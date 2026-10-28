package facilitator
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStandardPopup;
   import com.sbi.popup.SBStandardTitlePopup;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   
   public class FacilitatorXtCommManager
   {
      
      private static var _guiLayer:DisplayObjectContainer;
      
      private static var _punishPopups:Array;
      
      private static var _reportCallback:Function;
      
      private static var _reportedPlayers:Object;
      
      private static var _punishPopup:Sprite;
      
      private static var _punishPopupHelper:MediaHelper;
      
      public static var kickMsg:String;
      
      public static var wasUserBanned:Boolean;
      
      private static var _isRulesPopupOpen:Boolean;
      
      private static var _contextualWarningTimer:Timer;
      
      public static const PUNISH_TYPE_BAN:int = -1;
      
      private static const PUNISH_TYPE_SCAMMING:int = 100;
      
      private static const PUNISH_TYPE_PII:int = 110;
      
      private static const PUNISH_TYPE_BULLYING:int = 120;
      
      private static const PUNISH_TYPE_INAPP_BEHAVIOR:int = 130;
      
      private static const CONTEXTUAL_WARNING_POPUP_TIME_MS:int = 10000;
      
      public static const RULE_MEAN:int = 1;
      
      public static const RULE_LANGUAGE:int = 2;
      
      public static const RULE_PERSONAL_INFO:int = 3;
      
      public static const RULE_SECURITY:int = 4;
      
      public static const RULE_BAD_DEN:int = 5;
      
      public static const RULE_SCAMMING:int = 6;
      
      public static const RULE_RELATIONSHIP:int = 7;
      
      public static var kickReason:int = -1;
      
      public function FacilitatorXtCommManager()
      {
         super();
      }
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         _guiLayer = param1;
         _punishPopups = new Array();
         _reportedPlayers = new Object();
         _punishPopup = new Sprite();
         _punishPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _punishPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         _punishPopupHelper = new MediaHelper();
         _punishPopupHelper.init(1505,onPunishPopupImgReceived);
         _contextualWarningTimer = new Timer(CONTEXTUAL_WARNING_POPUP_TIME_MS);
      }
      
      public static function sendBanRequest(param1:String, param2:Number, param3:int, param4:String) : void
      {
         gMainFrame.server.setXtObject_Str("fb",[param1,param2,param3,param4]);
      }
      
      public static function sendSilenceRequest(param1:String, param2:Number, param3:int, param4:String) : void
      {
         gMainFrame.server.setXtObject_Str("fs",[param1,param2,param3,param4]);
      }
      
      public static function sendMuteRequest(param1:String, param2:Number, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("fm",[param1,param2,param3]);
      }
      
      public static function sendKickRequest(param1:String, param2:String) : void
      {
         gMainFrame.server.setXtObject_Str("fk",[param1,param2]);
      }
      
      public static function sendGrantGemsRequest(param1:String, param2:int) : void
      {
         gMainFrame.server.setXtObject_Str("fg",[param1,param2]);
      }
      
      public static function sendPrivateMessageRequest(param1:String, param2:String, param3:String) : void
      {
         gMainFrame.server.setXtObject_Str("fp",[param1,param2,param3]);
      }
      
      public static function sendClearDenRequest(param1:String) : void
      {
         gMainFrame.server.setXtObject_Str("fc",[param1]);
      }
      
      public static function sendReportAPlayerRequest(param1:String, param2:int, param3:Function) : void
      {
         if(!_reportedPlayers[param1])
         {
            _reportedPlayers[param1] = true;
            _reportCallback = param3;
            gMainFrame.server.setXtObject_Str("fr",[param1,param2]);
         }
         else
         {
            param3(true);
         }
      }
      
      public static function sendIdleTimeOut() : void
      {
         gMainFrame.server.setXtObject_Str("ft",[],gMainFrame.server.isWorldZone);
      }
      
      public static function sendInvisModeRequest(param1:Boolean) : void
      {
         if(param1 == gMainFrame.clientInfo.invisMode)
         {
            DebugUtility.debugTrace("WARNING: trying to change to invisMode:" + param1 + " when client is already at that state");
         }
         DebugUtility.debugTrace("sendInvisModeRequest called - shouldGoInvisible:" + param1);
         DebugUtility.debugTrace("sendInvisModeRequest called - gMainFrame.clientInfo.invisMode:" + gMainFrame.clientInfo.invisMode);
         DebugUtility.debugTrace("sendInvisModeRequest called - AvatarManager.avatarViewList:" + AvatarManager.avatarViewList);
         DebugUtility.debugTrace("sendInvisModeRequest called - AvatarManager.playerAvatarWorldView:" + (AvatarManager.avatarViewList ? AvatarManager.playerAvatarWorldView : null));
         var _loc2_:Array = !param1 && AvatarManager.avatarViewList != null && AvatarManager.playerAvatarWorldView != null ? [int(AvatarManager.playerAvatarWorldView.x),int(AvatarManager.playerAvatarWorldView.y),AvatarManager.playerAvatarWorldView.lastIdleAnim | (AvatarManager.playerAvatarWorldView.lastIdleFlip ? 2147483648 : 0),0] : [];
         DebugUtility.debugTrace("sendInvisModeRequest posArray:" + _loc2_);
         if(gMainFrame.server.isWorldXtReady)
         {
            DebugUtility.debugTrace("setXt is ready - sending fi");
            gMainFrame.server.setXtObject_Str("fi",_loc2_);
         }
         else
         {
            DebugUtility.debugTrace("setXt is NOT ready - setting trigger for fi");
            gMainFrame.server.triggerCmdWhenWorldXtReady("fi",_loc2_);
         }
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "fd":
               facilitatorDisciplineResponse(_loc2_);
               break;
            case "fk":
               facilitatorKickResponse(_loc2_);
               break;
            case "fb":
               facilitatorBanResponse(_loc2_);
               break;
            case "fm":
               facilitatorMuteResponse(_loc2_);
               break;
            case "fs":
               facilitatorSilenceResponse(_loc2_);
               break;
            case "fg":
               facilitatorGrantResponse(_loc2_);
               break;
            case "fp":
               facilitatorPrivateMessageResponse(_loc2_);
               break;
            case "fr":
               facilitatorReportAPlayerResponse(_loc2_);
               break;
            case "fi":
               facilitatorInvisModeResponse(_loc2_);
               break;
            default:
               throw new Error("FacilitatorXtCommManager illegal data:" + _loc2_[0]);
         }
      }
      
      public static function facilitatorDisciplineResponse(param1:Array) : void
      {
         var _loc3_:String = null;
         var _loc4_:int = 0;
         var _loc5_:SBOkPopup = null;
         var _loc6_:SBStandardPopup = null;
         var _loc7_:GamePlay = null;
         var _loc2_:String = param1[2];
         if(_loc2_ == "fb")
         {
            wasUserBanned = true;
            openPunishPopup(PUNISH_TYPE_BAN);
            AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
         }
         else if(_loc2_ == "fs")
         {
            _loc4_ = int(param1[3]);
            if(_loc4_ > 0)
            {
               _loc3_ = "A moderator has made it so you can not type for " + _loc4_ + " minutes because you were breaking the Animal Jam Rules.";
               GuiManager.chatHist.enableFreeChat(false);
            }
            else if(_loc4_ < 0)
            {
               _loc3_ = "A moderator has made it so you can not type because you were breaking the Animal Jam Rules.";
               GuiManager.chatHist.enableFreeChat(false);
            }
            else
            {
               _loc3_ = "You may now type. Please do not break the rules again.";
               GuiManager.chatHist.enableFreeChat(true);
            }
            _loc5_ = new SBOkPopup(_guiLayer,_loc3_);
            _punishPopups.unshift(_loc5_);
         }
         else if(_loc2_ == "fk")
         {
            _loc3_ = "You have been logged out from Animal Jam. Click the OK button to log back in.";
            kickReason = int(param1[3]);
            if(kickReason > 0)
            {
               kickMsg = param1[4];
               _loc6_ = new SBStandardPopup(_guiLayer,_loc3_);
            }
            else
            {
               kickMsg = _loc3_;
               _loc7_ = GamePlay(gMainFrame.gamePlay);
               _loc7_.onConnectionLost(null);
            }
         }
         else if(_loc2_ == "fp")
         {
            if(param1[4] == "0")
            {
               _loc3_ = "--Message From Moderator--\n\n" + param1[3];
               _punishPopups.unshift(new SBOkPopup(_guiLayer,_loc3_));
            }
            else
            {
               _punishPopups.unshift(new SBStandardTitlePopup(_guiLayer,"Jamaa isn\'t the place for this type of conversation, but if you need help, please talk to " + "a trusted adult or visit online resources like\n" + "yourlifeyourvoice.org or reachout.com.","Animal Jam CARES!"));
            }
         }
         else
         {
            if(_loc2_ != "fw")
            {
               throw new Error("ERROR -- FacilitatorXtCommManager: Invalid cmd=" + _loc2_);
            }
            showContextualWarningPopup(param1[3]);
            AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
         }
      }
      
      private static function facilitatorKickResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = "Kick was successful!";
         }
         else
         {
            _loc2_ = "Kick attempt FAILED! \n User may be offline.";
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorBanResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = "Ban succeeded!";
         }
         else
         {
            _loc2_ = "Ban attempt FAILED!";
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorMuteResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = "Mute succeeded!";
         }
         else
         {
            _loc2_ = "Mute attempt FAILED!";
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorSilenceResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = "Silence succeeded!";
         }
         else
         {
            _loc2_ = "Silence attempt FAILED!";
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorGrantResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = "Gem grant succeeded!";
         }
         else
         {
            _loc2_ = "Gem grant attempt FAILED!";
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorPrivateMessageResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = int(param1[2]);
         if(_loc3_ == 1)
         {
            _loc2_ = "Private message sent successfully!";
         }
         else if(_loc3_ == -1)
         {
            _loc2_ = "Filter triggered by private message - try again.";
         }
         else
         {
            _loc2_ = "Private message failed to send!";
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorReportAPlayerResponse(param1:Array) : void
      {
         if(_reportCallback != null)
         {
            _reportCallback(Boolean(param1[2]));
         }
         _reportCallback = null;
      }
      
      private static function facilitatorInvisModeResponse(param1:Array) : void
      {
         var newInvisMode:Boolean = false;
         var fimrestr:String = null;
         var data:Array = param1;
         try
         {
            newInvisMode = data[2] != "0";
            gMainFrame.clientInfo.invisMode = newInvisMode;
            if(AvatarManager.avatarViewList != null && AvatarManager.playerAvatarWorldView != null)
            {
               AvatarManager.playerAvatarWorldView.alpha = newInvisMode ? 0.5 : 1;
            }
            DebugUtility.debugTrace("ghostMode - fi invis mode response received from server - now ghostMode:" + gMainFrame.clientInfo.invisMode);
         }
         catch(e:Error)
         {
            fimrestr = "ERROR: Caught error in facilitatorInvisModeResponse: " + e.message + " " + e.getStackTrace();
            DebugUtility.debugTrace(fimrestr);
         }
      }
      
      private static function showContextualWarningPopup(param1:int) : void
      {
         openPunishPopup(param1);
         _contextualWarningTimer.start();
         _contextualWarningTimer.addEventListener("timer",onContextualWarningTimerFinished,false,0,true);
      }
      
      private static function onContextualWarningTimerFinished(param1:TimerEvent) : void
      {
         _contextualWarningTimer.stop();
         _guiLayer.removeChild(_punishPopup);
         DarkenManager.unDarken(_punishPopup);
         GuiManager.setFocusToChatText();
      }
      
      private static function getWarningFrameLabelString(param1:int) : String
      {
         switch(param1)
         {
            case PUNISH_TYPE_BAN:
               return "accountBan";
            case PUNISH_TYPE_SCAMMING:
               return "scamming";
            case PUNISH_TYPE_PII:
               return "personalInfo";
            case PUNISH_TYPE_BULLYING:
               return "bullying";
            case PUNISH_TYPE_INAPP_BEHAVIOR:
               return "behavior";
            default:
               return "behavior";
         }
      }
      
      private static function punishmentOkButtonHandler(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(Boolean(_punishPopups) && _punishPopups.length > 0)
         {
            _loc2_ = _punishPopups[0];
            _loc2_.destroy();
            _punishPopups.splice(0,1);
            _loc2_ = null;
         }
      }
      
      private static function onPunishPopupImgReceived(param1:MovieClip) : void
      {
         if(param1)
         {
            _punishPopup.addChild(param1);
            _punishPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopupClicked,false,0,true);
            _punishPopupHelper.destroy();
            _punishPopupHelper = null;
         }
      }
      
      private static function onRulesBtnClicked(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(gMainFrame.server.isConnected)
         {
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/autoBan/rules");
         }
         _isRulesPopupOpen = true;
         GuiManager.displayRulesPopup(true,onRulesXBtnDown);
      }
      
      private static function onPopupClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onRulesXBtnDown(param1:MouseEvent) : void
      {
         SBTracker.pop();
         _isRulesPopupOpen = false;
      }
      
      public static function openPunishPopup(param1:int) : void
      {
         var _loc2_:MovieClip = null;
         if(_contextualWarningTimer.running)
         {
            _contextualWarningTimer.stop();
         }
         gMainFrame.stage.focus = _punishPopup;
         var _loc3_:int = 0;
         while(_loc3_ < _punishPopup.numChildren)
         {
            if(_punishPopup.getChildAt(_loc3_) is MovieClip)
            {
               _loc2_ = MovieClip(_punishPopup.getChildAt(_loc3_));
               break;
            }
            _loc3_++;
         }
         var _loc4_:MovieClip = MovieClip(_loc2_.getChildAt(0));
         var _loc5_:String = getWarningFrameLabelString(param1);
         if(_loc4_.currentFrameLabel != _loc5_)
         {
            _loc4_.gotoAndStop(_loc5_);
         }
         _guiLayer.addChild(_punishPopup);
         DarkenManager.darken(_punishPopup);
         if(param1 == PUNISH_TYPE_BAN && _loc4_.rulesBtn != null)
         {
            _loc4_.rulesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRulesBtnClicked,false,0,true);
         }
         if(gMainFrame.server.isConnected)
         {
            if(_loc5_ == "accountBan")
            {
               SBTracker.trackPageview("game/play/popup/autoBan");
            }
            else
            {
               SBTracker.trackPageview("game/play/popup/warning/" + _loc5_);
            }
         }
         if(_isRulesPopupOpen)
         {
            onRulesBtnClicked(null);
         }
      }
   }
}

