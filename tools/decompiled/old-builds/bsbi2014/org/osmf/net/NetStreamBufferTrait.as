package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.traits.BufferTrait;
   
   [ExcludeClass]
   public class NetStreamBufferTrait extends BufferTrait
   {
      
      private var netStream:NetStream;
      
      private var changeBufferLengthTimer:Timer;
      
      public function NetStreamBufferTrait(netStream:NetStream)
      {
         super();
         this.netStream = netStream;
         bufferTime = netStream.bufferTime;
         netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,0,true);
         this.changeBufferLengthTimer = new Timer(250);
         this.changeBufferLengthTimer.addEventListener(TimerEvent.TIMER,this.onChangeBufferLength,false,0,true);
         this.changeBufferLengthTimer.start();
      }
      
      override public function get bufferLength() : Number
      {
         return this.netStream.bufferLength;
      }
      
      override protected function bufferTimeChangeStart(newTime:Number) : void
      {
         this.netStream.bufferTime = newTime;
      }
      
      private function onChangeBufferLength(t:TimerEvent) : void
      {
         setBufferLength(this.netStream.bufferLength);
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_START:
            case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
               bufferTime = this.netStream.bufferTime;
               setBuffering(true);
               if(this.netStream.bufferTime == 0)
               {
                  setBuffering(false);
               }
               break;
            case NetStreamCodes.NETSTREAM_BUFFER_FLUSH:
            case NetStreamCodes.NETSTREAM_BUFFER_FULL:
               setBuffering(false);
         }
      }
   }
}

