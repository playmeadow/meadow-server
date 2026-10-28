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
         _accShownItems = [];
         _accShownLayers = [];
         ownerAvatar = param1;
         if(ownerAvatar.avName == null)
         {
            DebugUtility.debugTrace("break here");
         }
      }
      
      public function destroy() : void
      {
         if(_accShownItems)
         {
            _accShownItems = null;
         }
         if(_accShownLayers)
         {
            _accShownLayers = null;
         }
      }
      
      public function copyShownAccRef(param1:AccessoryState) : void
      {
         DebugUtility.debugTrace("AccState copyAcc - ownerAvatar:" + ownerAvatar + (ownerAvatar ? " name:" + ownerAvatar.avName : "") + " copyFrom avatar:" + param1.ownerAvatar + " name:" + param1.ownerAvatar.avName);
         accShownItems = param1.accShownItems;
         accShownLayers = param1.accShownLayers;
      }
      
      public function cloneShownAcc(param1:AccessoryState) : void
      {
         var _loc2_:int = 0;
         accShownItems = param1.accShownItems;
         _loc2_ = 0;
         while(_loc2_ < accShownItems.length)
         {
            accShownItems[_loc2_] = accShownItems[_loc2_].clone();
            _loc2_++;
         }
         accShownLayers = param1.accShownLayers;
      }
      
      public function matchShownItems(param1:AccessoryState, param2:Array, param3:Array) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = int(param1.accShownItems.length);
         accShownLayers = param1.accShownLayers;
         _loc7_ = 0;
         while(_loc7_ < _loc6_)
         {
            if(param1.accShownItems[_loc7_].type == 1)
            {
               _loc4_ = 0;
               while(_loc4_ < param2.length)
               {
                  if(param1.accShownItems[_loc7_].invIdx == param2[_loc4_].invIdx)
                  {
                     accShownItems[_loc7_] = param2[_loc4_];
                     break;
                  }
                  _loc4_++;
               }
            }
            else if(param1.accShownItems[_loc7_].type == 0)
            {
               _loc5_ = 0;
               while(_loc5_ < param3.length)
               {
                  if(param1.accShownItems[_loc7_].invIdx == param3[_loc5_].invIdx)
                  {
                     accShownItems[_loc7_] = param3[_loc5_];
                     break;
                  }
                  _loc5_++;
               }
            }
            _loc7_++;
         }
      }
      
      public function get accShownItems() : Array
      {
         return _accShownItems;
      }
      
      public function set accShownItems(param1:Array) : void
      {
         _accShownItems = param1.concat();
      }
      
      public function get accShownLayers() : Array
      {
         return _accShownLayers;
      }
      
      public function set accShownLayers(param1:Array) : void
      {
         _accShownLayers = param1.concat();
      }
      
      public function showAccessory(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1)
         {
            _loc3_ = 0;
            _loc2_ = int(_accShownItems.length);
            while(_loc3_ < _loc2_)
            {
               if(_accShownItems[_loc3_].invIdx == param1.invIdx)
               {
                  DebugUtility.debugTrace("accessory showId:" + _accShownItems[_loc3_].invIdx + " is already visible!");
                  break;
               }
               _loc3_++;
            }
            if(_loc3_ == _loc2_)
            {
               param1.setInUse(ownerAvatar.perUserAvId,true);
               adjustAvatarQuestValues(true,param1);
               _accShownItems.push(param1);
               _accShownLayers.push(param1.layerId);
            }
         }
         else
         {
            DebugUtility.debugTrace("WARNING: showAccessory received a null item");
         }
      }
      
      public function replaceAccessory(param1:Item, param2:Item) : void
      {
         var _loc4_:int = 0;
         if(param1.accId != param2.accId)
         {
            throw new Error("Tried to replace accessory with different accId! Layers may not match! oldId:" + param1.accId + " newId:" + param2.accId);
         }
         var _loc3_:int = int(_accShownItems.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            if(_accShownItems[_loc4_] == param1)
            {
               _accShownItems[_loc4_] = param2;
               if(!param2.getInUse(ownerAvatar.perUserAvId))
               {
                  _accShownItems.splice(_loc4_,1);
                  _accShownLayers.splice(_loc4_,1);
               }
               break;
            }
            _loc4_++;
         }
      }
      
      public function isAccessoryVisibleByItemId(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_accShownItems.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_accShownItems[_loc3_].invIdx == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isAccessoryVisibleByAccId(param1:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_accShownItems.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_accShownItems[_loc3_].accId == param1)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
      
      public function isAccessoryVisibleByLayer(param1:int) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_accShownLayers.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(_accShownLayers[_loc2_] == param1)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      public function getAccessoryVisibleDefIdByLayer(param1:int) : int
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(_accShownLayers.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(_accShownLayers[_loc2_] == param1)
            {
               return _accShownItems[_loc2_].defId;
            }
            _loc2_++;
         }
         return 0;
      }
      
      public function hideAccessory(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(param1)
         {
            _loc3_ = 0;
            _loc2_ = int(_accShownItems.length);
            while(_loc3_ < _loc2_)
            {
               if(_accShownItems[_loc3_].invIdx == param1.invIdx)
               {
                  param1.setInUse(ownerAvatar.perUserAvId,false);
                  adjustAvatarQuestValues(false,param1);
                  _accShownItems.splice(_loc3_,1);
                  _accShownLayers.splice(_loc3_,1);
                  break;
               }
               _loc3_++;
            }
            if(_loc3_ == _accShownItems.length)
            {
            }
         }
      }
      
      public function hideAll() : void
      {
         while(_accShownItems.length > 0)
         {
            hideAccessory(_accShownItems[0]);
         }
      }
      
      public function removeAllItems() : void
      {
         _accShownItems = [];
         _accShownLayers = [];
         ownerAvatar.meleeAttack = [0,0];
         ownerAvatar.rangedAttack = [0,0];
         ownerAvatar.fierceAttack = [0,0];
         ownerAvatar.healingPower = [0,0];
         ownerAvatar.defense = [0,0];
      }
      
      public function hideAllExceptBase() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(_accShownItems.length);
         while(_loc2_ < _loc1_)
         {
            if(_accShownLayers[_loc2_] != 1)
            {
               hideAccessory(_accShownItems[_loc2_]);
               _loc1_--;
            }
            else
            {
               _loc2_++;
            }
         }
      }
      
      public function hideAllClothingArticles(param1:Array = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:int = int(_accShownItems.length);
         while(_loc4_ < _loc2_)
         {
            _loc3_ = int(_accShownItems[_loc4_].layerId);
            if(_loc3_ > 3)
            {
               if(param1)
               {
                  param1.push(_accShownItems[_loc4_].invIdx);
               }
               hideAccessory(_accShownItems[_loc4_]);
               _loc2_--;
            }
            else
            {
               _loc4_++;
            }
         }
      }
      
      private function adjustAvatarQuestValues(param1:Boolean, param2:Item) : void
      {
         if(param2.attack < 0)
         {
            if(param1)
            {
               var _loc3_:* = 0;
               var _loc4_:* = ownerAvatar.healingPower[_loc3_] + param2.attack * -1;
               ownerAvatar.healingPower[_loc3_] = _loc4_;
            }
            else
            {
               _loc4_ = 0;
               _loc3_ = ownerAvatar.healingPower[_loc4_] - param2.attack * -1;
               ownerAvatar.healingPower[_loc4_] = _loc3_;
            }
         }
         else if(param2.combatType == 1)
         {
            if(param1)
            {
               _loc3_ = 0;
               _loc4_ = ownerAvatar.rangedAttack[_loc3_] + param2.attack;
               ownerAvatar.rangedAttack[_loc3_] = _loc4_;
            }
            else
            {
               _loc4_ = 0;
               _loc3_ = ownerAvatar.rangedAttack[_loc4_] - param2.attack;
               ownerAvatar.rangedAttack[_loc4_] = _loc3_;
            }
         }
         else if(param1)
         {
            _loc3_ = 0;
            _loc4_ = ownerAvatar.meleeAttack[_loc3_] + param2.attack;
            ownerAvatar.meleeAttack[_loc3_] = _loc4_;
         }
         else
         {
            _loc4_ = 0;
            _loc3_ = ownerAvatar.meleeAttack[_loc4_] - param2.attack;
            ownerAvatar.meleeAttack[_loc4_] = _loc3_;
         }
         if(param1)
         {
            _loc3_ = 0;
            _loc4_ = ownerAvatar.fierceAttack[_loc3_] + param2.fierceAttack;
            ownerAvatar.fierceAttack[_loc3_] = _loc4_;
            ownerAvatar.defense[0] += param2.defense;
         }
         else
         {
            _loc3_ = 0;
            _loc4_ = ownerAvatar.fierceAttack[_loc3_] - param2.fierceAttack;
            ownerAvatar.fierceAttack[_loc3_] = _loc4_;
            ownerAvatar.defense[0] -= param2.defense;
         }
         switch(param2.modifierType - 1)
         {
            case 0:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.rangedAttack[_loc3_] + param2.modifierValue;
                  ownerAvatar.rangedAttack[_loc3_] = _loc4_;
               }
               else
               {
                  _loc4_ = 1;
                  _loc3_ = ownerAvatar.rangedAttack[_loc4_] - param2.modifierValue;
                  ownerAvatar.rangedAttack[_loc4_] = _loc3_;
               }
               break;
            case 1:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.meleeAttack[_loc3_] + param2.modifierValue;
                  ownerAvatar.meleeAttack[_loc3_] = _loc4_;
               }
               else
               {
                  _loc4_ = 1;
                  _loc3_ = ownerAvatar.meleeAttack[_loc4_] - param2.modifierValue;
                  ownerAvatar.meleeAttack[_loc4_] = _loc3_;
               }
               break;
            case 2:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.defense[_loc3_] + param2.modifierValue;
                  ownerAvatar.defense[_loc3_] = _loc4_;
               }
               else
               {
                  _loc4_ = 1;
                  _loc3_ = ownerAvatar.defense[_loc4_] - param2.modifierValue;
                  ownerAvatar.defense[_loc4_] = _loc3_;
               }
               break;
            case 3:
               if(param1)
               {
                  _loc3_ = 1;
                  _loc4_ = ownerAvatar.healingPower[_loc3_] + param2.modifierValue;
                  ownerAvatar.healingPower[_loc3_] = _loc4_;
                  break;
               }
               _loc4_ = 1;
               _loc3_ = ownerAvatar.healingPower[_loc4_] - param2.modifierValue;
               ownerAvatar.healingPower[_loc4_] = _loc3_;
         }
      }
   }
}

