package gui
{
   import avatar.AvatarInfo;
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
   import flash.geom.Point;
   import flash.utils.Dictionary;
   import flash.utils.Timer;
   import localization.LocalizationManager;
   import room.RoomManagerWorld;
   
   public class BuddyList
   {
      
      private static var _playerSearch:PlayerSearch;
      
      private static var _buddyListPopup:SBPopup;
      
      private static var _buddyListContent:MovieClip;
      
      private static var _buddyListWindow:MovieClip;
      
      private static var _buddyListWindow2:MovieClip;
      
      private static var _buddyListBtn:MovieClip;
      
      private static var _scrollbar:SBScrollbar;
      
      private static var _buddyListWorldPopup:MovieClip;
      
      private static var _buddyListWorldWindow:MovieClip;
      
      private static var _scrollbarInWorld:SBScrollbar;
      
      private static var _requestingForWorldBuddyList:Boolean;
      
      private static var _worldSelectCallback:Function;
      
      private static var _currentSelectedUsername:String;
      
      private static var _currentSelectedItem:Object;
      
      private static var _glowTimer:Timer;
      
      private static var _buddyListScrollOffset:int;
      
      private static var _popupLayer:DisplayLayer;
      
      private static var _loadingSpiral:LoadingSpiral;
      
      private static var _worldPopupLoadingSpiral:LoadingSpiral;
      
      public static var listRequested:Boolean;
      
      private static const BUDDY_LIST_X_OFFSET:int = 5;
      
      private static const BUDDY_LIST_Y_OFFSET:int = 49;
      
      public function BuddyList()
      {
         super();
      }
      
      public static function init(param1:DisplayLayer, param2:MovieClip, param3:Boolean = false) : void
      {
         _popupLayer = param1;
         _buddyListBtn = param2;
         if(!Utility.canBuddy())
         {
            _buddyListBtn.activateGrayState(true);
         }
         _buddyListContent = GETDEFINITIONBYNAME("BuddyListContent");
         LocalizationManager.translateId(_buddyListContent.buddyListTitleTxt,11250);
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         _buddyListPopup = new SBPopup(_popupLayer,GETDEFINITIONBYNAME("BuddyListPopup"),_buddyListContent,false,true,false,false);
         _buddyListPopup.closeCallback = buddyListClosedCallback;
         _buddyListPopup.x = _buddyListPopup.width * 0.5 + BUDDY_LIST_X_OFFSET;
         _buddyListPopup.y = _buddyListPopup.skin.s.ba.height * 0.5 + BUDDY_LIST_Y_OFFSET;
         _loadingSpiral = new LoadingSpiral(DisplayObjectContainer(_buddyListPopup.content),-15);
         _glowTimer = new Timer(5000);
         addListeners();
         if(param3)
         {
            onBuddyListChange(null);
         }
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
         LocalizationManager.translateId(_buddyListContent.buddyListTitleTxt,11250);
      }
      
      public static function destroy() : void
      {
         var _loc1_:int = 0;
         if(_buddyListWindow)
         {
            _loc1_ = 0;
            while(_loc1_ < _buddyListWindow.numChildren)
            {
               _buddyListWindow.getChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler);
               _buddyListWindow.removeChildAt(0);
               _loc1_++;
            }
         }
         removeListeners();
         if(_buddyListWindow2)
         {
            _loc1_ = 0;
            while(_loc1_ < _buddyListWindow2.numChildren)
            {
               _buddyListWindow2.removeChildAt(0);
               _loc1_++;
            }
         }
         _buddyListContent = null;
         if(_buddyListPopup)
         {
            _buddyListPopup.destroy();
            _buddyListPopup = null;
         }
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
         if(_buddyListWorldPopup)
         {
            buildInWorldBuddyList(null,_currentSelectedItem,null,_currentSelectedUsername);
         }
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
         MovieClip(_buddyListPopup.content).itemBlock.addChild(_buddyListWindow);
         buildBuddyListWindow(_buddyListWindow,true);
         if(_buddyListWindow.height >= 19.59 * 10)
         {
            _loc2_ *= _buddyListWindow.height - 19.59 * 10;
         }
         _scrollbar = new SBScrollbar();
         _scrollbar.init(_buddyListWindow,MovieClip(_buddyListPopup.content).itemBlock.width,19.59 * 10,5,"scrollbar2",19.59,_loc2_);
      }
      
      public static function buildBuddyListWindow(param1:MovieClip, param2:Boolean = false) : void
      {
         var _loc6_:Buddy = null;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:MovieClip = null;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc12_:AvatarInfo = null;
         var _loc3_:Array = [];
         var _loc4_:Dictionary = BuddyManager.buddyList;
         var _loc5_:int = BuddyManager.buddyCount;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         if(Boolean(_loc4_) && _loc5_ > 0)
         {
            for each(_loc6_ in _loc4_)
            {
               _loc3_.push({
                  "userName":_loc6_.userName,
                  "moderatedUserName":_loc6_.userNameModerated,
                  "onlineStatus":_loc6_.onlineStatus,
                  "numDaysSinceLastLogin":_loc6_.numDaysSinceLastLogin,
                  "accountType":_loc6_.accountType
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
                  _loc9_ = GETDEFINITIONBYNAME("OnlineBuddyListWindow");
                  _loc11_ = "Avatar Name";
                  _loc12_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc10_);
                  if(_loc12_)
                  {
                     _loc11_ = _loc12_.avName;
                  }
                  LocalizationManager.updateToFit(_loc9_.avNameTxt,_loc11_);
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
                  _loc9_ = GETDEFINITIONBYNAME("OfflineBuddyListWindow");
                  _loc9_.onOffBlocked.gotoAndStop("offline");
               }
               param1.addChild(_loc9_);
               _loc9_.x = 0;
               _loc9_.y = _loc7_;
               _loc7_ += _loc9_.height;
               _loc9_.userName = _loc10_;
               _loc9_.moderatedUserName = _loc3_[_loc8_].moderatedUserName;
               LocalizationManager.updateToFit(_loc9_.userNameTxt,_loc3_[_loc8_].moderatedUserName);
               _loc9_.onlineStatus = _loc3_[_loc8_].onlineStatus;
               _loc9_.daysSinceLastLogin = _loc3_[_loc8_].numDaysSinceLastLogin;
               _loc9_.accountType = _loc3_[_loc8_].accountType;
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
      
      private static function buildInWorldBuddyListWindow(param1:MovieClip, param2:String) : void
      {
         var _loc6_:Buddy = null;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:MovieClip = null;
         var _loc10_:String = null;
         var _loc3_:Array = [];
         var _loc4_:Dictionary = BuddyManager.buddyList;
         var _loc5_:int = BuddyManager.buddyCount;
         if(Boolean(_loc4_) && _loc5_ > 0)
         {
            for each(_loc6_ in _loc4_)
            {
               _loc3_.push({
                  "userName":_loc6_.userName,
                  "moderatedUserName":_loc6_.userNameModerated,
                  "onlineStatus":_loc6_.onlineStatus
               });
            }
            _loc3_.sortOn(["userName"],[Array.DESCENDING,Array.CASEINSENSITIVE]);
            _loc7_ = 0;
            param1.selectedIndex = -1;
            _loc8_ = 0;
            while(_loc8_ < _loc5_)
            {
               _loc10_ = _loc3_[_loc8_].userName;
               _loc9_ = GETDEFINITIONBYNAME("portalBuddyListWindowCont");
               param1.addChild(_loc9_);
               _loc9_.x = 0;
               _loc9_.y = _loc7_;
               _loc7_ += _loc9_.height;
               _loc9_.userName = _loc10_;
               _loc9_.moderatedUserName = _loc3_[_loc8_].moderatedUserName;
               LocalizationManager.updateToFit(_loc9_.userNameTxt,_loc3_[_loc8_].moderatedUserName);
               _loc9_.selectPortalBuddyBox = new GuiRadioButtonSingle(_loc9_.radioBtn,_loc9_.userNameTxt);
               if(_loc3_[_loc8_].onlineStatus == SFClient.STATUS_OFFLINE_ARCHIVED)
               {
                  _loc9_.selectPortalBuddyBox.gray = true;
               }
               else
               {
                  if(_loc10_.toLowerCase() == param2.toLowerCase())
                  {
                     _loc9_.selectPortalBuddyBox.selected = true;
                     param1.selectedIndex = _loc8_;
                     _currentSelectedUsername = param2;
                  }
                  else
                  {
                     _loc9_.selectPortalBuddyBox.selected = false;
                  }
                  _loc9_.index = _loc8_;
                  _loc9_.addEventListener(MouseEvent.MOUSE_DOWN,worldBuddyListClickOnBuddyHandler,false,0,true);
               }
               _loc8_++;
            }
         }
      }
      
      public static function buildInWorldBuddyList(param1:MovieClip, param2:Object, param3:Function, param4:String) : void
      {
         if(Boolean(!param1) || Boolean(param1 && !closeWorldBuddyList()) || !listRequested)
         {
            if(param1)
            {
               _worldSelectCallback = param3;
               if(_buddyListWorldPopup == null)
               {
                  _buddyListWorldPopup = GETDEFINITIONBYNAME("portalLinkBuddyListPopup");
               }
               if(_worldPopupLoadingSpiral == null)
               {
                  _worldPopupLoadingSpiral = new LoadingSpiral(_buddyListWorldPopup,_buddyListWorldPopup.width * 0.5,_buddyListWorldPopup.height * 0.5);
               }
               RoomManagerWorld.instance.layerManager.room_chat.addChild(_buddyListWorldPopup);
               _buddyListWorldPopup.x = param1.x - _buddyListWorldPopup.width * 0.5;
               _buddyListWorldPopup.y = param1.y + 30;
            }
            if(!listRequested)
            {
               _worldPopupLoadingSpiral.visible = true;
               BuddyXtCommManager.sendBuddyListRequest();
               listRequested = true;
               _requestingForWorldBuddyList = true;
               _currentSelectedUsername = param4;
               _currentSelectedItem = param2;
            }
            else
            {
               if(!param1 || !_buddyListWorldWindow || _buddyListWorldWindow.selectedItem != param2)
               {
                  _currentSelectedUsername = param4;
                  _currentSelectedItem = param2;
                  if(_scrollbarInWorld)
                  {
                     _scrollbarInWorld.destroy();
                     _scrollbarInWorld = null;
                  }
                  _buddyListWorldWindow = new MovieClip();
                  while(_buddyListWorldPopup.numChildren > 2)
                  {
                     _buddyListWorldPopup.removeChildAt(_buddyListWorldPopup.numChildren - 1);
                  }
                  _buddyListWorldPopup.itemBlock.addChild(_buddyListWorldWindow);
                  buildInWorldBuddyListWindow(_buddyListWorldWindow,param4);
                  _scrollbarInWorld = new SBScrollbar();
                  _scrollbarInWorld.init(_buddyListWorldWindow,_buddyListWorldPopup.itemBlock.width,22 * 6,0,"scrollbar2",22);
                  _buddyListWorldWindow.selectedItem = param2;
               }
               _worldPopupLoadingSpiral.visible = false;
            }
         }
      }
      
      public static function updateWorldBuddyListPosition(param1:MovieClip) : void
      {
         if(Boolean(_buddyListWorldPopup) && Boolean(_buddyListWorldPopup.parent))
         {
            _buddyListWorldPopup.x = param1.x - _buddyListWorldPopup.width * 0.5;
            _buddyListWorldPopup.y = param1.y + 30;
         }
      }
      
      public static function closeWorldBuddyList() : Boolean
      {
         if(Boolean(_buddyListWorldPopup) && Boolean(_buddyListWorldPopup.parent))
         {
            _buddyListWorldPopup.parent.removeChild(_buddyListWorldPopup);
            _worldSelectCallback = null;
            _currentSelectedItem = null;
            return true;
         }
         return false;
      }
      
      public static function isOverWorldBuddyList(param1:int, param2:int) : Boolean
      {
         var _loc3_:Point = null;
         if(Boolean(_buddyListWorldPopup) && Boolean(_buddyListWorldPopup.parent))
         {
            _loc3_ = RoomManagerWorld.instance.convertWorldToScreen(param1,param2);
            return _buddyListWorldPopup.hitTestPoint(_loc3_.x,_loc3_.y,true);
         }
         return false;
      }
      
      public static function destroyInWorldBuddyList() : void
      {
         closeWorldBuddyList();
         _buddyListWorldPopup = null;
         _buddyListWorldWindow = null;
         if(_scrollbarInWorld)
         {
            _scrollbarInWorld.destroy();
            _scrollbarInWorld = null;
         }
         _worldSelectCallback = null;
         _currentSelectedUsername = "";
         _currentSelectedItem = null;
      }
      
      private static function worldBuddyListClickOnBuddyHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_worldSelectCallback != null)
         {
            if(_currentSelectedUsername.toLowerCase() == param1.currentTarget.userName.toLowerCase())
            {
               _buddyListWorldWindow.selectedIndex = -1;
               _currentSelectedUsername = "";
            }
            else
            {
               if(_buddyListWorldWindow.selectedIndex != -1)
               {
                  MovieClip(_buddyListWorldWindow.getChildAt(_buddyListWorldWindow.selectedIndex)).selectPortalBuddyBox.selected = false;
               }
               _buddyListWorldWindow.selectedIndex = param1.currentTarget.index;
               _currentSelectedUsername = param1.currentTarget.userName;
            }
            _worldSelectCallback(_currentSelectedUsername);
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
            _loc5_ = LocalizationManager.translateIdOnly(11251);
         }
         else if(_loc6_ == 0)
         {
            _loc5_ = LocalizationManager.translateIdOnly(11252);
         }
         else if(_loc6_ == 1)
         {
            _loc5_ = LocalizationManager.translateIdOnly(11253);
         }
         else if(_loc6_ > 1 && _loc6_ < 31)
         {
            _loc5_ = LocalizationManager.translateIdAndInsertOnly(11254,_loc6_);
         }
         else if(_loc6_ > 30 || _loc6_ == -1)
         {
            _loc5_ = LocalizationManager.translateIdOnly(11255);
         }
         else
         {
            _loc5_ = LocalizationManager.translateIdOnly(11256);
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
         if(!param1.currentTarget.isGray)
         {
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
               glowTimerHandler(null);
               _buddyListPopup.open();
            }
         }
      }
      
      private static function buddyListClosedCallback() : void
      {
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
         GuiManager.toolTip.init(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14638),180,305);
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
         if(_buddyListContent)
         {
            _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSearchBtn);
            _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_OVER,onSearchBtnOver);
            _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_OUT,onSearchBtnOut);
         }
      }
   }
}

