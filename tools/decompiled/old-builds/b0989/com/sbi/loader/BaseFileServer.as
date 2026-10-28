package com.sbi.loader
{
   import flash.events.EventDispatcher;
   
   public class BaseFileServer extends EventDispatcher
   {
      
      private var _contentPath:String;
      
      private var _loaderArray:Array;
      
      private var _cacheArray:Array;
      
      public function BaseFileServer(param1:String)
      {
         super();
         this._contentPath = param1;
         this._loaderArray = new Array();
         this._cacheArray = new Array();
      }
      
      public function updatePath(param1:String) : void
      {
         this._contentPath = param1;
      }
      
      public function clearFromCache(param1:String, param2:int) : void
      {
         if(this._cacheArray[param1])
         {
            if(this._cacheArray[param1][param2])
            {
               delete this._cacheArray[param1][param2];
            }
         }
         if(this._loaderArray[param1])
         {
            if(this._loaderArray[param1][param2])
            {
               delete this._loaderArray[param1][param2];
            }
         }
      }
      
      public function requestFile(param1:uint, param2:Boolean = false, param3:int = 0, param4:Boolean = true) : void
      {
         var _loc5_:LoaderCacheEntry_URL = null;
         if(param2 || this.getFromCache(param1) == false)
         {
            if(!(this._loaderArray[this._contentPath] ? this._loaderArray[this._contentPath][param1] : false))
            {
               _loc5_ = new LoaderCacheEntry_URL(this._contentPath + param1,false);
               _loc5_.id = param1;
               _loc5_.contentType = param3;
               _loc5_.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetData);
               _loc5_.load("binary",param4);
               if(this._loaderArray[this._contentPath] == null)
               {
                  this._loaderArray[this._contentPath] = [];
               }
               this._loaderArray[this._contentPath][param1] = {
                  "l":_loc5_,
                  "c":1
               };
            }
            else
            {
               ++this._loaderArray[this._contentPath][param1].c;
            }
         }
      }
      
      public function requestFiles(param1:Array) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            this.requestFile(param1[_loc2_]);
            _loc2_++;
         }
      }
      
      private function getFromCache(param1:uint) : Boolean
      {
         var _loc2_:Object = this.searchCache(param1);
         if(_loc2_)
         {
            this.newEvent(_loc2_.id,_loc2_.data,true,_loc2_.contentType);
         }
         return _loc2_ == null ? false : true;
      }
      
      private function searchCache(param1:uint) : Object
      {
         return this._cacheArray[this._contentPath] ? this._cacheArray[this._contentPath][param1] : null;
      }
      
      private function onResultGetData(param1:LoaderEvent) : void
      {
         var _loc5_:* = 0;
         var _loc2_:FileServerEvent = new FileServerEvent(FileServerEvent.ON_NEW_DATA);
         _loc2_.id = param1.entry.id;
         _loc2_.contentType = param1.entry.contentType;
         var _loc3_:Object = param1.entry.data;
         if(_loc3_ == null)
         {
            _loc2_.success = false;
         }
         else
         {
            _loc2_.data = _loc3_;
            if(this._cacheArray[this._contentPath] == null)
            {
               this._cacheArray[this._contentPath] = [];
            }
            this._cacheArray[this._contentPath][_loc2_.id] = {
               "id":_loc2_.id,
               "data":_loc3_,
               "contentType":_loc2_.contentType
            };
         }
         var _loc4_:Object = this._loaderArray[this._contentPath][_loc2_.id];
         if(_loc4_)
         {
            _loc4_.l.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.onResultGetData);
            _loc5_ = int(_loc4_.c);
            this._loaderArray[this._contentPath][_loc2_.id] = null;
            while(_loc5_-- > 0)
            {
               this.newEvent(_loc2_.id,_loc2_.data,_loc2_.success,_loc2_.contentType);
            }
         }
      }
      
      private function newEvent(param1:int, param2:*, param3:Boolean, param4:int = 0) : void
      {
         var _loc5_:FileServerEvent = new FileServerEvent(FileServerEvent.ON_NEW_DATA);
         _loc5_.id = param1;
         _loc5_.data = param2;
         _loc5_.success = param3;
         _loc5_.contentType = param4;
         dispatchEvent(_loc5_);
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
