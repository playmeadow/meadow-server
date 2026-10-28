package
{
   import avatar.UserInfoCache;
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
   import flash.display.StageScaleMode;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import gamePlayFlow.GamePlay;
   import room.LayerManager;
   
   public class MainFrame extends Sprite
   {
      
      public static var avatarCreationLogin:MovieClip;
      
      public static var avatarCreationVO:MovieClip;
      
      public static var handleLocalExternalCall:Function;
      
      private static var _configLoadedCallback:Function;
      
      private static var m:MainFrame;
      
      private static var _flashVarUserName:String;
      
      public static const VIEW_WIDTH:int = 900;
      
      public static const VIEW_HEIGHT:int = 550;
      
      public static const ROOMS_FOLDER:String = "roomDefs/";
      
      public static const CDN_SALT:String = "J@mnim4L";
      
      public static const MSG_ID_LOGIN_IN_USE:int = -11;
      
      public static const MSG_ID_LOGIN_ACCT_MAINT:int = -12;
      
      public static const MSG_ID_LOGIN_CONNECTION:int = -14;
      
      public static const MSG_ID_LOGIN_BANNED:int = -15;
      
      public static const MSG_ID_LOGIN_SERVER_MAINT:int = -16;
      
      public static const MSG_ID_LOGIN_CLIENT_MISMATCH:int = -24;
      
      private static const _configDebugFile:String = "clientdevtest.xml";
      
      private static const _configDebugTemplateFile:String = "clientdevtest.template.xml";
      
      private var _client:SFClient = null;
      
      private var _path:String = null;
      
      private var _stage:Stage;
      
      private var _gamePlay:DisplayObjectContainer;
      
      private var _waitingRoom:DisplayObjectContainer;
      
      private var _createAccount:DisplayObjectContainer;
      
      private var _loaderCache:LoaderCache;
      
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
         var stg:Stage = null;
         var extIntAvail:Boolean = false;
         var msk:Shape = null;
         var haveFlashVars:Boolean = false;
         var loadit:URLLoader = null;
         var flashVars:Object = param1;
         var configLoadedCallback:Function = param2;
         var path:String = param3;
         var main:DisplayObjectContainer = param4;
         if(m == null)
         {
            if(path == null || main == null || main.stage == null)
            {
               throw new Error("ERROR: Attempted to call initial getInstance on MainFrame without correct parameters!");
            }
            stg = main.stage;
            LoadProgress.init(stg);
            LoadProgress.show(true,LoadProgress.INITIALIZING);
            LoaderCache.cdnSalt = CDN_SALT;
            extIntAvail = ExternalInterface.available;
            if(extIntAvail)
            {
               DebugUtility.debugTrace("extIntAvail is true");
               DebugUtility.debugTrace("mrc dm init starting up call returned:" + ExternalInterface.call("mrc",["dm","init:starting up"]));
            }
            else
            {
               DebugUtility.debugTrace("extIntAvail is false");
            }
            msk = new Shape();
            msk.graphics.clear();
            msk.graphics.lineStyle(1,16777215);
            msk.graphics.beginFill(16777215);
            msk.graphics.drawRect(0,0,VIEW_WIDTH,VIEW_HEIGHT);
            msk.graphics.endFill();
            main.addChild(msk);
            main.mask = msk;
            stg.showDefaultContextMenu = false;
            stg.scaleMode = StageScaleMode.NO_SCALE;
            m = new MainFrame();
            m.init(new Singleton(),path,stg);
            gMainFrame = m;
            if(extIntAvail)
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
            _configLoadedCallback = configLoadedCallback;
            haveFlashVars = Boolean(flashVars && flashVars.smartfoxServer);
            DebugUtility.debugTrace("MainFrame.getInstance - haveFlashVars:" + haveFlashVars);
            gMainFrame.clientInfo.devMode = !haveFlashVars;
            if(haveFlashVars)
            {
               _flashVarUserName = flashVars.username;
               DebugUtility.debugTrace("MainFrame.getInstance - flashVars.smartfoxServer:" + flashVars.smartfoxServer + " flashVars.smartfoxPort:" + flashVars.smartfoxPort + " flashVars.blueboxServer:" + flashVars.blueboxServer + " flashVars.blueboxPort:" + flashVars.blueboxPort + " flashVars.content:" + flashVars.content + " flashVars.website:" + flashVars.website);
               if(!(Boolean(flashVars.smartfoxServer) && Boolean(flashVars.smartfoxPort) && Boolean(flashVars.blueboxServer) && Boolean(flashVars.blueboxPort) && Boolean(flashVars.content) && Boolean(flashVars.website)))
               {
                  DebugUtility.debugTrace("MainFrame.getInstance - Invalid FlashVars! Throwing error...");
                  throw new Error("Invalid FlashVars!");
               }
               if(!flashVars.hasOwnProperty("startupRoom"))
               {
                  flashVars.startupRoom = "jamaa_township.room_main";
               }
               if(!flashVars.hasOwnProperty("worldmapRoom"))
               {
                  flashVars.worldmapRoom = "world_map/room_main.xroom";
               }
               if(!flashVars.hasOwnProperty("dangermapRoom"))
               {
                  flashVars.dangermapRoom = "danger_map/room_main.xroom";
               }
               if(!flashVars.hasOwnProperty("clientDebug"))
               {
                  flashVars.clientDebug = "false";
               }
               if(!flashVars.hasOwnProperty("build_version"))
               {
                  flashVars.build_version = "0";
               }
               if(!flashVars.hasOwnProperty("deploy_version"))
               {
                  flashVars.deploy_version = "0";
               }
               if(!flashVars.hasOwnProperty("locale"))
               {
                  flashVars.locale = "en-US";
               }
               if(!flashVars.hasOwnProperty("sg_params"))
               {
                  flashVars.sg_params = "";
               }
               if(!flashVars.hasOwnProperty("buddyRoomTimerInterval"))
               {
                  flashVars.buddyRoomTimerInterval = "30000";
               }
               if(!flashVars.hasOwnProperty("countryCode"))
               {
                  flashVars.countryCode = "";
               }
               if(String(flashVars.sg_params).indexOf("%") >= 0)
               {
                  throw new Error("Invalid sg_params!");
               }
               gMainFrame.clientInfo.localMode = false;
               LoaderCache.localMode = false;
               applyConfigVars(flashVars);
            }
            else
            {
               loadit = new URLLoader();
               loadit.dataFormat = URLLoaderDataFormat.TEXT;
               loadit.addEventListener(Event.COMPLETE,configDebugLoadCompleteHandler);
               loadit.addEventListener(IOErrorEvent.IO_ERROR,configDebugLoadIOErrorHandler);
               loadit.load(new URLRequest(_configDebugFile));
            }
         }
         SBTracker.create();
         return m;
      }
      
      public static function isInitialized() : Boolean
      {
         return Boolean(m != null);
      }
      
      private static function applyConfigVars(param1:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         for(_loc2_ in param1)
         {
            gMainFrame.clientInfo[_loc2_] = param1[_loc2_];
         }
         _loc3_ = [param1.smartfoxServer];
         _loc4_ = 1;
         while(param1.hasOwnProperty("smartfoxServer" + _loc4_))
         {
            _loc3_.push(param1["smartfoxServer" + _loc4_]);
            _loc4_++;
         }
         var _loc5_:Array = [param1.blueboxServer];
         var _loc6_:int = 1;
         while(param1.hasOwnProperty("blueboxServer" + _loc6_))
         {
            _loc5_.push(param1["blueboxServer" + _loc6_]);
            _loc6_++;
         }
         gMainFrame.server.setServerConfig(_loc3_,param1.smartfoxPort,_loc5_,param1.blueboxPort,param1.clientDebug);
         var _loc7_:String = param1.build_version;
         gMainFrame.clientInfo.buildVersion = _loc7_;
         LoaderCache.buildVersion = _loc7_;
         var _loc8_:String = param1.deploy_version;
         gMainFrame.clientInfo.deployVersion = _loc8_;
         LoaderCache.deployVersion = _loc8_;
         var _loc9_:String = param1.locale;
         gMainFrame.clientInfo.locale = _loc9_;
         var _loc10_:String = param1.myExternalIp;
         gMainFrame.clientInfo.clientIp = _loc10_;
         gMainFrame.clientInfo.websiteURL = param1.website;
         var _loc11_:String = param1.content;
         gMainFrame.clientInfo.contentURL = _loc11_;
         LoaderCache.contentURL = _loc11_;
         var _loc12_:Boolean = Boolean(param1.webRefPath == "create_account");
         gMainFrame.clientInfo.isCreateAccount = _loc12_;
         var _loc13_:Boolean = Boolean(param1.waitingMode == "true");
         gMainFrame.clientInfo.waitingMode = _loc13_;
         var _loc14_:int = int(param1.buddyRoomTimerInterval);
         gMainFrame.clientInfo.buddyRoomTimerInterval = _loc14_;
         gMainFrame.clientInfo.startUpRoom = String(param1.startupRoom);
         gMainFrame.clientInfo.worldMapRoom = ROOMS_FOLDER + param1.worldmapRoom;
         gMainFrame.clientInfo.dangerMapRoom = ROOMS_FOLDER + param1.dangermapRoom;
         gMainFrame.clientInfo.clientDebug = param1.clientDebug;
         gMainFrame.clientInfo.sgParams = String(param1.sg_params);
         gMainFrame.clientInfo.mdUrl = String(param1.mdUrl);
         gMainFrame.clientInfo.currentTimestamp = Number(param1.currentTimestamp);
         gMainFrame.clientInfo.sbTrackerIp = String(param1.sbStatTrackerIp);
         gMainFrame.clientInfo.sbTrackerModulator = param1.sbStatModulator;
         gMainFrame.clientInfo.landingPage = String(param1.landingPage);
         gMainFrame.clientInfo.authToken = param1.auth_token;
         gMainFrame.clientInfo.countryCode = param1.countryCode;
         if(gMainFrame.clientInfo.countryCode == undefined)
         {
            gMainFrame.clientInfo.countryCode = "";
         }
         DebugUtility.debugTrace("-configXml/flashVars info-");
         DebugUtility.debugTrace("smartfoxAddress:" + param1.smartfoxServer);
         DebugUtility.debugTrace("smartfoxPort:" + param1.smartfoxPort);
         DebugUtility.debugTrace("blueboxAddress:" + param1.blueboxServer);
         DebugUtility.debugTrace("blueboxPort:" + param1.blueboxPort);
         DebugUtility.debugTrace("buildVersionStr:" + _loc7_);
         DebugUtility.debugTrace("deployVersionStr:" + _loc8_);
         DebugUtility.debugTrace("localeStr:" + _loc9_);
         DebugUtility.debugTrace("clientIpStr:" + _loc10_);
         DebugUtility.debugTrace("contentURL:" + gMainFrame.clientInfo.contentURL);
         DebugUtility.debugTrace("websiteURL:" + gMainFrame.clientInfo.websiteURL);
         DebugUtility.debugTrace("isCreateAccount:" + _loc12_ + " webRefPath:" + param1.webRefPath);
         DebugUtility.debugTrace("isWaitingMode:" + _loc13_ + " cfgVars.waitingMode:" + param1.waitingMode);
         DebugUtility.debugTrace("startUpRoom:" + gMainFrame.clientInfo.startUpRoom);
         DebugUtility.debugTrace("worldMapRoom:" + gMainFrame.clientInfo.worldMapRoom);
         DebugUtility.debugTrace("dangerMapRoom:" + gMainFrame.clientInfo.dangerMapRoom);
         DebugUtility.debugTrace("clientDebug:" + param1.clientDebug);
         DebugUtility.debugTrace("sgParams:" + gMainFrame.clientInfo.sgParams);
         DebugUtility.debugTrace("buddyRoomTimerInterval:" + gMainFrame.clientInfo.buddyRoomTimerInterval);
         m._loaderCache = new LoaderCache();
         _configLoadedCallback();
      }
      
      private static function configDebugLoadIOErrorHandler(param1:IOErrorEvent) : void
      {
         var _loc2_:URLLoader = new URLLoader();
         _loc2_.dataFormat = URLLoaderDataFormat.TEXT;
         _loc2_.addEventListener(Event.COMPLETE,configDebugLoadCompleteHandler);
         _loc2_.addEventListener(IOErrorEvent.IO_ERROR,configDebugTemplateLoadIOErrorHandler);
         _loc2_.load(new URLRequest(_configDebugTemplateFile));
      }
      
      private static function configDebugTemplateLoadIOErrorHandler(param1:IOErrorEvent) : void
      {
         throw new Error("IOError reading " + _configDebugFile + " or " + _configDebugTemplateFile + "! ioe:" + param1);
      }
      
      private static function configDebugLoadCompleteHandler(param1:Event) : void
      {
         var _loc5_:XML = null;
         var _loc6_:String = null;
         var _loc12_:String = null;
         var _loc2_:XML = new XML(param1.target.data);
         var _loc3_:XMLList = _loc2_.autoLogins.children();
         var _loc4_:int = 0;
         for each(_loc5_ in _loc3_)
         {
            gMainFrame.clientInfo["autoLogin" + ++_loc4_] = [String(_loc5_.name.text()),String(_loc5_.token.text())];
         }
         _loc6_ = _loc2_.local.text();
         if(_loc6_ == "false")
         {
            gMainFrame.clientInfo.localMode = false;
            LoaderCache.localMode = false;
         }
         else
         {
            gMainFrame.clientInfo.localMode = true;
         }
         var _loc7_:String = _loc2_.clientDebug.text();
         if(_loc7_ != "true")
         {
            _loc7_ = "false";
         }
         var _loc8_:String = "false";
         if(_loc2_.hasOwnProperty("waitingMode"))
         {
            _loc8_ = _loc2_.waitingMode.text();
         }
         var _loc9_:Object = {
            "smartfoxServer":_loc2_.smartfoxServer.text(),
            "smartfoxPort":_loc2_.smartfoxPort.text(),
            "blueboxServer":_loc2_.blueboxServer.text(),
            "blueboxPort":_loc2_.blueboxPort.text(),
            "content":_loc2_.content.text(),
            "website":_loc2_.website.text(),
            "startupRoom":_loc2_.startupRoom.text(),
            "worldmapRoom":_loc2_.worldmapRoom.text(),
            "dangermapRoom":_loc2_.dangermapRoom.text(),
            "clientDebug":_loc7_,
            "waitingMode":_loc8_,
            "sg_params":"",
            "mdUrl":_loc2_.mdUrl
         };
         var _loc10_:int = 1;
         while(_loc2_.hasOwnProperty("smartfoxServer" + _loc10_))
         {
            _loc9_["smartfoxServer" + _loc10_] = _loc2_["smartfoxServer" + _loc10_].text();
            _loc10_++;
         }
         var _loc11_:int = 1;
         while(_loc2_.hasOwnProperty("blueboxServer" + _loc11_))
         {
            _loc9_["blueboxServer" + _loc11_] = _loc2_["blueboxServer" + _loc11_].text();
            _loc11_++;
         }
         _loc9_["build_version"] = _loc2_.hasOwnProperty("build_version") ? _loc2_.build_version.text() : "0";
         _loc9_["deploy_version"] = _loc2_.hasOwnProperty("deploy_version") ? _loc2_.deploy_version.text() : "0";
         _loc9_["locale"] = _loc2_.hasOwnProperty("locale") ? _loc2_.locale.text() : "en";
         _loc9_["myExternalIp"] = _loc2_.hasOwnProperty("myExternalIp") ? _loc2_.myExternalIp.text() : "";
         _loc9_["webRefPath"] = _loc2_.hasOwnProperty("webRefPath") ? _loc2_.webRefPath.text() : "";
         _loc9_["buddyRoomTimerInterval"] = _loc2_.hasOwnProperty("buddyRoomTimerInterval") ? _loc2_.buddyRoomTimerInterval.text() : "30000";
         for(_loc12_ in _loc9_)
         {
            if(_loc9_[_loc12_] is XMLList && XMLList(_loc9_[_loc12_]).length() > 1)
            {
               throw new Error("Invalid clientdevtest xml config! Found multiple tags of same name:" + _loc12_);
            }
         }
         applyConfigVars(_loc9_);
      }
      
      public function init(param1:Singleton, param2:String, param3:Stage) : void
      {
         this._path = param2;
         this._stage = param3;
         this._client = new SFClient();
         this.userInfo = new UserInfoCache();
         this.userInfo.init();
         this.clientInfo = new Object();
         this.clientInfo.invisMode = false;
         this.classNames = null;
      }
      
      public function get server() : SFClient
      {
         return this._client;
      }
      
      public function get path() : String
      {
         return this._path;
      }
      
      override public function get stage() : Stage
      {
         return this._stage;
      }
      
      public function set createAccount(param1:DisplayObjectContainer) : void
      {
         this._createAccount = param1;
      }
      
      public function get createAccount() : DisplayObjectContainer
      {
         return this._createAccount;
      }
      
      public function set waitingRoom(param1:DisplayObjectContainer) : void
      {
         this._waitingRoom = param1;
      }
      
      public function get waitingRoom() : DisplayObjectContainer
      {
         return this._waitingRoom;
      }
      
      public function set gamePlay(param1:DisplayObjectContainer) : void
      {
         this._gamePlay = param1;
      }
      
      public function get gamePlay() : DisplayObjectContainer
      {
         return this._gamePlay;
      }
      
      public function get layerManager() : LayerManager
      {
         return (this._gamePlay as GamePlay).layerManager;
      }
      
      public function get loaderCache() : LoaderCache
      {
         return this._loaderCache;
      }
      
      public function set layerInfo(param1:Object) : void
      {
         this._layerInfo = param1;
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
         return this._gamePlay != null && Boolean(this._gamePlay["isInMinigame"]());
      }
      
      public function setAvatarOffsets(param1:Array) : void
      {
         LayerAnim.avOffsets = param1;
      }
      
      public function switchServersIfNeeded(param1:String) : Boolean
      {
         DebugUtility.debugTrace("switchServersIfNeeded called with newNode:" + param1);
         var _loc2_:String = param1;
         DebugUtility.debugTrace("checking new node:" + _loc2_ + " vs old node:" + this._client.serverIp);
         if(this._client.serverIp == _loc2_)
         {
            return false;
         }
         this._gamePlay["reconnecting"] = true;
         this._gamePlay["showLoadProgress"](true,LoadProgress.JOINING_SERVER);
         this._client.switchServerNode(_loc2_);
         this._client.disconnect();
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
