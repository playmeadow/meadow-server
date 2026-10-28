package gui
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import game.MinigameManager;
   import loader.DefPacksDefHelper;
   import loader.MediaHelper;
   import pet.GuiPet;
   import pet.PetManager;
   import pet.PetXtCommManager;
   
   public class PetInventory
   {
      
      private static const LOADING_SPIRAL_SMALL:int = 397;
      
      private static const EVT_ICON_ID:int = 44;
      
      private const PET_INVENTORY_MEDIA_ID:int = 993;
      
      private var _guiLayer:DisplayLayer;
      
      private var _mediaHelpers:Array;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _closeCallback:Function;
      
      private var _petList:Array;
      
      private var _petViews:Array;
      
      private var _loadingSpiralBig:LoadingSpiral;
      
      private var _inventoryMC:MovieClip;
      
      private var _bigPet:GuiPet;
      
      private var _scrollButtons:SBScrollbar;
      
      private var _itemWindows:WindowGenerator;
      
      private var _isRecycling:Boolean;
      
      private var _activePetModified:Boolean;
      
      private var _noCurrentActivePet:Boolean;
      
      private var _idx:int;
      
      private var _currSelectedIdx:int;
      
      private var _initialPetInvId:int;
      
      private var _recycleOneOnly:Boolean;
      
      private var _hasRecycled:Boolean;
      
      private var _shop:Shop;
      
      public function PetInventory()
      {
         super();
      }
      
      public function init(param1:Function, param2:Boolean = false) : void
      {
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = param1;
         this._mediaHelpers = [];
         this._petViews = [];
         this._petList = PetManager.myPetList;
         this._idx = -1;
         this._currSelectedIdx = -1;
         this._recycleOneOnly = param2;
         this._loadingSpiralBig = new LoadingSpiral();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/inventory");
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.PET_INVENTORY_MEDIA_ID,this.onMediaItemLoaded);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         this.removeEventListeners();
         DarkenManager.unDarken(this._inventoryMC);
         this._guiLayer.removeChild(this._inventoryMC);
         SBTracker.pop();
         this._activePetModified = false;
         this._noCurrentActivePet = false;
         this._idx = -1;
         this._initialPetInvId = -1;
         this._currSelectedIdx = -1;
         this._isRecycling = false;
         this._inventoryMC = null;
         this._petList = null;
         if(this._petViews)
         {
            _loc1_ = 0;
            while(_loc1_ < this._petViews.length)
            {
               this._petViews[_loc1_].destroy();
               _loc1_++;
            }
         }
         this._petViews = null;
         if(this._bigPet)
         {
            this._bigPet.destroy();
            this._bigPet = null;
         }
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
         _loc1_ = 0;
         while(_loc1_ < this._mediaHelpers.length)
         {
            this._mediaHelpers[_loc1_].destroy();
            _loc1_++;
         }
         this._mediaHelpers.splice();
         if(this._closeCallback != null)
         {
            if(this._recycleOneOnly)
            {
               this._closeCallback(this._hasRecycled);
            }
            else
            {
               this._closeCallback();
            }
            this._closeCallback = null;
         }
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(param1)
         {
            this._inventoryMC = MovieClip(param1.getChildAt(0));
            this._inventoryMC.petNameTxt.text = "";
            this._inventoryMC.itemCounter.counterTxt.text = "0/" + PetManager.getPetInventoryMax();
            this._inventoryMC.bMastery.visible = false;
            this._inventoryMC.helpBubble.visible = false;
            if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
            {
               this._inventoryMC.shopBtn.visible = false;
            }
            if(Boolean(this._petList) && this._petList.length > 0)
            {
               if(PetManager.myActivePetInvId != 0)
               {
                  _loc2_ = 0;
                  while(_loc2_ < this._petList.length)
                  {
                     if(this._petList[_loc2_].idx == PetManager.myActivePetInvId)
                     {
                        this._currSelectedIdx = _loc2_;
                        this._initialPetInvId = this._petList[_loc2_].idx;
                        if(PetManager.getEnviroTypeByPetType(this._petList[_loc2_].type) != AvatarManager.roomEnviroType)
                        {
                           break;
                        }
                        _loc3_ = this._petList[_loc2_];
                        this._bigPet = new GuiPet(_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,this.onBigPetLoaded);
                        this._inventoryMC.itemWindowPet.addChild(this._bigPet);
                        this._inventoryMC.petNameTxt.text = this._bigPet.petName;
                        this._inventoryMC.butterfly.visible = false;
                        if(_loc3_.masteryCounter >= PetManager.MASTERY_ACHIV_MIN_COUNT)
                        {
                           this._inventoryMC.bMastery.visible = true;
                           this._inventoryMC.bMastery.icon.gotoAndStop(PetManager.petNameForDefId(_loc3_.defId) + "1");
                           if((_loc3_.uBits >> 8 & 0x0F) > 0)
                           {
                              this._inventoryMC.bMastery.mouse.visible = false;
                              this._inventoryMC.bMastery.down.visible = true;
                           }
                        }
                        break;
                     }
                     _loc2_++;
                  }
               }
               this._inventoryMC.itemCounter.counterTxt.text = this._petList.length + "/" + PetManager.getPetInventoryMax();
            }
            DarkenManager.showLoadingSpiral(false);
            this._inventoryMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._inventoryMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._guiLayer.addChild(this._inventoryMC);
            DarkenManager.darken(this._inventoryMC);
            this.createItemWindows();
            this.addEventListeners();
         }
      }
      
      private function onBigPetLoaded(param1:MovieClip) : void
      {
         this._bigPet.scaleX = this._bigPet.scaleY = 5;
         this._bigPet.y += 83;
      }
      
      private function createGuiPets() : void
      {
         this._petViews = [];
         var _loc1_:int = 0;
         while(_loc1_ < this._petList.length)
         {
            this._petViews.push(new GuiPet(this._petList[_loc1_].idx,this._petList[_loc1_].lBits,this._petList[_loc1_].uBits,this._petList[_loc1_].eBits,this._petList[_loc1_].type,this._petList[_loc1_].name,null));
            _loc1_++;
         }
      }
      
      private function createItemWindows() : void
      {
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
         while(this._inventoryMC.itemWindow.numChildren > 0)
         {
            this._inventoryMC.itemWindow.removeChildAt(0);
         }
         this.createGuiPets();
         var _loc1_:int = int(this._petList.length);
         var _loc2_:int = Math.min(PetManager.getPetInventoryMax(),4);
         var _loc3_:int = Math.ceil(_loc2_ / 5);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(_loc2_,_loc3_,PetManager.getPetInventoryMax(),2,2,1,ItemWindowPets,this._petList,"",{
            "mouseDown":this.winMouseDown,
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut
         },{"isRecycling":this._isRecycling || this._recycleOneOnly},null,false,false);
         this._inventoryMC.itemWindow.addChild(this._itemWindows);
         this._loadingSpiralBig.visible = false;
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._itemWindows,344,258,4,"scrollbar2",86);
      }
      
      private function onConfirmFreePet(param1:Object) : void
      {
         if(param1.status)
         {
            PetXtCommManager.sendPetDismissRequest(this._petList[param1.passback].idx,this.freePetCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function freePetCallback(param1:Boolean, param2:Boolean, param3:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         GuiManager.resetPetWindowListInDen();
         if(param1)
         {
            if(param2)
            {
               SBTracker.trackPageview("/game/play/popup/pet/petInventory/free");
               --this._idx;
               --this._currSelectedIdx;
               this._hasRecycled = true;
               if(param3)
               {
                  AvatarManager.playerAvatarWorldView.setActivePet(0,0,0);
                  this._activePetModified = true;
                  while(this._inventoryMC.itemWindowPet.numChildren > 0)
                  {
                     this._inventoryMC.itemWindowPet.removeChildAt(0);
                  }
                  this._inventoryMC.petNameTxt.text = "";
                  this._inventoryMC.butterfly.visible = true;
                  this._idx = -1;
                  this._currSelectedIdx = -1;
               }
               if(!this._recycleOneOnly)
               {
                  this._petList = PetManager.myPetList;
                  this._inventoryMC.itemCounter.counterTxt.text = this._petList.length + "/" + PetManager.getPetInventoryMax();
                  this._isRecycling = false;
                  this._noCurrentActivePet = true;
                  this.createItemWindows();
               }
               else
               {
                  this.destroy();
               }
            }
            else
            {
               new SBOkPopup(GuiManager.guiLayer,"You can\'t free your pet right now! Try again!");
            }
         }
      }
      
      private function onPetSwitch() : void
      {
         DarkenManager.showLoadingSpiral(false);
         this.destroy();
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         var _loc4_:MovieClip = null;
         param1.stopPropagation();
         if((this._isRecycling || this._recycleOneOnly) && Boolean(param1.currentTarget.cageIcon.visible))
         {
            if(!(PetManager.getEnviroTypeByPetType(this._petList[param1.currentTarget.index].type) == AvatarManager.roomEnviroType && PetManager.myActivePetInvId == this._petList[param1.currentTarget.index].idx && !PartyManager.canSwitchPet(true)))
            {
               new SBYesNoPopup(this._guiLayer,"Are you sure you want to free this pet?",true,this.onConfirmFreePet,param1.currentTarget.index);
            }
         }
         else if(param1.currentTarget.newPetIcon.visible)
         {
            PetManager.openPetFinder("",this.onPetSwitch);
         }
         else
         {
            if(param1.currentTarget.gray.visible)
            {
               if(!gMainFrame.userInfo.isMember)
               {
                  UpsellManager.displayPopup(UpsellManager.PETS,"equipMemberPet");
               }
               return;
            }
            while(this._inventoryMC.itemWindowPet.numChildren > 0)
            {
               this._inventoryMC.itemWindowPet.removeChildAt(0);
            }
            this._idx = param1.currentTarget.index;
            this._currSelectedIdx = this._idx;
            if((param1.currentTarget.cir.currentFrameLabel == "downMouse" || param1.currentTarget.cir.currentFrameLabel == "down") && PartyManager.canSwitchPet(true))
            {
               param1.currentTarget.cir.gotoAndStop("up");
               if(this._initialPetInvId == 0)
               {
                  this._idx = -1;
               }
               PetManager.myActivePetInvId = 0;
               GuiManager.resetPetWindowListInDen();
               this._activePetModified = false;
               this._inventoryMC.petNameTxt.text = "";
               this._inventoryMC.butterfly.visible = true;
               this._inventoryMC.bMastery.visible = false;
               this._bigPet.destroy();
               this._bigPet = null;
            }
            else
            {
               this._activePetModified = true;
               this._noCurrentActivePet = false;
               _loc2_ = 0;
               while(_loc2_ < this._itemWindows.numWindowsCreated)
               {
                  _loc4_ = MovieClip(this._itemWindows.bg.getChildAt(_loc2_));
                  _loc4_.cir.gotoAndStop("up");
                  _loc2_++;
               }
               param1.currentTarget.cir.gotoAndStop("downMouse");
               _loc3_ = this._petList[this._idx];
               this._bigPet = new GuiPet(_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,this.onBigPetLoaded);
               this._inventoryMC.itemWindowPet.addChild(this._bigPet);
               this._inventoryMC.petNameTxt.text = this._bigPet.petName;
               this._inventoryMC.butterfly.visible = false;
               if(_loc3_.masteryCounter >= PetManager.MASTERY_ACHIV_MIN_COUNT)
               {
                  this._inventoryMC.bMastery.visible = true;
                  this._inventoryMC.bMastery.icon.gotoAndStop(PetManager.petNameForDefId(_loc3_.defId) + "1");
                  if((_loc3_.uBits >> 8 & 0x0F) > 0)
                  {
                     this._inventoryMC.bMastery.mouse.visible = false;
                     this._inventoryMC.bMastery.down.visible = true;
                  }
                  else
                  {
                     this._inventoryMC.bMastery.mouse.visible = true;
                     this._inventoryMC.bMastery.down.visible = false;
                  }
               }
               else
               {
                  this._inventoryMC.bMastery.visible = false;
                  this._inventoryMC.bMastery.mouse.visible = true;
                  this._inventoryMC.bMastery.down.visible = false;
               }
               if(this._initialPetInvId == _loc3_.idx)
               {
                  this._idx = -1;
                  PetManager.myActivePetInvId = this._initialPetInvId;
               }
               else
               {
                  PetManager.myActivePetInvId = _loc3_.idx;
               }
               GuiManager.resetPetWindowListInDen();
            }
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function onCageBtn(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MovieClip = null;
         param1.stopPropagation();
         if(this._isRecycling)
         {
            this._isRecycling = false;
            _loc2_ = 0;
            while(_loc2_ < this._itemWindows.numWindowsCreated)
            {
               _loc3_ = MovieClip(this._itemWindows.bg.getChildAt(_loc2_));
               _loc3_.cageIcon.visible = false;
               _loc2_++;
            }
         }
         else
         {
            this._isRecycling = true;
            _loc2_ = 0;
            while(_loc2_ < this._itemWindows.numWindowsCreated)
            {
               _loc3_ = MovieClip(this._itemWindows.bg.getChildAt(_loc2_));
               _loc3_.cageIcon.visible = true;
               _loc2_++;
            }
         }
      }
      
      private function onCageOverBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),"Free Your Pet",0,-30);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onCageOutBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onMasteryBtn(param1:MouseEvent) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         param1.stopPropagation();
         var _loc2_:Object = this._petList[this._currSelectedIdx];
         if(_loc2_ != null)
         {
            _loc3_ = _loc2_.uBits >> 8 & 0x0F;
            if(_loc3_ > 0)
            {
               _loc3_ = 0;
               param1.currentTarget.mouse.visible = true;
               param1.currentTarget.down.visible = false;
            }
            else
            {
               _loc3_ = 1;
               param1.currentTarget.mouse.visible = false;
               param1.currentTarget.down.visible = true;
            }
            _loc4_ = int(_loc2_.uBits);
            _loc5_ = _loc4_ & 0x0F;
            _loc6_ = _loc4_ >> 4 & 0x0F;
            _loc7_ = _loc4_ >> 12 & 0x0F;
            _loc8_ = _loc4_ >> 16 & 0x0F;
            _loc9_ = _loc4_ >> 20 & 0x0F;
            _loc4_ = _loc9_ << 20 | _loc8_ << 16 | _loc7_ << 12 | _loc3_ << 8 | _loc6_ << 4 | _loc5_;
            _loc2_.uBits = _loc3_ << 8 | _loc4_;
            if(this._petViews[this._currSelectedIdx] != null)
            {
               this._petViews[this._currSelectedIdx].updateUBits(_loc2_.uBits);
            }
            this._bigPet.updateAllBits(_loc2_.lBits,_loc2_.uBits,_loc2_.eBits);
            DarkenManager.showLoadingSpiral(true);
            PetXtCommManager.sendPetMasteryRequest(_loc3_,_loc2_.idx);
         }
      }
      
      private function updateActivePet(param1:Boolean = false) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Function = null;
         if(param1)
         {
            _loc2_ = this.onPetUpdate;
         }
         else
         {
            _loc2_ = this.onPetSwitch;
         }
         if(this._idx > -1)
         {
            if(Boolean(this._petList) && this._petList.length > 0)
            {
               _loc3_ = this._petList[this._idx];
               if(_loc3_ != null)
               {
                  if(this._activePetModified)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PetXtCommManager.sendPetSwitchRequest(_loc3_.idx,_loc2_);
                     this._activePetModified = false;
                     return;
                  }
                  if(PetManager.myActivePetInvId == 0 && MovieClip(this._itemWindows.bg.getChildAt(this._idx)).cir.currentFrameLabel == "up" && !this._noCurrentActivePet)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PetXtCommManager.sendPetSwitchRequest(0,_loc2_);
                     return;
                  }
               }
            }
         }
         if(AvatarManager.playerAvatarWorldView.getActivePet() != null)
         {
            if(this._bigPet == null)
            {
               AvatarManager.playerAvatarWorldView.setActivePet(0,0,0);
            }
            else
            {
               AvatarManager.playerAvatarWorldView.setActivePet(this._bigPet.getLBits(),this._bigPet.getUBits(),this._bigPet.getEBits());
            }
         }
         if(!param1)
         {
            this.destroy();
         }
         else
         {
            _loc2_();
         }
      }
      
      private function reloadPets() : void
      {
         this._petList = PetManager.myPetList;
         while(this._inventoryMC.itemWindowPet.numChildren > 0)
         {
            this._inventoryMC.itemWindowPet.removeChildAt(0);
         }
         var _loc1_:Object = PetManager.myActivePet;
         this._bigPet = new GuiPet(_loc1_.idx,_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.type,_loc1_.name,this.onBigPetLoaded);
         this._inventoryMC.itemWindowPet.addChild(this._bigPet);
         this._inventoryMC.petNameTxt.text = this._bigPet.petName;
         this._inventoryMC.butterfly.visible = false;
         this.createItemWindows();
         if(AvatarManager.playerAvatarWorldView.getActivePet() != null)
         {
            AvatarManager.playerAvatarWorldView.setActivePet(this._bigPet.getLBits(),this._bigPet.getUBits(),this._bigPet.getEBits());
         }
      }
      
      private function onPetUpdate() : void
      {
         DarkenManager.showLoadingSpiral(false);
         var _loc1_:Object = {"typeDefId":52};
         MinigameManager.handleGameClick(_loc1_,null,false,this.reloadPets);
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.updateActivePet();
      }
      
      private function onShopBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._shop = new Shop();
         if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            this._shop.init(GenericListXtCommManager.DEN_ITEM_PET_OCEAN,DefPacksDefHelper.DEF_DEN_ITEM,AvatarManager.playerAvatar,this._guiLayer);
         }
         else
         {
            this._shop.init(GenericListXtCommManager.DEN_ITEM_PET_LAND,DefPacksDefHelper.DEF_DEN_ITEM,AvatarManager.playerAvatar,this._guiLayer);
         }
      }
      
      private function onSalonBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.updateActivePet(true);
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addEventListeners() : void
      {
         this._inventoryMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._inventoryMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._inventoryMC.cageBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCageBtn,false,0,true);
         this._inventoryMC.cageBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onCageOverBtn,false,0,true);
         this._inventoryMC.cageBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onCageOutBtn,false,0,true);
         this._inventoryMC.bMastery.addEventListener(MouseEvent.MOUSE_DOWN,this.onMasteryBtn,false,0,true);
         this._inventoryMC.shopBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onShopBtn,false,0,true);
         this._inventoryMC.salonBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSalonBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._inventoryMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._inventoryMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._inventoryMC.cageBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCageBtn);
         this._inventoryMC.cageBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onCageOverBtn);
         this._inventoryMC.cageBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onCageOutBtn);
         this._inventoryMC.bMastery.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMasteryBtn);
         this._inventoryMC.shopBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onShopBtn);
         this._inventoryMC.salonBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSalonBtn);
      }
   }
}

