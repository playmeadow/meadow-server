package com.sbi.graphics
{
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.loader.ImageServerEvent;
   import com.sbi.loader.ImageServerURL;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class LayerAnim
   {
      
      private static var _activePool:Array;
      
      private static var _freePool:Array;
      
      private static var _avOffsets:Array;
      
      private static var _lastEntry:int;
      
      private static var _useMaxThrottle:Function;
      
      public static const PLAY_LOOP:int = 0;
      
      public static const PLAY_ONE_SHOT:int = 1;
      
      public static const PLAY_LOOP__KEEP_CURRENT_FRAME:int = 2;
      
      public static const AN_SIT_NNE:int = 1;
      
      public static const AN_SIT_NE:int = 2;
      
      public static const AN_SIT_E:int = 3;
      
      public static const AN_SIT_SE:int = 4;
      
      public static const AN_SIT_SSE:int = 5;
      
      public static const AN_MOVE_NNE:int = 7;
      
      public static const AN_MOVE_NE:int = 8;
      
      public static const AN_MOVE_E:int = 9;
      
      public static const AN_MOVE_SE:int = 10;
      
      public static const AN_MOVE_SSE:int = 11;
      
      public static const AN_BBCARD:int = 13;
      
      public static const AN_IDLE_SE:int = 14;
      
      public static const AN_HUD_AVT:int = 15;
      
      public static const AN_IDLE_NE:int = 16;
      
      public static const AN_HOP:int = 17;
      
      public static const AN_SLEEP:int = 22;
      
      public static const AN_DANCE:int = 23;
      
      public static const AN_PLAY:int = 6;
      
      public static const AN_SWIM_N:int = 36;
      
      public static const AN_SWIM_NE:int = 34;
      
      public static const AN_SWIM_E:int = 29;
      
      public static const AN_SWIM_SE:int = 35;
      
      public static const AN_SWIM_S:int = 37;
      
      public static const AN_FLOAT:int = 32;
      
      public static const AN_WATER_DIVE:int = 41;
      
      public static const AN_WATER_PLAY:int = 39;
      
      public static const AN_WATER_SPIN:int = 33;
      
      public static const AN_WATER_JIG:int = 38;
      
      public static const AN_WATER_POSE:int = 40;
      
      public static const AN_PHOTO:int = 42;
      
      public static const AN_PARACHUTE_IDLE:int = 19;
      
      public static const AN_PARACHUTE_JUMP:int = 24;
      
      public static const AN_PARACHUTE_DISTRESS:int = 20;
      
      public static const AN_PARACHUTE_LAND:int = 21;
      
      public static const AN_WINDRIDER_JUMP:int = 28;
      
      public static const AN_WINDRIDER_IDLE:int = 29;
      
      public static const AN_WINDRIDER_FALL:int = 30;
      
      public static const AN_WINDRIDER_START:int = 31;
      
      public static const AN_WINDRIDER_DISTRESS:int = 20;
      
      public static const AVATAR_BITMAP_OFFSET_X:int = 375;
      
      public static const AVATAR_BITMAP_OFFSET_Y:int = 365;
      
      private static var _throttle:int = 8;
      
      private var _bitmap:LayerBitmap;
      
      private var _avDefId:int;
      
      private var _animId:int;
      
      private var _frame:int;
      
      private var _hFlip:Boolean;
      
      private var _totalFrames:int;
      
      private var _x:int;
      
      private var _y:int;
      
      private var _rotation:int;
      
      private var _xOff:int;
      
      private var _yOff:int;
      
      private var _bPause:Boolean;
      
      private var _layers:Array;
      
      private var _colors:Array;
      
      private var _callback:Function;
      
      private var _mode:int;
      
      private var _tStep:int;
      
      private var _bRedraw:Boolean;
      
      private var _bReload:Boolean;
      
      private var _bBaseLayer:Boolean;
      
      private var _avatarEnabled:Boolean = true;
      
      private var _bNewAnim:Boolean;
      
      private var _requestAnimId:int;
      
      private var _receivedData:Array;
      
      private var _requestedIds:Array;
      
      private var _requestCallback:Function;
      
      private var _requestMode:int;
      
      private var _preloadRequestedIds:Array;
      
      private var _preloadCallback:Function;
      
      private var _bounceEnabled:Boolean;
      
      private var _bounceOverride:Boolean;
      
      private var _bounceOffSet:int;
      
      private var _local:Boolean;
      
      public function LayerAnim(param1:Class)
      {
         super();
         if(param1 != SingletonLock)
         {
            throw new Error("Invalid access.  Use LayerAnim.getNew");
         }
         this._requestedIds = new Array();
         this._colors = new Array();
      }
      
      public static function set avOffsets(param1:Array) : void
      {
         _avOffsets = param1;
      }
      
      public static function getAvOffset(param1:int) : Point
      {
         if(_avOffsets[param1])
         {
            return _avOffsets[param1];
         }
         return new Point(-100,-100);
      }
      
      public static function set throttle(param1:int) : void
      {
         _throttle = param1;
      }
      
      public static function getNew() : LayerAnim
      {
         var _loc1_:LayerAnim = null;
         if(!_activePool)
         {
            _activePool = new Array();
            _freePool = new Array();
         }
         if(_freePool.length)
         {
            _loc1_ = _freePool.pop();
         }
         else
         {
            _loc1_ = new LayerAnim(SingletonLock);
         }
         _activePool.push(_loc1_);
         _loc1_.init();
         return _loc1_;
      }
      
      public static function destroy(param1:LayerAnim) : void
      {
         var _loc2_:int = _activePool.indexOf(param1);
         if(_loc2_ >= 0)
         {
            _activePool.splice(_loc2_,1);
            param1.destroy();
            _freePool.push(param1);
         }
      }
      
      public static function heartbeat() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc5_:LayerAnim = null;
         var _loc6_:int = 0;
         if(Boolean(_activePool) && Boolean(_activePool.length))
         {
            _loc1_ = int(_activePool.length);
            _loc2_ = _loc1_;
            _loc3_ = int(_loc1_ * 0.5);
            if(_loc3_ < 1 || Boolean(_useMaxThrottle) && Boolean(_useMaxThrottle()))
            {
               _loc3_ = 1;
            }
            if(_loc3_ > _throttle)
            {
               _loc3_ = _throttle;
            }
            _loc4_ = _lastEntry;
            for each(_loc5_ in _activePool)
            {
               ++_loc5_._tStep;
            }
            while(_loc3_ > 0 && _loc2_ > 0)
            {
               if(_loc4_ >= _loc1_)
               {
                  _loc4_ = 0;
               }
               _loc5_ = _activePool[_loc4_++];
               _loc6_ = _loc5_._tStep;
               if(_loc6_ >= 2)
               {
                  if((_loc5_._requestMode == PLAY_ONE_SHOT || isOnscreen(_loc5_)) && _loc5_.heartbeat())
                  {
                     _loc5_._tStep = 0;
                     _loc3_--;
                  }
               }
               _loc2_--;
            }
            _lastEntry = _loc4_;
         }
      }
      
      private static function isOnscreen(param1:LayerAnim) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Rectangle = null;
         var _loc2_:DisplayObjectContainer = param1.bitmap.parent;
         if(_loc2_)
         {
            _loc3_ = 0;
            _loc4_ = 900;
            _loc5_ = 0;
            _loc6_ = 550;
            _loc7_ = _loc2_.getBounds(gMainFrame.stage);
            return _loc7_.height == 0 || !(_loc6_ < _loc7_.top || _loc5_ > _loc7_.bottom || _loc4_ < _loc7_.left || _loc3_ > _loc7_.right);
         }
         return true;
      }
      
      public static function set useMaxThrottle(param1:Function) : void
      {
         _useMaxThrottle = param1;
      }
      
      public function get bounceOffSet() : int
      {
         return this._bounceOffSet;
      }
      
      public function get bounceEnabled() : Boolean
      {
         return this._bounceEnabled;
      }
      
      public function set bounceEnabled(param1:Boolean) : void
      {
         this._bounceEnabled = param1;
      }
      
      public function set local(param1:Boolean) : void
      {
         this._local = param1;
      }
      
      private function init() : void
      {
         this._bitmap = new LayerBitmap();
         this._layers = null;
         this._requestAnimId = -1;
         this._avDefId = -1;
         this._animId = -1;
         this._bNewAnim = false;
         this._totalFrames = 0;
         this._bReload = true;
         this._tStep = 1;
         this._bounceEnabled = false;
      }
      
      private function destroy() : void
      {
         this._bitmap = null;
         this._layers = null;
         if(this._requestedIds.length != 0)
         {
            ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
            this._requestedIds.splice(0,this._requestedIds.length);
         }
      }
      
      public function set avDefId(param1:int) : void
      {
         if(param1 != this._avDefId)
         {
            this._avDefId = param1;
            this._xOff = -getAvOffset(this._avDefId).x - AVATAR_BITMAP_OFFSET_X;
            this._yOff = -getAvOffset(this._avDefId).y - AVATAR_BITMAP_OFFSET_Y;
            this._bReload = true;
         }
      }
      
      public function get layers() : Array
      {
         return this._layers;
      }
      
      public function get avDefId() : int
      {
         return this._avDefId;
      }
      
      public function get animId() : int
      {
         return this._animId;
      }
      
      public function get hFlip() : Boolean
      {
         return this._hFlip;
      }
      
      public function get frame() : int
      {
         return this._frame;
      }
      
      public function set frame(param1:int) : void
      {
         this._frame = param1;
      }
      
      public function set avatarEnabled(param1:Boolean) : void
      {
         this._avatarEnabled = param1;
      }
      
      public function set layers(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc3_:Boolean = true;
         var _loc4_:Boolean = false;
         if(Boolean(this._layers) && this._layers.length == param1.length)
         {
            _loc3_ = false;
            _loc2_ = 0;
            while(_loc2_ < param1.length)
            {
               if(this._layers[_loc2_].l != param1[_loc2_].l)
               {
                  _loc3_ = true;
                  break;
               }
               if(this._layers[_loc2_].c != param1[_loc2_].c)
               {
                  _loc4_ = true;
               }
               _loc2_++;
            }
            if(!_loc3_ && !_loc4_)
            {
               return;
            }
         }
         if(param1.length > 0)
         {
            this._layers = param1;
            if(_loc3_)
            {
               this._bReload = true;
            }
            else if(_loc4_)
            {
               for each(_loc5_ in param1)
               {
                  _loc6_ = ImageServerURL.instance.getLayerIndex(_loc5_.l);
                  this._bitmap.setLayerColor(_loc6_,_loc5_.c);
               }
               this._bRedraw = true;
            }
         }
      }
      
      public function get x() : int
      {
         return this._x;
      }
      
      public function get y() : int
      {
         return this._y;
      }
      
      public function set x(param1:int) : void
      {
         this._x = param1;
      }
      
      public function set y(param1:int) : void
      {
         this._y = param1;
      }
      
      public function set alpha(param1:Number) : void
      {
         this._bitmap.alpha = param1;
      }
      
      public function set rotation(param1:Number) : void
      {
         this._rotation = param1;
      }
      
      public function set hFlip(param1:Boolean) : void
      {
         if(param1 != this._hFlip)
         {
            this._hFlip = param1;
            this._bRedraw = true;
         }
      }
      
      public function set visible(param1:Boolean) : void
      {
         this._bitmap.visible = param1;
      }
      
      public function get visible() : Boolean
      {
         return this._bitmap.visible;
      }
      
      public function set pause(param1:Boolean) : void
      {
         this._bPause = param1;
      }
      
      public function get bitmap() : LayerBitmap
      {
         return this._bitmap;
      }
      
      public function playAnim(param1:int, param2:int = 0, param3:Function = null) : void
      {
         if(this._requestAnimId == -1 && param1 != this._animId || this._requestAnimId != param1)
         {
            this._requestCallback = param3;
            this._requestMode = param2;
            this._requestAnimId = param1;
            this._bReload = true;
            this._bounceOverride = param1 != AN_HOP;
         }
      }
      
      public function preload(param1:Array, param2:Function) : void
      {
         var _loc3_:int = 0;
         this._preloadCallback = param2;
         this._preloadRequestedIds = [];
         while(_loc3_ < param1.length)
         {
            this.buildRequestArray(param1[_loc3_],this._preloadRequestedIds,null);
            _loc3_++;
         }
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
         ImageServerURL.instance.requestImages(this._preloadRequestedIds.slice());
      }
      
      private function heartbeat() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc1_:Boolean = false;
         if(this._bReload)
         {
            this.loadAnim();
         }
         if(this._totalFrames == 0)
         {
            return false;
         }
         if(this._frame >= this._totalFrames)
         {
            if(this._mode == PLAY_ONE_SHOT)
            {
               this._frame = this._totalFrames > 0 ? int(this._totalFrames - 1) : 0;
            }
            else
            {
               this._frame = 0;
            }
            if(this._callback != null)
            {
               this._callback(this,this._animId);
               if(this._mode == PLAY_ONE_SHOT)
               {
                  this._callback = null;
               }
            }
         }
         if(this._bRedraw)
         {
            this._bitmap.invalidate();
            this._bRedraw = false;
         }
         if(this._avatarEnabled)
         {
            _loc1_ = this._bitmap.paint(this._frame,this._hFlip);
         }
         this._bounceOffSet = 0;
         if(this._bounceEnabled && !this._bounceOverride)
         {
            _loc2_ = 75;
            _loc3_ = (this._frame + 1) / this._totalFrames;
            this._bounceOffSet = (1 - (2 * _loc3_ - 1) * (2 * _loc3_ - 1)) * _loc2_;
            if(this._local && this._frame == 0)
            {
               SBAudio.playCachedSound("BOUNCE");
            }
         }
         this.updateBitmapPos(this._bounceOffSet);
         if(!this._bPause)
         {
            ++this._frame;
         }
         return _loc1_;
      }
      
      private function loadAnim() : void
      {
         var _loc1_:int = 0;
         if(this._layers != null && this._layers.length > 0)
         {
            _loc1_ = this._requestAnimId != -1 ? this._requestAnimId : this._animId;
            if(_loc1_ >= 0)
            {
               this._requestAnimId = _loc1_;
               this.requestAnim(_loc1_);
            }
         }
      }
      
      public function updateBitmapPos(param1:int) : void
      {
         var _loc5_:Matrix = null;
         var _loc2_:Point = this._bitmap.anchorPoint;
         var _loc3_:int = this._x + _loc2_.x + this._xOff;
         var _loc4_:int = this._y + _loc2_.y + this._yOff - param1;
         if(this._rotation)
         {
            _loc5_ = this._bitmap.transform.matrix;
            _loc5_.identity();
            _loc5_.translate(_loc2_.x + this._xOff,_loc2_.y + this._yOff);
            _loc5_.rotate(this._rotation * (Math.PI / 180));
            _loc5_.translate(_loc3_,_loc4_);
            this._bitmap.transform.matrix = _loc5_;
         }
         else
         {
            if(this._bitmap.rotation != this._rotation)
            {
               this._bitmap.rotation = this._rotation;
            }
            this._bitmap.x = _loc3_;
            this._bitmap.y = _loc4_;
         }
      }
      
      private function requestAnim(param1:int) : void
      {
         this._bNewAnim = false;
         this._requestedIds.splice(0,this._requestedIds.length);
         this._colors = [];
         this._receivedData = [];
         this.buildRequestArray(param1,this._requestedIds,this._colors);
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
         ImageServerURL.instance.requestImages(this._requestedIds.slice());
         this._bReload = false;
         this._bBaseLayer = false;
      }
      
      private function buildRequestArray(param1:int, param2:Array, param3:Array) : void
      {
         var _loc4_:Object = null;
         var _loc5_:uint = 0;
         param2.push(ImageArrayHelper.packId(this._avDefId,param1,0));
         for each(_loc4_ in this._layers)
         {
            _loc5_ = ImageArrayHelper.packId(this._avDefId,param1,_loc4_.l);
            param2.push(_loc5_);
            if(param3)
            {
               param3[_loc5_] = _loc4_.c;
            }
         }
      }
      
      private function onReceiveData(param1:ImageServerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc4_:uint = 0;
         var _loc5_:Object = null;
         var _loc3_:int = param1.layer;
         if(Boolean(this._preloadRequestedIds) && Boolean(this._preloadRequestedIds.length))
         {
            _loc2_ = this._preloadRequestedIds.indexOf(param1.id);
            if(_loc2_ >= 0)
            {
               this._preloadRequestedIds.splice(_loc2_,1);
               if(this._preloadRequestedIds.length == 0)
               {
                  this._preloadRequestedIds = null;
                  if(this._requestedIds.length == 0)
                  {
                     ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
                  }
                  if(this._preloadCallback != null)
                  {
                     this._preloadCallback(this);
                  }
               }
               return;
            }
         }
         _loc2_ = this._requestedIds.indexOf(param1.id);
         if(_loc2_ >= 0)
         {
            this._requestedIds.splice(_loc2_,1);
            if(_loc3_ > 0)
            {
               _loc4_ = uint(this._colors[param1.id]);
            }
            if(param1.success)
            {
               this._receivedData.push({
                  "l":_loc3_,
                  "d":param1.imageData,
                  "c":_loc4_
               });
            }
            if(this._requestedIds.length == 0)
            {
               this._bNewAnim = true;
               if(this._preloadRequestedIds == null)
               {
                  ImageServerURL.instance.removeEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
               }
            }
            if(_loc3_ == 1 || this._bNewAnim)
            {
               this._bBaseLayer = true;
               if(this._mode == LayerAnim.PLAY_LOOP__KEEP_CURRENT_FRAME)
               {
                  this._mode == LayerAnim.PLAY_LOOP;
               }
               else
               {
                  this._frame = 0;
               }
               if(this._requestAnimId >= 0)
               {
                  this._animId = this._requestAnimId;
               }
               this._callback = this._requestCallback;
               this._mode = this._requestMode;
               this._requestAnimId = -1;
               this._bitmap.release();
            }
            if(this._bBaseLayer)
            {
               for each(_loc5_ in this._receivedData)
               {
                  this._bitmap.setLayer(_loc5_.l,_loc5_.d,_loc5_.c);
               }
               this._totalFrames = this._bitmap.length;
            }
         }
      }
   }
}

class SingletonLock
{
   
   public function SingletonLock()
   {
      super();
   }
}
