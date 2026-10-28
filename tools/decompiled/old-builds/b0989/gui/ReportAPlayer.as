package gui
{
   import com.sbi.popup.SBPopup;
   import facilitator.FacilitatorXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
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
      
      public function init(param1:DisplayLayer, param2:Function = null, param3:Boolean = false, param4:String = null, param5:int = 450, param6:int = 275) : void
      {
         _popupLayer = param1;
         _closeCallback = param2;
         _isFromPlayersCard = param3;
         _playersAvatarUserName = param4;
         _hasReported = false;
         _reasonArray = ["Being a bully!","Bad words!","Inappropriate den!","Personal info!","Safety!","Scamming!","Inappropriate behavior!"];
         if(param3)
         {
            _reportFromCard = new (getDefinitionByName("ReportPopupReportContent") as Class)();
            _reportFromCardPopup = new SBPopup(_popupLayer,new (getDefinitionByName("ReportPopupReportSkin") as Class)(),_reportFromCard,true,true,false,false,true);
            _reportFromCardPopup.x = param5;
            _reportFromCardPopup.y = param6;
            _reportFromCardPopup.bxClosesPopup = false;
            _reportFromCard.reasonTxt.text = "Being a bully!";
            _reportFromCard.titleTxt.text = "Would you like a moderator to review " + _playersAvatarUserName + "?";
            SafeChatManager.buildSafeChatTree(_reportFromCard.reasonChatTree,"ECardTextTreeNode",SafeChatManager.TREE_ECARDTEXT,this.onReasonTextClose,_reasonArray);
            SafeChatManager.closeSafeChat(_reportFromCard.reasonChatTree);
         }
         else
         {
            _report = new (getDefinitionByName("ReportPopupHowToContent2") as Class)();
            _reportPopup = new SBPopup(_popupLayer,new (getDefinitionByName("ReportPopupHowToSkin") as Class)(),_report);
            _reportPopup.x = param5;
            _reportPopup.y = param6;
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
         var _loc2_:String = null;
         if(param1)
         {
            _loc2_ = "Thanks! Your report was sent to a moderator.";
            _hasReported = true;
         }
         else
         {
            _loc2_ = "Your report attempt didn\'t work! Try again.";
         }
         _reportFromCardConfirm = new (getDefinitionByName("ReportPopupReportedContent") as Class)();
         _reportFromCardConfirmPopup = new SBPopup(_popupLayer,new (getDefinitionByName("ReportPopupReportedSkin") as Class)(),_reportFromCardConfirm,true,true,false,false,true);
         _reportFromCardConfirmPopup.x = _reportFromCardPopup.x;
         _reportFromCardConfirmPopup.y = _reportFromCardPopup.y;
         _reportFromCardConfirmPopup.bxClosesPopup = false;
         _reportFromCardConfirm.titleTxt.text = _loc2_;
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

