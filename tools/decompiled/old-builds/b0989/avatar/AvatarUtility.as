package avatar
{
   import com.sbi.popup.SBWizard;
   import createAccountGui.GuiAvatarCreationAssets;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import gui.SharedAvatarAnimalConstants;
   import item.Item;
   import item.ItemXtCommManager;
   
   public class AvatarUtility
   {
      
      public static var avatarTypes:Array;
      
      public static var creationAvatars:Array;
      
      public static var avatarDefInfo:Array;
      
      public static var creationAssets:GuiAvatarCreationAssets;
      
      public static var skippedIndexes:Array;
      
      private static var _avtMgrGetAvtByDbAvId:Function;
      
      private static var _numViewsLoaded:int;
      
      private static var _numNonMemberAvatars:Function;
      
      public static const AVT_AVAIL_HIDDEN:int = 0;
      
      public static const AVT_AVAIL_ACTIVE:int = 1;
      
      public static const AVT_AVAIL_ENDANGERED:int = 2;
      
      public static const AVT_AVAIL_EXTINCT:int = 3;
      
      public function AvatarUtility()
      {
         super();
      }
      
      public static function init(param1:MovieClip, param2:SBWizard, param3:Function, param4:INewAvatar = null, param5:DisplayObjectContainer = null, param6:Function = null, param7:Function = null, param8:Boolean = true) : void
      {
         var _loc9_:Function = null;
         _avtMgrGetAvtByDbAvId = param3;
         _numNonMemberAvatars = param6;
         creationAssets = new GuiAvatarCreationAssets(param8 ? MainFrame.avatarCreationWorld : MainFrame.avatarCreationLogin,param8);
         creationAssets.init(param8 ? MainFrame.avatarCreationWorld : MainFrame.avatarCreationLogin,param8);
         creationAssets.visible = false;
         param5.addChild(creationAssets);
         _loc9_ = param8 ? buildCreationAvatarViews : param7;
         GenericListXtCommManager.requestGenericList(GenericListXtCommManager.AVATAR_LIST_ID,_loc9_,null,param8);
      }
      
      public static function reloadAvatarChooser(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false, param5:int = 0, param6:int = -1) : void
      {
         if(creationAssets)
         {
            creationAssets.reloadChooser(param1,param2,param3,param4,param5,param6);
         }
      }
      
      public static function destroyReloadedItems() : void
      {
         if(creationAssets)
         {
            creationAssets.destroyReloadedItems();
         }
      }
      
      public static function buildCreationAvatarViews(param1:Array, param2:Boolean = false) : void
      {
         var _loc3_:* = 0;
         var _loc5_:Avatar = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:Item = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:Object = null;
         var _loc14_:Object = null;
         var _loc15_:Object = null;
         avatarTypes = [];
         skippedIndexes = [];
         var _loc4_:int = int(param1.length);
         var _loc11_:int = 0;
         if(creationAvatars)
         {
            if(creationAvatars.length > 0)
            {
               _loc12_ = 0;
               while(_loc12_ < creationAvatars.length)
               {
                  creationAvatars[_loc12_].destroy();
                  _loc12_++;
               }
            }
         }
         avatarDefInfo = new Array(_loc4_);
         creationAvatars = [];
         _loc10_ = 0;
         _loc3_ = 0;
         while(_loc10_ < _loc4_)
         {
            _loc13_ = gMainFrame.userInfo.getAvatarDefByAvType(param1[_loc10_]);
            if(_loc13_)
            {
               if(isAvatarActive(_loc13_.availability) && (!param2 || param2 && !_loc13_.isMemOnly && !isExtinct(_loc13_.availability) && Utility.isLand(_loc13_.enviroTypeFlag)))
               {
                  _loc6_ = int(param1[_loc10_]);
                  avatarTypes[_loc10_ - _loc11_] = _loc6_;
                  avatarDefInfo[_loc10_ - _loc11_] = {
                     "isMemberOnly":_loc13_.isMemOnly,
                     "enviroFlag":_loc13_.enviroTypeFlag,
                     "cost":_loc13_.cost,
                     "availability":_loc13_.availability
                  };
                  _loc5_ = new Avatar();
                  _loc5_.init(0,"",_loc6_,[_loc13_.colorLayer1,_loc13_.colorLayer2,_loc13_.colorLayer3]);
                  _loc14_ = ItemXtCommManager.getItemDef(_loc13_.defEyes);
                  _loc15_ = ItemXtCommManager.getItemDef(_loc13_.defPattern);
                  _loc8_ = new Item();
                  _loc8_.init(1,_loc3_++,0,-1,-1);
                  _loc5_.inventoryBodyMod.addItem(_loc8_);
                  _loc5_.accStateShowAccessory(_loc8_);
                  _loc8_ = new Item();
                  _loc8_.init(_loc14_.defId,_loc3_++,_loc14_.colors,-1,-1);
                  _loc5_.inventoryBodyMod.addItem(_loc8_);
                  _loc5_.accStateShowAccessory(_loc8_);
                  if(_loc15_)
                  {
                     _loc8_ = new Item();
                     _loc8_.init(_loc15_.defId,_loc3_++,_loc15_.colors,-1,-1);
                     _loc5_.inventoryBodyMod.addItem(_loc8_);
                     _loc5_.accStateShowAccessory(_loc8_);
                  }
                  creationAvatars.push(_loc5_);
                  skippedIndexes[_loc10_] = false;
               }
               else
               {
                  skippedIndexes[_loc10_] = true;
                  _loc11_++;
               }
            }
            _loc10_++;
         }
         if(!param2)
         {
            creationAssets.creationWiz.chooseAnimalScreen.init();
         }
      }
      
      public static function generateNew(param1:int, param2:Avatar = null, param3:int = -1, param4:int = 0, param5:Function = null) : Avatar
      {
         var _loc7_:AvatarInfo = null;
         var _loc6_:Avatar = null;
         if(param2 == null && _avtMgrGetAvtByDbAvId != null)
         {
            _loc6_ = _avtMgrGetAvtByDbAvId(param1);
         }
         if(!_loc6_)
         {
            if(param2)
            {
               _loc6_ = param2;
            }
            else
            {
               _loc6_ = new Avatar();
            }
            _loc7_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(param1);
            if((Boolean(_loc7_)) && _loc7_.type != -1)
            {
               _loc6_.init(param1,_loc7_.avName,_loc7_.type,_loc7_.colors,null,_loc7_.userName,param3,param4);
               getAvatarItemData(_loc6_,param5,_loc7_);
            }
            else
            {
               _loc6_.init(param1,"tempAvt",-1,[0,0,0],null,"tempUser",param3);
               AvatarXtCommManager.requestADForAvatar(param1,true,param5,_loc6_);
            }
         }
         return _loc6_;
      }
      
      public static function getAvatarItemData(param1:Avatar, param2:Function = null, param3:AvatarInfo = null) : void
      {
         if(param1 == null || param1.dbAvId < 0)
         {
            throw new Error("Invalid avatar!");
         }
         if(param3 == null)
         {
            param3 = gMainFrame.userInfo.getAvatarInfoByDbAvId(param1.dbAvId);
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
            ItemXtCommManager.requestItemListForAvatar(null,param1,ItemXtCommManager.hasRequestedFullItemList);
         }
         else
         {
            AvatarXtCommManager.requestADForAvatar(param1.dbAvId,true,param2,param1);
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
               if(_loc7_.layerId == 1)
               {
                  _loc5_ = uint(param2[0]);
               }
               else if(_loc7_.layerId == 2)
               {
                  _loc5_ = uint(param2[1]);
               }
               else if(_loc7_.layerId == 3)
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
         while(_loc2_ < avatarTypes.length)
         {
            if(Boolean(avatarTypes[_loc2_]) && avatarTypes[_loc2_] == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public static function findAvatarIndexByType(param1:int) : int
      {
         var _loc2_:int = 0;
         while(_loc2_ < creationAvatars.length)
         {
            if(Boolean(creationAvatars[_loc2_]) && creationAvatars[_loc2_].avTypeId == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      public static function findAvDefByType(param1:int) : Object
      {
         var _loc2_:int = findAvDefIndexByType(param1);
         if(_loc2_ != -1)
         {
            return avatarDefInfo[_loc2_];
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
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_ = 220;
               _loc3_ = 212;
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
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_SNOW_LEOPARD:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_RACCOON:
               _loc2_.x = 127;
               _loc2_.y = 115;
               break;
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = 127;
               _loc2_.y = 110;
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
         switch(param1)
         {
            case SharedAvatarAnimalConstants.AV_TIGER:
               _loc2_.x = 10;
               _loc2_.y = -70;
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
            case 10:
               _loc2_.x = 0;
               _loc2_.y = -115;
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
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = -2;
               _loc2_.y = -95;
               break;
            default:
               _loc2_.x = -25;
               _loc2_.y = -75;
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
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = 128;
               _loc2_.y = 65;
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
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = -145;
               _loc2_.y = -160;
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
            case SharedAvatarAnimalConstants.AV_KANGAROO:
               _loc2_.x = 152;
               _loc2_.y = 155;
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

