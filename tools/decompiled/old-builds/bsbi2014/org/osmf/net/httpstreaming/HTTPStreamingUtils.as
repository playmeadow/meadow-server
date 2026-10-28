package org.osmf.net.httpstreaming
{
   import flash.utils.ByteArray;
   import org.osmf.elements.f4mClasses.BootstrapInfo;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexInfo;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FStreamInfo;
   
   [ExcludeClass]
   public class HTTPStreamingUtils
   {
      
      public function HTTPStreamingUtils()
      {
         super();
      }
      
      public static function createHTTPStreamingMetadata(abstUrl:String, abstData:ByteArray, serverBaseUrls:Vector.<String>) : Metadata
      {
         var metadata:Metadata = new Metadata();
         var bootstrap:BootstrapInfo = new BootstrapInfo();
         if(abstUrl != null && abstUrl.length > 0)
         {
            bootstrap.url = abstUrl;
         }
         bootstrap.data = abstData;
         metadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY,bootstrap);
         if(serverBaseUrls != null && serverBaseUrls.length > 0)
         {
            metadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY,serverBaseUrls);
         }
         return metadata;
      }
      
      public static function createF4FIndexInfo(resource:URLResource) : HTTPStreamingF4FIndexInfo
      {
         var serverBaseURLs:Vector.<String> = null;
         var streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = null;
         var dvrInfo:DVRInfo = null;
         var indexInfo:HTTPStreamingF4FIndexInfo = null;
         var httpMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
         var dvrMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
         if(httpMetadata != null)
         {
            serverBaseURLs = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY) as Vector.<String>;
            streamInfos = generateStreamInfos(resource);
            dvrInfo = generateDVRInfo(dvrMetadata);
            indexInfo = new HTTPStreamingF4FIndexInfo(serverBaseURLs != null && serverBaseURLs.length > 0 ? serverBaseURLs[0] : null,streamInfos,dvrInfo);
         }
         return indexInfo;
      }
      
      public static function normalizeURL(url:String) : String
      {
         var temp:String = null;
         var i:int = 0;
         var ret:String = "";
         var protocol:String = "";
         if(url.indexOf("http://") == 0)
         {
            protocol = "http://";
         }
         else if(url.indexOf("https://") == 0)
         {
            protocol = "https://";
         }
         if(protocol.length > 0)
         {
            temp = url.substr(protocol.length);
         }
         else
         {
            temp = url;
         }
         var items:Array = temp.split("/");
         var index:int = items.indexOf("..");
         while(index >= 0)
         {
            items.splice(index - 1,2);
            index = items.indexOf("..");
         }
         ret = protocol;
         if(items.length > 0)
         {
            for(i = 0; i < items.length; i++)
            {
               if(i != 0)
               {
                  ret += "/";
               }
               ret += items[i] as String;
            }
         }
         return ret;
      }
      
      private static function generateDVRInfo(metadata:Metadata) : DVRInfo
      {
         if(metadata == null)
         {
            return null;
         }
         var dvrInfo:DVRInfo = new DVRInfo();
         dvrInfo.id = "";
         dvrInfo.beginOffset = NaN;
         dvrInfo.endOffset = NaN;
         dvrInfo.offline = false;
         if(metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_ID_KEY) != null)
         {
            dvrInfo.id = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_ID_KEY) as String;
         }
         if(metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY) != null)
         {
            dvrInfo.beginOffset = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY) as uint;
         }
         if(metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_END_OFFSET_KEY) != null)
         {
            dvrInfo.endOffset = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_END_OFFSET_KEY) as uint;
         }
         if(metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_OFFLINE_KEY) != null)
         {
            dvrInfo.offline = metadata.getValue(MetadataNamespaces.HTTP_STREAMING_DVR_OFFLINE_KEY) as Boolean;
         }
         return dvrInfo;
      }
      
      private static function generateStreamInfos(resource:URLResource) : Vector.<HTTPStreamingF4FStreamInfo>
      {
         var streamMetadata:Object = null;
         var xmpMetadata:ByteArray = null;
         var streamItem:DynamicStreamingItem = null;
         var streamName:String = null;
         var streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = new Vector.<HTTPStreamingF4FStreamInfo>();
         var drmMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DRM_METADATA) as Metadata;
         var httpMetadata:Metadata = resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata;
         var additionalHeader:ByteArray = null;
         var bootstrap:BootstrapInfo = null;
         var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;
         if(dsResource != null)
         {
            for each(streamItem in dsResource.streamItems)
            {
               additionalHeader = null;
               bootstrap = null;
               streamMetadata = null;
               xmpMetadata = null;
               if(drmMetadata != null)
               {
                  additionalHeader = drmMetadata.getValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY + streamItem.streamName) as ByteArray;
               }
               if(httpMetadata != null)
               {
                  bootstrap = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + streamItem.streamName) as BootstrapInfo;
                  streamMetadata = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + streamItem.streamName);
                  xmpMetadata = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + streamItem.streamName) as ByteArray;
               }
               streamInfos.push(new HTTPStreamingF4FStreamInfo(bootstrap,streamItem.streamName,streamItem.bitrate,additionalHeader,streamMetadata,xmpMetadata));
            }
         }
         else
         {
            if(drmMetadata != null)
            {
               additionalHeader = drmMetadata.getValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY) as ByteArray;
            }
            if(httpMetadata != null)
            {
               bootstrap = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY) as BootstrapInfo;
               streamMetadata = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY);
               xmpMetadata = httpMetadata.getValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY) as ByteArray;
            }
            streamName = resource.url;
            streamInfos.push(new HTTPStreamingF4FStreamInfo(bootstrap,streamName,NaN,additionalHeader,streamMetadata,xmpMetadata));
         }
         return streamInfos;
      }
   }
}

