package org.osmf.net
{
   import flash.net.NetConnection;
   import flash.utils.Dictionary;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.URLResource;
   import org.osmf.utils.URL;
   
   public class NetConnectionFactory extends NetConnectionFactoryBase
   {
      
      private static const DEFAULT_TIMEOUT:Number = 10000;
      
      private static const DEFAULT_PORTS:String = "1935,443,80";
      
      private static const DEFAULT_PROTOCOLS_FOR_RTMP:String = "rtmp,rtmpt,rtmps";
      
      private static const DEFAULT_PROTOCOLS_FOR_RTMPE:String = "rtmpe,rtmpte";
      
      private static const DEFAULT_CONNECTION_ATTEMPT_INTERVAL:Number = 200;
      
      private static const PROTOCOL_RTMP:String = "rtmp";
      
      private static const PROTOCOL_RTMPS:String = "rtmps";
      
      private static const PROTOCOL_RTMPT:String = "rtmpt";
      
      private static const PROTOCOL_RTMPE:String = "rtmpe";
      
      private static const PROTOCOL_RTMPTE:String = "rtmpte";
      
      private static const PROTOCOL_HTTP:String = "http";
      
      private static const PROTOCOL_HTTPS:String = "https";
      
      private static const PROTOCOL_FILE:String = "file";
      
      private static const PROTOCOL_EMPTY:String = "";
      
      private static const MP3_EXTENSION:String = ".mp3";
      
      private var shareNetConnections:Boolean;
      
      private var negotiator:NetNegotiator;
      
      private var connectionDictionary:Dictionary;
      
      private var keyDictionary:Dictionary;
      
      private var pendingDictionary:Dictionary;
      
      private var _connectionAttemptInterval:Number = 200;
      
      private var _timeout:Number = 10000;
      
      public function NetConnectionFactory(shareNetConnections:Boolean = true)
      {
         super();
         this.shareNetConnections = shareNetConnections;
      }
      
      public function get timeout() : Number
      {
         return this._timeout;
      }
      
      public function set timeout(value:Number) : void
      {
         this._timeout = value;
      }
      
      public function get connectionAttemptInterval() : Number
      {
         return this._connectionAttemptInterval;
      }
      
      public function set connectionAttemptInterval(value:Number) : void
      {
         this._connectionAttemptInterval = value;
      }
      
      override public function create(resource:URLResource) : void
      {
         var sharedConnection:SharedConnection;
         var connectionsUnderway:Vector.<URLResource>;
         var key:String = null;
         var pendingConnections:Vector.<URLResource> = null;
         var urlIncludesFMSApplicationInstance:Boolean = false;
         var netConnectionURLs:Vector.<String> = null;
         var netConnections:Vector.<NetConnection> = null;
         var j:int = 0;
         var negotiator:NetNegotiator = null;
         var onConnected:Function = null;
         var onConnectionFailed:Function = null;
         key = this.createNetConnectionKey(resource);
         if(this.connectionDictionary == null)
         {
            this.connectionDictionary = new Dictionary();
            this.keyDictionary = new Dictionary();
            this.pendingDictionary = new Dictionary();
         }
         sharedConnection = this.connectionDictionary[key] as SharedConnection;
         connectionsUnderway = this.pendingDictionary[key] as Vector.<URLResource>;
         if(sharedConnection != null && this.shareNetConnections)
         {
            ++sharedConnection.count;
            dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_COMPLETE,false,false,sharedConnection.netConnection,resource));
         }
         else if(connectionsUnderway != null)
         {
            connectionsUnderway.push(resource);
         }
         else
         {
            onConnected = function(event:NetConnectionFactoryEvent):void
            {
               var pendingEvent:NetConnectionFactoryEvent = null;
               var pendingResource:URLResource = null;
               var alreadyShared:SharedConnection = null;
               var obj:SharedConnection = null;
               negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,onConnected);
               negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_ERROR,onConnectionFailed);
               var pendingEvents:Vector.<NetConnectionFactoryEvent> = new Vector.<NetConnectionFactoryEvent>();
               var pendingConnections:Vector.<URLResource> = pendingDictionary[key];
               for(var i:Number = 0; i < pendingConnections.length; i++)
               {
                  pendingResource = pendingConnections[i] as URLResource;
                  if(shareNetConnections)
                  {
                     alreadyShared = connectionDictionary[key] as SharedConnection;
                     if(alreadyShared != null)
                     {
                        ++alreadyShared.count;
                     }
                     else
                     {
                        obj = new SharedConnection();
                        obj.count = 1;
                        obj.netConnection = event.netConnection;
                        connectionDictionary[key] = obj;
                        keyDictionary[obj.netConnection] = key;
                     }
                  }
                  pendingEvents.push(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_COMPLETE,false,false,event.netConnection,pendingResource));
               }
               delete pendingDictionary[key];
               for each(pendingEvent in pendingEvents)
               {
                  dispatchEvent(pendingEvent);
               }
            };
            onConnectionFailed = function(event:NetConnectionFactoryEvent):void
            {
               var pendingResource:URLResource = null;
               negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,onConnected);
               negotiator.removeEventListener(NetConnectionFactoryEvent.CREATION_ERROR,onConnectionFailed);
               var pendingConnections:Vector.<URLResource> = pendingDictionary[key];
               for each(pendingResource in pendingConnections)
               {
                  dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_ERROR,false,false,null,pendingResource,event.mediaError));
               }
               delete pendingDictionary[key];
            };
            pendingConnections = new Vector.<URLResource>();
            pendingConnections.push(resource);
            this.pendingDictionary[key] = pendingConnections;
            urlIncludesFMSApplicationInstance = resource is StreamingURLResource ? StreamingURLResource(resource).urlIncludesFMSApplicationInstance : false;
            netConnectionURLs = this.createNetConnectionURLs(resource.url,urlIncludesFMSApplicationInstance);
            netConnections = new Vector.<NetConnection>();
            for(j = 0; j < netConnectionURLs.length; j++)
            {
               netConnections.push(this.createNetConnection());
            }
            negotiator = new NetNegotiator(this._connectionAttemptInterval,this._timeout);
            negotiator.addEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,onConnected);
            negotiator.addEventListener(NetConnectionFactoryEvent.CREATION_ERROR,onConnectionFailed);
            negotiator.createNetConnection(resource,netConnectionURLs,netConnections);
         }
      }
      
      override public function closeNetConnection(netConnection:NetConnection) : void
      {
         var key:String = null;
         var obj:SharedConnection = null;
         if(this.shareNetConnections)
         {
            key = this.keyDictionary[netConnection] as String;
            if(key != null)
            {
               obj = this.connectionDictionary[key] as SharedConnection;
               --obj.count;
               if(obj.count == 0)
               {
                  netConnection.close();
                  delete this.connectionDictionary[key];
                  delete this.keyDictionary[netConnection];
               }
            }
         }
         else
         {
            super.closeNetConnection(netConnection);
         }
      }
      
      protected function createNetConnectionKey(resource:URLResource) : String
      {
         var fmsURL:FMSURL = new FMSURL(resource.url);
         return fmsURL.protocol + fmsURL.host + fmsURL.port + fmsURL.appName + fmsURL.instanceName;
      }
      
      protected function createNetConnection() : NetConnection
      {
         return new NetConnection();
      }
      
      protected function createNetConnectionURLs(url:String, urlIncludesFMSApplicationInstance:Boolean = false) : Vector.<String>
      {
         var portProtocol:PortProtocol = null;
         var urls:Vector.<String> = new Vector.<String>();
         var portProtocols:Vector.<PortProtocol> = this.buildPortProtocolSequence(url);
         for each(portProtocol in portProtocols)
         {
            urls.push(this.buildConnectionAddress(url,urlIncludesFMSApplicationInstance,portProtocol));
         }
         return urls;
      }
      
      private function buildPortProtocolSequence(url:String) : Vector.<PortProtocol>
      {
         var j:int = 0;
         var attempt:PortProtocol = null;
         var portProtocols:Vector.<PortProtocol> = new Vector.<PortProtocol>();
         var theURL:URL = new URL(url);
         var allowedPorts:String = theURL.port == "" ? DEFAULT_PORTS : theURL.port;
         var allowedProtocols:String = "";
         switch(theURL.protocol)
         {
            case PROTOCOL_RTMP:
               allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMP;
               break;
            case PROTOCOL_RTMPE:
               allowedProtocols = DEFAULT_PROTOCOLS_FOR_RTMPE;
               break;
            case PROTOCOL_RTMPS:
            case PROTOCOL_RTMPT:
            case PROTOCOL_RTMPTE:
               allowedProtocols = theURL.protocol;
         }
         var portArray:Array = allowedPorts.split(",");
         var protocolArray:Array = allowedProtocols.split(",");
         for(var i:int = 0; i < protocolArray.length; i++)
         {
            for(j = 0; j < portArray.length; j++)
            {
               attempt = new PortProtocol();
               attempt.protocol = protocolArray[i];
               attempt.port = portArray[j];
               portProtocols.push(attempt);
            }
         }
         return portProtocols;
      }
      
      private function buildConnectionAddress(url:String, urlIncludesFMSApplicationInstance:Boolean, portProtocol:PortProtocol) : String
      {
         var fmsURL:FMSURL = new FMSURL(url,urlIncludesFMSApplicationInstance);
         var addr:String = portProtocol.protocol + "://" + fmsURL.host + ":" + portProtocol.port + "/" + fmsURL.appName + (fmsURL.useInstance ? "/" + fmsURL.instanceName : "");
         if(fmsURL.query != null && fmsURL.query != "")
         {
            addr += "?" + fmsURL.query;
         }
         return addr;
      }
   }
}

import flash.net.NetConnection;

class SharedConnection
{
   
   public var count:Number;
   
   public var netConnection:NetConnection;
   
   public function SharedConnection()
   {
      super();
   }
}
