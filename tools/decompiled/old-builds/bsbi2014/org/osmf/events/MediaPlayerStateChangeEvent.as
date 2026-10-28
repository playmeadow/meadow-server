package org.osmf.events
{
   import flash.events.Event;
   
   public class MediaPlayerStateChangeEvent extends Event
   {
      
      public static const MEDIA_PLAYER_STATE_CHANGE:String = "mediaPlayerStateChange";
      
      private var _state:String;
      
      public function MediaPlayerStateChangeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, state:String = null)
      {
         super(type,bubbles,cancelable);
         this._state = state;
      }
      
      public function get state() : String
      {
         return this._state;
      }
      
      override public function clone() : Event
      {
         return new MediaPlayerStateChangeEvent(type,bubbles,cancelable,this._state);
      }
   }
}

