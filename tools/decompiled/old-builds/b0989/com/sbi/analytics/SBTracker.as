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
   import flash.utils.Timer;
   import flash.utils.getTimer;
   
   public class SBTracker
   {
      
      private static var _lastPage:String;
      
      private static var _pageStack:Array;
      
      private static var _batchTimer:Timer;
      
      private static var _previousDurationTime:Number;
      
      private static var _isExternalAvailable:Boolean;
      
      private static var _couldNotConnect:Boolean;
      
      private static var _containsAnUndefined:Boolean;
      
      private static var _pageView:String;
      
      private static var _socket:Socket;
      
      private static var _timeOffset:Number;
      
      private static var _isFromLogin:Boolean;
      
      private static var _holdingObject:Object;
      
      private static var _retryLimit:int;
      
      private static var _latestTimeStamp:Number;
      
      private static var _lastBatchCallback:Function;
      
      private static var _errorPageView:String;
      
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
            _holdingObject = null;
            _pageView = null;
            _lastPage = null;
            _pageStack = [];
            _previousDurationTime = 0;
            _latestTimeStamp = 0;
            _socket = new Socket();
            _socket.addEventListener(Event.CLOSE,closeHandler);
            _socket.addEventListener(Event.CONNECT,connectHandler);
            _socket.addEventListener(DataEvent.DATA,dataHandler);
            _socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
            _batchTimer = new Timer(10000);
            _batchTimer.addEventListener(TimerEvent.TIMER,onBatchTimer,false,0,true);
            _batchTimer.start();
         }
      }
      
      public static function receiveClose() : String
      {
         var _loc1_:Number = NaN;
         var _loc2_:String = null;
         _batchTimer.stop();
         _batchTimer.removeEventListener(TimerEvent.TIMER,onBatchTimer);
         if(_pageView != null)
         {
            if(_holdingObject != null)
            {
               _loc1_ = _previousDurationTime;
               _previousDurationTime = getTimer();
               _loc1_ = _previousDurationTime - _loc1_;
               _loc2_ = _holdingObject.time + "\n" + _holdingObject.order + "\n" + Math.round(_loc1_ / 100) + "\n" + _holdingObject.sessionId + "\n" + _holdingObject.uri + "\n" + _holdingObject.uriParams + "\n" + _holdingObject.pop + "\n";
               _pageView += _loc2_;
            }
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
      
      public static function trackPageview(param1:String, param2:int = -1) : void
      {
         var _loc3_:Array = null;
         var _loc4_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Number = NaN;
         var _loc7_:Boolean = false;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         if(_isExternalAvailable && !_couldNotConnect)
         {
            _lastPage = param1;
            param1 = param1.replace("\'","");
            _loc3_ = param1.split(/#/i);
            _loc4_ = _previousDurationTime;
            _previousDurationTime = getTimer();
            _loc4_ = _previousDurationTime - _loc4_;
            if(gMainFrame.clientInfo.sessionId == undefined)
            {
               _containsAnUndefined = true;
               _isFromLogin = param2 != -1;
               if(_isFromLogin)
               {
                  gMainFrame.clientInfo.sessionId = Math.floor(Math.random() * (int.MAX_VALUE + 1));
               }
            }
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
            _loc6_ = Math.floor(new Date().valueOf() / 1000 + _timeOffset);
            _loc7_ = _loc6_ - _latestTimeStamp == 0;
            _latestTimeStamp = _loc6_;
            _loc8_ = {
               "userId":_loc5_,
               "time":_loc6_,
               "order":(_holdingObject != null && _loc7_ ? (_holdingObject.order = _holdingObject.order + 1) : 0),
               "duration":Math.round(_loc4_ / 100),
               "sessionId":gMainFrame.clientInfo.sessionId,
               "uri":_loc3_[0],
               "uriParams":(_loc3_[1] != null ? _loc3_[1] : ""),
               "pop":(_loc3_[2] != null ? 1 : 0)
            };
            if(_holdingObject != null)
            {
               _loc9_ = _holdingObject.userId + "\n" + _holdingObject.time + "\n" + _loc8_.order + "\n" + _loc8_.duration + "\n" + _holdingObject.sessionId + "\n" + _holdingObject.uri + "\n" + _holdingObject.uriParams + "\n" + _holdingObject.pop + "\n";
               _holdingObject = {
                  "userId":_loc8_.userId,
                  "time":_loc8_.time,
                  "order":_loc8_.order,
                  "duration:":-1,
                  "sessionId":_loc8_.sessionId,
                  "uri":_loc8_.uri,
                  "uriParams":_loc8_.uriParams,
                  "pop":_loc8_.pop
               };
               if(_pageView != null)
               {
                  _pageView += _loc9_;
               }
               else
               {
                  _pageView = _loc9_;
               }
            }
            else
            {
               _holdingObject = _loc8_;
            }
            _loc10_ = _loc8_.userId + "\n" + _loc8_.time + "\n" + _loc8_.order + "\n" + _loc8_.duration + "\n" + _loc8_.sessionId + "\n" + _loc8_.uri + "\n" + _loc8_.uriParams + "\n" + _loc8_.pop + "\n";
            Debug.log(_loc10_,Debug.PINK);
         }
      }
      
      public static function handleErrorTracking(param1:int, param2:int, param3:int, param4:int, param5:Number, param6:String, param7:String, param8:int) : void
      {
         if(_socket == null)
         {
            _socket = new Socket();
            _socket.addEventListener(Event.CLOSE,closeHandler);
            _socket.addEventListener(Event.CONNECT,errorConnectHandler);
            _socket.addEventListener(DataEvent.DATA,dataHandler);
            _socket.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
            _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,securityErrorHandler);
         }
         else
         {
            _socket.removeEventListener(Event.CONNECT,connectHandler);
            _socket.addEventListener(Event.CONNECT,errorConnectHandler);
         }
         var _loc9_:Number = Number(gMainFrame.clientInfo.sessionId);
         if(gMainFrame.clientInfo.sessionId == undefined)
         {
            _loc9_ = Math.round(Math.random() * (int.MAX_VALUE + 1));
         }
         var _loc10_:Number = isNaN(_previousDurationTime) ? 0 : _previousDurationTime;
         _previousDurationTime = getTimer();
         _loc10_ = _previousDurationTime - _loc10_;
         var _loc11_:Object = {
            "userId":(param1 == -1 ? (gMainFrame.clientInfo.dbUserId != undefined ? gMainFrame.clientInfo.dbUserId : -1) : param1),
            "time":(param2 == -1 ? Math.floor(new Date().valueOf() / 1000 + _timeOffset) : param2),
            "order":param3,
            "duration":(param4 == -1 ? _loc10_ : param4),
            "sessionId":(param5 == -1 ? _loc9_ : param5),
            "uri":param6,
            "uriParams":param7,
            "pop":(param8 == -1 ? 0 : param8)
         };
         var _loc12_:String = _loc11_.userId + "\n" + _loc11_.time + "\n" + _loc11_.order + "\n" + _loc11_.duration + "\n" + _loc11_.sessionId + "\n" + _loc11_.uri + "\n" + _loc11_.uriParams + "\n" + _loc11_.pop + "\n";
         if(_errorPageView != null)
         {
            _errorPageView += _loc12_;
         }
         else
         {
            _errorPageView = _loc12_;
         }
         if(_errorPageView != null && Boolean(_socket))
         {
            if(_batchTimer)
            {
               _batchTimer.reset();
            }
            _socket.connect(gMainFrame.clientInfo.sbTrackerIp,5050);
         }
      }
      
      public static function handleOnKickOrLogout() : void
      {
         if(_isExternalAvailable && _pageView != null)
         {
            ExternalInterface.call("handleLogout",_pageView);
         }
      }
      
      public static function push() : void
      {
         if(Boolean(_pageStack) && _lastPage != null)
         {
            _pageStack.push(_lastPage + "#pop");
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
            onBatchTimer(null);
         }
      }
      
      private static function onBatchTimer(param1:TimerEvent) : void
      {
         if(!_isFromLogin)
         {
            if(gMainFrame.clientInfo.dbUserId == undefined)
            {
               return;
            }
            if(gMainFrame.clientInfo.dbUserId % gMainFrame.clientInfo.sbTrackerModulator != 0)
            {
               _batchTimer.stop();
               _batchTimer.removeEventListener(TimerEvent.TIMER,onBatchTimer);
               _couldNotConnect = true;
               _pageView = null;
               _socket = null;
               _isExternalAvailable = false;
               return;
            }
         }
         if(_lastBatchCallback != null && _retryLimit > 0)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
         if(Boolean(_pageView != null) && Boolean(_socket) && (gMainFrame.clientInfo.sessionId != undefined || _isFromLogin))
         {
            if(_containsAnUndefined && !_isFromLogin)
            {
               _pageView = _pageView.replace(/undefined/gixm,gMainFrame.clientInfo.sessionId);
               _pageView = _pageView.replace(/-1/gixm,gMainFrame.clientInfo.dbUserId);
            }
            _containsAnUndefined = false;
            _batchTimer.reset();
            _socket.connect(gMainFrame.clientInfo.sbTrackerIp,5050);
         }
         else if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
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
         _socket.flush();
         _socket.close();
         _pageView = null;
         _retryLimit = 0;
         _batchTimer.start();
         if(_lastBatchCallback != null)
         {
            _lastBatchCallback();
            _lastBatchCallback = null;
         }
      }
      
      private static function errorConnectHandler(param1:Event) : void
      {
         Debug.log(_errorPageView,Debug.RED);
         _socket.writeUTFBytes(_errorPageView);
         _socket.flush();
         _socket.close();
         _errorPageView = null;
         _retryLimit = 0;
         _socket.addEventListener(Event.CONNECT,connectHandler);
         _socket.removeEventListener(Event.CONNECT,errorConnectHandler);
         if(_batchTimer)
         {
            _batchTimer.start();
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
         if(_retryLimit < 3)
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
         if(_retryLimit < 3)
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

