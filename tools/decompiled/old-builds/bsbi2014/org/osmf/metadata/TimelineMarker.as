package org.osmf.metadata
{
   public class TimelineMarker
   {
      
      private var _time:Number;
      
      private var _duration:Number;
      
      public function TimelineMarker(time:Number, duration:Number = NaN)
      {
         super();
         this._time = time;
         this._duration = duration;
      }
      
      public function get time() : Number
      {
         return this._time;
      }
      
      public function get duration() : Number
      {
         return this._duration;
      }
   }
}

