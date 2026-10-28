package org.osmf.net.rtmpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   public class InsufficientBandwidthRule extends SwitchingRuleBase
   {
      
      private var bitrateMultiplier:Number;
      
      public function InsufficientBandwidthRule(param1:RTMPNetStreamMetrics, param2:Number = 1.15)
      {
         super(param1);
         this.bitrateMultiplier = param2;
      }
      
      override public function getNewIndex() : int
      {
         var _loc1_:* = null;
         var _loc2_:int = 0;
         var _loc3_:* = -1;
         if(rtmpMetrics.averageMaxBytesPerSecond != 0)
         {
            _loc2_ = rtmpMetrics.currentIndex;
            while(_loc2_ >= 0)
            {
               if(rtmpMetrics.averageMaxBytesPerSecond * 8 / 1024 > rtmpMetrics.resource.streamItems[_loc2_].bitrate * bitrateMultiplier)
               {
                  _loc3_ = _loc2_;
                  break;
               }
               _loc2_--;
            }
            _loc3_ = int(_loc3_ == rtmpMetrics.currentIndex ? -1 : _loc3_);
         }
         return _loc3_;
      }
      
      private function get rtmpMetrics() : RTMPNetStreamMetrics
      {
         return metrics as RTMPNetStreamMetrics;
      }
   }
}

