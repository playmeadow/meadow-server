package org.osmf.net.httpstreaming
{
   import org.osmf.net.SwitchingRuleBase;
   
   [ExcludeClass]
   public class DownloadRatioRule extends SwitchingRuleBase
   {
      
      private var aggressiveUpswitch:Boolean = false;
      
      public function DownloadRatioRule(metrics:HTTPNetStreamMetrics, aggressiveUpswitch:Boolean = true)
      {
         super(metrics);
         this.aggressiveUpswitch = aggressiveUpswitch;
      }
      
      override public function getNewIndex() : int
      {
         var switchRatio:Number = NaN;
         var proposedIndex:int = -1;
         if(this.httpMetrics.downloadRatio < 1)
         {
            if(this.httpMetrics.currentIndex > 0)
            {
               switchRatio = this.getSwitchRatio(this.httpMetrics.currentIndex - 1);
               if(this.httpMetrics.downloadRatio < switchRatio)
               {
                  proposedIndex = 0;
               }
               else
               {
                  proposedIndex = this.httpMetrics.currentIndex - 1;
               }
            }
         }
         else if(this.httpMetrics.currentIndex < this.httpMetrics.maxAllowedIndex)
         {
            switchRatio = this.getSwitchRatio(this.httpMetrics.currentIndex + 1);
            if(this.httpMetrics.downloadRatio >= switchRatio)
            {
               if(this.httpMetrics.downloadRatio > 100 || !this.aggressiveUpswitch)
               {
                  proposedIndex = this.httpMetrics.currentIndex + 1;
               }
               else
               {
                  while(++proposedIndex < this.httpMetrics.maxAllowedIndex + 1)
                  {
                     switchRatio = this.getSwitchRatio(proposedIndex);
                     if(this.httpMetrics.downloadRatio < switchRatio)
                     {
                        break;
                     }
                  }
                  proposedIndex--;
               }
            }
         }
         return proposedIndex;
      }
      
      private function getSwitchRatio(index:int) : Number
      {
         return this.httpMetrics.getBitrateForIndex(index) / this.httpMetrics.getBitrateForIndex(metrics.currentIndex);
      }
      
      private function get httpMetrics() : HTTPNetStreamMetrics
      {
         return metrics as HTTPNetStreamMetrics;
      }
   }
}

