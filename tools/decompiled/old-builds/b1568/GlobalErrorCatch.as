package
{
   import com.sbi.analytics.GATracker;
   import com.sbi.debug.DebugUtility;
   import flash.desktop.Clipboard;
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   
   public class GlobalErrorCatch
   {
      
      public function GlobalErrorCatch()
      {
         super();
      }
      
      public static function globalErrorListener(param1:UncaughtErrorEvent) : void
      {
         var _loc4_:UncaughtErrorEvent = UncaughtErrorEvent(param1);
         var _loc2_:Boolean = gMainFrame.clientInfo.accountType == 4 || gMainFrame.clientInfo.extCallsActive;
         var _loc5_:String = "Default";
         if(_loc4_)
         {
            if(!_loc2_)
            {
               _loc4_.preventDefault();
            }
            if(_loc4_.error is Error)
            {
               _loc5_ = Error(_loc4_.error).message + _loc4_.error.toString() + "\n";
               _loc5_ = _loc4_.error.getStackTrace();
            }
            else if(_loc4_.error is ErrorEvent)
            {
               _loc5_ = ErrorEvent(_loc4_.error).text + _loc4_.error.toString();
               _loc5_ = _loc5_ + "\n This is an ErrorEvent";
            }
            else
            {
               _loc5_ = _loc4_.error.toString();
               _loc5_ = _loc5_ + ("\n This is not an Error or Error event: " + _loc4_.error);
            }
            if(_loc2_)
            {
               if(ExternalInterface.available)
               {
                  if(gMainFrame.clientInfo.clientPlatform.toLowerCase() == "electron")
                  {
                     ExternalInterface.call("console.log",_loc5_);
                  }
                  else
                  {
                     ExternalInterface.call("alert",_loc5_);
                  }
               }
               else
               {
                  AJClient.globalErrorDebugTxt.setVisibility(true);
                  Clipboard.generalClipboard.clear();
                  Clipboard.generalClipboard.setData("air:text",_loc5_);
               }
            }
         }
         var _loc3_:String = DebugUtility.getTrackedDebugStatements();
         if(_loc3_.length > 0)
         {
            _loc3_ = "\n\nTracked Debug Statements:\n" + _loc3_;
         }
         var _loc6_:String = AJClient.globalErrorDebugTxt.text;
         if(_loc6_.length > 0)
         {
            _loc6_ = "\n\n" + _loc6_;
         }
         AJClient.globalErrorDebugTxt.text = "[" + new Date().toString() + "]\n" + _loc5_ + _loc3_ + _loc6_;
         GATracker.trackError(_loc5_ + _loc3_,false);
      }
   }
}

