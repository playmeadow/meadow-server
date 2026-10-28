package createAccountGui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import createAccountFlow.CreateAccountGui;
   import createAccountFlow.CreateAccountXtCommManager;
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
   import gui.GuiDropdownDay;
   import gui.GuiRadioButtonGroup;
   import gui.GuiSoundBtnSubMenu;
   import gui.GuiStatusIcon;
   
   public class GuiPlayerTagScreen extends SBScreen
   {
      
      public static const NUM_SUGGESTED_NAMES:int = 4;
      
      private var _newBdayMonthDpn:GuiDropdown;
      
      private var _newBdayDayDpn:GuiDropdownDay;
      
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
      
      private var _isEmailSameAsUserName:Boolean;
      
      private var _registrationPanel:MovieClip;
      
      private var _selectedBdayMonthIndex:int;
      
      private var _selectedBdayDayIndex:int;
      
      private var _selectedGender:int;
      
      private var _selectedBdayAgeIndex:int;
      
      private var _hasSelectedBdayAge:Boolean;
      
      private var _passwordText:String;
      
      private var _genderAgeTracking:Object;
      
      private var _userNameTracking:Object;
      
      private var _passWordTracking:Object;
      
      public function GuiPlayerTagScreen(param1:Object, param2:SBWizard)
      {
         this._creation = param1;
         this._creation.accountCreation.registrationPanel.gotoAndStop("intro");
         this._playerTagScreen = this._creation.accountCreation.registrationPanel.userNamePanel.userNameContainer.signup_wizard.act_popup;
         super(this._playerTagScreen,param2);
         this._registrationPanel = MovieClip(this._creation.accountCreation.registrationPanel);
         this._newBdayMonthDpn = new GuiDropdown(this._playerTagScreen.birthday.dropdown_month);
         this._newBdayDayDpn = new GuiDropdownDay(this._playerTagScreen.birthday.dropdown_day);
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
         onEnterFromPrev = this.enterFromPrev;
         onEnterFromNext = this.enterFromNext;
         onLeaveToPrev = this.leaveToPrev;
         onLeaveToNext = this.leaveToNext;
         updateScreen = this.updateScreenAssets;
         this._playerTagScreen.ageGender.visible = false;
         this._playerTagScreen.username.visible = false;
         this._playerTagScreen.password.visible = false;
         this._genderAgeTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         this._userNameTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         this._passWordTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         GuiStatusIcon.initClipOff(this._genderAgeSts,this._genderAgeTracking);
         GuiStatusIcon.initClipOff(this._userNameSts,this._userNameTracking);
         GuiStatusIcon.initClipOff(this._passWordSts,this._passWordTracking);
         this._nameTipPopup.visible = false;
         this._passwordTipPopup.visible = false;
         this._validationPending = false;
         this._continueClicked = false;
         this._lastCheckedPlayerTag = "";
         this._passwordText = "";
         this._selectedBdayMonthIndex = -1;
         this._selectedBdayAgeIndex = 7;
         this._selectedBdayDayIndex = -1;
         this._selectedGender = -1;
         this._newBdayMonthDpn.init(-1.05,0,"-");
         this._newBdayDayDpn.init(0.55,0,"-");
         this._newPlayerAgeDpn.init(0.55,this._selectedBdayAgeIndex,"-");
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
         this._newPasswordTxt.restrict = "^ ";
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
      
      public function enterFromPrev() : void
      {
         this._playerTagScreen.ageGender.visible = true;
         this._playerTagScreen.username.visible = true;
         this._playerTagScreen.password.visible = true;
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
      
      public function enterFromNext() : Boolean
      {
         this.enterFromPrev();
         if(CreateAccountGui.currEmailAddress().split("@")[0].toLowerCase() == this._newUsernameTxt.text.toLowerCase())
         {
            this._isEmailSameAsUserName = true;
            gMainFrame.stage.focus = this._newUsernameTxt;
            CreateAccountGui.showEmailCannotMatchUserName();
            this._nextBtn.visible = false;
            this._newUsernameBar.visible = false;
            GuiStatusIcon.showX(this._userNameSts,this._userNameTracking);
         }
         return true;
      }
      
      public function leaveToNext() : Boolean
      {
         CreateAccountGui.vo3Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
         CreateAccountGui.showTipsPopup(false);
         var _loc1_:Boolean = this._isEmailSameAsUserName;
         var _loc2_:Boolean = this.nextBtnHandler();
         if(_loc1_)
         {
            super.parentWizard.next();
         }
         return _loc2_;
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
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:GuiSoundBtnSubMenu = null;
         this._playerTagScreen = this._registrationPanel.userNamePanel.userNameContainer.signup_wizard.act_popup;
         this._newBdayMonthDpn = new GuiDropdown(this._playerTagScreen.birthday.dropdown_month);
         this._newBdayMonthDpn.init(-1.05,this._selectedBdayMonthIndex,this._selectedBdayMonthIndex == -1 ? "-" : null);
         this._newBdayDayDpn = new GuiDropdownDay(this._playerTagScreen.birthday.dropdown_day);
         this._newBdayDayDpn.init(0.55,this._selectedBdayDayIndex,this._selectedBdayDayIndex == -1 ? "-" : null);
         this._newGenderRbg = new GuiRadioButtonGroup(this._playerTagScreen.ageGender.radioGenderBtn);
         this._newGenderRbg.selected = this._selectedGender;
         this._newPlayerAgeDpn = new GuiDropdown(this._playerTagScreen.ageGender.dropdown_age);
         this._newPlayerAgeDpn.init(0.55,this._selectedBdayAgeIndex,this._hasSelectedBdayAge ? null : "-");
         this._nameSuggestionsFrame = this._playerTagScreen.NamePopup;
         this._newUsernameTxt = this._playerTagScreen.username.pTag_txt;
         this._newUsernameTxt.text = this._lastCheckedPlayerTag ? this._lastCheckedPlayerTag : "";
         this._newUsernameBar = this._playerTagScreen.username.textBar1;
         this._newPasswordTxt = this._playerTagScreen.password.pswd_txt;
         this._newPasswordTxt.text = this._passwordText;
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
         this._playerTagScreen.username.changeBtn.visible = false;
         this._playerTagScreen.ageGender.visible = true;
         this._playerTagScreen.username.visible = true;
         this._playerTagScreen.password.visible = true;
         GuiStatusIcon.setVisBasedOnTrackers(this._genderAgeSts,this._genderAgeTracking);
         GuiStatusIcon.setVisBasedOnTrackers(this._userNameSts,this._userNameTracking);
         GuiStatusIcon.setVisBasedOnTrackers(this._passWordSts,this._passWordTracking);
         this._nameTipPopup.visible = false;
         this._passwordTipPopup.visible = false;
         this._validationPending = false;
         this._continueClicked = false;
         this._nameSuggestionsFrame.visible = false;
         this._activeSelBar1.visible = false;
         this._activeSelBar2.visible = false;
         this._activeSelBar3.visible = false;
         this._activeSelBar4.visible = false;
         if(param1)
         {
            this._newUsernameTxt.restrict = "A-Za-z0-9";
            this._newUsernameTxt.maxChars = 20;
            this._newPasswordTxt.restrict = "^ ";
            this._newPasswordTxt.maxChars = 32;
            this._nameSuggestionsFrame["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.nameSugCloseBtnMouseDownHandler,false,0,true);
            this._nameSugTxts = [];
            _loc2_ = 0;
            while(_loc2_ < NUM_SUGGESTED_NAMES)
            {
               _loc3_ = this._nameSuggestionsFrame["name" + (_loc2_ + 1)];
               this._nameSugTxts[_loc2_] = _loc3_["pTag_txt"];
               TextField(this._nameSugTxts[_loc2_]).text = "ysername" + _loc2_;
               _loc3_.addEventListener(MouseEvent.CLICK,this.nameSugClickHandler,false,0,true);
               _loc2_++;
            }
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
            this._tipsNeedTxt.addEventListener(TextEvent.LINK,this.tipsNeedTxtClickHandler,false,0,true);
            this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
            if(CreateAccountGui.vo3Sound.sc)
            {
               this._voBtn.play();
            }
            else
            {
               this._voBtn.stop();
            }
            this.selBar1FocusHandler(null);
            this._nextBtn.enabled = false;
            if(Boolean(this._userNameSts["_check"].visible) && Boolean(this._passWordSts["_check"].visible))
            {
               this._nextBtn.visible = true;
            }
            else
            {
               this._nextBtn.visible = false;
            }
         }
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
      
      public function userNameValidCallback(param1:int, param2:Array, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:Array = null;
         this._validationPending = false;
         this._userNameSts.visible = true;
         if(param1 == 1)
         {
            GuiStatusIcon.showCheck(this._userNameSts,this._userNameTracking);
            if(this._passWordSts["_check"].visible)
            {
               this._nextBtn.visible = true;
            }
            this._newUsernameBar.visible = true;
            this._nameSuggestionsFrame.visible = false;
            if(this._continueClicked || this._isEmailSameAsUserName)
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
               if(param3 != CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
               {
                  SBTracker.trackPageview("/login/usernameUnavailable/#" + this._numTimesBadUsername,0,SBTracker.TYPE_EVENT);
                  ++this._numTimesBadUsername;
               }
               _loc5_ = [];
               _loc4_ = 3;
               while(_loc4_ < param2.length)
               {
                  if(param2[_loc4_] != null && param2[_loc4_] != "")
                  {
                     _loc5_.push(param2[_loc4_]);
                  }
                  _loc4_++;
               }
               if(_loc5_.length != 0)
               {
                  this._nameSuggestionsFrame.gotoAndStop(_loc5_.length);
                  _loc4_ = 0;
                  while(_loc4_ < _loc5_.length)
                  {
                     TextField(this._nameSugTxts[_loc4_]).text = _loc5_[_loc4_];
                     _loc4_++;
                  }
                  this._nameSuggestionsFrame.visible = true;
               }
               else
               {
                  this._nameSuggestionsFrame.visible = false;
               }
               this._newBdayMonthDpn.closeDropdownSilent();
               this._newBdayDayDpn.closeDropdownSilent();
               this._newPlayerAgeDpn.closeDropdownSilent();
            }
            GuiStatusIcon.showX(this._userNameSts,this._userNameTracking);
            this._nextBtn.visible = false;
            if(this._newUsernameTxt.text == "")
            {
               this._userNameSts.visible = this._userNameTracking.xTracking = this._userNameTracking.waitTracking = this._userNameTracking.checkTracking = false;
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
         if(param1)
         {
            this._passWordSts.visible = true;
            this._passwordText = this._newPasswordTxt.text;
            GuiStatusIcon.showCheck(this._passWordSts,this._passWordTracking);
            this._newPasswordBar.visible = true;
            if(this._userNameSts["_check"].visible)
            {
               this._nextBtn.visible = true;
            }
         }
         else
         {
            GuiStatusIcon.showX(this._passWordSts,this._passWordTracking);
            if(this._newPasswordTxt.text.length == 0)
            {
               this._passWordSts.visible = this._passWordTracking.xTracking = this._passWordTracking.waitTracking = this._passWordTracking.checkTracking = false;
            }
            else
            {
               this._newPasswordBar.visible = false;
            }
            this._passwordText = "";
            this._nextBtn.visible = false;
            this._creation.invalidatePassWord();
         }
      }
      
      private function markEmptyAsError() : void
      {
         if(this._newUsernameTxt.text == "")
         {
            GuiStatusIcon.showX(this._userNameSts,this._userNameTracking);
            this._userNameSts.visible = true;
            this._newUsernameBar.visible = false;
         }
         this.checkPassWord();
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
               this._userNameSts.visible = this._userNameTracking.xTracking = this._userNameTracking.waitTracking = this._userNameTracking.checkTracking = false;
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
               GuiStatusIcon.showWait(this._userNameSts,this._userNameTracking);
               this._userNameKeyUpDelayTimer.start();
            }
         }
      }
      
      private function checkPassWord() : void
      {
         this._creation.validatePassWord(this._newPasswordTxt.text,this._newUsernameTxt.text,this.passWordValidCallback);
      }
      
      private function userNameTxtChangeHandler(param1:Event) : void
      {
         this.checkUserName();
         this.checkPassWord();
         CreateAccountGui.hideNotifyPopup();
      }
      
      private function userNameTxtChangeDelayTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = this._newUsernameTxt.text;
         this._newUsernameTxt.text = _loc2_.substr(0,1) + _loc2_.substr(1).toLowerCase();
         var _loc3_:Array = CreateAccountGui.currEmailAddress().split("@");
         if(_loc3_.length > 1)
         {
            if(_loc3_[0].toLowerCase() != this._newUsernameTxt.text.toLowerCase())
            {
               this._creation.validateUserName(this._newUsernameTxt.text,this._newPasswordTxt.text,0,0,0,this.userNameValidCallback);
            }
            else
            {
               CreateAccountGui.showEmailCannotMatchUserName();
               this._validationPending = false;
               GuiStatusIcon.showX(this._userNameSts,this._userNameTracking);
            }
         }
         else
         {
            this._creation.validateUserName(this._newUsernameTxt.text,this._newPasswordTxt.text,0,0,0,this.userNameValidCallback);
         }
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
         this.checkPassWord();
         this.checkUserName();
      }
      
      private function selBar1FocusHandler(param1:Event) : void
      {
         var _loc2_:Date = null;
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
         if(param1)
         {
            this._selectedBdayMonthIndex = this._newBdayMonthDpn.selectedIdx;
            this._selectedBdayDayIndex = this._newBdayDayDpn.selectedIdx;
            if(this._selectedBdayMonthIndex != -1 && param1.currentTarget == this._playerTagScreen.birthday.dropdown_month)
            {
               _loc2_ = new Date(2013,this._selectedBdayMonthIndex + 1,0);
               this._newBdayDayDpn.updateDaysShown(_loc2_.getDate());
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
         if(param1)
         {
            this._selectedGender = this._newGenderRbg.selected;
            if(!this._hasSelectedBdayAge)
            {
               this._hasSelectedBdayAge = this._newPlayerAgeDpn.dropdownTxt.text != "-";
            }
            this._selectedBdayAgeIndex = this._newPlayerAgeDpn.selectedIdx;
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
         CreateAccountGui.hideNotifyPopup();
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
               this._isEmailSameAsUserName = false;
               return true;
            }
            this.passWordTxtChangeHandler(null);
            this.markEmptyAsError();
            return false;
         }
         this._continueClicked = true;
         this._creation.validateUserName(this._newUsernameTxt.text,this._newPasswordTxt.text,0,0,0,this.userNameValidCallback);
         this.markEmptyAsError();
         return false;
      }
   }
}

