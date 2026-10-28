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
      
      override public function init(callback:Function) : void
      {
         var clientIpStr:String;
         var r:URLLoader = null;
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
      
      private function clientIpFetchCompleteHandler(e:Event) : void
      {
         var ipString:String = e.target.data;
         DebugUtility.debugTrace("my ip is:" + ipString);
         if(ipString == "")
         {
            LoadProgress.show(true,"Error - please try again later");
            return;
         }
         gMainFrame.clientInfo.clientIp = ipString;
         this.saveClientIp(ipString);
      }
      
      private function saveClientIp(confirmedIpString:String) : void
      {
         LoaderCache.clientIp = confirmedIpString;
         DebugUtility.debugTrace("saveClientIp - LoaderCache.clientIp:" + LoaderCache.clientIp);
         super._resourceDoneLoadingCallback(this);
      }
   }
}

