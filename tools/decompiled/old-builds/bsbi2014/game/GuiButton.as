package game
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GuiButton
   {
      
      private var _mc:MovieClip;
      
      private var _clickFunc:Function;
      
      public function GuiButton(mc:MovieClip, f:Function)
      {
         super();
         this._mc = mc;
         this._clickFunc = f;
         this._mc.addEventListener(MouseEvent.ROLL_OVER,this.mouseOver);
         this._mc.addEventListener(MouseEvent.ROLL_OUT,this.mouseOut);
         this._mc.addEventListener(MouseEvent.MOUSE_DOWN,this.mouseClick);
         this._mc.gotoAndStop("off");
      }
      
      public function release() : void
      {
         this._mc.removeEventListener(MouseEvent.ROLL_OVER,this.mouseOver);
         this._mc.removeEventListener(MouseEvent.ROLL_OUT,this.mouseOut);
         this._mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseClick);
         this._mc.parent.removeChild(this._mc);
         this._mc = null;
      }
      
      private function mouseOver(e:MouseEvent) : void
      {
         if(this._mc.currentFrameLabel != "on")
         {
            this._mc.gotoAndPlay("on");
         }
         AJAudio.playHudBtnRollover();
      }
      
      private function mouseOut(e:MouseEvent) : void
      {
         if(this._mc.currentFrameLabel != "off")
         {
            this._mc.gotoAndPlay("off");
         }
      }
      
      private function mouseClick(e:MouseEvent) : void
      {
         this._clickFunc();
         AJAudio.playHudBtnClick();
      }
   }
}

