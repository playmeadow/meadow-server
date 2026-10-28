package
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.ResourceStack;
   import createAccountFlow.CreateAccount;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.ui.Mouse;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import resource.FetchClientIPResourceStackable;
   import resource.LoadAvatarCarouselResourceStackable;
   import resource.LoadCursorResourceStackable;
   import resource.LoadIntro;
   import room.DebugGUITextbox;
   import waitingRoomFlow.WaitingRoom;
   
   [SWF(width="900", height="550", backgroundColor="#393625", frameRate="24")]
   public class AJClient extends Sprite
   {
      
      private static var _globalErrorDebugTxt:DebugGUITextbox;
      
      private var _resourceStackLoader:ResourceStack;
      
      private var _intro:LoadIntro;
      
      private var _flashvars:Object;
      
      public function AJClient()
      {
         super();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
      }
      
      public static function get globalErrorDebugTxt() : DebugGUITextbox
      {
         return _globalErrorDebugTxt;
      }
      
      private static function handleGlobalErrors(param1:UncaughtErrorEvent) : void
      {
         _globalErrorDebugTxt.text = GlobalErrorCatch.setupGlobalErrorListener(param1);
      }
      
      private function addedToStageHandler(param1:Event) : void
      {
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         var _loc2_:Boolean = ExternalInterface.available;
         if(_loc2_)
         {
            DebugUtility.debugTrace("addedToStageHandler extIntAvail is true");
            DebugUtility.debugTrace("mrc dm init ctor starting up call returned:" + ExternalInterface.call("mrc",["dm","AJClient addedToStageHandler starting up"]));
         }
         else
         {
            DebugUtility.debugTrace("addedToStageHandler extIntAvail is false");
         }
         if(!MainFrame.isInitialized())
         {
            if(parent != null)
            {
               this._flashvars = parent.loaderInfo.parameters;
            }
            else
            {
               this._flashvars = loaderInfo.parameters;
            }
            MainFrame.handleLocalExternalCall = GamePlay.handleLocalExternalCall;
            MainFrame.getInstance(this._flashvars,this.setupInit,"",this);
            _globalErrorDebugTxt = new DebugGUITextbox();
            _globalErrorDebugTxt.init(this,"Global Error Catcher Initialized",false,true,true,600);
            _globalErrorDebugTxt.txt.textColor = 2236962;
            _globalErrorDebugTxt.x = 222;
            _globalErrorDebugTxt.y = 300;
            if(loaderInfo.hasOwnProperty("uncaughtErrorEvents"))
            {
               loaderInfo["uncaughtErrorEvents"].addEventListener("uncaughtError",handleGlobalErrors);
            }
         }
         DebugUtility.debugTrace("AJClient addedToStageHandler finished");
      }
      
      public function setupInit() : void
      {
         Utility.init(DarkenManager.showLoadingSpiral,DarkenManager.darken,DarkenManager.unDarken);
         this._resourceStackLoader = new ResourceStack(gMainFrame.path,gMainFrame.loaderCache.openFile);
         this._resourceStackLoader.pushClass(new FetchClientIPResourceStackable(),true);
         this._resourceStackLoader.pushFile("assets/sharedFonts.swf",true);
         this._resourceStackLoader.pushFile("assets/HUDAssets.swf",true);
         this._resourceStackLoader.pushClass(new LoadAvatarCarouselResourceStackable());
         if(Mouse["supportsNativeCursor"])
         {
            this._resourceStackLoader.pushClass(new LoadCursorResourceStackable());
         }
         if(gMainFrame.clientInfo.isCreateAccount)
         {
            this._resourceStackLoader.start(this.setupCreateAccount);
         }
         else if(gMainFrame.clientInfo.waitingMode)
         {
            this._resourceStackLoader.start(this.setupWaitingRoom);
         }
         else
         {
            this._resourceStackLoader.start(this.setupGamePlay);
         }
      }
      
      public function setupCreateAccount() : void
      {
         if(gMainFrame.clientInfo.landingPage != "undefined")
         {
            SBTracker.trackPageview("/game/play/homepage/" + gMainFrame.clientInfo.landingPage,0);
         }
         var _loc1_:CreateAccount = new CreateAccount(this._flashvars);
         addChild(_loc1_);
         gMainFrame.createAccount = _loc1_;
         _loc1_.loginCtorHelper();
         this._intro = new LoadIntro();
         this._intro.init(_loc1_.setIntro);
      }
      
      public function setupWaitingRoom() : void
      {
         var _loc1_:WaitingRoom = new WaitingRoom(this._flashvars);
         addChild(_loc1_);
         gMainFrame.waitingRoom = _loc1_;
         _loc1_.waitCtorHelper();
      }
      
      public function setupGamePlay(param1:Event = null, param2:Event = null) : void
      {
         if(gMainFrame.createAccount)
         {
            if(contains(gMainFrame.createAccount))
            {
               removeChild(gMainFrame.createAccount);
            }
            gMainFrame.createAccount = null;
            this._intro = null;
            this._resourceStackLoader = null;
         }
         var _loc3_:GamePlay = new GamePlay(this._flashvars,param1,param2);
         addChild(_loc3_);
         gMainFrame.gamePlay = _loc3_;
         _loc3_.worldCtorHelper();
      }
      
      private function createAvatar() : void
      {
      }
      
      private function shardSelection() : void
      {
      }
      
      private function enterGame() : void
      {
      }
   }
}

