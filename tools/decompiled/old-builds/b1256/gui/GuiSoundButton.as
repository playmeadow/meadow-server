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
      
      public var loadingCont:MovieClip;
      
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
         mouse = this["mouse"];
         down = this["down"];
         gray = this["gray"];
         glowArrow = this["glowArrow"];
         glow = this["glow"];
         loadingCont = this["loadingCont"];
         if(!mouse)
         {
            throw new Error("GuiSoundButton is missing parts or they are named incorrectly!");
         }
         mouse.stop();
         mouse.visible = true;
         if(down)
         {
            down.stop();
            down.visible = false;
         }
         if(gray)
         {
            hasGrayState = true;
            gray.visible = false;
         }
         if(glowArrow)
         {
            hasGlowArrowState = true;
            glowArrow.visible = false;
         }
         if(glow)
         {
            glow.visible = false;
         }
         if(loadingCont)
         {
            loadingCont.visible = false;
         }
         mouseEnabled = false;
         addEventListener("mouseDown",btnDownHandler,false,1,true);
         addEventListener("rollOver",btnOverHandler,false,1,true);
         addEventListener("rollOut",btnOutHandler,false,1,true);
      }
      
      public function initToolTip(param1:DisplayObjectContainer, param2:String, param3:int, param4:int, param5:Boolean = true) : void
      {
         if(!_toolTip)
         {
            _toolTip = GETDEFINITIONBYNAME("Tooltip");
         }
         _toolTip.init(param1,param2,this.x + param3,this.y + param4,param5);
      }
      
      public function activateGrayState(param1:Boolean) : void
      {
         if(param1)
         {
            if(hasGrayState && !isGray)
            {
               btnOutHandler(null);
               isGray = gray.visible = true;
               _mouseVisibleOnEnableGray = mouse.visible;
               mouse.visible = false;
               if(down)
               {
                  down.visible = false;
               }
               removeEventListener("rollOver",btnOverHandler);
               removeEventListener("rollOut",btnOutHandler);
               removeEventListener("mouseDown",btnDownHandler);
            }
         }
         else if(hasGrayState && isGray)
         {
            isGray = gray.visible = false;
            if(_mouseVisibleOnEnableGray)
            {
               mouse.visible = true;
            }
            else
            {
               mouse.visible = false;
            }
            if(down)
            {
               down.visible = !mouse.visible;
            }
            addEventListener("rollOver",btnOverHandler,false,1,true);
            addEventListener("rollOut",btnOutHandler,false,1,true);
            addEventListener("mouseDown",btnDownHandler,false,1,true);
         }
      }
      
      public function activateGlowArrowState(param1:Boolean) : void
      {
         if(param1)
         {
            if(hasGlowArrowState)
            {
               isGlowArrow = true;
               glowArrow.visible = true;
               glowArrow.mouseChildren = false;
               glowArrow.mouseEnabled = false;
            }
         }
         else if(hasGlowArrowState)
         {
            isGlowArrow = false;
            glowArrow.visible = false;
         }
      }
      
      public function activateLoadingState(param1:Boolean) : void
      {
         if(loadingCont)
         {
            loadingCont.visible = param1;
            activateGrayState(param1);
            if(!param1)
            {
               downToUpState();
            }
         }
      }
      
      public function setButtonState(param1:int) : void
      {
         activateGlowArrowState(false);
         activateGrayState(false);
         switch(param1)
         {
            case 0:
               if(glow)
               {
                  glow.visible = false;
               }
               activateGrayState(true);
               break;
            case 1:
               activateGlowArrowState(false);
               break;
            case 2:
               activateGlowArrowState(true);
         }
      }
      
      public function btnOverHandler(param1:MouseEvent) : void
      {
         hazMouse = true;
         if(mouse.visible)
         {
            if(mouse.hasEventListener("enterFrame"))
            {
               mouse.removeEventListener("enterFrame",pbFrameHandler);
            }
            mouse.gotoAndPlay(1);
            if(soundsEnabled && param1 != null)
            {
               playRolloverSound();
            }
            if(_toolTip && _toolTip.enabled)
            {
               _toolTip.startTimer(param1);
               _toolTip.bringToolToFront();
            }
         }
      }
      
      public function btnOutHandler(param1:MouseEvent) : void
      {
         hazMouse = false;
         if(mouse.visible)
         {
            if(mouse.currentFrame > 1)
            {
               playBackwards(mouse);
            }
            else
            {
               mouse.stop();
            }
            if(_toolTip && _toolTip.toolTipTimer && _toolTip.isTimerRunning())
            {
               _toolTip.resetTimerAndSetVisibility();
            }
            else if(_toolTip)
            {
               _toolTip.visible = false;
            }
         }
      }
      
      public function btnDownHandler(param1:MouseEvent) : void
      {
         if(isGray)
         {
            if(param1)
            {
               param1.stopPropagation();
            }
            return;
         }
         if(down && !down.visible)
         {
            down.visible = true;
            mouse.visible = false;
         }
         else
         {
            mouse.visible = true;
            mouse.gotoAndPlay(1);
            if(down)
            {
               down.visible = false;
            }
         }
         if(soundsEnabled && param1 != null)
         {
            playClickSound();
         }
         if(_toolTip && _toolTip.toolTipTimer && _toolTip.isTimerRunning())
         {
            _toolTip.resetTimerAndSetVisibility();
         }
         else if(_toolTip)
         {
            _toolTip.visible = false;
         }
         downToUpState();
      }
      
      public function setTimer(param1:Boolean) : void
      {
         _useTimer = param1;
      }
      
      private function playBackwards(param1:MovieClip) : void
      {
         param1.addEventListener("enterFrame",pbFrameHandler,false,0,true);
      }
      
      private function pbFrameHandler(param1:Event) : void
      {
         var _loc2_:MovieClip = null;
         if(param1.target as MovieClip)
         {
            _loc2_ = MovieClip(param1.target);
            if(_loc2_.currentFrame == 1)
            {
               _loc2_.removeEventListener("enterFrame",pbFrameHandler);
               return;
            }
            _loc2_.prevFrame();
         }
      }
      
      public function downToUpState() : void
      {
         if(down)
         {
            down.visible = false;
         }
         mouse.visible = true;
         mouse.gotoAndStop(1);
         if(hazMouse)
         {
            btnOverHandler(null);
         }
      }
      
      public function upToDownState() : void
      {
         if(down && !down.visible)
         {
            down.visible = true;
            mouse.visible = false;
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

