package org.osmf.metadata
{
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MetadataEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.SeekEvent;
   import org.osmf.events.TimelineMetadataEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.traits.PlayState;
   import org.osmf.traits.PlayTrait;
   import org.osmf.traits.SeekTrait;
   import org.osmf.traits.TimeTrait;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="markerDurationReached",type="org.osmf.events.TimelineMetadataEvent")]
   [Event(name="markerTimeReached",type="org.osmf.events.TimelineMetadataEvent")]
   [Event(name="markerRemove",type="org.osmf.metadata.TimelineMetadataEvent")]
   [Event(name="markerAdd",type="org.osmf.metadata.TimelineMetadataEvent")]
   public class TimelineMetadata extends Metadata
   {
      
      private static const CHECK_INTERVAL:Number = 100;
      
      private static const TOLERANCE:Number = 0.25;
      
      private var temporalKeyCollection:Vector.<Number>;
      
      private var temporalValueCollection:Vector.<TimelineMarker>;
      
      private var media:MediaElement;
      
      private var timeTrait:TimeTrait;
      
      private var seekTrait:SeekTrait;
      
      private var playTrait:PlayTrait;
      
      private var lastFiredTemporalMetadataIndex:int;
      
      private var intervalTimer:Timer;
      
      private var restartTimer:Boolean;
      
      private var _enabled:Boolean;
      
      private var durationTimers:Dictionary;
      
      public function TimelineMetadata(media:MediaElement)
      {
         super();
         if(media == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.media = media;
         this._enabled = true;
         this.intervalTimer = new Timer(CHECK_INTERVAL);
         this.intervalTimer.addEventListener(TimerEvent.TIMER,this.onIntervalTimer);
         this.timeTrait = media.getTrait(MediaTraitType.TIME) as TimeTrait;
         this.seekTrait = media.getTrait(MediaTraitType.SEEK) as SeekTrait;
         this.setupTraitEventListener(MediaTraitType.SEEK);
         this.playTrait = media.getTrait(MediaTraitType.PLAY) as PlayTrait;
         this.setupTraitEventListener(MediaTraitType.PLAY);
         media.addEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
         media.addEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
      }
      
      public function get numMarkers() : int
      {
         return Boolean(this.temporalValueCollection) ? int(this.temporalValueCollection.length) : 0;
      }
      
      public function getMarkerAt(index:int) : TimelineMarker
      {
         if(index >= 0 && this.temporalValueCollection != null && index < this.temporalValueCollection.length)
         {
            return this.temporalValueCollection[index];
         }
         return null;
      }
      
      public function addMarker(marker:TimelineMarker) : void
      {
         if(marker == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this.addValue("" + marker.time,marker);
      }
      
      public function removeMarker(marker:TimelineMarker) : TimelineMarker
      {
         if(marker == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this.removeValue("" + marker.time);
      }
      
      override public function addValue(key:String, value:Object) : void
      {
         var index:int = 0;
         var time:Number = new Number(key);
         var marker:TimelineMarker = value as TimelineMarker;
         if(key == null || isNaN(time) || time < 0 || marker == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         if(this.temporalValueCollection == null)
         {
            this.temporalKeyCollection = new Vector.<Number>();
            this.temporalKeyCollection.push(time);
            this.temporalValueCollection = new Vector.<TimelineMarker>();
            this.temporalValueCollection.push(value);
         }
         else
         {
            index = this.findTemporalMetadata(0,this.temporalValueCollection.length - 1,time);
            if(index < 0)
            {
               index *= -1;
               this.temporalKeyCollection.splice(index,0,time);
               this.temporalValueCollection.splice(index,0,marker);
            }
            else if(index == 0 && time != this.temporalKeyCollection[0])
            {
               this.temporalKeyCollection.splice(index,0,time);
               this.temporalValueCollection.splice(index,0,marker);
            }
            else
            {
               this.temporalKeyCollection[index] = time;
               this.temporalValueCollection[index] = marker;
            }
         }
         this.enabled = true;
         dispatchEvent(new MetadataEvent(MetadataEvent.VALUE_ADD,false,false,key,marker));
         dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_ADD,false,false,marker));
      }
      
      override public function removeValue(key:String) : *
      {
         if(key == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         var time:Number = new Number(key);
         var result:* = null;
         var index:int = Boolean(this.temporalValueCollection) ? this.findTemporalMetadata(0,this.temporalValueCollection.length - 1,time) : -1;
         if(index >= 0)
         {
            this.temporalKeyCollection.splice(index,1);
            result = this.temporalValueCollection.splice(index,1)[0];
            if(this.temporalValueCollection.length == 0)
            {
               this.reset(false);
               this.temporalValueCollection = null;
               this.temporalKeyCollection = null;
            }
            dispatchEvent(new MetadataEvent(MetadataEvent.VALUE_REMOVE,false,false,key,result));
            dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_REMOVE,false,false,result as TimelineMarker));
         }
         return result;
      }
      
      override public function getValue(key:String) : *
      {
         var i:int = 0;
         var keyTime:Number = NaN;
         if(key == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         var time:Number = new Number(key);
         if(!isNaN(time))
         {
            for(i = 0; i < this.temporalKeyCollection.length; i++)
            {
               keyTime = this.temporalKeyCollection[i];
               if(keyTime == time)
               {
                  return this.temporalValueCollection[i];
               }
            }
         }
         return null;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(value:Boolean) : void
      {
         this._enabled = value;
         this.reset(value);
      }
      
      private function startTimer(start:Boolean = true) : void
      {
         if(!start)
         {
            this.intervalTimer.stop();
         }
         else if(this.timeTrait != null && this.temporalValueCollection != null && this.temporalValueCollection.length > 0 && this.restartTimer && this.enabled && !this.intervalTimer.running)
         {
            if(this.playTrait != null && this.playTrait.playState == PlayState.PLAYING)
            {
               this.intervalTimer.start();
            }
         }
      }
      
      private function reset(startTimer:Boolean) : void
      {
         this.lastFiredTemporalMetadataIndex = -1;
         this.restartTimer = true;
         this.intervalTimer.reset();
         this.intervalTimer.delay = CHECK_INTERVAL;
         if(startTimer)
         {
            this.startTimer();
         }
      }
      
      private function checkForTemporalMetadata() : void
      {
         var now:Number = this.timeTrait.currentTime;
         var index:int = this.findTemporalMetadata(this.lastFiredTemporalMetadataIndex + 1,this.temporalValueCollection.length - 1,now);
         if(index <= 0)
         {
            index *= -1;
            index = index > 0 ? int(index - 1) : 0;
         }
         if(!this.checkTemporalMetadata(index,now) && index + 1 < this.temporalValueCollection.length)
         {
            this.checkTemporalMetadata(index + 1,now);
         }
      }
      
      private function setupTraitEventListener(traitType:String, add:Boolean = true) : void
      {
         var event:PlayEvent = null;
         if(add)
         {
            if(traitType == MediaTraitType.SEEK && this.seekTrait != null)
            {
               this.seekTrait.addEventListener(SeekEvent.SEEKING_CHANGE,this.onSeekingChange);
            }
            else if(traitType == MediaTraitType.PLAY && this.playTrait != null)
            {
               this.playTrait.addEventListener(PlayEvent.PLAY_STATE_CHANGE,this.onPlayStateChange);
               if(this.playTrait.playState == PlayState.PLAYING)
               {
                  event = new PlayEvent(PlayEvent.PLAY_STATE_CHANGE,false,false,PlayState.PLAYING);
                  this.onPlayStateChange(event);
               }
            }
         }
         else if(traitType == MediaTraitType.SEEK && this.seekTrait != null)
         {
            this.seekTrait.removeEventListener(SeekEvent.SEEKING_CHANGE,this.onSeekingChange);
         }
         else if(traitType == MediaTraitType.PLAY && this.playTrait != null)
         {
            this.playTrait.removeEventListener(PlayEvent.PLAY_STATE_CHANGE,this.onPlayStateChange);
         }
      }
      
      private function onSeekingChange(event:SeekEvent) : void
      {
         if(event.seeking)
         {
            this.reset(true);
         }
      }
      
      private function onPlayStateChange(event:PlayEvent) : void
      {
         var timer:Timer = null;
         if(event.playState == PlayState.PLAYING)
         {
            if(this.durationTimers != null)
            {
               for each(timer in this.durationTimers)
               {
                  timer.start();
               }
            }
            this.startTimer();
         }
         else
         {
            if(this.durationTimers != null)
            {
               for each(timer in this.durationTimers)
               {
                  timer.stop();
               }
            }
            this.startTimer(false);
         }
      }
      
      private function findTemporalMetadata(firstIndex:int, lastIndex:int, time:Number) : int
      {
         var mid:int = 0;
         if(firstIndex <= lastIndex)
         {
            mid = (firstIndex + lastIndex) / 2;
            if(time == this.temporalKeyCollection[mid])
            {
               return mid;
            }
            if(time < this.temporalKeyCollection[mid])
            {
               return this.findTemporalMetadata(firstIndex,mid - 1,time);
            }
            return this.findTemporalMetadata(mid + 1,lastIndex,time);
         }
         return -firstIndex;
      }
      
      private function dispatchTemporalEvents(index:int) : void
      {
         var marker:TimelineMarker = null;
         var timer:Timer = null;
         var endTime:Number = NaN;
         var onDurationTimer:Function = null;
         marker = this.temporalValueCollection[index];
         dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_TIME_REACHED,false,false,marker));
         if(marker.duration > 0)
         {
            onDurationTimer = function(event:TimerEvent):void
            {
               if(Boolean(timeTrait) && timeTrait.currentTime >= endTime)
               {
                  timer.removeEventListener(TimerEvent.TIMER,onDurationTimer);
                  delete durationTimers[marker];
                  dispatchEvent(new TimelineMetadataEvent(TimelineMetadataEvent.MARKER_DURATION_REACHED,false,false,marker));
               }
            };
            timer = new Timer(CHECK_INTERVAL);
            endTime = marker.time + marker.duration;
            if(this.durationTimers == null)
            {
               this.durationTimers = new Dictionary();
            }
            this.durationTimers[marker] = timer;
            timer.addEventListener(TimerEvent.TIMER,onDurationTimer);
            timer.start();
         }
      }
      
      private function checkTemporalMetadata(index:int, now:Number) : Boolean
      {
         var thisTime:Number = NaN;
         var nextTime:Number = NaN;
         var newDelay:Number = NaN;
         if(!this.temporalValueCollection || !this.temporalValueCollection.length)
         {
            return false;
         }
         var result:Boolean = false;
         if(this.temporalValueCollection[index].time >= now - TOLERANCE && this.temporalValueCollection[index].time <= now + TOLERANCE && index != this.lastFiredTemporalMetadataIndex)
         {
            this.lastFiredTemporalMetadataIndex = index;
            this.dispatchTemporalEvents(index);
            thisTime = this.temporalKeyCollection[index];
            nextTime = this.calcNextTime(index);
            newDelay = (nextTime - thisTime) * 1000 / 4;
            newDelay = newDelay > CHECK_INTERVAL ? newDelay : CHECK_INTERVAL;
            if(thisTime == nextTime)
            {
               this.startTimer(false);
               this.restartTimer = false;
            }
            else if(newDelay != this.intervalTimer.delay)
            {
               this.intervalTimer.reset();
               this.intervalTimer.delay = newDelay;
               this.startTimer();
            }
            result = true;
         }
         else if(this.intervalTimer.delay != CHECK_INTERVAL && now + this.intervalTimer.delay / 1000 > this.calcNextTime(index))
         {
            this.intervalTimer.reset();
            this.intervalTimer.delay = CHECK_INTERVAL;
            this.startTimer();
         }
         return result;
      }
      
      private function calcNextTime(index:int) : Number
      {
         return this.temporalValueCollection[index + 1 < this.temporalKeyCollection.length ? index + 1 : this.temporalKeyCollection.length - 1].time;
      }
      
      private function onIntervalTimer(event:TimerEvent) : void
      {
         this.checkForTemporalMetadata();
      }
      
      private function onTraitAdd(event:MediaElementEvent) : void
      {
         switch(event.traitType)
         {
            case MediaTraitType.TIME:
               this.timeTrait = this.media.getTrait(MediaTraitType.TIME) as TimeTrait;
               this.startTimer();
               break;
            case MediaTraitType.SEEK:
               this.seekTrait = this.media.getTrait(MediaTraitType.SEEK) as SeekTrait;
               break;
            case MediaTraitType.PLAY:
               this.playTrait = this.media.getTrait(MediaTraitType.PLAY) as PlayTrait;
         }
         this.setupTraitEventListener(event.traitType);
      }
      
      private function onTraitRemove(event:MediaElementEvent) : void
      {
         this.setupTraitEventListener(event.traitType,false);
         switch(event.traitType)
         {
            case MediaTraitType.TIME:
               this.timeTrait = null;
               if(this.media.hasOwnProperty("numChildren") == false)
               {
                  this.startTimer(false);
               }
               break;
            case MediaTraitType.SEEK:
               this.seekTrait = null;
               break;
            case MediaTraitType.PLAY:
               this.playTrait = null;
         }
      }
   }
}

