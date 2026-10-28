package gui
{
   import buddy.BuddyXtCommManager;
   import com.sbi.popup.SBPopup;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class ReportAPlayer
   {
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _closeCallback:Function;
      
      private static var _report:MovieClip;
      
      private static var _reportFromCard:MovieClip;
      
      private static var _reportPopup:SBPopup;
      
      private static var _reportFromCardPopup:SBPopup;
      
      private static var _reportFromCardConfirmPopup:MovieClip;
      
      private static var _isFromPlayersCard:Boolean;
      
      private static var _reportAPlayer:Boolean;
      
      private static var _playersAvatarUserName:String;
      
      private static var _playersModeratedAvatarUserName:String;
      
      private static var _reasonArray:Array;
      
      private static var _hasReported:Boolean;
      
      private static var _reportConfirmMediaHelper:MediaHelper;
      
      private static var _agreeBox:GuiCheckBox;
      
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
      
      public function init(param1:DisplayLayer, param2:Function = null, param3:Boolean = false, param4:String = null, param5:String = null, param6:Boolean = true, param7:int = 450, param8:int = 275) : void
      {
         _popupLayer = param1;
         _closeCallback = param2;
         _isFromPlayersCard = param3;
         _playersAvatarUserName = param4;
         _playersModeratedAvatarUserName = param5;
         _hasReported = false;
         _reportAPlayer = param6;
         _reasonArray = [LocalizationManager.translateIdOnly(11372),LocalizationManager.translateIdOnly(14791),LocalizationManager.translateIdOnly(14792),LocalizationManager.translateIdOnly(14793),LocalizationManager.translateIdOnly(14794),LocalizationManager.translateIdOnly(14795),LocalizationManager.translateIdOnly(15736),LocalizationManager.translateIdOnly(15737),LocalizationManager.translateIdOnly(20088)];
         if(param3)
         {
            _reportFromCard = GETDEFINITIONBYNAME("ReportPopupReportContent");
            _reportFromCardPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupReportSkin"),_reportFromCard,true,true,false,false,true);
            _reportFromCardPopup.x = param7;
            _reportFromCardPopup.y = param8;
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
            _reportPopup.x = param7;
            _reportPopup.y = param8;
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
            if(_agreeBox)
            {
               _agreeBox.destroy();
               _agreeBox = null;
            }
            DarkenManager.unDarken(_reportFromCardConfirmPopup);
            _popupLayer.removeChild(_reportFromCardConfirmPopup);
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
         param1.stopPropagation();
         if(_hasReported && _agreeBox.checked)
         {
            if(!BuddyManager.isBlocked(_playersAvatarUserName))
            {
               BuddyXtCommManager.sendBuddyBlockRequest(_playersAvatarUserName);
            }
         }
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
         if(_reportAPlayer)
         {
            FacilitatorXtCommManager.sendReportAPlayerRequest(_playersAvatarUserName,this.reasonIdForReason(_reportFromCard.reasonTxt.text),this.reportAPlayerResponse);
         }
         else
         {
            FacilitatorXtCommManager.sendReportAPostRequest(_playersAvatarUserName,this.reasonIdForReason(_reportFromCard.reasonTxt.text),this.reportAPlayerResponse);
         }
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
            case _reasonArray[8]:
               return FacilitatorXtCommManager.RULE_JAM_A_GRAM;
            default:
               throw new Error("Reason for reporting is invalid. Reason: " + param1);
         }
      }
      
      private function onNoHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.onClose(param1);
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
         DarkenManager.showLoadingSpiral(true);
         _reportConfirmMediaHelper = new MediaHelper();
         _reportConfirmMediaHelper.init(2694,this.onReportConfirmLoaded,param1);
      }
      
      private function onReportConfirmLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _reportFromCardConfirmPopup = MovieClip(param1.getChildAt(0));
         _reportFromCardConfirmPopup.x = _reportFromCardPopup.x;
         _reportFromCardConfirmPopup.y = _reportFromCardPopup.y;
         if(param1.passback)
         {
            LocalizationManager.translateId(_reportFromCardConfirmPopup.titleTxt,11374);
            _hasReported = true;
         }
         else
         {
            LocalizationManager.translateId(_reportFromCardConfirmPopup.titleTxt,11375);
         }
         _reportFromCardConfirmPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         _agreeBox = new GuiCheckBox(_reportFromCardConfirmPopup.agree_box);
         _agreeBox.init(_reportFromCardConfirmPopup.bodyTxt);
         _agreeBox.checked = true;
         _reportConfirmMediaHelper.destroy();
         _reportConfirmMediaHelper = null;
         _popupLayer.addChild(_reportFromCardConfirmPopup);
         DarkenManager.darken(_reportFromCardConfirmPopup);
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
               _reportFromCardConfirmPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
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

