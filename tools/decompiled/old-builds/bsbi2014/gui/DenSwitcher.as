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
      
      public function init(initPlayerAvatar:Avatar, initGuiLayer:DisplayLayer, isRecycling:Boolean = false, openStoreOnly:Boolean = false, initCloseCallback:Function = null, initFirstOpenIndex:int = -1, initGlId:int = -1, initShopItemIndex:int = -1, initPopupX:int = 450, initPopupY:int = 250) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._playerAvatar = initPlayerAvatar;
         this._guiLayer = initGuiLayer;
         this._closeCallback = initCloseCallback;
         this._recyclingOnly = isRecycling;
         this._openStoreOnly = openStoreOnly;
         this._firstOpenIdx = initFirstOpenIndex;
         this._storeItemIndex = initShopItemIndex;
         this._numTotalSlots = SwitchManager.NUM_DEN_ROOM_SLOTS;
         this._mediaHelpers = [];
         if(initGlId == -1)
         {
            this._glId = GenericListXtCommManager.DEN_ROOM_SHOP_ID;
         }
         else
         {
            this._glId = initGlId;
         }
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.DENSWITCH_MEDIA_ID,this.onMediaItemLoaded,true);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         KeepAlive.stopKATimer(this._switchContent);
         for(var i:int = 0; i < this._views.length; i++)
         {
            if(Boolean(this._views[i]))
            {
               this._views[i].destroy();
               this._views[i] = null;
            }
         }
         if(Boolean(this._shop))
         {
            this._shop.destroy();
            this._shop = null;
         }
         if(Boolean(this._switchContent))
         {
            if(this._switchContent.root.parent == this._guiLayer)
            {
               this._guiLayer.removeChild(this._switchContent.root);
            }
            DarkenManager.unDarken(MovieClip(this._switchContent.root));
            this._switchContent.root.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._switchContent = null;
            if(Boolean(this._closeBtn))
            {
               this._closeBtn = null;
            }
            if(Boolean(this._contentItems))
            {
               this._contentItems = null;
            }
         }
         if(Boolean(this._itemWindows))
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
      
      public function showDenSwitcher(show:Boolean) : void
      {
         if(Boolean(this._switchContent) && this._switchContent.root.visible != show)
         {
            this._switchContent.root.visible = show;
            if(show)
            {
               DarkenManager.darken(MovieClip(this._switchContent.root));
            }
            else
            {
               DarkenManager.unDarken(MovieClip(this._switchContent.root));
            }
         }
      }
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         var shouldOpenItemWindow:Boolean = false;
         if(Boolean(img))
         {
            this._closeBtn = MovieClip(img.getChildAt(0)).bx;
            this._switchContent = MovieClip(img.getChildAt(0)).c;
            KeepAlive.startKATimer(this._switchContent);
            this._guiLayer.addChild(img);
            img.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            img.x = MainFrame.VIEW_WIDTH * 0.5;
            img.y = MainFrame.VIEW_HEIGHT * 0.5;
            DarkenManager.showLoadingSpiral(false);
            DarkenManager.darken(img);
            this.addListeners();
            shouldOpenItemWindow = this._firstOpenIdx != -1;
            this.initVisibilityAndStates();
            this.buildWindows();
            if(this._openStoreOnly)
            {
               img.visible = false;
               this.onItemWindowDown(null);
            }
            else if(shouldOpenItemWindow)
            {
               this.onItemWindowDown(null);
            }
         }
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
         var mc:MovieClip = null;
         var denRoomHelper:MediaHelper = null;
         if(Boolean(this._scrollButtons))
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._itemWindows))
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         var numItemsInCurrentArray:int = this._numTotalSlots;
         var xCount:int = Math.min(numItemsInCurrentArray,4);
         var yCount:int = Math.ceil(xCount / 2);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(xCount,yCount,numItemsInCurrentArray,2,2,0,ItemWindowAnimal,DenSwitch.denList,"icon",{
            "mouseDown":this.onItemWindowDown,
            "mouseOver":this.onItemWindowOver,
            "mouseOut":this.onItemWindowOut
         },{"recylingOnly":this._recyclingOnly},null,false,false);
         this._switchContent.itemBlock.addChild(this._itemWindows);
         this._views = new Array(this._numTotalSlots);
         this._contentItems = new Array(this._numTotalSlots);
         this._activeIdx = DenSwitch.activeDenIdx;
         for(var i:int = 0; i < this._numTotalSlots; i++)
         {
            mc = MovieClip(this._itemWindows.bg.getChildAt(i));
            this._contentItems[i] = mc;
            if(DenSwitch.denList[i] != null)
            {
               denRoomHelper = new MediaHelper();
               denRoomHelper.init(DenSwitch.denList[i].mediaId,this.mediaHelperCallback,DenSwitch.denList[i].isMemberOnly);
               this._views[i] = denRoomHelper;
            }
            else if(this._firstOpenIdx == -1)
            {
               this._firstOpenIdx = i;
            }
         }
         if(this._firstOpenIdx == -1)
         {
            this._firstOpenIdx = 0;
         }
         var numDens:int = DenSwitch.numDens;
         if(numDens > this.MIN_NUM_DENS)
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
         if(numDens >= this._numTotalSlots && !this._recyclingOnly)
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
      
      public function switchDenCallback(success:Boolean) : void
      {
         if(success)
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
      
      private function recycleDenCallback(success:Boolean, removedIndex:int) : void
      {
         var slotMC:MovieClip = null;
         var i:int = 0;
         if(success)
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
               slotMC = this._contentItems[removedIndex];
               if(Boolean(this._views[removedIndex]))
               {
                  this._views[removedIndex].destroy();
                  this._views[removedIndex] = null;
               }
               this._recycling = false;
               for(i = 0; i < this._numTotalSlots; i++)
               {
                  this._contentItems[i].recycle.visible = false;
               }
               slotMC.resetWindow(removedIndex);
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
         var slotMC:MovieClip = this._contentItems[this._idx];
         slotMC.buyDen.visible = false;
         slotMC.den.visible = true;
         slotMC.den.txt.text = DenSwitch.denList[this._idx].name;
         slotMC.den.sel.visible = false;
         var denRoomHelper:MediaHelper = new MediaHelper();
         denRoomHelper.init(DenSwitch.denList[this._idx].mediaId,this.mediaHelperCallback,DenSwitch.denList[this._idx].isMemberOnly);
         this._views[this._idx] = denRoomHelper;
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
         if(Boolean(this._shop))
         {
            this._shop.denItemIdx = this._firstOpenIdx = Math.max(0,DenSwitch.nextFreeSlotIdx);
         }
      }
      
      public function closeDenShop(itemsPurchased:Boolean = false) : void
      {
         if(Boolean(this._shop))
         {
            this._shop.destroy();
            this._shop = null;
         }
         if(this._openStoreOnly)
         {
            this.close();
         }
      }
      
      private function mediaHelperCallback(mc:MovieClip) : void
      {
         for(var j:int = 0; j < this._views.length; j++)
         {
            if(this._views[j] == mc.mediaHelper)
            {
               if(Boolean(mc.passback) && !gMainFrame.userInfo.isMember)
               {
                  this._contentItems[j].gray.amlMask.amlBox.addChild(mc);
               }
               else
               {
                  this._contentItems[j].den.itemBlock.addChild(mc);
               }
               break;
            }
         }
      }
      
      private function confirmRecycleHandler(o:Object) : void
      {
         if(Boolean(o.status))
         {
            DenSwitch.removeDen(this._idx,this.recycleDenCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function onItemWindowDown(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
            this._idx = evt.currentTarget.index;
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
      
      private function onItemWindowOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._idx = evt.currentTarget.index;
         if(this._contentItems[this._idx].den.currentFrameLabel != "mouse")
         {
            this._contentItems[this._idx].den.gotoAndPlay("mouse");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemWindowOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._idx = evt.currentTarget.index;
         if(this._contentItems[this._idx].den.currentFrameLabel != "out")
         {
            this._contentItems[this._idx].den.gotoAndPlay("out");
         }
      }
      
      private function onOopsClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(this._switchContent.oopsPopup);
         this._switchContent.oopsPopup.visible = false;
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.close();
      }
      
      private function onRecycleDown(evt:MouseEvent) : void
      {
         var i:int = 0;
         var j:int = 0;
         evt.stopPropagation();
         if(!this._recyclingOnly)
         {
            if(this._recycling)
            {
               for(i = 0; i < this._numTotalSlots; i++)
               {
                  this._contentItems[i].recycle.visible = false;
               }
               this._recycling = false;
            }
            else if(!this._switchContent.recycleBtn.gray.visible)
            {
               this._recycling = true;
               for(j = 0; j < this._numTotalSlots; j++)
               {
                  if(Boolean(this._views[j]))
                  {
                     if(!this._contentItems[j].buyDen.visible)
                     {
                        this._contentItems[j].recycle.visible = true;
                     }
                  }
               }
            }
            else
            {
               this._switchContent.recycleBtn.mouse.visible = false;
            }
         }
      }
      
      private function onRecycleOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14626),843,480);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onRecycleOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onMoreDenDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._recyclingOnly)
         {
            this._shop = new Shop();
            this._shop.init(this._glId,DefPacksDefHelper.DEF_DEN_ROOM,this._playerAvatar,this._guiLayer,true,this.closeDenShop,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5,this._idx,this.purchasedDenRoomCallback);
         }
      }
      
      private function addListeners() : void
      {
         if(Boolean(this._closeBtn))
         {
            this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         if(Boolean(this._switchContent))
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
         for(var i:int = 0; i < this._numTotalSlots; i++)
         {
            if(Boolean(this._contentItems[i]))
            {
               this._contentItems[i].removeEventListener(MouseEvent.MOUSE_DOWN,this.onItemWindowDown);
               this._contentItems[i].removeEventListener(MouseEvent.ROLL_OVER,this.onItemWindowOver);
               this._contentItems[i].removeEventListener(MouseEvent.ROLL_OUT,this.onItemWindowOut);
            }
         }
         if(Boolean(this._closeBtn))
         {
            this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         if(Boolean(this._switchContent))
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

