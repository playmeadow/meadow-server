package gui
{
   import avatar.AvatarManager;
   import com.sbi.popup.SBPopup;
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
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
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
         _recycle = GETDEFINITIONBYNAME("RecyclePopupContent");
         _recycleSmall = GETDEFINITIONBYNAME("RecycleSmlPopupContent");
         _recycleSmall.itemBlock.gift.visible = false;
         _recycleSmall.itemBlock.addBtn.visible = false;
         _recycleSmall.itemBlock.removeBtn.visible = false;
         _recycleSmall.itemBlock.avtSpecificIcon.visible = false;
         _recycleSmall.itemBlock.avtSpecific.visible = false;
         _recycleSmall.itemBlock.avtSpecificHighlight.visible = false;
         _recycleSmall.itemBlock.rareDiamondTag.visible = false;
         _recycleSmall.itemBlock.diamond.visible = false;
         _itemRecycleId = param1;
         _popupLayer = param2;
         _recycleOneItem = param3;
         _isInCurrEnviro = param7;
         _recyclePopup = new SBPopup(param2,GETDEFINITIONBYNAME("RecyclePopupSkin"),_recycle,true,true,false,false,true);
         _recyclePopupSmall = new SBPopup(param2,GETDEFINITIONBYNAME("RecycleSmlPopupSkin"),_recycleSmall,false,true,false,false,true);
         _closeCallback = param4;
         _recyclePopup.x = param5;
         _recyclePopup.y = param6;
         _recyclePopup.bxClosesPopup = false;
         _height = _recycle.itemBlock.height;
         _spirals = [];
         addListeners();
         AJAudio.playItemRecycledSound();
         if(_itemRecycleId == 1 || _itemRecycleId == 3 || _itemRecycleId == 4)
         {
            if(gMainFrame.userInfo.playerUserInfo.denItemsFull.length <= 0)
            {
               DenXtCommManager.requestDenItems(fillInventory);
            }
         }
         fillInventory();
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         removeListeners();
         if(_recyclePopup)
         {
            _recyclePopup.destroy();
            _recyclePopup = null;
         }
         if(_recyclePopupSmall)
         {
            _recyclePopupSmall.destroy();
            _recyclePopupSmall = null;
         }
         if(_itemWindows)
         {
            _scrollValue = _itemWindows.scrollYValue;
            switch(_itemRecycleId)
            {
               case 0:
                  _accessoriesScrollValue = _scrollValue;
                  break;
               case 1:
                  _denScrollValue = _scrollValue;
                  break;
               case 2:
                  _denAudioScrollValue = _scrollValue;
                  break;
               case 3:
                  _denOceanOnlyScrollValue = _scrollValue;
                  break;
               case 4:
                  _denLandOnlyScrollValue = _scrollValue;
                  break;
               case 5:
                  _accessoriesOceanOnlyScrollValue = _scrollValue;
                  break;
               case 6:
                  _accessoriesLandOnlyScrollValue = _scrollValue;
            }
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_spirals && _spirals.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _spirals.length)
            {
               _spirals[_loc1_].destroy();
               _loc1_++;
            }
         }
         _spirals = null;
         _hasRecycled = false;
         _tempMC = null;
         _closeCallback = null;
      }
      
      public function hasBeenInited() : Boolean
      {
         return _recyclePopup != null;
      }
      
      private function fillInventory(param1:Boolean = false) : void
      {
         var _loc2_:Array = null;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(!param1)
         {
            _recycleInventory = [];
            if(_itemRecycleId == 0)
            {
               _recycleInventory = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               _scrollValue = _accessoriesScrollValue;
            }
            else if(_itemRecycleId == 6 || _itemRecycleId == 5)
            {
               _loc2_ = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
               if(_itemRecycleId == 6)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _loc2_.length)
                  {
                     if(_loc2_[_loc4_].enviroType == 0)
                     {
                        _recycleInventory.push(_loc2_[_loc4_]);
                     }
                     _loc4_++;
                  }
                  _scrollValue = _accessoriesLandOnlyScrollValue;
               }
               else
               {
                  _loc4_ = 0;
                  while(_loc4_ < _loc2_.length)
                  {
                     if(_loc2_[_loc4_].enviroType == 1)
                     {
                        _recycleInventory.push(_loc2_[_loc4_]);
                     }
                     _loc4_++;
                  }
                  _scrollValue = _accessoriesOceanOnlyScrollValue;
               }
            }
            else
            {
               _loc2_ = gMainFrame.userInfo.playerUserInfo.denItemsFull;
               if(_itemRecycleId == 4 || _itemRecycleId == 3)
               {
                  if(_isInCurrEnviro)
                  {
                     _loc2_ = Utility.denItemListByEnviroType(_loc2_,AvatarManager.roomEnviroType);
                  }
               }
               _recycleInventory = [];
               _loc4_ = 0;
               while(_loc4_ < _loc2_.length)
               {
                  if(_itemRecycleId == 2)
                  {
                     if(_loc2_[_loc4_].sortId == 4 && _loc2_[_loc4_].itemDefId != 617)
                     {
                        _recycleInventory[_loc3_] = _loc2_[_loc4_].clone();
                        _loc3_++;
                     }
                  }
                  else if(_loc2_[_loc4_].sortId != 4)
                  {
                     if(_itemRecycleId == 1 || _isInCurrEnviro)
                     {
                        _recycleInventory[_loc3_] = _loc2_[_loc4_].clone();
                        _loc3_++;
                     }
                     else if(_itemRecycleId == 4 && _loc2_[_loc4_].enviroType == 0)
                     {
                        _recycleInventory[_loc3_] = _loc2_[_loc4_].clone();
                        _loc3_++;
                     }
                     else if(_loc2_[_loc4_].enviroType == 1)
                     {
                        _recycleInventory[_loc3_] = _loc2_[_loc4_].clone();
                        _loc3_++;
                     }
                  }
                  _loc4_++;
               }
               if(_itemRecycleId == 2)
               {
                  _scrollValue = _denAudioScrollValue;
               }
               else if(_itemRecycleId == 1)
               {
                  _scrollValue = _denScrollValue;
               }
               else if(_itemRecycleId == 4)
               {
                  _scrollValue = _denLandOnlyScrollValue;
               }
               else if(_itemRecycleId == 3)
               {
                  _scrollValue = _denOceanOnlyScrollValue;
               }
            }
         }
         createWindows();
      }
      
      private function createWindows() : void
      {
         if(_itemWindows)
         {
            _scrollValue = _itemWindows.scrollYValue;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         while(_recycle.itemBlock.numChildren > 1)
         {
            _recycle.itemBlock.removeChildAt(_recycle.itemBlock.numChildren - 1);
         }
         _itemWindows = new WindowAndScrollbarGenerator();
         _itemWindows.init(_recycle.itemBlock.width,_recycle.itemBlock.height,4,_scrollValue,3,4,12,2,2,0,ItemWindowOriginal,_recycleInventory,"icon",0,{
            "mouseDown":onItemWindowDown,
            "mouseOver":onItemRollOver,
            "mouseOut":onItemRollOut
         },{"isRecycling":true},null,true,false,false);
         _recycle.itemBlock.addChild(_itemWindows);
      }
      
      private function attemptToRecycleItem(param1:int) : void
      {
         var _loc2_:Object = _recycleInventory[_idx];
         _recycleSmall.itemBlock.iconLayer.addChild(_tempMC.icon);
         _recycleSmall.itemBlock.ocean.visible = _loc2_.isOcean;
         _recycleSmall.itemBlock.avtSpecific.visible = false;
         if(_loc2_.isRareDiamond)
         {
            _recycleSmall.itemBlock.rareDiamondTag.visible = true;
         }
         else
         {
            _recycleSmall.itemBlock.rare.visible = _loc2_.isRare;
            _recycleSmall.itemBlock.diamond.visible = _loc2_.isDiamond;
         }
         LocalizationManager.translateIdAndInsert(_recycleSmall.bodyTxt,11371,Utility.convertNumberToString(_loc2_.recycleValue));
         _recyclePopupSmall.open();
      }
      
      private function sendRecycleRequest(param1:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         var _loc5_:int = 0;
         if(param1)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc4_ = int(_recycleInventory[_idx].invIdx);
            _loc2_ = _recycleInventory[_idx];
            _loc3_ = gMainFrame.userInfo.getMyTradeList();
            _savedTradeIdx = -1;
            _loc5_ = 0;
            while(_loc5_ < _loc3_.length)
            {
               if(_loc3_[_loc5_].type == _itemRecycleId && _loc3_[_loc5_].invIdx == _loc4_)
               {
                  _savedTradeIdx = _loc5_;
                  break;
               }
               _loc5_++;
            }
            if(_itemRecycleId == 0 || _itemRecycleId == 6 || _itemRecycleId == 5)
            {
               ItemXtCommManager.requestItemRecycle(_loc4_,confirmRecycle,onRecycleListCallback);
            }
            else
            {
               DenXtCommManager.requestRecycle(true,_loc4_,confirmRecycle,onRecycleListCallback);
            }
         }
      }
      
      private function confirmRecycle(param1:Boolean) : void
      {
         if(param1)
         {
            if(_tempMC.icon.parent)
            {
               _tempMC.icon.parent.removeChild(_tempMC.icon);
            }
            if(_savedTradeIdx != -1)
            {
               gMainFrame.userInfo.removeFromMyTradeList(_savedTradeIdx);
               if(_itemRecycleId == 0 || _itemRecycleId == 6 || _itemRecycleId == 5)
               {
                  TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
               }
               else if(_itemRecycleId == 1 || _itemRecycleId == 2 || _itemRecycleId == 4 || _itemRecycleId == 3)
               {
                  TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
               }
            }
         }
         _savedTradeIdx = -1;
      }
      
      private function onRecycleListCallback() : void
      {
         DarkenManager.showLoadingSpiral(false);
         _hasRecycled = true;
         if(_onRecycleSuccessCallback != null)
         {
            _onRecycleSuccessCallback();
         }
         if(_recycleOneItem)
         {
            applyAndClose(true);
         }
         else
         {
            _itemWindows.deleteItem(_idx,_recycleInventory);
         }
      }
      
      public function setOnRecycleSuccessCallback(param1:Function) : void
      {
         _onRecycleSuccessCallback = param1;
      }
      
      private function applyAndClose(param1:Boolean = false) : void
      {
         ItemXtCommManager.recycleIlCallback = null;
         DenXtCommManager.recycleDiCallback = null;
         if(_closeCallback != null)
         {
            _closeCallback(param1);
         }
         else
         {
            destroy();
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         applyAndClose(_hasRecycled);
      }
      
      private function onItemWindowDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _idx = param1.currentTarget.index;
         _tempMC = _recycleInventory[_idx].clone();
         if(_recycleInventory[_idx].isMemberOnly)
         {
            if(!gMainFrame.userInfo.isMember)
            {
               _recycleSmall.itemBlock.lockOpen.visible = false;
               _recycleSmall.itemBlock.lock.visible = true;
            }
            else
            {
               _recycleSmall.itemBlock.lockOpen.visible = true;
               _recycleSmall.itemBlock.lock.visible = false;
            }
            _recycleSmall.itemBlock.gray.visible = false;
         }
         else
         {
            _recycleSmall.itemBlock.lock.visible = false;
            _recycleSmall.itemBlock.lockOpen.visible = false;
            _recycleSmall.itemBlock.gray.visible = false;
         }
         if(!_recycleInventory[_idx].isRare)
         {
            _recycleSmall.itemBlock.rare.visible = false;
         }
         attemptToRecycleItem(_recycleInventory[_idx].value);
      }
      
      private function onItemRollOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
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
         _recyclePopupSmall.close();
         sendRecycleRequest(true);
      }
      
      private function onNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _recycleSmall.itemBlock.iconLayer.removeChild(_tempMC.icon);
         _recyclePopupSmall.close();
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(52);
      }
      
      private function onInfoBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14678),param1.currentTarget.x + _recyclePopup.x,param1.currentTarget.y + _recyclePopup.y + param1.currentTarget.height);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function addListeners() : void
      {
         if(_recyclePopup)
         {
            _recyclePopup.skin.s["bx"].addEventListener("mouseDown",onClose,false,0,true);
         }
         if(_recyclePopupSmall)
         {
            _recyclePopupSmall.skin.s["bx"].addEventListener("mouseDown",onNoBtn,false,0,true);
         }
         _recyclePopup.skin.s["infoBtn"].addEventListener("mouseDown",onInfoBtnDown,false,0,true);
         _recyclePopup.skin.s["infoBtn"].addEventListener("mouseOver",onInfoBtnOver,false,0,true);
         _recyclePopup.skin.s["infoBtn"].addEventListener("mouseOut",onInfoBtnOut,false,0,true);
         _recycleSmall.okBtn.addEventListener("mouseDown",onOkBtn,false,0,true);
         _recycleSmall.noBtn.addEventListener("mouseDown",onNoBtn,false,0,true);
      }
      
      private function removeListeners() : void
      {
         if(_recyclePopup)
         {
            _recyclePopup.skin.s["bx"].removeEventListener("mouseDown",onClose);
         }
         if(_recyclePopupSmall)
         {
            _recyclePopupSmall.skin.s["bx"].removeEventListener("mouseDown",onNoBtn);
         }
         _recycleSmall.okBtn.removeEventListener("mouseDown",onOkBtn);
         _recycleSmall.noBtn.removeEventListener("mouseDown",onNoBtn);
         _recyclePopup.skin.s["infoBtn"].removeEventListener("mouseDown",onInfoBtnDown);
         _recyclePopup.skin.s["infoBtn"].addEventListener("mouseOver",onInfoBtnOver);
         _recyclePopup.skin.s["infoBtn"].addEventListener("mouseOut",onInfoBtnOut);
      }
   }
}

