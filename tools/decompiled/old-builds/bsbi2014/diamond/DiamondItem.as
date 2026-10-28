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
      
      public function DiamondItem(defId:int)
      {
         super();
         var def:Object = DiamondXtCommManager.getDiamondDef(defId);
         this._defId = defId;
         this._type = def.type;
         this._refDefId = def.refDefId;
         this._status = def.status;
         this._value = this.isOnSale ? int(Math.ceil(def.value * 0.5)) : int(def.value);
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

