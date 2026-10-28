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
      
      private static var _petDefs:Object;
      
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
      
      public static function set petDefs(param1:Object) : void
      {
         _petDefs = param1;
      }
      
      public static function relocalizePetDefs() : void
      {
         for each(var _loc1_:Object in _petDefs)
         {
            _loc1_.title = LocalizationManager.translateIdOnly(_loc1_.titleStrId);
         }
      }
      
      public static function openPetFinder(param1:String = "", param2:Function = null, param3:Boolean = false, param4:Array = null, param5:Object = null, param6:int = 0, param7:int = 0, param8:Boolean = false) : void
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
         var _loc5_:Array = null;
         var _loc8_:String = null;
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:int = 2;
         var _loc6_:String = param1[_loc9_++];
         if(_loc6_ == "1")
         {
            _loc8_ = param1[_loc9_++];
            _loc4_ = int(param1[_loc9_++]);
            _loc5_ = [];
            _loc7_ = -1;
            _loc10_ = 0;
            while(_loc10_ < _loc4_)
            {
               _loc3_ = {
                  "idx":int(param1[_loc9_++]),
                  "name":param1[_loc9_++],
                  "isGround":isGround(param1[_loc9_++]),
                  "lBits":uint(param1[_loc9_++]),
                  "uBits":uint(param1[_loc9_++]),
                  "eBits":uint(param1[_loc9_++]),
                  "masteryCounter":uint(param1[_loc9_++]),
                  "isSparkling":false
               };
               _loc3_.defId = getDefIdFromLBits(_loc3_.lBits);
               _loc3_.type = petTypeForDefId(_loc3_.defId);
               _loc5_.push(_loc3_);
               _loc10_++;
            }
            _loc5_.sortOn("idx",16);
            if(_loc8_.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase())
            {
               _myPetList = _loc5_;
            }
         }
         if(param2 != null)
         {
            param2(_loc5_,_loc6_);
         }
      }
      
      public static function isGround(param1:int) : Boolean
      {
         return param1 == 0 || param1 == 2 || param1 == 4;
      }
      
      public static function onPetCreateResponse(param1:Array, param2:Function) : void
      {
         var _loc8_:int = 0;
         var _loc13_:int = 0;
         var _loc6_:* = undefined;
         var _loc9_:int = 0;
         var _loc3_:* = 0;
         var _loc12_:* = 0;
         var _loc11_:* = 0;
         var _loc10_:String = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc7_:Object = null;
         var _loc14_:int = 2;
         if(param1[_loc14_++] == "1")
         {
            _loc8_ = int(param1[_loc14_++]);
            _loc13_ = int(param1[_loc14_++]);
            _loc6_ = UserCurrency.getCurrency(_loc13_);
            if(_loc6_ == null)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc13_);
            }
            UserCurrency.setCurrency(_loc8_,_loc13_);
            if(_loc6_ != _loc8_)
            {
               AJAudio.playShopCachingSound();
            }
            _loc9_ = int(param1[_loc14_++]);
            _loc3_ = uint(param1[_loc14_++]);
            _loc12_ = uint(param1[_loc14_++]);
            _loc11_ = uint(param1[_loc14_++]);
            _loc10_ = param1[_loc14_++];
            _loc4_ = getDefIdFromLBits(_loc3_);
            _loc5_ = getPetDef(_loc4_);
            if(_loc5_)
            {
               _loc7_ = {
                  "idx":_loc9_,
                  "name":_loc10_,
                  "defId":_loc4_,
                  "type":_loc5_.type,
                  "lBits":_loc3_,
                  "uBits":_loc12_,
                  "eBits":_loc11_,
                  "isSparkling":false
               };
               _loc7_.masteryCounter = 0;
               _myPetList.push(_loc7_);
               DenXtCommManager.addPetToDen(_loc7_);
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc5_.type))
               {
                  if(!_loc5_.isMember || Boolean(gMainFrame.userInfo.isMember))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(_loc3_,_loc12_,_loc11_,_loc10_);
                     myActivePetInvId = _loc9_;
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
         var _loc15_:AvatarWorldView = null;
         var _loc17_:int = 0;
         var _loc13_:Boolean = false;
         var _loc7_:* = null;
         var _loc3_:UserInfo = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:String = null;
         var _loc14_:Object = null;
         var _loc16_:AvatarInfo = null;
         var _loc12_:int = 2;
         var _loc6_:Boolean = param1[_loc12_++] == "1";
         if(_loc6_)
         {
            _loc17_ = int(param1[_loc12_++]);
            _loc15_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc17_);
            if(_loc17_ == gMainFrame.server.userId)
            {
               myActivePetInvId = int(param1[_loc12_++]);
               if(_loc15_)
               {
                  if(myActivePetInvId != 0)
                  {
                     for each(_loc7_ in _myPetList)
                     {
                        if(_loc7_.idx == myActivePetInvId)
                        {
                           _loc15_.setActivePet(_loc7_.lBits,_loc7_.uBits,_loc7_.eBits,_loc7_.name);
                           _loc13_ = true;
                           break;
                        }
                     }
                  }
                  else
                  {
                     _loc15_.setActivePet(0,0,0,"");
                  }
                  _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_loc15_.userName);
                  for each(var _loc8_:AvatarInfo in _loc3_.avList)
                  {
                     if(_loc8_.perUserAvId == _loc15_.perUserAvId)
                     {
                        if(AvatarManager.roomEnviroType == 0)
                        {
                           _loc8_.landPetInvId = myActivePetInvId;
                        }
                        else
                        {
                           _loc8_.oceanPetInvId = myActivePetInvId;
                        }
                        gMainFrame.userInfo.setUserInfoByUserName(_loc15_.userName,_loc3_);
                        break;
                     }
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  _loc4_ = myActivePet;
                  if(_loc4_)
                  {
                     _loc15_.setActivePet(_loc4_.lBits,_loc4_.uBits,_loc4_.eBits,_loc4_.name);
                     _loc4_.isSparkling = false;
                  }
               }
            }
            else
            {
               _loc5_ = int(param1[_loc12_++]);
               _loc11_ = int(param1[_loc12_++]);
               _loc10_ = int(param1[_loc12_++]);
               _loc9_ = param1[_loc12_++];
               if(_loc15_)
               {
                  _loc15_.setActivePet(_loc5_,_loc11_,_loc11_,_loc9_);
               }
               _loc14_ = null;
               if(_loc5_ != 0)
               {
                  _loc14_ = {
                     "name":_loc9_,
                     "lBits":_loc5_,
                     "uBits":_loc11_,
                     "eBits":_loc10_
                  };
                  _loc14_.defId = PetManager.getDefIdFromLBits(_loc14_.lBits);
                  _loc14_.type = PetManager.petTypeForDefId(_loc14_.defId);
                  _loc14_.isGround = PetManager.isGround(_loc14_.type);
               }
               _loc16_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc15_.userName);
               if(_loc16_)
               {
                  _loc16_.currPet = _loc14_;
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
            param2(_loc6_);
         }
      }
      
      public static function onPetItemsResponse(param1:Array, param2:Function) : void
      {
         var _loc4_:Object = null;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 2;
         var _loc5_:Boolean = param1[_loc9_++] == "1";
         if(_loc5_)
         {
            UserCurrency.setCurrency(int(param1[_loc9_++]),0);
            AJAudio.playShopCachingSound();
            _loc4_ = myActivePet;
            if(_loc4_ == null)
            {
               trace("ERROR: myActivePet is null");
               return;
            }
            _loc6_ = int(param1[_loc9_++]);
            if(myActivePet.idx != _loc6_)
            {
               trace("ERROR: Invalid pet invId");
               return;
            }
            _loc3_ = int(param1[_loc9_++]);
            _loc8_ = int(param1[_loc9_++]);
            _loc7_ = int(param1[_loc9_++]);
            _loc4_.lBits = _loc3_;
            _loc4_.uBits = _loc8_;
            _loc4_.eBits = _loc7_;
            AvatarManager.playerAvatarWorldView.setActivePet(_loc3_,_loc8_,_loc7_,myActivePetName);
            myActivePetInvId = _loc6_;
            DenXtCommManager.reloadPetInDen(_loc6_,_loc3_,_loc8_,_loc7_);
         }
         if(param2 != null)
         {
            param2(_loc5_);
         }
      }
      
      public static function onPetMasteryResponse(param1:Array, param2:Function) : void
      {
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 2;
         var _loc4_:Boolean = param1[_loc8_++] == "1";
         if(_loc4_)
         {
            _loc5_ = int(param1[_loc8_++]);
            _loc9_ = 0;
            while(_loc9_ < _myPetList.length)
            {
               if(_myPetList[_loc9_].idx == _loc5_)
               {
                  _loc3_ = int(param1[_loc8_++]);
                  _loc7_ = int(param1[_loc8_++]);
                  _loc6_ = int(param1[_loc8_++]);
                  _myPetList[_loc9_].lBits = _loc3_;
                  _myPetList[_loc9_].uBits = _loc7_;
                  _myPetList[_loc9_].eBits = _loc6_;
                  DenXtCommManager.reloadPetInDen(_loc5_,_loc3_,_loc7_,_loc6_);
                  break;
               }
               _loc9_++;
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
         var _loc5_:Boolean = false;
         var _loc7_:int = 0;
         var _loc4_:Boolean = param1[2] == "1";
         var _loc6_:int = int(param1[3]);
         if(_loc4_)
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
                     _loc5_ = true;
                     AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
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
            param2(_loc4_,_loc3_,_loc5_);
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
         return gMainFrame.userInfo.userVarCache.getUserVarValueById(338);
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
         var _loc2_:* = null;
         var _loc3_:int = 0;
         for each(_loc2_ in _myPetList)
         {
            _loc3_ = getEnviroTypeByPetType(_loc2_.type,param1);
            if(_loc3_ == 0)
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
         var _loc4_:int = Math.random() * 19;
         var _loc3_:int = 0;
         var _loc6_:int = Math.random() * 5;
         var _loc5_:int = Math.random() * 3;
         var _loc8_:int = Math.random() * 3;
         var _loc9_:int = Math.random() * 3;
         var _loc7_:int = 0;
         return [param1,_loc2_,_loc4_,_loc3_,_loc6_,_loc5_,_loc8_,_loc9_,_loc7_,0,0,0,0,0,0];
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
         var _loc10_:int = param1 & 0xFF;
         var _loc11_:int = param1 >> 8 & 0x3F;
         var _loc13_:int = param1 >> 14 & 0x1F;
         var _loc12_:int = param1 >> 19 & 0x1F;
         var _loc16_:int = param1 >> 24 & 0x0F;
         var _loc14_:int = param1 >> 28 & 0x0F;
         var _loc8_:int = param2 & 0x0F;
         var _loc9_:int = param2 >> 4 & 0x0F;
         var _loc6_:int = param2 >> 8 & 0x0F;
         var _loc7_:int = param2 >> 12 & 0x0F;
         var _loc5_:int = param2 >> 16 & 0x0F;
         var _loc4_:int = param2 >> 20 & 0x0F;
         var _loc18_:int = param3 & 0x0F;
         var _loc17_:int = param3 >> 4 & 0x0F;
         var _loc15_:int = param3 >> 8 & 0x0F;
         return [_loc10_,_loc11_,_loc13_,_loc12_,_loc16_,_loc14_,_loc8_,_loc9_,_loc6_,_loc7_,_loc5_,_loc4_,_loc18_,_loc17_,_loc15_];
      }
   }
}

