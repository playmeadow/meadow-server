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
         var _loc4_:String = null;
         var _loc2_:UncaughtErrorEvent = UncaughtErrorEvent(param1);
         var _loc3_:Boolean = gMainFrame.clientInfo.accountType == SbiConstants.INTERNAL;
         if(_loc2_)
         {
            if(!_loc3_)
            {
               _loc2_.preventDefault();
            }
            if(_loc2_.error is Error)
            {
               if(Capabilities.isDebugger)
               {
                  _loc4_ = Error(_loc2_.error).getStackTrace();
               }
               else
               {
                  _loc4_ = Error(_loc2_.error).message;
               }
            }
            else if(_loc2_.error is ErrorEvent)
            {
               _loc4_ = ErrorEvent(_loc2_.error).text;
            }
            else
            {
               _loc4_ = _loc2_.error.toString();
            }
         }
         return _loc4_;
      }
   }
}

