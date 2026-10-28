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
      
      public static function questAskComplete(param1:String, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaskr",[param1,param2,param3]);
      }
      
      public static function questMiniGameComplete(param1:String, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qmgc",[param1,param2,param3]);
      }
      
      public static function questActorAttacked(param1:String, param2:int, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaa",[param1,param1 == "" ? 1 : 0,param2,param3,param4]);
      }
      
      public static function questPhantomAttackDestructible(param1:String, param2:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpad",[param1,param2]);
      }
      
      public static function questPlayerHeal(param1:int, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qph",[param1,param2]);
      }
      
      public static function questActorTriggered(param1:String, param2:int = 0) : void
      {
         DebugUtility.debugTrace("sending \'qat\' command with actorId: " + param1,Debug.RED);
         gMainFrame.server.setXtObject_Str("qat",[param1,param2]);
      }
      
      public static function questPickUpItem(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpup",[param1,AvatarManager.playerSfsUserId]);
      }
      
      public static function questActorTreasureTriggered(param1:String, param2:int = 0) : void
      {
         gMainFrame.server.setXtObject_Str("qatt",[param1,param2]);
      }
      
      public static function questActorUntriggered(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("qaut",[param1]);
      }
      
      public static function questActorPositionUpdate(param1:String, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int) : void
      {
         if(QuestManager._questStartingPlayerCount > 1)
         {
            gMainFrame.server.setXtObject_Str("qau",[param1,param2,param3,param4,param5,param6,param7]);
         }
      }
      
      public static function questActorSeek(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qas",[param1,param2]);
      }
      
      public static function questBeamZap(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qbzap",[param1,param2]);
      }
      
      public static function questPhantomZap(param1:String, param2:int, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qpzap",[param1,param2,param3,param4]);
      }
      
      public static function questFullRoomMinigameComplete(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qfrmgdone",[param1,param2]);
      }
      
      public static function sendQuestJoinPrivate(param1:String) : void
      {
         if(gMainFrame.server.getCurrentRoom())
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
            gMainFrame.server.setXtObject_Str("qjp",[gMainFrame.server.getCurrentRoomName(),param1]);
         }
      }
      
      public static function sendQuestCreateJoinPublic(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         var _loc4_:String = null;
         if(gMainFrame.server.getCurrentRoom())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            _loc4_ = gMainFrame.server.getCurrentRoomName();
            if(_loc4_.indexOf("den") != -1)
            {
               _wasRoomWeCameFromDen = true;
            }
            else
            {
               _wasRoomWeCameFromDen = false;
            }
            if(param3)
            {
               _autoStartQuestOnNextWaitResponse = true;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qj",[gMainFrame.server.getCurrentRoomName(),param1,param2,0]);
         }
      }
      
      public static function sendQuestCreateJoinPublicNoCurrentRoom(param1:int, param2:int = 0) : void
      {
         if(RoomXtCommManager._loadingNewRoom)
         {
            DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
            return;
         }
         AvatarManager.joiningNewRoom = true;
         RoomXtCommManager._loadingNewRoom = true;
         RoomManagerWorld.instance.forceStopMovement();
         gMainFrame.server.setXtObject_Str("qj",["",param1,param2,0]);
      }
      
      public static function sendQuestCreatePrivate(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         if(gMainFrame.server.getCurrentRoom())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            if(param3)
            {
               _autoStartQuestOnNextWaitResponse = true;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjc",[gMainFrame.server.getCurrentRoomName(),param1,param2]);
         }
      }
      
      public static function sendQuestPrivateKick(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("qjk",[param1]);
      }
      
      public static function sendQuestJoinCancel() : void
      {
         gMainFrame.server.setXtObject_Str("qjx",[]);
         GuiManager.setSwapBtnGray(false);
      }
      
      public static function sendQuestStartRequest() : void
      {
         if(gMainFrame.server.getCurrentRoom())
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
      
      public static function sendQuestProjectileLaunch(param1:int, param2:int, param3:int, param4:String, param5:int, param6:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qp",[param1,param2,param3,param4,param5,param6]);
      }
      
      public static function sendQuestSwipe(param1:int, param2:int, param3:int, param4:String, param5:int, param6:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qm",[param1,param2,param3,param4,param5,param6]);
      }
      
      public static function sendQuestExit(param1:String) : void
      {
         DenXtCommManager.denChangePending = _wasRoomWeCameFromDen;
         gMainFrame.server.setXtObject_Str("qx",[param1]);
      }
      
      public static function sendAttackPlayer(param1:String, param2:int, param3:int, param4:uint) : void
      {
         gMainFrame.server.setXtObject_Str("qap",[param1,param2,param3,param4]);
      }
      
      public static function sendQuestPlayerRequestRespawn(param1:int, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qprr",[param1,param2,param3]);
      }
      
      public static function sendPlantSeed(param1:int, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qps",[param1,param2,param3]);
      }
      
      public static function sendEatPhantom(param1:String, param2:String, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qep",[param1,param2,param3,param4]);
      }
      
      public static function sendPlantAte(param1:String, param2:String) : void
      {
         gMainFrame.server.setXtObject_Str("qpa",[param1,param2]);
      }
      
      public static function sendPickGiftResult(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("qpgift",[param1]);
      }
      
      public static function sendQuestCloneQuest() : void
      {
         gMainFrame.server.setXtObject_Str("qcq",[]);
      }
      
      public static function sendQuestDropItem(param1:int, param2:int, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("qdroppup",[param1,param2,param3,AvatarManager.playerSfsUserId]);
      }
      
      public static function sendQuestMovedItemsRequest() : void
      {
         gMainFrame.server.setXtObject_Str("qmi",[]);
      }
      
      public static function sendPlaySwfComplete() : void
      {
         gMainFrame.server.setXtObject_Str("qplayswf",[]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "qap":
               QuestManager.handleAttackPlayer(_loc2_);
               break;
            case "qau":
               QuestManager.handleQuestActorPositionUpdateResponse(_loc2_);
               break;
            case "qahs":
               QuestManager.handleActorHealthStatus(_loc2_);
               break;
            case "qas":
               QuestManager.handleQuestActorRequestSeekResponse(_loc2_);
               break;
            case "qjp":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc2_[2] != 0)
               {
                  GuiManager.setSwapBtnGray(true);
                  QuestManager.handleQuestJoinResponse(_loc2_,AdventureJoin.CUSTOM_WAITING_TYPE,_loc2_[5]);
               }
               else if(_loc2_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(_loc2_[3] == "FULL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14817));
               }
               else if(_loc2_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(_loc2_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
               }
               else if(_loc2_[3] == "NB")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14819));
               }
               else if(_loc2_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc2_[4]));
               }
               else if(_loc2_[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(_loc2_[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc2_[4]));
               }
               else if(_loc2_[3] == "NQ")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14822));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               break;
            case "qjc":
               GuiManager.setSwapBtnGray(true);
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc2_[2] != 0)
               {
                  GuiManager.closeWorldMapIfOpen();
                  QuestManager.handleQuestJoinResponse(_loc2_,AdventureJoin.CUSTOM_SETTINGS_TYPE);
               }
               else if(_loc2_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(_loc2_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(_loc2_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
               }
               else if(_loc2_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc2_[4]));
               }
               else if(_loc2_[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(_loc2_[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc2_[4]));
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               break;
            case "qj":
               GuiManager.setSwapBtnGray(true);
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc2_[2] != 0)
               {
                  QuestManager.handleQuestJoinResponse(_loc2_,AdventureJoin.NORMAL_TYPE,_loc2_[5]);
               }
               else if(_loc2_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(_loc2_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(_loc2_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14823));
               }
               else if(_loc2_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc2_[4]));
               }
               else if(_loc2_[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(_loc2_[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc2_[4]));
               }
               else if(_loc2_[3] == "NDLERR")
               {
                  new SBOkPopup(GuiManager.guiLayer,"Total user var bits exceeded - increase support for additional levels!");
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               break;
            case "qjx":
               GuiManager.setSwapBtnGray(false);
               QuestManager.handleQuestJoinCancelResponse(_loc2_);
               break;
            case "qw":
               QuestManager.handleQuestWaitResponse(_loc2_);
               if(_autoStartQuestOnNextWaitResponse)
               {
                  _autoStartQuestOnNextWaitResponse = false;
                  sendQuestStartRequest();
               }
               break;
            case "qs":
               GuiManager.setSwapBtnGray(false);
               questStartResponse(_loc2_);
               QuestManager.handleQuestStartResponse(_loc2_);
               break;
            case "qat":
               questActorTriggeredResponse(_loc2_);
               break;
            case "qcmd":
               QuestManager.handleCommand(_loc2_,false);
               break;
            case "qcmddbg":
               QuestManager.handleCommand(_loc2_,true);
               break;
            case "qp":
               QuestManager.handleLaunchProjectile(_loc2_);
               break;
            case "qm":
               QuestManager.handleSwipe(_loc2_);
               break;
            case "quxp":
               QuestManager.handleXpUpdate(_loc2_);
               break;
            case "quhp":
               QuestManager.handleHealthUpdate(_loc2_,false);
               break;
            case "qrspn":
               QuestManager.handleHealthUpdate(_loc2_,true);
               break;
            case "qad":
               QuestManager.handleActorDeath(_loc2_);
               break;
            case "qx":
               break;
            case "qxt":
               QuestManager.handleExitByType(_loc2_);
               break;
            case "qspn":
               QuestManager.handleSpawn(_loc2_);
               break;
            case "qatt":
               QuestManager.handleQuestActorTriggerTreasure(_loc2_);
               break;
            case "qusu":
               QuestManager.handleStatsUpdate(_loc2_);
               break;
            case "qulu":
               QuestManager.handleLevelUp(_loc2_);
               break;
            case "qpup":
               QuestManager.handlePickUpItem(_loc2_);
               break;
            case "qsnd":
               QuestManager.playSound(_loc2_[2],null,_loc2_[3] == "1");
               break;
            case "qmusic":
               QuestManager.playMusic(_loc2_[2]);
               break;
            case "qswfs":
               QuestManager.handleSetSwfState(_loc2_);
               break;
            case "qmlib":
               QuestManager.handleLoadMediaLib(_loc2_);
               break;
            case "qprr":
               QuestManager.handleQuestPlayerRequestRespawn(_loc2_);
               break;
            case "qpd":
               QuestManager.handleQuestPlayerDead(_loc2_);
               break;
            case "qsp":
               QuestManager.handleQuestSetPath(_loc2_);
               break;
            case "qps":
               QuestManager.handlePlantSeed(_loc2_);
               break;
            case "qpa":
               QuestManager.handlePlantAte(_loc2_[2],_loc2_[3]);
               break;
            case "qbzap":
               QuestManager.handleBeamZap(_loc2_);
               break;
            case "qpzap":
               QuestManager.handlePhantomZap(_loc2_);
               break;
            case "qpgift":
               QuestManager.handlePickGift(_loc2_);
               break;
            case "qplq":
               QuestManager.handlePlayerLeftQuest(_loc2_);
               break;
            case "qrc":
               QuestManager.handleQuestRoomChange(_loc2_);
               break;
            case "qviu":
               QuestManager.handleQuestVolumeInteractionUpdate(_loc2_);
               break;
            case "qtorch":
               QuestManager.handleQuestTorch(_loc2_);
               break;
            case "qgi":
               questPickUpItem(_loc2_[2]);
               break;
            case "qsndpk":
               QuestManager.loadQuestSfx(_loc2_[2]);
               break;
            case "qicon":
               QuestManager.handleActorIcon(_loc2_[2],_loc2_[3]);
               break;
            case "qseed":
               QuestManager.handleGiveSeed(_loc2_[2],_loc2_[3],_loc2_[4]);
               break;
            case "qmi":
               QuestManager.handleMovedItemList(_loc2_ as Array);
               break;
            case "qepr":
               QuestManager.handlePlantEatRecoil(_loc2_[2]);
               break;
            case "qplayswf":
               QuestManager.handlePlaySwf(_loc2_[2]);
               break;
            case "qshake":
               QuestManager.handleShake(_loc2_[2]);
               break;
            case "qaward":
               QuestManager.handleAward(_loc2_[2],_loc2_[3]);
               break;
            case "qposturi":
               QuestManager.handlePostUri(_loc2_[2]);
               break;
            case "qpreloadswf":
               QuestManager.handlPreloadSwf(_loc2_[2]);
               break;
            case "qfade":
               QuestManager.handleFade(_loc2_[2] == 1);
               break;
            case "qavsw":
               QuestManager.handleAvSwitch(_loc2_);
         }
      }
      
      private static function questStartResponse(param1:Object) : void
      {
         var _loc6_:String = null;
         var _loc7_:Dictionary = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:String = null;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc15_:Boolean = false;
         var _loc16_:String = null;
         var _loc17_:String = null;
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:* = int(param1[_loc2_++]);
         if(_loc5_ >= 0)
         {
            _loc6_ = param1[_loc2_++];
            _loc7_ = new Dictionary();
            while(_loc5_ > 0)
            {
               _loc8_ = new Object();
               _loc9_ = param1[_loc2_++];
               _loc10_ = int(param1[_loc2_++]);
               _loc11_ = 0;
               _loc12_ = null;
               if(_loc10_ == QuestActor.QUEST_ACTOR_TYPE_SPEAKER)
               {
                  _loc12_ = param1[_loc2_++];
               }
               else
               {
                  _loc11_ = int(param1[_loc2_++]);
               }
               _loc13_ = int(param1[_loc2_++]);
               _loc14_ = param1[_loc2_++] == 1;
               _loc15_ = param1[_loc2_++] == 1;
               _loc16_ = param1[_loc2_++];
               _loc17_ = param1[_loc2_++];
               _loc8_.visible = _loc14_;
               _loc8_.requireClick = _loc15_;
               _loc8_.defId = _loc11_;
               _loc8_.defName = _loc12_;
               _loc8_.type = _loc10_;
               _loc8_.state = _loc13_;
               _loc8_.pathName = _loc16_ != "" ? _loc16_ : null;
               QuestManager.initInitialActorStatus(_loc8_,null);
               _loc8_.pendingSwfStateName = _loc17_;
               _loc7_[_loc9_] = _loc8_;
               _loc5_--;
            }
            QuestManager.setActorDictionary(_loc7_,_loc6_);
            QuestManager.hasJustJoinedQuest = true;
         }
         else
         {
            AvatarManager.joiningNewRoom = false;
            RoomXtCommManager._loadingNewRoom = false;
         }
      }
      
      private static function questActorTriggeredResponse(param1:Object) : void
      {
      }
      
      public static function questNPCDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_NPC] = null;
         var _loc3_:Object = new Object();
         for each(_loc5_ in param1.def)
         {
            _loc4_ = {
               "avatarRefId":int(_loc5_.avatarRefId),
               "backColor":Number(_loc5_.backColor),
               "backItemRefId":int(_loc5_.backItemRefId),
               "eyesColor":Number(_loc5_.eyesColor),
               "eyesItemRefId":int(_loc5_.eyesItemRefId),
               "legColor":Number(_loc5_.legColor),
               "legItemRefId":int(_loc5_.legItemRefId),
               "headColor":int(_loc5_.headColor),
               "headMediaRefId":uint(_loc5_.headMediaRefId),
               "headItemRefId":int(_loc5_.headItemRefId),
               "defId":int(_loc5_.id),
               "mediaRefId":int(_loc5_.mediaRefId),
               "neckColor":Number(_loc5_.neckColor),
               "neckItemRefId":int(_loc5_.neckItemRefId),
               "patternColor":Number(_loc5_.patternColor),
               "patternItemRefId":int(_loc5_.patternItemRefId),
               "tailColor":Number(_loc5_.tailColor),
               "tailItemRefId":int(_loc5_.tailItemRefId),
               "titleStrId":int(_loc5_.titleStrId),
               "type":int(_loc5_.type),
               "baseColor":int(_loc5_.baseColor),
               "hps":int(_loc5_.hps),
               "defense":int(_loc5_.defense),
               "xpValue":int(_loc5_.xpValue),
               "iconMediaRefId":int(_loc5_.iconMediaRefId),
               "level":int(_loc5_.level),
               "attackable":int(_loc5_.attackable),
               "damageTouch":int(_loc5_.damageTouch)
            };
            _loc3_[_loc4_.defId] = _loc4_;
         }
         QuestManager.npcDefs = _loc3_;
      }
      
      public static function scriptResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_SCRIPT] = null;
         var _loc3_:Object = new Object();
         for each(_loc5_ in param1.def)
         {
            _loc4_ = {
               "defId":int(_loc5_.id),
               "avatarLimit":int(_loc5_.avatarLimit),
               "avatarMin":int(_loc5_.avatarMin),
               "descStrId":int(_loc5_.descStrId),
               "difficulty":int(_loc5_.difficulty),
               "levelMin":int(_loc5_.levelMin),
               "mediaRefId":int(_loc5_.mediaRefId),
               "time":int(_loc5_.time),
               "titleStrId":int(_loc5_.titleStrId),
               "hudType":int(_loc5_.hudType),
               "bannerMediaRefId":int(_loc5_.bannerMediaRefId),
               "membersOnly":(_loc5_.membersOnly == "1" ? true : false)
            };
            _loc3_[_loc4_.defId] = _loc4_;
         }
         _scriptDefs = _loc3_;
      }
      
      public static function roomJoined(param1:String) : void
      {
         QuestManager.questRoomJoined(param1.indexOf("quest_") == 0);
      }
      
      public static function getScriptDef(param1:int) : Object
      {
         return _scriptDefs[param1];
      }
      
      private static function searchQuestCache(param1:int) : Object
      {
         return _questCache[param1];
      }
   }
}

