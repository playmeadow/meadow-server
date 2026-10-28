package gamePlayFlow
{
   import Party.PartyManager;
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
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopupManager;
   import com.sbi.popup.SBStandardPopup;
   import currency.UserCurrency;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
   import ecard.ECardManager;
   import ecard.ECardXtCommManager;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
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
      
      public static const HIDE_NONENGLISH_SHARDS_HACK:Boolean = true;
      
      private static var _roomMgrInitSetGotoUsername:String;
      
      private static var _instance:GamePlay;
      
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
         _gamePlayFlashVars = param1;
         _loginEvent = param2;
         _connectEvent = param3;
      }
      
      public static function handleLocalExternalCall(param1:Object) : void
      {
         var _loc2_:RoomManagerWorld = null;
         var _loc13_:String = null;
         var _loc8_:String = null;
         var _loc4_:String = null;
         var _loc10_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc17_:Boolean = false;
         var _loc3_:Stage = null;
         var _loc16_:BitmapData = null;
         var _loc6_:ByteArray = null;
         var _loc5_:String = null;
         var _loc14_:String = null;
         var _loc15_:int = 0;
         var _loc7_:Boolean = false;
         var _loc12_:String = null;
         var _loc11_:String = null;
         try
         {
            DebugUtility.debugTrace("mec received - got params[0]:" + param1[0]);
            if(param1[0] == "mjr")
            {
               if(_instance == null)
               {
                  return;
               }
               _loc2_ = _instance.roomMgr;
               _loc13_ = null;
               _loc8_ = param1[1];
               if(param1.hasOwnProperty("2"))
               {
                  _loc4_ = param1[2];
                  if(_loc4_ != null && _loc4_ != "" && _loc2_ != null)
                  {
                     _loc13_ = _loc4_;
                  }
               }
               _loc10_ = _loc13_ != null;
               _loc9_ = gMainFrame.server.getCurrentRoomName() == _loc8_;
               if(!_loc9_)
               {
                  DarkenManager.showLoadingSpiral(true);
                  RoomXtCommManager.sendRoomJoinRequest(_loc8_,-1,false,_loc10_);
                  if(_loc10_)
                  {
                     _loc2_.setGotoUsername(_loc13_,_loc9_);
                  }
               }
               else if(_loc10_)
               {
                  _loc2_.setGotoUsername(_loc13_,_loc9_);
               }
               DebugUtility.debugTrace("mjr:room join command received - request for room:" + _loc8_ + " (invisMode:" + gMainFrame.clientInfo.invisMode + " roomMgr:" + _loc2_ + " alreadyInRoom:" + _loc9_ + ") user:" + _loc13_ + " sent to server");
            }
            else if(param1[0] == "mim")
            {
               _loc17_ = param1.hasOwnProperty("1") && param1[1];
               FacilitatorXtCommManager.sendInvisModeRequest(_loc17_);
               DebugUtility.debugTrace("mim:invis mode command received - request sent to server - shouldGoInvisible:" + _loc17_);
            }
            else if(param1[0] == "msn")
            {
               if(ExternalInterface.available)
               {
                  ExternalInterface.call("mrc",["sn",gMainFrame.server.serverIp]);
                  DebugUtility.debugTrace("mrc:sn command sent - ip:" + gMainFrame.server.serverIp);
               }
               DebugUtility.debugTrace("msn:get server node command received - sn response command sent");
            }
            else if(param1[0] == "mds")
            {
               if(_instance == null)
               {
                  return;
               }
               if(ExternalInterface.available)
               {
                  AvatarManager.playerAvatarWorldView.visible = false;
                  _instance.stage.invalidate();
                  _loc3_ = _instance.stage;
                  _loc16_ = new BitmapData(_loc3_.stageWidth,_loc3_.stageHeight);
                  _loc16_.draw(_loc3_);
                  _loc6_ = _loc16_.getPixels(new Rectangle(0,0,_loc3_.stageWidth,_loc3_.stageHeight));
                  _loc5_ = Base64.encodeByteArray(_loc6_);
                  AvatarManager.playerAvatarWorldView.visible = true;
                  ExternalInterface.call("mrc",["ds",_loc5_]);
                  DebugUtility.debugTrace("mrc:ds command sent - denScreenshotData:" + _loc16_);
               }
               DebugUtility.debugTrace("mds:get den screenshot command received - ds response command sent");
            }
            else if(param1[0] == "ixm")
            {
               DebugUtility.debugTrace("ixm:init external mode command received - setting extCallsActive to true");
               gMainFrame.clientInfo.extCallsActive = true;
               DebugUtility.debugTrace("ixm: extCallsActive set to true");
               DebugUtility.debugTrace("params.hasOwnProperty(\"1\"):" + param1.hasOwnProperty("1"));
               if(param1.hasOwnProperty("1") && param1[1] != null)
               {
                  _loc14_ = param1[1];
                  DebugUtility.debugTrace("roomNameOrId - params[1]:" + _loc14_);
                  gMainFrame.clientInfo.autoStartRoom = _loc14_;
                  _loc15_ = parseInt(param1[2]);
                  DebugUtility.debugTrace("shardId - params[2]:" + _loc15_);
                  if(_loc14_.indexOf("den") == 0 && _loc15_ != -1)
                  {
                     DebugUtility.debugTrace("ixm: WARNING - ignoring shardId:" + _loc15_ + " because room name:" + _loc14_ + " appears to be a den!");
                     _loc15_ = -1;
                  }
                  else if(_loc14_ == "adventure&" && _loc15_ < 0)
                  {
                     DebugUtility.debugTrace("ixm: ERROR - invalid shardId:" + _loc15_ + "! room name was the adventure keyword:" + _loc14_ + " so shardId needs to be an adventure script def id!");
                     return;
                  }
                  gMainFrame.clientInfo.autoStartRoomShardId = _loc15_;
                  DebugUtility.debugTrace("ixm:auto start room command received - request for " + param1[1] + " set up to be caught during server selection screen init");
               }
               _loc7_ = true;
               DebugUtility.debugTrace("params.hasOwnProperty(\"4\"):" + param1.hasOwnProperty("4"));
               if(param1.hasOwnProperty("4"))
               {
                  _loc7_ = Boolean(param1[4]);
                  DebugUtility.debugTrace("ghostMode - initGhostMode:" + _loc7_);
                  if(!_loc7_)
                  {
                     FacilitatorXtCommManager.sendInvisModeRequest(_loc7_);
                     DebugUtility.debugTrace("ixm:invis mode request sent to server - initGhostMode:" + _loc7_);
                  }
               }
               _loc12_ = "";
               if(param1.hasOwnProperty("5"))
               {
                  DebugUtility.debugTrace("initJumpUser - params[5]:" + param1[5]);
                  _loc12_ = param1[5];
                  if(_loc12_ != null && _loc12_ != "")
                  {
                     _roomMgrInitSetGotoUsername = _loc12_;
                  }
               }
               DebugUtility.debugTrace("ixm:auto jump to user position command - invisMode:" + gMainFrame.clientInfo.invisMode + " ijusername:" + _loc12_ + " _roomMgrInitSetGotoUsername:" + _roomMgrInitSetGotoUsername);
            }
         }
         catch(e:Error)
         {
            _loc11_ = "ERROR: Caught error in handleLocalExternalCall: " + e.message + " " + e.getStackTrace();
            DebugUtility.debugTrace(_loc11_);
         }
      }
      
      public function worldCtorHelper() : void
      {
         _instance = this;
         init();
      }
      
      public function init() : void
      {
         SBTracker.trackPageview("/game/play/loading/startup");
         DebugUtility.debugTrace("security:" + Security.sandboxType);
         DebugUtility.debugTrace("username:" + _gamePlayFlashVars.username);
         DebugUtility.debugTrace("auth_token:" + _gamePlayFlashVars.auth_token);
         _loginUsername = _gamePlayFlashVars.username;
         _loginAuthToken = _gamePlayFlashVars.auth_token;
         Security.allowDomain("*");
         _connectingToServer = false;
         _nextSFServerIdx = 0;
         loginHACK = 0;
         _layerManager = null;
         loadLayer = new DisplayLayer();
         addChild(loadLayer);
         _debugConnectionModeTxt = new DebugGUITextbox();
         _debugConnectionModeTxt.init(loadLayer,"Connection Mode: (Initializing...)",false,false,true,340);
         _debugConnectionModeTxt.txt.textColor = 2236962;
         _debugConnectionModeTxt.x = 50;
         _debugConnectionModeTxt.y = 350;
         _debugServerNodeTxt = new DebugGUITextbox();
         _debugServerNodeTxt.init(loadLayer,"Server Node: " + gMainFrame.server.serverIp,false,false,true,170);
         _debugServerNodeTxt.txt.textColor = 2236962;
         _debugServerNodeTxt.x = 50;
         _debugServerNodeTxt.y = 375;
         _debugShardIdTxt = new DebugGUITextbox();
         _debugShardIdTxt.init(loadLayer,"Shard: (Initializing...)",false,false,true,170);
         _debugShardIdTxt.txt.textColor = 2236962;
         _debugShardIdTxt.x = 50;
         _debugShardIdTxt.y = 400;
         _loginShardId = -1;
         _cachedShardIdToNodeMap = {};
         DebugUtility.debugTrace("gamePlay init() - _gamePlayFlashVars.isCreateAccount:" + _gamePlayFlashVars.isCreateAccount + " Server Node: " + gMainFrame.server.serverIp);
         try
         {
            _loginSO = SharedObject.getLocal("com/sbi/login","/");
         }
         catch(e:Error)
         {
            _loginSO = null;
         }
         LoadProgress.init(loadLayer);
         initHUDAssets();
         gMainFrame.stage.quality = "medium";
      }
      
      public function get layerManager() : LayerManager
      {
         return _layerManager;
      }
      
      public function set reconnecting(param1:Boolean) : void
      {
         _reconnecting = param1;
         GuiManager.reconnecting = param1;
      }
      
      public function get reconnecting() : Boolean
      {
         return _reconnecting;
      }
      
      public function set debugShardIdTxt(param1:String) : void
      {
         _debugShardIdTxt.text = "Shard: " + param1;
      }
      
      public function connectToNewServer() : void
      {
         if(_connectingToServer)
         {
            return;
         }
         if(ServerSelector.isOpen())
         {
            ServerSelector.destroy();
         }
         initConnect();
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
            initPreConnect();
         }
         else
         {
            initGamePalette();
         }
      }
      
      public function initGamePalette() : void
      {
         ImageServerURL.instance.addEventListener("OnGlobalPalette",handleGamePalette,false,0,true);
         ImageServerURL.instance.requestGlobalPalette();
      }
      
      private function handleGamePalette(param1:ImageServerEvent) : void
      {
         if(param1 && param1.genericData)
         {
            PaletteHelper.setGamePalette(param1.genericData.palette,param1.genericData.avatarPalette1,param1.genericData.avatarPalette2);
         }
         initPreConnect();
      }
      
      public function initPreConnect() : void
      {
         AJAudio.init(RoomManagerWorld.instance.broadcastMute);
         XtReplyDemuxer.init();
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"c");
         gMainFrame.server.addEventListener("OnConectionLost",onConnectionLost,false,0,true);
         initConnect();
      }
      
      public function initConnect() : void
      {
         if(!gMainFrame.server.isConnected)
         {
            if(gMainFrame.path == "")
            {
               gMainFrame.server.removeEventListener("OnConnect",onConnect);
               gMainFrame.server.removeEventListener("OnLogin",onWorldLogIn);
               gMainFrame.server.addEventListener("OnConnect",onConnect,false,0,true);
               gMainFrame.server.addEventListener("OnLogin",onWorldLogIn,false,0,true);
            }
            _debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
            DebugUtility.debugTrace("initConnect Server Node: " + gMainFrame.server.serverIp);
            _connectingToServer = true;
            gMainFrame.server.connect();
         }
         else
         {
            DebugUtility.debugTrace("ERROR: already connected?!");
         }
      }
      
      public function initShardSelectionAssets() : void
      {
         _layerManager = new LayerManager(this,loadLayer);
         roomMgr = RoomManagerWorld.instance;
         roomMgr.init(this.layerManager);
         if(_loginShardId == -1)
         {
            roomMgr.shardId = -1;
         }
         if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
         {
            roomMgr.jamaaMilliseconds = gMainFrame.clientInfo.currentTimestamp * 1000;
         }
         var _loc4_:DisplayLayer = _layerManager.gui;
         var _loc2_:DisplayLayer = _layerManager.fps;
         GenericListXtCommManager.init();
         GuiManager.init(_loc4_,_loc2_,_layerManager.room_avatars,_layerManager.room_chat,_layerManager.bkg,roomMgr.setFocus);
         RoomXtCommManager.init();
         DenXtCommManager.init(DenSwitch.denListResponse);
         XtReplyDemuxer.addModule(GenericListXtCommManager.handleXtReply,"g");
         var _loc3_:ContextMenu = new ContextMenu();
         _loc3_.addEventListener("menuSelect",onContextMenuHandler,false,0,true);
         _loc3_.hideBuiltInItems();
         var _loc6_:ContextMenuItem = new ContextMenuItem("Animal Jam");
         _loc3_.customItems.push(_loc6_);
         var _loc5_:ContextMenuItem = new ContextMenuItem("OS: " + Capabilities.os,false,false);
         var _loc1_:ContextMenuItem = new ContextMenuItem("Player: " + Capabilities.playerType + " " + Capabilities.version,false,false);
         _loc3_.customItems.push(_loc5_);
         _loc3_.customItems.push(_loc1_);
         this.contextMenu = _loc3_;
         _stats = new Stats();
         _layerManager.fps.addChild(_stats);
         _stats.visible = false;
         stage.addEventListener("keyDown",keyDownListener,false,0,true);
      }
      
      public function initAssets() : void
      {
         Fonts.init();
         if(_layerManager == null)
         {
            _layerManager = new LayerManager(this,loadLayer);
            roomMgr = RoomManagerWorld.instance;
            roomMgr.init(this.layerManager);
            if(_loginShardId == -1)
            {
               roomMgr.shardId = -1;
            }
         }
         var _loc3_:DisplayLayer = _layerManager.gui;
         var _loc1_:DisplayLayer = _layerManager.fps;
         AchievementManager.init(_loc1_);
         PartyManager.init();
         KeepAlive.init(_loc3_,gMainFrame.server.getIsConnected,FacilitatorXtCommManager.sendIdleTimeOut);
         BuddyManager.init(_loc3_,GuiManager.mainHud.buddyListBtn);
         NGFactManager.init(_loc3_,_layerManager.room_orbs);
         PollManager.init(_loc3_,_layerManager.room_orbs);
         FeedbackManager.init(_loc3_,_layerManager.room_orbs);
         ECardManager.init(_loc3_,GuiManager.mainHud.eCardBtn);
         AvatarWorldView.init({"showUserInfoPopup":BuddyCard.showBuddyCard});
         MinigameManager.init(_loc3_,roomMgr);
         AchievementXtCommManager.init(MinigameManager.inMinigame,GuiManager.onMyUserVarsReceived,GuiManager.setGemBonusValues);
         LayerAnim.useMaxThrottle = MinigameManager.inInRoomGame;
         AvatarManager.init(_layerManager.room_avatars,_layerManager.room_chat,_layerManager.flying_avatars,_layerManager.preview_room_avatar,_layerManager.preview_room_flying_avatar);
         if(gMainFrame.clientInfo.extCallsActive)
         {
            DebugUtility.debugTrace("auto jump to user position command - roomMgr:" + roomMgr + " _roomMgrInitSetGotoUsername:" + _roomMgrInitSetGotoUsername);
            if(_roomMgrInitSetGotoUsername != null && _roomMgrInitSetGotoUsername != "")
            {
               roomMgr.setGotoUsername(_roomMgrInitSetGotoUsername,false);
            }
         }
         UserCommXtCommManager.init();
         ItemXtCommManager.init(AvatarManager.getAvatarByUsernamePerUserAvId,AvatarManager.processAcIlCombo,GuiManager,DenXtCommManager.handleDenShopList,BuddyCard.updateDropDown);
         NameBar.getNamebarIconsFunc = GuiManager.getNamebarBadgeList;
         FacilitatorXtCommManager.init(_loc3_);
         TradeXtCommManager.init();
         PetManager.init();
         QuestXtCommManager.init();
         QuestManager.init(_layerManager);
         TradeManager.init(_loc3_);
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
         _loc1_.addChild(_debugConnectionModeTxt);
         _loc1_.addChild(_debugServerNodeTxt);
         _loc1_.addChild(_debugShardIdTxt);
         addEventListener("enterFrame",heartbeat,false,0,true);
         lastTimer = getTimer();
         ServerSelector.fillNamesArray(true);
         var _loc2_:DefPacksDefHelper = new DefPacksDefHelper();
         _loc2_.init(1038,GenericListXtCommManager.genericListTypeResponse,null,2);
         DefPacksDefHelper.mediaArray[1038] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1025,QuestXtCommManager.questNPCDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1025] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1011,RoomXtCommManager.roomDefResponse,null,2);
         DefPacksDefHelper.mediaArray[1011] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1040,DenXtCommManager.denRoomResponse,null,2);
         DefPacksDefHelper.mediaArray[1040] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1053,MovieXtCommManager.movieNodeResponse,null,2);
         DefPacksDefHelper.mediaArray[1053] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1054,DiamondXtCommManager.diamondResponse,null,2);
         DefPacksDefHelper.mediaArray[1054] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1052,QuestXtCommManager.scriptResponse,null,2);
         DefPacksDefHelper.mediaArray[1052] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1046,PetXtCommManager.petDefsResponse,null,2);
         DefPacksDefHelper.mediaArray[1046] = _loc2_;
         _loc2_ = new DefPacksDefHelper();
         _loc2_.init(1042,AchievementXtCommManager.onAchievementDefPacksResponse,null,2);
         DefPacksDefHelper.mediaArray[1042] = _loc2_;
         GuiManager.volumeMgr.loadAssets(mapAssetsLoaded);
      }
      
      public function mapAssetsLoaded() : void
      {
         gMainFrame.server.setInitRoom();
         roomMgr.chosenLoginFinished();
         if(gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.accountType == 5)
         {
            _debugAudioVolumeSlider = new DebugGUISlider();
            _debugAudioVolumeSlider.init(_layerManager,roomMgr.debugAudioVolumeChanged,false);
         }
         _debugCheckbox1 = new DebugGUICheckbox();
         _debugCheckbox1.init(_layerManager.fps,null,"Background Layer",true);
         _debugCheckbox1.x = 400;
         _debugCheckbox1.y = 250;
         _debugCheckbox2 = new DebugGUICheckbox();
         _debugCheckbox2.init(_layerManager.fps,null,"Sortable Layer",true);
         _debugCheckbox2.x = 400;
         _debugCheckbox2.y = 275;
         _debugCheckbox3 = new DebugGUICheckbox();
         _debugCheckbox3.init(_layerManager.fps,null,"Foreground Layer",true);
         _debugCheckbox3.x = 400;
         _debugCheckbox3.y = 300;
         _debugVersionTxt = new DebugGUITextbox();
         _debugVersionTxt.init(_layerManager.fps,"world.swf Filesize: " + this.loaderInfo.bytesTotal + " Version: " + "1.0.110410" + " | buildinfo.xml - buildinfo.xml not loaded yet!");
         _debugVersionTxt.x = 50;
         _debugVersionTxt.y = 100;
         gMainFrame.loaderCache.openFile("buildinfo.xml",buildInfoDebugLoadCompleteHandler,null,"text");
      }
      
      private function buildInfoDebugLoadCompleteHandler(param1:LoaderEvent) : void
      {
         var _loc2_:XML = null;
         if(param1.status)
         {
            _loc2_ = new XML(param1.entry.data);
            _debugVersionTxt.text = "world.swf - Filesize: " + this.loaderInfo.bytesTotal + " Version: " + "1.0.110410" + " | buildinfo.xml - Time: " + _loc2_.time.text() + " Id: " + _loc2_.id.text();
         }
         else
         {
            _debugVersionTxt.text = "world.swf - Filesize: " + this.loaderInfo.bytesTotal + " Version: " + "1.0.110410" + " | buildinfo.xml - buildinfo.xml not found!";
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
         roomMgr.destroy();
         roomMgr = null;
         removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyDown",keyDownListener);
         gMainFrame.server.removeEventListener("OnConectionLost",onConnectionLost);
         if(gMainFrame.path == "")
         {
            gMainFrame.server.removeEventListener("OnConnect",onConnect);
            gMainFrame.server.removeEventListener("OnLogin",onWorldLogIn);
         }
      }
      
      public function showServerSelectorMore(param1:Object) : void
      {
         var _loc3_:String = null;
         var _loc5_:int = 0;
         var _loc9_:* = null;
         var _loc6_:Array = [];
         var _loc10_:int = -1;
         var _loc8_:int = 2;
         var _loc11_:int = 0;
         while(param1.hasOwnProperty(_loc8_))
         {
            _loc3_ = param1[_loc8_++];
            while(!isNaN(Number(param1[_loc8_])))
            {
               _loc5_ = int(param1[_loc8_++]);
               if(_loc5_ > _loc10_)
               {
                  _loc10_ = _loc5_;
               }
               if(roomMgr.shardId == _loc5_)
               {
                  _loc8_ += 3;
               }
               else
               {
                  _cachedShardIdToNodeMap[_loc5_] = _loc3_;
                  _loc6_[_loc11_++] = {
                     "i":_loc5_,
                     "l":param1[_loc8_++],
                     "p":param1[_loc8_++],
                     "b":param1[_loc8_++]
                  };
               }
            }
         }
         _loc6_.sortOn(["l","b","p","i"],[16,2 | 0x10,2 | 0x10,16]);
         _cachedShardInfo = _loc6_;
         var _loc2_:Object = {};
         var _loc4_:int = 0;
         var _loc7_:int = LocalizationManager.accountLanguage;
         for each(_loc9_ in _loc6_)
         {
            if(_loc9_.l == _loc7_)
            {
               if(int(_loc9_.p) < 4)
               {
                  _loc2_[_loc4_++] = _loc9_.i;
                  _loc2_[_loc4_++] = _loc9_.l;
                  _loc2_[_loc4_++] = int(_loc9_.p) > 0 ? _loc9_.p : (int(_loc9_.b) > 0 ? "1" : "0");
                  _loc2_[_loc4_++] = _loc9_.b;
               }
            }
         }
         for each(_loc9_ in _loc6_)
         {
            if(_loc9_.l != _loc7_)
            {
               if(!(_loc7_ == LocalizationManager.LANG_ENG && _loc9_.l != _loc7_))
               {
                  if(int(_loc9_.p) < 4)
                  {
                     _loc2_[_loc4_++] = _loc9_.i;
                     _loc2_[_loc4_++] = _loc9_.l;
                     _loc2_[_loc4_++] = int(_loc9_.p) > 0 ? _loc9_.p : (int(_loc9_.b) > 0 ? "1" : "0");
                     _loc2_[_loc4_++] = _loc9_.b;
                  }
               }
            }
         }
         for each(_loc9_ in _loc6_)
         {
            if(int(_loc9_.p) >= 4)
            {
               if(!(_loc7_ == LocalizationManager.LANG_ENG && _loc9_.l != _loc7_))
               {
                  _loc2_[_loc4_++] = _loc9_.i;
                  _loc2_[_loc4_++] = _loc9_.l;
                  _loc2_[_loc4_++] = int(_loc9_.p) > 0 ? _loc9_.p : (int(_loc9_.b) > 0 ? "1" : "0");
                  _loc2_[_loc4_++] = _loc9_.b;
               }
            }
         }
         ServerSelector.setupAllShards(_loc2_,_loc10_);
      }
      
      public function joinChosenShardIdNode(param1:int = -1, param2:String = null) : void
      {
         if(param1 != -1)
         {
            _loginShardId = param1;
            roomMgr.shardId = param1;
            for each(var _loc3_:Object in _cachedShardInfo)
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
         roomMgr._gotNewShardId = true;
         roomMgr.joinNewShardRoom();
      }
      
      public function loginToChosenServer() : void
      {
         var _loc2_:String = null;
         var _loc1_:SFEvent = null;
         if(!gMainFrame.server.isConnected)
         {
            gMainFrame.server.connect();
         }
         else
         {
            _loc2_ = _loginUsername;
            if(_loc2_ != null)
            {
               if(_loginUsername && _loginUsername.indexOf("%") == -1 && gMainFrame.clientInfo.sessionId != undefined)
               {
                  _loc2_ += "%" + gMainFrame.clientInfo.sessionId;
               }
               _loc2_ += "#" + LocalizationManager.accountLanguage;
               _loc2_ += "!" + gMainFrame.clientInfo.deployVersion;
               gMainFrame.server.logIn("sbiLogin",_loc2_,_loginAuthToken);
            }
            else
            {
               _loc1_ = new SFEvent("OnLogin");
               _loc1_.status = false;
               onWorldLogIn(_loc1_);
            }
         }
      }
      
      private function keyDownListener(param1:KeyboardEvent) : void
      {
         if(gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.accountType == 5)
         {
            if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 113)
            {
               _stats.visible = !_stats.visible;
               _debugServerNodeTxt.visible = !_debugServerNodeTxt.visible;
               _debugConnectionModeTxt.visible = !_debugConnectionModeTxt.visible;
               _debugShardIdTxt.visible = !_debugShardIdTxt.visible;
               if(_stats.visible)
               {
                  stage.addChild(_layerManager.fps);
               }
               else
               {
                  stage.removeChild(_layerManager.fps);
               }
            }
            else if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 116)
            {
               GuiManager.toggleHud();
            }
            else if(!param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 117)
            {
               if(gMainFrame.stage.quality == "HIGH")
               {
                  gMainFrame.stage.quality = "medium";
               }
               else if(gMainFrame.stage.quality == "MEDIUM")
               {
                  gMainFrame.stage.quality = "low";
               }
               else
               {
                  gMainFrame.stage.quality = "high";
               }
            }
            else if(param1.ctrlKey && !param1.shiftKey && !param1.altKey && param1.keyCode == 118)
            {
               BuddyXtCommManager.sendBuddyFillRequest();
            }
         }
      }
      
      private function onContextMenuHandler(param1:ContextMenuEvent) : void
      {
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc2_:int = getTimer();
         AvatarManager.heartbeat(33,_loc2_ - lastTimer);
         roomMgr.heartbeat(33,_loc2_ - lastTimer);
         QuestManager.heartbeat();
         LayerAnim.heartbeat();
         PartyManager.updateTime(_loc2_);
         BuddyManager.heartbeat(_loc2_ - lastTimer);
         lastTimer = _loc2_;
      }
      
      public function onConnect(param1:SFEvent) : void
      {
         _connectingToServer = false;
         if(param1.status)
         {
            _debugConnectionModeTxt.text = "Bluebox Connection: " + gMainFrame.server.isBlueboxMode();
            DebugUtility.debugTrace("onConnect - _gamePlayFlashVars.isCreateAccount:" + _gamePlayFlashVars.isCreateAccount + " gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive);
            if(!_layerManager)
            {
               initShardSelectionAssets();
            }
            loginToChosenServer();
         }
         else if(_reconnecting)
         {
            if(!gMainFrame.server.autoAttemptHttp)
            {
               gMainFrame.server.autoAttemptHttp = true;
               _debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
               _debugConnectionModeTxt.text = "Attempting Reconnecting/Direct Bluebox Autoattempt Connection...";
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
            if(_nextSFServerIdx < gMainFrame.server.serverIps.length)
            {
               gMainFrame.server.setNewServer(_nextSFServerIdx);
               _debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
               _debugConnectionModeTxt.text = "Attempting Connection...";
               DebugUtility.debugTrace("trying next Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
               _nextSFServerIdx = _nextSFServerIdx + 1;
            }
            else
            {
               gMainFrame.server.autoAttemptHttp = true;
               _nextSFServerIdx = 0;
               gMainFrame.server.setNewServer(_nextSFServerIdx);
               _debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
               _debugConnectionModeTxt.text = "Starting Over With BlueBox Autoattempt Connection...";
               DebugUtility.debugTrace("trying first bluebox Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
            }
         }
         else if(_nextSFServerIdx < gMainFrame.server.blueboxIps.length)
         {
            gMainFrame.server.setNewServer(_nextSFServerIdx);
            DebugUtility.debugTrace("trying next bluebox Server Node: " + gMainFrame.server.serverIp);
            gMainFrame.server.connect();
            _nextSFServerIdx = _nextSFServerIdx + 1;
         }
         else
         {
            DebugUtility.debugTrace("entire cluster/game is down! _nextSFServerIdx:" + _nextSFServerIdx + " serverIps:" + gMainFrame.server.serverIps + " blueboxIps:" + gMainFrame.server.blueboxIps);
            new SBStandardPopup(stage,LocalizationManager.translateIdOnly(14695),false);
         }
      }
      
      public function onWorldLogIn(param1:SFEvent) : void
      {
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:String = null;
         var _loc2_:String = null;
         DebugUtility.debugTrace("World onLogIn, status:" + param1.status);
         if(param1.status)
         {
            DebugUtility.debugTrace("World onLogIn successful! gMainFrame.clientInfo.extCallsActive:" + gMainFrame.clientInfo.extCallsActive + " _layerManager:" + _layerManager + " evt.userName:" + param1.userName + " gMainFrame.server.serverIp:" + gMainFrame.server.serverIp + " evt.obj.firstFiveMinutes:" + param1.obj.firstFiveMinutes);
            DebugUtility.debugTrace("World onLogIn successful! roomMgr.shardId:" + roomMgr.shardId + " _loginUsername:" + _loginUsername + " _loginShardId:" + _loginShardId);
            gMainFrame.server.setInitRoom();
            gMainFrame.clientInfo.dbUserId = param1.obj.dbUserId;
            gMainFrame.clientInfo.accountType = param1.obj.accountType;
            gMainFrame.clientInfo.avName = param1.obj.avName;
            gMainFrame.clientInfo.dailyGiftIndex = param1.obj.dailyGiftIndex;
            UserCurrency.initCurrency();
            _loc6_ = 0;
            while(_loc6_ < SbiConstants.CURRENCY_NAMES.length)
            {
               UserCurrency.setCurrency(param1.obj[SbiConstants.CURRENCY_NAMES[_loc6_] + "Count"],_loc6_);
               _loc6_++;
            }
            gMainFrame.clientInfo.hasOnlineBuddies = param1.obj.hasOnlineBuddies;
            gMainFrame.clientInfo.interactions = param1.obj.interactions;
            gMainFrame.clientInfo.jamaaDate = param1.obj.jamaaDate;
            gMainFrame.clientInfo.newspaperTimestamp = param1.obj.newspaperTimestamp;
            gMainFrame.clientInfo.numAJHQGiftCards = param1.obj.numAJHQGiftCards;
            gMainFrame.clientInfo.numDaysLeftOnSubscription = param1.obj.numDaysLeftOnSubscription;
            gMainFrame.clientInfo.numRedemptionCards = param1.obj.numRedemptionCards;
            gMainFrame.clientInfo.numUnreadECards = param1.obj.numUnreadECards;
            gMainFrame.clientInfo.recyclePercentage = param1.obj.recyclePercentage;
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
            gMainFrame.userInfo.webPlayerWallSettings = param1.obj.webWallStatus;
            gMainFrame.userInfo.myUUID = param1.obj.uuid;
            gMainFrame.userInfo.playerWallSettings = param1.obj.playerWallSettings;
            gMainFrame.userInfo.isMember = Utility.isMember(param1.obj.accountType);
            gMainFrame.userInfo.firstFiveMinutes = param1.obj.pendingFlags & 1;
            gMainFrame.userInfo.needFastPass = (param1.obj.pendingFlags & 0x10) != 0;
            DenSwitch.setActiveDenIdx(param1.obj.activeDenRoomInvId);
            PetManager.myActivePetInvId = param1.obj.activePetInvId;
            _debugServerNodeTxt.text = "Server Node: " + gMainFrame.server.serverIp;
            gMainFrame.server.triggerWorldXtReadyCmd();
            gMainFrame.myFlashVarUserName = param1.userName;
            GuiManager.setupSharedObject();
            GuiManager.setupSoundButton();
            gMainFrame.clientInfo.invisMode = gMainFrame.userInfo.isModerator;
            if(_reconnecting)
            {
               _reconnecting = false;
               if(gMainFrame.userInfo.avtDefsCached)
               {
                  _loc3_ = int(gMainFrame.server.userId);
                  AvatarManager.playerSfsUserId = _loc3_;
                  UserCommXtCommManager.playerSfsUserId = _loc3_;
                  AvatarSwitch.playerSfsUserId = _loc3_;
                  MinigameManager.userId = _loc3_;
                  roomMgr.reconnectNodeSwitchLoginFinished();
                  return;
               }
            }
            gMainFrame.clientInfo.accountTypeChanged = param1.obj.accountTypeChanged;
            gMainFrame.clientInfo.lastBroadcastMessage = param1.obj.lastBroadcastMessage;
            gMainFrame.clientInfo.sessionId = param1.obj.sessionId;
            GuiManager.setupAllItems();
            if(gMainFrame.server.isBlueboxMode())
            {
               SBTracker.trackPageview("/game/play/isBlueBox",-1,1);
            }
            AvatarSwitch.init();
            initAssets();
         }
         else if(gMainFrame.clientInfo.hasOwnProperty("autoLogin" + ++loginHACK))
         {
            _loc4_ = gMainFrame.clientInfo["autoLogin" + loginHACK];
            _loc5_ = _loc4_[0];
            _loc5_ = _loc5_ + ("#" + LocalizationManager.accountLanguage);
            _loc5_ = _loc5_ + ("!" + gMainFrame.clientInfo.deployVersion);
            gMainFrame.server.logIn("sbiLogin",_loc5_,_loc4_[1]);
            _loginUsername = _loc4_[0];
            _loginAuthToken = _loc4_[1];
         }
         else
         {
            _reconnecting = false;
            SBTracker.push();
            if(param1.obj && param1.obj.hasOwnProperty("dbUserId"))
            {
               gMainFrame.clientInfo.dbUserId = param1.obj.dbUserId;
            }
            else
            {
               gMainFrame.clientInfo.dbUserId = 0;
            }
            if(param1.statusId == -11)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/inUse");
               _loc2_ = LocalizationManager.translateIdOnly(11197);
            }
            else if(param1.statusId == -12)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/accountMaintenance");
               _loc2_ = LocalizationManager.translateIdOnly(11198);
            }
            else if(param1.statusId == -16)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/serverMaintenance");
               _loc2_ = LocalizationManager.translateIdOnly(11199);
            }
            else if(param1.statusId == -14)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/tooManyConnections");
               _loc2_ = LocalizationManager.translateIdOnly(11200);
            }
            else if(param1.statusId == -15)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/bannedUser");
               _loc2_ = LocalizationManager.translateIdOnly(11201);
            }
            else if(param1.statusId == -24)
            {
               SBTracker.trackPageview("/game/play/popup/loginError/clientMismatch");
               Utility.reloadSWFOrGetIp();
            }
            else
            {
               SBTracker.trackPageview("/game/play/popup/loginError");
               _loc2_ = LocalizationManager.translateIdOnly(11202);
            }
            SBTracker.handleErrorTracking(gMainFrame.clientInfo.dbUserId,-1,0,Math.abs(param1.statusId),-1,"failure",gMainFrame.server.serverIp,-1,-1);
            new SBStandardPopup(gMainFrame.stage,_loc2_,false);
         }
      }
      
      public function onConnectionLost(param1:SFEvent) : void
      {
         var msg:String;
         var evt:SFEvent = param1;
         if(AvatarManager.playerSfsUserId >= 0)
         {
            roomMgr.exitRoom();
            RoomXtCommManager.loadingNewRoom = false;
            AvatarManager.connectionLost();
         }
         if(_reconnecting)
         {
            connectToNewServer();
            return;
         }
         if(PlayerWallManager)
         {
            PlayerWallManager.destroy();
         }
         if(GuiManager.chatHist)
         {
            GuiManager.chatHist.showChatInput(false);
         }
         if(GuiManager.guiLayer && GuiManager.guiLayer.contains(LoadProgress.loadScreen))
         {
            GuiManager.guiLayer.removeChild(LoadProgress.loadScreen);
         }
         if(_idleTimeoutPopup)
         {
            DebugUtility.debugTrace("WARNING: idleTimeoutPopup is not null!");
            _idleTimeoutPopup.destroy();
            _idleTimeoutPopup = null;
         }
         idleBlackout = new Sprite();
         with(idleBlackout.graphics)
         {
            beginFill(0);
            drawRect(0,0,MainFrame.VIEW_WIDTH,MainFrame.VIEW_WIDTH);
         }
         while(_layerManager.gui.numChildren >= 1)
         {
            _layerManager.gui.removeChildAt(0);
         }
         _layerManager.gui.addChild(idleBlackout);
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
         _idleTimeoutPopup = new SBOkPopup(gMainFrame.stage,msg,false,idleTimeoutConfirmHandler);
      }
      
      public function idleTimeoutConfirmHandler(param1:MouseEvent) : void
      {
         if(_idleTimeoutPopup)
         {
            _idleTimeoutPopup.destroy();
            _idleTimeoutPopup = null;
         }
         _layerManager.gui.removeChild(idleBlackout);
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

