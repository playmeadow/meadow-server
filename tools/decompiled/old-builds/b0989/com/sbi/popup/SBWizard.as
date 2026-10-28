package com.sbi.popup
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class SBWizard
   {
      
      public var screens:Array;
      
      private var _step:int;
      
      private var _useSeparateScreens:Boolean;
      
      public var wizClip:MovieClip;
      
      public function SBWizard()
      {
         super();
      }
      
      public function init(param1:MovieClip, param2:Boolean = true, param3:int = 0, param4:Array = null, param5:Boolean = true, param6:Boolean = false, param7:Boolean = false) : void
      {
         var _loc9_:int = 0;
         var _loc10_:DisplayObject = null;
         var _loc11_:SBScreen = null;
         var _loc12_:int = 0;
         if(param1 == null)
         {
            throw new Error("invalid null initWizClip!");
         }
         this.wizClip = param1;
         this._useSeparateScreens = param6;
         if(!param2 && param6)
         {
            this.wizClip.visible = false;
         }
         var _loc8_:int = param6 == false ? int(param4.length) : this.wizClip.totalFrames;
         if(param4)
         {
            this.screens = param4;
         }
         else
         {
            this.screens = [];
            if(_loc8_ > 0)
            {
               _loc9_ = 0;
               while(_loc9_ < _loc8_)
               {
                  this.wizClip.gotoAndStop(_loc9_ + 1);
                  _loc10_ = this.wizClip.getChildAt(0);
                  _loc11_ = new SBScreen(_loc10_ as MovieClip,this);
                  _loc11_.screenClip.visible = false;
                  this.screens.push(_loc11_);
                  _loc9_++;
               }
               if(this.screens.length != uint(_loc8_))
               {
                  throw new Error("SBWizard - Failed assertion: lengths must be equal- screens.length:" + this.screens.length + " uint(framesLength):" + uint(_loc8_));
               }
            }
         }
         this.wizClip.enabled = param5;
         this.step = param3;
         if(param6)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc8_)
            {
               this.wizClip.addChild(this.screens[_loc12_].screenClip);
               _loc12_++;
            }
            if(param3 > 0 && param3 <= _loc8_)
            {
               this.screens[param3 - 1].screenClip.visible = true;
            }
         }
         this.wizClip.stop();
      }
      
      public function destroy() : void
      {
         this.screens.splice(0,this.screens.length);
         this.screens = null;
         this.wizClip = null;
      }
      
      public function get step() : int
      {
         return this._step;
      }
      
      public function set step(param1:int) : void
      {
         if(param1 == this._step)
         {
            return;
         }
         this.jumpToStep(param1);
      }
      
      public function get currScreen() : SBScreen
      {
         return this.screens[this._step - 1];
      }
      
      public function get nextScreen() : SBScreen
      {
         if(Boolean(this.screens) && this._step < this.screens.length - 2)
         {
            return this.screens[int(this._step)];
         }
         return null;
      }
      
      public function get prevScreen() : SBScreen
      {
         if(Boolean(this._step > 0) && Boolean(this.screens) && this.screens.length >= this._step)
         {
            return this.screens[int(this._step - 2)];
         }
         return null;
      }
      
      public function jumpToStep(param1:int) : void
      {
         var _loc3_:SBScreen = null;
         var _loc4_:Function = null;
         var _loc5_:SBScreen = null;
         var _loc6_:Function = null;
         if(!this.screens || param1 < 0 || param1 > this.screens.length + 1)
         {
            throw new Error("illegal wizard step:" + param1 + " screens:" + (this.screens ? this.screens.length : this.screens));
         }
         if(!this.wizClip.enabled || param1 == this._step)
         {
            return;
         }
         var _loc2_:Boolean = Boolean(param1 > this._step);
         if(this._step > 0 && this._step <= this.screens.length)
         {
            _loc3_ = this.screens[this._step - 1];
            if(this._useSeparateScreens)
            {
               _loc3_.screenClip.visible = false;
            }
            _loc4_ = _loc2_ ? _loc3_.onLeaveToNext : _loc3_.onLeaveToPrev;
            if(_loc4_ != null)
            {
               if(!_loc4_())
               {
                  return;
               }
            }
         }
         this._step = param1;
         if(param1 > 0 && param1 <= this.screens.length)
         {
            _loc5_ = this.screens[param1 - 1];
            if(this._useSeparateScreens)
            {
               _loc5_.screenClip.visible = true;
            }
            _loc6_ = _loc2_ ? _loc5_.onEnterFromPrev : _loc5_.onEnterFromNext;
            if(_loc6_ != null)
            {
               _loc6_();
            }
         }
      }
      
      public function jumpToScreen(param1:SBScreen) : void
      {
         var _loc2_:int = this.screens.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this.jumpToStep(_loc2_ + 1);
            return;
         }
         throw new Error("SBWizard jumpToScreen - screen:" + param1 + " not found!");
      }
      
      public function next() : void
      {
         this.jumpToStep(this._step + 1);
      }
      
      public function prev() : void
      {
         this.jumpToStep(this._step - 1);
      }
      
      public function onPlay() : void
      {
         this.currScreen.onPlay();
      }
      
      public function onClose() : void
      {
         this.currScreen.onClose();
      }
      
      public function addScreen(param1:SBScreen, param2:int = 0) : void
      {
         if(!this.screens)
         {
            throw new Error("Tried to addScreen on an uninitialized wizard!");
         }
         if(param2 == 0)
         {
            this.screens.push(param1);
         }
         else
         {
            if(param2 < 0 || param2 > this.screens.length)
            {
               throw new Error("illegal step:" + param2 + " while trying to addScreen");
            }
            this.screens.splice(param2 - 1,0,param1);
         }
      }
      
      public function removeScreen(param1:int = 0) : void
      {
         if(!this.screens || this.screens.length == 0)
         {
            throw new Error("Tried to removeScreen on an empty wizard!");
         }
         if(param1 == 0)
         {
            this.screens.pop();
         }
         else
         {
            if(param1 < 0 || param1 > this.screens.length)
            {
               throw new Error("illegal step:" + param1 + " while trying to removeScreen");
            }
            this.screens.splice(param1 - 1,1);
         }
      }
   }
}

