package game
{
   import achievement.AchievementManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import com.adobe.utils.StringUtil;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.KeepAlive;
   import com.sbi.client.SFEvent;
   import com.sbi.client.SFRoom;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.popup.SBMessage;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import gui.DarkenManager;
   import gui.EmoticonUtility;
   import gui.GameCardPopup;
   import gui.GuiManager;
   import gui.LoadingSpiral;
   import gui.SafeChatManager;
   import gui.UpsellManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import pet.PetXtCommManager;
   import pet.WorldPet;
   import playerWall.PlayerWallManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class MinigameManager
   {
      
      private static const keepGameBase:GameBase = null;
      
      public static const PET_SALON_DEF_ID:int = 52;
      
      public static const PET_SALON_PARTY_DEF_ID:int = 81;
      
      public static const AVATAR_WIDTH:int = 150;
      
      public static const AVATAR_HEIGHT:int = 150;
      
      public static const PET_WASH_DEF_ID:int = 43;
      
      private static var _userId:int;
      
      private static var _parentLayer:DisplayObjectContainer;
      
      private static var _minigameRef:IMinigame;
      
      private static var _primaryRoomName:String;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _gameCardPopup:GameCardPopup;
      
      private static var _joinGameObj:Object;
      
      private static var _oldJoinGameObj:Object;
      
      private static var _onClickParams:Object;
      
      private static var _joinFrgCallback:Function;
      
      private static var _inMinigame:Boolean;
      
      private static var _waitlistP1X:Number;
      
      private static var _waitlistP2X:Number;
      
      private static var _waitlistP3X:Number;
      
      private static var _waitlistP4X:Number;
      
      private static var _pvpGameDefId:int;
      
      private static var _pvpUserName:String;
      
      private static var _pvpUserNameModerated:String;
      
      private static var _pvpCancelSubRoomId:int = -1;
      
      private static var _pvpCancelMSReceived:Boolean;
      
      private static var _buddyGameInviteContent:MovieClip;
      
      private static var _buddyGamePopup:SBPopup;
      
      private static var _miniSpiral:LoadingSpiral;
      
      private static var _pvpMedia:Array;
      
      private static var _pvpAmISender:Boolean;
      
      private static var _inInRoomGame:Boolean;
      
      private static var _frgWaiting:Boolean = false;
      
      private static var _rejoin:Boolean = false;
      
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
      
      private static var _gameCloseCallback:Function;
      
      private static var _leaderBoardCache:Dictionary;
      
      public static var _pvpPromptReplay:Boolean;
      
      public static var minigameInfoCache:MinigameInfoCache;
      
      public static const GameTotem:Class = Game_Sign_swf$fc23efb8027f30caf6134175c0e3ff65672977561;
      
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
         _buddyGameInviteContent.invite.cancelBtn.addEventListener("mouseDown",onPVPCloseInvite);
         _buddyGameInviteContent.request.noBtn.addEventListener("mouseDown",onPVPNoInvite);
         _buddyGameInviteContent.request.okBtn.addEventListener("mouseDown",onPVPYesInvite);
         _buddyGameInviteContent.refuse.okBtn.addEventListener("mouseDown",onPVPCloseInvite);
         _miniSpiral = new LoadingSpiral(_buddyGameInviteContent.invite,105,37);
         _miniSpiral.scaleX = 0.5;
         _miniSpiral.scaleY = 0.5;
         _pvpMedia = [];
         _gemSerialNumber = -1;
         _scoreSN = -1;
         _petMasterySerialNumber = -1;
         _petMasteryQueuePopup = false;
         _awardGemsQueue = [];
         _awardMasteryPointsQueue = [];
         _pvpPromptReplay = false;
         _leaderBoardCache = new Dictionary();
         gMainFrame.server.addEventListener("OnJoinRoom",joinRoomHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         minigameInfoCache = null;
         gMainFrame.server.removeEventListener("OnJoinRoom",joinRoomHandler);
      }
      
      public static function setPrimaryRoomNameBypass() : void
      {
         _primaryRoomNameBypass = true;
      }
      
      public static function getLeaderBoardCache() : Dictionary
      {
         return _leaderBoardCache;
      }
      
      private static function leave(param1:Boolean = false, param2:int = 0) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:String = null;
         if(_frgWaiting)
         {
            _loc4_ = true;
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
                  _loc3_ = _primaryRoomName.slice(0,6);
                  if(_loc3_ != "quest_")
                  {
                     _roomMgr.minigameJoinRoom(_primaryRoomName);
                  }
                  else
                  {
                     QuestXtCommManager.questFullRoomMinigameComplete(_primaryRoomName,param2);
                  }
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
         if(_waitListPopup && _waitListPopup.visible)
         {
            _waitListPopup.close();
            _waitListPopup.content["p1"].x = _waitlistP1X;
            _waitListPopup.content["p2"].x = _waitlistP2X;
            _waitListPopup.content["p3"].x = _waitlistP3X;
            _waitListPopup.content["p4"].x = _waitlistP4X;
         }
         leaveGame(_loc4_);
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
         gMainFrame.stage.quality = "medium";
         DarkenManager.showLoadingSpiral(false);
         if(!_inInRoomGame && !param1)
         {
            LoadProgress.show(true,6);
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
         SBTracker.trackPageview("/game/play/minigame/#" + getGameNameId(_joinGameObj.typeDefId));
         if(_waitListPopup && _waitListPopup.content && _waitListPopup.content["waitingTxt"])
         {
            LocalizationManager.translateId(_waitListPopup.content["waitingTxt"],11099);
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
      
      private static function waitListUpdate() : void
      {
      }
      
      private static function sendPVPRequest(param1:int, param2:String) : void
      {
         MinigameXtCommManager.sendMinigamePvpMsg(param1,0,param2);
      }
      
      private static function sendResponseToPVPRequest(param1:Boolean) : void
      {
         MinigameXtCommManager.sendMinigamePvpMsg(_pvpGameDefId,param1 ? 0 : 1);
      }
      
      private static function playGame(param1:int) : void
      {
         var _loc2_:TextFormat = null;
         if(RoomXtCommManager.isSwitching)
         {
            return;
         }
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(playGame,param1);
            return;
         }
         _proModeId = param1;
         killJoinGamePopup();
         if(_joinGameObj.mi.maxPlayers > 1 && _joinGameObj.mi.maxPlayers <= 4)
         {
            _waitList = GETDEFINITIONBYNAME("MinigameLobbyContent");
            _waitListPopup = new SBPopup(_parentLayer,GETDEFINITIONBYNAME("MinigameLobbySkin"),_waitList,true,true,false,false,true);
            _waitListPopup.content.scaleX = 1;
            _waitListPopup.content.scaleY = 1;
            _waitListPopup.skin.s["bx"].addEventListener("mouseDown",onSingleMultiplayerPopupXBtn,false,0,true);
            _waitList.gameTitleTxt.text = _joinGameObj.name;
            _waitList.startBtn.visible = false;
            _waitList.waiting_txt.visible = false;
            _waitList.player_count_txt.x += _waitList.player_count_txt.width;
            LocalizationManager.translateIdAndInsert(_waitList.player_count_txt,11100,_joinGameObj.mi.maxPlayers);
            _loc2_ = new TextFormat();
            _loc2_.align = "center";
            _waitList.player_count_txt.setTextFormat(_loc2_);
            if(!Utility.canMultiplayer())
            {
               _waitList.multiplayerBtn.activateGrayState(true);
               _waitList.startBtn.activateGrayState(true);
            }
            _waitList.multiplayerBtn.addEventListener("mouseDown",onSingleMultiplayerBtn,false,0,true);
            _waitList.singlePlayerBtn.addEventListener("mouseDown",onSingleMultiplayerBtn,false,0,true);
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
         var _loc9_:TextFormat = null;
         var _loc7_:AvatarView = null;
         var _loc6_:String = null;
         var _loc5_:int = 0;
         var _loc4_:String = null;
         var _loc2_:String = null;
         DebugUtility.debugTrace("Launch Game: " + _joinGameObj.name + " typeDefId:" + _joinGameObj.typeDefId);
         minigameInfoCache.currMinigameId = _joinGameObj.typeDefId;
         _inMinigame = true;
         if(!_inInRoomGame && _primaryRoomName != "" && _joinFrgCallback != null)
         {
            _joinFrgCallback();
            _joinFrgCallback = null;
         }
         var _loc10_:MinigameInfo = minigameInfoCache.getMinigameInfo(_joinGameObj.typeDefId);
         var _loc3_:int = int(_loc10_.minPlayers);
         var _loc8_:int = int(_loc10_.maxPlayers);
         _minReqPlayers = _loc3_;
         _maxAllowedPlayers = _loc8_;
         if(_loc8_ > 1 && _loc8_ <= 4 && param1)
         {
            _waitList.multiplayerBtn.visible = false;
            _waitList.singlePlayerBtn.visible = false;
            _waitList.waiting_txt.visible = true;
            _waitList.startBtn.visible = true;
            _waitList.player_count_txt.x -= _waitList.player_count_txt.width;
            _loc9_ = new TextFormat();
            _loc9_.align = "right";
            _waitList.player_count_txt.setTextFormat(_loc9_);
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
            _loc7_ = new AvatarView();
            _loc7_.init(AvatarManager.playerAvatar);
            _loc7_.playAnim(15);
            _waitList.p1.char.charLayer.addChild(_loc7_);
            _loc6_ = AvatarManager.playerAvatar.avName;
            _loc5_ = _loc6_.indexOf(" ");
            if(_loc5_ != -1)
            {
               _loc4_ = _loc6_.substr(0,_loc5_);
               _loc2_ = _loc6_.substr(_loc5_ + 1,_loc6_.length);
            }
            else
            {
               _loc4_ = _loc6_;
            }
            _waitList.p1.nameBar.firstName_txt.text = _loc4_;
            if(_loc2_)
            {
               _waitList.p1.nameBar.lastName_txt.text = _loc2_;
            }
            if(_loc8_ == 2)
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
            else if(_loc8_ == 3)
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
            else if(_loc8_ == 4)
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
            if(_loc3_ > 1)
            {
               _waitList["player_count_txt"].text = _waitList["player_count_txt"].text.replace("1",_loc3_);
            }
            if(_loc3_ < _loc8_)
            {
               _waitList.startBtn.addEventListener("mouseDown",startNowHandler,false,0,true);
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
               killJoinGamePopup();
            }
            DarkenManager.showLoadingSpiral(true);
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         PlayerWallManager.setForWaitingOnWallResponse(false);
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
            param1.addEventListener("mouseDown",stopMouse,false,0,true);
            param1.addEventListener("mouseMove",stopMouse,false,0,true);
            KeepAlive.startKATimer(param1);
         }
         else
         {
            _frgLoader = param1;
            _parentLayer.addChild(_frgLoader);
            _frgWaiting = false;
            gMainFrame.stage.focus = null;
            if(_joinGameObj.swfName == "Twister" || _joinGameObj.swfName == "FallingPhantoms" || _joinGameObj.swfName == "HorseRace" || _joinGameObj.swfName == "DolphinRace" || _joinGameObj.swfName == "GemBreaker" || _joinGameObj.swfName == "FortSmasher" || _joinGameObj.swfName == "SuperSort" || _joinGameObj.swfName == "FashionShow" || _joinGameObj.swfName == "PillBugs" || _joinGameObj.swfName == "QuestCombat" || _joinGameObj.swfName == "HedgeHog" || _joinGameObj.swfName == "TouchPool" || _joinGameObj.swfName == "ParachuteGlider" || _joinGameObj.swfName == "Pachinko" || _joinGameObj.swfName == "MiniGame_Memory" || _joinGameObj.swfName == "DistanceChallenge" || _joinGameObj.swfName == "PhantomFighter" || _joinGameObj.swfName == "QuestParachuteGlider" || _joinGameObj.swfName == "TowerDefense" || _joinGameObj.swfName == "EagleFlap" || _joinGameObj.swfName == "SpotOn" || _joinGameObj.swfName == "TrueFalse")
            {
               gMainFrame.stage.quality = "medium";
            }
            else if(_joinGameObj.swfName == "ArtStudioPrint" || _joinGameObj.swfName == "ArtPrintPlayPortrait" || _joinGameObj.swfName == "ArtStudioColor" || _joinGameObj.swfName == "ArtStudioPottery" || _joinGameObj.swfName == "ArtStudioPainting" || _joinGameObj.swfName == "BradyExpeditions" || _joinGameObj.swfName == "MicroMiraSays" || _joinGameObj.swfName == "MoatMadness" || _joinGameObj.swfName == "PhantomsTreasure")
            {
               gMainFrame.stage.quality = "high";
            }
            else
            {
               gMainFrame.stage.quality = "low";
            }
            if(_joinGameObj.swfName == "TrueFalse")
            {
               GuiManager.enableGameHud(true,"game");
               GuiManager.mainHud.parent.setChildIndex(GuiManager.mainHud,GuiManager.mainHud.parent.numChildren - 1);
            }
         }
         if(_waitListPopup && _waitListPopup.visible)
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
         var _loc4_:int = 3;
         while(_loc4_ < _loc2_ + 3)
         {
            DebugUtility.debugTrace("p" + (_loc4_ - 2) + "Id:" + _startData[_loc4_]);
            _loc3_[_loc4_ - 3] = parseInt(_startData[_loc4_++]);
         }
         if(inMinigame() && _joinGameObj.swfName != "TrueFalse")
         {
            GuiManager.chatHist.removeKeyListeners();
         }
         KeepAlive.startKATimer(DisplayObjectContainer(_minigameRef).stage);
         EventDispatcher(_minigameRef).addEventListener("complete",minigameLoadCompleteHandler,false,0,true);
         _minigameRef.start(_userId,_loc3_,msg,leave);
         _startData.splice(1,2 + _loc3_.length);
         _minigameRef.message(_startData);
         while(_mmToSendWhenRefLoaded && _mmToSendWhenRefLoaded.length > 0)
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
               MinigameXtCommManager.sendMinigamePvpMsg(_pvpGameDefId,1);
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
            displaySentRequestPopup(param1.passback.mediaRefId,param1.passback.userNameModerated);
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
         if(_frgWaiting && _waitIds.length >= _minReqPlayers && !RoomXtCommManager.isSwitching && !QuestManager.isInPrivateAdventureState)
         {
            MinigameXtCommManager.sendMinigameStartRequest(_joinGameObj.typeDefId);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      public static function inMinigame() : Boolean
      {
         if(_joinGameObj != null && (_joinGameObj.swfName == "QuestCombat" || _joinGameObj.isCustom))
         {
            return false;
         }
         return _inMinigame;
      }
      
      public static function isInReadyModeForPVP() : Boolean
      {
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
      
      public static function msg(param1:Array, param2:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc3_:String = null;
         if(param1[0] == "_a" && param1.length > 1)
         {
            _loc4_ = int(param1[1]);
            if(param1.length > 2)
            {
               _loc3_ = param1[2];
            }
            AvatarManager.setPlayerAttachmentEmot(_loc4_,_loc3_);
            return;
         }
         if(param2)
         {
            param1[0] = UserCommXtCommManager.fixMispellings(param1[0]);
            param1[0] = UserCommXtCommManager.adjustCamelCase(param1[0]);
            param1[0] = UserCommXtCommManager.adjustSpecialWords(param1[0]);
         }
         param1.splice(0,0,_joinGameObj.typeDefId);
         MinigameXtCommManager.sendMinigameMessageRequest(param1,_inInRoomGame);
         if(param2 && GuiManager.chatHist.enableFreeChatValue)
         {
            GuiManager.chatHist.resetTreeSearch();
            GuiManager.chatHist.chatMsgText.text = "";
            gMainFrame.stage.focus = GuiManager.chatHist.chatMsgText;
         }
      }
      
      public static function readySelfForCustomPVPGame(param1:int, param2:String) : void
      {
         minigameInfoCache.currMinigameId = param1;
         _pvpUserName = param2;
      }
      
      public static function readySelfForPvpGame(param1:Object, param2:String, param3:Boolean, param4:Boolean = false) : void
      {
         var _loc5_:UserInfo = null;
         var _loc6_:MinigameInfo = minigameInfoCache.getMinigameInfo(param1.typeDefId);
         if(_loc6_)
         {
            _inInRoomGame = _loc6_.isInRoomGame;
            if(param3)
            {
               if(_inInRoomGame)
               {
                  if(_joinGameObj && !_joinGameObj.isPvp)
                  {
                     _oldJoinGameObj = _joinGameObj;
                  }
                  _pvpGameDefId = param1.typeDefId;
                  _loc5_ = gMainFrame.userInfo.getUserInfoByUserName(param2);
                  if(_loc5_ == null)
                  {
                     throw new Error("User info not available for " + param2 + ". This should get fixed!");
                  }
                  _pvpUserNameModerated = _loc5_.getModeratedUserName();
                  _pvpUserName = param2;
                  _joinGameObj = param1;
                  _joinGameObj.name = LocalizationManager.translateIdOnly(_loc6_.titleStrId);
                  _joinGameObj.swfName = _loc6_.swfName;
                  _joinGameObj.isPvp = true;
                  _joinGameObj.isCustom = param4;
                  gMainFrame.server.setToJoinIRG(true);
                  minigameInfoCache.currMinigameId = _joinGameObj.typeDefId;
                  _inMinigame = true;
               }
            }
         }
         if(!param3)
         {
            _pvpGameDefId = -1;
            _pvpUserName = "";
            _pvpUserNameModerated = "";
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
      
      public static function handleGameClick(param1:Object, param2:Function, param3:Boolean = false, param4:Function = null, param5:int = 0) : void
      {
         var _loc7_:MinigameInfo = null;
         var _loc6_:Object = null;
         var _loc8_:Object = null;
         var _loc11_:Object = null;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         if(_gameCardPopup)
         {
            killJoinGamePopup();
         }
         if(!_inMinigame && !_gameCardPopup)
         {
            _roomMgr.forceStopMovement();
            if(!minigameInfoCache.getMinigameInfo(param1.typeDefId))
            {
               DarkenManager.showLoadingSpiral(true);
               MinigameXtCommManager.sendMinigameInfoRequest([param1.typeDefId],false,onMinigameInfoResponseWhenClicked);
               _onClickParams = {
                  "gameEntry":param1,
                  "frgJoinedCallback":param2,
                  "skipGameCard":param3,
                  "gameCloseCallback":param4,
                  "optionalParam":param5
               };
               return;
            }
            _joinGameObj = param1;
            _loc7_ = minigameInfoCache.getMinigameInfo(_joinGameObj.typeDefId);
            if(_loc7_.gameDefId == 82)
            {
               _proModeId = param5;
            }
            _joinGameObj.mi = _loc7_;
            _joinGameObj.name = LocalizationManager.translateIdOnly(_loc7_.titleStrId);
            _joinGameObj.swfName = _loc7_.swfName;
            _joinGameObj.isPvp = false;
            _joinFrgCallback = param2;
            _inInRoomGame = _loc7_.isInRoomGame;
            _loc6_ = PetManager.myActivePet;
            if(_loc7_.gameDefId == 43)
            {
               if(AvatarManager.playerAvatarWorldView)
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
            else if(_loc7_.gameDefId == 52 || _loc7_.gameDefId == 81)
            {
               if(AvatarManager.playerAvatarWorldView)
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
            _gameCloseCallback = param4;
            if(_loc7_.petDefId > 0 && (_loc6_ == null || _loc6_.defId != _loc7_.petDefId))
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup(10,"playPetGame/" + _loc7_.titleStrId);
               }
               else
               {
                  _loc8_ = PetManager.getPetDef(_loc7_.petDefId);
                  _loc11_ = null;
                  _loc9_ = PetManager.myPetList;
                  _loc10_ = 0;
                  while(_loc10_ < _loc9_.length)
                  {
                     if(_loc9_[_loc10_].defId == _loc8_.defId)
                     {
                        _loc11_ = _loc9_[_loc10_];
                        break;
                     }
                     _loc10_++;
                  }
                  if(_loc11_ != null && PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc11_.type) && (_inInRoomGame || param3))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(_loc11_.lBits,_loc11_.uBits,_loc11_.eBits,_loc11_.name);
                     PetXtCommManager.sendPetSwitchRequest(_loc11_.idx,launchInRoomGame);
                  }
                  else
                  {
                     new SBOkPopup(_parentLayer,LocalizationManager.translateIdAndInsertOnly(14687,_loc8_.title.toLowerCase(),_joinGameObj.name));
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
               _gameCardPopup = new GameCardPopup(_parentLayer,_joinGameObj,playGame,killJoinGamePopup);
            }
         }
      }
      
      private static function launchInRoomGame(param1:Boolean) : void
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
      
      private static function onMinigameInfoResponseWhenClicked() : void
      {
         if(_onClickParams)
         {
            handleGameClick(_onClickParams.gameEntry,_onClickParams.frgJoinedCallback,_onClickParams.skipGameCard,_onClickParams.gameCloseCallback,_onClickParams.optionalParam);
            _onClickParams = null;
         }
      }
      
      public static function startGame(param1:Array) : void
      {
         _startData = param1;
         _mmToSendWhenRefLoaded = [];
         createGameWindow();
      }
      
      public static function joinGameResponse(param1:Array) : void
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:Avatar = null;
         var _loc13_:AvatarView = null;
         var _loc12_:Point = null;
         var _loc11_:String = null;
         var _loc10_:int = 0;
         var _loc9_:String = null;
         var _loc3_:String = null;
         var _loc7_:MovieClip = null;
         if(param1[2] == "pf")
         {
            DarkenManager.showLoadingSpiral(false);
            GuiManager.handleGameExit();
            _inMinigame = false;
            _inInRoomGame = false;
            minigameInfoCache.currMinigameId = -1;
            gMainFrame.stage.quality = "medium";
            gMainFrame.server.setToJoinIRG(false);
            _loc4_ = PetManager.getPetDef(parseInt(param1[3]));
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(10,"playPetGame/" + _loc4_.title);
            }
            else
            {
               new SBOkPopup(_parentLayer,LocalizationManager.translateIdAndInsertOnly(14687,_loc4_.title.toLowerCase(),_joinGameObj.name));
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
            gMainFrame.stage.quality = "medium";
            gMainFrame.server.setToJoinIRG(false);
            _frgWaiting = false;
            UpsellManager.displayPopup(13,"playMOGame/" + _joinGameObj.name);
            return;
         }
         if(param1[2] == "as")
         {
            DarkenManager.showLoadingSpiral(false);
            _roomMgr.setMinigameIdToJoin(minigameInfoCache.currMinigameId);
            if(param1[3] == -1)
            {
               new SBYesNoPopup(_parentLayer,LocalizationManager.translateIdOnly(23803),true,GuiManager.switchToOceanAnimal,{
                  "switchRooms":false,
                  "switchDens":false
               });
            }
            else
            {
               new SBOkPopup(_parentLayer,LocalizationManager.translateIdOnly(23910));
            }
            GuiManager.handleGameExit();
            _inMinigame = false;
            _inInRoomGame = false;
            minigameInfoCache.currMinigameId = -1;
            gMainFrame.stage.quality = "medium";
            gMainFrame.server.setToJoinIRG(false);
            _frgWaiting = false;
         }
         else
         {
            if(_inInRoomGame || _waitListPopup == null)
            {
               return;
            }
            if(int(param1[1]) != gMainFrame.server.getCurrentRoomId(_inInRoomGame))
            {
               return;
            }
            _waitIds = [];
            _loc6_ = 1;
            while(_loc6_ < _maxAllowedPlayers + 1)
            {
               while(_waitListPopup.content["p" + _loc6_].char.charLayer.numChildren > 0)
               {
                  _waitListPopup.content["p" + _loc6_].char.charLayer.removeChildAt(0);
               }
               _waitListPopup.content["p" + _loc6_].char.gotoAndPlay("waiting");
               _waitListPopup.content["p" + _loc6_].nameBar.lastName_txt.text = "";
               _loc6_++;
            }
            _loc2_ = 2;
            while(_loc2_ < _maxAllowedPlayers + 2)
            {
               if(_loc2_ < param1.length)
               {
                  _loc5_ = int(param1[_loc2_]);
                  _waitIds.push(_loc5_);
                  _waitListPopup.content["p" + (_loc2_ - 1)].char.gotoAndPlay("up");
                  _loc8_ = AvatarManager.getAvatarBySfsUserId(_loc5_);
                  if(_loc8_ == null)
                  {
                     DebugUtility.debugTraceObject("AvatarManager.avatarList",AvatarManager.avatarList);
                     throw new Error("\"mj\" sent down bad sfsUserId wid:" + _loc5_);
                  }
                  _loc13_ = new AvatarView();
                  _loc13_.init(_loc8_);
                  _loc13_.playAnim(15);
                  _loc13_.scaleX = 0.7;
                  _loc13_.scaleY = 0.7;
                  _loc12_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc13_.avTypeId);
                  _loc13_.x = _loc12_.x;
                  _loc13_.y = _loc12_.y;
                  _waitListPopup.content["p" + (_loc2_ - 1)].char.charLayer.addChild(_loc13_);
                  _loc11_ = _loc8_.avName;
                  _loc10_ = _loc11_.indexOf(" ");
                  if(_loc10_ != -1)
                  {
                     _loc9_ = _loc11_.substr(0,_loc10_);
                     _loc3_ = _loc11_.substr(_loc10_ + 1,_loc11_.length);
                  }
                  else
                  {
                     _loc9_ = _loc11_;
                  }
                  _waitListPopup.content["p" + (_loc2_ - 1)].nameBar.firstName_txt.text = _loc9_;
                  if(_loc3_)
                  {
                     _waitListPopup.content["p" + (_loc2_ - 1)].nameBar.lastName_txt.text = _loc3_;
                  }
               }
               else
               {
                  _waitListPopup.content["p" + (_loc2_ - 1)].char.gotoAndPlay("waiting");
                  LocalizationManager.translateId(_waitListPopup.content["p" + (_loc2_ - 1)].nameBar.firstName_txt,11101);
                  _waitListPopup.content["p" + (_loc2_ - 1)].nameBar.lastName_txt.text = "";
               }
               _loc2_++;
            }
            _loc7_ = _waitListPopup.content["startBtn"];
            if(_waitIds.length >= _minReqPlayers)
            {
               if(!_loc7_.hasEventListener("mouseDown"))
               {
                  _loc7_.addEventListener("mouseDown",startNowHandler,false,0,true);
               }
               _loc7_.visible = true;
            }
            else
            {
               _loc7_.visible = false;
            }
            if(!_waitListPopup.visible)
            {
               _waitListPopup.open();
            }
            waitListUpdate();
         }
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
            _loc2_ = new SBMessage(_parentLayer,GETDEFINITIONBYNAME("ConfirmSkin"),LocalizationManager.translateIdOnly(11131));
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
         var _loc5_:String = null;
         var _loc2_:int = 0;
         var _loc4_:int = int(param1[2]);
         var _loc3_:int = int(param1[3]);
         if(_loc3_ == 0)
         {
            _loc5_ = param1[4];
            _loc2_ = int(param1[5]);
            readySelfForPvpGame({"typeDefId":_loc4_},_loc5_,true);
            displayPVPReceivedRequestPopup(minigameInfoCache.getMinigameInfo(_pvpGameDefId).gameCardMediaId,_loc2_ > 0 ? _loc5_ : LocalizationManager.translateIdOnly(11098),MinigameManager.getGameName(_pvpGameDefId));
         }
         else if(_loc3_ == 1)
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
               readySelfForPvpGame({"typeDefId":_loc4_},_pvpUserName,false);
            }
         }
      }
      
      public static function leaderBoardResponse(param1:Array) : void
      {
         var _loc3_:Object = null;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = int(param1[2]);
         if(_loc5_ != -1)
         {
            _loc3_ = {};
            _loc3_._cacheTime = getTimer();
            _loc3_._allTime = [];
            _loc3_._thisWeek = [];
            _loc3_._buddy = [];
            _loc4_ = 3;
            _loc6_ = int(param1[_loc4_++]);
            _loc2_ = 0;
            while(_loc6_ > 0)
            {
               _loc3_._allTime[_loc2_] = {};
               _loc3_._allTime[_loc2_]._name = param1[_loc4_++];
               _loc3_._allTime[_loc2_++]._score = param1[_loc4_++];
               _loc6_--;
            }
            _loc6_ = int(param1[_loc4_++]);
            _loc2_ = 0;
            while(_loc6_ > 0)
            {
               _loc3_._thisWeek[_loc2_] = {};
               _loc3_._thisWeek[_loc2_]._name = param1[_loc4_++];
               _loc3_._thisWeek[_loc2_++]._score = param1[_loc4_++];
               _loc6_--;
            }
            _loc6_ = int(param1[_loc4_++]);
            _loc2_ = 0;
            while(_loc6_ > 0)
            {
               _loc3_._buddy[_loc2_] = {};
               _loc3_._buddy[_loc2_]._name = param1[_loc4_++];
               _loc3_._buddy[_loc2_++]._score = param1[_loc4_++];
               _loc6_--;
            }
            _leaderBoardCache[_loc5_] = _loc3_;
            if(_joinGameObj != null && _gameCardPopup != null && _joinGameObj.typeDefId == _loc5_)
            {
               _gameCardPopup.onLeaderBoardSelected();
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
               return LocalizationManager.translateIdOnly(_loc2_.titleStrId);
            }
         }
         return "";
      }
      
      public static function getGameNameId(param1:int) : int
      {
         var _loc2_:MinigameInfo = null;
         if(minigameInfoCache)
         {
            _loc2_ = minigameInfoCache.getMinigameInfo(param1);
            if(_loc2_)
            {
               return _loc2_.titleStrId;
            }
         }
         return -1;
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
            return LocalizationManager.translatePetName(PetManager.myActivePet.name);
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
               _loc2_ = {};
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
               _loc3_ = {};
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
         var _loc4_:Number = (param1.minigameID + 49) * 3 + (_petMasterySerialNumber + 83) * 5;
         var _loc3_:Number = (_petMasterySerialNumber + _userId + param1.amount) * 3 + param1.amount * 3;
         _petMasterySerialNumber = -1;
         gMainFrame.server.setXtObject_Str("ma",[_loc2_,_loc4_,_loc3_]);
      }
      
      private static function sendGemAward(param1:Object) : void
      {
         var _loc3_:Number = (param1.amount + 29) * 7 + (_userId + 99) * 3 + (_gemSerialNumber + 49) * 5;
         var _loc4_:Number = (param1.minigameID + 49) * 3 + (_gemSerialNumber + 83) * 5;
         var _loc2_:Number = (_gemSerialNumber + _userId + param1.amount) * 3 + param1.amount * 3;
         _gemSerialNumber = -1;
         gMainFrame.server.setXtObject_Str("mg",[_loc3_,_loc4_,_loc2_]);
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
      
      public static function sendChatMsg(param1:MouseEvent, param2:String = "") : void
      {
         var _loc4_:Object = null;
         var _loc3_:String = null;
         var _loc6_:String = param2 == "" ? GuiManager.mainHud.chatBar.text01_chat.text : param2;
         _loc6_ = _loc6_.split("\r").join("");
         _loc6_ = _loc6_.split(gMainFrame.server.rawProtocolSeparator).join("");
         _loc6_ = StringUtil.trim(_loc6_);
         if(_loc6_.length <= 0)
         {
            return;
         }
         var _loc5_:Object = EmoticonUtility.matchEmoteString(_loc6_);
         if(_loc5_.status)
         {
            _loc4_ = _minigameRef;
            _loc3_ = SafeChatManager.safeChatCodeForString(_loc6_,4);
            if(_loc3_)
            {
               _loc4_._messageServer(["cm",_loc3_,1],true);
               _loc4_.addAvatarMessageForMyself(_loc6_,0);
               GuiManager.safeChatBtnDownHandler(null);
            }
            else
            {
               _loc4_.addAvatarMessageForMyself("...",0);
               _loc4_._messageServer(["cm",_loc6_,gMainFrame.userInfo.sgChatType == 1 ? 0 : 9],true);
            }
            return;
         }
         GuiManager.chatHist.resetTreeSearch();
         GuiManager.chatHist.chatMsgText.text = "";
         gMainFrame.stage.focus = GuiManager.chatHist.chatMsgText;
      }
      
      public static function sendSafeChatMsg(param1:String, param2:String) : void
      {
         sendChatMsg(null,param1);
      }
      
      public static function sendEmoteMsg(param1:Sprite) : void
      {
         var _loc2_:Object = _minigameRef;
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         _loc2_.setAvatarEmote(param1);
         if(!EmoticonUtility.getEmoteString(param1))
         {
            throw new Error("setAvatarEmote: sent invalid emote sprite?!");
         }
         _loc2_._messageServer(["cm",EmoticonUtility.idForEmote(param1) + UserCommXtCommManager.RAW_STR + 2],true);
      }
      
      public static function emoteForId(param1:int) : Sprite
      {
         return EmoticonUtility.emoteForId(param1);
      }
      
      public static function stringForId(param1:int) : String
      {
         return EmoticonUtility.stringForId(param1);
      }
      
      public static function playAnimFromActionString(param1:String, param2:int) : void
      {
         var _loc3_:Object = _minigameRef;
         for each(var _loc4_:Object in AvatarWorldView._actionLookup)
         {
            if(_loc4_.name == param1)
            {
               _loc3_.playAnim(_loc4_.land,param2);
               break;
            }
         }
      }
      
      public static function sendActionMsg(param1:Sprite) : void
      {
         var _loc4_:Object = _minigameRef;
         if(gMainFrame.clientInfo.invisMode)
         {
            return;
         }
         var _loc3_:String = GuiManager.actionMgr.getActionString(param1);
         for each(var _loc5_:Object in AvatarWorldView._actionLookup)
         {
            if(_loc5_.name == _loc3_)
            {
               _loc4_.playAnim(_loc5_.land);
               break;
            }
         }
         if(!GuiManager.actionMgr.getActionString(param1))
         {
            throw new Error("setAvatarAction: sent invalid action sprite?!");
         }
         var _loc2_:int = 0;
         _loc4_._messageServer(["cm",GuiManager.actionMgr.getActionString(param1) + UserCommXtCommManager.RAW_STR + 3 + UserCommXtCommManager.RAW_STR + _loc2_],true);
      }
      
      public static function isMember(param1:int) : Boolean
      {
         return Utility.isMember(param1);
      }
   }
}

