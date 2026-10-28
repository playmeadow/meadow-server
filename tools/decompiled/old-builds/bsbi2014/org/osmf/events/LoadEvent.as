package org.osmf.events
{
   import flash.events.Event;
   
   public class LoadEvent extends Event
   {
      
      public static const LOAD_STATE_CHANGE:String = "loadStateChange";
      
      public static const BYTES_LOADED_CHANGE:String = "bytesLoadedChange";
      
      public static const BYTES_TOTAL_CHANGE:String = "bytesTotalChange";
      
      private var _loadState:String;
      
      private var _bytes:Number;
      
      public function LoadEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, loadState:String = null, bytes:Number = NaN)
      {
         super(type,bubbles,cancelable);
         this._loadState = loadState;
         this._bytes = bytes;
      }
      
      override public function clone() : Event
      {
         return new LoadEvent(type,bubbles,cancelable,this.loadState,this.bytes);
      }
      
      public function get loadState() : String
      {
         return this._loadState;
      }
      
      public function get bytes() : Number
      {
         return this._bytes;
      }
   }
}

