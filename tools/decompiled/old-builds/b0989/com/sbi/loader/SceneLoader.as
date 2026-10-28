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
   
   public class SceneLoader extends EventDispatcher
   {
      
      private var _offset:Point;
      
      private var _scene:Object;
      
      private var _loaderCount:int;
      
      private var _loader:Array;
      
      public function SceneLoader()
      {
         super();
         this._loader = new Array();
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
      
      public function setScene(param1:Object) : void
      {
         this.release();
         this._scene = param1;
         if(param1)
         {
            this.loadLayers();
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
      
      private function loadLayers() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Loader = null;
         this._offset = new Point(9999999,9999999);
         var _loc1_:Array = this.getActorList("ActorLayer");
         this._loaderCount = _loc1_.length;
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc3_ = _loc1_[_loc2_];
            _loc3_.dx = _loc3_.scrollX;
            _loc3_.dy = _loc3_.scrollY;
            _loc4_ = this.loadAsset(_loc3_.assetName);
            _loc3_.s = _loc4_;
            _loc4_.x = Math.round(_loc3_.x);
            _loc4_.y = Math.round(_loc3_.y);
            _loc4_.rotation = _loc3_.rot;
            _loc4_.scaleX = _loc3_.scaleX;
            _loc4_.scaleY = _loc3_.scaleY;
            _loc2_++;
         }
      }
      
      private function loadAsset(param1:String) : Loader
      {
         var _loc2_:Loader = null;
         var _loc4_:int = 0;
         var _loc5_:LoaderContext = null;
         param1 = param1.toLowerCase();
         var _loc3_:Array = this._scene.assets;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].name.toLowerCase() == param1)
            {
               _loc2_ = new Loader();
               if(_loc3_[_loc4_].ba)
               {
                  _loc5_ = new LoaderContext(false,ApplicationDomain.currentDomain);
                  _loc2_.loadBytes(_loc3_[_loc4_].ba,_loc5_);
                  _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoaderComplete);
                  _loc2_.cacheAsBitmap = true;
                  this._loader.push(_loc2_);
               }
               return _loc2_;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function onLoaderComplete(param1:Event) : void
      {
         var _loc2_:LoaderInfo = param1.target as LoaderInfo;
         _loc2_.removeEventListener(Event.COMPLETE,this.onLoaderComplete);
         if(_loc2_.content is MovieClip && MovieClip(_loc2_.content).totalFrames > 1)
         {
            _loc2_.content.cacheAsBitmap = false;
         }
         --this._loaderCount;
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

