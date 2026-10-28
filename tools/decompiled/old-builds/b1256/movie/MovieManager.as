package movie
{
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.printing.PrintJob;
   import gui.DarkenManager;
   import gui.FeedbackManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MovieManager
   {
      
      public static const NORMAL_SKIN:int = 1;
      
      public static const BRADY_BARR_SKIN:int = 2;
      
      public static const TIERNEY_THYS_SKIN:int = 3;
      
      public static const BIGGER_FRAME:int = 5;
      
      public static const VID_PLAYER_MEDIA_ID:int = 39;
      
      public static const VID_SELECTOR_MEDIA_ID:int = 202;
      
      private const MOVIES_PER_SCREEN:int = 4;
      
      private var _popupLayer:DisplayLayer;
      
      private var _movieSelector:MovieClip;
      
      private var _movieSelectorPopup:MovieClip;
      
      private var _closeCallback:Function;
      
      private var _pageNumber:int;
      
      private var _mediaItems:Array;
      
      private var _previewImages:Array;
      
      private var _videoArray:Array;
      
      private var _videoPlayer:VideoPlayerOSMF;
      
      private var _spirals:Array;
      
      private var _movieMediaHelper:MediaHelper;
      
      private var _printMediaHelper:MediaHelper;
      
      private var _previewArray:Array;
      
      private var _baseTitles:Array;
      
      private var _indivTitles:Array;
      
      private var _videoPlayerId:int;
      
      private var _theaterScreen:Object;
      
      private var _isFromTheater:Boolean;
      
      private var _isAsking:Boolean;
      
      private var _titleTxt:String;
      
      private var _statusIds:Array;
      
      private var _subtitleIds:Array;
      
      private var _chooseRandom:Boolean;
      
      private var _printMediaHolder:Array;
      
      private var _numPrintItemsToLoad:int;
      
      private var _numPrintItemsLoaded:int;
      
      private var _loadedImages:Array;
      
      private var _randomPlayerSkinId:int;
      
      private var _shouldRepeat:Boolean;
      
      private var _defaultWidth:int = 512;
      
      private var _defaultHeight:int = 288;
      
      private var _skinFrameId:int = 1;
      
      private var _closeBtn:MovieClip;
      
      private var _leftArrow:MovieClip;
      
      private var _rightArrow:MovieClip;
      
      private var _mw0:MovieClip;
      
      private var _mw1:MovieClip;
      
      private var _mw2:MovieClip;
      
      private var _mw3:MovieClip;
      
      private var _playMovBtn0:MovieClip;
      
      private var _playMovBtn1:MovieClip;
      
      private var _playMovBtn2:MovieClip;
      
      private var _playMovBtn3:MovieClip;
      
      public function MovieManager()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Object, param3:Array, param4:Array, param5:Array, param6:Array, param7:Array, param8:Array, param9:int = 202, param10:int = 39, param11:Function = null) : void
      {
         _popupLayer = param1;
         if(param9 > 0)
         {
            _movieMediaHelper = new MediaHelper();
            _movieMediaHelper.init(param9,movieHelperCallback);
         }
         _closeCallback = param11;
         if(param2)
         {
            if(param2 is MovieClip)
            {
               _theaterScreen = param2;
            }
            else if(param2.hasOwnProperty("loader"))
            {
               _theaterScreen = param2.loader.content;
            }
         }
         _videoPlayer = new VideoPlayerOSMF();
         if(_theaterScreen)
         {
            MovieClip(_theaterScreen).addChild(_videoPlayer);
            _isFromTheater = true;
         }
         else
         {
            param1.addChild(_videoPlayer);
            _isFromTheater = false;
         }
         _pageNumber = 0;
         _videoPlayerId = param10;
         _spirals = [];
         _previewImages = [];
         _mediaItems = [];
         _videoArray = param4;
         _previewArray = param3;
         _baseTitles = param5;
         _indivTitles = param6;
         _statusIds = param7;
         _subtitleIds = param8;
      }
      
      public function get videoPlayer() : VideoPlayerOSMF
      {
         return _videoPlayer;
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         removeListeners();
         KeepAlive.stopKATimer(_movieSelectorPopup);
         _popupLayer.removeChild(_movieSelectorPopup);
         DarkenManager.unDarken(_movieSelectorPopup);
         _movieSelectorPopup = null;
         _movieSelector = null;
         _isFromTheater = false;
         _isAsking = false;
         _theaterScreen = null;
         _titleTxt = null;
         _movieMediaHelper.destroy();
         _movieMediaHelper = null;
         if(_printMediaHelper)
         {
            _printMediaHelper.destroy();
            _printMediaHelper = null;
         }
         if(_mediaItems)
         {
            _loc2_ = 0;
            while(_loc2_ < _mediaItems.length)
            {
               _mediaItems[0].destroy();
               _loc2_++;
            }
            _mediaItems.splice(0,_mediaItems.length);
            _mediaItems = null;
         }
         _loc1_ = 0;
         while(_loc1_ < _spirals.length)
         {
            _spirals[_loc1_].destroy();
            _loc1_++;
         }
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
         }
         _spirals = null;
         _previewImages = null;
         _mediaItems = null;
         _videoArray = null;
         _previewArray = null;
         _baseTitles = null;
         _indivTitles = null;
         _statusIds = null;
         _closeBtn = null;
         _leftArrow = null;
         _rightArrow = null;
         _mw0 = null;
         _mw1 = null;
         _mw2 = null;
         _mw3 = null;
         _playMovBtn0 = null;
         _playMovBtn1 = null;
         _playMovBtn2 = null;
         _playMovBtn3 = null;
         _closeCallback = null;
      }
      
      public function toggleVisibility() : void
      {
         if(_movieSelectorPopup)
         {
            if(_movieSelectorPopup.visible)
            {
               DarkenManager.unDarken(_movieSelectorPopup);
            }
            else
            {
               DarkenManager.darken(_movieSelectorPopup);
            }
            _movieSelectorPopup.visible = !_movieSelectorPopup.visible;
         }
      }
      
      public function setSkinFrame(param1:int) : void
      {
         _skinFrameId = param1;
         if(_movieSelector && _movieSelector.currentFrame != param1)
         {
            _movieSelector.gotoAndPlay(param1);
         }
      }
      
      public function togglePlayPauseVideoPlayer(param1:Boolean) : void
      {
         if(_videoPlayer)
         {
            _videoPlayer.togglePlayPause(param1);
         }
      }
      
      public function setQuestionBtn() : void
      {
         if(_movieSelector && _movieSelector.askTab)
         {
            if(_movieSelector.askTab.hasOwnProperty("askBradyBtn"))
            {
               _movieSelector.askTab.askBradyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
            }
            else
            {
               _movieSelector.askTab.askTierneyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
            }
         }
         else
         {
            _isAsking = true;
         }
      }
      
      public function setTitleTxt(param1:String) : void
      {
         if(_movieSelector)
         {
            LocalizationManager.translateId(_movieSelector.titleTxt,int(param1));
         }
         else
         {
            _titleTxt = param1;
         }
      }
      
      public function chooseRandom(param1:Boolean, param2:int = 1, param3:Boolean = false, param4:int = 530, param5:int = 298) : void
      {
         _chooseRandom = param1;
         _randomPlayerSkinId = param2;
         if(_movieSelector && _chooseRandom)
         {
            _videoPlayer.init(_videoArray,_subtitleIds,_indivTitles,_videoPlayerId,-1,param3,param4,param5,onVideoPlayerClose);
            _videoPlayer.setSkinFrame(param2);
            toggleVisibility();
         }
      }
      
      public function setShouldRepeat(param1:Boolean) : void
      {
         _shouldRepeat = param1;
      }
      
      public function setDefaultWidthHeight(param1:int, param2:int) : void
      {
         _defaultWidth = param1;
         _defaultHeight = param2;
      }
      
      private function movieHelperCallback(param1:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:MediaHelper = null;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _movieSelectorPopup = param1;
            KeepAlive.startKATimer(_movieSelectorPopup);
            _movieSelectorPopup.visible = false;
            _popupLayer.addChild(_movieSelectorPopup);
            _movieSelector = MovieClip(_movieSelectorPopup.getChildAt(0));
            if(_movieSelector.currentFrame != _skinFrameId)
            {
               _movieSelector.gotoAndPlay(_skinFrameId);
            }
            _loc4_ = 1;
            while(_loc4_ < Math.min(5,_previewArray.length + 1))
            {
               _spirals[_loc4_ - 1] = new LoadingSpiral(_movieSelector["mw" + _loc4_].itemLayer);
               _loc4_++;
            }
            _loc2_ = 0;
            while(_loc2_ < _previewArray.length)
            {
               _loc3_ = new MediaHelper();
               _loc3_.init(_previewArray[_loc2_],previewHelperCallback,true);
               _mediaItems[_loc2_] = _loc3_;
               _loc2_++;
            }
            _movieSelectorPopup.x = 900 * 0.5;
            _movieSelectorPopup.y = 550 * 0.5;
            _closeBtn = MovieClip(_movieSelectorPopup.getChildAt(0)["bx"]);
            _leftArrow = _movieSelector["arrowLBtn"];
            _rightArrow = _movieSelector["arrowRBtn"];
            _mw0 = _movieSelector["mw1"];
            _mw1 = _movieSelector["mw2"];
            _mw2 = _movieSelector["mw3"];
            _mw3 = _movieSelector["mw4"];
            _playMovBtn0 = _mw0["playMovBtn"];
            _playMovBtn1 = _mw1["playMovBtn"];
            _playMovBtn2 = _mw2["playMovBtn"];
            _playMovBtn3 = _mw3["playMovBtn"];
            _playMovBtn0.visible = false;
            _playMovBtn1.visible = false;
            _playMovBtn2.visible = false;
            _playMovBtn3.visible = false;
            _mw0.movieDescTxt.visible = false;
            _mw1.movieDescTxt.visible = false;
            _mw2.movieDescTxt.visible = false;
            _mw3.movieDescTxt.visible = false;
            _mw0.newTag.visible = false;
            _mw1.newTag.visible = false;
            _mw2.newTag.visible = false;
            _mw3.newTag.visible = false;
            if(_videoArray.length <= 4)
            {
               _leftArrow.activateGrayState(true);
               _rightArrow.activateGrayState(true);
            }
            if(!_isAsking)
            {
               if(_movieSelector.askTab)
               {
                  _movieSelector.askTab.visible = false;
               }
            }
            if(_titleTxt)
            {
               LocalizationManager.translateId(_movieSelector.titleTxt,int(_titleTxt));
            }
            addListeners();
            if(!_theaterScreen)
            {
               toggleVisibility();
            }
            if(_theaterScreen)
            {
               _videoPlayer.init(_videoArray,_subtitleIds,_indivTitles,-1,-1);
            }
            if(_chooseRandom)
            {
               _videoPlayer.init(_videoArray,_subtitleIds,_indivTitles,_videoPlayerId,-1,_shouldRepeat,512,288,onVideoPlayerClose);
               _videoPlayer.setSkinFrame(_randomPlayerSkinId);
               toggleVisibility();
            }
         }
      }
      
      private function onVideoPlayerClose() : void
      {
         onClose(null);
      }
      
      private function addListeners() : void
      {
         _closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         _playMovBtn0.addEventListener("mouseDown",onPlay,false,0,true);
         _playMovBtn1.addEventListener("mouseDown",onPlay,false,0,true);
         _playMovBtn2.addEventListener("mouseDown",onPlay,false,0,true);
         _playMovBtn3.addEventListener("mouseDown",onPlay,false,0,true);
         _leftArrow.addEventListener("mouseDown",onSideBtn,false,0,true);
         _rightArrow.addEventListener("mouseDown",onSideBtn,false,0,true);
         _movieSelectorPopup.addEventListener("mouseDown",onMoviePopup,false,0,true);
         if(_isAsking)
         {
            if(_movieSelector.askTab)
            {
               if(_movieSelector.askTab.hasOwnProperty("askBradyBtn"))
               {
                  _movieSelector.askTab.askBradyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
               }
               else
               {
                  _movieSelector.askTab.askTierneyBtn.addEventListener("mouseDown",onAskBtn,false,0,true);
               }
            }
         }
      }
      
      private function removeListeners() : void
      {
         _closeBtn.removeEventListener("mouseDown",onClose);
         _playMovBtn0.removeEventListener("mouseDown",onPlay);
         _playMovBtn1.removeEventListener("mouseDown",onPlay);
         _playMovBtn2.removeEventListener("mouseDown",onPlay);
         _playMovBtn3.removeEventListener("mouseDown",onPlay);
         _leftArrow.removeEventListener("mouseDown",onSideBtn);
         _rightArrow.removeEventListener("mouseDown",onSideBtn);
         _movieSelectorPopup.removeEventListener("mouseDown",onMoviePopup);
         if(_isAsking)
         {
            if(_movieSelector.askTab)
            {
               if(_movieSelector.askTab.hasOwnProperty("askBradyBtn"))
               {
                  _movieSelector.askTab.askBradyBtn.removeEventListener("mouseDown",onAskBtn);
               }
               else
               {
                  _movieSelector.askTab.askTierneyBtn.removeEventListener("mouseDown",onAskBtn);
               }
            }
         }
      }
      
      private function onMoviePopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_closeCallback != null)
         {
            if(!_chooseRandom)
            {
               _closeCallback();
            }
         }
         else
         {
            destroy();
         }
      }
      
      private function onAskBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         if(param1.currentTarget.name == "askBradyBtn")
         {
            FeedbackManager.openFeedbackPopup(1);
         }
         else
         {
            FeedbackManager.openFeedbackPopup(11);
         }
      }
      
      private function previewHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         _loc4_ = 0;
         while(_loc4_ < _mediaItems.length)
         {
            if(_mediaItems[_loc4_] == param1.mediaHelper)
            {
               _previewImages[_loc4_] = param1;
               if(_loc4_ < 4)
               {
                  _loc2_ = this["_mw" + _loc4_];
                  _spirals[_loc4_].destroy();
                  _loc2_.movieDescTxt.visible = true;
                  _loc2_.playMovBtn.visible = true;
                  _loc2_.itemLayer.addChild(param1);
                  LocalizationManager.translateId(_loc2_.movieDescTxt,_baseTitles[_loc4_]);
                  _loc2_.newTag.visible = _statusIds[_loc4_] == 1;
                  _loc3_ = param1.getChildAt(0);
                  _loc5_ = 0;
                  while(_loc5_ < _loc3_.numChildren)
                  {
                     if(_loc3_.getChildAt(_loc5_).name.indexOf("beakerBtn") >= 0)
                     {
                        _loc3_.getChildAt(_loc5_).addEventListener("mouseDown",onBeakerDown,false,0,true);
                     }
                     _loc5_++;
                  }
               }
               break;
            }
            _loc4_++;
         }
         if(_mediaItems.length < 4)
         {
            _loc5_ = int(_mediaItems.length);
            while(_loc5_ < 4)
            {
               this["_mw" + _loc5_].visible = false;
               _loc5_++;
            }
         }
      }
      
      private function reloadPreviews() : void
      {
         var _loc4_:int = 0;
         var _loc1_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         _loc4_ = 1;
         while(_loc4_ < 5)
         {
            while(_movieSelector["mw" + _loc4_].itemLayer.numChildren > 0)
            {
               _movieSelector["mw" + _loc4_].itemLayer.removeChildAt(0);
            }
            _loc4_++;
         }
         _loc3_ = _pageNumber;
         while(_loc3_ < _pageNumber + 4)
         {
            _loc1_ = this["_mw" + (_loc3_ - _pageNumber)];
            if(_loc3_ < _previewImages.length)
            {
               _loc1_.visible = true;
               _loc1_.itemLayer.addChild(_previewImages[_loc3_]);
               _loc1_.playMovBtn.visible = true;
               LocalizationManager.translateId(_loc1_.movieDescTxt,_baseTitles[_loc3_]);
               _loc1_.newTag.visible = _statusIds[_loc3_] == 1;
               _loc2_ = _previewImages[_loc3_].getChildAt(0);
               _loc4_ = 0;
               while(_loc4_ < _loc2_.numChildren)
               {
                  if(_loc2_.getChildAt(_loc4_).name.indexOf("beakerBtn") > 0)
                  {
                     _loc2_.getChildAt(_loc4_).addEventListener("mouseDown",onBeakerDown,false,0,true);
                  }
                  _loc4_++;
               }
            }
            else
            {
               _loc1_.visible = false;
            }
            _loc3_++;
         }
      }
      
      private function onPlay(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         switch(param1.currentTarget.parent.name)
         {
            case "mw1":
               break;
            case "mw2":
               _loc2_ = 1;
               break;
            case "mw3":
               _loc2_ = 2;
               break;
            case "mw4":
               _loc2_ = 3;
         }
         if(_videoArray.length > _loc2_ + _pageNumber)
         {
            if(_chooseRandom || _isFromTheater)
            {
               _videoPlayer.playVideoIdx(_pageNumber + _loc2_);
               onClose(param1);
            }
            else
            {
               _videoPlayer.init(_videoArray,_subtitleIds,_indivTitles,_videoPlayerId,_pageNumber + _loc2_,_shouldRepeat,_defaultWidth,_defaultHeight);
               _videoPlayer.setSkinFrame(_skinFrameId);
            }
         }
      }
      
      private function onSideBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         var _loc3_:* = param1.currentTarget.name;
         if("arrowLBtn" !== _loc3_)
         {
            if(_pageNumber + 4 < _videoArray.length)
            {
               _pageNumber += 4;
               reloadPreviews();
            }
            else
            {
               _pageNumber = 0;
               reloadPreviews();
            }
         }
         else if(_pageNumber - 4 >= 0)
         {
            _pageNumber -= 4;
            reloadPreviews();
         }
         else if(_videoArray.length > 4)
         {
            _loc2_ = _videoArray.length % 4;
            _pageNumber = _videoArray.length;
            var _temp_5:* = §§findproperty(_pageNumber);
            _pageNumber -= _loc2_ == 0 ? 4 : _loc2_;
            reloadPreviews();
         }
      }
      
      private function onBeakerDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(_popupLayer,LocalizationManager.translateIdOnly(14808),true,onConfirmPrint,param1.currentTarget.name.split("_"));
      }
      
      private function onConfirmPrint(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            _numPrintItemsToLoad = param1.passback.length - 1;
            _numPrintItemsLoaded = 0;
            _printMediaHolder = [];
            _loadedImages = [];
            _loc2_ = 1;
            while(_loc2_ < param1.passback.length)
            {
               _printMediaHelper = new MediaHelper();
               _printMediaHelper.init(param1.passback[_loc2_],onPrintMediaLoaded,_loc2_);
               _printMediaHolder.push(_printMediaHelper);
               _loc2_++;
            }
         }
      }
      
      private function onPrintMediaLoaded(param1:MovieClip) : void
      {
         var _loc3_:PrintJob = null;
         var _loc5_:int = 0;
         var _loc2_:Array = null;
         var _loc4_:Object = null;
         _loadedImages[param1.passback - 1] = param1;
         _numPrintItemsLoaded = _numPrintItemsLoaded + 1;
         if(_numPrintItemsLoaded == _numPrintItemsToLoad)
         {
            DarkenManager.showLoadingSpiral(false);
            _loc3_ = new PrintJob();
            if(_loc3_.start())
            {
               _loc2_ = [];
               _loc5_ = 0;
               while(_loc5_ < _loadedImages.length)
               {
                  _loc4_ = setupPrintSprite(_loadedImages[_loc5_],_loc3_);
                  _loc2_.push(_loc4_.spriteToPrint);
                  _printMediaHolder[_loc5_].destroy();
                  try
                  {
                     _loc3_.addPage(_loc4_.spriteToPrint,new Rectangle(0,0,_loc4_.realW + 2,_loc4_.realH + 2));
                  }
                  catch(e:Error)
                  {
                  }
                  _loc5_++;
               }
               _loc4_ = null;
            }
            _loadedImages = null;
            _printMediaHolder = null;
            _loc3_.send();
            if(_loc2_)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc2_.length)
               {
                  if(_loc2_[_loc5_].parent)
                  {
                     gMainFrame.stage.removeChild(_loc2_[_loc5_]);
                  }
                  _loc5_++;
               }
            }
            _loc2_ = null;
         }
      }
      
      private function setupPrintSprite(param1:MovieClip, param2:PrintJob) : Object
      {
         var _loc5_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc3_:Sprite = new Sprite();
         param1.scaleX = param1.scaleY = 4;
         _loc3_.addChild(param1);
         param1.x = param1.y = 1;
         var _loc6_:Number = _loc3_.width;
         var _loc10_:Number = _loc3_.height;
         var _loc9_:BitmapData = new BitmapData(_loc3_.width,_loc3_.height,false,4294967295);
         _loc9_.draw(_loc3_);
         var _loc8_:Bitmap = new Bitmap(_loc9_);
         var _loc4_:Sprite = new Sprite();
         _loc4_.addChild(_loc8_);
         _loc8_.x = 0;
         _loc8_.y = 0;
         _loc8_.scaleX = 0.999;
         _loc8_.scaleY = 0.999;
         _loc4_.x = 0;
         _loc4_.y = 0;
         gMainFrame.stage.addChild(_loc4_);
         _loc4_.visible = false;
         if(param2.orientation != "portrait")
         {
            _loc4_.rotation = 90;
            _loc4_.x = _loc4_.width;
            _loc7_ = param2.pageWidth / _loc10_;
            _loc5_ = param2.pageHeight / _loc6_;
         }
         else
         {
            _loc7_ = param2.pageWidth / _loc6_;
            _loc5_ = param2.pageHeight / _loc10_;
         }
         _loc4_.scaleX = _loc4_.scaleY = Math.min(_loc7_,_loc5_);
         return {
            "spriteToPrint":_loc4_,
            "realW":_loc6_,
            "realH":_loc10_
         };
      }
   }
}

