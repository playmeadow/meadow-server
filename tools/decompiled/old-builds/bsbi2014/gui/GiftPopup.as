package gui
{
   import avatar.AvatarManager;
   import avatar.UserInfo;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import ecard.ECard;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.ui.Keyboard;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   
   public class GiftPopup
   {
      
      public static const POPUP_TYPE_JAG:int = 0;
      
      public static const POPUP_TYPE_PROMO:int = 1;
      
      public static const POPUP_TYPE_PRIZE:int = 2;
      
      public static const POPUP_TYPE_JB:int = 3;
      
      public static const POPUP_TYPE_JAMAALIDAY_GIFT:int = 4;
      
      public static const POPUP_TYPE_TOUCH_POOL:int = 5;
      
      public static const POPUP_TYPE_HQ:int = 6;
      
      public static const POPUP_TYPE_TREASURE:int = 7;
      
      public static const POPUP_TYPE_ADVENTURES:int = 8;
      
      public static const GIFT_TYPE_GEMS:int = 0;
      
      public static const GIFT_TYPE_CLOTHING:int = 1;
      
      public static const GIFT_TYPE_DEN_ACC:int = 2;
      
      public static const GIFT_TYPE_DEN_ROOM:int = 3;
      
      public static const GIFT_TYPE_AVT:int = 4;
      
      public static const GIFT_TYPE_DEN_AUDIO:int = 5;
      
      public static const GIFT_TYPE_PET:int = 6;
      
      public static const GIFT_TYPE_ORBS:int = 7;
      
      public static const GIFT_TYPE_DIAMOND:int = 8;
      
      public static const BUTTONS_TYPE_KEEP_DISCARD:int = 0;
      
      public static const BUTTONS_TYPE_OK:int = 1;
      
      public static const BUTTONS_TYPE_CREATE:int = 2;
      
      public static const BUTTONS_TYPE_TAKE_LEAVE:int = 3;
      
      private const GIFT_POPUP_ID:int = 1084;
      
      private var _guiLayer:DisplayObjectContainer;
      
      private var _icon:Sprite;
      
      private var _name:String;
      
      private var _popupType:int;
      
      private var _giftType:int;
      
      private var _enviroType:int;
      
      private var _denyForNonMem:Boolean;
      
      private var _buttonsType:int;
      
      private var _onCloseMsg:String;
      
      private var _msgText:String;
      
      private var _keepCallback:Function;
      
      private var _rejectCallback:Function;
      
      private var _closeCallback:Function;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _popupContent:MovieClip;
      
      private var _closeMsgOkPopup:SBOkPopup;
      
      private var _recyclePopup:RecycleItems;
      
      private var _giftDataArray:Array;
      
      private var _isFromStartup:Boolean;
      
      private var _popupActive:Boolean;
      
      private var _giftDefIdOrAmount:String;
      
      public function GiftPopup()
      {
         super();
      }
      
      public static function giftTypeForECardType(eCardType:int) : int
      {
         if(eCardType == ECard.TYPE_GEMS)
         {
            return GIFT_TYPE_GEMS;
         }
         if(eCardType == ECard.TYPE_CLOTHING)
         {
            return GIFT_TYPE_CLOTHING;
         }
         if(eCardType == ECard.TYPE_DEN_ACC)
         {
            return GIFT_TYPE_DEN_ACC;
         }
         if(eCardType == ECard.TYPE_DEN_ROOM)
         {
            return GIFT_TYPE_DEN_ROOM;
         }
         if(eCardType == ECard.TYPE_AVT)
         {
            return GIFT_TYPE_AVT;
         }
         if(eCardType == ECard.TYPE_DEN_AUDIO)
         {
            return GIFT_TYPE_DEN_AUDIO;
         }
         if(eCardType == ECard.TYPE_PET)
         {
            return GIFT_TYPE_PET;
         }
         if(eCardType == ECard.TYPE_DIAMOND)
         {
            return GIFT_TYPE_DIAMOND;
         }
         return -1;
      }
      
      public static function buttonsTypeForECardType(eCardType:int) : int
      {
         if(eCardType == ECard.TYPE_PET)
         {
            return BUTTONS_TYPE_CREATE;
         }
         if(eCardType == ECard.TYPE_GEMS || eCardType == ECard.TYPE_AVT || eCardType == ECard.TYPE_DIAMOND)
         {
            return BUTTONS_TYPE_OK;
         }
         return BUTTONS_TYPE_KEEP_DISCARD;
      }
      
      public function init(guiLayer:DisplayObjectContainer, icon:Sprite, name:String, giftDefIdOrAmount:int, popupType:int, giftType:int, keepCallback:Function = null, rejectCallback:Function = null, closeCallback:Function = null, denyForNonMem:Boolean = false, buttonsType:int = 0, enviroType:int = 0, onCloseMsg:String = null, msgText:String = null, giftDataArray:Array = null, isFromStartup:Boolean = false) : void
      {
         this._guiLayer = guiLayer;
         this._icon = icon;
         this._name = name;
         this._enviroType = enviroType;
         this._denyForNonMem = denyForNonMem;
         this._buttonsType = buttonsType;
         this._onCloseMsg = onCloseMsg;
         this._giftDefIdOrAmount = giftDefIdOrAmount == 0 ? name : String(giftDefIdOrAmount);
         this.translateNonItemNameForTracking();
         this._popupType = popupType;
         this._giftType = giftType;
         this._keepCallback = keepCallback;
         this._rejectCallback = rejectCallback;
         this._closeCallback = closeCallback;
         this._msgText = msgText;
         this._giftDataArray = giftDataArray;
         this._isFromStartup = isFromStartup;
         DarkenManager.showLoadingSpiral(true);
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.GIFT_POPUP_ID,this.onMediaItemLoaded,this._name);
      }
      
      public function destroy() : void
      {
         this._popupContent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGiftPopup);
         if(Boolean(this._popupContent.buttons.keepBtn.visible))
         {
            this._guiLayer.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keepKeyDown);
            this._popupContent.buttons.keepBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.keepBtnDownHandler);
            this._guiLayer.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.rejectKeyDown);
            this._popupContent.buttons.discardBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler);
         }
         if(Boolean(this._popupContent.buttons.okBtn.visible))
         {
            this._guiLayer.stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.rejectFromOkKeyDown);
            this._popupContent.buttons.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.rejectFromOkButtonDownHandler);
         }
         if(Boolean(this._popupContent.bx.visible))
         {
            this._popupContent.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onXBtnDown);
         }
         this._guiLayer.removeChild(this._popupContent);
         DarkenManager.unDarken(this._popupContent);
         this._popupContent = null;
         this._guiLayer = null;
         this._icon = null;
         this._keepCallback = null;
         this._rejectCallback = null;
         this._closeCallback = null;
      }
      
      public function close() : void
      {
         if(Boolean(this._onCloseMsg))
         {
            this._closeMsgOkPopup = new SBOkPopup(this._guiLayer,this._onCloseMsg,true,this.onCloseMsgOkBtnDown);
            this._onCloseMsg = null;
            return;
         }
         SBTracker.pop();
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
      }
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         var appendMessage:String = null;
         if(Boolean(img))
         {
            appendMessage = this._enviroType == Utility.ENVIRO_OCEAN ? "_Ocean" : "";
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._giftDefIdOrAmount,-1,SBTracker.TYPE_EVENT);
            this._popupContent = MovieClip(img.getChildAt(0));
            this._popupContent.itemLayer.addChild(this._icon);
            LocalizationManager.updateToFit(this._popupContent.buttons.giftNameTxt,img.passback);
            this._popupContent.bx.visible = false;
            if(!AJAudio.hasLoadedGiftUnwrapSfx)
            {
               AJAudio.loadSfx("GiftUnwrap",img.loaderInfo.applicationDomain.getDefinition("GiftUnwrap") as Class,0.6);
               AJAudio.loadSfx("TreasureUnwrap",img.loaderInfo.applicationDomain.getDefinition("TreasureUnwrap") as Class,0.33);
               AJAudio.hasLoadedGiftUnwrapSfx = true;
            }
            this._guiLayer.addChild(this._popupContent);
            if(this._popupType == POPUP_TYPE_PROMO)
            {
               this._popupContent.buttons.treasureNameTxt.visible = false;
               this._popupContent.buttons.treasureTxtBox.visible = false;
               if(this._name.indexOf("Diamond") != -1)
               {
                  LocalizationManager.translateId(this._popupContent.mailboxTitleTxt,11280);
               }
               else
               {
                  LocalizationManager.translateId(this._popupContent.mailboxTitleTxt,11281);
               }
               this._popupContent.present.addEventListener(MouseEvent.MOUSE_DOWN,this.onPresentDownHandler,false,0,true);
               this._popupContent.buttons.visible = false;
            }
            else if(this._popupType == POPUP_TYPE_HQ)
            {
               this._popupContent.buttons.treasureNameTxt.visible = false;
               this._popupContent.buttons.treasureTxtBox.visible = false;
               this._popupContent.present.addEventListener(MouseEvent.MOUSE_DOWN,this.onPresentDownHandler,false,0,true);
               if(!this._isFromStartup)
               {
                  this._popupContent.bx.visible = true;
                  this._popupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onXBtnDown,false,0,true);
               }
               this._popupContent.gotoAndPlay("offMessage");
               if(Boolean(this._msgText))
               {
                  this._popupContent.messageTxt.text = this._msgText;
               }
               this._popupContent.buttons.visible = false;
            }
            else if(this._popupType == POPUP_TYPE_TREASURE)
            {
               this._popupContent.buttons.giftNameTxt.visible = false;
               this._popupContent.buttons.giftTxtBox.visible = false;
               this._popupContent.buttons.treasureNameTxt.text = img.passback;
               this._popupContent.gotoAndStop("offTreasureMessage" + appendMessage);
               this._popupContent.present.addEventListener(MouseEvent.MOUSE_DOWN,this.onPresentDownHandler,false,0,true);
               this._popupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onXBtnDown,false,0,true);
               this._popupContent.buttons.visible = false;
            }
            else if(this._popupType == POPUP_TYPE_ADVENTURES)
            {
               this._popupContent.buttons.giftNameTxt.visible = false;
               this._popupContent.buttons.giftTxtBox.visible = false;
               this._popupContent.buttons.treasureNameTxt.text = img.passback;
               this._popupContent.gotoAndPlay("onChooseTreasure" + appendMessage);
               AJAudio.playTreasureUnwrap();
            }
            else
            {
               this._popupContent.buttons.treasureNameTxt.visible = false;
               this._popupContent.buttons.treasureTxtBox.visible = false;
               if(this._popupType == POPUP_TYPE_JAG || this._popupType == POPUP_TYPE_JB || this._popupType == POPUP_TYPE_TOUCH_POOL)
               {
                  if(this._popupType == POPUP_TYPE_TOUCH_POOL)
                  {
                     LocalizationManager.translateId(this._popupContent.mailboxTitleTxt,11282);
                  }
                  else
                  {
                     LocalizationManager.translateId(this._popupContent.mailboxTitleTxt,11283);
                  }
                  this._popupContent.bx.visible = true;
                  this._popupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onXBtnDown,false,0,true);
               }
               else if(this._popupType == POPUP_TYPE_JAMAALIDAY_GIFT)
               {
                  LocalizationManager.translateId(this._popupContent.mailboxTitleTxt,11283);
               }
               else if(this._popupType == POPUP_TYPE_PRIZE)
               {
                  LocalizationManager.translateId(this._popupContent.mailboxTitleTxt,11282);
               }
               this._popupContent.gotoAndStop("lastFrame");
               AJAudio.playGiftUnwrap();
            }
            this._popupContent.addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftPopup,false,0,true);
            if(this._buttonsType == BUTTONS_TYPE_KEEP_DISCARD)
            {
               this._guiLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keepKeyDown,false,0,true);
               this._popupContent.buttons.keepBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.keepBtnDownHandler,false,0,true);
               this._guiLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.rejectKeyDown,false,0,true);
               this._popupContent.buttons.discardBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler,false,0,true);
               this._popupContent.buttons.okBtn.visible = false;
               this._popupContent.buttons.createBtn.visible = false;
               if(Boolean(this._popupContent.buttons.takeBtn))
               {
                  this._popupContent.buttons.takeBtn.visible = false;
               }
               if(Boolean(this._popupContent.buttons.leaveBtn))
               {
                  this._popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(this._buttonsType == BUTTONS_TYPE_OK)
            {
               this._guiLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.rejectFromOkKeyDown,false,0,true);
               this._popupContent.buttons.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.rejectFromOkButtonDownHandler,false,0,true);
               this._popupContent.buttons.keepBtn.visible = false;
               this._popupContent.buttons.discardBtn.visible = false;
               this._popupContent.buttons.createBtn.visible = false;
               if(Boolean(this._popupContent.buttons.takeBtn))
               {
                  this._popupContent.buttons.takeBtn.visible = false;
               }
               if(Boolean(this._popupContent.buttons.leaveBtn))
               {
                  this._popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(this._buttonsType == BUTTONS_TYPE_CREATE)
            {
               this._popupContent.buttons.createBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCreateButton,false,0,true);
               this._popupContent.buttons.createBtn.visible = true;
               this._popupContent.buttons.keepBtn.visible = false;
               this._popupContent.buttons.discardBtn.visible = false;
               this._popupContent.buttons.okBtn.visible = false;
               if(Boolean(this._popupContent.buttons.takeBtn))
               {
                  this._popupContent.buttons.takeBtn.visible = false;
               }
               if(Boolean(this._popupContent.buttons.leaveBtn))
               {
                  this._popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(this._buttonsType == BUTTONS_TYPE_TAKE_LEAVE)
            {
               this._guiLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keepKeyDown,false,0,true);
               this._popupContent.buttons.takeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.keepBtnDownHandler,false,0,true);
               this._guiLayer.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.rejectKeyDown,false,0,true);
               this._popupContent.buttons.leaveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler,false,0,true);
               this._popupContent.buttons.okBtn.visible = false;
               this._popupContent.buttons.createBtn.visible = false;
               this._popupContent.buttons.keepBtn.visible = false;
               this._popupContent.buttons.discardBtn.visible = false;
            }
            this._popupContent.x = MainFrame.VIEW_WIDTH * 0.5;
            this._popupContent.y = MainFrame.VIEW_HEIGHT * 0.5;
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._popupContent);
         }
      }
      
      private function keepKeyDown(event:KeyboardEvent) : void
      {
         if(this._popupActive == false)
         {
            switch(event.keyCode)
            {
               case Keyboard.ENTER:
               case Keyboard.SPACE:
                  this.keepBtnDownHandler(event);
            }
         }
      }
      
      private function rejectKeyDown(event:KeyboardEvent) : void
      {
         if(this._popupActive == false)
         {
            switch(event.keyCode)
            {
               case Keyboard.BACKSPACE:
               case Keyboard.DELETE:
               case Keyboard.ESCAPE:
                  this.rejectBtnDownHandler(event);
            }
         }
      }
      
      private function rejectFromOkKeyDown(event:KeyboardEvent) : void
      {
         if(this._popupActive == false)
         {
            switch(event.keyCode)
            {
               case Keyboard.BACKSPACE:
               case Keyboard.DELETE:
               case Keyboard.ESCAPE:
                  this.rejectFromOkButtonDownHandler(event);
            }
         }
      }
      
      private function onGiftPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onXBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.close();
      }
      
      private function onPresentDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var appendMessage:String = this._enviroType == Utility.ENVIRO_OCEAN ? "_Ocean" : "";
         this._popupContent.buttons.visible = true;
         this._popupContent.present.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPresentDownHandler);
         this._popupContent.gotoAndPlay(this._popupType == POPUP_TYPE_HQ ? "onMessage" : (this._popupType == POPUP_TYPE_TREASURE ? "onTreasureMessage" + appendMessage : "on"));
         if(this._popupType == POPUP_TYPE_TREASURE)
         {
            AJAudio.playTreasureUnwrap();
         }
         else
         {
            AJAudio.playGiftUnwrap();
         }
      }
      
      private function keepBtnDownHandler(evt:Event) : void
      {
         var inv:Array = null;
         var invSize:int = 0;
         var invMaxSize:int = 0;
         var recycleId:int = 0;
         var fullItems:Array = null;
         var ui:UserInfo = null;
         var i:int = 0;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this._denyForNonMem && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.JAG,"Receiving_Gift");
         }
         else
         {
            inv = [];
            if(this._giftType == GIFT_TYPE_CLOTHING)
            {
               if(Boolean(gMainFrame.userInfo.playerAvatarInfo))
               {
                  fullItems = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               }
               if(this._enviroType == Utility.ENVIRO_LAND)
               {
                  if(fullItems.length > 0)
                  {
                     inv = Utility.clothingItemListByEnviroType(fullItems,Utility.ENVIRO_LAND);
                  }
                  recycleId = RecycleItems.RECYCLE_ACCESSORIES_LAND_ONLY;
               }
               else
               {
                  if(fullItems.length > 0)
                  {
                     inv = Utility.clothingItemListByEnviroType(fullItems,Utility.ENVIRO_OCEAN);
                  }
                  recycleId = RecycleItems.RECYCLE_ACCESSORIES_OCEAN_ONLY;
               }
               if(Boolean(inv))
               {
                  invSize = int(inv.length);
               }
               invMaxSize = Shop.maxItems;
            }
            else if(this._giftType == GIFT_TYPE_DEN_ACC)
            {
               if(this._enviroType == Utility.ENVIRO_LAND)
               {
                  if(Boolean(gMainFrame.userInfo.playerUserInfo))
                  {
                     ui = gMainFrame.userInfo.playerUserInfo;
                     if(ui.denItemsFull.length > 0)
                     {
                        inv = Utility.denItemListByEnviroType(ui.denItemsFull,Utility.ENVIRO_LAND);
                     }
                  }
                  recycleId = RecycleItems.RECYCLE_DEN_ITEMS_LAND_ONLY;
               }
               else
               {
                  if(Boolean(gMainFrame.userInfo.playerUserInfo) && gMainFrame.userInfo.playerUserInfo.denItemsFull.length > 0)
                  {
                     inv = Utility.denItemListByEnviroType(gMainFrame.userInfo.playerUserInfo.denItemsFull,Utility.ENVIRO_OCEAN);
                  }
                  recycleId = RecycleItems.RECYCLE_DEN_ITEMS_OCEAN_ONLY;
               }
               if(Boolean(inv))
               {
                  invSize = int(inv.length);
               }
               invMaxSize = Shop.maxDenItems;
            }
            else if(this._giftType == GIFT_TYPE_DEN_AUDIO)
            {
               if(Boolean(gMainFrame.userInfo.playerUserInfo) && gMainFrame.userInfo.playerUserInfo.denItemsFull.length > 0)
               {
                  inv = Utility.denItemListByEnviroType(gMainFrame.userInfo.playerUserInfo.denItemsFull,-1,true);
               }
               recycleId = RecycleItems.RECYCLE_DEN_AUDIO;
               if(Boolean(inv))
               {
                  invSize = int(inv.length);
               }
               invMaxSize = Shop.maxAudioItems;
            }
            else if(this._giftType == GIFT_TYPE_DEN_ROOM)
            {
               inv = DenSwitch.denList;
               recycleId = DenSwitch.RECYCLE_DEN_ROOM;
               if(Boolean(inv))
               {
                  for(i = 0; i < inv.length; i++)
                  {
                     if(Boolean(inv[i]))
                     {
                        invSize++;
                     }
                  }
               }
               invMaxSize = SwitchManager.NUM_DEN_ROOM_SLOTS;
            }
            else
            {
               if(this._popupType == POPUP_TYPE_ADVENTURES)
               {
                  if(this._giftType == GIFT_TYPE_GEMS || this._giftType == GIFT_TYPE_ORBS)
                  {
                     this.keepItem();
                     return;
                  }
               }
               trace("Invalid type for GiftPopup keep button. type=" + this._giftType);
            }
            if(Utility.canGift() || this._popupType != POPUP_TYPE_JAG)
            {
               if(invSize >= invMaxSize)
               {
                  this._popupActive = true;
                  new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14746),true,this.confirmRecycleHandler,recycleId);
               }
               else
               {
                  this.keepItem();
               }
            }
            else
            {
               this._popupActive = true;
               new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14747),true,this.okPopupComplete);
            }
         }
      }
      
      private function okPopupComplete(evt:MouseEvent) : void
      {
         this._popupActive = false;
         SBOkPopup.destroyInParentChain(evt.target.parent);
      }
      
      private function rejectFromOkButtonDownHandler(evt:Event) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this._giftType == GIFT_TYPE_GEMS || this._giftType == GIFT_TYPE_ORBS || this._giftType == GIFT_TYPE_DIAMOND)
         {
            GuiManager.startGemsFlash();
         }
         SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._giftDefIdOrAmount + "/ok",-1,SBTracker.TYPE_EVENT);
         if(this._rejectCallback != null)
         {
            this._rejectCallback();
         }
         else
         {
            this.close();
         }
      }
      
      private function rejectBtnDownHandler(evt:Event) : void
      {
         var localizedMessage:String = null;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this._popupType != POPUP_TYPE_TREASURE)
         {
            if(this._popupType == POPUP_TYPE_PROMO)
            {
               localizedMessage = LocalizationManager.translateIdAndInsertOnly(14748,this._popupContent.mailboxTitleTxt.text.toLowerCase());
            }
            else if(this._popupType == POPUP_TYPE_HQ)
            {
               localizedMessage = LocalizationManager.translateIdOnly(14749);
            }
            else
            {
               localizedMessage = LocalizationManager.translateIdAndInsertOnly(14750,this._popupContent.mailboxTitleTxt.text.toLowerCase());
            }
            this._popupActive = true;
            new SBYesNoPopup(this._guiLayer,localizedMessage,true,this.onConfirmReject);
         }
         else
         {
            this._popupActive = true;
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14919),true,this.onConfirmReject);
         }
      }
      
      private function onCreateButton(evt:MouseEvent) : void
      {
         PetManager.openPetFinder(this._name.toLowerCase().replace(/[\s\r\n]*/gim,""),this.onPetCreated,true,this._giftDataArray);
      }
      
      private function onPetCreated() : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
      }
      
      private function onConfirmReject(o:Object) : void
      {
         if(Boolean(o.status))
         {
            SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._giftDefIdOrAmount + "/reject",-1,SBTracker.TYPE_EVENT);
            if(this._rejectCallback != null)
            {
               this._rejectCallback();
            }
            else
            {
               this.close();
            }
         }
         this._popupActive = false;
      }
      
      private function keepItem() : void
      {
         SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._giftDefIdOrAmount + "/keep",-1,SBTracker.TYPE_EVENT);
         if(this._keepCallback != null)
         {
            this._keepCallback();
         }
         else
         {
            this.close();
         }
      }
      
      private function onCloseMsgOkBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._closeMsgOkPopup.destroy();
         this._closeMsgOkPopup = null;
         this.close();
      }
      
      private function confirmRecycleHandler(o:Object) : void
      {
         var recycleType:int = 0;
         if(Boolean(o.status))
         {
            recycleType = int(o.passback);
            if(recycleType == DenSwitch.RECYCLE_DEN_ROOM)
            {
               GuiManager.openDenRoomSwitcher(true,this.onDenRoomRecycleClose);
            }
            else
            {
               this._recyclePopup = new RecycleItems();
               this._recyclePopup.init(recycleType,this._guiLayer,true,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,this._enviroType == AvatarManager.roomEnviroType);
            }
         }
         this._popupActive = false;
      }
      
      private function onRecycleClose(itemRecycled:Boolean = false) : void
      {
         if(Boolean(this._recyclePopup))
         {
            this._recyclePopup.destroy();
            this._recyclePopup = null;
         }
         if(itemRecycled)
         {
            this.keepItem();
         }
      }
      
      private function onDenRoomRecycleClose(itemRecycled:Boolean = false) : void
      {
         GuiManager.onDenSwitchClose(true);
         if(itemRecycled)
         {
            this.keepItem();
         }
      }
      
      private function popupTypeToString(type:int) : String
      {
         switch(type)
         {
            case POPUP_TYPE_JAG:
               return "JAG";
            case POPUP_TYPE_PRIZE:
               return "Prize";
            case POPUP_TYPE_PROMO:
               return "Promo";
            case POPUP_TYPE_JB:
               return "JB";
            case POPUP_TYPE_TOUCH_POOL:
               return "TouchPool";
            default:
               return "";
         }
      }
      
      private function translateNonItemNameForTracking() : void
      {
         if(this._giftType == GIFT_TYPE_GEMS)
         {
            this._giftDefIdOrAmount += " gems";
         }
         else if(this._giftType == GIFT_TYPE_ORBS)
         {
            this._giftDefIdOrAmount += " orbs";
         }
         else if(this._giftType == GIFT_TYPE_DIAMOND)
         {
            this._giftDefIdOrAmount += " diamonds";
         }
      }
   }
}

