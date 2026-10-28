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
      
      public function setServerConfig(setSfsIps:Array, setSfsPort:int, setBlueboxIps:Array, setBlueboxPort:int, clientDebug:String) : void
      {
         this._serverIps = setSfsIps;
         var initialJoinIndex:int = Math.floor(Math.random() * this._serverIps.length);
         this._serverIp = setSfsIps[initialJoinIndex];
         this._serverPort = setSfsPort;
         this._blueboxIps = setBlueboxIps;
         var initialBlueBoxJoinIndex:int = Math.floor(Math.random() * this._blueboxIps.length);
         this._sfs.blueBoxIpAddress = setBlueboxIps[initialBlueBoxJoinIndex];
         this._sfs.blueBoxPort = setBlueboxPort;
         this._sfs.debug = clientDebug == "true";
      }
      
      public function setNewServer(setServerIdx:int) : void
      {
         if(!this.autoAttemptHttp)
         {
            this._serverIp = this._serverIps[setServerIdx];
         }
         else
         {
            this._sfs.blueBoxIpAddress = this._serverIp = this._blueboxIps[setServerIdx];
         }
      }
      
      public function switchServerNode(setSfsIp:String) : void
      {
         this._serverIp = setSfsIp;
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
      
      public function logIn(zone:String, userName:String, pass:String) : void
      {
         if(this._hashKey == null)
         {
            trace("***ERROR ERROR ERROR - attempted to login without a valid encryption key!***");
            return;
         }
         this._userName = userName;
         this._zone = zone;
         this._isWorldZone = this._zone == "sbiLogin";
         this._password = pass;
         this._sfs.login(this._zone,userName,pass);
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
      
      public function triggerCmdWhenWorldXtReady(cmd:String, obj:Array) : void
      {
         this._triggerWhenWorldXtReadyCmd = cmd;
         this._triggerWhenWorldXtReadyObj = obj;
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
      
      public function setXtObject_Str(cmd:String, obj:Array, isWorld:Boolean = true, useSubRoom:Boolean = false, restartKeepAlive:Boolean = true) : void
      {
         var extStr:String = null;
         if(this._sfs.isConnected)
         {
            if(obj == null)
            {
               obj = [];
            }
            extStr = isWorld ? "o" : "a";
            this._sfs.sendXtMessage(extStr,cmd,obj,SmartFoxClient.XTMSG_TYPE_STR,this.getCurrentRoomId(useSubRoom));
            if(restartKeepAlive)
            {
               KeepAlive.restartTimeLeftTimer();
            }
         }
      }
      
      public function setXtObject_XML(extName:String, cmd:String, obj:Object, useSubRoom:Boolean = false) : void
      {
         if(this._sfs.isConnected)
         {
            if(obj == null)
            {
               obj = {};
            }
            this._sfs.sendXtMessage(extName,cmd,obj,SmartFoxClient.XTMSG_TYPE_XML,this.getCurrentRoomId(useSubRoom));
         }
      }
      
      public function setXtObject_JSON(cmd:String, obj:Object, useSubRoom:Boolean = false) : void
      {
         if(this._sfs.isConnected)
         {
            if(obj == null)
            {
               obj = {};
            }
            this._sfs.sendXtMessage("a",cmd,obj,SmartFoxClient.XTMSG_TYPE_JSON,this.getCurrentRoomId(useSubRoom));
         }
      }
      
      public function getKey() : void
      {
         var newEvt:SFEvent = null;
         if(this._hashKey == null)
         {
            this._sfs.getRandomKey();
         }
         else
         {
            newEvt = new SFEvent(SFEvent.ON_CONNECT);
            newEvt.status = true;
            dispatchEvent(newEvt);
         }
      }
      
      public function createRoom(rmName:String, maxUsersInRoom:uint, maxSpectatorsInRoom:uint, isGameRoom:Boolean, exitOldRoom:Boolean, extName:String, extClassName:String) : void
      {
         throw new Error("createRoom on client should not be used if at all possible!");
      }
      
      public function setToJoinIRG(joiningIRG:Boolean) : void
      {
         this._currentSubRoomId = joiningIRG ? 0 : -1;
      }
      
      public function leaveRoom(roomId:int) : void
      {
         this._sfs.leaveRoom(roomId);
      }
      
      public function leaveCurrentRoom(useSubRoom:Boolean = false) : void
      {
         this._sfs.leaveRoom(useSubRoom ? this._currentSubRoomId : this._currentPrimaryRoomId);
         this._currentSubRoomId = -1;
      }
      
      public function sendMessage(message:String, roomId:int = -2, toUserId:int = -1) : void
      {
         if(this._sfs.isConnected)
         {
            if(toUserId >= 0)
            {
               this._sfs.sendPrivateMessage(message,toUserId,roomId);
            }
            else
            {
               if(roomId == -2)
               {
                  roomId = this._currentPrimaryRoomId;
               }
               this._sfs.sendPublicMessage(message,roomId);
               KeepAlive.restartTimeLeftTimer();
            }
         }
      }
      
      public function isInMyRoom(findUserId:int, useSubRoom:Boolean) : Boolean
      {
         if(!useSubRoom && this._currentPrimaryRoomUsers == null)
         {
            return false;
         }
         if(useSubRoom && this._currentSubRoomUsers == null)
         {
            return false;
         }
         return Boolean(useSubRoom ? this._currentSubRoomUsers[findUserId] != undefined : this._currentPrimaryRoomUsers[findUserId] != undefined);
      }
      
      public function loadBuddyList() : void
      {
         this._sfs.loadBuddyList();
      }
      
      public function getBuddyById(userId:int) : Object
      {
         return this._sfs.getBuddyById(userId);
      }
      
      public function getBuddyByName(userName:String) : Object
      {
         return this._sfs.getBuddyByName(userName);
      }
      
      public function sendBuddyPermissionResponse(confirm:Boolean, username:String) : void
      {
         this._sfs.sendBuddyPermissionResponse(confirm,username);
      }
      
      public function setBuddyBlockStatus(userName:String, blocked:Boolean) : void
      {
         this._sfs.setBuddyBlockStatus(userName,blocked);
      }
      
      public function getBuddyRoomByName(username:String) : void
      {
         var buddy:Object = this._sfs.getBuddyByName(username);
         this._sfs.getBuddyRoom(buddy);
      }
      
      public function getBuddyRoomById(userid:int) : void
      {
         var buddy:Object = this._sfs.getBuddyById(userid);
         this._sfs.getBuddyRoom(buddy);
      }
      
      public function getBuddyRoom(userobj:Object) : void
      {
         var buddy:Object = null;
         if(!userobj)
         {
            throw new Error("Invalid buddy obj used to request buddy room! userobj:" + userobj);
         }
         if(!userobj.hasOwnProperty("id"))
         {
            throw new Error("Invalid buddy obj used to request buddy room! userobj.hasOwnProperty(\"id\"):" + userobj.hasOwnProperty("id"));
         }
         var validBuddy:Boolean = false;
         for each(buddy in this._sfs.buddyList)
         {
            if(buddy.id == userobj.id)
            {
               validBuddy = true;
               break;
            }
         }
         if(validBuddy)
         {
            this._sfs.getBuddyRoom(buddy);
            return;
         }
         throw new Error("Invalid buddy obj used to request buddy room! Could not find match in client buddy list. userobj.id:" + userobj.id);
      }
      
      public function removeBuddy(userName:String) : void
      {
         this._sfs.removeBuddy(userName);
      }
      
      public function getCurrentRoom(useSubRoom:Boolean = false) : SFRoom
      {
         return useSubRoom ? this._currSubRoom : this._currRoom;
      }
      
      public function getCurrentRoomId(useSubRoom:Boolean = false) : int
      {
         if(!useSubRoom)
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
      
      public function setCurrSubRoomId(subRoomId:int) : void
      {
         if(this._currentSubRoomId != -1)
         {
            DebugUtility.debugTrace("WARNING: setting currSubRoomId to " + subRoomId + " but _currSubRoomId was not -1. It was " + this._currentSubRoomId);
         }
         this._currentSubRoomId = subRoomId;
      }
      
      public function getCurrentRoomName(useSubRoom:Boolean = false) : String
      {
         var r:SFRoom = this.getCurrentRoom(useSubRoom);
         if(!r)
         {
            trace("WARNING: null room object! trying to get room name before joining any rooms? useSubRoom:" + useSubRoom);
            return null;
         }
         return r.name;
      }
      
      public function setInitRoom() : void
      {
         var roomList:Array = this._sfs.getAllRooms();
         if(roomList.length > 0)
         {
            return;
         }
         roomList[INIT_ROOM_ID] = new Room(INIT_ROOM_ID,"_init",10000,0,false,false,false,true);
      }
      
      public function joinDefaultRoom() : void
      {
         var roomList:Array = this._sfs.getAllRooms();
         var jr:Room = roomList[INIT_ROOM_ID];
         jr.addUser(this._myUser,this._myUser.getId());
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
      
      public function setRoomList(data:Object) : void
      {
         var r:Room = null;
         var roomId:int = 0;
         var roomList:Array = this._sfs.getAllRooms();
         roomList.splice(0,roomList.length);
         var j:int = 2;
         var numRooms:int = int(data[j++]);
         for(var i:int = 0; i < numRooms; i++)
         {
            roomId = int(data[j++]);
            roomList[roomId] = new Room(roomId,data[j++],int(data[j++]),0,data[j++] == "1",data[j++] == "1",false,i < 1,int(data[j++]));
         }
         this._roomIds.splice(0,this._roomIds.length);
         for each(r in roomList)
         {
            this._roomIds.push(r.getId());
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
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_ROOM_LIST);
         newEvt.status = true;
         dispatchEvent(newEvt);
      }
      
      public function setAPIUserList(roomId:int, currUsers:Object) : void
      {
         var k:String = null;
         var r:Room = this._sfs.getRoom(roomId);
         if(!r)
         {
            trace("ERROR: setAPIUserList called with invalid roomId:" + roomId);
            return;
         }
         var ulfix:Array = r.getUserList();
         if(!ulfix)
         {
            trace("ERROR: setAPIUserList got a null userlist from the room?!");
            return;
         }
         ulfix.splice(0,ulfix.length);
         if(!currUsers)
         {
            trace("ERROR: setAPIUserList called with invalid currUsers:" + currUsers);
            return;
         }
         for(k in currUsers)
         {
            ulfix[k] = currUsers[k];
         }
      }
      
      private function onConnection(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = null;
         this._currentPrimaryRoomId = -1;
         this._currentSubRoomId = -1;
         if(ExternalInterface.available)
         {
            ExternalInterface.call("mrc",["dm","SFClient onConnection"]);
         }
         var ok:Boolean = Boolean(evt.params.success);
         if(ok)
         {
            this._isConnected = true;
            trace("Connected.");
            this.getKey();
         }
         else
         {
            trace("Failed to connect to :" + this._serverIp);
            newEvt = new SFEvent(SFEvent.ON_CONNECT);
            newEvt.status = false;
            dispatchEvent(newEvt);
         }
      }
      
      private function onConnectionLost(evt:SFSEvent) : void
      {
         trace("Connection Lost");
         this._isConnected = false;
         this._hashKey = null;
         this._isLoggedIn = false;
         this._isWorldLoggedIn = false;
         this._currentPrimaryRoomId = -1;
         this._currentSubRoomId = -1;
         this._currRoom = null;
         this._currSubRoom = null;
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_CONNECTION_LOST);
         newEvt.status = true;
         dispatchEvent(newEvt);
      }
      
      private function onLogin(evt:SFSEvent) : void
      {
         var ok:Boolean = Boolean(evt.params.success);
         if(!ok)
         {
            trace("Error: " + evt.params.error);
         }
         else
         {
            this._isLoggedIn = true;
            trace("Logged in!");
         }
         this._currentPrimaryRoomId = -1;
         this._currentSubRoomId = -1;
         this._currRoom = null;
         this._currSubRoom = null;
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_LOGIN);
         newEvt.status = ok;
         newEvt.userName = evt.params.name;
         dispatchEvent(newEvt);
      }
      
      private function onExtensionResponse(evt:SFSEvent) : void
      {
         var data:Object = evt.params.dataObj;
         var newEvt:SFEvent = null;
         if(data._cmd == "login")
         {
            if(ExternalInterface.available)
            {
               ExternalInterface.call("mrc",["dm","SFClient xtResponse - ON_LOGIN"]);
            }
            newEvt = new SFEvent(SFEvent.ON_LOGIN);
            newEvt.status = true;
            newEvt.obj = data.params;
            this._currentPrimaryRoomId = -1;
            this._currentSubRoomId = -1;
            this._currRoom = null;
            this._currSubRoom = null;
            if(data.status == "1")
            {
               this._myUser = new User(this._sfs.myUserId = data.params.userId,this._sfs.myUserName = data.params.userName);
               newEvt.userName = data.params.userName;
               this._isLoggedIn = true;
               this._isWorldLoggedIn = true;
            }
            else
            {
               newEvt.status = false;
               newEvt.message = data.message;
               newEvt.statusId = data.statusId;
            }
            dispatchEvent(newEvt);
         }
         else
         {
            newEvt = new SFEvent(SFEvent.ON_XT_REPLY);
            newEvt.status = true;
            newEvt.obj = evt.params.dataObj;
            dispatchEvent(newEvt);
         }
      }
      
      private function onLogout(evt:SFSEvent) : void
      {
         this._isLoggedIn = false;
         this._isWorldLoggedIn = false;
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_LOGOUT);
         newEvt.status = true;
         dispatchEvent(newEvt);
      }
      
      private function onRoomListUpdate(evt:SFSEvent) : void
      {
         var r:Room = null;
         trace("Updated Room List");
         this._roomIds.splice(0,this._roomIds.length);
         for each(r in evt.params.roomList)
         {
            this._roomIds.push(r.getId());
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
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_ROOM_LIST);
         newEvt.status = true;
         dispatchEvent(newEvt);
      }
      
      private function onRoomAdded(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_ROOM_CREATED);
         newEvt.status = true;
         newEvt.roomId = evt.params.room.getId();
         dispatchEvent(newEvt);
      }
      
      private function onRoomDeleted(evt:SFSEvent) : void
      {
         this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_ROOM_DELETED);
         newEvt.status = true;
         if(Boolean(evt) && Boolean(evt.params) && Boolean(evt.params.room))
         {
            newEvt.roomId = evt.params.room.getId();
         }
         dispatchEvent(newEvt);
      }
      
      private function onCreateRoomError(evt:SFSEvent) : void
      {
         this._currentSubRoomUsers = null;
         this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         this._currentSubRoomId = -1;
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_ROOM_CREATED);
         newEvt.status = false;
         newEvt.message = evt.params.error;
         trace("SFClient: ERROR: could not create room! Message:" + newEvt.message);
         dispatchEvent(newEvt);
      }
      
      public function handleRoomJoin(joinedRoom:SFRoom) : void
      {
         var jr:Room = null;
         var jrid:int = joinedRoom.id;
         if(this._currentSubRoomId == 0)
         {
            this._currSubRoom = joinedRoom;
            this._currentSubRoomId = jrid;
         }
         else
         {
            this._currRoom = joinedRoom;
            this._currentPrimaryRoomId = jrid;
         }
         if(ExternalInterface.available)
         {
            ExternalInterface.call("mrc",["dm","handleRoomJoin called"]);
         }
         var roomList:Array = this._sfs.getAllRooms();
         (roomList[jrid] = new Room(jrid,joinedRoom.name,joinedRoom.maxUsers,joinedRoom.maxSpectators,joinedRoom.isTemp,joinedRoom.isGame,joinedRoom.isPrivate,joinedRoom.isLimbo,joinedRoom.users,joinedRoom.spectators)).addUser(this._myUser,this._myUser.getId());
         this._sfs.activeRoomId = jrid;
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_JOIN_ROOM);
         newEvt.status = true;
         newEvt.roomId = jrid;
         newEvt.obj = {};
         newEvt.obj.room = joinedRoom;
         newEvt.obj.subRoom = this._currSubRoom;
         dispatchEvent(newEvt);
      }
      
      public function handleRoomJoinError(joinErrorMessage:String, denOwner:String = "") : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_JOIN_ROOM);
         newEvt.status = false;
         newEvt.message = joinErrorMessage;
         newEvt.obj = {};
         newEvt.obj.roomFull = joinErrorMessage == "This room is currently full";
         newEvt.obj.denOwner = denOwner;
         dispatchEvent(newEvt);
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
      
      private function onRoomLeft(evt:SFSEvent) : void
      {
         if(this._currentSubRoomId == 0)
         {
            throw new Error("Left a room while in the middle of making a sub room?!");
         }
         if(evt.params.roomId == this._currentSubRoomId)
         {
            this._currentSubRoomUsers = null;
            this._currentSubRoomId = -1;
         }
         else
         {
            this._currentPrimaryRoomUsers = null;
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_LEFT_ROOM);
         newEvt.status = true;
         newEvt.roomId = evt.params.roomId;
         dispatchEvent(newEvt);
      }
      
      private function onUserEnterRoom(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_USER_ENTERED_ROOM);
         newEvt.status = true;
         newEvt.userId = evt.params.user.getId();
         newEvt.userName = evt.params.user.getName();
         newEvt.roomId = evt.params.roomId;
         if(newEvt.roomId == this._currentPrimaryRoomId)
         {
            this._currentPrimaryRoomUsers[newEvt.userId] = evt.params.user;
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         else if(newEvt.roomId == this._currentSubRoomId)
         {
            this._currentSubRoomUsers[newEvt.userId] = evt.params.user;
            this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         }
         else
         {
            trace("ERROR: User entered not-one-of-mine roomId:" + newEvt.roomId + " _currentPrimaryRoomId:" + this._currentPrimaryRoomId + " _currentSubRoomId:" + this._currentSubRoomId);
         }
         dispatchEvent(newEvt);
      }
      
      private function onUserLeaveRoom(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_USER_LEFT_ROOM);
         newEvt.status = true;
         newEvt.userId = evt.params.userId;
         newEvt.roomId = evt.params.roomId;
         if(newEvt.roomId == this._currentPrimaryRoomId)
         {
            delete this._currentPrimaryRoomUsers[newEvt.userId];
            this.setAPIUserList(this._currentPrimaryRoomId,this._currentPrimaryRoomUsers);
         }
         else if(newEvt.roomId == this._currentSubRoomId)
         {
            delete this._currentSubRoomUsers[newEvt.userId];
            this.setAPIUserList(this._currentSubRoomId,this._currentSubRoomUsers);
         }
         else
         {
            trace("ERROR: User left not-one-of-mine roomId:" + newEvt.roomId + " _currentPrimaryRoomId:" + this._currentPrimaryRoomId + " _currentSubRoomId:" + this._currentSubRoomId);
         }
         dispatchEvent(newEvt);
      }
      
      private function onUserCountChange(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_ROOM_POPULATION_CHANGE);
         newEvt.status = true;
         newEvt.roomId = evt.params.room.getId();
         dispatchEvent(newEvt);
      }
      
      private function onBuddyList(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_BUDDY_LIST);
         newEvt.status = true;
         newEvt.obj = evt.params.list;
         newEvt.message = evt.params.error;
         dispatchEvent(newEvt);
      }
      
      private function onBuddyListError(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_BUDDY_LIST);
         newEvt.status = false;
         newEvt.message = evt.params.error;
         dispatchEvent(newEvt);
      }
      
      private function onBuddyListUpdate(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_BUDDY_LIST_UPDATE);
         newEvt.status = true;
         newEvt.userName = evt.params.buddy.name;
         newEvt.obj = evt.params.buddy;
         newEvt.message = evt.params.error;
         dispatchEvent(newEvt);
      }
      
      private function onBuddyPermissionRequest(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_BUDDY_REQUEST);
         newEvt.status = true;
         newEvt.userName = evt.params.sender;
         dispatchEvent(newEvt);
      }
      
      private function onBuddyRoom(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_BUDDY_ROOM);
         newEvt.status = true;
         newEvt.roomId = evt.params.idList[0];
         dispatchEvent(newEvt);
      }
      
      private function onAdminMessage(evt:SFSEvent) : void
      {
         DebugUtility.debugTrace("onAdminMessage:" + evt.params.message);
      }
      
      private function onModeratorMessage(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_CHAT_MESSAGE);
         newEvt.status = true;
         newEvt.message = evt.params.message;
         dispatchEvent(newEvt);
      }
      
      private function onPrivateMessage(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_CHAT_MESSAGE);
         newEvt.status = true;
         newEvt.message = evt.params.message;
         dispatchEvent(newEvt);
      }
      
      private function onPublicMessage(evt:SFSEvent) : void
      {
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_CHAT_MESSAGE);
         newEvt.status = true;
         newEvt.message = evt.params.message;
         dispatchEvent(newEvt);
      }
      
      private function onRandomKey(evt:SFSEvent) : void
      {
         this._hashKey = evt.params.key;
         trace("Random key received from server: " + this._hashKey);
         var newEvt:SFEvent = new SFEvent(SFEvent.ON_CONNECT);
         newEvt.status = true;
         dispatchEvent(newEvt);
      }
      
      public function get autoAttemptHttp() : Boolean
      {
         return this._sfs.smartConnect;
      }
      
      public function set autoAttemptHttp(setAutoAttemptHttp:Boolean) : void
      {
         this._sfs.smartConnect = setAutoAttemptHttp;
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
      
      public function set gemCount(value:int) : void
      {
         this._gemCount = value;
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

