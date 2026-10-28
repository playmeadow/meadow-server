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
      
      public function SoundManager(param1:GameBase, param2:int = 0)
      {
         super();
         this._soundVolume = new Dictionary(true);
         this._barSound = new Dictionary(true);
         this._soundChannel = new Dictionary(true);
         this._sound = new Dictionary(true);
         this._soundsPlaying = new Dictionary(true);
         this._soundVolumeByName = new Dictionary(true);
         this._sounds = new Array();
         this._minigame = param1;
         this._soundLimit = param2;
         if(!MainFrame.isInitialized())
         {
            LoaderCache.contentURL = "../../";
         }
      }
      
      public function setVolumes(param1:Dictionary) : void
      {
         var _loc2_:Object = null;
         for(_loc2_ in param1)
         {
            this._soundVolumeByName[_loc2_] = param1[_loc2_];
         }
      }
      
      private function getSound(param1:String) : Object
      {
         var _loc2_:Object = null;
         if(param1 == null)
         {
            return null;
         }
         for each(_loc2_ in this._sounds)
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
         var _loc4_:Object = this.getSound(param3);
         if(_loc4_ == null)
         {
            _loc4_ = new Object();
            _loc4_.sound = new param1() as Sound;
            if(param3)
            {
               _loc4_.name = param3;
            }
            this._sounds.push(_loc4_);
            this._sound[param1] = _loc4_.sound;
         }
         if(param2 >= 0)
         {
            this._soundVolume[_loc4_.sound] = param2;
         }
         else
         {
            this._soundVolume[_loc4_.sound] = this._soundVolumeByName[param3];
         }
         this._soundsPlaying[_loc4_.sound] = 0;
         var _loc5_:SoundTransform = new SoundTransform(0,0);
         var _loc6_:SoundChannel = _loc4_.sound.play(0,0,_loc5_);
         if(_loc6_)
         {
            _loc6_.stop();
         }
      }
      
      public function addStream(param1:String, param2:Number) : SBMusic
      {
         var _loc3_:Object = new Object();
         var _loc4_:SBMusic = new SBMusic(param1 + ".mp3",false,param2);
         _loc3_.sound = _loc4_;
         _loc3_.name = param1;
         this._soundVolume[_loc3_.sound] = param2;
         this._sounds.push(_loc3_);
         return _loc3_.sound;
      }
      
      public function play(param1:Class, param2:Number = 0, param3:int = 0) : SoundChannel
      {
         var _loc5_:Number = NaN;
         var _loc6_:SoundTransform = null;
         var _loc7_:SoundChannel = null;
         var _loc4_:Sound = this._sound[param1];
         if(_loc4_)
         {
            if(SBAudio.isMusicMuted)
            {
               _loc5_ = 0;
            }
            else
            {
               _loc5_ = Number(this._soundVolume[_loc4_]);
            }
            _loc6_ = new SoundTransform(_loc5_,0);
            if(this._soundLimit > 0)
            {
               if(this._soundsPlaying[_loc4_] >= this._soundLimit && param3 == 0)
               {
                  return null;
               }
               _loc7_ = _loc4_.play(param2,param3,_loc6_);
               if(_loc7_)
               {
                  this._soundsPlaying[_loc7_] = _loc4_;
                  ++this._soundsPlaying[_loc4_];
                  if(param3 == 0)
                  {
                     _loc7_.addEventListener(Event.SOUND_COMPLETE,this.soundComplete);
                  }
               }
               return _loc7_;
            }
            return _loc4_.play(param2,param3,_loc6_);
         }
         return null;
      }
      
      private function soundComplete(param1:Event) : void
      {
         param1.target.removeEventListener(Event.SOUND_COMPLETE,this.soundComplete);
         --this._soundsPlaying[this._soundsPlaying[param1.target]];
         this._soundsPlaying[param1.target] = null;
      }
      
      public function playStream(param1:SBMusic, param2:Number = 0, param3:int = 0) : SoundChannel
      {
         if(param1 == null)
         {
            return null;
         }
         var _loc4_:Number = Number(this._soundVolume[param1]);
         var _loc5_:SoundTransform = new SoundTransform(_loc4_,0);
         param1.stop();
         param1.play(param2,param3,_loc5_);
         if(param1.sc == null)
         {
            return null;
         }
         this._soundChannel[param1] = param1.sc;
         param1.sc.soundTransform = _loc5_;
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
         --this._soundsPlaying[this._soundsPlaying[param1]];
         param1.stop();
      }
      
      private function onPlay(param1:MouseEvent) : void
      {
         if(this._barSound[param1.target.parent] is Sound)
         {
            return;
         }
         this.playStream(this._barSound[param1.target.parent],0,9999);
      }
      
      private function onStop(param1:MouseEvent) : void
      {
         if(this._barSound[param1.target.parent] is Sound)
         {
            return;
         }
         this._barSound[param1.target.parent].stop();
      }
   }
}

