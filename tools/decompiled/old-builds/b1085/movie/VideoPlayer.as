package movie
{
   import avatar.UserCommXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.loader.LoaderCache;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.NetStatusEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.text.TextField;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class VideoPlayer extends Sprite
   {
      
      private var _videoMediaHelper:MediaHelper;
      
      private var _playerPopup:MovieClip;
      
      private var _videoLayer:Sprite;
      
      private var _videoPlayer:Video;
      
      private var _stream:NetStream;
      
      private var _connection:NetConnection;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _playerTitleText:TextField;
      
      private var _currVideoIdx:int;
      
      private var _videos:Array;
      
      private var _videoDesc:Array;
      
      private var _loadText:TextField;
      
      private var _hasMediaId:Boolean;
      
      private var _skinFrameId:int = 1;
      
      private var _musicMutedByPlayer:Boolean;
      
      private var _isReady:Boolean;
      
      private var _isPaused:Boolean;
      
      private var _readyToStart:Boolean;
      
      private var _bandwidthTimer:Timer;
      
      private var _bandwidthRates:Array;
      
      private var _popupLoaded:Boolean;
      
      private var _netConnected:Boolean;
      
      private var _playerWidth:int;
      
      private var _playerHeight:int;
      
      private var _info:Object;
      
      private var _shouldRepeatSingleMovie:Boolean;
      
      private var _closeCallback:Function;
      
      public function VideoPlayer()
      {
         super();
      }
      
      public function init(param1:Array, param2:Array = null, param3:int = -1, param4:int = -1, param5:Boolean = true, param6:Number = 512, param7:Number = 288, param8:Function = null) : void
      {
         this._videos = param1;
         this._videoDesc = param2;
         this._playerWidth = param6;
         this._playerHeight = param7;
         this._shouldRepeatSingleMovie = param5;
         this._closeCallback = param8;
         this._bandwidthTimer = new Timer(100);
         this._bandwidthRates = [];
         this._currVideoIdx = param4;
         if(this._currVideoIdx >= this._videos.length || this._currVideoIdx < 0)
         {
            this._currVideoIdx = Math.round(Math.random() * (this._videos.length - 1));
         }
         if(param3 >= 0)
         {
            this._videoMediaHelper = new MediaHelper();
            this._videoMediaHelper.init(param3,this.mediaHelperCallback);
            this._hasMediaId = true;
         }
         this._connection = new NetConnection();
         this._connection.addEventListener(NetStatusEvent.NET_STATUS,this.netStartHandler);
         this._connection.connect(null);
         this._videoPlayer = new Video(this._playerWidth,this._playerHeight);
         this._videoPlayer.visible = false;
         if(this._hasMediaId)
         {
            this._videoPlayer.x -= this._videoPlayer.width * 0.5;
            this._videoPlayer.y -= this._videoPlayer.height * 0.5;
            UserCommXtCommManager.sendPermEmote(542,false);
            SBTracker.push();
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            this.addChild(this._videoPlayer);
            this._loadingSpiral = new LoadingSpiral(this,this.width * 0.5,this.height * 0.5);
            this._popupLoaded = true;
            if(this._netConnected)
            {
               this.initPlayer();
            }
         }
      }
      
      public function destroy() : void
      {
         if(this._videoPlayer)
         {
            this.dispose();
            this._videoPlayer = null;
         }
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
         if(this._hasMediaId)
         {
            UserCommXtCommManager.sendPermEmote(-1,false);
         }
      }
      
      public function playVideoIdx(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:SoundTransform = null;
         if(Boolean(this._videoPlayer) && param1 <= this._videos.length)
         {
            this.stop();
            if(param1 == this._currVideoIdx && !param2)
            {
               this.seek(0);
               this.start();
            }
            else
            {
               this.reset();
               this.addSpiral();
               this._currVideoIdx = param1;
               this._stream.play(LoaderCache.fetchCDNURL("streams/" + this._videos[this._currVideoIdx] + ".flv"),0);
               if(SBAudio.isMusicMuted)
               {
                  _loc3_ = this._stream.soundTransform;
                  _loc3_.volume = 0;
                  this._stream.soundTransform = _loc3_;
               }
               this._readyToStart = true;
               if(this._playerPopup)
               {
                  LocalizationManager.translateId(this._playerTitleText,this._videoDesc[this._currVideoIdx]);
               }
               SBTracker.trackPageview("/game/play/video/#" + this._videoDesc[this._currVideoIdx]);
            }
         }
      }
      
      public function toggleSound() : void
      {
         var _loc1_:SoundTransform = null;
         if(this._stream)
         {
            _loc1_ = this._stream.soundTransform;
            if(_loc1_.volume == 0)
            {
               _loc1_.volume = 1;
            }
            else
            {
               _loc1_.volume = 0;
            }
            this._stream.soundTransform = _loc1_;
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
      
      public function skipVideo() : void
      {
         this.completeHandler();
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            this._playerPopup = param1;
            _loc2_ = MovieClip(this._playerPopup.getChildAt(0));
            if(_loc2_.currentFrame != this._skinFrameId)
            {
               _loc2_.gotoAndPlay(this._skinFrameId);
            }
            this._videoLayer = this._playerPopup.getChildAt(0)["itemLayer"];
            this._playerTitleText = _loc2_["videoTitleTxt"];
            GuiManager.guiLayer.addChild(this._playerPopup);
            if(Boolean(this._videoDesc) && this._videoDesc.length > 0)
            {
               LocalizationManager.translateId(this._playerTitleText,this._videoDesc[this._currVideoIdx]);
            }
            else
            {
               LocalizationManager.translateId(this._playerTitleText,11392);
            }
            this._playerPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._playerPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._videoLayer.addChild(this._videoPlayer);
            _loc2_["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            this._loadText = _loc2_["loadTxt"];
            this._loadText.text = "0%";
            this._playerPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDown);
            DarkenManager.darken(param1);
            this._loadingSpiral = new LoadingSpiral(this._videoLayer);
            this._popupLoaded = true;
            if(this._netConnected)
            {
               this.initPlayer();
            }
         }
      }
      
      private function initPlayer() : void
      {
         this._stream = new NetStream(this._connection);
         this._stream.bufferTime = 180;
         this._stream.addEventListener(NetStatusEvent.NET_STATUS,this.netStartHandler);
         this._videoPlayer.attachNetStream(this._stream);
         this._stream.client = new Object();
         this._stream.client.onMetaData = this.onMetaData;
         this.playVideoIdx(this._currVideoIdx,true);
         if(!SBAudio.isMusicMuted)
         {
            SBAudio.muteMusic(false);
            this._musicMutedByPlayer = true;
         }
      }
      
      private function netStartHandler(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetConnection.Connect.Success":
               this._netConnected = true;
               if(this._popupLoaded)
               {
                  this.initPlayer();
               }
               break;
            case "NetStream.Play.Start":
               param1.target.pause();
               param1.target.removeEventListener(NetStatusEvent.NET_STATUS,this.netStartHandler);
               param1.target.addEventListener(NetStatusEvent.NET_STATUS,this.netStopHandler);
               this._videoPlayer.visible = true;
               if(!this._isReady)
               {
                  this._isReady = true;
                  if(this._readyToStart && !this._isPaused)
                  {
                     this.removeSpiral();
                     this.start();
                  }
               }
               else
               {
                  this._bandwidthTimer.stop();
               }
         }
      }
      
      private function netStopHandler(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
         {
            case "NetStream.Play.Stop":
               this.completeHandler();
         }
      }
      
      private function completeHandler() : void
      {
         this.addSpiral();
         this.stop();
         var _loc1_:int = this._currVideoIdx;
         if(this._currVideoIdx < this._videos.length - 1)
         {
            _loc1_++;
         }
         else
         {
            _loc1_ = 0;
         }
         if(this._shouldRepeatSingleMovie)
         {
            this.playVideoIdx(_loc1_);
         }
         else
         {
            this.onClose(null);
         }
      }
      
      private function onMetaData(param1:Object) : void
      {
         var duration:Number = NaN;
         var amountLoaded:Number = NaN;
         var startTime:Number = NaN;
         var info:Object = param1;
         this._info = info;
         this._videoPlayer.visible = true;
         duration = Number(info.duration);
         this._stream.bufferTime = duration;
         amountLoaded = this._stream.bytesLoaded;
         startTime = getTimer();
         this._bandwidthTimer.addEventListener(TimerEvent.TIMER,function(param1:Event):void
         {
            var _loc2_:Number = NaN;
            var _loc3_:int = 0;
            var _loc4_:int = 0;
            var _loc5_:Number = NaN;
            var _loc6_:Number = NaN;
            var _loc7_:Number = NaN;
            var _loc8_:ProgressEvent = null;
            var _loc9_:Number = NaN;
            if(_stream)
            {
               _loc2_ = getTimer();
               _loc3_ = int(_stream.bytesLoaded);
               _loc4_ = Math.max(_stream.bytesTotal,1);
               _loc5_ = (_loc3_ - amountLoaded) / ((_loc2_ - startTime) / 1000);
               amountLoaded = _loc3_;
               startTime = _loc2_;
               _loc6_ = _loc4_ / duration;
               if(_loc3_ < _loc4_)
               {
                  _bandwidthRates.push(_loc5_);
               }
               if(_bandwidthRates.length > 50)
               {
                  _bandwidthRates.shift();
               }
               _loc5_ = getAverage(_bandwidthRates);
               _loc7_ = _loc4_ - _loc3_;
               _loc8_ = getProgress();
               if(_hasMediaId)
               {
                  _loadText.text = Math.round(_loc3_ / _loc4_ * 100) + "%";
               }
               if(_loc3_ >= _loc4_ || _loc8_.bytesLoaded >= _loc8_.bytesTotal)
               {
                  if(_hasMediaId)
                  {
                     _loadText.text = "100%";
                  }
                  _stream.bufferTime = 1;
                  _bandwidthTimer.reset();
                  _isReady = true;
                  if(_readyToStart && !_isPaused)
                  {
                     start();
                  }
                  return;
               }
               _loc9_ = calculateBuffer(duration,_loc6_,_loc5_);
               if(_bandwidthRates.length < 5 && _loc3_ < _loc4_)
               {
                  _loc9_ = Math.max(_stream.bufferTime * 2,_loc9_);
               }
               _stream.bufferTime = _loc9_;
            }
         });
         this._bandwidthTimer.start();
      }
      
      private function calculateBuffer(param1:Number, param2:Number, param3:Number) : Number
      {
         if(param2 > param3)
         {
            return Math.floor(Math.max(param1,1.05 * Math.ceil(param1 - param1 / (param2 / param3))));
         }
         return 1;
      }
      
      private function getProgress() : ProgressEvent
      {
         var _loc1_:ProgressEvent = null;
         if(this._stream != null && this._stream.bytesLoaded == this._stream.bytesTotal)
         {
            _loc1_ = new ProgressEvent(ProgressEvent.PROGRESS,false,false,this._stream.bytesLoaded,this._stream.bytesTotal);
         }
         else if(this._stream != null && this._stream.bufferLength > 0 && this._stream.bytesLoaded > 0)
         {
            _loc1_ = new ProgressEvent(ProgressEvent.PROGRESS,false,false,this._stream.bytesLoaded,this._stream.bufferLength < this._stream.bufferTime ? this._stream.bytesLoaded * this._stream.bufferTime / this._stream.bufferLength : this._stream.bytesLoaded);
         }
         else
         {
            _loc1_ = new ProgressEvent(ProgressEvent.PROGRESS,false,false,0,100);
         }
         return _loc1_;
      }
      
      private function getAverage(param1:Array) : Number
      {
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ += param1[_loc3_];
            _loc3_++;
         }
         return _loc2_ / param1.length;
      }
      
      private function dispose() : void
      {
         this.stop();
         this._connection.close();
         this._connection = null;
         if(this._stream)
         {
            this._stream.bufferTime = 180;
            this._stream.close();
            this._stream = null;
         }
         this._popupLoaded = false;
         this._netConnected = false;
         this._bandwidthTimer = null;
         this.reset();
      }
      
      private function reset() : void
      {
         this._isReady = false;
         this._isPaused = false;
         this._readyToStart = false;
      }
      
      private function start() : void
      {
         if(this._isReady)
         {
            this.removeSpiral();
            this._stream.bufferTime = 5;
            this.resume();
         }
         this._readyToStart = true;
      }
      
      private function stop() : void
      {
         this.pause();
      }
      
      private function pause() : void
      {
         this._isPaused = true;
         if(this._stream != null)
         {
            this._stream.pause();
         }
      }
      
      private function resume() : void
      {
         this._isPaused = false;
         if(this._stream != null)
         {
            this._stream.resume();
         }
      }
      
      private function seek(param1:Number) : void
      {
         if(this._stream != null)
         {
            this._stream.seek(param1);
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
            if(this._videoLayer.contains(this._loadingSpiral))
            {
               this._videoLayer.removeChild(this._loadingSpiral);
            }
         }
         else if(this.contains(this._loadingSpiral))
         {
            this.removeChild(this._loadingSpiral);
         }
      }
      
      private function addSpiral() : void
      {
         if(this._hasMediaId)
         {
            if(Boolean(this._loadingSpiral) && !this._videoLayer.contains(this._loadingSpiral))
            {
               this._videoLayer.addChild(this._loadingSpiral);
            }
         }
         else if(Boolean(this._loadingSpiral) && !this.contains(this._loadingSpiral))
         {
            this.addChild(this._loadingSpiral);
         }
      }
      
      private function mouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

