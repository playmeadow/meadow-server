package
{
   import com.sbi.analytics.GATracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import gui.GuiManager;
   
   public class GlobalErrorCatch
   {
      
      public function GlobalErrorCatch()
      {
         super();
      }
      
      public static function setupGlobalErrorListener(param1:UncaughtErrorEvent) : String
      {
         var _loc3_:UncaughtErrorEvent = UncaughtErrorEvent(param1);
         var _loc4_:Boolean = gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.extCallsActive;
         var _loc2_:String = "Default";
         if(_loc3_)
         {
            if(!_loc4_)
            {
               _loc3_.preventDefault();
            }
            if(_loc3_.error is Error)
            {
               _loc2_ = Error(_loc3_.error).message + _loc3_.error.toString() + "\n";
               _loc2_ = _loc3_.error.getStackTrace();
            }
            else if(_loc3_.error is ErrorEvent)
            {
               _loc2_ = ErrorEvent(_loc3_.error).text + _loc3_.error.toString();
               _loc2_ += "\n This is an ErrorEvent";
            }
            else
            {
               _loc2_ = _loc3_.error.toString();
               _loc2_ += "\n This is not an Error or Error event: " + _loc3_.error;
            }
            if(_loc4_)
            {
               new SBOkPopup(GuiManager.guiLayer,"Caught an error with the following message:\n" + _loc2_);
            }
         }
         _loc2_ += "\n" + DebugUtility.getTrackedDebugStatements();
         GATracker.trackError(_loc2_,false);
         return _loc2_;
      }
   }
}

