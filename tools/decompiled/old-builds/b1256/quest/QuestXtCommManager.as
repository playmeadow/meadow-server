package quest
{
   import avatar.AvatarManager;
   import com.carlcalderon.arthropod.Debug;
   import com.hurlant.util.Base64;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import den.DenXtCommManager;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
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
      
      private static var _activePickGift:String;
      
      private static var _autoStartQuestOnNextWaitResponse:Boolean;
      
      public function QuestXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _questCache = [];
         _questDefLookups = [];
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
         var _loc8_:Boolean = param1.substring(0,3) == "_l_";
         if(!_loc8_ && QuestManager.livePlayerCount() > 1)
         {
            gMainFrame.server.setXtObject_Str("qau",[param1,param2,param3,param4,param5,param6,param7]);
         }
      }
      
      public static function questActorSeek(param1:String, param2:int) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Boolean = param1.substring(0,3) == "_l_";
         if(!_loc4_)
         {
            gMainFrame.server.setXtObject_Str("qas",[param1,param2]);
         }
         else
         {
            _loc3_ = [];
            _loc3_[0] = 0;
            _loc3_[1] = 0;
            _loc3_[2] = param1;
            _loc3_[3] = param2;
            _loc3_[4] = AvatarManager.playerSfsUserId;
            QuestManager.handleQuestActorRequestSeekResponse(_loc3_);
         }
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
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
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
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestJoinBuddy(param1:String) : void
      {
         var _loc2_:String = null;
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
         {
            if(RoomXtCommManager._loadingNewRoom)
            {
               DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
               return;
            }
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            _loc2_ = gMainFrame.server.getCurrentRoomName();
            if(_loc2_.indexOf("den") != -1)
            {
               _wasRoomWeCameFromDen = true;
            }
            else
            {
               _wasRoomWeCameFromDen = false;
            }
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qjf",[gMainFrame.server.getCurrentRoomName(),param1]);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestCreateJoinPublic(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         var _loc4_:String = null;
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
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
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestCreateJoinPublicNoCurrentRoom(param1:int, param2:int = 0) : void
      {
         if(RoomXtCommManager._loadingNewRoom)
         {
            DebugUtility.debugTrace("IGNORING sendQuestWaitRequest request because user is already joining a new room!");
            return;
         }
         if(Utility.canQuest())
         {
            AvatarManager.joiningNewRoom = true;
            RoomXtCommManager._loadingNewRoom = true;
            RoomManagerWorld.instance.forceStopMovement();
            gMainFrame.server.setXtObject_Str("qj",["",param1,param2,0]);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
         }
      }
      
      public static function sendQuestCreatePrivate(param1:int, param2:int = 0, param3:Boolean = false) : void
      {
         if(gMainFrame.server.getCurrentRoom() && Utility.canQuest())
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
            GuiManager.grayOutHudItemsForPrivateLobby(true);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(20142));
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
      
      public static function sendPickGiftResult(param1:int, param2:Boolean, param3:Boolean) : void
      {
         gMainFrame.server.setXtObject_Str(_activePickGift,[param1,param2 ? "1" : "0",param3 ? "1" : "0"]);
      }
      
      public static function sendPickGiftComplete() : void
      {
         gMainFrame.server.setXtObject_Str("qpgiftdone",["1"]);
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
         var _loc8_:ByteArray = null;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:Array = null;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Object = param1.obj;
         switch(_loc3_[0])
         {
            case "qqm":
               if(QuestManager._questActorDictionary != null)
               {
                  _loc8_ = Base64.decodeToByteArray(_loc3_[2]);
                  _loc8_.uncompress();
                  _loc7_ = _loc8_.readShort();
                  _loc9_ = 0;
                  while(_loc9_ < _loc7_)
                  {
                     _loc6_ = _loc8_.readShort();
                     _loc4_ = [];
                     _loc2_ = 0;
                     _loc4_[_loc2_++] = _loc8_.readUTF();
                     _loc6_--;
                     _loc4_[_loc2_++] = _loc3_[1];
                     _loc5_ = 0;
                     while(_loc5_ < _loc6_)
                     {
                        _loc4_[_loc2_++] = _loc8_.readUTF();
                        _loc5_++;
                     }
                     param1.obj = _loc4_;
                     handleXtReply(param1);
                     _loc9_++;
                  }
               }
               break;
            case "qap":
               QuestManager.handleAttackPlayer(_loc3_);
               break;
            case "qau":
               QuestManager.handleQuestActorPositionUpdateResponse(_loc3_);
               break;
            case "qahs":
               QuestManager.handleActorHealthStatus(_loc3_);
               break;
            case "qas":
               QuestManager.handleQuestActorRequestSeekResponse(_loc3_);
               break;
            case "qjp":
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc3_[2] != 0)
               {
                  GuiManager.setSwapBtnGray(true);
                  QuestManager.handleQuestJoinResponse(_loc3_,"custParty",_loc3_[5]);
               }
               else if(_loc3_[3] == "NV")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
               }
               else if(_loc3_[3] == "FULL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14817));
               }
               else if(_loc3_[3] == "NLAND")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
               }
               else if(_loc3_[3] == "NOCEAN")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
               }
               else if(_loc3_[3] == "NAIR")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
               }
               else if(_loc3_[3] == "NM")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
               }
               else if(_loc3_[3] == "NB")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14819));
               }
               else if(_loc3_[3] == "NL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc3_[4]));
               }
               else if(_loc3_[3] == "NAIL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
               }
               else if(_loc3_[3] == "NDL")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc3_[4]));
               }
               else if(_loc3_[3] == "NQ")
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14822));
               }
               else if(_loc3_[3] == "NP")
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
               if(_loc3_[2] != 0)
               {
                  GuiManager.closeWorldMapIfOpen();
                  QuestManager.handleQuestJoinResponse(_loc3_,"custSettings");
               }
               else
               {
                  if(_loc3_[3] == "NV")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  }
                  else if(_loc3_[3] == "NLAND")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                  }
                  else if(_loc3_[3] == "NOCEAN")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                  }
                  else if(_loc3_[3] == "NAIR")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                  }
                  else if(_loc3_[3] == "NM")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14818));
                  }
                  else if(_loc3_[3] == "NL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc3_[4]));
                  }
                  else if(_loc3_[3] == "NAIL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
                  }
                  else if(_loc3_[3] == "NDL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc3_[4]));
                  }
                  else if(_loc3_[3] == "NP")
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
               AvatarManager.joiningNewRoom = false;
               RoomXtCommManager._loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               if(_loc3_[2] != 0)
               {
                  GuiManager.setSwapBtnGray(true);
                  QuestManager.handleQuestJoinResponse(_loc3_,"normal",_loc3_[5]);
               }
               else
               {
                  GuiManager.setSwapBtnGray(false);
                  if(_loc3_[3] == "NV")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  }
                  else if(_loc3_[3] == "NLAND")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                  }
                  else if(_loc3_[3] == "NOCEAN")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                  }
                  else if(_loc3_[3] == "NAIR")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                  }
                  else if(_loc3_[3] == "NM")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14823));
                  }
                  else if(_loc3_[3] == "NL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_loc3_[4]));
                  }
                  else if(_loc3_[3] == "NAIL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14820));
                  }
                  else if(_loc3_[3] == "NDL")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_loc3_[4]));
                  }
                  else if(_loc3_[3] == "NDLERR")
                  {
                     new SBOkPopup(GuiManager.guiLayer,"Total user var bits exceeded - increase support for additional levels!");
                  }
                  else if(_loc3_[3] == "NP")
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                  }
                  else
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14816));
                  }
               }
               break;
            case "qjx":
               GuiManager.setSwapBtnGray(false);
               QuestManager.handleQuestJoinCancelResponse(_loc3_);
               break;
            case "qw":
               QuestManager.handleQuestWaitResponse(_loc3_);
               if(_autoStartQuestOnNextWaitResponse)
               {
                  _autoStartQuestOnNextWaitResponse = false;
                  sendQuestStartRequest();
               }
               break;
            case "qs":
               GuiManager.setSwapBtnGray(false);
               questStartResponse(_loc3_);
               QuestManager.handleQuestStartResponse(_loc3_);
               break;
            case "qcmd":
               QuestManager.handleCommand(_loc3_,false);
               break;
            case "qcmdVT":
               QuestManager.handleCommand(_loc3_,true);
               break;
            case "qp":
               QuestManager.handleLaunchProjectile(_loc3_);
               break;
            case "qm":
               QuestManager.handleSwipe(_loc3_);
               break;
            case "quxp":
               QuestManager.handleXpUpdate(_loc3_);
               break;
            case "quhp":
               QuestManager.handleHealthUpdate(_loc3_,false);
               break;
            case "qrspn":
               QuestManager.handleHealthUpdate(_loc3_,true);
               break;
            case "qad":
               QuestManager.handleActorDeath(_loc3_);
               break;
            case "qx":
               break;
            case "qxt":
               QuestManager.handleExitByType(_loc3_);
               break;
            case "qspn":
               QuestManager.handleSpawn(_loc3_);
               break;
            case "qatt":
               QuestManager.handleQuestActorTriggerTreasure(_loc3_);
               break;
            case "qusu":
               QuestManager.handleStatsUpdate(_loc3_);
               break;
            case "qulu":
               QuestManager.handleLevelUp(_loc3_);
               break;
            case "qporbs":
               QuestManager.handleOrbsUpdate(_loc3_);
               break;
            case "qpup":
               QuestManager.handlePickUpItem(_loc3_);
               break;
            case "qsnd":
               QuestManager.playSound(_loc3_[2],null,false,null);
               break;
            case "qsndVO":
               QuestManager.playSound(_loc3_[2],null,true,_loc3_[3]);
               break;
            case "qmusic":
               QuestManager.playMusic(_loc3_[2]);
               break;
            case "qswfs":
               QuestManager.handleSetSwfState(_loc3_);
               break;
            case "qmlib":
               QuestManager.handleLoadMediaLib(_loc3_);
               break;
            case "qprr":
               QuestManager.handleQuestPlayerRequestRespawn(_loc3_);
               break;
            case "qpd":
               QuestManager.handleQuestPlayerDead(_loc3_);
               break;
            case "qsp":
               QuestManager.handleQuestSetPath(_loc3_);
               break;
            case "qps":
               QuestManager.handlePlantSeed(_loc3_);
               break;
            case "qpa":
               QuestManager.handlePlantAte(_loc3_[2],_loc3_[3]);
               break;
            case "qbzap":
               QuestManager.handleBeamZap(_loc3_);
               break;
            case "qpzap":
               QuestManager.handlePhantomZap(_loc3_);
               break;
            case "qpgift":
               _activePickGift = "qpgift";
               QuestManager.handlePickGift(_loc3_,false);
               break;
            case "qpgiftplr":
               _activePickGift = "qpgiftplr";
               QuestManager.handlePickGift(_loc3_,false);
               break;
            case "qplq":
               QuestManager.handlePlayerLeftQuest(_loc3_);
               break;
            case "qrc":
               QuestManager.handleQuestRoomChange(_loc3_);
               break;
            case "qviu":
               QuestManager.handleQuestVolumeInteractionUpdate(_loc3_);
               break;
            case "qtorch":
               QuestManager.handleQuestTorch(_loc3_);
               break;
            case "qgi":
               questPickUpItem(_loc3_[2]);
               break;
            case "qsndpk":
               QuestManager.loadQuestSfx(_loc3_[2]);
               break;
            case "qicon":
               QuestManager.handleActorIcon(_loc3_[2],_loc3_[3]);
               break;
            case "qseed":
               QuestManager.handleGiveSeed(_loc3_[2],_loc3_[3],_loc3_[4]);
               break;
            case "qmi":
               QuestManager.handleMovedItemList(_loc3_ as Array);
               break;
            case "qepr":
               QuestManager.handlePlantEatRecoil(_loc3_[2]);
               break;
            case "qplayswf":
               QuestManager.handlePlaySwf(_loc3_[2]);
               break;
            case "qshake":
               QuestManager.handleShake(_loc3_[2]);
               break;
            case "qaward":
               QuestManager.handleAward(_loc3_[2],_loc3_[3]);
               break;
            case "qposturi":
               QuestManager.handlePostUri(_loc3_[2]);
               break;
            case "qpreloadswf":
               QuestManager.handlPreloadSwf(_loc3_[2]);
               break;
            case "qfade":
               QuestManager.handleFade(_loc3_[2] == 1);
               break;
            case "qavsw":
               QuestManager.handleAvSwitch(_loc3_);
               break;
            case "qrestore":
               QuestManager.handleRestore(_loc3_);
         }
      }
      
      private static function questStartResponse(param1:Object) : void
      {
         var _loc4_:String = null;
         var _loc17_:Dictionary = null;
         var _loc8_:Object = null;
         var _loc14_:String = null;
         var _loc12_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc15_:int = 0;
         var _loc13_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc11_:String = null;
         var _loc10_:String = null;
         var _loc9_:int = 2;
         var _loc16_:int = int(param1[_loc9_++]);
         var _loc7_:int = int(param1[_loc9_++]);
         var _loc2_:int = int(param1[_loc9_++]);
         if(_loc2_ >= 0)
         {
            _loc4_ = param1[_loc9_++];
            _loc17_ = new Dictionary();
            while(_loc2_ > 0)
            {
               _loc8_ = {};
               _loc14_ = param1[_loc9_++];
               _loc12_ = int(param1[_loc9_++]);
               _loc5_ = 0;
               _loc6_ = null;
               if(_loc12_ == 16)
               {
                  _loc6_ = param1[_loc9_++];
               }
               else
               {
                  _loc5_ = int(param1[_loc9_++]);
               }
               _loc15_ = int(param1[_loc9_++]);
               _loc13_ = param1[_loc9_++] == 1;
               _loc3_ = param1[_loc9_++] == 1;
               _loc11_ = param1[_loc9_++];
               _loc10_ = param1[_loc9_++];
               _loc8_.visible = _loc13_;
               _loc8_.requireClick = _loc3_;
               _loc8_.defId = _loc5_;
               _loc8_.defName = _loc6_;
               _loc8_.type = _loc12_;
               _loc8_.state = _loc15_;
               _loc8_.pathName = _loc11_ != "" ? _loc11_ : null;
               QuestManager.initInitialActorStatus(_loc8_,null);
               _loc8_.pendingSwfStateName = _loc10_;
               _loc17_[_loc14_] = _loc8_;
               _loc2_--;
            }
            QuestManager.setActorDictionary(_loc17_,_loc4_);
            QuestManager.hasJustJoinedQuest = true;
         }
         else
         {
            AvatarManager.joiningNewRoom = false;
            RoomXtCommManager._loadingNewRoom = false;
         }
      }
      
      public static function questNPCDefResponse(param1:DefPacksDefHelper) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1025] = null;
         var _loc5_:Object = {};
         for each(var _loc4_:Object in param1.def)
         {
            _loc2_ = {
               "avatarRefId":int(_loc4_.avatarRefId),
               "backColor":Number(_loc4_.backColor),
               "backItemRefId":int(_loc4_.backItemRefId),
               "eyesColor":Number(_loc4_.eyesColor),
               "eyesItemRefId":int(_loc4_.eyesItemRefId),
               "legColor":Number(_loc4_.legColor),
               "legItemRefId":int(_loc4_.legItemRefId),
               "headColor":int(_loc4_.headColor),
               "headMediaRefId":uint(_loc4_.headMediaRefId),
               "headItemRefId":int(_loc4_.headItemRefId),
               "defId":int(_loc4_.id),
               "mediaRefId":int(_loc4_.mediaRefId),
               "neckColor":Number(_loc4_.neckColor),
               "neckItemRefId":int(_loc4_.neckItemRefId),
               "patternColor":Number(_loc4_.patternColor),
               "patternItemRefId":int(_loc4_.patternItemRefId),
               "tailColor":Number(_loc4_.tailColor),
               "tailItemRefId":int(_loc4_.tailItemRefId),
               "titleStrId":int(_loc4_.titleStrId),
               "type":int(_loc4_.type),
               "baseColor":int(_loc4_.baseColor),
               "hps":int(_loc4_.hps),
               "defense":int(_loc4_.defense),
               "xpValue":int(_loc4_.xpValue),
               "iconMediaRefId":int(_loc4_.iconMediaRefId),
               "level":int(_loc4_.level),
               "attackable":int(_loc4_.attackable),
               "damageTouch":int(_loc4_.damageTouch)
            };
            _loc5_[_loc2_.defId] = _loc2_;
         }
         QuestManager.npcDefs = _loc5_;
      }
      
      public static function scriptResponse(param1:DefPacksDefHelper) : void
      {
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1052] = null;
         var _loc3_:Object = {};
         for each(var _loc4_:Object in _loc2_)
         {
            _loc5_ = {
               "defId":int(_loc4_.id),
               "avatarLimit":int(_loc4_.avatarLimit),
               "avatarMin":int(_loc4_.avatarMin),
               "avatarType":int(_loc4_.avatarType),
               "descStrId":int(_loc4_.descStrId),
               "difficulty":int(_loc4_.difficulty),
               "levelMin":int(_loc4_.levelMin),
               "mediaRefId":int(_loc4_.mediaRefId),
               "time":int(_loc4_.time),
               "titleStrId":int(_loc4_.titleStrId),
               "hudType":int(_loc4_.hudType),
               "bannerMediaRefId":int(_loc4_.bannerMediaRefId),
               "membersOnly":(_loc4_.membersOnly == "1" ? true : false),
               "playAsPet":(_loc4_.playAsPet == "1" ? true : false)
            };
            _loc3_[_loc5_.defId] = _loc5_;
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

