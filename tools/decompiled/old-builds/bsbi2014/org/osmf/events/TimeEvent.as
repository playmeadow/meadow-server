package org.osmf.events
{
   import flash.events.Event;
   
   public class TimeEvent extends Event
   {
      
      public static const CURRENT_TIME_CHANGE:String = "currentTimeChange";
      
      public static const DURATION_CHANGE:String = "durationChange";
      
      public static const COMPLETE:String = "complete";
      
      private var _time:Number;
      
      public function TimeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, time:Number = NaN)
      {
         super(type,bubbles,cancelable);
         this._time = time;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      override public function clone() : Event
      {
         return new TimeEvent(type,bubbles,cancelable,this.time);
      }
   }
}

