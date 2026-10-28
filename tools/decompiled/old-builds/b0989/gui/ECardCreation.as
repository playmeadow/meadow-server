package gui
{
   import avatar.AvatarManager;
   import buddy.BuddyEvent;
   import buddy.BuddyXtCommManager;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.*;
   import ecard.ECard;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.utils.getDefinitionByName;
   import flash.utils.setTimeout;
   
   public class ECardCreation
   {
      
      public static var ffmCallback:Function;
      
      private const NUM_VIS_STAMP_ROWS:int = 3;
      
      private var _eCardCreation:MovieClip;
      
      private var _eCardClothes:DenAndClothesItemSelect;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _onCloseCallback:Function;
      
      private var _backBtnCallback:Function;
      
      private var _toUserName:String;
      
      private var _currCardId:int;
      
      private var _currStampId:int;
      
      private var _messageType:int;
      
      private var _msg:String;
      
      private var _type:int;
      
      private var _giftItemIdx:int = -1;
      
      private var _isAllowedToType:Boolean;
      
      private var _cards:Array;
      
      private var _stamps:Array;
      
      private var _buddyList:MovieClip;
      
      private var _buddyListScrollButtons:SBScrollbar;
      
      private var OfflineBuddyListWindow:Class;
      
      private var OnlineBuddyListWindow:Class;
      
      private var _dummyMsgTxt:TextField;
      
      private var _stampWindow:WindowGenerator;
      
      private var _stampListScrollButtons:SBScrollbar;
      
      private var _stampBtn:MovieClip;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _guiLayer:DisplayLayer;
      
      public function ECardCreation()
      {
         super();
      }
      
      public function init(param1:DisplayLayer, param2:String, param3:Array, param4:Array, param5:Function, param6:Function, param7:Boolean = false) : void
      {
         this._guiLayer = param1;
         this._eCardCreation = ECardManager.eCardInboxAndCreation;
         this._eCardCreation.visible = true;
         if(this._eCardCreation.currentFrameLabel != "create")
         {
            this._eCardCreation.gotoAndStop("create");
         }
         DarkenManager.showLoadingSpiral(false);
         this.OfflineBuddyListWindow = getDefinitionByName("OfflineBuddyListWindow") as Class;
         this.OnlineBuddyListWindow = getDefinitionByName("OnlineBuddyListWindow") as Class;
         this._eCardClothes = new DenAndClothesItemSelect();
         this._eCardClothes.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.itemArray,this._guiLayer,this.onECardClothesAddBtn,this.onECardClothesClose);
         this._eCardClothes.showHide();
         SafeChatManager.buildSafeChatTree(this._eCardCreation.chatTree,"ECardTextTreeNode",SafeChatManager.TREE_ECARDTEXT,this.onECardTextClose,null);
         SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
         this._predictiveTextManager = new PredictiveTextManager();
         this._predictiveTextManager.init(this._eCardCreation.textBtn.currTxt,PredictiveTextTree.defaultRoot,PredictiveTextManager.USE_TYPE_ECARD,this._eCardCreation.predictTxtTag,null,null,this.checkShouldCompleteSuggestion);
         this._eCardCreation.textBtn.currTxt.text = this._eCardCreation.msgTxt.text = SafeChatManager.ctNodes[0][0];
         this._msg = "0,0";
         this._eCardCreation.buddyList.visible = false;
         this._eCardCreation.giftIcon.visible = false;
         this._eCardCreation.stampList.visible = false;
         this._eCardCreation.cardSlot.noMailPopup.visible = false;
         this._eCardCreation.textBtn.currTxt.tabEnabled = false;
         this._eCardCreation.textBtn.tabEnabled = false;
         this._eCardCreation.tabEnabled = false;
         this._eCardCreation.addGiftBtn.activateGrayState(false);
         this._eCardCreation.leftBtn.activateGrayState(false);
         this._eCardCreation.rightBtn.activateGrayState(false);
         this._eCardCreation.leftBtn.visible = true;
         this._eCardCreation.rightBtn.visible = true;
         this._eCardCreation.textBtn.currTxt.maxChars = 70;
         this._eCardCreation.charCounter.text = "0/70";
         this._eCardCreation.charCounter.visible = false;
         this._dummyMsgTxt = new TextField();
         this._dummyMsgTxt.text = this._eCardCreation.msgTxt.text;
         var _loc8_:TextFormat = this._eCardCreation.msgTxt.getTextFormat();
         this._dummyMsgTxt.setTextFormat(this._eCardCreation.msgTxt.getTextFormat());
         this._dummyMsgTxt.defaultTextFormat = _loc8_;
         this._toUserName = param2;
         this._cards = param3;
         this._stamps = param4;
         this._backBtnCallback = param5;
         this._onCloseCallback = param6;
         if(param7)
         {
            this._eCardCreation.backBtn.visible = false;
            this._guiLayer.addChild(this._eCardCreation);
            DarkenManager.darken(this._eCardCreation);
         }
         this._loadingSpiral = new LoadingSpiral();
         this._currCardId = 0;
         this._currStampId = 0;
         this._messageType = ECard.MESSAGE_TYPE_BUBBLECHAT;
         if(this._toUserName == "")
         {
            this._eCardCreation.toTab.toUserNameTxt.text = "Select a buddy!";
            if(this._eCardCreation.sendBtn.hasGrayState)
            {
               this._eCardCreation.sendBtn.activateGrayState(true);
            }
            this.toBtnHandler(null);
         }
         else
         {
            this._eCardCreation.toTab.toUserNameTxt.text = this._toUserName;
         }
         if(this._stamps)
         {
            this._stampWindow = new WindowGenerator();
            this._stampWindow.init(1,this.NUM_VIS_STAMP_ROWS,this._stamps.length,0,1,0,ItemWindowStamp,this._stamps,"img2",{
               "mouseDown":this.stampBtnDownHandler,
               "mouseOver":this.stampBtnOverHandler,
               "mosueOut":this.stampBtnOutHandler
            });
            this._eCardCreation.stampList.itemBlock.addChild(this._stampWindow);
            this._stampWindow.x = 0;
            this._stampWindow.y = 0;
            if(this._stampWindow)
            {
               this._stampBtn = new (getDefinitionByName("StampBtn") as Class)();
               this._stampListScrollButtons = new SBScrollbar();
               this._stampListScrollButtons.init(this._stampWindow,this._stampWindow.width,this._stampBtn.height * this.NUM_VIS_STAMP_ROWS + 1 * (this.NUM_VIS_STAMP_ROWS - 1) + 0 * 2,1,"scrollbar2",this._stampBtn.height + 1);
            }
         }
         this.drawCurrCard();
         this.drawCurrStamp();
         KeepAlive.startKATimer(this._eCardCreation);
         this.addListeners();
         BuddyManager.eventDispatcher.addEventListener(BuddyEvent.BUDDY_LIST,this.onBuddyListChange,false,0,true);
         BuddyManager.eventDispatcher.addEventListener(BuddyEvent.BUDDY_CHANGED,this.onBuddyListChange,false,0,true);
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         if(gMainFrame.server.isConnected)
         {
            KeepAlive.stopKATimer(this._eCardCreation);
         }
         SafeChatManager.destroy(this._eCardCreation.chatTree);
         if(!this._eCardCreation.backBtn.visible)
         {
            DarkenManager.unDarken(this._eCardCreation);
            this._guiLayer.removeChild(this._eCardCreation);
         }
         if(this._stampWindow)
         {
            this._stampWindow.destroy();
            this._stampWindow = null;
         }
         if(this._stampListScrollButtons)
         {
            this._stampListScrollButtons.destroy();
            this._stampListScrollButtons = null;
         }
         if(this._buddyListScrollButtons)
         {
            this._buddyListScrollButtons.destroy();
            this._buddyListScrollButtons = null;
         }
         GuiManager.displayRulesPopup(false);
         if(this._buddyList)
         {
            this._buddyList = null;
         }
         this._eCardClothes.destroy();
         this._eCardClothes = null;
         if(this._loadingSpiral)
         {
            this._loadingSpiral.destroy();
            this._loadingSpiral = null;
         }
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_LIST,this.onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_CHANGED,this.onBuddyListChange);
      }
      
      public function get visibility() : Boolean
      {
         return this._eCardCreation.visible;
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._onCloseCallback();
      }
      
      private function drawCurrCard() : void
      {
         if(Boolean(this._cards) && Boolean(this._cards[this._currCardId]))
         {
            while(this._eCardCreation.cardSlot.cardLayer.numChildren > 1)
            {
               this._eCardCreation.cardSlot.cardLayer.removeChild(this._eCardCreation.cardSlot.cardLayer.getChildAt(1));
            }
            this._eCardCreation.cardSlot.cardLayer.addChild(this._cards[this._currCardId].img);
         }
         else
         {
            DebugUtility.debugTrace("ECardCreation: No current card to draw");
         }
      }
      
      private function drawCurrStamp() : void
      {
         if(Boolean(this._stamps) && Boolean(this._stamps[this._currStampId]))
         {
            while(this._eCardCreation.stampSlot.stampLayer.numChildren > 1)
            {
               this._eCardCreation.stampSlot.stampLayer.removeChild(this._eCardCreation.stampSlot.stampLayer.getChildAt(1));
            }
            this._eCardCreation.stampSlot.stampLayer.addChild(this._stamps[this._currStampId].img);
         }
         else
         {
            DebugUtility.debugTrace("ECardCreation: No current stamp to draw");
         }
      }
      
      private function mouseOverMsgText(param1:MouseEvent) : void
      {
         CursorManager.showICursor(true);
      }
      
      private function mouseOutMsgText(param1:MouseEvent) : void
      {
         CursorManager.showICursor(false);
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!gMainFrame.userInfo.isMember)
         {
            new SBOkPopup(GuiManager.guiLayer,"Writing your own Jam-A-Grams is currently being tested by members only.");
         }
         else
         {
            if(!(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_RESTR_BUBBLE))
            {
               this._isAllowedToType = true;
               if(SafeChatManager.containsInTreeArray(this._eCardCreation.textBtn.currTxt.text))
               {
                  this._eCardCreation.textBtn.currTxt.text = "";
                  this._eCardCreation.msgTxt.text = "";
                  this._dummyMsgTxt.text = "";
                  this._msg = "";
               }
               this._eCardCreation.textBtn.currTxt.setSelection(this._eCardCreation.textBtn.currTxt.length,this._eCardCreation.textBtn.currTxt.length);
               this._eCardCreation.msgTxt.setSelection(this._eCardCreation.msgTxt.length,this._eCardCreation.msgTxt.length);
               return;
            }
            new SBOkPopup(GuiManager.guiLayer,"Chatting is not turned on. Have your parent use their account settings to change your chat type!");
         }
         gMainFrame.stage.focus = null;
      }
      
      private function onKeyFocusChange(param1:FocusEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
         this._eCardCreation.textBtn.currTxt.setSelection(this._eCardCreation.textBtn.currTxt.length,this._eCardCreation.textBtn.currTxt.length);
      }
      
      private function onFocusIn(param1:FocusEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function keyUpListener(param1:KeyboardEvent) : void
      {
         if(this._isAllowedToType)
         {
            this._predictiveTextManager.onKeyUp(param1);
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(this._isAllowedToType)
         {
            if(this._eCardCreation.chatTree.visible)
            {
               SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
            }
            this._messageType = ECard.MESSAGE_TYPE_LIMITEDCHAT;
            this._predictiveTextManager.onKeyDown(param1);
            if(this._eCardCreation.msgTxt.text.toLowerCase() != this._eCardCreation.textBtn.currTxt.text.toLowerCase() || param1.keyCode == 8)
            {
               setTimeout(this.updateMessageText,1000 / 24);
            }
         }
      }
      
      private function checkShouldCompleteSuggestion(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         setTimeout(this.checkShouldCompleteSuggestionWork,1000 / 24,param1,param2,param3);
      }
      
      private function checkShouldCompleteSuggestionWork(param1:String, param2:Boolean, param3:Function) : void
      {
         if(param2)
         {
            this.updateMessageText();
            if(param3 != null)
            {
               param3(param1,true);
               return;
            }
         }
         var _loc4_:TextField = new TextField();
         var _loc5_:TextFormat = this._eCardCreation.msgTxt.getTextFormat();
         _loc4_.text = this._eCardCreation.msgTxt.text + param1;
         _loc4_.setTextFormat(_loc5_);
         if(_loc4_.length > this._eCardCreation.textBtn.currTxt.maxChars)
         {
            if(param3 != null)
            {
               param3(param1,false);
            }
         }
         else if(param3 != null)
         {
            param3(param1,true);
         }
      }
      
      private function updateMessageText() : void
      {
         this._eCardCreation.msgTxt.text = this._dummyMsgTxt.text = this._eCardCreation.textBtn.currTxt.text.toUpperCase();
         this._eCardCreation.msgTxt.setSelection(this._eCardCreation.msgTxt.length,this._eCardCreation.msgTxt.length);
         var _loc1_:TextFormat = new TextFormat();
         if(this._dummyMsgTxt.textHeight / Number(this._eCardCreation.msgTxt.getTextFormat().size) > 1 || this._dummyMsgTxt.textHeight / Number(50) > 1 || this._eCardCreation.msgTxt.numLines > 1)
         {
            _loc1_.size = 30;
            this._eCardCreation.msgTxt.setTextFormat(_loc1_);
            this._dummyMsgTxt.setTextFormat(_loc1_);
            if(this._eCardCreation.msgTxt.textHeight / Number(this._eCardCreation.msgTxt.getTextFormat().size) < 1)
            {
               this._eCardCreation.msgTxt.y = 148;
            }
            else
            {
               this._eCardCreation.msgTxt.y = 137;
            }
         }
         else
         {
            _loc1_.size = 50;
            this._eCardCreation.msgTxt.setTextFormat(_loc1_);
            this._dummyMsgTxt.setTextFormat(_loc1_);
            this._eCardCreation.msgTxt.y = 137;
         }
         if(!this._eCardCreation.charCounter.visible)
         {
            this._eCardCreation.charCounter.visible = true;
         }
         this._msg = this._eCardCreation.msgTxt.text.toUpperCase();
         this._eCardCreation.charCounter.text = this._msg.length + "/" + this._eCardCreation.textBtn.currTxt.maxChars;
      }
      
      private function sendMailBtnHandler(param1:MouseEvent) : void
      {
         var _loc4_:String = null;
         param1.stopPropagation();
         if(this._eCardCreation.sendBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(this._msg.length == 0 || !this._predictiveTextManager.isWordValid())
         {
            _loc4_ = this._msg.length == 0 ? "Be sure to write something before you send your Jam-A-Gram!" : "You can\'t send a Jam-A-Gram with unapproved text!";
            new SBOkPopup(this._guiLayer,_loc4_);
            return;
         }
         var _loc2_:String = this._eCardCreation.toTab.toUserNameTxt.text;
         this.backBtnHandler(null);
         DarkenManager.showLoadingSpiral(true);
         var _loc3_:Boolean = ECardXtCommManager.sendECardSendRequest(_loc2_,this._cards[this._currCardId].mediaId,this._stamps[this._currStampId].mediaId,this._messageType,this._msg,this._type,this._giftItemIdx,this.onSentResponseCallback);
         if(!_loc3_)
         {
            return;
         }
         if(ffmCallback != null)
         {
            ffmCallback(4);
         }
         AJAudio.playMailSentSound();
      }
      
      private function sendMailBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,"Send",833,446);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function arrowBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._cards)
         {
            if(Boolean(param1) && param1.currentTarget.name == this._eCardCreation.leftBtn.name)
            {
               if(this._currCardId <= 0)
               {
                  this._currCardId = this._cards.length - 1;
               }
               else
               {
                  --this._currCardId;
               }
            }
            else if(this._currCardId >= this._cards.length - 1)
            {
               this._currCardId = 0;
            }
            else
            {
               ++this._currCardId;
            }
            this.drawCurrCard();
         }
      }
      
      private function backBtnHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(this._backBtnCallback != null)
         {
            this._backBtnCallback(param1 == null ? true : false);
         }
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_LIST,this.onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_CHANGED,this.onBuddyListChange);
      }
      
      private function backBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,"Back",67,448);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function backBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function addTextBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(this._eCardCreation.stampList.visible)
         {
            this._eCardCreation.stampList.visible = false;
         }
         if(!this._eCardCreation.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,this._eCardCreation.chatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
         }
         if(ffmCallback != null)
         {
            ffmCallback(3);
         }
      }
      
      private function addTextBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,"Messages",283,492);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onECardTextClose(param1:String, param2:String) : void
      {
         this._predictiveTextManager.resetTreeSearch();
         this._eCardCreation.charCounter.visible = false;
         this._eCardCreation.charCounter.text = "0/" + this._eCardCreation.textBtn.currTxt.maxChars;
         this._eCardCreation.textBtn.currTxt.text = this._eCardCreation.msgTxt.text = param1;
         this._msg = param2;
         this._messageType = ECard.MESSAGE_TYPE_BUBBLECHAT;
         SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
      }
      
      private function addGiftBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!param1.currentTarget.isGray)
         {
            if(!this._eCardClothes)
            {
               this._eCardClothes = new DenAndClothesItemSelect();
               this._eCardClothes.init(gMainFrame.userInfo.playerAvatarInfo.getFullItems(),AvatarManager.playerAvatar.inventoryDenFull.itemArray,this._guiLayer,this.onECardClothesAddBtn,this.onECardClothesClose);
            }
            else
            {
               this._eCardClothes.showHide();
            }
         }
      }
      
      private function addGiftBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,"Add A Gift",658,492);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function addStampBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(this._eCardCreation.chatTree.visible)
         {
            SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
         }
         this._eCardCreation.stampList.visible = !this._eCardCreation.stampList.visible;
         if(ffmCallback != null)
         {
            ffmCallback(3);
         }
      }
      
      private function addStampBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,"Change Stamp",237,492);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function stampBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._currStampId = param1.currentTarget.index;
         this._eCardCreation.stampList.visible = false;
         this.drawCurrStamp();
         AJAudio.playSubMenuBtnClick();
      }
      
      private function stampBtnOverHandler(param1:MouseEvent) : void
      {
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function stampBtnOutHandler(param1:MouseEvent) : void
      {
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function toBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._eCardCreation.buddyList.visible)
         {
            if(this._buddyListScrollButtons)
            {
               this._buddyListScrollButtons.destroy();
               this._buddyListScrollButtons = null;
            }
            if(this._eCardCreation.buddyList.itemBlock.numChildren > 1)
            {
               this._eCardCreation.buddyList.itemBlock.removeChild(this._eCardCreation.buddyList.itemBlock.getChildAt(1));
            }
            _loc2_ = this._buddyList.numChildren;
            if(_loc2_ > 0)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  this._buddyList.getChildAt(_loc3_).removeEventListener(MouseEvent.MOUSE_DOWN,this.clickOnBuddyHandler);
                  _loc3_++;
               }
            }
         }
         else
         {
            if(this._buddyListScrollButtons)
            {
               this._buddyListScrollButtons.destroy();
               this._buddyListScrollButtons = null;
            }
            this.makeNewBuddyList();
         }
         this._eCardCreation.buddyList.visible = !this._eCardCreation.buddyList.visible;
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onBuddyListChange(param1:BuddyEvent) : void
      {
         this.makeNewBuddyList();
      }
      
      private function makeNewBuddyList() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this._eCardCreation)
         {
            if(!BuddyList.listRequested)
            {
               BuddyXtCommManager.sendBuddyListRequest();
               BuddyList.listRequested = true;
               this._loadingSpiral.setNewParent(this._eCardCreation.buddyList.itemBlock,this._eCardCreation.buddyList.itemBlock.width * 0.5,this._eCardCreation.buddyList.itemBlock.height * 0.5);
            }
            else if(this._loadingSpiral)
            {
               if(this._loadingSpiral.parent == this._eCardCreation.buddyList.itemBlock)
               {
                  this._eCardCreation.buddyList.itemBlock.removeChild(this._loadingSpiral);
               }
               this._loadingSpiral.destroy();
               this._loadingSpiral = null;
            }
            if(this._eCardCreation.buddyList.visible)
            {
               if(this._buddyListScrollButtons)
               {
                  this._buddyListScrollButtons.destroy();
                  this._buddyListScrollButtons = null;
               }
               if(this._buddyList.parent)
               {
                  this._buddyList.parent.removeChild(this._buddyList);
               }
               while(this._eCardCreation.buddyList.itemBlock.numChildren > 0)
               {
                  this._eCardCreation.buddyList.itemBlock.removeChildAt(0);
               }
            }
            this._buddyList = new MovieClip();
            BuddyList.buildBuddyListWindow(this._buddyList);
            this._buddyList.x = 0;
            this._buddyList.y = 0;
            this._eCardCreation.buddyList.itemBlock.addChild(this._buddyList);
            _loc1_ = BuddyManager.buddyCount;
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               this._buddyList.getChildAt(_loc2_).addEventListener(MouseEvent.MOUSE_DOWN,this.clickOnBuddyHandler,false,0,true);
               _loc2_++;
            }
            this._buddyListScrollButtons = new SBScrollbar();
            this._buddyListScrollButtons.init(this._buddyList,this._eCardCreation.buddyList.itemBlock.width,new this.OfflineBuddyListWindow().height * 10,5,"scrollbar2",new this.OfflineBuddyListWindow().height);
         }
      }
      
      private function clickOnBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._toUserName = this._eCardCreation.toTab.toUserNameTxt.text = param1.currentTarget.userNameTxt.text;
         if(this._toUserName != "")
         {
            if(this._eCardCreation.sendBtn.hasGrayState)
            {
               this._eCardCreation.sendBtn.activateGrayState(false);
            }
         }
         this.toBtnHandler(null);
         if(ffmCallback != null)
         {
            ffmCallback(2);
         }
      }
      
      private function onECardClothesAddBtn(param1:int, param2:Boolean = true) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         this._giftItemIdx = param1;
         if(this._giftItemIdx > 0)
         {
            _loc3_ = gMainFrame.userInfo.getMyTradeList();
            if(param2)
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  if(_loc3_[_loc4_].type == TradeManager.CLOTHING_TYPE && _loc3_[_loc4_].invIdx == this._giftItemIdx)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(_loc4_);
                     TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                     break;
                  }
                  _loc4_++;
               }
               this._type = ECard.TYPE_CLOTHING;
            }
            else
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  if(_loc3_[_loc4_].type == TradeManager.DEN_TYPE && _loc3_[_loc4_].invIdx == this._giftItemIdx)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(_loc4_);
                     TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                     break;
                  }
                  _loc4_++;
               }
               this._type = ECard.TYPE_DEN_ACC;
            }
            this._eCardCreation.addGiftBtn.activateGrayState(true);
         }
         this._eCardClothes.showHide();
         this._eCardCreation.giftIcon.visible = true;
      }
      
      private function onECardClothesClose() : void
      {
         DebugUtility.debugTrace("clothes window closed");
      }
      
      private function onSentResponseCallback(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(!param1)
         {
            new SBOkPopup(this._guiLayer,"Jam-A-Grams cannot be sent to that user!");
         }
      }
      
      private function removeGiftBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._giftItemIdx = -1;
         this._type = ECard.TYPE_STANDARD;
         if(this._eCardCreation)
         {
            this._eCardCreation.giftIcon.visible = false;
         }
         if(this._eCardClothes)
         {
            this._eCardClothes.removeGift();
         }
         if(this._eCardCreation.addGiftBtn.hasGrayState)
         {
            this._eCardCreation.addGiftBtn.activateGrayState(false);
         }
      }
      
      private function onRulesBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.displayRulesPopup(true);
      }
      
      private function addListeners() : void
      {
         this._eCardCreation.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._eCardCreation.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._eCardCreation.leftBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler,false,0,true);
         this._eCardCreation.rightBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler,false,0,true);
         this._eCardCreation.toTab.addEventListener(MouseEvent.MOUSE_DOWN,this.toBtnHandler,false,0,true);
         this._eCardCreation.addStampBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.addStampBtnHandler,false,0,true);
         this._eCardCreation.addStampBtn.addEventListener(MouseEvent.MOUSE_OVER,this.addStampBtnOverHandler,false,0,true);
         this._eCardCreation.addStampBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._eCardCreation.addTextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.addTextBtnHandler,false,0,true);
         this._eCardCreation.addTextBtn.addEventListener(MouseEvent.MOUSE_OVER,this.addTextBtnOverHandler,false,0,true);
         this._eCardCreation.addTextBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         if(Utility.canGift())
         {
            this._eCardCreation.addGiftBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.addGiftBtnHandler,false,0,true);
            this._eCardCreation.addGiftBtn.addEventListener(MouseEvent.MOUSE_OVER,this.addGiftBtnOverHandler,false,0,true);
            this._eCardCreation.addGiftBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         }
         else
         {
            this._eCardCreation.addGiftBtn.activateGrayState(true);
         }
         this._eCardCreation.giftIcon.removeGiftBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.removeGiftBtnHandler,false,0,true);
         this._eCardCreation.sendBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sendMailBtnHandler,false,0,true);
         this._eCardCreation.sendBtn.addEventListener(MouseEvent.MOUSE_OVER,this.sendMailBtnOverHandler,false,0,true);
         this._eCardCreation.sendBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._eCardCreation.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.backBtnHandler,false,0,true);
         this._eCardCreation.backBtn.addEventListener(MouseEvent.MOUSE_OVER,this.backBtnOverHandler,false,0,true);
         this._eCardCreation.backBtn.addEventListener(MouseEvent.MOUSE_OUT,this.backBtnOutHandler,false,0,true);
         this._eCardCreation.textBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
         if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE)
         {
            this._eCardCreation.textBtn.currTxt.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange,false,0,true);
            this._eCardCreation.textBtn.currTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
            this._eCardCreation.textBtn.currTxt.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
         }
         this._eCardCreation.rulesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRulesBtn,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            this._eCardCreation.textBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText,false,0,true);
            this._eCardCreation.textBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         var _loc1_:int = 0;
         this._eCardCreation.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._eCardCreation.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._eCardCreation.leftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler);
         this._eCardCreation.rightBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler);
         this._eCardCreation.toTab.removeEventListener(MouseEvent.MOUSE_DOWN,this.toBtnHandler);
         this._eCardCreation.addStampBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.addStampBtnHandler);
         this._eCardCreation.addStampBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.addStampBtnOverHandler);
         this._eCardCreation.addStampBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._eCardCreation.addTextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.addTextBtnHandler);
         this._eCardCreation.addTextBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.addTextBtnOverHandler);
         this._eCardCreation.addTextBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         if(Utility.canGift())
         {
            this._eCardCreation.addGiftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.addGiftBtnHandler);
            this._eCardCreation.addGiftBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.addGiftBtnOverHandler);
            this._eCardCreation.addGiftBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         }
         this._eCardCreation.giftIcon.removeGiftBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.removeGiftBtnHandler);
         this._eCardCreation.sendBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.sendMailBtnHandler);
         this._eCardCreation.sendBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.sendMailBtnOverHandler);
         this._eCardCreation.sendBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._eCardCreation.backBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.backBtnHandler);
         this._eCardCreation.backBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.backBtnOverHandler);
         this._eCardCreation.backBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.backBtnOutHandler);
         this._eCardCreation.textBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
         if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE)
         {
            this._eCardCreation.textBtn.currTxt.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange);
            this._eCardCreation.textBtn.currTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this._eCardCreation.textBtn.currTxt.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
         }
         this._eCardCreation.rulesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRulesBtn);
         if(this._buddyList)
         {
            _loc1_ = 0;
            while(_loc1_ < this._buddyList.numChildren)
            {
               this._buddyList.getChildAt(_loc1_).removeEventListener(MouseEvent.MOUSE_DOWN,this.clickOnBuddyHandler);
               _loc1_++;
            }
         }
      }
   }
}

