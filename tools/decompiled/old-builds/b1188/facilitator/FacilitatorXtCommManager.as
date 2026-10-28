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
      
      private static var _reportPostCallback:Function;
      
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
      
      public static const PUNISH_TYPE_PHONE_FILTER:int = 0;
      
      public static const PUNISH_TYPE_MEDIUM_FILTER:int = 10;
      
      public static const PUNISH_TYPE_SCAMMING:int = 100;
      
      public static const PUNISH_TYPE_PII:int = 110;
      
      public static const PUNISH_TYPE_BULLYING:int = 120;
      
      public static const PUNISH_TYPE_INAPP_BEHAVIOR:int = 130;
      
      private static const CONTEXTUAL_WARNING_POPUP_TIME_MS:int = 10000;
      
      public static const RULE_MEAN:int = 1;
      
      public static const RULE_LANGUAGE:int = 2;
      
      public static const RULE_PERSONAL_INFO:int = 3;
      
      public static const RULE_SECURITY:int = 4;
      
      public static const RULE_BAD_DEN:int = 5;
      
      public static const RULE_SCAMMING:int = 6;
      
      public static const RULE_RELATIONSHIP:int = 7;
      
      public static const RULE_USERNAME:int = 13;
      
      public static const RULE_JAM_A_GRAM:int = 14;
      
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
      
      public static function sendReportAPostRequest(param1:String, param2:int, param3:Function) : void
      {
         _reportPostCallback = param3;
         gMainFrame.server.setXtObject_Str("frp",[param1,param2]);
      }
      
      public static function sendReportAPlayerRequest(param1:String, param2:int, param3:Function) : void
      {
         if(!_reportedPlayers[param1] || gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_QUEST)
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
         var _loc2_:Array = !param1 && AvatarManager.avatarViewList != null && AvatarManager.playerAvatarWorldView != null ? [1,int(AvatarManager.playerAvatarWorldView.x),int(AvatarManager.playerAvatarWorldView.y),AvatarManager.playerAvatarWorldView.lastIdleAnim | (AvatarManager.playerAvatarWorldView.lastIdleFlip ? 2147483648 : 0),0] : [];
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
            case "frp":
               facilitatorReportAPostResponse(_loc2_);
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
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:SBOkPopup = null;
         var _loc2_:String = param1[2];
         if(_loc2_ == "fb")
         {
            if(param1[3] == "1")
            {
               wasUserBanned = true;
               suspensionDuration = int(param1[4]);
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
         else if(_loc2_ == "fs")
         {
            _loc4_ = int(param1[3]);
            if(_loc4_ > 0)
            {
               _loc3_ = LocalizationManager.translateIdAndInsertOnly(11180,_loc4_);
               GuiManager.chatHist.enableFreeChat(false);
            }
            else if(_loc4_ < 0)
            {
               _loc3_ = LocalizationManager.translateIdOnly(11181);
               GuiManager.chatHist.enableFreeChat(false);
            }
            else
            {
               _loc3_ = LocalizationManager.translateIdOnly(11182);
               GuiManager.chatHist.enableFreeChat(true);
            }
            _loc5_ = new SBOkPopup(_guiLayer,_loc3_);
            _punishPopups.unshift(_loc5_);
         }
         else if(_loc2_ == "fk")
         {
            _loc3_ = LocalizationManager.translateIdOnly(11183);
            kickReason = int(param1[3]);
            if(kickReason > 0)
            {
               kickMsg = _loc3_;
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
               _loc3_ = LocalizationManager.translateIdOnly(11134) + param1[3];
               _punishPopups.unshift(new SBOkPopup(_guiLayer,_loc3_));
            }
            else
            {
               _punishPopups.unshift(new SBStandardTitlePopup(_guiLayer,LocalizationManager.translateIdOnly(11135),LocalizationManager.translateIdOnly(11136)));
            }
         }
         else if(_loc2_ == "fw")
         {
            showContextualWarningPopup(param1[3]);
            AvatarManager.setChatBalloonReadyForClear(gMainFrame.server.userId);
         }
         else
         {
            if(!(_loc2_ == "fg" || _loc2_ == "fc"))
            {
               throw new Error("ERROR -- FacilitatorXtCommManager: Invalid cmd=" + _loc2_);
            }
            if(param1[3] == "1")
            {
               _loc9_ = Math.ceil(int(param1[4]) / 3600);
               if(_loc9_ == 1)
               {
                  if(_loc2_ == "fg")
                  {
                     _loc8_ = 18218;
                  }
                  else if(_loc2_ == "fc")
                  {
                     _loc8_ = 18217;
                  }
               }
               else if(_loc9_ < 24)
               {
                  if(_loc2_ == "fg")
                  {
                     _loc8_ = 18219;
                  }
                  else if(_loc2_ == "fc")
                  {
                     _loc8_ = 18399;
                  }
               }
               else
               {
                  _loc9_ = Math.ceil(_loc9_ / 24);
                  if(_loc9_ == 1)
                  {
                     if(_loc2_ == "fg")
                     {
                        _loc8_ = 18400;
                     }
                     else if(_loc2_ == "fc")
                     {
                        _loc8_ = 18402;
                     }
                  }
                  else if(_loc2_ == "fg")
                  {
                     _loc8_ = 18401;
                  }
                  else if(_loc2_ == "fc")
                  {
                     _loc8_ = 18403;
                  }
               }
               if(_loc2_ == "fg")
               {
                  if(Utility.canTrade())
                  {
                     Utility.toggleInteractionBit(SbiConstants.INTERACTION_TYPE_TRADE);
                  }
                  if(Utility.canGift())
                  {
                     Utility.toggleInteractionBit(SbiConstants.INTERACTION_TYPE_GIFT);
                  }
               }
               else if(_loc2_ == "fc")
               {
                  if(gMainFrame.userInfo.sgChatType != ChatHistory.SG_CHAT_TYPE_BUBBLE)
                  {
                     gMainFrame.userInfo.sgChatType = ChatHistory.SG_CHAT_TYPE_BUBBLE;
                  }
               }
               if(_loc8_ != 0)
               {
                  if(RoomXtCommManager.loadingNewRoom || LoadProgress.visible)
                  {
                     RoomManagerWorld.instance.setNeedsToSeeFacilitatorMessage(true,_loc8_,_loc9_);
                  }
                  else
                  {
                     _loc10_ = new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(_loc8_,_loc9_));
                  }
               }
            }
            else if(_loc2_ == "fg")
            {
               if(Utility.canTradeNonDegraded() && !Utility.canTrade())
               {
                  Utility.toggleInteractionBit(SbiConstants.INTERACTION_TYPE_TRADE);
               }
               if(Utility.canGiftNonDegraded() && !Utility.canGift())
               {
                  Utility.toggleInteractionBit(SbiConstants.INTERACTION_TYPE_GIFT);
               }
            }
            else if(_loc2_ == "fc")
            {
               if(gMainFrame.userInfo.sgChatType != gMainFrame.userInfo.sgChatTypeNonDegraded)
               {
                  gMainFrame.userInfo.sgChatType = gMainFrame.userInfo.sgChatTypeNonDegraded;
               }
            }
         }
      }
      
      private static function facilitatorKickResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11184);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11185);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorBanResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11186);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11187);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorMuteResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11188);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11189);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorSilenceResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11190);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11191);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorGrantResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         if(param1[2] == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11192);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11193);
         }
         new SBOkPopup(_guiLayer,_loc2_);
      }
      
      private static function facilitatorPrivateMessageResponse(param1:Array) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = int(param1[2]);
         if(_loc3_ == 1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11194);
         }
         else if(_loc3_ == -1)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11195);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11196);
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
      
      private static function facilitatorReportAPostResponse(param1:Array) : void
      {
         if(_reportPostCallback != null)
         {
            _reportPostCallback(Boolean(param1[2]));
            _reportPostCallback = null;
         }
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
         openPunishPopup(param1,0);
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
      
      public static function openPunishPopup(param1:int, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         if(_contextualWarningTimer.running)
         {
            _contextualWarningTimer.stop();
         }
         _contextualWarningTimer.delay = 10000;
         gMainFrame.stage.focus = _punishPopup;
         var _loc4_:int = 0;
         while(_loc4_ < _punishPopup.numChildren)
         {
            if(_punishPopup.getChildAt(_loc4_) is MovieClip)
            {
               _loc3_ = MovieClip(_punishPopup.getChildAt(_loc4_));
               break;
            }
            _loc4_++;
         }
         var _loc5_:MovieClip = MovieClip(_loc3_.getChildAt(0));
         var _loc6_:String = getWarningFrameLabelString(param1);
         _guiLayer.addChild(_punishPopup);
         if(_loc5_.currentFrameLabel != _loc6_)
         {
            _loc5_.gotoAndStop(_loc6_);
         }
         DarkenManager.darken(_punishPopup);
         if((param1 == PUNISH_TYPE_BAN || param1 == PUNISH_TYPE_SUSPEND) && _loc5_.rulesBtn != null)
         {
            _loc5_.rulesBtn.addEventListener(MouseEvent.MOUSE_DOWN,onRulesBtnClicked,false,0,true);
         }
         if(gMainFrame.server.isConnected)
         {
            if(_loc6_ == "accountBan")
            {
               SBTracker.trackPageview("game/play/popup/autoBan",-1,SBTracker.TYPE_EVENT);
            }
            else
            {
               SBTracker.trackPageview("game/play/popup/warning/" + _loc6_,-1,SBTracker.TYPE_EVENT);
            }
         }
         if(param1 == PUNISH_TYPE_SUSPEND)
         {
            if(param2 % 24 == 0)
            {
               LocalizationManager.translateIdAndInsert(_loc5_.messageTxt,18407,param2 / 24);
            }
            else
            {
               LocalizationManager.translateIdAndInsert(_loc5_.messageTxt,18409,param2);
            }
            LocalizationManager.translateId(_loc5_.titleTxt,18433);
         }
         else if(param1 == PUNISH_TYPE_BAN)
         {
            LocalizationManager.translateId(_loc5_.messageTxt,18408);
            LocalizationManager.translateId(_loc5_.titleTxt,18432);
         }
         else if(param1 == PUNISH_TYPE_SCAMMING)
         {
            LocalizationManager.translateId(_loc5_.titleTxt,4144);
            LocalizationManager.translateId(_loc5_.messageTxt,4145);
         }
         else if(param1 == PUNISH_TYPE_PII)
         {
            LocalizationManager.translateId(_loc5_.titleTxt,4142);
            LocalizationManager.translateId(_loc5_.messageTxt,4140);
         }
         else if(param1 == PUNISH_TYPE_BULLYING)
         {
            LocalizationManager.translateId(_loc5_.titleTxt,4136);
            LocalizationManager.translateId(_loc5_.messageTxt,4137);
         }
         else if(param1 == PUNISH_TYPE_INAPP_BEHAVIOR)
         {
            LocalizationManager.translateId(_loc5_.titleTxt,4138);
            LocalizationManager.translateId(_loc5_.messageTxt,4141);
         }
         else if(param1 == PUNISH_TYPE_MEDIUM_FILTER || param1 == PUNISH_TYPE_PHONE_FILTER)
         {
            LocalizationManager.translateId(_loc5_.titleTxt,19762);
            LocalizationManager.translateId(_loc5_.messageTxt,19761);
            _contextualWarningTimer.delay = 5000;
         }
         if(_isRulesPopupOpen)
         {
            onRulesBtnClicked(null);
         }
      }
   }
}

