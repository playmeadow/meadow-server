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
      
      public function init(param1:int, param2:int, param3:int, param4:int, param5:String, param6:int, param7:Boolean, param8:uint = 0) : void
      {
         this.invId = param1;
         this.itemDefId = param2;
         this._mediaId = param3;
         this.value = param4;
         this.recycleValue = this.value * gMainFrame.clientInfo.recyclePercentage;
         this.name = param5;
         this._isMemberOnly = param7;
         this.enviroType = param6;
         this.endTime = param8;
         this._icon = new Sprite();
         this._waitForSmallIcon = true;
      }
      
      public function destroy() : void
      {
         this._icon = null;
         this._largeIcon = null;
      }
      
      public function initShopItem(param1:int, param2:int, param3:int, param4:int, param5:int, param6:String, param7:int, param8:Boolean, param9:int = 0, param10:int = 0, param11:uint = 0) : void
      {
         this.invId = param1;
         this.itemDefId = param2;
         this._mediaId = param3;
         this._mediaIdLarge = param4;
         this.name = param6;
         this._isMemberOnly = param8;
         this.itemStatus = param9;
         this.value = this.isOnSale ? int(param5 * 0.5) : param5;
         this.enviroType = param7;
         this.currencyType = param10;
         this.endTime = param11;
         this.recycleValue = param5 * gMainFrame.clientInfo.recyclePercentage;
         this._isShopItem = true;
         this._icon = new Sprite();
         this._largeIcon = new Sprite();
         this._waitForSmallIcon = this._waitForLargeIcon = true;
         this.makeShopIcons();
      }
      
      public function clone() : DenRoomItem
      {
         var _loc1_:DenRoomItem = new DenRoomItem();
         if(this._isShopItem)
         {
            _loc1_.initShopItem(this.invId,this.itemDefId,this._mediaId,this._mediaIdLarge,this.value,this.name,this.enviroType,this._isMemberOnly,this.itemStatus,this.currencyType,this.endTime);
         }
         else
         {
            _loc1_.init(this.invId,this.itemDefId,this._mediaId,this.value,this.name,this.enviroType,this._isMemberOnly,this.endTime);
         }
         return _loc1_;
      }
      
      private function makeIcon() : void
      {
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(this._mediaId,this.mediaHelperCallback,true);
      }
      
      private function makeShopIcons() : void
      {
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this._mediaId,this.mediaHelperCallback,true);
         this._mediaHelperLarge = new MediaHelper();
         this._mediaHelperLarge.init(this._mediaIdLarge,this.mediaHelperCallback,true);
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         if(this._mediaId == param1.mediaHelper.id)
         {
            if(this._icon)
            {
               this._icon.addChild(param1);
            }
            if(!this._isShopItem)
            {
               this._icon.x = -(this._icon.width * 0.5);
               this._icon.y = -(this._icon.height * 0.5);
            }
            if(this._mediaHelper)
            {
               this._mediaHelper.destroy();
               this._mediaHelper = null;
            }
         }
         else if(this._mediaIdLarge == param1.mediaHelper.id)
         {
            if(this._largeIcon)
            {
               this._largeIcon.addChild(param1);
            }
            if(!this._isShopItem)
            {
               this._largeIcon.x = -(this._largeIcon.width * 0.5);
               this._largeIcon.y = -(this._largeIcon.height * 0.5);
            }
            if(this._mediaHelperLarge)
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
         return this.enviroType == SbiConstants.ENVIRO_OCEAN;
      }
      
      public function get isLand() : Boolean
      {
         return this.enviroType == SbiConstants.ENVIRO_LAND;
      }
      
      public function get diamondDefId() : int
      {
         return this._diamondDefId;
      }
      
      public function set diamondDefId(param1:int) : void
      {
         this._diamondDefId = param1;
      }
   }
}

