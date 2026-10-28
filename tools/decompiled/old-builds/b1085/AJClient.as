package
{
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.FileServerEvent;
   import com.sbi.loader.LoaderCache;
   import com.sbi.loader.ResourceStack;
   import createAccountFlow.CreateAccount;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.UncaughtErrorEvent;
   import flash.external.ExternalInterface;
   import flash.ui.Mouse;
   import gamePlayFlow.GamePlay;
   import gui.DarkenManager;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import resource.FetchClientIPResourceStackable;
   import resource.LoadAvatarCarouselResourceStackable;
   import resource.LoadCursorResourceStackable;
   import room.DebugGUITextbox;
   import waitingRoomFlow.WaitingRoom;
   
   [SWF(width="900", height="550", backgroundColor="#393625", frameRate="24")]
   public class AJClient extends Sprite
   {
      
      private static var _globalErrorDebugTxt:DebugGUITextbox;
      
      private var _resourceStackLoader:ResourceStack;
      
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
         var _loc3_:Object = null;
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
               _loc3_ = parent.loaderInfo.parameters;
            }
            else
            {
               _loc3_ = loaderInfo.parameters;
            }
            MainFrame.handleLocalExternalCall = GamePlay.handleLocalExternalCall;
            MainFrame.getInstance(_loc3_,this.setupInit,"",this);
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
         LoaderCache.clientIp = gMainFrame.clientInfo.clientIp;
         gMainFrame.stage.addEventListener("Localization",LocalizationManager.onLocalizationEvent,false,0,true);
         var _loc1_:DefPacksDefHelper = new DefPacksDefHelper();
         LocalizationManager.currentLanguage = LocalizationManager.accountLanguage = LocalizationManager.getLanguageIdForLocale(gMainFrame.clientInfo.locale);
         _loc1_.init(uint(DefPacksDefHelper.DEF_LOCALIZATION + "" + LocalizationManager.currentLanguage),LocalizationXtCommManager.onLocalizationListResponse,this.loadResourceItems,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LOCALIZATION + "" + LocalizationManager.currentLanguage] = _loc1_;
         _loc1_ = new DefPacksDefHelper();
         _loc1_.init(uint(DefPacksDefHelper.DEF_PREFERRED_LOCALIZATION + "" + LocalizationManager.accountLanguage),LocalizationXtCommManager.onPreferredLocalizationListResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PREFERRED_LOCALIZATION + "" + LocalizationManager.accountLanguage] = _loc1_;
      }
      
      public function loadResourceItems() : void
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
            SBTracker.trackPageview("/game/play/homepage/" + gMainFrame.clientInfo.landingPage,0,SBTracker.TYPE_EVENT);
         }
         var _loc1_:CreateAccount = new CreateAccount(gMainFrame.clientInfo);
         addChild(_loc1_);
         gMainFrame.createAccount = _loc1_;
         _loc1_.loginCtorHelper();
      }
      
      public function setupWaitingRoom() : void
      {
         var _loc1_:WaitingRoom = new WaitingRoom(gMainFrame.clientInfo);
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
            this._resourceStackLoader = null;
         }
         var _loc3_:GamePlay = new GamePlay(gMainFrame.clientInfo,param1,param2);
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

