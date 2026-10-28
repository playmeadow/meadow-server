package com.sbi.loader
{
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.Dictionary;
   import localization.LocalizationManager;
   
   public class SceneLoader extends EventDispatcher
   {
      
      public static const LOAD_STATE_NOTLOADED:int = 0;
      
      public static const LOAD_STATE_LOADING:int = 1;
      
      public static const LOAD_STATE_LOADED:int = 2;
      
      private var _offset:Point;
      
      private var _scene:Object;
      
      private var _loaderCount:int;
      
      private var _loader:Array;
      
      private var _loadedAssets:Dictionary;
      
      private var _loaderLUT:Dictionary;
      
      private var _initCount:int;
      
      private var _loadProgressCallback:Function;
      
      public var _useDynamicLoading:Boolean;
      
      public function SceneLoader(loadProgressCallback:Function = null)
      {
         super();
         this._loader = new Array();
         this._loadProgressCallback = loadProgressCallback;
      }
      
      public function getOffset(stage:DisplayObject) : Point
      {
         var o:Object = null;
         var s:Loader = null;
         var rect:Rectangle = null;
         var layers:Array = this.getActorList("ActorLayer");
         for each(o in layers)
         {
            s = o.s;
            rect = s.getBounds(stage);
            if(rect.x < this._offset.x)
            {
               this._offset.x = rect.x;
            }
            if(rect.y < this._offset.y)
            {
               this._offset.y = rect.y;
            }
         }
         return this._offset;
      }
      
      public function get isValid() : Boolean
      {
         return this._scene != null;
      }
      
      public function get sceneObject() : Object
      {
         return this._scene;
      }
      
      public function setScene(scene:Object, forceStaticLoad:Boolean = false) : void
      {
         this.release();
         this._scene = scene;
         this._loadedAssets = new Dictionary();
         this._loaderLUT = new Dictionary();
         if(Boolean(scene))
         {
            this.loadLayers(forceStaticLoad);
         }
      }
      
      public function getActorList(name:String) : Array
      {
         return this._scene.actors[name];
      }
      
      public function getLayer(name:String) : Object
      {
         return this.findLayer(name);
      }
      
      public function cloneAsset(name:String) : Object
      {
         var loader:Loader = null;
         var o:Object = this.findLayer(name);
         if(Boolean(o))
         {
            loader = this.newAsset(o.assetName);
            loader.x = o.x;
            loader.y = o.y;
            o.loader = loader;
         }
         return o;
      }
      
      public function release() : void
      {
         var l:Loader = null;
         while(Boolean(this._loader.length))
         {
            l = this._loader.pop();
            l.unloadAndStop();
         }
      }
      
      public function releaseCloneAsset(l:Loader) : void
      {
         var i:int = 0;
         var le:Loader = null;
         while(i < this._loader.length)
         {
            le = this._loader[i];
            if(le == l)
            {
               l.unloadAndStop();
               this._loader.splice(i,1);
               break;
            }
            i++;
         }
      }
      
      public function forceLoadComplete() : void
      {
         this._loadProgressCallback(false);
      }
      
      private function findLayer(name:String) : Object
      {
         var o:Object = null;
         var i:int = 0;
         var a:Array = this.getActorList("ActorLayer");
         name = name.toLowerCase();
         for(i = 0; i < a.length; i++)
         {
            if(a[i].name == name)
            {
               o = new Object();
               o.assetName = a[i].assetName;
               o.loader = a[i].s;
               o.height = a[i].s.height;
               o.width = a[i].s.width;
               o.x = a[i].s.x;
               o.y = a[i].s.y;
               o.flip = a[i].flip;
               break;
            }
         }
         if(o == null)
         {
            trace("Layer Not Found: " + name);
         }
         return o;
      }
      
      private function newAsset(name:String) : Loader
      {
         var l:Loader = null;
         var i:int = 0;
         name = name.toLowerCase();
         for(var a:Array = this._scene.assets; i < a.length; )
         {
            if(a[i].name.toLowerCase() == name)
            {
               l = new Loader();
               l.loadBytes(a[i].ba);
               l.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onNewLoaderComplete);
               l.cacheAsBitmap = true;
               this._loader.push(l);
               return l;
            }
            i++;
         }
         return l;
      }
      
      private function onNewLoaderComplete(e:Event) : void
      {
         var l:LoaderInfo = e.target as LoaderInfo;
         l.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         if(l.content is MovieClip && MovieClip(l.content).totalFrames > 1)
         {
            l.content.cacheAsBitmap = false;
         }
         dispatchEvent(e);
      }
      
      public function loadLayer(o:Object) : void
      {
         o.loaded = LOAD_STATE_LOADING;
         this._loaderLUT[o.s] = o;
         var l:Loader = this.loadAsset(o.assetName,o.s);
         ++this._initCount;
      }
      
      public function isValidDynamicAsset(o:Object) : Boolean
      {
         return o.name == "" && o.typeIndex != 1 && o.typeIndex != 2 && o.dx == 1 && o.dy == 1;
      }
      
      private function loadLayers(forceStaticLoad:Boolean = false) : void
      {
         var i:int = 0;
         var o:Object = null;
         var l:Loader = null;
         this._offset = new Point(9999999,9999999);
         var a:Array = this.getActorList("ActorLayer");
         this._loaderCount = a.length;
         this._initCount = 0;
         if(Boolean(a.length > 0) && Boolean(a[0].hasOwnProperty("top")) && !forceStaticLoad)
         {
            this._useDynamicLoading = true;
         }
         else
         {
            this._useDynamicLoading = false;
         }
         var namedAssetsLoading:Boolean = false;
         for(i = 0; i < a.length; i++)
         {
            o = a[i];
            o.dx = o.scrollX;
            o.dy = o.scrollY;
            if(this._useDynamicLoading)
            {
               o.offsetX = o.left - o.x;
               o.offsetY = o.top - o.y;
               if(Boolean(o.flip & 1))
               {
                  o.offsetX -= o.width;
               }
               if(Boolean(o.flip & 2))
               {
                  o.offsetY -= o.height;
               }
            }
            else
            {
               o.offsetX = 0;
               o.offsetY = 0;
            }
            if(this._useDynamicLoading && namedAssetsLoading && this.isValidDynamicAsset(o))
            {
               --this._loaderCount;
               l = new Loader();
               o.loaded = LOAD_STATE_NOTLOADED;
            }
            else
            {
               o.loaded = LOAD_STATE_LOADING;
               this._loadedAssets[o.assetName] = l = this.loadAsset(o.assetName);
               namedAssetsLoading = true;
            }
            o.s = l;
            this._loaderLUT[l] = o;
            l.x = Math.round(o.x);
            l.y = Math.round(o.y);
            l.rotation = o.rot;
            l.scaleX = o.scaleX;
            l.scaleY = o.scaleY;
         }
      }
      
      private function loadAsset(name:String, loader:Loader = null) : Loader
      {
         var i:int = 0;
         var ldrContext:LoaderContext = null;
         var l:Loader = loader;
         name = name.toLowerCase();
         for(var a:Array = this._scene.assets; i < a.length; )
         {
            if(a[i].name.toLowerCase() == name)
            {
               if(l == null)
               {
                  l = new Loader();
               }
               if(Boolean(a[i].ba))
               {
                  ldrContext = new LoaderContext(false,ApplicationDomain.currentDomain);
                  l.loadBytes(a[i].ba,ldrContext);
                  l.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
                  l.cacheAsBitmap = true;
                  this._loader.push(l);
               }
               return l;
            }
            i++;
         }
         return l;
      }
      
      private function onLoaderComplete(e:Event) : void
      {
         var l:LoaderInfo = e.target as LoaderInfo;
         l.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         if(l.content is MovieClip)
         {
            LocalizationManager.findAllTextfields(l.content);
            if(MovieClip(l.content).totalFrames > 1)
            {
               l.content.cacheAsBitmap = false;
            }
         }
         --this._loaderCount;
         this._loaderLUT[l.loader].loaded = LOAD_STATE_LOADED;
         if(this._initCount > 0)
         {
            --this._initCount;
            if(this._initCount == 0)
            {
               this._loadProgressCallback(false);
            }
         }
         if(this._loaderCount == 0)
         {
            this.allLoadingComplete();
         }
      }
      
      private function allLoadingComplete() : void
      {
         var e:Event = new Event(Event.COMPLETE);
         dispatchEvent(e);
      }
   }
}

