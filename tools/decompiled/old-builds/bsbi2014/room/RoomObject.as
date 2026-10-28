package room
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class RoomObject
   {
      
      protected var _mc:MovieClip;
      
      protected var _dir:int;
      
      protected var _bHold:Boolean;
      
      public function RoomObject(mc:MovieClip)
      {
         super();
         this._dir = 0;
         this._mc = mc;
         mc.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      public function get hold() : Boolean
      {
         return this._bHold;
      }
      
      public function mouseDown(f:Boolean) : void
      {
         this._bHold = f;
      }
      
      public function release() : void
      {
         if(Boolean(this._mc))
         {
            this._mc.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this._mc = null;
         }
      }
      
      public function setDir(d:int) : void
      {
         this._dir = d;
      }
      
      protected function onEnterFrame(e:Event) : void
      {
      }
   }
}

