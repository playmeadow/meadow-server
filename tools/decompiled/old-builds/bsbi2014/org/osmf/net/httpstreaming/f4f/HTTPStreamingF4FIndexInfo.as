package org.osmf.net.httpstreaming.f4f
{
   import org.osmf.net.httpstreaming.HTTPStreamingIndexInfoBase;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   
   [ExcludeClass]
   public class HTTPStreamingF4FIndexInfo extends HTTPStreamingIndexInfoBase
   {
      
      private var _serverBaseURL:String;
      
      private var _dvrInfo:DVRInfo;
      
      private var _streamInfos:Vector.<HTTPStreamingF4FStreamInfo>;
      
      public function HTTPStreamingF4FIndexInfo(serverBaseURL:String = null, streamInfos:Vector.<HTTPStreamingF4FStreamInfo> = null, dvrInfo:DVRInfo = null)
      {
         super();
         this._serverBaseURL = serverBaseURL;
         this._streamInfos = streamInfos;
         this._dvrInfo = dvrInfo;
      }
      
      public function get serverBaseURL() : String
      {
         return this._serverBaseURL;
      }
      
      public function get streamInfos() : Vector.<HTTPStreamingF4FStreamInfo>
      {
         return this._streamInfos;
      }
      
      public function get dvrInfo() : DVRInfo
      {
         return this._dvrInfo;
      }
   }
}

