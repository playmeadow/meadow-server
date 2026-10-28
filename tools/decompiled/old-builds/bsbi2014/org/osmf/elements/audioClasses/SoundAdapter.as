package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   
   [Event(name="progress",type="flash.events.ProgressEvent")]
   [Event(name="downloadComplete",type="flash.events.Event")]
   [Event(name="complete",type="flash.events.Event")]
   [ExcludeClass]
   public class SoundAdapter extends EventDispatcher
   {
      
      public static const DOWNLOAD_COMPLETE:String = "downloadComplete";
      
      private var owner:MediaElement;
      
      private var _soundTransform:SoundTransform;
      
      private var sound:Sound;
      
      private var playing:Boolean = false;
      
      private var channel:SoundChannel;
      
      private var lastStartTime:Number = 0;
      
      public function SoundAdapter(owner:MediaElement, sound:Sound)
      {
         super();
         this.owner = owner;
         this.sound = sound;
         this._soundTransform = new SoundTransform();
         sound.addEventListener(Event.COMPLETE,this.onDownloadComplete,false,0,true);
         sound.addEventListener(ProgressEvent.PROGRESS,this.onProgress,false,0,true);
         sound.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError,false,0,true);
      }
      
      public function get currentTime() : Number
      {
         return this.channel != null ? this.channel.position / 1000 : this.lastStartTime / 1000;
      }
      
      public function get estimatedDuration() : Number
      {
         return this.sound.length / (1000 * this.sound.bytesLoaded / this.sound.bytesTotal);
      }
      
      public function get soundTransform() : SoundTransform
      {
         return this._soundTransform;
      }
      
      public function set soundTransform(value:SoundTransform) : void
      {
         this._soundTransform = value;
         if(this.channel != null)
         {
            this.channel.soundTransform = value;
         }
      }
      
      public function play(time:Number = -1) : Boolean
      {
         var success:Boolean = false;
         if(this.channel == null)
         {
            try
            {
               this.channel = this.sound.play(time != -1 ? time : this.lastStartTime);
            }
            catch(error:ArgumentError)
            {
               channel = null;
            }
            if(this.channel != null)
            {
               this.playing = true;
               this.channel.soundTransform = this._soundTransform;
               this.channel.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
               success = true;
            }
            else
            {
               this.owner.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.SOUND_PLAY_FAILED)));
            }
         }
         return success;
      }
      
      public function pause() : void
      {
         if(this.channel != null)
         {
            this.lastStartTime = this.channel.position;
            this.clearChannel();
            this.playing = false;
         }
      }
      
      public function stop() : void
      {
         if(this.channel != null)
         {
            this.lastStartTime = 0;
            this.clearChannel();
            this.playing = false;
         }
      }
      
      public function seek(time:Number) : void
      {
         var wasPlaying:Boolean = this.playing;
         if(this.channel != null)
         {
            this.clearChannel();
         }
         this.play(time * 1000);
         if(wasPlaying == false)
         {
            this.pause();
         }
      }
      
      private function clearChannel() : void
      {
         if(this.channel != null)
         {
            this.channel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
            this.channel.stop();
            this.channel = null;
         }
      }
      
      private function onSoundComplete(event:Event) : void
      {
         this.lastStartTime = this.channel.position;
         this.clearChannel();
         this.playing = false;
         dispatchEvent(new Event(Event.COMPLETE));
      }
      
      private function onDownloadComplete(event:Event) : void
      {
         dispatchEvent(new Event(DOWNLOAD_COMPLETE));
      }
      
      private function onProgress(event:ProgressEvent) : void
      {
         dispatchEvent(event.clone());
      }
      
      private function onIOError(event:IOErrorEvent) : void
      {
         this.owner.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.IO_ERROR)));
      }
   }
}

