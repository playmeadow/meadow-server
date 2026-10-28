package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject
   {
      
      protected var _mc:MovieClip;
      
      protected var _dir:int;
      
      protected var _bHold:Boolean;
      
      public function RoomObject(param1:MovieClip)
      {
         super();
         _dir = 0;
         _mc = param1;
         param1.addEventListener("enterFrame",onEnterFrame);
      }
      
      public function get hold() : Boolean
      {
         return _bHold;
      }
      
      public function get mc() : MovieClip
      {
         return _mc;
      }
      
      public function mouseDown(param1:Boolean) : void
      {
         _bHold = param1;
      }
      
      public function release() : void
      {
         if(_mc)
         {
            _mc.removeEventListener("enterFrame",onEnterFrame);
            _mc = null;
         }
      }
      
      public function setDir(param1:int) : void
      {
         _dir = param1;
      }
      
      protected function onEnterFrame(param1:Event) : void
      {
      }
   }
}

