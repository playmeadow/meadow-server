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
      
      private var _uuid:String;
      
      private var _sfsUserId:int;
      
      private var _perUserAvId:int;
      
      private var _avTypeId:int;
      
      private var _roomType:int;
      
      private var _customAvId:int;
      
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
      
      public function init(param1:int, param2:String, param3:int, param4:Array, param5:int = -1, param6:AccessoryState = null, param7:String = "", param8:int = -1, param9:int = 0, param10:Array = null, param11:Array = null, param12:Array = null, param13:Array = null, param14:Array = null) : void
      {
         avTypeId = param3;
         _perUserAvId = param1;
         _roomType = param9;
         _customAvId = param5;
         _avName = param2;
         rangedAttack = param10 == null ? [0,0] : param10;
         meleeAttack = param11 == null ? [0,0] : param11;
         fierceAttack = param12 == null ? [0,0] : param12;
         healingPower = param13 == null ? [0,0] : param13;
         defense = param14 == null ? [0,0] : param14;
         if(param7 != "")
         {
            userName = param7;
         }
         _sfsUserId = param8;
         _accState = new AccessoryState();
         if(param6)
         {
            DebugUtility.debugTrace("Avatar init - copying accState");
            _accState.copyShownAccRef(param6);
            DebugUtility.debugTrace("old ownerAvatar:" + (_accState.ownerAvatar ? _accState.ownerAvatar.avName : _accState.ownerAvatar));
            _accState.ownerAvatar = this;
            DebugUtility.debugTrace("new ownerAvatar:" + _accState.ownerAvatar.avName);
         }
         else
         {
            _accState.init(this);
         }
         if(param4)
         {
            copyColors(param4);
         }
         else
         {
            _colors = null;
         }
         inventoryClothing = new Inventory();
         inventoryBodyMod = new Inventory();
         inventoryDenFull = new Inventory();
         inventoryDenPartial = new Inventory();
         inventoryClothing.init(_accState);
         inventoryBodyMod.init(_accState);
         inventoryDenFull.init(_accState);
         inventoryDenPartial.init(_accState);
      }
      
      public function destroy() : void
      {
         if(_accState)
         {
            _accState.destroy();
            _accState = null;
         }
         if(inventoryClothing)
         {
            inventoryClothing.destroy();
            inventoryClothing = null;
         }
         if(inventoryBodyMod)
         {
            inventoryBodyMod.destroy();
            inventoryBodyMod = null;
         }
         if(inventoryDenFull)
         {
            inventoryDenFull.destroy();
            inventoryDenFull = null;
         }
         if(inventoryDenPartial)
         {
            inventoryDenPartial.destroy();
            inventoryDenPartial = null;
         }
         _colors = null;
      }
      
      public function get perUserAvId() : int
      {
         return _perUserAvId;
      }
      
      public function set perUserAvId(param1:int) : void
      {
         _perUserAvId = param1;
      }
      
      public function get avName() : String
      {
         return LocalizationManager.translateAvatarName(_avName);
      }
      
      public function set avName(param1:String) : void
      {
         _avName = param1;
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function set userName(param1:String) : void
      {
         _userName = param1;
      }
      
      public function get uuid() : String
      {
         return _uuid;
      }
      
      public function set uuid(param1:String) : void
      {
         _uuid = param1;
      }
      
      public function get sfsUserId() : int
      {
         return _sfsUserId;
      }
      
      public function set avTypeId(param1:int) : void
      {
         _avTypeId = param1;
         _enviroTypeFlag = gMainFrame.userInfo.getAvatarEnviroTypeFlagByAvType(_avTypeId);
      }
      
      public function get avTypeId() : int
      {
         return _avTypeId;
      }
      
      public function get enviroTypeFlag() : int
      {
         return _enviroTypeFlag;
      }
      
      public function set colors(param1:Array) : void
      {
         setColors(param1[0],param1[1],param1[2]);
      }
      
      public function get colors() : Array
      {
         return _colors;
      }
      
      public function get accShownItems() : Array
      {
         return _accState.accShownItems;
      }
      
      public function set roomType(param1:int) : void
      {
         _roomType = param1;
      }
      
      public function get customAvId() : int
      {
         return _customAvId;
      }
      
      public function set customAvId(param1:int) : void
      {
         _customAvId = param1;
      }
      
      public function get inUsePatternId() : int
      {
         return _accState.getAccessoryVisibleDefIdByLayer(2);
      }
      
      public function get inUseEyeId() : int
      {
         return _accState.getAccessoryVisibleDefIdByLayer(3);
      }
      
      public function copyShownAccRefsFromAvatar(param1:Avatar) : void
      {
         _accState.copyShownAccRef(param1._accState);
         inventoryBodyMod.itemArray = param1.inventoryBodyMod.itemArray.concat();
         if(param1.inventoryClothing)
         {
            inventoryClothing.itemArray = param1.inventoryClothing.itemArray.concat();
         }
      }
      
      public function cloneShownAccFromAvatar(param1:Avatar) : void
      {
         _accState.cloneShownAcc(param1._accState);
         inventoryBodyMod.itemArray = param1.inventoryBodyMod.itemArray.concat();
         if(param1.inventoryClothing)
         {
            inventoryClothing.itemArray = param1.inventoryClothing.itemArray.concat();
         }
      }
      
      public function matchShownAcc(param1:AccessoryState) : void
      {
         _accState.matchShownItems(param1,inventoryClothing.itemArray,inventoryBodyMod.itemArray);
      }
      
      public function setColors(param1:uint, param2:uint, param3:uint) : void
      {
         if(_colors == null)
         {
            _colors = new Array(3);
         }
         var _loc13_:uint = uint(gMainFrame.userInfo.getAvatarColorLayer1InfoByAvType(_avTypeId));
         var _loc11_:int = param1 >> 24 & 0xFF;
         var _loc12_:int = param1 >> 16 & 0xFF;
         var _loc9_:int = _loc13_ >> 8 & 0xFF;
         var _loc10_:int = _loc13_ & 0xFF;
         var _loc4_:uint = uint(gMainFrame.userInfo.getAvatarColorLayer3InfoByAvType(_avTypeId));
         var _loc5_:int = param3 >> 24 & 0xFF;
         var _loc7_:int = _loc4_ >> 16 & 0xFF;
         var _loc8_:int = _loc4_ >> 8 & 0xFF;
         var _loc6_:int = _loc4_ & 0xFF;
         _colors[0] = uint(_loc11_ << 24 | _loc12_ << 16 | _loc9_ << 8 | _loc10_);
         _colors[1] = param2;
         _colors[2] = uint(_loc5_ << 24 | _loc7_ << 16 | _loc8_ << 8 | _loc6_);
         dispatchEvent(new AvatarEvent("OnAvatarChanged"));
      }
      
      public function copyColors(param1:Array) : void
      {
         colors = param1.concat();
      }
      
      public function itemResponseIntegrate(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Item = null;
         var _loc5_:Boolean = false;
         var _loc4_:int = 0;
         if(inventoryBodyMod && inventoryClothing)
         {
            removeAllItems();
            _loc2_ = int(param1.length);
            _loc5_ = _customAvId != -1;
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_ = param1[_loc4_];
               if(_loc3_.type == 0)
               {
                  if(ItemXtCommManager.canUseItem(_loc3_.defId,this,_loc5_))
                  {
                     inventoryBodyMod.addItem(_loc3_);
                     if(_loc3_.getInUse(_perUserAvId))
                     {
                        _accState.showAccessory(_loc3_);
                     }
                  }
               }
               else if(_loc3_.type == 1)
               {
                  if(_enviroTypeFlag == 1 << 0 || _enviroTypeFlag == 1 << 1 || _enviroTypeFlag == true || _loc3_.enviroType == _roomType)
                  {
                     inventoryClothing.addItem(_loc3_);
                     if(_loc3_.getInUse(_perUserAvId))
                     {
                        _accState.showAccessory(_loc3_);
                     }
                  }
               }
               else
               {
                  DebugUtility.debugTrace("ERROR: Bad item type: " + _loc3_.type);
               }
               _loc4_++;
            }
            dispatchEvent(new AvatarEvent("OnAvatarChanged"));
         }
      }
      
      public function accStateShowAccessory(param1:Item, param2:Function = null) : void
      {
         var _loc4_:Item = null;
         var _loc5_:int = 0;
         var _loc3_:Array = param1.type == 0 ? inventoryBodyMod.itemArray : inventoryClothing.itemArray;
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc5_];
            if(_loc4_.layerId == param1.layerId && _loc4_.getInUse(_perUserAvId))
            {
               if(_loc4_ != param1)
               {
                  accStateHideAccessory(_loc4_,false);
                  if(param2 != null)
                  {
                     param2(_loc4_);
                  }
                  break;
               }
            }
            _loc5_++;
         }
         _accState.showAccessory(param1);
         dispatchEvent(new AvatarEvent("OnAvatarChanged"));
      }
      
      public function accStateHideAccessory(param1:Item, param2:Boolean = true) : void
      {
         _accState.hideAccessory(param1);
         if(param2)
         {
            dispatchEvent(new AvatarEvent("OnAvatarChanged"));
         }
      }
      
      public function removeAllItems() : void
      {
         inventoryBodyMod.itemArray = [];
         inventoryClothing.itemArray = [];
         _accState.removeAllItems();
      }
      
      public function get accState() : AccessoryState
      {
         return _accState;
      }
      
      public function clone(param1:Avatar) : void
      {
         _avTypeId = param1.avTypeId;
         _perUserAvId = param1.perUserAvId;
         _avName = param1.avName;
         userName = param1.userName;
         _sfsUserId = param1._sfsUserId;
         _accState = new AccessoryState();
         _accState.cloneShownAcc(param1.accState);
         _accState.ownerAvatar = this;
         copyColors(param1.colors);
         inventoryClothing = new Inventory();
         inventoryClothing.clone(param1.inventoryClothing);
         inventoryBodyMod = new Inventory();
         inventoryBodyMod.clone(param1.inventoryBodyMod);
         inventoryDenFull = new Inventory();
         inventoryDenFull.clone(param1.inventoryDenFull);
         inventoryDenPartial = new Inventory();
         inventoryDenPartial.clone(param1.inventoryDenPartial);
      }
   }
}

