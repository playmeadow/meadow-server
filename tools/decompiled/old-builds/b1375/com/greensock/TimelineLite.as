package com.greensock
{
   import com.greensock.core.Animation;
   import com.greensock.core.SimpleTimeline;
   
   public class TimelineLite extends SimpleTimeline
   {
      
      public static const version:String = "12.1.5";
      
      protected var _labels:Object;
      
      public function TimelineLite(param1:Object = null)
      {
         var _loc3_:String = null;
         var _loc2_:Object = null;
         super(param1);
         _labels = {};
         autoRemoveChildren = this.vars.autoRemoveChildren == true;
         smoothChildTiming = this.vars.smoothChildTiming == true;
         _sortChildren = true;
         _onUpdate = this.vars.onUpdate;
         for(_loc3_ in this.vars)
         {
            _loc2_ = this.vars[_loc3_];
            if(_loc2_ is Array)
            {
               if(_loc2_.join("").indexOf("{self}") !== -1)
               {
                  this.vars[_loc3_] = _swapSelfInParams(_loc2_ as Array);
               }
            }
         }
         if(this.vars.tweens is Array)
         {
            this.add(this.vars.tweens,0,this.vars.align || "normal",this.vars.stagger || 0);
         }
      }
      
      protected static function _prepVars(param1:Object) : Object
      {
         return param1._isGSVars ? param1.vars : param1;
      }
      
      protected static function _copy(param1:Object) : Object
      {
         var _loc2_:String = null;
         var _loc3_:Object = {};
         for(_loc2_ in param1)
         {
            _loc3_[_loc2_] = param1[_loc2_];
         }
         return _loc3_;
      }
      
      public static function exportRoot(param1:Object = null, param2:Boolean = true) : TimelineLite
      {
         var _loc4_:TimelineLite = null;
         var _loc6_:Animation = null;
         param1 ||= {};
         if(!("smoothChildTiming" in param1))
         {
            param1.smoothChildTiming = true;
         }
         _loc4_ = new TimelineLite(param1);
         var _loc5_:SimpleTimeline = _loc4_._timeline;
         _loc5_._remove(_loc4_,true);
         _loc4_._startTime = 0;
         _loc4_._rawPrevTime = _loc4_._time = _loc4_._totalTime = _loc5_._time;
         var _loc3_:Animation = _loc5_._first;
         while(_loc3_)
         {
            _loc6_ = _loc3_._next;
            if(!param2 || !(_loc3_ is TweenLite && TweenLite(_loc3_).target == _loc3_.vars.onComplete))
            {
               _loc4_.add(_loc3_,_loc3_._startTime - _loc3_._delay);
            }
            _loc3_ = _loc6_;
         }
         _loc5_.add(_loc4_,0);
         return _loc4_;
      }
      
      public function to(param1:Object, param2:Number, param3:Object, param4:* = "+=0") : *
      {
         return param2 ? add(new TweenLite(param1,param2,param3),param4) : this.set(param1,param3,param4);
      }
      
      public function from(param1:Object, param2:Number, param3:Object, param4:* = "+=0") : *
      {
         return add(TweenLite.from(param1,param2,param3),param4);
      }
      
      public function fromTo(param1:Object, param2:Number, param3:Object, param4:Object, param5:* = "+=0") : *
      {
         return param2 ? add(TweenLite.fromTo(param1,param2,param3,param4),param5) : this.set(param1,param4,param5);
      }
      
      public function staggerTo(param1:Array, param2:Number, param3:Object, param4:Number, param5:* = "+=0", param6:Function = null, param7:Array = null) : *
      {
         var _loc9_:int = 0;
         var _loc8_:TimelineLite = new TimelineLite({
            "onComplete":param6,
            "onCompleteParams":param7,
            "smoothChildTiming":this.smoothChildTiming
         });
         _loc9_ = 0;
         while(_loc9_ < param1.length)
         {
            if(param3.startAt != null)
            {
               param3.startAt = _copy(param3.startAt);
            }
            _loc8_.to(param1[_loc9_],param2,_copy(param3),_loc9_ * param4);
            _loc9_++;
         }
         return add(_loc8_,param5);
      }
      
      public function staggerFrom(param1:Array, param2:Number, param3:Object, param4:Number = 0, param5:* = "+=0", param6:Function = null, param7:Array = null) : *
      {
         param3 = _prepVars(param3);
         if(!("immediateRender" in param3))
         {
            param3.immediateRender = true;
         }
         param3.runBackwards = true;
         return staggerTo(param1,param2,param3,param4,param5,param6,param7);
      }
      
      public function staggerFromTo(param1:Array, param2:Number, param3:Object, param4:Object, param5:Number = 0, param6:* = "+=0", param7:Function = null, param8:Array = null) : *
      {
         param4 = _prepVars(param4);
         param3 = _prepVars(param3);
         param4.startAt = param3;
         param4.immediateRender = param4.immediateRender != false && param3.immediateRender != false;
         return staggerTo(param1,param2,param4,param5,param6,param7,param8);
      }
      
      public function call(param1:Function, param2:Array = null, param3:* = "+=0") : *
      {
         return add(TweenLite.delayedCall(0,param1,param2),param3);
      }
      
      public function set(param1:Object, param2:Object, param3:* = "+=0") : *
      {
         param3 = _parseTimeOrLabel(param3,0,true);
         param2 = _prepVars(param2);
         if(param2.immediateRender == null)
         {
            param2.immediateRender = param3 === _time && !_paused;
         }
         return add(new TweenLite(param1,0,param2),param3);
      }
      
      public function addPause(param1:* = "+=0", param2:Function = null, param3:Array = null) : *
      {
         return call(_pauseCallback,["{self}",param2,param3],param1);
      }
      
      protected function _pauseCallback(param1:TweenLite, param2:Function = null, param3:Array = null) : void
      {
         pause(param1._startTime);
         if(param2 != null)
         {
            param2.apply(null,param3);
         }
      }
      
      override public function insert(param1:*, param2:* = 0) : *
      {
         return add(param1,param2 || 0);
      }
      
      override public function add(param1:*, param2:* = "+=0", param3:String = "normal", param4:Number = 0) : *
      {
         var _loc5_:* = undefined;
         var _loc10_:int = 0;
         var _loc6_:SimpleTimeline = null;
         if(typeof param2 !== "number")
         {
            param2 = _parseTimeOrLabel(param2,0,true,param1);
         }
         if(!(param1 is Animation))
         {
            if(param1 is Array)
            {
               var _loc7_:Number = param2;
               var _loc8_:Number = Number(param1.length);
               _loc10_ = 0;
               while(_loc10_ < _loc8_)
               {
                  _loc5_ = param1[_loc10_];
                  if(_loc5_ is Array)
                  {
                     _loc5_ = new TimelineLite({"tweens":_loc5_});
                  }
                  add(_loc5_,_loc7_);
                  if(!(typeof _loc5_ === "string" || typeof _loc5_ === "function"))
                  {
                     switch(param3)
                     {
                        case "sequence":
                           _loc7_ = _loc5_._startTime + _loc5_.totalDuration() / _loc5_._timeScale;
                           break;
                        case "start":
                           _loc5_._startTime -= _loc5_.delay();
                     }
                  }
                  _loc7_ += param4;
                  _loc10_++;
               }
               return _uncache(true);
            }
            if(typeof param1 === "string")
            {
               return addLabel(String(param1),param2);
            }
            if(typeof param1 !== "function")
            {
               trace("Cannot add " + param1 + " into the TimelineLite/Max: it is not a tween, timeline, function, or string.");
               return this;
            }
            param1 = TweenLite.delayedCall(0,param1);
         }
         super.add(param1,param2);
         if(_gc || _time === _duration)
         {
            if(!_paused)
            {
               if(_duration < duration())
               {
                  _loc6_ = this;
                  var _loc9_:Boolean = _loc6_.rawTime() > param1._startTime;
                  while(_loc6_._timeline)
                  {
                     if(_loc9_ && _loc6_._timeline.smoothChildTiming)
                     {
                        _loc6_.totalTime(_loc6_._totalTime,true);
                     }
                     else if(_loc6_._gc)
                     {
                        _loc6_._enabled(true,false);
                     }
                     _loc6_ = _loc6_._timeline;
                  }
               }
            }
         }
         return this;
      }
      
      public function remove(param1:*) : *
      {
         var _loc2_:Number = NaN;
         if(param1 is Animation)
         {
            return _remove(param1,false);
         }
         if(param1 is Array)
         {
            _loc2_ = Number(param1.length);
            while(--_loc2_ > -1)
            {
               remove(param1[_loc2_]);
            }
            return this;
         }
         if(typeof param1 == "string")
         {
            return removeLabel(String(param1));
         }
         return kill(null,param1);
      }
      
      override public function _remove(param1:Animation, param2:Boolean = false) : *
      {
         super._remove(param1,param2);
         if(_last == null)
         {
            _time = _totalTime = _duration = _totalDuration = 0;
         }
         else if(_time > _last._startTime + _last._totalDuration / _last._timeScale)
         {
            _time = duration();
            _totalTime = _totalDuration;
         }
         return this;
      }
      
      public function append(param1:*, param2:* = 0) : *
      {
         return add(param1,_parseTimeOrLabel(null,param2,true,param1));
      }
      
      public function insertMultiple(param1:Array, param2:* = 0, param3:String = "normal", param4:Number = 0) : *
      {
         return add(param1,param2 || 0,param3,param4);
      }
      
      public function appendMultiple(param1:Array, param2:* = 0, param3:String = "normal", param4:Number = 0) : *
      {
         return add(param1,_parseTimeOrLabel(null,param2,true,param1),param3,param4);
      }
      
      public function addLabel(param1:String, param2:* = "+=0") : *
      {
         _labels[param1] = _parseTimeOrLabel(param2);
         return this;
      }
      
      public function removeLabel(param1:String) : *
      {
         delete _labels[param1];
         return this;
      }
      
      public function getLabelTime(param1:String) : Number
      {
         return param1 in _labels ? Number(_labels[param1]) : -1;
      }
      
      protected function _parseTimeOrLabel(param1:*, param2:* = 0, param3:Boolean = false, param4:Object = null) : Number
      {
         var _loc5_:int = 0;
         if(param4 is Animation && param4.timeline === this)
         {
            remove(param4);
         }
         else if(param4 is Array)
         {
            _loc5_ = int(param4.length);
            while(--_loc5_ > -1)
            {
               if(param4[_loc5_] is Animation && param4[_loc5_].timeline === this)
               {
                  remove(param4[_loc5_]);
               }
            }
         }
         if(typeof param2 === "string")
         {
            return _parseTimeOrLabel(param2,param3 && typeof param1 === "number" && !(param2 in _labels) ? param1 - duration() : 0,param3);
         }
         param2 ||= 0;
         if(typeof param1 === "string" && (isNaN(param1) || param1 in _labels))
         {
            _loc5_ = int(param1.indexOf("="));
            if(_loc5_ === -1)
            {
               if(!(param1 in _labels))
               {
                  return param3 ? (_labels[param1] = duration() + param2) : param2;
               }
               return _labels[param1] + param2;
            }
            param2 = parseInt(param1.charAt(_loc5_ - 1) + "1",10) * Number(param1.substr(_loc5_ + 1));
            param1 = _loc5_ > 1 ? _parseTimeOrLabel(param1.substr(0,_loc5_ - 1),0,param3) : duration();
         }
         else if(param1 == null)
         {
            param1 = duration();
         }
         return Number(param1) + param2;
      }
      
      override public function seek(param1:*, param2:Boolean = true) : *
      {
         return totalTime(typeof param1 === "number" ? Number(param1) : _parseTimeOrLabel(param1),param2);
      }
      
      public function stop() : *
      {
         return paused(true);
      }
      
      public function gotoAndPlay(param1:*, param2:Boolean = true) : *
      {
         return play(param1,param2);
      }
      
      public function gotoAndStop(param1:*, param2:Boolean = true) : *
      {
         return pause(param1,param2);
      }
      
      override public function render(param1:Number, param2:Boolean = false, param3:Boolean = false) : void
      {
         var _loc6_:Animation = null;
         var _loc5_:Boolean = false;
         var _loc7_:Animation = null;
         var _loc12_:String = null;
         var _loc4_:Boolean = false;
         if(_gc)
         {
            _enabled(true,false);
         }
         var _loc9_:Number = Number(!_dirty ? _totalDuration : totalDuration());
         var _loc13_:Number = _time;
         var _loc11_:Number = _startTime;
         var _loc8_:Number = _timeScale;
         var _loc10_:Boolean = _paused;
         if(param1 >= _loc9_)
         {
            _totalTime = _time = _loc9_;
            if(!_reversed)
            {
               if(!_hasPausedChild())
               {
                  _loc5_ = true;
                  _loc12_ = "onComplete";
                  if(_duration === 0)
                  {
                     if(param1 === 0 || _rawPrevTime < 0 || _rawPrevTime === _tinyNum)
                     {
                        if(_rawPrevTime !== param1 && _first != null)
                        {
                           _loc4_ = true;
                           if(_rawPrevTime > _tinyNum)
                           {
                              _loc12_ = "onReverseComplete";
                           }
                        }
                     }
                  }
               }
            }
            _rawPrevTime = _duration !== 0 || !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
            param1 = _loc9_ + 0.0001;
         }
         else if(param1 < 1e-7)
         {
            _totalTime = _time = 0;
            if(_loc13_ !== 0 || _duration === 0 && _rawPrevTime !== _tinyNum && (_rawPrevTime > 0 || param1 < 0 && _rawPrevTime >= 0))
            {
               _loc12_ = "onReverseComplete";
               _loc5_ = _reversed;
            }
            if(param1 < 0)
            {
               _active = false;
               if(_rawPrevTime >= 0 && _first != null)
               {
                  _loc4_ = true;
               }
               _rawPrevTime = param1;
            }
            else
            {
               _rawPrevTime = _duration || !param2 || param1 !== 0 || _rawPrevTime === param1 ? param1 : _tinyNum;
               param1 = 0;
               if(!_initted)
               {
                  _loc4_ = true;
               }
            }
         }
         else
         {
            _totalTime = _time = _rawPrevTime = param1;
         }
         if((_time == _loc13_ || !_first) && !param3 && !_loc4_)
         {
            return;
         }
         if(!_initted)
         {
            _initted = true;
         }
         if(!_active)
         {
            if(!_paused && _time !== _loc13_ && param1 > 0)
            {
               _active = true;
            }
         }
         if(_loc13_ == 0)
         {
            if(vars.onStart)
            {
               if(_time != 0)
               {
                  if(!param2)
                  {
                     vars.onStart.apply(null,vars.onStartParams);
                  }
               }
            }
         }
         if(_time >= _loc13_)
         {
            _loc6_ = _first;
            while(_loc6_)
            {
               _loc7_ = _loc6_._next;
               if(_paused && !_loc10_)
               {
                  break;
               }
               if(_loc6_._active || _loc6_._startTime <= _time && !_loc6_._paused && !_loc6_._gc)
               {
                  if(!_loc6_._reversed)
                  {
                     _loc6_.render((param1 - _loc6_._startTime) * _loc6_._timeScale,param2,param3);
                  }
                  else
                  {
                     _loc6_.render((!_loc6_._dirty ? _loc6_._totalDuration : _loc6_.totalDuration()) - (param1 - _loc6_._startTime) * _loc6_._timeScale,param2,param3);
                  }
               }
               _loc6_ = _loc7_;
            }
         }
         else
         {
            _loc6_ = _last;
            while(_loc6_)
            {
               _loc7_ = _loc6_._prev;
               if(_paused && !_loc10_)
               {
                  break;
               }
               if(_loc6_._active || _loc6_._startTime <= _loc13_ && !_loc6_._paused && !_loc6_._gc)
               {
                  if(!_loc6_._reversed)
                  {
                     _loc6_.render((param1 - _loc6_._startTime) * _loc6_._timeScale,param2,param3);
                  }
                  else
                  {
                     _loc6_.render((!_loc6_._dirty ? _loc6_._totalDuration : _loc6_.totalDuration()) - (param1 - _loc6_._startTime) * _loc6_._timeScale,param2,param3);
                  }
               }
               _loc6_ = _loc7_;
            }
         }
         if(_onUpdate != null)
         {
            if(!param2)
            {
               _onUpdate.apply(null,vars.onUpdateParams);
            }
         }
         if(_loc12_)
         {
            if(!_gc)
            {
               if(_loc11_ == _startTime || _loc8_ != _timeScale)
               {
                  if(_time == 0 || _loc9_ >= totalDuration())
                  {
                     if(_loc5_)
                     {
                        if(_timeline.autoRemoveChildren)
                        {
                           _enabled(false,false);
                        }
                        _active = false;
                     }
                     if(!param2)
                     {
                        if(vars[_loc12_])
                        {
                           vars[_loc12_].apply(null,vars[_loc12_ + "Params"]);
                        }
                     }
                  }
               }
            }
         }
      }
      
      public function _hasPausedChild() : Boolean
      {
         var _loc1_:Animation = _first;
         while(_loc1_)
         {
            if(_loc1_._paused || _loc1_ is TimelineLite && Boolean(TimelineLite(_loc1_)._hasPausedChild()))
            {
               return true;
            }
            _loc1_ = _loc1_._next;
         }
         return false;
      }
      
      public function getChildren(param1:Boolean = true, param2:Boolean = true, param3:Boolean = true, param4:Number = -9999999999) : Array
      {
         var _loc7_:Array = [];
         var _loc5_:Animation = _first;
         var _loc6_:int = 0;
         while(_loc5_)
         {
            if(_loc5_._startTime >= param4)
            {
               if(_loc5_ is TweenLite)
               {
                  if(param2)
                  {
                     _loc7_[_loc6_++] = _loc5_;
                  }
               }
               else
               {
                  if(param3)
                  {
                     _loc7_[_loc6_++] = _loc5_;
                  }
                  if(param1)
                  {
                     _loc7_ = _loc7_.concat(TimelineLite(_loc5_).getChildren(true,param2,param3));
                     _loc6_ = int(_loc7_.length);
                  }
               }
            }
            _loc5_ = _loc5_._next;
         }
         return _loc7_;
      }
      
      public function getTweensOf(param1:Object, param2:Boolean = true) : Array
      {
         var _loc5_:Array = null;
         var _loc7_:int = 0;
         var _loc6_:Boolean = this._gc;
         var _loc4_:Array = [];
         var _loc3_:int = 0;
         if(_loc6_)
         {
            _enabled(true,true);
         }
         _loc5_ = TweenLite.getTweensOf(param1);
         _loc7_ = int(_loc5_.length);
         while(--_loc7_ > -1)
         {
            if(_loc5_[_loc7_].timeline === this || param2 && _contains(_loc5_[_loc7_]))
            {
               _loc4_[_loc3_++] = _loc5_[_loc7_];
            }
         }
         if(_loc6_)
         {
            _enabled(false,true);
         }
         return _loc4_;
      }
      
      private function _contains(param1:Animation) : Boolean
      {
         var _loc2_:SimpleTimeline = param1.timeline;
         while(_loc2_)
         {
            if(_loc2_ == this)
            {
               return true;
            }
            _loc2_ = _loc2_.timeline;
         }
         return false;
      }
      
      public function shiftChildren(param1:Number, param2:Boolean = false, param3:Number = 0) : *
      {
         var _loc4_:Animation = _first;
         while(_loc4_)
         {
            if(_loc4_._startTime >= param3)
            {
               _loc4_._startTime += param1;
            }
            _loc4_ = _loc4_._next;
         }
         if(param2)
         {
            for(var _loc5_:String in _labels)
            {
               if(_labels[_loc5_] >= param3)
               {
                  var _loc6_:String = _loc5_;
                  var _loc7_:Number = _labels[_loc6_] + param1;
                  _labels[_loc6_] = _loc7_;
               }
            }
         }
         _uncache(true);
         return this;
      }
      
      override public function _kill(param1:Object = null, param2:Object = null) : Boolean
      {
         var _loc3_:Array = null;
         if(param1 == null)
         {
            if(param2 == null)
            {
               return _enabled(false,false);
            }
         }
         _loc3_ = param2 == null ? getChildren(true,true,false) : getTweensOf(param2);
         var _loc5_:int = int(_loc3_.length);
         var _loc4_:Boolean = false;
         while(--_loc5_ > -1)
         {
            if(_loc3_[_loc5_]._kill(param1,param2))
            {
               _loc4_ = true;
            }
         }
         return _loc4_;
      }
      
      public function clear(param1:Boolean = true) : *
      {
         var _loc2_:Array = null;
         _loc2_ = getChildren(false,true,true);
         var _loc3_:int = int(_loc2_.length);
         _time = _totalTime = 0;
         while(--_loc3_ > -1)
         {
            _loc2_[_loc3_]._enabled(false,false);
         }
         if(param1)
         {
            _labels = {};
         }
         return _uncache(true);
      }
      
      override public function invalidate() : *
      {
         var _loc1_:Animation = _first;
         while(_loc1_)
         {
            _loc1_.invalidate();
            _loc1_ = _loc1_._next;
         }
         return this;
      }
      
      override public function _enabled(param1:Boolean, param2:Boolean = false) : Boolean
      {
         var _loc3_:Animation = null;
         if(param1 == _gc)
         {
            _loc3_ = _first;
            while(_loc3_)
            {
               _loc3_._enabled(param1,true);
               _loc3_ = _loc3_._next;
            }
         }
         return super._enabled(param1,param2);
      }
      
      override public function duration(param1:Number = NaN) : *
      {
         if(!arguments.length)
         {
            if(_dirty)
            {
               totalDuration();
            }
            return _duration;
         }
         if(duration() !== 0)
         {
            if(param1 !== 0)
            {
               timeScale(_duration / param1);
            }
         }
         return this;
      }
      
      override public function totalDuration(param1:Number = NaN) : *
      {
         var _loc7_:Animation = null;
         var _loc6_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!arguments.length)
         {
            if(_dirty)
            {
               _loc3_ = 0;
               var _loc4_:Animation = _last;
               var _loc5_:Number = Infinity;
               while(_loc4_)
               {
                  _loc7_ = _loc4_._prev;
                  if(_loc4_._dirty)
                  {
                     _loc4_.totalDuration();
                  }
                  if(_loc4_._startTime > _loc5_ && _sortChildren && !_loc4_._paused)
                  {
                     add(_loc4_,_loc4_._startTime - _loc4_._delay);
                  }
                  else
                  {
                     _loc5_ = _loc4_._startTime;
                  }
                  if(_loc4_._startTime < 0 && !_loc4_._paused)
                  {
                     _loc3_ -= _loc4_._startTime;
                     if(_timeline.smoothChildTiming)
                     {
                        _startTime += _loc4_._startTime / _timeScale;
                     }
                     shiftChildren(-_loc4_._startTime,false,-9999999999);
                     _loc5_ = 0;
                  }
                  _loc6_ = _loc4_._startTime + _loc4_._totalDuration / _loc4_._timeScale;
                  if(_loc6_ > _loc3_)
                  {
                     _loc3_ = _loc6_;
                  }
                  _loc4_ = _loc7_;
               }
               _duration = _totalDuration = _loc3_;
               _dirty = false;
            }
            return _totalDuration;
         }
         if(totalDuration() != 0)
         {
            if(param1 != 0)
            {
               timeScale(_totalDuration / param1);
            }
         }
         return this;
      }
      
      public function usesFrames() : Boolean
      {
         var _loc1_:SimpleTimeline = _timeline;
         while(_loc1_._timeline)
         {
            _loc1_ = _loc1_._timeline;
         }
         return _loc1_ == _rootFramesTimeline;
      }
      
      override public function rawTime() : Number
      {
         return _paused ? _totalTime : (_timeline.rawTime() - _startTime) * _timeScale;
      }
   }
}

