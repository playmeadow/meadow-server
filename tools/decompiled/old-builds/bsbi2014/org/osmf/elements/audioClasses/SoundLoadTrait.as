package org.osmf.elements.audioClasses
{
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.media.Sound;
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   [ExcludeClass]
   public class SoundLoadTrait extends LoadTrait
   {
      
      private var lastBytesTotal:Number;
      
      private var _sound:Sound;
      
      public function SoundLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
      }
      
      public function get sound() : Sound
      {
         return this._sound;
      }
      
      public function set sound(value:Sound) : void
      {
         this._sound = value;
      }
      
      override protected function loadStateChangeStart(newState:String) : void
      {
         if(newState == LoadState.READY)
         {
            if(this._sound != null)
            {
               this._sound.addEventListener(Event.OPEN,this.bytesTotalCheckingHandler,false,0,true);
               this._sound.addEventListener(ProgressEvent.PROGRESS,this.bytesTotalCheckingHandler,false,0,true);
            }
         }
         else if(newState == LoadState.UNINITIALIZED)
         {
            this._sound = null;
         }
      }
      
      override public function get bytesLoaded() : Number
      {
         return Boolean(this._sound) ? this._sound.bytesLoaded : NaN;
      }
      
      override public function get bytesTotal() : Number
      {
         return Boolean(this._sound) ? this._sound.bytesTotal : NaN;
      }
      
      private function bytesTotalCheckingHandler(_:Event) : void
      {
         var event:LoadEvent = null;
         if(this.lastBytesTotal != this._sound.bytesTotal)
         {
            event = new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE,false,false,null,this._sound.bytesTotal);
            this.lastBytesTotal = this._sound.bytesTotal;
            dispatchEvent(event);
         }
      }
   }
}

