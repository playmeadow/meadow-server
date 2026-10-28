package it.gotoandplay.smartfoxserver
{
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.FileReference;
   import flash.net.Socket;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import it.gotoandplay.smartfoxserver.data.Room;
   import it.gotoandplay.smartfoxserver.data.User;
   import it.gotoandplay.smartfoxserver.handlers.ExtHandler;
   import it.gotoandplay.smartfoxserver.handlers.IMessageHandler;
   import it.gotoandplay.smartfoxserver.handlers.SysHandler;
   import it.gotoandplay.smartfoxserver.http.HttpConnection;
   import it.gotoandplay.smartfoxserver.http.HttpEvent;
   import it.gotoandplay.smartfoxserver.util.Entities;
   import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
   
   public class SmartFoxClient extends EventDispatcher
   {
      
      private static const EOM:int = 0;
      
      private static const MSG_XML:String = "<";
      
      private static const MSG_JSON:String = "{";
      
      private static var MSG_STR:String = "%";
      
      private static var MIN_POLL_SPEED:Number = 0;
      
      private static var DEFAULT_POLL_SPEED:Number = 750;
      
      private static var MAX_POLL_SPEED:Number = 10000;
      
      private static var HTTP_POLL_REQUEST:String = "poll";
      
      public static const MODMSG_TO_USER:String = "u";
      
      public static const MODMSG_TO_ROOM:String = "r";
      
      public static const MODMSG_TO_ZONE:String = "z";
      
      public static const XTMSG_TYPE_XML:String = "xml";
      
      public static const XTMSG_TYPE_STR:String = "str";
      
      public static const XTMSG_TYPE_JSON:String = "json";
      
      public static const CONNECTION_MODE_DISCONNECTED:String = "disconnected";
      
      public static const CONNECTION_MODE_SOCKET:String = "socket";
      
      public static const CONNECTION_MODE_HTTP:String = "http";
      
      private var byteBuffer:ByteArray = new ByteArray();
      
      public var _ingressActive:Boolean = false;
      
      private var roomList:Array;
      
      private var connected:Boolean;
      
      private var benchStartTime:int;
      
      private var sysHandler:SysHandler;
      
      private var extHandler:ExtHandler;
      
      private var majVersion:Number;
      
      private var minVersion:Number;
      
      private var subVersion:Number;
      
      private var messageHandlers:Array;
      
      private var socketConnection:Socket;
      
      private var autoConnectOnConfigSuccess:Boolean = false;
      
      private var _connectingToBluebox:Boolean = false;
      
      public var ipAddress:String;
      
      public var port:int = 9339;
      
      public var defaultZone:String;
      
      private var isHttpMode:Boolean = false;
      
      private var _httpPollSpeed:int = DEFAULT_POLL_SPEED;
      
      private var httpConnection:HttpConnection;
      
      public var blueBoxIpAddress:String;
      
      public var blueBoxPort:Number = 0;
      
      public var smartConnect:Boolean = true;
      
      public var buddyList:Array;
      
      public var myBuddyVars:Array;
      
      public var debug:Boolean;
      
      public var myUserId:int;
      
      public var myUserName:String;
      
      public var playerId:int;
      
      public var amIModerator:Boolean;
      
      public var activeRoomId:int;
      
      public var changingRoom:Boolean;
      
      public var httpPort:int = 8080;
      
      public var properties:Object = null;
      
      public function SmartFoxClient(param1:Boolean = false)
      {
         super();
         this.majVersion = 1;
         this.minVersion = 6;
         this.subVersion = 5;
         this.activeRoomId = -1;
         this.debug = param1;
         this.messageHandlers = [];
         setupMessageHandlers();
         socketConnection = new Socket();
         socketConnection.addEventListener("connect",handleSocketConnection);
         socketConnection.addEventListener("close",handleSocketDisconnection);
         socketConnection.addEventListener("socketData",handleSocketData);
         socketConnection.addEventListener("ioError",handleIOError);
         socketConnection.addEventListener("networkError",handleIOError);
         socketConnection.addEventListener("securityError",handleSecurityError);
         httpConnection = new HttpConnection();
         httpConnection.addEventListener("onHttpConnect",handleHttpConnect);
         httpConnection.addEventListener("onHttpClose",handleHttpClose);
         httpConnection.addEventListener("onHttpData",handleHttpData);
         httpConnection.addEventListener("onHttpError",handleHttpError);
      }
      
      public function get rawProtocolSeparator() : String
      {
         return MSG_STR;
      }
      
      public function set rawProtocolSeparator(param1:String) : void
      {
         if(param1 != "<" && param1 != "{")
         {
            MSG_STR = param1;
         }
      }
      
      public function get isConnected() : Boolean
      {
         return this.connected;
      }
      
      public function set isConnected(param1:Boolean) : void
      {
         this.connected = param1;
      }
      
      public function get httpPollSpeed() : int
      {
         return this._httpPollSpeed;
      }
      
      public function set httpPollSpeed(param1:int) : void
      {
         if(param1 >= 0 && param1 <= 10000)
         {
            this._httpPollSpeed = param1;
         }
      }
      
      public function loadConfig(param1:String = "config.xml", param2:Boolean = true) : void
      {
         this.autoConnectOnConfigSuccess = param2;
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.addEventListener("complete",onConfigLoadSuccess);
         _loc3_.addEventListener("ioError",onConfigLoadFailure);
         _loc3_.load(new URLRequest(param1));
      }
      
      public function getConnectionMode() : String
      {
         var _loc1_:String = "disconnected";
         if(this.isConnected)
         {
            if(this.isHttpMode)
            {
               _loc1_ = "http";
            }
            else
            {
               _loc1_ = "socket";
            }
         }
         return _loc1_;
      }
      
      public function connect(param1:String, param2:int = 9339) : void
      {
         if(!connected)
         {
            initialize();
            this.ipAddress = param1;
            this.port = param2;
            socketConnection.connect(param1,param2);
         }
         else
         {
            debugMessage("*** ALREADY CONNECTED ***");
         }
      }
      
      public function connectBluebox() : void
      {
         if(!connected)
         {
            initialize();
            tryBlueBoxConnection(new ErrorEvent("error",false,false,"Already connected when trying to force httpProxy connection?!"));
         }
         else
         {
            debugMessage("*** ALREADY HTTP CONNECTED ***");
         }
      }
      
      public function disconnect() : void
      {
         connected = false;
         if(!isHttpMode)
         {
            socketConnection.close();
         }
         else
         {
            httpConnection.close();
         }
         sysHandler.dispatchDisconnection();
      }
      
      public function addBuddy(param1:String) : void
      {
         var _loc2_:String = null;
         if(param1 != myUserName && !checkBuddyDuplicates(param1))
         {
            _loc2_ = "<n>" + param1 + "</n>";
            send({"t":"sys"},"addB",-1,_loc2_);
         }
      }
      
      public function autoJoin() : void
      {
         if(!checkRoomList())
         {
            return;
         }
         var _loc1_:Object = {"t":"sys"};
         this.send(_loc1_,"autoJoin",this.activeRoomId ? this.activeRoomId : -1,"");
      }
      
      public function clearBuddyList() : void
      {
         buddyList = [];
         send({"t":"sys"},"clearB",-1,"");
         var _loc2_:Object = {};
         _loc2_.list = buddyList;
         var _loc1_:SFSEvent = new SFSEvent("onBuddyList",_loc2_);
         dispatchEvent(_loc1_);
      }
      
      public function createRoom(param1:Object, param2:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = activeRoomId;
         }
         var _loc6_:Object = {"t":"sys"};
         var _loc10_:String = param1.isGame ? "1" : "0";
         var _loc4_:String = "1";
         var _loc3_:String = param1.maxUsers == null ? "0" : String(param1.maxUsers);
         var _loc5_:String = param1.maxSpectators == null ? "0" : String(param1.maxSpectators);
         var _loc8_:String = param1.joinAsSpectator ? "1" : "0";
         if(param1.isGame && param1.exitCurrentRoom != null)
         {
            _loc4_ = param1.exitCurrentRoom ? "1" : "0";
         }
         var _loc9_:String = "<room tmp=\'1\' gam=\'" + _loc10_ + "\' spec=\'" + _loc5_ + "\' exit=\'" + _loc4_ + "\' jas=\'" + _loc8_ + "\'>";
         _loc9_ = _loc9_ + ("<name><![CDATA[" + (param1.name == null ? "" : param1.name) + "]]></name>");
         _loc9_ = _loc9_ + ("<pwd><![CDATA[" + (param1.password == null ? "" : param1.password) + "]]></pwd>");
         _loc9_ = _loc9_ + ("<max>" + _loc3_ + "</max>");
         if(param1.uCount != null)
         {
            _loc9_ += "<uCnt>" + (param1.uCount ? "1" : "0") + "</uCnt>";
         }
         if(param1.extension != null)
         {
            _loc9_ += "<xt n=\'" + param1.extension.name;
            _loc9_ = _loc9_ + ("\' s=\'" + param1.extension.script + "\' />");
         }
         if(param1.vars == null)
         {
            _loc9_ += "<vars></vars>";
         }
         else
         {
            _loc9_ += "<vars>";
            for(var _loc7_:String in param1.vars)
            {
               _loc9_ += getXmlRoomVariable(param1.vars[_loc7_]);
            }
            _loc9_ += "</vars>";
         }
         _loc9_ += "</room>";
         send(_loc6_,"createRoom",param2,_loc9_);
      }
      
      public function getAllRooms() : Array
      {
         return roomList;
      }
      
      public function setRoomList(param1:Array) : void
      {
         this.roomList = param1;
      }
      
      public function getBuddyByName(param1:String) : Object
      {
         for each(var _loc2_:Object in buddyList)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getBuddyById(param1:int) : Object
      {
         for each(var _loc2_:Object in buddyList)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getBuddyRoom(param1:Object) : void
      {
         if(param1.id != -1)
         {
            send({"t":"sys"},"roomB",-1,"<b id=\'" + param1.id + "\' />");
         }
      }
      
      public function getRoom(param1:int) : Room
      {
         if(!checkRoomList())
         {
            return null;
         }
         return roomList[param1];
      }
      
      public function getRoomByName(param1:String) : Room
      {
         if(!checkRoomList())
         {
            return null;
         }
         var _loc3_:Room = null;
         for each(var _loc2_:Room in roomList)
         {
            if(_loc2_.getName() == param1)
            {
               _loc3_ = _loc2_;
               break;
            }
         }
         return _loc3_;
      }
      
      public function getRoomList() : void
      {
         var _loc1_:Object = {"t":"sys"};
         send(_loc1_,"getRmList",activeRoomId,"");
      }
      
      public function getActiveRoom() : Room
      {
         if(!checkRoomList() || !checkJoin())
         {
            return null;
         }
         return roomList[activeRoomId];
      }
      
      public function getRandomKey() : void
      {
         send({"t":"sys"},"rndK",-1,"");
      }
      
      public function getUploadPath() : String
      {
         return "http://" + this.ipAddress + ":" + this.httpPort + "/default/uploads/";
      }
      
      public function getVersion() : String
      {
         return this.majVersion + "." + this.minVersion + "." + this.subVersion;
      }
      
      public function joinRoom(param1:*, param2:String = "", param3:Boolean = false, param4:Boolean = false, param5:int = -1) : void
      {
         var _loc9_:Object = null;
         var _loc8_:String = null;
         var _loc12_:int = 0;
         var _loc10_:String = null;
         if(!checkRoomList())
         {
            return;
         }
         var _loc7_:int = -1;
         var _loc11_:int = param3 ? 1 : 0;
         if(!this.changingRoom)
         {
            if(typeof param1 == "number")
            {
               _loc7_ = param1;
            }
            else if(typeof param1 == "string")
            {
               for each(var _loc6_:Room in roomList)
               {
                  if(_loc6_.getName() == param1)
                  {
                     _loc7_ = _loc6_.getId();
                     break;
                  }
               }
            }
            if(_loc7_ != -1)
            {
               _loc9_ = {"t":"sys"};
               _loc8_ = param4 ? "0" : "1";
               _loc12_ = param5 > -1 ? param5 : activeRoomId;
               if(activeRoomId == -1)
               {
                  _loc8_ = "0";
                  _loc12_ = -1;
               }
               _loc10_ = "<room id=\'" + _loc7_ + "\' pwd=\'" + param2 + "\' spec=\'" + _loc11_ + "\' leave=\'" + _loc8_ + "\' old=\'" + _loc12_ + "\' />";
               send(_loc9_,"joinRoom",activeRoomId,_loc10_);
               changingRoom = true;
            }
            else
            {
               debugMessage("SmartFoxError: requested room to join does not exist!");
            }
         }
      }
      
      public function leaveRoom(param1:int) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         var _loc2_:Object = {"t":"sys"};
         var _loc3_:String = "<rm id=\'" + param1 + "\' />";
         send(_loc2_,"leaveRoom",param1,_loc3_);
      }
      
      public function loadBuddyList() : void
      {
         send({"t":"sys"},"loadB",-1,"");
      }
      
      public function login(param1:String, param2:String, param3:String) : void
      {
         var _loc4_:Object = {"t":"sys"};
         var _loc5_:String = "<login z=\'" + param1 + "\'><nick><![CDATA[" + param2 + "]]></nick><pword><![CDATA[" + param3 + "]]></pword></login>";
         send(_loc4_,"login",0,_loc5_);
      }
      
      public function logout() : void
      {
         var _loc1_:Object = {"t":"sys"};
         send(_loc1_,"logout",-1,"");
      }
      
      public function removeBuddy(param1:String) : void
      {
         var _loc7_:Object = null;
         var _loc4_:Object = null;
         var _loc8_:String = null;
         var _loc6_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc3_:Boolean = false;
         for(var _loc5_:String in buddyList)
         {
            _loc7_ = buddyList[_loc5_];
            if(_loc7_.name == param1)
            {
               delete buddyList[_loc5_];
               _loc3_ = true;
               break;
            }
         }
         if(_loc3_)
         {
            _loc4_ = {"t":"sys"};
            _loc8_ = "<n>" + param1 + "</n>";
            send(_loc4_,"remB",-1,_loc8_);
            _loc6_ = {};
            _loc6_.list = buddyList;
            _loc2_ = new SFSEvent("onBuddyList",_loc6_);
            dispatchEvent(_loc2_);
         }
      }
      
      public function roundTripBench() : void
      {
         this.benchStartTime = getTimer();
         send({"t":"sys"},"roundTrip",activeRoomId,"");
      }
      
      public function sendBuddyPermissionResponse(param1:Boolean, param2:String) : void
      {
         var _loc3_:Object = {"t":"sys"};
         var _loc4_:String = "<n res=\'" + (param1 ? "g" : "r") + "\'>" + param2 + "</n>";
         send(_loc3_,"bPrm",-1,_loc4_);
      }
      
      public function sendPublicMessage(param1:String, param2:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = activeRoomId;
         }
         var _loc3_:Object = {"t":"sys"};
         var _loc4_:String = "<txt><![CDATA[" + Entities.encodeEntities(param1) + "]]></txt>";
         send(_loc3_,"pubMsg",param2,_loc4_);
      }
      
      public function sendPrivateMessage(param1:String, param2:int, param3:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param3 == -1)
         {
            param3 = activeRoomId;
         }
         var _loc4_:Object = {"t":"sys"};
         var _loc5_:String = "<txt rcp=\'" + param2 + "\'><![CDATA[" + Entities.encodeEntities(param1) + "]]></txt>";
         send(_loc4_,"prvMsg",param3,_loc5_);
      }
      
      public function sendModeratorMessage(param1:String, param2:String, param3:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         var _loc4_:Object = {"t":"sys"};
         var _loc5_:String = "<txt t=\'" + param2 + "\' id=\'" + param3 + "\'><![CDATA[" + Entities.encodeEntities(param1) + "]]></txt>";
         send(_loc4_,"modMsg",activeRoomId,_loc5_);
      }
      
      public function sendObject(param1:Object, param2:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = activeRoomId;
         }
         var _loc4_:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(param1) + "]]>";
         var _loc3_:Object = {"t":"sys"};
         send(_loc3_,"asObj",param2,_loc4_);
      }
      
      public function sendObjectToGroup(param1:Object, param2:Array, param3:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param3 == -1)
         {
            param3 = activeRoomId;
         }
         var _loc4_:String = "";
         for(var _loc5_:String in param2)
         {
            if(!isNaN(param2[_loc5_]))
            {
               _loc4_ += param2[_loc5_] + ",";
            }
         }
         _loc4_ = _loc4_.substr(0,_loc4_.length - 1);
         param1._$$_ = _loc4_;
         var _loc6_:Object = {"t":"sys"};
         var _loc7_:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(param1) + "]]>";
         send(_loc6_,"asObjG",param3,_loc7_);
      }
      
      public function sendXtMessage(param1:String, param2:String, param3:*, param4:String = "xml", param5:int = -1) : void
      {
         var _loc13_:Object = null;
         var _loc10_:Object = null;
         var _loc9_:String = null;
         var _loc12_:String = null;
         var _loc7_:Number = NaN;
         var _loc8_:Object = null;
         var _loc11_:Object = null;
         var _loc6_:String = null;
         if(!checkRoomList())
         {
            return;
         }
         if(param5 == -1)
         {
            param5 = activeRoomId;
         }
         if(param4 == "xml")
         {
            _loc13_ = {"t":"xt"};
            _loc10_ = {
               "name":param1,
               "cmd":param2,
               "param":param3
            };
            _loc9_ = "<![CDATA[" + ObjectSerializer.getInstance().serialize(_loc10_) + "]]>";
            send(_loc13_,"xtReq",param5,_loc9_);
         }
         else if(param4 == "str")
         {
            _loc12_ = MSG_STR + "xt" + MSG_STR + param1 + MSG_STR + param2 + MSG_STR + param5 + MSG_STR;
            _loc7_ = 0;
            while(_loc7_ < param3.length)
            {
               _loc12_ += param3[_loc7_].toString() + MSG_STR;
               _loc7_++;
            }
            sendString(_loc12_);
         }
         else if(param4 == "json")
         {
            _loc8_ = {};
            _loc8_.x = param1;
            _loc8_.c = param2;
            _loc8_.r = param5;
            _loc8_.p = param3;
            _loc11_ = {};
            _loc11_.t = "xt";
            _loc11_.b = _loc8_;
            _loc6_ = JSON.stringify(_loc11_);
            sendJson(_loc6_);
         }
      }
      
      public function setBuddyBlockStatus(param1:String, param2:Boolean) : void
      {
         var _loc6_:String = null;
         var _loc5_:Object = null;
         var _loc4_:SFSEvent = null;
         var _loc3_:Object = getBuddyByName(param1);
         if(_loc3_ != null)
         {
            if(_loc3_.isBlocked != param2)
            {
               _loc3_.isBlocked = param2;
               _loc6_ = "<n x=\'" + (param2 ? "1" : "0") + "\'>" + param1 + "</n>";
               send({"t":"sys"},"setB",-1,_loc6_);
               _loc5_ = {};
               _loc5_.buddy = _loc3_;
               _loc4_ = new SFSEvent("onBuddyListUpdate",_loc5_);
               dispatchEvent(_loc4_);
            }
         }
      }
      
      public function setBuddyVariables(param1:Array) : void
      {
         var _loc5_:String = null;
         var _loc3_:Object = {"t":"sys"};
         var _loc4_:String = "<vars>";
         for(var _loc2_:String in param1)
         {
            _loc5_ = param1[_loc2_];
            if(myBuddyVars[_loc2_] != _loc5_)
            {
               myBuddyVars[_loc2_] = _loc5_;
               _loc4_ += "<var n=\'" + _loc2_ + "\'><![CDATA[" + _loc5_ + "]]></var>";
            }
         }
         _loc4_ += "</vars>";
         this.send(_loc3_,"setBvars",-1,_loc4_);
      }
      
      public function setRoomVariables(param1:Array, param2:int = -1, param3:Boolean = true) : void
      {
         var _loc6_:String = null;
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = activeRoomId;
         }
         var _loc5_:Object = {"t":"sys"};
         if(param3)
         {
            _loc6_ = "<vars>";
         }
         else
         {
            _loc6_ = "<vars so=\'0\'>";
         }
         for each(var _loc4_:Object in param1)
         {
            _loc6_ += getXmlRoomVariable(_loc4_);
         }
         _loc6_ += "</vars>";
         send(_loc5_,"setRvars",param2,_loc6_);
      }
      
      public function setUserVariables(param1:Object, param2:int = -1) : void
      {
         var _loc4_:User = null;
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param2 == -1)
         {
            param2 = activeRoomId;
         }
         var _loc3_:Object = {"t":"sys"};
         var _loc8_:Room = getActiveRoom();
         var _loc5_:User = _loc8_.getUser(myUserId);
         _loc5_.setVariables(param1);
         var _loc6_:int = _loc5_.getId();
         for each(var _loc9_:Room in getAllRooms())
         {
            _loc4_ = _loc9_.getUser(_loc6_);
            if(_loc4_ != null && _loc4_ != _loc5_)
            {
               _loc4_.setVariables(param1);
            }
         }
         var _loc7_:String = getXmlUserVariable(param1);
         send(_loc3_,"setUvars",param2,_loc7_);
      }
      
      public function switchSpectator(param1:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param1 == -1)
         {
            param1 = activeRoomId;
         }
         send({"t":"sys"},"swSpec",param1,"");
      }
      
      public function switchPlayer(param1:int = -1) : void
      {
         if(!checkRoomList() || !checkJoin())
         {
            return;
         }
         if(param1 == -1)
         {
            param1 = activeRoomId;
         }
         send({"t":"sys"},"swPl",param1,"");
      }
      
      public function uploadFile(param1:FileReference, param2:int = -1, param3:String = "", param4:int = -1) : void
      {
         if(param2 == -1)
         {
            param2 = this.myUserId;
         }
         if(param3 == "")
         {
            param3 = this.myUserName;
         }
         if(param4 == -1)
         {
            param4 = this.httpPort;
         }
         param1.upload(new URLRequest("http://" + this.ipAddress + ":" + param4 + "/default/Upload.py?id=" + param2 + "&nick=" + param3));
         debugMessage("[UPLOAD]: http://" + this.ipAddress + ":" + param4 + "/default/Upload.py?id=" + param2 + "&nick=" + param3);
      }
      
      public function __logout() : void
      {
         initialize(true);
      }
      
      public function sendString(param1:String) : void
      {
         debugMessage("[Sending - STR]: " + param1 + "\n");
         if(isHttpMode)
         {
            httpConnection.send(param1);
         }
         else
         {
            writeToSocket(param1);
         }
      }
      
      public function sendJson(param1:String) : void
      {
         debugMessage("[Sending - JSON]: " + param1 + "\n");
         if(isHttpMode)
         {
            httpConnection.send(param1);
         }
         else
         {
            writeToSocket(param1);
         }
      }
      
      public function getBenchStartTime() : int
      {
         return this.benchStartTime;
      }
      
      public function clearRoomList() : void
      {
         this.roomList = [];
      }
      
      private function initialize(param1:Boolean = false) : void
      {
         this.changingRoom = false;
         this.amIModerator = false;
         this.playerId = -1;
         this.activeRoomId = -1;
         this.myUserId = -1;
         this.myUserName = "";
         this.roomList = [];
         this.buddyList = [];
         this.myBuddyVars = [];
         if(!param1)
         {
            this.connected = false;
            this.isHttpMode = false;
         }
      }
      
      private function onConfigLoadSuccess(param1:Event) : void
      {
         var _loc2_:SFSEvent = null;
         var _loc3_:URLLoader = param1.target as URLLoader;
         var _loc4_:XML = new XML(_loc3_.data);
         this.ipAddress = this.blueBoxIpAddress = _loc4_.ip;
         this.port = int(_loc4_.port);
         this.defaultZone = _loc4_.zone;
         if(_loc4_.blueBoxIpAddress != undefined)
         {
            this.blueBoxIpAddress = _loc4_.blueBoxIpAddress;
         }
         if(_loc4_.blueBoxPort != undefined)
         {
            this.blueBoxPort = _loc4_.blueBoxPort;
         }
         if(_loc4_.debug != undefined)
         {
            this.debug = _loc4_.debug.toLowerCase() == "true" ? true : false;
         }
         if(_loc4_.smartConnect != undefined)
         {
            this.smartConnect = _loc4_.smartConnect.toLowerCase() == "true" ? true : false;
         }
         if(_loc4_.httpPort != undefined)
         {
            this.httpPort = int(_loc4_.httpPort);
         }
         if(_loc4_.httpPollSpeed != undefined)
         {
            this.httpPollSpeed = int(_loc4_.httpPollSpeed);
         }
         if(_loc4_.rawProtocolSeparator != undefined)
         {
            rawProtocolSeparator = _loc4_.rawProtocolSeparator;
         }
         if(autoConnectOnConfigSuccess)
         {
            this.connect(ipAddress,port);
         }
         else
         {
            _loc2_ = new SFSEvent("onConfigLoadSuccess",{});
            dispatchEvent(_loc2_);
         }
      }
      
      private function onConfigLoadFailure(param1:IOErrorEvent) : void
      {
         var _loc3_:Object = {"message":param1.text};
         var _loc2_:SFSEvent = new SFSEvent("onConfigLoadFailure",_loc3_);
         dispatchEvent(_loc2_);
      }
      
      private function setupMessageHandlers() : void
      {
         sysHandler = new SysHandler(this);
         extHandler = new ExtHandler(this);
         addMessageHandler("sys",sysHandler);
         addMessageHandler("xt",extHandler);
      }
      
      private function addMessageHandler(param1:String, param2:IMessageHandler) : void
      {
         if(this.messageHandlers[param1] == null)
         {
            this.messageHandlers[param1] = param2;
         }
         else
         {
            debugMessage("Warning, message handler called: " + param1 + " already exist!");
         }
      }
      
      private function debugMessage(param1:String) : void
      {
         var _loc2_:SFSEvent = null;
         if(this.debug)
         {
            DebugUtility.debugTrace(param1);
            _loc2_ = new SFSEvent("onDebugMessage",{"message":param1});
            dispatchEvent(_loc2_);
         }
      }
      
      private function send(param1:Object, param2:String, param3:Number, param4:String) : void
      {
         var _loc5_:String = makeXmlHeader(param1);
         _loc5_ = _loc5_ + ("<body action=\'" + param2 + "\' r=\'" + param3 + "\'>" + param4 + "</body>" + closeHeader());
         debugMessage("[Sending]: " + _loc5_ + "\n");
         if(isHttpMode)
         {
            httpConnection.send(_loc5_);
         }
         else
         {
            writeToSocket(_loc5_);
         }
      }
      
      private function writeToSocket(param1:String) : void
      {
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUTFBytes(param1);
         _loc2_.writeByte(0);
         socketConnection.writeBytes(_loc2_);
         socketConnection.flush();
      }
      
      private function makeXmlHeader(param1:Object) : String
      {
         var _loc3_:String = "<msg";
         for(var _loc2_:String in param1)
         {
            _loc3_ += " " + _loc2_ + "=\'" + param1[_loc2_] + "\'";
         }
         return _loc3_ + ">";
      }
      
      private function closeHeader() : String
      {
         return "</msg>";
      }
      
      private function checkBuddyDuplicates(param1:String) : Boolean
      {
         var _loc2_:Boolean = false;
         for each(var _loc3_:Object in buddyList)
         {
            if(_loc3_.name == param1)
            {
               _loc2_ = true;
               break;
            }
         }
         return _loc2_;
      }
      
      private function xmlReceived(param1:String) : void
      {
         var _loc6_:XML = new XML(param1);
         var _loc3_:String = _loc6_.@t;
         var _loc4_:String = _loc6_.body.@action;
         var _loc5_:int = int(_loc6_.body.@r);
         var _loc2_:IMessageHandler = messageHandlers[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handleMessage(_loc6_,"xml");
         }
      }
      
      private function jsonReceived(param1:String) : void
      {
         var _loc3_:Object = JSON.parse(param1);
         var _loc4_:String = _loc3_["t"];
         var _loc2_:IMessageHandler = messageHandlers[_loc4_];
         if(_loc2_ != null)
         {
            _loc2_.handleMessage(_loc3_["b"],"json");
         }
      }
      
      private function strReceived(param1:String) : void
      {
         var _loc4_:Array = param1.substr(1,param1.length - 2).split(MSG_STR);
         var _loc3_:String = _loc4_[0];
         var _loc2_:IMessageHandler = messageHandlers[_loc3_];
         if(_loc2_ != null)
         {
            _loc2_.handleMessage(_loc4_.splice(1,_loc4_.length - 1),"str");
         }
      }
      
      private function getXmlRoomVariable(param1:Object) : String
      {
         var _loc2_:String = param1.name.toString();
         var _loc7_:* = param1.val;
         var _loc4_:String = param1.priv ? "1" : "0";
         var _loc5_:String = param1.persistent ? "1" : "0";
         var _loc3_:String = null;
         var _loc6_:String = typeof _loc7_;
         if(_loc6_ == "boolean")
         {
            _loc3_ = "b";
            _loc7_ = _loc7_ ? "1" : "0";
         }
         else if(_loc6_ == "number")
         {
            _loc3_ = "n";
         }
         else if(_loc6_ == "string")
         {
            _loc3_ = "s";
         }
         else if(_loc7_ == null && _loc6_ == "object" || _loc6_ == "undefined")
         {
            _loc3_ = "x";
            _loc7_ = "";
         }
         if(_loc3_ != null)
         {
            return "<var n=\'" + _loc2_ + "\' t=\'" + _loc3_ + "\' pr=\'" + _loc4_ + "\' pe=\'" + _loc5_ + "\'><![CDATA[" + _loc7_ + "]]></var>";
         }
         return "";
      }
      
      private function getXmlUserVariable(param1:Object) : String
      {
         var _loc2_:* = undefined;
         var _loc3_:String = null;
         var _loc4_:String = null;
         var _loc5_:String = "<vars>";
         for(var _loc6_:String in param1)
         {
            _loc2_ = param1[_loc6_];
            _loc4_ = typeof _loc2_;
            _loc3_ = null;
            if(_loc4_ == "boolean")
            {
               _loc3_ = "b";
               _loc2_ = _loc2_ ? "1" : "0";
            }
            else if(_loc4_ == "number")
            {
               _loc3_ = "n";
            }
            else if(_loc4_ == "string")
            {
               _loc3_ = "s";
            }
            else if(_loc2_ == null && _loc4_ == "object" || _loc4_ == "undefined")
            {
               _loc3_ = "x";
               _loc2_ = "";
            }
            if(_loc3_ != null)
            {
               _loc5_ += "<var n=\'" + _loc6_ + "\' t=\'" + _loc3_ + "\'><![CDATA[" + _loc2_ + "]]></var>";
            }
         }
         return _loc5_ + "</vars>";
      }
      
      private function checkRoomList() : Boolean
      {
         var _loc1_:Boolean = true;
         if(roomList == null || roomList.length == 0)
         {
            _loc1_ = false;
            errorTrace("The room list is empty!\nThe client API cannot function properly until the room list is populated.\nPlease consult the documentation for more infos.");
         }
         return _loc1_;
      }
      
      private function checkJoin() : Boolean
      {
         var _loc1_:Boolean = true;
         if(activeRoomId < 0)
         {
            _loc1_ = false;
            errorTrace("You haven\'t joined any rooms!\nIn order to interact with the server you should join at least one room.\nPlease consult the documentation for more infos.");
         }
         return _loc1_;
      }
      
      private function errorTrace(param1:String) : void
      {
         trace("\n****************************************************************");
         trace("Warning:");
         trace(param1);
         trace("****************************************************************");
      }
      
      private function handleHttpConnect(param1:HttpEvent) : void
      {
         this.handleSocketConnection(null);
         connected = true;
         _connectingToBluebox = false;
         httpConnection.send(HTTP_POLL_REQUEST);
      }
      
      private function handleHttpClose(param1:HttpEvent) : void
      {
         initialize();
         var _loc2_:SFSEvent = new SFSEvent("onConnectionLost",{});
         dispatchEvent(_loc2_);
         _connectingToBluebox = false;
      }
      
      private function handleHttpData(param1:HttpEvent) : void
      {
         var _loc5_:String = null;
         var _loc4_:int = 0;
         var _loc2_:String = param1.params.data as String;
         var _loc3_:Array = _loc2_.split("\n");
         if(_loc3_[0] != "")
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length - 1)
            {
               _loc5_ = _loc3_[_loc4_];
               if(_loc5_.length > 0)
               {
                  handleMessage(_loc5_);
               }
               _loc4_++;
            }
            if(this._httpPollSpeed > 0)
            {
               setTimeout(this.handleDelayedPoll,this._httpPollSpeed);
            }
            else
            {
               handleDelayedPoll();
            }
         }
      }
      
      private function handleDelayedPoll() : void
      {
         httpConnection.send(HTTP_POLL_REQUEST);
      }
      
      private function handleHttpError(param1:HttpEvent) : void
      {
         trace("HttpError type:" + param1.type + " message:" + param1.params.message);
         if(!connected)
         {
            dispatchConnectionError();
         }
         _connectingToBluebox = false;
      }
      
      private function handleSocketConnection(param1:Event) : void
      {
         var _loc2_:Object = null;
         var _loc3_:String = null;
         if(_ingressActive)
         {
            sysHandler.handleApiOK(null);
         }
         else
         {
            _loc2_ = {"t":"sys"};
            _loc3_ = "<ver v=\'" + this.majVersion.toString() + this.minVersion.toString() + this.subVersion.toString() + "\' />";
            send(_loc2_,"verChk",0,_loc3_);
         }
      }
      
      private function handleSocketDisconnection(param1:Event) : void
      {
         initialize();
         var _loc2_:SFSEvent = new SFSEvent("onConnectionLost",{});
         dispatchEvent(_loc2_);
      }
      
      private function handleIOError(param1:IOErrorEvent) : void
      {
         trace("handleIOError evt:" + param1);
         tryBlueBoxConnection(param1);
      }
      
      private function tryBlueBoxConnection(param1:ErrorEvent) : void
      {
         var _loc3_:String = null;
         var _loc2_:int = 0;
         if(!connected)
         {
            if(!_connectingToBluebox)
            {
               if(smartConnect)
               {
                  debugMessage("Socket connection failed. Trying BlueBox");
                  isHttpMode = true;
                  _loc3_ = blueBoxIpAddress != null ? blueBoxIpAddress : ipAddress;
                  _loc2_ = int(blueBoxPort != 0 ? blueBoxPort : httpPort);
                  _connectingToBluebox = true;
                  httpConnection.connect(_loc3_,_loc2_);
               }
               else
               {
                  dispatchConnectionError();
               }
            }
         }
         else
         {
            debugMessage("[WARN] Connection error: " + param1.text);
         }
      }
      
      private function handleSocketError(param1:SecurityErrorEvent) : void
      {
         debugMessage("Socket Error: " + param1.text);
      }
      
      private function handleSecurityError(param1:SecurityErrorEvent) : void
      {
         tryBlueBoxConnection(param1);
      }
      
      private function handleSocketData(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(socketConnection.bytesAvailable);
         while(--_loc3_ >= 0)
         {
            _loc2_ = socketConnection.readByte();
            if(_loc2_ != 0)
            {
               byteBuffer.writeByte(_loc2_);
            }
            else
            {
               try
               {
                  handleMessage(byteBuffer.toString());
               }
               catch(err:Error)
               {
                  debugMessage("[WARN] Unexpected exception during handleMessage: " + err);
                  if(err.getStackTrace() != null)
                  {
                     debugMessage(err.getStackTrace());
                  }
               }
               byteBuffer = new ByteArray();
            }
         }
      }
      
      private function handleMessage(param1:String) : void
      {
         if(param1 != "ok")
         {
            debugMessage("[ RECEIVED ]: " + param1 + ", (len: " + param1.length + ")");
         }
         var _loc2_:String = param1.charAt(0);
         if(_loc2_ == "<")
         {
            xmlReceived(param1);
         }
         else if(_loc2_ == MSG_STR)
         {
            strReceived(param1);
         }
         else if(_loc2_ == "{")
         {
            jsonReceived(param1);
         }
      }
      
      private function dispatchConnectionError() : void
      {
         var _loc2_:Object = {};
         _loc2_.success = false;
         _loc2_.error = "I/O Error";
         var _loc1_:SFSEvent = new SFSEvent("onConnection",_loc2_);
         dispatchEvent(_loc1_);
      }
   }
}

