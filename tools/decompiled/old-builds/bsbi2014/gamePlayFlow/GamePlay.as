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
      
      public function GamePlay(initFlashVars:Object, loginEvent:Event, connectEvent:Event)
      {
         super();
         this._gamePlayFlashVars = initFlashVars;
         this._loginEvent = loginEvent;
         this._connectEvent = connectEvent;
      }
      
      public static function handleLocalExternalCall(params:Object) : void
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
      
      public function set reconnecting(r:Boolean) : void
      {
         this._reconnecting = r;
         GuiManager.reconnecting = r;
      }
      
      public function get reconnecting() : Boolean
      {
         return this._reconnecting;
      }
      
      public function set debugShardIdTxt(s:String) : void
      {
         this._debugShardIdTxt.text = "Shard: " + s;
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
      
      public function showLoadProgress(show:Boolean, msgId:int) : void
      {
         LoadProgress.show(show);
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
      
      private function handleGamePalette(e:ImageServerEvent) : void
      {
         if(Boolean(e) && Boolean(e.genericData))
         {
            PaletteHelper.setGamePalette(e.genericData.palette,e.genericData.avatarPalette1,e.genericData.avatarPalette2);
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
         var guiLayer:DisplayLayer = this._layerManager.gui;
         var fpsLayer:DisplayLayer = this._layerManager.fps;
         GenericListXtCommManager.init();
         GuiManager.init(guiLayer,fpsLayer,this._layerManager.room_avatars,this._layerManager.room_chat,this._layerManager.bkg,this.roomMgr.setFocus);
         LocalizationXtCommManager.init();
         RoomXtCommManager.init();
         DenXtCommManager.init(DenSwitch.denListResponse);
         XtReplyDemuxer.addModule(GenericListXtCommManager.handleXtReply,"g");
         var cm:ContextMenu = new ContextMenu();
         cm.addEventListener(ContextMenuEvent.MENU_SELECT,this.onContextMenuHandler,false,0,true);
         cm.hideBuiltInItems();
         var cm0:ContextMenuItem = new ContextMenuItem("Animal Jam");
         cm.customItems.push(cm0);
         var cm1:ContextMenuItem = new ContextMenuItem("OS: " + Capabilities.os,false,false);
         var cm2:ContextMenuItem = new ContextMenuItem("Player: " + Capabilities.playerType + " " + Capabilities.version,false,false);
         cm.customItems.push(cm1);
         cm.customItems.push(cm2);
         this.contextMenu = cm;
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
         var guiLayer:DisplayLayer = this._layerManager.gui;
         var fpsLayer:DisplayLayer = this._layerManager.fps;
         AchievementManager.init(fpsLayer);
         PartyManager.init(GuiManager.mainHud.partyBtn.x + 15,GuiManager.mainHud.partyBtn.y + GuiManager.mainHud.partyBtn.height * 0.5 - 5);
         KeepAlive.init(guiLayer,gMainFrame.server.getIsConnected,FacilitatorXtCommManager.sendIdleTimeOut);
         BuddyManager.init(guiLayer,GuiManager.mainHud.buddyListBtn);
         NGFactManager.init(guiLayer,this._layerManager.room_orbs);
         PollManager.init(guiLayer,this._layerManager.room_orbs);
         FeedbackManager.init(guiLayer,this._layerManager.room_orbs);
         ECardManager.init(guiLayer,GuiManager.mainHud.eCardBtn);
         AvatarWorldView.init({"showUserInfoPopup":BuddyCard.showBuddyCard});
         MinigameManager.init(guiLayer,this.roomMgr);
         AchievementXtCommManager.init(MinigameManager.inMinigame,GuiManager.onMyUserVarsReceived,GuiManager.setGemBonusValues);
         LayerAnim.useMaxThrottle = MinigameManager.inInRoomGame;
         AvatarManager.init(this._layerManager.room_avatars,this._layerManager.room_chat,this._layerManager.flying_avatars,this._layerManager.preview_room_avatar,this._layerManager.preview_room_flying_avatar);
         if(Boolean(gMainFrame.clientInfo.extCallsActive))
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
         FacilitatorXtCommManager.init(guiLayer);
         TradeXtCommManager.init();
         PetManager.init();
         QuestXtCommManager.init();
         QuestManager.init(this._layerManager);
         TradeManager.init(guiLayer);
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
         fpsLayer.addChild(this._debugConnectionModeTxt);
         fpsLayer.addChild(this._debugServerNodeTxt);
         fpsLayer.addChild(this._debugShardIdTxt);
         addEventListener(Event.ENTER_FRAME,this.heartbeat,false,0,true);
         this.lastTimer = getTimer();
         GuiManager.volumeMgr.loadAssets(this.mapAssetsLoaded);
         ServerSelector.fillNamesArray(true);
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_GENERIC_LIST_TYPE,GenericListXtCommManager.genericListTypeResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_GENERIC_LIST_TYPE] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_PET,PetXtCommManager.petDefsResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PET] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_NPC,QuestXtCommManager.questNPCDefResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NPC] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_DEN_ROOM,DenXtCommManager.denRoomResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DEN_ROOM] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_MOVIE_NODE,MovieXtCommManager.movieNodeResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_MOVIE_NODE] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_DIAMOND,DiamondXtCommManager.diamondResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DIAMOND] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(DefPacksDefHelper.DEF_SCRIPT,QuestXtCommManager.scriptResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_SCRIPT] = dpdh;
      }
      
      public function mapAssetsLoaded() : void
      {
         gMainFrame.server.setInitRoom();
         this.roomMgr.chosenLoginFinished();
         if(gMainFrame.clientInfo.accountType == Utility.INTERNAL || gMainFrame.clientInfo.accountType == Utility.COMMUNITY || true)
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
      
      private function buildInfoDebugLoadCompleteHandler(e:LoaderEvent) : void
      {
         var biXml:XML = null;
         if(e.status)
         {
            biXml = new XML(e.entry.data);
            this._debugVersionTxt.text = "world.swf - Filesize: " + this.loaderInfo.bytesTotal + " Version: " + gVersion + " | buildinfo.xml - Time: " + biXml.time.text() + " Id: " + biXml.id.text();
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
      
      public function showServerSelectorMore(rmResponseData:Object) : void
      {
         var asiObj:Object = null;
         var mNode:String = null;
         var nextMoreShardId:int = 0;
         var allShardInfoSortable:Array = [];
         var lastShardId:int = -1;
         var smi:int = 2;
         var asis:int = 0;
         while(rmResponseData.hasOwnProperty(smi))
         {
            mNode = rmResponseData[smi++];
            while(!isNaN(Number(rmResponseData[smi])))
            {
               nextMoreShardId = int(rmResponseData[smi++]);
               if(nextMoreShardId > lastShardId)
               {
                  lastShardId = nextMoreShardId;
               }
               if(this.roomMgr.shardId == nextMoreShardId)
               {
                  smi += 3;
               }
               else
               {
                  this._cachedShardIdToNodeMap[nextMoreShardId] = mNode;
                  allShardInfoSortable[asis++] = {
                     "i":nextMoreShardId,
                     "l":rmResponseData[smi++],
                     "p":rmResponseData[smi++],
                     "b":rmResponseData[smi++]
                  };
               }
            }
         }
         allShardInfoSortable.sortOn(["l","b","p","i"],[Array.NUMERIC,Array.DESCENDING | Array.NUMERIC,Array.DESCENDING | Array.NUMERIC,Array.NUMERIC]);
         this._cachedShardInfo = allShardInfoSortable;
         var allShardInfoData:Object = {};
         var smidi:int = 0;
         var myLangId:int = LocalizationManager.accountLanguage;
         for each(asiObj in allShardInfoSortable)
         {
            if(asiObj.l == myLangId)
            {
               if(int(asiObj.p) < 4)
               {
                  allShardInfoData[smidi++] = asiObj.i;
                  allShardInfoData[smidi++] = asiObj.l;
                  allShardInfoData[smidi++] = int(asiObj.p) > 0 ? asiObj.p : (int(asiObj.b) > 0 ? "1" : "0");
                  allShardInfoData[smidi++] = asiObj.b;
               }
            }
         }
         for each(asiObj in allShardInfoSortable)
         {
            if(asiObj.l != myLangId)
            {
               if(!(HIDE_NONENGLISH_SHARDS_HACK && myLangId == LocalizationManager.LANG_ENG && asiObj.l != myLangId))
               {
                  if(int(asiObj.p) < 4)
                  {
                     allShardInfoData[smidi++] = asiObj.i;
                     allShardInfoData[smidi++] = asiObj.l;
                     allShardInfoData[smidi++] = int(asiObj.p) > 0 ? asiObj.p : (int(asiObj.b) > 0 ? "1" : "0");
                     allShardInfoData[smidi++] = asiObj.b;
                  }
               }
            }
         }
         for each(asiObj in allShardInfoSortable)
         {
            if(int(asiObj.p) >= 4)
            {
               if(!(HIDE_NONENGLISH_SHARDS_HACK && myLangId == LocalizationManager.LANG_ENG && asiObj.l != myLangId))
               {
                  allShardInfoData[smidi++] = asiObj.i;
                  allShardInfoData[smidi++] = asiObj.l;
                  allShardInfoData[smidi++] = int(asiObj.p) > 0 ? asiObj.p : (int(asiObj.b) > 0 ? "1" : "0");
                  allShardInfoData[smidi++] = asiObj.b;
               }
            }
         }
         ServerSelector.setupAllShards(allShardInfoData,lastShardId);
      }
      
      public function joinChosenShardIdNode(shardId:int = -1, autoStartNode:String = null) : void
      {
         var siObj:Object = null;
         if(shardId != -1)
         {
            this._loginShardId = shardId;
            this.roomMgr.shardId = shardId;
            for each(siObj in this._cachedShardInfo)
            {
               if(siObj.i == shardId)
               {
                  if(siObj.l != LocalizationManager.accountLanguage)
                  {
                     RoomXtCommManager.waitForLangPack = true;
                     LocalizationXtCommManager.onLocalizationShardResponse(shardId + ":" + siObj.l);
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
         var loginUsername:String = null;
         var newEvt:SFEvent = null;
         if(!gMainFrame.server.isConnected)
         {
            gMainFrame.server.connect();
         }
         else
         {
            loginUsername = this._loginUsername;
            if(loginUsername != null)
            {
               if(Boolean(this._loginUsername) && Boolean(this._loginUsername.indexOf("%") == -1) && gMainFrame.clientInfo.sessionId != undefined)
               {
                  loginUsername += "%" + gMainFrame.clientInfo.sessionId;
               }
               loginUsername += "#" + LocalizationManager.accountLanguage;
               gMainFrame.server.logIn("sbiLogin",loginUsername,this._loginAuthToken);
            }
            else
            {
               newEvt = new SFEvent(SFEvent.ON_LOGIN);
               newEvt.status = false;
               this.onWorldLogIn(newEvt);
            }
         }
      }
      
      private function keyDownListener(e:KeyboardEvent) : void
      {
         var ajClient:Object = null;
         if(gMainFrame.clientInfo.accountType == Utility.INTERNAL || gMainFrame.clientInfo.accountType == Utility.COMMUNITY || true)
         {
            if(e.keyCode == Keyboard.F2)
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
            else if(e.keyCode == Keyboard.F5)
            {
               GuiManager.toggleHud();
            }
            else if(e.keyCode == Keyboard.F6)
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
         if(e.keyCode == Keyboard.F3)
         {
            this.onConnectionLost(null);
         }
         else if(e.keyCode == Keyboard.F4)
         {
            if(Boolean(this._debugVersionTxt))
            {
               this._debugVersionTxt.toggleVisiblity();
            }
            stage.addChild(AJClient.globalErrorDebugTxt);
            AJClient.globalErrorDebugTxt.toggleVisiblity();
         }
         else if(e.keyCode == Keyboard.F8)
         {
            GuiManager.startFFM(true);
         }
         else if(e.keyCode == Keyboard.F9)
         {
            RoomXtCommManager.sendNonDenRoomJoinRequest("debug.room_main#" + this.roomMgr.shardId);
         }
         else if(e.keyCode == Keyboard.F12)
         {
            this._debugAudioVolumeSlider.toggleVisiblity();
            this._debugCheckbox1.toggleVisiblity();
            this._debugCheckbox2.toggleVisiblity();
            this._debugCheckbox3.toggleVisiblity();
         }
         else if(e.keyCode == Keyboard.HOME)
         {
            AchievementXtCommManager.requestDeleteAllAchievementsAndUserVars();
            gMainFrame.userInfo.playerUserInfo.resetAchievements();
         }
         else if(e.keyCode == Keyboard.END)
         {
            ajClient = gMainFrame.stage.getChildAt(1);
            if(Boolean(ajClient) && ajClient.mask != null)
            {
               ajClient.mask = null;
            }
         }
      }
      
      private function onContextMenuHandler(event:ContextMenuEvent) : void
      {
      }
      
      public function heartbeat(evt:Event) : void
      {
         var currTime:int = getTimer();
         AvatarManager.heartbeat(33,currTime - this.lastTimer);
         this.roomMgr.heartbeat(33,currTime - this.lastTimer);
         QuestManager.heartbeat();
         LayerAnim.heartbeat();
         PartyManager.updateTime();
         this.lastTimer = currTime;
      }
      
      public function onConnect(evt:SFEvent) : void
      {
         this._connectingToServer = false;
         if(evt.status)
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
      
      public function onWorldLogIn(evt:SFEvent) : void
      {
         var newSfsUserId:int = 0;
         var message:String = null;
         var alra:Array = null;
         var loginUsername:String = null;
         DebugUtility.debugTrace("World onLogIn, status:" + evt.status);
         if(evt.status)
         {
            DebugUtility.debugTrace("World onLogIn successful! gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive + " _layerManager:" + this._layerManager + " evt.userName:" + evt.userName + " gMainFrame.server.serverIp:" + gMainFrame.server.serverIp + " evt.obj.firstFiveMinutes:" + evt.obj.firstFiveMinutes);
            DebugUtility.debugTrace("World onLogIn successful! roomMgr.shardId:" + this.roomMgr.shardId + " _loginShardId:" + this._loginUsername + " _loginShardId:" + this._loginShardId);
            gMainFrame.server.setInitRoom();
            gMainFrame.clientInfo.dbUserId = evt.obj.dbUserId;
            gMainFrame.clientInfo.accountType = evt.obj.accountType;
            gMainFrame.clientInfo.avName = evt.obj.avName;
            gMainFrame.clientInfo.dailyGiftIndex = evt.obj.dailyGiftIndex;
            gMainFrame.clientInfo.diamondCount = evt.obj.diamondCount;
            gMainFrame.clientInfo.gemCount = evt.obj.gemCount;
            gMainFrame.clientInfo.hasOnlineBuddies = evt.obj.hasOnlineBuddies;
            gMainFrame.clientInfo.interactions = evt.obj.interactions;
            gMainFrame.clientInfo.jamaaDate = evt.obj.jamaaDate;
            gMainFrame.clientInfo.newspaperTimestamp = evt.obj.newspaperTimestamp;
            gMainFrame.clientInfo.numAJHQGiftCards = evt.obj.numAJHQGiftCards;
            gMainFrame.clientInfo.numDaysLeftOnSubscription = evt.obj.numDaysLeftOnSubscription;
            gMainFrame.clientInfo.numRedemptionCards = evt.obj.numRedemptionCards;
            gMainFrame.clientInfo.numUnreadECards = evt.obj.numUnreadECards;
            gMainFrame.clientInfo.orbCount = evt.obj.orbCount;
            gMainFrame.clientInfo.recyclePercentage = evt.obj.recyclePercentage;
            gMainFrame.clientInfo.ticketCount = evt.obj.ticketCount;
            gMainFrame.clientInfo.userNameModerated = evt.obj.userNameModerated;
            gMainFrame.userInfo.myPerUserAvId = evt.obj.perUserAvId;
            gMainFrame.userInfo.myUserName = evt.userName;
            gMainFrame.userInfo.isGuide = evt.obj.isGuide;
            gMainFrame.userInfo.isModerator = evt.obj.isModerator;
            gMainFrame.userInfo.isMyDenPrivate = evt.obj.isMyDenPrivate;
            gMainFrame.userInfo.isSilenced = evt.obj.isSilenced != null ? true : false;
            gMainFrame.userInfo.numLogins = evt.obj.numLogins;
            gMainFrame.userInfo.pendingFlags = evt.obj.pendingFlags;
            gMainFrame.userInfo.sgChatType = evt.obj.sgChatType;
            gMainFrame.userInfo.sgChatTypeNonDegraded = evt.obj.sgChatTypeNonDegraded;
            gMainFrame.userInfo.isMember = Utility.isMember(evt.obj.accountType);
            gMainFrame.userInfo.firstFiveMinutes = evt.obj.pendingFlags & 1 << 0;
            DenSwitch.setActiveDenIdx(evt.obj.activeDenRoomInvId);
            PetManager.myActivePetInvId = evt.obj.activePetInvId;
            this._debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
            gMainFrame.server.triggerWorldXtReadyCmd();
            gMainFrame.myFlashVarUserName = evt.userName;
            GuiManager.setupSharedObject();
            GuiManager.setupSoundButton();
            gMainFrame.clientInfo.invisMode = gMainFrame.userInfo.isModerator;
            if(this._reconnecting)
            {
               this._reconnecting = false;
               if(gMainFrame.userInfo.avtDefsCached)
               {
                  newSfsUserId = int(gMainFrame.server.userId);
                  AvatarManager.playerSfsUserId = newSfsUserId;
                  UserCommXtCommManager.playerSfsUserId = newSfsUserId;
                  AvatarSwitch.playerSfsUserId = newSfsUserId;
                  MinigameManager.userId = newSfsUserId;
                  PartyManager.requestPartyList();
                  this.roomMgr.reconnectNodeSwitchLoginFinished();
                  return;
               }
            }
            gMainFrame.clientInfo.accountTypeChanged = evt.obj.accountTypeChanged;
            gMainFrame.clientInfo.lastBroadcastMessage = evt.obj.lastBroadcastMessage;
            gMainFrame.clientInfo.sessionId = evt.obj.sessionId;
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
            gMainFrame.clientInfo.dbUserId = evt.obj.dbUserId;
            if(evt.statusId == MainFrame.MSG_ID_LOGIN_IN_USE)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/inUse");
               message = LocalizationManager.translateIdOnly(11197);
            }
            else if(evt.statusId == MainFrame.MSG_ID_LOGIN_ACCT_MAINT)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/accountMaintenance");
               message = LocalizationManager.translateIdOnly(11198);
            }
            else if(evt.statusId == MainFrame.MSG_ID_LOGIN_SERVER_MAINT)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/serverMaintenance");
               message = LocalizationManager.translateIdOnly(11199);
            }
            else if(evt.statusId == MainFrame.MSG_ID_LOGIN_CONNECTION)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/tooManyConnections");
               message = LocalizationManager.translateIdOnly(11200);
            }
            else if(evt.statusId == MainFrame.MSG_ID_LOGIN_BANNED)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/bannedUser");
               message = LocalizationManager.translateIdOnly(11201);
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/loginError");
               message = LocalizationManager.translateIdOnly(11202);
            }
            SBTracker.handleErrorTracking(evt.obj.dbUserId,-1,0,Math.abs(evt.statusId),-1,"failure",gMainFrame.server.serverIp,-1,-1);
            new SBStandardPopup(gMainFrame.stage,message,false);
         }
         else
         {
            if(!gMainFrame.clientInfo.hasOwnProperty("autoLogin" + ++this.loginHACK))
            {
               throw new Error("Could not auto-login world; add more loginHACKs or log in from the website.");
            }
            alra = gMainFrame.clientInfo["autoLogin" + this.loginHACK];
            loginUsername = alra[0];
            loginUsername += "#" + LocalizationManager.accountLanguage;
            gMainFrame.server.logIn("sbiLogin",loginUsername,alra[1]);
            this._loginUsername = alra[0];
            this._loginAuthToken = alra[1];
         }
      }
      
      public function onConnectionLost(evt:SFEvent) : void
      {
         var msg:String = null;
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
         if(Boolean(GuiManager.chatHist))
         {
            GuiManager.chatHist.showChatInput(false);
         }
         if(Boolean(GuiManager.guiLayer) && GuiManager.guiLayer.contains(LoadProgress.loadScreen))
         {
            GuiManager.guiLayer.removeChild(LoadProgress.loadScreen);
         }
         if(Boolean(this._idleTimeoutPopup))
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
      
      public function idleTimeoutConfirmHandler(m:MouseEvent) : void
      {
         if(Boolean(this._idleTimeoutPopup))
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

