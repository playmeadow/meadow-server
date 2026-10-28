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
   import gui.ChatHistory;
   import gui.DarkenManager;
   import gui.GuiManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   import room.RoomXtCommManager;
   
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
      
      public static var suspensionType:int;
      
      public static var suspensionDuration:int;
      
      private static var _isRulesPopupOpen:Boolean;
      
      private static var _contextualWarningTimer:Timer;
      
      public static const PUNISH_TYPE_BAN:int = -1;
      
      public static const PUNISH_TYPE_SUSPEND:int = -2;
      
      private static const PUNISH_TYPE_PHONE_FILTER:int = 0;
      
      private static const PUNISH_TYPE_MEDIUM_FILTER:int = 10;
      
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
      
      public static const RULE_USERNAME:int = 13;
      
      public static var kickReason:int = -1;
      
      public function FacilitatorXtCommManager()
      {
         super();
      }
      
      public static function init(guiLayer:DisplayObjectContainer) : void
      {
         _guiLayer = guiLayer;
         _punishPopups = new Array();
         _reportedPlayers = new Object();
         _punishPopup = new Sprite();
         _punishPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _punishPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         _punishPopupHelper = new MediaHelper();
         _punishPopupHelper.init(1505,onPunishPopupImgReceived);
         _contextualWarningTimer = new Timer(CONTEXTUAL_WARNING_POPUP_TIME_MS);
      }
      
      public static function sendBanRequest(userName:String, duration:Number, reason:int, notes:String) : void
      {
         gMainFrame.server.setXtObject_Str("fb",[userName,duration,reason,notes]);
      }
      
      public static function sendSilenceRequest(userName:String, duration:Number, reason:int, notes:String) : void
      {
         gMainFrame.server.setXtObject_Str("fs",[userName,duration,reason,notes]);
      }
      
      public static function sendMuteRequest(userName:String, duration:Number, notes:String) : void
      {
         gMainFrame.server.setXtObject_Str("fm",[userName,duration,notes]);
      }
      
      public static function sendKickRequest(userName:String, notes:String) : void
      {
         gMainFrame.server.setXtObject_Str("fk",[userName,notes]);
      }
      
      public static function sendGrantGemsRequest(userName:String, numGems:int) : void
      {
         gMainFrame.server.setXtObject_Str("fg",[userName,numGems]);
      }
      
      public static function sendPrivateMessageRequest(userName:String, msg:String, notes:String) : void
      {
         gMainFrame.server.setXtObject_Str("fp",[userName,msg,notes]);
      }
      
      public static function sendClearDenRequest(userName:String) : void
      {
         gMainFrame.server.setXtObject_Str("fc",[userName]);
      }
      
      public static function sendReportAPlayerRequest(userName:String, reason:int, callback:Function) : void
      {
         if(!_reportedPlayers[userName] || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            _reportedPlayers[userName] = true;
            _reportCallback = callback;
            gMainFrame.server.setXtObject_Str("fr",[userName,reason]);
         }
         else
         {
            callback(true);
         }
      }
      
      public static function sendIdleTimeOut() : void
      {
         gMainFrame.server.setXtObject_Str("ft",[],gMainFrame.server.isWorldZone);
      }
      
      public static function sendInvisModeRequest(shouldGoInvisible:Boolean) : void
      {
         if(shouldGoInvisible == gMainFrame.clientInfo.invisMode)
         {
            DebugUtility.debugTrace("WARNING: trying to change to invisMode:" + shouldGoInvisible + " when client is already at that state");
         }
         DebugUtility.debugTrace("sendInvisModeRequest called - shouldGoInvisible:" + shouldGoInvisible);
         DebugUtility.debugTrace("sendInvisModeRequest called - gMainFrame.clientInfo.invisMode:" + gMainFrame.clientInfo.invisMode);
         DebugUtility.debugTrace("sendInvisModeRequest called - AvatarManager.avatarViewList:" + AvatarManager.avatarViewList);
         DebugUtility.debugTrace("sendInvisModeRequest called - AvatarManager.playerAvatarWorldView:" + (Boolean(AvatarManager.avatarViewList) ? AvatarManager.playerAvatarWorldView : null));
         var posArray:Array = !shouldGoInvisible && AvatarManager.avatarViewList != null && AvatarManager.playerAvatarWorldView != null ? [1,int(AvatarManager.playerAvatarWorldView.x),int(AvatarManager.playerAvatarWorldView.y),AvatarManager.playerAvatarWorldView.lastIdleAnim | (AvatarManager.playerAvatarWorldView.lastIdleFlip ? 2147483648 : 0),0] : [];
         DebugUtility.debugTrace("sendInvisModeRequest posArray:" + posArray);
         if(gMainFrame.server.isWorldXtReady)
         {
            DebugUtility.debugTrace("setXt is ready - sending fi");
            gMainFrame.server.setXtObject_Str("fi",posArray);
         }
         else
         {
            DebugUtility.debugTrace("setXt is NOT ready - setting trigger for fi");
            gMainFrame.server.triggerCmdWhenWorldXtReady("fi",posArray);
         }
      }
      
      public static function handleXtReply(evt:SFEvent) : void
      {
         var data:Array = evt.obj;
         switch(data[0])
         {
            case "fd":
               facilitatorDisciplineResponse(data);
               break;
            case "fk":
               facilitatorKickResponse(data);
               break;
            case "fb":
               facilitatorBanResponse(data);
               break;
            case "fm":
               facilitatorMuteResponse(data);
               break;
            case "fs":
               facilitatorSilenceResponse(data);
               break;
            case "fg":
               facilitatorGrantResponse(data);
               break;
            case "fp":
               facilitatorPrivateMessageResponse(data);
               break;
            case "fr":
               facilitatorReportAPlayerResponse(data);
               break;
            case "fi":
               facilitatorInvisModeResponse(data);
               break;
            default:
               throw new Error("FacilitatorXtCommManager illegal data:" + data[0]);
         }
      }
      
      public static function facilitatorDisciplineResponse(data:Array) : void
      {
         var msg:String = null;
         var duration:int = 0;
         var sp:SBOkPopup = null;
         var kp:SBStandardPopup = null;
         var gamePlay:GamePlay = null;
         var locStringId:int = 0;
         var timeLeft:int = 0;
         var popup:SBOkPopup = null;
         var cmd:String = data[2];
         if(cmd == "fb")
         {
            if(data[3] == "1")
            {
               wasUserBanned = true;
               suspensionDuration = int(data[4]);
               if(suspensionDuration == -1)
               {
                  suspensionType = PUNISH_TYPE_BAN;
               }
               else
               {
                  suspensionType = PUNISH_TYPE_SUSPEND;
                  suspensionDuration = Math.ceil(suspensionDuration / 3600);
               }
               openPunishPopup(suspensionType,suspensionDuration);
               AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
            }
         }
         else if(cmd == "fs")
         {
            duration = int(data[3]);
            if(duration > 0)
            {
               msg = LocalizationManager.translateIdAndInsertOnly(11180,duration);
               GuiManager.chatHist.enableFreeChat(false);
            }
            else if(duration < 0)
            {
               msg = LocalizationManager.translateIdOnly(11181);
               GuiManager.chatHist.enableFreeChat(false);
            }
            else
            {
               msg = LocalizationManager.translateIdOnly(11182);
               GuiManager.chatHist.enableFreeChat(true);
            }
            sp = new SBOkPopup(_guiLayer,msg);
            _punishPopups.unshift(sp);
         }
         else if(cmd == "fk")
         {
            msg = LocalizationManager.translateIdOnly(11183);
            kickReason = int(data[3]);
            if(kickReason > 0)
            {
               kickMsg = msg;
               kp = new SBStandardPopup(_guiLayer,msg);
            }
            else
            {
               kickMsg = msg;
               gamePlay = GamePlay(gMainFrame.gamePlay);
               gamePlay.onConnectionLost(null);
            }
         }
         else if(cmd == "fp")
         {
            if(data[4] == "0")
            {
               msg = LocalizationManager.translateIdOnly(11134) + data[3];
               _punishPopups.unshift(new SBOkPopup(_guiLayer,msg));
            }
            else
            {
               _punishPopups.unshift(new SBStandardTitlePopup(_guiLayer,LocalizationManager.translateIdOnly(11135),LocalizationManager.translateIdOnly(11136)));
            }
         }
         else if(cmd == "fw")
         {
            showContextualWarningPopup(data[3]);
            AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
         }
         else
         {
            if(!(cmd == "fg" || cmd == "fc"))
            {
               throw new Error("ERROR -- FacilitatorXtCommManager: Invalid cmd=" + cmd);
            }
            if(data[3] == "1")
            {
               timeLeft = Math.ceil(int(data[4]) / 3600);
               if(timeLeft == 1)
               {
                  if(cmd == "fg")
                  {
                     locStringId = 18218;
                  }
                  else if(cmd == "fc")
                  {
                     locStringId = 18217;
                  }
               }
               else if(timeLeft < 24)
               {
                  if(cmd == "fg")
                  {
                     locStringId = 18219;
                  }
                  else if(cmd == "fc")
                  {
                     locStringId = 18399;
                  }
               }
               else
               {
                  timeLeft = Math.ceil(timeLeft / 24);
                  if(timeLeft == 1)
                  {
                     if(cmd == "fg")
                     {
                        locStringId = 18400;
                     }
                     else if(cmd == "fc")
                     {
                        locStringId = 18402;
                     }
                  }
                  else if(cmd == "fg")
                  {
                     locStringId = 18401;
                  }
                  else if(cmd == "fc")
                  {
                     locStringId = 18403;
                  }
               }
               if(cmd == "fg")
               {
                  if(Utility.canTrade())
                  {
                     Utility.toggleInteractionBit(Utility.INTERACTION_TYPE_TRADE);
                  }
                  if(Utility.canGift())
                  {
                     Utility.toggleInteractionBit(Utility.INTERACTION_TYPE_GIFT);
                  }
               }
               else if(cmd == "fc")
               {
                  if(gMainFrame.userInfo.sgChatType != ChatHistory.SG_CHAT_TYPE_BUBBLE)
                  {
                     gMainFrame.userInfo.sgChatType = ChatHistory.SG_CHAT_TYPE_BUBBLE;
                  }
               }
               if(locStringId != 0)
               {
                  if(RoomXtCommManager.loadingNewRoom || LoadProgress.visible)
                  {
                     RoomManagerWorld.instance.setNeedsToSeeFacilitatorMessage(true,locStringId,timeLeft);
                  }
                  else
                  {
                     popup = new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(locStringId,timeLeft));
                  }
               }
            }
            else if(cmd == "fg")
            {
               if(Utility.canTradeNonDegraded() && !Utility.canTrade())
               {
                  Utility.toggleInteractionBit(Utility.INTERACTION_TYPE_TRADE);
               }
               if(Utility.canGiftNonDegraded() && !Utility.canGift())
               {
                  Utility.toggleInteractionBit(Utility.INTERACTION_TYPE_GIFT);
               }
            }
            else if(cmd == "fc")
            {
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  gMainFrame.userInfo.sgChatType = gMainFrame.userInfo.sgChatTypeNonDegraded;
               }
            }
         }
      }
      
      private static function facilitatorKickResponse(data:Array) : void
      {
         var msg:String = null;
         if(data[2] == 1)
         {
            msg = LocalizationManager.translateIdOnly(11184);
         }
         else
         {
            msg = LocalizationManager.translateIdOnly(11185);
         }
         new SBOkPopup(_guiLayer,msg);
      }
      
      private static function facilitatorBanResponse(data:Array) : void
      {
         var msg:String = null;
         if(data[2] == 1)
         {
            msg = LocalizationManager.translateIdOnly(11186);
         }
         else
         {
            msg = LocalizationManager.translateIdOnly(11187);
         }
         new SBOkPopup(_guiLayer,msg);
      }
      
      private static function facilitatorMuteResponse(data:Array) : void
      {
         var msg:String = null;
         if(data[2] == 1)
         {
            msg = LocalizationManager.translateIdOnly(11188);
         }
         else
         {
            msg = LocalizationManager.translateIdOnly(11189);
         }
         new SBOkPopup(_guiLayer,msg);
      }
      
      private static function facilitatorSilenceResponse(data:Array) : void
      {
         var msg:String = null;
         if(data[2] == 1)
         {
            msg = LocalizationManager.translateIdOnly(11190);
         }
         else
         {
            msg = LocalizationManager.translateIdOnly(11191);
         }
         new SBOkPopup(_guiLayer,msg);
      }
      
      private static function facilitatorGrantResponse(data:Array) : void
      {
         var msg:String = null;
         if(data[2] == 1)
         {
            msg = LocalizationManager.translateIdOnly(11192);
         }
         else
         {
            msg = LocalizationManager.translateIdOnly(11193);
         }
         new SBOkPopup(_guiLayer,msg);
      }
      
      private static function facilitatorPrivateMessageResponse(data:Array) : void
      {
         var msg:String = null;
         var status:int = int(data[2]);
         if(status == 1)
         {
            msg = LocalizationManager.translateIdOnly(11194);
         }
         else if(status == -1)
         {
            msg = LocalizationManager.translateIdOnly(11195);
         }
         else
         {
            msg = LocalizationManager.translateIdOnly(11196);
         }
         new SBOkPopup(_guiLayer,msg);
      }
      
      private static function facilitatorReportAPlayerResponse(data:Array) : void
      {
         if(_reportCallback != null)
         {
            _reportCallback(Boolean(data[2]));
         }
         _reportCallback = null;
      }
      
      private static function facilitatorInvisModeResponse(data:Array) : void
      {
         var newInvisMode:Boolean = false;
         var fimrestr:String = null;
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
      
      private static function showContextualWarningPopup(warningType:int) : void
      {
         openPunishPopup(warningType,0);
         _contextualWarningTimer.start();
         _contextualWarningTimer.addEventListener("timer",onContextualWarningTimerFinished,false,0,true);
      }
      
      private static function onContextualWarningTimerFinished(evt:TimerEvent) : void
      {
         _contextualWarningTimer.stop();
         _guiLayer.removeChild(_punishPopup);
         DarkenManager.unDarken(_punishPopup);
         GuiManager.setFocusToChatText();
      }
      
      private static function getWarningFrameLabelString(warningType:int) : String
      {
         switch(warningType)
         {
            case PUNISH_TYPE_BAN:
            case PUNISH_TYPE_SUSPEND:
               return "accountBan";
            case PUNISH_TYPE_SCAMMING:
               return "scamming";
            case PUNISH_TYPE_PII:
               return "personalInfo";
            case PUNISH_TYPE_BULLYING:
               return "bullying";
            case PUNISH_TYPE_INAPP_BEHAVIOR:
            case PUNISH_TYPE_MEDIUM_FILTER:
            case PUNISH_TYPE_PHONE_FILTER:
               return "behavior";
            default:
               return "behavior";
         }
      }
      
      private static function punishmentOkButtonHandler(evt:MouseEvent) : void
      {
         var popup:Object = null;
         evt.stopPropagation();
         if(Boolean(_punishPopups) && _punishPopups.length > 0)
         {
            popup = _punishPopups[0];
            popup.destroy();
            _punishPopups.splice(0,1);
            popup = null;
         }
      }
      
      private static function onPunishPopupImgReceived(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _punishPopup.addChild(img);
            _punishPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopupClicked,false,0,true);
            _punishPopupHelper.destroy();
            _punishPopupHelper = null;
         }
      }
      
      private static function onRulesBtnClicked(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(gMainFrame.server.isConnected)
         {
            SBTracker.push();
            SBTracker.trackPageview("game/play/popup/autoBan/rules");
         }
         _isRulesPopupOpen = true;
         GuiManager.displayRulesPopup(true,onRulesXBtnDown);
      }
      
      private static function onPopupClicked(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onRulesXBtnDown(evt:MouseEvent) : void
      {
         SBTracker.pop();
         _isRulesPopupOpen = false;
      }
      
      public static function openPunishPopup(punishType:int, durationInHours:int) : void
      {
         var mc1:MovieClip = null;
         if(_contextualWarningTimer.running)
         {
            _contextualWarningTimer.stop();
         }
         _contextualWarningTimer.delay = 10000;
         gMainFrame.stage.focus = _punishPopup;
         for(var i:int = 0; i < _punishPopup.numChildren; i++)
         {
            if(_punishPopup.getChildAt(i) is MovieClip)
            {
               mc1 = MovieClip(_punishPopup.getChildAt(i));
               break;
            }
         }
         var mc:MovieClip = MovieClip(mc1.getChildAt(0));
         var punishString:String = getWarningFrameLabelString(punishType);
         _guiLayer.addChild(_punishPopup);
         if(mc.currentFrameLabel != punishString)
         {
            mc.gotoAndStop(punishString);
         }
         DarkenManager.darken(_punishPopup);
         if((punishType == PUNISH_TYPE_BAN || punishType == PUNISH_TYPE_SUSPEND) && mc.rulesBtn != null)
         {
            mc.rulesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRulesBtnClicked,false,0,true);
         }
         if(gMainFrame.server.isConnected)
         {
            if(punishString == "accountBan")
            {
               SBTracker.trackPageview("game/play/popup/autoBan",-1,SBTracker.TYPE_EVENT);
            }
            else
            {
               SBTracker.trackPageview("game/play/popup/warning/" + punishString,-1,SBTracker.TYPE_EVENT);
            }
         }
         if(punishType == PUNISH_TYPE_SUSPEND)
         {
            if(durationInHours % 24 == 0)
            {
               LocalizationManager.translateIdAndInsert(mc.messageTxt,18407,durationInHours / 24);
            }
            else
            {
               LocalizationManager.translateIdAndInsert(mc.messageTxt,18409,durationInHours);
            }
            LocalizationManager.translateId(mc.titleTxt,18433);
         }
         else if(punishType == PUNISH_TYPE_BAN)
         {
            LocalizationManager.translateId(mc.messageTxt,18408);
            LocalizationManager.translateId(mc.titleTxt,18432);
         }
         else if(punishType == PUNISH_TYPE_SCAMMING)
         {
            LocalizationManager.translateId(mc.titleTxt,4144);
            LocalizationManager.translateId(mc.messageTxt,4145);
         }
         else if(punishType == PUNISH_TYPE_PII)
         {
            LocalizationManager.translateId(mc.titleTxt,4142);
            LocalizationManager.translateId(mc.messageTxt,4140);
         }
         else if(punishType == PUNISH_TYPE_BULLYING)
         {
            LocalizationManager.translateId(mc.titleTxt,4136);
            LocalizationManager.translateId(mc.messageTxt,4137);
         }
         else if(punishType == PUNISH_TYPE_INAPP_BEHAVIOR)
         {
            LocalizationManager.translateId(mc.titleTxt,4138);
            LocalizationManager.translateId(mc.messageTxt,4141);
         }
         else if(punishType == PUNISH_TYPE_MEDIUM_FILTER || punishType == PUNISH_TYPE_PHONE_FILTER)
         {
            LocalizationManager.translateId(mc.titleTxt,19762);
            LocalizationManager.translateId(mc.messageTxt,19761);
            _contextualWarningTimer.delay = 5000;
         }
         if(_isRulesPopupOpen)
         {
            onRulesBtnClicked(null);
         }
      }
   }
}

