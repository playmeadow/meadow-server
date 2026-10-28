package org.osmf.elements.audioClasses
{
   import flash.media.SoundTransform;
   import org.osmf.traits.AudioTrait;
   
   [ExcludeClass]
   public class AudioAudioTrait extends AudioTrait
   {
      
      private var soundAdapter:SoundAdapter;
      
      public function AudioAudioTrait(soundAdapter:SoundAdapter)
      {
         super();
         this.soundAdapter = soundAdapter;
         soundAdapter.soundTransform.volume = volume;
         soundAdapter.soundTransform.pan = pan;
      }
      
      override protected function volumeChangeStart(newVolume:Number) : void
      {
         var soundTransform:SoundTransform = this.soundAdapter.soundTransform;
         soundTransform.volume = muted ? 0 : newVolume;
         this.soundAdapter.soundTransform = soundTransform;
      }
      
      override protected function mutedChangeStart(newMuted:Boolean) : void
      {
         var soundTransform:SoundTransform = this.soundAdapter.soundTransform;
         soundTransform.volume = newMuted ? 0 : volume;
         this.soundAdapter.soundTransform = soundTransform;
      }
      
      override protected function panChangeStart(newPan:Number) : void
      {
         var soundTransform:SoundTransform = this.soundAdapter.soundTransform;
         soundTransform.pan = newPan;
         this.soundAdapter.soundTransform = soundTransform;
      }
   }
}

