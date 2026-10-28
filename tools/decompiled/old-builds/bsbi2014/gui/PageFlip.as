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
      
      private static const AJ_EBOOK_MEDIA_ID:int = 566;
      
      private static const RECTANGULAR_EBOOK_MEDIA_ID:int = 878;
      
      private static const RECTANGULAR_AJ_EBOOK_MEDIA_ID:int = 3006;
      
      private static const JOURNEYBOOK_PAGES_ID:int = 1184;
      
      private static const JOURNEYBOOK_MEDIA_ID:int = 1183;
      
      private static const INFO_POPUP_MEDIA_ID:int = 1201;
      
      private static const MEMBER_BOOK_MEDIA_ID:int = 3580;
      
      private static const MEMBER_BOOK_PAGES_ID:int = 3581;
      
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
      
      private static const EBOOK_OTTER_STAMPS_UV:int = 381;
      
      private static const EBOOK_PANDA_STAMPS_UV:int = 401;
      
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
      
      private static const EBOOK_OTTER_NAME:String = "Otters";
      
      private static const EBOOK_PANDA_NAME:String = "Panda";
      
      private static const EBOOK_OTTER_NUM_STAMPS:int = 7;
      
      private static const EBOOK_PANDA_NUM_STAMPS:int = 4;
      
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
      
      private var _isAJEBook:Boolean;
      
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
      
      private var _numButtonsToLoad:int;
      
      private var _isAJMemberBook:Boolean;
      
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
      
      public function init(initGuiLayer:DisplayLayer, pageIds:Array = null, isSinglePageFlip:Boolean = false, initCloseCallback:Function = null, initFlipCallback:Function = null, isRectangularEbook:Boolean = false, isAJEBook:Boolean = false, enableDragging:Boolean = false, initIsJourneyBook:Boolean = false, initPageNumToOpen:int = 1, showInfoPopup:Boolean = false) : void
      {
         var soundMediaHelper:MediaHelper = null;
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
         this._isSinglePF = isSinglePageFlip;
         this._enableDragging = enableDragging;
         this._closeCallback = initCloseCallback;
         this._flipCallback = initFlipCallback;
         this._isJourneyBook = initIsJourneyBook;
         this._pageNameArray = [];
         this._loadedPageNumber = [];
         this._pageNumToOpen = initPageNumToOpen;
         this._popupLayer = initGuiLayer;
         this._isRectangular = isRectangularEbook;
         this._isAJEBook = isAJEBook;
         this._isAJMemberBook = false;
         this._pageHolderViews = new Array();
         this._showInfoPopup = showInfoPopup;
         this._pagesArray = pageIds;
         if(this._isJourneyBook && !AJAudio.hasLoadedJourneyBookBookSfx)
         {
            soundMediaHelper = new MediaHelper();
            soundMediaHelper.init(JOURNEYBOOK_SOUNDS_ID,this.onLoadJBSounds);
            this._pageHolderViews.push(soundMediaHelper);
         }
         else
         {
            this.loadHolderMovieClips();
         }
      }
      
      private function openPageFlip() : void
      {
         var i:int = 0;
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
            for(i = 1; i < this._pageNumToOpen; i++)
            {
               this._pageNumber = this.fixPageNum(this._currentPage + 2);
               this._currentPage = this._pageNumber;
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
         if(Boolean(this._eBook))
         {
            this.x = 0;
            this.y = 0;
            this._popupLayer.addChild(this._eBook);
            this._eBook.x = MainFrame.VIEW_WIDTH * 0.5;
            this._eBook.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._eBook.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
            this._eBook.addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false,0,true);
            this._eBook.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
            if(Boolean(this._xBtn))
            {
               this._xBtn.visible = false;
            }
            this._eBook.itemWindow.addChild(this);
            DarkenManager.darken(this._eBook);
         }
         else if(Boolean(this._journeyBook))
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
         if(Boolean(this._eBook))
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
         if(Boolean(this._eBook))
         {
            DarkenManager.unDarken(this._eBook);
            this._popupLayer.removeChild(this._eBook);
            this._popupLayer.removeChild(this._zoomBtn);
            this._zoomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.magnify);
         }
         else if(Boolean(this._journeyBook))
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
         if(Boolean(this._infoPopup))
         {
            this.onInfoPopupClose(null);
         }
         KeepAlive.stopKATimer(this._rightBottomBtn);
         this.removeListeners();
         this._buttonsView = null;
         this._mediaViews = null;
         this._loadedPages = null;
         if(Boolean(this._eBook))
         {
            while(this._eBook.numChildren > 0)
            {
               this._eBook.removeChildAt(0);
            }
         }
         else if(Boolean(this._journeyBook))
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
         if(Boolean(this._pageFlipBase))
         {
            this._pageFlipBase.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
         }
         if(this._buttonsLoaded == this._numButtonsToLoad)
         {
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler);
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler);
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._leftBottomBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
            this._rightBottomBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
            this._xBtn.removeEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler);
         }
         if(Boolean(this._eBook))
         {
            this._eBook.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
            this._eBook.removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
            this._eBook.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler);
            this._zoomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.magnify);
         }
         if(Boolean(this._journeyBook))
         {
            this._journeyBook.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         }
      }
      
      private function onLoadJBSounds(img:MovieClip) : void
      {
         var currLoaderAppDomain:ApplicationDomain = null;
         if(Boolean(img))
         {
            if(!AJAudio.hasLoadedJourneyBookBookSfx)
            {
               currLoaderAppDomain = img.loaderInfo.applicationDomain;
               AJAudio.loadSfx("JBBookFactClose",currLoaderAppDomain.getDefinition("JBBookFactClose") as Class,0.6);
               AJAudio.loadSfx("JBBookFactOpen",currLoaderAppDomain.getDefinition("JBBookFactOpen") as Class,0.6);
               AJAudio.hasLoadedJourneyBookBookSfx = true;
            }
            this._pageHolderViews = [];
            this.loadHolderMovieClips();
         }
      }
      
      private function loadHolderMovieClips() : void
      {
         var id:int = 0;
         var lastPageId:int = 0;
         var bookCoverId:int = -1;
         if(this._isSinglePF)
         {
            if(this._isJourneyBook)
            {
               id = lastPageId = JOURNEYBOOK_PAGES_ID;
               bookCoverId = JOURNEYBOOK_MEDIA_ID;
            }
            else
            {
               id = SINGLE_PAGE_PAGES_ID;
               lastPageId = SINGLE_PAGE_LAST_PAGE_ID;
            }
         }
         else if(this._isAJEBook)
         {
            bookCoverId = this._isRectangular ? RECTANGULAR_AJ_EBOOK_MEDIA_ID : AJ_EBOOK_MEDIA_ID;
            id = lastPageId = this._isRectangular ? EBOOK_PAGES_ID_TALL : EBOOK_PAGES_ID;
         }
         else if(this._isAJMemberBook)
         {
            bookCoverId = MEMBER_BOOK_MEDIA_ID;
            id = lastPageId = MEMBER_BOOK_PAGES_ID;
         }
         else
         {
            bookCoverId = this._isRectangular ? RECTANGULAR_EBOOK_MEDIA_ID : EBOOK_MEDIA_ID;
            id = lastPageId = this._isRectangular ? EBOOK_PAGES_ID_TALL : EBOOK_PAGES_ID;
         }
         if(!this._isJourneyBook)
         {
            this._currPageVarsLoaded = true;
         }
         var blankPageMediaHelper:MediaHelper = new MediaHelper();
         blankPageMediaHelper.init(id,this.pageHolderCallback);
         this._pageHolderViews[0] = blankPageMediaHelper;
         blankPageMediaHelper = new MediaHelper();
         blankPageMediaHelper.init(id,this.pageHolderCallback);
         this._pageHolderViews[1] = blankPageMediaHelper;
         blankPageMediaHelper = new MediaHelper();
         blankPageMediaHelper.init(id,this.pageHolderCallback);
         this._pageHolderViews[2] = blankPageMediaHelper;
         blankPageMediaHelper = new MediaHelper();
         blankPageMediaHelper.init(id,this.pageHolderCallback);
         this._pageHolderViews[3] = blankPageMediaHelper;
         blankPageMediaHelper = new MediaHelper();
         blankPageMediaHelper.init(lastPageId,this.pageHolderCallback,true);
         this._pageHolderViews[4] = blankPageMediaHelper;
         if(bookCoverId > -1)
         {
            blankPageMediaHelper = new MediaHelper();
            blankPageMediaHelper.init(bookCoverId,this.pageHolderCallback,true);
            this._pageHolderViews[5] = blankPageMediaHelper;
         }
      }
      
      private function pageHolderCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(Boolean(img.passback) && img.mediaHelper == this._pageHolderViews[4])
            {
               this._blankPageLast = img;
            }
            else if(Boolean(img.passback) && img.mediaHelper == this._pageHolderViews[5])
            {
               if(img.mediaHelper.id == JOURNEYBOOK_MEDIA_ID)
               {
                  this._journeyBook = MovieClip(img.getChildAt(0));
               }
               else
               {
                  this._eBook = MovieClip(img.getChildAt(0));
               }
            }
            else if(this._blankPage1 == null)
            {
               this._blankPage1 = img;
            }
            else if(this._blankPage2 == null)
            {
               this._blankPage2 = img;
            }
            else if(this._blankPage3 == null)
            {
               this._blankPage3 = img;
            }
            else if(this._blankPage4 == null)
            {
               this._blankPage4 = img;
            }
            if(Boolean(img.mediaHelper))
            {
               img.mediaHelper.destroy();
               delete img.mediaHelper;
            }
            ++this._pagesLoaded;
         }
         if(this._pagesLoaded == this._pageHolderViews.length)
         {
            this.openPageFlip();
         }
      }
      
      private function infoPopupCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._infoPopup = MovieClip(img.getChildAt(0));
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
      
      private function onInfoPopupClose(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         this._infoPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onImageDown);
         this._infoPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInfoPopupClose);
         this._popupLayer.removeChild(this._infoPopup);
         this._infoPopup = null;
      }
      
      private function loadButtons() : void
      {
         var buttonsMediaHelper:MediaHelper = new MediaHelper();
         buttonsMediaHelper = new MediaHelper();
         buttonsMediaHelper.init(RIGHT_TOP_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[1] = buttonsMediaHelper;
         buttonsMediaHelper = new MediaHelper();
         buttonsMediaHelper.init(LEFT_BOTTOM_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[2] = buttonsMediaHelper;
         buttonsMediaHelper = new MediaHelper();
         buttonsMediaHelper.init(RIGHT_BOTTOM_BTN_ID,this.buttonsCallback,true);
         this._buttonsView[3] = buttonsMediaHelper;
         if(Boolean(this._eBook))
         {
            buttonsMediaHelper = new MediaHelper();
            buttonsMediaHelper.init(ZOOM_BTN_ID,this.buttonsCallback,true);
            this._buttonsView[4] = buttonsMediaHelper;
            this._numButtonsToLoad = 4;
         }
         else
         {
            this._numButtonsToLoad = 3;
         }
      }
      
      private function buttonsCallback(img:MovieClip) : void
      {
         for(var i:int = 0; i < this._buttonsView.length; i++)
         {
            if(this._buttonsView[i] == img.mediaHelper)
            {
               this._buttonsView[i] = img;
               ++this._buttonsLoaded;
            }
         }
         if(Boolean(img.mediaHelper))
         {
            img.mediaHelper.destroy();
            delete img.mediaHelper;
         }
         if(this._buttonsLoaded == this._numButtonsToLoad)
         {
            this.initBtns();
         }
      }
      
      private function loadPages(pageNum:int) : void
      {
         var pagesMediaHelper:MediaHelper = new MediaHelper();
         if(this._isSinglePF)
         {
            pagesMediaHelper.init(this._pagesArray[pageNum - 1],this.mediaHelperCallback,pageNum);
            this._mediaViews[pageNum - 1] = pagesMediaHelper;
         }
         else
         {
            pagesMediaHelper.init(this._pagesArray[pageNum - 2],this.mediaHelperCallback,pageNum);
            this._mediaViews[pageNum - 2] = pagesMediaHelper;
            pagesMediaHelper = new MediaHelper();
            pagesMediaHelper.init(this._pagesArray[pageNum - 1],this.mediaHelperCallback,pageNum);
            this._mediaViews[pageNum - 1] = pagesMediaHelper;
         }
      }
      
      private function mediaHelperCallback(img:MovieClip) : void
      {
         var j:int = 0;
         var currPageNum:int = 0;
         var pageNumber:int = 0;
         var print1:MovieClip = null;
         if(Boolean(this._pageFlipBase))
         {
            for(j = 0; j < this._mediaViews.length; j++)
            {
               if(this._mediaViews[j] == img.mediaHelper)
               {
                  delete this._mediaViews[j];
                  ++this._numberOfLoadedPages;
                  if(this._isSinglePF)
                  {
                     currPageNum = this._pageFlipIncrement + j * 2;
                     this._loadedPages[this._pageFlipIncrement + j * 2] = img;
                  }
                  else
                  {
                     currPageNum = this._pageFlipIncrement + j;
                     if(this._isAJEBook)
                     {
                        if(this._isRectangular)
                        {
                           img.scaleX = 0.499;
                           img.scaleY = 0.499;
                        }
                        else
                        {
                           img.scaleX = 0.413;
                           img.scaleY = 0.413;
                        }
                     }
                     this._loadedPages[currPageNum] = img;
                  }
                  this.checkPageForButtons(img,currPageNum);
                  if((this._flipInProgress == 1 || this._pageFlipComplete == true) && this._flipDirection == 1)
                  {
                     this._currentPage = this._pageNumber;
                  }
                  if(int(this._numberOfFlips) == img.passback)
                  {
                     if(this._numberOfLoadedPages == this._pageFlipIncrement)
                     {
                        this._numberOfLoadedPages = 0;
                        this._loadedPageNumber[img.passback - this._pageFlipIncrement] = true;
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
                           pageNumber = this._flipDirection == 1 ? int(this._pageNumber - 0.5) : int(this._pageNumber + 0.5);
                           if(this._loadedPages[pageNumber] != null)
                           {
                              print1 = this._loadedPages[pageNumber];
                              print1.x = -this._flipDirection * this._pageWidth * 0.5;
                              print1.y = -this._vertDir * this._pivotY;
                              this._flippingBottomPage.addChild(print1);
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
            }
         }
      }
      
      private function checkPageForButtons(img:MovieClip, currPageNum:int) : void
      {
         var numChildren:int = 0;
         var i:int = 0;
         var currPage:Object = null;
         var jbDefIds:Array = null;
         var k:int = 0;
         var j:int = 0;
         var grandChild:Object = null;
         var split:Array = null;
         if(Boolean(img))
         {
            numChildren = img.numChildren;
            for(i = 0; i < img.numChildren; i++)
            {
               currPage = img.getChildAt(i);
               if(currPage != null)
               {
                  jbDefIds = [];
                  k = 0;
                  for(j = 0; j < currPage.numChildren; j++)
                  {
                     grandChild = currPage.getChildAt(j);
                     if(grandChild.name.indexOf("movie") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onMovieDown,false,0,true);
                     }
                     else if(grandChild.name.indexOf("jb_title") == 0)
                     {
                        this._pageNameArray[currPageNum] = grandChild.name.substr(9);
                     }
                     else if(grandChild.name.indexOf("jb_gift") == 0)
                     {
                        currPage.JBGift = grandChild;
                        currPage.JBGift.id = grandChild.name.substr(8);
                     }
                     else if(grandChild.name.indexOf("jb") == 0)
                     {
                        grandChild.jbId = grandChild.name.substr(3);
                        jbDefIds[k++] = grandChild.jbId;
                     }
                     else if(grandChild.name.indexOf("submitBtn") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onSubmitDown,false,0,true);
                     }
                     else if(grandChild.name.indexOf("turnTo") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onTurnToBtn,false,0,true);
                     }
                     else if(grandChild.name.indexOf("linkTo") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onLinkToBtn,false,0,true);
                     }
                     else if(grandChild.name.indexOf("joinRoom") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinRoomBtn,false,0,true);
                     }
                     else if(grandChild.name.indexOf("joinParty") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onJoinPartyBtn,false,0,true);
                     }
                     else if(grandChild.name == "imgPoll")
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onImgPoll,false,0,true);
                     }
                     else if(grandChild.name.indexOf("loadPopup") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onLoadPopup,false,0,true);
                     }
                     else if(grandChild.name.indexOf("gameBtn") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onGameBtn,false,0,true);
                     }
                     else if(grandChild.name.indexOf("petBtn") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetBtn,false,0,true);
                     }
                     else if(grandChild.name.indexOf("badgeCont") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.MOUSE_DOWN,this.onBadgeCont,false,0,true);
                        split = grandChild.name.split("_");
                        if(Boolean(split) && split.length > 0)
                        {
                           grandChild.badgePageName = split[1];
                           grandChild.badgeId = int(split[2]);
                        }
                        else
                        {
                           grandChild.badgeId = 0;
                           grandChild.badgePageName = "";
                        }
                        if(gMainFrame.userInfo.userVarCache.getUserVarValueById(this.eBookUserVarIdForPageName(grandChild.badgePageName)) != -1 && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(this.eBookUserVarIdForPageName(grandChild.badgePageName),grandChild.badgeId)))
                        {
                           grandChild.gotoAndStop("color");
                        }
                     }
                     else if(grandChild.name.indexOf("expandTxt") == 0)
                     {
                        grandChild.addEventListener(MouseEvent.ROLL_OVER,this.onExpandRollOverOut,false,0,true);
                        grandChild.addEventListener(MouseEvent.ROLL_OUT,this.onExpandRollOverOut,false,0,true);
                     }
                  }
                  if(jbDefIds.length > 0)
                  {
                     currPage.numJBItemsTotal = jbDefIds.length;
                     currPage.numJBItemsSeen = 0;
                     currPage.numJBItemsLoaded = 0;
                     for(k = 0; k < jbDefIds.length; k++)
                     {
                        NGFactManager.requestJourneyBookFactDef(jbDefIds[k],this.onJBFactDefReceived,currPageNum);
                     }
                  }
                  else
                  {
                     this._currPageVarsLoaded = true;
                  }
               }
            }
         }
      }
      
      private function onPetBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         PetManager.openPetFinder(PetManager.petNameForDefId(evt.currentTarget.name.split("_")[1]));
      }
      
      private function onBadgeCont(evt:MouseEvent) : void
      {
         var currUserVarId:int = 0;
         var numStamps:int = 0;
         var currUserVarValue:int = 0;
         evt.stopPropagation();
         if(evt.currentTarget.currentFrameLabel != "color")
         {
            evt.currentTarget.gotoAndPlay("play");
            currUserVarId = this.eBookUserVarIdForPageName(evt.currentTarget.badgePageName);
            numStamps = this.eBookNumStampsForUserVarId(currUserVarId);
            currUserVarValue = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(currUserVarId));
            if(currUserVarValue != -1 && !gMainFrame.userInfo.userVarCache.isBitSet(currUserVarId,evt.currentTarget.badgeId) && gMainFrame.userInfo.userVarCache.numBitsSet(currUserVarValue,numStamps) + 1 == numStamps)
            {
               GuiManager.setupGemGiftPopup(100);
            }
            AchievementXtCommManager.requestSetUserVar(currUserVarId,evt.currentTarget.badgeId);
         }
      }
      
      private function onExpandRollOverOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.type == MouseEvent.ROLL_OUT)
         {
            evt.currentTarget.gotoAndPlay("off");
         }
         else
         {
            evt.currentTarget.gotoAndPlay("on");
         }
      }
      
      private function onGameBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._gameLaunchObj = {"typeDefId":evt.currentTarget.name.split("_")[1]};
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
      
      private function onMovieDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         var contentArray:Array = new Array();
         contentArray = evt.currentTarget.name.split("_");
         var genericListId:int = int(contentArray[1]);
         var shouldRepeat:Boolean = contentArray.length >= 3 ? contentArray[2] == true : false;
         var frameMsg:String = contentArray.length >= 4 ? contentArray[3] : null;
         var width:int = contentArray.length >= 5 ? int(contentArray[4]) : int(null);
         var height:int = contentArray.length >= 6 ? int(contentArray[5]) : int(null);
         GenericListGuiManager.genericListVolumeClicked(genericListId,{
            "shouldRepeat":shouldRepeat,
            "msg":frameMsg,
            "width":width,
            "height":height
         });
      }
      
      private function onSubmitDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.showLoadingSpiral(true);
         FeedbackManager.openFeedbackPopup(4);
      }
      
      private function onTurnToBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var currPageToTurnTo:int = int(evt.currentTarget.name.split("_")[1]);
         this._vertDir = 1;
         this.turnTo(this._currentPage + currPageToTurnTo * 2,Boolean(currPageToTurnTo % 2));
      }
      
      private function onLinkToBtn(evt:MouseEvent) : void
      {
         var splitArray:Array;
         var currName:String;
         var requestString:String;
         var request:URLRequest = null;
         evt.stopPropagation();
         splitArray = evt.currentTarget.name.split("_");
         currName = splitArray[1];
         requestString = "";
         if(currName == "blog")
         {
            if(splitArray.length > 2)
            {
               requestString = "http://dailyexplorer.animaljam.com/" + splitArray[2].split("$").join("-");
            }
            else
            {
               requestString = "http://dailyexplorer.animaljam.com/";
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
         else if(currName == "blogCat")
         {
            requestString = "http://dailyexplorer.animaljam.com/?cat=" + splitArray[2];
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
      
      private function onJoinRoomBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var roomName:Array = evt.currentTarget.name.replace("joinRoom_","").split("$")[0].split("_");
         new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(14775,LocalizationManager.translateIdOnly(roomName[0])),true,this.onConfirmJoinRoom,evt.currentTarget.name);
      }
      
      private function onConfirmJoinRoom(o:Object) : void
      {
         var splitRoom:Array = null;
         var roomName:String = null;
         var roomAndSpawn:Array = null;
         if(Boolean(o.status))
         {
            splitRoom = o.passback.split("$");
            splitRoom.shift();
            roomName = splitRoom.join("$");
            roomName = roomName.replace("$",".");
            roomAndSpawn = roomName.split("$");
            roomName = roomAndSpawn[0];
            roomName = roomName.toLowerCase() + "#" + RoomManagerWorld.instance.shardId;
            if(roomName != gMainFrame.server.getCurrentRoomName())
            {
               if(roomAndSpawn.length == 2)
               {
                  RoomManagerWorld.instance.setGotoSpawnPoint(roomAndSpawn[1].toLowerCase());
               }
               DarkenManager.showLoadingSpiral(true);
               RoomXtCommManager.sendRoomJoinRequest(roomName);
            }
         }
      }
      
      private function onJoinPartyBtn(evt:MouseEvent) : void
      {
         var defId:int = int(evt.currentTarget.name.split("_")[1]);
         new SBYesNoPopup(this._popupLayer,LocalizationManager.translateIdAndInsertOnly(14776,LocalizationManager.translateIdOnly(PartyManager.getPartyDef(defId).titleStrId)),true,this.onConfirmJoinParty,defId);
      }
      
      private function onConfirmJoinParty(o:Object) : void
      {
         if(Boolean(o.status))
         {
            gMainFrame.server.setXtObject_Str("sj",[o.passback]);
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onImgPoll(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         ImagePoll.displayPoll(ImagePoll.DEN_ITEM_VOTING_VAR_ID,ImagePoll.DEN_POLL_MEDIA_ID,0,3,1);
      }
      
      private function onLoadPopup(evt:MouseEvent) : void
      {
         var popupMediaHelper:MediaHelper = null;
         evt.stopPropagation();
         if(!this._genericPopup)
         {
            DarkenManager.showLoadingSpiral(true);
            popupMediaHelper = new MediaHelper();
            popupMediaHelper.init(evt.currentTarget.name.split("_")[1],this.onPopupLoaded);
         }
         else
         {
            this._popupLayer.addChild(this._genericPopup);
            DarkenManager.darken(this._genericPopup);
         }
      }
      
      private function onPopupLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            this._genericPopup = MovieClip(img.getChildAt(0));
            this._genericPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
            this._genericPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupClose,false,0,true);
            this._popupLayer.addChild(this._genericPopup);
            this._genericPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._genericPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            DarkenManager.darken(this._genericPopup);
         }
      }
      
      private function onPopupClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._popupLayer.removeChild(this._genericPopup);
         DarkenManager.unDarken(this._genericPopup);
      }
      
      private function onJBItemDown(evt:MouseEvent) : void
      {
         NGFactManager.showJourneyBookFact(evt.currentTarget.jbId);
      }
      
      private function onJBItemOver(evt:MouseEvent) : void
      {
         if(evt.currentTarget.itemName != "")
         {
            GuiManager.toolTip.init(this._popupLayer,evt.currentTarget.itemName,evt.currentTarget.x + MainFrame.VIEW_WIDTH * 0.5,evt.currentTarget.y + MainFrame.VIEW_HEIGHT * 0.5);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function onJBItemOut(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onJBGiftDown(evt:MouseEvent) : void
      {
         var currItemDef:Object = null;
         var giftType:int = 0;
         if(evt.currentTarget.id.indexOf("d") == 0)
         {
            currItemDef = DenXtCommManager.getDenItemDef(evt.currentTarget.id.substr(2));
            giftType = GiftPopup.GIFT_TYPE_DEN_ACC;
         }
         else
         {
            currItemDef = ItemXtCommManager.getItemDef(evt.currentTarget.id.substr(2));
            giftType = GiftPopup.GIFT_TYPE_CLOTHING;
         }
         if(Boolean(this._jbGiftPopup))
         {
            this._jbGiftPopup.destroy();
            this._jbGiftPopup = null;
         }
         this._jbGiftPopup = new GiftPopup();
         this._jbGiftPopup.init(this._popupLayer,evt.currentTarget.getImage(),currItemDef.name,evt.currentTarget.id.substr(2),GiftPopup.POPUP_TYPE_JAG,giftType,this.onKeepJBGift,this.onRejectJBGift,this.onCloseJBGift);
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
         if(Boolean(this._jbGiftPopup))
         {
            this._jbGiftPopup.destroy();
            this._jbGiftPopup = null;
         }
      }
      
      private function onSetUserVarResponse(userVarId:int, value:int) : void
      {
         DarkenManager.showLoadingSpiral(false);
         var pageNumber:int = this.fixPageNum(this._currentPage) + 0.5;
         var currPage:MovieClip = MovieClip(this._loadedPages[pageNumber].getChildAt(0));
         if(Boolean(currPage.JBGift))
         {
            currPage.JBGift.enable(false);
            currPage.JBGift.removeEventListener(MouseEvent.MOUSE_DOWN,this.onJBGiftDown);
         }
         --JBManager.numUnclaimedGifts;
         GuiManager.updateJBIcon();
         if(Boolean(this._jbGiftPopup))
         {
            this._jbGiftPopup.destroy();
            this._jbGiftPopup = null;
         }
      }
      
      private function onJBFactDefReceived(factDef:Object, pageNumber:int) : void
      {
         var currPage:MovieClip = null;
         var animalBtn:MovieClip = null;
         if(Boolean(this._pageFlipBase))
         {
            currPage = MovieClip(this._loadedPages[pageNumber].getChildAt(0));
            animalBtn = currPage["jb_" + factDef.id];
            if(!animalBtn)
            {
               currPage.numJBItemsLoaded = currPage.numJBItemsTotal;
               this._currPageVarsLoaded = true;
               this.showButtons();
               return;
            }
            ++currPage.numJBItemsLoaded;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(factDef.userVarId,JB_PAGE_SEEN) && currPage.numJBItemsLoaded == 1)
            {
               JBManager.removeUnseenPage(factDef.userVarId);
               AchievementXtCommManager.requestSetUserVar(factDef.userVarId,JB_PAGE_SEEN);
            }
            if(gMainFrame.userInfo.userVarCache.isBitSet(factDef.userVarId,factDef.bitIdx))
            {
               ++currPage.numJBItemsSeen;
               animalBtn.enable();
               animalBtn.itemName = new String(LocalizationManager.translateIdOnly(factDef.title));
               GuiManager.toolTip.resetTimerAndSetVisibility();
               animalBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onJBItemDown,false,0,true);
               animalBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onJBItemOver,false,0,true);
               animalBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onJBItemOut,false,0,true);
               if(currPage.numJBItemsSeen == currPage.numJBItemsTotal && Boolean(currPage.JBGift))
               {
                  if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(factDef.userVarId,JB_KEEP_GIFT)) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(factDef.userVarId,JB_DISCARD_GIFT)))
                  {
                     currPage.JBGift.enable(false);
                  }
                  else
                  {
                     currPage.JBGift.enable(true);
                     currPage.JBGift.addEventListener(MouseEvent.MOUSE_DOWN,this.onJBGiftDown,false,0,true);
                  }
               }
            }
            if(currPage.numJBItemsLoaded == currPage.numJBItemsTotal)
            {
               this._currPageVarsLoaded = true;
               if(this._currPageLoaded && this._flipInProgress == 0)
               {
                  this.flipComplete();
               }
               else if(this._flipInProgress == 0 && this._pageFlipComplete == false)
               {
                  if(Math.round(this._currentPage) == pageNumber)
                  {
                     this._flipCallback(this._pageNameArray[pageNumber]);
                  }
               }
            }
         }
      }
      
      private function onImageDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function removeIfChildAdded(displayObjectContainer:DisplayObjectContainer, displayObject:DisplayObject) : void
      {
         for(var i:int = 0; i < displayObjectContainer.numChildren; i++)
         {
            if(displayObjectContainer.getChildAt(i) == displayObject)
            {
               displayObjectContainer.removeChildAt(i);
               return;
            }
         }
      }
      
      private function mouseDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._zoomedIn)
         {
            if(Boolean(this._eBook))
            {
               this._eBook.startDrag(false,this._fullPageBounds);
            }
            else
            {
               this.startDrag(false,this._fullPageBounds);
            }
         }
      }
      
      private function mouseUpHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._zoomedIn)
         {
            this.stopDrag();
         }
      }
      
      private function removeMovieClip(mc:DisplayObject) : void
      {
         if(Boolean(mc))
         {
            if(Boolean(mc.parent))
            {
               mc.parent.removeChild(mc);
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
      
      private function range0to1(i:Number) : Number
      {
         return i > 1 ? 1 : (i < 0 ? 0 : i);
      }
      
      private function makeShade(pageDrawingTarget:Sprite, xQuadrant:Number, yQuadrant:Number) : void
      {
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
      
      private function makeShadow(pageDrawingTarget:Sprite, xQuadrant:Number) : void
      {
         var colors:Array = null;
         var alphas:Array = null;
         var ratios:Array = null;
         var ratio:Number = NaN;
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
      
      private function startFlip(pageNumber:Number, flipDirection:Number, numberOfFlips:int) : void
      {
         this._flipInProgress = 1;
         if(flipDirection == 1)
         {
            if(this._isSinglePF)
            {
               this._numberOfFlips += numberOfFlips;
            }
            else
            {
               this._numberOfFlips += numberOfFlips * 2;
            }
         }
         else if(this._isSinglePF)
         {
            this._numberOfFlips -= numberOfFlips;
         }
         else
         {
            this._numberOfFlips -= numberOfFlips * 2;
         }
         this._numberOfFlips = Math.min(this._numberOfPages,this._numberOfFlips);
         this._pageFlipComplete = false;
         if(!this._loadedPageNumber[this._numberOfFlips - this._pageFlipIncrement])
         {
            this.initPage(pageNumber,flipDirection,this._vertDir);
            if(this._isJourneyBook)
            {
               this._currPageVarsLoaded = false;
            }
            this._currPageLoaded = false;
            this.loadPages(this._numberOfFlips);
         }
         else
         {
            this.initPage(pageNumber,flipDirection,this._vertDir);
            this._currentPage = pageNumber;
         }
         this._startX = flipDirection * this._pageWidth;
         if(this._showCornerBtns)
         {
            this._rightBottomBtn.visible = this._leftBottomBtn.visible = false;
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
         var m:Number = -this._vertDir * (this._pageWidth + this._pageHeight * 0.5);
         var e:Number = this._pageHeight / 2;
         if(this._showCornerBtns && this._buttonsLoaded == this._numButtonsToLoad)
         {
            this._rightBottomBtn.y = this._leftBottomBtn.y = m + e;
            this._xBtn.y = m - e + this._xBtn.height;
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
                  this._leftBottomBtn.x = -this._pageWidth + this._leftBottomBtn.width;
               }
            }
            this.bringButtonsToFront();
         }
      }
      
      private function flipAuto(goalR:Number) : void
      {
         this._step = (goalR - this._pageFlipPercent) * this._dragSmoothness;
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
      
      public function turnTo(pageNumber:Number, shouldFixPageNum:Boolean = true) : void
      {
         var difference:int = 0;
         var d:int = 0;
         if(shouldFixPageNum)
         {
            this._pageNumber = this.fixPageNum(pageNumber);
         }
         else
         {
            this._pageNumber = pageNumber;
         }
         if(this._pageNumber != this._currentPage)
         {
            if(this._flipInProgress == 0)
            {
               difference = Math.round((this._pageNumber - this._currentPage) * 0.5);
               d = this._pageNumber > this._currentPage ? 1 : -1;
               this._pageTurnedTo += difference;
               this.startFlip(this._pageNumber,d,Math.abs(difference));
            }
         }
      }
      
      private function fixPageNum(pageNum:Number) : Number
      {
         var mod:int = pageNum % 2;
         if(mod == 0)
         {
            return pageNum + 0.5;
         }
         if(mod == 1)
         {
            return pageNum - 0.5;
         }
         return pageNum;
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
      
      public function flipTo(targPage:Number) : void
      {
         targPage = this.fixPageNum(targPage);
         if(targPage > this._currentPage)
         {
            this._directionAfterFlip = 1;
         }
         else
         {
            if(targPage >= this._currentPage)
            {
               return;
            }
            this._directionAfterFlip = -1;
         }
         this._bFlipAuto = true;
         this._autoFlipTargetPage = targPage;
         this.startFlip(this._currentPage + this._directionAfterFlip * 2,this._directionAfterFlip,0);
      }
      
      private function drawPage(pageDrawingTarget:MovieClip, xQuadrant:Number, yQuadrant:Number) : void
      {
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
      
      private function renderPageFlip(percent:Number) : void
      {
         var rotation:Number = this._vertDir * this._flipDirection * 45 * percent;
         this._flippingBottomPageMask.rotation = this._flippingTopPageMask.rotation = -rotation;
         this._flippingBottomPage.rotation = this._flippingPageShadowMask.rotation = this._vertDir * (this._flipDirection * 90) - rotation * 2;
         this._flippingShadow.rotation = this._shadowsShadow.rotation = this._vertDir * (this._flipDirection * 45) - rotation;
      }
      
      private function showButtons() : void
      {
         if(this._flipInProgress == 0)
         {
            if(this._enableDragging)
            {
               this.setupButtonsPositions();
            }
            if(this._showCornerBtns && this._currPageLoaded && this._currPageVarsLoaded && this._buttonsLoaded == this._numButtonsToLoad)
            {
               if(Boolean(this._stationaryLeftPage))
               {
                  this._stationaryLeftPage.visible = true;
               }
               this._rightBottomBtn.alpha = this._leftBottomBtn.alpha = this._xBtn.alpha = 1;
               if(this._isSinglePF && this._currentPage != 0.5 || !this._isSinglePF && this._currentPage != 2.5)
               {
                  this._leftBottomBtn.visible = true;
               }
               else
               {
                  this._leftBottomBtn.visible = false;
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
         if(this._showCornerBtns && this._currPageLoaded && this._currPageVarsLoaded && this._buttonsLoaded == this._numButtonsToLoad)
         {
            if(Boolean(this._stationaryLeftPage))
            {
               this._stationaryLeftPage.visible = true;
            }
            this._rightBottomBtn.alpha = this._leftBottomBtn.alpha = this._xBtn.alpha = 1;
            if(this._isSinglePF && this._currentPage != 0.5 || !this._isSinglePF && this._currentPage != 2.5)
            {
               this._leftBottomBtn.visible = true;
            }
            else
            {
               this._leftBottomBtn.visible = false;
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
         var shade:Sprite = null;
         this.removeIfChildAdded(this._pageFlipBase,this._flippingTopPage);
         this._flippingTopPage = new MovieClip();
         var tempflippingTopPage:MovieClip = new MovieClip();
         var pageNumber:int = this._flipDirection == 1 ? int(this._currentPage + 0.5) : int(this._currentPage - 0.5);
         if(pageNumber <= this._numberOfPages + 0.5)
         {
            if(pageNumber >= this._numberOfPages)
            {
               this.drawPage(tempflippingTopPage,this._flipDirection,this._vertDir);
               this._flippingTopPage.addChild(tempflippingTopPage);
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
               this.drawPage(tempflippingTopPage,this._flipDirection,this._vertDir);
               this._flippingTopPage.addChild(tempflippingTopPage);
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
            if(this._loadedPages[pageNumber] != null)
            {
               this._print = new Sprite();
               this._print = this._loadedPages[pageNumber];
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
               shade = new MovieClip();
               shade.mouseChildren = false;
               shade.mouseEnabled = false;
               this.makeShade(shade,this._flipDirection,this._vertDir);
               this._flippingTopPage.addChild(shade);
               this._pageFlipBase.addChild(this._flippingTopPage);
            }
         }
         this.removeIfChildAdded(this._pageFlipBase,this._flippingBottomPage);
         this._flippingBottomPage = new MovieClip();
         var tempflippingBottomPage:MovieClip = new MovieClip();
         this.drawPage(tempflippingBottomPage,-this._flipDirection,this._vertDir);
         this._flippingBottomPage.addChild(tempflippingBottomPage);
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
         var print1:Sprite = new MovieClip();
         if(this._isSinglePF)
         {
            if(this._flipDirection != 1 || this._isJourneyBook)
            {
               pageNumber = this._flipDirection == 1 ? int(this._pageNumber - 0.5) : int(this._pageNumber + 0.5);
               if(this._loadedPages[pageNumber] != null)
               {
                  print1 = this._loadedPages[pageNumber];
                  print1.x = -this._flipDirection * this._pageWidth * 0.5;
                  print1.y = -this._vertDir * this._pivotY;
                  this._flippingBottomPage.addChild(print1);
               }
               else if(!this._isJourneyBook && this._flipDirection == -1)
               {
                  this._spiralBottomFlippingPage.setNewParent(this._flippingBottomPage,this._flipDirection * this._pageWidth * 0.5,-this._vertDir * this._pivotY);
               }
            }
         }
         else
         {
            pageNumber = this._flipDirection == 1 ? int(this._pageNumber - 0.5) : int(this._pageNumber + 0.5);
            if(!this._ShouldBeDragging && !this._isJourneyBook && this._pageNumber <= this._numberOfPages)
            {
               pageNumber += this._flipDirection * 2;
            }
            if(this._loadedPages[pageNumber] != null)
            {
               print1 = this._loadedPages[pageNumber];
               print1.x = -this._flipDirection * this._pageWidth * 0.5;
               print1.y = -this._vertDir * this._pivotY;
               this._flippingBottomPage.addChild(print1);
            }
            else
            {
               this._spiralBottomFlippingPage.setNewParent(this._flippingBottomPage,-this._flipDirection * this._pageWidth * 0.5,-this._vertDir * this._pivotY);
            }
         }
         this._flippingBottomPage.rotation = -this._flipDirection * this._vertDir * 90;
         this._pageFlipBase.addChild(this._flippingBottomPage);
      }
      
      private function startDragging(flipDirection:Number, vertDir:Number) : void
      {
         this._ShouldBeDragging = true;
         this.initPage(this._currentPage + flipDirection * 2,flipDirection,vertDir);
         if(this._isSinglePF && flipDirection == -1)
         {
            this._startX = 0;
         }
         else
         {
            this._startX = flipDirection * this._pageWidth;
         }
         if(this._showCornerBtns)
         {
            if(flipDirection == -1 && (this._isSinglePF || this._isJourneyBook))
            {
               this._rightBottomBtn.alpha = 0;
            }
            else
            {
               this._rightBottomBtn.alpha = this._leftBottomBtn.alpha = 0;
            }
         }
         this._pageFlipPercent = 0;
         this._pageFlipBase.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      private function initPage(ep:Number, hDir:Number, vDir:Number) : void
      {
         this._pageNumber = ep;
         this._flipDirection = hDir;
         this._vertDir = vDir;
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
      
      private function setStationary(setStationaryOnly:Boolean = false) : void
      {
         var temp:Sprite = null;
         var tempStationaryRightPage:MovieClip = null;
         var temporary:Sprite = null;
         var shade:Sprite = null;
         var pageIndex:int = -1;
         var tempStationaryLeftPage:MovieClip = new MovieClip();
         if(!this._isSinglePF && this._flipInProgress != 1)
         {
            if(Boolean(this._stationaryLeftPage) && Boolean(this._stationaryLeftPage.parent) && this._stationaryLeftPage.parent == this._pageFlipBase)
            {
               pageIndex = this._pageFlipBase.getChildIndex(this._stationaryLeftPage);
            }
            this.removeIfChildAdded(this._pageFlipBase,this._stationaryLeftPage);
            this._stationaryLeftPage = new MovieClip();
            if(this._currentPage != 0.5)
            {
               this.drawPage(tempStationaryLeftPage,-1,this._vertDir);
               this._stationaryLeftPage.addChild(tempStationaryLeftPage);
               this._blankPage1.x = -this._pageWidth * 0.5;
               this._blankPage1.y = -this._vertDir * this._pivotY;
               this._stationaryLeftPage.addChild(this._blankPage1);
               this._pageNumberTxt = this._flipDirection == 1 ? int(this._currentPage - 0.5) : int(this._pageNumber - 0.5);
               if(this._pageNumberTxt != 0)
               {
                  if(this._loadedPages[this._pageNumberTxt] != null)
                  {
                     temp = new MovieClip();
                     temp = this._loadedPages[this._pageNumberTxt];
                     temp.x = -this._pageWidth * 0.5;
                     temp.y = -this._vertDir * this._pivotY;
                     this._stationaryLeftPage.addChild(temp);
                  }
                  else
                  {
                     this._spiralLeftPage.setNewParent(this._stationaryLeftPage,this._pageWidth * 0.5,-this._vertDir * this._pivotY);
                  }
                  this._pageFlipBase.addChild(this._stationaryLeftPage);
                  if(pageIndex != -1)
                  {
                     this._pageFlipBase.setChildIndex(this._stationaryLeftPage,pageIndex);
                  }
                  pageIndex = -1;
                  if(setStationaryOnly)
                  {
                     this._stationaryLeftPage.visible = false;
                  }
               }
            }
         }
         if(this._isJourneyBook)
         {
            if(Boolean(this._stationaryLeftPage) && Boolean(this._stationaryLeftPage.parent) && this._stationaryLeftPage.parent == this._pageFlipBase)
            {
               pageIndex = this._pageFlipBase.getChildIndex(this._stationaryLeftPage);
            }
            this.removeIfChildAdded(this._pageFlipBase,this._stationaryLeftPage);
            this._stationaryLeftPage = new MovieClip();
            this.drawPage(tempStationaryLeftPage,-1,this._vertDir);
            this._stationaryLeftPage.addChild(tempStationaryLeftPage);
            this._blankPage1.scaleX = -1;
            this._blankPage1.x = -this._pageWidth * 0.5;
            this._blankPage1.y = -this._vertDir * this._pivotY;
            this._stationaryLeftPage.addChild(this._blankPage1);
            this._pageFlipBase.addChild(this._stationaryLeftPage);
            if(pageIndex != -1)
            {
               this._pageFlipBase.setChildIndex(this._stationaryLeftPage,pageIndex);
            }
            pageIndex = -1;
         }
         if(Boolean(this._stationaryRightPage) && Boolean(this._stationaryRightPage.parent) && this._stationaryRightPage.parent == this._pageFlipBase)
         {
            pageIndex = this._pageFlipBase.getChildIndex(this._stationaryRightPage);
         }
         this.removeIfChildAdded(this._pageFlipBase,this._stationaryRightPage);
         this._stationaryRightPage = new MovieClip();
         if(this._pageNumber <= this._numberOfPages + 0.5)
         {
            tempStationaryRightPage = new MovieClip();
            this._pageNumberTxt = this._flipDirection == 1 ? int(this._pageNumber + 0.5) : int(this._currentPage + 0.5);
            if(this._pageNumberTxt >= this._numberOfPages)
            {
               this.drawPage(tempStationaryRightPage,this._flipDirection,this._vertDir);
               this._stationaryRightPage.addChild(tempStationaryRightPage);
               this._blankPageLast.x = this._pageWidth * 0.5;
               this._blankPageLast.y = -this._vertDir * this._pivotY;
               this._stationaryRightPage.addChild(this._blankPageLast);
            }
            else
            {
               this.drawPage(tempStationaryRightPage,1,this._vertDir);
               this._stationaryRightPage.addChild(tempStationaryRightPage);
               this._blankPage2.x = this._pageWidth * 0.5;
               this._blankPage2.y = -this._vertDir * this._pivotY;
               this._stationaryRightPage.addChild(this._blankPage2);
            }
            if(this._pageNumberTxt <= this._numberOfPages + 0.5)
            {
               if(this._loadedPages[this._pageNumberTxt] != null)
               {
                  temporary = new MovieClip();
                  temporary = this._loadedPages[this._pageNumberTxt];
                  temporary.x = this._pageWidth * 0.5;
                  temporary.y = -this._vertDir * this._pivotY;
                  this._stationaryRightPage.addChild(temporary);
               }
               else
               {
                  this._spiralRightPage.setNewParent(this._stationaryRightPage,this._pageWidth * 0.5,-this._vertDir * this._pivotY);
               }
               this._pageFlipBase.addChild(this._stationaryRightPage);
               if(pageIndex != -1)
               {
                  this._pageFlipBase.setChildIndex(this._stationaryRightPage,pageIndex);
               }
            }
         }
         if(!this._isSinglePF || this._isJourneyBook || this._flipDirection == -1)
         {
            shade = new MovieClip();
            shade.mouseChildren = false;
            shade.mouseEnabled = false;
            this.makeShade(shade,-this._flipDirection,this._vertDir);
            if(this._flipDirection > 0 && !this._isSinglePF && this._pageDrag)
            {
               this._stationaryLeftPage.addChild(shade);
            }
            else
            {
               this._stationaryRightPage.addChild(shade);
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
         }
      }
      
      private function stopDragging(side:Number) : void
      {
         if(this._pageDrag)
         {
            if(side > 0)
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
         this._rightBottomBtn = this._buttonsView[3];
         this._xBtn = this._buttonsView[1];
         if(Boolean(this._eBook))
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
         this._pageFlipBase.addChild(this._xBtn);
         KeepAlive.startKATimer(this._rightBottomBtn);
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
            this._leftBottomBtn.x = -this._pageWidth + this._leftBottomBtn.width;
         }
         if(this._isSinglePF)
         {
            if(this._pageStart < 2)
            {
               this._leftBottomBtn.visible = false;
            }
         }
         else if(this._pageStart < 3)
         {
            this._leftBottomBtn.visible = false;
         }
         if(!this._currPageVarsLoaded)
         {
            this._leftBottomBtn.visible = false;
            this._rightBottomBtn.visible = false;
         }
         if(Boolean(this._eBook))
         {
            this._xBtn.visible = false;
         }
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_OVER,this.allBtnOverHandler,false,0,true);
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_OUT,this.allBtnOutHandler,false,0,true);
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.allBtnDownHandler,false,0,true);
         this._leftBottomBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
         this._rightBottomBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
         this._xBtn.addEventListener(MouseEvent.MOUSE_UP,this.allBtnUpHandler,false,0,true);
      }
      
      private function bringButtonsToFront() : void
      {
         this._leftBottomBtn.parent.setChildIndex(this._leftBottomBtn,this._leftBottomBtn.parent.numChildren - 1);
         this._rightBottomBtn.parent.setChildIndex(this._rightBottomBtn,this._rightBottomBtn.parent.numChildren - 1);
         this._xBtn.parent.setChildIndex(this._xBtn,this._xBtn.parent.numChildren - 1);
      }
      
      private function allBtnOverHandler(m:MouseEvent) : void
      {
         switch(m.currentTarget)
         {
            case this._leftBottomBtn:
               this.startDragging(-1,1);
               break;
            case this._rightBottomBtn:
               this.startDragging(1,1);
         }
      }
      
      private function allBtnOutHandler(m:MouseEvent) : void
      {
         if(m.currentTarget != this._xBtn)
         {
            this._ShouldBeDragging = false;
            this.bringButtonsToFront();
         }
      }
      
      private function magnify(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._zoomedIn)
         {
            this.stopDrag();
            if(Boolean(this._eBook))
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
            if(Boolean(this._eBook))
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
      
      private function allBtnDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(m.currentTarget == this._xBtn || m.currentTarget.name == "bx")
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
            if(m.currentTarget == this._leftBottomBtn)
            {
               this._rightBottomBtn.visible = this._xBtn.visible = false;
            }
            else
            {
               this._leftBottomBtn.visible = false;
            }
         }
      }
      
      private function allBtnUpHandler(m:MouseEvent) : void
      {
         if(this._playFlipSound)
         {
            AJAudio.playNewspaperSound();
         }
         switch(m.currentTarget)
         {
            case this._leftBottomBtn:
               this.stopDragging(-1);
               break;
            case this._rightBottomBtn:
               this.stopDragging(1);
         }
      }
      
      private function onEnterFrame(e:Event) : void
      {
         var goalRatio:Number = NaN;
         if(this._flipInProgress == 1)
         {
            this.flipAuto(this.range0to1(this._pageOffset = this._pageOffset + this._autoStepSpeed));
         }
         else
         {
            goalRatio = this.getPageRatio();
            this._step = (goalRatio - this._pageFlipPercent) * this._dragSmoothness;
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
      
      private function jbUserVarIdForPageName(pageName:String) : int
      {
         switch(pageName)
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
      
      private function eBookUserVarIdForPageName(pageName:String) : int
      {
         switch(pageName)
         {
            case EBOOK_OTTER_NAME:
               return EBOOK_OTTER_STAMPS_UV;
            case EBOOK_PANDA_NAME:
               return EBOOK_PANDA_STAMPS_UV;
            default:
               return -1;
         }
      }
      
      private function eBookNumStampsForUserVarId(userVarId:int) : int
      {
         switch(userVarId)
         {
            case EBOOK_OTTER_STAMPS_UV:
               return EBOOK_OTTER_NUM_STAMPS;
            case EBOOK_PANDA_STAMPS_UV:
               return EBOOK_PANDA_NUM_STAMPS;
            default:
               return -1;
         }
      }
   }
}

