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
      
      public static function init(initHudWallBtn:MovieClip) : void
      {
         PlayerWallXtCommManager.init();
         PlayerWallXtCommManager.sendPrivacyGetRequest(gMainFrame.server.userName);
         _guiLayer = GuiManager.guiLayer;
         _hudWallBtn = initHudWallBtn;
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
         var currSharedObj:SharedObject = GuiManager.sharedObj;
         if(Boolean(currSharedObj) && Boolean(currSharedObj.data))
         {
            _currentMessageColor = currSharedObj.data.msgColor != null ? currSharedObj.data.msgColor : "green";
            _currentMessagePattern = currSharedObj.data.msgPattern != null ? int(currSharedObj.data.msgPattern) : 1;
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
      
      public static function openStrangersPlayerWall(ownersUserName:String) : void
      {
         if(Boolean(_strangersPlayerWall))
         {
            _strangersPlayerWall.destroy();
            _strangersPlayerWall = null;
         }
         _strangersPlayerWall = new PlayerWallGui();
         _strangerInbox = [];
         _strangersPlayerWall.init(_strangerInbox,ownersUserName,"",0,_currentMessagePattern,"",_currentMessageColor,1714,1714,onStrangerPlayerWallClose);
      }
      
      public static function get isFirstTime() : Boolean
      {
         return _isFirstTime;
      }
      
      public static function set isFirstTime(value:Boolean) : void
      {
         _isFirstTime = value;
      }
      
      public static function get privacyId() : int
      {
         return _privacyId;
      }
      
      public static function set privacyId(value:int) : void
      {
         _privacyId = value;
      }
      
      public static function get reportedMessageIds() : Array
      {
         return _reportedStrangerMessageIds;
      }
      
      public static function startMyWallTimer() : void
      {
         if(Boolean(_openWallUpdateTimer))
         {
            _openWallUpdateTimer.start();
         }
      }
      
      public static function onGetResponse(status:Boolean, paramList:Array, isFromHudTimer:Boolean) : void
      {
         if(status)
         {
            if(isFromHudTimer)
            {
               if(paramList.length > _inbox.length && !isFirstTime)
               {
                  _unreadCount = paramList.length - _inbox.length;
                  _hudWallBtn.newPostCount.visible = true;
                  _hudWallBtn.newPostCount.postCountTxt.text = _unreadCount;
                  _hudWallBtn.glow.visible = true;
                  _glowTimer.start();
               }
            }
            else if(Boolean(_myPlayerWall))
            {
               isFirstTime = false;
               _inbox = paramList.concat();
               _myPlayerWall.reloadMessages(_inbox);
            }
            else if(Boolean(_strangersPlayerWall))
            {
               _strangerInbox = paramList.concat();
               _strangersPlayerWall.reloadMessages(_strangerInbox);
            }
         }
         else if(!isFromHudTimer)
         {
            if(Boolean(_myPlayerWall))
            {
               isFirstTime = true;
               _myPlayerWall.reloadMessages(_inbox);
            }
            else if(Boolean(_strangersPlayerWall))
            {
               _strangersPlayerWall.reloadMessages(_strangerInbox);
            }
         }
         if(!isFromHudTimer)
         {
            _openWallUpdateTimer.start();
         }
         else
         {
            _myPlayerWallClosedTimer.start();
         }
      }
      
      public static function processMessagePush(msg:PostMessage) : void
      {
         if(Boolean(_myPlayerWall))
         {
            _inbox.unshift(msg);
            if(Boolean(_myPlayerWall))
            {
               _myPlayerWall.reloadMessages(_inbox);
            }
         }
         else if(Boolean(_strangersPlayerWall))
         {
            _strangerInbox.unshift(msg);
            _strangersPlayerWall.reloadMessages(_strangerInbox);
         }
      }
      
      public static function processMessageUpdate(msgId:String, newMsg:String) : void
      {
         var tempMessage:PostMessage = null;
         var inbox:Array = [];
         if(Boolean(_myPlayerWall))
         {
            inbox = _inbox;
         }
         else
         {
            inbox = _strangerInbox;
         }
         for(var j:int = 0; j < inbox.length; j++)
         {
            tempMessage = inbox[j];
            if(tempMessage != null && tempMessage.msgId == msgId)
            {
               tempMessage.message = newMsg;
               if(Boolean(_myPlayerWall))
               {
                  _myPlayerWall.reloadMessages(inbox);
               }
               else if(Boolean(_strangersPlayerWall))
               {
                  _strangersPlayerWall.reloadMessages(inbox);
               }
               break;
            }
         }
      }
      
      public static function onAddResponse(msgId:String, postTimeStamp:Number, errorMsgId:int) : void
      {
      }
      
      public static function onStrangerReport(msgId:String) : void
      {
         _reportedStrangerMessageIds.push(msgId);
         if(Boolean(_strangersPlayerWall))
         {
            _strangersPlayerWall.reloadMessages(_strangerInbox);
         }
      }
      
      public static function onDeleteResponse(owner:String, msgId:String, status:Boolean) : void
      {
         var tempMsgId:String = null;
         var isMyWall:Boolean = false;
         var j:int = 0;
         var inbox:Array = [];
         DarkenManager.showLoadingSpiral(false);
         if(status)
         {
            isMyWall = owner == gMainFrame.userInfo.myUserName;
            if(isMyWall)
            {
               inbox = _inbox;
            }
            else
            {
               inbox = _strangerInbox;
            }
            for(j = 0; j < inbox.length; j++)
            {
               tempMsgId = inbox[j].msgId;
               if(tempMsgId == msgId)
               {
                  inbox.splice(j,1);
                  break;
               }
            }
         }
         if(isMyWall && Boolean(_myPlayerWall))
         {
            _myPlayerWall.reloadMessages(inbox);
         }
         else if(Boolean(_strangersPlayerWall))
         {
            _strangersPlayerWall.reloadMessages(inbox);
         }
      }
      
      public static function onStatusResponse(status:Boolean, userName:String, newStatus:String) : void
      {
         if(status && userName == gMainFrame.userInfo.myUserName)
         {
            _statusText = newStatus;
            _iconId = 1714;
         }
      }
      
      public static function onPrivacyResponse(status:Boolean, newPrivacyId:int) : void
      {
         if(status && Boolean(_myPlayerWall))
         {
            _privacyId = newPrivacyId;
         }
      }
      
      private static function playerWallBtnDownHandler(event:MouseEvent) : void
      {
         _myPlayerWallClosedTimer.reset();
         _hudWallBtn.glow.visible = false;
         _glowTimer.reset();
         if(Boolean(_myPlayerWall))
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
      
      private static function glowTimerHandler(event:TimerEvent) : void
      {
         _glowTimer.stop();
         _hudWallBtn.glow.visible = false;
      }
      
      private static function onMessageUpdateTimer(event:TimerEvent) : void
      {
         var isClosedTimer:Boolean = event.currentTarget == _myPlayerWallClosedTimer;
         if(isClosedTimer)
         {
            _myPlayerWallClosedTimer.reset();
         }
         else
         {
            _openWallUpdateTimer.reset();
         }
         if(isClosedTimer)
         {
            PlayerWallXtCommManager.sendPostGetRequest(gMainFrame.userInfo.myUserName,null,true);
         }
         else if(Boolean(_strangersPlayerWall))
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

