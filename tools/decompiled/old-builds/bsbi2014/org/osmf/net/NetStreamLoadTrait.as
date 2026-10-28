package org.osmf.net
{
   import flash.errors.IllegalOperationError;
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import flash.net.NetGroup;
   import flash.net.NetStream;
   import flash.utils.Dictionary;
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   public class NetStreamLoadTrait extends LoadTrait
   {
      
      private var _connection:NetConnection;
      
      private var _switchManager:NetStreamSwitchManagerBase;
      
      private var traits:Dictionary = new Dictionary();
      
      private var _netConnectionFactory:NetConnectionFactoryBase;
      
      private var isStreamingResource:Boolean;
      
      private var _netStream:NetStream;
      
      private var _netGroup:NetGroup;
      
      public function NetStreamLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
         this.isStreamingResource = NetStreamUtils.isStreamingResource(resource);
      }
      
      public function get connection() : NetConnection
      {
         return this._connection;
      }
      
      public function set connection(value:NetConnection) : void
      {
         this._connection = value;
      }
      
      public function get netStream() : NetStream
      {
         return this._netStream;
      }
      
      public function set netStream(value:NetStream) : void
      {
         this._netStream = value;
      }
      
      public function get switchManager() : NetStreamSwitchManagerBase
      {
         return this._switchManager;
      }
      
      public function set switchManager(value:NetStreamSwitchManagerBase) : void
      {
         this._switchManager = value;
      }
      
      public function setTrait(trait:MediaTraitBase) : void
      {
         if(trait == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.traits[trait.traitType] = trait;
      }
      
      public function getTrait(traitType:String) : MediaTraitBase
      {
         return this.traits[traitType];
      }
      
      public function get netConnectionFactory() : NetConnectionFactoryBase
      {
         return this._netConnectionFactory;
      }
      
      public function set netConnectionFactory(value:NetConnectionFactoryBase) : void
      {
         this._netConnectionFactory = value;
      }
      
      override protected function loadStateChangeStart(newState:String) : void
      {
         if(newState == LoadState.READY)
         {
            if(!this.isStreamingResource && (this.netStream.bytesTotal <= 0 || this.netStream.bytesTotal == uint.MAX_VALUE))
            {
               this.netStream.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
            }
         }
         else if(newState == LoadState.UNINITIALIZED)
         {
            this.netStream = null;
            dispatchEvent(new LoadEvent(LoadEvent.BYTES_LOADED_CHANGE,false,false,null,this.bytesLoaded));
            dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE,false,false,null,this.bytesTotal));
         }
      }
      
      override public function get bytesLoaded() : Number
      {
         return this.isStreamingResource ? NaN : (this.netStream != null ? this.netStream.bytesLoaded : NaN);
      }
      
      override public function get bytesTotal() : Number
      {
         return this.isStreamingResource ? NaN : (this.netStream != null ? this.netStream.bytesTotal : NaN);
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         if(this.netStream != null && this.netStream.bytesTotal > 0)
         {
            dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE,false,false,null,this.netStream.bytesTotal));
            this.netStream.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
         }
      }
      
      public function get netGroup() : NetGroup
      {
         return this._netGroup;
      }
      
      public function set netGroup(value:NetGroup) : void
      {
         this._netGroup = value;
      }
   }
}

