package org.osmf.events
{
   import flash.events.Event;
   
   public class PlayEvent extends Event
   {
      
      public static const CAN_PAUSE_CHANGE:String = "canPauseChange";
      
      public static const PLAY_STATE_CHANGE:String = "playStateChange";
      
      private var _playState:String;
      
      private var _canPause:Boolean;
      
      public function PlayEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, playState:String = null, canPause:Boolean = false)
      {
         super(type,bubbles,cancelable);
         this._playState = playState;
         this._canPause = canPause;
      }
      
      override public function clone() : Event
      {
         return new PlayEvent(type,bubbles,cancelable,this.playState,this.canPause);
      }
      
      public function get playState() : String
      {
         return this._playState;
      }
      
      public function get canPause() : Boolean
      {
         return this._canPause;
      }
   }
}

