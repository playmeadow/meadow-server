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
      
      public var endTime:uint;
      
      public var specialType:int;
      
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
      
      public static function getIconId(sortId:int) : int
      {
         if(sortId == SORT_FLOOR || sortId == SORT_PET)
         {
            return 1;
         }
         if(sortId == SORT_WALL)
         {
            return 2;
         }
         if(sortId == SORT_FLOORING || sortId == SORT_WALLPAPER || sortId == SORT_AUDIO)
         {
            return 3;
         }
         return sortId + 1;
      }
      
      public static function getInWorldId(sortId:int, currDenCatId:int) : int
      {
         if(sortId == SORT_FLOOR || sortId == SORT_PET)
         {
            return 1;
         }
         if(sortId == SORT_WALL)
         {
            return 2;
         }
         if(sortId == SORT_AUDIO)
         {
            return 3;
         }
         return currDenCatId;
      }
      
      public function init(initItemDefId:int, initInvIdx:int = 0, initCategoryId:int = 0, initVersion:int = 0, initRefId:int = 0, initPetExtra:int = 0, initPetExtra2:int = 0, initEndTime:uint = 0) : void
      {
         var currDef:Object = null;
         this.refId = initRefId;
         this.invIdx = initInvIdx;
         this._itemDefId = initItemDefId;
         this.categoryId = initCategoryId;
         this.version = initVersion;
         this.endTime = initEndTime;
         if(initRefId == REF_ID_PET_ITEM)
         {
            currDef = PetManager.getPetDef(this._itemDefId);
            this._itemDefId = DenXtCommManager.denItemDefIdForPetDefId(this._itemDefId);
            this.value = currDef.cost;
            this.layerId = DEN_PET_LAYER_ID;
            this.sortId = SORT_PET;
            this.isMemberOnly = currDef.isMember;
            this.itemStatus = currDef.status;
            this.value = this.isOnSale ? int(currDef.cost * 0.5) : int(currDef.cost);
            this.strmName = "";
            this.name = currDef.title;
            this.minigameDefId = 0;
            this.version2 = initPetExtra;
            this.version3 = initPetExtra2;
            this.enviroType = PetManager.getEnviroTypeByPetType(currDef.type);
            this.recycleValue = currDef.recycleValue == "0" || currDef.recycleValue == null ? int(currDef.cost * gMainFrame.clientInfo.recyclePercentage) : int(currDef.recycleValue);
            this.currencyType = 0;
            this._globalScale = 1;
            this.specialType = 0;
         }
         else
         {
            currDef = DenXtCommManager.getDenItemDef(initItemDefId);
            this.value = currDef.cost;
            this.layerId = currDef.layer;
            this.sortId = currDef.sortCat;
            this.isMemberOnly = currDef.membersOnly == "1";
            this.itemStatus = currDef.itemStatus;
            this.value = this.isOnSale ? int(currDef.cost * 0.5) : int(currDef.cost);
            this.strmName = this._itemDefId == DEF_AUDIO_DEF_ID ? DEF_AUDIO_STRMNAME : currDef.abbrName;
            this.name = currDef.name;
            this.minigameDefId = currDef.gameDefId;
            this.version2 = currDef.flag;
            this.enviroType = currDef.enviroType;
            this.currencyType = currDef.currencyType;
            this.recycleValue = currDef.recycleValue == "0" && this.currencyType != Item.TICKET_CURRENCY ? int(this.value * gMainFrame.clientInfo.recyclePercentage) : int(currDef.recycleValue);
            this._globalScale = currDef.scalePercent / 100;
            this.specialType = currDef.specialType;
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._iconHelper))
         {
            this._iconHelper.destroy();
            this._iconHelper = null;
         }
         this._icon = null;
         if(Boolean(this._largeIconHelper))
         {
            this._largeIconHelper.destroy();
            this._largeIconHelper = null;
         }
         this._largeIcon = null;
      }
      
      public function initShopItem(initItemDefId:int, initVersion:int, setRandomVersion:Boolean = false, initEndTime:uint = 0) : void
      {
         this._itemDefId = initItemDefId;
         this._setRandomVersion = setRandomVersion;
         this.version = initVersion;
         var currDef:Object = DenXtCommManager.getDenItemDef(initItemDefId);
         this.name = currDef.name;
         this.isMemberOnly = currDef.membersOnly == "1";
         this.itemStatus = currDef.itemStatus;
         this.value = this.isOnSale ? int(currDef.cost * 0.5) : int(currDef.cost);
         this.minigameDefId = currDef.gameDefId;
         this.sortId = currDef.sortCat;
         this.enviroType = currDef.enviroType;
         this.strmName = currDef.abbrName;
         this.version2 = currDef.flag;
         this.currencyType = currDef.currencyType;
         this._isShopItem = true;
         this._globalScale = currDef.scalePercent / 100;
         this.endTime = initEndTime;
      }
      
      public function ifItemDiffers(itemParam:DenItem) : Boolean
      {
         if(this.invIdx == itemParam.invIdx)
         {
            return true;
         }
         return false;
      }
      
      public function clone() : DenItem
      {
         var clonedItem:DenItem = new DenItem();
         if(this._isShopItem)
         {
            clonedItem.initShopItem(this._itemDefId,this.version,this._setRandomVersion,this.endTime);
         }
         else
         {
            clonedItem.init(this._itemDefId,this.invIdx,this.categoryId,this.version,this.refId,this.version2,this.version3,this.endTime);
         }
         if(this._diamondDefId != -1)
         {
            clonedItem._diamondDefId = this._diamondDefId;
            clonedItem.currencyType = this.currencyType;
            clonedItem.value = this.value;
            clonedItem.endTime = this.endTime;
         }
         return clonedItem;
      }
      
      public function makeSmallIcon() : void
      {
         var extraVersion:int = this.sortId == SORT_PET ? this.version2 : 0;
         var extraVersion2:int = this.sortId == SORT_PET ? this.version3 : 0;
         this._icon = new Sprite();
         this._iconHelper = new DenItemHelper();
         this._iconHelper.init(uint(this._itemDefId << 16 | getIconId(this.sortId)),this.iconReceived,this.version,0,extraVersion,extraVersion2);
      }
      
      public function makeLargeIcon() : void
      {
         var extraVersion:int = this.sortId == SORT_PET ? this.version2 : 0;
         var extraVersion2:int = this.sortId == SORT_PET ? this.version3 : 0;
         this._largeIcon = new Sprite();
         this._largeIconHelper = new DenItemHelper();
         this._largeIconHelper.init(uint(this._itemDefId << 16 | getIconId(this.sortId)),this.largeIconReceived,this.version,0,extraVersion,extraVersion2);
      }
      
      public function getVersions() : Array
      {
         var returnArray:Array = null;
         if(Boolean(this._iconHelper))
         {
            returnArray = this._iconHelper.getVersions();
         }
         else if(Boolean(this._largeIconHelper))
         {
            returnArray = this._largeIconHelper.getVersions();
         }
         if(returnArray == null)
         {
            this.version = 0;
         }
         return returnArray;
      }
      
      public function setVersion(v:int) : void
      {
         this.version = v;
         if(Boolean(this._iconHelper))
         {
            this._iconHelper.setVersion(v);
         }
         else if(Boolean(this._largeIconHelper))
         {
            this._largeIconHelper.setVersion(v);
         }
      }
      
      private function iconReceived(helper:DenItemHelper) : void
      {
         var versions:Array = null;
         helper.displayObject.cacheAsBitmap = true;
         this._icon.addChild(helper.displayObject);
         this.resizeAndPositionIcon(false);
         this.isIconLoaded = true;
         if(this._setRandomVersion)
         {
            versions = this.getVersions();
            if(Boolean(versions))
            {
               this.setVersion(versions[Math.floor(Math.random() * (versions.length - 1 + 1))]);
            }
         }
      }
      
      private function largeIconReceived(helper:DenItemHelper) : void
      {
         var versions:Array = null;
         helper.displayObject.cacheAsBitmap = true;
         this._largeIcon.addChild(helper.displayObject);
         this.resizeAndPositionIcon(true);
         this.isIconLoaded = true;
         if(this._setRandomVersion)
         {
            versions = this.getVersions();
            if(Boolean(versions))
            {
               this.setVersion(versions[Math.floor(Math.random() * (versions.length - 1 + 1))]);
            }
         }
      }
      
      private function resizeAndPositionIcon(isLargeIcon:Boolean) : void
      {
         var scale:Number = NaN;
         var spr:Sprite = null;
         if(isLargeIcon)
         {
            spr = Sprite(this._largeIcon.getChildAt(0));
         }
         else
         {
            spr = Sprite(this._icon.getChildAt(0));
         }
         var mc:MovieClip = MovieClip(Loader(spr.getChildAt(0)).content);
         for(var i:int = 0; i < mc.currentLabels.length; i++)
         {
            if(mc.currentLabels[i].name == "icon")
            {
               mc.gotoAndStop("icon");
               break;
            }
         }
         if(this._isShopItem)
         {
            if(isLargeIcon)
            {
               if(mc.hasOwnProperty("listenToMouseInShop"))
               {
                  this._listenToMouse = mc.listenToMouseInShop;
               }
               else
               {
                  this._listenToMouse = true;
               }
               scale = WIND_LARGE_SIZE / Math.max(this._largeIcon.width,this._largeIcon.height) * this._globalScale;
               this._largeIcon.width *= scale;
               this._largeIcon.height *= scale;
               this._largeIcon.x = -(this._largeIcon.width * 0.5);
               this._largeIcon.y = -(this._largeIcon.height * 0.5);
            }
            else
            {
               scale = WIND_MED_SIZE / Math.max(this._icon.width,this._icon.height) * this._globalScale;
               this._icon.width *= scale;
               this._icon.height *= scale;
               this._icon.x = -(this._icon.width * 0.5);
               this._icon.y = -(this._icon.height * 0.5);
            }
         }
         else
         {
            scale = WIND_SMALL_SIZE / Math.max(this._icon.width,this._icon.height) * this._globalScale;
            this._icon.width *= scale;
            this._icon.height *= scale;
            this._icon.x = -(this._icon.width * 0.5);
            this._icon.y = -(this._icon.height * 0.5);
         }
         this.listenToMouse(this._listenToMouse,mc);
         if(this.imageLoadedCallback != null)
         {
            this.imageLoadedCallback();
         }
      }
      
      public function listenToMouse(shouldListen:Boolean, mc:MovieClip = null) : void
      {
         var spr:Sprite = null;
         this._listenToMouse = shouldListen;
         if(!mc)
         {
            if(Boolean(this._largeIcon))
            {
               if(this._largeIcon.numChildren <= 0)
               {
                  return;
               }
               spr = Sprite(this._largeIcon.getChildAt(0));
            }
            else
            {
               if(!this._icon || this._icon.numChildren <= 0)
               {
                  return;
               }
               spr = Sprite(this._icon.getChildAt(0));
            }
            if(!spr)
            {
               return;
            }
            mc = MovieClip(Loader(spr.getChildAt(0)).content);
         }
         if(Boolean(mc) && mc.hasOwnProperty("listenToMouse"))
         {
            mc.listenToMouse = this._listenToMouse;
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
      
      public function set itemDefId(value:int) : void
      {
         this._itemDefId = value;
      }
   }
}

