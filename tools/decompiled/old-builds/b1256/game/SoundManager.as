package game
{
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.loader.LoaderCache;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   
   public class SoundManager
   {
      
      private static const BARWIDTH:int = 136;
      
      public var _soundVolume:Dictionary;
      
      public var _soundChannel:Dictionary;
      
      public var _sound:Dictionary;
      
      private var _soundsPlaying:Dictionary;
      
      private var _soundLimit:int;
      
      public var _sounds:Array;
      
      public var _soundToolInstace:MovieClip;
      
      public var _barSound:Dictionary;
      
      public var _minigame:GameBase;
      
      private var _currentDragger:MovieClip;
      
      private var _soundVolumeByName:Dictionary;
      
      private var _lastTimeFadeIn:Number;
      
      private var _lastTimeFadeOut:Number;
      
      private var _fadeInStream:SBMusic;
      
      private var _fadeOutStream:SBMusic;
      
      public function SoundManager(param1:GameBase, param2:int = 0)
      {
         super();
         _soundVolume = new Dictionary(true);
         _barSound = new Dictionary(true);
         _soundChannel = new Dictionary(true);
         _sound = new Dictionary(true);
         _soundsPlaying = new Dictionary(true);
         _soundVolumeByName = new Dictionary(true);
         _sounds = [];
         _minigame = param1;
         _soundLimit = param2;
         if(!MainFrame.isInitialized())
         {
            LoaderCache.contentURL = "../../";
         }
      }
      
      public function setVolumes(param1:Dictionary) : void
      {
         for(var _loc2_:Object in param1)
         {
            _soundVolumeByName[_loc2_] = param1[_loc2_];
         }
      }
      
      private function getSound(param1:String) : Object
      {
         var _loc2_:* = null;
         if(param1 == null)
         {
            return null;
         }
         for each(_loc2_ in _sounds)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function addSound(param1:Class, param2:Number, param3:String = null) : void
      {
         var _loc6_:Object = getSound(param3);
         if(_loc6_ == null)
         {
            _loc6_ = {};
            _loc6_.sound = new param1() as Sound;
            if(param3)
            {
               _loc6_.name = param3;
            }
            _sounds.push(_loc6_);
            _sound[param1] = _loc6_.sound;
         }
         if(param2 >= 0)
         {
            _soundVolume[_loc6_.sound] = param2;
         }
         else
         {
            _soundVolume[_loc6_.sound] = _soundVolumeByName[param3];
         }
         _soundsPlaying[_loc6_.sound] = 0;
         var _loc5_:SoundTransform = new SoundTransform(0,0);
         var _loc4_:SoundChannel = _loc6_.sound.play(0,0,_loc5_);
         if(_loc4_)
         {
            _loc4_.stop();
         }
      }
      
      public function addStream(param1:String, param2:Number) : SBMusic
      {
         var _loc4_:Object = {};
         var _loc3_:SBMusic = new SBMusic(param1 + ".mp3",false,param2);
         _loc4_.sound = _loc3_;
         _loc4_.name = param1;
         _soundVolume[_loc4_.sound] = param2;
         _sounds.push(_loc4_);
         return _loc4_.sound;
      }
      
      public function play(param1:Class, param2:Number = 0, param3:int = 0) : SoundChannel
      {
         var _loc5_:Number = NaN;
         var _loc7_:SoundTransform = null;
         var _loc6_:SoundChannel = null;
         var _loc4_:Sound = _sound[param1];
         if(_loc4_)
         {
            if(SBAudio.isMusicMuted)
            {
               _loc5_ = 0;
            }
            else
            {
               _loc5_ = Number(_soundVolume[_loc4_]);
            }
            _loc7_ = new SoundTransform(_loc5_,0);
            if(_soundLimit > 0)
            {
               if(_soundsPlaying[_loc4_] >= _soundLimit && param3 == 0)
               {
                  return null;
               }
               _loc6_ = _loc4_.play(param2,param3,_loc7_);
               if(_loc6_)
               {
                  _soundsPlaying[_loc6_] = _loc4_;
                  _soundsPlaying[_loc4_]++;
                  if(param3 == 0)
                  {
                     _loc6_.addEventListener("soundComplete",soundComplete);
                  }
               }
               return _loc6_;
            }
            return _loc4_.play(param2,param3,_loc7_);
         }
         return null;
      }
      
      private function soundComplete(param1:Event) : void
      {
         param1.target.removeEventListener("soundComplete",soundComplete);
         _soundsPlaying[_soundsPlaying[param1.target]]--;
         _soundsPlaying[param1.target] = null;
      }
      
      private function doFadeIn(param1:Event) : void
      {
         var _loc5_:Number = (getTimer() - _lastTimeFadeIn) / 1000;
         if(_loc5_ >= 1)
         {
            _loc5_ = 1;
            gMainFrame.stage.removeEventListener("enterFrame",doFadeIn);
         }
         var _loc2_:Number = _soundVolume[_fadeInStream] * _loc5_;
         var _loc3_:SoundChannel = _fadeInStream.sc;
         var _loc4_:SoundTransform = new SoundTransform(_loc2_,0);
         _fadeInStream.sc.soundTransform = _loc4_;
         if(_loc5_ == 1)
         {
            _fadeInStream = null;
         }
      }
      
      private function doFadeOut(param1:Event) : void
      {
         var _loc2_:Number = (getTimer() - _lastTimeFadeOut) / 1000;
         if(_loc2_ >= 1)
         {
            _loc2_ = 1;
            gMainFrame.stage.removeEventListener("enterFrame",doFadeOut);
         }
         var _loc3_:Number = _soundVolume[_fadeOutStream] * (1 - _loc2_);
         var _loc4_:SoundTransform = new SoundTransform(_loc3_,0);
         _fadeOutStream.sc.soundTransform = _loc4_;
         if(_loc2_ == 1)
         {
            _fadeOutStream.sc.stop();
            _fadeOutStream = null;
         }
      }
      
      public function destroy() : void
      {
         if(_fadeInStream)
         {
            gMainFrame.stage.removeEventListener("enterFrame",doFadeIn);
            _fadeInStream = null;
         }
         if(_fadeOutStream)
         {
            _fadeOutStream.sc.stop();
            _fadeOutStream = null;
            gMainFrame.stage.removeEventListener("enterFrame",doFadeOut);
         }
      }
      
      public function fadeOut(param1:SBMusic) : void
      {
         if(SBAudio.isMusicMuted)
         {
            param1.stop();
            return;
         }
         _lastTimeFadeOut = getTimer();
         _fadeOutStream = param1;
         gMainFrame.stage.addEventListener("enterFrame",doFadeOut,false,0,true);
      }
      
      public function playStream(param1:SBMusic, param2:Number = 0, param3:int = 0, param4:Boolean = false) : SoundChannel
      {
         var _loc6_:SoundTransform = null;
         if(SBAudio.isMusicMuted)
         {
            param4 = false;
         }
         if(param1 == null)
         {
            return null;
         }
         var _loc5_:Number = Number(_soundVolume[param1]);
         if(_fadeOutStream == param1)
         {
            gMainFrame.stage.removeEventListener("enterFrame",doFadeOut);
            _loc5_ = Number(_soundVolume[_fadeOutStream]);
            _loc6_ = new SoundTransform(_loc5_,0);
            _fadeOutStream.sc.soundTransform = _loc6_;
            return _fadeOutStream.sc;
         }
         if(param4)
         {
            _loc6_ = new SoundTransform(0,0);
            gMainFrame.stage.addEventListener("enterFrame",doFadeIn,false,0,true);
            _lastTimeFadeIn = getTimer();
            _fadeInStream = param1;
         }
         else
         {
            _loc6_ = new SoundTransform(_loc5_,0);
         }
         param1.stop();
         param1.play(param2,param3,_loc6_);
         if(param1.sc == null)
         {
            return null;
         }
         _soundChannel[param1] = param1.sc;
         param1.sc.soundTransform = _loc6_;
         if(SBAudio.isMusicMuted)
         {
            param1.mute();
         }
         return param1.sc;
      }
      
      public function pauseStream(param1:SBMusic) : void
      {
         param1.pause();
      }
      
      public function unpauseStream(param1:SBMusic) : void
      {
         param1.unpause();
      }
      
      public function togglePauseStream(param1:SBMusic) : void
      {
         param1.togglePause();
      }
      
      public function stop(param1:SoundChannel) : void
      {
         _soundsPlaying[_soundsPlaying[param1]]--;
         param1.stop();
      }
      
      private function onPlay(param1:MouseEvent) : void
      {
         if(_barSound[param1.target.parent] is Sound)
         {
            return;
         }
         playStream(_barSound[param1.target.parent],0,9999);
      }
      
      private function onStop(param1:MouseEvent) : void
      {
         if(_barSound[param1.target.parent] is Sound)
         {
            return;
         }
         _barSound[param1.target.parent].stop();
      }
   }
}

