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
         this._itemArray = [];
         this._accState = param1;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(this._itemArray)
         {
            _loc1_ = 0;
            while(_loc1_ < this._itemArray.length)
            {
               this._itemArray[_loc1_].destroy();
               _loc1_++;
            }
            this._itemArray = null;
         }
         if(this._accState)
         {
            this._accState.destroy();
            this._accState = null;
         }
      }
      
      public function itemTypeMatch(param1:Item) : Boolean
      {
         return true;
      }
      
      public function eraseAll() : void
      {
         this._itemArray = [];
      }
      
      public function clone(param1:Inventory) : void
      {
         var _loc3_:Item = null;
         this._itemArray = [];
         this._accState = param1._accState;
         var _loc2_:Array = param1._itemArray;
         for each(_loc3_ in _loc2_)
         {
            this.addItem(_loc3_.clone());
         }
      }
      
      public function addItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(this._itemArray != null)
         {
            if(this.hasItem(param1))
            {
               _loc2_ = int(this._itemArray.length);
               _loc3_ = 0;
               while(_loc3_ < _loc2_)
               {
                  if(this._itemArray[_loc3_].ifItemDiffers(param1))
                  {
                     this.updateItem(param1);
                     break;
                  }
                  _loc3_++;
               }
            }
            else
            {
               this._itemArray.push(param1);
            }
         }
         else
         {
            this._itemArray.push(param1);
         }
      }
      
      public function removeItem(param1:Item) : void
      {
         var _loc2_:int = this.getItemIndexInItemArray(param1.invIdx);
         if(_loc2_ >= 0)
         {
            this._itemArray.splice(_loc2_,1);
         }
      }
      
      private function updateItem(param1:Item) : void
      {
         var _loc2_:int = this.getItemIndexInItemArray(param1.invIdx);
         if(_loc2_ >= 0)
         {
            if(this._accState != null)
            {
               this._accState.replaceAccessory(this._itemArray[_loc2_],param1);
            }
            this._itemArray[_loc2_] = param1;
            return;
         }
         throw new Error("WARNING: Inventory- Cannot update an item that doesn\'t exist in inventory.");
      }
      
      public function hasItem(param1:Item) : Boolean
      {
         if(this.getItemIndexInItemArray(param1.invIdx) >= 0)
         {
            return true;
         }
         return false;
      }
      
      public function hasItemByAccId(param1:int) : Boolean
      {
         return Boolean(this.getItemIndexInItemArrayByAccId(param1) >= 0);
      }
      
      public function get itemArray() : Array
      {
         return this._itemArray;
      }
      
      public function set itemArray(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1)
         {
            this._itemArray = param1;
            _loc2_ = 0;
            while(_loc2_ < this._itemArray.length)
            {
               this._itemArray[_loc2_] = this._itemArray[_loc2_].clone();
               _loc2_++;
            }
         }
      }
      
      public function get numItems() : int
      {
         return this._itemArray.length;
      }
      
      private function getItemIndexInItemArray(param1:int) : int
      {
         var _loc2_:int = int(this._itemArray.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._itemArray[_loc3_].invIdx == param1)
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
         while(_loc2_ < this._itemArray.length)
         {
            if(this._itemArray[_loc2_].accId == param1)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
   }
}

