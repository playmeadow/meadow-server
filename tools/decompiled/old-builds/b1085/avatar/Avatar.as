package avatar
{
   import com.sbi.debug.DebugUtility;
   import flash.events.EventDispatcher;
   import item.Inventory;
   import item.Item;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   
   public class Avatar extends EventDispatcher
   {
      
      private var _avName:String;
      
      private var _userName:String;
      
      private var _sfsUserId:int;
      
      private var _dbAvId:int;
      
      private var _avTypeId:int;
      
      private var _roomType:int;
      
      private var _enviroTypeFlag:int;
      
      private var _colors:Array;
      
      private var _accState:AccessoryState;
      
      public var inventoryClothing:Inventory;
      
      public var inventoryBodyMod:Inventory;
      
      public var inventoryDenFull:Inventory;
      
      public var inventoryDenPartial:Inventory;
      
      public var isShaman:Boolean;
      
      public var shamanName:String;
      
      public var shamanText:String;
      
      public var rangedAttack:Array;
      
      public var meleeAttack:Array;
      
      public var fierceAttack:Array;
      
      public var healingPower:Array;
      
      public var defense:Array;
      
      public function Avatar()
      {
         super();
      }
      
      public function init(param1:int, param2:String, param3:int, param4:Array, param5:AccessoryState = null, param6:String = "", param7:int = -1, param8:int = 0, param9:Array = null, param10:Array = null, param11:Array = null, param12:Array = null, param13:Array = null) : void
      {
         this.avTypeId = param3;
         this._dbAvId = param1;
         this._roomType = param8;
         this._avName = param2;
         this.rangedAttack = param9 == null ? [0,0] : param9;
         this.meleeAttack = param10 == null ? [0,0] : param10;
         this.fierceAttack = param11 == null ? [0,0] : param11;
         this.healingPower = param12 == null ? [0,0] : param12;
         this.defense = param13 == null ? [0,0] : param13;
         if(param6 != "")
         {
            this.userName = param6;
         }
         this._sfsUserId = param7;
         this._accState = new AccessoryState();
         if(param5)
         {
            DebugUtility.debugTrace("Avatar init - copying accState");
            this._accState.copyShownAccRef(param5);
            DebugUtility.debugTrace("old ownerAvatar:" + (this._accState.ownerAvatar ? this._accState.ownerAvatar.avName : this._accState.ownerAvatar));
            this._accState.ownerAvatar = this;
            DebugUtility.debugTrace("new ownerAvatar:" + this._accState.ownerAvatar.avName);
         }
         else
         {
            this._accState.init(this);
         }
         if(param4)
         {
            this.copyColors(param4);
         }
         else
         {
            this._colors = null;
         }
         this.inventoryClothing = new Inventory();
         this.inventoryBodyMod = new Inventory();
         this.inventoryDenFull = new Inventory();
         this.inventoryDenPartial = new Inventory();
         this.inventoryClothing.init(this._accState);
         this.inventoryBodyMod.init(this._accState);
         this.inventoryDenFull.init(this._accState);
         this.inventoryDenPartial.init(this._accState);
      }
      
      public function destroy() : void
      {
         if(this._accState)
         {
            this._accState.destroy();
            this._accState = null;
         }
         if(this.inventoryClothing)
         {
            this.inventoryClothing.destroy();
            this.inventoryClothing = null;
         }
         if(this.inventoryBodyMod)
         {
            this.inventoryBodyMod.destroy();
            this.inventoryBodyMod = null;
         }
         if(this.inventoryDenFull)
         {
            this.inventoryDenFull.destroy();
            this.inventoryDenFull = null;
         }
         if(this.inventoryDenPartial)
         {
            this.inventoryDenPartial.destroy();
            this.inventoryDenPartial = null;
         }
         this._colors = null;
      }
      
      public function get dbAvId() : int
      {
         return this._dbAvId;
      }
      
      public function set dbAvId(param1:int) : void
      {
         this._dbAvId = param1;
      }
      
      public function get avName() : String
      {
         return LocalizationManager.translateAvatarName(this._avName);
      }
      
      public function set avName(param1:String) : void
      {
         this._avName = param1;
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function set userName(param1:String) : void
      {
         this._userName = param1;
      }
      
      public function get sfsUserId() : int
      {
         return this._sfsUserId;
      }
      
      public function set avTypeId(param1:int) : void
      {
         this._avTypeId = param1;
         this._enviroTypeFlag = gMainFrame.userInfo.getAvatarEnviroTypeFlagByAvType(this._avTypeId);
      }
      
      public function get avTypeId() : int
      {
         return this._avTypeId;
      }
      
      public function get enviroTypeFlag() : int
      {
         return this._enviroTypeFlag;
      }
      
      public function set colors(param1:Array) : void
      {
         this.setColors(param1[0],param1[1],param1[2]);
      }
      
      public function get colors() : Array
      {
         return this._colors;
      }
      
      public function get accShownItems() : Array
      {
         return this._accState.accShownItems;
      }
      
      public function copyShownAccRefsFromAvatar(param1:Avatar) : void
      {
         this._accState.copyShownAccRef(param1._accState);
         this.inventoryBodyMod.itemArray = param1.inventoryBodyMod.itemArray.concat();
         if(param1.inventoryClothing)
         {
            this.inventoryClothing.itemArray = param1.inventoryClothing.itemArray.concat();
         }
      }
      
      public function cloneShownAccFromAvatar(param1:Avatar) : void
      {
         this._accState.cloneShownAcc(param1._accState);
         this.inventoryBodyMod.itemArray = param1.inventoryBodyMod.itemArray.concat();
         if(param1.inventoryClothing)
         {
            this.inventoryClothing.itemArray = param1.inventoryClothing.itemArray.concat();
         }
      }
      
      public function matchShownAcc(param1:AccessoryState) : void
      {
         this._accState.matchShownItems(param1,this.inventoryClothing.itemArray,this.inventoryBodyMod.itemArray);
      }
      
      public function setColors(param1:uint, param2:uint, param3:uint) : void
      {
         if(this._colors == null)
         {
            this._colors = new Array(3);
         }
         var _loc4_:uint = uint(gMainFrame.userInfo.getAvatarColorLayer1InfoByAvType(this._avTypeId));
         var _loc5_:int = param1 >> 24 & 0xFF;
         var _loc6_:int = param1 >> 16 & 0xFF;
         var _loc7_:int = _loc4_ >> 8 & 0xFF;
         var _loc8_:int = _loc4_ & 0xFF;
         var _loc9_:uint = uint(gMainFrame.userInfo.getAvatarColorLayer3InfoByAvType(this._avTypeId));
         var _loc10_:int = param3 >> 24 & 0xFF;
         var _loc11_:int = _loc9_ >> 16 & 0xFF;
         var _loc12_:int = _loc9_ >> 8 & 0xFF;
         var _loc13_:int = _loc9_ & 0xFF;
         this._colors[0] = uint(_loc5_ << 24 | _loc6_ << 16 | _loc7_ << 8 | _loc8_);
         this._colors[1] = param2;
         this._colors[2] = uint(_loc10_ << 24 | _loc11_ << 16 | _loc12_ << 8 | _loc13_);
         dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
      }
      
      public function copyColors(param1:Array) : void
      {
         this.colors = param1.concat();
      }
      
      public function itemResponseIntegrate(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Item = null;
         var _loc4_:int = 0;
         if(Boolean(this.inventoryBodyMod) && Boolean(this.inventoryClothing))
         {
            this.removeAllItems();
            _loc2_ = int(param1.length);
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_ = param1[_loc4_];
               if(_loc3_.type == Item.BODY_MOD_TYPE)
               {
                  if(ItemXtCommManager.canUseItem(_loc3_.defId,this._avTypeId))
                  {
                     this.inventoryBodyMod.addItem(_loc3_);
                     if(_loc3_.getInUse(this._dbAvId))
                     {
                        this._accState.showAccessory(_loc3_);
                     }
                  }
               }
               else if(_loc3_.type == Item.CLOTHING_TYPE)
               {
                  if(this._enviroTypeFlag == 1 << Utility.ENVIRO_LAND || this._enviroTypeFlag == 1 << Utility.ENVIRO_OCEAN || this._enviroTypeFlag == 1 < Utility.ENVIRO_AIR || _loc3_.enviroType == this._roomType)
                  {
                     this.inventoryClothing.addItem(_loc3_);
                     if(_loc3_.getInUse(this._dbAvId))
                     {
                        this._accState.showAccessory(_loc3_);
                     }
                  }
               }
               else
               {
                  DebugUtility.debugTrace("ERROR: Bad item type: " + _loc3_.type);
               }
               _loc4_++;
            }
            dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
         }
      }
      
      public function accStateShowAccessory(param1:Item, param2:Function = null) : void
      {
         var _loc4_:Item = null;
         var _loc3_:Array = param1.type == Item.BODY_MOD_TYPE ? this.inventoryBodyMod.itemArray : this.inventoryClothing.itemArray;
         var _loc5_:int = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc5_];
            if(_loc4_.layerId == param1.layerId && _loc4_.getInUse(this._dbAvId))
            {
               if(_loc4_ != param1)
               {
                  this.accStateHideAccessory(_loc4_,false);
                  if(param2 != null)
                  {
                     param2(_loc4_);
                  }
                  break;
               }
            }
            _loc5_++;
         }
         this._accState.showAccessory(param1);
         dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
      }
      
      public function accStateHideAccessory(param1:Item, param2:Boolean = true) : void
      {
         this._accState.hideAccessory(param1);
         if(param2)
         {
            dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
         }
      }
      
      public function removeAllItems() : void
      {
         this.inventoryBodyMod.itemArray = [];
         this.inventoryClothing.itemArray = [];
         this._accState.removeAllItems();
      }
      
      public function get accState() : AccessoryState
      {
         return this._accState;
      }
      
      public function clone(param1:Avatar) : void
      {
         this._avTypeId = param1.avTypeId;
         this._dbAvId = param1.dbAvId;
         this._avName = param1.avName;
         this.userName = param1.userName;
         this._sfsUserId = param1._sfsUserId;
         this._accState = new AccessoryState();
         this._accState.cloneShownAcc(param1.accState);
         this._accState.ownerAvatar = this;
         this.copyColors(param1.colors);
         this.inventoryClothing = new Inventory();
         this.inventoryClothing.clone(param1.inventoryClothing);
         this.inventoryBodyMod = new Inventory();
         this.inventoryBodyMod.clone(param1.inventoryBodyMod);
         this.inventoryDenFull = new Inventory();
         this.inventoryDenFull.clone(param1.inventoryDenFull);
         this.inventoryDenPartial = new Inventory();
         this.inventoryDenPartial.clone(param1.inventoryDenPartial);
      }
   }
}

