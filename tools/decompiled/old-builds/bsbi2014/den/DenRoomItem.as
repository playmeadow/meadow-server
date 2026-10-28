package den
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.MediaHelper;
   
   public class DenRoomItem
   {
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      public var invId:int;
      
      public var itemDefId:int;
      
      public var value:int;
      
      public var name:String;
      
      public var itemStatus:int;
      
      public var isIconLoaded:Boolean;
      
      public var imageLoadedCallback:Function;
      
      public var enviroType:int;
      
      public var currencyType:int;
      
      public var endTime:uint;
      
      public var recycleValue:int;
      
      private var _diamondDefId:int = -1;
      
      private var _mediaId:int;
      
      private var _mediaIdLarge:int;
      
      private var _mediaHelper:MediaHelper;
      
      private var _mediaHelperLarge:MediaHelper;
      
      private var _isMemberOnly:Boolean;
      
      private var _waitForSmallIcon:Boolean;
      
      private var _waitForLargeIcon:Boolean;
      
      private var _icon:Sprite;
      
      private var _largeIcon:Sprite;
      
      private var _isShopItem:Boolean;
      
      public function DenRoomItem()
      {
         super();
      }
      
      public function init(initInvId:int, initItemDefId:int, initMediaId:int, initValue:int, initName:String, initEnviroType:int, membersOnly:Boolean, initEndTime:uint = 0) : void
      {
         this.invId = initInvId;
         this.itemDefId = initItemDefId;
         this._mediaId = initMediaId;
         this.value = initValue;
         this.recycleValue = this.value * gMainFrame.clientInfo.recyclePercentage;
         this.name = initName;
         this._isMemberOnly = membersOnly;
         this.enviroType = initEnviroType;
         this.endTime = initEndTime;
         this._icon = new Sprite();
         this._waitForSmallIcon = true;
      }
      
      public function destroy() : void
      {
         this._icon = null;
         this._largeIcon = null;
      }
      
      public function initShopItem(initInvId:int, initItemDefId:int, initMediaId:int, initMediaIdLarge:int, initValue:int, initName:String, initEnviroType:int, membersOnly:Boolean, initItemStatus:int = 0, initCurrencyType:int = 0, initEndtime:uint = 0) : void
      {
         this.invId = initInvId;
         this.itemDefId = initItemDefId;
         this._mediaId = initMediaId;
         this._mediaIdLarge = initMediaIdLarge;
         this.name = initName;
         this._isMemberOnly = membersOnly;
         this.itemStatus = initItemStatus;
         this.value = this.isOnSale ? int(initValue * 0.5) : initValue;
         this.enviroType = initEnviroType;
         this.currencyType = initCurrencyType;
         this.endTime = initEndtime;
         this.recycleValue = initValue * gMainFrame.clientInfo.recyclePercentage;
         this._isShopItem = true;
         this._icon = new Sprite();
         this._largeIcon = new Sprite();
         this._waitForSmallIcon = this._waitForLargeIcon = true;
         this.makeShopIcons();
      }
      
      public function clone() : DenRoomItem
      {
         var clonedItem:DenRoomItem = new DenRoomItem();
         if(this._isShopItem)
         {
            clonedItem.initShopItem(this.invId,this.itemDefId,this._mediaId,this._mediaIdLarge,this.value,this.name,this.enviroType,this._isMemberOnly,this.itemStatus,this.currencyType,this.endTime);
         }
         else
         {
            clonedItem.init(this.invId,this.itemDefId,this._mediaId,this.value,this.name,this.enviroType,this._isMemberOnly,this.endTime);
         }
         return clonedItem;
      }
      
      private function makeIcon() : void
      {
         var denRoomHelper:MediaHelper = new MediaHelper();
         denRoomHelper.init(this._mediaId,this.mediaHelperCallback,true);
      }
      
      private function makeShopIcons() : void
      {
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this._mediaId,this.mediaHelperCallback,true);
         this._mediaHelperLarge = new MediaHelper();
         this._mediaHelperLarge.init(this._mediaIdLarge,this.mediaHelperCallback,true);
      }
      
      private function mediaHelperCallback(mc:MovieClip) : void
      {
         if(this._mediaId == mc.mediaHelper.id)
         {
            if(Boolean(this._icon))
            {
               this._icon.addChild(mc);
            }
            if(!this._isShopItem)
            {
               this._icon.x = -(this._icon.width * 0.5);
               this._icon.y = -(this._icon.height * 0.5);
            }
            if(Boolean(this._mediaHelper))
            {
               this._mediaHelper.destroy();
               this._mediaHelper = null;
            }
         }
         else if(this._mediaIdLarge == mc.mediaHelper.id)
         {
            if(Boolean(this._largeIcon))
            {
               this._largeIcon.addChild(mc);
            }
            if(!this._isShopItem)
            {
               this._largeIcon.x = -(this._largeIcon.width * 0.5);
               this._largeIcon.y = -(this._largeIcon.height * 0.5);
            }
            if(Boolean(this._mediaHelperLarge))
            {
               this._mediaHelperLarge.destroy();
               this._mediaHelperLarge = null;
            }
         }
         if(this.imageLoadedCallback != null)
         {
            this.imageLoadedCallback();
         }
         this.isIconLoaded = true;
      }
      
      public function get icon() : Sprite
      {
         return this._icon;
      }
      
      public function get largeIcon() : Sprite
      {
         return this._largeIcon;
      }
      
      public function get mediaId() : int
      {
         return this._mediaId;
      }
      
      public function get mediaIdLarge() : int
      {
         return this._mediaIdLarge;
      }
      
      public function get isMemberOnly() : Boolean
      {
         return this._isMemberOnly;
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
      
      public function get diamondDefId() : int
      {
         return this._diamondDefId;
      }
      
      public function set diamondDefId(value:int) : void
      {
         this._diamondDefId = value;
      }
   }
}

