package den
{
   import currency.CombinedCurrencyItem;
   import diamond.DiamondXtCommManager;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.DenItemHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   
   public class DenItem
   {
      
      public static const SORT_FLOOR:int = 0;
      
      public static const SORT_WALL:int = 1;
      
      public static const SORT_FLOORING:int = 2;
      
      public static const SORT_WALLPAPER:int = 3;
      
      public static const SORT_AUDIO:int = 4;
      
      public static const SORT_PET:int = 5;
      
      public static const PLACE_CAT_FLOOR:int = 1;
      
      public static const PLACE_CAT_WALL:int = 2;
      
      public static const PLACE_CAT_ICONL:int = 3;
      
      public static const SPECIAL_TYPE_NORMAL:int = 0;
      
      public static const SPECIAL_TYPE_PORTAL:int = 1;
      
      public static const SPECIAL_TYPE_EMOTE:int = 2;
      
      public static const REF_ID_DEN_ITEM:int = 0;
      
      public static const REF_ID_PET_ITEM:int = 1;
      
      public static const DEN_PET_LAYER_ID:int = 0;
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      public static const DEF_AUDIO_DEF_ID:int = 617;
      
      public static const DEF_AUDIO_PACKED_ID:uint = 40435715;
      
      public static const DEF_AUDIO_INVIDX:int = -1;
      
      public static const DEF_AUDIO_STRMNAME:String = "MusDenDef";
      
      public static const DEF_AUDIO_VOL:int = 50;
      
      public static const WIND_SMALL_SIZE:int = 80;
      
      public static const WIND_MED_SIZE:int = 168;
      
      public static const WIND_LARGE_SIZE:int = 280;
      
      public var refId:int;
      
      public var invIdx:int;
      
      public var categoryId:int;
      
      public var layerId:int;
      
      public var sortId:int;
      
      public var name:String;
      
      public var isMemberOnly:Boolean;
      
      public var version:int;
      
      public var version2:int;
      
      public var version3:int;
      
      public var strmName:String;
      
      public var enviroType:int;
      
      public var recycleValue:int;
      
      public var currencyType:int;
      
      public var endTime:uint;
      
      public var specialType:int;
      
      private var _value:int;
      
      private var _diamondDefId:int = -1;
      
      private var _itemDefId:int;
      
      public var itemStatus:int;
      
      public var minigameDefId:int;
      
      public var listId:int;
      
      public var isIconLoaded:Boolean;
      
      public var imageLoadedCallback:Function;
      
      private var _icon:Sprite;
      
      private var _iconHelper:DenItemHelper;
      
      private var _largeIcon:Sprite;
      
      private var _largeIconHelper:DenItemHelper;
      
      private var _isShopItem:Boolean;
      
      private var _listenToMouse:Boolean;
      
      private var _globalScale:Number = 1;
      
      private var _setRandomVersion:Boolean;
      
      private var _combinedCurrencyItem:CombinedCurrencyItem;
      
      public function DenItem()
      {
         super();
      }
      
      public static function getIconId(param1:int) : int
      {
         if(param1 == 0 || param1 == 5)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 2;
         }
         if(param1 == 2 || param1 == 3 || param1 == 4)
         {
            return 3;
         }
         return param1 + 1;
      }
      
      public static function getInWorldId(param1:int, param2:int) : int
      {
         if(param1 == 0 || param1 == 5)
         {
            return 1;
         }
         if(param1 == 1)
         {
            return 2;
         }
         if(param1 == 4)
         {
            return 3;
         }
         return param2;
      }
      
      public function init(param1:int, param2:int = 0, param3:int = 0, param4:int = 0, param5:int = 0, param6:int = 0, param7:int = 0, param8:uint = 0) : void
      {
         var _loc9_:Object = null;
         refId = param5;
         invIdx = param2;
         _itemDefId = param1;
         categoryId = param3;
         version = param4;
         endTime = param8;
         if(param5 == 1)
         {
            _loc9_ = PetManager.getPetDef(_itemDefId);
            _itemDefId = DenXtCommManager.denItemDefIdForPetDefId(_itemDefId);
            layerId = 0;
            sortId = 5;
            isMemberOnly = _loc9_.isMember;
            itemStatus = _loc9_.status;
            _value = isOnSale ? _loc9_.cost * 0.5 : _loc9_.cost;
            strmName = "";
            name = _loc9_.title;
            minigameDefId = 0;
            listId = 0;
            version2 = param6;
            version3 = param7;
            enviroType = PetManager.getEnviroTypeByPetType(_loc9_.type);
            recycleValue = _loc9_.recycleValue == "0" || _loc9_.recycleValue == null ? _loc9_.cost * gMainFrame.clientInfo.recyclePercentage : _loc9_.recycleValue;
            currencyType = 0;
            _globalScale = 1;
            specialType = 0;
            _combinedCurrencyItem = null;
         }
         else
         {
            _loc9_ = DenXtCommManager.getDenItemDef(param1);
            layerId = _loc9_.layer;
            sortId = _loc9_.sortCat;
            isMemberOnly = _loc9_.membersOnly == "1";
            itemStatus = _loc9_.itemStatus;
            _value = isOnSale ? _loc9_.cost * 0.5 : _loc9_.cost;
            strmName = _itemDefId == 617 ? "MusDenDef" : _loc9_.abbrName;
            name = _loc9_.name;
            minigameDefId = _loc9_.gameDefId;
            listId = _loc9_.listId;
            version2 = _loc9_.flag;
            enviroType = _loc9_.enviroType;
            currencyType = _loc9_.currencyType;
            recycleValue = _loc9_.recycleValue == "0" && currencyType != 1 ? value * gMainFrame.clientInfo.recyclePercentage : _loc9_.recycleValue;
            _globalScale = _loc9_.scalePercent / 100;
            specialType = _loc9_.specialType;
            _diamondDefId = DiamondXtCommManager.getDiamondDefIdByRefId(_loc9_.id,1);
            if(currencyType == 100)
            {
               _combinedCurrencyItem = new CombinedCurrencyItem(_loc9_.combinedCurrencyString);
            }
         }
      }
      
      public function destroy() : void
      {
         if(_iconHelper)
         {
            _iconHelper.destroy();
            _iconHelper = null;
         }
         _icon = null;
         if(_largeIconHelper)
         {
            _largeIconHelper.destroy();
            _largeIconHelper = null;
         }
         _largeIcon = null;
      }
      
      public function initShopItem(param1:int, param2:int, param3:Boolean = false, param4:uint = 0) : void
      {
         _itemDefId = param1;
         _setRandomVersion = param3;
         version = param2;
         var _loc5_:Object = DenXtCommManager.getDenItemDef(param1);
         name = _loc5_.name;
         isMemberOnly = _loc5_.membersOnly == "1";
         itemStatus = _loc5_.itemStatus;
         _value = isOnSale ? _loc5_.cost * 0.5 : _loc5_.cost;
         minigameDefId = _loc5_.gameDefId;
         listId = _loc5_.listId;
         sortId = _loc5_.sortCat;
         enviroType = _loc5_.enviroType;
         strmName = _loc5_.abbrName;
         version2 = _loc5_.flag;
         currencyType = _loc5_.currencyType;
         _isShopItem = true;
         _globalScale = _loc5_.scalePercent / 100;
         endTime = param4;
         if(currencyType == 100)
         {
            _combinedCurrencyItem = new CombinedCurrencyItem(_loc5_.combinedCurrencyString);
         }
      }
      
      public function ifItemDiffers(param1:DenItem) : Boolean
      {
         if(invIdx == param1.invIdx)
         {
            return true;
         }
         return false;
      }
      
      public function clone() : DenItem
      {
         var _loc1_:DenItem = new DenItem();
         if(_isShopItem)
         {
            _loc1_.initShopItem(_itemDefId,version,_setRandomVersion,endTime);
         }
         else
         {
            _loc1_.init(_itemDefId,invIdx,categoryId,version,refId,version2,version3,endTime);
         }
         if(_diamondDefId != -1)
         {
            _loc1_._diamondDefId = _diamondDefId;
            _loc1_.endTime = endTime;
            _loc1_.currencyType = 3;
            _loc1_.value = value;
            _loc1_.itemStatus = itemStatus;
         }
         return _loc1_;
      }
      
      public function makeSmallIcon() : void
      {
         var _loc1_:int = int(sortId == 5 ? version2 : 0);
         var _loc2_:int = int(sortId == 5 ? version3 : 0);
         _icon = new Sprite();
         _iconHelper = new DenItemHelper();
         _iconHelper.init(uint(_itemDefId << 16 | getIconId(sortId)),iconReceived,version,0,_loc1_,_loc2_);
      }
      
      public function makeLargeIcon() : void
      {
         var _loc1_:int = int(sortId == 5 ? version2 : 0);
         var _loc2_:int = int(sortId == 5 ? version3 : 0);
         _largeIcon = new Sprite();
         _largeIconHelper = new DenItemHelper();
         _largeIconHelper.init(uint(_itemDefId << 16 | getIconId(sortId)),largeIconReceived,version,0,_loc1_,_loc2_);
      }
      
      public function getVersions() : Array
      {
         var _loc1_:Array = null;
         if(_iconHelper)
         {
            _loc1_ = _iconHelper.getVersions();
         }
         else if(_largeIconHelper)
         {
            _loc1_ = _largeIconHelper.getVersions();
         }
         if(_loc1_ == null)
         {
            version = 0;
         }
         return _loc1_;
      }
      
      public function setVersion(param1:int) : void
      {
         version = param1;
         if(_iconHelper)
         {
            _iconHelper.setVersion(param1);
         }
         else if(_largeIconHelper)
         {
            _largeIconHelper.setVersion(param1);
         }
      }
      
      private function iconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Array = null;
         param1.displayObject.cacheAsBitmap = true;
         _icon.addChild(param1.displayObject);
         resizeAndPositionIcon(false);
         isIconLoaded = true;
         if(_setRandomVersion)
         {
            _loc2_ = getVersions();
            if(_loc2_)
            {
               setVersion(_loc2_[Math.floor(Math.random() * (_loc2_.length - 1 + 1))]);
            }
         }
      }
      
      private function largeIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Array = null;
         param1.displayObject.cacheAsBitmap = true;
         _largeIcon.addChild(param1.displayObject);
         resizeAndPositionIcon(true);
         isIconLoaded = true;
         if(_setRandomVersion)
         {
            _loc2_ = getVersions();
            if(_loc2_)
            {
               setVersion(_loc2_[Math.floor(Math.random() * (_loc2_.length - 1 + 1))]);
            }
         }
      }
      
      private function resizeAndPositionIcon(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         var _loc5_:Sprite = null;
         var _loc4_:int = 0;
         if(param1)
         {
            _loc5_ = Sprite(_largeIcon.getChildAt(0));
         }
         else
         {
            _loc5_ = Sprite(_icon.getChildAt(0));
         }
         var _loc3_:MovieClip = MovieClip(Loader(_loc5_.getChildAt(0)).content);
         _loc4_ = 0;
         while(_loc4_ < _loc3_.currentLabels.length)
         {
            if(_loc3_.currentLabels[_loc4_].name == "icon")
            {
               _loc3_.gotoAndStop("icon");
               break;
            }
            _loc4_++;
         }
         if(_isShopItem)
         {
            if(param1)
            {
               if(_loc3_.hasOwnProperty("listenToMouseInShop"))
               {
                  _listenToMouse = _loc3_.listenToMouseInShop;
               }
               else
               {
                  _listenToMouse = true;
               }
               _loc2_ = 280 / Math.max(_largeIcon.width,_largeIcon.height) * _globalScale;
               _largeIcon.width *= _loc2_;
               _largeIcon.height *= _loc2_;
               _largeIcon.x = -(_largeIcon.width * 0.5);
               _largeIcon.y = -(_largeIcon.height * 0.5);
            }
            else
            {
               _loc2_ = 168 / Math.max(_icon.width,_icon.height) * _globalScale;
               _icon.width *= _loc2_;
               _icon.height *= _loc2_;
               _icon.x = -(_icon.width * 0.5);
               _icon.y = -(_icon.height * 0.5);
            }
         }
         else
         {
            _loc2_ = 80 / Math.max(_icon.width,_icon.height) * _globalScale;
            _icon.width *= _loc2_;
            _icon.height *= _loc2_;
            _icon.x = -(_icon.width * 0.5);
            _icon.y = -(_icon.height * 0.5);
         }
         listenToMouse(_listenToMouse,_loc3_);
         if(imageLoadedCallback != null)
         {
            imageLoadedCallback();
         }
      }
      
      public function listenToMouse(param1:Boolean, param2:MovieClip = null) : void
      {
         var _loc3_:Sprite = null;
         _listenToMouse = param1;
         if(!param2)
         {
            if(_largeIcon)
            {
               if(_largeIcon.numChildren <= 0)
               {
                  return;
               }
               _loc3_ = Sprite(_largeIcon.getChildAt(0));
            }
            else
            {
               if(!_icon || _icon.numChildren <= 0)
               {
                  return;
               }
               _loc3_ = Sprite(_icon.getChildAt(0));
            }
            if(!_loc3_)
            {
               return;
            }
            param2 = MovieClip(Loader(_loc3_.getChildAt(0)).content);
         }
         if(param2 && param2.hasOwnProperty("listenToMouse"))
         {
            param2.listenToMouse = _listenToMouse;
         }
      }
      
      public function get diamondDefId() : int
      {
         return _diamondDefId;
      }
      
      public function set diamondDefId(param1:int) : void
      {
         _diamondDefId = param1;
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
      
      public function get extraTooltipInfo() : String
      {
         return "";
      }
      
      public function get itemDefId() : int
      {
         return _itemDefId;
      }
      
      public function set itemDefId(param1:int) : void
      {
         _itemDefId = param1;
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
         switch(layerId - 1)
         {
            case 0:
            case 1:
               return LocalizationManager.translateIdOnly(11215).toLowerCase();
            default:
               return "";
         }
      }
   }
}

