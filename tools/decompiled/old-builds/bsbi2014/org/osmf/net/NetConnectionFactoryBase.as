package org.osmf.net
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.net.NetConnection;
   import org.osmf.media.URLResource;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="creationError",type="org.osmf.events.NetConnectionFactoryEvent")]
   [Event(name="creationComplete",type="org.osmf.events.NetConnectionFactoryEvent")]
   public class NetConnectionFactoryBase extends EventDispatcher
   {
      
      public function NetConnectionFactoryBase()
      {
         super();
      }
      
      public function create(resource:URLResource) : void
      {
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.FUNCTION_MUST_BE_OVERRIDDEN));
      }
      
      public function closeNetConnection(netConnection:NetConnection) : void
      {
         netConnection.close();
      }
   }
}

