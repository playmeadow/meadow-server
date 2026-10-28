package playerWall
{
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.setTimeout;
   import gui.*;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PlayerWallGui
   {
      
      private static var _scrollYPosition:Number = 0;
      
      private const PLAYER_WALL_MEDIA_ID:int = 1499;
      
      private const AVATAR_ICON_LIST_ID:int = 109;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inbox:Array;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _playerWall:MovieClip;
      
      private var _owner:String;
      
      private var _status:String;
      
      private var _currPatternId:int;
      
      private var _myCurrColor:String;
      
      private var _ownerCurrColor:String;
      
      private var _ownerIconId:int;
      
      private var _myIconId:int;
      
      private var _postWindows:WindowGenerator;
      
      private var _postScrollBar:SBScrollbar;
      
      private var _avatarWindows:WindowGenerator;
      
      private var _avatarScrollBar:SBScrollbar;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _predictiveStatusManager:PredictiveTextManager;
      
      private var _emoteMgr:EmoticonManager;
      
      private var _reportMsgId:String;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _isMyWall:Boolean;
      
      private var _currSentMessageText:String;
      
      private var _newWallSettingsDropDown:GuiDropdown;
      
      private var _privacyId:int;
      
      private var _msgCode:String;
      
      private var _hasConnected:Boolean;
      
      private var _mediaHelperHolder:Array;
      
      private var _avatarIconWindowLoadingSpiral:LoadingSpiral;
      
      private var _numAvatarIconsLoaded:int;
      
      private var _avatarIcons:Array;
      
      public function PlayerWallGui()
      {
         super();
      }
      
      public function init(param1:Array, param2:String, param3:String, param4:int, param5:int, param6:String, param7:String, param8:int, param9:int, param10:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._guiLayer = GuiManager.guiLayer;
         this._inbox = param1;
         this._owner = param2;
         this._status = param3;
         this._privacyId = param4;
         this._currPatternId = param5;
         this._myCurrColor = param7;
         this._ownerCurrColor = param6;
         this._ownerIconId = param8;
         this._myIconId = param9;
         this._closeCallback = param10;
         this._isMyWall = param2 == gMainFrame.userInfo.myUserName;
         this._mediaHelperHolder = [];
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this.PLAYER_WALL_MEDIA_ID,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         KeepAlive.stopKATimer(this._playerWall);
         if(this._postScrollBar)
         {
            this._postScrollBar.destroy();
            this._postScrollBar = null;
         }
         if(this._postWindows)
         {
            this._postWindows.destroy();
            this._postWindows = null;
         }
         if(this._avatarScrollBar)
         {
            this._avatarScrollBar.destroy();
            this._avatarScrollBar = null;
         }
         if(this._avatarWindows)
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         this.setupSafeChat(true);
         this.setupSettingsPopup(true);
         this.setupMessageEntry(true);
         this.setupEmotePopup(true);
         this.removePatternsAndColors();
         this._mediaHelperHolder = null;
         this._mediaHelper = null;
         this._inbox = null;
         this._closeCallback = null;
         this.removeEventListeners();
         DarkenManager.unDarken(this._playerWall);
         this._guiLayer.removeChild(this._playerWall);
         this._playerWall = null;
      }
      
      public function show(param1:Boolean) : void
      {
         if(this._playerWall)
         {
            if(param1)
            {
               this.addEventListeners();
               this._guiLayer.addChild(this._playerWall);
               DarkenManager.darken(this._playerWall);
            }
            else
            {
               DarkenManager.unDarken(this._playerWall);
               this._guiLayer.removeChild(this._playerWall);
               this.removeEventListeners();
            }
         }
      }
      
      public function reloadMessages(param1:Array) : void
      {
         this.setStatusGrayState();
         if(param1)
         {
            this._inbox = param1;
            this.createWallPosts();
         }
         else
         {
            this._playerWall.contentLoader.visible = false;
         }
      }
      
      public function get myCurrMessageColor() : String
      {
         return this._myCurrColor;
      }
      
      public function get currMessagePattern() : int
      {
         return this._currPatternId;
      }
      
      public function get owner() : String
      {
         return this._owner;
      }
      
      public function get status() : String
      {
         return this._playerWall.statusTxt.text;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._playerWall = MovieClip(param1.getChildAt(0));
            KeepAlive.startKATimer(this._playerWall);
            this._playerWall.x = MainFrame.VIEW_WIDTH * 0.5;
            this._playerWall.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.patternPopup.visible = false;
            this._playerWall.colorPopup.visible = false;
            this._playerWall.emotePopup.visible = false;
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.statusTxt.text = "";
            this._playerWall.titleTxt.text = this._owner;
            this._playerWall.messageTxt.alpha = 0.5;
            this._playerWall.messageTxt.restrict = "";
            this._playerWall.statusTxt.restrict = "";
            this._playerWall.settingsPopup.visible = false;
            this._playerWall.postStatusBtn.visible = false;
            this._playerWall.predictiveText.visible = false;
            this._playerWall.messageTxt.selectable = false;
            this._playerWall.charCounter.visible = false;
            this._playerWall.messageTxt.text = "";
            if(this._isMyWall)
            {
               this._playerWall.wallOwnerIcon.visible = false;
               this._playerWall.settingsBtn.visible = true;
            }
            else
            {
               this._playerWall.editStatusIcon.visible = false;
               this._playerWall.settingsBtn.visible = false;
            }
            if(PlayerWallManager.isFirstTime || !this._isMyWall)
            {
               PlayerWallXtCommManager.sendPrivacyGetRequest(this._owner,this.onFirstTimePrivacy);
            }
            else
            {
               this._playerWall.messageEntry.gotoAndStop(this._myCurrColor);
               this._playerWall.messageEntry.pattern.gotoAndStop("pattern" + this._currPatternId);
               this._hasConnected = true;
               if(this._isMyWall)
               {
                  this.setupStatusEntry();
               }
               this.buildAvatarIcons();
               this.loadOwnerIcons();
               this.setupSafeChat();
               this.setupMessageEntry();
               this.setupPatternsAndColorsPopup();
               this.setupEmotePopup();
               this._playerWall.postStatusBtn.visible = true;
               this.setupSettingsPopup(false,this._privacyId);
               this.onWallSettingsDropDown(null);
               this.setStatusGrayState();
               this._playerWall.statusLoader.visible = false;
               this.createWallPosts();
               PlayerWallManager.startMyWallTimer();
            }
            this.addEventListeners();
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._playerWall);
            DarkenManager.darken(this._playerWall);
         }
      }
      
      private function loadOwnerIcons() : void
      {
         if(this._myIconId == 0)
         {
            PlayerWallXtCommManager.sendStatusGetRequest(gMainFrame.userInfo.myUserName,this.onMyStatusLoaded);
         }
         else
         {
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(this._ownerIconId,this.onIconLoaded,1);
            this._mediaHelperHolder.push(this._mediaHelper);
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(this._myIconId,this.onIconLoaded,2);
            this._mediaHelperHolder.push(this._mediaHelper);
         }
      }
      
      private function onIconLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            if(this._playerWall)
            {
               if(param1.passback == 1)
               {
                  param1.scaleX = 0.52;
                  param1.scaleY = 0.52;
                  while(this._playerWall.wallOwnerIcon.itemWindow.numChildren > 0)
                  {
                     this._playerWall.wallOwnerIcon.itemWindow.removeChildAt(0);
                  }
                  this._playerWall.wallOwnerIcon.itemWindow.addChild(param1);
                  this._playerWall.wallOwnerIcon.gotoAndStop(this._ownerCurrColor);
               }
               else
               {
                  param1.scaleX = 0.82;
                  param1.scaleY = 0.82;
                  while(this._playerWall.messageEntry.itemWindow.numChildren > 0)
                  {
                     this._playerWall.messageEntry.itemWindow.removeChildAt(0);
                  }
                  this._playerWall.messageEntry.itemWindow.addChild(param1);
                  this._playerWall.messageEntry.gotoAndStop(this._myCurrColor);
               }
            }
         }
      }
      
      private function updateIconColors() : void
      {
         var _loc1_:int = 0;
         if(this._isMyWall)
         {
            this._playerWall.wallOwnerIcon.gotoAndStop(this._ownerCurrColor);
            this._ownerCurrColor = this._myCurrColor;
         }
         this._playerWall.messageEntry.gotoAndStop(this._myCurrColor);
         if(this._avatarWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < this._avatarWindows.numWindowsCreated)
            {
               ItemWindowAvatarIcon(this._avatarWindows.bg.getChildAt(_loc1_)).updateColor(this._myCurrColor);
               _loc1_++;
            }
         }
      }
      
      private function buildAvatarIcons() : void
      {
         GenericListXtCommManager.requestGenericList(this.AVATAR_ICON_LIST_ID,this.onAvatarIconMediaIdsLoaded);
      }
      
      private function onAvatarIconMediaIdsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(this._playerWall)
         {
            if(this._avatarWindows)
            {
               this._avatarWindows.destroy();
               this._avatarWindows = null;
            }
            if(this._avatarWindows)
            {
               this._avatarWindows.destroy();
               this._avatarWindows = null;
            }
            if(param2.length > 0)
            {
               this._avatarIconWindowLoadingSpiral = new LoadingSpiral(this._playerWall.avatarPopup.content,this._playerWall.avatarPopup.content.height * 0.5,this._playerWall.avatarPopup.content.width * 0.5 + 60);
               this._avatarWindows = new WindowGenerator();
               this._avatarWindows.init(4,param2.length,param2.length,2,2,2,ItemWindowAvatarIcon,param2,"",{
                  "mouseDown":this.onAvatarIconDown,
                  "mouseOver":null,
                  "mouseOut":null
               },{"currColor":this._myCurrColor},this.onAvatarIconWindowsLoaded,false,false);
               this._playerWall.avatarPopup.content.addChild(this._avatarWindows);
            }
         }
      }
      
      private function onAvatarIconWindowsLoaded() : void
      {
         if(this._playerWall)
         {
            this._avatarIconWindowLoadingSpiral.visible = false;
            this._avatarScrollBar = new SBScrollbar();
            this._avatarScrollBar.init(this._avatarWindows,this._playerWall.avatarPopup.content.width,this._avatarWindows.boxHeight * 4 + 2 * 4,0,"scrollbar2",this._avatarWindows.boxHeight + 2,0);
         }
      }
      
      private function onAvatarIconDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._myIconId = param1.currentTarget.currIconId;
         if(this._isMyWall)
         {
            this._ownerIconId = this._myIconId;
         }
         this._playerWall.avatarPopup.visible = false;
         this._playerWall.avatarBtn.downToUpState();
         this.loadOwnerIcons();
      }
      
      private function setupSafeChat(param1:Boolean = false) : void
      {
         if(param1)
         {
            SafeChatManager.destroy(this._playerWall.chatTree);
         }
         else
         {
            SafeChatManager.buildSafeChatTree(this._playerWall.chatTree,"ECardTextTreeNode",SafeChatManager.TREE_ECARDTEXT,this.onChatTreeClose,null);
            SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         }
      }
      
      private function setupSettingsPopup(param1:Boolean = false, param2:int = 0) : void
      {
         var destroy:Boolean = param1;
         var privacyId:int = param2;
         with(this._playerWall.settingsPopup)
         {
            if(destroy)
            {
               removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
               bx.removeEventListener(MouseEvent.MOUSE_DOWN,onSettingsClose);
               if(_newWallSettingsDropDown)
               {
                  _newWallSettingsDropDown.dropdownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onWallSettingsDropDown);
                  _newWallSettingsDropDown = null;
               }
            }
            else
            {
               addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
               bx.addEventListener(MouseEvent.MOUSE_DOWN,onSettingsClose,false,0,true);
               _newWallSettingsDropDown = new GuiDropdown(playerwall_dropdown.dropdown);
               _newWallSettingsDropDown.init(0,privacyId);
               _newWallSettingsDropDown.dropdownBtn.addEventListener(MouseEvent.MOUSE_DOWN,onWallSettingsDropDown,false,0,true);
            }
         }
      }
      
      private function setupStatusEntry(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(this._predictiveStatusManager)
            {
               this._predictiveStatusManager.destroy();
            }
            this._playerWall.statusTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this._playerWall.statusTxt.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this._playerWall.statusTxt.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
            this._playerWall.statusTxt.removeEventListener(MouseEvent.MOUSE_OVER,this.onTextOver);
            this._playerWall.statusTxt.removeEventListener(MouseEvent.MOUSE_OUT,this.onTextOut);
         }
         else
         {
            if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE)
            {
               this._predictiveStatusManager = new PredictiveTextManager();
               this._predictiveStatusManager.init(this._playerWall.statusTxt,PredictiveTextTree.defaultRoot,PredictiveTextManager.USE_TYPE_ALL,null,null,this.onSendStatusMessage);
               this._playerWall.statusTxt.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
               this._playerWall.statusTxt.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
            }
            else
            {
               this._playerWall.statusTxt.selectable = false;
            }
            this._playerWall.statusTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
            this._playerWall.statusTxt.addEventListener(MouseEvent.MOUSE_OVER,this.onTextOver,false,0,true);
            this._playerWall.statusTxt.addEventListener(MouseEvent.MOUSE_OUT,this.onTextOut,false,0,true);
         }
      }
      
      private function setupMessageEntry(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(this._predictiveTextManager)
            {
               this._predictiveTextManager.destroy();
            }
            this._playerWall.messageTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this._playerWall.messageTxt.removeEventListener(TextEvent.TEXT_INPUT,this.handleTextInput);
            this._playerWall.messageTxt.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this._playerWall.messageTxt.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
            this._playerWall.messageTxt.removeEventListener(MouseEvent.MOUSE_OVER,this.onTextOver);
            this._playerWall.messageTxt.removeEventListener(MouseEvent.MOUSE_OUT,this.onTextOut);
         }
         else
         {
            if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE)
            {
               this._playerWall.charCounter.text = "0/" + this._playerWall.messageTxt.maxChars;
               this._playerWall.charCounter.visible = true;
               this._predictiveTextManager = new PredictiveTextManager();
               this._predictiveTextManager.init(this._playerWall.messageTxt,PredictiveTextTree.defaultRoot,PredictiveTextManager.USE_TYPE_ALL,this._playerWall.predictiveText,null,this.onSendMessage,this.checkShouldCompleteSuggestion);
               this._playerWall.messageTxt.addEventListener(TextEvent.TEXT_INPUT,this.handleTextInput,false,0,true);
               this._playerWall.messageTxt.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
               this._playerWall.messageTxt.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
            }
            this._playerWall.messageTxt.selectable = true;
            this._playerWall.messageTxt.text = "Type your message here...";
            this._playerWall.messageTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
            this._playerWall.messageTxt.addEventListener(MouseEvent.MOUSE_OVER,this.onTextOver,false,0,true);
            this._playerWall.messageTxt.addEventListener(MouseEvent.MOUSE_OUT,this.onTextOut,false,0,true);
         }
      }
      
      private function setupPatternsAndColorsPopup(param1:Boolean = false) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Boolean = true;
         var _loc4_:int = 1;
         while(_loc3_)
         {
            _loc2_ = this._playerWall.patternPopup["patternBtn" + _loc4_];
            if(_loc2_)
            {
               _loc2_.gotoAndStop(this._myCurrColor);
               _loc2_.pattern.gotoAndStop("pattern" + _loc4_);
               _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelectPattern,false,0,true);
            }
            _loc2_ = this._playerWall.colorPopup["colorBtn" + _loc4_];
            if(_loc2_)
            {
               _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelectColor,false,0,true);
               _loc2_.gotoAndStop(_loc4_);
            }
            if(!_loc2_)
            {
               _loc3_ = false;
            }
            _loc4_++;
         }
      }
      
      private function removePatternsAndColors() : void
      {
         var _loc1_:MovieClip = null;
         var _loc2_:Boolean = true;
         var _loc3_:int = 1;
         while(_loc2_)
         {
            _loc1_ = this._playerWall.patternPopup["patternBtn" + _loc3_];
            if(_loc1_)
            {
               _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSelectPattern);
            }
            _loc1_ = this._playerWall.colorPopup["colorBtn" + _loc3_];
            if(_loc1_)
            {
               _loc1_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSelectColor);
            }
            if(!_loc1_)
            {
               _loc2_ = false;
            }
            _loc3_++;
         }
      }
      
      private function setupEmotePopup(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(this._emoteMgr)
            {
               this._emoteMgr.destroy();
            }
         }
         else
         {
            this._emoteMgr = new EmoticonManager(this.onEmoteDown,this._playerWall.emoteBtn,this._playerWall.emotePopup,null,null,null,null,false);
         }
      }
      
      private function createWallPosts() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._playerWall)
         {
            if(this._postScrollBar)
            {
               _scrollYPosition = this._postScrollBar.scrollYValue;
               this._postScrollBar.destroy();
               this._postScrollBar = null;
            }
            if(this._postWindows)
            {
               this._postWindows.destroy();
               this._postWindows = null;
            }
            if(!this._isMyWall)
            {
               _loc1_ = PlayerWallManager.reportedMessageIds;
               _loc2_ = 0;
               while(_loc2_ < _loc1_.length)
               {
                  _loc3_ = 0;
                  while(_loc3_ < this._inbox.length)
                  {
                     if(this._inbox[_loc3_].msgId == _loc1_[_loc2_])
                     {
                        this._inbox.splice(_loc3_,1);
                        break;
                     }
                     _loc3_++;
                  }
                  _loc2_++;
               }
            }
            if(this._inbox.length > 0)
            {
               this._playerWall.contentLoader.visible = true;
               this._postWindows = new WindowGenerator();
               this._postWindows.init(1,this._inbox.length,this._inbox.length,0,12,2,ItemWindowPost,this._inbox,"",{
                  "mouseDown":null,
                  "mouseOver":null,
                  "mouseOut":null
               },{
                  "reportMsgBtnMouseDown":this.onReportDown,
                  "deleteMsgBtnMouseDown":this.onDeleteDown,
                  "isMyPost":this._isMyWall
               },this.onWindowsLoaded,false,false);
               this._playerWall.itemHolder.addChild(this._postWindows);
            }
            else
            {
               this._playerWall.contentLoader.visible = false;
            }
         }
      }
      
      private function onWindowsLoaded() : void
      {
         if(this._playerWall)
         {
            this._playerWall.contentLoader.visible = false;
            this._postScrollBar = new SBScrollbar();
            this._postScrollBar.init(this._postWindows,this._playerWall.itemHolder.width,this._postWindows.boxHeight * 4 + 12 * 4,-31,"scrollbar2",this._postWindows.boxHeight + 12,_scrollYPosition,this._postWindows.boxHeight * this._inbox.length + 12 * this._inbox.length);
         }
      }
      
      private function closeAllLowerPopups() : void
      {
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         this._emoteMgr.closeEmotes();
         if(this._playerWall.colorPopup.visible)
         {
            this._playerWall.colorPopup.visible = false;
            this._playerWall.colorBtn.downToUpState();
         }
         if(this._playerWall.patternPopup.visible)
         {
            this._playerWall.patternPopup.visible = false;
            this._playerWall.patternBtn.downToUpState();
         }
         if(this._playerWall.avatarPopup.visible)
         {
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.avatarBtn.downToUpState();
         }
      }
      
      private function onSelectPattern(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._currPatternId = param1.currentTarget.pattern.currentFrameLabel.replace("pattern","");
         this._playerWall.messageEntry.pattern.gotoAndStop("pattern" + this._currPatternId);
         GuiManager.setSharedObj("msgPattern",this._currPatternId);
         this._playerWall.patternPopup.visible = false;
         this._playerWall.patternBtn.downToUpState();
      }
      
      private function onSelectColor(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._myCurrColor = param1.currentTarget.currentFrameLabel;
         GuiManager.setSharedObj("msgColor",this._myCurrColor);
         this._playerWall.messageEntry.gotoAndStop(this._myCurrColor);
         this._playerWall.colorPopup.visible = false;
         this._playerWall.colorBtn.downToUpState();
         this.updateIconColors();
      }
      
      private function onReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._reportMsgId = param1.currentTarget.parent.parent.msgId;
         this._reportAPlayer = new ReportAPlayer();
         this._reportAPlayer.init(this._guiLayer,this.onPostReport,true,param1.currentTarget.parent.nameTxt.text);
      }
      
      private function onPostReport(param1:Boolean) : void
      {
         if(this._reportAPlayer)
         {
            this._reportAPlayer.destroy();
            this._reportAPlayer = null;
         }
         if(param1 && this._reportMsgId != "")
         {
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.postStatusBtn.activateGrayState(true);
            this._playerWall.contentLoader.visible = true;
            KeepAlive.restartTimeLeftTimer();
            if(this._isMyWall)
            {
               PlayerWallXtCommManager.sendPostDeleteRequest(this._owner + "\n" + this._reportMsgId,PlayerWallManager.onDeleteResponse);
            }
            else
            {
               PlayerWallManager.onStrangerReport(this._reportMsgId);
            }
            this._reportMsgId = "";
         }
      }
      
      private function setStatusGrayState() : void
      {
         if(this._predictiveStatusManager)
         {
            if(this._playerWall.statusTxt.text != this._status && this._playerWall.statusTxt.text.length > 0 && !PlayerWallXtCommManager.isSocketOpen())
            {
               this._playerWall.postStatusBtn.activateGrayState(!this._predictiveStatusManager.isWordValid());
            }
            else
            {
               this._playerWall.postStatusBtn.activateGrayState(true);
            }
         }
         else
         {
            this._playerWall.postStatusBtn.activateGrayState(true);
         }
      }
      
      private function onDeleteDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(this._guiLayer,"Are you sure you want to delete this post?",true,this.deleteMessageConfirmCallback,param1.currentTarget.parent.parent.msgId);
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(param1.status)
         {
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.postStatusBtn.activateGrayState(true);
            this._playerWall.contentLoader.visible = true;
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendPostDeleteRequest(this._owner + "\n" + param1.passback,PlayerWallManager.onDeleteResponse);
         }
      }
      
      public function onDeleteResponse(param1:String, param2:Boolean) : void
      {
         var _loc3_:PostMessage = null;
         var _loc4_:int = 0;
         if(this._playerWall)
         {
            this._playerWall.contentLoader.visible = false;
            this._playerWall.postBtn.activateGrayState(false);
            this.setStatusGrayState();
            if(param2)
            {
               _loc4_ = 0;
               while(_loc4_ < this._inbox.length)
               {
                  _loc3_ = this._inbox[_loc4_];
                  if(_loc3_ != null && _loc3_.msgId == param1)
                  {
                     this._inbox.splice(_loc4_,1);
                     break;
                  }
                  _loc4_++;
               }
               this.createWallPosts();
            }
            else
            {
               new SBOkPopup(this._guiLayer,"Couldn\'t delete this post please try again.");
            }
         }
      }
      
      private function onAvatarBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._playerWall.colorPopup.visible)
         {
            this._playerWall.colorPopup.visible = false;
            this._playerWall.colorBtn.downToUpState();
         }
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         this._emoteMgr.closeEmotes();
         if(this._playerWall.patternPopup.visible)
         {
            this._playerWall.patternPopup.visible = false;
            this._playerWall.patternBtn.downToUpState();
         }
         if(this._playerWall.avatarPopup.visible)
         {
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.avatarBtn.downToUpState();
         }
         else
         {
            this._playerWall.avatarPopup.visible = true;
         }
      }
      
      private function onPatternBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._playerWall.colorPopup.visible)
         {
            this._playerWall.colorPopup.visible = false;
            this._playerWall.colorBtn.downToUpState();
         }
         if(this._playerWall.avatarPopup.visible)
         {
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.avatarBtn.downToUpState();
         }
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         this._emoteMgr.closeEmotes();
         if(this._playerWall.patternPopup.visible)
         {
            this._playerWall.patternPopup.visible = false;
            this._playerWall.patternBtn.downToUpState();
         }
         else
         {
            this._playerWall.patternPopup.visible = true;
         }
      }
      
      private function onColorBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._playerWall.patternPopup.visible)
         {
            this._playerWall.patternPopup.visible = false;
            this._playerWall.patternBtn.downToUpState();
         }
         if(this._playerWall.avatarPopup.visible)
         {
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.avatarBtn.downToUpState();
         }
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         this._emoteMgr.closeEmotes();
         if(this._playerWall.colorPopup.visible)
         {
            this._playerWall.colorPopup.visible = false;
            this._playerWall.colorBtn.downToUpState();
         }
         else
         {
            this._playerWall.colorPopup.visible = true;
         }
      }
      
      private function onEmoteBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         if(this._playerWall.patternPopup.visible)
         {
            this._playerWall.patternPopup.visible = false;
            this._playerWall.patternBtn.downToUpState();
         }
         if(this._playerWall.avatarPopup.visible)
         {
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.avatarBtn.downToUpState();
         }
         if(this._playerWall.colorPopup.visible)
         {
            this._playerWall.colorPopup.visible = false;
            this._playerWall.colorBtn.downToUpState();
         }
      }
      
      private function onSafeChatBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._emoteMgr.closeEmotes();
         if(this._playerWall.patternPopup.visible)
         {
            this._playerWall.patternPopup.visible = false;
            this._playerWall.patternBtn.downToUpState();
         }
         if(this._playerWall.avatarPopup.visible)
         {
            this._playerWall.avatarPopup.visible = false;
            this._playerWall.avatarBtn.downToUpState();
         }
         if(this._playerWall.colorPopup.visible)
         {
            this._playerWall.colorPopup.visible = false;
            this._playerWall.colorBtn.downToUpState();
         }
         if(!this._playerWall.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,this._playerWall.chatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(this._playerWall.chatTree);
         }
      }
      
      private function onEmoteDown(param1:Sprite) : void
      {
         if(this._playerWall.messageTxt.alpha == 0.5)
         {
            if(!PlayerWallXtCommManager.isSocketOpen())
            {
               this._playerWall.postBtn.activateGrayState(false);
            }
            this._playerWall.messageTxt.alpha = 1;
            this._predictiveTextManager.resetTreeSearch();
         }
         var _loc2_:String = EmoticonUtility.getEmoteString(param1);
         setTimeout(this.updateCharCount,1000 / 24);
         gMainFrame.stage.focus = this._playerWall.messageTxt;
      }
      
      private function onPostBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == this._playerWall.postStatusBtn)
         {
            this.onSendStatusMessage();
         }
         else if(this._predictiveTextManager)
         {
            this._predictiveTextManager.onSendBtnDown(null);
         }
         else
         {
            this.onSendMessage(param1);
         }
      }
      
      private function onSettingsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._playerWall.settingsPopup.visible = !this._playerWall.settingsPopup.visible;
         this.closeAllLowerPopups();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onSendStatusMessage() : void
      {
         if(!this._playerWall.postStatusBtn.isGray)
         {
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.postStatusBtn.activateGrayState(true);
            this._playerWall.postStatusBtn.visible = false;
            this._playerWall.statusLoader.visible = true;
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendStatusSetRequest(this._owner + "\n" + this._playerWall.statusTxt.text,this.onStatusSet);
         }
      }
      
      private function onSendMessage(param1:MouseEvent) : void
      {
         if(!this._playerWall.postBtn.isGray)
         {
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.postStatusBtn.activateGrayState(true);
            this._playerWall.contentLoader.visible = true;
            this._currSentMessageText = this._playerWall.messageTxt.text;
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendPostAddRequest(this._owner + "\n" + gMainFrame.userInfo.myUserName + "\n" + this._playerWall.messageTxt.text + "\n" + this._currPatternId + "\n" + this._myCurrColor,this.onMessageSent);
            this._playerWall.charCounter.text = "0/" + this._playerWall.messageTxt.maxChars;
            if(this._predictiveTextManager == null)
            {
               this._playerWall.messageTxt.text = "";
            }
         }
      }
      
      private function onMessageSent(param1:Boolean, param2:String, param3:Number, param4:int) : void
      {
         var _loc5_:PostMessage = null;
         if(this._playerWall)
         {
            if(param1)
            {
               _loc5_ = new PostMessage(param2,this._currSentMessageText,gMainFrame.userInfo.myUserName,1512,this._currPatternId,this._myCurrColor,param3,false);
               this._currSentMessageText = "";
               PlayerWallManager.processMessagePush(_loc5_);
            }
            else
            {
               if(param4 > 1)
               {
                  new SBOkPopup(this._guiLayer,"Message failed to add due to filter");
               }
               else if(param4 == -1)
               {
                  new SBOkPopup(this._guiLayer,"Cleanspeak failed to work properly");
               }
               else
               {
                  new SBOkPopup(this._guiLayer,"Message could not be sent");
               }
               this._playerWall.contentLoader.visible = false;
               this.setStatusGrayState();
               this._playerWall.postBtn.activateGrayState(false);
            }
            if(this._predictiveTextManager)
            {
               this._predictiveTextManager.resetTreeSearch();
            }
         }
      }
      
      private function onStatusSet(param1:Boolean, param2:int) : void
      {
         if(this._playerWall)
         {
            this._playerWall.statusLoader.visible = false;
            if(!param1)
            {
               if(param2 > 1)
               {
                  new SBOkPopup(this._guiLayer,"Status failed to add due to filter");
               }
               else if(param2 == -1)
               {
                  new SBOkPopup(this._guiLayer,"Cleanspeak failed to work properly");
               }
               else
               {
                  new SBOkPopup(this._guiLayer,"Problem setting your status");
               }
               this._predictiveStatusManager.resetTreeSearch();
            }
            else
            {
               this._status = this._playerWall.statusTxt.text;
            }
         }
      }
      
      private function onFirstTimePrivacy(param1:Boolean, param2:int) : void
      {
         if(this._playerWall)
         {
            if(param1)
            {
               this._privacyId = param2;
               this.setupSettingsPopup(false,param2);
               this.onWallSettingsDropDown(null);
            }
            else
            {
               new SBOkPopup(this._guiLayer,"Problem getting Privacy settings");
            }
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendStatusGetRequest(this._owner,this.onFirstTimeStatus);
         }
      }
      
      private function onFirstTimeStatus(param1:Boolean, param2:String, param3:int, param4:String) : void
      {
         if(this._playerWall)
         {
            this._playerWall.statusLoader.visible = false;
            if(param1)
            {
               this._status = param2;
               this._ownerIconId = param3;
               if(this._isMyWall)
               {
                  this._myIconId = param3;
                  this._myCurrColor = param4;
               }
               this._ownerCurrColor = param4;
               this.loadOwnerIcons();
               if(this._isMyWall)
               {
                  this._playerWall.postStatusBtn.visible = true;
                  this.setStatusGrayState();
               }
            }
            else
            {
               new SBOkPopup(this._guiLayer,"Problem getting status");
            }
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendPostGetRequest(this._owner,this.onFirstTimeGet);
         }
      }
      
      private function onFirstTimeGet(param1:Boolean, param2:Array) : void
      {
         if(param1)
         {
            this._hasConnected = true;
            this.buildAvatarIcons();
            this.addEventListeners();
            if(this._isMyWall)
            {
               this.setupStatusEntry();
            }
            this.setupSafeChat();
            this.setupMessageEntry();
            this.setupPatternsAndColorsPopup();
            this.setupEmotePopup();
         }
      }
      
      private function onPrivacySetResponse(param1:Boolean, param2:int) : void
      {
         if(this._playerWall)
         {
            if(param1)
            {
               this._privacyId = param2;
            }
            else
            {
               new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14774));
            }
         }
      }
      
      private function onMyStatusLoaded(param1:Boolean, param2:String, param3:int, param4:String) : void
      {
         if(param1)
         {
            this._myCurrColor = param4;
            this._myIconId = param3;
            this.loadOwnerIcons();
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
            if(param3 != null)
            {
               param3(param1,true);
               return;
            }
         }
         var _loc4_:TextField = new TextField();
         var _loc5_:TextFormat = this._playerWall.messageTxt.getTextFormat();
         _loc4_.text = this._playerWall.messageTxt.text + param1;
         _loc4_.setTextFormat(_loc5_);
         if(_loc4_.length > this._playerWall.messageTxt.maxChars)
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
      
      private function handleTextInput(param1:TextEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(param1.currentTarget == this._playerWall.statusTxt)
         {
            if(this._predictiveStatusManager)
            {
               if(param1.keyCode == 13)
               {
                  if(this._playerWall.statusTxt.text != this._status && this._playerWall.statusTxt.text != "" && !this._playerWall.postStatusBtn.isGray)
                  {
                     AJAudio.playTextEnter();
                     this.onSendStatusMessage();
                  }
                  return;
               }
               AJAudio.playTextType();
            }
         }
         else if(this._predictiveTextManager)
         {
            if(param1.keyCode == 13)
            {
               if(this._playerWall.messageTxt.alpha != 0.5 && this._playerWall.messageTxt.text != "" && !this._playerWall.postBtn.isGray)
               {
                  AJAudio.playTextEnter();
                  if(this._predictiveTextManager)
                  {
                     this._predictiveTextManager.onSendBtnDown(null);
                  }
               }
               return;
            }
            AJAudio.playTextType();
            setTimeout(this.updateCharCount,1000 / 24);
         }
         else if(!this._playerWall.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,this._playerWall.chatTree);
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14713));
         }
      }
      
      private function keyUpListener(param1:KeyboardEvent) : void
      {
         if(param1.currentTarget == this._playerWall.statusTxt)
         {
            if(this._predictiveStatusManager)
            {
               this._predictiveStatusManager.onKeyUp(param1);
            }
            this.setStatusGrayState();
            if(param1.keyCode == 13)
            {
               this._playerWall.statusTxt.setSelection(this._playerWall.statusTxt.length,this._playerWall.statusTxt.length);
            }
         }
         else
         {
            if(this._predictiveTextManager)
            {
               this._predictiveTextManager.onKeyUp(param1);
            }
            if(this._playerWall.messageTxt.length > 0 && !PlayerWallXtCommManager.isSocketOpen())
            {
               this._playerWall.postBtn.activateGrayState(!this._predictiveTextManager.isWordValid());
            }
            else
            {
               this._playerWall.postBtn.activateGrayState(true);
            }
            if(param1.keyCode == 13)
            {
               this._playerWall.messageTxt.setSelection(this._playerWall.messageTxt.length,this._playerWall.messageTxt.length);
            }
         }
      }
      
      private function updateCharCount() : void
      {
         this._playerWall.charCounter.visible = true;
         this._playerWall.charCounter.text = this._playerWall.messageTxt.text.length + "/" + this._playerWall.messageTxt.maxChars;
      }
      
      private function onSettingsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._newWallSettingsDropDown.selectedIdx != this._privacyId)
         {
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendPrivacySetRequest(this._owner + "\n" + this._newWallSettingsDropDown.selectedIdx,this.onPrivacySetResponse);
         }
         this.onSettingsBtn(param1);
      }
      
      private function onWallSettingsDropDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._newWallSettingsDropDown.selectedIdx == 0)
         {
            this._playerWall.settingsPopup.message.messageTxt.text = "Your Wall is set to EVERYONE. Everyone in Jamaa can read and post to your Wall.";
            this._playerWall.settingsPopup.playerwall_dropdown.lockedIcon.visible = false;
            this._playerWall.settingsPopup.playerwall_dropdown.unlockedIcon.visible = true;
         }
         else
         {
            if(this._newWallSettingsDropDown.selectedIdx == 1)
            {
               this._playerWall.settingsPopup.message.messageTxt.text = "Your Wall is set to BUDDIES. Only your buddies can read and post to your Wall.";
            }
            else if(this._newWallSettingsDropDown.selectedIdx == 2)
            {
               this._playerWall.settingsPopup.message.messageTxt.text = "Your Wall is set to PRIVATE. Only you can read and post to your Wall.";
            }
            this._playerWall.settingsPopup.playerwall_dropdown.lockedIcon.visible = true;
            this._playerWall.settingsPopup.playerwall_dropdown.unlockedIcon.visible = false;
         }
      }
      
      private function onChatTreeClose(param1:String, param2:String) : void
      {
         if(this._predictiveTextManager)
         {
            this._predictiveTextManager.resetTreeSearch();
         }
         this._playerWall.messageTxt.alpha = 1;
         this._playerWall.charCounter.visible = false;
         this._playerWall.charCounter.text = "0/" + this._playerWall.messageTxt.maxChars;
         this._playerWall.messageTxt.text = param1;
         this._msgCode = param2;
         if(!PlayerWallXtCommManager.isSocketOpen())
         {
            this._playerWall.postBtn.activateGrayState(false);
         }
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget == this._playerWall.statusTxt)
         {
            this._playerWall.statusTxt.setSelection(this._playerWall.statusTxt.length,this._playerWall.statusTxt.length);
            this._playerWall.postStatusBtn.visible = true;
            this.setStatusGrayState();
         }
         else
         {
            if(this._playerWall.messageTxt.text == "Type your message here...")
            {
               this._playerWall.messageTxt.alpha = 1;
               this._predictiveTextManager.resetTreeSearch();
            }
            this.closeAllLowerPopups();
         }
      }
      
      private function onTextOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         CursorManager.showICursor(true);
      }
      
      private function onTextOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         CursorManager.showICursor(false);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onKeyFocusChange(param1:FocusEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
         this._playerWall.messageTxt.setSelection(this._playerWall.messageTxt.length,this._playerWall.messageTxt.length);
      }
      
      private function addEventListeners() : void
      {
         if(this._playerWall)
         {
            this._playerWall.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._playerWall.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
            if(this._hasConnected)
            {
               this._playerWall.avatarBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAvatarBtn,false,0,true);
               this._playerWall.patternBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPatternBtn,false,0,true);
               this._playerWall.colorBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtn,false,0,true);
               this._playerWall.emoteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onEmoteBtn,false,0,true);
               this._playerWall.postBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPostBtn,false,0,true);
               this._playerWall.postStatusBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPostBtn,false,0,true);
               this._playerWall.settingsBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSettingsBtn,false,0,true);
               this._playerWall.messageTxt.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange,false,0,true);
               this._playerWall.speedChatBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSafeChatBtn,false,0,true);
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         if(this._playerWall)
         {
            this._playerWall.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._playerWall.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
            if(this._hasConnected)
            {
               this._playerWall.avatarBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAvatarBtn);
               this._playerWall.patternBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPatternBtn);
               this._playerWall.colorBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtn);
               this._playerWall.emoteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onEmoteBtn);
               this._playerWall.postBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPostBtn);
               this._playerWall.postStatusBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPostBtn);
               this._playerWall.settingsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSettingsBtn);
               this._playerWall.messageTxt.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange);
               this._playerWall.speedChatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSafeChatBtn);
            }
         }
      }
   }
}

