package com.sbi.loader
{
   import flash.display.Loader;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   
   public class LoaderCacheEntry_Base extends EventDispatcher
   {
      
      protected var _parent:LoaderCache;
      
      protected var _loader:*;
      
      protected var _swf:String;
      
      protected var _isLoaded:Boolean;
      
      protected var _completeCallback:Function;
      
      protected var _data:Object;
      
      protected var _id:*;
      
      protected var _contentType:int;
      
      private var _percent:Number;
      
      private var _err:String;
      
      private var _progressCallback:Function;
      
      public function LoaderCacheEntry_Base(swf:String)
      {
         super();
         this._swf = swf;
      }
      
      public function set parent(p:LoaderCache) : void
      {
         this._parent = p;
      }
      
      public function set id(id:*) : void
      {
         this._id = id;
      }
      
      public function get id() : *
      {
         return this._id;
      }
      
      public function set contentType(ct:int) : void
      {
         this._contentType = ct;
      }
      
      public function get contentType() : int
      {
         return this._contentType;
      }
      
      public function get name() : String
      {
         return this._swf;
      }
      
      public function destroy() : void
      {
      }
      
      public function load(dataFormat:String = "binary", useDeployVersion:Boolean = true) : void
      {
      }
      
      public function setCompleteCallback(completeCallback:Function) : void
      {
         if(this._completeCallback != completeCallback)
         {
            if(this._completeCallback != null)
            {
               removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this._completeCallback);
            }
            addEventListener(LoaderEvent.ON_LOAD_COMPLETE,completeCallback,false,0,true);
            this._completeCallback = completeCallback;
         }
      }
      
      public function setProgressCallback(progressCallback:Function) : void
      {
         if(this._progressCallback != progressCallback)
         {
            if(this._progressCallback != null)
            {
               removeEventListener(LoaderEvent.ON_LOAD_PROGRESS,this._progressCallback);
            }
            addEventListener(LoaderEvent.ON_LOAD_PROGRESS,progressCallback,false,0,true);
            this._progressCallback = progressCallback;
         }
      }
      
      public function get progress() : Number
      {
         return this._percent;
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      public function get data() : Object
      {
         return this._data;
      }
      
      protected function onLoadCompleteEvent() : void
      {
         var newEvt:LoaderEvent = new LoaderEvent(LoaderEvent.ON_LOAD_COMPLETE);
         newEvt.status = true;
         newEvt.entry = this;
         dispatchEvent(newEvt);
         if(Boolean(this._parent))
         {
            this._parent.remove(this._swf);
         }
      }
      
      protected function onLoadProgressEvent() : void
      {
         var newEvt:LoaderEvent = new LoaderEvent(LoaderEvent.ON_LOAD_PROGRESS);
         newEvt.status = true;
         newEvt.entry = this;
         newEvt.percent = this._percent;
         dispatchEvent(newEvt);
      }
      
      protected function loadProgress(event:ProgressEvent) : void
      {
         this._percent = event.bytesLoaded / event.bytesTotal;
         this._percent = Math.round(this._percent * 100);
         this.onLoadProgressEvent();
      }
      
      protected function ioError(event:IOErrorEvent) : void
      {
         var newEvt:LoaderEvent = new LoaderEvent(LoaderEvent.ON_LOAD_COMPLETE);
         newEvt.status = false;
         newEvt.entry = this;
         newEvt.message = event.text;
         dispatchEvent(newEvt);
         if(Boolean(this._parent))
         {
            this._parent.remove(this._swf);
         }
      }
   }
}

