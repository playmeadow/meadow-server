package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import localization.LocalizationManager;
   import room.RoomXtCommManager;
   
   public class ChatHistory
   {
      
      public static const SG_CHAT_TYPE_BUBBLE:int = 0;
      
      public static const SG_CHAT_TYPE_FREE:int = 1;
      
      public static const SG_CHAT_TYPE_PREDICTIVE:int = 2;
      
      public static const SG_CHAT_TYPE_RESTR_BUBBLE:int = 3;
      
      public static const TEXT_RESTRICTION:String = "A-Za-z0-9!\'.,():? ";
      
      public static const TEXT_RESTRICTION_WO_PAREN:String = "A-Za-z0-9!\'.,:? ";
      
      public static const TEXT_RESTRICTION_WO_OPEN_PAREN:String = "A-Za-z0-9!\'.,):? ";
      
      public static const TEXT_RESTRICTION_INTERROBANG:String = "?!.";
      
      private const CHAT_DIM_ALPHA:Number = 0.5;
      
      private const CHAT_BRIGHT_ALPHA:Number = 1;
      
      private var _keyListenersActive:Boolean;
      
      private var _enableFreeChat:Boolean = true;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _keyboardEvent:KeyboardEvent;
      
      private var _predictiveText:MovieClip;
      
      private var _chatText:TextField;
      
      private var _chatBarContainer:MovieClip;
      
      private var _chatRepeatBtn:MovieClip;
      
      private var _chatRepeatWindow:MovieClip;
      
      private var _repeatChatWindows:WindowGenerator;
      
      private var _chatRepeatArray:Array;
      
      private var _hasSetupChatRepeatBtn:Boolean;
      
      private var _previousRestriction:String;
      
      private var _numInterrobangs:int;
      
      private var _textColorTimer:Timer;
      
      private var _defaultTextColor:uint;
      
      public var chatHistory:MovieClip;
      
      public var chatUpDown:MovieClip;
      
      public var chatMsgText:TextField;
      
      public var chatSendBtn:MovieClip;
      
      public var sendMsgCallback:Function;
      
      public function ChatHistory(chatHistoryMC:MovieClip, chatBarContainer:MovieClip, upAndDownMovieClip:MovieClip, buddyListButton:MovieClip, chatMessageText:TextField, chatSendButton:MovieClip, sendMessageCallback:Function, predictiveText:MovieClip, chatHistoryRepeatBtn:MovieClip, chatHistoryRepeatWindow:MovieClip)
      {
         super();
         if(Boolean(this.chatHistory))
         {
            throw new Error("ERROR: Singleton ChatHistory did not expect to be created twice!");
         }
         this.setupInitialItems(chatHistoryMC,chatBarContainer,upAndDownMovieClip,buddyListButton,chatMessageText,chatSendButton,sendMessageCallback,predictiveText,chatHistoryRepeatBtn,chatHistoryRepeatWindow);
      }
      
      public function reload(chatHistoryMC:MovieClip, chatBarContainer:MovieClip, upAndDownMovieClip:MovieClip, buddyListButton:MovieClip, chatMessageText:TextField, chatSendButton:MovieClip, predictiveText:MovieClip, chatHistoryRepeatBtn:MovieClip, chatHistoryRepeatWindow:MovieClip, completeRebuild:Boolean) : void
      {
         this._keyListenersActive = true;
         if(Boolean(this.chatHistory))
         {
            this.chatHistory.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         }
         if(Boolean(this.chatUpDown))
         {
            this.chatUpDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler);
         }
         if(Boolean(this._chatText))
         {
            this._chatText.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         }
         if(Boolean(this.chatMsgText))
         {
            this.chatMsgText.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this.chatMsgText.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this.chatMsgText.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
            this.chatMsgText.removeEventListener(TextEvent.TEXT_INPUT,this.onTextInput);
            if(Boolean(Mouse["supportsNativeCursor"]))
            {
               this.chatMsgText.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText);
               this.chatMsgText.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText);
            }
         }
         if(Boolean(this._chatRepeatBtn))
         {
            this._chatRepeatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChatRepeatBtn);
         }
         this._hasSetupChatRepeatBtn = false;
         this.setupInitialItems(chatHistoryMC,chatBarContainer,upAndDownMovieClip,buddyListButton,chatMessageText,chatSendButton,this.sendMsgCallback,predictiveText,chatHistoryRepeatBtn,chatHistoryRepeatWindow);
      }
      
      public function resetChatPrivs(reload:Boolean = false) : void
      {
         var sgChatType:int = 0;
         if(Utility.canChat())
         {
            sgChatType = int(gMainFrame.userInfo.sgChatType);
            if(this.isAllowedFreeChat())
            {
               this.chatMsgText.restrict = TEXT_RESTRICTION;
               this._previousRestriction = null;
               this._numInterrobangs = 0;
               this._textColorTimer = new Timer(150,3);
               this._textColorTimer.addEventListener(TimerEvent.TIMER,this.onColorTimerComplete,false,0,true);
               this._defaultTextColor = 4531987;
               this.enableFreeChat(true);
            }
            else if(sgChatType != SG_CHAT_TYPE_BUBBLE && sgChatType != SG_CHAT_TYPE_RESTR_BUBBLE && (sgChatType == SG_CHAT_TYPE_PREDICTIVE || !this.isAllowedFreeChat()))
            {
               if(Boolean(reload) && Boolean(this._predictiveTextManager) && PredictiveTextManager.findPredictiveTextNodeIfPossible != null)
               {
                  this._predictiveTextManager.reload(this.chatMsgText,this._predictiveText,this._chatBarContainer);
               }
               else
               {
                  this._predictiveTextManager = new PredictiveTextManager();
                  this._predictiveTextManager.init(this.chatMsgText,PredictiveTextManager.findPredictiveTextNodeIfPossible,PredictiveTextManager.USE_TYPE_ALL,this._predictiveText,this._chatBarContainer,this.sendMsgCallback);
               }
               this._chatText.selectable = true;
               this._chatText.text = "";
               this.chatMsgText.selectable = true;
               this._enableFreeChat = true;
            }
            else
            {
               this.enableFreeChat(false);
            }
         }
         else
         {
            this.enableFreeChat(false);
         }
      }
      
      public function destroy() : void
      {
         this.chatMsgText.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
         this._keyListenersActive = false;
         this.chatMsgText.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
         this._chatText.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         this._chatText = null;
         this.chatHistory.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         this.chatHistory.visible = false;
         this.chatHistory = null;
         this.chatUpDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler);
         this.chatUpDown.visible = false;
         this.chatUpDown = null;
      }
      
      public function showChatInput(flag:Boolean) : void
      {
         this.chatUpDown.visible = flag;
         this.chatMsgText.visible = flag;
         this.chatSendBtn.visible = flag;
      }
      
      public function addMessageById(userId:int, chatMessage:String) : void
      {
         var userName:String = null;
         var avInfo:AvatarInfo = null;
         var avt:Avatar = AvatarManager.getAvatarBySfsUserId(userId);
         if(Boolean(avt))
         {
            userName = avt.userName;
            if(userName != null && userName != "_unknown")
            {
               avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
               if(Boolean(avInfo))
               {
                  this.addMessage(avInfo.avName,avInfo.userName,chatMessage);
               }
            }
         }
      }
      
      public function addMessage(avatarName:String, userName:String, chatMessage:String) : void
      {
         var tempStr:String = null;
         var containsText:Boolean = false;
         var indexOfContainedMsg:int = 0;
         var i:int = 0;
         if(avatarName != null && avatarName.length > 0)
         {
            this._chatText.appendText(avatarName + ": " + chatMessage + "\n");
            if(Boolean(this._chatRepeatWindow) && Boolean(AvatarManager.playerAvatar) && userName == AvatarManager.playerAvatar.userName)
            {
               for(i = 0; i < this._chatRepeatArray.length; i++)
               {
                  if(this._chatRepeatArray[i] == chatMessage)
                  {
                     containsText = true;
                     indexOfContainedMsg = i;
                     break;
                  }
               }
               if(!containsText)
               {
                  if(this._chatRepeatArray.length >= 5)
                  {
                     this._chatRepeatArray.shift();
                  }
                  this._chatRepeatArray.push(chatMessage);
                  this.onChatRepeatBtn(null);
               }
               else
               {
                  this._chatRepeatArray.splice(indexOfContainedMsg,1);
                  this._chatRepeatArray.push(chatMessage);
                  this.onChatRepeatBtn(null);
               }
               this.setupRepeatChat();
            }
         }
         else
         {
            this._chatText.appendText("\"" + chatMessage + "\"" + "\n");
         }
         while(this._chatText.numLines >= 100)
         {
            tempStr = this._chatText.text;
            this._chatText.text = tempStr.substr(tempStr.indexOf("\r") + 1);
         }
         this._chatText.scrollV = this._chatText.maxScrollV;
      }
      
      public function removeEmotesFromChatRepeat() : void
      {
         var i:int = 0;
         if(Boolean(this._chatRepeatArray) && this._chatRepeatArray.length > 0)
         {
            for(i = 0; i < this._chatRepeatArray.length; i++)
            {
               if(EmoticonUtility.doesStringMatchAnEmote(this._chatRepeatArray[i]))
               {
                  this._chatRepeatArray.splice(i,1);
                  i--;
               }
            }
            this.setupRepeatChat();
            this.onChatRepeatBtn(null);
         }
      }
      
      public function addPrivateMessage(senderName:String, recipientName:String, chatMessage:String) : void
      {
         var normalFormat:TextFormat = new TextFormat();
         var whisperFormat:TextFormat = new TextFormat();
         DebugUtility.debugTrace("sender: " + senderName + " recip: " + recipientName);
         normalFormat.color = 6572056;
         normalFormat.bold = false;
         whisperFormat.color = 16711680;
         whisperFormat.bold = true;
         if(this._chatText.length == 0)
         {
            this._chatText.setTextFormat(whisperFormat);
         }
         else
         {
            this._chatText.setTextFormat(whisperFormat,this._chatText.length - 1,this._chatText.length);
         }
         if(recipientName == null)
         {
            this._chatText.appendText(senderName + ": " + chatMessage + "\n");
         }
         else
         {
            this._chatText.appendText(senderName + " to " + recipientName + ": " + chatMessage + "\n");
         }
         this._chatText.setTextFormat(normalFormat,this._chatText.length - 1,this._chatText.length);
      }
      
      public function reAddKeyListeners() : void
      {
         if(!this._keyListenersActive)
         {
            this.chatMsgText.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
            this.chatMsgText.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
            this._keyListenersActive = true;
         }
      }
      
      public function removeKeyListeners() : void
      {
         if(this._keyListenersActive)
         {
            this.chatMsgText.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this.chatMsgText.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this._keyListenersActive = false;
         }
      }
      
      public function clearChat() : void
      {
         this._chatText.text = "";
         this._chatRepeatArray = [];
         this.setupRepeatChat();
         this.onRepeatWindoesLoaded(true);
         this._chatText.scrollV = 0;
      }
      
      public function openChat() : void
      {
         if(this.chatHistory.currentFrameLabel != "open")
         {
            this.chatUpDown.gotoAndStop("down");
            if(!gMainFrame.userInfo.isMember)
            {
               this.chatUpDown["down"].activateGrayState(true);
            }
            this.chatHistory.gotoAndPlay("open");
            this.brightenChat();
            AJAudio.playChatOpenSound();
            this.closeChatRepeatWindow();
         }
      }
      
      public function closeChatRepeatWindow() : void
      {
         if(Boolean(this._chatRepeatWindow) && this._chatRepeatWindow.visible)
         {
            this._chatRepeatWindow.visible = false;
            this._chatRepeatBtn.downToUpState();
         }
      }
      
      public function dimChat() : void
      {
         if(this.chatHistory.currentFrameLabel == "open" && this.chatHistory.alpha == this.CHAT_BRIGHT_ALPHA)
         {
            this.chatHistory.alpha = this.CHAT_DIM_ALPHA;
         }
      }
      
      public function brightenChat() : void
      {
         if(this.chatHistory.alpha != this.CHAT_BRIGHT_ALPHA)
         {
            this.chatHistory.alpha = this.CHAT_BRIGHT_ALPHA;
         }
      }
      
      public function closeChat() : void
      {
         if(this.chatHistory.currentFrameLabel != null && this.chatHistory.currentFrameLabel != "close")
         {
            this.brightenChat();
            this.chatUpDown.gotoAndStop("up");
            if(!gMainFrame.userInfo.isMember)
            {
               this.chatUpDown["up"].activateGrayState(true);
            }
            this.chatHistory.gotoAndPlay("close");
            AJAudio.playChatCloseSound();
         }
      }
      
      public function get enableFreeChatValue() : Boolean
      {
         return this._enableFreeChat;
      }
      
      public function enableFreeChat(value:Boolean) : void
      {
         this._enableFreeChat = value;
         this.chatMsgText.text = "";
         if(!value)
         {
            this.chatMsgText.restrict = "";
            this._chatText.selectable = false;
            this.chatMsgText.selectable = false;
         }
         else
         {
            this.chatMsgText.restrict = TEXT_RESTRICTION;
            this._chatText.selectable = true;
            this.chatMsgText.selectable = true;
         }
      }
      
      public function resetTreeSearch() : void
      {
         if(Boolean(this._predictiveTextManager))
         {
            this._predictiveTextManager.resetTreeSearch();
         }
         if(this.isAllowedFreeChat())
         {
            this.chatMsgText.restrict = TEXT_RESTRICTION;
         }
      }
      
      public function doesChatContainText() : Boolean
      {
         if(this.chatMsgText.text != "")
         {
            return true;
         }
         return false;
      }
      
      public function setFocusOnMsgText() : void
      {
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            gMainFrame.stage.focus = this.chatMsgText;
         }
         else
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      public function toggleInGameHud(enable:Boolean) : void
      {
         if(enable)
         {
            this.chatMsgText.maxChars = 40;
         }
         else
         {
            this.chatMsgText.maxChars = 70;
         }
      }
      
      private function setupInitialItems(chatHistoryMC:MovieClip, chatBarContainer:MovieClip, upAndDownMovieClip:MovieClip, buddyListButton:MovieClip, chatMessageText:TextField, chatSendButton:MovieClip, sendMessageCallback:Function, predictiveText:MovieClip, chatHistoryRepeatBtn:MovieClip, chatHistoryRepeatWindow:MovieClip) : void
      {
         this._keyListenersActive = true;
         this.chatHistory = chatHistoryMC;
         this._predictiveText = predictiveText;
         this._chatBarContainer = chatBarContainer;
         this._chatRepeatBtn = chatHistoryRepeatBtn;
         this._chatRepeatWindow = chatHistoryRepeatWindow;
         this._chatRepeatArray = [];
         this.chatHistory.gotoAndStop(1);
         this.chatHistory.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         this.chatUpDown = upAndDownMovieClip;
         this.chatUpDown.gotoAndStop(1);
         this.chatUpDown["up"].mouse.gotoAndStop(1);
         if(!gMainFrame.userInfo.isMember)
         {
            this.chatUpDown["up"].activateGrayState(true);
         }
         this.chatUpDown.addEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler,false,0,true);
         if(Boolean(buddyListButton))
         {
            buddyListButton.glow.visible = false;
         }
         this.chatMsgText = chatMessageText;
         this.toggleInGameHud(false);
         this.chatMsgText.text = "";
         this._previousRestriction = null;
         if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_RESTR_BUBBLE)
         {
            this.chatMsgText.restrict = "";
         }
         else
         {
            this.chatMsgText.restrict = TEXT_RESTRICTION;
         }
         if(this.isAllowedFreeChat())
         {
            GuiManager.mainHud.ansChatBtn.visible = false;
            chatSendButton = GuiManager.mainHud.sendChatBtn;
            chatSendButton.visible = true;
         }
         else
         {
            GuiManager.mainHud.sendChatBtn.visible = false;
            chatSendButton = GuiManager.mainHud.ansChatBtn;
            chatSendButton.visible = true;
         }
         if(Boolean(this._chatRepeatWindow))
         {
            this._chatRepeatWindow.visible = false;
         }
         this.setupLanguageFlag();
         predictiveText.visible = false;
         this._chatText = GuiManager.mainHud.chatHistTxt;
         this.chatSendBtn = chatSendButton;
         this.sendMsgCallback = sendMessageCallback;
         this._chatText.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         this.chatMsgText.addEventListener(Event.CHANGE,this.onTextFieldChanged,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
         this.chatMsgText.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
         this.chatMsgText.addEventListener(TextEvent.TEXT_INPUT,this.onTextInput,false,0,true);
         if(Boolean(Mouse["supportsNativeCursor"]))
         {
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText,false,0,true);
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText,false,0,true);
         }
         this.chatSendBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sendChatBtnDownHandler,false,0,true);
         this.setupRepeatChat();
         this.resetChatPrivs();
         this.setFocusOnMsgText();
      }
      
      private function setupRepeatChat() : void
      {
         if(Boolean(this._chatRepeatBtn))
         {
            if(Boolean(gMainFrame.userInfo.isMember) && this._chatRepeatArray.length > 0)
            {
               this._chatRepeatBtn.visible = true;
               GuiManager.mainHud.bgChatRepeat.visible = true;
               if(!this._hasSetupChatRepeatBtn)
               {
                  this._chatRepeatBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onChatRepeatBtn,false,0,true);
               }
               this._hasSetupChatRepeatBtn = true;
            }
            else if(this._chatRepeatBtn.visible || Boolean(GuiManager.mainHud.bgChatRepeat.visible))
            {
               this._chatRepeatBtn.visible = false;
               GuiManager.mainHud.bgChatRepeat.visible = false;
               this._chatRepeatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChatRepeatBtn);
               this._hasSetupChatRepeatBtn = false;
            }
         }
      }
      
      private function setupLanguageFlag() : void
      {
         if(LocalizationManager.currentLanguage != LocalizationManager.accountLanguage)
         {
            this._chatBarContainer.flag.gotoAndStop(LocalizationManager.currentLanguage + 1);
            this._chatBarContainer.text01_chat.width = 258.75;
            this._chatBarContainer.text01_chat.x = -130.5;
            this._chatBarContainer.flag.addEventListener(MouseEvent.MOUSE_DOWN,this.onEscapeFlagDown,false,0,true);
         }
         else
         {
            this._chatBarContainer.flag.gotoAndStop("off");
            this._chatBarContainer.text01_chat.width = 290.75;
            this._chatBarContainer.text01_chat.x = -162.5;
            this._chatBarContainer.flag.removeEventListener(MouseEvent.MOUSE_DOWN,this.onEscapeFlagDown);
         }
      }
      
      private function isAllowedFreeChat() : Boolean
      {
         return gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_FREE && LocalizationManager.currentLanguage == LocalizationManager.accountLanguage && LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG;
      }
      
      private function onEscapeFlagDown(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translatePreferredIdOnly(15989),true,this.onConfirmEscape);
      }
      
      private function onConfirmEscape(o:Object) : void
      {
         if(Boolean(o.status))
         {
            RoomXtCommManager.sendRoomJoinRequest("jamaa_township.room_main#-1");
         }
      }
      
      private function openCloseHandler(m:MouseEvent) : void
      {
         if(this.chatHistory.currentFrameLabel == "open")
         {
            this.closeChat();
         }
         else if(!m.currentTarget["up"].isGray)
         {
            this.openChat();
         }
      }
      
      private function mouseOverMsgText(m:MouseEvent) : void
      {
         CursorManager.showICursor(true);
      }
      
      private function mouseOutMsgText(m:MouseEvent) : void
      {
         CursorManager.showICursor(false);
      }
      
      private function onTextInput(e:TextEvent) : void
      {
         e.preventDefault();
         this.keyDownListener(this._keyboardEvent,e.text);
      }
      
      private function msgTextDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_RESTR_BUBBLE || !Utility.canChat())
            {
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18406));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14713));
               }
               gMainFrame.stage.focus = null;
               return;
            }
            this.chatMsgText.setSelection(this.chatMsgText.length,this.chatMsgText.length);
            gMainFrame.stage.focus = this.chatMsgText;
         }
         else
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      private function chatClickHandler(m:MouseEvent) : void
      {
         this.brightenChat();
      }
      
      private function onTextFieldChanged(evt:Event) : void
      {
         if(Boolean(this._predictiveTextManager))
         {
            this._predictiveTextManager.onTextFieldChanged(evt);
         }
      }
      
      private function keyUpListener(evt:KeyboardEvent) : void
      {
         if(evt.keyCode > 36 && evt.keyCode < 41)
         {
            this.chatMsgText.setSelection(this.chatMsgText.length,this.chatMsgText.length);
            return;
         }
         if(this._enableFreeChat)
         {
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_PREDICTIVE && !this.isAllowedFreeChat())
            {
               if(Boolean(this._predictiveTextManager))
               {
                  this._predictiveTextManager.onKeyUp(evt);
               }
            }
            else if(this.isAllowedFreeChat())
            {
               if(evt.keyCode == Keyboard.ENTER)
               {
                  return;
               }
               if(evt.keyCode == Keyboard.BACKSPACE)
               {
                  if(this.chatMsgText.restrict == "")
                  {
                     this.chatMsgText.restrict = this._previousRestriction;
                     this._previousRestriction = null;
                  }
                  else if(this.chatMsgText.restrict == TEXT_RESTRICTION_INTERROBANG)
                  {
                     if(this._numInterrobangs == 0)
                     {
                        this.chatMsgText.restrict = TEXT_RESTRICTION;
                        this._previousRestriction = null;
                     }
                  }
               }
            }
         }
      }
      
      private function keyDownListener(evt:KeyboardEvent, textFieldInput:String = null) : void
      {
         var showColorChange:Boolean = false;
         var regEx:RegExp = null;
         var matchArray:Array = null;
         if(textFieldInput == null && evt.keyCode != Keyboard.ENTER && evt.keyCode != Keyboard.BACKSPACE && evt.keyCode != Keyboard.TAB && evt.keyCode != Keyboard.SHIFT && evt.keyCode != Keyboard.ALTERNATE && !evt.altKey && !evt.ctrlKey)
         {
            this._keyboardEvent = evt;
            return;
         }
         if(this._keyboardEvent == null && evt == null)
         {
            return;
         }
         if(this._enableFreeChat)
         {
            if(this.isAllowedFreeChat())
            {
               if(evt.shiftKey && evt.keyCode != Keyboard.SHIFT)
               {
                  AJAudio.playTextType();
               }
               else if(evt.keyCode != Keyboard.SHIFT)
               {
                  AJAudio.playTextType();
               }
               if(evt.keyCode == Keyboard.ENTER)
               {
                  AJAudio.playTextEnter();
                  if(this.chatMsgText.text.length > 0)
                  {
                     this.chatMsgText.restrict = TEXT_RESTRICTION;
                     this._previousRestriction = null;
                     this._numInterrobangs = 0;
                     this.sendMsgCallback(null);
                     this._keyboardEvent = null;
                     return;
                  }
               }
               if(evt.keyCode == Keyboard.BACKSPACE)
               {
                  if(this.chatMsgText.restrict == TEXT_RESTRICTION_INTERROBANG)
                  {
                     if(this._numInterrobangs == 1)
                     {
                        this.chatMsgText.restrict = this._previousRestriction;
                        this._previousRestriction = TEXT_RESTRICTION;
                     }
                     --this._numInterrobangs;
                  }
                  else if(this.chatMsgText.restrict == "")
                  {
                     this.chatMsgText.restrict = this._previousRestriction;
                     if(this._previousRestriction == TEXT_RESTRICTION_INTERROBANG)
                     {
                        --this._numInterrobangs;
                        this._previousRestriction = TEXT_RESTRICTION;
                     }
                  }
                  else if(this.chatMsgText.restrict == TEXT_RESTRICTION)
                  {
                     this._numInterrobangs = 0;
                  }
                  if(evt.ctrlKey)
                  {
                     this._numInterrobangs = 0;
                     this.chatMsgText.restrict = TEXT_RESTRICTION;
                     this._previousRestriction = null;
                  }
               }
               else if(textFieldInput == "." && !evt.shiftKey || evt.shiftKey && (textFieldInput == "?" || textFieldInput == "!"))
               {
                  if(this.chatMsgText.restrict == TEXT_RESTRICTION)
                  {
                     this._previousRestriction = TEXT_RESTRICTION;
                     this.chatMsgText.restrict = TEXT_RESTRICTION_INTERROBANG;
                  }
                  ++this._numInterrobangs;
               }
               if(textFieldInput != null && evt.keyCode != Keyboard.SHIFT && evt.keyCode != Keyboard.BACKSPACE && !evt.ctrlKey && evt.keyCode != Keyboard.CAPS_LOCK && evt.keyCode != 144 && evt.keyCode != 145 && evt.keyCode != Keyboard.PAUSE && evt.keyCode != Keyboard.TAB && evt.keyCode != Keyboard.ESCAPE && (evt.keyCode < 112 || evt.keyCode > 126) && evt.keyCode != 91)
               {
                  regEx = new RegExp("[" + this.chatMsgText.restrict + "]","g");
                  matchArray = textFieldInput.match(regEx);
                  if(matchArray == null || matchArray.length == 0 || matchArray.length != textFieldInput.length || (this.chatMsgText.maxChars > 0 ? Boolean(this.chatMsgText.length >= this.chatMsgText.maxChars) : Boolean(false)))
                  {
                     showColorChange = true;
                  }
                  else
                  {
                     this.chatMsgText.appendText(textFieldInput);
                  }
                  if(showColorChange)
                  {
                     AJAudio.playLimitedChatErrorSound();
                     this.chatMsgText.textColor = 16711680;
                     this._textColorTimer.start();
                  }
                  else
                  {
                     this._textColorTimer.reset();
                     this.chatMsgText.textColor = this._defaultTextColor;
                  }
               }
               else
               {
                  this._textColorTimer.reset();
                  this.chatMsgText.textColor = this._defaultTextColor;
               }
               this.chatMsgText.setSelection(this.chatMsgText.length,this.chatMsgText.length);
               this._keyboardEvent = null;
               return;
            }
            if(Boolean(this._predictiveTextManager))
            {
               this._predictiveTextManager.onKeyDown(evt,textFieldInput);
            }
         }
         this._keyboardEvent = null;
      }
      
      private function onColorTimerComplete(t:TimerEvent) : void
      {
         if(this._textColorTimer.currentCount == this._textColorTimer.repeatCount)
         {
            this._textColorTimer.reset();
            this.chatMsgText.textColor = this._defaultTextColor;
         }
         else if(this._textColorTimer.currentCount % 2 == 0)
         {
            this.chatMsgText.textColor = 16711680;
         }
         else
         {
            this.chatMsgText.textColor = this._defaultTextColor;
         }
      }
      
      private function sendChatBtnDownHandler(evt:MouseEvent) : void
      {
         if(!evt.currentTarget.isGray)
         {
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_PREDICTIVE || !this.isAllowedFreeChat())
            {
               if(LocalizationManager.accountLanguage != LocalizationManager.currentLanguage)
               {
                  this.onEscapeFlagDown(null);
               }
               else
               {
                  FeedbackManager.openFeedbackPopup(FeedbackManager.TYPE_DICTIONARY);
               }
            }
            else if(this._enableFreeChat)
            {
               if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_FREE)
               {
                  this.chatMsgText.restrict = TEXT_RESTRICTION;
                  this._previousRestriction = null;
                  this._numInterrobangs = 0;
                  if(this.chatMsgText.text.length > 0)
                  {
                     this.sendMsgCallback(null);
                  }
                  return;
               }
               if(Boolean(this._predictiveTextManager))
               {
                  this._predictiveTextManager.onSendBtnDown(evt);
               }
               this.chatSendBtn.down.visible = false;
               this.chatSendBtn.mouse.visible = true;
               this.chatSendBtn.mouse.gotoAndPlay(1);
            }
         }
      }
      
      private function onChatRepeatBtn(evt:MouseEvent) : void
      {
         if(evt == null || !evt.currentTarget.isGray)
         {
            if(evt != null && this._chatRepeatWindow.visible)
            {
               this._chatRepeatWindow.visible = false;
               return;
            }
            if(evt == null && !this._chatRepeatWindow.visible)
            {
               return;
            }
            this._chatRepeatWindow.visible = true;
            if(this.chatHistory.visible)
            {
               this.closeChat();
            }
            if(Boolean(this._repeatChatWindows))
            {
               this._repeatChatWindows.destroy();
               this._repeatChatWindows = null;
            }
            while(this._chatRepeatWindow.itemWindow.numChildren > 1)
            {
               this._chatRepeatWindow.itemWindow.removeChildAt(1);
            }
            this._repeatChatWindows = new WindowGenerator();
            this._repeatChatWindows.init(1,this._chatRepeatArray.length,this._chatRepeatArray.length,0,0,0,ItemWindowTextNode,this._chatRepeatArray,"",{
               "mouseDown":this.onRepeatChatSelected,
               "mouseOver":null,
               "mouseOut":null
            },null,this.onRepeatWindoesLoaded);
            this._chatRepeatWindow.itemWindow.addChild(this._repeatChatWindows);
         }
      }
      
      private function onRepeatWindoesLoaded(reset:Boolean = false) : void
      {
         if(Boolean(this._chatRepeatWindow))
         {
            this._chatRepeatWindow.m.height = reset ? 33 : Math.round(this._repeatChatWindows.height);
            this._chatRepeatWindow.m.width = this._chatRepeatWindow.t.width = this._chatRepeatWindow.b.width = reset ? 268 : this._repeatChatWindows.width + 2;
            this._chatRepeatWindow.m.y = this._chatRepeatWindow.b.y - this._chatRepeatWindow.m.height;
            this._chatRepeatWindow.t.y = this._chatRepeatWindow.m.y - this._chatRepeatWindow.t.height;
            this._chatRepeatWindow.itemWindow.x = this._chatRepeatWindow.m.x;
            this._chatRepeatWindow.itemWindow.y = this._chatRepeatWindow.m.y;
         }
      }
      
      private function onRepeatChatSelected(evt:MouseEvent) : void
      {
         if(!AvatarManager.playerAvatarWorldView.isSameMessage(evt.currentTarget.text))
         {
            this.sendMsgCallback(null,evt.currentTarget.text);
            SBTracker.trackPageview("/game/play/popup/repeatChat/#repeat",-1,SBTracker.TYPE_EVENT);
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/repeatChat/#repeatDeny",-1,SBTracker.TYPE_EVENT);
         }
         this.closeChatRepeatWindow();
      }
   }
}

