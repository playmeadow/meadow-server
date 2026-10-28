package gui
{
   import avatar.Avatar;
   import com.sbi.client.KeepAlive;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DenSwitcher
   {
      
      private const MIN_NUM_DENS:int = 1;
      
      private const DENSWITCH_MEDIA_ID:int = 1168;
      
      private var _numTotalSlots:int;
      
      private var _playerAvatar:Avatar;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _shop:Shop;
      
      private var _views:Array;
      
      private var _activeIdx:int;
      
      private var _idx:int;
      
      private var _recycling:Boolean;
      
      private var _recyclingOnly:Boolean;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _mediaHelpers:Array;
      
      private var _contentItems:Array;
      
      private var _switchContent:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _choosingContent:MovieClip;
      
      private var _scrollButtons:SBScrollbar;
      
      private var _itemWindows:WindowGenerator;
      
      private var _openStoreOnly:Boolean;
      
      private var _firstOpenIdx:int;
      
      private var _glId:int;
      
      private var _storeItemIndex:int;
      
      public function DenSwitcher()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:Boolean = false, param4:Boolean = false, param5:Function = null, param6:int = -1, param7:int = -1, param8:int = -1, param9:int = 450, param10:int = 250) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._playerAvatar = param1;
         this._guiLayer = param2;
         this._closeCallback = param5;
         this._recyclingOnly = param3;
         this._openStoreOnly = param4;
         this._firstOpenIdx = param6;
         this._storeItemIndex = param8;
         this._numTotalSlots = SwitchManager.NUM_DEN_ROOM_SLOTS;
         this._mediaHelpers = [];
         if(param7 == -1)
         {
            this._glId = GenericListXtCommManager.DEN_ROOM_SHOP_ID;
         }
         else
         {
            this._glId = param7;
         }
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.DENSWITCH_MEDIA_ID,this.onMediaItemLoaded,true);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         KeepAlive.stopKATimer(this._switchContent);
         var _loc1_:int = 0;
         while(_loc1_ < this._views.length)
         {
            if(this._views[_loc1_])
            {
               this._views[_loc1_].destroy();
               this._views[_loc1_] = null;
            }
            _loc1_++;
         }
         if(this._shop)
         {
            this._shop.destroy();
            this._shop = null;
         }
         if(this._switchContent)
         {
            if(this._switchContent.root.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(this._switchContent.root));
            this._switchContent.root.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._switchContent = null;
            if(this._closeBtn)
            {
               this._closeBtn = null;
            }
            if(this._contentItems)
            {
               this._contentItems = null;
            }
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         this._recyclingOnly = false;
         this._recycling = false;
         this._closeCallback = null;
      }
      
      public function close() : void
      {
         if(this._closeCallback != null)
         {
            this._closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      public function get idx() : int
      {
         return this._idx;
      }
      
      public function showDenSwitcher(param1:Boolean) : void
      {
         if(Boolean(this._switchContent) && this._switchContent.root.visible != param1)
         {
            this._switchContent.root.visible = param1;
            if(param1)
            {
               DarkenManager.darken(MovieClip(this._switchContent.root));
            }
            else
            {
               DarkenManager.unDarken(MovieClip(this._switchContent.root));
            }
         }
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc2_:Boolean = false;
         if(param1)
         {
            this._closeBtn = MovieClip(param1.getChildAt(0)).bx;
            this._switchContent = MovieClip(param1.getChildAt(0)).c;
            KeepAlive.startKATimer(this._switchContent);
            this._guiLayer.addChild(param1);
            param1.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            param1.x = MainFrame.VIEW_WIDTH * 0.5;
            param1.y = MainFrame.VIEW_HEIGHT * 0.5;
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(param1);
            this.addListeners();
            _loc2_ = this._firstOpenIdx != -1;
            this.initVisibilityAndStates();
            this.buildWindows();
            if(this._openStoreOnly)
            {
               param1.visible = false;
               this.onItemWindowDown(null);
            }
            else if(_loc2_)
            {
               this.onItemWindowDown(null);
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function initVisibilityAndStates() : void
      {
         this._activeIdx = DenSwitch.activeDenIdx;
         this._switchContent.buyPopup.tag.visible = false;
         this._switchContent.oopsPopup.body_txt.text = "";
         LocalizationManager.translateId(this._switchContent.switchTitleTxt,11271);
         this._switchContent.buyPopup.tag.txt.text = "";
         this._switchContent.buyPopup.paw.gray.visible = false;
         this._switchContent.buyPopup.banner.visible = false;
         this._switchContent.buyPopup.lock.visible = false;
         this._switchContent.buyPopup.lockOpen.visible = false;
         this._switchContent.buyPopup.colorChange_btn.visible = false;
         this._switchContent.buyPopup.paw.visible = true;
         this._switchContent.buyPopup.visible = false;
         this._switchContent.oopsPopup.visible = false;
         this._switchContent.oopsCostPopup.visible = false;
         this._switchContent.denShopTag.visible = false;
         this._switchContent.saveAmlTag.visible = false;
      }
      
      private function buildWindows() : void
      {
         var _loc6_:MovieClip = null;
         var _loc7_:MediaHelper = null;
         if(this._scrollButtons)
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         var _loc1_:int = this._numTotalSlots;
         var _loc2_:int = Math.min(_loc1_,4);
         var _loc3_:int = Math.ceil(_loc2_ / 2);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(_loc2_,_loc3_,_loc1_,2,2,0,ItemWindowAnimal,DenSwitch.denList,"icon",{
            "mouseDown":this.onItemWindowDown,
            "mouseOver":this.onItemWindowOver,
            "mouseOut":this.onItemWindowOut
         },{"recylingOnly":this._recyclingOnly},null,false,false);
         this._switchContent.itemBlock.addChild(this._itemWindows);
         this._views = new Array(this._numTotalSlots);
         this._contentItems = new Array(this._numTotalSlots);
         this._activeIdx = DenSwitch.activeDenIdx;
         var _loc4_:int = 0;
         while(_loc4_ < this._numTotalSlots)
         {
            _loc6_ = MovieClip(this._itemWindows.bg.getChildAt(_loc4_));
            this._contentItems[_loc4_] = _loc6_;
            if(DenSwitch.denList[_loc4_] != null)
            {
               _loc7_ = new MediaHelper();
               _loc7_.init(DenSwitch.denList[_loc4_].mediaId,this.mediaHelperCallback,DenSwitch.denList[_loc4_].isMemberOnly);
               this._views[_loc4_] = _loc7_;
            }
            else if(this._firstOpenIdx == -1)
            {
               this._firstOpenIdx = _loc4_;
            }
            _loc4_++;
         }
         if(this._firstOpenIdx == -1)
         {
            this._firstOpenIdx = 0;
         }
         var _loc5_:int = DenSwitch.numDens;
         if(_loc5_ > this.MIN_NUM_DENS)
         {
            this._switchContent.recycleBtn.gray.visible = false;
            this._switchContent.recycleBtn.mouse.visible = true;
            this._switchContent.recycleBtn.down.visible = false;
         }
         else
         {
            this._switchContent.recycleBtn.gray.visible = true;
            this._switchContent.recycleBtn.mouse.visible = false;
            this._switchContent.recycleBtn.down.visible = false;
         }
         if(this._recyclingOnly)
         {
            this._recycling = true;
         }
         if(_loc5_ >= this._numTotalSlots && !this._recyclingOnly)
         {
            this._switchContent.denShopTag.visible = true;
         }
         else
         {
            this._switchContent.denShopTag.visible = false;
         }
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._itemWindows,840,440,0,"scrollbar2",224.6);
      }
      
      public function switchDenCallback(param1:Boolean) : void
      {
         if(param1)
         {
            this.close();
         }
         else
         {
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11272);
            this._switchContent.oopsPopup.visible = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function recycleDenCallback(param1:Boolean, param2:int) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         if(param1)
         {
            if(this._recyclingOnly)
            {
               DarkenManager.showLoadingSpiral(false);
               if(this._closeCallback != null)
               {
                  this._closeCallback(true);
               }
               else
               {
                  this.destroy();
               }
            }
            else
            {
               _loc3_ = this._contentItems[param2];
               if(this._views[param2])
               {
                  this._views[param2].destroy();
                  this._views[param2] = null;
               }
               this._recycling = false;
               _loc4_ = 0;
               while(_loc4_ < this._numTotalSlots)
               {
                  this._contentItems[_loc4_].recycle.visible = false;
                  _loc4_++;
               }
               _loc3_.resetWindow(param2);
               if(DenSwitch.numDens <= this.MIN_NUM_DENS)
               {
                  this._switchContent.recycleBtn.gray.visible = true;
                  this._switchContent.recycleBtn.mouse.visible = false;
                  this._switchContent.recycleBtn.down.visible = false;
               }
               if(DenSwitch.numDens >= this._numTotalSlots)
               {
                  this._switchContent.denShopTag.visible = true;
               }
               else
               {
                  this._switchContent.denShopTag.visible = false;
               }
            }
         }
         else
         {
            DarkenManager.darken(this._switchContent.oopsPopup);
            LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11273);
            this._switchContent.oopsPopup.visible = true;
            this._recycling = true;
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function purchasedDenRoomCallback() : void
      {
         DenPreviewManager.handleDenPurchase();
         if(!this._openStoreOnly)
         {
            this.closeDenShop(true);
         }
         MovieClip(this._itemWindows).bg.getChildAt(this._idx).currItem = DenSwitch.denList[this._idx];
         var _loc1_:MovieClip = this._contentItems[this._idx];
         _loc1_.buyDen.visible = false;
         _loc1_.den.visible = true;
         _loc1_.den.txt.text = DenSwitch.denList[this._idx].name;
         _loc1_.den.sel.visible = false;
         var _loc2_:MediaHelper = new MediaHelper();
         _loc2_.init(DenSwitch.denList[this._idx].mediaId,this.mediaHelperCallback,DenSwitch.denList[this._idx].isMemberOnly);
         this._views[this._idx] = _loc2_;
         if(DenSwitch.numDens >= this._numTotalSlots)
         {
            this._switchContent.denShopTag.visible = true;
         }
         else
         {
            this._switchContent.denShopTag.visible = false;
         }
         if(DenSwitch.numDens > this.MIN_NUM_DENS)
         {
            this._switchContent.recycleBtn.gray.visible = false;
            this._switchContent.recycleBtn.mouse.visible = true;
            this._switchContent.recycleBtn.down.visible = false;
         }
         if(this._shop)
         {
            this._shop.denItemIdx = this._firstOpenIdx = Math.max(0,DenSwitch.nextFreeSlotIdx);
         }
      }
      
      public function closeDenShop(param1:Boolean = false) : void
      {
         if(this._shop)
         {
            this._shop.destroy();
            this._shop = null;
         }
         if(this._openStoreOnly)
         {
            this.close();
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         while(_loc2_ < this._views.length)
         {
            if(this._views[_loc2_] == param1.mediaHelper)
            {
               if(Boolean(param1.passback) && !gMainFrame.userInfo.isMember)
               {
                  this._contentItems[_loc2_].gray.amlMask.amlBox.addChild(param1);
               }
               else
               {
                  this._contentItems[_loc2_].den.itemBlock.addChild(param1);
               }
               break;
            }
            _loc2_++;
         }
      }
      
      private function confirmRecycleHandler(param1:Object) : void
      {
         if(param1.status)
         {
            DenSwitch.removeDen(this._idx,this.recycleDenCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
            this._idx = param1.currentTarget.index;
         }
         else
         {
            this._idx = this._firstOpenIdx;
         }
         if(Boolean(this._contentItems[this._idx].buyDen.visible) || this._openStoreOnly)
         {
            if(!GenericListGuiManager.isWorldShopOpen())
            {
               this._shop = new Shop();
               this._shop.init(this._glId,DefPacksDefHelper.DEF_DEN_ROOM,this._playerAvatar,this._guiLayer,true,this.closeDenShop,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,this._idx,this.purchasedDenRoomCallback,this._openStoreOnly,this._storeItemIndex);
            }
         }
         else if(this._contentItems[this._idx].gray.visible == true && !this._recycling)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.DENS,"useLockedDen/" + DenSwitch.denList[this._idx].name);
            }
         }
         else if(this._recycling)
         {
            if(this._idx == this._activeIdx)
            {
               DarkenManager.darken(this._switchContent.oopsPopup);
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11274);
               this._switchContent.oopsPopup.visible = true;
            }
            else if(this._idx == 0)
            {
               DarkenManager.darken(this._switchContent.oopsPopup);
               LocalizationManager.translateId(this._switchContent.oopsPopup.body_txt,11275);
               this._switchContent.oopsPopup.visible = true;
            }
            else
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14715,Utility.convertNumberToString(DenSwitch.denList[this._idx].recycleValue)),true,this.confirmRecycleHandler);
            }
         }
         else if(this._contentItems[this._idx].den.visible == true)
         {
            if(this._idx != this._activeIdx)
            {
               DarkenManager.showLoadingSpiral(true);
               DenSwitch.switchDens(this._idx,this.switchDenCallback);
            }
         }
      }
      
      private function onItemWindowOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._idx = param1.currentTarget.index;
         if(this._contentItems[this._idx].den.currentFrameLabel != "mouse")
         {
            this._contentItems[this._idx].den.gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._idx = param1.currentTarget.index;
         if(this._contentItems[this._idx].den.currentFrameLabel != "out")
         {
            this._contentItems[this._idx].den.gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._switchContent.oopsPopup);
         this._switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.close();
      }
      
      private function onRecycleDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         param1.stopPropagation();
         if(!this._recyclingOnly)
         {
            if(this._recycling)
            {
               _loc2_ = 0;
               while(_loc2_ < this._numTotalSlots)
               {
                  this._contentItems[_loc2_].recycle.visible = false;
                  _loc2_++;
               }
               this._recycling = false;
            }
            else if(!this._switchContent.recycleBtn.gray.visible)
            {
               this._recycling = true;
               _loc3_ = 0;
               while(_loc3_ < this._numTotalSlots)
               {
                  if(this._views[_loc3_])
                  {
                     if(!this._contentItems[_loc3_].buyDen.visible)
                     {
                        this._contentItems[_loc3_].recycle.visible = true;
                     }
                  }
                  _loc3_++;
               }
            }
            else
            {
               this._switchContent.recycleBtn.mouse.visible = false;
            }
         }
      }
      
      private function onRecycleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14626),843,480);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onMoreDenDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._recyclingOnly)
         {
            this._shop = new Shop();
            this._shop.init(this._glId,DefPacksDefHelper.DEF_DEN_ROOM,this._playerAvatar,this._guiLayer,true,this.closeDenShop,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,this._idx,this.purchasedDenRoomCallback);
         }
      }
      
      private function addListeners() : void
      {
         if(this._closeBtn)
         {
            this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         if(this._switchContent)
         {
            this._switchContent.recycleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRecycleDown,false,0,true);
            this._switchContent.recycleBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onRecycleOver,false,0,true);
            this._switchContent.recycleBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onRecycleOut,false,0,true);
            this._switchContent.oopsPopup.closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onOopsClose,false,0,true);
            this._switchContent.denShopTag.denShopBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onMoreDenDown,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._numTotalSlots)
         {
            if(this._contentItems[_loc1_])
            {
               this._contentItems[_loc1_].removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown);
               this._contentItems[_loc1_].removeEventListener(MouseEvent.ROLL_OVER,this.onItemWindowOver);
               this._contentItems[_loc1_].removeEventListener(MouseEvent.ROLL_OUT,this.onItemWindowOut);
            }
            _loc1_++;
         }
         if(this._closeBtn)
         {
            this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         if(this._switchContent)
         {
            this._switchContent.recycleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRecycleDown);
            this._switchContent.recycleBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onRecycleOver);
            this._switchContent.recycleBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onRecycleOut);
            this._switchContent.oopsPopup.closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOopsClose);
            this._switchContent.denShopTag.denShopBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMoreDenDown);
         }
      }
   }
}

