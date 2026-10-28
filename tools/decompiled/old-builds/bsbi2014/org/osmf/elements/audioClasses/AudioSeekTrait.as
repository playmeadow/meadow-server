package org.osmf.elements.audioClasses
{
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   
   [ExcludeClass]
   public class AudioSeekTrait extends SeekTrait
   {
      
      private var soundAdapter:SoundAdapter;
      
      public function AudioSeekTrait(timeTrait:TimeTrait, soundAdapter:SoundAdapter)
      {
         super(timeTrait);
         this.soundAdapter = soundAdapter;
      }
      
      override protected function seekingChangeStart(newSeeking:Boolean, time:Number) : void
      {
         if(newSeeking)
         {
            this.soundAdapter.seek(time);
         }
      }
      
      override protected function seekingChangeEnd(time:Number) : void
      {
         super.seekingChangeEnd(time);
         if(seeking == true)
         {
            setSeeking(false,time);
         }
      }
   }
}

