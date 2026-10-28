package org.osmf.net.httpstreaming.dvr
{
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.net.NetStreamCodes;
   import org.osmf.net.httpstreaming.HTTPNetStream;
   import org.osmf.traits.TimeTrait;
   
   [ExcludeClass]
   public class HTTPStreamingDVRCastTimeTrait extends TimeTrait
   {
      
      private var _connection:NetConnection;
      
      private var _stream:HTTPNetStream;
      
      private var _dvrInfo:DVRInfo;
      
      public function HTTPStreamingDVRCastTimeTrait(connection:NetConnection, stream:HTTPNetStream, dvrInfo:DVRInfo)
      {
         super(NaN);
         this._connection = connection;
         this._stream = stream;
         this._dvrInfo = dvrInfo;
         this._stream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO,this.onDVRStreamInfo);
         this._stream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
      }
      
      override public function get duration() : Number
      {
         if(this._dvrInfo == null)
         {
            return NaN;
         }
         return this._dvrInfo.curLength;
      }
      
      override public function get currentTime() : Number
      {
         return this._stream.time;
      }
      
      private function onDVRStreamInfo(event:DVRStreamInfoEvent) : void
      {
         this._dvrInfo = event.info as DVRInfo;
         setDuration(this._dvrInfo.curLength);
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY:
               signalComplete();
         }
      }
   }
}

