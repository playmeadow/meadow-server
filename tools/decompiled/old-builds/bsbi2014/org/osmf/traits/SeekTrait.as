package org.osmf.traits
{
   import org.osmf.events.SeekEvent;
   
   [Event(name="seekingChange",type="org.osmf.events.SeekEvent")]
   public class SeekTrait extends MediaTraitBase
   {
      
      private var _timeTrait:TimeTrait;
      
      private var _seeking:Boolean;
      
      public function SeekTrait(timeTrait:TimeTrait)
      {
         super(MediaTraitType.SEEK);
         this._timeTrait = timeTrait;
      }
      
      final public function get seeking() : Boolean
      {
         return this._seeking;
      }
      
      final public function seek(time:Number) : void
      {
         if(this.canSeekTo(time))
         {
            this.setSeeking(true,time);
         }
      }
      
      public function canSeekTo(time:Number) : Boolean
      {
         return Boolean(this._timeTrait) ? isNaN(time) == false && time >= 0 && (time <= this._timeTrait.duration || time <= this._timeTrait.currentTime) : false;
      }
      
      final protected function get timeTrait() : TimeTrait
      {
         return this._timeTrait;
      }
      
      final protected function set timeTrait(value:TimeTrait) : void
      {
         this._timeTrait = value;
      }
      
      final protected function setSeeking(value:Boolean, time:Number) : void
      {
         this.seekingChangeStart(value,time);
         this._seeking = value;
         this.seekingChangeEnd(time);
      }
      
      protected function seekingChangeStart(newSeeking:Boolean, time:Number) : void
      {
      }
      
      protected function seekingChangeEnd(time:Number) : void
      {
         dispatchEvent(new SeekEvent(SeekEvent.SEEKING_CHANGE,false,false,this.seeking,time));
      }
   }
}

