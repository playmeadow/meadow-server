package avatar
{
   import achievement.Achievement;
   import localization.LocalizationManager;
   
   public class UserInfo
   {
      
      public var currPerUserAvId:int;
      
      public var avList:Object;
      
      public var denItemsFull:Array;
      
      public var denItemsPartial:Array;
      
      public var accountType:int;
      
      public var nameBarData:int;
      
      public var isGuide:Boolean;
      
      public var userNameModeratedFlag:int;
      
      public var _userName:String;
      
      private var _allItems:Array;
      
      private var _achievements:Array;
      
      private var _achievementsIndexed:Array;
      
      private var _timeStampSinceLastRequest:Number;
      
      private var _timeLeftHostingCustomParty:int;
      
      private var _timeWhenHostingEnds:Number;
      
      private var _uuid:String;
      
      public function UserInfo()
      {
         super();
      }
      
      public function init(param1:String, param2:String, param3:Array = null, param4:int = -1, param5:int = 1, param6:int = 0, param7:int = -1) : void
      {
         _userName = param1;
         _uuid = param2;
         _timeStampSinceLastRequest = 0;
         _allItems = [];
         if(param3)
         {
            avList = param3;
         }
         else
         {
            avList = {};
         }
         if(param4 > 0)
         {
            currPerUserAvId = param4;
         }
         accountType = param5;
         userNameModeratedFlag = param6;
         _timeLeftHostingCustomParty = param7;
      }
      
      public function addAvatarToList(param1:AvatarInfo) : void
      {
         avList[param1.perUserAvId] = param1;
      }
      
      public function getAvatarInfoByPerUserAvId(param1:int) : AvatarInfo
      {
         if(param1 == -1)
         {
            return avList[currPerUserAvId];
         }
         if(avList[param1])
         {
            return avList[param1];
         }
         return null;
      }
      
      public function addAchievementsTolist(param1:Array) : void
      {
         var _loc5_:Achievement = null;
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         if(!_achievements)
         {
            _achievements = [];
         }
         if(!_achievementsIndexed)
         {
            _achievementsIndexed = [];
         }
         var _loc3_:int = int(_achievements.length);
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1[_loc4_] as Achievement;
            _achievements[_loc3_++] = _loc5_;
            _loc2_ = _achievementsIndexed[_loc5_.type];
            if(!_loc2_)
            {
               _loc2_ = [];
               _achievementsIndexed[_loc5_.type] = _loc2_;
            }
            _loc2_.push(_loc5_);
            _loc4_++;
         }
      }
      
      public function set fullItemList(param1:Array) : void
      {
         _allItems = param1;
      }
      
      public function get fullItemList() : Array
      {
         return _allItems;
      }
      
      public function getFullItemList(param1:Boolean) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < _allItems.length)
         {
            if(param1)
            {
               _loc2_.push(_allItems[_loc3_]);
            }
            else if(_allItems[_loc3_].invIdx >= 0)
            {
               _loc2_.push(_allItems[_loc3_]);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getPartialItemList(param1:int, param2:Boolean) : Array
      {
         var _loc4_:int = 0;
         var _loc3_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < _allItems.length)
         {
            if(_allItems[_loc4_].invIdx < 0 && param2 || Utility.isSameEnviroType(gMainFrame.userInfo.getAvatarEnviroTypeFlagByAvType(param1),_allItems[_loc4_].enviroType))
            {
               if(param2)
               {
                  _loc3_.push(_allItems[_loc4_]);
               }
               else if(_allItems[_loc4_].invIdx >= 0)
               {
                  _loc3_.push(_allItems[_loc4_]);
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function allItemsInUseOff(param1:int) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _allItems.length)
         {
            _allItems[_loc2_].setInUse(param1,false);
            _loc2_++;
         }
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function set userName(param1:String) : void
      {
         _userName = param1;
      }
      
      public function get achievements() : Array
      {
         return _achievements;
      }
      
      public function get achievementsIndexed() : Array
      {
         return _achievementsIndexed;
      }
      
      public function get isMember() : Boolean
      {
         return Utility.isMember(accountType);
      }
      
      public function resetAchievements() : void
      {
         _achievements = [];
         _achievementsIndexed = [];
      }
      
      public function getTimeOfLastAchievementRequest() : Number
      {
         return _timeStampSinceLastRequest;
      }
      
      public function setTimeOfLastAchievementRequest(param1:Number) : void
      {
         _timeStampSinceLastRequest = param1;
      }
      
      public function getModeratedUserName() : String
      {
         if(userNameModeratedFlag > 0)
         {
            return userName;
         }
         return LocalizationManager.translateIdOnly(11098);
      }
      
      public function getAccountType() : int
      {
         return accountType;
      }
      
      public function set timeLeftHostingCustomParty(param1:int) : void
      {
         _timeLeftHostingCustomParty = param1;
         _timeWhenHostingEnds = Math.floor(new Date().time / 1000) + param1;
      }
      
      public function get isStillHosting() : Boolean
      {
         if(isNaN(_timeWhenHostingEnds))
         {
            return false;
         }
         return new Date().time / 1000 < _timeWhenHostingEnds;
      }
      
      public function set uuid(param1:String) : void
      {
         _uuid = param1;
      }
      
      public function get uuid() : String
      {
         return _uuid;
      }
   }
}

