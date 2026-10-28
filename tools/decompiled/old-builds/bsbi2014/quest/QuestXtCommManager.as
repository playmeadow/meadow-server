package quest
{
   import avatar.AvatarManager;
   import com.carlcalderon.arthropod.Debug;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import den.DenXtCommManager;
   import flash.utils.Dictionary;
   import gui.AdventureJoin;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class QuestXtCommManager
   {
      
      private static var _questCache:Array;
      
      private static var _questDefLookups:Array;
      
      private static var _scriptDefs:Object;
      
      private static var _wasRoomWeCameFromDen:Boolean;
      
      private static var _autoStartQuestOnNextWaitResponse:Boolean;
      
      public function QuestXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _questCache = new Array();
         _questDefLookups = new Array();
         _autoStartQuestOnNextWaitResponse = false;
      }
      
      public static function questAskComplete(actorName:String, actorState:int, askResult:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaskr",[actorName,actorState,askResult]);
      }
      
      public static function questMiniGameComplete(actorName:String, actorState:int, gameResult:int) : void
      {
         gMainFrame.server.setXtObject_Str("qmgc",[actorName,actorState,gameResult]);
      }
      
      public static function questActorAttacked(actorId:String, defId:int, inX:int, inY:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaa",[actorId,actorId == "" ? 1 : 0,defId,inX,inY]);
      }
      
      public static function questPhantomAttackDestructible(attackerId:String, actorId:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpad",[attackerId,actorId]);
      }
      
      public static function questPlayerHeal(defId:int, playerToHeal:int) : void
      {
         gMainFrame.server.setXtObject_Str("qph",[defId,playerToHeal]);
      }
      
      public static function questActorTriggered(actorId:String, status:int = 0) : void
      {
         DebugUtility.debugTrace("sending \'qat\' command with actorId: " + actorId,Debug.RED);
         gMainFrame.server.setXtObject_Str("qat",[actorId,status]);
      }
      
      public static function questPickUpItem(actorId:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpup",[actorId,AvatarManager.playerSfsUserId]);
      }
      
      public static function questActorTreasureTriggered(actorId:String, status:int = 0) : void
      {
         gMainFrame.server.setXtObject_Str("qatt",[actorId,status]);
      }
      
      public static function questActorUntriggered(actorId:String) : void
      {
         gMainFrame.server.setXtObject_Str("qaut",[actorId]);
      }
      
      public static function questActorPositionUpdate(actorId:String, inX:int, inY:int, velocity:int, seekType:int, inTargetX:int, inTargetY:int) : void
      {
         var isLocal:Boolean = actorId.substring(0,3) == "_l_";
         if(!isLocal && QuestManager.livePlayerCount() > 1)
         {
            gMainFrame.server.setXtObject_Str("qau",[actorId,inX,inY,velocity,seekType,inTargetX,inTargetY]);
         }
      }
      
      public static function questActorSeek(actorId:String, requestSeek:int) : void
      {
         var data:Array = null;
         var isLocal:Boolean = actorId.substring(0,3) == "_l_";
         if(!isLocal)
         {
            gMainFrame.server.setXtObject_Str("qas",[actorId,requestSeek]);
         }
         else
         {
            data = new Array();
            data[0] = 0;
            data[1] = 0;
            data[2] = actorId;
            data[3] = requestSeek;
            data[4] = AvatarManager.playerSfsUserId;
            QuestManager.handleQuestActorRequestSeekResponse(data);
         }
      }
      
      public static function questBeamZap(actorId:String, inPlayerSfsId:int) : void
      {
         gMainFrame.server.setXtObject_Str("qbzap",[actorId,inPlayerSfsId]);
      }
      
      public static function questPhantomZap(actorId:String, inPlayerSfsId:int, inX:int, inY:int) : void
      {
         gMainFrame.server.setXtObject_Str("qpzap",[actorId,inPlayerSfsId,inX,inY]);
      }
      
      public static function questDropOrb(actorId:String, inPlayerSfsId:int, inAmount:int) : void
      {
         gMainFrame.server.setXtObject_Str("qdroporb",[actorId,inPlayerSfsId,inAmount]);
      }
      
      public static function questFullRoomMinigameComplete(roomName:String, inGameResult:int) : void
      {
         gMainFrame.server.setXtObject_Str("qfrmgdone",[roomName,inGameResult]);
      }
      
      public static function sendQuestJoinPrivate(questCreatorName:String) : void
      {
         if(Boolean(gMainFrame.server.getCurrentRoom()))
         {
            DarkenManager.showLoadingSpiral(true);
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjp",[gMainFrame.server.getCurrentRoomName(),questCreatorName]);
         }
      }
      
      public static function sendQuestJoinBuddy(buddyName:String) : void
      {
         var currRoomName:String = null;
         if(Boolean(gMainFrame.server.getCurrentRoom()))
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            currRoomName = gMainFrame.server.getCurrentRoomName();
            if(currRoomName.indexOf("den") != -1)
            {
               _wasRoomWeCameFromDen = true;
            }
            else
            {
               _wasRoomWeCameFromDen = false;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjf",[gMainFrame.server.getCurrentRoomName(),buddyName]);
         }
      }
      
      public static function sendQuestCreateJoinPublic(questDefId:int, questDifficultyLevel:int = 0, autoStart:Boolean = false) : void
      {
         var currRoomName:String = null;
         if(Boolean(gMainFrame.server.getCurrentRoom()))
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            currRoomName = gMainFrame.server.getCurrentRoomName();
            if(currRoomName.indexOf("den") != -1)
            {
               _wasRoomWeCameFromDen = true;
            }
            else
            {
               _wasRoomWeCameFromDen = false;
            }
            if(autoStart)
            {
               _autoStartQuestOnNextWaitResponse = true;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qj",[gMainFrame.server.getCurrentRoomName(),questDefId,questDifficultyLevel,0]);
         }
      }
      
      public static function sendQuestCreateJoinPublicNoCurrentRoom(questDefId:int, questDifficultyLevel:int = 0) : void
      {
         if(RoomXtCommManager._loadingNewRoom)
         {
            DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
            return;
         }
         AvatarManager.joiningNewRoom = true;
         RoomXtCommManager._loadingNewRoom = true;
         RoomManagerWorld.instance.forceStopMovement();
         gMainFrame.server.setXtObject_Str("qj",["",questDefId,questDifficultyLevel,0]);
      }
      
      public static function sendQuestCreatePrivate(questDefId:int, questDifficultyLevel:int = 0, autoStart:Boolean = false) : void
      {
         if(Boolean(gMainFrame.server.getCurrentRoom()))
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            if(autoStart)
            {
               _autoStartQuestOnNextWaitResponse = true;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjc",[gMainFrame.server.getCurrentRoomName(),questDefId,questDifficultyLevel]);
            GuiManager.grayOutHudItemsForPrivateLobby(true);
         }
      }
      
      public static function sendQuestPrivateKick(playerToKick:String) : void
      {
         gMainFrame.server.setXtObject_Str("qjk",[playerToKick]);
      }
      
      public static function sendQuestJoinCancel() : void
      {
         gMainFrame.server.setXtObject_Str("qjx",[]);
         GuiManager.setSwapBtnGray(false);
      }
      
      public static function sendQuestStartRequest() : void
      {
         if(Boolean(gMainFrame.server.getCurrentRoom()))
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestStartRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            AvatarManager.resetCustomAdventureState();
            gMainFrame.server.setXtObject_Str("qs",[gMainFrame.server.getCurrentRoomName()]);
         }
      }
      
      public static function sendQuestProjectileLaunch(inMediaID:int, inX:int, inY:int, inActorID:String, inAvSfsID:int, inColor:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qp",[inMediaID,inX,inY,inActorID,inAvSfsID,inColor]);
      }
      
      public static function sendQuestSwipe(inMediaID:int, inX:int, inY:int, inActorID:String, inAvSfsID:int, inColors:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qm",[inMediaID,inX,inY,inActorID,inAvSfsID,inColors]);
      }
      
      public static function sendQuestExit(exitType:String) : void
      {
         DenXtCommManager.denChangePending = _wasRoomWeCameFromDen;
         gMainFrame.server.setXtObject_Str("qx",[exitType]);
      }
      
      public static function sendAttackPlayer(inActorId:String, inPlayerSfsId:int, inWeaponItemDefId:int, inWeaponColor:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qap",[inActorId,inPlayerSfsId,inWeaponItemDefId,inWeaponColor]);
      }
      
      public static function sendQuestPlayerRequestRespawn(numGems:int, inX:int, inY:int) : void
      {
         gMainFrame.server.setXtObject_Str("qprr",[numGems,inX,inY]);
      }
      
      public static function sendPlantSeed(inSeedDef:int, inX:int, inY:int) : void
      {
         gMainFrame.server.setXtObject_Str("qps",[inSeedDef,inX,inY]);
      }
      
      public static function sendEatPhantom(inPlant:String, inPhantom:String, inX:int, inY:int) : void
      {
         gMainFrame.server.setXtObject_Str("qep",[inPlant,inPhantom,inX,inY]);
      }
      
      public static function sendPlantAte(inPlant:String, inPhantom:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpa",[inPlant,inPhantom]);
      }
      
      public static function sendPickGiftResult(pickedGift:int, consolationPrize:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str("qpgift",[pickedGift,consolationPrize ? "1" : "0"]);
      }
      
      public static function sendQuestCloneQuest() : void
      {
         gMainFrame.server.setXtObject_Str("qcq",[]);
      }
      
      public static function sendQuestDropItem(inX:int, inY:int, pickup:String) : void
      {
         gMainFrame.server.setXtObject_Str("qdroppup",[inX,inY,pickup,AvatarManager.playerSfsUserId]);
      }
      
      public static function sendQuestMovedItemsRequest() : void
      {
         gMainFrame.server.setXtObject_Str("qmi",[]);
      }
      
      public static function sendPlaySwfComplete() : void
      {
         gMainFrame.server.setXtObject_Str("qplayswf",[]);
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "qap":
               QuestManager.handleAttackPlayer(data);
               break;
            case "qau":
               QuestManager.handleQuestActorPositionUpdateResponse(data);
               break;
            case "qahs":
               QuestManager.handleActorHealthStatus(data);
               break;
            case "qas":
               QuestManager.handleQuestActorRequestSeekResponse(data);
               break;
            case "qjp":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(data[2] != 0)
               {
                  GuiManager.setSwapBtnGray(true);
                  QuestManager.handleQuestJoinResponse(data,AdventureJoin.CUSTOM_WAITING_TYPE,data[5]);
               }
               else if(data[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(data[3] == "FULL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14817));
               }
               else if(data[3] == "NLAND")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(data[3] == "NOCEAN")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
               }
               else if(data[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
               }
               else if(data[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
               }
               else if(data[3] == "NB")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14819));
               }
               else if(data[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,data[4]));
               }
               else if(data[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(data[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,data[4]));
               }
               else if(data[3] == "NQ")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14822));
               }
               else if(data[3] == "NP")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               break;
            case "qjc":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(data[2] != 0)
               {
                  GuiManager.closeWorldMapIfOpen();
                  QuestManager.handleQuestJoinResponse(data,AdventureJoin.CUSTOM_SETTINGS_TYPE);
               }
               else
               {
                  if(data[3] == "NV")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  }
                  else if(data[3] == "NLAND")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                  }
                  else if(data[3] == "NOCEAN")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                  }
                  else if(data[3] == "NAIR")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                  }
                  else if(data[3] == "NM")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
                  }
                  else if(data[3] == "NL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,data[4]));
                  }
                  else if(data[3] == "NAIL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
                  }
                  else if(data[3] == "NDL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,data[4]));
                  }
                  else if(data[3] == "NP")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  }
                  else
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  }
                  GuiManager.grayOutHudItemsForPrivateLobby(false);
               }
               break;
            case "qj":
               GuiManager.setSwapBtnGray(true);
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(data[2] != 0)
               {
                  QuestManager.handleQuestJoinResponse(data,AdventureJoin.NORMAL_TYPE,data[5]);
               }
               else if(data[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(data[3] == "NLAND")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(data[3] == "NOCEAN")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
               }
               else if(data[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
               }
               else if(data[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14823));
               }
               else if(data[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,data[4]));
               }
               else if(data[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(data[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,data[4]));
               }
               else if(data[3] == "NDLERR")
               {
                  new SBOkPopup(GuiManager.guiLayer,"Total user var bits exceeded - increase support for additional levels!");
               }
               else if(data[3] == "NP")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               break;
            case "qjx":
               GuiManager.setSwapBtnGray(false);
               QuestManager.handleQuestJoinCancelResponse(data);
               break;
            case "qw":
               QuestManager.handleQuestWaitResponse(data);
               if(_autoStartQuestOnNextWaitResponse)
               {
                  _autoStartQuestOnNextWaitResponse = false;
                  sendQuestStartRequest();
               }
               break;
            case "qs":
               GuiManager.setSwapBtnGray(false);
               questStartResponse(data);
               QuestManager.handleQuestStartResponse(data);
               break;
            case "qat":
               questActorTriggeredResponse(data);
               break;
            case "qcmd":
               QuestManager.handleCommand(data,false);
               break;
            case "qcmdVT":
               QuestManager.handleCommand(data,true);
               break;
            case "qp":
               QuestManager.handleLaunchProjectile(data);
               break;
            case "qm":
               QuestManager.handleSwipe(data);
               break;
            case "quxp":
               QuestManager.handleXpUpdate(data);
               break;
            case "quhp":
               QuestManager.handleHealthUpdate(data,false);
               break;
            case "qrspn":
               QuestManager.handleHealthUpdate(data,true);
               break;
            case "qad":
               QuestManager.handleActorDeath(data);
               break;
            case "qx":
               break;
            case "qxt":
               QuestManager.handleExitByType(data);
               break;
            case "qspn":
               QuestManager.handleSpawn(data);
               break;
            case "qatt":
               QuestManager.handleQuestActorTriggerTreasure(data);
               break;
            case "qusu":
               QuestManager.handleStatsUpdate(data);
               break;
            case "qulu":
               QuestManager.handleLevelUp(data);
               break;
            case "qporbs":
               QuestManager.handleOrbsUpdate(data);
               break;
            case "qpup":
               QuestManager.handlePickUpItem(data);
               break;
            case "qsnd":
               QuestManager.playSound(data[2],null,data[3] == "1");
               break;
            case "qmusic":
               QuestManager.playMusic(data[2]);
               break;
            case "qswfs":
               QuestManager.handleSetSwfState(data);
               break;
            case "qmlib":
               QuestManager.handleLoadMediaLib(data);
               break;
            case "qprr":
               QuestManager.handleQuestPlayerRequestRespawn(data);
               break;
            case "qpd":
               QuestManager.handleQuestPlayerDead(data);
               break;
            case "qsp":
               QuestManager.handleQuestSetPath(data);
               break;
            case "qps":
               QuestManager.handlePlantSeed(data);
               break;
            case "qpa":
               QuestManager.handlePlantAte(data[2],data[3]);
               break;
            case "qbzap":
               QuestManager.handleBeamZap(data);
               break;
            case "qpzap":
               QuestManager.handlePhantomZap(data);
               break;
            case "qdroporb":
               QuestManager.handleDropOrb(data);
               break;
            case "qpgift":
               QuestManager.handlePickGift(data);
               break;
            case "qplq":
               QuestManager.handlePlayerLeftQuest(data);
               break;
            case "qrc":
               QuestManager.handleQuestRoomChange(data);
               break;
            case "qviu":
               QuestManager.handleQuestVolumeInteractionUpdate(data);
               break;
            case "qtorch":
               QuestManager.handleQuestTorch(data);
               break;
            case "qgi":
               questPickUpItem(data[2]);
               break;
            case "qsndpk":
               QuestManager.loadQuestSfx(data[2]);
               break;
            case "qicon":
               QuestManager.handleActorIcon(data[2],data[3]);
               break;
            case "qseed":
               QuestManager.handleGiveSeed(data[2],data[3],data[4]);
               break;
            case "qmi":
               QuestManager.handleMovedItemList(data as Array);
               break;
            case "qepr":
               QuestManager.handlePlantEatRecoil(data[2]);
               break;
            case "qplayswf":
               QuestManager.handlePlaySwf(data[2]);
               break;
            case "qshake":
               QuestManager.handleShake(data[2]);
               break;
            case "qaward":
               QuestManager.handleAward(data[2],data[3]);
               break;
            case "qposturi":
               QuestManager.handlePostUri(data[2]);
               break;
            case "qpreloadswf":
               QuestManager.handlPreloadSwf(data[2]);
               break;
            case "qfade":
               QuestManager.handleFade(data[2] == 1);
               break;
            case "qavsw":
               QuestManager.handleAvSwitch(data);
         }
      }
      
      private static function questStartResponse(data:Object) : void
      {
         var timeStamp:String = null;
         var actorDictionary:Dictionary = null;
         var actorData:Object = null;
         var actorID:String = null;
         var actorType:int = 0;
         var actorDefId:int = 0;
         var actorDefName:String = null;
         var actorState:int = 0;
         var actorVisible:Boolean = false;
         var actorRequireClick:Boolean = false;
         var actorPath:String = null;
         var actorSwfState:String = null;
         var i:int = 2;
         var scriptDefId:int = int(data[i++]);
         var playerCount:int = int(data[i++]);
         var actorCount:int = int(data[i++]);
         if(actorCount >= 0)
         {
            timeStamp = data[i++];
            for(actorDictionary = new Dictionary(); actorCount > 0; )
            {
               actorData = new Object();
               actorID = data[i++];
               actorType = int(data[i++]);
               actorDefId = 0;
               actorDefName = null;
               if(actorType == QuestActor.QUEST_ACTOR_TYPE_SPEAKER)
               {
                  actorDefName = data[i++];
               }
               else
               {
                  actorDefId = int(data[i++]);
               }
               actorState = int(data[i++]);
               actorVisible = data[i++] == 1;
               actorRequireClick = data[i++] == 1;
               actorPath = data[i++];
               actorSwfState = data[i++];
               actorData.visible = actorVisible;
               actorData.requireClick = actorRequireClick;
               actorData.defId = actorDefId;
               actorData.defName = actorDefName;
               actorData.type = actorType;
               actorData.state = actorState;
               actorData.pathName = actorPath != "" ? actorPath : null;
               QuestManager.initInitialActorStatus(actorData,null);
               actorData.pendingSwfStateName = actorSwfState;
               actorDictionary[actorID] = actorData;
               actorCount--;
            }
            QuestManager.setActorDictionary(actorDictionary,timeStamp);
            QuestManager.hasJustJoinedQuest = true;
         }
         else
         {
            AvatarManager.joiningNewRoom = false;
            RoomXtCommManager._loadingNewRoom = false;
         }
      }
      
      private static function questActorTriggeredResponse(data:Object) : void
      {
      }
      
      public static function questNPCDefResponse(dfdh:DefPacksDefHelper) : void
      {
         var npcDef:Object = null;
         var data:Object = null;
         var newDef:Object = dfdh.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NPC] = null;
         var npcDefs:Object = new Object();
         for each(data in dfdh.def)
         {
            npcDef = {
               "avatarRefId":int(data.avatarRefId),
               "backColor":Number(data.backColor),
               "backItemRefId":int(data.backItemRefId),
               "eyesColor":Number(data.eyesColor),
               "eyesItemRefId":int(data.eyesItemRefId),
               "legColor":Number(data.legColor),
               "legItemRefId":int(data.legItemRefId),
               "headColor":int(data.headColor),
               "headMediaRefId":uint(data.headMediaRefId),
               "headItemRefId":int(data.headItemRefId),
               "defId":int(data.id),
               "mediaRefId":int(data.mediaRefId),
               "neckColor":Number(data.neckColor),
               "neckItemRefId":int(data.neckItemRefId),
               "patternColor":Number(data.patternColor),
               "patternItemRefId":int(data.patternItemRefId),
               "tailColor":Number(data.tailColor),
               "tailItemRefId":int(data.tailItemRefId),
               "titleStrId":int(data.titleStrId),
               "type":int(data.type),
               "baseColor":int(data.baseColor),
               "hps":int(data.hps),
               "defense":int(data.defense),
               "xpValue":int(data.xpValue),
               "iconMediaRefId":int(data.iconMediaRefId),
               "level":int(data.level),
               "attackable":int(data.attackable),
               "damageTouch":int(data.damageTouch)
            };
            npcDefs[npcDef.defId] = npcDef;
         }
         QuestManager.npcDefs = npcDefs;
      }
      
      public static function scriptResponse(dfdh:DefPacksDefHelper) : void
      {
         var scriptDef:Object = null;
         var data:Object = null;
         var newDef:Object = dfdh.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_SCRIPT] = null;
         var scriptDefs:Object = new Object();
         for each(data in newDef)
         {
            scriptDef = {
               "defId":int(data.id),
               "avatarLimit":int(data.avatarLimit),
               "avatarMin":int(data.avatarMin),
               "avatarType":int(data.avatarType),
               "descStrId":int(data.descStrId),
               "difficulty":int(data.difficulty),
               "levelMin":int(data.levelMin),
               "mediaRefId":int(data.mediaRefId),
               "time":int(data.time),
               "titleStrId":int(data.titleStrId),
               "hudType":int(data.hudType),
               "bannerMediaRefId":int(data.bannerMediaRefId),
               "membersOnly":(data.membersOnly == "1" ? true : false),
               "playAsPet":(data.playAsPet == "1" ? true : false)
            };
            scriptDefs[scriptDef.defId] = scriptDef;
         }
         _scriptDefs = scriptDefs;
      }
      
      public static function roomJoined(inRoomName:String) : void
      {
         QuestManager.questRoomJoined(inRoomName.indexOf("quest_") == 0);
      }
      
      public static function getScriptDef(id:int) : Object
      {
         return _scriptDefs[id];
      }
      
      private static function searchQuestCache(defId:int) : Object
      {
         return _questCache[defId];
      }
   }
}

