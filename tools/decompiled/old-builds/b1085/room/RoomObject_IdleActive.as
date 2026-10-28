package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject_IdleActive extends RoomObject
   {
      
      public function RoomObject_IdleActive(param1:MovieClip)
      {
         super(param1);
      }
      
      override public function mouseDown(param1:Boolean) : void
      {
         if(param1 && _bHold == false)
         {
            _mc.gotoAndPlay("active");
            _bHold = true;
         }
      }
      
      override protected function onEnterFrame(param1:Event) : void
      {
         if(_bHold && _mc.currentLabel == "idle")
         {
            _bHold = false;
         }
      }
   }
}

