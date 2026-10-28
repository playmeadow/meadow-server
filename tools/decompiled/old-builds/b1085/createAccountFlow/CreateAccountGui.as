package createAccountFlow
{
   import avatar.AvatarSwitch;
   import com.sbi.analytics.SBTracker;
   import com.sbi.corelib.audio.SBSound;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBWizard;
   import createAccountGui.GuiAvatarCreationAssets;
   import createAccountGui.GuiChooseAnimal;
   import createAccountGui.GuiCreateAName;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import gui.DarkenManager;
   import gui.GuiNameTypeScreen;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class CreateAccountGui
   {
      
      public static var bgLayer:DisplayLayer;
      
      public static var frgLayer:DisplayLayer;
      
      public static var guiLayer:DisplayLayer;
      
      private static var _login:CreateAccount;
      
      private static var _loginAssets:GuiAvatarCreationAssets;
      
      private static var _nameTypeScreen:GuiNameTypeScreen;
      
      private static var _serverPopup:MovieClip;
      
      private static var _charPopup:MovieClip;
      
      private static var _spawnPopup:MovieClip;
      
      private static var ContentLogIn:Class;
      
      private static var CharacterContent:Class;
      
      private static var splashScreen:MovieClip;
      
      private static var createAccountRulesPopup:SBPopup;
      
      private static var selectAvatarPopup:SBPopup;
      
      private static var createAccountCharacterPopup:SBPopup;
      
      private static var createAccountAvEditorPopup:SBPopup;
      
      private static var createAccountPasswordPopup:SBPopup;
      
      private static var createAccountChatPopup:SBPopup;
      
      private static var createAccountActivatePopup:SBPopup;
      
      private static var createAccountSuccessPopup:SBPopup;
      
      private static var _notifyPopup:MovieClip;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _accountVerifyPopup:MovieClip;
      
      private static var connectingStr:int;
      
      private static var connectFailedStr:int;
      
      private static var loggingInStr:int;
      
      private static var failedLoginStr:int;
      
      private static var usernameExistsStr:int;
      
      private static var oopsTitleStr:int;
      
      private static var connectingTitleStr:int;
      
      public static var loginCreateGuiCallback:Function;
      
      public static var vo1Sound:SBSound;
      
      public static var vo2Sound:SBSound;
      
      public static var vo3Sound:SBSound;
      
      public static var vo4Sound:SBSound;
      
      public static var vo5Sound:SBSound;
      
      public static const MSG_ID_SERVER_ERROR:int = -1;
      
      public static const MSG_ID_USERNAME_BADWORD:int = -2;
      
      public static const MSG_ID_USERNAME_UNAVAILABLE:int = -3;
      
      public static const MSG_ID_USERNAME_MISSING:int = -4;
      
      public static const MSG_ID_PASSWORD_INVALID:int = -5;
      
      public static const MSG_ID_PASSWORD_MISSING:int = -6;
      
      public static const MSG_ID_EMAIL_MISSING:int = -7;
      
      public static const MSG_ID_EMAIL_INVALID:int = -8;
      
      public static const MSG_ID_EMAIL_FAILURE:int = -9;
      
      public static const MSG_ID_LOGIN_INVALID:int = -10;
      
      public static const MSG_ID_LOGIN_IN_USE:int = -11;
      
      public static const MSG_ID_LOGIN_ZONE_FULL:int = -12;
      
      public static const MSG_ID_LOGIN_CONNECTION:int = -13;
      
      public static const MSG_ID_LOGIN_BANNED:int = -14;
      
      public static const MSG_ID_LOGIN_SERVER_MAIN:int = -15;
      
      public static const MSG_ID_PASSWORD_SAME_AS_UN:int = -16;
      
      public static const MSG_ID_TOO_MANY_EMAILS:int = -18;
      
      public static const MSG_ID_AGE_BLANK:int = -98;
      
      public static const MSG_ID_SEX_BLANK:int = -99;
      
      public static const MSG_ID_MONTH_OR_DAY_BLANK:int = -100;
      
      public static const MIN_PASSWORD_LENGTH:int = 6;
      
      public static var VoiceOver1Sound:Class = CreateAccountGui_VoiceOver1Sound;
      
      public static var VoiceOver2Sound:Class = CreateAccountGui_VoiceOver2Sound;
      
      public static var VoiceOver3Sound:Class = CreateAccountGui_VoiceOver3Sound;
      
      public static var VoiceOver4Sound:Class = CreateAccountGui_VoiceOver4Sound;
      
      public static var VoiceOver5Sound:Class = CreateAccountGui_VoiceOver5Sound;
      
      public function CreateAccountGui()
      {
         super();
      }
      
      public static function init(param1:CreateAccount) : void
      {
         _login = param1;
         _loginAssets = new GuiAvatarCreationAssets(param1.accountCreation);
         _loginAssets.init(param1,false);
         bgLayer = new DisplayLayer();
         frgLayer = new DisplayLayer();
         guiLayer = new DisplayLayer();
         _login.addChild(bgLayer);
         _login.addChild(guiLayer);
         _login.addChild(frgLayer);
         DarkenManager.init(frgLayer);
         _loginAssets.tipsPopup.visible = false;
         frgLayer.addChild(_loginAssets);
         vo1Sound = new SBSound(VoiceOver1Sound,false);
         vo2Sound = new SBSound(VoiceOver2Sound,false);
         vo3Sound = new SBSound(VoiceOver3Sound,false);
         vo4Sound = new SBSound(VoiceOver4Sound,false);
         vo5Sound = new SBSound(VoiceOver5Sound,false);
         connectingStr = 11143;
         connectFailedStr = 11144;
         oopsTitleStr = 11145;
         connectingTitleStr = 0;
         _notifyPopup = _loginAssets.notifyPopup;
         loggingInStr = 11146;
         failedLoginStr = 11147;
         usernameExistsStr = 11148;
         showNewChrPopup();
      }
      
      public static function destroy() : void
      {
         if(_login.contains(bgLayer))
         {
            _login.removeChild(bgLayer);
         }
         bgLayer = null;
         if(_login.contains(guiLayer))
         {
            _login.removeChild(guiLayer);
         }
         guiLayer = null;
         if(_login.contains(frgLayer))
         {
            frgLayer.removeChild(_loginAssets);
            _login.removeChild(frgLayer);
         }
         frgLayer = null;
         _login = null;
         createAccountRulesPopup.destroy();
         createAccountRulesPopup = null;
         selectAvatarPopup.destroy();
         selectAvatarPopup = null;
         createAccountCharacterPopup.destroy();
         createAccountCharacterPopup = null;
         createAccountAvEditorPopup.destroy();
         createAccountAvEditorPopup = null;
         createAccountChatPopup.destroy();
         createAccountChatPopup = null;
         createAccountActivatePopup.destroy();
         createAccountActivatePopup = null;
         createAccountSuccessPopup.destroy();
         createAccountSuccessPopup = null;
         _loginAssets.destroy();
         _loginAssets = null;
         vo1Sound.destroy();
         vo1Sound = null;
         vo2Sound.destroy();
         vo2Sound = null;
         vo3Sound.destroy();
         vo3Sound = null;
         vo4Sound.destroy();
         vo4Sound = null;
         vo5Sound.destroy();
         vo5Sound = null;
         DarkenManager.destroy();
      }
      
      public static function get nameTypeScreen() : GuiCreateAName
      {
         return _loginAssets.creationWiz.createANameScreen;
      }
      
      public static function get newAccountWizard() : SBWizard
      {
         return _loginAssets.creationWiz;
      }
      
      public static function get chooseAnimalScreen() : GuiChooseAnimal
      {
         return _loginAssets.creationWiz.chooseAnimalScreen;
      }
      
      public static function showConnectingMsg() : void
      {
         LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,connectingStr);
         _loginAssets.notifyPopup.titleTxt.text = connectingTitleStr;
         _loginAssets.notifyPopup.visible = true;
      }
      
      public static function hideNotifyPopup() : void
      {
         _loginAssets.notifyPopup.visible = false;
      }
      
      public static function showConnectFailedPopup() : void
      {
         LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,connectFailedStr);
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _loginAssets.notifyPopup.visible = true;
      }
      
      public static function currAvatar() : MovieClip
      {
         return _loginAssets.currAvatar;
      }
      
      public static function currBG() : String
      {
         return _loginAssets.currBG;
      }
      
      public static function currType() : int
      {
         return _loginAssets.currType;
      }
      
      public static function currEmailAddress() : String
      {
         return _loginAssets.currEmailAddress;
      }
      
      public static function emailValidationCallback() : Function
      {
         return _loginAssets.emailValidationCallback;
      }
      
      public static function loadNameLists() : void
      {
         _loginAssets.loadNameLists();
      }
      
      public static function showNewChrPopup() : void
      {
         hideNotifyPopup();
         trackUserCreateAccountPageChange("ChooseAnimal");
      }
      
      public static function newChrWizardDone() : void
      {
         _loginAssets.creationWiz.wizClip.visible = true;
         _loginAssets.creationWiz.jumpToStep(1);
      }
      
      public static function showLoginCreateResultMsg(param1:int) : void
      {
         var _loc2_:int = -1;
         switch(param1)
         {
            case MSG_ID_SERVER_ERROR:
            default:
               _loc2_ = 11149;
               break;
            case MSG_ID_USERNAME_BADWORD:
               _loc2_ = 11150;
               break;
            case MSG_ID_USERNAME_UNAVAILABLE:
               _loc2_ = 11148;
               break;
            case MSG_ID_USERNAME_MISSING:
               _loc2_ = 11151;
               break;
            case MSG_ID_PASSWORD_INVALID:
               _loc2_ = 11152;
               break;
            case MSG_ID_PASSWORD_MISSING:
               _loc2_ = 11153;
               break;
            case MSG_ID_EMAIL_MISSING:
               _loc2_ = 11154;
               break;
            case MSG_ID_EMAIL_INVALID:
               _loc2_ = 11155;
               break;
            case MSG_ID_EMAIL_FAILURE:
               _loc2_ = 11156;
               break;
            case MSG_ID_LOGIN_INVALID:
               _loc2_ = 11157;
               break;
            case MSG_ID_LOGIN_IN_USE:
               _loc2_ = 11158;
               break;
            case MSG_ID_LOGIN_ZONE_FULL:
               _loc2_ = 11159;
               break;
            case MSG_ID_LOGIN_CONNECTION:
               _loc2_ = 11160;
               break;
            case MSG_ID_PASSWORD_SAME_AS_UN:
               _loc2_ = 11161;
               break;
            case MSG_ID_AGE_BLANK:
               _loc2_ = 11162;
               break;
            case MSG_ID_SEX_BLANK:
               _loc2_ = 11163;
               break;
            case MSG_ID_MONTH_OR_DAY_BLANK:
               _loc2_ = 11164;
               break;
            case MSG_ID_TOO_MANY_EMAILS:
               _mediaHelper = new MediaHelper();
               _mediaHelper.init(1842,onMediaLoaded);
               DarkenManager.showLoadingSpiral(true);
         }
         if(_loc2_ != -1)
         {
            LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,_loc2_);
            LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
            _loginAssets.notifyPopup.visible = true;
         }
         if(loginCreateGuiCallback != null)
         {
            loginCreateGuiCallback(true,param1 == MSG_ID_EMAIL_MISSING || param1 == MSG_ID_EMAIL_INVALID || param1 == MSG_ID_EMAIL_FAILURE);
         }
      }
      
      private static function onMediaLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            DarkenManager.showLoadingSpiral(false);
            _accountVerifyPopup = MovieClip(param1.getChildAt(0));
            _accountVerifyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onAccountVerifyClose,false,0,true);
            _accountVerifyPopup.parent_btn.addEventListener(MouseEvent.MOUSE_DOWN,onActivateEmailBtn,false,0,true);
            _accountVerifyPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            _accountVerifyPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
            _loginAssets.addChild(_accountVerifyPopup);
            trackUserCreateAccountPageChange("AccountVerify");
         }
      }
      
      private static function onActivateEmailBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = gMainFrame.clientInfo.websiteURL + "parent_activation";
         var _loc3_:URLRequest = new URLRequest(_loc2_);
         try
         {
            navigateToURL(_loc3_,"_blank");
            onAccountVerifyClose(param1);
         }
         catch(e:Error)
         {
         }
      }
      
      private static function onAccountVerifyClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_accountVerifyPopup);
         _loginAssets.removeChild(_accountVerifyPopup);
         _accountVerifyPopup = null;
      }
      
      public static function loginCreateSuccess() : void
      {
         trackUserCreateAccountPageChange("CreateAndLogin");
         _login.logInNewAccountDone();
      }
      
      public static function showEmailDomainMisspelledWarning(param1:Array) : void
      {
         var _loc2_:String = LocalizationManager.translateIdOnly(11165);
         while(param1.length > 0)
         {
            _loc2_ += param1.pop();
            if(param1.length > 0)
            {
               _loc2_ += " ";
            }
         }
         _loc2_ += LocalizationManager.translateIdOnly(11166);
         LocalizationManager.updateToFit(_loginAssets.notifyPopup.notifyTxt,_loc2_,true);
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _loginAssets.notifyPopup.visible = true;
      }
      
      public static function showUsernameExistsMsg(param1:int = -10, param2:Boolean = true) : void
      {
         if(param1 == MSG_ID_USERNAME_UNAVAILABLE)
         {
            LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,11148);
         }
         else if(param2)
         {
            LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,11168);
         }
         else
         {
            LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,11169);
         }
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _loginAssets.notifyPopup.visible = true;
         if(loginCreateGuiCallback != null)
         {
            loginCreateGuiCallback(true,param1 == MSG_ID_LOGIN_INVALID);
         }
      }
      
      public static function showNewPasswordBadMsg(param1:int = -1) : void
      {
         if(param1 == MSG_ID_PASSWORD_SAME_AS_UN)
         {
            LocalizationManager.translateId(_notifyPopup.notifyTxt,11161);
         }
         else
         {
            LocalizationManager.translateId(_notifyPopup.notifyTxt,11170);
         }
         LocalizationManager.translateId(_notifyPopup.titleTxt,oopsTitleStr);
         _notifyPopup.visible = true;
      }
      
      public static function showEmailCannotMatchUserName() : void
      {
         LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,11171,true);
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _loginAssets.notifyPopup.visible = true;
      }
      
      public static function showTipsPopup(param1:Boolean) : void
      {
         _loginAssets.tipsPopup.visible = param1;
      }
      
      public static function showMustAgreeMsg() : void
      {
         LocalizationManager.translateId(_notifyPopup.notifyTxt,11172);
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _notifyPopup.visible = true;
      }
      
      public static function showMustConfirmMsg() : void
      {
         LocalizationManager.translateId(_notifyPopup.notifyTxt,11173);
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _notifyPopup.visible = true;
      }
      
      public static function avatarNameValidateCallback(param1:int) : void
      {
         if(param1 == 1)
         {
            hideNotifyPopup();
         }
         else
         {
            showAvNameExistsMsg(param1);
         }
      }
      
      public static function showAvNameExistsMsg(param1:int = -10) : void
      {
         if(param1 == MSG_ID_USERNAME_UNAVAILABLE)
         {
            LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,11174);
         }
         else
         {
            LocalizationManager.translateId(_loginAssets.notifyPopup.notifyTxt,11175);
         }
         LocalizationManager.translateId(_loginAssets.notifyPopup.titleTxt,oopsTitleStr);
         _loginAssets.notifyPopup.visible = true;
      }
      
      public static function hideUsernameExistsMsg() : void
      {
         _loginAssets.creationWiz.playerTagScreen.enableNext();
         hideNotifyPopup();
      }
      
      public static function showTypeSelectAvatars() : void
      {
         LoadProgress.show(false);
      }
      
      public static function trackUserCreateAccountPageChange(param1:String, param2:int = 0) : void
      {
         SBTracker.trackPageview("/login/" + param1,0,param2);
      }
      
      public static function clearAvatarSwitchAddCallback() : void
      {
         AvatarSwitch.addAvatarCallback = null;
      }
   }
}

