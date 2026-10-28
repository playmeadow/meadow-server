package org.osmf.elements
{
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import org.osmf.elements.f4mClasses.DRMAdditionalHeader;
   import org.osmf.elements.f4mClasses.Manifest;
   import org.osmf.elements.f4mClasses.ManifestParser;
   import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.DefaultMediaFactory;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.net.httpstreaming.HTTPStreamingUtils;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.URL;
   
   public class F4MLoader extends LoaderBase
   {
      
      public static const F4M_MIME_TYPE:String = "application/f4m+xml";
      
      private static const F4M_EXTENSION:String = "f4m";
      
      private var supportedMimeTypes:Vector.<String> = new Vector.<String>();
      
      private var factory:MediaFactory;
      
      private var parser:ManifestParser;
      
      public function F4MLoader(factory:MediaFactory = null)
      {
         super();
         this.supportedMimeTypes.push(F4M_MIME_TYPE);
         if(factory == null)
         {
            factory = new DefaultMediaFactory();
         }
         this.parser = new ManifestParser();
         this.factory = factory;
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var urlResource:URLResource = null;
         var extension:String = null;
         var supported:int = MediaTypeUtil.checkMetadataMatchWithResource(resource,new Vector.<String>(),this.supportedMimeTypes);
         if(supported == MediaTypeUtil.METADATA_MATCH_FOUND)
         {
            return true;
         }
         if(resource is URLResource)
         {
            urlResource = URLResource(resource);
            extension = new URL(urlResource.url).extension;
            return extension == F4M_EXTENSION;
         }
         return false;
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         var manifest:Manifest = null;
         var manifestLoader:URLLoader = null;
         var onError:Function = null;
         var onComplete:Function = null;
         onError = function(event:ErrorEvent):void
         {
            manifestLoader.removeEventListener(Event.COMPLETE,onComplete);
            manifestLoader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
            manifestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(0,event.text)));
         };
         onComplete = function(event:Event):void
         {
            var completionCallback:Function;
            var unfinishedLoads:Number = NaN;
            var item:DRMAdditionalHeader = null;
            manifestLoader.removeEventListener(Event.COMPLETE,onComplete);
            manifestLoader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
            manifestLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
            try
            {
               manifest = parser.parse(event.target.data,getRootUrl(URLResource(loadTrait.resource).url));
            }
            catch(parseError:Error)
            {
               updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
               loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(parseError.errorID,parseError.message)));
            }
            if(manifest != null)
            {
               unfinishedLoads = 0;
               for each(item in manifest.drmAdditionalHeaders)
               {
                  if(item.url != null)
                  {
                     completionCallback = function(success:Boolean):void
                     {
                        if(success)
                        {
                           --unfinishedLoads;
                        }
                        if(unfinishedLoads == 0)
                        {
                           finishLoad();
                        }
                     };
                     unfinishedLoads++;
                     loadAdditionalHeader(item,completionCallback,onError);
                  }
               }
               if(unfinishedLoads == 0)
               {
                  finishLoad();
               }
            }
         };
         var finishLoad:Function = function():void
         {
            var netResource:MediaResourceBase = null;
            var loadedElem:MediaElement = null;
            var s:OSMFStrings = null;
            try
            {
               netResource = parser.createResource(manifest,URLResource(loadTrait.resource));
               loadedElem = factory.createMediaElement(netResource);
               if(loadedElem.hasOwnProperty("defaultDuration") && !isNaN(manifest.duration))
               {
                  loadedElem["defaultDuration"] = manifest.duration;
               }
               LoadFromDocumentLoadTrait(loadTrait).mediaElement = loadedElem;
               updateLoadTrait(loadTrait,LoadState.READY);
            }
            catch(error:Error)
            {
               updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
               loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.F4M_FILE_INVALID,error.message)));
            }
         };
         updateLoadTrait(loadTrait,LoadState.LOADING);
         manifestLoader = new URLLoader(new URLRequest(URLResource(loadTrait.resource).url));
         manifestLoader.addEventListener(Event.COMPLETE,onComplete);
         manifestLoader.addEventListener(IOErrorEvent.IO_ERROR,onError);
         manifestLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.UNINITIALIZED);
      }
      
      private function loadAdditionalHeader(item:DRMAdditionalHeader, completionCallback:Function, onError:Function) : void
      {
         var onDRMLoadComplete:Function = null;
         onDRMLoadComplete = function(event:Event):void
         {
            event.target.removeEventListener(Event.COMPLETE,onDRMLoadComplete);
            event.target.removeEventListener(IOErrorEvent.IO_ERROR,onError);
            event.target.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
            item.data = URLLoader(event.target).data;
            completionCallback(true);
         };
         var drmLoader:URLLoader = new URLLoader();
         drmLoader.dataFormat = URLLoaderDataFormat.BINARY;
         drmLoader.addEventListener(Event.COMPLETE,onDRMLoadComplete);
         drmLoader.addEventListener(IOErrorEvent.IO_ERROR,onError);
         drmLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onError);
         drmLoader.load(new URLRequest(HTTPStreamingUtils.normalizeURL(item.url)));
      }
      
      private function getRootUrl(url:String) : String
      {
         return url.substr(0,url.lastIndexOf("/"));
      }
   }
}

