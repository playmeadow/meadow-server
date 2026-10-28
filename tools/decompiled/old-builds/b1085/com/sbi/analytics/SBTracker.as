package com.sbi.analytics
{
   import com.carlcalderon.arthropod.Debug;
   import flash.events.DataEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.net.Socket;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   
   public class SBTracker
   {
      
      private static var _pageStack:Array;
      
      private static var _batchTimer:Timer;
      
      private static var _isExternalAvailable:Boolean;
      
      private static var _couldNotConnect:Boolean;
      
      private static var _pageView:String;
      
      private static var _socket:Socket;
      
      private static var _timeOffset:Number;
      
      private static var _isFromLogin:Boolean;
      
      private static var _retryLimit:int;
      
      private static var _lastBatchCallback:Function;
      
      private static var _trackingObjects:Dictionary;
      
      private static var _latestTrackTimeStamp:Dictionary;
      
      private static var _lastestDuration:Dictionary;
      
      public static const TYPE_NORMAL:int = 0;
      
      public static const TYPE_EVENT:int = 1;
      
      public static const TYPE_ERROR:int = 2;
      
      private static var MAX_RETRIES:int = 3;
      
      public function SBTracker()
      {
         super();
      }
      
      public static function create() : void
      {
         if(ExternalInterface.available && gMainFrame.clientInfo.sbTrackerIp != -1)
         {
            _isExternalAvailable = true;
            ExternalInterface.addCallback("receiveClose",receiveClose);
            if(!isNaN(gMainFrame.clientInfo.currentTimestamp))
            {
               _timeOffset = gMainFrame.clientInfo.currentTimestamp - new Date().valueOf() / 1000;
            }
            else
            {
               _timeOffset = 0;
            }
            _pageView = null;
            _pageStack = [];
            _socket = new Socket();
            _socket.addEventListener(Event.CLOSE,closeHandler);
            _socket.addEventListener(Event.CONNECT,connectHandler);
            _socket.addEventListener(DataEvent.DATA,dataHandler);
            _socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
            _trackingObjects = new Dictionary();
            _trackingObjects[TYPE_NORMAL] = [];
            _trackingObjects[TYPE_EVENT] = [];
            _trackingObjects[TYPE_ERROR] = [];
            _latestTrackTimeStamp = new Dictionary();
            _latestTrackTimeStamp[TYPE_NORMAL] = 0;
            _lastestDuration = new Dictionary();
            _lastestDuration[TYPE_NORMAL] = 0;
            _batchTimer = new Timer(10000);
            _batchTimer.addEventListener(TimerEvent.TIMER,onBatchTimer,false,0,true);
            _batchTimer.start();
         }
      }
      
      public static function receiveClose() : String
      {
         _batchTimer.stop();
         _batchTimer.removeEventListener(TimerEvent.TIMER,onBatchTimer);
         if(_pageView != null)
         {
            setupPageView();
            return _pageView;
         }
         return null;
      }
      
      public static function onError() : void
      {
         if(_isExternalAvailable)
         {
            ExternalInterface.call("reportAnalyticsError","Error Timeout",gMainFrame.clientInfo.sessionId);
         }
         Debug.log("Sending analytics error",Debug.RED);
      }
      
      public static function trackPageview(param1:String, param2:int = -1, param3:int = 0, param4:Boolean = true) : void
      {
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         if(_isExternalAvailable && !_couldNotConnect)
         {
            _isFromLogin = param2 != -1;
            if(_isFromLogin)
            {
               _loc5_ = 0;
            }
            else if(gMainFrame.clientInfo.dbUserId == undefined)
            {
               _loc5_ = -1;
            }
            else
            {
               _loc5_ = int(gMainFrame.clientInfo.dbUserId);
            }
            if(_loc5_ > 0)
            {
               if(param4 && _loc5_ % gMainFrame.clientInfo.sbTrackerModulator != 0)
               {
                  return;
               }
            }
            _loc6_ = Math.floor(new Date().valueOf() / 1000 + _timeOffset);
            if(gMainFrame.clientInfo.sessionId == undefined && _isFromLogin)
            {
               gMainFrame.clientInfo.sessionId = Math.floor(Math.random() * (int.MAX_VALUE + 1));
            }
            _trackingObjects[param3].push(new URIObj(param1,_loc6_,_isFromLogin,param3,_trackingObjects[param3].length,param4));
         }
      }
      
      public static function handleErrorTracking(param1:int, param2:int, param3:int, param4:int, param5:Number, param6:String, param7:String, param8:int, param9:int) : void
      {
         var _loc10_:Number = Number(gMainFrame.clientInfo.sessionId);
         if(gMainFrame.clientInfo.sessionId == undefined)
         {
            _loc10_ = Math.round(Math.random() * (int.MAX_VALUE + 1));
         }
         if(gMainFrame.clientInfo.dbUserId == undefined)
         {
            gMainFrame.clientInfo.dbUserId = param1;
         }
         var _loc11_:Object = {
            "userId":(gMainFrame.clientInfo.dbUserId == undefined ? param1 : null),
            "order":param3,
            "duration":(param4 == -1 ? null : param4),
            "sessionId":(param5 == -1 ? _loc10_ : null)
         };
         _trackingObjects[TYPE_ERROR].push(new URIObj(param6 + "#" + param7 + "#" + param8 + "#" + param9,param2 == -1 ? Math.floor(new Date().valueOf() / 1000 + _timeOffset) : param2,_isFromLogin,TYPE_ERROR,_trackingObjects[TYPE_ERROR].length,false,_loc11_));
         onBatchTimer(null);
      }
      
      public static function handleOnKickOrLogout() : void
      {
         if(_isExternalAvailable && _pageView != null)
         {
            ExternalInterface.call("handleLogout",_pageView);
         }
      }
      
      public static function push(param1:int = 0) : void
      {
         var _loc2_:Array = null;
         var _loc3_:Object = null;
         if(_pageStack)
         {
            _loc2_ = _trackingObjects[param1];
            if(_loc2_.length > 0)
            {
               _loc3_ = _loc2_[_loc2_.length - 1].trackingObject;
               _pageStack.push(_loc3_.uri + "#" + _loc3_.uriParams + "#pop#" + _loc3_.value);
            }
         }
      }
      
      public static function pop() : void
      {
         if(Boolean(_pageStack) && Boolean(_pageStack.length))
         {
            trackPageview(_pageStack.pop());
         }
      }
      
      public static function flush(param1:Boolean = false) : void
      {
         if(Boolean(_pageStack) && Boolean(_pageStack.length))
         {
            if(param1)
            {
               trackPageview(_pageStack[0]);
            }
            _pageStack = [];
         }
      }
      
      public static function completeLastTrackingBatch(param1:Function) : void
      {
         _lastBatchCallback = param1;
         if(_batchTimer)
         {
            _batchTimer.stop();
            if(_socket)
            {
               setupPageView(true);
               if(_pageView != null)
               {
                  _batchTimer.reset();
                  _socket.connect(gMainFrame.clientInfo.sbTrackerIp,5050);
                  return;
               }
            }
         }
         if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
      }
      
      public static function getLastDuration(param1:int) : Number
      {
         return _lastestDuration[param1];
      }
      
      public static function setLastDuration(param1:int, param2:Number) : void
      {
         _lastestDuration[param1] = param2;
      }
      
      public static function getLastTimestamp(param1:int) : Number
      {
         return _latestTrackTimeStamp[param1];
      }
      
      public static function setLastTimestamp(param1:int, param2:Number) : void
      {
         _latestTrackTimeStamp[param1] = param2;
      }
      
      public static function getnextURIObjByType(param1:int, param2:int) : URIObj
      {
         var _loc3_:Array = _trackingObjects[param2];
         if(_loc3_.length > 0 && _loc3_.length > param1 + 1)
         {
            return _loc3_[param1 + 1];
         }
         return null;
      }
      
      public static function getPreviousURIObjByType(param1:int, param2:int) : URIObj
      {
         var _loc3_:Array = _trackingObjects[param2];
         if(_loc3_.length > 0 && _loc3_.length > param1 - 1)
         {
            return _loc3_[param1 - 1];
         }
         return null;
      }
      
      private static function findLatestTrackedURIObjByThrottleType(param1:Array, param2:Boolean) : URIObj
      {
         var _loc3_:* = 0;
         if(param1)
         {
            _loc3_ = int(param1.length - 1);
            while(_loc3_ >= 0)
            {
               if(param1[_loc3_].throttled == param2)
               {
                  return param1[_loc3_];
               }
               _loc3_--;
            }
         }
         return null;
      }
      
      private static function onBatchTimer(param1:TimerEvent) : void
      {
         if(_socket)
         {
            setupPageView();
            if(_pageView != null)
            {
               _batchTimer.reset();
               _socket.connect(gMainFrame.clientInfo.sbTrackerIp,5050);
               return;
            }
         }
         if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
      }
      
      private static function setupPageView(param1:Boolean = false) : void
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         var _loc4_:URIObj = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Array = null;
         var _loc8_:Boolean = false;
         if(_pageView == null)
         {
            _loc2_ = "";
            for(_loc6_ in _trackingObjects)
            {
               _loc3_ = int(_loc6_);
               _loc7_ = _trackingObjects[_loc3_];
               if(_loc7_.length > 0)
               {
                  if(gMainFrame.clientInfo.sessionId != undefined)
                  {
                     _loc5_ = 0;
                     for(; _loc5_ < _loc7_.length; _loc5_++)
                     {
                        _loc4_ = _loc7_[_loc5_];
                        if(_loc4_.throttled)
                        {
                           if(!_loc4_.isFromLogin)
                           {
                              if(gMainFrame.clientInfo.dbUserId % gMainFrame.clientInfo.sbTrackerModulator != 0)
                              {
                                 continue;
                              }
                           }
                           else if(gMainFrame.clientInfo.sessionId % gMainFrame.clientInfo.sbTrackerModulator != 0)
                           {
                              continue;
                           }
                        }
                        _loc2_ += _loc4_.pageView;
                     }
                     if(param1)
                     {
                        if(_loc4_.throttled)
                        {
                           if(!_loc4_.isFromLogin)
                           {
                              if(gMainFrame.clientInfo.dbUserId % gMainFrame.clientInfo.sbTrackerModulator != 0)
                              {
                                 _loc8_ = false;
                              }
                              else
                              {
                                 _loc8_ = true;
                              }
                           }
                           else if(gMainFrame.clientInfo.sessionId % gMainFrame.clientInfo.sbTrackerModulator != 0)
                           {
                              _loc8_ = false;
                           }
                           else
                           {
                              _loc8_ = true;
                           }
                        }
                        else
                        {
                           _loc8_ = true;
                        }
                        if(_loc8_)
                        {
                           _loc2_ += _loc4_.ownPageView;
                        }
                        _trackingObjects[_loc3_] = [];
                        _loc7_ = [];
                     }
                     else
                     {
                        _trackingObjects[_loc3_].splice(0,_loc7_.length - 1);
                        _loc7_.splice(0,_loc7_.length - 1);
                        _loc4_.index = 0;
                     }
                  }
               }
            }
            if(_loc2_ != "")
            {
               _pageView = _loc2_;
            }
         }
      }
      
      private static function closeHandler(param1:Event) : void
      {
         _socket.close();
      }
      
      private static function connectHandler(param1:Event) : void
      {
         Debug.log(_pageView,Debug.YELLOW);
         _socket.writeUTFBytes(_pageView);
         _pageView = null;
         _socket.flush();
         _socket.close();
         _retryLimit = 0;
         _batchTimer.start();
         if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
      }
      
      private static function dataHandler(param1:DataEvent) : void
      {
      }
      
      private static function ioErrorHandler(param1:IOErrorEvent) : void
      {
         if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
         if(_retryLimit < MAX_RETRIES)
         {
            ++_retryLimit;
            Debug.log("IO error - retrying analytics connection",Debug.RED);
            _socket.connect(gMainFrame.clientInfo.sbTrackerIp,5050);
            return;
         }
         _couldNotConnect = true;
      }
      
      private static function securityErrorHandler(param1:SecurityErrorEvent) : void
      {
         if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
         if(_retryLimit < MAX_RETRIES)
         {
            Debug.log("Security error - retrying analytics connection",Debug.RED);
            ++_retryLimit;
            _socket.connect(gMainFrame.clientInfo.sbTrackerIp,5050);
            return;
         }
         if(_batchTimer)
         {
            _batchTimer.stop();
            _batchTimer.removeEventListener(TimerEvent.TIMER,onBatchTimer);
         }
         _couldNotConnect = true;
         _pageView = null;
         _socket = null;
         onError();
      }
   }
}

