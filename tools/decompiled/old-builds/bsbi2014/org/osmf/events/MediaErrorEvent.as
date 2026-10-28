package org.osmf.events
{
   import flash.events.Event;
   
   public class MediaErrorEvent extends Event
   {
      
      public static const MEDIA_ERROR:String = "mediaError";
      
      private var _error:MediaError;
      
      public function MediaErrorEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, error:MediaError = null)
      {
         super(type,bubbles,cancelable);
         this._error = error;
      }
      
      override public function clone() : Event
      {
         return new MediaErrorEvent(type,bubbles,cancelable,this.error);
      }
      
      public function get error() : MediaError
      {
         return this._error;
      }
   }
}

