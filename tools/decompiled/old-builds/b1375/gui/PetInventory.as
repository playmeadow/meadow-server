package gui
{
   import Party.PartyManager;
   import adoptAPet.AdoptAPetManager;
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import game.MinigameManager;
   import gui.itemWindows.ItemWindowPets;
   import gui.jazwares.CheckListPopup;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetDef;
   import pet.PetManager;
   import pet.PetXtCommManager;
   
   public class PetInventory
   {
      
      private static const LOADING_SPIRAL_SMALL:int = 397;
      
      private static const EVT_ICON_ID:int = 44;
      
      private const PET_INVENTORY_MEDIA_ID:int = 993;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      private var _petList:Array;
      
      private var _inventoryMC:MovieClip;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _loadingSpiralBig:LoadingSpiral;
      
      private var _bigPet:GuiPet;
      
      private var _itemWindows:WindowAndScrollbarGenerator;
      
      private var _shop:Shop;
      
      private var _checkListPopup:CheckListPopup;
      
      private var _isRecycling:Boolean;
      
      private var _activePetModified:Boolean;
      
      private var _noCurrentActivePet:Boolean;
      
      private var _idx:int;
      
      private var _currSelectedIdx:int;
      
      private var _initialPetInvId:int;
      
      private var _recycleOneOnly:Boolean;
      
      private var _hasRecycled:Boolean;
      
      private var _previousPetInvId:int;
      
      private var _petIndexBeingDeleted:int;
      
      private var _openCheckListImmediately:Boolean;
      
      public function PetInventory()
      {
         super();
      }
      
      public function init(param1:Function, param2:Boolean = false, param3:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _guiLayer = GuiManager.guiLayer;
         _closeCallback = param1;
         _petList = PetManager.myPetList.concat();
         _idx = -1;
         _currSelectedIdx = -1;
         _recycleOneOnly = param2;
         _openCheckListImmediately = param3;
         _loadingSpiralBig = new LoadingSpiral();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/inventory");
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(993,onMediaItemLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         DarkenManager.unDarken(_inventoryMC);
         _guiLayer.removeChild(_inventoryMC);
         SBTracker.pop();
         onCheckListClose();
         _activePetModified = false;
         _noCurrentActivePet = false;
         _idx = -1;
         _initialPetInvId = -1;
         _currSelectedIdx = -1;
         _isRecycling = false;
         _inventoryMC = null;
         _petList = null;
         if(_bigPet)
         {
            _bigPet.destroy();
            _bigPet = null;
         }
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         if(_closeCallback != null)
         {
            if(_recycleOneOnly)
            {
               _closeCallback(_hasRecycled);
            }
            else
            {
               _closeCallback();
            }
            _closeCallback = null;
         }
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:PetDef = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _inventoryMC = MovieClip(param1.getChildAt(0));
            _inventoryMC.petNameTxt.text = "";
            _inventoryMC.itemCounter.counterTxt.text = "0/" + PetManager.getPetInventoryMax();
            _inventoryMC.bMastery.visible = false;
            _inventoryMC.certBtn.visible = false;
            _inventoryMC.rare.visible = false;
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
            _inventoryMC.helpBubble.visible = false;
            if(AvatarManager.roomEnviroType == 1)
            {
               _inventoryMC.shopBtn.visible = false;
            }
            if(AdoptAPetManager.hasAtLeastOneUsableAdoptAPet)
            {
               _inventoryMC.checklistBtn.visible = true;
               _inventoryMC.newBurst.visible = AdoptAPetManager.hasUnseenPetData;
            }
            else
            {
               _inventoryMC.checklistBtn.visible = false;
               _inventoryMC.newBurst.visible = false;
            }
            _previousPetInvId = PetManager.myActivePetInvId;
            if(_petList && _petList.length > 0)
            {
               if(PetManager.myActivePetInvId != 0)
               {
                  _loc4_ = 0;
                  while(_loc4_ < _petList.length)
                  {
                     if(_petList[_loc4_].idx == PetManager.myActivePetInvId)
                     {
                        _currSelectedIdx = _loc4_;
                        _initialPetInvId = _petList[_loc4_].idx;
                        if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_petList[_loc4_].type))
                        {
                           _loc2_ = _petList[_loc4_];
                           _bigPet = new GuiPet(_loc2_.createdTs,_loc2_.idx,_loc2_.lBits,_loc2_.uBits,_loc2_.eBits,_loc2_.type,_loc2_.name,_loc2_.personalityDefId,_loc2_.favoriteToyDefId,_loc2_.favoriteFoodDefId,onBigPetLoaded);
                           _loc3_ = PetManager.getPetDef(_bigPet.getDefID());
                           _inventoryMC.itemWindowPet.addChild(_bigPet);
                           _inventoryMC.petNameTxt.text = _bigPet.petName;
                           _inventoryMC.butterfly.visible = false;
                           if(_loc2_.masteryCounter >= 100)
                           {
                              _inventoryMC.bMastery.visible = true;
                              _inventoryMC.bMastery.icon.gotoAndStop(PetManager.petNameForDefId(_loc2_.defId) + "1");
                              if((_loc2_.uBits >> 8 & 0x0F) > 0)
                              {
                                 _inventoryMC.bMastery.mouse.visible = false;
                                 _inventoryMC.bMastery.down.visible = true;
                              }
                           }
                           _inventoryMC.certBtn.visible = true;
                           _inventoryMC.rare.visible = _loc3_ && _loc3_.status == 4;
                        }
                        break;
                     }
                     _loc4_++;
                  }
               }
               _inventoryMC.itemCounter.counterTxt.text = _petList.length + "/" + PetManager.getPetInventoryMax();
            }
            DarkenManager.showLoadingSpiral(false);
            _inventoryMC.x = 900 * 0.5;
            _inventoryMC.y = 550 * 0.5;
            _guiLayer.addChild(_inventoryMC);
            DarkenManager.darken(_inventoryMC);
            createItemWindows();
            addEventListeners();
            if(_openCheckListImmediately)
            {
               onChecklistBtn(null);
            }
         }
      }
      
      private function onBigPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _bigPet.scaleX = _bigPet.scaleY = 5;
         _bigPet.y += 83;
      }
      
      private function createItemWindows() : void
      {
         if(_itemWindows)
         {
            _itemWindows.destroy();
            _itemWindows = null;
         }
         while(_inventoryMC.itemWindow.numChildren > 1)
         {
            _inventoryMC.itemWindow.removeChildAt(_inventoryMC.itemWindow.numChildren - 1);
         }
         var _loc1_:int = int(_petList.length);
         var _loc2_:Number = Math.min(PetManager.getPetInventoryMax(),4);
         var _loc3_:int = Math.min(PetManager.getPetInventoryMax(),4);
         _itemWindows = new WindowAndScrollbarGenerator();
         _itemWindows.init(_inventoryMC.itemWindow.width,_inventoryMC.itemWindow.height,4,0,_loc2_,_loc3_,PetManager.getPetInventoryMax(),2,2,1,0.5,ItemWindowPets,_petList,"",0,{
            "mouseDown":winMouseDown,
            "mouseOver":winMouseOver,
            "mouseOut":winMouseOut
         },{"isRecycling":_isRecycling || _recycleOneOnly},null,false,false,false);
         _inventoryMC.itemWindow.addChild(_itemWindows);
         _loadingSpiralBig.visible = false;
      }
      
      private function onConfirmFreePet(param1:Object) : void
      {
         if(param1.status)
         {
            _petIndexBeingDeleted = param1.passback;
            PetXtCommManager.sendPetDismissRequest(_petList[param1.passback].idx,freePetCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function freePetCallback(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            if(param2)
            {
               SBTracker.trackPageview("/game/play/popup/pet/petInventory/free");
               _idx = _idx - 1;
               _currSelectedIdx = _currSelectedIdx - 1;
               _hasRecycled = true;
               if(param3)
               {
                  AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,0,"",0,0,0);
                  _activePetModified = true;
                  while(_inventoryMC.itemWindowPet.numChildren > 0)
                  {
                     _inventoryMC.itemWindowPet.removeChildAt(0);
                  }
                  _inventoryMC.petNameTxt.text = "";
                  _inventoryMC.butterfly.visible = true;
                  _inventoryMC.bMastery.visible = false;
                  _inventoryMC.certBtn.visible = false;
                  _inventoryMC.rare.visible = false;
                  _idx = -1;
                  _currSelectedIdx = -1;
               }
               if(!_recycleOneOnly)
               {
                  _itemWindows.deleteItem(_petIndexBeingDeleted,_petList);
                  _inventoryMC.itemCounter.counterTxt.text = _petList.length + "/" + PetManager.getPetInventoryMax();
                  _noCurrentActivePet = true;
               }
               else
               {
                  destroy();
               }
            }
            else
            {
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14786));
            }
         }
      }
      
      private function onPetSwitch(param1:Boolean = true) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            destroy();
         }
         else
         {
            PetManager.myActivePetInvId = _previousPetInvId;
            reloadPets();
         }
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         var _loc5_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc2_:Object = null;
         var _loc3_:PetDef = null;
         param1.stopPropagation();
         if((_isRecycling || _recycleOneOnly) && param1.currentTarget.cageIcon.visible)
         {
            if(!(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_petList[param1.currentTarget.index].type) && PetManager.myActivePetInvId == _petList[param1.currentTarget.index].idx && !PartyManager.canSwitchPet(true)))
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14787),true,onConfirmFreePet,param1.currentTarget.index);
            }
         }
         else if(param1.currentTarget.newPetIcon.visible)
         {
            PetManager.openPetFinder("",onPetSwitch);
         }
         else
         {
            if(param1.currentTarget.gray.visible)
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup("pets","equipMemberPet");
               }
               return;
            }
            while(_inventoryMC.itemWindowPet.numChildren > 0)
            {
               _inventoryMC.itemWindowPet.removeChildAt(0);
            }
            _idx = param1.currentTarget.index;
            _currSelectedIdx = _idx;
            if((param1.currentTarget.cir.currentFrameLabel == "downMouse" || param1.currentTarget.cir.currentFrameLabel == "down") && PartyManager.canSwitchPet(true))
            {
               param1.currentTarget.cir.gotoAndStop("up");
               if(_initialPetInvId == 0)
               {
                  _idx = -1;
               }
               PetManager.myActivePetInvId = 0;
               GuiManager.resetPetWindowListAndUpdateBtns();
               _activePetModified = false;
               _inventoryMC.petNameTxt.text = "";
               _inventoryMC.butterfly.visible = true;
               _inventoryMC.bMastery.visible = false;
               _inventoryMC.certBtn.visible = false;
               _inventoryMC.rare.visible = false;
               _bigPet.destroy();
               _bigPet = null;
            }
            else
            {
               _activePetModified = true;
               _noCurrentActivePet = false;
               _loc5_ = 0;
               while(_loc5_ < _petList.length)
               {
                  _loc4_ = MovieClip(_itemWindows.bg.getChildAt(_loc5_));
                  _loc4_.cir.gotoAndStop("up");
                  _loc5_++;
               }
               param1.currentTarget.cir.gotoAndStop("downMouse");
               _loc2_ = _petList[_idx];
               _bigPet = new GuiPet(_loc2_.createdTs,_loc2_.idx,_loc2_.lBits,_loc2_.uBits,_loc2_.eBits,_loc2_.type,_loc2_.name,_loc2_.personalityDefId,_loc2_.favoriteToyDefId,_loc2_.favoriteFoodDefId,onBigPetLoaded);
               _loc3_ = PetManager.getPetDef(_bigPet.getDefID());
               _inventoryMC.itemWindowPet.addChild(_bigPet);
               _inventoryMC.petNameTxt.text = _bigPet.petName;
               _inventoryMC.butterfly.visible = false;
               _inventoryMC.certBtn.visible = true;
               _inventoryMC.rare.visible = _loc3_ && _loc3_.status == 4;
               if(_loc2_.masteryCounter >= 100)
               {
                  _inventoryMC.bMastery.visible = true;
                  _inventoryMC.bMastery.icon.gotoAndStop(PetManager.petNameForDefId(_loc2_.defId) + "1");
                  if((_loc2_.uBits >> 8 & 0x0F) > 0)
                  {
                     _inventoryMC.bMastery.mouse.visible = false;
                     _inventoryMC.bMastery.down.visible = true;
                  }
                  else
                  {
                     _inventoryMC.bMastery.mouse.visible = true;
                     _inventoryMC.bMastery.down.visible = false;
                  }
               }
               else
               {
                  _inventoryMC.bMastery.visible = false;
                  _inventoryMC.bMastery.mouse.visible = true;
                  _inventoryMC.bMastery.down.visible = false;
               }
               _previousPetInvId = PetManager.myActivePetInvId;
               if(_initialPetInvId == _loc2_.idx)
               {
                  _idx = -1;
                  PetManager.myActivePetInvId = _initialPetInvId;
               }
               else
               {
                  PetManager.myActivePetInvId = _loc2_.idx;
               }
               GuiManager.resetPetWindowListAndUpdateBtns();
            }
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.hasPet)
         {
            if(param1.currentTarget.numChildren >= 1)
            {
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
         }
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.hasPet)
         {
            if(param1.currentTarget.numChildren >= 1)
            {
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
               {
                  param1.currentTarget.cir.gotoAndStop("down");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "down")
               {
                  param1.currentTarget.cir.gotoAndStop("up");
               }
            }
         }
      }
      
      private function onCageBtn(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = null;
         param1.stopPropagation();
         if(_isRecycling)
         {
            _isRecycling = false;
         }
         else
         {
            _isRecycling = true;
         }
         _itemWindows.callUpdateInWindowWithInput({"isRecycling":_isRecycling});
      }
      
      private function onCageOverBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(14674),0,-30);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onCageOutBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onMasteryBtn(param1:MouseEvent) : void
      {
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         param1.stopPropagation();
         var _loc2_:Object = _petList[_currSelectedIdx];
         if(_loc2_ != null)
         {
            _loc5_ = _loc2_.uBits >> 8 & 0x0F;
            if(_loc5_ > 0)
            {
               _loc5_ = 0;
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            else
            {
               _loc5_ = 1;
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            _loc9_ = int(_loc2_.uBits);
            _loc7_ = _loc9_ & 0x0F;
            _loc8_ = _loc9_ >> 4 & 0x0F;
            _loc6_ = _loc9_ >> 12 & 0x0F;
            _loc4_ = _loc9_ >> 16 & 0x0F;
            _loc3_ = _loc9_ >> 20 & 0x0F;
            _loc9_ = _loc3_ << 20 | _loc4_ << 16 | _loc6_ << 12 | _loc5_ << 8 | _loc8_ << 4 | _loc7_;
            _loc2_.uBits = _loc5_ << 8 | _loc9_;
            _itemWindows.callUpdateOnWindowWithInput(_currSelectedIdx,{"petObject":_loc2_});
            _bigPet.updateAllBits(_loc2_.lBits,_loc2_.uBits,_loc2_.eBits);
            DarkenManager.showLoadingSpiral(true);
            PetXtCommManager.sendPetMasteryRequest(_loc5_,_loc2_.idx);
         }
      }
      
      private function updateActivePet(param1:Boolean = false) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Function = null;
         if(param1)
         {
            _loc3_ = onPetUpdate;
         }
         else
         {
            _loc3_ = onPetSwitch;
         }
         if(_idx > -1)
         {
            if(_petList && _petList.length > 0)
            {
               _loc2_ = _petList[_idx];
               if(_loc2_ != null)
               {
                  if(_activePetModified)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PetXtCommManager.sendPetSwitchRequest(_loc2_.idx,_loc3_);
                     _activePetModified = false;
                     return;
                  }
                  if(PetManager.myActivePetInvId == 0 && MovieClip(_itemWindows.bg.getChildAt(_idx)).cir.currentFrameLabel == "up" && !_noCurrentActivePet)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PetXtCommManager.sendPetSwitchRequest(0,_loc3_);
                     return;
                  }
               }
            }
         }
         if(AvatarManager.playerAvatarWorldView.getActivePet() != null)
         {
            if(_bigPet == null)
            {
               AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,0,"",0,0,0);
            }
            else
            {
               AvatarManager.playerAvatarWorldView.setActivePet(_bigPet.createdTs,_bigPet.getLBits(),_bigPet.getUBits(),_bigPet.getEBits(),_bigPet.petName,_bigPet.personalityDefId,_bigPet.favoriteFoodDefId,_bigPet.favoriteToyDefId);
            }
         }
         if(!param1)
         {
            destroy();
         }
         else
         {
            _loc3_(true);
         }
      }
      
      private function reloadPets() : void
      {
         _petList = PetManager.myPetList.concat();
         while(_inventoryMC.itemWindowPet.numChildren > 0)
         {
            _inventoryMC.itemWindowPet.removeChildAt(0);
         }
         var _loc1_:Object = PetManager.myActivePet;
         if(_bigPet && _loc1_)
         {
            _bigPet = new GuiPet(_loc1_.createdTs,_loc1_.idx,_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.type,_loc1_.name,_loc1_.personalityDefId,_loc1_.favoriteToyDefId,_loc1_.favoriteFoodDefId,onBigPetLoaded);
            _inventoryMC.itemWindowPet.addChild(_bigPet);
            _inventoryMC.petNameTxt.text = _bigPet.petName;
         }
         _inventoryMC.butterfly.visible = false;
         createItemWindows();
         if(_bigPet && AvatarManager.playerAvatarWorldView.getActivePet() != null)
         {
            AvatarManager.playerAvatarWorldView.setActivePet(_bigPet.createdTs,_bigPet.getLBits(),_bigPet.getUBits(),_bigPet.getEBits(),_bigPet.petName,_bigPet.personalityDefId,_bigPet.favoriteFoodDefId,_bigPet.favoriteToyDefId);
         }
      }
      
      private function onPetUpdate(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            _loc2_ = {"typeDefId":52};
            MinigameManager.handleGameClick(_loc2_,null,false,reloadPets);
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         updateActivePet();
      }
      
      private function onShopBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _shop = new Shop();
         if(AvatarManager.roomEnviroType == 1)
         {
            _shop.init(89,1030,AvatarManager.playerAvatar,_guiLayer);
         }
         else
         {
            _shop.init(85,1030,AvatarManager.playerAvatar,_guiLayer);
         }
      }
      
      private function onSalonBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         updateActivePet(true);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onChecklistBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_checkListPopup)
         {
            onCheckListClose();
         }
         _checkListPopup = new CheckListPopup();
         _checkListPopup.init(onCheckListClose);
      }
      
      private function onCheckListClose() : void
      {
         if(_checkListPopup)
         {
            _checkListPopup.destroy();
            _checkListPopup = null;
         }
         _inventoryMC.newBurst.visible = AdoptAPetManager.hasUnseenPetData;
      }
      
      private function onCertBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_bigPet)
         {
            GuiManager.openPetCertificatePopup(_bigPet,null);
         }
      }
      
      private function addEventListeners() : void
      {
         _inventoryMC.addEventListener("mouseDown",onPopup,false,0,true);
         _inventoryMC.bx.addEventListener("mouseDown",onClose,false,0,true);
         _inventoryMC.cageBtn.addEventListener("mouseDown",onCageBtn,false,0,true);
         _inventoryMC.cageBtn.addEventListener("mouseOver",onCageOverBtn,false,0,true);
         _inventoryMC.cageBtn.addEventListener("mouseOut",onCageOutBtn,false,0,true);
         _inventoryMC.bMastery.addEventListener("mouseDown",onMasteryBtn,false,0,true);
         _inventoryMC.shopBtn.addEventListener("mouseDown",onShopBtn,false,0,true);
         _inventoryMC.salonBtn.addEventListener("mouseDown",onSalonBtn,false,0,true);
         _inventoryMC.checklistBtn.addEventListener("mouseDown",onChecklistBtn,false,0,true);
         _inventoryMC.certBtn.addEventListener("mouseDown",onCertBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _inventoryMC.removeEventListener("mouseDown",onPopup);
         _inventoryMC.bx.removeEventListener("mouseDown",onClose);
         _inventoryMC.cageBtn.removeEventListener("mouseDown",onCageBtn);
         _inventoryMC.cageBtn.removeEventListener("mouseOver",onCageOverBtn);
         _inventoryMC.cageBtn.removeEventListener("mouseOut",onCageOutBtn);
         _inventoryMC.bMastery.removeEventListener("mouseDown",onMasteryBtn);
         _inventoryMC.shopBtn.removeEventListener("mouseDown",onShopBtn);
         _inventoryMC.salonBtn.removeEventListener("mouseDown",onSalonBtn);
         _inventoryMC.checklistBtn.removeEventListener("mouseDown",onChecklistBtn);
         _inventoryMC.certBtn.removeEventListener("mouseDown",onCertBtn);
      }
   }
}

