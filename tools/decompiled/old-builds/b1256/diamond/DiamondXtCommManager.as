package diamond
{
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import den.DenItem;
   import den.DenRoomItem;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   
   public class DiamondXtCommManager
   {
      
      public static const DIAMOND_TYPE_ITEM:int = 0;
      
      public static const DIAMOND_TYPE_DEN_ITEM:int = 1;
      
      public static const DIAMOND_TYPE_PET:int = 2;
      
      public static const DIAMOND_TYPE_AVATAR:int = 3;
      
      public static const DIAMOND_TYPE_DEN:int = 4;
      
      public static var diamondDefsLoaded:Boolean;
      
      private static var _diamondDefs:Object = {};
      
      private static var _diamondRefDefs:Object = {};
      
      public function DiamondXtCommManager()
      {
         super();
      }
      
      public static function diamondResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[1054] = null;
         var _loc5_:Object = {};
         _diamondRefDefs = {};
         for each(var _loc3_:Object in param1.def)
         {
            _loc4_ = {
               "defId":int(_loc3_.id),
               "value":int(_loc3_.cost),
               "refDefId":int(_loc3_.refId),
               "status":int(_loc3_.status),
               "type":int(_loc3_.type)
            };
            _loc5_[_loc4_.defId] = _loc4_;
            if(_diamondRefDefs[_loc4_.type])
            {
               _diamondRefDefs[_loc4_.type][_loc4_.refDefId] = _loc4_;
            }
            else
            {
               _diamondRefDefs[_loc4_.type] = {};
               _diamondRefDefs[_loc4_.type][_loc4_.refDefId] = _loc4_;
            }
         }
         _diamondDefs = _loc5_;
         diamondDefsLoaded = true;
      }
      
      public static function getDiamondItem(param1:int) : DiamondItem
      {
         return new DiamondItem(param1);
      }
      
      public static function getDiamondDef(param1:int) : Object
      {
         return _diamondDefs[param1];
      }
      
      public static function getDiamondDefByRefId(param1:int, param2:int) : Object
      {
         return getDiamondDef(getDiamondDefIdByRefId(param1,param2));
      }
      
      public static function getDiamondDefIdByRefId(param1:int, param2:int) : int
      {
         var _loc3_:Object = null;
         var _loc4_:Object = _diamondRefDefs[param2];
         if(_loc4_)
         {
            _loc3_ = _loc4_[param1];
            if(_loc3_)
            {
               return _loc3_.defId;
            }
         }
         return -1;
      }
      
      public static function generateDiamondShopList(param1:int, param2:Array, param3:Array) : Array
      {
         var _loc14_:Object = null;
         var _loc9_:int = 0;
         var _loc15_:Object = null;
         var _loc5_:* = null;
         var _loc12_:DiamondItem = null;
         var _loc10_:Avatar = null;
         var _loc17_:Object = null;
         var _loc16_:Point = null;
         var _loc7_:Array = null;
         var _loc4_:Array = null;
         var _loc11_:Object = null;
         var _loc6_:Object = null;
         var _loc13_:Array = [];
         var _loc8_:int = 0;
         _loc9_ = 0;
         for(; _loc9_ < param1; _loc9_++)
         {
            _loc15_ = {
               "icon":null,
               "value":0,
               "currencyType":3,
               "name":"",
               "destroy":null,
               "isMemberOnly":false,
               "isNew":false,
               "isOnClearance":false,
               "isOnSale":false,
               "isRare":false
            };
            _loc12_ = getDiamondItem(int(param2[_loc9_]));
            if(_loc12_.isAccessory)
            {
               _loc14_ = ItemXtCommManager.getItemDef(_loc12_.refDefId);
               _loc15_ = new Item();
               _loc15_.init(_loc14_.defId,_loc9_,_loc14_.colors[0],0,0,true);
               _loc15_.value = _loc12_.value;
               _loc15_.diamondDefId = _loc12_.defId;
               _loc15_.itemStatus = _loc12_.status;
               param3[_loc9_] = _loc14_.colors.concat();
            }
            else if(_loc12_.isAvatar)
            {
               _loc10_ = AvatarUtility.findCreationAvatarByType(_loc12_.refDefId,-1);
               if(!_loc10_)
               {
                  continue;
               }
               _loc15_.icon = new AvatarView();
               _loc15_.icon.init(_loc10_);
               _loc15_.icon.playAnim(13,false,1,null);
               _loc17_ = gMainFrame.userInfo.getAvatarDefByAvatar(_loc10_);
               _loc15_.value = _loc12_.value;
               _loc15_.itemDefId = _loc12_.defId;
               _loc15_.diamondDefId = _loc12_.defId;
               _loc15_.name = LocalizationManager.translateIdOnly(11179);
               _loc15_.destroy = _loc15_.icon.destroy;
               _loc15_.isOcean = Utility.isOcean(_loc15_.icon.avatarData.enviroTypeFlag);
               _loc15_.isNew = _loc12_.status == 1;
               _loc15_.isOnClearance = _loc12_.status == 3;
               _loc15_.isOnSale = _loc12_.status == 2;
               _loc15_.isRare = _loc12_.status == 4;
               if(_loc17_)
               {
                  _loc15_.isMemberOnly = _loc17_.isMemOnly;
                  _loc15_.name = LocalizationManager.translateIdOnly(_loc17_.titleStrRef);
               }
               _loc16_ = AvatarUtility.getAnimalItemWindowOffset(_loc15_.icon.avTypeId);
               _loc15_.icon.x = _loc16_.x;
               _loc15_.icon.y = _loc16_.y;
            }
            else if(_loc12_.isPet)
            {
               _loc7_ = PetManager.createRandomPet(_loc12_.refDefId);
               _loc4_ = PetManager.packPetBits(_loc7_);
               _loc11_ = PetManager.getPetDef(_loc12_.refDefId);
               _loc15_.icon = PetManager.getGuiPet(_loc12_.refDefId,_loc4_[0],_loc4_[1],_loc4_[2],_loc11_.type,_loc11_.title,onPetLoaded);
               _loc15_.value = _loc12_.value;
               _loc15_.itemDefId = _loc12_.defId;
               _loc15_.diamondDefId = _loc12_.defId;
               _loc15_.name = _loc11_.title;
               _loc15_.destroy = _loc15_.icon.destroy;
               _loc15_.isOcean = Utility.isOcean(PetManager.getEnviroTypeByPetType(_loc11_.type));
               _loc15_.isNew = _loc12_.status == 1;
               _loc15_.isOnClearance = _loc12_.status == 3;
               _loc15_.isOnSale = _loc12_.status == 2;
               _loc15_.isRare = _loc12_.status == 4;
               _loc15_.isMemberOnly = _loc11_.isMember;
            }
            else if(_loc12_.isDenItem)
            {
               _loc15_ = new DenItem();
               _loc15_.initShopItem(_loc12_.refDefId,-1);
               _loc15_.value = _loc12_.value;
               _loc15_.diamondDefId = _loc12_.defId;
               _loc15_.itemStatus = _loc12_.status;
            }
            else if(_loc12_.isDen)
            {
               _loc15_ = new DenRoomItem();
               _loc6_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc12_.refDefId);
               _loc15_.initShopItem(_loc8_,_loc6_.defId,_loc6_.mediaId,_loc6_.mediaIdLarge,_loc6_.value,_loc6_.name,_loc6_.enviroType,_loc6_.membersOnly,_loc6_.status);
               _loc15_.value = _loc12_.value;
               _loc15_.itemDefId = _loc12_.defId;
               _loc15_.itemStatus = _loc12_.status;
               _loc15_.diamondDefId = _loc12_.defId;
            }
            _loc15_.currencyType = 3;
            _loc13_.push(_loc15_);
         }
         return _loc13_;
      }
      
      private static function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         param1.scaleX = param1.scaleY = 3;
         param1.y += param1.height * 0.35;
      }
   }
}

