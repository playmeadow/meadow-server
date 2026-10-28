package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.traits.BufferTrait;
   
   public class NetStreamBufferTrait extends BufferTrait
   {
      
      private var netStream:NetStream;
      
      private var changeBufferLengthTimer:Timer;
      
      public function NetStreamBufferTrait(param1:NetStream)
      {
         super();
         this.netStream = param1;
         bufferTime = param1.bufferTime;
         param1.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,0,true);
         this.changeBufferLengthTimer = new Timer(250);
         this.changeBufferLengthTimer.addEventListener(TimerEvent.TIMER,this.onChangeBufferLength,false,0,true);
         this.changeBufferLengthTimer.start();
      }
      
      override public function get bufferLength() : Number
      {
         return this.netStream.bufferLength;
      }
      
      override protected function bufferTimeChangeStart(param1:Number) : void
      {
         this.netStream.bufferTime = param1;
      }
      
      private function onChangeBufferLength(param1:TimerEvent) : void
      {
         setBufferLength(this.netStream.bufferLength);
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         switch(param1.info.code)
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

