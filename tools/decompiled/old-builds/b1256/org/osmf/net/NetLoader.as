package org.osmf.net
{
   import flash.events.NetStatusEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
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
      
      private static const STREAM_RECONNECT_TIMEOUT:Number = 120000;
      
      private static const STREAM_RECONNECT_TIMER_INTERVAL:int = 1000;
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["video"]);
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["video/x-flv","video/x-f4v","video/mp4","video/mp4v-es","video/x-m4v","video/3gpp","video/3gpp2","video/quicktime"]);
      
      private var netConnectionFactory:NetConnectionFactoryBase;
      
      private var pendingLoads:Dictionary = new Dictionary();
      
      private var oldConnectionURLs:Dictionary = new Dictionary();
      
      private var _reconnectStreams:Boolean = true;
      
      private var _reconnectTimeout:Number;
      
      public function NetLoader(param1:NetConnectionFactoryBase = null)
      {
         super();
         _reconnectTimeout = 120000;
         netConnectionFactory = param1 || new NetConnectionFactory();
         netConnectionFactory.addEventListener("creationComplete",onCreationComplete);
         netConnectionFactory.addEventListener("creationError",onCreationError);
      }
      
      public function get reconnectTimeout() : Number
      {
         return _reconnectTimeout;
      }
      
      public function set reconnectTimeout(param1:Number) : void
      {
         if(param1 < 0)
         {
            throw new ArgumentError(OSMFStrings.getString("invalidParam"));
         }
         _reconnectTimeout = param1;
      }
      
      protected function setReconnectStreams(param1:Boolean) : void
      {
         _reconnectStreams = param1;
      }
      
      public function get reconnectStreams() : Boolean
      {
         return _reconnectStreams;
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc4_:int = MediaTypeUtil.checkMetadataMatchWithResource(param1,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(_loc4_ != 2)
         {
            return _loc4_ == 0;
         }
         var _loc2_:URLResource = param1 as URLResource;
         var _loc3_:RegExp = /.flv$|.f4v$|.mov$|.mp4$|.mp4v$|.m4v$|.3gp$|.3gpp2$|.3g2$/i;
         var _loc5_:URL = _loc2_ != null ? new URL(_loc2_.url) : null;
         if(_loc5_ == null || _loc5_.rawUrl == null || _loc5_.rawUrl.length <= 0)
         {
            return false;
         }
         if(_loc5_.protocol == "")
         {
            return _loc3_.test(_loc5_.path);
         }
         if(NetStreamUtils.isRTMPStream(_loc5_.rawUrl))
         {
            return true;
         }
         if(_loc5_.protocol.search(/file$|http$|https$/i) != -1)
         {
            return _loc5_.path == null || _loc5_.path.length <= 0 || _loc5_.path.indexOf(".") == -1 || _loc3_.test(_loc5_.path);
         }
         return false;
      }
      
      protected function createNetStream(param1:NetConnection, param2:URLResource) : NetStream
      {
         var _loc4_:NetStream = new NetStream(param1);
         var _loc3_:StreamingURLResource = param2 as StreamingURLResource;
         if(_loc3_ != null && _loc3_.streamType == "live" && _loc4_.bufferTime == 0)
         {
            _loc4_.bufferTime = 0.1;
         }
         return _loc4_;
      }
      
      protected function createNetStreamSwitchManager(param1:NetConnection, param2:NetStream, param3:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         return null;
      }
      
      protected function processFinishLoading(param1:NetStreamLoadTrait) : void
      {
         updateLoadTrait(param1,"ready");
      }
      
      override protected function executeLoad(param1:LoadTrait) : void
      {
         updateLoadTrait(param1,"loading");
         var _loc2_:URL = new URL((param1.resource as URLResource).url);
         switch(_loc2_.protocol)
         {
            case "rtmp":
            case "rtmps":
            case "rtmpt":
            case "rtmpe":
            case "rtmpte":
            case "rtmfp":
               startLoadingRTMP(param1);
               break;
            case "http":
            case "https":
            case "file":
            case "":
               startLoadingHTTP(param1);
               break;
            default:
               updateLoadTrait(param1,"loadError");
               param1.dispatchEvent(new MediaErrorEvent("mediaError",false,false,new MediaError(5)));
         }
      }
      
      override protected function executeUnload(param1:LoadTrait) : void
      {
         var _loc2_:NetStreamLoadTrait = param1 as NetStreamLoadTrait;
         updateLoadTrait(param1,"unloading");
         _loc2_.netStream.close();
         if(_loc2_.netConnectionFactory != null)
         {
            _loc2_.netConnectionFactory.closeNetConnection(_loc2_.connection);
         }
         else
         {
            _loc2_.connection.close();
         }
         delete oldConnectionURLs[param1.resource];
         updateLoadTrait(param1,"uninitialized");
      }
      
      protected function createReconnectNetConnection() : NetConnection
      {
         return new NetConnection();
      }
      
      protected function reconnect(param1:NetConnection, param2:URLResource) : void
      {
         var _loc3_:String = oldConnectionURLs[param2] as String;
         if(_loc3_ != null && _loc3_.length > 0 && param1 != null)
         {
            param1.connect(_loc3_);
         }
      }
      
      protected function reconnectStream(param1:NetStreamLoadTrait) : void
      {
         var _loc5_:NetStreamPlayOptions = new NetStreamPlayOptions();
         param1.netStream.attach(param1.connection);
         _loc5_.transition = "resume";
         var _loc3_:URLResource = param1.resource as URLResource;
         var _loc2_:Boolean = _loc3_ as StreamingURLResource != null ? (_loc3_ as StreamingURLResource).urlIncludesFMSApplicationInstance : false;
         var _loc4_:String = NetStreamUtils.getStreamNameFromURL(_loc3_.url,_loc2_);
         _loc5_.streamName = _loc4_;
         param1.netStream.play2(_loc5_);
      }
      
      private function finishLoading(param1:NetConnection, param2:LoadTrait, param3:NetConnectionFactoryBase = null) : void
      {
         var _loc5_:NetStream = null;
         var _loc4_:NetStreamLoadTrait = param2 as NetStreamLoadTrait;
         if(_loc4_ != null)
         {
            _loc4_.connection = param1;
            _loc5_ = createNetStream(param1,_loc4_.resource as URLResource);
            _loc5_.client = new NetClient();
            _loc4_.netStream = _loc5_;
            _loc4_.switchManager = createNetStreamSwitchManager(param1,_loc5_,_loc4_.resource as DynamicStreamingResource);
            _loc4_.netConnectionFactory = param3;
            if(_reconnectStreams && _loc4_.resource is URLResource && supportsStreamReconnect(_loc4_.resource as URLResource))
            {
               setupStreamReconnect(_loc4_);
            }
            processFinishLoading(param2 as NetStreamLoadTrait);
         }
      }
      
      private function supportsStreamReconnect(param1:URLResource) : Boolean
      {
         var _loc6_:String = null;
         var _loc4_:Array = null;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:Boolean = true;
         if(NetStreamUtils.isRTMPStream(param1.url))
         {
            _loc6_ = param1.getMetadataValue("http://www.osmf.org/fmsServerVersion/1.0") as String;
            if(_loc6_ != null && _loc6_.length > 0)
            {
               _loc4_ = _loc6_.split(",");
               if(_loc4_.length >= 3)
               {
                  _loc3_ = int(_loc4_[0]);
                  _loc5_ = int(_loc4_[1]);
                  _loc7_ = int(_loc4_[2]);
                  if(_loc3_ < 3 || _loc3_ == 3 && _loc5_ < 5 || _loc3_ == 3 && _loc5_ == 5 && _loc7_ < 3)
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
      
      private function setupStreamReconnect(param1:NetStreamLoadTrait) : void
      {
         var timeoutTimer:Timer;
         var streamIsPaused:Boolean;
         var bufferIsEmpty:Boolean;
         var reconnectHasTimedOut:Boolean;
         var fmsIdleTimeoutReached:Boolean;
         var loadTrait:NetStreamLoadTrait = param1;
         var setupReconnectTimer:* = function(param1:Boolean = true):void
         {
            if(param1)
            {
               reconnectTimer.addEventListener("timerComplete",onReconnectTimer);
            }
            else
            {
               reconnectTimer.removeEventListener("timerComplete",onReconnectTimer);
               reconnectTimer = null;
            }
         };
         var setupTimeoutTimer:* = function(param1:Boolean = true):void
         {
            if(param1)
            {
               if(_reconnectTimeout > 0)
               {
                  timeoutTimer = new Timer(_reconnectTimeout,1);
                  timeoutTimer.addEventListener("timerComplete",onTimeoutTimer);
               }
            }
            else if(timeoutTimer != null)
            {
               timeoutTimer.removeEventListener("timerComplete",onTimeoutTimer);
               timeoutTimer = null;
            }
         };
         var setupNetConnectionListeners:* = function(param1:Boolean = true):void
         {
            if(param1)
            {
               netConnection.addEventListener("netStatus",onNetStatus);
            }
            else
            {
               netConnection.removeEventListener("netStatus",onNetStatus);
            }
         };
         var setupNetStreamListeners:* = function(param1:Boolean = true):void
         {
            if(loadTrait.netStream != null)
            {
               if(param1)
               {
                  loadTrait.netStream.addEventListener("netStatus",onNetStatus);
               }
               else
               {
                  loadTrait.netStream.removeEventListener("netStatus",onNetStatus);
               }
            }
         };
         var onNetStatus:* = function(param1:NetStatusEvent):void
         {
            var _loc2_:NetConnection = null;
            switch(param1.info.code)
            {
               case "NetConnection.Connect.Success":
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
               case "NetConnection.Connect.IdleTimeOut":
                  fmsIdleTimeoutReached = true;
                  break;
               case "NetConnection.Connect.Closed":
               case "NetConnection.Connect.Failed":
                  if(loadTrait.loadState == "ready" && !reconnectHasTimedOut && !fmsIdleTimeoutReached)
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
               case "NetStream.Pause.Notify":
                  streamIsPaused = true;
                  break;
               case "NetStream.Unpause.Notify":
                  streamIsPaused = false;
                  break;
               case "NetStream.Buffer.Empty":
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
               case "NetStream.Buffer.Full":
                  bufferIsEmpty = false;
            }
         };
         var onTimeoutTimer:* = function(param1:TimerEvent):void
         {
            reconnectHasTimedOut = true;
         };
         var onReconnectTimer:* = function(param1:TimerEvent):void
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
         var netConnection:NetConnection = loadTrait.connection;
         var reconnectTimer:Timer = new Timer(1000,1);
         oldConnectionURLs[loadTrait.resource] = netConnection.uri;
         streamIsPaused = false;
         bufferIsEmpty = false;
         reconnectHasTimedOut = false;
         fmsIdleTimeoutReached = false;
         setupNetConnectionListeners();
         setupNetStreamListeners();
         setupReconnectTimer();
         setupTimeoutTimer();
      }
      
      private function startLoadingRTMP(param1:LoadTrait) : void
      {
         addPendingLoad(param1);
         netConnectionFactory.create(param1.resource as URLResource);
      }
      
      private function onCreationComplete(param1:NetConnectionFactoryEvent) : void
      {
         processCreationComplete(param1.netConnection,findAndRemovePendingLoad(param1.resource),param1.currentTarget as NetConnectionFactoryBase);
      }
      
      protected function processCreationComplete(param1:NetConnection, param2:LoadTrait, param3:NetConnectionFactoryBase = null) : void
      {
         finishLoading(param1,param2,param3);
      }
      
      private function onCreationError(param1:NetConnectionFactoryEvent) : void
      {
         var _loc2_:LoadTrait = findAndRemovePendingLoad(param1.resource);
         if(_loc2_ != null)
         {
            _loc2_.dispatchEvent(new MediaErrorEvent("mediaError",false,false,param1.mediaError));
            updateLoadTrait(_loc2_,"loadError");
         }
      }
      
      private function startLoadingHTTP(param1:LoadTrait) : void
      {
         var _loc2_:NetConnection = new NetConnection();
         _loc2_.client = new NetClient();
         _loc2_.connect(null);
         finishLoading(_loc2_,param1);
      }
      
      private function addPendingLoad(param1:LoadTrait) : void
      {
         if(pendingLoads[param1.resource] == null)
         {
            pendingLoads[param1.resource] = [param1];
         }
         else
         {
            pendingLoads[param1.resource].push(param1);
         }
      }
      
      private function findAndRemovePendingLoad(param1:URLResource) : LoadTrait
      {
         var _loc4_:int = 0;
         var _loc2_:LoadTrait = null;
         var _loc3_:Array = pendingLoads[param1];
         if(_loc3_ != null)
         {
            if(_loc3_.length == 1)
            {
               _loc2_ = _loc3_[0] as LoadTrait;
               delete pendingLoads[param1];
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
   }
}

