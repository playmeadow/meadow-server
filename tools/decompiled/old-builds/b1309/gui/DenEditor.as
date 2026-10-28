package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import collection.DenItemCollection;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBPopup;
   import com.sbi.popup.SBYesNoPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   import gui.itemWindows.ItemWindowOriginal;
   import localization.LocalizationManager;
   import room.DenItemHolder;
   import room.DenItemHolderEvent;
   import room.RoomManagerWorld;
   import trade.TutorialPopups;
   
   public class DenEditor
   {
      
      public static var closeCallback:Function;
      
      public static var openCallback:Function;
      
      public static var staticEditor:MovieClip;
      
      private const NUM_VIS_X_WIN:int = 10;
      
      private const NUM_VIS_Y_WIN:int = 1;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const WARNING_ITEM_COUNT:int = 98;
      
      private const MAX_PLACED_ITEMS:int = 101;
      
      private const ADDITIONAL_ITEMS_FOR_MEMBERS:int = 200;
      
      private const DEN_EDIT_TUTORIAL_WELCOME:int = 0;
      
      private const DEN_EDIT_TUTORIAL_PLACE_ITEM:int = 1;
      
      private const DEN_EDIT_TUTORIAL_ITEM_PLACED:int = 2;
      
      private const DEN_EDIT_TUTORIAL_DOING_WELL:int = 3;
      
      private const DEN_EDIT_TUTORIAL_DOING_WELL_GIFT:int = 4;
      
      private const DEN_EDIT_TUTORIAL_SHOP:int = 5;
      
      private const OFFSET_BETWEEN_TAB_DN_BTNS:Number = 44.2;
      
      private const OFFSET_BETWEEN_TAB_UP_BTNS:int = 43;
      
      private var _denEditor:MovieClip;
      
      private var _playerAvatar:Avatar;
      
      private var _numItems:int;
      
      private var _currItems:DenItemCollection;
      
      private var _allNormalDenItems:DenItemCollection;
      
      private var _themeItems:DenItemCollection;
      
      private var _audioItems:DenItemCollection;
      
      private var _petItems:DenItemCollection;
      
      private var _toyItems:DenItemCollection;
      
      private var _plantItems:DenItemCollection;
      
      private var _furnitureItems:DenItemCollection;
      
      private var _wallItems:DenItemCollection;
      
      private var _allWindows:WindowAndScrollbarGenerator;
      
      private var _themeWindows:WindowAndScrollbarGenerator;
      
      private var _petWindows:WindowAndScrollbarGenerator;
      
      private var _toyWindows:WindowAndScrollbarGenerator;
      
      private var _plantWindows:WindowAndScrollbarGenerator;
      
      private var _furnitureWindows:WindowAndScrollbarGenerator;
      
      private var _wallWindows:WindowAndScrollbarGenerator;
      
      private var _delayGiftTimer:Timer;
      
      private var _audioItemWindows:WindowAndScrollbarGenerator;
      
      private var _numAudioItemsLastDrawn:int;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mainHud:MovieClip;
      
      private var _glowTimer:Timer;
      
      private var _shop:Shop;
      
      private var _recycle:RecycleItems;
      
      private var _denLock:MovieClip;
      
      private var _denLockPopup:SBPopup;
      
      private var _denAudio:MovieClip;
      
      private var _denAudioPopup:SBPopup;
      
      private var _isRecycling:Boolean;
      
      private var _roomMgr:RoomManagerWorld;
      
      private var _denItemHolder:DenItemHolder;
      
      private var _currPlacementMax:int;
      
      private var _currWarningCount:int;
      
      private var _agreeBox:GuiCheckBox;
      
      private var _denLockToggleCallback:Function;
      
      public function DenEditor()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:MovieClip) : void
      {
         _playerAvatar = param1;
         _denEditor = GETDEFINITIONBYNAME("DenEditorAsset");
         _guiLayer = param2;
         _mainHud = param3;
         staticEditor = _denEditor;
         _currPlacementMax = gMainFrame.userInfo.isMember || (gMainFrame.userInfo.pendingFlags & 1 << 1) > 0 ? 101 + 200 : 101;
         _currWarningCount = gMainFrame.userInfo.isMember || (gMainFrame.userInfo.pendingFlags & 1 << 1) > 0 ? 98 + 200 : 98;
         _roomMgr = RoomManagerWorld.instance;
         _denItemHolder = _roomMgr.denItemHolder;
         _guiLayer.addChild(_denEditor);
         initAssetVisibility();
         setupPlayerItems();
         DenXtCommManager.denEditorDIResponseCallback = diResponseCallback;
         _denItemHolder.addEventListener("OnItemRemoved",onDenItemRemoved,false,0,true);
         _denItemHolder.addEventListener("OnSaveState",onDenSaveState,false,0,true);
         addListeners();
      }
      
      public function destroy() : void
      {
         _denItemHolder.removeEventListener("OnItemRemoved",onDenItemRemoved);
         _denItemHolder.removeEventListener("OnSaveState",onDenSaveState);
         removeListeners();
         _guiLayer.removeChild(_denEditor);
         if(_denLockPopup)
         {
            _denLockPopup.destroy();
         }
         if(_denAudioPopup)
         {
            _denAudioPopup.destroy();
         }
         if(!_mainHud.visible)
         {
            _mainHud.visible = true;
         }
         closeCallback = null;
         openCallback = null;
         onRecycleClose();
         _denEditor = null;
         _currItems = null;
         _allNormalDenItems = null;
         _petItems = null;
         _themeItems = null;
         _audioItems = null;
         _toyItems = null;
         _plantItems = null;
         _furnitureItems = null;
         _wallItems = null;
         clearItemWindows();
         TutorialPopups.closeTalkingTutorialPopup();
         _isRecycling = false;
         _numAudioItemsLastDrawn = 0;
         DenXtCommManager.denEditorDIResponseCallback = null;
         if(_glowTimer)
         {
            _glowTimer.removeEventListener("timer",glowTimerHandler);
            _glowTimer.reset();
            _glowTimer = null;
         }
      }
      
      public function closeDenCustomization(param1:Boolean = false) : void
      {
         if(!param1)
         {
            if(isDenHudOpen)
            {
               _denItemHolder.removeHighlightState();
               onClose(null);
               onRecycleClose();
               onShopClose(false);
            }
            reloadDenItems();
         }
      }
      
      public function resetPetWindowListAndUpdateBtns() : void
      {
         if(_petWindows)
         {
            _petWindows.destroy();
            _petWindows = null;
         }
         if(!_denEditor.petBtnDn.visible)
         {
            _denEditor.petBtnDn.visible = true;
         }
         drawItemWindows();
      }
      
      public function updateSwitchRecycleBtnVisibility() : void
      {
         if(!_denEditor.switchDenBtn.visible)
         {
            if(gMainFrame.userInfo.numLogins >= 2 || gMainFrame.userInfo.userVarCache.getUserVarValueById(3) > 1)
            {
               _denEditor.switchDenBtn.visible = true;
               _denEditor.recycleBtn.visible = true;
            }
         }
      }
      
      public function clearItemWindows() : void
      {
         if(_allWindows)
         {
            _allWindows.destroy();
            _allWindows = null;
         }
         if(_themeWindows)
         {
            _themeWindows.destroy();
            _themeWindows = null;
         }
         if(_petWindows)
         {
            _petWindows.destroy();
            _petWindows = null;
         }
         if(_plantWindows)
         {
            _plantWindows.destroy();
            _plantWindows = null;
         }
         if(_furnitureWindows)
         {
            _furnitureWindows.destroy();
            _furnitureWindows = null;
         }
         if(_petWindows)
         {
            _petWindows.destroy();
            _petWindows = null;
         }
         if(_audioItemWindows)
         {
            _audioItemWindows.destroy();
            _audioItemWindows = null;
         }
         if(_wallWindows)
         {
            _wallWindows.destroy();
            _wallWindows = null;
         }
      }
      
      public function refreshDenLockSettings() : void
      {
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            _denEditor.lockBtn.denLock.visible = true;
            _denEditor.lockBtn.denUnlock.visible = false;
         }
         else
         {
            _denEditor.lockBtn.denLock.visible = false;
            _denEditor.lockBtn.denUnlock.visible = true;
         }
      }
      
      public function clearDenInUseItems() : void
      {
         var _loc2_:DenItemCollection = null;
         var _loc1_:int = 0;
         _loc2_ = _audioItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_audioItemWindows)
         {
            _audioItemWindows.callUpdateInWindow();
         }
         _loc2_ = _allNormalDenItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_allWindows)
         {
            _allWindows.callUpdateInWindow();
         }
         _loc2_ = _petItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_petWindows)
         {
            _petWindows.callUpdateInWindow();
         }
         _loc2_ = _toyItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_toyWindows)
         {
            _toyWindows.callUpdateInWindow();
         }
         _loc2_ = _plantItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_plantWindows)
         {
            _plantWindows.callUpdateInWindow();
         }
         _loc2_ = _furnitureItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_furnitureWindows)
         {
            _furnitureWindows.callUpdateInWindow();
         }
         _loc2_ = _wallItems;
         _loc1_ = 0;
         while(_loc1_ < _loc2_.length)
         {
            _loc2_.getDenItem(_loc1_).categoryId = 0;
            _loc1_++;
         }
         if(_wallWindows)
         {
            _wallWindows.callUpdateInWindow();
         }
      }
      
      public function reloadDenItems() : void
      {
         clearItemWindows();
         setupPlayerItems();
      }
      
      public function get isDenHudOpen() : Boolean
      {
         return _denEditor ? _denEditor.bottomHud.visible : false;
      }
      
      public function openDenLockPopup(param1:Function) : void
      {
         _denLockToggleCallback = param1;
         lockContainerHandler(null);
      }
      
      public function onDenTutorialGiftClose() : void
      {
         if(_denEditor.bottomHud.visible && !gMainFrame.userInfo.userVarCache.isBitSet(379,5))
         {
            TutorialPopups.openTalkingTutorial(18658,18662,10,115,_denEditor.shopBtn);
         }
         else
         {
            TutorialPopups.closeTalkingTutorialPopup();
         }
      }
      
      public function showDenEditor(param1:Boolean) : void
      {
         _denEditor.bottomHud.visible = param1;
         _mainHud.visible = param1;
      }
      
      private function initAssetVisibility() : void
      {
         _glowTimer = new Timer(10000);
         _glowTimer.addEventListener("timer",glowTimerHandler,false,0,true);
         _glowTimer.start();
         toggleBottomHudVisibility();
         _denEditor.normBtnUp.visible = true;
         _denEditor.themeBtnUp.visible = false;
         _denEditor.petBtnUp.visible = false;
         _denEditor.toyBtnUp.visible = false;
         _denEditor.plantBtnUp.visible = false;
         _denEditor.furnitureBtnUp.visible = false;
         _denEditor.wallBtnUp.visible = false;
         if(gMainFrame.userInfo.userVarCache.getUserVarValueById(212) <= 0)
         {
            _denEditor.petBtnDn.visible = false;
         }
         if(gMainFrame.userInfo.numLogins < 2 && gMainFrame.userInfo.userVarCache.getUserVarValueById(3) <= 1)
         {
            _denEditor.switchDenBtn.visible = false;
            _denEditor.recycleBtn.visible = false;
         }
         _denEditor.denAudioPopup.visible = false;
         _denEditor.itemBlock.glowCont.glow.visible = false;
         _denEditor.lockBtn.denLock.initToolTip(_guiLayer,LocalizationManager.translateIdOnly(14639),900 * 0.5,105);
         _denEditor.lockBtn.denUnlock.initToolTip(_guiLayer,LocalizationManager.translateIdOnly(14640),900 * 0.5,105);
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            _denEditor.lockBtn.denLock.visible = true;
            _denEditor.lockBtn.denUnlock.visible = false;
         }
         else
         {
            _denEditor.lockBtn.denLock.visible = false;
            _denEditor.lockBtn.denUnlock.visible = true;
         }
         _denEditor.searchBar.searchTxt.visible = false;
         _denEditor.searchBar.shortTextWidth = _denEditor.searchBar.txt.width + 10;
         _denEditor.searchBar.wideTextWidth = _denEditor.searchBar.searchTxt.width + 10;
         _denEditor.searchBar.b.xBtn.visible = false;
      }
      
      private function setupPlayerItems() : void
      {
         var _loc1_:DenItemCollection = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         if(_playerAvatar && _playerAvatar.inventoryDenFull && _playerAvatar.inventoryDenFull.denItemCollection.length > 0)
         {
            _loc1_ = new DenItemCollection(_playerAvatar.inventoryDenFull.denItemCollection.concatCollection(null));
         }
         else if(gMainFrame.userInfo.playerUserInfo.denItemsFull)
         {
            _loc1_ = new DenItemCollection(gMainFrame.userInfo.playerUserInfo.denItemsFull.concatCollection(null));
         }
         _currItems = new DenItemCollection();
         _numAudioItemsLastDrawn = 0;
         if(AvatarManager.roomEnviroType == 2 || AvatarManager.roomEnviroType == 0)
         {
            _petItems = gMainFrame.userInfo.getMyPetsInDenByEnviroType(0);
         }
         else
         {
            _petItems = gMainFrame.userInfo.getMyPetsInDenByEnviroType(1);
         }
         if(_loc1_ && _loc1_.length > 0)
         {
            _loc4_ = int(_loc1_.length);
            _allNormalDenItems = new DenItemCollection();
            _audioItems = new DenItemCollection();
            _loc2_ = 0;
            while(_loc2_ < _loc4_)
            {
               if(_loc1_.getDenItem(_loc2_).typeCatId == 4)
               {
                  _audioItems.pushDenItem(_loc1_.getDenItem(_loc2_));
               }
               else if(_loc1_.getDenItem(_loc2_).enviroType == AvatarManager.roomEnviroType)
               {
                  _allNormalDenItems.pushDenItem(_loc1_.getDenItem(_loc2_));
               }
               _loc2_++;
            }
            _themeItems = Utility.sortItems(_allNormalDenItems,0,2,3,-1,true) as DenItemCollection;
            _toyItems = Utility.sortItems(_allNormalDenItems,0,6,-1,-1,true) as DenItemCollection;
            _plantItems = Utility.sortItems(_allNormalDenItems,0,5,-1,-1,true) as DenItemCollection;
            _furnitureItems = Utility.sortItems(_allNormalDenItems,0,0,-1,-1,true) as DenItemCollection;
            _wallItems = Utility.sortItems(_allNormalDenItems,0,1,-1,-1,true) as DenItemCollection;
            setupTabsVisibilityAndPosition();
            _loc3_ = null;
            if(_denEditor.normBtnUp.visible)
            {
               _loc3_ = _denEditor.normBtnUp;
            }
            else if(_denEditor.themeBtnUp.visible)
            {
               _loc3_ = _denEditor.themeBtnUp;
            }
            else if(_denEditor.petBtnUp.visible)
            {
               _loc3_ = _denEditor.petBtnUp;
            }
            else if(_denEditor.toyBtnUp.visible)
            {
               _loc3_ = _denEditor.toyBtnUp;
            }
            else if(_denEditor.plantBtnUp.visible)
            {
               _loc3_ = _denEditor.plantBtnUp;
            }
            else if(_denEditor.furnitureBtnUp.visible)
            {
               _loc3_ = _denEditor.furnitureBtnUp;
            }
            else if(_denEditor.wallBtnUp.visible)
            {
               _loc3_ = _denEditor.wallBtnUp;
            }
            if(_loc3_)
            {
               setupTabs(_loc3_,false);
            }
         }
         else
         {
            _denEditor.normBtnUp.visible = true;
            _denEditor.themeBtnUp.visible = false;
            _denEditor.petBtnUp.visible = false;
            _allNormalDenItems = new DenItemCollection();
            _themeItems = new DenItemCollection();
            _audioItems = new DenItemCollection();
            _plantItems = new DenItemCollection();
            _toyItems = new DenItemCollection();
            _furnitureItems = new DenItemCollection();
            _wallItems = new DenItemCollection();
            _numItems = 0;
         }
      }
      
      private function setupTabsVisibilityAndPosition() : void
      {
         var _loc1_:int = 1;
         if(_furnitureItems.length > 0)
         {
            _denEditor.furnitureBtnDn.visible = true;
            _denEditor.furnitureBtnDn.x = _denEditor.normBtnDn.x + 44.2;
            _denEditor.furnitureBtnUp.x = _denEditor.normBtnUp.x + 43;
            _loc1_++;
         }
         else
         {
            _denEditor.furnitureBtnDn.visible = false;
         }
         if(_toyItems.length > 0)
         {
            _denEditor.toyBtnDn.visible = true;
            _denEditor.toyBtnDn.x = _denEditor.toyBtnDn.x = _denEditor.normBtnDn.x + 44.2 * _loc1_;
            _denEditor.toyBtnUp.x = _denEditor.normBtnUp.x + 43 * _loc1_;
            _loc1_++;
         }
         else
         {
            _denEditor.toyBtnDn.visible = false;
         }
         if(_plantItems.length > 0)
         {
            _denEditor.plantBtnDn.visible = true;
            _denEditor.plantBtnDn.x = _denEditor.normBtnDn.x + 44.2 * _loc1_;
            _denEditor.plantBtnUp.x = _denEditor.normBtnUp.x + 43 * _loc1_;
            _loc1_++;
         }
         else
         {
            _denEditor.plantBtnDn.visible = false;
         }
         if(_themeItems.length > 0)
         {
            _denEditor.themeBtnDn.visible = true;
            _denEditor.themeBtnDn.x = _denEditor.normBtnDn.x + 44.2 * _loc1_;
            _denEditor.themeBtnUp.x = _denEditor.normBtnUp.x + 43 * _loc1_;
            _loc1_++;
         }
         else
         {
            _denEditor.themeBtnDn.visible = false;
         }
         if(_wallItems.length > 0)
         {
            _denEditor.wallBtnDn.visible = true;
            _denEditor.wallBtnDn.x = _denEditor.normBtnDn.x + 44.2 * _loc1_;
            _denEditor.wallBtnUp.x = _denEditor.normBtnUp.x + 43 * _loc1_;
            _loc1_++;
         }
         else
         {
            _denEditor.wallBtnDn.visible = false;
         }
         if(_petItems.length > 0)
         {
            _denEditor.petBtnDn.visible = true;
            _denEditor.petBtnDn.x = _denEditor.normBtnDn.x + 44.2 * _loc1_;
            _denEditor.petBtnUp.x = _denEditor.normBtnUp.x + 43 * _loc1_;
            _loc1_++;
         }
         else
         {
            _denEditor.petBtnDn.visible = false;
         }
      }
      
      private function diResponseCallback() : void
      {
         _playerAvatar = AvatarManager.playerAvatar;
         resetWindowsAndTabsToNormal();
      }
      
      private function onShopRecycleClose(param1:Boolean = false, param2:Boolean = false) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = diResponseCallback;
         if(param1)
         {
            resetWindowsAndTabsToNormal();
         }
      }
      
      private function resetWindowsAndTabsToNormal() : void
      {
         _denEditor.normBtnUp.visible = true;
         _denEditor.themeBtnUp.visible = false;
         _denEditor.petBtnUp.visible = false;
         _denEditor.toyBtnUp.visible = false;
         _denEditor.plantBtnUp.visible = false;
         _denEditor.furnitureBtnUp.visible = false;
         _denEditor.wallBtnUp.visible = false;
         if(_allNormalDenItems && _allNormalDenItems.length > 0)
         {
            _currItems = _allNormalDenItems;
         }
         clearItemWindows();
         setupPlayerItems();
      }
      
      private function drawItemWindows() : void
      {
         var _loc1_:WindowAndScrollbarGenerator = null;
         while(_denEditor.itemBlock.itemBlock.numChildren > 1)
         {
            _denEditor.itemBlock.itemBlock.removeChildAt(_denEditor.itemBlock.itemBlock.numChildren - 1);
         }
         var _loc2_:WindowAndScrollbarGenerator = currItemWindow;
         if(_loc2_ == null)
         {
            if(_currItems)
            {
               _numItems = Math.max(_currItems.length,10);
            }
            else
            {
               _numItems = 10;
            }
            _loc1_ = new WindowAndScrollbarGenerator();
            _loc1_.init(_denEditor.itemBlock.itemBlock.width,_denEditor.itemBlock.itemBlock.height,0,0,10,1,0,2,2,0,2 * 0.5,ItemWindowOriginal,_currItems.getCoreArray(),"icon",0,{
               "mouseDown":winMouseDown,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut,
               "memberOnlyDown":memberOnlyDown
            },{"isPetItem":_currItems == _petItems},null,false,true,true,true,true);
            _loc2_ = currItemWindow = _loc1_;
         }
         if(_currItems)
         {
            _denEditor.itemBlock.itemBlock.addChild(_loc2_);
         }
         if(_numItems <= 10 + 1)
         {
            _denEditor.lArrowBtn.activateGrayState(true);
            _denEditor.rArrowBtn.activateGrayState(true);
         }
         else
         {
            _denEditor.lArrowBtn.activateGrayState(false);
            _denEditor.rArrowBtn.activateGrayState(false);
         }
      }
      
      private function get currItemWindow() : WindowAndScrollbarGenerator
      {
         var _loc1_:WindowAndScrollbarGenerator = null;
         if(_denEditor.normBtnUp.visible)
         {
            if(_allWindows)
            {
               _loc1_ = _allWindows;
            }
         }
         else if(_denEditor.themeBtnUp.visible)
         {
            if(_themeWindows)
            {
               _loc1_ = _themeWindows;
            }
         }
         else if(_denEditor.petBtnUp.visible)
         {
            if(_petWindows)
            {
               _loc1_ = _petWindows;
            }
         }
         else if(_denEditor.toyBtnUp.visible)
         {
            if(_toyWindows)
            {
               _loc1_ = _toyWindows;
            }
         }
         else if(_denEditor.plantBtnUp.visible)
         {
            if(_plantWindows)
            {
               _loc1_ = _plantWindows;
            }
         }
         else if(_denEditor.furnitureBtnUp.visible)
         {
            if(_furnitureWindows)
            {
               _loc1_ = _furnitureWindows;
            }
         }
         else if(_denEditor.wallBtnUp.visible)
         {
            if(_wallWindows)
            {
               _loc1_ = _wallWindows;
            }
         }
         return _loc1_;
      }
      
      private function set currItemWindow(param1:WindowAndScrollbarGenerator) : void
      {
         if(_denEditor.normBtnUp.visible)
         {
            _allWindows = param1;
         }
         else if(_denEditor.themeBtnUp.visible)
         {
            _themeWindows = param1;
         }
         else if(_denEditor.petBtnUp.visible)
         {
            _petWindows = param1;
         }
         else if(_denEditor.toyBtnUp.visible)
         {
            _toyWindows = param1;
         }
         else if(_denEditor.plantBtnUp.visible)
         {
            _plantWindows = param1;
         }
         else if(_denEditor.furnitureBtnUp.visible)
         {
            _furnitureWindows = param1;
         }
         else if(_denEditor.wallBtnUp.visible)
         {
            _wallWindows = param1;
         }
      }
      
      private function scrollBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            currItemWindow.handleScrollBtnClick(param1.currentTarget.name == _denEditor.lArrowBtn.name);
         }
      }
      
      private function customizeBtnHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/denCustomize");
         param1.stopPropagation();
         toggleBottomHudVisibility();
         if(!gMainFrame.userInfo.userVarCache.isBitSet(379,0))
         {
            AchievementXtCommManager.requestSetUserVar(379,0);
         }
         if(openCallback != null)
         {
            openCallback();
         }
      }
      
      private function customizeBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14641),730,450);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function toggleBottomHudVisibility() : void
      {
         _denEditor.bottomHud.visible = !_denEditor.bottomHud.visible;
         _mainHud.visible = !_denEditor.bottomHud.visible;
         _mainHud.furnBtn.visible = _mainHud.visible;
         if(_denEditor.bottomHud.visible)
         {
            _roomMgr.setRoomMode(1);
            GuiManager.closeAnyHudPopups();
            if(!gMainFrame.userInfo.userVarCache.isBitSet(379,1))
            {
               TutorialPopups.openTalkingTutorial(18655,18662,10,115,null,_denEditor.itemBlock.glowCont.glow);
               _mainHud.furnBtn.setButtonState(1);
            }
            else if(!gMainFrame.userInfo.userVarCache.isBitSet(379,2))
            {
               TutorialPopups.openTalkingTutorial(18656,18662,10,115,null);
            }
            else if(!gMainFrame.userInfo.userVarCache.isBitSet(379,5))
            {
               TutorialPopups.openTalkingTutorial(18658,18662,10,115,_denEditor.shopBtn);
            }
         }
         else
         {
            if(!gMainFrame.userInfo.userVarCache.isBitSet(379,0))
            {
               TutorialPopups.openTalkingTutorial(18654,18662,10,115,_mainHud.furnBtn);
            }
            else
            {
               _mainHud.furnBtn.setButtonState(1);
               TutorialPopups.closeTalkingTutorialPopup();
            }
            _roomMgr.setRoomMode(0);
         }
      }
      
      public function toggleEditorHud(param1:Boolean) : void
      {
         _denEditor.bottomHud.visible = param1;
         onDenLockPopupClose(null);
         onAudioPopupClose(null);
         if(param1)
         {
            GuiManager.closeAnyHudPopups();
         }
      }
      
      private function setupTabs(param1:MovieClip, param2:Boolean) : void
      {
         switch(param1)
         {
            case _denEditor.normBtnDn:
            case _denEditor.normBtnUp:
               if(param2)
               {
                  _denEditor.normBtnUp.visible = true;
               }
               _denEditor.itemCountTxt.text = _allNormalDenItems.length + "/" + Shop.maxDenItems;
               _currItems = _allNormalDenItems;
               break;
            case _denEditor.themeBtnDn:
            case _denEditor.themeBtnUp:
               if(param2)
               {
                  _denEditor.themeBtnUp.visible = true;
               }
               _denEditor.itemCountTxt.text = _themeItems.length;
               _currItems = _themeItems;
               break;
            case _denEditor.petBtnDn:
            case _denEditor.petBtnUp:
               if(param2)
               {
                  _denEditor.petBtnUp.visible = true;
               }
               if(_petItems == null)
               {
                  if(AvatarManager.roomEnviroType == 2 || AvatarManager.roomEnviroType == 0)
                  {
                     _petItems = gMainFrame.userInfo.getMyPetsInDenByEnviroType(0);
                  }
                  else
                  {
                     _petItems = gMainFrame.userInfo.getMyPetsInDenByEnviroType(1);
                  }
               }
               _denEditor.itemCountTxt.text = _petItems.length;
               _currItems = _petItems;
               break;
            case _denEditor.toyBtnDn:
            case _denEditor.toyBtnUp:
               if(param2)
               {
                  _denEditor.toyBtnUp.visible = true;
               }
               _currItems = _toyItems;
               _denEditor.itemCountTxt.text = _toyItems.length;
               break;
            case _denEditor.plantBtnDn:
            case _denEditor.plantBtnUp:
               if(param2)
               {
                  _denEditor.plantBtnUp.visible = true;
               }
               _currItems = _plantItems;
               _denEditor.itemCountTxt.text = _plantItems.length;
               break;
            case _denEditor.furnitureBtnDn:
            case _denEditor.furnitureBtnUp:
               if(param2)
               {
                  _denEditor.furnitureBtnUp.visible = true;
               }
               _currItems = _furnitureItems;
               _denEditor.itemCountTxt.text = _furnitureItems.length;
               break;
            case _denEditor.wallBtnDn:
            case _denEditor.wallBtnUp:
               if(param2)
               {
                  _denEditor.wallBtnUp.visible = true;
               }
               _currItems = _wallItems;
               _denEditor.itemCountTxt.text = _wallItems.length;
               break;
            default:
               DebugUtility.debugTrace("WARNING: Bad btn clicked in tabBtnHandler");
               return;
         }
         _numItems = _currItems.length;
         drawItemWindows();
      }
      
      private function tabBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _denEditor.normBtnUp.visible = false;
         _denEditor.themeBtnUp.visible = false;
         _denEditor.petBtnUp.visible = false;
         _denEditor.toyBtnUp.visible = false;
         _denEditor.plantBtnUp.visible = false;
         _denEditor.furnitureBtnUp.visible = false;
         _denEditor.wallBtnUp.visible = false;
         setupTabs(param1.currentTarget as MovieClip,true);
      }
      
      private function tabBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Point = param1.currentTarget.localToGlobal(new Point(param1.currentTarget.width * 0.5,-10));
         switch(param1.currentTarget)
         {
            case _denEditor.normBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24730),_loc2_.x,_loc2_.y);
               break;
            case _denEditor.themeBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24735),_loc2_.x,_loc2_.y);
               break;
            case _denEditor.petBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24736),_loc2_.x,_loc2_.y);
               break;
            case _denEditor.plantBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24734),_loc2_.x,_loc2_.y);
               break;
            case _denEditor.toyBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24732),_loc2_.x,_loc2_.y);
               break;
            case _denEditor.furnitureBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24731),_loc2_.x,_loc2_.y);
               break;
            case _denEditor.wallBtnDn:
               GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(24737),_loc2_.x,_loc2_.y);
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc3_:WindowAndScrollbarGenerator = null;
         var _loc2_:MovieClip = null;
         if(param1.currentTarget.cir.currentFrameLabel == "green")
         {
            param1.currentTarget.cir.gotoAndStop("over");
         }
         else
         {
            _loc3_ = null;
            if(!param1.currentTarget.isAudio)
            {
               _loc3_ = currItemWindow;
            }
            else
            {
               _loc3_ = _audioItemWindows;
            }
            if(_loc3_)
            {
               _loc2_ = MovieClip(_loc3_.bg.getChildAt(param1.currentTarget.index));
               if(_loc2_.cir.currentFrameLabel == "down")
               {
                  _loc2_.cir.gotoAndStop("downMouse");
               }
               else if(_loc2_.cir.currentFrameLabel != "downMouse")
               {
                  _loc2_.cir.gotoAndStop("over");
               }
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         var _loc3_:WindowAndScrollbarGenerator = null;
         var _loc2_:MovieClip = null;
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "over" && param1.currentTarget.isActivePet)
            {
               param1.currentTarget.cir.gotoAndStop("green");
            }
            else
            {
               _loc3_ = currItemWindow;
               if(_loc3_)
               {
                  _loc2_ = MovieClip(_loc3_.bg.getChildAt(param1.currentTarget.index));
                  if(_loc2_.cir.currentFrameLabel == "downMouse")
                  {
                     _loc2_.cir.gotoAndStop("down");
                  }
                  else if(_loc2_.cir.currentFrameLabel != "down")
                  {
                     _loc2_.cir.gotoAndStop("up");
                  }
               }
            }
         }
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:DenItem = null;
         var _loc5_:int = 0;
         var _loc6_:WindowAndScrollbarGenerator = null;
         var _loc4_:MovieClip = null;
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == "previewBtn")
         {
            _loc2_ = param1.currentTarget.parent.parent.currItem;
            GuiManager.openMasterpiecePreview(_loc2_.uniqueImageId,_loc2_.uniqueImageCreator,_loc2_.version);
         }
         else
         {
            if(param1.currentTarget.isActivePet)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(14714));
               return;
            }
            _loc2_ = param1.currentTarget.isAudio ? _audioItems.getDenItem(param1.currentTarget.index) : _currItems.getDenItem(param1.currentTarget.index);
            if(_loc2_.categoryId == 0)
            {
               if(_loc2_.sortId != 4 && _denItemHolder.numberOfInUseItems >= _currWarningCount)
               {
                  if(_denItemHolder.numberOfInUseItems >= _currPlacementMax)
                  {
                     if(!gMainFrame.userInfo.isMember || (gMainFrame.userInfo.pendingFlags & 2) < 0)
                     {
                        UpsellManager.displayPopup("200Items","additionalPlacedDenItem");
                     }
                     else
                     {
                        new SBOkPopup(_guiLayer,getWarningMessage(_denItemHolder.numberOfInUseItems + 1));
                     }
                     return;
                  }
                  new SBOkPopup(_guiLayer,getWarningMessage(_denItemHolder.numberOfInUseItems + 1));
               }
               if(param1.currentTarget.isAudio)
               {
                  _loc5_ = getLastPlacedId();
                  if(_loc5_ != -1)
                  {
                     MovieClip(_audioItemWindows.bg.getChildAt(_loc5_)).resetAudioDown();
                     _audioItems.getDenItem(_loc5_).categoryId = 0;
                  }
                  MovieClip(_audioItemWindows.bg.getChildAt(param1.currentTarget.index)).setAudioDown();
               }
               placeItemInRoom(_loc2_);
               if(!gMainFrame.userInfo.userVarCache.isBitSet(379,1) && !gMainFrame.userInfo.userVarCache.isBitSet(379,2))
               {
                  _denEditor.itemBlock.glowCont.glow.visible = false;
                  TutorialPopups.openTalkingTutorial(18656,18662,10,115,null);
               }
               if(!gMainFrame.userInfo.userVarCache.isBitSet(379,1))
               {
                  AchievementXtCommManager.requestSetUserVar(379,1);
               }
            }
            else
            {
               if(param1.currentTarget.isAudio)
               {
                  _loc5_ = getLastPlacedId();
                  if(param1.currentTarget.index == _loc5_)
                  {
                     return;
                  }
               }
               _denItemHolder.removeItem(_loc2_.invIdx,_loc2_.refId);
               _loc2_.categoryId = 0;
               if(gMainFrame.userInfo.userVarCache.isBitSet(379,1) && !gMainFrame.userInfo.userVarCache.isBitSet(379,2))
               {
                  AchievementXtCommManager.requestSetUserVar(379,2);
               }
               if(gMainFrame.userInfo.userVarCache.isBitSet(379,1) && !gMainFrame.userInfo.userVarCache.isBitSet(379,3))
               {
                  DarkenManager.addInvisibleBlockBG();
                  TutorialPopups.openTalkingTutorial(21388,18662,10,115,null);
                  _delayGiftTimer = new Timer(4000);
                  _delayGiftTimer.addEventListener("timer",onDelayGiftTimer,false,0,true);
                  _delayGiftTimer.start();
               }
            }
            if(!param1.currentTarget.isAudio)
            {
               _loc6_ = currItemWindow;
               if(_loc6_)
               {
                  _loc4_ = MovieClip(_loc6_.bg.getChildAt(param1.currentTarget.index));
                  if(_loc6_ == _themeWindows)
                  {
                     _themeItems.getDenItem(_loc4_.index).categoryId = _loc2_.categoryId;
                  }
                  else if(_loc6_ == _toyWindows)
                  {
                     _toyItems.getDenItem(_loc4_.index).categoryId = _loc2_.categoryId;
                  }
                  else if(_loc6_ == _furnitureWindows)
                  {
                     _furnitureItems.getDenItem(_loc4_.index).categoryId = _loc2_.categoryId;
                  }
                  else if(_loc6_ == _plantWindows)
                  {
                     _plantItems.getDenItem(_loc4_.index).categoryId = _loc2_.categoryId;
                  }
                  else if(_loc6_ == _wallWindows)
                  {
                     _wallItems.getDenItem(_loc4_.index).categoryId = _loc2_.categoryId;
                  }
                  _loc3_ = 0;
                  while(_loc3_ < _allNormalDenItems.length)
                  {
                     if(_allNormalDenItems.getDenItem(_loc3_).invIdx == _loc2_.invIdx)
                     {
                        _allNormalDenItems.getDenItem(_loc3_).categoryId = _loc2_.categoryId;
                        break;
                     }
                     _loc3_++;
                  }
                  if(_loc4_.cir.currentFrameLabel == "downMouse")
                  {
                     _loc4_.cir.gotoAndStop("over");
                  }
                  else
                  {
                     _loc4_.cir.gotoAndStop("downMouse");
                  }
               }
            }
            AJAudio.playSubMenuBtnClick();
         }
      }
      
      private function getWarningMessage(param1:int) : String
      {
         var _loc3_:int = _currPlacementMax - param1;
         var _loc2_:String = "";
         if(_loc3_ > 1)
         {
            _loc2_ = LocalizationManager.translateIdAndInsertOnly(11262,_loc3_);
         }
         else if(_loc3_ == 1)
         {
            _loc2_ = LocalizationManager.translateIdAndInsertOnly(11263,_loc3_);
         }
         else if(_loc3_ == 0)
         {
            _loc2_ = LocalizationManager.translateIdOnly(11264);
         }
         else
         {
            _loc2_ = LocalizationManager.translateIdOnly(11265);
         }
         return _loc2_;
      }
      
      private function memberOnlyDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         UpsellManager.displayPopup("denItems","placeDenItem/" + _currItems.getDenItem(param1.currentTarget.index).defId);
      }
      
      private function memberOnlyDownAudio(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         UpsellManager.displayPopup("denAudio","selectDenAudio/" + _audioItems.getDenItem(param1.currentTarget.index).defId);
      }
      
      private function placeItemInRoom(param1:DenItem) : void
      {
         var _loc2_:int = DenItem.getInWorldId(param1.sortId,_roomMgr.denCatId);
         param1.categoryId = _loc2_;
         _roomMgr.spawnNewDenItem({
            "i":param1.invIdx,
            "p":param1.defId << 16 | _loc2_,
            "l":param1.layerId,
            "x":0,
            "y":0,
            "c":_loc2_,
            "s":param1.sortId,
            "mg":param1.minigameDefId,
            "v":param1.version,
            "strmName":param1.strmName,
            "v2":param1.version2,
            "v3":param1.version3,
            "r":param1.refId,
            "userNameLink":"",
            "specialType":param1.specialType,
            "listLauncherId":param1.listId,
            "uniqueImageId":param1.uniqueImageId,
            "uniqueImageCreator":param1.uniqueImageCreator
         });
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         SBTracker.pop();
         if(_denLockPopup && _denLockPopup.visible)
         {
            changeDownToUpStateLock();
            _denLockPopup.close();
         }
         if(_denAudioPopup && _denAudioPopup.visible)
         {
            _denEditor.denAudio.downToUpState();
            _denAudioPopup.close();
         }
         if(param1)
         {
            param1.stopPropagation();
         }
         toggleBottomHudVisibility();
         if(closeCallback != null)
         {
            closeCallback();
         }
      }
      
      private function shopBtnHandler(param1:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         if(_shop)
         {
            _shop.destroy();
         }
         _roomMgr._bInDenShop = true;
         DenXtCommManager.saveDenItemsState();
         if(openCallback != null)
         {
            openCallback();
         }
         if(!gMainFrame.userInfo.userVarCache.isBitSet(379,5))
         {
            AchievementXtCommManager.requestSetUserVar(379,5);
            _denEditor.shopBtn.setButtonState(1);
         }
         TutorialPopups.closeTalkingTutorialPopup();
         _shop = new Shop();
         if(AvatarManager.roomEnviroType == 1)
         {
            _shop.init(51,1030,_playerAvatar,_guiLayer,onShopClose);
         }
         else
         {
            _shop.init(!gMainFrame.userInfo.userVarCache.isBitSet(379,8) ? 234 : 12,1030,_playerAvatar,_guiLayer,onShopClose);
         }
      }
      
      private function shopBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14643),770,390);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function denSwitchBtnHandler(param1:MouseEvent) : void
      {
         DenXtCommManager.saveDenItemsState();
         GuiManager.openDenRoomSwitcher(false,null,false,-1,384);
      }
      
      private function denSwitchBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14644),689,400);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function denSwitchBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onShopClose(param1:Boolean) : void
      {
         onShopRecycleClose(param1);
         if(_denAudioPopup && _denAudioPopup.visible && param1 && _shop.isAudioShop)
         {
            buildDenAudioWindows();
         }
         if(_shop.showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(379,8) && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(379,7)))
         {
            DarkenManager.addInvisibleBlockBG();
            TutorialPopups.openTalkingTutorial(18661,18662,10,115,null);
            _delayGiftTimer = new Timer(6000);
            _delayGiftTimer.addEventListener("timer",onDelayGiftTimer,false,0,true);
            _delayGiftTimer.start();
         }
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         _roomMgr._bInDenShop = false;
      }
      
      private function recycleBtnHandler(param1:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         param1.stopPropagation();
         if(_recycle)
         {
            _recycle.destroy();
         }
         DenXtCommManager.saveDenItemsState();
         _recycle = new RecycleItems();
         _recycle.init(1,_guiLayer,false,onRecycleClose,900 * 0.5,550 * 0.5);
      }
      
      private function recycleBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14645),610,400);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         onShopRecycleClose(param1);
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
      }
      
      private function onDenItemRemoved(param1:DenItemHolderEvent) : void
      {
         var _loc9_:DenItemCollection = null;
         var _loc2_:DenItem = null;
         var _loc5_:int = 0;
         var _loc3_:MovieClip = null;
         var _loc4_:WindowAndScrollbarGenerator = null;
         var _loc6_:int = 0;
         var _loc8_:int = int(param1.id);
         var _loc7_:int = param1.refId;
         if(gMainFrame.userInfo.userVarCache.isBitSet(379,1) && !gMainFrame.userInfo.userVarCache.isBitSet(379,2))
         {
            AchievementXtCommManager.requestSetUserVar(379,2);
         }
         if(gMainFrame.userInfo.userVarCache.isBitSet(379,1) && !gMainFrame.userInfo.userVarCache.isBitSet(379,3))
         {
            DarkenManager.addInvisibleBlockBG();
            TutorialPopups.openTalkingTutorial(21388,18662,10,115,null);
            _delayGiftTimer = new Timer(4000);
            _delayGiftTimer.addEventListener("timer",onDelayGiftTimer,false,0,true);
            _delayGiftTimer.start();
         }
         var _loc10_:Object = null;
         if(param1.array && param1.array.length > 0)
         {
            _loc10_ = param1.array[0];
         }
         if(_loc7_ == 0)
         {
            if(_loc10_ && _loc10_.s == 4)
            {
               _loc9_ = _audioItems;
            }
            else
            {
               _loc9_ = _allNormalDenItems;
            }
         }
         else
         {
            _loc9_ = _petItems;
         }
         if(_loc9_)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc9_.length)
            {
               if(_loc9_.getDenItem(_loc5_).invIdx == _loc8_)
               {
                  _loc2_ = _loc9_.getDenItem(_loc5_);
                  _loc2_.categoryId = 0;
                  break;
               }
               _loc5_++;
            }
            if(_currItems && _currItems.getDenItem(0) && _currItems.getDenItem(0).refId == _loc7_)
            {
               _loc4_ = currItemWindow;
               _loc6_ = _currItems.length - 1;
               while(_loc6_ >= 0)
               {
                  _loc3_ = MovieClip(_loc4_).bg.getChildAt(_loc6_);
                  _loc2_ = _currItems.getDenItem(_loc3_.index);
                  if(_loc2_.refId == _loc7_ && _loc2_.invIdx == _loc8_)
                  {
                     _loc3_.cir.gotoAndStop("up");
                     _loc2_.categoryId = 0;
                     break;
                  }
                  _loc6_--;
               }
               switch(_currItems.getDenItem(0).typeCatId)
               {
                  case 0:
                     _loc9_ = _furnitureItems;
                     _loc4_ = _furnitureWindows;
                     break;
                  case 1:
                     _loc9_ = _wallItems;
                     _loc4_ = _wallWindows;
                     break;
                  case 2:
                  case 3:
                     _loc9_ = _themeItems;
                     _loc4_ = _themeWindows;
                     break;
                  case 99:
                     _loc9_ = _petItems;
                     _loc4_ = _petWindows;
                     break;
                  case 5:
                     _loc9_ = _plantItems;
                     _loc4_ = _plantWindows;
                     break;
                  case 6:
                     _loc9_ = _toyItems;
                     _loc4_ = _toyWindows;
                     break;
                  case 4:
                     _loc9_ = _audioItems;
                     _loc4_ = _audioItemWindows;
               }
               _loc6_ = 0;
               while(_loc6_ < _loc9_.length)
               {
                  _loc2_ = _loc9_.getDenItem(_loc6_);
                  if(_loc2_.refId == _loc7_ && _loc2_.invIdx == _loc8_)
                  {
                     if(_loc4_)
                     {
                        _loc3_ = MovieClip(_loc4_).bg.getChildAt(_loc6_);
                        _loc3_.cir.gotoAndStop("up");
                     }
                     _loc2_.categoryId = 0;
                     break;
                  }
                  _loc6_++;
               }
            }
         }
      }
      
      private function onDenSaveState(param1:DenItemHolderEvent) : void
      {
         if(param1.array && param1.array.length > 0)
         {
            DenXtCommManager.requestDenStateChange(param1.array);
         }
      }
      
      private function glowTimerHandler(param1:TimerEvent) : void
      {
         _glowTimer.stop();
         if(_mainHud.furnBtn.glow)
         {
            _mainHud.furnBtn.glow.visible = false;
         }
      }
      
      private function onDelayGiftTimer(param1:TimerEvent) : void
      {
         _delayGiftTimer.stop();
         _delayGiftTimer.removeEventListener("timerComplete",onDelayGiftTimer);
         _delayGiftTimer = null;
         DarkenManager.removeInvisibleBlockBG();
         if(gMainFrame.userInfo.userVarCache.isBitSet(379,2) && !gMainFrame.userInfo.userVarCache.isBitSet(379,3))
         {
            AchievementXtCommManager.requestSetUserVar(379,3);
         }
         else if(gMainFrame.userInfo.userVarCache.isBitSet(379,7) && !gMainFrame.userInfo.userVarCache.isBitSet(379,8))
         {
            AchievementXtCommManager.requestSetUserVar(379,8);
         }
      }
      
      private function audioBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_denAudioPopup)
         {
            _denAudio = GETDEFINITIONBYNAME("DenAudioPopupContent");
            _denAudioPopup = new SBPopup(_guiLayer,GETDEFINITIONBYNAME("DenAudioPopupSkin"),_denAudio,true,true);
            _denAudioPopup.x = 900 * 0.5;
            _denAudioPopup.y = 235;
            _denAudioPopup.bxClosesPopup = false;
            _denAudioPopup.skin.s["bx"].addEventListener("mouseDown",onAudioPopupClose,false,0,true);
            _denAudioPopup.addEventListener("mouseDown",onDenLockAudioPopup,false,0,true);
            _denAudio.audioRecycleBtn.visible = true;
            _denAudio.audioShopBtn.visible = true;
            _denAudio.audioRecycleBtn.addEventListener("mouseDown",onAudioRecycle,false,0,true);
            _denAudio.audioRecycleBtn.addEventListener("mouseOver",onAudioRecycleOver,false,0,true);
            _denAudio.audioRecycleBtn.addEventListener("mouseOut",onAudioRecycleOut,false,0,true);
            _denAudio.audioShopBtn.addEventListener("mouseDown",onAudioShopBtn,false,0,true);
            _denAudio.audioShopBtn.addEventListener("mouseOver",onAudioShopBtnOver,false,0,true);
            _denAudio.audioShopBtn.addEventListener("mouseOut",onAudioShopBtnOut,false,0,true);
         }
         else if(_denAudioPopup.visible)
         {
            _denAudioPopup.close();
         }
         else
         {
            _denAudioPopup.open();
         }
         if(_numAudioItemsLastDrawn != _audioItems.length)
         {
            buildDenAudioWindows();
         }
      }
      
      private function onAudioRecycle(param1:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         param1.stopPropagation();
         if(_recycle)
         {
            _recycle.destroy();
         }
         DenXtCommManager.saveDenItemsState();
         _recycle = new RecycleItems();
         _recycle.init(2,_guiLayer,false,onAudioRecycleClose,900 * 0.5,550 * 0.5);
      }
      
      private function onAudioRecycleClose(param1:Boolean = false) : void
      {
         onShopRecycleClose(param1,true);
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
         onAudioPopupClose(null);
      }
      
      private function onAudioRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14646),param1.currentTarget.x + _denAudioPopup.x,param1.currentTarget.y - 25 + 235);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onAudioRecycleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onAudioShopBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _shop = new Shop();
         _shop.init(56,1030,_playerAvatar,_guiLayer,onShopClose);
      }
      
      private function onAudioShopBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14647),param1.currentTarget.x + _denAudioPopup.x,param1.currentTarget.y - 25 + 235);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onAudioShopBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function audioBtnOverHandler(param1:MouseEvent) : void
      {
         if(!_denEditor.denAudioPopup.visible)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(11270),549,95);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onMouseMouseOverDenHud(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _denItemHolder.handleMouse(0,0,false);
      }
      
      private function clearDenBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(18826),true,onConfirmClearDen);
      }
      
      private function onConfirmClearDen(param1:Object) : void
      {
         if(param1.status)
         {
            if(_denItemHolder.numberOfInitItems <= 1 && _denItemHolder.numberOfInUseItems > 1)
            {
               _denItemHolder.clearDen();
               clearDenInUseItems();
            }
            else if(_denItemHolder.numberOfInitItems > 1)
            {
               DenXtCommManager.requestEmptyDen();
            }
         }
      }
      
      private function clearDenBtnOverHandler(param1:MouseEvent) : void
      {
         if(!param1.currentTarget.isGray)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(18827),355,95);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function lockContainerHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!_denLockPopup)
         {
            _denLock = GETDEFINITIONBYNAME("DenLockPopupContent");
            _denLockPopup = new SBPopup(_guiLayer,GETDEFINITIONBYNAME("DenLockPopupSkin"),_denLock,true,true);
            _denLockPopup.x = 900 * 0.5;
            _denLockPopup.y = 190;
            _denLockPopup.bxClosesPopup = false;
            _denLockPopup.skin.s["bx"].addEventListener("mouseDown",onDenLockPopupClose,false,0,true);
            _denLockPopup.addEventListener("mouseDown",onDenLockAudioPopup,false,0,true);
            _denLockPopup.addEventListener("mouseOver",overDenLockPopup,false,0,true);
            _denLockPopup.addEventListener("mouseOut",outDenLockPopup,false,0,true);
            _denLock.lockDenBtn.addEventListener("mouseDown",onLockUnlockDenDown,false,0,true);
            _denLock.unlockDenBtn.addEventListener("mouseDown",onLockUnlockDenDown,false,0,true);
            _agreeBox = new GuiCheckBox(_denLock.agree_box);
            _agreeBox.init(_denLock.agree_txt);
            _agreeBox.checked = true;
            if(gMainFrame.userInfo.isMyDenPrivate)
            {
               LocalizationManager.translateId(_denLock.titleTxt,11266);
               LocalizationManager.translateId(_denLock.bodyTxt,11267);
               _denLock.agree_box.visible = false;
               _denLock.agree_txt.visible = false;
               _denLock.unlockDenBtn.y = 68.1;
               _denLock.lockDenBtn.y = 68.1;
               _denLock.bodyTxt.y = -14.4;
            }
            else
            {
               LocalizationManager.translateId(_denLock.titleTxt,11268);
               LocalizationManager.translateId(_denLock.bodyTxt,11269);
               _denLock.agree_box.visible = true;
               _denLock.agree_txt.visible = true;
               _denLock.unlockDenBtn.y = 76.6;
               _denLock.lockDenBtn.y = 76.6;
               _denLock.bodyTxt.y = -26.9;
            }
            _denLock.lockDenBtn.visible = !gMainFrame.userInfo.isMyDenPrivate;
            _denLock.unlockDenBtn.visible = gMainFrame.userInfo.isMyDenPrivate;
            return;
         }
         if(_denLockPopup.visible)
         {
            _denLockPopup.close();
         }
         else
         {
            _denLockPopup.open();
         }
      }
      
      private function onDenLockAudioPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function buildDenAudioWindows() : void
      {
         if(_audioItemWindows && _audioItemWindows.numChildren > 0)
         {
            _audioItemWindows.destroy();
            _audioItemWindows = null;
         }
         var _loc2_:int = _numAudioItemsLastDrawn = _audioItems.length;
         var _loc3_:int = Math.min(_loc2_,3);
         var _loc1_:int = Math.ceil(_loc3_ / 2);
         _audioItemWindows = new WindowAndScrollbarGenerator();
         _audioItemWindows.init(_denAudio.itemWindow.width,_denAudio.itemWindow.height,0,0,_loc3_,_loc1_,0,1,1,1,0.5,ItemWindowOriginal,_audioItems.getCoreArray(),"icon",0,{
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut,
            "memberOnlyDown":memberOnlyDownAudio
         },{"isAudio":true});
         _denAudio.itemWindow.addChild(_audioItemWindows);
         LocalizationManager.translateId(_denAudio.titleTxt,11270);
      }
      
      private function getLastPlacedId() : int
      {
         var _loc2_:int = 0;
         var _loc1_:MovieClip = null;
         _loc2_ = 0;
         while(_loc2_ < _audioItemWindows.numWindowsCreated)
         {
            _loc1_ = MovieClip(_audioItemWindows.bg.getChildAt(_loc2_));
            if(_loc1_.isLastPlacedAudio)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
      
      private function overDenLockPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _roomMgr._bInDenShop = true;
         _denItemHolder.handleMouse(0,0,false);
      }
      
      private function outDenLockPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _roomMgr._bInDenShop = false;
      }
      
      private function onLockUnlockDenDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         gMainFrame.userInfo.isMyDenPrivate = !gMainFrame.userInfo.isMyDenPrivate;
         DenXtCommManager.requestSetDenPrivacy(gMainFrame.userInfo.isMyDenPrivate,_agreeBox.checked);
         _denLockPopup.close();
         changeDownToUpStateLock();
         _denEditor.lockBtn.denLock.visible = gMainFrame.userInfo.isMyDenPrivate;
         _denEditor.lockBtn.denUnlock.visible = !gMainFrame.userInfo.isMyDenPrivate;
         _denLock.lockDenBtn.visible = !gMainFrame.userInfo.isMyDenPrivate;
         _denLock.unlockDenBtn.visible = gMainFrame.userInfo.isMyDenPrivate;
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            LocalizationManager.translateId(_denLock.titleTxt,11266);
            LocalizationManager.translateId(_denLock.bodyTxt,11267);
            _denLock.agree_box.visible = false;
            _denLock.agree_txt.visible = false;
            _denLock.unlockDenBtn.y = 68.1;
            _denLock.lockDenBtn.y = 68.1;
            _denLock.bodyTxt.y = -14.4;
         }
         else
         {
            LocalizationManager.translateId(_denLock.titleTxt,11268);
            LocalizationManager.translateId(_denLock.bodyTxt,11269);
            _denLock.agree_box.visible = true;
            _denLock.agree_txt.visible = true;
            _denLock.unlockDenBtn.y = 76.6;
            _denLock.lockDenBtn.y = 76.6;
            _denLock.bodyTxt.y = -26.9;
         }
         if(_denLockToggleCallback != null)
         {
            _denLockToggleCallback(false);
            _denLockToggleCallback = null;
         }
      }
      
      private function onDenLockPopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_denLockPopup)
         {
            _denLockPopup.close();
            changeDownToUpStateLock();
         }
      }
      
      private function onAudioPopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_denAudioPopup)
         {
            _denAudioPopup.close();
            _denEditor.denAudio.downToUpState();
         }
      }
      
      private function changeDownToUpStateLock() : void
      {
         if(_denEditor.lockBtn.denLock.visible)
         {
            _denEditor.lockBtn.denLock.downToUpState();
         }
         else
         {
            _denEditor.lockBtn.denUnlock.downToUpState();
         }
         _roomMgr._bInDenShop = false;
      }
      
      private function lockOverBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _roomMgr._bInDenShop = true;
         _denItemHolder.handleMouse(0,0,false);
      }
      
      private function lockOutBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _roomMgr._bInDenShop = false;
      }
      
      private function onSearchTextInput(param1:Event) : void
      {
         if(currItemWindow)
         {
            currItemWindow.handleSearchInput(_denEditor.searchBar.searchTxt.text);
         }
      }
      
      private function onSearchBarDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _denEditor.searchBar;
         AJAudio.playHudBtnClick();
         if(param1)
         {
            param1.stopPropagation();
            if(_loc2_.open)
            {
               if(!_loc2_.b.hitTestPoint(param1.stageX,param1.stageY,true))
               {
                  return;
               }
               _loc2_.open = false;
               _loc2_.searchTxt.text = "";
               onSearchTextInput(null);
            }
            else
            {
               _loc2_.open = true;
               gMainFrame.stage.focus = _loc2_.searchTxt;
            }
         }
         else
         {
            _loc2_.open = false;
            _loc2_.searchTxt.text = "";
            onSearchTextInput(null);
         }
         _loc2_.b.xBtn.visible = _loc2_.open;
         _loc2_.txt.visible = !_loc2_.open;
         _loc2_.txt.visible = !_loc2_.open;
         _loc2_.searchTxt.visible = _loc2_.open;
         var _loc3_:int = int(_loc2_.m.width);
         _loc2_.m.width = _loc2_.open ? _loc2_.wideTextWidth : _loc2_.shortTextWidth;
         _loc2_.b.x = _loc2_.m.x + _loc2_.m.width;
         if(!_loc2_.open)
         {
            _loc2_.b.x--;
         }
         _loc2_.x -= (_loc2_.m.width - _loc3_) * 0.5;
      }
      
      private function onSearchBarOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playHudBtnRollover();
      }
      
      private function onSearchBarOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addListeners() : void
      {
         _denEditor.addEventListener("mouseMove",onMouseMouseOverDenHud,false,0,true);
         _denEditor.closeBtn.addEventListener("mouseDown",onClose,false,0,true);
         _mainHud.furnBtn.addEventListener("mouseDown",customizeBtnHandler,false,0,true);
         _mainHud.furnBtn.addEventListener("mouseOver",customizeBtnOverHandler,false,0,true);
         _mainHud.furnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.recycleBtn.addEventListener("mouseDown",recycleBtnHandler,false,0,true);
         _denEditor.recycleBtn.addEventListener("mouseOver",recycleBtnOverHandler,false,0,true);
         _denEditor.recycleBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.shopBtn.addEventListener("mouseDown",shopBtnHandler,false,0,true);
         _denEditor.shopBtn.addEventListener("mouseOver",shopBtnOverHandler,false,0,true);
         _denEditor.shopBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.switchDenBtn.addEventListener("mouseDown",denSwitchBtnHandler,false,0,true);
         _denEditor.switchDenBtn.addEventListener("mouseOver",denSwitchBtnOverHandler,false,0,true);
         _denEditor.switchDenBtn.addEventListener("mouseOut",denSwitchBtnOutHandler,false,0,true);
         _denEditor.lArrowBtn.addEventListener("mouseDown",scrollBtnHandler,false,0,true);
         _denEditor.rArrowBtn.addEventListener("mouseDown",scrollBtnHandler,false,0,true);
         _denEditor.normBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.normBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.normBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.themeBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.themeBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.themeBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.petBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.petBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.petBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.toyBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.toyBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.toyBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.plantBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.plantBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.plantBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.furnitureBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.furnitureBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.furnitureBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.wallBtnDn.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _denEditor.wallBtnDn.addEventListener("mouseOver",tabBtnOverHandler,false,0,true);
         _denEditor.wallBtnDn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.lockBtn.addEventListener("mouseDown",lockContainerHandler,false,0,true);
         _denEditor.lockBtn.addEventListener("mouseOver",lockOverBtnHandler,false,0,true);
         _denEditor.lockBtn.addEventListener("mouseOut",lockOutBtnHandler,false,0,true);
         _denEditor.denAudio.addEventListener("mouseDown",audioBtnHandler,false,0,true);
         _denEditor.denAudio.addEventListener("mouseOver",audioBtnOverHandler,false,0,true);
         _denEditor.denAudio.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.clearDenBtn.addEventListener("mouseDown",clearDenBtn,false,0,true);
         _denEditor.clearDenBtn.addEventListener("mouseOver",clearDenBtnOverHandler,false,0,true);
         _denEditor.clearDenBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _denEditor.searchBar.addEventListener("change",onSearchTextInput,false,0,true);
         _denEditor.searchBar.addEventListener("mouseDown",onSearchBarDown,false,0,true);
         _denEditor.searchBar.addEventListener("mouseOver",onSearchBarOver,false,0,true);
         _denEditor.searchBar.addEventListener("mouseOut",onSearchBarOut,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _denEditor.removeEventListener("mouseMove",onMouseMouseOverDenHud);
         _denEditor.closeBtn.removeEventListener("mouseDown",onClose);
         _mainHud.furnBtn.removeEventListener("mouseDown",customizeBtnHandler);
         _mainHud.furnBtn.removeEventListener("mouseOver",customizeBtnOverHandler);
         _mainHud.furnBtn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.recycleBtn.removeEventListener("mouseDown",recycleBtnHandler);
         _denEditor.recycleBtn.removeEventListener("mouseOver",recycleBtnOverHandler);
         _denEditor.recycleBtn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.shopBtn.removeEventListener("mouseDown",shopBtnHandler);
         _denEditor.shopBtn.removeEventListener("mouseOver",shopBtnOverHandler);
         _denEditor.shopBtn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.switchDenBtn.removeEventListener("mouseDown",denSwitchBtnHandler);
         _denEditor.switchDenBtn.removeEventListener("mouseOver",denSwitchBtnOverHandler);
         _denEditor.switchDenBtn.removeEventListener("mouseOut",denSwitchBtnOutHandler);
         _denEditor.normBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.normBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.normBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.themeBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.themeBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.themeBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.petBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.petBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.petBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.toyBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.toyBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.toyBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.plantBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.plantBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.plantBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.furnitureBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.furnitureBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.furnitureBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.wallBtnDn.removeEventListener("mouseDown",tabBtnHandler);
         _denEditor.wallBtnDn.removeEventListener("mouseOver",tabBtnOverHandler);
         _denEditor.wallBtnDn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.lArrowBtn.removeEventListener("mouseDown",scrollBtnHandler);
         _denEditor.rArrowBtn.removeEventListener("mouseDown",scrollBtnHandler);
         _denEditor.lockBtn.removeEventListener("mouseDown",lockContainerHandler);
         _denEditor.lockBtn.removeEventListener("mouseOver",lockOverBtnHandler);
         _denEditor.lockBtn.removeEventListener("mouseOut",lockOutBtnHandler);
         _denEditor.denAudio.removeEventListener("mouseDown",audioBtnHandler);
         _denEditor.denAudio.removeEventListener("mouseOver",audioBtnOverHandler);
         _denEditor.denAudio.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.clearDenBtn.removeEventListener("mouseDown",clearDenBtn);
         _denEditor.clearDenBtn.removeEventListener("mouseOver",clearDenBtnOverHandler);
         _denEditor.clearDenBtn.removeEventListener("mouseOut",btnOutHandler);
         _denEditor.searchBar.removeEventListener("change",onSearchTextInput);
         _denEditor.searchBar.removeEventListener("mouseDown",onSearchBarDown);
         _denEditor.searchBar.removeEventListener("mouseOver",onSearchBarOver);
         _denEditor.searchBar.removeEventListener("mouseOut",onSearchBarOut);
      }
   }
}

