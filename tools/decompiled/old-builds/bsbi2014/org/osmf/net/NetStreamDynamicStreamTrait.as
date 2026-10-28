package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetStream;
   import org.osmf.traits.DynamicStreamTrait;
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   public class NetStreamDynamicStreamTrait extends DynamicStreamTrait
   {
      
      private var netStream:NetStream;
      
      private var switchManager:NetStreamSwitchManagerBase;
      
      private var inSetSwitching:Boolean;
      
      private var dsResource:DynamicStreamingResource;
      
      private var indexToSwitchTo:int;
      
      public function NetStreamDynamicStreamTrait(netStream:NetStream, switchManager:NetStreamSwitchManagerBase, dsResource:DynamicStreamingResource)
      {
         super(switchManager.autoSwitch,switchManager.currentIndex,dsResource.streamItems.length);
         this.netStream = netStream;
         this.switchManager = switchManager;
         this.dsResource = dsResource;
         netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
         NetClient(netStream.client).addHandler(NetStreamCodes.ON_PLAY_STATUS,this.onPlayStatus);
      }
      
      override public function dispose() : void
      {
         this.netStream = null;
         this.switchManager = null;
      }
      
      override public function getBitrateForIndex(index:int) : Number
      {
         if(index > numDynamicStreams - 1 || index < 0)
         {
            throw new RangeError(OSMFStrings.getString(OSMFStrings.STREAMSWITCH_INVALID_INDEX));
         }
         return this.dsResource.streamItems[index].bitrate;
      }
      
      override protected function switchingChangeStart(newSwitching:Boolean, index:int) : void
      {
         if(newSwitching && !this.inSetSwitching)
         {
            this.indexToSwitchTo = index;
         }
      }
      
      override protected function switchingChangeEnd(index:int) : void
      {
         super.switchingChangeEnd(index);
         if(switching && !this.inSetSwitching)
         {
            this.switchManager.switchTo(this.indexToSwitchTo);
         }
      }
      
      override protected function autoSwitchChangeStart(value:Boolean) : void
      {
         this.switchManager.autoSwitch = value;
      }
      
      override protected function maxAllowedIndexChangeStart(value:int) : void
      {
         this.switchManager.maxAllowedIndex = value;
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         switch(event.info.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_TRANSITION:
               this.inSetSwitching = true;
               setSwitching(true,this.dsResource.indexFromName(event.info.details));
               this.inSetSwitching = false;
               break;
            case NetStreamCodes.NETSTREAM_PLAY_FAILED:
               setSwitching(false,currentIndex);
         }
      }
      
      private function onPlayStatus(event:Object) : void
      {
         switch(event.code)
         {
            case NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE:
               setSwitching(false,this.switchManager.currentIndex);
         }
      }
   }
}

