package game
{
   import achievement.AchievementManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
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
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.GameCardPopup;
   import gui.GuiManager;
   import gui.InstructionScreenBuilder;
   import gui.LoadingSpiral;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import pet.WorldPet;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
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
      
      private static var _pvpUserNameModerated:String;
      
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
      
      public static function init(topDoc:DisplayObjectContainer, roomMgr:RoomManagerWorld) : void
      {
         _parentLayer = topDoc;
         _roomMgr = roomMgr;
         _userId = gMainFrame.server.userId;
         _primaryRoomName = "";
         _frgWaiting = false;
         _inMinigame = false;
         _mmToSendWhenRefLoaded = null;
         minigameInfoCache = new MinigameInfoCache();
         minigameInfoCache.init();
         _buddyGameInviteContent = GETDEFINITIONBYNAME("BuddyGameInviteContent");
         _buddyGamePopup = new SBPopup(_parentLayer,GETDEFINITIONBYNAME("BuddyGameInviteSkin"),_buddyGameInviteContent,false,true,false,false,true);
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
      
      private static function leave(autoRejoin:Boolean = false, inGameResult:int = 0) : void
      {
         var wasWaiting:Boolean = false;
         var firstOfName:String = null;
         if(_frgWaiting)
         {
            wasWaiting = true;
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
                  firstOfName = _primaryRoomName.slice(0,6);
                  if(firstOfName != "quest_")
                  {
                     _roomMgr.minigameJoinRoom(_primaryRoomName);
                  }
                  else
                  {
                     QuestXtCommManager.questFullRoomMinigameComplete(_primaryRoomName,inGameResult);
                  }
               }
            }
            else if(_frgWaiting)
            {
               MinigameXtCommManager.sendMinigameJoinRequest(_joinGameObj.typeDefId);
               _frgWaiting = false;
            }
            if(Boolean(_frgLoader))
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
         leaveGame(wasWaiting);
         if(Boolean(_minigameRef))
         {
            _minigameRef = null;
         }
         _mmToSendWhenRefLoaded = null;
         _roomName = "";
         if(autoRejoin)
         {
            _rejoin = true;
         }
         _proModeId = 0;
         GuiManager.chatHist.reAddKeyListeners();
      }
      
      private static function leaveGame(wasWaiting:Boolean) : void
      {
         SBTracker.pop();
         if(Boolean(_minigameRef))
         {
            KeepAlive.stopKATimer(DisplayObjectContainer(_minigameRef).stage);
         }
         GuiManager.handleGameExit();
         _inMinigame = false;
         minigameInfoCache.currMinigameId = -1;
         gMainFrame.stage.quality = StageQuality.MEDIUM;
         DarkenManager.showLoadingSpiral(false);
         if(!_inInRoomGame && !wasWaiting)
         {
            LoadProgress.show(true,LoadProgress.LOADING_ROOM);
         }
         if(_pvpGameDefId >= 0)
         {
            if(_pvpPromptReplay)
            {
               new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14682),true,onYesNoReplay,{
                  "gameDefId":_pvpGameDefId,
                  "userName":_pvpUserName,
                  "userNameModerated":_pvpUserNameModerated,
                  "mediaRefId":minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId
               });
            }
            _pvpGameDefId = -1;
            _pvpUserName = "";
            _pvpUserNameModerated = "";
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
      
      private static function createGameWindow(swfName:String = "") : void
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
         var name:String = getGameName(_joinGameObj.typeDefId);
         if(_joinGameObj.typeDefId == 48)
         {
            name += " Land";
         }
         else if(_joinGameObj.typeDefId == 66)
         {
            name += " Ocean";
         }
         SBTracker.push();
         SBTracker.trackPageview("/game/play/minigame/#" + getGameNameId(_joinGameObj.typeDefId));
         if(Boolean(_waitListPopup) && Boolean(_waitListPopup.content) && Boolean(_waitListPopup.content["waitingTxt"]))
         {
            LocalizationManager.translateId(_waitListPopup.content["waitingTxt"],11099);
         }
         if(swfName == "")
         {
            swfName = "games/" + _joinGameObj.swfName + "/" + _joinGameObj.swfName + ".swf";
         }
         if(_inInRoomGame)
         {
            gMainFrame.loaderCache.openFile(gMainFrame.path + swfName,loadCompleteHandler);
            if(_pvpGameDefId >= 0)
            {
               _buddyGamePopup.close();
               DarkenManager.showLoadingSpiral(true);
            }
         }
         else
         {
            _roomMgr.exitRoom();
            LoadProgress.load(swfName,1,loadProgressCompleteHandler);
         }
      }
      
      private static function killJoinGamePopup(m:MouseEvent = null) : void
      {
         if(Boolean(_gameCardPopup))
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
      
      private static function sendPVPRequest(gameDefId:int, userName:String) : void
      {
         MinigameXtCommManager.sendMinigamePvpMsg(gameDefId,MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT,userName);
      }
      
      private static function sendResponseToPVPRequest(accepted:Boolean) : void
      {
         MinigameXtCommManager.sendMinigamePvpMsg(_pvpGameDefId,accepted ? MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT : MinigameXtCommManager.PVP_DENY_DENIED_OR_CANCEL);
      }
      
      private static function playGame(proModeId:int) : void
      {
         var txtFormat:TextFormat = null;
         if(RoomXtCommManager.isSwitching)
         {
            return;
         }
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(playGame,proModeId);
            return;
         }
         _proModeId = proModeId;
         killJoinGamePopup();
         if(_joinGameObj.mi.maxPlayers > 1 && _joinGameObj.mi.maxPlayers <= 4)
         {
            _waitList = GETDEFINITIONBYNAME("MinigameLobbyContent");
            _waitListPopup = new SBPopup(_parentLayer,GETDEFINITIONBYNAME("MinigameLobbySkin"),_waitList,true,true,false,false,true);
            _waitListPopup.content.scaleX = 1;
            _waitListPopup.content.scaleY = 1;
            _waitListPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,onSingleMultiplayerPopupXBtn,false,0,true);
            _waitList.gameTitleTxt.text = _joinGameObj.name;
            _waitList.startBtn.visible = false;
            _waitList.waiting_txt.visible = false;
            _waitList.player_count_txt.x += _waitList.player_count_txt.width;
            LocalizationManager.translateIdAndInsert(_waitList.player_count_txt,11100,_joinGameObj.mi.maxPlayers);
            txtFormat = new TextFormat();
            txtFormat.align = TextFormatAlign.CENTER;
            _waitList.player_count_txt.setTextFormat(txtFormat);
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
      
      private static function onSingleMultiplayerPopupXBtn(evt:MouseEvent) : void
      {
         if(_frgWaiting)
         {
            closeHandler();
         }
         else if(Boolean(_waitListPopup))
         {
            _waitListPopup.destroy();
         }
      }
      
      private static function onSingleMultiplayerBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(evt.currentTarget.isGray))
         {
            return;
         }
         launchGame(evt.currentTarget.name == "multiplayerBtn");
      }
      
      private static function openInstructions() : void
      {
         _gameCardPopup.suppressMouseDown = true;
         InstructionScreenBuilder.build(_joinGameObj.swfName,_gameCardPopup,playGame);
         _gameCardPopup.visible = false;
      }
      
      private static function joinRoomHandler(evt:SFEvent) : void
      {
         var sfrIrg:SFRoom = null;
         var sfrFrg:SFRoom = null;
         if(evt.status)
         {
            if(Boolean(evt.obj.subRoom))
            {
               if(_pvpCancelMSReceived)
               {
                  RoomXtCommManager.sendRoomLeaveRequest(gMainFrame.server.getCurrentRoomId(true),true);
                  _mmToSendWhenRefLoaded = null;
                  _pvpCancelMSReceived = false;
                  return;
               }
               sfrIrg = evt.obj.room;
               if(sfrIrg.isGame && sfrIrg.isTemp)
               {
                  if(_roomName == "")
                  {
                     _roomName = evt.obj.subRoom.name;
                  }
               }
            }
            else if(evt.roomId > -1)
            {
               sfrFrg = evt.obj.room;
               if(sfrFrg.isGame && sfrFrg.isTemp && sfrFrg.name.substr(0,3) != "den")
               {
                  if(!_primaryRoomNameBypass)
                  {
                     _primaryRoomName = _roomName;
                     _roomName = sfrFrg.name;
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
            DebugUtility.debugTrace("MinigameManager: could not join room! msg:" + evt.message);
         }
      }
      
      private static function launchGame(playMultiPlayer:Boolean = false) : void
      {
         var txtFormat:TextFormat = null;
         var avtView:AvatarView = null;
         var avName:String = null;
         var space:int = 0;
         var firstName:String = null;
         var lastName:String = null;
         DebugUtility.debugTrace("Launch Game: " + _joinGameObj.name + " typeDefId:" + _joinGameObj.typeDefId);
         minigameInfoCache.currMinigameId = _joinGameObj.typeDefId;
         _inMinigame = true;
         if(!_inInRoomGame && _primaryRoomName != "" && _joinFrgCallback != null)
         {
            _joinFrgCallback();
            _joinFrgCallback = null;
         }
         var joinGameInfo:MinigameInfo = minigameInfoCache.getMinigameInfo(_joinGameObj.typeDefId);
         var joinMinPlayers:int = int(joinGameInfo.minPlayers);
         var joinMaxPlayers:int = int(joinGameInfo.maxPlayers);
         _minReqPlayers = joinMinPlayers;
         _maxAllowedPlayers = joinMaxPlayers;
         if(joinMaxPlayers > 1 && joinMaxPlayers <= 4 && playMultiPlayer)
         {
            _waitList.multiplayerBtn.visible = false;
            _waitList.singlePlayerBtn.visible = false;
            _waitList.waiting_txt.visible = true;
            _waitList.startBtn.visible = true;
            _waitList.player_count_txt.x -= _waitList.player_count_txt.width;
            txtFormat = new TextFormat();
            txtFormat.align = TextFormatAlign.RIGHT;
            _waitList.player_count_txt.setTextFormat(txtFormat);
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
            avtView = new AvatarView();
            avtView.init(AvatarManager.playerAvatar);
            avtView.playAnim(LayerAnim.AN_HUD_AVT);
            _waitList.p1.char.charLayer.addChild(avtView);
            avName = AvatarManager.playerAvatar.avName;
            space = avName.indexOf(" ");
            if(space != -1)
            {
               firstName = avName.substr(0,space);
               lastName = avName.substr(space + 1,avName.length);
            }
            else
            {
               firstName = avName;
            }
            _waitList.p1.nameBar.firstName_txt.text = firstName;
            if(Boolean(lastName))
            {
               _waitList.p1.nameBar.lastName_txt.text = lastName;
            }
            if(joinMaxPlayers == 2)
            {
               LocalizationManager.translateId(_waitList.p2.nameBar.firstName_txt,11101);
               _waitList.p2.nameBar.lastName_txt.text = "";
               if(_waitList.p2.char.currentFrameLabel != "waiting")
               {
                  _waitList.p2.char.gotoAndPlay("waiting");
               }
               _waitList.p3.visible = false;
               _waitList.p4.visible = false;
               _waitList.p1.x = _waitlistP2X;
               _waitList.p2.x = _waitlistP3X;
               LocalizationManager.translateIdAndInsert(_waitList["player_count_txt"],11100,2);
            }
            else if(joinMaxPlayers == 3)
            {
               LocalizationManager.translateId(_waitList.p2.nameBar.firstName_txt,11101);
               _waitList.p2.nameBar.lastName_txt.text = "";
               if(_waitList.p2.char.currentFrameLabel != "waiting")
               {
                  _waitList.p2.char.gotoAndPlay("waiting");
               }
               LocalizationManager.translateId(_waitList.p3.nameBar.firstName_txt,11101);
               _waitList.p3.nameBar.lastName_txt.text = "";
               if(_waitList.p3.char.currentFrameLabel != "waiting")
               {
                  _waitList.p3.char.gotoAndPlay("waiting");
               }
               _waitList.p4.visible = false;
               _waitList.p1.x = _waitlistP1X + (_waitlistP2X - _waitlistP1X) * 0.5;
               _waitList.p2.x = _waitlistP2X + (_waitlistP3X - _waitlistP2X) * 0.5;
               _waitList.p3.x = _waitlistP3X + (_waitlistP4X - _waitlistP3X) * 0.5;
               LocalizationManager.translateIdAndInsert(_waitList["player_count_txt"],11100,3);
            }
            else if(joinMaxPlayers == 4)
            {
               LocalizationManager.translateId(_waitList.p2.nameBar.firstName_txt,11101);
               _waitList.p2.nameBar.lastName_txt.text = "";
               if(_waitList.p2.char.currentFrameLabel != "waiting")
               {
                  _waitList.p2.char.gotoAndPlay("waiting");
               }
               LocalizationManager.translateId(_waitList.p3.nameBar.firstName_txt,11101);
               _waitList.p3.nameBar.lastName_txt.text = "";
               if(_waitList.p3.char.currentFrameLabel != "waiting")
               {
                  _waitList.p3.char.gotoAndPlay("waiting");
               }
               LocalizationManager.translateId(_waitList.p4.nameBar.firstName_txt,11101);
               _waitList.p4.nameBar.lastName_txt.text = "";
               if(_waitList.p4.char.currentFrameLabel != "waiting")
               {
                  _waitList.p4.char.gotoAndPlay("waiting");
               }
               LocalizationManager.translateIdAndInsert(_waitList["player_count_txt"],11100,4);
            }
            if(joinMinPlayers > 1)
            {
               _waitList["player_count_txt"].text = _waitList["player_count_txt"].text.replace("1",joinMinPlayers);
            }
            if(joinMinPlayers < joinMaxPlayers)
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
            if(Boolean(_gameCardPopup))
            {
               DarkenManager.unDarken(_gameCardPopup);
            }
            DarkenManager.showLoadingSpiral(true);
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
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
         MinigameXtCommManager.sendMinigameJoinRequest(_joinGameObj.typeDefId,false,playMultiPlayer,_proModeId);
      }
      
      private static function loadCompleteHandler(evt:LoaderEvent) : void
      {
         if(!evt.status)
         {
            DebugUtility.debugTrace("ERROR: could not load game swf! loadCompleteHandler evt.message: " + evt.message);
         }
         else
         {
            startGameLoaded(evt.entry.loader);
         }
      }
      
      private static function loadProgressCompleteHandler() : void
      {
         startGameLoaded(LoadProgress.entry.loader);
      }
      
      private static function startGameLoaded(gameLoader:Loader) : void
      {
         if(_inInRoomGame)
         {
            _parentLayer.addChild(gameLoader);
            gameLoader.addEventListener(MouseEvent.MOUSE_DOWN,stopMouse,false,0,true);
            gameLoader.addEventListener(MouseEvent.MOUSE_MOVE,stopMouse,false,0,true);
            KeepAlive.startKATimer(gameLoader);
         }
         else
         {
            _frgLoader = gameLoader;
            _parentLayer.addChild(_frgLoader);
            _frgWaiting = false;
            gMainFrame.stage.focus = null;
            if(_joinGameObj.swfName == "Twister" || _joinGameObj.swfName == "FallingPhantoms" || _joinGameObj.swfName == "HorseRace" || _joinGameObj.swfName == "DolphinRace" || _joinGameObj.swfName == "GemBreaker" || _joinGameObj.swfName == "FortSmasher" || _joinGameObj.swfName == "SuperSort" || _joinGameObj.swfName == "FashionShow" || _joinGameObj.swfName == "PillBugs" || _joinGameObj.swfName == "QuestCombat" || _joinGameObj.swfName == "HedgeHog" || _joinGameObj.swfName == "TouchPool" || _joinGameObj.swfName == "ParachuteGlider" || _joinGameObj.swfName == "Pachinko" || _joinGameObj.swfName == "MiniGame_Memory" || _joinGameObj.swfName == "DistanceChallenge" || _joinGameObj.swfName == "PhantomFighter" || _joinGameObj.swfName == "QuestParachuteGlider" || _joinGameObj.swfName == "TowerDefense" || _joinGameObj.swfName == "EagleFlap" || _joinGameObj.swfName == "SpotOn")
            {
               gMainFrame.stage.quality = StageQuality.MEDIUM;
            }
            else if(_joinGameObj.swfName == "ArtStudioPrint" || _joinGameObj.swfName == "ArtPrintPlayPortrait" || _joinGameObj.swfName == "ArtStudioColor" || _joinGameObj.swfName == "ArtStudioPottery" || _joinGameObj.swfName == "ArtStudioPainting" || _joinGameObj.swfName == "BradyExpeditions" || _joinGameObj.swfName == "MicroMiraSays" || _joinGameObj.swfName == "MoatMadness" || _joinGameObj.swfName == "PhantomsTreasure")
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
         _minigameRef = IMinigame(gameLoader.content);
         var numPlayers:int = parseInt(_startData[2]);
         DebugUtility.debugTrace("numPlayers:" + numPlayers);
         var joinIds:Array = new Array(numPlayers);
         var sd:int = 3;
         while(sd < numPlayers + 3)
         {
            DebugUtility.debugTrace("p" + (sd - 2) + "Id:" + _startData[sd]);
            joinIds[sd - 3] = parseInt(_startData[sd++]);
         }
         if(inMinigame())
         {
            GuiManager.chatHist.removeKeyListeners();
         }
         KeepAlive.startKATimer(DisplayObjectContainer(_minigameRef).stage);
         EventDispatcher(_minigameRef).addEventListener(Event.COMPLETE,minigameLoadCompleteHandler,false,0,true);
         _minigameRef.start(_userId,joinIds,msg,leave);
         _startData.splice(1,2 + joinIds.length);
         _minigameRef.message(_startData);
         while(Boolean(_mmToSendWhenRefLoaded) && _mmToSendWhenRefLoaded.length > 0)
         {
            _minigameRef.message(_mmToSendWhenRefLoaded.shift());
         }
      }
      
      private static function loadPVPGameMedia(mediaId:int) : void
      {
         var pvpGameHelper:MediaHelper = new MediaHelper();
         pvpGameHelper.init(mediaId,mediaHelperCallback,true);
      }
      
      private static function mediaHelperCallback(img:MovieClip) : void
      {
         _pvpMedia[img.mediaHelper.id] = img;
         setMediaImage(img);
      }
      
      private static function setMediaImage(img:MovieClip) : void
      {
         while(_buddyGameInviteContent.itemBlock.numChildren > 0)
         {
            _buddyGameInviteContent.itemBlock.removeChildAt(0);
         }
         _buddyGameInviteContent.itemBlock.addChild(img);
      }
      
      private static function onPVPCloseInvite(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.parent.name == "invite")
         {
            if(_pvpGameDefId >= 0 && _pvpUserName != "")
            {
               _pvpCancelSubRoomId = gMainFrame.server.getPvpSubRoomId();
               MinigameXtCommManager.sendMinigamePvpMsg(_pvpGameDefId,MinigameXtCommManager.PVP_DENY_DENIED_OR_CANCEL);
               readySelfForPvpGame({"typeDefId":_pvpGameDefId},_pvpUserName,false);
            }
         }
         if(Boolean(_buddyGamePopup))
         {
            _buddyGamePopup.close();
         }
      }
      
      private static function onPVPYesInvite(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         sendResponseToPVPRequest(true);
         _buddyGamePopup.close();
         DarkenManager.showLoadingSpiral(true);
      }
      
      private static function onPVPNoInvite(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         sendResponseToPVPRequest(false);
         readySelfForPvpGame({"typeDefId":_pvpGameDefId},_pvpUserName,false);
         _buddyGamePopup.close();
      }
      
      private static function onYesNoReplay(o:Object) : void
      {
         if(Boolean(o.status))
         {
            sendPVPRequest(o.passback.gameDefId,o.passback.userName);
            displaySentRequestPopup(o.passback.mediaRefId,o.passback.userNameModerated);
            readySelfForPvpGame({"typeDefId":o.passback.gameDefId},o.passback.userName,true);
         }
      }
      
      private static function displayPVPReceivedRequestPopup(mediaId:int, avtName:String, gameName:String) : void
      {
         _pvpAmISender = false;
         _buddyGameInviteContent.invite.visible = false;
         _buddyGameInviteContent.refuse.visible = false;
         if(_pvpMedia[mediaId] == null)
         {
            loadPVPGameMedia(mediaId);
         }
         else
         {
            setMediaImage(_pvpMedia[mediaId]);
         }
         _buddyGameInviteContent.request.visible = true;
         _buddyGameInviteContent.request.popupTxt1.text = avtName;
         _buddyGameInviteContent.request.popupTxt3.text = gameName;
         if(!_buddyGamePopup.visible)
         {
            _buddyGamePopup.open();
         }
      }
      
      private static function displayPVPDeniedRequestPopup(mediaId:int, avtName:String) : void
      {
         _pvpAmISender = false;
         _buddyGameInviteContent.invite.visible = false;
         _buddyGameInviteContent.request.visible = false;
         if(_pvpMedia[mediaId] == null)
         {
            loadPVPGameMedia(mediaId);
         }
         else
         {
            setMediaImage(_pvpMedia[mediaId]);
         }
         _buddyGameInviteContent.refuse.visible = true;
         _buddyGameInviteContent.refuse.popupTxt1.text = avtName;
         if(!_buddyGamePopup.visible)
         {
            _buddyGamePopup.open();
         }
      }
      
      private static function minigameLoadCompleteHandler(e:Event) : void
      {
         LoadProgress.show(false);
         if(_inInRoomGame)
         {
            AvatarManager.showAvtAndChatLayers(false);
            DarkenManager.showLoadingSpiral(false);
         }
      }
      
      private static function startNowHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(Boolean(m.currentTarget.isGray))
         {
            return;
         }
         if(_frgWaiting && _waitIds.length >= _minReqPlayers && !RoomXtCommManager.isSwitching && !QuestManager.isInPrivateAdventureState)
         {
            MinigameXtCommManager.sendMinigameStartRequest(_joinGameObj.typeDefId);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      public static function inMinigame() : Boolean
      {
         if(_joinGameObj != null && (Boolean(_joinGameObj.swfName == "QuestCombat") || Boolean(_joinGameObj.isCustom)))
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
      
      public static function set userId(value:int) : void
      {
         _userId = value;
      }
      
      public static function msg(msgStr:Array) : void
      {
         var emotId:int = 0;
         var extra:String = null;
         if(msgStr[0] == "_a" && msgStr.length > 1)
         {
            emotId = int(msgStr[1]);
            if(msgStr.length > 2)
            {
               extra = msgStr[2];
            }
            AvatarManager.setPlayerAttachmentEmot(emotId,extra);
            return;
         }
         msgStr.splice(0,0,_joinGameObj.typeDefId);
         MinigameXtCommManager.sendMinigameMessageRequest(msgStr,_inInRoomGame);
      }
      
      public static function readySelfForCustomPVPGame(typeDefId:int, budUserName:String) : void
      {
         minigameInfoCache.currMinigameId = typeDefId;
         _pvpUserName = budUserName;
      }
      
      public static function readySelfForPvpGame(gameEntry:Object, budUserName:String, setReady:Boolean, isCustom:Boolean = false) : void
      {
         var ui:UserInfo = null;
         var jmi:MinigameInfo = minigameInfoCache.getMinigameInfo(gameEntry.typeDefId);
         if(Boolean(jmi))
         {
            _inInRoomGame = jmi.isInRoomGame;
            if(setReady)
            {
               if(_inInRoomGame)
               {
                  if(Boolean(_joinGameObj) && !_joinGameObj.isPvp)
                  {
                     _oldJoinGameObj = _joinGameObj;
                  }
                  _pvpGameDefId = gameEntry.typeDefId;
                  ui = gMainFrame.userInfo.getUserInfoByUserName(budUserName);
                  if(ui == null)
                  {
                     throw new Error("User info not available for " + budUserName + ". This should get fixed!");
                  }
                  _pvpUserNameModerated = ui.getModeratedUserName();
                  _pvpUserName = budUserName;
                  _joinGameObj = gameEntry;
                  _joinGameObj.name = LocalizationManager.translateIdOnly(jmi.titleStrId);
                  _joinGameObj.swfName = jmi.swfName;
                  _joinGameObj.isPvp = true;
                  _joinGameObj.isCustom = isCustom;
                  gMainFrame.server.setToJoinIRG(true);
                  minigameInfoCache.currMinigameId = _joinGameObj.typeDefId;
                  _inMinigame = true;
               }
            }
         }
         if(!setReady)
         {
            _pvpGameDefId = -1;
            _pvpUserName = "";
            _pvpUserNameModerated = "";
            if(Boolean(_oldJoinGameObj))
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
      
      public static function handleGameClick(gameEntry:Object, frgJoinedCallback:Function, skipGameCard:Boolean = false, gameCloseCallback:Function = null, optionalParam:int = 0) : void
      {
         var jmi:MinigameInfo = null;
         var myActivePet:Object = null;
         var petDef:Object = null;
         var currPet:Object = null;
         var petList:Array = null;
         var i:int = 0;
         var proModUserVarId:int = 0;
         var proModeUserVarValue:int = 0;
         if(Boolean(_gameCardPopup) && !_gameCardPopup.visible)
         {
            killJoinGamePopup();
         }
         if(!_inMinigame && !_gameCardPopup)
         {
            _roomMgr.forceStopMovement();
            _joinGameObj = gameEntry;
            jmi = minigameInfoCache.getMinigameInfo(_joinGameObj.typeDefId);
            if(jmi.gameDefId == 82)
            {
               _proModeId = optionalParam;
            }
            _joinGameObj.mi = jmi;
            _joinGameObj.name = LocalizationManager.translateIdOnly(jmi.titleStrId);
            _joinGameObj.swfName = jmi.swfName;
            _joinGameObj.isPvp = false;
            _joinFrgCallback = frgJoinedCallback;
            _inInRoomGame = jmi.isInRoomGame;
            myActivePet = PetManager.myActivePet;
            if(jmi.gameDefId == PET_WASH_DEF_ID)
            {
               if(Boolean(AvatarManager.playerAvatarWorldView))
               {
                  if(!AvatarManager.playerAvatarWorldView.getActivePet())
                  {
                     new SBOkPopup(_parentLayer,LocalizationManager.translateIdOnly(14683));
                     return;
                  }
                  if(!gMainFrame.userInfo.isMember)
                  {
                     new SBOkPopup(_parentLayer,LocalizationManager.translateIdOnly(14684));
                     return;
                  }
               }
            }
            else if(jmi.gameDefId == PET_SALON_DEF_ID || jmi.gameDefId == PET_SALON_PARTY_DEF_ID)
            {
               if(Boolean(AvatarManager.playerAvatarWorldView))
               {
                  if(!AvatarManager.playerAvatarWorldView.getActivePet())
                  {
                     new SBOkPopup(_parentLayer,LocalizationManager.translateIdOnly(14685));
                     return;
                  }
                  if(!gMainFrame.userInfo.isMember)
                  {
                     new SBOkPopup(_parentLayer,LocalizationManager.translateIdOnly(14686));
                     return;
                  }
               }
            }
            _gameCloseCallback = gameCloseCallback;
            if(jmi.petDefId > 0 && (myActivePet == null || myActivePet.defId != jmi.petDefId))
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup(UpsellManager.PETS,"playPetGame/" + jmi.titleStrId);
               }
               else
               {
                  petDef = PetManager.getPetDef(jmi.petDefId);
                  currPet = null;
                  petList = PetManager.myPetList;
                  for(i = 0; i < petList.length; i++)
                  {
                     if(petList[i].defId == petDef.defId)
                     {
                        currPet = petList[i];
                        break;
                     }
                  }
                  if(currPet != null && PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,currPet.type) && (_inInRoomGame || skipGameCard))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(currPet.lBits,currPet.uBits,currPet.eBits,currPet.name);
                     PetXtCommManager.sendPetSwitchRequest(currPet.idx,launchInRoomGame);
                  }
                  else
                  {
                     new SBOkPopup(_parentLayer,LocalizationManager.translateIdAndInsertOnly(14687,petDef.title.toLowerCase(),_joinGameObj.name));
                  }
               }
               return;
            }
            if(_inInRoomGame || skipGameCard)
            {
               gMainFrame.server.setToJoinIRG(true);
               launchGame();
            }
            else
            {
               proModUserVarId = int(_joinGameObj.mi.proModeUserVarRefId);
               proModeUserVarValue = int(gMainFrame.userInfo.userVarCache.getUserVarValueById(proModUserVarId));
               _gameCardPopup = new GameCardPopup(_parentLayer,jmi.gameCardScreen,playGame,openInstructions,killJoinGamePopup,null,null,proModUserVarId > 0,proModeUserVarValue,_joinGameObj.mi.maxPlayers > 1);
            }
         }
      }
      
      private static function launchInRoomGame(status:Boolean) : void
      {
         gMainFrame.server.setToJoinIRG(true);
         launchGame();
      }
      
      private static function closeHandler(m:MouseEvent = null) : void
      {
         leave();
      }
      
      private static function stopMouse(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      public static function startGame(data:Array) : void
      {
         _startData = data;
         _mmToSendWhenRefLoaded = [];
         createGameWindow();
      }
      
      public static function joinGameResponse(data:Array) : void
      {
         var petDef:Object = null;
         var c:int = 0;
         var w:int = 0;
         var strtBtn:MovieClip = null;
         var wid:int = 0;
         var joinedAvatarRef:Avatar = null;
         var avtView:AvatarView = null;
         var offset:Point = null;
         var avName:String = null;
         var space:int = 0;
         var firstName:String = null;
         var lastName:String = null;
         if(data[2] == "pf")
         {
            DarkenManager.showLoadingSpiral(false);
            GuiManager.handleGameExit();
            _inMinigame = false;
            _inInRoomGame = false;
            minigameInfoCache.currMinigameId = -1;
            gMainFrame.stage.quality = StageQuality.MEDIUM;
            gMainFrame.server.setToJoinIRG(false);
            petDef = PetManager.getPetDef(parseInt(data[3]));
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.PETS,"playPetGame/" + petDef.title);
            }
            else
            {
               new SBOkPopup(_parentLayer,LocalizationManager.translateIdAndInsertOnly(14687,petDef.title.toLowerCase(),_joinGameObj.name));
            }
            return;
         }
         if(data[2] == "mo")
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
         if(_inInRoomGame || _waitListPopup == null)
         {
            return;
         }
         if(int(data[1]) != gMainFrame.server.getCurrentRoomId(_inInRoomGame))
         {
            return;
         }
         _waitIds = [];
         for(c = 1; c < _maxAllowedPlayers + 1; c++)
         {
            while(_waitListPopup.content["p" + c].char.charLayer.numChildren > 0)
            {
               _waitListPopup.content["p" + c].char.charLayer.removeChildAt(0);
            }
            _waitListPopup.content["p" + c].char.gotoAndPlay("waiting");
            _waitListPopup.content["p" + c].nameBar.lastName_txt.text = "";
         }
         for(w = 2; w < _maxAllowedPlayers + 2; w++)
         {
            if(w < data.length)
            {
               wid = int(data[w]);
               _waitIds.push(wid);
               _waitListPopup.content["p" + (w - 1)].char.gotoAndPlay("up");
               joinedAvatarRef = AvatarManager.getAvatarBySfsUserId(wid);
               if(joinedAvatarRef == null)
               {
                  DebugUtility.debugTraceObject("AvatarManager.avatarList",AvatarManager.avatarList);
                  throw new Error("\"mj\" sent down bad sfsUserId wid:" + wid);
               }
               avtView = new AvatarView();
               avtView.init(joinedAvatarRef);
               avtView.playAnim(LayerAnim.AN_HUD_AVT);
               avtView.scaleX = 0.7;
               avtView.scaleY = 0.7;
               offset = AvatarUtility.getAvatarMinigameLobbyOffset(avtView.avTypeId);
               avtView.x = offset.x;
               avtView.y = offset.y;
               _waitListPopup.content["p" + (w - 1)].char.charLayer.addChild(avtView);
               avName = joinedAvatarRef.avName;
               space = avName.indexOf(" ");
               if(space != -1)
               {
                  firstName = avName.substr(0,space);
                  lastName = avName.substr(space + 1,avName.length);
               }
               else
               {
                  firstName = avName;
               }
               _waitListPopup.content["p" + (w - 1)].nameBar.firstName_txt.text = firstName;
               if(Boolean(lastName))
               {
                  _waitListPopup.content["p" + (w - 1)].nameBar.lastName_txt.text = lastName;
               }
            }
            else
            {
               _waitListPopup.content["p" + (w - 1)].char.gotoAndPlay("waiting");
               LocalizationManager.translateId(_waitListPopup.content["p" + (w - 1)].nameBar.firstName_txt,11101);
               _waitListPopup.content["p" + (w - 1)].nameBar.lastName_txt.text = "";
            }
         }
         strtBtn = _waitListPopup.content["startBtn"];
         if(_waitIds.length >= _minReqPlayers)
         {
            if(!strtBtn.hasEventListener(MouseEvent.MOUSE_DOWN))
            {
               strtBtn.addEventListener(MouseEvent.MOUSE_DOWN,startNowHandler,false,0,true);
            }
            strtBtn.visible = true;
         }
         else
         {
            strtBtn.visible = false;
         }
         if(!_waitListPopup.visible)
         {
            _waitListPopup.open();
         }
         waitListUpdate();
      }
      
      public static function minigameEndResponse(data:Array) : void
      {
         var gameEndedPopup:SBMessage = null;
         if(Boolean(_minigameRef))
         {
            _minigameRef.end(data);
            _minigameRef = null;
         }
         _mmToSendWhenRefLoaded = null;
         if(!_inInRoomGame)
         {
            gameEndedPopup = new SBMessage(_parentLayer,GETDEFINITIONBYNAME("ConfirmSkin"),LocalizationManager.translateIdOnly(11131));
            gameEndedPopup.closeCallback = leave;
         }
         else
         {
            gMainFrame.server.setToJoinIRG(false);
         }
      }
      
      public static function minigameRoomRemovedResponse(data:Array) : void
      {
         if(_rejoin)
         {
            launchGame();
            _rejoin = false;
         }
      }
      
      public static function messageGame(data:Array) : void
      {
         if(Boolean(_minigameRef))
         {
            _minigameRef.message(data);
         }
         else if(Boolean(_mmToSendWhenRefLoaded))
         {
            _mmToSendWhenRefLoaded.push(data);
         }
      }
      
      public static function pvpResponse(data:Array) : void
      {
         var userName:String = null;
         var userNameModeratedFlag:int = 0;
         var gameId:int = int(data[2]);
         var status:int = int(data[3]);
         if(status == MinigameXtCommManager.PVP_REQUEST_OR_ACCEPT)
         {
            userName = data[4];
            userNameModeratedFlag = int(data[5]);
            readySelfForPvpGame({"typeDefId":gameId},userName,true);
            displayPVPReceivedRequestPopup(minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId,userNameModeratedFlag > 0 ? userName : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME),MinigameManager.getGameName(_pvpGameDefId));
         }
         else if(status == MinigameXtCommManager.PVP_DENY_DENIED_OR_CANCEL)
         {
            if(_pvpGameDefId > 0 && _pvpUserName != "")
            {
               if(_buddyGamePopup.visible && !_pvpAmISender)
               {
                  _buddyGamePopup.close();
               }
               else
               {
                  displayPVPDeniedRequestPopup(minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId,_pvpUserNameModerated);
               }
               readySelfForPvpGame({"typeDefId":gameId},_pvpUserName,false);
            }
         }
      }
      
      public static function leaderBoardResponse(data:Array) : void
      {
         var leaderBoardData:Object = null;
         var entryCount:int = 0;
         var dataIndex:int = 0;
         var leaderIndex:int = 0;
         var gameDefID:int = int(data[2]);
         if(gameDefID != -1)
         {
            leaderBoardData = new Object();
            leaderBoardData._cacheTime = getTimer();
            leaderBoardData._allTime = new Array();
            leaderBoardData._thisWeek = new Array();
            leaderBoardData._buddy = new Array();
            dataIndex = 3;
            entryCount = int(data[dataIndex++]);
            leaderIndex = 0;
            while(entryCount > 0)
            {
               leaderBoardData._allTime[leaderIndex] = new Object();
               leaderBoardData._allTime[leaderIndex]._name = data[dataIndex++];
               leaderBoardData._allTime[leaderIndex++]._score = data[dataIndex++];
               entryCount--;
            }
            entryCount = int(data[dataIndex++]);
            leaderIndex = 0;
            while(entryCount > 0)
            {
               leaderBoardData._thisWeek[leaderIndex] = new Object();
               leaderBoardData._thisWeek[leaderIndex]._name = data[dataIndex++];
               leaderBoardData._thisWeek[leaderIndex++]._score = data[dataIndex++];
               entryCount--;
            }
            entryCount = int(data[dataIndex++]);
            leaderIndex = 0;
            while(entryCount > 0)
            {
               leaderBoardData._buddy[leaderIndex] = new Object();
               leaderBoardData._buddy[leaderIndex]._name = data[dataIndex++];
               leaderBoardData._buddy[leaderIndex++]._score = data[dataIndex++];
               entryCount--;
            }
            _leaderBoardCache[gameDefID] = leaderBoardData;
            if(_joinGameObj != null && _gameCardPopup != null && _joinGameObj.typeDefId == gameDefID)
            {
               onLeaderBoardSelected();
            }
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      public static function displaySentRequestPopup(mediaId:int, avtName:String) : void
      {
         _pvpAmISender = true;
         _buddyGameInviteContent.request.visible = false;
         _buddyGameInviteContent.refuse.visible = false;
         if(_pvpMedia[mediaId] == null)
         {
            loadPVPGameMedia(mediaId);
         }
         else
         {
            setMediaImage(_pvpMedia[mediaId]);
         }
         _buddyGameInviteContent.invite.visible = true;
         _buddyGameInviteContent.invite.popupTxt2.text = avtName;
         if(!_buddyGamePopup.visible)
         {
            _buddyGamePopup.open();
         }
      }
      
      public static function getGameName(id:int) : String
      {
         var mi:MinigameInfo = null;
         if(Boolean(minigameInfoCache))
         {
            mi = minigameInfoCache.getMinigameInfo(id);
            if(Boolean(mi))
            {
               return LocalizationManager.translateIdOnly(mi.titleStrId);
            }
         }
         return "";
      }
      
      public static function getGameNameId(id:int) : int
      {
         var mi:MinigameInfo = null;
         if(Boolean(minigameInfoCache))
         {
            mi = minigameInfoCache.getMinigameInfo(id);
            if(Boolean(mi))
            {
               return mi.titleStrId;
            }
         }
         return -1;
      }
      
      public static function getActivePet(onLoadedCallback:Function) : Sprite
      {
         var wp:WorldPet = AvatarManager.playerAvatarWorldView.getActivePet();
         if(Boolean(wp))
         {
            return PetManager.getPetSprite(wp.getLBits(),wp.getUBits(),wp.getEBits(),wp.getType(),onLoadedCallback);
         }
         return null;
      }
      
      public static function getActivePetName() : String
      {
         if(Boolean(PetManager.myActivePet))
         {
            return LocalizationManager.translatePetName(PetManager.myActivePet.name);
         }
         return "";
      }
      
      public static function sendPetItemRequest(cat9:int, cat10:int, cat11:int, environment:int, callback:Function) : void
      {
         PetXtCommManager.sendPetItemRequest(cat9,cat10,cat11,environment,callback);
      }
      
      public static function setPetSparkle(sparkle:int) : void
      {
         PetManager.sendPetSparkle(sparkle);
      }
      
      public static function getIsPlayerMember() : Boolean
      {
         return gMainFrame.userInfo.isMember;
      }
      
      public static function minigameGems(data:Object) : void
      {
         var gemData:Object = null;
         _gemSerialNumber = parseInt(data[2]);
         if(parseInt(data[3]) == 1)
         {
            _scoreSN = _gemSerialNumber;
         }
         if(_awardGemsQueue.length > 0)
         {
            gemData = _awardGemsQueue.pop();
            sendGemAward(gemData);
         }
      }
      
      public static function minigamePetMastery(data:Object) : void
      {
         var masteryData:Object = null;
         _petMasterySerialNumber = parseInt(data[2]);
         if(data[3] == "1")
         {
            _petMasteryQueuePopup = true;
         }
         if(_awardMasteryPointsQueue.length > 0)
         {
            masteryData = _awardMasteryPointsQueue.pop();
            sendMasteryPoints(masteryData);
         }
      }
      
      public static function awardPetMasteryPoints(amount:int) : void
      {
         var masteryData:Object = null;
         if(amount > 0)
         {
            if(MainFrame.isInitialized())
            {
               masteryData = new Object();
               masteryData.amount = amount;
               PetManager.addToActivePetMastery(amount);
               if(minigameInfoCache != null)
               {
                  masteryData.minigameID = minigameInfoCache.currMinigameId;
               }
               else
               {
                  masteryData.minigameID = -1;
               }
               if(_petMasterySerialNumber != -1)
               {
                  sendMasteryPoints(masteryData);
               }
               else
               {
                  _awardMasteryPointsQueue.push(masteryData);
               }
            }
         }
      }
      
      public static function awardGems(amount:int, inGameDefID:int) : void
      {
         var gemData:Object = null;
         if(amount > 0)
         {
            if(MainFrame.isInitialized())
            {
               gemData = new Object();
               gemData.amount = amount;
               gemData.minigameID = inGameDefID;
               if(_gemSerialNumber != -1)
               {
                  sendGemAward(gemData);
               }
               else
               {
                  _awardGemsQueue.push(gemData);
               }
            }
         }
      }
      
      private static function sendMasteryPoints(masteryData:Object) : void
      {
         var encryptedPoints:Number = (masteryData.amount + 29) * 7 + (_userId + 99) * 3 + (_petMasterySerialNumber + 49) * 5;
         var encryptedGameDefID:Number = (masteryData.minigameID + 49) * 3 + (_petMasterySerialNumber + 83) * 5;
         var encryptedCheckSum:Number = (_petMasterySerialNumber + _userId + masteryData.amount) * 3 + masteryData.amount * 3;
         _petMasterySerialNumber = -1;
         gMainFrame.server.setXtObject_Str("ma",[encryptedPoints,encryptedGameDefID,encryptedCheckSum]);
      }
      
      private static function sendGemAward(gemData:Object) : void
      {
         var encryptedGems:Number = (gemData.amount + 29) * 7 + (_userId + 99) * 3 + (_gemSerialNumber + 49) * 5;
         var encryptedGameDefID:Number = (gemData.minigameID + 49) * 3 + (_gemSerialNumber + 83) * 5;
         var encryptedCheckSum:Number = (_gemSerialNumber + _userId + gemData.amount) * 3 + gemData.amount * 3;
         _gemSerialNumber = -1;
         gMainFrame.server.setXtObject_Str("mg",[encryptedGems,encryptedGameDefID,encryptedCheckSum]);
      }
      
      public static function sendScore(scoreMain:Number, scoreVal:Number, scoreNum:Number, index:int, game:int) : void
      {
         gMainFrame.server.setXtObject_Str("msv",[scoreMain + 3 * index,scoreVal - 8 * index,scoreNum + 5 * index,index * 5 + 7 * _scoreSN,game * 3 + _scoreSN]);
      }
      
      public static function getScoreSN() : int
      {
         return _scoreSN;
      }
      
      public static function keepAlive() : void
      {
         KeepAlive.inputReceivedHandler(null);
      }
      
      public static function handleQuestMiniGameComplete(inResults:int) : void
      {
         QuestManager.handleQuestMiniGameComplete(inResults);
      }
   }
}

