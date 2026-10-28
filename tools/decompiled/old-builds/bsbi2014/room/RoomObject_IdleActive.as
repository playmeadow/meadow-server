package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject_IdleActive extends RoomObject
   {
      
      public function RoomObject_IdleActive(mc:MovieClip)
      {
         super(mc);
      }
      
      override public function mouseDown(f:Boolean) : void
      {
         if(f && _bHold == false)
         {
            _mc.gotoAndPlay("active");
            _bHold = true;
         }
      }
      
      override protected function onEnterFrame(e:Event) : void
      {
         if(_bHold && _mc.currentLabel == "idle")
         {
            _bHold = false;
         }
      }
   }
}

