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
   import flash.events.MouseEvent;
   import loader.MediaHelper;
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
      
      public function GiftPopup()
      {
         super();
      }
      
      public static function giftTypeForECardType(param1:int) : int
      {
         if(param1 == ECard.TYPE_GEMS)
         {
            return GIFT_TYPE_GEMS;
         }
         if(param1 == ECard.TYPE_CLOTHING)
         {
            return GIFT_TYPE_CLOTHING;
         }
         if(param1 == ECard.TYPE_DEN_ACC)
         {
            return GIFT_TYPE_DEN_ACC;
         }
         if(param1 == ECard.TYPE_DEN_ROOM)
         {
            return GIFT_TYPE_DEN_ROOM;
         }
         if(param1 == ECard.TYPE_AVT)
         {
            return GIFT_TYPE_AVT;
         }
         if(param1 == ECard.TYPE_DEN_AUDIO)
         {
            return GIFT_TYPE_DEN_AUDIO;
         }
         if(param1 == ECard.TYPE_PET)
         {
            return GIFT_TYPE_PET;
         }
         if(param1 == ECard.TYPE_DIAMOND)
         {
            return GIFT_TYPE_DIAMOND;
         }
         return -1;
      }
      
      public static function buttonsTypeForECardType(param1:int) : int
      {
         if(param1 == ECard.TYPE_PET)
         {
            return BUTTONS_TYPE_CREATE;
         }
         if(param1 == ECard.TYPE_GEMS || param1 == ECard.TYPE_AVT || param1 == ECard.TYPE_DIAMOND)
         {
            return BUTTONS_TYPE_OK;
         }
         return BUTTONS_TYPE_KEEP_DISCARD;
      }
      
      public function init(param1:DisplayObjectContainer, param2:Sprite, param3:String, param4:int, param5:int, param6:Function = null, param7:Function = null, param8:Function = null, param9:Boolean = false, param10:int = 0, param11:int = 0, param12:String = null, param13:String = null, param14:Array = null, param15:Boolean = false) : void
      {
         this._guiLayer = param1;
         this._icon = param2;
         this._name = param3;
         this._enviroType = param11;
         this._denyForNonMem = param9;
         this._buttonsType = param10;
         this._onCloseMsg = param12;
         this._popupType = param4;
         this._giftType = param5;
         this._keepCallback = param6;
         this._rejectCallback = param7;
         this._closeCallback = param8;
         this._msgText = param13;
         this._giftDataArray = param14;
         this._isFromStartup = param15;
         DarkenManager.showLoadingSpiral(true);
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.GIFT_POPUP_ID,this.onMediaItemLoaded,this._name);
      }
      
      public function destroy() : void
      {
         this._popupContent.removeEventListener(MouseEvent.MOUSE_DOWN,this.onGiftPopup);
         if(this._popupContent.buttons.keepBtn.visible)
         {
            this._popupContent.buttons.keepBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.keepBtnDownHandler);
            this._popupContent.buttons.discardBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler);
         }
         if(this._popupContent.buttons.okBtn.visible)
         {
            this._popupContent.buttons.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler);
         }
         if(this._popupContent.bx.visible)
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
         if(this._onCloseMsg)
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
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._name);
            this._popupContent = MovieClip(param1.getChildAt(0));
            this._popupContent.itemLayer.addChild(this._icon);
            this._popupContent.buttons.giftNameTxt.text = param1.passback;
            this._popupContent.bx.visible = false;
            if(!AJAudio.hasLoadedGiftUnwrapSfx)
            {
               AJAudio.loadSfx("GiftUnwrap",param1.loaderInfo.applicationDomain.getDefinition("GiftUnwrap") as Class,0.6);
               AJAudio.loadSfx("TreasureUnwrap",param1.loaderInfo.applicationDomain.getDefinition("TreasureUnwrap") as Class,0.6);
               AJAudio.hasLoadedGiftUnwrapSfx = true;
            }
            if(this._popupType == POPUP_TYPE_PROMO)
            {
               this._popupContent.buttons.treasureNameTxt.visible = false;
               this._popupContent.buttons.treasureTxtBox.visible = false;
               if(this._name.indexOf("Diamond") != -1)
               {
                  this._popupContent.mailboxTitleTxt.text = "Member Gift";
               }
               else
               {
                  this._popupContent.mailboxTitleTxt.text = "Promo Gift";
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
               if(this._msgText)
               {
                  this._popupContent.messageTxt.text = this._msgText;
               }
               this._popupContent.buttons.visible = false;
            }
            else if(this._popupType == POPUP_TYPE_TREASURE)
            {
               this._popupContent.buttons.giftNameTxt.visible = false;
               this._popupContent.buttons.giftTxtBox.visible = false;
               this._popupContent.buttons.treasureNameTxt.text = param1.passback;
               this._popupContent.gotoAndStop("offTreasureMessage");
               this._popupContent.present.addEventListener(MouseEvent.MOUSE_DOWN,this.onPresentDownHandler,false,0,true);
               this._popupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onXBtnDown,false,0,true);
               this._popupContent.buttons.visible = false;
            }
            else if(this._popupType == POPUP_TYPE_ADVENTURES)
            {
               this._popupContent.buttons.giftNameTxt.visible = false;
               this._popupContent.buttons.giftTxtBox.visible = false;
               this._popupContent.buttons.treasureNameTxt.text = param1.passback;
               this._popupContent.gotoAndPlay("onChooseTreasure");
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
                     this._popupContent.mailboxTitleTxt.text = "Your Prize";
                  }
                  else
                  {
                     this._popupContent.mailboxTitleTxt.text = "Your Gift";
                  }
                  this._popupContent.bx.visible = true;
                  this._popupContent.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onXBtnDown,false,0,true);
               }
               else if(this._popupType == POPUP_TYPE_JAMAALIDAY_GIFT)
               {
                  this._popupContent.mailboxTitleTxt.text = "Your Gift";
               }
               else if(this._popupType == POPUP_TYPE_PRIZE)
               {
                  this._popupContent.mailboxTitleTxt.text = "Your Prize";
               }
               this._popupContent.gotoAndStop("lastFrame");
               AJAudio.playGiftUnwrap();
            }
            this._popupContent.addEventListener(MouseEvent.MOUSE_DOWN,this.onGiftPopup,false,0,true);
            if(this._buttonsType == BUTTONS_TYPE_KEEP_DISCARD)
            {
               this._popupContent.buttons.keepBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.keepBtnDownHandler,false,0,true);
               this._popupContent.buttons.discardBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler,false,0,true);
               this._popupContent.buttons.okBtn.visible = false;
               this._popupContent.buttons.createBtn.visible = false;
               if(this._popupContent.buttons.takeBtn)
               {
                  this._popupContent.buttons.takeBtn.visible = false;
               }
               if(this._popupContent.buttons.leaveBtn)
               {
                  this._popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(this._buttonsType == BUTTONS_TYPE_OK)
            {
               this._popupContent.buttons.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler,false,0,true);
               this._popupContent.buttons.keepBtn.visible = false;
               this._popupContent.buttons.discardBtn.visible = false;
               this._popupContent.buttons.createBtn.visible = false;
               if(this._popupContent.buttons.takeBtn)
               {
                  this._popupContent.buttons.takeBtn.visible = false;
               }
               if(this._popupContent.buttons.leaveBtn)
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
               if(this._popupContent.buttons.takeBtn)
               {
                  this._popupContent.buttons.takeBtn.visible = false;
               }
               if(this._popupContent.buttons.leaveBtn)
               {
                  this._popupContent.buttons.leaveBtn.visible = false;
               }
            }
            else if(this._buttonsType == BUTTONS_TYPE_TAKE_LEAVE)
            {
               this._popupContent.buttons.takeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.keepBtnDownHandler,false,0,true);
               this._popupContent.buttons.leaveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.rejectBtnDownHandler,false,0,true);
               this._popupContent.buttons.okBtn.visible = false;
               this._popupContent.buttons.createBtn.visible = false;
               this._popupContent.buttons.keepBtn.visible = false;
               this._popupContent.buttons.discardBtn.visible = false;
            }
            this._popupContent.x = MainFrame.VIEW_WIDTH * 0.5;
            this._popupContent.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._guiLayer.addChild(this._popupContent);
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(this._popupContent);
         }
      }
      
      private function onGiftPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onXBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.close();
      }
      
      private function onPresentDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._popupContent.buttons.visible = true;
         this._popupContent.present.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPresentDownHandler);
         this._popupContent.gotoAndPlay(this._popupType == POPUP_TYPE_HQ ? "onMessage" : (this._popupType == POPUP_TYPE_TREASURE ? "onTreasureMessage" : "on"));
         if(this._popupType == POPUP_TYPE_TREASURE)
         {
            AJAudio.playTreasureUnwrap();
         }
         else
         {
            AJAudio.playGiftUnwrap();
         }
      }
      
      private function keepBtnDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:UserInfo = null;
         var _loc8_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._denyForNonMem && !gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.JAG,"Receiving_Gift");
         }
         else
         {
            _loc2_ = [];
            if(this._giftType == GIFT_TYPE_CLOTHING)
            {
               if(gMainFrame.userInfo.playerAvatarInfo)
               {
                  _loc6_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               }
               if(this._enviroType == Utility.ENVIRO_LAND)
               {
                  if(_loc6_.length > 0)
                  {
                     _loc2_ = Utility.clothingItemListByEnviroType(_loc6_,Utility.ENVIRO_LAND);
                  }
                  _loc5_ = RecycleItems.RECYCLE_ACCESSORIES_LAND_ONLY;
               }
               else
               {
                  if(_loc6_.length > 0)
                  {
                     _loc2_ = Utility.clothingItemListByEnviroType(_loc6_,Utility.ENVIRO_OCEAN);
                  }
                  _loc5_ = RecycleItems.RECYCLE_ACCESSORIES_OCEAN_ONLY;
               }
               if(_loc2_)
               {
                  _loc3_ = int(_loc2_.length);
               }
               _loc4_ = Shop.maxItems;
            }
            else if(this._giftType == GIFT_TYPE_DEN_ACC)
            {
               if(this._enviroType == Utility.ENVIRO_LAND)
               {
                  if(gMainFrame.userInfo.playerUserInfo)
                  {
                     _loc7_ = gMainFrame.userInfo.playerUserInfo;
                     if(_loc7_.denItemsFull.length > 0)
                     {
                        _loc2_ = Utility.denItemListByEnviroType(_loc7_.denItemsFull,Utility.ENVIRO_LAND);
                     }
                  }
                  _loc5_ = RecycleItems.RECYCLE_DEN_ITEMS_LAND_ONLY;
               }
               else
               {
                  if(Boolean(gMainFrame.userInfo.playerUserInfo) && gMainFrame.userInfo.playerUserInfo.denItemsFull.length > 0)
                  {
                     _loc2_ = Utility.denItemListByEnviroType(gMainFrame.userInfo.playerUserInfo.denItemsFull,Utility.ENVIRO_OCEAN);
                  }
                  _loc5_ = RecycleItems.RECYCLE_DEN_ITEMS_OCEAN_ONLY;
               }
               if(_loc2_)
               {
                  _loc3_ = int(_loc2_.length);
               }
               _loc4_ = Shop.maxDenItems;
            }
            else if(this._giftType == GIFT_TYPE_DEN_AUDIO)
            {
               if(Boolean(gMainFrame.userInfo.playerUserInfo) && gMainFrame.userInfo.playerUserInfo.denItemsFull.length > 0)
               {
                  _loc2_ = Utility.denItemListByEnviroType(gMainFrame.userInfo.playerUserInfo.denItemsFull,-1,true);
               }
               _loc5_ = RecycleItems.RECYCLE_DEN_AUDIO;
               if(_loc2_)
               {
                  _loc3_ = int(_loc2_.length);
               }
               _loc4_ = Shop.maxAudioItems;
            }
            else if(this._giftType == GIFT_TYPE_DEN_ROOM)
            {
               _loc2_ = DenSwitch.denList;
               _loc5_ = DenSwitch.RECYCLE_DEN_ROOM;
               if(_loc2_)
               {
                  _loc8_ = 0;
                  while(_loc8_ < _loc2_.length)
                  {
                     if(_loc2_[_loc8_])
                     {
                        _loc3_++;
                     }
                     _loc8_++;
                  }
               }
               _loc4_ = SwitchManager.NUM_DEN_ROOM_SLOTS;
            }
            else if(this._popupType == POPUP_TYPE_ADVENTURES)
            {
               if(this._giftType == GIFT_TYPE_GEMS || this._giftType == GIFT_TYPE_ORBS)
               {
                  this.keepItem();
                  return;
               }
            }
            if(Utility.canGift() || this._popupType != POPUP_TYPE_JAG)
            {
               if(_loc3_ >= _loc4_)
               {
                  new SBYesNoPopup(this._guiLayer,"Your inventory is full. Recycle an item to free up space?",true,this.confirmRecycleHandler,_loc5_);
               }
               else
               {
                  this.keepItem();
               }
            }
            else
            {
               new SBOkPopup(this._guiLayer,"Gifting is disabled. Please contact AJHQ for more info.");
            }
         }
      }
      
      private function rejectBtnDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
            if(param1.currentTarget.name == "okBtn")
            {
               if(this._giftType == GIFT_TYPE_GEMS || this._giftType == GIFT_TYPE_ORBS)
               {
                  GuiManager.startGemsFlash();
               }
               SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._name + "/ok");
               if(this._rejectCallback != null)
               {
                  this._rejectCallback();
               }
               else
               {
                  this.close();
               }
            }
            else if(this._popupType != POPUP_TYPE_TREASURE)
            {
               _loc2_ = "";
               _loc2_ += this._popupType == POPUP_TYPE_PROMO ? " your " : " ";
               _loc2_ += this._popupType == POPUP_TYPE_HQ ? "your gift from Animal Jam HQ" : this._popupContent.mailboxTitleTxt.text.toLowerCase();
               new SBYesNoPopup(this._guiLayer,"Are you sure you want to discard" + _loc2_ + "?",true,this.onConfirmReject);
            }
            else
            {
               new SBYesNoPopup(this._guiLayer,"Are you sure you don\'t want this treasure?",true,this.onConfirmReject);
            }
         }
      }
      
      private function onCreateButton(param1:MouseEvent) : void
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
      
      private function onConfirmReject(param1:Object) : void
      {
         if(param1.status)
         {
            SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._name + "/reject");
            if(this._rejectCallback != null)
            {
               this._rejectCallback();
            }
            else
            {
               this.close();
            }
         }
      }
      
      private function keepItem() : void
      {
         SBTracker.trackPageview("game/play/popup/gift/" + this.popupTypeToString(this._popupType) + "/#" + this._name + "/keep");
         if(this._keepCallback != null)
         {
            this._keepCallback();
         }
         else
         {
            this.close();
         }
      }
      
      private function onCloseMsgOkBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._closeMsgOkPopup.destroy();
         this._closeMsgOkPopup = null;
         this.close();
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(param1.status)
         {
            _loc2_ = int(param1.passback);
            if(_loc2_ == DenSwitch.RECYCLE_DEN_ROOM)
            {
               GuiManager.openDenRoomSwitcher(true,this.onDenRoomRecycleClose);
            }
            else
            {
               this._recyclePopup = new RecycleItems();
               this._recyclePopup.init(_loc2_,this._guiLayer,true,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,this._enviroType == AvatarManager.roomEnviroType);
            }
         }
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(this._recyclePopup)
         {
            this._recyclePopup.destroy();
            this._recyclePopup = null;
         }
         if(param1)
         {
            this.keepItem();
         }
      }
      
      private function onDenRoomRecycleClose(param1:Boolean = false) : void
      {
         GuiManager.onDenSwitchClose(true);
         if(param1)
         {
            this.keepItem();
         }
      }
      
      private function popupTypeToString(param1:int) : String
      {
         switch(param1)
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
   }
}

