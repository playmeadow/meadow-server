package avatar
{
   import com.sbi.debug.DebugUtility;
   import flash.utils.Dictionary;
   import localization.LocalizationManager;
   
   public class UserInfoCache
   {
      
      public var myBuddyCount:int;
      
      public var myUUID:String;
      
      public var isMember:Boolean;
      
      public var isModerator:Boolean;
      
      public var isGuide:Boolean;
      
      public var isSilenced:Boolean;
      
      public var isMyDenPrivate:Boolean;
      
      public var sgChatType:int;
      
      public var sgChatTypeNonDegraded:int;
      
      public var firstFiveMinutes:int;
      
      public var needFastPass:Boolean;
      
      public var pendingFlags:Number;
      
      public var activeDenRoomInvId:int;
      
      public var numLogins:int;
      
      public var playerWallSettings:int;
      
      public var worldMapRoomName:String;
      
      public var avtDefsCached:Boolean;
      
      private var _myUserName:String;
      
      private var _userInfo:Object;
      
      private var _perUserAvIdToUserName:Dictionary;
      
      private var _myPerUserAvId:int;
      
      private var _myUserVarCache:UserVarCache;
      
      private var _avatarDefs:Object;
      
      private var _customAvatarDefs:Object;
      
      private var _denRoomDefs:Object;
      
      private var _genericListDefsInfo:Object;
      
      private var _myTradeList:Array;
      
      private var _myPetsInDen:Array;
      
      public function UserInfoCache()
      {
         super();
      }
      
      public function init() : void
      {
         this._userInfo = {};
         this._myPerUserAvId = -1;
         this._myUserName = "";
         this.avtDefsCached = false;
         this._myUserVarCache = new UserVarCache();
         this._myUserVarCache.init();
         this._perUserAvIdToUserName = new Dictionary(true);
         this._avatarDefs = new Object();
         this._customAvatarDefs = new Object();
         this._genericListDefsInfo = new Object();
         this._myTradeList = [];
      }
      
      public function destroy() : void
      {
         this._userInfo = null;
         this._avatarDefs = null;
         this._customAvatarDefs = null;
         this._denRoomDefs = null;
         this._genericListDefsInfo = null;
         this._myTradeList = null;
      }
      
      public function getUserInfoByUserName(param1:String) : UserInfo
      {
         return this._userInfo[param1];
      }
      
      public function setUserInfoByUserName(param1:String, param2:UserInfo) : void
      {
         var _loc3_:UserInfo = null;
         var _loc4_:AvatarInfo = null;
         if(Boolean(param1) && param1 != "")
         {
            _loc3_ = this._userInfo[param1] = param2;
            for each(_loc4_ in _loc3_.avList)
            {
               this._perUserAvIdToUserName[_loc4_.perUserAvId] = param1;
            }
         }
      }
      
      public function getAvatarInfoByUsernamePerUserAvId(param1:String, param2:int) : AvatarInfo
      {
         var _loc3_:UserInfo = null;
         var _loc4_:AvatarInfo = null;
         loop0:
         for each(_loc3_ in this._userInfo)
         {
            var _loc7_:int = 0;
            var _loc8_:* = _loc3_.avList;
            do
            {
               for each(_loc4_ in _loc8_)
               {
               }
               continue loop0;
            }
            while(!(_loc4_.userName.toLowerCase() == param1.toLowerCase() && _loc4_.perUserAvId == param2));
            return _loc4_;
         }
         return null;
      }
      
      public function changeUserName(param1:String, param2:String, param3:int) : void
      {
         var _loc4_:UserInfo = null;
         var _loc5_:AvatarInfo = null;
         if(this._userInfo.hasOwnProperty(param1))
         {
            _loc4_ = this._userInfo[param1];
            this._userInfo[param2] = _loc4_;
            this._userInfo[param2].userName = param2;
            this._userInfo[param2].userNameModeratedFlag = param3;
            for each(_loc5_ in _loc4_.avList)
            {
               _loc5_.userName = param2;
               this._perUserAvIdToUserName[_loc5_.perUserAvId] = param2;
            }
            delete this._userInfo[param1];
         }
      }
      
      public function getAvatarInfoByUserName(param1:String) : AvatarInfo
      {
         param1 = param1;
         if(this._userInfo.hasOwnProperty(param1))
         {
            return this._userInfo[param1].avList[this._userInfo[param1].currPerUserAvId];
         }
         return null;
      }
      
      public function getAvatarInfoByUserNameThenPerUserAvId(param1:String, param2:int) : AvatarInfo
      {
         var _loc3_:Object = null;
         if(this._userInfo.hasOwnProperty(param1))
         {
            _loc3_ = this._userInfo[param1];
            return this._userInfo[param1].avList[param2];
         }
         return null;
      }
      
      public function get myPerUserAvId() : int
      {
         return this._myPerUserAvId;
      }
      
      public function setCurrAvDbId(param1:String, param2:int) : void
      {
         if(this._userInfo.hasOwnProperty(param1))
         {
            this._userInfo[param1].currPerUserAvId = param2;
         }
      }
      
      public function set myPerUserAvId(param1:int) : void
      {
         this._myPerUserAvId = param1;
         if(this._userInfo.hasOwnProperty(this.myUserName) && Boolean(this._userInfo[this.myUserName]))
         {
            UserInfo(this._userInfo[this.myUserName]).currPerUserAvId = param1;
         }
      }
      
      public function setAvatarInfoByUsernamePerUserAvId(param1:int, param2:AvatarInfo, param3:Boolean = false) : void
      {
         var _loc4_:String = param2.userName;
         if(!this._userInfo.hasOwnProperty(_loc4_))
         {
            throw new Error("Invalid setAvatarInfo! Needs userName!");
         }
         this._userInfo[_loc4_].avList[param1] = param2;
         if(param3)
         {
            this._userInfo[_loc4_].currPerUserAvId = param1;
            this._perUserAvIdToUserName[param1] = _loc4_;
         }
      }
      
      public function setAccountTypeByUserName(param1:String, param2:int) : void
      {
         param1 = param1.toLowerCase();
         if(this._userInfo.hasOwnProperty(param1))
         {
            this._userInfo[param1].accountType = param2;
         }
      }
      
      public function set playerAvatarInfo(param1:AvatarInfo) : void
      {
         this._myPerUserAvId = param1.perUserAvId;
         this.myUserName = param1.userName;
         var _loc2_:UserInfo = UserInfo(this._userInfo[this.myUserName]);
         if(_loc2_)
         {
            _loc2_.avList[this._myPerUserAvId] = param1;
            _loc2_.currPerUserAvId = this._myPerUserAvId;
         }
      }
      
      public function get playerAvatarInfo() : AvatarInfo
      {
         try
         {
            return this._userInfo[this.myUserName].avList[this._myPerUserAvId];
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error trying to get playerAvatarInfo! msg:" + e.message);
         }
         return null;
      }
      
      public function get myUserName() : String
      {
         return this._myUserName;
      }
      
      public function set myUserName(param1:String) : void
      {
         this._myUserName = param1;
      }
      
      public function get playerUserInfo() : UserInfo
      {
         return this.getUserInfoByUserName(this.myUserName);
      }
      
      public function get userVarCache() : UserVarCache
      {
         return this._myUserVarCache;
      }
      
      public function get userNameModerated() : String
      {
         if(gMainFrame.clientInfo.userNameModerated > 0)
         {
            return this._myUserName;
         }
         return LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
      }
      
      public function setAvatarDefs(param1:Object) : void
      {
         this._avatarDefs = param1;
         this.avtDefsCached = true;
      }
      
      public function setCustomAvatarDefs(param1:Object) : void
      {
         this._customAvatarDefs = param1;
      }
      
      public function getAvatarColorLayer1InfoByAvType(param1:uint) : uint
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].colorLayer1;
         }
         return 0;
      }
      
      public function getAvatarColorLayer2InfoByAvType(param1:uint) : uint
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].colorLayer2;
         }
         return 0;
      }
      
      public function getAvatarColorLayer3InfoByAvType(param1:uint) : uint
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].colorLayer3;
         }
         return 0;
      }
      
      public function getAvatarDefEyesInfoByAvType(param1:int) : uint
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].defEyes;
         }
         return 0;
      }
      
      public function getAvatarMemberInfoByAvType(param1:int) : Boolean
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].isMemOnly;
         }
         return false;
      }
      
      public function getAvatarEnviroTypeFlagByAvType(param1:int) : int
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].enviroTypeFlag;
         }
         return 0;
      }
      
      public function getAllCustomAvatarDefsByAvType(param1:int) : Array
      {
         var _loc3_:Object = null;
         var _loc2_:Array = [];
         for each(_loc3_ in this._customAvatarDefs)
         {
            if(_loc3_.avatarRefId == param1)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc2_;
      }
      
      public function getAvatarDefByAvType(param1:int, param2:Boolean) : Object
      {
         if(param2)
         {
            return this._customAvatarDefs[param1];
         }
         return this._avatarDefs[param1];
      }
      
      public function getAvatarDefByAvatar(param1:Avatar) : Object
      {
         if(param1)
         {
            if(param1.customAvId != -1)
            {
               return this._customAvatarDefs[param1.customAvId];
            }
            return this._avatarDefs[param1.avTypeId];
         }
         return null;
      }
      
      public function set denRoomDefs(param1:Object) : void
      {
         this._denRoomDefs = param1;
      }
      
      public function get denRoomDefs() : Object
      {
         return this._denRoomDefs;
      }
      
      public function getDenRoomDefByDefId(param1:int) : Object
      {
         return this._denRoomDefs[param1];
      }
      
      public function set genericListDefs(param1:Object) : void
      {
         this._genericListDefsInfo = param1;
      }
      
      public function getGenericListDefByDefId(param1:int) : Object
      {
         return this._genericListDefsInfo[param1];
      }
      
      public function getMyTradeList() : Array
      {
         return this._myTradeList;
      }
      
      public function set myTradeList(param1:Array) : void
      {
         this._myTradeList = param1;
      }
      
      public function removeFromMyTradeList(param1:int) : void
      {
         this._myTradeList.splice(param1,1);
      }
      
      public function set myPetsInDen(param1:Array) : void
      {
         this._myPetsInDen = param1;
      }
      
      public function get myPetsInDen() : Array
      {
         return this._myPetsInDen;
      }
      
      public function isPendingFlagSet(param1:int) : Boolean
      {
         return (this.pendingFlags & 1 << param1) != 0;
      }
   }
}

