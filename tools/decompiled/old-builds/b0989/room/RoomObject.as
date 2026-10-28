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
         this._dir = 0;
         this._mc = param1;
         param1.addEventListener(Event.ENTER_FRAME,this.onEnterFrame);
      }
      
      public function get hold() : Boolean
      {
         return this._bHold;
      }
      
      public function mouseDown(param1:Boolean) : void
      {
         this._bHold = param1;
      }
      
      public function release() : void
      {
         if(this._mc)
         {
            this._mc.removeEventListener(Event.ENTER_FRAME,this.onEnterFrame);
            this._mc = null;
         }
      }
      
      public function setDir(param1:int) : void
      {
         this._dir = param1;
      }
      
      protected function onEnterFrame(param1:Event) : void
      {
      }
   }
}

