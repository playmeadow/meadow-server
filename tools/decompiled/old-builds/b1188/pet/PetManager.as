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
   import gui.PetCreator;
   import gui.PetMastery;
   import item.Item;
   import localization.LocalizationManager;
   
   public class PetManager
   {
      
      private static var _petDefs:Object;
      
      private static var _myPetList:Array;
      
      private static var _myActivePetInvId:int;
      
      private static var _petFinderCloseCallback:Function;
      
      private static var _petFinder:PetCreator;
      
      private static var _petMasteryMgr:PetMastery;
      
      private static var _petFinderCallback:Function;
      
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
      
      public static function set petDefs(param1:Object) : void
      {
         _petDefs = param1;
      }
      
      public static function relocalizePetDefs() : void
      {
         var _loc1_:Object = null;
         for each(_loc1_ in _petDefs)
         {
            _loc1_.title = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
         }
      }
      
      public static function openPetFinder(param1:String = "", param2:Function = null, param3:Boolean = false, param4:Array = null, param5:Object = null, param6:int = 0, param7:int = 0) : void
      {
         if(_petFinder)
         {
            _petFinder.destroy();
            _petFinder = null;
         }
         _petFinder = new PetCreator();
         _petFinderCallback = param2;
         if(param1 == "")
         {
            _petFinder.init(-1,onPetFinderClose,false,null,param6,null,param7);
         }
         else
         {
            _petFinder.init(petDefIdForName(param1),onPetFinderClose,param3,param4,param6,param5,param7);
         }
      }
      
      private static function onPetFinderClose() : void
      {
         if(_petFinder)
         {
            _petFinder.destroy();
            _petFinder = null;
         }
         if(_petFinderCallback != null)
         {
            _petFinderCallback();
            _petFinderCallback = null;
         }
      }
      
      public static function checkAndOpenMasteryPopup(param1:Boolean) : void
      {
         if(Boolean(myActivePet) && Boolean(myActivePet.masteryCounter >= MASTERY_ACHIV_MIN_COUNT) && param1)
         {
            if(!_petMasteryMgr)
            {
               _petMasteryMgr = new PetMastery();
               _petMasteryMgr.init();
            }
            _petMasteryMgr.displayMasteryPopup();
         }
      }
      
      public static function onPetListResponse(param1:Array, param2:Function) : void
      {
         var _loc4_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:Object = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:* = 2;
         var _loc5_:String = param1[_loc3_++];
         if(_loc5_ == "1")
         {
            _loc6_ = param1[_loc3_++];
            _loc7_ = int(param1[_loc3_++]);
            _loc4_ = [];
            _loc9_ = -1;
            _loc10_ = 0;
            while(_loc10_ < _loc7_)
            {
               _loc8_ = {
                  "idx":int(param1[_loc3_++]),
                  "name":param1[_loc3_++],
                  "isGround":isGround(param1[_loc3_++]),
                  "lBits":uint(param1[_loc3_++]),
                  "uBits":uint(param1[_loc3_++]),
                  "eBits":uint(param1[_loc3_++]),
                  "masteryCounter":uint(param1[_loc3_++]),
                  "isSparkling":false
               };
               _loc8_.defId = getDefIdFromLBits(_loc8_.lBits);
               _loc8_.type = petTypeForDefId(_loc8_.defId);
               _loc4_.push(_loc8_);
               _loc10_++;
            }
            _loc4_.sortOn("idx",Array.NUMERIC);
            if(_loc6_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _myPetList = _loc4_;
            }
         }
         if(param2 != null)
         {
            param2(_loc4_,_loc5_);
         }
      }
      
      public static function isGround(param1:int) : Boolean
      {
         return param1 == PetBase.TYPE_LAND_GROUND || param1 == PetBase.TYPE_OCEAN_GROUND || param1 == PetBase.TYPE_AMPHIB_GROUND;
      }
      
      public static function onPetCreateResponse(param1:Array, param2:Function) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc3_:* = 2;
         if(param1[_loc3_++] == "1")
         {
            _loc5_ = int(param1[_loc3_++]);
            _loc6_ = int(param1[_loc3_++]);
            switch(_loc6_)
            {
               case Item.GEM_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.gemCount);
                  if(_loc4_ != _loc5_)
                  {
                     gMainFrame.clientInfo.gemCount = _loc5_;
                  }
                  break;
               case Item.TICKET_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.ticketCount);
                  if(_loc4_ != _loc5_)
                  {
                     gMainFrame.clientInfo.ticketCount = _loc5_;
                  }
                  break;
               case Item.CRYSTAL_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.crystalCount);
                  if(_loc4_ != _loc5_)
                  {
                     gMainFrame.clientInfo.crystalCount = _loc5_;
                  }
                  break;
               case Item.DIAMOND_CURRENCY:
                  _loc4_ = int(gMainFrame.clientInfo.diamondCount);
                  if(_loc4_ != _loc5_)
                  {
                     gMainFrame.clientInfo.diamondCount = _loc5_;
                  }
                  break;
               default:
                  throw new Error("ItemManager: Received unknown currencyType: " + _loc6_);
            }
            if(_loc4_ != _loc5_)
            {
               AJAudio.playShopCachingSound();
            }
            _loc7_ = int(param1[_loc3_++]);
            _loc8_ = uint(param1[_loc3_++]);
            _loc9_ = uint(param1[_loc3_++]);
            _loc10_ = uint(param1[_loc3_++]);
            _loc11_ = param1[_loc3_++];
            _loc12_ = getDefIdFromLBits(_loc8_);
            _loc13_ = getPetDef(_loc12_);
            if(_loc13_)
            {
               _loc14_ = {
                  "idx":_loc7_,
                  "name":_loc11_,
                  "defId":_loc12_,
                  "type":_loc13_.type,
                  "lBits":_loc8_,
                  "uBits":_loc9_,
                  "eBits":_loc10_,
                  "isSparkling":false
               };
               _loc14_.masteryCounter = 0;
               _myPetList.push(_loc14_);
               DenXtCommManager.addPetToDen(_loc14_);
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc13_.type))
               {
                  if(!_loc13_.isMember || Boolean(gMainFrame.userInfo.isMember))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(_loc8_,_loc9_,_loc10_,_loc11_);
                     myActivePetInvId = _loc7_;
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,WorldPet.ACTION_SPARKLE,0);
               }
               if(param2 != null)
               {
                  param2();
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14809));
         }
      }
      
      public static function onPetSwitchResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:AvatarWorldView = null;
         var _loc6_:int = 0;
         var _loc7_:UserInfo = null;
         var _loc8_:AvatarInfo = null;
         var _loc9_:Object = null;
         var _loc10_:Boolean = false;
         var _loc11_:Object = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:String = null;
         var _loc16_:Object = null;
         var _loc17_:AvatarInfo = null;
         var _loc3_:* = 2;
         var _loc4_:Boolean = param1[_loc3_++] == "1";
         if(_loc4_)
         {
            _loc6_ = int(param1[_loc3_++]);
            _loc5_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc6_);
            if(_loc6_ == gMainFrame.server.userId)
            {
               myActivePetInvId = int(param1[_loc3_++]);
               if(_loc5_)
               {
                  if(myActivePetInvId != 0)
                  {
                     for each(_loc11_ in _myPetList)
                     {
                        if(_loc11_.idx == myActivePetInvId)
                        {
                           _loc5_.setActivePet(_loc11_.lBits,_loc11_.uBits,_loc11_.eBits,_loc11_.name);
                           _loc10_ = true;
                           break;
                        }
                     }
                  }
                  else
                  {
                     _loc5_.setActivePet(0,0,0,"");
                  }
                  _loc7_ = gMainFrame.userInfo.getUserInfoByUserName(_loc5_.userName);
                  for each(_loc8_ in _loc7_.avList)
                  {
                     if(_loc8_.perUserAvId == _loc5_.perUserAvId)
                     {
                        if(AvatarManager.roomEnviroType == SbiConstants.ENVIRO_LAND)
                        {
                           _loc8_.landPetInvId = myActivePetInvId;
                        }
                        else
                        {
                           _loc8_.oceanPetInvId = myActivePetInvId;
                        }
                        gMainFrame.userInfo.setUserInfoByUserName(_loc5_.userName,_loc7_);
                        break;
                     }
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,WorldPet.ACTION_SPARKLE,0);
                  _loc9_ = myActivePet;
                  if(_loc9_)
                  {
                     _loc5_.setActivePet(_loc9_.lBits,_loc9_.uBits,_loc9_.eBits,_loc9_.name);
                     _loc9_.isSparkling = false;
                  }
               }
            }
            else
            {
               _loc12_ = int(param1[_loc3_++]);
               _loc13_ = int(param1[_loc3_++]);
               _loc14_ = int(param1[_loc3_++]);
               _loc15_ = param1[_loc3_++];
               if(_loc5_)
               {
                  _loc5_.setActivePet(_loc12_,_loc13_,_loc13_,_loc15_);
               }
               _loc16_ = null;
               if(_loc12_ != 0)
               {
                  _loc16_ = {
                     "name":_loc15_,
                     "lBits":_loc12_,
                     "uBits":_loc13_,
                     "eBits":_loc14_
                  };
                  _loc16_.defId = PetManager.getDefIdFromLBits(_loc16_.lBits);
                  _loc16_.type = PetManager.petTypeForDefId(_loc16_.defId);
                  _loc16_.isGround = PetManager.isGround(_loc16_.type);
               }
               _loc17_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc5_.userName);
               if(_loc17_)
               {
                  _loc17_.currPet = _loc16_;
               }
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14810));
         }
         if(param2 != null)
         {
            param2(_loc4_);
         }
      }
      
      public static function onPetItemsResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:* = 2;
         var _loc4_:Boolean = param1[_loc3_++] == "1";
         if(_loc4_)
         {
            _loc5_ = int(param1[_loc3_++]);
            gMainFrame.clientInfo.gemCount = _loc5_;
            AJAudio.playShopCachingSound();
            _loc6_ = myActivePet;
            if(_loc6_ == null)
            {
               return;
            }
            _loc7_ = int(param1[_loc3_++]);
            if(myActivePet.idx != _loc7_)
            {
               return;
            }
            _loc8_ = int(param1[_loc3_++]);
            _loc9_ = int(param1[_loc3_++]);
            _loc10_ = int(param1[_loc3_++]);
            _loc6_.lBits = _loc8_;
            _loc6_.uBits = _loc9_;
            _loc6_.eBits = _loc10_;
            AvatarManager.playerAvatarWorldView.setActivePet(_loc8_,_loc9_,_loc10_,myActivePetName);
            myActivePetInvId = _loc7_;
            DenXtCommManager.reloadPetInDen(_loc7_,_loc8_,_loc9_,_loc10_);
         }
         if(param2 != null)
         {
            param2(_loc4_);
         }
      }
      
      public static function onPetMasteryResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:* = 2;
         var _loc4_:Boolean = param1[_loc3_++] == "1";
         if(_loc4_)
         {
            _loc5_ = int(param1[_loc3_++]);
            _loc6_ = 0;
            while(_loc6_ < _myPetList.length)
            {
               if(_myPetList[_loc6_].idx == _loc5_)
               {
                  _loc7_ = int(param1[_loc3_++]);
                  _loc8_ = int(param1[_loc3_++]);
                  _loc9_ = int(param1[_loc3_++]);
                  _myPetList[_loc6_].lBits = _loc7_;
                  _myPetList[_loc6_].uBits = _loc8_;
                  _myPetList[_loc6_].eBits = _loc9_;
                  DenXtCommManager.reloadPetInDen(_loc5_,_loc7_,_loc8_,_loc9_);
                  break;
               }
               _loc6_++;
            }
         }
         DarkenManager.showLoadingSpiral(false);
         if(param2 != null)
         {
            param2(_loc4_);
         }
      }
      
      public static function onPetDismissResponse(param1:Array, param2:Function) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc7_:int = 0;
         var _loc5_:Boolean = param1[2] == "1";
         var _loc6_:int = int(param1[3]);
         if(_loc5_)
         {
            _loc7_ = 0;
            while(_loc7_ < _myPetList.length)
            {
               if(_myPetList[_loc7_].idx == _loc6_)
               {
                  if(_myActivePetInvId == _myPetList[_loc7_].idx)
                  {
                     _myActivePetInvId = 0;
                     AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,"");
                     _loc4_ = true;
                     AvatarManager.setPetAction(AvatarManager.playerSfsUserId,WorldPet.ACTION_SPARKLE,0);
                  }
                  _myPetList.splice(_loc7_,1);
                  DenXtCommManager.removePetFromDen(_loc6_);
                  _loc3_ = true;
                  break;
               }
               _loc7_++;
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14786));
         }
         if(param2 != null)
         {
            param2(_loc5_,_loc3_,_loc4_);
         }
      }
      
      public static function getPetSprite(param1:uint, param2:uint, param3:uint, param4:int, param5:Function = null) : Sprite
      {
         return Sprite(new PetBase(param1,param2,param3,param5));
      }
      
      public static function getGuiPet(param1:int, param2:uint, param3:uint, param4:uint, param5:int, param6:String, param7:Function = null) : GuiPet
      {
         return new GuiPet(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public static function get myPetList() : Array
      {
         return _myPetList;
      }
      
      public static function get myActivePetName() : String
      {
         var _loc1_:Object = getMyPetByInvId(_myActivePetInvId);
         if(_loc1_)
         {
            return _loc1_.name;
         }
         return "";
      }
      
      public static function set myActivePetInvId(param1:int) : void
      {
         _myActivePetInvId = param1;
      }
      
      public static function addToActivePetMastery(param1:int) : void
      {
         myActivePet.masteryCounter += param1;
      }
      
      public static function get myActivePetInvId() : int
      {
         return _myActivePetInvId;
      }
      
      public static function getMyPetByInvId(param1:int) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in _myPetList)
         {
            if(_loc2_.idx == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function get myActivePet() : Object
      {
         var _loc1_:Object = null;
         for each(_loc1_ in _myPetList)
         {
            if(_loc1_.idx == _myActivePetInvId)
            {
               return _loc1_;
            }
         }
         return null;
      }
      
      public static function petTypeForDefId(param1:int) : int
      {
         if(Boolean(_petDefs) && Boolean(_petDefs[param1]))
         {
            return _petDefs[param1].type;
         }
         return -1;
      }
      
      public static function getPetDef(param1:int) : Object
      {
         if(_petDefs)
         {
            return _petDefs[param1];
         }
         return null;
      }
      
      public static function petForPetDefId(param1:int) : Object
      {
         var _loc2_:Object = null;
         for each(_loc2_ in _myPetList)
         {
            if(_loc2_.defId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public static function getEnviroTypeByPetType(param1:int, param2:int = 0) : int
      {
         if(param1 == TYPE_LAND_LOW)
         {
            return SbiConstants.ENVIRO_LAND;
         }
         if(param1 == TYPE_LAND_HIGH)
         {
            return Utility.isAir(param2) ? SbiConstants.ENVIRO_AIR : SbiConstants.ENVIRO_LAND;
         }
         if(param1 == TYPE_OCEAN_HIGH || param1 == TYPE_OCEAN_LOW)
         {
            return SbiConstants.ENVIRO_OCEAN;
         }
         if(param1 == TYPE_AMPHIB_LOW || param1 == TYPE_AMPHIB_HIGH)
         {
            return AvatarManager.roomEnviroType;
         }
         return -1;
      }
      
      public static function setPetState(param1:MovieClip, param2:uint, param3:uint, param4:uint) : void
      {
         var _loc5_:int = param2 & 0xFF;
         if(PetManager.petTypeForDefId(_loc5_) == 4)
         {
            param1.pet.setState(param2,param3,param4,AvatarManager.roomEnviroType);
         }
         else
         {
            param1.pet.setState(param2,param3);
         }
      }
      
      public static function petDefIdForName(param1:String) : int
      {
         switch(param1)
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
            case "panda":
               return PetBase.DEF_ID_PANDA;
            case "polarBearCub":
               return PetBase.DEF_ID_POLAR_BEAR_CUB;
            case "gecko":
               return PetBase.DEF_ID_GECKO;
            case "pony":
               return PetBase.DEF_ID_PONY;
            case "piglet":
               return PetBase.DEF_ID_PIGLET;
            default:
               return -1;
         }
      }
      
      public static function petNameForDefId(param1:int) : String
      {
         switch(param1)
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
            case PetBase.DEF_ID_PANDA:
               return "panda";
            case PetBase.DEF_ID_POLAR_BEAR_CUB:
               return "polarBearCub";
            case PetBase.DEF_ID_GECKO:
               return "gecko";
            case PetBase.DEF_ID_PONY:
               return "pony";
            case PetBase.DEF_ID_PIGLET:
               return "piglet";
            default:
               return "";
         }
      }
      
      public static function getDefIdFromLBits(param1:int) : int
      {
         return param1 & 0xFF;
      }
      
      public static function sendPetSparkle(param1:int) : void
      {
         UserCommXtCommManager.sendPetAction(WorldPet.ACTION_SPARKLE,param1);
      }
      
      public static function getPetInventoryMax() : Number
      {
         return gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_PET_INVENTORY_MAX);
      }
      
      public static function isPetAvailable(param1:Number) : Boolean
      {
         if(Utility.areTwoAndedNumbersEqual(gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_PET_VIEWABLE_FLAG),Utility.leftShiftNumbers(param1 - 1)))
         {
            return true;
         }
         return false;
      }
      
      public static function canCurrAvatarUsePet(param1:int, param2:int) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:Object = null;
         if(gMainFrame.clientInfo.roomType == SbiConstants.ROOMTYPE_PARTY)
         {
            _loc4_ = PartyManager.getPartyDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc4_ != null)
            {
               if(_loc4_.restrictions == PartyManager.RESTRICTIONS_BEYOURPET)
               {
                  _loc3_ = true;
               }
            }
         }
         return canBeUsedInEnviroType(param2,AvatarManager.roomEnviroType) && (_loc3_ ? true : canBeUsedByEnviroTypeFlag(param2,param1));
      }
      
      private static function canBeUsedInEnviroType(param1:int, param2:int) : Boolean
      {
         if(param1 == TYPE_LAND_LOW || param1 == TYPE_LAND_HIGH)
         {
            return param2 == SbiConstants.ENVIRO_LAND;
         }
         if(param1 == TYPE_OCEAN_LOW || param1 == TYPE_OCEAN_HIGH)
         {
            return param2 == SbiConstants.ENVIRO_OCEAN;
         }
         if(param1 == TYPE_AMPHIB_LOW || param1 == TYPE_AMPHIB_HIGH)
         {
            return param2 == SbiConstants.ENVIRO_LAND || param2 == SbiConstants.ENVIRO_OCEAN;
         }
         return false;
      }
      
      private static function canBeUsedByEnviroTypeFlag(param1:int, param2:int) : Boolean
      {
         if(param1 == TYPE_LAND_LOW)
         {
            return !Utility.isAir(param2) && Utility.isLand(param2);
         }
         if(param1 == TYPE_LAND_HIGH)
         {
            return Utility.isAir(param2) || Utility.isLand(param2);
         }
         if(param1 == TYPE_OCEAN_LOW || param1 == TYPE_OCEAN_HIGH)
         {
            return Utility.isOcean(param2);
         }
         if(param1 == TYPE_AMPHIB_LOW)
         {
            return !Utility.isAir(param2) && (Utility.isLand(param2) || Utility.isOcean(param2));
         }
         if(param1 == TYPE_AMPHIB_HIGH)
         {
            return Utility.isLand(param2) || Utility.isOcean(param2);
         }
         return false;
      }
      
      public static function canPetGoInEnviroType(param1:int, param2:int) : Boolean
      {
         var _loc3_:int = getEnviroTypeByPetType(param1,param2);
         if(Utility.isSameEnviroType(param2,_loc3_))
         {
            return true;
         }
         return false;
      }
      
      public static function checkIfHasPet(param1:int) : Boolean
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         for each(_loc2_ in _myPetList)
         {
            _loc3_ = getEnviroTypeByPetType(_loc2_.type,param1);
            if(_loc3_ == SbiConstants.ENVIRO_LAND)
            {
               if(Utility.isSameEnviroType(param1,_loc3_) && !Utility.isAir(param1))
               {
                  return true;
               }
            }
            else if(Utility.isSameEnviroType(param1,_loc3_))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function createRandomPet(param1:int) : Array
      {
         var _loc2_:int = Math.random() * 19;
         var _loc3_:int = Math.random() * 19;
         var _loc4_:int = 0;
         var _loc5_:int = Math.random() * 5;
         var _loc6_:int = Math.random() * 3;
         var _loc7_:int = Math.random() * 3;
         var _loc8_:int = Math.random() * 3;
         var _loc9_:int = 0;
         return [param1,_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,0,0,0,0,0,0];
      }
      
      public static function packPetBits(param1:Array) : Array
      {
         var _loc2_:uint = uint(param1[5] << 28 | param1[4] << 24 | param1[3] << 19 | param1[2] << 14 | param1[1] << 8 | param1[0]);
         var _loc3_:uint = uint(param1[11] << 20 | param1[10] << 16 | param1[9] << 12 | param1[8] << 8 | param1[7] << 4 | param1[6]);
         var _loc4_:uint = 0;
         return [_loc2_,_loc3_,_loc4_];
      }
      
      public static function unpackPetBits(param1:uint, param2:uint, param3:uint) : Array
      {
         var _loc4_:int = param1 & 0xFF;
         var _loc5_:int = param1 >> 8 & 0x3F;
         var _loc6_:int = param1 >> 14 & 0x1F;
         var _loc7_:int = param1 >> 19 & 0x1F;
         var _loc8_:int = param1 >> 24 & 0x0F;
         var _loc9_:int = param1 >> 28 & 0x0F;
         var _loc10_:int = param2 & 0x0F;
         var _loc11_:int = param2 >> 4 & 0x0F;
         var _loc12_:int = param2 >> 8 & 0x0F;
         var _loc13_:int = param2 >> 12 & 0x0F;
         var _loc14_:int = param2 >> 16 & 0x0F;
         var _loc15_:int = param2 >> 20 & 0x0F;
         var _loc16_:int = param3 & 0x0F;
         var _loc17_:int = param3 >> 4 & 0x0F;
         var _loc18_:int = param3 >> 8 & 0x0F;
         return [_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc17_,_loc18_];
      }
   }
}

