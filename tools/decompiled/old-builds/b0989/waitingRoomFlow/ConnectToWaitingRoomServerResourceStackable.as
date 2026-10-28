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
      
      public function ConnectToWaitingRoomServerResourceStackable(param1:String)
      {
         super();
         this._username = param1;
      }
      
      override public function init(param1:Function) : void
      {
         var r:URLLoader = null;
         var callback:Function = param1;
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
      
      private function connectCompleteHandler(param1:Event) : void
      {
         var _loc2_:String = param1.target.data;
         DebugUtility.debugTrace("my status is:" + _loc2_);
         if(_loc2_ == "")
         {
            LoadProgress.show(true,"Error connecting to waiting room server - please try again later");
            return;
         }
         super._resourceDoneLoadingCallback(this);
      }
   }
}

