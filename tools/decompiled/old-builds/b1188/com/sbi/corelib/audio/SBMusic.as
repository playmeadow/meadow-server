package com.sbi.corelib.audio
{
   import com.sbi.loader.LoaderCache;
   import flash.events.IOErrorEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundLoaderContext;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   
   public class SBMusic
   {
      
      private var _hashKey:String;
      
      private var _previouslyPlayedFilename:String;
      
      private var _currFilename:String;
      
      private var _previousVolume:Number;
      
      private var _currVolume:Number;
      
      public var paused:Boolean = false;
      
      public var muted:Boolean = false;
      
      public var mutedVolume:Number = 1;
      
      public var playVolume:Number = 1;
      
      public var s:Sound;
      
      public var sc:SoundChannel;
      
      public var position:Number;
      
      public function SBMusic(param1:String, param2:Boolean = true, param3:Number = 1, param4:Number = 1000, param5:Boolean = true)
      {
         super();
         this.playNewMusic(param1,param2,param3,param4,param5);
         SBAudio.addMusic(this);
      }
      
      public function playNewMusic(param1:String, param2:Boolean = true, param3:Number = 1, param4:Number = 1000, param5:Boolean = true) : void
      {
         this._previouslyPlayedFilename = this._currFilename;
         this._currFilename = param1;
         this._previousVolume = this._currVolume;
         this._currVolume = param3;
         var _loc6_:URLRequest = LoaderCache.fetchCDNURLRequest("audio/" + param1);
         if(this.s)
         {
            this.s.removeEventListener(IOErrorEvent.IO_ERROR,this.handleIOError);
            this.s = null;
         }
         if(this.sc)
         {
            this.sc.stop();
            this.sc = null;
         }
         this.s = new Sound(_loc6_,new SoundLoaderContext(param4,param5));
         this.volume = param3;
         if(param2)
         {
            this.play();
         }
         else
         {
            this.stop();
         }
         this.s.addEventListener(IOErrorEvent.IO_ERROR,this.handleIOError,false,0,true);
      }
      
      public function play(param1:Number = 0, param2:int = 2147483647, param3:SoundTransform = null) : void
      {
         if(this.s == null)
         {
            return;
         }
         this.sc = this.s.play(param1,param2,param3);
         if(this.sc == null)
         {
            return;
         }
         this.setTransformVolume(this.playVolume);
      }
      
      public function get volume() : Number
      {
         return this.sc ? this.sc.soundTransform.volume : -1;
      }
      
      public function set volume(param1:Number) : void
      {
         if(this.muted)
         {
            this.mutedVolume = param1;
         }
         else
         {
            this.playVolume = param1;
         }
         if(this.sc)
         {
            this.setTransformVolume(param1);
         }
      }
      
      public function toggleMute() : void
      {
         if(this.muted)
         {
            this.unmute();
         }
         else
         {
            this.mute();
         }
      }
      
      public function mute() : void
      {
         if(!this.muted)
         {
            this.mutedVolume = this.volume;
            this.volume = 0;
            this.muted = true;
         }
      }
      
      public function unmute() : void
      {
         if(this.muted)
         {
            this.volume = this.mutedVolume;
            this.muted = false;
         }
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
         if(Boolean(this.s) && Boolean(this.sc) && !this.paused)
         {
            this.position = this.sc.position;
            this.sc.stop();
            this.paused = true;
         }
      }
      
      public function unpause() : void
      {
         if(Boolean(this.s) && Boolean(this.sc) && this.paused)
         {
            this.sc = this.s.play(this.position);
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
         this.muted = false;
      }
      
      public function get previouslyPlayedFilename() : String
      {
         return this._previouslyPlayedFilename;
      }
      
      public function get previousVolume() : Number
      {
         return this._previousVolume;
      }
      
      private function setTransformVolume(param1:Number) : void
      {
         var _loc2_:SoundTransform = this.sc.soundTransform;
         _loc2_.volume = param1;
         this.sc.soundTransform = _loc2_;
      }
      
      private function handleIOError(param1:IOErrorEvent) : void
      {
         if(this.s)
         {
            this.s = null;
         }
         if(this.sc)
         {
            this.sc.stop();
            this.sc = null;
         }
         SBAudio.removeMusic(this);
      }
   }
}

