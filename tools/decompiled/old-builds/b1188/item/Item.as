package item
{
   import avatar.AvatarXtCommManager;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerBitmap;
   import diamond.DiamondXtCommManager;
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
      
      public static const CRYSTAL_CURRENCY:int = 2;
      
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
      
      public var inUseFlagLand:Number;
      
      public var inUseFlagOcean:Number;
      
      public var isMemberOnly:Boolean;
      
      public var itemStatus:int;
      
      public var type:int;
      
      public var enviroType:int;
      
      public var recycleValue:int;
      
      public var currencyType:int;
      
      public var avatarUseFlag:Object;
      
      public var endTime:uint;
      
      public var colors:Array;
      
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
      
      public function init(param1:int, param2:int = 0, param3:uint = 0, param4:int = 0, param5:int = 0, param6:Boolean = false, param7:uint = 0) : void
      {
         this._defId = param1;
         this.invIdx = param2;
         this.color = param3;
         this.inUseFlagLand = param4;
         this.inUseFlagOcean = param5;
         this._isShopItem = param6;
         this.endTime = param7;
         var _loc8_:Object = ItemXtCommManager.getItemDef(param1);
         if(_loc8_ == null)
         {
            DebugUtility.debugTrace("Item.init got invalid itemDefId? defId:" + param1,16711680);
         }
         this.layerId = _loc8_.layerId;
         this.accId = _loc8_.accId;
         this.name = _loc8_.name;
         this.isGiftable = _loc8_.isGiftable;
         this.type = _loc8_.type;
         this.isMemberOnly = _loc8_.isMembersOnly;
         this.itemStatus = _loc8_.itemStatus;
         this.value = this.isOnSale ? int(_loc8_.cost * 0.5) : int(_loc8_.cost);
         this.enviroType = _loc8_.enviroType;
         this.recycleValue = _loc8_.recycleValue == 0 ? int(_loc8_.cost * gMainFrame.clientInfo.recyclePercentage) : int(_loc8_.recycleValue);
         this.currencyType = _loc8_.currencyType;
         this.avatarUseFlag = _loc8_.avatarUseFlag;
         this.colors = _loc8_.colors;
         this._attackMediaRefId = _loc8_.attackMediaRefId;
         this._defense = _loc8_.defense;
         this._attack = _loc8_.attack;
         this._combatType = _loc8_.combatType;
         this._fierce = _loc8_.criticalHit;
         this._modifierType = _loc8_.modifierType;
         this._modifierValue = _loc8_.modifierValue;
         this._diamondDefId = DiamondXtCommManager.getDiamondDefIdByRefId(_loc8_.defId,DiamondXtCommManager.DIAMOND_TYPE_ITEM);
         this.isIconLoaded = false;
      }
      
      public function destroy() : void
      {
         if(this._iconHelper)
         {
            this._iconHelper.destroy();
            this._iconHelper = null;
         }
         if(this._iconBitmap)
         {
            this._iconBitmap.release();
            this._iconBitmap = null;
         }
         if(this._largeIconHelper)
         {
            this._largeIconHelper.destroy();
            this._largeIconHelper = null;
         }
         if(this._largeIconBitmap)
         {
            this._largeIconBitmap.release();
            this._largeIconBitmap = null;
         }
         if(this._icon)
         {
            this._icon = null;
         }
      }
      
      public function ifItemDiffers(param1:Item) : Boolean
      {
         if(this._defId == param1.defId)
         {
            if(this.inUseFlagLand != param1.inUseFlagLand || this.inUseFlagOcean != param1.inUseFlagOcean || this.value != param1.value || this.color != param1.color || this.name != param1.name || this.isGiftable != param1.isGiftable || this.type != param1.type || this.layerId != param1.layerId || this.accId != param1.accId || this.isMemberOnly != param1.isMemberOnly || this.isNew != param1.isNew || this.isOnSale != param1.isOnSale || this.recycleValue != param1.recycleValue || this.currencyType != param1.currencyType || this.endTime != param1.endTime)
            {
               return true;
            }
         }
         return false;
      }
      
      public function clone() : Item
      {
         var _loc1_:Item = new Item();
         _loc1_.init(this._defId,this.invIdx,this.color,this.inUseFlagLand,this.inUseFlagOcean,this._isShopItem,this.endTime);
         if(this.diamondDefId != -1)
         {
            _loc1_.diamondDefId = this.diamondDefId;
            _loc1_.value = this.value;
            _loc1_.currencyType = this.currencyType;
            _loc1_.endTime = this.endTime;
         }
         return _loc1_;
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
      
      public function setIconColor(param1:int, param2:uint) : void
      {
         if(Boolean(this._icon) && Boolean(this._icon.getChildAt(0)))
         {
            LayerBitmap(this._icon.getChildAt(0)).setLayerColor(param1,param2);
            LayerBitmap(this._icon.getChildAt(0)).paint(0);
         }
         else
         {
            this._iconLayerID = param1;
            this._iconColorID = param2;
         }
      }
      
      public function resizeAndPositionIcon(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         if(this._isShopItem)
         {
            if(param1)
            {
               _loc2_ = 1;
               this._largeIcon.width *= _loc2_;
               this._largeIcon.height *= _loc2_;
               this._largeIcon.x = -(this._largeIcon.width * 0.5);
               this._largeIcon.y = -(this._largeIcon.height * 0.5);
            }
            else
            {
               _loc2_ = 0.6;
               this._icon.width *= _loc2_;
               this._icon.height *= _loc2_;
               this._icon.x = -(this._icon.width * 0.5);
               this._icon.y = -(this._icon.height * 0.5);
            }
         }
         else
         {
            _loc2_ = 0.75;
            this._icon.width *= _loc2_;
            this._icon.height *= _loc2_;
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
      
      public function set diamondDefId(param1:int) : void
      {
         this._diamondDefId = param1;
      }
      
      public function get defId() : int
      {
         return this._defId;
      }
      
      public function set defId(param1:int) : void
      {
         this._defId = param1;
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
         return this.enviroType == SbiConstants.ENVIRO_OCEAN;
      }
      
      public function get isLand() : Boolean
      {
         return this.enviroType == SbiConstants.ENVIRO_LAND;
      }
      
      public function get isDiamond() : Boolean
      {
         return this._diamondDefId != -1;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return this.isRare && this.isDiamond;
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
      
      public function getInUse(param1:int) : Boolean
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = 0;
         var _loc4_:uint = 0;
         if(this.inUseFlagLand != -1 && this.inUseFlagOcean != -1)
         {
            if(AvatarXtCommManager.avSlotInfo[param1])
            {
               _loc2_ = uint(AvatarXtCommManager.avSlotInfo[param1].avInvId);
               _loc3_ = uint(1 << _loc2_);
               if(this.enviroType == SbiConstants.ENVIRO_LAND)
               {
                  _loc4_ = this.inUseFlagLand;
                  if(uint(_loc4_ & _loc3_) > 0)
                  {
                     return true;
                  }
               }
               else
               {
                  _loc4_ = this.inUseFlagOcean;
                  if(uint(_loc4_ & _loc3_) > 0)
                  {
                     return true;
                  }
               }
            }
            return false;
         }
         return true;
      }
      
      public function setInUse(param1:int, param2:Boolean) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         if(AvatarXtCommManager.avSlotInfo[param1])
         {
            _loc3_ = Number(AvatarXtCommManager.avSlotInfo[param1].avInvId);
            _loc4_ = uint(1 << _loc3_);
            if(param2)
            {
               if(this.enviroType == SbiConstants.ENVIRO_LAND)
               {
                  _loc5_ = this.inUseFlagLand;
                  _loc5_ = uint(_loc5_ | _loc4_);
                  this.inUseFlagLand = _loc5_;
               }
               else
               {
                  _loc5_ = this.inUseFlagOcean;
                  _loc5_ = uint(_loc5_ | _loc4_);
                  this.inUseFlagOcean = _loc5_;
               }
            }
            else if(this.enviroType == SbiConstants.ENVIRO_LAND)
            {
               _loc5_ = this.inUseFlagLand;
               _loc5_ = uint(_loc5_ & ~_loc4_);
               this.inUseFlagLand = _loc5_;
            }
            else
            {
               _loc5_ = this.inUseFlagOcean;
               _loc5_ = uint(_loc5_ & ~_loc4_);
               this.inUseFlagOcean = _loc5_;
            }
         }
      }
   }
}

