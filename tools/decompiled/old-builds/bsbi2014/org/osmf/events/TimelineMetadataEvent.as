package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.metadata.TimelineMarker;
   
   public class TimelineMetadataEvent extends MetadataEvent
   {
      
      public static const MARKER_TIME_REACHED:String = "markerTimeReached";
      
      public static const MARKER_DURATION_REACHED:String = "markerDurationReached";
      
      public static const MARKER_ADD:String = "markerAdd";
      
      public static const MARKER_REMOVE:String = "markerRemove";
      
      private var _marker:TimelineMarker;
      
      public function TimelineMetadataEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, marker:TimelineMarker = null)
      {
         super(type,bubbles,cancelable,"" + marker.time,marker);
         this._marker = marker;
      }
      
      public function get marker() : TimelineMarker
      {
         return this._marker;
      }
      
      override public function clone() : Event
      {
         return new TimelineMetadataEvent(type,bubbles,cancelable,this._marker);
      }
   }
}

