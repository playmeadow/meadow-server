package org.osmf.net
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.net.NetStreamPlayTransitions;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import org.osmf.utils.OSMFStrings;
   
   public class NetStreamSwitchManager extends NetStreamSwitchManagerBase
   {
      
      private static const RULE_CHECK_INTERVAL:Number = 500;
      
      private static const DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM:int = 3;
      
      private static const DEFAULT_WAIT_DURATION_AFTER_DOWN_SWITCH:int = 30000;
      
      private static const DEFAULT_CLEAR_FAILED_COUNTS_INTERVAL:Number = 300000;
      
      private var netStream:NetStream;
      
      private var dsResource:DynamicStreamingResource;
      
      private var switchingRules:Vector.<SwitchingRuleBase>;
      
      private var metrics:NetStreamMetricsBase;
      
      private var checkRulesTimer:Timer;
      
      private var clearFailedCountsTimer:Timer;
      
      private var actualIndex:int = -1;
      
      private var oldStreamName:String;
      
      private var switching:Boolean;
      
      private var _currentIndex:int;
      
      private var lastTransitionIndex:int = -1;
      
      private var connection:NetConnection;
      
      private var dsiFailedCounts:Vector.<int>;
      
      private var failedDSI:Dictionary;
      
      private var _bandwidthLimit:Number = 0;
      
      public function NetStreamSwitchManager(connection:NetConnection, netStream:NetStream, resource:DynamicStreamingResource, metrics:NetStreamMetricsBase, switchingRules:Vector.<SwitchingRuleBase>)
      {
         super();
         this.connection = connection;
         this.netStream = netStream;
         this.dsResource = resource;
         this.metrics = metrics;
         this.switchingRules = switchingRules || new Vector.<SwitchingRuleBase>();
         this._currentIndex = Math.max(0,Math.min(this.maxAllowedIndex,this.dsResource.initialIndex));
         this.checkRulesTimer = new Timer(RULE_CHECK_INTERVAL);
         this.checkRulesTimer.addEventListener(TimerEvent.TIMER,this.checkRules);
         this.failedDSI = new Dictionary();
         this._bandwidthLimit = 1.4 * resource.streamItems[resource.streamItems.length - 1].bitrate * 1000 / 8;
         netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS,this.onPlayStatus,int.MAX_VALUE);
      }
      
      override public function set autoSwitch(value:Boolean) : void
      {
         super.autoSwitch = value;
         if(autoSwitch)
         {
            this.checkRulesTimer.start();
         }
         else
         {
            this.checkRulesTimer.stop();
         }
      }
      
      override public function get currentIndex() : uint
      {
         return this._currentIndex;
      }
      
      override public function get maxAllowedIndex() : int
      {
         var count:int = this.dsResource.streamItems.length - 1;
         return count < super.maxAllowedIndex ? count : super.maxAllowedIndex;
      }
      
      override public function set maxAllowedIndex(value:int) : void
      {
         if(value > this.dsResource.streamItems.length)
         {
            throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
         }
         super.maxAllowedIndex = value;
         this.metrics.maxAllowedIndex = value;
      }
      
      override public function switchTo(index:int) : void
      {
         if(!autoSwitch)
         {
            if(index < 0 || index > this.maxAllowedIndex)
            {
               throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
            }
            if(this.actualIndex == -1)
            {
               this.prepareForSwitching();
            }
            this.executeSwitch(index);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE));
      }
      
      protected function canAutoSwitchNow(newIndex:int) : Boolean
      {
         var current:int = 0;
         if(this.dsiFailedCounts[newIndex] >= 1)
         {
            current = getTimer();
            if(current - this.failedDSI[newIndex] < DEFAULT_WAIT_DURATION_AFTER_DOWN_SWITCH)
            {
               return false;
            }
         }
         else if(this.dsiFailedCounts[newIndex] > DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM)
         {
            return false;
         }
         return true;
      }
      
      final protected function get bandwidthLimit() : Number
      {
         return this._bandwidthLimit;
      }
      
      final protected function set bandwidthLimit(value:Number) : void
      {
         this._bandwidthLimit = value;
      }
      
      private function executeSwitch(targetIndex:int) : void
      {
         var nso:NetStreamPlayOptions = new NetStreamPlayOptions();
         var playArgs:Object = NetStreamUtils.getPlayArgsForResource(this.dsResource);
         nso.start = playArgs.start;
         nso.len = playArgs.len;
         nso.streamName = this.dsResource.streamItems[targetIndex].streamName;
         var sn:String = this.oldStreamName;
         if(sn != null && sn.indexOf("?") >= 0)
         {
            nso.oldStreamName = sn.substr(0,sn.indexOf("?"));
         }
         else
         {
            nso.oldStreamName = this.oldStreamName;
         }
         nso.transition = NetStreamPlayTransitions.SWITCH;
         this.switching = true;
         this.netStream.play2(nso);
         this.oldStreamName = this.dsResource.streamItems[targetIndex].streamName;
         if(targetIndex < this.actualIndex && autoSwitch)
         {
            this.incrementDSIFailedCount(this.actualIndex);
            this.failedDSI[this.actualIndex] = getTimer();
         }
      }
      
      private function checkRules(event:TimerEvent) : void
      {
         var n:int = 0;
         if(this.switchingRules == null || this.switching)
         {
            return;
         }
         var newIndex:int = int.MAX_VALUE;
         for(var i:int = 0; i < this.switchingRules.length; i++)
         {
            n = this.switchingRules[i].getNewIndex();
            if(n != -1 && n < newIndex)
            {
               newIndex = n;
            }
         }
         if(newIndex != -1 && newIndex != int.MAX_VALUE && newIndex != this.actualIndex)
         {
            newIndex = Math.min(newIndex,this.maxAllowedIndex);
         }
         if(newIndex != -1 && newIndex != int.MAX_VALUE && newIndex != this.actualIndex && !this.switching && newIndex <= this.maxAllowedIndex && this.canAutoSwitchNow(newIndex))
         {
            this.executeSwitch(newIndex);
         }
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_START:
               if(this.actualIndex == -1)
               {
                  this.prepareForSwitching();
               }
               else if(autoSwitch && this.checkRulesTimer.running == false)
               {
                  this.checkRulesTimer.start();
               }
               break;
            case NetStreamCodes.NETSTREAM_PLAY_TRANSITION:
               this.switching = false;
               this.actualIndex = this.dsResource.indexFromName(event.info.details);
               this.metrics.currentIndex = this.actualIndex;
               this.lastTransitionIndex = this.actualIndex;
               break;
            case NetStreamCodes.NETSTREAM_PLAY_FAILED:
               this.switching = false;
               break;
            case NetStreamCodes.NETSTREAM_SEEK_NOTIFY:
               this.switching = false;
               if(this.lastTransitionIndex >= 0)
               {
                  this._currentIndex = this.lastTransitionIndex;
               }
               break;
            case NetStreamCodes.NETSTREAM_PLAY_STOP:
               this.checkRulesTimer.stop();
         }
      }
      
      private function onPlayStatus(info:Object) : void
      {
         switch(info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE:
               if(this.lastTransitionIndex >= 0)
               {
                  this._currentIndex = this.lastTransitionIndex;
                  this.lastTransitionIndex = -1;
               }
         }
      }
      
      private function prepareForSwitching() : void
      {
         this.initDSIFailedCounts();
         this.metrics.resource = this.dsResource;
         this.actualIndex = 0;
         this.lastTransitionIndex = -1;
         if(this.dsResource.initialIndex >= 0 && this.dsResource.initialIndex < this.dsResource.streamItems.length)
         {
            this.actualIndex = this.dsResource.initialIndex;
         }
         if(autoSwitch)
         {
            this.checkRulesTimer.start();
         }
         this.setThrottleLimits(this.dsResource.streamItems.length - 1);
         this.metrics.currentIndex = this.actualIndex;
      }
      
      private function initDSIFailedCounts() : void
      {
         if(this.dsiFailedCounts != null)
         {
            this.dsiFailedCounts.length = 0;
            this.dsiFailedCounts = null;
         }
         this.dsiFailedCounts = new Vector.<int>();
         for(var i:int = 0; i < this.dsResource.streamItems.length; i++)
         {
            this.dsiFailedCounts.push(0);
         }
      }
      
      private function incrementDSIFailedCount(index:int) : void
      {
         ++this.dsiFailedCounts[index];
         if(this.dsiFailedCounts[index] > DEFAULT_MAX_UP_SWITCHES_PER_STREAM_ITEM)
         {
            if(this.clearFailedCountsTimer == null)
            {
               this.clearFailedCountsTimer = new Timer(DEFAULT_CLEAR_FAILED_COUNTS_INTERVAL,1);
               this.clearFailedCountsTimer.addEventListener(TimerEvent.TIMER,this.clearFailedCounts);
            }
            this.clearFailedCountsTimer.start();
         }
      }
      
      private function clearFailedCounts(event:TimerEvent) : void
      {
         this.clearFailedCountsTimer.removeEventListener(TimerEvent.TIMER,this.clearFailedCounts);
         this.clearFailedCountsTimer = null;
         this.initDSIFailedCounts();
      }
      
      private function setThrottleLimits(index:int) : void
      {
         this.connection.call("setBandwidthLimit",null,this._bandwidthLimit,this._bandwidthLimit);
      }
   }
}

