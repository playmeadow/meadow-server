package playerWall
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.net.SharedObject;
   import flash.utils.Timer;
   import gui.DarkenManager;
   import gui.GuiManager;
   
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
      
      private static var _currentMessageColor:String;
      
      private static var _currentMessagePattern:int;
      
      private static var _privacyId:int;
      
      private static var _reportedStrangerMessageIds:Array;
      
      private static var _iconId:int;
      
      public function PlayerWallManager()
      {
         super();
      }
      
      public static function init(param1:MovieClip) : void
      {
         PlayerWallXtCommManager.init();
         PlayerWallXtCommManager.sendPrivacyGetRequest(gMainFrame.server.userName);
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
            _currentMessageColor = _loc2_.data.msgColor != null ? _loc2_.data.msgColor : "green";
            _currentMessagePattern = _loc2_.data.msgPattern != null ? int(_loc2_.data.msgPattern) : 1;
         }
         else
         {
            _currentMessageColor = "green";
            _currentMessagePattern = 1;
         }
         _inbox = [];
         _reportedStrangerMessageIds = [];
         _hudWallBtn.addEventListener(MouseEvent.MOUSE_DOWN,playerWallBtnDownHandler,false,0,true);
      }
      
      public static function destroy() : void
      {
         _openWallUpdateTimer.reset();
         _openWallUpdateTimer = null;
         _myPlayerWallClosedTimer.reset();
         _myPlayerWallClosedTimer = null;
      }
      
      public static function openStrangersPlayerWall(param1:String) : void
      {
         if(_strangersPlayerWall)
         {
            _strangersPlayerWall.destroy();
            _strangersPlayerWall = null;
         }
         _strangersPlayerWall = new PlayerWallGui();
         _strangerInbox = [];
         _strangersPlayerWall.init(_strangerInbox,param1,"",0,_currentMessagePattern,"",_currentMessageColor,1714,1714,onStrangerPlayerWallClose);
      }
      
      public static function get isFirstTime() : Boolean
      {
         return _isFirstTime;
      }
      
      public static function set isFirstTime(param1:Boolean) : void
      {
         _isFirstTime = param1;
      }
      
      public static function get privacyId() : int
      {
         return _privacyId;
      }
      
      public static function set privacyId(param1:int) : void
      {
         _privacyId = param1;
      }
      
      public static function get reportedMessageIds() : Array
      {
         return _reportedStrangerMessageIds;
      }
      
      public static function startMyWallTimer() : void
      {
         if(_openWallUpdateTimer)
         {
            _openWallUpdateTimer.start();
         }
      }
      
      public static function onGetResponse(param1:Boolean, param2:Array, param3:Boolean) : void
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
         }
         else if(!param3)
         {
            if(_myPlayerWall)
            {
               isFirstTime = true;
               _myPlayerWall.reloadMessages(_inbox);
            }
            else if(_strangersPlayerWall)
            {
               _strangersPlayerWall.reloadMessages(_strangerInbox);
            }
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
      
      public static function onAddResponse(param1:String, param2:Number, param3:int) : void
      {
      }
      
      public static function onStrangerReport(param1:String) : void
      {
         _reportedStrangerMessageIds.push(param1);
         if(_strangersPlayerWall)
         {
            _strangersPlayerWall.reloadMessages(_strangerInbox);
         }
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
      
      public static function onStatusResponse(param1:Boolean, param2:String, param3:String) : void
      {
         if(param1 && param2 == gMainFrame.userInfo.myUserName)
         {
            _statusText = param3;
            _iconId = 1714;
         }
      }
      
      public static function onPrivacyResponse(param1:Boolean, param2:int) : void
      {
         if(param1 && Boolean(_myPlayerWall))
         {
            _privacyId = param2;
         }
      }
      
      private static function playerWallBtnDownHandler(param1:MouseEvent) : void
      {
         _myPlayerWallClosedTimer.reset();
         _hudWallBtn.glow.visible = false;
         _glowTimer.reset();
         if(_myPlayerWall)
         {
            _myPlayerWall.destroy();
            _myPlayerWall = null;
         }
         _myPlayerWall = new PlayerWallGui();
         _myPlayerWall.init(_inbox,gMainFrame.server.userName,_statusText,_privacyId,_currentMessagePattern,_currentMessageColor,_currentMessageColor,_iconId,_iconId,onMyPlayerWallClose);
         _hudWallBtn.newPostCount.visible = false;
         _hudWallBtn.newPostCount.postCountTxt.text = "";
         _unreadCount = 0;
      }
      
      private static function onMyPlayerWallClose() : void
      {
         _openWallUpdateTimer.reset();
         _myPlayerWallClosedTimer.start();
         _currentMessageColor = _myPlayerWall.myCurrMessageColor;
         _currentMessagePattern = _myPlayerWall.currMessagePattern;
         _myPlayerWall.destroy();
         _myPlayerWall = null;
      }
      
      private static function onStrangerPlayerWallClose() : void
      {
         _openWallUpdateTimer.reset();
         _currentMessageColor = _strangersPlayerWall.myCurrMessageColor;
         _currentMessagePattern = _strangersPlayerWall.currMessagePattern;
         _strangersPlayerWall.destroy();
         _strangersPlayerWall = null;
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
            PlayerWallXtCommManager.sendPostGetRequest(gMainFrame.userInfo.myUserName,null,true);
         }
         else if(_strangersPlayerWall)
         {
            PlayerWallXtCommManager.sendPostGetRequest(_strangersPlayerWall.owner,null);
         }
         else
         {
            PlayerWallXtCommManager.sendPostGetRequest(gMainFrame.userInfo.myUserName);
         }
      }
   }
}

