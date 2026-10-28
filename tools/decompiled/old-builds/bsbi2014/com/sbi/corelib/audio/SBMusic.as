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
      
      public function SBMusic(filename:String, autoPlay:Boolean = true, vol:Number = 1, bufferTime:Number = 1000, checkForPolicyFile:Boolean = true)
      {
         super();
         this.playNewMusic(filename,autoPlay,vol,bufferTime,checkForPolicyFile);
         SBAudio.addMusic(this);
      }
      
      public function playNewMusic(filename:String, autoPlay:Boolean = true, vol:Number = 1, bufferTime:Number = 1000, checkForPolicyFile:Boolean = true) : void
      {
         this._previouslyPlayedFilename = this._currFilename;
         this._currFilename = filename;
         this._previousVolume = this._currVolume;
         this._currVolume = vol;
         var cdnStreamURLRequest:URLRequest = LoaderCache.fetchCDNURLRequest("audio/" + filename);
         if(Boolean(this.s))
         {
            this.s.removeEventListener(IOErrorEvent.IO_ERROR,this.handleIOError);
            this.s = null;
         }
         if(Boolean(this.sc))
         {
            this.sc.stop();
            this.sc = null;
         }
         this.s = new Sound(cdnStreamURLRequest,new SoundLoaderContext(bufferTime,checkForPolicyFile));
         this.volume = vol;
         if(autoPlay)
         {
            this.play();
         }
         else
         {
            this.stop();
         }
         this.s.addEventListener(IOErrorEvent.IO_ERROR,this.handleIOError,false,0,true);
      }
      
      public function play(startTime:Number = 0, loops:int = 2147483647, sndTransform:SoundTransform = null) : void
      {
         if(this.s == null)
         {
            return;
         }
         this.sc = this.s.play(startTime,loops,sndTransform);
         if(this.sc == null)
         {
            return;
         }
         this.setTransformVolume(this.playVolume);
      }
      
      public function get volume() : Number
      {
         return Boolean(this.sc) ? this.sc.soundTransform.volume : -1;
      }
      
      public function set volume(vol:Number) : void
      {
         if(this.muted)
         {
            this.mutedVolume = vol;
         }
         else
         {
            this.playVolume = vol;
         }
         if(Boolean(this.sc))
         {
            this.setTransformVolume(vol);
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
         if(Boolean(this.sc))
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
      
      private function setTransformVolume(vol:Number) : void
      {
         var transform:SoundTransform = this.sc.soundTransform;
         transform.volume = vol;
         this.sc.soundTransform = transform;
      }
      
      private function handleIOError(i:IOErrorEvent) : void
      {
         if(Boolean(this.s))
         {
            trace("WARNING - IOError while attempting to load music:" + this.s.url);
            this.s = null;
         }
         if(Boolean(this.sc))
         {
            this.sc.stop();
            this.sc = null;
         }
         SBAudio.removeMusic(this);
      }
   }
}

