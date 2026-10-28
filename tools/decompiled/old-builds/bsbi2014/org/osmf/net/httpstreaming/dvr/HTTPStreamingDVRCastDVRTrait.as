package org.osmf.net.httpstreaming.dvr
{
   import flash.net.NetConnection;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.net.httpstreaming.HTTPNetStream;
   import org.osmf.traits.DVRTrait;
   
   [ExcludeClass]
   public class HTTPStreamingDVRCastDVRTrait extends DVRTrait
   {
      
      private var _connection:NetConnection;
      
      private var _stream:HTTPNetStream;
      
      private var _dvrInfo:DVRInfo;
      
      public function HTTPStreamingDVRCastDVRTrait(connection:NetConnection, stream:HTTPNetStream, dvrInfo:DVRInfo)
      {
         this._connection = connection;
         this._stream = stream;
         this._dvrInfo = dvrInfo;
         this._stream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO,this.onDVRStreamInfo);
         super(dvrInfo.isRecording);
      }
      
      private function onDVRStreamInfo(event:DVRStreamInfoEvent) : void
      {
         this._dvrInfo = event.info as DVRInfo;
         setIsRecording(this._dvrInfo == null ? false : this._dvrInfo.isRecording);
      }
   }
}

