package gui
{
   import achievement.AchievementXtCommManager;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import verification.VerificationXtCommManager;
   
   public class EmailConfirmation
   {
      
      private var _mediaHelper:MediaHelper;
      
      private var _closeCallBack:Function;
      
      private var _emailConfirmPopup:MovieClip;
      
      private var _parentEmailPopup:MovieClip;
      
      private var _emailStsTracking:Object;
      
      private var _emailSts:MovieClip;
      
      private var _emailTxt:TextField;
      
      private var _lastCheckedEmail:String;
      
      private var _delaySuggestionTimer:Timer;
      
      private var _suggestedDomain:String;
      
      private var _displayCodeRedemptionString:Boolean;
      
      public function EmailConfirmation()
      {
         super();
      }
      
      public function init(param1:Function, param2:MovieClip, param3:Boolean = false) : void
      {
         _closeCallBack = param1;
         _displayCodeRedemptionString = param3;
         if(param2 == null)
         {
            DarkenManager.showLoadingSpiral(true);
            _mediaHelper = new MediaHelper();
            _mediaHelper.init(4573,onPopupLoaded);
         }
         else
         {
            onPopupLoaded(param2);
         }
      }
      
      public function destroy(param1:Boolean = true) : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_emailConfirmPopup);
         GuiManager.guiLayer.removeChild(_emailConfirmPopup);
         _emailConfirmPopup = null;
         _parentEmailPopup = null;
         if(_closeCallBack != null)
         {
            _closeCallBack(param1);
            _closeCallBack = null;
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         if(_mediaHelper)
         {
            _mediaHelper.destroy();
         }
         AchievementXtCommManager.requestSetUserVar(428,gMainFrame.clientInfo.jamaaDate);
         _emailConfirmPopup = MovieClip(param1.getChildAt(0));
         _emailConfirmPopup.x = 900 * 0.5;
         _emailConfirmPopup.y = 550 * 0.5;
         _parentEmailPopup = _emailConfirmPopup.parentEmailPopup;
         _parentEmailPopup.visible = false;
         if(_displayCodeRedemptionString)
         {
            LocalizationManager.translateId(_emailConfirmPopup.bodyTxt,24884);
         }
         _emailTxt = _parentEmailPopup.email_txt;
         _emailSts = _parentEmailPopup.email_status;
         _emailStsTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
         _parentEmailPopup.emailCheckPopup.visible = false;
         _parentEmailPopup.resendBtn.activateGrayState(true);
         _delaySuggestionTimer = new Timer(1000,1);
         LocalizationManager.translateIdAndInsert(_emailConfirmPopup.countTitleTxt,6260,gMainFrame.clientInfo.numDaysBeforeExpiring);
         _emailTxt.text = gMainFrame.clientInfo.userEmail;
         emailKeyUpHandler(null);
         GuiManager.guiLayer.addChild(_emailConfirmPopup);
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(_emailConfirmPopup);
         addEventListeners();
      }
      
      private function addEventListeners() : void
      {
         _emailConfirmPopup.addEventListener("mouseDown",onPopup,false,0,true);
         _emailConfirmPopup.bx.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _emailConfirmPopup.okBtn.addEventListener("mouseDown",onCloseBtn,false,0,true);
         _emailConfirmPopup.resendBtn.addEventListener("mouseDown",onResendBtn,false,0,true);
         _parentEmailPopup.resendBtn.addEventListener("mouseDown",onResendBtn,false,0,true);
         _parentEmailPopup.bx.addEventListener("mouseDown",onParentEmailClose,false,0,true);
         _emailTxt.addEventListener("keyUp",emailKeyUpHandler,false,0,true);
         _delaySuggestionTimer.addEventListener("timer",onSuggestionTimer,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _emailConfirmPopup.removeEventListener("mouseDown",onPopup);
         _emailConfirmPopup.bx.removeEventListener("mouseDown",onCloseBtn);
         _emailConfirmPopup.okBtn.removeEventListener("mouseDown",onCloseBtn);
         _emailConfirmPopup.resendBtn.removeEventListener("mouseDown",onResendBtn);
         _parentEmailPopup.resendBtn.removeEventListener("mouseDown",onResendBtn);
         _parentEmailPopup.bx.removeEventListener("mouseDown",onParentEmailClose);
         _emailTxt.removeEventListener("keyUp",emailKeyUpHandler);
         _delaySuggestionTimer.removeEventListener("timer",onSuggestionTimer);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private function onResendBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget == _emailConfirmPopup.resendBtn)
            {
               _parentEmailPopup.visible = true;
               gMainFrame.stage.focus = _emailTxt;
               _emailTxt.setSelection(_emailTxt.length,_emailTxt.length);
            }
            else
            {
               DarkenManager.showLoadingSpiral(true);
               if(_emailTxt.text != gMainFrame.clientInfo.userEmail)
               {
                  VerificationXtCommManager.requestRenameAndResendActivationEmail(_emailTxt.text,onResendComplete);
               }
               else
               {
                  VerificationXtCommManager.requestResendActivationEmail(onResendComplete);
               }
            }
         }
      }
      
      private function onParentEmailClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _parentEmailPopup.visible = false;
      }
      
      private function onSuggestionTimer(param1:TimerEvent) : void
      {
         if(_suggestedDomain != "")
         {
            _parentEmailPopup.emailCheckPopup.visible = true;
            LocalizationManager.translateIdAndInsert(_parentEmailPopup.emailCheckPopup.suggestTxt,11165,_suggestedDomain);
         }
      }
      
      private function emailKeyUpHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Object = null;
         if(_emailTxt.text == "")
         {
            GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
            _emailConfirmPopup.textBar.visible = true;
            _lastCheckedEmail = _emailTxt.text;
            _parentEmailPopup.resendBtn.activateGrayState(true);
            return;
         }
         if(_emailTxt.text != _lastCheckedEmail)
         {
            _emailSts.visible = true;
            _lastCheckedEmail = _emailTxt.text;
            _suggestedDomain = "";
            _loc2_ = !SbiConstants.EMAIL_REGEX.test(_emailTxt.text);
            if(_loc2_)
            {
               GuiStatusIcon.showX(_emailSts,_emailStsTracking);
               _parentEmailPopup.textBar.visible = false;
               _parentEmailPopup.emailCheckPopup.visible = false;
               _parentEmailPopup.resendBtn.activateGrayState(true);
            }
            else
            {
               GuiStatusIcon.showCheck(_emailSts,_emailStsTracking);
               _parentEmailPopup.textBar.visible = true;
               _loc3_ = Utility.checkEmailDomain(_emailTxt.text);
               if(_loc3_.suggestions.length > 0)
               {
                  _suggestedDomain = _loc3_.suggestions[0];
                  _delaySuggestionTimer.reset();
                  _delaySuggestionTimer.start();
               }
               else
               {
                  _parentEmailPopup.emailCheckPopup.visible = false;
               }
               _parentEmailPopup.resendBtn.activateGrayState(false);
            }
         }
      }
      
      private function onResendComplete(param1:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            destroy();
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(22626));
         }
      }
   }
}

