package org.osmf.traits
{
   import org.osmf.events.BufferEvent;
   
   [Event(name="bufferTimeChange",type="org.osmf.events.BufferEvent")]
   [Event(name="bufferingChange",type="org.osmf.events.BufferEvent")]
   public class BufferTrait extends MediaTraitBase
   {
      
      private var _buffering:Boolean = false;
      
      private var _bufferLength:Number = 0;
      
      private var _bufferTime:Number = 0;
      
      public function BufferTrait()
      {
         super(MediaTraitType.BUFFER);
      }
      
      public function get buffering() : Boolean
      {
         return this._buffering;
      }
      
      public function get bufferLength() : Number
      {
         return this._bufferLength;
      }
      
      public function get bufferTime() : Number
      {
         return this._bufferTime;
      }
      
      public function set bufferTime(value:Number) : void
      {
         if(isNaN(value) || value < 0)
         {
            value = 0;
         }
         if(value != this._bufferTime)
         {
            this.bufferTimeChangeStart(value);
            this._bufferTime = value;
            this.bufferTimeChangeEnd();
         }
      }
      
      final protected function setBufferLength(value:Number) : void
      {
         if(value != this._bufferLength)
         {
            this.bufferLengthChangeStart(value);
            this._bufferLength = value;
            this.bufferLengthChangeEnd();
         }
      }
      
      final protected function setBuffering(value:Boolean) : void
      {
         if(value != this._buffering)
         {
            this.bufferingChangeStart(value);
            this._buffering = value;
            this.bufferingChangeEnd();
         }
      }
      
      protected function bufferingChangeStart(newBuffering:Boolean) : void
      {
      }
      
      protected function bufferingChangeEnd() : void
      {
         dispatchEvent(new BufferEvent(BufferEvent.BUFFERING_CHANGE,false,false,this._buffering));
      }
      
      protected function bufferLengthChangeStart(newSize:Number) : void
      {
      }
      
      protected function bufferLengthChangeEnd() : void
      {
         dispatchEvent(new BufferEvent(BufferEvent.BUFFER_LENGTH_CHANGE,false,false,false,NaN,this._bufferLength));
      }
      
      protected function bufferTimeChangeStart(newTime:Number) : void
      {
      }
      
      protected function bufferTimeChangeEnd() : void
      {
         dispatchEvent(new BufferEvent(BufferEvent.BUFFER_TIME_CHANGE,false,false,false,this._bufferTime));
      }
   }
}

