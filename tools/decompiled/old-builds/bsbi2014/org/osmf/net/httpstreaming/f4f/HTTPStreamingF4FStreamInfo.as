package org.osmf.net.httpstreaming.f4f
{
   import flash.utils.ByteArray;
   import org.osmf.elements.f4mClasses.BootstrapInfo;
   
   [ExcludeClass]
   public class HTTPStreamingF4FStreamInfo
   {
      
      private var _streamName:String;
      
      private var _bitrate:Number;
      
      private var _bootstrap:BootstrapInfo;
      
      private var _additionalHeader:ByteArray;
      
      private var _streamMetadata:Object;
      
      private var _xmpMetadata:ByteArray;
      
      public function HTTPStreamingF4FStreamInfo(bootstrap:BootstrapInfo, streamName:String, bitrate:Number, additionalHeader:ByteArray, streamMetadata:Object, xmpMetadata:ByteArray)
      {
         super();
         this._streamName = streamName;
         this._bitrate = bitrate;
         this._additionalHeader = additionalHeader;
         this._bootstrap = bootstrap;
         this._streamMetadata = streamMetadata;
         this._xmpMetadata = xmpMetadata;
      }
      
      public function get streamName() : String
      {
         return this._streamName;
      }
      
      public function get bitrate() : Number
      {
         return this._bitrate;
      }
      
      public function get additionalHeader() : ByteArray
      {
         return this._additionalHeader;
      }
      
      public function get bootstrapInfo() : BootstrapInfo
      {
         return this._bootstrap;
      }
      
      public function get streamMetadata() : Object
      {
         return this._streamMetadata;
      }
      
      public function get xmpMetadata() : ByteArray
      {
         return this._xmpMetadata;
      }
   }
}

