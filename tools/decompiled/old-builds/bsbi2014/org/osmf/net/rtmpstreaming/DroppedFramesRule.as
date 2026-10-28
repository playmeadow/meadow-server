package org.osmf.net.rtmpstreaming
{
   import flash.utils.getTimer;
   import org.osmf.net.NetStreamMetricsBase;
   import org.osmf.net.SwitchingRuleBase;
   
   public class DroppedFramesRule extends SwitchingRuleBase
   {
      
      private static const LOCK_INTERVAL:Number = 30000;
      
      private var downSwitchByOne:int;
      
      private var downSwitchByTwo:int;
      
      private var downSwitchToZero:int;
      
      private var lockLevel:Number;
      
      private var lastLockTime:Number;
      
      public function DroppedFramesRule(metrics:NetStreamMetricsBase, downSwitchByOne:int = 10, downSwitchByTwo:int = 20, downSwitchToZero:int = 24)
      {
         super(metrics);
         this.downSwitchByOne = downSwitchByOne;
         this.downSwitchByTwo = downSwitchByTwo;
         this.downSwitchToZero = downSwitchToZero;
         this.lastLockTime = 0;
         this.lockLevel = int.MAX_VALUE;
      }
      
      override public function getNewIndex() : int
      {
         var moreDetail:String = null;
         var newIndex:int = -1;
         if(metrics.averageDroppedFPS > this.downSwitchToZero)
         {
            newIndex = 0;
            moreDetail = "Average droppedFPS of " + Math.round(metrics.averageDroppedFPS) + " > " + this.downSwitchToZero;
         }
         else if(metrics.averageDroppedFPS > this.downSwitchByTwo)
         {
            newIndex = metrics.currentIndex - 2 < 0 ? 0 : int(metrics.currentIndex - 2);
            moreDetail = "Average droppedFPS of " + Math.round(metrics.averageDroppedFPS) + " > " + this.downSwitchByTwo;
         }
         else if(metrics.averageDroppedFPS > this.downSwitchByOne)
         {
            newIndex = metrics.currentIndex - 1 < 0 ? 0 : int(metrics.currentIndex - 1);
            moreDetail = "Average droppedFPS of " + Math.round(metrics.averageDroppedFPS) + " > " + this.downSwitchByOne;
         }
         if(newIndex != -1 && newIndex < metrics.currentIndex)
         {
            this.lockIndex(newIndex);
         }
         if(newIndex == -1 && this.isLocked(metrics.currentIndex))
         {
            newIndex = metrics.currentIndex;
         }
         return newIndex;
      }
      
      private function lockIndex(index:int) : void
      {
         if(!this.isLocked(index))
         {
            this.lockLevel = index;
            this.lastLockTime = getTimer();
         }
      }
      
      private function isLocked(index:int) : Boolean
      {
         return index >= this.lockLevel && getTimer() - this.lastLockTime < LOCK_INTERVAL;
      }
   }
}

