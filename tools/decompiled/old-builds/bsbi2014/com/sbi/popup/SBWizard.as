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
      
      public function init(initWizClip:MovieClip, initAvatarCreationAssets:Object, initVisible:Boolean = true, initStep:int = 1, initScreens:Array = null, initEnabled:Boolean = true, useSeparateScreens:Boolean = false, isInWorld:Boolean = false) : void
      {
         var ifs:int = 0;
         var childOne:DisplayObject = null;
         var frameScreen:SBScreen = null;
         var ifa:int = 0;
         if(initWizClip == null)
         {
            throw new Error("invalid null initWizClip!");
         }
         this.wizClip = initWizClip;
         this.creationAssets = initAvatarCreationAssets;
         this._useSeparateScreens = useSeparateScreens;
         if(!initVisible && useSeparateScreens)
         {
            this.wizClip.visible = false;
         }
         var framesLength:int = useSeparateScreens == false ? int(initScreens.length) : this.wizClip.totalFrames;
         if(Boolean(initScreens))
         {
            this.screens = initScreens;
         }
         else
         {
            this.screens = [];
            if(framesLength > 0)
            {
               for(ifs = 0; ifs < framesLength; ifs++)
               {
                  this.wizClip.gotoAndStop(ifs + 1);
                  if(this.wizClip.numChildren < 1)
                  {
                     throw new Error("SBWizard could not find any child SBScreen on frame:" + (ifs + 1) + "!");
                  }
                  childOne = this.wizClip.getChildAt(0);
                  if(!(childOne is MovieClip))
                  {
                     throw new Error("SBWizard child was not a MovieClip for SBScreen on frame:" + (ifs + 1) + "!");
                  }
                  frameScreen = new SBScreen(childOne as MovieClip,this);
                  if(!frameScreen)
                  {
                     throw new Error("SBWizard child SBScreen was null on frame:" + (ifs + 1) + "!");
                  }
                  frameScreen.screenClip.visible = false;
                  this.screens.push(frameScreen);
               }
               if(this.screens.length != uint(framesLength))
               {
                  throw new Error("SBWizard - Failed assertion: lengths must be equal- screens.length:" + this.screens.length + " uint(framesLength):" + uint(framesLength));
               }
            }
         }
         this.wizClip.enabled = initEnabled;
         this.step = initStep;
         if(useSeparateScreens)
         {
            for(ifa = 0; ifa < framesLength; ifa++)
            {
               this.wizClip.addChild(this.screens[ifa].screenClip);
            }
            if(initStep > 0 && initStep <= framesLength)
            {
               this.screens[initStep - 1].screenClip.visible = true;
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
      
      public function set step(setStep:int) : void
      {
         if(setStep == this._step)
         {
            return;
         }
         this.jumpToStep(setStep);
      }
      
      public function get currScreen() : SBScreen
      {
         return this.screens[this._step - 1];
      }
      
      public function get nextScreen() : SBScreen
      {
         if(Boolean(this.screens) && this._step <= this.screens.length - 1)
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
      
      public function jumpToStep(newStep:int) : void
      {
         var oldScr:SBScreen = null;
         var oldStepMoveFunc:Function = null;
         var newScr:SBScreen = null;
         var newStepMoveFunc:Function = null;
         if(!this.screens || newStep < 0 || newStep > this.screens.length + 1)
         {
            throw new Error("illegal wizard step:" + newStep + " screens:" + (Boolean(this.screens) ? this.screens.length : this.screens));
         }
         if(!this.wizClip.enabled || newStep == this._step)
         {
            return;
         }
         var moveForward:Boolean = Boolean(newStep > this._step);
         if(this._step > 0 && this._step <= this.screens.length)
         {
            oldScr = this.screens[this._step - 1];
            if(this._useSeparateScreens)
            {
               oldScr.screenClip.visible = false;
            }
            oldStepMoveFunc = moveForward ? oldScr.onLeaveToNext : oldScr.onLeaveToPrev;
            if(oldStepMoveFunc != null)
            {
               if(!oldStepMoveFunc())
               {
                  return;
               }
            }
         }
         this._step = newStep;
         if(newStep > 0 && newStep <= this.screens.length)
         {
            newScr = this.screens[newStep - 1];
            if(this._useSeparateScreens)
            {
               newScr.screenClip.visible = true;
            }
            newStepMoveFunc = moveForward ? newScr.onEnterFromPrev : newScr.onEnterFromNext;
            if(newStepMoveFunc != null)
            {
               newStepMoveFunc();
            }
         }
      }
      
      public function jumpToScreen(jumpScreen:SBScreen) : void
      {
         var screenIdx:int = this.screens.indexOf(jumpScreen);
         if(screenIdx >= 0)
         {
            this.jumpToStep(screenIdx + 1);
            return;
         }
         throw new Error("SBWizard jumpToScreen - screen:" + jumpScreen + " not found!");
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
         this._step = 1;
      }
      
      public function addScreen(addScreen:SBScreen, addStep:int = 0) : void
      {
         if(!this.screens)
         {
            throw new Error("Tried to addScreen on an uninitialized wizard!");
         }
         if(addStep == 0)
         {
            this.screens.push(addScreen);
         }
         else
         {
            if(addStep < 0 || addStep > this.screens.length)
            {
               throw new Error("illegal step:" + addStep + " while trying to addScreen");
            }
            this.screens.splice(addStep - 1,0,addScreen);
         }
      }
      
      public function removeScreen(remStep:int = 0) : void
      {
         if(!this.screens || this.screens.length == 0)
         {
            throw new Error("Tried to removeScreen on an empty wizard!");
         }
         if(remStep == 0)
         {
            this.screens.pop();
         }
         else
         {
            if(remStep < 0 || remStep > this.screens.length)
            {
               throw new Error("illegal step:" + remStep + " while trying to removeScreen");
            }
            this.screens.splice(remStep - 1,1);
         }
      }
      
      public function updateCurrScreen() : void
      {
         var currScr:SBScreen = this.currScreen;
         if(Boolean(currScr))
         {
            currScr.updateScreen(true);
         }
         var prevScr:SBScreen = this.prevScreen;
         if(Boolean(prevScr))
         {
            prevScr.updateScreen();
         }
         var nextScr:SBScreen = this.nextScreen;
         if(Boolean(nextScr))
         {
            nextScr.updateScreen();
         }
      }
   }
}

