package waitingRoomFlow
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.ResourceStack;
   import flash.display.MovieClip;
   import flash.display.StageQuality;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.system.Security;
   import flash.utils.Timer;
   
   public class WaitingRoom extends MovieClip
   {
      
      public var mainLayer:DisplayLayer;
      
      public var loadLayer:DisplayLayer;
      
      private var _waitingRoomFlashVars:Object;
      
      private var _resourceStack:ResourceStack;
      
      private var _pollTimer:Timer;
      
      private var _username:String;
      
      private var _waitingRoom:MovieClip;
      
      public function WaitingRoom(param1:Object)
      {
         super();
         this._waitingRoomFlashVars = param1;
      }
      
      public function waitCtorHelper() : void
      {
         this.init();
      }
      
      public function init() : void
      {
         Security.allowDomain("*");
         this._username = this._waitingRoomFlashVars.username;
         this.mainLayer = new DisplayLayer();
         addChild(this.mainLayer);
         this._resourceStack = new ResourceStack(gMainFrame.path,gMainFrame.loaderCache.openFile);
         this._resourceStack.pushClass(new ConnectToWaitingRoomServerResourceStackable(this._username),false);
         this._resourceStack.pushClass(new LoadWaitingRoomMediaResourceStackable(this.setWaitingRoomMovieClip),false);
         this._resourceStack.start(this.waitingRoomSetupDone);
         this.loadLayer = new DisplayLayer();
         addChild(this.loadLayer);
         LoadProgress.init(this.loadLayer);
         gMainFrame.stage.quality = StageQuality.MEDIUM;
      }
      
      public function destroy() : void
      {
         this._pollTimer.reset();
         this._pollTimer = null;
      }
      
      public function setWaitingRoomMovieClip(param1:MovieClip) : void
      {
         this._waitingRoom = param1;
         this.mainLayer.addChild(this._waitingRoom);
      }
      
      private function waitingRoomSetupDone() : void
      {
         DebugUtility.debugTrace("waitingRoom setup done - starting poll timer");
         this._pollTimer = new Timer(5000);
         this._pollTimer.addEventListener(TimerEvent.TIMER,this.handleWaitingRoomPollTimer);
         this._pollTimer.start();
         LoadProgress.show(false);
      }
      
      private function handleWaitingRoomPollTimer(param1:TimerEvent) : void
      {
         var r:URLLoader = null;
         var t:TimerEvent = param1;
         try
         {
            r = new URLLoader();
            r.dataFormat = URLLoaderDataFormat.TEXT;
            r.addEventListener(Event.COMPLETE,this.pollCompleteHandler,false,0,true);
            DebugUtility.debugTrace("ConnectToWaitingRoomServerResourceStackable init() - connect url:http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/poll username:" + this._username);
            r.load(new URLRequest("http://" + gMainFrame.clientInfo.waitingRoomServerAddress + ":" + gMainFrame.clientInfo.waitingRoomServerPort + "/poll"));
         }
         catch(e:Error)
         {
            DebugUtility.debugTrace("error polling waitingRoom server:" + e.getStackTrace());
            LoadProgress.show(true,"Error polling for full server - please try again later");
            _pollTimer.reset();
            return;
         }
      }
      
      private function pollCompleteHandler(param1:Event) : void
      {
         var _loc2_:String = param1.target.data;
         if(_loc2_ == "")
         {
            LoadProgress.show(true,"Error with poll of waiting room server - please try again later");
            return;
         }
         if(_loc2_ == "enter")
         {
            LoadProgress.show(true,"Ready- please refresh to log in now!");
         }
      }
   }
}

