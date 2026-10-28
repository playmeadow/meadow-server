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
      
      public function SBSound(param1:Class, param2:Boolean = true, param3:Number = 1)
      {
         super();
         this.s = new param1();
         this.volume = param3;
         if(param2)
         {
            this.play();
         }
         else
         {
            this.stop();
         }
         SBAudio.addSound(this);
      }
      
      public function play(param1:Number = 0, param2:int = 0, param3:SoundTransform = null) : void
      {
         if(param2 == -1)
         {
            param2 = int.MAX_VALUE;
         }
         if(this.s == null)
         {
            return;
         }
         this.sc = this.s.play(param1,param2,param3);
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
         return this.sc ? this.sc.soundTransform.volume : -1;
      }
      
      public function set volume(param1:Number) : void
      {
         this.playVolume = param1;
         if(this.sc)
         {
            this.setTransformVolume(param1);
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
         if(this.sc)
         {
            this.sc.stop();
         }
         this.paused = false;
         this._soundPlaying = false;
      }
      
      private function setTransformVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = this.sc.soundTransform;
         if(SBAudio.isMusicMuted)
         {
            _loc2_.volume = 0;
         }
         else
         {
            _loc2_.volume = param1;
         }
         this.sc.soundTransform = _loc2_;
      }
      
      private function soundStoppedHandler(param1:Event) : void
      {
         this._soundPlaying = false;
      }
   }
}

