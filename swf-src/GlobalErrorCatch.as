package
{
   import com.sbi.analytics.GATracker;
   import com.sbi.debug.DebugUtility;
   import flash.desktop.Clipboard;
   import flash.display.LoaderInfo;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   
   public class GlobalErrorCatch
   {
      
      public function GlobalErrorCatch()
      {
         super();
      }
      
      private static function describeTarget(param1:Object) : String
      {
         var _loc2_:String = String(param1);
         if(param1 is LoaderInfo)
         {
            _loc2_ += " url=" + LoaderInfo(param1).url + " loaderURL=" + LoaderInfo(param1).loaderURL + " bytes=" + LoaderInfo(param1).bytesTotal;
            if(LoaderInfo(param1).loader && LoaderInfo(param1).loader.parent)
            {
               _loc2_ += " parent=" + LoaderInfo(param1).loader.parent + " name=" + LoaderInfo(param1).loader.parent.name;
            }
         }
         return _loc2_;
      }
      
      public static function reportToServer(param1:String) : void
      {
         var _loc2_:URLRequest = new URLRequest(gMainFrame.clientInfo.websiteURL + "v1/reportError");
         _loc2_.method = "POST";
         _loc2_.contentType = "application/json";
         _loc2_.data = JSON.stringify({
            "section":"swf",
            "message":param1
         });
         var _loc3_:URLLoader = new URLLoader();
         _loc3_.addEventListener("ioError",onReportFailed);
         _loc3_.addEventListener("securityError",onReportFailed);
         _loc3_.load(_loc2_);
      }
      
      private static function onReportFailed(param1:Event) : void
      {
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
               _loc5_ = _loc5_ + ("\n target: " + describeTarget(ErrorEvent(_loc4_.error).target));
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
                  AJClient.globalDebugLog.setVisibility(true);
                  Clipboard.generalClipboard.clear();
                  Clipboard.generalClipboard.setData("air:text",_loc5_);
               }
            }
         }
         reportToServer(_loc4_ ? String(_loc4_.error) + "\n" + _loc5_ : _loc5_);
         var _loc3_:String = DebugUtility.getTrackedDebugStatements();
         if(_loc3_.length > 0)
         {
            DebugUtility.debugTrace("Tracked Debug Statements:\n" + _loc3_);
         }
         DebugUtility.debugTrace(_loc5_,false);
         GATracker.trackError(_loc5_ + _loc3_,false);
      }
   }
}

