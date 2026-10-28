package game
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GuiButton
   {
      
      private var _mc:MovieClip;
      
      private var _clickFunc:Function;
      
      public function GuiButton(param1:MovieClip, param2:Function)
      {
         super();
         this._mc = param1;
         this._clickFunc = param2;
         this._mc.addEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
         this._mc.addEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
         this._mc.addEventListener(MouseEvent.CLICK,this.mouseClick);
         this._mc.gotoAndPlay("off");
      }
      
      public function release() : void
      {
         this._mc.removeEventListener(MouseEvent.MOUSE_OVER,this.mouseOver);
         this._mc.removeEventListener(MouseEvent.MOUSE_OUT,this.mouseOut);
         this._mc.removeEventListener(MouseEvent.CLICK,this.mouseClick);
         this._mc.parent.removeChild(this._mc);
         this._mc = null;
      }
      
      private function mouseOver(param1:MouseEvent) : void
      {
         this._mc.gotoAndPlay("on");
         AJAudio.playHudBtnRollover();
      }
      
      private function mouseOut(param1:MouseEvent) : void
      {
         this._mc.gotoAndPlay("off");
      }
      
      private function mouseClick(param1:MouseEvent) : void
      {
         this._clickFunc();
         AJAudio.playHudBtnClick();
      }
   }
}

