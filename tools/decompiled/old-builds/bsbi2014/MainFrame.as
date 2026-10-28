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
      
      public static function getInstance(flashVars:Object = null, configLoadedCallback:Function = null, path:String = "", main:DisplayObjectContainer = null) : MainFrame
      {
         var stg:Stage = null;
         var extIntAvail:Boolean = false;
         var msk:Shape = null;
         var haveFlashVars:Boolean = false;
         var loadit:URLLoader = null;
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
      
      private static function applyConfigVars(cfgVars:Object) : void
      {
         var p:String = null;
         var sfServers:Array = null;
         var si:int = 0;
         for(p in cfgVars)
         {
            gMainFrame.clientInfo[p] = cfgVars[p];
         }
         sfServers = [cfgVars.smartfoxServer];
         si = 1;
         while(cfgVars.hasOwnProperty("smartfoxServer" + si))
         {
            sfServers.push(cfgVars["smartfoxServer" + si]);
            si++;
         }
         var bbServers:Array = [cfgVars.blueboxServer];
         var bi:int = 1;
         while(cfgVars.hasOwnProperty("blueboxServer" + bi))
         {
            bbServers.push(cfgVars["blueboxServer" + bi]);
            bi++;
         }
         gMainFrame.server.setServerConfig(sfServers,cfgVars.smartfoxPort,bbServers,cfgVars.blueboxPort,cfgVars.clientDebug);
         var buildVersionStr:String = cfgVars.build_version;
         gMainFrame.clientInfo.buildVersion = buildVersionStr;
         LoaderCache.buildVersion = buildVersionStr;
         var deployVersionStr:String = cfgVars.deploy_version;
         gMainFrame.clientInfo.deployVersion = deployVersionStr;
         LoaderCache.deployVersion = deployVersionStr;
         var localeStr:String = cfgVars.locale;
         gMainFrame.clientInfo.locale = localeStr;
         var clientIpStr:String = cfgVars.myExternalIp;
         gMainFrame.clientInfo.clientIp = clientIpStr;
         gMainFrame.clientInfo.websiteURL = cfgVars.website;
         var contentStr:String = cfgVars.content;
         gMainFrame.clientInfo.contentURL = contentStr;
         LoaderCache.contentURL = contentStr;
         var isCreateAccount:Boolean = Boolean(cfgVars.webRefPath == "create_account");
         gMainFrame.clientInfo.isCreateAccount = isCreateAccount;
         var isWaitingMode:Boolean = Boolean(cfgVars.waitingMode == "true");
         gMainFrame.clientInfo.waitingMode = isWaitingMode;
         var buddyRoomTimerInterval:int = int(cfgVars.buddyRoomTimerInterval);
         gMainFrame.clientInfo.buddyRoomTimerInterval = buddyRoomTimerInterval;
         gMainFrame.clientInfo.startUpRoom = String(cfgVars.startupRoom);
         gMainFrame.clientInfo.worldMapRoom = ROOMS_FOLDER + cfgVars.worldmapRoom;
         gMainFrame.clientInfo.dangerMapRoom = ROOMS_FOLDER + cfgVars.dangermapRoom;
         gMainFrame.clientInfo.clientDebug = cfgVars.clientDebug;
         gMainFrame.clientInfo.sgParams = String(cfgVars.sg_params);
         gMainFrame.clientInfo.mdUrl = String(cfgVars.mdUrl);
         gMainFrame.clientInfo.currentTimestamp = Number(cfgVars.currentTimestamp);
         gMainFrame.clientInfo.sbTrackerIp = String(cfgVars.sbStatTrackerIp);
         gMainFrame.clientInfo.sbTrackerModulator = cfgVars.sbStatModulator;
         gMainFrame.clientInfo.landingPage = String(cfgVars.landingPage);
         gMainFrame.clientInfo.authToken = cfgVars.auth_token;
         gMainFrame.clientInfo.countryCode = cfgVars.countryCode;
         if(gMainFrame.clientInfo.countryCode == undefined)
         {
            gMainFrame.clientInfo.countryCode = "";
         }
         DebugUtility.debugTrace("-configXml/flashVars info-");
         DebugUtility.debugTrace("smartfoxAddress:" + cfgVars.smartfoxServer);
         DebugUtility.debugTrace("smartfoxPort:" + cfgVars.smartfoxPort);
         DebugUtility.debugTrace("blueboxAddress:" + cfgVars.blueboxServer);
         DebugUtility.debugTrace("blueboxPort:" + cfgVars.blueboxPort);
         DebugUtility.debugTrace("buildVersionStr:" + buildVersionStr);
         DebugUtility.debugTrace("deployVersionStr:" + deployVersionStr);
         DebugUtility.debugTrace("localeStr:" + localeStr);
         DebugUtility.debugTrace("clientIpStr:" + clientIpStr);
         DebugUtility.debugTrace("contentURL:" + gMainFrame.clientInfo.contentURL);
         DebugUtility.debugTrace("websiteURL:" + gMainFrame.clientInfo.websiteURL);
         DebugUtility.debugTrace("isCreateAccount:" + isCreateAccount + " webRefPath:" + cfgVars.webRefPath);
         DebugUtility.debugTrace("isWaitingMode:" + isWaitingMode + " cfgVars.waitingMode:" + cfgVars.waitingMode);
         DebugUtility.debugTrace("startUpRoom:" + gMainFrame.clientInfo.startUpRoom);
         DebugUtility.debugTrace("worldMapRoom:" + gMainFrame.clientInfo.worldMapRoom);
         DebugUtility.debugTrace("dangerMapRoom:" + gMainFrame.clientInfo.dangerMapRoom);
         DebugUtility.debugTrace("clientDebug:" + cfgVars.clientDebug);
         DebugUtility.debugTrace("sgParams:" + gMainFrame.clientInfo.sgParams);
         DebugUtility.debugTrace("buddyRoomTimerInterval:" + gMainFrame.clientInfo.buddyRoomTimerInterval);
         m._loaderCache = new LoaderCache();
         _configLoadedCallback();
      }
      
      private static function configDebugLoadIOErrorHandler(ioe:IOErrorEvent) : void
      {
         var loadit:URLLoader = new URLLoader();
         loadit.dataFormat = URLLoaderDataFormat.TEXT;
         loadit.addEventListener(Event.COMPLETE,configDebugLoadCompleteHandler);
         loadit.addEventListener(IOErrorEvent.IO_ERROR,configDebugTemplateLoadIOErrorHandler);
         loadit.load(new URLRequest(_configDebugTemplateFile));
      }
      
      private static function configDebugTemplateLoadIOErrorHandler(ioe:IOErrorEvent) : void
      {
         throw new Error("IOError reading " + _configDebugFile + " or " + _configDebugTemplateFile + "! ioe:" + ioe);
      }
      
      private static function configDebugLoadCompleteHandler(event:Event) : void
      {
         var alx:XML = null;
         var localStr:String = null;
         var xs:String = null;
         var configXml:XML = new XML(event.target.data);
         var alxl:XMLList = configXml.autoLogins.children();
         var n:int = 0;
         for each(alx in alxl)
         {
            gMainFrame.clientInfo["autoLogin" + ++n] = [String(alx.name.text()),String(alx.token.text())];
         }
         localStr = configXml.local.text();
         if(localStr == "false")
         {
            gMainFrame.clientInfo.localMode = false;
            LoaderCache.localMode = false;
         }
         else
         {
            gMainFrame.clientInfo.localMode = true;
         }
         var clientDebug:String = configXml.clientDebug.text();
         if(clientDebug != "true")
         {
            clientDebug = "false";
         }
         var isWaitingMode:String = "false";
         if(configXml.hasOwnProperty("waitingMode"))
         {
            isWaitingMode = configXml.waitingMode.text();
         }
         var xmlVars:Object = {
            "smartfoxServer":configXml.smartfoxServer.text(),
            "smartfoxPort":configXml.smartfoxPort.text(),
            "blueboxServer":configXml.blueboxServer.text(),
            "blueboxPort":configXml.blueboxPort.text(),
            "content":configXml.content.text(),
            "website":configXml.website.text(),
            "startupRoom":configXml.startupRoom.text(),
            "worldmapRoom":configXml.worldmapRoom.text(),
            "dangermapRoom":configXml.dangermapRoom.text(),
            "clientDebug":clientDebug,
            "waitingMode":isWaitingMode,
            "sg_params":"",
            "mdUrl":configXml.mdUrl
         };
         var xsi:int = 1;
         while(configXml.hasOwnProperty("smartfoxServer" + xsi))
         {
            xmlVars["smartfoxServer" + xsi] = configXml["smartfoxServer" + xsi].text();
            xsi++;
         }
         var xbi:int = 1;
         while(configXml.hasOwnProperty("blueboxServer" + xbi))
         {
            xmlVars["blueboxServer" + xbi] = configXml["blueboxServer" + xbi].text();
            xbi++;
         }
         xmlVars["build_version"] = configXml.hasOwnProperty("build_version") ? configXml.build_version.text() : "0";
         xmlVars["deploy_version"] = configXml.hasOwnProperty("deploy_version") ? configXml.deploy_version.text() : "0";
         xmlVars["locale"] = configXml.hasOwnProperty("locale") ? configXml.locale.text() : "en";
         xmlVars["myExternalIp"] = configXml.hasOwnProperty("myExternalIp") ? configXml.myExternalIp.text() : "";
         xmlVars["webRefPath"] = configXml.hasOwnProperty("webRefPath") ? configXml.webRefPath.text() : "";
         xmlVars["buddyRoomTimerInterval"] = configXml.hasOwnProperty("buddyRoomTimerInterval") ? configXml.buddyRoomTimerInterval.text() : "30000";
         for(xs in xmlVars)
         {
            if(xmlVars[xs] is XMLList && XMLList(xmlVars[xs]).length() > 1)
            {
               throw new Error("Invalid clientdevtest xml config! Found multiple tags of same name:" + xs);
            }
         }
         applyConfigVars(xmlVars);
      }
      
      public function init(s:Singleton, path:String, st:Stage) : void
      {
         this._path = path;
         this._stage = st;
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
      
      public function set createAccount(newCreateAccount:DisplayObjectContainer) : void
      {
         this._createAccount = newCreateAccount;
      }
      
      public function get createAccount() : DisplayObjectContainer
      {
         return this._createAccount;
      }
      
      public function set waitingRoom(newWaitingRoom:DisplayObjectContainer) : void
      {
         this._waitingRoom = newWaitingRoom;
      }
      
      public function get waitingRoom() : DisplayObjectContainer
      {
         return this._waitingRoom;
      }
      
      public function set gamePlay(newGamePlay:DisplayObjectContainer) : void
      {
         this._gamePlay = newGamePlay;
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
      
      public function set layerInfo(o:Object) : void
      {
         this._layerInfo = o;
         ImageServerURL.instance.layerInfo = o;
      }
      
      public function get myFlashVarUserName() : String
      {
         return _flashVarUserName;
      }
      
      public function set myFlashVarUserName(name:String) : void
      {
         _flashVarUserName = name;
      }
      
      public function isInMinigame() : Boolean
      {
         return this._gamePlay != null && Boolean(this._gamePlay["isInMinigame"]());
      }
      
      public function setAvatarOffsets(a:Array) : void
      {
         LayerAnim.avOffsets = a;
      }
      
      public function switchServersIfNeeded(newNode:String) : Boolean
      {
         DebugUtility.debugTrace("switchServersIfNeeded called with newNode:" + newNode);
         var newServerNodeIp:String = newNode;
         DebugUtility.debugTrace("checking new node:" + newServerNodeIp + " vs old node:" + this._client.serverIp);
         if(this._client.serverIp == newServerNodeIp)
         {
            return false;
         }
         this._gamePlay["reconnecting"] = true;
         this._gamePlay["showLoadProgress"](true,LoadProgress.JOINING_SERVER);
         this._client.switchServerNode(newServerNodeIp);
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
