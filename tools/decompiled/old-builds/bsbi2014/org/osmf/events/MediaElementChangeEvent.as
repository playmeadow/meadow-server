package org.osmf.events
{
   import flash.events.Event;
   
   [ExcludeClass]
   public class MediaElementChangeEvent extends Event
   {
      
      public static const MEDIA_ELEMENT_CHANGE:String = "mediaElementChange";
      
      public function MediaElementChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
      
      override public function clone() : Event
      {
         return new MediaElementChangeEvent(type,bubbles,cancelable);
      }
   }
}

