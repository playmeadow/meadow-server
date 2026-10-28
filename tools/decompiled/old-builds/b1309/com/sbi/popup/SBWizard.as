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
      
      public var creationAssets:Object;
      
      public function SBWizard()
      {
         super();
      }
      
      public function init(param1:MovieClip, param2:Object, param3:Boolean = true, param4:int = 1, param5:Array = null, param6:Boolean = true, param7:Boolean = false, param8:Boolean = false, param9:Boolean = false) : void
      {
         var _loc13_:int = 0;
         var _loc11_:DisplayObject = null;
         var _loc14_:SBScreen = null;
         var _loc12_:int = 0;
         if(param1 == null)
         {
            throw new Error("invalid null initWizClip!");
         }
         wizClip = param1;
         creationAssets = param2;
         _useSeparateScreens = param7;
         if(!param3 && param7)
         {
            wizClip.visible = false;
         }
         var _loc10_:int = int(param7 == false ? param5.length : wizClip.totalFrames);
         if(param5)
         {
            screens = param5;
         }
         else
         {
            screens = [];
            if(_loc10_ > 0)
            {
               _loc13_ = 0;
               while(_loc13_ < _loc10_)
               {
                  wizClip.gotoAndStop(_loc13_ + 1);
                  _loc11_ = wizClip.getChildAt(0);
                  _loc14_ = new SBScreen(_loc11_ as MovieClip,this);
                  _loc14_.screenClip.visible = false;
                  screens.push(_loc14_);
                  _loc13_++;
               }
               if(screens.length != uint(_loc10_))
               {
                  throw new Error("SBWizard - Failed assertion: lengths must be equal- screens.length:" + screens.length + " uint(framesLength):" + uint(_loc10_));
               }
            }
         }
         wizClip.enabled = param6;
         step = param4;
         if(param7)
         {
            _loc12_ = 0;
            while(_loc12_ < _loc10_)
            {
               wizClip.addChild(screens[_loc12_].screenClip);
               _loc12_++;
            }
            if(param4 > 0 && param4 <= _loc10_)
            {
               screens[param4 - 1].screenClip.visible = true;
            }
         }
         wizClip.stop();
      }
      
      public function destroy() : void
      {
         screens.splice(0,screens.length);
         screens = null;
         wizClip = null;
      }
      
      public function get step() : int
      {
         return _step;
      }
      
      public function set step(param1:int) : void
      {
         if(param1 == _step)
         {
            return;
         }
         jumpToStep(param1);
      }
      
      public function get currScreen() : SBScreen
      {
         if(screens && _step - 1 <= screens.length - 1)
         {
            return screens[_step - 1];
         }
         return null;
      }
      
      public function get nextScreen() : SBScreen
      {
         if(screens && _step <= screens.length - 1)
         {
            return screens[_step];
         }
         return null;
      }
      
      public function get prevScreen() : SBScreen
      {
         if(_step > 0 && screens && screens.length >= _step)
         {
            return screens[int(_step - 2)];
         }
         return null;
      }
      
      public function jumpToStep(param1:int) : void
      {
         var _loc2_:SBScreen = null;
         var _loc4_:Function = null;
         var _loc5_:SBScreen = null;
         var _loc6_:Function = null;
         if(!screens || param1 < 0 || param1 > screens.length + 1)
         {
            throw new Error("illegal wizard step:" + param1 + " screens:" + (screens ? screens.length : screens));
         }
         if(!wizClip.enabled || param1 == _step)
         {
            return;
         }
         var _loc3_:Boolean = param1 > _step;
         if(_step > 0 && _step <= screens.length)
         {
            _loc2_ = screens[_step - 1];
            if(_useSeparateScreens)
            {
               _loc2_.screenClip.visible = false;
            }
            _loc4_ = _loc3_ ? _loc2_.onLeaveToNext : _loc2_.onLeaveToPrev;
            if(_loc4_ != null)
            {
               if(!_loc4_())
               {
                  return;
               }
            }
         }
         _step = param1;
         if(param1 > 0 && param1 <= screens.length)
         {
            _loc5_ = screens[param1 - 1];
            if(_useSeparateScreens)
            {
               _loc5_.screenClip.visible = true;
            }
            _loc6_ = _loc3_ ? _loc5_.onEnterFromPrev : _loc5_.onEnterFromNext;
            if(_loc6_ != null)
            {
               _loc6_();
            }
         }
      }
      
      public function jumpToScreen(param1:SBScreen) : void
      {
         var _loc2_:int = screens.indexOf(param1);
         if(_loc2_ >= 0)
         {
            jumpToStep(_loc2_ + 1);
            return;
         }
         throw new Error("SBWizard jumpToScreen - screen:" + param1 + " not found!");
      }
      
      public function next() : void
      {
         jumpToStep(_step + 1);
      }
      
      public function prev() : void
      {
         jumpToStep(_step - 1);
      }
      
      public function onPlay() : void
      {
         currScreen.onPlay();
      }
      
      public function onClose() : void
      {
         currScreen.onClose();
         _step = 1;
      }
      
      public function addScreen(param1:SBScreen, param2:int = 0) : void
      {
         if(!screens)
         {
            throw new Error("Tried to addScreen on an uninitialized wizard!");
         }
         if(param2 == 0)
         {
            screens.push(param1);
         }
         else
         {
            if(param2 < 0 || param2 > screens.length)
            {
               throw new Error("illegal step:" + param2 + " while trying to addScreen");
            }
            screens.splice(param2 - 1,0,param1);
         }
      }
      
      public function removeScreen(param1:int = 0) : void
      {
         if(!screens || screens.length == 0)
         {
            throw new Error("Tried to removeScreen on an empty wizard!");
         }
         if(param1 == 0)
         {
            screens.pop();
         }
         else
         {
            if(param1 < 0 || param1 > screens.length)
            {
               throw new Error("illegal step:" + param1 + " while trying to removeScreen");
            }
            screens.splice(param1 - 1,1);
         }
      }
      
      public function updateCurrScreen() : void
      {
         var _loc3_:SBScreen = currScreen;
         if(_loc3_)
         {
            _loc3_.updateScreen(true);
         }
         var _loc1_:SBScreen = prevScreen;
         if(_loc1_)
         {
            _loc1_.updateScreen();
         }
         var _loc2_:SBScreen = nextScreen;
         if(_loc2_)
         {
            _loc2_.updateScreen();
         }
      }
   }
}

