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
   import flash.printing.PrintJobOrientation;
   import gui.DarkenManager;
   import gui.FeedbackManager;
   import gui.LoadingSpiral;
   import loader.MediaHelper;
   
   public class MovieManager
   {
      
      public static const NORMAL_SKIN:int = 1;
      
      public static const BRADY_BARR_SKIN:int = 2;
      
      public static const TIERNEY_THYS_SKIN:int = 3;
      
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
      
      private var _videoPlayer:VideoPlayer;
      
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
      
      private var _chooseRandom:Boolean;
      
      private var _printMediaHolder:Array;
      
      private var _numPrintItemsToLoad:int;
      
      private var _numPrintItemsLoaded:int;
      
      private var _loadedImages:Array;
      
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
      
      public function init(param1:DisplayLayer, param2:Object, param3:Array, param4:Array, param5:Array, param6:Array, param7:Array, param8:int = 202, param9:int = 39, param10:Function = null) : void
      {
         this._popupLayer = param1;
         if(param8 > 0)
         {
            this._movieMediaHelper = new MediaHelper();
            this._movieMediaHelper.init(param8,this.movieHelperCallback);
         }
         this._closeCallback = param10;
         if(param2)
         {
            if(param2 is MovieClip)
            {
               this._theaterScreen = param2;
            }
            else if(param2.hasOwnProperty("loader"))
            {
               this._theaterScreen = param2.loader.content;
            }
         }
         this._videoPlayer = new VideoPlayer();
         if(this._theaterScreen)
         {
            MovieClip(this._theaterScreen).addChild(this._videoPlayer);
            this._isFromTheater = true;
         }
         else
         {
            param1.addChild(this._videoPlayer);
            this._isFromTheater = false;
         }
         this._pageNumber = 0;
         this._videoPlayerId = param9;
         this._spirals = new Array();
         this._previewImages = new Array();
         this._mediaItems = new Array();
         this._videoArray = param4;
         this._previewArray = param3;
         this._baseTitles = param5;
         this._indivTitles = param6;
         this._statusIds = param7;
      }
      
      public function get videoPlayer() : VideoPlayer
      {
         return this._videoPlayer;
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         this.removeListeners();
         KeepAlive.stopKATimer(this._movieSelectorPopup);
         this._popupLayer.removeChild(this._movieSelectorPopup);
         DarkenManager.unDarken(this._movieSelectorPopup);
         this._movieSelectorPopup = null;
         this._movieSelector = null;
         this._isFromTheater = false;
         this._isAsking = false;
         this._theaterScreen = null;
         this._titleTxt = null;
         this._movieMediaHelper.destroy();
         this._movieMediaHelper = null;
         if(this._printMediaHelper)
         {
            this._printMediaHelper.destroy();
            this._printMediaHelper = null;
         }
         if(this._mediaItems)
         {
            _loc2_ = 0;
            while(_loc2_ < this._mediaItems.length)
            {
               this._mediaItems[0].destroy();
               _loc2_++;
            }
            this._mediaItems.splice(0,this._mediaItems.length);
            this._mediaItems = null;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._spirals.length)
         {
            this._spirals[_loc1_].destroy();
            _loc1_++;
         }
         if(this._videoPlayer)
         {
            this._videoPlayer.destroy();
         }
         this._spirals = null;
         this._previewImages = null;
         this._mediaItems = null;
         this._videoArray = null;
         this._previewArray = null;
         this._baseTitles = null;
         this._indivTitles = null;
         this._statusIds = null;
         this._closeBtn = null;
         this._leftArrow = null;
         this._rightArrow = null;
         this._mw0 = null;
         this._mw1 = null;
         this._mw2 = null;
         this._mw3 = null;
         this._playMovBtn0 = null;
         this._playMovBtn1 = null;
         this._playMovBtn2 = null;
         this._playMovBtn3 = null;
         this._closeCallback = null;
      }
      
      public function toggleVisibility() : void
      {
         if(this._movieSelectorPopup)
         {
            if(this._movieSelectorPopup.visible)
            {
               DarkenManager.unDarken(this._movieSelectorPopup);
            }
            else
            {
               DarkenManager.darken(this._movieSelectorPopup);
            }
            this._movieSelectorPopup.visible = !this._movieSelectorPopup.visible;
         }
      }
      
      public function setSkinFrame(param1:int) : void
      {
         this._skinFrameId = param1;
         if(Boolean(this._movieSelector) && this._movieSelector.currentFrame != param1)
         {
            this._movieSelector.gotoAndPlay(param1);
         }
      }
      
      public function setQuestionBtn() : void
      {
         if(Boolean(this._movieSelector) && Boolean(this._movieSelector.askTab))
         {
            if(this._movieSelector.askTab.hasOwnProperty("askBradyBtn"))
            {
               this._movieSelector.askTab.askBradyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
            }
            else
            {
               this._movieSelector.askTab.askTierneyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
            }
         }
         else
         {
            this._isAsking = true;
         }
      }
      
      public function setTitleTxt(param1:String) : void
      {
         if(this._movieSelector)
         {
            this._movieSelector.titleTxt.text = param1;
         }
         else
         {
            this._titleTxt = param1;
         }
      }
      
      public function chooseRandom(param1:Boolean) : void
      {
         this._chooseRandom = param1;
         if(Boolean(this._movieSelector) && this._chooseRandom)
         {
            this._videoPlayer.init(this._videoArray,this._indivTitles,this._videoPlayerId,-1,true,530,298,this.onVideoPlayerClose);
            this.toggleVisibility();
         }
      }
      
      private function movieHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:MediaHelper = null;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            this._movieSelectorPopup = param1;
            KeepAlive.startKATimer(this._movieSelectorPopup);
            this._movieSelectorPopup.visible = false;
            this._popupLayer.addChild(this._movieSelectorPopup);
            this._movieSelector = MovieClip(this._movieSelectorPopup.getChildAt(0));
            if(this._movieSelector.currentFrame != this._skinFrameId)
            {
               this._movieSelector.gotoAndPlay(this._skinFrameId);
            }
            _loc2_ = 1;
            while(_loc2_ < Math.min(5,this._previewArray.length + 1))
            {
               this._spirals[_loc2_ - 1] = new LoadingSpiral(this._movieSelector["mw" + _loc2_].itemLayer);
               _loc2_++;
            }
            _loc3_ = 0;
            while(_loc3_ < this._previewArray.length)
            {
               _loc4_ = new MediaHelper();
               _loc4_.init(this._previewArray[_loc3_],this.previewHelperCallback,true);
               this._mediaItems[_loc3_] = _loc4_;
               _loc3_++;
            }
            this._movieSelectorPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._movieSelectorPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._closeBtn = MovieClip(this._movieSelectorPopup.getChildAt(0)["bx"]);
            this._leftArrow = this._movieSelector["arrowLBtn"];
            this._rightArrow = this._movieSelector["arrowRBtn"];
            this._mw0 = this._movieSelector["mw1"];
            this._mw1 = this._movieSelector["mw2"];
            this._mw2 = this._movieSelector["mw3"];
            this._mw3 = this._movieSelector["mw4"];
            this._playMovBtn0 = this._mw0["playMovBtn"];
            this._playMovBtn1 = this._mw1["playMovBtn"];
            this._playMovBtn2 = this._mw2["playMovBtn"];
            this._playMovBtn3 = this._mw3["playMovBtn"];
            this._playMovBtn0.visible = false;
            this._playMovBtn1.visible = false;
            this._playMovBtn2.visible = false;
            this._playMovBtn3.visible = false;
            this._mw0.movieDescTxt.visible = false;
            this._mw1.movieDescTxt.visible = false;
            this._mw2.movieDescTxt.visible = false;
            this._mw3.movieDescTxt.visible = false;
            this._mw0.newTag.visible = false;
            this._mw1.newTag.visible = false;
            this._mw2.newTag.visible = false;
            this._mw3.newTag.visible = false;
            if(this._videoArray.length <= 4)
            {
               this._leftArrow.activateGrayState(true);
               this._rightArrow.activateGrayState(true);
            }
            if(!this._isAsking)
            {
               if(this._movieSelector.askTab)
               {
                  this._movieSelector.askTab.visible = false;
               }
            }
            if(this._titleTxt)
            {
               this._movieSelector.titleTxt.text = this._titleTxt;
            }
            this.addListeners();
            if(!this._theaterScreen)
            {
               this.toggleVisibility();
            }
            if(this._theaterScreen)
            {
               this._videoPlayer.init(this._videoArray,this._indivTitles,-1,-1);
            }
            if(this._chooseRandom)
            {
               this._videoPlayer.init(this._videoArray,this._indivTitles,this._videoPlayerId,-1,true,530,298,this.onVideoPlayerClose);
               this.toggleVisibility();
            }
         }
      }
      
      private function onVideoPlayerClose() : void
      {
         this.onClose(null);
      }
      
      private function addListeners() : void
      {
         this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._playMovBtn0.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._playMovBtn1.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._playMovBtn2.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._playMovBtn3.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay,false,0,true);
         this._leftArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn,false,0,true);
         this._rightArrow.addEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn,false,0,true);
         this._movieSelectorPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onMoviePopup,false,0,true);
         if(this._isAsking)
         {
            if(this._movieSelector.askTab)
            {
               if(this._movieSelector.askTab.hasOwnProperty("askBradyBtn"))
               {
                  this._movieSelector.askTab.askBradyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
               }
               else
               {
                  this._movieSelector.askTab.askTierneyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn,false,0,true);
               }
            }
         }
      }
      
      private function removeListeners() : void
      {
         this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._playMovBtn0.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._playMovBtn1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._playMovBtn2.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._playMovBtn3.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
         this._leftArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn);
         this._rightArrow.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSideBtn);
         this._movieSelectorPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMoviePopup);
         if(this._isAsking)
         {
            if(this._movieSelector.askTab)
            {
               if(this._movieSelector.askTab.hasOwnProperty("askBradyBtn"))
               {
                  this._movieSelector.askTab.askBradyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn);
               }
               else
               {
                  this._movieSelector.askTab.askTierneyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAskBtn);
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
         if(this._closeCallback != null)
         {
            if(!this._chooseRandom)
            {
               this._closeCallback();
            }
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onAskBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         if(param1.currentTarget.name == "askBradyBtn")
         {
            FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_ASK_BRADY);
         }
         else
         {
            FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_ASK_TIERNEY);
         }
      }
      
      private function previewHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         while(_loc4_ < this._mediaItems.length)
         {
            if(this._mediaItems[_loc4_] == param1.mediaHelper)
            {
               this._previewImages[_loc4_] = param1;
               if(_loc4_ < 4)
               {
                  _loc2_ = this["_mw" + _loc4_];
                  this._spirals[_loc4_].destroy();
                  _loc2_.movieDescTxt.visible = true;
                  _loc2_.playMovBtn.visible = true;
                  _loc2_.itemLayer.addChild(param1);
                  _loc2_.movieDescTxt.text = this._baseTitles[_loc4_];
                  _loc2_.movieDescTxt.text = this._baseTitles[_loc4_];
                  _loc2_.newTag.visible = this._statusIds[_loc4_] == 1;
                  _loc5_ = param1.getChildAt(0);
                  _loc3_ = 0;
                  while(_loc3_ < _loc5_.numChildren)
                  {
                     if(_loc5_.getChildAt(_loc3_).name.indexOf("beakerBtn") >= 0)
                     {
                        _loc5_.getChildAt(_loc3_).addEventListener(MouseEvent.MOUSE_DOWN,this.onBeakerDown,false,0,true);
                     }
                     _loc3_++;
                  }
               }
               break;
            }
            _loc4_++;
         }
         if(this._mediaItems.length < 4)
         {
            _loc3_ = int(this._mediaItems.length);
            while(_loc3_ < 4)
            {
               this["_mw" + _loc3_].visible = false;
               _loc3_++;
            }
         }
      }
      
      private function reloadPreviews() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc4_:Object = null;
         _loc1_ = 1;
         while(_loc1_ < 5)
         {
            while(this._movieSelector["mw" + _loc1_].itemLayer.numChildren > 0)
            {
               this._movieSelector["mw" + _loc1_].itemLayer.removeChildAt(0);
            }
            _loc1_++;
         }
         var _loc3_:int = this._pageNumber;
         while(_loc3_ < this._pageNumber + 4)
         {
            _loc2_ = this["_mw" + (_loc3_ - this._pageNumber)];
            if(_loc3_ < this._previewImages.length)
            {
               _loc2_.visible = true;
               _loc2_.itemLayer.addChild(this._previewImages[_loc3_]);
               _loc2_.playMovBtn.visible = true;
               _loc2_.movieDescTxt.text = this._baseTitles[_loc3_];
               _loc2_.newTag.visible = this._statusIds[_loc3_] == 1;
               _loc4_ = this._previewImages[_loc3_].getChildAt(0);
               _loc1_ = 0;
               while(_loc1_ < _loc4_.numChildren)
               {
                  if(_loc4_.getChildAt(_loc1_).name.indexOf("beakerBtn") > 0)
                  {
                     _loc4_.getChildAt(_loc1_).addEventListener(MouseEvent.MOUSE_DOWN,this.onBeakerDown,false,0,true);
                  }
                  _loc1_++;
               }
            }
            else
            {
               _loc2_.visible = false;
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
         if(this._videoArray.length > _loc2_ + this._pageNumber)
         {
            if(this._chooseRandom || this._isFromTheater)
            {
               this._videoPlayer.playVideoIdx(this._pageNumber + _loc2_);
               this.onClose(param1);
            }
            else
            {
               this._videoPlayer.init(this._videoArray,this._indivTitles,this._videoPlayerId,this._pageNumber + _loc2_);
               this._videoPlayer.setSkinFrame(this._skinFrameId);
            }
         }
      }
      
      private function onSideBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         switch(param1.currentTarget.name)
         {
            case "arrowLBtn":
               if(this._pageNumber - 4 >= 0)
               {
                  this._pageNumber -= 4;
                  this.reloadPreviews();
               }
               else if(this._videoArray.length > 4)
               {
                  _loc2_ = this._videoArray.length % 4;
                  this._pageNumber = this._videoArray.length;
                  this._pageNumber -= _loc2_ == 0 ? 4 : _loc2_;
                  this.reloadPreviews();
               }
               break;
            default:
               if(this._pageNumber + 4 < this._videoArray.length)
               {
                  this._pageNumber += 4;
                  this.reloadPreviews();
               }
               else
               {
                  this._pageNumber = 0;
                  this.reloadPreviews();
               }
         }
      }
      
      private function onBeakerDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(this._popupLayer,"Do you want to print this experiment and try it yourself?",true,this.onConfirmPrint,param1.currentTarget.name.split("_"));
      }
      
      private function onConfirmPrint(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            this._numPrintItemsToLoad = param1.passback.length - 1;
            this._numPrintItemsLoaded = 0;
            this._printMediaHolder = [];
            this._loadedImages = [];
            _loc2_ = 1;
            while(_loc2_ < param1.passback.length)
            {
               this._printMediaHelper = new MediaHelper();
               this._printMediaHelper.init(param1.passback[_loc2_],this.onPrintMediaLoaded,_loc2_);
               this._printMediaHolder.push(this._printMediaHelper);
               _loc2_++;
            }
         }
      }
      
      private function onPrintMediaLoaded(param1:MovieClip) : void
      {
         var _loc2_:PrintJob = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:Object = null;
         this._loadedImages[param1.passback - 1] = param1;
         ++this._numPrintItemsLoaded;
         if(this._numPrintItemsLoaded == this._numPrintItemsToLoad)
         {
            DarkenManager.showLoadingSpiral(false);
            _loc2_ = new PrintJob();
            if(_loc2_.start())
            {
               _loc4_ = [];
               _loc3_ = 0;
               while(_loc3_ < this._loadedImages.length)
               {
                  _loc5_ = this.setupPrintSprite(this._loadedImages[_loc3_],_loc2_);
                  _loc4_.push(_loc5_.spriteToPrint);
                  this._printMediaHolder[_loc3_].destroy();
                  try
                  {
                     _loc2_.addPage(_loc5_.spriteToPrint,new Rectangle(0,0,_loc5_.realW + 2,_loc5_.realH + 2));
                  }
                  catch(e:Error)
                  {
                  }
                  _loc3_++;
               }
               _loc5_ = null;
            }
            this._loadedImages = null;
            this._printMediaHolder = null;
            _loc2_.send();
            if(_loc4_)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc4_.length)
               {
                  if(_loc4_[_loc3_].parent)
                  {
                     gMainFrame.stage.removeChild(_loc4_[_loc3_]);
                  }
                  _loc3_++;
               }
            }
            _loc4_ = null;
         }
      }
      
      private function setupPrintSprite(param1:MovieClip, param2:PrintJob) : Object
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc3_:Sprite = new Sprite();
         param1.scaleX = param1.scaleY = 4;
         _loc3_.addChild(param1);
         param1.x = param1.y = 1;
         var _loc4_:Number = _loc3_.width;
         var _loc5_:Number = _loc3_.height;
         var _loc6_:BitmapData = new BitmapData(_loc3_.width,_loc3_.height,false,4294967295);
         _loc6_.draw(_loc3_);
         var _loc7_:Bitmap = new Bitmap(_loc6_);
         var _loc8_:Sprite = new Sprite();
         _loc8_.addChild(_loc7_);
         _loc7_.x = 0;
         _loc7_.y = 0;
         _loc7_.scaleX = 0.999;
         _loc7_.scaleY = 0.999;
         _loc8_.x = 0;
         _loc8_.y = 0;
         gMainFrame.stage.addChild(_loc8_);
         _loc8_.visible = false;
         if(param2.orientation != PrintJobOrientation.PORTRAIT)
         {
            _loc8_.rotation = 90;
            _loc8_.x = _loc8_.width;
            _loc9_ = param2.pageWidth / _loc5_;
            _loc10_ = param2.pageHeight / _loc4_;
         }
         else
         {
            _loc9_ = param2.pageWidth / _loc4_;
            _loc10_ = param2.pageHeight / _loc5_;
         }
         _loc8_.scaleX = _loc8_.scaleY = Math.min(_loc9_,_loc10_);
         return {
            "spriteToPrint":_loc8_,
            "realW":_loc4_,
            "realH":_loc5_
         };
      }
   }
}

