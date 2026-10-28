package diamond
{
   import avatar.AvatarItem;
   import collection.IitemCollection;
   import den.DenItem;
   import den.DenRoomItem;
   import inventory.Iitem;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
   import pet.PetItem;
   
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
         if(_diamondDefs[param1])
         {
            return new DiamondItem(param1);
         }
         return null;
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
      
      public static function generateDiamondShopList(param1:int, param2:Array, param3:Array) : IitemCollection
      {
         var _loc6_:Object = null;
         var _loc10_:int = 0;
         var _loc7_:Iitem = null;
         var _loc4_:DiamondItem = null;
         var _loc8_:Object = null;
         var _loc5_:IitemCollection = new IitemCollection();
         var _loc9_:int = 0;
         _loc10_ = 0;
         while(_loc10_ < param1)
         {
            _loc4_ = getDiamondItem(int(param2[_loc10_]));
            if(_loc4_.isAccessory)
            {
               _loc6_ = ItemXtCommManager.getItemDef(_loc4_.refDefId);
               _loc7_ = new Item();
               (_loc7_ as Item).init(_loc6_.defId,_loc10_,_loc6_.colors[0],0,0,true);
               param3[_loc6_.defId] = _loc6_.colors.concat();
            }
            else if(_loc4_.isAvatar)
            {
               _loc7_ = new AvatarItem();
               (_loc7_ as AvatarItem).init(_loc4_.refDefId,_loc10_,true,0,-1,_loc4_);
            }
            else if(_loc4_.isPet)
            {
               _loc7_ = new PetItem();
               (_loc7_ as PetItem).init(0,_loc4_.refDefId,null,0,0,0,_loc10_,null,true,-1,null,_loc4_);
            }
            else if(_loc4_.isDenItem)
            {
               _loc7_ = new DenItem();
               (_loc7_ as DenItem).initShopItem(_loc4_.refDefId,-1);
            }
            else if(_loc4_.isDen)
            {
               _loc7_ = new DenRoomItem();
               _loc8_ = gMainFrame.userInfo.getDenRoomDefByDefId(_loc4_.refDefId);
               (_loc7_ as DenRoomItem).initShopItem(_loc9_,_loc8_.defId,_loc8_);
            }
            _loc5_.pushIitem(_loc7_);
            _loc10_++;
         }
         return _loc5_;
      }
   }
}

