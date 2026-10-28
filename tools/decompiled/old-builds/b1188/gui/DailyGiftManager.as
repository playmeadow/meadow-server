package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DailyGiftManager
   {
      
      private const GIFTS_RECEIVED_UV:int = 373;
      
      private var _giftingPopupMediaHelper:MediaHelper;
      
      private var _giftingPopupContent:MovieClip;
      
      private var _giftPopup:GiftPopup;
      
      private var _giftIndex:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _randColorIndex:int;
      
      private var _gemAmount:int;
      
      private var _diamondAmount:int;
      
      private var _closeCallback:Function;
      
      private var _giftDataToStillBeDisplayed:Object;
      
      private var _additionalDiamond:Array;
      
      public function DailyGiftManager()
      {
         super();
      }
      
      public function init(param1:int, param2:Function) : void
      {
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = param2;
         this._giftIndex = param1;
         this._giftingPopupMediaHelper = new MediaHelper();
         this._giftingPopupMediaHelper.init(2539,this.giftingPopupCallback);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(this._giftPopup)
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
         this._giftDataToStillBeDisplayed = null;
         if(this._giftingPopupContent)
         {
            DarkenManager.unDarken(this._giftingPopupContent.parent);
            this._guiLayer.removeChild(this._giftingPopupContent.parent);
            this._giftingPopupContent.visible = false;
            this._giftingPopupContent = null;
            this._giftingPopupMediaHelper = null;
         }
      }
      
      private function giftingPopupCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            this._giftingPopupContent = MovieClip(param1.getChildAt(0));
            param1.x = MainFrame.VIEW_WIDTH * 0.5;
            param1.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._additionalDiamond = new Array(false,false,false,true,false,true,true,false,true,true,false,true,true,false,false,true,false,true,true,false,true,false,true,true,true,false,true,false,true,false,true);
            this.setupPopup();
            this.addEventListeners();
            this._guiLayer.addChild(param1);
            DarkenManager.darken(param1);
         }
      }
      
      private function setupPopup() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(this.GIFTS_RECEIVED_UV));
         var _loc3_:int = 1;
         while(_loc3_ <= 31)
         {
            _loc1_ = this._giftingPopupContent["gift" + _loc3_];
            if(_loc3_ < this._giftIndex + 1)
            {
               if(_loc2_ != -1 && (_loc2_ & 1 << _loc3_ - 1) > 0)
               {
                  _loc1_.gotoAndStop("opened");
               }
               else
               {
                  _loc1_.gotoAndStop("missed");
                  _loc1_.missedGift.diamond.visible = this._additionalDiamond[_loc3_ - 1];
               }
            }
            else
            {
               if(_loc3_ > this._giftIndex + 1)
               {
                  _loc1_.gotoAndStop("unopened");
                  _loc1_.unopenedGift.highlight.visible = false;
                  _loc1_.unopenedGift.openTag.visible = false;
                  _loc1_.unopenedGift.currIndex = _loc3_;
                  _loc1_.unopenedGift.shine.visible = false;
                  _loc1_.unopenedGift.gift.addEventListener(MouseEvent.MOUSE_DOWN,this.onFutureGiftDown,false,0,true);
                  _loc1_.unopenedGift.diamond.addEventListener(MouseEvent.MOUSE_DOWN,this.onFutureDiamondDown,false,0,true);
               }
               else if(_loc3_ == this._giftIndex + 1)
               {
                  _loc1_.gotoAndStop("unopened");
                  _loc1_.unopenedGift.openTag.visible = true;
                  _loc1_.unopenedGift.highlight.visible = false;
                  _loc1_.unopenedGift.highlight.mouseChildren = false;
                  _loc1_.unopenedGift.highlight.mouseEnabled = false;
                  _loc1_.unopenedGift.shine.mouseChildren = false;
                  _loc1_.unopenedGift.shine.mouseEnabled = false;
                  _loc1_.unopenedGift.gift.addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown,false,0,true);
                  _loc1_.unopenedGift.gift.addEventListener(MouseEvent.ROLL_OVER,this.onGiftOver,false,0,true);
                  _loc1_.unopenedGift.gift.addEventListener(MouseEvent.ROLL_OUT,this.onGiftOut,false,0,true);
                  _loc1_.unopenedGift.diamond.addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown,false,0,true);
               }
               if(!gMainFrame.userInfo.isMember)
               {
                  _loc1_.unopenedGift.diamond.gotoAndStop("nonMember");
               }
               _loc1_.unopenedGift.diamond.visible = this._additionalDiamond[_loc3_ - 1];
            }
            _loc3_++;
         }
      }
      
      public function setupGiftPopup() : void
      {
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 1;
         var _loc3_:int = 2;
         var _loc4_:int = 3;
         var _loc5_:Array = new Array(_loc2_,_loc2_,_loc2_,_loc2_,_loc1_,_loc1_,_loc1_,_loc2_,_loc2_,_loc2_,_loc2_,_loc1_,_loc1_,_loc1_,_loc2_,_loc2_,_loc2_,_loc2_,_loc1_,_loc1_,_loc1_,_loc2_,_loc2_,_loc1_,_loc1_,_loc2_,_loc2_,_loc2_,_loc2_,_loc2_,_loc2_);
         var _loc6_:Array = new Array(1825,1837,717,715,849,526,691,1164,1165,1806,1838,850,692,851,1352,1354,1842,1836,852,525,690,1808,1161,853,854,1832,1833,1835,1351,1353,1826);
         var _loc7_:int = 0;
         var _loc11_:int = int(gMainFrame.clientInfo.dailyGiftIndex);
         if(_loc11_ <= _loc5_.length)
         {
            if(_loc5_[this._giftIndex] == _loc1_)
            {
               _loc9_ = ItemXtCommManager.getItemDef(_loc6_[_loc11_]);
               this._randColorIndex = (_loc9_.colors.length - 1) * Math.random();
               _loc8_ = new Item();
               _loc8_.init(_loc9_.defId,0,_loc9_.colors[this._randColorIndex],0,0,true);
               _loc10_ = GiftPopup.GIFT_TYPE_CLOTHING;
            }
            else if(_loc5_[this._giftIndex] == _loc2_)
            {
               _loc9_ = DenXtCommManager.getDenItemDef(_loc6_[_loc11_]);
               _loc8_ = new DenItem();
               _loc8_.initShopItem(_loc9_.id,0);
               _loc10_ = GiftPopup.GIFT_TYPE_DEN_ACC;
            }
            else if(_loc5_[this._giftIndex] == _loc3_)
            {
               _loc10_ = GiftPopup.GIFT_TYPE_GEMS;
            }
            else if(_loc5_[this._giftIndex] == _loc4_)
            {
               _loc10_ = GiftPopup.GIFT_TYPE_DIAMOND;
            }
            if(Boolean(this._additionalDiamond[this._giftIndex]) && Boolean(gMainFrame.userInfo.isMember))
            {
               this._diamondAmount = 1;
               this._giftingPopupMediaHelper = new MediaHelper();
               this._giftingPopupMediaHelper.init(StartupPopups.DIAMOND_MEDIA_ID,this.onDiamondIconLoaded);
               this._giftDataToStillBeDisplayed = {
                  "currItem":_loc8_,
                  "defIdOrAmount":_loc6_[_loc11_],
                  "giftType":_loc10_
               };
            }
            else
            {
               this.checkAndInitializeGiftPopup(_loc10_,_loc8_,_loc6_[_loc11_]);
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function checkAndInitializeGiftPopup(param1:int, param2:Object, param3:int) : void
      {
         if(param1 == GiftPopup.GIFT_TYPE_GEMS)
         {
            this._gemAmount = param3;
            this._giftingPopupMediaHelper = new MediaHelper();
            this._giftingPopupMediaHelper.init(StartupPopups.GEMS_MEDIA_ID,this.onGemIconLoaded);
         }
         else if(param1 == GiftPopup.GIFT_TYPE_DIAMOND)
         {
            this._diamondAmount = param3;
            this._giftingPopupMediaHelper = new MediaHelper();
            this._giftingPopupMediaHelper.init(StartupPopups.DIAMOND_MEDIA_ID,this.onDiamondIconLoaded);
         }
         else
         {
            this._giftPopup = new GiftPopup();
            this._giftPopup.init(this._guiLayer,param2.largeIcon,param2.name,param3,GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,param1,this.keepGiftCallback,this.rejectGiftCallback);
         }
      }
      
      private function onGemIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._giftPopup = new GiftPopup();
            this._giftPopup.init(this._guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(this._gemAmount == 1 ? LocalizationManager.GEM_CAPITALIZED : LocalizationManager.GEMS_CAPITALIZED,this._gemAmount),this._gemAmount,GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,GiftPopup.GIFT_TYPE_GEMS,null,this.keepGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
      }
      
      private function onDiamondIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._giftPopup = new GiftPopup();
            this._giftPopup.init(this._guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(this._diamondAmount == 1 ? LocalizationManager.DIAMOND_CAPITALIZED : LocalizationManager.DIAMONDS_CAPITALIZED,this._diamondAmount),this._diamondAmount,GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,GiftPopup.GIFT_TYPE_DIAMOND,null,this.keepDiamondGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/close");
         this.close();
      }
      
      private function keepDiamondGiftCallback() : void
      {
         if(this._giftDataToStillBeDisplayed != null)
         {
            this._giftPopup.destroy();
            this.checkAndInitializeGiftPopup(this._giftDataToStillBeDisplayed.giftType,this._giftDataToStillBeDisplayed.currItem,this._giftDataToStillBeDisplayed.defIdOrAmount);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            this._giftingPopupContent.visible = false;
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_DAILY_GEM_BONUS,this._randColorIndex,this.setVarCallback);
            AchievementXtCommManager.requestSetUserVar(this.GIFTS_RECEIVED_UV,this._giftIndex);
         }
      }
      
      private function keepGiftCallback() : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._giftingPopupContent.visible = false;
         AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_DAILY_GEM_BONUS,this._randColorIndex,this.setVarCallback);
         AchievementXtCommManager.requestSetUserVar(this.GIFTS_RECEIVED_UV,this._giftIndex);
      }
      
      private function rejectGiftCallback() : void
      {
         if(this._giftDataToStillBeDisplayed)
         {
            DarkenManager.showLoadingSpiral(true);
            this._giftingPopupContent.visible = false;
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_DAILY_GEM_BONUS,666,this.setVarCallback);
            AchievementXtCommManager.requestSetUserVar(this.GIFTS_RECEIVED_UV,this._giftIndex);
         }
         else
         {
            this.close();
         }
      }
      
      private function setVarCallback(param1:int, param2:int) : void
      {
         if(this._gemAmount > 0)
         {
            gMainFrame.clientInfo.gemCount += this._gemAmount;
         }
         if(this._diamondAmount > 0)
         {
            gMainFrame.clientInfo.diamondCount += this._diamondAmount;
         }
         DarkenManager.showLoadingSpiral(false);
         this.close();
      }
      
      private function close() : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback();
            this._closeCallback = null;
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/" + param1.currentTarget.name);
         this.setupGiftPopup();
      }
      
      private function onFutureGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = param1.currentTarget.parent.currIndex - (this._giftIndex + 1);
         new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc2_ == 1 ? 11383 : 11384,_loc2_));
      }
      
      private function onFutureDiamondDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = param1.currentTarget.parent.currIndex - (this._giftIndex + 1);
         if(!gMainFrame.userInfo.isMember)
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc2_ == 1 ? 20019 : 20020,_loc2_));
         }
         else
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc2_ == 1 ? 11383 : 11384,_loc2_));
         }
      }
      
      private function onGiftOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.parent.highlight.visible = true;
      }
      
      private function onGiftOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.parent.highlight.visible = false;
      }
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         this._giftingPopupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._giftingPopupContent.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         var _loc1_:MovieClip = null;
         this._giftingPopupContent.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._giftingPopupContent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         var _loc2_:int = this._giftIndex + 1;
         while(_loc2_ <= 25)
         {
            _loc1_ = this._giftingPopupContent["gift" + _loc2_];
            _loc1_.unopenedGift.gift.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown);
            _loc1_.unopenedGift.gift.removeEventListener(MouseEvent.ROLL_OVER,this.onGiftOver);
            _loc1_.unopenedGift.gift.removeEventListener(MouseEvent.ROLL_OUT,this.onGiftOut);
            _loc1_.unopenedGift.diamond.removeEventListener(MouseEvent.MOUSE_DOWN,this.onFutureDiamondDown);
            _loc2_++;
         }
      }
   }
}

