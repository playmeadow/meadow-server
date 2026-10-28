package pet
{
   import Party.PartyManager;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import gui.DarkenManager;
   import gui.GuiManager;
   import gui.PetCreator;
   import gui.PetMastery;
   import inventory.Iitem;
   import localization.LocalizationManager;
   
   public class PetManager
   {
      
      public static const TYPE_LAND_LOW:int = 0;
      
      public static const TYPE_LAND_HIGH:int = 1;
      
      public static const TYPE_OCEAN_LOW:int = 2;
      
      public static const TYPE_OCEAN_HIGH:int = 3;
      
      public static const TYPE_AMPHIB_LOW:int = 4;
      
      public static const TYPE_AMPHIB_HIGH:int = 5;
      
      public static const LIMITED_TIME:int = 1;
      
      public static const MASTERY_ACHIV_MIN_COUNT:int = 100;
      
      private static const EVT_ICON_ID:int = 44;
      
      private static var _petDefs:Vector.<PetDef>;
      
      private static var _myPetList:Array;
      
      private static var _myActivePetInvId:int;
      
      private static var _petFinderCloseCallback:Function;
      
      private static var _petFinder:PetCreator;
      
      private static var _petMasteryMgr:PetMastery;
      
      private static var _petFinderCallback:Function;
      
      public function PetManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _myPetList = [];
      }
      
      public static function set petDefs(param1:Vector.<PetDef>) : void
      {
         _petDefs = param1;
      }
      
      public static function relocalizePetDefs() : void
      {
         for each(var _loc1_:PetDef in _petDefs)
         {
            if(_loc1_)
            {
               _loc1_.title = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
            }
         }
      }
      
      public static function openPetFinder(param1:String = "", param2:Function = null, param3:Boolean = false, param4:Array = null, param5:Iitem = null, param6:int = 0, param7:int = 0, param8:Boolean = false) : void
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
            _petFinder.init(petDefIdForName(param1),onPetFinderClose,param3,param4,param6,param5,param7,param8);
         }
      }
      
      private static function onPetFinderClose(param1:Boolean) : void
      {
         var _loc2_:Function = null;
         if(_petFinder)
         {
            _petFinder.destroy();
            _petFinder = null;
         }
         if(_petFinderCallback != null)
         {
            _loc2_ = _petFinderCallback;
            _petFinderCallback = null;
            if(_loc2_.length == 1)
            {
               _loc2_(param1);
            }
            else
            {
               _loc2_();
            }
         }
      }
      
      public static function checkAndOpenMasteryPopup(param1:Boolean) : void
      {
         if(myActivePet && myActivePet.masteryCounter >= 100 && param1)
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
         var _loc9_:Array = null;
         var _loc7_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 2;
         var _loc10_:String = param1[_loc6_++];
         if(_loc10_ == "1")
         {
            _loc7_ = param1[_loc6_++];
            _loc3_ = int(param1[_loc6_++]);
            _loc9_ = [];
            _loc8_ = -1;
            _loc5_ = 0;
            while(_loc5_ < _loc3_)
            {
               _loc4_ = {
                  "idx":int(param1[_loc6_++]),
                  "name":param1[_loc6_++],
                  "isGround":isGround(param1[_loc6_++]),
                  "lBits":uint(param1[_loc6_++]),
                  "uBits":uint(param1[_loc6_++]),
                  "eBits":uint(param1[_loc6_++]),
                  "masteryCounter":uint(param1[_loc6_++]),
                  "isSparkling":false
               };
               _loc4_.defId = getDefIdFromLBits(_loc4_.lBits);
               _loc4_.type = petTypeForDefId(_loc4_.defId);
               _loc9_.push(_loc4_);
               _loc5_++;
            }
            _loc9_.sortOn("idx",16);
            if(_loc7_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _myPetList = _loc9_;
            }
         }
         if(param2 != null)
         {
            param2(_loc9_,_loc10_);
         }
      }
      
      public static function isGround(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 2 || param1 == 4;
      }
      
      public static function onPetCreateResponse(param1:Array, param2:Function) : void
      {
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:* = undefined;
         var _loc13_:int = 0;
         var _loc4_:* = 0;
         var _loc10_:* = 0;
         var _loc6_:* = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc5_:PetDef = null;
         var _loc14_:Object = null;
         var _loc9_:int = 2;
         if(param1[_loc9_++] == "1")
         {
            _loc7_ = int(param1[_loc9_++]);
            _loc3_ = int(param1[_loc9_++]);
            _loc8_ = UserCurrency.getCurrency(_loc3_);
            if(_loc8_ == null)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc3_);
            }
            UserCurrency.setCurrency(_loc7_,_loc3_);
            if(_loc8_ != _loc7_)
            {
               AJAudio.playShopCachingSound();
            }
            _loc13_ = int(param1[_loc9_++]);
            _loc4_ = uint(param1[_loc9_++]);
            _loc10_ = uint(param1[_loc9_++]);
            _loc6_ = uint(param1[_loc9_++]);
            _loc11_ = param1[_loc9_++];
            _loc12_ = getDefIdFromLBits(_loc4_);
            _loc5_ = getPetDef(_loc12_);
            if(_loc5_)
            {
               _loc14_ = {
                  "idx":_loc13_,
                  "name":_loc11_,
                  "defId":_loc12_,
                  "type":_loc5_.type,
                  "lBits":_loc4_,
                  "uBits":_loc10_,
                  "eBits":_loc6_,
                  "isSparkling":false
               };
               _loc14_.masteryCounter = 0;
               _myPetList.push(_loc14_);
               DenXtCommManager.addPetToDen(_loc14_);
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc5_.type))
               {
                  if(!_loc5_.isMember || Boolean(gMainFrame.userInfo.isMember))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(_loc4_,_loc10_,_loc6_,_loc11_);
                     myActivePetInvId = _loc13_;
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
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
         var _loc3_:AvatarWorldView = null;
         var _loc15_:int = 0;
         var _loc10_:Boolean = false;
         var _loc13_:* = null;
         var _loc16_:UserInfo = null;
         var _loc11_:Object = null;
         var _loc4_:int = 0;
         var _loc12_:int = 0;
         var _loc6_:int = 0;
         var _loc14_:String = null;
         var _loc7_:Object = null;
         var _loc8_:AvatarInfo = null;
         var _loc9_:int = 2;
         var _loc17_:Boolean = param1[_loc9_++] == "1";
         if(_loc17_)
         {
            _loc15_ = int(param1[_loc9_++]);
            _loc3_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc15_);
            if(_loc15_ == gMainFrame.server.userId)
            {
               myActivePetInvId = int(param1[_loc9_++]);
               if(_loc3_)
               {
                  if(myActivePetInvId != 0)
                  {
                     for each(_loc13_ in _myPetList)
                     {
                        if(_loc13_.idx == myActivePetInvId)
                        {
                           _loc3_.setActivePet(_loc13_.lBits,_loc13_.uBits,_loc13_.eBits,_loc13_.name);
                           _loc10_ = true;
                           break;
                        }
                     }
                  }
                  else
                  {
                     _loc3_.setActivePet(0,0,0,"");
                  }
                  _loc16_ = gMainFrame.userInfo.getUserInfoByUserName(_loc3_.userName);
                  for each(var _loc5_:AvatarInfo in _loc16_.avList)
                  {
                     if(_loc5_.perUserAvId == _loc3_.perUserAvId)
                     {
                        if(AvatarManager.roomEnviroType == 0)
                        {
                           _loc5_.landPetInvId = myActivePetInvId;
                        }
                        else
                        {
                           _loc5_.oceanPetInvId = myActivePetInvId;
                        }
                        gMainFrame.userInfo.setUserInfoByUserName(_loc3_.userName,_loc16_);
                        break;
                     }
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  _loc11_ = myActivePet;
                  if(_loc11_)
                  {
                     _loc3_.setActivePet(_loc11_.lBits,_loc11_.uBits,_loc11_.eBits,_loc11_.name);
                     _loc11_.isSparkling = false;
                  }
               }
            }
            else
            {
               _loc4_ = int(param1[_loc9_++]);
               _loc12_ = int(param1[_loc9_++]);
               _loc6_ = int(param1[_loc9_++]);
               _loc14_ = param1[_loc9_++];
               if(_loc3_)
               {
                  _loc3_.setActivePet(_loc4_,_loc12_,_loc12_,_loc14_);
               }
               _loc7_ = null;
               if(_loc4_ != 0)
               {
                  _loc7_ = {
                     "name":_loc14_,
                     "lBits":_loc4_,
                     "uBits":_loc12_,
                     "eBits":_loc6_
                  };
                  _loc7_.defId = PetManager.getDefIdFromLBits(_loc7_.lBits);
                  _loc7_.type = PetManager.petTypeForDefId(_loc7_.defId);
                  _loc7_.isGround = PetManager.isGround(_loc7_.type);
               }
               _loc8_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc3_.userName);
               if(_loc8_)
               {
                  _loc8_.currPet = _loc7_;
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
            param2(_loc17_);
         }
      }
      
      public static function onPetItemsResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:Object = null;
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 2;
         var _loc10_:Boolean = param1[_loc8_++] == "1";
         if(_loc10_)
         {
            UserCurrency.setCurrency(int(param1[_loc8_++]),0);
            AJAudio.playShopCachingSound();
            _loc5_ = myActivePet;
            if(_loc5_ == null)
            {
               trace("ERROR: myActivePet is null");
               return;
            }
            _loc7_ = int(param1[_loc8_++]);
            if(myActivePet.idx != _loc7_)
            {
               trace("ERROR: Invalid pet invId");
               return;
            }
            _loc4_ = int(param1[_loc8_++]);
            _loc9_ = int(param1[_loc8_++]);
            _loc6_ = int(param1[_loc8_++]);
            _loc5_.lBits = _loc4_;
            _loc5_.uBits = _loc9_;
            _loc5_.eBits = _loc6_;
            AvatarManager.playerAvatarWorldView.setActivePet(_loc4_,_loc9_,_loc6_,myActivePetName);
            myActivePetInvId = _loc7_;
            _loc3_ = getDefIdFromLBits(_loc4_);
            DenXtCommManager.reloadPetInDen(_loc7_,petTypeForDefId(_loc3_),_loc4_,_loc9_,_loc6_);
         }
         if(param2 != null)
         {
            param2(_loc10_);
         }
      }
      
      public static function onPetMasteryResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 2;
         var _loc9_:Boolean = param1[_loc7_++] == "1";
         if(_loc9_)
         {
            _loc5_ = int(param1[_loc7_++]);
            _loc6_ = 0;
            while(_loc6_ < _myPetList.length)
            {
               if(_myPetList[_loc6_].idx == _loc5_)
               {
                  _loc3_ = int(param1[_loc7_++]);
                  _loc8_ = int(param1[_loc7_++]);
                  _loc4_ = int(param1[_loc7_++]);
                  _myPetList[_loc6_].lBits = _loc3_;
                  _myPetList[_loc6_].uBits = _loc8_;
                  _myPetList[_loc6_].eBits = _loc4_;
                  DenXtCommManager.reloadPetInDen(_loc5_,_myPetList[_loc6_].type,_loc3_,_loc8_,_loc4_);
                  break;
               }
               _loc6_++;
            }
         }
         DarkenManager.showLoadingSpiral(false);
         if(param2 != null)
         {
            param2(_loc9_);
         }
      }
      
      public static function onPetDismissResponse(param1:Array, param2:Function) : void
      {
         var _loc3_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc4_:int = 0;
         var _loc7_:Boolean = param1[2] == "1";
         var _loc6_:int = int(param1[3]);
         if(_loc7_)
         {
            _loc4_ = 0;
            while(_loc4_ < _myPetList.length)
            {
               if(_myPetList[_loc4_].idx == _loc6_)
               {
                  if(_myActivePetInvId == _myPetList[_loc4_].idx)
                  {
                     _myActivePetInvId = 0;
                     AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,"");
                     _loc5_ = true;
                     AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  }
                  DenXtCommManager.removePetFromDen(_loc6_,_myPetList[_loc4_].type);
                  _myPetList.splice(_loc4_,1);
                  _loc3_ = true;
                  break;
               }
               _loc4_++;
            }
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14786));
         }
         if(param2 != null)
         {
            param2(_loc7_,_loc3_,_loc5_);
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
         var _loc2_:* = null;
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
         var _loc1_:* = null;
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
         if(_petDefs && _petDefs[param1])
         {
            return _petDefs[param1].type;
         }
         return -1;
      }
      
      public static function getPetDef(param1:int) : PetDef
      {
         if(_petDefs)
         {
            return _petDefs[param1];
         }
         return null;
      }
      
      public static function petForPetDefId(param1:int) : Object
      {
         var _loc2_:* = null;
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
         if(param1 == 0)
         {
            return 0;
         }
         if(param1 == 1)
         {
            return Utility.isAir(param2) ? 2 : 0;
         }
         if(param1 == 3 || param1 == 2)
         {
            return 1;
         }
         if(param1 == 4 || param1 == 5)
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
               return 2;
            case "kitten":
               return 1;
            case "puppy":
               return 4;
            case "ducky":
               return 3;
            case "butterfly":
               return 5;
            case "hamster":
               return 6;
            case "bat":
               return 7;
            case "seahorse":
               return 8;
            case "anglerfish":
               return 9;
            case "reindeer":
               return 10;
            case "snake":
               return 11;
            case "jellyfish":
               return 12;
            case "bunny":
               return 13;
            case "hummingbird":
               return 14;
            case "turtle":
               return 15;
            case "monkey":
               return 16;
            case "tarantula":
               return 17;
            case "fox":
               return 18;
            case "owl":
               return 19;
            case "tiger":
               return 20;
            case "arcticwolfpup":
               return 21;
            case "raccoon":
               return 22;
            case "joey":
               return 23;
            case "eaglet":
               return 24;
            case "cheetah":
               return 25;
            case "rhino":
               return 26;
            case "giraffe":
               return 27;
            case "sugarglider":
               return 28;
            case "lionCub":
               return 29;
            case "panda":
               return 30;
            case "polarBearCub":
               return 31;
            case "gecko":
               return 32;
            case "pony":
               return 34;
            case "piglet":
               return 35;
            case "ferret":
               return 36;
            case "elephant":
               return 37;
            case "armadillo":
               return 38;
            case "peacock":
               return 39;
            case "bee":
               return 40;
            case "skunk":
               return 42;
            case "turkey":
               return 43;
            case "penguin":
               return 44;
            case "snowLeopard":
               return 45;
            case "mantis":
               return 46;
            case "ladybug":
               return 47;
            case "cricket":
               return 48;
            case "squirrel":
               return 49;
            case "mouse":
               return 50;
            case "firefly":
               return 51;
            case "lemur":
               return 52;
            case "hippo":
               return 53;
            case "goat":
               return 54;
            default:
               return -1;
         }
      }
      
      public static function petNameForDefId(param1:int) : String
      {
         switch(param1)
         {
            case 2:
               return "frog";
            case 1:
               return "kitten";
            case 4:
               return "puppy";
            case 3:
               return "ducky";
            case 5:
               return "butterfly";
            case 6:
               return "hamster";
            case 7:
               return "bat";
            case 8:
               return "seahorse";
            case 9:
               return "anglerfish";
            case 10:
               return "reindeer";
            case 11:
               return "snake";
            case 12:
               return "jellyfish";
            case 13:
               return "bunny";
            case 14:
               return "hummingbird";
            case 15:
               return "turtle";
            case 16:
               return "monkey";
            case 17:
               return "tarantula";
            case 18:
               return "fox";
            case 19:
               return "owl";
            case 20:
               return "tiger";
            case 21:
               return "arcticwolfpup";
            case 22:
               return "raccoon";
            case 23:
               return "joey";
            case 24:
               return "eaglet";
            case 25:
               return "cheetah";
            case 26:
               return "rhino";
            case 27:
               return "giraffe";
            case 28:
               return "sugarglider";
            case 29:
               return "lionCub";
            case 30:
               return "panda";
            case 31:
               return "polarBearCub";
            case 32:
               return "gecko";
            case 34:
               return "pony";
            case 35:
               return "piglet";
            case 36:
               return "ferret";
            case 37:
               return "elephant";
            case 38:
               return "armadillo";
            case 39:
               return "peacock";
            case 40:
               return "bee";
            case 42:
               return "skunk";
            case 43:
               return "turkey";
            case 44:
               return "penguin";
            case 45:
               return "snowLeopard";
            case 46:
               return "mantis";
            case 47:
               return "ladybug";
            case 48:
               return "cricket";
            case 49:
               return "squirrel";
            case 50:
               return "mouse";
            case 51:
               return "firefly";
            case 52:
               return "lemur";
            case 53:
               return "hippo";
            case 54:
               return "goat";
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
         UserCommXtCommManager.sendPetAction(1,param1);
      }
      
      public static function getPetInventoryMax() : Number
      {
         return Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(338),44);
      }
      
      public static function isPetAvailable(param1:Number) : Boolean
      {
         if(Utility.bitwiseAnd(gMainFrame.userInfo.userVarCache.getUserVarValueById(342),Utility.leftShiftNumbers(param1 - 1)) > 0)
         {
            return true;
         }
         return false;
      }
      
      public static function canCurrAvatarUsePet(param1:int, param2:int) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType == 5)
         {
            _loc3_ = PartyManager.getPartyDef(gMainFrame.clientInfo.secondaryDefId);
            if(_loc3_ != null)
            {
               if(_loc3_.restrictions == 8)
               {
                  _loc4_ = true;
               }
            }
         }
         return canBeUsedInEnviroType(param2,AvatarManager.roomEnviroType) && (_loc4_ ? true : canBeUsedByEnviroTypeFlag(param2,param1));
      }
      
      public static function canPetGoInBothEnviroTypes(param1:int) : Boolean
      {
         if(param1 == 4 || param1 == 5)
         {
            return true;
         }
         return false;
      }
      
      private static function canBeUsedInEnviroType(param1:int, param2:int) : Boolean
      {
         if(param1 == 0 || param1 == 1)
         {
            return param2 == 0;
         }
         if(param1 == 2 || param1 == 3)
         {
            return param2 == 1;
         }
         if(param1 == 4 || param1 == 5)
         {
            return param2 == 0 || param2 == 1;
         }
         return false;
      }
      
      private static function canBeUsedByEnviroTypeFlag(param1:int, param2:int) : Boolean
      {
         if(param1 == 0)
         {
            return !Utility.isAir(param2) && Utility.isLand(param2);
         }
         if(param1 == 1)
         {
            return Utility.isAir(param2) || Utility.isLand(param2);
         }
         if(param1 == 2 || param1 == 3)
         {
            return Utility.isOcean(param2);
         }
         if(param1 == 4)
         {
            return !Utility.isAir(param2) && (Utility.isLand(param2) || Utility.isOcean(param2));
         }
         if(param1 == 5)
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
         var _loc3_:* = null;
         var _loc2_:int = 0;
         for each(_loc3_ in _myPetList)
         {
            _loc2_ = getEnviroTypeByPetType(_loc3_.type,param1);
            if(_loc2_ == 0)
            {
               if(Utility.isSameEnviroType(param1,_loc2_) && !Utility.isAir(param1))
               {
                  return true;
               }
            }
            else if(Utility.isSameEnviroType(param1,_loc2_))
            {
               return true;
            }
         }
         return false;
      }
      
      public static function createRandomPet(param1:int) : Array
      {
         var _loc6_:int = Math.random() * 19;
         var _loc4_:int = Math.random() * 19;
         var _loc5_:int = 0;
         var _loc2_:int = Math.random() * 5;
         var _loc3_:int = Math.random() * 3;
         var _loc8_:int = Math.random() * 3;
         var _loc9_:int = Math.random() * 3;
         var _loc7_:int = 0;
         return [param1,_loc6_,_loc4_,_loc5_,_loc2_,_loc3_,_loc8_,_loc9_,_loc7_,0,0,0,0,0,0];
      }
      
      public static function packPetBits(param1:Array) : Array
      {
         var _loc2_:uint = uint(param1[5] << 28 | param1[4] << 24 | param1[3] << 19 | param1[2] << 14 | param1[1] << 8 | param1[0]);
         var _loc4_:uint = uint(param1[11] << 20 | param1[10] << 16 | param1[9] << 12 | param1[8] << 8 | param1[7] << 4 | param1[6]);
         var _loc3_:uint = 0;
         return [_loc2_,_loc4_,_loc3_];
      }
      
      public static function unpackPetBits(param1:uint, param2:uint, param3:uint) : Array
      {
         var _loc9_:int = param1 & 0xFF;
         var _loc15_:int = param1 >> 8 & 0x3F;
         var _loc12_:int = param1 >> 14 & 0x1F;
         var _loc13_:int = param1 >> 19 & 0x1F;
         var _loc10_:int = param1 >> 24 & 0x0F;
         var _loc11_:int = param1 >> 28 & 0x0F;
         var _loc7_:int = param2 & 0x0F;
         var _loc8_:int = param2 >> 4 & 0x0F;
         var _loc5_:int = param2 >> 8 & 0x0F;
         var _loc6_:int = param2 >> 12 & 0x0F;
         var _loc16_:int = param2 >> 16 & 0x0F;
         var _loc17_:int = param2 >> 20 & 0x0F;
         var _loc18_:int = param3 & 0x0F;
         var _loc14_:int = param3 >> 4 & 0x0F;
         var _loc4_:int = param3 >> 8 & 0x0F;
         return [_loc9_,_loc15_,_loc12_,_loc13_,_loc10_,_loc11_,_loc7_,_loc8_,_loc5_,_loc6_,_loc16_,_loc17_,_loc18_,_loc14_,_loc4_];
      }
   }
}

