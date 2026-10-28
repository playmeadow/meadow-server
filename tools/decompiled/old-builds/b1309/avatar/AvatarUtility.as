package avatar
{
   import collection.AccItemCollection;
   import diamond.DiamondXtCommManager;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.GuiManager;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class AvatarUtility
   {
      
      public static const AVT_AVAIL_HIDDEN:int = 0;
      
      public static const AVT_AVAIL_ACTIVE:int = 1;
      
      public static const AVT_AVAIL_ENDANGERED:int = 2;
      
      public static const AVT_AVAIL_EXTINCT:int = 3;
      
      private static var _avatarTypes:Array;
      
      private static var _creationAvatars:Array;
      
      private static var _avatarDefInfo:Array;
      
      private static var _skippedIndexes:Array;
      
      private static var _avtMgrGetAvtByPerUserAvId:Function;
      
      private static var _numViewsLoaded:int;
      
      private static var _numNonMemberAvatars:Function;
      
      private static var _currDiamondAvatarStoreDefs:Array;
      
      private static var _diamondAvatarListData:Array;
      
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
         GenericListXtCommManager.requestGenericList(64,_loc5_,null,param4);
      }
      
      public static function buildCreationAvatarViews(param1:Array, param2:Boolean = false) : void
      {
         var _loc11_:int = 0;
         var _loc3_:int = 0;
         var _loc19_:Avatar = null;
         var _loc8_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:Item = null;
         var _loc13_:int = 0;
         var _loc12_:int = 0;
         var _loc14_:Object = null;
         var _loc6_:Object = null;
         var _loc10_:int = 0;
         var _loc5_:Object = null;
         var _loc17_:Array = null;
         var _loc18_:CustomAvatarDef = null;
         var _loc7_:int = 0;
         _avatarTypes = [];
         _skippedIndexes = [];
         var _loc9_:int = int(param1.length);
         var _loc4_:int = 0;
         if(_creationAvatars)
         {
            if(_creationAvatars.length > 0)
            {
               _loc10_ = 0;
               while(_loc10_ < _creationAvatars.length)
               {
                  _creationAvatars[_loc10_].destroy();
                  _loc10_++;
               }
            }
         }
         _avatarDefInfo = new Array(_loc9_);
         _creationAvatars = [];
         _loc12_ = 0;
         _loc11_ = 0;
         _loc3_ = 0;
         while(_loc12_ < _loc9_)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarDefByAvType(param1[_loc12_],false);
            if(_loc5_)
            {
               if(isAvatarActive(_loc5_.availability) && (!param2 || param2 && !_loc5_.isMemOnly && !isExtinct(_loc5_.availability) && Utility.isLand(_loc5_.enviroTypeFlag)))
               {
                  _loc15_ = int(param1[_loc12_]);
                  _avatarTypes[_loc3_ - _loc4_] = _loc15_;
                  _avatarDefInfo[_loc3_ - _loc4_] = {
                     "isMemberOnly":_loc5_.isMemOnly,
                     "enviroFlag":_loc5_.enviroTypeFlag,
                     "recycleValue":Math.ceil(_loc5_.cost * 0.5),
                     "cost":(_loc5_.status == 2 ? Math.ceil(_loc5_.cost * 0.5) : _loc5_.cost),
                     "availability":_loc5_.availability,
                     "status":_loc5_.status,
                     "isDiamond":false,
                     "diamondItem":null,
                     "diamondCost":0
                  };
                  _loc19_ = new Avatar();
                  _loc19_.init(0,"",_loc15_,[_loc5_.colorLayer1,_loc5_.colorLayer2,_loc5_.colorLayer3]);
                  _loc14_ = ItemXtCommManager.getItemDef(_loc5_.defEyes);
                  _loc6_ = ItemXtCommManager.getItemDef(_loc5_.defPattern);
                  _loc16_ = new Item();
                  _loc16_.init(1,_loc11_++,0,-1,-1);
                  _loc19_.inventoryBodyMod.addItem(_loc16_);
                  _loc19_.accStateShowAccessory(_loc16_);
                  _loc16_ = new Item();
                  _loc16_.init(_loc14_.defId,_loc11_++,_loc14_.colors,-1,-1);
                  _loc19_.inventoryBodyMod.addItem(_loc16_);
                  _loc19_.accStateShowAccessory(_loc16_);
                  if(_loc6_)
                  {
                     _loc16_ = new Item();
                     _loc16_.init(_loc6_.defId,_loc11_++,_loc6_.colors,-1,-1);
                     _loc19_.inventoryBodyMod.addItem(_loc16_);
                     _loc19_.accStateShowAccessory(_loc16_);
                  }
                  _creationAvatars.push(_loc19_);
                  _skippedIndexes[_loc12_] = false;
                  if(!param2)
                  {
                     _loc17_ = gMainFrame.userInfo.getAllCustomAvatarDefsByAvType(param1[_loc12_]);
                     _loc18_ = null;
                     _loc7_ = 0;
                     while(_loc7_ < _loc17_.length)
                     {
                        _loc18_ = _loc17_[_loc7_];
                        if(_loc18_)
                        {
                           _loc19_ = new Avatar();
                           _loc19_.init(0,"",_loc15_,[_loc5_.colorLayer1,_loc5_.colorLayer2,_loc5_.colorLayer3],_loc18_.defId);
                           _loc14_ = ItemXtCommManager.getItemDef(_loc5_.defEyes);
                           _loc6_ = ItemXtCommManager.getItemDef(_loc18_.patternRefId);
                           _loc16_ = new Item();
                           _loc16_.init(1,_loc11_++,0,-1,-1);
                           _loc19_.inventoryBodyMod.addItem(_loc16_);
                           _loc19_.accStateShowAccessory(_loc16_);
                           _loc16_ = new Item();
                           _loc16_.init(_loc14_.defId,_loc11_++,_loc14_.colors,-1,-1);
                           _loc19_.inventoryBodyMod.addItem(_loc16_);
                           _loc19_.accStateShowAccessory(_loc16_);
                           if(_loc6_)
                           {
                              _loc16_ = new Item();
                              _loc16_.init(_loc6_.defId,_loc11_++,_loc6_.colors,-1,-1);
                              _loc19_.inventoryBodyMod.addItem(_loc16_);
                              _loc19_.accStateShowAccessory(_loc16_);
                           }
                           _creationAvatars.push(_loc19_);
                           _loc3_++;
                           _avatarTypes[_loc3_ - _loc4_] = _loc15_;
                           _avatarDefInfo[_loc3_ - _loc4_] = _avatarDefInfo[_loc3_ - 1 - _loc4_];
                        }
                        _loc7_++;
                     }
                  }
               }
               else
               {
                  _skippedIndexes[_loc12_] = true;
                  _loc4_++;
               }
            }
            _loc3_++;
            _loc12_++;
         }
         if(!param2)
         {
            GenericListXtCommManager.requestGenericList(166,onCurrDiamondAvatarStoreList,null,true);
            GenericListXtCommManager.requestGenericList(293,onDiamondAvatarListLoaded,null,true);
         }
      }
      
      private static function onCurrDiamondAvatarStoreList(param1:int, param2:Array) : void
      {
         _currDiamondAvatarStoreDefs = param2.slice(6);
         if(_diamondAvatarListData != null)
         {
            onDiamondAvatarListLoaded(293,_diamondAvatarListData);
         }
      }
      
      private static function onDiamondAvatarListLoaded(param1:int, param2:Array) : void
      {
         var j:int;
         var numItems:int;
         var diamondItem:Object;
         var avt:Avatar;
         var avatarDef:Object;
         var i:int;
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
               if(diamondItem && diamondItem.isAvatar)
               {
                  avt = AvatarUtility._creationAvatars[AvatarUtility.findAvatarIndexByType(diamondItem.refDefId,-1)];
                  if(avt && getAvatarDefIsViewable(avt,avt.customAvId != -1) || _currDiamondAvatarStoreDefs.some((function():*
                  {
                     var isSame:Function;
                     return isSame = function(param1:*, param2:int, param3:Array):Boolean
                     {
                        return int(param1) == diamondItem.defId;
                     };
                  })()))
                  {
                     avatarDef = _avatarDefInfo[findAvDefIndexByType(avt.avTypeId)];
                     avatarDef.diamondItem = diamondItem;
                  }
               }
               i = i + 1;
            }
         }
         else
         {
            _diamondAvatarListData = cad;
         }
      }
      
      public static function getAvatarDefIsViewable(param1:Avatar, param2:Boolean = false) : Boolean
      {
         var _loc3_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(param2 ? 410 : 287));
         var _loc4_:int = param2 ? param1.customAvId : param1.avTypeId;
         return Utility.bitwiseAnd(_loc3_,Utility.leftShiftNumbers(_loc4_ - 1)) > 0;
      }
      
      public static function getAvatarDefIsViewableWithAvId(param1:int, param2:Boolean = false) : Boolean
      {
         var _loc3_:Number = Number(gMainFrame.userInfo.userVarCache.getUserVarValueById(param2 ? 410 : 287));
         return Utility.bitwiseAnd(_loc3_,Utility.leftShiftNumbers(param1 - 1)) > 0;
      }
      
      public static function generateNew(param1:int, param2:Avatar = null, param3:String = null, param4:int = -1, param5:int = 0, param6:Function = null) : Avatar
      {
         var _loc7_:AvatarInfo = null;
         var _loc8_:Avatar = null;
         if(param2 == null && _avtMgrGetAvtByPerUserAvId != null)
         {
            _loc8_ = _avtMgrGetAvtByPerUserAvId(param3,param1);
         }
         if(!_loc8_)
         {
            if(param2)
            {
               _loc8_ = param2;
            }
            else
            {
               _loc8_ = new Avatar();
            }
            if(_loc8_.userName == null)
            {
               if(param3 == null)
               {
                  throw new Error("avt and paramUserName are both null!!!");
               }
               _loc8_.userName = param3;
            }
            _loc7_ = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param3,param1);
            if(_loc7_ && _loc7_.type != -1)
            {
               _loc8_.init(param1,_loc7_.avName,_loc7_.type,_loc7_.colors,_loc7_.customAvId,null,_loc7_.userName,param4,param5);
               getAvatarItemData(_loc8_,param6,_loc7_);
            }
            else
            {
               _loc8_.init(param1,"tempAvt",0,[0,0,0],-1,null,_loc8_.userName,param4);
               AvatarXtCommManager.requestADForAvatar(param1,true,param6,_loc8_);
            }
         }
         return _loc8_;
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
         var _loc4_:AccItemCollection = param3.getItems(true);
         if(_loc4_ && _loc4_.length > 0)
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
      
      public static function layerArrayForItemsAndColors(param1:AccItemCollection, param2:Array, param3:int) : Array
      {
         var _loc5_:Object = null;
         var _loc4_:* = 0;
         var _loc6_:Array = [];
         if(param1)
         {
            for each(var _loc7_:Item in param1.getCoreArray())
            {
               if(_loc7_.getInUse(param3))
               {
                  if(_loc7_.layerId == 1)
                  {
                     _loc4_ = uint(param2[0]);
                  }
                  else if(_loc7_.layerId == 2)
                  {
                     _loc4_ = uint(param2[1]);
                  }
                  else if(_loc7_.layerId == 3)
                  {
                     _loc4_ = uint(param2[2]);
                  }
                  else
                  {
                     _loc4_ = _loc7_.color;
                  }
                  _loc5_ = {
                     "l":_loc7_.accId,
                     "c":_loc4_
                  };
                  _loc6_.push(_loc5_);
               }
            }
         }
         return _loc6_;
      }
      
      public static function findAvDefIndexByType(param1:int) : int
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _avatarTypes.length)
         {
            if(_avatarTypes[_loc2_] && _avatarTypes[_loc2_] == param1)
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
         _loc3_ = 0;
         while(_loc3_ < _creationAvatars.length)
         {
            if(_creationAvatars[_loc3_] && _creationAvatars[_loc3_].avTypeId == param1 && _creationAvatars[_loc3_].customAvId == param2)
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
         _loc3_ = 0;
         while(_loc3_ < _creationAvatars.length)
         {
            if(_creationAvatars[_loc3_] && _creationAvatars[_loc3_].avTypeId == param1 && _creationAvatars[_loc3_].customAvId == param2)
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
            case 1:
               _loc3_ = 228;
               _loc2_ = 220;
               break;
            case 2:
               _loc3_ = 213;
               _loc2_ = 318;
               break;
            case 35:
               _loc3_ = 213;
               _loc2_ = 308;
               break;
            case 4:
               _loc3_ = 226;
               _loc2_ = 217;
               break;
            case 5:
               _loc3_ = 228;
               _loc2_ = 220;
               break;
            case 6:
               _loc3_ = 225;
               _loc2_ = 215;
               break;
            case 7:
               _loc3_ = 228;
               _loc2_ = 216;
               break;
            case 8:
               _loc3_ = 231;
               _loc2_ = 216;
               break;
            case 13:
               _loc3_ = 230;
               _loc2_ = 216;
               break;
            case 15:
               _loc3_ = 222;
               _loc2_ = 216;
               break;
            case 16:
               _loc3_ = 230;
               _loc2_ = 216;
               break;
            case 18:
               _loc3_ = 222;
               _loc2_ = 213;
               break;
            case 19:
               _loc3_ = 216;
               _loc2_ = 250;
               break;
            case 20:
               _loc3_ = 222;
               _loc2_ = 245;
               break;
            case 17:
               _loc3_ = 232;
               _loc2_ = 216;
               break;
            case 23:
               _loc3_ = 232;
               _loc2_ = 220;
               break;
            case 22:
               _loc3_ = 225;
               _loc2_ = 237;
               break;
            case 24:
               _loc3_ = 223;
               _loc2_ = 217;
               break;
            case 21:
               _loc3_ = 221;
               _loc2_ = 249;
               break;
            case 26:
               _loc3_ = 220;
               _loc2_ = 215;
               break;
            case 25:
               _loc3_ = 216;
               _loc2_ = 218;
               break;
            case 28:
               _loc3_ = 222;
               _loc2_ = 222;
               break;
            case 29:
               _loc3_ = 220;
               _loc2_ = 223;
               break;
            case 30:
               _loc3_ = 220;
               _loc2_ = 212;
               break;
            case 31:
               _loc3_ = 220;
               _loc2_ = 215;
               break;
            case 27:
               _loc3_ = 220;
               _loc2_ = 212;
               break;
            case 3:
               _loc3_ = 225;
               _loc2_ = 220;
               break;
            case 9:
               _loc3_ = 225;
               _loc2_ = 220;
               break;
            case 10:
               _loc3_ = 227;
               _loc2_ = 220;
               break;
            case 11:
               _loc3_ = 221;
               _loc2_ = 218;
               break;
            case 12:
               _loc3_ = 221;
               _loc2_ = 218;
               break;
            case 14:
               _loc3_ = 221;
               _loc2_ = 215;
               break;
            case 32:
            case 33:
               _loc3_ = 224;
               _loc2_ = 218;
               break;
            case 34:
               _loc3_ = 224;
               _loc2_ = 213;
               break;
            case 36:
               _loc3_ = 224;
               _loc2_ = 220;
               break;
            default:
               _loc3_ = 225;
               _loc2_ = 200;
         }
         return new Point(_loc3_,_loc2_);
      }
      
      public static function getAvatarViewPosition(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         switch(param1)
         {
            case 1:
               _loc2_.x = 137;
               _loc2_.y = 85;
               break;
            case 2:
               _loc2_.x = 120;
               _loc2_.y = 150;
               break;
            case 35:
               _loc2_.x = 120;
               _loc2_.y = 140;
               break;
            case 4:
               _loc2_.x = 136;
               _loc2_.y = 85;
               break;
            case 5:
               _loc2_.x = 133;
               _loc2_.y = 85;
               break;
            case 6:
               _loc2_.x = 131;
               _loc2_.y = 90;
               break;
            case 7:
               _loc2_.x = 136;
               _loc2_.y = 95;
               break;
            case 8:
               _loc2_.x = 140;
               _loc2_.y = 85;
               break;
            case 13:
               _loc2_.x = 125;
               _loc2_.y = 95;
               break;
            case 15:
               _loc2_.x = 127;
               _loc2_.y = 130;
               break;
            case 16:
               _loc2_.x = 134;
               _loc2_.y = 80;
               break;
            case 18:
               _loc2_.x = 131;
               _loc2_.y = 75;
               break;
            case 19:
               _loc2_.x = 125;
               _loc2_.y = 90;
               break;
            case 20:
               _loc2_.x = 127;
               _loc2_.y = 120;
               break;
            case 17:
               _loc2_.x = 140;
               _loc2_.y = 100;
               break;
            case 23:
               _loc2_.x = 130;
               _loc2_.y = 100;
               break;
            case 22:
               _loc2_.x = 125;
               _loc2_.y = 117;
               break;
            case 24:
               _loc2_.x = 129;
               _loc2_.y = 95;
               break;
            case 21:
               _loc2_.x = 128;
               _loc2_.y = 95;
               break;
            case 26:
               _loc2_.x = 124;
               _loc2_.y = 110;
               break;
            case 25:
               _loc2_.x = 123;
               _loc2_.y = 115;
               break;
            case 28:
               _loc2_.x = 129;
               _loc2_.y = 99;
               break;
            case 29:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case 30:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case 31:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case 27:
               _loc2_.x = 127;
               _loc2_.y = 110;
               break;
            case 3:
               _loc2_.x = 130;
               _loc2_.y = 100;
               break;
            case 9:
               _loc2_.x = 140;
               _loc2_.y = 100;
               break;
            case 10:
               _loc2_.x = 134;
               _loc2_.y = 97;
               break;
            case 11:
               _loc2_.x = 130;
               _loc2_.y = 97;
               break;
            case 12:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            case 14:
            case 34:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            case 32:
            case 33:
               _loc2_.x = 130;
               _loc2_.y = 115;
               break;
            case 36:
               _loc2_.x = 125;
               _loc2_.y = 95;
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
               case 1:
                  _loc2_.x = 10;
                  _loc2_.y = -70;
                  break;
               case 2:
                  _loc2_.x = 10;
                  _loc2_.y = -130;
                  break;
               case 35:
                  _loc2_.x = 0;
                  _loc2_.y = -110;
                  break;
               case 4:
                  _loc2_.x = 5;
                  _loc2_.y = -80;
                  break;
               case 5:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
                  break;
               case 6:
                  _loc2_.x = -15;
                  _loc2_.y = -85;
                  break;
               case 7:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
                  break;
               case 8:
                  _loc2_.x = -25;
                  _loc2_.y = -75;
                  break;
               case 13:
                  _loc2_.x = -10;
                  _loc2_.y = -95;
                  break;
               case 15:
                  _loc2_.x = -10;
                  _loc2_.y = -90;
                  break;
               case 16:
                  _loc2_.x = -10;
                  _loc2_.y = -105;
                  break;
               case 18:
                  _loc2_.x = -15;
                  _loc2_.y = -60;
                  break;
               case 19:
                  _loc2_.x = -10;
                  _loc2_.y = -95;
                  break;
               case 20:
                  _loc2_.x = -15;
                  _loc2_.y = -88;
                  break;
               case 17:
                  _loc2_.x = -15;
                  _loc2_.y = -90;
                  break;
               case 23:
                  _loc2_.x = -20;
                  _loc2_.y = -104;
                  break;
               case 22:
                  _loc2_.x = -10;
                  _loc2_.y = -75;
                  break;
               case 24:
                  _loc2_.x = -16;
                  _loc2_.y = -95;
                  break;
               case 21:
                  _loc2_.x = -25;
                  _loc2_.y = -95;
                  break;
               case 26:
                  _loc2_.x = -17;
                  _loc2_.y = -130;
                  break;
               case 25:
                  _loc2_.x = -17;
                  _loc2_.y = -88;
                  break;
               case 28:
                  _loc2_.x = -7;
                  _loc2_.y = -113;
                  break;
               case 29:
                  _loc2_.x = -7;
                  _loc2_.y = -99;
                  break;
               case 30:
                  _loc2_.x = -2;
                  _loc2_.y = -58;
                  break;
               case 31:
                  _loc2_.x = 0;
                  _loc2_.y = -80;
                  break;
               case 27:
                  _loc2_.x = -2;
                  _loc2_.y = -95;
                  break;
               case 3:
                  _loc2_.x = -2;
                  _loc2_.y = -135;
                  break;
               case 9:
                  _loc2_.x = -5;
                  _loc2_.y = -85;
                  break;
               case 10:
                  _loc2_.x = -10;
                  _loc2_.y = -83;
                  break;
               case 11:
                  _loc2_.x = -5;
                  _loc2_.y = -100;
                  break;
               case 12:
                  _loc2_.x = -10;
                  _loc2_.y = -120;
                  break;
               case 14:
                  _loc2_.x = -2;
                  _loc2_.y = -115;
                  break;
               case 32:
               case 33:
               case 34:
                  _loc2_.x = -8;
                  _loc2_.y = -83;
                  break;
               case 36:
                  _loc2_.x = -8;
                  _loc2_.y = -70;
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
               case 1:
                  _loc2_.x = -5;
                  _loc2_.y = -30;
                  break;
               case 2:
                  _loc2_.x = -5;
                  _loc2_.y = -35;
                  break;
               case 35:
                  _loc2_.x = -15;
                  _loc2_.y = -23;
                  break;
               case 4:
                  _loc2_.x = -5;
                  _loc2_.y = -45;
                  break;
               case 5:
                  _loc2_.x = 8;
                  _loc2_.y = -40;
                  break;
               case 6:
                  _loc2_.x = 5;
                  _loc2_.y = -35;
                  break;
               case 7:
                  _loc2_.x = -5;
                  _loc2_.y = -35;
                  break;
               case 8:
                  _loc2_.x = -5;
                  _loc2_.y = -35;
                  break;
               case 13:
                  _loc2_.x = -10;
                  _loc2_.y = -25;
                  break;
               case 15:
                  _loc2_.x = 5;
                  _loc2_.y = -15;
                  break;
               case 16:
                  _loc2_.x = 5;
                  _loc2_.y = -35;
                  break;
               case 18:
                  _loc2_.x = 0;
                  _loc2_.y = -30;
                  break;
               case 19:
                  _loc2_.x = 0;
                  _loc2_.y = -20;
                  break;
               case 20:
                  _loc2_.x = 0;
                  _loc2_.y = -30;
                  break;
               case 17:
                  _loc2_.x = 0;
                  _loc2_.y = -45;
                  break;
               case 23:
                  _loc2_.x = 5;
                  _loc2_.y = -37;
                  break;
               case 22:
               case 24:
                  _loc2_.x = 0;
                  _loc2_.y = -30;
                  break;
               case 21:
                  _loc2_.x = -5;
                  _loc2_.y = -55;
                  break;
               case 26:
                  _loc2_.x = 5;
                  _loc2_.y = -42;
                  break;
               case 25:
                  _loc2_.x = 10;
                  _loc2_.y = -33;
                  break;
               case 28:
                  _loc2_.x = -1;
                  _loc2_.y = -35;
                  break;
               case 29:
                  _loc2_.x = -1;
                  _loc2_.y = -15;
                  break;
               case 30:
                  _loc2_.x = -8;
                  _loc2_.y = -24;
                  break;
               case 31:
                  _loc2_.x = -6;
                  _loc2_.y = -30;
                  break;
               case 27:
                  _loc2_.x = -8;
                  _loc2_.y = -28;
                  break;
               case 3:
                  _loc2_.x = -8;
                  _loc2_.y = -30;
                  break;
               case 9:
                  _loc2_.x = -5;
                  _loc2_.y = -33;
                  break;
               case 10:
                  _loc2_.x = -10;
                  _loc2_.y = -33;
                  break;
               case 11:
                  _loc2_.x = -10;
                  _loc2_.y = -33;
                  break;
               case 12:
                  _loc2_.x = -10;
                  _loc2_.y = -40;
                  break;
               case 14:
                  _loc2_.x = -2;
                  _loc2_.y = -33;
                  break;
               case 32:
               case 33:
               case 34:
                  _loc2_.x = -10;
                  _loc2_.y = -28;
                  break;
               case 36:
                  _loc2_.x = -10;
                  _loc2_.y = -35;
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
            case 1:
               _loc2_.x = 123;
               _loc2_.y = 34;
               break;
            case 2:
               _loc2_.x = 90;
               _loc2_.y = 135;
               break;
            case 35:
               _loc2_.x = 104;
               _loc2_.y = 125;
               break;
            case 4:
               _loc2_.x = 134;
               _loc2_.y = 45;
               break;
            case 5:
               _loc2_.x = 127;
               _loc2_.y = 58;
               break;
            case 6:
               _loc2_.x = 124;
               _loc2_.y = 50;
               break;
            case 7:
               _loc2_.x = 133;
               _loc2_.y = 54;
               break;
            case 8:
               _loc2_.x = 138;
               _loc2_.y = 65;
               break;
            case 13:
               _loc2_.x = 120;
               _loc2_.y = 85;
               break;
            case 15:
               _loc2_.x = 133;
               _loc2_.y = 85;
               break;
            case 16:
               _loc2_.x = 125;
               _loc2_.y = 52;
               break;
            case 18:
               _loc2_.x = 127;
               _loc2_.y = 38;
               break;
            case 19:
               _loc2_.x = 125;
               _loc2_.y = 75;
               break;
            case 20:
               _loc2_.x = 128;
               _loc2_.y = 80;
               break;
            case 17:
               _loc2_.x = 135;
               _loc2_.y = 60;
               break;
            case 23:
               _loc2_.x = 135;
               _loc2_.y = 75;
               break;
            case 22:
               _loc2_.x = 120;
               _loc2_.y = 67;
               break;
            case 24:
               _loc2_.x = 127;
               _loc2_.y = 62;
               break;
            case 21:
            case 36:
               _loc2_.x = 122;
               _loc2_.y = 62;
               break;
            case 26:
               _loc2_.x = 122;
               _loc2_.y = 78;
               break;
            case 25:
            case 10:
               _loc2_.x = 127;
               _loc2_.y = 72;
               break;
            case 28:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            case 29:
               _loc2_.x = 127;
               _loc2_.y = 90;
               break;
            case 30:
               _loc2_.x = 114;
               _loc2_.y = 98;
               break;
            case 31:
               _loc2_.x = 122;
               _loc2_.y = 70;
               break;
            case 27:
               _loc2_.x = 128;
               _loc2_.y = 65;
               break;
            case 3:
               _loc2_.x = 132;
               _loc2_.y = 70;
               break;
            case 9:
               _loc2_.x = 145;
               _loc2_.y = 70;
               break;
            case 11:
               _loc2_.x = 125;
               _loc2_.y = 68;
               break;
            case 12:
               _loc2_.x = 130;
               _loc2_.y = 77;
               break;
            case 14:
            case 34:
               _loc2_.x = 122;
               _loc2_.y = 68;
               break;
            case 32:
            case 33:
               _loc2_.x = 120;
               _loc2_.y = 90;
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
         _loc2_.x = 112;
         _loc2_.y = 140;
         return _loc2_;
      }
      
      public static function getAvatarPhotoOffset(param1:int) : Point
      {
         var _loc2_:Point = new Point();
         switch(param1)
         {
            case 1:
               _loc2_.x = -150;
               _loc2_.y = -160;
               break;
            case 2:
               _loc2_.x = -195;
               _loc2_.y = -60;
               break;
            case 35:
               _loc2_.x = -155;
               _loc2_.y = -95;
               break;
            case 4:
               _loc2_.x = -155;
               _loc2_.y = -190;
               break;
            case 5:
               _loc2_.x = -152;
               _loc2_.y = -140;
               break;
            case 6:
               _loc2_.x = -130;
               _loc2_.y = -158;
               break;
            case 7:
               _loc2_.x = -140;
               _loc2_.y = -175;
               break;
            case 8:
               _loc2_.x = -145;
               _loc2_.y = -192;
               break;
            case 13:
               _loc2_.x = -160;
               _loc2_.y = -155;
               break;
            case 15:
               _loc2_.x = -165;
               _loc2_.y = -125;
               break;
            case 16:
               _loc2_.x = -162;
               _loc2_.y = -148;
               break;
            case 18:
               _loc2_.x = -107;
               _loc2_.y = -140;
               break;
            case 19:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case 20:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case 17:
               _loc2_.x = -155;
               _loc2_.y = -150;
               break;
            case 23:
               _loc2_.x = -130;
               _loc2_.y = -185;
               break;
            case 22:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case 24:
               _loc2_.x = -162;
               _loc2_.y = -180;
               break;
            case 21:
               _loc2_.x = -160;
               _loc2_.y = -190;
               break;
            case 26:
               _loc2_.x = -140;
               _loc2_.y = -160;
               break;
            case 25:
               _loc2_.x = -165;
               _loc2_.y = -175;
               break;
            case 28:
               _loc2_.x = -150;
               _loc2_.y = -165;
               break;
            case 29:
               _loc2_.x = -145;
               _loc2_.y = -180;
               break;
            case 30:
               _loc2_.x = -140;
               _loc2_.y = -165;
               break;
            case 31:
               _loc2_.x = -135;
               _loc2_.y = -145;
               break;
            case 27:
               _loc2_.x = -145;
               _loc2_.y = -160;
               break;
            case 3:
               _loc2_.x = -145;
               _loc2_.y = -160;
               break;
            case 9:
               _loc2_.x = -130;
               _loc2_.y = -130;
               break;
            case 10:
               _loc2_.x = -125;
               _loc2_.y = -175;
               break;
            case 11:
               _loc2_.x = -125;
               _loc2_.y = -155;
               break;
            case 12:
               _loc2_.x = -135;
               _loc2_.y = -100;
               break;
            case 14:
               _loc2_.x = -165;
               _loc2_.y = -175;
               break;
            case 32:
               _loc2_.x = -150;
               _loc2_.y = -135;
               break;
            case 33:
               _loc2_.x = -120;
               _loc2_.y = -115;
               break;
            case 34:
               _loc2_.x = -145;
               _loc2_.y = -190;
               break;
            case 36:
               _loc2_.x = -160;
               _loc2_.y = -178;
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
            case 1:
            case 4:
               _loc2_.x = 160;
               _loc2_.y = 152;
               break;
            case 2:
               _loc2_.x = 150;
               _loc2_.y = 220;
               break;
            case 35:
               _loc2_.x = 150;
               _loc2_.y = 215;
               break;
            case 5:
            case 6:
               _loc2_.x = 158;
               _loc2_.y = 152;
               break;
            case 7:
               _loc2_.x = 157;
               _loc2_.y = 148;
               break;
            case 8:
               _loc2_.x = 162;
               _loc2_.y = 149;
               break;
            case 13:
            case 16:
            case 15:
               _loc2_.x = 160;
               _loc2_.y = 152;
               break;
            case 22:
               _loc2_.x = 155;
               _loc2_.y = 165;
               break;
            case 18:
               _loc2_.x = 153;
               _loc2_.y = 150;
               break;
            case 19:
               _loc2_.x = 148;
               _loc2_.y = 173;
               break;
            case 20:
               _loc2_.x = 153;
               _loc2_.y = 170;
               break;
            case 17:
            case 23:
               _loc2_.x = 162;
               _loc2_.y = 152;
               break;
            case 24:
               _loc2_.x = 155;
               _loc2_.y = 152;
               break;
            case 26:
               _loc2_.x = 155;
               _loc2_.y = 150;
               break;
            case 25:
               _loc2_.x = 153;
               _loc2_.y = 152;
               break;
            case 28:
               _loc2_.x = 155;
               _loc2_.y = 152;
               break;
            case 29:
               _loc2_.x = 155;
               _loc2_.y = 155;
               break;
            case 30:
               _loc2_.x = 152;
               _loc2_.y = 155;
               break;
            case 31:
               _loc2_.x = 154;
               _loc2_.y = 148;
               break;
            case 27:
               _loc2_.x = 152;
               _loc2_.y = 155;
               break;
            case 3:
            case 9:
               _loc2_.x = 158;
               _loc2_.y = 155;
               break;
            case 21:
               _loc2_.x = 153;
               _loc2_.y = 172;
               break;
            case 10:
               _loc2_.x = 159;
               _loc2_.y = 150;
               break;
            case 11:
               _loc2_.x = 152;
               _loc2_.y = 152;
               break;
            case 12:
               _loc2_.x = 156;
               _loc2_.y = 156;
               break;
            case 14:
               _loc2_.x = 153;
               _loc2_.y = 153;
               break;
            case 32:
            case 33:
               _loc2_.x = 158;
               _loc2_.y = 152;
               break;
            case 34:
               _loc2_.x = 158;
               _loc2_.y = 147;
               break;
            case 36:
               _loc2_.x = 156;
               _loc2_.y = 155;
               break;
            default:
               _loc2_.x = 160;
               _loc2_.y = 152;
         }
         return _loc2_;
      }
      
      public static function getAvOffsetByDefId(param1:int) : Point
      {
         switch(param1)
         {
            case 1:
               return new Point(120,35);
            case 2:
               return new Point(92,140);
            case 35:
               return new Point(105,130);
            case 4:
               return new Point(134,54);
            case 5:
               return new Point(125,58);
            case 6:
               return new Point(125,55);
            case 7:
               return new Point(138,50);
            case 8:
               return new Point(130,72);
            case 13:
               return new Point(120,88);
            case 15:
               return new Point(134,90);
            case 16:
               return new Point(125,53);
            case 18:
               return new Point(128,41);
            case 19:
               return new Point(125,80);
            case 20:
               return new Point(128,85);
            case 17:
               return new Point(138,60);
            case 23:
               return new Point(132,80);
            case 22:
               return new Point(122,70);
            case 24:
               return new Point(125,60);
            case 26:
               return new Point(125,79);
            case 21:
               return new Point(122,65);
            case 25:
               return new Point(126,75);
            case 28:
               return new Point(126,92);
            case 29:
               return new Point(130,110);
            case 30:
               return new Point(110,105);
            case 31:
               return new Point(121,70);
            case 27:
            case 34:
               break;
            case 3:
               return new Point(135,75);
            case 9:
               return new Point(145,75);
            case 10:
               return new Point(130,72);
            case 11:
               return new Point(125,72);
            case 12:
               return new Point(132,75);
            case 14:
               return new Point(125,72);
            case 32:
            case 33:
               return new Point(125,87);
            case 36:
               return new Point(122,55);
            default:
               return new Point(115,110);
         }
         return new Point(125,65);
      }
      
      public static function isAvatarActive(param1:int) : Boolean
      {
         if(param1 > 0)
         {
            return true;
         }
         return false;
      }
      
      public static function isEndangered(param1:int) : Boolean
      {
         if(param1 == 2)
         {
            return true;
         }
         return false;
      }
      
      public static function isExtinct(param1:int) : Boolean
      {
         if(param1 == 3)
         {
            return true;
         }
         return false;
      }
   }
}

