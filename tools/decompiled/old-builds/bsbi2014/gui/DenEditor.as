package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.*;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Quadratic;
   import loader.DefPacksDefHelper;
   import localization.LocalizationManager;
   import pet.PetManager;
   import room.DenItemHolder;
   import room.DenItemHolderEvent;
   import room.RoomManagerWorld;
   
   public class DenEditor
   {
      
      public static var closeCallback:Function;
      
      public static var openCallback:Function;
      
      public static var staticEditor:MovieClip;
      
      private const NUM_VIS_X_WIN:int = 9;
      
      private const NUM_VIS_Y_WIN:int = 1;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const EASE_TIME:Number = 0.8;
      
      private const WARNING_ITEM_COUNT:int = 98;
      
      private const MAX_PLACED_ITEMS:int = 101;
      
      private const ADDITIONAL_ITEMS_FOR_MEMBERS:int = 200;
      
      private const DEN_EDIT_TUTORIAL_WELCOME:int = 0;
      
      private const DEN_EDIT_TUTORIAL_PLACE_ITEM:int = 1;
      
      private const DEN_EDIT_TUTORIAL_ITEM_PLACED:int = 2;
      
      private const DEN_EDIT_TUTORIAL_DOING_WELL:int = 3;
      
      private const DEN_EDIT_TUTORIAL_DOING_WELL_GIFT:int = 4;
      
      private const DEN_EDIT_TUTORIAL_SHOP:int = 5;
      
      private var _denEditor:MovieClip;
      
      private var _playerAvatar:Avatar;
      
      private var _numItems:int;
      
      private var _currItems:Array;
      
      private var _allNormalDenItems:Array;
      
      private var _themeItems:Array;
      
      private var _audioItems:Array;
      
      private var _petItems:Array;
      
      private var _allWindows:WindowGenerator;
      
      private var _themeWindows:WindowGenerator;
      
      private var _petWindows:WindowGenerator;
      
      private var _scrollMask:Sprite;
      
      private var _currContentX:Number;
      
      private var _fullScreenChange:Number;
      
      private var _numColsInView:int;
      
      private var _viewableWidth:Number;
      
      private var _oneColWidth:Number;
      
      private var _delayGiftTimer:Timer;
      
      private var _scrollButtons:SBScrollbar;
      
      private var _audioItemWindows:WindowGenerator;
      
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
      
      public function init(playerAvatar:Avatar, guiLayer:DisplayLayer, mainHud:MovieClip) : void
      {
         this._playerAvatar = playerAvatar;
         this._denEditor = GETDEFINITIONBYNAME("DenEditorAsset");
         this._guiLayer = guiLayer;
         this._mainHud = mainHud;
         staticEditor = this._denEditor;
         this._currContentX = 0;
         this._currPlacementMax = Boolean(gMainFrame.userInfo.isMember) || (gMainFrame.userInfo.pendingFlags & 1 << GuiManager.WAS_MEMBER_ADDITIONAL_ITEMS) > 0 ? int(this.MAX_PLACED_ITEMS + this.ADDITIONAL_ITEMS_FOR_MEMBERS) : this.MAX_PLACED_ITEMS;
         this._currWarningCount = Boolean(gMainFrame.userInfo.isMember) || (gMainFrame.userInfo.pendingFlags & 1 << GuiManager.WAS_MEMBER_ADDITIONAL_ITEMS) > 0 ? int(this.WARNING_ITEM_COUNT + this.ADDITIONAL_ITEMS_FOR_MEMBERS) : this.WARNING_ITEM_COUNT;
         this._roomMgr = RoomManagerWorld.instance;
         this._denItemHolder = this._roomMgr.denItemHolder;
         this._guiLayer.addChild(this._denEditor);
         this.initAssetVisibility();
         this.setupPlayerItems();
         DenXtCommManager.denEditorDIResponseCallback = this.diResponseCallback;
         this._denItemHolder.addEventListener(DenItemHolderEvent.ITEM_REMOVED,this.onDenItemRemoved,false,0,true);
         this._denItemHolder.addEventListener(DenItemHolderEvent.SAVE_STATE,this.onDenSaveState,false,0,true);
         this.addListeners();
      }
      
      public function destroy() : void
      {
         this._denItemHolder.removeEventListener(DenItemHolderEvent.ITEM_REMOVED,this.onDenItemRemoved);
         this._denItemHolder.removeEventListener(DenItemHolderEvent.SAVE_STATE,this.onDenSaveState);
         this.removeListeners();
         this._guiLayer.removeChild(this._denEditor);
         if(Boolean(this._denLockPopup))
         {
            this._denLockPopup.destroy();
         }
         if(Boolean(this._denAudioPopup))
         {
            this._denAudioPopup.destroy();
         }
         if(!this._mainHud.visible)
         {
            this._mainHud.visible = true;
         }
         closeCallback = null;
         openCallback = null;
         this.onRecycleClose();
         this._denEditor = null;
         this._currItems = null;
         this._allNormalDenItems = null;
         this._petItems = null;
         this._themeItems = null;
         this._audioItems = null;
         if(Boolean(this._allWindows))
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(Boolean(this._themeWindows))
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         if(Boolean(this._petWindows))
         {
            this._petWindows.destroy();
            this._petWindows = null;
         }
         if(Boolean(this._audioItemWindows))
         {
            this._audioItemWindows.destroy();
            this._audioItemWindows = null;
         }
         GuiManager.closeTalkingTutorialPopup();
         this._isRecycling = false;
         this._numAudioItemsLastDrawn = 0;
         DenXtCommManager.denEditorDIResponseCallback = null;
         if(Boolean(this._glowTimer))
         {
            this._glowTimer.removeEventListener(TimerEvent.TIMER,this.glowTimerHandler);
            this._glowTimer.reset();
            this._glowTimer = null;
         }
      }
      
      public function closeDenCustomization() : void
      {
         if(this.isDenHudOpen)
         {
            this._denItemHolder.removeHighlightState();
            this.onClose(null);
            this.onRecycleClose();
            this.onShopClose(false);
         }
         if(Boolean(this._allWindows))
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(Boolean(this._themeWindows))
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         if(Boolean(this._petWindows))
         {
            this._petWindows.destroy();
            this._petWindows = null;
         }
         if(Boolean(this._audioItemWindows))
         {
            this._audioItemWindows.destroy();
            this._audioItemWindows = null;
         }
         this.currItemWindow = null;
      }
      
      public function resetPetWindowList() : void
      {
         if(Boolean(this._petWindows))
         {
            this._petWindows.destroy();
            this._petWindows = null;
         }
      }
      
      public function refreshDenLockSettings() : void
      {
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            this._denEditor.lockBtn.denLock.visible = true;
            this._denEditor.lockBtn.denUnlock.visible = false;
         }
         else
         {
            this._denEditor.lockBtn.denLock.visible = false;
            this._denEditor.lockBtn.denUnlock.visible = true;
         }
      }
      
      public function clearDenInUseItems() : void
      {
         var di:DenItem = null;
         var items:Array = null;
         var i:int = 0;
         items = this._audioItems;
         for(i = 0; i < items.length; i++)
         {
            di = items[i];
            di.categoryId = 0;
         }
         items = this._allNormalDenItems;
         for(i = 0; i < items.length; i++)
         {
            di = items[i];
            di.categoryId = 0;
         }
         items = this._petItems;
         for(i = 0; i < items.length; i++)
         {
            di = items[i];
            di.categoryId = 0;
         }
         if(Boolean(this._allWindows))
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(Boolean(this._themeWindows))
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         this.drawItemWindows();
      }
      
      public function reloadDenItems() : void
      {
         this.setupPlayerItems();
      }
      
      public function get isDenHudOpen() : Boolean
      {
         return Boolean(this._denEditor) ? Boolean(this._denEditor.bottomHud.visible) : false;
      }
      
      public function reloadPetItems() : void
      {
         var di:DenItem = null;
         var i:int = 0;
         var petDef:Object = null;
         var petList:Array = gMainFrame.userInfo.myPetsInDen;
         this._petItems = [];
         if(Boolean(petList))
         {
            for(i = 0; i < petList.length; i++)
            {
               di = petList[i];
               petDef = PetManager.getPetDef(PetManager.getDefIdFromLBits(di.version));
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,petDef.type))
               {
                  this._petItems.push(di);
               }
            }
         }
      }
      
      public function openDenLockPopup(callback:Function) : void
      {
         this._denLockToggleCallback = callback;
         this.lockContainerHandler(null);
      }
      
      public function onDenTutorialGiftClose() : void
      {
         if(Boolean(this._denEditor.bottomHud.visible) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP))
         {
            GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18658),LocalizationManager.translateIdOnly(18662),10,115,this._denEditor.shopBtn);
         }
         else
         {
            GuiManager.closeTalkingTutorialPopup();
         }
      }
      
      public function showDenEditor(show:Boolean) : void
      {
         this._denEditor.bottomHud.visible = show;
         this._mainHud.visible = show;
      }
      
      private function initAssetVisibility() : void
      {
         this._glowTimer = new Timer(10000);
         this._glowTimer.addEventListener(TimerEvent.TIMER,this.glowTimerHandler,false,0,true);
         this._glowTimer.start();
         this.toggleBottomHudVisibility();
         this._denEditor.normBtnUp.visible = true;
         this._denEditor.themeBtnUp.visible = false;
         this._denEditor.audioBtnUp.visible = false;
         this._denEditor.petBtnUp.visible = false;
         this._denEditor.audioBtnDn.visible = false;
         this._denEditor.yardBtn.visible = false;
         this._denEditor.denAudioPopup.visible = false;
         this._denEditor.itemBlock.glow.visible = false;
         this._denEditor.lockBtn.denLock.initToolTip(this._guiLayer,LocalizationManager.translateIdOnly(14639),MainFrame.VIEW_WIDTH * 0.5,105);
         this._denEditor.lockBtn.denUnlock.initToolTip(this._guiLayer,LocalizationManager.translateIdOnly(14640),MainFrame.VIEW_WIDTH * 0.5,105);
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            this._denEditor.lockBtn.denLock.visible = true;
            this._denEditor.lockBtn.denUnlock.visible = false;
         }
         else
         {
            this._denEditor.lockBtn.denLock.visible = false;
            this._denEditor.lockBtn.denUnlock.visible = true;
         }
         this._viewableWidth = this._denEditor.itemBlock.itemBlock.width;
      }
      
      private function setupPlayerItems() : void
      {
         var tempLength:int = 0;
         var i:int = 0;
         var j:int = 0;
         var temp:Array = [];
         if(Boolean(this._playerAvatar) && this._playerAvatar.inventoryDenFull.itemArray.length > 0)
         {
            temp = this._playerAvatar.inventoryDenFull.itemArray.concat();
         }
         else if(Boolean(gMainFrame.userInfo.playerUserInfo.denItemsFull))
         {
            temp = gMainFrame.userInfo.playerUserInfo.denItemsFull.concat();
         }
         this.reloadPetItems();
         this._currItems = [];
         this._numAudioItemsLastDrawn = 0;
         if(Boolean(temp) && temp.length > 0)
         {
            tempLength = int(temp.length);
            this._allNormalDenItems = [];
            this._audioItems = [];
            for(i = 0; i < tempLength; i++)
            {
               if(temp[i].sortId == DenItem.SORT_AUDIO)
               {
                  this._audioItems.push(temp[i]);
               }
               else if(temp[i].enviroType == AvatarManager.roomEnviroType)
               {
                  this._allNormalDenItems.push(temp[i]);
               }
            }
            this._themeItems = Utility.sortItems(this._allNormalDenItems,0,DenItem.SORT_FLOORING,DenItem.SORT_WALLPAPER);
            for(j = 0; j < this._themeItems.length; j++)
            {
               this._themeItems[j] = this._themeItems[j].clone();
            }
            if(Boolean(this._denEditor.normBtnUp.visible))
            {
               this._currItems = this._allNormalDenItems;
               this._denEditor.itemCountTxt.text = this._currItems.length + "/" + Shop.maxDenItems;
            }
            else if(Boolean(this._denEditor.themeBtnUp.visible))
            {
               this._currItems = this._themeItems;
               this._denEditor.itemCountTxt.text = this._currItems.length;
            }
            else if(Boolean(this._denEditor.petBtnUp.visible))
            {
               this._currItems = this._petItems;
               this._denEditor.itemCountTxt.text = this._currItems.length;
            }
            this._numItems = this._currItems.length;
         }
         else
         {
            this._denEditor.normBtnUp.visible = true;
            this._denEditor.themeBtnUp.visible = false;
            this._denEditor.petBtnUp.visible = false;
            this._allNormalDenItems = [];
            this._themeItems = [];
            this._audioItems = [];
            this._numItems = 0;
         }
      }
      
      private function diResponseCallback() : void
      {
         this._denEditor.normBtnUp.visible = true;
         this._denEditor.themeBtnUp.visible = false;
         this._denEditor.petBtnUp.visible = false;
         if(Boolean(this._allNormalDenItems) && this._allNormalDenItems.length > 0)
         {
            this._currItems = this._allNormalDenItems;
         }
         this.setupPlayerItems();
         this._currContentX = 0;
         if(Boolean(this._allWindows))
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(Boolean(this._themeWindows))
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         this.drawItemWindows();
      }
      
      private function onShopRecycleClose(hasMadeChanges:Boolean = false, isAudio:Boolean = false) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = this.diResponseCallback;
         if(hasMadeChanges)
         {
            this._denEditor.normBtnUp.visible = true;
            this._denEditor.themeBtnUp.visible = false;
            this._denEditor.petBtnUp.visible = false;
            if(Boolean(this._allNormalDenItems) && this._allNormalDenItems.length > 0)
            {
               this._currItems = this._allNormalDenItems;
            }
            this.setupPlayerItems();
            this._currContentX = 0;
            if(!isAudio)
            {
               if(Boolean(this._allWindows))
               {
                  this._allWindows.destroy();
                  this._allWindows = null;
               }
               if(Boolean(this._themeWindows))
               {
                  this._themeWindows.destroy();
                  this._themeWindows = null;
               }
            }
            this.drawItemWindows();
         }
      }
      
      private function drawItemWindows() : void
      {
         var generatedWindow:WindowGenerator = null;
         var j:int = 0;
         if(this.currItemWindow == null)
         {
            if(Boolean(this._currItems))
            {
               this._oneColWidth = 84;
               this._fullScreenChange = this._viewableWidth - this._oneColWidth;
               this._numColsInView = this._viewableWidth / this._oneColWidth;
               this._numItems = Math.max(this._currItems.length,this.NUM_VIS_X_WIN);
            }
            else
            {
               this._numItems = this.NUM_VIS_X_WIN;
            }
            if(this._currItems == this._themeItems)
            {
               for(j = 0; j < this._themeItems.length; j++)
               {
                  this._themeItems[j].destroy();
               }
               this._themeItems = Utility.sortItems(this._allNormalDenItems,0,DenItem.SORT_FLOORING,DenItem.SORT_WALLPAPER);
               for(j = 0; j < this._themeItems.length; j++)
               {
                  this._themeItems[j] = this._themeItems[j].clone();
               }
               this._currItems = this._themeItems;
            }
            generatedWindow = new WindowGenerator();
            this.currItemWindow = generatedWindow;
            generatedWindow.init(this.NUM_VIS_X_WIN,this.NUM_VIS_Y_WIN,this._numItems,this.X_WIN_OFFSET,this.Y_WIN_OFFSET,this.X_WIN_START,ItemWindowOriginal,this._currItems,"icon",{
               "mouseDown":this.winMouseDown,
               "mouseOver":this.winMouseOver,
               "mouseOut":this.winMouseOut,
               "memberOnlyDown":this.memberOnlyDown
            },{"isPetItem":this._currItems == this._petItems},this.onWindowsGenerated,true);
            this._currContentX = 0;
            if(Boolean(this._currItems))
            {
               generatedWindow.x = this._currContentX;
               generatedWindow.y = 0;
            }
         }
         if(Boolean(this._currItems))
         {
            this._currContentX = this.currItemWindow.x;
            this._numItems = Math.max(this._currItems.length,this.NUM_VIS_X_WIN);
            this._scrollMask = new Sprite();
            this._scrollMask.graphics.beginFill(16777215);
            this._scrollMask.graphics.drawRect(0,0,this.currItemWindow.boxWidth * this.NUM_VIS_X_WIN + this.X_WIN_OFFSET * (this.NUM_VIS_X_WIN - 1) + this.X_WIN_START * 2,this.currItemWindow.height);
            this._scrollMask.graphics.endFill();
            while(this._denEditor.itemBlock.numChildren > 1)
            {
               this._denEditor.itemBlock.removeChildAt(1);
            }
            this._denEditor.itemBlock.addChild(this._scrollMask);
            this._denEditor.itemBlock.addChild(this.currItemWindow);
            this.currItemWindow.mask = this._scrollMask;
         }
         if(this._numItems <= 9)
         {
            this._denEditor.lArrowBtn.activateGrayState(true);
            this._denEditor.rArrowBtn.activateGrayState(true);
         }
         else
         {
            this._denEditor.lArrowBtn.activateGrayState(false);
            this._denEditor.rArrowBtn.activateGrayState(false);
         }
      }
      
      private function get currItemWindow() : WindowGenerator
      {
         var currWindow:WindowGenerator = null;
         if(Boolean(this._denEditor.normBtnUp.visible))
         {
            if(Boolean(this._allWindows))
            {
               currWindow = this._allWindows;
            }
         }
         else if(Boolean(this._denEditor.themeBtnUp.visible))
         {
            if(Boolean(this._themeWindows))
            {
               currWindow = this._themeWindows;
            }
         }
         else if(Boolean(this._denEditor.petBtnUp.visible))
         {
            if(Boolean(this._petWindows))
            {
               currWindow = this._petWindows;
            }
         }
         return currWindow;
      }
      
      private function set currItemWindow(window:WindowGenerator) : void
      {
         if(Boolean(this._denEditor.normBtnUp.visible))
         {
            this._allWindows = window;
         }
         else if(Boolean(this._denEditor.themeBtnUp.visible))
         {
            this._themeWindows = window;
         }
         else if(Boolean(this._denEditor.petBtnUp.visible))
         {
            this._petWindows = window;
         }
      }
      
      private function onWindowsGenerated() : void
      {
         this.loadCurrViewableObjects(0,this.currItemWindow);
      }
      
      private function scrollBtnHandler(evt:MouseEvent) : void
      {
         var j:int = 0;
         var contentRightOfWindow:Number = NaN;
         var i:int = 0;
         evt.stopPropagation();
         var scrollAmt:Number = 0;
         var currWindow:WindowGenerator = this.currItemWindow;
         if(evt.currentTarget.name == this._denEditor.lArrowBtn.name)
         {
            if(this._currContentX < 0)
            {
               if(this._currContentX <= -this._fullScreenChange)
               {
                  scrollAmt = this._fullScreenChange;
               }
               else
               {
                  for(j = this._numColsInView - 2; j > 0; j--)
                  {
                     if(this._currContentX <= -(this._oneColWidth * j))
                     {
                        scrollAmt = this._oneColWidth * j;
                        break;
                     }
                  }
                  if(-scrollAmt > this._currContentX)
                  {
                     scrollAmt = -this._currContentX;
                  }
               }
            }
            else if(currWindow.width > this._scrollMask.width)
            {
            }
         }
         else
         {
            contentRightOfWindow = currWindow.width + this._currContentX - this._viewableWidth;
            if(contentRightOfWindow > 0)
            {
               if(contentRightOfWindow >= this._fullScreenChange)
               {
                  scrollAmt = -this._fullScreenChange;
               }
               else
               {
                  for(i = this._numColsInView - 2; i > 0; i--)
                  {
                     if(contentRightOfWindow >= this._oneColWidth * i)
                     {
                        scrollAmt = -(this._oneColWidth * i);
                        break;
                     }
                  }
                  if(-scrollAmt < contentRightOfWindow)
                  {
                     scrollAmt = -contentRightOfWindow;
                  }
               }
            }
         }
         if(scrollAmt != 0)
         {
            this._currContentX += scrollAmt;
            this.loadCurrViewableObjects(this._currContentX,currWindow);
            new GTween(currWindow,this.EASE_TIME,{"x":this._scrollMask.x + this._currContentX},{"ease":Quadratic.easeOut});
         }
      }
      
      private function loadCurrViewableObjects(currContentX:Number, currItemWindow:WindowGenerator) : void
      {
         var o:Object = null;
         var currStartIndex:int = -(currContentX / (this._oneColWidth + this.X_WIN_OFFSET));
         var currEndIndex:int = currStartIndex + this._numColsInView;
         var numChildren:int = currItemWindow.bg.numChildren;
         for(var i:int = currStartIndex; i < currEndIndex; i++)
         {
            if(i < numChildren)
            {
               o = currItemWindow.bg.getChildAt(i);
               o.loadCurrItem(0,currContentX);
            }
         }
      }
      
      private function customizeBtnHandler(evt:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/denCustomize");
         evt.stopPropagation();
         this.toggleBottomHudVisibility();
         if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_WELCOME))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_WELCOME);
         }
         if(openCallback != null)
         {
            openCallback();
         }
      }
      
      private function customizeBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14641),730,450);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function toggleBottomHudVisibility() : void
      {
         this._denEditor.bottomHud.visible = !this._denEditor.bottomHud.visible;
         this._mainHud.visible = !this._denEditor.bottomHud.visible;
         this._mainHud.furnBtn.visible = this._mainHud.visible;
         if(Boolean(this._denEditor.bottomHud.visible))
         {
            this._roomMgr.setRoomMode(RoomManagerWorld.ROOM_MODE_DEN);
            this.drawItemWindows();
            GuiManager.closeAnyHudPopups();
            if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM))
            {
               GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18655),LocalizationManager.translateIdOnly(18662),10,115,null,this._denEditor.itemBlock.glow);
               this._mainHud.furnBtn.setButtonState(1);
            }
            else if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED))
            {
               GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18656),LocalizationManager.translateIdOnly(18662),10,115,null);
            }
            else if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP))
            {
               GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18658),LocalizationManager.translateIdOnly(18662),10,115,this._denEditor.shopBtn);
            }
         }
         else
         {
            if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_WELCOME))
            {
               GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18654),LocalizationManager.translateIdOnly(18662),10,115,this._mainHud.furnBtn);
            }
            else
            {
               this._mainHud.furnBtn.setButtonState(1);
               GuiManager.closeTalkingTutorialPopup();
            }
            this._roomMgr.setRoomMode(RoomManagerWorld.ROOM_MODE_AVATAR);
         }
      }
      
      public function toggleEditorHud(show:Boolean) : void
      {
         this._denEditor.bottomHud.visible = show;
         this.onDenLockPopupClose(null);
         this.onAudioPopupClose(null);
         if(show)
         {
            GuiManager.closeAnyHudPopups();
         }
      }
      
      private function tabBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.name == this._denEditor.normBtnDn.name)
         {
            this._denEditor.normBtnUp.visible = true;
            this._denEditor.themeBtnUp.visible = false;
            this._denEditor.petBtnUp.visible = false;
            this._denEditor.itemCountTxt.text = this._allNormalDenItems.length + "/" + Shop.maxDenItems;
            this._currItems = this._allNormalDenItems;
         }
         else if(evt.currentTarget.name == this._denEditor.themeBtnDn.name)
         {
            this._denEditor.normBtnUp.visible = false;
            this._denEditor.themeBtnUp.visible = true;
            this._denEditor.petBtnUp.visible = false;
            this._denEditor.itemCountTxt.text = this._themeItems.length;
            this._currItems = this._themeItems;
         }
         else
         {
            if(evt.currentTarget.name != this._denEditor.petBtnDn.name)
            {
               DebugUtility.debugTrace("WARNING: Bad btn clicked in tabBtnHandler");
               return;
            }
            this._denEditor.normBtnUp.visible = false;
            this._denEditor.themeBtnUp.visible = false;
            this._denEditor.petBtnUp.visible = true;
            this._denEditor.itemCountTxt.text = this._petItems.length;
            this._currItems = this._petItems;
            if(this._currItems == null)
            {
               this.reloadPetItems();
            }
         }
         this._currContentX = 0;
         this.drawItemWindows();
      }
      
      private function tabBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.name == this._denEditor.normBtnDn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11216),120,405);
         }
         else if(evt.currentTarget.name == this._denEditor.themeBtnDn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14642),205,405);
         }
         else if(evt.currentTarget.name == this._denEditor.petBtnDn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11240),290,405);
         }
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         var window:WindowGenerator = null;
         var i:int = 0;
         var currItem:MovieClip = null;
         if(evt.currentTarget.cir.currentFrameLabel == "green")
         {
            evt.currentTarget.cir.gotoAndStop("over");
         }
         else
         {
            if(evt.currentTarget.cir.currentFrameLabel == "down")
            {
               evt.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(evt.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               evt.currentTarget.cir.gotoAndStop("over");
            }
            if(this._currItems == this._themeItems)
            {
               window = this._allWindows;
            }
            else if(this._currItems == this._allNormalDenItems)
            {
               window = this._themeWindows;
            }
            if(Boolean(window))
            {
               for(i = 0; i < window.bg.numChildren; i++)
               {
                  currItem = MovieClip(window.bg.getChildAt(i));
                  if(currItem.defId == evt.currentTarget.defId)
                  {
                     if(currItem.cir.currentFrameLabel == "down")
                     {
                        currItem.cir.gotoAndStop("downMouse");
                     }
                     else if(currItem.cir.currentFrameLabel != "downMouse")
                     {
                        currItem.cir.gotoAndStop("over");
                     }
                     break;
                  }
               }
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         var window:WindowGenerator = null;
         var i:int = 0;
         var currItem:MovieClip = null;
         if(evt.currentTarget.numChildren >= 2)
         {
            if(evt.currentTarget.cir.currentFrameLabel == "over" && Boolean(evt.currentTarget.isActivePet))
            {
               evt.currentTarget.cir.gotoAndStop("green");
            }
            else
            {
               if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
               {
                  evt.currentTarget.cir.gotoAndStop("down");
               }
               else if(evt.currentTarget.cir.currentFrameLabel != "down")
               {
                  evt.currentTarget.cir.gotoAndStop("up");
               }
               if(this._currItems == this._themeItems)
               {
                  window = this._allWindows;
               }
               else if(this._currItems == this._allNormalDenItems)
               {
                  window = this._themeWindows;
               }
               if(Boolean(window))
               {
                  for(i = 0; i < window.bg.numChildren; i++)
                  {
                     currItem = MovieClip(window.bg.getChildAt(i));
                     if(currItem.defId == evt.currentTarget.defId)
                     {
                        if(currItem.cir.currentFrameLabel == "downMouse")
                        {
                           currItem.cir.gotoAndStop("down");
                        }
                        else if(currItem.cir.currentFrameLabel != "down")
                        {
                           currItem.cir.gotoAndStop("up");
                        }
                        break;
                     }
                  }
               }
            }
         }
      }
      
      private function winMouseDown(evt:MouseEvent) : void
      {
         var lastPlacedAudioId:int = 0;
         var window:WindowGenerator = null;
         var i:int = 0;
         var currItem:MovieClip = null;
         evt.stopPropagation();
         if(Boolean(evt.currentTarget.isActivePet))
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14714));
            return;
         }
         var denItem:DenItem = Boolean(evt.currentTarget.isAudio) ? this._audioItems[evt.currentTarget.index] : this._currItems[evt.currentTarget.index];
         if(denItem.categoryId == 0)
         {
            if(denItem.sortId < 4 && this._denItemHolder.numberOfInUseItems >= this._currWarningCount)
            {
               if(this._denItemHolder.numberOfInUseItems >= this._currPlacementMax)
               {
                  if(!gMainFrame.userInfo.isMember || (gMainFrame.userInfo.pendingFlags & 1 << 1) < 0)
                  {
                     UpsellManager.displayPopup(UpsellManager.EXTRA_DEN_ITEMS,"additionalPlacedDenItem");
                  }
                  else
                  {
                     new SBOkPopup(this._guiLayer,this.getWarningMessage(this._denItemHolder.numberOfInUseItems + 1));
                  }
                  return;
               }
               new SBOkPopup(this._guiLayer,this.getWarningMessage(this._denItemHolder.numberOfInUseItems + 1));
            }
            if(Boolean(evt.currentTarget.isAudio))
            {
               lastPlacedAudioId = this.getLastPlacedId();
               if(lastPlacedAudioId != -1)
               {
                  MovieClip(this._audioItemWindows.bg.getChildAt(lastPlacedAudioId)).resetAudioDown();
                  this._audioItems[lastPlacedAudioId].categoryId = 0;
               }
               MovieClip(this._audioItemWindows.bg.getChildAt(evt.currentTarget.index)).setAudioDown();
            }
            this.placeItemInRoom(denItem);
            if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED))
            {
               this._denEditor.itemBlock.glow.visible = false;
               GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18656),LocalizationManager.translateIdOnly(18662),10,115,null);
            }
            if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM))
            {
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM);
            }
         }
         else
         {
            if(Boolean(evt.currentTarget.isAudio))
            {
               lastPlacedAudioId = this.getLastPlacedId();
               if(evt.currentTarget.index == lastPlacedAudioId)
               {
                  return;
               }
            }
            this._denItemHolder.removeItem(denItem.invIdx,denItem.refId);
            denItem.categoryId = 0;
            if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM)) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED))
            {
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED);
            }
            if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM)) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_DOING_WELL))
            {
               DarkenManager.addInvisibleBlockBG();
               GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18657),LocalizationManager.translateIdOnly(18662),10,115,null);
               this._delayGiftTimer = new Timer(4000);
               this._delayGiftTimer.addEventListener(TimerEvent.TIMER,this.onDelayGiftTimer,false,0,true);
               this._delayGiftTimer.start();
            }
         }
         if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            evt.currentTarget.cir.gotoAndStop("over");
         }
         else
         {
            evt.currentTarget.cir.gotoAndStop("downMouse");
         }
         if(!evt.currentTarget.isAudio)
         {
            if(this._currItems == this._themeItems)
            {
               window = this._allWindows;
            }
            else
            {
               window = this._themeWindows;
            }
            if(Boolean(window))
            {
               for(i = 0; i < window.bg.numChildren; i++)
               {
                  currItem = MovieClip(window.bg.getChildAt(i));
                  if(currItem.defId == evt.currentTarget.defId)
                  {
                     if(window == this._themeWindows)
                     {
                        this._themeItems[currItem.index].categoryId = denItem.categoryId;
                     }
                     else
                     {
                        this._allNormalDenItems[currItem.index].categoryId = denItem.categoryId;
                     }
                     if(currItem.cir.currentFrameLabel == "downMouse")
                     {
                        currItem.cir.gotoAndStop("over");
                     }
                     else
                     {
                        currItem.cir.gotoAndStop("downMouse");
                     }
                     break;
                  }
               }
            }
         }
         AJAudio.playSubMenuBtnClick();
      }
      
      private function getWarningMessage(numItemsInUse:int) : String
      {
         var numRemaining:int = this._currPlacementMax - numItemsInUse;
         var warningTxt:String = "";
         if(numRemaining > 1)
         {
            warningTxt = LocalizationManager.translateIdAndInsertOnly(11262,numRemaining);
         }
         else if(numRemaining == 1)
         {
            warningTxt = LocalizationManager.translateIdAndInsertOnly(11263,numRemaining);
         }
         else if(numRemaining == 0)
         {
            warningTxt = LocalizationManager.translateIdOnly(11264);
         }
         else
         {
            warningTxt = LocalizationManager.translateIdOnly(11265);
         }
         return warningTxt;
      }
      
      private function memberOnlyDown(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         UpsellManager.displayPopup(UpsellManager.DEN_ITEMS,"placeDenItem/" + this._currItems[evt.currentTarget.index].itemDefId);
      }
      
      private function memberOnlyDownAudio(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         UpsellManager.displayPopup(UpsellManager.DEN_AUDIO,"selectDenAudio/" + this._audioItems[evt.currentTarget.index].itemDefId);
      }
      
      private function placeItemInRoom(placeItem:DenItem) : void
      {
         var catId:int = DenItem.getInWorldId(placeItem.sortId,this._roomMgr.denCatId);
         placeItem.categoryId = catId;
         this._roomMgr.spawnNewDenItem({
            "i":placeItem.invIdx,
            "p":placeItem.itemDefId << 16 | catId,
            "l":placeItem.layerId,
            "x":0,
            "y":0,
            "c":catId,
            "s":placeItem.sortId,
            "mg":placeItem.minigameDefId,
            "v":placeItem.version,
            "strmName":placeItem.strmName,
            "v2":placeItem.version2,
            "v3":placeItem.version3,
            "r":placeItem.refId,
            "userNameLink":"",
            "specialType":placeItem.specialType
         });
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         SBTracker.pop();
         if(Boolean(this._denLockPopup) && this._denLockPopup.visible)
         {
            this.changeDownToUpStateLock();
            this._denLockPopup.close();
         }
         if(Boolean(this._denAudioPopup) && this._denAudioPopup.visible)
         {
            this._denEditor.denAudio.downToUpState();
            this._denAudioPopup.close();
         }
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         this.toggleBottomHudVisibility();
         if(closeCallback != null)
         {
            closeCallback();
         }
      }
      
      private function shopBtnHandler(evt:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         if(Boolean(this._shop))
         {
            this._shop.destroy();
         }
         this._roomMgr._bInDenShop = true;
         DenXtCommManager.saveDenItemsState();
         if(openCallback != null)
         {
            openCallback();
         }
         if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_SHOP);
            this._denEditor.shopBtn.setButtonState(1);
         }
         GuiManager.closeTalkingTutorialPopup();
         this._shop = new Shop();
         if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            this._shop.init(GenericListXtCommManager.DEN_ITEM_CRYSTALREEF_SHOP_ID,DefPacksDefHelper.DEF_DEN_ITEM,this._playerAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
         else
         {
            this._shop.init(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,Shop.DEN_EDIT_TUTORIAL_COMPLETE) ? GenericListXtCommManager.DEN_ITEM_FIRST_TIME_SHOP_ID : GenericListXtCommManager.DEN_ITEM_MAIN_SHOP_ID,DefPacksDefHelper.DEF_DEN_ITEM,this._playerAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
      }
      
      private function shopBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14643),795,390);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function btnOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function denSwitchBtnHandler(evt:MouseEvent) : void
      {
         DenXtCommManager.saveDenItemsState();
         GuiManager.openDenRoomSwitcher(false,null,false,-1,GenericListXtCommManager.DEN_ROOM_FULL_SHOP_ID);
      }
      
      private function denSwitchBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14644),705,400);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function denSwitchBtnOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onShopClose(bItemsPurchased:Boolean) : void
      {
         this.onShopRecycleClose(bItemsPurchased);
         if(Boolean(this._denAudioPopup && this._denAudioPopup.visible) && Boolean(bItemsPurchased) && this._shop.isAudioShop)
         {
            this.buildDenAudioWindows();
         }
         if(this._shop.showTutorial && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,Shop.DEN_EDIT_TUTORIAL_COMPLETE) && Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,Shop.DEN_EDIT_TUTORIAL_SHOP_BUY)))
         {
            DarkenManager.addInvisibleBlockBG();
            GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18661),LocalizationManager.translateIdOnly(18662),10,115,null);
            this._delayGiftTimer = new Timer(6000);
            this._delayGiftTimer.addEventListener(TimerEvent.TIMER,this.onDelayGiftTimer,false,0,true);
            this._delayGiftTimer.start();
         }
         if(Boolean(this._shop))
         {
            this._shop.destroy();
            this._shop = null;
         }
         this._roomMgr._bInDenShop = false;
      }
      
      private function recycleBtnHandler(evt:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         evt.stopPropagation();
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
         }
         DenXtCommManager.saveDenItemsState();
         this._recycle = new RecycleItems();
         this._recycle.init(RecycleItems.RECYCLE_DEN_ITEMS,this._guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private function recycleBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14645),615,400);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onRecycleClose(itemRecycled:Boolean = false) : void
      {
         this.onShopRecycleClose(itemRecycled);
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
            this._recycle = null;
         }
      }
      
      private function onDenItemRemoved(evt:DenItemHolderEvent) : void
      {
         var items:Array = null;
         var di:DenItem = null;
         var i:int = 0;
         var mc:MovieClip = null;
         var currWindows:WindowGenerator = null;
         var j:int = 0;
         var invIdx:int = int(evt.id);
         var refId:int = evt.refId;
         if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM)) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED);
         }
         if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_PLACE_ITEM)) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_DOING_WELL))
         {
            DarkenManager.addInvisibleBlockBG();
            GuiManager.openTalkingTutorial(LocalizationManager.translateIdOnly(18657),LocalizationManager.translateIdOnly(18662),10,115,null);
            this._delayGiftTimer = new Timer(4000);
            this._delayGiftTimer.addEventListener(TimerEvent.TIMER,this.onDelayGiftTimer,false,0,true);
            this._delayGiftTimer.start();
         }
         var o:Object = null;
         if(Boolean(evt.array) && evt.array.length > 0)
         {
            o = evt.array[0];
         }
         if(refId == DenItem.REF_ID_DEN_ITEM)
         {
            if(Boolean(o) && o.s == DenItem.SORT_AUDIO)
            {
               items = this._audioItems;
            }
            else
            {
               items = this._allNormalDenItems;
            }
         }
         else
         {
            items = this._petItems;
         }
         if(Boolean(items))
         {
            for(i = 0; i < items.length; i++)
            {
               if(items[i].invIdx == invIdx)
               {
                  di = items[i];
                  di.categoryId = 0;
                  break;
               }
            }
            if(Boolean(this._currItems) && Boolean(this._currItems[0]) && this._currItems[0].refId == refId)
            {
               currWindows = this.currItemWindow;
               for(j = this._currItems.length - 1; j >= 0; j--)
               {
                  mc = MovieClip(currWindows).bg.getChildAt(j);
                  di = this._currItems[mc.index];
                  if(di.refId == refId && di.invIdx == invIdx)
                  {
                     mc.cir.gotoAndStop("up");
                     di.categoryId = 0;
                     break;
                  }
               }
               if(this.currItemWindow == this._allWindows)
               {
                  items = this._themeItems;
                  currWindows = this._themeWindows;
               }
               else if(this.currItemWindow == this._themeWindows)
               {
                  items = this._allNormalDenItems;
                  currWindows = this._allWindows;
               }
               if(Boolean(currWindows))
               {
                  for(j = 0; j < items.length; j++)
                  {
                     mc = MovieClip(currWindows).bg.getChildAt(j);
                     di = items[mc.index];
                     if(di.refId == refId && di.invIdx == invIdx)
                     {
                        mc.cir.gotoAndStop("up");
                        di.categoryId = 0;
                        break;
                     }
                  }
               }
            }
         }
      }
      
      private function onDenSaveState(evt:DenItemHolderEvent) : void
      {
         if(Boolean(evt.array) && evt.array.length > 0)
         {
            DenXtCommManager.requestDenStateChange(evt.array);
         }
      }
      
      private function glowTimerHandler(te:TimerEvent) : void
      {
         this._glowTimer.stop();
         this._mainHud.furnBtn.glow.visible = false;
      }
      
      private function onDelayGiftTimer(te:TimerEvent) : void
      {
         this._delayGiftTimer.stop();
         this._delayGiftTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.onDelayGiftTimer);
         this._delayGiftTimer = null;
         DarkenManager.removeInvisibleBlockBG();
         if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_ITEM_PLACED)) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_DOING_WELL))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,this.DEN_EDIT_TUTORIAL_DOING_WELL);
         }
         else if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,Shop.DEN_EDIT_TUTORIAL_SHOP_BUY)) && !gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TUTORIALS,Shop.DEN_EDIT_TUTORIAL_COMPLETE))
         {
            AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TUTORIALS,Shop.DEN_EDIT_TUTORIAL_COMPLETE);
         }
      }
      
      private function audioBtnHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(!this._denAudioPopup)
         {
            this._denAudio = GETDEFINITIONBYNAME("DenAudioPopupContent");
            this._denAudioPopup = new SBPopup(this._guiLayer,GETDEFINITIONBYNAME("DenAudioPopupSkin"),this._denAudio,true,true);
            this._denAudioPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._denAudioPopup.y = 235;
            this._denAudioPopup.bxClosesPopup = false;
            this._denAudioPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onAudioPopupClose,false,0,true);
            this._denAudioPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onDenLockAudioPopup,false,0,true);
            this._denAudio.audioRecycleBtn.visible = true;
            this._denAudio.audioShopBtn.visible = true;
            this._denAudio.audioRecycleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAudioRecycle,false,0,true);
            this._denAudio.audioRecycleBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onAudioRecycleOver,false,0,true);
            this._denAudio.audioRecycleBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onAudioRecycleOut,false,0,true);
            this._denAudio.audioShopBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAudioShopBtn,false,0,true);
            this._denAudio.audioShopBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onAudioShopBtnOver,false,0,true);
            this._denAudio.audioShopBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onAudioShopBtnOut,false,0,true);
         }
         else if(this._denAudioPopup.visible)
         {
            this._denAudioPopup.close();
         }
         else
         {
            this._denAudioPopup.open();
         }
         if(this._numAudioItemsLastDrawn != this._audioItems.length)
         {
            this.buildDenAudioWindows();
         }
      }
      
      private function onAudioRecycle(e:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         e.stopPropagation();
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
         }
         DenXtCommManager.saveDenItemsState();
         this._recycle = new RecycleItems();
         this._recycle.init(RecycleItems.RECYCLE_DEN_AUDIO,this._guiLayer,false,this.onAudioRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private function onAudioRecycleClose(itemRecycled:Boolean = false) : void
      {
         this.onShopRecycleClose(itemRecycled,true);
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
            this._recycle = null;
         }
         this.onAudioPopupClose(null);
      }
      
      private function onAudioRecycleOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14646),e.currentTarget.x + this._denAudioPopup.x,e.currentTarget.y - 25 + 235);
         GuiManager.toolTip.startTimer(e);
      }
      
      private function onAudioRecycleOut(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onAudioShopBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._shop = new Shop();
         this._shop.init(GenericListXtCommManager.DEN_ITEM_AUDIO_SHOP_ID,DefPacksDefHelper.DEF_DEN_ITEM,this._playerAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private function onAudioShopBtnOver(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14647),e.currentTarget.x + this._denAudioPopup.x,e.currentTarget.y - 25 + 235);
         GuiManager.toolTip.startTimer(e);
      }
      
      private function onAudioShopBtnOut(e:MouseEvent) : void
      {
         e.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function audioBtnOverHandler(e:MouseEvent) : void
      {
         if(!this._denEditor.denAudioPopup.visible)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11270),549,95);
            GuiManager.toolTip.startTimer(e);
         }
      }
      
      private function onMouseMouseOverDenHud(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         this._denItemHolder.handleMouse(0,0,false);
      }
      
      private function clearDenBtn(e:MouseEvent) : void
      {
         e.stopPropagation();
         new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(18826),true,this.onConfirmClearDen);
      }
      
      private function onConfirmClearDen(o:Object) : void
      {
         if(Boolean(o.status))
         {
            if(this._denItemHolder.numberOfInitItems <= 1 && this._denItemHolder.numberOfInUseItems > 1)
            {
               this._denItemHolder.clearDen();
               this.clearDenInUseItems();
            }
            else if(this._denItemHolder.numberOfInitItems > 1)
            {
               DenXtCommManager.requestEmptyDen();
            }
         }
      }
      
      private function clearDenBtnOverHandler(e:MouseEvent) : void
      {
         if(!e.currentTarget.isGray)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(18827),355,95);
            GuiManager.toolTip.startTimer(e);
         }
      }
      
      private function lockContainerHandler(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         if(!this._denLockPopup)
         {
            this._denLock = GETDEFINITIONBYNAME("DenLockPopupContent");
            this._denLockPopup = new SBPopup(this._guiLayer,GETDEFINITIONBYNAME("DenLockPopupSkin"),this._denLock,true,true);
            this._denLockPopup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._denLockPopup.y = 190;
            this._denLockPopup.bxClosesPopup = false;
            this._denLockPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onDenLockPopupClose,false,0,true);
            this._denLockPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onDenLockAudioPopup,false,0,true);
            this._denLockPopup.addEventListener(MouseEvent.MOUSE_OVER,this.overDenLockPopup,false,0,true);
            this._denLockPopup.addEventListener(MouseEvent.MOUSE_OUT,this.outDenLockPopup,false,0,true);
            this._denLock.lockDenBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onLockUnlockDenDown,false,0,true);
            this._denLock.unlockDenBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onLockUnlockDenDown,false,0,true);
            this._agreeBox = new GuiCheckBox(this._denLock.agree_box);
            this._agreeBox.init(this._denLock.agree_txt);
            this._agreeBox.checked = true;
            if(gMainFrame.userInfo.isMyDenPrivate)
            {
               LocalizationManager.translateId(this._denLock.titleTxt,11266);
               LocalizationManager.translateId(this._denLock.bodyTxt,11267);
               this._denLock.agree_box.visible = false;
               this._denLock.agree_txt.visible = false;
               this._denLock.unlockDenBtn.y = 68.1;
               this._denLock.lockDenBtn.y = 68.1;
               this._denLock.bodyTxt.y = -14.4;
            }
            else
            {
               LocalizationManager.translateId(this._denLock.titleTxt,11268);
               LocalizationManager.translateId(this._denLock.bodyTxt,11269);
               this._denLock.agree_box.visible = true;
               this._denLock.agree_txt.visible = true;
               this._denLock.unlockDenBtn.y = 76.6;
               this._denLock.lockDenBtn.y = 76.6;
               this._denLock.bodyTxt.y = -26.9;
            }
            this._denLock.lockDenBtn.visible = !gMainFrame.userInfo.isMyDenPrivate;
            this._denLock.unlockDenBtn.visible = gMainFrame.userInfo.isMyDenPrivate;
            return;
         }
         if(this._denLockPopup.visible)
         {
            this._denLockPopup.close();
         }
         else
         {
            this._denLockPopup.open();
         }
      }
      
      private function onDenLockAudioPopup(e:MouseEvent) : void
      {
         e.stopPropagation();
      }
      
      private function buildDenAudioWindows() : void
      {
         if(Boolean(this._scrollButtons))
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._audioItemWindows) && this._audioItemWindows.numChildren > 0)
         {
            this._audioItemWindows.destroy();
            this._audioItemWindows = null;
         }
         var numItemsInCurrentArray:int = this._numAudioItemsLastDrawn = this._audioItems.length;
         var xCount:int = Math.min(numItemsInCurrentArray,3);
         var yCount:int = Math.ceil(xCount / 2);
         this._audioItemWindows = new WindowGenerator();
         this._audioItemWindows.init(xCount,yCount,numItemsInCurrentArray,1,1,1,ItemWindowOriginal,this._audioItems,"icon",{
            "mouseDown":this.winMouseDown,
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut,
            "memberOnlyDown":this.memberOnlyDownAudio
         },{"isAudio":true},null,false,false);
         this._denAudio.itemWindow.addChild(this._audioItemWindows);
         LocalizationManager.translateId(this._denAudio.titleTxt,11270);
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._audioItemWindows,260,170,0,"scrollbar2",this._audioItemWindows.boxHeight);
      }
      
      private function getLastPlacedId() : int
      {
         var mc:MovieClip = null;
         for(var i:int = 0; i < this._audioItemWindows.numWindowsCreated; i++)
         {
            mc = MovieClip(this._audioItemWindows.bg.getChildAt(i));
            if(Boolean(mc.isLastPlacedAudio))
            {
               return i;
            }
         }
         return -1;
      }
      
      private function overDenLockPopup(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._roomMgr._bInDenShop = true;
         this._denItemHolder.handleMouse(0,0,false);
      }
      
      private function outDenLockPopup(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._roomMgr._bInDenShop = false;
      }
      
      private function onLockUnlockDenDown(e:MouseEvent) : void
      {
         e.stopPropagation();
         gMainFrame.userInfo.isMyDenPrivate = !gMainFrame.userInfo.isMyDenPrivate;
         DenXtCommManager.requestSetDenPrivacy(gMainFrame.userInfo.isMyDenPrivate,this._agreeBox.checked);
         this._denLockPopup.close();
         this.changeDownToUpStateLock();
         this._denEditor.lockBtn.denLock.visible = gMainFrame.userInfo.isMyDenPrivate;
         this._denEditor.lockBtn.denUnlock.visible = !gMainFrame.userInfo.isMyDenPrivate;
         this._denLock.lockDenBtn.visible = !gMainFrame.userInfo.isMyDenPrivate;
         this._denLock.unlockDenBtn.visible = gMainFrame.userInfo.isMyDenPrivate;
         if(gMainFrame.userInfo.isMyDenPrivate)
         {
            LocalizationManager.translateId(this._denLock.titleTxt,11266);
            LocalizationManager.translateId(this._denLock.bodyTxt,11267);
            this._denLock.agree_box.visible = false;
            this._denLock.agree_txt.visible = false;
            this._denLock.unlockDenBtn.y = 68.1;
            this._denLock.lockDenBtn.y = 68.1;
            this._denLock.bodyTxt.y = -14.4;
         }
         else
         {
            LocalizationManager.translateId(this._denLock.titleTxt,11268);
            LocalizationManager.translateId(this._denLock.bodyTxt,11269);
            this._denLock.agree_box.visible = true;
            this._denLock.agree_txt.visible = true;
            this._denLock.unlockDenBtn.y = 76.6;
            this._denLock.lockDenBtn.y = 76.6;
            this._denLock.bodyTxt.y = -26.9;
         }
         if(this._denLockToggleCallback != null)
         {
            this._denLockToggleCallback(false);
            this._denLockToggleCallback = null;
         }
      }
      
      private function onDenLockPopupClose(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         if(Boolean(this._denLockPopup))
         {
            this._denLockPopup.close();
            this.changeDownToUpStateLock();
         }
      }
      
      private function onAudioPopupClose(e:MouseEvent) : void
      {
         if(Boolean(e))
         {
            e.stopPropagation();
         }
         if(Boolean(this._denAudioPopup))
         {
            this._denAudioPopup.close();
            this._denEditor.denAudio.downToUpState();
         }
      }
      
      private function changeDownToUpStateLock() : void
      {
         if(Boolean(this._denEditor.lockBtn.denLock.visible))
         {
            this._denEditor.lockBtn.denLock.downToUpState();
         }
         else
         {
            this._denEditor.lockBtn.denUnlock.downToUpState();
         }
         this._roomMgr._bInDenShop = false;
      }
      
      private function lockOverBtnHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._roomMgr._bInDenShop = true;
         this._denItemHolder.handleMouse(0,0,false);
      }
      
      private function lockOutBtnHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._roomMgr._bInDenShop = false;
      }
      
      private function addListeners() : void
      {
         this._denEditor.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMouseOverDenHud,false,0,true);
         this._denEditor.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._mainHud.furnBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.customizeBtnHandler,false,0,true);
         this._mainHud.furnBtn.addEventListener(MouseEvent.MOUSE_OVER,this.customizeBtnOverHandler,false,0,true);
         this._mainHud.furnBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.recycleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.recycleBtnHandler,false,0,true);
         this._denEditor.recycleBtn.addEventListener(MouseEvent.MOUSE_OVER,this.recycleBtnOverHandler,false,0,true);
         this._denEditor.recycleBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.shopBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.shopBtnHandler,false,0,true);
         this._denEditor.shopBtn.addEventListener(MouseEvent.MOUSE_OVER,this.shopBtnOverHandler,false,0,true);
         this._denEditor.shopBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.switchDenBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.denSwitchBtnHandler,false,0,true);
         this._denEditor.switchDenBtn.addEventListener(MouseEvent.MOUSE_OVER,this.denSwitchBtnOverHandler,false,0,true);
         this._denEditor.switchDenBtn.addEventListener(MouseEvent.MOUSE_OUT,this.denSwitchBtnOutHandler,false,0,true);
         this._denEditor.lArrowBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.scrollBtnHandler,false,0,true);
         this._denEditor.rArrowBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.scrollBtnHandler,false,0,true);
         this._denEditor.normBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._denEditor.normBtnDn.addEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler,false,0,true);
         this._denEditor.normBtnDn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.themeBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._denEditor.themeBtnDn.addEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler,false,0,true);
         this._denEditor.themeBtnDn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.petBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._denEditor.petBtnDn.addEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler,false,0,true);
         this._denEditor.petBtnDn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.audioBtnDn.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._denEditor.audioBtnDn.addEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler,false,0,true);
         this._denEditor.audioBtnDn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.lockBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.lockContainerHandler,false,0,true);
         this._denEditor.lockBtn.addEventListener(MouseEvent.MOUSE_OVER,this.lockOverBtnHandler,false,0,true);
         this._denEditor.lockBtn.addEventListener(MouseEvent.MOUSE_OUT,this.lockOutBtnHandler,false,0,true);
         this._denEditor.denAudio.addEventListener(MouseEvent.MOUSE_DOWN,this.audioBtnHandler,false,0,true);
         this._denEditor.denAudio.addEventListener(MouseEvent.MOUSE_OVER,this.audioBtnOverHandler,false,0,true);
         this._denEditor.denAudio.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._denEditor.clearDenBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.clearDenBtn,false,0,true);
         this._denEditor.clearDenBtn.addEventListener(MouseEvent.MOUSE_OVER,this.clearDenBtnOverHandler,false,0,true);
         this._denEditor.clearDenBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         this._denEditor.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMouseOverDenHud);
         this._denEditor.closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._mainHud.furnBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.customizeBtnHandler);
         this._mainHud.furnBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.customizeBtnOverHandler);
         this._mainHud.furnBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.recycleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.recycleBtnHandler);
         this._denEditor.recycleBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.recycleBtnOverHandler);
         this._denEditor.recycleBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.shopBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.shopBtnHandler);
         this._denEditor.shopBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.shopBtnOverHandler);
         this._denEditor.shopBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.switchDenBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.denSwitchBtnHandler);
         this._denEditor.switchDenBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.denSwitchBtnOverHandler);
         this._denEditor.switchDenBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.denSwitchBtnOutHandler);
         this._denEditor.normBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._denEditor.normBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler);
         this._denEditor.normBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.themeBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._denEditor.themeBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler);
         this._denEditor.themeBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.petBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._denEditor.petBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler);
         this._denEditor.petBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.lArrowBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.scrollBtnHandler);
         this._denEditor.rArrowBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.scrollBtnHandler);
         this._denEditor.audioBtnDn.removeEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._denEditor.audioBtnDn.removeEventListener(MouseEvent.MOUSE_OVER,this.tabBtnOverHandler);
         this._denEditor.audioBtnDn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.lockBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.lockContainerHandler);
         this._denEditor.lockBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.lockOverBtnHandler);
         this._denEditor.lockBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.lockOutBtnHandler);
         this._denEditor.denAudio.removeEventListener(MouseEvent.MOUSE_DOWN,this.audioBtnHandler);
         this._denEditor.denAudio.removeEventListener(MouseEvent.MOUSE_OVER,this.audioBtnOverHandler);
         this._denEditor.denAudio.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._denEditor.clearDenBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.clearDenBtn);
         this._denEditor.clearDenBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.clearDenBtnOverHandler);
         this._denEditor.clearDenBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
      }
      
      private function printName(evt:MouseEvent) : void
      {
         DebugUtility.debugTrace(evt.currentTarget.name);
      }
   }
}

