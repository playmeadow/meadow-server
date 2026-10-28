package item
{
   import avatar.AvatarXtCommManager;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerBitmap;
   import flash.display.Sprite;
   
   public class Item
   {
      
      public static const BODY_MOD_TYPE:int = 0;
      
      public static const CLOTHING_TYPE:int = 1;
      
      public static const BASE_LAYER:int = 1;
      
      public static const PATTERN_LAYER:int = 2;
      
      public static const EYE_LAYER:int = 3;
      
      public static const TAIL_LAYER:int = 4;
      
      public static const LEG_LAYER:int = 5;
      
      public static const BACK_LAYER:int = 6;
      
      public static const NECK_LAYER:int = 7;
      
      public static const HEAD_LAYER_1:int = 8;
      
      public static const HEAD_LAYER_2:int = 9;
      
      public static const HEAD_LAYER_3:int = 10;
      
      public static const OCEAN_LEG_LAYER:int = 8;
      
      public static const OCEAN_BACK_LAYER:int = 6;
      
      public static const OCEAN_HEAD_LAYER:int = 7;
      
      public static const OCEAN_NECK_LAYER:int = 5;
      
      public static const NUM_DETAILS_PER_ITEM:int = 11;
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      public static const GEM_CURRENCY:int = 0;
      
      public static const TICKET_CURRENCY:int = 1;
      
      public static const ORB_CURRENCY:int = 2;
      
      public static const DIAMOND_CURRENCY:int = 3;
      
      public static const COMBAT_TYPE_MELEE:int = 0;
      
      public static const COMBAT_TYPE_RANGED:int = 1;
      
      public static const MODIFIER_TYPE_NONE:int = 0;
      
      public static const MODIFIER_TYPE_RANGED:int = 1;
      
      public static const MODIFIER_TYPE_MELEE:int = 2;
      
      public static const MODIFIER_TYPE_DEFENSE:int = 3;
      
      public static const MODIFIER_TYPE_RESTORE:int = 4;
      
      public var layerId:int;
      
      public var invIdx:int;
      
      public var accId:int;
      
      public var color:uint;
      
      public var name:String;
      
      public var isGiftable:Boolean;
      
      public var value:int;
      
      public var inUseFlagLand:int;
      
      public var inUseFlagOcean:int;
      
      public var isMemberOnly:Boolean;
      
      public var itemStatus:int;
      
      public var type:int;
      
      public var enviroType:int;
      
      public var recycleValue:int;
      
      public var currencyType:int;
      
      public var avatarUseFlag:Object;
      
      public var endTime:uint;
      
      private var _diamondDefId:int = -1;
      
      private var _defId:int;
      
      private var _icon:Sprite;
      
      private var _iconHelper:SimpleIcon;
      
      private var _iconBitmap:LayerBitmap;
      
      private var _largeIcon:Sprite;
      
      private var _largeIconHelper:SimpleIcon;
      
      private var _largeIconBitmap:LayerBitmap;
      
      private var _isShopItem:Boolean;
      
      public var isIconLoaded:Boolean;
      
      public var imageLoadedCallback:Function;
      
      private var _iconLayerID:int = -1;
      
      private var _iconColorID:int = 0;
      
      private var _attackMediaRefId:int = 0;
      
      private var _defense:int = 0;
      
      private var _attack:int = 0;
      
      private var _combatType:int = 0;
      
      private var _fierce:int = 0;
      
      private var _modifierType:int = 0;
      
      private var _modifierValue:int = 0;
      
      public function Item()
      {
         super();
      }
      
      public function init(initDefId:int, initInvIdx:int = 0, initColor:uint = 0, initInUseFlagLand:int = 0, initInUseFlagOcean:int = 0, initIsShopItem:Boolean = false, initEndTime:uint = 0) : void
      {
         this._defId = initDefId;
         this.invIdx = initInvIdx;
         this.color = initColor;
         this.inUseFlagLand = initInUseFlagLand;
         this.inUseFlagOcean = initInUseFlagOcean;
         this._isShopItem = initIsShopItem;
         this.endTime = initEndTime;
         var currDef:Object = ItemXtCommManager.getItemDef(initDefId);
         if(currDef == null)
         {
            DebugUtility.debugTrace("Item.init got invalid itemDefId? defId:" + initDefId,16711680);
         }
         this.layerId = currDef.layerId;
         this.accId = currDef.accId;
         this.name = currDef.name;
         this.isGiftable = currDef.isGiftable;
         this.type = currDef.type;
         this.isMemberOnly = currDef.isMembersOnly;
         this.itemStatus = currDef.itemStatus;
         this.value = this.isOnSale ? int(currDef.cost * 0.5) : int(currDef.cost);
         this.enviroType = currDef.enviroType;
         this.recycleValue = currDef.recycleValue == 0 ? int(currDef.cost * gMainFrame.clientInfo.recyclePercentage) : int(currDef.recycleValue);
         this.currencyType = currDef.currencyType;
         this.avatarUseFlag = currDef.avatarUseFlag;
         this._attackMediaRefId = currDef.attackMediaRefId;
         this._defense = currDef.defense;
         this._attack = currDef.attack;
         this._combatType = currDef.combatType;
         this._fierce = currDef.criticalHit;
         this._modifierType = currDef.modifierType;
         this._modifierValue = currDef.modifierValue;
         this.isIconLoaded = false;
      }
      
      public function destroy() : void
      {
         if(Boolean(this._iconHelper))
         {
            this._iconHelper.destroy();
            this._iconHelper = null;
         }
         if(Boolean(this._iconBitmap))
         {
            this._iconBitmap.release();
            this._iconBitmap = null;
         }
         if(Boolean(this._largeIconHelper))
         {
            this._largeIconHelper.destroy();
            this._largeIconHelper = null;
         }
         if(Boolean(this._largeIconBitmap))
         {
            this._largeIconBitmap.release();
            this._largeIconBitmap = null;
         }
         if(Boolean(this._icon))
         {
            this._icon = null;
         }
      }
      
      public function ifItemDiffers(itemParam:Item) : Boolean
      {
         if(this._defId == itemParam.defId)
         {
            if(this.inUseFlagLand != itemParam.inUseFlagLand || this.inUseFlagOcean != itemParam.inUseFlagOcean || this.value != itemParam.value || this.color != itemParam.color || this.name != itemParam.name || this.isGiftable != itemParam.isGiftable || this.type != itemParam.type || this.layerId != itemParam.layerId || this.accId != itemParam.accId || this.isMemberOnly != itemParam.isMemberOnly || this.isNew != itemParam.isNew || this.isOnSale != itemParam.isOnSale || this.recycleValue != itemParam.recycleValue || this.currencyType != itemParam.currencyType || this.endTime != itemParam.endTime)
            {
               return true;
            }
         }
         return false;
      }
      
      public function clone() : Item
      {
         var clonedItem:Item = new Item();
         clonedItem.init(this._defId,this.invIdx,this.color,this.inUseFlagLand,this.inUseFlagOcean,this._isShopItem,this.endTime);
         if(this.diamondDefId != -1)
         {
            clonedItem.diamondDefId = this.diamondDefId;
            clonedItem.value = this.value;
            clonedItem.currencyType = this.currencyType;
            clonedItem.endTime = this.endTime;
         }
         return clonedItem;
      }
      
      public function makeSmallIcon() : void
      {
         if(this.accId == 3)
         {
            return;
         }
         this.isIconLoaded = false;
         this._icon = new Sprite();
         this._iconBitmap = new LayerBitmap();
         this._iconHelper = new SimpleIcon();
         this._iconHelper.init(this._iconBitmap,this.color,this.accId,1,this._isShopItem,false,this.smallIconReceived);
      }
      
      public function makeLargeIcon() : void
      {
         if(this.accId == 3)
         {
            return;
         }
         this.isIconLoaded = false;
         this._largeIcon = new Sprite();
         this._largeIconBitmap = new LayerBitmap();
         this._largeIconHelper = new SimpleIcon();
         this._largeIconHelper.init(this._largeIconBitmap,this.color,this.accId,1,this._isShopItem,false,this.largeIconReceived);
      }
      
      private function smallIconReceived() : void
      {
         this._icon.addChild(this._iconBitmap);
         this.resizeAndPositionIcon(false);
         this.isIconLoaded = true;
         if(this._iconLayerID >= 0)
         {
            LayerBitmap(this._icon.getChildAt(0)).setLayerColor(this._iconLayerID,this._iconColorID);
            LayerBitmap(this._icon.getChildAt(0)).paint(0);
            this._iconLayerID = -1;
         }
      }
      
      private function largeIconReceived() : void
      {
         this._largeIcon.addChild(this._largeIconBitmap);
         this.resizeAndPositionIcon(true);
         this.isIconLoaded = true;
      }
      
      public function setIconColor(layerId:int, color:uint) : void
      {
         if(Boolean(this._icon) && Boolean(this._icon.getChildAt(0)))
         {
            LayerBitmap(this._icon.getChildAt(0)).setLayerColor(layerId,color);
            LayerBitmap(this._icon.getChildAt(0)).paint(0);
         }
         else
         {
            this._iconLayerID = layerId;
            this._iconColorID = color;
         }
      }
      
      public function resizeAndPositionIcon(isLargeIcon:Boolean) : void
      {
         var scale:Number = NaN;
         if(this._isShopItem)
         {
            if(isLargeIcon)
            {
               scale = 1;
               this._largeIcon.width *= scale;
               this._largeIcon.height *= scale;
               this._largeIcon.x = -(this._largeIcon.width * 0.5);
               this._largeIcon.y = -(this._largeIcon.height * 0.5);
            }
            else
            {
               scale = 0.6;
               this._icon.width *= scale;
               this._icon.height *= scale;
               this._icon.x = -(this._icon.width * 0.5);
               this._icon.y = -(this._icon.height * 0.5);
            }
         }
         else
         {
            scale = 0.75;
            this._icon.width *= scale;
            this._icon.height *= scale;
            this._icon.x = -(this._icon.width * 0.5);
            this._icon.y = -(this._icon.height * 0.5);
         }
         if(this.imageLoadedCallback != null)
         {
            this.imageLoadedCallback();
         }
      }
      
      public function get diamondDefId() : int
      {
         return this._diamondDefId;
      }
      
      public function set diamondDefId(value:int) : void
      {
         this._diamondDefId = value;
      }
      
      public function get defId() : int
      {
         return this._defId;
      }
      
      public function set defId(value:int) : void
      {
         this._defId = value;
      }
      
      public function get itemDefId() : int
      {
         return this._defId;
      }
      
      public function get icon() : Sprite
      {
         if(!this._icon)
         {
            this.makeSmallIcon();
         }
         return this._icon;
      }
      
      public function get largeIcon() : Sprite
      {
         if(!this._largeIcon)
         {
            this.makeLargeIcon();
         }
         return this._largeIcon;
      }
      
      public function get isOnSale() : Boolean
      {
         return this.itemStatus == SALE_ITEM;
      }
      
      public function get isOnClearance() : Boolean
      {
         return this.itemStatus == CLEARANCE_ITEM;
      }
      
      public function get isRare() : Boolean
      {
         return this.itemStatus == RARE_ITEM;
      }
      
      public function get isNew() : Boolean
      {
         return this.itemStatus == NEW_ITEM;
      }
      
      public function get isOcean() : Boolean
      {
         return this.enviroType == Utility.ENVIRO_OCEAN;
      }
      
      public function get isLand() : Boolean
      {
         return this.enviroType == Utility.ENVIRO_LAND;
      }
      
      public function get attackMediaRefId() : int
      {
         return this._attackMediaRefId;
      }
      
      public function get defense() : int
      {
         return this._defense;
      }
      
      public function get attack() : int
      {
         return this._attack;
      }
      
      public function get combatType() : int
      {
         return this._combatType;
      }
      
      public function get modifierType() : int
      {
         return this._modifierType;
      }
      
      public function get modifierValue() : int
      {
         return this._modifierValue;
      }
      
      public function get fierceAttack() : int
      {
         return this._fierce;
      }
      
      public function get extraTooltipInfo() : String
      {
         return "";
      }
      
      public function getInUse(perUserAvId:int) : Boolean
      {
         var avInvId:int = 0;
         if(this.inUseFlagLand != -1 && this.inUseFlagOcean != -1)
         {
            if(Boolean(AvatarXtCommManager.avSlotInfo[perUserAvId]))
            {
               avInvId = int(AvatarXtCommManager.avSlotInfo[perUserAvId].avInvId);
               if(this.enviroType == Utility.ENVIRO_LAND)
               {
                  if((this.inUseFlagLand & 1 << avInvId) > 0)
                  {
                     return true;
                  }
               }
               else if((this.inUseFlagOcean & 1 << avInvId) > 0)
               {
                  return true;
               }
            }
            return false;
         }
         return true;
      }
      
      public function setInUse(perUserAvId:int, show:Boolean) : void
      {
         var avInvId:int = 0;
         if(Boolean(AvatarXtCommManager.avSlotInfo[perUserAvId]))
         {
            avInvId = int(AvatarXtCommManager.avSlotInfo[perUserAvId].avInvId);
            if(show)
            {
               if(this.enviroType == Utility.ENVIRO_LAND)
               {
                  this.inUseFlagLand |= 1 << avInvId;
               }
               else
               {
                  this.inUseFlagOcean |= 1 << avInvId;
               }
            }
            else if(this.enviroType == Utility.ENVIRO_LAND)
            {
               this.inUseFlagLand &= ~(1 << avInvId);
            }
            else
            {
               this.inUseFlagOcean &= ~(1 << avInvId);
            }
         }
      }
   }
}

