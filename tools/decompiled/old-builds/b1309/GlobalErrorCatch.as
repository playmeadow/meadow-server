package
{
   import com.sbi.analytics.GATracker;
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   
   public class GlobalErrorCatch
   {
      
      public function GlobalErrorCatch()
      {
         super();
      }
      
      public static function setupGlobalErrorListener(param1:UncaughtErrorEvent) : String
      {
         var _loc3_:UncaughtErrorEvent = UncaughtErrorEvent(param1);
         var _loc2_:Boolean = gMainFrame.clientInfo.accountType == 4;
         var _loc4_:String = "Default";
         if(_loc3_)
         {
            if(!_loc2_)
            {
               _loc3_.preventDefault();
            }
            if(_loc3_.error is Error)
            {
               _loc4_ = _loc3_.error.getStackTrace();
            }
            else if(_loc3_.error is ErrorEvent)
            {
               _loc4_ = ErrorEvent(_loc3_.error).text;
               _loc4_ = _loc4_ + "\n This is an ErrorEvent";
               _loc4_ = _loc4_ + ("\n" + DebugUtility.getTrackedDebugStatements());
            }
            else
            {
               _loc4_ = _loc3_.error.toString();
               _loc4_ = _loc4_ + ("\n This is not an Error or Error event: " + _loc3_.error);
            }
         }
         GATracker.trackError(_loc4_,false);
         return _loc4_;
      }
   }
}

