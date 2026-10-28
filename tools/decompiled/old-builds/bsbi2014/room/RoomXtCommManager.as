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
   import game.MinigameManager;
   import gamePlayFlow.GamePlay;
   import gui.BuddyCard;
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
         XtReplyDemuxer.addModule(handleXtReply,"r");
      }
      
      public static function destroy() : void
      {
         XtReplyDemuxer.removeModule(handleXtReply);
         roomCountResponseCallback = null;
      }
      
      public static function sendRoomCountRequest(userNames:Array) : void
      {
         gMainFrame.server.setXtObject_Str("rc",userNames,true,false,false);
      }
      
      public static function sendMoreShardRequest() : void
      {
         gMainFrame.server.setXtObject_Str("rm",[]);
      }
      
      public static function sendRoomFFMRequest(rfCallback:Function) : void
      {
         _rfCallback = rfCallback;
         gMainFrame.server.setXtObject_Str("rf",[]);
      }
      
      public static function sendNonDenRoomJoinRequest(rjNameOrId:String) : void
      {
         sendRoomJoinRequestFull(rjNameOrId);
      }
      
      public static function set waitForLangPack(setWait:Boolean) : void
      {
         _waitForLangPack = setWait;
      }
      
      public static function sendRoomJoinRequest(rjNameOrId:String, portalInvId:int = -1, isFromMinigame:Boolean = false, forceInvisMode:Boolean = false, confirmLanguageChange:Boolean = true) : void
      {
         if(rjNameOrId.slice(0,3) == "den" && !isFromMinigame)
         {
            DenXtCommManager.requestDenJoinFull(rjNameOrId,portalInvId,forceInvisMode,confirmLanguageChange);
         }
         else
         {
            sendRoomJoinRequestFull(rjNameOrId,forceInvisMode,confirmLanguageChange);
         }
      }
      
      private static function sendRoomJoinRequestFull(rjNameOrId:String, forceInvisMode:Boolean = false, confirmLanguageChange:Boolean = true) : void
      {
         if(_loadingNewRoom)
         {
            DebugUtility.debugTrace("IGNORING rj request to room=" + rjNameOrId + " because user is already joining a new room!");
            return;
         }
         if(isSwitching)
         {
            DarkenManager.showLoadingSpiral(false);
            return;
         }
         if(Boolean(gMainFrame.server.getCurrentRoom()))
         {
            if(rjNameOrId == gMainFrame.server.getCurrentRoomName())
            {
               trace("WARNING: User is already in this room!");
               DarkenManager.showLoadingSpiral(false);
               return;
            }
         }
         AvatarManager.joiningNewRoom = true;
         _loadingNewRoom = true;
         var atIdx:int = rjNameOrId.indexOf("@");
         if(atIdx < 0)
         {
            _joinRoomName = rjNameOrId;
         }
         else
         {
            _joinRoomName = rjNameOrId.substring(0,atIdx);
         }
         if(RoomManagerWorld.instance.haveHadLastGoodRoomName())
         {
            SBTracker.trackPageview("/game/play/loading/changeRooms");
         }
         var confirmLanguageChangeString:String = confirmLanguageChange ? "1" : "0";
         var forceInvisNow:Boolean = forceInvisMode || _roomMgr.forceInvisMode;
         if(!forceInvisNow)
         {
            gMainFrame.server.setXtObject_Str("rj",[rjNameOrId,confirmLanguageChangeString]);
         }
         else
         {
            gMainFrame.server.setXtObject_Str("rj",[rjNameOrId,confirmLanguageChangeString,"1"]);
            _roomMgr.forceInvisMode = true;
         }
      }
      
      public static function sendRoomLeaveRequest(roomId:int, useSubRoom:Boolean = false) : void
      {
         gMainFrame.server.setXtObject_Str("rl",[roomId],true,useSubRoom);
         gMainFrame.server.handleSubRoomExit();
      }
      
      public static function denJoinRequested(avIdOrDenRoomName:String) : void
      {
         _loadingNewRoom = true;
         _joinRoomName = avIdOrDenRoomName;
         _denJoinPending = true;
      }
      
      public static function get loadingNewRoom() : Boolean
      {
         return _loadingNewRoom;
      }
      
      public static function set loadingNewRoom(value:Boolean) : void
      {
         _loadingNewRoom = value;
      }
      
      public static function startRoomLoadIfReady() : void
      {
         _waitForLangPack = false;
         if(Boolean(_savedRPData))
         {
            roomPropertiesResponse(_savedRPData);
            _savedRPData = null;
         }
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Object = evt.obj;
         switch(data[0])
         {
            case "rj":
               roomJoinResponse(data);
               break;
            case "rp":
               roomPropertiesResponse(data);
               break;
            case "rc":
               roomCountResponse(data);
               break;
            case "rf":
               roomFFMResponse(data);
               break;
            case "rl":
               roomListResponse(data);
               break;
            case "rm":
               roomMoreResponse(data);
               break;
            default:
               throw new Error("RoomXtCommManager: Received illegal cmd: " + data[0]);
         }
      }
      
      private static function roomJoinResponse(data:Object) : void
      {
         var s:SFRoom = null;
         var displayName:String = null;
         var displayNameId:int = 0;
         var roomLanguageId:int = 0;
         var joinedShardId:int = 0;
         var msg:String = null;
         var newNode:String = null;
         var asrShardId:int = 0;
         var i:int = 2;
         if(data[i++] == "1")
         {
            s = new SFRoom();
            s.name = data[i++];
            s.id = int(data[i++]);
            s.users = int(data[i++]);
            s.maxUsers = int(data[i++]);
            s.spectators = int(data[i++]);
            s.maxSpectators = int(data[i++]);
            s.isPrivate = data[i++] == "1";
            s.isGame = data[i++] == "1";
            s.isLimbo = data[i++] == "1";
            s.isTemp = data[i++] == "1";
            displayName = data[i++];
            displayNameId = int(data[i++]);
            gMainFrame.userInfo.myPerUserAvId = int(data[i++]);
            PetManager.myActivePetInvId = int(data[i++]);
            roomLanguageId = int(data[i++]);
            if(data.hasOwnProperty(i))
            {
               joinedShardId = int(data[i++]);
               _roomMgr.shardId = joinedShardId;
            }
            if(roomLanguageId != LocalizationManager.currentLanguage && !MinigameManager.inInRoomGame())
            {
               LocalizationXtCommManager.requestLocalizationPack(roomLanguageId);
            }
            gMainFrame.server.handleRoomJoin(s);
            _roomMgr.forceInvisMode = false;
            if(!s.isGame || s.name.indexOf("den") == 0 || s.name.indexOf("party") == 0 || s.name.indexOf("staging") == 0)
            {
               GuiManager.setRoomNameDisplay(displayName,displayNameId);
            }
            if(s.name.indexOf("venue_carnival") != -1)
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(343) < 1)
               {
                  _welcomePopup = new WelcomeToCarnival();
                  _welcomePopup.init();
                  DarkenManager.showLoadingSpiral(true);
                  AchievementXtCommManager.requestSetUserVar(343,1);
               }
            }
            else if(s.name.indexOf("room_diamonds") != -1)
            {
               if(gMainFrame.userInfo.userVarCache.getUserVarValueById(368) < 1)
               {
                  GuiManager.openDiamondShopInfo();
                  AchievementXtCommManager.requestSetUserVar(368,1);
               }
            }
            delete gMainFrame.clientInfo.autoStartRoom;
            QuestXtCommManager.roomJoined(s.name);
         }
         else
         {
            msg = data[i++];
            if(msg == "N")
            {
               newNode = data[i++];
               if(newNode == "null")
               {
                  new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14834),false);
                  AvatarManager.joiningNewRoom = false;
                  _denJoinPending = false;
                  return;
               }
               gMainFrame.userInfo.myPerUserAvId = int(data[i++]);
               if(_denJoinPending)
               {
                  gMainFrame.clientInfo.autoStartRoom = _joinRoomName;
                  gMainFrame.clientInfo.autoStartRoomShardId = RT_PARAM_GET_SHARD_FROM_DEN;
                  DebugUtility.debugTrace("using autoStartRoom to prep resend join request after switching server nodes - room:" + _joinRoomName + " shardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
                  if(!gMainFrame.switchServersIfNeeded(newNode))
                  {
                     throw new Error("got join room response saying to switch server nodes, but was already on that node!");
                  }
               }
               else
               {
                  if(_joinRoomName.indexOf("#") < 0)
                  {
                     throw new Error("join room request for sfs room:" + _joinRoomName + " somehow is on another server node:" + newNode + " (current node:" + gMainFrame.server.serverIp + ")?!");
                  }
                  gMainFrame.clientInfo.autoStartRoom = _joinRoomName;
                  asrShardId = int(_joinRoomName.substr(_joinRoomName.indexOf("#") + 1));
                  if(asrShardId == -1)
                  {
                     asrShardId = RT_PARAM_NEW_REGISTRANT_EXPERIENCE_REDIRECT;
                  }
                  gMainFrame.clientInfo.autoStartRoomShardId = asrShardId;
                  DebugUtility.debugTrace("using autoStartRoom to prep resend join request after switching server nodes - room:" + _joinRoomName + " shardId:" + gMainFrame.clientInfo.autoStartRoomShardId);
                  if(!gMainFrame.switchServersIfNeeded(newNode))
                  {
                     new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14835),false);
                     AvatarManager.joiningNewRoom = false;
                     _denJoinPending = false;
                     return;
                  }
               }
               _roomMgr.clearLastGoodRoomForServerSwitch();
            }
            else if(msg.indexOf("DJE") == 0)
            {
               if(msg.charAt(3) == "C")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14836),true,GuiManager.switchToOceanAnimal,false);
               }
               else if(msg.charAt(3) == "E")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14836),true,GuiManager.switchToOceanAnimal,true);
               }
               else if(msg.charAt(3) == "K")
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBYesNoPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14837),true,GuiManager.switchToOceanAnimal,false);
               }
            }
            else if(msg == "BSJ")
            {
               _loadingNewRoom = false;
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14838));
            }
            else if(msg == "SSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14839));
            }
            else if(msg == "CSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14840));
            }
            else if(msg == "QSJL")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14841));
            }
            else if(msg == "BQSJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14842));
            }
            else if(msg == "RQJF")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14843));
            }
            else if(msg == "RQJF_NL")
            {
               _loadingNewRoom = false;
               if(!BuddyCard.joinBuddyInQuest())
               {
                  DarkenManager.showLoadingSpiral(false);
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14843));
               }
            }
            else if(msg == "SQQJ")
            {
               DarkenManager.showLoadingSpiral(false);
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14844));
            }
            else if(msg != "LC")
            {
               gMainFrame.server.handleRoomJoinError(msg,data[i]);
            }
            _loadingNewRoom = false;
         }
         AvatarManager.joiningNewRoom = false;
         _denJoinPending = false;
      }
      
      private static function roomPropertiesResponse(data:Object) : void
      {
         if(_waitForLangPack)
         {
            _savedRPData = data;
            return;
         }
         _roomMgr.loadRoom(data[2],int(data[3]),int(data[4]),int(data[5]),int(data[6]));
         AvatarManager.finishHandleAvatarCreate();
      }
      
      private static function roomCountResponse(data:Object) : void
      {
         if(roomCountResponseCallback != null)
         {
            roomCountResponseCallback(data);
         }
      }
      
      private static function roomMoreResponse(data:Object) : void
      {
         var statusId:int = 0;
         if(!isNaN(Number(data[2])))
         {
            statusId = int(data[2]);
            if(statusId <= 0)
            {
               new SBStandardPopup(LoadProgress.loadLayer,LocalizationManager.translateIdOnly(14847),false);
               return;
            }
         }
         GamePlay(gMainFrame.gamePlay).showServerSelectorMore(data);
      }
      
      private static function roomFFMResponse(data:Object) : void
      {
         if(data[2] == "1" && _rfCallback != null)
         {
            _rfCallback();
         }
      }
      
      private static function roomListResponse(data:Object) : void
      {
         gMainFrame.server.setRoomList(data);
      }
   }
}

