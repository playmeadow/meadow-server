package org.osmf.traits
{
   import org.osmf.events.AudioEvent;
   
   [Event(name="panChange",type="org.osmf.events.AudioEvent")]
   [Event(name="mutedChange",type="org.osmf.events.AudioEvent")]
   [Event(name="volumeChange",type="org.osmf.events.AudioEvent")]
   public class AudioTrait extends MediaTraitBase
   {
      
      private var _volume:Number = 1;
      
      private var _muted:Boolean = false;
      
      private var _pan:Number = 0;
      
      public function AudioTrait()
      {
         super(MediaTraitType.AUDIO);
      }
      
      public function get volume() : Number
      {
         return this._volume;
      }
      
      final public function set volume(value:Number) : void
      {
         if(isNaN(value))
         {
            value = 0;
         }
         else if(value > 1)
         {
            value = 1;
         }
         else if(value < 0)
         {
            value = 0;
         }
         if(value != this._volume)
         {
            this.volumeChangeStart(value);
            this._volume = value;
            this.volumeChangeEnd();
         }
      }
      
      public function get muted() : Boolean
      {
         return this._muted;
      }
      
      final public function set muted(value:Boolean) : void
      {
         if(value != this._muted)
         {
            this.mutedChangeStart(value);
            this._muted = value;
            this.mutedChangeEnd();
         }
      }
      
      public function get pan() : Number
      {
         return this._pan;
      }
      
      final public function set pan(value:Number) : void
      {
         if(isNaN(value))
         {
            value = 0;
         }
         else if(value > 1)
         {
            value = 1;
         }
         else if(value < -1)
         {
            value = -1;
         }
         if(value != this._pan)
         {
            this.panChangeStart(value);
            this._pan = value;
            this.panChangeEnd();
         }
      }
      
      protected function volumeChangeStart(newVolume:Number) : void
      {
      }
      
      protected function volumeChangeEnd() : void
      {
         dispatchEvent(new AudioEvent(AudioEvent.VOLUME_CHANGE,false,false,false,this._volume));
      }
      
      protected function mutedChangeStart(newMuted:Boolean) : void
      {
      }
      
      protected function mutedChangeEnd() : void
      {
         dispatchEvent(new AudioEvent(AudioEvent.MUTED_CHANGE,false,false,this._muted));
      }
      
      protected function panChangeStart(newPan:Number) : void
      {
      }
      
      protected function panChangeEnd() : void
      {
         dispatchEvent(new AudioEvent(AudioEvent.PAN_CHANGE,false,false,false,NaN,this._pan));
      }
   }
}

