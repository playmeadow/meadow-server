package org.osmf.traits
{
   import org.osmf.events.TimeEvent;
   
   [Event(name="complete",type="org.osmf.events.TimeEvent")]
   [Event(name="durationChange",type="org.osmf.events.TimeEvent")]
   public class TimeTrait extends MediaTraitBase
   {
      
      private var _duration:Number;
      
      private var _currentTime:Number;
      
      public function TimeTrait(duration:Number = NaN)
      {
         super(MediaTraitType.TIME);
         this._duration = duration;
      }
      
      public function get duration() : Number
      {
         return this._duration;
      }
      
      public function get currentTime() : Number
      {
         return this._currentTime;
      }
      
      protected function durationChangeStart(newDuration:Number) : void
      {
      }
      
      protected function durationChangeEnd(oldDuration:Number) : void
      {
         dispatchEvent(new TimeEvent(TimeEvent.DURATION_CHANGE,false,false,this._duration));
      }
      
      protected function currentTimeChangeStart(newCurrentTime:Number) : void
      {
      }
      
      protected function currentTimeChangeEnd(oldCurrentTime:Number) : void
      {
      }
      
      protected function signalComplete() : void
      {
         dispatchEvent(new TimeEvent(TimeEvent.COMPLETE));
      }
      
      final protected function setCurrentTime(value:Number) : void
      {
         var oldCurrentTime:Number = NaN;
         if(!isNaN(value))
         {
            if(!isNaN(this._duration))
            {
               value = Math.min(value,this._duration);
            }
            else
            {
               value = 0;
            }
         }
         if(this._currentTime != value && !(isNaN(this._currentTime) && isNaN(value)))
         {
            this.currentTimeChangeStart(value);
            oldCurrentTime = this._currentTime;
            this._currentTime = value;
            this.currentTimeChangeEnd(oldCurrentTime);
            if(this.currentTime == this.duration && this.currentTime > 0)
            {
               this.signalComplete();
            }
         }
      }
      
      final protected function setDuration(value:Number) : void
      {
         var oldDuration:Number = NaN;
         if(this._duration != value)
         {
            this.durationChangeStart(value);
            oldDuration = this._duration;
            this._duration = value;
            this.durationChangeEnd(oldDuration);
            if(!isNaN(this._currentTime) && !isNaN(this._duration) && this._currentTime > this._duration)
            {
               this.setCurrentTime(this.duration);
            }
         }
      }
   }
}

