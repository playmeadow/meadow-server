package waitingRoomFlow
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.IResourceStackable;
   import flash.events.Event;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import resource.BaseResourceStackable;
   
   public class ConnectToWaitingRoomServerResourceStackable extends BaseResourceStackable implements IResourceStackable
   {
      
      private var _username:String;
      
      public function ConnectToWaitingRoomServerResourceStackable(initUsername:String)
      {
         super();
         this._username = initUsername;
      }
      
      override public function init(callback:Function) : void
      {
         var r:URLLoader = null;
         super.init(callback);
         try
         {
            r = new URLLoader();
            r.dataFormat = URLLoaderDataFormat.TEXT;
            r.addEventListener(Event.COMPLETE,this.connectCompleteHandler,false,0,true);
            DebugUtility.debugTrace("ConnectToWaitingRoomServerResourceStackable init() - connect url:http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/connect username:" + this._username);
            r.load(new URLRequest("http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/connect"));
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error connecting to waitingRoom server:" + e.getStackTrace());
            LoadProgress.show(true,"Error waiting for full server - please try again later");
            return;
         }
      }
      
      private function connectCompleteHandler(e:Event) : void
      {
         var statusString:String = e.target.data;
         DebugUtility.debugTrace("my status is:" + statusString);
         if(statusString == "")
         {
            LoadProgress.show(true,"Error connecting to waiting room server - please try again later");
            return;
         }
         super._resourceDoneLoadingCallback(this);
      }
   }
}

