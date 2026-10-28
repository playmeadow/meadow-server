package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.DynamicStreamEvent;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="autoSwitchChange",type="org.osmf.events.DynamicStreamEvent")]
   [Event(name="numDynamicStreamsChange",type="org.osmf.events.DynamicStreamEvent")]
   [Event(name="switchingChange",type="org.osmf.events.DynamicStreamEvent")]
   public class DynamicStreamTrait extends MediaTraitBase
   {
      
      private var _autoSwitch:Boolean;
      
      private var _currentIndex:int = 0;
      
      private var _maxAllowedIndex:int = 0;
      
      private var _numDynamicStreams:int;
      
      private var _switching:Boolean;
      
      public function DynamicStreamTrait(autoSwitch:Boolean = true, currentIndex:int = 0, numDynamicStreams:int = 1)
      {
         super(MediaTraitType.DYNAMIC_STREAM);
         this._autoSwitch = autoSwitch;
         this._currentIndex = currentIndex;
         this._numDynamicStreams = numDynamicStreams;
         this._maxAllowedIndex = numDynamicStreams - 1;
         this._switching = false;
      }
      
      public function get autoSwitch() : Boolean
      {
         return this._autoSwitch;
      }
      
      final public function set autoSwitch(value:Boolean) : void
      {
         if(this.autoSwitch != value)
         {
            this.autoSwitchChangeStart(value);
            this._autoSwitch = value;
            this.autoSwitchChangeEnd();
         }
      }
      
      public function get numDynamicStreams() : int
      {
         return this._numDynamicStreams;
      }
      
      public function get currentIndex() : int
      {
         return this._currentIndex;
      }
      
      public function get maxAllowedIndex() : int
      {
         return this._maxAllowedIndex;
      }
      
      final public function set maxAllowedIndex(value:int) : void
      {
         if(value < 0 || value > this._numDynamicStreams - 1)
         {
            throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
         }
         if(this.maxAllowedIndex != value)
         {
            this.maxAllowedIndexChangeStart(value);
            this._maxAllowedIndex = value;
            this.maxAllowedIndexChangeEnd();
         }
      }
      
      public function getBitrateForIndex(index:int) : Number
      {
         if(index > this._numDynamicStreams - 1 || index < 0)
         {
            throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
         }
         return 0;
      }
      
      public function get switching() : Boolean
      {
         return this._switching;
      }
      
      public function switchTo(index:int) : void
      {
         if(this.autoSwitch)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_STREAM_NOT_IN_MANUAL_MODE));
         }
         if(index != this.currentIndex)
         {
            if(index < 0 || index > this.maxAllowedIndex)
            {
               throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
            }
            this.setSwitching(true,index);
         }
      }
      
      final protected function setNumDynamicStreams(value:int) : void
      {
         if(value != this._numDynamicStreams)
         {
            this._numDynamicStreams = value;
            if(this.maxAllowedIndex >= this._numDynamicStreams)
            {
               this.maxAllowedIndex = Math.max(0,this._numDynamicStreams - 1);
            }
            dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.NUM_DYNAMIC_STREAMS_CHANGE));
         }
      }
      
      final protected function setCurrentIndex(value:int) : void
      {
         this._currentIndex = value;
      }
      
      final protected function setSwitching(newSwitching:Boolean, index:int) : void
      {
         if(newSwitching != this._switching)
         {
            this.switchingChangeStart(newSwitching,index);
            this._switching = newSwitching;
            if(newSwitching == false)
            {
               this.setCurrentIndex(index);
            }
            this.switchingChangeEnd(index);
         }
      }
      
      protected function autoSwitchChangeStart(value:Boolean) : void
      {
      }
      
      protected function autoSwitchChangeEnd() : void
      {
         dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.AUTO_SWITCH_CHANGE,false,false,false,this._autoSwitch));
      }
      
      protected function switchingChangeStart(newSwitching:Boolean, index:int) : void
      {
      }
      
      protected function switchingChangeEnd(index:int) : void
      {
         dispatchEvent(new DynamicStreamEvent(DynamicStreamEvent.SWITCHING_CHANGE,false,false,this.switching));
      }
      
      protected function maxAllowedIndexChangeStart(newIndex:int) : void
      {
      }
      
      protected function maxAllowedIndexChangeEnd() : void
      {
      }
   }
}

