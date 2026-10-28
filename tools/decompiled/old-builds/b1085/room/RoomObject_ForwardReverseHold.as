package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject_ForwardReverseHold extends RoomObject
   {
      
      public function RoomObject_ForwardReverseHold(param1:MovieClip)
      {
         super(param1);
         param1.gotoAndStop(1);
      }
      
      override public function mouseDown(param1:Boolean) : void
      {
         if(param1 && _bHold == false && _mc.hasOwnProperty("mouseDown"))
         {
            _mc.mouseDown();
         }
         _bHold = param1;
      }
      
      override protected function onEnterFrame(param1:Event) : void
      {
         var _loc2_:* = _mc.currentFrame;
         if(_dir == 1)
         {
            if(++_loc2_ <= _mc.totalFrames)
            {
               _mc.gotoAndStop(_loc2_);
            }
            else
            {
               _dir = 0;
            }
         }
         else if(_dir == -1)
         {
            _loc2_--;
            if(_loc2_ > 0)
            {
               _mc.gotoAndStop(_loc2_);
            }
            else
            {
               _dir = 0;
            }
         }
      }
   }
}

