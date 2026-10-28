package org.osmf.net.rtmpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class SufficientBandwidthRule extends SwitchingRuleBase
   {
      
      private static const BANDWIDTH_SAFETY_MULTIPLE:Number = 1.15;
      
      private static const MIN_DROPPED_FPS:int = 2;
      
      public function SufficientBandwidthRule(metrics:RTMPNetStreamMetrics)
      {
         super(metrics);
      }
      
      override public function getNewIndex() : int
      {
         var moreDetail:String = null;
         var i:int = 0;
         var newIndex:int = -1;
         if(this.rtmpMetrics.averageMaxBytesPerSecond != 0)
         {
            for(i = this.rtmpMetrics.resource.streamItems.length - 1; i >= 0; i--)
            {
               if(this.rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > this.rtmpMetrics.resource.streamItems[i].bitrate * BANDWIDTH_SAFETY_MULTIPLE)
               {
                  newIndex = i;
                  break;
               }
            }
            if(newIndex > this.rtmpMetrics.currentIndex)
            {
               newIndex = this.rtmpMetrics.droppedFPS < MIN_DROPPED_FPS && this.rtmpMetrics.netStream.bufferLength > this.rtmpMetrics.netStream.bufferTime ? newIndex : -1;
            }
            else
            {
               newIndex = -1;
            }
         }
         return newIndex;
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

