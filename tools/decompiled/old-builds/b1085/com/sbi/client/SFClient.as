package com.sbi.client
{
   import com.sbi.debug.DebugUtility;
   import flash.events.EventDispatcher;
   import flash.external.ExternalInterface;
   import it.gotoandplay.smartfoxserver.SFSEvent;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   import it.gotoandplay.smartfoxserver.data.Room;
   import it.gotoandplay.smartfoxserver.data.User;
   
   public class SFClient extends EventDispatcher
   {
      
      public static const STATUS_ONLINE:int = 1;
      
      public static const STATUS_OFFLINE_ACTIVE:int = 0;
      
      public static const STATUS_OFFLINE_ARCHIVED:int = -1;
      
      public static const STATUS_OFFLINE_UNKNOWN:int = -2;
      
      public static const INIT_ROOM_ID:int = 1;
      
      protected var _sfs:SmartFoxClient;
      
      protected var _serverIps:Array;
      
      protected var _blueboxIps:Array;
      
      protected var _serverIp:String;
      
      protected var _serverPort:int;
      
      private var _isConnected:Boolean;
      
      private var _isLoggedIn:Boolean;
      
      private var _isWorldLoggedIn:Boolean;
      
      private var _currSubRoom:SFRoom;
      
      private var _currRoom:SFRoom;
      
      private var _currentPrimaryRoomId:int = -1;
      
      private var _currentSubRoomId:int = -1;
      
      private var _currentPrimaryRoomUsers:Object;
      
      private var _currentSubRoomUsers:Object;
      
      private var _triggerWhenWorldXtReadyCmd:String;
      
      private var _triggerWhenWorldXtReadyObj:Array;
      
      private var _roomIds:Array;
      
      private var _userName:String;
      
      private var _myUser:User;
      
      private var _gemCount:int;
      
      private var _password:String;
      
      private var _zone:String;
      
      private var _hashKey:String;
      
      private var _isWorldZone:Boolean;
      
      private var _pingTimeAvg:uint;
      
      private var _pingTimeTotal:uint;
      
      private var _pingTimeCount:uint;
      
      public function SFClient()
      {
         super();
         this._roomIds = new Array();
         this.setUpServer();
      }
      
      private function setUpServer() : void
      {
         this._isConnected = false;
         this._hashKey = null;
         this._isLoggedIn = false;
         this._isWorldLoggedIn = false;
         this._sfs = new SmartFoxClient(false);
         this._sfs.smartConnect = false;
         this._sfs.addEventListener(SFSEvent.onConnection,this.onConnection);
         this._sfs.addEventListener(SFSEvent.onConnectionLost,this.onConnectionLost);
         this._sfs.addEventListener(SFSEvent.onLogin,this.onLogin);
         this._sfs.addEventListener(SFSEvent.onExtensionResponse,this.onExtensionResponse);
         this._sfs.addEventListener(SFSEvent.onLogout,this.onLogout);
         this._sfs.addEventListener(SFSEvent.onRoomListUpdate,this.onRoomListUpdate);
         this._sfs.addEventListener(SFSEvent.onRoomAdded,this.onRoomAdded);
         this._sfs.addEventListener(SFSEvent.onCreateRoomError,this.onCreateRoomError);
         this._sfs.addEventListener(SFSEvent.onRoomDeleted,this.onRoomDeleted);
         this._sfs.addEventListener(SFSEvent.onUserEnterRoom,this.onUserEnterRoom);
         this._sfs.addEventListener(SFSEvent.onUserLeaveRoom,this.onUserLeaveRoom);
         this._sfs.addEventListener(SFSEvent.onRoomLeft,this.onRoomLeft);
         this._sfs.addEventListener(SFSEvent.onUserCountChange,this.onUserCountChange);
         this._sfs.addEventListener(SFSEvent.onBuddyList,this.onBuddyList);
         this._sfs.addEventListener(SFSEvent.onBuddyListError,this.onBuddyListError);
         this._sfs.addEventListener(SFSEvent.onBuddyListUpdate,this.onBuddyListUpdate);
         this._sfs.addEventListener(SFSEvent.onBuddyPermissionRequest,this.onBuddyPermissionRequest);
         this._sfs.addEventListener(SFSEvent.onBuddyRoom,this.onBuddyRoom);
         this._sfs.addEventListener(SFSEvent.onAdminMessage,this.onAdminMessage);
         this._sfs.addEventListener(SFSEvent.onModeratorMessage,this.onModeratorMessage);
         this._sfs.addEventListener(SFSEvent.onPrivateMessage,this.onPrivateMessage);
         this._sfs.addEventListener(SFSEvent.onPublicMessage,this.onPublicMessage);
         this._sfs.addEventListener(SFSEvent.onRandomKey,this.onRandomKey);
      }
      
      public function setServerConfig(param1:Array, param2:int, param3:Array, param4:int, param5:String) : void
      {
         this._serverIps = param1;
         this._serverIp = param1[0];
         this._serverPort = param2;
         this._blueboxIps = param3;
         this._sfs.blueBoxIpAddress = param3[0];
         this._sfs.blueBoxPort = param4;
         this._sfs.debug = param5 == "true";
      }
      
      public function setNewServer(param1:int) : void
      {
         if(!this.autoAttemptHttp)
         {
            this._serverIp = this._serverIps[param1];
         }
         else
         {
            this._sfs.blueBoxIpAddress = this._serverIp = this._blueboxIps[param1];
         }
      }
      
      public function switchServerNode(param1:String) : void
      {
         this._serverIp = param1;
         if(this.autoAttemptHttp)
         {
            this._sfs.blueBoxIpAddress = this._serverIp;
         }
      }
      
      public function isBlueboxMode() : Boolean
      {
         return this._sfs.getConnectionMode() == SmartFoxClient.CONNECTION_MODE_HTTP;
      }
      
      public function connect() : void
      {
         if(!this._isConnected)
         {
            this._sfs.connect(this._serverIp,this._serverPort);
         }
         else
         {
            this.getKey();
         }
      }
      
      public function logIn(param1:String, param2:String, param3:String) : void
      {
         if(this._hashKey == null)
         {
            return;
         }
         this._userName = param2;
         this._zone = param1;
         this._isWorldZone = this._zone == "sbiLogin";
         this._password = param3;
         this._sfs.login(this._zone,param2,param3);
      }
      
      public function logOut() : void
      {
         this._sfs.logout();
      }
      
      public function disconnect() : void
      {
         this._isLoggedIn = false;
         this._isWorldLoggedIn = false;
         this._isConnected = false;
         this._hashKey = null;
         this._sfs.disconnect();
      }
      
      public function get serverIps() : Array
      {
         return this._serverIps;
      }
      
      public function get serverIp() : String
      {
         return this._serverIp;
      }
      
      public function get serverPort() : int
      {
         return this._sfs.port;
      }
      
      public function get blueboxIps() : Array
      {
         return this._blueboxIps;
      }
      
      public function get blueboxServerIp() : String
      {
         return this._sfs.blueBoxIpAddress;
      }
      
      public function get blueboxServerPort() : int
      {
         return this._sfs.blueBoxPort;
      }
      
      public function get isWorldXtReady() : Boolean
      {
         return this._isWorldLoggedIn;
      }
      
      public function triggerCmdWhenWorldXtReady(param1:String, param2:Array) : void
      {
         this._triggerWhenWorldXtReadyCmd = param1;
         this._triggerWhenWorldXtReadyObj = param2;
      }
      
      public function triggerWorldXtReadyCmd() : void
      {
         if(this._triggerWhenWorldXtReadyCmd != null && this._triggerWhenWorldXtReadyObj != null)
         {
            this.setXtObject_Str(this._triggerWhenWorldXtReadyCmd,this._triggerWhenWorldXtReadyObj);
            this._triggerWhenWorldXtReadyCmd = null;
            this._triggerWhenWorldXtReadyObj = null;
         }
      }
      
      public function setXtObject_Str(param1:String, param2:Array, param3:Boolean = true, param4:Boolean = false, param5:Boolean = true) : void
      {
         if(param2 == null)
         {
            param2 = [];
         }
         var _loc6_:String = param3 ? "o" : "a";
         this._sfs.sendXtMessage(_loc6_,param1,param2,SmartFoxClient.XTMSG_TYPE_STR,this.getCurrentRoomId(param4));
         if(param5)
         {
            KeepAlive.restartTimeLeftTimer();
         }
      }
      
      public function setXtObject_XML(param1:String, param2:String, param3:Object, param4:Boolean = false) : void
      {
         if(param3 == null)
         {
            param3 = {};
         }
         this._sfs.sendXtMessage(param1,param2,param3,SmartFoxClient.XTMSG_TYPE_XML,this.getCurrentRoomId(param4));
      }
      
      public function setXtObject_JSON(param1:String, param2:Object, param3:Boolean = false) : void
      {
         if(param2 == null)
         {
            param2 = {};
         }
         this._sfs.sendXtMessage("a",param1,param2,SmartFoxClient.XTMSG_TYPE_JSON,this.getCurrentRoomId(param3));
      }
      
      public function getKey() : void
      {
         var _loc1_:SFEvent = null;
         if(this._hashKey == null)
         {
            this._sfs.getRandomKey();
         }
         else
         {
            _loc1_ = new SFEvent(SFEvent.ON_CONNECT);
            _loc1_.status = true;
            dispatchEvent(_loc1_);
         }
      }
      
      public function createRoom(param1:String, param2:uint, param3:uint, param4:Boolean, param5:Boolean, param6:String, param7:String) : void
      {
         throw new Error("createRoom on client should not be used if at all possible!");
      }
      
      public function setToJoinIRG(param1:Boolean) : void
      {
         this._currentSubRoomId = param1 ? 0 : -1;
      }
      
      public function leaveRoom(param1:int) : void
      {
         this._sfs.leaveRoom(param1);
      }
      
      public function leaveCurrentRoom(param1:Boolean = false) : void
      {
         this._sfs.leaveRoom(param1 ? this._currentSubRoomId : this._currentPrimaryRoomId);
         this._currentSubRoomId = -1;
      }
      
      public function sendMessage(param1:String, param2:int = -2, param3:int = -1) : void
      {
         if(param3 >= 0)
         {
            this._sfs.sendPrivateMessage(param1,param3,param2);
         }
         else
         {
            if(param2 == -2)
            {
               param2 = this._currentPrimaryRoomId;
            }
            this._sfs.sendPublicMessage(param1,param2);
            KeepAlive.restartTimeLeftTimer();
         }
      }
      
      public function isInMyRoom(param1:int, param2:Boolean) : Boolean
      {
         if(!param2 && this._currentPrimaryRoomUsers == null)
         {
            return false;
         }
         if(param2 && this._currentSubRoomUsers == null)
         {
            return false;
         }
         return Boolean(param2 ? this._currentSubRoomUsers[param1] != undefined : this._currentPrimaryRoomUsers[param1] != undefined);
      }
      
      public function loadBuddyList() : void
      {
         this._sfs.loadBuddyList();
      }
      
      public function getBuddyById(param1:int) : Object
      {
         return this._sfs.getBuddyById(param1);
      }
      
      public function getBuddyByName(param1:String) : Object
      {
         return this._sfs.getBuddyByName(param1);
      }
      
      public function sendBuddyPermissionResponse(param1:Boolean, param2:String) : void
      {
         this._sfs.sendBuddyPermissionResponse(param1,param2);
      }
      
      public function setBuddyBlockStatus(param1:String, param2:Boolean) : void
      {
         this._sfs.setBuddyBlockStatus(param1,param2);
      }
      
      public function getBuddyRoomByName(param1:String) : void
      {
         var _loc2_:Object = this._sfs.getBuddyByName(param1);
         this._sfs.getBuddyRoom(_loc2_);
      }
      
      public function getBuddyRoomById(param1:int) : void
      {
         var _loc2_:Object = this._sfs.getBuddyById(param1);
         this._sfs.getBuddyRoom(_loc2_);
      }
      
      public function getBuddyRoom(param1:Object) : void
      {
         var _loc3_:Object = null;
         if(!param1)
         {
            throw new Error("Invalid buddy obj used to request buddy room! userobj:" + param1);
         }
         if(!param1.hasOwnProperty("id"))
         {
            throw new Error("Invalid buddy obj used to request buddy room! userobj.hasOwnProperty(\"id\"):" + param1.hasOwnProperty("id"));
         }
         var _loc2_:Boolean = false;
         for each(_loc3_ in this._sfs.buddyList)
         {
            if(_loc3_.id == param1.id)
            {
               _loc2_ = true;
               break;
            }
         }
         if(_loc2_)
         {
            this._sfs.getBuddyRoom(_loc3_);
            return;
         }
         throw new Error("Invalid buddy obj used to request buddy room! Could not find match in client buddy list. userobj.id:" + param1.id);
      }
      
      public function removeBuddy(param1:String) : void
      {
         this._sfs.removeBuddy(param1);
      }
      
      public function getCurrentRoom(param1:Boolean = false) : SFRoom
      {
         return param1 ? this._currSubRoom : this._currRoom;
      }
      
      public function getCurrentRoomId(param1:Boolean = false) : int
      {
         if(!param1)
         {
            return this._currentPrimaryRoomId;
         }
         if(this._currentSubRoomId <= 0)
         {
            throw new Error("Attempt to send message to sub room without valid subRoomId! (no in-room game room currently joined?)");
         }
         return this._currentSubRoomId;
      }
      
      public function getPvpSubRoomId() : int
      {
         return this._currentSubRoomId;
      }
      
      public function setCurrSubRoomId(param1:int) : void
      {
         if(this._currentSubRoomId != -1)
         {
            DebugUtility.debugTrace("WARNING: setting currSubRoomId to " + param1 + " but _currSubRoomId was not -1. It was " + this._currentSubRoomId);
         }
         this._currentSubRoomId = param1;
      }
      
      public function getCurrentRoomName(param1:Boolean = false) : String
      {
         var _loc2_:SFRoom = this.getCurrentRoom(param1);
         if(!_loc2_)
         {
            return null;
         }
         return _loc2_.name;
      }
      
      public function setInitRoom() : void
      {
         var _loc1_:Array = this._sfs.getAllRooms();
         if(_loc1_.length > 0)
         {
            return;
         }
         _loc1_[INIT_ROOM_ID] = new Room(INIT_ROOM_ID,"_init",10000,0,false,false,false,true);
      }
      
      public function joinDefaultRoom() : void
      {
         var _loc1_:Array = this._sfs.getAllRooms();
         var _loc2_:Room = _loc1_[INIT_ROOM_ID];
         _loc2_.addUser(this._myUser,this._myUser.getId());
         this._sfs.activeRoomId = INIT_ROOM_ID;
         this._currRoom = new SFRoom();
         this._currRoom.name = "_init";
         this._currRoom.id = INIT_ROOM_ID;
         this._currRoom.users = 1;
         this._currRoom.maxUsers = 10000;
         this._currRoom.spectators = 0;
         this._currRoom.maxSpectators = 0;
         this._currRoom.isPrivate = false;
         this._currRoom.isGame = false;
         this._currRoom.isLimbo = true;
         this._currRoom.isTemp = true;
      }
      
      public function setRoomList(param1:Object) : void
      {
         var _loc6_:Room = null;
         var _loc8_:int = 0;
         var _loc2_:Array = this._sfs.getAllRooms();
         _loc2_.splice(0,_loc2_.length);
         var _loc3_:* = 2;
         var _loc4_:int = int(param1[_loc3_++]);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            _loc8_ = int(param1[_loc3_++]);
            _loc2_[_loc8_] = new Room(_loc8_,param1[_loc3_++],int(param1[_loc3_++]),0,param1[_loc3_++] == "1",param1[_loc3_++] == "1",false,_loc5_ < 1,int(param1[_loc3_++]));
            _loc5_++;
         }
         this._roomIds.splice(0,this._roomIds.length);
         for each(_loc6_ in _loc2_)
         {
            this._roomIds.push(_loc6_.getId());
         }
         if(this._currentPrimaryRoomId != -1)
         {
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         else if(this._roomIds.length == 1)
         {
            this._currentPrimaryRoomId = this.roomIds[0];
         }
         if(this._currentSubRoomId > 0)
         {
            this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         }
         var _loc7_:SFEvent = new SFEvent(SFEvent.ON_ROOM_LIST);
         _loc7_.status = true;
         dispatchEvent(_loc7_);
      }
      
      public function setAPIUserList(param1:int, param2:Object) : void
      {
         var _loc5_:String = null;
         var _loc3_:Room = this._sfs.getRoom(param1);
         if(!_loc3_)
         {
            return;
         }
         var _loc4_:Array = _loc3_.getUserList();
         if(!_loc4_)
         {
            return;
         }
         _loc4_.splice(0,_loc4_.length);
         if(!param2)
         {
            return;
         }
         for(_loc5_ in param2)
         {
            _loc4_[_loc5_] = param2[_loc5_];
         }
      }
      
      private function onConnection(param1:SFSEvent) : void
      {
         var _loc3_:SFEvent = null;
         this._currentPrimaryRoomId = -1;
         this._currentSubRoomId = -1;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("mrc",["dm","SFClient onConnection"]);
         }
         var _loc2_:Boolean = Boolean(param1.params.success);
         if(_loc2_)
         {
            this._isConnected = true;
            this.getKey();
         }
         else
         {
            _loc3_ = new SFEvent(SFEvent.ON_CONNECT);
            _loc3_.status = false;
            dispatchEvent(_loc3_);
         }
      }
      
      private function onConnectionLost(param1:SFSEvent) : void
      {
         this._isConnected = false;
         this._hashKey = null;
         this._isLoggedIn = false;
         this._isWorldLoggedIn = false;
         this._currentPrimaryRoomId = -1;
         this._currentSubRoomId = -1;
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_CONNECTION_LOST);
         _loc2_.status = true;
         dispatchEvent(_loc2_);
      }
      
      private function onLogin(param1:SFSEvent) : void
      {
         var _loc2_:Boolean = Boolean(param1.params.success);
         if(_loc2_)
         {
            this._isLoggedIn = true;
         }
         this._currentPrimaryRoomId = -1;
         this._currentSubRoomId = -1;
         var _loc3_:SFEvent = new SFEvent(SFEvent.ON_LOGIN);
         _loc3_.status = _loc2_;
         _loc3_.userName = param1.params.name;
         dispatchEvent(_loc3_);
      }
      
      private function onExtensionResponse(param1:SFSEvent) : void
      {
         var _loc2_:Object = param1.params.dataObj;
         var _loc3_:SFEvent = null;
         if(_loc2_._cmd == "login")
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","SFClient xtResponse - ON_LOGIN"]);
            }
            _loc3_ = new SFEvent(SFEvent.ON_LOGIN);
            _loc3_.status = true;
            _loc3_.obj = _loc2_.params;
            this._currentPrimaryRoomId = -1;
            this._currentSubRoomId = -1;
            if(_loc2_.status == "1")
            {
               this._myUser = new User(this._sfs.myUserId = _loc2_.params.userId,this._sfs.myUserName = _loc2_.params.userName);
               _loc3_.userName = _loc2_.params.userName;
               this._isLoggedIn = true;
               this._isWorldLoggedIn = true;
            }
            else
            {
               _loc3_.status = false;
               _loc3_.message = _loc2_.message;
               _loc3_.statusId = _loc2_.statusId;
            }
            dispatchEvent(_loc3_);
         }
         else
         {
            _loc3_ = new SFEvent(SFEvent.ON_XT_REPLY);
            _loc3_.status = true;
            _loc3_.obj = param1.params.dataObj;
            dispatchEvent(_loc3_);
         }
      }
      
      private function onLogout(param1:SFSEvent) : void
      {
         this._isLoggedIn = false;
         this._isWorldLoggedIn = false;
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_LOGOUT);
         _loc2_.status = true;
         dispatchEvent(_loc2_);
      }
      
      private function onRoomListUpdate(param1:SFSEvent) : void
      {
         var _loc2_:Room = null;
         this._roomIds.splice(0,this._roomIds.length);
         for each(_loc2_ in param1.params.roomList)
         {
            this._roomIds.push(_loc2_.getId());
         }
         if(this._currentPrimaryRoomId != -1)
         {
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         else if(this._roomIds.length == 1)
         {
            this._currentPrimaryRoomId = this.roomIds[0];
         }
         if(this._currentSubRoomId > 0)
         {
            this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         }
         var _loc3_:SFEvent = new SFEvent(SFEvent.ON_ROOM_LIST);
         _loc3_.status = true;
         dispatchEvent(_loc3_);
      }
      
      private function onRoomAdded(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_ROOM_CREATED);
         _loc2_.status = true;
         _loc2_.roomId = param1.params.room.getId();
         dispatchEvent(_loc2_);
      }
      
      private function onRoomDeleted(param1:SFSEvent) : void
      {
         this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_ROOM_DELETED);
         _loc2_.status = true;
         if(Boolean(param1) && Boolean(param1.params) && Boolean(param1.params.room))
         {
            _loc2_.roomId = param1.params.room.getId();
         }
         dispatchEvent(_loc2_);
      }
      
      private function onCreateRoomError(param1:SFSEvent) : void
      {
         this._currentSubRoomUsers = null;
         this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         this._currentSubRoomId = -1;
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_ROOM_CREATED);
         _loc2_.status = false;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      public function handleRoomJoin(param1:SFRoom) : void
      {
         var _loc4_:Room = null;
         var _loc2_:int = param1.id;
         if(this._currentSubRoomId == 0)
         {
            this._currSubRoom = param1;
            this._currentSubRoomId = _loc2_;
         }
         else
         {
            this._currRoom = param1;
            this._currentPrimaryRoomId = _loc2_;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("mrc",["dm","handleRoomJoin called"]);
         }
         var _loc3_:Array = this._sfs.getAllRooms();
         (_loc3_[_loc2_] = new Room(_loc2_,param1.name,param1.maxUsers,param1.maxSpectators,param1.isTemp,param1.isGame,param1.isPrivate,param1.isLimbo,param1.users,param1.spectators)).addUser(this._myUser,this._myUser.getId());
         this._sfs.activeRoomId = _loc2_;
         var _loc5_:SFEvent = new SFEvent(SFEvent.ON_JOIN_ROOM);
         _loc5_.status = true;
         _loc5_.roomId = _loc2_;
         _loc5_.obj = {};
         _loc5_.obj.room = param1;
         _loc5_.obj.subRoom = this._currSubRoom;
         dispatchEvent(_loc5_);
      }
      
      public function handleRoomJoinError(param1:String, param2:String = "") : void
      {
         var _loc3_:SFEvent = new SFEvent(SFEvent.ON_JOIN_ROOM);
         _loc3_.status = false;
         _loc3_.message = param1;
         _loc3_.obj = {};
         _loc3_.obj.roomFull = param1 == "This room is currently full";
         _loc3_.obj.denOwner = param2;
         dispatchEvent(_loc3_);
      }
      
      public function handleSubRoomExit() : void
      {
         if(this._currentSubRoomId <= 0)
         {
            throw new Error("Trying to leave a sub room when not in one?");
         }
         this._currentSubRoomId = -1;
         this._currSubRoom = null;
      }
      
      private function onRoomLeft(param1:SFSEvent) : void
      {
         if(this._currentSubRoomId == 0)
         {
            throw new Error("Left a room while in the middle of making a sub room?!");
         }
         if(param1.params.roomId == this._currentSubRoomId)
         {
            this._currentSubRoomUsers = null;
            this._currentSubRoomId = -1;
         }
         else
         {
            this._currentPrimaryRoomUsers = null;
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_LEFT_ROOM);
         _loc2_.status = true;
         _loc2_.roomId = param1.params.roomId;
         dispatchEvent(_loc2_);
      }
      
      private function onUserEnterRoom(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_USER_ENTERED_ROOM);
         _loc2_.status = true;
         _loc2_.userId = param1.params.user.getId();
         _loc2_.userName = param1.params.user.getName();
         _loc2_.roomId = param1.params.roomId;
         if(_loc2_.roomId == this._currentPrimaryRoomId)
         {
            this._currentPrimaryRoomUsers[_loc2_.userId] = param1.params.user;
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         else if(_loc2_.roomId == this._currentSubRoomId)
         {
            this._currentSubRoomUsers[_loc2_.userId] = param1.params.user;
            this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         }
         dispatchEvent(_loc2_);
      }
      
      private function onUserLeaveRoom(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_USER_LEFT_ROOM);
         _loc2_.status = true;
         _loc2_.userId = param1.params.userId;
         _loc2_.roomId = param1.params.roomId;
         if(_loc2_.roomId == this._currentPrimaryRoomId)
         {
            delete this._currentPrimaryRoomUsers[_loc2_.userId];
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         else if(_loc2_.roomId == this._currentSubRoomId)
         {
            delete this._currentSubRoomUsers[_loc2_.userId];
            this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         }
         dispatchEvent(_loc2_);
      }
      
      private function onUserCountChange(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_ROOM_POPULATION_CHANGE);
         _loc2_.status = true;
         _loc2_.roomId = param1.params.room.getId();
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyList(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_BUDDY_LIST);
         _loc2_.status = true;
         _loc2_.obj = param1.params.list;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyListError(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_BUDDY_LIST);
         _loc2_.status = false;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyListUpdate(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_BUDDY_LIST_UPDATE);
         _loc2_.status = true;
         _loc2_.userName = param1.params.buddy.name;
         _loc2_.obj = param1.params.buddy;
         _loc2_.message = param1.params.error;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyPermissionRequest(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_BUDDY_REQUEST);
         _loc2_.status = true;
         _loc2_.userName = param1.params.sender;
         dispatchEvent(_loc2_);
      }
      
      private function onBuddyRoom(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_BUDDY_ROOM);
         _loc2_.status = true;
         _loc2_.roomId = param1.params.idList[0];
         dispatchEvent(_loc2_);
      }
      
      private function onAdminMessage(param1:SFSEvent) : void
      {
         DebugUtility.debugTrace("onAdminMessage:" + param1.params.message);
      }
      
      private function onModeratorMessage(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_CHAT_MESSAGE);
         _loc2_.status = true;
         _loc2_.message = param1.params.message;
         dispatchEvent(_loc2_);
      }
      
      private function onPrivateMessage(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_CHAT_MESSAGE);
         _loc2_.status = true;
         _loc2_.message = param1.params.message;
         dispatchEvent(_loc2_);
      }
      
      private function onPublicMessage(param1:SFSEvent) : void
      {
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_CHAT_MESSAGE);
         _loc2_.status = true;
         _loc2_.message = param1.params.message;
         dispatchEvent(_loc2_);
      }
      
      private function onRandomKey(param1:SFSEvent) : void
      {
         this._hashKey = param1.params.key;
         var _loc2_:SFEvent = new SFEvent(SFEvent.ON_CONNECT);
         _loc2_.status = true;
         dispatchEvent(_loc2_);
      }
      
      public function get autoAttemptHttp() : Boolean
      {
         return this._sfs.smartConnect;
      }
      
      public function set autoAttemptHttp(param1:Boolean) : void
      {
         this._sfs.smartConnect = param1;
      }
      
      public function get isWorldZone() : Boolean
      {
         return this._isWorldZone;
      }
      
      public function get userId() : int
      {
         return this._sfs.myUserId;
      }
      
      public function get userName() : String
      {
         return this._sfs.myUserName;
      }
      
      public function get gemCount() : int
      {
         return this._gemCount;
      }
      
      public function set gemCount(param1:int) : void
      {
         this._gemCount = param1;
      }
      
      public function get signInUserName() : String
      {
         return this._userName;
      }
      
      public function get password() : String
      {
         return this._password;
      }
      
      public function get roomIds() : Array
      {
         return this._roomIds;
      }
      
      public function get buddyList() : Array
      {
         return this._sfs.buddyList;
      }
      
      public function get rawProtocolSeparator() : String
      {
         return this._sfs.rawProtocolSeparator;
      }
      
      public function get isLoggedIn() : Boolean
      {
         return this._isLoggedIn;
      }
      
      public function get isConnected() : Boolean
      {
         return this._isConnected;
      }
      
      public function getIsConnected() : Boolean
      {
         return this._isConnected;
      }
      
      public function get hashKey() : String
      {
         return this._hashKey;
      }
   }
}

