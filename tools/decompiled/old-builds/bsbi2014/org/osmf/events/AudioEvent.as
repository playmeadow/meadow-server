package org.osmf.events
{
   import flash.events.Event;
   
   public class AudioEvent extends Event
   {
      
      public static const VOLUME_CHANGE:String = "volumeChange";
      
      public static const MUTED_CHANGE:String = "mutedChange";
      
      public static const PAN_CHANGE:String = "panChange";
      
      private var _muted:Boolean;
      
      private var _volume:Number;
      
      private var _pan:Number;
      
      public function AudioEvent(type:String, bubbles:Boolean, cancelable:Boolean, muted:Boolean = false, volume:Number = NaN, pan:Number = NaN)
      {
         super(type,bubbles,cancelable);
         this._muted = muted;
         this._volume = volume;
         this._pan = pan;
      }
      
      public function get muted() : Boolean
      {
         return this._muted;
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      public function get pan() : Number
      {
         return this._pan;
      }
      
      override public function clone() : Event
      {
         return new AudioEvent(type,bubbles,cancelable,this._muted,this._volume,this._pan);
      }
   }
}

