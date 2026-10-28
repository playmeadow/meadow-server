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
      
      private var _specialCharText:MovieClip;
      
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
      
      private var _currWordLength:int;
      
      private var _writtenWordsLength:Array;
      
      private var _wordCapitalizationProperties:Array;
      
      private var _firstLetterWasCapital:Boolean;
      
      private var _secondLetterWasCapital:Boolean;
      
      public var chatHistory:MovieClip;
      
      public var chatUpDown:MovieClip;
      
      public var chatMsgText:TextField;
      
      public var chatSendBtn:MovieClip;
      
      public var sendMsgCallback:Function;
      
      public function ChatHistory(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip)
      {
         super();
         if(this.chatHistory)
         {
            throw new Error("ERROR: Singleton ChatHistory did not expect to be created twice!");
         }
         this.setupInitialItems(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip, param12:Boolean) : void
      {
         this._keyListenersActive = true;
         if(this.chatHistory)
         {
            this.chatHistory.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         }
         if(this.chatUpDown)
         {
            this.chatUpDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler);
         }
         if(this._chatText)
         {
            this._chatText.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         }
         if(this.chatMsgText)
         {
            this.chatMsgText.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this.chatMsgText.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this.chatMsgText.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
            this.chatMsgText.removeEventListener(TextEvent.TEXT_INPUT,this.onTextInput);
            if(Mouse["supportsNativeCursor"])
            {
               this.chatMsgText.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText);
               this.chatMsgText.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText);
            }
         }
         if(this._chatRepeatBtn)
         {
            this._chatRepeatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onChatRepeatBtn);
         }
         this._hasSetupChatRepeatBtn = false;
         this.setupInitialItems(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      public function resetChatPrivs(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         if(Utility.canChat())
         {
            _loc2_ = int(gMainFrame.userInfo.sgChatType);
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
            else if(_loc2_ != SG_CHAT_TYPE_BUBBLE && _loc2_ != SG_CHAT_TYPE_RESTR_BUBBLE && (_loc2_ == SG_CHAT_TYPE_PREDICTIVE || !this.isAllowedFreeChat()))
            {
               if(Boolean(param1) && Boolean(this._predictiveTextManager) && PredictiveTextManager.findPredictiveTextNodeIfPossible != null)
               {
                  this._predictiveTextManager.reload(this.chatMsgText,this._predictiveText,this._specialCharText,this._chatBarContainer);
               }
               else
               {
                  this._predictiveTextManager = new PredictiveTextManager();
                  this._predictiveTextManager.init(this.chatMsgText,PredictiveTextManager.findPredictiveTextNodeIfPossible,PredictiveTextManager.USE_TYPE_ALL,this._predictiveText,this._specialCharText,this._chatBarContainer,this.sendMsgCallback);
               }
               if(this._chatText)
               {
                  this._chatText.selectable = true;
                  this._chatText.text = "";
               }
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
         if(this._chatText)
         {
            this._chatText.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
            this._chatText = null;
         }
         this.chatHistory.removeEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler);
         this.chatHistory.visible = false;
         this.chatHistory = null;
         this.chatUpDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler);
         this.chatUpDown.visible = false;
         this.chatUpDown = null;
      }
      
      public function showChatInput(param1:Boolean) : void
      {
         this.chatUpDown.visible = param1;
         this.chatMsgText.visible = param1;
         if(this.chatSendBtn)
         {
            this.chatSendBtn.visible = param1;
         }
      }
      
      public function addMessageById(param1:int, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:AvatarInfo = null;
         var _loc3_:Avatar = AvatarManager.getAvatarBySfsUserId(param1);
         if(_loc3_)
         {
            _loc4_ = _loc3_.userName;
            if(_loc4_ != null && _loc4_ != "_unknown")
            {
               _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc4_);
               if(_loc5_)
               {
                  this.addMessage(_loc5_.avName,_loc5_.userName,param2);
               }
            }
         }
      }
      
      public function addMessage(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:String = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1 != null && param1.length > 0)
         {
            this._chatText.appendText(param1 + ": " + param3 + "\n");
            if(Boolean(this._chatRepeatWindow) && Boolean(AvatarManager.playerAvatar) && param2.toLowerCase() == AvatarManager.playerAvatar.userName.toLowerCase())
            {
               _loc7_ = 0;
               while(_loc7_ < this._chatRepeatArray.length)
               {
                  if(this._chatRepeatArray[_loc7_] == param3)
                  {
                     _loc5_ = true;
                     _loc6_ = _loc7_;
                     break;
                  }
                  _loc7_++;
               }
               if(!_loc5_)
               {
                  if(this._chatRepeatArray.length >= 5)
                  {
                     this._chatRepeatArray.shift();
                  }
                  this._chatRepeatArray.push(param3);
                  this.onChatRepeatBtn(null);
               }
               else
               {
                  this._chatRepeatArray.splice(_loc6_,1);
                  this._chatRepeatArray.push(param3);
                  this.onChatRepeatBtn(null);
               }
               this.setupRepeatChat();
            }
         }
         else
         {
            this._chatText.appendText("\"" + param3 + "\"" + "\n");
         }
         while(this._chatText.numLines >= 100)
         {
            _loc4_ = this._chatText.text;
            this._chatText.text = _loc4_.substr(_loc4_.indexOf("\r") + 1);
         }
         this._chatText.scrollV = this._chatText.maxScrollV;
      }
      
      public function removeEmotesFromChatRepeat() : void
      {
         var _loc1_:* = 0;
         if(Boolean(this._chatRepeatArray) && this._chatRepeatArray.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this._chatRepeatArray.length)
            {
               if(EmoticonUtility.doesStringMatchAnEmote(this._chatRepeatArray[_loc1_]))
               {
                  this._chatRepeatArray.splice(_loc1_,1);
                  _loc1_--;
               }
               _loc1_++;
            }
            this.setupRepeatChat();
            this.onChatRepeatBtn(null);
         }
      }
      
      public function addPrivateMessage(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:TextFormat = new TextFormat();
         var _loc5_:TextFormat = new TextFormat();
         DebugUtility.debugTrace("sender: " + param1 + " recip: " + param2);
         _loc4_.color = 6572056;
         _loc4_.bold = false;
         _loc5_.color = 16711680;
         _loc5_.bold = true;
         if(this._chatText)
         {
            if(this._chatText.length == 0)
            {
               this._chatText.setTextFormat(_loc5_);
            }
            else
            {
               this._chatText.setTextFormat(_loc5_,this._chatText.length - 1,this._chatText.length);
            }
            if(param2 == null)
            {
               this._chatText.appendText(param1 + ": " + param3 + "\n");
            }
            else
            {
               this._chatText.appendText(param1 + " to " + param2 + ": " + param3 + "\n");
            }
            this._chatText.setTextFormat(_loc4_,this._chatText.length - 1,this._chatText.length);
         }
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
         if(this._chatText)
         {
            this._chatText.text = "";
         }
         this._chatRepeatArray = [];
         this.setupRepeatChat();
         this.onRepeatWindoesLoaded(true);
         if(this._chatText)
         {
            this._chatText.scrollV = 0;
         }
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
         if(Boolean(this.chatHistory) && Boolean(this.chatHistory.currentFrameLabel == "open") && this.chatHistory.alpha == this.CHAT_BRIGHT_ALPHA)
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
         if(Boolean(this.chatHistory) && Boolean(this.chatHistory.currentFrameLabel != null) && this.chatHistory.currentFrameLabel != "close")
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
      
      public function enableFreeChat(param1:Boolean) : void
      {
         this._enableFreeChat = param1;
         this.chatMsgText.text = "";
         if(!param1)
         {
            this.chatMsgText.restrict = "";
            if(this._chatText)
            {
               this._chatText.selectable = false;
            }
            this.chatMsgText.selectable = false;
         }
         else
         {
            this.chatMsgText.restrict = TEXT_RESTRICTION;
            if(this._chatText)
            {
               this._chatText.selectable = true;
            }
            this.chatMsgText.selectable = true;
         }
         if(this._specialCharText)
         {
            this._specialCharText.visible = false;
         }
      }
      
      public function resetTreeSearch() : void
      {
         if(this._predictiveTextManager)
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
      
      public function toggleInGameHud(param1:Boolean) : void
      {
         if(param1)
         {
            this.chatMsgText.maxChars = 40;
         }
         else
         {
            this.chatMsgText.maxChars = 70;
         }
      }
      
      private function setupInitialItems(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip) : void
      {
         this._keyListenersActive = true;
         this.chatHistory = param1;
         this._predictiveText = param8;
         this._specialCharText = param9;
         this._chatBarContainer = param2;
         this._chatRepeatBtn = param10;
         this._chatRepeatWindow = param11;
         this._chatRepeatArray = [];
         this._writtenWordsLength = [];
         this._wordCapitalizationProperties = [];
         this._firstLetterWasCapital = false;
         this._secondLetterWasCapital = false;
         if(param1)
         {
            this.chatHistory.gotoAndStop(1);
            this.chatHistory.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
            this.chatUpDown = param3;
            this.chatUpDown.gotoAndStop(1);
            this.chatUpDown["up"].mouse.gotoAndStop(1);
            if(!gMainFrame.userInfo.isMember)
            {
               this.chatUpDown["up"].activateGrayState(true);
            }
            this.chatUpDown.addEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler,false,0,true);
         }
         if(param4)
         {
            param4.glow.visible = false;
         }
         this.chatMsgText = param5;
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
            if(GuiManager.mainHud.ansChatBtn)
            {
               GuiManager.mainHud.ansChatBtn.visible = false;
            }
            param6 = GuiManager.mainHud.sendChatBtn;
            if(param6)
            {
               param6.visible = true;
            }
         }
         else
         {
            if(GuiManager.mainHud.sendChatBtn)
            {
               GuiManager.mainHud.sendChatBtn.visible = false;
            }
            param6 = GuiManager.mainHud.ansChatBtn;
            if(param6)
            {
               param6.visible = true;
            }
         }
         if(this._chatRepeatWindow)
         {
            this._chatRepeatWindow.visible = false;
         }
         this.setupLanguageFlag();
         param8.visible = false;
         this._chatText = GuiManager.mainHud.chatHistTxt;
         this.chatSendBtn = param6;
         this.sendMsgCallback = param7;
         if(this._chatText)
         {
            this._chatText.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         }
         this.chatMsgText.addEventListener(Event.CHANGE,this.onTextFieldChanged,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
         this.chatMsgText.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
         this.chatMsgText.addEventListener(TextEvent.TEXT_INPUT,this.onTextInput,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText,false,0,true);
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText,false,0,true);
         }
         if(this.chatSendBtn)
         {
            this.chatSendBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sendChatBtnDownHandler,false,0,true);
         }
         this.setupRepeatChat();
         this.resetChatPrivs();
         this.setFocusOnMsgText();
      }
      
      private function setupRepeatChat() : void
      {
         if(this._chatRepeatBtn)
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
      
      private function onEscapeFlagDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translatePreferredIdOnly(15989),true,this.onConfirmEscape);
      }
      
      private function onConfirmEscape(param1:Object) : void
      {
         if(param1.status)
         {
            RoomXtCommManager.sendRoomJoinRequest("jamaa_township.room_main#-1");
         }
      }
      
      private function openCloseHandler(param1:MouseEvent) : void
      {
         if(this.chatHistory.currentFrameLabel == "open")
         {
            this.closeChat();
         }
         else if(!param1.currentTarget["up"].isGray)
         {
            this.openChat();
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
      
      private function onTextInput(param1:TextEvent) : void
      {
         param1.preventDefault();
         this.keyDownListener(this._keyboardEvent,param1.text);
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function chatClickHandler(param1:MouseEvent) : void
      {
         this.brightenChat();
      }
      
      private function onTextFieldChanged(param1:Event) : void
      {
         if(this._predictiveTextManager)
         {
            this._predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyUpListener(param1:KeyboardEvent) : void
      {
         if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            this.chatMsgText.setSelection(this.chatMsgText.length,this.chatMsgText.length);
            return;
         }
         if(this._enableFreeChat)
         {
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_PREDICTIVE && !this.isAllowedFreeChat())
            {
               if(this._predictiveTextManager)
               {
                  this._predictiveTextManager.onKeyUp(param1);
               }
            }
            else if(this.isAllowedFreeChat())
            {
               if(param1.keyCode == Keyboard.ENTER)
               {
                  return;
               }
               if(param1.keyCode == Keyboard.BACKSPACE)
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
      
      private function keyDownListener(param1:KeyboardEvent, param2:String = null) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:RegExp = null;
         var _loc6_:Array = null;
         if(param2 == null && param1.keyCode != Keyboard.ENTER && param1.keyCode != Keyboard.BACKSPACE && param1.keyCode != Keyboard.TAB && param1.keyCode != Keyboard.SHIFT && param1.keyCode != Keyboard.ALTERNATE && !param1.altKey && !param1.ctrlKey && param1.keyCode != Keyboard.INSERT)
         {
            this._keyboardEvent = param1;
            return;
         }
         if(this._keyboardEvent == null && param1 == null)
         {
            return;
         }
         if(this._enableFreeChat)
         {
            if(this.isAllowedFreeChat())
            {
               if(param1.shiftKey && param1.keyCode != Keyboard.SHIFT)
               {
                  AJAudio.playTextType();
               }
               else if(param1.keyCode != Keyboard.SHIFT)
               {
                  AJAudio.playTextType();
               }
               if(param1.keyCode == Keyboard.ENTER)
               {
                  AJAudio.playTextEnter();
                  if(this.chatMsgText.text.length > 0)
                  {
                     this.chatMsgText.restrict = TEXT_RESTRICTION;
                     this._previousRestriction = null;
                     this._numInterrobangs = 0;
                     this._currWordLength = 0;
                     this.sendMsgCallback(null);
                     this._keyboardEvent = null;
                     return;
                  }
               }
               if(param1.keyCode == Keyboard.BACKSPACE)
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
                  if(this.chatMsgText.text.length == 0)
                  {
                     this._currWordLength = 0;
                     this._writtenWordsLength = [];
                     this._wordCapitalizationProperties = [];
                  }
                  else if(this._currWordLength == 0)
                  {
                     this._currWordLength = this._writtenWordsLength.pop();
                     _loc3_ = this._wordCapitalizationProperties.pop();
                     if(_loc3_)
                     {
                        this._firstLetterWasCapital = _loc3_.firstLetterWasCapital;
                        this._secondLetterWasCapital = _loc3_.secondLetterWasCapital;
                     }
                     else
                     {
                        this._firstLetterWasCapital = false;
                        this._secondLetterWasCapital = false;
                     }
                  }
                  else
                  {
                     --this._currWordLength;
                  }
                  if(param1.ctrlKey)
                  {
                     this._numInterrobangs = 0;
                     this.chatMsgText.restrict = TEXT_RESTRICTION;
                     this._previousRestriction = null;
                  }
               }
               else if(param2 == "." && !param1.shiftKey || param1.shiftKey && (param2 == "?" || param2 == "!"))
               {
                  if(this.chatMsgText.restrict == TEXT_RESTRICTION)
                  {
                     this._previousRestriction = TEXT_RESTRICTION;
                     this.chatMsgText.restrict = TEXT_RESTRICTION_INTERROBANG;
                  }
                  ++this._numInterrobangs;
               }
               if(param2 != null && param1.keyCode != Keyboard.SHIFT && param1.keyCode != Keyboard.BACKSPACE && !param1.ctrlKey && param1.keyCode != Keyboard.CAPS_LOCK && param1.keyCode != 144 && param1.keyCode != 145 && param1.keyCode != Keyboard.PAUSE && param1.keyCode != Keyboard.TAB && param1.keyCode != Keyboard.ESCAPE && (param1.keyCode < 112 || param1.keyCode > 126) && param1.keyCode != 91)
               {
                  _loc5_ = new RegExp("[" + this.chatMsgText.restrict + "]","g");
                  _loc6_ = param2.match(_loc5_);
                  if(_loc6_ == null || _loc6_.length == 0 || _loc6_.length != param2.length || (this.chatMsgText.maxChars > 0 ? Boolean(this.chatMsgText.length >= this.chatMsgText.maxChars) : Boolean(false)))
                  {
                     _loc4_ = true;
                  }
                  else
                  {
                     if(param2 == " ")
                     {
                        this._writtenWordsLength.push(this._currWordLength);
                        this._wordCapitalizationProperties.push({
                           "firstLetterWasCapital":this._firstLetterWasCapital,
                           "secondLetterWasCapital":this._secondLetterWasCapital
                        });
                        this._currWordLength = 0;
                        this._firstLetterWasCapital = false;
                        this._secondLetterWasCapital = false;
                     }
                     else
                     {
                        if(this._currWordLength == 0)
                        {
                           this._firstLetterWasCapital = param2 == param2.toUpperCase();
                        }
                        else if(this._currWordLength == 1)
                        {
                           if(!this._firstLetterWasCapital)
                           {
                              param2 = param2.toLowerCase();
                           }
                           this._secondLetterWasCapital = param2 == param2.toUpperCase();
                        }
                        else if(this._currWordLength >= 2)
                        {
                           if(this._secondLetterWasCapital)
                           {
                              param2 = param2.toUpperCase();
                           }
                           else
                           {
                              param2 = param2.toLowerCase();
                           }
                        }
                        ++this._currWordLength;
                     }
                     this.chatMsgText.appendText(param2);
                  }
                  if(_loc4_)
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
            if(this._predictiveTextManager)
            {
               this._predictiveTextManager.onKeyDown(param1,param2);
            }
         }
         this._keyboardEvent = null;
      }
      
      private function onColorTimerComplete(param1:TimerEvent) : void
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
      
      private function sendChatBtnDownHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
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
                  this._wordCapitalizationProperties = [];
                  this._writtenWordsLength = [];
                  this._firstLetterWasCapital = false;
                  this._secondLetterWasCapital = false;
                  this._currWordLength = 0;
                  if(this.chatMsgText.text.length > 0)
                  {
                     this.sendMsgCallback(null);
                  }
                  return;
               }
               if(this._predictiveTextManager)
               {
                  this._predictiveTextManager.onSendBtnDown(param1);
               }
               this.chatSendBtn.down.visible = false;
               this.chatSendBtn.mouse.visible = true;
               this.chatSendBtn.mouse.gotoAndPlay(1);
            }
         }
      }
      
      private function onChatRepeatBtn(param1:MouseEvent) : void
      {
         if(param1 == null || !param1.currentTarget.isGray)
         {
            if(param1 != null && this._chatRepeatWindow.visible)
            {
               this._chatRepeatWindow.visible = false;
               return;
            }
            if(param1 == null && !this._chatRepeatWindow.visible)
            {
               return;
            }
            this._chatRepeatWindow.visible = true;
            if(this.chatHistory.visible)
            {
               this.closeChat();
            }
            if(this._repeatChatWindows)
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
      
      private function onRepeatWindoesLoaded(param1:Boolean = false) : void
      {
         if(this._chatRepeatWindow)
         {
            this._chatRepeatWindow.m.height = param1 ? 33 : Math.round(this._repeatChatWindows.height);
            this._chatRepeatWindow.m.width = this._chatRepeatWindow.t.width = this._chatRepeatWindow.b.width = param1 ? 268 : this._repeatChatWindows.width + 2;
            this._chatRepeatWindow.m.y = this._chatRepeatWindow.b.y - this._chatRepeatWindow.m.height;
            this._chatRepeatWindow.t.y = this._chatRepeatWindow.m.y - this._chatRepeatWindow.t.height;
            this._chatRepeatWindow.itemWindow.x = this._chatRepeatWindow.m.x;
            this._chatRepeatWindow.itemWindow.y = this._chatRepeatWindow.m.y;
         }
      }
      
      private function onRepeatChatSelected(param1:MouseEvent) : void
      {
         if(!AvatarManager.playerAvatarWorldView.isSameMessage(param1.currentTarget.text))
         {
            this.sendMsgCallback(null,param1.currentTarget.text);
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

