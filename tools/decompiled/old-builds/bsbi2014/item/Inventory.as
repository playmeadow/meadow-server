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
      
      public function init(initAccState:AccessoryState) : void
      {
         this._itemArray = [];
         this._accState = initAccState;
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         if(Boolean(this._itemArray))
         {
            for(i = 0; i < this._itemArray.length; i++)
            {
               this._itemArray[i].destroy();
            }
            this._itemArray = null;
         }
         if(Boolean(this._accState))
         {
            this._accState.destroy();
            this._accState = null;
         }
      }
      
      public function itemTypeMatch(itemParam:Item) : Boolean
      {
         return true;
      }
      
      public function eraseAll() : void
      {
         this._itemArray = [];
      }
      
      public function clone(cloneFromInv:Inventory) : void
      {
         var ci:Item = null;
         this._itemArray = [];
         this._accState = cloneFromInv._accState;
         var clonera:Array = cloneFromInv._itemArray;
         for each(ci in clonera)
         {
            this.addItem(ci.clone());
         }
      }
      
      public function addItem(itemParam:Item) : void
      {
         var itemLength:int = 0;
         var i:int = 0;
         if(this._itemArray != null)
         {
            if(this.hasItem(itemParam))
            {
               itemLength = int(this._itemArray.length);
               for(i = 0; i < itemLength; i++)
               {
                  if(Boolean(this._itemArray[i].ifItemDiffers(itemParam)))
                  {
                     this.updateItem(itemParam);
                     break;
                  }
               }
            }
            else
            {
               this._itemArray.push(itemParam);
            }
         }
         else
         {
            this._itemArray.push(itemParam);
         }
      }
      
      public function removeItem(removeItem:Item) : void
      {
         var removeItemIdxInItemArray:int = this.getItemIndexInItemArray(removeItem.invIdx);
         if(removeItemIdxInItemArray >= 0)
         {
            this._itemArray.splice(removeItemIdxInItemArray,1);
         }
      }
      
      private function updateItem(updateItem:Item) : void
      {
         var updateItemIdxInItemArray:int = this.getItemIndexInItemArray(updateItem.invIdx);
         if(updateItemIdxInItemArray >= 0)
         {
            if(this._accState != null)
            {
               this._accState.replaceAccessory(this._itemArray[updateItemIdxInItemArray],updateItem);
            }
            this._itemArray[updateItemIdxInItemArray] = updateItem;
            return;
         }
         throw new Error("WARNING: Inventory- Cannot update an item that doesn\'t exist in inventory.");
      }
      
      public function hasItem(itemParam:Item) : Boolean
      {
         if(this.getItemIndexInItemArray(itemParam.invIdx) >= 0)
         {
            return true;
         }
         return false;
      }
      
      public function hasItemByAccId(itemAccId:int) : Boolean
      {
         return Boolean(this.getItemIndexInItemArrayByAccId(itemAccId) >= 0);
      }
      
      public function get itemArray() : Array
      {
         return this._itemArray;
      }
      
      public function set itemArray(itemArray:Array) : void
      {
         var i:int = 0;
         if(Boolean(itemArray))
         {
            this._itemArray = itemArray;
            for(i = 0; i < this._itemArray.length; i++)
            {
               this._itemArray[i] = this._itemArray[i].clone();
            }
         }
      }
      
      public function get numItems() : int
      {
         return this._itemArray.length;
      }
      
      private function getItemIndexInItemArray(invIdx:int) : int
      {
         var itemLength:int = int(this._itemArray.length);
         for(var i:int = 0; i < itemLength; i++)
         {
            if(this._itemArray[i].invIdx == invIdx)
            {
               return i;
            }
         }
         return -1;
      }
      
      private function getItemIndexInItemArrayByAccId(accId:int) : int
      {
         for(var i:int = 0; i < this._itemArray.length; i++)
         {
            if(this._itemArray[i].accId == accId)
            {
               return i;
            }
         }
         return -1;
      }
   }
}

