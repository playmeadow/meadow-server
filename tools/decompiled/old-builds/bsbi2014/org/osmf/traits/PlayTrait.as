package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.PlayEvent;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="playStateChange",type="org.osmf.events.PlayEvent")]
   [Event(name="canPauseChange",type="org.osmf.events.PlayEvent")]
   public class PlayTrait extends MediaTraitBase
   {
      
      private var _playState:String;
      
      private var _canPause:Boolean;
      
      public function PlayTrait()
      {
         super(MediaTraitType.PLAY);
         this._canPause = true;
         this._playState = PlayState.STOPPED;
      }
      
      final public function play() : void
      {
         this.attemptPlayStateChange(PlayState.PLAYING);
      }
      
      public function get canPause() : Boolean
      {
         return this._canPause;
      }
      
      final public function pause() : void
      {
         if(this.canPause)
         {
            this.attemptPlayStateChange(PlayState.PAUSED);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.PAUSE_NOT_SUPPORTED));
      }
      
      final public function stop() : void
      {
         this.attemptPlayStateChange(PlayState.STOPPED);
      }
      
      public function get playState() : String
      {
         return this._playState;
      }
      
      final protected function setCanPause(value:Boolean) : void
      {
         if(value != this._canPause)
         {
            this._canPause = value;
            dispatchEvent(new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE));
         }
      }
      
      protected function playStateChangeStart(newPlayState:String) : void
      {
      }
      
      protected function playStateChangeEnd() : void
      {
         dispatchEvent(new PlayEvent(PlayEvent.PLAY_STATE_CHANGE,false,false,this.playState));
      }
      
      private function attemptPlayStateChange(newPlayState:String) : void
      {
         if(this._playState != newPlayState)
         {
            this.playStateChangeStart(newPlayState);
            this._playState = newPlayState;
            this.playStateChangeEnd();
         }
      }
   }
}

