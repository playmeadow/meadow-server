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
      
      public static function setCurrentShop(shop:Shop) : void
      {
         _currentShop = shop;
      }
      
      public static function handleAllRequiredVisibilities(on:Boolean) : void
      {
         GuiManager.toggleHud();
         handleDenSwitcherandShopVisibility(on);
         GuiManager.showDenHudItems(on);
         if(Boolean(_buyAndBackBtns))
         {
            _buyAndBackBtns.visible = !on;
         }
         else if(!on)
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
      
      public static function showBuyAndBackBtns(show:Boolean) : void
      {
         if(show)
         {
            if(Boolean(_buyAndBackBtns))
            {
               _buyAndBackBtns.visible = true;
            }
            else
            {
               _loadingMediaHelper = new MediaHelper();
               _loadingMediaHelper.init(2969,onBuyAndBackBtnsLoaded);
            }
         }
         else if(Boolean(_buyAndBackBtns))
         {
            _buyAndBackBtns.visible = false;
         }
      }
      
      public static function exitPreview() : void
      {
         onBackBtn(null);
      }
      
      private static function handleDenSwitcherandShopVisibility(show:Boolean) : void
      {
         if(show)
         {
            GuiManager.showDenSwitcher(true);
            if(Boolean(_currentShop))
            {
               _currentShop.showShop(true);
            }
         }
         else
         {
            if(Boolean(_currentShop))
            {
               _currentShop.showShop(false);
            }
            GuiManager.showDenSwitcher(false);
         }
      }
      
      private static function onBuyAndBackBtnsLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _buyAndBackBtns = img;
            _buyAndBackBtns.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBackBtn,false,0,true);
            _buyAndBackBtns.buyBtn.addEventListener(MouseEvent.MOUSE_DOWN,onBuyBtn,false,0,true);
            GuiManager.guiLayer.addChild(_buyAndBackBtns);
         }
      }
      
      private static function onBackBtn(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(_buyAndBackBtns) && _buyAndBackBtns.visible)
         {
            RoomManagerWorld.instance.reloadCurrentNormalRoom();
            _buyAndBackBtns.visible = false;
         }
      }
      
      private static function onBuyBtn(evt:MouseEvent) : void
      {
         var denDef:Object = null;
         evt.stopPropagation();
         if(Boolean(_currentShop))
         {
            if(_currentShop.isDiamondStore)
            {
               _currentShop.attemptToBuyCurrrentItem();
            }
            else
            {
               denDef = gMainFrame.userInfo.denRoomDefs[_currentShop.getCurrentItemDefId()];
               if(Boolean(denDef))
               {
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(10305,Utility.convertNumberToString(denDef.value)),true,onPreviewBuy);
               }
            }
         }
      }
      
      private static function onPreviewBuy(o:Object) : void
      {
         if(Boolean(o.status))
         {
            if(Boolean(_currentShop))
            {
               _currentShop.attemptToBuyCurrrentItem();
            }
         }
      }
   }
}

