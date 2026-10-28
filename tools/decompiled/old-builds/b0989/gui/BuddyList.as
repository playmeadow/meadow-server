package gui
{
   import avatar.AvatarInfo;
   import avatar.AvatarXtCommManager;
   import buddy.Buddy;
   import buddy.BuddyEvent;
   import buddy.BuddyXtCommManager;
   import com.sbi.client.SFClient;
   import com.sbi.popup.SBPopup;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import flash.utils.getDefinitionByName;
   
   public class BuddyList
   {
      
      private static var BuddyListPopup:Class;
      
      private static var OfflineBuddyListWindow:Class;
      
      private static var BuddyListContent:Class;
      
      private static var OnlineBuddyListWindow:Class;
      
      private static var _playerSearch:PlayerSearch;
      
      private static var _buddyListPopup:SBPopup;
      
      private static var _buddyListContent:MovieClip;
      
      private static var _buddyListWindow:MovieClip;
      
      private static var _buddyListWindow2:MovieClip;
      
      private static var _buddyListBtn:MovieClip;
      
      private static var _scrollbar:SBScrollbar;
      
      private static var _glowTimer:Timer;
      
      private static var _buddyListScrollOffset:int;
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      public static var listRequested:Boolean;
      
      public static var ffmCallBack:Function;
      
      private static const BUDDY_LIST_X_OFFSET:int = 5;
      
      private static const BUDDY_LIST_Y_OFFSET:int = 49;
      
      public function BuddyList()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:MovieClip) : void
      {
         _popupLayer = param1;
         _buddyListBtn = param2;
         if(!Utility.canBuddy())
         {
            _buddyListBtn.activateGrayState(true);
         }
         BuddyListContent = getDefinitionByName("BuddyListContent") as Class;
         BuddyListPopup = getDefinitionByName("BuddyListPopup") as Class;
         OfflineBuddyListWindow = getDefinitionByName("OfflineBuddyListWindow") as Class;
         OnlineBuddyListWindow = getDefinitionByName("OnlineBuddyListWindow") as Class;
         _buddyListContent = new BuddyListContent();
         _buddyListContent.buddyListTitleTxt.text = "My Buddies";
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         _buddyListPopup = new SBPopup(_popupLayer,new BuddyListPopup(),_buddyListContent,false,true,false,false);
         _buddyListPopup.closeCallback = buddyListClosedCallback;
         _buddyListPopup.x = _buddyListPopup.width * 0.5 + BUDDY_LIST_X_OFFSET;
         _buddyListPopup.y = _buddyListPopup.skin.s.ba.height * 0.5 + BUDDY_LIST_Y_OFFSET;
         _loadingSpiral = new LoadingSpiral(DisplayObjectContainer(_buddyListPopup.content),-15);
         _glowTimer = new Timer(5000);
         addListeners();
      }
      
      public static function rebuildBtn(param1:MovieClip) : void
      {
         if(_buddyListBtn)
         {
            _buddyListBtn.removeEventListener(MouseEvent.MOUSE_DOWN,buddyListBtnHandler);
         }
         _buddyListBtn = param1;
         if(Utility.canBuddy())
         {
            _buddyListBtn.addEventListener(MouseEvent.MOUSE_DOWN,buddyListBtnHandler,false,0,true);
         }
         else
         {
            _buddyListBtn.activateGrayState(true);
         }
         _buddyListBtn.glow.visible = false;
      }
      
      public static function destroy() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _buddyListWindow.numChildren)
         {
            _buddyListWindow.getChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler);
            _buddyListWindow.removeChildAt(0);
            _loc1_++;
         }
         removeListeners();
         _loc1_ = 0;
         while(_loc1_ < _buddyListWindow2.numChildren)
         {
            _buddyListWindow2.removeChildAt(0);
            _loc1_++;
         }
         _buddyListContent = null;
         ffmCallBack = null;
         _buddyListPopup.destroy();
         _buddyListPopup = null;
      }
      
      public static function get visible() : Boolean
      {
         return _buddyListPopup.visible;
      }
      
      public static function closeBuddyList() : void
      {
         if(Boolean(_buddyListPopup) && _buddyListPopup.visible)
         {
            _buddyListPopup.close();
            GuiManager.toolTip.resetTimerAndSetVisibility();
            _buddyListBtn.downToUpState();
         }
      }
      
      private static function onBuddyListChange(param1:Event) : void
      {
         var _loc3_:DisplayObject = null;
         _loadingSpiral.visible = false;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         var _loc2_:Number = -1;
         if(_scrollbar)
         {
            _loc2_ = _scrollbar.scrollYPercentage;
            _scrollbar.destroy();
            _scrollbar = null;
         }
         if(_buddyListWindow != null)
         {
            while(_buddyListWindow.numChildren > 0)
            {
               _loc3_ = _buddyListWindow.getChildAt(0);
               _loc3_.removeEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler);
               _buddyListWindow.removeChild(_loc3_);
               _loc3_ = null;
            }
            if(_buddyListWindow.parent)
            {
               _buddyListWindow.parent.removeChild(_buddyListWindow);
            }
         }
         _buddyListWindow = new MovieClip();
         BuddyListContent(_buddyListPopup.content).itemBlock.addChild(_buddyListWindow);
         buildBuddyListWindow(_buddyListWindow,true);
         if(_buddyListWindow.height >= 19.6 * 10)
         {
            _loc2_ *= _buddyListWindow.height - 19.6 * 10;
         }
         _scrollbar = new SBScrollbar();
         _scrollbar.init(_buddyListWindow,BuddyListContent(_buddyListPopup.content).itemBlock.width,19.6 * 10,5,"scrollbar2",19.6,_loc2_);
      }
      
      public static function buildBuddyListWindow(param1:MovieClip, param2:Boolean = false) : void
      {
         var _loc3_:Array = null;
         var _loc6_:Buddy = null;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:MovieClip = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:AvatarInfo = null;
         _loc3_ = [];
         var _loc4_:Dictionary = BuddyManager.buddyList;
         var _loc5_:int = BuddyManager.buddyCount;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         if(Boolean(_loc4_) && _loc5_ > 0)
         {
            for each(_loc6_ in _loc4_)
            {
               _loc3_.push({
                  "userName":_loc6_.userName,
                  "onlineStatus":_loc6_.onlineStatus,
                  "numDaysSinceLastLogin":_loc6_.numDaysSinceLastLogin
               });
            }
            _loc3_.sortOn(["onlineStatus","userName"],[Array.DESCENDING,Array.CASEINSENSITIVE]);
            _loc7_ = 0;
            _loc8_ = 0;
            while(_loc8_ < _loc5_)
            {
               _loc10_ = _loc3_[_loc8_].userName;
               if(_loc3_[_loc8_].onlineStatus == SFClient.STATUS_ONLINE)
               {
                  _loc9_ = new OnlineBuddyListWindow();
                  _loc11_ = "Avatar Name";
                  _loc12_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc10_);
                  if(_loc12_)
                  {
                     _loc11_ = _loc12_.avName;
                  }
                  _loc9_.avNameTxt.text = _loc11_;
                  if(BuddyManager.isBlocked(_loc10_))
                  {
                     _loc9_.onOffBlocked.gotoAndStop("blocked");
                  }
                  else
                  {
                     _loc9_.onOffBlocked.gotoAndStop("online");
                  }
               }
               else
               {
                  _loc9_ = new OfflineBuddyListWindow();
                  _loc9_.onOffBlocked.gotoAndStop("offline");
               }
               param1.addChild(_loc9_);
               _loc9_.x = 0;
               _loc9_.y = _loc7_;
               _loc7_ += _loc9_.height;
               _loc9_.userName = _loc10_;
               _loc9_.onlineStatus = _loc3_[_loc8_].onlineStatus;
               _loc9_.daysSinceLastLogin = _loc3_[_loc8_].numDaysSinceLastLogin;
               if(param2)
               {
                  _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler,false,0,true);
                  _loc9_.addEventListener(MouseEvent.MOUSE_OVER,buddyListOverBuddyHandler,false,0,true);
                  _loc9_.addEventListener(MouseEvent.MOUSE_OUT,buddyListOutBuddyHandler,false,0,true);
               }
               _loc8_++;
            }
         }
      }
      
      private static function buddyListClickOnBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:MovieClip = MovieClip(param1.currentTarget);
         if(_loc2_.userName.indexOf("Liza") < 0)
         {
            BuddyCard.showBuddyCard({
               "userName":_loc2_.userName,
               "onlineStatus":_loc2_.onlineStatus
            });
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         AJAudio.playSubMenuBtnClick();
      }
      
      private static function buddyListOverBuddyHandler(param1:MouseEvent) : void
      {
         var _loc5_:String = null;
         var _loc2_:int = _buddyListPopup.x - _buddyListWindow.width * 0.5 + 5;
         var _loc3_:int = _buddyListPopup.y - 19.6 * 4.5 - _scrollbar.scrollYValue;
         var _loc4_:MovieClip = MovieClip(param1.currentTarget.getChildAt(0));
         var _loc6_:int = int(param1.currentTarget.daysSinceLastLogin);
         if(param1.currentTarget.avNameTxt)
         {
            _loc5_ = "Online";
         }
         else if(_loc6_ == 0)
         {
            _loc5_ = "Today";
         }
         else if(_loc6_ == 1)
         {
            _loc5_ = "1 Day Ago";
         }
         else if(_loc6_ > 1 && _loc6_ < 31)
         {
            _loc5_ = _loc6_ + " Days Ago";
         }
         else if(_loc6_ > 30 || _loc6_ == -1)
         {
            _loc5_ = "More than 30 Days";
         }
         else
         {
            _loc5_ = "Unknown";
         }
         GuiManager.toolTip.init(GuiManager.guiLayer,_loc5_,0,0);
         GuiManager.toolTip.setPos(_loc2_ + _loc4_.x + GuiManager.toolTip.width * 0.5,_loc3_ + param1.currentTarget.y);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private static function buddyListOutBuddyHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function buddyListBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!listRequested)
         {
            BuddyXtCommManager.sendBuddyListRequest();
            listRequested = true;
         }
         GuiManager.onExitRoom(true);
         if(_buddyListPopup.visible)
         {
            _buddyListPopup.close();
         }
         else
         {
            if(GuiManager.secondFFMRunning)
            {
               GuiManager.ffmBuddyList = false;
               AvatarXtCommManager.sendAvatarFiveMinutesUpdate([GuiManager.FFM_BUDDYLIST]);
            }
            _buddyListPopup.open();
         }
      }
      
      private static function buddyListClosedCallback() : void
      {
         if(ffmCallBack != null)
         {
            ffmCallBack();
         }
         _buddyListBtn.downToUpState();
         _buddyListScrollOffset = 0;
      }
      
      public static function startBuddyListBtnGlow() : void
      {
         if(_buddyListBtn)
         {
            _buddyListBtn.glow.visible = true;
         }
         AJAudio.playBuddyOnlineOfflineSound();
         if(_glowTimer.running)
         {
            _glowTimer.stop();
         }
         _glowTimer.start();
      }
      
      private static function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         if(_buddyListBtn)
         {
            _buddyListBtn.glow.visible = false;
         }
      }
      
      private static function onSearchBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _playerSearch = new PlayerSearch();
         _playerSearch.init();
         DarkenManager.showLoadingSpiral(true);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function onSearchBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,"Find A Jammer",180,305);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private static function onSearchBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function addListeners() : void
      {
         _glowTimer.addEventListener(TimerEvent.TIMER,glowTimerHandler,false,0,true);
         BuddyManager.eventDispatcher.addEventListener(BuddyEvent.BUDDY_LIST,onBuddyListChange,false,0,true);
         BuddyManager.eventDispatcher.addEventListener(BuddyEvent.BUDDY_CHANGED,onBuddyListChange,false,0,true);
         if(Utility.canBuddy())
         {
            _buddyListBtn.addEventListener(MouseEvent.MOUSE_DOWN,buddyListBtnHandler,false,0,true);
         }
         _buddyListContent.searchBtn.addEventListener(MouseEvent.MOUSE_DOWN,onSearchBtn,false,0,true);
         _buddyListContent.searchBtn.addEventListener(MouseEvent.MOUSE_OVER,onSearchBtnOver,false,0,true);
         _buddyListContent.searchBtn.addEventListener(MouseEvent.MOUSE_OUT,onSearchBtnOut,false,0,true);
      }
      
      private static function removeListeners() : void
      {
         if(Utility.canBuddy())
         {
            _buddyListBtn.removeEventListener(MouseEvent.MOUSE_DOWN,buddyListBtnHandler);
         }
         _glowTimer.removeEventListener(TimerEvent.TIMER,glowTimerHandler);
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_LIST,onBuddyListChange);
         BuddyManager.eventDispatcher.removeEventListener(BuddyEvent.BUDDY_CHANGED,onBuddyListChange);
         _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSearchBtn);
         _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_OVER,onSearchBtnOver);
         _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_OUT,onSearchBtnOut);
      }
   }
}

