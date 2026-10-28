package item
{
   import avatar.AccessoryState;
   
   public class Inventory
   {
      
      private var _itemArray:Array;
      
      private var _accState:AccessoryState;
      
      public function Inventory()
      {
         super();
      }
      
      public function init(param1:AccessoryState) : void
      {
         _itemArray = [];
         _accState = param1;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_itemArray)
         {
            _loc1_ = 0;
            while(_loc1_ < _itemArray.length)
            {
               _itemArray[_loc1_].destroy();
               _loc1_++;
            }
            _itemArray = null;
         }
         if(_accState)
         {
            _accState.destroy();
            _accState = null;
         }
      }
      
      public function itemTypeMatch(param1:Item) : Boolean
      {
         return true;
      }
      
      public function eraseAll() : void
      {
         _itemArray = [];
      }
      
      public function clone(param1:Inventory) : void
      {
         _itemArray = [];
         _accState = param1._accState;
         var _loc2_:Array = param1._itemArray;
         for each(var _loc3_:Item in _loc2_)
         {
            addItem(_loc3_.clone());
         }
      }
      
      public function addItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(_itemArray != null)
         {
            if(hasItem(param1))
            {
               _loc2_ = int(_itemArray.length);
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  if(_itemArray[_loc3_].ifItemDiffers(param1))
                  {
                     updateItem(param1);
                     break;
                  }
                  _loc3_++;
               }
            }
            else
            {
               _itemArray.push(param1);
            }
         }
         else
         {
            _itemArray.push(param1);
         }
      }
      
      public function removeItem(param1:Item) : void
      {
         var _loc2_:int = getItemIndexInItemArray(param1.invIdx);
         if(_loc2_ >= 0)
         {
            _itemArray.splice(_loc2_,1);
         }
      }
      
      private function updateItem(param1:Item) : void
      {
         var _loc2_:int = getItemIndexInItemArray(param1.invIdx);
         if(_loc2_ >= 0)
         {
            if(_accState != null)
            {
               _accState.replaceAccessory(_itemArray[_loc2_],param1);
            }
            _itemArray[_loc2_] = param1;
            return;
         }
         throw new Error("WARNING: Inventory- Cannot update an item that doesn\'t exist in inventory.");
      }
      
      public function hasItem(param1:Item) : Boolean
      {
         if(getItemIndexInItemArray(param1.invIdx) >= 0)
         {
            return true;
         }
         return false;
      }
      
      public function hasItemByAccId(param1:int) : Boolean
      {
         return getItemIndexInItemArrayByAccId(param1) >= 0;
      }
      
      public function get itemArray() : Array
      {
         return _itemArray;
      }
      
      public function set itemArray(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            _itemArray = param1;
            _loc2_ = 0;
            while(_loc2_ < _itemArray.length)
            {
               _itemArray[_loc2_] = _itemArray[_loc2_].clone();
               _loc2_++;
            }
         }
      }
      
      public function get numItems() : int
      {
         return _itemArray.length;
      }
      
      private function getItemIndexInItemArray(param1:int) : int
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_itemArray.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_itemArray[_loc3_].invIdx == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      private function getItemIndexInItemArrayByAccId(param1:int) : int
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _itemArray.length)
         {
            if(_itemArray[_loc2_].accId == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
   }
}

