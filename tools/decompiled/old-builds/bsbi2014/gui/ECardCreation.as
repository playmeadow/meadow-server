package gui
{
   import avatar.AvatarManager;
   import buddy.BuddyEvent;
   import buddy.BuddyXtCommManager;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.*;
   import ecard.ECard;
   import ecard.ECardImageBase;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   import flash.utils.setTimeout;
   import localization.LocalizationManager;
   
   public class ECardCreation
   {
      
      private const NUM_VIS_STAMP_ROWS:int = 3;
      
      private var _eCardCreation:MovieClip;
      
      private var _eCardClothes:DenAndClothesItemSelect;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _onCloseCallback:Function;
      
      private var _backBtnCallback:Function;
      
      private var _toUserName:String;
      
      private var _toModeratedUserName:String;
      
      private var _toAccountType:int;
      
      private var _currCardId:int;
      
      private var _currStampId:int;
      
      private var _messageType:int;
      
      private var _msg:String;
      
      private var _type:int;
      
      private var _giftItemIdx:int = -1;
      
      private var _isAllowedToType:Boolean;
      
      private var _keyboardEvent:KeyboardEvent;
      
      private var _createOnly:Boolean;
      
      private var _cardMediaIds:Array;
      
      private var _stampMediaIds:Array;
      
      private var _currentECardImageBase:ECardImageBase;
      
      private var _currentStampImageBase:ECardImageBase;
      
      private var _buddyList:MovieClip;
      
      private var _buddyListScrollButtons:SBScrollbar;
      
      private var _dummyMsgTxt:TextField;
      
      private var _stampWindow:WindowGenerator;
      
      private var _stampListScrollButtons:SBScrollbar;
      
      private var _stampBtn:MovieClip;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _eCardLoadingSpiral:LoadingSpiral;
      
      private var _guiLayer:DisplayLayer;
      
      public function ECardCreation()
      {
         super();
      }
      
      public function init(initGuiLayer:DisplayLayer, initToUserName:String, initToModeratedUserName:String, initToAccountType:int, initCards:Array, initStamps:Array, initBackBtnCallback:Function, initCloseCallback:Function, initCreateOnly:Boolean = false) : void
      {
         var numBuddies:int = 0;
         this._guiLayer = initGuiLayer;
         this._eCardCreation = ECardManager.eCardInboxAndCreation;
         this._eCardCreation.visible = true;
         if(initCreateOnly)
         {
            this._guiLayer.addChild(this._eCardCreation);
            DarkenManager.darken(this._eCardCreation);
         }
         if(this._eCardCreation.currentFrameLabel != "create")
         {
            this._eCardCreation.gotoAndStop("create");
         }
         DarkenManager.showLoadingSpiral(false);
         SafeChatManager.buildSafeChatTree(this._eCardCreation.chatTree,"ECardTextTreeNode",SafeChatManager.TREE_ECARDTEXT,this.onECardTextClose,null);
         SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
         this._predictiveTextManager = new PredictiveTextManager();
         this._predictiveTextManager.init(this._eCardCreation.textBtn.currTxt,PredictiveTextTree.defaultRoot,PredictiveTextManager.USE_TYPE_ECARD,this._eCardCreation.predictTxtTag,null,null,this.checkShouldCompleteSuggestion);
         if(PredictiveTextTree.defaultRoot == null)
         {
            PredictiveTextManager.requestAndCreateTextTreeNode();
         }
         this._eCardCreation.textBtn.currTxt.text = this._eCardCreation.msgTxt.text = SafeChatManager.ctNodes[0][0];
         this._eCardCreation.msgTxt.restrict = ChatHistory.TEXT_RESTRICTION;
         this._msg = "0,0";
         this._eCardCreation.buddyList.visible = false;
         this._eCardCreation.giftIcon.visible = false;
         this._eCardCreation.stampList.visible = false;
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
         var obj:TextFormat = this._eCardCreation.msgTxt.getTextFormat();
         this._dummyMsgTxt.setTextFormat(this._eCardCreation.msgTxt.getTextFormat());
         this._dummyMsgTxt.defaultTextFormat = obj;
         this._toUserName = initToUserName;
         this._toModeratedUserName = initToModeratedUserName;
         this._toAccountType = initToAccountType;
         this._cardMediaIds = initCards;
         this._stampMediaIds = initStamps;
         this._backBtnCallback = initBackBtnCallback;
         this._onCloseCallback = initCloseCallback;
         this._createOnly = initCreateOnly;
         this._loadingSpiral = new LoadingSpiral();
         this._eCardLoadingSpiral = new LoadingSpiral();
         this._currCardId = 0;
         this._currStampId = 0;
         this._messageType = ECard.MESSAGE_TYPE_BUBBLECHAT;
         if(!BuddyList.listRequested)
         {
            BuddyXtCommManager.sendBuddyListRequest();
            BuddyList.listRequested = true;
            this._loadingSpiral.setNewParent(this._eCardCreation.buddyList.itemBlock,this._eCardCreation.buddyList.itemBlock.width * 0.5,this._eCardCreation.buddyList.itemBlock.height * 0.5);
            this.putInGrayedOutState(true);
            this._eCardCreation.cardSlot.noMailPopup.visible = false;
         }
         else
         {
            numBuddies = BuddyManager.buddyCount;
            if(this._toUserName == "")
            {
               LocalizationManager.translateId(this._eCardCreation.toTab.toUserNameTxt,11276);
               if(Boolean(this._eCardCreation.sendBtn.hasGrayState))
               {
                  this._eCardCreation.sendBtn.activateGrayState(true);
               }
               if(numBuddies != 0)
               {
                  this.toBtnHandler(null);
               }
               else
               {
                  this.putInGrayedOutState(true);
               }
               this._eCardCreation.buddyList.visible = !this._eCardCreation.buddyList.visible == true && (Boolean(this._buddyList) && Boolean(this._buddyList.numChildren > 0)) ? true : false;
            }
            else
            {
               this.toBtnHandler(null);
               this._eCardCreation.toTab.toUserNameTxt.text = this._toModeratedUserName;
            }
         }
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
         if(Boolean(this._stampWindow))
         {
            this._stampWindow.destroy();
            this._stampWindow = null;
         }
         if(Boolean(this._stampListScrollButtons))
         {
            this._stampListScrollButtons.destroy();
            this._stampListScrollButtons = null;
         }
         if(Boolean(this._buddyListScrollButtons))
         {
            this._buddyListScrollButtons.destroy();
            this._buddyListScrollButtons = null;
         }
         GuiManager.displayRulesPopup(false);
         if(Boolean(this._buddyList))
         {
            this._buddyList = null;
         }
         if(Boolean(this._eCardClothes))
         {
            this._eCardClothes.destroy();
            this._eCardClothes = null;
         }
         if(Boolean(this._loadingSpiral))
         {
            this._loadingSpiral.destroy();
            this._loadingSpiral = null;
         }
         if(Boolean(this._predictiveTextManager))
         {
            this._predictiveTextManager.destroy();
            this._predictiveTextManager = null;
         }
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_LIST,this.onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_CHANGED,this.onBuddyListChange);
      }
      
      public function get visibility() : Boolean
      {
         return this._eCardCreation.visible;
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         this._onCloseCallback();
      }
      
      private function createAndLoadStampsAndEcards() : void
      {
         this._eCardCreation.cardSlot.noMailPopup.visible = false;
         if(Boolean(this._stampMediaIds) && this._stampWindow == null)
         {
            this._stampWindow = new WindowGenerator();
            this._stampWindow.init(1,this.NUM_VIS_STAMP_ROWS,this._stampMediaIds.length,0,1,0,ItemWindowStamp,this._stampMediaIds,"img2",{
               "mouseDown":this.stampBtnDownHandler,
               "mouseOver":this.stampBtnOverHandler,
               "mosueOut":this.stampBtnOutHandler
            });
            this._eCardCreation.stampList.itemBlock.addChild(this._stampWindow);
            this._stampWindow.x = 0;
            this._stampWindow.y = 0;
            if(Boolean(this._stampWindow))
            {
               this._stampBtn = GETDEFINITIONBYNAME("StampBtn");
               this._stampListScrollButtons = new SBScrollbar();
               this._stampListScrollButtons.init(this._stampWindow,this._stampWindow.width,this._stampBtn.height * this.NUM_VIS_STAMP_ROWS + 1 * (this.NUM_VIS_STAMP_ROWS - 1) + 0 * 2,1,"scrollbar2",this._stampBtn.height + 1);
            }
         }
         if(this._createOnly)
         {
            this._eCardCreation.backBtn.visible = false;
         }
         this.drawCurrCard();
         this.drawCurrStamp();
      }
      
      private function putInGrayedOutState(gray:Boolean) : void
      {
         with(this._eCardCreation)
         {
            leftBtn.activateGrayState(gray);
            rightBtn.activateGrayState(gray);
            addStampBtn.activateGrayState(gray);
            addTextBtn.activateGrayState(gray);
            textBtn.activateGrayState(gray);
            if(!gray)
            {
               if(_toUserName != "")
               {
                  sendBtn.activateGrayState(gray);
               }
               if(Utility.canGift() && _giftItemIdx == -1)
               {
                  addGiftBtn.activateGrayState(gray);
               }
               if(_stampWindow == null)
               {
                  createAndLoadStampsAndEcards();
               }
            }
            else
            {
               sendBtn.activateGrayState(gray);
               addGiftBtn.activateGrayState(gray);
               if(Boolean(_stampWindow))
               {
                  _stampWindow.destroy();
                  _stampWindow = null;
                  if(Boolean(_stampListScrollButtons))
                  {
                     _stampListScrollButtons.destroy();
                     _stampListScrollButtons = null;
                  }
                  while(_eCardCreation.cardSlot.cardLayer.numChildren > 1)
                  {
                     _eCardCreation.cardSlot.cardLayer.removeChild(_eCardCreation.cardSlot.cardLayer.getChildAt(1));
                  }
                  while(_eCardCreation.stampSlot.stampLayer.numChildren > 1)
                  {
                     _eCardCreation.stampSlot.stampLayer.removeChild(_eCardCreation.stampSlot.stampLayer.getChildAt(1));
                  }
               }
            }
            toTab.visible = !gray;
            msgTxt.visible = !gray;
            textBtn.currTxt.selectable = !gray;
            cardSlot.noMailPopup.visible = gray;
         }
      }
      
      private function drawCurrCard() : void
      {
         if(Boolean(this._cardMediaIds) && Boolean(this._cardMediaIds[this._currCardId]))
         {
            while(this._eCardCreation.cardSlot.cardLayer.numChildren > 1)
            {
               this._eCardCreation.cardSlot.cardLayer.removeChild(this._eCardCreation.cardSlot.cardLayer.getChildAt(1));
            }
            this._eCardLoadingSpiral.setNewParent(this._eCardCreation.cardSlot.cardLayer,this._eCardCreation.cardSlot.cardLayer.width * 0.5,this._eCardCreation.cardSlot.cardLayer.height * 0.5);
            this._eCardLoadingSpiral.visible = true;
            this._currentECardImageBase = new ECardImageBase();
            this._currentECardImageBase.init(this._cardMediaIds[this._currCardId],this.onECardImageLoaded);
         }
         else
         {
            DebugUtility.debugTrace("ECardCreation: No current card to draw");
         }
      }
      
      private function onECardImageLoaded() : void
      {
         while(this._eCardCreation.cardSlot.cardLayer.numChildren > 1)
         {
            this._eCardCreation.cardSlot.cardLayer.removeChild(this._eCardCreation.cardSlot.cardLayer.getChildAt(1));
         }
         this._eCardLoadingSpiral.visible = false;
         this._eCardCreation.cardSlot.cardLayer.addChild(this._currentECardImageBase.img);
      }
      
      private function drawCurrStamp() : void
      {
         if(Boolean(this._stampMediaIds) && Boolean(this._stampMediaIds[this._currStampId]))
         {
            while(this._eCardCreation.stampSlot.stampLayer.numChildren > 1)
            {
               this._eCardCreation.stampSlot.stampLayer.removeChild(this._eCardCreation.stampSlot.stampLayer.getChildAt(1));
            }
            this._currentStampImageBase = new ECardImageBase();
            this._currentStampImageBase.init(this._stampMediaIds[this._currStampId],this.onStampImageLoaded);
         }
         else
         {
            DebugUtility.debugTrace("ECardCreation: No current stamp to draw");
         }
      }
      
      private function onStampImageLoaded() : void
      {
         while(this._eCardCreation.stampSlot.stampLayer.numChildren > 1)
         {
            this._eCardCreation.stampSlot.stampLayer.removeChild(this._eCardCreation.stampSlot.stampLayer.getChildAt(1));
         }
         this._eCardCreation.stampSlot.stampLayer.addChild(this._currentStampImageBase.img);
      }
      
      private function mouseOverMsgText(m:MouseEvent) : void
      {
         if(!m.currentTarget.isGray)
         {
            CursorManager.showICursor(true);
         }
      }
      
      private function mouseOutMsgText(m:MouseEvent) : void
      {
         if(!m.currentTarget.isGray)
         {
            CursorManager.showICursor(false);
         }
      }
      
      private function msgTextDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               this.addTextBtnHandler(evt);
            }
            else
            {
               if(!(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_RESTR_BUBBLE))
               {
                  this._isAllowedToType = true;
                  if(SafeChatManager.containsInTreeArray(this._eCardCreation.textBtn.currTxt.text,SafeChatManager.TREE_ECARDTEXT))
                  {
                     this._eCardCreation.textBtn.currTxt.text = "";
                     this._eCardCreation.msgTxt.text = "";
                     this._dummyMsgTxt.text = "";
                     this._msg = "";
                     this._eCardCreation.charCounter.visible = true;
                  }
                  this._eCardCreation.textBtn.currTxt.setSelection(this._eCardCreation.textBtn.currTxt.length,this._eCardCreation.textBtn.currTxt.length);
                  this._eCardCreation.msgTxt.setSelection(this._eCardCreation.msgTxt.length,this._eCardCreation.msgTxt.length);
                  return;
               }
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18406));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14713));
               }
            }
            gMainFrame.stage.focus = null;
         }
      }
      
      private function onKeyFocusChange(evt:FocusEvent) : void
      {
         evt.stopPropagation();
         evt.preventDefault();
         this._eCardCreation.textBtn.currTxt.setSelection(this._eCardCreation.textBtn.currTxt.length,this._eCardCreation.textBtn.currTxt.length);
      }
      
      private function onFocusIn(evt:FocusEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onTextInput(e:TextEvent) : void
      {
         e.preventDefault();
         this.keyDownListener(this._keyboardEvent,e.text);
      }
      
      private function onTextChanged(evt:Event) : void
      {
         if(this._isAllowedToType)
         {
            this._predictiveTextManager.onTextFieldChanged(evt);
         }
      }
      
      private function keyUpListener(evt:KeyboardEvent) : void
      {
         if(this._isAllowedToType)
         {
            this._predictiveTextManager.onKeyUp(evt);
         }
      }
      
      private function keyDownListener(evt:KeyboardEvent, textFieldInput:String = null) : void
      {
         if(this._isAllowedToType)
         {
            if(textFieldInput == null && evt.keyCode != Keyboard.ENTER && evt.keyCode != Keyboard.BACKSPACE && evt.keyCode != Keyboard.TAB && evt.keyCode != Keyboard.SHIFT)
            {
               this._keyboardEvent = evt;
               return;
            }
            if(this._keyboardEvent == null && evt == null)
            {
               return;
            }
            if(Boolean(this._eCardCreation.chatTree.visible))
            {
               SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
            }
            this._messageType = ECard.MESSAGE_TYPE_LIMITEDCHAT;
            this._predictiveTextManager.onKeyDown(evt,textFieldInput);
            this._keyboardEvent = null;
            if(this._eCardCreation.msgTxt.text.toLowerCase() != this._eCardCreation.textBtn.currTxt.text.toLowerCase() || evt.keyCode == 8)
            {
               setTimeout(this.updateMessageText,1000 / 24);
            }
         }
      }
      
      private function checkShouldCompleteSuggestion(txt:String, shouldUpdateText:Boolean = false, onCompleteCallback:Function = null) : void
      {
         setTimeout(this.checkShouldCompleteSuggestionWork,1000 / 24,txt,shouldUpdateText,onCompleteCallback);
      }
      
      private function checkShouldCompleteSuggestionWork(txt:String, shouldUpdateText:Boolean, onCompleteCallback:Function) : void
      {
         if(shouldUpdateText)
         {
            this.updateMessageText();
            if(onCompleteCallback != null)
            {
               onCompleteCallback(txt,true);
               return;
            }
         }
         var testText:TextField = new TextField();
         var myFormat:TextFormat = this._eCardCreation.msgTxt.getTextFormat();
         testText.text = this._eCardCreation.msgTxt.text + txt;
         testText.setTextFormat(myFormat);
         if(testText.length > this._eCardCreation.textBtn.currTxt.maxChars)
         {
            if(onCompleteCallback != null)
            {
               onCompleteCallback(txt,false);
            }
         }
         else if(onCompleteCallback != null)
         {
            onCompleteCallback(txt,true);
         }
      }
      
      private function updateMessageText() : void
      {
         this._eCardCreation.msgTxt.text = this._dummyMsgTxt.text = this._eCardCreation.textBtn.currTxt.text.toUpperCase();
         this._eCardCreation.msgTxt.setSelection(this._eCardCreation.msgTxt.length,this._eCardCreation.msgTxt.length);
         var myNewFormat:TextFormat = this._eCardCreation.msgTxt.getTextFormat();
         if(this._dummyMsgTxt.textHeight / Number(this._eCardCreation.msgTxt.getTextFormat().size) > 1 || this._dummyMsgTxt.textHeight / Number(50) > 1 || this._eCardCreation.msgTxt.numLines > 1)
         {
            myNewFormat.size = 30;
            this._eCardCreation.msgTxt.setTextFormat(myNewFormat);
            this._dummyMsgTxt.setTextFormat(myNewFormat);
            if(this._eCardCreation.msgTxt.textHeight / Number(this._eCardCreation.msgTxt.getTextFormat().size) < 1)
            {
               this._eCardCreation.msgTxt.y = 148;
            }
            else
            {
               this._eCardCreation.msgTxt.y = 135;
            }
         }
         else
         {
            myNewFormat.size = 50;
            this._eCardCreation.msgTxt.setTextFormat(myNewFormat);
            this._dummyMsgTxt.setTextFormat(myNewFormat);
            this._eCardCreation.msgTxt.y = 137;
         }
         if(!this._eCardCreation.charCounter.visible)
         {
            this._eCardCreation.charCounter.visible = true;
         }
         this._msg = this._eCardCreation.msgTxt.text.toUpperCase();
         this._eCardCreation.charCounter.text = this._msg.length + "/" + this._eCardCreation.textBtn.currTxt.maxChars;
      }
      
      private function sendMailBtnHandler(evt:MouseEvent) : void
      {
         var message:String = null;
         evt.stopPropagation();
         if(Boolean(this._eCardCreation.sendBtn.isGray))
         {
            return;
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(this._msg.length == 0 || !this._predictiveTextManager.isWordValid())
         {
            message = this._msg.length == 0 ? LocalizationManager.translateIdOnly(11277) : LocalizationManager.translateIdOnly(11278);
            new SBOkPopup(this._guiLayer,message);
            return;
         }
         this.backBtnHandler(null);
         DarkenManager.showLoadingSpiral(true);
         var success:Boolean = ECardXtCommManager.sendECardSendRequest(this._toUserName,this._currentECardImageBase.mediaId,this._currentStampImageBase.mediaId,this._messageType,this._msg,this._type,this._giftItemIdx,this.onSentResponseCallback);
         if(!success)
         {
            return;
         }
         AJAudio.playMailSentSound();
      }
      
      private function sendMailBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14648),833,446);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function arrowBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray && !this._eCardLoadingSpiral.visible)
         {
            if(Boolean(this._cardMediaIds))
            {
               if(Boolean(evt) && evt.currentTarget.name == this._eCardCreation.leftBtn.name)
               {
                  if(this._currCardId <= 0)
                  {
                     this._currCardId = this._cardMediaIds.length - 1;
                  }
                  else
                  {
                     --this._currCardId;
                  }
               }
               else if(this._currCardId >= this._cardMediaIds.length - 1)
               {
                  this._currCardId = 0;
               }
               else
               {
                  ++this._currCardId;
               }
            }
            this.drawCurrCard();
         }
      }
      
      private function backBtnHandler(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(this._backBtnCallback != null)
         {
            this._backBtnCallback(evt == null ? true : false);
         }
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_LIST,this.onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_CHANGED,this.onBuddyListChange);
      }
      
      private function backBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11207),67,448);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function backBtnOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function addTextBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!evt.currentTarget.isGray)
         {
            if(Boolean(this._eCardCreation.stampList.visible))
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
         }
      }
      
      private function addTextBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14649),283,492);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function onECardTextClose(msg:String, code:String) : void
      {
         this._predictiveTextManager.resetTreeSearch();
         this._eCardCreation.charCounter.visible = false;
         this._eCardCreation.charCounter.text = "0/" + this._eCardCreation.textBtn.currTxt.maxChars;
         this._eCardCreation.textBtn.currTxt.text = this._eCardCreation.msgTxt.text = msg;
         this.updateMessageText();
         this._msg = code;
         this._messageType = ECard.MESSAGE_TYPE_BUBBLECHAT;
         SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
      }
      
      private function addGiftBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!evt.currentTarget.isGray)
         {
            if(gMainFrame.userInfo.isMember)
            {
               if(Utility.isMember(this._toAccountType))
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
               else
               {
                  new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(18193));
               }
            }
            else
            {
               UpsellManager.displayPopup(UpsellManager.JAG,"Sending_Gift");
            }
         }
      }
      
      private function addGiftBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14650),658,492);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function addStampBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(!evt.currentTarget.isGray)
         {
            if(Boolean(this._eCardCreation.chatTree.visible))
            {
               SafeChatManager.closeSafeChat(this._eCardCreation.chatTree);
            }
            this._eCardCreation.stampList.visible = !this._eCardCreation.stampList.visible;
         }
      }
      
      private function addStampBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14651),237,492);
            GuiManager.toolTip.startTimer(evt);
         }
      }
      
      private function stampBtnDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._currStampId = evt.currentTarget.index;
         this._eCardCreation.stampList.visible = false;
         this.drawCurrStamp();
         AJAudio.playSubMenuBtnClick();
      }
      
      private function stampBtnOverHandler(evt:MouseEvent) : void
      {
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function stampBtnOutHandler(evt:MouseEvent) : void
      {
      }
      
      private function btnOutHandler(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function toBtnHandler(evt:MouseEvent) : void
      {
         var numBuddies:int = 0;
         var i:int = 0;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(this._eCardCreation.buddyList.visible))
         {
            if(Boolean(this._buddyListScrollButtons))
            {
               this._buddyListScrollButtons.destroy();
               this._buddyListScrollButtons = null;
            }
            if(this._eCardCreation.buddyList.itemBlock.numChildren > 1)
            {
               this._eCardCreation.buddyList.itemBlock.removeChild(this._eCardCreation.buddyList.itemBlock.getChildAt(1));
            }
            numBuddies = this._buddyList.numChildren;
            if(numBuddies > 0)
            {
               for(i = 0; i < numBuddies; i++)
               {
                  this._buddyList.getChildAt(i).removeEventListener(MouseEvent.MOUSE_DOWN,this.clickOnBuddyHandler);
               }
            }
         }
         else
         {
            if(Boolean(this._buddyListScrollButtons))
            {
               this._buddyListScrollButtons.destroy();
               this._buddyListScrollButtons = null;
            }
            this.makeNewBuddyList();
         }
         this._eCardCreation.buddyList.visible = !this._eCardCreation.buddyList.visible == true && (Boolean(this._buddyList) && Boolean(this._buddyList.numChildren > 0)) ? true : false;
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onBuddyListChange(evt:BuddyEvent) : void
      {
         this.makeNewBuddyList();
      }
      
      private function makeNewBuddyList() : void
      {
         var numBuddies:int = 0;
         var i:int = 0;
         if(Boolean(this._eCardCreation))
         {
            if(!BuddyList.listRequested)
            {
               BuddyXtCommManager.sendBuddyListRequest();
               BuddyList.listRequested = true;
               this._loadingSpiral.setNewParent(this._eCardCreation.buddyList.itemBlock,this._eCardCreation.buddyList.itemBlock.width * 0.5,this._eCardCreation.buddyList.itemBlock.height * 0.5);
               return;
            }
            if(Boolean(this._buddyListScrollButtons))
            {
               this._buddyListScrollButtons.destroy();
               this._buddyListScrollButtons = null;
            }
            if(Boolean(this._eCardCreation.buddyList.visible))
            {
               if(Boolean(this._buddyList.parent))
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
            numBuddies = BuddyManager.buddyCount;
            this.putInGrayedOutState(numBuddies == 0 && !this._createOnly);
            if(numBuddies == 0)
            {
               this._eCardCreation.toTab.removeEventListener(MouseEvent.MOUSE_DOWN,this.toBtnHandler);
               this._eCardCreation.toTab.mouseChildren = false;
               this._eCardCreation.toTab.mouseEnabled = false;
            }
            for(i = 0; i < numBuddies; i++)
            {
               this._buddyList.getChildAt(i).addEventListener(MouseEvent.MOUSE_DOWN,this.clickOnBuddyHandler,false,0,true);
            }
            this._buddyListScrollButtons = new SBScrollbar();
            this._buddyListScrollButtons.init(this._buddyList,this._eCardCreation.buddyList.itemBlock.width,GETDEFINITIONBYNAME("OfflineBuddyListWindow").height * 10,5,"scrollbar2",GETDEFINITIONBYNAME("OfflineBuddyListWindow").height);
            if(this._toUserName == "")
            {
               LocalizationManager.translateId(this._eCardCreation.toTab.toUserNameTxt,11276);
               if(Boolean(this._eCardCreation.sendBtn.hasGrayState))
               {
                  this._eCardCreation.sendBtn.activateGrayState(true);
               }
            }
            else
            {
               this._eCardCreation.toTab.toUserNameTxt.text = this._toModeratedUserName;
            }
            if(Boolean(this._loadingSpiral))
            {
               if(this._loadingSpiral.parent == this._eCardCreation.buddyList.itemBlock)
               {
                  this._eCardCreation.buddyList.itemBlock.removeChild(this._loadingSpiral);
               }
               this._loadingSpiral.destroy();
               this._loadingSpiral = null;
               this._eCardCreation.buddyList.visible = !this._eCardCreation.buddyList.visible == true && (Boolean(this._buddyList) && Boolean(this._buddyList.numChildren > 0)) ? true : false;
            }
         }
      }
      
      private function clickOnBuddyHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._toModeratedUserName = this._eCardCreation.toTab.toUserNameTxt.text = evt.currentTarget.moderatedUserName;
         this._toUserName = evt.currentTarget.userName;
         this._toAccountType = evt.currentTarget.accountType;
         if(this._toUserName != "")
         {
            if(Boolean(this._eCardCreation.sendBtn.hasGrayState))
            {
               this._eCardCreation.sendBtn.activateGrayState(false);
            }
         }
         if(!Utility.isMember(this._toAccountType))
         {
            this.removeGiftBtnHandler(null);
         }
         this.toBtnHandler(null);
      }
      
      private function onECardClothesAddBtn(giftItemIdx:int, isClothesItem:Boolean = true) : void
      {
         var tradeList:Array = null;
         var i:int = 0;
         this._giftItemIdx = giftItemIdx;
         if(this._giftItemIdx > 0)
         {
            tradeList = gMainFrame.userInfo.getMyTradeList();
            if(isClothesItem)
            {
               for(i = 0; i < tradeList.length; i++)
               {
                  if(tradeList[i].type == TradeManager.CLOTHING_TYPE && tradeList[i].invIdx == this._giftItemIdx)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(i);
                     TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                     break;
                  }
               }
               this._type = ECard.TYPE_CLOTHING;
            }
            else
            {
               for(i = 0; i < tradeList.length; i++)
               {
                  if(tradeList[i].type == TradeManager.DEN_TYPE && tradeList[i].invIdx == this._giftItemIdx)
                  {
                     gMainFrame.userInfo.removeFromMyTradeList(i);
                     TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                     break;
                  }
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
      
      private function onSentResponseCallback(status:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(!status)
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14717));
         }
      }
      
      private function removeGiftBtnHandler(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         this._giftItemIdx = -1;
         this._type = ECard.TYPE_STANDARD;
         if(Boolean(this._eCardCreation))
         {
            this._eCardCreation.giftIcon.visible = false;
         }
         if(Boolean(this._eCardClothes))
         {
            this._eCardClothes.removeGift();
         }
         if(Boolean(this._eCardCreation.addGiftBtn.hasGrayState))
         {
            this._eCardCreation.addGiftBtn.activateGrayState(false);
         }
      }
      
      private function onRulesBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
            this._eCardCreation.textBtn.currTxt.addEventListener(Event.CHANGE,this.onTextChanged,false,0,true);
            this._eCardCreation.textBtn.currTxt.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange,false,0,true);
            this._eCardCreation.textBtn.currTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
            this._eCardCreation.textBtn.currTxt.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
            this._eCardCreation.textBtn.currTxt.addEventListener(TextEvent.TEXT_INPUT,this.onTextInput,false,0,true);
         }
         this._eCardCreation.rulesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRulesBtn,false,0,true);
         if(Boolean(Mouse["supportsNativeCursor"]))
         {
            this._eCardCreation.textBtn.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText,false,0,true);
            this._eCardCreation.textBtn.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         var i:int = 0;
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
            this._eCardCreation.textBtn.currTxt.removeEventListener(Event.CHANGE,this.onTextChanged);
            this._eCardCreation.textBtn.currTxt.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange);
            this._eCardCreation.textBtn.currTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this._eCardCreation.textBtn.currTxt.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this._eCardCreation.textBtn.currTxt.removeEventListener(TextEvent.TEXT_INPUT,this.onTextInput);
         }
         this._eCardCreation.rulesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRulesBtn);
         if(Boolean(this._buddyList))
         {
            for(i = 0; i < this._buddyList.numChildren; i++)
            {
               this._buddyList.getChildAt(i).removeEventListener(MouseEvent.MOUSE_DOWN,this.clickOnBuddyHandler);
            }
         }
      }
   }
}

