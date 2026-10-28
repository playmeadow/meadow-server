package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.analytics.SBTracker;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   
   public class DailyGiftManager
   {
      
      private const GEMS_MEDIA_ID:int = 1086;
      
      private var _giftingPopupMediaHelper:MediaHelper;
      
      private var _giftingPopupContent:MovieClip;
      
      private var _giftPopup:GiftPopup;
      
      private var _giftIndex:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _randColorIndex:int;
      
      private var _gemAmount:int;
      
      private var _closeCallback:Function;
      
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
         this._giftingPopupMediaHelper.init(328,this.giftingPopupCallback);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(this._giftPopup)
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
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
            this.addEventListeners();
            this._guiLayer.addChild(param1);
            DarkenManager.darken(param1);
         }
      }
      
      public function setupGiftPopup() : void
      {
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 1;
         var _loc3_:int = 2;
         var _loc4_:Array = new Array(_loc2_,_loc3_,_loc2_,_loc2_,_loc2_,_loc3_,_loc2_,_loc2_,_loc3_,_loc1_,_loc2_,_loc3_,_loc2_,_loc2_,_loc3_,_loc2_,_loc2_,_loc3_,_loc2_,_loc2_,_loc2_,_loc3_,_loc2_,_loc1_,_loc3_);
         var _loc5_:Array = new Array(1162,300,721,722,1161,400,715,716,500,526,718,600,717,720,700,719,1163,800,1164,724,1165,900,723,525,1000);
         var _loc6_:int = 0;
         var _loc10_:int = int(gMainFrame.clientInfo.dailyGiftIndex);
         if(_loc10_ <= _loc4_.length)
         {
            if(_loc4_[this._giftIndex] == _loc1_)
            {
               _loc8_ = ItemXtCommManager.getItemDef(_loc5_[_loc10_]);
               this._randColorIndex = (_loc8_.colors.length - 1) * Math.random();
               _loc7_ = new Item();
               _loc7_.init(_loc8_.defId,0,_loc8_.colors[this._randColorIndex],0,0,true);
               _loc9_ = GiftPopup.GIFT_TYPE_CLOTHING;
            }
            else if(_loc4_[this._giftIndex] == _loc2_)
            {
               _loc8_ = DenXtCommManager.getDenItemDef(_loc5_[_loc10_]);
               _loc7_ = new DenItem();
               _loc7_.initShopItem(_loc8_.id,0);
               _loc9_ = GiftPopup.GIFT_TYPE_DEN_ACC;
            }
            else
            {
               _loc9_ = GiftPopup.GIFT_TYPE_GEMS;
            }
            if(_loc9_ == GiftPopup.GIFT_TYPE_GEMS)
            {
               this._gemAmount = _loc5_[_loc10_];
               this._giftingPopupMediaHelper = new MediaHelper();
               this._giftingPopupMediaHelper.init(this.GEMS_MEDIA_ID,this.onGemIconLoaded);
            }
            else
            {
               this._giftPopup = new GiftPopup();
               this._giftPopup.init(this._guiLayer,_loc7_.largeIcon,_loc7_.name,GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,_loc9_,this.keepGiftCallback,this.rejectGiftCallback);
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onGemIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._giftPopup = new GiftPopup();
            this._giftPopup.init(this._guiLayer,param1,this._gemAmount + " Gems",GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,GiftPopup.GIFT_TYPE_GEMS,null,this.keepGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/close");
         this.close();
      }
      
      private function keepGiftCallback() : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._giftingPopupContent.visible = false;
         AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_DAILY_GEM_BONUS,this._randColorIndex,this.setVarCallback);
      }
      
      private function rejectGiftCallback() : void
      {
         this.close();
      }
      
      private function setVarCallback(param1:int, param2:int) : void
      {
         if(this._gemAmount > 0)
         {
            gMainFrame.clientInfo.gemCount += this._gemAmount;
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
      
      private function onPopupDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         this._giftingPopupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._giftingPopupContent.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
         var _loc1_:int = 1;
         while(_loc1_ < 9)
         {
            this._giftingPopupContent["gift" + _loc1_].addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown,false,0,true);
            _loc1_++;
         }
      }
      
      private function removeEventListeners() : void
      {
         this._giftingPopupContent.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._giftingPopupContent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         var _loc1_:int = 1;
         while(_loc1_ < 9)
         {
            this._giftingPopupContent["gift" + _loc1_].removeEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown);
            _loc1_++;
         }
      }
   }
}

