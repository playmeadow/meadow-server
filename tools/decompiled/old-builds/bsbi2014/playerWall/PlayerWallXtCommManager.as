package playerWall
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.Socket;
   import flash.utils.Timer;
   import gui.GuiManager;
   
   public class PlayerWallXtCommManager
   {
      
      private static var _deleteResponseCallback:Function;
      
      private static var _getResponseCallback:Function;
      
      private static var _addResponseCallback:Function;
      
      private static var _setStatusResponseCallback:Function;
      
      private static var _getStatusResponseCallback:Function;
      
      private static var _socket:Socket;
      
      private static var _stringToSend:String;
      
      private static var _cmd:String;
      
      private static var _currResponseFunction:Function;
      
      private static var _numDataItemsToReceive:int;
      
      private static var _numDataItemsReceived:int;
      
      private static var _receivedData:String;
      
      private static var _dataToProcess:Array;
      
      private static var _setPrivacyResponseCallback:Function;
      
      private static var _getPrivacyResponseCallback:Function;
      
      private static var _isFromHudTimer:Boolean;
      
      private static var _retryTimer:Timer;
      
      private static var _waitingStringToSend:String;
      
      private static var _waitingResponseCallback:Function;
      
      private static var _waitingIsFromHudTimer:Boolean;
      
      private static var _waitingRequestFunction:Function;
      
      public function PlayerWallXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _socket = new Socket();
         _socket.addEventListener(Event.CONNECT,onConnected,false,0,true);
         _socket.addEventListener(IOErrorEvent.IO_ERROR,onIOError,false,0,true);
         _socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onSecurityError,false,0,true);
         _socket.addEventListener(ProgressEvent.SOCKET_DATA,onSocketData,false,0,true);
         _retryTimer = new Timer(50);
         _retryTimer.addEventListener(TimerEvent.TIMER,onRetryTimer,false,0,true);
         _numDataItemsToReceive = -1;
         _dataToProcess = [];
      }
      
      public static function isSocketOpen() : Boolean
      {
         return _socket.connected;
      }
      
      public static function sendPostDeleteRequest(stringToSend:String, responseCallback:Function = null) : void
      {
         if(canTryToConnect(sendPostDeleteRequest,stringToSend,responseCallback))
         {
            if(responseCallback != null)
            {
               _deleteResponseCallback = responseCallback;
            }
            _currResponseFunction = deleteResponse;
            _cmd = "D";
            _stringToSend = stringToSend;
            setupConnection();
         }
      }
      
      public static function sendPostGetRequest(userName:String, responseCallback:Function = null, isFromHudTimer:Boolean = false) : void
      {
         if(canTryToConnect(sendPostGetRequest,userName,responseCallback,isFromHudTimer))
         {
            if(responseCallback != null)
            {
               _getResponseCallback = responseCallback;
            }
            _cmd = "G";
            _currResponseFunction = getResponse;
            _stringToSend = userName;
            _isFromHudTimer = isFromHudTimer;
            setupConnection();
         }
      }
      
      public static function sendPostAddRequest(stringToSend:String, responseCallback:Function = null) : void
      {
         if(canTryToConnect(sendPostAddRequest,stringToSend,responseCallback))
         {
            if(responseCallback != null)
            {
               _addResponseCallback = responseCallback;
            }
            _cmd = "A";
            _currResponseFunction = addResponse;
            _stringToSend = stringToSend;
            setupConnection();
         }
      }
      
      public static function sendStatusSetRequest(stringToSend:String, responseCallback:Function = null) : void
      {
         if(canTryToConnect(sendStatusSetRequest,stringToSend,responseCallback))
         {
            if(responseCallback != null)
            {
               _setStatusResponseCallback = responseCallback;
            }
            _cmd = "SC";
            _currResponseFunction = setStatusResponse;
            _stringToSend = stringToSend;
            setupConnection();
         }
      }
      
      public static function sendStatusGetRequest(stringToSend:String, responseCallback:Function = null) : void
      {
         if(canTryToConnect(sendStatusGetRequest,stringToSend,responseCallback))
         {
            if(responseCallback != null)
            {
               _getStatusResponseCallback = responseCallback;
            }
            _cmd = "SG";
            _currResponseFunction = getStatusResponse;
            _stringToSend = stringToSend;
            setupConnection();
         }
      }
      
      public static function sendPrivacyGetRequest(stringToSend:String, responseCallback:Function = null) : void
      {
         if(canTryToConnect(sendPrivacyGetRequest,stringToSend,responseCallback))
         {
            if(responseCallback != null)
            {
               _getPrivacyResponseCallback = responseCallback;
            }
            _cmd = "OG";
            _currResponseFunction = getPrivacyResponse;
            _stringToSend = stringToSend;
            setupConnection();
         }
      }
      
      public static function sendPrivacySetRequest(stringToSend:String, responseCallback:Function = null) : void
      {
         if(canTryToConnect(sendPrivacySetRequest,stringToSend,responseCallback))
         {
            if(responseCallback != null)
            {
               _setPrivacyResponseCallback = responseCallback;
            }
            _cmd = "OC";
            _currResponseFunction = setPrivacyResponse;
            _stringToSend = stringToSend;
            setupConnection();
         }
      }
      
      private static function deleteResponse(data:String) : void
      {
         var splitStringToSend:Array = null;
         var status:Boolean = data == "1" ? true : false;
         if(_deleteResponseCallback != null)
         {
            splitStringToSend = _stringToSend.split("\n");
            _deleteResponseCallback(splitStringToSend[0],splitStringToSend[1],status);
            _deleteResponseCallback = null;
         }
      }
      
      private static function addResponse(data:Array) : void
      {
         var splitData:Array = null;
         if(Boolean(data[1]))
         {
            splitData = data[1].split("|");
         }
         else
         {
            splitData = [];
         }
         var status:Boolean = data[0] == "1" ? true : false;
         var severity:int = -1;
         if(!status)
         {
            if(splitData[0] != null)
            {
               severity = int(splitData[0]);
            }
            else
            {
               severity = int(data[0]);
            }
         }
         if(_addResponseCallback != null)
         {
            _addResponseCallback(status,splitData[1],Number(splitData[2]),severity);
            _addResponseCallback = null;
         }
      }
      
      private static function getResponse(data:Array) : void
      {
         var singlePost:Array = null;
         var unreadCount:int = 0;
         var numSkipped:int = 0;
         var finalData:Array = [];
         var status:Boolean = data[0] == "1" ? true : false;
         for(var i:int = 0; i < data.length; i++)
         {
            singlePost = data[i].split("|");
            if(Boolean(singlePost) && singlePost.length > 1)
            {
               finalData.push({
                  "msgId":singlePost[0],
                  "message":singlePost[3],
                  "senderUserName":singlePost[2],
                  "iconId":1714,
                  "patternId":int(singlePost[4]),
                  "color":singlePost[5],
                  "postTime":Number(singlePost[1]),
                  "isBuddy":false
               });
            }
            else
            {
               numSkipped++;
            }
         }
         PlayerWallManager.onGetResponse(status,finalData,_isFromHudTimer);
         if(_getResponseCallback != null)
         {
            _getResponseCallback(status,finalData);
            _getResponseCallback = null;
         }
      }
      
      private static function setStatusResponse(data:Array) : void
      {
         var status:Boolean = data[0] == "1" ? true : false;
         var severity:int = -1;
         var splitString:Array = _stringToSend.split("\n");
         if(!status)
         {
            severity = int(data[0]);
         }
         PlayerWallManager.onStatusResponse(status,splitString[0],splitString[1]);
         if(_setStatusResponseCallback != null)
         {
            _setStatusResponseCallback(status,severity);
            _setStatusResponseCallback = null;
         }
      }
      
      private static function getStatusResponse(data:Array) : void
      {
         var currIconId:int = 0;
         var currColor:String = null;
         var status:Boolean = data[0] == "1" ? true : false;
         var newStatusString:String = "";
         if(data[1] != null)
         {
            newStatusString = data[1];
            currIconId = 1714;
            currColor = "green";
         }
         PlayerWallManager.onStatusResponse(status,_stringToSend,newStatusString);
         if(_getStatusResponseCallback != null)
         {
            _getStatusResponseCallback(status,newStatusString,currIconId,currColor);
            _getStatusResponseCallback = null;
         }
      }
      
      private static function getPrivacyResponse(data:Array) : void
      {
         var status:Boolean = data[0] == "1" ? true : false;
         var newPrivacyId:int = 0;
         if(data[1] != null)
         {
            newPrivacyId = int(data[1]);
         }
         PlayerWallManager.onPrivacyResponse(status,newPrivacyId);
         if(_getPrivacyResponseCallback != null)
         {
            _getPrivacyResponseCallback(status,newPrivacyId);
            _getPrivacyResponseCallback = null;
         }
      }
      
      private static function setPrivacyResponse(data:Array) : void
      {
         var status:Boolean = data[0] == "1" ? true : false;
         var privacyId:int = int(_stringToSend.split("\n")[1]);
         PlayerWallManager.onPrivacyResponse(status,privacyId);
         if(_setPrivacyResponseCallback != null)
         {
            _setPrivacyResponseCallback(status,privacyId);
            _setPrivacyResponseCallback = null;
         }
      }
      
      private static function setupConnection() : void
      {
         if(_socket.connected)
         {
            new SBOkPopup(GuiManager.guiLayer,"Trying to setup a connection when one is already running. Should not be happening");
         }
         else
         {
            _socket.connect("playerwall.smartbombinteractive.com",6000);
         }
      }
      
      private static function canTryToConnect(requestFunction:Function, stringToSend:String, responseCallback:Function = null, isFromHudTimer:Boolean = false) : Boolean
      {
         if(_socket.connected)
         {
            if(_waitingRequestFunction == null)
            {
               _waitingRequestFunction = requestFunction;
               _waitingStringToSend = stringToSend;
               _waitingResponseCallback = responseCallback;
               _waitingIsFromHudTimer = isFromHudTimer;
               _retryTimer.start();
            }
            else
            {
               new SBOkPopup(GuiManager.guiLayer,"We are setting up a retry but a current retry is already running");
            }
            return false;
         }
         return true;
      }
      
      private static function onRetryTimer(evt:TimerEvent) : void
      {
         _retryTimer.reset();
         if(_socket.connected)
         {
            DebugUtility.debugTrace("Still retrying...",65280);
            _retryTimer.start();
         }
         else
         {
            _numDataItemsToReceive = -1;
            if(_waitingIsFromHudTimer)
            {
               _waitingRequestFunction(_waitingStringToSend,_waitingResponseCallback,_waitingIsFromHudTimer);
            }
            else
            {
               _waitingRequestFunction(_waitingStringToSend,_waitingResponseCallback);
            }
            _waitingRequestFunction = null;
            _waitingStringToSend = "";
            _waitingResponseCallback = null;
            _waitingIsFromHudTimer = false;
         }
      }
      
      private static function onConnected(evt:Event) : void
      {
      }
      
      private static function onSocketData(evt:ProgressEvent) : void
      {
         var splitData:Array = null;
         var receivedSplitDataLength:int = 0;
         var currData:String = null;
         var newData:String = null;
         var i:int = 0;
         while(_socket.bytesAvailable > 0)
         {
            currData = _socket.readUTFBytes(_socket.bytesAvailable);
            _numDataItemsReceived += currData.split("\n").length;
            if(_numDataItemsToReceive == -1)
            {
               _receivedData = currData;
            }
            else
            {
               _receivedData += currData;
            }
         }
         if(_numDataItemsToReceive == -1 || _numDataItemsReceived >= _numDataItemsToReceive)
         {
            splitData = _receivedData.split("\r\n");
            for(i = 0; i < splitData.length; i++)
            {
               newData = splitData[i];
               if(newData == "SID:")
               {
                  _socket.writeUTFBytes("C:" + _cmd + "\n");
                  DebugUtility.debugTrace("sending command: C:" + _cmd,65280);
                  _socket.flush();
               }
               else if(newData == "*")
               {
                  _socket.writeUTFBytes(_stringToSend + "\n");
                  DebugUtility.debugTrace("sending string: " + _stringToSend,65280);
                  _socket.flush();
               }
               else if(newData.indexOf("Build") != -1)
               {
                  if(Boolean(gMainFrame.clientInfo.devMode))
                  {
                     _socket.writeUTFBytes("A:" + gMainFrame.userInfo.myUserName + "," + gMainFrame.userInfo.myUserName + "," + gMainFrame.server.serverIp + "\n");
                     DebugUtility.debugTrace("sending command: A:" + gMainFrame.userInfo.myUserName + "," + gMainFrame.userInfo.myUserName + "," + gMainFrame.server.serverIp,65280);
                  }
                  else
                  {
                     _socket.writeUTFBytes("A:" + gMainFrame.clientInfo.authToken + "," + gMainFrame.userInfo.myUserName + "," + gMainFrame.server.serverIp + "\n");
                     DebugUtility.debugTrace("sending command: A:" + gMainFrame.clientInfo.authToken + "," + gMainFrame.userInfo.myUserName + "," + gMainFrame.server.serverIp,65280);
                  }
                  _socket.flush();
               }
               else if(!(newData == "\r\n" || newData == ""))
               {
                  if(!isNaN(Number(newData)) && _numDataItemsToReceive == -1)
                  {
                     DebugUtility.debugTrace("number of items to receive = " + int(newData),65280);
                     _numDataItemsToReceive = int(newData);
                     if(_numDataItemsReceived < _numDataItemsToReceive)
                     {
                        break;
                     }
                  }
                  else if(newData == "**done**")
                  {
                     DebugUtility.debugTrace("receiving **done**",65280);
                     _socket.close();
                     _numDataItemsToReceive = -1;
                     _numDataItemsReceived = 0;
                     _receivedData = "";
                     _currResponseFunction(_dataToProcess);
                     _dataToProcess = [];
                  }
                  else
                  {
                     _dataToProcess.push(newData);
                     DebugUtility.debugTrace("receiving data pieces: " + newData,65280);
                  }
               }
            }
         }
      }
      
      private static function onIOError(evt:IOErrorEvent) : void
      {
         DebugUtility.debugTrace("IO error",65280);
         _socket.close();
      }
      
      private static function onSecurityError(evt:SecurityErrorEvent) : void
      {
         DebugUtility.debugTrace("Security error",65280);
         _socket.close();
      }
   }
}

