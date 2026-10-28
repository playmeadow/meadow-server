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
   import game.MinigameManager;
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
      
      public function init(param1:Array, param2:Array, param3:Array = null, param4:int = -1, param5:int = -1, param6:Boolean = true, param7:Number = 512, param8:Number = 288, param9:Function = null) : void
      {
         this._videos = param1;
         this._videoDesc = param3;
         this._subtitleIds = param2;
         this._playerWidth = param7;
         this._playerHeight = param8;
         this._shouldRepeatSingleMovie = param6;
         this._currVideoIdx = param5;
         this._closeCallback = param9;
         this._mouseOverTimer = new Timer(10,300);
         this._mouseOverTimer.addEventListener(TimerEvent.TIMER,this.onMouseOverTimer,false,0,true);
         if(this._currVideoIdx >= this._videos.length || this._currVideoIdx < 0)
         {
            this._currVideoIdx = Math.round(Math.random() * (this._videos.length - 1));
         }
         if(param4 >= 0)
         {
            this._videoMediaHelper = new MediaHelper();
            this._videoMediaHelper.init(param4,this.mediaHelperCallback);
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
         this._videoPlayer.autoRewind = param6;
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
      
      private function loadPlugin(param1:String) : void
      {
         var _loc2_:MediaResourceBase = null;
         var _loc3_:Class = null;
         if(param1.substr(0,4) == "http" || param1.substr(0,4) == "file")
         {
            _loc2_ = new URLResource(param1);
         }
         else
         {
            _loc3_ = getDefinitionByName(param1) as Class;
            _loc2_ = new PluginInfoResource(new _loc3_());
         }
         this.loadPluginFromResource(_loc2_);
      }
      
      private function loadPluginFromResource(param1:MediaResourceBase) : void
      {
         this._mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD,this.onPluginLoaded);
         this._mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR,this.onPluginLoadFailed);
         this._mediaFactory.loadPlugin(param1);
      }
      
      private function onPluginLoaded(param1:MediaFactoryEvent) : void
      {
      }
      
      private function onPluginLoadFailed(param1:MediaFactoryEvent) : void
      {
      }
      
      private function onPlayPauseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            this._videoPlayer.pause();
            this._mouseOverTimer.reset();
            param1.currentTarget.parent.playPauseBtn.gotoAndStop("play");
         }
         else if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "pause")
         {
            param1.currentTarget.parent.playPauseBtn.gotoAndStop("pause");
            this._videoPlayer.play();
            this._mouseOverTimer.start();
            param1.currentTarget.parent.playPauseBtn.alpha = 1;
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            this._mouseOverTimer.reset();
            param1.currentTarget.parent.playPauseBtn.visible = false;
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.playPauseBtn.currentFrameLabel != "play")
         {
            this._mouseOverTimer.start();
            param1.currentTarget.parent.playPauseBtn.alpha = 1;
            param1.currentTarget.parent.playPauseBtn.visible = true;
         }
      }
      
      private function onMouseOverTimer(param1:TimerEvent) : void
      {
         if(param1.currentTarget.currentCount > 200)
         {
            if(this._theaterWindow)
            {
               this._theaterWindow.playPauseBtn.alpha -= 0.01;
            }
            else if(this._playerPopup)
            {
               this._playerPopup.playPauseBtn.alpha -= 0.01;
            }
            if(param1.currentTarget.currentCount == this._mouseOverTimer.repeatCount)
            {
               this._mouseOverTimer.reset();
            }
         }
      }
      
      private function onBytesLoadedChange(param1:LoadEvent) : void
      {
         param1.stopPropagation();
         if(this._playerPopup.loadTxt)
         {
            this._playerPopup.loadTxt.text = int(param1.bytes / param1.currentTarget.bytesTotal * 100) + "%";
         }
      }
      
      private function onBufferLengthChange(param1:BufferEvent) : void
      {
         if(param1.bufferLength <= 0.01)
         {
            this._bufferTimer = new Timer(10000);
            this._bufferTimer.addEventListener(TimerEvent.TIMER,this.onCheckBufferLength);
            this._bufferTimer.start();
         }
         else if(this._bufferTimer)
         {
            this._bufferTimer.stop();
            this._bufferTimer.removeEventListener(TimerEvent.TIMER,this.onCheckBufferLength);
            this._bufferTimer = null;
         }
      }
      
      private function onMediaPlayerStateChange(param1:MediaPlayerStateChangeEvent) : void
      {
         param1.stopPropagation();
         if(param1.state == "buffering")
         {
         }
         if(param1.state == "playing")
         {
         }
      }
      
      private function onCheckBufferLength(param1:TimerEvent) : void
      {
         new SBOkPopup(GuiManager.guiLayer,"This video is not available anymore.");
      }
      
      private function onBufferChange(param1:BufferEvent) : void
      {
         param1.stopPropagation();
         if(param1.buffering)
         {
            this.addSpiral();
         }
         else
         {
            this.removeSpiral();
         }
      }
      
      private function onTimeEvent(param1:TimeEvent) : void
      {
      }
      
      private function canPlay(param1:MediaPlayerCapabilityChangeEvent) : void
      {
         if(this._startUpTimer)
         {
            this._startUpTimer.addEventListener(TimerEvent.TIMER,this.onStartupCheck);
            this._startUpTimer.start();
         }
      }
      
      private function onMediaSizeChange(param1:DisplayObjectEvent) : void
      {
         if(this._startUpTimer)
         {
            this._startUpTimer.stop();
            this._startUpTimer.removeEventListener(TimerEvent.TIMER,this.onStartupCheck);
            this._startUpTimer = null;
         }
      }
      
      private function onStartupCheck(param1:TimerEvent) : void
      {
         this._startUpTimer.stop();
         this._startUpTimer.removeEventListener(TimerEvent.TIMER,this.onStartupCheck);
         this._startUpTimer = null;
      }
      
      private function onStateChange(param1:PlayEvent) : void
      {
         if(param1.playState == "playing")
         {
            SBTracker.trackPageview("/game/play/video/#" + this._videos[this._currVideoIdx]);
         }
      }
      
      public function destroy() : void
      {
         this.destroyPlayerItems();
         if(this._videoMediaHelper)
         {
            this._videoMediaHelper.destroy();
            this._videoMediaHelper = null;
         }
         if(this._playerPopup)
         {
            this._playerPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            this._playerPopup.visible = false;
            this._playerPopup = null;
         }
         if(this._loadingSpiral)
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
         if(!MinigameManager.inMinigame() && this._hasMediaId)
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
      
      public function setSkinFrame(param1:int) : void
      {
         this._skinFrameId = param1;
         if(Boolean(this._playerPopup) && this._playerPopup.currentFrame != this._skinFrameId)
         {
            this._playerPopup.gotoAndPlay(this._skinFrameId);
         }
      }
      
      private function destroyPlayerItems() : void
      {
         if(this._startUpTimer)
         {
            this._startUpTimer.stop();
            this._startUpTimer.removeEventListener(TimerEvent.TIMER,this.onStartupCheck);
            this._startUpTimer = null;
         }
         if(this._bufferTimer)
         {
            this._bufferTimer.stop();
            this._bufferTimer.removeEventListener(TimerEvent.TIMER,this.onCheckBufferLength);
            this._bufferTimer = null;
         }
         if(this._videoPlayer)
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
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            this._playerPopup = MovieClip(param1.getChildAt(0));
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
      
      public function playVideoIdx(param1:int) : void
      {
         this._currVideoIdx = param1;
         this.playNonStreaming();
      }
      
      private function playNonStreaming() : void
      {
         var _loc3_:Metadata = null;
         var _loc1_:URLResource = new URLResource(LoaderCache.fetchCDNURL("streams/" + this._videos[this._currVideoIdx] + ".flv"));
         this.onHideCaption(null);
         if(LocalizationManager.currentLanguage != LocalizationManager.LANG_ENG && this._subtitleIds[this._currVideoIdx] != 0)
         {
            _loc3_ = new Metadata();
            _loc3_.addValue(CaptioningPluginInfo.CAPTIONING_METADATA_KEY_URI,LoaderCache.fetchCDNURL("subtitle/" + this._subtitleIds[this._currVideoIdx] + "/" + LocalizationManager.currentLanguage));
            MediaResourceBase(_loc1_).addMetadataValue(CaptioningPluginInfo.CAPTIONING_METADATA_NAMESPACE,_loc3_);
         }
         var _loc2_:NetLoader = new NetLoader();
         this._mediaFactory.addItem(new MediaFactoryItem("org.osmf.elements.video",_loc2_.canHandleResource,this.createVideoElement));
         this._videoElement = this._mediaFactory.createMediaElement(_loc1_);
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
      
      private function setMediaElement(param1:MediaElement) : void
      {
         if(this._videoPlayer.media != null && this._container.containsMediaElement(this._videoPlayer.media))
         {
            this._container.removeMediaElement(this._videoPlayer.media);
         }
         if(param1 != null)
         {
            this._container.addMediaElement(param1);
         }
         this._videoPlayer.media = param1;
      }
      
      private function enablePlayerControls(param1:Boolean = true) : void
      {
      }
      
      private function createVideoElement() : MediaElement
      {
         return new VideoElement();
      }
      
      private function onTraitAdd(param1:MediaElementEvent) : void
      {
         switch(param1.traitType)
         {
            case MediaTraitType.SEEK:
         }
      }
      
      private function onShowCaption(param1:TimelineMetadataEvent) : void
      {
         var _loc2_:Caption = param1.marker as Caption;
         if(_loc2_ != null)
         {
            this._subTitleTextField.htmlText = _loc2_.text;
            if(!this._graySubtitleBox.visible)
            {
               this._graySubtitleBox.visible = true;
            }
         }
      }
      
      private function onHideCaption(param1:TimelineMetadataEvent) : void
      {
         this._subTitleTextField.htmlText = "";
         this._graySubtitleBox.visible = false;
      }
      
      private function onMediaError(param1:MediaErrorEvent) : void
      {
      }
      
      private function formatCaption(param1:Caption) : void
      {
         var _loc3_:CaptionFormat = null;
         var _loc4_:TextFormat = null;
         var _loc5_:CaptionStyle = null;
         var _loc2_:uint = 0;
         while(_loc2_ < param1.numCaptionFormats)
         {
            _loc3_ = param1.getCaptionFormatAt(_loc2_);
            _loc4_ = new TextFormat();
            _loc5_ = _loc3_.style;
            if(_loc5_.textColor != null)
            {
               _loc4_.color = _loc5_.textColor;
            }
            if(_loc5_.fontFamily != "")
            {
               _loc4_.font = _loc5_.fontFamily;
            }
            if(_loc5_.fontSize > 0)
            {
               _loc4_.size = _loc5_.fontSize;
            }
            if(_loc5_.fontStyle != "")
            {
               _loc4_.italic = _loc5_.fontStyle == "italic" ? true : false;
            }
            if(_loc5_.fontWeight != "")
            {
               _loc4_.bold = _loc5_.fontWeight == "bold" ? true : false;
            }
            if(_loc5_.textAlign != "")
            {
               _loc4_.align = _loc5_.textAlign;
            }
            this._playerPopup.subtitle.setTextFormat(_loc4_,_loc3_.startIndex,_loc3_.endIndex);
            if(this._playerPopup.subtitle.wordWrap != _loc5_.wrapOption)
            {
               this._playerPopup.subtitle.wordWrap = _loc5_.wrapOption;
            }
            _loc2_++;
         }
      }
      
      private function onSMILPluginLoaded(param1:MediaFactoryEvent) : void
      {
         var _loc2_:DynamicStreamingResource = new DynamicStreamingResource("http://wac.6A16.edgecastcdn.net/006A16/IntroVideo/manifest.smil",StreamType.RECORDED);
         _loc2_.urlIncludesFMSApplicationInstance = true;
         this._videoElement = this._mediaFactory.createMediaElement(_loc2_);
         this._videoPlayer.media = this._videoElement;
         this._videoPlayer.bufferTime = 6;
         this._container.addMediaElement(this._videoElement);
         if(SBAudio.isMusicMuted)
         {
            this._videoPlayer.volume = 0;
         }
      }
      
      private function playLiveStream(param1:int) : void
      {
         this._FCS = new FCSubscribeHandler();
         this._FCS.run("mba_opensea","rtmp://fml.6A16.edgecastcdn.net/206A16",this);
      }
      
      public function fcSubscribeDone() : void
      {
         var _loc1_:StreamingURLResource = new StreamingURLResource("rtmp://fml.6A16.edgecastcdn.net/206A16/mba_opensea",StreamType.LIVE);
         this._videoElement = this._mediaFactory.createMediaElement(_loc1_);
         this._videoPlayer.media = this._videoElement;
         this._videoPlayer.bufferTime = 6;
         this._container.addMediaElement(this._videoElement);
         if(SBAudio.isMusicMuted)
         {
            this._videoPlayer.volume = 0;
         }
      }
      
      private function onPluginLoadError(param1:MediaFactoryEvent) : void
      {
      }
      
      private function completeHandler(param1:TimeEvent) : void
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
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
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
            if(this._playerPopup.itemLayer.contains(this._loadingSpiral))
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
      
      private function mouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

