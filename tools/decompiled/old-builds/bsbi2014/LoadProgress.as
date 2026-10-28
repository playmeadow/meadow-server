package
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.loader.LoaderCacheEntry_Base;
   import com.sbi.loader.LoaderEvent;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.utils.ByteArray;
   import localization.LocalizationManager;
   
   public class LoadProgress
   {
      
      private static var _entry:LoaderCacheEntry_Base;
      
      private static var _loadScreen:Loader;
      
      private static var _loadLayer:DisplayObjectContainer;
      
      private static var _completeCallback:Function;
      
      private static var _target:String;
      
      private static var _displayTarget:String;
      
      private static var _bChangeLoadingScreen:Boolean;
      
      private static var _progressCounter:int;
      
      private static var _visible:Boolean;
      
      public static const INITIALIZING:int = 1;
      
      public static const LOADING_GAMES:int = 2;
      
      public static const LOADING_ANIMALS:int = 3;
      
      public static const LOADING_WORLDMAP:int = 4;
      
      public static const FINDING_ROOM:int = 5;
      
      public static const LOADING_ROOM:int = 6;
      
      public static const JOINING_SERVER:int = 7;
      
      private static const LoadScreenSWF:Class = LoadProgress_LoadScreenSWF;
      
      public function LoadProgress()
      {
         super();
      }
      
      public static function get loadScreen() : Loader
      {
         return _loadScreen;
      }
      
      public static function get entry() : LoaderCacheEntry_Base
      {
         return _entry;
      }
      
      public static function get loadLayer() : DisplayObjectContainer
      {
         return _loadLayer;
      }
      
      public static function get visible() : Boolean
      {
         return _visible;
      }
      
      public static function init(initLoadLayer:DisplayObjectContainer) : void
      {
         var ba:ByteArray = null;
         if(_loadScreen == null)
         {
            _bChangeLoadingScreen = true;
            _progressCounter = 0;
            _loadLayer = initLoadLayer;
            _loadScreen = new Loader();
            _loadScreen.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadScreenComplete);
            ba = ByteArray(new LoadScreenSWF());
            _loadScreen.loadBytes(ba);
         }
      }
      
      public static function show(bShow:Boolean, displayString:Object = null) : void
      {
         var mc:MovieClip = null;
         if(bShow)
         {
            _visible = true;
            mc = MovieClip(_loadScreen.content);
            if(!loadLayer.contains(_loadScreen))
            {
               loadLayer.addChild(_loadScreen);
            }
            if(Boolean(mc) && _bChangeLoadingScreen)
            {
               mc.showScreen(true);
               mc.setProgress(_progressCounter);
               if(!LocalizationManager.hasLocalizations)
               {
                  mc.setCallback(onLoadProgressTextChange);
                  mc.textBox.visible = false;
                  mc.loadText.visible = false;
               }
               else
               {
                  mc.setCallback(null);
                  mc.textBox.visible = true;
                  mc.loadText.visible = true;
               }
               _bChangeLoadingScreen = false;
            }
         }
         else if(loadLayer.contains(_loadScreen))
         {
            _visible = false;
            loadLayer.removeChild(_loadScreen);
            _bChangeLoadingScreen = true;
            _progressCounter = 0;
         }
      }
      
      public static function load(loadTarget:String, progress:int, loadCompleteCallback:Function) : void
      {
         _entry = null;
         _completeCallback = loadCompleteCallback;
         _target = gMainFrame.path + loadTarget;
         _progressCounter = progress;
         var mc:MovieClip = MovieClip(_loadScreen.content);
         if(Boolean(mc))
         {
            mc.setProgress(progress);
         }
         DebugUtility.debugTrace("loading target:" + _target);
         if(Boolean(_loadScreen))
         {
            startLoad();
            return;
         }
         throw new Error("preloader was not embedded?!");
      }
      
      private static function onLoadProgressTextChange() : void
      {
         var mc:MovieClip = null;
         if(LocalizationManager.hasLocalizations)
         {
            mc = MovieClip(_loadScreen.content);
            if(Boolean(_loadScreen.content))
            {
               mc.relocalize();
               mc.setCallback(null);
               mc.textBox.visible = true;
               mc.loadText.visible = true;
            }
         }
      }
      
      private static function onLoadScreenComplete(e:Event) : void
      {
         show(true);
      }
      
      private static function startLoad() : void
      {
         show(true);
         gMainFrame.loaderCache.openFile(_target,loadCompleteHandler,loadProgressHandler);
      }
      
      private static function loadCompleteHandler(e:LoaderEvent) : void
      {
         _entry = e.entry;
         if(_completeCallback != null)
         {
            _completeCallback();
         }
      }
      
      private static function loadProgressHandler(evt:LoaderEvent) : void
      {
         if(evt.status && Boolean(_loadScreen))
         {
            return;
         }
         throw new Error("ERROR: Unable to show loading progress! status:" + evt.status + " preloader:" + _loadScreen);
      }
   }
}

