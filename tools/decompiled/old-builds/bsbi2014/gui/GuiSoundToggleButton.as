package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuiSoundToggleButton extends MovieClip
   {
      
      public var mouse:MovieClip;
      
      public var down:MovieClip;
      
      public var gray:MovieClip;
      
      public var glowArrow:MovieClip;
      
      public var glow:MovieClip;
      
      public var hasGrayState:Boolean = false;
      
      public var isGray:Boolean = false;
      
      public var soundsEnabled:Boolean = true;
      
      public var clickQueued:Boolean = false;
      
      public var hazMouse:Boolean = false;
      
      public var hasGlowArrowState:Boolean;
      
      public var isGlowArrow:Boolean;
      
      private var _mouseVisibleOnEnableGray:Boolean = true;
      
      private var _pulseForward:Boolean = true;
      
      private var _pulseExtraFrames:int = 0;
      
      private var _repetitions:int = 0;
      
      private var _toolTip:ToolTipPopup;
      
      private var _useTimer:Boolean = true;
      
      public function GuiSoundToggleButton()
      {
         super();
         this.mouse = this["mouse"];
         this.down = this["down"];
         this.gray = this["gray"];
         this.glowArrow = this["glowArrow"];
         this.glow = this["glow"];
         if(!this.mouse)
         {
            throw new Error("GuiSoundToggleButton is missing parts or they are named incorrectly!");
         }
         this.mouse.stop();
         this.mouse.visible = true;
         if(Boolean(this.down))
         {
            this.down.stop();
            this.down.visible = false;
         }
         if(Boolean(this.gray))
         {
            this.hasGrayState = true;
            this.gray.visible = false;
         }
         if(Boolean(this.glowArrow))
         {
            this.hasGlowArrowState = true;
            this.glowArrow.visible = false;
         }
         if(Boolean(this.glow))
         {
            this.glow.visible = false;
         }
         addEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler,false,1,true);
         addEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler,false,1,true);
         addEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler,false,1,true);
      }
      
      public function initToolTip(layer:DisplayObjectContainer, msg:String, xPos:int, yPos:int, shouldUseTimer:Boolean = true) : void
      {
         if(!this._toolTip)
         {
            this._toolTip = GETDEFINITIONBYNAME("Tooltip");
         }
         this._toolTip.init(layer,msg,this.x + xPos,this.y + yPos,shouldUseTimer);
      }
      
      public function activateGrayState(yes:Boolean) : void
      {
         if(yes)
         {
            if(this.hasGrayState && !this.isGray)
            {
               this.isGray = this.gray.visible = true;
               this._mouseVisibleOnEnableGray = this.mouse.visible;
               this.mouse.visible = false;
               if(Boolean(this.down))
               {
                  this.down.visible = false;
               }
               removeEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler);
               removeEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler);
               removeEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler);
            }
         }
         else if(this.hasGrayState && this.isGray)
         {
            this.isGray = this.gray.visible = false;
            if(this._mouseVisibleOnEnableGray)
            {
               this.mouse.visible = true;
            }
            else
            {
               this.mouse.visible = false;
            }
            if(Boolean(this.down))
            {
               this.down.visible = !this.mouse.visible;
            }
            addEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler,false,1,true);
            addEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler,false,1,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler,false,1,true);
         }
      }
      
      public function activateGlowArrowState(yes:Boolean) : void
      {
         if(yes)
         {
            if(this.hasGlowArrowState)
            {
               this.isGlowArrow = true;
               this.glowArrow.visible = true;
            }
         }
         else if(this.hasGlowArrowState)
         {
            this.isGlowArrow = false;
            this.glowArrow.visible = false;
         }
      }
      
      public function setButtonState(state:int) : void
      {
         this.activateGlowArrowState(false);
         this.activateGrayState(false);
         switch(state)
         {
            case 0:
               if(Boolean(this.glow))
               {
                  this.glow.visible = false;
               }
               this.activateGrayState(true);
               break;
            case 1:
               break;
            case 2:
               this.activateGlowArrowState(true);
         }
      }
      
      public function pulseButton(status:Boolean, repetitions:int = -1) : void
      {
         if(status)
         {
            this.mouse.addEventListener(Event.ENTER_FRAME,this.pulseFrameHandler,false,0,true);
            this._repetitions = repetitions;
         }
         else
         {
            this.mouse.removeEventListener(Event.ENTER_FRAME,this.pulseFrameHandler);
            this._repetitions = 0;
         }
      }
      
      private function pulseFrameHandler(evt:Event) : void
      {
         var mch:MovieClip = MovieClip(evt.target);
         if(this._repetitions > 0)
         {
            if(this._pulseForward && mch.currentFrame <= mch.totalFrames - 1)
            {
               if(this._pulseExtraFrames > 10)
               {
                  mch.nextFrame();
               }
               else
               {
                  ++this._pulseExtraFrames;
               }
               if(mch.currentFrame == mch.totalFrames)
               {
                  --this._repetitions;
                  this._pulseForward = false;
                  this._pulseExtraFrames = 0;
               }
            }
            else if(this._pulseExtraFrames >= 10)
            {
               mch.prevFrame();
               if(mch.currentFrame == 1)
               {
                  --this._repetitions;
                  this._pulseForward = true;
                  this._pulseExtraFrames = 0;
               }
            }
            else
            {
               ++this._pulseExtraFrames;
            }
         }
         else if(this._repetitions == -1)
         {
            if(this._pulseForward && mch.currentFrame <= mch.totalFrames - 1)
            {
               if(this._pulseExtraFrames > 10)
               {
                  mch.nextFrame();
               }
               else
               {
                  ++this._pulseExtraFrames;
               }
               if(mch.currentFrame == mch.totalFrames)
               {
                  this._pulseForward = false;
                  this._pulseExtraFrames = 0;
               }
            }
            else if(this._pulseExtraFrames >= 10)
            {
               mch.prevFrame();
               if(mch.currentFrame == 1)
               {
                  this._pulseForward = true;
                  this._pulseExtraFrames = 0;
               }
            }
            else
            {
               ++this._pulseExtraFrames;
            }
         }
         else
         {
            this.mouse.removeEventListener(Event.ENTER_FRAME,this.pulseFrameHandler);
         }
      }
      
      private function btnOverHandler(m:MouseEvent) : void
      {
         this.hazMouse = true;
         if(this.mouse.visible)
         {
            if(this.mouse.hasEventListener(Event.ENTER_FRAME))
            {
               this.mouse.removeEventListener(Event.ENTER_FRAME,this.pbFrameHandler);
            }
            this.mouse.gotoAndPlay(1);
            if(this.soundsEnabled && m != null)
            {
               this.playRolloverSound();
            }
            if(Boolean(this._toolTip) && this._toolTip.enabled)
            {
               this._toolTip.startTimer(m);
               this._toolTip.bringToolToFront();
            }
         }
      }
      
      private function btnOutHandler(m:MouseEvent) : void
      {
         this.hazMouse = false;
         if(this.mouse.visible)
         {
            if(this.mouse.currentFrame > 1)
            {
               this.playBackwards(this.mouse);
            }
            else
            {
               this.mouse.stop();
            }
            if(Boolean(this._toolTip) && Boolean(this._toolTip.toolTipTimer) && this._toolTip.isTimerRunning())
            {
               this._toolTip.resetTimerAndSetVisibility();
            }
            else if(Boolean(this._toolTip))
            {
               this._toolTip.visible = false;
            }
         }
      }
      
      private function btnDownHandler(m:MouseEvent) : void
      {
         if(this.isGray)
         {
            if(Boolean(m))
            {
               m.stopPropagation();
            }
            return;
         }
         if(Boolean(this.down) && !this.down.visible)
         {
            this.down.visible = true;
            this.mouse.visible = false;
         }
         else
         {
            this.mouse.visible = true;
            this.mouse.gotoAndPlay(1);
            if(Boolean(this.down))
            {
               this.down.visible = false;
            }
         }
         if(this.soundsEnabled && m != null)
         {
            this.playClickSound();
         }
         if(Boolean(this._toolTip) && Boolean(this._toolTip.toolTipTimer) && this._toolTip.isTimerRunning())
         {
            this._toolTip.resetTimerAndSetVisibility();
         }
         else if(Boolean(this._toolTip))
         {
            this._toolTip.visible = false;
         }
      }
      
      public function setTimer(bool:Boolean) : void
      {
         this._useTimer = bool;
      }
      
      private function selWatcher(e:Event) : void
      {
         var mu:MovieClip = null;
         if(Boolean(e.target as MovieClip))
         {
            mu = MovieClip(e.target);
            if(mu.currentFrame == mu.totalFrames)
            {
               if(this.hazMouse)
               {
                  this.mouse.gotoAndPlay(1);
               }
               else
               {
                  this.mouse.gotoAndStop(1);
               }
               this.mouse.visible = true;
               mu.gotoAndStop(1);
               mu.visible = false;
               mu.removeEventListener(Event.ENTER_FRAME,this.selWatcher);
            }
         }
      }
      
      private function queueClick(mc:MovieClip) : void
      {
         this.clickQueued = true;
         mc.addEventListener(Event.ENTER_FRAME,this.qcFrameHandler,false,0,true);
      }
      
      private function queueClickCallback() : void
      {
         if(!this.down.visible)
         {
            this.down.visible = true;
            this.mouse.visible = false;
         }
         this.down.gotoAndPlay(1);
      }
      
      private function qcFrameHandler(e:Event) : void
      {
         var mch:MovieClip = null;
         if(this.clickQueued && Boolean(e.target as MovieClip))
         {
            mch = MovieClip(e.target);
            if(mch.currentFrame == mch.totalFrames)
            {
               this.clickQueued = false;
               this.queueClickCallback();
               mch.removeEventListener(Event.ENTER_FRAME,this.qcFrameHandler);
            }
         }
      }
      
      private function playBackwards(mc:MovieClip) : void
      {
         mc.addEventListener(Event.ENTER_FRAME,this.pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(e:Event) : void
      {
         var mch:MovieClip = null;
         if(Boolean(e.target as MovieClip))
         {
            mch = MovieClip(e.target);
            if(mch.currentFrame == 1)
            {
               mch.removeEventListener(Event.ENTER_FRAME,this.pbFrameHandler);
               return;
            }
            mch.prevFrame();
         }
      }
      
      public function downToUpState() : void
      {
         if(Boolean(this.down))
         {
            this.down.visible = false;
         }
         this.mouse.visible = true;
         this.mouse.gotoAndStop(1);
      }
      
      public function upToDownState() : void
      {
         if(Boolean(this.down) && !this.down.visible)
         {
            this.down.visible = true;
            this.mouse.visible = false;
         }
      }
      
      public function playClickSound() : void
      {
         AJAudio.playHudBtnClick();
      }
      
      public function playRolloverSound() : void
      {
         AJAudio.playHudBtnRollover();
      }
   }
}

