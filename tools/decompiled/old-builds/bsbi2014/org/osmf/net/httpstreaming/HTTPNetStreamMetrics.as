package org.osmf.net.httpstreaming
{
   import org.osmf.net.NetStreamMetricsBase;
   
   [ExcludeClass]
   public class HTTPNetStreamMetrics extends NetStreamMetricsBase
   {
      
      private var httpNetStream:HTTPNetStream;
      
      public function HTTPNetStreamMetrics(netStream:HTTPNetStream)
      {
         super(netStream);
         this.httpNetStream = netStream;
      }
      
      public function get downloadRatio() : Number
      {
         return this.httpNetStream.downloadRatio;
      }
      
      public function getBitrateForIndex(index:int) : Number
      {
         return this.resource.streamItems[index].bitrate;
      }
   }
}

