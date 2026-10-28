package org.osmf.net
{
   import flash.media.SoundTransform;
   import flash.net.NetStream;
   import org.osmf.traits.AudioTrait;
   
   [ExcludeClass]
   public class NetStreamAudioTrait extends AudioTrait
   {
      
      private var netStream:NetStream;
      
      public function NetStreamAudioTrait(netStream:NetStream)
      {
         super();
         this.netStream = netStream;
      }
      
      override protected function volumeChangeStart(newVolume:Number) : void
      {
         var soundTransform:SoundTransform = this.netStream.soundTransform;
         soundTransform.volume = muted ? 0 : newVolume;
         this.netStream.soundTransform = soundTransform;
      }
      
      override protected function mutedChangeStart(newMuted:Boolean) : void
      {
         var soundTransform:SoundTransform = this.netStream.soundTransform;
         soundTransform.volume = newMuted ? 0 : volume;
         this.netStream.soundTransform = soundTransform;
      }
      
      override protected function panChangeStart(newPan:Number) : void
      {
         var soundTransform:SoundTransform = this.netStream.soundTransform;
         soundTransform.pan = newPan;
         this.netStream.soundTransform = soundTransform;
      }
   }
}

