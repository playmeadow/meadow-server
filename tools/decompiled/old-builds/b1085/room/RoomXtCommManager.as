package room
{
   import achievement.AchievementXtCommManager;
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.client.SFRoom;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStandardPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenXtCommManager;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.WelcomeToCarnival;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestXtCommManager;
   
   public class RoomXtCommManager
   {
      
      public static var roomCountResponseCallback:Function;
      
      public static var isSwitching:Boolean;
      
      public static var _joinRoomName:String;
      
      public static var shardSelectionUsername:String;
      
      public static var _loadingNewRoom:Boolean;
      
      private static var _denJoinPending:Boolean;
      
      private static var _waitForLangPack:Boolean;
      
      private static var _savedRPData:Object;
      
      private static var _roomMgr:RoomManagerWorld;
      
      private static var _rfCallback:Function;
      
      public static var _welcomePopup:WelcomeToCarnival;
      
      public static const RT_PARAM_GET_SHARD_FROM_DEN:int = -1;
      
      public static const RT_PARAM_NEW_REGISTRANT_EXPERIENCE_REDIRECT:int = -2;
      
      public function RoomXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _denJoinPending = false;
         _waitForLangPack = false;
         _savedRPData = null;
         _roomMgr = RoomManagerWorld.instance;
         shardSelectionUsername = "";
         XtReplyDemuxer.addModule(handleXtReply,"r");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
         roomCountResponseCallback = null;
      }
      
      public static function sendRoomCountRequest(param1:Array) : void
      {
         gMainFrame.server.setXtObject_Str("rc",param1,true,false,false);
      }
      
      public static function sendRoomShardRequest() : void
      {
         gMainFrame.server.setXtObject_Str("rs",[_roomMgr.shardId,LocalizationManager.accountLanguage]);
      }
      
      public static function sendMoreShardRequest() : void
      {
         gMainFrame.server.setXtObject_Str("rm",[shardSelectionUsername,String(LocalizationManager.accountLanguage)],false);
      }
      
      public static function sendRoomFFMRequest(param1:Function) : void
      {
         _rfCallback = param1;
         gMainFrame.server.setXtObject_Str("rf",[]);
      }
      
      public static function sendNonDenRoomJoinRequest(param1:String) : void
      {
         sendRoomJoinRequestFull(param1);
      }
      
      public static function set waitForLangPack(param1:Boolean) : void
      {
         _waitForLangPack = param1;
      }
      
      public static function sendRoomJoinRequest(param1:String, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(param1.slice(0,3) == "den" && !param2)
         {
            DenXtCommManager.requestDenJoinFull(param1,param3);
         }
         else
         {
            sendRoomJoinRequestFull(param1,param3);
         }
      }
      
      private static function sendRoomJoinRequestFull(param1:String, param2:Boolean = false) : void
      {
         if(_loadingNewRoom)
         {
            DebugUtility.debugTrace("IGNORING rj request to room=" + param1 + " because user is already joining a new room!");
            return;
         }
         if(isSwitching)
         {
            DarkenManager.showLoadingSpiral(false);
            return;
         }
         if(gMainFrame.server.getCurrentRoom())
         {
            if(param1 == gMainFrame.server.getCurrentRoomName())
            {
               return;
            }
         }
         AvatarManager.joiningNewRoom = true;
         _loadingNewRoom = true;
         _joinRoomName = param1;
         if(RoomManagerWorld.instance.haveHadLastGoodRoomName())
         {
            SBTracker.trackPageview("/game/play/loading/changeRooms");
         }
         var _loc3_:Boolean = param2 || _roomMgr.forceInvisMode;
         if(!_loc3_)
         {
            gMainFrame.server.setXtObject_Str("rj",[param1]);
         }
         else
         {
            gMainFrame.server.setXtObject_Str("rj",[param1,"1"]);
            _roomMgr.forceInvisMode = true;
         }
      }
      
      public static function sendRoomLeaveRequest(param1:int, param2:Boolean = false) : void
      {
         gMainFrame.server.setXtObject_Str("rl",[param1],true,param2);
         gMainFrame.server.handleSubRoomExit();
      }
      
      public static function denJoinRequested(param1:String) : void
      {
         _loadingNewRoom = true;
         _joinRoomName = param1;
         _denJoinPending = true;
      }
      
      public static function get loadingNewRoom() : Boolean
      {
         return _loadingNewRoom;
      }
      
      public static function set loadingNewRoom(param1:Boolean) : void
      {
         _loadingNewRoom = param1;
      }
      
      public static function startRoomLoadIfReady() : void
      {
         _waitForLangPack = false;
         if(_savedRPData)
         {
            roomPropertiesResponse(_savedRPData);
            _savedRPData = null;
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Object = param1.obj;
         switch(_loc2_[0])
         {
            case "rj":
               roomJoinResponse(_loc2_);
               break;
            case "rp":
               roomPropertiesResponse(_loc2_);
               break;
            case "rc":
               roomCountResponse(_loc2_);
               break;
            case "rs":
               roomShardResponse(_loc2_);
               break;
            case "rf":
               roomFFMResponse(_loc2_);
               break;
            case "rl":
               roomListResponse(_loc2_);
               break;
            case "rm":
               roomMoreResponse(_loc2_);
               break;
            default:
               throw new Error("RoomXtCommManager: Received illegal cmd: " + _loc2_[0]);
         }
      }
      
      private static function roomJoinResponse(param1:Object) : void
      {
         var _loc3_:SFRoom = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc2_:* = 2;
         if(param1[_loc2_++] == "1")
         {
            _loc3_ = new SFRoom();
            _loc3_.name = param1[_loc2_++];
            _loc3_.id = int(param1[_loc2_++]);
            _loc3_.users = int(param1[_loc2_++]);
            _loc3_.maxUsers = int(param1[_loc2_++]);
            _loc3_.spectators = int(param1[_loc2_++]);
            _loc3_.maxSpectators = int(param1[_loc2_++]);
            _loc3_.isPrivate = param1[_loc2_++] == "1";
            _loc3_.isGame = param1[_loc2_++] == "1";
            _loc3_.isLimbo = param1[_loc2_++] == "1";
            _loc3_.isTemp = param1[_loc2_++] == "1";
            _loc4_ = param1[_loc2_++];
            gMainFrame.userInfo.myDbAvId = int(param1[_loc2_++]);
            PetManager.myActivePetInvId = int(param1[_loc2_++]);
            _loc5_ = int(param1[_loc2_++]);
            if(param1.hasOwnProperty(_loc2_))
            {
               _loc6_ = int(param1[_loc2_++]);
               _roomMgr.shardId = _loc6_;
               LocalizationXtCommManager.sendLocalizationShardRequest(_loc6_);
            }
            else if(_loc5_ != LocalizationManager.currentLanguage)
            {
               LocalizationXtCommManager.requestLocalizationPack(_loc5_);
            }
            gMainFrame.server.handleRoomJoin(_loc3_);
            _roomMgr.forceInvisMode = false;
            if(!_loc3_.isGame || _loc3_.name.indexOf("den") == 0 || _loc3_.name.indexOf("party") == 0 || _loc3_.name.indexOf("staging") == 0)
            {
               GuiManager.setRoomNameDisplay(_loc4_);
            }
            if(_loc3_.name.indexOf("venue_carnival") != -1)
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(343) < 1)
               {
                  _welcomePopup = new WelcomeToCarnival();
                  _welcomePopup.init();
                  DarkenManager.showLoadingSpiral(true);
                  AchievementXtCommManager.requestSetUserVar(343,1);
               }
            }
            else if(_loc3_.name.indexOf("room_diamonds") != -1)
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(368) < 1)
               {
                  GuiManager.openDiamondShopInfo();
                  AchievementXtCommManager.requestSetUserVar(368,1);
               }
            }
            QuestXtCommManager.roomJoined(_loc3_.name);
         }
         else
         {
            _loc7_ = param1[_loc2_++];
            if(_loc7_ == "N")
            {
               _loc8_ = param1[_loc2_++];
               if(_loc8_ == "null")
               {
                  new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14834),false);
                  AvatarManager.joiningNewRoom = false;
                  _denJoinPending = false;
                  return;
               }
               _loc9_ = int(param1[_loc2_++]);
               gMainFrame.userInfo.myDbAvId = _loc9_;
               if(_denJoinPending)
               {
                  gMainFrame.clientInfo.autoStartRoom = _joinRoomName;
                  gMainFrame.clientInfo.autoStartRoomShardId = RT_PARAM_GET_SHARD_FROM_DEN;
                  gMainFrame.clientInfo.autoStartRoomServerNode = _loc8_;
                  DebugUtility.debugTrace("using autoStartRoom to prep resend join request after switching server nodes - room:" + _joinRoomName + " shardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
                  if(!gMainFrame.switchServersIfNeeded(_loc8_))
                  {
                     throw new Error("got join room response saying to switch server nodes, but was already on that node!");
                  }
               }
               else
               {
                  if(_joinRoomName.indexOf("#") < 0)
                  {
                     throw new Error("join room request for sfs room:" + _joinRoomName + " somehow is on another server node:" + _loc8_ + " (current node:" + gMainFrame.server.serverIp + ")?!");
                  }
                  gMainFrame.clientInfo.autoStartRoom = _joinRoomName;
                  _loc10_ = int(_joinRoomName.substr(_joinRoomName.indexOf("#") + 1));
                  if(_loc10_ == -1)
                  {
                     _loc10_ = RT_PARAM_NEW_REGISTRANT_EXPERIENCE_REDIRECT;
                  }
                  gMainFrame.clientInfo.autoStartRoomShardId = _loc10_;
                  gMainFrame.clientInfo.autoStartRoomServerNode = _loc8_;
                  DebugUtility.debugTrace("using autoStartRoom to prep resend join request after switching server nodes - room:" + _joinRoomName + " shardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
                  if(!gMainFrame.switchServersIfNeeded(_loc8_))
                  {
                     new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
                     AvatarManager.joiningNewRoom = false;
                     _denJoinPending = false;
                     return;
                  }
               }
               _roomMgr.clearLastGoodRoomForServerSwitch();
            }
            else if(_loc7_.indexOf("DJE") == 0)
            {
               if(_loc7_.charAt(3) == "C")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14836),true,GuiManager.switchToOceanAnimal,false);
               }
               else if(_loc7_.charAt(3) == "E")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14836),true,GuiManager.switchToOceanAnimal,true);
               }
               else if(_loc7_.charAt(3) == "K")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14837),true,GuiManager.switchToOceanAnimal,false);
               }
            }
            else if(_loc7_ == "BSJ")
            {
               _loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14838));
            }
            else if(_loc7_ == "SSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14839));
            }
            else if(_loc7_ == "CSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14840));
            }
            else if(_loc7_ == "QSJL")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14841));
            }
            else if(_loc7_ == "BQSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14842));
            }
            else if(_loc7_ == "RQJF")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14843));
            }
            else if(_loc7_ == "SQQJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14844));
            }
            else
            {
               gMainFrame.server.handleRoomJoinError(_loc7_,param1[_loc2_]);
            }
            _loadingNewRoom = false;
         }
         AvatarManager.joiningNewRoom = false;
         _denJoinPending = false;
      }
      
      private static function roomPropertiesResponse(param1:Object) : void
      {
         if(_waitForLangPack)
         {
            _savedRPData = param1;
            return;
         }
         _roomMgr.loadRoom(param1[2],int(param1[3]),int(param1[4]),int(param1[5]),int(param1[6]));
         AvatarManager.finishHandleAvatarCreate();
      }
      
      private static function roomCountResponse(param1:Object) : void
      {
         if(roomCountResponseCallback != null)
         {
            roomCountResponseCallback(param1);
         }
      }
      
      private static function roomMoreResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(!isNaN(Number(param1[2])))
         {
            _loc2_ = int(param1[2]);
            if(_loc2_ <= 0)
            {
               new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14847),false);
               return;
            }
         }
         GamePlay(gMainFrame.gamePlay).showServerSelectorMore(param1);
      }
      
      private static function roomShardResponse(param1:Object) : void
      {
         var _loc2_:int = 0;
         if(!isNaN(Number(param1[2])))
         {
            _loc2_ = int(param1[2]);
            if(_loc2_ <= 0)
            {
               new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14846),false);
               return;
            }
         }
         GamePlay(gMainFrame.gamePlay).showServerSelector(param1);
      }
      
      private static function roomFFMResponse(param1:Object) : void
      {
         if(param1[2] == "1" && _rfCallback != null)
         {
            _rfCallback();
         }
      }
      
      private static function roomListResponse(param1:Object) : void
      {
         gMainFrame.server.setRoomList(param1);
      }
   }
}

