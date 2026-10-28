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
      
      public function DailyGiftManager()
      {
         super();
      }
      
      public function init(giftIndex:int, closeCallback:Function) : void
      {
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = closeCallback;
         this._giftIndex = giftIndex;
         this._giftingPopupMediaHelper = new MediaHelper();
         this._giftingPopupMediaHelper.init(2539,this.giftingPopupCallback);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(Boolean(this._giftPopup))
         {
            this._giftPopup.destroy();
            this._giftPopup = null;
         }
         if(Boolean(this._giftingPopupContent))
         {
            DarkenManager.unDarken(this._giftingPopupContent.parent);
            this._guiLayer.removeChild(this._giftingPopupContent.parent);
            this._giftingPopupContent.visible = false;
            this._giftingPopupContent = null;
            this._giftingPopupMediaHelper = null;
         }
      }
      
      private function giftingPopupCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            DarkenManager.showLoadingSpiral(false);
            this._giftingPopupContent = MovieClip(img.getChildAt(0));
            img.x = MainFrame.VIEW_WIDTH * 0.5;
            img.y = MainFrame.VIEW_HEIGHT * 0.5;
            this.setupPopup();
            this.addEventListeners();
            this._guiLayer.addChild(img);
            DarkenManager.darken(img);
         }
      }
      
      private function setupPopup() : void
      {
         var currGift:MovieClip = null;
         var itemsReceivedValue:int = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(this.GIFTS_RECEIVED_UV));
         for(var i:int = 1; i <= 25; i++)
         {
            currGift = this._giftingPopupContent["gift" + i];
            if(i < this._giftIndex + 1)
            {
               if(itemsReceivedValue != -1 && (itemsReceivedValue & 1 << i - 1) > 0)
               {
                  currGift.gotoAndStop("opened");
               }
               else
               {
                  currGift.gotoAndStop("missed");
               }
            }
            else if(i > this._giftIndex + 1)
            {
               currGift.gotoAndStop("unopened");
               currGift.unopenedGift.highlight.visible = false;
               currGift.unopenedGift.openTag.visible = false;
               currGift.unopenedGift.currIndex = i;
               currGift.unopenedGift.shine.visible = false;
               currGift.unopenedGift.gift.addEventListener(MouseEvent.MOUSE_DOWN,this.onFutureGiftDown,false,0,true);
            }
            else if(i == this._giftIndex + 1)
            {
               currGift.gotoAndStop("unopened");
               currGift.unopenedGift.openTag.visible = true;
               currGift.unopenedGift.highlight.visible = false;
               currGift.unopenedGift.highlight.mouseChildren = false;
               currGift.unopenedGift.highlight.mouseEnabled = false;
               currGift.unopenedGift.shine.mouseChildren = false;
               currGift.unopenedGift.shine.mouseEnabled = false;
               currGift.unopenedGift.gift.addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown,false,0,true);
               currGift.unopenedGift.gift.addEventListener(MouseEvent.ROLL_OVER,this.onGiftOver,false,0,true);
               currGift.unopenedGift.gift.addEventListener(MouseEvent.ROLL_OUT,this.onGiftOut,false,0,true);
            }
         }
      }
      
      public function setupGiftPopup() : void
      {
         var currItem:Object = null;
         var def:Object = null;
         var giftType:int = 0;
         var CLOTHING_ITEM:int = 0;
         var DEN_ITEM:int = 1;
         var GEMS:int = 2;
         var DIAMONDS:int = 3;
         var giftValue:Array = new Array(DEN_ITEM,GEMS,CLOTHING_ITEM,DEN_ITEM,GEMS,DEN_ITEM,CLOTHING_ITEM,DIAMONDS,DEN_ITEM,DEN_ITEM,GEMS,CLOTHING_ITEM,DEN_ITEM,GEMS,DEN_ITEM,DEN_ITEM,GEMS,DEN_ITEM,DEN_ITEM,DEN_ITEM,DIAMONDS,DEN_ITEM,CLOTHING_ITEM,CLOTHING_ITEM,GEMS);
         var defArray:Array = new Array(1354,300,690,1349,400,1352,691,1,1351,715,600,526,1353,700,1348,1350,800,1161,1164,1165,1,717,525,692,1000);
         var randColor:int = 0;
         var index:int = int(gMainFrame.clientInfo.dailyGiftIndex);
         if(index <= giftValue.length)
         {
            if(giftValue[this._giftIndex] == CLOTHING_ITEM)
            {
               def = ItemXtCommManager.getItemDef(defArray[index]);
               this._randColorIndex = (def.colors.length - 1) * Math.random();
               currItem = new Item();
               currItem.init(def.defId,0,def.colors[this._randColorIndex],0,0,true);
               giftType = GiftPopup.GIFT_TYPE_CLOTHING;
            }
            else if(giftValue[this._giftIndex] == DEN_ITEM)
            {
               def = DenXtCommManager.getDenItemDef(defArray[index]);
               currItem = new DenItem();
               currItem.initShopItem(def.id,0);
               giftType = GiftPopup.GIFT_TYPE_DEN_ACC;
            }
            else if(giftValue[this._giftIndex] == GEMS)
            {
               giftType = GiftPopup.GIFT_TYPE_GEMS;
            }
            else if(giftValue[this._giftIndex] == DIAMONDS)
            {
               giftType = GiftPopup.GIFT_TYPE_DIAMOND;
            }
            if(giftType == GiftPopup.GIFT_TYPE_GEMS)
            {
               this._gemAmount = defArray[index];
               this._giftingPopupMediaHelper = new MediaHelper();
               this._giftingPopupMediaHelper.init(StartupPopups.GEMS_MEDIA_ID,this.onGemIconLoaded);
            }
            else if(giftType == GiftPopup.GIFT_TYPE_DIAMOND)
            {
               this._diamondAmount = defArray[index];
               this._giftingPopupMediaHelper = new MediaHelper();
               this._giftingPopupMediaHelper.init(StartupPopups.DIAMOND_MEDIA_ID,this.onDiamondIconLoaded);
            }
            else
            {
               this._giftPopup = new GiftPopup();
               this._giftPopup.init(this._guiLayer,currItem.largeIcon,currItem.name,defArray[index],GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,giftType,this.keepGiftCallback,this.rejectGiftCallback);
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private function onGemIconLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._giftPopup = new GiftPopup();
            this._giftPopup.init(this._guiLayer,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.GEMS_CAPITALIZED,this._gemAmount),this._gemAmount,GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,GiftPopup.GIFT_TYPE_GEMS,null,this.keepGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
      }
      
      private function onDiamondIconLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._giftPopup = new GiftPopup();
            this._giftPopup.init(this._guiLayer,img,LocalizationManager.translateIdAndInsertOnly(LocalizationManager.DIAMONDS_CAPITALIZED,this._diamondAmount),this._gemAmount,GiftPopup.POPUP_TYPE_JAMAALIDAY_GIFT,GiftPopup.GIFT_TYPE_DIAMOND,null,this.keepGiftCallback,null,false,GiftPopup.BUTTONS_TYPE_OK);
         }
      }
      
      private function onClose(m:MouseEvent) : void
      {
         m.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/close");
         this.close();
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
         this.close();
      }
      
      private function setVarCallback(varDefId:int, value:int) : void
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
      
      private function onGiftDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBTracker.trackPageview("game/play/popup/dailyGift/" + evt.currentTarget.name);
         this.setupGiftPopup();
      }
      
      private function onFutureGiftDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var numDays:int = evt.currentTarget.parent.currIndex - (this._giftIndex + 1);
         new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(numDays == 1 ? 11383 : 11384,numDays));
      }
      
      private function onGiftOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.parent.highlight.visible = true;
      }
      
      private function onGiftOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.parent.highlight.visible = false;
      }
      
      private function onPopupDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         this._giftingPopupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._giftingPopupContent.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         var currGift:MovieClip = null;
         this._giftingPopupContent.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._giftingPopupContent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopupDown);
         for(var i:int = this._giftIndex + 1; i <= 25; i++)
         {
            currGift = this._giftingPopupContent["gift" + i];
            currGift.unopenedGift.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGiftDown);
            currGift.unopenedGift.removeEventListener(MouseEvent.ROLL_OVER,this.onGiftOver);
            currGift.unopenedGift.removeEventListener(MouseEvent.ROLL_OUT,this.onGiftOut);
         }
      }
   }
}

