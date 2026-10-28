package com.sbi.analytics
{
   import libraries.uanalytics.tracker.WebTracker;
   import libraries.uanalytics.tracking.Configuration;
   
   public class GATracker
   {
      
      private static var _tracker:WebTracker;
      
      public function GATracker()
      {
         super();
      }
      
      public static function init() : void
      {
         var _loc2_:Configuration = new Configuration();
         _loc2_.enableThrottling = true;
         _loc2_.forcePOST = true;
         var _loc1_:String = (gMainFrame.clientInfo.websiteURL as String).indexOf("stage") != -1 ? "UA-55037062-1" : "UA-16265056-4";
         _tracker = new WebTracker(_loc1_,_loc2_);
      }
      
      public static function trackError(param1:String, param2:Boolean) : Boolean
      {
         return _tracker.exception(param1,param2);
      }
   }
}

