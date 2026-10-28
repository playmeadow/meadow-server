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
      
      private var _perUserAvId:int;
      
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
      
      public function init(uniqueAvatarId:int, avName:String, type:int, colors:Array, initAccState:AccessoryState = null, initUserName:String = "", initSfsUserId:int = -1, initRoomType:int = 0, initRangedAttack:Array = null, initMeleeAttack:Array = null, initFierceAttack:Array = null, initHealingPower:Array = null, initDefense:Array = null) : void
      {
         this.avTypeId = type;
         this._perUserAvId = uniqueAvatarId;
         this._roomType = initRoomType;
         this._avName = avName;
         this.rangedAttack = initRangedAttack == null ? [0,0] : initRangedAttack;
         this.meleeAttack = initMeleeAttack == null ? [0,0] : initMeleeAttack;
         this.fierceAttack = initFierceAttack == null ? [0,0] : initFierceAttack;
         this.healingPower = initHealingPower == null ? [0,0] : initHealingPower;
         this.defense = initDefense == null ? [0,0] : initDefense;
         if(initUserName != "")
         {
            this.userName = initUserName;
         }
         this._sfsUserId = initSfsUserId;
         this._accState = new AccessoryState();
         if(Boolean(initAccState))
         {
            DebugUtility.debugTrace("Avatar init - copying accState");
            this._accState.copyShownAccRef(initAccState);
            DebugUtility.debugTrace("old ownerAvatar:" + (Boolean(this._accState.ownerAvatar) ? this._accState.ownerAvatar.avName : this._accState.ownerAvatar));
            this._accState.ownerAvatar = this;
            DebugUtility.debugTrace("new ownerAvatar:" + this._accState.ownerAvatar.avName);
         }
         else
         {
            this._accState.init(this);
         }
         if(Boolean(colors))
         {
            this.copyColors(colors);
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
         if(Boolean(this._accState))
         {
            this._accState.destroy();
            this._accState = null;
         }
         if(Boolean(this.inventoryClothing))
         {
            this.inventoryClothing.destroy();
            this.inventoryClothing = null;
         }
         if(Boolean(this.inventoryBodyMod))
         {
            this.inventoryBodyMod.destroy();
            this.inventoryBodyMod = null;
         }
         if(Boolean(this.inventoryDenFull))
         {
            this.inventoryDenFull.destroy();
            this.inventoryDenFull = null;
         }
         if(Boolean(this.inventoryDenPartial))
         {
            this.inventoryDenPartial.destroy();
            this.inventoryDenPartial = null;
         }
         this._colors = null;
      }
      
      public function get perUserAvId() : int
      {
         return this._perUserAvId;
      }
      
      public function set perUserAvId(setperUserAvId:int) : void
      {
         this._perUserAvId = setperUserAvId;
      }
      
      public function get avName() : String
      {
         return LocalizationManager.translateAvatarName(this._avName);
      }
      
      public function set avName(setAvName:String) : void
      {
         this._avName = setAvName;
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function set userName(setUserName:String) : void
      {
         this._userName = setUserName;
      }
      
      public function get sfsUserId() : int
      {
         return this._sfsUserId;
      }
      
      public function set avTypeId(newType:int) : void
      {
         this._avTypeId = newType;
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
      
      public function set colors(setColorra:Array) : void
      {
         this.setColors(setColorra[0],setColorra[1],setColorra[2]);
      }
      
      public function get colors() : Array
      {
         return this._colors;
      }
      
      public function get accShownItems() : Array
      {
         return this._accState.accShownItems;
      }
      
      public function set roomType(newRoomType:int) : void
      {
         this._roomType = newRoomType;
      }
      
      public function copyShownAccRefsFromAvatar(fromAvatar:Avatar) : void
      {
         this._accState.copyShownAccRef(fromAvatar._accState);
         this.inventoryBodyMod.itemArray = fromAvatar.inventoryBodyMod.itemArray.concat();
         if(Boolean(fromAvatar.inventoryClothing))
         {
            this.inventoryClothing.itemArray = fromAvatar.inventoryClothing.itemArray.concat();
         }
      }
      
      public function cloneShownAccFromAvatar(fromAvatar:Avatar) : void
      {
         this._accState.cloneShownAcc(fromAvatar._accState);
         this.inventoryBodyMod.itemArray = fromAvatar.inventoryBodyMod.itemArray.concat();
         if(Boolean(fromAvatar.inventoryClothing))
         {
            this.inventoryClothing.itemArray = fromAvatar.inventoryClothing.itemArray.concat();
         }
      }
      
      public function matchShownAcc(fromAccState:AccessoryState) : void
      {
         this._accState.matchShownItems(fromAccState,this.inventoryClothing.itemArray,this.inventoryBodyMod.itemArray);
      }
      
      public function setColors(color1:uint, color2:uint, color3:uint) : void
      {
         if(this._colors == null)
         {
            this._colors = new Array(3);
         }
         var presetLayer1Colors:uint = uint(gMainFrame.userInfo.getAvatarColorLayer1InfoByAvType(this._avTypeId));
         var base1:int = color1 >> 24 & 0xFF;
         var base2:int = color1 >> 16 & 0xFF;
         var base3:int = presetLayer1Colors >> 8 & 0xFF;
         var base4:int = presetLayer1Colors & 0xFF;
         var presetLayer3Colors:uint = uint(gMainFrame.userInfo.getAvatarColorLayer3InfoByAvType(this._avTypeId));
         var eyes1:int = color3 >> 24 & 0xFF;
         var eyes2:int = presetLayer3Colors >> 16 & 0xFF;
         var eyes3:int = presetLayer3Colors >> 8 & 0xFF;
         var eyes4:int = presetLayer3Colors & 0xFF;
         this._colors[0] = uint(base1 << 24 | base2 << 16 | base3 << 8 | base4);
         this._colors[1] = color2;
         this._colors[2] = uint(eyes1 << 24 | eyes2 << 16 | eyes3 << 8 | eyes4);
         dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
      }
      
      public function copyColors(copyColorra:Array) : void
      {
         this.colors = copyColorra.concat();
      }
      
      public function itemResponseIntegrate(itemList:Array) : void
      {
         var itemListLength:int = 0;
         var currItem:Item = null;
         var si:int = 0;
         if(Boolean(this.inventoryBodyMod) && Boolean(this.inventoryClothing))
         {
            this.removeAllItems();
            itemListLength = int(itemList.length);
            for(si = 0; si < itemListLength; si++)
            {
               currItem = itemList[si];
               if(currItem.type == Item.BODY_MOD_TYPE)
               {
                  if(ItemXtCommManager.canUseItem(currItem.defId,this._avTypeId))
                  {
                     this.inventoryBodyMod.addItem(currItem);
                     if(currItem.getInUse(this._perUserAvId))
                     {
                        this._accState.showAccessory(currItem);
                     }
                  }
               }
               else if(currItem.type == Item.CLOTHING_TYPE)
               {
                  if(this._enviroTypeFlag == 1 << Utility.ENVIRO_LAND || this._enviroTypeFlag == 1 << Utility.ENVIRO_OCEAN || this._enviroTypeFlag == 1 < Utility.ENVIRO_AIR || currItem.enviroType == this._roomType)
                  {
                     this.inventoryClothing.addItem(currItem);
                     if(currItem.getInUse(this._perUserAvId))
                     {
                        this._accState.showAccessory(currItem);
                     }
                  }
               }
               else
               {
                  DebugUtility.debugTrace("ERROR: Bad item type: " + currItem.type);
               }
            }
            dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
         }
      }
      
      public function accStateShowAccessory(showItem:Item, hideItemCallback:Function = null) : void
      {
         var tempItem:Item = null;
         var items:Array = showItem.type == Item.BODY_MOD_TYPE ? this.inventoryBodyMod.itemArray : this.inventoryClothing.itemArray;
         for(var i:int = 0; i < items.length; i++)
         {
            tempItem = items[i];
            if(tempItem.layerId == showItem.layerId && tempItem.getInUse(this._perUserAvId))
            {
               if(tempItem != showItem)
               {
                  this.accStateHideAccessory(tempItem,false);
                  if(hideItemCallback != null)
                  {
                     hideItemCallback(tempItem);
                  }
                  break;
               }
            }
         }
         this._accState.showAccessory(showItem);
         dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
      }
      
      public function accStateHideAccessory(hideItem:Item, bDispatchEvent:Boolean = true) : void
      {
         this._accState.hideAccessory(hideItem);
         if(bDispatchEvent)
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
      
      public function clone(avatarToClone:Avatar) : void
      {
         this._avTypeId = avatarToClone.avTypeId;
         this._perUserAvId = avatarToClone.perUserAvId;
         this._avName = avatarToClone.avName;
         this.userName = avatarToClone.userName;
         this._sfsUserId = avatarToClone._sfsUserId;
         this._accState = new AccessoryState();
         this._accState.cloneShownAcc(avatarToClone.accState);
         this._accState.ownerAvatar = this;
         this.copyColors(avatarToClone.colors);
         this.inventoryClothing = new Inventory();
         this.inventoryClothing.clone(avatarToClone.inventoryClothing);
         this.inventoryBodyMod = new Inventory();
         this.inventoryBodyMod.clone(avatarToClone.inventoryBodyMod);
         this.inventoryDenFull = new Inventory();
         this.inventoryDenFull.clone(avatarToClone.inventoryDenFull);
         this.inventoryDenPartial = new Inventory();
         this.inventoryDenPartial.clone(avatarToClone.inventoryDenPartial);
      }
   }
}

