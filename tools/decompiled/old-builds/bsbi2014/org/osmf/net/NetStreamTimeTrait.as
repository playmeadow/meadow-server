package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.TimeTrait;
   
   [ExcludeClass]
   public class NetStreamTimeTrait extends TimeTrait
   {
      
      private var durationOffset:Number = 0;
      
      private var _audioDelay:Number = 0;
      
      private var netStream:NetStream;
      
      private var resource:MediaResourceBase;
      
      private var multicast:Boolean = false;
      
      public function NetStreamTimeTrait(netStream:NetStream, resource:MediaResourceBase, defaultDuration:Number = NaN)
      {
         super();
         this.netStream = netStream;
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA,this.onMetaData);
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS,this.onPlayStatus);
         netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,0,true);
         this.resource = resource;
         if(isNaN(defaultDuration) == false)
         {
            setDuration(defaultDuration);
         }
         var streamResource:MulticastResource = resource as MulticastResource;
         if(streamResource != null && streamResource.groupspec != null && streamResource.groupspec.length > 0)
         {
            this.multicast = true;
            setDuration(Number.MAX_VALUE);
         }
      }
      
      override public function get currentTime() : Number
      {
         if(this.multicast)
         {
            return 0;
         }
         if(this.durationOffset == duration - (this.netStream.time - this._audioDelay))
         {
            return this.netStream.time - this._audioDelay + this.durationOffset;
         }
         return this.netStream.time - this._audioDelay;
      }
      
      private function onMetaData(value:Object) : void
      {
         var playArgs:Object = NetStreamUtils.getPlayArgsForResource(this.resource);
         this._audioDelay = value.hasOwnProperty("audiodelay") ? Number(value.audiodelay) : 0;
         var subclipStartTime:Number = Math.max(0,playArgs.start);
         var subclipDuration:Number = Number(playArgs.len);
         if(subclipDuration == NetStreamUtils.PLAY_LEN_ARG_ALL)
         {
            subclipDuration = Number.MAX_VALUE;
         }
         setDuration(Math.min(value.duration - this._audioDelay - subclipStartTime,subclipDuration));
      }
      
      private function onPlayStatus(event:Object) : void
      {
         switch(event.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
               this.signalComplete();
         }
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_STOP:
               if(NetStreamUtils.isStreamingResource(this.resource) == false)
               {
                  this.signalComplete();
               }
               break;
            case NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY:
               this.signalComplete();
         }
      }
      
      override protected function signalComplete() : void
      {
         if(this.netStream.time - this._audioDelay != duration)
         {
            this.durationOffset = duration - (this.netStream.time - this._audioDelay);
         }
         super.signalComplete();
      }
      
      internal function get audioDelay() : Number
      {
         return this._audioDelay;
      }
   }
}

