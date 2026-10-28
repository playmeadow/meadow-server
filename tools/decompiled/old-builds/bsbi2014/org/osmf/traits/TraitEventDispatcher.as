package org.osmf.traits
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.AudioEvent;
   import org.osmf.events.BufferEvent;
   import org.osmf.events.DRMEvent;
   import org.osmf.events.DVREvent;
   import org.osmf.events.DisplayObjectEvent;
   import org.osmf.events.DynamicStreamEvent;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.PlayEvent;
   import org.osmf.events.SeekEvent;
   import org.osmf.events.TimeEvent;
   import org.osmf.media.MediaElement;
   
   [Event(name="isRecordingChange",type="org.osmf.events.DVREvent")]
   [Event(name="drmStateChange",type="org.osmf.events.DRMEvent")]
   [Event(name="loadStateChange",type="org.osmf.events.LoadEvent")]
   [Event(name="bytesTotalChange",type="org.osmf.events.LoadEvent")]
   [Event(name="bufferTimeChange",type="org.osmf.events.BufferEvent")]
   [Event(name="bufferingChange",type="org.osmf.events.BufferEvent")]
   [Event(name="autoSwitchChange",type="org.osmf.events.DynamicStreamEvent")]
   [Event(name="numDynamicStreamsChange",type="org.osmf.events.DynamicStreamEvent")]
   [Event(name="switchingChange",type="org.osmf.events.DynamicStreamEvent")]
   [Event(name="seekingChange",type="org.osmf.events.SeekEvent")]
   [Event(name="mediaSizeChange",type="org.osmf.events.DisplayObjectEvent")]
   [Event(name="displayObjectChange",type="org.osmf.events.DisplayObjectEvent")]
   [Event(name="canPauseChange",type="org.osmf.events.PlayEvent")]
   [Event(name="playStateChange",type="org.osmf.events.PlayEvent")]
   [Event(name="panChange",type="org.osmf.events.AudioEvent")]
   [Event(name="mutedChange",type="org.osmf.events.AudioEvent")]
   [Event(name="volumeChange",type="org.osmf.events.AudioEvent")]
   [Event(name="complete",type="org.osmf.events.TimeEvent")]
   [Event(name="durationChange",type="org.osmf.events.TimeEvent")]
   public class TraitEventDispatcher extends EventDispatcher
   {
      
      private static var eventMaps:Dictionary;
      
      private var _mediaElement:MediaElement;
      
      public function TraitEventDispatcher()
      {
         super();
         if(eventMaps == null)
         {
            eventMaps = new Dictionary();
            eventMaps[TimeEvent.DURATION_CHANGE] = MediaTraitType.TIME;
            eventMaps[TimeEvent.COMPLETE] = MediaTraitType.TIME;
            eventMaps[PlayEvent.PLAY_STATE_CHANGE] = MediaTraitType.PLAY;
            eventMaps[PlayEvent.CAN_PAUSE_CHANGE] = MediaTraitType.PLAY;
            eventMaps[AudioEvent.VOLUME_CHANGE] = MediaTraitType.AUDIO;
            eventMaps[AudioEvent.MUTED_CHANGE] = MediaTraitType.AUDIO;
            eventMaps[AudioEvent.PAN_CHANGE] = MediaTraitType.AUDIO;
            eventMaps[SeekEvent.SEEKING_CHANGE] = MediaTraitType.SEEK;
            eventMaps[DynamicStreamEvent.SWITCHING_CHANGE] = MediaTraitType.DYNAMIC_STREAM;
            eventMaps[DynamicStreamEvent.AUTO_SWITCH_CHANGE] = MediaTraitType.DYNAMIC_STREAM;
            eventMaps[DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE] = MediaTraitType.DYNAMIC_STREAM;
            eventMaps[DisplayObjectEvent.DISPLAY_OBJECT_CHANGE] = MediaTraitType.DISPLAY_OBJECT;
            eventMaps[DisplayObjectEvent.MEDIA_SIZE_CHANGE] = MediaTraitType.DISPLAY_OBJECT;
            eventMaps[LoadEvent.LOAD_STATE_CHANGE] = MediaTraitType.LOAD;
            eventMaps[LoadEvent.BYTES_LOADED_CHANGE] = MediaTraitType.LOAD;
            eventMaps[LoadEvent.BYTES_TOTAL_CHANGE] = MediaTraitType.LOAD;
            eventMaps[BufferEvent.BUFFERING_CHANGE] = MediaTraitType.BUFFER;
            eventMaps[BufferEvent.BUFFER_TIME_CHANGE] = MediaTraitType.BUFFER;
            eventMaps[BufferEvent.BUFFER_LENGTH_CHANGE] = MediaTraitType.BUFFER;
            eventMaps[DRMEvent.DRM_STATE_CHANGE] = MediaTraitType.DRM;
            eventMaps[DVREvent.IS_RECORDING_CHANGE] = MediaTraitType.DVR;
         }
      }
      
      public function get media() : MediaElement
      {
         return this._mediaElement;
      }
      
      public function set media(value:MediaElement) : void
      {
         var traitType:String = null;
         if(value != this._mediaElement)
         {
            if(this._mediaElement != null)
            {
               this._mediaElement.removeEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
               this._mediaElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
               for each(traitType in this._mediaElement.traitTypes)
               {
                  this.onTraitChanged(traitType,false);
               }
            }
            this._mediaElement = value;
            if(this._mediaElement != null)
            {
               this._mediaElement.addEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
               this._mediaElement.addEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
               for each(traitType in this._mediaElement.traitTypes)
               {
                  this.onTraitChanged(traitType,true);
               }
            }
         }
      }
      
      override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         var hadEventListener:Boolean = hasEventListener(type);
         super.addEventListener(type,listener,useCapture,priority,useWeakReference);
         if(Boolean(this._mediaElement) && Boolean(!hadEventListener) && eventMaps[type] != undefined)
         {
            this.changeListeners(true,eventMaps[type],type);
         }
      }
      
      override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         super.removeEventListener(type,listener,useCapture);
         if(Boolean(this._mediaElement) && Boolean(!hasEventListener(type)) && eventMaps[type] != undefined)
         {
            this.changeListeners(false,eventMaps[type],type);
         }
      }
      
      private function onTraitAdd(event:MediaElementEvent) : void
      {
         this.onTraitChanged(event.traitType,true);
      }
      
      private function onTraitRemove(event:MediaElementEvent) : void
      {
         this.onTraitChanged(event.traitType,false);
      }
      
      private function onTraitChanged(traitType:String, add:Boolean) : void
      {
         switch(traitType)
         {
            case MediaTraitType.TIME:
               this.changeListeners(add,traitType,TimeEvent.DURATION_CHANGE);
               this.changeListeners(add,traitType,TimeEvent.COMPLETE);
               break;
            case MediaTraitType.PLAY:
               this.changeListeners(add,traitType,PlayEvent.PLAY_STATE_CHANGE);
               this.changeListeners(add,traitType,PlayEvent.CAN_PAUSE_CHANGE);
               break;
            case MediaTraitType.AUDIO:
               this.changeListeners(add,traitType,AudioEvent.VOLUME_CHANGE);
               this.changeListeners(add,traitType,AudioEvent.MUTED_CHANGE);
               this.changeListeners(add,traitType,AudioEvent.PAN_CHANGE);
               break;
            case MediaTraitType.SEEK:
               this.changeListeners(add,traitType,SeekEvent.SEEKING_CHANGE);
               break;
            case MediaTraitType.DYNAMIC_STREAM:
               this.changeListeners(add,traitType,DynamicStreamEvent.SWITCHING_CHANGE);
               this.changeListeners(add,traitType,DynamicStreamEvent.AUTO_SWITCH_CHANGE);
               this.changeListeners(add,traitType,DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE);
               break;
            case MediaTraitType.DISPLAY_OBJECT:
               this.changeListeners(add,traitType,DisplayObjectEvent.DISPLAY_OBJECT_CHANGE);
               this.changeListeners(add,traitType,DisplayObjectEvent.MEDIA_SIZE_CHANGE);
               break;
            case MediaTraitType.LOAD:
               this.changeListeners(add,traitType,LoadEvent.LOAD_STATE_CHANGE);
               this.changeListeners(add,traitType,LoadEvent.BYTES_TOTAL_CHANGE);
               this.changeListeners(add,traitType,LoadEvent.BYTES_LOADED_CHANGE);
               break;
            case MediaTraitType.BUFFER:
               this.changeListeners(add,traitType,BufferEvent.BUFFERING_CHANGE);
               this.changeListeners(add,traitType,BufferEvent.BUFFER_TIME_CHANGE);
               this.changeListeners(add,traitType,BufferEvent.BUFFER_LENGTH_CHANGE);
               break;
            case MediaTraitType.DRM:
               this.changeListeners(add,traitType,DRMEvent.DRM_STATE_CHANGE);
               break;
            case MediaTraitType.DVR:
               this.changeListeners(add,traitType,DVREvent.IS_RECORDING_CHANGE);
         }
      }
      
      private function changeListeners(add:Boolean, traitType:String, event:String) : void
      {
         if(this._mediaElement.getTrait(traitType) != null)
         {
            if(add && hasEventListener(event))
            {
               this._mediaElement.getTrait(traitType).addEventListener(event,this.redispatchEvent);
            }
            else
            {
               this._mediaElement.getTrait(traitType).removeEventListener(event,this.redispatchEvent);
            }
         }
      }
      
      private function redispatchEvent(event:Event) : void
      {
         dispatchEvent(event.clone());
      }
   }
}

