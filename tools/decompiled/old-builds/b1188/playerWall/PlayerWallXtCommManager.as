package playerWall
{
   import com.adobe.serialization.json.JSON;
   import com.sbi.client.SFEvent;
   import com.sbi.debug.DebugUtility;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLRequestHeader;
   import flash.net.URLRequestMethod;
   import gui.BuddyManager;
   import localization.LocalizationManager;
   
   public class PlayerWallXtCommManager
   {
      
      private static var _requestor:URLLoader;
      
      private static var _deleteResponseCallback:Function;
      
      private static var _getResponseCallback:Function;
      
      private static var _putResponseCallback:Function;
      
      private static var _setSettingsResponseCallback:Function;
      
      private static var _isFromHudTimer:Boolean;
      
      private static var _wallTokenCallback:Function;
      
      private static var _wallTokenPassback:Object;
      
      private static var _setSettingsId:int;
      
      private static var _isProcessingRequest:Boolean;
      
      private static var _currCommand:String;
      
      private static var _checkResponseCallback:Function;
      
      private static var _currentRequestUsername:String;
      
      private static var _messageToPost:PostMessage;
      
      private static var _currMessageuuid:String;
      
      private static var _tokenFailures:int;
      
      private static const PLAYER_WALL_URL:String = "https://playerwall.smartbombinteractive.com:443/wall/";
      
      public function PlayerWallXtCommManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _requestor = new URLLoader();
      }
      
      public static function destroy() : void
      {
      }
      
      public static function sendWallTokenRequest(param1:String, param2:Function = null, param3:Object = null, param4:Boolean = false) : void
      {
         if(_tokenFailures < 2)
         {
            if(param4)
            {
               ++_tokenFailures;
            }
            _wallTokenCallback = param2;
            _wallTokenPassback = param3;
            gMainFrame.server.setXtObject_Str("wt",[param1]);
         }
         else
         {
            PlayerWallManager.closeOpenPlayerWallDueToTokenFailures();
            _tokenFailures = 0;
         }
      }
      
      public static function sendWallSettingsRequest(param1:int, param2:Function) : void
      {
         _setSettingsResponseCallback = param2;
         _setSettingsId = param1;
         gMainFrame.server.setXtObject_Str("ws",[param1]);
      }
      
      public static function handleXtReply(param1:SFEvent) : void
      {
         if(!param1.status)
         {
            DebugUtility.debugTrace("ERROR: PlayerWallXtCommManager handleXtReply was called with bad evt.status:" + param1.status);
            return;
         }
         var _loc2_:Array = param1.obj;
         switch(_loc2_[0])
         {
            case "wt":
               PlayerWallManager.handleTokenResponse(_loc2_);
               if(_wallTokenCallback != null)
               {
                  if(_wallTokenPassback != null)
                  {
                     _wallTokenCallback(_wallTokenPassback,_loc2_[2] == "1");
                     _wallTokenPassback = null;
                  }
                  else
                  {
                     _wallTokenCallback(_loc2_[2] == "1");
                  }
                  _wallTokenCallback = null;
               }
               break;
            case "ws":
               PlayerWallManager.onPrivacyResponse(_loc2_[2] == "1",_setSettingsId);
               if(_setSettingsResponseCallback != null)
               {
                  _setSettingsResponseCallback(_loc2_[2] == "1",_setSettingsId);
                  _setSettingsResponseCallback = null;
               }
         }
      }
      
      public static function sendCheckPlayerWall(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc4_:Object = PlayerWallManager.tokenMap[param1];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _currentRequestUsername = param1;
         _checkResponseCallback = param2;
         _isFromHudTimer = param3;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"CHK",
               "t":_loc5_
            });
         }
         else
         {
            checkResponse(null);
         }
      }
      
      public static function sendPutToPlayerWall(param1:String, param2:PostMessage, param3:Function) : void
      {
         var _loc4_:Object = PlayerWallManager.tokenMap[param1];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _messageToPost = param2;
         _currentRequestUsername = param1;
         _putResponseCallback = param3;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"PUT",
               "t":_loc5_,
               "sid":param2.senderDbId,
               "s":param2.patternId,
               "c":param2.colorId,
               "m":param2.message,
               "ai":param2.avtDefId,
               "ac":param2.avtColors,
               "ae":param2.avtEyeDefId,
               "ap":param2.avtPatternDefId,
               "aci":param2.avtCustomId,
               "l":param2.localizationId
            });
         }
         else
         {
            addResponse(null);
         }
      }
      
      public static function sendDeleteFromPlayerWall(param1:String, param2:String, param3:Function) : void
      {
         var _loc4_:Object = PlayerWallManager.tokenMap[param1];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _currentRequestUsername = param1;
         _currMessageuuid = param2;
         _deleteResponseCallback = param3;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"DEL",
               "t":_loc5_,
               "x":param2
            });
         }
         else
         {
            deleteResponse(null);
         }
      }
      
      public static function sendGetFromPlayerWall(param1:String, param2:Function, param3:Boolean = false) : void
      {
         var _loc4_:Object = PlayerWallManager.tokenMap[param1];
         var _loc5_:String = null;
         if(_loc4_)
         {
            _loc5_ = _loc4_.token;
         }
         _currentRequestUsername = param1;
         _getResponseCallback = param2;
         _isFromHudTimer = param3;
         if(_loc5_)
         {
            sendServiceRequest({
               "cmd":"GET",
               "t":_loc5_
            });
         }
         else
         {
            getResponse(null);
         }
      }
      
      public static function ContinueCommandAfterTokenRequest(param1:Object, param2:Boolean) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(Boolean(param1) && param2)
         {
            _loc3_ = param1.cmd;
            _loc4_ = param1.username;
            switch(_loc3_)
            {
               case "CHK":
                  sendCheckPlayerWall(_loc4_,param1.callback,param1.isFromHudTimer);
                  break;
               case "PUT":
                  sendPutToPlayerWall(_loc4_,param1.msgToPost,param1.callback);
                  break;
               case "DEL":
                  sendDeleteFromPlayerWall(_loc4_,param1.messageuuid,param1.callback);
                  break;
               case "GET":
                  sendGetFromPlayerWall(_loc4_,param1.callback,param1.isFromHudTimer);
            }
         }
         else
         {
            PlayerWallManager.closeOpenPlayerWallDueToTokenFailures();
         }
      }
      
      private static function checkResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onCheckResponse(_loc2_,param1,_currentRequestUsername,_isFromHudTimer);
         if(_checkResponseCallback != null)
         {
            _checkResponseCallback(_loc2_,param1);
         }
      }
      
      private static function deleteResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         if(_deleteResponseCallback != null)
         {
            _deleteResponseCallback(_loc2_,_currMessageuuid,param1.e);
            _deleteResponseCallback = null;
         }
      }
      
      private static function addResponse(param1:Object) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         var _loc3_:int = param1.cs != null ? int(param1.cs) : 0;
         if(_loc2_)
         {
            _messageToPost.msgId = param1.x;
            _messageToPost.postTime = param1.t;
         }
         if(_putResponseCallback != null)
         {
            _putResponseCallback(_loc2_,_messageToPost,_loc3_,param1.e);
            _putResponseCallback = null;
         }
      }
      
      public static function getResponse(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:String = null;
         var _loc8_:Boolean = false;
         var _loc9_:Array = null;
         var _loc10_:int = 0;
         var _loc2_:Array = [];
         var _loc6_:Boolean = param1 != null ? Boolean(param1.s) : false;
         if(_loc6_)
         {
            _loc9_ = param1.r;
            _loc10_ = 0;
            while(_loc10_ < _loc9_.length)
            {
               _loc3_ = _loc9_[_loc10_];
               if(_loc3_)
               {
                  _loc7_ = _loc3_.um == 1 ? _loc3_.un : LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
                  _loc8_ = _loc3_.u == gMainFrame.userInfo.myUUID ? true : BuddyManager.isBuddy(_loc3_.un);
                  _loc2_.push(new PostMessage(_loc3_.x,_loc3_.m,_loc3_.uid,_loc3_.un,_loc7_,_loc3_.s,_loc3_.c,_loc3_.t,_loc8_,_loc3_.ai,_loc3_.ac,_loc3_.ae,_loc3_.ap,_loc3_.l,_loc3_.aci));
               }
               else
               {
                  _loc5_++;
               }
               _loc10_++;
            }
            PlayerWallManager.updateTimestamp(_currentRequestUsername,param1.t);
         }
         PlayerWallManager.onGetResponse(_loc6_,_loc2_,_isFromHudTimer,_currentRequestUsername,param1.e);
         if(_getResponseCallback != null)
         {
            _getResponseCallback(_loc6_,_loc2_);
            _getResponseCallback = null;
         }
      }
      
      private static function setSettingsResponse(param1:Array) : void
      {
         var _loc2_:Boolean = param1 != null ? Boolean(param1.s) : false;
         PlayerWallManager.onPrivacyResponse(_loc2_,_setSettingsId);
         if(_setSettingsResponseCallback != null)
         {
            _setSettingsResponseCallback(_loc2_,_setSettingsId);
            _setSettingsResponseCallback = null;
         }
      }
      
      public static function sendServiceRequest(... rest) : void
      {
         var _loc2_:URLRequestHeader = null;
         var _loc3_:String = null;
         var _loc4_:URLRequest = null;
         if(!_isProcessingRequest)
         {
            _isProcessingRequest = true;
            _currCommand = rest[0].cmd;
            _loc2_ = new URLRequestHeader("Content-type","application/json");
            _loc3_ = com.adobe.serialization.json.JSON.encode(rest[0]);
            _loc4_ = new URLRequest(PLAYER_WALL_URL);
            _loc4_.method = URLRequestMethod.POST;
            _loc4_.requestHeaders.push(_loc2_);
            _loc4_.data = _loc3_;
            _requestor = new URLLoader();
            _requestor.addEventListener(Event.COMPLETE,httpRequestComplete);
            _requestor.addEventListener(IOErrorEvent.IO_ERROR,httpRequestError);
            _requestor.addEventListener(SecurityErrorEvent.SECURITY_ERROR,httpRequestError);
            _requestor.load(_loc4_);
         }
      }
      
      private static function httpRequestComplete(param1:Event) : void
      {
         _tokenFailures = 0;
         _isProcessingRequest = false;
         var _loc2_:Object = param1.target.data != "" ? com.adobe.serialization.json.JSON.decode(param1.target.data) : null;
         switch(_currCommand)
         {
            case "CHK":
               checkResponse(_loc2_);
               break;
            case "PUT":
               addResponse(_loc2_);
               break;
            case "DEL":
               deleteResponse(_loc2_);
               break;
            case "GET":
               getResponse(_loc2_);
         }
      }
      
      private static function httpRequestError(param1:ErrorEvent) : void
      {
         _isProcessingRequest = false;
      }
   }
}

