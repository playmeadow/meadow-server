package org.osmf.utils
{
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   [ExcludeClass]
   public class HTTPLoader extends LoaderBase
   {
      
      public function HTTPLoader()
      {
         super();
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var urlResource:URLResource = resource as URLResource;
         if(urlResource == null || urlResource.url == null || urlResource.url.length <= 0)
         {
            return false;
         }
         var url:URL = new URL(urlResource.url);
         if(url.protocol.search(/http$|https$/i) == -1 && url.protocol != "")
         {
            return false;
         }
         return true;
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         var urlResource:URLResource;
         var urlReq:URLRequest;
         var loader:URLLoader = null;
         var onLoadComplete:Function = null;
         var onIOError:Function = null;
         var onSecurityError:Function = null;
         var toggleLoaderListeners:Function = function(loader:URLLoader, on:Boolean):void
         {
            if(on)
            {
               loader.addEventListener(Event.COMPLETE,onLoadComplete);
               loader.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
               loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
            }
            else
            {
               loader.removeEventListener(Event.COMPLETE,onLoadComplete);
               loader.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
               loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
            }
         };
         onLoadComplete = function(event:Event):void
         {
            toggleLoaderListeners(loader,false);
            var httpLoadTrait:HTTPLoadTrait = loadTrait as HTTPLoadTrait;
            httpLoadTrait.urlLoader = loader;
            updateLoadTrait(loadTrait,LoadState.READY);
         };
         onIOError = function(ioEvent:IOErrorEvent, ioEventDetail:String = null):void
         {
            toggleLoaderListeners(loader,false);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.IO_ERROR,Boolean(ioEvent) ? ioEvent.text : ioEventDetail)));
         };
         onSecurityError = function(securityEvent:SecurityErrorEvent, securityEventDetail:String = null):void
         {
            toggleLoaderListeners(loader,false);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.SECURITY_ERROR,Boolean(securityEvent) ? securityEvent.text : securityEventDetail)));
         };
         updateLoadTrait(loadTrait,LoadState.LOADING);
         urlResource = loadTrait.resource as URLResource;
         urlReq = new URLRequest(urlResource.url.toString());
         loader = this.createURLLoader();
         toggleLoaderListeners(loader,true);
         try
         {
            loader.load(urlReq);
         }
         catch(ioError:IOError)
         {
            onIOError(null,ioError.message);
         }
         catch(securityError:SecurityError)
         {
            onSecurityError(null,securityError.message);
         }
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.UNLOADING);
         updateLoadTrait(loadTrait,LoadState.UNINITIALIZED);
      }
      
      protected function createURLLoader() : URLLoader
      {
         return new URLLoader();
      }
   }
}

