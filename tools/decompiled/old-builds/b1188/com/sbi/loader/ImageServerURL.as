package com.sbi.loader
{
   import com.sbi.graphics.ImageArray;
   import com.sbi.graphics.ImageArrayHelper;
   import com.sbi.graphics.PaletteHelper;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   public class ImageServerURL extends EventDispatcher
   {
      
      private static var _instance:ImageServerURL;
      
      private static const IMAGE_ARRAY_PATH:String = "imageArrays/";
      
      private static const PALETTE_NAME:String = "paletteData";
      
      private var _imageCacheArray:Array;
      
      private var _loaderCacheArray:Array;
      
      private var _layerInfo:Object;
      
      public function ImageServerURL(param1:Class)
      {
         super();
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid Singleton access.  Use ImageServerURL.instance.");
         }
         this._imageCacheArray = new Array();
         this._loaderCacheArray = new Array();
      }
      
      public static function get instance() : ImageServerURL
      {
         if(!_instance)
         {
            _instance = new ImageServerURL(SingletonLock);
         }
         return _instance;
      }
      
      public function set layerInfo(param1:Object) : void
      {
         this._layerInfo = param1;
      }
      
      public function getLayerIndex(param1:int) : int
      {
         return this._layerInfo[param1];
      }
      
      public function requestGlobalPalette() : void
      {
         var _loc1_:ImageServerEvent = null;
         var _loc2_:LoaderCacheEntry_URL = null;
         if(this.isGlobalPaletteCached())
         {
            _loc1_ = new ImageServerEvent(ImageServerEvent.ON_GLOBAL_PALETTE);
            _loc1_.imageData = null;
            dispatchEvent(_loc1_);
         }
         else
         {
            _loc2_ = new LoaderCacheEntry_URL(PALETTE_NAME);
            _loc2_.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetGamePalette);
            _loc2_.load();
            this._loaderCacheArray["palette"] = {"l":_loc2_};
         }
      }
      
      public function requestImage(param1:uint, param2:Boolean = true) : void
      {
         var _loc3_:LoaderCacheEntry_URL = null;
         if(!param2 || this.getFromCache(param1) == false)
         {
            if(!this._loaderCacheArray[param1])
            {
               _loc3_ = new LoaderCacheEntry_URL(IMAGE_ARRAY_PATH + param1);
               _loc3_.id = param1;
               _loc3_.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetImageData);
               _loc3_.load();
               this._loaderCacheArray[param1] = {
                  "l":_loc3_,
                  "c":1
               };
            }
            else
            {
               ++this._loaderCacheArray[param1].c;
            }
         }
      }
      
      public function requestImages(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this.requestImage(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      private function getFromCache(param1:uint) : Boolean
      {
         var _loc3_:ImageServerEvent = null;
         var _loc2_:Object = this.searchCache(param1);
         if(_loc2_)
         {
            _loc3_ = new ImageServerEvent(ImageServerEvent.ON_NEW_DATA);
            _loc3_.id = _loc2_.id;
            _loc3_.imageData = _loc2_.imageData;
            _loc3_.frames = _loc2_.frames;
            _loc3_.layer = _loc2_.layer;
            _loc3_.success = _loc3_.imageData == null ? false : true;
            dispatchEvent(_loc3_);
         }
         return _loc2_ == null ? false : true;
      }
      
      private function isGlobalPaletteCached() : Boolean
      {
         return Boolean(PaletteHelper.gamePalette);
      }
      
      private function searchCache(param1:uint) : Object
      {
         return this._imageCacheArray[param1];
      }
      
      private function onResultGetGamePalette(param1:LoaderEvent) : void
      {
         var _loc2_:ImageServerEvent = null;
         var _loc3_:ByteArray = null;
         var _loc4_:ByteArray = null;
         var _loc5_:ByteArray = null;
         var _loc6_:ByteArray = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1)
         {
            this._loaderCacheArray["palette"].l.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetGamePalette);
            this._loaderCacheArray["palette"] = null;
            _loc2_ = new ImageServerEvent(ImageServerEvent.ON_GLOBAL_PALETTE);
            _loc3_ = param1.entry.data as ByteArray;
            _loc4_ = new ByteArray();
            _loc5_ = new ByteArray();
            _loc6_ = new ByteArray();
            _loc3_.position = 0;
            _loc7_ = _loc3_.readInt();
            _loc8_ = 4;
            _loc4_.writeBytes(_loc3_,_loc8_,_loc7_);
            _loc4_.position = 0;
            _loc8_ += _loc7_;
            _loc3_.position = _loc8_;
            _loc7_ = _loc3_.readInt();
            _loc8_ += 4;
            _loc5_.writeBytes(_loc3_,_loc8_,_loc7_);
            _loc5_.position = 0;
            _loc8_ += _loc7_;
            _loc3_.position = _loc8_;
            _loc7_ = _loc3_.readInt();
            _loc8_ += 4;
            _loc6_.writeBytes(_loc3_,_loc8_,_loc7_);
            _loc6_.position = 0;
            _loc2_.genericData = {
               "palette":_loc4_,
               "avatarPalette1":_loc5_,
               "avatarPalette2":_loc6_
            };
            dispatchEvent(_loc2_);
            return;
         }
         throw new Error("Got 0 for GetGamePalette request!");
      }
      
      private function onResultGetImageData(param1:LoaderEvent) : void
      {
         var _loc5_:ImageServerEvent = null;
         var _loc2_:ImageServerEvent = new ImageServerEvent(ImageServerEvent.ON_NEW_DATA);
         _loc2_.id = param1.entry.id;
         var _loc3_:Object = param1.entry.data;
         if(_loc3_ == null)
         {
            this._imageCacheArray[_loc2_.id] = {
               "id":_loc2_.id,
               "imageData":null,
               "layer":0,
               "frames":0
            };
            _loc2_.success = false;
         }
         else
         {
            if(_loc3_.v != ImageArray.VERSION)
            {
               throw new Error("ERROR: Unrecognized version number(" + _loc3_.v.toString(16) + ")!");
            }
            _loc2_.imageData = _loc3_;
            _loc2_.layer = this._layerInfo[ImageArrayHelper.layerId(_loc2_.id)];
            _loc2_.frames = _loc3_.f.length;
            this._imageCacheArray[_loc2_.id] = {
               "id":_loc2_.id,
               "imageData":_loc3_,
               "layer":_loc2_.layer,
               "frames":_loc2_.frames
            };
         }
         this._loaderCacheArray[_loc2_.id].l.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetImageData);
         var _loc4_:* = int(this._loaderCacheArray[_loc2_.id].c);
         this._loaderCacheArray[_loc2_.id] = null;
         while(_loc4_-- > 0)
         {
            _loc5_ = new ImageServerEvent(ImageServerEvent.ON_NEW_DATA);
            _loc5_.id = _loc2_.id;
            _loc5_.imageData = _loc2_.imageData;
            _loc5_.layer = _loc2_.layer;
            _loc5_.frames = _loc2_.frames;
            _loc5_.success = _loc2_.success;
            dispatchEvent(_loc5_);
         }
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
