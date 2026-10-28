package currency
{
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import loader.MediaHelper;
   
   public class CurrencyItem
   {
      
      public static const NORMAL_ITEM:int = 0;
      
      public static const NEW_ITEM:int = 1;
      
      public static const SALE_ITEM:int = 2;
      
      public static const CLEARANCE_ITEM:int = 3;
      
      public static const RARE_ITEM:int = 4;
      
      private var _itemDefId:int;
      
      private var _mediaId:int;
      
      private var _result:int;
      
      private var _resultType:int;
      
      private var _value:int;
      
      private var _currencyType:int;
      
      private var _name:String;
      
      private var _itemStatus:int;
      
      private var _isMemberOnly:Boolean;
      
      private var _enviroType:int;
      
      private var _endTime:uint;
      
      private var _mediaIdLarge:int;
      
      private var _mediaHelper:MediaHelper;
      
      private var _mediaHelperLarge:MediaHelper;
      
      private var _waitForSmallIcon:Boolean;
      
      private var _waitForLargeIcon:Boolean;
      
      private var _icon:Sprite;
      
      private var _largeIcon:Sprite;
      
      public var isIconLoaded:Boolean;
      
      public var imageLoadedCallback:Function;
      
      public function CurrencyItem()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:String, param8:uint = 0) : void
      {
         _itemDefId = param1;
         _mediaId = _mediaIdLarge = param2;
         _value = param5;
         _name = param7;
         _isMemberOnly = false;
         _enviroType = 0;
         _currencyType = param6;
         _result = param3;
         _resultType = param4;
         _endTime = param8;
         _icon = new Sprite();
         _largeIcon = new Sprite();
         _waitForSmallIcon = _waitForLargeIcon = true;
         makeIcons();
      }
      
      public function destroy() : void
      {
         _icon = null;
      }
      
      public function clone() : CurrencyItem
      {
         var _loc1_:CurrencyItem = new CurrencyItem();
         _loc1_.init(_itemDefId,_mediaId,_result,_resultType,_value,_currencyType,_name,_endTime);
         return _loc1_;
      }
      
      private function makeIcons() : void
      {
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(_mediaId,onIconLoaded,true);
         _mediaHelperLarge = new MediaHelper();
         _mediaHelperLarge.init(_mediaIdLarge,onLargeIconLoaded,true);
      }
      
      private function onIconLoaded(param1:MovieClip) : void
      {
         if(_mediaId == param1.mediaHelper.id)
         {
            if(_icon)
            {
               _icon.addChild(param1);
            }
         }
         if(imageLoadedCallback != null)
         {
            imageLoadedCallback();
         }
         isIconLoaded = true;
      }
      
      private function onLargeIconLoaded(param1:MovieClip) : void
      {
         if(_mediaIdLarge == param1.mediaHelper.id)
         {
            if(_largeIcon)
            {
               _largeIcon.addChild(param1);
            }
         }
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
         return _itemStatus == 2;
      }
      
      public function get isOnClearance() : Boolean
      {
         return _itemStatus == 3;
      }
      
      public function get isRare() : Boolean
      {
         return _itemStatus == 4;
      }
      
      public function get isNew() : Boolean
      {
         return _itemStatus == 1;
      }
      
      public function get isOcean() : Boolean
      {
         return _enviroType == 1;
      }
      
      public function get isLand() : Boolean
      {
         return _enviroType == 0;
      }
      
      public function get itemDefId() : int
      {
         return _itemDefId;
      }
      
      public function get itemStatus() : int
      {
         return _itemStatus;
      }
      
      public function get currencyType() : int
      {
         return _currencyType;
      }
      
      public function get value() : int
      {
         return _value;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function get endTime() : uint
      {
         return _endTime;
      }
      
      public function set endTime(param1:uint) : void
      {
         _endTime = param1;
      }
   }
}

