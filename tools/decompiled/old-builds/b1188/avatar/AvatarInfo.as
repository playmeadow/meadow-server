package avatar
{
   import localization.LocalizationManager;
   import pet.PetManager;
   
   public class AvatarInfo
   {
      
      public var perUserAvId:int;
      
      public var uuid:String;
      
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
      
      public var customAvId:int;
      
      private var _userName:String;
      
      private var _currPet:Object;
      
      private var _avName:String;
      
      public function AvatarInfo()
      {
         super();
      }
      
      public function init(param1:int = -1, param2:String = "", param3:String = "", param4:String = "", param5:int = -1, param6:Array = null, param7:int = 0, param8:Object = null, param9:int = -1, param10:int = 0, param11:int = 0, param12:int = 0, param13:int = 0, param14:int = 0, param15:int = 0, param16:int = 0, param17:int = 0, param18:int = 0, param19:int = 0, param20:int = 100, param21:Boolean = false) : void
      {
         this.isDead = false;
         this.perUserAvId = param1;
         this._avName = param2;
         this._userName = param3;
         this.uuid = param4;
         this.type = param5;
         this.colors = param6 == null ? [286331153,286331153,286331153] : param6;
         this.currEnviroType = param7;
         this.landPetInvId = param10;
         this.oceanPetInvId = param11;
         this.questXp = param12;
         this.questLevel = param13;
         this.questXPPercentage = param14;
         this.questHealthPercentage = param20;
         this.questTorchStatus = param21;
         this.attackBase = param16;
         this.attackMax = param17;
         this.defenseBase = param19;
         this.defenseMax = param18;
         this.healthBase = param15;
         this._currPet = param8;
         this.customAvId = param9;
      }
      
      public function get currPet() : Object
      {
         if(this._userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            return PetManager.myActivePet;
         }
         return this._currPet;
      }
      
      public function set currPet(param1:Object) : void
      {
         if(this._userName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            this._currPet = param1;
         }
      }
      
      public function getItems(param1:Boolean = false) : Array
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
         if(_loc2_)
         {
            return _loc2_.getPartialItemList(this.type,param1);
         }
         return null;
      }
      
      public function getFullItems(param1:Boolean = false) : Array
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
         if(_loc2_)
         {
            return _loc2_.getFullItemList(param1);
         }
         return null;
      }
      
      public function set fullItemList(param1:Array) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
         if(_loc2_)
         {
            _loc2_.fullItemList = param1;
         }
      }
      
      public function get denItems() : Array
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
         if(_loc1_)
         {
            return _loc1_.denItemsFull;
         }
         return null;
      }
      
      public function get achievements() : Array
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
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
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
            if(_loc2_)
            {
               _loc2_.denItemsFull = param1;
            }
         }
      }
      
      public function get accountType() : int
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this._userName);
         if(_loc1_)
         {
            return _loc1_.accountType;
         }
         return SbiConstants.NON_MEMBER;
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
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function set userName(param1:String) : void
      {
         this._userName = param1;
      }
   }
}

