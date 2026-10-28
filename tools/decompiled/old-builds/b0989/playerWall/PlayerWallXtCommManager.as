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
      
      public static function sendPostDeleteRequest(param1:String, param2:Function = null) : void
      {
         if(canTryToConnect(sendPostDeleteRequest,param1,param2))
         {
            if(param2 != null)
            {
               _deleteResponseCallback = param2;
            }
            _currResponseFunction = deleteResponse;
            _cmd = "D";
            _stringToSend = param1;
            setupConnection();
         }
      }
      
      public static function sendPostGetRequest(param1:String, param2:Function = null, param3:Boolean = false) : void
      {
         if(canTryToConnect(sendPostGetRequest,param1,param2,param3))
         {
            if(param2 != null)
            {
               _getResponseCallback = param2;
            }
            _cmd = "G";
            _currResponseFunction = getResponse;
            _stringToSend = param1;
            _isFromHudTimer = param3;
            setupConnection();
         }
      }
      
      public static function sendPostAddRequest(param1:String, param2:Function = null) : void
      {
         if(canTryToConnect(sendPostAddRequest,param1,param2))
         {
            if(param2 != null)
            {
               _addResponseCallback = param2;
            }
            _cmd = "A";
            _currResponseFunction = addResponse;
            _stringToSend = param1;
            setupConnection();
         }
      }
      
      public static function sendStatusSetRequest(param1:String, param2:Function = null) : void
      {
         if(canTryToConnect(sendStatusSetRequest,param1,param2))
         {
            if(param2 != null)
            {
               _setStatusResponseCallback = param2;
            }
            _cmd = "SC";
            _currResponseFunction = setStatusResponse;
            _stringToSend = param1;
            setupConnection();
         }
      }
      
      public static function sendStatusGetRequest(param1:String, param2:Function = null) : void
      {
         if(canTryToConnect(sendStatusGetRequest,param1,param2))
         {
            if(param2 != null)
            {
               _getStatusResponseCallback = param2;
            }
            _cmd = "SG";
            _currResponseFunction = getStatusResponse;
            _stringToSend = param1;
            setupConnection();
         }
      }
      
      public static function sendPrivacyGetRequest(param1:String, param2:Function = null) : void
      {
         if(canTryToConnect(sendPrivacyGetRequest,param1,param2))
         {
            if(param2 != null)
            {
               _getPrivacyResponseCallback = param2;
            }
            _cmd = "OG";
            _currResponseFunction = getPrivacyResponse;
            _stringToSend = param1;
            setupConnection();
         }
      }
      
      public static function sendPrivacySetRequest(param1:String, param2:Function = null) : void
      {
         if(canTryToConnect(sendPrivacySetRequest,param1,param2))
         {
            if(param2 != null)
            {
               _setPrivacyResponseCallback = param2;
            }
            _cmd = "OC";
            _currResponseFunction = setPrivacyResponse;
            _stringToSend = param1;
            setupConnection();
         }
      }
      
      private static function deleteResponse(param1:String) : void
      {
         var _loc3_:Array = null;
         var _loc2_:Boolean = param1 == "1" ? true : false;
         if(_deleteResponseCallback != null)
         {
            _loc3_ = _stringToSend.split("\n");
            _deleteResponseCallback(_loc3_[0],_loc3_[1],_loc2_);
            _deleteResponseCallback = null;
         }
      }
      
      private static function addResponse(param1:Array) : void
      {
         var _loc2_:Array = null;
         if(param1[1])
         {
            _loc2_ = param1[1].split("|");
         }
         else
         {
            _loc2_ = [];
         }
         var _loc3_:Boolean = param1[0] == "1" ? true : false;
         var _loc4_:int = -1;
         if(!_loc3_)
         {
            if(_loc2_[0] != null)
            {
               _loc4_ = int(_loc2_[0]);
            }
            else
            {
               _loc4_ = int(param1[0]);
            }
         }
         if(_addResponseCallback != null)
         {
            _addResponseCallback(_loc3_,_loc2_[1],Number(_loc2_[2]),_loc4_);
            _addResponseCallback = null;
         }
      }
      
      private static function getResponse(param1:Array) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:Array = [];
         var _loc6_:Boolean = param1[0] == "1" ? true : false;
         var _loc7_:int = 0;
         while(_loc7_ < param1.length)
         {
            _loc3_ = param1[_loc7_].split("|");
            if(Boolean(_loc3_) && _loc3_.length > 1)
            {
               _loc2_.push({
                  "msgId":_loc3_[0],
                  "message":_loc3_[3],
                  "senderUserName":_loc3_[2],
                  "iconId":1714,
                  "patternId":int(_loc3_[4]),
                  "color":_loc3_[5],
                  "postTime":Number(_loc3_[1]),
                  "isBuddy":false
               });
            }
            else
            {
               _loc5_++;
            }
            _loc7_++;
         }
         PlayerWallManager.onGetResponse(_loc6_,_loc2_,_isFromHudTimer);
         if(_getResponseCallback != null)
         {
            _getResponseCallback(_loc6_,_loc2_);
            _getResponseCallback = null;
         }
      }
      
      private static function setStatusResponse(param1:Array) : void
      {
         var _loc2_:Boolean = param1[0] == "1" ? true : false;
         var _loc3_:int = -1;
         var _loc4_:Array = _stringToSend.split("\n");
         if(!_loc2_)
         {
            _loc3_ = int(param1[0]);
         }
         PlayerWallManager.onStatusResponse(_loc2_,_loc4_[0],_loc4_[1]);
         if(_setStatusResponseCallback != null)
         {
            _setStatusResponseCallback(_loc2_,_loc3_);
            _setStatusResponseCallback = null;
         }
      }
      
      private static function getStatusResponse(param1:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:String = null;
         var _loc2_:Boolean = param1[0] == "1" ? true : false;
         var _loc3_:String = "";
         if(param1[1] != null)
         {
            _loc3_ = param1[1];
            _loc4_ = 1714;
            _loc5_ = "green";
         }
         PlayerWallManager.onStatusResponse(_loc2_,_stringToSend,_loc3_);
         if(_getStatusResponseCallback != null)
         {
            _getStatusResponseCallback(_loc2_,_loc3_,_loc4_,_loc5_);
            _getStatusResponseCallback = null;
         }
      }
      
      private static function getPrivacyResponse(param1:Array) : void
      {
         var _loc2_:Boolean = param1[0] == "1" ? true : false;
         var _loc3_:int = 0;
         if(param1[1] != null)
         {
            _loc3_ = int(param1[1]);
         }
         PlayerWallManager.onPrivacyResponse(_loc2_,_loc3_);
         if(_getPrivacyResponseCallback != null)
         {
            _getPrivacyResponseCallback(_loc2_,_loc3_);
            _getPrivacyResponseCallback = null;
         }
      }
      
      private static function setPrivacyResponse(param1:Array) : void
      {
         var _loc2_:Boolean = param1[0] == "1" ? true : false;
         var _loc3_:int = int(_stringToSend.split("\n")[1]);
         PlayerWallManager.onPrivacyResponse(_loc2_,_loc3_);
         if(_setPrivacyResponseCallback != null)
         {
            _setPrivacyResponseCallback(_loc2_,_loc3_);
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
      
      private static function canTryToConnect(param1:Function, param2:String, param3:Function = null, param4:Boolean = false) : Boolean
      {
         if(_socket.connected)
         {
            if(_waitingRequestFunction == null)
            {
               _waitingRequestFunction = param1;
               _waitingStringToSend = param2;
               _waitingResponseCallback = param3;
               _waitingIsFromHudTimer = param4;
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
      
      private static function onRetryTimer(param1:TimerEvent) : void
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
      
      private static function onConnected(param1:Event) : void
      {
      }
      
      private static function onSocketData(param1:ProgressEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         while(_socket.bytesAvailable > 0)
         {
            _loc4_ = _socket.readUTFBytes(_socket.bytesAvailable);
            _numDataItemsReceived += _loc4_.split("\n").length;
            if(_numDataItemsToReceive == -1)
            {
               _receivedData = _loc4_;
            }
            else
            {
               _receivedData += _loc4_;
            }
         }
         if(_numDataItemsToReceive == -1 || _numDataItemsReceived >= _numDataItemsToReceive)
         {
            _loc2_ = _receivedData.split("\r\n");
            _loc6_ = 0;
            while(_loc6_ < _loc2_.length)
            {
               _loc5_ = _loc2_[_loc6_];
               if(_loc5_ == "SID:")
               {
                  _socket.writeUTFBytes("C:" + _cmd + "\n");
                  DebugUtility.debugTrace("sending command: C:" + _cmd,65280);
                  _socket.flush();
               }
               else if(_loc5_ == "*")
               {
                  _socket.writeUTFBytes(_stringToSend + "\n");
                  DebugUtility.debugTrace("sending string: " + _stringToSend,65280);
                  _socket.flush();
               }
               else if(_loc5_.indexOf("Build") != -1)
               {
                  if(gMainFrame.clientInfo.devMode)
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
               else if(!(_loc5_ == "\r\n" || _loc5_ == ""))
               {
                  if(!isNaN(Number(_loc5_)) && _numDataItemsToReceive == -1)
                  {
                     DebugUtility.debugTrace("number of items to receive = " + int(_loc5_),65280);
                     _numDataItemsToReceive = int(_loc5_);
                     if(_numDataItemsReceived < _numDataItemsToReceive)
                     {
                        break;
                     }
                  }
                  else if(_loc5_ == "**done**")
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
                     _dataToProcess.push(_loc5_);
                     DebugUtility.debugTrace("receiving data pieces: " + _loc5_,65280);
                  }
               }
               _loc6_++;
            }
         }
      }
      
      private static function onIOError(param1:IOErrorEvent) : void
      {
         DebugUtility.debugTrace("IO error",65280);
         _socket.close();
      }
      
      private static function onSecurityError(param1:SecurityErrorEvent) : void
      {
         DebugUtility.debugTrace("Security error",65280);
         _socket.close();
      }
   }
}

