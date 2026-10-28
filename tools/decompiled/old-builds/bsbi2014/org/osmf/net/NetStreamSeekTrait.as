package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.media.Video;
   import flash.net.NetStream;
   import flash.utils.Timer;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   
   [ExcludeClass]
   public class NetStreamSeekTrait extends SeekTrait
   {
      
      private var video:Video;
      
      private var loadTrait:LoadTrait;
      
      private var audioDelay:Number = 0;
      
      private var seekBugTimer:Timer;
      
      private var netStream:NetStream;
      
      private var expectedTime:Number;
      
      private var previousTime:Number;
      
      private var suppressSeekNotifyEvent:Boolean = false;
      
      public function NetStreamSeekTrait(temporal:TimeTrait, loadTrait:LoadTrait, netStream:NetStream, video:Video = null)
      {
         super(temporal);
         this.netStream = netStream;
         this.video = video;
         this.loadTrait = loadTrait;
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_META_DATA,this.onMetaData);
         netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
         this.seekBugTimer = new Timer(10,100);
         this.seekBugTimer.addEventListener(TimerEvent.TIMER,this.onSeekBugTimer,false,0,true);
         this.seekBugTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onSeekBugTimerDone,false,0,true);
      }
      
      override public function canSeekTo(time:Number) : Boolean
      {
         var maxSeekTime:Number = NaN;
         var result:Boolean = super.canSeekTo(time);
         if(result && !isNaN(this.loadTrait.bytesTotal) && this.loadTrait.bytesTotal > 0)
         {
            maxSeekTime = timeTrait.duration * Number(this.loadTrait.bytesLoaded / this.loadTrait.bytesTotal);
            result = time <= maxSeekTime;
         }
         return result;
      }
      
      override protected function seekingChangeStart(newSeeking:Boolean, time:Number) : void
      {
         if(newSeeking)
         {
            this.suppressSeekNotifyEvent = false;
            this.previousTime = this.netStream.time - this.audioDelay;
            this.expectedTime = time;
            this.netStream.seek(time + this.audioDelay);
            if(this.previousTime == this.expectedTime)
            {
               this.seekBugTimer.start();
               this.suppressSeekNotifyEvent = true;
            }
         }
      }
      
      override protected function seekingChangeEnd(time:Number) : void
      {
         var nsTimeTrait:NetStreamTimeTrait = null;
         super.seekingChangeEnd(time);
         if(seeking == true && this.video != null)
         {
            nsTimeTrait = timeTrait as NetStreamTimeTrait;
            if(nsTimeTrait != null && nsTimeTrait.currentTime + nsTimeTrait.audioDelay >= nsTimeTrait.duration)
            {
               this.video.clear();
            }
         }
      }
      
      private function onMetaData(value:Object) : void
      {
         this.audioDelay = value.hasOwnProperty("audiodelay") ? Number(value.audiodelay) : 0;
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
               this.runSeekBugTimer();
               break;
            case NetStreamCodes.NETSTREAM_SEEK_INVALIDTIME:
            case NetStreamCodes.NETSTREAM_SEEK_FAILED:
               setSeeking(false,this.previousTime);
               break;
            case NetStreamCodes.NETSTREAM_PLAY_START:
            case NetStreamCodes.NETSTREAM_PLAY_RESET:
            case NetStreamCodes.NETSTREAM_PAUSE_NOTIFY:
            case NetStreamCodes.NETSTREAM_PLAY_STOP:
            case NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY:
               if(seeking && this.seekBugTimer.running == false)
               {
                  this.runSeekBugTimer();
               }
         }
      }
      
      private function runSeekBugTimer() : void
      {
         if(this.suppressSeekNotifyEvent == false)
         {
            this.seekBugTimer.start();
         }
         else
         {
            this.suppressSeekNotifyEvent = false;
         }
      }
      
      private function onSeekBugTimer(event:TimerEvent) : void
      {
         if(this.previousTime != this.netStream.time - this.audioDelay || this.previousTime == this.expectedTime)
         {
            this.onSeekBugTimerDone(null);
         }
      }
      
      private function onSeekBugTimerDone(event:TimerEvent) : void
      {
         this.seekBugTimer.reset();
         setSeeking(false,this.expectedTime);
      }
   }
}

