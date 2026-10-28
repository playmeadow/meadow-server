package org.osmf.net
{
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.utils.URL;
   
   [ExcludeClass]
   public class NetStreamUtils
   {
      
      public static const PLAY_START_ARG_ANY:int = -2;
      
      public static const PLAY_START_ARG_LIVE:int = -1;
      
      public static const PLAY_START_ARG_RECORDED:int = 0;
      
      public static const PLAY_LEN_ARG_ALL:int = -1;
      
      public function NetStreamUtils()
      {
         super();
      }
      
      public static function getStreamNameFromURL(url:String, urlIncludesFMSApplicationInstance:Boolean = false) : String
      {
         var fmsURL:FMSURL = null;
         var streamName:String = "";
         if(url != null)
         {
            if(isRTMPStream(url))
            {
               fmsURL = new FMSURL(url,urlIncludesFMSApplicationInstance);
               streamName = fmsURL.streamName;
               if(fmsURL.query != null && fmsURL.query != "")
               {
                  streamName += "?" + fmsURL.query;
               }
            }
            else
            {
               streamName = url;
            }
         }
         return streamName;
      }
      
      public static function isStreamingResource(resource:MediaResourceBase) : Boolean
      {
         var urlResource:URLResource = null;
         var result:Boolean = false;
         if(resource != null)
         {
            urlResource = resource as URLResource;
            if(urlResource != null)
            {
               result = NetStreamUtils.isRTMPStream(urlResource.url);
               if(result == false)
               {
                  result = urlResource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) != null;
               }
            }
         }
         return result;
      }
      
      public static function isRTMPStream(url:String) : Boolean
      {
         var theURL:URL = null;
         var protocol:String = null;
         var result:Boolean = false;
         if(url != null)
         {
            theURL = new URL(url);
            protocol = theURL.protocol;
            if(protocol != null && protocol.length > 0)
            {
               result = protocol.search(/^rtmp$|rtmp[tse]$|rtmpte$/i) != -1;
            }
         }
         return result;
      }
      
      public static function getStreamType(resource:MediaResourceBase) : String
      {
         var streamType:String = StreamType.RECORDED;
         var streamingURLResource:StreamingURLResource = resource as StreamingURLResource;
         if(streamingURLResource != null)
         {
            streamType = streamingURLResource.streamType;
         }
         return streamType;
      }
      
      public static function getPlayArgsForResource(resource:MediaResourceBase) : Object
      {
         var streamingResource:StreamingURLResource = null;
         var startArg:Number = PLAY_START_ARG_ANY;
         var lenArg:Number = PLAY_LEN_ARG_ALL;
         switch(getStreamType(resource))
         {
            case StreamType.LIVE_OR_RECORDED:
               startArg = PLAY_START_ARG_ANY;
               break;
            case StreamType.LIVE:
               startArg = PLAY_START_ARG_LIVE;
               break;
            case StreamType.RECORDED:
               startArg = PLAY_START_ARG_RECORDED;
         }
         if(startArg != PLAY_START_ARG_LIVE && resource != null)
         {
            streamingResource = resource as StreamingURLResource;
            if(streamingResource != null && isStreamingResource(streamingResource))
            {
               if(!isNaN(streamingResource.clipStartTime))
               {
                  startArg = streamingResource.clipStartTime;
               }
               if(!isNaN(streamingResource.clipEndTime))
               {
                  startArg = Math.max(0,startArg);
                  lenArg = Math.max(0,streamingResource.clipEndTime - startArg);
               }
            }
         }
         return {
            "start":startArg,
            "len":lenArg
         };
      }
   }
}

