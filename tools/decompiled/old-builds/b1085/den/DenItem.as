package den
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import item.Item;
   import loader.DenItemHelper;
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
      
      public static const REF_ID_DEN_ITEM:int = 0;
      
      public static const REF_ID_PET_ITEM:int = 1;
      
      public static const DEN_PET_LAYER_ID:int = 0;
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      public static const DEF_AUDIO_DEF_ID:int = 617;
      
      public static const DEF_AUDIO_PACKED_ID:uint = DEF_AUDIO_DEF_ID << 16 | PLACE_CAT_ICONL;
      
      public static const DEF_AUDIO_INVIDX:int = -1;
      
      public static const DEF_AUDIO_STRMNAME:String = "MusDenDef";
      
      public static const DEF_AUDIO_VOL:int = 50;
      
      public static const WIND_SMALL_SIZE:int = 80;
      
      public static const WIND_MED_SIZE:int = 168;
      
      public static const WIND_LARGE_SIZE:int = 280;
      
      public var refId:int;
      
      public var invIdx:int;
      
      public var categoryId:int;
      
      public var value:int;
      
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
      
      private var _diamondDefId:int = -1;
      
      private var _itemDefId:int;
      
      public var itemStatus:int;
      
      public var minigameDefId:int;
      
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
      
      public function DenItem()
      {
         super();
      }
      
      public static function getIconId(param1:int) : int
      {
         if(param1 == SORT_FLOOR || param1 == SORT_PET)
         {
            return 1;
         }
         if(param1 == SORT_WALL)
         {
            return 2;
         }
         if(param1 == SORT_FLOORING || param1 == SORT_WALLPAPER || param1 == SORT_AUDIO)
         {
            return 3;
         }
         return param1 + 1;
      }
      
      public static function getInWorldId(param1:int, param2:int) : int
      {
         if(param1 == SORT_FLOOR || param1 == SORT_PET)
         {
            return 1;
         }
         if(param1 == SORT_WALL)
         {
            return 2;
         }
         if(param1 == SORT_AUDIO)
         {
            return 3;
         }
         return param2;
      }
      
      public function init(param1:int, param2:int = 0, param3:int = 0, param4:int = 0, param5:int = 0, param6:int = 0, param7:int = 0) : void
      {
         var _loc8_:Object = null;
         this.refId = param5;
         this.invIdx = param2;
         this._itemDefId = param1;
         this.categoryId = param3;
         this.version = param4;
         if(param5 == REF_ID_PET_ITEM)
         {
            _loc8_ = PetManager.getPetDef(this._itemDefId);
            this._itemDefId = DenXtCommManager.denItemDefIdForPetDefId(this._itemDefId);
            this.value = _loc8_.cost;
            this.layerId = DEN_PET_LAYER_ID;
            this.sortId = SORT_PET;
            this.isMemberOnly = _loc8_.isMember;
            this.itemStatus = _loc8_.status;
            this.strmName = "";
            this.name = _loc8_.title;
            this.minigameDefId = 0;
            this.version2 = param6;
            this.version3 = param7;
            this.enviroType = PetManager.getEnviroTypeByPetType(_loc8_.type);
            this.recycleValue = _loc8_.recycleValue == "0" || _loc8_.recycleValue == null ? int(this.value * gMainFrame.clientInfo.recyclePercentage) : int(_loc8_.recycleValue);
            this.currencyType = 0;
            this._globalScale = 1;
         }
         else
         {
            _loc8_ = DenXtCommManager.getDenItemDef(param1);
            this.value = _loc8_.cost;
            this.layerId = _loc8_.layer;
            this.sortId = _loc8_.sortCat;
            this.isMemberOnly = _loc8_.membersOnly == "1";
            this.itemStatus = _loc8_.itemStatus;
            this.strmName = this._itemDefId == DEF_AUDIO_DEF_ID ? DEF_AUDIO_STRMNAME : _loc8_.abbrName;
            this.name = _loc8_.name;
            this.minigameDefId = _loc8_.gameDefId;
            this.version2 = _loc8_.flag;
            this.enviroType = _loc8_.enviroType;
            this.currencyType = _loc8_.currencyType;
            this.recycleValue = _loc8_.recycleValue == "0" && this.currencyType != Item.TICKET_CURRENCY ? int(this.value * gMainFrame.clientInfo.recyclePercentage) : int(_loc8_.recycleValue);
            this._globalScale = _loc8_.scalePercent / 100;
         }
      }
      
      public function destroy() : void
      {
         if(this._iconHelper)
         {
            this._iconHelper.destroy();
            this._iconHelper = null;
         }
         this._icon = null;
         if(this._largeIconHelper)
         {
            this._largeIconHelper.destroy();
            this._largeIconHelper = null;
         }
         this._largeIcon = null;
      }
      
      public function initShopItem(param1:int, param2:int, param3:Boolean = false) : void
      {
         this._itemDefId = param1;
         this._setRandomVersion = param3;
         this.version = param2;
         var _loc4_:Object = DenXtCommManager.getDenItemDef(param1);
         this.value = _loc4_.cost;
         this.name = _loc4_.name;
         this.isMemberOnly = _loc4_.membersOnly == "1";
         this.itemStatus = _loc4_.itemStatus;
         this.minigameDefId = _loc4_.gameDefId;
         this.sortId = _loc4_.sortCat;
         this.enviroType = _loc4_.enviroType;
         this.strmName = _loc4_.abbrName;
         this.version2 = _loc4_.flag;
         this.currencyType = _loc4_.currencyType;
         this._isShopItem = true;
         this._globalScale = _loc4_.scalePercent / 100;
      }
      
      public function ifItemDiffers(param1:DenItem) : Boolean
      {
         if(this.invIdx == param1.invIdx)
         {
            return true;
         }
         return false;
      }
      
      public function clone() : DenItem
      {
         var _loc1_:DenItem = new DenItem();
         if(this._isShopItem)
         {
            _loc1_.initShopItem(this._itemDefId,this.version,this._setRandomVersion);
         }
         else
         {
            _loc1_.init(this._itemDefId,this.invIdx,this.categoryId,this.version,this.refId,this.version2,this.version3);
         }
         if(this._diamondDefId != -1)
         {
            _loc1_._diamondDefId = this._diamondDefId;
            _loc1_.currencyType = this.currencyType;
            _loc1_.value = this.value;
         }
         return _loc1_;
      }
      
      public function makeSmallIcon() : void
      {
         var _loc1_:int = this.sortId == SORT_PET ? this.version2 : 0;
         var _loc2_:int = this.sortId == SORT_PET ? this.version3 : 0;
         this._icon = new Sprite();
         this._iconHelper = new DenItemHelper();
         this._iconHelper.init(uint(this._itemDefId << 16 | getIconId(this.sortId)),this.iconReceived,this.version,0,_loc1_,_loc2_);
      }
      
      public function makeLargeIcon() : void
      {
         var _loc1_:int = this.sortId == SORT_PET ? this.version2 : 0;
         var _loc2_:int = this.sortId == SORT_PET ? this.version3 : 0;
         this._largeIcon = new Sprite();
         this._largeIconHelper = new DenItemHelper();
         this._largeIconHelper.init(uint(this._itemDefId << 16 | getIconId(this.sortId)),this.largeIconReceived,this.version,0,_loc1_,_loc2_);
      }
      
      public function getVersions() : Array
      {
         var _loc1_:Array = null;
         if(this._iconHelper)
         {
            _loc1_ = this._iconHelper.getVersions();
         }
         else if(this._largeIconHelper)
         {
            _loc1_ = this._largeIconHelper.getVersions();
         }
         if(_loc1_ == null)
         {
            this.version = 0;
         }
         return _loc1_;
      }
      
      public function setVersion(param1:int) : void
      {
         this.version = param1;
         if(this._iconHelper)
         {
            this._iconHelper.setVersion(param1);
         }
         else if(this._largeIconHelper)
         {
            this._largeIconHelper.setVersion(param1);
         }
      }
      
      private function iconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Array = null;
         param1.displayObject.cacheAsBitmap = true;
         this._icon.addChild(param1.displayObject);
         this.resizeAndPositionIcon(false);
         this.isIconLoaded = true;
         if(this._setRandomVersion)
         {
            _loc2_ = this.getVersions();
            if(_loc2_)
            {
               this.setVersion(_loc2_[Math.floor(Math.random() * (_loc2_.length - 1 + 1))]);
            }
         }
      }
      
      private function largeIconReceived(param1:DenItemHelper) : void
      {
         var _loc2_:Array = null;
         param1.displayObject.cacheAsBitmap = true;
         this._largeIcon.addChild(param1.displayObject);
         this.resizeAndPositionIcon(true);
         this.isIconLoaded = true;
         if(this._setRandomVersion)
         {
            _loc2_ = this.getVersions();
            if(_loc2_)
            {
               this.setVersion(_loc2_[Math.floor(Math.random() * (_loc2_.length - 1 + 1))]);
            }
         }
      }
      
      private function resizeAndPositionIcon(param1:Boolean) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Sprite = null;
         if(param1)
         {
            _loc3_ = Sprite(this._largeIcon.getChildAt(0));
         }
         else
         {
            _loc3_ = Sprite(this._icon.getChildAt(0));
         }
         var _loc4_:MovieClip = MovieClip(Loader(_loc3_.getChildAt(0)).content);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.currentLabels.length)
         {
            if(_loc4_.currentLabels[_loc5_].name == "icon")
            {
               _loc4_.gotoAndStop("icon");
               break;
            }
            _loc5_++;
         }
         if(this._isShopItem)
         {
            if(param1)
            {
               if(_loc4_.hasOwnProperty("listenToMouseInShop"))
               {
                  this._listenToMouse = _loc4_.listenToMouseInShop;
               }
               else
               {
                  this._listenToMouse = true;
               }
               _loc2_ = WIND_LARGE_SIZE / Math.max(this._largeIcon.width,this._largeIcon.height) * this._globalScale;
               this._largeIcon.width *= _loc2_;
               this._largeIcon.height *= _loc2_;
               this._largeIcon.x = -(this._largeIcon.width * 0.5);
               this._largeIcon.y = -(this._largeIcon.height * 0.5);
            }
            else
            {
               _loc2_ = WIND_MED_SIZE / Math.max(this._icon.width,this._icon.height) * this._globalScale;
               this._icon.width *= _loc2_;
               this._icon.height *= _loc2_;
               this._icon.x = -(this._icon.width * 0.5);
               this._icon.y = -(this._icon.height * 0.5);
            }
         }
         else
         {
            _loc2_ = WIND_SMALL_SIZE / Math.max(this._icon.width,this._icon.height) * this._globalScale;
            this._icon.width *= _loc2_;
            this._icon.height *= _loc2_;
            this._icon.x = -(this._icon.width * 0.5);
            this._icon.y = -(this._icon.height * 0.5);
         }
         this.listenToMouse(this._listenToMouse,_loc4_);
         if(this.imageLoadedCallback != null)
         {
            this.imageLoadedCallback();
         }
      }
      
      public function listenToMouse(param1:Boolean, param2:MovieClip = null) : void
      {
         var _loc3_:Sprite = null;
         this._listenToMouse = param1;
         if(!param2)
         {
            if(this._largeIcon)
            {
               if(this._largeIcon.numChildren <= 0)
               {
                  return;
               }
               _loc3_ = Sprite(this._largeIcon.getChildAt(0));
            }
            else
            {
               if(!this._icon || this._icon.numChildren <= 0)
               {
                  return;
               }
               _loc3_ = Sprite(this._icon.getChildAt(0));
            }
            if(!_loc3_)
            {
               return;
            }
            param2 = MovieClip(Loader(_loc3_.getChildAt(0)).content);
         }
         if(Boolean(param2) && param2.hasOwnProperty("listenToMouse"))
         {
            param2.listenToMouse = this._listenToMouse;
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
      
      public function get extraTooltipInfo() : String
      {
         return "";
      }
      
      public function get itemDefId() : int
      {
         return this._itemDefId;
      }
      
      public function set itemDefId(param1:int) : void
      {
         this._itemDefId = param1;
      }
   }
}

