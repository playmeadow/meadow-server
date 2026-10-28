package createAccountGui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import createAccountFlow.CreateAccountGui;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   import gui.GuiDropdown;
   import gui.GuiRadioButtonGroup;
   import gui.GuiSoundBtnSubMenu;
   import gui.GuiStatusIcon;
   
   public class GuiPlayerTagScreen extends SBScreen
   {
      
      public static const NUM_SUGGESTED_NAMES:int = 4;
      
      private var _newBdayMonthDpn:GuiDropdown;
      
      private var _newBdayDayDpn:GuiDropdown;
      
      private var _newGenderRbg:GuiRadioButtonGroup;
      
      private var _newPlayerAgeDpn:GuiDropdown;
      
      private var _nameSuggestionsFrame:MovieClip;
      
      private var _nameSugTxts:Array;
      
      private var _userNameKeyUpDelayTimer:Timer;
      
      private var _newUsernameTxt:TextField;
      
      private var _newUsernameBar:MovieClip;
      
      private var _newPasswordTxt:TextField;
      
      private var _newPasswordBar:MovieClip;
      
      private var _animalFrame:MovieClip;
      
      private var _animalFrameAnimalHolder:MovieClip;
      
      private var _activeSelBar1:MovieClip;
      
      private var _activeSelBar2:MovieClip;
      
      private var _activeSelBar3:MovieClip;
      
      private var _activeSelBar4:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _genderAgeSts:MovieClip;
      
      private var _userNameSts:MovieClip;
      
      private var _passWordSts:MovieClip;
      
      private var _tipsNeedTxt:TextField;
      
      private var _privacyPolicyTxt:TextField;
      
      private var _voBtn:MovieClip;
      
      private var _nameTipPopup:MovieClip;
      
      private var _passwordTipPopup:MovieClip;
      
      private var _creation:Object;
      
      private var _playerTagScreen:MovieClip;
      
      private var _validationPending:Boolean;
      
      private var _lastCheckedPlayerTag:String;
      
      private var _continueClicked:Boolean;
      
      private var _numTimesBadUsername:int;
      
      private var _isExperimental:Boolean;
      
      public function GuiPlayerTagScreen(param1:Object, param2:SBWizard)
      {
         this._creation = param1;
         this._creation.accountCreation.registrationPanel.gotoAndStop("intro");
         this._playerTagScreen = this._creation.accountCreation.registrationPanel.userNamePanel.userNameContainer.signup_wizard.act_popup;
         super(this._playerTagScreen,param2);
         this._newBdayMonthDpn = new GuiDropdown(this._playerTagScreen.birthday.dropdown_month);
         this._newBdayDayDpn = new GuiDropdown(this._playerTagScreen.birthday.dropdown_day);
         this._newGenderRbg = new GuiRadioButtonGroup(this._playerTagScreen.ageGender.radioGenderBtn);
         this._newPlayerAgeDpn = new GuiDropdown(this._playerTagScreen.ageGender.dropdown_age);
         this._nameSuggestionsFrame = this._playerTagScreen.NamePopup;
         this._newUsernameTxt = this._playerTagScreen.username.pTag_txt;
         this._newUsernameBar = this._playerTagScreen.username.textBar1;
         this._newPasswordTxt = this._playerTagScreen.password.pswd_txt;
         this._newPasswordBar = this._playerTagScreen.password.textBar2;
         this._activeSelBar1 = this._playerTagScreen.act_bar_sel1;
         this._activeSelBar2 = this._playerTagScreen.act_bar_sel2;
         this._activeSelBar3 = this._playerTagScreen.username.act_bar_sel3;
         this._activeSelBar4 = this._playerTagScreen.password.act_bar_sel4;
         this._tipsNeedTxt = this._playerTagScreen.tips_help_txt;
         this._privacyPolicyTxt = this._playerTagScreen.pp_txt;
         this._voBtn = this._playerTagScreen.vo_Btn;
         this._backBtn = this._creation.accountCreation.back_btn;
         this._backBtn.gotoAndStop(1);
         this._nextBtn = this._creation.accountCreation.next_btn;
         this._nextBtn.gotoAndStop(1);
         this._genderAgeSts = this._playerTagScreen.ageGender.genderAge_status;
         this._userNameSts = this._playerTagScreen.username.username_status;
         this._passWordSts = this._playerTagScreen.password.pswd_status;
         this._nameTipPopup = this._playerTagScreen.nameTipPopup;
         this._passwordTipPopup = this._playerTagScreen.passwordTipPopup;
      }
      
      public function init() : void
      {
         var _loc2_:GuiSoundBtnSubMenu = null;
         onEnterFromPrev = this.enterFromBoth;
         onEnterFromNext = this.enterFromBoth;
         onLeaveToPrev = this.leaveToPrev;
         onLeaveToNext = this.leaveToNext;
         this._playerTagScreen.ageGender.visible = false;
         this._playerTagScreen.username.visible = false;
         this._playerTagScreen.password.visible = false;
         this._genderAgeSts["_x"].visible = false;
         this._genderAgeSts["_check"].visible = false;
         this._genderAgeSts.visible = false;
         this._userNameSts["_x"].visible = false;
         this._userNameSts["_check"].visible = false;
         this._userNameSts.visible = false;
         this._passWordSts["_x"].visible = false;
         this._passWordSts["_check"].visible = false;
         this._passWordSts.visible = false;
         this._nameTipPopup.visible = false;
         this._passwordTipPopup.visible = false;
         this._validationPending = false;
         this._continueClicked = false;
         this._lastCheckedPlayerTag = this._newUsernameTxt.text;
         this._newBdayMonthDpn.init(-1.05,0,"-");
         this._newBdayDayDpn.init(0.55,0,"-");
         this._newPlayerAgeDpn.init(0.55,6,"-");
         this._nameSuggestionsFrame.visible = false;
         this._nameSuggestionsFrame["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.nameSugCloseBtnMouseDownHandler,false,0,true);
         this._nameSugTxts = [];
         var _loc1_:int = 0;
         while(_loc1_ < NUM_SUGGESTED_NAMES)
         {
            _loc2_ = this._nameSuggestionsFrame["name" + (_loc1_ + 1)];
            this._nameSugTxts[_loc1_] = _loc2_["pTag_txt"];
            TextField(this._nameSugTxts[_loc1_]).text = "ysername" + _loc1_;
            _loc2_.addEventListener(MouseEvent.CLICK,this.nameSugClickHandler,false,0,true);
            _loc1_++;
         }
         this._userNameKeyUpDelayTimer = new Timer(1222);
         this._userNameKeyUpDelayTimer.addEventListener(TimerEvent.TIMER,this.userNameTxtChangeDelayTimerHandler,false,0,true);
         this._newUsernameTxt.restrict = "A-Za-z0-9";
         this._newUsernameTxt.maxChars = 20;
         this._newPasswordTxt.maxChars = 32;
         this._activeSelBar1.visible = false;
         this._activeSelBar2.visible = false;
         this._activeSelBar3.visible = false;
         this._activeSelBar4.visible = false;
         this._newBdayMonthDpn.currDropDown.addEventListener(MouseEvent.MOUSE_DOWN,this.selBar1FocusHandler,false,0,true);
         this._newBdayDayDpn.currDropDown.addEventListener(MouseEvent.MOUSE_DOWN,this.selBar1FocusHandler,false,0,true);
         this._newBdayMonthDpn.currDropDown.addEventListener(FocusEvent.FOCUS_IN,this.selBar1FocusHandler,false,0,true);
         this._newBdayDayDpn.currDropDown.addEventListener(FocusEvent.FOCUS_IN,this.selBar1FocusHandler,false,0,true);
         this._newGenderRbg.currRadioButton.addEventListener(MouseEvent.MOUSE_DOWN,this.selBar2FocusHandler,false,0,true);
         this._newPlayerAgeDpn.currDropDown.addEventListener(MouseEvent.MOUSE_DOWN,this.selBar2FocusHandler,false,0,true);
         this._newPlayerAgeDpn.currDropDown.addEventListener(FocusEvent.FOCUS_IN,this.selBar2FocusHandler,false,0,true);
         this._newUsernameTxt.addEventListener(Event.CHANGE,this.userNameTxtChangeHandler,false,0,true);
         this._newUsernameTxt.addEventListener(MouseEvent.MOUSE_DOWN,this.selBar3FocusHandler,false,0,true);
         this._newUsernameTxt.addEventListener(KeyboardEvent.KEY_DOWN,this.selBar3FocusHandler,false,0,true);
         this._newUsernameTxt.addEventListener(FocusEvent.FOCUS_IN,this.selBar3FocusHandler,false,0,true);
         this._newPasswordTxt.addEventListener(Event.CHANGE,this.passWordTxtChangeHandler,false,0,true);
         this._newPasswordTxt.addEventListener(FocusEvent.FOCUS_IN,this.selBar4FocusHandler,false,0,true);
         this._tipsNeedTxt.htmlText = "<a href=\'event:\'><u>" + this._tipsNeedTxt.text + "</u></a>";
         this._tipsNeedTxt.addEventListener(TextEvent.LINK,this.tipsNeedTxtClickHandler,false,0,true);
         this._privacyPolicyTxt.htmlText = "<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>" + this._privacyPolicyTxt.text + "</u></a>";
         this._voBtn.stop();
         this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
      }
      
      override public function destroy() : void
      {
         this._newBdayMonthDpn.currDropDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.selBar1FocusHandler);
         this._newBdayDayDpn.currDropDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.selBar1FocusHandler);
         this._newBdayMonthDpn.currDropDown.removeEventListener(FocusEvent.FOCUS_IN,this.selBar1FocusHandler);
         this._newBdayDayDpn.currDropDown.removeEventListener(FocusEvent.FOCUS_IN,this.selBar1FocusHandler);
         this._newGenderRbg.currRadioButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.selBar2FocusHandler);
         this._newPlayerAgeDpn.currDropDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.selBar2FocusHandler);
         this._newPlayerAgeDpn.currDropDown.removeEventListener(FocusEvent.FOCUS_IN,this.selBar2FocusHandler);
         this._newUsernameTxt.removeEventListener(Event.CHANGE,this.userNameTxtChangeHandler);
         this._newUsernameTxt.removeEventListener(MouseEvent.MOUSE_DOWN,this.selBar3FocusHandler);
         this._newUsernameTxt.removeEventListener(KeyboardEvent.KEY_DOWN,this.selBar3FocusHandler);
         this._newUsernameTxt.removeEventListener(FocusEvent.FOCUS_IN,this.selBar3FocusHandler);
         this._newPasswordTxt.removeEventListener(Event.CHANGE,this.passWordTxtChangeHandler);
         this._newPasswordTxt.removeEventListener(FocusEvent.FOCUS_IN,this.selBar4FocusHandler);
         this._tipsNeedTxt.removeEventListener(TextEvent.LINK,this.tipsNeedTxtClickHandler);
         this._voBtn.removeEventListener(MouseEvent.CLICK,this.voBtnClickHandler);
         this._newBdayMonthDpn.destroy();
         this._newBdayMonthDpn = null;
         this._newBdayDayDpn.destroy();
         this._newBdayDayDpn = null;
         this._newPlayerAgeDpn.destroy();
         this._newPlayerAgeDpn = null;
         this._newGenderRbg.destroy();
         this._newGenderRbg = null;
         this._nameSuggestionsFrame["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.nameSugCloseBtnMouseDownHandler);
         this._userNameKeyUpDelayTimer.stop();
         this._userNameKeyUpDelayTimer = null;
         super.destroy();
      }
      
      public function enterFromBoth() : void
      {
         this._isExperimental = gMainFrame.clientInfo.sessionId % 2 == 0;
         if(!this._isExperimental)
         {
            this._playerTagScreen.ageGender.visible = true;
            this._playerTagScreen.username.visible = true;
            this._playerTagScreen.password.visible = true;
         }
         this._numTimesBadUsername = 0;
         CreateAccountGui.vo3Sound.play();
         if(CreateAccountGui.vo3Sound.sc)
         {
            CreateAccountGui.vo3Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
            this._voBtn.play();
         }
         CreateAccountGui.trackUserCreateAccountPageChange("CreatePlayerAccount");
         this.selBar1FocusHandler(null);
         this._nextBtn.enabled = false;
         CreateAccountGui.hideNotifyPopup();
         if(Boolean(this._userNameSts["_check"].visible) && Boolean(this._passWordSts["_check"].visible))
         {
            this._nextBtn.visible = true;
         }
         else
         {
            this._nextBtn.visible = false;
         }
      }
      
      public function leaveToNext() : Boolean
      {
         CreateAccountGui.vo3Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         CreateAccountGui.showTipsPopup(false);
         return this.nextBtnHandler();
      }
      
      public function leaveToBoth() : void
      {
      }
      
      public function leaveToPrev() : Boolean
      {
         CreateAccountGui.vo3Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         this._numTimesBadUsername = 0;
         CreateAccountGui.showNewChrPopup();
         CreateAccountGui.showTipsPopup(false);
         this._nextBtn.visible = true;
         return true;
      }
      
      public function stopVOButton(param1:Event) : void
      {
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
      }
      
      public function enableNext() : void
      {
         this._nextBtn.enabled = true;
      }
      
      public function userNameValidCallback(param1:int, param2:Array) : void
      {
         var _loc3_:int = 0;
         this._validationPending = false;
         this._userNameSts.visible = true;
         if(param1 == 1)
         {
            GuiStatusIcon.showCheck(this._userNameSts);
            if(this._isExperimental)
            {
               this._playerTagScreen.password.visible = true;
               SBTracker.trackPageview("/login/experimental/password",0);
            }
            if(this._passWordSts["_check"].visible)
            {
               this._nextBtn.visible = true;
            }
            this._newUsernameBar.visible = true;
            this._nameSuggestionsFrame.visible = false;
            if(this._continueClicked)
            {
               if(this.nextBtnHandler())
               {
                  if(super.parentWizard != null)
                  {
                     super.parentWizard.next();
                  }
               }
            }
         }
         else
         {
            if(param1 == CreateAccountGui.MSG_ID_USERNAME_UNAVAILABLE)
            {
               SBTracker.trackPageview("/login/usernameUnavailable/#" + this._numTimesBadUsername,0);
               ++this._numTimesBadUsername;
               _loc3_ = 3;
               while(_loc3_ < NUM_SUGGESTED_NAMES + 3 && _loc3_ < param2.length)
               {
                  TextField(this._nameSugTxts[_loc3_ - 3]).text = param2[_loc3_];
                  _loc3_++;
               }
               if(param2[4] != "")
               {
                  this._nameSuggestionsFrame.visible = true;
               }
               this._newBdayMonthDpn.closeDropdownSilent();
               this._newBdayDayDpn.closeDropdownSilent();
               this._newPlayerAgeDpn.closeDropdownSilent();
            }
            GuiStatusIcon.showX(this._userNameSts);
            if(this._isExperimental)
            {
               this._playerTagScreen.password.visible = false;
            }
            this._nextBtn.visible = false;
            if(this._newUsernameTxt.text == "")
            {
               this._userNameSts.visible = false;
               this._newUsernameBar.visible = true;
            }
            else
            {
               this._newUsernameBar.visible = false;
            }
         }
         this._continueClicked = false;
      }
      
      public function passWordValidCallback(param1:Boolean) : void
      {
         this._passWordSts.visible = true;
         if(param1)
         {
            GuiStatusIcon.showCheck(this._passWordSts);
            this._newPasswordBar.visible = true;
            if(this._userNameSts["_check"].visible)
            {
               this._nextBtn.visible = true;
            }
         }
         else
         {
            GuiStatusIcon.showX(this._passWordSts);
            this._nextBtn.visible = false;
            if(this._newPasswordTxt.text.length < CreateAccountGui.MIN_PASSWORD_LENGTH)
            {
               this._passWordSts.visible = false;
               this._newPasswordBar.visible = true;
            }
            else
            {
               this._newPasswordBar.visible = false;
            }
         }
      }
      
      private function markEmptyAsError() : void
      {
         if(this._newUsernameTxt.text == "")
         {
            GuiStatusIcon.showX(this._userNameSts);
            if(this._isExperimental)
            {
               this._playerTagScreen.password.visible = false;
            }
            this._userNameSts.visible = true;
            this._newUsernameBar.visible = false;
         }
         if(this._newPasswordTxt.text.length < CreateAccountGui.MIN_PASSWORD_LENGTH)
         {
            if(this._newUsernameTxt.text != "")
            {
               CreateAccountGui.showNewPasswordBadMsg();
            }
            GuiStatusIcon.showX(this._passWordSts);
            this._passWordSts.visible = true;
            this._newPasswordBar.visible = false;
         }
      }
      
      private function checkUserName() : void
      {
         if(this._creation.validatedUserName != this._newUsernameTxt.text)
         {
            if(this._creation.validatedUserName)
            {
               this._creation.invalidateUserName();
            }
            if(this._newUsernameTxt.text == "")
            {
               this._userNameSts.visible = false;
               CreateAccountGui.hideNotifyPopup();
            }
            else if(this._newUsernameTxt.text != this._lastCheckedPlayerTag)
            {
               if(this._validationPending)
               {
                  if(!this._userNameKeyUpDelayTimer.running)
                  {
                     this._creation.invalidatePending();
                  }
                  this._userNameKeyUpDelayTimer.reset();
               }
               this._validationPending = true;
               this._lastCheckedPlayerTag = this._newUsernameTxt.text;
               this._userNameSts.visible = true;
               GuiStatusIcon.showWait(this._userNameSts);
               this._userNameKeyUpDelayTimer.start();
            }
         }
      }
      
      private function checkPassWord() : void
      {
         this._passWordSts.visible = true;
         GuiStatusIcon.showX(this._passWordSts);
         if(this._newPasswordTxt.text.length >= CreateAccountGui.MIN_PASSWORD_LENGTH)
         {
            this._creation.validatePassWord(this._newPasswordTxt.text,this._newUsernameTxt.text,this.passWordValidCallback);
         }
         else
         {
            if(this._newPasswordTxt.text.length == 0)
            {
               this._passWordSts.visible = false;
            }
            this._nextBtn.visible = false;
            this._newPasswordBar.visible = true;
            this._creation.invalidatePassWord();
         }
      }
      
      private function userNameTxtChangeHandler(param1:Event) : void
      {
         this.checkUserName();
         this.checkPassWord();
      }
      
      private function userNameTxtChangeDelayTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = this._newUsernameTxt.text;
         this._newUsernameTxt.text = _loc2_.substr(0,1) + _loc2_.substr(1).toLowerCase();
         this._creation.validateUserName(this._newUsernameTxt.text,this._newPasswordTxt.text,this.userNameValidCallback);
         this._userNameKeyUpDelayTimer.reset();
      }
      
      private function nameSugClickHandler(param1:MouseEvent) : void
      {
         this._newUsernameTxt.text = param1.currentTarget["pTag_txt"].text;
         this.userNameTxtChangeHandler(null);
         this._nameSuggestionsFrame.visible = false;
      }
      
      private function nameSugCloseBtnMouseDownHandler(param1:MouseEvent) : void
      {
         this._nameSuggestionsFrame.visible = false;
      }
      
      private function passWordTxtChangeHandler(param1:Event) : void
      {
         this._lastCheckedPlayerTag = null;
         this.checkPassWord();
         this.checkUserName();
      }
      
      private function selBar1FocusHandler(param1:Event) : void
      {
         if(!this._activeSelBar1.visible)
         {
            this._activeSelBar1.visible = true;
            this._activeSelBar2.visible = false;
            this._activeSelBar3.visible = false;
            this._activeSelBar4.visible = false;
            this._nameSuggestionsFrame.visible = false;
            this._nameTipPopup.visible = false;
            this._passwordTipPopup.visible = false;
            this._newPlayerAgeDpn.closeDropdownSilent();
         }
         if(this._isExperimental)
         {
            if(this._newBdayMonthDpn.dropdownTxt.text != "-" && this._newBdayDayDpn.dropdownTxt.text != "-")
            {
               if(!this._playerTagScreen.ageGender.visible)
               {
                  SBTracker.trackPageview("/login/experimental/ageGender",0);
               }
               this._playerTagScreen.ageGender.visible = true;
            }
         }
      }
      
      private function selBar2FocusHandler(param1:Event) : void
      {
         if(!this._activeSelBar2.visible)
         {
            this._activeSelBar1.visible = false;
            this._activeSelBar2.visible = true;
            this._activeSelBar3.visible = false;
            this._activeSelBar4.visible = false;
            this._nameSuggestionsFrame.visible = false;
            this._nameTipPopup.visible = false;
            this._passwordTipPopup.visible = false;
            this._newBdayMonthDpn.closeDropdownSilent();
            this._newBdayDayDpn.closeDropdownSilent();
         }
         if(this._isExperimental)
         {
            if(this._newGenderRbg.selected > -1 && this._newGenderRbg.selected < 2 && this._newPlayerAgeDpn.dropdownTxt.text != "-")
            {
               if(!this._playerTagScreen.username.visible)
               {
                  SBTracker.trackPageview("/login/experimental/username",0);
               }
               this._playerTagScreen.username.visible = true;
            }
         }
      }
      
      private function selBar3FocusHandler(param1:Event) : void
      {
         if(!this._activeSelBar3.visible)
         {
            this._activeSelBar1.visible = false;
            this._activeSelBar2.visible = false;
            this._activeSelBar3.visible = true;
            this._activeSelBar4.visible = false;
            this._nameTipPopup.visible = true;
            this._passwordTipPopup.visible = false;
            this._nameSuggestionsFrame.visible = false;
            this._newPlayerAgeDpn.closeDropdownSilent();
            this._newBdayMonthDpn.closeDropdownSilent();
            this._newBdayDayDpn.closeDropdownSilent();
         }
      }
      
      private function selBar4FocusHandler(param1:FocusEvent) : void
      {
         if(!this._activeSelBar4.visible)
         {
            this._activeSelBar1.visible = false;
            this._activeSelBar2.visible = false;
            this._activeSelBar3.visible = false;
            this._activeSelBar4.visible = true;
            this._nameSuggestionsFrame.visible = false;
            this._nameTipPopup.visible = false;
            this._passwordTipPopup.visible = true;
            this._newPlayerAgeDpn.closeDropdownSilent();
            this._newBdayMonthDpn.closeDropdownSilent();
            this._newBdayDayDpn.closeDropdownSilent();
         }
      }
      
      private function tipsNeedTxtClickHandler(param1:TextEvent) : void
      {
         param1.preventDefault();
         CreateAccountGui.showTipsPopup(true);
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(CreateAccountGui.vo3Sound.isPlaying)
         {
            CreateAccountGui.vo3Sound.stop();
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo3Sound.play();
            if(CreateAccountGui.vo3Sound.sc)
            {
               CreateAccountGui.vo3Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
      
      private function nextBtnHandler() : Boolean
      {
         if(this._validationPending)
         {
            this._continueClicked = true;
            return false;
         }
         if(this._creation.validatedUserName)
         {
            if(this._creation.validatedPassWord)
            {
               if(this._newPlayerAgeDpn.selectedIdx < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(CreateAccountGui.MSG_ID_AGE_BLANK);
                  return false;
               }
               if(this._newGenderRbg.selected < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(CreateAccountGui.MSG_ID_SEX_BLANK);
                  return false;
               }
               if(this._newBdayDayDpn.selectedIdx < 0 || this._newBdayMonthDpn.selectedIdx < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(CreateAccountGui.MSG_ID_MONTH_OR_DAY_BLANK);
                  return false;
               }
               this._creation.setBirthday(String(this._newBdayMonthDpn.selectedIdx + 1),this._newBdayDayDpn.selectedTxt.text,String(this._newPlayerAgeDpn.selectedIdx));
               this._creation.setGender(this._newGenderRbg.selected);
               this._numTimesBadUsername = 0;
               return true;
            }
            this.passWordTxtChangeHandler(null);
            this.markEmptyAsError();
            return false;
         }
         this._continueClicked = true;
         this._creation.validateUserName(this._newUsernameTxt.text,this.userNameValidCallback);
         this.markEmptyAsError();
         return false;
      }
   }
}

