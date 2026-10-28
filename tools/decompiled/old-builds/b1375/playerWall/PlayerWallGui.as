package playerWall
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.UserCommXtCommManager;
   import collection.DenItemCollection;
   import collection.IntItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBOkCancelPopup;
   import com.sbi.popup.SBOkPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.setTimeout;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.BuddyManager;
   import gui.CursorManager;
   import gui.DarkenManager;
   import gui.EmoticonManager;
   import gui.EmoticonUtility;
   import gui.FeedbackManager;
   import gui.GenericListGuiManager;
   import gui.GuiManager;
   import gui.GuiRadioButtonGroup;
   import gui.LoadingSpiral;
   import gui.PredictiveTextManager;
   import gui.ReportAPlayer;
   import gui.SBScrollbar;
   import gui.SafeChatManager;
   import gui.WindowAndScrollbarGenerator;
   import gui.WindowGenerator;
   import gui.itemWindows.ItemWindowMasterpiece;
   import gui.itemWindows.ItemWindowPattern;
   import gui.itemWindows.ItemWindowPlayerWallDecor;
   import gui.itemWindows.ItemWindowPost;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import masterpiece.MasterpieceDisplayItem;
   
   public class PlayerWallGui
   {
      
      private static var _scrollYPosition:Number = 0;
      
      private const PLAYER_WALL_MEDIA_ID:int = 1499;
      
      private const AVATAR_ICON_LIST_ID:int = 109;
      
      private const DECOR_ICONS_GENERIC_LIST_ID:int = 313;
      
      private const DECOR_ITEMS_GENERIC_LIST_ID:int = 314;
      
      private var _guiLayer:DisplayLayer;
      
      private var _inbox:Vector.<PostMessage>;
      
      private var _closeCallback:Function;
      
      private var _mediaHelper:MediaHelper;
      
      private var _playerWall:MovieClip;
      
      private var _owner:String;
      
      private var _status:String;
      
      private var _currPatternId:int;
      
      private var _myCurrColorId:int;
      
      private var _postWindows:WindowAndScrollbarGenerator;
      
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
      
      private var _masterpieceWindows:WindowAndScrollbarGenerator;
      
      private var _wallDecorIconIds:Array;
      
      private var _decorScrollBar:SBScrollbar;
      
      private var _wallDecorItemIds:Array;
      
      private var _currDecorIndex:int;
      
      private var _patternIconIds:Array;
      
      private var _patternWindows:WindowGenerator;
      
      private var _patternScrollBar:SBScrollbar;
      
      private var _messagePatternWindow:ItemWindowPattern;
      
      private var _wallParameters:Object;
      
      private var _hasLoadedDecor:Boolean;
      
      private var _messagePatternLoaded:Boolean;
      
      private var _updateTimer:Timer;
      
      private var _canWrite:Boolean;
      
      private var _currDragMasterpiece:MasterpieceDisplayItem;
      
      private var _dragStartPoint:Point;
      
      private var _masterpieceFrameIds:Array;
      
      private var _masterpieceLaunchObj:Object;
      
      private var _selectedMasterpieces:Object;
      
      private var _masterpieceDiCollection:DenItemCollection;
      
      private var _masterpieceItemsBeingLoaded:Array;
      
      public function PlayerWallGui()
      {
         super();
      }
      
      public function init(param1:Vector.<PostMessage>, param2:String, param3:String, param4:int, param5:int, param6:Function) : void
      {
         if(MinigameManager.inMinigame())
         {
            return;
         }
         _guiLayer = GuiManager.guiLayer;
         _inbox = param1;
         _owner = param2;
         _status = param3;
         _currPatternId = param4;
         _myCurrColorId = param5;
         _closeCallback = param6;
         _isMyWall = param2 == gMainFrame.userInfo.myUserName;
         _mediaHelperHolder = [];
         _updateTimer = new Timer(45000);
         _canWrite = _isMyWall ? true : PlayerWallManager.tokenMap[_owner.toLowerCase()].write == "1";
         SBTracker.trackPageview("game/play/playerWall/#" + (_isMyWall ? "openMyWall" : "openStrangersWall"));
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(1499,onMediaLoaded);
         UserCommXtCommManager.sendPermEmote(4329);
      }
      
      public function destroy() : void
      {
         KeepAlive.stopKATimer(_playerWall);
         if(_postWindows)
         {
            _postWindows.destroy();
            _postWindows = null;
         }
         setupSafeChat(true);
         setupSettingsPopup(true);
         setupMessageEntry(true);
         setupEmotePopup(true);
         setupColors(true);
         setupPatterns(true);
         setupWallDecorPopup(true);
         setupMasterpiecePopup(true);
         _mediaHelperHolder = null;
         _mediaHelper = null;
         _inbox = null;
         _closeCallback = null;
         removeEventListeners();
         _updateTimer.stop();
         _updateTimer = null;
         for each(var _loc1_:MasterpieceDisplayItem in _masterpieceItemsBeingLoaded)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
               _loc1_ = null;
            }
         }
         _masterpieceItemsBeingLoaded = null;
         DarkenManager.unDarken(_playerWall);
         if(_playerWall && _playerWall.parent == _guiLayer)
         {
            _guiLayer.removeChild(_playerWall);
         }
         _playerWall = null;
         UserCommXtCommManager.sendPermEmote(-1);
      }
      
      public function reloadMessages(param1:Vector.<PostMessage>, param2:int, param3:String = "") : void
      {
         var _loc6_:PostMessage = null;
         var _loc7_:int = 0;
         var _loc5_:Object = PlayerWallManager.myBlockedMessages;
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            _loc6_ = param1[_loc7_];
            if(_loc6_.msgId != param3 && _loc6_.msgId == _loc5_[_loc6_.msgId])
            {
               param1.splice(_loc7_,1);
               _loc7_--;
            }
            _loc7_++;
         }
         var _loc4_:* = -1;
         _loc7_ = 0;
         while(_loc7_ < param1.length)
         {
            if(param1[_loc7_].msgId == param3)
            {
               _loc4_ = _loc7_;
               break;
            }
            _loc7_++;
         }
         if(param1)
         {
            switch(param2)
            {
               case 0:
                  findDifferencesAndUpdatePosts(param1);
                  break;
               case 1:
                  _postWindows.deleteItem(_loc4_,param1);
                  break;
               case 2:
                  _postWindows.updateItem(_loc4_,param1[_loc4_]);
                  break;
               case 3:
                  _postWindows.deleteItem(_loc4_,param1);
                  break;
               case 4:
                  _postWindows.insertItem(param1[_loc4_],true);
                  break;
               case 5:
                  _inbox = param1;
                  createWallPosts();
            }
            _playerWall.noPostCont.visible = param1.length == 0;
            _playerWall.cleanUpBtn.activateGrayState(param1.length == 0);
         }
      }
      
      public function reloadMasterpieceItems() : void
      {
         var _loc1_:MovieClip = _playerWall.frame_0;
         var _loc2_:int = 0;
         while(_loc1_)
         {
            while(_loc1_.itemLayer.numChildren > 1)
            {
               _loc1_.itemLayer.removeChildAt(_loc1_.itemLayer.numChildren - 1);
            }
            if(_loc1_.loadingSpiral)
            {
               (_loc1_.loadingSpiral as LoadingSpiral).destroy();
               delete _loc1_.loadingSpiral;
            }
            _loc2_++;
            _loc1_ = _playerWall["frame_" + _loc2_];
         }
         setupMasterpiecePopup();
      }
      
      public function set currWallParameters(param1:Object) : void
      {
         _wallParameters = param1;
         if(_wallParameters == null)
         {
            _wallParameters = {"bg":"19"};
         }
         else if(_wallParameters.bg && _wallParameters.bg == -1)
         {
            _wallParameters.bg = 19;
         }
         if(_wallParameters.mp)
         {
            _selectedMasterpieces = _wallParameters.mp;
         }
         _currDecorIndex = int(_wallParameters.bg);
      }
      
      public function get myCurrMessageColorId() : int
      {
         return _myCurrColorId;
      }
      
      public function get currMessagePattern() : int
      {
         return _currPatternId;
      }
      
      public function get owner() : String
      {
         return _owner;
      }
      
      public function get status() : String
      {
         return _playerWall.statusTxt.text;
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _playerWall = MovieClip(param1.getChildAt(0));
            KeepAlive.startKATimer(_playerWall);
            _playerWall.x = 900 * 0.5;
            _playerWall.y = 550 * 0.5;
            _playerWall.patternPopup.visible = false;
            _playerWall.colorPopup.visible = false;
            _playerWall.emotePopup.visible = false;
            _playerWall.postBtn.activateGrayState(true);
            _playerWall.titleTxt.text = _owner;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 0.5;
            _playerWall.settingsPopup.visible = false;
            _playerWall.predictiveText.visible = false;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.selectable = false;
            _playerWall.messageTxtCont.txtColorCont.charCounter.visible = false;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.text = "";
            _playerWall.wallDecorCont.visible = false;
            _playerWall.masterpieceCont.visible = false;
            _playerWall.contentLoader.visible = true;
            _playerWall.noPostCont.visible = false;
            if(_isMyWall)
            {
               _playerWall.settingsBtn.visible = true;
               _playerWall.wallDecorBtn.visible = true;
               _playerWall.masterpieceBtn.visible = true;
               _playerWall.btnBgCont.visible = true;
               _privacyId = gMainFrame.userInfo.playerWallSettings;
               _playerWall.cleanUpBtn.activateGrayState(true);
            }
            else
            {
               _playerWall.settingsBtn.visible = false;
               _playerWall.wallDecorBtn.visible = false;
               _playerWall.masterpieceBtn.visible = false;
               _playerWall.btnBgCont.visible = false;
               _playerWall.cleanUpBtn.visible = false;
            }
            if(PlayerWallManager.isFirstTime || !_isMyWall)
            {
               PlayerWallXtCommManager.sendGetFromPlayerWall(_isMyWall ? gMainFrame.userInfo.myUserName : _owner,onFirstTimeGet);
            }
            else
            {
               setupWallDecorPopup();
               setupMasterpiecePopup();
               setupMessageEntry();
               setupSafeChat();
               setupPatterns();
               setupColors();
               setupEmotePopup();
               setupSettingsPopup(false,_privacyId);
               onSettingsChoose(null);
               updatePatternPopupColors();
               createWallPosts();
               PlayerWallManager.startMyWallTimer();
            }
            addEventListeners();
         }
      }
      
      private function setupSafeChat(param1:Boolean = false) : void
      {
         if(_canWrite)
         {
            if(param1)
            {
               SafeChatManager.destroy(_playerWall.chatTree);
            }
            else
            {
               SafeChatManager.buildSafeChatTree(_playerWall.chatTree,"ECardTextTreeNode",5,onChatTreeClose,null);
               SafeChatManager.closeSafeChat(_playerWall.chatTree);
               _playerWall.speedChatBtn.downToUpState();
            }
         }
         else
         {
            _playerWall.speedChatBtn.activateGrayState(true);
            _playerWall.speedChatBtn.mouseChildren = false;
            _playerWall.speedChatBtn.mouseEnabled = false;
            _playerWall.chatTree.visible = false;
         }
      }
      
      private function setupSettingsPopup(param1:Boolean = false, param2:int = 0) : void
      {
         if(param1)
         {
            _playerWall.settingsPopup.removeEventListener("mouseDown",onPopup);
            _playerWall.settingsPopup.bx.removeEventListener("mouseDown",onSettingsClose);
            if(_wallSettingsRadioBtns)
            {
               _wallSettingsRadioBtns.currRadioButton.removeEventListener("mouseDown",onSettingsChoose);
               _wallSettingsRadioBtns.destroy();
               _wallSettingsRadioBtns = null;
            }
         }
         else
         {
            _playerWall.settingsPopup.addEventListener("mouseDown",onPopup,false,0,true);
            _playerWall.settingsPopup.bx.addEventListener("mouseDown",onSettingsClose,false,0,true);
            _wallSettingsRadioBtns = new GuiRadioButtonGroup(_playerWall.settingsPopup.options);
            _wallSettingsRadioBtns.currRadioButton.addEventListener("mouseDown",onSettingsChoose,false,0,true);
            _wallSettingsRadioBtns.selected = param2;
         }
      }
      
      private function setupWallDecorPopup(param1:Boolean = false) : void
      {
         if(param1)
         {
            _playerWall.wallDecorCont.removeEventListener("mouseDown",onPopup);
            _playerWall.wallDecorCont.bx.removeEventListener("mouseDown",onWallDecorClose);
            _wallDecorIconIds = null;
            if(_wallDecorWindows)
            {
               _wallDecorWindows.destroy();
               _wallDecorWindows = null;
            }
         }
         else
         {
            if(_isMyWall)
            {
               currWallParameters = PlayerWallManager.myWallParameters;
            }
            if(_wallDecorItemIds == null)
            {
               GenericListXtCommManager.requestGenericList(314,onDecorItemsLoaded);
            }
            if(_wallDecorIconIds == null)
            {
               _playerWall.wallDecorBtn.addEventListener("mouseDown",onPopup,false,0,true);
               _playerWall.wallDecorCont.bx.addEventListener("mouseDown",onWallDecorClose,false,0,true);
               GenericListXtCommManager.requestGenericList(313,onDecorIconsLoaded);
            }
            else
            {
               _wallDecorWindows = new WindowGenerator();
               _wallDecorWindows.init(3,_wallDecorIconIds.length,_wallDecorIconIds.length,10,5,5,ItemWindowPlayerWallDecor,_wallDecorIconIds,"",{
                  "mouseDown":onDecorMouseDown,
                  "mouseOver":null,
                  "mouseOut":null
               },null,onDecorWindowsLoaded,false,false);
               _playerWall.wallDecorCont.itemWindow.addChild(_wallDecorWindows);
            }
         }
      }
      
      private function setupMasterpiecePopup(param1:Boolean = false) : void
      {
         var _loc2_:MovieClip = null;
         if(param1)
         {
            if(_isMyWall)
            {
               _playerWall.masterpieceCont.removeEventListener("mouseDown",onPopup);
               _playerWall.masterpieceCont.bx.removeEventListener("mouseDown",onMasterpiecePopupClose);
               _playerWall.masterpieceCont.createMasterpieceBtn.removeEventListener("mouseDown",onCreateAMasterpieceBtn);
               if(_masterpieceWindows)
               {
                  _masterpieceWindows.destroy();
                  _masterpieceWindows = null;
               }
            }
         }
         else
         {
            if(_selectedMasterpieces)
            {
               for each(var _loc3_:Object in _selectedMasterpieces)
               {
                  _loc2_ = _playerWall["frame_" + _loc3_.sid];
                  if(_loc2_)
                  {
                     while(_loc2_.itemLayer.numChildren > 1)
                     {
                        _loc2_.itemLayer.removeChildAt(_loc2_.itemLayer.numChildren - 1);
                     }
                     if(_loc2_.loadingSpiral)
                     {
                        (_loc2_.loadingSpiral as LoadingSpiral).destroy();
                        delete _loc2_.loadingSpiral;
                     }
                     _loc2_.loadingSpiral = new LoadingSpiral(_loc2_.itemLayer);
                  }
               }
            }
            if(_isMyWall)
            {
               _playerWall.masterpieceBtn.addEventListener("mouseDown",onPopup,false,0,true);
               _playerWall.masterpieceCont.bx.addEventListener("mouseDown",onMasterpiecePopupClose,false,0,true);
               _playerWall.masterpieceCont.createMasterpieceBtn.addEventListener("mouseDown",onCreateAMasterpieceBtn,false,0,true);
               setupMasterpieceCollection(new DenItemCollection(gMainFrame.userInfo.playerUserInfo.denItemsFull.concatCollection(null)));
               if(_masterpieceWindows)
               {
                  _masterpieceWindows.destroy();
                  _masterpieceWindows = null;
               }
               _masterpieceWindows = new WindowAndScrollbarGenerator();
               _masterpieceWindows.init(_playerWall.masterpieceCont.itemWindow.width,_playerWall.masterpieceCont.itemWindow.height,5,0,2,2,_masterpieceDiCollection.length,2,2,2,2,ItemWindowMasterpiece,_masterpieceDiCollection.getCoreArray(),"icon",0,{
                  "mouseDown":onMasterpieceMouseDown,
                  "mouseOver":null,
                  "mouseOut":null
               },_selectedMasterpieces,null,true,false,false);
               _playerWall.masterpieceCont.itemWindow.addChild(_masterpieceWindows);
               if(_masterpieceDiCollection.length == 0)
               {
                  _playerWall.masterpieceCont.noFramePopup.visible = true;
               }
               else
               {
                  _playerWall.masterpieceCont.noFramePopup.visible = false;
               }
               setupMasterpiecesInFrames();
            }
            else
            {
               DenXtCommManager.requestDenMasterpieceItems(_owner,onMasterpieceItemsReceived);
            }
         }
      }
      
      private function setupMasterpieceCollection(param1:DenItemCollection) : void
      {
         var _loc3_:int = 0;
         _masterpieceDiCollection = new DenItemCollection();
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1.getDenItem(_loc3_).isCustom)
            {
               if(!_isMyWall)
               {
                  for each(var _loc2_:Object in _selectedMasterpieces)
                  {
                     if(_loc2_.iid == param1.getDenItem(_loc3_).invIdx)
                     {
                        _masterpieceDiCollection.pushDenItem(param1.getDenItem(_loc3_));
                        break;
                     }
                  }
               }
               else
               {
                  _masterpieceDiCollection.pushDenItem(param1.getDenItem(_loc3_));
               }
            }
            _loc3_++;
         }
      }
      
      private function onMasterpieceItemsReceived(param1:DenItemCollection) : void
      {
         setupMasterpieceCollection(param1);
         setupMasterpiecesInFrames();
      }
      
      private function setupMasterpiecesInFrames() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:MovieClip = null;
         var _loc5_:MasterpieceDisplayItem = null;
         var _loc6_:IntItemCollection = new IntItemCollection();
         _masterpieceItemsBeingLoaded = [];
         for each(var _loc4_:Object in _selectedMasterpieces)
         {
            _loc1_ = false;
            _loc2_ = _playerWall["frame_" + _loc4_.sid];
            for each(var _loc3_:DenItem in _masterpieceDiCollection.getCoreArray())
            {
               if(_loc3_.invIdx == _loc4_.iid)
               {
                  if(_loc2_)
                  {
                     _loc5_ = new MasterpieceDisplayItem();
                     _loc5_.init(_loc3_.invIdx,_loc3_.version,_loc3_.uniqueImageId,_loc3_.uniqueImageCreator,_loc3_.uniqueImageCreatorDbId,_loc3_.uniqueImageCreatorUUID,onMasterpieceSetupInFramesLoaded,_loc2_);
                     _masterpieceItemsBeingLoaded[_loc4_.sid] = _loc5_;
                  }
                  _loc1_ = true;
                  break;
               }
            }
            if(!_loc1_)
            {
               if(_loc2_ && _loc2_.loadingSpiral)
               {
                  (_loc2_.loadingSpiral as LoadingSpiral).destroy();
                  delete _loc2_.loadingSpiral;
               }
               _loc6_.pushIntItem(_loc4_.iid);
            }
         }
         if(_loc6_.length > 0)
         {
            PlayerWallXtCommManager.sendRemoveMasterpiece(_loc6_,null);
         }
      }
      
      private function onMasterpieceSetupInFramesLoaded(param1:MasterpieceDisplayItem, param2:MovieClip) : void
      {
         if(param2.loadingSpiral)
         {
            (param2.loadingSpiral as LoadingSpiral).destroy();
            delete param2.loadingSpiral;
         }
         while(param2.itemLayer.numChildren > 1)
         {
            param2.itemLayer.removeChildAt(param2.itemLayer.numChildren - 1);
         }
         var _loc3_:Number = param2.itemLayer.width / Math.max(param1.width,param1.height);
         param1.scaleX = param1.scaleY = _loc3_;
         param2.itemLayer.addChild(param1);
      }
      
      private function setupMessageEntry(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(_predictiveTextManager)
            {
               _predictiveTextManager.destroy();
            }
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("keyDown",keyDownListener);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("change",onTextChanged);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseDown",msgTextDownHandler);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseOver",onTextOver);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseOut",onTextOut);
            if(_messagePatternWindow)
            {
               _messagePatternWindow.destroy();
               _messagePatternWindow = null;
            }
         }
         else if(_canWrite)
         {
            _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars = 70;
            _playerWall.messageTxtCont.txtColorCont.charCounter.text = "0/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
            _playerWall.messageTxtCont.txtColorCont.charCounter.visible = true;
            _predictiveTextManager = new PredictiveTextManager();
            _predictiveTextManager.init(_playerWall.messageTxtCont.txtColorCont.messageTxt,2,_playerWall.predictTxtTag,_playerWall.specialCharCont,-262,_playerWall.messageTxtCont,onSendMessage,checkShouldCompleteSuggestion);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("change",onTextChanged,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.selectable = true;
            _playerWall.messageTxtCont.txtColorCont.messageTxt.text = LocalizationManager.translateIdOnly(23140);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("keyDown",keyDownListener,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseOver",onTextOver,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseOut",onTextOut,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseDown",msgTextDownHandler,false,0,true);
            _playerWall.messageTxtCont.gotoAndStop(_myCurrColorId);
            _messagePatternWindow = new ItemWindowPattern(onMessagePatternLoaded,3983,"",0,null,null,null,null,{
               "type":"post",
               "colorIndex":_myCurrColorId,
               "patternIndex":_currPatternId
            });
            _playerWall.messageEntryHolder.addChild(_messagePatternWindow);
         }
         else
         {
            _playerWall.predictTxtTag.visible = _playerWall.specialCharCont.visible = false;
            _playerWall.colorBtn.activateGrayState(true);
            _playerWall.colorBtn.mouseChildren = false;
            _playerWall.colorBtn.mouseEnabled = false;
            _playerWall.messageTxtCont.visible = false;
            _messagePatternLoaded = true;
            if(_hasLoadedDecor)
            {
               displayLoadedWall();
            }
         }
      }
      
      private function setupPatterns(param1:Boolean = false) : void
      {
         if(_canWrite)
         {
            if(param1)
            {
               _patternIconIds = null;
               if(_patternWindows)
               {
                  _patternWindows.destroy();
                  _patternWindows = null;
               }
            }
            else if(_patternIconIds == null)
            {
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(3983,onPatternLoaded);
            }
            else
            {
               _patternWindows = new WindowGenerator();
               _patternWindows.init(1,_patternIconIds.length,_patternIconIds.length,0,0,0,ItemWindowPattern,_patternIconIds,"",{
                  "mouseDown":onSelectPattern,
                  "mouseOver":null,
                  "mouseOut":null
               },{
                  "type":"swatch",
                  "colorIndex":_myCurrColorId
               },onPatternWindowsLoaded,false,false);
               _playerWall.patternPopup.itemWindow.addChild(_patternWindows);
            }
         }
         else
         {
            _playerWall.patternBtn.activateGrayState(true);
            _playerWall.patternBtn.mouseChildren = false;
            _playerWall.patternBtn.mouseEnabled = false;
         }
      }
      
      private function setupColors(param1:Boolean = false) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Boolean = true;
         var _loc4_:int = 1;
         while(_loc2_)
         {
            _loc3_ = _playerWall.colorPopup["colorBtn" + _loc4_];
            if(_loc3_)
            {
               if(param1)
               {
                  _loc3_.removeEventListener("mouseDown",onSelectColor);
               }
               else
               {
                  _loc3_.addEventListener("mouseDown",onSelectColor,false,0,true);
               }
               _loc3_.gotoAndStop(_loc4_);
            }
            if(!_loc3_)
            {
               _loc2_ = false;
            }
            _loc4_++;
         }
      }
      
      private function updatePatternPopupColors() : void
      {
         var _loc1_:int = 0;
         if(_patternWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < _patternWindows.mediaWindows.length)
            {
               ItemWindowPattern(_patternWindows.mediaWindows[_loc1_]).setColor(_myCurrColorId);
               _loc1_++;
            }
         }
         if(_messagePatternWindow)
         {
            ItemWindowPattern(_messagePatternWindow).setColor(_myCurrColorId);
         }
         _playerWall.messageTxtCont.gotoAndStop(_myCurrColorId);
      }
      
      private function setupEmotePopup(param1:Boolean = false) : void
      {
         if(_canWrite)
         {
            if(param1)
            {
               if(_emoteMgr)
               {
                  _emoteMgr.destroy();
               }
            }
            else
            {
               _emoteMgr = new EmoticonManager(1,onEmoteDown,_playerWall.emoteBtn,_playerWall.emotePopup,null,null,null,null,false);
            }
         }
         else
         {
            _playerWall.emoteBtn.activateGrayState(true);
            _playerWall.emoteBtn.mouseChildren = false;
            _playerWall.emoteBtn.mouseEnabled = false;
         }
      }
      
      private function createWallPosts() : void
      {
         var _loc4_:Array = null;
         var _loc3_:int = 0;
         var _loc1_:Object = null;
         var _loc2_:PostMessage = null;
         if(_playerWall)
         {
            if(_postWindows)
            {
               _scrollYPosition = _postWindows.scrollYValue;
               _postWindows.destroy();
               _postWindows = null;
            }
            else
            {
               _scrollYPosition = 1.7976931348623157e+308;
            }
            _loc4_ = [];
            _loc1_ = PlayerWallManager.myBlockedMessages;
            _loc3_ = 0;
            while(_loc3_ < _inbox.length)
            {
               _loc2_ = _inbox[_loc3_];
               if(_loc2_.msgId == _loc1_[_loc2_.msgId])
               {
                  _inbox.splice(_loc3_,1);
                  _loc3_--;
               }
               else
               {
                  _loc4_.push(_loc2_);
               }
               _loc3_++;
            }
            _playerWall.newMessageBtn.visible = false;
            _playerWall.contentLoader.visible = false;
            _playerWall.noPostCont.visible = _inbox.length == 0;
            _playerWall.cleanUpBtn.activateGrayState(_inbox.length == 0);
            _postWindows = new WindowAndScrollbarGenerator();
            _postWindows.init(_playerWall.itemHolder.width,_playerWall.itemHolder.height - 4,0,_scrollYPosition,1,5,0,0,0,6,0,ItemWindowPost,_loc4_,"",100,{
               "mouseDown":null,
               "mouseOver":null,
               "mouseOut":null
            },{
               "reportMsgBtnMouseDown":onReportDown,
               "deleteMsgBtnMouseDown":onDeleteDown,
               "isMyPost":_isMyWall
            },null,false,false,false,false,true);
            _playerWall.itemHolder.addChild(_postWindows);
         }
      }
      
      private function closeAllLowerPopups() : void
      {
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         _playerWall.speedChatBtn.downToUpState();
         if(_emoteMgr)
         {
            _emoteMgr.closeEmotes();
         }
         if(_playerWall.colorPopup.visible)
         {
            _playerWall.colorPopup.visible = false;
            _playerWall.colorBtn.downToUpState();
         }
         if(_playerWall.patternPopup.visible)
         {
            _playerWall.patternPopup.visible = false;
            _playerWall.patternBtn.downToUpState();
         }
      }
      
      private function onSelectPattern(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _currPatternId = param1.currentTarget.getCurrentPatternIndex();
         ItemWindowPattern(_messagePatternWindow).setPattern(_currPatternId);
         GuiManager.setSharedObj("msgPattern",_currPatternId);
         _playerWall.patternPopup.visible = false;
         _playerWall.patternBtn.downToUpState();
      }
      
      private function onSelectColor(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _myCurrColorId = param1.currentTarget.currentFrame;
         GuiManager.setSharedObj("msgColor",_myCurrColorId);
         _playerWall.colorPopup.visible = false;
         _playerWall.colorBtn.downToUpState();
         updatePatternPopupColors();
      }
      
      private function onReportDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:ItemWindowPost = param1.currentTarget.parent.parent.parent;
         _reportMsgId = _loc2_.msgId;
         _reportAPlayer = new ReportAPlayer();
         _reportAPlayer.init(3,_guiLayer,onPostReport,true,_loc2_.senderUserName,_loc2_.senderModeratedUserName,false,_reportMsgId);
      }
      
      private function onPostReport(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         if(param1 && _reportMsgId != "")
         {
            _playerWall.postBtn.activateGrayState(true);
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendSetBlockedMessage(_reportMsgId,null);
            _reportMsgId = "";
         }
         SafeChatManager.destroy(_playerWall.chatTree);
         SafeChatManager.buildSafeChatTree(_playerWall.chatTree,"ECardTextTreeNode",5,onChatTreeClose,null);
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         _playerWall.speedChatBtn.downToUpState();
      }
      
      private function setStatusGrayState() : void
      {
      }
      
      private function findDifferencesAndUpdatePosts(param1:Vector.<PostMessage>) : void
      {
         var _loc6_:* = null;
         var _loc8_:PostMessage = null;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:Object = {};
         for each(_loc6_ in _inbox)
         {
            _loc2_[_loc6_.msgId] = _loc6_;
         }
         var _loc4_:Array = [];
         var _loc5_:Vector.<PostMessage> = new Vector.<PostMessage>();
         var _loc3_:Object = PlayerWallManager.myBlockedMessages;
         for each(_loc6_ in param1)
         {
            _loc8_ = _loc2_[_loc6_.msgId];
            if(_loc8_ == null)
            {
               if(_loc6_.msgId != _loc3_[_loc6_.msgId])
               {
                  _loc4_.push(_loc6_);
               }
            }
            else if(_loc8_.message != _loc6_.message)
            {
               _loc5_.push(_loc6_);
            }
         }
         _inbox = param1;
         if(_postWindows)
         {
            if(_loc4_.length > 0)
            {
               if(_loc4_.length == 1)
               {
                  _postWindows.insertItem(_loc4_[0],false);
               }
               else
               {
                  _postWindows.insertManyItems(_loc4_,false);
               }
            }
            if(_loc5_.length > 0)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc5_.length)
               {
                  _loc9_ = 0;
                  while(_loc9_ < param1.length)
                  {
                     if(param1[_loc9_].msgId == _loc5_[_loc7_].msgId)
                     {
                        _postWindows.updateItem(_loc9_,param1[_loc9_]);
                     }
                     _loc9_++;
                  }
                  _loc7_++;
               }
            }
         }
         else
         {
            createWallPosts();
         }
      }
      
      private function canIKeepPosting() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(_isMyWall)
         {
            return true;
         }
         if(_inbox.length < 5)
         {
            return true;
         }
         _loc2_ = _inbox.length - 1;
         while(_loc2_ >= 0)
         {
            if(_inbox[_loc2_].senderUserName != gMainFrame.userInfo.myUserName)
            {
               return true;
            }
            if(++_loc1_ >= 5)
            {
               return false;
            }
            _loc2_--;
         }
         return true;
      }
      
      private function displayLoadedWall() : void
      {
         GuiManager.mainHud.playerWall.activateLoadingState(false);
         BuddyManager.setPlayerWallLoading(false);
         BuddyManager.destroyBuddyCard();
         _guiLayer.addChild(_playerWall);
         DarkenManager.darken(_playerWall);
         _updateTimer.start();
         if(_isMyWall)
         {
            if(gMainFrame.userInfo.userVarCache.getUserVarValueById(414) < 0)
            {
               AchievementXtCommManager.requestSetUserVar(414,1);
               GenericListGuiManager.genericListVolumeClicked(334,{
                  "shouldRepeat":false,
                  "msg":"biggerFrame",
                  "width":768,
                  "height":432
               });
            }
         }
      }
      
      private function onDeleteDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.parent.parent.parent.darken(true);
         new SBOkCancelPopup(_guiLayer,LocalizationManager.translateIdOnly(23141),true,deleteMessageConfirmCallback,param1.currentTarget.parent.parent.parent);
      }
      
      private function deleteMessageConfirmCallback(param1:Object) : void
      {
         if(_playerWall && param1.status)
         {
            _playerWall.postBtn.activateGrayState(true);
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendDeleteFromPlayerWall(_owner,param1.passback.msgId,onDeleteResponse);
         }
         else
         {
            param1.passback.darken(false);
         }
      }
      
      public function onDeleteResponse(param1:Boolean, param2:String, param3:String = "") : void
      {
         var _loc4_:PostMessage = null;
         var _loc5_:int = 0;
         if(_playerWall)
         {
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha != 0.5 && _playerWall.messageTxtCont.txtColorCont.messageTxt.length > 0)
            {
               _playerWall.postBtn.activateGrayState(!_predictiveTextManager.isValid());
            }
            else
            {
               _playerWall.postBtn.activateGrayState(true);
            }
            if(param1)
            {
               _loc5_ = 0;
               while(_loc5_ < _inbox.length)
               {
                  _loc4_ = _inbox[_loc5_];
                  if(_loc4_ != null && _loc4_.msgId == param2)
                  {
                     _postWindows.deleteItem(_loc5_,_inbox);
                     break;
                  }
                  _loc5_++;
               }
               _playerWall.noPostCont.visible = _inbox.length == 0;
               _playerWall.cleanUpBtn.activateGrayState(_inbox.length == 0);
            }
            else if(param3)
            {
               if(param3 == "token")
               {
                  PlayerWallXtCommManager.sendWallTokenRequest(_owner,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                     "cmd":"DEL",
                     "username":_owner,
                     "messageuuid":String,
                     "callback":onDeleteResponse
                  },true,true);
               }
               else if(param3 == "unavailable")
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
               }
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22627));
            }
         }
      }
      
      private function onPatternBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_playerWall.colorPopup.visible)
            {
               _playerWall.colorPopup.visible = false;
               _playerWall.colorBtn.downToUpState();
            }
            SafeChatManager.closeSafeChat(_playerWall.chatTree);
            _playerWall.speedChatBtn.downToUpState();
            if(_emoteMgr)
            {
               _emoteMgr.closeEmotes();
            }
            if(_playerWall.patternPopup.visible)
            {
               _playerWall.patternPopup.visible = false;
               _playerWall.patternBtn.downToUpState();
            }
            else
            {
               _playerWall.patternPopup.visible = true;
            }
         }
      }
      
      private function onColorBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_playerWall.patternPopup.visible)
            {
               _playerWall.patternPopup.visible = false;
               _playerWall.patternBtn.downToUpState();
            }
            SafeChatManager.closeSafeChat(_playerWall.chatTree);
            _playerWall.speedChatBtn.downToUpState();
            if(_emoteMgr)
            {
               _emoteMgr.closeEmotes();
            }
            if(_playerWall.colorPopup.visible)
            {
               _playerWall.colorPopup.visible = false;
               _playerWall.colorBtn.downToUpState();
            }
            else
            {
               _playerWall.colorPopup.visible = true;
            }
         }
      }
      
      private function onEmoteBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            SafeChatManager.closeSafeChat(_playerWall.chatTree);
            _playerWall.speedChatBtn.downToUpState();
            if(_playerWall.patternPopup.visible)
            {
               _playerWall.patternPopup.visible = false;
               _playerWall.patternBtn.downToUpState();
            }
            if(_playerWall.colorPopup.visible)
            {
               _playerWall.colorPopup.visible = false;
               _playerWall.colorBtn.downToUpState();
            }
         }
      }
      
      private function onSafeChatBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            if(param1.currentTarget.isGray)
            {
               return;
            }
         }
         if(_emoteMgr)
         {
            _emoteMgr.closeEmotes();
         }
         if(_playerWall.patternPopup.visible)
         {
            _playerWall.patternPopup.visible = false;
            _playerWall.patternBtn.downToUpState();
         }
         if(_playerWall.colorPopup.visible)
         {
            _playerWall.colorPopup.visible = false;
            _playerWall.colorBtn.downToUpState();
         }
         if(!_playerWall.speedChatBtn.isGray)
         {
            if(!_playerWall.chatTree.visible)
            {
               SafeChatManager.openSafeChat(false,_playerWall.chatTree);
            }
            else
            {
               SafeChatManager.closeSafeChat(_playerWall.chatTree);
            }
         }
      }
      
      private function onEmoteDown(param1:Sprite) : void
      {
         var _loc2_:String = null;
         if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha == 0.5)
         {
            _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
            _predictiveTextManager.resetTreeSearch();
         }
         if(_predictiveTextManager)
         {
            _loc2_ = EmoticonUtility.getEmoteString(param1);
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.text.length + _loc2_.length <= _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars)
            {
               _predictiveTextManager.addWordToPredictiveText(_loc2_);
               setTimeout(updateCharCount,41.666666666666664);
               gMainFrame.stage.focus = _playerWall.messageTxtCont.txtColorCont.messageTxt;
               _playerWall.speedChatBtn.activateGrayState(true);
            }
         }
      }
      
      private function onPostBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_predictiveTextManager)
         {
            _predictiveTextManager.onSendBtnDown(null);
         }
         else
         {
            onSendMessage(param1);
         }
      }
      
      private function onSettingsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _playerWall.settingsPopup.visible = !_playerWall.settingsPopup.visible;
         if(!_playerWall.settingsPopup.visible)
         {
            _playerWall.settingsBtn[_playerWall.settingsBtn.currentFrameLabel + "Btn"].downToUpState();
         }
         closeAllLowerPopups();
      }
      
      private function onWallDecorBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _playerWall.wallDecorCont.visible = !_playerWall.wallDecorCont.visible;
         _playerWall.masterpieceCont.visible = false;
         _playerWall.masterpieceBtn.downToUpState();
         if(!_playerWall.wallDecorCont.visible)
         {
            _playerWall.wallDecorBtn.downToUpState();
            PlayerWallXtCommManager.sendSetWallParameters(_owner,_wallParameters,null);
            SBTracker.trackPageview("/game/play/playerWall/#wallPaper/#null#" + _wallDecorItemIds[_wallParameters.bg],-1,1);
         }
         closeAllLowerPopups();
      }
      
      private function onMasterpieceBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _playerWall.masterpieceCont.visible = !_playerWall.masterpieceCont.visible;
         _playerWall.wallDecorCont.visible = false;
         _playerWall.wallDecorBtn.downToUpState();
         if(!_playerWall.masterpieceCont.visible)
         {
            _playerWall.masterpieceBtn.downToUpState();
            if(param1)
            {
               PlayerWallXtCommManager.sendSetWallParameters(_owner,_wallParameters,null);
            }
         }
         closeAllLowerPopups();
      }
      
      private function onMasterpieceFrameDown(param1:MouseEvent) : void
      {
         var _loc2_:MasterpieceDisplayItem = null;
         param1.stopPropagation();
         var _loc3_:MovieClip = param1.currentTarget as MovieClip;
         if(_loc3_ && _loc3_.itemLayer.numChildren > 1)
         {
            _loc2_ = _loc3_.itemLayer.getChildAt(_loc3_.itemLayer.numChildren - 1) as MasterpieceDisplayItem;
            if(_loc2_)
            {
               GuiManager.openMasterpiecePreview(_loc2_.uniqueImageId,_loc2_.uniqueImageCreator,_loc2_.uniqueImageCreatorDbId,_loc2_.uniqueImageCreatorUUID,_loc2_.versionId);
            }
         }
      }
      
      private function onMasterpieceFrameOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("mouse");
      }
      
      private function onMasterpieceFrameOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.gotoAndStop("out");
         param1.currentTarget.glow.visible = false;
      }
      
      private function onSuggestWordsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         FeedbackManager.openFeedbackPopup(18);
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
      
      private function onDecorMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = _currDecorIndex;
         if(param1)
         {
            param1.stopPropagation();
            _wallDecorWindows.mediaWindows[_loc2_].downToUpState();
            _loc2_ = int(param1.currentTarget.index);
            _currDecorIndex = _loc2_;
            _wallParameters.bg = _currDecorIndex;
         }
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_wallDecorItemIds[_loc2_],onWallDecorItemLoaded);
      }
      
      private function onMasterpieceMouseDown(param1:MouseEvent) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc7_:DenItem = null;
         var _loc3_:MasterpieceDisplayItem = null;
         var _loc2_:MasterpieceDisplayItem = null;
         param1.stopPropagation();
         if((param1.currentTarget as ItemWindowMasterpiece).inUse)
         {
            _loc7_ = (param1.currentTarget as ItemWindowMasterpiece).currItem;
            if(_loc7_)
            {
               _loc5_ = _playerWall.frame_0;
               _loc4_ = 0;
               while(_loc5_ != null)
               {
                  if(_loc5_.itemLayer.numChildren > 1)
                  {
                     _loc3_ = _loc5_.itemLayer.getChildAt(_loc5_.itemLayer.numChildren - 1) as MasterpieceDisplayItem;
                     if(_loc3_ && _loc7_.invIdx == _loc3_.invId)
                     {
                        _loc5_.itemLayer.removeChild(_loc3_);
                        if(_selectedMasterpieces)
                        {
                           for(var _loc6_:int in _selectedMasterpieces)
                           {
                              if(_selectedMasterpieces[_loc6_].iid == _loc7_.invIdx)
                              {
                                 delete _selectedMasterpieces[_loc6_];
                                 _wallParameters.mp = _selectedMasterpieces;
                                 break;
                              }
                           }
                        }
                        break;
                     }
                  }
                  if(_loc5_.loadingSpiral)
                  {
                     (_loc5_.loadingSpiral as LoadingSpiral).destroy();
                     delete _loc5_.loadingSpiral;
                  }
                  _loc4_++;
                  _loc5_ = _playerWall["frame_" + _loc4_];
               }
            }
            (param1.currentTarget as ItemWindowMasterpiece).inUse = false;
         }
         else
         {
            _loc2_ = param1.currentTarget.cloneCurrMasterpieceItem(onDragItemLoaded) as MasterpieceDisplayItem;
            _currDragMasterpiece = _loc2_;
            _dragStartPoint = new Point(param1.stageX,param1.stageY);
            _currDragMasterpiece.startDrag();
            _playerWall.addChild(_currDragMasterpiece);
            _playerWall.addEventListener("mouseUp",onMasterpieceMouseUp,false,0,true);
            _loc5_ = _playerWall.frame_0;
            _loc4_ = 0;
            while(_loc5_ != null)
            {
               _loc5_.gotoAndStop("out");
               _loc5_.glow.visible = true;
               _loc5_.mouseEnabled = false;
               _loc5_.mouseChildren = false;
               _loc4_++;
               _loc5_ = _playerWall["frame_" + _loc4_];
            }
            onMasterpieceBtn(null);
            (param1.currentTarget as ItemWindowMasterpiece).inUse = true;
         }
      }
      
      private function onDragItemLoaded(param1:MasterpieceDisplayItem) : void
      {
         var _loc3_:Point = null;
         var _loc2_:Number = NaN;
         if(_currDragMasterpiece)
         {
            _loc3_ = _playerWall.globalToLocal(_dragStartPoint);
            _currDragMasterpiece.x = _loc3_.x;
            _currDragMasterpiece.y = _loc3_.y;
            _loc2_ = _playerWall.frame_0.itemLayer.width / Math.max(_currDragMasterpiece.width,_currDragMasterpiece.height);
            _currDragMasterpiece.scaleX = _currDragMasterpiece.scaleY = _loc2_;
            _currDragMasterpiece.onLoadedCallback = null;
            if(_currDragMasterpiece.parent != _playerWall)
            {
               _currDragMasterpiece.x = _currDragMasterpiece.y = 0;
               _currDragMasterpiece = null;
            }
         }
      }
      
      private function onMasterpieceMouseUp(param1:MouseEvent) : void
      {
         var _loc8_:MovieClip = null;
         var _loc5_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc6_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Object = null;
         param1.stopPropagation();
         if(_currDragMasterpiece != null)
         {
            _currDragMasterpiece.stopDrag();
            _loc8_ = _playerWall.frame_0;
            _loc5_ = 0;
            _loc6_ = 2147483647;
            while(_loc8_ != null)
            {
               _loc2_ = Math.sqrt(Math.pow(_loc8_.x - _currDragMasterpiece.x,2) + Math.pow(_loc8_.y - _currDragMasterpiece.y,2));
               if(_loc2_ < _loc6_)
               {
                  _loc6_ = _loc2_;
                  _loc3_ = _loc8_;
               }
               _loc8_.glow.visible = false;
               _loc8_.gotoAndStop("out");
               _loc8_.mouseEnabled = true;
               _loc8_.mouseChildren = true;
               _loc5_++;
               _loc8_ = _playerWall["frame_" + _loc5_];
            }
            if(_selectedMasterpieces != null)
            {
               _selectedMasterpieces.push({
                  "iid":_currDragMasterpiece.invId,
                  "sid":int(_loc3_.name.split("_")[1])
               });
            }
            else
            {
               _selectedMasterpieces = [{
                  "iid":_currDragMasterpiece.invId,
                  "sid":int(_loc3_.name.split("_")[1])
               }];
            }
            if(_wallParameters)
            {
               _wallParameters.mp = _selectedMasterpieces;
            }
            else
            {
               _wallParameters = {"mp":_selectedMasterpieces};
            }
            while(_loc3_.itemLayer.numChildren > 1)
            {
               _loc4_ = _loc3_.itemLayer.getChildAt(_loc3_.itemLayer.numChildren - 1);
               if(_loc4_ is MasterpieceDisplayItem)
               {
                  for(var _loc9_:int in _selectedMasterpieces)
                  {
                     if(_selectedMasterpieces[_loc9_].iid == (_loc4_ as MasterpieceDisplayItem).invId)
                     {
                        for(var _loc7_:int in _masterpieceDiCollection.getCoreArray())
                        {
                           if(_masterpieceDiCollection.getDenItem(_loc7_).invIdx == _selectedMasterpieces[_loc9_].iid)
                           {
                              _masterpieceWindows.callUpdateOnWindowWithInput(_loc7_,false);
                              break;
                           }
                        }
                        delete _selectedMasterpieces[_loc9_];
                        break;
                     }
                  }
               }
               _loc3_.itemLayer.removeChildAt(_loc3_.itemLayer.numChildren - 1);
            }
            if(_loc3_.loadingSpiral)
            {
               (_loc3_.loadingSpiral as LoadingSpiral).destroy();
               delete _loc3_.loadingSpiral;
            }
            _loc3_.itemLayer.addChild(_currDragMasterpiece);
            _currDragMasterpiece.x = _currDragMasterpiece.y = 0;
            if(_currDragMasterpiece.hasLoaded)
            {
               _currDragMasterpiece = null;
            }
            onMasterpieceBtn(null);
         }
         _playerWall.removeEventListener("mouseUp",onMasterpieceMouseUp);
      }
      
      private function onWallDecorItemLoaded(param1:MovieClip) : void
      {
         if(_playerWall)
         {
            while(_playerWall.wallItemWindow.numChildren > 0)
            {
               _playerWall.wallItemWindow.removeChildAt(0);
            }
            _playerWall.wallItemWindow.addChild(param1.getChildAt(0));
            _hasLoadedDecor = true;
            if(_messagePatternLoaded)
            {
               displayLoadedWall();
            }
         }
      }
      
      private function onTimerEvent(param1:Event) : void
      {
         if(_playerWall && _postWindows)
         {
            _postWindows.callUpdateInWindow();
            _updateTimer.reset();
            _updateTimer.start();
         }
      }
      
      private function onMessageEntry(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(23230));
      }
      
      private function onPatternWindowsLoaded() : void
      {
         if(_playerWall)
         {
            _patternScrollBar = new SBScrollbar();
            _patternScrollBar.init(_patternWindows,_playerWall.patternPopup.itemWindow.width,_patternWindows.boxHeight * 8,3,"scrollbar2",_patternWindows.boxHeight,0);
         }
      }
      
      private function onDecorWindowsLoaded() : void
      {
         if(_playerWall)
         {
            _decorScrollBar = new SBScrollbar();
            _decorScrollBar.init(_wallDecorWindows,_playerWall.wallDecorCont.itemWindow.width,_wallDecorWindows.boxHeight * 4 + 20,0,"scrollbar2",_wallDecorWindows.boxHeight + 5,0);
         }
      }
      
      private function onDecorItemsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _wallDecorItemIds = param2;
            onDecorMouseDown(null);
         }
      }
      
      private function onMasterpieceFrameItemsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _masterpieceFrameIds = param2;
         }
      }
      
      private function onPatternLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         if(_playerWall)
         {
            param1 = MovieClip(param1.getChildAt(0)).swatchBtn.pattern;
            _patternIconIds = new Array(param1.currentLabels.length);
            _loc2_ = 0;
            while(_loc2_ < param1.currentLabels.length)
            {
               _patternIconIds[_loc2_] = 3983;
               _loc2_++;
            }
            setupPatterns();
         }
      }
      
      private function onSendMessage(param1:MouseEvent) : void
      {
         var _loc3_:Avatar = null;
         var _loc2_:PostMessage = null;
         if(!_playerWall.postBtn.isGray)
         {
            KeepAlive.restartTimeLeftTimer();
            _playerWall.postBtn.activateGrayState(true);
            if(canIKeepPosting())
            {
               _playerWall.speedChatBtn.activateGrayState(false);
               _playerWall.messageTxtCont.txtColorCont.charCounter.text = "0/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
               _loc3_ = AvatarManager.playerAvatar;
               _loc2_ = new PostMessage("0",_playerWall.messageTxtCont.txtColorCont.messageTxt.text,gMainFrame.clientInfo.dbUserId,gMainFrame.userInfo.myUserName,gMainFrame.userInfo.userNameModerated,_currPatternId,_myCurrColorId,new Date().valueOf(),false,_loc3_.avTypeId,_loc3_.colors,_loc3_.inUseEyeId,_loc3_.inUsePatternId,LocalizationManager.currentLanguage,_loc3_.customAvId);
               PlayerWallXtCommManager.sendPutToPlayerWall(_owner,_loc2_,_wallParameters,onMessageSent);
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(23231));
            }
         }
         else if(!_canWrite)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(23230));
         }
      }
      
      private function onMessageSent(param1:Boolean, param2:PostMessage, param3:int, param4:int, param5:String = "") : void
      {
         if(_playerWall)
         {
            if(param1)
            {
               _playerWall.noPostCont.visible = _inbox.length == 0;
            }
            else
            {
               if(param3 > 1 && param3 != 5)
               {
                  if(param3 != 4)
                  {
                     FacilitatorXtCommManager.showContextualWarningPopup(param4);
                  }
               }
               else if(param3 == -1)
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22628));
               }
               else if(param5)
               {
                  if(param5 == "token")
                  {
                     PlayerWallXtCommManager.sendWallTokenRequest(_owner,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                        "cmd":"PUT",
                        "username":_owner,
                        "msgToPost":param2,
                        "callback":onMessageSent
                     },true,true);
                  }
                  else if(param5 == "unavailable")
                  {
                     new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
                  }
               }
               else
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22628));
               }
               _playerWall.postBtn.activateGrayState(true);
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.resetTreeSearch();
            }
            else
            {
               _playerWall.messageTxtCont.txtColorCont.messageTxt.text = LocalizationManager.translateIdOnly(23140);
            }
            _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 0.5;
         }
      }
      
      private function onFirstTimeGet(param1:Boolean) : void
      {
         if(_playerWall)
         {
            KeepAlive.restartTimeLeftTimer();
            if(param1)
            {
               setupWallDecorPopup();
               setupMasterpiecePopup();
               setupMessageEntry();
               setupSettingsPopup(false,_privacyId);
               onSettingsChoose(null);
               addEventListeners();
               setupSafeChat();
               setupPatterns();
               setupColors();
               setupEmotePopup();
            }
         }
      }
      
      private function onPrivacySetResponse(param1:Boolean, param2:int) : void
      {
         if(_playerWall)
         {
            if(param1)
            {
               _privacyId = param2;
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14774));
            }
         }
      }
      
      private function checkShouldCompleteSuggestion(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Function = null) : void
      {
         checkShouldCompleteSuggestionWork(param1,param2,param3,param4);
      }
      
      private function checkShouldCompleteSuggestionWork(param1:String, param2:Boolean, param3:Boolean, param4:Function) : void
      {
         var _loc5_:TextField = null;
         var _loc6_:TextFormat = null;
         if(_playerWall)
         {
            if(param2)
            {
               if(_playerWall.messageTxtCont.txtColorCont.messageTxt.length > 0)
               {
                  _playerWall.postBtn.activateGrayState(!_predictiveTextManager.isValid());
               }
               else
               {
                  _playerWall.postBtn.activateGrayState(true);
               }
               return;
            }
            _loc5_ = new TextField();
            _loc6_ = _playerWall.messageTxtCont.txtColorCont.messageTxt.getTextFormat();
            _loc5_.text = _playerWall.messageTxtCont.txtColorCont.messageTxt.text + param1;
            _loc5_.setTextFormat(_loc6_);
            if(_loc5_.length > _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars)
            {
               if(param4 != null)
               {
                  param4(param1,param3,false);
               }
            }
            else if(param4 != null)
            {
               param4(param1,param3,true);
            }
         }
      }
      
      private function onDecorIconsLoaded(param1:int, param2:Array, param3:Array) : void
      {
         if(_playerWall)
         {
            _wallDecorIconIds = param2;
            setupWallDecorPopup();
         }
      }
      
      private function onMessagePatternLoaded(param1:MovieClip) : void
      {
         if(_playerWall && _messagePatternWindow)
         {
            _messagePatternLoaded = true;
            if(_hasLoadedDecor)
            {
               displayLoadedWall();
            }
         }
      }
      
      private function onTextChanged(param1:Event) : void
      {
         if(_playerWall && _predictiveTextManager)
         {
            _predictiveTextManager.onTextFieldChanged(param1);
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(_predictiveTextManager)
         {
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha != 1)
            {
               _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
               _playerWall.messageTxtCont.txtColorCont.messageTxt.text = "";
            }
            if(_predictiveTextManager)
            {
               _predictiveTextManager.onKeyDown(param1);
               setTimeout(updateCharCount,41.666666666666664);
            }
         }
         else if(!_playerWall.chatTree.visible)
         {
            SafeChatManager.openSafeChat(false,_playerWall.chatTree);
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14713));
         }
      }
      
      private function updateCharCount() : void
      {
         if(_playerWall)
         {
            _playerWall.messageTxtCont.txtColorCont.charCounter.visible = true;
            _playerWall.messageTxtCont.txtColorCont.charCounter.text = _playerWall.messageTxtCont.txtColorCont.messageTxt.text.length + "/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
            if(_playerWall.messageTxtCont.txtColorCont.messageTxt.length > 0)
            {
               _playerWall.postBtn.activateGrayState(!_predictiveTextManager.isValid());
            }
            else
            {
               _playerWall.postBtn.activateGrayState(true);
            }
         }
      }
      
      private function onSettingsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_wallSettingsRadioBtns.selected != _privacyId)
         {
            KeepAlive.restartTimeLeftTimer();
            PlayerWallXtCommManager.sendSetWallSettingsRequest(_wallSettingsRadioBtns.selected,onPrivacySetResponse);
         }
         onSettingsBtn(param1);
      }
      
      private function onSettingsChoose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _playerWall.settingsBtn.gotoAndStop(_wallSettingsRadioBtns.selected + 1);
         if(_playerWall.settingsPopup.visible)
         {
            _playerWall.settingsBtn[_playerWall.settingsBtn.currentFrameLabel + "Btn"].upToDownState();
         }
      }
      
      private function onWallDecorClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         onWallDecorBtn(param1);
      }
      
      private function onMasterpiecePopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         onMasterpieceBtn(param1);
      }
      
      private function onCreateAMasterpieceBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onMasterpieceBtn(param1);
         _masterpieceLaunchObj = {"typeDefId":51};
         if(!MinigameManager.minigameInfoCache.getMinigameInfo(_masterpieceLaunchObj.typeDefId))
         {
            DarkenManager.showLoadingSpiral(true);
            MinigameXtCommManager.sendMinigameInfoRequest([_masterpieceLaunchObj.typeDefId],false,onMinigameInfoResponse);
         }
         else
         {
            MinigameManager.handleGameClick(_masterpieceLaunchObj,null,true);
         }
      }
      
      private function onMinigameInfoResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         MinigameManager.handleGameClick(_masterpieceLaunchObj,null,true);
      }
      
      private function onChatTreeClose(param1:String, param2:String) : void
      {
         if(_predictiveTextManager)
         {
            _predictiveTextManager.resetTreeSearch();
         }
         _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
         _playerWall.messageTxtCont.txtColorCont.charCounter.visible = false;
         _playerWall.messageTxtCont.txtColorCont.charCounter.text = "0/" + _playerWall.messageTxtCont.txtColorCont.messageTxt.maxChars;
         _playerWall.messageTxtCont.txtColorCont.messageTxt.text = param1;
         _msgCode = param2;
         _playerWall.postBtn.activateGrayState(false);
         SafeChatManager.closeSafeChat(_playerWall.chatTree);
         onSendMessage(null);
         _playerWall.speedChatBtn.downToUpState();
         _playerWall.postBtn.activateGrayState(true);
         if(_predictiveTextManager)
         {
            _predictiveTextManager.resetTreeSearch();
         }
         _playerWall.messageTxtCont.txtColorCont.messageTxt.text = "";
         updateCharCount();
      }
      
      private function msgTextDownHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget == _playerWall.statusTxt)
         {
            _playerWall.statusTxt.setSelection(_playerWall.statusTxt.length,_playerWall.statusTxt.length);
            _playerWall.postStatusBtn.visible = true;
         }
         else
         {
            closeAllLowerPopups();
            if(!Utility.canChat())
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14713));
            }
            else if(!_playerWall.speedChatBtn.isGray && (gMainFrame.userInfo.sgChatType == 0 || gMainFrame.userInfo.sgChatType == 3))
            {
               onSafeChatBtn(null);
            }
            else if(_playerWall.messageTxtCont.txtColorCont.messageTxt.alpha != 1)
            {
               _playerWall.messageTxtCont.txtColorCont.messageTxt.alpha = 1;
               _predictiveTextManager.resetTreeSearch();
            }
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
      
      private function onMessageTextDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _predictiveTextManager.onTextClick();
      }
      
      private function onClearPostsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            new SBOkCancelPopup(_guiLayer,LocalizationManager.translateIdOnly(24689),true,onConfirmClear);
         }
      }
      
      private function onConfirmClear(param1:Object) : void
      {
         if(param1.status)
         {
            _playerWall.contentLoader.visible = true;
            PlayerWallXtCommManager.sendClearAllMessages(null);
         }
      }
      
      private function addEventListeners() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         if(_playerWall)
         {
            _playerWall.addEventListener("mouseDown",onPopup,false,0,true);
            _playerWall.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
            _playerWall.patternBtn.addEventListener("mouseDown",onPatternBtn,false,0,true);
            _playerWall.colorBtn.addEventListener("mouseDown",onColorBtn,false,0,true);
            _playerWall.emoteBtn.addEventListener("mouseDown",onEmoteBtn,false,0,true);
            _playerWall.postBtn.addEventListener("mouseDown",onPostBtn,false,0,true);
            _playerWall.settingsBtn.addEventListener("mouseDown",onSettingsBtn,false,0,true);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.addEventListener("mouseDown",onMessageTextDown,false,0,true);
            _playerWall.speedChatBtn.addEventListener("mouseDown",onSafeChatBtn,false,0,true);
            _playerWall.wallDecorBtn.addEventListener("mouseDown",onWallDecorBtn,false,0,true);
            _playerWall.masterpieceBtn.addEventListener("mouseDown",onMasterpieceBtn,false,0,true);
            _playerWall.ansBtnCont.addEventListener("mouseDown",onSuggestWordsBtn,false,0,true);
            _playerWall.cleanUpBtn.addEventListener("mouseDown",onClearPostsBtn,false,0,true);
            _updateTimer.addEventListener("timer",onTimerEvent,false,0,true);
            if(!_canWrite)
            {
               _playerWall.messageEntryHolder.addEventListener("mouseDown",onMessageEntry,false,0,true);
            }
            _loc2_ = _playerWall.frame_0;
            _loc1_ = 0;
            while(_loc2_ != null)
            {
               _loc2_.addEventListener("mouseDown",onMasterpieceFrameDown,false,0,true);
               _loc2_.addEventListener("mouseOver",onMasterpieceFrameOver,false,0,true);
               _loc2_.addEventListener("mouseOut",onMasterpieceFrameOut,false,0,true);
               _loc2_.glow.visible = false;
               _loc1_++;
               _loc2_ = _playerWall["frame_" + _loc1_];
            }
         }
      }
      
      private function removeEventListeners() : void
      {
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         if(_playerWall)
         {
            _playerWall.removeEventListener("mouseDown",onPopup);
            _playerWall.bx.removeEventListener("mouseDown",onCloseBtn);
            _playerWall.patternBtn.removeEventListener("mouseDown",onPatternBtn);
            _playerWall.colorBtn.removeEventListener("mouseDown",onColorBtn);
            _playerWall.emoteBtn.removeEventListener("mouseDown",onEmoteBtn);
            _playerWall.postBtn.removeEventListener("mouseDown",onPostBtn);
            _playerWall.settingsBtn.removeEventListener("mouseDown",onSettingsBtn);
            _playerWall.messageTxtCont.txtColorCont.messageTxt.removeEventListener("mouseDown",onMessageTextDown);
            _playerWall.speedChatBtn.removeEventListener("mouseDown",onSafeChatBtn);
            _playerWall.wallDecorBtn.removeEventListener("mouseDown",onWallDecorBtn);
            _playerWall.masterpieceBtn.removeEventListener("mouseDown",onMasterpieceBtn);
            _playerWall.ansBtnCont.removeEventListener("mouseDown",onSuggestWordsBtn);
            _playerWall.cleanUpBtn.removeEventListener("mouseDown",onClearPostsBtn);
            _updateTimer.removeEventListener("timer",onTimerEvent);
            if(!_canWrite)
            {
               _playerWall.messageEntryHolder.removeEventListener("mouseDown",onMessageEntry);
            }
            _loc2_ = _playerWall.frame_0;
            _loc1_ = 0;
            while(_loc2_ != null)
            {
               _loc2_.removeEventListener("mouseDown",onMasterpieceFrameDown);
               _loc2_.removeEventListener("mouseOver",onMasterpieceFrameOver);
               _loc2_.removeEventListener("mouseOut",onMasterpieceFrameOut);
               _loc1_++;
               _loc2_ = _playerWall["frame_" + _loc1_];
            }
         }
      }
   }
}

