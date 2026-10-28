package it.gotoandplay.smartfoxserver
{
   import com.adobe.serialization.json.JSON;
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
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
      
      public function SmartFoxClient(debug:Boolean = false)
      {
         super();
         this.majVersion = 1;
         this.minVersion = 6;
         this.subVersion = 5;
         this.activeRoomId = -1;
         this.debug = debug;
         this.messageHandlers = [];
         this.setupMessageHandlers();
         this.socketConnection = new Socket();
         this.socketConnection.addEventListener(Event.CONNECT,this.handleSocketConnection);
         this.socketConnection.addEventListener(Event.CLOSE,this.handleSocketDisconnection);
         this.socketConnection.addEventListener(ProgressEvent.SOCKET_DATA,this.handleSocketData);
         this.socketConnection.addEventListener(IOErrorEvent.IO_ERROR,this.handleIOError);
         this.socketConnection.addEventListener(IOErrorEvent.NETWORK_ERROR,this.handleIOError);
         this.socketConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.handleSecurityError);
         this.httpConnection = new HttpConnection();
         this.httpConnection.addEventListener(HttpEvent.onHttpConnect,this.handleHttpConnect);
         this.httpConnection.addEventListener(HttpEvent.onHttpClose,this.handleHttpClose);
         this.httpConnection.addEventListener(HttpEvent.onHttpData,this.handleHttpData);
         this.httpConnection.addEventListener(HttpEvent.onHttpError,this.handleHttpError);
      }
      
      public function get rawProtocolSeparator() : String
      {
         return MSG_STR;
      }
      
      public function set rawProtocolSeparator(value:String) : void
      {
         if(value != "<" && value != "{")
         {
            MSG_STR = value;
         }
      }
      
      public function get isConnected() : Boolean
      {
         return this.connected;
      }
      
      public function set isConnected(b:Boolean) : void
      {
         this.connected = b;
      }
      
      public function get httpPollSpeed() : int
      {
         return this._httpPollSpeed;
      }
      
      public function set httpPollSpeed(sp:int) : void
      {
         if(sp >= 0 && sp <= 10000)
         {
            this._httpPollSpeed = sp;
         }
      }
      
      public function loadConfig(configFile:String = "config.xml", autoConnect:Boolean = true) : void
      {
         this.autoConnectOnConfigSuccess = autoConnect;
         var loader:URLLoader = new URLLoader();
         loader.addEventListener(Event.COMPLETE,this.onConfigLoadSuccess);
         loader.addEventListener(IOErrorEvent.IO_ERROR,this.onConfigLoadFailure);
         loader.load(new URLRequest(configFile));
      }
      
      public function getConnectionMode() : String
      {
         var mode:String = CONNECTION_MODE_DISCONNECTED;
         if(this.isConnected)
         {
            if(this.isHttpMode)
            {
               mode = CONNECTION_MODE_HTTP;
            }
            else
            {
               mode = CONNECTION_MODE_SOCKET;
            }
         }
         return mode;
      }
      
      public function connect(ipAdr:String, port:int = 9339) : void
      {
         if(!this.connected)
         {
            this.initialize();
            this.ipAddress = ipAdr;
            this.port = port;
            this.socketConnection.connect(ipAdr,port);
         }
         else
         {
            this.debugMessage("*** ALREADY CONNECTED ***");
         }
      }
      
      public function disconnect() : void
      {
         this.connected = false;
         if(!this.isHttpMode)
         {
            this.socketConnection.close();
         }
         else
         {
            this.httpConnection.close();
         }
         this.sysHandler.dispatchDisconnection();
      }
      
      public function addBuddy(buddyName:String) : void
      {
         var xmlMsg:String = null;
         if(buddyName != this.myUserName && !this.checkBuddyDuplicates(buddyName))
         {
            xmlMsg = "<n>" + buddyName + "</n>";
            this.send({"t":"sys"},"addB",-1,xmlMsg);
         }
      }
      
      public function autoJoin() : void
      {
         if(!this.checkRoomList())
         {
            return;
         }
         var header:Object = {"t":"sys"};
         this.send(header,"autoJoin",Boolean(this.activeRoomId) ? this.activeRoomId : -1,"");
      }
      
      public function clearBuddyList() : void
      {
         this.buddyList = [];
         this.send({"t":"sys"},"clearB",-1,"");
         var params:Object = {};
         params.list = this.buddyList;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyList,params);
         dispatchEvent(evt);
      }
      
      public function createRoom(roomObj:Object, roomId:int = -1) : void
      {
         var i:String = null;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var header:Object = {"t":"sys"};
         var isGame:String = Boolean(roomObj.isGame) ? "1" : "0";
         var exitCurrentRoom:String = "1";
         var maxUsers:String = roomObj.maxUsers == null ? "0" : String(roomObj.maxUsers);
         var maxSpectators:String = roomObj.maxSpectators == null ? "0" : String(roomObj.maxSpectators);
         var joinAsSpectator:String = Boolean(roomObj.joinAsSpectator) ? "1" : "0";
         if(Boolean(roomObj.isGame) && roomObj.exitCurrentRoom != null)
         {
            exitCurrentRoom = Boolean(roomObj.exitCurrentRoom) ? "1" : "0";
         }
         var xmlMsg:String = "<room tmp=\'1\' gam=\'" + isGame + "\' spec=\'" + maxSpectators + "\' exit=\'" + exitCurrentRoom + "\' jas=\'" + joinAsSpectator + "\'>";
         xmlMsg += "<name><![CDATA[" + (roomObj.name == null ? "" : roomObj.name) + "]]></name>";
         xmlMsg += "<pwd><![CDATA[" + (roomObj.password == null ? "" : roomObj.password) + "]]></pwd>";
         xmlMsg += "<max>" + maxUsers + "</max>";
         if(roomObj.uCount != null)
         {
            xmlMsg += "<uCnt>" + (Boolean(roomObj.uCount) ? "1" : "0") + "</uCnt>";
         }
         if(roomObj.extension != null)
         {
            xmlMsg += "<xt n=\'" + roomObj.extension.name;
            xmlMsg += "\' s=\'" + roomObj.extension.script + "\' />";
         }
         if(roomObj.vars == null)
         {
            xmlMsg += "<vars></vars>";
         }
         else
         {
            xmlMsg += "<vars>";
            for(i in roomObj.vars)
            {
               xmlMsg += this.getXmlRoomVariable(roomObj.vars[i]);
            }
            xmlMsg += "</vars>";
         }
         xmlMsg += "</room>";
         this.send(header,"createRoom",roomId,xmlMsg);
      }
      
      public function getAllRooms() : Array
      {
         return this.roomList;
      }
      
      public function setRoomList(roomList:Array) : void
      {
         this.roomList = roomList;
      }
      
      public function getBuddyByName(buddyName:String) : Object
      {
         var buddy:Object = null;
         for each(buddy in this.buddyList)
         {
            if(buddy.name == buddyName)
            {
               return buddy;
            }
         }
         return null;
      }
      
      public function getBuddyById(id:int) : Object
      {
         var buddy:Object = null;
         for each(buddy in this.buddyList)
         {
            if(buddy.id == id)
            {
               return buddy;
            }
         }
         return null;
      }
      
      public function getBuddyRoom(buddy:Object) : void
      {
         if(buddy.id != -1)
         {
            this.send({"t":"sys"},"roomB",-1,"<b id=\'" + buddy.id + "\' />");
         }
      }
      
      public function getRoom(roomId:int) : Room
      {
         if(!this.checkRoomList())
         {
            return null;
         }
         return this.roomList[roomId];
      }
      
      public function getRoomByName(roomName:String) : Room
      {
         var r:Room = null;
         if(!this.checkRoomList())
         {
            return null;
         }
         var room:Room = null;
         for each(r in this.roomList)
         {
            if(r.getName() == roomName)
            {
               room = r;
               break;
            }
         }
         return room;
      }
      
      public function getRoomList() : void
      {
         var header:Object = {"t":"sys"};
         this.send(header,"getRmList",this.activeRoomId,"");
      }
      
      public function getActiveRoom() : Room
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return null;
         }
         return this.roomList[this.activeRoomId];
      }
      
      public function getRandomKey() : void
      {
         this.send({"t":"sys"},"rndK",-1,"");
      }
      
      public function getUploadPath() : String
      {
         return "http://" + this.ipAddress + ":" + this.httpPort + "/default/uploads/";
      }
      
      public function getVersion() : String
      {
         return this.majVersion + "." + this.minVersion + "." + this.subVersion;
      }
      
      public function joinRoom(newRoom:*, pword:String = "", isSpectator:Boolean = false, dontLeave:Boolean = false, oldRoom:int = -1) : void
      {
         var r:Room = null;
         var header:Object = null;
         var leaveCurrRoom:String = null;
         var roomToLeave:int = 0;
         var message:String = null;
         if(!this.checkRoomList())
         {
            return;
         }
         var newRoomId:int = -1;
         var isSpec:int = isSpectator ? 1 : 0;
         if(!this.changingRoom)
         {
            if(typeof newRoom == "number")
            {
               newRoomId = int(newRoom);
            }
            else if(typeof newRoom == "string")
            {
               for each(r in this.roomList)
               {
                  if(r.getName() == newRoom)
                  {
                     newRoomId = r.getId();
                     break;
                  }
               }
            }
            if(newRoomId != -1)
            {
               header = {"t":"sys"};
               leaveCurrRoom = dontLeave ? "0" : "1";
               roomToLeave = oldRoom > -1 ? oldRoom : this.activeRoomId;
               if(this.activeRoomId == -1)
               {
                  leaveCurrRoom = "0";
                  roomToLeave = -1;
               }
               message = "<room id=\'" + newRoomId + "\' pwd=\'" + pword + "\' spec=\'" + isSpec + "\' leave=\'" + leaveCurrRoom + "\' old=\'" + roomToLeave + "\' />";
               this.send(header,"joinRoom",this.activeRoomId,message);
               this.changingRoom = true;
            }
            else
            {
               this.debugMessage("SmartFoxError: requested room to join does not exist!");
            }
         }
      }
      
      public function leaveRoom(roomId:int) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<rm id=\'" + roomId + "\' />";
         this.send(header,"leaveRoom",roomId,xmlMsg);
      }
      
      public function loadBuddyList() : void
      {
         this.send({"t":"sys"},"loadB",-1,"");
      }
      
      public function login(zone:String, name:String, pass:String) : void
      {
         var header:Object = {"t":"sys"};
         var message:String = "<login z=\'" + zone + "\'><nick><![CDATA[" + name + "]]></nick><pword><![CDATA[" + pass + "]]></pword></login>";
         this.send(header,"login",0,message);
      }
      
      public function logout() : void
      {
         var header:Object = {"t":"sys"};
         this.send(header,"logout",-1,"");
      }
      
      public function removeBuddy(buddyName:String) : void
      {
         var buddy:Object = null;
         var it:String = null;
         var header:Object = null;
         var xmlMsg:String = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var found:Boolean = false;
         for(it in this.buddyList)
         {
            buddy = this.buddyList[it];
            if(buddy.name == buddyName)
            {
               delete this.buddyList[it];
               found = true;
               break;
            }
         }
         if(found)
         {
            header = {"t":"sys"};
            xmlMsg = "<n>" + buddyName + "</n>";
            this.send(header,"remB",-1,xmlMsg);
            params = {};
            params.list = this.buddyList;
            evt = new SFSEvent(SFSEvent.onBuddyList,params);
            dispatchEvent(evt);
         }
      }
      
      public function roundTripBench() : void
      {
         this.benchStartTime = getTimer();
         this.send({"t":"sys"},"roundTrip",this.activeRoomId,"");
      }
      
      public function sendBuddyPermissionResponse(allowBuddy:Boolean, targetBuddy:String) : void
      {
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<n res=\'" + (allowBuddy ? "g" : "r") + "\'>" + targetBuddy + "</n>";
         this.send(header,"bPrm",-1,xmlMsg);
      }
      
      public function sendPublicMessage(message:String, roomId:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<txt><![CDATA[" + Entities.encodeEntities(message) + "]]></txt>";
         this.send(header,"pubMsg",roomId,xmlMsg);
      }
      
      public function sendPrivateMessage(message:String, recipientId:int, roomId:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<txt rcp=\'" + recipientId + "\'><![CDATA[" + Entities.encodeEntities(message) + "]]></txt>";
         this.send(header,"prvMsg",roomId,xmlMsg);
      }
      
      public function sendModeratorMessage(message:String, type:String, id:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<txt t=\'" + type + "\' id=\'" + id + "\'><![CDATA[" + Entities.encodeEntities(message) + "]]></txt>";
         this.send(header,"modMsg",this.activeRoomId,xmlMsg);
      }
      
      public function sendObject(obj:Object, roomId:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var xmlData:String = "<![CDATA[" + ObjectSerializer.getInstance().serialize(obj) + "]]>";
         var header:Object = {"t":"sys"};
         this.send(header,"asObj",roomId,xmlData);
      }
      
      public function sendObjectToGroup(obj:Object, userList:Array, roomId:int = -1) : void
      {
         var i:String = null;
         var header:Object = null;
         var xmlMsg:String = null;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var strList:String = "";
         for(i in userList)
         {
            if(!isNaN(userList[i]))
            {
               strList += userList[i] + ",";
            }
         }
         strList = strList.substr(0,strList.length - 1);
         obj._$$_ = strList;
         header = {"t":"sys"};
         xmlMsg = "<![CDATA[" + ObjectSerializer.getInstance().serialize(obj) + "]]>";
         this.send(header,"asObjG",roomId,xmlMsg);
      }
      
      public function sendXtMessage(xtName:String, cmd:String, paramObj:*, type:String = "xml", roomId:int = -1) : void
      {
         var header:Object = null;
         var xtReq:Object = null;
         var xmlmsg:String = null;
         var hdr:String = null;
         var i:Number = NaN;
         var body:Object = null;
         var obj:Object = null;
         var msg:String = null;
         if(!this.checkRoomList())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         if(type == XTMSG_TYPE_XML)
         {
            header = {"t":"xt"};
            xtReq = {
               "name":xtName,
               "cmd":cmd,
               "param":paramObj
            };
            xmlmsg = "<![CDATA[" + ObjectSerializer.getInstance().serialize(xtReq) + "]]>";
            this.send(header,"xtReq",roomId,xmlmsg);
         }
         else if(type == XTMSG_TYPE_STR)
         {
            hdr = MSG_STR + "xt" + MSG_STR + xtName + MSG_STR + cmd + MSG_STR + roomId + MSG_STR;
            for(i = 0; i < paramObj.length; i++)
            {
               hdr += paramObj[i].toString() + MSG_STR;
            }
            this.sendString(hdr);
         }
         else if(type == XTMSG_TYPE_JSON)
         {
            body = {};
            body.x = xtName;
            body.c = cmd;
            body.r = roomId;
            body.p = paramObj;
            obj = {};
            obj.t = "xt";
            obj.b = body;
            msg = com.adobe.serialization.json.JSON.encode(obj);
            this.sendJson(msg);
         }
      }
      
      public function setBuddyBlockStatus(buddyName:String, status:Boolean) : void
      {
         var xmlMsg:String = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var b:Object = this.getBuddyByName(buddyName);
         if(b != null)
         {
            if(b.isBlocked != status)
            {
               b.isBlocked = status;
               xmlMsg = "<n x=\'" + (status ? "1" : "0") + "\'>" + buddyName + "</n>";
               this.send({"t":"sys"},"setB",-1,xmlMsg);
               params = {};
               params.buddy = b;
               evt = new SFSEvent(SFSEvent.onBuddyListUpdate,params);
               dispatchEvent(evt);
            }
         }
      }
      
      public function setBuddyVariables(varList:Array) : void
      {
         var vName:String = null;
         var vValue:String = null;
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<vars>";
         for(vName in varList)
         {
            vValue = varList[vName];
            if(this.myBuddyVars[vName] != vValue)
            {
               this.myBuddyVars[vName] = vValue;
               xmlMsg += "<var n=\'" + vName + "\'><![CDATA[" + vValue + "]]></var>";
            }
         }
         xmlMsg += "</vars>";
         this.send(header,"setBvars",-1,xmlMsg);
      }
      
      public function setRoomVariables(varList:Array, roomId:int = -1, setOwnership:Boolean = true) : void
      {
         var xmlMsg:String = null;
         var rv:Object = null;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var header:Object = {"t":"sys"};
         if(setOwnership)
         {
            xmlMsg = "<vars>";
         }
         else
         {
            xmlMsg = "<vars so=\'0\'>";
         }
         for each(rv in varList)
         {
            xmlMsg += this.getXmlRoomVariable(rv);
         }
         xmlMsg += "</vars>";
         this.send(header,"setRvars",roomId,xmlMsg);
      }
      
      public function setUserVariables(varObj:Object, roomId:int = -1) : void
      {
         var room:Room = null;
         var xmlMsg:String = null;
         var varOwner:User = null;
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         var header:Object = {"t":"sys"};
         var currRoom:Room = this.getActiveRoom();
         var user:User = currRoom.getUser(this.myUserId);
         user.setVariables(varObj);
         var userId:int = user.getId();
         for each(room in this.getAllRooms())
         {
            varOwner = room.getUser(userId);
            if(varOwner != null && varOwner != user)
            {
               varOwner.setVariables(varObj);
            }
         }
         xmlMsg = this.getXmlUserVariable(varObj);
         this.send(header,"setUvars",roomId,xmlMsg);
      }
      
      public function switchSpectator(roomId:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         this.send({"t":"sys"},"swSpec",roomId,"");
      }
      
      public function switchPlayer(roomId:int = -1) : void
      {
         if(!this.checkRoomList() || !this.checkJoin())
         {
            return;
         }
         if(roomId == -1)
         {
            roomId = this.activeRoomId;
         }
         this.send({"t":"sys"},"swPl",roomId,"");
      }
      
      public function uploadFile(fileRef:FileReference, id:int = -1, nick:String = "", port:int = -1) : void
      {
         if(id == -1)
         {
            id = this.myUserId;
         }
         if(nick == "")
         {
            nick = this.myUserName;
         }
         if(port == -1)
         {
            port = this.httpPort;
         }
         fileRef.upload(new URLRequest("http://" + this.ipAddress + ":" + port + "/default/Upload.py?id=" + id + "&nick=" + nick));
         this.debugMessage("[UPLOAD]: http://" + this.ipAddress + ":" + port + "/default/Upload.py?id=" + id + "&nick=" + nick);
      }
      
      public function __logout() : void
      {
         this.initialize(true);
      }
      
      public function sendString(strMessage:String) : void
      {
         this.debugMessage("[Sending - STR]: " + strMessage + "\n");
         if(this.isHttpMode)
         {
            this.httpConnection.send(strMessage);
         }
         else
         {
            this.writeToSocket(strMessage);
         }
      }
      
      public function sendJson(jsMessage:String) : void
      {
         this.debugMessage("[Sending - JSON]: " + jsMessage + "\n");
         if(this.isHttpMode)
         {
            this.httpConnection.send(jsMessage);
         }
         else
         {
            this.writeToSocket(jsMessage);
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
      
      private function initialize(isLogOut:Boolean = false) : void
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
         if(!isLogOut)
         {
            this.connected = false;
            this.isHttpMode = false;
         }
      }
      
      private function onConfigLoadSuccess(evt:Event) : void
      {
         var sfsEvt:SFSEvent = null;
         var loader:URLLoader = evt.target as URLLoader;
         var xmlDoc:XML = new XML(loader.data);
         this.ipAddress = this.blueBoxIpAddress = xmlDoc.ip;
         this.port = int(xmlDoc.port);
         this.defaultZone = xmlDoc.zone;
         if(xmlDoc.blueBoxIpAddress != undefined)
         {
            this.blueBoxIpAddress = xmlDoc.blueBoxIpAddress;
         }
         if(xmlDoc.blueBoxPort != undefined)
         {
            this.blueBoxPort = xmlDoc.blueBoxPort;
         }
         if(xmlDoc.debug != undefined)
         {
            this.debug = xmlDoc.debug.toLowerCase() == "true" ? true : false;
         }
         if(xmlDoc.smartConnect != undefined)
         {
            this.smartConnect = xmlDoc.smartConnect.toLowerCase() == "true" ? true : false;
         }
         if(xmlDoc.httpPort != undefined)
         {
            this.httpPort = int(xmlDoc.httpPort);
         }
         if(xmlDoc.httpPollSpeed != undefined)
         {
            this.httpPollSpeed = int(xmlDoc.httpPollSpeed);
         }
         if(xmlDoc.rawProtocolSeparator != undefined)
         {
            this.rawProtocolSeparator = xmlDoc.rawProtocolSeparator;
         }
         if(this.autoConnectOnConfigSuccess)
         {
            this.connect(this.ipAddress,this.port);
         }
         else
         {
            sfsEvt = new SFSEvent(SFSEvent.onConfigLoadSuccess,{});
            dispatchEvent(sfsEvt);
         }
      }
      
      private function onConfigLoadFailure(evt:IOErrorEvent) : void
      {
         var params:Object = {"message":evt.text};
         var sfsEvt:SFSEvent = new SFSEvent(SFSEvent.onConfigLoadFailure,params);
         dispatchEvent(sfsEvt);
      }
      
      private function setupMessageHandlers() : void
      {
         this.sysHandler = new SysHandler(this);
         this.extHandler = new ExtHandler(this);
         this.addMessageHandler("sys",this.sysHandler);
         this.addMessageHandler("xt",this.extHandler);
      }
      
      private function addMessageHandler(key:String, handler:IMessageHandler) : void
      {
         if(this.messageHandlers[key] == null)
         {
            this.messageHandlers[key] = handler;
         }
         else
         {
            this.debugMessage("Warning, message handler called: " + key + " already exist!");
         }
      }
      
      private function debugMessage(message:String) : void
      {
         var evt:SFSEvent = null;
         if(this.debug)
         {
            DebugUtility.debugTrace(message);
            evt = new SFSEvent(SFSEvent.onDebugMessage,{"message":message});
            dispatchEvent(evt);
         }
      }
      
      private function send(header:Object, action:String, fromRoom:Number, message:String) : void
      {
         var xmlMsg:String = this.makeXmlHeader(header);
         xmlMsg += "<body action=\'" + action + "\' r=\'" + fromRoom + "\'>" + message + "</body>" + this.closeHeader();
         this.debugMessage("[Sending]: " + xmlMsg + "\n");
         if(this.isHttpMode)
         {
            this.httpConnection.send(xmlMsg);
         }
         else
         {
            this.writeToSocket(xmlMsg);
         }
      }
      
      private function writeToSocket(msg:String) : void
      {
         var byteBuff:ByteArray = new ByteArray();
         byteBuff.writeUTFBytes(msg);
         byteBuff.writeByte(0);
         if(byteBuff.length > 4096)
         {
            throw new Error("Message will be ignored by server because it is > MaxMsgLen [4096] in config.xml: size=" + byteBuff.length + "\n\t" + msg);
         }
         this.socketConnection.writeBytes(byteBuff);
         this.socketConnection.flush();
      }
      
      private function makeXmlHeader(headerObj:Object) : String
      {
         var item:String = null;
         var xmlData:String = "<msg";
         for(item in headerObj)
         {
            xmlData += " " + item + "=\'" + headerObj[item] + "\'";
         }
         return xmlData + ">";
      }
      
      private function closeHeader() : String
      {
         return "</msg>";
      }
      
      private function checkBuddyDuplicates(buddyName:String) : Boolean
      {
         var buddy:Object = null;
         var res:Boolean = false;
         for each(buddy in this.buddyList)
         {
            if(buddy.name == buddyName)
            {
               res = true;
               break;
            }
         }
         return res;
      }
      
      private function xmlReceived(msg:String) : void
      {
         var xmlData:XML = new XML(msg);
         var handlerId:String = xmlData.@t;
         var action:String = xmlData.body.@action;
         var roomId:int = int(xmlData.body.@r);
         var handler:IMessageHandler = this.messageHandlers[handlerId];
         if(handler != null)
         {
            handler.handleMessage(xmlData,XTMSG_TYPE_XML);
         }
      }
      
      private function jsonReceived(msg:String) : void
      {
         var jso:Object = com.adobe.serialization.json.JSON.decode(msg);
         var handlerId:String = jso["t"];
         var handler:IMessageHandler = this.messageHandlers[handlerId];
         if(handler != null)
         {
            handler.handleMessage(jso["b"],XTMSG_TYPE_JSON);
         }
      }
      
      private function strReceived(msg:String) : void
      {
         var params:Array = msg.substr(1,msg.length - 2).split(MSG_STR);
         var handlerId:String = params[0];
         var handler:IMessageHandler = this.messageHandlers[handlerId];
         if(handler != null)
         {
            handler.handleMessage(params.splice(1,params.length - 1),XTMSG_TYPE_STR);
         }
      }
      
      private function getXmlRoomVariable(rVar:Object) : String
      {
         var vName:String = rVar.name.toString();
         var vValue:* = rVar.val;
         var vPrivate:String = Boolean(rVar.priv) ? "1" : "0";
         var vPersistent:String = Boolean(rVar.persistent) ? "1" : "0";
         var t:String = null;
         var type:String = typeof vValue;
         if(type == "boolean")
         {
            t = "b";
            vValue = Boolean(vValue) ? "1" : "0";
         }
         else if(type == "number")
         {
            t = "n";
         }
         else if(type == "string")
         {
            t = "s";
         }
         else if(vValue == null && type == "object" || type == "undefined")
         {
            t = "x";
            vValue = "";
         }
         if(t != null)
         {
            return "<var n=\'" + vName + "\' t=\'" + t + "\' pr=\'" + vPrivate + "\' pe=\'" + vPersistent + "\'><![CDATA[" + vValue + "]]></var>";
         }
         return "";
      }
      
      private function getXmlUserVariable(uVars:Object) : String
      {
         var val:* = undefined;
         var t:String = null;
         var type:String = null;
         var key:String = null;
         var xmlStr:String = "<vars>";
         for(key in uVars)
         {
            val = uVars[key];
            type = typeof val;
            t = null;
            if(type == "boolean")
            {
               t = "b";
               val = Boolean(val) ? "1" : "0";
            }
            else if(type == "number")
            {
               t = "n";
            }
            else if(type == "string")
            {
               t = "s";
            }
            else if(val == null && type == "object" || type == "undefined")
            {
               t = "x";
               val = "";
            }
            if(t != null)
            {
               xmlStr += "<var n=\'" + key + "\' t=\'" + t + "\'><![CDATA[" + val + "]]></var>";
            }
         }
         return xmlStr + "</vars>";
      }
      
      private function checkRoomList() : Boolean
      {
         var success:Boolean = true;
         if(this.roomList == null || this.roomList.length == 0)
         {
            success = false;
            this.errorTrace("The room list is empty!\nThe client API cannot function properly until the room list is populated.\nPlease consult the documentation for more infos.");
         }
         return success;
      }
      
      private function checkJoin() : Boolean
      {
         var success:Boolean = true;
         if(this.activeRoomId < 0)
         {
            success = false;
            this.errorTrace("You haven\'t joined any rooms!\nIn order to interact with the server you should join at least one room.\nPlease consult the documentation for more infos.");
         }
         return success;
      }
      
      private function errorTrace(msg:String) : void
      {
         trace("\n****************************************************************");
         trace("Warning:");
         trace(msg);
         trace("****************************************************************");
      }
      
      private function handleHttpConnect(evt:HttpEvent) : void
      {
         this.handleSocketConnection(null);
         this.connected = true;
         this.httpConnection.send(HTTP_POLL_REQUEST);
      }
      
      private function handleHttpClose(evt:HttpEvent) : void
      {
         this.initialize();
         var sfse:SFSEvent = new SFSEvent(SFSEvent.onConnectionLost,{});
         dispatchEvent(sfse);
         this._connectingToBluebox = false;
      }
      
      private function handleHttpData(evt:HttpEvent) : void
      {
         var message:String = null;
         var i:int = 0;
         var data:String = evt.params.data as String;
         var messages:Array = data.split("\n");
         if(messages[0] != "")
         {
            for(i = 0; i < messages.length - 1; i++)
            {
               message = messages[i];
               if(message.length > 0)
               {
                  this.handleMessage(message);
               }
            }
            if(this._httpPollSpeed > 0)
            {
               setTimeout(this.handleDelayedPoll,this._httpPollSpeed);
            }
            else
            {
               this.handleDelayedPoll();
            }
         }
      }
      
      private function handleDelayedPoll() : void
      {
         this.httpConnection.send(HTTP_POLL_REQUEST);
      }
      
      private function handleHttpError(evt:HttpEvent) : void
      {
         trace("HttpError");
         if(!this.connected)
         {
            this.dispatchConnectionError();
         }
         this._connectingToBluebox = false;
      }
      
      private function handleSocketConnection(e:Event) : void
      {
         var header:Object = {"t":"sys"};
         var xmlMsg:String = "<ver v=\'" + this.majVersion.toString() + this.minVersion.toString() + this.subVersion.toString() + "\' />";
         this.send(header,"verChk",0,xmlMsg);
      }
      
      private function handleSocketDisconnection(evt:Event) : void
      {
         this.initialize();
         var sfse:SFSEvent = new SFSEvent(SFSEvent.onConnectionLost,{});
         dispatchEvent(sfse);
      }
      
      private function handleIOError(evt:IOErrorEvent) : void
      {
         this.tryBlueBoxConnection(evt);
      }
      
      private function tryBlueBoxConnection(evt:ErrorEvent) : void
      {
         var __ip:String = null;
         var __port:int = 0;
         if(!this.connected)
         {
            if(!this._connectingToBluebox)
            {
               if(this.smartConnect)
               {
                  this.debugMessage("Socket connection failed. Trying BlueBox");
                  this.isHttpMode = true;
                  __ip = this.blueBoxIpAddress != null ? this.blueBoxIpAddress : this.ipAddress;
                  __port = this.blueBoxPort != 0 ? int(this.blueBoxPort) : this.httpPort;
                  this._connectingToBluebox = true;
                  this.httpConnection.connect(__ip,__port);
               }
               else
               {
                  this.dispatchConnectionError();
               }
            }
         }
         else
         {
            this.debugMessage("[WARN] Connection error: " + evt.text);
         }
      }
      
      private function handleSocketError(evt:SecurityErrorEvent) : void
      {
         this.debugMessage("Socket Error: " + evt.text);
      }
      
      private function handleSecurityError(evt:SecurityErrorEvent) : void
      {
         this.tryBlueBoxConnection(evt);
      }
      
      private function handleSocketData(evt:Event) : void
      {
         var b:int = 0;
         var bytes:int = int(this.socketConnection.bytesAvailable);
         while(--bytes >= 0)
         {
            b = this.socketConnection.readByte();
            if(b != 0)
            {
               this.byteBuffer.writeByte(b);
            }
            else
            {
               try
               {
                  this.handleMessage(this.byteBuffer.toString());
               }
               catch(err:Error)
               {
                  debugMessage("[WARN] Unexpected exception during handleMessage: " + err);
                  if(err.getStackTrace() != null)
                  {
                     debugMessage(err.getStackTrace());
                  }
               }
               this.byteBuffer = new ByteArray();
            }
         }
      }
      
      private function handleMessage(msg:String) : void
      {
         if(msg != "ok")
         {
            this.debugMessage("[ RECEIVED ]: " + msg + ", (len: " + msg.length + ")");
         }
         var type:String = msg.charAt(0);
         if(type == MSG_XML)
         {
            this.xmlReceived(msg);
         }
         else if(type == MSG_STR)
         {
            this.strReceived(msg);
         }
         else if(type == MSG_JSON)
         {
            this.jsonReceived(msg);
         }
      }
      
      private function dispatchConnectionError() : void
      {
         var params:Object = {};
         params.success = false;
         params.error = "I/O Error";
         var sfse:SFSEvent = new SFSEvent(SFSEvent.onConnection,params);
         dispatchEvent(sfse);
      }
   }
}

