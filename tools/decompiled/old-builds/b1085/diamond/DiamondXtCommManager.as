package diamond
{
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.graphics.LayerAnim;
   import den.DenItem;
   import den.DenRoomItem;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import gui.PetFinder;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   
   public class DiamondXtCommManager
   {
      
      private static var _diamondDefs:Object;
      
      public function DiamondXtCommManager()
      {
         super();
      }
      
      public static function diamondResponse(param1:DefPacksDefHelper) : void
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc2_:Object = param1.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DIAMOND] = null;
         var _loc3_:Object = new Object();
         for each(_loc5_ in param1.def)
         {
            _loc4_ = {
               "defId":int(_loc5_.id),
               "value":int(_loc5_.cost),
               "refDefId":int(_loc5_.refId),
               "status":int(_loc5_.status),
               "type":int(_loc5_.type)
            };
            _loc3_[_loc4_.defId] = _loc4_;
         }
         _diamondDefs = _loc3_;
      }
      
      public static function getDiamondItem(param1:int) : DiamondItem
      {
         return new DiamondItem(param1);
      }
      
      public static function getDiamondDef(param1:int) : Object
      {
         return _diamondDefs[param1];
      }
      
      public static function generateDiamondShopList(param1:int, param2:Array, param3:Array) : Array
      {
         var _loc6_:Object = null;
         var _loc8_:Object = null;
         var _loc9_:Object = null;
         var _loc10_:DiamondItem = null;
         var _loc11_:Object = null;
         var _loc12_:Point = null;
         var _loc13_:Array = null;
         var _loc14_:Array = null;
         var _loc15_:Object = null;
         var _loc16_:Object = null;
         var _loc4_:Array = [];
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         while(_loc7_ < param1)
         {
            _loc8_ = {
               "icon":null,
               "value":0,
               "currencyType":Item.DIAMOND_CURRENCY,
               "name":"",
               "destroy":null,
               "isMemberOnly":false,
               "isNew":false,
               "isOnClearance":false,
               "isOnSale":false,
               "isRare":false
            };
            _loc10_ = getDiamondItem(int(param2[_loc7_]));
            if(_loc10_.isAccessory)
            {
               _loc6_ = ItemXtCommManager.getItemDef(_loc10_.refDefId);
               _loc8_ = new Item();
               _loc8_.init(_loc6_.defId,_loc7_,_loc6_.colors[0],0,0,true);
               _loc8_.value = _loc10_.value;
               _loc8_.diamondDefId = _loc10_.defId;
               _loc8_.itemStatus = _loc10_.status;
               param3[_loc7_] = _loc6_.colors.concat();
            }
            else if(_loc10_.isAvatar)
            {
               _loc8_.icon = new AvatarView();
               _loc8_.icon.init(AvatarUtility.creationAvatars[AvatarUtility.findAvatarIndexByType(_loc10_.refDefId)]);
               _loc8_.icon.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
               _loc11_ = gMainFrame.userInfo.getAvatarDefByAvType(_loc8_.icon.avTypeId);
               _loc8_.value = _loc10_.value;
               _loc8_.itemDefId = _loc10_.defId;
               _loc8_.diamondDefId = _loc10_.defId;
               _loc8_.name = LocalizationManager.translateIdOnly(11179);
               _loc8_.destroy = _loc8_.icon.destroy;
               _loc8_.isOcean = Utility.isOcean(_loc8_.icon.avatarData.enviroTypeFlag);
               _loc8_.isNew = _loc10_.status == Item.NEW_ITEM;
               _loc8_.isOnClearance = _loc10_.status == Item.CLEARANCE_ITEM;
               _loc8_.isOnSale = _loc10_.status == Item.SALE_ITEM;
               _loc8_.isRare = _loc10_.status == Item.RARE_ITEM;
               if(_loc11_)
               {
                  _loc8_.isMemberOnly = _loc11_.isMemOnly;
                  _loc8_.name = LocalizationManager.translateIdOnly(_loc11_.titleStrRef);
               }
               _loc12_ = AvatarUtility.getAnimalItemWindowOffset(_loc8_.icon.avTypeId);
               _loc8_.icon.x = _loc12_.x;
               _loc8_.icon.y = _loc12_.y;
            }
            else if(_loc10_.isPet)
            {
               _loc13_ = PetFinder.createRandomPet(_loc10_.refDefId);
               _loc14_ = PetFinder.packPetBits(_loc13_);
               _loc15_ = PetManager.getPetDef(_loc10_.refDefId);
               _loc8_.icon = PetManager.getGuiPet(_loc10_.refDefId,_loc14_[0],_loc14_[1],_loc14_[2],_loc15_.type,"Pet",onPetLoaded);
               _loc8_.value = _loc10_.value;
               _loc8_.itemDefId = _loc10_.defId;
               _loc8_.diamondDefId = _loc10_.defId;
               _loc8_.name = _loc15_.title;
               _loc8_.destroy = _loc8_.icon.destroy;
               _loc8_.isOcean = Utility.isOcean(PetManager.getEnviroTypeByPetType(_loc15_.type));
               _loc8_.isNew = _loc10_.status == Item.NEW_ITEM;
               _loc8_.isOnClearance = _loc10_.status == Item.CLEARANCE_ITEM;
               _loc8_.isOnSale = _loc10_.status == Item.SALE_ITEM;
               _loc8_.isRare = _loc10_.status == Item.RARE_ITEM;
               _loc8_.isMemberOnly = _loc15_.isMember;
            }
            else if(_loc10_.isDenItem)
            {
               _loc8_ = new DenItem();
               _loc8_.initShopItem(_loc10_.refDefId,-1);
               _loc8_.value = _loc10_.value;
               _loc8_.diamondDefId = _loc10_.defId;
               _loc8_.itemStatus = _loc10_.status;
            }
            else if(_loc10_.isDen)
            {
               _loc8_ = new DenRoomItem();
               _loc16_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc10_.refDefId);
               _loc8_.initShopItem(_loc5_,_loc16_.defId,_loc16_.mediaId,_loc16_.mediaIdLarge,_loc16_.value,_loc16_.name,_loc16_.enviroType,_loc16_.membersOnly,_loc16_.status);
               _loc8_.value = _loc10_.value;
               _loc8_.itemDefId = _loc10_.defId;
               _loc8_.itemStatus = _loc10_.status;
               _loc8_.diamondDefId = _loc10_.defId;
            }
            _loc8_.currencyType = Item.DIAMOND_CURRENCY;
            _loc4_.push(_loc8_);
            _loc7_++;
         }
         return _loc4_;
      }
      
      private static function onPetLoaded(param1:MovieClip) : void
      {
         param1.scaleX = param1.scaleY = 3;
         param1.y += param1.height * 0.35;
      }
   }
}

