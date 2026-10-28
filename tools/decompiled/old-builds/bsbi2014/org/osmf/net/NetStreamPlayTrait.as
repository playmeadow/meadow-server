package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.net.NetStreamPlayTransitions;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.PlayState;
   import org.osmf.traits.PlayTrait;
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   public class NetStreamPlayTrait extends PlayTrait
   {
      
      private static const NETCONNECTION_FAILURE_ERROR_CODE:int = 2154;
      
      private var streamStarted:Boolean;
      
      private var netStream:NetStream;
      
      private var netConnection:NetConnection;
      
      private var urlResource:URLResource;
      
      private var multicastResource:MulticastResource;
      
      private var reconnectStreams:Boolean;
      
      public function NetStreamPlayTrait(netStream:NetStream, resource:MediaResourceBase, reconnectStreams:Boolean, netConnection:NetConnection)
      {
         super();
         if(netStream == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.netStream = netStream;
         this.netConnection = netConnection;
         this.urlResource = resource as URLResource;
         this.multicastResource = resource as MulticastResource;
         this.reconnectStreams = reconnectStreams;
         netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,1,true);
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS,this.onPlayStatus,1);
      }
      
      override protected function playStateChangeStart(newPlayState:String) : void
      {
         var playArgs:Object = null;
         var streamingResource:StreamingURLResource = null;
         var urlIncludesFMSApplicationInstance:Boolean = false;
         var streamName:String = null;
         var startTime:Number = NaN;
         var len:Number = NaN;
         var dsResource:DynamicStreamingResource = null;
         var nso:NetStreamPlayOptions = null;
         if(newPlayState == PlayState.PLAYING)
         {
            if(this.streamStarted)
            {
               if(this.multicastResource != null)
               {
                  this.netStream.play(this.multicastResource.streamName,-1,-1);
               }
               else
               {
                  this.netStream.resume();
               }
            }
            else if(this.urlResource != null)
            {
               streamingResource = this.urlResource as StreamingURLResource;
               urlIncludesFMSApplicationInstance = Boolean(streamingResource) ? streamingResource.urlIncludesFMSApplicationInstance : false;
               streamName = NetStreamUtils.getStreamNameFromURL(this.urlResource.url,urlIncludesFMSApplicationInstance);
               playArgs = NetStreamUtils.getPlayArgsForResource(this.urlResource);
               startTime = Number(playArgs.start);
               len = Number(playArgs.len);
               dsResource = this.urlResource as DynamicStreamingResource;
               if(dsResource != null)
               {
                  nso = new NetStreamPlayOptions();
                  nso.start = startTime;
                  nso.len = len;
                  nso.streamName = dsResource.streamItems[dsResource.initialIndex].streamName;
                  nso.transition = NetStreamPlayTransitions.RESET;
                  this.doPlay2(nso);
               }
               else if(this.reconnectStreams && streamingResource != null && NetStreamUtils.isRTMPStream(streamingResource.url))
               {
                  nso = new NetStreamPlayOptions();
                  nso.start = startTime;
                  nso.len = len;
                  nso.transition = NetStreamPlayTransitions.RESET;
                  nso.streamName = streamName;
                  this.doPlay2(nso);
               }
               else if(this.multicastResource != null && this.multicastResource.groupspec != null && this.multicastResource.groupspec.length > 0)
               {
                  this.doPlay(this.multicastResource.streamName,startTime,len);
               }
               else
               {
                  this.doPlay(streamName,startTime,len);
               }
            }
         }
         else if(this.multicastResource != null)
         {
            this.netStream.play(false);
         }
         else
         {
            this.netStream.pause();
         }
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_FAILED:
            case NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID:
            case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
            case NetStreamCodes.NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:
            case NetStreamCodes.NETSTREAM_FAILED:
               this.netStream.pause();
               this.streamStarted = false;
               break;
            case NetStreamCodes.NETSTREAM_PLAY_STOP:
               if(this.urlResource != null && NetStreamUtils.isStreamingResource(this.urlResource) == false)
               {
                  stop();
               }
         }
      }
      
      private function onPlayStatus(event:Object) : void
      {
         switch(event.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_COMPLETE:
               stop();
         }
      }
      
      private function doPlay(... args) : void
      {
         try
         {
            this.netStream.play.apply(this,args);
            this.streamStarted = true;
         }
         catch(error:Error)
         {
            streamStarted = false;
            stop();
            dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.NETSTREAM_PLAY_FAILED)));
         }
      }
      
      private function doPlay2(nspo:NetStreamPlayOptions) : void
      {
         this.netStream.play2(nspo);
         this.streamStarted = true;
      }
   }
}

