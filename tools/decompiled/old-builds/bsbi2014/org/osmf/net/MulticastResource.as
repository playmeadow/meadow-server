package org.osmf.net
{
   import flash.utils.ByteArray;
   
   public class MulticastResource extends StreamingURLResource
   {
      
      private var _groupspec:String;
      
      private var _streamName:String;
      
      public function MulticastResource(url:String, groupspec:String = null, streamName:String = null, connectionArguments:Vector.<Object> = null, urlIncludesFMSApplicationInstance:Boolean = false, drmContentData:ByteArray = null)
      {
         super(url,StreamType.LIVE,NaN,NaN,connectionArguments,urlIncludesFMSApplicationInstance,drmContentData);
         this._groupspec = groupspec;
         this._streamName = streamName;
      }
      
      public function get groupspec() : String
      {
         return this._groupspec;
      }
      
      public function set groupspec(value:String) : void
      {
         this._groupspec = value;
      }
      
      public function get streamName() : String
      {
         return this._streamName;
      }
      
      public function set streamName(value:String) : void
      {
         this._streamName = value;
      }
   }
}

