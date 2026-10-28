package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserCommXtCommManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.SortLayer;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.popup.*;
   import den.DenItem;
   import den.DenXtCommManager;
   import ecard.ECardManager;
   import flash.display.*;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.net.SharedObject;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import loader.DenItemHelper;
   import loader.MediaHelper;
   import movie.VideoPlayer;
   import pet.PetManager;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public final class GuiManager
   {
      
      public static var mainHud:MovieClip;
      
      public static var chatHist:ChatHistory;
      
      public static var actionMgr:ActionManager;
      
      public static var emoteMgr:EmoticonManager;
      
      public static var volumeMgr:VolumeSelector;
      
      public static var denEditor:DenEditor;
      
      public static var guiLayer:DisplayLayer;
      
      public static var fpsLayer:DisplayLayer;
      
      public static var worldLayer:SortLayer;
      
      public static var chatLayer:DisplayLayer;
      
      public static var bgLayer:DisplayLayer;
      
      public static var toolTip:ToolTipPopup;
      
      public static var toolTipBigGems:ToolTipBigPopup;
      
      public static var toolTipBigTickets:ToolTipBigPopup;
      
      public static var toolTipBigDiamonds:ToolTipBigPopup;
      
      public static var wasInFFM:Boolean;
      
      private static var _currRoomDisplayName:String;
      
      private static var _room:String;
      
      private static var _hudAvtView:AvatarView;
      
      private static var _avEditor:AvatarEditor;
      
      private static var _avtSwitcher:AvatarSwitcher;
      
      private static var _denSwitcher:DenSwitcher;
      
      private static var _mySettings:MySettings;
      
      private static var _reportAPlayer:ReportAPlayer;
      
      private static var _firstFiveMinutes:FirstFiveMinutes;
      
      private static var _achievementViewer:AchievementViewer;
      
      private static var _startupPopups:StartupPopups;
      
      private static var _jammerCentral:BulletinBoard;
      
      private static var _gemBonusWheel:GemBonusSpinWheel;
      
      private static var _dailyGiftManager:DailyGiftManager;
      
      private static var _museumDonation:MuseumDonation;
      
      private static var _playerEngagement:PlayerEngagement;
      
      private static var _photoBooth:PhotoBooth;
      
      private static var _diamondConfirmationPopup:MovieClip;
      
      private static var _diamondShopInfoPopup:MovieClip;
      
      private static var _demotionMessage:DemotionMessages;
      
      private static var _scrollButtons:MovieClip;
      
      private static var _videoPlayer:VideoPlayer;
      
      private static var _pageFlip:PageFlip;
      
      private static var SwapPopupContent:Class;
      
      private static var NewsPopupContent:Class;
      
      private static var AwardsPopupContent:Class;
      
      private static var TimerPopupContent:Class;
      
      private static var ReportPopupContent:Class;
      
      private static var _swap:MovieClip;
      
      private static var _swapPopup:SBPopup;
      
      private static var _awards:MovieClip;
      
      private static var _awardsPopup:SBPopup;
      
      private static var _timer:MovieClip;
      
      private static var _timerPopup:SBPopup;
      
      private static var _report:MovieClip;
      
      private static var _reportPopup:SBPopup;
      
      private static var _rulesPopup:SBPopup;
      
      private static var _gemsGlowTimer:Timer;
      
      private static var _tooManyGemsPopup:SBPopup;
      
      private static var _commands:Array;
      
      private static var _initialCommands:Array;
      
      private static var _denCommands:Array;
      
      private static var _clothesCommands:Array;
      
      private static var _furnitureCommands:Array;
      
      private static var _eCardCommands:Array;
      
      private static var _availShards:Array;
      
      private static var _ffmCallback:Function;
      
      private static var _avEditorCloseCallback:Function;
      
      private static var _diamondMediaHelper:MediaHelper;
      
      private static var _heartItemWindow:WindowGenerator;
      
      private static var _giftPopup:GiftPopup;
      
      private static var _prizeOkPopup:SBOkPopup;
      
      private static var _prizeData:Object;
      
      private static var _prizeDenItemHelper:DenItemHelper;
      
      private static var _prizeImg:Sprite;
      
      private static var _currentBookId:int;
      
      private static var _isRectangularEBook:Boolean;
      
      private static var _lionMediaHelper:MediaHelper;
      
      private static var _lionFoundPopup:MovieClip;
      
      private static var _lizaCommands:Array;
      
      private static var _secondFFM:FirstFiveMinutes;
      
      private static var _lizaLoder:MediaHelper;
      
      private static var _lizaMC:MovieClip;
      
      public static var ffmProcessAgainCallback:Function;
      
      public static var ffmDenCommands:Boolean;
      
      public static var ffmClothesCommands:Boolean;
      
      public static var ffmFurnitureCommmands:Boolean;
      
      public static var ffmECardCommands:Boolean;
      
      private static var _newsOpenedFromBtn:Boolean;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _reconnecting:Boolean;
      
      private static var _hasClosedGemBonus:Boolean;
      
      private static var _namebarBadgeList:Array;
      
      private static var _sharedObj:SharedObject;
      
      private static const DAILY_GIFT_NUM_DAYS:int = 25;
      
      private static const MAX_GEMS:int = 1000;
      
      private static const JB_LIST_ID:int = 53;
      
      private static const NEWSPAPER_LIST_ID:int = 34;
      
      private static const DIAMOND_SHOP_INFO:int = 2222;
      
      public static const FFM_DEN:int = 1;
      
      public static const FFM_MAP:int = 2;
      
      public static const FFM_MAIL:int = 3;
      
      public static const FFM_BUDDYLIST:int = 4;
      
      public static const FFM_NEWS:int = 5;
      
      public static const FFM_SWAP:int = 6;
      
      public static const FFM_SHOP:int = 7;
      
      public static const FFM_DEN_CUSTOMIZE:int = 8;
      
      public static const FFM_DEN_COMMANDS:int = 9;
      
      public static const FFM_CLOTHES_COMMANDS:int = 10;
      
      public static const FFM_FURNITURE_COMMANDS:int = 11;
      
      public static const FFM_ECARD_COMMANDS:int = 12;
      
      public static const SECOND_FFM_RUNNING:int = 13;
      
      public static const NAME_BAR_ICONS_LIST_ID:int = 110;
      
      public static var _originalHudFrame:int = -1;
      
      public static var secondFFMRunning:Boolean = false;
      
      public static var ffmDen:Boolean = false;
      
      public static var ffmMap:Boolean = false;
      
      public static var ffmMail:Boolean = false;
      
      public static var ffmBuddyList:Boolean = false;
      
      public static var ffmNews:Boolean = false;
      
      public static var ffmSwap:Boolean = false;
      
      public static var ffmShopBtn:Boolean = false;
      
      public static var ffmDenCustomizeBtn:Boolean = false;
      
      public static var ffmLoopAmountHolder:int = 0;
      
      public static var ffmFarthestSet:int = 0;
      
      private static var _namebarBadgeDefs:Object = new Object();
      
      public function GuiManager()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:DisplayLayer, param3:SortLayer, param4:DisplayLayer, param5:DisplayLayer, param6:Function) : void
      {
         _roomMgr = RoomManagerWorld.instance;
         DarkenManager.init(param1);
         SBPopupManager.darken = DarkenManager.darken;
         SBPopupManager.lighten = DarkenManager.unDarken;
         DarkenManager.setFocus = param6;
         guiLayer = param1;
         fpsLayer = param2;
         worldLayer = param3;
         chatLayer = param4;
         bgLayer = param5;
         mainHud = new (getDefinitionByName("MainHud") as Class)();
         mainHud.x = 6;
         mainHud.y = 5;
         mainHud.cacheAsBitmap = true;
         mainHud.safeChatTreeWindow.visible = false;
         mainHud.actionsWindow.visible = false;
         mainHud.emotesWindow.visible = false;
         if(mainHud.swapBtn.hasGrayState)
         {
            mainHud.swapBtn.activateGrayState(false);
         }
         mainHud.mainBlock.visible = false;
         mainHud.gemsBtnBlock.visible = false;
         mainHud.charWindowBlock.visible = false;
         _gemsGlowTimer = new Timer(5000);
         mainHud.gemsBtn.glow.visible = false;
         mainHud.awardsBtn.glow.visible = false;
         mainHud.newsBtn.glow.visible = false;
         mainHud.book.glow.visible = false;
         mainHud.book.gift.visible = false;
         mainHud.partyBtn.glow.visible = false;
         mainHud.playerWallBtn.glow.visible = false;
         mainHud.playerWallBtn.visible = false;
         guiLayer.addChild(mainHud);
         chatHist = new ChatHistory(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,UserCommXtCommManager.onSendMessage,mainHud.predictTxtTag);
         SafeChatManager.init(UserCommXtCommManager.sendAvatarSafeChat,mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
         emoteMgr = new EmoticonManager(onEmoteClick,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
         actionMgr = new ActionManager(UserCommXtCommManager.sendAvatarAction,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
         mainHud.furnBtn.visible = false;
         mainHud.mySettingsBtn.glow.visible = false;
         if(mainHud.mySettingsBtn.hasGrayState)
         {
            mainHud.mySettingsBtn.activateGrayState(false);
         }
         if(mainHud.reportBtn.hasGrayState)
         {
            mainHud.reportBtn.activateGrayState(false);
         }
         if(gMainFrame.clientInfo["firstTime"])
         {
            mainHud.charHelp.addEventListener(MouseEvent.MOUSE_DOWN,helpMouseDownHandler,false,0,true);
            mainHud.worldHelp.addEventListener(MouseEvent.MOUSE_DOWN,helpMouseDownHandler,false,0,true);
            mainHud.worldHelp["help_txt"].text = "Click here to see a map of the world";
         }
         else
         {
            mainHud.charHelp.visible = false;
            mainHud.worldHelp.visible = false;
         }
         volumeMgr = new VolumeSelector();
         volumeMgr.VolumeSelctor(guiLayer);
         volumeMgr.enable(true,mainHud.worldMapBtn,mainHud.zoneName,mainHud.worldHelp);
         InstructionScreenBuilder.init(guiLayer);
         setupChatHistoryAndEmotePrivs();
         addListeners();
         UpsellManager.init(guiLayer,PetManager.getPetInventoryMax);
         _availShards = [];
         setToolTipText();
         toolTip = new (getDefinitionByName("Tooltip") as Class)();
         toolTipBigGems = new (getDefinitionByName("TooltipBig") as Class)();
         toolTipBigTickets = new (getDefinitionByName("TooltipBig") as Class)();
         toolTipBigDiamonds = new (getDefinitionByName("TooltipBig") as Class)();
         _achievementViewer = new AchievementViewer();
         _achievementViewer.loadMedia(287);
         setupSoundButton();
         var _loc7_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc7_.init(DefPacksDefHelper.DEF_NAMEBAR_BADGE,namebarBadgeDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NAMEBAR_BADGE] = _loc7_;
      }
      
      public static function setupSharedObject() : void
      {
         _sharedObj = null;
         if(gMainFrame.myFlashVarUserName != null)
         {
            try
            {
               _sharedObj = SharedObject.getLocal(gMainFrame.myFlashVarUserName);
               if(_sharedObj.data.cursor == null || _sharedObj.data.cursor == "custom")
               {
                  CursorManager.switchToCursor(CursorManager.CUSTOM_CURSOR);
               }
            }
            catch(e:Error)
            {
               CursorManager.switchToCursor(CursorManager.CUSTOM_CURSOR);
               _sharedObj = null;
            }
         }
         AJAudio.setupSharedObject(_sharedObj);
      }
      
      public static function setupSoundButton() : void
      {
         if(SBAudio.isMusicMuted || SBAudio.areSoundsMuted)
         {
            depressSoundButton(true);
         }
      }
      
      public static function setSharedObj(param1:String, param2:*) : void
      {
         if(_sharedObj != null)
         {
            switch(param1)
            {
               case "cursor":
                  if(_sharedObj.data.cursor != param2)
                  {
                     _sharedObj.data.cursor = param2;
                  }
                  break;
               case "msgColor":
                  if(_sharedObj.data.msgColor != param2)
                  {
                     _sharedObj.data.msgColor = param2;
                  }
                  break;
               case "msgPattern":
                  if(_sharedObj.data.msgPattern != param2)
                  {
                     _sharedObj.data.msgPattern = param2;
                  }
                  break;
               case "expiration":
                  if(_sharedObj.data.expiration != param2)
                  {
                     _sharedObj.data.expiration = param2;
                  }
            }
            try
            {
               _sharedObj.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function get sharedObj() : SharedObject
      {
         return _sharedObj;
      }
      
      public static function setupChatHistoryAndEmotePrivs() : void
      {
         var _loc1_:Boolean = true;
         if(Boolean(gMainFrame.userInfo.isSilenced) || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_BUBBLE || gMainFrame.userInfo.sgChatType == ChatHistory.SG_CHAT_TYPE_RESTR_BUBBLE)
         {
            _loc1_ = false;
         }
         chatHist.resetChatPrivs();
         emoteMgr.resetEmotePrivs();
      }
      
      public static function startFFM(param1:Boolean = false) : void
      {
         _lizaLoder = new MediaHelper();
         _lizaLoder.init(1864,onLizaLoaded);
         mainHud.newsBtn.glow.visible = false;
      }
      
      private static function onLizaLoaded(param1:MovieClip) : void
      {
         _lizaMC = param1;
         _lizaMC.setStateByScript("firstFive");
         RoomXtCommManager.sendRoomFFMRequest(rfCallback);
      }
      
      private static function rfCallback() : void
      {
         _roomMgr.callback_FFMRoomAssetsLoaded = ffmAssetsLoadedCallback;
         var _loc1_:String = "ffm" + gMainFrame.userInfo.myUserName;
         RoomXtCommManager.sendNonDenRoomJoinRequest(_loc1_);
         mainHud.mainBlock.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
         mainHud.mainBlock.addEventListener(MouseEvent.ROLL_OVER,blockMouseHandler,false,0,true);
         mainHud.mainBlock.addEventListener(MouseEvent.ROLL_OUT,blockMouseHandler,false,0,true);
         mainHud.gemsBtnBlock.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
         mainHud.gemsBtnBlock.addEventListener(MouseEvent.ROLL_OVER,blockMouseHandler,false,0,true);
         mainHud.gemsBtnBlock.addEventListener(MouseEvent.ROLL_OUT,blockMouseHandler,false,0,true);
         mainHud.charWindowBlock.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
         mainHud.charWindowBlock.addEventListener(MouseEvent.ROLL_OVER,blockMouseHandler,false,0,true);
         mainHud.charWindowBlock.addEventListener(MouseEvent.ROLL_OUT,blockMouseHandler,false,0,true);
      }
      
      private static function ffmAssetsLoadedCallback() : void
      {
         _lizaCommands = [];
         _lizaCommands = [[{
            "cmd":"delay",
            "sec":0.1,
            "type":"standAlone"
         },{
            "cmd":"visibility",
            "src":mainHud.mainBlock,
            "visibility":true,
            "revert":false
         },{
            "cmd":"visibility",
            "src":mainHud.gemsBtnBlock,
            "visibility":true,
            "revert":false
         },{
            "cmd":"visibility",
            "src":mainHud.charWindowBlock,
            "visibility":true,
            "revert":false
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.GO_HERE_MEDIA_ID
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.SKIP_BUTTON
         }],[{
            "cmd":"shaman",
            "x":830,
            "y":575
         },{
            "cmd":"delay",
            "sec":0.4,
            "type":"standAlone"
         }],[{
            "cmd":"playStream",
            "src":"12",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Welcome to Jamaa.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":1
         }],[{
            "cmd":"playStream",
            "src":"25",
            "mustFinish":true,
            "advances":false,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Click the mouse to move close to me.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.GO_HERE_MEDIA_ID,
            "type":"mediaId",
            "goHere":true,
            "visibility":true,
            "revert":true
         },{
            "cmd":"advanceOnEvent",
            "src":"volume",
            "event":"volume",
            "type":"volume"
         }],[{
            "cmd":"playStream",
            "src":"43",
            "advances":true,
            "volume":0.2
         },{
            "cmd":"popup",
            "txt":"Click the mouse to move close to me.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":false
         }],[{
            "cmd":"playStream",
            "src":"18",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Hello there!",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.2
         }],[{
            "cmd":"visibility",
            "src":FirstFiveMinutes.MIRA_HIGHLIGHT_MEDIA_ID,
            "type":"mediaId",
            "visibility":false
         },{
            "cmd":"playStream",
            "src":"23",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Every animal in Jamaa is special.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.2
         }],[{
            "cmd":"playStream",
            "src":"7",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"You should spend some time making yourself unique.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.CHAR_WINDOW_MEDIA_ID
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.ARROW_D_MEDIA_ID
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.ARROW_U_MEDIA_ID
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.ARROW_L_MEDIA_ID
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.ARROW_R_MEDIA_ID
         },{
            "cmd":"delay",
            "sec":0.5
         }],[{
            "cmd":"playStream",
            "src":"29",
            "advances":false,
            "mustFinish":true,
            "repeatAfter":10,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Click on the animal picture to do so.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":false
         },{
            "cmd":"arrow",
            "dir":"down",
            "layer":"gui",
            "src":mainHud.charWindow,
            "visibility":true,
            "x":4,
            "y":-60,
            "revert":true
         },{
            "cmd":"visibility",
            "src":mainHud.charWindowBlock,
            "visibility":false,
            "revert":true
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.CHAR_WINDOW_MEDIA_ID,
            "type":"mediaId",
            "layer":"gui",
            "x":0,
            "y":0,
            "visibility":true,
            "revert":true
         },{
            "cmd":"advanceOnEvent",
            "src":mainHud.charWindow,
            "event":MouseEvent.MOUSE_DOWN,
            "type":"callback"
         }],[{
            "cmd":"playStream",
            "src":"19",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Great job!",
            "x":149,
            "y":319,
            "delay":true
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.COLOR_TAB_HIGHLIGHT_MEDIA_ID
         },{
            "cmd":"delay",
            "sec":1
         }],[{
            "cmd":"playStream",
            "src":"28",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"playSound",
            "src":"subMenuClick"
         },{
            "cmd":"popup",
            "txt":"Click on the color tab to change your colors.",
            "x":149,
            "y":345,
            "delay":true
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.COLOR_TAB_HIGHLIGHT_MEDIA_ID,
            "visibility":true,
            "type":"mediaId",
            "layer":"gui",
            "x":3,
            "y":28,
            "revert":false
         },{
            "cmd":"arrow",
            "dir":"down",
            "visibility":true,
            "x":660,
            "y":115,
            "revert":false
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.EYE_TAB_HIGHLIGHT_MEDIA_ID
         },{
            "cmd":"delay",
            "sec":1
         }],[{
            "cmd":"visibility",
            "src":FirstFiveMinutes.COLOR_TAB_HIGHLIGHT_MEDIA_ID,
            "visibility":false,
            "type":"mediaId",
            "layer":"gui",
            "revert":false
         },{
            "cmd":"playStream",
            "src":"27",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"playSound",
            "src":"subMenuClick"
         },{
            "cmd":"popup",
            "txt":"Click on the eye tab to change the shape and color of your eyes.",
            "x":149,
            "y":358,
            "delay":true
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.EYE_TAB_HIGHLIGHT_MEDIA_ID,
            "visibility":true,
            "type":"mediaId",
            "layer":"gui",
            "x":3,
            "y":28,
            "revert":false
         },{
            "cmd":"functionCall",
            "src":FirstFiveMinutes.EYE_FUNCTION_ID,
            "param":AvatarEditor.EYE_TAB_ID
         },{
            "cmd":"arrow",
            "dir":"down",
            "visibility":true,
            "x":743,
            "y":115,
            "revert":false
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.PATTERN_TAB_HIGHLIGHT_MEDIA_ID
         },{
            "cmd":"delay",
            "sec":1
         }],[{
            "cmd":"visibility",
            "src":FirstFiveMinutes.EYE_TAB_HIGHLIGHT_MEDIA_ID,
            "visibility":false,
            "type":"mediaId",
            "layer":"gui",
            "x":3,
            "y":28,
            "revert":false
         },{
            "cmd":"playStream",
            "src":"26",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"playSound",
            "src":"subMenuClick"
         },{
            "cmd":"popup",
            "txt":"Click on the pattern tab to change the shape and color of your pattern.",
            "x":149,
            "y":358,
            "delay":true
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.PATTERN_TAB_HIGHLIGHT_MEDIA_ID,
            "visibility":true,
            "type":"mediaId",
            "layer":"gui",
            "x":3,
            "y":28,
            "revert":false
         },{
            "cmd":"functionCall",
            "src":FirstFiveMinutes.PATTERN_FUNCTION_ID,
            "param":AvatarEditor.PATTERN_TAB_ID
         },{
            "cmd":"arrow",
            "dir":"down",
            "visibility":true,
            "x":822,
            "y":115,
            "revert":false
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID
         },{
            "cmd":"delay",
            "sec":1
         }],[{
            "cmd":"visibility",
            "src":FirstFiveMinutes.PATTERN_TAB_HIGHLIGHT_MEDIA_ID,
            "visibility":false,
            "type":"mediaId",
            "layer":"gui",
            "x":3,
            "y":28,
            "revert":false
         },{
            "cmd":"arrow",
            "dir":"down",
            "visibility":false,
            "revert":false
         },{
            "cmd":"playStream",
            "src":"10",
            "advances":false,
            "repeatAfter":30,
            "shamanTalk":true
         },{
            "cmd":"playSound",
            "src":"subMenuClick"
         },{
            "cmd":"popup",
            "txt":"When you love how you look, click on the X in the corner to exit.",
            "x":149,
            "y":358,
            "delay":false
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.AVATAR_EDITOR_BLOCK,
            "visibility":false,
            "type":"mediaId",
            "revert":false
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.AVATAR_EDITOR_X_BTN_HIGHLIGHT_MEDIA_ID,
            "type":"mediaId",
            "layer":"gui",
            "x":0,
            "y":0,
            "visibility":true,
            "revert":true
         },{
            "cmd":"functionCall",
            "src":FirstFiveMinutes.COLOR_FUNCTION_ID,
            "param":AvatarEditor.COLOR_TAB_ID
         },{
            "cmd":"arrow",
            "dir":"right",
            "visibility":true,
            "x":800,
            "y":35,
            "revert":true
         },{
            "cmd":"advanceOnEvent",
            "src":FirstFiveMinutes.AVATAR_EDITOR_X_BTN,
            "event":MouseEvent.MOUSE_DOWN,
            "type":"mediaId"
         }],[{
            "cmd":"playStream",
            "src":"22",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Excellent work!",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.8
         }],[{
            "cmd":"playStream",
            "src":"30",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"By changing your colors, you just earned your first achievement!",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":false
         },{
            "cmd":"preload",
            "src":FirstFiveMinutes.ACHIEVEMENT_POPUP_MEDIA_ID
         },{
            "cmd":"delay",
            "sec":0.2
         }],[{
            "cmd":"playStream",
            "src":"33",
            "advances":false,
            "shamanTalk":false
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.ACHIEVEMENT_POPUP_MEDIA_ID,
            "visibility":true,
            "type":"mediaIdAnimated",
            "revert":true
         },{
            "cmd":"delay",
            "sec":3,
            "type":"standAlone"
         }],[{
            "cmd":"delay",
            "sec":0.5,
            "type":"standAlone"
         }],[{
            "cmd":"playStream",
            "src":"32",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Achievements are awards you can earn by doing special things around Jamaa.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.8
         }],[{
            "cmd":"playStream",
            "src":"9",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"visibility",
            "src":FirstFiveMinutes.ACHIEVEMENT_POPUP_MEDIA_ID,
            "visibility":false,
            "type":"mediaId",
            "revert":false
         },{
            "cmd":"popup",
            "txt":"You have done so well in your training so far.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.5
         }],[{
            "cmd":"playStream",
            "src":"16",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"I\'m so proud of you that I want to give you some gems.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.5
         }],[{
            "cmd":"playStream",
            "src":"21",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Gems can be used to buy clothes, furniture, and all sorts of neat things in Jamaa.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.5
         }],[{
            "cmd":"playStream",
            "src":"14",
            "advances":false,
            "mustFinish":true,
            "shamanTalk":true
         },{
            "cmd":"playSound",
            "src":"gemsEarned"
         },{
            "cmd":"popup",
            "txt":"Point to the gems at the top to see how many you have.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"visibility",
            "src":mainHud.gemsBtnBlock,
            "visibility":false,
            "revert":false
         },{
            "cmd":"visibility",
            "src":mainHud.gemsBtn.glow,
            "visibility":true,
            "revert":false
         },{
            "cmd":"arrow",
            "src":mainHud.gemsBtn,
            "dir":"left",
            "visibility":true,
            "x":40,
            "y":-10,
            "revert":true
         },{
            "cmd":"advanceOnEvent",
            "src":mainHud.gemsBtn,
            "event":MouseEvent.ROLL_OVER,
            "type":"mc"
         },{
            "cmd":"delay",
            "sec":0.5
         }],[{
            "cmd":"playStream",
            "src":"8",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Your training is finished for now.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"visibility",
            "src":mainHud.gemsBtn.glow,
            "visibility":false
         },{
            "cmd":"delay",
            "sec":0.2
         }],[{
            "cmd":"playStream",
            "src":"15",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"I think you\'re ready to discover Jamaa.",
            "type":"chat",
            "x":620,
            "y":340,
            "delay":true
         },{
            "cmd":"delay",
            "sec":0.8
         }],[{
            "cmd":"playStream",
            "src":"20",
            "advances":true,
            "shamanTalk":true
         },{
            "cmd":"popup",
            "txt":"Good luck on all your adventures!",
            "type":"chat",
            "x":620,
            "y":340
         },{
            "cmd":"delay",
            "sec":0.5
         }]];
         _firstFiveMinutes = new FirstFiveMinutes();
         _firstFiveMinutes.init(_lizaCommands,_lizaMC,guiLayer,worldLayer,chatLayer,ffmDoneCallback);
      }
      
      private static function ffmDoneCallback() : void
      {
         AvatarXtCommManager.sendAvatarFiveMinutesUpdate([0]);
         gMainFrame.userInfo.firstFiveMinutes = 1;
         wasInFFM = true;
         _roomMgr.callback_FFMRoomAssetsLoaded = null;
         mainHud.mainBlock.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         mainHud.mainBlock.removeEventListener(MouseEvent.ROLL_OVER,blockMouseHandler);
         mainHud.mainBlock.removeEventListener(MouseEvent.ROLL_OUT,blockMouseHandler);
         mainHud.gemsBtnBlock.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         mainHud.gemsBtnBlock.removeEventListener(MouseEvent.ROLL_OVER,blockMouseHandler);
         mainHud.gemsBtnBlock.removeEventListener(MouseEvent.ROLL_OUT,blockMouseHandler);
         mainHud.charWindowBlock.removeEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler);
         mainHud.charWindowBlock.removeEventListener(MouseEvent.ROLL_OVER,blockMouseHandler);
         mainHud.charWindowBlock.removeEventListener(MouseEvent.ROLL_OUT,blockMouseHandler);
         mainHud.mainBlock.visible = false;
         mainHud.gemsBtnBlock.visible = false;
         mainHud.charWindowBlock.visible = false;
         _firstFiveMinutes.destroy();
         _firstFiveMinutes = null;
         if(_lizaMC)
         {
            _lizaMC = null;
         }
         secondFFMRunning = false;
         _roomMgr.callback_FFMRoomAssetsLoaded = startSecondFFHCallback;
         _roomMgr.setGotoSpawnPoint("ff1");
         RoomXtCommManager.sendNonDenRoomJoinRequest("jamaa_township.room_main#" + _roomMgr.shardId);
      }
      
      public static function startSecondFFM() : void
      {
         if(!secondFFMRunning)
         {
            secondFFMRunning = true;
            ffmDen = true;
            ffmMap = true;
            ffmMail = true;
            ffmBuddyList = true;
            ffmNews = true;
            ffmSwap = true;
            ffmShopBtn = true;
            ffmDenCustomizeBtn = true;
            _roomMgr.callback_FFMRoomAssetsLoaded = startSecondFFHCallback;
            startSecondFFHCallback();
         }
      }
      
      public static function startSecondFFHCallback() : void
      {
         mainHud.newsBtn.glow.visible = true;
         if(secondFFMRunning)
         {
            _denCommands = new Array();
            _clothesCommands = new Array();
            _furnitureCommands = new Array();
            _eCardCommands = new Array();
            if(!ffmDenCommands)
            {
               DenEditor.closeCallback = activateDeactivateCallback;
               _denCommands.push([{
                  "cmd":"delay",
                  "sec":0.5,
                  "type":"standAlone"
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to DECORATE your den",
                  "type":"helpBubble",
                  "x":640,
                  "y":380,
                  "top":false,
                  "left":false,
                  "delay":false,
                  "btn":"ffmShopBtn"
               },{
                  "cmd":"playStream",
                  "src":"49",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               },{
                  "cmd":"advanceOnEvent",
                  "src":mainHud.furnBtn,
                  "event":MouseEvent.MOUSE_DOWN,
                  "type":"mc"
               },{
                  "cmd":"delay",
                  "sec":0.5
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to BUY ITEMS for your den",
                  "type":"helpBubble",
                  "x":660,
                  "y":320,
                  "top":false,
                  "left":false,
                  "delay":false,
                  "btn":"ffmDenCustomizeBtn"
               },{
                  "cmd":"playStream",
                  "src":"48",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               },{
                  "cmd":"advanceOnEvent",
                  "src":"shopBtn",
                  "event":MouseEvent.MOUSE_DOWN,
                  "type":"den"
               }]);
            }
            if(!ffmClothesCommands)
            {
               RoomManagerWorld._ffmCloseCallback = processAndDelete;
               _clothesCommands.push([{
                  "cmd":"delay",
                  "sec":0.5,
                  "type":"standAlone"
               }],[{
                  "cmd":"popup",
                  "txt":"Click on the TABLES/ITEMS to shop.",
                  "type":"helpBubble",
                  "world":true,
                  "x":480,
                  "y":280,
                  "top":false,
                  "left":true,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"59",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               },{
                  "cmd":"delay",
                  "sec":0.5
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to TRADE YOUR ITEMS for gems.",
                  "type":"helpBubble",
                  "world":true,
                  "x":470,
                  "y":330,
                  "top":true,
                  "left":true,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"60",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               }]);
            }
            if(!ffmFurnitureCommmands)
            {
               _furnitureCommands.push([{
                  "cmd":"delay",
                  "sec":0.5,
                  "type":"standAlone"
               }],[{
                  "cmd":"popup",
                  "txt":"Click on the TABLES/ITEMS to shop.",
                  "type":"helpBubble",
                  "world":true,
                  "x":515,
                  "y":310,
                  "top":false,
                  "left":false,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"59",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               },{
                  "cmd":"delay",
                  "sec":0.5
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to TRADE YOUR ITEMS for gems.",
                  "type":"helpBubble",
                  "world":true,
                  "x":485,
                  "y":325,
                  "top":true,
                  "left":false,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"60",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               }]);
            }
            if(!ffmECardCommands)
            {
               ECardInbox.ffmCallback = eCardFFMCallback;
               ECardInbox.initialConditionsCallback = initialConditionsCallback;
               ECardCreation.ffmCallback = nextSetCallback;
               _eCardCommands.push([{
                  "cmd":"delay",
                  "sec":0.25,
                  "type":"standAlone"
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to create a NEW JAM-A-GRAM.",
                  "type":"helpBubble",
                  "x":215,
                  "y":370,
                  "top":false,
                  "left":true,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"50",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               }],[{
                  "cmd":"popup",
                  "txt":"Select a BUDDY from your buddy list.",
                  "type":"helpBubble",
                  "x":452,
                  "y":385,
                  "top":true,
                  "left":true,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"57",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               }],[{
                  "cmd":"popup",
                  "txt":"Use these tools to CUSTOMIZE your Jam-A-Gram.",
                  "type":"helpBubble",
                  "x":320,
                  "y":385,
                  "top":true,
                  "left":true,
                  "twoTails":true,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"46",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to send your CUSTOMIZED JAM-A-GRAM.",
                  "type":"helpBubble",
                  "x":680,
                  "y":385,
                  "top":false,
                  "left":false,
                  "delay":false
               },{
                  "cmd":"playStream",
                  "src":"58",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               }]);
            }
            loadInitialConditions();
            _secondFFM = new FirstFiveMinutes();
            _secondFFM.init(_initialCommands,_lizaMC,guiLayer,worldLayer,chatLayer,secondFFMDoneCallback,true);
         }
      }
      
      public static function loadInitialConditions() : void
      {
         _initialCommands = [];
         if(ffmDen)
         {
            _initialCommands.push([{
               "cmd":"delay",
               "sec":0.5,
               "type":"standAlone"
            }],[{
               "cmd":"popup",
               "txt":"Click here to go to your DEN.",
               "type":"helpBubble",
               "x":640,
               "y":380,
               "top":false,
               "left":false,
               "delay":false,
               "btn":"ffmDen"
            },{
               "cmd":"playStream",
               "src":"47",
               "advances":false,
               "shamanTalk":false,
               "repeatStream":true
            },{
               "cmd":"advanceOnEvent",
               "src":mainHud.denBtn,
               "event":MouseEvent.MOUSE_DOWN,
               "type":"mc"
            }]);
         }
         else if(ffmMap)
         {
            VolumeSelector.ffmCallback = initialConditionsCallback;
            _initialCommands.push([{
               "cmd":"delay",
               "sec":0.5,
               "type":"standAlone"
            }],[{
               "cmd":"popup",
               "txt":"Click here to see a MAP OF JAMAA.",
               "type":"helpBubble",
               "x":715,
               "y":380,
               "top":false,
               "left":false,
               "delay":false,
               "btn":"ffmMap"
            },{
               "cmd":"playStream",
               "src":"53",
               "advances":false,
               "shamanTalk":false,
               "repeatStream":true
            },{
               "cmd":"advanceOnEvent",
               "src":mainHud.world,
               "event":MouseEvent.MOUSE_DOWN,
               "type":"mc",
               "modifyOnClick":"map"
            }]);
         }
         else if(ffmMail)
         {
            ECardInbox.initialConditionsCallback = initialConditionsCallback;
            _initialCommands.push([{
               "cmd":"delay",
               "sec":0.5,
               "type":"standAlone"
            }],[{
               "cmd":"popup",
               "txt":"Click here to open your MAILBOX.",
               "type":"helpBubble",
               "x":120,
               "y":140,
               "top":true,
               "left":true,
               "delay":false,
               "btn":"ffmMail"
            },{
               "cmd":"playStream",
               "src":"52",
               "advances":false,
               "shamanTalk":false,
               "repeatStream":true
            }]);
         }
         else if(ffmBuddyList)
         {
            BuddyList.ffmCallBack = initialConditionsCallback;
            _initialCommands.push([{
               "cmd":"delay",
               "sec":0.5,
               "type":"standAlone"
            }],[{
               "cmd":"popup",
               "txt":"Click here to see your BUDDY LIST.",
               "type":"helpBubble",
               "x":180,
               "y":140,
               "top":true,
               "left":true,
               "delay":false,
               "btn":"ffmBuddyList"
            },{
               "cmd":"playStream",
               "src":"45",
               "advances":false,
               "shamanTalk":false,
               "repeatStream":true
            },{
               "cmd":"advanceOnEvent",
               "src":mainHud.buddyList,
               "event":MouseEvent.MOUSE_DOWN,
               "type":"mc"
            }]);
         }
         else if(!ffmNews)
         {
            if(ffmSwap)
            {
               SwitchManager.ffmCallback = initialConditionsCallback;
               _initialCommands.push([{
                  "cmd":"delay",
                  "sec":0.5,
                  "type":"standAlone"
               }],[{
                  "cmd":"popup",
                  "txt":"Click here to SWITCH ANIMALS.",
                  "type":"helpBubble",
                  "x":270,
                  "y":375,
                  "top":false,
                  "left":true,
                  "delay":false,
                  "btn":"ffmSwap"
               },{
                  "cmd":"playStream",
                  "src":"44",
                  "advances":false,
                  "shamanTalk":false,
                  "repeatStream":true
               },{
                  "cmd":"advanceOnEvent",
                  "src":mainHud.swap,
                  "event":MouseEvent.MOUSE_DOWN,
                  "type":"mc"
               }]);
            }
         }
         _commands = _initialCommands;
      }
      
      public static function reloadCommands(param1:String) : void
      {
         _room = param1;
         if(param1 == "den" && _denCommands.length > 0)
         {
            DenEditor.closeCallback = activateDeactivateCallback;
            _commands = _denCommands;
            if(_denCommands.length < 2)
            {
               DenEditor.openCallback = activateDeactivateCallback;
            }
         }
         else if(param1 == "jamaa_township.clothes_shop")
         {
            _commands = _clothesCommands;
            if(_commands.length > 0)
            {
               _secondFFM.processCurrentSet();
            }
         }
         else if(param1 == "jamaa_township.furniture_room")
         {
            _commands = _furnitureCommands;
            if(_commands.length > 0)
            {
               _secondFFM.processCurrentSet();
            }
         }
         else if(ECardInbox.eCardIsOpen)
         {
            if(ECardInbox.eCardWasOpen)
            {
               _secondFFM.processCurrentSet();
            }
            else
            {
               ECardInbox.nextSetCallback = nextSetCallback;
               _secondFFM.processAndSplice();
               _commands = _eCardCommands;
               if(_commands.length < 4)
               {
                  ffmLoopAmountHolder = 0;
                  nextSetCallback(-1);
               }
               else
               {
                  ffmLoopAmountHolder = 0;
                  reloadCommandsCallback();
               }
            }
         }
         else
         {
            loadInitialConditions();
            _commands = _initialCommands;
         }
      }
      
      public static function nextSetCallback(param1:int) : void
      {
         ++ffmLoopAmountHolder;
         switch(ffmLoopAmountHolder)
         {
            case 1:
               if(ffmProcessAgainCallback != null)
               {
                  ffmProcessAgainCallback();
                  _secondFFM.processCurrentSet();
                  ffmProcessAgainCallback = null;
                  ++ffmFarthestSet;
                  return;
               }
               if(_commands.length == 4)
               {
                  if(param1 > ffmFarthestSet)
                  {
                     _secondFFM.doNextSet(false);
                     ++ffmFarthestSet;
                  }
                  else
                  {
                     _secondFFM.doNextSet(true,_commands);
                  }
               }
               break;
            case 2:
               if(ffmProcessAgainCallback != null)
               {
                  ffmProcessAgainCallback();
                  _secondFFM.processCurrentSet();
                  ffmProcessAgainCallback = null;
                  ++ffmFarthestSet;
                  return;
               }
               if(_commands.length == 3)
               {
                  if(param1 > ffmFarthestSet)
                  {
                     _secondFFM.doNextSet(false);
                     ++ffmFarthestSet;
                  }
                  else
                  {
                     _secondFFM.doNextSet(true,_commands);
                  }
               }
               break;
            case 3:
               if(ffmProcessAgainCallback != null)
               {
                  ffmProcessAgainCallback();
                  _secondFFM.processCurrentSet();
                  ffmProcessAgainCallback = null;
                  ++ffmFarthestSet;
                  return;
               }
               if(_commands.length == 2)
               {
                  if(param1 > ffmFarthestSet)
                  {
                     _secondFFM.doNextSet(false);
                     ++ffmFarthestSet;
                  }
                  else
                  {
                     _secondFFM.doNextSet(true,_commands);
                  }
               }
               break;
            case 4:
               if(ffmProcessAgainCallback != null)
               {
                  ffmProcessAgainCallback();
                  _secondFFM.processCurrentSet();
                  ffmProcessAgainCallback = null;
                  ++ffmFarthestSet;
                  return;
               }
               if(_commands.length == 1)
               {
                  if(param1 > ffmFarthestSet)
                  {
                     _secondFFM.doNextSet(false);
                     ++ffmFarthestSet;
                  }
                  else
                  {
                     _secondFFM.doNextSet(true,_commands);
                  }
               }
               break;
            case ffmLoopAmountHolder > 4:
               ffmLoopAmountHolder = 0;
         }
      }
      
      public static function reloadCommandsCallback() : void
      {
         if(_room == "den")
         {
            if(_commands.length > 1)
            {
               _secondFFM.reloadSets(_commands);
            }
            else if(_commands.length > 0)
            {
               _secondFFM.reloadSets(_commands);
            }
         }
         else if(_commands.length > 0)
         {
            _secondFFM.reloadSets(_commands);
         }
      }
      
      private static function eCardFFMCallback() : void
      {
         if(ECardInbox.eCardIsOpen)
         {
            reloadCommands(null);
         }
         else
         {
            reloadCommands(null);
         }
      }
      
      private static function processAndDelete() : void
      {
         _secondFFM.processCurrentSet();
         _commands.splice(0,1);
         _secondFFM.processCurrentSet();
      }
      
      private static function initialConditionsCallback() : void
      {
         reloadCommands(gMainFrame.server.getCurrentRoomName().slice(0,3));
         reloadCommandsCallback();
      }
      
      public static function activateDeactivateCallback() : void
      {
         if(DenEditor.openCallback == null)
         {
            _secondFFM.reloadSets();
            DenEditor.openCallback = activateDeactivateCallback;
         }
         else if(_secondFFM.getSets() == _commands)
         {
            _secondFFM.reloadSets();
         }
         else
         {
            _secondFFM.reloadSets(_commands);
         }
      }
      
      private static function secondFFMDoneCallback() : void
      {
         if(_denCommands.length == 0)
         {
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_DEN_COMMANDS]);
         }
         if(_clothesCommands.length == 0)
         {
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_CLOTHES_COMMANDS]);
         }
         if(_furnitureCommands.length == 0)
         {
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_FURNITURE_COMMANDS]);
         }
         if(_eCardCommands.length == 0)
         {
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_ECARD_COMMANDS]);
         }
         if(!ffmDen && !ffmMap && !ffmMail && !ffmBuddyList && !ffmNews && !ffmSwap && !ffmShopBtn && !ffmDenCustomizeBtn)
         {
            if(_denCommands.length == 0)
            {
               if(_clothesCommands.length == 0)
               {
                  if(_furnitureCommands.length == 0)
                  {
                     if(_eCardCommands.length == 0)
                     {
                        _secondFFM.destroy();
                        _secondFFM = null;
                        secondFFMRunning = false;
                        AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.SECOND_FFM_RUNNING]);
                        DenEditor.closeCallback = null;
                        DenEditor.openCallback = null;
                        DenEditor.staticEditor = null;
                        _roomMgr.callback_FFMRoomAssetsLoaded = null;
                        SwitchManager.ffmCallback = null;
                        ECardCreation.ffmCallback = null;
                        BuddyList.ffmCallBack = null;
                        ECardInbox.eCardIsOpen = false;
                        ECardInbox.eCardWasOpen = false;
                        ECardInbox.ffmCallback = null;
                        ECardInbox.initialConditionsCallback = null;
                        ECardInbox.nextSetCallback = null;
                        RoomManagerWorld._ffmCloseCallback = null;
                        _denCommands = null;
                        _clothesCommands = null;
                        _furnitureCommands = null;
                        _eCardCommands = null;
                     }
                  }
               }
            }
         }
      }
      
      public static function destroy() : void
      {
         removeListeners();
         chatHist.destroy();
         chatHist = null;
         SafeChatManager.destroy();
         emoteMgr.destroy();
         emoteMgr = null;
         actionMgr.destroy();
         actionMgr = null;
         volumeMgr.destroy();
         volumeMgr = null;
         InstructionScreenBuilder.destroy();
         DarkenManager.destroy();
         ItemXtCommManager.setHudAvtItemListLayerAnim(null);
         _reconnecting = false;
      }
      
      private static function setToolTipText() : void
      {
         if(mainHud.buddyListBtn)
         {
            mainHud.buddyListBtn.initToolTip(guiLayer,"Buddies",mainHud.x,40);
         }
         if(mainHud.eCardBtn)
         {
            mainHud.eCardBtn.initToolTip(guiLayer,"Jam-A-Grams",mainHud.x,40);
         }
         if(mainHud.newsBtn)
         {
            mainHud.newsBtn.initToolTip(guiLayer,"Jamaa Journal",mainHud.x,40);
         }
         if(mainHud.mySettingsBtn)
         {
            mainHud.mySettingsBtn.initToolTip(guiLayer,"My Settings",mainHud.x,45);
         }
         if(mainHud.reportBtn)
         {
            mainHud.reportBtn.initToolTip(guiLayer,"Report a Player",mainHud.x,45);
         }
         if(mainHud.swapBtn)
         {
            mainHud.swapBtn.initToolTip(guiLayer,"Switch Animals",mainHud.x,-35);
         }
         if(mainHud.actionsBtn)
         {
            mainHud.actionsBtn.initToolTip(guiLayer,"Actions",mainHud.x,-30);
         }
         if(mainHud.emotesBtn)
         {
            mainHud.emotesBtn.initToolTip(guiLayer,"Emotes",mainHud.x,-30);
         }
         if(mainHud.sendChatBtn)
         {
            if(mainHud.currentFrameLabel == "quest")
            {
               mainHud.sendChatBtn.initToolTip(guiLayer,"Send",528 + mainHud.x,497);
            }
            else
            {
               mainHud.sendChatBtn.initToolTip(guiLayer,"Send",521 + mainHud.x,505);
            }
         }
         if(mainHud.safeChatBtn)
         {
            mainHud.safeChatBtn.initToolTip(guiLayer,"Chat",mainHud.x,-30);
         }
         if(mainHud.denBtn)
         {
            mainHud.denBtn.initToolTip(guiLayer,"Den",mainHud.x,-35);
         }
         if(mainHud.soundBtn)
         {
            mainHud.soundBtn.initToolTip(guiLayer,"Volume",mainHud.x,-25);
         }
         if(mainHud.worldMapBtn)
         {
            mainHud.worldMapBtn.initToolTip(guiLayer,"World Map",mainHud.x,-50);
         }
         if(mainHud.awardsBtn)
         {
            mainHud.awardsBtn.initToolTip(guiLayer,"Achievements",mainHud.x,40);
         }
         if(mainHud.book)
         {
            mainHud.book.initToolTip(guiLayer,"Journey Book",mainHud.x,40);
         }
         if(mainHud.partyBtn)
         {
            mainHud.partyBtn.initToolTip(guiLayer,"Parties",mainHud.x,40);
         }
         if(mainHud.questReportBtn)
         {
            mainHud.questReportBtn.initToolTip(guiLayer,"Report A Player",mainHud.x,-30);
         }
         if(mainHud.questingExit_btnQuest)
         {
            mainHud.questingExit_btnQuest.initToolTip(guiLayer,"Exit Adventure",mainHud.x,-35);
         }
      }
      
      private static function blockMouseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function setSwapBtnGray(param1:Boolean) : void
      {
         if(Boolean(mainHud.swapBtn) && mainHud.swapBtn.isGray != param1)
         {
            mainHud.swapBtn.activateGrayState(param1);
         }
      }
      
      private static function helpMouseDownHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.visible = false;
      }
      
      public static function isModal() : Boolean
      {
         return volumeMgr.visible;
      }
      
      public static function onItemPrize(param1:Object) : void
      {
         _prizeData = {
            "userVarId":int(param1[2]),
            "isClothing":param1[3] == "1",
            "itemDefId":int(param1[4]),
            "itemName":param1[5],
            "desc":param1[6],
            "color":uint(param1[7])
         };
      }
      
      public static function showPrizePopupIfAny() : Boolean
      {
         var _loc1_:Object = null;
         if(_prizeData)
         {
            _loc1_ = DenXtCommManager.getDenItemDef(_prizeData.itemDefId);
            if(!_loc1_)
            {
               return false;
            }
            _prizeDenItemHelper = new DenItemHelper();
            _prizeDenItemHelper.init(uint(_prizeData.itemDefId << 16 | DenItem.getIconId(_loc1_.sortCat)),onPrizeIconReceived,_prizeData.color);
            return true;
         }
         return false;
      }
      
      private static function onPrizeIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Sprite = null;
         var _loc3_:Number = NaN;
         if(Boolean(param1) && Boolean(param1.displayObject))
         {
            _loc2_ = new Sprite();
            _loc3_ = DenItem.WIND_MED_SIZE / Math.max(param1.displayObject.width,param1.displayObject.height);
            param1.displayObject.width *= _loc3_;
            param1.displayObject.height *= _loc3_;
            _loc2_.addChild(param1.displayObject);
            _loc2_.x = -_loc2_.width * 0.5;
            _loc2_.y = -_loc2_.height * 0.5;
            _prizeImg = _loc2_;
            _prizeOkPopup = new SBOkPopup(guiLayer,_prizeData.desc,true,onPrizeDescOkDown);
         }
      }
      
      private static function onPrizeDescOkDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _prizeOkPopup.destroy();
         _giftPopup = new GiftPopup();
         _giftPopup.init(guiLayer,_prizeImg,_prizeData.itemName,GiftPopup.POPUP_TYPE_PRIZE,GiftPopup.GIFT_TYPE_DEN_ACC,onKeepPrizeDown,onDiscardPrizeDown,destroyPrizePopup);
      }
      
      private static function onKeepPrizeDown() : void
      {
         AchievementXtCommManager.requestSetUserVar(_prizeData.userVarId,3 | _prizeData.color << 4);
         destroyPrizePopup();
      }
      
      private static function onDiscardPrizeDown() : void
      {
         AchievementXtCommManager.requestSetUserVar(_prizeData.userVarId,2 | _prizeData.color << 4);
         destroyPrizePopup();
      }
      
      private static function destroyPrizePopup() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
         _prizeData = null;
         if(_prizeDenItemHelper)
         {
            _prizeDenItemHelper.destroy();
            _prizeDenItemHelper = null;
         }
         _prizeImg = null;
         guiStartupChecks();
      }
      
      public static function guiStartupChecks() : void
      {
         var _loc1_:int = 0;
         if(!gMainFrame.clientInfo.invisMode)
         {
            if(!showPrizePopupIfAny())
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP) != gMainFrame.clientInfo.newspaperTimestamp)
               {
                  GuiManager.onNewsPaperBtn(null);
                  AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP_STARTUP,gMainFrame.clientInfo.newspaperTimestamp);
               }
               else if(!_hasClosedGemBonus)
               {
                  _loc1_ = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_DAILY_GEM_BONUS));
                  if(_loc1_ == -1 || (_loc1_ & 0xFFFF) < gMainFrame.clientInfo.jamaaDate)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     if(gMainFrame.clientInfo.dailyGiftIndex >= 0 && gMainFrame.clientInfo.dailyGiftIndex < DAILY_GIFT_NUM_DAYS)
                     {
                        openDailyGift(gMainFrame.clientInfo.dailyGiftIndex);
                     }
                     else
                     {
                        openGemBonusWheel(_loc1_);
                     }
                  }
               }
            }
         }
      }
      
      public static function openGiftPopup(param1:Sprite, param2:String, param3:int, param4:Function, param5:Function, param6:Function, param7:int, param8:String, param9:int, param10:String, param11:Boolean) : void
      {
         _giftPopup = new GiftPopup();
         _giftPopup.init(guiLayer,param1,param2,param9,GiftPopup.giftTypeForECardType(param3),param4,param5,param6,false,param7,Utility.ENVIRO_LAND,param8,param10,null,param11);
      }
      
      public static function closePromoPopup() : Boolean
      {
         if(_giftPopup)
         {
            _giftPopup.close();
            return true;
         }
         return false;
      }
      
      public static function destroyPromotionalPopup() : void
      {
         if(_giftPopup)
         {
            _giftPopup.destroy();
            _giftPopup = null;
         }
      }
      
      public static function initMessagePopups() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _startupPopups = new StartupPopups();
         _startupPopups.init(guiLayer);
      }
      
      public static function initDemotionMessage(param1:Function) : void
      {
         _demotionMessage = new DemotionMessages();
         _demotionMessage.init(param1);
      }
      
      public static function initPlayerEngagement(param1:Function) : void
      {
         _playerEngagement = new PlayerEngagement();
         _playerEngagement.init(param1);
      }
      
      public static function set reconnecting(param1:Boolean) : void
      {
         _reconnecting = param1;
      }
      
      public static function get reconnecting() : Boolean
      {
         return _reconnecting;
      }
      
      public static function initMoviePlayer(param1:int, param2:Array, param3:Array, param4:Boolean = true) : void
      {
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
         }
         _videoPlayer = new VideoPlayer();
         _videoPlayer.init(param2,param3,param1,-1,param4);
      }
      
      public static function setVideoPlayerSkin(param1:int) : void
      {
         if(_videoPlayer)
         {
            _videoPlayer.setSkinFrame(param1);
         }
      }
      
      private static function gemsGlowTimerHandler(param1:TimerEvent) : void
      {
         _gemsGlowTimer.stop();
         if(mainHud.gemsBtn)
         {
            mainHud.gemsBtn.glow.visible = false;
         }
      }
      
      public static function startGemsFlash() : void
      {
         _gemsGlowTimer.start();
         AJAudio.playGemsEarnedSound();
         if(mainHud.gemsBtn)
         {
            mainHud.gemsBtn.glow.visible = true;
         }
      }
      
      public static function onNewsPaperBtn(param1:MouseEvent) : void
      {
         if(_newsOpenedFromBtn = param1 != null)
         {
            param1.stopPropagation();
         }
         if(_pageFlip)
         {
            _pageFlip.destroy();
         }
         if(Boolean(mainHud.newsBtn.glow.visible) && Boolean(param1))
         {
            mainHud.newsBtn.glow.visible = false;
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP,gMainFrame.clientInfo.newspaperTimestamp);
         }
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(NEWSPAPER_LIST_ID,onNewsPaperMediaListReceived);
      }
      
      private static function onNewsPaperMediaListReceived(param1:int, param2:Array, param3:Array) : void
      {
         SBTracker.push();
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,param2,true,onPageFlipCloseNP,onFlipNP);
      }
      
      public static function onJourneyBookBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(mainHud.book.glow.visible)
         {
            mainHud.book.glow.visible = false;
         }
         openJourneyBook();
      }
      
      public static function openJourneyBook(param1:Boolean = false) : void
      {
         if(_pageFlip)
         {
            _pageFlip.destroy();
         }
         DarkenManager.showLoadingSpiral(true);
         if(param1)
         {
            GenericListXtCommManager.requestGenericList(JB_LIST_ID,onJourneyBookMediaListReceivedWithInfo);
         }
         else
         {
            GenericListXtCommManager.requestGenericList(JB_LIST_ID,onJourneyBookMediaListReceived);
         }
      }
      
      private static function onJourneyBookMediaListReceived(param1:int, param2:Array, param3:Array, param4:Boolean = false) : void
      {
         SBTracker.push();
         var _loc5_:int = 1;
         var _loc6_:int = 0;
         while(_loc6_ < param3.length)
         {
            if(param3[_loc6_] == _currRoomDisplayName)
            {
               _loc5_ = _loc6_ + 1;
               break;
            }
            _loc6_++;
         }
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,param2,true,onEBookClose,onJourneyBookFlipNP,false,false,true,_loc5_,param4);
      }
      
      private static function onJourneyBookMediaListReceivedWithInfo(param1:int, param2:Array, param3:Array) : void
      {
         onJourneyBookMediaListReceived(param1,param2,param3,true);
      }
      
      public static function showJBGlow(param1:Boolean) : void
      {
         if(mainHud.book != null)
         {
            mainHud.book.glow.visible = param1;
         }
      }
      
      public static function updateJBIcon() : void
      {
         if(JBManager.numUnclaimedGifts > 0)
         {
            mainHud.book.gift.visible = true;
            mainHud.book.gift.giftCountTxt.text = JBManager.numUnclaimedGifts;
         }
         else
         {
            mainHud.book.gift.visible = false;
            mainHud.book.gift.giftCountTxt.text = "";
         }
      }
      
      public static function openEBook(param1:int, param2:Boolean) : void
      {
         if(_pageFlip)
         {
            _pageFlip.destroy();
         }
         _isRectangularEBook = param2;
         DarkenManager.showLoadingSpiral(true);
         GenericListXtCommManager.requestGenericList(param1,onMediaListReceived);
      }
      
      private static function onMediaListReceived(param1:int, param2:Array, param3:Array) : void
      {
         _currentBookId = param1;
         SBTracker.push();
         _pageFlip = new PageFlip();
         _pageFlip.init(guiLayer,param2,false,onEBookClose,onEBookFlipNP,_isRectangularEBook);
         DarkenManager.showLoadingSpiral(false);
      }
      
      public static function onMyUserVarsReceived() : void
      {
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_JAMAA_JOURNAL_TIMESTAMP) != gMainFrame.clientInfo.newspaperTimestamp)
         {
            mainHud.newsBtn.glow.visible = true;
         }
      }
      
      private static function onJourneyBookFlipNP(param1:String) : void
      {
         SBTracker.trackPageview("/game/play/popup/jb/#" + param1);
      }
      
      private static function onFlipNP(param1:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/newspaper/#page" + param1);
      }
      
      private static function onEBookFlipNP(param1:int) : void
      {
         SBTracker.trackPageview("/game/play/popup/#book_" + _currentBookId + "/page" + param1);
      }
      
      public static function onSwapBtnClickHandler(param1:MouseEvent) : void
      {
         if(Boolean(mainHud.swapBtn) && Boolean(mainHud.swapBtn.isGray) || RoomXtCommManager.isSwitching)
         {
            return;
         }
         param1.stopPropagation();
         _roomMgr.forceStopMovement();
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/avatarSwitch");
         if(GuiManager.secondFFMRunning)
         {
            GuiManager.ffmSwap = false;
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_SWAP]);
         }
         _avtSwitcher = new AvatarSwitcher();
         _avtSwitcher.init(guiLayer,onAvtSwitchClose,false,false);
      }
      
      public static function switchToOceanAnimal(param1:Object) : void
      {
         if(param1.status)
         {
            if(Boolean(mainHud.swapBtn) && Boolean(mainHud.swapBtn.isGray) || RoomXtCommManager.isSwitching)
            {
               return;
            }
            _roomMgr.forceStopMovement();
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/noOceanAnimal");
            _avtSwitcher = new AvatarSwitcher();
            _avtSwitcher.init(guiLayer,onAvtSwitchClose,false,true,param1.passback);
         }
      }
      
      public static function openAvatarChoose() : void
      {
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
         }
         _avtSwitcher = new AvatarSwitcher();
         _avtSwitcher.init(guiLayer,chooseAvatarCloseCallback,true,false);
      }
      
      public static function openDenRoomSwitcher(param1:Boolean = false, param2:Function = null, param3:Boolean = false) : void
      {
         if(_denSwitcher)
         {
            _denSwitcher.destroy();
         }
         if(!param1)
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/denSwitch");
            ffmSwap = false;
         }
         if(param2 == null)
         {
            param2 = onDenSwitchClose;
         }
         _denSwitcher = new DenSwitcher();
         _denSwitcher.init(AvatarManager.playerAvatar,guiLayer,param1,param3,param2,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private static function chooseAvatarCloseCallback() : void
      {
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
         _demotionMessage.hasChosen = true;
         _demotionMessage.goToNextPage();
      }
      
      private static function charWindowOverHandler(param1:MouseEvent) : void
      {
         toolTip.init(guiLayer,"Change Your Look",param1.currentTarget.x + mainHud.x,param1.currentTarget.y - (mainHud.currentFrameLabel == "quest" ? 40 : 55));
         toolTip.startTimer(param1);
         param1.currentTarget.gotoAndStop("over");
         AJAudio.playHudBtnRollover();
      }
      
      private static function charWindowOutHandler(param1:MouseEvent) : void
      {
         toolTip.resetTimerAndSetVisibility();
         param1.currentTarget.gotoAndStop("up");
      }
      
      private static function onSoundBtnClickHandler(param1:MouseEvent) : void
      {
         SBAudio.toggleMuteAll();
         toggleMuteVideo();
         if(_mySettings)
         {
            _mySettings.updateSoundBtn();
         }
      }
      
      public static function updateSettingsMessage() : void
      {
         if(_mySettings)
         {
            _mySettings.updateWorldMessage();
         }
      }
      
      public static function toggleMuteVideo() : void
      {
         if(Boolean(_roomMgr.theaterWindow) && Boolean(GenericListGuiManager.movieSelector) && Boolean(GenericListGuiManager.movieSelector.videoPlayer))
         {
            GenericListGuiManager.movieSelector.videoPlayer.toggleSound();
         }
      }
      
      public static function depressSoundButton(param1:Boolean) : void
      {
         if(param1)
         {
            mainHud.soundBtn.upToDownState();
         }
         else
         {
            mainHud.soundBtn.downToUpState();
         }
      }
      
      private static function onAwardsBtnClickHandler(param1:MouseEvent) : void
      {
         if(BuddyList.visible)
         {
            BuddyList.closeBuddyList();
         }
         if(PartyManager.visible)
         {
            PartyManager.close();
         }
         if(Boolean(_achievementViewer) && _achievementViewer.hasBeenInited)
         {
            if(_achievementViewer.visible)
            {
               _achievementViewer.close();
            }
            else
            {
               _achievementViewer.open();
            }
         }
         else
         {
            if(_achievementViewer == null)
            {
               _achievementViewer = new AchievementViewer();
            }
            _achievementViewer.init(mainHud.awardsBtn.x + 15,mainHud.awardsBtn.y + mainHud.awardsBtn.height * 0.5 - 5,287);
         }
      }
      
      public static function onPartyBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         else
         {
            mainHud.partyBtn.upToDownState();
         }
         if(BuddyList.visible)
         {
            BuddyList.closeBuddyList();
         }
         if(_achievementViewer.visible)
         {
            _achievementViewer.close();
         }
         if(mainHud.partyBtn.glow.visible)
         {
            mainHud.partyBtn.glow.visible = false;
         }
         if(PartyManager.visible)
         {
            PartyManager.close();
         }
         else
         {
            PartyManager.open();
         }
      }
      
      public static function showPartyBtnGlow(param1:Boolean) : void
      {
         if(gMainFrame.userInfo.firstFiveMinutes > 0 && Boolean(mainHud.partyBtn))
         {
            mainHud.partyBtn.glow.visible = param1;
         }
      }
      
      private static function onGemsBtnRollOverHandler(param1:MouseEvent) : void
      {
         toolTipBigGems.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.gemCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.width + 5,param1.currentTarget.y + 5,false);
         if(gMainFrame.clientInfo.ticketCount > 0)
         {
            param1.currentTarget.mouse.itemHitArea.visible = true;
            param1.currentTarget.mouse.tickets.visible = true;
            param1.currentTarget.mouse.itemHitArea.height = 50;
            toolTipBigTickets.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.ticketCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.width + 5,param1.currentTarget.y + 48,false);
            toolTipBigTickets.startTimer(param1);
         }
         else
         {
            param1.currentTarget.mouse.itemHitArea.visible = false;
            param1.currentTarget.mouse.tickets.visible = false;
         }
         param1.currentTarget.mouse.orb.visible = false;
         param1.currentTarget.mouse.orbTicketSpot.visible = false;
         if(gMainFrame.clientInfo.diamondCount > 0)
         {
            param1.currentTarget.mouse.itemHitArea.visible = true;
            if(gMainFrame.clientInfo.ticketCount > 0)
            {
               param1.currentTarget.mouse.diamondTicketSpot.visible = false;
               param1.currentTarget.mouse.itemHitArea.height = 100;
               param1.currentTarget.mouse.diamondOrbSpot.visible = true;
               param1.currentTarget.mouse.diamond.visible = false;
               toolTipBigDiamonds.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.diamondCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.width + 5,param1.currentTarget.y + 100,false);
            }
            else
            {
               param1.currentTarget.mouse.itemHitArea.height = 50;
               param1.currentTarget.mouse.diamondTicketSpot.visible = true;
               param1.currentTarget.mouse.diamondOrbSpot.visible = false;
               param1.currentTarget.mouse.diamond.visible = false;
               toolTipBigDiamonds.init(guiLayer,Utility.convertNumberToString(gMainFrame.clientInfo.diamondCount),param1.currentTarget.x + mainHud.x + param1.currentTarget.width + 5,param1.currentTarget.y + 49,false);
            }
            toolTipBigDiamonds.startTimer(param1);
         }
         else
         {
            param1.currentTarget.mouse.diamondTicketSpot.visible = false;
            param1.currentTarget.mouse.diamondOrbSpot.visible = false;
            param1.currentTarget.mouse.diamond.visible = false;
         }
         if(PartyManager.visible)
         {
            PartyManager.bringToFront();
         }
         toolTipBigGems.startTimer(param1);
      }
      
      private static function onGemsBtnRollOutHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.mouse.itemHitArea.visible = false;
         toolTipBigGems.visible = false;
         toolTipBigTickets.visible = false;
         toolTipBigDiamonds.visible = false;
      }
      
      private static function onMySettingsBtnClickHandler(param1:MouseEvent) : void
      {
         if(_mySettings != null)
         {
            _mySettings.destroy();
            _mySettings = null;
         }
         else
         {
            if(_reportAPlayer)
            {
               _reportAPlayer.destroy();
               _reportAPlayer = null;
               mainHud.reportBtn.downToUpState();
            }
            _mySettings = new MySettings();
            _mySettings.init(guiLayer,740,240,onMySettingsClose);
         }
      }
      
      private static function onReportBtnClickHandler(param1:MouseEvent) : void
      {
         if(_reportAPlayer)
         {
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
         else
         {
            if(_mySettings)
            {
               _mySettings.destroy();
               _mySettings = null;
               mainHud.mySettingsBtn.downToUpState();
            }
            _reportAPlayer = new ReportAPlayer();
            _reportAPlayer.init(guiLayer,onReportAPlayerClose,false,null,756,130);
         }
      }
      
      public static function displayRulesPopup(param1:Boolean, param2:Function = null) : void
      {
         if(param1)
         {
            if(_rulesPopup)
            {
               _rulesPopup.destroy();
               _rulesPopup = null;
            }
            _rulesPopup = new SBPopup(guiLayer,new (getDefinitionByName("ReportRulesPopupSkin") as Class)(),new (getDefinitionByName("ReportRulesPopupContent") as Class)(),true,true,false,false,true);
            _rulesPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _rulesPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            if(param2 != null)
            {
               _rulesPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,param2,false,0,true);
            }
         }
         else if(_rulesPopup)
         {
            _rulesPopup.destroy();
            _rulesPopup = null;
         }
      }
      
      public static function openJammerCentral() : void
      {
         if(_jammerCentral)
         {
            _jammerCentral.destroy();
            _jammerCentral = null;
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/jammerCentral");
         _jammerCentral = new BulletinBoard();
         _jammerCentral.init(guiLayer,onJammerCentralClose);
      }
      
      public static function refreshJammerCentral() : void
      {
         if(_jammerCentral)
         {
            _jammerCentral.refresh();
         }
      }
      
      private static function onJammerCentralClose() : void
      {
         SBTracker.flush(true);
         _jammerCentral.destroy();
         _jammerCentral = null;
      }
      
      public static function openLionFound() : void
      {
         DarkenManager.showLoadingSpiral(true);
         _lionMediaHelper = new MediaHelper();
         _lionMediaHelper.init(1176,onLionMediaLoaded,true);
      }
      
      private static function onLionMediaLoaded(param1:MovieClip) : void
      {
         var _loc2_:Avatar = null;
         var _loc3_:Array = null;
         var _loc4_:Item = null;
         var _loc5_:AvatarView = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _lionFoundPopup = MovieClip(param1.getChildAt(0));
            _lionFoundPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _lionFoundPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            guiLayer.addChild(_lionFoundPopup);
            DarkenManager.darken(_lionFoundPopup);
            _lionFoundPopup.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
            _lionFoundPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeLionPopup,false,0,true);
            _lionFoundPopup.oopsPopup.addEventListener(MouseEvent.MOUSE_DOWN,blockMouseHandler,false,0,true);
            _lionFoundPopup.oopsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,closeLionOopsPopup,false,0,true);
            _lionFoundPopup.donateBtn.addEventListener(MouseEvent.MOUSE_DOWN,onLionDonateBtn,false,0,true);
            _loc2_ = new Avatar();
            _loc2_.init(-1,"Lion King",17,[388317183,117440512,83836927],null,"Lion King");
            _loc3_ = [];
            _loc4_ = new Item();
            _loc3_[0] = _loc4_;
            _loc4_.init(1,1,0,-1,-1);
            _loc4_ = new Item();
            _loc3_[1] = _loc4_;
            _loc4_.init(4,2,0,-1,-1);
            _loc2_.itemResponseIntegrate(_loc3_);
            _loc5_ = new AvatarView();
            _loc5_.init(_loc2_,null);
            _loc5_.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
            _loc5_.x = 140;
            _loc5_.y = 60;
            _lionFoundPopup.amlBG.amlMask.amlBox.addChild(_loc5_);
            _lionFoundPopup.oopsPopup.visible = false;
         }
      }
      
      private static function closeLionPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_lionFoundPopup);
         guiLayer.removeChild(_lionFoundPopup);
         _lionFoundPopup = null;
      }
      
      private static function closeLionOopsPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _lionFoundPopup.oopsPopup.visible = false;
      }
      
      private static function onLionDonateBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onLionCurrencyCheck(param1:Boolean) : void
      {
         if(!param1)
         {
            if(_lionFoundPopup)
            {
               _lionFoundPopup.oopsPopup.visible = true;
            }
         }
      }
      
      private static function denBtnMouseDownHandler(param1:MouseEvent) : void
      {
         param1.currentTarget.downToUpState();
         param1.stopPropagation();
         if(secondFFMRunning)
         {
            ffmDen = false;
            AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_DEN]);
         }
         DarkenManager.showLoadingSpiral(true);
         DenXtCommManager.requestDenJoin(gMainFrame.userInfo.playerAvatarInfo.dbAvId);
         mainHud.denBtn.downToUpState();
      }
      
      public static function onExitRoom(param1:Boolean = false) : void
      {
         if(!param1)
         {
            BuddyList.closeBuddyList();
         }
         NGFactManager.closeFact();
         chatHist.resetTreeSearch();
         if(!param1)
         {
            if(_mySettings != null)
            {
               _mySettings.destroy();
               _mySettings = null;
               mainHud.mySettingsBtn.downToUpState();
            }
            if(_reportAPlayer)
            {
               if(_reportAPlayer.visible)
               {
                  mainHud.reportBtn.downToUpState();
               }
               _reportAPlayer.destroy();
               _reportAPlayer = null;
            }
         }
         ReportAPlayer.closeReportFromCardPopoup();
         if(_videoPlayer)
         {
            _videoPlayer.destroy();
            _videoPlayer = null;
         }
         if(PartyManager.visible)
         {
            PartyManager.close();
         }
         if(_pageFlip)
         {
            onPageFlipCloseNP();
         }
         if(ECardManager.eCardVisibility())
         {
            ECardManager.closeECard();
         }
         if(Boolean(volumeMgr) && volumeMgr.visible)
         {
            volumeMgr.show(false,VolumeSelector.WORLD_MAP);
         }
         if(Boolean(_achievementViewer) && _achievementViewer.visible)
         {
            _achievementViewer.close();
         }
         if(_avEditor)
         {
            _avEditor.destroy();
            _avEditor = null;
         }
         TradeManager.closeAllTradingRelatedPopups();
         QuestManager.closeAdventureJoinPopup();
         showJBGlow(false);
      }
      
      public static function closeAnyInventoryRelatedWindows() : void
      {
         if(ECardManager.eCardVisibility())
         {
            ECardManager.closeECard();
         }
         if(_avEditor)
         {
            TradeManager.resetNumTradeItems(_avEditor.numClothingItemsInTradeListInitially,_avEditor.numDenItemsInTradeListInitially);
            _avEditor.destroy();
            _avEditor = null;
         }
         if(_roomMgr)
         {
            _roomMgr.onRecycleClose();
         }
         if(denEditor)
         {
            denEditor.closeDenCustomization();
            onDenSwitchClose();
         }
      }
      
      public static function resetPetWindowListInDen() : void
      {
         if(denEditor)
         {
            denEditor.resetPetWindowList();
         }
      }
      
      public static function refreshDenLockSettings() : void
      {
         if(denEditor)
         {
            denEditor.refreshDenLockSettings();
         }
      }
      
      public static function openWorldMap() : void
      {
         volumeMgr.show(true,VolumeSelector.WORLD_MAP);
      }
      
      public static function onPhotoBoothClose() : void
      {
         SBTracker.pop();
         _photoBooth.destroy();
         _photoBooth = null;
      }
      
      public static function onAvEditorClose() : void
      {
         SBTracker.pop();
         _avEditor.destroy();
         _avEditor = null;
         if(_avEditorCloseCallback != null)
         {
            _avEditorCloseCallback();
            _avEditorCloseCallback = null;
         }
      }
      
      public static function onPageFlipCloseNP() : void
      {
         var _loc1_:int = 0;
         if(_pageFlip)
         {
            SBTracker.pop();
            _pageFlip.destroy();
            _pageFlip = null;
         }
         if(!_newsOpenedFromBtn && !_hasClosedGemBonus)
         {
            _loc1_ = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_DAILY_GEM_BONUS));
            if(_loc1_ == -1 || (_loc1_ & 0xFFFF) < gMainFrame.clientInfo.jamaaDate)
            {
               DarkenManager.showLoadingSpiral(true);
               if(gMainFrame.clientInfo.dailyGiftIndex >= 0 && gMainFrame.clientInfo.dailyGiftIndex < DAILY_GIFT_NUM_DAYS)
               {
                  openDailyGift(gMainFrame.clientInfo.dailyGiftIndex);
               }
               else
               {
                  openGemBonusWheel(_loc1_);
               }
            }
         }
      }
      
      public static function openDailyGift(param1:int) : void
      {
         if(_dailyGiftManager)
         {
            _dailyGiftManager.destroy();
            _dailyGiftManager = null;
         }
         DarkenManager.showLoadingSpiral(true);
         _dailyGiftManager = new DailyGiftManager();
         _dailyGiftManager.init(param1,onDailyGiftClose);
      }
      
      private static function onDailyGiftClose() : void
      {
         _dailyGiftManager.destroy();
         _dailyGiftManager = null;
      }
      
      public static function openMuseumDonation() : void
      {
         if(_museumDonation)
         {
            _museumDonation.destroy();
            _museumDonation = null;
         }
         _museumDonation = new MuseumDonation();
         _museumDonation.init(onMuseumDonationClose);
      }
      
      private static function onMuseumDonationClose() : void
      {
         _museumDonation.destroy();
         _museumDonation = null;
      }
      
      public static function openGemBonusWheel(param1:int) : void
      {
         if(_gemBonusWheel)
         {
            _gemBonusWheel.destroy();
            _gemBonusWheel = null;
         }
         _gemBonusWheel = new GemBonusSpinWheel();
         _gemBonusWheel.init(param1,onGemBonusClose);
      }
      
      public static function setGemBonusValues(param1:int) : void
      {
         if(_gemBonusWheel)
         {
            _gemBonusWheel.setupValuesAndSpin(param1);
         }
      }
      
      private static function onGemBonusClose() : void
      {
         _gemBonusWheel.destroy();
         _gemBonusWheel = null;
         _hasClosedGemBonus = true;
      }
      
      public static function onEBookClose() : void
      {
         if(_pageFlip)
         {
            SBTracker.pop();
            _pageFlip.destroy();
            _pageFlip = null;
         }
      }
      
      public static function onAvtSwitchClose() : void
      {
         SBTracker.pop();
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
      }
      
      public static function closeAvtSwitcherFromRoomJoin() : void
      {
         if(Boolean(_avtSwitcher) && _avtSwitcher.isChoosing)
         {
            return;
         }
         setSwapBtnGray(false);
         RoomXtCommManager.isSwitching = false;
         if(_avtSwitcher)
         {
            _avtSwitcher.destroy();
            _avtSwitcher = null;
         }
      }
      
      public static function onDenSwitchClose(param1:Boolean = false) : void
      {
         if(!param1)
         {
            SBTracker.pop();
         }
         if(_denSwitcher)
         {
            _denSwitcher.destroy();
            _denSwitcher = null;
         }
      }
      
      public static function onMySettingsClose() : void
      {
         if(_mySettings)
         {
            mainHud.mySettingsBtn.downToUpState();
            _mySettings.destroy();
            _mySettings = null;
         }
      }
      
      public static function onReportAPlayerClose(param1:Boolean) : void
      {
         if(_reportAPlayer)
         {
            mainHud.reportBtn.downToUpState();
            _reportAPlayer.destroy();
            _reportAPlayer = null;
         }
      }
      
      public static function openDiamondShopInfo() : void
      {
         if(_diamondShopInfoPopup == null)
         {
            DarkenManager.showLoadingSpiral(true);
            _diamondMediaHelper = new MediaHelper();
            _diamondMediaHelper.init(DIAMOND_SHOP_INFO,onDiamondInfoLoaded);
         }
         else
         {
            guiLayer.addChild(_diamondShopInfoPopup);
            DarkenManager.darken(_diamondShopInfoPopup);
         }
      }
      
      private static function onDiamondInfoLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _diamondShopInfoPopup = MovieClip(param1.getChildAt(0));
         _diamondShopInfoPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
         _diamondShopInfoPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondInfoClose,false,0,true);
         _diamondShopInfoPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _diamondShopInfoPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         guiLayer.addChild(_diamondShopInfoPopup);
         DarkenManager.darken(_diamondShopInfoPopup);
      }
      
      private static function onDiamondInfoClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_diamondShopInfoPopup);
         guiLayer.removeChild(_diamondShopInfoPopup);
      }
      
      private static function mainHudMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         gMainFrame.stage.addEventListener(MouseEvent.MOUSE_DOWN,clickedOutsideChatCui,false,0,true);
      }
      
      private static function charWindowDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!RoomXtCommManager.isSwitching)
         {
            openAvatarEditor();
            toolTip.resetTimerAndSetVisibility();
            if(mainHud.charHelp)
            {
               mainHud.charHelp.visible = false;
            }
         }
      }
      
      public static function openPhotoBooth() : void
      {
         if(_photoBooth)
         {
            _photoBooth.destroy();
            _photoBooth = null;
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/photoBooth");
            _photoBooth = new PhotoBooth();
            _photoBooth.init(onPhotoBoothClose);
         }
      }
      
      public static function openAvatarEditor(param1:Function = null) : void
      {
         var _loc2_:Boolean = false;
         _avEditorCloseCallback = param1;
         if(_avEditor)
         {
            _avEditor.destroy();
            _avEditor = null;
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/avatarEditor");
            _loc2_ = Boolean(_firstFiveMinutes) && !_firstFiveMinutes.isHelpBubble;
            _avEditor = new AvatarEditor();
            _avEditor.init(AvatarManager.playerAvatar,guiLayer,true,onAvEditorClose,_loc2_);
         }
      }
      
      public static function setFFMAvatarEditor() : void
      {
         _firstFiveMinutes.setAvatarEditor(_avEditor);
         _avEditor.block.visible = true;
         _firstFiveMinutes.advanceOnCallback();
      }
      
      public static function openAvEditorRecycle() : void
      {
         if(_avEditor)
         {
            _avEditor.openRecycle();
         }
      }
      
      public static function onEnterRoom(param1:int) : void
      {
         if(_currRoomDisplayName == "Brady Barr\'s Lab")
         {
            if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_BRADY_BARR_COUNT) < 0)
            {
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_BRADY_BARR_COUNT,1);
               GenericListGuiManager.genericListVolumeClicked(19,{"msg":"bb"});
            }
         }
         else if(_currRoomDisplayName == "Tierney\'s Aquarium")
         {
            if(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_TIERNEY_THYS_COUNT) < 0)
            {
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TIERNEY_THYS_COUNT,1);
               GenericListGuiManager.genericListVolumeClicked(78,{"msg":"tt"});
            }
         }
         setFocusToChatText();
         if(mainHud.currentFrame != param1 + 1 || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
            {
               if(mainHud.currentFrameLabel != "quest")
               {
                  enableGameHud(true,"quest");
               }
            }
            else
            {
               if(mainHud.currentFrameLabel == "quest")
               {
                  enableGameHud(false);
               }
               mainHud.gotoAndStop(param1 + 1);
               mainHud.chat.chatHistoryBG.chatHistBox.hud01_chatHistory.gotoAndStop(param1 + 1);
            }
            actionMgr.turnOnOceanActions(param1 == Utility.ENVIRO_OCEAN);
         }
      }
      
      public static function setFocusToChatText() : void
      {
         gMainFrame.stage.focus = mainHud.chatTxt;
      }
      
      public static function showHudAvt() : void
      {
         var _loc1_:Avatar = AvatarManager.playerAvatar;
         if(_hudAvtView)
         {
            if(_hudAvtView.parent == mainHud.charWindow.charLayer)
            {
               mainHud.charWindow.charLayer.removeChild(_hudAvtView);
            }
            _hudAvtView.destroy();
         }
         _hudAvtView = new AvatarView();
         _hudAvtView.init(_loc1_);
         _hudAvtView.playAnim(LayerAnim.AN_HUD_AVT,false,LayerAnim.PLAY_ONE_SHOT,null);
         positionHudAvatar();
         mainHud.charWindow.charLayer.addChild(_hudAvtView);
         if(mainHud.currentFrameLabel != "quest")
         {
            mainHud.text01_charName.text = AvatarManager.playerAvatar.userName;
         }
      }
      
      public static function positionHudAvatar() : void
      {
         var _loc1_:Point = AvatarUtility.getAvatarHudPosition(_hudAvtView.avTypeId);
         _hudAvtView.x = _loc1_.x;
         _hudAvtView.y = _loc1_.y;
      }
      
      public static function activateDenHud(param1:Boolean) : void
      {
         if(mainHud.denBtn)
         {
            mainHud.denBtn.removeEventListener(MouseEvent.MOUSE_DOWN,denBtnMouseDownHandler);
            mainHud.denBtn.visible = !param1;
         }
         if(!param1)
         {
            if(mainHud.denBtn)
            {
               mainHud.denBtn.addEventListener(MouseEvent.MOUSE_DOWN,denBtnMouseDownHandler,false,0,true);
            }
            if(denEditor)
            {
               denEditor.destroy();
               denEditor = null;
               mainHud.furnBtn.visible = false;
            }
         }
         else
         {
            if(denEditor)
            {
               denEditor.destroy();
               denEditor = null;
            }
            denEditor = new DenEditor();
            denEditor.init(AvatarManager.playerAvatar,guiLayer,mainHud);
            if(_ffmCallback != null)
            {
               _ffmCallback();
            }
         }
      }
      
      public static function showDenHudItems(param1:Boolean) : void
      {
         if(denEditor)
         {
            denEditor.toggleEditorHud(param1);
         }
      }
      
      public static function onPetsChanged() : void
      {
         if(denEditor)
         {
            denEditor.reloadDenItems();
         }
      }
      
      public static function clickedOutsideChatCui(param1:MouseEvent) : void
      {
         if(!mainHud.contains(DisplayObject(param1.target)))
         {
            if(mainHud.safeChatTreeWindow.visible)
            {
               mainHud.safeChatTreeWindow.visible = false;
            }
            if(mainHud.emotesWindow.visible)
            {
               mainHud.emotesWindow.visible = false;
            }
            if(mainHud.actionsWindow.visible)
            {
               mainHud.actionsWindow.visible = false;
            }
         }
         gMainFrame.stage.removeEventListener(MouseEvent.MOUSE_UP,clickedOutsideChatCui);
      }
      
      public static function onEmoteClick(param1:Sprite) : void
      {
         UserCommXtCommManager.sendAvatarEmote(param1);
      }
      
      public static function resizeHudZoneNameBar(param1:MovieClip) : void
      {
         param1.name_txt.width = param1.name_txt.textWidth + 5;
         param1.mid.width = param1.name_txt.textWidth + 5 + 0.5 * param1.left.width;
         param1.mid.x = param1.right.x - param1.mid.width + 1;
         param1.left.x = param1.mid.x - 0.5 * param1.left.width;
         param1.name_txt.x = param1.mid.x + 12;
      }
      
      private static function layerGuiMouseDownHandler(param1:MouseEvent) : void
      {
         if(!mainHud.contains(DisplayObject(param1.target)))
         {
            if(mainHud.safeChatTreeWindow.visible)
            {
               mainHud.safeChatBtn.dispatchEvent(param1);
            }
            if(mainHud.emotesWindow.visible)
            {
               mainHud.emotesBtn.dispatchEvent(param1);
            }
            if(mainHud.actionsWindow.visible)
            {
               mainHud.actionsBtn.dispatchEvent(param1);
            }
         }
      }
      
      private static function layerBkgMouseUpHandler(param1:MouseEvent) : void
      {
         if(mainHud.chatBar.text01_chat.visible)
         {
            gMainFrame.stage.focus = mainHud.chatTxt;
         }
      }
      
      public static function setRoomNameDisplay(param1:String) : void
      {
         _currRoomDisplayName = param1;
         if(mainHud.zoneNameTxt)
         {
            mainHud.zoneNameTxt.text = _currRoomDisplayName;
            resizeHudZoneNameBar(mainHud.zoneName);
         }
      }
      
      public static function get currRoomDisplayName() : String
      {
         return _currRoomDisplayName ? _currRoomDisplayName : "Unknown";
      }
      
      public static function handleMouseDown() : void
      {
         chatHist.dimChat();
         SafeChatManager.closeSafeChat();
         actionMgr.closeActions();
         emoteMgr.closeEmotes();
      }
      
      public static function handleGameExit() : void
      {
         mainHud.chatTxt.text = "";
         setFocusToChatText();
      }
      
      public static function addQuestXP(param1:Number) : void
      {
         var xpPercentage:Number = param1;
         if(mainHud.xpMeter)
         {
            with(mainHud.xpMeter)
            {
               
               xpBar.width = xpBarContainer.width * (xpPercentage / 100);
            }
         }
      }
      
      public static function setQuestHearts(param1:Number) : void
      {
         var _loc2_:AvatarInfo = null;
         if(mainHud.heartWindow)
         {
            if(_heartItemWindow)
            {
               if(Boolean(_heartItemWindow.parent) && _heartItemWindow.parent == mainHud.heartWindow)
               {
                  mainHud.heartWindow.removeChild(_heartItemWindow);
               }
               _heartItemWindow.destroy();
            }
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
            _heartItemWindow = new WindowGenerator();
            _heartItemWindow.init(Math.round(_loc2_.healthBase * 0.5),1,Math.round(_loc2_.healthBase * 0.5),0,0,0,ItemWindowHeart,null,"",null,{"hpPercentage":param1},onHeartsLoaded,true,false);
            mainHud.heartWindow.addChild(_heartItemWindow);
         }
      }
      
      private static function onHeartsLoaded() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _heartItemWindow.bg.numChildren)
         {
            MovieClip(_heartItemWindow.bg.getChildAt(_loc1_)).updateFrame();
            _loc1_++;
         }
      }
      
      public static function updateXPShape(param1:MovieClip) : void
      {
         var shape:MovieClip = null;
         var img:MovieClip = param1;
         if(mainHud.xpLevelShape)
         {
            with(mainHud)
            {
               
               while(xpLevelShape.numChildren > 0)
               {
                  xpLevelShape.removeChildAt(0);
               }
               shape = MovieClip(img.getChildAt(0));
               shape.text.text = img.passback;
               xpLevelShape.addChild(shape);
            }
         }
      }
      
      public static function updateShapeXP(param1:int) : void
      {
         var shape:MovieClip = null;
         var level:int = param1;
         if(mainHud.xpLevelShape)
         {
            with(mainHud)
            {
               
               if(xpLevelShape.numChildren > 0)
               {
                  shape = xpLevelShape.getChildAt(0);
                  if(shape.hasOwnProperty("text"))
                  {
                     shape.text.text = level;
                  }
               }
            }
         }
      }
      
      public static function showDiamondConfirmation(param1:int, param2:Function) : void
      {
         if(_diamondConfirmationPopup == null)
         {
            _diamondConfirmationPopup = new (getDefinitionByName("diamondShopConf") as Class)();
            _diamondConfirmationPopup.cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn,false,0,true);
            _diamondConfirmationPopup.buyBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn,false,0,true);
            _diamondConfirmationPopup.closeButton.addEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn,false,0,true);
            _diamondConfirmationPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _diamondConfirmationPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _diamondConfirmationPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         }
         _diamondConfirmationPopup.callback = param2;
         _diamondConfirmationPopup.diamondTxt.text = Utility.convertNumberToString(param1);
         guiLayer.addChild(_diamondConfirmationPopup);
         DarkenManager.darken(_diamondConfirmationPopup);
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onDiamondConfBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_diamondConfirmationPopup);
         guiLayer.removeChild(_diamondConfirmationPopup);
         if(param1.currentTarget.name == "buyBtn")
         {
            _diamondConfirmationPopup.callback();
         }
         _diamondConfirmationPopup.cancelBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn);
         _diamondConfirmationPopup.buyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDiamondConfBtn);
         _diamondConfirmationPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
         _diamondConfirmationPopup = null;
      }
      
      private static function addListeners() : void
      {
         guiLayer.addEventListener(MouseEvent.MOUSE_DOWN,layerGuiMouseDownHandler,false,0,true);
         bgLayer.addEventListener(MouseEvent.MOUSE_UP,layerBkgMouseUpHandler,false,0,true);
         mainHud.addEventListener(MouseEvent.MOUSE_DOWN,mainHudMouseDownHandler,false,0,true);
         if(mainHud.charWindow != null)
         {
            mainHud.charWindow.addEventListener(MouseEvent.MOUSE_DOWN,charWindowDownHandler,false,0,true);
            mainHud.charWindow.addEventListener(MouseEvent.ROLL_OVER,charWindowOverHandler,false,0,true);
            mainHud.charWindow.addEventListener(MouseEvent.ROLL_OUT,charWindowOutHandler,false,0,true);
         }
         if(mainHud.swapBtn != null)
         {
            mainHud.swapBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSwapBtnClickHandler,false,0,true);
         }
         if(mainHud.awardsBtn != null)
         {
            mainHud.awardsBtn.addEventListener(MouseEvent.MOUSE_DOWN,onAwardsBtnClickHandler,false,0,true);
         }
         if(mainHud.gemsBtn != null)
         {
            mainHud.gemsBtn.addEventListener(MouseEvent.ROLL_OVER,onGemsBtnRollOverHandler,false,0,true);
            mainHud.gemsBtn.addEventListener(MouseEvent.ROLL_OUT,onGemsBtnRollOutHandler,false,0,true);
         }
         if(mainHud.mySettingsBtn != null)
         {
            mainHud.mySettingsBtn.addEventListener(MouseEvent.MOUSE_DOWN,onMySettingsBtnClickHandler,false,0,true);
         }
         if(mainHud.reportBtn != null)
         {
            mainHud.reportBtn.addEventListener(MouseEvent.MOUSE_DOWN,onReportBtnClickHandler,false,0,true);
         }
         if(mainHud.soundBtn != null)
         {
            mainHud.soundBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSoundBtnClickHandler,false,0,true);
         }
         if(mainHud.newsBtn != null)
         {
            mainHud.newsBtn.addEventListener(MouseEvent.MOUSE_DOWN,onNewsPaperBtn,false,0,true);
         }
         if(mainHud.book != null)
         {
            mainHud.book.addEventListener(MouseEvent.MOUSE_DOWN,onJourneyBookBtn,false,0,true);
         }
         if(mainHud.partyBtn != null)
         {
            mainHud.partyBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPartyBtn,false,0,true);
         }
         if(mainHud.safeChatBtn != null)
         {
            mainHud.safeChatBtn.addEventListener(MouseEvent.MOUSE_DOWN,safeChatBtnDownHandler,false,0,true);
         }
         if(mainHud.questExitBtn != null)
         {
            mainHud.questExitBtn.addEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestExit,false,0,true);
         }
         if(mainHud.questReportBtn != null)
         {
            mainHud.questReportBtn.addEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestReportBtn,false,0,true);
         }
         _gemsGlowTimer.addEventListener(TimerEvent.TIMER,gemsGlowTimerHandler,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         guiLayer.removeEventListener(MouseEvent.MOUSE_DOWN,layerGuiMouseDownHandler);
         bgLayer.removeEventListener(MouseEvent.MOUSE_UP,layerBkgMouseUpHandler);
         mainHud.removeEventListener(MouseEvent.MOUSE_DOWN,mainHudMouseDownHandler);
         if(mainHud.charWindow != null)
         {
            mainHud.charWindow.removeEventListener(MouseEvent.MOUSE_DOWN,charWindowDownHandler);
            mainHud.charWindow.removeEventListener(MouseEvent.ROLL_OVER,charWindowOverHandler);
            mainHud.charWindow.removeEventListener(MouseEvent.ROLL_OUT,charWindowOutHandler);
         }
         if(mainHud.swapBtn != null)
         {
            mainHud.swapBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSwapBtnClickHandler);
         }
         if(mainHud.awardsBtn != null)
         {
            mainHud.awardsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onAwardsBtnClickHandler);
         }
         if(mainHud.gemsBtn != null)
         {
            mainHud.gemsBtn.removeEventListener(MouseEvent.ROLL_OVER,onGemsBtnRollOverHandler);
            mainHud.gemsBtn.removeEventListener(MouseEvent.ROLL_OUT,onGemsBtnRollOutHandler);
         }
         if(mainHud.mySettingsBtn != null)
         {
            mainHud.mySettingsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onMySettingsBtnClickHandler);
         }
         if(mainHud.reportBtn != null)
         {
            mainHud.reportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onReportBtnClickHandler);
         }
         if(mainHud.soundBtn != null)
         {
            mainHud.soundBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSoundBtnClickHandler);
         }
         if(mainHud.newsBtn != null)
         {
            mainHud.newsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onNewsPaperBtn);
         }
         if(mainHud.book != null)
         {
            mainHud.book.removeEventListener(MouseEvent.MOUSE_DOWN,onJourneyBookBtn);
         }
         if(mainHud.partyBtn != null)
         {
            mainHud.partyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onPartyBtn);
         }
         if(mainHud.safeChatBtn != null)
         {
            mainHud.safeChatBtn.removeEventListener(MouseEvent.MOUSE_DOWN,safeChatBtnDownHandler);
         }
         if(mainHud.questExitBtn != null)
         {
            mainHud.questExitBtn.removeEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestExit);
         }
         if(mainHud.questReportBtn != null)
         {
            mainHud.questReportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,QuestManager.onQuestReportBtn);
         }
         _gemsGlowTimer.removeEventListener(TimerEvent.TIMER,gemsGlowTimerHandler);
      }
      
      public static function safeChatBtnDownHandler(param1:MouseEvent) : void
      {
         if(mainHud.safeChatTreeWindow.visible)
         {
            SafeChatManager.closeSafeChat();
         }
         else
         {
            if(mainHud.emotesWindow.visible)
            {
               mainHud.emotesBtn.dispatchEvent(param1);
            }
            if(mainHud.actionsWindow.visible)
            {
               mainHud.actionsBtn.dispatchEvent(param1);
            }
            if(param1)
            {
               param1.stopPropagation();
            }
            SafeChatManager.openSafeChat(true);
         }
      }
      
      public static function toggleHud() : void
      {
         mainHud.visible = !mainHud.visible;
         setFocusToChatText();
      }
      
      private static function namebarBadgeDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         for each(_loc3_ in param1.def)
         {
            _loc2_ = {
               "defId":int(_loc3_.id),
               "pendingFlagsBit":int(_loc3_.pendingFlagsBit),
               "mediaRefId":int(_loc3_.mediaRefId)
            };
            _namebarBadgeDefs[_loc2_.defId] = _loc2_;
         }
      }
      
      public static function loadNameBarBadgeList() : void
      {
         GenericListXtCommManager.requestGenericList(NAME_BAR_ICONS_LIST_ID,onNameBarListLoaded);
      }
      
      private static function onNameBarListLoaded(param1:Array) : void
      {
         var _loc3_:Object = null;
         _namebarBadgeList = [];
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = getNamebarBadgeDef(param1[_loc2_]);
            if(_loc3_)
            {
               _namebarBadgeList[_loc2_] = _loc3_.mediaRefId;
            }
            _loc2_++;
         }
      }
      
      public static function getNamebarBadgeList() : Array
      {
         return _namebarBadgeList;
      }
      
      public static function getNamebarBadgeDefs() : Object
      {
         return _namebarBadgeDefs;
      }
      
      public static function getNamebarBadgeDef(param1:int) : Object
      {
         return _namebarBadgeDefs[param1];
      }
      
      public static function enableGameHud(param1:Boolean, param2:String = null, param3:Object = null) : void
      {
         var _loc4_:AvatarInfo = null;
         if(param1)
         {
            volumeMgr.enable(false);
            removeListeners();
            _originalHudFrame = mainHud.currentFrame;
            mainHud.gotoAndStop(param2);
            (mainHud as GuiHud).init(true);
            addListeners();
            GuiManager.chatHist.toggleInGameHud(true);
            if(param2 == "quest")
            {
               _loc4_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
               addQuestXP(_loc4_.questXPPercentage);
               setQuestHearts(_loc4_.questHealthPercentage);
               QuestManager.loadLevelShape(_loc4_.questLevel);
               chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,mainHud.predictTxtTagQuest);
               SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_ADVENTURE);
               SafeChatManager.reload(mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
               actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
               emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
               setupSoundButton();
               mainHud.reportPlayerCont.visible = false;
               setToolTipText();
            }
            if(param3)
            {
               if(mainHud.combatCardDeckBtn != null)
               {
                  mainHud.combatCardDeckBtn.addEventListener(MouseEvent.MOUSE_DOWN,param3.onCardDeckBtnClickHandler,false,0,true);
               }
            }
         }
         else if(_originalHudFrame != -1)
         {
            if(param3)
            {
               if(mainHud.combatCardDeckBtn != null)
               {
                  mainHud.combatCardDeckBtn.removeEventListener(MouseEvent.MOUSE_DOWN,param3.onCardDeckBtnClickHandler);
               }
            }
            removeListeners();
            mainHud.gotoAndStop(_originalHudFrame);
            (mainHud as GuiHud).init(true);
            addListeners();
            setToolTipText();
            _originalHudFrame = -1;
            chatHist.reload(mainHud.chatHist,mainHud.chatBar,mainHud.chatHistUpDownBtn,mainHud.buddyListBtn,mainHud.chatTxt,mainHud.sendChatBtn,mainHud.predictTxtTag);
            SafeChatManager.buildSafeChatTree(mainHud.safeChatTreeWindow,null,SafeChatManager.TREE_SAFECHAT);
            SafeChatManager.reload(mainHud.safeChatBtn,mainHud.safeChatTreeWindow,mainHud.actionsBtn,mainHud.actionWindow,mainHud.emotesBtn,mainHud.emotesWindow);
            actionMgr.reload(mainHud.actionsBtn,mainHud.actionsWindow,mainHud.emotesBtn,mainHud.emotesWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
            emoteMgr.reload(mainHud.emotesBtn,mainHud.emotesWindow,mainHud.actionsBtn,mainHud.actionsWindow,mainHud.safeChatBtn,mainHud.safeChatTreeWindow);
            volumeMgr.enable(true,mainHud.worldMapBtn,mainHud.zoneName,mainHud.worldHelp);
            GuiManager.chatHist.toggleInGameHud(false);
            setupSoundButton();
            setToolTipText();
            ECardManager.init(guiLayer,mainHud.eCardBtn,true);
            BuddyList.rebuildBtn(mainHud.buddyListBtn);
            mainHud.safeChatTreeWindow.visible = false;
            mainHud.actionsWindow.visible = false;
            mainHud.emotesWindow.visible = false;
            if(mainHud.swapBtn.hasGrayState)
            {
               mainHud.swapBtn.activateGrayState(false);
            }
            mainHud.mainBlock.visible = false;
            mainHud.gemsBtnBlock.visible = false;
            mainHud.charWindowBlock.visible = false;
            mainHud.gemsBtn.glow.visible = false;
            mainHud.awardsBtn.glow.visible = false;
            mainHud.newsBtn.glow.visible = false;
            mainHud.book.glow.visible = false;
            mainHud.book.gift.visible = false;
            mainHud.partyBtn.glow.visible = false;
            mainHud.playerWallBtn.glow.visible = false;
            mainHud.playerWallBtn.visible = false;
            mainHud.mySettingsBtn.glow.visible = false;
            mainHud.furnBtn.glow.visible = false;
         }
         setRoomNameDisplay(_currRoomDisplayName);
         setFocusToChatText();
      }
   }
}

