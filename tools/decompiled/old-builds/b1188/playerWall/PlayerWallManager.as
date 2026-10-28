package playerWall
{
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.net.SharedObject;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.GuiManager;
   import localization.LocalizationManager;
   
   public class PlayerWallManager
   {
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _hudWallBtn:MovieClip;
      
      private static var _glowTimer:Timer;
      
      private static var _openWallUpdateTimer:Timer;
      
      private static var _myPlayerWallClosedTimer:Timer;
      
      private static var _unreadCount:int;
      
      private static var _inbox:Array;
      
      private static var _strangerInbox:Array;
      
      private static var _myPlayerWall:PlayerWallGui;
      
      private static var _strangersPlayerWall:PlayerWallGui;
      
      private static var _isFirstTime:Boolean;
      
      private static var _statusText:String;
      
      private static var _currentMessageColorId:int;
      
      private static var _currentMessagePattern:int;
      
      private static var _currentDecorId:int;
      
      private static var _myPrivacyId:int;
      
      private static var _reportedPosts:Array;
      
      public static const PATTERN_MEDIA_ID:int = 3983;
      
      public static var tokenMap:Object = new Object();
      
      public function PlayerWallManager()
      {
         super();
      }
      
      public static function init(param1:MovieClip) : void
      {
         PlayerWallXtCommManager.init();
         _guiLayer = GuiManager.guiLayer;
         _hudWallBtn = param1;
         _unreadCount = 0;
         _isFirstTime = true;
         _hudWallBtn.newPostCount.visible = false;
         _hudWallBtn.newPostCount.postCountTxt.text = "";
         _hudWallBtn.glow.visible = true;
         _glowTimer = new Timer(5000);
         _glowTimer.addEventListener(TimerEvent.TIMER,glowTimerHandler,false,0,true);
         _glowTimer.start();
         _openWallUpdateTimer = new Timer(15000);
         _openWallUpdateTimer.addEventListener(TimerEvent.TIMER,onMessageUpdateTimer,false,0,true);
         _myPlayerWallClosedTimer = new Timer(60000);
         _myPlayerWallClosedTimer.addEventListener(TimerEvent.TIMER,onMessageUpdateTimer,false,0,true);
         _myPlayerWallClosedTimer.start();
         var _loc2_:SharedObject = GuiManager.sharedObj;
         if(Boolean(_loc2_) && Boolean(_loc2_.data))
         {
            _currentMessageColorId = _loc2_.data.msgColor != null ? int(_loc2_.data.msgColor) : 1;
            _currentMessagePattern = _loc2_.data.msgPattern != null ? int(_loc2_.data.msgPattern) : 1;
            _currentDecorId = _loc2_.data.decorId != null ? int(_loc2_.data.decorId) : 9;
            _reportedPosts = _loc2_.data.reportedPosts != null ? _loc2_.data.reportedPosts : [];
         }
         else
         {
            _currentMessageColorId = 1;
            _currentMessagePattern = 1;
            _currentDecorId = 9;
            _reportedPosts = [];
         }
         _inbox = [];
         _hudWallBtn.addEventListener(MouseEvent.MOUSE_DOWN,playerWallBtnDownHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         _openWallUpdateTimer.reset();
         _openWallUpdateTimer = null;
         _myPlayerWallClosedTimer.reset();
         _myPlayerWallClosedTimer = null;
      }
      
      public static function closeOpenPlayerWallDueToTokenFailures() : void
      {
         onMyPlayerWallClose(true);
         onStrangerPlayerWallClose();
         new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22626));
      }
      
      public static function handleTokenResponse(param1:Array) : void
      {
         if(param1[2] == "1")
         {
            tokenMap[param1[4]] = {
               "token":param1[3],
               "time":0
            };
         }
         else
         {
            DarkenManager.showLoadingSpiral(false);
            if(int(param1[2]) == SbiConstants.PLAYER_WALL_TOKEN_LOCKED_FAILURE)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22623));
            }
            else if(int(param1[2]) == SbiConstants.PLAYER_WALL_TOKEN_BUDDIES_FAILURE)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22624));
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
            }
         }
      }
      
      public static function openStrangersPlayerWall(param1:String, param2:Boolean = true) : void
      {
         if(param2)
         {
            if(_strangersPlayerWall)
            {
               _strangersPlayerWall.destroy();
               _strangersPlayerWall = null;
            }
            if(tokenMap[param1] != null)
            {
               _strangersPlayerWall = new PlayerWallGui();
               _strangerInbox = [];
               _strangersPlayerWall.init(_strangerInbox,param1,"",_currentMessagePattern,_currentMessageColorId,_currentDecorId,onStrangerPlayerWallClose);
            }
            else
            {
               PlayerWallXtCommManager.sendWallTokenRequest(param1,openStrangersPlayerWall,param1);
            }
         }
      }
      
      public static function onCheckResponse(param1:Boolean, param2:Object, param3:String, param4:Boolean) : void
      {
         if(param1)
         {
            if(updateTimestamp(param3,param2.t))
            {
               PlayerWallXtCommManager.sendGetFromPlayerWall(param3,null,param4);
            }
            if(!param4)
            {
               _openWallUpdateTimer.start();
            }
            else
            {
               _myPlayerWallClosedTimer.start();
            }
         }
         else if(param2)
         {
            if(param2.e == SbiConstants.PLAYER_WALL_FAILURE_TOKEN)
            {
               PlayerWallXtCommManager.sendWallTokenRequest(param3,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
                  "cmd":"CHK",
                  "userName":param3,
                  "isFromHudTimer":param4
               });
            }
            else if(param2.e == SbiConstants.PLAYER_WALL_FAILURE_UNAVAILABLE)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(22625));
            }
         }
      }
      
      public static function onGetResponse(param1:Boolean, param2:Array, param3:Boolean, param4:String, param5:String = "") : void
      {
         if(param1)
         {
            if(param3)
            {
               if(param2.length > _inbox.length && !isFirstTime)
               {
                  _unreadCount = param2.length - _inbox.length;
                  _hudWallBtn.newPostCount.visible = true;
                  _hudWallBtn.newPostCount.postCountTxt.text = _unreadCount;
                  _hudWallBtn.glow.visible = true;
                  _glowTimer.start();
               }
            }
            else if(_myPlayerWall)
            {
               isFirstTime = false;
               _inbox = param2.concat();
               _myPlayerWall.reloadMessages(_inbox);
            }
            else if(_strangersPlayerWall)
            {
               _strangerInbox = param2.concat();
               _strangersPlayerWall.reloadMessages(_strangerInbox);
            }
            if(!param3)
            {
               _openWallUpdateTimer.start();
            }
            else
            {
               _myPlayerWallClosedTimer.start();
            }
         }
         else if(Boolean(param5) && param5 == SbiConstants.PLAYER_WALL_FAILURE_TOKEN)
         {
            PlayerWallXtCommManager.sendWallTokenRequest(param4,PlayerWallXtCommManager.ContinueCommandAfterTokenRequest,{
               "cmd":"GET",
               "username":param4,
               "isFromHudTimer":param3,
               "callback":null
            });
         }
      }
      
      public static function processMessagePush(param1:PostMessage) : void
      {
         if(_myPlayerWall)
         {
            _inbox.unshift(param1);
            if(_myPlayerWall)
            {
               _myPlayerWall.reloadMessages(_inbox);
            }
         }
         else if(_strangersPlayerWall)
         {
            _strangerInbox.unshift(param1);
            _strangersPlayerWall.reloadMessages(_strangerInbox);
         }
      }
      
      public static function processMessageUpdate(param1:String, param2:String) : void
      {
         var _loc3_:PostMessage = null;
         var _loc4_:Array = [];
         if(_myPlayerWall)
         {
            _loc4_ = _inbox;
         }
         else
         {
            _loc4_ = _strangerInbox;
         }
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_.length)
         {
            _loc3_ = _loc4_[_loc5_];
            if(_loc3_ != null && _loc3_.msgId == param1)
            {
               _loc3_.message = param2;
               if(_myPlayerWall)
               {
                  _myPlayerWall.reloadMessages(_loc4_);
               }
               else if(_strangersPlayerWall)
               {
                  _strangersPlayerWall.reloadMessages(_loc4_);
               }
               break;
            }
            _loc5_++;
         }
      }
      
      public static function onReportMessage(param1:String) : void
      {
         if(_reportedPosts.length > SbiConstants.PLAYER_WALL_MAX_REPORTED_POSTS_SAVED)
         {
            _reportedPosts.pop();
         }
         _reportedPosts.splice(0,0,param1);
         if(_strangersPlayerWall)
         {
            _strangersPlayerWall.reloadMessages(_strangerInbox);
         }
         else if(_myPlayerWall)
         {
            _myPlayerWall.reloadMessages(_inbox);
         }
         GuiManager.setSharedObj("reportedPosts",_reportedPosts);
      }
      
      public static function onDeleteResponse(param1:String, param2:String, param3:Boolean) : void
      {
         var _loc4_:String = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc5_:Array = [];
         DarkenManager.showLoadingSpiral(false);
         if(param3)
         {
            _loc6_ = param1 == gMainFrame.userInfo.myUserName;
            if(_loc6_)
            {
               _loc5_ = _inbox;
            }
            else
            {
               _loc5_ = _strangerInbox;
            }
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               _loc4_ = _loc5_[_loc7_].msgId;
               if(_loc4_ == param2)
               {
                  _loc5_.splice(_loc7_,1);
                  break;
               }
               _loc7_++;
            }
         }
         if(_loc6_ && Boolean(_myPlayerWall))
         {
            _myPlayerWall.reloadMessages(_loc5_);
         }
         else if(_strangersPlayerWall)
         {
            _strangersPlayerWall.reloadMessages(_loc5_);
         }
      }
      
      public static function onPrivacyResponse(param1:Boolean, param2:int) : void
      {
         if(param1)
         {
            gMainFrame.userInfo.playerWallSettings = param2;
         }
      }
      
      public static function get isFirstTime() : Boolean
      {
         return _isFirstTime;
      }
      
      public static function set isFirstTime(param1:Boolean) : void
      {
         _isFirstTime = param1;
      }
      
      public static function get reportedPostIds() : Array
      {
         return _reportedPosts;
      }
      
      public static function updateTimestamp(param1:String, param2:Number) : Boolean
      {
         var _loc3_:Object = tokenMap[param1];
         if(_loc3_)
         {
            if(_loc3_.time < param2)
            {
               tokenMap[param1].time = param2;
               return true;
            }
         }
         return false;
      }
      
      public static function startMyWallTimer() : void
      {
         if(_openWallUpdateTimer)
         {
            _openWallUpdateTimer.start();
         }
      }
      
      private static function playerWallBtnDownHandler(param1:Object, param2:Boolean = true) : void
      {
         if(param1 is MouseEvent)
         {
            DarkenManager.showLoadingSpiral(true);
            param1.stopPropagation();
         }
         _myPlayerWallClosedTimer.reset();
         _hudWallBtn.glow.visible = false;
         _glowTimer.reset();
         if(_myPlayerWall)
         {
            _myPlayerWall.destroy();
            _myPlayerWall = null;
         }
         if(param2)
         {
            if(tokenMap[gMainFrame.userInfo.myUserName] != null)
            {
               _myPlayerWall = new PlayerWallGui();
               _myPlayerWall.init(_inbox,gMainFrame.server.userName,_statusText,_currentMessagePattern,_currentMessageColorId,_currentDecorId,onMyPlayerWallClose);
               _hudWallBtn.newPostCount.visible = false;
               _hudWallBtn.newPostCount.postCountTxt.text = "";
               _unreadCount = 0;
            }
            else
            {
               PlayerWallXtCommManager.sendWallTokenRequest(gMainFrame.userInfo.myUserName,playerWallBtnDownHandler,gMainFrame.userInfo.myUserName);
            }
         }
      }
      
      private static function onMyPlayerWallClose(param1:Boolean = false) : void
      {
         _openWallUpdateTimer.reset();
         if(!param1)
         {
            _myPlayerWallClosedTimer.start();
         }
         if(_myPlayerWall)
         {
            _currentMessageColorId = _myPlayerWall.myCurrMessageColorId;
            _currentMessagePattern = _myPlayerWall.currMessagePattern;
            _currentDecorId = _myPlayerWall.currDecorIndex;
            _myPlayerWall.destroy();
            _myPlayerWall = null;
         }
      }
      
      private static function onStrangerPlayerWallClose() : void
      {
         _openWallUpdateTimer.reset();
         if(_strangersPlayerWall)
         {
            _currentMessageColorId = _strangersPlayerWall.myCurrMessageColorId;
            _currentMessagePattern = _strangersPlayerWall.currMessagePattern;
            _strangersPlayerWall.destroy();
            _strangersPlayerWall = null;
         }
      }
      
      private static function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         _hudWallBtn.glow.visible = false;
      }
      
      private static function onMessageUpdateTimer(param1:TimerEvent) : void
      {
         var _loc2_:Boolean = param1.currentTarget == _myPlayerWallClosedTimer;
         if(_loc2_)
         {
            _myPlayerWallClosedTimer.reset();
         }
         else
         {
            _openWallUpdateTimer.reset();
         }
         if(_loc2_)
         {
            PlayerWallXtCommManager.sendCheckPlayerWall(gMainFrame.userInfo.myUserName,null,true);
         }
         else if(_strangersPlayerWall)
         {
            PlayerWallXtCommManager.sendCheckPlayerWall(_strangersPlayerWall.owner,null);
         }
         else
         {
            PlayerWallXtCommManager.sendCheckPlayerWall(gMainFrame.userInfo.myUserName,null);
         }
      }
   }
}

