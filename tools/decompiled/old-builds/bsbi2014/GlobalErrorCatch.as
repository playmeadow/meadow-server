package
{
   import flash.events.ErrorEvent;
   import flash.events.UncaughtErrorEvent;
   import flash.system.Capabilities;
   
   public class GlobalErrorCatch
   {
      
      public function GlobalErrorCatch()
      {
         super();
      }
      
      public static function setupGlobalErrorListener(evt:UncaughtErrorEvent) : String
      {
         var message:String = null;
         var ucEvt:UncaughtErrorEvent = UncaughtErrorEvent(evt);
         var showErrors:Boolean = gMainFrame.clientInfo.accountType == Utility.INTERNAL;
         showErrors = true;
         if(Boolean(ucEvt))
         {
            if(!showErrors)
            {
               ucEvt.preventDefault();
            }
            if(ucEvt.error is Error)
            {
               if(Capabilities.isDebugger)
               {
                  message = Error(ucEvt.error).getStackTrace();
               }
               else
               {
                  message = Error(ucEvt.error).message;
               }
            }
            else if(ucEvt.error is ErrorEvent)
            {
               message = ErrorEvent(ucEvt.error).text;
            }
            else
            {
               message = ucEvt.error.toString();
            }
         }
         return message;
      }
   }
}

