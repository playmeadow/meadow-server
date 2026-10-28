package resource
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.IResourceStackable;
   import com.sbi.loader.LoaderCache;
   import com.sbi.popup.SBStandardPopupLoaded;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import localization.LocalizationManager;
   
   public class FetchClientIPResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      
      public static const GET_CLIENT_IP_URL:String = "http://www.icanhazip.com/";
      
      public function FetchClientIPResourceStackable()
      {
         super();
      }
      
      override public function init(param1:Function) : void
      {
         var _loc4_:* = null;
         var _loc2_:String = null;
         super.init(param1);
         var _loc3_:String = gMainFrame.clientInfo.clientIp;
         if(_loc3_ != null && _loc3_ != "")
         {
            DebugUtility.debugTrace("FetchClientIPResourceStackable init() - clientIpStr:" + _loc3_);
            saveClientIp(_loc3_);
         }
         else
         {
            DebugUtility.debugTrace("ERROR: FetchClientIPResourceStackable init() - non-debug/localdevtest environment is missing myExternalIp flashvar!",16711680);
            _loc2_ = LocalizationManager.translateIdOnly(11149) + " (CLIENTIPERR)";
            new SBStandardPopupLoaded(gMainFrame.stage,_loc2_,false,false);
         }
      }
      
      private function clientIpFetchCompleteHandler(param1:Event) : void
      {
         var _loc2_:String = param1.target.data;
         DebugUtility.debugTrace("my ip is:" + _loc2_);
         if(_loc2_ == "")
         {
            DebugUtility.debugTrace("ERROR: FetchClientIPResourceStackable clientIpFetchCompleteHandler() - getClientIp result was empty!",16711680);
            return;
         }
         gMainFrame.clientInfo.clientIp = _loc2_;
         saveClientIp(_loc2_);
      }
      
      private function saveClientIp(param1:String) : void
      {
         LoaderCache.clientIp = param1;
         DebugUtility.debugTrace("saveClientIp - LoaderCache.clientIp:" + LoaderCache.clientIp);
         super._resourceDoneLoadingCallback(this);
      }
   }
}

