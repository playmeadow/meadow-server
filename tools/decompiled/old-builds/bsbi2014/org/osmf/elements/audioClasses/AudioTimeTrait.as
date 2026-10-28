package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import org.osmf.traits.TimeTrait;
   
   [ExcludeClass]
   public class AudioTimeTrait extends TimeTrait
   {
      
      private var soundAdapter:SoundAdapter;
      
      public function AudioTimeTrait(soundAdapter:SoundAdapter)
      {
         super();
         this.soundAdapter = soundAdapter;
         soundAdapter.addEventListener(ProgressEvent.PROGRESS,this.onDownloadProgress,false,0,true);
         soundAdapter.addEventListener(SoundAdapter.DOWNLOAD_COMPLETE,this.onDownloadComplete,false,0,true);
         soundAdapter.addEventListener(Event.COMPLETE,this.onPlaybackComplete,false,0,true);
      }
      
      override public function get currentTime() : Number
      {
         return this.soundAdapter.currentTime;
      }
      
      private function onDownloadProgress(event:Event) : void
      {
         if(!isNaN(this.soundAdapter.estimatedDuration) && this.soundAdapter.estimatedDuration > 0)
         {
            this.soundAdapter.removeEventListener(ProgressEvent.PROGRESS,this.onDownloadProgress);
            setDuration(this.soundAdapter.estimatedDuration);
         }
      }
      
      private function onDownloadComplete(event:Event) : void
      {
         setDuration(this.soundAdapter.estimatedDuration);
      }
      
      private function onPlaybackComplete(event:Event) : void
      {
         signalComplete();
      }
   }
}

