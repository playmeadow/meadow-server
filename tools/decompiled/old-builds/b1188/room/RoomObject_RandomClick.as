package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject_RandomClick extends RoomObject
   {
      
      private var _frameCountdown:int;
      
      public function RoomObject_RandomClick(param1:MovieClip)
      {
         super(param1);
         param1.stop();
      }
      
      override public function mouseDown(param1:Boolean) : void
      {
         if(_bHold == false && param1 == true)
         {
            this._frameCountdown = 5 + int(Math.random() * _mc.totalFrames) / 2;
            _bHold = true;
         }
      }
      
      override protected function onEnterFrame(param1:Event) : void
      {
         if(_bHold)
         {
            if(_mc.currentFrame == _mc.totalFrames)
            {
               _mc.gotoAndStop(0);
            }
            else
            {
               _mc.nextFrame();
            }
            if(this._frameCountdown == 0)
            {
               _bHold = false;
            }
            else
            {
               --this._frameCountdown;
            }
         }
      }
   }
}

