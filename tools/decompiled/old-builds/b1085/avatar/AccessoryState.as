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
      
      public function init(param1:Avatar) : void
      {
         this._accShownItems = [];
         this._accShownLayers = [];
         this.ownerAvatar = param1;
         if(this.ownerAvatar.avName == null)
         {
            DebugUtility.debugTrace("break here");
         }
      }
      
      public function destroy() : void
      {
         if(this._accShownItems)
         {
            this._accShownItems = null;
         }
         if(this._accShownLayers)
         {
            this._accShownLayers = null;
         }
      }
      
      public function copyShownAccRef(param1:AccessoryState) : void
      {
         DebugUtility.debugTrace("AccState copyAcc - ownerAvatar:" + this.ownerAvatar + (this.ownerAvatar ? " name:" + this.ownerAvatar.avName : "") + " copyFrom avatar:" + param1.ownerAvatar + " name:" + param1.ownerAvatar.avName);
         this.accShownItems = param1.accShownItems;
         this.accShownLayers = param1.accShownLayers;
      }
      
      public function cloneShownAcc(param1:AccessoryState) : void
      {
         this.accShownItems = param1.accShownItems;
         var _loc2_:int = 0;
         while(_loc2_ < this.accShownItems.length)
         {
            this.accShownItems[_loc2_] = this.accShownItems[_loc2_].clone();
            _loc2_++;
         }
         this.accShownLayers = param1.accShownLayers;
      }
      
      public function matchShownItems(param1:AccessoryState, param2:Array, param3:Array) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:int = int(param1.accShownItems.length);
         this.accShownLayers = param1.accShownLayers;
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(param1.accShownItems[_loc5_].type == Item.CLOTHING_TYPE)
            {
               _loc6_ = 0;
               while(_loc6_ < param2.length)
               {
                  if(param1.accShownItems[_loc5_].invIdx == param2[_loc6_].invIdx)
                  {
                     this.accShownItems[_loc5_] = param2[_loc6_];
                     break;
                  }
                  _loc6_++;
               }
            }
            else if(param1.accShownItems[_loc5_].type == Item.BODY_MOD_TYPE)
            {
               _loc7_ = 0;
               while(_loc7_ < param3.length)
               {
                  if(param1.accShownItems[_loc5_].invIdx == param3[_loc7_].invIdx)
                  {
                     this.accShownItems[_loc5_] = param3[_loc7_];
                     break;
                  }
                  _loc7_++;
               }
            }
            _loc5_++;
         }
      }
      
      public function get accShownItems() : Array
      {
         return this._accShownItems;
      }
      
      public function set accShownItems(param1:Array) : void
      {
         this._accShownItems = param1.concat();
      }
      
      public function get accShownLayers() : Array
      {
         return this._accShownLayers;
      }
      
      public function set accShownLayers(param1:Array) : void
      {
         this._accShownLayers = param1.concat();
      }
      
      public function showAccessory(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            _loc3_ = int(this._accShownItems.length);
            while(_loc2_ < _loc3_)
            {
               if(this._accShownItems[_loc2_].invIdx == param1.invIdx)
               {
                  DebugUtility.debugTrace("accessory showId:" + this._accShownItems[_loc2_].invIdx + " is already visible!");
                  break;
               }
               _loc2_++;
            }
            if(_loc2_ == _loc3_)
            {
               param1.setInUse(this.ownerAvatar.dbAvId,true);
               this.adjustAvatarQuestValues(true,param1);
               this._accShownItems.push(param1);
               this._accShownLayers.push(-1);
            }
         }
         else
         {
            DebugUtility.debugTrace("WARNING: showAccessory received a null item");
         }
      }
      
      public function replaceAccessory(param1:Item, param2:Item) : void
      {
         if(param1.accId != param2.accId)
         {
            throw new Error("Tried to replace accessory with different accId! Layers may not match! oldId:" + param1.accId + " newId:" + param2.accId);
         }
         var _loc3_:int = int(this._accShownItems.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(this._accShownItems[_loc4_] == param1)
            {
               this._accShownItems[_loc4_] = param2;
               if(!param2.getInUse(this.ownerAvatar.dbAvId))
               {
                  this._accShownItems.splice(_loc4_,1);
                  this._accShownLayers.splice(_loc4_,1);
               }
               break;
            }
            _loc4_++;
         }
      }
      
      public function isAccessoryVisibleByItemId(param1:int) : Boolean
      {
         var _loc2_:int = int(this._accShownItems.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._accShownItems[_loc3_].invIdx == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isAccessoryVisibleByAccId(param1:int) : Boolean
      {
         var _loc2_:int = int(this._accShownItems.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._accShownItems[_loc3_].accId == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isAccessoryVisibleByLayer(param1:int) : Boolean
      {
         var _loc2_:int = int(this._accShownLayers.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._accShownLayers[_loc3_] == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function hideAccessory(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(param1)
         {
            _loc2_ = 0;
            _loc3_ = int(this._accShownItems.length);
            while(_loc2_ < _loc3_)
            {
               if(this._accShownItems[_loc2_].invIdx == param1.invIdx)
               {
                  param1.setInUse(this.ownerAvatar.dbAvId,false);
                  this.adjustAvatarQuestValues(false,param1);
                  this._accShownItems.splice(_loc2_,1);
                  this._accShownLayers.splice(_loc2_,1);
                  break;
               }
               _loc2_++;
            }
            if(_loc2_ == this._accShownItems.length)
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
         var _loc1_:int = 0;
         var _loc2_:* = int(this._accShownItems.length);
         while(_loc1_ < _loc2_)
         {
            if(this._accShownLayers[_loc1_] != 1)
            {
               this.hideAccessory(this._accShownItems[_loc1_]);
               _loc2_--;
            }
            else
            {
               _loc1_++;
            }
         }
      }
      
      public function hideAllClothingArticles(param1:Array = null) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:* = int(this._accShownItems.length);
         while(_loc2_ < _loc3_)
         {
            _loc4_ = int(this._accShownItems[_loc2_].layerId);
            if(_loc4_ > 3)
            {
               if(param1)
               {
                  param1.push(this._accShownItems[_loc2_].invIdx);
               }
               this.hideAccessory(this._accShownItems[_loc2_]);
               _loc3_--;
            }
            else
            {
               _loc2_++;
            }
         }
      }
      
      private function adjustAvatarQuestValues(param1:Boolean, param2:Item) : void
      {
         if(param2.attack < 0)
         {
            if(param1)
            {
               this.ownerAvatar.healingPower[0] += param2.attack * -1;
            }
            else
            {
               this.ownerAvatar.healingPower[0] -= param2.attack * -1;
            }
         }
         else if(param2.combatType == Item.COMBAT_TYPE_RANGED)
         {
            if(param1)
            {
               this.ownerAvatar.rangedAttack[0] += param2.attack;
            }
            else
            {
               this.ownerAvatar.rangedAttack[0] -= param2.attack;
            }
         }
         else if(param1)
         {
            this.ownerAvatar.meleeAttack[0] += param2.attack;
         }
         else
         {
            this.ownerAvatar.meleeAttack[0] -= param2.attack;
         }
         if(param1)
         {
            this.ownerAvatar.fierceAttack[0] += param2.fierceAttack;
            this.ownerAvatar.defense[0] += param2.defense;
         }
         else
         {
            this.ownerAvatar.fierceAttack[0] -= param2.fierceAttack;
            this.ownerAvatar.defense[0] -= param2.defense;
         }
         switch(param2.modifierType)
         {
            case Item.MODIFIER_TYPE_DEFENSE:
               if(param1)
               {
                  this.ownerAvatar.defense[1] += param2.modifierValue;
               }
               else
               {
                  this.ownerAvatar.defense[1] -= param2.modifierValue;
               }
               break;
            case Item.MODIFIER_TYPE_MELEE:
               if(param1)
               {
                  this.ownerAvatar.meleeAttack[1] += param2.modifierValue;
               }
               else
               {
                  this.ownerAvatar.meleeAttack[1] -= param2.modifierValue;
               }
               break;
            case Item.MODIFIER_TYPE_RANGED:
               if(param1)
               {
                  this.ownerAvatar.rangedAttack[1] += param2.modifierValue;
               }
               else
               {
                  this.ownerAvatar.rangedAttack[1] -= param2.modifierValue;
               }
               break;
            case Item.MODIFIER_TYPE_RESTORE:
               if(param1)
               {
                  this.ownerAvatar.healingPower[1] += param2.modifierValue;
               }
               else
               {
                  this.ownerAvatar.healingPower[1] -= param2.modifierValue;
               }
         }
      }
   }
}

