package gskinner.motion
{
   import flash.display.Shape;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IEventDispatcher;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class GTween extends EventDispatcher
   {
      
      protected static var shape:Shape;
      
      protected static var time:Number;
      
      public static var version:Number = 2.01;
      
      public static var defaultDispatchEvents:Boolean = false;
      
      public static var defaultEase:Function = linearEase;
      
      public static var pauseAll:Boolean = false;
      
      public static var timeScaleAll:Number = 1;
      
      protected static var hasStarPlugins:Boolean = false;
      
      protected static var plugins:Object = {};
      
      protected static var tickList:Dictionary = new Dictionary(true);
      
      protected static var gcLockList:Dictionary = new Dictionary(false);
      
      staticInit();
      
      protected var _delay:Number = 0;
      
      protected var _values:Object;
      
      protected var _paused:Boolean = true;
      
      protected var _position:Number;
      
      protected var _inited:Boolean;
      
      protected var _initValues:Object;
      
      protected var _rangeValues:Object;
      
      protected var _proxy:TargetProxy;
      
      public var autoPlay:Boolean = true;
      
      public var data:*;
      
      public var duration:Number;
      
      public var ease:Function;
      
      public var nextTween:GTween;
      
      public var pluginData:Object;
      
      public var reflect:Boolean;
      
      public var repeatCount:int = 1;
      
      public var target:Object;
      
      public var useFrames:Boolean;
      
      public var timeScale:Number = 1;
      
      public var positionOld:Number;
      
      public var ratio:Number;
      
      public var ratioOld:Number;
      
      public var calculatedPosition:Number;
      
      public var calculatedPositionOld:Number;
      
      public var suppressEvents:Boolean;
      
      public var dispatchEvents:Boolean;
      
      public var onComplete:Function;
      
      public var onChange:Function;
      
      public var onInit:Function;
      
      public function GTween(target:Object = null, duration:Number = 1, values:Object = null, props:Object = null, pluginData:Object = null)
      {
         var swap:Boolean = false;
         super();
         this.ease = defaultEase;
         this.dispatchEvents = defaultDispatchEvents;
         this.target = target;
         this.duration = duration;
         this.pluginData = this.copy(pluginData,{});
         if(Boolean(props))
         {
            swap = Boolean(props.swapValues);
            delete props.swapValues;
         }
         this.copy(props,this);
         this.resetValues(values);
         if(swap)
         {
            this.swapValues();
         }
         if(this.duration == 0 && this.delay == 0 && this.autoPlay)
         {
            this.position = 0;
         }
      }
      
      public static function installPlugin(plugin:Object, propertyNames:Array, highPriority:Boolean = false) : void
      {
         var propertyName:String = null;
         for(var i:uint = 0; i < propertyNames.length; i++)
         {
            propertyName = propertyNames[i];
            if(propertyName == "*")
            {
               hasStarPlugins = true;
            }
            if(plugins[propertyName] == null)
            {
               plugins[propertyName] = [plugin];
            }
            else if(highPriority)
            {
               plugins[propertyName].unshift(plugin);
            }
            else
            {
               plugins[propertyName].push(plugin);
            }
         }
      }
      
      public static function linearEase(a:Number, b:Number, c:Number, d:Number) : Number
      {
         return a;
      }
      
      protected static function staticInit() : void
      {
         (shape = new Shape()).addEventListener(Event.ENTER_FRAME,staticTick);
         time = getTimer() / 1000;
      }
      
      protected static function staticTick(evt:Event) : void
      {
         var o:Object = null;
         var tween:GTween = null;
         var t:Number = time;
         time = getTimer() / 1000;
         if(pauseAll)
         {
            return;
         }
         var dt:Number = (time - t) * timeScaleAll;
         for(o in tickList)
         {
            tween = o as GTween;
            tween.position = tween._position + (tween.useFrames ? timeScaleAll : dt) * tween.timeScale;
         }
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function set paused(value:Boolean) : void
      {
         if(value == this._paused)
         {
            return;
         }
         this._paused = value;
         if(this._paused)
         {
            delete tickList[this];
            if(this.target is IEventDispatcher)
            {
               this.target.removeEventListener("_",this.invalidate);
            }
            delete gcLockList[this];
         }
         else
         {
            if(isNaN(this._position) || this.repeatCount != 0 && this._position >= this.repeatCount * this.duration)
            {
               this._inited = false;
               this.calculatedPosition = this.calculatedPositionOld = this.ratio = this.ratioOld = this.positionOld = 0;
               this._position = -this.delay;
            }
            tickList[this] = true;
            if(this.target is IEventDispatcher)
            {
               this.target.addEventListener("_",this.invalidate);
            }
            else
            {
               gcLockList[this] = true;
            }
         }
      }
      
      public function get position() : Number
      {
         return this._position;
      }
      
      public function set position(value:Number) : void
      {
         var n:String = null;
         var initVal:Number = NaN;
         var rangeVal:Number = NaN;
         var val:Number = NaN;
         var pluginArr:Array = null;
         var l:uint = 0;
         var i:uint = 0;
         this.positionOld = this._position;
         this.ratioOld = this.ratio;
         this.calculatedPositionOld = this.calculatedPosition;
         var maxPosition:Number = this.repeatCount * this.duration;
         var end:Boolean = value >= maxPosition && this.repeatCount > 0;
         if(end)
         {
            if(this.calculatedPositionOld == maxPosition)
            {
               return;
            }
            this._position = maxPosition;
            this.calculatedPosition = this.reflect && !(this.repeatCount & 1) ? 0 : this.duration;
         }
         else
         {
            this._position = value;
            this.calculatedPosition = this._position < 0 ? 0 : this._position % this.duration;
            if(this.reflect && Boolean(this._position / this.duration & 1))
            {
               this.calculatedPosition = this.duration - this.calculatedPosition;
            }
         }
         this.ratio = this.duration == 0 && this._position >= 0 ? 1 : Number(this.ease(this.calculatedPosition / this.duration,0,1,1));
         if(Boolean(this.target) && (Boolean(this._position >= 0 || this.positionOld >= 0)) && this.calculatedPosition != this.calculatedPositionOld)
         {
            if(!this._inited)
            {
               this.init();
            }
            for(n in this._values)
            {
               initVal = Number(this._initValues[n]);
               rangeVal = Number(this._rangeValues[n]);
               val = initVal + rangeVal * this.ratio;
               pluginArr = plugins[n];
               if(Boolean(pluginArr))
               {
                  l = pluginArr.length;
                  for(i = 0; i < l; i++)
                  {
                     val = Number(pluginArr[i].tween(this,n,val,initVal,rangeVal,this.ratio,end));
                  }
                  if(!isNaN(val))
                  {
                     this.target[n] = val;
                  }
               }
               else
               {
                  this.target[n] = val;
               }
            }
         }
         if(hasStarPlugins)
         {
            pluginArr = plugins["*"];
            l = pluginArr.length;
            for(i = 0; i < l; i++)
            {
               pluginArr[i].tween(this,"*",NaN,NaN,NaN,this.ratio,end);
            }
         }
         if(!this.suppressEvents)
         {
            if(this.dispatchEvents)
            {
               this.dispatchEvt("change");
            }
            if(this.onChange != null)
            {
               this.onChange(this);
            }
         }
         if(end)
         {
            this.paused = true;
            if(Boolean(this.nextTween))
            {
               this.nextTween.paused = false;
            }
            if(!this.suppressEvents)
            {
               if(this.dispatchEvents)
               {
                  this.dispatchEvt("complete");
               }
               if(this.onComplete != null)
               {
                  this.onComplete(this);
               }
            }
         }
      }
      
      public function get delay() : Number
      {
         return this._delay;
      }
      
      public function set delay(value:Number) : void
      {
         if(this._position <= 0)
         {
            this._position = -value;
         }
         this._delay = value;
      }
      
      public function get proxy() : TargetProxy
      {
         if(this._proxy == null)
         {
            this._proxy = new TargetProxy(this);
         }
         return this._proxy;
      }
      
      public function setValue(name:String, value:Number) : void
      {
         this._values[name] = value;
         this.invalidate();
      }
      
      public function getValue(name:String) : Number
      {
         return this._values[name];
      }
      
      public function deleteValue(name:String) : Boolean
      {
         delete this._rangeValues[name];
         delete this._initValues[name];
         return delete this._values[name];
      }
      
      public function setValues(values:Object) : void
      {
         this.copy(values,this._values,true);
         this.invalidate();
      }
      
      public function resetValues(values:Object = null) : void
      {
         this._values = {};
         this.setValues(values);
      }
      
      public function getValues() : Object
      {
         return this.copy(this._values,{});
      }
      
      public function getInitValue(name:String) : Number
      {
         return this._initValues[name];
      }
      
      public function swapValues() : void
      {
         var n:String = null;
         var pos:Number = NaN;
         if(!this._inited)
         {
            this.init();
         }
         var o:Object = this._values;
         this._values = this._initValues;
         this._initValues = o;
         for(n in this._rangeValues)
         {
            this._rangeValues[n] *= -1;
         }
         if(this._position < 0)
         {
            pos = this.positionOld;
            this.position = 0;
            this._position = this.positionOld;
            this.positionOld = pos;
         }
         else
         {
            this.position = this._position;
         }
      }
      
      public function init() : void
      {
         var n:String = null;
         var pluginArr:Array = null;
         var l:uint = 0;
         var value:Number = NaN;
         var i:uint = 0;
         this._inited = true;
         this._initValues = {};
         this._rangeValues = {};
         for(n in this._values)
         {
            if(Boolean(plugins[n]))
            {
               pluginArr = plugins[n];
               l = pluginArr.length;
               value = n in this.target ? Number(this.target[n]) : NaN;
               for(i = 0; i < l; i++)
               {
                  value = Number(pluginArr[i].init(this,n,value));
               }
               if(!isNaN(value))
               {
                  this._rangeValues[n] = this._values[n] - (this._initValues[n] = value);
               }
            }
            else
            {
               this._rangeValues[n] = this._values[n] - (this._initValues[n] = this.target[n]);
            }
         }
         if(hasStarPlugins)
         {
            pluginArr = plugins["*"];
            l = pluginArr.length;
            for(i = 0; i < l; i++)
            {
               pluginArr[i].init(this,"*",NaN);
            }
         }
         if(!this.suppressEvents)
         {
            if(this.dispatchEvents)
            {
               this.dispatchEvt("init");
            }
            if(this.onInit != null)
            {
               this.onInit(this);
            }
         }
      }
      
      public function beginning() : void
      {
         this.position = 0;
         this.paused = true;
      }
      
      public function end() : void
      {
         this.position = this.repeatCount > 0 ? this.repeatCount * this.duration : this.duration;
      }
      
      protected function invalidate() : void
      {
         this._inited = false;
         if(this._position > 0)
         {
            this._position = 0;
         }
         if(this.autoPlay)
         {
            this.paused = false;
         }
      }
      
      protected function copy(o1:Object, o2:Object, smart:Boolean = false) : Object
      {
         var n:String = null;
         for(n in o1)
         {
            if(smart && o1[n] == null)
            {
               delete o2[n];
            }
            else
            {
               o2[n] = o1[n];
            }
         }
         return o2;
      }
      
      protected function dispatchEvt(name:String) : void
      {
         if(hasEventListener(name))
         {
            dispatchEvent(new Event(name));
         }
      }
   }
}

import flash.utils.Proxy;
import flash.utils.flash_proxy;
import gskinner.motion.GTween;

use namespace flash_proxy;

dynamic class TargetProxy extends Proxy
{
   
   private var tween:GTween;
   
   public function TargetProxy(tween:GTween)
   {
      super();
      this.tween = tween;
   }
   
   override flash_proxy function callProperty(methodName:*, ... args) : *
   {
      return this.tween.target[methodName].apply(null,args);
   }
   
   override flash_proxy function getProperty(prop:*) : *
   {
      var value:Number = Number(this.tween.getValue(prop));
      return isNaN(value) ? this.tween.target[prop] : value;
   }
   
   override flash_proxy function setProperty(prop:*, value:*) : void
   {
      if(value is Boolean || value is String || isNaN(value))
      {
         this.tween.target[prop] = value;
      }
      else
      {
         this.tween.setValue(String(prop),Number(value));
      }
   }
   
   override flash_proxy function deleteProperty(prop:*) : Boolean
   {
      this.tween.deleteValue(prop);
      return true;
   }
}
