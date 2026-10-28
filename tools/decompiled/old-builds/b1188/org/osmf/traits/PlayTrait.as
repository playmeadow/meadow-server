package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.PlayEvent;
   import org.osmf.utils.OSMFStrings;
   
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
      
      final protected function setCanPause(param1:Boolean) : void
      {
         if(param1 != this._canPause)
         {
            this._canPause = param1;
            dispatchEvent(new PlayEvent(PlayEvent.CAN_PAUSE_CHANGE));
         }
      }
      
      protected function playStateChangeStart(param1:String) : void
      {
      }
      
      protected function playStateChangeEnd() : void
      {
         dispatchEvent(new PlayEvent(PlayEvent.PLAY_STATE_CHANGE,false,false,this.playState));
      }
      
      private function attemptPlayStateChange(param1:String) : void
      {
         if(this._playState != param1)
         {
            this.playStateChangeStart(param1);
            this._playState = param1;
            this.playStateChangeEnd();
         }
      }
   }
}

