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
         this._itemDefId = param1;
         this._mediaId = this._mediaIdLarge = param2;
         this._value = param5;
         this._name = param7;
         this._isMemberOnly = false;
         this._enviroType = SbiConstants.ENVIRO_LAND;
         this._currencyType = param6;
         this._result = param3;
         this._resultType = param4;
         this._endTime = param8;
         this._icon = new Sprite();
         this._largeIcon = new Sprite();
         this._waitForSmallIcon = this._waitForLargeIcon = true;
         this.makeIcons();
      }
      
      public function destroy() : void
      {
         this._icon = null;
      }
      
      public function clone() : CurrencyItem
      {
         var _loc1_:CurrencyItem = new CurrencyItem();
         _loc1_.init(this._itemDefId,this._mediaId,this._result,this._resultType,this._value,this._currencyType,this._name,this._endTime);
         return _loc1_;
      }
      
      private function makeIcons() : void
      {
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(this._mediaId,this.onIconLoaded,true);
         this._mediaHelperLarge = new MediaHelper();
         this._mediaHelperLarge.init(this._mediaIdLarge,this.onLargeIconLoaded,true);
      }
      
      private function onIconLoaded(param1:MovieClip) : void
      {
         if(this._mediaId == param1.mediaHelper.id)
         {
            if(this._icon)
            {
               this._icon.addChild(param1);
            }
         }
         if(this.imageLoadedCallback != null)
         {
            this.imageLoadedCallback();
         }
         this.isIconLoaded = true;
      }
      
      private function onLargeIconLoaded(param1:MovieClip) : void
      {
         if(this._mediaIdLarge == param1.mediaHelper.id)
         {
            if(this._largeIcon)
            {
               this._largeIcon.addChild(param1);
            }
         }
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
         return this._itemStatus == SALE_ITEM;
      }
      
      public function get isOnClearance() : Boolean
      {
         return this._itemStatus == CLEARANCE_ITEM;
      }
      
      public function get isRare() : Boolean
      {
         return this._itemStatus == RARE_ITEM;
      }
      
      public function get isNew() : Boolean
      {
         return this._itemStatus == NEW_ITEM;
      }
      
      public function get isOcean() : Boolean
      {
         return this._enviroType == SbiConstants.ENVIRO_OCEAN;
      }
      
      public function get isLand() : Boolean
      {
         return this._enviroType == SbiConstants.ENVIRO_LAND;
      }
      
      public function get itemDefId() : int
      {
         return this._itemDefId;
      }
      
      public function get itemStatus() : int
      {
         return this._itemStatus;
      }
      
      public function get currencyType() : int
      {
         return this._currencyType;
      }
      
      public function get value() : int
      {
         return this._value;
      }
      
      public function get name() : String
      {
         return this._name;
      }
      
      public function get endTime() : uint
      {
         return this._endTime;
      }
      
      public function set endTime(param1:uint) : void
      {
         this._endTime = param1;
      }
   }
}

