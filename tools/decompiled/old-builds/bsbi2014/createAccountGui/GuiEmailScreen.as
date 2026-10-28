package createAccountGui
{
   import com.sbi.corelib.Utils;
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
   
   public class GuiEmailScreen extends SBScreen
   {
      
      public static const MAX_EMAIL_LENGTH:int = 50;
      
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
      
      private const _emailRegEx:RegExp = new RegExp(/\w/);
      
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
      
      public function GuiEmailScreen(initLogin:Object, initWizard:SBWizard)
      {
         this._login = initLogin;
         this._emailScreen = this._login.accountCreation.registrationPanel.email_popup;
         this._registrationPanel = MovieClip(this._emailScreen.parent);
         super(this._emailScreen,initWizard);
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
         CreateAccountGui.vo4Sound.play();
         if(Boolean(CreateAccountGui.vo4Sound.sc))
         {
            CreateAccountGui.vo4Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVO,false,0,true);
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
         CreateAccountGui.vo4Sound.stop();
         this._voBtn.stop();
         MovieClip(this._emailScreen.parent).gotoAndPlay("backAccountOne");
         CreateAccountGui.currAvatar().gotoAndPlay("backAccountOne");
         MovieClip(this._emailScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backAccountOne");
         return true;
      }
      
      public function leaveToNext() : Boolean
      {
         CreateAccountGui.vo4Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         CreateAccountGui.hideNotifyPopup();
         return this.nextBtnHandler();
      }
      
      public function updateScreenAssets(isCurrentScreen:Boolean = false) : void
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
         if(isCurrentScreen)
         {
            this._emailTxt.addEventListener(KeyboardEvent.KEY_UP,this.emailKeyUpHandler,false,0,true);
            this._emailTxt.addEventListener(FocusEvent.FOCUS_OUT,this.onEmailTxtLoseFocus,false,0,true);
            this._confirmTxt.addEventListener(KeyboardEvent.KEY_UP,this.confirmKeyUpHandler,false,0,true);
            if(Boolean(CreateAccountGui.vo4Sound.sc))
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
      
      public function stopVO(e:Event) : void
      {
         if(Boolean(CreateAccountGui))
         {
            CreateAccountGui.vo4Sound.stop();
         }
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
      }
      
      public function emailValidCallback(error:Boolean, invalidEmail:Boolean, isDomainChecked:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._validationPending = false;
         this._emailSts.visible = true;
         this._domainConfirmed = false;
         if(invalidEmail)
         {
            this._validatedEmail = null;
            GuiStatusIcon.showX(this._emailSts,this._emailStsTracking);
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
            if(!isDomainChecked)
            {
               this._emailKeyUpDelayTimer.reset();
               this._emailKeyUpDelayTimer.start();
            }
            else
            {
               this._emailKeyUpDelayTimer.reset();
            }
         }
         else if(!error)
         {
            if(isDomainChecked)
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
            if(!error && this._emailScreen.currentFrameLabel == "default")
            {
               this._emailScreen.gotoAndStop("confirm");
            }
         }
         this._continueClicked = false;
      }
      
      public function confirmValidCallback(invalidConfirmation:Boolean) : void
      {
         this._confirmSts.visible = true;
         if(invalidConfirmation)
         {
            this._validatedConfirmEmail = null;
            GuiStatusIcon.showX(this._confirmSts,this._confirmStsTracking);
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
         else if(Boolean(this._emailSts["_check"].visible))
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
               this._emailScreen.gotoAndPlay("playRules");
            }
            if(this._continueClicked && this._isCheckBoxChecked)
            {
               this.nextBtnHandler();
            }
         }
         this._continueClicked = false;
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
            this._emailSts.visible = true;
            this._emailBar.visible = false;
         }
      }
      
      private function confirmMarkEmptyAsError() : void
      {
         if(this._confirmTxt.text == "")
         {
            GuiStatusIcon.showX(this._confirmSts,this._confirmStsTracking);
            this._confirmSts.visible = true;
            this._confirmBar.visible = false;
         }
      }
      
      private function emailKeyUpHandler(k:KeyboardEvent) : void
      {
         var splitEmail:Array = null;
         var emailInvalid:Boolean = false;
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
            splitEmail = this._emailTxt.text.split("@");
            if(splitEmail.length > 1 && splitEmail[0].toLowerCase() == this._login.validatedUserName.toLowerCase())
            {
               parentWizard.prev();
               return;
            }
            emailInvalid = Boolean(!this._emailRegEx["exec"](this._emailTxt.text) || this._emailTxt.text.length > MAX_EMAIL_LENGTH);
            this.emailValidCallback(emailInvalid,emailInvalid);
            if(this._confirmTxt.text != "")
            {
               this.confirmKeyUpHandler(null);
            }
         }
      }
      
      private function emailTxtChangeDelayTimerHandler(t:TimerEvent) : void
      {
         this.onEmailTxtLoseFocus(null);
         this._emailKeyUpDelayTimer.reset();
      }
      
      private function onEmailTxtLoseFocus(e:FocusEvent) : void
      {
         var exactDomainMatch:Boolean = false;
         var n:int = 0;
         var nd:int = 0;
         var emailDomain:String = null;
         var suggestions:Array = null;
         var emailDomainAsArray:Array = null;
         var dldist:int = 0;
         var emailInvalid:Boolean = Boolean(!this._emailRegEx["exec"](this._emailTxt.text) || this._emailTxt.text.length > MAX_EMAIL_LENGTH);
         if(!emailInvalid)
         {
            exactDomainMatch = false;
            n = 0;
            nd = int(this._commonDomains.length);
            emailDomain = this._emailTxt.text.substr(this._emailTxt.text.indexOf("@") + 1).toLowerCase();
            while(n < nd)
            {
               if(emailDomain == this._commonDomains[n])
               {
                  exactDomainMatch = true;
                  CreateAccountGui.hideNotifyPopup();
                  this.emailValidCallback(false,false,true);
                  break;
               }
               n++;
            }
            if(!exactDomainMatch)
            {
               suggestions = new Array();
               emailDomainAsArray = emailDomain.split("");
               n = 0;
               while(n < nd)
               {
                  dldist = Utils.damerauLevenshteinDistance(emailDomainAsArray,this._commonDomains[n].split(""),64);
                  if(dldist == 1)
                  {
                     suggestions.push(this._commonDomains[n]);
                  }
                  n++;
               }
               if(suggestions.length > 0)
               {
                  CreateAccountGui.showEmailDomainMisspelledWarning(suggestions);
               }
               else
               {
                  CreateAccountGui.hideNotifyPopup();
               }
               if(!this._domainConfirmed && !this._validationPending)
               {
                  this._validationPending = true;
                  GuiStatusIcon.showWait(this._emailSts,this._emailStsTracking);
                  CreateAccountXtCommManager.sendLoginMXLookup(emailDomain);
               }
            }
         }
      }
      
      private function confirmKeyUpHandler(k:KeyboardEvent) : void
      {
         this._confirmText = this._confirmTxt.text;
         if(this._confirmTxt.text == "")
         {
            GuiStatusIcon.initClipOff(this._confirmSts,this._confirmStsTracking);
            this._validatedConfirmEmail = null;
            return;
         }
         if(k != null)
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
      
      private function voBtnClickHandler(m:MouseEvent) : void
      {
         if(CreateAccountGui.vo4Sound.isPlaying)
         {
            CreateAccountGui.vo4Sound.stop();
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo4Sound.play();
            if(Boolean(CreateAccountGui.vo4Sound.sc))
            {
               CreateAccountGui.vo4Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVO,false,0,true);
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

