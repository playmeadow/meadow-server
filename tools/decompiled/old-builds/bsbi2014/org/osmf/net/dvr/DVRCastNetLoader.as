package org.osmf.net.dvr
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.net.NetStreamLoadTrait;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamType;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.net.rtmpstreaming.RTMPDynamicStreamingNetLoader;
   import org.osmf.traits.LoadState;
   
   public class DVRCastNetLoader extends RTMPDynamicStreamingNetLoader
   {
      
      public function DVRCastNetLoader(factory:DVRCastNetConnectionFactory = null)
      {
         if(factory == null)
         {
            factory = new DVRCastNetConnectionFactory();
         }
         super(factory);
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var result:Boolean = false;
         var streamingURLResource:StreamingURLResource = null;
         if(super.canHandleResource(resource))
         {
            streamingURLResource = resource as StreamingURLResource;
            if(streamingURLResource != null)
            {
               result = streamingURLResource.streamType == StreamType.DVR && NetStreamUtils.isRTMPStream(streamingURLResource.url);
            }
         }
         return result;
      }
      
      override protected function createNetStream(connection:NetConnection, resource:URLResource) : NetStream
      {
         return new DVRCastNetStream(connection,resource);
      }
      
      override protected function processFinishLoading(loadTrait:NetStreamLoadTrait) : void
      {
         loadTrait.setTrait(new DVRCastDVRTrait(loadTrait.connection,loadTrait.netStream,loadTrait.resource));
         loadTrait.setTrait(new DVRCastTimeTrait(loadTrait.connection,loadTrait.netStream,loadTrait.resource));
         updateLoadTrait(loadTrait,LoadState.READY);
      }
   }
}

