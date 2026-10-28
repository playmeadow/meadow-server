package
{
   import avatar.UserInfoCache;
   import com.sbi.analytics.GATracker;
   import com.sbi.analytics.SBTracker;
   import com.sbi.client.SFClient;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.loader.ImageServerURL;
   import com.sbi.loader.LoaderCache;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import gamePlayFlow.GamePlay;
   import room.LayerManager;
   
   public class MainFrame extends Sprite
   {
      
      public static const VIEW_WIDTH:int = 900;
      
      public static const VIEW_HEIGHT:int = 550;
      
      public static const ROOMS_FOLDER:String = "roomDefs/";
      
      public static const AUDIO_FOLDER:String = "audio/";
      
      public static const CDN_SALT:String = "J@mnim4L";
      
      public static const MSG_ID_LOGIN_IN_USE:int = -11;
      
      public static const MSG_ID_LOGIN_ACCT_MAINT:int = -12;
      
      public static const MSG_ID_LOGIN_CONNECTION:int = -14;
      
      public static const MSG_ID_LOGIN_BANNED:int = -15;
      
      public static const MSG_ID_LOGIN_SERVER_MAINT:int = -16;
      
      public static const MSG_ID_LOGIN_CLIENT_MISMATCH:int = -24;
      
      public static var avatarCreationLogin:MovieClip;
      
      public static var avatarCreationVO:MovieClip;
      
      public static var handleLocalExternalCall:Function;
      
      private static const _configDebugFile:String = "clientdevtest.xml";
      
      private static const _configDebugTemplateFile:String = "clientdevtest.template.xml";
      
      private static var _configLoadedCallback:Function;
      
      private static var m:MainFrame;
      
      private static var _flashVarUserName:String;
      
      private static var _client:SFClient = null;
      
      private static var _path:String = null;
      
      private static var _stage:Stage;
      
      private static var _gamePlay:DisplayObjectContainer;
      
      private static var _waitingRoom:DisplayObjectContainer;
      
      private static var _createAccount:DisplayObjectContainer;
      
      private static var _loaderCache:LoaderCache;
      
      public var userInfo:UserInfoCache;
      
      public var clientInfo:Object;
      
      public var classNames:Array;
      
      private var _layerInfo:Object;
      
      public function MainFrame()
      {
         super();
      }
      
      public static function getInstance(param1:Object = null, param2:Function = null, param3:String = "", param4:DisplayObjectContainer = null) : MainFrame
      {
         var _loc7_:Stage = null;
         var _loc8_:Boolean = false;
         var _loc5_:Shape = null;
         var _loc9_:Boolean = false;
         var _loc6_:URLLoader = null;
         if(m == null)
         {
            if(param3 == null || param4 == null || param4.stage == null)
            {
               throw new Error("ERROR: Attempted to call initial getInstance on MainFrame without correct parameters!");
            }
            _loc7_ = param4.stage;
            LoadProgress.init(_loc7_);
            LoadProgress.show(true,1);
            LoaderCache.cdnSalt = "J@mnim4L";
            _loc8_ = ExternalInterface.available;
            if(_loc8_)
            {
               DebugUtility.debugTrace("extIntAvail is true");
               DebugUtility.debugTrace("mrc dm init starting up call returned:" + ExternalInterface.call("mrc",["dm","init:starting up"]));
            }
            else
            {
               DebugUtility.debugTrace("extIntAvail is false");
            }
            _loc5_ = new Shape();
            _loc5_.graphics.clear();
            _loc5_.graphics.lineStyle(1,16777215);
            _loc5_.graphics.beginFill(16777215);
            _loc5_.graphics.drawRect(0,0,900,550);
            _loc5_.graphics.endFill();
            param4.addChild(_loc5_);
            param4.mask = _loc5_;
            _loc7_.showDefaultContextMenu = false;
            _loc7_.scaleMode = "noScale";
            m = new MainFrame();
            m.init(new Singleton(),param3,_loc7_);
            gMainFrame = m;
            _loc7_.addEventListener("keyDown",keyDownListener,false,0,true);
            _loc7_.addEventListener("rightMouseDown",onRightMouseDown,false,0,true);
            if(_loc8_)
            {
               try
               {
                  DebugUtility.debugTrace("init:adding mec callback");
                  ExternalInterface.addCallback("mec",handleLocalExternalCall);
                  DebugUtility.debugTrace("init:mec added, calling lc...");
                  ExternalInterface.call("mrc",["lc"]);
                  DebugUtility.debugTrace("init:... lc called, waiting for ixm...");
               }
               catch(e:Error)
               {
                  DebugUtility.debugTrace("init:ERROR hit during AJC ext mod setup! msg:" + e.message + " stack:" + e.getStackTrace());
               }
            }
            DebugUtility.debugTrace("init: setting extCallsActive to false");
            gMainFrame.clientInfo.extCallsActive = false;
            DebugUtility.debugTrace("init: set extCallsActive to false");
            _configLoadedCallback = param2;
            _loc9_ = param1 && param1.smartfoxServer;
            DebugUtility.debugTrace("MainFrame.getInstance - haveFlashVars:" + _loc9_);
            gMainFrame.clientInfo.devMode = !_loc9_;
            if(_loc9_)
            {
               if("username" in param1 && param1.username != undefined)
               {
                  _flashVarUserName = param1.username;
               }
               else
               {
                  _flashVarUserName = "";
               }
               DebugUtility.debugTrace("MainFrame.getInstance - flashVars.smartfoxServer:" + param1.smartfoxServer + " flashVars.smartfoxPort:" + param1.smartfoxPort + " flashVars.blueboxServer:" + param1.blueboxServer + " flashVars.blueboxPort:" + param1.blueboxPort + " flashVars.content:" + param1.content + " flashVars.website:" + param1.website);
               if(!(param1.smartfoxServer && param1.smartfoxPort && param1.blueboxServer && param1.blueboxPort && param1.content && param1.website))
               {
                  DebugUtility.debugTrace("MainFrame.getInstance - Invalid FlashVars! Throwing error...");
                  throw new Error("Invalid FlashVars!");
               }
               if(!param1.hasOwnProperty("startupRoom"))
               {
                  param1.startupRoom = "jamaa_township.room_main";
               }
               if(!param1.hasOwnProperty("worldmapRoom"))
               {
                  param1.worldmapRoom = "world_map/room_main.xroom";
               }
               if(!param1.hasOwnProperty("dangermapRoom"))
               {
                  param1.dangermapRoom = "danger_map/room_main.xroom";
               }
               if(!param1.hasOwnProperty("clientDebug"))
               {
                  param1.clientDebug = "false";
               }
               if(!param1.hasOwnProperty("forceHttpProxy"))
               {
                  param1.forceHttpProxy = "false";
               }
               if(!param1.hasOwnProperty("build_version"))
               {
                  param1.build_version = "0";
               }
               if(!param1.hasOwnProperty("deploy_version"))
               {
                  param1.deploy_version = "0";
               }
               if(!param1.hasOwnProperty("locale"))
               {
                  param1.locale = "en-US";
               }
               if(!param1.hasOwnProperty("sg_params"))
               {
                  param1.sg_params = "";
               }
               if(!param1.hasOwnProperty("buddyRoomTimerInterval"))
               {
                  param1.buddyRoomTimerInterval = "30000";
               }
               if(!param1.hasOwnProperty("countryCode"))
               {
                  param1.countryCode = "";
               }
               if(String(param1.sg_params).indexOf("%") >= 0)
               {
                  throw new Error("Invalid sg_params!");
               }
               gMainFrame.clientInfo.localMode = false;
               LoaderCache.localMode = false;
               applyConfigVars(param1);
            }
            else
            {
               _loc6_ = new URLLoader();
               _loc6_.dataFormat = "text";
               _loc6_.addEventListener("complete",configDebugLoadCompleteHandler);
               _loc6_.addEventListener("ioError",configDebugLoadIOErrorHandler);
               _loc6_.load(new URLRequest("clientdevtest.xml"));
            }
         }
         GATracker.init();
         SBTracker.create();
         return m;
      }
      
      public static function isInitialized() : Boolean
      {
         return m != null;
      }
      
      private static function keyDownListener(param1:KeyboardEvent) : void
      {
         if(gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.accountType == 5)
         {
            if(!param1.ctrlKey && param1.shiftKey && !param1.altKey && param1.keyCode == 123)
            {
               if(!_client.isConnected)
               {
                  return;
               }
               if(_gamePlay)
               {
                  _gamePlay["reconnecting"] = true;
                  _gamePlay["showLoadProgress"](true,7);
               }
               gMainFrame.clientInfo.forceHttpProxy = true;
               _client.disconnect();
            }
         }
      }
      
      private static function onRightMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.preventDefault();
      }
      
      private static function applyConfigVars(param1:Object) : void
      {
         for(var _loc7_:String in param1)
         {
            gMainFrame.clientInfo[_loc7_] = param1[_loc7_];
         }
         var _loc6_:Array = [param1.smartfoxServer];
         var _loc10_:int = 1;
         while(param1.hasOwnProperty("smartfoxServer" + _loc10_))
         {
            _loc6_.push(param1["smartfoxServer" + _loc10_]);
            _loc10_++;
         }
         var _loc8_:Array = [param1.blueboxServer];
         var _loc4_:int = 1;
         while(param1.hasOwnProperty("blueboxServer" + _loc4_))
         {
            _loc8_.push(param1["blueboxServer" + _loc4_]);
            _loc4_++;
         }
         gMainFrame.server.setServerConfig(_loc6_,param1.smartfoxPort,_loc8_,param1.blueboxPort,param1.clientDebug);
         var _loc11_:String = param1.forceHttpProxy;
         gMainFrame.clientInfo.forceHttpProxy = _loc11_ == "true";
         var _loc5_:String = "";
         if(param1.hasOwnProperty("gameSessionId"))
         {
            _loc5_ = param1.gameSessionId;
            if(_loc5_ != null && _loc5_ != "")
            {
               gMainFrame.clientInfo.sessionId = int(_loc5_);
            }
         }
         var _loc12_:String = param1.build_version;
         gMainFrame.clientInfo.buildVersion = _loc12_;
         LoaderCache.buildVersion = _loc12_;
         var _loc9_:String = param1.deploy_version;
         gMainFrame.clientInfo.deployVersion = _loc9_;
         LoaderCache.deployVersion = _loc9_;
         var _loc3_:String = param1.locale;
         gMainFrame.clientInfo.locale = _loc3_;
         gMainFrame.clientInfo.websiteURL = param1.website;
         var _loc13_:String = param1.content;
         gMainFrame.clientInfo.contentURL = _loc13_;
         LoaderCache.contentURL = _loc13_;
         var _loc14_:Boolean = param1.webRefPath == "create_account";
         gMainFrame.clientInfo.isCreateAccount = _loc14_;
         var _loc2_:Boolean = param1.waitingMode == "true";
         gMainFrame.clientInfo.waitingMode = _loc2_;
         var _loc15_:int = int(param1.buddyRoomTimerInterval);
         gMainFrame.clientInfo.buddyRoomTimerInterval = _loc15_;
         gMainFrame.clientInfo.startUpRoom = String(param1.startupRoom);
         gMainFrame.clientInfo.worldMapRoom = "roomDefs/" + param1.worldmapRoom;
         gMainFrame.clientInfo.dangerMapRoom = "roomDefs/" + param1.dangermapRoom;
         gMainFrame.clientInfo.clientDebug = param1.clientDebug;
         gMainFrame.clientInfo.sgParams = String(param1.sg_params);
         gMainFrame.clientInfo.mdUrl = String(param1.mdUrl);
         gMainFrame.clientInfo.currentTimestamp = Number(param1.currentTimestamp);
         gMainFrame.clientInfo.sbTrackerIp = String(param1.sbStatTrackerIp);
         gMainFrame.clientInfo.sbTrackerModulator = param1.sbStatModulator;
         gMainFrame.clientInfo.landingPage = String(param1.landingPage);
         gMainFrame.clientInfo.authToken = param1.auth_token;
         gMainFrame.clientInfo.countryCode = param1.countryCode;
         gMainFrame.clientInfo.playerWallHost = String(param1.playerWallHost);
         if("redemptionCode" in param1)
         {
            gMainFrame.clientInfo.redemptionCode = String(param1.redemptionCode);
         }
         if(gMainFrame.clientInfo.countryCode == undefined)
         {
            gMainFrame.clientInfo.countryCode = "";
         }
         DebugUtility.debugTrace("-configXml/flashVars info-");
         DebugUtility.debugTrace("smartfoxAddress:" + param1.smartfoxServer);
         DebugUtility.debugTrace("smartfoxPort:" + param1.smartfoxPort);
         DebugUtility.debugTrace("blueboxAddress:" + param1.blueboxServer);
         DebugUtility.debugTrace("blueboxPort:" + param1.blueboxPort);
         DebugUtility.debugTrace("gameSessionIdStr:" + _loc5_);
         DebugUtility.debugTrace("buildVersionStr:" + _loc12_);
         DebugUtility.debugTrace("deployVersionStr:" + _loc9_);
         DebugUtility.debugTrace("localeStr:" + _loc3_);
         DebugUtility.debugTrace("contentURL:" + gMainFrame.clientInfo.contentURL);
         DebugUtility.debugTrace("websiteURL:" + gMainFrame.clientInfo.websiteURL);
         DebugUtility.debugTrace("isCreateAccount:" + _loc14_ + " webRefPath:" + param1.webRefPath);
         DebugUtility.debugTrace("isWaitingMode:" + _loc2_ + " cfgVars.waitingMode:" + param1.waitingMode);
         DebugUtility.debugTrace("startUpRoom:" + gMainFrame.clientInfo.startUpRoom);
         DebugUtility.debugTrace("worldMapRoom:" + gMainFrame.clientInfo.worldMapRoom);
         DebugUtility.debugTrace("dangerMapRoom:" + gMainFrame.clientInfo.dangerMapRoom);
         DebugUtility.debugTrace("clientDebug:" + param1.clientDebug);
         DebugUtility.debugTrace("forceHttpProxy:" + param1.forceHttpProxy);
         DebugUtility.debugTrace("sgParams:" + gMainFrame.clientInfo.sgParams);
         DebugUtility.debugTrace("buddyRoomTimerInterval:" + gMainFrame.clientInfo.buddyRoomTimerInterval);
         _loaderCache = new LoaderCache();
         if(!gMainFrame.clientInfo.devMode && !gMainFrame.clientInfo.isCreateAccount && (_flashVarUserName == "" || !("auth_token" in param1) || param1.auth_token == null || param1.auth_token == undefined || param1.auth_token == ""))
         {
            gMainFrame.clientInfo.failedToInitiate = true;
         }
         _configLoadedCallback();
      }
      
      private static function configDebugLoadIOErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.dataFormat = "text";
         _loc2_.addEventListener("complete",configDebugLoadCompleteHandler);
         _loc2_.addEventListener("ioError",configDebugTemplateLoadIOErrorHandler);
         _loc2_.load(new URLRequest("clientdevtest.template.xml"));
      }
      
      private static function configDebugTemplateLoadIOErrorHandler(param1:IOErrorEvent) : void
      {
         throw new Error("IOError reading clientdevtest.xml or clientdevtest.template.xml! ioe:" + param1);
      }
      
      private static function configDebugLoadCompleteHandler(param1:Event) : void
      {
         var _loc11_:XML = new XML(param1.target.data);
         var _loc9_:XMLList = _loc11_.autoLogins.children();
         var _loc7_:int = 0;
         for each(var _loc5_:XML in _loc9_)
         {
            gMainFrame.clientInfo["autoLogin" + ++_loc7_] = [String(_loc5_.name.text()),String(_loc5_.token.text())];
         }
         var _loc6_:String = _loc11_.local.text();
         if(_loc6_ == "false")
         {
            gMainFrame.clientInfo.localMode = false;
            LoaderCache.localMode = false;
         }
         else
         {
            gMainFrame.clientInfo.localMode = true;
         }
         var _loc4_:String = _loc11_.clientDebug.text();
         if(_loc4_ != "true")
         {
            _loc4_ = "false";
         }
         var _loc10_:String = "false";
         if(_loc11_.hasOwnProperty("forceHttpProxy"))
         {
            _loc10_ = _loc11_.forceHttpProxy.text();
         }
         var _loc2_:String = "false";
         if(_loc11_.hasOwnProperty("waitingMode"))
         {
            _loc2_ = _loc11_.waitingMode.text();
         }
         var _loc3_:Object = {
            "smartfoxServer":_loc11_.smartfoxServer.text(),
            "smartfoxPort":_loc11_.smartfoxPort.text(),
            "blueboxServer":_loc11_.blueboxServer.text(),
            "blueboxPort":_loc11_.blueboxPort.text(),
            "content":_loc11_.content.text(),
            "website":_loc11_.website.text(),
            "startupRoom":_loc11_.startupRoom.text(),
            "worldmapRoom":_loc11_.worldmapRoom.text(),
            "dangermapRoom":_loc11_.dangermapRoom.text(),
            "clientDebug":_loc4_,
            "forceHttpProxy":_loc10_,
            "waitingMode":_loc2_,
            "sg_params":"",
            "mdUrl":_loc11_.mdUrl,
            "playerWallHost":_loc11_.playerWallHost.text()
         };
         var _loc8_:int = 1;
         while(_loc11_.hasOwnProperty("smartfoxServer" + _loc8_))
         {
            _loc3_["smartfoxServer" + _loc8_] = _loc11_["smartfoxServer" + _loc8_].text();
            _loc8_++;
         }
         var _loc13_:int = 1;
         while(_loc11_.hasOwnProperty("blueboxServer" + _loc13_))
         {
            _loc3_["blueboxServer" + _loc13_] = _loc11_["blueboxServer" + _loc13_].text();
            _loc13_++;
         }
         _loc3_["build_version"] = _loc11_.hasOwnProperty("build_version") ? _loc11_.build_version.text() : "0";
         _loc3_["deploy_version"] = _loc11_.hasOwnProperty("deploy_version") ? _loc11_.deploy_version.text() : "0";
         _loc3_["locale"] = _loc11_.hasOwnProperty("locale") ? _loc11_.locale.text() : "en";
         _loc3_["webRefPath"] = _loc11_.hasOwnProperty("webRefPath") ? _loc11_.webRefPath.text() : "";
         _loc3_["buddyRoomTimerInterval"] = _loc11_.hasOwnProperty("buddyRoomTimerInterval") ? _loc11_.buddyRoomTimerInterval.text() : "30000";
         for(var _loc12_:String in _loc3_)
         {
            if(_loc3_[_loc12_] is XMLList && XMLList(_loc3_[_loc12_]).length() > 1)
            {
               throw new Error("Invalid clientdevtest xml config! Found multiple tags of same name:" + _loc12_);
            }
         }
         applyConfigVars(_loc3_);
      }
      
      public function init(param1:Singleton, param2:String, param3:Stage) : void
      {
         _path = param2;
         _stage = param3;
         _client = new SFClient();
         userInfo = new UserInfoCache();
         userInfo.init();
         clientInfo = {};
         clientInfo.invisMode = false;
         classNames = null;
      }
      
      public function get server() : SFClient
      {
         return _client;
      }
      
      public function get path() : String
      {
         return _path;
      }
      
      override public function get stage() : Stage
      {
         return _stage;
      }
      
      public function set createAccount(param1:DisplayObjectContainer) : void
      {
         _createAccount = param1;
      }
      
      public function get createAccount() : DisplayObjectContainer
      {
         return _createAccount;
      }
      
      public function set waitingRoom(param1:DisplayObjectContainer) : void
      {
         _waitingRoom = param1;
      }
      
      public function get waitingRoom() : DisplayObjectContainer
      {
         return _waitingRoom;
      }
      
      public function set gamePlay(param1:DisplayObjectContainer) : void
      {
         _gamePlay = param1;
      }
      
      public function get gamePlay() : DisplayObjectContainer
      {
         return _gamePlay;
      }
      
      public function get layerManager() : LayerManager
      {
         return (_gamePlay as GamePlay).layerManager;
      }
      
      public function get loaderCache() : LoaderCache
      {
         return _loaderCache;
      }
      
      public function set layerInfo(param1:Object) : void
      {
         _layerInfo = param1;
         ImageServerURL.instance.layerInfo = param1;
      }
      
      public function get myFlashVarUserName() : String
      {
         return _flashVarUserName;
      }
      
      public function set myFlashVarUserName(param1:String) : void
      {
         _flashVarUserName = param1;
      }
      
      public function isInMinigame() : Boolean
      {
         return _gamePlay != null && _gamePlay["isInMinigame"]();
      }
      
      public function setAvatarOffsets(param1:Array) : void
      {
         LayerAnim.avOffsets = param1;
      }
      
      public function switchServersIfNeeded(param1:String) : Boolean
      {
         DebugUtility.debugTrace("switchServersIfNeeded called with newNode:" + param1);
         var _loc2_:String = param1;
         DebugUtility.debugTrace("checking new node:" + _loc2_ + " vs old node:" + _client.serverIp);
         if(_client.serverIp == _loc2_)
         {
            return false;
         }
         _gamePlay["reconnecting"] = true;
         _gamePlay["showLoadProgress"](true,7);
         _client.switchServerNode(_loc2_);
         _client.disconnect();
         return true;
      }
   }
}

class Singleton
{
   
   public function Singleton()
   {
      super();
   }
}
