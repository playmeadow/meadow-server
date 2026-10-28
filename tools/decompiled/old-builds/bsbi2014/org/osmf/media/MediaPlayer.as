package org.osmf.media
{
   import flash.display.DisplayObject;
   import flash.errors.IllegalOperationError;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.osmf.events.AudioEvent;
   import org.osmf.events.BufferEvent;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.DynamicStreamEvent;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaElementChangeEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MediaPlayerCapabilityChangeEvent;
   import org.osmf.events.MediaPlayerStateChangeEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.SeekEvent;
   import org.osmf.events.TimeEvent;
   import org.osmf.traits.AudioTrait;
   import org.osmf.traits.BufferTrait;
   import org.osmf.traits.DRMState;
   import org.osmf.traits.DRMTrait;
   import org.osmf.traits.DVRTrait;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.traits.DynamicStreamTrait;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.traits.PlayState;
   import org.osmf.traits.PlayTrait;
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   import org.osmf.traits.TraitEventDispatcher;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="mediaError",type="org.osmf.events.MediaErrorEvent")]
   [Event(name="hasDisplayObjectChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="hasDRMChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="canLoadChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="hasAudioChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="temporalChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="isDynamicStreamChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="canSeekChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="canBufferChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="canPlayChange",type="org.osmf.events.MediaPlayerCapabilityChangeEvent")]
   [Event(name="bytesLoadedChange",type="org.osmf.events.LoadEvent")]
   [Event(name="currentTimeChange",type="org.osmf.events.TimeEvent")]
   [Event(name="mediaPlayerStateChange",type="org.osmf.events.MediaPlayerStateChangeEvent")]
   public class MediaPlayer extends TraitEventDispatcher
   {
      
      private static const DEFAULT_UPDATE_INTERVAL:Number = 250;
      
      private var lastCurrentTime:Number = 0;
      
      private var lastBytesLoaded:Number = NaN;
      
      private var _autoPlay:Boolean = true;
      
      private var _autoRewind:Boolean = true;
      
      private var _loop:Boolean = false;
      
      private var _currentTimeUpdateInterval:Number = 250;
      
      private var _currentTimeTimer:Timer = new Timer(DEFAULT_UPDATE_INTERVAL);
      
      private var _state:String;
      
      private var _bytesLoadedUpdateInterval:Number = 250;
      
      private var _bytesLoadedTimer:Timer = new Timer(DEFAULT_UPDATE_INTERVAL);
      
      private var inExecuteAutoRewind:Boolean = false;
      
      private var inSeek:Boolean = false;
      
      private var mediaAtEnd:Boolean = false;
      
      private var mediaPlayerVolume:Number = 1;
      
      private var mediaPlayerVolumeSet:Boolean = false;
      
      private var mediaPlayerMuted:Boolean = false;
      
      private var mediaPlayerMutedSet:Boolean = false;
      
      private var mediaPlayerAudioPan:Number = 0;
      
      private var mediaPlayerAudioPanSet:Boolean = false;
      
      private var mediaPlayerBufferTime:Number = 0;
      
      private var mediaPlayerBufferTimeSet:Boolean = false;
      
      private var mediaPlayerMaxAllowedDynamicStreamIndex:int = 0;
      
      private var mediaPlayerMaxAllowedDynamicStreamIndexSet:Boolean = false;
      
      private var mediaPlayerAutoDynamicStreamSwitch:Boolean = true;
      
      private var mediaPlayerAutoDynamicStreamSwitchSet:Boolean = false;
      
      private var _canPlay:Boolean;
      
      private var _canSeek:Boolean;
      
      private var _temporal:Boolean;
      
      private var _hasAudio:Boolean;
      
      private var _hasDisplayObject:Boolean;
      
      private var _canLoad:Boolean;
      
      private var _canBuffer:Boolean;
      
      private var _isDynamicStream:Boolean;
      
      private var _hasDRM:Boolean;
      
      public function MediaPlayer(media:MediaElement = null)
      {
         super();
         this._state = MediaPlayerState.UNINITIALIZED;
         this.media = media;
         this._currentTimeTimer.addEventListener(TimerEvent.TIMER,this.onCurrentTimeTimer,false,0,true);
         this._bytesLoadedTimer.addEventListener(TimerEvent.TIMER,this.onBytesLoadedTimer,false,0,true);
      }
      
      override public function set media(value:MediaElement) : void
      {
         var traitType:String = null;
         var loadTrait:LoadTrait = null;
         if(value != media)
         {
            this.mediaAtEnd = false;
            if(media != null)
            {
               this.inExecuteAutoRewind = false;
               if(this.playing)
               {
                  (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
               }
               if(this.canLoad)
               {
                  loadTrait = media.getTrait(MediaTraitType.LOAD) as LoadTrait;
                  if(loadTrait.loadState == LoadState.READY)
                  {
                     loadTrait.unload();
                  }
               }
               this.setState(MediaPlayerState.UNINITIALIZED);
               if(Boolean(media))
               {
                  media.removeEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
                  media.removeEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
                  media.removeEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError);
                  for each(traitType in media.traitTypes)
                  {
                     this.updateTraitListeners(traitType,false);
                  }
               }
            }
            super.media = value;
            if(media != null)
            {
               media.addEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
               media.addEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
               media.addEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError);
               if(media.hasTrait(MediaTraitType.LOAD) == false)
               {
                  this.processReadyState();
               }
               for each(traitType in media.traitTypes)
               {
                  this.updateTraitListeners(traitType,true);
               }
            }
            dispatchEvent(new MediaElementChangeEvent(MediaElementChangeEvent.MEDIA_ELEMENT_CHANGE));
         }
      }
      
      public function set autoRewind(value:Boolean) : void
      {
         this._autoRewind = value;
      }
      
      public function get autoRewind() : Boolean
      {
         return this._autoRewind;
      }
      
      public function set autoPlay(value:Boolean) : void
      {
         this._autoPlay = value;
      }
      
      public function get autoPlay() : Boolean
      {
         return this._autoPlay;
      }
      
      public function set loop(value:Boolean) : void
      {
         this._loop = value;
      }
      
      public function get loop() : Boolean
      {
         return this._loop;
      }
      
      public function set currentTimeUpdateInterval(value:Number) : void
      {
         if(this._currentTimeUpdateInterval != value)
         {
            this._currentTimeUpdateInterval = value;
            if(isNaN(this._currentTimeUpdateInterval) || this._currentTimeUpdateInterval <= 0)
            {
               this._currentTimeTimer.stop();
            }
            else
            {
               this._currentTimeTimer.delay = this._currentTimeUpdateInterval;
               if(this.temporal)
               {
                  this._currentTimeTimer.start();
               }
            }
         }
      }
      
      public function get currentTimeUpdateInterval() : Number
      {
         return this._currentTimeUpdateInterval;
      }
      
      public function set bytesLoadedUpdateInterval(value:Number) : void
      {
         if(this._bytesLoadedUpdateInterval != value)
         {
            this._bytesLoadedUpdateInterval = value;
            if(isNaN(this._bytesLoadedUpdateInterval) || this._bytesLoadedUpdateInterval <= 0)
            {
               this._bytesLoadedTimer.stop();
            }
            else
            {
               this._bytesLoadedTimer.delay = this._bytesLoadedUpdateInterval;
               if(this.canLoad)
               {
                  this._bytesLoadedTimer.start();
               }
            }
         }
      }
      
      public function get bytesLoadedUpdateInterval() : Number
      {
         return this._bytesLoadedUpdateInterval;
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      public function get canPlay() : Boolean
      {
         return this._canPlay;
      }
      
      public function get canPause() : Boolean
      {
         return this.canPlay ? (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).canPause : false;
      }
      
      public function get canSeek() : Boolean
      {
         return this._canSeek;
      }
      
      public function get temporal() : Boolean
      {
         return this._temporal;
      }
      
      public function get hasAudio() : Boolean
      {
         return this._hasAudio;
      }
      
      public function get isDynamicStream() : Boolean
      {
         return this._isDynamicStream;
      }
      
      public function get canLoad() : Boolean
      {
         return this._canLoad;
      }
      
      public function get canBuffer() : Boolean
      {
         return this._canBuffer;
      }
      
      public function get hasDRM() : Boolean
      {
         return this._hasDRM;
      }
      
      public function get volume() : Number
      {
         return this.hasAudio ? AudioTrait(this.getTraitOrThrow(MediaTraitType.AUDIO)).volume : this.mediaPlayerVolume;
      }
      
      public function set volume(value:Number) : void
      {
         var doDispatchEvent:Boolean = false;
         if(this.hasAudio)
         {
            (this.getTraitOrThrow(MediaTraitType.AUDIO) as AudioTrait).volume = value;
         }
         else if(value != this.mediaPlayerVolume)
         {
            doDispatchEvent = true;
         }
         this.mediaPlayerVolume = value;
         this.mediaPlayerVolumeSet = true;
         if(doDispatchEvent)
         {
            dispatchEvent(new AudioEvent(AudioEvent.VOLUME_CHANGE,false,false,false,value));
         }
      }
      
      public function get muted() : Boolean
      {
         return this.hasAudio ? AudioTrait(this.getTraitOrThrow(MediaTraitType.AUDIO)).muted : this.mediaPlayerMuted;
      }
      
      public function set muted(value:Boolean) : void
      {
         var doDispatchEvent:Boolean = false;
         if(this.hasAudio)
         {
            (this.getTraitOrThrow(MediaTraitType.AUDIO) as AudioTrait).muted = value;
         }
         else if(value != this.mediaPlayerMuted)
         {
            doDispatchEvent = true;
         }
         this.mediaPlayerMuted = value;
         this.mediaPlayerMutedSet = true;
         if(doDispatchEvent)
         {
            dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE,false,false,value));
         }
      }
      
      public function get audioPan() : Number
      {
         return this.hasAudio ? AudioTrait(this.getTraitOrThrow(MediaTraitType.AUDIO)).pan : this.mediaPlayerAudioPan;
      }
      
      public function set audioPan(value:Number) : void
      {
         var doDispatchEvent:Boolean = false;
         if(this.hasAudio)
         {
            (this.getTraitOrThrow(MediaTraitType.AUDIO) as AudioTrait).pan = value;
         }
         else if(value != this.mediaPlayerAudioPan)
         {
            doDispatchEvent = true;
         }
         this.mediaPlayerAudioPan = value;
         this.mediaPlayerAudioPanSet = true;
         if(doDispatchEvent)
         {
            dispatchEvent(new AudioEvent(AudioEvent.PAN_CHANGE,false,false,false,NaN,value));
         }
      }
      
      public function get paused() : Boolean
      {
         return this.canPlay ? (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).playState == PlayState.PAUSED : false;
      }
      
      public function pause() : void
      {
         (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).pause();
      }
      
      public function get playing() : Boolean
      {
         return this.canPlay ? (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).playState == PlayState.PLAYING : false;
      }
      
      public function play() : void
      {
         if(this.canPlay && this.canSeek && this.canSeekTo(0) && this.mediaAtEnd)
         {
            this.executeAutoRewind(true);
         }
         else
         {
            (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).play();
         }
      }
      
      public function get seeking() : Boolean
      {
         return this.canSeek ? (this.getTraitOrThrow(MediaTraitType.SEEK) as SeekTrait).seeking : false;
      }
      
      public function seek(time:Number) : void
      {
         this.inSeek = true;
         (this.getTraitOrThrow(MediaTraitType.SEEK) as SeekTrait).seek(time);
         this.inSeek = false;
      }
      
      public function canSeekTo(time:Number) : Boolean
      {
         return (this.getTraitOrThrow(MediaTraitType.SEEK) as SeekTrait).canSeekTo(time);
      }
      
      public function stop() : void
      {
         (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
         if(this.canSeek)
         {
            this.executeAutoRewind(false);
         }
      }
      
      public function get mediaWidth() : Number
      {
         return this._hasDisplayObject ? (this.getTraitOrThrow(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).mediaWidth : NaN;
      }
      
      public function get mediaHeight() : Number
      {
         return this._hasDisplayObject ? (this.getTraitOrThrow(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).mediaHeight : NaN;
      }
      
      public function get autoDynamicStreamSwitch() : Boolean
      {
         return this.isDynamicStream ? (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).autoSwitch : this.mediaPlayerAutoDynamicStreamSwitch;
      }
      
      public function set autoDynamicStreamSwitch(value:Boolean) : void
      {
         var doDispatchEvent:Boolean = false;
         if(this.isDynamicStream)
         {
            (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).autoSwitch = value;
         }
         else if(value != this.mediaPlayerAutoDynamicStreamSwitch)
         {
            doDispatchEvent = true;
         }
         this.mediaPlayerAutoDynamicStreamSwitch = value;
         this.mediaPlayerAutoDynamicStreamSwitchSet = true;
         if(doDispatchEvent)
         {
            dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE,false,false,this.dynamicStreamSwitching,this.mediaPlayerAutoDynamicStreamSwitch));
         }
      }
      
      public function get currentDynamicStreamIndex() : int
      {
         return this.isDynamicStream ? (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).currentIndex : 0;
      }
      
      public function get numDynamicStreams() : int
      {
         return this.isDynamicStream ? (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).numDynamicStreams : 0;
      }
      
      public function getBitrateForDynamicStreamIndex(index:int) : Number
      {
         return (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).getBitrateForIndex(index);
      }
      
      public function get maxAllowedDynamicStreamIndex() : int
      {
         return this.isDynamicStream ? (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).maxAllowedIndex : this.mediaPlayerMaxAllowedDynamicStreamIndex;
      }
      
      public function set maxAllowedDynamicStreamIndex(value:int) : void
      {
         if(this.isDynamicStream)
         {
            (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).maxAllowedIndex = value;
         }
         this.mediaPlayerMaxAllowedDynamicStreamIndex = value;
         this.mediaPlayerMaxAllowedDynamicStreamIndexSet = true;
      }
      
      public function get dynamicStreamSwitching() : Boolean
      {
         return this.isDynamicStream ? (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).switching : false;
      }
      
      public function switchDynamicStreamIndex(streamIndex:int) : void
      {
         (this.getTraitOrThrow(MediaTraitType.DYNAMIC_STREAM) as DynamicStreamTrait).switchTo(streamIndex);
      }
      
      public function get displayObject() : DisplayObject
      {
         return this._hasDisplayObject ? (this.getTraitOrThrow(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait).displayObject : null;
      }
      
      public function get duration() : Number
      {
         return this.temporal ? (this.getTraitOrThrow(MediaTraitType.TIME) as TimeTrait).duration : 0;
      }
      
      public function get currentTime() : Number
      {
         return this.temporal ? (this.getTraitOrThrow(MediaTraitType.TIME) as TimeTrait).currentTime : 0;
      }
      
      public function get buffering() : Boolean
      {
         return this.canBuffer ? (this.getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).buffering : false;
      }
      
      public function get bufferLength() : Number
      {
         return this.canBuffer ? (this.getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).bufferLength : 0;
      }
      
      public function get bufferTime() : Number
      {
         return this.canBuffer ? (this.getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).bufferTime : this.mediaPlayerBufferTime;
      }
      
      public function set bufferTime(value:Number) : void
      {
         var doDispatchEvent:Boolean = false;
         if(this.canBuffer)
         {
            (this.getTraitOrThrow(MediaTraitType.BUFFER) as BufferTrait).bufferTime = value;
         }
         else if(value != this.mediaPlayerBufferTime)
         {
            doDispatchEvent = true;
         }
         this.mediaPlayerBufferTime = value;
         this.mediaPlayerBufferTimeSet = true;
         if(doDispatchEvent)
         {
            dispatchEvent(new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE,false,false,this.buffering,this.mediaPlayerBufferTime));
         }
      }
      
      public function get bytesLoaded() : Number
      {
         var bytes:Number = 0;
         if(this.canLoad)
         {
            bytes = (this.getTraitOrThrow(MediaTraitType.LOAD) as LoadTrait).bytesLoaded;
            if(isNaN(bytes))
            {
               bytes = 0;
            }
         }
         return bytes;
      }
      
      public function get bytesTotal() : Number
      {
         var bytes:Number = 0;
         if(this.canLoad)
         {
            bytes = (this.getTraitOrThrow(MediaTraitType.LOAD) as LoadTrait).bytesTotal;
            if(isNaN(bytes))
            {
               bytes = 0;
            }
         }
         return bytes;
      }
      
      public function authenticate(username:String = null, password:String = null) : void
      {
         (this.getTraitOrThrow(MediaTraitType.DRM) as DRMTrait).authenticate(username,password);
      }
      
      public function authenticateWithToken(token:Object) : void
      {
         (this.getTraitOrThrow(MediaTraitType.DRM) as DRMTrait).authenticateWithToken(token);
      }
      
      public function get drmState() : String
      {
         return this.hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).drmState : DRMState.UNINITIALIZED;
      }
      
      public function get drmStartDate() : Date
      {
         return this.hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).startDate : null;
      }
      
      public function get drmEndDate() : Date
      {
         return this.hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).endDate : null;
      }
      
      public function get drmPeriod() : Number
      {
         return this.hasDRM ? DRMTrait(media.getTrait(MediaTraitType.DRM)).period : NaN;
      }
      
      public function get isDVRRecording() : Boolean
      {
         var dvrTrait:DVRTrait = media != null ? media.getTrait(MediaTraitType.DVR) as DVRTrait : null;
         return dvrTrait != null ? dvrTrait.isRecording : false;
      }
      
      private function getTraitOrThrow(traitType:String) : MediaTraitBase
      {
         var error:String = null;
         var traitName:String = null;
         if(!media || !media.hasTrait(traitType))
         {
            error = OSMFStrings.getString(OSMFStrings.CAPABILITY_NOT_SUPPORTED);
            traitName = traitType.replace("[class ","");
            traitName = traitName.replace("]","").toLowerCase();
            error = error.replace("*trait*",traitName);
            throw new IllegalOperationError(error);
         }
         return media.getTrait(traitType);
      }
      
      private function onMediaError(event:MediaErrorEvent) : void
      {
         this.setState(MediaPlayerState.PLAYBACK_ERROR);
         dispatchEvent(event.clone());
      }
      
      private function onTraitAdd(event:MediaElementEvent) : void
      {
         this.updateTraitListeners(event.traitType,true);
      }
      
      private function onTraitRemove(event:MediaElementEvent) : void
      {
         this.updateTraitListeners(event.traitType,false);
      }
      
      private function updateTraitListeners(traitType:String, add:Boolean, skipIfInErrorState:Boolean = true) : void
      {
         var timeTrait:TimeTrait = null;
         var playTrait:PlayTrait = null;
         var audioTrait:AudioTrait = null;
         var dynamicStreamTrait:DynamicStreamTrait = null;
         var displayObjectTrait:DisplayObjectTrait = null;
         var loadTrait:LoadTrait = null;
         var bufferTrait:BufferTrait = null;
         var loadState:String = null;
         if(this.state == MediaPlayerState.PLAYBACK_ERROR && skipIfInErrorState && traitType != MediaTraitType.LOAD)
         {
            return;
         }
         if(add)
         {
            this.updateCapabilityForTrait(traitType,add);
         }
         switch(traitType)
         {
            case MediaTraitType.TIME:
               this.changeListeners(add,traitType,TimeEvent.COMPLETE,this.onComplete);
               this._temporal = add;
               if(add && this._currentTimeUpdateInterval > 0 && !isNaN(this._currentTimeUpdateInterval))
               {
                  this._currentTimeTimer.start();
               }
               else
               {
                  this._currentTimeTimer.stop();
               }
               timeTrait = TimeTrait(media.getTrait(MediaTraitType.TIME));
               if(timeTrait.currentTime != 0 && this._currentTimeUpdateInterval > 0 && !isNaN(this._currentTimeUpdateInterval))
               {
                  dispatchEvent(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE,false,false,this.currentTime));
               }
               if(timeTrait.duration != 0)
               {
                  dispatchEvent(new TimeEvent(TimeEvent.DURATION_CHANGE,false,false,this.duration));
               }
               break;
            case MediaTraitType.PLAY:
               this.changeListeners(add,traitType,PlayEvent.PLAY_STATE_CHANGE,this.onPlayStateChange);
               this._canPlay = add;
               playTrait = PlayTrait(media.getTrait(MediaTraitType.PLAY));
               if(this.autoPlay && this.canPlay && !this.playing && !this.inSeek)
               {
                  this.play();
               }
               else if(playTrait.playState != PlayState.STOPPED)
               {
                  dispatchEvent(new PlayEvent(PlayEvent.PLAY_STATE_CHANGE,false,false,add ? playTrait.playState : PlayState.STOPPED));
               }
               if(playTrait.canPause)
               {
                  dispatchEvent(new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE,false,false,null,add));
               }
               break;
            case MediaTraitType.AUDIO:
               this._hasAudio = add;
               audioTrait = AudioTrait(media.getTrait(MediaTraitType.AUDIO));
               if(this.mediaPlayerVolumeSet)
               {
                  this.volume = this.mediaPlayerVolume;
               }
               else if(this.mediaPlayerVolume != audioTrait.volume)
               {
                  dispatchEvent(new AudioEvent(AudioEvent.VOLUME_CHANGE,false,false,this.muted,this.volume,this.audioPan));
               }
               if(this.mediaPlayerMutedSet)
               {
                  this.muted = this.mediaPlayerMuted;
               }
               else if(this.mediaPlayerMuted != audioTrait.muted)
               {
                  dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE,false,false,this.muted,this.volume,this.audioPan));
               }
               if(this.mediaPlayerAudioPanSet)
               {
                  this.audioPan = this.mediaPlayerAudioPan;
               }
               else if(this.mediaPlayerAudioPan != audioTrait.pan)
               {
                  dispatchEvent(new AudioEvent(AudioEvent.PAN_CHANGE,false,false,this.muted,this.volume,this.audioPan));
               }
               break;
            case MediaTraitType.SEEK:
               this.changeListeners(add,traitType,SeekEvent.SEEKING_CHANGE,this.onSeeking);
               this._canSeek = add;
               if(SeekTrait(media.getTrait(MediaTraitType.SEEK)).seeking && !this.inExecuteAutoRewind)
               {
                  dispatchEvent(new SeekEvent(SeekEvent.SEEKING_CHANGE,false,false,add));
               }
               break;
            case MediaTraitType.DYNAMIC_STREAM:
               this._isDynamicStream = add;
               dynamicStreamTrait = DynamicStreamTrait(media.getTrait(MediaTraitType.DYNAMIC_STREAM));
               if(this.mediaPlayerMaxAllowedDynamicStreamIndexSet)
               {
                  this.maxAllowedDynamicStreamIndex = this.mediaPlayerMaxAllowedDynamicStreamIndex;
               }
               if(this.mediaPlayerAutoDynamicStreamSwitchSet)
               {
                  this.autoDynamicStreamSwitch = this.mediaPlayerAutoDynamicStreamSwitch;
               }
               else if(this.mediaPlayerAutoDynamicStreamSwitch != dynamicStreamTrait.autoSwitch)
               {
                  dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE,false,false,this.dynamicStreamSwitching,this.autoDynamicStreamSwitch));
               }
               if(dynamicStreamTrait.switching)
               {
                  dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.SWITCHING_CHANGE,false,false,this.dynamicStreamSwitching,this.autoDynamicStreamSwitch));
               }
               dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE,false,false,this.dynamicStreamSwitching,this.autoDynamicStreamSwitch));
               break;
            case MediaTraitType.DISPLAY_OBJECT:
               this._hasDisplayObject = add;
               displayObjectTrait = DisplayObjectTrait(media.getTrait(MediaTraitType.DISPLAY_OBJECT));
               if(displayObjectTrait.displayObject != null)
               {
                  dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.DISPLAY_OBJECT_CHANGE,false,false,null,this.displayObject,NaN,NaN,this.mediaWidth,this.mediaHeight));
               }
               if(!isNaN(displayObjectTrait.mediaHeight) || !isNaN(displayObjectTrait.mediaWidth))
               {
                  dispatchEvent(new DisplayObjectEvent(DisplayObjectEvent.MEDIA_SIZE_CHANGE,false,false,null,this.displayObject,NaN,NaN,this.mediaWidth,this.mediaHeight));
               }
               break;
            case MediaTraitType.LOAD:
               this.changeListeners(add,traitType,LoadEvent.LOAD_STATE_CHANGE,this.onLoadState);
               this._canLoad = add;
               loadTrait = LoadTrait(media.getTrait(MediaTraitType.LOAD));
               if(loadTrait.bytesLoaded > 0)
               {
                  dispatchEvent(new LoadEvent(LoadEvent.BYTES_LOADED_CHANGE,false,false,null,this.bytesLoaded));
               }
               if(loadTrait.bytesTotal > 0)
               {
                  dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE,false,false,null,this.bytesTotal));
               }
               if(add)
               {
                  loadState = (media.getTrait(traitType) as LoadTrait).loadState;
                  if(loadState != LoadState.READY && loadState != LoadState.LOADING)
                  {
                     this.load();
                  }
                  else if(this.autoPlay && this.canPlay && !this.playing)
                  {
                     this.play();
                  }
                  if(this._bytesLoadedUpdateInterval > 0 && !isNaN(this._bytesLoadedUpdateInterval))
                  {
                     this._bytesLoadedTimer.start();
                  }
                  else
                  {
                     this._bytesLoadedTimer.stop();
                  }
               }
               break;
            case MediaTraitType.BUFFER:
               this.changeListeners(add,traitType,BufferEvent.BUFFERING_CHANGE,this.onBuffering);
               this._canBuffer = add;
               bufferTrait = BufferTrait(media.getTrait(MediaTraitType.BUFFER));
               if(this.mediaPlayerBufferTimeSet)
               {
                  this.bufferTime = this.mediaPlayerBufferTime;
               }
               else if(this.mediaPlayerBufferTime != bufferTrait.bufferTime)
               {
                  dispatchEvent(new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE,false,false,false,this.bufferTime));
               }
               if(bufferTrait.buffering)
               {
                  dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE,false,false,this.buffering));
               }
               break;
            case MediaTraitType.DRM:
               this._hasDRM = add;
               dispatchEvent(new DRMEvent(DRMEvent.DRM_STATE_CHANGE,this.drmState,false,false,this.drmStartDate,this.drmEndDate,this.drmPeriod));
         }
         if(add == false)
         {
            this.updateCapabilityForTrait(traitType,false);
         }
      }
      
      private function updateCapabilityForTrait(traitType:String, capabilityAdd:Boolean) : void
      {
         var eventType:String = null;
         switch(traitType)
         {
            case MediaTraitType.AUDIO:
               eventType = MediaPlayerCapabilityChangeEvent.HAS_AUDIO_CHANGE;
               this._hasAudio = capabilityAdd;
               break;
            case MediaTraitType.BUFFER:
               eventType = MediaPlayerCapabilityChangeEvent.CAN_BUFFER_CHANGE;
               this._canBuffer = capabilityAdd;
               break;
            case MediaTraitType.DISPLAY_OBJECT:
               eventType = MediaPlayerCapabilityChangeEvent.HAS_DISPLAY_OBJECT_CHANGE;
               break;
            case MediaTraitType.DRM:
               eventType = MediaPlayerCapabilityChangeEvent.HAS_DRM_CHANGE;
               this._hasDRM = capabilityAdd;
               break;
            case MediaTraitType.DYNAMIC_STREAM:
               eventType = MediaPlayerCapabilityChangeEvent.IS_DYNAMIC_STREAM_CHANGE;
               this._isDynamicStream = capabilityAdd;
               break;
            case MediaTraitType.LOAD:
               eventType = MediaPlayerCapabilityChangeEvent.CAN_LOAD_CHANGE;
               this._canLoad = capabilityAdd;
               break;
            case MediaTraitType.PLAY:
               eventType = MediaPlayerCapabilityChangeEvent.CAN_PLAY_CHANGE;
               this._canPlay = capabilityAdd;
               break;
            case MediaTraitType.SEEK:
               eventType = MediaPlayerCapabilityChangeEvent.CAN_SEEK_CHANGE;
               this._canSeek = capabilityAdd;
               break;
            case MediaTraitType.TIME:
               eventType = MediaPlayerCapabilityChangeEvent.TEMPORAL_CHANGE;
               this._temporal = capabilityAdd;
         }
         if(eventType != null)
         {
            dispatchEvent(new MediaPlayerCapabilityChangeEvent(eventType,false,false,capabilityAdd));
         }
      }
      
      private function changeListeners(add:Boolean, traitType:String, event:String, listener:Function) : void
      {
         var priority:int = 0;
         if(add)
         {
            priority = 1;
            media.getTrait(traitType).addEventListener(event,listener,false,priority);
         }
         else if(media.hasTrait(traitType))
         {
            media.getTrait(traitType).removeEventListener(event,listener);
         }
      }
      
      private function onSeeking(event:SeekEvent) : void
      {
         this.mediaAtEnd = false;
         if(event.type == SeekEvent.SEEKING_CHANGE && event.seeking)
         {
            this.setState(MediaPlayerState.BUFFERING);
         }
         else if(this.canPlay && this.playing)
         {
            this.setState(MediaPlayerState.PLAYING);
         }
         else if(this.canPlay && this.paused)
         {
            this.setState(MediaPlayerState.PAUSED);
         }
         else if(this.canBuffer && this.buffering)
         {
            this.setState(MediaPlayerState.BUFFERING);
         }
         else if(!this.inExecuteAutoRewind)
         {
            this.setState(MediaPlayerState.READY);
         }
      }
      
      private function onPlayStateChange(event:PlayEvent) : void
      {
         if(event.playState == PlayState.PLAYING)
         {
            if(this.canBuffer == false || this.bufferLength > 0 || this.bufferTime < 0.001)
            {
               this.setState(MediaPlayerState.PLAYING);
            }
         }
         else if(event.playState == PlayState.PAUSED)
         {
            this.setState(MediaPlayerState.PAUSED);
         }
      }
      
      private function onLoadState(event:LoadEvent) : void
      {
         if(event.loadState == LoadState.READY && this.state == MediaPlayerState.LOADING)
         {
            this.processReadyState();
         }
         else if(event.loadState == LoadState.UNINITIALIZED)
         {
            this.setState(MediaPlayerState.UNINITIALIZED);
         }
         else if(event.loadState == LoadState.LOAD_ERROR)
         {
            this.setState(MediaPlayerState.PLAYBACK_ERROR);
         }
         else if(event.loadState == LoadState.LOADING)
         {
            this.setState(MediaPlayerState.LOADING);
         }
      }
      
      private function processReadyState() : void
      {
         this.setState(MediaPlayerState.READY);
         if(this.autoPlay && this.canPlay && !this.playing)
         {
            this.play();
         }
      }
      
      private function onComplete(event:TimeEvent) : void
      {
         this.mediaAtEnd = true;
         if(this.loop && this.canSeek && this.canPlay)
         {
            this.executeAutoRewind(true);
         }
         else if(!this.loop && this.canPlay)
         {
            (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
            if(this.autoRewind && this.canSeek)
            {
               this.executeAutoRewind(false);
            }
            else
            {
               this.setState(MediaPlayerState.READY);
            }
         }
         else
         {
            this.setState(MediaPlayerState.READY);
         }
      }
      
      private function executeAutoRewind(playAfterAutoRewind:Boolean) : void
      {
         var onSeekingChange:Function = null;
         if(this.inExecuteAutoRewind == false)
         {
            onSeekingChange = function(event:SeekEvent):void
            {
               if(event.seeking == false)
               {
                  removeEventListener(SeekEvent.SEEKING_CHANGE,onSeekingChange);
                  if(playAfterAutoRewind)
                  {
                     play();
                  }
                  else
                  {
                     setState(MediaPlayerState.READY);
                  }
                  inExecuteAutoRewind = false;
               }
            };
            this.inExecuteAutoRewind = true;
            this.mediaAtEnd = false;
            addEventListener(SeekEvent.SEEKING_CHANGE,onSeekingChange);
            this.seek(0);
         }
      }
      
      private function onCurrentTimeTimer(event:TimerEvent) : void
      {
         if(this.temporal && this.currentTime != this.lastCurrentTime && (!this.canSeek || !this.seeking))
         {
            this.lastCurrentTime = this.currentTime;
            dispatchEvent(new TimeEvent(TimeEvent.CURRENT_TIME_CHANGE,false,false,this.currentTime));
         }
      }
      
      private function onBytesLoadedTimer(event:TimerEvent) : void
      {
         var bytesLoadedEvent:LoadEvent = null;
         if(this.canLoad && this.bytesLoaded != this.lastBytesLoaded)
         {
            bytesLoadedEvent = new LoadEvent(LoadEvent.BYTES_LOADED_CHANGE,false,false,null,this.bytesLoaded);
            this.lastBytesLoaded = this.bytesLoaded;
            dispatchEvent(bytesLoadedEvent);
         }
      }
      
      private function onBuffering(event:BufferEvent) : void
      {
         if(event.buffering)
         {
            this.setState(MediaPlayerState.BUFFERING);
         }
         else if(this.canPlay && this.playing)
         {
            this.setState(MediaPlayerState.PLAYING);
         }
         else if(this.canPlay && this.paused)
         {
            this.setState(MediaPlayerState.PAUSED);
         }
         else
         {
            this.setState(MediaPlayerState.READY);
         }
      }
      
      private function setState(newState:String) : void
      {
         var playing:Boolean = false;
         var traitType:String = null;
         if(this._state != newState)
         {
            this._state = newState;
            dispatchEvent(new MediaPlayerStateChangeEvent(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE,false,false,this._state));
            if(newState == MediaPlayerState.PLAYBACK_ERROR)
            {
               playing = this.playing;
               for each(traitType in media.traitTypes)
               {
                  if(traitType != MediaTraitType.LOAD)
                  {
                     this.updateTraitListeners(traitType,false,false);
                  }
               }
               if(playing)
               {
                  (this.getTraitOrThrow(MediaTraitType.PLAY) as PlayTrait).stop();
               }
            }
         }
      }
      
      private function load() : void
      {
         var loadTrait:LoadTrait = null;
         try
         {
            loadTrait = media.getTrait(MediaTraitType.LOAD) as LoadTrait;
            if(loadTrait.loadState != LoadState.LOADING && loadTrait.loadState != LoadState.READY)
            {
               loadTrait.load();
            }
         }
         catch(error:IllegalOperationError)
         {
            setState(MediaPlayerState.PLAYBACK_ERROR);
            dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.MEDIA_LOAD_FAILED,error.message)));
         }
      }
   }
}

