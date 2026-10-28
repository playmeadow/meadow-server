package org.osmf.net.dvr
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.events.TimeEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   internal class DVRCastTimeTrait extends TimeTrait
   {
      
      private var durationUpdateTimer:Timer;
      
      private var oldDuration:Number;
      
      private var stream:NetStream;
      
      private var streamInfo:DVRCastStreamInfo;
      
      private var recordingInfo:DVRCastRecordingInfo;
      
      public function DVRCastTimeTrait(connection:NetConnection, stream:NetStream, resource:MediaResourceBase)
      {
         super(NaN);
         if(connection == null || stream == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.stream = stream;
         stream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
         this.durationUpdateTimer = new Timer(DVRCastConstants.LOCAL_DURATION_UPDATE_INTERVAL);
         this.durationUpdateTimer.addEventListener(TimerEvent.TIMER,this.onDurationUpdateTimer);
         this.durationUpdateTimer.start();
         this.streamInfo = resource.getMetadataValue(DVRCastConstants.STREAM_INFO_KEY) as DVRCastStreamInfo;
         this.recordingInfo = resource.getMetadataValue(DVRCastConstants.RECORDING_INFO_KEY) as DVRCastRecordingInfo;
      }
      
      override public function get duration() : Number
      {
         var result:Number = NaN;
         if(this.streamInfo.isRecording)
         {
            result = this.recordingInfo.startDuration - this.recordingInfo.startOffset + (new Date().time - this.recordingInfo.startTime.time) / 1000;
         }
         else
         {
            result = this.streamInfo.currentLength - this.recordingInfo.startOffset;
         }
         return isNaN(result) ? NaN : Math.max(0,result);
      }
      
      override public function get currentTime() : Number
      {
         return this.stream.time;
      }
      
      private function onDurationUpdateTimer(event:TimerEvent) : void
      {
         var newDuration:Number = this.duration;
         if(newDuration != this.oldDuration)
         {
            this.oldDuration = newDuration;
            dispatchEvent(new TimeEvent(TimeEvent.DURATION_CHANGE,false,false,newDuration));
         }
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         if(event.info.code == "NetStream.Play.Stop")
         {
            if(Boolean(this.durationUpdateTimer))
            {
               this.durationUpdateTimer.stop();
            }
            signalComplete();
         }
      }
   }
}

