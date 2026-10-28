package createAccountGui
{
   import com.sbi.corelib.audio.SBSound;
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import createAccountFlow.CreateAccountGui;
   import createAccountFlow.CreateAccountXtCommManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.GuiCheckBox;
   import gui.GuiStatusIcon;
   import gui.PollManager;
   
   public class GuiEmailScreen extends SBScreen
   {
      
      public static const MAX_EMAIL_LENGTH:int = 50;
      
      private static const SURVEY_POLL_DEF_ID:int = 30;
      
      private var _emailTxt:TextField;
      
      private var _confirmTxt:TextField;
      
      private var _emailBar:MovieClip;
      
      private var _confirmBar:MovieClip;
      
      private var _emailSts:MovieClip;
      
      private var _confirmSts:MovieClip;
      
      private var _voBtn:MovieClip;
      
      private var _login:Object;
      
      private var _validationPending:Boolean;
      
      private var _continueClicked:Boolean;
      
      private var _validatedEmail:String;
      
      private var _lastCheckedEmail:String;
      
      private var _validatedConfirmEmail:String;
      
      private var _prevConfirmTxt:String;
      
      private var _emailScreen:MovieClip;
      
      private var _playBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _registrationPanel:MovieClip;
      
      private var _emailText:String;
      
      private var _confirmText:String;
      
      private var _emailStsTracking:Object;
      
      private var _confirmStsTracking:Object;
      
      private var _emailKeyUpDelayTimer:Timer;
      
      private var _domainConfirmed:Boolean;
      
      private var _checkBox:GuiCheckBox;
      
      private var _isCheckBoxChecked:Boolean;
      
      private var _isLeavingToPrev:Boolean;
      
      private var _currVo:SBSound;
      
      public function GuiEmailScreen(param1:Object, param2:SBWizard)
      {
         _login = param1;
         _emailScreen = _login.accountCreation.registrationPanel.email_popup;
         _registrationPanel = MovieClip(_emailScreen.parent);
         super(_emailScreen,param2);
         _emailTxt = _emailScreen.emailTxtCont.email_txt;
         _emailTxt.maxChars = 50;
         _confirmTxt = _emailScreen.confirmTxtCont.confirm_txt;
         _confirmTxt.maxChars = 50;
         _emailBar = _emailScreen.textBarNew;
         _confirmBar = _emailScreen.confirmTextBar;
         _emailSts = _emailScreen.emailTxtCont.email_status;
         _confirmSts = _emailScreen.confirmTxtCont.confirm_status;
         _emailStsTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _confirmStsTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _checkBox = new GuiCheckBox(_emailScreen.rulesFrame.agree_box,onAgreeChecked);
         GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
         GuiStatusIcon.initClipOff(_confirmSts,_confirmStsTracking);
         _voBtn = _emailScreen.vo_btn;
         _playBtn = _login.accountCreation.play_btn;
         _nextBtn = _login.accountCreation.next_btn;
         _nextBtn.gotoAndStop(1);
         _isLeavingToPrev = false;
      }
      
      public function init() : void
      {
         onEnterFromPrev = enterFromPrev;
         onEnterFromNext = enterFromNext;
         onLeaveToPrev = leaveToPrev;
         onLeaveToNext = leaveToNext;
         onPlay = onPlayBtn;
         updateScreen = updateScreenAssets;
         _validationPending = false;
         _continueClicked = false;
         _prevConfirmTxt = "";
         _emailText = "";
         _confirmText = "";
         _emailTxt.addEventListener("keyUp",emailKeyUpHandler,false,0,true);
         _emailTxt.addEventListener("focusOut",onEmailTxtLoseFocus,false,0,true);
         _confirmTxt.addEventListener("keyUp",confirmKeyUpHandler,false,0,true);
         _emailKeyUpDelayTimer = new Timer(1222);
         _emailKeyUpDelayTimer.addEventListener("timer",emailTxtChangeDelayTimerHandler,false,0,true);
         _voBtn.stop();
         _voBtn.addEventListener("mouseDown",voBtnClickHandler,false,0,true);
      }
      
      override public function destroy() : void
      {
         _voBtn.removeEventListener("mouseDown",voBtnClickHandler);
         _emailKeyUpDelayTimer.stop();
         _emailKeyUpDelayTimer = null;
         super.destroy();
      }
      
      public function onPlayBtn() : void
      {
         DarkenManager.showLoadingSpiral(true);
         CreateAccountGui.vo5Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         _login.createNewAccountSetup(CreateAccountGui.currEmailAddress(),CreateAccountGui.emailValidationCallback());
      }
      
      public function enterFromNext() : void
      {
         _isLeavingToPrev = false;
         if(_emailSts["_check"].visible && _confirmSts["_check"].visible && _isCheckBoxChecked)
         {
            _playBtn.visible = true;
         }
         else
         {
            _playBtn.visible = false;
         }
         CreateAccountGui.trackUserCreateAccountPageChange("ParentEmail");
         _currVo = CreateAccountGui.vo4Sound;
         _currVo.play();
         if(_currVo.sc)
         {
            _currVo.sc.addEventListener("soundComplete",stopVO,false,0,true);
            _voBtn.play();
         }
         _nextBtn.visible = false;
         CreateAccountGui.hideNotifyPopup();
         _emailKeyUpDelayTimer.reset();
         _emailKeyUpDelayTimer.start();
      }
      
      public function enterFromPrev() : void
      {
         enterFromNext();
         MovieClip(_emailScreen.parent).gotoAndPlay("playPlayerAccountTwo");
         CreateAccountGui.currAvatar().gotoAndPlay("playPlayerAccountTwo");
         MovieClip(_emailScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("playPlayerAccountTwo");
      }
      
      public function enterFromBoth() : void
      {
      }
      
      public function leaveToPrev() : Boolean
      {
         _isLeavingToPrev = true;
         _nextBtn.visible = true;
         _playBtn.visible = false;
         _currVo.stop();
         _voBtn.stop();
         MovieClip(_emailScreen.parent).gotoAndPlay("backAccountOne");
         CreateAccountGui.currAvatar().gotoAndPlay("backAccountOne");
         MovieClip(_emailScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backAccountOne");
         return true;
      }
      
      public function leaveToNext() : Boolean
      {
         _currVo.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         CreateAccountGui.hideNotifyPopup();
         return nextBtnHandler();
      }
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         _emailScreen = _registrationPanel.email_popup;
         _emailTxt = _emailScreen.emailTxtCont.email_txt;
         _emailTxt.maxChars = 50;
         _emailTxt.text = _emailText;
         _confirmTxt = _emailScreen.confirmTxtCont.confirm_txt;
         _confirmTxt.maxChars = 50;
         _confirmTxt.text = _confirmText;
         _emailBar = _emailScreen.textBarNew;
         _confirmBar = _emailScreen.confirmTextBar;
         _emailSts = _emailScreen.emailTxtCont.email_status;
         _confirmSts = _emailScreen.confirmTxtCont.confirm_status;
         _checkBox = new GuiCheckBox(_emailScreen.rulesFrame.agree_box,onAgreeChecked);
         _checkBox.init(_emailScreen.rulesFrame.agree_txt);
         _checkBox.checked = _isCheckBoxChecked;
         GuiStatusIcon.setVisBasedOnTrackers(_emailSts,_emailStsTracking);
         GuiStatusIcon.setVisBasedOnTrackers(_confirmSts,_confirmStsTracking);
         _voBtn = _emailScreen.vo_btn;
         _playBtn = _login.accountCreation.play_btn;
         _nextBtn = _login.accountCreation.next_btn;
         _nextBtn.gotoAndStop(1);
         if(param1)
         {
            _emailTxt.addEventListener("keyUp",emailKeyUpHandler,false,0,true);
            _emailTxt.addEventListener("focusOut",onEmailTxtLoseFocus,false,0,true);
            _confirmTxt.addEventListener("keyUp",confirmKeyUpHandler,false,0,true);
            if(_currVo.sc)
            {
               _voBtn.play();
            }
            else
            {
               _voBtn.stop();
            }
            _voBtn.addEventListener("mouseDown",voBtnClickHandler,false,0,true);
            if(!_isLeavingToPrev)
            {
               if(_emailSts["_check"].visible && _confirmSts["_check"].visible && _isCheckBoxChecked)
               {
                  _playBtn.visible = true;
               }
               else
               {
                  _playBtn.visible = false;
               }
            }
         }
         else
         {
            _playBtn.visible = false;
         }
      }
      
      public function get currEmail() : String
      {
         return _emailTxt.text;
      }
      
      public function stopVO(param1:Event) : void
      {
         if(_currVo)
         {
            _currVo.stop();
         }
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
      }
      
      public function emailValidCallback(param1:Boolean, param2:Boolean, param3:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _validationPending = false;
         _emailSts.visible = true;
         _domainConfirmed = false;
         if(param2)
         {
            _validatedEmail = null;
            GuiStatusIcon.showX(_emailSts,_emailStsTracking);
            resetVoBackToSound4();
            _playBtn.visible = false;
            if(_emailTxt.text == "")
            {
               GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
               _emailBar.visible = true;
            }
            else
            {
               _emailBar.visible = false;
            }
            if(!param3)
            {
               _emailKeyUpDelayTimer.reset();
               _emailKeyUpDelayTimer.start();
            }
            else
            {
               _emailKeyUpDelayTimer.reset();
            }
         }
         else if(!param1)
         {
            if(param3)
            {
               GuiStatusIcon.showCheck(_emailSts,_emailStsTracking);
               if(_emailTxt.text == _confirmTxt.text)
               {
                  confirmValidCallback(false);
               }
               if(_confirmSts["_check"].visible && _isCheckBoxChecked)
               {
                  _playBtn.visible = true;
               }
               _validatedEmail = _emailTxt.text;
               _emailKeyUpDelayTimer.reset();
               _domainConfirmed = true;
            }
            else
            {
               _emailKeyUpDelayTimer.reset();
               _emailKeyUpDelayTimer.start();
               GuiStatusIcon.showWait(_emailSts,_emailStsTracking);
            }
            _emailBar.visible = true;
            if(!param1 && _emailScreen.currentFrameLabel == "default")
            {
               _emailScreen.gotoAndStop("confirm");
            }
         }
         _continueClicked = false;
      }
      
      public function confirmValidCallback(param1:Boolean) : void
      {
         _confirmSts.visible = true;
         if(param1)
         {
            _validatedConfirmEmail = null;
            GuiStatusIcon.showX(_confirmSts,_confirmStsTracking);
            resetVoBackToSound4();
            _playBtn.visible = false;
            if(_confirmTxt.text == "")
            {
               GuiStatusIcon.initClipOff(_confirmSts,_confirmStsTracking);
               _confirmBar.visible = true;
            }
            else
            {
               _confirmBar.visible = false;
            }
         }
         else if(_emailSts["_check"].visible)
         {
            GuiStatusIcon.showCheck(_confirmSts,_confirmStsTracking);
            if(_isCheckBoxChecked)
            {
               _playBtn.visible = true;
            }
            _confirmBar.visible = true;
            _validatedConfirmEmail = _confirmTxt.text;
            if(_emailScreen.currentFrameLabel != "rules")
            {
               if(gMainFrame.clientInfo.sessionId % gMainFrame.clientInfo.sbTrackerModulator == 0)
               {
                  showSurveyPopup();
                  return;
               }
               _emailScreen.gotoAndPlay("playRules");
            }
            if(_continueClicked && _isCheckBoxChecked)
            {
               nextBtnHandler();
            }
            else if(!_isCheckBoxChecked)
            {
               setupRulesVo();
            }
         }
         _continueClicked = false;
      }
      
      private function setupRulesVo() : void
      {
         if(_currVo)
         {
            _currVo.stop();
         }
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         if(CreateAccountGui)
         {
            _currVo = CreateAccountGui.vo5Sound;
            _currVo.play();
            if(_currVo.sc)
            {
               _currVo.sc.addEventListener("soundComplete",stopVO,false,0,true);
               _voBtn.play();
            }
         }
      }
      
      private function showSurveyPopup() : void
      {
         PollManager.setupNonTabPoll(30,onSurveyClose);
      }
      
      private function onSurveyClose() : void
      {
         if(_emailScreen.currentFrameLabel != "rules")
         {
            _emailScreen.gotoAndPlay("playRules");
         }
         setupRulesVo();
      }
      
      private function onAgreeChecked(param1:GuiCheckBox) : void
      {
         _isCheckBoxChecked = _checkBox.checked;
         if(_isCheckBoxChecked && _emailSts["_check"].visible && _confirmSts["_check"].visible)
         {
            _playBtn.visible = true;
         }
         else
         {
            _playBtn.visible = false;
         }
      }
      
      private function emailMarkEmptyAsError() : void
      {
         if(_emailTxt.text == "")
         {
            GuiStatusIcon.showX(_emailSts,_emailStsTracking);
            resetVoBackToSound4();
            _emailSts.visible = true;
            _emailBar.visible = false;
         }
      }
      
      private function confirmMarkEmptyAsError() : void
      {
         if(_confirmTxt.text == "")
         {
            GuiStatusIcon.showX(_confirmSts,_confirmStsTracking);
            resetVoBackToSound4();
            _confirmSts.visible = true;
            _confirmBar.visible = false;
         }
      }
      
      private function resetVoBackToSound4() : void
      {
         if(_currVo)
         {
            if(_currVo != CreateAccountGui.vo4Sound)
            {
               _currVo.stop();
               _voBtn.stop();
               _voBtn.gotoAndStop(1);
               _currVo = CreateAccountGui.vo4Sound;
            }
         }
      }
      
      private function emailKeyUpHandler(param1:KeyboardEvent) : void
      {
         var _loc3_:Array = null;
         var _loc2_:Boolean = false;
         _emailText = _emailTxt.text;
         if(_emailTxt.text == "")
         {
            GuiStatusIcon.initClipOff(_emailSts,_emailStsTracking);
            _emailBar.visible = true;
            _lastCheckedEmail = _emailTxt.text;
            _validatedEmail = null;
            return;
         }
         if(_emailTxt.text != _lastCheckedEmail)
         {
            _validationPending = true;
            _lastCheckedEmail = _emailTxt.text;
            _loc3_ = _emailTxt.text.split("@");
            if(_loc3_.length > 1 && _loc3_[0].toLowerCase() == _login.validatedUserName.toLowerCase())
            {
               parentWizard.prev();
               return;
            }
            _loc2_ = !SbiConstants.EMAIL_REGEX.test(_emailTxt.text) || _emailTxt.text.length > 50;
            emailValidCallback(_loc2_,_loc2_);
            if(_confirmTxt.text != "")
            {
               confirmKeyUpHandler(null);
            }
         }
      }
      
      private function emailTxtChangeDelayTimerHandler(param1:TimerEvent) : void
      {
         onEmailTxtLoseFocus(null);
         _emailKeyUpDelayTimer.reset();
      }
      
      private function onEmailTxtLoseFocus(param1:FocusEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Boolean = !SbiConstants.EMAIL_REGEX.test(_emailTxt.text) || _emailTxt.text.length > 50;
         if(!_loc3_)
         {
            _loc2_ = Utility.checkEmailDomain(_emailTxt.text);
            if(_loc2_.suggestions.length > 0)
            {
               CreateAccountGui.showEmailDomainMisspelledWarning(_loc2_.suggestions);
            }
            else
            {
               CreateAccountGui.hideNotifyPopup();
            }
            if(!_domainConfirmed && !_validationPending)
            {
               _validationPending = true;
               GuiStatusIcon.showWait(_emailSts,_emailStsTracking);
               CreateAccountXtCommManager.sendLoginMXLookup(_emailTxt.text,!_loc2_.exactMatch);
            }
         }
      }
      
      private function confirmKeyUpHandler(param1:KeyboardEvent) : void
      {
         _confirmText = _confirmTxt.text;
         if(_confirmTxt.text == "")
         {
            GuiStatusIcon.initClipOff(_confirmSts,_confirmStsTracking);
            _validatedConfirmEmail = null;
            return;
         }
         if(param1 != null)
         {
            CreateAccountGui.hideNotifyPopup();
         }
         if(_emailTxt.text == _confirmTxt.text)
         {
            confirmValidCallback(false);
         }
         else
         {
            confirmValidCallback(true);
         }
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(_currVo.isPlaying)
         {
            _currVo.stop();
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         else
         {
            if(_currVo == null)
            {
               _currVo = CreateAccountGui.vo4Sound;
            }
            _currVo.play();
            if(_currVo.sc)
            {
               _currVo.sc.addEventListener("soundComplete",stopVO,false,0,true);
               _voBtn.play();
            }
         }
      }
      
      private function nextBtnHandler() : Boolean
      {
         if(_validationPending || !_domainConfirmed || !_isCheckBoxChecked)
         {
            _continueClicked = true;
            return false;
         }
         if(_validatedEmail != null)
         {
            if(_validatedConfirmEmail != null)
            {
               stopVO(null);
               _continueClicked = true;
               _validationPending = false;
               _emailKeyUpDelayTimer.reset();
               return true;
            }
            if(_confirmTxt.text == "")
            {
               confirmMarkEmptyAsError();
            }
            CreateAccountGui.showMustConfirmMsg();
            return false;
         }
         CreateAccountGui.showUsernameExistsMsg(-8,false);
         if(_emailTxt.text == "")
         {
            emailMarkEmptyAsError();
         }
         return false;
      }
   }
}

