package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class GuiSoundToggleButton extends MovieClip
   {
      
      public var mouse:MovieClip;
      
      public var down:MovieClip;
      
      public var gray:MovieClip;
      
      public var hasGrayState:Boolean = false;
      
      public var isGray:Boolean = false;
      
      public var soundsEnabled:Boolean = true;
      
      public var clickQueued:Boolean = false;
      
      public var hazMouse:Boolean = false;
      
      private var _mouseVisibleOnEnableGray:Boolean = true;
      
      private var pulseForward:Boolean = true;
      
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
         if(!this.mouse)
         {
            throw new Error("GuiSoundToggleButton is missing parts or they are named incorrectly!");
         }
         this.mouse.stop();
         this.mouse.visible = true;
         if(this.down)
         {
            this.down.stop();
            this.down.visible = false;
         }
         if(this.gray)
         {
            this.hasGrayState = true;
            this.gray.visible = false;
         }
         addEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler,false,0,true);
         addEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler,false,0,true);
      }
      
      public function initToolTip(param1:DisplayObjectContainer, param2:String, param3:int, param4:int, param5:Boolean = true) : void
      {
         if(!this._toolTip)
         {
            this._toolTip = new (getDefinitionByName("Tooltip") as Class)();
         }
         this._toolTip.init(param1,param2,this.x + param3,this.y + param4,param5);
      }
      
      public function activateGrayState(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.hasGrayState && !this.isGray)
            {
               this.isGray = this.gray.visible = true;
               this._mouseVisibleOnEnableGray = this.mouse.visible;
               this.mouse.visible = false;
               if(this.down)
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
            if(this.down)
            {
               this.down.visible = !this.mouse.visible;
            }
            addEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler,false,0,true);
            addEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler,false,0,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler,false,0,true);
         }
      }
      
      public function pulseButton(param1:Boolean, param2:int = -1) : void
      {
         if(param1)
         {
            this.mouse.addEventListener(Event.ENTER_FRAME,this.pulseFrameHandler,false,0,true);
            this._repetitions = param2;
         }
         else
         {
            this.mouse.removeEventListener(Event.ENTER_FRAME,this.pulseFrameHandler);
            this._repetitions = 0;
         }
      }
      
      private function pulseFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = MovieClip(param1.target);
         if(this._repetitions > 0)
         {
            if(this.pulseForward && _loc2_.currentFrame <= _loc2_.totalFrames - 1)
            {
               if(this._pulseExtraFrames > 10)
               {
                  _loc2_.nextFrame();
               }
               else
               {
                  ++this._pulseExtraFrames;
               }
               if(_loc2_.currentFrame == _loc2_.totalFrames)
               {
                  --this._repetitions;
                  this.pulseForward = false;
                  this._pulseExtraFrames = 0;
               }
            }
            else if(this._pulseExtraFrames >= 10)
            {
               _loc2_.prevFrame();
               if(_loc2_.currentFrame == 1)
               {
                  --this._repetitions;
                  this.pulseForward = true;
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
            if(this.pulseForward && _loc2_.currentFrame <= _loc2_.totalFrames - 1)
            {
               if(this._pulseExtraFrames > 10)
               {
                  _loc2_.nextFrame();
               }
               else
               {
                  ++this._pulseExtraFrames;
               }
               if(_loc2_.currentFrame == _loc2_.totalFrames)
               {
                  this.pulseForward = false;
                  this._pulseExtraFrames = 0;
               }
            }
            else if(this._pulseExtraFrames >= 10)
            {
               _loc2_.prevFrame();
               if(_loc2_.currentFrame == 1)
               {
                  this.pulseForward = true;
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
      
      private function btnOverHandler(param1:MouseEvent) : void
      {
         this.hazMouse = true;
         if(this.mouse.visible)
         {
            if(this.mouse.hasEventListener(Event.ENTER_FRAME))
            {
               this.mouse.removeEventListener(Event.ENTER_FRAME,this.pbFrameHandler);
            }
            this.mouse.gotoAndPlay(1);
            if(this.soundsEnabled && param1 != null)
            {
               this.playRolloverSound();
            }
            if(Boolean(this._toolTip) && this._toolTip.enabled)
            {
               this._toolTip.startTimer(param1);
               this._toolTip.bringToolToFront();
            }
         }
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
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
            else if(this._toolTip)
            {
               this._toolTip.visible = false;
            }
         }
      }
      
      private function btnDownHandler(param1:MouseEvent) : void
      {
         if(this.isGray)
         {
            if(param1)
            {
               param1.stopPropagation();
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
            if(this.down)
            {
               this.down.visible = false;
            }
         }
         if(this.soundsEnabled && param1 != null)
         {
            this.playClickSound();
         }
         if(Boolean(this._toolTip) && Boolean(this._toolTip.toolTipTimer) && this._toolTip.isTimerRunning())
         {
            this._toolTip.resetTimerAndSetVisibility();
         }
         else if(this._toolTip)
         {
            this._toolTip.visible = false;
         }
      }
      
      public function setTimer(param1:Boolean) : void
      {
         this._useTimer = param1;
      }
      
      private function selWatcher(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target as MovieClip)
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == _loc2_.totalFrames)
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
               _loc2_.gotoAndStop(1);
               _loc2_.visible = false;
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.selWatcher);
            }
         }
      }
      
      private function queueClick(param1:MovieClip) : void
      {
         this.clickQueued = true;
         param1.addEventListener(Event.ENTER_FRAME,this.qcFrameHandler,false,0,true);
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
      
      private function qcFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(this.clickQueued && Boolean(param1.target as MovieClip))
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == _loc2_.totalFrames)
            {
               this.clickQueued = false;
               this.queueClickCallback();
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.qcFrameHandler);
            }
         }
      }
      
      private function playBackwards(param1:MovieClip) : void
      {
         param1.addEventListener(Event.ENTER_FRAME,this.pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target as MovieClip)
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == 1)
            {
               _loc2_.removeEventListener(Event.ENTER_FRAME,this.pbFrameHandler);
               return;
            }
            _loc2_.prevFrame();
         }
      }
      
      public function downToUpState() : void
      {
         if(this.down)
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

