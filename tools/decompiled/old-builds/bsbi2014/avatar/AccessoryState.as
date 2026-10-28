package avatar
{
   import com.sbi.debug.DebugUtility;
   import item.Item;
   
   public class AccessoryState
   {
      
      private var _accShownItems:Array;
      
      private var _accShownLayers:Array;
      
      public var ownerAvatar:Avatar;
      
      public function AccessoryState()
      {
         super();
      }
      
      public function init(initOwnerAvatar:Avatar) : void
      {
         this._accShownItems = [];
         this._accShownLayers = [];
         this.ownerAvatar = initOwnerAvatar;
         if(this.ownerAvatar.avName == null)
         {
            DebugUtility.debugTrace("break here");
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._accShownItems))
         {
            this._accShownItems = null;
         }
         if(Boolean(this._accShownLayers))
         {
            this._accShownLayers = null;
         }
      }
      
      public function copyShownAccRef(copyFrom:AccessoryState) : void
      {
         DebugUtility.debugTrace("AccState copyAcc - ownerAvatar:" + this.ownerAvatar + (Boolean(this.ownerAvatar) ? " name:" + this.ownerAvatar.avName : "") + " copyFrom avatar:" + copyFrom.ownerAvatar + " name:" + copyFrom.ownerAvatar.avName);
         this.accShownItems = copyFrom.accShownItems;
         this.accShownLayers = copyFrom.accShownLayers;
      }
      
      public function cloneShownAcc(copyFrom:AccessoryState) : void
      {
         this.accShownItems = copyFrom.accShownItems;
         for(var i:int = 0; i < this.accShownItems.length; i++)
         {
            this.accShownItems[i] = this.accShownItems[i].clone();
         }
         this.accShownLayers = copyFrom.accShownLayers;
      }
      
      public function matchShownItems(copyFrom:AccessoryState, clothingItems:Array, bodyModItems:Array) : void
      {
         var j:int = 0;
         var k:int = 0;
         var numShownItems:int = int(copyFrom.accShownItems.length);
         this.accShownLayers = copyFrom.accShownLayers;
         for(var i:int = 0; i < numShownItems; i++)
         {
            if(copyFrom.accShownItems[i].type == Item.CLOTHING_TYPE)
            {
               for(j = 0; j < clothingItems.length; j++)
               {
                  if(copyFrom.accShownItems[i].invIdx == clothingItems[j].invIdx)
                  {
                     this.accShownItems[i] = clothingItems[j];
                     break;
                  }
               }
            }
            else if(copyFrom.accShownItems[i].type == Item.BODY_MOD_TYPE)
            {
               for(k = 0; k < bodyModItems.length; k++)
               {
                  if(copyFrom.accShownItems[i].invIdx == bodyModItems[k].invIdx)
                  {
                     this.accShownItems[i] = bodyModItems[k];
                     break;
                  }
               }
            }
         }
      }
      
      public function get accShownItems() : Array
      {
         return this._accShownItems;
      }
      
      public function set accShownItems(setShown:Array) : void
      {
         this._accShownItems = setShown.concat();
      }
      
      public function get accShownLayers() : Array
      {
         return this._accShownLayers;
      }
      
      public function set accShownLayers(setShownLayers:Array) : void
      {
         this._accShownLayers = setShownLayers.concat();
      }
      
      public function showAccessory(showItem:Item) : void
      {
         var i:int = 0;
         var accLength:int = 0;
         if(Boolean(showItem))
         {
            i = 0;
            accLength = int(this._accShownItems.length);
            while(i < accLength)
            {
               if(this._accShownItems[i].invIdx == showItem.invIdx)
               {
                  DebugUtility.debugTrace("accessory showId:" + this._accShownItems[i].invIdx + " is already visible!");
                  break;
               }
               i++;
            }
            if(i == accLength)
            {
               showItem.setInUse(this.ownerAvatar.perUserAvId,true);
               this.adjustAvatarQuestValues(true,showItem);
               this._accShownItems.push(showItem);
               this._accShownLayers.push(-1);
            }
         }
         else
         {
            DebugUtility.debugTrace("WARNING: showAccessory received a null item");
         }
      }
      
      public function replaceAccessory(oldAcc:Item, newAcc:Item) : void
      {
         if(oldAcc.accId != newAcc.accId)
         {
            throw new Error("Tried to replace accessory with different accId! Layers may not match! oldId:" + oldAcc.accId + " newId:" + newAcc.accId);
         }
         var rsiLength:int = int(this._accShownItems.length);
         for(var rsai:int = 0; rsai < rsiLength; rsai++)
         {
            if(this._accShownItems[rsai] == oldAcc)
            {
               this._accShownItems[rsai] = newAcc;
               if(!newAcc.getInUse(this.ownerAvatar.perUserAvId))
               {
                  this._accShownItems.splice(rsai,1);
                  this._accShownLayers.splice(rsai,1);
               }
               break;
            }
         }
      }
      
      public function isAccessoryVisibleByItemId(hasItemInvIdx:int) : Boolean
      {
         var itemsLength:int = int(this._accShownItems.length);
         for(var hii:int = 0; hii < itemsLength; hii++)
         {
            if(this._accShownItems[hii].invIdx == hasItemInvIdx)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isAccessoryVisibleByAccId(hasAccId:int) : Boolean
      {
         var itemsLength:int = int(this._accShownItems.length);
         for(var hii:int = 0; hii < itemsLength; hii++)
         {
            if(this._accShownItems[hii].accId == hasAccId)
            {
               return true;
            }
         }
         return false;
      }
      
      public function isAccessoryVisibleByLayer(hasLayerId:int) : Boolean
      {
         var layersLength:int = int(this._accShownLayers.length);
         for(var hli:int = 0; hli < layersLength; hli++)
         {
            if(this._accShownLayers[hli] == hasLayerId)
            {
               return true;
            }
         }
         return false;
      }
      
      public function hideAccessory(hideItem:Item) : void
      {
         var i:int = 0;
         var accLength:int = 0;
         if(Boolean(hideItem))
         {
            i = 0;
            accLength = int(this._accShownItems.length);
            while(i < accLength)
            {
               if(this._accShownItems[i].invIdx == hideItem.invIdx)
               {
                  hideItem.setInUse(this.ownerAvatar.perUserAvId,false);
                  this.adjustAvatarQuestValues(false,hideItem);
                  this._accShownItems.splice(i,1);
                  this._accShownLayers.splice(i,1);
                  break;
               }
               i++;
            }
            if(i == this._accShownItems.length)
            {
            }
         }
      }
      
      public function hideAll() : void
      {
         while(this._accShownItems.length > 0)
         {
            this.hideAccessory(this._accShownItems[0]);
         }
      }
      
      public function removeAllItems() : void
      {
         this._accShownItems = [];
         this._accShownLayers = [];
         this.ownerAvatar.meleeAttack = [0,0];
         this.ownerAvatar.rangedAttack = [0,0];
         this.ownerAvatar.fierceAttack = [0,0];
         this.ownerAvatar.healingPower = [0,0];
         this.ownerAvatar.defense = [0,0];
      }
      
      public function hideAllExceptBase() : void
      {
         var i:int = 0;
         var accLength:int = int(this._accShownItems.length);
         while(i < accLength)
         {
            if(this._accShownLayers[i] != 1)
            {
               this.hideAccessory(this._accShownItems[i]);
               accLength--;
            }
            else
            {
               i++;
            }
         }
      }
      
      public function hideAllClothingArticles(itemsOff:Array = null) : void
      {
         var layerId:int = 0;
         var i:int = 0;
         var accLength:int = int(this._accShownItems.length);
         while(i < accLength)
         {
            layerId = int(this._accShownItems[i].layerId);
            if(layerId > 3)
            {
               if(Boolean(itemsOff))
               {
                  itemsOff.push(this._accShownItems[i].invIdx);
               }
               this.hideAccessory(this._accShownItems[i]);
               accLength--;
            }
            else
            {
               i++;
            }
         }
      }
      
      private function adjustAvatarQuestValues(add:Boolean, myitem:Item) : void
      {
         if(myitem.attack < 0)
         {
            if(add)
            {
               this.ownerAvatar.healingPower[0] += myitem.attack * -1;
            }
            else
            {
               this.ownerAvatar.healingPower[0] -= myitem.attack * -1;
            }
         }
         else if(myitem.combatType == Item.COMBAT_TYPE_RANGED)
         {
            if(add)
            {
               this.ownerAvatar.rangedAttack[0] += myitem.attack;
            }
            else
            {
               this.ownerAvatar.rangedAttack[0] -= myitem.attack;
            }
         }
         else if(add)
         {
            this.ownerAvatar.meleeAttack[0] += myitem.attack;
         }
         else
         {
            this.ownerAvatar.meleeAttack[0] -= myitem.attack;
         }
         if(add)
         {
            this.ownerAvatar.fierceAttack[0] += myitem.fierceAttack;
            this.ownerAvatar.defense[0] += myitem.defense;
         }
         else
         {
            this.ownerAvatar.fierceAttack[0] -= myitem.fierceAttack;
            this.ownerAvatar.defense[0] -= myitem.defense;
         }
         switch(myitem.modifierType)
         {
            case Item.MODIFIER_TYPE_DEFENSE:
               if(add)
               {
                  this.ownerAvatar.defense[1] += myitem.modifierValue;
               }
               else
               {
                  this.ownerAvatar.defense[1] -= myitem.modifierValue;
               }
               break;
            case Item.MODIFIER_TYPE_MELEE:
               if(add)
               {
                  this.ownerAvatar.meleeAttack[1] += myitem.modifierValue;
               }
               else
               {
                  this.ownerAvatar.meleeAttack[1] -= myitem.modifierValue;
               }
               break;
            case Item.MODIFIER_TYPE_RANGED:
               if(add)
               {
                  this.ownerAvatar.rangedAttack[1] += myitem.modifierValue;
               }
               else
               {
                  this.ownerAvatar.rangedAttack[1] -= myitem.modifierValue;
               }
               break;
            case Item.MODIFIER_TYPE_RESTORE:
               if(add)
               {
                  this.ownerAvatar.healingPower[1] += myitem.modifierValue;
               }
               else
               {
                  this.ownerAvatar.healingPower[1] -= myitem.modifierValue;
               }
         }
      }
   }
}

