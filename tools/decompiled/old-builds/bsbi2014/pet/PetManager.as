package pet
{
   import achievement.AchievementXtCommManager;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import com.sbi.popup.SBOkPopup;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.PartyManager;
   import gui.PetFinder;
   import gui.PetMastery;
   import item.Item;
   import localization.LocalizationManager;
   
   public class PetManager
   {
      
      private static var _petDefs:Object;
      
      private static var _myPetList:Array;
      
      private static var _myActivePetInvId:int;
      
      private static var _petFinderCloseCallback:Function;
      
      private static var _petFinder:PetFinder;
      
      private static var _petMasteryMgr:PetMastery;
      
      public static const TYPE_LAND_LOW:int = 0;
      
      public static const TYPE_LAND_HIGH:int = 1;
      
      public static const TYPE_OCEAN_LOW:int = 2;
      
      public static const TYPE_OCEAN_HIGH:int = 3;
      
      public static const TYPE_AMPHIB_LOW:int = 4;
      
      public static const TYPE_AMPHIB_HIGH:int = 5;
      
      public static const LIMITED_TIME:int = 1;
      
      public static const MASTERY_ACHIV_MIN_COUNT:int = 100;
      
      private static const EVT_ICON_ID:int = 44;
      
      public function PetManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _myPetList = [];
      }
      
      public static function set petDefs(o:Object) : void
      {
         _petDefs = o;
      }
      
      public static function relocalizePetDefs() : void
      {
         var p:Object = null;
         for each(p in _petDefs)
         {
            p.title = LocalizationManager.translateIdOnly(p.titleStrId);
         }
      }
      
      public static function openPetFinder(petName:String = "", closeCallback:Function = null, isFromRedemption:Boolean = false, petData:Array = null) : void
      {
         if(Boolean(_petFinder))
         {
            _petFinder.destroy();
            _petFinder = null;
         }
         _petFinder = new PetFinder();
         if(petName == "")
         {
            _petFinder.init(-1,closeCallback);
         }
         else
         {
            _petFinder.init(petDefIdForName(petName),closeCallback,isFromRedemption,petData);
         }
      }
      
      public static function checkAndOpenMasteryPopup(hasAchieved:Boolean) : void
      {
         if(Boolean(myActivePet) && Boolean(myActivePet.masteryCounter >= MASTERY_ACHIV_MIN_COUNT) && hasAchieved)
         {
            if(!_petMasteryMgr)
            {
               _petMasteryMgr = new PetMastery();
               _petMasteryMgr.init();
            }
            _petMasteryMgr.displayMasteryPopup();
         }
      }
      
      public static function onPetListResponse(data:Array, callback:Function) : void
      {
         var petsData:Array = null;
         var userName:String = null;
         var numPets:int = 0;
         var pd:Object = null;
         var idxToUpdate:int = 0;
         var i:int = 0;
         var j:int = 2;
         var status:String = data[j++];
         if(status == "1")
         {
            userName = data[j++];
            numPets = int(data[j++]);
            petsData = [];
            idxToUpdate = -1;
            for(i = 0; i < numPets; i++)
            {
               pd = {
                  "idx":int(data[j++]),
                  "name":data[j++],
                  "isGround":isGround(data[j++]),
                  "lBits":uint(data[j++]),
                  "uBits":uint(data[j++]),
                  "eBits":uint(data[j++]),
                  "masteryCounter":uint(data[j++]),
                  "isSparkling":false
               };
               pd.defId = getDefIdFromLBits(pd.lBits);
               pd.type = petTypeForDefId(pd.defId);
               petsData.push(pd);
            }
            petsData.sortOn("idx",Array.NUMERIC);
            if(userName == gMainFrame.userInfo.myUserName)
            {
               _myPetList = petsData;
            }
         }
         if(callback != null)
         {
            callback(petsData,status == "-1");
         }
      }
      
      public static function isGround(type:int) : Boolean
      {
         return type == PetBase.TYPE_LAND_GROUND || type == PetBase.TYPE_OCEAN_GROUND || type == PetBase.TYPE_AMPHIB_GROUND;
      }
      
      public static function onPetCreateResponse(data:Array, callback:Function) : void
      {
         var prevBalance:int = 0;
         var newBalance:int = 0;
         var currencyType:int = 0;
         var invId:int = 0;
         var lBits:uint = 0;
         var uBits:uint = 0;
         var eBits:uint = 0;
         var petName:String = null;
         var defId:int = 0;
         var def:Object = null;
         var petObj:Object = null;
         var j:int = 2;
         if(data[j++] == "1")
         {
            newBalance = int(data[j++]);
            currencyType = int(data[j++]);
            switch(currencyType)
            {
               case Item.GEM_CURRENCY:
                  prevBalance = int(gMainFrame.clientInfo.gemCount);
                  if(prevBalance != newBalance)
                  {
                     gMainFrame.clientInfo.gemCount = newBalance;
                  }
                  break;
               case Item.TICKET_CURRENCY:
                  prevBalance = int(gMainFrame.clientInfo.ticketCount);
                  if(prevBalance != newBalance)
                  {
                     gMainFrame.clientInfo.ticketCount = newBalance;
                  }
                  break;
               case Item.ORB_CURRENCY:
                  prevBalance = int(gMainFrame.clientInfo.orbCount);
                  if(prevBalance != newBalance)
                  {
                     gMainFrame.clientInfo.orbCount = newBalance;
                  }
                  break;
               case Item.DIAMOND_CURRENCY:
                  prevBalance = int(gMainFrame.clientInfo.diamondCount);
                  if(prevBalance != newBalance)
                  {
                     gMainFrame.clientInfo.diamondCount = newBalance;
                  }
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + currencyType);
            }
            if(prevBalance != newBalance)
            {
               AJAudio.playShopCachingSound();
            }
            invId = int(data[j++]);
            lBits = uint(data[j++]);
            uBits = uint(data[j++]);
            eBits = uint(data[j++]);
            petName = data[j++];
            defId = getDefIdFromLBits(lBits);
            def = getPetDef(defId);
            if(Boolean(def))
            {
               petObj = {
                  "idx":invId,
                  "name":petName,
                  "defId":defId,
                  "type":def.type,
                  "lBits":lBits,
                  "uBits":uBits,
                  "eBits":eBits,
                  "isSparkling":false
               };
               petObj.masteryCounter = 0;
               _myPetList.push(petObj);
               if(!def.isMember || Boolean(gMainFrame.userInfo.isMember))
               {
                  AvatarManager.playerAvatarWorldView.setActivePet(lBits,uBits,eBits,petName);
                  myActivePetInvId = invId;
               }
               DenXtCommManager.addPetToDen(petObj);
               AvatarManager.setPetAction(AvatarManager.playerSfsUserId,WorldPet.ACTION_SPARKLE,0);
               if(callback != null)
               {
                  callback();
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14809));
         }
      }
      
      public static function onPetSwitchResponse(data:Array, callback:Function) : void
      {
         var awv:AvatarWorldView = null;
         var sfsUserId:int = 0;
         var ui:UserInfo = null;
         var avInfo:AvatarInfo = null;
         var myPet:Object = null;
         var hasFound:Boolean = false;
         var o:Object = null;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var petName:String = null;
         var currPet:Object = null;
         var ai:AvatarInfo = null;
         var j:int = 2;
         var status:Boolean = data[j++] == "1";
         if(status)
         {
            sfsUserId = int(data[j++]);
            awv = AvatarManager.getAvatarWorldViewBySfsUserId(sfsUserId);
            if(sfsUserId == gMainFrame.server.userId)
            {
               myActivePetInvId = int(data[j++]);
               if(Boolean(awv))
               {
                  if(myActivePetInvId != 0)
                  {
                     for each(o in _myPetList)
                     {
                        if(o.idx == myActivePetInvId)
                        {
                           awv.setActivePet(o.lBits,o.uBits,o.eBits,o.name);
                           hasFound = true;
                           break;
                        }
                     }
                  }
                  else
                  {
                     awv.setActivePet(0,0,0,"");
                  }
                  ui = gMainFrame.userInfo.getUserInfoByUserName(awv.userName);
                  for each(avInfo in ui.avList)
                  {
                     if(avInfo.perUserAvId == awv.perUserAvId)
                     {
                        if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND)
                        {
                           avInfo.landPetInvId = myActivePetInvId;
                        }
                        else
                        {
                           avInfo.oceanPetInvId = myActivePetInvId;
                        }
                        gMainFrame.userInfo.setUserInfoByUserName(awv.userName,ui);
                        break;
                     }
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,WorldPet.ACTION_SPARKLE,0);
                  myPet = myActivePet;
                  if(Boolean(myPet))
                  {
                     awv.setActivePet(myPet.lBits,myPet.uBits,myPet.eBits,myPet.name);
                     myPet.isSparkling = false;
                  }
               }
            }
            else
            {
               lBits = int(data[j++]);
               uBits = int(data[j++]);
               eBits = int(data[j++]);
               petName = data[j++];
               if(Boolean(awv))
               {
                  awv.setActivePet(lBits,uBits,uBits,petName);
               }
               currPet = null;
               if(lBits != 0)
               {
                  currPet = {
                     "name":petName,
                     "lBits":lBits,
                     "uBits":uBits,
                     "eBits":eBits
                  };
                  currPet.defId = PetManager.getDefIdFromLBits(currPet.lBits);
                  currPet.type = PetManager.petTypeForDefId(currPet.defId);
                  currPet.isGround = PetManager.isGround(currPet.type);
               }
               ai = gMainFrame.userInfo.getAvatarInfoByUserName(awv.userName);
               if(Boolean(ai))
               {
                  ai.currPet = currPet;
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14810));
         }
         if(callback != null)
         {
            callback(status);
         }
      }
      
      public static function onPetItemsResponse(data:Array, callback:Function) : void
      {
         var gemBalance:int = 0;
         var myActivePet:Object = null;
         var invId:int = 0;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var j:int = 2;
         var status:Boolean = data[j++] == "1";
         if(status)
         {
            gemBalance = int(data[j++]);
            gMainFrame.clientInfo.gemCount = gemBalance;
            AJAudio.playShopCachingSound();
            myActivePet = myActivePet;
            if(myActivePet == null)
            {
               trace("ERROR: myActivePet is null");
               return;
            }
            invId = int(data[j++]);
            if(myActivePet.idx != invId)
            {
               trace("ERROR: Invalid pet invId");
               return;
            }
            lBits = int(data[j++]);
            uBits = int(data[j++]);
            eBits = int(data[j++]);
            myActivePet.lBits = lBits;
            myActivePet.uBits = uBits;
            myActivePet.eBits = eBits;
            AvatarManager.playerAvatarWorldView.setActivePet(lBits,uBits,eBits,myActivePetName);
            myActivePetInvId = invId;
            DenXtCommManager.reloadPetInDen(invId,lBits,uBits,eBits);
         }
         if(callback != null)
         {
            callback(status);
         }
      }
      
      public static function onPetMasteryResponse(data:Array, callback:Function) : void
      {
         var invId:int = 0;
         var i:int = 0;
         var lBits:int = 0;
         var uBits:int = 0;
         var eBits:int = 0;
         var j:int = 2;
         var status:Boolean = data[j++] == "1";
         if(status)
         {
            invId = int(data[j++]);
            for(i = 0; i < _myPetList.length; i++)
            {
               if(_myPetList[i].idx == invId)
               {
                  lBits = int(data[j++]);
                  uBits = int(data[j++]);
                  eBits = int(data[j++]);
                  _myPetList[i].lBits = lBits;
                  _myPetList[i].uBits = uBits;
                  _myPetList[i].eBits = eBits;
                  DenXtCommManager.reloadPetInDen(invId,lBits,uBits,eBits);
                  break;
               }
            }
         }
         DarkenManager.showLoadingSpiral(false);
         if(callback != null)
         {
            callback(status);
         }
      }
      
      public static function onPetDismissResponse(data:Array, callback:Function) : void
      {
         var isFound:Boolean = false;
         var wasActivePet:Boolean = false;
         var i:int = 0;
         var status:Boolean = data[2] == "1";
         var invIdx:int = int(data[3]);
         if(status)
         {
            for(i = 0; i < _myPetList.length; i++)
            {
               if(_myPetList[i].idx == invIdx)
               {
                  if(_myActivePetInvId == _myPetList[i].idx)
                  {
                     _myActivePetInvId = 0;
                     AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,"");
                     wasActivePet = true;
                     AvatarManager.setPetAction(AvatarManager.playerSfsUserId,WorldPet.ACTION_SPARKLE,0);
                  }
                  _myPetList.splice(i,1);
                  DenXtCommManager.removePetFromDen(invIdx);
                  isFound = true;
                  break;
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14786));
         }
         if(callback != null)
         {
            callback(status,isFound,wasActivePet);
         }
      }
      
      public static function getPetSprite(lBits:uint, uBits:uint, eBits:uint, type:int, onLoadedCallback:Function = null) : Sprite
      {
         return Sprite(new PetBase(lBits,uBits,eBits,onLoadedCallback));
      }
      
      public static function getGuiPet(idx:int, lBits:uint, uBits:uint, eBits:uint, type:int, name:String, onLoadedCallback:Function = null) : GuiPet
      {
         return new GuiPet(idx,lBits,uBits,eBits,type,name,onLoadedCallback);
      }
      
      public static function get myPetList() : Array
      {
         return _myPetList;
      }
      
      public static function get myActivePetName() : String
      {
         var myPet:Object = getMyPetByInvId(_myActivePetInvId);
         if(Boolean(myPet))
         {
            return myPet.name;
         }
         return "";
      }
      
      public static function set myActivePetInvId(value:int) : void
      {
         _myActivePetInvId = value;
      }
      
      public static function addToActivePetMastery(amount:int) : void
      {
         myActivePet.masteryCounter += amount;
      }
      
      public static function get myActivePetInvId() : int
      {
         return _myActivePetInvId;
      }
      
      public static function getMyPetByInvId(invId:int) : Object
      {
         var o:Object = null;
         for each(o in _myPetList)
         {
            if(o.idx == invId)
            {
               return o;
            }
         }
         return null;
      }
      
      public static function get myActivePet() : Object
      {
         var o:Object = null;
         for each(o in _myPetList)
         {
            if(o.idx == _myActivePetInvId)
            {
               return o;
            }
         }
         return null;
      }
      
      public static function petTypeForDefId(defId:int) : int
      {
         if(Boolean(_petDefs) && Boolean(_petDefs[defId]))
         {
            return _petDefs[defId].type;
         }
         return -1;
      }
      
      public static function getPetDef(defId:int) : Object
      {
         if(Boolean(_petDefs))
         {
            return _petDefs[defId];
         }
         return null;
      }
      
      public static function petForPetDefId(defId:int) : Object
      {
         var o:Object = null;
         for each(o in _myPetList)
         {
            if(o.defId == defId)
            {
               return o;
            }
         }
         return null;
      }
      
      public static function getEnviroTypeByPetType(type:int, avatarEnviroTypeFlag:int = 0) : int
      {
         if(type == TYPE_LAND_LOW)
         {
            return Utility.ENVIRO_LAND;
         }
         if(type == TYPE_LAND_HIGH)
         {
            return Utility.isAir(avatarEnviroTypeFlag) ? Utility.ENVIRO_AIR : Utility.ENVIRO_LAND;
         }
         if(type == TYPE_OCEAN_HIGH || type == TYPE_OCEAN_LOW)
         {
            return Utility.ENVIRO_OCEAN;
         }
         if(type == TYPE_AMPHIB_LOW || type == TYPE_AMPHIB_HIGH)
         {
            return AvatarManager.roomEnviroType;
         }
         return -1;
      }
      
      public static function setPetState(petMC:MovieClip, lBits:uint, uBits:uint, eBits:uint) : void
      {
         var test:int = lBits & 0xFF;
         if(test == 15)
         {
            petMC.pet.setState(lBits,uBits,eBits,AvatarManager.roomEnviroType);
         }
         else
         {
            petMC.pet.setState(lBits,uBits);
         }
      }
      
      public static function petDefIdForName(petName:String) : int
      {
         switch(petName)
         {
            case "frog":
               return PetBase.DEF_ID_FROG;
            case "kitten":
               return PetBase.DEF_ID_CAT;
            case "puppy":
               return PetBase.DEF_ID_DOG;
            case "ducky":
               return PetBase.DEF_ID_DUCK;
            case "butterfly":
               return PetBase.DEF_ID_BFLY;
            case "hamster":
               return PetBase.DEF_ID_HAMS;
            case "bat":
               return PetBase.DEF_ID_BAT;
            case "seahorse":
               return PetBase.DEF_ID_SEAHORSE;
            case "anglerfish":
               return PetBase.DEF_ID_ANGLER;
            case "reindeer":
               return PetBase.DEF_ID_REINDEER;
            case "snake":
               return PetBase.DEF_ID_SNAKE;
            case "jellyfish":
               return PetBase.DEF_ID_JELLYFISH;
            case "bunny":
               return PetBase.DEF_ID_BUNNY;
            case "hummingbird":
               return PetBase.DEF_ID_HUMMINGBIRD;
            case "turtle":
               return PetBase.DEF_ID_TURTLE;
            case "monkey":
               return PetBase.DEF_ID_MONKEY;
            case "tarantula":
               return PetBase.DEF_ID_TARANTUAL;
            case "fox":
               return PetBase.DEF_ID_FOX;
            case "owl":
               return PetBase.DEF_ID_OWL;
            case "tiger":
               return PetBase.DEF_ID_TIGER;
            case "arcticwolfpup":
               return PetBase.DEF_ID_ARCTIC_WOLF;
            case "raccoon":
               return PetBase.DEF_ID_RACCOON;
            case "joey":
               return PetBase.DEF_ID_JOEY;
            case "eaglet":
               return PetBase.DEF_ID_EAGLET;
            case "cheetah":
               return PetBase.DEF_ID_CHEETAH;
            case "rhino":
               return PetBase.DEF_ID_RHINO;
            case "giraffe":
               return PetBase.DEF_ID_GIRAFFE;
            case "sugarglider":
               return PetBase.DEF_ID_SUGAR_GLIDER;
            case "lionCub":
               return PetBase.DEF_ID_LION_CUB;
            default:
               return -1;
         }
      }
      
      public static function petNameForDefId(defId:int) : String
      {
         switch(defId)
         {
            case PetBase.DEF_ID_FROG:
               return "frog";
            case PetBase.DEF_ID_CAT:
               return "kitten";
            case PetBase.DEF_ID_DOG:
               return "puppy";
            case PetBase.DEF_ID_DUCK:
               return "ducky";
            case PetBase.DEF_ID_BFLY:
               return "butterfly";
            case PetBase.DEF_ID_HAMS:
               return "hamster";
            case PetBase.DEF_ID_BAT:
               return "bat";
            case PetBase.DEF_ID_SEAHORSE:
               return "seahorse";
            case PetBase.DEF_ID_ANGLER:
               return "anglerfish";
            case PetBase.DEF_ID_REINDEER:
               return "reindeer";
            case PetBase.DEF_ID_SNAKE:
               return "snake";
            case PetBase.DEF_ID_JELLYFISH:
               return "jellyfish";
            case PetBase.DEF_ID_BUNNY:
               return "bunny";
            case PetBase.DEF_ID_HUMMINGBIRD:
               return "hummingbird";
            case PetBase.DEF_ID_TURTLE:
               return "turtle";
            case PetBase.DEF_ID_MONKEY:
               return "monkey";
            case PetBase.DEF_ID_TARANTUAL:
               return "tarantula";
            case PetBase.DEF_ID_FOX:
               return "fox";
            case PetBase.DEF_ID_OWL:
               return "owl";
            case PetBase.DEF_ID_TIGER:
               return "tiger";
            case PetBase.DEF_ID_ARCTIC_WOLF:
               return "arcticwolfpup";
            case PetBase.DEF_ID_RACCOON:
               return "raccoon";
            case PetBase.DEF_ID_JOEY:
               return "joey";
            case PetBase.DEF_ID_EAGLET:
               return "eaglet";
            case PetBase.DEF_ID_CHEETAH:
               return "cheetah";
            case PetBase.DEF_ID_RHINO:
               return "rhino";
            case PetBase.DEF_ID_GIRAFFE:
               return "giraffe";
            case PetBase.DEF_ID_SUGAR_GLIDER:
               return "sugarglider";
            case PetBase.DEF_ID_LION_CUB:
               return "lionCub";
            default:
               return "";
         }
      }
      
      public static function getDefIdFromLBits(lBits:int) : int
      {
         return lBits & 0xFF;
      }
      
      public static function sendPetSparkle(sparkle:int) : void
      {
         UserCommXtCommManager.sendPetAction(WorldPet.ACTION_SPARKLE,sparkle);
      }
      
      public static function getPetInventoryMax() : int
      {
         return gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_PET_INVENTORY_MAX);
      }
      
      public static function isPetAvailable(petDefId:int) : Boolean
      {
         if((gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_PET_VIEWABLE_FLAG) & 1 << petDefId - 1) != 0)
         {
            return true;
         }
         return false;
      }
      
      public static function canCurrAvatarUsePet(avatarEnviroTypeFlag:int, petType:int) : Boolean
      {
         var ignoreByEnviroTypeFlag:Boolean = false;
         var currPartyDef:Object = null;
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
         {
            currPartyDef = PartyManager.getPartyDef(gMainFrame.clientInfo.secondaryDefId);
            if(currPartyDef != null)
            {
               if(currPartyDef.restrictions == PartyManager.RESTRICTIONS_BEYOURPET)
               {
                  ignoreByEnviroTypeFlag = true;
               }
            }
         }
         return canBeUsedInEnviroType(petType,AvatarManager.roomEnviroType) && (ignoreByEnviroTypeFlag ? true : canBeUsedByEnviroTypeFlag(petType,avatarEnviroTypeFlag));
      }
      
      private static function canBeUsedInEnviroType(petType:int, enviroType:int) : Boolean
      {
         if(petType == TYPE_LAND_LOW || petType == TYPE_LAND_HIGH)
         {
            return enviroType == Utility.ENVIRO_LAND;
         }
         if(petType == TYPE_OCEAN_LOW || petType == TYPE_OCEAN_HIGH)
         {
            return enviroType == Utility.ENVIRO_OCEAN;
         }
         if(petType == TYPE_AMPHIB_LOW || petType == TYPE_AMPHIB_HIGH)
         {
            return enviroType == Utility.ENVIRO_LAND || enviroType == Utility.ENVIRO_OCEAN;
         }
         return false;
      }
      
      private static function canBeUsedByEnviroTypeFlag(petType:int, enviroTypeFlag:int) : Boolean
      {
         if(petType == TYPE_LAND_LOW)
         {
            return !Utility.isAir(enviroTypeFlag) && Utility.isLand(enviroTypeFlag);
         }
         if(petType == TYPE_LAND_HIGH)
         {
            return Utility.isAir(enviroTypeFlag) || Utility.isLand(enviroTypeFlag);
         }
         if(petType == TYPE_OCEAN_LOW || petType == TYPE_OCEAN_HIGH)
         {
            return Utility.isOcean(enviroTypeFlag);
         }
         if(petType == TYPE_AMPHIB_LOW)
         {
            return !Utility.isAir(enviroTypeFlag) && (Utility.isLand(enviroTypeFlag) || Utility.isOcean(enviroTypeFlag));
         }
         if(petType == TYPE_AMPHIB_HIGH)
         {
            return Utility.isLand(enviroTypeFlag) || Utility.isOcean(enviroTypeFlag);
         }
         return false;
      }
      
      public static function canPetGoInEnviroType(petType:int, enviroTypeFlag:int) : Boolean
      {
         var petEnviroType:int = getEnviroTypeByPetType(petType,enviroTypeFlag);
         if(Utility.isSameEnviroType(enviroTypeFlag,petEnviroType))
         {
            return true;
         }
         return false;
      }
      
      public static function checkIfHasPet(enviroTypeFlag:int) : Boolean
      {
         var o:Object = null;
         var petEnviroType:int = 0;
         for each(o in _myPetList)
         {
            petEnviroType = getEnviroTypeByPetType(o.type,enviroTypeFlag);
            if(petEnviroType == Utility.ENVIRO_LAND)
            {
               if(Utility.isSameEnviroType(enviroTypeFlag,petEnviroType) && !Utility.isAir(enviroTypeFlag))
               {
                  return true;
               }
            }
            else if(Utility.isSameEnviroType(enviroTypeFlag,petEnviroType))
            {
               return true;
            }
         }
         return false;
      }
   }
}

