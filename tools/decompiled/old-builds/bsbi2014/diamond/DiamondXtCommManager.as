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
   import pet.GuiPet;
   import pet.PetManager;
   
   public class DiamondXtCommManager
   {
      
      private static var _diamondDefs:Object;
      
      public function DiamondXtCommManager()
      {
         super();
      }
      
      public static function diamondResponse(dfdh:DefPacksDefHelper) : void
      {
         var diamondDef:Object = null;
         var data:Object = null;
         var newDef:Object = dfdh.def;
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_DIAMOND] = null;
         var diamondDefs:Object = new Object();
         for each(data in dfdh.def)
         {
            diamondDef = {
               "defId":int(data.id),
               "value":int(data.cost),
               "refDefId":int(data.refId),
               "status":int(data.status),
               "type":int(data.type)
            };
            diamondDefs[diamondDef.defId] = diamondDef;
         }
         _diamondDefs = diamondDefs;
      }
      
      public static function getDiamondItem(id:int) : DiamondItem
      {
         return new DiamondItem(id);
      }
      
      public static function getDiamondDef(id:int) : Object
      {
         return _diamondDefs[id];
      }
      
      public static function generateDiamondShopList(numItems:int, data:Array, itemColorsArray:Array) : Array
      {
         var currDef:Object = null;
         var createdItem:Object = null;
         var currCreatedItemDef:Object = null;
         var diamondItem:DiamondItem = null;
         var avatarDef:Object = null;
         var offset:Point = null;
         var catArray:Array = null;
         var petBits:Array = null;
         var currPetDef:Object = null;
         var o:Object = null;
         var items:Array = [];
         var j:int = 0;
         for(var i:int = 0; i < numItems; i++)
         {
            createdItem = {
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
            diamondItem = getDiamondItem(int(data[i]));
            if(diamondItem.isAccessory)
            {
               currDef = ItemXtCommManager.getItemDef(diamondItem.refDefId);
               createdItem = new Item();
               createdItem.init(currDef.defId,i,currDef.colors[0],0,0,true);
               createdItem.value = diamondItem.value;
               createdItem.diamondDefId = diamondItem.defId;
               createdItem.itemStatus = diamondItem.status;
               itemColorsArray[i] = currDef.colors.concat();
            }
            else if(diamondItem.isAvatar)
            {
               createdItem.icon = new AvatarView();
               createdItem.icon.init(AvatarUtility.creationAvatars[AvatarUtility.findAvatarIndexByType(diamondItem.refDefId)]);
               createdItem.icon.playAnim(LayerAnim.AN_BBCARD,false,LayerAnim.PLAY_ONE_SHOT,null);
               avatarDef = gMainFrame.userInfo.getAvatarDefByAvType(createdItem.icon.avTypeId);
               createdItem.value = diamondItem.value;
               createdItem.itemDefId = diamondItem.defId;
               createdItem.diamondDefId = diamondItem.defId;
               createdItem.name = LocalizationManager.translateIdOnly(11179);
               createdItem.destroy = createdItem.icon.destroy;
               createdItem.isOcean = Utility.isOcean(createdItem.icon.avatarData.enviroTypeFlag);
               createdItem.isNew = diamondItem.status == Item.NEW_ITEM;
               createdItem.isOnClearance = diamondItem.status == Item.CLEARANCE_ITEM;
               createdItem.isOnSale = diamondItem.status == Item.SALE_ITEM;
               createdItem.isRare = diamondItem.status == Item.RARE_ITEM;
               if(Boolean(avatarDef))
               {
                  createdItem.isMemberOnly = avatarDef.isMemOnly;
                  createdItem.name = LocalizationManager.translateIdOnly(avatarDef.titleStrRef);
               }
               offset = AvatarUtility.getAnimalItemWindowOffset(createdItem.icon.avTypeId);
               createdItem.icon.x = offset.x;
               createdItem.icon.y = offset.y;
            }
            else if(diamondItem.isPet)
            {
               catArray = PetFinder.createRandomPet(diamondItem.refDefId);
               petBits = PetFinder.packPetBits(catArray);
               currPetDef = PetManager.getPetDef(diamondItem.refDefId);
               createdItem.icon = PetManager.getGuiPet(diamondItem.refDefId,petBits[0],petBits[1],petBits[2],currPetDef.type,"Pet",onPetLoaded);
               createdItem.value = diamondItem.value;
               createdItem.itemDefId = diamondItem.defId;
               createdItem.diamondDefId = diamondItem.defId;
               createdItem.name = currPetDef.title;
               createdItem.destroy = createdItem.icon.destroy;
               createdItem.isOcean = Utility.isOcean(PetManager.getEnviroTypeByPetType(currPetDef.type));
               createdItem.isNew = diamondItem.status == Item.NEW_ITEM;
               createdItem.isOnClearance = diamondItem.status == Item.CLEARANCE_ITEM;
               createdItem.isOnSale = diamondItem.status == Item.SALE_ITEM;
               createdItem.isRare = diamondItem.status == Item.RARE_ITEM;
               createdItem.isMemberOnly = currPetDef.isMember;
            }
            else if(diamondItem.isDenItem)
            {
               createdItem = new DenItem();
               createdItem.initShopItem(diamondItem.refDefId,-1);
               createdItem.value = diamondItem.value;
               createdItem.diamondDefId = diamondItem.defId;
               createdItem.itemStatus = diamondItem.status;
            }
            else if(diamondItem.isDen)
            {
               createdItem = new DenRoomItem();
               o = gMainFrame.userInfo.getDenRoomDefByDefId(diamondItem.refDefId);
               createdItem.initShopItem(j,o.defId,o.mediaId,o.mediaIdLarge,o.value,o.name,o.enviroType,o.membersOnly,o.status);
               createdItem.value = diamondItem.value;
               createdItem.itemDefId = diamondItem.defId;
               createdItem.itemStatus = diamondItem.status;
               createdItem.diamondDefId = diamondItem.defId;
            }
            createdItem.currencyType = Item.DIAMOND_CURRENCY;
            items.push(createdItem);
         }
         return items;
      }
      
      private static function onPetLoaded(content:MovieClip, pet:GuiPet) : void
      {
         content.scaleX = content.scaleY = 3;
         content.y += content.height * 0.35;
      }
   }
}

