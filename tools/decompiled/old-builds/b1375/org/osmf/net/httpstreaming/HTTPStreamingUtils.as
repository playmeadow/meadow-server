package org.osmf.net.httpstreaming
{
   import flash.utils.ByteArray;
   import org.osmf.elements.f4mClasses.BootstrapInfo;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexInfo;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FStreamInfo;
   
   public class HTTPStreamingUtils
   {
      
      public function HTTPStreamingUtils()
      {
         super();
      }
      
      public static function createHTTPStreamingMetadata(param1:String, param2:ByteArray, param3:Vector.<String>) : Metadata
      {
         var _loc5_:Metadata = new Metadata();
         var _loc4_:BootstrapInfo = new BootstrapInfo();
         if(param1 != null && param1.length > 0)
         {
            _loc4_.url = param1;
         }
         _loc4_.data = param2;
         _loc5_.addValue("bootstrap",_loc4_);
         if(param3 != null && param3.length > 0)
         {
            _loc5_.addValue("serverBaseUrls",param3);
         }
         return _loc5_;
      }
      
      public static function createF4FIndexInfo(param1:URLResource) : HTTPStreamingF4FIndexInfo
      {
         var _loc3_:* = undefined;
         var _loc6_:* = undefined;
         var _loc4_:DVRInfo = null;
         var _loc5_:HTTPStreamingF4FIndexInfo = null;
         var _loc2_:Metadata = param1.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") as Metadata;
         var _loc7_:Metadata = param1.getMetadataValue("http://www.osmf.org/dvr/1.0") as Metadata;
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.getValue("serverBaseUrls") as Vector.<String>;
            _loc6_ = generateStreamInfos(param1);
            _loc4_ = generateDVRInfo(_loc7_);
            _loc5_ = new HTTPStreamingF4FIndexInfo(_loc3_ != null && _loc3_.length > 0 ? _loc3_[0] : null,_loc6_,_loc4_);
         }
         return _loc5_;
      }
      
      public static function normalizeURL(param1:String) : String
      {
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc2_:String = "";
         var _loc4_:String = "";
         if(param1.indexOf("http://") == 0)
         {
            _loc4_ = "http://";
         }
         else if(param1.indexOf("https://") == 0)
         {
            _loc4_ = "https://";
         }
         if(_loc4_.length > 0)
         {
            _loc6_ = param1.substr(_loc4_.length);
         }
         else
         {
            _loc6_ = param1;
         }
         var _loc5_:Array = _loc6_.split("/");
         var _loc3_:int = _loc5_.indexOf("..");
         while(_loc3_ >= 0)
         {
            _loc5_.splice(_loc3_ - 1,2);
            _loc3_ = _loc5_.indexOf("..");
         }
         _loc2_ = _loc4_;
         if(_loc5_.length > 0)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               if(_loc7_ != 0)
               {
                  _loc2_ += "/";
               }
               _loc2_ += _loc5_[_loc7_] as String;
               _loc7_++;
            }
         }
         return _loc2_;
      }
      
      private static function generateDVRInfo(param1:Metadata) : DVRInfo
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc2_:DVRInfo = new DVRInfo();
         _loc2_.id = "";
         _loc2_.beginOffset = NaN;
         _loc2_.endOffset = NaN;
         _loc2_.offline = false;
         if(param1.getValue("dvrId") != null)
         {
            _loc2_.id = param1.getValue("dvrId") as String;
         }
         if(param1.getValue("beginOffset") != null)
         {
            _loc2_.beginOffset = param1.getValue("beginOffset") as uint;
         }
         if(param1.getValue("endOffset") != null)
         {
            _loc2_.endOffset = param1.getValue("endOffset") as uint;
         }
         if(param1.getValue("dvrOffline") != null)
         {
            _loc2_.offline = param1.getValue("dvrOffline") as Boolean;
         }
         return _loc2_;
      }
      
      private static function generateStreamInfos(param1:URLResource) : Vector.<HTTPStreamingF4FStreamInfo>
      {
         var _loc5_:Object = null;
         var _loc9_:ByteArray = null;
         var _loc11_:String = null;
         var _loc7_:Vector.<HTTPStreamingF4FStreamInfo> = new Vector.<HTTPStreamingF4FStreamInfo>();
         var _loc10_:Metadata = param1.getMetadataValue("http://www.osmf.org/drm/1.0") as Metadata;
         var _loc2_:Metadata = param1.getMetadataValue("http://www.osmf.org/httpstreaming/1.0") as Metadata;
         var _loc6_:ByteArray = null;
         var _loc4_:BootstrapInfo = null;
         var _loc3_:DynamicStreamingResource = param1 as DynamicStreamingResource;
         if(_loc3_ != null)
         {
            for each(var _loc8_:DynamicStreamingItem in _loc3_.streamItems)
            {
               _loc6_ = null;
               _loc4_ = null;
               _loc5_ = null;
               _loc9_ = null;
               if(_loc10_ != null)
               {
                  _loc6_ = _loc10_.getValue("DRMAdditionalHeader" + _loc8_.streamName) as ByteArray;
               }
               if(_loc2_ != null)
               {
                  _loc4_ = _loc2_.getValue("bootstrap" + _loc8_.streamName) as BootstrapInfo;
                  _loc5_ = _loc2_.getValue("streamMetadata" + _loc8_.streamName);
                  _loc9_ = _loc2_.getValue("xmpMetadata" + _loc8_.streamName) as ByteArray;
               }
               _loc7_.push(new HTTPStreamingF4FStreamInfo(_loc4_,_loc8_.streamName,_loc8_.bitrate,_loc6_,_loc5_,_loc9_));
            }
         }
         else
         {
            if(_loc10_ != null)
            {
               _loc6_ = _loc10_.getValue("DRMAdditionalHeader") as ByteArray;
            }
            if(_loc2_ != null)
            {
               _loc4_ = _loc2_.getValue("bootstrap") as BootstrapInfo;
               _loc5_ = _loc2_.getValue("streamMetadata");
               _loc9_ = _loc2_.getValue("xmpMetadata") as ByteArray;
            }
            _loc11_ = param1.url;
            _loc7_.push(new HTTPStreamingF4FStreamInfo(_loc4_,_loc11_,NaN,_loc6_,_loc5_,_loc9_));
         }
         return _loc7_;
      }
   }
}

