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
      
      public static function initReasonArray(ira:Array) : void
      {
         _reasonArray = ira;
      }
      
      public static function closeReportFromCardPopoup() : void
      {
         if(Boolean(_reportFromCardPopup))
         {
            _reportFromCardPopup.close();
         }
      }
      
      public function init(guiLayer:DisplayLayer, initCloseCallback:Function = null, fromPlayersCard:Boolean = false, playersAvatarUserName:String = null, playersModeratedAvatarUserName:String = null, initPopupX:int = 450, initPopupY:int = 275) : void
      {
         _popupLayer = guiLayer;
         _closeCallback = initCloseCallback;
         _isFromPlayersCard = fromPlayersCard;
         _playersAvatarUserName = playersAvatarUserName;
         _playersModeratedAvatarUserName = playersModeratedAvatarUserName;
         _hasReported = false;
         _reasonArray = [LocalizationManager.translateIdOnly(11372),LocalizationManager.translateIdOnly(14791),LocalizationManager.translateIdOnly(14792),LocalizationManager.translateIdOnly(14793),LocalizationManager.translateIdOnly(14794),LocalizationManager.translateIdOnly(14795),LocalizationManager.translateIdOnly(15736),LocalizationManager.translateIdOnly(15737)];
         if(fromPlayersCard)
         {
            _reportFromCard = GETDEFINITIONBYNAME("ReportPopupReportContent");
            _reportFromCardPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("ReportPopupReportSkin"),_reportFromCard,true,true,false,false,true);
            _reportFromCardPopup.x = initPopupX;
            _reportFromCardPopup.y = initPopupY;
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
            _reportPopup.x = initPopupX;
            _reportPopup.y = initPopupY;
            _reportPopup.bxClosesPopup = false;
         }
         this.addListeners();
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         if(Boolean(_reportFromCardPopup))
         {
            _reportFromCardPopup.destroy();
            _reportFromCardPopup = null;
         }
         if(Boolean(_reportPopup))
         {
            _reportPopup.destroy();
            _reportPopup = null;
         }
         if(Boolean(_reportFromCardConfirmPopup))
         {
            if(Boolean(_agreeBox))
            {
               _agreeBox.destroy();
               _agreeBox = null;
            }
            DarkenManager.unDarken(_reportFromCardConfirmPopup);
            _popupLayer.removeChild(_reportFromCardConfirmPopup);
            _reportFromCardConfirmPopup = null;
         }
         GuiManager.displayRulesPopup(false);
         if(Boolean(_reportFromCard))
         {
            SafeChatManager.destroy(_reportFromCard.reasonChatTree);
         }
         if(Boolean(GuiManager.mainHud.reportBtn))
         {
            GuiManager.mainHud.reportBtn.downToUpState();
         }
         _closeCallback = null;
      }
      
      private function onClose(e:MouseEvent) : void
      {
         e.stopPropagation();
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
      
      private function onReportBtnHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         FacilitatorXtCommManager.sendReportAPlayerRequest(_playersAvatarUserName,this.reasonIdForReason(_reportFromCard.reasonTxt.text),this.reportAPlayerResponse);
         _reportFromCardPopup.close();
      }
      
      private function reasonIdForReason(reason:String) : int
      {
         switch(reason)
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
               throw new Error("Reason for reporting is invalid. Reason: " + reason);
         }
      }
      
      private function onNoHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         this.onClose(null);
      }
      
      private function onReasonHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(!_reportFromCard.reasonChatTree.visible)
         {
            SafeChatManager.openSafeChat(true,_reportFromCard.reasonChatTree);
         }
         else
         {
            SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
         }
      }
      
      private function onReasonTextClose(msg:String, code:String) : void
      {
         _reportFromCard.reasonTxt.text = msg;
         SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
      }
      
      private function onRules(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.displayRulesPopup(true);
      }
      
      private function reportAPlayerResponse(status:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _reportConfirmMediaHelper = new MediaHelper();
         _reportConfirmMediaHelper.init(2694,this.onReportConfirmLoaded,status);
      }
      
      private function onReportConfirmLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _reportFromCardConfirmPopup = MovieClip(img.getChildAt(0));
         _reportFromCardConfirmPopup.x = _reportFromCardPopup.x;
         _reportFromCardConfirmPopup.y = _reportFromCardPopup.y;
         if(Boolean(img.passback))
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
         if(Boolean(_reportPopup))
         {
            return _reportPopup.visible;
         }
         return false;
      }
      
      private function addListeners() : void
      {
         if(_isFromPlayersCard)
         {
            if(Boolean(_reportFromCardPopup))
            {
               _reportFromCardPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
            }
            _reportFromCard.reportBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReportBtnHandler,false,0,true);
            _reportFromCard.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNoHandler,false,0,true);
            _reportFromCard.addTxtBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReasonHandler,false,0,true);
         }
         else
         {
            if(Boolean(_reportPopup))
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
            if(Boolean(_reportFromCardPopup))
            {
               _reportFromCardPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            }
            if(Boolean(_reportFromCardConfirmPopup))
            {
               _reportFromCardConfirmPopup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            }
            _reportFromCard.reportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onReportBtnHandler);
            _reportFromCard.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNoHandler);
            _reportFromCard.addTxtBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onReasonHandler);
         }
         else
         {
            if(Boolean(_reportPopup))
            {
               _reportPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            }
            _report.rulesReportBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRules);
         }
      }
   }
}

