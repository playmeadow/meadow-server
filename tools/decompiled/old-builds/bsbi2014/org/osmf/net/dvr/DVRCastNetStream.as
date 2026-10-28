package org.osmf.net.dvr
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import org.osmf.media.MediaResourceBase;
   
   [ExcludeClass]
   public class DVRCastNetStream extends NetStream
   {
      
      private var recordingInfo:DVRCastRecordingInfo;
      
      public function DVRCastNetStream(connection:NetConnection, resource:MediaResourceBase)
      {
         super(connection);
         this.recordingInfo = resource.getMetadataValue(DVRCastConstants.RECORDING_INFO_KEY) as DVRCastRecordingInfo;
      }
      
      override public function play(... arguments) : void
      {
         super.play(arguments[0],this.recordingInfo.startOffset,-1);
      }
      
      override public function play2(param:NetStreamPlayOptions) : void
      {
         if(Boolean(param))
         {
            param.start = this.recordingInfo.startOffset;
            param.len = -1;
         }
         super.play2(param);
      }
   }
}

