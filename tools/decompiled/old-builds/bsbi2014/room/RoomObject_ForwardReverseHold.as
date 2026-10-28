package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject_ForwardReverseHold extends RoomObject
   {
      
      public function RoomObject_ForwardReverseHold(mc:MovieClip)
      {
         super(mc);
         mc.gotoAndStop(1);
      }
      
      override public function mouseDown(f:Boolean) : void
      {
         if(f && _bHold == false && _mc.hasOwnProperty("mouseDown"))
         {
            _mc.mouseDown();
         }
         _bHold = f;
      }
      
      override protected function onEnterFrame(e:Event) : void
      {
         var f:int = _mc.currentFrame;
         if(_dir == 1)
         {
            f++;
            if(f <= _mc.totalFrames)
            {
               _mc.gotoAndStop(f);
            }
            else
            {
               _dir = 0;
            }
         }
         else if(_dir == -1)
         {
            f--;
            if(f > 0)
            {
               _mc.gotoAndStop(f);
            }
            else
            {
               _dir = 0;
            }
         }
      }
   }
}

