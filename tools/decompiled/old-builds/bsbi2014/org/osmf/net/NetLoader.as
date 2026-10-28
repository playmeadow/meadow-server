package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.net.NetStreamPlayTransitions;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaType;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.URL;
   
   public class NetLoader extends LoaderBase
   {
      
      private static const PROTOCOL_RTMP:String = "rtmp";
      
      private static const PROTOCOL_RTMPS:String = "rtmps";
      
      private static const PROTOCOL_RTMPT:String = "rtmpt";
      
      private static const PROTOCOL_RTMPE:String = "rtmpe";
      
      private static const PROTOCOL_RTMPTE:String = "rtmpte";
      
      private static const PROTOCOL_RTMFP:String = "rtmfp";
      
      private static const PROTOCOL_HTTP:String = "http";
      
      private static const PROTOCOL_HTTPS:String = "https";
      
      private static const PROTOCOL_FILE:String = "file";
      
      private static const PROTOCOL_EMPTY:String = "";
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.VIDEO]);
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["video/x-flv","video/x-f4v","video/mp4","video/mp4v-es","video/x-m4v","video/3gpp","video/3gpp2","video/quicktime"]);
      
      private static const STREAM_RECONNECT_TIMEOUT:Number = 120000;
      
      private static const STREAM_RECONNECT_TIMER_INTERVAL:int = 1000;
      
      private var netConnectionFactory:NetConnectionFactoryBase;
      
      private var pendingLoads:Dictionary = new Dictionary();
      
      private var oldConnectionURLs:Dictionary = new Dictionary();
      
      private var _reconnectStreams:Boolean = true;
      
      private var _reconnectTimeout:Number;
      
      public function NetLoader(factory:NetConnectionFactoryBase = null)
      {
         super();
         this._reconnectTimeout = STREAM_RECONNECT_TIMEOUT;
         this.netConnectionFactory = factory || new NetConnectionFactory();
         this.netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,this.onCreationComplete);
         this.netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_ERROR,this.onCreationError);
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
         {
            return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
         }
         var res:URLResource = resource as URLResource;
         var extensionPattern:RegExp = /.flv$|.f4v$|.mov$|.mp4$|.mp4v$|.m4v$|.3gp$|.3gpp2$|.3g2$/i;
         var url:URL = res != null ? new URL(res.url) : null;
         if(url == null || url.rawUrl == null || url.rawUrl.length <= 0)
         {
            return false;
         }
         if(url.protocol == "")
         {
            return extensionPattern.test(url.path);
         }
         if(NetStreamUtils.isRTMPStream(url.rawUrl))
         {
            return true;
         }
         if(url.protocol.search(/file$|http$|https$/i) != -1)
         {
            return url.path == null || url.path.length <= 0 || url.path.indexOf(".") == -1 || extensionPattern.test(url.path);
         }
         return false;
      }
      
      protected function createNetStream(connection:NetConnection, resource:URLResource) : NetStream
      {
         var ns:NetStream = new NetStream(connection);
         var streamingResource:StreamingURLResource = resource as StreamingURLResource;
         if(streamingResource != null && streamingResource.streamType == StreamType.LIVE && ns.bufferTime == 0)
         {
            ns.bufferTime = 0.1;
         }
         return ns;
      }
      
      protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         return null;
      }
      
      protected function processFinishLoading(loadTrait:NetStreamLoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.READY);
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.LOADING);
         var url:URL = new URL((loadTrait.resource as URLResource).url);
         switch(url.protocol)
         {
            case PROTOCOL_RTMP:
            case PROTOCOL_RTMPS:
            case PROTOCOL_RTMPT:
            case PROTOCOL_RTMPE:
            case PROTOCOL_RTMPTE:
            case PROTOCOL_RTMFP:
               this.startLoadingRTMP(loadTrait);
               break;
            case PROTOCOL_HTTP:
            case PROTOCOL_HTTPS:
            case PROTOCOL_FILE:
            case PROTOCOL_EMPTY:
               this.startLoadingHTTP(loadTrait);
               break;
            default:
               updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
               loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.URL_SCHEME_INVALID)));
         }
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
         updateLoadTrait(loadTrait,LoadState.UNLOADING);
         netLoadTrait.netStream.close();
         if(netLoadTrait.netConnectionFactory != null)
         {
            netLoadTrait.netConnectionFactory.closeNetConnection(netLoadTrait.connection);
         }
         else
         {
            netLoadTrait.connection.close();
         }
         delete this.oldConnectionURLs[loadTrait.resource];
         updateLoadTrait(loadTrait,LoadState.UNINITIALIZED);
      }
      
      private function finishLoading(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null) : void
      {
         var netStream:NetStream = null;
         var netLoadTrait:NetStreamLoadTrait = loadTrait as NetStreamLoadTrait;
         if(netLoadTrait != null)
         {
            netLoadTrait.connection = connection;
            netStream = this.createNetStream(connection,netLoadTrait.resource as URLResource);
            netStream.client = new NetClient();
            netLoadTrait.netStream = netStream;
            netLoadTrait.switchManager = this.createNetStreamSwitchManager(connection,netStream,netLoadTrait.resource as DynamicStreamingResource);
            netLoadTrait.netConnectionFactory = factory;
            if(this._reconnectStreams && netLoadTrait.resource is URLResource && this.supportsStreamReconnect(netLoadTrait.resource as URLResource))
            {
               this.setupStreamReconnect(netLoadTrait);
            }
            this.processFinishLoading(loadTrait as NetStreamLoadTrait);
         }
      }
      
      private function supportsStreamReconnect(resource:URLResource) : Boolean
      {
         var fmsVersion:String = null;
         var versionParts:Array = null;
         var majorVersion:int = 0;
         var minorVersion:int = 0;
         var subMinorVersion:int = 0;
         var result:Boolean = true;
         if(NetStreamUtils.isRTMPStream(resource.url))
         {
            fmsVersion = resource.getMetadataValue(MetadataNamespaces.FMS_SERVER_VERSION_METADATA) as String;
            if(fmsVersion != null && fmsVersion.length > 0)
            {
               versionParts = fmsVersion.split(",");
               if(versionParts.length >= 3)
               {
                  majorVersion = int(versionParts[0]);
                  minorVersion = int(versionParts[1]);
                  subMinorVersion = int(versionParts[2]);
                  if(majorVersion < 3 || majorVersion == 3 && minorVersion < 5 || majorVersion == 3 && minorVersion == 5 && subMinorVersion < 3)
                  {
                     result = false;
                  }
               }
            }
         }
         else
         {
            result = false;
         }
         return result;
      }
      
      private function startLoadingRTMP(loadTrait:LoadTrait) : void
      {
         this.addPendingLoad(loadTrait);
         this.netConnectionFactory.create(loadTrait.resource as URLResource);
      }
      
      private function onCreationComplete(event:NetConnectionFactoryEvent) : void
      {
         this.processCreationComplete(event.netConnection,this.findAndRemovePendingLoad(event.resource),event.currentTarget as NetConnectionFactoryBase);
      }
      
      protected function processCreationComplete(connection:NetConnection, loadTrait:LoadTrait, factory:NetConnectionFactoryBase = null) : void
      {
         this.finishLoading(connection,loadTrait,factory);
      }
      
      private function onCreationError(event:NetConnectionFactoryEvent) : void
      {
         var loadTrait:LoadTrait = this.findAndRemovePendingLoad(event.resource);
         if(loadTrait != null)
         {
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,event.mediaError));
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
         }
      }
      
      private function startLoadingHTTP(loadTrait:LoadTrait) : void
      {
         var connection:NetConnection = new NetConnection();
         connection.client = new NetClient();
         connection.connect(null);
         this.finishLoading(connection,loadTrait);
      }
      
      private function addPendingLoad(loadTrait:LoadTrait) : void
      {
         if(this.pendingLoads[loadTrait.resource] == null)
         {
            this.pendingLoads[loadTrait.resource] = [loadTrait];
         }
         else
         {
            this.pendingLoads[loadTrait.resource].push(loadTrait);
         }
      }
      
      private function findAndRemovePendingLoad(resource:URLResource) : LoadTrait
      {
         var i:int = 0;
         var loadTrait:LoadTrait = null;
         var pendingLoadsArray:Array = this.pendingLoads[resource];
         if(pendingLoadsArray != null)
         {
            if(pendingLoadsArray.length == 1)
            {
               loadTrait = pendingLoadsArray[0] as LoadTrait;
               delete this.pendingLoads[resource];
            }
            else
            {
               for(i = 0; i < pendingLoadsArray.length; i++)
               {
                  loadTrait = pendingLoadsArray[i];
                  if(loadTrait.resource == resource)
                  {
                     pendingLoadsArray.splice(i,1);
                     break;
                  }
               }
            }
         }
         return loadTrait;
      }
      
      public function get reconnectTimeout() : Number
      {
         return this._reconnectTimeout;
      }
      
      public function set reconnectTimeout(value:Number) : void
      {
         if(value < 0)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this._reconnectTimeout = value;
      }
      
      protected function setReconnectStreams(value:Boolean) : void
      {
         this._reconnectStreams = value;
      }
      
      public function get reconnectStreams() : Boolean
      {
         return this._reconnectStreams;
      }
      
      protected function createReconnectNetConnection() : NetConnection
      {
         return new NetConnection();
      }
      
      protected function reconnect(netConnection:NetConnection, resource:URLResource) : void
      {
         var connectionURL:String = this.oldConnectionURLs[resource] as String;
         if(connectionURL != null && connectionURL.length > 0 && netConnection != null)
         {
            netConnection.connect(connectionURL);
         }
      }
      
      protected function reconnectStream(loadTrait:NetStreamLoadTrait) : void
      {
         var nsPlayOptions:NetStreamPlayOptions = new NetStreamPlayOptions();
         loadTrait.netStream.attach(loadTrait.connection);
         nsPlayOptions.transition = NetStreamPlayTransitions.RESUME;
         var resource:URLResource = loadTrait.resource as URLResource;
         var urlIncludesFMSApplicationInstance:Boolean = resource as StreamingURLResource != null ? (resource as StreamingURLResource).urlIncludesFMSApplicationInstance : false;
         var streamName:String = NetStreamUtils.getStreamNameFromURL(resource.url,urlIncludesFMSApplicationInstance);
         nsPlayOptions.streamName = streamName;
         loadTrait.netStream.play2(nsPlayOptions);
      }
      
      private function setupStreamReconnect(loadTrait:NetStreamLoadTrait) : void
      {
         var netConnection:NetConnection = null;
         var reconnectTimer:Timer = null;
         var timeoutTimer:Timer = null;
         var streamIsPaused:Boolean = false;
         var bufferIsEmpty:Boolean = false;
         var reconnectHasTimedOut:Boolean = false;
         var fmsIdleTimeoutReached:Boolean = false;
         var onNetStatus:Function = null;
         var onTimeoutTimer:Function = null;
         var onReconnectTimer:Function = null;
         var setupReconnectTimer:Function = function(add:Boolean = true):void
         {
            if(add)
            {
               reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onReconnectTimer);
            }
            else
            {
               reconnectTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onReconnectTimer);
               reconnectTimer = null;
            }
         };
         var setupTimeoutTimer:Function = function(add:Boolean = true):void
         {
            if(add)
            {
               if(_reconnectTimeout > 0)
               {
                  timeoutTimer = new Timer(_reconnectTimeout,1);
                  timeoutTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onTimeoutTimer);
               }
            }
            else if(timeoutTimer != null)
            {
               timeoutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onTimeoutTimer);
               timeoutTimer = null;
            }
         };
         var setupNetConnectionListeners:Function = function(add:Boolean = true):void
         {
            if(add)
            {
               netConnection.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
            }
            else
            {
               netConnection.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
            }
         };
         var setupNetStreamListeners:Function = function(add:Boolean = true):void
         {
            if(loadTrait.netStream != null)
            {
               if(add)
               {
                  loadTrait.netStream.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
               }
               else
               {
                  loadTrait.netStream.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
               }
            }
         };
         onNetStatus = function(event:NetStatusEvent):void
         {
            var oldConnection:NetConnection = null;
            switch(event.info.code)
            {
               case NetConnectionCodes.CONNECT_SUCCESS:
                  oldConnection = loadTrait.connection;
                  loadTrait.connection = netConnection;
                  oldConnectionURLs[loadTrait.resource] = netConnection.uri;
                  if(timeoutTimer != null)
                  {
                     timeoutTimer.stop();
                  }
                  reconnectStream(loadTrait);
                  if(loadTrait.netConnectionFactory != null)
                  {
                     loadTrait.netConnectionFactory.closeNetConnection(oldConnection);
                  }
                  else
                  {
                     oldConnection.close();
                  }
                  break;
               case NetConnectionCodes.CONNECT_IDLE_TIME_OUT:
                  fmsIdleTimeoutReached = true;
                  break;
               case NetConnectionCodes.CONNECT_CLOSED:
               case NetConnectionCodes.CONNECT_FAILED:
                  if(loadTrait.loadState == LoadState.READY && !reconnectHasTimedOut && !fmsIdleTimeoutReached)
                  {
                     reconnectTimer.start();
                     if(bufferIsEmpty || loadTrait.netStream.bufferLength == 0 || streamIsPaused)
                     {
                        if(timeoutTimer != null)
                        {
                           timeoutTimer.start();
                        }
                        else
                        {
                           reconnectHasTimedOut = true;
                           setupReconnectTimer(false);
                           setupNetConnectionListeners(false);
                           setupNetStreamListeners(false);
                           setupTimeoutTimer(false);
                        }
                     }
                  }
                  else
                  {
                     setupReconnectTimer(false);
                     setupNetConnectionListeners(false);
                     setupNetStreamListeners(false);
                     setupTimeoutTimer(false);
                  }
                  break;
               case NetStreamCodes.NETSTREAM_PAUSE_NOTIFY:
                  streamIsPaused = true;
                  break;
               case NetStreamCodes.NETSTREAM_UNPAUSE_NOTIFY:
                  streamIsPaused = false;
                  break;
               case NetStreamCodes.NETSTREAM_BUFFER_EMPTY:
                  if(!netConnection.connected)
                  {
                     if(timeoutTimer != null)
                     {
                        timeoutTimer.start();
                     }
                     else
                     {
                        reconnectHasTimedOut = true;
                     }
                  }
                  else
                  {
                     bufferIsEmpty = true;
                  }
                  break;
               case NetStreamCodes.NETSTREAM_BUFFER_FULL:
                  bufferIsEmpty = false;
            }
         };
         onTimeoutTimer = function(event:TimerEvent):void
         {
            reconnectHasTimedOut = true;
         };
         onReconnectTimer = function(event:TimerEvent):void
         {
            if(reconnectHasTimedOut)
            {
               return;
            }
            if(netConnection === loadTrait.connection)
            {
               setupNetConnectionListeners(false);
               netConnection = createReconnectNetConnection();
               netConnection.client = new NetClient();
               setupNetConnectionListeners();
            }
            reconnect(netConnection,loadTrait.resource as URLResource);
         };
         netConnection = loadTrait.connection;
         reconnectTimer = new Timer(STREAM_RECONNECT_TIMER_INTERVAL,1);
         this.oldConnectionURLs[loadTrait.resource] = netConnection.uri;
         streamIsPaused = false;
         bufferIsEmpty = false;
         reconnectHasTimedOut = false;
         fmsIdleTimeoutReached = false;
         setupNetConnectionListeners();
         setupNetStreamListeners();
         setupReconnectTimer();
         setupTimeoutTimer();
      }
   }
}

