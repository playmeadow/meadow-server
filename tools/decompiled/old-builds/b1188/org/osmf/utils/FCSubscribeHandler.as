package org.osmf.utils
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.utils.Timer;
   
   public class FCSubscribeHandler
   {
      
      private var maxRetry:Number = 5;
      
      private var currentTry:Number = 0;
      
      private var retryTimer:Timer;
      
      private var nc:NetConnection;
      
      private var owner:Object;
      
      public var nsName:String;
      
      public function FCSubscribeHandler()
      {
         super();
      }
      
      public function run(param1:String, param2:String, param3:Object) : void
      {
         this.nsName = param1;
         this.owner = param3;
         this.nc = new NetConnection();
         this.nc.addEventListener(NetStatusEvent.NET_STATUS,this.netConnectHandler);
         this.nc.client = this;
         this.nc.connect(param2);
      }
      
      protected function netConnectHandler(param1:NetStatusEvent) : void
      {
         if(param1.info.code == "NetConnection.Connect.Success")
         {
            this.fcSubscribeRetry();
         }
         else if(param1.info.code != "NetStream.Play.UnpublishNotify")
         {
            if(param1.info.code == "NetStream.Unpublish.Success")
            {
            }
         }
      }
      
      private function fcSubscribeRetry() : void
      {
         this.retryTimer = new Timer(1000,3);
         this.retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.retryFCSubscribe);
         this.retryTimer.start();
      }
      
      private function retryFCSubscribe(param1:TimerEvent) : void
      {
         if(this.currentTry != this.maxRetry)
         {
            this.nc.call("FCSubscribe",null,this.nsName);
            ++this.currentTry;
         }
         else
         {
            this.cleanupTimer();
         }
      }
      
      public function onFCSubscribe(param1:Object) : void
      {
         if(param1.code != "NetStream.Play.StreamNotFound")
         {
            if(param1.code == "NetStream.Play.Start")
            {
               this.cleanupTimer();
               this.owner.fcSubscribeDone();
            }
         }
      }
      
      public function onFCUnpublish(param1:Object) : void
      {
      }
      
      private function cleanupTimer() : void
      {
         this.retryTimer.stop();
         this.retryTimer = null;
      }
   }
}

