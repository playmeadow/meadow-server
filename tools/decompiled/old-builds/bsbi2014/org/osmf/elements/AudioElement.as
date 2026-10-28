package org.osmf.elements
{
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import org.osmf.elements.audioClasses.AudioAudioTrait;
   import org.osmf.elements.audioClasses.AudioPlayTrait;
   import org.osmf.elements.audioClasses.AudioSeekTrait;
   import org.osmf.elements.audioClasses.AudioTimeTrait;
   import org.osmf.elements.audioClasses.SoundAdapter;
   import org.osmf.elements.audioClasses.SoundLoadTrait;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.DefaultTraitResolver;
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.net.*;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   public class AudioElement extends LoadableElementBase
   {
      
      private var soundAdapter:SoundAdapter;
      
      private var stream:NetStream;
      
      private var defaultTimeTrait:ModifiableTimeTrait;
      
      private var _alternateLoaders:Vector.<LoaderBase>;
      
      public function AudioElement(resource:URLResource = null, loader:LoaderBase = null)
      {
         super(resource,loader);
         if(!(loader == null || loader is NetLoader || loader is SoundLoader))
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
      }
      
      public function get defaultDuration() : Number
      {
         return Boolean(this.defaultTimeTrait) ? this.defaultTimeTrait.duration : NaN;
      }
      
      public function set defaultDuration(value:Number) : void
      {
         if(isNaN(value) || value < 0)
         {
            if(this.defaultTimeTrait != null)
            {
               removeTraitResolver(MediaTraitType.TIME);
               this.defaultTimeTrait = null;
            }
         }
         else
         {
            if(this.defaultTimeTrait == null)
            {
               this.defaultTimeTrait = new ModifiableTimeTrait();
               addTraitResolver(MediaTraitType.TIME,new DefaultTraitResolver(MediaTraitType.TIME,this.defaultTimeTrait));
            }
            this.defaultTimeTrait.duration = value;
         }
      }
      
      override public function set resource(value:MediaResourceBase) : void
      {
         loader = getLoaderForResource(value,this.alternateLoaders);
         super.resource = value;
      }
      
      override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase) : LoadTrait
      {
         return loader is NetLoader ? new NetStreamLoadTrait(loader,resource) : new SoundLoadTrait(loader,resource);
      }
      
      override protected function processReadyState() : void
      {
         var timeTrait:TimeTrait = null;
         var reconnectStreams:Boolean = false;
         var soundLoadTrait:SoundLoadTrait = null;
         var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
         this.soundAdapter = null;
         this.stream = null;
         var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
         if(Boolean(netLoadTrait))
         {
            this.stream = netLoadTrait.netStream;
            this.stream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatusEvent);
            netLoadTrait.connection.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatusEvent,false,0,true);
            reconnectStreams = false;
            if(loader is NetLoader)
            {
               reconnectStreams = (loader as NetLoader).reconnectStreams;
            }
            addTrait(MediaTraitType.PLAY,new NetStreamPlayTrait(this.stream,resource,reconnectStreams,netLoadTrait.connection));
            timeTrait = new NetStreamTimeTrait(this.stream,resource,this.defaultDuration);
            addTrait(MediaTraitType.TIME,timeTrait);
            addTrait(MediaTraitType.SEEK,new NetStreamSeekTrait(timeTrait,loadTrait,this.stream));
            addTrait(MediaTraitType.AUDIO,new NetStreamAudioTrait(this.stream));
            addTrait(MediaTraitType.BUFFER,new NetStreamBufferTrait(this.stream));
         }
         else
         {
            soundLoadTrait = loadTrait as SoundLoadTrait;
            this.soundAdapter = new SoundAdapter(this,soundLoadTrait.sound);
            addTrait(MediaTraitType.PLAY,new AudioPlayTrait(this.soundAdapter));
            timeTrait = new AudioTimeTrait(this.soundAdapter);
            addTrait(MediaTraitType.TIME,timeTrait);
            addTrait(MediaTraitType.SEEK,new AudioSeekTrait(timeTrait,this.soundAdapter));
            addTrait(MediaTraitType.AUDIO,new AudioAudioTrait(this.soundAdapter));
         }
      }
      
      override protected function processUnloadingState() : void
      {
         if(this.stream != null)
         {
            this.stream.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatusEvent);
         }
         var netLoadTrait:NetStreamLoadTrait = getTrait(MediaTraitType.LOAD) as NetStreamLoadTrait;
         if(netLoadTrait != null)
         {
            netLoadTrait.connection.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatusEvent);
         }
         removeTrait(MediaTraitType.PLAY);
         removeTrait(MediaTraitType.SEEK);
         removeTrait(MediaTraitType.TIME);
         removeTrait(MediaTraitType.AUDIO);
         removeTrait(MediaTraitType.BUFFER);
         if(this.soundAdapter != null)
         {
            this.soundAdapter.pause();
         }
         this.soundAdapter = null;
         this.stream = null;
      }
      
      private function onNetStatusEvent(event:NetStatusEvent) : void
      {
         var error:MediaError = null;
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_FAILED:
            case NetStreamCodes.NETSTREAM_FAILED:
               error = new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED,event.info.description);
               break;
            case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
               error = new MediaError(MediaErrorCodes.NETSTREAM_STREAM_NOT_FOUND,event.info.description);
               break;
            case NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID:
               error = new MediaError(MediaErrorCodes.NETSTREAM_FILE_STRUCTURE_INVALID,event.info.description);
               break;
            case NetStreamCodes.NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:
               error = new MediaError(MediaErrorCodes.NETSTREAM_NO_SUPPORTED_TRACK_FOUND,event.info.description);
               break;
            case NetConnectionCodes.CONNECT_IDLE_TIME_OUT:
               error = new MediaError(MediaErrorCodes.NETCONNECTION_TIMEOUT,event.info.description);
         }
         if(error != null)
         {
            dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,error));
         }
      }
      
      private function get alternateLoaders() : Vector.<LoaderBase>
      {
         if(this._alternateLoaders == null)
         {
            this._alternateLoaders = new Vector.<LoaderBase>();
            this._alternateLoaders.push(new SoundLoader());
            this._alternateLoaders.push(new NetLoader());
         }
         return this._alternateLoaders;
      }
   }
}

