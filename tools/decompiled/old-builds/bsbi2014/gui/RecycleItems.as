package gui
{
   import avatar.AvatarManager;
   import com.sbi.popup.SBPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.ItemXtCommManager;
   import localization.LocalizationManager;
   
   public class RecycleItems
   {
      
      private static const RECYCLE_TUT_LIST_ID:int = 52;
      
      public static const RECYCLE_ACCESSORIES:int = 0;
      
      public static const RECYCLE_DEN_ITEMS:int = 1;
      
      public static const RECYCLE_DEN_AUDIO:int = 2;
      
      public static const RECYCLE_DEN_ITEMS_OCEAN_ONLY:int = 3;
      
      public static const RECYCLE_DEN_ITEMS_LAND_ONLY:int = 4;
      
      public static const RECYCLE_ACCESSORIES_OCEAN_ONLY:int = 5;
      
      public static const RECYCLE_ACCESSORIES_LAND_ONLY:int = 6;
      
      private static var _accessoriesScrollValue:Number = 0;
      
      private static var _accessoriesOceanOnlyScrollValue:Number = 0;
      
      private static var _accessoriesLandOnlyScrollValue:Number = 0;
      
      private static var _denScrollValue:Number = 0;
      
      private static var _denOceanOnlyScrollValue:Number = 0;
      
      private static var _denLandOnlyScrollValue:Number = 0;
      
      private static var _denAudioScrollValue:Number = 0;
      
      private static var _scrollValue:Number = 0;
      
      private var _recycle:MovieClip;
      
      private var _recycleSmall:MovieClip;
      
      private var _itemRecycleId:int;
      
      private var _savedTradeIdx:int;
      
      private var _recyclePopup:SBPopup;
      
      private var _recyclePopupSmall:SBPopup;
      
      private var _closeCallback:Function;
      
      private var _onRecycleSuccessCallback:Function;
      
      private var _recycleInventory:Array;
      
      private var _scrollButtons:MovieClip;
      
      private var _itemWindows:WindowGenerator;
      
      private var _popupLayer:DisplayObjectContainer;
      
      private var _idx:int;
      
      private var _height:int;
      
      private var _recycleOneItem:Boolean;
      
      private var _hasRecycled:Boolean;
      
      private var _isInCurrEnviro:Boolean;
      
      private var _tempMC:Object;
      
      private var _spirals:Array;
      
      public function RecycleItems()
      {
         super();
      }
      
      private static function onInfoBtnOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function init(itemRecycleId:int, guiLayer:DisplayObjectContainer, recycleOneItem:Boolean = false, init_closeCallback:Function = null, initPopupX:int = 450, initPopupY:int = 250, isInCurrEnviro:Boolean = false) : void
      {
         this._recycle = GETDEFINITIONBYNAME("RecyclePopupContent");
         this._recycleSmall = GETDEFINITIONBYNAME("RecycleSmlPopupContent");
         this._recycleSmall.itemBlock.gift.visible = false;
         this._recycleSmall.itemBlock.addBtn.visible = false;
         this._recycleSmall.itemBlock.removeBtn.visible = false;
         this._recycleSmall.itemBlock.avtSpecificIcon.visible = false;
         this._recycleSmall.itemBlock.avtSpecific.visible = false;
         this._recycleSmall.itemBlock.avtSpecificHighlight.visible = false;
         this._itemRecycleId = itemRecycleId;
         this._popupLayer = guiLayer;
         this._recycleOneItem = recycleOneItem;
         this._isInCurrEnviro = isInCurrEnviro;
         this._recyclePopup = new SBPopup(guiLayer,GETDEFINITIONBYNAME("RecyclePopupSkin"),this._recycle,true,true,false,false,true);
         this._recyclePopupSmall = new SBPopup(guiLayer,GETDEFINITIONBYNAME("RecycleSmlPopupSkin"),this._recycleSmall,false,true,false,false,true);
         this._closeCallback = init_closeCallback;
         this._recyclePopup.x = initPopupX;
         this._recyclePopup.y = initPopupY;
         this._recyclePopup.bxClosesPopup = false;
         this._height = this._recycle.itemBlock.height;
         this._spirals = [];
         this.addListeners();
         AJAudio.playItemRecycledSound();
         if(this._itemRecycleId == RECYCLE_DEN_ITEMS || this._itemRecycleId == RECYCLE_DEN_ITEMS_OCEAN_ONLY || this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY)
         {
            if(gMainFrame.userInfo.playerUserInfo.denItemsFull.length <= 0)
            {
               DenXtCommManager.requestDenItems(this.fillInventory);
            }
         }
         this.fillInventory();
      }
      
      public function destroy() : void
      {
         var j:int = 0;
         this.removeListeners();
         if(Boolean(this._recyclePopup))
         {
            this._recyclePopup.destroy();
            this._recyclePopup = null;
         }
         if(Boolean(this._recyclePopupSmall))
         {
            this._recyclePopupSmall.destroy();
            this._recyclePopupSmall = null;
         }
         if(Boolean(this._scrollButtons))
         {
            _scrollValue = this._scrollButtons.scrollYValue;
            switch(this._itemRecycleId)
            {
               case RECYCLE_ACCESSORIES:
                  _accessoriesScrollValue = _scrollValue;
                  break;
               case RECYCLE_ACCESSORIES_LAND_ONLY:
                  _accessoriesLandOnlyScrollValue = _scrollValue;
                  break;
               case RECYCLE_ACCESSORIES_OCEAN_ONLY:
                  _accessoriesOceanOnlyScrollValue = _scrollValue;
                  break;
               case RECYCLE_DEN_ITEMS:
                  _denScrollValue = _scrollValue;
                  break;
               case RECYCLE_DEN_ITEMS_LAND_ONLY:
                  _denLandOnlyScrollValue = _scrollValue;
                  break;
               case RECYCLE_DEN_ITEMS_OCEAN_ONLY:
                  _denOceanOnlyScrollValue = _scrollValue;
                  break;
               case RECYCLE_DEN_AUDIO:
                  _denAudioScrollValue = _scrollValue;
            }
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._itemWindows))
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            for(j = 0; j < this._spirals.length; j++)
            {
               this._spirals[j].destroy();
            }
         }
         this._spirals = null;
         this._hasRecycled = false;
         this._tempMC = null;
         this._closeCallback = null;
      }
      
      public function hasBeenInited() : Boolean
      {
         return this._recyclePopup != null;
      }
      
      private function fillInventory(isRefill:Boolean = false) : void
      {
         var temp:Array = null;
         var i:int = 0;
         var j:int = 0;
         if(!isRefill)
         {
            this._recycleInventory = [];
            if(this._itemRecycleId == RECYCLE_ACCESSORIES)
            {
               this._recycleInventory = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               _scrollValue = _accessoriesScrollValue;
            }
            else if(this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY || this._itemRecycleId == RECYCLE_ACCESSORIES_OCEAN_ONLY)
            {
               temp = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY)
               {
                  for(i = 0; i < temp.length; i++)
                  {
                     if(temp[i].enviroType == Utility.ENVIRO_LAND)
                     {
                        this._recycleInventory.push(temp[i]);
                     }
                  }
                  _scrollValue = _accessoriesLandOnlyScrollValue;
               }
               else
               {
                  for(i = 0; i < temp.length; i++)
                  {
                     if(temp[i].enviroType == Utility.ENVIRO_OCEAN)
                     {
                        this._recycleInventory.push(temp[i]);
                     }
                  }
                  _scrollValue = _accessoriesOceanOnlyScrollValue;
               }
            }
            else
            {
               temp = gMainFrame.userInfo.playerUserInfo.denItemsFull;
               if(this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY || this._itemRecycleId == RECYCLE_DEN_ITEMS_OCEAN_ONLY)
               {
                  if(this._isInCurrEnviro)
                  {
                     temp = Utility.denItemListByEnviroType(temp,AvatarManager.roomEnviroType);
                  }
               }
               this._recycleInventory = new Array();
               for(i = 0; i < temp.length; i++)
               {
                  if(this._itemRecycleId == RECYCLE_DEN_AUDIO)
                  {
                     if(temp[i].sortId == DenItem.SORT_AUDIO && temp[i].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
                     {
                        this._recycleInventory[j] = temp[i].clone();
                        j++;
                     }
                  }
                  else if(temp[i].sortId != DenItem.SORT_AUDIO)
                  {
                     if(this._itemRecycleId == RECYCLE_DEN_ITEMS || this._isInCurrEnviro)
                     {
                        this._recycleInventory[j] = temp[i].clone();
                        j++;
                     }
                     else if(this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY && temp[i].enviroType == Utility.ENVIRO_LAND)
                     {
                        this._recycleInventory[j] = temp[i].clone();
                        j++;
                     }
                     else if(temp[i].enviroType == Utility.ENVIRO_OCEAN)
                     {
                        this._recycleInventory[j] = temp[i].clone();
                        j++;
                     }
                  }
               }
               if(this._itemRecycleId == RECYCLE_DEN_AUDIO)
               {
                  _scrollValue = _denAudioScrollValue;
               }
               else if(this._itemRecycleId == RECYCLE_DEN_ITEMS)
               {
                  _scrollValue = _denScrollValue;
               }
               else if(this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY)
               {
                  _scrollValue = _denLandOnlyScrollValue;
               }
               else if(this._itemRecycleId == RECYCLE_DEN_ITEMS_OCEAN_ONLY)
               {
                  _scrollValue = _denOceanOnlyScrollValue;
               }
            }
         }
         this.createWindows();
      }
      
      private function createWindows() : void
      {
         if(Boolean(this._scrollButtons))
         {
            _scrollValue = this._scrollButtons.scrollYValue;
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._itemWindows) && this._itemWindows.numChildren > 0)
         {
            while(Boolean(this._itemWindows.bg.numChildren))
            {
               this._itemWindows.bg.removeChildAt(0);
            }
         }
         if(Boolean(this._itemWindows))
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         while(Boolean(this._recycle.itemBlock.numChildren))
         {
            this._recycle.itemBlock.removeChildAt(0);
         }
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(3,4,Math.max(this._recycleInventory.length,12),2,2,0,ItemWindowOriginal,this._recycleInventory,"icon",{
            "mouseDown":this.onItemWindowDown,
            "mouseOver":this.onItemRollOver,
            "mouseOut":this.onItemRollOut
         },{"isRecycling":true},null,false,false);
         this._recycle.itemBlock.addChild(this._itemWindows);
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._itemWindows,this._itemWindows.width,84 * 4 + 2 * 4,0,"scrollbar2",this._itemWindows.boxHeight + 2,_scrollValue);
      }
      
      private function attemptToRecycleItem(itemValue:int) : void
      {
         var currItem:Object = this._recycleInventory[this._idx];
         this._recycleSmall.itemBlock.iconLayer.addChild(this._tempMC.icon);
         this._recycleSmall.itemBlock.ocean.visible = currItem.isOcean;
         this._recycleSmall.itemBlock.avtSpecific.visible = false;
         LocalizationManager.translateIdAndInsert(this._recycleSmall.bodyTxt,11371,Utility.convertNumberToString(currItem.recycleValue));
         this._recyclePopupSmall.open();
      }
      
      private function sendRecycleRequest(status:Boolean) : void
      {
         var inventoryId:int = 0;
         var currItem:Object = null;
         var tradeList:Array = null;
         var i:int = 0;
         if(status)
         {
            DarkenManager.showLoadingSpiral(true);
            inventoryId = int(this._recycleInventory[this._idx].invIdx);
            currItem = this._recycleInventory[this._idx];
            tradeList = gMainFrame.userInfo.getMyTradeList();
            this._savedTradeIdx = -1;
            for(i = 0; i < tradeList.length; i++)
            {
               if(tradeList[i].type == this._itemRecycleId && tradeList[i].invIdx == inventoryId)
               {
                  this._savedTradeIdx = i;
                  break;
               }
            }
            if(this._itemRecycleId == RECYCLE_ACCESSORIES || this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY || this._itemRecycleId == RECYCLE_ACCESSORIES_OCEAN_ONLY)
            {
               ItemXtCommManager.requestItemRecycle(inventoryId,this.confirmRecycle,this.onRecycleListCallback);
            }
            else
            {
               DenXtCommManager.requestRecycle(true,inventoryId,this.confirmRecycle,this.onRecycleListCallback);
            }
         }
      }
      
      private function confirmRecycle(success:Boolean) : void
      {
         if(success)
         {
            if(Boolean(this._tempMC.icon.parent))
            {
               this._tempMC.icon.parent.removeChild(this._tempMC.icon);
            }
            if(this._savedTradeIdx != -1)
            {
               gMainFrame.userInfo.removeFromMyTradeList(this._savedTradeIdx);
               if(this._itemRecycleId == RECYCLE_ACCESSORIES || this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY || this._itemRecycleId == RECYCLE_ACCESSORIES_OCEAN_ONLY)
               {
                  TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
               }
               else if(this._itemRecycleId == RECYCLE_DEN_ITEMS || this._itemRecycleId == RECYCLE_DEN_AUDIO || this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY || this._itemRecycleId == RECYCLE_DEN_ITEMS_OCEAN_ONLY)
               {
                  TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
               }
            }
         }
         this._savedTradeIdx = -1;
      }
      
      private function onRecycleListCallback() : void
      {
         DarkenManager.showLoadingSpiral(false);
         this._recycleInventory.splice(this._idx,1);
         this._hasRecycled = true;
         if(this._onRecycleSuccessCallback != null)
         {
            this._onRecycleSuccessCallback();
         }
         if(this._recycleOneItem)
         {
            this.applyAndClose(true);
         }
         else
         {
            _scrollValue = this._scrollButtons.scrollYValue;
            this.fillInventory(true);
         }
      }
      
      public function setOnRecycleSuccessCallback(callback:Function) : void
      {
         this._onRecycleSuccessCallback = callback;
      }
      
      private function applyAndClose(itemRecycled:Boolean = false) : void
      {
         ItemXtCommManager.recycleIlCallback = null;
         DenXtCommManager.recycleDiCallback = null;
         if(this._closeCallback != null)
         {
            this._closeCallback(itemRecycled);
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.applyAndClose(this._hasRecycled);
      }
      
      private function onItemWindowDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._idx = evt.currentTarget.index;
         this._tempMC = this._recycleInventory[this._idx].clone();
         if(Boolean(this._recycleInventory[this._idx].isMemberOnly))
         {
            if(!gMainFrame.userInfo.isMember)
            {
               this._recycleSmall.itemBlock.lockOpen.visible = false;
               this._recycleSmall.itemBlock.lock.visible = true;
            }
            else
            {
               this._recycleSmall.itemBlock.lockOpen.visible = true;
               this._recycleSmall.itemBlock.lock.visible = false;
            }
            this._recycleSmall.itemBlock.gray.visible = false;
         }
         else
         {
            this._recycleSmall.itemBlock.lock.visible = false;
            this._recycleSmall.itemBlock.lockOpen.visible = false;
            this._recycleSmall.itemBlock.gray.visible = false;
         }
         if(!this._recycleInventory[this._idx].isRare)
         {
            this._recycleSmall.itemBlock.rare.visible = false;
         }
         this.attemptToRecycleItem(this._recycleInventory[this._idx].value);
      }
      
      private function onItemRollOver(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(evt.currentTarget.cir.currentFrameLabel == "down")
         {
            evt.currentTarget.cir.gotoAndStop("downMouse");
         }
         else if(evt.currentTarget.cir.currentFrameLabel != "downMouse")
         {
            evt.currentTarget.cir.gotoAndStop("over");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemRollOut(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            evt.currentTarget.cir.gotoAndStop("down");
         }
         else if(evt.currentTarget.cir.currentFrameLabel != "down")
         {
            evt.currentTarget.cir.gotoAndStop("up");
         }
      }
      
      private function onOkBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._recyclePopupSmall.close();
         this.sendRecycleRequest(true);
      }
      
      private function onNoBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._recycleSmall.itemBlock.iconLayer.removeChild(this._tempMC.icon);
         this._recyclePopupSmall.close();
      }
      
      private function onInfoBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(RECYCLE_TUT_LIST_ID);
      }
      
      private function onInfoBtnOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14678),evt.currentTarget.x + this._recyclePopup.x,evt.currentTarget.y + this._recyclePopup.y + evt.currentTarget.height);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function addListeners() : void
      {
         if(Boolean(this._recyclePopup))
         {
            this._recyclePopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         if(Boolean(this._recyclePopupSmall))
         {
            this._recyclePopupSmall.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onNoBtn,false,0,true);
         }
         this._recyclePopup.skin.s["infoBtn"].addEventListener(MouseEvent.MOUSE_DOWN,this.onInfoBtnDown,false,0,true);
         this._recyclePopup.skin.s["infoBtn"].addEventListener(MouseEvent.MOUSE_OVER,this.onInfoBtnOver,false,0,true);
         this._recyclePopup.skin.s["infoBtn"].addEventListener(MouseEvent.MOUSE_OUT,onInfoBtnOut,false,0,true);
         this._recycleSmall.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onOkBtn,false,0,true);
         this._recycleSmall.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNoBtn,false,0,true);
      }
      
      private function removeListeners() : void
      {
         if(Boolean(this._recyclePopup))
         {
            this._recyclePopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         if(Boolean(this._recyclePopupSmall))
         {
            this._recyclePopupSmall.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onNoBtn);
         }
         this._recycleSmall.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOkBtn);
         this._recycleSmall.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNoBtn);
         this._recyclePopup.skin.s["infoBtn"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onInfoBtnDown);
         this._recyclePopup.skin.s["infoBtn"].addEventListener(MouseEvent.MOUSE_OVER,this.onInfoBtnOver);
         this._recyclePopup.skin.s["infoBtn"].addEventListener(MouseEvent.MOUSE_OUT,onInfoBtnOut);
      }
   }
}

