package com.sbi.graphics
{
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
      
      public function LayerAnim(lock:Class)
      {
         super();
         if(lock != SingletonLock)
         {
            throw new Error("Invalid access.  Use LayerAnim.getNew");
         }
         this._requestedIds = new Array();
         this._colors = new Array();
      }
      
      public static function set avOffsets(a:Array) : void
      {
         _avOffsets = a;
      }
      
      public static function getAvOffset(avDefId:int) : Point
      {
         if(Boolean(_avOffsets[avDefId]))
         {
            return _avOffsets[avDefId];
         }
         return new Point(-100,-100);
      }
      
      public static function set throttle(t:int) : void
      {
         _throttle = t;
      }
      
      public static function getNew() : LayerAnim
      {
         var an:LayerAnim = null;
         if(!_activePool)
         {
            _activePool = new Array();
            _freePool = new Array();
         }
         if(Boolean(_freePool.length))
         {
            an = _freePool.pop();
         }
         else
         {
            an = new LayerAnim(SingletonLock);
         }
         _activePool.push(an);
         an.init();
         return an;
      }
      
      public static function destroy(an:LayerAnim) : void
      {
         var i:int = _activePool.indexOf(an);
         if(i >= 0)
         {
            _activePool.splice(i,1);
            an.destroy();
            _freePool.push(an);
         }
      }
      
      public static function heartbeat() : void
      {
         var total:int = 0;
         var countdown:int = 0;
         var throttle:int = 0;
         var i:int = 0;
         var la:LayerAnim = null;
         var tStep:int = 0;
         if(Boolean(_activePool) && Boolean(_activePool.length))
         {
            total = int(_activePool.length);
            countdown = total;
            throttle = total * 0.5;
            if(throttle < 1 || Boolean(_useMaxThrottle) && Boolean(_useMaxThrottle()))
            {
               throttle = 1;
            }
            if(throttle > _throttle)
            {
               throttle = _throttle;
            }
            i = _lastEntry;
            for each(la in _activePool)
            {
               ++la._tStep;
            }
            while(throttle > 0 && countdown > 0)
            {
               if(i >= total)
               {
                  i = 0;
               }
               la = _activePool[i++];
               tStep = la._tStep;
               if(tStep >= 2)
               {
                  if((la._requestMode == PLAY_ONE_SHOT || isOnscreen(la)) && la.heartbeat())
                  {
                     la._tStep = 0;
                     throttle--;
                  }
               }
               countdown--;
            }
            _lastEntry = i;
         }
      }
      
      private static function isOnscreen(la:LayerAnim) : Boolean
      {
         var left1:int = 0;
         var right1:int = 0;
         var top1:int = 0;
         var bottom1:int = 0;
         var rect:Rectangle = null;
         var theParent:DisplayObjectContainer = la.bitmap.parent;
         if(Boolean(theParent))
         {
            left1 = 0;
            right1 = 900;
            top1 = 0;
            bottom1 = 550;
            rect = theParent.getBounds(gMainFrame.stage);
            return rect.height == 0 || !(bottom1 < rect.top || top1 > rect.bottom || right1 < rect.left || left1 > rect.right);
         }
         return true;
      }
      
      public static function set useMaxThrottle(func:Function) : void
      {
         _useMaxThrottle = func;
      }
      
      public function get bounceEnabled() : Boolean
      {
         return this._bounceEnabled;
      }
      
      public function set bounceEnabled(b:Boolean) : void
      {
         this._bounceEnabled = b;
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
      
      public function set avDefId(i:int) : void
      {
         if(i != this._avDefId)
         {
            this._avDefId = i;
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
      
      public function set frame(f:int) : void
      {
         this._frame = f;
      }
      
      public function set avatarEnabled(b:Boolean) : void
      {
         this._avatarEnabled = b;
      }
      
      public function set layers(l:Array) : void
      {
         var i:int = 0;
         var o:Object = null;
         var layerIndex:int = 0;
         var bDiffLayer:Boolean = true;
         var bDiffColor:Boolean = false;
         if(Boolean(this._layers) && this._layers.length == l.length)
         {
            bDiffLayer = false;
            for(i = 0; i < l.length; i++)
            {
               if(this._layers[i].l != l[i].l)
               {
                  bDiffLayer = true;
                  break;
               }
               if(this._layers[i].c != l[i].c)
               {
                  bDiffColor = true;
               }
            }
            if(!bDiffLayer && !bDiffColor)
            {
               return;
            }
         }
         if(l.length > 0)
         {
            this._layers = l;
            if(bDiffLayer)
            {
               this._bReload = true;
            }
            else if(bDiffColor)
            {
               for each(o in l)
               {
                  layerIndex = ImageServerURL.instance.getLayerIndex(o.l);
                  this._bitmap.setLayerColor(layerIndex,o.c);
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
      
      public function set x(x:int) : void
      {
         this._x = x;
      }
      
      public function set y(y:int) : void
      {
         this._y = y;
      }
      
      public function set alpha(a:Number) : void
      {
         this._bitmap.alpha = a;
      }
      
      public function set rotation(deg:Number) : void
      {
         this._rotation = deg;
      }
      
      public function set hFlip(f:Boolean) : void
      {
         if(f != this._hFlip)
         {
            this._hFlip = f;
            this._bRedraw = true;
         }
      }
      
      public function set visible(f:Boolean) : void
      {
         this._bitmap.visible = f;
      }
      
      public function get visible() : Boolean
      {
         return this._bitmap.visible;
      }
      
      public function set pause(p:Boolean) : void
      {
         this._bPause = p;
      }
      
      public function get bitmap() : LayerBitmap
      {
         return this._bitmap;
      }
      
      public function playAnim(animId:int, mode:int = 0, callback:Function = null) : void
      {
         if(this._requestAnimId == -1 && animId != this._animId || this._requestAnimId != animId)
         {
            this._requestCallback = callback;
            this._requestMode = mode;
            this._requestAnimId = animId;
            this._bReload = true;
         }
      }
      
      public function preload(animList:Array, callback:Function) : void
      {
         var i:int = 0;
         this._preloadCallback = callback;
         for(this._preloadRequestedIds = []; i < animList.length; )
         {
            this.buildRequestArray(animList[i],this._preloadRequestedIds,null);
            i++;
         }
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
         ImageServerURL.instance.requestImages(this._preloadRequestedIds.slice());
      }
      
      private function heartbeat() : Boolean
      {
         var bounceHeight:int = 0;
         var bPainted:Boolean = false;
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
            bPainted = this._bitmap.paint(this._frame,this._hFlip);
         }
         var offSet:int = 0;
         if(this._bounceEnabled)
         {
            bounceHeight = 150;
            offSet = bounceHeight * (this._frame + 1) / this._totalFrames;
            if(offSet > bounceHeight / 2)
            {
               offSet = bounceHeight - offSet;
            }
         }
         this.updateBitmapPos(offSet);
         if(!this._bPause)
         {
            ++this._frame;
         }
         return bPainted;
      }
      
      private function loadAnim() : void
      {
         var anId:int = 0;
         if(this._layers != null && this._layers.length > 0)
         {
            anId = this._requestAnimId != -1 ? this._requestAnimId : this._animId;
            if(anId >= 0)
            {
               this._requestAnimId = anId;
               this.requestAnim(anId);
            }
         }
      }
      
      public function updateBitmapPos(offSet:int) : void
      {
         var m:Matrix = null;
         var ap:Point = this._bitmap.anchorPoint;
         var x:int = this._x + ap.x + this._xOff;
         var y:int = this._y + ap.y + this._yOff - offSet;
         if(Boolean(this._rotation))
         {
            m = this._bitmap.transform.matrix;
            m.identity();
            m.translate(ap.x + this._xOff,ap.y + this._yOff);
            m.rotate(this._rotation * (Math.PI / 180));
            m.translate(x,y);
            this._bitmap.transform.matrix = m;
         }
         else
         {
            if(this._bitmap.rotation != this._rotation)
            {
               this._bitmap.rotation = this._rotation;
            }
            this._bitmap.x = x;
            this._bitmap.y = y;
         }
      }
      
      private function requestAnim(id:int) : void
      {
         this._bNewAnim = false;
         this._requestedIds.splice(0,this._requestedIds.length);
         this._colors = [];
         this._receivedData = [];
         this.buildRequestArray(id,this._requestedIds,this._colors);
         ImageServerURL.instance.addEventListener(ImageServerEvent.ON_NEW_DATA,this.onReceiveData);
         ImageServerURL.instance.requestImages(this._requestedIds.slice());
         this._bReload = false;
         this._bBaseLayer = false;
      }
      
      private function buildRequestArray(id:int, a:Array, colors:Array) : void
      {
         var o:Object = null;
         var packId:uint = 0;
         a.push(ImageArrayHelper.packId(this._avDefId,id,0));
         for each(o in this._layers)
         {
            packId = ImageArrayHelper.packId(this._avDefId,id,o.l);
            a.push(packId);
            if(Boolean(colors))
            {
               colors[packId] = o.c;
            }
         }
      }
      
      private function onReceiveData(e:ImageServerEvent) : void
      {
         var i:int = 0;
         var color:uint = 0;
         var o:Object = null;
         var layer:int = e.layer;
         if(Boolean(this._preloadRequestedIds) && Boolean(this._preloadRequestedIds.length))
         {
            i = this._preloadRequestedIds.indexOf(e.id);
            if(i >= 0)
            {
               this._preloadRequestedIds.splice(i,1);
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
         i = this._requestedIds.indexOf(e.id);
         if(i >= 0)
         {
            this._requestedIds.splice(i,1);
            if(layer > 0)
            {
               color = uint(this._colors[e.id]);
            }
            if(e.success)
            {
               this._receivedData.push({
                  "l":layer,
                  "d":e.imageData,
                  "c":color
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
            if(layer == 1 || this._bNewAnim)
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
               for each(o in this._receivedData)
               {
                  this._bitmap.setLayer(o.l,o.d,o.c);
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
