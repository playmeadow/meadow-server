package org.osmf.net
{
   public class SwitchingRuleBase
   {
      
      private var _metrics:NetStreamMetricsBase;
      
      public function SwitchingRuleBase(metrics:NetStreamMetricsBase)
      {
         super();
         this._metrics = metrics;
      }
      
      public function getNewIndex() : int
      {
         return -1;
      }
      
      protected function get metrics() : NetStreamMetricsBase
      {
         return this._metrics;
      }
   }
}

