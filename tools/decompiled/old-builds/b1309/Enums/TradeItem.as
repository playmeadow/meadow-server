package Enums
{
   public class TradeItem
   {
      
      public static const ITEM_TYPE_ACCESSORY_ITEM:int = 0;
      
      public static const ITEM_TYPE_DEN_ITEM:int = 1;
      
      private var _invIdx:int;
      
      private var _itemType:int;
      
      public function TradeItem(param1:int, param2:int)
      {
         super();
         _invIdx = param1;
         _itemType = param2;
      }
      
      public function get invIdx() : int
      {
         return _invIdx;
      }
      
      public function get itemType() : int
      {
         return _itemType;
      }
   }
}

