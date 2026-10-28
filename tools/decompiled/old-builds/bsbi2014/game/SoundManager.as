package game
{
   import com.sbi.corelib.audio.SBAudio;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.loader.LoaderCache;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   import flash.ui.Keyboard;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import gui.GuiManager;
   
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
      
      private var SoundTool:Class = SoundManager_SoundTool;
      
      public function SoundManager(minigame:GameBase, soundLimit:int = 0)
      {
         super();
         this._soundVolume = new Dictionary(true);
         this._barSound = new Dictionary(true);
         this._soundChannel = new Dictionary(true);
         this._sound = new Dictionary(true);
         this._soundsPlaying = new Dictionary(true);
         this._soundVolumeByName = new Dictionary(true);
         this._sounds = new Array();
         this._minigame = minigame;
         this._soundLimit = soundLimit;
         if(Boolean(this._minigame) && Boolean(this._minigame.stage))
         {
            this._minigame.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyboardPressed,false,0,true);
         }
         else
         {
            gMainFrame.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyboardPressed,false,0,true);
         }
         if(!MainFrame.isInitialized())
         {
            LoaderCache.contentURL = "../../";
         }
      }
      
      public function setVolumes(volumes:Dictionary) : void
      {
         var key:Object = null;
         for(key in volumes)
         {
            this._soundVolumeByName[key] = volumes[key];
         }
      }
      
      private function getSound(name:String) : Object
      {
         var o:Object = null;
         if(name == null)
         {
            return null;
         }
         for each(o in this._sounds)
         {
            if(o.name == name)
            {
               return o;
            }
         }
         return null;
      }
      
      public function addSound(sndClass:Class, volume:Number, name:String = null) : void
      {
         var snd:Object = this.getSound(name);
         if(snd == null)
         {
            snd = new Object();
            snd.sound = new sndClass() as Sound;
            if(Boolean(name))
            {
               snd.name = name;
            }
            this._sounds.push(snd);
            this._sound[sndClass] = snd.sound;
         }
         if(volume >= 0)
         {
            this._soundVolume[snd.sound] = volume;
         }
         else
         {
            this._soundVolume[snd.sound] = this._soundVolumeByName[name];
         }
         this._soundsPlaying[snd.sound] = 0;
         var st:SoundTransform = new SoundTransform(0,0);
         var sc:SoundChannel = snd.sound.play(0,0,st);
         if(Boolean(sc))
         {
            sc.stop();
         }
      }
      
      public function addStream(name:String, volume:Number) : SBMusic
      {
         var snd:Object = new Object();
         var stream:SBMusic = new SBMusic(name + ".mp3",false,volume);
         snd.sound = stream;
         snd.name = name;
         this._soundVolume[snd.sound] = volume;
         this._sounds.push(snd);
         return snd.sound;
      }
      
      public function play(sndClass:Class, startTime:Number = 0, loops:int = 0) : SoundChannel
      {
         var volume:Number = NaN;
         var st:SoundTransform = null;
         var sc:SoundChannel = null;
         var sound:Sound = this._sound[sndClass];
         if(Boolean(sound))
         {
            if(SBAudio.isMusicMuted)
            {
               volume = 0;
            }
            else
            {
               volume = Number(this._soundVolume[sound]);
            }
            st = new SoundTransform(volume,0);
            if(this._soundLimit > 0)
            {
               if(this._soundsPlaying[sound] >= this._soundLimit && loops == 0)
               {
                  return null;
               }
               sc = sound.play(startTime,loops,st);
               if(Boolean(sc))
               {
                  this._soundsPlaying[sc] = sound;
                  ++this._soundsPlaying[sound];
                  if(loops == 0)
                  {
                     sc.addEventListener(Event.SOUND_COMPLETE,this.soundComplete);
                  }
               }
               return sc;
            }
            return sound.play(startTime,loops,st);
         }
         return null;
      }
      
      private function soundComplete(e:Event) : void
      {
         e.target.removeEventListener(Event.SOUND_COMPLETE,this.soundComplete);
         --this._soundsPlaying[this._soundsPlaying[e.target]];
         this._soundsPlaying[e.target] = null;
      }
      
      private function doFadeIn(e:Event) : void
      {
         var fadeInValue:Number = (getTimer() - this._lastTimeFadeIn) / 1000;
         if(fadeInValue >= 1)
         {
            fadeInValue = 1;
            gMainFrame.stage.removeEventListener(Event.ENTER_FRAME,this.doFadeIn);
         }
         var volume:Number = this._soundVolume[this._fadeInStream] * fadeInValue;
         var currentSC:SoundChannel = this._fadeInStream.sc;
         var st:SoundTransform = new SoundTransform(volume,0);
         this._fadeInStream.sc.soundTransform = st;
         if(fadeInValue == 1)
         {
            this._fadeInStream = null;
         }
      }
      
      private function doFadeOut(e:Event) : void
      {
         var fadeOutValue:Number = (getTimer() - this._lastTimeFadeOut) / 1000;
         if(fadeOutValue >= 1)
         {
            fadeOutValue = 1;
            gMainFrame.stage.removeEventListener(Event.ENTER_FRAME,this.doFadeOut);
         }
         var volume:Number = this._soundVolume[this._fadeOutStream] * (1 - fadeOutValue);
         var currentSC:SoundChannel = this._fadeOutStream.sc;
         var st:SoundTransform = new SoundTransform(volume,0);
         this._fadeOutStream.sc.soundTransform = st;
         if(fadeOutValue == 1)
         {
            this._fadeOutStream.sc.stop();
            this._fadeOutStream = null;
         }
      }
      
      public function destroy() : void
      {
         if(Boolean(this._fadeInStream))
         {
            gMainFrame.stage.removeEventListener(Event.ENTER_FRAME,this.doFadeIn);
            this._fadeInStream = null;
         }
         if(Boolean(this._fadeOutStream))
         {
            this._fadeOutStream.sc.stop();
            this._fadeOutStream = null;
            gMainFrame.stage.removeEventListener(Event.ENTER_FRAME,this.doFadeOut);
         }
      }
      
      public function fadeOut(stream:SBMusic) : void
      {
         if(SBAudio.isMusicMuted)
         {
            stream.stop();
            return;
         }
         this._lastTimeFadeOut = getTimer();
         this._fadeOutStream = stream;
         gMainFrame.stage.addEventListener(Event.ENTER_FRAME,this.doFadeOut,false,0,true);
      }
      
      public function playStream(stream:SBMusic, startTime:Number = 0, loops:int = 0, fade:Boolean = false) : SoundChannel
      {
         var st:SoundTransform = null;
         if(SBAudio.isMusicMuted)
         {
            fade = false;
         }
         if(stream == null)
         {
            return null;
         }
         var volume:Number = Number(this._soundVolume[stream]);
         if(fade)
         {
            st = new SoundTransform(0,0);
            gMainFrame.stage.addEventListener(Event.ENTER_FRAME,this.doFadeIn,false,0,true);
            this._lastTimeFadeIn = getTimer();
            this._fadeInStream = stream;
         }
         else
         {
            st = new SoundTransform(volume,0);
         }
         stream.stop();
         stream.play(startTime,loops,st);
         if(stream.sc == null)
         {
            return null;
         }
         this._soundChannel[stream] = stream.sc;
         stream.sc.soundTransform = st;
         if(SBAudio.isMusicMuted)
         {
            stream.mute();
         }
         return stream.sc;
      }
      
      public function pauseStream(stream:SBMusic) : void
      {
         stream.pause();
      }
      
      public function unpauseStream(stream:SBMusic) : void
      {
         stream.unpause();
      }
      
      public function togglePauseStream(stream:SBMusic) : void
      {
         stream.togglePause();
      }
      
      public function stop(sound:SoundChannel) : void
      {
         --this._soundsPlaying[this._soundsPlaying[sound]];
         sound.stop();
      }
      
      private function onPlay(event:MouseEvent) : void
      {
         if(this._barSound[event.target.parent] is Sound)
         {
            this.playToolSound(this._barSound[event.target.parent]);
            return;
         }
         this.playStream(this._barSound[event.target.parent],0,9999);
      }
      
      private function onStop(event:MouseEvent) : void
      {
         var sound:Sound = null;
         if(this._barSound[event.target.parent] is Sound)
         {
            sound = this._barSound[event.target.parent];
            if(Boolean(this._soundChannel[sound]))
            {
               this._soundChannel[sound].stop();
            }
            return;
         }
         this._barSound[event.target.parent].stop();
      }
      
      public function onComplete(event:Event) : void
      {
         var bar:MovieClip = null;
         var snd:Object = null;
         var volume:int = 0;
         var loader:Loader = this._soundToolInstace.getChildAt(0) as Loader;
         var content:Object = Object(loader.content);
         content.background.x = 0;
         content.background.y = 0;
         content.background.width = 900;
         content.background.height = Math.max(900,50 + this._sounds.length / 4 * 65);
         content.title.x = 0.5 * (content.background.width - content.title.width);
         for(var i:int = 0; i < this._sounds.length; i++)
         {
            bar = content.createBar();
            volume = int(this._soundVolume[this._sounds[i].sound] * 100);
            bar.volume.text = String(volume);
            bar.song_text.text = this._sounds[i].name;
            bar.scaleX = 0.5;
            bar.scaleY = 0.5;
            bar.x = 30 + i % 4 * bar.width * 1.1;
            bar.y = 50 + Math.floor(i / 4) * bar.height;
            this._barSound[bar] = this._sounds[i].sound;
            bar.slider.x = volume / 100 * BARWIDTH;
            bar.slider.addEventListener(MouseEvent.MOUSE_DOWN,this.onPress);
            bar.slider.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
            bar.volume.addEventListener(Event.CHANGE,this.onVolumeChange);
            bar.play_btn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPlay);
            bar.stop_btn.addEventListener(MouseEvent.MOUSE_DOWN,this.onStop);
         }
         this._soundToolInstace.removeEventListener(Event.COMPLETE,this.onComplete);
         this._soundToolInstace.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheel);
      }
      
      private function onKeyDownS(e:KeyboardEvent) : void
      {
         if(Boolean(this._soundToolInstace))
         {
            switch(e.keyCode)
            {
               case Keyboard.PAGE_DOWN:
                  this._soundToolInstace.y -= 10;
                  break;
               case Keyboard.PAGE_UP:
                  if(this._soundToolInstace.y < 0)
                  {
                     this._soundToolInstace.y += 10;
                  }
            }
         }
      }
      
      private function onMouseWheel(e:MouseEvent) : void
      {
         var loader:Loader = this._soundToolInstace.getChildAt(0) as Loader;
         if(e.delta > 0)
         {
            if(e.currentTarget.y < 0)
            {
               e.currentTarget.y += 10;
            }
         }
         else if(e.currentTarget.y > 1100 - loader.content.height)
         {
            e.currentTarget.y -= 10;
         }
      }
      
      private function onPress(event:MouseEvent) : void
      {
         event.target.startDrag(false,new Rectangle(0,20,BARWIDTH * 2,0));
         this._currentDragger = event.target as MovieClip;
         event.target.stage.addEventListener(MouseEvent.MOUSE_UP,this.onRelease);
      }
      
      private function onRelease(event:MouseEvent) : void
      {
         var volume:int = 0;
         var transform:SoundTransform = null;
         if(Boolean(this._currentDragger))
         {
            volume = int(this._currentDragger.x / BARWIDTH * 100);
            this._currentDragger.stopDrag();
            Object(this._currentDragger.parent).volume.text = String(volume);
            this._soundVolume[this._barSound[Object(this._currentDragger.parent)]] = volume / 100;
            if(Boolean(this._soundChannel[this._barSound[Object(this._currentDragger.parent)]]))
            {
               transform = this._soundChannel[this._barSound[Object(this._currentDragger.parent)]].soundTransform;
               transform.volume = volume / 100;
               this._soundChannel[this._barSound[Object(this._currentDragger.parent)]].soundTransform = transform;
            }
         }
         this._currentDragger = null;
      }
      
      private function onVolumeChange(event:Event) : void
      {
         var transform:SoundTransform = null;
         if(parseInt(event.target.text) > 200)
         {
            event.target.text = String(200);
         }
         else if(parseInt(event.target.text) < 0)
         {
            event.target.text = String(0);
         }
         var volume:Number = parseInt(event.target.text) / 100;
         this._soundVolume[this._barSound[event.target.parent]] = volume;
         event.target.parent.slider.x = volume * BARWIDTH;
         if(Boolean(this._soundChannel[this._barSound[event.target.parent]]))
         {
            transform = this._soundChannel[this._barSound[event.target.parent]].soundTransform;
            transform.volume = volume;
            this._soundChannel[this._barSound[event.target.parent]].soundTransform = transform;
         }
      }
      
      public function invokeSoundTool() : void
      {
         if(this._soundToolInstace == null)
         {
            this._soundToolInstace = new this.SoundTool();
            this._soundToolInstace.addEventListener(Event.COMPLETE,this.onComplete);
            GuiManager.guiLayer.addChild(this._soundToolInstace);
         }
         else
         {
            this.closeSoundTool();
         }
      }
      
      private function playToolSound(sound:Sound) : void
      {
         var volume:Number = Number(this._soundVolume[sound]);
         var st:SoundTransform = new SoundTransform(volume,0);
         var looping:Boolean = false;
         if(Boolean(this._soundChannel[sound]))
         {
            looping = true;
            this._soundChannel[sound].stop();
            delete this._soundChannel[sound];
         }
         this._soundChannel[sound] = sound.play(0,0,st);
      }
      
      public function closeSoundTool() : void
      {
         GuiManager.guiLayer.removeChild(this._soundToolInstace);
         Loader(this._soundToolInstace.getChildAt(0)).unloadAndStop();
         this._soundToolInstace = null;
      }
      
      private function keyboardPressed(event:KeyboardEvent) : void
      {
         if(event.keyCode == Keyboard.F6)
         {
            this.invokeSoundTool();
         }
         else
         {
            this.onKeyDownS(event);
         }
      }
   }
}

