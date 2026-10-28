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
      
      public function SceneLoader(param1:Function = null)
      {
         super();
         _loader = [];
         _loadProgressCallback = param1;
      }
      
      public function getOffset(param1:DisplayObject) : Point
      {
         var _loc4_:* = null;
         var _loc2_:Loader = null;
         var _loc5_:Rectangle = null;
         var _loc3_:Array = getActorList("ActorLayer");
         for each(_loc4_ in _loc3_)
         {
            _loc2_ = _loc4_.s;
            _loc5_ = _loc2_.getBounds(param1);
            if(_loc5_.x < _offset.x)
            {
               _offset.x = _loc5_.x;
            }
            if(_loc5_.y < _offset.y)
            {
               _offset.y = _loc5_.y;
            }
         }
         return _offset;
      }
      
      public function get isValid() : Boolean
      {
         return _scene != null;
      }
      
      public function get sceneObject() : Object
      {
         return _scene;
      }
      
      public function setScene(param1:Object, param2:Boolean = false) : void
      {
         release();
         _scene = param1;
         _loadedAssets = new Dictionary();
         _loaderLUT = new Dictionary();
         if(param1)
         {
            loadLayers(param2);
         }
      }
      
      public function getActorList(param1:String) : Array
      {
         return _scene.actors[param1];
      }
      
      public function getLayer(param1:String) : Object
      {
         return findLayer(param1);
      }
      
      public function cloneAsset(param1:String) : Object
      {
         var _loc2_:Loader = null;
         var _loc3_:Object = findLayer(param1);
         if(_loc3_)
         {
            _loc2_ = newAsset(_loc3_.assetName);
            _loc2_.x = _loc3_.x;
            _loc2_.y = _loc3_.y;
            _loc3_.loader = _loc2_;
         }
         return _loc3_;
      }
      
      public function release() : void
      {
         var _loc1_:Loader = null;
         while(_loader.length)
         {
            _loc1_ = _loader.pop();
            _loc1_.unloadAndStop();
         }
      }
      
      public function releaseCloneAsset(param1:Loader) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Loader = null;
         while(_loc3_ < _loader.length)
         {
            _loc2_ = _loader[_loc3_];
            if(_loc2_ == param1)
            {
               param1.unloadAndStop();
               _loader.splice(_loc3_,1);
               break;
            }
            _loc3_++;
         }
      }
      
      public function forceLoadComplete() : void
      {
         _loadProgressCallback();
      }
      
      private function findLayer(param1:String) : Object
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc2_:Array = getActorList("ActorLayer");
         param1 = param1.toLowerCase();
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc2_[_loc4_].name == param1)
            {
               _loc3_ = {};
               _loc3_.assetName = _loc2_[_loc4_].assetName;
               _loc3_.loader = _loc2_[_loc4_].s;
               _loc3_.height = _loc2_[_loc4_].s.height;
               _loc3_.width = _loc2_[_loc4_].s.width;
               _loc3_.x = _loc2_[_loc4_].s.x;
               _loc3_.y = _loc2_[_loc4_].s.y;
               _loc3_.flip = _loc2_[_loc4_].flip;
               break;
            }
            _loc4_++;
         }
         if(_loc3_ == null)
         {
            trace("Layer Not Found: " + param1);
         }
         return _loc3_;
      }
      
      private function newAsset(param1:String) : Loader
      {
         var _loc3_:Loader = null;
         var _loc4_:int = 0;
         param1 = param1.toLowerCase();
         var _loc2_:Array = _scene.assets;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc2_[_loc4_].name.toLowerCase() == param1)
            {
               _loc3_ = new Loader();
               _loc3_.loadBytes(_loc2_[_loc4_].ba);
               _loc3_.contentLoaderInfo.addEventListener("complete",onNewLoaderComplete);
               _loader.push(_loc3_);
               return _loc3_;
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function onNewLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener("complete",onLoaderComplete);
         if(!isAnimated(_loc2_.content))
         {
            _loc2_.content.cacheAsBitmap = true;
         }
         dispatchEvent(param1);
      }
      
      private function isAnimated(param1:DisplayObject) : Boolean
      {
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:MovieClip = param1 as MovieClip;
         if(_loc2_)
         {
            if(_loc2_.totalFrames > 1)
            {
               _loc4_ = true;
            }
            else
            {
               _loc3_ = _loc2_.numChildren;
               while(_loc4_ = false && _loc5_ < _loc3_)
               {
                  _loc4_ = isAnimated(_loc2_.getChildAt(_loc5_));
                  _loc5_++;
               }
            }
         }
         return _loc4_;
      }
      
      public function loadLayer(param1:Object) : void
      {
         param1.loaded = 1;
         _loaderLUT[param1.s] = param1;
         var _loc2_:Loader = loadAsset(param1.assetName,param1.s);
         _initCount = _initCount + 1;
      }
      
      public function isValidDynamicAsset(param1:Object) : Boolean
      {
         return param1.name == "" && param1.typeIndex != 1 && param1.typeIndex != 2 && param1.dx == 1 && param1.dy == 1;
      }
      
      private function loadLayers(param1:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Loader = null;
         _offset = new Point(9999999,9999999);
         var _loc3_:Array = getActorList("ActorLayer");
         _loaderCount = _loc3_.length;
         _initCount = 0;
         if(_loc3_.length > 0 && _loc3_[0].hasOwnProperty("top") && !param1)
         {
            _useDynamicLoading = true;
         }
         else
         {
            _useDynamicLoading = false;
         }
         var _loc2_:Boolean = false;
         _loc6_ = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc6_];
            _loc4_.dx = _loc4_.scrollX;
            _loc4_.dy = _loc4_.scrollY;
            if(_useDynamicLoading)
            {
               _loc4_.offsetX = _loc4_.left - _loc4_.x;
               _loc4_.offsetY = _loc4_.top - _loc4_.y;
               if(_loc4_.flip & 1)
               {
                  _loc4_.offsetX -= _loc4_.width;
               }
               if(_loc4_.flip & 2)
               {
                  _loc4_.offsetY -= _loc4_.height;
               }
            }
            else
            {
               _loc4_.offsetX = 0;
               _loc4_.offsetY = 0;
            }
            if(_useDynamicLoading && _loc2_ && isValidDynamicAsset(_loc4_))
            {
               _loaderCount = _loaderCount - 1;
               _loc5_ = new Loader();
               _loc4_.loaded = 0;
            }
            else
            {
               _loc4_.loaded = 1;
               _loadedAssets[_loc4_.assetName] = _loc5_ = loadAsset(_loc4_.assetName);
               _loc2_ = true;
            }
            _loc4_.s = _loc5_;
            _loaderLUT[_loc5_] = _loc4_;
            _loc5_.x = Math.round(_loc4_.x);
            _loc5_.y = Math.round(_loc4_.y);
            _loc5_.rotation = _loc4_.rot;
            _loc5_.scaleX = _loc4_.scaleX;
            _loc5_.scaleY = _loc4_.scaleY;
            _loc6_++;
         }
      }
      
      private function loadAsset(param1:String, param2:Loader = null) : Loader
      {
         var _loc6_:int = 0;
         var _loc3_:LoaderContext = null;
         var _loc5_:Loader = param2;
         param1 = param1.toLowerCase();
         var _loc4_:Array = _scene.assets;
         while(_loc6_ < _loc4_.length)
         {
            if(_loc4_[_loc6_].name.toLowerCase() == param1)
            {
               if(_loc5_ == null)
               {
                  _loc5_ = new Loader();
               }
               if(_loc4_[_loc6_].ba)
               {
                  _loc3_ = new LoaderContext(false,ApplicationDomain.currentDomain);
                  _loc5_.loadBytes(_loc4_[_loc6_].ba,_loc3_);
                  _loc5_.contentLoaderInfo.addEventListener("complete",onLoaderComplete);
                  _loader.push(_loc5_);
               }
               return _loc5_;
            }
            _loc6_++;
         }
         return _loc5_;
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener("complete",onLoaderComplete);
         if(_loc2_.content is MovieClip)
         {
            LocalizationManager.findAllTextfields(_loc2_.content);
            if(!isAnimated(_loc2_.content))
            {
               _loc2_.content.cacheAsBitmap = true;
            }
         }
         _loaderCount = _loaderCount - 1;
         _loaderLUT[_loc2_.loader].loaded = 2;
         if(_initCount > 0)
         {
            _initCount = _initCount - 1;
            if(_initCount == 0)
            {
               _loadProgressCallback();
            }
         }
         if(_loaderCount == 0)
         {
            allLoadingComplete();
         }
      }
      
      private function allLoadingComplete() : void
      {
         var _loc1_:Event = new Event("complete");
         dispatchEvent(_loc1_);
      }
   }
}

