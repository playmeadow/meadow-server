package org.osmf.net
{
   import flash.errors.IOError;
   import flash.events.AsyncErrorEvent;
   import flash.events.EventDispatcher;
   import flash.events.NetStatusEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.utils.Timer;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.MetadataNamespaces;
   
   [Event(name="creationError",type="org.osmf.events.NetConnectionFactoryEvent")]
   [Event(name="creationComplete",type="org.osmf.events.NetConnectionFactoryEvent")]
   internal class NetNegotiator extends EventDispatcher
   {
      
      private var resource:URLResource;
      
      private var netConnectionURLs:Vector.<String>;
      
      private var netConnections:Vector.<NetConnection>;
      
      private var netConnectionArguments:Vector.<Object>;
      
      private var failedConnectionCount:int;
      
      private var timeOutTimer:Timer;
      
      private var connectionTimer:Timer;
      
      private var attemptIndex:int;
      
      private var mediaError:MediaError;
      
      private var connectionAttemptInterval:Number;
      
      private var _timeout:Number;
      
      public function NetNegotiator(connectionAttemptInterval:Number, timeout:Number = 10000)
      {
         super();
         this.connectionAttemptInterval = connectionAttemptInterval;
         this._timeout = timeout;
      }
      
      public function get timeout() : Number
      {
         return this._timeout;
      }
      
      public function set timeout(value:Number) : void
      {
         this._timeout = value;
      }
      
      public function createNetConnection(resource:URLResource, netConnectionURLs:Vector.<String>, netConnections:Vector.<NetConnection>) : void
      {
         this.resource = resource;
         this.netConnectionURLs = netConnectionURLs;
         this.netConnections = netConnections;
         var streamingResource:StreamingURLResource = resource as StreamingURLResource;
         if(streamingResource != null && streamingResource.connectionArguments != null && streamingResource.connectionArguments.length > 0)
         {
            this.netConnectionArguments = streamingResource.connectionArguments;
         }
         this.initializeConnectionAttempts();
         this.tryToConnect(null);
      }
      
      private function initializeConnectionAttempts() : void
      {
         this.timeOutTimer = new Timer(this._timeout,1);
         this.timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.masterTimeout);
         this.timeOutTimer.start();
         this.connectionTimer = new Timer(this.connectionAttemptInterval);
         this.connectionTimer.addEventListener(TimerEvent.TIMER,this.tryToConnect);
         this.connectionTimer.start();
         this.failedConnectionCount = 0;
         this.attemptIndex = 0;
      }
      
      private function tryToConnect(evt:TimerEvent) : void
      {
         var rs:MulticastResource = null;
         var host:String = null;
         var args:Array = null;
         var arg:Object = null;
         this.netConnections[this.attemptIndex].addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus,false,0,true);
         this.netConnections[this.attemptIndex].addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onNetSecurityError,false,0,true);
         this.netConnections[this.attemptIndex].addEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onAsyncError,false,0,true);
         this.netConnections[this.attemptIndex].client = new NetClient();
         try
         {
            rs = this.resource as MulticastResource;
            if(rs != null && rs.groupspec != null && rs.groupspec.length > 0)
            {
               NetConnection(this.netConnections[this.attemptIndex]).connect(rs.url);
            }
            else
            {
               host = this.netConnectionURLs[this.attemptIndex];
               args = [host];
               if(this.netConnectionArguments != null)
               {
                  for each(arg in this.netConnectionArguments)
                  {
                     args.push(arg);
                  }
               }
               NetConnection(this.netConnections[this.attemptIndex]).connect.apply(this.netConnections[this.attemptIndex],args);
            }
            ++this.attemptIndex;
            if(this.attemptIndex >= this.netConnectionURLs.length)
            {
               this.connectionTimer.stop();
            }
         }
         catch(ioError:IOError)
         {
            handleFailedConnectionSession(new MediaError(MediaErrorCodes.IO_ERROR,ioError.message),netConnectionURLs[attemptIndex]);
         }
         catch(argumentError:ArgumentError)
         {
            handleFailedConnectionSession(new MediaError(MediaErrorCodes.ARGUMENT_ERROR,argumentError.message),netConnectionURLs[attemptIndex]);
         }
         catch(securityError:SecurityError)
         {
            handleFailedConnectionSession(new MediaError(MediaErrorCodes.SECURITY_ERROR,securityError.message),netConnectionURLs[attemptIndex]);
         }
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         var index:int = 0;
         var tempTimer:Timer = null;
         var onTempTimer:Function = null;
         switch(event.info.code)
         {
            case NetConnectionCodes.CONNECT_INVALIDAPP:
               this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.NETCONNECTION_APPLICATION_INVALID,event.info.description),NetConnection(event.target).uri);
               break;
            case NetConnectionCodes.CONNECT_REJECTED:
               if(event.info.hasOwnProperty("ex") && event.info.ex.code == 302)
               {
                  onTempTimer = function(event:TimerEvent):void
                  {
                     tempTimer.removeEventListener(TimerEvent.TIMER,onTempTimer);
                     tempTimer.stop();
                     tryToConnect(null);
                  };
                  index = this.netConnections.indexOf(event.target as NetConnection);
                  this.netConnectionURLs[index] = event.info.ex.redirect;
                  this.attemptIndex = index;
                  tempTimer = new Timer(100,1);
                  tempTimer.addEventListener(TimerEvent.TIMER,onTempTimer);
                  tempTimer.start();
               }
               else
               {
                  this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.NETCONNECTION_REJECTED,event.info.description),NetConnection(event.target).uri);
               }
               break;
            case NetConnectionCodes.CONNECT_FAILED:
               ++this.failedConnectionCount;
               if(this.failedConnectionCount >= this.netConnectionURLs.length)
               {
                  this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.NETCONNECTION_FAILED),NetConnection(event.target).uri);
               }
               break;
            case NetConnectionCodes.CONNECT_SUCCESS:
               if(event.info.hasOwnProperty("data") && Boolean(event.info.data.hasOwnProperty("version")))
               {
                  this.resource.addMetadataValue(MetadataNamespaces.FMS_SERVER_VERSION_METADATA,event.info.data.version);
               }
               this.shutDownUnsuccessfulConnections();
               dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_COMPLETE,false,false,event.currentTarget as NetConnection,this.resource));
               break;
            case "NetStream.Publish.Start":
         }
      }
      
      private function shutDownUnsuccessfulConnections() : void
      {
         var nc:NetConnection = null;
         this.timeOutTimer.stop();
         this.connectionTimer.stop();
         for(var i:int = 0; i < this.netConnections.length; i++)
         {
            nc = this.netConnections[i];
            if(!nc.connected)
            {
               nc.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
               nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onNetSecurityError);
               nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onAsyncError);
               nc.close();
               delete this.netConnections[i];
            }
         }
      }
      
      private function handleFailedConnectionSession(mediaError:MediaError, url:String) : void
      {
         this.shutDownUnsuccessfulConnections();
         dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_ERROR,false,false,null,this.resource,mediaError));
      }
      
      private function onNetSecurityError(event:SecurityErrorEvent) : void
      {
         this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.SECURITY_ERROR,event.text),NetConnection(event.target).uri);
      }
      
      private function onAsyncError(event:AsyncErrorEvent) : void
      {
         this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.ASYNC_ERROR,event.text),NetConnection(event.target).uri);
      }
      
      private function masterTimeout(event:TimerEvent) : void
      {
         this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.NETCONNECTION_TIMEOUT,"" + this._timeout),"");
      }
   }
}

