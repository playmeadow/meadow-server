package it.gotoandplay.smartfoxserver.handlers
{
   import flash.utils.getTimer;
   import it.gotoandplay.smartfoxserver.SFSEvent;
   import it.gotoandplay.smartfoxserver.SmartFoxClient;
   import it.gotoandplay.smartfoxserver.data.Room;
   import it.gotoandplay.smartfoxserver.data.User;
   import it.gotoandplay.smartfoxserver.util.Entities;
   import it.gotoandplay.smartfoxserver.util.ObjectSerializer;
   
   public class SysHandler implements IMessageHandler
   {
      
      private var sfs:SmartFoxClient;
      
      private var handlersTable:Array;
      
      public function SysHandler(sfs:SmartFoxClient)
      {
         super();
         this.sfs = sfs;
         this.handlersTable = [];
         this.handlersTable["apiOK"] = this.handleApiOK;
         this.handlersTable["apiKO"] = this.handleApiKO;
         this.handlersTable["logOK"] = this.handleLoginOk;
         this.handlersTable["logKO"] = this.handleLoginKo;
         this.handlersTable["logout"] = this.handleLogout;
         this.handlersTable["rmList"] = this.handleRoomList;
         this.handlersTable["uCount"] = this.handleUserCountChange;
         this.handlersTable["joinOK"] = this.handleJoinOk;
         this.handlersTable["joinKO"] = this.handleJoinKo;
         this.handlersTable["uER"] = this.handleUserEnterRoom;
         this.handlersTable["userGone"] = this.handleUserLeaveRoom;
         this.handlersTable["pubMsg"] = this.handlePublicMessage;
         this.handlersTable["prvMsg"] = this.handlePrivateMessage;
         this.handlersTable["dmnMsg"] = this.handleAdminMessage;
         this.handlersTable["modMsg"] = this.handleModMessage;
         this.handlersTable["dataObj"] = this.handleASObject;
         this.handlersTable["rVarsUpdate"] = this.handleRoomVarsUpdate;
         this.handlersTable["roomAdd"] = this.handleRoomAdded;
         this.handlersTable["roomDel"] = this.handleRoomDeleted;
         this.handlersTable["rndK"] = this.handleRandomKey;
         this.handlersTable["roundTripRes"] = this.handleRoundTripBench;
         this.handlersTable["uVarsUpdate"] = this.handleUserVarsUpdate;
         this.handlersTable["createRmKO"] = this.handleCreateRoomError;
         this.handlersTable["bList"] = this.handleBuddyList;
         this.handlersTable["bUpd"] = this.handleBuddyListUpdate;
         this.handlersTable["bAdd"] = this.handleBuddyAdded;
         this.handlersTable["roomB"] = this.handleBuddyRoom;
         this.handlersTable["leaveRoom"] = this.handleLeaveRoom;
         this.handlersTable["swSpec"] = this.handleSpectatorSwitched;
         this.handlersTable["bPrm"] = this.handleAddBuddyPermission;
         this.handlersTable["remB"] = this.handleRemoveBuddy;
         this.handlersTable["swPl"] = this.handlePlayerSwitched;
      }
      
      public function handleMessage(msgObj:Object, type:String) : void
      {
         var xmlData:XML = msgObj as XML;
         var action:String = xmlData.body.@action;
         var fn:Function = this.handlersTable[action];
         if(fn != null)
         {
            fn.apply(this,[msgObj]);
         }
         else
         {
            trace("Unknown sys command: " + action);
         }
      }
      
      public function handleApiOK(o:Object) : void
      {
         this.sfs.isConnected = true;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onConnection,{"success":true});
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleApiKO(o:Object) : void
      {
         var params:Object = {};
         params.success = false;
         params.error = "API are obsolete, please upgrade";
         var evt:SFSEvent = new SFSEvent(SFSEvent.onConnection,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleLoginOk(o:Object) : void
      {
         var uid:int = int(o.body.login.@id);
         var mod:int = int(o.body.login.@mod);
         var name:String = o.body.login.@n;
         this.sfs.amIModerator = mod == 1;
         this.sfs.myUserId = uid;
         this.sfs.myUserName = name;
         this.sfs.playerId = -1;
         var params:Object = {};
         params.success = true;
         params.name = name;
         params.error = "";
         var evt:SFSEvent = new SFSEvent(SFSEvent.onLogin,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleLoginKo(o:Object) : void
      {
         var params:Object = {};
         params.success = false;
         params.error = o.body.login.@e;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onLogin,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleLogout(o:Object) : void
      {
         this.sfs.__logout();
         var evt:SFSEvent = new SFSEvent(SFSEvent.onLogout,{});
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleRoomList(o:Object) : void
      {
         var roomXml:XML = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var roomId:int = 0;
         var room:Room = null;
         var oldRoom:Room = null;
         var roomList:Array = this.sfs.getAllRooms();
         var tempList:Array = [];
         for each(roomXml in o.body.rmList.rm)
         {
            roomId = int(roomXml.@id);
            room = new Room(roomId,roomXml.n,int(roomXml.@maxu),int(roomXml.@maxs),roomXml.@temp == "1",roomXml.@game == "1",roomXml.@priv == "1",roomXml.@lmb == "1",int(roomXml.@ucnt),int(roomXml.@scnt));
            if(roomXml.vars.toString().length > 0)
            {
               this.populateVariables(room.getVariables(),roomXml);
            }
            oldRoom = roomList[roomId];
            if(oldRoom != null)
            {
               room.setVariables(oldRoom.getVariables());
               room.setUserList(oldRoom.getUserList());
            }
            tempList[roomId] = room;
         }
         this.sfs.setRoomList(tempList);
         params = {};
         params.roomList = tempList;
         evt = new SFSEvent(SFSEvent.onRoomListUpdate,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleUserCountChange(o:Object) : void
      {
         var params:Object = null;
         var evt:SFSEvent = null;
         var uCount:int = int(o.body.@u);
         var sCount:int = int(o.body.@s);
         var roomId:int = int(o.body.@r);
         var room:Room = this.sfs.getAllRooms()[roomId];
         if(room != null)
         {
            room.setUserCount(uCount);
            room.setSpectatorCount(sCount);
            params = {};
            params.room = room;
            evt = new SFSEvent(SFSEvent.onUserCountChange,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      public function handleJoinOk(o:Object) : void
      {
         var usr:XML = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var name:String = null;
         var id:int = 0;
         var isMod:Boolean = false;
         var isSpec:Boolean = false;
         var pId:int = 0;
         var user:User = null;
         var roomId:int = int(o.body.@r);
         var roomVarsXml:XMLList = o.body;
         var userListXml:XMLList = o.body.uLs.u;
         var playerId:int = int(o.body.pid.@id);
         this.sfs.activeRoomId = roomId;
         var currRoom:Room = this.sfs.getRoom(roomId);
         currRoom.clearUserList();
         this.sfs.playerId = playerId;
         currRoom.setMyPlayerIndex(playerId);
         if(roomVarsXml.vars.toString().length > 0)
         {
            currRoom.clearVariables();
            this.populateVariables(currRoom.getVariables(),roomVarsXml);
         }
         for each(usr in userListXml)
         {
            name = usr.n;
            id = int(usr.@i);
            isMod = usr.@m == "1" ? true : false;
            isSpec = usr.@s == "1" ? true : false;
            pId = usr.@p == null ? -1 : int(usr.@p);
            user = new User(id,name);
            user.setModerator(isMod);
            user.setIsSpectator(isSpec);
            user.setPlayerId(pId);
            if(usr.vars.toString().length > 0)
            {
               this.populateVariables(user.getVariables(),usr);
            }
            currRoom.addUser(user,id);
         }
         this.sfs.changingRoom = false;
         params = {};
         params.room = currRoom;
         evt = new SFSEvent(SFSEvent.onJoinRoom,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleJoinKo(o:Object) : void
      {
         this.sfs.changingRoom = false;
         var params:Object = {};
         params.error = o.body.error.@msg;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onJoinRoomError,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleUserEnterRoom(o:Object) : void
      {
         var roomId:int = int(o.body.@r);
         var usrId:int = int(o.body.u.@i);
         var usrName:String = o.body.u.n;
         var isMod:Boolean = o.body.u.@m == "1";
         var isSpec:Boolean = o.body.u.@s == "1";
         var pid:int = o.body.u.@p != null ? int(o.body.u.@p) : -1;
         var varList:XMLList = o.body.u.vars["var"];
         var currRoom:Room = this.sfs.getRoom(roomId);
         var newUser:User = new User(usrId,usrName);
         newUser.setModerator(isMod);
         newUser.setIsSpectator(isSpec);
         newUser.setPlayerId(pid);
         currRoom.addUser(newUser,usrId);
         if(o.body.u.vars.toString().length > 0)
         {
            this.populateVariables(newUser.getVariables(),o.body.u);
         }
         var params:Object = {};
         params.roomId = roomId;
         params.user = newUser;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onUserEnterRoom,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleUserLeaveRoom(o:Object) : void
      {
         var userId:int = int(o.body.user.@id);
         var roomId:int = int(o.body.@r);
         var theRoom:Room = this.sfs.getRoom(roomId);
         if(theRoom == null)
         {
            trace("WARN - Leave Room not found, id: " + roomId);
            return;
         }
         var uName:String = theRoom.getUser(userId).getName();
         theRoom.removeUser(userId);
         var params:Object = {};
         params.roomId = roomId;
         params.userId = userId;
         params.userName = uName;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onUserLeaveRoom,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handlePublicMessage(o:Object) : void
      {
         var roomId:int = int(o.body.@r);
         var userId:int = int(o.body.user.@id);
         var message:String = o.body.txt;
         var sender:User = this.sfs.getRoom(roomId).getUser(userId);
         var params:Object = {};
         params.message = Entities.decodeEntities(message);
         params.sender = sender;
         params.roomId = roomId;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onPublicMessage,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handlePrivateMessage(o:Object) : void
      {
         var roomId:int = int(o.body.@r);
         var userId:int = int(o.body.user.@id);
         var message:String = o.body.txt;
         var theRoom:Room = this.sfs.getRoom(roomId);
         var sender:User = null;
         if(theRoom != null)
         {
            sender = theRoom.getUser(userId);
         }
         var params:Object = {};
         params.message = Entities.decodeEntities(message);
         params.sender = sender;
         params.roomId = roomId;
         params.userId = userId;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onPrivateMessage,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleAdminMessage(o:Object) : void
      {
         var roomId:int = int(o.body.@r);
         var userId:int = int(o.body.user.@id);
         var message:String = o.body.txt;
         var params:Object = {};
         params.message = Entities.decodeEntities(message);
         var evt:SFSEvent = new SFSEvent(SFSEvent.onAdminMessage,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleModMessage(o:Object) : void
      {
         var roomId:int = int(o.body.@r);
         var userId:int = int(o.body.user.@id);
         var message:String = o.body.txt;
         var sender:User = null;
         var room:Room = this.sfs.getRoom(roomId);
         if(room != null)
         {
            sender = room.getUser(userId);
         }
         var params:Object = {};
         params.message = Entities.decodeEntities(message);
         params.sender = sender;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onModeratorMessage,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleASObject(o:Object) : void
      {
         var roomId:int = int(o.body.@r);
         var userId:int = int(o.body.user.@id);
         var xmlStr:String = o.body.dataObj;
         var sender:User = this.sfs.getRoom(roomId).getUser(userId);
         var asObj:Object = ObjectSerializer.getInstance().deserialize(new XML(xmlStr));
         var params:Object = {};
         params.obj = asObj;
         params.sender = sender;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onObjectReceived,params);
         this.sfs.dispatchEvent(evt);
      }
      
      public function handleRoomVarsUpdate(o:Object) : void
      {
         var params:Object = null;
         var evt:SFSEvent = null;
         var roomId:int = int(o.body.@r);
         var userId:int = int(o.body.user.@id);
         var theRoom:Room = this.sfs.getRoom(roomId);
         var changedVars:Array = [];
         if(theRoom != null)
         {
            if(o.body.vars.toString().length > 0)
            {
               this.populateVariables(theRoom.getVariables(),o.body,changedVars);
            }
            params = {};
            params.room = theRoom;
            params.changedVars = changedVars;
            evt = new SFSEvent(SFSEvent.onRoomVariablesUpdate,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      public function handleUserVarsUpdate(o:Object) : void
      {
         var changedVars:Array = null;
         var room:Room = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var userId:int = int(o.body.user.@id);
         var varOwner:User = null;
         var returnUser:User = null;
         if(o.body.vars.toString().length > 0)
         {
            for each(room in this.sfs.getAllRooms())
            {
               varOwner = room.getUser(userId);
               if(varOwner != null)
               {
                  if(returnUser == null)
                  {
                     returnUser = varOwner;
                  }
                  changedVars = [];
                  this.populateVariables(varOwner.getVariables(),o.body,changedVars);
               }
            }
            params = {};
            params.user = returnUser;
            params.changedVars = changedVars;
            evt = new SFSEvent(SFSEvent.onUserVariablesUpdate,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      private function handleRoomAdded(o:Object) : void
      {
         var rId:int = int(o.body.rm.@id);
         var rName:String = o.body.rm.name;
         var rMax:int = int(o.body.rm.@max);
         var rSpec:int = int(o.body.rm.@spec);
         var isTemp:Boolean = o.body.rm.@temp == "1" ? true : false;
         var isGame:Boolean = o.body.rm.@game == "1" ? true : false;
         var isPriv:Boolean = o.body.rm.@priv == "1" ? true : false;
         var isLimbo:Boolean = o.body.rm.@limbo == "1" ? true : false;
         var newRoom:Room = new Room(rId,rName,rMax,rSpec,isTemp,isGame,isPriv,isLimbo);
         var rList:Array = this.sfs.getAllRooms();
         rList[rId] = newRoom;
         if(o.body.rm.vars.toString().length > 0)
         {
            this.populateVariables(newRoom.getVariables(),o.body.rm);
         }
         var params:Object = {};
         params.room = newRoom;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onRoomAdded,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleRoomDeleted(o:Object) : void
      {
         var params:Object = null;
         var evt:SFSEvent = null;
         var roomId:int = int(o.body.rm.@id);
         var roomList:Array = this.sfs.getAllRooms();
         if(roomList[roomId] != null)
         {
            params = {};
            params.room = roomList[roomId];
            delete roomList[roomId];
            evt = new SFSEvent(SFSEvent.onRoomDeleted,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      private function handleRandomKey(o:Object) : void
      {
         var key:String = o.body.k.toString();
         var params:Object = {};
         params.key = key;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onRandomKey,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleRoundTripBench(o:Object) : void
      {
         var now:int = getTimer();
         var res:int = now - this.sfs.getBenchStartTime();
         var params:Object = {};
         params.elapsed = res;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onRoundTripResponse,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleCreateRoomError(o:Object) : void
      {
         var errMsg:String = o.body.room.@e;
         var params:Object = {};
         params.error = errMsg;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onCreateRoomError,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleBuddyList(o:Object) : void
      {
         var buddy:Object = null;
         var myVar:XML = null;
         var b:XML = null;
         var bVars:XMLList = null;
         var bVar:XML = null;
         var bList:XMLList = o.body.bList;
         var myVars:XMLList = o.body.mv;
         var params:Object = {};
         var evt:SFSEvent = null;
         if(myVars != null && myVars.toString().length > 0)
         {
            for each(myVar in myVars.v)
            {
               this.sfs.myBuddyVars[myVar.@n.toString()] = myVar.toString();
            }
         }
         if(bList != null && bList.b.length != null)
         {
            if(bList.toString().length > 0)
            {
               for each(b in bList.b)
               {
                  buddy = {};
                  buddy.isOnline = b.@s == "1" ? true : false;
                  buddy.name = b.n.toString();
                  buddy.id = b.@i;
                  buddy.isBlocked = b.@x == "1" ? true : false;
                  buddy.variables = {};
                  bVars = b.vs;
                  if(bVars.toString().length > 0)
                  {
                     for each(bVar in bVars.v)
                     {
                        buddy.variables[bVar.@n.toString()] = bVar.toString();
                     }
                  }
                  this.sfs.buddyList.push(buddy);
               }
            }
            params.list = this.sfs.buddyList;
            evt = new SFSEvent(SFSEvent.onBuddyList,params);
            this.sfs.dispatchEvent(evt);
         }
         else
         {
            params.error = o.body.err.toString();
            evt = new SFSEvent(SFSEvent.onBuddyListError,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      private function handleBuddyListUpdate(o:Object) : void
      {
         var buddy:Object = null;
         var bVars:XMLList = null;
         var tempB:Object = null;
         var found:Boolean = false;
         var it:String = null;
         var bVar:XML = null;
         var params:Object = {};
         var evt:SFSEvent = null;
         if(o.body.err.toString().length > 0)
         {
            params.error = o.body.err.toString();
            evt = new SFSEvent(SFSEvent.onBuddyListError,params);
            this.sfs.dispatchEvent(evt);
            return;
         }
         if(o.body.b != null)
         {
            buddy = {};
            buddy.isOnline = o.body.b.@s == "1" ? true : false;
            buddy.name = o.body.b.n.toString();
            buddy.id = o.body.b.@i;
            buddy.isBlocked = o.body.b.@x == "1" ? true : false;
            bVars = o.body.b.vs;
            tempB = null;
            found = false;
            for(it in this.sfs.buddyList)
            {
               tempB = this.sfs.buddyList[it];
               if(tempB.name == buddy.name)
               {
                  this.sfs.buddyList[it] = buddy;
                  buddy.isBlocked = tempB.isBlocked;
                  buddy.variables = tempB.variables;
                  if(bVars.toString().length > 0)
                  {
                     for each(bVar in bVars.v)
                     {
                        buddy.variables[bVar.@n.toString()] = bVar.toString();
                     }
                  }
                  found = true;
                  break;
               }
            }
            if(found)
            {
               params.buddy = buddy;
               evt = new SFSEvent(SFSEvent.onBuddyListUpdate,params);
               this.sfs.dispatchEvent(evt);
            }
         }
      }
      
      private function handleAddBuddyPermission(o:Object) : void
      {
         var params:Object = {};
         params.sender = o.body.n.toString();
         params.message = "";
         if(o.body.txt != undefined)
         {
            params.message = Entities.decodeEntities(o.body.txt);
         }
         var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyPermissionRequest,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleBuddyAdded(o:Object) : void
      {
         var bVar:XML = null;
         var buddy:Object = {};
         buddy.isOnline = o.body.b.@s == "1" ? true : false;
         buddy.name = o.body.b.n.toString();
         buddy.id = o.body.b.@i;
         buddy.isBlocked = o.body.b.@x == "1" ? true : false;
         buddy.variables = {};
         var bVars:XMLList = o.body.b.vs;
         if(bVars.toString().length > 0)
         {
            for each(bVar in bVars.v)
            {
               buddy.variables[bVar.@n.toString()] = bVar.toString();
            }
         }
         this.sfs.buddyList.push(buddy);
         var params:Object = {};
         params.list = this.sfs.buddyList;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyList,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleRemoveBuddy(o:Object) : void
      {
         var it:String = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var buddyName:String = o.body.n.toString();
         var buddy:Object = null;
         for(it in this.sfs.buddyList)
         {
            buddy = this.sfs.buddyList[it];
            if(buddy.name == buddyName)
            {
               delete this.sfs.buddyList[it];
               params = {};
               params.list = this.sfs.buddyList;
               evt = new SFSEvent(SFSEvent.onBuddyList,params);
               this.sfs.dispatchEvent(evt);
               break;
            }
         }
      }
      
      private function handleBuddyRoom(o:Object) : void
      {
         var roomIds:String = o.body.br.@r;
         var ids:Array = roomIds.split(",");
         for(var i:int = 0; i < ids.length; i++)
         {
            ids[i] = int(ids[i]);
         }
         var params:Object = {};
         params.idList = ids;
         var evt:SFSEvent = new SFSEvent(SFSEvent.onBuddyRoom,params);
         this.sfs.dispatchEvent(evt);
      }
      
      private function handleLeaveRoom(o:Object) : void
      {
         var params:Object = null;
         var evt:SFSEvent = null;
         var roomLeft:int = int(o.body.rm.@id);
         var roomList:Array = this.sfs.getAllRooms();
         if(Boolean(roomList[roomLeft]))
         {
            params = {};
            params.roomId = roomLeft;
            evt = new SFSEvent(SFSEvent.onRoomLeft,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      private function handleSpectatorSwitched(o:Object) : void
      {
         var userId:int = 0;
         var user:User = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var roomId:int = int(o.body.@r);
         var playerId:int = int(o.body.pid.@id);
         var theRoom:Room = this.sfs.getRoom(roomId);
         if(playerId > 0)
         {
            theRoom.setUserCount(theRoom.getUserCount() + 1);
            theRoom.setSpectatorCount(theRoom.getSpectatorCount() - 1);
         }
         if(o.body.pid.@u != undefined)
         {
            userId = int(o.body.pid.@u);
            user = theRoom.getUser(userId);
            if(user != null)
            {
               user.setIsSpectator(false);
               user.setPlayerId(playerId);
            }
         }
         else
         {
            this.sfs.playerId = playerId;
            params = {};
            params.success = this.sfs.playerId > 0;
            params.newId = this.sfs.playerId;
            params.room = theRoom;
            evt = new SFSEvent(SFSEvent.onSpectatorSwitched,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      private function handlePlayerSwitched(o:Object) : void
      {
         var userId:int = 0;
         var user:User = null;
         var params:Object = null;
         var evt:SFSEvent = null;
         var roomId:int = int(o.body.@r);
         var playerId:int = int(o.body.pid.@id);
         var isItMe:Boolean = o.body.pid.@u == undefined;
         var theRoom:Room = this.sfs.getRoom(roomId);
         if(playerId == -1)
         {
            theRoom.setUserCount(theRoom.getUserCount() - 1);
            theRoom.setSpectatorCount(theRoom.getSpectatorCount() + 1);
            if(!isItMe)
            {
               userId = int(o.body.pid.@u);
               user = theRoom.getUser(userId);
               if(user != null)
               {
                  user.setIsSpectator(true);
                  user.setPlayerId(playerId);
               }
            }
         }
         if(isItMe)
         {
            this.sfs.playerId = playerId;
            params = {};
            params.success = playerId == -1;
            params.newId = playerId;
            params.room = theRoom;
            evt = new SFSEvent(SFSEvent.onPlayerSwitched,params);
            this.sfs.dispatchEvent(evt);
         }
      }
      
      private function populateVariables(variables:Array, xmlData:Object, changedVars:Array = null) : void
      {
         var v:XML = null;
         var vName:String = null;
         var vType:String = null;
         var vValue:String = null;
         for each(v in xmlData.vars["var"])
         {
            vName = v.@n;
            vType = v.@t;
            vValue = v;
            if(changedVars != null)
            {
               changedVars.push(vName);
               changedVars[vName] = true;
            }
            if(vType == "b")
            {
               variables[vName] = vValue == "1" ? true : false;
            }
            else if(vType == "n")
            {
               variables[vName] = Number(vValue);
            }
            else if(vType == "s")
            {
               variables[vName] = vValue;
            }
            else if(vType == "x")
            {
               delete variables[vName];
            }
         }
      }
      
      public function dispatchDisconnection() : void
      {
         var evt:SFSEvent = new SFSEvent(SFSEvent.onConnectionLost,null);
         this.sfs.dispatchEvent(evt);
      }
   }
}

