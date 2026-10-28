package org.osmf.net
{
   import flash.utils.ByteArray;
   import org.osmf.media.URLResource;
   
   public class StreamingURLResource extends URLResource
   {
      
      private var _streamType:String;
      
      private var _clipStartTime:Number;
      
      private var _clipEndTime:Number;
      
      private var _connectionArguments:Vector.<Object>;
      
      private var _drmContentData:ByteArray;
      
      private var _urlIncludesFMSApplicationInstance:Boolean = false;
      
      public function StreamingURLResource(url:String, streamType:String = null, clipStartTime:Number = NaN, clipEndTime:Number = NaN, connectionArguments:Vector.<Object> = null, urlIncludesFMSApplicationInstance:Boolean = false, drmContentData:ByteArray = null)
      {
         this._streamType = streamType || StreamType.RECORDED;
         this._clipStartTime = clipStartTime;
         this._clipEndTime = clipEndTime;
         this._urlIncludesFMSApplicationInstance = urlIncludesFMSApplicationInstance;
         this._drmContentData = drmContentData;
         this._connectionArguments = connectionArguments;
         super(url);
      }
      
      public function get streamType() : String
      {
         return this._streamType;
      }
      
      public function set streamType(value:String) : void
      {
         this._streamType = value;
      }
      
      public function get clipStartTime() : Number
      {
         return this._clipStartTime;
      }
      
      public function set clipStartTime(value:Number) : void
      {
         this._clipStartTime = value;
      }
      
      public function get clipEndTime() : Number
      {
         return this._clipEndTime;
      }
      
      public function set clipEndTime(value:Number) : void
      {
         this._clipEndTime = value;
      }
      
      public function get connectionArguments() : Vector.<Object>
      {
         return this._connectionArguments;
      }
      
      public function set connectionArguments(value:Vector.<Object>) : void
      {
         this._connectionArguments = value;
      }
      
      public function get drmContentData() : ByteArray
      {
         return this._drmContentData;
      }
      
      public function set drmContentData(value:ByteArray) : void
      {
         this._drmContentData = value;
      }
      
      public function get urlIncludesFMSApplicationInstance() : Boolean
      {
         return this._urlIncludesFMSApplicationInstance;
      }
      
      public function set urlIncludesFMSApplicationInstance(value:Boolean) : void
      {
         this._urlIncludesFMSApplicationInstance = value;
      }
   }
}

