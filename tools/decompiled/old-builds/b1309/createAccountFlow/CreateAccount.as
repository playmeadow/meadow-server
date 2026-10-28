package createAccountFlow
{
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.INewAvatar;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFEvent;
   import com.sbi.corelib.crypto.SBCrypto;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   import com.sbi.popup.*;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.system.Security;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.Fonts;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   
   public class CreateAccount extends MovieClip implements INewAvatar
   {
      
      public var existingAvatarData:Array;
      
      public var existingAvatarDataChanged:Boolean;
      
      public var showAvatarOrigX:Number;
      
      public var showAvatarOrigY:Number;
      
      public var avatarCarousel:MovieClip;
      
      public var accountCreation:MovieClip;
      
      private var _createAccountFlashVars:Object;
      
      private var _nextNewAccountServerIdx:int;
      
      private var _triedReloadSwf:Boolean;
      
      private var createUserAutoconnect:Boolean;
      
      private var createAvatarAutoconnect:Boolean;
      
      private var loginInfoAutoconnect:Boolean;
      
      private var loginInfoAutologin:Boolean;
      
      private var validateUserNameAutoconnect:Boolean;
      
      private var _validateTestName:String;
      
      private var _validateTestPass:String;
      
      private var validateUserNameAutologin:Boolean;
      
      private var validateAvNameAutoconnect:Boolean;
      
      private var _validateTestAvName:String;
      
      private var validateAvNameAutologin:Boolean;
      
      private var _ignoreValidation:Boolean;
      
      private var _newUserName:String;
      
      private var _newUserPass:String;
      
      private var _newSaveName:Boolean;
      
      private var _newUserEmail:String;
      
      private var _caUserName:String;
      
      private var _caUserPass:String;
      
      private var _caUserEmail:String;
      
      private var _caBirthday:String;
      
      private var _caGender:int;
      
      private var _showAvatar:Avatar;
      
      private var _showAvatarView:AvatarView;
      
      private var _caAvatarName:String;
      
      private var _caAvatarNameIndexes:Array;
      
      private var _caAvatarType:int;
      
      private var _caAvatarColor:int;
      
      private var color1s:Array;
      
      private var color2s:Array;
      
      private var color3s:Array;
      
      private var _createUser:Boolean;
      
      private var _createAvatar:Boolean;
      
      private var _createUserLoggedIn:Boolean;
      
      private var _createAvatarLoggedIn:Boolean;
      
      private var _userNameValidGuiCallback:Function;
      
      private var _avNameValidGuiCallback:Function;
      
      private var _zone:String;
      
      private var _alreadyCreated:Boolean;
      
      private var _closeTimer:Timer;
      
      private var _createdDBUserId:int;
      
      private var _customAvId:int;
      
      private var _unusablePasswords:Array;
      
      private var _connectEvent:Event;
      
      private var _loginEvent:Event;
      
      private var _avNameIndexes:Array;
      
      public function CreateAccount(param1:Object)
      {
         super();
         _createAccountFlashVars = param1;
      }
      
      public function loginCtorHelper() : void
      {
         init();
      }
      
      public function init() : void
      {
         DebugUtility.debugTrace("security:" + Security.sandboxType);
         _nextNewAccountServerIdx = 0;
         _triedReloadSwf = false;
         existingAvatarData = [];
         existingAvatarDataChanged = false;
         _ignoreValidation = false;
         _newUserName = null;
         _newUserPass = null;
         _newSaveName = false;
         _newUserEmail = "";
         _caUserName = "";
         _caUserPass = "";
         _caUserEmail = "";
         _caBirthday = "";
         _caGender = -1;
         _caAvatarName = "";
         _caAvatarNameIndexes = [];
         _createUser = false;
         _createAvatar = false;
         _createUserLoggedIn = false;
         _createAvatarLoggedIn = false;
         _alreadyCreated = false;
         _zone = "sbiLogin";
         _avNameIndexes = [0,0,0];
         _createdDBUserId = -1;
         LoadProgress.init(this);
         UserCurrency.initCurrency();
         initCreateAccountAssets();
      }
      
      private function initCreateAccountAssets() : void
      {
         accountCreation = MainFrame.avatarCreationLogin;
         initGamePalette();
      }
      
      public function initGamePalette() : void
      {
         ImageServerURL.instance.addEventListener("OnGlobalPalette",handleGamePalette,false,0,true);
         DebugUtility.debugTrace("login - asking for game palette");
         ImageServerURL.instance.requestGlobalPalette();
      }
      
      private function handleGamePalette(param1:ImageServerEvent) : void
      {
         ImageServerURL.instance.removeEventListener("OnGlobalPalette",handleGamePalette);
         if(param1 && param1.genericData)
         {
            PaletteHelper.setGamePalette(param1.genericData.palette,param1.genericData.avatarPalette1,param1.genericData.avatarPalette2);
         }
         initAssets();
      }
      
      public function initAssets() : void
      {
         XtReplyDemuxer.init();
         CreateAccountXtCommManager.init(this);
         AvatarXtCommManager.init();
         ItemXtCommManager.init();
         GenericListXtCommManager.init();
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"i");
         XtReplyDemuxer.addModule(ItemXtCommManager.handleXtReply,"s");
         XtReplyDemuxer.addModule(GenericListXtCommManager.handleXtReply,"g");
         createUserAutoconnect = false;
         createAvatarAutoconnect = false;
         loginInfoAutologin = false;
         validateUserNameAutoconnect = false;
         validateUserNameAutologin = false;
         validateAvNameAutoconnect = false;
         validateAvNameAutologin = false;
         gMainFrame.server.removeEventListener("OnConnect",onConnect);
         gMainFrame.server.removeEventListener("OnLogin",onLogIn);
         gMainFrame.server.removeEventListener("OnConectionLost",onLogOut);
         gMainFrame.server.addEventListener("OnConnect",onConnect,false,0,true);
         gMainFrame.server.addEventListener("OnLogin",onLogIn,false,0,true);
         gMainFrame.server.addEventListener("OnConectionLost",onLogOut,false,0,true);
         Fonts.init();
         AJAudio.init();
         CreateAccountGui.init(this);
         removeEventListener("enterFrame",heartbeat);
         addEventListener("enterFrame",heartbeat,false,0,true);
         loginInfoAutoconnect = true;
         connecting();
      }
      
      public function destroy() : void
      {
         CreateAccountGui.destroy();
         ItemXtCommManager.destroy();
         AvatarXtCommManager.destroy();
         CreateAccountXtCommManager.destroy();
         XtReplyDemuxer.destroy();
         SBPopupManager.destroyAll();
         ImageServerURL.instance.removeEventListener("OnGlobalPalette",handleGamePalette);
         gMainFrame.server.removeEventListener("OnConnect",onConnect);
         gMainFrame.server.removeEventListener("OnLogin",onLogIn);
         gMainFrame.server.removeEventListener("OnConectionLost",onLogOut);
         gMainFrame.userInfo.avtDefsCached = false;
         MainFrame.avatarCreationLogin = null;
         removeEventListener("enterFrame",heartbeat);
         existingAvatarData = null;
         avatarCarousel = null;
         accountCreation = null;
         _showAvatar.destroy();
         _showAvatarView.destroy(true);
         _showAvatar = null;
         _showAvatarView = null;
      }
      
      public function get validatedAvatarName() : String
      {
         return _caAvatarName;
      }
      
      public function get validatedUserName() : String
      {
         return _caUserName;
      }
      
      public function get validatedPassWord() : String
      {
         return _caUserPass;
      }
      
      public function get showAvatar() : Avatar
      {
         return _showAvatar;
      }
      
      public function get showAvatarView() : AvatarView
      {
         return _showAvatarView;
      }
      
      public function registrationSuccess() : void
      {
         CreateAccountGui.trackUserCreateAccountPageChange("IntroComplete",-1,1);
         SBTracker.completeLastTrackingBatch(onLastBatchPushed);
      }
      
      private function onLastBatchPushed() : void
      {
         var _loc1_:String = null;
         var _loc2_:URLRequest = null;
         var _loc3_:URLVariables = null;
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("complete_signup",_newUserName,_newUserPass);
            }
            else
            {
               _loc1_ = gMainFrame.clientInfo.websiteURL + "complete_signup";
               _loc2_ = new URLRequest(_loc1_);
               _loc2_.method = "POST";
               _loc3_ = new URLVariables();
               _loc3_.u = _newUserName;
               _loc3_.p = _newUserPass;
               DebugUtility.debugTrace("wurv:" + _loc3_);
               _loc2_.data = _loc3_;
               navigateToURL(_loc2_,"_self");
            }
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error while trying to redirect to autologin (and then world)! msg:" + e.message + e.getStackTrace());
         }
      }
      
      private function loadComplete(param1:Event) : void
      {
         gMainFrame.server.disconnect();
         destroy();
         AJClient(this.parent).setupGamePlay(_loginEvent,_connectEvent);
      }
      
      private function ioError(param1:IOError) : void
      {
         DebugUtility.debugTrace("IO Error while trying to redirect to autologin (and then world)!");
      }
      
      public function heartbeat(param1:Event) : void
      {
         LayerAnim.heartbeat();
      }
      
      public function connecting() : void
      {
         CreateAccountGui.showConnectingMsg();
         LoadProgress.show(false);
         LoadProgress.show(true);
         gMainFrame.server.connect();
      }
      
      private function onConnect(param1:SFEvent) : void
      {
         var _loc2_:String = null;
         _connectEvent = param1;
         if(param1.status)
         {
            _triedReloadSwf = false;
            CreateAccountGui.hideNotifyPopup();
            if(loginInfoAutoconnect)
            {
               loginInfoAutoconnect = false;
               logInForCreateAvatarData();
               return;
            }
            if(validateUserNameAutoconnect)
            {
               validateUserNameAutoconnect = false;
               validateUserName(_validateTestName,_validateTestPass,0,0,0,_userNameValidGuiCallback);
               return;
            }
            if(validateAvNameAutoconnect)
            {
               validateAvNameAutoconnect = false;
               validateAvatarName(_validateTestAvName,_avNameIndexes[0],_avNameIndexes[1],_avNameIndexes[2],_avNameValidGuiCallback);
               return;
            }
            if(createUserAutoconnect)
            {
               createUserAutoconnect = false;
               createNewAccount();
               return;
            }
            if(createAvatarAutoconnect)
            {
               createAvatarAutoconnect = false;
               createNewAvatar();
               return;
            }
         }
         else if(!gMainFrame.server.autoAttemptHttp)
         {
            if(_nextNewAccountServerIdx < gMainFrame.server.serverIps.length)
            {
               gMainFrame.server.setNewServer(_nextNewAccountServerIdx);
               DebugUtility.debugTrace("new account trying next Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
               _nextNewAccountServerIdx = _nextNewAccountServerIdx + 1;
            }
            else
            {
               gMainFrame.server.autoAttemptHttp = true;
               _nextNewAccountServerIdx = 0;
               gMainFrame.server.setNewServer(_nextNewAccountServerIdx);
               DebugUtility.debugTrace("new account trying first httpProxy Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
            }
         }
         else if(_nextNewAccountServerIdx < gMainFrame.server.blueboxIps.length)
         {
            gMainFrame.server.setNewServer(_nextNewAccountServerIdx);
            DebugUtility.debugTrace("new account trying next httpProxy Server Node: " + gMainFrame.server.serverIp);
            gMainFrame.server.connect();
            _nextNewAccountServerIdx = _nextNewAccountServerIdx + 1;
         }
         else
         {
            if(!_triedReloadSwf)
            {
               _triedReloadSwf = true;
               _loc2_ = Utility.reloadSWFOrGetIp(false,false);
               if(_loc2_)
               {
                  gMainFrame.server.switchServerNode(_loc2_);
                  DebugUtility.debugTrace("trying new Server Node: " + _loc2_);
                  gMainFrame.server.connect();
                  return;
               }
            }
            DebugUtility.debugTrace("entire new account cluster is down! _nextNewAccountServerIdx:" + _nextNewAccountServerIdx + " serverIps:" + gMainFrame.server.serverIps + " blueboxIps:" + gMainFrame.server.blueboxIps);
            CreateAccountGui.showConnectFailedPopup();
         }
      }
      
      public function hideConnectingMsg() : void
      {
         CreateAccountGui.hideNotifyPopup();
      }
      
      public function logInNewAccountDone() : void
      {
         registrationSuccess();
      }
      
      public function newAvatarData(param1:int, param2:String, param3:Array, param4:Function, param5:int = -1, param6:int = -1, param7:Boolean = false) : void
      {
         var _loc8_:int = AvatarUtility.findAvatarIndexByType(param1,param6);
         _caAvatarType = AvatarUtility.getAvatarTypeByIndex(_loc8_);
         _showAvatar = AvatarUtility.getAvatarByIndex(_loc8_);
         _caAvatarNameIndexes = param3;
         _customAvId = param6;
         validateAvatarName(param2,_caAvatarNameIndexes[0],_caAvatarNameIndexes[1],_caAvatarNameIndexes[2],param4);
      }
      
      public function logInForCreateAvatarData() : void
      {
         if(!gMainFrame.server.isConnected)
         {
            loginInfoAutoconnect = true;
            CreateAccountGui.showConnectingMsg();
            gMainFrame.server.connect();
            return;
         }
         if(!gMainFrame.server.isLoggedIn)
         {
            loginInfoAutologin = true;
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
         else
         {
            GenericListXtCommManager.requestGenericList(64,handleCreateAvatarData,null,false);
         }
      }
      
      public function handleCreateAvatarData(param1:Array) : void
      {
         if(gMainFrame.server.isLoggedIn)
         {
            loginInfoAutologin = false;
            DebugUtility.debugTrace("dealing with create avatar data now:" + param1);
            AvatarUtility.buildCreationAvatarViews(param1,true);
            CreateAccountGui.showTypeSelectAvatars();
            CreateAccountGui.chooseAnimalScreen.init();
         }
         else
         {
            logInForCreateAvatarData();
         }
      }
      
      public function invalidateUserName() : void
      {
         _caUserName = null;
      }
      
      public function invalidatePassWord() : void
      {
         _caUserPass = null;
      }
      
      public function invalidatePending() : void
      {
         _ignoreValidation = true;
      }
      
      public function validateUserName(param1:String, param2:String, param3:int, param4:int, param5:int, param6:Function, param7:int = 0) : void
      {
         _userNameValidGuiCallback = param6;
         if(param1 && param1 != "" && param1.length > 3 && SbiConstants.USERNAME_REGEX.test(param1))
         {
            if(param2 == null || param2.toLowerCase().indexOf(param1.toLowerCase()) < 0)
            {
               if(!gMainFrame.server.isConnected)
               {
                  validateUserNameAutoconnect = true;
                  _validateTestName = param1;
                  _validateTestPass = param2;
                  CreateAccountGui.showConnectingMsg();
                  gMainFrame.server.connect();
                  return;
               }
               if(gMainFrame.server.isLoggedIn)
               {
                  _validateTestName = param1;
                  _validateTestPass = param2;
                  CreateAccountXtCommManager.sendLoginAvailableRequest(param7,_validateTestName,0,0,0);
               }
               else
               {
                  validateUserNameAutologin = true;
                  _validateTestName = param1;
                  _validateTestPass = param2;
                  gMainFrame.server.logIn("sbiAccountZone","","");
               }
            }
            else
            {
               CreateAccountGui.showNewPasswordBadMsg(-16);
               if(_userNameValidGuiCallback != null)
               {
                  _userNameValidGuiCallback(false,[],2);
               }
            }
         }
         else
         {
            CreateAccountGui.showUsernameExistsMsg();
            if(_userNameValidGuiCallback != null)
            {
               _userNameValidGuiCallback(false,[],2);
            }
         }
      }
      
      public function validatePassWord(param1:String, param2:String, param3:Function) : void
      {
         if(param1 && param1 != "" && param1.length >= 6)
         {
            if(_unusablePasswords == null)
            {
               _unusablePasswords = LocalizationManager.translateIdOnly(21913).split("|");
            }
            if(param2.toLowerCase().indexOf(param1.toLowerCase()) >= 0 || param1.toLowerCase().indexOf(param2.toLowerCase()) >= 0)
            {
               CreateAccountGui.showNewPasswordBadMsg(-16);
               param3(false);
            }
            else if(_unusablePasswords.indexOf(param1) != -1)
            {
               CreateAccountGui.showNewPasswordBadMsg(-5);
               param3(false);
            }
            else
            {
               _caUserPass = param1;
               CreateAccountGui.hideNotifyPopup();
               param3(true);
            }
         }
         else
         {
            param3(false);
         }
      }
      
      public function validateAvatarName(param1:String, param2:int, param3:int, param4:int, param5:Function) : void
      {
         _avNameValidGuiCallback = param5;
         if(param1 && param1 != "" && RegExp(/a-zA-Z0-9 /)["exec"](param1) == null)
         {
            _validateTestAvName = param1;
            if(!gMainFrame.server.isConnected)
            {
               validateAvNameAutoconnect = true;
               CreateAccountGui.showConnectingMsg();
               gMainFrame.server.connect();
               return;
            }
            if(gMainFrame.server.isLoggedIn)
            {
               CreateAccountXtCommManager.sendLoginAvailableRequest(1,"",param2,param3,param4);
            }
            else
            {
               validateAvNameAutologin = true;
               gMainFrame.server.logIn("sbiAccountZone","","");
            }
         }
         else
         {
            CreateAccountGui.showAvNameExistsMsg();
         }
      }
      
      public function setBirthday(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Date = null;
         var _loc5_:int = 0;
         try
         {
            _loc4_ = new Date();
            _loc5_ = _loc4_.fullYear - int(param3);
            if(param1 == "")
            {
               param1 = "1";
            }
            if(param2 == "")
            {
               param2 = "1";
            }
            if(int(param1) > _loc4_.month + 1 || int(param1) == _loc4_.month + 1 && int(param2) >= _loc4_.date + 1)
            {
               _loc5_--;
            }
            if(_loc5_ < 0)
            {
               _loc5_ = 0;
            }
            _caBirthday = param1 + "/" + param2 + "/" + _loc5_;
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("ERROR: Bad birthday provided! Using default 1/1/1 for now.");
            _caBirthday = "1/1/1";
         }
      }
      
      public function setGender(param1:int) : void
      {
         _caGender = param1;
      }
      
      public function screenInitCallback(param1:MovieClip) : void
      {
      }
      
      public function get playSound() : Boolean
      {
         return true;
      }
      
      private function createNewAccount() : void
      {
         var _loc2_:Array = null;
         var _loc1_:Array = null;
         if(!gMainFrame.server.isConnected)
         {
            createUserAutoconnect = true;
            CreateAccountGui.showConnectingMsg();
            gMainFrame.server.connect();
            return;
         }
         if(gMainFrame.server.isLoggedIn && _createUser)
         {
            _createUserLoggedIn = true;
         }
         if(_createUserLoggedIn)
         {
            _loc2_ = [_caUserName,_caUserEmail,SBCrypto.encrypt(_caUserPass,gMainFrame.server.hashKey),_caBirthday,_caGender,gMainFrame.clientInfo.sgParams];
            _loc1_ = [0,_caUserName,_caAvatarNameIndexes[0],LocalizationManager.isCurrLanguageReversed() ? _caAvatarNameIndexes[2] : _caAvatarNameIndexes[1],LocalizationManager.isCurrLanguageReversed() ? _caAvatarNameIndexes[1] : _caAvatarNameIndexes[2],_caAvatarType,_showAvatar.colors[0],_showAvatar.colors[1],_showAvatar.colors[2],_showAvatar.accShownItems];
            CreateAccountXtCommManager.sendLoginCreateRequest(_loc2_,_loc1_);
         }
         else
         {
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
      }
      
      public function createNewAccountSetup(param1:String, param2:Function = null) : void
      {
         if(_alreadyCreated && _caUserEmail == param1)
         {
            CreateAccountGui.loginCreateSuccess(_createdDBUserId);
            return;
         }
         CreateAccountGui.loginCreateGuiCallback = param2;
         _caUserEmail = param1;
         if(_caUserName && _caUserName != "" && SbiConstants.USERNAME_REGEX.test(_caUserName) && _caUserPass && _caUserPass != "" && _caUserEmail && _caUserEmail != "")
         {
            _newUserName = _caUserName;
            _newUserPass = _caUserPass;
            _newUserEmail = _caUserEmail;
            _createUser = true;
            _createAvatar = true;
            createNewAccount();
         }
         else
         {
            CreateAccountGui.showUsernameExistsMsg(-3,false);
         }
      }
      
      private function createNewAvatar() : void
      {
         var _loc1_:Array = null;
         if(!gMainFrame.server.isConnected)
         {
            createAvatarAutoconnect = true;
            CreateAccountGui.showConnectingMsg();
            gMainFrame.server.connect();
            return;
         }
         if(gMainFrame.server.isLoggedIn && _createAvatar)
         {
            _createAvatarLoggedIn = true;
         }
         if(_createAvatarLoggedIn)
         {
            _loc1_ = [_caUserName,_caAvatarNameIndexes[0],_caAvatarNameIndexes[1],_caAvatarNameIndexes[2],_caAvatarType,_showAvatar.colors[0],_showAvatar.colors[1],_showAvatar.colors[2],_showAvatar.accShownItems];
            CreateAccountXtCommManager.sendLoginNewRequest(_loc1_);
         }
         else
         {
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
      }
      
      public function createNewAvatarPrep(param1:int = 0) : void
      {
      }
      
      public function nameTypeScreenDone() : void
      {
      }
      
      public function handleLoginAvailable(param1:Array, param2:int) : void
      {
         if(_ignoreValidation)
         {
            _ignoreValidation = false;
            return;
         }
         var _loc3_:int = int(param1[2]);
         if(_loc3_ == -24)
         {
            CreateAccountGui.showDifferentVersionsPopup();
         }
         else if(param2 == 0 || param2 == 2)
         {
            if(_loc3_ != 1)
            {
               _caUserName = null;
               if(_userNameValidGuiCallback != null)
               {
                  _userNameValidGuiCallback(_loc3_,param1,param2);
               }
               if(param2 != 2)
               {
                  CreateAccountGui.showUsernameExistsMsg(_loc3_);
               }
            }
            else
            {
               _caUserName = _validateTestName;
               if(_userNameValidGuiCallback != null)
               {
                  _userNameValidGuiCallback(_loc3_,param1,param2);
               }
               if(param2 != 2)
               {
                  CreateAccountGui.hideUsernameExistsMsg();
               }
            }
         }
         else if(param2 == 1)
         {
            if(_loc3_ == 1)
            {
               _caAvatarName = _validateTestAvName;
               if(_avNameValidGuiCallback != null)
               {
                  _avNameValidGuiCallback(true);
               }
            }
            else if(_avNameValidGuiCallback != null)
            {
               _avNameValidGuiCallback(false);
            }
            CreateAccountGui.avatarNameValidateCallback(_loc3_);
         }
      }
      
      public function handleLoginCreate(param1:Array) : void
      {
         var _loc2_:int = int(param1[2]);
         var _loc3_:int = int(param1[3]);
         if(_loc2_ <= 0)
         {
            DarkenManager.showLoadingSpiral(false);
            if(_loc2_ == -24)
            {
               CreateAccountGui.showDifferentVersionsPopup();
            }
            else
            {
               CreateAccountGui.showLoginCreateResultMsg(_loc2_);
            }
         }
         else
         {
            gMainFrame.server.disconnect();
            _alreadyCreated = true;
            _createdDBUserId = _loc3_;
            DebugUtility.debugTrace("Created DbUserId = " + _createdDBUserId);
            CreateAccountGui.loginCreateSuccess(_loc3_);
         }
      }
      
      public function handleLoginEmail(param1:Object) : void
      {
         var _loc2_:Function = null;
         if(param1[2] == -24)
         {
            CreateAccountGui.showDifferentVersionsPopup();
         }
         else
         {
            _loc2_ = CreateAccountGui.emailValidationCallback();
            _loc2_(param1[2] == "0",param1[2] == "0",true);
         }
      }
      
      public function handleLocalExternalCall(param1:Object) : void
      {
      }
      
      private function onLogOut(param1:SFEvent) : void
      {
         _createUserLoggedIn = false;
         _createAvatarLoggedIn = false;
      }
      
      private function onLogIn(param1:SFEvent) : void
      {
         _loginEvent = param1;
         gMainFrame.server.setInitRoom();
         if(validateUserNameAutologin || validateAvNameAutologin || loginInfoAutologin)
         {
            loginDone();
            return;
         }
         if(_createUser)
         {
            _createUserLoggedIn = true;
         }
         else if(_createAvatar)
         {
            _createAvatarLoggedIn = true;
         }
         loginDone();
      }
      
      private function loginDone() : void
      {
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            AvatarXtCommManager.requestAvatarInfo(loginDone);
            return;
         }
         CreateAccountGui.loadNameLists();
         if(loginInfoAutologin)
         {
            GenericListXtCommManager.requestGenericList(64,handleCreateAvatarData,null,false);
            return;
         }
         if(validateUserNameAutologin)
         {
            validateUserNameAutologin = false;
            validateUserName(_validateTestName,_validateTestPass,0,0,0,_userNameValidGuiCallback);
            return;
         }
         if(validateAvNameAutologin)
         {
            validateAvNameAutologin = false;
            validateAvatarName(_validateTestAvName,_avNameIndexes[0],_avNameIndexes[1],_avNameIndexes[2],_avNameValidGuiCallback);
            return;
         }
         if(_createAvatarLoggedIn)
         {
            createNewAvatar();
         }
         if(_createUserLoggedIn)
         {
            createNewAccount();
         }
      }
   }
}

