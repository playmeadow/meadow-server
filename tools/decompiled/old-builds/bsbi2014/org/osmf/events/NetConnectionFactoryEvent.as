package org.osmf.events
{
   import flash.events.Event;
   import flash.net.NetConnection;
   import org.osmf.media.URLResource;
   
   public class NetConnectionFactoryEvent extends Event
   {
      
      public static const CREATION_COMPLETE:String = "creationComplete";
      
      public static const CREATION_ERROR:String = "creationError";
      
      private var _netConnection:NetConnection;
      
      private var _resource:URLResource;
      
      private var _mediaError:MediaError;
      
      public function NetConnectionFactoryEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, netConnection:NetConnection = null, resource:URLResource = null, mediaError:MediaError = null)
      {
         super(type,bubbles,cancelable);
         this._netConnection = netConnection;
         this._resource = resource;
         this._mediaError = mediaError;
      }
      
      public function get netConnection() : NetConnection
      {
         return this._netConnection;
      }
      
      public function get resource() : URLResource
      {
         return this._resource;
      }
      
      public function get mediaError() : MediaError
      {
         return this._mediaError;
      }
      
      override public function clone() : Event
      {
         return new NetConnectionFactoryEvent(type,bubbles,cancelable,this._netConnection,this._resource,this._mediaError);
      }
   }
}

