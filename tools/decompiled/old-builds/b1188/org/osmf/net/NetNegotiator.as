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
      
      public function NetNegotiator(param1:Number, param2:Number = 10000)
      {
         super();
         this.connectionAttemptInterval = param1;
         this._timeout = param2;
      }
      
      public function get timeout() : Number
      {
         return this._timeout;
      }
      
      public function set timeout(param1:Number) : void
      {
         this._timeout = param1;
      }
      
      public function createNetConnection(param1:URLResource, param2:Vector.<String>, param3:Vector.<NetConnection>) : void
      {
         this.resource = param1;
         this.netConnectionURLs = param2;
         this.netConnections = param3;
         var _loc4_:StreamingURLResource = param1 as StreamingURLResource;
         if(_loc4_ != null && _loc4_.connectionArguments != null && _loc4_.connectionArguments.length > 0)
         {
            this.netConnectionArguments = _loc4_.connectionArguments;
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
      
      private function tryToConnect(param1:TimerEvent) : void
      {
         var rs:MulticastResource = null;
         var host:String = null;
         var args:Array = null;
         var arg:Object = null;
         var evt:TimerEvent = param1;
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
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         var index:int = 0;
         var tempTimer:Timer = null;
         var onTempTimer:Function = null;
         var event:NetStatusEvent = param1;
         switch(event.info.code)
         {
            case NetConnectionCodes.CONNECT_INVALIDAPP:
               this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.NETCONNECTION_APPLICATION_INVALID,event.info.description),NetConnection(event.target).uri);
               break;
            case NetConnectionCodes.CONNECT_REJECTED:
               if(event.info.hasOwnProperty("ex") && event.info.ex.code == 302)
               {
                  onTempTimer = function(param1:TimerEvent):void
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
         var _loc2_:NetConnection = null;
         this.timeOutTimer.stop();
         this.connectionTimer.stop();
         var _loc1_:int = 0;
         while(_loc1_ < this.netConnections.length)
         {
            _loc2_ = this.netConnections[_loc1_];
            if(!_loc2_.connected)
            {
               _loc2_.removeEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
               _loc2_.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onNetSecurityError);
               _loc2_.removeEventListener(AsyncErrorEvent.ASYNC_ERROR,this.onAsyncError);
               _loc2_.close();
               delete this.netConnections[_loc1_];
            }
            _loc1_++;
         }
      }
      
      private function handleFailedConnectionSession(param1:MediaError, param2:String) : void
      {
         this.shutDownUnsuccessfulConnections();
         dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_ERROR,false,false,null,this.resource,param1));
      }
      
      private function onNetSecurityError(param1:SecurityErrorEvent) : void
      {
         this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.SECURITY_ERROR,param1.text),NetConnection(param1.target).uri);
      }
      
      private function onAsyncError(param1:AsyncErrorEvent) : void
      {
         this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.ASYNC_ERROR,param1.text),NetConnection(param1.target).uri);
      }
      
      private function masterTimeout(param1:TimerEvent) : void
      {
         this.handleFailedConnectionSession(new MediaError(MediaErrorCodes.NETCONNECTION_TIMEOUT,"" + this._timeout),"");
      }
   }
}

