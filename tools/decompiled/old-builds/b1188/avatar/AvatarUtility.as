package avatar
{
   import achievement.AchievementXtCommManager;
   import diamond.DiamondXtCommManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.GuiManager;
   import gui.SharedAvatarAnimalConstants;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class AvatarUtility
   {
      
      private static var _avatarTypes:Array;
      
      private static var _creationAvatars:Array;
      
      private static var _avatarDefInfo:Array;
      
      private static var _skippedIndexes:Array;
      
      private static var _avtMgrGetAvtByPerUserAvId:Function;
      
      private static var _numViewsLoaded:int;
      
      private static var _numNonMemberAvatars:Function;
      
      private static var _currDiamondAvatarStoreDefs:Array;
      
      private static var _diamondAvatarListData:Array;
      
      public static const AVT_AVAIL_HIDDEN:int = 0;
      
      public static const AVT_AVAIL_ACTIVE:int = 1;
      
      public static const AVT_AVAIL_ENDANGERED:int = 2;
      
      public static const AVT_AVAIL_EXTINCT:int = 3;
      
      public function AvatarUtility()
      {
         super();
      }
      
      public static function init(param1:Function, param2:Function = null, param3:Function = null, param4:Boolean = true) : void
      {
         var _loc5_:Function = null;
         _avtMgrGetAvtByPerUserAvId = param1;
         _numNonMemberAvatars = param2;
         _loc5_ = param4 ? buildCreationAvatarViews : param3;
         GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVATAR_LIST_ID,_loc5_,null,param4);
      }
      
      public static function buildCreationAvatarViews(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:* = 0;
         var _loc5_:int = 0;
         var _loc6_:Avatar = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Item = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc15_:int = 0;
         var _loc16_:Object = null;
         var _loc17_:Array = null;
         var _loc18_:Object = null;
         var _loc19_:int = 0;
         _avatarTypes = [];
         _skippedIndexes = [];
         var _loc4_:int = int(param1.length);
         var _loc12_:int = 0;
         if(_creationAvatars)
         {
            if(_creationAvatars.length > 0)
            {
               _loc15_ = 0;
               while(_loc15_ < _creationAvatars.length)
               {
                  _creationAvatars[_loc15_].destroy();
                  _loc15_++;
               }
            }
         }
         _avatarDefInfo = new Array(_loc4_);
         _creationAvatars = [];
         _loc11_ = 0;
         _loc3_ = 0;
         _loc5_ = 0;
         while(_loc11_ < _loc4_)
         {
            _loc16_ = gMainFrame.userInfo.getAvatarDefByAvType(param1[_loc11_],false);
            if(_loc16_)
            {
               if(isAvatarActive(_loc16_.availability) && (!param2 || param2 && !_loc16_.isMemOnly && !isExtinct(_loc16_.availability) && Utility.isLand(_loc16_.enviroTypeFlag)))
               {
                  _loc7_ = int(param1[_loc11_]);
                  _avatarTypes[_loc5_ - _loc12_] = _loc7_;
                  _avatarDefInfo[_loc5_ - _loc12_] = {
                     "isMemberOnly":_loc16_.isMemOnly,
                     "enviroFlag":_loc16_.enviroTypeFlag,
                     "recycleValue":_loc16_.cost * 0.5,
                     "cost":(_loc16_.status == 2 ? _loc16_.cost * 0.5 : _loc16_.cost),
                     "availability":_loc16_.availability,
                     "status":_loc16_.status,
                     "isDiamond":false,
                     "diamondDefId":-1,
                     "diamondCost":0
                  };
                  _loc6_ = new Avatar();
                  _loc6_.init(0,"",_loc7_,[_loc16_.colorLayer1,_loc16_.colorLayer2,_loc16_.colorLayer3]);
                  _loc13_ = ItemXtCommManager.getItemDef(_loc16_.defEyes);
                  _loc14_ = ItemXtCommManager.getItemDef(_loc16_.defPattern);
                  _loc9_ = new Item();
                  _loc9_.init(1,_loc3_++,0,-1,-1);
                  _loc6_.inventoryBodyMod.addItem(_loc9_);
                  _loc6_.accStateShowAccessory(_loc9_);
                  _loc9_ = new Item();
                  _loc9_.init(_loc13_.defId,_loc3_++,_loc13_.colors,-1,-1);
                  _loc6_.inventoryBodyMod.addItem(_loc9_);
                  _loc6_.accStateShowAccessory(_loc9_);
                  if(_loc14_)
                  {
                     _loc9_ = new Item();
                     _loc9_.init(_loc14_.defId,_loc3_++,_loc14_.colors,-1,-1);
                     _loc6_.inventoryBodyMod.addItem(_loc9_);
                     _loc6_.accStateShowAccessory(_loc9_);
                  }
                  _creationAvatars.push(_loc6_);
                  _skippedIndexes[_loc11_] = false;
                  if(!param2)
                  {
                     _loc17_ = gMainFrame.userInfo.getAllCustomAvatarDefsByAvType(param1[_loc11_]);
                     _loc18_ = null;
                     _loc19_ = 0;
                     while(_loc19_ < _loc17_.length)
                     {
                        _loc18_ = _loc17_[_loc19_];
                        if(_loc18_)
                        {
                           _loc6_ = new Avatar();
                           _loc6_.init(0,"",_loc7_,[_loc16_.colorLayer1,_loc16_.colorLayer2,_loc16_.colorLayer3],_loc18_.id);
                           _loc13_ = ItemXtCommManager.getItemDef(_loc16_.defEyes);
                           _loc14_ = ItemXtCommManager.getItemDef(_loc18_.patternRefId);
                           _loc9_ = new Item();
                           _loc9_.init(1,_loc3_++,0,-1,-1);
                           _loc6_.inventoryBodyMod.addItem(_loc9_);
                           _loc6_.accStateShowAccessory(_loc9_);
                           _loc9_ = new Item();
                           _loc9_.init(_loc13_.defId,_loc3_++,_loc13_.colors,-1,-1);
                           _loc6_.inventoryBodyMod.addItem(_loc9_);
                           _loc6_.accStateShowAccessory(_loc9_);
                           if(_loc14_)
                           {
                              _loc9_ = new Item();
                              _loc9_.init(_loc14_.defId,_loc3_++,_loc14_.colors,-1,-1);
                              _loc6_.inventoryBodyMod.addItem(_loc9_);
                              _loc6_.accStateShowAccessory(_loc9_);
                           }
                           _creationAvatars.push(_loc6_);
                           _loc5_++;
                           _avatarTypes[_loc5_ - _loc12_] = _loc7_;
                           _avatarDefInfo[_loc5_ - _loc12_] = _avatarDefInfo[_loc5_ - 1 - _loc12_];
                        }
                        _loc19_++;
                     }
                  }
               }
               else
               {
                  _skippedIndexes[_loc11_] = true;
                  _loc12_++;
               }
            }
            _loc5_++;
            _loc11_++;
         }
         if(!param2)
         {
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.CURR_SHOP_DIAMOND_AVATAR_LIST,onCurrDiamondAvatarStoreList,null,true);
            GenericListXtCommManager.requestGenericList(GenericListXtCommManager.DIAMOND_AVATAR_LIST_ID,onDiamondAvatarListLoaded,null,true);
         }
      }
      
      private static function onCurrDiamondAvatarStoreList(param1:int, param2:Array) : void
      {
         _currDiamondAvatarStoreDefs = param2.slice(6);
         if(_diamondAvatarListData != null)
         {
            onDiamondAvatarListLoaded(GenericListXtCommManager.DIAMOND_AVATAR_LIST_ID,_diamondAvatarListData);
         }
      }
      
      private static function onDiamondAvatarListLoaded(param1:int, param2:Array) : void
      {
         var j:int = 0;
         var numItems:int = 0;
         var diamondItem:Object = null;
         var avt:Avatar = null;
         var avatarDef:Object = null;
         var i:int = 0;
         var glId:int = param1;
         var cad:Array = param2;
         if(_currDiamondAvatarStoreDefs != null)
         {
            j = 6;
            numItems = int(cad[j++]);
            i = 0;
            while(i < numItems)
            {
               diamondItem = DiamondXtCommManager.getDiamondItem(int(cad[j++]));
               if(Boolean(diamondItem) && Boolean(diamondItem.isAvatar))
               {
                  avt = AvatarUtility._creationAvatars[AvatarUtility.findAvatarIndexByType(diamondItem.refDefId,-1)];
                  if(Boolean(avt) && Boolean(getAvatarDefIsViewable(avt,avt.customAvId != -1)) || _currDiamondAvatarStoreDefs.some(function isSame(param1:*, param2:int, param3:Array):Boolean
                  {
                     return int(param1) == diamondItem.defId;
                  }))
                  {
                     avatarDef = _avatarDefInfo[findAvDefIndexByType(avt.avTypeId)];
                     avatarDef.isDiamond = true;
                     avatarDef.diamondCost = diamondItem.value;
                     avatarDef.diamondDefId = diamondItem.defId;
                  }
               }
               i++;
            }
         }
         else
         {
            _diamondAvatarListData = cad;
         }
      }
      
      public static function getAvatarDefIsViewable(param1:Avatar, param2:Boolean = false) : Boolean
      {
         var _loc3_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(param2 ? AchievementXtCommManager.UV_CUSTOM_AVT_VIEWABLE_FLAG : AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG));
         var _loc4_:int = param2 ? param1.customAvId : param1.avTypeId;
         return Utility.areTwoAndedNumbersEqual(_loc3_,Utility.leftShiftNumbers(_loc4_ - 1));
      }
      
      public static function getAvatarDefIsViewableWithAvId(param1:int, param2:Boolean = false) : Boolean
      {
         var _loc3_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(param2 ? AchievementXtCommManager.UV_CUSTOM_AVT_VIEWABLE_FLAG : AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG));
         return Utility.areTwoAndedNumbersEqual(_loc3_,Utility.leftShiftNumbers(param1 - 1));
      }
      
      public static function generateNew(param1:int, param2:Avatar = null, param3:String = null, param4:int = -1, param5:int = 0, param6:Function = null) : Avatar
      {
         var _loc8_:AvatarInfo = null;
         var _loc7_:Avatar = null;
         if(param2 == null && _avtMgrGetAvtByPerUserAvId != null)
         {
            _loc7_ = _avtMgrGetAvtByPerUserAvId(param3,param1);
         }
         if(!_loc7_)
         {
            if(param2)
            {
               _loc7_ = param2;
            }
            else
            {
               _loc7_ = new Avatar();
            }
            if(_loc7_.userName == null)
            {
               if(param3 == null)
               {
                  throw new Error("avt and paramUserName are both null!!!");
               }
               _loc7_.userName = param3;
            }
            _loc8_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param3,param1);
            if((Boolean(_loc8_)) && _loc8_.type != -1)
            {
               _loc7_.init(param1,_loc8_.avName,_loc8_.type,_loc8_.colors,_loc8_.customAvId,null,_loc8_.userName,param4,param5);
               getAvatarItemData(_loc7_,param6,_loc8_);
            }
            else
            {
               _loc7_.init(param1,"tempAvt",-1,[0,0,0],-1,null,_loc7_.userName,param4);
               AvatarXtCommManager.requestADForAvatar(param1,true,param6,_loc7_);
            }
         }
         return _loc7_;
      }
      
      public static function getAvatarItemData(param1:Avatar, param2:Function = null, param3:AvatarInfo = null) : void
      {
         if(param1 == null || param1.perUserAvId < 0)
         {
            throw new Error("Invalid avatar!");
         }
         if(param3 == null)
         {
            param3 = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param1.userName,param1.perUserAvId);
            if(param3 == null)
            {
               throw new Error("Invalid avatar or avInfo!");
            }
         }
         var _loc4_:Array = param3.getItems(true);
         if((Boolean(_loc4_)) && _loc4_.length > 0)
         {
            param1.itemResponseIntegrate(_loc4_);
         }
         else if(param1.avTypeId > 0)
         {
            ItemXtCommManager.requestItemListForAvatar(null,param1,param1.userName.toLowerCase() == gMainFrame.userInfo.myUserName.toLowerCase() ? !ItemXtCommManager.hasRequestedFullItemList : false);
         }
         else
         {
            AvatarXtCommManager.requestADForAvatar(param1.perUserAvId,true,param2,param1);
         }
      }
      
      public static function layerArrayForItemsAndColors(param1:Array, param2:Array, param3:int) : Array
      {
         var _loc4_:Object = null;
         var _loc5_:uint = 0;
         var _loc7_:Item = null;
         var _loc6_:Array = [];
         for each(_loc7_ in param1)
         {
            if(_loc7_.getInUse(param3))
            {
               if(_loc7_.layerId == SbiConstants.LAYER_BASE_ID)
               {
                  _loc5_ = uint(param2[0]);
               }
               else if(_loc7_.layerId == SbiConstants.LAYER_PATTERN_ID)
               {
                  _loc5_ = uint(param2[1]);
               }
               else if(_loc7_.layerId == SbiConstants.LAYER_EYE_ID)
               {
                  _loc5_ = uint(param2[2]);
               }
               else
               {
                  _loc5_ = _loc7_.color;
               }
               _loc4_ = {
                  "l":_loc7_.accId,
                  "c":_loc5_
               };
               _loc6_.push(_loc4_);
            }
         }
         return _loc6_;
      }
      
      public static function findAvDefIndexByType(param1:int) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < _avatarTypes.length)
         {
            if(Boolean(_avatarTypes[_loc2_]) && _avatarTypes[_loc2_] == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public static function getAvatarByIndex(param1:int) : Avatar
      {
         return _creationAvatars[param1];
      }
      
      public static function getAvatarDefByIndex(param1:int) : Object
      {
         if(_avatarDefInfo)
         {
            return _avatarDefInfo[param1];
         }
         return null;
      }
      
      public static function getAvatarTypeByIndex(param1:int) : int
      {
         if(_avatarTypes)
         {
            return _avatarTypes[param1];
         }
         return -1;
      }
      
      public static function get numAvatarDefs() : int
      {
         if(_avatarDefInfo)
         {
            return _avatarDefInfo.length;
         }
         return 0;
      }
      
      public static function get numAvatarTypes() : int
      {
         if(_avatarTypes)
         {
            return _avatarTypes.length;
         }
         return 0;
      }
      
      public static function get creationAvatarsList() : Array
      {
         return _creationAvatars;
      }
      
      public static function findCreationAvatarByType(param1:int, param2:int) : Avatar
      {
         var _loc3_:int = 0;
         while(_loc3_ < _creationAvatars.length)
         {
            if(Boolean(_creationAvatars[_loc3_]) && Boolean(_creationAvatars[_loc3_].avTypeId == param1) && _creationAvatars[_loc3_].customAvId == param2)
            {
               return _creationAvatars[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public static function findAvatarIndexByType(param1:int, param2:int) : int
      {
         var _loc3_:int = 0;
         while(_loc3_ < _creationAvatars.length)
         {
            if(Boolean(_creationAvatars[_loc3_]) && Boolean(_creationAvatars[_loc3_].avTypeId == param1) && _creationAvatars[_loc3_].customAvId == param2)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public static function findAvDefByType(param1:int, param2:int) : Object
      {
         var _loc3_:int = findAvatarIndexByType(param1,param2);
         if(_loc3_ != -1)
         {
            return _avatarDefInfo[_loc3_];
         }
         return null;
      }
      
      public static function numNonMemberAvatars() : int
      {
         if(_numNonMemberAvatars != null)
         {
            return _numNonMemberAvatars();
         }
         return 0;
      }
      
      private static function nameTypeScreenMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      public static function getAvatarHudPosition(param1:int) : Point
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               _loc2_ = 228;
               _loc3_ = 220;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               _loc2_ = 213;
               _loc3_ = 318;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               _loc2_ = 226;
               _loc3_ = 217;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               _loc2_ = 228;
               _loc3_ = 220;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               _loc2_ = 225;
               _loc3_ = 215;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               _loc2_ = 228;
               _loc3_ = 216;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               _loc2_ = 231;
               _loc3_ = 216;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               _loc2_ = 230;
               _loc3_ = 216;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               _loc2_ = 222;
               _loc3_ = 216;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               _loc2_ = 230;
               _loc3_ = 216;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               _loc2_ = 222;
               _loc3_ = 213;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               _loc2_ = 216;
               _loc3_ = 250;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               _loc2_ = 222;
               _loc3_ = 245;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               _loc2_ = 232;
               _loc3_ = 216;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               _loc2_ = 232;
               _loc3_ = 220;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               _loc2_ = 225;
               _loc3_ = 237;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               _loc2_ = 223;
               _loc3_ = 217;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               _loc2_ = 221;
               _loc3_ = 249;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               _loc2_ = 220;
               _loc3_ = 215;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               _loc2_ = 216;
               _loc3_ = 218;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               _loc2_ = 222;
               _loc3_ = 222;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_ = 220;
               _loc3_ = 223;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_ = 220;
               _loc3_ = 212;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               _loc2_ = 220;
               _loc3_ = 215;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_ = 220;
               _loc3_ = 212;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               _loc2_ = 225;
               _loc3_ = 220;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               _loc2_ = 225;
               _loc3_ = 220;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               _loc2_ = 227;
               _loc3_ = 220;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               _loc2_ = 221;
               _loc3_ = 218;
               break;
            case SharedAvatarAnimalConstants.AV_OWL:
               _loc2_ = 221;
               _loc3_ = 218;
               break;
            default:
               _loc2_ = 225;
               _loc3_ = 200;
         }
         return new Point(_loc2_,_loc3_);
      }
      
      public static function getAvatarViewPosition(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               _loc2_.x = 137;
               _loc2_.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               _loc2_.x = 120;
               _loc2_.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               _loc2_.x = 136;
               _loc2_.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               _loc2_.x = 133;
               _loc2_.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               _loc2_.x = 131;
               _loc2_.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               _loc2_.x = 136;
               _loc2_.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               _loc2_.x = 140;
               _loc2_.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               _loc2_.x = 125;
               _loc2_.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               _loc2_.x = 127;
               _loc2_.y = 130;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               _loc2_.x = 134;
               _loc2_.y = 80;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               _loc2_.x = 131;
               _loc2_.y = 75;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               _loc2_.x = 125;
               _loc2_.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               _loc2_.x = 127;
               _loc2_.y = 120;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               _loc2_.x = 140;
               _loc2_.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               _loc2_.x = 130;
               _loc2_.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               _loc2_.x = 125;
               _loc2_.y = 117;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               _loc2_.x = 129;
               _loc2_.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               _loc2_.x = 128;
               _loc2_.y = 95;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               _loc2_.x = 124;
               _loc2_.y = 110;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               _loc2_.x = 123;
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               _loc2_.x = 129;
               _loc2_.y = 99;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = 127;
               _loc2_.y = 110;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               _loc2_.x = 130;
               _loc2_.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               _loc2_.x = 140;
               _loc2_.y = 100;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               _loc2_.x = 134;
               _loc2_.y = 97;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               _loc2_.x = 130;
               _loc2_.y = 97;
               break;
            case SharedAvatarAnimalConstants.AV_OWL:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            default:
               _loc2_.x = 112;
               _loc2_.y = 140;
         }
         return _loc2_;
      }
      
      public static function getAvatarChatOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         if(GuiManager.isBeYourPetRoom())
         {
            if(AvatarManager.playerAvatarWorldView)
            {
               _loc2_.x = 10;
               _loc2_.y = -80;
            }
            else
            {
               _loc2_.x = 10;
               _loc2_.y = -90;
            }
         }
         else
         {
            switch(param1)
            {
               case SharedAvatarAnimalConstants.AV_TIGER:
                  _loc2_.x = 10;
                  _loc2_.y = -70;
                  break;
               case SharedAvatarAnimalConstants.AV_EAGLE:
                  _loc2_.x = 10;
                  _loc2_.y = -130;
                  break;
               case SharedAvatarAnimalConstants.AV_WOLF:
                  _loc2_.x = 5;
                  _loc2_.y = -80;
                  break;
               case SharedAvatarAnimalConstants.AV_KOALA:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_PANDA:
                  _loc2_.x = -15;
                  _loc2_.y = -85;
                  break;
               case SharedAvatarAnimalConstants.AV_MONKEY:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_BUNNY:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_RHINO:
                  _loc2_.x = -10;
                  _loc2_.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_CROC:
                  _loc2_.x = -10;
                  _loc2_.y = -90;
                  break;
               case SharedAvatarAnimalConstants.AV_ELEPHANT:
                  _loc2_.x = -10;
                  _loc2_.y = -105;
                  break;
               case SharedAvatarAnimalConstants.AV_SEAL:
                  _loc2_.x = -15;
                  _loc2_.y = -60;
                  break;
               case SharedAvatarAnimalConstants.AV_DOLPHIN:
                  _loc2_.x = -10;
                  _loc2_.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_SHARK:
                  _loc2_.x = -15;
                  _loc2_.y = -88;
                  break;
               case SharedAvatarAnimalConstants.AV_LION:
                  _loc2_.x = -15;
                  _loc2_.y = -90;
                  break;
               case SharedAvatarAnimalConstants.AV_HORSE:
                  _loc2_.x = -20;
                  _loc2_.y = -104;
                  break;
               case SharedAvatarAnimalConstants.AV_TURTLE:
                  _loc2_.x = -10;
                  _loc2_.y = -75;
                  break;
               case SharedAvatarAnimalConstants.AV_PENGUIN:
                  _loc2_.x = -16;
                  _loc2_.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_OCTOPUS:
                  _loc2_.x = -25;
                  _loc2_.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_GIRAFFE:
                  _loc2_.x = -17;
                  _loc2_.y = -130;
                  break;
               case SharedAvatarAnimalConstants.AV_FOX:
                  _loc2_.x = -17;
                  _loc2_.y = -88;
                  break;
               case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
                  _loc2_.x = -7;
                  _loc2_.y = -113;
                  break;
               case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
                  _loc2_.x = -7;
                  _loc2_.y = -99;
                  break;
               case SharedAvatarAnimalConstants.AV_RACCOON:
                  _loc2_.x = -2;
                  _loc2_.y = -58;
                  break;
               case SharedAvatarAnimalConstants.AV_CHEETAH:
                  _loc2_.x = 0;
                  _loc2_.y = -80;
                  break;
               case SharedAvatarAnimalConstants.AV_KANGAROO:
                  _loc2_.x = -2;
                  _loc2_.y = -95;
                  break;
               case SharedAvatarAnimalConstants.AV_DEER:
                  _loc2_.x = -2;
                  _loc2_.y = -135;
                  break;
               case SharedAvatarAnimalConstants.AV_HYENA:
                  _loc2_.x = -5;
                  _loc2_.y = -85;
                  break;
               case SharedAvatarAnimalConstants.AV_OTTER:
                  _loc2_.x = -10;
                  _loc2_.y = -83;
                  break;
               case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
                  _loc2_.x = -5;
                  _loc2_.y = -100;
                  break;
               case SharedAvatarAnimalConstants.AV_OWL:
                  _loc2_.x = -10;
                  _loc2_.y = -120;
                  break;
               default:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
            }
         }
         return _loc2_;
      }
      
      public static function getAvatarEmoteBgOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         if(GuiManager.isBeYourPetRoom())
         {
            if(AvatarManager.playerAvatarWorldView)
            {
               _loc2_.x = -5;
               _loc2_.y = -25;
            }
            else
            {
               _loc2_.x = -5;
               _loc2_.y = -35;
            }
         }
         else
         {
            switch(param1)
            {
               case SharedAvatarAnimalConstants.AV_TIGER:
                  _loc2_.x = -5;
                  _loc2_.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_EAGLE:
                  _loc2_.x = -5;
                  _loc2_.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_WOLF:
                  _loc2_.x = -5;
                  _loc2_.y = -45;
                  break;
               case SharedAvatarAnimalConstants.AV_KOALA:
                  _loc2_.x = 8;
                  _loc2_.y = -40;
                  break;
               case SharedAvatarAnimalConstants.AV_PANDA:
                  _loc2_.x = 5;
                  _loc2_.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_MONKEY:
                  _loc2_.x = -5;
                  _loc2_.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_BUNNY:
                  _loc2_.x = -5;
                  _loc2_.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_RHINO:
                  _loc2_.x = -10;
                  _loc2_.y = -25;
                  break;
               case SharedAvatarAnimalConstants.AV_CROC:
                  _loc2_.x = 5;
                  _loc2_.y = -15;
                  break;
               case SharedAvatarAnimalConstants.AV_ELEPHANT:
                  _loc2_.x = 5;
                  _loc2_.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_SEAL:
                  _loc2_.x = 0;
                  _loc2_.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_DOLPHIN:
                  _loc2_.x = 0;
                  _loc2_.y = -20;
                  break;
               case SharedAvatarAnimalConstants.AV_SHARK:
                  _loc2_.x = 0;
                  _loc2_.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_LION:
                  _loc2_.x = 0;
                  _loc2_.y = -45;
                  break;
               case SharedAvatarAnimalConstants.AV_HORSE:
                  _loc2_.x = 5;
                  _loc2_.y = -37;
                  break;
               case SharedAvatarAnimalConstants.AV_TURTLE:
               case SharedAvatarAnimalConstants.AV_PENGUIN:
                  _loc2_.x = 0;
                  _loc2_.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_OCTOPUS:
                  _loc2_.x = -5;
                  _loc2_.y = -55;
                  break;
               case SharedAvatarAnimalConstants.AV_GIRAFFE:
                  _loc2_.x = 5;
                  _loc2_.y = -42;
                  break;
               case SharedAvatarAnimalConstants.AV_FOX:
                  _loc2_.x = 10;
                  _loc2_.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
                  _loc2_.x = -1;
                  _loc2_.y = -35;
                  break;
               case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
                  _loc2_.x = -1;
                  _loc2_.y = -15;
                  break;
               case SharedAvatarAnimalConstants.AV_RACCOON:
                  _loc2_.x = -8;
                  _loc2_.y = -24;
                  break;
               case SharedAvatarAnimalConstants.AV_CHEETAH:
                  _loc2_.x = -6;
                  _loc2_.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_KANGAROO:
                  _loc2_.x = -8;
                  _loc2_.y = -28;
                  break;
               case SharedAvatarAnimalConstants.AV_DEER:
                  _loc2_.x = -8;
                  _loc2_.y = -30;
                  break;
               case SharedAvatarAnimalConstants.AV_HYENA:
                  _loc2_.x = -5;
                  _loc2_.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_OTTER:
                  _loc2_.x = -10;
                  _loc2_.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
                  _loc2_.x = -10;
                  _loc2_.y = -33;
                  break;
               case SharedAvatarAnimalConstants.AV_OWL:
                  _loc2_.x = -10;
                  _loc2_.y = -40;
                  break;
               default:
                  _loc2_.x = -5;
                  _loc2_.y = -45;
            }
         }
         return _loc2_;
      }
      
      public static function getAnimalItemWindowOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               _loc2_.x = 123;
               _loc2_.y = 34;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               _loc2_.x = 90;
               _loc2_.y = 135;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               _loc2_.x = 134;
               _loc2_.y = 45;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               _loc2_.x = 127;
               _loc2_.y = 58;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               _loc2_.x = 124;
               _loc2_.y = 50;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               _loc2_.x = 133;
               _loc2_.y = 54;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               _loc2_.x = 138;
               _loc2_.y = 65;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               _loc2_.x = 120;
               _loc2_.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               _loc2_.x = 133;
               _loc2_.y = 85;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               _loc2_.x = 125;
               _loc2_.y = 52;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               _loc2_.x = 127;
               _loc2_.y = 38;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               _loc2_.x = 125;
               _loc2_.y = 75;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               _loc2_.x = 128;
               _loc2_.y = 80;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               _loc2_.x = 135;
               _loc2_.y = 60;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               _loc2_.x = 135;
               _loc2_.y = 75;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               _loc2_.x = 120;
               _loc2_.y = 67;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               _loc2_.x = 127;
               _loc2_.y = 62;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               _loc2_.x = 122;
               _loc2_.y = 62;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               _loc2_.x = 122;
               _loc2_.y = 78;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               _loc2_.x = 127;
               _loc2_.y = 72;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_.x = 114;
               _loc2_.y = 98;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               _loc2_.x = 122;
               _loc2_.y = 70;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = 128;
               _loc2_.y = 65;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               _loc2_.x = 132;
               _loc2_.y = 70;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               _loc2_.x = 145;
               _loc2_.y = 70;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               _loc2_.x = 130;
               _loc2_.y = 68;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               _loc2_.x = 125;
               _loc2_.y = 68;
               break;
            case SharedAvatarAnimalConstants.AV_OWL:
               _loc2_.x = 130;
               _loc2_.y = 77;
               break;
            default:
               _loc2_.x = 120;
               _loc2_.y = 50;
         }
         return _loc2_;
      }
      
      public static function getTalkingHeadOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         var _loc3_:int = param1;
         switch(0)
         {
         }
         _loc2_.x = 112;
         _loc2_.y = 140;
         return _loc2_;
      }
      
      public static function getAvatarPhotoOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               _loc2_.x = -150;
               _loc2_.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               _loc2_.x = -195;
               _loc2_.y = -60;
               break;
            case SharedAvatarAnimalConstants.AV_WOLF:
               _loc2_.x = -155;
               _loc2_.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
               _loc2_.x = -152;
               _loc2_.y = -140;
               break;
            case SharedAvatarAnimalConstants.AV_PANDA:
               _loc2_.x = -130;
               _loc2_.y = -158;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               _loc2_.x = -140;
               _loc2_.y = -175;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               _loc2_.x = -145;
               _loc2_.y = -192;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
               _loc2_.x = -160;
               _loc2_.y = -155;
               break;
            case SharedAvatarAnimalConstants.AV_CROC:
               _loc2_.x = -165;
               _loc2_.y = -125;
               break;
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
               _loc2_.x = -162;
               _loc2_.y = -148;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               _loc2_.x = -107;
               _loc2_.y = -140;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
               _loc2_.x = -155;
               _loc2_.y = -150;
               break;
            case SharedAvatarAnimalConstants.AV_HORSE:
               _loc2_.x = -130;
               _loc2_.y = -185;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               _loc2_.x = -162;
               _loc2_.y = -180;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               _loc2_.x = -140;
               _loc2_.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               _loc2_.x = -165;
               _loc2_.y = -175;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               _loc2_.x = -150;
               _loc2_.y = -165;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_.x = -145;
               _loc2_.y = -180;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_.x = -140;
               _loc2_.y = -165;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               _loc2_.x = -135;
               _loc2_.y = -145;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = -145;
               _loc2_.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
               _loc2_.x = -145;
               _loc2_.y = -160;
               break;
            case SharedAvatarAnimalConstants.AV_HYENA:
               _loc2_.x = -130;
               _loc2_.y = -130;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               _loc2_.x = -125;
               _loc2_.y = -175;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               _loc2_.x = -125;
               _loc2_.y = -155;
               break;
            case SharedAvatarAnimalConstants.AV_OWL:
               _loc2_.x = -135;
               _loc2_.y = -100;
               break;
            default:
               _loc2_.x = -160;
               _loc2_.y = -190;
         }
         return _loc2_;
      }
      
      public static function getAvatarMinigameLobbyOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point(0,0);
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
            case SharedAvatarAnimalConstants.AV_WOLF:
               _loc2_.x = 160;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_EAGLE:
               _loc2_.x = 150;
               _loc2_.y = 220;
               break;
            case SharedAvatarAnimalConstants.AV_KOALA:
            case SharedAvatarAnimalConstants.AV_PANDA:
               _loc2_.x = 158;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_MONKEY:
               _loc2_.x = 157;
               _loc2_.y = 148;
               break;
            case SharedAvatarAnimalConstants.AV_BUNNY:
               _loc2_.x = 162;
               _loc2_.y = 149;
               break;
            case SharedAvatarAnimalConstants.AV_RHINO:
            case SharedAvatarAnimalConstants.AV_ELEPHANT:
            case SharedAvatarAnimalConstants.AV_CROC:
               _loc2_.x = 160;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_TURTLE:
               _loc2_.x = 155;
               _loc2_.y = 165;
               break;
            case SharedAvatarAnimalConstants.AV_SEAL:
               _loc2_.x = 153;
               _loc2_.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_DOLPHIN:
               _loc2_.x = 148;
               _loc2_.y = 173;
               break;
            case SharedAvatarAnimalConstants.AV_SHARK:
               _loc2_.x = 153;
               _loc2_.y = 170;
               break;
            case SharedAvatarAnimalConstants.AV_LION:
            case SharedAvatarAnimalConstants.AV_HORSE:
               _loc2_.x = 162;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_PENGUIN:
               _loc2_.x = 155;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_GIRAFFE:
               _loc2_.x = 155;
               _loc2_.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_FOX:
               _loc2_.x = 153;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_ARCTIC_WOLF:
               _loc2_.x = 155;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_.x = 155;
               _loc2_.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_.x = 152;
               _loc2_.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_CHEETAH:
               _loc2_.x = 154;
               _loc2_.y = 148;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = 152;
               _loc2_.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_DEER:
            case SharedAvatarAnimalConstants.AV_HYENA:
               _loc2_.x = 158;
               _loc2_.y = 155;
               break;
            case SharedAvatarAnimalConstants.AV_OCTOPUS:
               _loc2_.x = 153;
               _loc2_.y = 172;
               break;
            case SharedAvatarAnimalConstants.AV_OTTER:
               _loc2_.x = 159;
               _loc2_.y = 150;
               break;
            case SharedAvatarAnimalConstants.AV_POLAR_BEAR:
               _loc2_.x = 152;
               _loc2_.y = 152;
               break;
            case SharedAvatarAnimalConstants.AV_OWL:
               _loc2_.x = 156;
               _loc2_.y = 156;
               break;
            default:
               _loc2_.x = 160;
               _loc2_.y = 152;
         }
         return _loc2_;
      }
      
      public static function isAvatarActive(param1:int) : Boolean
      {
         if(param1 > AVT_AVAIL_HIDDEN)
         {
            return true;
         }
         return false;
      }
      
      public static function isEndangered(param1:int) : Boolean
      {
         if(param1 == AVT_AVAIL_ENDANGERED)
         {
            return true;
         }
         return false;
      }
      
      public static function isExtinct(param1:int) : Boolean
      {
         if(param1 == AVT_AVAIL_EXTINCT)
         {
            return true;
         }
         return false;
      }
   }
}

