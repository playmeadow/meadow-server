package gui
{
   import avatar.AvatarManager;
   import com.sbi.popup.SBPopup;
   import den.DenItem;
   import den.DenXtCommManager;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import item.Item;
   import item.ItemXtCommManager;
   
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
      
      private static function onInfoBtnOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function init(param1:int, param2:DisplayObjectContainer, param3:Boolean = false, param4:Function = null, param5:int = 450, param6:int = 250, param7:Boolean = false) : void
      {
         this._recycle = new (getDefinitionByName("RecyclePopupContent") as Class)();
         this._recycleSmall = new (getDefinitionByName("RecycleSmlPopupContent") as Class)();
         this._recycleSmall.itemBlock.gift.visible = false;
         this._recycleSmall.itemBlock.addBtn.visible = false;
         this._recycleSmall.itemBlock.removeBtn.visible = false;
         this._recycleSmall.itemBlock.avtSpecificIcon.visible = false;
         this._recycleSmall.itemBlock.avtSpecific.visible = false;
         this._recycleSmall.itemBlock.avtSpecificHighlight.visible = false;
         this._itemRecycleId = param1;
         this._popupLayer = param2;
         this._recycleOneItem = param3;
         this._isInCurrEnviro = param7;
         this._recyclePopup = new SBPopup(param2,new (getDefinitionByName("RecyclePopupSkin") as Class)(),this._recycle,true,true,false,false,true);
         this._recyclePopupSmall = new SBPopup(param2,new (getDefinitionByName("RecycleSmlPopupSkin") as Class)(),this._recycleSmall,false,true,false,false,true);
         this._closeCallback = param4;
         this._recyclePopup.x = param5;
         this._recyclePopup.y = param6;
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
         var _loc1_:int = 0;
         this.removeListeners();
         if(this._recyclePopup)
         {
            this._recyclePopup.destroy();
            this._recyclePopup = null;
         }
         if(this._recyclePopupSmall)
         {
            this._recyclePopupSmall.destroy();
            this._recyclePopupSmall = null;
         }
         if(this._scrollButtons)
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
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this._spirals.length)
            {
               this._spirals[_loc1_].destroy();
               _loc1_++;
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
      
      private function fillInventory(param1:Boolean = false) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(!param1)
         {
            this._recycleInventory = [];
            if(this._itemRecycleId == RECYCLE_ACCESSORIES)
            {
               this._recycleInventory = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               _scrollValue = _accessoriesScrollValue;
            }
            else if(this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY || this._itemRecycleId == RECYCLE_ACCESSORIES_OCEAN_ONLY)
            {
               _loc2_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY)
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.length)
                  {
                     if(_loc2_[_loc3_].enviroType == Utility.ENVIRO_LAND)
                     {
                        this._recycleInventory.push(_loc2_[_loc3_]);
                     }
                     _loc3_++;
                  }
                  _scrollValue = _accessoriesLandOnlyScrollValue;
               }
               else
               {
                  _loc3_ = 0;
                  while(_loc3_ < _loc2_.length)
                  {
                     if(_loc2_[_loc3_].enviroType == Utility.ENVIRO_OCEAN)
                     {
                        this._recycleInventory.push(_loc2_[_loc3_]);
                     }
                     _loc3_++;
                  }
                  _scrollValue = _accessoriesOceanOnlyScrollValue;
               }
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.playerUserInfo.denItemsFull;
               if(this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY || this._itemRecycleId == RECYCLE_DEN_ITEMS_OCEAN_ONLY)
               {
                  if(this._isInCurrEnviro)
                  {
                     _loc2_ = Utility.denItemListByEnviroType(_loc2_,AvatarManager.roomEnviroType);
                  }
               }
               this._recycleInventory = new Array();
               _loc3_ = 0;
               while(_loc3_ < _loc2_.length)
               {
                  if(this._itemRecycleId == RECYCLE_DEN_AUDIO)
                  {
                     if(_loc2_[_loc3_].sortId == DenItem.SORT_AUDIO && _loc2_[_loc3_].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
                     {
                        this._recycleInventory[_loc4_] = _loc2_[_loc3_].clone();
                        _loc4_++;
                     }
                  }
                  else if(_loc2_[_loc3_].sortId != DenItem.SORT_AUDIO)
                  {
                     if(this._itemRecycleId == RECYCLE_DEN_ITEMS || this._isInCurrEnviro)
                     {
                        this._recycleInventory[_loc4_] = _loc2_[_loc3_].clone();
                        _loc4_++;
                     }
                     else if(this._itemRecycleId == RECYCLE_DEN_ITEMS_LAND_ONLY && _loc2_[_loc3_].enviroType == Utility.ENVIRO_LAND)
                     {
                        this._recycleInventory[_loc4_] = _loc2_[_loc3_].clone();
                        _loc4_++;
                     }
                     else if(_loc2_[_loc3_].enviroType == Utility.ENVIRO_OCEAN)
                     {
                        this._recycleInventory[_loc4_] = _loc2_[_loc3_].clone();
                        _loc4_++;
                     }
                  }
                  _loc3_++;
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
         if(this._scrollButtons)
         {
            _scrollValue = this._scrollButtons.scrollYValue;
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(Boolean(this._itemWindows) && this._itemWindows.numChildren > 0)
         {
            while(this._itemWindows.bg.numChildren)
            {
               this._itemWindows.bg.removeChildAt(0);
            }
         }
         if(this._itemWindows)
         {
            this._itemWindows.destroy();
            this._itemWindows = null;
         }
         while(this._recycle.itemBlock.numChildren)
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
      
      private function attemptToRecycleItem(param1:int) : void
      {
         var _loc3_:String = null;
         var _loc2_:Object = this._recycleInventory[this._idx];
         this._recycleSmall.itemBlock.iconLayer.addChild(this._tempMC.icon);
         this._recycleSmall.itemBlock.ocean.visible = _loc2_.isOcean;
         if(Boolean(AvatarManager.playerAvatar && _loc2_ is Item) && Boolean(!ItemXtCommManager.canUseItem(_loc2_.defId,AvatarManager.playerAvatar.avTypeId)) && ItemXtCommManager.isItemSpecificToSomeAvatar(_loc2_.defId,_loc2_.enviroType))
         {
            _loc3_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(_loc2_.defId));
            if(_loc3_ != "-1")
            {
               if(this._recycleSmall.itemBlock.avtSpecific.currentFrameLabel != _loc3_)
               {
                  this._recycleSmall.itemBlock.avtSpecific.gotoAndStop(_loc3_);
               }
               this._recycleSmall.itemBlock.avtSpecific.visible = true;
            }
         }
         else
         {
            this._recycleSmall.itemBlock.avtSpecific.visible = false;
         }
         this._recycleSmall.bodyTxt.text = "Are you sure you want to recycle this item for " + Utility.convertNumberToString(_loc2_.recycleValue) + " gems?";
         this._recyclePopupSmall.open();
      }
      
      private function sendRecycleRequest(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = int(this._recycleInventory[this._idx].invIdx);
            _loc3_ = this._recycleInventory[this._idx];
            _loc4_ = gMainFrame.userInfo.getMyTradeList();
            this._savedTradeIdx = -1;
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length)
            {
               if(_loc4_[_loc5_].type == this._itemRecycleId && _loc4_[_loc5_].invIdx == _loc2_)
               {
                  this._savedTradeIdx = _loc5_;
                  break;
               }
               _loc5_++;
            }
            if(this._itemRecycleId == RECYCLE_ACCESSORIES || this._itemRecycleId == RECYCLE_ACCESSORIES_LAND_ONLY || this._itemRecycleId == RECYCLE_ACCESSORIES_OCEAN_ONLY)
            {
               ItemXtCommManager.requestItemRecycle(_loc2_,this.confirmRecycle,this.onRecycleListCallback);
            }
            else
            {
               DenXtCommManager.requestRecycle(true,_loc2_,this.confirmRecycle,this.onRecycleListCallback);
            }
         }
      }
      
      private function confirmRecycle(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._tempMC.icon.parent)
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
      
      public function setOnRecycleSuccessCallback(param1:Function) : void
      {
         this._onRecycleSuccessCallback = param1;
      }
      
      private function applyAndClose(param1:Boolean = false) : void
      {
         ItemXtCommManager.recycleIlCallback = null;
         DenXtCommManager.recycleDiCallback = null;
         if(this._closeCallback != null)
         {
            this._closeCallback(param1);
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.applyAndClose(this._hasRecycled);
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._idx = param1.currentTarget.index;
         this._tempMC = this._recycleInventory[this._idx].clone();
         if(this._recycleInventory[this._idx].isMemberOnly)
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
      
      private function onItemRollOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.isAvatarSpecific)
         {
            _loc2_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(param1.currentTarget.defId));
            if(_loc2_ != "-1")
            {
               if(param1.currentTarget.avtSpecificIcon.currentFrameLabel != _loc2_)
               {
                  param1.currentTarget.avtSpecificIcon.gotoAndStop(_loc2_);
               }
               param1.currentTarget.avtSpecificIcon.visible = true;
               param1.currentTarget.avtSpecificHighlight.visible = true;
               return;
            }
         }
         if(param1.currentTarget.cir.currentFrameLabel == "down")
         {
            param1.currentTarget.cir.gotoAndStop("downMouse");
         }
         else if(param1.currentTarget.cir.currentFrameLabel != "downMouse")
         {
            param1.currentTarget.cir.gotoAndStop("over");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onItemRollOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.isAvatarSpecific)
         {
            param1.currentTarget.avtSpecificIcon.visible = false;
            param1.currentTarget.avtSpecificHighlight.visible = false;
            return;
         }
         if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            param1.currentTarget.cir.gotoAndStop("down");
         }
         else if(param1.currentTarget.cir.currentFrameLabel != "down")
         {
            param1.currentTarget.cir.gotoAndStop("up");
         }
      }
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._recyclePopupSmall.close();
         this.sendRecycleRequest(true);
      }
      
      private function onNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._recycleSmall.itemBlock.iconLayer.removeChild(this._tempMC.icon);
         this._recyclePopupSmall.close();
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(RECYCLE_TUT_LIST_ID);
      }
      
      private function onInfoBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,"How To Recycle",param1.currentTarget.x + this._recyclePopup.x,param1.currentTarget.y + this._recyclePopup.y + param1.currentTarget.height);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function addListeners() : void
      {
         if(this._recyclePopup)
         {
            this._recyclePopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         }
         if(this._recyclePopupSmall)
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
         if(this._recyclePopup)
         {
            this._recyclePopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         }
         if(this._recyclePopupSmall)
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

