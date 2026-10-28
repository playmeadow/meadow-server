package org.osmf.events
{
   import flash.events.Event;
   
   public class MetadataEvent extends Event
   {
      
      public static const VALUE_ADD:String = "valueAdd";
      
      public static const VALUE_REMOVE:String = "valueRemove";
      
      public static const VALUE_CHANGE:String = "valueChange";
      
      private var _key:String;
      
      private var _value:*;
      
      private var _oldValue:*;
      
      public function MetadataEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, key:String = null, value:* = null, oldValue:* = null)
      {
         super(type,bubbles,cancelable);
         this._key = key;
         this._value = value;
         this._oldValue = oldValue;
      }
      
      public function get key() : String
      {
         return this._key;
      }
      
      public function get value() : *
      {
         return this._value;
      }
      
      public function get oldValue() : *
      {
         return this._oldValue;
      }
      
      override public function clone() : Event
      {
         return new MetadataEvent(type,bubbles,cancelable,this._key,this._value,this._oldValue);
      }
   }
}

