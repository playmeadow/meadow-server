package org.osmf.net
{
   import flash.utils.ByteArray;
   
   public class MulticastResource extends StreamingURLResource
   {
      
      private var _groupspec:String;
      
      private var _streamName:String;
      
      public function MulticastResource(param1:String, param2:String = null, param3:String = null, param4:Vector.<Object> = null, param5:Boolean = false, param6:ByteArray = null)
      {
         super(param1,StreamType.LIVE,NaN,NaN,param4,param5,param6);
         this._groupspec = param2;
         this._streamName = param3;
      }
      
      public function get groupspec() : String
      {
         return this._groupspec;
      }
      
      public function set groupspec(param1:String) : void
      {
         this._groupspec = param1;
      }
      
      public function get streamName() : String
      {
         return this._streamName;
      }
      
      public function set streamName(param1:String) : void
      {
         this._streamName = param1;
      }
   }
}

