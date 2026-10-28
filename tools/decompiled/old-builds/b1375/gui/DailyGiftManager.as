package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
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
      
      public static const GIFTS_RECEIVED_UV:int = 440;
      
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
         _guiLayer = GuiManager.guiLayer;
         _closeCallback = param2;
         _giftIndex = param1;
         _giftingPopupMediaHelper = new MediaHelper();
         _giftingPopupMediaHelper.init(2539,giftingPopupCallback);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         _giftDataToStillBeDisplayed = null;
         if(_giftingPopupContent)
         {
            DarkenManager.unDarken(_giftingPopupContent.parent);
            _guiLayer.removeChild(_giftingPopupContent.parent);
            _giftingPopupContent.visible = false;
            _giftingPopupContent = null;
            _giftingPopupMediaHelper = null;
         }
      }
      
      private function giftingPopupCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _giftingPopupContent = MovieClip(param1.getChildAt(0));
            param1.x = 900 * 0.5;
            param1.y = 550 * 0.5;
            _additionalDiamond = new Array(true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true,false,true);
            setupPopup();
            addEventListeners();
            _guiLayer.addChild(param1);
            DarkenManager.darken(param1);
         }
      }
      
      private function setupPopup() : void
      {
         var _loc1_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc2_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(440));
         _loc3_ = 1;
         for(; _loc3_ <= 31; _loc3_++)
         {
            _loc1_ = _giftingPopupContent["gift" + _loc3_];
            if(_loc3_ < _giftIndex + 1)
            {
               if(_loc2_ != -1 && (_loc2_ & 1 << _loc3_ - 1) > 0)
               {
                  _loc1_.gotoAndStop("opened");
               }
               else
               {
                  _loc1_.gotoAndStop("missed");
                  _loc1_.missedGift.diamond.visible = _additionalDiamond[_loc3_ - 1];
               }
            }
            else
            {
               if(_loc3_ > _giftIndex + 1)
               {
                  _loc1_.gotoAndStop("unopened");
                  _loc1_.unopenedGift.highlight.visible = false;
                  _loc1_.unopenedGift.openTag.visible = false;
                  _loc1_.unopenedGift.currIndex = _loc3_;
                  _loc1_.unopenedGift.shine.visible = false;
                  _loc1_.unopenedGift.gift.addEventListener("mouseDown",onFutureGiftDown,false,0,true);
                  _loc1_.unopenedGift.diamond.addEventListener("mouseDown",onFutureGiftDown,false,0,true);
               }
               else if(_loc3_ == _giftIndex + 1)
               {
                  if(_loc2_ != -1 && (_loc2_ & 1 << _loc3_ - 1) > 0)
                  {
                     _loc1_.gotoAndStop("opened");
                     continue;
                  }
                  _loc1_.gotoAndStop("unopened");
                  _loc1_.unopenedGift.openTag.visible = true;
                  _loc1_.unopenedGift.highlight.visible = false;
                  _loc1_.unopenedGift.highlight.mouseChildren = false;
                  _loc1_.unopenedGift.highlight.mouseEnabled = false;
                  _loc1_.unopenedGift.shine.mouseChildren = false;
                  _loc1_.unopenedGift.shine.mouseEnabled = false;
                  _loc1_.unopenedGift.gift.addEventListener("mouseDown",onGiftDown,false,0,true);
                  _loc1_.unopenedGift.gift.addEventListener("rollOver",onGiftOver,false,0,true);
                  _loc1_.unopenedGift.gift.addEventListener("rollOut",onGiftOut,false,0,true);
                  _loc1_.unopenedGift.diamond.addEventListener("mouseDown",onGiftDown,false,0,true);
               }
               if(!gMainFrame.userInfo.isMember)
               {
                  _loc1_.unopenedGift.diamond.gotoAndStop("nonMember");
               }
               _loc1_.unopenedGift.diamond.visible = _additionalDiamond[_loc3_ - 1];
            }
         }
      }
      
      public function setupGiftPopup() : void
      {
         var _loc3_:Object = null;
         var _loc5_:Object = null;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 1;
         var _loc1_:int = 2;
         var _loc8_:int = 3;
         var _loc11_:Array = new Array(_loc7_,_loc7_,_loc9_,_loc7_,_loc7_,_loc7_,_loc7_,_loc9_,_loc7_,_loc9_,_loc7_,_loc9_,_loc7_,_loc7_,_loc7_,_loc9_,_loc7_,_loc9_,_loc9_,_loc9_,_loc7_,_loc9_,_loc9_,_loc9_,_loc9_,_loc7_,_loc7_,_loc7_,_loc7_,_loc7_,_loc9_);
         var _loc6_:Array = new Array(2886,2439,1311,2910,2436,1806,2913,851,1825,692,2453,852,1164,1165,1808,527,1810,853,854,1312,2915,525,1313,691,249,1826,2868,1833,2869,1835,850);
         var _loc10_:int = 0;
         var _loc2_:int = int(gMainFrame.clientInfo.dailyGiftIndex);
         if(_loc2_ <= _loc11_.length)
         {
            if(_loc11_[_giftIndex] == _loc9_)
            {
               _loc5_ = ItemXtCommManager.getItemDef(_loc6_[_loc2_]);
               _randColorIndex = (_loc5_.colors.length - 1) * Math.random();
               _loc3_ = new Item();
               _loc3_.init(_loc5_.defId,0,_loc5_.colors[_randColorIndex],0,0,true);
               _loc4_ = 1;
            }
            else if(_loc11_[_giftIndex] == _loc7_)
            {
               _loc5_ = DenXtCommManager.getDenItemDef(_loc6_[_loc2_]);
               _loc3_ = new DenItem();
               _loc3_.initShopItem(_loc5_.id,0);
               _loc4_ = 2;
            }
            else if(_loc11_[_giftIndex] == _loc1_)
            {
               _loc4_ = 0;
            }
            else if(_loc11_[_giftIndex] == _loc8_)
            {
               _loc4_ = 8;
            }
            if(_additionalDiamond[_giftIndex])
            {
               _diamondAmount = 1;
               _giftingPopupMediaHelper = new MediaHelper();
               _giftingPopupMediaHelper.init(2221,onDiamondIconLoaded);
               _giftDataToStillBeDisplayed = {
                  "currItem":_loc3_,
                  "defIdOrAmount":_loc6_[_loc2_],
                  "giftType":_loc4_
               };
            }
            else
            {
               checkAndInitializeGiftPopup(_loc4_,_loc3_,_loc6_[_loc2_]);
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function checkAndInitializeGiftPopup(param1:int, param2:Object, param3:int) : void
      {
         if(param1 == 0)
         {
            _gemAmount = param3;
            _giftingPopupMediaHelper = new MediaHelper();
            _giftingPopupMediaHelper.init(1086,onGemIconLoaded);
         }
         else if(param1 == 8)
         {
            _diamondAmount = param3;
            _giftingPopupMediaHelper = new MediaHelper();
            _giftingPopupMediaHelper.init(2221,onDiamondIconLoaded);
         }
         else
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(_guiLayer,param2.largeIcon,param2.name,param3,4,param1,keepGiftCallback,rejectGiftCallback);
         }
      }
      
      private function onGemIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(_guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(_gemAmount == 1 ? 11114 : 11097,_gemAmount),_gemAmount,4,0,null,keepGiftCallback,null,false,1);
         }
      }
      
      private function onDiamondIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _giftPopup = new GiftPopup();
            _giftPopup.init(_guiLayer,param1,LocalizationManager.translateIdAndInsertOnly(_diamondAmount == 1 ? 11116 : 11103,_diamondAmount),_diamondAmount,4,8,null,keepDiamondGiftCallback,null,false,1);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/close");
         close();
      }
      
      private function keepDiamondGiftCallback() : void
      {
         if(_giftDataToStillBeDisplayed != null)
         {
            _giftPopup.destroy();
            checkAndInitializeGiftPopup(_giftDataToStillBeDisplayed.giftType,_giftDataToStillBeDisplayed.currItem,_giftDataToStillBeDisplayed.defIdOrAmount);
         }
         else
         {
            DarkenManager.showLoadingSpiral(true);
            _giftingPopupContent.visible = false;
            AchievementXtCommManager.requestSetUserVar(214,_randColorIndex,setVarCallback);
            AchievementXtCommManager.requestSetUserVar(440,_giftIndex);
         }
      }
      
      private function keepGiftCallback() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _giftingPopupContent.visible = false;
         AchievementXtCommManager.requestSetUserVar(214,_randColorIndex,setVarCallback);
         AchievementXtCommManager.requestSetUserVar(440,_giftIndex);
      }
      
      private function rejectGiftCallback() : void
      {
         if(_giftDataToStillBeDisplayed)
         {
            DarkenManager.showLoadingSpiral(true);
            _giftingPopupContent.visible = false;
            AchievementXtCommManager.requestSetUserVar(214,666,setVarCallback);
            AchievementXtCommManager.requestSetUserVar(440,_giftIndex);
         }
         else
         {
            close();
         }
      }
      
      private function setVarCallback(param1:int, param2:int) : void
      {
         if(_gemAmount > 0)
         {
            UserCurrency.setCurrency(UserCurrency.getCurrency(0) + _gemAmount,0);
         }
         if(_diamondAmount > 0)
         {
            UserCurrency.setCurrency(UserCurrency.getCurrency(3) + _diamondAmount,3);
         }
         DarkenManager.showLoadingSpiral(false);
         close();
      }
      
      private function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
            _closeCallback = null;
         }
         else
         {
            destroy();
         }
      }
      
      private function onGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/" + param1.currentTarget.name);
         setupGiftPopup();
      }
      
      private function onFutureGiftDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:int = param1.currentTarget.parent.currIndex - (_giftIndex + 1);
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc2_ == 1 ? 11383 : 11384,_loc2_));
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
         _giftingPopupContent.bx.addEventListener("mouseDown",onClose,false,0,true);
         _giftingPopupContent.addEventListener("mouseDown",onPopupDown,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:int = 0;
         _giftingPopupContent.bx.removeEventListener("mouseDown",onClose);
         _giftingPopupContent.removeEventListener("mouseDown",onPopupDown);
         _loc2_ = _giftIndex + 1;
         while(_loc2_ <= 25)
         {
            _loc1_ = _giftingPopupContent["gift" + _loc2_];
            if(_loc1_.unopenedGift)
            {
               _loc1_.unopenedGift.gift.removeEventListener("mouseDown",onGiftDown);
               _loc1_.unopenedGift.gift.removeEventListener("rollOver",onGiftOver);
               _loc1_.unopenedGift.gift.removeEventListener("rollOut",onGiftOut);
               _loc1_.unopenedGift.gift.removeEventListener("mouseDown",onFutureGiftDown);
               _loc1_.unopenedGift.diamond.removeEventListener("mouseDown",onFutureGiftDown);
            }
            _loc2_++;
         }
      }
   }
}

