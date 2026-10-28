package createAccountGui
{
   import com.sbi.corelib.Utils;
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
      
      private const _commonDomains:Array = ["yahoo.com","hotmail.com","gmail.com","comcast.net","sbcglobal.net","att.net","msn.com","microsoft.com","aim.com","charter.net","aol.com","cox.net","live.com","live.ca","verizon.net","xtra.co.nz","shaw.ca","bellsouth.net","roadrunner.com","hotmail.co.uk","yahoo.co.uk","optonline.net","centurylink.net","centurytel.net","mail.com","mac.com","google.com","googlemail.com","compuserve.com","myspace.com","facebook.com","youtube.com","netscape.net","emailaccount.com","earthlink.net","rocketmail.com","broadband.com","ymail.com","supermail.com","junkmail.com","mindspring.com","juno.com","prodigy.net","excite.com","frontiernet.net","frontier.com","frontiernet.net","epix.net","love.com","hellokitty.com","sky.com","pacbell.net","champmail.com","heartmail.com","dragon.com","computer.org","digis.net","yahoo.ca","hotmail.ca","googlemail.co.uk","msn.ca","msn.co.uk","microsoft.co.uk","microsoft.ca","aol.co.uk","live.co.uk","compuserve.co.uk","netscape.ca"];
      
      private const _emailRegExOLD:RegExp = new RegExp(/\A([^;:,\(\)\[\]@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i);
      
      private const _emailRegEx:RegExp = new RegExp(/^[\w\-\.]+@([a-zA-Z0-9]+[\.{1}])+[a-zA-Z]{2,}$/i);
      
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
         this._login = param1;
         this._emailScreen = this._login.accountCreation.registrationPanel.email_popup;
         this._registrationPanel = MovieClip(this._emailScreen.parent);
         super(this._emailScreen,param2);
         this._emailTxt = this._emailScreen.emailTxtCont.email_txt;
         this._emailTxt.maxChars = MAX_EMAIL_LENGTH;
         this._confirmTxt = this._emailScreen.confirmTxtCont.confirm_txt;
         this._confirmTxt.maxChars = MAX_EMAIL_LENGTH;
         this._emailBar = this._emailScreen.textBarNew;
         this._confirmBar = this._emailScreen.confirmTextBar;
         this._emailSts = this._emailScreen.emailTxtCont.email_status;
         this._confirmSts = this._emailScreen.confirmTxtCont.confirm_status;
         this._emailStsTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         this._confirmStsTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         this._checkBox = new GuiCheckBox(this._emailScreen.rulesFrame.agree_box,this.onAgreeChecked);
         GuiStatusIcon.initClipOff(this._emailSts,this._emailStsTracking);
         GuiStatusIcon.initClipOff(this._confirmSts,this._confirmStsTracking);
         this._voBtn = this._emailScreen.vo_btn;
         this._playBtn = this._login.accountCreation.play_btn;
         this._nextBtn = this._login.accountCreation.next_btn;
         this._nextBtn.gotoAndStop(1);
         this._isLeavingToPrev = false;
      }
      
      public function init() : void
      {
         onEnterFromPrev = this.enterFromPrev;
         onEnterFromNext = this.enterFromNext;
         onLeaveToPrev = this.leaveToPrev;
         onLeaveToNext = this.leaveToNext;
         onPlay = this.onPlayBtn;
         updateScreen = this.updateScreenAssets;
         this._validationPending = false;
         this._continueClicked = false;
         this._prevConfirmTxt = "";
         this._emailText = "";
         this._confirmText = "";
         this._emailTxt.addEventListener(KeyboardEvent.KEY_UP,this.emailKeyUpHandler,false,0,true);
         this._emailTxt.addEventListener(FocusEvent.FOCUS_OUT,this.onEmailTxtLoseFocus,false,0,true);
         this._confirmTxt.addEventListener(KeyboardEvent.KEY_UP,this.confirmKeyUpHandler,false,0,true);
         this._emailKeyUpDelayTimer = new Timer(1222);
         this._emailKeyUpDelayTimer.addEventListener(TimerEvent.TIMER,this.emailTxtChangeDelayTimerHandler,false,0,true);
         this._voBtn.stop();
         this._voBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.voBtnClickHandler,false,0,true);
      }
      
      override public function destroy() : void
      {
         this._voBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.voBtnClickHandler);
         this._emailKeyUpDelayTimer.stop();
         this._emailKeyUpDelayTimer = null;
         super.destroy();
      }
      
      public function onPlayBtn() : void
      {
         DarkenManager.showLoadingSpiral(true);
         CreateAccountGui.vo5Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         this._login.createNewAccountSetup(CreateAccountGui.currEmailAddress(),CreateAccountGui.emailValidationCallback());
      }
      
      public function enterFromNext() : void
      {
         this._isLeavingToPrev = false;
         if(Boolean(this._emailSts["_check"].visible) && Boolean(this._confirmSts["_check"].visible) && this._isCheckBoxChecked)
         {
            this._playBtn.visible = true;
         }
         else
         {
            this._playBtn.visible = false;
         }
         CreateAccountGui.trackUserCreateAccountPageChange("ParentEmail");
         this._currVo = CreateAccountGui.vo4Sound;
         this._currVo.play();
         if(this._currVo.sc)
         {
            this._currVo.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVO,false,0,true);
            this._voBtn.play();
         }
         this._nextBtn.visible = false;
         CreateAccountGui.hideNotifyPopup();
         this._emailKeyUpDelayTimer.reset();
         this._emailKeyUpDelayTimer.start();
      }
      
      public function enterFromPrev() : void
      {
         this.enterFromNext();
         MovieClip(this._emailScreen.parent).gotoAndPlay("playPlayerAccountTwo");
         CreateAccountGui.currAvatar().gotoAndPlay("playPlayerAccountTwo");
         MovieClip(this._emailScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("playPlayerAccountTwo");
      }
      
      public function enterFromBoth() : void
      {
      }
      
      public function leaveToPrev() : Boolean
      {
         this._isLeavingToPrev = true;
         this._nextBtn.visible = true;
         this._playBtn.visible = false;
         this._currVo.stop();
         this._voBtn.stop();
         MovieClip(this._emailScreen.parent).gotoAndPlay("backAccountOne");
         CreateAccountGui.currAvatar().gotoAndPlay("backAccountOne");
         MovieClip(this._emailScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backAccountOne");
         return true;
      }
      
      public function leaveToNext() : Boolean
      {
         this._currVo.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         CreateAccountGui.hideNotifyPopup();
         return this.nextBtnHandler();
      }
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         this._emailScreen = this._registrationPanel.email_popup;
         this._emailTxt = this._emailScreen.emailTxtCont.email_txt;
         this._emailTxt.maxChars = MAX_EMAIL_LENGTH;
         this._emailTxt.text = this._emailText;
         this._confirmTxt = this._emailScreen.confirmTxtCont.confirm_txt;
         this._confirmTxt.maxChars = MAX_EMAIL_LENGTH;
         this._confirmTxt.text = this._confirmText;
         this._emailBar = this._emailScreen.textBarNew;
         this._confirmBar = this._emailScreen.confirmTextBar;
         this._emailSts = this._emailScreen.emailTxtCont.email_status;
         this._confirmSts = this._emailScreen.confirmTxtCont.confirm_status;
         this._checkBox = new GuiCheckBox(this._emailScreen.rulesFrame.agree_box,this.onAgreeChecked);
         this._checkBox.init(this._emailScreen.rulesFrame.agree_txt);
         this._checkBox.checked = this._isCheckBoxChecked;
         GuiStatusIcon.setVisBasedOnTrackers(this._emailSts,this._emailStsTracking);
         GuiStatusIcon.setVisBasedOnTrackers(this._confirmSts,this._confirmStsTracking);
         this._voBtn = this._emailScreen.vo_btn;
         this._playBtn = this._login.accountCreation.play_btn;
         this._nextBtn = this._login.accountCreation.next_btn;
         this._nextBtn.gotoAndStop(1);
         if(param1)
         {
            this._emailTxt.addEventListener(KeyboardEvent.KEY_UP,this.emailKeyUpHandler,false,0,true);
            this._emailTxt.addEventListener(FocusEvent.FOCUS_OUT,this.onEmailTxtLoseFocus,false,0,true);
            this._confirmTxt.addEventListener(KeyboardEvent.KEY_UP,this.confirmKeyUpHandler,false,0,true);
            if(this._currVo.sc)
            {
               this._voBtn.play();
            }
            else
            {
               this._voBtn.stop();
            }
            this._voBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.voBtnClickHandler,false,0,true);
            if(!this._isLeavingToPrev)
            {
               if(Boolean(this._emailSts["_check"].visible) && Boolean(this._confirmSts["_check"].visible) && this._isCheckBoxChecked)
               {
                  this._playBtn.visible = true;
               }
               else
               {
                  this._playBtn.visible = false;
               }
            }
         }
         else
         {
            this._playBtn.visible = false;
         }
      }
      
      public function get currEmail() : String
      {
         return this._emailTxt.text;
      }
      
      public function stopVO(param1:Event) : void
      {
         if(this._currVo)
         {
            this._currVo.stop();
         }
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
      }
      
      public function emailValidCallback(param1:Boolean, param2:Boolean, param3:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._validationPending = false;
         this._emailSts.visible = true;
         this._domainConfirmed = false;
         if(param2)
         {
            this._validatedEmail = null;
            GuiStatusIcon.showX(this._emailSts,this._emailStsTracking);
            this.resetVoBackToSound4();
            this._playBtn.visible = false;
            if(this._emailTxt.text == "")
            {
               GuiStatusIcon.initClipOff(this._emailSts,this._emailStsTracking);
               this._emailBar.visible = true;
            }
            else
            {
               this._emailBar.visible = false;
            }
            if(!param3)
            {
               this._emailKeyUpDelayTimer.reset();
               this._emailKeyUpDelayTimer.start();
            }
            else
            {
               this._emailKeyUpDelayTimer.reset();
            }
         }
         else if(!param1)
         {
            if(param3)
            {
               GuiStatusIcon.showCheck(this._emailSts,this._emailStsTracking);
               if(this._emailTxt.text == this._confirmTxt.text)
               {
                  this.confirmValidCallback(false);
               }
               if(Boolean(this._confirmSts["_check"].visible) && this._isCheckBoxChecked)
               {
                  this._playBtn.visible = true;
               }
               this._validatedEmail = this._emailTxt.text;
               this._emailKeyUpDelayTimer.reset();
               this._domainConfirmed = true;
            }
            else
            {
               this._emailKeyUpDelayTimer.reset();
               this._emailKeyUpDelayTimer.start();
               GuiStatusIcon.showWait(this._emailSts,this._emailStsTracking);
            }
            this._emailBar.visible = true;
            if(!param1 && this._emailScreen.currentFrameLabel == "default")
            {
               this._emailScreen.gotoAndStop("confirm");
            }
         }
         this._continueClicked = false;
      }
      
      public function confirmValidCallback(param1:Boolean) : void
      {
         this._confirmSts.visible = true;
         if(param1)
         {
            this._validatedConfirmEmail = null;
            GuiStatusIcon.showX(this._confirmSts,this._confirmStsTracking);
            this.resetVoBackToSound4();
            this._playBtn.visible = false;
            if(this._confirmTxt.text == "")
            {
               GuiStatusIcon.initClipOff(this._confirmSts,this._confirmStsTracking);
               this._confirmBar.visible = true;
            }
            else
            {
               this._confirmBar.visible = false;
            }
         }
         else if(this._emailSts["_check"].visible)
         {
            GuiStatusIcon.showCheck(this._confirmSts,this._confirmStsTracking);
            if(this._isCheckBoxChecked)
            {
               this._playBtn.visible = true;
            }
            this._confirmBar.visible = true;
            this._validatedConfirmEmail = this._confirmTxt.text;
            if(this._emailScreen.currentFrameLabel != "rules")
            {
               if(gMainFrame.clientInfo.sessionId % gMainFrame.clientInfo.sbTrackerModulator == 0)
               {
                  this.showSurveyPopup();
                  return;
               }
               this._emailScreen.gotoAndPlay("playRules");
            }
            if(this._continueClicked && this._isCheckBoxChecked)
            {
               this.nextBtnHandler();
            }
            else if(!this._isCheckBoxChecked)
            {
               this.setupRulesVo();
            }
         }
         this._continueClicked = false;
      }
      
      private function setupRulesVo() : void
      {
         if(this._currVo)
         {
            this._currVo.stop();
         }
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         if(CreateAccountGui)
         {
            this._currVo = CreateAccountGui.vo5Sound;
            this._currVo.play();
            if(this._currVo.sc)
            {
               this._currVo.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVO,false,0,true);
               this._voBtn.play();
            }
         }
      }
      
      private function showSurveyPopup() : void
      {
         PollManager.setupNonTabPoll(SURVEY_POLL_DEF_ID,this.onSurveyClose);
      }
      
      private function onSurveyClose() : void
      {
         if(this._emailScreen.currentFrameLabel != "rules")
         {
            this._emailScreen.gotoAndPlay("playRules");
         }
         this.setupRulesVo();
      }
      
      private function onAgreeChecked() : void
      {
         this._isCheckBoxChecked = this._checkBox.checked;
         if(Boolean(this._isCheckBoxChecked) && Boolean(this._emailSts["_check"].visible) && Boolean(this._confirmSts["_check"].visible))
         {
            this._playBtn.visible = true;
         }
         else
         {
            this._playBtn.visible = false;
         }
      }
      
      private function emailMarkEmptyAsError() : void
      {
         if(this._emailTxt.text == "")
         {
            GuiStatusIcon.showX(this._emailSts,this._emailStsTracking);
            this.resetVoBackToSound4();
            this._emailSts.visible = true;
            this._emailBar.visible = false;
         }
      }
      
      private function confirmMarkEmptyAsError() : void
      {
         if(this._confirmTxt.text == "")
         {
            GuiStatusIcon.showX(this._confirmSts,this._confirmStsTracking);
            this.resetVoBackToSound4();
            this._confirmSts.visible = true;
            this._confirmBar.visible = false;
         }
      }
      
      private function resetVoBackToSound4() : void
      {
         if(this._currVo)
         {
            if(this._currVo != CreateAccountGui.vo4Sound)
            {
               this._currVo.stop();
               this._voBtn.stop();
               this._voBtn.gotoAndStop(1);
               this._currVo = CreateAccountGui.vo4Sound;
            }
         }
      }
      
      private function emailKeyUpHandler(param1:KeyboardEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Boolean = false;
         this._emailText = this._emailTxt.text;
         if(this._emailTxt.text == "")
         {
            GuiStatusIcon.initClipOff(this._emailSts,this._emailStsTracking);
            this._emailBar.visible = true;
            this._lastCheckedEmail = this._emailTxt.text;
            this._validatedEmail = null;
            return;
         }
         if(this._emailTxt.text != this._lastCheckedEmail)
         {
            this._validationPending = true;
            this._lastCheckedEmail = this._emailTxt.text;
            _loc2_ = this._emailTxt.text.split("@");
            if(_loc2_.length > 1 && _loc2_[0].toLowerCase() == this._login.validatedUserName.toLowerCase())
            {
               parentWizard.prev();
               return;
            }
            _loc3_ = Boolean(!this._emailRegEx["exec"](this._emailTxt.text) || this._emailTxt.text.length > MAX_EMAIL_LENGTH);
            this.emailValidCallback(_loc3_,_loc3_);
            if(this._confirmTxt.text != "")
            {
               this.confirmKeyUpHandler(null);
            }
         }
      }
      
      private function emailTxtChangeDelayTimerHandler(param1:TimerEvent) : void
      {
         this.onEmailTxtLoseFocus(null);
         this._emailKeyUpDelayTimer.reset();
      }
      
      private function onEmailTxtLoseFocus(param1:FocusEvent) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc2_:Boolean = Boolean(!this._emailRegEx["exec"](this._emailTxt.text) || this._emailTxt.text.length > MAX_EMAIL_LENGTH);
         if(!_loc2_)
         {
            _loc3_ = false;
            _loc4_ = 0;
            _loc5_ = int(this._commonDomains.length);
            _loc6_ = this._emailTxt.text.substr(this._emailTxt.text.indexOf("@") + 1).toLowerCase();
            while(_loc4_ < _loc5_)
            {
               if(_loc6_ == this._commonDomains[_loc4_])
               {
                  _loc3_ = true;
                  CreateAccountGui.hideNotifyPopup();
                  this.emailValidCallback(false,false,true);
                  break;
               }
               _loc4_++;
            }
            if(!_loc3_)
            {
               _loc7_ = new Array();
               _loc8_ = _loc6_.split("");
               _loc4_ = 0;
               while(_loc4_ < _loc5_)
               {
                  _loc9_ = Utils.damerauLevenshteinDistance(_loc8_,this._commonDomains[_loc4_].split(""),64);
                  if(_loc9_ == 1)
                  {
                     _loc7_.push(this._commonDomains[_loc4_]);
                  }
                  _loc4_++;
               }
               if(_loc7_.length > 0)
               {
                  CreateAccountGui.showEmailDomainMisspelledWarning(_loc7_);
               }
               else
               {
                  CreateAccountGui.hideNotifyPopup();
               }
               if(!this._domainConfirmed && !this._validationPending)
               {
                  this._validationPending = true;
                  GuiStatusIcon.showWait(this._emailSts,this._emailStsTracking);
                  CreateAccountXtCommManager.sendLoginMXLookup(_loc6_);
               }
            }
         }
      }
      
      private function confirmKeyUpHandler(param1:KeyboardEvent) : void
      {
         this._confirmText = this._confirmTxt.text;
         if(this._confirmTxt.text == "")
         {
            GuiStatusIcon.initClipOff(this._confirmSts,this._confirmStsTracking);
            this._validatedConfirmEmail = null;
            return;
         }
         if(param1 != null)
         {
            CreateAccountGui.hideNotifyPopup();
         }
         if(this._emailTxt.text == this._confirmTxt.text)
         {
            this.confirmValidCallback(false);
         }
         else
         {
            this.confirmValidCallback(true);
         }
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(this._currVo.isPlaying)
         {
            this._currVo.stop();
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            if(this._currVo == null)
            {
               this._currVo = CreateAccountGui.vo4Sound;
            }
            this._currVo.play();
            if(this._currVo.sc)
            {
               this._currVo.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVO,false,0,true);
               this._voBtn.play();
            }
         }
      }
      
      private function nextBtnHandler() : Boolean
      {
         if(this._validationPending || !this._domainConfirmed || !this._isCheckBoxChecked)
         {
            this._continueClicked = true;
            return false;
         }
         if(this._validatedEmail != null)
         {
            if(this._validatedConfirmEmail != null)
            {
               this.stopVO(null);
               this._continueClicked = true;
               this._validationPending = false;
               this._emailKeyUpDelayTimer.reset();
               return true;
            }
            if(this._confirmTxt.text == "")
            {
               this.confirmMarkEmptyAsError();
            }
            CreateAccountGui.showMustConfirmMsg();
            return false;
         }
         CreateAccountGui.showUsernameExistsMsg(CreateAccountGui.MSG_ID_EMAIL_INVALID,false);
         if(this._emailTxt.text == "")
         {
            this.emailMarkEmptyAsError();
         }
         return false;
      }
   }
}

