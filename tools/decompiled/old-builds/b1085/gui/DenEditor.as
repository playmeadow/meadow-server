package gui
{
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
      
      private const ADDITIONAL_ITEMS_FOR_MEMBERS:int = 100;
      
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
      
      public function DenEditor()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:MovieClip) : void
      {
         this._playerAvatar = param1;
         this._denEditor = GETDEFINITIONBYNAME("DenEditorAsset");
         this._guiLayer = param2;
         this._mainHud = param3;
         staticEditor = this._denEditor;
         this._currContentX = 0;
         this._currPlacementMax = Boolean(gMainFrame.userInfo.isMember) || (gMainFrame.userInfo.pendingFlags & 1 << 1) > 0 ? int(this.MAX_PLACED_ITEMS + this.ADDITIONAL_ITEMS_FOR_MEMBERS) : this.MAX_PLACED_ITEMS;
         this._currWarningCount = Boolean(gMainFrame.userInfo.isMember) || (gMainFrame.userInfo.pendingFlags & 1 << 1) > 0 ? int(this.WARNING_ITEM_COUNT + this.ADDITIONAL_ITEMS_FOR_MEMBERS) : this.WARNING_ITEM_COUNT;
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
         if(this._denLockPopup)
         {
            this._denLockPopup.destroy();
         }
         if(this._denAudioPopup)
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
         if(this._allWindows)
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(this._themeWindows)
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         if(this._petWindows)
         {
            this._petWindows.destroy();
            this._petWindows = null;
         }
         if(this._audioItemWindows)
         {
            this._audioItemWindows.destroy();
            this._audioItemWindows = null;
         }
         this._isRecycling = false;
         this._numAudioItemsLastDrawn = 0;
         DenXtCommManager.denEditorDIResponseCallback = null;
         if(this._glowTimer)
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
         if(this._allWindows)
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(this._themeWindows)
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         if(this._petWindows)
         {
            this._petWindows.destroy();
            this._petWindows = null;
         }
         if(this._audioItemWindows)
         {
            this._audioItemWindows.destroy();
            this._audioItemWindows = null;
         }
         this.currItemWindow = null;
      }
      
      public function resetPetWindowList() : void
      {
         if(this._petWindows)
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
      
      public function reloadDenItems() : void
      {
         this.setupPlayerItems();
      }
      
      public function get isDenHudOpen() : Boolean
      {
         return this._denEditor ? Boolean(this._denEditor.bottomHud.visible) : false;
      }
      
      public function reloadPetItems() : void
      {
         var _loc2_:DenItem = null;
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc1_:Array = gMainFrame.userInfo.myPetsInDen;
         this._petItems = [];
         if(_loc1_)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc1_.length)
            {
               _loc2_ = _loc1_[_loc3_];
               _loc4_ = PetManager.getPetDef(PetManager.getDefIdFromLBits(_loc2_.version));
               if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc4_.type))
               {
                  this._petItems.push(_loc2_);
               }
               _loc3_++;
            }
         }
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
         this._viewableWidth = this._denEditor.itemBlock.width;
      }
      
      private function setupPlayerItems() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Array = [];
         if(Boolean(this._playerAvatar) && this._playerAvatar.inventoryDenFull.itemArray.length > 0)
         {
            _loc1_ = this._playerAvatar.inventoryDenFull.itemArray.concat();
         }
         else if(gMainFrame.userInfo.playerUserInfo.denItemsFull)
         {
            _loc1_ = gMainFrame.userInfo.playerUserInfo.denItemsFull.concat();
         }
         this.reloadPetItems();
         this._currItems = [];
         this._numAudioItemsLastDrawn = 0;
         if(Boolean(_loc1_) && _loc1_.length > 0)
         {
            _loc2_ = int(_loc1_.length);
            this._allNormalDenItems = [];
            this._audioItems = [];
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               if(_loc1_[_loc3_].sortId == DenItem.SORT_AUDIO)
               {
                  this._audioItems.push(_loc1_[_loc3_]);
               }
               else if(_loc1_[_loc3_].enviroType == AvatarManager.roomEnviroType)
               {
                  this._allNormalDenItems.push(_loc1_[_loc3_]);
               }
               _loc3_++;
            }
            this._themeItems = Utility.sortItems(this._allNormalDenItems,0,DenItem.SORT_FLOORING,DenItem.SORT_WALLPAPER);
            _loc4_ = 0;
            while(_loc4_ < this._themeItems.length)
            {
               this._themeItems[_loc4_] = this._themeItems[_loc4_].clone();
               _loc4_++;
            }
            if(this._denEditor.normBtnUp.visible)
            {
               this._currItems = this._allNormalDenItems;
               this._denEditor.itemCountTxt.text = this._currItems.length + "/" + Shop.maxDenItems;
            }
            else if(this._denEditor.themeBtnUp.visible)
            {
               this._currItems = this._themeItems;
               this._denEditor.itemCountTxt.text = this._currItems.length;
            }
            else if(this._denEditor.petBtnUp.visible)
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
         if(this._allWindows)
         {
            this._allWindows.destroy();
            this._allWindows = null;
         }
         if(this._themeWindows)
         {
            this._themeWindows.destroy();
            this._themeWindows = null;
         }
         this.drawItemWindows();
      }
      
      private function onShopRecycleClose(param1:Boolean = false, param2:Boolean = false) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = this.diResponseCallback;
         if(param1)
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
            if(!param2)
            {
               if(this._allWindows)
               {
                  this._allWindows.destroy();
                  this._allWindows = null;
               }
               if(this._themeWindows)
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
         var _loc1_:WindowGenerator = null;
         var _loc2_:int = 0;
         if(this.currItemWindow == null)
         {
            if(this._currItems)
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
               _loc2_ = 0;
               while(_loc2_ < this._themeItems.length)
               {
                  this._themeItems[_loc2_].destroy();
                  _loc2_++;
               }
               this._themeItems = Utility.sortItems(this._allNormalDenItems,0,DenItem.SORT_FLOORING,DenItem.SORT_WALLPAPER);
               _loc2_ = 0;
               while(_loc2_ < this._themeItems.length)
               {
                  this._themeItems[_loc2_] = this._themeItems[_loc2_].clone();
                  _loc2_++;
               }
               this._currItems = this._themeItems;
            }
            _loc1_ = new WindowGenerator();
            this.currItemWindow = _loc1_;
            _loc1_.init(this.NUM_VIS_X_WIN,this.NUM_VIS_Y_WIN,this._numItems,this.X_WIN_OFFSET,this.Y_WIN_OFFSET,this.X_WIN_START,ItemWindowOriginal,this._currItems,"icon",{
               "mouseDown":this.winMouseDown,
               "mouseOver":this.winMouseOver,
               "mouseOut":this.winMouseOut,
               "memberOnlyDown":this.memberOnlyDown
            },{"isPetItem":this._currItems == this._petItems},this.onWindowsGenerated,true);
            this._currContentX = 0;
            if(this._currItems)
            {
               _loc1_.x = this._currContentX;
               _loc1_.y = 0;
            }
         }
         if(this._currItems)
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
         var _loc1_:WindowGenerator = null;
         if(this._denEditor.normBtnUp.visible)
         {
            if(this._allWindows)
            {
               _loc1_ = this._allWindows;
            }
         }
         else if(this._denEditor.themeBtnUp.visible)
         {
            if(this._themeWindows)
            {
               _loc1_ = this._themeWindows;
            }
         }
         else if(this._denEditor.petBtnUp.visible)
         {
            if(this._petWindows)
            {
               _loc1_ = this._petWindows;
            }
         }
         return _loc1_;
      }
      
      private function set currItemWindow(param1:WindowGenerator) : void
      {
         if(this._denEditor.normBtnUp.visible)
         {
            this._allWindows = param1;
         }
         else if(this._denEditor.themeBtnUp.visible)
         {
            this._themeWindows = param1;
         }
         else if(this._denEditor.petBtnUp.visible)
         {
            this._petWindows = param1;
         }
      }
      
      private function onWindowsGenerated() : void
      {
         this.loadCurrViewableObjects(0,this.currItemWindow);
      }
      
      private function scrollBtnHandler(param1:MouseEvent) : void
      {
         var _loc4_:* = 0;
         var _loc5_:Number = NaN;
         var _loc6_:* = 0;
         param1.stopPropagation();
         var _loc2_:Number = 0;
         var _loc3_:WindowGenerator = this.currItemWindow;
         if(param1.currentTarget.name == this._denEditor.lArrowBtn.name)
         {
            if(this._currContentX < 0)
            {
               if(this._currContentX <= -this._fullScreenChange)
               {
                  _loc2_ = this._fullScreenChange;
               }
               else
               {
                  _loc4_ = int(this._numColsInView - 2);
                  while(_loc4_ > 0)
                  {
                     if(this._currContentX <= -(this._oneColWidth * _loc4_))
                     {
                        _loc2_ = this._oneColWidth * _loc4_;
                        break;
                     }
                     _loc4_--;
                  }
                  if(-_loc2_ > this._currContentX)
                  {
                     _loc2_ = -this._currContentX;
                  }
               }
            }
            else if(_loc3_.width > this._scrollMask.width)
            {
            }
         }
         else
         {
            _loc5_ = _loc3_.width + this._currContentX - this._viewableWidth;
            if(_loc5_ > 0)
            {
               if(_loc5_ >= this._fullScreenChange)
               {
                  _loc2_ = -this._fullScreenChange;
               }
               else
               {
                  _loc6_ = int(this._numColsInView - 2);
                  while(_loc6_ > 0)
                  {
                     if(_loc5_ >= this._oneColWidth * _loc6_)
                     {
                        _loc2_ = -(this._oneColWidth * _loc6_);
                        break;
                     }
                     _loc6_--;
                  }
                  if(-_loc2_ < _loc5_)
                  {
                     _loc2_ = -_loc5_;
                  }
               }
            }
         }
         if(_loc2_ != 0)
         {
            this._currContentX += _loc2_;
            this.loadCurrViewableObjects(this._currContentX,_loc3_);
            new GTween(_loc3_,this.EASE_TIME,{"x":this._scrollMask.x + this._currContentX},{"ease":Quadratic.easeOut});
         }
      }
      
      private function loadCurrViewableObjects(param1:Number, param2:WindowGenerator) : void
      {
         var _loc7_:Object = null;
         var _loc3_:int = -(param1 / (this._oneColWidth + this.X_WIN_OFFSET));
         var _loc4_:int = _loc3_ + this._numColsInView;
         var _loc5_:int = param2.bg.numChildren;
         var _loc6_:int = _loc3_;
         while(_loc6_ < _loc4_)
         {
            if(_loc6_ < _loc5_)
            {
               _loc7_ = param2.bg.getChildAt(_loc6_);
               _loc7_.loadCurrItem(0,param1);
            }
            _loc6_++;
         }
      }
      
      private function customizeBtnHandler(param1:MouseEvent) : void
      {
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/denCustomize");
         param1.stopPropagation();
         this.toggleBottomHudVisibility();
         if(openCallback != null)
         {
            openCallback();
         }
      }
      
      private function customizeBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14641),730,450);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function toggleBottomHudVisibility() : void
      {
         this._denEditor.bottomHud.visible = !this._denEditor.bottomHud.visible;
         this._mainHud.visible = !this._denEditor.bottomHud.visible;
         this._mainHud.furnBtn.visible = this._mainHud.visible;
         if(this._denEditor.bottomHud.visible)
         {
            this._roomMgr.setRoomMode(RoomManagerWorld.ROOM_MODE_DEN);
            this.drawItemWindows();
         }
         else
         {
            this._roomMgr.setRoomMode(RoomManagerWorld.ROOM_MODE_AVATAR);
         }
      }
      
      public function toggleEditorHud(param1:Boolean) : void
      {
         this._denEditor.bottomHud.visible = param1;
         this.onDenLockPopupClose(null);
         this.onAudioPopupClose(null);
      }
      
      private function tabBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == this._denEditor.normBtnDn.name)
         {
            this._denEditor.normBtnUp.visible = true;
            this._denEditor.themeBtnUp.visible = false;
            this._denEditor.petBtnUp.visible = false;
            this._denEditor.itemCountTxt.text = this._allNormalDenItems.length + "/" + Shop.maxDenItems;
            this._currItems = this._allNormalDenItems;
         }
         else if(param1.currentTarget.name == this._denEditor.themeBtnDn.name)
         {
            this._denEditor.normBtnUp.visible = false;
            this._denEditor.themeBtnUp.visible = true;
            this._denEditor.petBtnUp.visible = false;
            this._denEditor.itemCountTxt.text = this._themeItems.length;
            this._currItems = this._themeItems;
         }
         else
         {
            if(param1.currentTarget.name != this._denEditor.petBtnDn.name)
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
      
      private function tabBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == this._denEditor.normBtnDn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11216),120,405);
         }
         else if(param1.currentTarget.name == this._denEditor.themeBtnDn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14642),205,405);
         }
         else if(param1.currentTarget.name == this._denEditor.petBtnDn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11240),290,405);
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:WindowGenerator = null;
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         if(param1.currentTarget.cir.currentFrameLabel == "green")
         {
            param1.currentTarget.cir.gotoAndStop("over");
         }
         else
         {
            if(param1.currentTarget.cir.currentFrameLabel == "down")
            {
               param1.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("over");
            }
            if(this._currItems == this._themeItems)
            {
               _loc2_ = this._allWindows;
            }
            else if(this._currItems == this._allNormalDenItems)
            {
               _loc2_ = this._themeWindows;
            }
            if(_loc2_)
            {
               _loc3_ = 0;
               while(_loc3_ < _loc2_.bg.numChildren)
               {
                  _loc4_ = MovieClip(_loc2_.bg.getChildAt(_loc3_));
                  if(_loc4_.defId == param1.currentTarget.defId)
                  {
                     if(_loc4_.cir.currentFrameLabel == "down")
                     {
                        _loc4_.cir.gotoAndStop("downMouse");
                     }
                     else if(_loc4_.cir.currentFrameLabel != "downMouse")
                     {
                        _loc4_.cir.gotoAndStop("over");
                     }
                     break;
                  }
                  _loc3_++;
               }
            }
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         var _loc2_:WindowGenerator = null;
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "over" && Boolean(param1.currentTarget.isActivePet))
            {
               param1.currentTarget.cir.gotoAndStop("green");
            }
            else
            {
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
               {
                  param1.currentTarget.cir.gotoAndStop("down");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "down")
               {
                  param1.currentTarget.cir.gotoAndStop("up");
               }
               if(this._currItems == this._themeItems)
               {
                  _loc2_ = this._allWindows;
               }
               else if(this._currItems == this._allNormalDenItems)
               {
                  _loc2_ = this._themeWindows;
               }
               if(_loc2_)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.bg.numChildren)
                  {
                     _loc4_ = MovieClip(_loc2_.bg.getChildAt(_loc3_));
                     if(_loc4_.defId == param1.currentTarget.defId)
                     {
                        if(_loc4_.cir.currentFrameLabel == "downMouse")
                        {
                           _loc4_.cir.gotoAndStop("down");
                        }
                        else if(_loc4_.cir.currentFrameLabel != "down")
                        {
                           _loc4_.cir.gotoAndStop("up");
                        }
                        break;
                     }
                     _loc3_++;
                  }
               }
            }
         }
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:WindowGenerator = null;
         var _loc5_:int = 0;
         var _loc6_:MovieClip = null;
         param1.stopPropagation();
         if(param1.currentTarget.isActivePet)
         {
            new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(14714));
            return;
         }
         var _loc2_:DenItem = param1.currentTarget.isAudio ? this._audioItems[param1.currentTarget.index] : this._currItems[param1.currentTarget.index];
         if(_loc2_.categoryId == 0)
         {
            if(_loc2_.sortId < 4 && this._denItemHolder.numberOfInUseItems >= this._currWarningCount)
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
            if(param1.currentTarget.isAudio)
            {
               _loc3_ = this.getLastPlacedId();
               if(_loc3_ != -1)
               {
                  MovieClip(this._audioItemWindows.bg.getChildAt(_loc3_)).resetAudioDown();
                  this._audioItems[_loc3_].categoryId = 0;
               }
               MovieClip(this._audioItemWindows.bg.getChildAt(param1.currentTarget.index)).setAudioDown();
            }
            this.placeItemInRoom(_loc2_);
         }
         else
         {
            if(param1.currentTarget.isAudio)
            {
               _loc3_ = this.getLastPlacedId();
               if(param1.currentTarget.index == _loc3_)
               {
                  return;
               }
            }
            this._denItemHolder.removeItem(_loc2_.invIdx,_loc2_.refId);
            _loc2_.categoryId = 0;
         }
         if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            param1.currentTarget.cir.gotoAndStop("over");
         }
         else
         {
            param1.currentTarget.cir.gotoAndStop("downMouse");
         }
         if(!param1.currentTarget.isAudio)
         {
            if(this._currItems == this._themeItems)
            {
               _loc4_ = this._allWindows;
            }
            else
            {
               _loc4_ = this._themeWindows;
            }
            if(_loc4_)
            {
               _loc5_ = 0;
               while(_loc5_ < _loc4_.bg.numChildren)
               {
                  _loc6_ = MovieClip(_loc4_.bg.getChildAt(_loc5_));
                  if(_loc6_.defId == param1.currentTarget.defId)
                  {
                     if(_loc4_ == this._themeWindows)
                     {
                        this._themeItems[_loc6_.index].categoryId = _loc2_.categoryId;
                     }
                     else
                     {
                        this._allNormalDenItems[_loc6_.index].categoryId = _loc2_.categoryId;
                     }
                     if(_loc6_.cir.currentFrameLabel == "downMouse")
                     {
                        _loc6_.cir.gotoAndStop("over");
                     }
                     else
                     {
                        _loc6_.cir.gotoAndStop("downMouse");
                     }
                     break;
                  }
                  _loc5_++;
               }
            }
         }
         AJAudio.playSubMenuBtnClick();
      }
      
      private function getWarningMessage(param1:int) : String
      {
         var _loc2_:int = this._currPlacementMax - param1;
         var _loc3_:String = "";
         if(_loc2_ > 1)
         {
            _loc3_ = LocalizationManager.translateIdAndInsertOnly(11262,_loc2_);
         }
         else if(_loc2_ == 1)
         {
            _loc3_ = LocalizationManager.translateIdAndInsertOnly(11263,_loc2_);
         }
         else if(_loc2_ == 0)
         {
            _loc3_ = LocalizationManager.translateIdOnly(11264);
         }
         else
         {
            _loc3_ = LocalizationManager.translateIdOnly(11265);
         }
         return _loc3_;
      }
      
      private function memberOnlyDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         UpsellManager.displayPopup(UpsellManager.DEN_ITEMS,"placeDenItem/" + this._currItems[param1.currentTarget.index].itemDefId);
      }
      
      private function memberOnlyDownAudio(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         UpsellManager.displayPopup(UpsellManager.DEN_AUDIO,"selectDenAudio/" + this._audioItems[param1.currentTarget.index].itemDefId);
      }
      
      private function placeItemInRoom(param1:DenItem) : void
      {
         var _loc2_:int = DenItem.getInWorldId(param1.sortId,this._roomMgr.denCatId);
         param1.categoryId = _loc2_;
         this._roomMgr.spawnNewDenItem({
            "i":param1.invIdx,
            "p":param1.itemDefId << 16 | _loc2_,
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
            "r":param1.refId
         });
      }
      
      private function onClose(param1:MouseEvent) : void
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
         if(param1)
         {
            param1.stopPropagation();
         }
         this.toggleBottomHudVisibility();
         if(closeCallback != null)
         {
            closeCallback();
         }
      }
      
      private function shopBtnHandler(param1:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         if(this._shop)
         {
            this._shop.destroy();
         }
         this._roomMgr._bInDenShop = true;
         DenXtCommManager.saveDenItemsState();
         if(openCallback != null)
         {
            openCallback();
         }
         this._shop = new Shop();
         if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            this._shop.init(GenericListXtCommManager.DEN_ITEM_CRYSTALREEF_SHOP_ID,DefPacksDefHelper.DEF_DEN_ITEM,this._playerAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
         else
         {
            this._shop.init(GenericListXtCommManager.DEN_ITEM_MAIN_SHOP_ID,DefPacksDefHelper.DEF_DEN_ITEM,this._playerAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
      }
      
      private function shopBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14643),795,390);
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
         GuiManager.openDenRoomSwitcher(false,null,false,-1,GenericListXtCommManager.DEN_ROOM_FULL_SHOP_ID);
      }
      
      private function denSwitchBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14644),705,400);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function denSwitchBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onShopClose(param1:Boolean) : void
      {
         this.onShopRecycleClose(param1);
         if(Boolean(this._denAudioPopup && this._denAudioPopup.visible) && Boolean(param1) && this._shop.isAudioShop)
         {
            this.buildDenAudioWindows();
         }
         if(this._shop)
         {
            this._shop.destroy();
            this._shop = null;
         }
         this._roomMgr._bInDenShop = false;
      }
      
      private function recycleBtnHandler(param1:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         param1.stopPropagation();
         if(this._recycle)
         {
            this._recycle.destroy();
         }
         DenXtCommManager.saveDenItemsState();
         this._recycle = new RecycleItems();
         this._recycle.init(RecycleItems.RECYCLE_DEN_ITEMS,this._guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private function recycleBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14645),615,400);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         this.onShopRecycleClose(param1);
         if(this._recycle)
         {
            this._recycle.destroy();
            this._recycle = null;
         }
      }
      
      private function onDenItemRemoved(param1:DenItemHolderEvent) : void
      {
         var _loc5_:Array = null;
         var _loc6_:DenItem = null;
         var _loc7_:int = 0;
         var _loc8_:MovieClip = null;
         var _loc9_:WindowGenerator = null;
         var _loc10_:* = 0;
         var _loc2_:int = int(param1.id);
         var _loc3_:int = param1.refId;
         var _loc4_:Object = null;
         if(Boolean(param1.array) && param1.array.length > 0)
         {
            _loc4_ = param1.array[0];
         }
         if(_loc3_ == DenItem.REF_ID_DEN_ITEM)
         {
            if(Boolean(_loc4_) && _loc4_.s == DenItem.SORT_AUDIO)
            {
               _loc5_ = this._audioItems;
            }
            else
            {
               _loc5_ = this._allNormalDenItems;
            }
         }
         else
         {
            _loc5_ = this._petItems;
         }
         if(_loc5_)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc5_.length)
            {
               if(_loc5_[_loc7_].invIdx == _loc2_)
               {
                  _loc6_ = _loc5_[_loc7_];
                  _loc6_.categoryId = 0;
                  break;
               }
               _loc7_++;
            }
            if(Boolean(this._currItems) && Boolean(this._currItems[0]) && this._currItems[0].refId == _loc3_)
            {
               _loc9_ = this.currItemWindow;
               _loc10_ = int(this._currItems.length - 1);
               while(_loc10_ >= 0)
               {
                  _loc8_ = MovieClip(_loc9_).bg.getChildAt(_loc10_);
                  _loc6_ = this._currItems[_loc8_.index];
                  if(_loc6_.refId == _loc3_ && _loc6_.invIdx == _loc2_)
                  {
                     _loc8_.cir.gotoAndStop("up");
                     _loc6_.categoryId = 0;
                     break;
                  }
                  _loc10_--;
               }
               if(this.currItemWindow == this._allWindows)
               {
                  _loc5_ = this._themeItems;
                  _loc9_ = this._themeWindows;
               }
               else if(this.currItemWindow == this._themeWindows)
               {
                  _loc5_ = this._allNormalDenItems;
                  _loc9_ = this._allWindows;
               }
               if(_loc9_)
               {
                  _loc10_ = 0;
                  while(_loc10_ < _loc5_.length)
                  {
                     _loc8_ = MovieClip(_loc9_).bg.getChildAt(_loc10_);
                     _loc6_ = _loc5_[_loc8_.index];
                     if(_loc6_.refId == _loc3_ && _loc6_.invIdx == _loc2_)
                     {
                        _loc8_.cir.gotoAndStop("up");
                        _loc6_.categoryId = 0;
                        break;
                     }
                     _loc10_++;
                  }
               }
            }
         }
      }
      
      private function onDenSaveState(param1:DenItemHolderEvent) : void
      {
         if(Boolean(param1.array) && param1.array.length > 0)
         {
            DenXtCommManager.requestDenStateChange(param1.array);
         }
      }
      
      private function glowTimerHandler(param1:TimerEvent) : void
      {
         this._glowTimer.stop();
         this._mainHud.furnBtn.glow.visible = false;
      }
      
      private function audioBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function onAudioRecycle(param1:MouseEvent) : void
      {
         DenXtCommManager.denEditorDIResponseCallback = null;
         param1.stopPropagation();
         if(this._recycle)
         {
            this._recycle.destroy();
         }
         DenXtCommManager.saveDenItemsState();
         this._recycle = new RecycleItems();
         this._recycle.init(RecycleItems.RECYCLE_DEN_AUDIO,this._guiLayer,false,this.onAudioRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private function onAudioRecycleClose(param1:Boolean = false) : void
      {
         this.onShopRecycleClose(param1,true);
         if(this._recycle)
         {
            this._recycle.destroy();
            this._recycle = null;
         }
         this.onAudioPopupClose(null);
      }
      
      private function onAudioRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14646),param1.currentTarget.x + this._denAudioPopup.x,param1.currentTarget.y - 25 + 235);
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
         this._shop = new Shop();
         this._shop.init(GenericListXtCommManager.DEN_ITEM_AUDIO_SHOP_ID,DefPacksDefHelper.DEF_DEN_ITEM,this._playerAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
      }
      
      private function onAudioShopBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14647),param1.currentTarget.x + this._denAudioPopup.x,param1.currentTarget.y - 25 + 235);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onAudioShopBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function audioBtnOverHandler(param1:MouseEvent) : void
      {
         if(!this._denEditor.denAudioPopup.visible)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(11270),549,95);
            GuiManager.toolTip.startTimer(param1);
         }
      }
      
      private function onMouseMouseOverDenHud(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._denItemHolder.handleMouse(0,0,false);
      }
      
      private function lockContainerHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
            if(gMainFrame.userInfo.isMyDenPrivate)
            {
               LocalizationManager.translateId(this._denLock.titleTxt,11266);
               LocalizationManager.translateId(this._denLock.bodyTxt,11267);
            }
            else
            {
               LocalizationManager.translateId(this._denLock.titleTxt,11268);
               LocalizationManager.translateId(this._denLock.bodyTxt,11269);
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
      
      private function onDenLockAudioPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function buildDenAudioWindows() : void
      {
         if(this._scrollButtons)
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._audioItemWindows) && this._audioItemWindows.numChildren > 0)
         {
            this._audioItemWindows.destroy();
            this._audioItemWindows = null;
         }
         var _loc1_:int = this._numAudioItemsLastDrawn = this._audioItems.length;
         var _loc2_:int = Math.min(_loc1_,3);
         var _loc3_:int = Math.ceil(_loc2_ / 2);
         this._audioItemWindows = new WindowGenerator();
         this._audioItemWindows.init(_loc2_,_loc3_,_loc1_,1,1,1,ItemWindowOriginal,this._audioItems,"icon",{
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
         var _loc2_:MovieClip = null;
         var _loc1_:int = 0;
         while(_loc1_ < this._audioItemWindows.numWindowsCreated)
         {
            _loc2_ = MovieClip(this._audioItemWindows.bg.getChildAt(_loc1_));
            if(_loc2_.isLastPlacedAudio)
            {
               return _loc1_;
            }
            _loc1_++;
         }
         return -1;
      }
      
      private function overDenLockPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._roomMgr._bInDenShop = true;
         this._denItemHolder.handleMouse(0,0,false);
      }
      
      private function outDenLockPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._roomMgr._bInDenShop = false;
      }
      
      private function onLockUnlockDenDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         gMainFrame.userInfo.isMyDenPrivate = !gMainFrame.userInfo.isMyDenPrivate;
         DenXtCommManager.requestSetDenPrivacy(gMainFrame.userInfo.isMyDenPrivate);
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
         }
         else
         {
            LocalizationManager.translateId(this._denLock.titleTxt,11268);
            LocalizationManager.translateId(this._denLock.bodyTxt,11269);
         }
      }
      
      private function onDenLockPopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._denLockPopup)
         {
            this._denLockPopup.close();
            this.changeDownToUpStateLock();
         }
      }
      
      private function onAudioPopupClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._denAudioPopup)
         {
            this._denAudioPopup.close();
            this._denEditor.denAudio.downToUpState();
         }
      }
      
      private function changeDownToUpStateLock() : void
      {
         if(this._denEditor.lockBtn.denLock.visible)
         {
            this._denEditor.lockBtn.denLock.downToUpState();
         }
         else
         {
            this._denEditor.lockBtn.denUnlock.downToUpState();
         }
         this._roomMgr._bInDenShop = false;
      }
      
      private function lockOverBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._roomMgr._bInDenShop = true;
         this._denItemHolder.handleMouse(0,0,false);
      }
      
      private function lockOutBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      }
      
      private function printName(param1:MouseEvent) : void
      {
         DebugUtility.debugTrace(param1.currentTarget.name);
      }
   }
}

