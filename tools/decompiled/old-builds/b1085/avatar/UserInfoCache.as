package avatar
{
   import com.sbi.debug.DebugUtility;
   import flash.utils.Dictionary;
   import localization.LocalizationManager;
   
   public class UserInfoCache
   {
      
      public var myUserName:String;
      
      public var myBuddyCount:int;
      
      public var isMember:Boolean;
      
      public var isModerator:Boolean;
      
      public var isGuide:Boolean;
      
      public var isSilenced:Boolean;
      
      public var isMyDenPrivate:Boolean;
      
      public var sgChatType:int;
      
      public var firstFiveMinutes:int;
      
      public var pendingFlags:Number;
      
      public var activeDenRoomInvId:int;
      
      public var numLogins:int;
      
      public var worldMapRoomName:String;
      
      public var avtDefsCached:Boolean;
      
      private var _userInfo:Object;
      
      private var _dbAvIdToUserName:Dictionary;
      
      private var _myDbAvId:int;
      
      private var _myUserVarCache:UserVarCache;
      
      private var _avatarDefs:Object;
      
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
         this._myDbAvId = -1;
         this.myUserName = "";
         this.avtDefsCached = false;
         this._myUserVarCache = new UserVarCache();
         this._myUserVarCache.init();
         this._dbAvIdToUserName = new Dictionary(true);
         this._avatarDefs = new Object();
         this._genericListDefsInfo = new Object();
         this._myTradeList = [];
      }
      
      public function destroy() : void
      {
         this._userInfo = null;
         this._avatarDefs = null;
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
         var _loc5_:String = null;
         var _loc6_:UserInfo = null;
         var _loc7_:AvatarInfo = null;
         if(Boolean(param1) && param1 != "")
         {
            _loc3_ = this._userInfo[param1] = param2;
            for each(_loc4_ in _loc3_.avList)
            {
               _loc5_ = this._dbAvIdToUserName[_loc4_.dbAvId];
               if((Boolean(_loc5_)) && _loc5_ != param1)
               {
                  _loc6_ = this._userInfo[_loc5_];
                  if(_loc6_)
                  {
                     for each(_loc7_ in _loc6_.avList)
                     {
                        delete this._dbAvIdToUserName[_loc7_.dbAvId];
                     }
                     delete this._userInfo[_loc5_];
                     break;
                  }
               }
            }
            for each(_loc4_ in _loc3_.avList)
            {
               this._dbAvIdToUserName[_loc4_.dbAvId] = param1;
            }
         }
      }
      
      public function getAvatarInfoByDbAvId(param1:int) : AvatarInfo
      {
         var _loc2_:UserInfo = null;
         var _loc3_:AvatarInfo = null;
         loop0:
         for each(_loc2_ in this._userInfo)
         {
            var _loc6_:int = 0;
            var _loc7_:* = _loc2_.avList;
            do
            {
               for each(_loc3_ in _loc7_)
               {
               }
               continue loop0;
            }
            while(_loc3_.dbAvId != param1);
            return _loc3_;
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
               this._dbAvIdToUserName[_loc5_.dbAvId] = param2;
            }
            delete this._userInfo[param1];
         }
      }
      
      public function getAvatarInfoByUserName(param1:String) : AvatarInfo
      {
         if(this._userInfo.hasOwnProperty(param1))
         {
            return this._userInfo[param1].avList[this._userInfo[param1].currDbAvId];
         }
         return null;
      }
      
      public function getAvatarInfoByUserNameThenDbAvId(param1:String, param2:int) : AvatarInfo
      {
         var _loc3_:Object = null;
         if(this._userInfo.hasOwnProperty(param1))
         {
            _loc3_ = this._userInfo[param1];
            return this._userInfo[param1].avList[param2];
         }
         return null;
      }
      
      public function get myDbAvId() : int
      {
         return this._myDbAvId;
      }
      
      public function setCurrAvDbId(param1:String, param2:int) : void
      {
         if(this._userInfo.hasOwnProperty(param1))
         {
            this._userInfo[param1].currDbAvId = param2;
         }
      }
      
      public function set myDbAvId(param1:int) : void
      {
         this._myDbAvId = param1;
         if(this._userInfo.hasOwnProperty(this.myUserName) && Boolean(this._userInfo[this.myUserName]))
         {
            UserInfo(this._userInfo[this.myUserName]).currDbAvId = param1;
         }
      }
      
      public function setAvatarInfoByDbAvId(param1:int, param2:AvatarInfo, param3:Boolean = false) : void
      {
         var _loc4_:String = param2.userName;
         if(!this._userInfo.hasOwnProperty(_loc4_))
         {
            throw new Error("Invalid setAvatarInfo! Needs userName!");
         }
         this._userInfo[_loc4_].avList[param1] = param2;
         if(param3)
         {
            this._userInfo[_loc4_].currDbAvId = param1;
            this._dbAvIdToUserName[param1] = _loc4_;
         }
      }
      
      public function setAccountTypeByUserName(param1:String, param2:int) : void
      {
         if(this._userInfo.hasOwnProperty(param1))
         {
            this._userInfo[param1].accountType = param2;
         }
      }
      
      public function set playerAvatarInfo(param1:AvatarInfo) : void
      {
         this._myDbAvId = param1.dbAvId;
         this.myUserName = param1.userName;
         var _loc2_:UserInfo = UserInfo(this._userInfo[this.myUserName]);
         if(_loc2_)
         {
            _loc2_.avList[this._myDbAvId] = param1;
            _loc2_.currDbAvId = this._myDbAvId;
         }
      }
      
      public function get playerAvatarInfo() : AvatarInfo
      {
         try
         {
            return this._userInfo[this.myUserName].avList[this._myDbAvId];
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error trying to get playerAvatarInfo! msg:" + e.message);
         }
         return null;
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
            return this.myUserName;
         }
         return LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
      }
      
      public function setAvatarDefs(param1:Object) : void
      {
         this._avatarDefs = param1;
         this.avtDefsCached = true;
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
      
      public function getAvatarDefPatternInfoByAvType(param1:int) : uint
      {
         if(this._avatarDefs[param1])
         {
            return this._avatarDefs[param1].defPattern;
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
      
      public function getAvatarDefByAvType(param1:int) : Object
      {
         return this._avatarDefs[param1];
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

