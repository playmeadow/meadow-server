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
      
      public var webPlayerWallSettings:int;
      
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
         _userInfo = {};
         _myPerUserAvId = -1;
         _myUserName = "";
         avtDefsCached = false;
         _myUserVarCache = new UserVarCache();
         _myUserVarCache.init();
         _perUserAvIdToUserName = new Dictionary(true);
         _avatarDefs = {};
         _customAvatarDefs = {};
         _genericListDefsInfo = {};
         _myTradeList = [];
      }
      
      public function destroy() : void
      {
         _userInfo = null;
         _avatarDefs = null;
         _customAvatarDefs = null;
         _denRoomDefs = null;
         _genericListDefsInfo = null;
         _myTradeList = null;
      }
      
      public function getUserInfoByUserName(param1:String) : UserInfo
      {
         return _userInfo[param1];
      }
      
      public function setUserInfoByUserName(param1:String, param2:UserInfo) : void
      {
         var _loc4_:UserInfo = null;
         var _loc3_:* = null;
         if(param1 && param1 != "")
         {
            _loc4_ = _userInfo[param1] = param2;
            for each(_loc3_ in _loc4_.avList)
            {
               _perUserAvIdToUserName[_loc3_.perUserAvId] = param1;
            }
         }
      }
      
      public function getAvatarInfoByUsernamePerUserAvId(param1:String, param2:int) : AvatarInfo
      {
         if(param1 != null)
         {
            loop0:
            for each(var _loc4_:UserInfo in _userInfo)
            {
               var _loc6_:int = 0;
               var _loc5_:Object = _loc4_.avList;
               do
               {
                  for each(var _loc3_:AvatarInfo in _loc5_)
                  {
                  }
                  continue loop0;
               }
               while(!(_loc3_.userName.toLowerCase() == param1.toLowerCase() && _loc3_.perUserAvId == param2));
               return _loc3_;
            }
         }
         return null;
      }
      
      public function updateAllAvatarInfoQuestXPIfZeroByUserName(param1:String, param2:int, param3:int) : void
      {
         if(param1 != null)
         {
            for each(var _loc5_:UserInfo in _userInfo)
            {
               for each(var _loc4_:AvatarInfo in _loc5_.avList)
               {
                  if(_loc4_.questLevel == 0)
                  {
                     _loc4_.questXp = param2;
                     _loc4_.questLevel = param3;
                  }
               }
            }
         }
      }
      
      public function changeUserName(param1:String, param2:String, param3:int) : void
      {
         var _loc5_:UserInfo = null;
         if(_userInfo.hasOwnProperty(param1))
         {
            _loc5_ = _userInfo[param1];
            _userInfo[param2] = _loc5_;
            _userInfo[param2].userName = param2;
            _userInfo[param2].userNameModeratedFlag = param3;
            for each(var _loc4_:AvatarInfo in _loc5_.avList)
            {
               _loc4_.userName = param2;
               _perUserAvIdToUserName[_loc4_.perUserAvId] = param2;
            }
            delete _userInfo[param1];
         }
      }
      
      public function getAvatarInfoByUserName(param1:String) : AvatarInfo
      {
         param1 = param1;
         if(_userInfo.hasOwnProperty(param1))
         {
            return _userInfo[param1].avList[_userInfo[param1].currPerUserAvId];
         }
         return null;
      }
      
      public function getAvatarInfoByUserNameThenPerUserAvId(param1:String, param2:int) : AvatarInfo
      {
         var _loc3_:Object = null;
         if(_userInfo.hasOwnProperty(param1))
         {
            _loc3_ = _userInfo[param1];
            return _userInfo[param1].avList[param2];
         }
         return null;
      }
      
      public function get myPerUserAvId() : int
      {
         return _myPerUserAvId;
      }
      
      public function setCurrAvDbId(param1:String, param2:int) : void
      {
         if(_userInfo.hasOwnProperty(param1))
         {
            _userInfo[param1].currPerUserAvId = param2;
         }
      }
      
      public function set myPerUserAvId(param1:int) : void
      {
         _myPerUserAvId = param1;
         if(_userInfo.hasOwnProperty(myUserName) && _userInfo[myUserName])
         {
            UserInfo(_userInfo[myUserName]).currPerUserAvId = param1;
         }
      }
      
      public function setAvatarInfoByUsernamePerUserAvId(param1:int, param2:AvatarInfo, param3:Boolean = false) : void
      {
         var _loc4_:String = param2.userName;
         if(!_userInfo.hasOwnProperty(_loc4_))
         {
            throw new Error("Invalid setAvatarInfo! Needs userName!");
         }
         _userInfo[_loc4_].avList[param1] = param2;
         if(param3)
         {
            _userInfo[_loc4_].currPerUserAvId = param1;
            _perUserAvIdToUserName[param1] = _loc4_;
         }
      }
      
      public function setAccountTypeByUserName(param1:String, param2:int) : void
      {
         param1 = param1.toLowerCase();
         if(_userInfo.hasOwnProperty(param1))
         {
            _userInfo[param1].accountType = param2;
         }
      }
      
      public function set playerAvatarInfo(param1:AvatarInfo) : void
      {
         _myPerUserAvId = param1.perUserAvId;
         myUserName = param1.userName;
         var _loc2_:UserInfo = UserInfo(_userInfo[myUserName]);
         if(_loc2_)
         {
            _loc2_.avList[_myPerUserAvId] = param1;
            _loc2_.currPerUserAvId = _myPerUserAvId;
         }
      }
      
      public function get playerAvatarInfo() : AvatarInfo
      {
         try
         {
            return _userInfo[myUserName].avList[_myPerUserAvId];
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("Error trying to get playerAvatarInfo! msg:" + e.message);
         }
         return null;
      }
      
      public function get myUserName() : String
      {
         return _myUserName;
      }
      
      public function set myUserName(param1:String) : void
      {
         _myUserName = param1;
      }
      
      public function get playerUserInfo() : UserInfo
      {
         return getUserInfoByUserName(myUserName);
      }
      
      public function set playerUserInfo(param1:UserInfo) : void
      {
         setUserInfoByUserName(myUserName,param1);
      }
      
      public function get userVarCache() : UserVarCache
      {
         return _myUserVarCache;
      }
      
      public function get userNameModerated() : String
      {
         if(gMainFrame.clientInfo.userNameModerated > 0)
         {
            return _myUserName;
         }
         return LocalizationManager.translateIdOnly(11098);
      }
      
      public function setAvatarDefs(param1:Object) : void
      {
         _avatarDefs = param1;
         avtDefsCached = true;
      }
      
      public function setCustomAvatarDefs(param1:Object) : void
      {
         _customAvatarDefs = param1;
      }
      
      public function getAvatarColorLayer1InfoByAvType(param1:uint) : uint
      {
         if(_avatarDefs[param1])
         {
            return _avatarDefs[param1].colorLayer1;
         }
         return 0;
      }
      
      public function getAvatarColorLayer2InfoByAvType(param1:uint) : uint
      {
         if(_avatarDefs[param1])
         {
            return _avatarDefs[param1].colorLayer2;
         }
         return 0;
      }
      
      public function getAvatarColorLayer3InfoByAvType(param1:uint) : uint
      {
         if(_avatarDefs[param1])
         {
            return _avatarDefs[param1].colorLayer3;
         }
         return 0;
      }
      
      public function getAvatarDefEyesInfoByAvType(param1:int) : uint
      {
         if(_avatarDefs[param1])
         {
            return _avatarDefs[param1].defEyes;
         }
         return 0;
      }
      
      public function getAvatarMemberInfoByAvType(param1:int) : Boolean
      {
         if(_avatarDefs[param1])
         {
            return _avatarDefs[param1].isMemOnly;
         }
         return false;
      }
      
      public function getAvatarEnviroTypeFlagByAvType(param1:int) : int
      {
         if(_avatarDefs[param1])
         {
            return _avatarDefs[param1].enviroTypeFlag;
         }
         return 0;
      }
      
      public function getAllCustomAvatarDefsByAvType(param1:int) : Array
      {
         var _loc3_:Array = [];
         for each(var _loc2_:Object in _customAvatarDefs)
         {
            if(_loc2_.avatarRefId == param1)
            {
               _loc3_.push(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public function getAvatarDefByAvType(param1:int, param2:Boolean) : Object
      {
         if(param2)
         {
            return _customAvatarDefs[param1];
         }
         return _avatarDefs[param1];
      }
      
      public function getAvatarDefByAvatar(param1:Avatar) : Object
      {
         if(param1)
         {
            if(param1.customAvId != -1)
            {
               return _customAvatarDefs[param1.customAvId];
            }
            return _avatarDefs[param1.avTypeId];
         }
         return null;
      }
      
      public function set denRoomDefs(param1:Object) : void
      {
         _denRoomDefs = param1;
      }
      
      public function get denRoomDefs() : Object
      {
         return _denRoomDefs;
      }
      
      public function getDenRoomDefByDefId(param1:int) : Object
      {
         return _denRoomDefs[param1];
      }
      
      public function set genericListDefs(param1:Object) : void
      {
         _genericListDefsInfo = param1;
      }
      
      public function getGenericListDefByDefId(param1:int) : Object
      {
         return _genericListDefsInfo[param1];
      }
      
      public function getMyTradeList() : Array
      {
         return _myTradeList;
      }
      
      public function set myTradeList(param1:Array) : void
      {
         _myTradeList = param1;
      }
      
      public function removeFromMyTradeList(param1:int) : void
      {
         _myTradeList.splice(param1,1);
      }
      
      public function set myPetsInDen(param1:Array) : void
      {
         _myPetsInDen = param1;
      }
      
      public function get myPetsInDen() : Array
      {
         return _myPetsInDen;
      }
      
      public function isPendingFlagSet(param1:int) : Boolean
      {
         return Utility.bitwiseAnd(pendingFlags,Utility.leftShiftNumbers(param1)) != 0;
      }
   }
}

