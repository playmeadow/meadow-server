package movie
{
   import avatar.UserCommXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import org.osmf.captioning.CaptioningPluginInfo;
   import org.osmf.captioning.model.Caption;
   import org.osmf.captioning.model.CaptionFormat;
   import org.osmf.captioning.model.CaptionStyle;
   import org.osmf.containers.MediaContainer;
   import org.osmf.elements.VideoElement;
   import org.osmf.events.BufferEvent;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MediaFactoryEvent;
   import org.osmf.events.MediaPlayerCapabilityChangeEvent;
   import org.osmf.events.MediaPlayerStateChangeEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.TimeEvent;
   import org.osmf.events.TimelineMetadataEvent;
   import org.osmf.media.DefaultMediaFactory;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.MediaPlayer;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfoResource;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.TimelineMetadata;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetLoader;
   import org.osmf.net.StreamType;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.utils.FCSubscribeHandler;
   
   public class VideoPlayerOSMF extends Sprite
   {
      
      private var _videoMediaHelper:MediaHelper;
      
      private var _playerPopup:MovieClip;
      
      private var _videoLayer:Sprite;
      
      private var _videoPlayer:MediaPlayer;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _currVideoIdx:int;
      
      private var _videos:Array;
      
      private var _videoDesc:Array;
      
      private var _subtitleIds:Array;
      
      private var _loadText:TextField;
      
      private var _hasMediaId:Boolean;
      
      private var _skinFrameId:int = 1;
      
      private var _subTitleTextField:TextField;
      
      private var _graySubtitleBox:MovieClip;
      
      private var _musicMutedByPlayer:Boolean;
      
      private var _isReady:Boolean;
      
      private var _isPaused:Boolean;
      
      private var _readyToStart:Boolean;
      
      private var _popupLoaded:Boolean;
      
      private var _netConnected:Boolean;
      
      private var _playerWidth:int;
      
      private var _playerHeight:int;
      
      private var _info:Object;
      
      private var _shouldRepeatSingleMovie:Boolean;
      
      private var _container:MediaContainer;
      
      private var _videoElement:MediaElement;
      
      private var _mediaFactory:DefaultMediaFactory;
      
      private var _FCS:FCSubscribeHandler;
      
      private var _isLive:Boolean;
      
      private var _bufferTimer:Timer;
      
      private var _startUpTimer:Timer;
      
      private var _captionMetadata:TimelineMetadata;
      
      private var _theaterWindow:MovieClip;
      
      private var _mouseOverTimer:Timer;
      
      private var _closeCallback:Function;
      
      public function VideoPlayerOSMF()
      {
         super();
      }
      
      public function init(initVideos:Array, initSubtitleIds:Array, initVideoDesc:Array = null, initMediaId:int = -1, initCurrVideoIdx:int = -1, initShouldRepeat:Boolean = true, initWidth:Number = 512, initHeight:Number = 288, initCloseCallback:Function = null) : void
      {
         this._videos = initVideos;
         this._videoDesc = initVideoDesc;
         this._subtitleIds = initSubtitleIds;
         this._playerWidth = initWidth;
         this._playerHeight = initHeight;
         this._shouldRepeatSingleMovie = initShouldRepeat;
         this._currVideoIdx = initCurrVideoIdx;
         this._closeCallback = initCloseCallback;
         this._mouseOverTimer = new Timer(10,300);
         this._mouseOverTimer.addEventListener(TimerEvent.TIMER,this.onMouseOverTimer,false,0,true);
         if(this._currVideoIdx >= this._videos.length || this._currVideoIdx < 0)
         {
            this._currVideoIdx = Math.round(Math.random() * (this._videos.length - 1));
         }
         if(initMediaId >= 0)
         {
            this._videoMediaHelper = new MediaHelper();
            this._videoMediaHelper.init(initMediaId,this.mediaHelperCallback);
            this._hasMediaId = true;
         }
         this._startUpTimer = new Timer(5000);
         this._videoPlayer = new MediaPlayer();
         this._container = new MediaContainer();
         this._mediaFactory = new DefaultMediaFactory();
         if(LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG)
         {
            this.loadPlugin("org.osmf.captioning.CaptioningPluginInfo");
         }
         this._container.width = this._playerWidth;
         this._container.height = this._playerHeight;
         this._videoPlayer.autoPlay = true;
         this._videoPlayer.autoRewind = initShouldRepeat;
         this._videoPlayer.addEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE,this.canPlay,false,0,true);
         this._videoPlayer.addEventListener(PlayEvent.PLAY_STATE_CHANGE,this.onStateChange,false,0,true);
         this._videoPlayer.addEventListener(BufferEvent.BUFFERING_CHANGE,this.onBufferChange,false,0,true);
         this._videoPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,this.onMediaPlayerStateChange,false,0,true);
         this._videoPlayer.addEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.onMediaSizeChange,false,0,true);
         this._videoPlayer.addEventListener(TimeEvent.COMPLETE,this.completeHandler,false,0,true);
         if(this._hasMediaId)
         {
            this._videoPlayer.addEventListener(LoadEvent.BYTES_LOADED_CHANGE,this.onBytesLoadedChange,false,0,true);
         }
         if(this._isLive)
         {
            this._videoPlayer.addEventListener(BufferEvent.BUFFER_LENGTH_CHANGE,this.onBufferLengthChange,false,0,true);
         }
         this._videoPlayer.currentTimeUpdateInterval = 100;
         if(this._hasMediaId)
         {
            this._container.x -= this._playerWidth * 0.5;
            this._container.y -= this._playerHeight * 0.5;
            UserCommXtCommManager.sendPermEmote(542,false);
            SBTracker.push();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            this._theaterWindow = MovieClip(this.parent);
            this._theaterWindow.parent.mouseEnabled = true;
            this._theaterWindow.parent.mouseChildren = true;
            this._loadingSpiral = new LoadingSpiral(this._theaterWindow,this._theaterWindow.width * 0.5,this._theaterWindow.height * 0.5);
            this._theaterWindow.hoverState.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayPauseBtn,false,0,true);
            this._theaterWindow.hoverState.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
            this._theaterWindow.hoverState.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            this._theaterWindow.playPauseBtn.visible = false;
            this._theaterWindow.playPauseBtn.gotoAndStop("pause");
            this._theaterWindow.videoLayer.addChild(this._container);
            this._subTitleTextField = this._theaterWindow.subtitle;
            this._subTitleTextField.htmlText = "";
            this._graySubtitleBox = this._theaterWindow.grayBox;
            this._graySubtitleBox.visible = false;
            this._popupLoaded = true;
            this.playVideoIdx(this._currVideoIdx);
         }
      }
      
      private function loadPlugin(source:String) : void
      {
         var pluginResource:MediaResourceBase = null;
         var pluginInfoRef:Class = null;
         if(source.substr(0,4) == "http" || source.substr(0,4) == "file")
         {
            pluginResource = new URLResource(source);
         }
         else
         {
            pluginInfoRef = getDefinitionByName(source) as Class;
            pluginResource = new PluginInfoResource(new pluginInfoRef());
         }
         this.loadPluginFromResource(pluginResource);
      }
      
      private function loadPluginFromResource(pluginResource:MediaResourceBase) : void
      {
         this._mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD,this.onPluginLoaded);
         this._mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR,this.onPluginLoadFailed);
         this._mediaFactory.loadPlugin(pluginResource);
      }
      
      private function onPluginLoaded(event:MediaFactoryEvent) : void
      {
         trace("Plugin LOADED!");
      }
      
      private function onPluginLoadFailed(event:MediaFactoryEvent) : void
      {
         trace("Plugin LOAD FAILED!");
      }
      
      private function onPlayPauseBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            this._videoPlayer.pause();
            this._mouseOverTimer.reset();
            evt.currentTarget.parent.playPauseBtn.gotoAndStop("play");
         }
         else if(evt.currentTarget.parent.playPauseBtn.currentFrameLabel != "pause")
         {
            evt.currentTarget.parent.playPauseBtn.gotoAndStop("pause");
            this._videoPlayer.play();
            this._mouseOverTimer.start();
            evt.currentTarget.parent.playPauseBtn.alpha = 1;
         }
      }
      
      private function onRollOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            this._mouseOverTimer.reset();
            evt.currentTarget.parent.playPauseBtn.visible = false;
         }
      }
      
      private function onRollOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            this._mouseOverTimer.start();
            evt.currentTarget.parent.playPauseBtn.alpha = 1;
            evt.currentTarget.parent.playPauseBtn.visible = true;
         }
      }
      
      private function onMouseOverTimer(t:TimerEvent) : void
      {
         if(t.currentTarget.currentCount > 200)
         {
            if(Boolean(this._theaterWindow))
            {
               this._theaterWindow.playPauseBtn.alpha -= 0.01;
            }
            else if(Boolean(this._playerPopup))
            {
               this._playerPopup.playPauseBtn.alpha -= 0.01;
            }
            if(t.currentTarget.currentCount == this._mouseOverTimer.repeatCount)
            {
               this._mouseOverTimer.reset();
            }
         }
      }
      
      private function onBytesLoadedChange(evt:LoadEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._playerPopup.loadTxt))
         {
            this._playerPopup.loadTxt.text = int(evt.bytes / evt.currentTarget.bytesTotal * 100) + "%";
         }
      }
      
      private function onBufferLengthChange(evt:BufferEvent) : void
      {
         if(evt.bufferLength <= 0.01)
         {
            this._bufferTimer = new Timer(10000);
            this._bufferTimer.addEventListener(TimerEvent.TIMER,this.onCheckBufferLength);
            this._bufferTimer.start();
         }
         else if(Boolean(this._bufferTimer))
         {
            this._bufferTimer.stop();
            this._bufferTimer.removeEventListener(TimerEvent.TIMER,this.onCheckBufferLength);
            this._bufferTimer = null;
         }
      }
      
      private function onMediaPlayerStateChange(evt:MediaPlayerStateChangeEvent) : void
      {
         evt.stopPropagation();
         if(evt.state == "buffering")
         {
         }
         if(evt.state == "playing")
         {
         }
      }
      
      private function onCheckBufferLength(e:TimerEvent) : void
      {
         new SBOkPopup(GuiManager.guiLayer,"This video is not available anymore.");
      }
      
      private function onBufferChange(evt:BufferEvent) : void
      {
         evt.stopPropagation();
         if(evt.buffering)
         {
            this.addSpiral();
         }
         else
         {
            this.removeSpiral();
         }
      }
      
      private function onTimeEvent(evt:TimeEvent) : void
      {
      }
      
      private function canPlay(evt:MediaPlayerCapabilityChangeEvent) : void
      {
         if(Boolean(this._startUpTimer))
         {
            this._startUpTimer.addEventListener(TimerEvent.TIMER,this.onStartupCheck);
            this._startUpTimer.start();
         }
      }
      
      private function onMediaSizeChange(evt:DisplayObjectEvent) : void
      {
         if(Boolean(this._startUpTimer))
         {
            this._startUpTimer.stop();
            this._startUpTimer.removeEventListener(TimerEvent.TIMER,this.onStartupCheck);
            this._startUpTimer = null;
         }
      }
      
      private function onStartupCheck(t:TimerEvent) : void
      {
         this._startUpTimer.stop();
         this._startUpTimer.removeEventListener(TimerEvent.TIMER,this.onStartupCheck);
         this._startUpTimer = null;
      }
      
      private function onStateChange(evt:PlayEvent) : void
      {
         if(evt.playState == "playing")
         {
            SBTracker.trackPageview("/game/play/video/#" + this._videos[this._currVideoIdx]);
         }
      }
      
      public function destroy() : void
      {
         this.destroyPlayerItems();
         if(Boolean(this._videoMediaHelper))
         {
            this._videoMediaHelper.destroy();
            this._videoMediaHelper = null;
         }
         if(Boolean(this._playerPopup))
         {
            this._playerPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            this._playerPopup.visible = false;
            this._playerPopup = null;
         }
         if(Boolean(this._loadingSpiral))
         {
            this._loadingSpiral.destroy();
            this._loadingSpiral = null;
         }
         this._videos = null;
         this._videoDesc = null;
         if(this._musicMutedByPlayer)
         {
            this._musicMutedByPlayer = false;
            SBAudio.unmuteMusic(false);
         }
         if(this._hasMediaId)
         {
            UserCommXtCommManager.sendPermEmote(-1,false);
         }
      }
      
      public function toggleSound() : void
      {
         if(this._videoPlayer.volume == 0)
         {
            this._videoPlayer.volume = 1;
         }
         else
         {
            this._videoPlayer.volume = 0;
         }
      }
      
      public function setSkinFrame(frameId:int) : void
      {
         this._skinFrameId = frameId;
         if(Boolean(this._playerPopup) && this._playerPopup.currentFrame != this._skinFrameId)
         {
            this._playerPopup.gotoAndPlay(this._skinFrameId);
         }
      }
      
      private function destroyPlayerItems() : void
      {
         if(Boolean(this._startUpTimer))
         {
            this._startUpTimer.stop();
            this._startUpTimer.removeEventListener(TimerEvent.TIMER,this.onStartupCheck);
            this._startUpTimer = null;
         }
         if(Boolean(this._bufferTimer))
         {
            this._bufferTimer.stop();
            this._bufferTimer.removeEventListener(TimerEvent.TIMER,this.onCheckBufferLength);
            this._bufferTimer = null;
         }
         if(Boolean(this._videoPlayer))
         {
            this._videoPlayer.stop();
            this._videoPlayer.media = null;
            if(this._container.containsMediaElement(this._videoElement))
            {
               this._container.removeMediaElement(this._videoElement);
            }
            while(this._container.numChildren > 0)
            {
               this._container.removeChildAt(0);
            }
            this._videoPlayer.removeEventListener(MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE,this.canPlay);
            this._videoPlayer.removeEventListener(PlayEvent.PLAY_STATE_CHANGE,this.onStateChange);
            this._videoPlayer.removeEventListener(BufferEvent.BUFFERING_CHANGE,this.onBufferChange);
            this._videoPlayer.removeEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,this.onMediaPlayerStateChange);
            this._videoPlayer.removeEventListener(DisplayObjectEvent.MEDIA_SIZE_CHANGE,this.onMediaSizeChange);
            if(this._isLive)
            {
               this._videoPlayer.removeEventListener(BufferEvent.BUFFER_LENGTH_CHANGE,this.onBufferLengthChange);
            }
            this._videoElement = null;
            this._container = null;
            this._videoPlayer = null;
            this._mediaFactory = null;
         }
      }
      
      private function mediaHelperCallback(mc:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(mc))
         {
            this._playerPopup = MovieClip(mc.getChildAt(0));
            if(this._playerPopup.currentFrame != this._skinFrameId)
            {
               this._playerPopup.gotoAndPlay(this._skinFrameId);
            }
            GuiManager.guiLayer.addChild(this._playerPopup);
            if(Boolean(this._videoDesc) && this._videoDesc.length > 0)
            {
               LocalizationManager.translateId(this._playerPopup.videoTitleTxt,this._videoDesc[this._currVideoIdx]);
            }
            else
            {
               LocalizationManager.translateId(this._playerPopup.videoTitleTxt,11392);
            }
            this._playerPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._playerPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._playerPopup.itemLayer.addChild(this._container);
            this._playerPopup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            this._playerPopup.hoverState.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlayPauseBtn);
            this._playerPopup.hoverState.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
            this._playerPopup.hoverState.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            this._playerPopup.playPauseBtn.visible = false;
            this._playerPopup.playPauseBtn.gotoAndStop("pause");
            this._playerPopup.loadTxt.text = "0%";
            this._subTitleTextField = this._playerPopup.subtitle;
            this._subTitleTextField.htmlText = "";
            this._graySubtitleBox = this._playerPopup.grayBox;
            this._graySubtitleBox.visible = false;
            this._playerPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            DarkenManager.darken(this._playerPopup);
            this._loadingSpiral = new LoadingSpiral(this._playerPopup.itemLayer);
            this._popupLoaded = true;
            this.playVideoIdx(this._currVideoIdx);
         }
      }
      
      public function playVideoIdx(idx:int) : void
      {
         this._currVideoIdx = idx;
         this.playNonStreaming();
      }
      
      private function playNonStreaming() : void
      {
         var metadata:Metadata = null;
         var resource:URLResource = new URLResource(LoaderCache.fetchCDNURL("streams/" + this._videos[this._currVideoIdx] + ".flv"));
         this.onHideCaption(null);
         if(LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG && this._subtitleIds[this._currVideoIdx] != 0)
         {
            metadata = new Metadata();
            metadata.addValue(CaptioningPluginInfo.CAPTIONING_METADATA_KEY_URI,LoaderCache.fetchCDNURL("subtitle/" + this._subtitleIds[this._currVideoIdx] + "/" + LocalizationManager.currentLanguage));
            MediaResourceBase(resource).addMetadataValue(CaptioningPluginInfo.CAPTIONING_METADATA_NAMESPACE,metadata);
         }
         var netLoader:NetLoader = new NetLoader();
         this._mediaFactory.addItem(new MediaFactoryItem("org.osmf.elements.video",netLoader.canHandleResource,this.createVideoElement));
         this._videoElement = this._mediaFactory.createMediaElement(resource);
         this._videoElement.addEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
         this._captionMetadata = this._videoElement.getMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
         if(this._captionMetadata == null)
         {
            this._captionMetadata = new TimelineMetadata(this._videoElement);
            this._videoElement.addMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE,this._captionMetadata);
         }
         this._captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_TIME_REACHED,this.onShowCaption);
         this._captionMetadata.addEventListener(TimelineMetadataEvent.MARKER_ADD,this.onHideCaption);
         this._videoElement.addEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError,false,0,true);
         this.setMediaElement(this._videoElement);
         this.enablePlayerControls(true);
         if(!SBAudio.isMusicMuted)
         {
            SBAudio.muteMusic(false);
            this._musicMutedByPlayer = true;
         }
         else
         {
            this._videoPlayer.volume = 0;
         }
      }
      
      private function setMediaElement(value:MediaElement) : void
      {
         if(this._videoPlayer.media != null && this._container.containsMediaElement(this._videoPlayer.media))
         {
            this._container.removeMediaElement(this._videoPlayer.media);
         }
         if(value != null)
         {
            this._container.addMediaElement(value);
         }
         this._videoPlayer.media = value;
      }
      
      private function enablePlayerControls(enable:Boolean = true) : void
      {
      }
      
      private function createVideoElement() : MediaElement
      {
         return new VideoElement();
      }
      
      private function onTraitAdd(event:MediaElementEvent) : void
      {
         switch(event.traitType)
         {
            case MediaTraitType.SEEK:
         }
      }
      
      private function onShowCaption(event:TimelineMetadataEvent) : void
      {
         var caption:Caption = event.marker as Caption;
         if(caption != null)
         {
            this._subTitleTextField.htmlText = caption.text;
            if(!this._graySubtitleBox.visible)
            {
               this._graySubtitleBox.visible = true;
            }
         }
      }
      
      private function onHideCaption(event:TimelineMetadataEvent) : void
      {
         this._subTitleTextField.htmlText = "";
         this._graySubtitleBox.visible = false;
      }
      
      private function onMediaError(event:MediaErrorEvent) : void
      {
         trace("Media Load Error : " + event.error.errorID + " - " + event.error.message);
      }
      
      private function formatCaption(caption:Caption) : void
      {
         var captionFormat:CaptionFormat = null;
         var txtFormat:TextFormat = null;
         var style:CaptionStyle = null;
         for(var i:uint = 0; i < caption.numCaptionFormats; i++)
         {
            captionFormat = caption.getCaptionFormatAt(i);
            txtFormat = new TextFormat();
            style = captionFormat.style;
            if(style.textColor != null)
            {
               txtFormat.color = style.textColor;
            }
            if(style.fontFamily != "")
            {
               txtFormat.font = style.fontFamily;
            }
            if(style.fontSize > 0)
            {
               txtFormat.size = style.fontSize;
            }
            if(style.fontStyle != "")
            {
               txtFormat.italic = style.fontStyle == "italic" ? true : false;
            }
            if(style.fontWeight != "")
            {
               txtFormat.bold = style.fontWeight == "bold" ? true : false;
            }
            if(style.textAlign != "")
            {
               txtFormat.align = style.textAlign;
            }
            this._playerPopup.subtitle.setTextFormat(txtFormat,captionFormat.startIndex,captionFormat.endIndex);
            if(this._playerPopup.subtitle.wordWrap != style.wrapOption)
            {
               this._playerPopup.subtitle.wordWrap = style.wrapOption;
            }
         }
      }
      
      private function onSMILPluginLoaded(evt:MediaFactoryEvent) : void
      {
         var myResource:DynamicStreamingResource = new DynamicStreamingResource("http://wac.6A16.edgecastcdn.net/006A16/IntroVideo/manifest.smil",StreamType.RECORDED);
         myResource.urlIncludesFMSApplicationInstance = true;
         this._videoElement = this._mediaFactory.createMediaElement(myResource);
         this._videoPlayer.media = this._videoElement;
         this._videoPlayer.bufferTime = 6;
         this._container.addMediaElement(this._videoElement);
         if(SBAudio.isMusicMuted)
         {
            this._videoPlayer.volume = 0;
         }
      }
      
      private function playLiveStream(idx:int) : void
      {
         this._FCS = new FCSubscribeHandler();
         this._FCS.run("mba_opensea","rtmp://fml.6A16.edgecastcdn.net/206A16",this);
      }
      
      public function fcSubscribeDone() : void
      {
         var myResource:StreamingURLResource = new StreamingURLResource("rtmp://fml.6A16.edgecastcdn.net/206A16/mba_opensea",StreamType.LIVE);
         this._videoElement = this._mediaFactory.createMediaElement(myResource);
         this._videoPlayer.media = this._videoElement;
         this._videoPlayer.bufferTime = 6;
         this._container.addMediaElement(this._videoElement);
         if(SBAudio.isMusicMuted)
         {
            this._videoPlayer.volume = 0;
         }
      }
      
      private function onPluginLoadError(evt:MediaFactoryEvent) : void
      {
         trace("FAILED TO LOAD PLUGIN");
      }
      
      private function completeHandler(evt:TimeEvent) : void
      {
         this.addSpiral();
         this._videoPlayer.stop();
         this._container.removeMediaElement(this._videoElement);
         if(this._currVideoIdx < this._videos.length - 1)
         {
            ++this._currVideoIdx;
         }
         else
         {
            this._currVideoIdx = 0;
         }
         if(this._shouldRepeatSingleMovie)
         {
            this.playVideoIdx(this._currVideoIdx);
         }
         else
         {
            this.onClose(null);
         }
      }
      
      private function onClose(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         DarkenManager.unDarken(this._playerPopup);
         if(this._hasMediaId)
         {
            SBTracker.pop();
         }
         this.destroy();
         if(this._closeCallback != null)
         {
            this._closeCallback();
            this._closeCallback = null;
         }
      }
      
      private function removeSpiral() : void
      {
         if(this._hasMediaId)
         {
            if(Boolean(this._playerPopup.itemLayer.contains(this._loadingSpiral)))
            {
               this._playerPopup.itemLayer.removeChild(this._loadingSpiral);
            }
         }
         else if(this._theaterWindow.contains(this._loadingSpiral))
         {
            this._theaterWindow.removeChild(this._loadingSpiral);
         }
      }
      
      private function addSpiral() : void
      {
         if(this._hasMediaId)
         {
            if(Boolean(this._loadingSpiral) && !this._playerPopup.itemLayer.contains(this._loadingSpiral))
            {
               this._playerPopup.itemLayer.addChild(this._loadingSpiral);
            }
         }
         else if(Boolean(this._loadingSpiral) && !this._theaterWindow.contains(this._loadingSpiral))
         {
            this._theaterWindow.addChild(this._loadingSpiral);
         }
      }
      
      private function mouseDown(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
   }
}

