package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   
   public class ChatHistory
   {
      
      public static const SG_CHAT_TYPE_BUBBLE:int = 0;
      
      public static const SG_CHAT_TYPE_FREE:int = 1;
      
      public static const SG_CHAT_TYPE_PREDICTIVE:int = 2;
      
      public static const SG_CHAT_TYPE_RESTR_BUBBLE:int = 3;
      
      private const CHAT_DIM_ALPHA:Number = 0.5;
      
      private const CHAT_BRIGHT_ALPHA:Number = 1;
      
      private var _keyListenersActive:Boolean;
      
      private var _enableFreeChat:Boolean = true;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _predictiveText:MovieClip;
      
      private var _chatText:TextField;
      
      private var _chatBarContainer:MovieClip;
      
      public var chatHistory:MovieClip;
      
      public var chatUpDown:MovieClip;
      
      public var chatMsgText:TextField;
      
      public var chatSendBtn:MovieClip;
      
      public var sendMsgCallback:Function;
      
      public function ChatHistory(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:Function, param8:MovieClip)
      {
         super();
         if(this.chatHistory)
         {
            throw new Error("ERROR: Singleton ChatHistory did not expect to be created twice!");
         }
         this._keyListenersActive = true;
         this.chatHistory = param1;
         this._predictiveText = param8;
         this._chatBarContainer = param2;
         this.chatHistory.visible = true;
         this.chatHistory.gotoAndStop(1);
         this.chatHistory.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         this.chatUpDown = param3;
         this.chatUpDown.gotoAndStop(1);
         this.chatUpDown["up"].mouse.gotoAndStop(1);
         this.chatUpDown.addEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler,false,0,true);
         param4.glow.visible = false;
         this.chatMsgText = param5;
         this.toggleInGameHud(false);
         this.chatMsgText.text = "";
         if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_RESTR_BUBBLE)
         {
            this.chatMsgText.restrict = "";
         }
         param8.visible = false;
         this._chatText = this.chatHistory.chatHistoryBG.text01_chatHistory;
         this.chatSendBtn = param6;
         this.sendMsgCallback = param7;
         this._chatText.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
         this.chatMsgText.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText,false,0,true);
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText,false,0,true);
         }
         this.chatSendBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sendChatBtnDownHandler,false,0,true);
         this.resetChatPrivs();
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:TextField, param6:MovieClip, param7:MovieClip) : void
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
            if(Mouse["supportsNativeCursor"])
            {
               this.chatMsgText.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText);
               this.chatMsgText.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText);
            }
         }
         this.chatHistory = param1;
         this._predictiveText = param7;
         this._chatBarContainer = param2;
         this.chatHistory.visible = true;
         this.chatHistory.gotoAndStop(1);
         this.chatHistory.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         this.chatUpDown = param3;
         this.chatUpDown.gotoAndStop(1);
         this.chatUpDown["up"].mouse.gotoAndStop(1);
         this.chatUpDown.addEventListener(MouseEvent.MOUSE_DOWN,this.openCloseHandler,false,0,true);
         this.chatMsgText = param5;
         this.toggleInGameHud(false);
         this.chatMsgText.text = "";
         if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_RESTR_BUBBLE)
         {
            this.chatMsgText.restrict = "";
         }
         param7.visible = false;
         this.resetChatPrivs();
         this._chatText = this.chatHistory.chatHistoryBG.text01_chatHistory;
         this._chatText.addEventListener(MouseEvent.MOUSE_DOWN,this.chatClickHandler,false,0,true);
         this.chatSendBtn = param6;
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
         this.chatMsgText.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
         this.chatMsgText.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
         if(Mouse["supportsNativeCursor"])
         {
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOverMsgText,false,0,true);
            this.chatMsgText.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOutMsgText,false,0,true);
         }
         this.chatSendBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sendChatBtnDownHandler,false,0,true);
         this.clearChat();
      }
      
      public function resetChatPrivs(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         if(Utility.canChat())
         {
            _loc2_ = int(gMainFrame.userInfo.sgChatType);
            if(_loc2_ == SG_CHAT_TYPE_FREE)
            {
               this.enableFreeChat(true);
            }
            else if(_loc2_ == SG_CHAT_TYPE_PREDICTIVE)
            {
               if(param1 && Boolean(this._predictiveTextManager))
               {
                  this._predictiveTextManager.reload(this.chatMsgText,this._predictiveText,this._chatBarContainer);
               }
               else
               {
                  this._predictiveTextManager = new PredictiveTextManager();
                  this._predictiveTextManager.init(this.chatMsgText,PredictiveTextTree.defaultRoot,PredictiveTextManager.USE_TYPE_ALL,this._predictiveText,this._chatBarContainer,this.sendMsgCallback);
               }
               this._chatText.selectable = true;
               this.chatMsgText.selectable = true;
               this._enableFreeChat = true;
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
      
      public function showChatInput(param1:Boolean) : void
      {
         this.chatUpDown.visible = param1;
         this.chatMsgText.visible = param1;
         this.chatSendBtn.visible = param1;
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
                  this.addMessage(_loc5_.avName,param2);
               }
            }
         }
      }
      
      public function addMessage(param1:String, param2:String) : void
      {
         var _loc3_:String = null;
         this._chatText.appendText(param1 + ": " + param2 + "\n");
         while(this._chatText.numLines >= 100)
         {
            _loc3_ = this._chatText.text;
            this._chatText.text = _loc3_.substr(_loc3_.indexOf("\r") + 1);
         }
         this._chatText.scrollV = this._chatText.maxScrollV;
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
         if(this._chatText.length == 0)
         {
            this._chatText.setTextFormat(_loc5_);
         }
         else
         {
            this._chatText.setTextFormat(_loc5_,this._chatText.length - 1,this._chatText.length);
         }
         if(param1 == gMainFrame.server.userName)
         {
            this._chatText.appendText(param1 + " to " + param2 + ": " + param3 + "\n");
         }
         else
         {
            this._chatText.appendText(param1 + " to " + param2 + ": " + param3 + "\n");
         }
         this._chatText.setTextFormat(_loc4_,this._chatText.length - 1,this._chatText.length);
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
         this._chatText.scrollV = 0;
      }
      
      public function openChat() : void
      {
         if(this.chatHistory.currentFrameLabel != "open")
         {
            this.chatUpDown.gotoAndStop("down");
            this.chatHistory.gotoAndPlay("open");
            this.brightenChat();
            AJAudio.playChatOpenSound();
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
         if(this.chatHistory.currentFrameLabel != "close")
         {
            this.brightenChat();
            this.chatUpDown.gotoAndStop("up");
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
         if(!param1)
         {
            this.chatMsgText.text = "";
            this.chatMsgText.restrict = "";
            this._chatText.selectable = false;
            this.chatMsgText.selectable = false;
         }
         else
         {
            this.chatMsgText.restrict = null;
            this._chatText.selectable = true;
            this.chatMsgText.selectable = true;
         }
      }
      
      public function resetTreeSearch() : void
      {
         if(this._predictiveTextManager)
         {
            this._predictiveTextManager.resetTreeSearch();
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
      
      public function addToMsgText(param1:String) : void
      {
         if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_FREE)
         {
            this.chatMsgText.appendText(param1);
         }
         else if(this._predictiveTextManager)
         {
            this._predictiveTextManager.addWordToPredictiveText(param1);
         }
      }
      
      public function setFocusOnMsgText() : void
      {
         gMainFrame.stage.focus = this.chatMsgText;
      }
      
      private function openCloseHandler(param1:MouseEvent) : void
      {
         if(this.chatHistory.currentFrameLabel == "open")
         {
            this.closeChat();
         }
         else
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
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(gMainFrame.userInfo.firstFiveMinutes > 0)
         {
            if(!(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_RESTR_BUBBLE || !Utility.canChat()))
            {
               this.chatMsgText.setSelection(this.chatMsgText.length,this.chatMsgText.length);
               return;
            }
            new SBOkPopup(GuiManager.guiLayer,"Chatting is not turned on. Have your parent use their account settings to change your chat type!");
         }
         gMainFrame.stage.focus = null;
      }
      
      private function chatClickHandler(param1:MouseEvent) : void
      {
         this.brightenChat();
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
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_PREDICTIVE)
            {
               if(this._predictiveTextManager)
               {
                  this._predictiveTextManager.onKeyUp(param1);
               }
            }
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(param1.keyCode > 36 && param1.keyCode < 41)
         {
            this.chatMsgText.setSelection(this.chatMsgText.length,this.chatMsgText.length);
            return;
         }
         if(this._enableFreeChat)
         {
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_FREE)
            {
               if(param1.keyCode != 16)
               {
                  AJAudio.playTextType();
               }
               if(param1.keyCode == 13)
               {
                  AJAudio.playTextEnter();
                  if(this.chatMsgText.text.length > 0)
                  {
                     this.sendMsgCallback(null);
                  }
               }
               return;
            }
            if(this._predictiveTextManager)
            {
               this._predictiveTextManager.onKeyDown(param1);
            }
         }
      }
      
      private function sendChatBtnDownHandler(param1:MouseEvent) : void
      {
         if(this._enableFreeChat)
         {
            if(gMainFrame.userInfo.sgChatType == SG_CHAT_TYPE_FREE)
            {
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
   }
}

