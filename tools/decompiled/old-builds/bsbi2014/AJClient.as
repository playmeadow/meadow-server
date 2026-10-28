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
   [SWF(width="900",height="550",backgroundColor="#00393625",frameRate="24")]
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
      
      private static function handleGlobalErrors(evt:UncaughtErrorEvent) : void
      {
         _globalErrorDebugTxt.text = GlobalErrorCatch.setupGlobalErrorListener(evt);
      }
      
      private function addedToStageHandler(e:Event) : void
      {
         var flashvars:Object = null;
         var i:int = 0;
         var k:String = null;
         removeEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
         var extIntAvail:Boolean = ExternalInterface.available;
         if(extIntAvail)
         {
            DebugUtility.debugTrace("addedToStageHandler - extIntAvail is true");
            DebugUtility.debugTrace("mrc dm init ctor starting up call returned:" + ExternalInterface.call("mrc",["dm","AJClient addedToStageHandler starting up"]));
         }
         else
         {
            DebugUtility.debugTrace("addedToStageHandler - extIntAvail is false");
         }
         if(!MainFrame.isInitialized())
         {
            if(parent != null)
            {
               flashvars = parent.loaderInfo.parameters;
            }
            else
            {
               flashvars = loaderInfo.parameters;
            }
            DebugUtility.debugTrace("addedToStageHandler - printing loaderInfo parameters flashvars...");
            i = 0;
            for(k in flashvars)
            {
               DebugUtility.debugTrace("  flashvar " + k + ":" + flashvars[k]);
               i++;
            }
            DebugUtility.debugTrace("addedToStageHandler - ...done printing loaderInfo parameters flashvars - i:" + i);
            MainFrame.handleLocalExternalCall = GamePlay.handleLocalExternalCall;
            MainFrame.getInstance(flashvars,this.setupInit,"",this);
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
         LoaderCache.clientIp = String(gMainFrame.clientInfo.clientIp);
         gMainFrame.stage.addEventListener("Localization",LocalizationManager.onLocalizationEvent,false,0,true);
         var dpdh:DefPacksDefHelper = new DefPacksDefHelper();
         LocalizationManager.currentLanguage = LocalizationManager.accountLanguage = LocalizationManager.getLanguageIdForLocale(gMainFrame.clientInfo.locale);
         dpdh.init(uint(DefPacksDefHelper.DEF_LOCALIZATION + "" + LocalizationManager.currentLanguage),LocalizationXtCommManager.onLocalizationListResponse,this.loadResourceItems,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_LOCALIZATION + "" + LocalizationManager.currentLanguage] = dpdh;
         dpdh = new DefPacksDefHelper();
         dpdh.init(uint(DefPacksDefHelper.DEF_PREFERRED_LOCALIZATION + "" + LocalizationManager.accountLanguage),LocalizationXtCommManager.onPreferredLocalizationListResponse,null,FileServerEvent.AMF3_TYPE);
         DefPacksDefHelper.mediaArray[DefPacksDefHelper.DEF_PREFERRED_LOCALIZATION + "" + LocalizationManager.accountLanguage] = dpdh;
      }
      
      public function loadResourceItems() : void
      {
         Utility.init(DarkenManager.showLoadingSpiral,DarkenManager.darken,DarkenManager.unDarken);
         this._resourceStackLoader = new ResourceStack(gMainFrame.path,gMainFrame.loaderCache.openFile);
         this._resourceStackLoader.pushClass(new FetchClientIPResourceStackable(),true);
         this._resourceStackLoader.pushFile("assets/sharedFonts.swf",true);
         this._resourceStackLoader.pushFile("assets/HUDAssets.swf",true);
         if(Boolean(gMainFrame.clientInfo.isCreateAccount))
         {
            this._resourceStackLoader.pushClass(new LoadAvatarCarouselResourceStackable());
         }
         if(Boolean(Mouse["supportsNativeCursor"]))
         {
            this._resourceStackLoader.pushClass(new LoadCursorResourceStackable());
         }
         if(Boolean(gMainFrame.clientInfo.isCreateAccount))
         {
            this._resourceStackLoader.start(this.setupCreateAccount);
         }
         else if(Boolean(gMainFrame.clientInfo.waitingMode))
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
         var ca:CreateAccount = new CreateAccount(gMainFrame.clientInfo);
         addChild(ca);
         gMainFrame.createAccount = ca;
         ca.loginCtorHelper();
      }
      
      public function setupWaitingRoom() : void
      {
         var wr:WaitingRoom = new WaitingRoom(gMainFrame.clientInfo);
         addChild(wr);
         gMainFrame.waitingRoom = wr;
         wr.waitCtorHelper();
      }
      
      public function setupGamePlay(loginEvt:Event = null, connectEvt:Event = null) : void
      {
         DebugUtility.debugTrace("setupGamePlay - loginEvt:" + loginEvt + " connectEvt:" + connectEvt);
         if(Boolean(gMainFrame.createAccount))
         {
            if(contains(gMainFrame.createAccount))
            {
               removeChild(gMainFrame.createAccount);
            }
            gMainFrame.createAccount = null;
            this._resourceStackLoader = null;
         }
         DebugUtility.debugTrace("setupGamePlay - constructing GamePlay - gMainFrame.clientInfo:" + gMainFrame.clientInfo);
         var gp:GamePlay = new GamePlay(gMainFrame.clientInfo,loginEvt,connectEvt);
         addChild(gp);
         gMainFrame.gamePlay = gp;
         DebugUtility.debugTrace("setupGamePlay - gp:" + gp + " calling worldCtorHelper");
         gp.worldCtorHelper();
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

