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
         this._loader = new Array();
         this._loadProgressCallback = param1;
      }
      
      public function getOffset(param1:DisplayObject) : Point
      {
         var _loc2_:Object = null;
         var _loc4_:Loader = null;
         var _loc5_:Rectangle = null;
         var _loc3_:Array = this.getActorList("ActorLayer");
         for each(_loc2_ in _loc3_)
         {
            _loc4_ = _loc2_.s;
            _loc5_ = _loc4_.getBounds(param1);
            if(_loc5_.x < this._offset.x)
            {
               this._offset.x = _loc5_.x;
            }
            if(_loc5_.y < this._offset.y)
            {
               this._offset.y = _loc5_.y;
            }
         }
         return this._offset;
      }
      
      public function get isValid() : Boolean
      {
         return this._scene != null;
      }
      
      public function setScene(param1:Object, param2:Boolean = false) : void
      {
         this.release();
         this._scene = param1;
         this._loadedAssets = new Dictionary();
         this._loaderLUT = new Dictionary();
         if(param1)
         {
            this.loadLayers(param2);
         }
      }
      
      public function getActorList(param1:String) : Array
      {
         return this._scene.actors[param1];
      }
      
      public function getLayer(param1:String) : Object
      {
         return this.findLayer(param1);
      }
      
      public function cloneAsset(param1:String) : Object
      {
         var _loc3_:Loader = null;
         var _loc2_:Object = this.findLayer(param1);
         if(_loc2_)
         {
            _loc3_ = this.newAsset(_loc2_.assetName);
            _loc3_.x = _loc2_.x;
            _loc3_.y = _loc2_.y;
            _loc2_.loader = _loc3_;
         }
         return _loc2_;
      }
      
      public function release() : void
      {
         var _loc1_:Loader = null;
         while(this._loader.length)
         {
            _loc1_ = this._loader.pop();
            _loc1_.unloadAndStop();
         }
      }
      
      public function releaseCloneAsset(param1:Loader) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Loader = null;
         while(_loc2_ < this._loader.length)
         {
            _loc3_ = this._loader[_loc2_];
            if(_loc3_ == param1)
            {
               param1.unloadAndStop();
               this._loader.splice(_loc2_,1);
               break;
            }
            _loc2_++;
         }
      }
      
      public function forceLoadComplete() : void
      {
         this._loadProgressCallback(false);
      }
      
      private function findLayer(param1:String) : Object
      {
         var _loc2_:Object = null;
         var _loc4_:int = 0;
         var _loc3_:Array = this.getActorList("ActorLayer");
         param1 = param1.toLowerCase();
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].name == param1)
            {
               _loc2_ = new Object();
               _loc2_.assetName = _loc3_[_loc4_].assetName;
               _loc2_.loader = _loc3_[_loc4_].s;
               _loc2_.height = _loc3_[_loc4_].s.height;
               _loc2_.width = _loc3_[_loc4_].s.width;
               _loc2_.x = _loc3_[_loc4_].s.x;
               _loc2_.y = _loc3_[_loc4_].s.y;
               _loc2_.flip = _loc3_[_loc4_].flip;
               break;
            }
            _loc4_++;
         }
         if(_loc2_ == null)
         {
         }
         return _loc2_;
      }
      
      private function newAsset(param1:String) : Loader
      {
         var _loc2_:Loader = null;
         var _loc4_:int = 0;
         param1 = param1.toLowerCase();
         var _loc3_:Array = this._scene.assets;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].name.toLowerCase() == param1)
            {
               _loc2_ = new Loader();
               _loc2_.loadBytes(_loc3_[_loc4_].ba);
               _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onNewLoaderComplete);
               _loc2_.cacheAsBitmap = true;
               this._loader.push(_loc2_);
               return _loc2_;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function onNewLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         if(_loc2_.content is MovieClip && MovieClip(_loc2_.content).totalFrames > 1)
         {
            _loc2_.content.cacheAsBitmap = false;
         }
         dispatchEvent(param1);
      }
      
      public function loadLayer(param1:Object) : void
      {
         param1.loaded = LOAD_STATE_LOADING;
         this._loaderLUT[param1.s] = param1;
         var _loc2_:Loader = this.loadAsset(param1.assetName,param1.s);
         ++this._initCount;
      }
      
      public function isValidDynamicAsset(param1:Object) : Boolean
      {
         return param1.name == "" && param1.typeIndex != 1 && param1.typeIndex != 2;
      }
      
      private function loadLayers(param1:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Loader = null;
         this._offset = new Point(9999999,9999999);
         var _loc2_:Array = this.getActorList("ActorLayer");
         this._loaderCount = _loc2_.length;
         this._initCount = 0;
         if(Boolean(_loc2_.length > 0) && Boolean(_loc2_[0].hasOwnProperty("top")) && !param1)
         {
            this._useDynamicLoading = true;
         }
         else
         {
            this._useDynamicLoading = false;
         }
         var _loc4_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _loc5_ = _loc2_[_loc3_];
            _loc5_.dx = _loc5_.scrollX;
            _loc5_.dy = _loc5_.scrollY;
            if(this._useDynamicLoading)
            {
               _loc5_.offsetX = _loc5_.left - _loc5_.x;
               _loc5_.offsetY = _loc5_.top - _loc5_.y;
               if(_loc5_.flip & 1)
               {
                  _loc5_.offsetX -= _loc5_.width;
               }
               if(_loc5_.flip & 2)
               {
                  _loc5_.offsetY -= _loc5_.height;
               }
            }
            else
            {
               _loc5_.offsetX = 0;
               _loc5_.offsetY = 0;
            }
            if(this._useDynamicLoading && _loc4_ && this.isValidDynamicAsset(_loc5_))
            {
               --this._loaderCount;
               _loc6_ = new Loader();
               _loc5_.loaded = LOAD_STATE_NOTLOADED;
            }
            else
            {
               _loc5_.loaded = LOAD_STATE_LOADING;
               this._loadedAssets[_loc5_.assetName] = _loc6_ = this.loadAsset(_loc5_.assetName);
               _loc4_ = true;
            }
            _loc5_.s = _loc6_;
            this._loaderLUT[_loc6_] = _loc5_;
            _loc6_.x = Math.round(_loc5_.x);
            _loc6_.y = Math.round(_loc5_.y);
            _loc6_.rotation = _loc5_.rot;
            _loc6_.scaleX = _loc5_.scaleX;
            _loc6_.scaleY = _loc5_.scaleY;
            _loc3_++;
         }
      }
      
      private function loadAsset(param1:String, param2:Loader = null) : Loader
      {
         var _loc5_:int = 0;
         var _loc6_:LoaderContext = null;
         var _loc3_:Loader = param2;
         param1 = param1.toLowerCase();
         var _loc4_:Array = this._scene.assets;
         while(_loc5_ < _loc4_.length)
         {
            if(_loc4_[_loc5_].name.toLowerCase() == param1)
            {
               if(_loc3_ == null)
               {
                  _loc3_ = new Loader();
               }
               if(_loc4_[_loc5_].ba)
               {
                  _loc6_ = new LoaderContext(false,ApplicationDomain.currentDomain);
                  _loc3_.loadBytes(_loc4_[_loc5_].ba,_loc6_);
                  _loc3_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
                  _loc3_.cacheAsBitmap = true;
                  this._loader.push(_loc3_);
               }
               return _loc3_;
            }
            _loc5_++;
         }
         return _loc3_;
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         if(_loc2_.content is MovieClip)
         {
            LocalizationManager.findAllTextfields(_loc2_.content);
            if(MovieClip(_loc2_.content).totalFrames > 1)
            {
               _loc2_.content.cacheAsBitmap = false;
            }
         }
         --this._loaderCount;
         this._loaderLUT[_loc2_.loader].loaded = LOAD_STATE_LOADED;
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
         var _loc1_:Event = new Event(Event.COMPLETE);
         dispatchEvent(_loc1_);
      }
   }
}

