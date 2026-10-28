package com.sbi.loader
{
   import flash.events.EventDispatcher;
   
   public class BaseFileServer extends EventDispatcher
   {
      
      private var _contentPath:String;
      
      private var _loaderArray:Array;
      
      private var _cacheArray:Array;
      
      public function BaseFileServer(path:String)
      {
         super();
         this._contentPath = path;
         this._loaderArray = new Array();
         this._cacheArray = new Array();
      }
      
      public function updatePath(path:String) : void
      {
         this._contentPath = path;
      }
      
      public function clearFromCache(path:String, id:int) : void
      {
         if(Boolean(this._cacheArray[path]))
         {
            if(Boolean(this._cacheArray[path][id]))
            {
               delete this._cacheArray[path][id];
            }
         }
         if(Boolean(this._loaderArray[path]))
         {
            if(Boolean(this._loaderArray[path][id]))
            {
               delete this._loaderArray[path][id];
            }
         }
      }
      
      public function requestFile(id:uint, noCache:Boolean = false, contentType:int = 0, useDeployVersion:Boolean = true) : void
      {
         var l:LoaderCacheEntry_URL = null;
         if(noCache || this.getFromCache(id) == false)
         {
            if(!(Boolean(this._loaderArray[this._contentPath]) ? this._loaderArray[this._contentPath][id] : false))
            {
               l = new LoaderCacheEntry_URL(this._contentPath + id,false);
               l.id = id;
               l.contentType = contentType;
               l.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetData);
               l.load("binary",useDeployVersion);
               if(this._loaderArray[this._contentPath] == null)
               {
                  this._loaderArray[this._contentPath] = [];
               }
               this._loaderArray[this._contentPath][id] = {
                  "l":l,
                  "c":1
               };
            }
            else
            {
               ++this._loaderArray[this._contentPath][id].c;
            }
         }
      }
      
      public function requestFiles(ids:Array) : void
      {
         for(var i:int = 0; i < ids.length; )
         {
            this.requestFile(ids[i]);
            i++;
         }
      }
      
      private function getFromCache(id:uint) : Boolean
      {
         var r:Object = this.searchCache(id);
         if(Boolean(r))
         {
            this.newEvent(r.id,r.data,true,r.contentType);
         }
         return r == null ? false : true;
      }
      
      private function searchCache(id:uint) : Object
      {
         return Boolean(this._cacheArray[this._contentPath]) ? this._cacheArray[this._contentPath][id] : null;
      }
      
      private function onResultGetData(le:LoaderEvent) : void
      {
         var c:int = 0;
         var e:FileServerEvent = new FileServerEvent(FileServerEvent.ON_NEW_DATA);
         e.id = le.entry.id;
         e.contentType = le.entry.contentType;
         var o:Object = le.entry.data;
         if(o == null)
         {
            e.success = false;
         }
         else
         {
            e.data = o;
            if(this._cacheArray[this._contentPath] == null)
            {
               this._cacheArray[this._contentPath] = [];
            }
            this._cacheArray[this._contentPath][e.id] = {
               "id":e.id,
               "data":o,
               "contentType":e.contentType
            };
         }
         var currObj:Object = this._loaderArray[this._contentPath][e.id];
         if(Boolean(currObj))
         {
            currObj.l.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetData);
            c = int(currObj.c);
            this._loaderArray[this._contentPath][e.id] = null;
            while(c-- > 0)
            {
               this.newEvent(e.id,e.data,e.success,e.contentType);
            }
         }
      }
      
      private function newEvent(id:int, data:*, success:Boolean, contentType:int = 0) : void
      {
         var ne:FileServerEvent = new FileServerEvent(FileServerEvent.ON_NEW_DATA);
         ne.id = id;
         ne.data = data;
         ne.success = success;
         ne.contentType = contentType;
         dispatchEvent(ne);
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
