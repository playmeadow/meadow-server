package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class GuiSoundButton extends MovieClip
   {
      
      public var mouse:MovieClip;
      
      public var down:MovieClip;
      
      public var gray:MovieClip;
      
      public var glowArrow:MovieClip;
      
      public var glow:MovieClip;
      
      public var hasGrayState:Boolean = false;
      
      public var isGray:Boolean = false;
      
      public var soundsEnabled:Boolean = true;
      
      public var hazMouse:Boolean = false;
      
      public var hasGlowArrowState:Boolean;
      
      public var isGlowArrow:Boolean;
      
      private var _mouseVisibleOnEnableGray:Boolean = true;
      
      private var _toolTip:ToolTipPopup;
      
      private var _useTimer:Boolean = true;
      
      public function GuiSoundButton()
      {
         super();
         this.mouse = this["mouse"];
         this.down = this["down"];
         this.gray = this["gray"];
         this.glowArrow = this["glowArrow"];
         this.glow = this["glow"];
         if(!this.mouse)
         {
            throw new Error("GuiSoundButton is missing parts or they are named incorrectly!");
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
         if(this.glowArrow)
         {
            this.hasGlowArrowState = true;
            this.glowArrow.visible = false;
         }
         if(this.glow)
         {
            this.glow.visible = false;
         }
         mouseEnabled = false;
         addEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler,false,1,true);
         addEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler,false,1,true);
         addEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler,false,1,true);
      }
      
      public function initToolTip(param1:DisplayObjectContainer, param2:String, param3:int, param4:int, param5:Boolean = true) : void
      {
         if(!this._toolTip)
         {
            this._toolTip = GETDEFINITIONBYNAME("Tooltip");
         }
         this._toolTip.init(param1,param2,this.x + param3,this.y + param4,param5);
      }
      
      public function activateGrayState(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.hasGrayState && !this.isGray)
            {
               this.btnOutHandler(null);
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
            addEventListener(MouseEvent.ROLL_OVER,this.btnOverHandler,false,1,true);
            addEventListener(MouseEvent.ROLL_OUT,this.btnOutHandler,false,1,true);
            addEventListener(MouseEvent.MOUSE_DOWN,this.btnDownHandler,false,1,true);
         }
      }
      
      public function activateGlowArrowState(param1:Boolean) : void
      {
         if(param1)
         {
            if(this.hasGlowArrowState)
            {
               this.isGlowArrow = true;
               this.glowArrow.visible = true;
               this.glowArrow.mouseChildren = false;
               this.glowArrow.mouseEnabled = false;
            }
         }
         else if(this.hasGlowArrowState)
         {
            this.isGlowArrow = false;
            this.glowArrow.visible = false;
         }
      }
      
      public function setButtonState(param1:int) : void
      {
         this.activateGlowArrowState(false);
         this.activateGrayState(false);
         switch(param1)
         {
            case 0:
               if(this.glow)
               {
                  this.glow.visible = false;
               }
               this.activateGrayState(true);
               break;
            case 1:
               this.activateGlowArrowState(false);
               break;
            case 2:
               this.activateGlowArrowState(true);
         }
      }
      
      public function btnOverHandler(param1:MouseEvent) : void
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
      
      public function btnOutHandler(param1:MouseEvent) : void
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
      
      public function btnDownHandler(param1:MouseEvent) : void
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
         this.downToUpState();
      }
      
      public function setTimer(param1:Boolean) : void
      {
         this._useTimer = param1;
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
         if(this.hazMouse)
         {
            this.btnOverHandler(null);
         }
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

