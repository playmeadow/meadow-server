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
   import flash.ui.Mouse;
   import flash.utils.Timer;
   import gui.itemWindows.ItemWindowTextNode;
   import localization.LocalizationManager;
   import quest.QuestManager;
   import room.RoomXtCommManager;
   
   public class ChatHistory
   {
      
      public static const SG_CHAT_TYPE_BUBBLE:int = 0;
      
      public static const SG_CHAT_TYPE_FREE:int = 1;
      
      public static const SG_CHAT_TYPE_PREDICTIVE:int = 2;
      
      public static const SG_CHAT_TYPE_RESTR_BUBBLE:int = 3;
      
      public static const TEXT_RESTRICTION:String = "A-Za-z0-9!\'.,():? ";
      
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
      
      private var _hasSetSecondLetterCapital:Boolean;
      
      public var chatHistory:MovieClip;
      
      public var chatUpDown:MovieClip;
      
      public var chatMsgText:TextField;
      
      public var chatSendBtn:MovieClip;
      
      public var sendMsgCallback:Function;
      
      public function ChatHistory(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip)
      {
         super();
         if(chatHistory)
         {
            throw new Error("ERROR: Singleton ChatHistory did not expect to be created twice!");
         }
         setupInitialItems(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip, param12:Boolean) : void
      {
         _keyListenersActive = true;
         if(chatHistory)
         {
            chatHistory.removeEventListener("mouseDown",chatClickHandler);
         }
         if(chatUpDown)
         {
            chatUpDown.removeEventListener("mouseDown",openCloseHandler);
         }
         if(_chatText)
         {
            _chatText.removeEventListener("mouseDown",chatClickHandler);
         }
         if(chatMsgText)
         {
            chatMsgText.removeEventListener("keyDown",keyDownListener);
            chatMsgText.removeEventListener("keyUp",keyUpListener);
            chatMsgText.removeEventListener("mouseDown",msgTextDownHandler);
            chatMsgText.removeEventListener("textInput",onTextInput);
            if(Mouse["supportsNativeCursor"])
            {
               chatMsgText.removeEventListener("mouseOver",mouseOverMsgText);
               chatMsgText.removeEventListener("mouseOut",mouseOutMsgText);
            }
         }
         if(_chatRepeatBtn)
         {
            _chatRepeatBtn.removeEventListener("mouseDown",onChatRepeatBtn);
         }
         _hasSetupChatRepeatBtn = false;
         setupInitialItems(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
      
      public function resetChatPrivs(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         if(Utility.canChat())
         {
            _loc2_ = int(gMainFrame.userInfo.sgChatType);
            if(isAllowedFreeChat())
            {
               chatMsgText.restrict = "A-Za-z0-9!\'.,():? ";
               _previousRestriction = null;
               _numInterrobangs = 0;
               _textColorTimer = new Timer(150,3);
               _textColorTimer.addEventListener("timer",onColorTimerComplete,false,0,true);
               _defaultTextColor = 4531987;
               enableFreeChat(true);
            }
            else if(_loc2_ != 0 && _loc2_ != 3 && (_loc2_ == 2 || !isAllowedFreeChat()))
            {
               if(param1 && _predictiveTextManager && PredictiveTextManager.findPredictiveTextNodeIfPossible != null)
               {
                  _predictiveTextManager.reload(chatMsgText,_predictiveText,_specialCharText,_chatBarContainer);
               }
               else
               {
                  _predictiveTextManager = new PredictiveTextManager();
                  _predictiveTextManager.init(chatMsgText,PredictiveTextManager.findPredictiveTextNodeIfPossible,0,_predictiveText,_specialCharText,343,_chatBarContainer,sendMsgCallback);
               }
               if(_chatText)
               {
                  _chatText.selectable = true;
                  _chatText.text = "";
               }
               chatMsgText.selectable = true;
               _enableFreeChat = true;
            }
            else
            {
               enableFreeChat(false);
            }
         }
         else
         {
            enableFreeChat(false);
         }
      }
      
      public function destroy() : void
      {
         chatMsgText.removeEventListener("keyDown",keyDownListener);
         _keyListenersActive = false;
         chatMsgText.removeEventListener("mouseDown",msgTextDownHandler);
         if(_chatText)
         {
            _chatText.removeEventListener("mouseDown",chatClickHandler);
            _chatText = null;
         }
         chatHistory.removeEventListener("mouseDown",chatClickHandler);
         chatHistory.visible = false;
         chatHistory = null;
         chatUpDown.removeEventListener("mouseDown",openCloseHandler);
         chatUpDown.visible = false;
         chatUpDown = null;
      }
      
      public function showChatInput(param1:Boolean) : void
      {
         chatUpDown.visible = param1;
         chatMsgText.visible = param1;
         if(chatSendBtn)
         {
            chatSendBtn.visible = param1;
         }
      }
      
      public function addMessageById(param1:int, param2:String) : void
      {
         var _loc4_:String = null;
         var _loc3_:AvatarInfo = null;
         var _loc5_:Avatar = AvatarManager.getAvatarBySfsUserId(param1);
         if(_loc5_)
         {
            _loc4_ = _loc5_.userName;
            if(_loc4_ != null && _loc4_ != "_unknown")
            {
               _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc4_);
               if(_loc3_)
               {
                  addMessage(_loc3_.avName,_loc3_.userName,param2);
               }
            }
         }
      }
      
      public function addMessage(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         if(param1 != null && param1.length > 0 && param3)
         {
            _chatText.appendText(param1 + ": " + param3 + "\n");
            if(_chatRepeatWindow && AvatarManager.playerAvatar && param2.toLowerCase() == AvatarManager.playerAvatar.userName.toLowerCase())
            {
               _loc6_ = 0;
               while(_loc6_ < _chatRepeatArray.length)
               {
                  if(_chatRepeatArray[_loc6_] == param3)
                  {
                     _loc4_ = true;
                     _loc5_ = _loc6_;
                     break;
                  }
                  _loc6_++;
               }
               if(!_loc4_)
               {
                  if(_chatRepeatArray.length >= 5)
                  {
                     _chatRepeatArray.shift();
                  }
                  _chatRepeatArray.push(param3);
                  onChatRepeatBtn(null);
               }
               else
               {
                  _chatRepeatArray.splice(_loc5_,1);
                  _chatRepeatArray.push(param3);
                  onChatRepeatBtn(null);
               }
               setupRepeatChat();
            }
         }
         else
         {
            _chatText.appendText("\"" + param3 + "\"" + "\n");
         }
         while(_chatText.numLines >= 100)
         {
            _loc7_ = _chatText.text;
            _chatText.text = _loc7_.substr(_loc7_.indexOf("\r") + 1);
         }
         _chatText.scrollV = _chatText.maxScrollV;
      }
      
      public function removeEmotesFromChatRepeat() : void
      {
         var _loc1_:int = 0;
         if(_chatRepeatArray && _chatRepeatArray.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _chatRepeatArray.length)
            {
               if(EmoticonUtility.doesStringMatchAnEmote(_chatRepeatArray[_loc1_]))
               {
                  _chatRepeatArray.splice(_loc1_,1);
                  _loc1_--;
               }
               _loc1_++;
            }
            setupRepeatChat();
            onChatRepeatBtn(null);
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
         if(_chatText)
         {
            if(_chatText.length == 0)
            {
               _chatText.setTextFormat(_loc5_);
            }
            else
            {
               _chatText.setTextFormat(_loc5_,_chatText.length - 1,_chatText.length);
            }
            if(param2 == null)
            {
               _chatText.appendText(param1 + ": " + param3 + "\n");
            }
            else
            {
               _chatText.appendText(param1 + " to " + param2 + ": " + param3 + "\n");
            }
            _chatText.setTextFormat(_loc4_,_chatText.length - 1,_chatText.length);
         }
      }
      
      public function reAddKeyListeners() : void
      {
         if(!_keyListenersActive)
         {
            chatMsgText.addEventListener("keyDown",keyDownListener,false,0,true);
            chatMsgText.addEventListener("keyUp",keyUpListener,false,0,true);
            _keyListenersActive = true;
         }
      }
      
      public function removeKeyListeners() : void
      {
         if(_keyListenersActive)
         {
            chatMsgText.removeEventListener("keyDown",keyDownListener);
            chatMsgText.removeEventListener("keyUp",keyUpListener);
            _keyListenersActive = false;
         }
      }
      
      public function clearChat() : void
      {
         if(_chatText)
         {
            _chatText.text = "";
         }
         _chatRepeatArray = [];
         setupRepeatChat();
         onRepeatWindoesLoaded(true);
         if(_chatText)
         {
            _chatText.scrollV = 0;
         }
      }
      
      public function openChat() : void
      {
         if(chatHistory.currentFrameLabel != "open")
         {
            chatUpDown.gotoAndStop("down");
            if(!gMainFrame.userInfo.isMember)
            {
               chatUpDown["down"].activateGrayState(true);
            }
            chatHistory.gotoAndPlay("open");
            brightenChat();
            AJAudio.playChatOpenSound();
            closeChatRepeatWindow();
         }
      }
      
      public function closeChatRepeatWindow() : void
      {
         if(_chatRepeatWindow && _chatRepeatWindow.visible)
         {
            _chatRepeatWindow.visible = false;
            _chatRepeatBtn.downToUpState();
         }
      }
      
      public function dimChat() : void
      {
         if(chatHistory && chatHistory.currentFrameLabel == "open" && chatHistory.alpha == 1)
         {
            chatHistory.alpha = 0.5;
         }
      }
      
      public function brightenChat() : void
      {
         if(chatHistory.alpha != 1)
         {
            chatHistory.alpha = 1;
         }
      }
      
      public function closeChat() : void
      {
         if(chatHistory && chatHistory.currentFrameLabel != null && chatHistory.currentFrameLabel != "close")
         {
            brightenChat();
            chatUpDown.gotoAndStop("up");
            if(!gMainFrame.userInfo.isMember)
            {
               chatUpDown["up"].activateGrayState(true);
            }
            chatHistory.gotoAndPlay("close");
            AJAudio.playChatCloseSound();
         }
      }
      
      public function get enableFreeChatValue() : Boolean
      {
         return _enableFreeChat;
      }
      
      public function enableFreeChat(param1:Boolean) : void
      {
         _enableFreeChat = param1;
         chatMsgText.text = "";
         if(!param1)
         {
            chatMsgText.restrict = "";
            if(_chatText)
            {
               _chatText.selectable = false;
            }
            chatMsgText.selectable = false;
         }
         else
         {
            chatMsgText.restrict = "A-Za-z0-9!\'.,():? ";
            if(_chatText)
            {
               _chatText.selectable = true;
            }
            chatMsgText.selectable = true;
         }
         if(_specialCharText)
         {
            _specialCharText.visible = false;
         }
      }
      
      public function resetTreeSearch() : void
      {
         if(_predictiveTextManager)
         {
            _predictiveTextManager.resetTreeSearch();
         }
         if(isAllowedFreeChat())
         {
            chatMsgText.restrict = "A-Za-z0-9!\'.,():? ";
         }
      }
      
      public function doesChatContainText() : Boolean
      {
         if(chatMsgText.text != "")
         {
            return true;
         }
         return false;
      }
      
      public function setFocusOnMsgText() : void
      {
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            gMainFrame.stage.focus = chatMsgText;
         }
         else
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      public function setFocusToChatTextWithKeydown(param1:KeyboardEvent, param2:String) : void
      {
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            gMainFrame.stage.focus = chatMsgText;
            if(chatMsgText)
            {
               keyDownListener(param1,param2);
            }
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
            chatMsgText.maxChars = 40;
         }
         else
         {
            chatMsgText.maxChars = 70;
         }
      }
      
      private function setupInitialItems(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip, param9:MovieClip, param10:MovieClip, param11:MovieClip) : void
      {
         _keyListenersActive = true;
         chatHistory = param1;
         _predictiveText = param8;
         _specialCharText = param9;
         _chatBarContainer = param2;
         _chatRepeatBtn = param10;
         _chatRepeatWindow = param11;
         _chatRepeatArray = [];
         _writtenWordsLength = [];
         _wordCapitalizationProperties = [];
         _firstLetterWasCapital = false;
         _secondLetterWasCapital = false;
         _hasSetSecondLetterCapital = false;
         if(param1)
         {
            chatHistory.gotoAndStop(1);
            chatHistory.addEventListener("mouseDown",chatClickHandler,false,0,true);
            chatUpDown = param3;
            chatUpDown.gotoAndStop(1);
            chatUpDown["up"].mouse.gotoAndStop(1);
            if(!gMainFrame.userInfo.isMember)
            {
               chatUpDown["up"].activateGrayState(true);
            }
            chatUpDown.addEventListener("mouseDown",openCloseHandler,false,0,true);
         }
         if(param4)
         {
            param4.glow.visible = false;
         }
         chatMsgText = param5;
         toggleInGameHud(false);
         chatMsgText.text = "";
         _previousRestriction = null;
         if(gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3)
         {
            chatMsgText.restrict = "";
         }
         else
         {
            chatMsgText.restrict = "A-Za-z0-9!\'.,():? ";
         }
         if(GuiManager.mainHud.sendChatBtn)
         {
            GuiManager.mainHud.sendChatBtn.visible = false;
         }
         param6 = GuiManager.mainHud.ansChatBtn;
         if(param6)
         {
            param6.visible = true;
         }
         if(_chatRepeatWindow)
         {
            _chatRepeatWindow.visible = false;
         }
         setupLanguageFlag();
         param8.visible = false;
         _chatText = GuiManager.mainHud.chatHistTxt;
         chatSendBtn = param6;
         sendMsgCallback = param7;
         if(_chatText)
         {
            _chatText.addEventListener("mouseDown",chatClickHandler,false,0,true);
         }
         chatMsgText.addEventListener("change",onTextFieldChanged,false,0,true);
         chatMsgText.addEventListener("keyDown",keyDownListener,false,0,true);
         chatMsgText.addEventListener("keyUp",keyUpListener,false,0,true);
         chatMsgText.addEventListener("mouseDown",msgTextDownHandler,false,0,true);
         chatMsgText.addEventListener("textInput",onTextInput,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            chatMsgText.addEventListener("mouseOver",mouseOverMsgText,false,0,true);
            chatMsgText.addEventListener("mouseOut",mouseOutMsgText,false,0,true);
         }
         if(chatSendBtn)
         {
            chatSendBtn.addEventListener("mouseDown",sendChatBtnDownHandler,false,0,true);
         }
         setupRepeatChat();
         resetChatPrivs();
         setFocusOnMsgText();
      }
      
      private function setupRepeatChat() : void
      {
         if(_chatRepeatBtn)
         {
            if(gMainFrame.userInfo.isMember && _chatRepeatArray.length > 0)
            {
               _chatRepeatBtn.visible = true;
               GuiManager.mainHud.bgChatRepeat.visible = true;
               if(!_hasSetupChatRepeatBtn)
               {
                  _chatRepeatBtn.addEventListener("mouseDown",onChatRepeatBtn,false,0,true);
               }
               _hasSetupChatRepeatBtn = true;
            }
            else if(_chatRepeatBtn.visible || GuiManager.mainHud.bgChatRepeat.visible)
            {
               _chatRepeatBtn.visible = false;
               GuiManager.mainHud.bgChatRepeat.visible = false;
               _chatRepeatBtn.removeEventListener("mouseDown",onChatRepeatBtn);
               _hasSetupChatRepeatBtn = false;
            }
         }
      }
      
      private function setupLanguageFlag() : void
      {
         if(LocalizationManager.currentLanguage != LocalizationManager.accountLanguage)
         {
            _chatBarContainer.flag.gotoAndStop(LocalizationManager.currentLanguage + 1);
            _chatBarContainer.text01_chat.width = 258.75;
            _chatBarContainer.text01_chat.x = -130.5;
            _chatBarContainer.flag.addEventListener("mouseDown",onEscapeFlagDown,false,0,true);
         }
         else
         {
            _chatBarContainer.flag.gotoAndStop("off");
            _chatBarContainer.text01_chat.width = 290.75;
            _chatBarContainer.text01_chat.x = -162.5;
            _chatBarContainer.flag.removeEventListener("mouseDown",onEscapeFlagDown);
         }
      }
      
      private function isAllowedFreeChat() : Boolean
      {
         return gMainFrame.userInfo.sgChatType == 1 && LocalizationManager.currentLanguage == LocalizationManager.accountLanguage && LocalizationManager.currentLanguage == LocalizationManager.LANG_ENG;
      }
      
      private function onEscapeFlagDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translatePreferredIdOnly(15989),true,onConfirmEscape);
      }
      
      private function onConfirmEscape(param1:Object) : void
      {
         if(param1.status)
         {
            if(QuestManager.inQuestRoom())
            {
               QuestManager.commandExit("flag");
            }
            else
            {
               RoomXtCommManager.sendRoomJoinRequest("jamaa_township.room_main#-1");
            }
         }
      }
      
      private function openCloseHandler(param1:MouseEvent) : void
      {
         if(chatHistory.currentFrameLabel == "open")
         {
            closeChat();
         }
         else if(!param1.currentTarget["up"].isGray)
         {
            openChat();
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
         keyDownListener(_keyboardEvent,param1.text);
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            if(gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3 || !Utility.canChat())
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
            chatMsgText.setSelection(chatMsgText.length,chatMsgText.length);
            gMainFrame.stage.focus = chatMsgText;
         }
         else
         {
            gMainFrame.stage.focus = null;
         }
      }
      
      private function chatClickHandler(param1:MouseEvent) : void
      {
         brightenChat();
      }
      
      private function onTextFieldChanged(param1:Event) : void
      {
         if(_predictiveTextManager)
         {
            _predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyUpListener(param1:KeyboardEvent) : void
      {
         if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            chatMsgText.setSelection(chatMsgText.length,chatMsgText.length);
            return;
         }
         if(_enableFreeChat)
         {
            if(gMainFrame.userInfo.sgChatType == 2 && !isAllowedFreeChat())
            {
               if(_predictiveTextManager)
               {
                  _predictiveTextManager.onKeyUp(param1);
               }
            }
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent, param2:String = null) : void
      {
         var _loc6_:Object = null;
         var _loc4_:Boolean = false;
         var _loc5_:RegExp = null;
         var _loc3_:Array = null;
         if(param2 == null && param1.keyCode != 13 && param1.keyCode != 8 && param1.keyCode != 9 && param1.keyCode != 16 && param1.keyCode != 18 && !param1.altKey && !param1.ctrlKey && param1.keyCode != 45)
         {
            _keyboardEvent = param1;
            return;
         }
         if(_keyboardEvent == null && param1 == null)
         {
            return;
         }
         if(_enableFreeChat)
         {
            if(isAllowedFreeChat())
            {
               if(param1.shiftKey && param1.keyCode != 16)
               {
                  AJAudio.playTextType();
               }
               else if(param1.keyCode != 16)
               {
                  AJAudio.playTextType();
               }
               if(param1.keyCode == 13)
               {
                  AJAudio.playTextEnter();
                  if(chatMsgText.text.length > 0)
                  {
                     chatMsgText.restrict = "A-Za-z0-9!\'.,():? ";
                     _previousRestriction = null;
                     _numInterrobangs = 0;
                     _currWordLength = 0;
                     sendMsgCallback(null);
                     _keyboardEvent = null;
                     return;
                  }
               }
               if(param1.keyCode == 8)
               {
                  if(chatMsgText.text.length == 0)
                  {
                     _currWordLength = 0;
                     _writtenWordsLength = [];
                     _wordCapitalizationProperties = [];
                  }
                  else if(_currWordLength == 0)
                  {
                     _currWordLength = _writtenWordsLength.pop();
                     _loc6_ = _wordCapitalizationProperties.pop();
                     if(_loc6_)
                     {
                        _firstLetterWasCapital = _loc6_.firstLetterWasCapital;
                        _secondLetterWasCapital = _loc6_.secondLetterWasCapital;
                        _hasSetSecondLetterCapital = _loc6_.hasSetSecondLetterCapital;
                     }
                     else
                     {
                        _firstLetterWasCapital = false;
                        _secondLetterWasCapital = false;
                        _hasSetSecondLetterCapital = false;
                     }
                  }
                  else
                  {
                     _currWordLength = _currWordLength - 1;
                  }
                  if(_currWordLength == 1)
                  {
                     _secondLetterWasCapital = false;
                     _hasSetSecondLetterCapital = false;
                  }
                  else if(_currWordLength <= 0)
                  {
                     _firstLetterWasCapital = false;
                     _secondLetterWasCapital = false;
                     _hasSetSecondLetterCapital = false;
                  }
                  if(param1.ctrlKey)
                  {
                     _numInterrobangs = 0;
                     chatMsgText.restrict = "A-Za-z0-9!\'.,():? ";
                     _previousRestriction = null;
                  }
               }
               if(param2 != null && param1.keyCode != 16 && param1.keyCode != 8 && !param1.ctrlKey && param1.keyCode != 20 && param1.keyCode != 144 && param1.keyCode != 145 && param1.keyCode != 16777224 && param1.keyCode != 9 && param1.keyCode != 27 && (param1.keyCode < 112 || param1.keyCode > 126) && param1.keyCode != 91)
               {
                  _loc5_ = new RegExp("[" + chatMsgText.restrict + "]","g");
                  _loc3_ = param2.match(_loc5_);
                  if(_loc3_ == null || _loc3_.length == 0 || _loc3_.length != param2.length || (chatMsgText.maxChars > 0 ? chatMsgText.length >= chatMsgText.maxChars : false))
                  {
                     _loc4_ = true;
                  }
                  else
                  {
                     if(param2 == " ")
                     {
                        _writtenWordsLength.push(_currWordLength);
                        _wordCapitalizationProperties.push({
                           "firstLetterWasCapital":_firstLetterWasCapital,
                           "secondLetterWasCapital":_secondLetterWasCapital,
                           "hasSetSecondLetterCapital":_hasSetSecondLetterCapital
                        });
                        _currWordLength = 0;
                        _firstLetterWasCapital = false;
                        _secondLetterWasCapital = false;
                        _hasSetSecondLetterCapital = false;
                     }
                     else
                     {
                        if(_currWordLength == 0)
                        {
                           _firstLetterWasCapital = param2 == param2.toUpperCase();
                        }
                        else if(_currWordLength == 1)
                        {
                           if(!_firstLetterWasCapital)
                           {
                              param2 = param2.toLowerCase();
                           }
                           if(param2.match(/\w/gi).length > 0)
                           {
                              _secondLetterWasCapital = param2 == param2.toUpperCase();
                              _hasSetSecondLetterCapital = true;
                           }
                        }
                        else if(_currWordLength >= 2)
                        {
                           if(!_hasSetSecondLetterCapital)
                           {
                              if(param2.match(/\w/gi).length > 0)
                              {
                                 _secondLetterWasCapital = param2 == param2.toUpperCase();
                                 _hasSetSecondLetterCapital = true;
                              }
                           }
                           if(_secondLetterWasCapital)
                           {
                              param2 = param2.toUpperCase();
                           }
                           else
                           {
                              param2 = param2.toLowerCase();
                           }
                        }
                        _currWordLength = _currWordLength + 1;
                     }
                     chatMsgText.appendText(param2);
                  }
                  if(_loc4_)
                  {
                     AJAudio.playLimitedChatErrorSound();
                     chatMsgText.textColor = 16711680;
                     _textColorTimer.start();
                  }
                  else
                  {
                     _textColorTimer.reset();
                     chatMsgText.textColor = _defaultTextColor;
                  }
               }
               else
               {
                  _textColorTimer.reset();
                  chatMsgText.textColor = _defaultTextColor;
               }
               chatMsgText.setSelection(chatMsgText.length,chatMsgText.length);
               _keyboardEvent = null;
               return;
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.onKeyDown(param1,param2);
            }
         }
         _keyboardEvent = null;
      }
      
      private function onColorTimerComplete(param1:TimerEvent) : void
      {
         if(_textColorTimer.currentCount == _textColorTimer.repeatCount)
         {
            _textColorTimer.reset();
            chatMsgText.textColor = _defaultTextColor;
         }
         else if(_textColorTimer.currentCount % 2 == 0)
         {
            chatMsgText.textColor = 16711680;
         }
         else
         {
            chatMsgText.textColor = _defaultTextColor;
         }
      }
      
      private function sendChatBtnDownHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            if(LocalizationManager.accountLanguage != LocalizationManager.currentLanguage)
            {
               onEscapeFlagDown(null);
            }
            else
            {
               FeedbackManager.openFeedbackPopup(19);
            }
         }
      }
      
      private function onChatRepeatBtn(param1:MouseEvent) : void
      {
         if(param1 == null || !param1.currentTarget.isGray)
         {
            if(param1 != null && _chatRepeatWindow.visible)
            {
               _chatRepeatWindow.visible = false;
               return;
            }
            if(param1 == null && !_chatRepeatWindow.visible)
            {
               return;
            }
            _chatRepeatWindow.visible = true;
            if(chatHistory.visible)
            {
               closeChat();
            }
            if(_repeatChatWindows)
            {
               _repeatChatWindows.destroy();
               _repeatChatWindows = null;
            }
            while(_chatRepeatWindow.itemWindow.numChildren > 1)
            {
               _chatRepeatWindow.itemWindow.removeChildAt(1);
            }
            _repeatChatWindows = new WindowGenerator();
            _repeatChatWindows.init(1,_chatRepeatArray.length,_chatRepeatArray.length,0,0,0,ItemWindowTextNode,_chatRepeatArray,"",{
               "mouseDown":onRepeatChatSelected,
               "mouseOver":null,
               "mouseOut":null
            },null,onRepeatWindoesLoaded);
            _chatRepeatWindow.itemWindow.addChild(_repeatChatWindows);
         }
      }
      
      private function onRepeatWindoesLoaded(param1:Boolean = false) : void
      {
         if(_chatRepeatWindow)
         {
            _chatRepeatWindow.m.height = param1 ? 33 : Math.round(_repeatChatWindows.height);
            _chatRepeatWindow.m.width = _chatRepeatWindow.t.width = _chatRepeatWindow.b.width = param1 ? 268 : _repeatChatWindows.width + 2;
            _chatRepeatWindow.m.y = _chatRepeatWindow.b.y - _chatRepeatWindow.m.height;
            _chatRepeatWindow.t.y = _chatRepeatWindow.m.y - _chatRepeatWindow.t.height;
            _chatRepeatWindow.itemWindow.x = _chatRepeatWindow.m.x;
            _chatRepeatWindow.itemWindow.y = _chatRepeatWindow.m.y;
         }
      }
      
      private function onRepeatChatSelected(param1:MouseEvent) : void
      {
         if(!AvatarManager.playerAvatarWorldView.isSameMessage(param1.currentTarget.text))
         {
            sendMsgCallback(null,param1.currentTarget.text);
            SBTracker.trackPageview("/game/play/popup/repeatChat/#repeat",-1,1);
         }
         else
         {
            SBTracker.trackPageview("/game/play/popup/repeatChat/#repeatDeny",-1,1);
         }
         closeChatRepeatWindow();
      }
   }
}

