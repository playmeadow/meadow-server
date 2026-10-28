package item
{
   import avatar.AvatarXtCommManager;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerBitmap;
   import currency.CombinedCurrencyItem;
   import diamond.DiamondXtCommManager;
   import flash.display.Sprite;
   import localization.LocalizationManager;
   
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
      
      public var isMemberOnly:Boolean;
      
      public var itemStatus:int;
      
      public var type:int;
      
      public var enviroType:int;
      
      public var recycleValue:int;
      
      public var currencyType:int;
      
      public var avatarUseFlag:Object;
      
      public var endTime:uint;
      
      public var colors:Array;
      
      private var _inUseFlagLand:Number;
      
      private var _inUseFlagOcean:Number;
      
      private var _value:int;
      
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
      
      private var _combinedCurrencyItem:CombinedCurrencyItem;
      
      public function Item()
      {
         super();
      }
      
      public function init(param1:int, param2:int = 0, param3:uint = 0, param4:Number = 0, param5:Number = 0, param6:Boolean = false, param7:uint = 0) : void
      {
         _defId = param1;
         invIdx = param2;
         color = param3;
         _inUseFlagLand = param4;
         _inUseFlagOcean = param5;
         _isShopItem = param6;
         endTime = param7;
         var _loc8_:Object = ItemXtCommManager.getItemDef(param1);
         if(_loc8_ == null)
         {
            DebugUtility.debugTrace("Item.init got invalid itemDefId? defId:" + param1,16711680);
         }
         layerId = _loc8_.layerId;
         accId = _loc8_.accId;
         name = _loc8_.name;
         isGiftable = _loc8_.isGiftable;
         type = _loc8_.type;
         isMemberOnly = _loc8_.isMembersOnly;
         itemStatus = _loc8_.itemStatus;
         _value = isOnSale ? _loc8_.cost * 0.5 : _loc8_.cost;
         enviroType = _loc8_.enviroType;
         recycleValue = _loc8_.recycleValue == 0 ? _loc8_.cost * gMainFrame.clientInfo.recyclePercentage : _loc8_.recycleValue;
         currencyType = _loc8_.currencyType;
         avatarUseFlag = _loc8_.avatarUseFlag;
         colors = _loc8_.colors;
         _attackMediaRefId = _loc8_.attackMediaRefId;
         _defense = _loc8_.defense;
         _attack = _loc8_.attack;
         _combatType = _loc8_.combatType;
         _fierce = _loc8_.criticalHit;
         _modifierType = _loc8_.modifierType;
         _modifierValue = _loc8_.modifierValue;
         _diamondDefId = DiamondXtCommManager.getDiamondDefIdByRefId(_loc8_.defId,0);
         if(currencyType == 100)
         {
            _combinedCurrencyItem = new CombinedCurrencyItem(_loc8_.combinedCurrencyString);
         }
         isIconLoaded = false;
      }
      
      public function destroy() : void
      {
         if(_iconHelper)
         {
            _iconHelper.destroy();
            _iconHelper = null;
         }
         if(_iconBitmap)
         {
            _iconBitmap.release();
            _iconBitmap = null;
         }
         if(_largeIconHelper)
         {
            _largeIconHelper.destroy();
            _largeIconHelper = null;
         }
         if(_largeIconBitmap)
         {
            _largeIconBitmap.release();
            _largeIconBitmap = null;
         }
         if(_icon)
         {
            _icon = null;
         }
      }
      
      public function ifItemDiffers(param1:Item) : Boolean
      {
         if(_defId == param1.defId)
         {
            if(_inUseFlagLand != param1._inUseFlagLand || _inUseFlagOcean != param1._inUseFlagOcean || value != param1.value || color != param1.color || name != param1.name || isGiftable != param1.isGiftable || type != param1.type || layerId != param1.layerId || accId != param1.accId || isMemberOnly != param1.isMemberOnly || isNew != param1.isNew || isOnSale != param1.isOnSale || recycleValue != param1.recycleValue || currencyType != param1.currencyType || endTime != param1.endTime)
            {
               return true;
            }
         }
         return false;
      }
      
      public function clone() : Item
      {
         var _loc1_:Item = new Item();
         _loc1_.init(_defId,invIdx,color,_inUseFlagLand,_inUseFlagOcean,_isShopItem,endTime);
         if(diamondDefId != -1)
         {
            _loc1_.diamondDefId = diamondDefId;
            _loc1_.value = value;
            _loc1_.currencyType = currencyType;
            _loc1_.endTime = endTime;
         }
         return _loc1_;
      }
      
      public function makeSmallIcon() : void
      {
         if(accId == 3)
         {
            return;
         }
         isIconLoaded = false;
         _icon = new Sprite();
         _iconBitmap = new LayerBitmap();
         _iconHelper = new SimpleIcon();
         _iconHelper.init(_iconBitmap,color,accId,1,_isShopItem,false,smallIconReceived);
      }
      
      public function makeLargeIcon() : void
      {
         if(accId == 3)
         {
            return;
         }
         isIconLoaded = false;
         _largeIcon = new Sprite();
         _largeIconBitmap = new LayerBitmap();
         _largeIconHelper = new SimpleIcon();
         _largeIconHelper.init(_largeIconBitmap,color,accId,1,_isShopItem,false,largeIconReceived);
      }
      
      private function smallIconReceived() : void
      {
         _icon.addChild(_iconBitmap);
         resizeAndPositionIcon(false);
         isIconLoaded = true;
         if(_iconLayerID >= 0)
         {
            LayerBitmap(_icon.getChildAt(0)).setLayerColor(_iconLayerID,_iconColorID);
            LayerBitmap(_icon.getChildAt(0)).paint(0);
            _iconLayerID = -1;
         }
      }
      
      private function largeIconReceived() : void
      {
         _largeIcon.addChild(_largeIconBitmap);
         resizeAndPositionIcon(true);
         isIconLoaded = true;
      }
      
      public function setIconColor(param1:int, param2:uint) : void
      {
         if(_icon && _icon.getChildAt(0))
         {
            LayerBitmap(_icon.getChildAt(0)).setLayerColor(param1,param2);
            LayerBitmap(_icon.getChildAt(0)).paint(0);
         }
         else
         {
            _iconLayerID = param1;
            _iconColorID = param2;
         }
      }
      
      public function resizeAndPositionIcon(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         if(_isShopItem)
         {
            if(param1)
            {
               _loc2_ = 1;
               _largeIcon.width *= _loc2_;
               _largeIcon.height *= _loc2_;
               _largeIcon.x = -(_largeIcon.width * 0.5);
               _largeIcon.y = -(_largeIcon.height * 0.5);
            }
            else
            {
               _loc2_ = 0.6;
               _icon.width *= _loc2_;
               _icon.height *= _loc2_;
               _icon.x = -(_icon.width * 0.5);
               _icon.y = -(_icon.height * 0.5);
            }
         }
         else
         {
            _loc2_ = 0.75;
            _icon.width *= _loc2_;
            _icon.height *= _loc2_;
            _icon.x = -(_icon.width * 0.5);
            _icon.y = -(_icon.height * 0.5);
         }
         if(imageLoadedCallback != null)
         {
            imageLoadedCallback();
         }
      }
      
      public function get inUseFlagLand() : Number
      {
         return _inUseFlagLand;
      }
      
      public function set inUseFlagLand(param1:Number) : void
      {
         _inUseFlagLand = param1;
      }
      
      public function get inUseFlagOcean() : Number
      {
         return _inUseFlagOcean;
      }
      
      public function set inUseFlagOcean(param1:Number) : void
      {
         _inUseFlagOcean = param1;
      }
      
      public function get diamondDefId() : int
      {
         return _diamondDefId;
      }
      
      public function set diamondDefId(param1:int) : void
      {
         _diamondDefId = param1;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function set defId(param1:int) : void
      {
         _defId = param1;
      }
      
      public function get itemDefId() : int
      {
         return _defId;
      }
      
      public function get icon() : Sprite
      {
         if(!_icon)
         {
            makeSmallIcon();
         }
         return _icon;
      }
      
      public function get largeIcon() : Sprite
      {
         if(!_largeIcon)
         {
            makeLargeIcon();
         }
         return _largeIcon;
      }
      
      public function get isOnSale() : Boolean
      {
         return itemStatus == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return itemStatus == 3;
      }
      
      public function get isRare() : Boolean
      {
         return itemStatus == 4;
      }
      
      public function get isNew() : Boolean
      {
         return itemStatus == 1;
      }
      
      public function get isOcean() : Boolean
      {
         return enviroType == 1;
      }
      
      public function get isLand() : Boolean
      {
         return enviroType == 0;
      }
      
      public function get isDiamond() : Boolean
      {
         return _diamondDefId != -1;
      }
      
      public function get isRareDiamond() : Boolean
      {
         return isRare && isDiamond;
      }
      
      public function get attackMediaRefId() : int
      {
         return _attackMediaRefId;
      }
      
      public function get defense() : int
      {
         return _defense;
      }
      
      public function get attack() : int
      {
         return _attack;
      }
      
      public function get combatType() : int
      {
         return _combatType;
      }
      
      public function get modifierType() : int
      {
         return _modifierType;
      }
      
      public function get modifierValue() : int
      {
         return _modifierValue;
      }
      
      public function get fierceAttack() : int
      {
         return _fierce;
      }
      
      public function get extraTooltipInfo() : String
      {
         return "";
      }
      
      public function getInUse(param1:int) : Boolean
      {
         var _loc4_:* = 0;
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(_inUseFlagLand != -1 && _inUseFlagOcean != -1)
         {
            if(AvatarXtCommManager.avSlotInfo[param1])
            {
               _loc4_ = uint(AvatarXtCommManager.avSlotInfo[param1].avInvId);
               _loc3_ = Utility.leftShiftNumbers(_loc4_);
               if(enviroType == 0)
               {
                  _loc2_ = _inUseFlagLand;
                  if(Utility.bitwiseAnd(_loc2_,_loc3_) > 0)
                  {
                     return true;
                  }
               }
               else
               {
                  _loc2_ = _inUseFlagOcean;
                  if(Utility.bitwiseAnd(_loc2_,_loc3_) > 0)
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
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         if(AvatarXtCommManager.avSlotInfo[param1])
         {
            _loc5_ = Number(AvatarXtCommManager.avSlotInfo[param1].avInvId);
            _loc4_ = Utility.leftShiftNumbers(_loc5_);
            if(param2)
            {
               if(enviroType == 0)
               {
                  _loc3_ = _inUseFlagLand;
                  _loc3_ = Utility.bitwiseOr(_loc3_,_loc4_);
                  _inUseFlagLand = _loc3_;
               }
               else
               {
                  _loc3_ = _inUseFlagOcean;
                  _loc3_ = Utility.bitwiseOr(_loc3_,_loc4_);
                  _inUseFlagOcean = _loc3_;
               }
            }
            else if(enviroType == 0)
            {
               _loc3_ = _inUseFlagLand;
               _loc3_ = Utility.bitwiseAnd(_loc3_,Utility.bitwiseNot(_loc4_));
               _inUseFlagLand = _loc3_;
            }
            else
            {
               _loc3_ = _inUseFlagOcean;
               _loc3_ = Utility.bitwiseAnd(_loc3_,Utility.bitwiseNot(_loc4_));
               _inUseFlagOcean = _loc3_;
            }
         }
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         return _combinedCurrencyItem;
      }
      
      public function set value(param1:int) : void
      {
         _value = param1;
      }
      
      public function get sincleCurrencyCost() : int
      {
         return _value;
      }
      
      public function get value() : *
      {
         if(currencyType == 100)
         {
            return _combinedCurrencyItem;
         }
         return _value;
      }
      
      public function get sortIdString() : String
      {
         switch(layerId - 4)
         {
            case 0:
               return LocalizationManager.translateIdOnly(11209).toLowerCase();
            case 1:
               return LocalizationManager.translateIdOnly(11208).toLowerCase();
            case 2:
               return LocalizationManager.translateIdOnly(11207).toLowerCase();
            case 3:
               return LocalizationManager.translateIdOnly(11206).toLowerCase();
            case 4:
            case 5:
            case 6:
               return LocalizationManager.translateIdOnly(11205).toLowerCase();
            default:
               return "";
         }
      }
   }
}

