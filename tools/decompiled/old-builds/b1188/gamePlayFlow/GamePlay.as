package gamePlayFlow
{
   import Party.PartyXtCommManager;
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import avatar.AvatarManager;
   import avatar.AvatarSwitch;
   import avatar.AvatarWorldView;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserCommXtCommManager;
   import buddy.BuddyXtCommManager;
   import com.hurlant.util.Base64;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.graphics.Stats;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBStandardPopup;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.StageQuality;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   import flash.ui.Keyboard;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import gui.BuddyCard;
   import gui.BuddyManager;
   import gui.DarkenManager;
   import gui.DenSwitch;
   import gui.FeedbackManager;
   import gui.Fonts;
   import gui.GuiManager;
   import gui.NGFactManager;
   import gui.PartyManager;
   import gui.PollManager;
   import gui.ServerSelector;
   import gui.TradeManager;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import movie.MovieXtCommManager;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import playerWall.PlayerWallManager;
   import playerWall.PlayerWallXtCommManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.DebugGUICheckbox;
   import room.DebugGUISlider;
   import room.DebugGUITextbox;
   import room.LayerManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   import trade.TradeXtCommManager;
   
   public class GamePlay extends MovieClip
   {
      
      private static var _roomMgrInitSetGotoUsername:String;
      
      private static var _instance:GamePlay;
      
      public static const HIDE_NONENGLISH_SHARDS_HACK:Boolean = true;
      
      public var loadLayer:DisplayLayer;
      
      private var _gamePlayFlashVars:Object;
      
      private var lastTimer:int;
      
      private var roomMgr:RoomManagerWorld;
      
      private var _layerManager:LayerManager;
      
      private var _loginSO:SharedObject;
      
      private var _loginUsername:String;
      
      private var _loginAuthToken:String;
      
      private var _reconnecting:Boolean;
      
      private var _connectingToServer:Boolean;
      
      private var _nextSFServerIdx:int;
      
      private var _idleTimeoutPopup:SBOkPopup;
      
      private var loginHACK:uint;
      
      private var idleBlackout:Sprite;
      
      private var _debugConnectionModeTxt:DebugGUITextbox;
      
      private var _debugServerNodeTxt:DebugGUITextbox;
      
      private var _debugShardIdTxt:DebugGUITextbox;
      
      private var _debugAudioVolumeSlider:DebugGUISlider;
      
      private var _debugCheckbox1:DebugGUICheckbox;
      
      private var _debugCheckbox2:DebugGUICheckbox;
      
      private var _debugCheckbox3:DebugGUICheckbox;
      
      private var _debugVersionTxt:DebugGUITextbox;
      
      private var _stats:Stats;
      
      private var _loginShardId:int;
      
      private var _rsShardInfoData:Object;
      
      private var _cachedShardInfo:Array;
      
      private var _cachedShardIdToNodeMap:Object;
      
      private var _loginEvent:Event;
      
      private var _connectEvent:Event;
      
      public function GamePlay(param1:Object, param2:Event, param3:Event)
      {
         super();
         this._gamePlayFlashVars = param1;
         this._loginEvent = param2;
         this._connectEvent = param3;
      }
      
      public static function handleLocalExternalCall(param1:Object) : void
      {
         var instanceRoomMgr:RoomManagerWorld = null;
         var username:String = null;
         var modJoinRoomName:String = null;
         var jumpingToUser:Boolean = false;
         var alreadyInRoom:Boolean = false;
         var usernamep:String = null;
         var shouldGoInvisible:Boolean = false;
         var instanceStage:Stage = null;
         var denScreenshotData:BitmapData = null;
         var denScreenShotPixels:ByteArray = null;
         var d:String = null;
         var initGhostMode:Boolean = false;
         var ijusername:String = null;
         var ixmRoomNameOrId:String = null;
         var ixmShardId:int = 0;
         var estr:String = null;
         var params:Object = param1;
         try
         {
            DebugUtility.debugTrace("mec received - got params[0]:" + params[0]);
            if(params[0] == "mjr")
            {
               if(_instance == null)
               {
                  return;
               }
               instanceRoomMgr = _instance.roomMgr;
               username = null;
               modJoinRoomName = params[1];
               if(params.hasOwnProperty("2"))
               {
                  usernamep = params[2];
                  if(usernamep != null && usernamep != "" && instanceRoomMgr != null)
                  {
                     username = usernamep;
                  }
               }
               jumpingToUser = username != null;
               alreadyInRoom = gMainFrame.server.getCurrentRoomName() == modJoinRoomName;
               if(!alreadyInRoom)
               {
                  DarkenManager.showLoadingSpiral(true);
                  RoomXtCommManager.sendRoomJoinRequest(modJoinRoomName,-1,false,jumpingToUser);
                  if(jumpingToUser)
                  {
                     instanceRoomMgr.setGotoUsername(username,alreadyInRoom);
                  }
               }
               else if(jumpingToUser)
               {
                  instanceRoomMgr.setGotoUsername(username,alreadyInRoom);
               }
               DebugUtility.debugTrace("mjr:room join command received - request for room:" + modJoinRoomName + " (invisMode:" + gMainFrame.clientInfo.invisMode + " roomMgr:" + instanceRoomMgr + " alreadyInRoom:" + alreadyInRoom + ") user:" + username + " sent to server");
            }
            else if(params[0] == "mim")
            {
               shouldGoInvisible = params.hasOwnProperty("1") && Boolean(params[1]);
               FacilitatorXtCommManager.sendInvisModeRequest(shouldGoInvisible);
               DebugUtility.debugTrace("mim:invis mode command received - request sent to server - shouldGoInvisible:" + shouldGoInvisible);
            }
            else if(params[0] == "msn")
            {
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["sn",gMainFrame.server.serverIp]);
                  DebugUtility.debugTrace("mrc:sn command sent - ip:" + gMainFrame.server.serverIp);
               }
               DebugUtility.debugTrace("msn:get server node command received - sn response command sent");
            }
            else if(params[0] == "mds")
            {
               if(_instance == null)
               {
                  return;
               }
               if(ExternalInterface.available)
               {
                  AvatarManager.playerAvatarWorldView.visible = false;
                  _instance.stage.invalidate();
                  instanceStage = _instance.stage;
                  denScreenshotData = new BitmapData(instanceStage.stageWidth,instanceStage.stageHeight);
                  denScreenshotData.draw(instanceStage);
                  denScreenShotPixels = denScreenshotData.getPixels(new Rectangle(0,0,instanceStage.stageWidth,instanceStage.stageHeight));
                  d = Base64.encodeByteArray(denScreenShotPixels);
                  AvatarManager.playerAvatarWorldView.visible = true;
                  ExternalInterface.call("mrc",["ds",d]);
                  DebugUtility.debugTrace("mrc:ds command sent - denScreenshotData:" + denScreenshotData);
               }
               DebugUtility.debugTrace("mds:get den screenshot command received - ds response command sent");
            }
            else if(params[0] == "ixm")
            {
               DebugUtility.debugTrace("ixm:init external mode command received - setting extCallsActive to true");
               gMainFrame.clientInfo.extCallsActive = true;
               DebugUtility.debugTrace("ixm: extCallsActive set to true");
               DebugUtility.debugTrace("params.hasOwnProperty(\"1\"):" + params.hasOwnProperty("1"));
               if(params.hasOwnProperty("1") && params[1] != null)
               {
                  ixmRoomNameOrId = params[1];
                  DebugUtility.debugTrace("roomNameOrId - params[1]:" + ixmRoomNameOrId);
                  gMainFrame.clientInfo.autoStartRoom = ixmRoomNameOrId;
                  ixmShardId = int(parseInt(params[2]));
                  DebugUtility.debugTrace("shardId - params[2]:" + ixmShardId);
                  if(ixmRoomNameOrId.indexOf("den") == 0 && ixmShardId != RoomXtCommManager.RT_PARAM_GET_SHARD_FROM_DEN)
                  {
                     DebugUtility.debugTrace("ixm: WARNING - ignoring shardId:" + ixmShardId + " because room name:" + ixmRoomNameOrId + " appears to be a den!");
                     ixmShardId = RoomXtCommManager.RT_PARAM_GET_SHARD_FROM_DEN;
                  }
                  else if(ixmRoomNameOrId == QuestManager.SCRIPT_EDITOR_IXM_KEYWORD && ixmShardId < 0)
                  {
                     DebugUtility.debugTrace("ixm: ERROR - invalid shardId:" + ixmShardId + "! room name was the adventure keyword:" + ixmRoomNameOrId + " so shardId needs to be an adventure script def id!");
                     return;
                  }
                  gMainFrame.clientInfo.autoStartRoomShardId = ixmShardId;
                  DebugUtility.debugTrace("ixm:auto start room command received - request for " + params[1] + " set up to be caught during server selection screen init");
               }
               initGhostMode = true;
               DebugUtility.debugTrace("params.hasOwnProperty(\"4\"):" + params.hasOwnProperty("4"));
               if(params.hasOwnProperty("4"))
               {
                  initGhostMode = Boolean(params[4]);
                  DebugUtility.debugTrace("ghostMode - initGhostMode:" + initGhostMode);
                  if(!initGhostMode)
                  {
                     FacilitatorXtCommManager.sendInvisModeRequest(initGhostMode);
                     DebugUtility.debugTrace("ixm:invis mode request sent to server - initGhostMode:" + initGhostMode);
                  }
               }
               ijusername = "";
               if(params.hasOwnProperty("5"))
               {
                  DebugUtility.debugTrace("initJumpUser - params[5]:" + params[5]);
                  ijusername = params[5];
                  if(ijusername != null && ijusername != "")
                  {
                     _roomMgrInitSetGotoUsername = ijusername;
                  }
               }
               DebugUtility.debugTrace("ixm:auto jump to user position command - invisMode:" + gMainFrame.clientInfo.invisMode + " ijusername:" + ijusername + " _roomMgrInitSetGotoUsername:" + _roomMgrInitSetGotoUsername);
            }
         }
         catch(e:Error)
         {
            estr = "ERROR: Caught error in handleLocalExternalCall: " + e.message + " " + e.getStackTrace();
            DebugUtility.debugTrace(estr);
         }
      }
      
      public function worldCtorHelper() : void
      {
         _instance = this;
         this.init();
      }
      
      public function init() : void
      {
         SBTracker.trackPageview("/game/play/loading/startup");
         DebugUtility.debugTrace("security:" + Security.sandboxType);
         DebugUtility.debugTrace("username:" + this._gamePlayFlashVars.username);
         DebugUtility.debugTrace("auth_token:" + this._gamePlayFlashVars.auth_token);
         this._loginUsername = this._gamePlayFlashVars.username;
         this._loginAuthToken = this._gamePlayFlashVars.auth_token;
         Security.allowDomain("*");
         this._connectingToServer = false;
         this._nextSFServerIdx = 0;
         this.loginHACK = 0;
         this._layerManager = null;
         this.loadLayer = new DisplayLayer();
         addChild(this.loadLayer);
         this._debugConnectionModeTxt = new DebugGUITextbox();
         this._debugConnectionModeTxt.init(this.loadLayer,"Connection Mode: (Initializing...)",false,false,true,340);
         this._debugConnectionModeTxt.txt.textColor = 2236962;
         this._debugConnectionModeTxt.x = 50;
         this._debugConnectionModeTxt.y = 350;
         this._debugServerNodeTxt = new DebugGUITextbox();
         this._debugServerNodeTxt.init(this.loadLayer,"Server Node: " + gMainFrame.server.serverIp,false,false,true,170);
         this._debugServerNodeTxt.txt.textColor = 2236962;
         this._debugServerNodeTxt.x = 50;
         this._debugServerNodeTxt.y = 375;
         this._debugShardIdTxt = new DebugGUITextbox();
         this._debugShardIdTxt.init(this.loadLayer,"Shard: (Initializing...)",false,false,true,170);
         this._debugShardIdTxt.txt.textColor = 2236962;
         this._debugShardIdTxt.x = 50;
         this._debugShardIdTxt.y = 400;
         this._loginShardId = -1;
         this._cachedShardIdToNodeMap = {};
         DebugUtility.debugTrace("gamePlay init() - _gamePlayFlashVars.isCreateAccount:" + this._gamePlayFlashVars.isCreateAccount + " Server Node: " + gMainFrame.server.serverIp);
         try
         {
            this._loginSO = SharedObject.getLocal("com/sbi/login","/");
         }
         catch(e:Error)
         {
            _loginSO = null;
         }
         LoadProgress.init(this.loadLayer);
         this.initHUDAssets();
         gMainFrame.stage.quality = StageQuality.MEDIUM;
      }
      
      public function get layerManager() : LayerManager
      {
         return this._layerManager;
      }
      
      public function set reconnecting(param1:Boolean) : void
      {
         this._reconnecting = param1;
         GuiManager.reconnecting = param1;
      }
      
      public function get reconnecting() : Boolean
      {
         return this._reconnecting;
      }
      
      public function set debugShardIdTxt(param1:String) : void
      {
         this._debugShardIdTxt.text = "Shard: " + param1;
      }
      
      public function connectToNewServer() : void
      {
         if(this._connectingToServer)
         {
            return;
         }
         if(ServerSelector.isOpen())
         {
            ServerSelector.destroy();
         }
         this.initConnect();
      }
      
      public function showLoadProgress(param1:Boolean, param2:int) : void
      {
         LoadProgress.show(param1);
      }
      
      public function isInMinigame() : Boolean
      {
         return MinigameManager.inMinigame();
      }
      
      public function initHUDAssets() : void
      {
         DebugUtility.debugTrace("initHUDAssets called... calling load on hudassets.swf before call to initPreConnect/initGamePalette");
         if(PaletteHelper.gamePalette != null)
         {
            this.initPreConnect();
         }
         else
         {
            this.initGamePalette();
         }
      }
      
      public function initGamePalette() : void
      {
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_GLOBAL_PALETTE,this.handleGamePalette,false,0,true);
         ImageServerURL.instance.requestGlobalPalette();
      }
      
      private function handleGamePalette(param1:ImageServerEvent) : void
      {
         if(Boolean(param1) && Boolean(param1.genericData))
         {
            PaletteHelper.setGamePalette(param1.genericData.palette,param1.genericData.avatarPalette1,param1.genericData.avatarPalette2);
         }
         this.initPreConnect();
      }
      
      public function initPreConnect() : void
      {
         AJAudio.init(RoomManagerWorld.instance.broadcastMute);
         XtReplyDemuxer.init();
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"c");
         gMainFrame.server.addEventListener(SFEvent.ON_CONNECTION_LOST,this.onConnectionLost,false,0,true);
         this.initConnect();
      }
      
      public function initConnect() : void
      {
         if(!gMainFrame.server.isConnected)
         {
            if(gMainFrame.path == "")
            {
               gMainFrame.server.removeEventListener(SFEvent.ON_CONNECT,this.onConnect);
               gMainFrame.server.removeEventListener(SFEvent.ON_LOGIN,this.onWorldLogIn);
               gMainFrame.server.addEventListener(SFEvent.ON_CONNECT,this.onConnect,false,0,true);
               gMainFrame.server.addEventListener(SFEvent.ON_LOGIN,this.onWorldLogIn,false,0,true);
            }
            this._debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
            DebugUtility.debugTrace("initConnect Server Node: " + gMainFrame.server.serverIp);
            this._connectingToServer = true;
            gMainFrame.server.connect();
         }
         else
         {
            DebugUtility.debugTrace("ERROR: already connected?!");
         }
      }
      
      public function initShardSelectionAssets() : void
      {
         this._layerManager = new LayerManager(this,this.loadLayer);
         this.roomMgr = RoomManagerWorld.instance;
         this.roomMgr.init(this.layerManager);
         if(this._loginShardId == -1)
         {
            this.roomMgr.shardId = -1;
         }
         if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
         {
            this.roomMgr.jamaaMilliseconds = gMainFrame.clientInfo.currentTimestamp * 1000;
         }
         var _loc1_:DisplayLayer = this._layerManager.gui;
         var _loc2_:DisplayLayer = this._layerManager.fps;
         GenericListXtCommManager.init();
         GuiManager.init(_loc1_,_loc2_,this._layerManager.room_avatars,this._layerManager.room_chat,this._layerManager.bkg,this.roomMgr.setFocus);
         LocalizationXtCommManager.init();
         RoomXtCommManager.init();
         DenXtCommManager.init(DenSwitch.denListResponse);
         XtReplyDemuxer.addModule(GenericListXtCommManager.handleXtReply,"g");
         var _loc3_:ContextMenu = new ContextMenu();
         _loc3_.addEventListener(ContextMenuEvent.MENU_SELECT,this.onContextMenuHandler,false,0,true);
         _loc3_.hideBuiltInItems();
         var _loc4_:ContextMenuItem = new ContextMenuItem("Animal Jam");
         _loc3_.customItems.push(_loc4_);
         var _loc5_:ContextMenuItem = new ContextMenuItem("OS: " + Capabilities.os,false,false);
         var _loc6_:ContextMenuItem = new ContextMenuItem("Player: " + Capabilities.playerType + " " + Capabilities.version,false,false);
         _loc3_.customItems.push(_loc5_);
         _loc3_.customItems.push(_loc6_);
         this.contextMenu = _loc3_;
         this._stats = new Stats();
         this._layerManager.fps.addChild(this._stats);
         this._stats.visible = false;
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener,false,0,true);
      }
      
      public function initAssets() : void
      {
         Fonts.init();
         if(this._layerManager == null)
         {
            this._layerManager = new LayerManager(this,this.loadLayer);
            this.roomMgr = RoomManagerWorld.instance;
            this.roomMgr.init(this.layerManager);
            if(this._loginShardId == -1)
            {
               this.roomMgr.shardId = -1;
            }
         }
         var _loc1_:DisplayLayer = this._layerManager.gui;
         var _loc2_:DisplayLayer = this._layerManager.fps;
         AchievementManager.init(_loc2_);
         PartyManager.init(GuiManager.mainHud.partyBtn.x + 15,GuiManager.mainHud.partyBtn.y + GuiManager.mainHud.partyBtn.height * 0.5 - 5);
         KeepAlive.init(_loc1_,gMainFrame.server.getIsConnected,FacilitatorXtCommManager.sendIdleTimeOut);
         BuddyManager.init(_loc1_,GuiManager.mainHud.buddyListBtn);
         NGFactManager.init(_loc1_,this._layerManager.room_orbs);
         PollManager.init(_loc1_,this._layerManager.room_orbs);
         FeedbackManager.init(_loc1_,this._layerManager.room_orbs);
         ECardManager.init(_loc1_,GuiManager.mainHud.eCardBtn);
         AvatarWorldView.init({"showUserInfoPopup":BuddyCard.showBuddyCard});
         MinigameManager.init(_loc1_,this.roomMgr);
         AchievementXtCommManager.init(MinigameManager.inMinigame,GuiManager.onMyUserVarsReceived,GuiManager.setGemBonusValues);
         LayerAnim.useMaxThrottle = MinigameManager.inInRoomGame;
         AvatarManager.init(this._layerManager.room_avatars,this._layerManager.room_chat,this._layerManager.flying_avatars,this._layerManager.preview_room_avatar,this._layerManager.preview_room_flying_avatar);
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("auto jump to user position command - roomMgr:" + this.roomMgr + " _roomMgrInitSetGotoUsername:" + _roomMgrInitSetGotoUsername);
            if(_roomMgrInitSetGotoUsername != null && _roomMgrInitSetGotoUsername != "")
            {
               this.roomMgr.setGotoUsername(_roomMgrInitSetGotoUsername,false);
            }
         }
         UserCommXtCommManager.init();
         ItemXtCommManager.init(AvatarManager.getAvatarByUsernamePerUserAvId,AvatarManager.processAcIlCombo,GuiManager,DenXtCommManager.handleDenShopList,BuddyCard.updateDropDown);
         NameBar.getNamebarIconsFunc = GuiManager.getNamebarBadgeList;
         FacilitatorXtCommManager.init(_loc1_);
         TradeXtCommManager.init();
         PetManager.init();
         QuestXtCommManager.init();
         QuestManager.init(this._layerManager);
         TradeManager.init(_loc1_);
         GuiManager.loadNameBarBadgeList();
         MinigameXtCommManager.init();
         ECardXtCommManager.init();
         AvatarXtCommManager.init(AvatarManager.avatarCreateResponse,AvatarManager.avatarUpdateResponse,AvatarManager.avatarPaintResponse,AvatarManager.avatarRemoveResponse,BuddyManager.avatarListResponse,AvatarManager.avatarList,AvatarManager.getAvatarByUserName,AvatarSwitch.avatarSwitchResponse,BuddyCard.updateDropDown);
         XtReplyDemuxer.addModule(UserCommXtCommManager.handleXtReply,"u");
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"i");
         XtReplyDemuxer.addModule(ECardXtCommManager.handleXtReply,"e");
         XtReplyDemuxer.addModule(FacilitatorXtCommManager.handleXtReply,"f");
         XtReplyDemuxer.addModule(BuddyXtCommManager.handleXtReply,"b");
         XtReplyDemuxer.addModule(AchievementXtCommManager.handleXtReply,"z");
         XtReplyDemuxer.addModule(QuestXtCommManager.handleXtReply,"q");
         XtReplyDemuxer.addModule(TradeXtCommManager.handleXtReply,"t");
         XtReplyDemuxer.addModule(PetXtCommManager.handleXtReply,"p");
         XtReplyDemuxer.addModule(PartyXtCommManager.handleXtReply,"s");
         XtReplyDemuxer.addModule(VersionXtCommManager.handleXtReply,"v");
         XtReplyDemuxer.addModule(PlayerWallXtCommManager.handleXtReply,"w");
         _loc2_.addChild(this._debugConnectionModeTxt);
         _loc2_.addChild(this._debugServerNodeTxt);
         _loc2_.addChild(this._debugShardIdTxt);
         addEventListener(Event.ENTER_FRAME,this.heartbeat,false,0,true);
         this.lastTimer = getTimer();
         ServerSelector.fillNamesArray(true);
         var _loc3_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_GENERIC_LIST_TYPE,GenericListXtCommManager.genericListTypeResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_GENERIC_LIST_TYPE] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_NPC,QuestXtCommManager.questNPCDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NPC] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_DEN_ROOM,DenXtCommManager.denRoomResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ROOM] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_MOVIE_NODE,MovieXtCommManager.movieNodeResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_MOVIE_NODE] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_DIAMOND,DiamondXtCommManager.diamondResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DIAMOND] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_SCRIPT,QuestXtCommManager.scriptResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_SCRIPT] = _loc3_;
         _loc3_ = new DefPacksDefHelper();
         _loc3_.init(DefPacksDefHelper.DEF_PET,PetXtCommManager.petDefsResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PET] = _loc3_;
         GuiManager.volumeMgr.loadAssets(this.mapAssetsLoaded);
      }
      
      public function mapAssetsLoaded() : void
      {
         gMainFrame.server.setInitRoom();
         this.roomMgr.chosenLoginFinished();
         if(gMainFrame.clientInfo.accountType == SbiConstants.INTERNAL || gMainFrame.clientInfo.accountType == SbiConstants.COMMUNITY)
         {
            this._debugAudioVolumeSlider = new DebugGUISlider();
            this._debugAudioVolumeSlider.init(this._layerManager,this.roomMgr.debugAudioVolumeChanged,false);
         }
         this._debugCheckbox1 = new DebugGUICheckbox();
         this._debugCheckbox1.init(this._layerManager.fps,null,"Background Layer",true);
         this._debugCheckbox1.x = 400;
         this._debugCheckbox1.y = 250;
         this._debugCheckbox2 = new DebugGUICheckbox();
         this._debugCheckbox2.init(this._layerManager.fps,null,"Sortable Layer",true);
         this._debugCheckbox2.x = 400;
         this._debugCheckbox2.y = 275;
         this._debugCheckbox3 = new DebugGUICheckbox();
         this._debugCheckbox3.init(this._layerManager.fps,null,"Foreground Layer",true);
         this._debugCheckbox3.x = 400;
         this._debugCheckbox3.y = 300;
         this._debugVersionTxt = new DebugGUITextbox();
         this._debugVersionTxt.init(this._layerManager.fps,"world.swf Filesize: " + this.loaderInfo.bytesTotal + " Version: " + gVersion + " | buildinfo.xml - buildinfo.xml not loaded yet!");
         this._debugVersionTxt.x = 50;
         this._debugVersionTxt.y = 100;
         gMainFrame.loaderCache.openFile("buildinfo.xml",this.buildInfoDebugLoadCompleteHandler,null,URLLoaderDataFormat.TEXT);
      }
      
      private function buildInfoDebugLoadCompleteHandler(param1:LoaderEvent) : void
      {
         var _loc2_:XML = null;
         if(param1.status)
         {
            _loc2_ = new XML(param1.entry.data);
            this._debugVersionTxt.text = "world.swf - Filesize: " + this.loaderInfo.bytesTotal + " Version: " + gVersion + " | buildinfo.xml - Time: " + _loc2_.time.text() + " Id: " + _loc2_.id.text();
         }
         else
         {
            this._debugVersionTxt.text = "world.swf - Filesize: " + this.loaderInfo.bytesTotal + " Version: " + gVersion + " | buildinfo.xml - buildinfo.xml not found!";
         }
      }
      
      public function destroy() : void
      {
         AvatarSwitch.destroy();
         SBPopupManager.destroyAll();
         XtReplyDemuxer.destroy();
         ItemXtCommManager.destroy();
         UserCommXtCommManager.destroy();
         AvatarManager.destroy();
         MinigameManager.destroy();
         BuddyManager.destroy();
         GuiManager.destroy();
         QuestManager.destroy();
         PlayerWallManager.destroy();
         this.roomMgr.destroy();
         this.roomMgr = null;
         removeEventListener(Event.ENTER_FRAME,this.heartbeat);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownListener);
         gMainFrame.server.removeEventListener(SFEvent.ON_CONNECTION_LOST,this.onConnectionLost);
         if(gMainFrame.path == "")
         {
            gMainFrame.server.removeEventListener(SFEvent.ON_CONNECT,this.onConnect);
            gMainFrame.server.removeEventListener(SFEvent.ON_LOGIN,this.onWorldLogIn);
         }
      }
      
      public function showServerSelectorMore(param1:Object) : void
      {
         var _loc9_:Object = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc2_:Array = [];
         var _loc3_:int = -1;
         var _loc4_:* = 2;
         var _loc5_:* = 0;
         while(param1.hasOwnProperty(_loc4_))
         {
            _loc10_ = param1[_loc4_++];
            while(!isNaN(Number(param1[_loc4_])))
            {
               _loc11_ = int(param1[_loc4_++]);
               if(_loc11_ > _loc3_)
               {
                  _loc3_ = _loc11_;
               }
               if(this.roomMgr.shardId == _loc11_)
               {
                  _loc4_ += 3;
               }
               else
               {
                  this._cachedShardIdToNodeMap[_loc11_] = _loc10_;
                  var _loc12_:Number;
                  _loc2_[_loc12_ = _loc5_++] = {
                     "i":_loc11_,
                     "l":param1[_loc4_++],
                     "p":param1[_loc4_++],
                     "b":param1[_loc4_++]
                  };
               }
            }
         }
         _loc2_.sortOn(["l","b","p","i"],[Array.NUMERIC,Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.NUMERIC,Array.NUMERIC]);
         this._cachedShardInfo = _loc2_;
         var _loc6_:Object = {};
         var _loc7_:* = 0;
         var _loc8_:int = LocalizationManager.accountLanguage;
         for each(_loc9_ in _loc2_)
         {
            if(_loc9_.l == _loc8_)
            {
               if(int(_loc9_.p) < 4)
               {
                  var _loc14_:Number;
                  _loc6_[_loc14_ = _loc7_++] = _loc9_.i;
                  var _loc15_:Number;
                  _loc6_[_loc15_ = _loc7_++] = _loc9_.l;
                  var _loc16_:Number;
                  _loc6_[_loc16_ = _loc7_++] = int(_loc9_.p) > 0 ? _loc9_.p : (int(_loc9_.b) > 0 ? "1" : "0");
                  var _loc17_:Number;
                  _loc6_[_loc17_ = _loc7_++] = _loc9_.b;
               }
            }
         }
         for each(_loc9_ in _loc2_)
         {
            if(_loc9_.l != _loc8_)
            {
               if(!(HIDE_NONENGLISH_SHARDS_HACK && _loc8_ == LocalizationManager.LANG_ENG && _loc9_.l != _loc8_))
               {
                  if(int(_loc9_.p) < 4)
                  {
                     _loc6_[_loc14_ = _loc7_++] = _loc9_.i;
                     _loc6_[_loc15_ = _loc7_++] = _loc9_.l;
                     _loc6_[_loc16_ = _loc7_++] = int(_loc9_.p) > 0 ? _loc9_.p : (int(_loc9_.b) > 0 ? "1" : "0");
                     _loc6_[_loc17_ = _loc7_++] = _loc9_.b;
                  }
               }
            }
         }
         for each(_loc9_ in _loc2_)
         {
            if(int(_loc9_.p) >= 4)
            {
               if(!(HIDE_NONENGLISH_SHARDS_HACK && _loc8_ == LocalizationManager.LANG_ENG && _loc9_.l != _loc8_))
               {
                  _loc6_[_loc14_ = _loc7_++] = _loc9_.i;
                  _loc6_[_loc15_ = _loc7_++] = _loc9_.l;
                  _loc6_[_loc16_ = _loc7_++] = int(_loc9_.p) > 0 ? _loc9_.p : (int(_loc9_.b) > 0 ? "1" : "0");
                  _loc6_[_loc17_ = _loc7_++] = _loc9_.b;
               }
            }
         }
         ServerSelector.setupAllShards(_loc6_,_loc3_);
      }
      
      public function joinChosenShardIdNode(param1:int = -1, param2:String = null) : void
      {
         var _loc3_:Object = null;
         if(param1 != -1)
         {
            this._loginShardId = param1;
            this.roomMgr.shardId = param1;
            for each(_loc3_ in this._cachedShardInfo)
            {
               if(_loc3_.i == param1)
               {
                  if(_loc3_.l != LocalizationManager.accountLanguage)
                  {
                     RoomXtCommManager.waitForLangPack = true;
                     LocalizationXtCommManager.onLocalizationShardResponse(param1 + ":" + _loc3_.l);
                  }
                  break;
               }
            }
         }
         SBTracker.trackPageview("/game/play/loading/joinShard");
         this.roomMgr._gotNewShardId = true;
         this.roomMgr.joinNewShardRoom(true);
      }
      
      public function loginToChosenServer() : void
      {
         var _loc1_:String = null;
         var _loc2_:SFEvent = null;
         if(!gMainFrame.server.isConnected)
         {
            gMainFrame.server.connect();
         }
         else
         {
            _loc1_ = this._loginUsername;
            if(_loc1_ != null)
            {
               if(Boolean(this._loginUsername) && Boolean(this._loginUsername.indexOf("%") == -1) && gMainFrame.clientInfo.sessionId != undefined)
               {
                  _loc1_ += "%" + gMainFrame.clientInfo.sessionId;
               }
               _loc1_ += "#" + LocalizationManager.accountLanguage;
               _loc1_ += "!" + gMainFrame.clientInfo.deployVersion;
               gMainFrame.server.logIn("sbiLogin",_loc1_,this._loginAuthToken);
            }
            else
            {
               _loc2_ = new SFEvent(SFEvent.ON_LOGIN);
               _loc2_.status = false;
               this.onWorldLogIn(_loc2_);
            }
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(gMainFrame.clientInfo.accountType == SbiConstants.INTERNAL || gMainFrame.clientInfo.accountType == SbiConstants.COMMUNITY)
         {
            if(param1.keyCode == Keyboard.F2)
            {
               this._stats.visible = !this._stats.visible;
               this._debugServerNodeTxt.visible = !this._debugServerNodeTxt.visible;
               this._debugConnectionModeTxt.visible = !this._debugConnectionModeTxt.visible;
               this._debugShardIdTxt.visible = !this._debugShardIdTxt.visible;
               if(this._stats.visible)
               {
                  stage.addChild(this._layerManager.fps);
               }
               else
               {
                  stage.removeChild(this._layerManager.fps);
               }
            }
            else if(param1.keyCode == Keyboard.F5)
            {
               GuiManager.toggleHud();
            }
            else if(param1.keyCode == Keyboard.F6)
            {
               if(gMainFrame.stage.quality == "HIGH")
               {
                  gMainFrame.stage.quality = StageQuality.MEDIUM;
               }
               else if(gMainFrame.stage.quality == "MEDIUM")
               {
                  gMainFrame.stage.quality = StageQuality.LOW;
               }
               else
               {
                  gMainFrame.stage.quality = StageQuality.HIGH;
               }
            }
         }
      }
      
      private function onContextMenuHandler(param1:ContextMenuEvent) : void
      {
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = getTimer();
         AvatarManager.heartbeat(33,_loc2_ - this.lastTimer);
         this.roomMgr.heartbeat(33,_loc2_ - this.lastTimer);
         QuestManager.heartbeat();
         LayerAnim.heartbeat();
         PartyManager.updateTime();
         this.lastTimer = _loc2_;
      }
      
      public function onConnect(param1:SFEvent) : void
      {
         this._connectingToServer = false;
         if(param1.status)
         {
            if(Boolean(this._loginSO) && Boolean(this._loginSO.data))
            {
               gMainFrame.clientInfo["firstTime"] = gMainFrame.clientInfo.hasOwnProperty("firstTime");
            }
            else if(!gMainFrame.clientInfo.devMode)
            {
               gMainFrame.clientInfo["firstTime"] = true;
            }
            this._debugConnectionModeTxt.text = "Bluebox Connection: " + gMainFrame.server.isBlueboxMode();
            DebugUtility.debugTrace("onConnect - _gamePlayFlashVars.isCreateAccount:" + this._gamePlayFlashVars.isCreateAccount + " gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive);
            if(!this._layerManager)
            {
               this.initShardSelectionAssets();
            }
            this.loginToChosenServer();
         }
         else if(this._reconnecting)
         {
            if(!gMainFrame.server.autoAttemptHttp)
            {
               gMainFrame.server.autoAttemptHttp = true;
               this._debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
               this._debugConnectionModeTxt.text = "Attempting Reconnecting/Direct Bluebox Autoattempt Connection...";
               DebugUtility.debugTrace("trying bluebox Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
            }
            else
            {
               new SBStandardPopup(this,LocalizationManager.translateIdOnly(14694),false);
            }
         }
         else if(!gMainFrame.server.autoAttemptHttp)
         {
            if(this._nextSFServerIdx < gMainFrame.server.serverIps.length)
            {
               gMainFrame.server.setNewServer(this._nextSFServerIdx);
               this._debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
               this._debugConnectionModeTxt.text = "Attempting Connection...";
               DebugUtility.debugTrace("trying next Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
               ++this._nextSFServerIdx;
            }
            else
            {
               gMainFrame.server.autoAttemptHttp = true;
               this._nextSFServerIdx = 0;
               gMainFrame.server.setNewServer(this._nextSFServerIdx);
               this._debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
               this._debugConnectionModeTxt.text = "Starting Over With BlueBox Autoattempt Connection...";
               DebugUtility.debugTrace("trying first bluebox Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
            }
         }
         else if(this._nextSFServerIdx < gMainFrame.server.blueboxIps.length)
         {
            gMainFrame.server.setNewServer(this._nextSFServerIdx);
            DebugUtility.debugTrace("trying next bluebox Server Node: " + gMainFrame.server.serverIp);
            gMainFrame.server.connect();
            ++this._nextSFServerIdx;
         }
         else
         {
            DebugUtility.debugTrace("entire cluster/game is down! _nextSFServerIdx:" + this._nextSFServerIdx + " serverIps:" + gMainFrame.server.serverIps + " blueboxIps:" + gMainFrame.server.blueboxIps);
            new SBStandardPopup(stage,LocalizationManager.translateIdOnly(14695),false);
         }
      }
      
      public function onWorldLogIn(param1:SFEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         DebugUtility.debugTrace("World onLogIn, status:" + param1.status);
         if(param1.status)
         {
            DebugUtility.debugTrace("World onLogIn successful! gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive + " _layerManager:" + this._layerManager + " evt.userName:" + param1.userName + " gMainFrame.server.serverIp:" + gMainFrame.server.serverIp + " evt.obj.firstFiveMinutes:" + param1.obj.firstFiveMinutes);
            DebugUtility.debugTrace("World onLogIn successful! roomMgr.shardId:" + this.roomMgr.shardId + " _loginShardId:" + this._loginUsername + " _loginShardId:" + this._loginShardId);
            gMainFrame.server.setInitRoom();
            gMainFrame.clientInfo.dbUserId = param1.obj.dbUserId;
            gMainFrame.clientInfo.accountType = param1.obj.accountType;
            gMainFrame.clientInfo.avName = param1.obj.avName;
            gMainFrame.clientInfo.dailyGiftIndex = param1.obj.dailyGiftIndex;
            gMainFrame.clientInfo.diamondCount = param1.obj.diamondCount;
            gMainFrame.clientInfo.gemCount = param1.obj.gemCount;
            gMainFrame.clientInfo.hasOnlineBuddies = param1.obj.hasOnlineBuddies;
            gMainFrame.clientInfo.interactions = param1.obj.interactions;
            gMainFrame.clientInfo.jamaaDate = param1.obj.jamaaDate;
            gMainFrame.clientInfo.newspaperTimestamp = param1.obj.newspaperTimestamp;
            gMainFrame.clientInfo.numAJHQGiftCards = param1.obj.numAJHQGiftCards;
            gMainFrame.clientInfo.numDaysLeftOnSubscription = param1.obj.numDaysLeftOnSubscription;
            gMainFrame.clientInfo.numRedemptionCards = param1.obj.numRedemptionCards;
            gMainFrame.clientInfo.numUnreadECards = param1.obj.numUnreadECards;
            gMainFrame.clientInfo.crystalCount = param1.obj.orbCount;
            gMainFrame.clientInfo.recyclePercentage = param1.obj.recyclePercentage;
            gMainFrame.clientInfo.ticketCount = param1.obj.ticketCount;
            gMainFrame.clientInfo.userNameModerated = param1.obj.userNameModerated;
            gMainFrame.userInfo.myPerUserAvId = param1.obj.perUserAvId;
            gMainFrame.userInfo.myUserName = param1.userName;
            gMainFrame.userInfo.isGuide = param1.obj.isGuide;
            gMainFrame.userInfo.isModerator = param1.obj.isModerator;
            gMainFrame.userInfo.isMyDenPrivate = param1.obj.isMyDenPrivate;
            gMainFrame.userInfo.isSilenced = param1.obj.isSilenced != null ? true : false;
            gMainFrame.userInfo.numLogins = param1.obj.numLogins;
            gMainFrame.userInfo.pendingFlags = param1.obj.pendingFlags;
            gMainFrame.userInfo.sgChatType = param1.obj.sgChatType;
            gMainFrame.userInfo.sgChatTypeNonDegraded = param1.obj.sgChatTypeNonDegraded;
            gMainFrame.userInfo.myUUID = param1.obj.uuid;
            gMainFrame.userInfo.playerWallSettings = param1.obj.playerWallSettings;
            gMainFrame.userInfo.isMember = Utility.isMember(param1.obj.accountType);
            gMainFrame.userInfo.firstFiveMinutes = param1.obj.pendingFlags & 1 << 0;
            gMainFrame.userInfo.needFastPass = (param1.obj.pendingFlags & 1 << 4) != 0;
            DenSwitch.setActiveDenIdx(param1.obj.activeDenRoomInvId);
            PetManager.myActivePetInvId = param1.obj.activePetInvId;
            this._debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
            gMainFrame.server.triggerWorldXtReadyCmd();
            gMainFrame.myFlashVarUserName = param1.userName;
            GuiManager.setupSharedObject();
            GuiManager.setupSoundButton();
            gMainFrame.clientInfo.invisMode = gMainFrame.userInfo.isModerator;
            if(this._reconnecting)
            {
               this._reconnecting = false;
               if(gMainFrame.userInfo.avtDefsCached)
               {
                  _loc2_ = int(gMainFrame.server.userId);
                  AvatarManager.playerSfsUserId = _loc2_;
                  UserCommXtCommManager.playerSfsUserId = _loc2_;
                  AvatarSwitch.playerSfsUserId = _loc2_;
                  MinigameManager.userId = _loc2_;
                  PartyManager.requestPartyList();
                  this.roomMgr.reconnectNodeSwitchLoginFinished();
                  return;
               }
            }
            gMainFrame.clientInfo.accountTypeChanged = param1.obj.accountTypeChanged;
            gMainFrame.clientInfo.lastBroadcastMessage = param1.obj.lastBroadcastMessage;
            gMainFrame.clientInfo.sessionId = param1.obj.sessionId;
            GuiManager.setupAllItems();
            if(gMainFrame.server.isBlueboxMode())
            {
               SBTracker.trackPageview("/game/play/isBlueBox",-1,SBTracker.TYPE_EVENT);
            }
            AvatarSwitch.init();
            this.initAssets();
         }
         else if(!gMainFrame.clientInfo.devMode)
         {
            this._reconnecting = false;
            SBTracker.push();
            gMainFrame.clientInfo.dbUserId = param1.obj.dbUserId;
            if(param1.statusId == MainFrame.MSG_ID_LOGIN_IN_USE)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/inUse");
               _loc3_ = LocalizationManager.translateIdOnly(11197);
            }
            else if(param1.statusId == MainFrame.MSG_ID_LOGIN_ACCT_MAINT)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/accountMaintenance");
               _loc3_ = LocalizationManager.translateIdOnly(11198);
            }
            else if(param1.statusId == MainFrame.MSG_ID_LOGIN_SERVER_MAINT)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/serverMaintenance");
               _loc3_ = LocalizationManager.translateIdOnly(11199);
            }
            else if(param1.statusId == MainFrame.MSG_ID_LOGIN_CONNECTION)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/tooManyConnections");
               _loc3_ = LocalizationManager.translateIdOnly(11200);
            }
            else if(param1.statusId == MainFrame.MSG_ID_LOGIN_BANNED)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/bannedUser");
               _loc3_ = LocalizationManager.translateIdOnly(11201);
            }
            else if(param1.statusId == MainFrame.MSG_ID_LOGIN_CLIENT_MISMATCH)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/clientMismatch");
               Utility.reloadSWFOrGetIp();
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/loginError");
               _loc3_ = LocalizationManager.translateIdOnly(11202);
            }
            SBTracker.handleErrorTracking(param1.obj.dbUserId,-1,0,Math.abs(param1.statusId),-1,"failure",gMainFrame.server.serverIp,-1,-1);
            new SBStandardPopup(gMainFrame.stage,_loc3_,false);
         }
         else
         {
            if(!gMainFrame.clientInfo.hasOwnProperty("autoLogin" + ++this.loginHACK))
            {
               throw new Error("Could not auto-login world; add more loginHACKs or log in from the website.");
            }
            _loc4_ = gMainFrame.clientInfo["autoLogin" + this.loginHACK];
            _loc5_ = _loc4_[0];
            _loc5_ = _loc5_ + ("#" + LocalizationManager.accountLanguage);
            _loc5_ = _loc5_ + ("!" + gMainFrame.clientInfo.deployVersion);
            gMainFrame.server.logIn("sbiLogin",_loc5_,_loc4_[1]);
            this._loginUsername = _loc4_[0];
            this._loginAuthToken = _loc4_[1];
         }
      }
      
      public function onConnectionLost(param1:SFEvent) : void
      {
         var msg:String = null;
         var evt:SFEvent = param1;
         if(AvatarManager.playerSfsUserId >= 0)
         {
            this.roomMgr.exitRoom();
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.connectionLost();
         }
         if(this._reconnecting)
         {
            this.connectToNewServer();
            return;
         }
         if(GuiManager.chatHist)
         {
            GuiManager.chatHist.showChatInput(false);
         }
         if(Boolean(GuiManager.guiLayer) && GuiManager.guiLayer.contains(LoadProgress.loadScreen))
         {
            GuiManager.guiLayer.removeChild(LoadProgress.loadScreen);
         }
         if(this._idleTimeoutPopup)
         {
            DebugUtility.debugTrace("WARNING: idleTimeoutPopup is not null!");
            this._idleTimeoutPopup.destroy();
            this._idleTimeoutPopup = null;
         }
         this.idleBlackout = new Sprite();
         with(this.idleBlackout.graphics)
         {
            beginFill(0);
            drawRect(0,0,MainFrame.VIEW_WIDTH,MainFrame.VIEW_WIDTH);
         }
         while(this._layerManager.gui.numChildren >= 1)
         {
            this._layerManager.gui.removeChildAt(0);
         }
         this._layerManager.gui.addChild(this.idleBlackout);
         if(FacilitatorXtCommManager.kickReason >= 0)
         {
            msg = FacilitatorXtCommManager.kickMsg;
            FacilitatorXtCommManager.kickReason = -1;
            FacilitatorXtCommManager.kickMsg = LocalizationManager.translateIdOnly(11183);
         }
         else
         {
            if(FacilitatorXtCommManager.wasUserBanned)
            {
               FacilitatorXtCommManager.openPunishPopup(FacilitatorXtCommManager.suspensionType,FacilitatorXtCommManager.suspensionDuration);
               return;
            }
            msg = LocalizationManager.translateIdOnly(11204);
         }
         this._idleTimeoutPopup = new SBOkPopup(gMainFrame.stage,msg,false,this.idleTimeoutConfirmHandler);
      }
      
      public function idleTimeoutConfirmHandler(param1:MouseEvent) : void
      {
         var m:MouseEvent = param1;
         if(this._idleTimeoutPopup)
         {
            this._idleTimeoutPopup.destroy();
            this._idleTimeoutPopup = null;
         }
         this._layerManager.gui.removeChild(this.idleBlackout);
         try
         {
            LoadProgress.show(true,"Redirecting");
            navigateToURL(new URLRequest(gMainFrame.clientInfo.websiteURL + "signin"),"_self");
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error while trying to redirect after timeout! msg:" + e.message + e.getStackTrace());
         }
      }
   }
}

