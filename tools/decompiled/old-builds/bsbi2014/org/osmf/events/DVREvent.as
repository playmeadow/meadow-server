package org.osmf.events
{
   import flash.events.Event;
   
   public class DVREvent extends Event
   {
      
      public static const IS_RECORDING_CHANGE:String = "isRecordingChange";
      
      public function DVREvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
      
      override public function clone() : Event
      {
         return new DVREvent(type,bubbles,cancelable);
      }
   }
}

