package avatar
{
   import localization.LocalizationManager;
   
   public class UserInfo
   {
      
      public var userName:String;
      
      public var currPerUserAvId:int;
      
      public var avList:Object;
      
      public var denItemsFull:Array;
      
      public var denItemsPartial:Array;
      
      public var accountType:int;
      
      public var nameBarData:int;
      
      public var isGuide:Boolean;
      
      public var userNameModeratedFlag:int;
      
      private var _allItems:Array;
      
      private var _achievements:Array;
      
      private var _timeStampSinceLastRequest:Number;
      
      public function UserInfo()
      {
         super();
      }
      
      public function init(initUserName:String, initAvList:Array = null, initCurrPerUserAvId:int = -1, initAccountType:int = 1, initUserNameModerated:int = 0) : void
      {
         this.userName = initUserName;
         this._timeStampSinceLastRequest = 0;
         this._allItems = [];
         if(Boolean(initAvList))
         {
            this.avList = initAvList;
         }
         else
         {
            this.avList = {};
         }
         if(initCurrPerUserAvId > 0)
         {
            this.currPerUserAvId = initCurrPerUserAvId;
         }
         this.accountType = initAccountType;
         this.userNameModeratedFlag = initUserNameModerated;
      }
      
      public function addAvatarToList(avatarInfo:AvatarInfo) : void
      {
         this.avList[avatarInfo.perUserAvId] = avatarInfo;
      }
      
      public function getAvatarInfoByPerUserAvId(perUserAvId:int) : AvatarInfo
      {
         if(perUserAvId == -1)
         {
            return this.avList[this.currPerUserAvId];
         }
         if(Boolean(this.avList[perUserAvId]))
         {
            return this.avList[perUserAvId];
         }
         return null;
      }
      
      public function addAchievementsTolist(achievs:Array) : void
      {
         if(!this._achievements)
         {
            this._achievements = [];
         }
         var j:int = int(this._achievements.length);
         for(var i:int = 0; i < achievs.length; i++)
         {
            this._achievements[j++] = achievs[i];
         }
      }
      
      public function set fullItemList(a:Array) : void
      {
         this._allItems = a;
      }
      
      public function get fullItemList() : Array
      {
         return this._allItems;
      }
      
      public function getFullItemList(withBodyMods:Boolean) : Array
      {
         var items:Array = [];
         for(var i:int = 0; i < this._allItems.length; i++)
         {
            if(withBodyMods)
            {
               items.push(this._allItems[i]);
            }
            else if(this._allItems[i].invIdx >= 0)
            {
               items.push(this._allItems[i]);
            }
         }
         return items;
      }
      
      public function getPartialItemList(avType:int, withBodyMods:Boolean) : Array
      {
         var items:Array = [];
         for(var i:int = 0; i < this._allItems.length; i++)
         {
            if(this._allItems[i].invIdx < 0 && withBodyMods || Utility.isSameEnviroType(gMainFrame.userInfo.getAvatarEnviroTypeFlagByAvType(avType),this._allItems[i].enviroType))
            {
               if(withBodyMods)
               {
                  items.push(this._allItems[i]);
               }
               else if(this._allItems[i].invIdx >= 0)
               {
                  items.push(this._allItems[i]);
               }
            }
         }
         return items;
      }
      
      public function allItemsInUseOff(perUserAvId:int) : void
      {
         for(var i:int = 0; i < this._allItems.length; i++)
         {
            this._allItems[i].setInUse(perUserAvId,false);
         }
      }
      
      public function get achievements() : Array
      {
         return this._achievements;
      }
      
      public function get isMember() : Boolean
      {
         return Utility.isMember(this.accountType);
      }
      
      public function resetAchievements() : void
      {
         this._achievements = [];
      }
      
      public function getTimeOfLastAchievementRequest() : Number
      {
         return this._timeStampSinceLastRequest;
      }
      
      public function setTimeOfLastAchievementRequest(time:Number) : void
      {
         this._timeStampSinceLastRequest = time;
      }
      
      public function getModeratedUserName() : String
      {
         if(this.userNameModeratedFlag > 0)
         {
            return this.userName;
         }
         return LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
      }
      
      public function getAccountType() : int
      {
         return this.accountType;
      }
   }
}

