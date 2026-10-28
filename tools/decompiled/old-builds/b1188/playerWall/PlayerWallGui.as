package playerWall
{
   import avatar.Avatar;
   import avatar.AvatarManager;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import flash.utils.setTimeout;
   import gui.*;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class PlayerWallGui
   {
      
      private static var _scrollYPosition:Number = 0;
      
      private const PLAYER_WALL_MEDIA_ID:int = 1499;
      
      private const AVATAR_ICON_LIST_ID:int = 109;
      
      private const DECOR_ICONS_GENERIC_LIST_ID:int = 313;
      
      private const DECOR_ITEMS_GENERIC_LIST_ID:int = 314;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inbox:Array;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _playerWall:MovieClip;
      
      private var _owner:String;
      
      private var _status:String;
      
      private var _currPatternId:int;
      
      private var _myCurrColorId:int;
      
      private var _postWindows:WindowGenerator;
      
      private var _postScrollBar:SBScrollbar;
      
      private var _predictiveTextManager:PredictiveTextManager;
      
      private var _predictiveStatusManager:PredictiveTextManager;
      
      private var _emoteMgr:EmoticonManager;
      
      private var _reportMsgId:String;
      
      private var _reportAPlayer:ReportAPlayer;
      
      private var _isMyWall:Boolean;
      
      private var _privacyId:int;
      
      private var _msgCode:String;
      
      private var _mediaHelperHolder:Array;
      
      private var _avatarIconWindowLoadingSpiral:LoadingSpiral;
      
      private var _numAvatarIconsLoaded:int;
      
      private var _avatarIcons:Array;
      
      private var _wallSettingsRadioBtns:GuiRadioButtonGroup;
      
      private var _wallDecorWindows:WindowGenerator;
      
      private var _wallDecorIconIds:Array;
      
      private var _decorScrollBar:SBScrollbar;
      
      private var _wallDecorItemIds:Array;
      
      private var _keyboardEvent:KeyboardEvent;
      
      private var _currDecorIndex:int;
      
      private var _patternIconIds:Array;
      
      private var _patternWindows:WindowGenerator;
      
      private var _patternScrollBar:SBScrollbar;
      
      private var _messagePatternWindow:ItemWindowPattern;
      
      public function PlayerWallGui()
      {
         super();
      }
      
      public function init(param1:Array, param2:String, param3:String, param4:int, param5:int, param6:int, param7:Function) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._guiLayer = GuiManager.guiLayer;
         this._inbox = param1;
         this._owner = param2;
         this._status = param3;
         this._currPatternId = param4;
         this._myCurrColorId = param5;
         this._currDecorIndex = param6;
         this._closeCallback = param7;
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
         this.setupSafeChat(true);
         this.setupSettingsPopup(true);
         this.setupMessageEntry(true);
         this.setupEmotePopup(true);
         this.setupColors(true);
         this.setupPatterns(true);
         this.setupWallDecorPopup(true);
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
      
      public function get myCurrMessageColorId() : int
      {
         return this._myCurrColorId;
      }
      
      public function get currMessagePattern() : int
      {
         return this._currPatternId;
      }
      
      public function get currDecorIndex() : int
      {
         return this._currDecorIndex;
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
            this._playerWall.patternPopup.visible = false;
            this._playerWall.colorPopup.visible = false;
            this._playerWall.emotePopup.visible = false;
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.titleTxt.text = this._owner;
            this._playerWall.messageTxtCont.messageTxt.alpha = 0.5;
            this._playerWall.messageTxtCont.messageTxt.restrict = "";
            this._playerWall.settingsPopup.visible = false;
            this._playerWall.predictiveText.visible = false;
            this._playerWall.messageTxtCont.messageTxt.selectable = false;
            this._playerWall.messageTxtCont.charCounter.visible = false;
            this._playerWall.messageTxtCont.messageTxt.text = "";
            this._playerWall.wallDecorCont.visible = false;
            if(this._isMyWall)
            {
               this._playerWall.settingsBtn.visible = true;
               this._playerWall.wallDecorBtn.visible = true;
               this._privacyId = gMainFrame.userInfo.playerWallSettings;
            }
            else
            {
               this._playerWall.settingsBtn.visible = false;
               this._playerWall.wallDecorBtn.visible = false;
            }
            if(PlayerWallManager.isFirstTime || !this._isMyWall)
            {
               PlayerWallXtCommManager.sendGetFromPlayerWall(this._isMyWall ? gMainFrame.userInfo.myUserName : this._owner,this.onFirstTimeGet);
            }
            else
            {
               this.setupSafeChat();
               this.setupMessageEntry();
               this.setupPatterns();
               this.setupColors();
               this.setupEmotePopup();
               this.setupSettingsPopup(false,this._privacyId);
               this.setupWallDecorPopup();
               this.onSettingsChoose(null);
               this.updatePatternPopupColors();
               this.createWallPosts();
               PlayerWallManager.startMyWallTimer();
            }
            this.addEventListeners();
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._playerWall);
            DarkenManager.darken(this._playerWall);
         }
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
               if(_wallSettingsRadioBtns)
               {
                  _wallSettingsRadioBtns.currRadioButton.removeEventListener(MouseEvent.MOUSE_DOWN,onSettingsChoose);
                  _wallSettingsRadioBtns.destroy();
                  _wallSettingsRadioBtns = null;
               }
            }
            else
            {
               addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
               bx.addEventListener(MouseEvent.MOUSE_DOWN,onSettingsClose,false,0,true);
               _wallSettingsRadioBtns = new GuiRadioButtonGroup(_playerWall.settingsPopup.options);
               _wallSettingsRadioBtns.currRadioButton.addEventListener(MouseEvent.MOUSE_DOWN,onSettingsChoose,false,0,true);
               _wallSettingsRadioBtns.selected = privacyId;
            }
         }
      }
      
      private function setupWallDecorPopup(param1:Boolean = false) : void
      {
         if(param1)
         {
            this._playerWall.wallDecorCont.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._playerWall.wallDecorCont.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onWallDecorClose);
            this._wallDecorIconIds = null;
            if(this._wallDecorWindows)
            {
               this._wallDecorWindows.destroy();
               this._wallDecorWindows = null;
            }
         }
         else if(this._wallDecorIconIds == null)
         {
            this._playerWall.wallDecorBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._playerWall.wallDecorCont.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onWallDecorClose,false,0,true);
            GenericListXtCommManager.requestGenericList(this.DECOR_ICONS_GENERIC_LIST_ID,this.onDecorIconsLoaded);
         }
         else
         {
            this._wallDecorWindows = new WindowGenerator();
            this._wallDecorWindows.init(3,this._wallDecorIconIds.length,this._wallDecorIconIds.length,10,5,5,ItemWindowPlayerWallDecor,this._wallDecorIconIds,"",{
               "mouseDown":this.onDecorMouseDown,
               "mouseOver":null,
               "mouseOut":null
            },null,this.onDecorWindowsLoaded,false,false);
            this._playerWall.wallDecorCont.itemWindow.addChild(this._wallDecorWindows);
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
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(TextEvent.TEXT_INPUT,this.handleTextInput);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(Event.CHANGE,this.onTextChanged);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(KeyboardEvent.KEY_UP,this.keyUpListener);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(MouseEvent.MOUSE_OVER,this.onTextOver);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(MouseEvent.MOUSE_OUT,this.onTextOut);
            if(this._messagePatternWindow)
            {
               this._messagePatternWindow.destroy();
               this._messagePatternWindow = null;
            }
         }
         else
         {
            if(gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_FREE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_PREDICTIVE)
            {
               this._playerWall.messageTxtCont.charCounter.text = "0/" + this._playerWall.messageTxtCont.messageTxt.maxChars;
               this._playerWall.messageTxtCont.charCounter.visible = true;
               this._predictiveTextManager = new PredictiveTextManager();
               this._predictiveTextManager.init(this._playerWall.messageTxtCont.messageTxt,PredictiveTextTree.defaultRoot,PredictiveTextManager.USE_TYPE_ECARD,this._playerWall.predictiveText,null,null,this.onSendMessage,this.checkShouldCompleteSuggestion);
               if(PredictiveTextTree.defaultRoot == null)
               {
                  PredictiveTextManager.requestAndCreateTextTreeNode();
               }
               this._playerWall.messageTxtCont.messageTxt.addEventListener(TextEvent.TEXT_INPUT,this.handleTextInput,false,0,true);
               this._playerWall.messageTxtCont.messageTxt.addEventListener(Event.CHANGE,this.onTextChanged,false,0,true);
               this._playerWall.messageTxtCont.messageTxt.addEventListener(KeyboardEvent.KEY_UP,this.keyUpListener,false,0,true);
               this._playerWall.messageTxtCont.messageTxt.addEventListener(MouseEvent.MOUSE_DOWN,this.msgTextDownHandler,false,0,true);
            }
            this._playerWall.messageTxtCont.messageTxt.selectable = true;
            this._playerWall.messageTxtCont.messageTxt.text = "Type your message here...";
            this._playerWall.messageTxtCont.messageTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
            this._playerWall.messageTxtCont.messageTxt.addEventListener(MouseEvent.MOUSE_OVER,this.onTextOver,false,0,true);
            this._playerWall.messageTxtCont.messageTxt.addEventListener(MouseEvent.MOUSE_OUT,this.onTextOut,false,0,true);
            this._messagePatternWindow = new ItemWindowPattern(null,PlayerWallManager.PATTERN_MEDIA_ID,"",0,null,null,null,null,{
               "type":ItemWindowPattern.TYPE_POST,
               "colorIndex":this._myCurrColorId,
               "patternIndex":this._currPatternId
            });
            this._playerWall.messageEntryHolder.addChild(this._messagePatternWindow);
         }
      }
      
      private function setupPatterns(param1:Boolean = false) : void
      {
         if(param1)
         {
            this._patternIconIds = null;
            if(this._patternWindows)
            {
               this._patternWindows.destroy();
               this._patternWindows = null;
            }
         }
         else if(this._patternIconIds == null)
         {
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(PlayerWallManager.PATTERN_MEDIA_ID,this.onPatternLoaded);
         }
         else
         {
            this._patternWindows = new WindowGenerator();
            this._patternWindows.init(1,this._patternIconIds.length,this._patternIconIds.length,0,0,0,ItemWindowPattern,this._patternIconIds,"",{
               "mouseDown":this.onSelectPattern,
               "mouseOver":null,
               "mouseOut":null
            },{
               "type":ItemWindowPattern.TYPE_SWATCH,
               "colorIndex":this._myCurrColorId
            },this.onPatternWindowsLoaded,false,false);
            this._playerWall.patternPopup.itemWindow.addChild(this._patternWindows);
         }
      }
      
      private function setupColors(param1:Boolean = false) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Boolean = true;
         var _loc4_:int = 1;
         while(_loc3_)
         {
            _loc2_ = this._playerWall.colorPopup["colorBtn" + _loc4_];
            if(_loc2_)
            {
               if(param1)
               {
                  _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSelectColor);
               }
               else
               {
                  _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelectColor,false,0,true);
               }
               _loc2_.gotoAndStop(_loc4_);
            }
            if(!_loc2_)
            {
               _loc3_ = false;
            }
            _loc4_++;
         }
      }
      
      private function updatePatternPopupColors() : void
      {
         var _loc1_:int = 0;
         if(this._patternWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < this._patternWindows.mediaWindows.length)
            {
               ItemWindowPattern(this._patternWindows.mediaWindows[_loc1_]).setColor(this._myCurrColorId);
               _loc1_++;
            }
         }
         if(this._messagePatternWindow)
         {
            ItemWindowPattern(this._messagePatternWindow).setColor(this._myCurrColorId);
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
               _loc1_ = PlayerWallManager.reportedPostIds;
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
               this._postWindows.init(1,this._inbox.length,this._inbox.length,0,6,6,ItemWindowPost,this._inbox,"",{
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
            this._postScrollBar.init(this._postWindows,this._playerWall.itemHolder.width,this._postWindows.boxHeight * 4 + 4 * 6 - 6,-40,"scrollbar2",this._postWindows.boxHeight + 6,_scrollYPosition);
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
      }
      
      private function onSelectPattern(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._currPatternId = param1.currentTarget.getCurrentPatternIndex();
         ItemWindowPattern(this._messagePatternWindow).setPattern(this._currPatternId);
         GuiManager.setSharedObj("msgPattern",this._currPatternId);
         this._playerWall.patternPopup.visible = false;
         this._playerWall.patternBtn.downToUpState();
      }
      
      private function onSelectColor(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._myCurrColorId = param1.currentTarget.currentFrame;
         GuiManager.setSharedObj("msgColor",this._myCurrColorId);
         this._playerWall.colorPopup.visible = false;
         this._playerWall.colorBtn.downToUpState();
         this.updatePatternPopupColors();
      }
      
      private function onReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._reportMsgId = param1.currentTarget.parent.parent.parent.msgId;
         this._reportAPlayer = new ReportAPlayer();
         this._reportAPlayer.init(this._guiLayer,this.onPostReport,true,param1.currentTarget.parent.parent.parent.senderUserName,param1.currentTarget.parent.parent.parent.senderModeratedUserName,false);
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
            this._playerWall.contentLoader.visible = true;
            KeepAlive.restartTimeLeftTimer();
            PlayerWallManager.onReportMessage(this._reportMsgId);
            this._reportMsgId = "";
         }
      }
      
      private function setStatusGrayState() : void
      {
      }
      
      private function onDeleteDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(this._guiLayer,"Are you sure you want to delete this post?",true,this.deleteMessageConfirmCallback,param1.currentTarget.parent.parent.parent.msgId);
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(Boolean(this._playerWall) && Boolean(param1.status))
         {
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.contentLoader.visible = true;
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendDeleteFromPlayerWall(this._owner,param1.passback,this.onDeleteResponse);
         }
      }
      
      public function onDeleteResponse(param1:Boolean, param2:String, param3:String = "") : void
      {
         var _loc4_:PostMessage = null;
         var _loc5_:int = 0;
         if(this._playerWall)
         {
            this._playerWall.contentLoader.visible = false;
            this._playerWall.postBtn.activateGrayState(false);
            if(param1)
            {
               _loc5_ = 0;
               while(_loc5_ < this._inbox.length)
               {
                  _loc4_ = this._inbox[_loc5_];
                  if(_loc4_ != null && _loc4_.msgId == param2)
                  {
                     this._inbox.splice(_loc5_,1);
                     break;
                  }
                  _loc5_++;
               }
               this.createWallPosts();
            }
            else if(param3)
            {
               if(param3 == SbiConstants.PLAYER_WALL_FAILURE_TOKEN)
               {
                  PlayerWallXtCommManager.sendWallTokenRequest(this._owner,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                     "cmd":"DEL",
                     "username":this._owner,
                     "messageuuid":String,
                     "callback":this.onDeleteResponse
                  });
               }
               else if(param3 == SbiConstants.PLAYER_WALL_FAILURE_UNAVAILABLE)
               {
                  new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(22625));
               }
            }
            else
            {
               new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(22627));
            }
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
         if(this._playerWall.messageTxtCont.messageTxt.alpha == 0.5)
         {
            this._playerWall.messageTxtCont.messageTxt.alpha = 1;
            this._predictiveTextManager.resetTreeSearch();
         }
         var _loc2_:String = EmoticonUtility.getEmoteString(param1);
         this._predictiveTextManager.addWordToPredictiveText(_loc2_);
         setTimeout(this.updateCharCount,1000 / 24);
         gMainFrame.stage.focus = this._playerWall.messageTxtCont.messageTxt;
      }
      
      private function onPostBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._predictiveTextManager)
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
         if(!this._playerWall.settingsPopup.visible)
         {
            this._playerWall.settingsBtn[this._playerWall.settingsBtn.currentFrameLabel + "Btn"].downToUpState();
         }
         this.closeAllLowerPopups();
      }
      
      private function onWallDecorBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._playerWall.wallDecorCont.visible = !this._playerWall.wallDecorCont.visible;
         if(!this._playerWall.wallDecorCont.visible)
         {
            this._playerWall.wallDecorBtn.downToUpState();
         }
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
      
      private function onDecorMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = this._currDecorIndex;
         if(param1)
         {
            param1.stopPropagation();
            _loc2_ = int(param1.currentTarget.index);
         }
         GuiManager.setSharedObj("decorId",_loc2_);
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this._wallDecorItemIds[_loc2_],this.onWallDecorItemLoaded);
      }
      
      private function onWallDecorItemLoaded(param1:MovieClip) : void
      {
         if(this._playerWall)
         {
            while(this._playerWall.wallItemWindow.numChildren > 0)
            {
               this._playerWall.wallItemWindow.removeChildAt(0);
            }
            this._playerWall.wallItemWindow.addChild(param1.getChildAt(0));
         }
      }
      
      private function onPatternWindowsLoaded() : void
      {
         if(this._playerWall)
         {
            this._patternScrollBar = new SBScrollbar();
            this._patternScrollBar.init(this._patternWindows,this._playerWall.patternPopup.itemWindow.width,this._patternWindows.boxHeight * 8,3,"scrollbar2",this._patternWindows.boxHeight,0);
         }
      }
      
      private function onDecorWindowsLoaded() : void
      {
         if(this._playerWall)
         {
            if(this._wallDecorItemIds == null)
            {
               GenericListXtCommManager.requestGenericList(this.DECOR_ITEMS_GENERIC_LIST_ID,this.onDecorItemsLoaded);
            }
            else if(this._playerWall)
            {
               this._decorScrollBar = new SBScrollbar();
               this._decorScrollBar.init(this._wallDecorWindows,this._playerWall.wallDecorCont.itemWindow.width,this._wallDecorWindows.boxHeight * 4 + 4 * 5,-45,"scrollbar2",this._wallDecorWindows.boxHeight + 5,0);
            }
         }
      }
      
      private function onDecorItemsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(this._playerWall)
         {
            this._wallDecorItemIds = param2;
            this.onDecorMouseDown(null);
            this.onDecorWindowsLoaded();
         }
      }
      
      private function onPatternLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(this._playerWall)
         {
            param1 = MovieClip(param1.getChildAt(0)).swatchBtn.pattern;
            this._patternIconIds = new Array(param1.currentLabels.length);
            _loc2_ = 0;
            while(_loc2_ < param1.currentLabels.length)
            {
               this._patternIconIds[_loc2_] = PlayerWallManager.PATTERN_MEDIA_ID;
               _loc2_++;
            }
            this.setupPatterns();
         }
      }
      
      private function onSendMessage(param1:MouseEvent) : void
      {
         var _loc2_:Avatar = null;
         var _loc3_:PostMessage = null;
         if(!this._playerWall.postBtn.isGray)
         {
            KeepAlive.restartTimeLeftTimer();
            this._playerWall.postBtn.activateGrayState(true);
            this._playerWall.contentLoader.visible = true;
            this._playerWall.messageTxtCont.charCounter.text = "0/" + this._playerWall.messageTxtCont.messageTxt.maxChars;
            if(this._predictiveTextManager == null)
            {
               this._playerWall.messageTxtCont.messageTxt.text = "";
            }
            _loc2_ = AvatarManager.playerAvatar;
            _loc3_ = new PostMessage("0",this._playerWall.messageTxtCont.messageTxt.text,gMainFrame.clientInfo.dbUserId,gMainFrame.userInfo.myUserName,gMainFrame.userInfo.userNameModerated,this._currPatternId,this._myCurrColorId,new Date().valueOf(),false,_loc2_.avTypeId,_loc2_.colors,_loc2_.inUseEyeId,_loc2_.inUsePatternId,LocalizationManager.currentLanguage,_loc2_.customAvId);
            PlayerWallXtCommManager.sendPutToPlayerWall(this._owner,_loc3_,this.onMessageSent);
         }
      }
      
      private function onMessageSent(param1:Boolean, param2:PostMessage, param3:int, param4:String = "") : void
      {
         if(this._playerWall)
         {
            if(param1)
            {
               PlayerWallManager.processMessagePush(param2);
            }
            else
            {
               if(param3 > 1 && param3 != 5)
               {
                  FacilitatorXtCommManager.openPunishPopup(FacilitatorXtCommManager.PUNISH_TYPE_MEDIUM_FILTER,0);
               }
               else if(param3 == -1)
               {
                  new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(22628));
               }
               else if(param4)
               {
                  if(param4 == SbiConstants.PLAYER_WALL_FAILURE_TOKEN)
                  {
                     PlayerWallXtCommManager.sendWallTokenRequest(this._owner,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                        "cmd":"PUT",
                        "username":this._owner,
                        "msgToPost":param2,
                        "callback":this.onMessageSent
                     });
                  }
                  else if(param4 == SbiConstants.PLAYER_WALL_FAILURE_UNAVAILABLE)
                  {
                     new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(22625));
                  }
               }
               else
               {
                  new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(22628));
               }
               this._playerWall.contentLoader.visible = false;
               this._playerWall.postBtn.activateGrayState(false);
            }
            if(this._predictiveTextManager)
            {
               this._predictiveTextManager.resetTreeSearch();
            }
         }
      }
      
      private function onFirstTimeGet(param1:Boolean, param2:Array) : void
      {
         if(this._playerWall)
         {
            KeepAlive.restartTimeLeftTimer();
            if(param1)
            {
               this.setupSettingsPopup(false,this._privacyId);
               this.onSettingsChoose(null);
               this.setupWallDecorPopup();
               this.addEventListeners();
               this.setupSafeChat();
               this.setupMessageEntry();
               this.setupPatterns();
               this.setupColors();
               this.setupEmotePopup();
            }
            else
            {
               new SBOkPopup(this._guiLayer,"Problem getting token. Please try again.");
            }
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
      
      private function checkShouldCompleteSuggestion(param1:String, param2:Boolean = false, param3:Function = null) : void
      {
         setTimeout(this.checkShouldCompleteSuggestionWork,1000 / 24,param1,param2,param3);
      }
      
      private function checkShouldCompleteSuggestionWork(param1:String, param2:Boolean, param3:Function) : void
      {
         var _loc4_:TextField = null;
         var _loc5_:TextFormat = null;
         if(this._playerWall)
         {
            if(param2)
            {
               if(param3 != null)
               {
                  param3(param1,true);
                  return;
               }
            }
            _loc4_ = new TextField();
            _loc5_ = this._playerWall.messageTxtCont.messageTxt.getTextFormat();
            _loc4_.text = this._playerWall.messageTxtCont.messageTxt.text + param1;
            _loc4_.setTextFormat(_loc5_);
            if(_loc4_.length > this._playerWall.messageTxtCont.messageTxt.maxChars)
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
      }
      
      private function onDecorIconsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(this._playerWall)
         {
            this._wallDecorIconIds = param2;
            this.setupWallDecorPopup();
         }
      }
      
      private function handleTextInput(param1:TextEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
         this.keyDownListener(this._keyboardEvent,param1.text);
      }
      
      private function onTextChanged(param1:Event) : void
      {
         if(Boolean(this._playerWall) && Boolean(this._predictiveTextManager))
         {
            this._predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent, param2:String = null) : void
      {
         if(param2 == null && param1.keyCode != Keyboard.ENTER && param1.keyCode != Keyboard.BACKSPACE && param1.keyCode != Keyboard.TAB && param1.keyCode != Keyboard.SHIFT)
         {
            this._keyboardEvent = param1;
            return;
         }
         if(this._keyboardEvent == null && param1 == null)
         {
            return;
         }
         if(this._predictiveTextManager)
         {
            if(param1.keyCode == 13)
            {
               if(this._playerWall.messageTxtCont.messageTxt.alpha != 0.5 && this._playerWall.messageTxtCont.messageTxt.text != "" && !this._playerWall.postBtn.isGray)
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
            this._predictiveTextManager.onKeyDown(param1,param2);
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
            if(this._playerWall.messageTxtCont.messageTxt.length > 0)
            {
               this._playerWall.postBtn.activateGrayState(!this._predictiveTextManager.isWordValid());
            }
            else
            {
               this._playerWall.postBtn.activateGrayState(true);
            }
            if(param1.keyCode == 13)
            {
               this._playerWall.messageTxtCont.messageTxt.setSelection(this._playerWall.messageTxtCont.messageTxt.length,this._playerWall.messageTxtCont.messageTxt.length);
            }
         }
      }
      
      private function updateCharCount() : void
      {
         if(this._playerWall)
         {
            this._playerWall.messageTxtCont.charCounter.visible = true;
            this._playerWall.messageTxtCont.charCounter.text = this._playerWall.messageTxtCont.messageTxt.text.length + "/" + this._playerWall.messageTxtCont.messageTxt.maxChars;
         }
      }
      
      private function onSettingsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._wallSettingsRadioBtns.selected != this._privacyId)
         {
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendWallSettingsRequest(this._wallSettingsRadioBtns.selected,this.onPrivacySetResponse);
         }
         this.onSettingsBtn(param1);
      }
      
      private function onSettingsChoose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._playerWall.settingsBtn.gotoAndStop(this._wallSettingsRadioBtns.selected + 1);
         if(this._playerWall.settingsPopup.visible)
         {
            this._playerWall.settingsBtn[this._playerWall.settingsBtn.currentFrameLabel + "Btn"].upToDownState();
         }
      }
      
      private function onWallDecorClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this.onWallDecorBtn(param1);
      }
      
      private function onChatTreeClose(param1:String, param2:String) : void
      {
         if(this._predictiveTextManager)
         {
            this._predictiveTextManager.resetTreeSearch();
         }
         this._playerWall.messageTxtCont.messageTxt.alpha = 1;
         this._playerWall.messageTxtCont.charCounter.visible = false;
         this._playerWall.messageTxtCont.charCounter.text = "0/" + this._playerWall.messageTxtCont.messageTxt.maxChars;
         this._playerWall.messageTxtCont.messageTxt.text = param1;
         this._msgCode = param2;
         this._playerWall.postBtn.activateGrayState(false);
         SafeChatManager.closeSafeChat(this._playerWall.chatTree);
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget == this._playerWall.statusTxt)
         {
            this._playerWall.statusTxt.setSelection(this._playerWall.statusTxt.length,this._playerWall.statusTxt.length);
            this._playerWall.postStatusBtn.visible = true;
         }
         else
         {
            if(this._playerWall.messageTxtCont.messageTxt.text == "Type your message here...")
            {
               this._playerWall.messageTxtCont.messageTxt.alpha = 1;
               this._predictiveTextManager.resetTreeSearch();
            }
            else if(this._msgCode != "")
            {
               this._playerWall.messageTxtCont.messageTxt.text = "";
               this._playerWall.messageTxtCont.charCounter.text = "0/" + this._playerWall.messageTxtCont.messageTxt.maxChars;
               this._playerWall.messageTxtCont.charCounter.visible = true;
               this._msgCode = "";
               this._playerWall.postBtn.activateGrayState(true);
            }
            this._playerWall.messageTxtCont.messageTxt.setSelection(this._playerWall.messageTxtCont.messageTxt.length,this._playerWall.messageTxtCont.messageTxt.length);
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
         this._playerWall.messageTxtCont.messageTxt.setSelection(this._playerWall.messageTxtCont.messageTxt.length,this._playerWall.messageTxtCont.messageTxt.length);
      }
      
      private function addEventListeners() : void
      {
         if(this._playerWall)
         {
            this._playerWall.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._playerWall.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn,false,0,true);
            this._playerWall.patternBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPatternBtn,false,0,true);
            this._playerWall.colorBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtn,false,0,true);
            this._playerWall.emoteBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onEmoteBtn,false,0,true);
            this._playerWall.postBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPostBtn,false,0,true);
            this._playerWall.settingsBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSettingsBtn,false,0,true);
            this._playerWall.messageTxtCont.messageTxt.addEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange,false,0,true);
            this._playerWall.speedChatBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSafeChatBtn,false,0,true);
            this._playerWall.wallDecorBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onWallDecorBtn,false,0,true);
         }
      }
      
      private function removeEventListeners() : void
      {
         if(this._playerWall)
         {
            this._playerWall.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._playerWall.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseBtn);
            this._playerWall.patternBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPatternBtn);
            this._playerWall.colorBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorBtn);
            this._playerWall.emoteBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onEmoteBtn);
            this._playerWall.postBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPostBtn);
            this._playerWall.settingsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSettingsBtn);
            this._playerWall.messageTxtCont.messageTxt.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE,this.onKeyFocusChange);
            this._playerWall.speedChatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSafeChatBtn);
            this._playerWall.wallDecorBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onWallDecorBtn);
         }
      }
   }
}

