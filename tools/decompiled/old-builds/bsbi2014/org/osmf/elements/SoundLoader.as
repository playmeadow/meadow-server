package org.osmf.elements
{
   import flash.errors.IOError;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import org.osmf.elements.audioClasses.SoundLoadTrait;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaType;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.*;
   
   public class SoundLoader extends LoaderBase
   {
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["audio/mpeg"]);
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.AUDIO]);
      
      private static const MIN_BYTES_TO_RECEIVE:int = 16;
      
      private var checkPolicyFile:Boolean;
      
      public function SoundLoader(checkPolicyFile:Boolean = false)
      {
         super();
         this.checkPolicyFile = checkPolicyFile;
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
         {
            return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
         }
         var urlResource:URLResource = resource as URLResource;
         if(urlResource == null || urlResource.url == null || urlResource.url.length <= 0)
         {
            return false;
         }
         var url:URL = new URL(urlResource.url);
         if(url.protocol == "")
         {
            return url.path.search(/\.mp3$|\.m4a$/i) != -1;
         }
         if(url.protocol.search(/file$|http$|https$/i) != -1)
         {
            return url.path == null || url.path.length <= 0 || url.path.indexOf(".") == -1 || url.path.search(/\.mp3$|\.m4a$/i) != -1;
         }
         return false;
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         var urlRequest:URLRequest;
         var context:SoundLoaderContext;
         var soundLoadTrait:SoundLoadTrait = null;
         var sound:Sound = null;
         var onProgress:Function = null;
         var onIOError:Function = null;
         var toggleSoundListeners:Function = function(sound:Sound, on:Boolean):void
         {
            if(on)
            {
               sound.addEventListener(ProgressEvent.PROGRESS,onProgress);
               sound.addEventListener(IOErrorEvent.IO_ERROR,onIOError);
            }
            else
            {
               sound.removeEventListener(ProgressEvent.PROGRESS,onProgress);
               sound.removeEventListener(IOErrorEvent.IO_ERROR,onIOError);
            }
         };
         onProgress = function(event:ProgressEvent):void
         {
            if(event.bytesTotal >= MIN_BYTES_TO_RECEIVE && soundLoadTrait.loadState == LoadState.LOADING)
            {
               toggleSoundListeners(sound,false);
               soundLoadTrait.sound = sound;
               updateLoadTrait(soundLoadTrait,LoadState.READY);
            }
         };
         onIOError = function(ioEvent:IOErrorEvent, ioEventDetail:String = null):void
         {
            toggleSoundListeners(sound,false);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.IO_ERROR,Boolean(ioEvent) ? ioEvent.text : ioEventDetail)));
         };
         var handleSecurityError:Function = function(securityErrorDetail:String):void
         {
            toggleSoundListeners(sound,false);
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.SECURITY_ERROR,securityErrorDetail)));
         };
         soundLoadTrait = loadTrait as SoundLoadTrait;
         updateLoadTrait(soundLoadTrait,LoadState.LOADING);
         sound = new Sound();
         toggleSoundListeners(sound,true);
         urlRequest = new URLRequest((soundLoadTrait.resource as URLResource).url.toString());
         context = new SoundLoaderContext(1000,this.checkPolicyFile);
         try
         {
            sound.load(urlRequest,context);
         }
         catch(ioError:IOError)
         {
            onIOError(null,ioError.message);
         }
         catch(securityError:SecurityError)
         {
            handleSecurityError(securityError.message);
         }
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         var soundLoadTrait:SoundLoadTrait = loadTrait as SoundLoadTrait;
         updateLoadTrait(soundLoadTrait,LoadState.UNLOADING);
         try
         {
            if(soundLoadTrait.sound != null)
            {
               soundLoadTrait.sound.close();
            }
         }
         catch(error:IOError)
         {
         }
         updateLoadTrait(soundLoadTrait,LoadState.UNINITIALIZED);
      }
   }
}

