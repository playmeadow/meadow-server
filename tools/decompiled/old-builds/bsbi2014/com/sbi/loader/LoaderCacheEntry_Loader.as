package com.sbi.loader
{
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   
   public class LoaderCacheEntry_Loader extends LoaderCacheEntry_Base
   {
      
      public function LoaderCacheEntry_Loader(swf:String)
      {
         super(swf);
         _loader = new Loader();
         _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,loadProgress,false,0,true);
         _loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.loadComplete,false,0,true);
         _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioError,false,0,true);
      }
      
      override public function destroy() : void
      {
         _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,loadProgress);
         _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.loadComplete);
         _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,ioError);
         if(_completeCallback != null)
         {
            removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,_completeCallback);
            _completeCallback = null;
         }
      }
      
      override public function load(dataFormat:String = "binary", useDeployVersion:Boolean = true) : void
      {
         var request:URLRequest = null;
         var ldrContext:LoaderContext = null;
         if(!_isLoaded)
         {
            if(LoaderCache.localMode && (_swf.slice(0,7) == "assets/" || _swf.slice(0,6) == "games/" || _swf.indexOf("/") == -1))
            {
               request = new URLRequest(_swf);
            }
            else
            {
               request = LoaderCache.fetchCDNURLRequest(_swf,"/",useDeployVersion);
            }
            ldrContext = new LoaderContext(true,ApplicationDomain.currentDomain);
            if(!LoaderCache.localMode)
            {
               ldrContext.securityDomain = SecurityDomain.currentDomain;
            }
            _loader.load(request,ldrContext);
         }
         else
         {
            onLoadCompleteEvent();
         }
      }
      
      private function loadComplete(e:Event) : void
      {
         _isLoaded = true;
         var loaderInfo:LoaderInfo = e.target as LoaderInfo;
         _data = loaderInfo.content;
         onLoadCompleteEvent();
      }
   }
}

