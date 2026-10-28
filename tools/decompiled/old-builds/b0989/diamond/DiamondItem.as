package diamond
{
   public class DiamondItem
   {
      
      public static const TYPE_ACCESSORY:int = 0;
      
      public static const TYPE_DEN_ITEM:int = 1;
      
      public static const TYPE_PET:int = 2;
      
      public static const TYPE_AVATAR:int = 3;
      
      public static const TYPE_DEN:int = 4;
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      private var _defId:int;
      
      private var _type:int;
      
      private var _refDefId:int;
      
      private var _status:int;
      
      private var _value:int;
      
      public function DiamondItem(param1:int)
      {
         super();
         var _loc2_:Object = DiamondXtCommManager.getDiamondDef(param1);
         this._defId = param1;
         this._type = _loc2_.type;
         this._refDefId = _loc2_.refDefId;
         this._status = _loc2_.status;
         this._value = _loc2_.value;
      }
      
      public function get defId() : int
      {
         return this._defId;
      }
      
      public function get type() : int
      {
         return this._type;
      }
      
      public function get refDefId() : int
      {
         return this._refDefId;
      }
      
      public function get status() : int
      {
         return this._status;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function get isAccessory() : Boolean
      {
         return this._type == TYPE_ACCESSORY;
      }
      
      public function get isAvatar() : Boolean
      {
         return this._type == TYPE_AVATAR;
      }
      
      public function get isDenItem() : Boolean
      {
         return this._type == TYPE_DEN_ITEM;
      }
      
      public function get isPet() : Boolean
      {
         return this._type == TYPE_PET;
      }
      
      public function get isDen() : Boolean
      {
         return this._type == TYPE_DEN;
      }
      
      public function get isOnSale() : Boolean
      {
         return this._status == SALE_ITEM;
      }
      
      public function get isOnClearance() : Boolean
      {
         return this._status == CLEARANCE_ITEM;
      }
      
      public function get isRare() : Boolean
      {
         return this._status == RARE_ITEM;
      }
      
      public function get isNew() : Boolean
      {
         return this._status == NEW_ITEM;
      }
   }
}

