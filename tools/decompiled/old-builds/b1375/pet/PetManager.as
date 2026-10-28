package pet
{
   import Party.PartyManager;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarWorldView;
   import avatar.UserCommXtCommManager;
   import avatar.UserInfo;
   import collection.PetItemCollection;
   import com.sbi.bit.ScalableBitField;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenXtCommManager;
   import diamond.DiamondXtCommManager;
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
      
      private static var _unlockedPets:ScalableBitField;
      
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
                  "createdTs":Number(param1[_loc9_++]),
                  "name":param1[_loc9_++],
                  "isGround":isGround(param1[_loc9_++]),
                  "lBits":uint(param1[_loc9_++]),
                  "uBits":uint(param1[_loc9_++]),
                  "eBits":uint(param1[_loc9_++]),
                  "masteryCounter":uint(param1[_loc9_++]),
                  "isSparkling":false,
                  "personalityDefId":uint(param1[_loc9_++]),
                  "favoriteToyDefId":uint(param1[_loc9_++]),
                  "favoriteFoodDefId":uint(param1[_loc9_++])
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
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:* = undefined;
         var _loc16_:int = 0;
         var _loc3_:* = 0;
         var _loc10_:* = 0;
         var _loc11_:* = 0;
         var _loc12_:String = null;
         var _loc5_:Number = NaN;
         var _loc14_:* = 0;
         var _loc4_:* = 0;
         var _loc15_:* = 0;
         var _loc13_:int = 0;
         var _loc8_:int = 2;
         if(param1[_loc8_++] == "1")
         {
            _loc7_ = int(param1[_loc8_++]);
            _loc9_ = int(param1[_loc8_++]);
            _loc6_ = UserCurrency.getCurrency(_loc9_);
            if(_loc6_ == null)
            {
               throw new Error("ItemManager: Received unknown currencyType: " + _loc9_);
            }
            UserCurrency.setCurrency(_loc7_,_loc9_);
            if(_loc6_ != _loc7_)
            {
               AJAudio.playShopCachingSound();
            }
            _loc16_ = int(param1[_loc8_++]);
            _loc3_ = uint(param1[_loc8_++]);
            _loc10_ = uint(param1[_loc8_++]);
            _loc11_ = uint(param1[_loc8_++]);
            _loc12_ = param1[_loc8_++];
            _loc5_ = Number(param1[_loc8_++]);
            _loc14_ = uint(param1[_loc8_++]);
            _loc4_ = uint(param1[_loc8_++]);
            _loc15_ = uint(param1[_loc8_++]);
            _loc13_ = getDefIdFromLBits(_loc3_);
            if(insertPet(_loc13_,_loc5_,_loc3_,_loc10_,_loc11_,_loc12_,_loc16_,_loc14_,_loc4_,_loc15_,true))
            {
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
      
      public static function insertPet(param1:int, param2:Number, param3:int, param4:int, param5:int, param6:String, param7:int, param8:int, param9:int, param10:int, param11:Boolean) : Boolean
      {
         var _loc12_:Object = null;
         var _loc14_:PetItem = null;
         var _loc13_:PetDef = getPetDef(param1);
         if(_loc13_)
         {
            _loc12_ = {
               "idx":param7,
               "name":param6,
               "defId":param1,
               "type":_loc13_.type,
               "lBits":param3,
               "uBits":param4,
               "eBits":param5,
               "isSparkling":false,
               "personalityDefId":param8,
               "favoriteToyDefId":param9,
               "favoriteFoodDefId":param10,
               "createdTs":param2
            };
            _loc14_ = new PetItem();
            _loc14_.init(param2,param1,[param3,param4,param5],param8,param9,param10,param7,param6);
            _loc12_.masteryCounter = 0;
            _myPetList.push(_loc12_);
            DenXtCommManager.addPetToDen(_loc14_);
            if(param11)
            {
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc13_.type))
               {
                  if(!_loc13_.isMember || Boolean(gMainFrame.userInfo.isMember))
                  {
                     AvatarManager.playerAvatarWorldView.setActivePet(param2,param3,param4,param5,param6,param8,param10,param9);
                     myActivePetInvId = param7;
                  }
               }
               AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
            }
            return true;
         }
         return false;
      }
      
      public static function onPetSwitchResponse(param1:Array, param2:Function) : void
      {
         var _loc17_:AvatarWorldView = null;
         var _loc21_:int = 0;
         var _loc15_:Boolean = false;
         var _loc9_:* = null;
         var _loc3_:UserInfo = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc13_:int = 0;
         var _loc12_:int = 0;
         var _loc11_:String = null;
         var _loc7_:Number = NaN;
         var _loc19_:* = 0;
         var _loc20_:* = 0;
         var _loc6_:* = 0;
         var _loc16_:Object = null;
         var _loc18_:AvatarInfo = null;
         var _loc14_:int = 2;
         var _loc8_:Boolean = param1[_loc14_++] == "1";
         if(_loc8_)
         {
            _loc21_ = int(param1[_loc14_++]);
            _loc17_ = AvatarManager.getAvatarWorldViewBySfsUserId(_loc21_);
            if(_loc21_ == gMainFrame.server.userId)
            {
               myActivePetInvId = int(param1[_loc14_++]);
               if(_loc17_)
               {
                  if(myActivePetInvId != 0)
                  {
                     for each(_loc9_ in _myPetList)
                     {
                        if(_loc9_.idx == myActivePetInvId)
                        {
                           _loc17_.setActivePet(_loc9_.createdTs,_loc9_.lBits,_loc9_.uBits,_loc9_.eBits,_loc9_.name,_loc9_.personalityDefId,_loc9_.favoriteFoodDefId,_loc9_.favoriteToyDefId);
                           _loc15_ = true;
                           break;
                        }
                     }
                  }
                  else
                  {
                     _loc17_.setActivePet(0,0,0,0,"",0,0,0);
                  }
                  _loc3_ = gMainFrame.userInfo.getUserInfoByUserName(_loc17_.userName);
                  for each(var _loc10_:AvatarInfo in _loc3_.avList)
                  {
                     if(_loc10_.perUserAvId == _loc17_.perUserAvId)
                     {
                        if(AvatarManager.roomEnviroType == 0)
                        {
                           _loc10_.landPetInvId = myActivePetInvId;
                        }
                        else
                        {
                           _loc10_.oceanPetInvId = myActivePetInvId;
                        }
                        gMainFrame.userInfo.setUserInfoByUserName(_loc17_.userName,_loc3_);
                        break;
                     }
                  }
                  AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  _loc4_ = myActivePet;
                  if(_loc4_)
                  {
                     _loc17_.setActivePet(_loc4_.createdTs,_loc4_.lBits,_loc4_.uBits,_loc4_.eBits,_loc4_.name,_loc4_.personalityDefId,_loc4_.favoriteFoodDefId,_loc4_.favoriteToyDefId);
                     _loc4_.isSparkling = false;
                  }
               }
            }
            else
            {
               _loc5_ = int(param1[_loc14_++]);
               _loc13_ = int(param1[_loc14_++]);
               _loc12_ = int(param1[_loc14_++]);
               _loc11_ = param1[_loc14_++];
               _loc7_ = Number(param1[_loc14_++]);
               _loc19_ = uint(param1[_loc14_++]);
               _loc20_ = uint(param1[_loc14_++]);
               _loc6_ = uint(param1[_loc14_++]);
               if(_loc17_)
               {
                  _loc17_.setActivePet(_loc7_,_loc5_,_loc13_,_loc13_,_loc11_,_loc19_,_loc20_,_loc6_);
               }
               _loc16_ = null;
               if(_loc5_ != 0)
               {
                  _loc16_ = {
                     "name":_loc11_,
                     "lBits":_loc5_,
                     "uBits":_loc13_,
                     "eBits":_loc12_,
                     "createdTs":_loc7_,
                     "personalityDefId":_loc19_,
                     "favoriteFoodDefId":_loc20_,
                     "favoriteToyDefId":_loc6_
                  };
                  _loc16_.defId = PetManager.getDefIdFromLBits(_loc16_.lBits);
                  _loc16_.type = PetManager.petTypeForDefId(_loc16_.defId);
                  _loc16_.isGround = PetManager.isGround(_loc16_.type);
               }
               _loc18_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc17_.userName);
               if(_loc18_)
               {
                  _loc18_.currPet = _loc16_;
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
            param2(_loc8_);
         }
      }
      
      public static function onPetItemsResponse(param1:Array, param2:Function) : void
      {
         var _loc4_:Object = null;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc10_:int = 2;
         var _loc6_:Boolean = param1[_loc10_++] == "1";
         if(_loc6_)
         {
            UserCurrency.setCurrency(int(param1[_loc10_++]),0);
            AJAudio.playShopCachingSound();
            _loc4_ = myActivePet;
            if(_loc4_ == null)
            {
               trace("ERROR: myActivePet is null");
               return;
            }
            _loc7_ = int(param1[_loc10_++]);
            if(myActivePet.idx != _loc7_)
            {
               trace("ERROR: Invalid pet invId");
               return;
            }
            _loc3_ = int(param1[_loc10_++]);
            _loc9_ = int(param1[_loc10_++]);
            _loc8_ = int(param1[_loc10_++]);
            _loc4_.lBits = _loc3_;
            _loc4_.uBits = _loc9_;
            _loc4_.eBits = _loc8_;
            AvatarManager.playerAvatarWorldView.setActivePet(_loc4_.createdTs,_loc3_,_loc9_,_loc8_,myActivePetName,_loc4_.personalityDefId,_loc4_.favoriteFoodDefId,_loc4_.favoriteToyDefId);
            myActivePetInvId = _loc7_;
            _loc5_ = getDefIdFromLBits(_loc3_);
            DenXtCommManager.reloadPetInDen(_loc7_,_loc4_.createdTs,petTypeForDefId(_loc5_),_loc3_,_loc9_,_loc8_,_loc4_.personalityDefId,_loc4_.favoriteFoodDefId,_loc4_.favoriteToyDefId);
         }
         if(param2 != null)
         {
            param2(_loc6_);
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
                  DenXtCommManager.reloadPetInDen(_loc5_,_myPetList[_loc9_].createdTs,_myPetList[_loc9_].type,_loc3_,_loc7_,_loc6_,_myPetList[_loc9_].personalityDefId,_myPetList[_loc9_].favoriteFoodDefId,_myPetList[_loc9_].favoriteToyDefId);
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
         var _loc6_:Object = null;
         var _loc4_:Boolean = param1[2] == "1";
         var _loc7_:int = int(param1[3]);
         if(_loc4_)
         {
            _loc6_ = removePetInvIdx([_loc7_]);
            _loc3_ = Boolean(_loc6_.isFound);
            _loc5_ = Boolean(_loc6_.wasActivePet);
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
      
      public static function removePetInvIdx(param1:Array) : Object
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = 0;
            while(_loc5_ < _myPetList.length)
            {
               if(_myPetList[_loc5_].idx == param1[_loc4_])
               {
                  if(_myActivePetInvId == _myPetList[_loc5_].idx)
                  {
                     _myActivePetInvId = 0;
                     if(AvatarManager.playerAvatarWorldView)
                     {
                        AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,0,"",0,0,0);
                     }
                     _loc3_ = true;
                     AvatarManager.setPetAction(AvatarManager.playerSfsUserId,1,0);
                  }
                  DenXtCommManager.removePetFromDen(param1[_loc4_],_myPetList[_loc5_].type);
                  _myPetList.splice(_loc5_,1);
                  _loc2_ = true;
               }
               _loc5_++;
            }
            _loc4_++;
         }
         return {
            "wasActivePet":_loc3_,
            "isFound":_loc2_
         };
      }
      
      public static function getPetSprite(param1:uint, param2:uint, param3:uint, param4:int, param5:Function = null) : Sprite
      {
         return Sprite(new PetBase(param1,param2,param3,0,0,0,param5));
      }
      
      public static function getGuiPet(param1:Number, param2:int, param3:uint, param4:uint, param5:uint, param6:int, param7:String, param8:int, param9:int, param10:int, param11:Function = null) : GuiPet
      {
         return new GuiPet(param1,param2,param3,param4,param5,param6,param7,param8,param10,param9,param11);
      }
      
      public static function get myPetList() : Array
      {
         return _myPetList;
      }
      
      public static function get myPetListAsIitem() : PetItemCollection
      {
         var _loc3_:PetItem = null;
         var _loc2_:PetItemCollection = new PetItemCollection();
         for each(var _loc1_:Object in _myPetList)
         {
            _loc3_ = new PetItem();
            _loc3_.init(_loc1_.createdTs,_loc1_.defId,[_loc1_.lBits,_loc1_.uBits,_loc1_.eBits],_loc1_.personalityDefId,_loc1_.favoriteToyDefId,_loc1_.favoriteFoodDefId,_loc1_.idx,_loc1_.name,false,0,null,DiamondXtCommManager.getDiamondItem(DiamondXtCommManager.getDiamondDefIdByRefId(_loc1_.defId,2)));
            _loc2_.pushPetItem(_loc3_);
         }
         return _loc2_;
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
         DebugUtility.debugErrorTracking("setPetState with petMC=" + param1 + "lBits=" + param2 + "uBits=" + param3 + "eBits=" + param4 + "AvatarManager.roomEnviroType=" + AvatarManager.roomEnviroType);
         if(PetManager.petTypeForDefId(_loc5_) == 4)
         {
            param1.pet.setState(param2,param3,param4,AvatarManager.roomEnviroType);
         }
         else
         {
            param1.pet.setState(param2,param3);
         }
         DebugUtility.clearDebugErrorTracking();
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
            case "meerkat":
               return 55;
            case "goldenbunny":
               return 56;
            case "phantom":
               return 57;
            case "seal":
               return 58;
            case "otter":
               return 59;
            case "rarephantom":
               return 60;
            case "groundhog":
               return 61;
            case "llama":
               return 62;
            case "arcticfox":
               return 63;
            case "rooster":
               return 41;
            case "hyena":
               return 64;
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
            case 55:
               return "meerkat";
            case 56:
               return "goldenbunny";
            case 57:
               return "phantom";
            case 58:
               return "seal";
            case 59:
               return "otter";
            case 60:
               return "rarephantom";
            case 61:
               return "groundhog";
            case 62:
               return "llama";
            case 63:
               return "arcticfox";
            case 41:
               return "rooster";
            case 64:
               return "hyena";
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
         return Math.max(gMainFrame.userInfo.userVarCache.getUserVarValueById(338),56);
      }
      
      public static function set unlockedPets(param1:String) : void
      {
         if(param1 != null && param1.length > 0)
         {
            _unlockedPets = new ScalableBitField(param1);
         }
      }
      
      public static function isPetAvailable(param1:Number) : Boolean
      {
         return _unlockedPets.isBitSet(param1 - 1);
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
               if(_loc3_.restrictions == 4 || _loc3_.restrictions == 8)
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

