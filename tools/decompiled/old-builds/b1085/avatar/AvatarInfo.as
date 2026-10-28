package avatar
{
   import localization.LocalizationManager;
   
   public class AvatarInfo
   {
      
      public var dbAvId:int;
      
      public var userName:String;
      
      public var type:int;
      
      public var colors:Array;
      
      public var currEnviroType:int;
      
      public var landPetInvId:int;
      
      public var oceanPetInvId:int;
      
      public var questXp:int;
      
      public var questLevel:int;
      
      public var questXPPercentage:int;
      
      public var questHealthPercentage:int;
      
      public var questTorchStatus:Boolean;
      
      public var isDead:Boolean;
      
      public var healthBase:int;
      
      public var attackBase:int;
      
      public var attackMax:int;
      
      public var defenseBase:int;
      
      public var defenseMax:int;
      
      private var _avName:String;
      
      public function AvatarInfo()
      {
         super();
      }
      
      public function init(param1:int = -1, param2:String = "", param3:String = "", param4:int = -1, param5:Array = null, param6:int = 0, param7:int = 0, param8:int = 0, param9:int = 0, param10:int = 0, param11:int = 0, param12:int = 0, param13:int = 0, param14:int = 0, param15:int = 0, param16:int = 0, param17:int = 100, param18:Boolean = false) : void
      {
         this.isDead = false;
         this.dbAvId = param1;
         this._avName = param2;
         this.userName = param3;
         this.type = param4;
         this.colors = param5 == null ? [286331153,286331153,286331153] : param5;
         this.currEnviroType = param6;
         this.landPetInvId = param7;
         this.oceanPetInvId = param8;
         this.questXp = param9;
         this.questLevel = param10;
         this.questXPPercentage = param11;
         this.questHealthPercentage = param17;
         this.questTorchStatus = param18;
         this.attackBase = param13;
         this.attackMax = param14;
         this.defenseBase = param16;
         this.defenseMax = param15;
         this.healthBase = param12;
      }
      
      public function getItems(param1:Boolean = false) : Array
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(_loc2_)
         {
            return _loc2_.getPartialItemList(this.type,param1);
         }
         return null;
      }
      
      public function getFullItems(param1:Boolean = false) : Array
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(_loc2_)
         {
            return _loc2_.getFullItemList(param1);
         }
         return null;
      }
      
      public function set fullItemList(param1:Array) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(_loc2_)
         {
            _loc2_.fullItemList = param1;
         }
      }
      
      public function get denItems() : Array
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(_loc1_)
         {
            return _loc1_.denItemsFull;
         }
         return null;
      }
      
      public function get achievements() : Array
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(_loc1_)
         {
            return _loc1_.achievements;
         }
         return null;
      }
      
      public function set denItems(param1:Array) : void
      {
         var _loc2_:UserInfo = null;
         if(param1)
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
            if(_loc2_)
            {
               _loc2_.denItemsFull = param1;
            }
         }
      }
      
      public function get accountType() : int
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(_loc1_)
         {
            return _loc1_.accountType;
         }
         return Utility.NON_MEMBER;
      }
      
      public function get isMember() : Boolean
      {
         return Utility.isMember(this.accountType);
      }
      
      public function get avName() : String
      {
         return LocalizationManager.translateAvatarName(this._avName);
      }
      
      public function set avName(param1:String) : void
      {
         this._avName = param1;
      }
   }
}

