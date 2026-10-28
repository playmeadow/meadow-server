package org.osmf.events
{
   import flash.events.Event;
   
   public class BufferEvent extends Event
   {
      
      public static const BUFFERING_CHANGE:String = "bufferingChange";
      
      public static const BUFFER_TIME_CHANGE:String = "bufferTimeChange";
      
      public static const BUFFER_LENGTH_CHANGE:String = "bufferLengthChange";
      
      private var _buffering:Boolean;
      
      private var _bufferTime:Number;
      
      private var _bufferLength:Number;
      
      public function BufferEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, buffering:Boolean = false, bufferTime:Number = NaN, bufferLength:Number = NaN)
      {
         super(type,bubbles,cancelable);
         this._buffering = buffering;
         this._bufferTime = bufferTime;
         this._bufferLength = bufferLength;
      }
      
      public function get buffering() : Boolean
      {
         return this._buffering;
      }
      
      public function get bufferTime() : Number
      {
         return this._bufferTime;
      }
      
      public function get bufferLength() : Number
      {
         return this._bufferLength;
      }
      
      override public function clone() : Event
      {
         return new BufferEvent(type,bubbles,cancelable,this._buffering,this._bufferTime,this._bufferLength);
      }
   }
}

