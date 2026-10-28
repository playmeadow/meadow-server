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
      
      public function NetLoader(param1:NetConnectionFactoryBase = null)
      {
         super();
         this._reconnectTimeout = STREAM_RECONNECT_TIMEOUT;
         this.netConnectionFactory = param1 || new NetConnectionFactory();
         this.netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,this.onCreationComplete);
         this.netConnectionFactory.addEventListener(NetConnectionFactoryEvent.CREATION_ERROR,this.onCreationError);
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:int = MediaTypeUtil.checkMetadataMatchWithResource(param1,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(_loc2_ != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
         {
            return _loc2_ == MediaTypeUtil.METADATA_MATCH_FOUND;
         }
         var _loc3_:URLResource = param1 as URLResource;
         var _loc4_:RegExp = /.flv$|.f4v$|.mov$|.mp4$|.mp4v$|.m4v$|.3gp$|.3gpp2$|.3g2$/i;
         var _loc5_:URL = _loc3_ != null ? new URL(_loc3_.url) : null;
         if(_loc5_ == null || _loc5_.rawUrl == null || _loc5_.rawUrl.length <= 0)
         {
            return false;
         }
         if(_loc5_.protocol == "")
         {
            return _loc4_.test(_loc5_.path);
         }
         if(NetStreamUtils.isRTMPStream(_loc5_.rawUrl))
         {
            return true;
         }
         if(_loc5_.protocol.search(/file$|http$|https$/i) != -1)
         {
            return _loc5_.path == null || _loc5_.path.length <= 0 || _loc5_.path.indexOf(".") == -1 || _loc4_.test(_loc5_.path);
         }
         return false;
      }
      
      protected function createNetStream(param1:NetConnection, param2:URLResource) : NetStream
      {
         var _loc3_:NetStream = new NetStream(param1);
         var _loc4_:StreamingURLResource = param2 as StreamingURLResource;
         if(_loc4_ != null && _loc4_.streamType == StreamType.LIVE && _loc3_.bufferTime == 0)
         {
            _loc3_.bufferTime = 0.1;
         }
         return _loc3_;
      }
      
      protected function createNetStreamSwitchManager(param1:NetConnection, param2:NetStream, param3:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         return null;
      }
      
      protected function processFinishLoading(param1:NetStreamLoadTrait) : void
      {
         updateLoadTrait(param1,LoadState.READY);
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         updateLoadTrait(param1,LoadState.LOADING);
         var _loc2_:URL = new URL((param1.resource as URLResource).url);
         switch(_loc2_.protocol)
         {
            case PROTOCOL_RTMP:
            case PROTOCOL_RTMPS:
            case PROTOCOL_RTMPT:
            case PROTOCOL_RTMPE:
            case PROTOCOL_RTMPTE:
            case PROTOCOL_RTMFP:
               this.startLoadingRTMP(param1);
               break;
            case PROTOCOL_HTTP:
            case PROTOCOL_HTTPS:
            case PROTOCOL_FILE:
            case PROTOCOL_EMPTY:
               this.startLoadingHTTP(param1);
               break;
            default:
               updateLoadTrait(param1,LoadState.LOAD_ERROR);
               param1.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.URL_SCHEME_INVALID)));
         }
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         var _loc2_:NetStreamLoadTrait = param1 as NetStreamLoadTrait;
         updateLoadTrait(param1,LoadState.UNLOADING);
         _loc2_.netStream.close();
         if(_loc2_.netConnectionFactory != null)
         {
            _loc2_.netConnectionFactory.closeNetConnection(_loc2_.connection);
         }
         else
         {
            _loc2_.connection.close();
         }
         delete this.oldConnectionURLs[param1.resource];
         updateLoadTrait(param1,LoadState.UNINITIALIZED);
      }
      
      private function finishLoading(param1:NetConnection, param2:LoadTrait, param3:NetConnectionFactoryBase = null) : void
      {
         var _loc5_:NetStream = null;
         var _loc4_:NetStreamLoadTrait = param2 as NetStreamLoadTrait;
         if(_loc4_ != null)
         {
            _loc4_.connection = param1;
            _loc5_ = this.createNetStream(param1,_loc4_.resource as URLResource);
            _loc5_.client = new NetClient();
            _loc4_.netStream = _loc5_;
            _loc4_.switchManager = this.createNetStreamSwitchManager(param1,_loc5_,_loc4_.resource as DynamicStreamingResource);
            _loc4_.netConnectionFactory = param3;
            if(this._reconnectStreams && _loc4_.resource is URLResource && this.supportsStreamReconnect(_loc4_.resource as URLResource))
            {
               this.setupStreamReconnect(_loc4_);
            }
            this.processFinishLoading(param2 as NetStreamLoadTrait);
         }
      }
      
      private function supportsStreamReconnect(param1:URLResource) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:Boolean = true;
         if(NetStreamUtils.isRTMPStream(param1.url))
         {
            _loc3_ = param1.getMetadataValue(MetadataNamespaces.FMS_SERVER_VERSION_METADATA) as String;
            if(_loc3_ != null && _loc3_.length > 0)
            {
               _loc4_ = _loc3_.split(",");
               if(_loc4_.length >= 3)
               {
                  _loc5_ = int(_loc4_[0]);
                  _loc6_ = int(_loc4_[1]);
                  _loc7_ = int(_loc4_[2]);
                  if(_loc5_ < 3 || _loc5_ == 3 && _loc6_ < 5 || _loc5_ == 3 && _loc6_ == 5 && _loc7_ < 3)
                  {
                     _loc2_ = false;
                  }
               }
            }
         }
         else
         {
            _loc2_ = false;
         }
         return _loc2_;
      }
      
      private function startLoadingRTMP(param1:LoadTrait) : void
      {
         this.addPendingLoad(param1);
         this.netConnectionFactory.create(param1.resource as URLResource);
      }
      
      private function onCreationComplete(param1:NetConnectionFactoryEvent) : void
      {
         this.processCreationComplete(param1.netConnection,this.findAndRemovePendingLoad(param1.resource),param1.currentTarget as NetConnectionFactoryBase);
      }
      
      protected function processCreationComplete(param1:NetConnection, param2:LoadTrait, param3:NetConnectionFactoryBase = null) : void
      {
         this.finishLoading(param1,param2,param3);
      }
      
      private function onCreationError(param1:NetConnectionFactoryEvent) : void
      {
         var _loc2_:LoadTrait = this.findAndRemovePendingLoad(param1.resource);
         if(_loc2_ != null)
         {
            _loc2_.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,param1.mediaError));
            updateLoadTrait(_loc2_,LoadState.LOAD_ERROR);
         }
      }
      
      private function startLoadingHTTP(param1:LoadTrait) : void
      {
         var _loc2_:NetConnection = new NetConnection();
         _loc2_.client = new NetClient();
         _loc2_.connect(null);
         this.finishLoading(_loc2_,param1);
      }
      
      private function addPendingLoad(param1:LoadTrait) : void
      {
         if(this.pendingLoads[param1.resource] == null)
         {
            this.pendingLoads[param1.resource] = [param1];
         }
         else
         {
            this.pendingLoads[param1.resource].push(param1);
         }
      }
      
      private function findAndRemovePendingLoad(param1:URLResource) : LoadTrait
      {
         var _loc4_:int = 0;
         var _loc2_:LoadTrait = null;
         var _loc3_:Array = this.pendingLoads[param1];
         if(_loc3_ != null)
         {
            if(_loc3_.length == 1)
            {
               _loc2_ = _loc3_[0] as LoadTrait;
               delete this.pendingLoads[param1];
            }
            else
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  _loc2_ = _loc3_[_loc4_];
                  if(_loc2_.resource == param1)
                  {
                     _loc3_.splice(_loc4_,1);
                     break;
                  }
                  _loc4_++;
               }
            }
         }
         return _loc2_;
      }
      
      public function get reconnectTimeout() : Number
      {
         return this._reconnectTimeout;
      }
      
      public function set reconnectTimeout(param1:Number) : void
      {
         if(param1 < 0)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         this._reconnectTimeout = param1;
      }
      
      protected function setReconnectStreams(param1:Boolean) : void
      {
         this._reconnectStreams = param1;
      }
      
      public function get reconnectStreams() : Boolean
      {
         return this._reconnectStreams;
      }
      
      protected function createReconnectNetConnection() : NetConnection
      {
         return new NetConnection();
      }
      
      protected function reconnect(param1:NetConnection, param2:URLResource) : void
      {
         var _loc3_:String = this.oldConnectionURLs[param2] as String;
         if(_loc3_ != null && _loc3_.length > 0 && param1 != null)
         {
            param1.connect(_loc3_);
         }
      }
      
      protected function reconnectStream(param1:NetStreamLoadTrait) : void
      {
         var _loc2_:NetStreamPlayOptions = new NetStreamPlayOptions();
         param1.netStream.attach(param1.connection);
         _loc2_.transition = NetStreamPlayTransitions.RESUME;
         var _loc3_:URLResource = param1.resource as URLResource;
         var _loc4_:Boolean = _loc3_ as StreamingURLResource != null ? (_loc3_ as StreamingURLResource).urlIncludesFMSApplicationInstance : false;
         var _loc5_:String = NetStreamUtils.getStreamNameFromURL(_loc3_.url,_loc4_);
         _loc2_.streamName = _loc5_;
         param1.netStream.play2(_loc2_);
      }
      
      private function setupStreamReconnect(param1:NetStreamLoadTrait) : void
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
         var loadTrait:NetStreamLoadTrait = param1;
         var setupReconnectTimer:Function = function(param1:Boolean = true):void
         {
            if(param1)
            {
               reconnectTimer.addEventListener(TimerEvent.TIMER_COMPLETE,onReconnectTimer);
            }
            else
            {
               reconnectTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,onReconnectTimer);
               reconnectTimer = null;
            }
         };
         var setupTimeoutTimer:Function = function(param1:Boolean = true):void
         {
            if(param1)
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
         var setupNetConnectionListeners:Function = function(param1:Boolean = true):void
         {
            if(param1)
            {
               netConnection.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
            }
            else
            {
               netConnection.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
            }
         };
         var setupNetStreamListeners:Function = function(param1:Boolean = true):void
         {
            if(loadTrait.netStream != null)
            {
               if(param1)
               {
                  loadTrait.netStream.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
               }
               else
               {
                  loadTrait.netStream.removeEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
               }
            }
         };
         onNetStatus = function(param1:NetStatusEvent):void
         {
            var _loc2_:NetConnection = null;
            switch(param1.info.code)
            {
               case NetConnectionCodes.CONNECT_SUCCESS:
                  _loc2_ = loadTrait.connection;
                  loadTrait.connection = netConnection;
                  oldConnectionURLs[loadTrait.resource] = netConnection.uri;
                  if(timeoutTimer != null)
                  {
                     timeoutTimer.stop();
                  }
                  reconnectStream(loadTrait);
                  if(loadTrait.netConnectionFactory != null)
                  {
                     loadTrait.netConnectionFactory.closeNetConnection(_loc2_);
                  }
                  else
                  {
                     _loc2_.close();
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
         onTimeoutTimer = function(param1:TimerEvent):void
         {
            reconnectHasTimedOut = true;
         };
         onReconnectTimer = function(param1:TimerEvent):void
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

