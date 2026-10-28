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
      
      public static function init(param1:DisplayObjectContainer) : void
      {
         var _loc2_:ByteArray = null;
         if(_loadScreen == null)
         {
            _bChangeLoadingScreen = true;
            _progressCounter = 0;
            _loadLayer = param1;
            _loadScreen = new Loader();
            _loadScreen.contentLoaderInfo.addEventListener(Event.COMPLETE,onLoadScreenComplete);
            _loc2_ = ByteArray(new LoadScreenSWF());
            _loadScreen.loadBytes(_loc2_);
         }
      }
      
      public static function show(param1:Boolean, param2:Object = null) : void
      {
         var _loc3_:MovieClip = null;
         if(param1)
         {
            _loc3_ = MovieClip(_loadScreen.content);
            if(Boolean(_loc3_) && _bChangeLoadingScreen)
            {
               _loc3_.showScreen(true);
               _loc3_.setProgress(_progressCounter);
               _bChangeLoadingScreen = false;
            }
            if(!loadLayer.contains(_loadScreen))
            {
               loadLayer.addChild(_loadScreen);
            }
         }
         else if(loadLayer.contains(_loadScreen))
         {
            loadLayer.removeChild(_loadScreen);
            _bChangeLoadingScreen = true;
            _progressCounter = 0;
         }
      }
      
      public static function load(param1:String, param2:int, param3:Function) : void
      {
         _entry = null;
         _completeCallback = param3;
         _target = gMainFrame.path + param1;
         _progressCounter = param2;
         var _loc4_:MovieClip = MovieClip(_loadScreen.content);
         if(_loc4_)
         {
            _loc4_.setProgress(param2);
         }
         DebugUtility.debugTrace("loading target:" + _target);
         if(_loadScreen)
         {
            startLoad();
            return;
         }
         throw new Error("preloader was not embedded?!");
      }
      
      private static function onLoadScreenComplete(param1:Event) : void
      {
         show(true);
      }
      
      private static function startLoad() : void
      {
         show(true);
         gMainFrame.loaderCache.openFile(_target,loadCompleteHandler,loadProgressHandler);
      }
      
      private static function loadCompleteHandler(param1:LoaderEvent) : void
      {
         _entry = param1.entry;
         if(_completeCallback != null)
         {
            _completeCallback();
         }
      }
      
      private static function loadProgressHandler(param1:LoaderEvent) : void
      {
         if(param1.status && Boolean(_loadScreen))
         {
            return;
         }
         throw new Error("ERROR: Unable to show loading progress! status:" + param1.status + " preloader:" + _loadScreen);
      }
   }
}

