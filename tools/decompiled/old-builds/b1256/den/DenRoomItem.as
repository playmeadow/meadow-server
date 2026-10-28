package den
{
   import currency.CombinedCurrencyItem;
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
      
      private var _combinedCurrencyItem:CombinedCurrencyItem;
      
      public function DenRoomItem()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int, param5:String, param6:int, param7:Boolean, param8:uint = 0) : void
      {
         invId = param1;
         itemDefId = param2;
         _mediaId = param3;
         value = param4;
         recycleValue = value * gMainFrame.clientInfo.recyclePercentage;
         name = param5;
         _isMemberOnly = param7;
         enviroType = param6;
         endTime = param8;
         _icon = new Sprite();
         _waitForSmallIcon = true;
         _combinedCurrencyItem = null;
      }
      
      public function destroy() : void
      {
         _icon = null;
         _largeIcon = null;
      }
      
      public function initShopItem(param1:int, param2:int, param3:int, param4:int, param5:int, param6:String, param7:int, param8:Boolean, param9:int = 0, param10:int = 0, param11:uint = 0) : void
      {
         invId = param1;
         itemDefId = param2;
         _mediaId = param3;
         _mediaIdLarge = param4;
         name = param6;
         _isMemberOnly = param8;
         itemStatus = param9;
         value = isOnSale ? param5 * 0.5 : param5;
         enviroType = param7;
         currencyType = param10;
         endTime = param11;
         recycleValue = param5 * gMainFrame.clientInfo.recyclePercentage;
         _combinedCurrencyItem = null;
         _isShopItem = true;
         _icon = new Sprite();
         _largeIcon = new Sprite();
         _waitForSmallIcon = _waitForLargeIcon = true;
         makeShopIcons();
      }
      
      public function clone() : DenRoomItem
      {
         var _loc1_:DenRoomItem = new DenRoomItem();
         if(_isShopItem)
         {
            _loc1_.initShopItem(invId,itemDefId,_mediaId,_mediaIdLarge,value,name,enviroType,_isMemberOnly,itemStatus,currencyType,endTime);
         }
         else
         {
            _loc1_.init(invId,itemDefId,_mediaId,value,name,enviroType,_isMemberOnly,endTime);
         }
         return _loc1_;
      }
      
      private function makeIcon() : void
      {
         var _loc1_:MediaHelper = new MediaHelper();
         _loc1_.init(_mediaId,mediaHelperCallback,true);
      }
      
      private function makeShopIcons() : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_mediaId,mediaHelperCallback,true);
         _mediaHelperLarge = new MediaHelper();
         _mediaHelperLarge.init(_mediaIdLarge,mediaHelperCallback,true);
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         if(_mediaId == param1.mediaHelper.id)
         {
            if(_icon)
            {
               _icon.addChild(param1);
            }
            if(!_isShopItem)
            {
               _icon.x = -(_icon.width * 0.5);
               _icon.y = -(_icon.height * 0.5);
            }
            if(_mediaHelper)
            {
               _mediaHelper.destroy();
               _mediaHelper = null;
            }
         }
         else if(_mediaIdLarge == param1.mediaHelper.id)
         {
            if(_largeIcon)
            {
               _largeIcon.addChild(param1);
            }
            if(!_isShopItem)
            {
               _largeIcon.x = -(_largeIcon.width * 0.5);
               _largeIcon.y = -(_largeIcon.height * 0.5);
            }
            if(_mediaHelperLarge)
            {
               _mediaHelperLarge.destroy();
               _mediaHelperLarge = null;
            }
         }
         if(imageLoadedCallback != null)
         {
            imageLoadedCallback();
         }
         isIconLoaded = true;
      }
      
      public function get icon() : Sprite
      {
         return _icon;
      }
      
      public function get largeIcon() : Sprite
      {
         return _largeIcon;
      }
      
      public function get mediaId() : int
      {
         return _mediaId;
      }
      
      public function get mediaIdLarge() : int
      {
         return _mediaIdLarge;
      }
      
      public function get isMemberOnly() : Boolean
      {
         return _isMemberOnly;
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
      
      public function get diamondDefId() : int
      {
         return _diamondDefId;
      }
      
      public function set diamondDefId(param1:int) : void
      {
         _diamondDefId = param1;
      }
      
      public function get combinedCurrencyItem() : CombinedCurrencyItem
      {
         return _combinedCurrencyItem;
      }
   }
}

