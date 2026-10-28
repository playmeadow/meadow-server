package room
{
   import flash.display.MovieClip;
   
   public class RoomObject_GemPickup extends RoomObject
   {
      
      public function RoomObject_GemPickup(mc:MovieClip)
      {
         super(mc);
      }
      
      override public function mouseDown(f:Boolean) : void
      {
         if(f && _bHold == false)
         {
            _mc.visible = false;
            _bHold = true;
            release();
         }
      }
   }
}

