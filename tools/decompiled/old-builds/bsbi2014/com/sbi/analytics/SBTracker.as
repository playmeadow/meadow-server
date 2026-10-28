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
      
      public static function trackPageview(pageURI:String, loginSessionId:int = -1, type:int = 0, throttled:Boolean = true) : void
      {
         var userId:int = 0;
         var currTime:Number = NaN;
         if(_isExternalAvailable && !_couldNotConnect)
         {
            _isFromLogin = loginSessionId != -1;
            if(_isFromLogin)
            {
               userId = 0;
            }
            else if(gMainFrame.clientInfo.dbUserId == undefined)
            {
               userId = -1;
            }
            else
            {
               userId = int(gMainFrame.clientInfo.dbUserId);
            }
            if(userId > 0)
            {
               if(throttled && userId % gMainFrame.clientInfo.sbTrackerModulator != 0)
               {
                  return;
               }
            }
            currTime = Math.floor(new Date().valueOf() / 1000 + _timeOffset);
            if(gMainFrame.clientInfo.sessionId == undefined && _isFromLogin)
            {
               gMainFrame.clientInfo.sessionId = Math.floor(Math.random() * (int.MAX_VALUE + 1));
            }
            _trackingObjects[type].push(new URIObj(pageURI,currTime,_isFromLogin,type,_trackingObjects[type].length,throttled));
         }
      }
      
      public static function handleErrorTracking(userId:int, time:int, order:int, duration:int, sessionId:Number, uri:String, uriParam:String, pop:int, value:int) : void
      {
         var tempSessionId:Number = Number(gMainFrame.clientInfo.sessionId);
         if(gMainFrame.clientInfo.sessionId == undefined)
         {
            tempSessionId = Math.round(Math.random() * (int.MAX_VALUE + 1));
         }
         if(gMainFrame.clientInfo.dbUserId == undefined)
         {
            gMainFrame.clientInfo.dbUserId = userId;
         }
         var customFields:Object = {
            "userId":(gMainFrame.clientInfo.dbUserId == undefined ? userId : null),
            "order":order,
            "duration":(duration == -1 ? null : duration),
            "sessionId":(sessionId == -1 ? tempSessionId : null)
         };
         _trackingObjects[TYPE_ERROR].push(new URIObj(uri + "#" + uriParam + "#" + pop + "#" + value,time == -1 ? Math.floor(new Date().valueOf() / 1000 + _timeOffset) : time,_isFromLogin,TYPE_ERROR,_trackingObjects[TYPE_ERROR].length,false,customFields));
         onBatchTimer(null);
      }
      
      public static function handleOnKickOrLogout() : void
      {
         if(_isExternalAvailable && _pageView != null)
         {
            ExternalInterface.call("handleLogout",_pageView);
         }
      }
      
      public static function push(type:int = 0) : void
      {
         var currTrackingObjects:Array = null;
         var trackingObject:Object = null;
         if(Boolean(_pageStack))
         {
            currTrackingObjects = _trackingObjects[type];
            if(currTrackingObjects.length > 0)
            {
               trackingObject = currTrackingObjects[currTrackingObjects.length - 1].trackingObject;
               _pageStack.push(trackingObject.uri + "#" + trackingObject.uriParams + "#pop#" + trackingObject.value);
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
      
      public static function flush(bPopFirst:Boolean = false) : void
      {
         if(Boolean(_pageStack) && Boolean(_pageStack.length))
         {
            if(bPopFirst)
            {
               trackPageview(_pageStack[0]);
            }
            _pageStack = [];
         }
      }
      
      public static function completeLastTrackingBatch(callback:Function) : void
      {
         _lastBatchCallback = callback;
         if(Boolean(_batchTimer))
         {
            _batchTimer.stop();
            if(Boolean(_socket))
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
      
      public static function getLastDuration(type:int) : Number
      {
         return _lastestDuration[type];
      }
      
      public static function setLastDuration(type:int, duration:Number) : void
      {
         _lastestDuration[type] = duration;
      }
      
      public static function getLastTimestamp(type:int) : Number
      {
         return _latestTrackTimeStamp[type];
      }
      
      public static function setLastTimestamp(type:int, timeStamp:Number) : void
      {
         _latestTrackTimeStamp[type] = timeStamp;
      }
      
      public static function getnextURIObjByType(index:int, type:int) : URIObj
      {
         var trackingArray:Array = _trackingObjects[type];
         if(trackingArray.length > 0 && trackingArray.length > index + 1)
         {
            return trackingArray[index + 1];
         }
         return null;
      }
      
      public static function getPreviousURIObjByType(index:int, type:int) : URIObj
      {
         var trackingArray:Array = _trackingObjects[type];
         if(trackingArray.length > 0 && trackingArray.length > index - 1)
         {
            return trackingArray[index - 1];
         }
         return null;
      }
      
      private static function findLatestTrackedURIObjByThrottleType(trackingObjects:Array, throttle:Boolean) : URIObj
      {
         var i:int = 0;
         if(Boolean(trackingObjects))
         {
            for(i = trackingObjects.length - 1; i >= 0; i--)
            {
               if(trackingObjects[i].throttled == throttle)
               {
                  return trackingObjects[i];
               }
            }
         }
         return null;
      }
      
      private static function onBatchTimer(t:TimerEvent) : void
      {
         if(Boolean(_socket))
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
      
      private static function setupPageView(updateLastItem:Boolean = false) : void
      {
         var myTrackString:String = null;
         var trackType:int = 0;
         var currUri:URIObj = null;
         var i:int = 0;
         var type:String = null;
         var currUriObjects:Array = null;
         var track:Boolean = false;
         if(_pageView == null)
         {
            myTrackString = "";
            for(type in _trackingObjects)
            {
               trackType = int(type);
               currUriObjects = _trackingObjects[trackType];
               if(currUriObjects.length > 0)
               {
                  if(gMainFrame.clientInfo.sessionId != undefined)
                  {
                     for(i = 0; i < currUriObjects.length; i++)
                     {
                        currUri = currUriObjects[i];
                        if(currUri.throttled)
                        {
                           if(!currUri.isFromLogin)
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
                        myTrackString += currUri.pageView;
                     }
                     if(updateLastItem)
                     {
                        if(currUri.throttled)
                        {
                           if(!currUri.isFromLogin)
                           {
                              if(gMainFrame.clientInfo.dbUserId % gMainFrame.clientInfo.sbTrackerModulator != 0)
                              {
                                 track = false;
                              }
                              else
                              {
                                 track = true;
                              }
                           }
                           else if(gMainFrame.clientInfo.sessionId % gMainFrame.clientInfo.sbTrackerModulator != 0)
                           {
                              track = false;
                           }
                           else
                           {
                              track = true;
                           }
                        }
                        else
                        {
                           track = true;
                        }
                        if(track)
                        {
                           myTrackString += currUri.ownPageView;
                        }
                        _trackingObjects[trackType] = [];
                        currUriObjects = [];
                     }
                     else
                     {
                        _trackingObjects[trackType].splice(0,currUriObjects.length - 1);
                        currUriObjects.splice(0,currUriObjects.length - 1);
                        currUri.index = 0;
                     }
                  }
               }
            }
            if(myTrackString != "")
            {
               _pageView = myTrackString;
            }
         }
      }
      
      private static function closeHandler(event:Event) : void
      {
         _socket.close();
      }
      
      private static function connectHandler(event:Event) : void
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
      
      private static function dataHandler(event:DataEvent) : void
      {
      }
      
      private static function ioErrorHandler(event:IOErrorEvent) : void
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
      
      private static function securityErrorHandler(event:SecurityErrorEvent) : void
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
         if(Boolean(_batchTimer))
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

