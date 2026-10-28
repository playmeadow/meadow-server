package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.net.NetConnection;
   import flash.net.NetGroup;
   import flash.net.NetStream;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   
   public class MulticastNetLoader extends NetLoader
   {
      
      public function MulticastNetLoader(factory:NetConnectionFactoryBase = null)
      {
         var newFactory:NetConnectionFactory = null;
         if(factory == null)
         {
            newFactory = new NetConnectionFactory();
            newFactory.timeout = 60000;
         }
         super(factory != null ? factory : newFactory);
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var rs:MulticastResource = resource as MulticastResource;
         return rs != null && rs.groupspec != null && rs.groupspec.length > 0 && rs.streamName != null && rs.streamName.length > 0;
      }
      
      override protected function createNetStream(connection:NetConnection, resource:URLResource) : NetStream
      {
         var rs:MulticastResource = resource as MulticastResource;
         return new NetStream(connection,rs.groupspec);
      }
      
      private function doProcessCreationComplete(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null) : void
      {
         super.processCreationComplete(connection,loadTrait,factory);
      }
      
      override protected function processCreationComplete(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null) : void
      {
         var netLoadTrait:NetStreamLoadTrait = null;
         var netGroup:NetGroup = null;
         var onNetStatus:Function = null;
         onNetStatus = function(event:NetStatusEvent):void
         {
            switch(event.info.code)
            {
               case "NetGroup.Connect.Success":
                  connection.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
                  netLoadTrait.netGroup = netGroup;
                  doProcessCreationComplete(connection,loadTrait,factory);
                  break;
               case "NetGroup.Connect.Failed":
               case "NetGroup.Connect.Rejected":
                  connection.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
                  updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            }
         };
         netLoadTrait = loadTrait as NetStreamLoadTrait;
         var multicastResource:MulticastResource = netLoadTrait.resource as MulticastResource;
         connection.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
         netGroup = new NetGroup(connection,multicastResource.groupspec);
      }
   }
}

