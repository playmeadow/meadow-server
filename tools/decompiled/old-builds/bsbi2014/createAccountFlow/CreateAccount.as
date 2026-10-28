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
      
      private var _avatarTypes:Array;
      
      private var _creationAvatars:Array;
      
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
      
      private var _connectEvent:Event;
      
      private var _loginEvent:Event;
      
      private var _avNameIndexes:Array;
      
      public function CreateAccount(initFlashVarParams:Object)
      {
         super();
         this._createAccountFlashVars = initFlashVarParams;
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
         this._avatarTypes = [];
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
      
      private function handleGamePalette(ise:ImageServerEvent) : void
      {
         ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_GLOBAL_PALETTE,this.handleGamePalette);
         if(Boolean(ise) && Boolean(ise.genericData))
         {
            PaletteHelper.setGamePalette(ise.genericData.palette,ise.genericData.avatarPalette1,ise.genericData.avatarPalette2);
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
      
      public function get creationAvatars() : Array
      {
         return this._creationAvatars;
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
      
      private function loadComplete(e:Event) : void
      {
         gMainFrame.server.disconnect();
         this.destroy();
         AJClient(this.parent).setupGamePlay(this._loginEvent,this._connectEvent);
      }
      
      private function ioError(e:IOError) : void
      {
         DebugUtility.debugTrace("IO Error while trying to redirect to autologin (and then world)!");
      }
      
      public function heartbeat(evt:Event) : void
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
      
      private function onConnect(evt:SFEvent) : void
      {
         this._connectEvent = evt;
         if(evt.status)
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
         else if(!gMainFrame.server.autoAttemptHttp)
         {
            if(this._nextNewAccountServerIdx < gMainFrame.server.serverIps.length)
            {
               gMainFrame.server.setNewServer(this._nextNewAccountServerIdx);
               DebugUtility.debugTrace("trying next regular Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
               ++this._nextNewAccountServerIdx;
            }
            else
            {
               gMainFrame.server.autoAttemptHttp = true;
               this._nextNewAccountServerIdx = 0;
               gMainFrame.server.setNewServer(this._nextNewAccountServerIdx);
               DebugUtility.debugTrace("trying first bluebox Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
            }
         }
         else
         {
            DebugUtility.debugTrace("bluebox connect fail serverIp:" + gMainFrame.server.serverIp + " _nextNewAccountServerIdx:" + this._nextNewAccountServerIdx);
            if(this._nextNewAccountServerIdx < gMainFrame.server.blueboxIps.length)
            {
               gMainFrame.server.setNewServer(this._nextNewAccountServerIdx);
               DebugUtility.debugTrace("trying next bluebox Server Node: " + gMainFrame.server.serverIp);
               gMainFrame.server.connect();
               ++this._nextNewAccountServerIdx;
            }
            else
            {
               DebugUtility.debugTrace("entire new account cluster is down! _nextNewAccountServerIdx:" + this._nextNewAccountServerIdx);
               CreateAccountGui.showConnectFailedPopup();
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
      
      public function newAvatarData(type:int, avatarName:String, avatarNameIndexes:Array, avNameValidGuiCallback:Function, isShopBuy:Boolean = false) : void
      {
         var index:int = AvatarUtility.findAvatarIndexByType(type);
         this._caAvatarType = this._avatarTypes[index];
         this._showAvatar = this._creationAvatars[index];
         this._caAvatarNameIndexes = avatarNameIndexes;
         this.validateAvatarName(avatarName,this._caAvatarNameIndexes[0],this._caAvatarNameIndexes[1],this._caAvatarNameIndexes[2],avNameValidGuiCallback);
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
      
      public function handleCreateAvatarData(cad:Array) : void
      {
         if(gMainFrame.server.isLoggedIn)
         {
            this.loginInfoAutologin = false;
            DebugUtility.debugTrace("dealing with create avatar data now:" + cad);
            AvatarUtility.buildCreationAvatarViews(cad,true);
            this._avatarTypes = AvatarUtility.avatarTypes;
            this._creationAvatars = AvatarUtility.creationAvatars;
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
      
      public function validateUserName(testname:String, testpass:String, userNameIndex0:int, userNameIndex1:int, userNameIndex2:int, userNameValidCallback:Function, availableRequestType:int = 0) : void
      {
         this._userNameValidGuiCallback = userNameValidCallback;
         if(Boolean(testname && testname != "") && Boolean(RegExp(/\W/)["exec"](testname) == null) && !RegExp(/^[a-zA-Z0-9].*[A-Z]+.*/).test(testname))
         {
            if(testpass == null || testpass.toLowerCase().indexOf(testname.toLowerCase()) < 0)
            {
               if(!gMainFrame.server.isConnected)
               {
                  this.validateUserNameAutoconnect = true;
                  this._validateTestName = testname;
                  this._validateTestPass = testpass;
                  CreateAccountGui.showConnectingMsg();
                  gMainFrame.server.connect();
                  return;
               }
               if(gMainFrame.server.isLoggedIn)
               {
                  this._validateTestName = testname;
                  this._validateTestPass = testpass;
                  CreateAccountXtCommManager.sendLoginAvailableRequest(availableRequestType,this._validateTestName,0,0,0);
               }
               else
               {
                  this.validateUserNameAutologin = true;
                  this._validateTestName = testname;
                  this._validateTestPass = testpass;
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
      
      public function validatePassWord(testpass:String, userName:String, validateCallback:Function) : void
      {
         if(Boolean(testpass) && Boolean(testpass != "") && testpass.length >= CreateAccountGui.MIN_PASSWORD_LENGTH)
         {
            if(testpass.toLowerCase().indexOf(userName.toLowerCase()) >= 0)
            {
               CreateAccountGui.showNewPasswordBadMsg(CreateAccountGui.MSG_ID_PASSWORD_SAME_AS_UN);
               validateCallback(false);
            }
            else
            {
               this._caUserPass = testpass;
               CreateAccountGui.hideNotifyPopup();
               validateCallback(true);
            }
         }
         else
         {
            CreateAccountGui.showNewPasswordBadMsg();
            validateCallback(false);
         }
      }
      
      public function validateAvatarName(testname:String, avatarNameIndex0:int, avatarNameIndex1:int, avatarNameIndex2:int, avNameValidCallback:Function) : void
      {
         this._avNameValidGuiCallback = avNameValidCallback;
         if(Boolean(testname) && Boolean(testname != "") && RegExp(/a-zA-Z0-9 /)["exec"](testname) == null)
         {
            this._validateTestAvName = testname;
            if(!gMainFrame.server.isConnected)
            {
               this.validateAvNameAutoconnect = true;
               CreateAccountGui.showConnectingMsg();
               gMainFrame.server.connect();
               return;
            }
            if(gMainFrame.server.isLoggedIn)
            {
               CreateAccountXtCommManager.sendLoginAvailableRequest(CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_AVATARNAME,"",avatarNameIndex0,avatarNameIndex1,avatarNameIndex2);
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
      
      public function setBirthday(bdayMonthText:String, bdayDayText:String, bdayAgeText:String) : void
      {
         var nowDate:Date = null;
         var bdayYear:int = 0;
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
      
      public function setGender(genderIdx:int) : void
      {
         this._caGender = genderIdx;
      }
      
      public function screenInitCallback(soundBtn:MovieClip) : void
      {
      }
      
      public function get playSound() : Boolean
      {
         return true;
      }
      
      private function createNewAccount() : void
      {
         var lc:Array = null;
         var ln:Array = null;
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
            lc = [this._caUserName,this._caUserEmail,SBCrypto.encrypt(this._caUserPass,gMainFrame.server.hashKey),this._caBirthday,this._caGender,this._loginRedemptionCode,gMainFrame.clientInfo.sgParams];
            if(!this._caAvatarNameIndexes[0] || !this._caAvatarNameIndexes[1] || !this._caAvatarNameIndexes[2])
            {
               AJClient.globalErrorDebugTxt.text = "null avatarname index! _caAvatarNameIndexes:" + this._caAvatarNameIndexes;
               gMainFrame.stage.addChild(AJClient.globalErrorDebugTxt);
               AJClient.globalErrorDebugTxt.visible = true;
            }
            ln = [0,this._caUserName,this._caAvatarNameIndexes[0],LocalizationManager.isCurrLanguageReversed() ? this._caAvatarNameIndexes[2] : this._caAvatarNameIndexes[1],LocalizationManager.isCurrLanguageReversed() ? this._caAvatarNameIndexes[1] : this._caAvatarNameIndexes[2],this._caAvatarType,this._showAvatar.colors[0],this._showAvatar.colors[1],this._showAvatar.colors[2],this._showAvatar.accShownItems];
            CreateAccountXtCommManager.sendLoginCreateRequest(lc,ln);
         }
         else
         {
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
      }
      
      public function createNewAccountSetup(btnUserEmail:String, btnGuiCallback:Function = null) : void
      {
         if(this._alreadyCreated && this._caUserEmail == btnUserEmail)
         {
            CreateAccountGui.loginCreateSuccess(this._createdDBUserId);
            return;
         }
         CreateAccountGui.loginCreateGuiCallback = btnGuiCallback;
         this._caUserEmail = btnUserEmail;
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
         var ln:Array = null;
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
            ln = [this._caUserName,this._caAvatarNameIndexes[0],this._caAvatarNameIndexes[1],this._caAvatarNameIndexes[2],this._caAvatarType,this._showAvatar.colors[0],this._showAvatar.colors[1],this._showAvatar.colors[2],this._showAvatar.accShownItems];
            CreateAccountXtCommManager.sendLoginNewRequest(ln);
         }
         else
         {
            gMainFrame.server.logIn("sbiAccountZone","","");
         }
      }
      
      public function createNewAvatarPrep(slotIdx:int = 0) : void
      {
      }
      
      public function nameTypeScreenDone() : void
      {
      }
      
      public function handleLoginAvailable(data:Array, returnType:int) : void
      {
         if(this._ignoreValidation)
         {
            this._ignoreValidation = false;
            return;
         }
         var dataStatus:int = int(data[2]);
         if(returnType == CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_USERNAME || returnType == CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
         {
            if(dataStatus != 1)
            {
               this._caUserName = null;
               if(this._userNameValidGuiCallback != null)
               {
                  this._userNameValidGuiCallback(dataStatus,data,returnType);
               }
               if(returnType != CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
               {
                  CreateAccountGui.showUsernameExistsMsg(dataStatus);
               }
            }
            else
            {
               this._caUserName = this._validateTestName;
               if(this._userNameValidGuiCallback != null)
               {
                  this._userNameValidGuiCallback(dataStatus,data,returnType);
               }
               if(returnType != CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_SUGGESTIONS)
               {
                  CreateAccountGui.hideUsernameExistsMsg();
               }
            }
         }
         else if(returnType == CreateAccountXtCommManager.LOGINAVAILABLE_TYPE_AVATARNAME)
         {
            if(dataStatus == 1)
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
            CreateAccountGui.avatarNameValidateCallback(dataStatus);
         }
      }
      
      public function handleLoginCreate(data:Array) : void
      {
         var dataStatus:int = int(data[2]);
         var dbUserId:int = int(data[3]);
         if(dataStatus <= 0)
         {
            DarkenManager.showLoadingSpiral(false);
            CreateAccountGui.showLoginCreateResultMsg(dataStatus);
         }
         else
         {
            gMainFrame.server.logOut();
            this._alreadyCreated = true;
            this._createdDBUserId = dbUserId;
            DebugUtility.debugTrace("Created DbUserId = " + this._createdDBUserId);
            CreateAccountGui.loginCreateSuccess(dbUserId);
         }
      }
      
      public function handleLoginEmail(params:Object) : void
      {
         var funcToCall:Function = CreateAccountGui.emailValidationCallback();
         funcToCall(params[2] == "0",params[2] == "0",true);
      }
      
      public function handleLocalExternalCall(params:Object) : void
      {
      }
      
      private function onLogOut(evt:SFEvent) : void
      {
         this._createUserLoggedIn = false;
         this._createAvatarLoggedIn = false;
      }
      
      private function onLogIn(evt:SFEvent) : void
      {
         this._loginEvent = evt;
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

