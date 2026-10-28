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
      
      public function run(nsName:String, url:String, owner:Object) : void
      {
         this.nsName = nsName;
         this.owner = owner;
         this.nc = new NetConnection();
         this.nc.addEventListener(NetStatusEvent.NET_STATUS,this.netConnectHandler);
         this.nc.client = this;
         this.nc.connect(url);
      }
      
      protected function netConnectHandler(event:NetStatusEvent) : void
      {
         trace("NC: " + event.info.code);
         if(event.info.code == "NetConnection.Connect.Success")
         {
            this.fcSubscribeRetry();
         }
         else if(event.info.code == "NetStream.Play.UnpublishNotify")
         {
            trace("publish");
         }
         else if(event.info.code == "NetStream.Unpublish.Success")
         {
            trace("unpublish");
         }
      }
      
      private function fcSubscribeRetry() : void
      {
         this.retryTimer = new Timer(1000,3);
         this.retryTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.retryFCSubscribe);
         this.retryTimer.start();
      }
      
      private function retryFCSubscribe(event:TimerEvent) : void
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
      
      public function onFCSubscribe(info:Object) : void
      {
         trace(info.code);
         if(info.code != "NetStream.Play.StreamNotFound")
         {
            if(info.code == "NetStream.Play.Start")
            {
               this.cleanupTimer();
               trace("ready to play");
               this.owner.fcSubscribeDone();
            }
         }
      }
      
      public function onFCUnpublish(info:Object) : void
      {
         trace("hi");
      }
      
      private function cleanupTimer() : void
      {
         this.retryTimer.stop();
         this.retryTimer = null;
      }
   }
}

