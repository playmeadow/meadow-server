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
         _mc = param1;
         _clickFunc = param2;
         _mc.addEventListener("rollOver",mouseOver);
         _mc.addEventListener("rollOut",mouseOut);
         _mc.addEventListener("mouseDown",mouseClick);
         _mc.gotoAndStop("off");
      }
      
      public function release() : void
      {
         _mc.removeEventListener("rollOver",mouseOver);
         _mc.removeEventListener("rollOut",mouseOut);
         _mc.removeEventListener("mouseDown",mouseClick);
         _mc.parent.removeChild(_mc);
         _mc = null;
      }
      
      private function mouseOver(param1:MouseEvent) : void
      {
         if(_mc.currentFrameLabel != "on")
         {
            _mc.gotoAndPlay("on");
         }
         AJAudio.playHudBtnRollover();
      }
      
      private function mouseOut(param1:MouseEvent) : void
      {
         if(_mc.currentFrameLabel != "off")
         {
            _mc.gotoAndPlay("off");
         }
      }
      
      private function mouseClick(param1:MouseEvent) : void
      {
         _clickFunc();
         AJAudio.playHudBtnClick();
      }
   }
}

