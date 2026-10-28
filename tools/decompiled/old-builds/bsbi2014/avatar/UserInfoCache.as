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
      
      public var sgChatTypeNonDegraded:int;
      
      public var firstFiveMinutes:int;
      
      public var pendingFlags:Number;
      
      public var activeDenRoomInvId:int;
      
      public var numLogins:int;
      
      public var worldMapRoomName:String;
      
      public var avtDefsCached:Boolean;
      
      private var _userInfo:Object;
      
      private var _perUserAvIdToUserName:Dictionary;
      
      private var _myPerUserAvId:int;
      
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
         this._myPerUserAvId = -1;
         this.myUserName = "";
         this.avtDefsCached = false;
         this._myUserVarCache = new UserVarCache();
         this._myUserVarCache.init();
         this._perUserAvIdToUserName = new Dictionary(true);
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
      
      public function getUserInfoByUserName(userName:String) : UserInfo
      {
         return this._userInfo[userName];
      }
      
      public function setUserInfoByUserName(userNameParam:String, userInfoParam:UserInfo) : void
      {
         var info:UserInfo = null;
         var avInfo:AvatarInfo = null;
         if(Boolean(userNameParam) && userNameParam != "")
         {
            info = this._userInfo[userNameParam] = userInfoParam;
            for each(avInfo in info.avList)
            {
               this._perUserAvIdToUserName[avInfo.perUserAvId] = userNameParam;
            }
         }
      }
      
      public function getAvatarInfoByUsernamePerUserAvId(userName:String, perUserAvId:int) : AvatarInfo
      {
         var user:UserInfo = null;
         var avInfo:AvatarInfo = null;
         loop0:
         for each(user in this._userInfo)
         {
            var _loc7_:int = 0;
            var _loc8_:* = user.avList;
            do
            {
               for each(avInfo in _loc8_)
               {
               }
               continue loop0;
            }
            while(!(avInfo.userName == userName && avInfo.perUserAvId == perUserAvId));
            return avInfo;
         }
         return null;
      }
      
      public function changeUserName(oldUserName:String, newUserName:String, userNameModeratedFlag:int) : void
      {
         var info:UserInfo = null;
         var avInfo:AvatarInfo = null;
         if(this._userInfo.hasOwnProperty(oldUserName))
         {
            info = this._userInfo[oldUserName];
            this._userInfo[newUserName] = info;
            this._userInfo[newUserName].userName = newUserName;
            this._userInfo[newUserName].userNameModeratedFlag = userNameModeratedFlag;
            for each(avInfo in info.avList)
            {
               avInfo.userName = newUserName;
               this._perUserAvIdToUserName[avInfo.perUserAvId] = newUserName;
            }
            delete this._userInfo[oldUserName];
         }
      }
      
      public function getAvatarInfoByUserName(userName:String) : AvatarInfo
      {
         if(this._userInfo.hasOwnProperty(userName))
         {
            return this._userInfo[userName].avList[this._userInfo[userName].currPerUserAvId];
         }
         return null;
      }
      
      public function getAvatarInfoByUserNameThenPerUserAvId(userName:String, perUserAvId:int) : AvatarInfo
      {
         var test:Object = null;
         if(this._userInfo.hasOwnProperty(userName))
         {
            test = this._userInfo[userName];
            return this._userInfo[userName].avList[perUserAvId];
         }
         return null;
      }
      
      public function get myPerUserAvId() : int
      {
         return this._myPerUserAvId;
      }
      
      public function setCurrAvDbId(userName:String, currAvDbId:int) : void
      {
         if(this._userInfo.hasOwnProperty(userName))
         {
            this._userInfo[userName].currPerUserAvId = currAvDbId;
         }
      }
      
      public function set myPerUserAvId(setperUserAvId:int) : void
      {
         this._myPerUserAvId = setperUserAvId;
         if(this._userInfo.hasOwnProperty(this.myUserName) && Boolean(this._userInfo[this.myUserName]))
         {
            UserInfo(this._userInfo[this.myUserName]).currPerUserAvId = setperUserAvId;
         }
      }
      
      public function setAvatarInfoByUsernamePerUserAvId(perUserAvId:int, setAvatarInfo:AvatarInfo, updateCurrperUserAvId:Boolean = false) : void
      {
         var setAvUsername:String = setAvatarInfo.userName;
         if(!this._userInfo.hasOwnProperty(setAvUsername))
         {
            throw new Error("Invalid setAvatarInfo! Needs userName!");
         }
         this._userInfo[setAvUsername].avList[perUserAvId] = setAvatarInfo;
         if(updateCurrperUserAvId)
         {
            this._userInfo[setAvUsername].currPerUserAvId = perUserAvId;
            this._perUserAvIdToUserName[perUserAvId] = setAvUsername;
         }
      }
      
      public function setAccountTypeByUserName(userName:String, accountType:int) : void
      {
         if(this._userInfo.hasOwnProperty(userName))
         {
            this._userInfo[userName].accountType = accountType;
         }
      }
      
      public function set playerAvatarInfo(setAvInfo:AvatarInfo) : void
      {
         this._myPerUserAvId = setAvInfo.perUserAvId;
         this.myUserName = setAvInfo.userName;
         var myUserInfo:UserInfo = UserInfo(this._userInfo[this.myUserName]);
         if(Boolean(myUserInfo))
         {
            myUserInfo.avList[this._myPerUserAvId] = setAvInfo;
            myUserInfo.currPerUserAvId = this._myPerUserAvId;
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
      
      public function setAvatarDefs(avtDefs:Object) : void
      {
         this._avatarDefs = avtDefs;
         this.avtDefsCached = true;
      }
      
      public function getAvatarColorLayer1InfoByAvType(avType:uint) : uint
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].colorLayer1;
         }
         return 0;
      }
      
      public function getAvatarColorLayer2InfoByAvType(avType:uint) : uint
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].colorLayer2;
         }
         return 0;
      }
      
      public function getAvatarColorLayer3InfoByAvType(avType:uint) : uint
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].colorLayer3;
         }
         return 0;
      }
      
      public function getAvatarDefPatternInfoByAvType(avType:int) : uint
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].defPattern;
         }
         return 0;
      }
      
      public function getAvatarDefEyesInfoByAvType(avType:int) : uint
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].defEyes;
         }
         return 0;
      }
      
      public function getAvatarMemberInfoByAvType(avType:int) : Boolean
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].isMemOnly;
         }
         return false;
      }
      
      public function getAvatarEnviroTypeFlagByAvType(avType:int) : int
      {
         if(Boolean(this._avatarDefs[avType]))
         {
            return this._avatarDefs[avType].enviroTypeFlag;
         }
         return 0;
      }
      
      public function getAvatarDefByAvType(avType:int) : Object
      {
         return this._avatarDefs[avType];
      }
      
      public function set denRoomDefs(o:Object) : void
      {
         this._denRoomDefs = o;
      }
      
      public function get denRoomDefs() : Object
      {
         return this._denRoomDefs;
      }
      
      public function getDenRoomDefByDefId(defId:int) : Object
      {
         return this._denRoomDefs[defId];
      }
      
      public function set genericListDefs(o:Object) : void
      {
         this._genericListDefsInfo = o;
      }
      
      public function getGenericListDefByDefId(defId:int) : Object
      {
         return this._genericListDefsInfo[defId];
      }
      
      public function getMyTradeList() : Array
      {
         return this._myTradeList;
      }
      
      public function set myTradeList(value:Array) : void
      {
         this._myTradeList = value;
      }
      
      public function removeFromMyTradeList(index:int) : void
      {
         this._myTradeList.splice(index,1);
      }
      
      public function set myPetsInDen(value:Array) : void
      {
         this._myPetsInDen = value;
      }
      
      public function get myPetsInDen() : Array
      {
         return this._myPetsInDen;
      }
      
      public function isPendingFlagSet(bitIdx:int) : Boolean
      {
         return (this.pendingFlags & 1 << bitIdx) != 0;
      }
   }
}

