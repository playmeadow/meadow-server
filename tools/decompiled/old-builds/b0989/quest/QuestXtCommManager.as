package quest
{
   import avatar.AvatarManager;
   import com.carlcalderon.arthropod.Debug;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import flash.utils.Dictionary;
   import gui.GuiManager;
   import loader.DefPacksDefHelper;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
   public class QuestXtCommManager
   {
      
      private static var _questCache:Array;
      
      private static var _questDefLookups:Array;
      
      private static var _scriptDefs:Object;
      
      public function QuestXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _questCache = new Array();
         _questDefLookups = new Array();
      }
      
      public static function questAskComplete(param1:String, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaskr",[param1,param2,param3]);
      }
      
      public static function questMiniGameComplete(param1:String, param2:int, param3:int) : void
      {
         gMainFrame.server.setXtObject_Str("qmgc",[param1,param2,param3]);
      }
      
      public static function questActorAttacked(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qaa",[param1,param1 == "" ? 1 : 0,param2]);
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
      
      public static function questActorPositionUpdate(param1:String, param2:int, param3:int, param4:int, param5:int) : void
      {
         if(QuestManager._questStartingPlayerCount > 1)
         {
            gMainFrame.server.setXtObject_Str("qau",[param1,param2,param3,param4,param5]);
         }
      }
      
      public static function questActorSeek(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("qas",[param1,param2]);
      }
      
      public static function questPhantomZap(param1:String, param2:int, param3:int, param4:int) : void
      {
         gMainFrame.server.setXtObject_Str("qpzap",[param1,param2,param3,param4]);
      }
      
      public static function sendQuestWaitRequest(param1:int) : void
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
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qj",[gMainFrame.server.getCurrentRoomName(),param1]);
         }
      }
      
      public static function sendQuestJoinCancel() : void
      {
         gMainFrame.server.setXtObject_Str("qjx",[]);
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
      
      public static function sendQuestExit() : void
      {
         gMainFrame.server.setXtObject_Str("qx",[]);
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
      
      public static function sendPickGiftResult(param1:int) : void
      {
         gMainFrame.server.setXtObject_Str("qpgift",[param1]);
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
            case "qj":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               if(_loc2_[2] != 0)
               {
                  QuestManager.handleQuestJoinResponse(_loc2_);
               }
               else if(_loc2_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,"Failed to join! Please try again.");
               }
               else if(_loc2_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,"This Adventure is currently for Club members only!");
               }
               else if(_loc2_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,"Your animal must be level " + _loc2_[4] + " to go on this Adventure.");
               }
               else
               {
                  new SBOkPopup(GuiManager.guiLayer,"Failed to join! Please try again.");
               }
               break;
            case "qjx":
               QuestManager.handleQuestJoinCancelResponse(_loc2_);
               break;
            case "qw":
               QuestManager.handleQuestWaitResponse(_loc2_);
               break;
            case "qs":
               questStartResponse(_loc2_);
               QuestManager.handleQuestStartResponse(_loc2_);
               break;
            case "qat":
               questActorTriggeredResponse(_loc2_);
               break;
            case "qcmd":
               QuestManager.handleCommand(_loc2_);
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
               QuestManager.playSound(_loc2_[2]);
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
            case "qep":
               QuestManager.handleEatPhantom(_loc2_[2],_loc2_[3]);
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
         }
      }
      
      private static function questStartResponse(param1:Object) : void
      {
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
         var _loc2_:* = 2;
         var _loc3_:int = int(param1[_loc2_++]);
         var _loc4_:int = int(param1[_loc2_++]);
         var _loc5_:* = int(param1[_loc2_++]);
         var _loc6_:String = param1[_loc2_++];
         if(_loc5_ >= 0)
         {
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
               _loc8_.visible = _loc14_;
               _loc8_.requireClick = _loc15_;
               _loc8_.defId = _loc11_;
               _loc8_.defName = _loc12_;
               _loc8_.type = _loc10_;
               _loc8_.state = _loc13_;
               _loc8_.pathName = _loc16_ != "" ? _loc16_ : null;
               QuestManager.initInitialActorStatus(_loc8_,null);
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
      
      public static function questDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_BATTLE_CARD] = null;
         var _loc3_:Object = new Object();
         for each(_loc5_ in param1.def)
         {
            _loc4_ = {
               "defId":int(_loc5_.id),
               "type":int(_loc5_.type),
               "cardMediaRefId":int(_loc5_.cardMediaRef),
               "effectMediaRefId":int(_loc5_.effectMediaRef),
               "screenEffectMediaRefId":int(_loc5_.screenEffectMediaRef),
               "titleStrId":int(_loc5_.titleStrId),
               "cardClass":int(_loc5_.cardClass),
               "amount":int(_loc5_.amount),
               "manaCost":int(_loc5_.manaCost),
               "delayStartMS":int(_loc5_.delayStartMS),
               "delayHitMS":int(_loc5_.delayHitMS),
               "criticalHit":int(_loc5_.criticalHit),
               "chanceHit":int(_loc5_.chanceHit),
               "debuffType":int(_loc5_.debuffType),
               "chanceDebuff":int(_loc5_.chanceDebuff),
               "amountDebuff":int(_loc5_.amountDebuff),
               "turnDurDebuff":int(_loc5_.turnDurDebuff),
               "classModifierBits":int(_loc5_.classModifierBits)
            };
            _loc3_[_loc4_.defId] = _loc4_;
         }
         QuestManager.gameCardDefs = _loc3_;
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
               "level":int(_loc5_.level)
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
               "titleStrId":int(_loc5_.titleStrId)
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

