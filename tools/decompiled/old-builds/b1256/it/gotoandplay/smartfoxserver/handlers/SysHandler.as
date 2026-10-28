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
      
      public function SysHandler(param1:SmartFoxClient)
      {
         super();
         this.sfs = param1;
         handlersTable = [];
         handlersTable["apiOK"] = this.handleApiOK;
         handlersTable["apiKO"] = this.handleApiKO;
         handlersTable["logOK"] = this.handleLoginOk;
         handlersTable["logKO"] = this.handleLoginKo;
         handlersTable["logout"] = this.handleLogout;
         handlersTable["rmList"] = this.handleRoomList;
         handlersTable["uCount"] = this.handleUserCountChange;
         handlersTable["joinOK"] = this.handleJoinOk;
         handlersTable["joinKO"] = this.handleJoinKo;
         handlersTable["uER"] = this.handleUserEnterRoom;
         handlersTable["userGone"] = this.handleUserLeaveRoom;
         handlersTable["pubMsg"] = this.handlePublicMessage;
         handlersTable["prvMsg"] = this.handlePrivateMessage;
         handlersTable["dmnMsg"] = this.handleAdminMessage;
         handlersTable["modMsg"] = this.handleModMessage;
         handlersTable["dataObj"] = this.handleASObject;
         handlersTable["rVarsUpdate"] = this.handleRoomVarsUpdate;
         handlersTable["roomAdd"] = this.handleRoomAdded;
         handlersTable["roomDel"] = this.handleRoomDeleted;
         handlersTable["rndK"] = this.handleRandomKey;
         handlersTable["roundTripRes"] = this.handleRoundTripBench;
         handlersTable["uVarsUpdate"] = this.handleUserVarsUpdate;
         handlersTable["createRmKO"] = this.handleCreateRoomError;
         handlersTable["bList"] = this.handleBuddyList;
         handlersTable["bUpd"] = this.handleBuddyListUpdate;
         handlersTable["bAdd"] = this.handleBuddyAdded;
         handlersTable["roomB"] = this.handleBuddyRoom;
         handlersTable["leaveRoom"] = this.handleLeaveRoom;
         handlersTable["swSpec"] = this.handleSpectatorSwitched;
         handlersTable["bPrm"] = this.handleAddBuddyPermission;
         handlersTable["remB"] = this.handleRemoveBuddy;
         handlersTable["swPl"] = this.handlePlayerSwitched;
      }
      
      public function handleMessage(param1:Object, param2:String) : void
      {
         var _loc3_:XML = param1 as XML;
         var _loc4_:String = _loc3_.body.@action;
         var _loc5_:Function = handlersTable[_loc4_];
         if(_loc5_ != null)
         {
            _loc5_.apply(this,[param1]);
         }
         else
         {
            trace("Unknown sys command: " + _loc4_);
         }
      }
      
      public function handleApiOK(param1:Object) : void
      {
         sfs.isConnected = true;
         var _loc2_:SFSEvent = new SFSEvent("onConnection",{"success":true});
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleApiKO(param1:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_.success = false;
         _loc3_.error = "API are obsolete, please upgrade";
         var _loc2_:SFSEvent = new SFSEvent("onConnection",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleLoginOk(param1:Object) : void
      {
         var _loc2_:int = int(param1.body.login.@id);
         var _loc5_:int = int(param1.body.login.@mod);
         var _loc4_:String = param1.body.login.@n;
         sfs.amIModerator = _loc5_ == 1;
         sfs.myUserId = _loc2_;
         sfs.myUserName = _loc4_;
         sfs.playerId = -1;
         var _loc6_:Object = {};
         _loc6_.success = true;
         _loc6_.name = _loc4_;
         _loc6_.error = "";
         var _loc3_:SFSEvent = new SFSEvent("onLogin",_loc6_);
         sfs.dispatchEvent(_loc3_);
      }
      
      public function handleLoginKo(param1:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_.success = false;
         _loc3_.error = param1.body.login.@e;
         var _loc2_:SFSEvent = new SFSEvent("onLogin",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleLogout(param1:Object) : void
      {
         sfs.__logout();
         var _loc2_:SFSEvent = new SFSEvent("onLogout",{});
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleRoomList(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc8_:Room = null;
         var _loc7_:Room = null;
         var _loc3_:Array = sfs.getAllRooms();
         var _loc9_:Array = [];
         for each(var _loc2_:XML in param1.body.rmList.rm)
         {
            _loc5_ = int(_loc2_.@id);
            _loc8_ = new Room(_loc5_,_loc2_.n,int(_loc2_.@maxu),int(_loc2_.@maxs),_loc2_.@temp == "1",_loc2_.@game == "1",_loc2_.@priv == "1",_loc2_.@lmb == "1",int(_loc2_.@ucnt),int(_loc2_.@scnt));
            if(_loc2_.vars.toString().length > 0)
            {
               populateVariables(_loc8_.getVariables(),_loc2_);
            }
            _loc7_ = _loc3_[_loc5_];
            if(_loc7_ != null)
            {
               _loc8_.setVariables(_loc7_.getVariables());
               _loc8_.setUserList(_loc7_.getUserList());
            }
            _loc9_[_loc5_] = _loc8_;
         }
         sfs.setRoomList(_loc9_);
         var _loc6_:Object = {};
         _loc6_.roomList = _loc9_;
         var _loc4_:SFSEvent = new SFSEvent("onRoomListUpdate",_loc6_);
         sfs.dispatchEvent(_loc4_);
      }
      
      public function handleUserCountChange(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc4_:SFSEvent = null;
         var _loc3_:int = int(param1.body.@u);
         var _loc2_:int = int(param1.body.@s);
         var _loc5_:int = int(param1.body.@r);
         var _loc7_:Room = sfs.getAllRooms()[_loc5_];
         if(_loc7_ != null)
         {
            _loc7_.setUserCount(_loc3_);
            _loc7_.setSpectatorCount(_loc2_);
            _loc6_ = {};
            _loc6_.room = _loc7_;
            _loc4_ = new SFSEvent("onUserCountChange",_loc6_);
            sfs.dispatchEvent(_loc4_);
         }
      }
      
      public function handleJoinOk(param1:Object) : void
      {
         var _loc11_:String = null;
         var _loc5_:int = 0;
         var _loc7_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc6_:int = 0;
         var _loc14_:User = null;
         var _loc2_:int = int(param1.body.@r);
         var _loc15_:XMLList = param1.body;
         var _loc13_:XMLList = param1.body.uLs.u;
         var _loc8_:int = int(param1.body.pid.@id);
         sfs.activeRoomId = _loc2_;
         var _loc10_:Room = sfs.getRoom(_loc2_);
         _loc10_.clearUserList();
         sfs.playerId = _loc8_;
         _loc10_.setMyPlayerIndex(_loc8_);
         if(_loc15_.vars.toString().length > 0)
         {
            _loc10_.clearVariables();
            populateVariables(_loc10_.getVariables(),_loc15_);
         }
         for each(var _loc12_:XML in _loc13_)
         {
            _loc11_ = _loc12_.n;
            _loc5_ = int(_loc12_.@i);
            _loc7_ = _loc12_.@m == "1" ? true : false;
            _loc3_ = _loc12_.@s == "1" ? true : false;
            _loc6_ = int(_loc12_.@p == null ? -1 : int(_loc12_.@p));
            _loc14_ = new User(_loc5_,_loc11_);
            _loc14_.setModerator(_loc7_);
            _loc14_.setIsSpectator(_loc3_);
            _loc14_.setPlayerId(_loc6_);
            if(_loc12_.vars.toString().length > 0)
            {
               populateVariables(_loc14_.getVariables(),_loc12_);
            }
            _loc10_.addUser(_loc14_,_loc5_);
         }
         sfs.changingRoom = false;
         var _loc4_:Object = {};
         _loc4_.room = _loc10_;
         var _loc9_:SFSEvent = new SFSEvent("onJoinRoom",_loc4_);
         sfs.dispatchEvent(_loc9_);
      }
      
      public function handleJoinKo(param1:Object) : void
      {
         sfs.changingRoom = false;
         var _loc3_:Object = {};
         _loc3_.error = param1.body.error.@msg;
         var _loc2_:SFSEvent = new SFSEvent("onJoinRoomError",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      public function handleUserEnterRoom(param1:Object) : void
      {
         var _loc7_:int = int(param1.body.@r);
         var _loc3_:int = int(param1.body.u.@i);
         var _loc10_:String = param1.body.u.n;
         var _loc2_:Boolean = param1.body.u.@m == "1";
         var _loc6_:Boolean = param1.body.u.@s == "1";
         var _loc8_:int = int(param1.body.u.@p != null ? int(param1.body.u.@p) : -1);
         var _loc12_:XMLList = param1.body.u.vars["var"];
         var _loc5_:Room = sfs.getRoom(_loc7_);
         var _loc11_:User = new User(_loc3_,_loc10_);
         _loc11_.setModerator(_loc2_);
         _loc11_.setIsSpectator(_loc6_);
         _loc11_.setPlayerId(_loc8_);
         _loc5_.addUser(_loc11_,_loc3_);
         if(param1.body.u.vars.toString().length > 0)
         {
            populateVariables(_loc11_.getVariables(),param1.body.u);
         }
         var _loc9_:Object = {};
         _loc9_.roomId = _loc7_;
         _loc9_.user = _loc11_;
         var _loc4_:SFSEvent = new SFSEvent("onUserEnterRoom",_loc9_);
         sfs.dispatchEvent(_loc4_);
      }
      
      public function handleUserLeaveRoom(param1:Object) : void
      {
         var _loc4_:int = int(param1.body.user.@id);
         var _loc6_:int = int(param1.body.@r);
         var _loc5_:Room = sfs.getRoom(_loc6_);
         if(_loc5_ == null)
         {
            trace("WARN - Leave Room not found, id: " + _loc6_);
            return;
         }
         var _loc2_:String = _loc5_.getUser(_loc4_).getName();
         _loc5_.removeUser(_loc4_);
         var _loc7_:Object = {};
         _loc7_.roomId = _loc6_;
         _loc7_.userId = _loc4_;
         _loc7_.userName = _loc2_;
         var _loc3_:SFSEvent = new SFSEvent("onUserLeaveRoom",_loc7_);
         sfs.dispatchEvent(_loc3_);
      }
      
      public function handlePublicMessage(param1:Object) : void
      {
         var _loc6_:int = int(param1.body.@r);
         var _loc5_:int = int(param1.body.user.@id);
         var _loc3_:String = param1.body.txt;
         var _loc2_:User = sfs.getRoom(_loc6_).getUser(_loc5_);
         var _loc7_:Object = {};
         _loc7_.message = Entities.decodeEntities(_loc3_);
         _loc7_.sender = _loc2_;
         _loc7_.roomId = _loc6_;
         var _loc4_:SFSEvent = new SFSEvent("onPublicMessage",_loc7_);
         sfs.dispatchEvent(_loc4_);
      }
      
      public function handlePrivateMessage(param1:Object) : void
      {
         var _loc7_:int = int(param1.body.@r);
         var _loc5_:int = int(param1.body.user.@id);
         var _loc3_:String = param1.body.txt;
         var _loc6_:Room = sfs.getRoom(_loc7_);
         var _loc2_:User = null;
         if(_loc6_ != null)
         {
            _loc2_ = _loc6_.getUser(_loc5_);
         }
         var _loc8_:Object = {};
         _loc8_.message = Entities.decodeEntities(_loc3_);
         _loc8_.sender = _loc2_;
         _loc8_.roomId = _loc7_;
         _loc8_.userId = _loc5_;
         var _loc4_:SFSEvent = new SFSEvent("onPrivateMessage",_loc8_);
         sfs.dispatchEvent(_loc4_);
      }
      
      public function handleAdminMessage(param1:Object) : void
      {
         var _loc5_:int = int(param1.body.@r);
         var _loc4_:int = int(param1.body.user.@id);
         var _loc2_:String = param1.body.txt;
         var _loc6_:Object = {};
         _loc6_.message = Entities.decodeEntities(_loc2_);
         var _loc3_:SFSEvent = new SFSEvent("onAdminMessage",_loc6_);
         sfs.dispatchEvent(_loc3_);
      }
      
      public function handleModMessage(param1:Object) : void
      {
         var _loc6_:int = int(param1.body.@r);
         var _loc5_:int = int(param1.body.user.@id);
         var _loc3_:String = param1.body.txt;
         var _loc2_:User = null;
         var _loc8_:Room = sfs.getRoom(_loc6_);
         if(_loc8_ != null)
         {
            _loc2_ = _loc8_.getUser(_loc5_);
         }
         var _loc7_:Object = {};
         _loc7_.message = Entities.decodeEntities(_loc3_);
         _loc7_.sender = _loc2_;
         var _loc4_:SFSEvent = new SFSEvent("onModMessage",_loc7_);
         sfs.dispatchEvent(_loc4_);
      }
      
      public function handleASObject(param1:Object) : void
      {
         var _loc7_:int = int(param1.body.@r);
         var _loc6_:int = int(param1.body.user.@id);
         var _loc4_:String = param1.body.dataObj;
         var _loc2_:User = sfs.getRoom(_loc7_).getUser(_loc6_);
         var _loc3_:Object = ObjectSerializer.getInstance().deserialize(new XML(_loc4_));
         var _loc8_:Object = {};
         _loc8_.obj = _loc3_;
         _loc8_.sender = _loc2_;
         var _loc5_:SFSEvent = new SFSEvent("onObjectReceived",_loc8_);
         sfs.dispatchEvent(_loc5_);
      }
      
      public function handleRoomVarsUpdate(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc5_:int = int(param1.body.@r);
         var _loc3_:int = int(param1.body.user.@id);
         var _loc4_:Room = sfs.getRoom(_loc5_);
         var _loc7_:Array = [];
         if(_loc4_ != null)
         {
            if(param1.body.vars.toString().length > 0)
            {
               populateVariables(_loc4_.getVariables(),param1.body,_loc7_);
            }
            _loc6_ = {};
            _loc6_.room = _loc4_;
            _loc6_.changedVars = _loc7_;
            _loc2_ = new SFSEvent("onRoomVariablesUpdate",_loc6_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      public function handleUserVarsUpdate(param1:Object) : void
      {
         var _loc7_:Array = null;
         var _loc6_:Object = null;
         var _loc2_:SFSEvent = null;
         var _loc4_:int = int(param1.body.user.@id);
         var _loc5_:User = null;
         var _loc3_:User = null;
         if(param1.body.vars.toString().length > 0)
         {
            for each(var _loc8_:Room in sfs.getAllRooms())
            {
               _loc5_ = _loc8_.getUser(_loc4_);
               if(_loc5_ != null)
               {
                  if(_loc3_ == null)
                  {
                     _loc3_ = _loc5_;
                  }
                  _loc7_ = [];
                  populateVariables(_loc5_.getVariables(),param1.body,_loc7_);
               }
            }
            _loc6_ = {};
            _loc6_.user = _loc3_;
            _loc6_.changedVars = _loc7_;
            _loc2_ = new SFSEvent("onUserVariablesUpdate",_loc6_);
            sfs.dispatchEvent(_loc2_);
         }
      }
      
      private function handleRoomAdded(param1:Object) : void
      {
         var _loc13_:int = int(param1.body.rm.@id);
         var _loc3_:String = param1.body.rm.name;
         var _loc9_:int = int(param1.body.rm.@max);
         var _loc4_:int = int(param1.body.rm.@spec);
         var _loc6_:Boolean = param1.body.rm.@temp == "1" ? true : false;
         var _loc12_:Boolean = param1.body.rm.@game == "1" ? true : false;
         var _loc11_:Boolean = param1.body.rm.@priv == "1" ? true : false;
         var _loc2_:Boolean = param1.body.rm.@limbo == "1" ? true : false;
         var _loc8_:Room = new Room(_loc13_,_loc3_,_loc9_,_loc4_,_loc6_,_loc12_,_loc11_,_loc2_);
         var _loc5_:Array = sfs.getAllRooms();
         _loc5_[_loc13_] = _loc8_;
         if(param1.body.rm.vars.toString().length > 0)
         {
            populateVariables(_loc8_.getVariables(),param1.body.rm);
         }
         var _loc10_:Object = {};
         _loc10_.room = _loc8_;
         var _loc7_:SFSEvent = new SFSEvent("onRoomAdded",_loc10_);
         sfs.dispatchEvent(_loc7_);
      }
      
      private function handleRoomDeleted(param1:Object) : void
      {
         var _loc5_:Object = null;
         var _loc3_:SFSEvent = null;
         var _loc4_:int = int(param1.body.rm.@id);
         var _loc2_:Array = sfs.getAllRooms();
         if(_loc2_[_loc4_] != null)
         {
            _loc5_ = {};
            _loc5_.room = _loc2_[_loc4_];
            delete _loc2_[_loc4_];
            _loc3_ = new SFSEvent("onRoomDeleted",_loc5_);
            sfs.dispatchEvent(_loc3_);
         }
      }
      
      private function handleRandomKey(param1:Object) : void
      {
         var _loc4_:String = param1.body.k.toString();
         var _loc3_:Object = {};
         _loc3_.key = _loc4_;
         var _loc2_:SFSEvent = new SFSEvent("onRandomKey",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleRoundTripBench(param1:Object) : void
      {
         var _loc3_:int = getTimer();
         var _loc2_:int = _loc3_ - sfs.getBenchStartTime();
         var _loc5_:Object = {};
         _loc5_.elapsed = _loc2_;
         var _loc4_:SFSEvent = new SFSEvent("onRoundTripResponse",_loc5_);
         sfs.dispatchEvent(_loc4_);
      }
      
      private function handleCreateRoomError(param1:Object) : void
      {
         var _loc3_:String = param1.body.room.@e;
         var _loc4_:Object = {};
         _loc4_.error = _loc3_;
         var _loc2_:SFSEvent = new SFSEvent("onCreateRoomError",_loc4_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleBuddyList(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc10_:XMLList = null;
         var _loc9_:XMLList = param1.body.bList;
         var _loc5_:XMLList = param1.body.mv;
         var _loc8_:Object = {};
         var _loc6_:SFSEvent = null;
         if(_loc5_ != null && _loc5_.toString().length > 0)
         {
            for each(var _loc7_:XML in _loc5_.v)
            {
               sfs.myBuddyVars[_loc7_.@n.toString()] = _loc7_.toString();
            }
         }
         if(_loc9_ != null && _loc9_.b.length != null)
         {
            if(_loc9_.toString().length > 0)
            {
               for each(var _loc4_:XML in _loc9_.b)
               {
                  _loc2_ = {};
                  _loc2_.isOnline = _loc4_.@s == "1" ? true : false;
                  _loc2_.name = _loc4_.n.toString();
                  _loc2_.id = _loc4_.@i;
                  _loc2_.isBlocked = _loc4_.@x == "1" ? true : false;
                  _loc2_.variables = {};
                  _loc10_ = _loc4_.vs;
                  if(_loc10_.toString().length > 0)
                  {
                     for each(var _loc3_:XML in _loc10_.v)
                     {
                        _loc2_.variables[_loc3_.@n.toString()] = _loc3_.toString();
                     }
                  }
                  sfs.buddyList.push(_loc2_);
               }
            }
            _loc8_.list = sfs.buddyList;
            _loc6_ = new SFSEvent("onBuddyList",_loc8_);
            sfs.dispatchEvent(_loc6_);
         }
         else
         {
            _loc8_.error = param1.body.err.toString();
            _loc6_ = new SFSEvent("onBuddyListError",_loc8_);
            sfs.dispatchEvent(_loc6_);
         }
      }
      
      private function handleBuddyListUpdate(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc9_:XMLList = null;
         var _loc3_:Object = null;
         var _loc8_:Boolean = false;
         var _loc7_:Object = {};
         var _loc6_:SFSEvent = null;
         if(param1.body.err.toString().length > 0)
         {
            _loc7_.error = param1.body.err.toString();
            _loc6_ = new SFSEvent("onBuddyListError",_loc7_);
            sfs.dispatchEvent(_loc6_);
            return;
         }
         if(param1.body.b != null)
         {
            _loc2_ = {};
            _loc2_.isOnline = param1.body.b.@s == "1" ? true : false;
            _loc2_.name = param1.body.b.n.toString();
            _loc2_.id = param1.body.b.@i;
            _loc2_.isBlocked = param1.body.b.@x == "1" ? true : false;
            _loc9_ = param1.body.b.vs;
            _loc3_ = null;
            _loc8_ = false;
            for(var _loc5_:String in sfs.buddyList)
            {
               _loc3_ = sfs.buddyList[_loc5_];
               if(_loc3_.name == _loc2_.name)
               {
                  sfs.buddyList[_loc5_] = _loc2_;
                  _loc2_.isBlocked = _loc3_.isBlocked;
                  _loc2_.variables = _loc3_.variables;
                  if(_loc9_.toString().length > 0)
                  {
                     for each(var _loc4_:XML in _loc9_.v)
                     {
                        _loc2_.variables[_loc4_.@n.toString()] = _loc4_.toString();
                     }
                  }
                  _loc8_ = true;
                  break;
               }
            }
            if(_loc8_)
            {
               _loc7_.buddy = _loc2_;
               _loc6_ = new SFSEvent("onBuddyListUpdate",_loc7_);
               sfs.dispatchEvent(_loc6_);
            }
         }
      }
      
      private function handleAddBuddyPermission(param1:Object) : void
      {
         var _loc3_:Object = {};
         _loc3_.sender = param1.body.n.toString();
         _loc3_.message = "";
         if(param1.body.txt != undefined)
         {
            _loc3_.message = Entities.decodeEntities(param1.body.txt);
         }
         var _loc2_:SFSEvent = new SFSEvent("onBuddyPermissionRequest",_loc3_);
         sfs.dispatchEvent(_loc2_);
      }
      
      private function handleBuddyAdded(param1:Object) : void
      {
         var _loc2_:Object = {};
         _loc2_.isOnline = param1.body.b.@s == "1" ? true : false;
         _loc2_.name = param1.body.b.n.toString();
         _loc2_.id = param1.body.b.@i;
         _loc2_.isBlocked = param1.body.b.@x == "1" ? true : false;
         _loc2_.variables = {};
         var _loc6_:XMLList = param1.body.b.vs;
         if(_loc6_.toString().length > 0)
         {
            for each(var _loc3_:XML in _loc6_.v)
            {
               _loc2_.variables[_loc3_.@n.toString()] = _loc3_.toString();
            }
         }
         sfs.buddyList.push(_loc2_);
         var _loc5_:Object = {};
         _loc5_.list = sfs.buddyList;
         var _loc4_:SFSEvent = new SFSEvent("onBuddyList",_loc5_);
         sfs.dispatchEvent(_loc4_);
      }
      
      private function handleRemoveBuddy(param1:Object) : void
      {
         var _loc6_:Object = null;
         var _loc5_:SFSEvent = null;
         var _loc4_:String = param1.body.n.toString();
         var _loc2_:Object = null;
         for(var _loc3_:String in sfs.buddyList)
         {
            _loc2_ = sfs.buddyList[_loc3_];
            if(_loc2_.name == _loc4_)
            {
               delete sfs.buddyList[_loc3_];
               _loc6_ = {};
               _loc6_.list = sfs.buddyList;
               _loc5_ = new SFSEvent("onBuddyList",_loc6_);
               sfs.dispatchEvent(_loc5_);
               break;
            }
         }
      }
      
      private function handleBuddyRoom(param1:Object) : void
      {
         var _loc6_:int = 0;
         var _loc3_:String = param1.body.br.@r;
         var _loc2_:Array = _loc3_.split(",");
         _loc6_ = 0;
         while(_loc6_ < _loc2_.length)
         {
            _loc2_[_loc6_] = int(_loc2_[_loc6_]);
            _loc6_++;
         }
         var _loc5_:Object = {};
         _loc5_.idList = _loc2_;
         var _loc4_:SFSEvent = new SFSEvent("onBuddyRoom",_loc5_);
         sfs.dispatchEvent(_loc4_);
      }
      
      private function handleLeaveRoom(param1:Object) : void
      {
         var _loc4_:Object = null;
         var _loc3_:SFSEvent = null;
         var _loc5_:int = int(param1.body.rm.@id);
         var _loc2_:Array = sfs.getAllRooms();
         if(_loc2_[_loc5_])
         {
            _loc4_ = {};
            _loc4_.roomId = _loc5_;
            _loc3_ = new SFSEvent("onRoomLeft",_loc4_);
            sfs.dispatchEvent(_loc3_);
         }
      }
      
      private function handleSpectatorSwitched(param1:Object) : void
      {
         var _loc4_:int = 0;
         var _loc8_:User = null;
         var _loc7_:Object = null;
         var _loc3_:SFSEvent = null;
         var _loc6_:int = int(param1.body.@r);
         var _loc2_:int = int(param1.body.pid.@id);
         var _loc5_:Room = sfs.getRoom(_loc6_);
         if(_loc2_ > 0)
         {
            _loc5_.setUserCount(_loc5_.getUserCount() + 1);
            _loc5_.setSpectatorCount(_loc5_.getSpectatorCount() - 1);
         }
         if(param1.body.pid.@u != undefined)
         {
            _loc4_ = int(param1.body.pid.@u);
            _loc8_ = _loc5_.getUser(_loc4_);
            if(_loc8_ != null)
            {
               _loc8_.setIsSpectator(false);
               _loc8_.setPlayerId(_loc2_);
            }
         }
         else
         {
            sfs.playerId = _loc2_;
            _loc7_ = {};
            _loc7_.success = sfs.playerId > 0;
            _loc7_.newId = sfs.playerId;
            _loc7_.room = _loc5_;
            _loc3_ = new SFSEvent("onSpectatorSwitched",_loc7_);
            sfs.dispatchEvent(_loc3_);
         }
      }
      
      private function handlePlayerSwitched(param1:Object) : void
      {
         var _loc5_:int = 0;
         var _loc9_:User = null;
         var _loc8_:Object = null;
         var _loc4_:SFSEvent = null;
         var _loc7_:int = int(param1.body.@r);
         var _loc3_:int = int(param1.body.pid.@id);
         var _loc2_:Boolean = param1.body.pid.@u == undefined;
         var _loc6_:Room = sfs.getRoom(_loc7_);
         if(_loc3_ == -1)
         {
            _loc6_.setUserCount(_loc6_.getUserCount() - 1);
            _loc6_.setSpectatorCount(_loc6_.getSpectatorCount() + 1);
            if(!_loc2_)
            {
               _loc5_ = int(param1.body.pid.@u);
               _loc9_ = _loc6_.getUser(_loc5_);
               if(_loc9_ != null)
               {
                  _loc9_.setIsSpectator(true);
                  _loc9_.setPlayerId(_loc3_);
               }
            }
         }
         if(_loc2_)
         {
            sfs.playerId = _loc3_;
            _loc8_ = {};
            _loc8_.success = _loc3_ == -1;
            _loc8_.newId = _loc3_;
            _loc8_.room = _loc6_;
            _loc4_ = new SFSEvent("onPlayerSwitched",_loc8_);
            sfs.dispatchEvent(_loc4_);
         }
      }
      
      private function populateVariables(param1:Array, param2:Object, param3:Array = null) : void
      {
         var _loc5_:String = null;
         var _loc7_:String = null;
         var _loc6_:String = null;
         for each(var _loc4_:XML in param2.vars["var"])
         {
            _loc5_ = _loc4_.@n;
            _loc7_ = _loc4_.@t;
            _loc6_ = _loc4_;
            if(param3 != null)
            {
               param3.push(_loc5_);
               param3[_loc5_] = true;
            }
            if(_loc7_ == "b")
            {
               param1[_loc5_] = _loc6_ == "1" ? true : false;
            }
            else if(_loc7_ == "n")
            {
               param1[_loc5_] = Number(_loc6_);
            }
            else if(_loc7_ == "s")
            {
               param1[_loc5_] = _loc6_;
            }
            else if(_loc7_ == "x")
            {
               delete param1[_loc5_];
            }
         }
      }
      
      public function dispatchDisconnection() : void
      {
         var _loc1_:SFSEvent = new SFSEvent("onConnectionLost",null);
         sfs.dispatchEvent(_loc1_);
      }
   }
}

