package org.osmf.net.rtmpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class InsufficientBandwidthRule extends SwitchingRuleBase
   {
      
      private var bitrateMultiplier:Number;
      
      public function InsufficientBandwidthRule(metrics:RTMPNetStreamMetrics, bitrateMultiplier:Number = 1.15)
      {
         super(metrics);
         this.bitrateMultiplier = bitrateMultiplier;
      }
      
      override public function getNewIndex() : int
      {
         var moreDetail:String = null;
         var i:int = 0;
         var newIndex:int = -1;
         if(this.rtmpMetrics.averageMaxBytesPerSecond != 0)
         {
            for(i = this.rtmpMetrics.currentIndex; i >= 0; i--)
            {
               if(this.rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > this.rtmpMetrics.resource.streamItems[i].bitrate * this.bitrateMultiplier)
               {
                  newIndex = i;
                  break;
               }
            }
            newIndex = newIndex == this.rtmpMetrics.currentIndex ? -1 : newIndex;
         }
         return newIndex;
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

