package resource
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.IResourceStackable;
   import com.sbi.loader.LoaderCache;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   
   public class FetchClientIPResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      
      public function FetchClientIPResourceStackable()
      {
         super();
      }
      
      override public function init(param1:Function) : void
      {
         var clientIpStr:String;
         var r:URLLoader = null;
         var callback:Function = param1;
         super.init(callback);
         clientIpStr = gMainFrame.clientInfo.clientIp;
         if(clientIpStr != null && clientIpStr != "")
         {
            DebugUtility.debugTrace("FetchClientIPResourceStackable init() - clientIpStr:" + clientIpStr);
            this.saveClientIp(clientIpStr);
         }
         else
         {
            try
            {
               r = new URLLoader();
               r.dataFormat = URLLoaderDataFormat.TEXT;
               r.addEventListener(Event.COMPLETE,this.clientIpFetchCompleteHandler,false,0,true);
               DebugUtility.debugTrace("FetchClientIPResourceStackable init() - getClientIp url:http://" + gMainFrame.server.blueboxServerIp + ":" + gMainFrame.server.blueboxServerPort + "/witI43K/getClientIp");
               r.load(new URLRequest("http://" + gMainFrame.server.blueboxServerIp + ":" + gMainFrame.server.blueboxServerPort + "/witI43K/getClientIp"));
            }
            catch(e:Error)
            {
               DebugUtility.debugTrace("error calling getClientIp:" + e.getStackTrace());
               LoadProgress.show(true,"Error - please try again later");
               return;
            }
         }
      }
      
      private function clientIpFetchCompleteHandler(param1:Event) : void
      {
         var _loc2_:String = param1.target.data;
         DebugUtility.debugTrace("my ip is:" + _loc2_);
         if(_loc2_ == "")
         {
            LoadProgress.show(true,"Error - please try again later");
            return;
         }
         gMainFrame.clientInfo.clientIp = _loc2_;
         this.saveClientIp(_loc2_);
      }
      
      private function saveClientIp(param1:String) : void
      {
         LoaderCache.clientIp = param1;
         DebugUtility.debugTrace("saveClientIp - LoaderCache.clientIp:" + LoaderCache.clientIp);
         super._resourceDoneLoadingCallback(this);
      }
   }
}

