package org.osmf.elements.loaderClasses
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.errors.IOError;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.system.ApplicationDomain;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.SecurityDomain;
   import flash.utils.Timer;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.URLResource;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   
   [ExcludeClass]
   public class LoaderUtils
   {
      
      private static const SWF_MIME_TYPE:String = "application/x-shockwave-flash";
      
      public function LoaderUtils()
      {
         super();
      }
      
      public static function createDisplayObjectTrait(loader:Loader, mediaElement:MediaElement) : DisplayObjectTrait
      {
         var displayObject:DisplayObject = null;
         var mediaWidth:Number = 0;
         var mediaHeight:Number = 0;
         var info:LoaderInfo = loader.contentLoaderInfo;
         displayObject = loader;
         displayObject.scrollRect = new Rectangle(0,0,info.width,info.height);
         mediaWidth = info.width;
         mediaHeight = info.height;
         return new DisplayObjectTrait(displayObject,mediaWidth,mediaHeight);
      }
      
      public static function loadLoadTrait(loadTrait:LoadTrait, updateLoadTraitFunction:Function, useCurrentSecurityDomain:Boolean, checkPolicyFile:Boolean, validateLoadedContentFunction:Function = null) : void
      {
         var context:LoaderContext;
         var urlReq:URLRequest;
         var loader:Loader = null;
         var onLoadComplete:Function = null;
         var onIOError:Function = null;
         var onSecurityError:Function = null;
         var toggleLoaderListeners:Function = function(loader:Loader, on:Boolean):void
         {
            if(on)
            {
               loader.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadComplete);
               loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
               loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
            }
            else
            {
               loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,onLoadComplete);
               loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
               loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError);
            }
         };
         onLoadComplete = function(event:Event):void
         {
            var validated:Boolean = false;
            var timer:Timer = null;
            var onTimer:Function = null;
            toggleLoaderListeners(loader,false);
            if(loadTrait.loadState == LoadState.LOADING)
            {
               if(validateLoadedContentFunction != null)
               {
                  validated = Boolean(validateLoadedContentFunction(loader.content));
                  if(validated)
                  {
                     if(Capabilities.isDebugger)
                     {
                        onTimer = function(event:TimerEvent):void
                        {
                           timer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
                           timer = null;
                           loader.unloadAndStop();
                           loader = null;
                           loadLoadTrait(loadTrait,updateLoadTraitFunction,useCurrentSecurityDomain,false,null);
                        };
                        timer = new Timer(250,1);
                        timer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimer);
                        timer.start();
                     }
                     else
                     {
                        loader.unloadAndStop();
                        loader = null;
                        loadLoadTrait(loadTrait,updateLoadTraitFunction,useCurrentSecurityDomain,false,null);
                     }
                  }
                  else
                  {
                     loader.unloadAndStop();
                     loader = null;
                     updateLoadTraitFunction(loadTrait,LoadState.LOAD_ERROR);
                     loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.IO_ERROR)));
                  }
               }
               else
               {
                  updateLoadTraitFunction(loadTrait,LoadState.READY);
               }
            }
         };
         onIOError = function(ioEvent:IOErrorEvent, ioEventDetail:String = null):void
         {
            toggleLoaderListeners(loader,false);
            loader = null;
            updateLoadTraitFunction(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.IO_ERROR,Boolean(ioEvent) ? ioEvent.text : ioEventDetail)));
         };
         onSecurityError = function(securityEvent:SecurityErrorEvent, securityEventDetail:String = null):void
         {
            toggleLoaderListeners(loader,false);
            loader = null;
            updateLoadTraitFunction(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.SECURITY_ERROR,Boolean(securityEvent) ? securityEvent.text : securityEventDetail)));
         };
         var loaderLoadTrait:LoaderLoadTrait = loadTrait as LoaderLoadTrait;
         loader = new Loader();
         loaderLoadTrait.loader = loader;
         updateLoadTraitFunction(loadTrait,LoadState.LOADING);
         context = new LoaderContext();
         urlReq = new URLRequest((loadTrait.resource as URLResource).url.toString());
         context.checkPolicyFile = checkPolicyFile;
         if(useCurrentSecurityDomain && urlReq.url.search(/^file:\//i) == -1)
         {
            context.securityDomain = SecurityDomain.currentDomain;
         }
         if(validateLoadedContentFunction != null)
         {
            context.applicationDomain = new ApplicationDomain();
         }
         toggleLoaderListeners(loader,true);
         try
         {
            loader.load(urlReq,context);
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
      
      public static function unloadLoadTrait(loadTrait:LoadTrait, updateLoadTraitFunction:Function) : void
      {
         var loaderLoadTrait:LoaderLoadTrait = loadTrait as LoaderLoadTrait;
         updateLoadTraitFunction(loadTrait,LoadState.UNLOADING);
         loaderLoadTrait.loader.unloadAndStop();
         updateLoadTraitFunction(loadTrait,LoadState.UNINITIALIZED);
      }
   }
}

