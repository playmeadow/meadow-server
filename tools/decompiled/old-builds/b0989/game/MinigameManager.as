package game
{
   import achievement.AchievementManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import buddy.Buddy;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFEvent;
   import com.sbi.client.SFRoom;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.*;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.Dictionary;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GameCardPopup;
   import gui.GuiManager;
   import gui.InstructionScreenBuilder;
   import gui.LoadingSpiral;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import pet.WorldPet;
   import quest.QuestManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class MinigameManager
   {
      
      private static var _userId:int;
      
      private static var _parentLayer:DisplayObjectContainer;
      
      private static var _minigameRef:IMinigame;
      
      private static var _primaryRoomName:String;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _gameCardPopup:GameCardPopup;
      
      private static var _joinGameObj:Object;
      
      private static var _oldJoinGameObj:Object;
      
      private static var _joinFrgCallback:Function;
      
      private static var _inMinigame:Boolean;
      
      private static var _waitlistP1X:Number;
      
      private static var _waitlistP2X:Number;
      
      private static var _waitlistP3X:Number;
      
      private static var _waitlistP4X:Number;
      
      private static var _pvpGameDefId:int;
      
      private static var _pvpUserName:String;
      
      private static var _pvpCancelMSReceived:Boolean;
      
      private static var _buddyGameInviteContent:MovieClip;
      
      private static var _buddyGamePopup:SBPopup;
      
      private static var _miniSpiral:LoadingSpiral;
      
      private static var _pvpMedia:Array;
      
      private static var _pvpAmISender:Boolean;
      
      private static var _inInRoomGame:Boolean;
      
      private static var _minReqPlayers:int;
      
      private static var _maxAllowedPlayers:int;
      
      private static var joinGameX:int;
      
      private static var joinGameY:int;
      
      private static var _roomName:String;
      
      private static var _waitIds:Array;
      
      private static var _startData:Array;
      
      private static var _frgLoader:Loader;
      
      private static var _mmToSendWhenRefLoaded:Array;
      
      private static var _waitListPopup:SBPopup;
      
      private static var _waitList:MovieClip;
      
      private static var ConfirmSkin:Class;
      
      private static var JoinGameSkin:Class;
      
      private static var JoinGameContent:Class;
      
      private static var MinigameLobbyContent:Class;
      
      private static var _gemSerialNumber:int;
      
      private static var _scoreSN:int;
      
      private static var _petMasterySerialNumber:int;
      
      private static var _petMasteryQueuePopup:Boolean;
      
      private static var _awardGemsQueue:Array;
      
      private static var _awardMasteryPointsQueue:Array;
      
      private static var _primaryRoomNameBypass:Boolean;
      
      private static var _proModeId:int;
      
      public static var _pvpPromptReplay:Boolean;
      
      private static var _gameCloseCallback:Function;
      
      public static var minigameInfoCache:MinigameInfoCache;
      
      public static var _leaderBoardCache:Dictionary;
      
      private static const keepGameBase:GameBase = null;
      
      public static const PET_SALON_DEF_ID:int = 52;
      
      public static const PET_SALON_PARTY_DEF_ID:int = 81;
      
      public static const AVATAR_WIDTH:int = 150;
      
      public static const AVATAR_HEIGHT:int = 150;
      
      public static const PET_WASH_DEF_ID:int = 43;
      
      private static var _pvpCancelSubRoomId:int = -1;
      
      private static var _frgWaiting:Boolean = false;
      
      private static var _rejoin:Boolean = false;
      
      public static const GameTotem:Class = MinigameManager_GameTotem;
      
      public function MinigameManager()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer, param2:RoomManagerWorld) : void
      {
         _parentLayer = param1;
         _roomMgr = param2;
         _userId = gMainFrame.server.userId;
         _primaryRoomName = "";
         JoinGameSkin = getDefinitionByName("JoinGameSkin") as Class;
         JoinGameContent = getDefinitionByName("JoinGameContent") as Class;
         MinigameLobbyContent = getDefinitionByName("MinigameLobbyContent") as Class;
         _frgWaiting = false;
         _inMinigame = false;
         _mmToSendWhenRefLoaded = null;
         minigameInfoCache = new MinigameInfoCache();
         minigameInfoCache.init();
         _buddyGameInviteContent = new (getDefinitionByName("BuddyGameInviteContent") as Class)();
         _buddyGamePopup = new SBPopup(_parentLayer,new (getDefinitionByName("BuddyGameInviteSkin") as Class)(),_buddyGameInviteContent,false,true,false,false,true);
         _buddyGameInviteContent.invite.visible = false;
         _buddyGameInviteContent.request.visible = false;
         _buddyGameInviteContent.refuse.visible = false;
         _buddyGameInviteContent.invite.cancelBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPVPCloseInvite);
         _buddyGameInviteContent.request.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPVPNoInvite);
         _buddyGameInviteContent.request.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPVPYesInvite);
         _buddyGameInviteContent.refuse.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,onPVPCloseInvite);
         _miniSpiral = new LoadingSpiral(_buddyGameInviteContent.invite,105,37);
         _miniSpiral.scaleX = 0.5;
         _miniSpiral.scaleY = 0.5;
         _pvpMedia = new Array();
         _gemSerialNumber = -1;
         _scoreSN = -1;
         _petMasterySerialNumber = -1;
         _petMasteryQueuePopup = false;
         _awardGemsQueue = new Array();
         _awardMasteryPointsQueue = new Array();
         _pvpPromptReplay = false;
         _leaderBoardCache = new Dictionary();
         gMainFrame.server.addEventListener(SFEvent.ON_JOIN_ROOM,joinRoomHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         minigameInfoCache = null;
         gMainFrame.server.removeEventListener(SFEvent.ON_JOIN_ROOM,joinRoomHandler);
      }
      
      public static function setPrimaryRoomNameBypass() : void
      {
         _primaryRoomNameBypass = true;
      }
      
      private static function leave(param1:Boolean = false) : void
      {
         var _loc2_:Boolean = false;
         if(_frgWaiting)
         {
            _loc2_ = true;
         }
         if(_inInRoomGame)
         {
            RoomXtCommManager.sendRoomLeaveRequest(gMainFrame.server.getCurrentRoomId(true));
         }
         else
         {
            if(_primaryRoomName != "")
            {
               if(gMainFrame.server.isConnected)
               {
                  _roomMgr.minigameJoinRoom(_primaryRoomName);
               }
            }
            else if(_frgWaiting)
            {
               MinigameXtCommManager.sendMinigameJoinRequest(_joinGameObj.typeDefId);
               _frgWaiting = false;
            }
            if(_frgLoader)
            {
               _frgLoader.unloadAndStop(true);
               _frgLoader.parent.removeChild(_frgLoader);
               _frgLoader = null;
            }
         }
         if(Boolean(_waitListPopup) && _waitListPopup.visible)
         {
            _waitListPopup.close();
            _waitListPopup.content["p1"].x = _waitlistP1X;
            _waitListPopup.content["p2"].x = _waitlistP2X;
            _waitListPopup.content["p3"].x = _waitlistP3X;
            _waitListPopup.content["p4"].x = _waitlistP4X;
         }
         leaveGame(_loc2_);
         if(_minigameRef)
         {
            _minigameRef = null;
         }
         _mmToSendWhenRefLoaded = null;
         _roomName = "";
         if(param1)
         {
            _rejoin = true;
         }
         _proModeId = 0;
         GuiManager.chatHist.reAddKeyListeners();
      }
      
      private static function leaveGame(param1:Boolean) : void
      {
         SBTracker.pop();
         if(_minigameRef)
         {
            KeepAlive.stopKATimer(DisplayObjectContainer(_minigameRef).stage);
         }
         GuiManager.handleGameExit();
         _inMinigame = false;
         minigameInfoCache.currMinigameId = -1;
         gMainFrame.stage.quality = StageQuality.MEDIUM;
         DarkenManager.showLoadingSpiral(false);
         if(!_inInRoomGame && !param1)
         {
            LoadProgress.show(true,LoadProgress.LOADING_ROOM);
         }
         if(_pvpGameDefId >= 0)
         {
            if(_pvpPromptReplay)
            {
               new SBYesNoPopup(GuiManager.guiLayer,"Do you want to replay?",true,onYesNoReplay,{
                  "gameDefId":_pvpGameDefId,
                  "userName":_pvpUserName,
                  "mediaRefId":minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId
               });
            }
            _pvpGameDefId = -1;
            _pvpUserName = "";
            _pvpCancelSubRoomId = -1;
            _pvpCancelMSReceived = false;
         }
         if(_gameCloseCallback != null)
         {
            _gameCloseCallback();
            _gameCloseCallback = null;
         }
         if(_inInRoomGame)
         {
            AvatarManager.showAvtAndChatLayers(true);
            PetManager.checkAndOpenMasteryPopup(_petMasteryQueuePopup);
            _petMasteryQueuePopup = false;
         }
         _inInRoomGame = false;
         AchievementManager.displayNewAchievements();
      }
      
      private static function createGameWindow(param1:String = "") : void
      {
         if(_pvpGameDefId >= 0)
         {
            killJoinGamePopup();
         }
         _oldJoinGameObj = null;
         if(_joinGameObj == null)
         {
            if(_pvpCancelSubRoomId <= 0)
            {
               return;
            }
            gMainFrame.server.setCurrSubRoomId(_pvpCancelSubRoomId);
            if(gMainFrame.server.getCurrentRoomId(true) > 0)
            {
               RoomXtCommManager.sendRoomLeaveRequest(gMainFrame.server.getCurrentRoomId(true),true);
               _mmToSendWhenRefLoaded = null;
               _pvpCancelMSReceived = false;
            }
            else
            {
               _pvpCancelMSReceived = true;
            }
            return;
         }
         var _loc2_:String = getGameName(_joinGameObj.typeDefId);
         if(_joinGameObj.typeDefId == 48)
         {
            _loc2_ += " Land";
         }
         else if(_joinGameObj.typeDefId == 66)
         {
            _loc2_ += " Ocean";
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/minigame/#" + _loc2_);
         if(Boolean(_waitListPopup) && Boolean(_waitListPopup.content) && Boolean(_waitListPopup.content["waitingTxt"]))
         {
            _waitListPopup.content["waitingTxt"].text = "Game starting...";
         }
         if(param1 == "")
         {
            param1 = "games/" + _joinGameObj.swfName + "/" + _joinGameObj.swfName + ".swf";
         }
         if(_inInRoomGame)
         {
            gMainFrame.loaderCache.openFile(gMainFrame.path + param1,loadCompleteHandler);
            if(_pvpGameDefId >= 0)
            {
               _buddyGamePopup.close();
               DarkenManager.showLoadingSpiral(true);
            }
         }
         else
         {
            _roomMgr.exitRoom();
            LoadProgress.load(param1,1,loadProgressCompleteHandler);
         }
      }
      
      private static function killJoinGamePopup(param1:MouseEvent = null) : void
      {
         if(_gameCardPopup)
         {
            _gameCardPopup.destroy();
            _gameCardPopup = null;
         }
      }
      
      private static function onLeaderBoardedClicked() : void
      {
         if(_joinGameObj != null && _joinGameObj.typeDefId != -1)
         {
            onLeaderBoardSelected();
         }
      }
      
      private static function onLeaderBoardSelected() : void
      {
         if(_gameCardPopup != null && _joinGameObj != null && _joinGameObj.typeDefId != -1)
         {
            if(_leaderBoardCache[_joinGameObj.typeDefId] != null && getTimer() - _leaderBoardCache[_joinGameObj.typeDefId]._cacheTime < 60000)
            {
               switch(_gameCardPopup.getVisibleLeaderBoard())
               {
                  case GameCardPopup.LEADERBOARD_TYPE_ALLTIME:
                     _gameCardPopup.populateLeaderBoard(_leaderBoardCache[_joinGameObj.typeDefId]._allTime);
                     break;
                  case GameCardPopup.LEADERBOARD_TYPE_BUDDY:
                     _gameCardPopup.populateLeaderBoard(_leaderBoardCache[_joinGameObj.typeDefId]._buddy);
                     break;
                  case GameCardPopup.LEADERBOARD_TYPE_THISWEEK:
                     _gameCardPopup.populateLeaderBoard(_leaderBoardCache[_joinGameObj.typeDefId]._thisWeek);
               }
            }
            else
            {
               _gameCardPopup.populateLeaderBoard(null);
               DarkenManager.showLoadingSpiral(true);
               MinigameXtCommManager.sendMinigameLeaderboardRequest(_joinGameObj.typeDefId);
            }
         }
      }
      
      private static function waitListUpdate() : void
      {
      }
      
      private static function sendPVPRequest(param1:int, param2:String) : void
      {
         MinigameXtCommManager.sendMinigamePvpMsg(param1,MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT,param2);
      }
      
      private static function sendResponseToPVPRequest(param1:Boolean) : void
      {
         MinigameXtCommManager.sendMinigamePvpMsg(_pvpGameDefId,param1 ? MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT : MinigameXtCommManager.PVP_DENY_DENIED_OR_CANCEL);
      }
      
      private static function playGame(param1:int) : void
      {
         var _loc2_:TextFormat = null;
         if(RoomXtCommManager.isSwitching)
         {
            return;
         }
         _proModeId = param1;
         killJoinGamePopup();
         if(_joinGameObj.mi.maxPlayers > 1 && _joinGameObj.mi.maxPlayers <= 4)
         {
            _waitList = new MinigameLobbyContent();
            _waitListPopup = new SBPopup(_parentLayer,new (getDefinitionByName("MinigameLobbySkin") as Class)(),_waitList,true,true,false,false,true);
            _waitListPopup.content.scaleX = 1;
            _waitListPopup.content.scaleY = 1;
            _waitListPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,onSingleMultiplayerPopupXBtn,false,0,true);
            _waitList.gameTitleTxt.text = _joinGameObj.name;
            _waitList.startBtn.visible = false;
            _waitList.waiting_txt.visible = false;
            _waitList.player_count_txt.x += _waitList.player_count_txt.width;
            _waitList.player_count_txt.text = "1-" + _joinGameObj.mi.maxPlayers + " player game";
            _loc2_ = new TextFormat();
            _loc2_.align = TextFormatAlign.CENTER;
            _waitList.player_count_txt.setTextFormat(_loc2_);
            if(!Utility.canMultiplayer())
            {
               _waitList.multiplayerBtn.activateGrayState(true);
               _waitList.startBtn.activateGrayState(true);
            }
            _waitList.multiplayerBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSingleMultiplayerBtn,false,0,true);
            _waitList.singlePlayerBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSingleMultiplayerBtn,false,0,true);
         }
         else
         {
            launchGame();
         }
      }
      
      private static function onSingleMultiplayerPopupXBtn(param1:MouseEvent) : void
      {
         if(_frgWaiting)
         {
            closeHandler();
         }
         else if(_waitListPopup)
         {
            _waitListPopup.destroy();
         }
      }
      
      private static function onSingleMultiplayerBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         launchGame(param1.currentTarget.name == "multiplayerBtn");
      }
      
      private static function openInstructions() : void
      {
         _gameCardPopup.suppressMouseDown = true;
         InstructionScreenBuilder.build(_joinGameObj.swfName,_gameCardPopup,playGame);
         _gameCardPopup.visible = false;
      }
      
      private static function joinRoomHandler(param1:SFEvent) : void
      {
         var _loc2_:SFRoom = null;
         var _loc3_:SFRoom = null;
         if(param1.status)
         {
            if(param1.obj.subRoom)
            {
               if(_pvpCancelMSReceived)
               {
                  RoomXtCommManager.sendRoomLeaveRequest(gMainFrame.server.getCurrentRoomId(true),true);
                  _mmToSendWhenRefLoaded = null;
                  _pvpCancelMSReceived = false;
                  return;
               }
               _loc2_ = param1.obj.room;
               if(_loc2_.isGame && _loc2_.isTemp)
               {
                  if(_roomName == "")
                  {
                     _roomName = param1.obj.subRoom.name;
                  }
               }
            }
            else if(param1.roomId > -1)
            {
               _loc3_ = param1.obj.room;
               if(_loc3_.isGame && _loc3_.isTemp && _loc3_.name.substr(0,3) != "den")
               {
                  if(!_primaryRoomNameBypass)
                  {
                     _primaryRoomName = _roomName;
                     _roomName = _loc3_.name;
                  }
                  _primaryRoomNameBypass = false;
               }
               else if(!_inInRoomGame && _primaryRoomName != "")
               {
                  _primaryRoomName = "";
                  return;
               }
            }
         }
         else if(_roomName != "")
         {
            DebugUtility.debugTrace("MinigameManager: could not join room! msg:" + param1.message);
         }
      }
      
      private static function launchGame(param1:Boolean = false) : void
      {
         var _loc5_:TextFormat = null;
         var _loc6_:AvatarView = null;
         var _loc7_:String = null;
         var _loc8_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         DebugUtility.debugTrace("Launch Game: " + _joinGameObj.name + " typeDefId:" + _joinGameObj.typeDefId);
         minigameInfoCache.currMinigameId = _joinGameObj.typeDefId;
         _inMinigame = true;
         if(!_inInRoomGame && _primaryRoomName != "" && _joinFrgCallback != null)
         {
            _joinFrgCallback();
            _joinFrgCallback = null;
         }
         var _loc2_:MinigameInfo = minigameInfoCache.getMinigameInfo(_joinGameObj.typeDefId);
         var _loc3_:int = int(_loc2_.minPlayers);
         var _loc4_:int = int(_loc2_.maxPlayers);
         _minReqPlayers = _loc3_;
         _maxAllowedPlayers = _loc4_;
         if(_loc4_ > 1 && _loc4_ <= 4 && param1)
         {
            _waitList.multiplayerBtn.visible = false;
            _waitList.singlePlayerBtn.visible = false;
            _waitList.waiting_txt.visible = true;
            _waitList.startBtn.visible = true;
            _waitList.player_count_txt.x -= _waitList.player_count_txt.width;
            _loc5_ = new TextFormat();
            _loc5_.align = TextFormatAlign.RIGHT;
            _waitList.player_count_txt.setTextFormat(_loc5_);
            _waitlistP1X = _waitList.p1.x;
            _waitlistP2X = _waitList.p2.x;
            _waitlistP3X = _waitList.p3.x;
            _waitlistP4X = _waitList.p4.x;
            _waitList.p1.nameBar.name_txt.visible = false;
            _waitList.p2.nameBar.name_txt.visible = false;
            _waitList.p3.nameBar.name_txt.visible = false;
            _waitList.p4.nameBar.name_txt.visible = false;
            if(_waitList.p1.char.currentFrameLabel != "up")
            {
               _waitList.p1.char.gotoAndPlay("up");
            }
            _loc6_ = new AvatarView();
            _loc6_.init(AvatarManager.playerAvatar);
            _loc6_.playAnim(LayerAnim.AN_HUD_AVT);
            _waitList.p1.char.charLayer.addChild(_loc6_);
            _loc7_ = AvatarManager.playerAvatar.avName;
            _loc8_ = _loc7_.indexOf(" ");
            if(_loc8_ != -1)
            {
               _loc9_ = _loc7_.substr(0,_loc8_);
               _loc10_ = _loc7_.substr(_loc8_ + 1,_loc7_.length);
            }
            else
            {
               _loc9_ = _loc7_;
            }
            _waitList.p1.nameBar.firstName_txt.text = _loc9_;
            if(_loc10_)
            {
               _waitList.p1.nameBar.lastName_txt.text = _loc10_;
            }
            if(_loc4_ == 2)
            {
               _waitList.p2.nameBar.firstName_txt.text = "Waiting...";
               _waitList.p2.nameBar.lastName_txt.text = "";
               if(_waitList.p2.char.currentFrameLabel != "waiting")
               {
                  _waitList.p2.char.gotoAndPlay("waiting");
               }
               _waitList.p3.visible = false;
               _waitList.p4.visible = false;
               _waitList.p1.x = _waitlistP2X;
               _waitList.p2.x = _waitlistP3X;
               _waitList["player_count_txt"].text = "1-2 player game";
            }
            else if(_loc4_ == 3)
            {
               _waitList.p2.nameBar.firstName_txt.text = "Waiting...";
               _waitList.p2.nameBar.lastName_txt.text = "";
               if(_waitList.p2.char.currentFrameLabel != "waiting")
               {
                  _waitList.p2.char.gotoAndPlay("waiting");
               }
               _waitList.p3.nameBar.firstName_txt.text = "Waiting...";
               _waitList.p3.nameBar.lastName_txt.text = "";
               if(_waitList.p3.char.currentFrameLabel != "waiting")
               {
                  _waitList.p3.char.gotoAndPlay("waiting");
               }
               _waitList.p4.visible = false;
               _waitList.p1.x = _waitlistP1X + (_waitlistP2X - _waitlistP1X) * 0.5;
               _waitList.p2.x = _waitlistP2X + (_waitlistP3X - _waitlistP2X) * 0.5;
               _waitList.p3.x = _waitlistP3X + (_waitlistP4X - _waitlistP3X) * 0.5;
               _waitList["player_count_txt"].text = "1-3 player game";
            }
            else if(_loc4_ == 4)
            {
               _waitList.p2.nameBar.firstName_txt.text = "Waiting...";
               _waitList.p2.nameBar.lastName_txt.text = "";
               if(_waitList.p2.char.currentFrameLabel != "waiting")
               {
                  _waitList.p2.char.gotoAndPlay("waiting");
               }
               _waitList.p3.nameBar.firstName_txt.text = "Waiting...";
               _waitList.p3.nameBar.lastName_txt.text = "";
               if(_waitList.p3.char.currentFrameLabel != "waiting")
               {
                  _waitList.p3.char.gotoAndPlay("waiting");
               }
               _waitList.p4.nameBar.firstName_txt.text = "Waiting...";
               _waitList.p4.nameBar.lastName_txt.text = "";
               if(_waitList.p4.char.currentFrameLabel != "waiting")
               {
                  _waitList.p4.char.gotoAndPlay("waiting");
               }
               _waitList["player_count_txt"].text = "1-4 player game";
            }
            if(_loc3_ > 1)
            {
               _waitList["player_count_txt"].text = _waitList["player_count_txt"].text.replace("1",_loc3_);
            }
            if(_loc3_ < _loc4_)
            {
               _waitList.startBtn.addEventListener(MouseEvent.MOUSE_DOWN,startNowHandler,false,0,true);
               _waitList.startBtn.visible = true;
            }
            else
            {
               _waitList.startBtn.visible = false;
            }
         }
         else
         {
            if(_gameCardPopup)
            {
               DarkenManager.unDarken(_gameCardPopup);
            }
            DarkenManager.showLoadingSpiral(true);
         }
         if(_inInRoomGame)
         {
            gMainFrame.server.setToJoinIRG(true);
         }
         else
         {
            if(_frgWaiting)
            {
               throw new Error("if we were already waiting then something went wrong");
            }
            _frgWaiting = true;
            gMainFrame.server.setToJoinIRG(false);
         }
         _roomName = gMainFrame.server.getCurrentRoomName(false);
         MinigameXtCommManager.sendMinigameJoinRequest(_joinGameObj.typeDefId,false,param1,_proModeId);
      }
      
      private static function loadCompleteHandler(param1:LoaderEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: could not load game swf! loadCompleteHandler evt.message: " + param1.message);
         }
         else
         {
            startGameLoaded(param1.entry.loader);
         }
      }
      
      private static function loadProgressCompleteHandler() : void
      {
         startGameLoaded(LoadProgress.entry.loader);
      }
      
      private static function startGameLoaded(param1:Loader) : void
      {
         if(_inInRoomGame)
         {
            _parentLayer.addChild(param1);
            param1.addEventListener(MouseEvent.MOUSE_DOWN,stopMouse,false,0,true);
            param1.addEventListener(MouseEvent.MOUSE_MOVE,stopMouse,false,0,true);
            KeepAlive.startKATimer(param1);
         }
         else
         {
            _frgLoader = param1;
            _parentLayer.addChild(_frgLoader);
            _frgWaiting = false;
            gMainFrame.stage.focus = null;
            if(_joinGameObj.swfName == "Twister" || _joinGameObj.swfName == "FallingPhantoms" || _joinGameObj.swfName == "HorseRace" || _joinGameObj.swfName == "DolphinRace" || _joinGameObj.swfName == "GemBreaker" || _joinGameObj.swfName == "FortSmasher" || _joinGameObj.swfName == "SuperSort" || _joinGameObj.swfName == "FashionShow" || _joinGameObj.swfName == "PillBugs" || _joinGameObj.swfName == "QuestCombat" || _joinGameObj.swfName == "HedgeHog" || _joinGameObj.swfName == "TouchPool")
            {
               gMainFrame.stage.quality = StageQuality.MEDIUM;
            }
            else if(_joinGameObj.swfName == "ArtStudioPrint" || _joinGameObj.swfName == "ArtPrintPlayPortrait" || _joinGameObj.swfName == "ArtStudioColor" || _joinGameObj.swfName == "ArtStudioPottery" || _joinGameObj.swfName == "ArtStudioPainting" || _joinGameObj.swfName == "BradyExpeditions")
            {
               gMainFrame.stage.quality = StageQuality.HIGH;
            }
            else
            {
               gMainFrame.stage.quality = StageQuality.LOW;
            }
         }
         if(Boolean(_waitListPopup) && _waitListPopup.visible)
         {
            _waitListPopup.close();
            _waitListPopup.content["p1"].x = _waitlistP1X;
            _waitListPopup.content["p2"].x = _waitlistP2X;
            _waitListPopup.content["p3"].x = _waitlistP3X;
            _waitListPopup.content["p4"].x = _waitlistP4X;
         }
         _minigameRef = IMinigame(param1.content);
         var _loc2_:int = parseInt(_startData[2]);
         DebugUtility.debugTrace("numPlayers:" + _loc2_);
         var _loc3_:Array = new Array(_loc2_);
         var _loc4_:* = 3;
         while(_loc4_ < _loc2_ + 3)
         {
            DebugUtility.debugTrace("p" + (_loc4_ - 2) + "Id:" + _startData[_loc4_]);
            _loc3_[_loc4_ - 3] = parseInt(_startData[_loc4_++]);
         }
         if(inMinigame())
         {
            GuiManager.chatHist.removeKeyListeners();
         }
         KeepAlive.startKATimer(DisplayObjectContainer(_minigameRef).stage);
         EventDispatcher(_minigameRef).addEventListener(Event.COMPLETE,minigameLoadCompleteHandler,false,0,true);
         _minigameRef.start(_userId,_loc3_,msg,leave);
         _startData.splice(1,2 + _loc3_.length);
         _minigameRef.message(_startData);
         while(Boolean(_mmToSendWhenRefLoaded) && _mmToSendWhenRefLoaded.length > 0)
         {
            _minigameRef.message(_mmToSendWhenRefLoaded.shift());
         }
      }
      
      private static function loadPVPGameMedia(param1:int) : void
      {
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(param1,mediaHelperCallback,true);
      }
      
      private static function mediaHelperCallback(param1:MovieClip) : void
      {
         _pvpMedia[param1.mediaHelper.id] = param1;
         setMediaImage(param1);
      }
      
      private static function setMediaImage(param1:MovieClip) : void
      {
         while(_buddyGameInviteContent.itemBlock.numChildren > 0)
         {
            _buddyGameInviteContent.itemBlock.removeChildAt(0);
         }
         _buddyGameInviteContent.itemBlock.addChild(param1);
      }
      
      private static function onPVPCloseInvite(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.parent.name == "invite")
         {
            if(_pvpGameDefId >= 0 && _pvpUserName != "")
            {
               _pvpCancelSubRoomId = gMainFrame.server.getPvpSubRoomId();
               MinigameXtCommManager.sendMinigamePvpMsg(_pvpGameDefId,MinigameXtCommManager.PVP_DENY_DENIED_OR_CANCEL);
               readySelfForPvpGame({"typeDefId":_pvpGameDefId},_pvpUserName,false);
            }
         }
         if(_buddyGamePopup)
         {
            _buddyGamePopup.close();
         }
      }
      
      private static function onPVPYesInvite(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         sendResponseToPVPRequest(true);
         _buddyGamePopup.close();
         DarkenManager.showLoadingSpiral(true);
      }
      
      private static function onPVPNoInvite(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         sendResponseToPVPRequest(false);
         readySelfForPvpGame({"typeDefId":_pvpGameDefId},_pvpUserName,false);
         _buddyGamePopup.close();
      }
      
      private static function onYesNoReplay(param1:Object) : void
      {
         if(param1.status)
         {
            sendPVPRequest(param1.passback.gameDefId,param1.passback.userName);
            displaySentRequestPopup(param1.passback.mediaRefId,param1.passback.userName);
            readySelfForPvpGame({"typeDefId":param1.passback.gameDefId},param1.passback.userName,true);
         }
      }
      
      private static function displayPVPReceivedRequestPopup(param1:int, param2:String, param3:String) : void
      {
         _pvpAmISender = false;
         _buddyGameInviteContent.invite.visible = false;
         _buddyGameInviteContent.refuse.visible = false;
         if(_pvpMedia[param1] == null)
         {
            loadPVPGameMedia(param1);
         }
         else
         {
            setMediaImage(_pvpMedia[param1]);
         }
         _buddyGameInviteContent.request.visible = true;
         _buddyGameInviteContent.request.popupTxt1.text = param2;
         _buddyGameInviteContent.request.popupTxt3.text = param3;
         if(!_buddyGamePopup.visible)
         {
            _buddyGamePopup.open();
         }
      }
      
      private static function displayPVPDeniedRequestPopup(param1:int, param2:String) : void
      {
         _pvpAmISender = false;
         _buddyGameInviteContent.invite.visible = false;
         _buddyGameInviteContent.request.visible = false;
         if(_pvpMedia[param1] == null)
         {
            loadPVPGameMedia(param1);
         }
         else
         {
            setMediaImage(_pvpMedia[param1]);
         }
         _buddyGameInviteContent.refuse.visible = true;
         _buddyGameInviteContent.refuse.popupTxt1.text = param2;
         if(!_buddyGamePopup.visible)
         {
            _buddyGamePopup.open();
         }
      }
      
      private static function minigameLoadCompleteHandler(param1:Event) : void
      {
         LoadProgress.show(false);
         if(_inInRoomGame)
         {
            AvatarManager.showAvtAndChatLayers(false);
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private static function startNowHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         if(_frgWaiting && _waitIds.length >= _minReqPlayers && !RoomXtCommManager.isSwitching)
         {
            MinigameXtCommManager.sendMinigameStartRequest(_joinGameObj.typeDefId);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      public static function inMinigame() : Boolean
      {
         if(_joinGameObj != null && _joinGameObj.swfName == "QuestCombat")
         {
            return false;
         }
         return _inMinigame;
      }
      
      public static function inInRoomGame() : Boolean
      {
         return _inInRoomGame;
      }
      
      public static function get inFullRoomGame() : Boolean
      {
         return _inMinigame && !_inInRoomGame;
      }
      
      public static function get roomName() : String
      {
         return _roomName;
      }
      
      public static function get roomEnviroType() : int
      {
         return _roomMgr.roomEnviroType;
      }
      
      public static function set userId(param1:int) : void
      {
         _userId = param1;
      }
      
      public static function msg(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:String = null;
         if(param1[0] == "_a" && param1.length > 1)
         {
            _loc2_ = int(param1[1]);
            if(param1.length > 2)
            {
               _loc3_ = param1[2];
            }
            AvatarManager.setPlayerAttachmentEmot(_loc2_,_loc3_);
            return;
         }
         param1.splice(0,0,_joinGameObj.typeDefId);
         MinigameXtCommManager.sendMinigameMessageRequest(param1,_inInRoomGame);
      }
      
      public static function readySelfForPvpGame(param1:Object, param2:String, param3:Boolean) : void
      {
         var _loc4_:MinigameInfo = minigameInfoCache.getMinigameInfo(param1.typeDefId);
         if(_loc4_)
         {
            _inInRoomGame = _loc4_.isInRoomGame;
            if(param3)
            {
               if(_inInRoomGame)
               {
                  if(Boolean(_joinGameObj) && !_joinGameObj.isPvp)
                  {
                     _oldJoinGameObj = _joinGameObj;
                  }
                  _pvpGameDefId = param1.typeDefId;
                  _pvpUserName = param2;
                  _joinGameObj = param1;
                  _joinGameObj.name = _loc4_.title;
                  _joinGameObj.swfName = _loc4_.swfName;
                  _joinGameObj.isPvp = true;
                  gMainFrame.server.setToJoinIRG(true);
                  minigameInfoCache.currMinigameId = _joinGameObj.typeDefId;
                  _inMinigame = true;
               }
            }
            else
            {
               _pvpGameDefId = -1;
               _pvpUserName = "";
               if(_oldJoinGameObj)
               {
                  _joinGameObj = _oldJoinGameObj;
                  _oldJoinGameObj = null;
               }
               else
               {
                  _joinGameObj = null;
               }
               _inInRoomGame = false;
               gMainFrame.server.setToJoinIRG(false);
               minigameInfoCache.currMinigameId = -1;
               _inMinigame = false;
            }
         }
      }
      
      public static function handleGameClick(param1:Object, param2:Function, param3:Boolean = false, param4:Function = null, param5:int = 0) : void
      {
         var _loc6_:MinigameInfo = null;
         var _loc7_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:Array = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         if(Boolean(_gameCardPopup) && !_gameCardPopup.visible)
         {
            killJoinGamePopup();
         }
         if(!_inMinigame && !_gameCardPopup)
         {
            _roomMgr.forceStopMovement();
            _joinGameObj = param1;
            _loc6_ = minigameInfoCache.getMinigameInfo(_joinGameObj.typeDefId);
            if(_loc6_.gameDefId == 82)
            {
               _proModeId = param5;
            }
            _joinGameObj.mi = _loc6_;
            _joinGameObj.name = _loc6_.title;
            _joinGameObj.swfName = _loc6_.swfName;
            _joinGameObj.isPvp = false;
            _joinFrgCallback = param2;
            _inInRoomGame = _loc6_.isInRoomGame;
            _loc7_ = PetManager.myActivePet;
            if(_loc6_.gameDefId == PET_WASH_DEF_ID)
            {
               if(AvatarManager.playerAvatarWorldView)
               {
                  if(!AvatarManager.playerAvatarWorldView.getActivePet())
                  {
                     new SBOkPopup(_parentLayer,"You have to bring a pet with you to use the Pet Wash!");
                     return;
                  }
                  if(!gMainFrame.userInfo.isMember)
                  {
                     new SBOkPopup(_parentLayer,"You have to be a member to enter the Pet Wash!");
                     return;
                  }
               }
            }
            else if(_loc6_.gameDefId == PET_SALON_DEF_ID || _loc6_.gameDefId == PET_SALON_PARTY_DEF_ID)
            {
               if(AvatarManager.playerAvatarWorldView)
               {
                  if(!AvatarManager.playerAvatarWorldView.getActivePet())
                  {
                     new SBOkPopup(_parentLayer,"You have to bring a pet with you to use the Pet Stop!");
                     return;
                  }
                  if(!gMainFrame.userInfo.isMember)
                  {
                     new SBOkPopup(_parentLayer,"You have to be a member to enter the Pet Stop!");
                     return;
                  }
               }
            }
            _gameCloseCallback = param4;
            if(_loc6_.petDefId > 0 && (_loc7_ == null || _loc7_.defId != _loc6_.petDefId))
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup(UpsellManager.PETS,"playPetGame/" + _loc6_.title);
               }
               else
               {
                  _loc8_ = PetManager.getPetDef(_loc6_.petDefId);
                  _loc9_ = null;
                  _loc10_ = PetManager.myPetList;
                  _loc11_ = 0;
                  while(_loc11_ < _loc10_.length)
                  {
                     if(_loc10_[_loc11_].defId == _loc8_.defId)
                     {
                        _loc9_ = _loc10_[_loc11_];
                        break;
                     }
                     _loc11_++;
                  }
                  if(_loc9_ != null && (_inInRoomGame || param3))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(_loc9_.lBits,_loc9_.uBits,_loc9_.eBits);
                     PetXtCommManager.sendPetSwitchRequest(_loc9_.idx,launchInRoomGame);
                  }
                  else
                  {
                     new SBOkPopup(_parentLayer,"You have to bring a " + _loc8_.title.toLowerCase() + " with you to play " + _joinGameObj.name + ".");
                  }
               }
               return;
            }
            if(_inInRoomGame || param3)
            {
               gMainFrame.server.setToJoinIRG(true);
               launchGame();
            }
            else
            {
               _loc12_ = int(_joinGameObj.mi.proModeUserVarRefId);
               _loc13_ = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc12_));
               _gameCardPopup = new GameCardPopup(_parentLayer,_loc6_.gameCardScreen,playGame,openInstructions,killJoinGamePopup,null,null,_loc12_ > 0,_loc13_,_joinGameObj.mi.maxPlayers > 1);
            }
         }
      }
      
      private static function launchInRoomGame() : void
      {
         gMainFrame.server.setToJoinIRG(true);
         launchGame();
      }
      
      private static function closeHandler(param1:MouseEvent = null) : void
      {
         leave();
      }
      
      private static function stopMouse(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function startGame(param1:Array) : void
      {
         _startData = param1;
         _mmToSendWhenRefLoaded = [];
         createGameWindow();
      }
      
      public static function joinGameResponse(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         var _loc8_:AvatarView = null;
         var _loc9_:Point = null;
         var _loc10_:String = null;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:String = null;
         if(param1[2] == "pf")
         {
            DarkenManager.showLoadingSpiral(false);
            GuiManager.handleGameExit();
            _inMinigame = false;
            _inInRoomGame = false;
            minigameInfoCache.currMinigameId = -1;
            gMainFrame.stage.quality = StageQuality.MEDIUM;
            gMainFrame.server.setToJoinIRG(false);
            _loc2_ = PetManager.getPetDef(parseInt(param1[3]));
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.PETS,"playPetGame/" + _loc2_.title);
            }
            else
            {
               new SBOkPopup(_parentLayer,"You have to bring a " + _loc2_.title.toLowerCase() + " with you to play " + _joinGameObj.name + ".");
            }
            return;
         }
         if(param1[2] == "mo")
         {
            DarkenManager.showLoadingSpiral(false);
            GuiManager.handleGameExit();
            _inMinigame = false;
            _inInRoomGame = false;
            minigameInfoCache.currMinigameId = -1;
            gMainFrame.stage.quality = StageQuality.MEDIUM;
            gMainFrame.server.setToJoinIRG(false);
            _frgWaiting = false;
            UpsellManager.displayPopup(UpsellManager.OCEAN,"playMOGame/" + _joinGameObj.name);
            return;
         }
         if(_inInRoomGame)
         {
            return;
         }
         if(int(param1[1]) != gMainFrame.server.getCurrentRoomId(_inInRoomGame))
         {
            return;
         }
         _waitIds = [];
         _loc3_ = 1;
         while(_loc3_ < _maxAllowedPlayers + 1)
         {
            while(_waitListPopup.content["p" + _loc3_].char.charLayer.numChildren > 0)
            {
               _waitListPopup.content["p" + _loc3_].char.charLayer.removeChildAt(0);
            }
            _waitListPopup.content["p" + _loc3_].char.gotoAndPlay("waiting");
            _waitListPopup.content["p" + _loc3_].nameBar.lastName_txt.text = "";
            _loc3_++;
         }
         _loc4_ = 2;
         while(_loc4_ < _maxAllowedPlayers + 2)
         {
            if(_loc4_ < param1.length)
            {
               _loc6_ = int(param1[_loc4_]);
               _waitIds.push(_loc6_);
               _waitListPopup.content["p" + (_loc4_ - 1)].char.gotoAndPlay("up");
               _loc7_ = AvatarManager.getAvatarBySfsUserId(_loc6_);
               if(_loc7_ == null)
               {
                  DebugUtility.debugTraceObject("AvatarManager.avatarList",AvatarManager.avatarList);
                  throw new Error("\"mj\" sent down bad sfsUserId wid:" + _loc6_);
               }
               _loc8_ = new AvatarView();
               _loc8_.init(_loc7_);
               _loc8_.playAnim(LayerAnim.AN_HUD_AVT);
               _loc8_.scaleX = 0.7;
               _loc8_.scaleY = 0.7;
               _loc9_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc8_.avTypeId);
               _loc8_.x = _loc9_.x;
               _loc8_.y = _loc9_.y;
               _waitListPopup.content["p" + (_loc4_ - 1)].char.charLayer.addChild(_loc8_);
               _loc10_ = _loc7_.avName;
               _loc11_ = _loc10_.indexOf(" ");
               if(_loc11_ != -1)
               {
                  _loc12_ = _loc10_.substr(0,_loc11_);
                  _loc13_ = _loc10_.substr(_loc11_ + 1,_loc10_.length);
               }
               else
               {
                  _loc12_ = _loc10_;
               }
               _waitListPopup.content["p" + (_loc4_ - 1)].nameBar.firstName_txt.text = _loc12_;
               if(_loc13_)
               {
                  _waitListPopup.content["p" + (_loc4_ - 1)].nameBar.lastName_txt.text = _loc13_;
               }
            }
            else
            {
               _waitListPopup.content["p" + (_loc4_ - 1)].char.gotoAndPlay("waiting");
               _waitListPopup.content["p" + (_loc4_ - 1)].nameBar.firstName_txt.text = "Waiting...";
               _waitListPopup.content["p" + (_loc4_ - 1)].nameBar.lastName_txt.text = "";
            }
            _loc4_++;
         }
         _loc5_ = _waitListPopup.content["startBtn"];
         if(_waitIds.length >= _minReqPlayers)
         {
            if(!_loc5_.hasEventListener(MouseEvent.MOUSE_DOWN))
            {
               _loc5_.addEventListener(MouseEvent.MOUSE_DOWN,startNowHandler,false,0,true);
            }
            _loc5_.visible = true;
         }
         else
         {
            _loc5_.visible = false;
         }
         if(!_waitListPopup.visible)
         {
            _waitListPopup.open();
         }
         waitListUpdate();
      }
      
      public static function minigameEndResponse(param1:Array) : void
      {
         var _loc2_:SBMessage = null;
         if(_minigameRef)
         {
            _minigameRef.end(param1);
            _minigameRef = null;
         }
         _mmToSendWhenRefLoaded = null;
         if(!_inInRoomGame)
         {
            _loc2_ = new SBMessage(_parentLayer,new (getDefinitionByName("ConfirmSkin") as Class)(),"Game has ended.");
            _loc2_.closeCallback = leave;
         }
         else
         {
            gMainFrame.server.setToJoinIRG(false);
         }
      }
      
      public static function minigameRoomRemovedResponse(param1:Array) : void
      {
         if(_rejoin)
         {
            launchGame();
            _rejoin = false;
         }
      }
      
      public static function messageGame(param1:Array) : void
      {
         if(_minigameRef)
         {
            _minigameRef.message(param1);
         }
         else if(_mmToSendWhenRefLoaded)
         {
            _mmToSendWhenRefLoaded.push(param1);
         }
      }
      
      public static function pvpResponse(param1:Array) : void
      {
         var _loc4_:Buddy = null;
         var _loc5_:String = null;
         var _loc2_:int = int(param1[2]);
         var _loc3_:int = int(param1[3]);
         if(_loc3_ == MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT)
         {
            _loc5_ = param1[4];
            readySelfForPvpGame({"typeDefId":_loc2_},_loc5_,true);
            displayPVPReceivedRequestPopup(minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId,_loc5_,MinigameManager.getGameName(_pvpGameDefId));
         }
         else if(_loc3_ == MinigameXtCommManager.PVP_DENY_DENIED_OR_CANCEL)
         {
            if(_pvpGameDefId > 0 && _pvpUserName != "")
            {
               if(_buddyGamePopup.visible && !_pvpAmISender)
               {
                  _buddyGamePopup.close();
               }
               else
               {
                  displayPVPDeniedRequestPopup(minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId,_pvpUserName);
               }
               readySelfForPvpGame({"typeDefId":_loc2_},_pvpUserName,false);
            }
         }
      }
      
      public static function leaderBoardResponse(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc2_:int = int(param1[2]);
         if(_loc2_ != -1)
         {
            _loc3_ = new Object();
            _loc3_._cacheTime = getTimer();
            _loc3_._allTime = new Array();
            _loc3_._thisWeek = new Array();
            _loc3_._buddy = new Array();
            _loc5_ = 3;
            _loc4_ = int(param1[_loc5_++]);
            _loc6_ = 0;
            while(_loc4_ > 0)
            {
               _loc3_._allTime[_loc6_] = new Object();
               _loc3_._allTime[_loc6_]._name = param1[_loc5_++];
               _loc3_._allTime[_loc6_++]._score = param1[_loc5_++];
               _loc4_--;
            }
            _loc4_ = int(param1[_loc5_++]);
            _loc6_ = 0;
            while(_loc4_ > 0)
            {
               _loc3_._thisWeek[_loc6_] = new Object();
               _loc3_._thisWeek[_loc6_]._name = param1[_loc5_++];
               _loc3_._thisWeek[_loc6_++]._score = param1[_loc5_++];
               _loc4_--;
            }
            _loc4_ = int(param1[_loc5_++]);
            _loc6_ = 0;
            while(_loc4_ > 0)
            {
               _loc3_._buddy[_loc6_] = new Object();
               _loc3_._buddy[_loc6_]._name = param1[_loc5_++];
               _loc3_._buddy[_loc6_++]._score = param1[_loc5_++];
               _loc4_--;
            }
            _leaderBoardCache[_loc2_] = _loc3_;
            if(_joinGameObj != null && _gameCardPopup != null && _joinGameObj.typeDefId == _loc2_)
            {
               onLeaderBoardSelected();
            }
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      public static function displaySentRequestPopup(param1:int, param2:String) : void
      {
         _pvpAmISender = true;
         _buddyGameInviteContent.request.visible = false;
         _buddyGameInviteContent.refuse.visible = false;
         if(_pvpMedia[param1] == null)
         {
            loadPVPGameMedia(param1);
         }
         else
         {
            setMediaImage(_pvpMedia[param1]);
         }
         _buddyGameInviteContent.invite.visible = true;
         _buddyGameInviteContent.invite.popupTxt2.text = param2;
         if(!_buddyGamePopup.visible)
         {
            _buddyGamePopup.open();
         }
      }
      
      public static function getGameName(param1:int) : String
      {
         var _loc2_:MinigameInfo = null;
         if(minigameInfoCache)
         {
            _loc2_ = minigameInfoCache.getMinigameInfo(param1);
            if(_loc2_)
            {
               return _loc2_.title;
            }
         }
         return "";
      }
      
      public static function getActivePet(param1:Function) : Sprite
      {
         var _loc2_:WorldPet = AvatarManager.playerAvatarWorldView.getActivePet();
         if(_loc2_)
         {
            return PetManager.getPetSprite(_loc2_.getLBits(),_loc2_.getUBits(),_loc2_.getEBits(),_loc2_.getType(),param1);
         }
         return null;
      }
      
      public static function getActivePetName() : String
      {
         if(PetManager.myActivePet)
         {
            return PetManager.myActivePet.name;
         }
         return "";
      }
      
      public static function sendPetItemRequest(param1:int, param2:int, param3:int, param4:int, param5:Function) : void
      {
         PetXtCommManager.sendPetItemRequest(param1,param2,param3,param4,param5);
      }
      
      public static function setPetSparkle(param1:int) : void
      {
         PetManager.sendPetSparkle(param1);
      }
      
      public static function getIsPlayerMember() : Boolean
      {
         return gMainFrame.userInfo.isMember;
      }
      
      public static function minigameGems(param1:Object) : void
      {
         var _loc2_:Object = null;
         _gemSerialNumber = parseInt(param1[2]);
         if(parseInt(param1[3]) == 1)
         {
            _scoreSN = _gemSerialNumber;
         }
         if(_awardGemsQueue.length > 0)
         {
            _loc2_ = _awardGemsQueue.pop();
            sendGemAward(_loc2_);
         }
      }
      
      public static function minigamePetMastery(param1:Object) : void
      {
         var _loc2_:Object = null;
         _petMasterySerialNumber = parseInt(param1[2]);
         if(param1[3] == "1")
         {
            _petMasteryQueuePopup = true;
         }
         if(_awardMasteryPointsQueue.length > 0)
         {
            _loc2_ = _awardMasteryPointsQueue.pop();
            sendMasteryPoints(_loc2_);
         }
      }
      
      public static function awardPetMasteryPoints(param1:int) : void
      {
         var _loc2_:Object = null;
         if(param1 > 0)
         {
            if(MainFrame.isInitialized())
            {
               _loc2_ = new Object();
               _loc2_.amount = param1;
               PetManager.addToActivePetMastery(param1);
               if(minigameInfoCache != null)
               {
                  _loc2_.minigameID = minigameInfoCache.currMinigameId;
               }
               else
               {
                  _loc2_.minigameID = -1;
               }
               if(_petMasterySerialNumber != -1)
               {
                  sendMasteryPoints(_loc2_);
               }
               else
               {
                  _awardMasteryPointsQueue.push(_loc2_);
               }
            }
         }
      }
      
      public static function awardGems(param1:int, param2:int) : void
      {
         var _loc3_:Object = null;
         if(param1 > 0)
         {
            if(MainFrame.isInitialized())
            {
               _loc3_ = new Object();
               _loc3_.amount = param1;
               _loc3_.minigameID = param2;
               if(_gemSerialNumber != -1)
               {
                  sendGemAward(_loc3_);
               }
               else
               {
                  _awardGemsQueue.push(_loc3_);
               }
            }
         }
      }
      
      private static function sendMasteryPoints(param1:Object) : void
      {
         var _loc2_:Number = (param1.amount + 29) * 7 + (_userId + 99) * 3 + (_petMasterySerialNumber + 49) * 5;
         var _loc3_:Number = (param1.minigameID + 49) * 3 + (_petMasterySerialNumber + 83) * 5;
         var _loc4_:Number = (_petMasterySerialNumber + _userId + param1.amount) * 3 + param1.amount * 3;
         _petMasterySerialNumber = -1;
         gMainFrame.server.setXtObject_Str("ma",[_loc2_,_loc3_,_loc4_]);
      }
      
      private static function sendGemAward(param1:Object) : void
      {
         var _loc2_:Number = (param1.amount + 29) * 7 + (_userId + 99) * 3 + (_gemSerialNumber + 49) * 5;
         var _loc3_:Number = (param1.minigameID + 49) * 3 + (_gemSerialNumber + 83) * 5;
         var _loc4_:Number = (_gemSerialNumber + _userId + param1.amount) * 3 + param1.amount * 3;
         _gemSerialNumber = -1;
         gMainFrame.server.setXtObject_Str("mg",[_loc2_,_loc3_,_loc4_]);
      }
      
      public static function sendScore(param1:Number, param2:Number, param3:Number, param4:int, param5:int) : void
      {
         gMainFrame.server.setXtObject_Str("msv",[param1 + 3 * param4,param2 - 8 * param4,param3 + 5 * param4,param4 * 5 + 7 * _scoreSN,param5 * 3 + _scoreSN]);
      }
      
      public static function getScoreSN() : int
      {
         return _scoreSN;
      }
      
      public static function keepAlive() : void
      {
         KeepAlive.inputReceivedHandler(null);
      }
      
      public static function handleQuestMiniGameComplete(param1:int) : void
      {
         QuestManager.handleQuestMiniGameComplete(param1);
      }
   }
}

