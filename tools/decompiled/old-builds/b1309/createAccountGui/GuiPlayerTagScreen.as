package createAccountGui
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import createAccountFlow.CreateAccountGui;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
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
         _creation = param1;
         _creation.accountCreation.registrationPanel.gotoAndStop("intro");
         _playerTagScreen = _creation.accountCreation.registrationPanel.userNamePanel.userNameContainer.signup_wizard.act_popup;
         super(_playerTagScreen,param2);
         _registrationPanel = MovieClip(_creation.accountCreation.registrationPanel);
         _newBdayMonthDpn = new GuiDropdown(_playerTagScreen.birthday.dropdown_month);
         _newBdayDayDpn = new GuiDropdownDay(_playerTagScreen.birthday.dropdown_day);
         _newGenderRbg = new GuiRadioButtonGroup(_playerTagScreen.ageGender.radioGenderBtn);
         _newPlayerAgeDpn = new GuiDropdown(_playerTagScreen.ageGender.dropdown_age);
         _nameSuggestionsFrame = _playerTagScreen.NamePopup;
         _newUsernameTxt = _playerTagScreen.username.pTag_txt;
         _newUsernameBar = _playerTagScreen.username.textBar1;
         _newPasswordTxt = _playerTagScreen.password.pswd_txt;
         _newPasswordBar = _playerTagScreen.password.textBar2;
         _activeSelBar1 = _playerTagScreen.act_bar_sel1;
         _activeSelBar2 = _playerTagScreen.act_bar_sel2;
         _activeSelBar3 = _playerTagScreen.username.act_bar_sel3;
         _activeSelBar4 = _playerTagScreen.password.act_bar_sel4;
         _tipsNeedTxt = _playerTagScreen.tips_help_txt;
         _privacyPolicyTxt = _playerTagScreen.pp_txt;
         _voBtn = _playerTagScreen.vo_Btn;
         _backBtn = _creation.accountCreation.back_btn;
         _backBtn.gotoAndStop(1);
         _nextBtn = _creation.accountCreation.next_btn;
         _nextBtn.gotoAndStop(1);
         _genderAgeSts = _playerTagScreen.ageGender.genderAge_status;
         _userNameSts = _playerTagScreen.username.username_status;
         _passWordSts = _playerTagScreen.password.pswd_status;
         _nameTipPopup = _playerTagScreen.nameTipPopup;
         _passwordTipPopup = _playerTagScreen.passwordTipPopup;
      }
      
      public function init() : void
      {
         var _loc2_:int = 0;
         var _loc1_:GuiSoundBtnSubMenu = null;
         onEnterFromPrev = enterFromPrev;
         onEnterFromNext = enterFromNext;
         onLeaveToPrev = leaveToPrev;
         onLeaveToNext = leaveToNext;
         updateScreen = updateScreenAssets;
         _playerTagScreen.ageGender.visible = false;
         _playerTagScreen.username.visible = false;
         _playerTagScreen.password.visible = false;
         _genderAgeTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _userNameTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         _passWordTracking = {
            "xTracking":false,
            "waitTracking":false,
            "checkTracking":false
         };
         GuiStatusIcon.initClipOff(_genderAgeSts,_genderAgeTracking);
         GuiStatusIcon.initClipOff(_userNameSts,_userNameTracking);
         GuiStatusIcon.initClipOff(_passWordSts,_passWordTracking);
         _nameTipPopup.visible = false;
         _passwordTipPopup.visible = false;
         _validationPending = false;
         _continueClicked = false;
         _lastCheckedPlayerTag = "";
         _passwordText = "";
         _selectedBdayMonthIndex = -1;
         _selectedBdayAgeIndex = 7;
         _selectedBdayDayIndex = -1;
         _selectedGender = -1;
         _newBdayMonthDpn.init(-1.05,0,"-");
         _newBdayDayDpn.init(0.55,0,"-");
         _newPlayerAgeDpn.init(0.55,_selectedBdayAgeIndex,"-");
         _nameSuggestionsFrame.visible = false;
         _nameSuggestionsFrame["bx"].addEventListener("mouseDown",nameSugCloseBtnMouseDownHandler,false,0,true);
         _nameSugTxts = [];
         _loc2_ = 0;
         while(_loc2_ < 4)
         {
            _loc1_ = _nameSuggestionsFrame["name" + (_loc2_ + 1)];
            _nameSugTxts[_loc2_] = _loc1_["pTag_txt"];
            TextField(_nameSugTxts[_loc2_]).text = "ysername" + _loc2_;
            _loc1_.addEventListener("click",nameSugClickHandler,false,0,true);
            _loc2_++;
         }
         _userNameKeyUpDelayTimer = new Timer(1222);
         _userNameKeyUpDelayTimer.addEventListener("timer",userNameTxtChangeDelayTimerHandler,false,0,true);
         _newUsernameTxt.restrict = Utility.getUsernameRestrictions();
         _newUsernameTxt.maxChars = 20;
         _newPasswordTxt.restrict = "^ ";
         _newPasswordTxt.maxChars = 32;
         _activeSelBar1.visible = false;
         _activeSelBar2.visible = false;
         _activeSelBar3.visible = false;
         _activeSelBar4.visible = false;
         _newBdayMonthDpn.currDropDown.addEventListener("mouseDown",selBar1FocusHandler,false,0,true);
         _newBdayDayDpn.currDropDown.addEventListener("mouseDown",selBar1FocusHandler,false,0,true);
         _newBdayMonthDpn.currDropDown.addEventListener("focusIn",selBar1FocusHandler,false,0,true);
         _newBdayDayDpn.currDropDown.addEventListener("focusIn",selBar1FocusHandler,false,0,true);
         _newGenderRbg.currRadioButton.addEventListener("mouseDown",selBar2FocusHandler,false,0,true);
         _newPlayerAgeDpn.currDropDown.addEventListener("mouseDown",selBar2FocusHandler,false,0,true);
         _newPlayerAgeDpn.currDropDown.addEventListener("focusIn",selBar2FocusHandler,false,0,true);
         _newUsernameTxt.addEventListener("change",userNameTxtChangeHandler,false,0,true);
         _newUsernameTxt.addEventListener("mouseDown",selBar3FocusHandler,false,0,true);
         _newUsernameTxt.addEventListener("keyDown",selBar3FocusHandler,false,0,true);
         _newUsernameTxt.addEventListener("focusIn",selBar3FocusHandler,false,0,true);
         _newPasswordTxt.addEventListener("change",passWordTxtChangeHandler,false,0,true);
         _newPasswordTxt.addEventListener("focusIn",selBar4FocusHandler,false,0,true);
         _tipsNeedTxt.htmlText = "<a href=\'event:\'><u>" + _tipsNeedTxt.text + "</u></a>";
         _tipsNeedTxt.addEventListener("link",tipsNeedTxtClickHandler,false,0,true);
         _privacyPolicyTxt.htmlText = "<a href=\'http://www.animaljam.com/privacy\' target=\'_blank\'><u>" + _privacyPolicyTxt.text + "</u></a>";
         _voBtn.stop();
         _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
      }
      
      override public function destroy() : void
      {
         _newBdayMonthDpn.currDropDown.removeEventListener("mouseDown",selBar1FocusHandler);
         _newBdayDayDpn.currDropDown.removeEventListener("mouseDown",selBar1FocusHandler);
         _newBdayMonthDpn.currDropDown.removeEventListener("focusIn",selBar1FocusHandler);
         _newBdayDayDpn.currDropDown.removeEventListener("focusIn",selBar1FocusHandler);
         _newGenderRbg.currRadioButton.removeEventListener("mouseDown",selBar2FocusHandler);
         _newPlayerAgeDpn.currDropDown.removeEventListener("mouseDown",selBar2FocusHandler);
         _newPlayerAgeDpn.currDropDown.removeEventListener("focusIn",selBar2FocusHandler);
         _newUsernameTxt.removeEventListener("change",userNameTxtChangeHandler);
         _newUsernameTxt.removeEventListener("mouseDown",selBar3FocusHandler);
         _newUsernameTxt.removeEventListener("keyDown",selBar3FocusHandler);
         _newUsernameTxt.removeEventListener("focusIn",selBar3FocusHandler);
         _newPasswordTxt.removeEventListener("change",passWordTxtChangeHandler);
         _newPasswordTxt.removeEventListener("focusIn",selBar4FocusHandler);
         _tipsNeedTxt.removeEventListener("link",tipsNeedTxtClickHandler);
         _voBtn.removeEventListener("click",voBtnClickHandler);
         _newBdayMonthDpn.destroy();
         _newBdayMonthDpn = null;
         _newBdayDayDpn.destroy();
         _newBdayDayDpn = null;
         _newPlayerAgeDpn.destroy();
         _newPlayerAgeDpn = null;
         _newGenderRbg.destroy();
         _newGenderRbg = null;
         _nameSuggestionsFrame["bx"].removeEventListener("mouseDown",nameSugCloseBtnMouseDownHandler);
         _userNameKeyUpDelayTimer.stop();
         _userNameKeyUpDelayTimer = null;
         super.destroy();
      }
      
      public function enterFromPrev() : void
      {
         _playerTagScreen.ageGender.visible = true;
         _playerTagScreen.username.visible = true;
         _playerTagScreen.password.visible = true;
         _numTimesBadUsername = 0;
         CreateAccountGui.vo3Sound.play();
         if(CreateAccountGui.vo3Sound.sc)
         {
            CreateAccountGui.vo3Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
            _voBtn.play();
         }
         CreateAccountGui.trackUserCreateAccountPageChange("CreatePlayerAccount");
         selBar1FocusHandler(null);
         _nextBtn.enabled = false;
         CreateAccountGui.hideNotifyPopup();
         if(_userNameSts["_check"].visible && _passWordSts["_check"].visible)
         {
            _nextBtn.visible = true;
         }
         else
         {
            _nextBtn.visible = false;
         }
      }
      
      public function enterFromNext() : Boolean
      {
         enterFromPrev();
         if(CreateAccountGui.currEmailAddress().split("@")[0].toLowerCase() == _newUsernameTxt.text.toLowerCase())
         {
            _isEmailSameAsUserName = true;
            gMainFrame.stage.focus = _newUsernameTxt;
            CreateAccountGui.showEmailCannotMatchUserName();
            _nextBtn.visible = false;
            _newUsernameBar.visible = false;
            GuiStatusIcon.showX(_userNameSts,_userNameTracking);
         }
         return true;
      }
      
      public function leaveToNext() : Boolean
      {
         CreateAccountGui.vo3Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         CreateAccountGui.showTipsPopup(false);
         var _loc1_:Boolean = _isEmailSameAsUserName;
         var _loc2_:Boolean = nextBtnHandler();
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
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
         _numTimesBadUsername = 0;
         CreateAccountGui.showNewChrPopup();
         CreateAccountGui.showTipsPopup(false);
         _nextBtn.visible = true;
         return true;
      }
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc2_:GuiSoundBtnSubMenu = null;
         _playerTagScreen = _registrationPanel.userNamePanel.userNameContainer.signup_wizard.act_popup;
         _newBdayMonthDpn = new GuiDropdown(_playerTagScreen.birthday.dropdown_month);
         _newBdayMonthDpn.init(-1.05,_selectedBdayMonthIndex,_selectedBdayMonthIndex == -1 ? "-" : null);
         _newBdayDayDpn = new GuiDropdownDay(_playerTagScreen.birthday.dropdown_day);
         _newBdayDayDpn.init(0.55,_selectedBdayDayIndex,_selectedBdayDayIndex == -1 ? "-" : null);
         _newGenderRbg = new GuiRadioButtonGroup(_playerTagScreen.ageGender.radioGenderBtn);
         _newGenderRbg.selected = _selectedGender;
         _newPlayerAgeDpn = new GuiDropdown(_playerTagScreen.ageGender.dropdown_age);
         _newPlayerAgeDpn.init(0.55,_selectedBdayAgeIndex,_hasSelectedBdayAge ? null : "-");
         _nameSuggestionsFrame = _playerTagScreen.NamePopup;
         _newUsernameTxt = _playerTagScreen.username.pTag_txt;
         _newUsernameTxt.text = _lastCheckedPlayerTag ? _lastCheckedPlayerTag : "";
         _newUsernameBar = _playerTagScreen.username.textBar1;
         _newPasswordTxt = _playerTagScreen.password.pswd_txt;
         _newPasswordTxt.text = _passwordText;
         _newPasswordBar = _playerTagScreen.password.textBar2;
         _activeSelBar1 = _playerTagScreen.act_bar_sel1;
         _activeSelBar2 = _playerTagScreen.act_bar_sel2;
         _activeSelBar3 = _playerTagScreen.username.act_bar_sel3;
         _activeSelBar4 = _playerTagScreen.password.act_bar_sel4;
         _tipsNeedTxt = _playerTagScreen.tips_help_txt;
         _privacyPolicyTxt = _playerTagScreen.pp_txt;
         _voBtn = _playerTagScreen.vo_Btn;
         _backBtn = _creation.accountCreation.back_btn;
         _backBtn.gotoAndStop(1);
         _nextBtn = _creation.accountCreation.next_btn;
         _nextBtn.gotoAndStop(1);
         _genderAgeSts = _playerTagScreen.ageGender.genderAge_status;
         _userNameSts = _playerTagScreen.username.username_status;
         _passWordSts = _playerTagScreen.password.pswd_status;
         _nameTipPopup = _playerTagScreen.nameTipPopup;
         _passwordTipPopup = _playerTagScreen.passwordTipPopup;
         _playerTagScreen.username.changeBtn.visible = false;
         _playerTagScreen.ageGender.visible = true;
         _playerTagScreen.username.visible = true;
         _playerTagScreen.password.visible = true;
         GuiStatusIcon.setVisBasedOnTrackers(_genderAgeSts,_genderAgeTracking);
         GuiStatusIcon.setVisBasedOnTrackers(_userNameSts,_userNameTracking);
         GuiStatusIcon.setVisBasedOnTrackers(_passWordSts,_passWordTracking);
         _nameTipPopup.visible = false;
         _passwordTipPopup.visible = false;
         _validationPending = false;
         _continueClicked = false;
         _nameSuggestionsFrame.visible = false;
         _activeSelBar1.visible = false;
         _activeSelBar2.visible = false;
         _activeSelBar3.visible = false;
         _activeSelBar4.visible = false;
         if(param1)
         {
            _newUsernameTxt.restrict = Utility.getUsernameRestrictions();
            _newUsernameTxt.maxChars = 20;
            _newPasswordTxt.restrict = "^ ";
            _newPasswordTxt.maxChars = 32;
            _nameSuggestionsFrame["bx"].addEventListener("mouseDown",nameSugCloseBtnMouseDownHandler,false,0,true);
            _nameSugTxts = [];
            _loc3_ = 0;
            while(_loc3_ < 4)
            {
               _loc2_ = _nameSuggestionsFrame["name" + (_loc3_ + 1)];
               _nameSugTxts[_loc3_] = _loc2_["pTag_txt"];
               TextField(_nameSugTxts[_loc3_]).text = "ysername" + _loc3_;
               _loc2_.addEventListener("click",nameSugClickHandler,false,0,true);
               _loc3_++;
            }
            _newBdayMonthDpn.currDropDown.addEventListener("mouseDown",selBar1FocusHandler,false,0,true);
            _newBdayDayDpn.currDropDown.addEventListener("mouseDown",selBar1FocusHandler,false,0,true);
            _newBdayMonthDpn.currDropDown.addEventListener("focusIn",selBar1FocusHandler,false,0,true);
            _newBdayDayDpn.currDropDown.addEventListener("focusIn",selBar1FocusHandler,false,0,true);
            _newGenderRbg.currRadioButton.addEventListener("mouseDown",selBar2FocusHandler,false,0,true);
            _newPlayerAgeDpn.currDropDown.addEventListener("mouseDown",selBar2FocusHandler,false,0,true);
            _newPlayerAgeDpn.currDropDown.addEventListener("focusIn",selBar2FocusHandler,false,0,true);
            _newUsernameTxt.addEventListener("change",userNameTxtChangeHandler,false,0,true);
            _newUsernameTxt.addEventListener("mouseDown",selBar3FocusHandler,false,0,true);
            _newUsernameTxt.addEventListener("keyDown",selBar3FocusHandler,false,0,true);
            _newUsernameTxt.addEventListener("focusIn",selBar3FocusHandler,false,0,true);
            _newPasswordTxt.addEventListener("change",passWordTxtChangeHandler,false,0,true);
            _newPasswordTxt.addEventListener("focusIn",selBar4FocusHandler,false,0,true);
            _tipsNeedTxt.addEventListener("link",tipsNeedTxtClickHandler,false,0,true);
            _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
            if(CreateAccountGui.vo3Sound.sc)
            {
               _voBtn.play();
            }
            else
            {
               _voBtn.stop();
            }
            selBar1FocusHandler(null);
            _nextBtn.enabled = false;
            if(_userNameSts["_check"].visible && _passWordSts["_check"].visible)
            {
               _nextBtn.visible = true;
            }
            else
            {
               _nextBtn.visible = false;
            }
         }
      }
      
      public function stopVOButton(param1:Event) : void
      {
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
      }
      
      public function enableNext() : void
      {
         _nextBtn.enabled = true;
      }
      
      public function userNameValidCallback(param1:int, param2:Array, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc4_:Array = null;
         _validationPending = false;
         _userNameSts.visible = true;
         if(param1 == 1)
         {
            GuiStatusIcon.showCheck(_userNameSts,_userNameTracking);
            if(_passWordSts["_check"].visible)
            {
               _nextBtn.visible = true;
            }
            _newUsernameBar.visible = true;
            _nameSuggestionsFrame.visible = false;
            if(_continueClicked || _isEmailSameAsUserName)
            {
               if(nextBtnHandler())
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
            if(param1 == -3)
            {
               if(param3 != 2)
               {
                  SBTracker.trackPageview("/login/usernameUnavailable/#" + _numTimesBadUsername,0,1);
                  _numTimesBadUsername = _numTimesBadUsername + 1;
               }
               _loc4_ = [];
               _loc5_ = 3;
               while(_loc5_ < param2.length)
               {
                  if(param2[_loc5_] != null && param2[_loc5_] != "")
                  {
                     _loc4_.push(param2[_loc5_]);
                  }
                  _loc5_++;
               }
               if(_loc4_.length != 0)
               {
                  _nameSuggestionsFrame.gotoAndStop(_loc4_.length);
                  _loc5_ = 0;
                  while(_loc5_ < _loc4_.length)
                  {
                     TextField(_nameSugTxts[_loc5_]).text = _loc4_[_loc5_];
                     _loc5_++;
                  }
                  _nameSuggestionsFrame.visible = true;
               }
               else
               {
                  _nameSuggestionsFrame.visible = false;
               }
               _newBdayMonthDpn.closeDropdownSilent();
               _newBdayDayDpn.closeDropdownSilent();
               _newPlayerAgeDpn.closeDropdownSilent();
            }
            GuiStatusIcon.showX(_userNameSts,_userNameTracking);
            _nextBtn.visible = false;
            if(_newUsernameTxt.text == "")
            {
               _userNameSts.visible = _userNameTracking.xTracking = _userNameTracking.waitTracking = _userNameTracking.checkTracking = false;
               _newUsernameBar.visible = true;
            }
            else
            {
               _newUsernameBar.visible = false;
            }
         }
         _continueClicked = false;
      }
      
      public function passWordValidCallback(param1:Boolean) : void
      {
         if(param1)
         {
            _passWordSts.visible = true;
            _passwordText = _newPasswordTxt.text;
            GuiStatusIcon.showCheck(_passWordSts,_passWordTracking);
            _newPasswordBar.visible = true;
            if(_userNameSts["_check"].visible)
            {
               _nextBtn.visible = true;
            }
         }
         else
         {
            GuiStatusIcon.showX(_passWordSts,_passWordTracking);
            if(_newPasswordTxt.text.length == 0)
            {
               _passWordSts.visible = _passWordTracking.xTracking = _passWordTracking.waitTracking = _passWordTracking.checkTracking = false;
            }
            else
            {
               _newPasswordBar.visible = false;
            }
            _passwordText = "";
            _nextBtn.visible = false;
            _creation.invalidatePassWord();
         }
      }
      
      private function markEmptyAsError() : void
      {
         if(_newUsernameTxt.text == "")
         {
            GuiStatusIcon.showX(_userNameSts,_userNameTracking);
            _userNameSts.visible = true;
            _newUsernameBar.visible = false;
         }
         checkPassWord();
      }
      
      private function checkUserName() : void
      {
         if(_creation.validatedUserName != _newUsernameTxt.text)
         {
            if(_creation.validatedUserName)
            {
               _creation.invalidateUserName();
            }
            if(_newUsernameTxt.text == "")
            {
               _userNameSts.visible = _userNameTracking.xTracking = _userNameTracking.waitTracking = _userNameTracking.checkTracking = false;
               CreateAccountGui.hideNotifyPopup();
            }
            else if(_newUsernameTxt.text != _lastCheckedPlayerTag)
            {
               if(_validationPending)
               {
                  if(!_userNameKeyUpDelayTimer.running)
                  {
                     _creation.invalidatePending();
                  }
                  _userNameKeyUpDelayTimer.reset();
               }
               _lastCheckedPlayerTag = _newUsernameTxt.text;
               if(_newUsernameTxt.text.length > 3)
               {
                  _validationPending = true;
                  _userNameSts.visible = true;
                  GuiStatusIcon.showWait(_userNameSts,_userNameTracking);
                  _userNameKeyUpDelayTimer.start();
               }
               else
               {
                  _validationPending = false;
                  GuiStatusIcon.showX(_userNameSts,_userNameTracking);
               }
            }
         }
      }
      
      private function checkPassWord() : void
      {
         _creation.validatePassWord(_newPasswordTxt.text,_newUsernameTxt.text,passWordValidCallback);
      }
      
      private function userNameTxtChangeHandler(param1:Event) : void
      {
         checkUserName();
         checkPassWord();
         CreateAccountGui.hideNotifyPopup();
      }
      
      private function userNameTxtChangeDelayTimerHandler(param1:TimerEvent) : void
      {
         var _loc2_:String = _newUsernameTxt.text;
         _newUsernameTxt.text = _loc2_.substr(0,1) + _loc2_.substr(1).toLowerCase();
         var _loc3_:Array = CreateAccountGui.currEmailAddress().split("@");
         if(_loc3_.length > 1)
         {
            if(_loc3_[0].toLowerCase() != _newUsernameTxt.text.toLowerCase())
            {
               _creation.validateUserName(_newUsernameTxt.text,_newPasswordTxt.text,0,0,0,userNameValidCallback);
            }
            else
            {
               CreateAccountGui.showEmailCannotMatchUserName();
               _validationPending = false;
               GuiStatusIcon.showX(_userNameSts,_userNameTracking);
            }
         }
         else
         {
            _creation.validateUserName(_newUsernameTxt.text,_newPasswordTxt.text,0,0,0,userNameValidCallback);
         }
         _userNameKeyUpDelayTimer.reset();
      }
      
      private function nameSugClickHandler(param1:MouseEvent) : void
      {
         _newUsernameTxt.text = param1.currentTarget["pTag_txt"].text;
         userNameTxtChangeHandler(null);
         _nameSuggestionsFrame.visible = false;
      }
      
      private function nameSugCloseBtnMouseDownHandler(param1:MouseEvent) : void
      {
         _nameSuggestionsFrame.visible = false;
      }
      
      private function passWordTxtChangeHandler(param1:Event) : void
      {
         checkPassWord();
         checkUserName();
      }
      
      private function selBar1FocusHandler(param1:Event) : void
      {
         var _loc2_:Date = null;
         if(!_activeSelBar1.visible)
         {
            _activeSelBar1.visible = true;
            _activeSelBar2.visible = false;
            _activeSelBar3.visible = false;
            _activeSelBar4.visible = false;
            _nameSuggestionsFrame.visible = false;
            _nameTipPopup.visible = false;
            _passwordTipPopup.visible = false;
            _newPlayerAgeDpn.closeDropdownSilent();
         }
         if(param1)
         {
            _selectedBdayMonthIndex = _newBdayMonthDpn.selectedIdx;
            _selectedBdayDayIndex = _newBdayDayDpn.selectedIdx;
            if(_selectedBdayMonthIndex != -1 && param1.currentTarget == _playerTagScreen.birthday.dropdown_month)
            {
               _loc2_ = new Date(2013,_selectedBdayMonthIndex + 1,0);
               _newBdayDayDpn.updateDaysShown(_loc2_.getDate());
            }
         }
      }
      
      private function selBar2FocusHandler(param1:Event) : void
      {
         if(!_activeSelBar2.visible)
         {
            _activeSelBar1.visible = false;
            _activeSelBar2.visible = true;
            _activeSelBar3.visible = false;
            _activeSelBar4.visible = false;
            _nameSuggestionsFrame.visible = false;
            _nameTipPopup.visible = false;
            _passwordTipPopup.visible = false;
            _newBdayMonthDpn.closeDropdownSilent();
            _newBdayDayDpn.closeDropdownSilent();
         }
         if(param1)
         {
            _selectedGender = _newGenderRbg.selected;
            if(!_hasSelectedBdayAge)
            {
               _hasSelectedBdayAge = _newPlayerAgeDpn.dropdownTxt.text != "-";
            }
            _selectedBdayAgeIndex = _newPlayerAgeDpn.selectedIdx;
         }
      }
      
      private function selBar3FocusHandler(param1:Event) : void
      {
         if(!_activeSelBar3.visible)
         {
            _activeSelBar1.visible = false;
            _activeSelBar2.visible = false;
            _activeSelBar3.visible = true;
            _activeSelBar4.visible = false;
            _nameTipPopup.visible = true;
            _passwordTipPopup.visible = false;
            _nameSuggestionsFrame.visible = false;
            _newPlayerAgeDpn.closeDropdownSilent();
            _newBdayMonthDpn.closeDropdownSilent();
            _newBdayDayDpn.closeDropdownSilent();
         }
         CreateAccountGui.hideNotifyPopup();
      }
      
      private function selBar4FocusHandler(param1:FocusEvent) : void
      {
         if(!_activeSelBar4.visible)
         {
            _activeSelBar1.visible = false;
            _activeSelBar2.visible = false;
            _activeSelBar3.visible = false;
            _activeSelBar4.visible = true;
            _nameSuggestionsFrame.visible = false;
            _nameTipPopup.visible = false;
            _passwordTipPopup.visible = true;
            _newPlayerAgeDpn.closeDropdownSilent();
            _newBdayMonthDpn.closeDropdownSilent();
            _newBdayDayDpn.closeDropdownSilent();
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
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo3Sound.play();
            if(CreateAccountGui.vo3Sound.sc)
            {
               CreateAccountGui.vo3Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
               _voBtn.play();
            }
         }
      }
      
      private function nextBtnHandler() : Boolean
      {
         if(_validationPending)
         {
            _continueClicked = true;
            return false;
         }
         if(_creation.validatedUserName)
         {
            if(_creation.validatedPassWord)
            {
               if(_newPlayerAgeDpn.selectedIdx < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(-98);
                  return false;
               }
               if(_newGenderRbg.selected < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(-99);
                  return false;
               }
               if(_newBdayDayDpn.selectedIdx < 0 || _newBdayMonthDpn.selectedIdx < 0)
               {
                  CreateAccountGui.showLoginCreateResultMsg(-100);
                  return false;
               }
               _creation.setBirthday(String(_newBdayMonthDpn.selectedIdx + 1),_newBdayDayDpn.selectedTxt.text,String(_newPlayerAgeDpn.selectedIdx + 1));
               _creation.setGender(_newGenderRbg.selected);
               _numTimesBadUsername = 0;
               _isEmailSameAsUserName = false;
               return true;
            }
            passWordTxtChangeHandler(null);
            markEmptyAsError();
            return false;
         }
         _continueClicked = true;
         _creation.validateUserName(_newUsernameTxt.text,_newPasswordTxt.text,0,0,0,userNameValidCallback);
         markEmptyAsError();
         return false;
      }
   }
}

