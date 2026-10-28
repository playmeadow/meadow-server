package org.osmf.traits
{
   import org.osmf.events.DVREvent;
   
   [Event(name="isRecordingChange",type="org.osmf.events.DVREvent")]
   public class DVRTrait extends MediaTraitBase
   {
      
      private var _isRecording:Boolean;
      
      public function DVRTrait(isRecording:Boolean = false)
      {
         this._isRecording = isRecording;
         super(MediaTraitType.DVR);
      }
      
      final public function get isRecording() : Boolean
      {
         return this._isRecording;
      }
      
      final protected function setIsRecording(value:Boolean) : void
      {
         if(value != this._isRecording)
         {
            this.isRecordingChangeStart(value);
            this._isRecording = value;
            this.isRecordingChangeEnd();
         }
      }
      
      protected function isRecordingChangeStart(value:Boolean) : void
      {
      }
      
      protected function isRecordingChangeEnd() : void
      {
         dispatchEvent(new DVREvent(DVREvent.IS_RECORDING_CHANGE));
      }
   }
}

