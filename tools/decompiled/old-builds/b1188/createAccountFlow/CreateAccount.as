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
   import flash.display.MovieClip;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
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
      
      private var _loginRedemptionCode:String;
      
      private var _nextNewAccountServerIdx:int;
      
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
         this._createAccountFlashVars = param1;
      }
      
      public function loginCtorHelper() : void
      {
         this.init();
      }
      
      public function init() : void
      {
         DebugUtility.debugTrace("security:" + Security.sandboxType);
         DebugUtility.debugTrace("redemption_code:" + this._createAccountFlashVars.redemption_code);
         this._loginRedemptionCode = this._createAccountFlashVars.redemption_code;
         if(this._loginRedemptionCode == null)
         {
            this._loginRedemptionCode = "";
         }
         this._nextNewAccountServerIdx = 0;
         this.existingAvatarData = [];
         this.existingAvatarDataChanged = false;
         this._ignoreValidation = false;
         this._newUserName = null;
         this._newUserPass = null;
         this._newSaveName = false;
         this._newUserEmail = "";
         this._caUserName = "";
         this._caUserPass = "";
         this._caUserEmail = "";
         this._caBirthday = "";
         this._caGender = -1;
         this._caAvatarName = "";
         this._caAvatarNameIndexes = [];
         this._createUser = false;
         this._createAvatar = false;
         this._createUserLoggedIn = false;
         this._createAvatarLoggedIn = false;
         this._alreadyCreated = false;
         this._zone = "sbiLogin";
         this._avNameIndexes = [0,0,0];
         this._createdDBUserId = -1;
         LoadProgress.init(this);
         this.initCreateAccountAssets();
      }
      
      private function initCreateAccountAssets() : void
      {
         this.accountCreation = MainFrame.avatarCreationLogin;
         this.initGamePalette();
      }
      
      public function initGamePalette() : void
      {
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_GLOBAL_PALETTE,this.handleGamePalette,false,0,true);
         DebugUtility.debugTrace("login - asking for game palette");
         ImageServerURL.instance.requestGlobalPalette();
      }
      
      private function handleGamePalette(param1:ImageServerEvent) : void
      {
         ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_GLOBAL_PALETTE,this.handleGamePalette);
         if(Boolean(param1) && Boolean(param1.genericData))
         {
            PaletteHelper.setGamePalette(param1.genericData.palette,param1.genericData.avatarPalette1,param1.genericData.avatarPalette2);
         }
         this.initAssets();
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
         this.createUserAutoconnect = false;
         this.createAvatarAutoconnect = false;
         this.loginInfoAutologin = false;
         this.validateUserNameAutoconnect = false;
         this.validateUserNameAutologin = false;
         this.validateAvNameAutoconnect = false;
         this.validateAvNameAutologin = false;
         gMainFrame.server.removeEventListener(SFEvent.ON_CONNECT,this.onConnect);
         gMainFrame.server.removeEventListener(SFEvent.ON_LOGIN,this.onLogIn);
         gMainFrame.server.removeEventListener(SFEvent.ON_CONNECTION_LOST,this.onLogOut);
         gMainFrame.server.addEventListener(SFEvent.ON_CONNECT,this.onConnect,false,0,true);
         gMainFrame.server.addEventListener(SFEvent.ON_LOGIN,this.onLogIn,false,0,true);
         gMainFrame.server.addEventListener(SFEvent.ON_CONNECTION_LOST,this.onLogOut,false,0,true);
         Fonts.init();
         AJAudio.init();
         CreateAccountGui.init(this);
         removeEventListener(Event.ENTER_FRAME,this.heartbeat);
         addEventListener(Event.ENTER_FRAME,this.heartbeat,false,0,true);
         this.loginInfoAutoconnect = true;
         this.connecting();
      }
      
      public function destroy() : void
      {
         CreateAccountGui.destroy();
         ItemXtCommManager.destroy();
         AvatarXtCommManager.destroy();
         CreateAccountXtCommManager.destroy();
         XtReplyDemuxer.destroy();
         SBPopupManager.destroyAll();
         ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_GLOBAL_PALETTE,this.handleGamePalette);
         gMainFrame.server.removeEventListener(SFEvent.ON_CONNECT,this.onConnect);
         gMainFrame.server.removeEventListener(SFEvent.ON_LOGIN,this.onLogIn);
         gMainFrame.server.removeEventListener(SFEvent.ON_CONNECTION_LOST,this.onLogOut);
         gMainFrame.userInfo.avtDefsCached = false;
         MainFrame.avatarCreationLogin = null;
         removeEventListener(Event.ENTER_FRAME,this.heartbeat);
         this.existingAvatarData = null;
         this.avatarCarousel = null;
         this.accountCreation = null;
         this._showAvatar.destroy();
         this._showAvatarView.destroy(true);
         this._showAvatar = null;
         this._showAvatarView = null;
      }
      
      public function get validatedAvatarName() : String
      {
         return this._caAvatarName;
      }
      
      public function get validatedUserName() : String
      {
         return this._caUserName;
      }
      
      public function get validatedPassWord() : String
      {
         return this._caUserPass;
      }
      
      public function get showAvatar() : Avatar
      {
         return this._showAvatar;
      }
      
      public function get showAvatarView() : AvatarView
      {
         return this._showAvatarView;
      }
      
      public function registrationSuccess() : void
      {
         CreateAccountGui.trackUserCreateAccountPageChange("IntroComplete",-1,SBTracker.TYPE_EVENT);
         SBTracker.completeLastTrackingBatch(this.onLastBatchPushed);
      }
      
      private function onLastBatchPushed() : void
      {
         var loc:String = null;
         var wur:URLRequest = null;
         var wurv:URLVariables = null;
         try
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("complete_signup",this._newUserName,this._newUserPass);
            }
            else
            {
               loc = gMainFrame.clientInfo.websiteURL + "complete_signup";
               wur = new URLRequest(loc);
               wur.method = URLRequestMethod.POST;
               wurv = new URLVariables();
               wurv.u = this._newUserName;
               wurv.p = this._newUserPass;
               DebugUtility.debugTrace("wurv:" + wurv);
               wur.data = wurv;
               navigateToURL(wur,"_self");
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
         this.destroy();
         AJClient(this.parent).setupGamePlay(this._loginEvent,this._connectEvent);
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
         this._connectEvent = param1;
         if(param1.status)
         {
            CreateAccountGui.hideNotifyPopup();
            if(this.loginInfoAutoconnect)
            {
               this.loginInfoAutoconnect = false;
               this.logInForCreateAvatarData();
               return;
            }
            if(this.validateUserNameAutoconnect)
            {
               this.validateUserNameAutoconnect = false;
               this.validateUserName(this._validateTestName,this._validateTestPass,0,0,0,this._userNameValidGuiCallback);
               return;
            }
            if(this.validateAvNameAutoconnect)
            {
               this.validateAvNameAutoconnect = false;
               this.validateAvatarName(this._validateTestAvName,this._avNameIndexes[0],this._avNameIndexes[1],this._avNameIndexes[2],this._avNameValidGuiCallback);
               return;
            }
            if(this.createUserAutoconnect)
            {
               this.createUserAutoconnect = false;
               this.createNewAccount();
               return;
            }
            if(this.createAvatarAutoconnect)
            {
               this.createAvatarAutoconnect = false;
               this.createNewAvatar();
               return;
            }
         }
         else
         {
            _loc2_ = Utility.reloadSWFOrGetIp(false,false);
            if(_loc2_)
            {
               if(gMainFrame.server.autoAttemptHttp == false && gMainFrame.server.serverIp == _loc2_)
               {
                  DebugUtility.debugTrace("entire new account cluster is down! _nextNewAccountServerIdx:" + this._nextNewAccountServerIdx);
                  CreateAccountGui.showConnectFailedPopup();
               }
               else
               {
                  gMainFrame.server.autoAttemptHttp = gMainFrame.server.serverIp != _loc2_;
                  gMainFrame.server.switchServerNode(_loc2_);
                  DebugUtility.debugTrace("trying new Server Node: " + _loc2_);
                  gMainFrame.server.connect();
               }
            }
         }
      }
      
      public function hideConnectingMsg() : void
      {
         CreateAccountGui.hideNotifyPopup();
      }
      
      public function logInNewAccountDone() : void
      {
         this.registrationSuccess();
      }
      
      public function newAvatarData(param1:int, param2:String, param3:Array, param4:Function, param5:int = -1, param6:int = -1, param7:Boolean = false) : void
      {
         var _loc8_:int = AvatarUtility.findAvatarIndexByType(param1,param6);
         this._caAvatarType = AvatarUtility.getAvatarTypeByIndex(_loc8_);
         this._showAvatar = AvatarUtility.getAvatarByIndex(_loc8_);
         this._caAvatarNameIndexes = param3;
         this._customAvId = param6;
         this.validateAvatarName(param2,this._caAvatarNameIndexes[0],this._caAvatarNameIndexes[1],this._caAvatarNameIndexes[2],param4);
      }
      
      public function logInForCreateAvatarData() : void
      {
         if(!gMainFrame.server.isConnected)
         {
            this.loginInfoAutoconnect = true;
            CreateAccountGui.showConnectingMsg();
            gMainFrame.server.connect();
            return;
         }
         if(!gMainFrame.server.isLoggedIn)
         {
            this.loginInfoAutologin = true;
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
         else
         {
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVATAR_LIST_ID,this.handleCreateAvatarData,null,false);
         }
      }
      
      public function handleCreateAvatarData(param1:Array) : void
      {
         if(gMainFrame.server.isLoggedIn)
         {
            this.loginInfoAutologin = false;
            DebugUtility.debugTrace("dealing with create avatar data now:" + param1);
            AvatarUtility.buildCreationAvatarViews(param1,true);
            CreateAccountGui.showTypeSelectAvatars();
            CreateAccountGui.chooseAnimalScreen.init();
         }
         else
         {
            this.logInForCreateAvatarData();
         }
      }
      
      public function invalidateUserName() : void
      {
         this._caUserName = null;
      }
      
      public function invalidatePassWord() : void
      {
         this._caUserPass = null;
      }
      
      public function invalidatePending() : void
      {
         this._ignoreValidation = true;
      }
      
      public function validateUserName(param1:String, param2:String, param3:int, param4:int, param5:int, param6:Function, param7:int = 0) : void
      {
         this._userNameValidGuiCallback = param6;
         if(Boolean(param1 && param1 != "") && Boolean(RegExp(/\W/)["exec"](param1) == null) && !RegExp(/^[a-zA-Z0-9].*[A-Z]+.*/).test(param1))
         {
            if(param2 == null || param2.toLowerCase().indexOf(param1.toLowerCase()) < 0)
            {
               if(!gMainFrame.server.isConnected)
               {
                  this.validateUserNameAutoconnect = true;
                  this._validateTestName = param1;
                  this._validateTestPass = param2;
                  CreateAccountGui.showConnectingMsg();
                  gMainFrame.server.connect();
                  return;
               }
               if(gMainFrame.server.isLoggedIn)
               {
                  this._validateTestName = param1;
                  this._validateTestPass = param2;
                  CreateAccountXtCommManager.sendLoginAvailableRequest(param7,this._validateTestName,0,0,0);
               }
               else
               {
                  this.validateUserNameAutologin = true;
                  this._validateTestName = param1;
                  this._validateTestPass = param2;
                  gMainFrame.server.logIn("sbiAccountZone","","");
               }
            }
            else
            {
               CreateAccountGui.showNewPasswordBadMsg(CreateAccountGui.MSG_ID_PASSWORD_SAME_AS_UN);
               if(this._userNameValidGuiCallback != null)
               {
                  this._userNameValidGuiCallback(false,[],CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS);
               }
            }
         }
         else
         {
            CreateAccountGui.showUsernameExistsMsg();
            if(this._userNameValidGuiCallback != null)
            {
               this._userNameValidGuiCallback(false,[],CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS);
            }
         }
      }
      
      public function validatePassWord(param1:String, param2:String, param3:Function) : void
      {
         if(Boolean(param1) && Boolean(param1 != "") && param1.length >= CreateAccountGui.MIN_PASSWORD_LENGTH)
         {
            if(this._unusablePasswords == null)
            {
               this._unusablePasswords = LocalizationManager.translateIdOnly(LocalizationManager.UNUSABLE_PASSWORDS).split("|");
            }
            if(param2.toLowerCase().indexOf(param1.toLowerCase()) >= 0 || param1.toLowerCase().indexOf(param2.toLowerCase()) >= 0)
            {
               CreateAccountGui.showNewPasswordBadMsg(CreateAccountGui.MSG_ID_PASSWORD_SAME_AS_UN);
               param3(false);
            }
            else if(this._unusablePasswords.indexOf(param1) != -1)
            {
               CreateAccountGui.showNewPasswordBadMsg(CreateAccountGui.MSG_ID_PASSWORD_INVALID);
               param3(false);
            }
            else
            {
               this._caUserPass = param1;
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
         this._avNameValidGuiCallback = param5;
         if(Boolean(param1) && Boolean(param1 != "") && RegExp(/a-zA-Z0-9 /)["exec"](param1) == null)
         {
            this._validateTestAvName = param1;
            if(!gMainFrame.server.isConnected)
            {
               this.validateAvNameAutoconnect = true;
               CreateAccountGui.showConnectingMsg();
               gMainFrame.server.connect();
               return;
            }
            if(gMainFrame.server.isLoggedIn)
            {
               CreateAccountXtCommManager.sendLoginAvailableRequest(CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_AVATARNAME,"",param2,param3,param4);
            }
            else
            {
               this.validateAvNameAutologin = true;
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
         var nowDate:Date = null;
         var bdayYear:int = 0;
         var bdayMonthText:String = param1;
         var bdayDayText:String = param2;
         var bdayAgeText:String = param3;
         try
         {
            nowDate = new Date();
            bdayYear = nowDate.fullYear - int(bdayAgeText);
            if(bdayMonthText == "")
            {
               bdayMonthText = "1";
            }
            if(bdayDayText == "")
            {
               bdayDayText = "1";
            }
            if(int(bdayMonthText) > nowDate.month + 1 || int(bdayMonthText) == nowDate.month + 1 && int(bdayDayText) >= nowDate.date + 1)
            {
               bdayYear--;
            }
            if(bdayYear < 0)
            {
               bdayYear = 0;
            }
            this._caBirthday = bdayMonthText + "/" + bdayDayText + "/" + bdayYear;
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("ERROR: Bad birthday provided! Using default 1/1/1 for now.");
            _caBirthday = "1/1/1";
         }
      }
      
      public function setGender(param1:int) : void
      {
         this._caGender = param1;
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
         var _loc1_:Array = null;
         var _loc2_:Array = null;
         if(!gMainFrame.server.isConnected)
         {
            this.createUserAutoconnect = true;
            CreateAccountGui.showConnectingMsg();
            gMainFrame.server.connect();
            return;
         }
         if(Boolean(gMainFrame.server.isLoggedIn) && this._createUser)
         {
            this._createUserLoggedIn = true;
         }
         if(this._createUserLoggedIn)
         {
            _loc1_ = [this._caUserName,this._caUserEmail,SBCrypto.encrypt(this._caUserPass,gMainFrame.server.hashKey),this._caBirthday,this._caGender,this._loginRedemptionCode,gMainFrame.clientInfo.sgParams];
            _loc2_ = [0,this._caUserName,this._caAvatarNameIndexes[0],LocalizationManager.isCurrLanguageReversed() ? this._caAvatarNameIndexes[2] : this._caAvatarNameIndexes[1],LocalizationManager.isCurrLanguageReversed() ? this._caAvatarNameIndexes[1] : this._caAvatarNameIndexes[2],this._caAvatarType,this._showAvatar.colors[0],this._showAvatar.colors[1],this._showAvatar.colors[2],this._showAvatar.accShownItems];
            CreateAccountXtCommManager.sendLoginCreateRequest(_loc1_,_loc2_);
         }
         else
         {
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
      }
      
      public function createNewAccountSetup(param1:String, param2:Function = null) : void
      {
         if(this._alreadyCreated && this._caUserEmail == param1)
         {
            CreateAccountGui.loginCreateSuccess(this._createdDBUserId);
            return;
         }
         CreateAccountGui.loginCreateGuiCallback = param2;
         this._caUserEmail = param1;
         if(Boolean(this._caUserName && this._caUserName != "" && RegExp(/\W/)["exec"](this._caUserName) == null && this._caUserPass && this._caUserPass != "") && Boolean(this._caUserEmail) && this._caUserEmail != "")
         {
            this._newUserName = this._caUserName;
            this._newUserPass = this._caUserPass;
            this._newUserEmail = this._caUserEmail;
            this._createUser = true;
            this._createAvatar = true;
            this.createNewAccount();
         }
         else
         {
            CreateAccountGui.showUsernameExistsMsg(CreateAccountGui.MSG_ID_LOGIN_INVALID,false);
         }
      }
      
      private function createNewAvatar() : void
      {
         var _loc1_:Array = null;
         if(!gMainFrame.server.isConnected)
         {
            this.createAvatarAutoconnect = true;
            CreateAccountGui.showConnectingMsg();
            gMainFrame.server.connect();
            return;
         }
         if(Boolean(gMainFrame.server.isLoggedIn) && this._createAvatar)
         {
            this._createAvatarLoggedIn = true;
         }
         if(this._createAvatarLoggedIn)
         {
            _loc1_ = [this._caUserName,this._caAvatarNameIndexes[0],this._caAvatarNameIndexes[1],this._caAvatarNameIndexes[2],this._caAvatarType,this._showAvatar.colors[0],this._showAvatar.colors[1],this._showAvatar.colors[2],this._showAvatar.accShownItems];
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
         if(this._ignoreValidation)
         {
            this._ignoreValidation = false;
            return;
         }
         var _loc3_:int = int(param1[2]);
         if(_loc3_ == MainFrame.MSG_ID_LOGIN_CLIENT_MISMATCH)
         {
            CreateAccountGui.showDifferentVersionsPopup();
         }
         else if(param2 == CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_USERNAME || param2 == CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
         {
            if(_loc3_ != 1)
            {
               this._caUserName = null;
               if(this._userNameValidGuiCallback != null)
               {
                  this._userNameValidGuiCallback(_loc3_,param1,param2);
               }
               if(param2 != CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
               {
                  CreateAccountGui.showUsernameExistsMsg(_loc3_);
               }
            }
            else
            {
               this._caUserName = this._validateTestName;
               if(this._userNameValidGuiCallback != null)
               {
                  this._userNameValidGuiCallback(_loc3_,param1,param2);
               }
               if(param2 != CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
               {
                  CreateAccountGui.hideUsernameExistsMsg();
               }
            }
         }
         else if(param2 == CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_AVATARNAME)
         {
            if(_loc3_ == 1)
            {
               this._caAvatarName = this._validateTestAvName;
               if(this._avNameValidGuiCallback != null)
               {
                  this._avNameValidGuiCallback(true);
               }
            }
            else if(this._avNameValidGuiCallback != null)
            {
               this._avNameValidGuiCallback(false);
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
            if(_loc2_ == MainFrame.MSG_ID_LOGIN_CLIENT_MISMATCH)
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
            this._alreadyCreated = true;
            this._createdDBUserId = _loc3_;
            DebugUtility.debugTrace("Created DbUserId = " + this._createdDBUserId);
            CreateAccountGui.loginCreateSuccess(_loc3_);
         }
      }
      
      public function handleLoginEmail(param1:Object) : void
      {
         var _loc2_:Function = null;
         if(param1[2] == MainFrame.MSG_ID_LOGIN_CLIENT_MISMATCH)
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
         this._createUserLoggedIn = false;
         this._createAvatarLoggedIn = false;
      }
      
      private function onLogIn(param1:SFEvent) : void
      {
         this._loginEvent = param1;
         gMainFrame.server.setInitRoom();
         if(this.validateUserNameAutologin || this.validateAvNameAutologin || this.loginInfoAutologin)
         {
            this.loginDone();
            return;
         }
         if(this._createUser)
         {
            this._createUserLoggedIn = true;
         }
         else if(this._createAvatar)
         {
            this._createAvatarLoggedIn = true;
         }
         this.loginDone();
      }
      
      private function loginDone() : void
      {
         if(!gMainFrame.userInfo.avtDefsCached)
         {
            AvatarXtCommManager.requestAvatarInfo(this.loginDone);
            return;
         }
         CreateAccountGui.loadNameLists();
         if(this.loginInfoAutologin)
         {
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVATAR_LIST_ID,this.handleCreateAvatarData,null,false);
            return;
         }
         if(this.validateUserNameAutologin)
         {
            this.validateUserNameAutologin = false;
            this.validateUserName(this._validateTestName,this._validateTestPass,0,0,0,this._userNameValidGuiCallback);
            return;
         }
         if(this.validateAvNameAutologin)
         {
            this.validateAvNameAutologin = false;
            this.validateAvatarName(this._validateTestAvName,this._avNameIndexes[0],this._avNameIndexes[1],this._avNameIndexes[2],this._avNameValidGuiCallback);
            return;
         }
         if(this._createAvatarLoggedIn)
         {
            this.createNewAvatar();
         }
         if(this._createUserLoggedIn)
         {
            this.createNewAccount();
         }
      }
   }
}

