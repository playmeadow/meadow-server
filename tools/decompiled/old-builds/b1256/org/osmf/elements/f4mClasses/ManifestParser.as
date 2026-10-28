package org.osmf.elements.f4mClasses
{
   import flash.utils.ByteArray;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.MulticastResource;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamingURLResource;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.URL;
   
   public class ManifestParser
   {
      
      private namespace xmlns = "http://ns.adobe.com/f4m/1.0";
      
      public function ManifestParser()
      {
         super();
      }
      
      public function parse(param1:String, param2:String = null) : Manifest
      {
         var _loc5_:Media = null;
         var _loc11_:Manifest = new Manifest();
         var _loc4_:Boolean = false;
         var _loc8_:XML = new XML(param1);
         if(_loc8_.id.length() > 0)
         {
            _loc11_.id = _loc8_.id.text();
         }
         if(_loc8_.duration.length() > 0)
         {
            _loc11_.duration = _loc8_.duration.text();
         }
         if(_loc8_.startTime.length() > 0)
         {
            _loc11_.startTime = DateUtil.parseW3CDTF(_loc8_.startTime.text());
         }
         if(_loc8_.mimeType.length() > 0)
         {
            _loc11_.mimeType = _loc8_.mimeType.text();
         }
         if(_loc8_.streamType.length() > 0)
         {
            _loc11_.streamType = _loc8_.streamType.text();
         }
         if(_loc8_.deliveryType.length() > 0)
         {
            _loc11_.deliveryType = _loc8_.deliveryType.text();
         }
         if(_loc8_.baseURL.length() > 0)
         {
            _loc11_.baseURL = _loc8_.baseURL.text();
         }
         if(_loc8_.urlIncludesFMSApplicationInstance.length() > 0)
         {
            _loc11_.urlIncludesFMSApplicationInstance = _loc8_.urlIncludesFMSApplicationInstance.text() == "true";
         }
         var _loc3_:String = _loc11_.baseURL != null ? _loc11_.baseURL : param2;
         var _loc15_:int = 0;
         var _loc14_:XMLList = _loc8_.dvrInfo;
         for each(var _loc9_:XML in _loc14_)
         {
            parseDVRInfo(_loc9_,_loc3_,_loc11_);
         }
         var _loc7_:Boolean = false;
         var _loc6_:Boolean = false;
         for each(var _loc12_:XML in _loc8_.media)
         {
            _loc5_ = parseMedia(_loc12_,_loc3_);
            if(_loc5_.multicastGroupspec != null && _loc5_.multicastGroupspec.length > 0 && (_loc5_.multicastStreamName == null || _loc5_.multicastStreamName.length <= 0) || _loc5_.multicastStreamName != null && _loc5_.multicastStreamName.length > 0 && (_loc5_.multicastGroupspec == null || _loc5_.multicastGroupspec.length <= 0))
            {
               _loc6_ = true;
            }
            if(_loc5_.multicastGroupspec != null && _loc5_.multicastGroupspec.length > 0)
            {
               _loc4_ = true;
            }
            _loc11_.media.push(_loc5_);
            if(!_loc7_)
            {
               _loc7_ = isNaN(_loc5_.bitrate);
            }
         }
         if(_loc6_)
         {
            throw new ArgumentError(OSMFStrings.getString("multicastParameterInvalid"));
         }
         if(_loc11_.media.length > 1 && _loc4_)
         {
            throw new ArgumentError(OSMFStrings.getString("multicastNotSupportMBR"));
         }
         if(_loc4_)
         {
            _loc11_.streamType = "live";
         }
         if(_loc11_.media.length > 1 && _loc7_)
         {
            throw new ArgumentError(OSMFStrings.getString("f4mBitrateMissing"));
         }
         for each(var _loc10_:XML in _loc8_.drmAdditionalHeader)
         {
            parseDRMAdditionalHeader(_loc10_,_loc11_.media,_loc3_,_loc11_);
         }
         for each(var _loc13_:XML in _loc8_.bootstrapInfo)
         {
            parseBootstrapInfo(_loc13_,_loc11_.media,_loc3_,_loc11_);
         }
         generateRTMPBaseURL(_loc11_);
         return _loc11_;
      }
      
      private function parseMedia(param1:XML, param2:String) : Media
      {
         var _loc7_:Base64Decoder = null;
         var _loc4_:ByteArray = null;
         var _loc6_:String = null;
         var _loc3_:Object = null;
         var _loc5_:Media = new Media();
         if(param1.attribute("url").length() > 0)
         {
            _loc5_.url = param1.@url;
            if(param1.attribute("bitrate").length() > 0)
            {
               _loc5_.bitrate = param1.@bitrate;
            }
            if(param1.attribute("drmAdditionalHeaderId").length() > 0)
            {
               _loc5_.drmAdditionalHeader.id = param1.@drmAdditionalHeaderId;
            }
            if(param1.attribute("bootstrapInfoId").length() > 0)
            {
               _loc5_.bootstrapInfo = new BootstrapInfo();
               _loc5_.bootstrapInfo.id = param1.@bootstrapInfoId;
            }
            if(param1.attribute("height").length() > 0)
            {
               _loc5_.height = param1.@height;
            }
            if(param1.attribute("width").length() > 0)
            {
               _loc5_.width = param1.@width;
            }
            if(param1.attribute("groupspec").length() > 0)
            {
               _loc5_.multicastGroupspec = param1.@groupspec;
            }
            if(param1.attribute("multicastStreamName").length() > 0)
            {
               _loc5_.multicastStreamName = param1.@multicastStreamName;
            }
            if(param1.moov.length() > 0)
            {
               _loc7_ = new Base64Decoder();
               _loc7_.decode(param1.moov.text());
               _loc5_.moov = _loc7_.drain();
            }
            if(param1.metadata.length() > 0)
            {
               _loc7_ = new Base64Decoder();
               _loc7_.decode(param1.metadata.text());
               _loc4_ = _loc7_.drain();
               _loc4_.position = 0;
               _loc4_.objectEncoding = 0;
               try
               {
                  _loc6_ = _loc4_.readObject() as String;
                  _loc3_ = _loc4_.readObject();
                  _loc5_.metadata = _loc3_;
               }
               catch(e:Error)
               {
               }
            }
            if(param1.xmpMetadata.length() > 0)
            {
               _loc7_ = new Base64Decoder();
               _loc7_.decode(param1.xmpMetadata.text());
               _loc5_.xmp = _loc7_.drain();
            }
            return _loc5_;
         }
         throw new ArgumentError(OSMFStrings.getString("f4mMediaURLMissing"));
      }
      
      private function parseDVRInfo(param1:XML, param2:String, param3:Manifest) : void
      {
         var _loc7_:String = null;
         var _loc4_:Number = NaN;
         var _loc5_:String = null;
         var _loc6_:DVRInfo = new DVRInfo();
         if(param1.attribute("id").length() > 0)
         {
            _loc6_.id = param1.@id;
         }
         if(param1.attribute("url").length() > 0)
         {
            _loc7_ = param1.@url;
            if(!isAbsoluteURL(_loc7_))
            {
               _loc7_ = param2 + "/" + _loc7_;
            }
            _loc6_.url = _loc7_;
         }
         if(param1.attribute("beginOffset").length() > 0)
         {
            _loc6_.beginOffset = Math.max(0,parseInt(param1.@beginOffset));
         }
         if(param1.attribute("endOffset").length() > 0)
         {
            _loc4_ = new Number(param1.@endOffset);
            if(_loc4_ > 0 && _loc4_ < 1)
            {
               _loc6_.endOffset = 1;
            }
            else
            {
               _loc6_.endOffset = Math.max(0,_loc4_);
            }
         }
         if(param1.attribute("offline").length() > 0)
         {
            _loc5_ = param1.@offline;
            _loc6_.offline = _loc5_.toLowerCase() == "true";
         }
         param3.dvrInfo = _loc6_;
      }
      
      private function parseDRMAdditionalHeader(param1:XML, param2:Vector.<Media>, param3:String, param4:Manifest) : void
      {
         var _loc6_:* = null;
         var _loc9_:String = null;
         var _loc7_:Base64Decoder = null;
         var _loc8_:String = null;
         var _loc5_:DRMAdditionalHeader = new DRMAdditionalHeader();
         if(param1.attribute("id").length() > 0)
         {
            _loc5_.id = param1.@id;
         }
         if(param1.attribute("url").length() > 0)
         {
            _loc8_ = param1.@url;
            if(!isAbsoluteURL(_loc8_))
            {
               _loc8_ = param3 + "/" + _loc8_;
            }
            _loc5_.url = _loc8_;
         }
         else
         {
            _loc9_ = param1.text();
            _loc7_ = new Base64Decoder();
            _loc7_.decode(_loc9_);
            _loc5_.data = _loc7_.drain();
         }
         param4.drmAdditionalHeaders.push(_loc5_);
         for each(_loc6_ in param2)
         {
            if(_loc6_.drmAdditionalHeader.id == _loc5_.id)
            {
               _loc6_.drmAdditionalHeader = _loc5_;
            }
         }
      }
      
      private function parseBootstrapInfo(param1:XML, param2:Vector.<Media>, param3:String, param4:Manifest) : void
      {
         var _loc6_:* = null;
         var _loc9_:String = null;
         var _loc7_:Base64Decoder = null;
         var _loc8_:String = null;
         var _loc5_:BootstrapInfo = new BootstrapInfo();
         if(param1.attribute("profile").length() > 0)
         {
            _loc5_.profile = param1.@profile;
            if(param1.attribute("id").length() > 0)
            {
               _loc5_.id = param1.@id;
            }
            if(param1.attribute("url").length() > 0)
            {
               _loc8_ = param1.@url;
               if(!isAbsoluteURL(_loc8_) && param3 != null)
               {
                  _loc8_ = param3 + "/" + _loc8_;
               }
               _loc5_.url = _loc8_;
            }
            else
            {
               _loc9_ = param1.text();
               _loc7_ = new Base64Decoder();
               _loc7_.decode(_loc9_);
               _loc5_.data = _loc7_.drain();
            }
            for each(_loc6_ in param2)
            {
               if(_loc6_.bootstrapInfo == null)
               {
                  _loc6_.bootstrapInfo = _loc5_;
               }
               else if(_loc6_.bootstrapInfo.id == _loc5_.id)
               {
                  _loc6_.bootstrapInfo = _loc5_;
               }
            }
            return;
         }
         throw new ArgumentError(OSMFStrings.getString("f4mProfileMissing"));
      }
      
      private function generateRTMPBaseURL(param1:Manifest) : void
      {
         if(param1.baseURL == null)
         {
            for each(var _loc2_:Media in param1.media)
            {
               if(NetStreamUtils.isRTMPStream(_loc2_.url))
               {
                  param1.baseURL = _loc2_.url;
                  break;
               }
            }
         }
      }
      
      public function createResource(param1:Manifest, param2:URLResource) : MediaResourceBase
      {
         var _loc7_:StreamingURLResource = null;
         var _loc19_:Media = null;
         var _loc13_:* = undefined;
         var _loc9_:String = null;
         var _loc16_:String = null;
         var _loc8_:String = null;
         var _loc6_:String = null;
         var _loc12_:DynamicStreamingResource = null;
         var _loc17_:* = undefined;
         var _loc4_:String = null;
         var _loc15_:DynamicStreamingItem = null;
         var _loc18_:Metadata = null;
         var _loc11_:Metadata = null;
         var _loc14_:URL = new URL(param2.url);
         var _loc10_:String = "/" + _loc14_.path;
         _loc10_ = _loc10_.substr(0,_loc10_.lastIndexOf("/"));
         var _loc3_:String = _loc14_.protocol + "://" + _loc14_.host + (_loc14_.port != "" ? ":" + _loc14_.port : "") + _loc10_;
         if(param1.media.length == 1)
         {
            _loc19_ = param1.media[0] as Media;
            _loc9_ = _loc19_.url;
            _loc8_ = null;
            if(isAbsoluteURL(_loc9_))
            {
               _loc8_ = _loc19_.url.substr(0,_loc19_.url.lastIndexOf("/"));
            }
            else if(param1.baseURL != null)
            {
               _loc8_ = param1.baseURL;
            }
            else
            {
               _loc8_ = _loc3_;
            }
            if(_loc19_.multicastGroupspec != null && _loc19_.multicastGroupspec.length > 0 && _loc19_.multicastStreamName != null && _loc19_.multicastStreamName.length > 0)
            {
               if(isAbsoluteURL(_loc9_))
               {
                  _loc7_ = new MulticastResource(_loc9_,param1.streamType);
               }
               else if(param1.baseURL != null)
               {
                  _loc7_ = new MulticastResource(param1.baseURL + "/" + _loc9_,streamType(param1));
               }
               else
               {
                  _loc7_ = new MulticastResource(_loc3_ + "/" + _loc9_,streamType(param1));
               }
               MulticastResource(_loc7_).groupspec = _loc19_.multicastGroupspec;
               MulticastResource(_loc7_).streamName = _loc19_.multicastStreamName;
            }
            else if(isAbsoluteURL(_loc9_))
            {
               _loc7_ = new StreamingURLResource(_loc9_,param1.streamType);
            }
            else if(param1.baseURL != null)
            {
               _loc7_ = new StreamingURLResource(param1.baseURL + "/" + _loc9_,streamType(param1));
            }
            else
            {
               _loc7_ = new StreamingURLResource(_loc3_ + "/" + _loc9_,streamType(param1));
            }
            _loc7_.urlIncludesFMSApplicationInstance = param1.urlIncludesFMSApplicationInstance;
            if(_loc19_.bootstrapInfo != null)
            {
               _loc13_ = new Vector.<String>();
               _loc13_.push(_loc8_);
               _loc16_ = _loc19_.bootstrapInfo.url;
               if(_loc19_.bootstrapInfo.url != null && isAbsoluteURL(_loc19_.bootstrapInfo.url) == false)
               {
                  _loc16_ = _loc3_ + "/" + _loc16_;
                  _loc19_.bootstrapInfo.url = _loc16_;
               }
               _loc11_ = new Metadata();
               _loc11_.addValue("bootstrap",_loc19_.bootstrapInfo);
               if(_loc13_.length > 0)
               {
                  _loc11_.addValue("serverBaseUrls",_loc13_);
               }
            }
            if(_loc19_.metadata != null)
            {
               if(_loc11_ == null)
               {
                  _loc11_ = new Metadata();
               }
               _loc11_.addValue("streamMetadata",_loc19_.metadata);
            }
            if(_loc19_.xmp != null)
            {
               if(_loc11_ == null)
               {
                  _loc11_ = new Metadata();
               }
               _loc11_.addValue("xmpMetadata",_loc19_.xmp);
            }
            if(_loc19_.drmAdditionalHeader != null)
            {
               _loc18_ = new Metadata();
               if(Media(param1.media[0]).drmAdditionalHeader != null && Media(param1.media[0]).drmAdditionalHeader.data != null)
               {
                  _loc18_.addValue("DRMAdditionalHeader",Media(param1.media[0]).drmAdditionalHeader.data);
                  _loc7_.drmContentData = extractDRMMetadata(Media(param1.media[0]).drmAdditionalHeader.data);
               }
            }
            if(_loc11_ != null)
            {
               _loc7_.addMetadataValue("http://www.osmf.org/httpstreaming/1.0",_loc11_);
            }
            if(_loc18_ != null)
            {
               _loc7_.addMetadataValue("http://www.osmf.org/drm/1.0",_loc18_);
            }
         }
         else if(param1.media.length > 1)
         {
            _loc6_ = param1.baseURL != null ? param1.baseURL : _loc3_;
            _loc13_ = new Vector.<String>();
            _loc13_.push(_loc6_);
            _loc12_ = new DynamicStreamingResource(_loc6_,streamType(param1));
            _loc12_.urlIncludesFMSApplicationInstance = param1.urlIncludesFMSApplicationInstance;
            _loc17_ = new Vector.<DynamicStreamingItem>();
            if(NetStreamUtils.isRTMPStream(_loc6_) == false)
            {
               _loc11_ = new Metadata();
               _loc12_.addMetadataValue("http://www.osmf.org/httpstreaming/1.0",_loc11_);
               _loc11_.addValue("serverBaseUrls",_loc13_);
            }
            for each(_loc19_ in param1.media)
            {
               if(isAbsoluteURL(_loc19_.url))
               {
                  _loc4_ = NetStreamUtils.getStreamNameFromURL(_loc19_.url);
               }
               else
               {
                  _loc4_ = _loc19_.url;
               }
               _loc15_ = new DynamicStreamingItem(_loc4_,_loc19_.bitrate,_loc19_.width,_loc19_.height);
               _loc17_.push(_loc15_);
               if(_loc19_.drmAdditionalHeader != null)
               {
                  if(_loc12_.getMetadataValue("http://www.osmf.org/drm/1.0") == null)
                  {
                     _loc18_ = new Metadata();
                     _loc12_.addMetadataValue("http://www.osmf.org/drm/1.0",_loc18_);
                  }
                  if(_loc19_.drmAdditionalHeader != null && _loc19_.drmAdditionalHeader.data != null)
                  {
                     _loc18_.addValue(_loc15_.streamName,extractDRMMetadata(_loc19_.drmAdditionalHeader.data));
                     _loc18_.addValue("DRMAdditionalHeader" + _loc15_.streamName,_loc19_.drmAdditionalHeader.data);
                  }
               }
               if(_loc19_.bootstrapInfo != null)
               {
                  _loc16_ = _loc19_.bootstrapInfo.url ? _loc19_.bootstrapInfo.url : null;
                  if(_loc19_.bootstrapInfo.url != null && isAbsoluteURL(_loc19_.bootstrapInfo.url) == false)
                  {
                     _loc16_ = _loc3_ + "/" + _loc16_;
                     _loc19_.bootstrapInfo.url = _loc16_;
                  }
                  _loc11_.addValue("bootstrap" + _loc15_.streamName,_loc19_.bootstrapInfo);
               }
               if(_loc19_.metadata != null)
               {
                  _loc11_.addValue("streamMetadata" + _loc15_.streamName,_loc19_.metadata);
               }
               if(_loc19_.xmp != null)
               {
                  _loc11_.addValue("xmpMetadata" + _loc15_.streamName,_loc19_.xmp);
               }
            }
            _loc12_.streamItems = _loc17_;
            _loc7_ = _loc12_;
         }
         else if(param1.baseURL == null)
         {
            throw new ArgumentError(OSMFStrings.getString("f4mMediaURLMissing"));
         }
         if(param1.mimeType != null)
         {
            _loc7_.mediaType = "video";
            _loc7_.mimeType = param1.mimeType;
         }
         var _loc5_:StreamingURLResource = param2 as StreamingURLResource;
         if(_loc5_ != null)
         {
            _loc7_.clipStartTime = _loc5_.clipStartTime;
            _loc7_.clipEndTime = _loc5_.clipEndTime;
         }
         _loc7_.addMetadataValue("http://www.osmf.org/derivedResource/1.0",param2);
         addDVRInfo(param1,_loc7_);
         return _loc7_;
      }
      
      private function isAbsoluteURL(param1:String) : Boolean
      {
         var _loc2_:URL = new URL(param1);
         return _loc2_.absolute;
      }
      
      private function extractDRMMetadata(param1:ByteArray) : ByteArray
      {
         var _loc8_:Object = null;
         var _loc2_:Object = null;
         var _loc9_:Object = null;
         var _loc5_:Object = null;
         var _loc4_:Object = null;
         var _loc3_:Object = null;
         var _loc6_:String = null;
         var _loc7_:Base64Decoder = null;
         var _loc10_:ByteArray = null;
         param1.position = 0;
         param1.objectEncoding = 0;
         try
         {
            _loc8_ = param1.readObject();
            _loc2_ = param1.readObject();
            _loc9_ = _loc2_["Encryption"];
            _loc5_ = _loc9_["Params"];
            _loc4_ = _loc5_["KeyInfo"];
            _loc3_ = _loc4_["FMRMS_METADATA"];
            _loc6_ = _loc3_["Metadata"] as String;
            _loc7_ = new Base64Decoder();
            _loc7_.decode(_loc6_);
            _loc10_ = _loc7_.drain();
         }
         catch(e:Error)
         {
            _loc10_ = null;
         }
         return _loc10_;
      }
      
      private function addDVRInfo(param1:Manifest, param2:StreamingURLResource) : void
      {
         if(param1.dvrInfo == null)
         {
            return;
         }
         var _loc3_:Metadata = new Metadata();
         _loc3_.addValue("beginOffset",param1.dvrInfo.beginOffset);
         _loc3_.addValue("endOffset",param1.dvrInfo.endOffset);
         _loc3_.addValue("dvrOffline",param1.dvrInfo.offline);
         _loc3_.addValue("dvrId",param1.dvrInfo.id);
         param2.addMetadataValue("http://www.osmf.org/dvr/1.0",_loc3_);
      }
      
      private function streamType(param1:Manifest) : String
      {
         return param1.streamType == "live" && param1.dvrInfo != null ? "dvr" : param1.streamType;
      }
   }
}

