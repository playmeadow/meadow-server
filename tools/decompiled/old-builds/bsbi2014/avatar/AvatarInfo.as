package avatar
{
   import localization.LocalizationManager;
   import pet.PetManager;
   
   public class AvatarInfo
   {
      
      public var perUserAvId:int;
      
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
      
      private var _currPet:Object;
      
      private var _avName:String;
      
      public function AvatarInfo()
      {
         super();
      }
      
      public function init(initPerUserAvatarId:int = -1, initAvName:String = "", initUserName:String = "", initType:int = -1, initColors:Array = null, initRoomType:int = 0, initCurrPet:Object = null, initLandPetInvId:int = 0, initOceanPetInvId:int = 0, initQuestXp:int = 0, initQuestLevel:int = 0, initQuestXPPercentage:int = 0, initHealthBase:int = 0, initAttackBase:int = 0, initAttackMax:int = 0, initDefenseMax:int = 0, initDefenseBase:int = 0, initQuestHealthPercentage:int = 100, initQuestTorchStatus:Boolean = false) : void
      {
         this.isDead = false;
         this.perUserAvId = initPerUserAvatarId;
         this._avName = initAvName;
         this.userName = initUserName;
         this.type = initType;
         this.colors = initColors == null ? [286331153,286331153,286331153] : initColors;
         this.currEnviroType = initRoomType;
         this.landPetInvId = initLandPetInvId;
         this.oceanPetInvId = initOceanPetInvId;
         this.questXp = initQuestXp;
         this.questLevel = initQuestLevel;
         this.questXPPercentage = initQuestXPPercentage;
         this.questHealthPercentage = initQuestHealthPercentage;
         this.questTorchStatus = initQuestTorchStatus;
         this.attackBase = initAttackBase;
         this.attackMax = initAttackMax;
         this.defenseBase = initDefenseBase;
         this.defenseMax = initDefenseMax;
         this.healthBase = initHealthBase;
         this._currPet = initCurrPet;
      }
      
      public function get currPet() : Object
      {
         if(this.userName == gMainFrame.userInfo.myUserName)
         {
            return PetManager.myActivePet;
         }
         return this._currPet;
      }
      
      public function set currPet(o:Object) : void
      {
         if(this.userName != gMainFrame.userInfo.myUserName)
         {
            this._currPet = o;
         }
      }
      
      public function getItems(withBodyMods:Boolean = false) : Array
      {
         var userInf:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(Boolean(userInf))
         {
            return userInf.getPartialItemList(this.type,withBodyMods);
         }
         return null;
      }
      
      public function getFullItems(withBodyMods:Boolean = false) : Array
      {
         var userInf:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(Boolean(userInf))
         {
            return userInf.getFullItemList(withBodyMods);
         }
         return null;
      }
      
      public function set fullItemList(list:Array) : void
      {
         var userInf:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(Boolean(userInf))
         {
            userInf.fullItemList = list;
         }
      }
      
      public function get denItems() : Array
      {
         var userInf:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(Boolean(userInf))
         {
            return userInf.denItemsFull;
         }
         return null;
      }
      
      public function get achievements() : Array
      {
         var userInf:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(Boolean(userInf))
         {
            return userInf.achievements;
         }
         return null;
      }
      
      public function set denItems(items:Array) : void
      {
         var userInfo:UserInfo = null;
         if(Boolean(items))
         {
            userInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
            if(Boolean(userInfo))
            {
               userInfo.denItemsFull = items;
            }
         }
      }
      
      public function get accountType() : int
      {
         var userInfo:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(this.userName);
         if(Boolean(userInfo))
         {
            return userInfo.accountType;
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
      
      public function set avName(name:String) : void
      {
         this._avName = name;
      }
   }
}

