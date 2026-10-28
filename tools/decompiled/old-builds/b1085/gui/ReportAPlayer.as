package gui
{
   import com.sbi.popup.SBPopup;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class ReportAPlayer
   {
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _closeCallback:Function;
      
      private static var _report:MovieClip;
      
      private static var _reportFromCard:MovieClip;
      
      private static var _reportFromCardConfirm:MovieClip;
      
      private static var _reportPopup:SBPopup;
      
      private static var _reportFromCardPopup:SBPopup;
      
      private static var _reportFromCardConfirmPopup:SBPopup;
      
      private static var _isFromPlayersCard:Boolean;
      
      private static var _playersAvatarUserName:String;
      
      private static var _playersModeratedAvatarUserName:String;
      
      private static var _reasonArray:Array;
      
      private static var _hasReported:Boolean;
      
      public function ReportAPlayer()
      {
         super();
      }
      
      public static function initReasonArray(param1:Array) : void
      {
         _reasonArray = param1;
      }
      
      public static function closeReportFromCardPopoup() : void
      {
         if(_reportFromCardPopup)
         {
            _reportFromCardPopup.close();
         }
      }
      
      public function init(param1:DisplayLayer, param2:Function = null, param3:Boolean = false, param4:String = null, param5:String = null, param6:int = 450, param7:int = 275) : void
      {
         _popupLayer = param1;
         _closeCallback = param2;
         _isFromPlayersCard = param3;
         _playersAvatarUserName = param4;
         _playersModeratedAvatarUserName = param5;
         _hasReported = false;
         _reasonArray = [LocalizationManager.translateIdOnly(11372),LocalizationManager.translateIdOnly(14791),LocalizationManager.translateIdOnly(14792),LocalizationManager.translateIdOnly(14793),LocalizationManager.translateIdOnly(14794),LocalizationManager.translateIdOnly(14795),LocalizationManager.translateIdOnly(15736),LocalizationManager.translateIdOnly(15737)];
         if(param3)
         {
            _reportFromCard = GETDEFINITIONBYNAME("ReportPopupReportContent");
            _reportFromCardPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupReportSkin"),_reportFromCard,true,true,false,false,true);
            _reportFromCardPopup.x = param6;
            _reportFromCardPopup.y = param7;
            _reportFromCardPopup.bxClosesPopup = false;
            LocalizationManager.translateId(_reportFromCard.reasonTxt,11372);
            LocalizationManager.translateIdAndInsert(_reportFromCard.titleTxt,11373,_playersModeratedAvatarUserName);
            SafeChatManager.buildSafeChatTree(_reportFromCard.reasonChatTree,"ECardTextTreeNode",SafeChatManager.TREE_ECARDTEXT,this.onReasonTextClose,_reasonArray);
            SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
         }
         else
         {
            _report = GETDEFINITIONBYNAME("ReportPopupHowToContent2");
            _reportPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupHowToSkin"),_report);
            _reportPopup.x = param6;
            _reportPopup.y = param7;
            _reportPopup.bxClosesPopup = false;
         }
         this.addListeners();
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         if(_reportFromCardPopup)
         {
            _reportFromCardPopup.destroy();
            _reportFromCardPopup = null;
         }
         if(_reportPopup)
         {
            _reportPopup.destroy();
            _reportPopup = null;
         }
         if(_reportFromCardConfirmPopup)
         {
            _reportFromCardConfirmPopup.destroy();
            _reportFromCardConfirmPopup = null;
         }
         GuiManager.displayRulesPopup(false);
         if(_reportFromCard)
         {
            SafeChatManager.destroy(_reportFromCard.reasonChatTree);
         }
         if(GuiManager.mainHud.reportBtn)
         {
            GuiManager.mainHud.reportBtn.downToUpState();
         }
         _closeCallback = null;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(_closeCallback != null)
         {
            _closeCallback(_hasReported);
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onReportBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         FacilitatorXtCommManager.sendReportAPlayerRequest(_playersAvatarUserName,this.reasonIdForReason(_reportFromCard.reasonTxt.text),this.reportAPlayerResponse);
         _reportFromCardPopup.close();
      }
      
      private function reasonIdForReason(param1:String) : int
      {
         switch(param1)
         {
            case _reasonArray[0]:
               return FacilitatorXtCommManager.RULE_MEAN;
            case _reasonArray[1]:
               return FacilitatorXtCommManager.RULE_LANGUAGE;
            case _reasonArray[2]:
               return FacilitatorXtCommManager.RULE_BAD_DEN;
            case _reasonArray[3]:
               return FacilitatorXtCommManager.RULE_PERSONAL_INFO;
            case _reasonArray[4]:
               return FacilitatorXtCommManager.RULE_SECURITY;
            case _reasonArray[5]:
               return FacilitatorXtCommManager.RULE_SCAMMING;
            case _reasonArray[6]:
               return FacilitatorXtCommManager.RULE_RELATIONSHIP;
            case _reasonArray[7]:
               return FacilitatorXtCommManager.RULE_USERNAME;
            default:
               throw new Error("Reason for reporting is invalid. Reason: " + param1);
         }
      }
      
      private function onNoHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.onClose(null);
      }
      
      private function onReasonHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_reportFromCard.reasonChatTree.visible)
         {
            SafeChatManager.openSafeChat(true,_reportFromCard.reasonChatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
         }
      }
      
      private function onReasonTextClose(param1:String, param2:String) : void
      {
         _reportFromCard.reasonTxt.text = param1;
         SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
      }
      
      private function onRules(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.displayRulesPopup(true);
      }
      
      private function reportAPlayerResponse(param1:Boolean) : void
      {
         _reportFromCardConfirm = GETDEFINITIONBYNAME("ReportPopupReportedContent");
         _reportFromCardConfirmPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupReportedSkin"),_reportFromCardConfirm,true,true,false,false,true);
         _reportFromCardConfirmPopup.x = _reportFromCardPopup.x;
         _reportFromCardConfirmPopup.y = _reportFromCardPopup.y;
         _reportFromCardConfirmPopup.bxClosesPopup = false;
         if(param1)
         {
            LocalizationManager.translateId(_reportFromCardConfirm.titleTxt,11374);
            _hasReported = true;
         }
         else
         {
            LocalizationManager.translateId(_reportFromCardConfirm.titleTxt,11375);
         }
         _reportFromCardConfirmPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
      }
      
      public function get visible() : Boolean
      {
         if(_reportPopup)
         {
            return _reportPopup.visible;
         }
         return false;
      }
      
      private function addListeners() : void
      {
         if(_isFromPlayersCard)
         {
            if(_reportFromCardPopup)
            {
               _reportFromCardPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
            }
            _reportFromCard.reportBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReportBtnHandler,false,0,true);
            _reportFromCard.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNoHandler,false,0,true);
            _reportFromCard.addTxtBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReasonHandler,false,0,true);
         }
         else
         {
            if(_reportPopup)
            {
               _reportPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
            }
            _report.rulesReportBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRules,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         if(_isFromPlayersCard)
         {
            if(_reportFromCardPopup)
            {
               _reportFromCardPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            }
            if(_reportFromCardConfirmPopup)
            {
               _reportFromCardConfirmPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            }
            _reportFromCard.reportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onReportBtnHandler);
            _reportFromCard.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNoHandler);
            _reportFromCard.addTxtBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReasonHandler);
         }
         else
         {
            if(_reportPopup)
            {
               _reportPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            }
            _report.rulesReportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRules);
         }
      }
   }
}

