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
      
      public function ImageServerURL(lock:Class)
      {
         super();
         if(lock != SingletonLock)
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
      
      public function set layerInfo(o:Object) : void
      {
         this._layerInfo = o;
      }
      
      public function getLayerIndex(layerId:int) : int
      {
         return this._layerInfo[layerId];
      }
      
      public function requestGlobalPalette() : void
      {
         var e:ImageServerEvent = null;
         var l:LoaderCacheEntry_URL = null;
         if(this.isGlobalPaletteCached())
         {
            e = new ImageServerEvent(ImageServerEvent.ON_GLOBAL_PALETTE);
            e.imageData = null;
            trace("imageServer dispatching cached game palette");
            dispatchEvent(e);
         }
         else
         {
            l = new LoaderCacheEntry_URL(PALETTE_NAME);
            l.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetGamePalette);
            l.load();
            this._loaderCacheArray["palette"] = {"l":l};
         }
      }
      
      public function requestImage(id:uint, bUseCache:Boolean = true) : void
      {
         var l:LoaderCacheEntry_URL = null;
         if(!bUseCache || this.getFromCache(id) == false)
         {
            if(!this._loaderCacheArray[id])
            {
               l = new LoaderCacheEntry_URL(IMAGE_ARRAY_PATH + id);
               l.id = id;
               l.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetImageData);
               l.load();
               this._loaderCacheArray[id] = {
                  "l":l,
                  "c":1
               };
            }
            else
            {
               ++this._loaderCacheArray[id].c;
            }
         }
      }
      
      public function requestImages(ids:Array) : void
      {
         for(var i:int = 0; i < ids.length; i++)
         {
            this.requestImage(ids[i]);
         }
      }
      
      private function getFromCache(id:uint) : Boolean
      {
         var e:ImageServerEvent = null;
         var r:Object = this.searchCache(id);
         if(Boolean(r))
         {
            e = new ImageServerEvent(ImageServerEvent.ON_NEW_DATA);
            e.id = r.id;
            e.imageData = r.imageData;
            e.frames = r.frames;
            e.layer = r.layer;
            e.success = e.imageData == null ? false : true;
            dispatchEvent(e);
         }
         return r == null ? false : true;
      }
      
      private function isGlobalPaletteCached() : Boolean
      {
         return Boolean(PaletteHelper.gamePalette);
      }
      
      private function searchCache(id:uint) : Object
      {
         return this._imageCacheArray[id];
      }
      
      private function onResultGetGamePalette(e:LoaderEvent) : void
      {
         var ie:ImageServerEvent = null;
         var ba:ByteArray = null;
         var pal:ByteArray = null;
         var a1pal:ByteArray = null;
         var a2pal:ByteArray = null;
         var len:int = 0;
         var pos:int = 0;
         if(Boolean(e))
         {
            this._loaderCacheArray["palette"].l.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetGamePalette);
            this._loaderCacheArray["palette"] = null;
            ie = new ImageServerEvent(ImageServerEvent.ON_GLOBAL_PALETTE);
            ba = e.entry.data as ByteArray;
            pal = new ByteArray();
            a1pal = new ByteArray();
            a2pal = new ByteArray();
            ba.position = 0;
            len = ba.readInt();
            pos = 4;
            pal.writeBytes(ba,pos,len);
            pal.position = 0;
            pos += len;
            ba.position = pos;
            len = ba.readInt();
            pos += 4;
            a1pal.writeBytes(ba,pos,len);
            a1pal.position = 0;
            pos += len;
            ba.position = pos;
            len = ba.readInt();
            pos += 4;
            a2pal.writeBytes(ba,pos,len);
            a2pal.position = 0;
            ie.genericData = {
               "palette":pal,
               "avatarPalette1":a1pal,
               "avatarPalette2":a2pal
            };
            dispatchEvent(ie);
            return;
         }
         throw new Error("Got 0 for GetGamePalette request!");
      }
      
      private function onResultGetImageData(le:LoaderEvent) : void
      {
         var ne:ImageServerEvent = null;
         var e:ImageServerEvent = new ImageServerEvent(ImageServerEvent.ON_NEW_DATA);
         e.id = le.entry.id;
         var o:Object = le.entry.data;
         if(o == null)
         {
            this._imageCacheArray[e.id] = {
               "id":e.id,
               "imageData":null,
               "layer":0,
               "frames":0
            };
            e.success = false;
         }
         else
         {
            if(o.v != ImageArray.VERSION)
            {
               throw new Error("ERROR: Unrecognized version number(" + o.v.toString(16) + ")!");
            }
            e.imageData = o;
            e.layer = this._layerInfo[ImageArrayHelper.layerId(e.id)];
            e.frames = o.f.length;
            this._imageCacheArray[e.id] = {
               "id":e.id,
               "imageData":o,
               "layer":e.layer,
               "frames":e.frames
            };
         }
         this._loaderCacheArray[e.id].l.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetImageData);
         var c:int = int(this._loaderCacheArray[e.id].c);
         this._loaderCacheArray[e.id] = null;
         while(c-- > 0)
         {
            ne = new ImageServerEvent(ImageServerEvent.ON_NEW_DATA);
            ne.id = e.id;
            ne.imageData = e.imageData;
            ne.layer = e.layer;
            ne.frames = e.frames;
            ne.success = e.success;
            dispatchEvent(ne);
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
