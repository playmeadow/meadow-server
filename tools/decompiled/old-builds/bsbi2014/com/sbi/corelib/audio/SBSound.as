package com.sbi.corelib.audio
{
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   
   public class SBSound
   {
      
      public var paused:Boolean = false;
      
      public var playVolume:Number = 1;
      
      public var s:Sound;
      
      public var sc:SoundChannel;
      
      private var _soundPlaying:Boolean;
      
      public function SBSound(soundClassName:Class, autoPlay:Boolean = true, vol:Number = 1)
      {
         super();
         this.s = new soundClassName();
         this.volume = vol;
         if(autoPlay)
         {
            this.play();
         }
         else
         {
            this.stop();
         }
         SBAudio.addSound(this);
      }
      
      public function play(startTime:Number = 0, loops:int = 0, sndTransform:SoundTransform = null) : void
      {
         if(loops == -1)
         {
            loops = int.MAX_VALUE;
         }
         if(this.s == null)
         {
            return;
         }
         this.sc = this.s.play(startTime,loops,sndTransform);
         if(this.sc == null)
         {
            return;
         }
         this._soundPlaying = true;
         this.sc.addEventListener(Event.SOUND_COMPLETE,this.soundStoppedHandler,false,0,true);
         this.setTransformVolume(this.playVolume);
      }
      
      public function destroy() : void
      {
         this.stop();
         this.sc = null;
         this.s = null;
         SBAudio.removeSound(this);
      }
      
      public function get volume() : Number
      {
         return Boolean(this.sc) ? this.sc.soundTransform.volume : -1;
      }
      
      public function set volume(vol:Number) : void
      {
         this.playVolume = vol;
         if(Boolean(this.sc))
         {
            this.setTransformVolume(vol);
         }
      }
      
      public function get isPlaying() : Boolean
      {
         return this._soundPlaying;
      }
      
      public function togglePause() : void
      {
         if(this.paused)
         {
            this.unpause();
         }
         else
         {
            this.pause();
         }
      }
      
      public function pause() : void
      {
         if(Boolean(this.sc) && !this.paused)
         {
            this.sc.stop();
            this.paused = true;
            this._soundPlaying = false;
         }
      }
      
      public function unpause() : void
      {
         if(Boolean(this.s) && Boolean(this.sc) && this.paused)
         {
            this.sc = this.s.play(this.sc.position);
            if(this.sc == null)
            {
               return;
            }
            this._soundPlaying = true;
            this.sc.addEventListener(Event.SOUND_COMPLETE,this.soundStoppedHandler,false,0,true);
            this.setTransformVolume(this.playVolume);
            this.paused = false;
         }
      }
      
      public function stop() : void
      {
         if(Boolean(this.sc))
         {
            this.sc.stop();
         }
         this.paused = false;
         this._soundPlaying = false;
      }
      
      private function setTransformVolume(vol:Number) : void
      {
         var transform:SoundTransform = this.sc.soundTransform;
         if(SBAudio.isMusicMuted)
         {
            transform.volume = 0;
         }
         else
         {
            transform.volume = vol;
         }
         this.sc.soundTransform = transform;
      }
      
      private function soundStoppedHandler(e:Event) : void
      {
         this._soundPlaying = false;
      }
   }
}

