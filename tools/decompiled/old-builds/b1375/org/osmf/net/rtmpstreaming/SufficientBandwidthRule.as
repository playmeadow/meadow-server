package org.osmf.net.rtmpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class SufficientBandwidthRule extends SwitchingRuleBase
   {
      
      private static const BANDWIDTH_SAFETY_MULTIPLE:Number = 1.15;
      
      private static const MIN_DROPPED_FPS:int = 2;
      
      public function SufficientBandwidthRule(param1:RTMPNetStreamMetrics)
      {
         super(param1);
      }
      
      override public function getNewIndex() : int
      {
         var _loc1_:* = null;
         var _loc2_:int = 0;
         var _loc3_:* = -1;
         if(rtmpMetrics.averageMaxBytesPerSecond != 0)
         {
            _loc2_ = rtmpMetrics.resource.streamItems.length - 1;
            while(_loc2_ >= 0)
            {
               if(rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > rtmpMetrics.resource.streamItems[_loc2_].bitrate * 1.15)
               {
                  _loc3_ = _loc2_;
                  break;
               }
               _loc2_--;
            }
            if(_loc3_ > rtmpMetrics.currentIndex)
            {
               _loc3_ = int(rtmpMetrics.droppedFPS < 2 && rtmpMetrics.netStream.bufferLength > rtmpMetrics.netStream.bufferTime ? _loc3_ : -1);
            }
            else
            {
               _loc3_ = -1;
            }
         }
         return _loc3_;
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

