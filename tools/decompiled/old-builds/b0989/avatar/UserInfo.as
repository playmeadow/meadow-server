package avatar
{
   public class UserInfo
   {
      
      public var userName:String;
      
      public var currDbAvId:int;
      
      public var avList:Object;
      
      public var denItemsFull:Array;
      
      public var denItemsPartial:Array;
      
      public var accountType:int;
      
      public var nameBarData:int;
      
      public var isGuide:Boolean;
      
      private var _allItems:Array;
      
      private var _achievements:Array;
      
      private var _timeStampSinceLastRequest:Number;
      
      public function UserInfo()
      {
         super();
      }
      
      public function init(param1:String, param2:Array = null, param3:int = -1, param4:int = 1) : void
      {
         this.userName = param1;
         this._timeStampSinceLastRequest = 0;
         this._allItems = [];
         if(param2)
         {
            this.avList = param2;
         }
         else
         {
            this.avList = {};
         }
         if(param3 > 0)
         {
            this.currDbAvId = param3;
         }
         this.accountType = param4;
      }
      
      public function addAvatarToList(param1:AvatarInfo) : void
      {
         this.avList[param1.dbAvId] = param1;
      }
      
      public function getAvatarInfoByDbAvId(param1:int) : AvatarInfo
      {
         if(param1 == -1)
         {
            return this.avList[this.currDbAvId];
         }
         if(this.avList[param1])
         {
            return this.avList[param1];
         }
         return null;
      }
      
      public function addAchievementsTolist(param1:Array) : void
      {
         if(!this._achievements)
         {
            this._achievements = [];
         }
         var _loc2_:* = int(this._achievements.length);
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            var _loc4_:Number;
            this._achievements[_loc4_ = _loc2_++] = param1[_loc3_];
            _loc3_++;
         }
      }
      
      public function set fullItemList(param1:Array) : void
      {
         this._allItems = param1;
      }
      
      public function get fullItemList() : Array
      {
         return this._allItems;
      }
      
      public function getFullItemList(param1:Boolean) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < this._allItems.length)
         {
            if(param1)
            {
               _loc2_.push(this._allItems[_loc3_]);
            }
            else if(this._allItems[_loc3_].invIdx >= 0)
            {
               _loc2_.push(this._allItems[_loc3_]);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function getPartialItemList(param1:int, param2:Boolean) : Array
      {
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         while(_loc4_ < this._allItems.length)
         {
            if(this._allItems[_loc4_].invIdx < 0 && param2 || Utility.isSameEnviroType(gMainFrame.userInfo.getAvatarEnviroTypeFlagByAvType(param1),this._allItems[_loc4_].enviroType))
            {
               if(param2)
               {
                  _loc3_.push(this._allItems[_loc4_]);
               }
               else if(this._allItems[_loc4_].invIdx >= 0)
               {
                  _loc3_.push(this._allItems[_loc4_]);
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function allItemsInUseOff(param1:int) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._allItems.length)
         {
            this._allItems[_loc2_].setInUse(param1,false);
            _loc2_++;
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
      
      public function setTimeOfLastAchievementRequest(param1:Number) : void
      {
         this._timeStampSinceLastRequest = param1;
      }
   }
}

