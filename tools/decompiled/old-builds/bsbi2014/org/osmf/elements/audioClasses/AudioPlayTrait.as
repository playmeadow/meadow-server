package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import org.osmf.traits.PlayState;
   import org.osmf.traits.PlayTrait;
   
   [ExcludeClass]
   public class AudioPlayTrait extends PlayTrait
   {
      
      private var lastPlayFailed:Boolean = false;
      
      private var soundAdapter:SoundAdapter;
      
      public function AudioPlayTrait(soundAdapter:SoundAdapter)
      {
         super();
         this.soundAdapter = soundAdapter;
         soundAdapter.addEventListener(Event.COMPLETE,this.onPlaybackComplete,false,1,true);
      }
      
      override protected function playStateChangeStart(newPlayState:String) : void
      {
         if(newPlayState == PlayState.PLAYING)
         {
            this.lastPlayFailed = !this.soundAdapter.play();
         }
         else if(newPlayState == PlayState.PAUSED)
         {
            this.soundAdapter.pause();
         }
         else if(newPlayState == PlayState.STOPPED)
         {
            this.soundAdapter.stop();
         }
      }
      
      override protected function playStateChangeEnd() : void
      {
         if(this.lastPlayFailed)
         {
            stop();
            this.lastPlayFailed = false;
         }
         else
         {
            super.playStateChangeEnd();
         }
      }
      
      private function onPlaybackComplete(event:Event) : void
      {
         stop();
      }
   }
}

