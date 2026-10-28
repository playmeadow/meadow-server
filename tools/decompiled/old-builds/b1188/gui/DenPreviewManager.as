package gui
{
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class DenPreviewManager
   {
      
      private static var _currentShop:Shop;
      
      private static var _buyAndBackBtns:MovieClip;
      
      private static var _loadingMediaHelper:MediaHelper;
      
      public function DenPreviewManager()
      {
         super();
      }
      
      public static function setCurrentShop(param1:Shop) : void
      {
         _currentShop = param1;
      }
      
      public static function handleAllRequiredVisibilities(param1:Boolean) : void
      {
         GuiManager.toggleHud();
         handleDenSwitcherandShopVisibility(param1);
         GuiManager.showDenHudItems(param1);
         if(_buyAndBackBtns)
         {
            _buyAndBackBtns.visible = !param1;
         }
         else if(!param1)
         {
            showBuyAndBackBtns(true);
         }
      }
      
      public static function handleDenPurchase() : void
      {
         if(Boolean(_buyAndBackBtns) && _buyAndBackBtns.visible)
         {
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
            _buyAndBackBtns.visible = false;
         }
      }
      
      public static function showBuyAndBackBtns(param1:Boolean) : void
      {
         if(param1)
         {
            if(_buyAndBackBtns)
            {
               _buyAndBackBtns.visible = true;
            }
            else
            {
               _loadingMediaHelper = new MediaHelper();
               _loadingMediaHelper.init(2969,onBuyAndBackBtnsLoaded);
            }
         }
         else if(_buyAndBackBtns)
         {
            _buyAndBackBtns.visible = false;
         }
      }
      
      public static function exitPreview() : void
      {
         onBackBtn(null);
      }
      
      private static function handleDenSwitcherandShopVisibility(param1:Boolean) : void
      {
         if(param1)
         {
            GuiManager.showDenSwitcher(true);
            if(_currentShop)
            {
               _currentShop.showShop(true);
            }
         }
         else
         {
            if(_currentShop)
            {
               _currentShop.showShop(false);
            }
            GuiManager.showDenSwitcher(false);
         }
      }
      
      private static function onBuyAndBackBtnsLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _buyAndBackBtns = param1;
            _buyAndBackBtns.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBackBtn,false,0,true);
            _buyAndBackBtns.buyBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBuyBtn,false,0,true);
            GuiManager.guiLayer.addChild(_buyAndBackBtns);
         }
      }
      
      private static function onBackBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(Boolean(_buyAndBackBtns) && _buyAndBackBtns.visible)
         {
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
            _buyAndBackBtns.visible = false;
         }
      }
      
      private static function onBuyBtn(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_currentShop)
         {
            if(_currentShop.isDiamondStore)
            {
               _currentShop.attemptToBuyCurrrentItem();
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.denRoomDefs[_currentShop.getCurrentItemDefId()];
               if(_loc2_)
               {
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(10305,Utility.convertNumberToString(_loc2_.value)),true,onPreviewBuy);
               }
            }
         }
      }
      
      private static function onPreviewBuy(param1:Object) : void
      {
         if(param1.status)
         {
            if(_currentShop)
            {
               _currentShop.attemptToBuyCurrrentItem();
            }
         }
      }
   }
}

