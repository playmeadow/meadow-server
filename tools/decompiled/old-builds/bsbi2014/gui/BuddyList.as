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
      
      public static function init(init_popupLayer:DisplayLayer, init_buddyListBtn:MovieClip, rebuild:Boolean = false) : void
      {
         _popupLayer = init_popupLayer;
         _buddyListBtn = init_buddyListBtn;
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
         if(rebuild)
         {
            onBuddyListChange(null);
         }
      }
      
      public static function rebuildBtn(init_buddyListBtn:MovieClip) : void
      {
         if(Boolean(_buddyListBtn))
         {
            _buddyListBtn.removeEventListener(MouseEvent.MOUSE_DOWN,buddyListBtnHandler);
         }
         _buddyListBtn = init_buddyListBtn;
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
         var i:int = 0;
         if(Boolean(_buddyListWindow))
         {
            for(i = 0; i < _buddyListWindow.numChildren; i++)
            {
               _buddyListWindow.getChildAt(0).removeEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler);
               _buddyListWindow.removeChildAt(0);
            }
         }
         removeListeners();
         if(Boolean(_buddyListWindow2))
         {
            for(i = 0; i < _buddyListWindow2.numChildren; i++)
            {
               _buddyListWindow2.removeChildAt(0);
            }
         }
         _buddyListContent = null;
         if(Boolean(_buddyListPopup))
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
      
      private static function onBuddyListChange(evt:Event) : void
      {
         var mc:DisplayObject = null;
         if(Boolean(_buddyListWorldPopup))
         {
            buildInWorldBuddyList(null,_currentSelectedItem,null,_currentSelectedUsername);
         }
         _loadingSpiral.visible = false;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         var scrollYValue:Number = -1;
         if(Boolean(_scrollbar))
         {
            scrollYValue = _scrollbar.scrollYPercentage;
            _scrollbar.destroy();
            _scrollbar = null;
         }
         if(_buddyListWindow != null)
         {
            while(_buddyListWindow.numChildren > 0)
            {
               mc = _buddyListWindow.getChildAt(0);
               mc.removeEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler);
               _buddyListWindow.removeChild(mc);
               mc = null;
            }
            if(Boolean(_buddyListWindow.parent))
            {
               _buddyListWindow.parent.removeChild(_buddyListWindow);
            }
         }
         _buddyListWindow = new MovieClip();
         MovieClip(_buddyListPopup.content).itemBlock.addChild(_buddyListWindow);
         buildBuddyListWindow(_buddyListWindow,true);
         if(_buddyListWindow.height >= 19.59 * 10)
         {
            scrollYValue *= _buddyListWindow.height - 19.59 * 10;
         }
         _scrollbar = new SBScrollbar();
         _scrollbar.init(_buddyListWindow,MovieClip(_buddyListPopup.content).itemBlock.width,19.59 * 10,5,"scrollbar2",19.59,scrollYValue);
      }
      
      public static function buildBuddyListWindow(buddyListMC:MovieClip, isForMainHud:Boolean = false) : void
      {
         var bud:Buddy = null;
         var yOffset:Number = NaN;
         var i:int = 0;
         var bw:MovieClip = null;
         var userName:String = null;
         var avName:String = null;
         var avInfo:AvatarInfo = null;
         var dp:Array = [];
         var buddyList:Dictionary = BuddyManager.buddyList;
         var numBuddies:int = BuddyManager.buddyCount;
         _buddyListContent.counterTxt.text = String(BuddyManager.buddyCount) + "/" + String(BuddyManager.MAX_BUDDY_COUNT);
         if(Boolean(buddyList) && numBuddies > 0)
         {
            for each(bud in buddyList)
            {
               dp.push({
                  "userName":bud.userName,
                  "moderatedUserName":bud.userNameModerated,
                  "onlineStatus":bud.onlineStatus,
                  "numDaysSinceLastLogin":bud.numDaysSinceLastLogin,
                  "accountType":bud.accountType
               });
            }
            dp.sortOn(["onlineStatus","userName"],[Array.DESCENDING,Array.CASEINSENSITIVE]);
            yOffset = 0;
            for(i = 0; i < numBuddies; i++)
            {
               userName = dp[i].userName;
               if(dp[i].onlineStatus == SFClient.STATUS_ONLINE)
               {
                  bw = GETDEFINITIONBYNAME("OnlineBuddyListWindow");
                  avName = "Avatar Name";
                  avInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
                  if(Boolean(avInfo))
                  {
                     avName = avInfo.avName;
                  }
                  LocalizationManager.updateToFit(bw.avNameTxt,avName);
                  if(BuddyManager.isBlocked(userName))
                  {
                     bw.onOffBlocked.gotoAndStop("blocked");
                  }
                  else
                  {
                     bw.onOffBlocked.gotoAndStop("online");
                  }
               }
               else
               {
                  bw = GETDEFINITIONBYNAME("OfflineBuddyListWindow");
                  bw.onOffBlocked.gotoAndStop("offline");
               }
               buddyListMC.addChild(bw);
               bw.x = 0;
               bw.y = yOffset;
               yOffset += bw.height;
               bw.userName = userName;
               bw.moderatedUserName = dp[i].moderatedUserName;
               LocalizationManager.updateToFit(bw.userNameTxt,dp[i].moderatedUserName);
               bw.onlineStatus = dp[i].onlineStatus;
               bw.daysSinceLastLogin = dp[i].numDaysSinceLastLogin;
               bw.accountType = dp[i].accountType;
               if(isForMainHud)
               {
                  bw.addEventListener(MouseEvent.MOUSE_DOWN,buddyListClickOnBuddyHandler,false,0,true);
                  bw.addEventListener(MouseEvent.MOUSE_OVER,buddyListOverBuddyHandler,false,0,true);
                  bw.addEventListener(MouseEvent.MOUSE_OUT,buddyListOutBuddyHandler,false,0,true);
               }
            }
         }
      }
      
      private static function buildInWorldBuddyListWindow(buddyListMC:MovieClip, currentSelectedBuddyUserName:String) : void
      {
         var bud:Buddy = null;
         var yOffset:Number = NaN;
         var i:int = 0;
         var bw:MovieClip = null;
         var userName:String = null;
         var dp:Array = [];
         var buddyList:Dictionary = BuddyManager.buddyList;
         var numBuddies:int = BuddyManager.buddyCount;
         if(Boolean(buddyList) && numBuddies > 0)
         {
            for each(bud in buddyList)
            {
               dp.push({
                  "userName":bud.userName,
                  "moderatedUserName":bud.userNameModerated,
                  "onlineStatus":bud.onlineStatus
               });
            }
            dp.sortOn(["userName"],[Array.DESCENDING,Array.CASEINSENSITIVE]);
            yOffset = 0;
            buddyListMC.selectedIndex = -1;
            for(i = 0; i < numBuddies; i++)
            {
               userName = dp[i].userName;
               bw = GETDEFINITIONBYNAME("portalBuddyListWindowCont");
               buddyListMC.addChild(bw);
               bw.x = 0;
               bw.y = yOffset;
               yOffset += bw.height;
               bw.userName = userName;
               bw.moderatedUserName = dp[i].moderatedUserName;
               LocalizationManager.updateToFit(bw.userNameTxt,dp[i].moderatedUserName);
               bw.selectPortalBuddyBox = new GuiRadioButtonSingle(bw.radioBtn,bw.userNameTxt);
               if(dp[i].onlineStatus == SFClient.STATUS_OFFLINE_ARCHIVED)
               {
                  bw.selectPortalBuddyBox.gray = true;
               }
               else
               {
                  if(userName == currentSelectedBuddyUserName)
                  {
                     bw.selectPortalBuddyBox.selected = true;
                     buddyListMC.selectedIndex = i;
                     _currentSelectedUsername = currentSelectedBuddyUserName;
                  }
                  else
                  {
                     bw.selectPortalBuddyBox.selected = false;
                  }
                  bw.index = i;
                  bw.addEventListener(MouseEvent.MOUSE_DOWN,worldBuddyListClickOnBuddyHandler,false,0,true);
               }
            }
         }
      }
      
      public static function buildInWorldBuddyList(linkBtn:MovieClip, selectedItem:Object, selectCallback:Function, currentSelectedUsername:String) : void
      {
         if(Boolean(!linkBtn) || Boolean(linkBtn && !closeWorldBuddyList()) || !listRequested)
         {
            if(Boolean(linkBtn))
            {
               _worldSelectCallback = selectCallback;
               if(_buddyListWorldPopup == null)
               {
                  _buddyListWorldPopup = GETDEFINITIONBYNAME("portalLinkBuddyListPopup");
               }
               if(_worldPopupLoadingSpiral == null)
               {
                  _worldPopupLoadingSpiral = new LoadingSpiral(_buddyListWorldPopup,_buddyListWorldPopup.width * 0.5,_buddyListWorldPopup.height * 0.5);
               }
               RoomManagerWorld.instance.layerManager.room_chat.addChild(_buddyListWorldPopup);
               _buddyListWorldPopup.x = linkBtn.x - _buddyListWorldPopup.width * 0.5;
               _buddyListWorldPopup.y = linkBtn.y + 30;
            }
            if(!listRequested)
            {
               _worldPopupLoadingSpiral.visible = true;
               BuddyXtCommManager.sendBuddyListRequest();
               listRequested = true;
               _requestingForWorldBuddyList = true;
               _currentSelectedUsername = currentSelectedUsername;
               _currentSelectedItem = selectedItem;
            }
            else
            {
               if(!linkBtn || !_buddyListWorldWindow || _buddyListWorldWindow.selectedItem != selectedItem)
               {
                  _currentSelectedUsername = currentSelectedUsername;
                  _currentSelectedItem = selectedItem;
                  if(Boolean(_scrollbarInWorld))
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
                  buildInWorldBuddyListWindow(_buddyListWorldWindow,currentSelectedUsername);
                  _scrollbarInWorld = new SBScrollbar();
                  _scrollbarInWorld.init(_buddyListWorldWindow,_buddyListWorldPopup.itemBlock.width,22 * 6,0,"scrollbar2",22);
                  _buddyListWorldWindow.selectedItem = selectedItem;
               }
               _worldPopupLoadingSpiral.visible = false;
            }
         }
      }
      
      public static function updateWorldBuddyListPosition(linkBtn:MovieClip) : void
      {
         if(Boolean(_buddyListWorldPopup) && Boolean(_buddyListWorldPopup.parent))
         {
            _buddyListWorldPopup.x = linkBtn.x - _buddyListWorldPopup.width * 0.5;
            _buddyListWorldPopup.y = linkBtn.y + 30;
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
      
      public static function isOverWorldBuddyList(x:int, y:int) : Boolean
      {
         var worldPoint:Point = null;
         if(Boolean(_buddyListWorldPopup) && Boolean(_buddyListWorldPopup.parent))
         {
            worldPoint = RoomManagerWorld.instance.convertWorldToScreen(x,y);
            return _buddyListWorldPopup.hitTestPoint(worldPoint.x,worldPoint.y,true);
         }
         return false;
      }
      
      public static function destroyInWorldBuddyList() : void
      {
         closeWorldBuddyList();
         _buddyListWorldPopup = null;
         _buddyListWorldWindow = null;
         if(Boolean(_scrollbarInWorld))
         {
            _scrollbarInWorld.destroy();
            _scrollbarInWorld = null;
         }
         _worldSelectCallback = null;
         _currentSelectedUsername = "";
         _currentSelectedItem = null;
      }
      
      private static function worldBuddyListClickOnBuddyHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(_worldSelectCallback != null)
         {
            if(_currentSelectedUsername == evt.currentTarget.userName)
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
               _buddyListWorldWindow.selectedIndex = evt.currentTarget.index;
               _currentSelectedUsername = evt.currentTarget.userName;
            }
            _worldSelectCallback(_currentSelectedUsername);
         }
      }
      
      private static function buddyListClickOnBuddyHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var buddyWindow:MovieClip = MovieClip(evt.currentTarget);
         if(buddyWindow.userName.indexOf("Liza") < 0)
         {
            BuddyCard.showBuddyCard({
               "userName":buddyWindow.userName,
               "onlineStatus":buddyWindow.onlineStatus
            });
         }
         GuiManager.toolTip.resetTimerAndSetVisibility();
         AJAudio.playSubMenuBtnClick();
      }
      
      private static function buddyListOverBuddyHandler(evt:MouseEvent) : void
      {
         var displayText:String = null;
         var offsetX:int = _buddyListPopup.x - _buddyListWindow.width * 0.5 + 5;
         var offsetY:int = _buddyListPopup.y - 19.6 * 4.5 - _scrollbar.scrollYValue;
         var MC:MovieClip = MovieClip(evt.currentTarget.getChildAt(0));
         var daysSinceLastLogin:int = int(evt.currentTarget.daysSinceLastLogin);
         if(Boolean(evt.currentTarget.avNameTxt))
         {
            displayText = LocalizationManager.translateIdOnly(11251);
         }
         else if(daysSinceLastLogin == 0)
         {
            displayText = LocalizationManager.translateIdOnly(11252);
         }
         else if(daysSinceLastLogin == 1)
         {
            displayText = LocalizationManager.translateIdOnly(11253);
         }
         else if(daysSinceLastLogin > 1 && daysSinceLastLogin < 31)
         {
            displayText = LocalizationManager.translateIdAndInsertOnly(11254,daysSinceLastLogin);
         }
         else if(daysSinceLastLogin > 30 || daysSinceLastLogin == -1)
         {
            displayText = LocalizationManager.translateIdOnly(11255);
         }
         else
         {
            displayText = LocalizationManager.translateIdOnly(11256);
         }
         GuiManager.toolTip.init(GuiManager.guiLayer,displayText,0,0);
         GuiManager.toolTip.setPos(offsetX + MC.x + GuiManager.toolTip.width * 0.5,offsetY + evt.currentTarget.y);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private static function buddyListOutBuddyHandler(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function buddyListBtnHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
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
         if(Boolean(_buddyListBtn))
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
      
      private static function glowTimerHandler(te:TimerEvent) : void
      {
         _glowTimer.stop();
         if(Boolean(_buddyListBtn))
         {
            _buddyListBtn.glow.visible = false;
         }
      }
      
      private static function onSearchBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         _playerSearch = new PlayerSearch();
         _playerSearch.init();
         DarkenManager.showLoadingSpiral(true);
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private static function onSearchBtnOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14638),180,305);
         GuiManager.toolTip.startTimer(e);
      }
      
      private static function onSearchBtnOut(e:MouseEvent) : void
      {
         e.stopPropagation();
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
         if(Boolean(_buddyListContent))
         {
            _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onSearchBtn);
            _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_OVER,onSearchBtnOver);
            _buddyListContent.searchBtn.removeEventListener(MouseEvent.MOUSE_OUT,onSearchBtnOut);
         }
      }
   }
}

