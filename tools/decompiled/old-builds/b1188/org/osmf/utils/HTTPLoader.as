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
   
   public class HTTPLoader extends LoaderBase
   {
      
      public function HTTPLoader()
      {
         super();
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:URLResource = param1 as URLResource;
         if(_loc2_ == null || _loc2_.url == null || _loc2_.url.length <= 0)
         {
            return false;
         }
         var _loc3_:URL = new URL(_loc2_.url);
         if(_loc3_.protocol.search(/http$|https$/i) == -1 && _loc3_.protocol != "")
         {
            return false;
         }
         return true;
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         var urlResource:URLResource;
         var urlReq:URLRequest;
         var loader:URLLoader = null;
         var onLoadComplete:Function = null;
         var onIOError:Function = null;
         var onSecurityError:Function = null;
         var loadTrait:LoadTrait = param1;
         var toggleLoaderListeners:Function = function(param1:URLLoader, param2:Boolean):void
         {
            if(param2)
            {
               param1.addEventListener(Event.COMPLETE,onLoadComplete);
               param1.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
               param1.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
            }
            else
            {
               param1.removeEventListener(Event.COMPLETE,onLoadComplete);
               param1.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
               param1.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
            }
         };
         onLoadComplete = function(param1:Event):void
         {
            toggleLoaderListeners(loader,false);
            var _loc2_:HTTPLoadTrait = loadTrait as HTTPLoadTrait;
            _loc2_.urlLoader = loader;
            updateLoadTrait(loadTrait,LoadState.READY);
         };
         onIOError = function(param1:IOErrorEvent, param2:String = null):void
         {
            toggleLoaderListeners(loader,false);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.IO_ERROR,param1 ? param1.text : param2)));
         };
         onSecurityError = function(param1:SecurityErrorEvent, param2:String = null):void
         {
            toggleLoaderListeners(loader,false);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.SECURITY_ERROR,param1 ? param1.text : param2)));
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
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         updateLoadTrait(param1,LoadState.UNLOADING);
         updateLoadTrait(param1,LoadState.UNINITIALIZED);
      }
      
      protected function createURLLoader() : URLLoader
      {
         return new URLLoader();
      }
   }
}

