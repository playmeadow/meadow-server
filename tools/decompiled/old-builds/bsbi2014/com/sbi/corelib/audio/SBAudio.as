package com.sbi.corelib.audio
{
   import flash.net.SharedObject;
   import flash.utils.Dictionary;
   
   public class SBAudio
   {
      
      private static var _cachedSounds:Dictionary;
      
      private static var _sharedObj:SharedObject;
      
      private static var _muteCallback:Function;
      
      private static var _sounds:Array = [];
      
      private static var _music:Array = [];
      
      private static var _isMusicMuted:Boolean = false;
      
      private static var _areSoundsMuted:Boolean = false;
      
      private static var _isInitialized:Boolean = false;
      
      public function SBAudio()
      {
         super();
      }
      
      public static function init(cachedSoundObjects:Object, muteCallBack:Function) : void
      {
         var sfxClassName:String = null;
         var sfxObject:Object = null;
         _cachedSounds = new Dictionary();
         for(sfxClassName in cachedSoundObjects)
         {
            sfxObject = cachedSoundObjects[sfxClassName];
            addCachedSound(sfxClassName,sfxObject.className,sfxObject.volume);
         }
         _muteCallback = muteCallBack;
         _isInitialized = true;
      }
      
      public static function setupSharedObject(sharedObj:SharedObject) : void
      {
         if(_sharedObj == null && sharedObj != null)
         {
            _sharedObj = sharedObj;
            if(Boolean(_sharedObj.data.isMusicMuted))
            {
               muteMusic();
            }
            if(Boolean(_sharedObj.data.areSoundsMuted))
            {
               muteSounds();
            }
         }
      }
      
      public static function addCachedSound(className:String, classVar:Class, defVolume:Number = 0.3) : void
      {
         _cachedSounds[className] = new SBSound(classVar,false,defVolume);
      }
      
      public static function get isMusicMuted() : Boolean
      {
         return _isMusicMuted;
      }
      
      public static function get areSoundsMuted() : Boolean
      {
         return _areSoundsMuted;
      }
      
      public static function get isInitialized() : Boolean
      {
         return _isInitialized;
      }
      
      public static function addSound(sound:SBSound) : void
      {
         _sounds.push(sound);
      }
      
      public static function removeSound(sound:SBSound) : void
      {
         _sounds.splice(_sounds.indexOf(sound),1);
      }
      
      public static function addMusic(music:Object) : void
      {
         _music.push(music);
      }
      
      public static function removeMusic(music:Object) : void
      {
         _music.splice(_music.indexOf(music),1);
      }
      
      public static function playCachedSound(className:String, loopCount:int = 1) : void
      {
         var sfx:SBSound = _cachedSounds[className];
         if(!sfx)
         {
            return;
         }
         sfx.play(0,loopCount);
      }
      
      public static function stopCachedSound(className:String) : void
      {
         var sfx:SBSound = _cachedSounds[className];
         if(!sfx)
         {
            return;
         }
         sfx.stop();
      }
      
      public static function setVolumeAll(vol:Number) : void
      {
         setVolumeSounds(vol);
         setVolumeMusic(vol);
      }
      
      public static function setVolumeSounds(vol:Number) : void
      {
         var s:SBSound = null;
         for each(s in _sounds)
         {
            s.volume = vol;
         }
      }
      
      public static function getVolumeMusic() : Number
      {
         var vol:Number = NaN;
         var m:Object = null;
         for each(m in _music)
         {
            vol = Number(m.volume);
         }
         return vol;
      }
      
      public static function setVolumeMusic(vol:Number) : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.volume = vol;
         }
      }
      
      private static function setSharedObjMusicMuted(isMuted:Boolean) : void
      {
         if(_sharedObj != null && _sharedObj.data.isMusicMuted != isMuted)
         {
            _sharedObj.data.isMusicMuted = isMuted;
            try
            {
               _sharedObj.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      private static function setSharedObjSoundsMuted(isMuted:Boolean) : void
      {
         if(_sharedObj != null && _sharedObj.data.areSoundsMuted != isMuted)
         {
            _sharedObj.data.areSoundsMuted = isMuted;
            try
            {
               _sharedObj.flush();
            }
            catch(e:Error)
            {
            }
         }
      }
      
      public static function toggleMuteAll() : void
      {
         toggleMuteSounds();
         toggleMuteMusic();
         _muteCallback(_isMusicMuted);
      }
      
      public static function muteAll() : void
      {
         muteSounds();
         muteMusic();
      }
      
      public static function unmuteAll() : void
      {
         unmuteSounds();
         unmuteMusic();
      }
      
      public static function toggleMuteSounds() : void
      {
         _areSoundsMuted = !_areSoundsMuted;
         setSharedObjSoundsMuted(_areSoundsMuted);
      }
      
      public static function muteSounds() : void
      {
         _areSoundsMuted = true;
         setSharedObjSoundsMuted(true);
      }
      
      public static function unmuteSounds() : void
      {
         _areSoundsMuted = false;
         setSharedObjSoundsMuted(false);
      }
      
      public static function toggleMuteMusic() : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.toggleMute();
         }
         _isMusicMuted = !_isMusicMuted;
         setSharedObjMusicMuted(_isMusicMuted);
      }
      
      public static function muteMusic(setFlags:Boolean = true) : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.mute();
         }
         if(setFlags)
         {
            _isMusicMuted = true;
            setSharedObjMusicMuted(true);
         }
      }
      
      public static function unmuteMusic(setFlags:Boolean = true) : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.unmute();
         }
         if(setFlags)
         {
            _isMusicMuted = false;
            setSharedObjMusicMuted(false);
         }
      }
      
      public static function togglePauseAll() : void
      {
         togglePauseSounds();
         togglePauseMusic();
      }
      
      public static function pauseAll() : void
      {
         pauseSounds();
         pauseMusic();
      }
      
      public static function unpauseAll() : void
      {
         unpauseSounds();
         unpauseMusic();
      }
      
      public static function togglePauseSounds() : void
      {
         var s:SBSound = null;
         for each(s in _sounds)
         {
            s.togglePause();
         }
      }
      
      public static function pauseSounds() : void
      {
         var s:SBSound = null;
         for each(s in _sounds)
         {
            s.pause();
         }
      }
      
      public static function unpauseSounds() : void
      {
         var s:SBSound = null;
         for each(s in _sounds)
         {
            s.unpause();
         }
      }
      
      public static function togglePauseMusic() : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.togglePause();
         }
      }
      
      public static function pauseMusic() : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.pause();
         }
      }
      
      public static function unpauseMusic() : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.unpause();
         }
      }
      
      public static function stopAll() : void
      {
         stopSounds();
         stopMusic();
      }
      
      public static function stopSounds() : void
      {
         var s:SBSound = null;
         for each(s in _sounds)
         {
            s.stop();
         }
      }
      
      public static function stopMusic() : void
      {
         var m:Object = null;
         for each(m in _music)
         {
            m.stop();
         }
      }
   }
}

