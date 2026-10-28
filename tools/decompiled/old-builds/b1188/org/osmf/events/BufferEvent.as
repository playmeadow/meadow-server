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
      
      public function BufferEvent(param1:String, param2:Boolean = false, param3:Boolean = false, param4:Boolean = false, param5:Number = NaN, param6:Number = NaN)
      {
         super(param1,param2,param3);
         this._buffering = param4;
         this._bufferTime = param5;
         this._bufferLength = param6;
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

