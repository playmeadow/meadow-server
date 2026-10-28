package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.ApplicationDomain;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Quadratic;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class PageFlip extends Sprite
   {
      
      public static var pageFlipOpen:Boolean;
      
      private static const SINGLE_PAGE_PAGES_ID:int = 500;
      
      private static const SINGLE_PAGE_LAST_PAGE_ID:int = 500;
      
      private static const EBOOK_PAGES_ID:int = 567;
      
      private static const EBOOK_PAGES_ID_TALL:int = 879;
      
      private static const EBOOK_MEDIA_ID:int = 566;
      
      private static const RECTANGULAR_EBOOK_MEDIA_ID:int = 878;
      
      private static const JOURNEYBOOK_PAGES_ID:int = 1184;
      
      private static const JOURNEYBOOK_MEDIA_ID:int = 1183;
      
      private static const INFO_POPUP_MEDIA_ID:int = 1201;
      
      private static const LEFT_TOP_BTN_ID:int = 176;
      
      private static const RIGHT_TOP_BTN_ID:int = 177;
      
      private static const LEFT_BOTTOM_BTN_ID:int = 180;
      
      private static const RIGHT_BOTTOM_BTN_ID:int = 181;
      
      private static const ZOOM_BTN_ID:int = 568;
      
      private static const JOURNEYBOOK_SOUNDS_ID:int = 1332;
      
      private static const JB_KEEP_GIFT:int = 31;
      
      private static const JB_DISCARD_GIFT:int = 30;
      
      private static const JB_PAGE_SEEN:int = 29;
      
      private static const JB_BAHARI_BAY_UV:int = 289;
      
      private static const JB_CRYSTAL_REEF_UV:int = 290;
      
      private static const JB_DEEP_BLUE_UV:int = 291;
      
      private static const JB_KANI_COVE_UV:int = 288;
      
      private static const JB_LTOZ_UV:int = 295;
      
      private static const JB_SHIVEER_UV:int = 298;
      
      private static const JB_SAREPIA_UV:int = 311;
      
      private static const JB_APPONDALE_UV:int = 320;
      
      private static const JB_CORALCANYONS_UV:int = 333;
      
      private static const JB_CRYSTAL_SANDS_UV:int = 337;
      
      private static const JB_BIRDS_PARADISE_UV:int = 365;
      
      private static const JB_OUTBACK_UV:int = 371;
      
      private static const JB_BAHARI_BAY_NAME:String = "bahari_bay";
      
      private static const JB_CRYSTAL_REEF_NAME:String = "crystal_reef";
      
      private static const JB_DEEP_BLUE_NAME:String = "deep_blue";
      
      private static const JB_KANI_COVE_NAME:String = "kani_cove";
      
      private static const JB_LTOZ_NAME:String = "lost_temple_of_zios";
      
      private static const JB_SHIVEER_NAME:String = "Mt_Shiveer";
      
      private static const JB_SAREPIA_NAME:String = "Sarepia_Forest";
      
      private static const JB_APPONDALE_NAME:String = "Appondale";
      
      private static const JB_CORALCANYONS_NAME:String = "coral_canyons";
      
      private static const JB_CRYSTAL_SANDS_NAME:String = "crystal_sands";
      
      private static const JB_BIRDS_PARADISE_NAME:String = "birds_of_paradise";
      
      private static const JB_OUTBACK_NAME:String = "kimbara_outback";
      
      private var _popupLayer:DisplayLayer;
      
      private var _pageWidth:Number;
      
      private var _pageHeight:Number;
      
      private var _pageColor:int;
      
      private var _numberOfPages:Number;
      
      private var _autoStepSpeed:Number;
      
      private var _snapDistance:Number;
      
      private var _dragSmoothness:Number;
      
      private var _cornerBtnPositions:int;
      
      private var _showCornerBtns:Boolean;
      
      private var _playFlipSound:Boolean;
      
      private var _pageWidthAndHeight:Number;
      
      private var _pivotY:Number;
      
      private var _flipDirection:Number;
      
      private var _vertDir:Number;
      
      private var _pageNumber:Number;
      
      private var _currentPage:Number;
      
      private var _autoFlipTargetPage:Number;
      
      private var _ShouldBeDragging:Boolean;
      
      private var _pageFlipPercent:Number;
      
      private var _flipSound:Sound;
      
      private var _soundChannel:SoundChannel;
      
      private var _pageRatio:Number;
      
      private var _startX:Number;
      
      private var _pageOffset:Number;
      
      private var _step:Number;
      
      private var _bFlipAuto:Boolean;
      
      private var _fullPageBounds:Rectangle;
      
      private var _rightPageBounds:Rectangle;
      
      private var _leftPageBounds:Rectangle;
      
      private var _directionAfterFlip:Number;
      
      private var _pageDrag:Boolean;
      
      private var _isSinglePF:Boolean;
      
      private var _enableDragging:Boolean;
      
      private var _currPageLoaded:Boolean;
      
      private var _currPageVarsLoaded:Boolean;
      
      private var _pageFlipComplete:Boolean;
      
      private var _zoomedIn:Boolean;
      
      private var _setPagesOnly:Boolean;
      
      private var _isRectangular:Boolean;
      
      private var _showInfoPopup:Boolean;
      
      private var _flipInProgress:int;
      
      private var _pageFlipBase:MovieClip;
      
      private var _stationaryRightPage:MovieClip;
      
      private var _flippingBottomPageMask:Sprite;
      
      private var _flippingTopPageMask:Sprite;
      
      private var _flippingPageShadowMask:MovieClip;
      
      private var _shadowStationaryMask:MovieClip;
      
      private var _flippingBottomPage:MovieClip;
      
      private var _flippingTopPage:MovieClip;
      
      private var _stationaryLeftPage:MovieClip;
      
      private var _blankPage1:MovieClip;
      
      private var _blankPage2:MovieClip;
      
      private var _blankPage3:MovieClip;
      
      private var _blankPage4:MovieClip;
      
      private var _blankPageLast:MovieClip;
      
      private var _eBook:MovieClip;
      
      private var _journeyBook:MovieClip;
      
      private var _isJourneyBook:Boolean;
      
      private var _flippingShadow:Sprite;
      
      private var _shadowsShadow:Sprite;
      
      private var _rightBottomBtn:MovieClip;
      
      private var _leftTopBtn:MovieClip;
      
      private var _leftBottomBtn:MovieClip;
      
      private var _xBtn:MovieClip;
      
      private var _zoomBtn:MovieClip;
      
      private var _print:Sprite;
      
      private var _loadedPages:Array;
      
      private var _spiralLeftPage:LoadingSpiral;
      
      private var _spiralRightPage:LoadingSpiral;
      
      private var _spiralTopFlippingPage:LoadingSpiral;
      
      private var _spiralBottomFlippingPage:LoadingSpiral;
      
      private var _pageStart:int;
      
      private var _mediaViews:Array;
      
      private var _buttonsView:Array;
      
      private var _pagesArray:Array;
      
      private var _pageHolderViews:Array;
      
      private var _topPageTween:GTween;
      
      private var _bottomPageTween:GTween;
      
      private var _pageNumberTxt:int;
      
      private var _pageFlipIncrement:int;
      
      private var _buttonsLoaded:int;
      
      private var _pagesLoaded:int;
      
      private var _pageTurnedTo:int;
      
      private var _numberOfLoadedPages:int;
      
      private var _numberOfFlips:int;
      
      private var _closeCallback:Function;
      
      private var _flipCallback:Function;
      
      private var _pageNameArray:Array;
      
      private var _pageNumToOpen:int;
      
      private var _loadedPageNumber:Array;
      
      private var _jbGiftPopup:GiftPopup;
      
      private var _genericPopup:MovieClip;
      
      private var _infoPopup:MovieClip;
      
      private var _infoPopupMediaHelper:MediaHelper;
      
      private var _gameLaunchObj:Object;
      
      public function PageFlip()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:Array = null, param3:Boolean = false, param4:Function = null, param5:Function = null, param6:Boolean = false, param7:Boolean = false, param8:Boolean = false, param9:int = 1, param10:Boolean = false) : void
      {
         var _loc11_:MediaHelper = null;
         DarkenManager.showLoadingSpiral(true);
         this._pageColor = 16777215;
         this._numberOfPages = 0;
         this._autoStepSpeed = 0.1;
         this._snapDistance = 0.002;
         this._dragSmoothness = 0.5;
         this._cornerBtnPositions = 20;
         this._showCornerBtns = true;
         this._playFlipSound = true;
         pageFlipOpen = true;
         this._isSinglePF = param3;
         this._enableDragging = param7;
         this._closeCallback = param4;
         this._flipCallback = param5;
         this._isJourneyBook = param8;
         this._pageNameArray = [];
         this._loadedPageNumber = [];
         this._pageNumToOpen = param9;
         this._popupLayer = param1;
         this._isRectangular = param6;
         this._pageHolderViews = new Array();
         this._showInfoPopup = param10;
         this._pagesArray = param2;
         if(this._isJourneyBook && !AJAudio.hasLoadedJourneyBookBookSfx)
         {
            _loc11_ = new MediaHelper();
            _loc11_.init(JOURNEYBOOK_SOUNDS_ID,this.onLoadJBSounds);
            this._pageHolderViews.push(_loc11_);
         }
         else
         {
            this.loadHolderMovieClips();
         }
      }
      
      private function openPageFlip() : void
      {
         var _loc1_:int = 0;
         this._pageWidth = this._blankPage1.width;
         this._pageHeight = this._blankPage1.height;
         this._pageWidthAndHeight = this._pageWidth + this._pageHeight;
         this._flipDirection = 1;
         this._vertDir = -1;
         this._pivotY = this._pageHeight * 0.5 + this._pageWidth;
         this._pageNumber = 2.5;
         this._currentPage = 0.5;
         this._pageStart = this._pageNumToOpen;
         this._numberOfFlips = 1;
         this._pageTurnedTo = 1;
         this._buttonsLoaded = 0;
         this._pageFlipIncrement = 1;
         if(this._isSinglePF)
         {
            this._numberOfPages += this._currentPage + 0.5 + (this._pagesArray.length * 2 - 2);
            if(this._isJourneyBook && JBManager.numUnseenPages == this._pagesArray.length || this._showInfoPopup)
            {
               this._infoPopupMediaHelper = new MediaHelper();
               this._infoPopupMediaHelper.init(INFO_POPUP_MEDIA_ID,this.infoPopupCallback);
            }
            _loc1_ = 1;
            while(_loc1_ < this._pageNumToOpen)
            {
               this._pageNumber = this.fixPageNum(this._currentPage + 2);
               this._currentPage = this._pageNumber;
               _loc1_++;
            }
            this._pageTurnedTo = this._pageNumToOpen;
            this._numberOfFlips = this._pageNumToOpen;
         }
         else
         {
            this._pageNumber = 4.5;
            this._currentPage = 2.5;
            this._pageFlipIncrement = 2;
            this._pageStart = 2;
            this._numberOfFlips = 2;
            if(this._pagesArray.length % 2 != 0)
            {
               throw new Error("Number of pages must be a multiple of 2");
            }
            this._numberOfPages = this._pagesArray.length + (this._pagesArray.length * 0.5 % 2 == 0 ? 1 : 0.5);
         }
         this._ShouldBeDragging = false;
         this._pageFlipPercent = 0;
         this._numberOfLoadedPages = 0;
         this._spiralLeftPage = new LoadingSpiral();
         this._spiralRightPage = new LoadingSpiral();
         this._spiralTopFlippingPage = new LoadingSpiral();
         this._spiralBottomFlippingPage = new LoadingSpiral();
         this._loadedPages = new Array();
         this._mediaViews = new Array();
         this._buttonsView = new Array();
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
         this.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false,0,true);
         this.loadPages(this._pageStart);
         this.loadButtons();
         DarkenManager.showLoadingSpiral(false);
         if(this._eBook)
         {
            this.x = 0;
            this.y = 0;
            this._popupLayer.addChild(this._eBook);
            this._eBook.x = MainFrame.VIEW_WIDTH * 0.5;
            this._eBook.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._eBook.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
            this._eBook.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false,0,true);
            this._eBook.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
            if(this._xBtn)
            {
               this._xBtn.visible = false;
            }
            this._eBook.itemWindow.addChild(this);
            DarkenManager.darken(this._eBook);
         }
         else if(this._journeyBook)
         {
            this.x = 0;
            this.y = 0;
            this._popupLayer.addChild(this._journeyBook);
            this._journeyBook.x = 0;
            this._journeyBook.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._journeyBook.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
            this._journeyBook.itemWindow.addChild(this);
            DarkenManager.darken(this._journeyBook);
         }
         else
         {
            this.x = MainFrame.VIEW_WIDTH * 0.5;
            this.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._popupLayer.addChild(this);
            DarkenManager.darken(this);
         }
         this._pageFlipBase = new MovieClip();
         this.addChild(this._pageFlipBase);
         this._pageFlipBase.y = -(this._pageWidth + this._pageHeight * 0.5);
         if(this._isSinglePF && !this._isJourneyBook)
         {
            this._pageFlipBase.x = -this._pageWidth * 0.5;
         }
         if(this._eBook)
         {
            if(this._isRectangular)
            {
               this._fullPageBounds = new Rectangle(MainFrame.VIEW_WIDTH - 30,this._eBook.height + 110,-MainFrame.VIEW_WIDTH + 60,-this._eBook.height - 210);
            }
            else
            {
               this._fullPageBounds = new Rectangle(MainFrame.VIEW_WIDTH + 160,this._eBook.height,-MainFrame.VIEW_WIDTH - 325,-this._eBook.height - 5);
            }
         }
         else
         {
            this._fullPageBounds = new Rectangle(this._pageWidth * 2,this._pageHeight,MainFrame.VIEW_WIDTH - this._pageWidth * 4,MainFrame.VIEW_HEIGHT - this._pageHeight * 2);
         }
         this._rightPageBounds = new Rectangle(0,this._pageHeight,0,MainFrame.VIEW_HEIGHT - this._pageHeight * 2);
         this._leftPageBounds = new Rectangle(this._pageWidth * 2,this._pageHeight,0,MainFrame.VIEW_HEIGHT - this._pageHeight * 2);
         this.initPage(this._pageNumber,this._flipDirection,this._vertDir);
         if(this._flipCallback != null)
         {
            if(!this._isJourneyBook)
            {
               this._flipCallback(this._pageTurnedTo);
            }
         }
      }
      
      public function destroy() : void
      {
         if(this._eBook)
         {
            DarkenManager.unDarken(this._eBook);
            this._popupLayer.removeChild(this._eBook);
            this._popupLayer.removeChild(this._zoomBtn);
            this._zoomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.magnify);
         }
         else if(this._journeyBook)
         {
            DarkenManager.unDarken(this._journeyBook);
            this._popupLayer.removeChild(this._journeyBook);
         }
         else
         {
            DarkenManager.unDarken(this);
            if(Boolean(this._popupLayer) && this._popupLayer.parent == this)
            {
               this._popupLayer.removeChild(this);
            }
         }
         if(this._infoPopup)
         {
            this.onInfoPopupClose(null);
         }
         KeepAlive.stopKATimer(this._rightBottomBtn);
         KeepAlive.stopKATimer(this._leftBottomBtn);
         KeepAlive.stopKATimer(this._leftTopBtn);
         this.removeListeners();
         this._buttonsView = null;
         this._mediaViews = null;
         this._loadedPages = null;
         if(this._eBook)
         {
            while(this._eBook.numChildren > 0)
            {
               this._eBook.removeChildAt(0);
            }
         }
         else if(this._journeyBook)
         {
            while(this._journeyBook.numChildren > 0)
            {
               this._journeyBook.removeChildAt(0);
            }
         }
         else
         {
            while(this.numChildren > 0)
            {
               this.removeChildAt(0);
            }
         }
         this._pageFlipBase = null;
         this._stationaryRightPage = null;
         this._flippingBottomPageMask = null;
         this._flippingTopPageMask = null;
         this._flippingPageShadowMask = null;
         this._shadowStationaryMask = null;
         this._flippingBottomPage = null;
         this._flippingTopPage = null;
         this._stationaryLeftPage = null;
         this._flippingShadow = null;
         this._shadowsShadow = null;
         this._rightBottomBtn = null;
         this._leftTopBtn = null;
         this._leftBottomBtn = null;
         this._xBtn = null;
         this._print = null;
         this._closeCallback = null;
         this._flipCallback = null;
         this._pageNumberTxt = NaN;
         this._pageFlipIncrement = NaN;
         this._buttonsLoaded = NaN;
         this._numberOfLoadedPages = NaN;
         this._pageTurnedTo = NaN;
         this._spiralLeftPage.destroy();
         this._spiralRightPage.destroy();
         this._spiralTopFlippingPage.destroy();
         this._spiralBottomFlippingPage.destroy();
         pageFlipOpen = false;
         this._topPageTween = null;
         this._bottomPageTween = null;
      }
      
      private function removeListeners() : void
      {
         if(this._pageFlipBase)
         {
            this._pageFlipBase.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         if(this._buttonsLoaded == 4)
         {
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._leftTopBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._leftTopBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._leftTopBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
            this._leftTopBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
         }
         if(this._eBook)
         {
            this._eBook.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            this._eBook.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            this._eBook.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._zoomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.magnify);
         }
         if(this._journeyBook)
         {
            this._journeyBook.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         }
      }
      
      private function onLoadJBSounds(param1:MovieClip) : void
      {
         var _loc2_:ApplicationDomain = null;
         if(param1)
         {
            if(!AJAudio.hasLoadedJourneyBookBookSfx)
            {
               _loc2_ = param1.loaderInfo.applicationDomain;
               AJAudio.loadSfx("JBBookFactClose",_loc2_.getDefinition("JBBookFactClose") as Class,0.6);
               AJAudio.loadSfx("JBBookFactOpen",_loc2_.getDefinition("JBBookFactOpen") as Class,0.6);
               AJAudio.hasLoadedJourneyBookBookSfx = true;
            }
            this._pageHolderViews = [];
            this.loadHolderMovieClips();
         }
      }
      
      private function loadHolderMovieClips() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = -1;
         if(this._isSinglePF)
         {
            if(this._isJourneyBook)
            {
               _loc1_ = _loc2_ = JOURNEYBOOK_PAGES_ID;
               _loc3_ = JOURNEYBOOK_MEDIA_ID;
            }
            else
            {
               _loc1_ = SINGLE_PAGE_PAGES_ID;
               _loc2_ = SINGLE_PAGE_LAST_PAGE_ID;
            }
         }
         else
         {
            _loc1_ = _loc2_ = this._isRectangular ? EBOOK_PAGES_ID_TALL : EBOOK_PAGES_ID;
            _loc3_ = this._isRectangular ? RECTANGULAR_EBOOK_MEDIA_ID : EBOOK_MEDIA_ID;
         }
         if(!this._isJourneyBook)
         {
            this._currPageVarsLoaded = true;
         }
         var _loc4_:MediaHelper = new MediaHelper();
         _loc4_.init(_loc1_,this.pageHolderCallback);
         this._pageHolderViews[0] = _loc4_;
         _loc4_ = new MediaHelper();
         _loc4_.init(_loc1_,this.pageHolderCallback);
         this._pageHolderViews[1] = _loc4_;
         _loc4_ = new MediaHelper();
         _loc4_.init(_loc1_,this.pageHolderCallback);
         this._pageHolderViews[2] = _loc4_;
         _loc4_ = new MediaHelper();
         _loc4_.init(_loc1_,this.pageHolderCallback);
         this._pageHolderViews[3] = _loc4_;
         _loc4_ = new MediaHelper();
         _loc4_.init(_loc2_,this.pageHolderCallback,true);
         this._pageHolderViews[4] = _loc4_;
         if(_loc3_ > -1)
         {
            _loc4_ = new MediaHelper();
            _loc4_.init(_loc3_,this.pageHolderCallback,true);
            this._pageHolderViews[5] = _loc4_;
         }
      }
      
      private function pageHolderCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            if(Boolean(param1.passback) && param1.mediaHelper == this._pageHolderViews[4])
            {
               this._blankPageLast = param1;
            }
            else if(Boolean(param1.passback) && param1.mediaHelper == this._pageHolderViews[5])
            {
               if(param1.mediaHelper.id == JOURNEYBOOK_MEDIA_ID)
               {
                  this._journeyBook = MovieClip(param1.getChildAt(0));
               }
               else
               {
                  this._eBook = MovieClip(param1.getChildAt(0));
               }
            }
            else if(this._blankPage1 == null)
            {
               this._blankPage1 = param1;
            }
            else if(this._blankPage2 == null)
            {
               this._blankPage2 = param1;
            }
            else if(this._blankPage3 == null)
            {
               this._blankPage3 = param1;
            }
            else if(this._blankPage4 == null)
            {
               this._blankPage4 = param1;
            }
            if(param1.mediaHelper)
            {
               param1.mediaHelper.destroy();
               delete param1.mediaHelper;
            }
            ++this._pagesLoaded;
         }
         if(this._pagesLoaded == this._pageHolderViews.length)
         {
            this.openPageFlip();
         }
      }
      
      private function infoPopupCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            this._infoPopup = MovieClip(param1.getChildAt(0));
            this._popupLayer.addChild(this._infoPopup);
            this._infoPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onInfoPopupClose,false,0,true);
            this._infoPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onImageDown,false,0,true);
            if(this._showInfoPopup)
            {
               LocalizationManager.translateId(this._infoPopup.txt,11363);
            }
            else
            {
               LocalizationManager.translateId(this._infoPopup.txt,11364);
            }
            this._infoPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._infoPopup.y = MainFrame.VIEW_HEIGHT * 0.5 - 20;
         }
      }
      
      private function onInfoPopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._infoPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onImageDown);
         this._infoPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInfoPopupClose);
         this._popupLayer.removeChild(this._infoPopup);
         this._infoPopup = null;
      }
      
      private function loadButtons() : void
      {
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(LEFT_TOP_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[0] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(RIGHT_TOP_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[1] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(LEFT_BOTTOM_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[2] = _loc1_;
         _loc1_ = new MediaHelper();
         _loc1_.init(RIGHT_BOTTOM_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[3] = _loc1_;
         if(this._eBook)
         {
            _loc1_ = new MediaHelper();
            _loc1_.init(ZOOM_BTN_ID,this.buttonsCallback,true);
            this._buttonsView[4] = _loc1_;
         }
      }
      
      private function buttonsCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._buttonsView.length)
         {
            if(this._buttonsView[_loc2_] == param1.mediaHelper)
            {
               this._buttonsView[_loc2_] = param1;
               ++this._buttonsLoaded;
            }
            _loc2_++;
         }
         if(param1.mediaHelper)
         {
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
         }
         if(this._buttonsLoaded == (this._eBook ? 5 : 4))
         {
            this.initBtns();
         }
      }
      
      private function loadPages(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         if(this._isSinglePF)
         {
            _loc2_.init(this._pagesArray[param1 - 1],this.mediaHelperCallback,param1);
            this._mediaViews[param1 - 1] = _loc2_;
         }
         else
         {
            _loc2_.init(this._pagesArray[param1 - 2],this.mediaHelperCallback,param1);
            this._mediaViews[param1 - 2] = _loc2_;
            _loc2_ = new MediaHelper();
            _loc2_.init(this._pagesArray[param1 - 1],this.mediaHelperCallback,param1);
            this._mediaViews[param1 - 1] = _loc2_;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         if(this._pageFlipBase)
         {
            _loc2_ = 0;
            while(_loc2_ < this._mediaViews.length)
            {
               if(this._mediaViews[_loc2_] == param1.mediaHelper)
               {
                  delete this._mediaViews[_loc2_];
                  ++this._numberOfLoadedPages;
                  if(this._isSinglePF)
                  {
                     _loc3_ = this._pageFlipIncrement + _loc2_ * 2;
                     this._loadedPages[this._pageFlipIncrement + _loc2_ * 2] = param1;
                  }
                  else
                  {
                     _loc3_ = this._pageFlipIncrement + _loc2_;
                     if(this._isRectangular)
                     {
                        param1.scaleX = 0.499;
                        param1.scaleY = 0.499;
                     }
                     else
                     {
                        param1.scaleX = 0.413;
                        param1.scaleY = 0.413;
                     }
                     this._loadedPages[_loc3_] = param1;
                  }
                  this.checkPageForButtons(param1,_loc3_);
                  if((this._flipInProgress == 1 || this._pageFlipComplete == true) && this._flipDirection == 1)
                  {
                     this._currentPage = this._pageNumber;
                  }
                  if(int(this._numberOfFlips) == param1.passback)
                  {
                     if(this._numberOfLoadedPages == this._pageFlipIncrement)
                     {
                        this._numberOfLoadedPages = 0;
                        this._loadedPageNumber[param1.passback - this._pageFlipIncrement] = true;
                        this._currPageLoaded = true;
                     }
                     if(this._flipInProgress == 1 || this._pageFlipComplete == true)
                     {
                        if(this._pageNumber < this._numberOfPages)
                        {
                           this._setPagesOnly = true;
                        }
                        if(this._pageFlipComplete || this._pageFlipPercent > 0.95)
                        {
                           this._currentPage = this._pageNumber;
                           this.flipComplete();
                           this.initPage(this._pageNumber,this._flipDirection,this._vertDir);
                           if(this._flipDirection != 1)
                           {
                              this.setStationary(true);
                           }
                        }
                        else
                        {
                           this._currentPage = this._pageNumber;
                           this.setStationary(true);
                           _loc4_ = this._flipDirection == 1 ? int(this._pageNumber - 0.5) : int(this._pageNumber + 0.5);
                           if(this._loadedPages[_loc4_] != null)
                           {
                              _loc5_ = this._loadedPages[_loc4_];
                              _loc5_.x = -this._flipDirection * this._pageWidth * 0.5;
                              _loc5_.y = -this._vertDir * this._pivotY;
                              this._flippingBottomPage.addChild(_loc5_);
                           }
                           else
                           {
                              this._spiralBottomFlippingPage.setNewParent(this._flippingBottomPage,this._flipDirection * this._pageWidth * 0.5,-this._vertDir * this._pivotY);
                           }
                           this.setupButtonsPositions();
                        }
                     }
                     else
                     {
                        this.initPage(this._pageNumber,this._flipDirection,this._vertDir);
                     }
                  }
                  break;
               }
               _loc2_++;
            }
         }
      }
      
      private function checkPageForButtons(param1:MovieClip, param2:int) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:* = 0;
         var _loc8_:int = 0;
         var _loc9_:Object = null;
         if(param1)
         {
            _loc3_ = param1.numChildren;
            _loc4_ = 0;
            while(_loc4_ < param1.numChildren)
            {
               _loc5_ = param1.getChildAt(_loc4_);
               if(_loc5_ != null)
               {
                  _loc6_ = [];
                  _loc7_ = 0;
                  _loc8_ = 0;
                  while(_loc8_ < _loc5_.numChildren)
                  {
                     _loc9_ = _loc5_.getChildAt(_loc8_);
                     if(_loc9_.name.indexOf("movie") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onMovieDown,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("jb_title") == 0)
                     {
                        this._pageNameArray[param2] = _loc9_.name.substr(9);
                     }
                     else if(_loc9_.name.indexOf("jb_gift") == 0)
                     {
                        _loc5_.JBGift = _loc9_;
                        _loc5_.JBGift.id = _loc9_.name.substr(8);
                     }
                     else if(_loc9_.name.indexOf("jb") == 0)
                     {
                        _loc9_.jbId = _loc9_.name.substr(3);
                        var _loc10_:Number;
                        _loc6_[_loc10_ = _loc7_++] = _loc9_.jbId;
                     }
                     else if(_loc9_.name.indexOf("submitBtn") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSubmitDown,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("turnTo") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onTurnToBtn,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("linkTo") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onLinkToBtn,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("joinRoom") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinRoomBtn,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("joinParty") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinPartyBtn,false,0,true);
                     }
                     else if(_loc9_.name == "imgPoll")
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onImgPoll,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("loadPopup") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onLoadPopup,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("gameBtn") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onGameBtn,false,0,true);
                     }
                     else if(_loc9_.name.indexOf("petBtn") == 0)
                     {
                        _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetBtn,false,0,true);
                     }
                     _loc8_++;
                  }
                  if(_loc6_.length > 0)
                  {
                     _loc5_.numJBItemsTotal = _loc6_.length;
                     _loc5_.numJBItemsSeen = 0;
                     _loc5_.numJBItemsLoaded = 0;
                     _loc7_ = 0;
                     while(_loc7_ < _loc6_.length)
                     {
                        NGFactManager.requestJourneyBookFactDef(_loc6_[_loc7_],this.onJBFactDefReceived,param2);
                        _loc7_++;
                     }
                  }
                  else
                  {
                     this._currPageVarsLoaded = true;
                  }
               }
               _loc4_++;
            }
         }
      }
      
      private function onPetBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         PetManager.openPetFinder(PetManager.petNameForDefId(param1.currentTarget.name.split("_")[1]));
      }
      
      private function onGameBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._gameLaunchObj = {"typeDefId":param1.currentTarget.name.split("_")[1]};
         if(!MinigameManager.minigameInfoCache.getMinigameInfo(this._gameLaunchObj.typeDefId))
         {
            DarkenManager.showLoadingSpiral(true);
            MinigameXtCommManager.sendMinigameInfoRequest([this._gameLaunchObj.typeDefId],false,this.onMinigameInfoResponse);
         }
         else
         {
            MinigameManager.handleGameClick(this._gameLaunchObj,null,true);
         }
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(this._gameLaunchObj,null,true);
      }
      
      private function onMovieDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         var _loc2_:Array = new Array();
         _loc2_ = param1.currentTarget.name.split("_");
         var _loc3_:int = int(_loc2_[1]);
         var _loc4_:Boolean = _loc2_.length >= 3 ? _loc2_[2] == true : false;
         var _loc5_:String = _loc2_.length >= 4 ? _loc2_[3] : null;
         var _loc6_:int = _loc2_.length >= 5 ? int(_loc2_[4]) : int(null);
         var _loc7_:int = _loc2_.length >= 6 ? int(_loc2_[5]) : int(null);
         GenericListGuiManager.genericListVolumeClicked(_loc3_,{
            "shouldRepeat":_loc4_,
            "msg":_loc5_,
            "width":_loc6_,
            "height":_loc7_
         });
      }
      
      private function onSubmitDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(4);
      }
      
      private function onTurnToBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = int(param1.currentTarget.name.split("_")[1]);
         this.turnTo(this._currentPage + _loc2_ * 2,Boolean(_loc2_ % 2));
      }
      
      private function onLinkToBtn(param1:MouseEvent) : void
      {
         var splitArray:Array;
         var currName:String;
         var requestString:String;
         var request:URLRequest = null;
         var evt:MouseEvent = param1;
         evt.stopPropagation();
         splitArray = evt.currentTarget.name.split("_");
         currName = splitArray[1];
         requestString = "";
         if(currName == "blog")
         {
            if(splitArray.length > 2)
            {
               requestString = "http://blog.animaljam.com/" + splitArray[2].split("$").join("-");
            }
            else
            {
               requestString = "http://blog.animaljam.com/";
            }
         }
         else if(currName == "outfitters")
         {
            requestString = "http://shop.animaljam.com/";
         }
         else if(currName == "jump")
         {
            requestString = "http://jump.animaljam.com/";
         }
         else if(currName == "academy")
         {
            requestString = "http://academy.animaljam.com/";
         }
         if(requestString != "")
         {
            request = new URLRequest(requestString);
            try
            {
               navigateToURL(request,"_blank");
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error with loading URL");
            }
         }
         else
         {
            DebugUtility.debugTrace("Request string is == \'\' and currName = " + currName);
         }
      }
      
      private function onJoinRoomBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Array = param1.currentTarget.name.replace("joinRoom_","").split("$")[0].split("_");
         var _loc3_:String = "";
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc2_[_loc4_] != null)
            {
               if(_loc4_ + 1 >= _loc2_.length)
               {
                  _loc3_ += _loc2_[_loc4_];
               }
               else
               {
                  _loc3_ += _loc2_[_loc4_] + " ";
               }
            }
            _loc4_++;
         }
         new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(14775,_loc3_),true,this.onConfirmJoinRoom,param1.currentTarget.name);
      }
      
      private function onConfirmJoinRoom(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         if(param1.status)
         {
            _loc2_ = param1.passback.replace("joinRoom_","");
            _loc2_ = _loc2_.replace("$",".");
            _loc3_ = _loc2_.split("$");
            _loc2_ = _loc3_[0];
            _loc2_ = _loc2_.toLowerCase() + "#" + RoomManagerWorld.instance.shardId;
            if(_loc2_ != gMainFrame.server.getCurrentRoomName())
            {
               if(_loc3_.length == 2)
               {
                  RoomManagerWorld.instance.setGotoSpawnPoint(_loc3_[1].toLowerCase());
               }
               DarkenManager.showLoadingSpiral(true);
               RoomXtCommManager.sendRoomJoinRequest(_loc2_);
            }
         }
      }
      
      private function onJoinPartyBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = int(param1.currentTarget.name.split("_")[1]);
         new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(14776,LocalizationManager.translateIdOnly(PartyManager.getPartyDef(_loc2_).titleStrId)),true,this.onConfirmJoinParty,_loc2_);
      }
      
      private function onConfirmJoinParty(param1:Object) : void
      {
         if(param1.status)
         {
            gMainFrame.server.setXtObject_Str("sj",[param1.passback]);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onImgPoll(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         ImagePoll.displayPoll(ImagePoll.TSHIRT_VAR_ID,ImagePoll.TSHIRT_MEDIA_ID);
      }
      
      private function onLoadPopup(param1:MouseEvent) : void
      {
         var _loc2_:MediaHelper = null;
         param1.stopPropagation();
         if(!this._genericPopup)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = new MediaHelper();
            _loc2_.init(param1.currentTarget.name.split("_")[1],this.onPopupLoaded);
         }
         else
         {
            this._popupLayer.addChild(this._genericPopup);
            DarkenManager.darken(this._genericPopup);
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            this._genericPopup = MovieClip(param1.getChildAt(0));
            this._genericPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
            this._genericPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose,false,0,true);
            this._popupLayer.addChild(this._genericPopup);
            this._genericPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._genericPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            DarkenManager.darken(this._genericPopup);
         }
      }
      
      private function onPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._popupLayer.removeChild(this._genericPopup);
         DarkenManager.unDarken(this._genericPopup);
      }
      
      private function onJBItemDown(param1:MouseEvent) : void
      {
         NGFactManager.showJourneyBookFact(param1.currentTarget.jbId);
      }
      
      private function onJBItemOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.itemName != "")
         {
            GuiManager.toolTip.init(this._popupLayer,param1.currentTarget.itemName,param1.currentTarget.x + MainFrame.VIEW_WIDTH * 0.5,param1.currentTarget.y + MainFrame.VIEW_HEIGHT * 0.5);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onJBItemOut(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onJBGiftDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(param1.currentTarget.id.indexOf("d") == 0)
         {
            _loc2_ = DenXtCommManager.getDenItemDef(param1.currentTarget.id.substr(2));
            _loc3_ = GiftPopup.GIFT_TYPE_DEN_ACC;
         }
         else
         {
            _loc2_ = ItemXtCommManager.getItemDef(param1.currentTarget.id.substr(2));
            _loc3_ = GiftPopup.GIFT_TYPE_CLOTHING;
         }
         if(this._jbGiftPopup)
         {
            this._jbGiftPopup.destroy();
            this._jbGiftPopup = null;
         }
         this._jbGiftPopup = new GiftPopup();
         this._jbGiftPopup.init(this._popupLayer,param1.currentTarget.getImage(),_loc2_.name,GiftPopup.POPUP_TYPE_JAG,_loc3_,this.onKeepJBGift,this.onRejectJBGift,this.onCloseJBGift);
      }
      
      private function onKeepJBGift() : void
      {
         DarkenManager.showLoadingSpiral(true);
         AchievementXtCommManager.requestSetUserVar(this.jbUserVarIdForPageName(this._pageNameArray[Math.round(this._currentPage)]),JB_KEEP_GIFT,this.onSetUserVarResponse);
      }
      
      private function onRejectJBGift() : void
      {
         DarkenManager.showLoadingSpiral(true);
         AchievementXtCommManager.requestSetUserVar(this.jbUserVarIdForPageName(this._pageNameArray[Math.round(this._currentPage)]),JB_DISCARD_GIFT,this.onSetUserVarResponse);
      }
      
      private function onCloseJBGift() : void
      {
         if(this._jbGiftPopup)
         {
            this._jbGiftPopup.destroy();
            this._jbGiftPopup = null;
         }
      }
      
      private function onSetUserVarResponse(param1:int, param2:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:int = this.fixPageNum(this._currentPage) + 0.5;
         var _loc4_:MovieClip = MovieClip(this._loadedPages[_loc3_].getChildAt(0));
         if(_loc4_.JBGift)
         {
            _loc4_.JBGift.enable(false);
            _loc4_.JBGift.removeEventListener(MouseEvent.MOUSE_DOWN,this.onJBGiftDown);
         }
         --JBManager.numUnclaimedGifts;
         GuiManager.updateJBIcon();
         if(this._jbGiftPopup)
         {
            this._jbGiftPopup.destroy();
            this._jbGiftPopup = null;
         }
      }
      
      private function onJBFactDefReceived(param1:Object, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:MovieClip = null;
         if(this._pageFlipBase)
         {
            _loc3_ = MovieClip(this._loadedPages[param2].getChildAt(0));
            _loc4_ = _loc3_["jb_" + param1.id];
            if(!_loc4_)
            {
               _loc3_.numJBItemsLoaded = _loc3_.numJBItemsTotal;
               this._currPageVarsLoaded = true;
               this.showButtons();
               return;
            }
            ++_loc3_.numJBItemsLoaded;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,JB_PAGE_SEEN) && _loc3_.numJBItemsLoaded == 1)
            {
               JBManager.removeUnseenPage(param1.userVarId);
               AchievementXtCommManager.requestSetUserVar(param1.userVarId,JB_PAGE_SEEN);
            }
            if(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,param1.bitIdx))
            {
               ++_loc3_.numJBItemsSeen;
               _loc4_.enable();
               _loc4_.itemName = new String(LocalizationManager.translateIdOnly(param1.title));
               GuiManager.toolTip.resetTimerAndSetVisibility();
               _loc4_.addEventListener(MouseEvent.MOUSE_DOWN,this.onJBItemDown,false,0,true);
               _loc4_.addEventListener(MouseEvent.MOUSE_OVER,this.onJBItemOver,false,0,true);
               _loc4_.addEventListener(MouseEvent.MOUSE_OUT,this.onJBItemOut,false,0,true);
               if(_loc3_.numJBItemsSeen == _loc3_.numJBItemsTotal && Boolean(_loc3_.JBGift))
               {
                  if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,JB_KEEP_GIFT)) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(param1.userVarId,JB_DISCARD_GIFT)))
                  {
                     _loc3_.JBGift.enable(false);
                  }
                  else
                  {
                     _loc3_.JBGift.enable(true);
                     _loc3_.JBGift.addEventListener(MouseEvent.MOUSE_DOWN,this.onJBGiftDown,false,0,true);
                  }
               }
            }
            if(_loc3_.numJBItemsLoaded == _loc3_.numJBItemsTotal)
            {
               this._currPageVarsLoaded = true;
               if(this._currPageLoaded && this._flipInProgress == 0)
               {
                  this.flipComplete();
               }
               else if(this._flipInProgress == 0 && this._pageFlipComplete == false)
               {
                  if(Math.round(this._currentPage) == param2)
                  {
                     this._flipCallback(this._pageNameArray[param2]);
                  }
               }
            }
         }
      }
      
      private function onImageDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function removeIfChildAdded(param1:DisplayObjectContainer, param2:DisplayObject) : void
      {
         var _loc3_:int = 0;
         while(_loc3_ < param1.numChildren)
         {
            if(param1.getChildAt(_loc3_) == param2)
            {
               param1.removeChildAt(_loc3_);
               return;
            }
            _loc3_++;
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._zoomedIn)
         {
            if(this._eBook)
            {
               this._eBook.startDrag(false,this._fullPageBounds);
            }
            else
            {
               this.startDrag(false,this._fullPageBounds);
            }
         }
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._zoomedIn)
         {
            this.stopDrag();
         }
      }
      
      private function removeMovieClip(param1:DisplayObject) : void
      {
         if(param1)
         {
            if(param1.parent)
            {
               param1.parent.removeChild(param1);
            }
         }
      }
      
      private function makeMasks() : void
      {
         this.removeIfChildAdded(this._pageFlipBase,this._flippingBottomPageMask);
         this._flippingBottomPageMask = new Sprite();
         this._flippingBottomPageMask.mouseChildren = false;
         this._flippingBottomPageMask.mouseEnabled = false;
         with(this._flippingBottomPageMask.graphics)
         {
            beginFill(21760,1);
            lineTo(_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
            curveTo(0,-_vertDir * 2 * _pageWidthAndHeight,-_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
            lineTo(0,0);
            endFill();
            _pageFlipBase.addChild(_flippingBottomPageMask);
         }
         this.removeIfChildAdded(this._pageFlipBase,this._flippingTopPageMask);
         this._flippingTopPageMask = new Sprite();
         this._flippingTopPageMask.mouseChildren = false;
         this._flippingTopPageMask.mouseEnabled = false;
         with(this._flippingTopPageMask.graphics)
         {
            beginFill(21760,1);
            lineTo(_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
            curveTo(0,-_vertDir * 2 * _pageWidthAndHeight,-_pageWidthAndHeight,-_vertDir * _pageWidthAndHeight);
            lineTo(0,0);
            endFill();
            _pageFlipBase.addChild(_flippingTopPageMask);
         }
         this.removeIfChildAdded(this._pageFlipBase,this._flippingPageShadowMask);
         this._flippingPageShadowMask = new MovieClip();
         this.drawPage(this._flippingPageShadowMask,-this._flipDirection,this._vertDir);
         this._flippingPageShadowMask.rotation = this._vertDir * this._flipDirection * 90;
         this._pageFlipBase.addChild(this._flippingPageShadowMask);
         this._flippingPageShadowMask.mouseChildren = false;
         this._flippingPageShadowMask.mouseEnabled = false;
         this.removeIfChildAdded(this._pageFlipBase,this._shadowStationaryMask);
         this._shadowStationaryMask = new MovieClip();
         this.drawPage(this._shadowStationaryMask,this._flipDirection,this._vertDir);
         this._pageFlipBase.addChild(this._shadowStationaryMask);
         this._shadowStationaryMask.mouseChildren = false;
         this._shadowStationaryMask.mouseEnabled = false;
         this._flippingBottomPage.mask = this._flippingBottomPageMask;
         this._flippingTopPage.mask = this._flippingTopPageMask;
         this._flippingShadow.mask = this._flippingPageShadowMask;
         this._shadowsShadow.mask = this._shadowStationaryMask;
      }
      
      private function range0to1(param1:Number) : Number
      {
         return param1 > 1 ? 1 : (param1 < 0 ? 0 : param1);
      }
      
      private function makeShade(param1:Sprite, param2:Number, param3:Number) : void
      {
         var pageDrawingTarget:Sprite = param1;
         var xQuadrant:Number = param2;
         var yQuadrant:Number = param3;
         var colors:Array = [0,0,0,0,0,0,0];
         var alphas:Array = [0.6,0.4,0.2,0,0,0,0];
         var ratios:Array = [0,1,17,51,89,132,255];
         var mat:Matrix = new Matrix();
         with(pageDrawingTarget.graphics)
         {
            mat.createGradientBox(xQuadrant * _pageWidth,-yQuadrant * _pageHeight,0,0,-yQuadrant * _pageWidth);
            beginGradientFill("linear",colors,alphas,ratios,mat);
            moveTo(0,-_pageWidth * yQuadrant);
            lineTo(0,-_pageWidthAndHeight * yQuadrant);
            lineTo(xQuadrant * _pageWidth,-_pageWidthAndHeight * yQuadrant);
            lineTo(xQuadrant * _pageWidth,-_pageWidth * yQuadrant);
            lineTo(0,-_pageWidth * yQuadrant);
            endFill();
         }
      }
      
      private function makeShadow(param1:Sprite, param2:Number) : void
      {
         var colors:Array = null;
         var alphas:Array = null;
         var ratios:Array = null;
         var ratio:Number = NaN;
         var pageDrawingTarget:Sprite = param1;
         var xQuadrant:Number = param2;
         var maxLength:Number = Math.sqrt(this._pageWidth * this._pageWidth + this._pageWidthAndHeight * this._pageWidthAndHeight);
         var mat:Matrix = new Matrix();
         colors = [0,0,0,0,0,0,0];
         alphas = [0.6,0.4,0.2,0,0,0,0];
         ratios = [0,1,17,51,89,132,255];
         with(pageDrawingTarget.graphics)
         {
            mat.createGradientBox(xQuadrant * _pageWidth,_vertDir * (maxLength - _pageWidth),0,0,0);
            beginGradientFill("linear",colors,alphas,ratios,mat);
            moveTo(0,-_vertDir * _pageWidth);
            lineTo(0,-_vertDir * maxLength);
            lineTo(xQuadrant * _pageWidth,-_vertDir * maxLength);
            lineTo(xQuadrant * _pageWidth,-_vertDir * _pageWidth);
            lineTo(0,-_vertDir * _pageWidth);
            endFill();
         }
      }
      
      private function getPageRatio() : Number
      {
         if(this._ShouldBeDragging)
         {
            if(this._isSinglePF)
            {
               this._pageRatio = -this._flipDirection * (mouseX - this._startX - this._flipDirection * this._cornerBtnPositions) / ((this._isJourneyBook ? 2 : 10) * this._pageWidth);
            }
            else
            {
               this._pageRatio = -this._flipDirection * (mouseX - this._startX - this._flipDirection * this._cornerBtnPositions) / (2 * this._pageWidth);
            }
         }
         else if(this._pageRatio > 2 / 3)
         {
            this._pageRatio += this._autoStepSpeed;
         }
         else
         {
            this._pageRatio -= this._autoStepSpeed;
         }
         return this.range0to1(this._pageRatio);
      }
      
      private function startFlip(param1:Number, param2:Number, param3:int) : void
      {
         this._flipInProgress = 1;
         if(param2 == 1)
         {
            if(this._isSinglePF)
            {
               this._numberOfFlips += param3;
            }
            else
            {
               this._numberOfFlips += param3 * 2;
            }
         }
         else if(this._isSinglePF)
         {
            this._numberOfFlips -= param3;
         }
         else
         {
            this._numberOfFlips -= param3 * 2;
         }
         this._numberOfFlips = Math.min(this._numberOfPages,this._numberOfFlips);
         this._pageFlipComplete = false;
         if(!this._loadedPageNumber[this._numberOfFlips - this._pageFlipIncrement])
         {
            this.initPage(param1,param2,this._vertDir);
            if(this._isJourneyBook)
            {
               this._currPageVarsLoaded = false;
            }
            this._currPageLoaded = false;
            this.loadPages(this._numberOfFlips);
         }
         else
         {
            this.initPage(param1,param2,this._vertDir);
            this._currentPage = param1;
         }
         this._startX = param2 * this._pageWidth;
         if(this._showCornerBtns)
         {
            this._rightBottomBtn.visible = this._leftBottomBtn.visible = this._leftTopBtn.visible = false;
         }
         this._pageOffset = 0;
         this.renderPageFlip(this._pageFlipPercent);
         this._pageFlipBase.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         if(this._playFlipSound)
         {
            AJAudio.playNewspaperSound();
         }
      }
      
      private function setupButtonsPositions() : void
      {
         var _loc1_:Number = -this._vertDir * (this._pageWidth + this._pageHeight * 0.5);
         var _loc2_:Number = this._pageHeight / 2;
         if(this._showCornerBtns && this._buttonsLoaded == (this._eBook ? 5 : 4))
         {
            this._rightBottomBtn.y = this._leftBottomBtn.y = _loc1_ + _loc2_;
            this._leftTopBtn.y = _loc1_ - _loc2_ + this._leftTopBtn.height;
            this._xBtn.y = _loc1_ - _loc2_ + this._xBtn.height;
            if(this._enableDragging)
            {
               if(this._isSinglePF)
               {
                  this._rightBottomBtn.x = this._pageWidth - this._rightBottomBtn.width;
                  this._xBtn.x = this._pageWidth - this._xBtn.width;
               }
               else
               {
                  this._rightBottomBtn.x = this._pageWidth - this._rightBottomBtn.width;
                  this._xBtn.x = this._pageWidth - this._xBtn.width;
                  this._leftBottomBtn.x = this._leftTopBtn.x = -this._pageWidth + this._leftBottomBtn.width;
               }
            }
            this.bringButtonsToFront();
         }
      }
      
      private function flipAuto(param1:Number) : void
      {
         this._step = (param1 - this._pageFlipPercent) * this._dragSmoothness;
         this._pageFlipPercent += this._step;
         this.renderPageFlip(this._pageFlipPercent);
         if(this._pageFlipPercent > 1 - this._snapDistance)
         {
            this.renderPageFlip(1);
            this.flipComplete();
            if(this._bFlipAuto)
            {
               if(this._currentPage < this._autoFlipTargetPage)
               {
                  this.startFlip(this._currentPage + this._directionAfterFlip * 2,this._directionAfterFlip,0);
               }
               else
               {
                  this._bFlipAuto = false;
               }
            }
         }
      }
      
      public function turnTo(param1:Number, param2:Boolean = true) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param2)
         {
            this._pageNumber = this.fixPageNum(param1);
         }
         else
         {
            this._pageNumber = param1;
         }
         if(this._pageNumber != this._currentPage)
         {
            if(this._flipInProgress == 0)
            {
               _loc3_ = Math.round((this._pageNumber - this._currentPage) * 0.5);
               _loc4_ = this._pageNumber > this._currentPage ? 1 : -1;
               this._pageTurnedTo += _loc3_;
               this.startFlip(this._pageNumber,_loc4_,Math.abs(_loc3_));
            }
         }
      }
      
      private function fixPageNum(param1:Number) : Number
      {
         var _loc2_:int = param1 % 2;
         if(_loc2_ == 0)
         {
            return param1 + 0.5;
         }
         if(_loc2_ == 1)
         {
            return param1 - 0.5;
         }
         return param1;
      }
      
      private function turnBack() : void
      {
         if(this._currentPage > 0.5)
         {
            this.turnTo(this._currentPage - 2);
         }
      }
      
      private function turnAhead() : void
      {
         if(this._currentPage < this._numberOfPages)
         {
            this.turnTo(this._currentPage + 2);
         }
      }
      
      public function flipTo(param1:Number) : void
      {
         param1 = this.fixPageNum(param1);
         if(param1 > this._currentPage)
         {
            this._directionAfterFlip = 1;
         }
         else
         {
            if(param1 >= this._currentPage)
            {
               return;
            }
            this._directionAfterFlip = -1;
         }
         this._bFlipAuto = true;
         this._autoFlipTargetPage = param1;
         this.startFlip(this._currentPage + this._directionAfterFlip * 2,this._directionAfterFlip,0);
      }
      
      private function drawPage(param1:MovieClip, param2:Number, param3:Number) : void
      {
         var pageDrawingTarget:MovieClip = param1;
         var xQuadrant:Number = param2;
         var yQuadrant:Number = param3;
         with(pageDrawingTarget.graphics)
         {
            beginFill(_pageColor,0);
            moveTo(0,-yQuadrant * _pageWidth);
            lineTo(0,-yQuadrant * _pageWidth);
            lineTo(0,-yQuadrant * _pageWidthAndHeight);
            lineTo(xQuadrant * _pageWidth,-yQuadrant * _pageWidthAndHeight);
            lineTo(xQuadrant * _pageWidth,-yQuadrant * _pageWidth);
            endFill();
         }
      }
      
      private function renderPageFlip(param1:Number) : void
      {
         var _loc2_:Number = this._vertDir * this._flipDirection * 45 * param1;
         this._flippingBottomPageMask.rotation = this._flippingTopPageMask.rotation = -_loc2_;
         this._flippingBottomPage.rotation = this._flippingPageShadowMask.rotation = this._vertDir * (this._flipDirection * 90) - _loc2_ * 2;
         this._flippingShadow.rotation = this._shadowsShadow.rotation = this._vertDir * (this._flipDirection * 45) - _loc2_;
      }
      
      private function showButtons() : void
      {
         if(this._flipInProgress == 0)
         {
            if(this._enableDragging)
            {
               this.setupButtonsPositions();
            }
            if(this._showCornerBtns && this._currPageLoaded && this._currPageVarsLoaded && this._buttonsLoaded == (this._eBook ? 5 : 4))
            {
               if(this._stationaryLeftPage)
               {
                  this._stationaryLeftPage.visible = true;
               }
               this._rightBottomBtn.alpha = this._leftBottomBtn.alpha = this._xBtn.alpha = this._leftTopBtn.alpha = 1;
               if(this._isSinglePF && this._currentPage != 0.5 || !this._isSinglePF && this._currentPage != 2.5)
               {
                  this._leftBottomBtn.visible = true;
                  if(!this._isSinglePF)
                  {
                     this._leftTopBtn.visible = true;
                  }
               }
               else
               {
                  this._leftBottomBtn.visible = this._leftTopBtn.visible = false;
               }
               if(this._currentPage != this._numberOfPages)
               {
                  if(this._pageTurnedTo * 2 <= this._numberOfPages + 0.5)
                  {
                     this._rightBottomBtn.visible = true;
                  }
                  else
                  {
                     this._rightBottomBtn.visible = false;
                  }
                  if(!this._eBook)
                  {
                     this._xBtn.visible = true;
                  }
               }
               else
               {
                  this._rightBottomBtn.visible = false;
               }
            }
         }
      }
      
      private function flipComplete() : void
      {
         this._pageFlipBase.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         this._pageFlipPercent = 0;
         this._flipInProgress = 0;
         this._pageFlipComplete = true;
         this._setPagesOnly = false;
         if(this._enableDragging)
         {
            this.setupButtonsPositions();
         }
         if(this._showCornerBtns && this._currPageLoaded && this._currPageVarsLoaded && this._buttonsLoaded == (this._eBook ? 5 : 4))
         {
            if(this._stationaryLeftPage)
            {
               this._stationaryLeftPage.visible = true;
            }
            this._rightBottomBtn.alpha = this._leftBottomBtn.alpha = this._xBtn.alpha = this._leftTopBtn.alpha = 1;
            if(this._isSinglePF && this._currentPage != 0.5 || !this._isSinglePF && this._currentPage != 2.5)
            {
               this._leftBottomBtn.visible = true;
               if(!this._isSinglePF)
               {
                  this._leftTopBtn.visible = true;
               }
            }
            else
            {
               this._leftBottomBtn.visible = this._leftTopBtn.visible = false;
            }
            if(this._currentPage != this._numberOfPages)
            {
               if(this._pageTurnedTo * 2 <= this._numberOfPages + 0.5)
               {
                  this._rightBottomBtn.visible = true;
               }
               else
               {
                  this._rightBottomBtn.visible = false;
               }
               if(!this._eBook)
               {
                  this._xBtn.visible = true;
               }
            }
            else
            {
               this._rightBottomBtn.visible = false;
            }
            if(this._flipCallback != null && this._pageOffset != 0)
            {
               if(this._isJourneyBook)
               {
                  this._flipCallback(this._pageNameArray[Math.round(this._currentPage)]);
               }
               else
               {
                  this._flipCallback(this._pageTurnedTo);
               }
            }
         }
         if(this._pageOffset == 0 || this._isJourneyBook)
         {
            return;
         }
         if(this._isSinglePF && !this._isJourneyBook)
         {
            if(this._flipDirection == 1)
            {
               this.removeMovieClip(this._flippingShadow);
               this.removeMovieClip(this._flippingPageShadowMask);
               this.removeMovieClip(this._flippingBottomPage);
               this.removeMovieClip(this._flippingBottomPageMask);
               this.removeMovieClip(this._flippingTopPage);
               this.removeMovieClip(this._flippingTopPageMask);
               this.removeMovieClip(this._stationaryLeftPage);
            }
         }
         else if(this._flipDirection == -1)
         {
            this.removeMovieClip(this._stationaryRightPage);
         }
         else
         {
            this.removeMovieClip(this._stationaryLeftPage);
         }
      }
      
      private function createShadow() : void
      {
         this.removeIfChildAdded(this._pageFlipBase,this._flippingShadow);
         this._flippingShadow = new Sprite();
         this._flippingShadow.mouseChildren = false;
         this._flippingShadow.mouseEnabled = false;
         this.makeShadow(this._flippingShadow,-this._flipDirection);
         this._flippingShadow.rotation = this._vertDir * this._flipDirection * 45;
         this._pageFlipBase.addChild(this._flippingShadow);
         this.removeIfChildAdded(this._pageFlipBase,this._shadowsShadow);
         this._shadowsShadow = new Sprite();
         this._shadowsShadow.mouseChildren = false;
         this._shadowsShadow.mouseEnabled = false;
         this.makeShadow(this._shadowsShadow,this._isSinglePF && !this._isJourneyBook ? 1 : this._flipDirection);
         this._shadowsShadow.rotation = this._vertDir * this._flipDirection * 45;
         this._pageFlipBase.addChild(this._shadowsShadow);
      }
      
      private function LB() : void
      {
         if(this._currentPage != 0.5)
         {
            if(!this._isSinglePF || this._isJourneyBook)
            {
               this._stationaryLeftPage.visible = true;
            }
         }
         else if(this._currentPage == this._numberOfPages + 0.5)
         {
            this._stationaryRightPage.visible = false;
         }
         if(this._pageNumber == 0.5 && !this._isJourneyBook)
         {
            this._shadowsShadow.visible = false;
         }
      }
      
      private function setFlipping() : void
      {
         var _loc5_:Sprite = null;
         this.removeIfChildAdded(this._pageFlipBase,this._flippingTopPage);
         this._flippingTopPage = new MovieClip();
         var _loc1_:MovieClip = new MovieClip();
         var _loc2_:int = this._flipDirection == 1 ? int(this._currentPage + 0.5) : int(this._currentPage - 0.5);
         if(_loc2_ <= this._numberOfPages + 0.5)
         {
            if(_loc2_ >= this._numberOfPages)
            {
               this.drawPage(_loc1_,this._flipDirection,this._vertDir);
               this._flippingTopPage.addChild(_loc1_);
               if(this._isJourneyBook && this._flipDirection < 0)
               {
                  this._blankPageLast.scaleX = -1;
               }
               else
               {
                  this._blankPageLast.scaleX = 1;
               }
               this._blankPageLast.x = this._flipDirection * this._pageWidth * 0.5;
               this._blankPageLast.y = -this._vertDir * this._pivotY;
               this._flippingTopPage.addChild(this._blankPageLast);
            }
            else
            {
               this.drawPage(_loc1_,this._flipDirection,this._vertDir);
               this._flippingTopPage.addChild(_loc1_);
               if(this._isJourneyBook && this._flipDirection < 0)
               {
                  this._blankPage3.scaleX = -1;
               }
               else
               {
                  this._blankPage3.scaleX = 1;
               }
               this._blankPage3.x = this._flipDirection * this._pageWidth * 0.5;
               this._blankPage3.y = -this._vertDir * this._pivotY;
               this._flippingTopPage.addChild(this._blankPage3);
            }
            if(this._isSinglePF && !this._isJourneyBook)
            {
               if(this._flipInProgress == 1)
               {
                  if(this._flipDirection < 0)
                  {
                     this._flippingTopPage.alpha = 0;
                     this._topPageTween = new GTween(this._flippingTopPage,0.7,{"alpha":1},{"ease":Quadratic.easeIn});
                  }
                  else
                  {
                     this._topPageTween = new GTween(this._flippingTopPage,0.7,{"alpha":0},{"ease":Quadratic.easeIn});
                  }
               }
            }
            if(this._loadedPages[_loc2_] != null)
            {
               this._print = new Sprite();
               this._print = this._loadedPages[_loc2_];
               this._print.x = this._flipDirection * this._pageWidth * 0.5;
               this._print.y = -this._vertDir * this._pivotY;
               this._flippingTopPage.addChild(this._print);
            }
            else
            {
               this._spiralTopFlippingPage.setNewParent(this._flippingTopPage,this._flipDirection * this._pageWidth * 0.5,-this._vertDir * this._pivotY);
            }
            if(this._flipDirection != -1 || (!this._isSinglePF || this._isJourneyBook))
            {
               _loc5_ = new MovieClip();
               _loc5_.mouseChildren = false;
               _loc5_.mouseEnabled = false;
               this.makeShade(_loc5_,this._flipDirection,this._vertDir);
               this._flippingTopPage.addChild(_loc5_);
               this._pageFlipBase.addChild(this._flippingTopPage);
            }
         }
         this.removeIfChildAdded(this._pageFlipBase,this._flippingBottomPage);
         this._flippingBottomPage = new MovieClip();
         var _loc3_:MovieClip = new MovieClip();
         this.drawPage(_loc3_,-this._flipDirection,this._vertDir);
         this._flippingBottomPage.addChild(_loc3_);
         if(this._isJourneyBook && this._flipInProgress == 1)
         {
            if(this._flipDirection > 0)
            {
               this._blankPage4.scaleX = -1;
            }
            else
            {
               this._blankPage4.scaleX = 1;
            }
         }
         this._blankPage4.x = -this._flipDirection * this._pageWidth * 0.5;
         this._blankPage4.y = -this._vertDir * this._pivotY;
         this._flippingBottomPage.addChild(this._blankPage4);
         if(this._isSinglePF && !this._isJourneyBook)
         {
            if(this._flipInProgress == 1)
            {
               if(this._flipDirection < 0)
               {
                  this._flippingBottomPage.alpha = 0;
                  this._bottomPageTween = new GTween(this._flippingBottomPage,0.7,{"alpha":1},{"ease":Quadratic.easeIn});
               }
               else
               {
                  this._bottomPageTween = new GTween(this._flippingBottomPage,0.7,{"alpha":0},{"ease":Quadratic.easeIn});
               }
            }
         }
         var _loc4_:Sprite = new MovieClip();
         if(this._isSinglePF)
         {
            if(this._flipDirection != 1 || this._isJourneyBook)
            {
               _loc2_ = this._flipDirection == 1 ? int(this._pageNumber - 0.5) : int(this._pageNumber + 0.5);
               if(this._loadedPages[_loc2_] != null)
               {
                  _loc4_ = this._loadedPages[_loc2_];
                  _loc4_.x = -this._flipDirection * this._pageWidth * 0.5;
                  _loc4_.y = -this._vertDir * this._pivotY;
                  this._flippingBottomPage.addChild(_loc4_);
               }
               else if(!this._isJourneyBook && this._flipDirection == -1)
               {
                  this._spiralBottomFlippingPage.setNewParent(this._flippingBottomPage,this._flipDirection * this._pageWidth * 0.5,-this._vertDir * this._pivotY);
               }
            }
         }
         else
         {
            _loc2_ = this._flipDirection == 1 ? int(this._pageNumber - 0.5) : int(this._pageNumber + 0.5);
            if(!this._ShouldBeDragging && !this._isJourneyBook && this._pageNumber <= this._numberOfPages)
            {
               _loc2_ += this._flipDirection * 2;
            }
            if(this._loadedPages[_loc2_] != null)
            {
               _loc4_ = this._loadedPages[_loc2_];
               _loc4_.x = -this._flipDirection * this._pageWidth * 0.5;
               _loc4_.y = -this._vertDir * this._pivotY;
               this._flippingBottomPage.addChild(_loc4_);
            }
            else
            {
               this._spiralBottomFlippingPage.setNewParent(this._flippingBottomPage,-this._flipDirection * this._pageWidth * 0.5,-this._vertDir * this._pivotY);
            }
         }
         this._flippingBottomPage.rotation = -this._flipDirection * this._vertDir * 90;
         this._pageFlipBase.addChild(this._flippingBottomPage);
      }
      
      private function startDragging(param1:Number, param2:Number) : void
      {
         this._ShouldBeDragging = true;
         this.initPage(this._currentPage + param1 * 2,param1,param2);
         if(this._isSinglePF && param1 == -1)
         {
            this._startX = 0;
         }
         else
         {
            this._startX = param1 * this._pageWidth;
         }
         if(this._showCornerBtns)
         {
            if(param1 == -1 && (this._isSinglePF || this._isJourneyBook))
            {
               this._rightBottomBtn.alpha = this._leftTopBtn.alpha = 0;
            }
            else
            {
               this._rightBottomBtn.alpha = this._leftBottomBtn.alpha = this._leftTopBtn.alpha = 0;
            }
         }
         this._pageFlipPercent = 0;
         this._pageFlipBase.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function initPage(param1:Number, param2:Number, param3:Number) : void
      {
         this._pageNumber = param1;
         this._flipDirection = param2;
         this._vertDir = param3;
         if(this._vertDir == 1)
         {
            this._pageFlipBase.y = this._pageWidth + this._pageHeight * 0.5;
         }
         if(this._vertDir != 1)
         {
            this._pageFlipBase.y = -(this._pageWidth + this._pageHeight * 0.5);
         }
         this.setStationary();
         if(this._setPagesOnly)
         {
            this._currentPage = this._pageNumber - 2;
         }
         this.setFlipping();
         this.createShadow();
         this.makeMasks();
         this.LB();
         if(this._setPagesOnly)
         {
            this._currentPage = this._pageNumber + 2;
         }
         if(this._currPageLoaded)
         {
            this.setupButtonsPositions();
         }
         if(this._currPageVarsLoaded && this._currPageLoaded)
         {
            this.showButtons();
         }
      }
      
      private function setStationary(param1:Boolean = false) : void
      {
         var _loc4_:Sprite = null;
         var _loc5_:MovieClip = null;
         var _loc6_:Sprite = null;
         var _loc7_:Sprite = null;
         var _loc2_:int = -1;
         var _loc3_:MovieClip = new MovieClip();
         if(!this._isSinglePF && this._flipInProgress != 1)
         {
            if(param1)
            {
               if(this._stationaryLeftPage.parent == this._pageFlipBase)
               {
                  _loc2_ = this._pageFlipBase.getChildIndex(this._stationaryLeftPage);
               }
            }
            this.removeIfChildAdded(this._pageFlipBase,this._stationaryLeftPage);
            this._stationaryLeftPage = new MovieClip();
            if(this._currentPage != 0.5)
            {
               this.drawPage(_loc3_,-1,this._vertDir);
               this._stationaryLeftPage.addChild(_loc3_);
               this._blankPage1.x = -this._pageWidth * 0.5;
               this._blankPage1.y = -this._vertDir * this._pivotY;
               this._stationaryLeftPage.addChild(this._blankPage1);
               this._pageNumberTxt = this._flipDirection == 1 ? int(this._currentPage - 0.5) : int(this._pageNumber - 0.5);
               if(this._pageNumberTxt != 0)
               {
                  if(this._loadedPages[this._pageNumberTxt] != null)
                  {
                     _loc4_ = new MovieClip();
                     _loc4_ = this._loadedPages[this._pageNumberTxt];
                     _loc4_.x = -this._pageWidth * 0.5;
                     _loc4_.y = -this._vertDir * this._pivotY;
                     this._stationaryLeftPage.addChild(_loc4_);
                  }
                  else
                  {
                     this._spiralLeftPage.setNewParent(this._stationaryLeftPage,this._pageWidth * 0.5,-this._vertDir * this._pivotY);
                  }
                  this._pageFlipBase.addChild(this._stationaryLeftPage);
                  if(_loc2_ != -1)
                  {
                     this._pageFlipBase.setChildIndex(this._stationaryLeftPage,_loc2_);
                  }
                  _loc2_ = -1;
                  if(param1)
                  {
                     this._stationaryLeftPage.visible = false;
                  }
               }
            }
         }
         if(this._isJourneyBook)
         {
            if(param1)
            {
               if(this._stationaryLeftPage.parent == this._pageFlipBase)
               {
                  _loc2_ = this._pageFlipBase.getChildIndex(this._stationaryLeftPage);
               }
            }
            this.removeIfChildAdded(this._pageFlipBase,this._stationaryLeftPage);
            this._stationaryLeftPage = new MovieClip();
            this.drawPage(_loc3_,-1,this._vertDir);
            this._stationaryLeftPage.addChild(_loc3_);
            this._blankPage1.scaleX = -1;
            this._blankPage1.x = -this._pageWidth * 0.5;
            this._blankPage1.y = -this._vertDir * this._pivotY;
            this._stationaryLeftPage.addChild(this._blankPage1);
            this._pageFlipBase.addChild(this._stationaryLeftPage);
            if(_loc2_ != -1)
            {
               this._pageFlipBase.setChildIndex(this._stationaryLeftPage,_loc2_);
            }
            _loc2_ = -1;
         }
         if(param1)
         {
            if(this._stationaryRightPage.parent == this._pageFlipBase)
            {
               _loc2_ = this._pageFlipBase.getChildIndex(this._stationaryRightPage);
            }
         }
         this.removeIfChildAdded(this._pageFlipBase,this._stationaryRightPage);
         this._stationaryRightPage = new MovieClip();
         if(this._pageNumber <= this._numberOfPages + 0.5)
         {
            _loc5_ = new MovieClip();
            this._pageNumberTxt = this._flipDirection == 1 ? int(this._pageNumber + 0.5) : int(this._currentPage + 0.5);
            if(this._pageNumberTxt >= this._numberOfPages)
            {
               this.drawPage(_loc5_,this._flipDirection,this._vertDir);
               this._stationaryRightPage.addChild(_loc5_);
               this._blankPageLast.x = this._pageWidth * 0.5;
               this._blankPageLast.y = -this._vertDir * this._pivotY;
               this._stationaryRightPage.addChild(this._blankPageLast);
            }
            else
            {
               this.drawPage(_loc5_,1,this._vertDir);
               this._stationaryRightPage.addChild(_loc5_);
               this._blankPage2.x = this._pageWidth * 0.5;
               this._blankPage2.y = -this._vertDir * this._pivotY;
               this._stationaryRightPage.addChild(this._blankPage2);
            }
            if(this._pageNumberTxt <= this._numberOfPages + 0.5)
            {
               if(this._loadedPages[this._pageNumberTxt] != null)
               {
                  _loc6_ = new MovieClip();
                  _loc6_ = this._loadedPages[this._pageNumberTxt];
                  _loc6_.x = this._pageWidth * 0.5;
                  _loc6_.y = -this._vertDir * this._pivotY;
                  this._stationaryRightPage.addChild(_loc6_);
               }
               else
               {
                  this._spiralRightPage.setNewParent(this._stationaryRightPage,this._pageWidth * 0.5,-this._vertDir * this._pivotY);
               }
               this._pageFlipBase.addChild(this._stationaryRightPage);
               if(_loc2_ != -1)
               {
                  this._pageFlipBase.setChildIndex(this._stationaryRightPage,_loc2_);
               }
            }
         }
         if(!this._isSinglePF || this._isJourneyBook || this._flipDirection == -1)
         {
            _loc7_ = new MovieClip();
            _loc7_.mouseChildren = false;
            _loc7_.mouseEnabled = false;
            this.makeShade(_loc7_,-this._flipDirection,this._vertDir);
            if(this._flipDirection > 0 && !this._isSinglePF && this._pageDrag)
            {
               this._stationaryLeftPage.addChild(_loc7_);
            }
            else
            {
               this._stationaryRightPage.addChild(_loc7_);
            }
         }
      }
      
      private function dropPage() : void
      {
         if(this._pageRatio > 2 / 3)
         {
            this._currentPage += 2 * this._flipDirection;
         }
         this._pageDrag = this._ShouldBeDragging = false;
         if(this._showCornerBtns)
         {
            this._leftBottomBtn.visible = this._rightBottomBtn.visible = true;
            if(!this._eBook)
            {
               this._xBtn.visible = true;
            }
            if(!this._isSinglePF)
            {
               this._leftTopBtn.visible = true;
            }
         }
      }
      
      private function stopDragging(param1:Number) : void
      {
         if(this._pageDrag)
         {
            if(param1 > 0)
            {
               this.turnAhead();
            }
            else
            {
               this.turnBack();
            }
            this._pageDrag = false;
         }
      }
      
      private function initBtns() : void
      {
         this._leftBottomBtn = this._buttonsView[2];
         this._leftTopBtn = this._buttonsView[0];
         this._rightBottomBtn = this._buttonsView[3];
         this._xBtn = this._buttonsView[1];
         if(this._eBook)
         {
            this._zoomBtn = this._buttonsView[4];
            this._zoomBtn.x = MainFrame.VIEW_WIDTH * 0.5;
            this._zoomBtn.y = MainFrame.VIEW_HEIGHT - 30;
            this._popupLayer.addChild(this._zoomBtn);
            this._zoomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.magnify,false,0,true);
            this._zoomBtn.magnifyBtnMinus.visible = false;
         }
         this._pageFlipBase.addChild(this._rightBottomBtn);
         this._pageFlipBase.addChild(this._leftBottomBtn);
         this._pageFlipBase.addChild(this._leftTopBtn);
         this._pageFlipBase.addChild(this._xBtn);
         KeepAlive.startKATimer(this._rightBottomBtn);
         KeepAlive.startKATimer(this._leftBottomBtn);
         KeepAlive.startKATimer(this._leftTopBtn);
         if(this._currPageLoaded)
         {
            this.setupButtonsPositions();
         }
         if(this._isSinglePF)
         {
            this._rightBottomBtn.x = this._pageWidth;
            this._xBtn.x = this._pageWidth;
            this._leftBottomBtn.x = this._leftBottomBtn.width;
            if(this._pageTurnedTo * 2 > this._numberOfPages + 0.5)
            {
               this._rightBottomBtn.visible = false;
            }
         }
         else
         {
            this._rightBottomBtn.x = this._pageWidth;
            this._xBtn.x = this._pageWidth;
            this._leftBottomBtn.x = this._leftTopBtn.x = -this._pageWidth + this._leftBottomBtn.width;
         }
         if(this._isSinglePF)
         {
            this._leftTopBtn.visible = false;
            if(this._pageStart < 2)
            {
               this._leftBottomBtn.visible = false;
            }
         }
         else if(this._pageStart < 3)
         {
            this._leftTopBtn.visible = false;
            this._leftBottomBtn.visible = false;
         }
         if(!this._currPageVarsLoaded)
         {
            this._leftBottomBtn.visible = false;
            this._rightBottomBtn.visible = false;
         }
         if(this._eBook)
         {
            this._xBtn.visible = false;
         }
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._leftTopBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._leftTopBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._leftTopBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
         this._leftTopBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
      }
      
      private function bringButtonsToFront() : void
      {
         this._leftBottomBtn.parent.setChildIndex(this._leftBottomBtn,this._leftBottomBtn.parent.numChildren - 1);
         this._rightBottomBtn.parent.setChildIndex(this._rightBottomBtn,this._rightBottomBtn.parent.numChildren - 1);
         this._leftTopBtn.parent.setChildIndex(this._leftTopBtn,this._leftTopBtn.parent.numChildren - 1);
         this._xBtn.parent.setChildIndex(this._xBtn,this._xBtn.parent.numChildren - 1);
      }
      
      private function allBtnOverHandler(param1:MouseEvent) : void
      {
         switch(param1.currentTarget)
         {
            case this._leftBottomBtn:
               this.startDragging(-1,1);
               break;
            case this._rightBottomBtn:
               this.startDragging(1,1);
               break;
            case this._leftTopBtn:
               this.startDragging(-1,-1);
         }
      }
      
      private function allBtnOutHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget != this._xBtn)
         {
            this._ShouldBeDragging = false;
            this.bringButtonsToFront();
         }
      }
      
      private function magnify(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._zoomedIn)
         {
            this.stopDrag();
            if(this._eBook)
            {
               this._eBook.scaleX -= 1.42;
               this._eBook.scaleY -= 1.42;
               this._eBook.x = 450;
               this._eBook.y = 275;
               this._zoomBtn.magnifyBtnPlus.visible = true;
               this._zoomBtn.magnifyBtnMinus.visible = false;
            }
            else
            {
               this.scaleX -= 1.42;
               this.scaleY -= 1.42;
               this.x = 450;
               this.y = 275;
            }
            this._zoomedIn = false;
         }
         else
         {
            if(this._eBook)
            {
               this._eBook.scaleX += 1.42;
               this._eBook.scaleY += 1.42;
               this._zoomBtn.magnifyBtnPlus.visible = false;
               this._zoomBtn.magnifyBtnMinus.visible = true;
            }
            else
            {
               this.scaleX += 1.42;
               this.scaleY += 1.42;
            }
            this._zoomedIn = true;
         }
      }
      
      private function allBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == this._xBtn || param1.currentTarget.name == "bx")
         {
            if(this._closeCallback != null)
            {
               this._closeCallback();
            }
            else
            {
               this.destroy();
            }
            return;
         }
         if(this._currPageLoaded && this._currPageVarsLoaded)
         {
            this._pageDrag = true;
            if(param1.currentTarget == this._leftTopBtn || param1.currentTarget == this._leftBottomBtn)
            {
               this._rightBottomBtn.visible = this._xBtn.visible = false;
            }
            else
            {
               this._leftBottomBtn.visible = this._leftTopBtn.visible = false;
            }
         }
      }
      
      private function allBtnUpHandler(param1:MouseEvent) : void
      {
         if(this._playFlipSound)
         {
            AJAudio.playNewspaperSound();
         }
         switch(param1.currentTarget)
         {
            case this._leftBottomBtn:
               this.stopDragging(-1);
               break;
            case this._rightBottomBtn:
               this.stopDragging(1);
               break;
            case this._leftTopBtn:
               this.stopDragging(-1);
         }
      }
      
      private function onEnterFrame(param1:Event) : void
      {
         var _loc2_:Number = NaN;
         if(this._flipInProgress == 1)
         {
            this.flipAuto(this.range0to1(this._pageOffset = this._pageOffset + this._autoStepSpeed));
         }
         else
         {
            _loc2_ = this.getPageRatio();
            this._step = (_loc2_ - this._pageFlipPercent) * this._dragSmoothness;
            this._pageFlipPercent += this._step;
            this.renderPageFlip(this._pageFlipPercent);
            if(!this._ShouldBeDragging)
            {
               if(this._pageFlipPercent < this._snapDistance || this._pageFlipPercent < 0.25)
               {
                  this.renderPageFlip(0);
                  this._pageOffset = 0;
                  this.flipComplete();
               }
               else if(this._pageFlipPercent > 1 - this._snapDistance)
               {
                  this.renderPageFlip(1);
                  this._pageOffset = 1;
                  this.flipComplete();
               }
            }
         }
      }
      
      private function jbUserVarIdForPageName(param1:String) : int
      {
         switch(param1)
         {
            case JB_BAHARI_BAY_NAME:
               return JB_BAHARI_BAY_UV;
            case JB_CRYSTAL_REEF_NAME:
               return JB_CRYSTAL_REEF_UV;
            case JB_DEEP_BLUE_NAME:
               return JB_DEEP_BLUE_UV;
            case JB_KANI_COVE_NAME:
               return JB_KANI_COVE_UV;
            case JB_LTOZ_NAME:
               return JB_LTOZ_UV;
            case JB_SHIVEER_NAME:
               return JB_SHIVEER_UV;
            case JB_SAREPIA_NAME:
               return JB_SAREPIA_UV;
            case JB_APPONDALE_NAME:
               return JB_APPONDALE_UV;
            case JB_CORALCANYONS_NAME:
               return JB_CORALCANYONS_UV;
            case JB_CRYSTAL_SANDS_NAME:
               return JB_CRYSTAL_SANDS_UV;
            case JB_BIRDS_PARADISE_NAME:
               return JB_BIRDS_PARADISE_UV;
            case JB_OUTBACK_NAME:
               return JB_OUTBACK_UV;
            default:
               return -1;
         }
      }
   }
}

