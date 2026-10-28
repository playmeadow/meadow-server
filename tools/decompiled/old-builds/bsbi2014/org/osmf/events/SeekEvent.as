package org.osmf.events
{
   import flash.events.Event;
   
   public class SeekEvent extends Event
   {
      
      public static const SEEKING_CHANGE:String = "seekingChange";
      
      private var _seeking:Boolean = false;
      
      private var _time:Number;
      
      public function SeekEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, seeking:Boolean = false, time:Number = NaN)
      {
         super(type,bubbles,cancelable);
         this._seeking = seeking;
         this._time = time;
      }
      
      public function get seeking() : Boolean
      {
         return this._seeking;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      override public function clone() : Event
      {
         return new SeekEvent(type,bubbles,cancelable,this._seeking,this._time);
      }
   }
}

