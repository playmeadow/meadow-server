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
      
      public static function setupGlobalErrorListener(param1:UncaughtErrorEvent) : String
      {
         var _loc2_:String = null;
         var _loc3_:UncaughtErrorEvent = UncaughtErrorEvent(param1);
         var _loc4_:Boolean = gMainFrame.clientInfo.accountType == 4;
         if(_loc3_)
         {
            if(!_loc4_)
            {
               _loc3_.preventDefault();
            }
            if(_loc3_.error is Error)
            {
               if(Capabilities.isDebugger)
               {
                  _loc2_ = Error(_loc3_.error).getStackTrace();
               }
               else
               {
                  _loc2_ = Error(_loc3_.error).message;
               }
            }
            else if(_loc3_.error is ErrorEvent)
            {
               _loc2_ = ErrorEvent(_loc3_.error).text;
            }
            else
            {
               _loc2_ = _loc3_.error.toString();
            }
         }
         return _loc2_;
      }
   }
}

