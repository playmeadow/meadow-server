package org.osmf.elements.f4mClasses
{
   import flash.utils.ByteArray;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaType;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.MulticastResource;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamType;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.URL;
   
   [ExcludeClass]
   public class ManifestParser
   {
      
      internal namespace xmlns = "http://ns.adobe.com/f4m/1.0";
      
      public function ManifestParser()
      {
         super();
      }
      
      public function parse(value:String, rootUrl:String = null) : Manifest
      {
         var dvrInfo:XML = null;
         var bitrateMissing:Boolean = false;
         var multicastParameterInvalid:Boolean = false;
         var media:XML = null;
         var data:XML = null;
         var info:XML = null;
         var newMedia:Media = null;
         var manifest:Manifest = new Manifest();
         var isMulticast:Boolean = false;
         var root:XML = new XML(value);
         if(root.id.length() > 0)
         {
            manifest.id = root.id.text();
         }
         if(root.duration.length() > 0)
         {
            manifest.duration = root.duration.text();
         }
         if(root.startTime.length() > 0)
         {
            manifest.startTime = DateUtil.parseW3CDTF(root.startTime.text());
         }
         if(root.mimeType.length() > 0)
         {
            manifest.mimeType = root.mimeType.text();
         }
         if(root.streamType.length() > 0)
         {
            manifest.streamType = root.streamType.text();
         }
         if(root.deliveryType.length() > 0)
         {
            manifest.deliveryType = root.deliveryType.text();
         }
         if(root.baseURL.length() > 0)
         {
            manifest.baseURL = root.baseURL.text();
         }
         if(root.urlIncludesFMSApplicationInstance.length() > 0)
         {
            manifest.urlIncludesFMSApplicationInstance = root.urlIncludesFMSApplicationInstance.text() == "true";
         }
         var baseUrl:String = manifest.baseURL != null ? manifest.baseURL : rootUrl;
         var _loc14_:int = 0;
         var _loc15_:* = root.dvrInfo;
         for each(dvrInfo in _loc15_)
         {
            this.parseDVRInfo(dvrInfo,baseUrl,manifest);
         }
         bitrateMissing = false;
         multicastParameterInvalid = false;
         for each(media in root.media)
         {
            newMedia = this.parseMedia(media,baseUrl);
            if(newMedia.multicastGroupspec != null && newMedia.multicastGroupspec.length > 0 && (newMedia.multicastStreamName == null || newMedia.multicastStreamName.length <= 0) || newMedia.multicastStreamName != null && newMedia.multicastStreamName.length > 0 && (newMedia.multicastGroupspec == null || newMedia.multicastGroupspec.length <= 0))
            {
               multicastParameterInvalid = true;
            }
            if(newMedia.multicastGroupspec != null && newMedia.multicastGroupspec.length > 0)
            {
               isMulticast = true;
            }
            manifest.media.push(newMedia);
            bitrateMissing ||= isNaN(newMedia.bitrate);
         }
         if(multicastParameterInvalid)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.MULTICAST_PARAMETER_INVALID));
         }
         if(manifest.media.length > 1 && isMulticast)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.MULTICAST_NOT_SUPPORT_MBR));
         }
         if(isMulticast)
         {
            manifest.streamType = StreamType.LIVE;
         }
         if(manifest.media.length > 1 && bitrateMissing)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_BITRATE_MISSING));
         }
         for each(data in root.drmAdditionalHeader)
         {
            this.parseDRMAdditionalHeader(data,manifest.media,baseUrl,manifest);
         }
         for each(info in root.bootstrapInfo)
         {
            this.parseBootstrapInfo(info,manifest.media,baseUrl,manifest);
         }
         this.generateRTMPBaseURL(manifest);
         return manifest;
      }
      
      private function parseMedia(value:XML, baseUrl:String) : Media
      {
         var decoder:Base64Decoder = null;
         var data:ByteArray = null;
         var header:String = null;
         var metaInfo:Object = null;
         var media:Media = new Media();
         if(value.attribute("url").length() > 0)
         {
            media.url = value.@url;
            if(value.attribute("bitrate").length() > 0)
            {
               media.bitrate = value.@bitrate;
            }
            if(value.attribute("drmAdditionalHeaderId").length() > 0)
            {
               media.drmAdditionalHeader.id = value.@drmAdditionalHeaderId;
            }
            if(value.attribute("bootstrapInfoId").length() > 0)
            {
               media.bootstrapInfo = new BootstrapInfo();
               media.bootstrapInfo.id = value.@bootstrapInfoId;
            }
            if(value.attribute("height").length() > 0)
            {
               media.height = value.@height;
            }
            if(value.attribute("width").length() > 0)
            {
               media.width = value.@width;
            }
            if(value.attribute("groupspec").length() > 0)
            {
               media.multicastGroupspec = value.@groupspec;
            }
            if(value.attribute("multicastStreamName").length() > 0)
            {
               media.multicastStreamName = value.@multicastStreamName;
            }
            if(value.moov.length() > 0)
            {
               decoder = new Base64Decoder();
               decoder.decode(value.moov.text());
               media.moov = decoder.drain();
            }
            if(value.metadata.length() > 0)
            {
               decoder = new Base64Decoder();
               decoder.decode(value.metadata.text());
               data = decoder.drain();
               data.position = 0;
               data.objectEncoding = 0;
               try
               {
                  header = data.readObject() as String;
                  metaInfo = data.readObject();
                  media.metadata = metaInfo;
               }
               catch(e:Error)
               {
               }
            }
            if(value.xmpMetadata.length() > 0)
            {
               decoder = new Base64Decoder();
               decoder.decode(value.xmpMetadata.text());
               media.xmp = decoder.drain();
            }
            return media;
         }
         throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));
      }
      
      private function parseDVRInfo(value:XML, baseUrl:String, manifest:Manifest) : void
      {
         var url:String = null;
         var v:Number = NaN;
         var s:String = null;
         var dvrInfo:DVRInfo = new DVRInfo();
         if(value.attribute("id").length() > 0)
         {
            dvrInfo.id = value.@id;
         }
         if(value.attribute("url").length() > 0)
         {
            url = value.@url;
            if(!this.isAbsoluteURL(url))
            {
               url = baseUrl + "/" + url;
            }
            dvrInfo.url = url;
         }
         if(value.attribute("beginOffset").length() > 0)
         {
            dvrInfo.beginOffset = Math.max(0,parseInt(value.@beginOffset));
         }
         if(value.attribute("endOffset").length() > 0)
         {
            v = new Number(value.@endOffset);
            if(v > 0 && v < 1)
            {
               dvrInfo.endOffset = 1;
            }
            else
            {
               dvrInfo.endOffset = Math.max(0,v);
            }
         }
         if(value.attribute("offline").length() > 0)
         {
            s = value.@offline;
            dvrInfo.offline = s.toLowerCase() == "true";
         }
         manifest.dvrInfo = dvrInfo;
      }
      
      private function parseDRMAdditionalHeader(value:XML, allMedia:Vector.<Media>, baseUrl:String, manifest:Manifest) : void
      {
         var media:Media = null;
         var metadata:String = null;
         var decoder:Base64Decoder = null;
         var url:String = null;
         var drmAdditionalHeader:DRMAdditionalHeader = new DRMAdditionalHeader();
         if(value.attribute("id").length() > 0)
         {
            drmAdditionalHeader.id = value.@id;
         }
         if(value.attribute("url").length() > 0)
         {
            url = value.@url;
            if(!this.isAbsoluteURL(url))
            {
               url = baseUrl + "/" + url;
            }
            drmAdditionalHeader.url = url;
         }
         else
         {
            metadata = value.text();
            decoder = new Base64Decoder();
            decoder.decode(metadata);
            drmAdditionalHeader.data = decoder.drain();
         }
         manifest.drmAdditionalHeaders.push(drmAdditionalHeader);
         for each(media in allMedia)
         {
            if(media.drmAdditionalHeader.id == drmAdditionalHeader.id)
            {
               media.drmAdditionalHeader = drmAdditionalHeader;
            }
         }
      }
      
      private function parseBootstrapInfo(value:XML, allMedia:Vector.<Media>, baseUrl:String, manifest:Manifest) : void
      {
         var media:Media = null;
         var metadata:String = null;
         var decoder:Base64Decoder = null;
         var url:String = null;
         var bootstrapInfo:BootstrapInfo = new BootstrapInfo();
         if(value.attribute("profile").length() > 0)
         {
            bootstrapInfo.profile = value.@profile;
            if(value.attribute("id").length() > 0)
            {
               bootstrapInfo.id = value.@id;
            }
            if(value.attribute("url").length() > 0)
            {
               url = value.@url;
               if(!this.isAbsoluteURL(url) && baseUrl != null)
               {
                  url = baseUrl + "/" + url;
               }
               bootstrapInfo.url = url;
            }
            else
            {
               metadata = value.text();
               decoder = new Base64Decoder();
               decoder.decode(metadata);
               bootstrapInfo.data = decoder.drain();
            }
            for each(media in allMedia)
            {
               if(media.bootstrapInfo == null)
               {
                  media.bootstrapInfo = bootstrapInfo;
               }
               else if(media.bootstrapInfo.id == bootstrapInfo.id)
               {
                  media.bootstrapInfo = bootstrapInfo;
               }
            }
            return;
         }
         throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_PROFILE_MISSING));
      }
      
      private function generateRTMPBaseURL(manifest:Manifest) : void
      {
         var media:Media = null;
         if(manifest.baseURL == null)
         {
            for each(media in manifest.media)
            {
               if(NetStreamUtils.isRTMPStream(media.url))
               {
                  manifest.baseURL = media.url;
                  break;
               }
            }
         }
      }
      
      public function createResource(value:Manifest, manifestResource:URLResource) : MediaResourceBase
      {
         var resource:StreamingURLResource = null;
         var media:Media = null;
         var serverBaseURLs:Vector.<String> = null;
         var url:String = null;
         var bootstrapInfoURLString:String = null;
         var baseURLString:String = null;
         var baseURL:String = null;
         var dynResource:DynamicStreamingResource = null;
         var streamItems:Vector.<DynamicStreamingItem> = null;
         var stream:String = null;
         var item:DynamicStreamingItem = null;
         var drmMetadata:Metadata = null;
         var httpMetadata:Metadata = null;
         var manifestURL:URL = new URL(manifestResource.url);
         var cleanedPath:String = "/" + manifestURL.path;
         cleanedPath = cleanedPath.substr(0,cleanedPath.lastIndexOf("/"));
         var manifestFolder:String = manifestURL.protocol + "://" + manifestURL.host + (manifestURL.port != "" ? ":" + manifestURL.port : "") + cleanedPath;
         if(value.media.length == 1)
         {
            media = value.media[0] as Media;
            url = media.url;
            baseURLString = null;
            if(this.isAbsoluteURL(url))
            {
               baseURLString = media.url.substr(0,media.url.lastIndexOf("/"));
            }
            else if(value.baseURL != null)
            {
               baseURLString = value.baseURL;
            }
            else
            {
               baseURLString = manifestFolder;
            }
            if(media.multicastGroupspec != null && media.multicastGroupspec.length > 0 && media.multicastStreamName != null && media.multicastStreamName.length > 0)
            {
               if(this.isAbsoluteURL(url))
               {
                  resource = new MulticastResource(url,value.streamType);
               }
               else if(value.baseURL != null)
               {
                  resource = new MulticastResource(value.baseURL + "/" + url,this.streamType(value));
               }
               else
               {
                  resource = new MulticastResource(manifestFolder + "/" + url,this.streamType(value));
               }
               MulticastResource(resource).groupspec = media.multicastGroupspec;
               MulticastResource(resource).streamName = media.multicastStreamName;
            }
            else if(this.isAbsoluteURL(url))
            {
               resource = new StreamingURLResource(url,value.streamType);
            }
            else if(value.baseURL != null)
            {
               resource = new StreamingURLResource(value.baseURL + "/" + url,this.streamType(value));
            }
            else
            {
               resource = new StreamingURLResource(manifestFolder + "/" + url,this.streamType(value));
            }
            resource.urlIncludesFMSApplicationInstance = value.urlIncludesFMSApplicationInstance;
            if(media.bootstrapInfo != null)
            {
               serverBaseURLs = new Vector.<String>();
               serverBaseURLs.push(baseURLString);
               bootstrapInfoURLString = media.bootstrapInfo.url;
               if(media.bootstrapInfo.url != null && this.isAbsoluteURL(media.bootstrapInfo.url) == false)
               {
                  bootstrapInfoURLString = manifestFolder + "/" + bootstrapInfoURLString;
                  media.bootstrapInfo.url = bootstrapInfoURLString;
               }
               httpMetadata = new Metadata();
               httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY,media.bootstrapInfo);
               if(serverBaseURLs.length > 0)
               {
                  httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY,serverBaseURLs);
               }
            }
            if(media.metadata != null)
            {
               if(httpMetadata == null)
               {
                  httpMetadata = new Metadata();
               }
               httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY,media.metadata);
            }
            if(media.xmp != null)
            {
               if(httpMetadata == null)
               {
                  httpMetadata = new Metadata();
               }
               httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY,media.xmp);
            }
            if(media.drmAdditionalHeader != null)
            {
               drmMetadata = new Metadata();
               if(Media(value.media[0]).drmAdditionalHeader != null && Media(value.media[0]).drmAdditionalHeader.data != null)
               {
                  drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY,Media(value.media[0]).drmAdditionalHeader.data);
                  resource.drmContentData = this.extractDRMMetadata(Media(value.media[0]).drmAdditionalHeader.data);
               }
            }
            if(httpMetadata != null)
            {
               resource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA,httpMetadata);
            }
            if(drmMetadata != null)
            {
               resource.addMetadataValue(MetadataNamespaces.DRM_METADATA,drmMetadata);
            }
         }
         else if(value.media.length > 1)
         {
            baseURL = value.baseURL != null ? value.baseURL : manifestFolder;
            serverBaseURLs = new Vector.<String>();
            serverBaseURLs.push(baseURL);
            dynResource = new DynamicStreamingResource(baseURL,this.streamType(value));
            dynResource.urlIncludesFMSApplicationInstance = value.urlIncludesFMSApplicationInstance;
            streamItems = new Vector.<DynamicStreamingItem>();
            if(NetStreamUtils.isRTMPStream(baseURL) == false)
            {
               httpMetadata = new Metadata();
               dynResource.addMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA,httpMetadata);
               httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_SERVER_BASE_URLS_KEY,serverBaseURLs);
            }
            for each(media in value.media)
            {
               if(this.isAbsoluteURL(media.url))
               {
                  stream = NetStreamUtils.getStreamNameFromURL(media.url);
               }
               else
               {
                  stream = media.url;
               }
               item = new DynamicStreamingItem(stream,media.bitrate,media.width,media.height);
               streamItems.push(item);
               if(media.drmAdditionalHeader != null)
               {
                  if(dynResource.getMetadataValue(MetadataNamespaces.DRM_METADATA) == null)
                  {
                     drmMetadata = new Metadata();
                     dynResource.addMetadataValue(MetadataNamespaces.DRM_METADATA,drmMetadata);
                  }
                  if(media.drmAdditionalHeader != null && media.drmAdditionalHeader.data != null)
                  {
                     drmMetadata.addValue(item.streamName,this.extractDRMMetadata(media.drmAdditionalHeader.data));
                     drmMetadata.addValue(MetadataNamespaces.DRM_ADDITIONAL_HEADER_KEY + item.streamName,media.drmAdditionalHeader.data);
                  }
               }
               if(media.bootstrapInfo != null)
               {
                  bootstrapInfoURLString = Boolean(media.bootstrapInfo.url) ? media.bootstrapInfo.url : null;
                  if(media.bootstrapInfo.url != null && this.isAbsoluteURL(media.bootstrapInfo.url) == false)
                  {
                     bootstrapInfoURLString = manifestFolder + "/" + bootstrapInfoURLString;
                     media.bootstrapInfo.url = bootstrapInfoURLString;
                  }
                  httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_BOOTSTRAP_KEY + item.streamName,media.bootstrapInfo);
               }
               if(media.metadata != null)
               {
                  httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_STREAM_METADATA_KEY + item.streamName,media.metadata);
               }
               if(media.xmp != null)
               {
                  httpMetadata.addValue(MetadataNamespaces.HTTP_STREAMING_XMP_METADATA_KEY + item.streamName,media.xmp);
               }
            }
            dynResource.streamItems = streamItems;
            resource = dynResource;
         }
         else if(value.baseURL == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.F4M_PARSE_MEDIA_URL_MISSING));
         }
         if(value.mimeType != null)
         {
            resource.mediaType = MediaType.VIDEO;
            resource.mimeType = value.mimeType;
         }
         var streamingManifestResource:StreamingURLResource = manifestResource as StreamingURLResource;
         if(streamingManifestResource != null)
         {
            resource.clipStartTime = streamingManifestResource.clipStartTime;
            resource.clipEndTime = streamingManifestResource.clipEndTime;
         }
         resource.addMetadataValue(MetadataNamespaces.DERIVED_RESOURCE_METADATA,manifestResource);
         this.addDVRInfo(value,resource);
         return resource;
      }
      
      private function isAbsoluteURL(url:String) : Boolean
      {
         var theURL:URL = new URL(url);
         return theURL.absolute;
      }
      
      private function extractDRMMetadata(data:ByteArray) : ByteArray
      {
         var header:Object = null;
         var encryption:Object = null;
         var enc:Object = null;
         var params:Object = null;
         var keyInfo:Object = null;
         var fmrmsMetadata:Object = null;
         var drmMetadata:String = null;
         var decoder:Base64Decoder = null;
         var metadata:ByteArray = null;
         data.position = 0;
         data.objectEncoding = 0;
         try
         {
            header = data.readObject();
            encryption = data.readObject();
            enc = encryption["Encryption"];
            params = enc["Params"];
            keyInfo = params["KeyInfo"];
            fmrmsMetadata = keyInfo["FMRMS_METADATA"];
            drmMetadata = fmrmsMetadata["Metadata"] as String;
            decoder = new Base64Decoder();
            decoder.decode(drmMetadata);
            metadata = decoder.drain();
         }
         catch(e:Error)
         {
            metadata = null;
         }
         return metadata;
      }
      
      private function addDVRInfo(manifest:Manifest, resource:StreamingURLResource) : void
      {
         if(manifest.dvrInfo == null)
         {
            return;
         }
         var metadata:Metadata = new Metadata();
         metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_BEGIN_OFFSET_KEY,manifest.dvrInfo.beginOffset);
         metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_END_OFFSET_KEY,manifest.dvrInfo.endOffset);
         metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_OFFLINE_KEY,manifest.dvrInfo.offline);
         metadata.addValue(MetadataNamespaces.HTTP_STREAMING_DVR_ID_KEY,manifest.dvrInfo.id);
         resource.addMetadataValue(MetadataNamespaces.DVR_METADATA,metadata);
      }
      
      private function streamType(value:Manifest) : String
      {
         return value.streamType == StreamType.LIVE && value.dvrInfo != null ? StreamType.DVR : value.streamType;
      }
   }
}

