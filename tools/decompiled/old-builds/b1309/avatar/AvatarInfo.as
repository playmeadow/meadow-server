package avatar
{
   import collection.AccItemCollection;
   import collection.DenItemCollection;
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
         isDead = false;
         perUserAvId = param1;
         _avName = param2;
         _userName = param3;
         uuid = param4;
         type = param5;
         colors = param6 == null ? [286331153,286331153,286331153] : param6;
         currEnviroType = param7;
         landPetInvId = param10;
         oceanPetInvId = param11;
         questXp = param12;
         questLevel = param13;
         questXPPercentage = param14;
         questHealthPercentage = param20;
         questTorchStatus = param21;
         attackBase = param16;
         attackMax = param17;
         defenseBase = param19;
         defenseMax = param18;
         healthBase = param15;
         _currPet = param8;
         customAvId = param9;
      }
      
      public function get currPet() : Object
      {
         if(_userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
         {
            return PetManager.myActivePet;
         }
         return _currPet;
      }
      
      public function set currPet(param1:Object) : void
      {
         if(_userName.toLowerCase() != gMainFrame.userInfo.myUserName.toLowerCase())
         {
            _currPet = param1;
         }
      }
      
      public function getItems(param1:Boolean = false) : AccItemCollection
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc2_)
         {
            return _loc2_.getPartialItemList(type,param1);
         }
         return null;
      }
      
      public function getFullItems(param1:Boolean = false) : AccItemCollection
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc2_)
         {
            return _loc2_.getFullItemList(param1);
         }
         return null;
      }
      
      public function set fullItemList(param1:AccItemCollection) : void
      {
         var _loc2_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc2_)
         {
            _loc2_.fullItemList = param1;
         }
      }
      
      public function get denItems() : DenItemCollection
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc1_)
         {
            return _loc1_.denItemsFull;
         }
         return null;
      }
      
      public function get achievements() : Array
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc1_)
         {
            return _loc1_.achievements;
         }
         return null;
      }
      
      public function set denItems(param1:DenItemCollection) : void
      {
         var _loc2_:UserInfo = null;
         if(param1)
         {
            _loc2_ = gMainFrame.userInfo.getUserInfoByUserName(_userName);
            if(_loc2_)
            {
               _loc2_.denItemsFull = param1;
            }
         }
      }
      
      public function get accountType() : int
      {
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_userName);
         if(_loc1_)
         {
            return _loc1_.accountType;
         }
         return 1;
      }
      
      public function get isMember() : Boolean
      {
         return Utility.isMember(accountType);
      }
      
      public function get avName() : String
      {
         return LocalizationManager.translateAvatarName(_avName);
      }
      
      public function set avName(param1:String) : void
      {
         _avName = param1;
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function set userName(param1:String) : void
      {
         _userName = param1;
      }
   }
}

