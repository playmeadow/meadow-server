package gui
{
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import currency.UserCurrency;
   import diamond.DiamondXtCommManager;
   import flash.display.Bitmap;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import loader.MasterpieceDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class MasterpiecePreview
   {
      
      private static var _masterpiecePreviewIconStrIds:Array;
      
      private static var _masterpiecePreviewIconsOrdered:Array;
      
      private static var _masterpiecePreviewIconIdsOrdered:Array;
      
      private const POPUP_MEDIA_ID:int = 4810;
      
      private var _guiLayer:DisplayObjectContainer;
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _masterpieceMediaHelper:MasterpieceDefHelper;
      
      private var _previewLoadingSpiral:LoadingSpiral;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _previewImage:Sprite;
      
      private var _previewPopup:MovieClip;
      
      private var _itemLayer:MovieClip;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _itemVersion:int;
      
      private var _hasLoadedIcons:Boolean;
      
      private var _isBuying:Boolean;
      
      private var _creatorUsername:String;
      
      private var _uniqueImageId:String;
      
      public function MasterpiecePreview(param1:DisplayObjectContainer, param2:String, param3:String, param4:int, param5:Function, param6:Object = null, param7:Boolean = false)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = param1;
         _itemVersion = param4;
         _uniqueImageId = param2;
         _creatorUsername = param3;
         if(param6 != null)
         {
            if(param6 is Bitmap)
            {
               _previewImage = new Sprite();
               _previewImage.addChild(param6 as Bitmap);
            }
            else
            {
               _previewImage = param6 as Sprite;
            }
         }
         _isBuying = param7;
         if(_masterpiecePreviewIconIdsOrdered == null)
         {
            GenericListXtCommManager.requestGenericList(424,onMasterpieceIconOrderListLoaded);
         }
         else
         {
            _hasLoadedIcons = true;
         }
         _closeCallback = param5;
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4810,onPreviewLoaded);
      }
      
      public static function get masterpiecePreviewIconStrIds() : Array
      {
         return _masterpiecePreviewIconStrIds;
      }
      
      public static function set masterpiecePreviewIconStrIds(param1:Array) : void
      {
         _masterpiecePreviewIconStrIds = param1;
      }
      
      public static function set masterpiecePreviewIconIdsOrdered(param1:Array) : void
      {
         _masterpiecePreviewIconIdsOrdered = param1;
      }
      
      public static function get masterpiecePreviewIconIdsOrdered() : Array
      {
         return _masterpiecePreviewIconIdsOrdered;
      }
      
      public function destroy(param1:Boolean = false) : void
      {
         var _loc3_:Function = null;
         var _loc2_:MovieClip = null;
         if(_closeCallback != null)
         {
            _loc3_ = _closeCallback;
            _closeCallback = null;
            _loc3_(param1);
            return;
         }
         if(_masterpiecePreviewIconsOrdered)
         {
            _loc2_ = _masterpiecePreviewIconsOrdered[_itemVersion];
            if(_loc2_)
            {
               if(_previewImage)
               {
                  _loc2_.itemWindow.removeChild(_previewImage);
               }
               if(!_isBuying)
               {
                  _loc2_.report_btn.removeEventListener("mouseDown",onReportDown);
               }
               _loc2_.removeEventListener("mouseOver",onIconOver);
               _loc2_.removeEventListener("mouseOut",onIconOut);
               _loc2_.nameBar.removeEventListener("mouseDown",onNameBarDown);
            }
         }
         removeEventListeners();
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
            _mediaHelper = null;
         }
         if(_previewLoadingSpiral)
         {
            _previewLoadingSpiral.destroy();
            _previewLoadingSpiral = null;
         }
         if(_masterpieceMediaHelper)
         {
            _masterpieceMediaHelper.destroy();
            _masterpieceMediaHelper = null;
         }
         DarkenManager.unDarken(_previewPopup);
         _guiLayer.removeChild(_previewPopup);
         _previewPopup = _itemLayer = _buyBtnGreen = _buyBtnRed = _closeBtn = null;
      }
      
      public function set closeCallback(param1:Function) : void
      {
         _closeCallback = param1;
      }
      
      private function onMasterpieceIconOrderListLoaded(param1:int, param2:Array, param3:Array) : void
      {
         _masterpiecePreviewIconIdsOrdered = param2;
         _masterpiecePreviewIconStrIds = param3;
         _hasLoadedIcons = true;
         if(_previewPopup)
         {
            setupPreview();
         }
      }
      
      private function onPreviewLoaded(param1:MovieClip) : void
      {
         _previewPopup = param1.getChildAt(0) as MovieClip;
         _itemLayer = _previewPopup.itemLayer;
         _buyBtnGreen = _previewPopup.diamond_buy_btn_green;
         _buyBtnRed = _previewPopup.diamond_buy_btn_red;
         _closeBtn = _previewPopup.bx;
         DarkenManager.showLoadingSpiral(false);
         _previewPopup.x = 900 * 0.5;
         _previewPopup.y = 550 * 0.5;
         setupPreview();
         addEventListeners();
         _guiLayer.addChild(_previewPopup);
         DarkenManager.darken(_previewPopup);
      }
      
      private function setupPreview() : void
      {
         var _loc1_:Object = null;
         if(_hasLoadedIcons)
         {
            if(_masterpiecePreviewIconsOrdered && _masterpiecePreviewIconsOrdered[_itemVersion])
            {
               _previewLoadingSpiral = new LoadingSpiral(_itemLayer);
               if(_previewImage)
               {
                  onPreviewImageLoaded(_previewImage);
               }
               else if(_uniqueImageId)
               {
                  _masterpieceMediaHelper = new MasterpieceDefHelper();
                  _masterpieceMediaHelper.init(_uniqueImageId,onPreviewImageLoaded);
               }
               else
               {
                  onPreviewImageLoaded(null);
               }
            }
            else
            {
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(_masterpiecePreviewIconIdsOrdered[_itemVersion],onPreviewIconLoaded);
            }
         }
         if(_isBuying)
         {
            _loc1_ = DiamondXtCommManager.getDiamondDef(221);
            if(!UserCurrency.hasEnoughCurrency(3,_loc1_.value))
            {
               _buyBtnGreen.visible = false;
               _buyBtnRed.visible = true;
            }
            else
            {
               _buyBtnGreen.visible = true;
               _buyBtnRed.visible = false;
            }
         }
         else
         {
            _buyBtnGreen.visible = false;
            _buyBtnRed.visible = false;
         }
      }
      
      private function onPreviewIconLoaded(param1:MovieClip) : void
      {
         if(_masterpiecePreviewIconsOrdered == null)
         {
            _masterpiecePreviewIconsOrdered = [];
         }
         _masterpiecePreviewIconsOrdered[_itemVersion] = param1.getChildAt(0);
         setupPreview();
      }
      
      private function onPreviewImageLoaded(param1:Sprite) : void
      {
         _previewImage = param1;
         if(_previewLoadingSpiral)
         {
            _previewLoadingSpiral.destroy();
            _previewLoadingSpiral = null;
         }
         var _loc3_:MovieClip = _masterpiecePreviewIconsOrdered[_itemVersion];
         var _loc2_:Number = _loc3_.itemWindow.scaleX - 1;
         var _loc4_:Number = _loc3_.itemWindow.scaleY - 1;
         if(_previewImage)
         {
            _previewImage.width = _loc3_.itemWindow.width - _loc3_.itemWindow.width * _loc2_;
            _previewImage.height = _loc3_.itemWindow.height - _loc3_.itemWindow.height * _loc4_;
            _previewImage.x = -_previewImage.width * 0.5;
            _previewImage.y = -_previewImage.height * 0.5;
            _loc3_.itemWindow.addChild(_previewImage);
            if(_isBuying || _creatorUsername == "" || _creatorUsername == gMainFrame.userInfo.myUserName)
            {
               _loc3_.nameBar.mouseChildren = false;
               _loc3_.nameBar.mouseEnabled = false;
            }
            else
            {
               _loc3_.nameBar.mouseChildren = true;
               _loc3_.nameBar.mouseEnabled = true;
               _loc3_.addEventListener("mouseOver",onIconOver,false,0,true);
               _loc3_.addEventListener("mouseOut",onIconOut,false,0,true);
               _loc3_.nameBar.addEventListener("mouseDown",onNameBarDown,false,0,true);
            }
            _loc3_.report_btn.visible = false;
            if(_creatorUsername == null || _creatorUsername == "")
            {
               (_loc3_.nameBar as GuiSoundButton).setTextInLayer(LocalizationManager.translateIdOnly(25212),"name_txt");
            }
            else
            {
               (_loc3_.nameBar as GuiSoundButton).setTextInLayer(_creatorUsername,"name_txt");
            }
            if(!_isBuying)
            {
               _loc3_.report_btn.addEventListener("mouseDown",onReportDown,false,0,true);
               _loc3_.nameBar.visible = true;
            }
         }
         else
         {
            _loc3_.nameBar.visible = false;
            _loc3_.report_btn.visible = false;
            while(_loc3_.itemWindow.numChildren > 1)
            {
               _loc3_.itemWindow.removeChildAt(_loc3_.itemWindow.numChildren - 1);
            }
         }
         if("frame" in _loc3_)
         {
            _loc3_.frame.filters = null;
         }
         _itemLayer.addChild(_loc3_);
      }
      
      private function addEventListeners() : void
      {
         _previewPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _buyBtnGreen.addEventListener("mouseDown",onBuyBtn,false,0,true);
         _buyBtnRed.addEventListener("mouseDown",onBuyBtn,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _previewPopup.removeEventListener("mouseDown",onPopup);
         _buyBtnGreen.removeEventListener("mouseDown",onBuyBtn);
         _buyBtnRed.removeEventListener("mouseDown",onBuyBtn);
         _closeBtn.removeEventListener("mouseDown",onCloseBtn);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onBuyBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _buyBtnRed)
         {
            UpsellManager.displayPopup("","extraDiamonds");
         }
         else if(!gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup("denArt","den_art");
         }
         else
         {
            destroy(true);
         }
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _reportAPlayer = new ReportAPlayer();
         _reportAPlayer.init(4,_guiLayer,onPostReport,true,_creatorUsername,_creatorUsername,false,_uniqueImageId,7);
      }
      
      private function onPostReport(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      private function onIconOver(param1:MouseEvent) : void
      {
         param1.currentTarget.report_btn.visible = true;
      }
      
      private function onIconOut(param1:MouseEvent) : void
      {
         param1.currentTarget.report_btn.visible = false;
      }
      
      private function onNameBarDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_previewPopup && _creatorUsername.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            BuddyList.requestBuddyListIfNeeded(onBuddyListRequested);
         }
      }
      
      private function onBuddyListRequested() : void
      {
         var _loc1_:Buddy = BuddyManager.getBuddyByUserName(_creatorUsername);
         if(_loc1_)
         {
            BuddyManager.showBuddyCard({
               "userName":_loc1_.userName,
               "onlineStatus":_loc1_.onlineStatus
            });
            return;
         }
         AvatarXtCommManager.requestAvatarGet(_creatorUsername,onUserLookUpReceived,true);
      }
      
      private function onUserLookUpReceived(param1:String, param2:Boolean, param3:int) : void
      {
         if(param2)
         {
            BuddyManager.showBuddyCard({
               "userName":param1,
               "onlineStatus":param3
            });
         }
      }
   }
}

