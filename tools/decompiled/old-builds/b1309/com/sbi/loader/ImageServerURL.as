package com.sbi.loader
{
   import com.sbi.graphics.ImageArrayHelper;
   import com.sbi.graphics.PaletteHelper;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   public class ImageServerURL extends EventDispatcher
   {
      
      private static const IMAGE_ARRAY_PATH:String = "imageArrays/";
      
      private static const PALETTE_NAME:String = "paletteData";
      
      private static var _instance:ImageServerURL;
      
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
         _imageCacheArray = [];
         _loaderCacheArray = [];
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
         _layerInfo = param1;
      }
      
      public function getLayerIndex(param1:int) : int
      {
         return _layerInfo[param1];
      }
      
      public function requestGlobalPalette() : void
      {
         var _loc1_:ImageServerEvent = null;
         var _loc2_:LoaderCacheEntry_URL = null;
         if(isGlobalPaletteCached())
         {
            _loc1_ = new ImageServerEvent("OnGlobalPalette");
            _loc1_.imageData = null;
            trace("imageServer dispatching cached game palette");
            dispatchEvent(_loc1_);
         }
         else
         {
            _loc2_ = new LoaderCacheEntry_URL("paletteData");
            _loc2_.addEventListener("OnLoadComplete",onResultGetGamePalette);
            _loc2_.load();
            _loaderCacheArray["palette"] = {"l":_loc2_};
         }
      }
      
      public function requestImage(param1:uint, param2:Boolean = true) : void
      {
         var _loc3_:LoaderCacheEntry_URL = null;
         if(!param2 || getFromCache(param1) == false)
         {
            if(!_loaderCacheArray[param1])
            {
               _loc3_ = new LoaderCacheEntry_URL("imageArrays/" + param1);
               _loc3_.id = param1;
               _loc3_.addEventListener("OnLoadComplete",onResultGetImageData);
               _loc3_.load();
               _loaderCacheArray[param1] = {
                  "l":_loc3_,
                  "c":1
               };
            }
            else
            {
               _loaderCacheArray[param1].c++;
            }
         }
      }
      
      public function requestImages(param1:Array) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            requestImage(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      private function getFromCache(param1:uint) : Boolean
      {
         var _loc3_:ImageServerEvent = null;
         var _loc2_:Object = searchCache(param1);
         if(_loc2_)
         {
            _loc3_ = new ImageServerEvent("OnNewData");
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
         return _imageCacheArray[param1];
      }
      
      private function onResultGetGamePalette(param1:LoaderEvent) : void
      {
         var _loc7_:ImageServerEvent = null;
         var _loc8_:ByteArray = null;
         var _loc6_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc4_:ByteArray = null;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         if(param1)
         {
            _loaderCacheArray["palette"].l.removeEventListener("OnLoadComplete",onResultGetGamePalette);
            _loaderCacheArray["palette"] = null;
            _loc7_ = new ImageServerEvent("OnGlobalPalette");
            _loc8_ = param1.entry.data as ByteArray;
            _loc6_ = new ByteArray();
            _loc3_ = new ByteArray();
            _loc4_ = new ByteArray();
            _loc8_.position = 0;
            _loc2_ = _loc8_.readInt();
            _loc5_ = 4;
            _loc6_.writeBytes(_loc8_,_loc5_,_loc2_);
            _loc6_.position = 0;
            _loc5_ += _loc2_;
            _loc8_.position = _loc5_;
            _loc2_ = _loc8_.readInt();
            _loc5_ += 4;
            _loc3_.writeBytes(_loc8_,_loc5_,_loc2_);
            _loc3_.position = 0;
            _loc5_ += _loc2_;
            _loc8_.position = _loc5_;
            _loc2_ = _loc8_.readInt();
            _loc5_ += 4;
            _loc4_.writeBytes(_loc8_,_loc5_,_loc2_);
            _loc4_.position = 0;
            _loc7_.genericData = {
               "palette":_loc6_,
               "avatarPalette1":_loc3_,
               "avatarPalette2":_loc4_
            };
            dispatchEvent(_loc7_);
            return;
         }
         throw new Error("Got 0 for GetGamePalette request!");
      }
      
      private function onResultGetImageData(param1:LoaderEvent) : void
      {
         var _loc4_:ImageServerEvent = null;
         var _loc3_:ImageServerEvent = new ImageServerEvent("OnNewData");
         _loc3_.id = param1.entry.id;
         var _loc5_:Object = param1.entry.data;
         if(_loc5_ == null)
         {
            _imageCacheArray[_loc3_.id] = {
               "id":_loc3_.id,
               "imageData":null,
               "layer":0,
               "frames":0
            };
            _loc3_.success = false;
         }
         else
         {
            if(_loc5_.v != 117967104)
            {
               throw new Error("ERROR: Unrecognized version number(" + _loc5_.v.toString(16) + ")!");
            }
            _loc3_.imageData = _loc5_;
            _loc3_.layer = _layerInfo[ImageArrayHelper.layerId(_loc3_.id)];
            _loc3_.frames = _loc5_.f.length;
            _imageCacheArray[_loc3_.id] = {
               "id":_loc3_.id,
               "imageData":_loc5_,
               "layer":_loc3_.layer,
               "frames":_loc3_.frames
            };
         }
         _loaderCacheArray[_loc3_.id].l.removeEventListener("OnLoadComplete",onResultGetImageData);
         var _loc2_:int = int(_loaderCacheArray[_loc3_.id].c);
         _loaderCacheArray[_loc3_.id] = null;
         while(_loc2_-- > 0)
         {
            _loc4_ = new ImageServerEvent("OnNewData");
            _loc4_.id = _loc3_.id;
            _loc4_.imageData = _loc3_.imageData;
            _loc4_.layer = _loc3_.layer;
            _loc4_.frames = _loc3_.frames;
            _loc4_.success = _loc3_.success;
            dispatchEvent(_loc4_);
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
