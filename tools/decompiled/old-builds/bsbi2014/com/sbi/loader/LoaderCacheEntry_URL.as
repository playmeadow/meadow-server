package com.sbi.loader
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   
   public class LoaderCacheEntry_URL extends LoaderCacheEntry_Base
   {
      
      private var _isObj:Boolean;
      
      public function LoaderCacheEntry_URL(swf:String, isObj:Boolean = true)
      {
         super(swf);
         this._isObj = isObj;
         _loader = new URLLoader();
         _loader.addEventListener(ProgressEvent.PROGRESS,loadProgress,false,0,true);
         _loader.addEventListener(Event.COMPLETE,this.loadComplete,false,0,true);
         _loader.addEventListener(IOErrorEvent.IO_ERROR,ioError,false,0,true);
      }
      
      override public function destroy() : void
      {
         _loader.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
         _loader.removeEventListener(Event.COMPLETE,this.loadComplete);
         _loader.removeEventListener(IOErrorEvent.IO_ERROR,ioError);
         if(_completeCallback != null)
         {
            removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,_completeCallback);
            _completeCallback = null;
         }
      }
      
      override public function load(dataFormat:String = "binary", useDeployVersion:Boolean = true) : void
      {
         var request:URLRequest = null;
         if(!_isLoaded)
         {
            request = LoaderCache.fetchCDNURLRequest(_swf,"/",useDeployVersion);
            _loader.dataFormat = dataFormat;
            trace("LoaderCacheEntry_URL - URLLoader.load being called for cdnURL:" + request.url + " dataFormat:" + dataFormat);
            _loader.load(request);
         }
         else
         {
            onLoadCompleteEvent();
         }
      }
      
      private function loadComplete(e:Event) : void
      {
         var ba:ByteArray = null;
         var o:Object = null;
         _isLoaded = true;
         _data = _loader.data;
         if(_data is ByteArray)
         {
            ba = _loader.data as ByteArray;
            try
            {
               ba.uncompress();
            }
            catch(err:Error)
            {
            }
            ba.position = 0;
            if(this._isObj)
            {
               o = ba.readObject();
               if(ba.bytesAvailable == 0)
               {
                  _data = o;
               }
               else
               {
                  ba.position = 0;
                  _data = ba;
               }
            }
            else
            {
               _data = ba;
            }
         }
         onLoadCompleteEvent();
      }
   }
}

