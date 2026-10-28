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
   import localization.LocalizationManager;
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
      
      private var _previousPetInvId:int;
      
      public function PetInventory()
      {
         super();
      }
      
      public function init(initCloseCallback:Function, recycleOneOnly:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = initCloseCallback;
         this._mediaHelpers = [];
         this._petViews = [];
         this._petList = PetManager.myPetList;
         this._idx = -1;
         this._currSelectedIdx = -1;
         this._recycleOneOnly = recycleOneOnly;
         this._loadingSpiralBig = new LoadingSpiral();
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/inventory");
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.PET_INVENTORY_MEDIA_ID,this.onMediaItemLoaded);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         var i:int = 0;
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
         if(Boolean(this._petViews))
         {
            for(i = 0; i < this._petViews.length; i++)
            {
               this._petViews[i].destroy();
            }
         }
         this._petViews = null;
         if(Boolean(this._bigPet))
         {
            this._bigPet.destroy();
            this._bigPet = null;
         }
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
         for(i = 0; i < this._mediaHelpers.length; i++)
         {
            this._mediaHelpers[i].destroy();
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
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         var i:int = 0;
         var myPet:Object = null;
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            this._inventoryMC = MovieClip(img.getChildAt(0));
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
                  for(i = 0; i < this._petList.length; i++)
                  {
                     if(this._petList[i].idx == PetManager.myActivePetInvId)
                     {
                        this._currSelectedIdx = i;
                        this._initialPetInvId = this._petList[i].idx;
                        if(!PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,this._petList[i].type))
                        {
                           break;
                        }
                        myPet = this._petList[i];
                        this._bigPet = new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,this.onBigPetLoaded);
                        this._inventoryMC.itemWindowPet.addChild(this._bigPet);
                        this._inventoryMC.petNameTxt.text = this._bigPet.petName;
                        this._inventoryMC.butterfly.visible = false;
                        if(myPet.masteryCounter >= PetManager.MASTERY_ACHIV_MIN_COUNT)
                        {
                           this._inventoryMC.bMastery.visible = true;
                           this._inventoryMC.bMastery.icon.gotoAndStop(PetManager.petNameForDefId(myPet.defId) + "1");
                           if((myPet.uBits >> 8 & 0x0F) > 0)
                           {
                              this._inventoryMC.bMastery.mouse.visible = false;
                              this._inventoryMC.bMastery.down.visible = true;
                           }
                        }
                        break;
                     }
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
      
      private function onBigPetLoaded(content:MovieClip, guiPet:GuiPet) : void
      {
         this._bigPet.scaleX = this._bigPet.scaleY = 5;
         this._bigPet.y += 83;
      }
      
      private function createGuiPets() : void
      {
         this._petViews = [];
         for(var i:int = 0; i < this._petList.length; i++)
         {
            this._petViews.push(new GuiPet(this._petList[i].idx,this._petList[i].lBits,this._petList[i].uBits,this._petList[i].eBits,this._petList[i].type,this._petList[i].name,null));
         }
      }
      
      private function createItemWindows() : void
      {
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
         while(this._inventoryMC.itemWindow.numChildren > 0)
         {
            this._inventoryMC.itemWindow.removeChildAt(0);
         }
         this.createGuiPets();
         var numItemsInCurrArray:int = int(this._petList.length);
         var xCount:int = Math.min(PetManager.getPetInventoryMax(),4);
         var yCount:int = Math.ceil(xCount / 5);
         this._itemWindows = new WindowGenerator();
         this._itemWindows.init(xCount,yCount,PetManager.getPetInventoryMax(),2,2,1,ItemWindowPets,this._petList,"",{
            "mouseDown":this.winMouseDown,
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut
         },{"isRecycling":this._isRecycling || this._recycleOneOnly},null,false,false);
         this._inventoryMC.itemWindow.addChild(this._itemWindows);
         this._loadingSpiralBig.visible = false;
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(this._itemWindows,344,258,4,"scrollbar2",86);
      }
      
      private function onConfirmFreePet(o:Object) : void
      {
         if(Boolean(o.status))
         {
            PetXtCommManager.sendPetDismissRequest(this._petList[o.passback].idx,this.freePetCallback);
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function freePetCallback(status:Boolean, wasFound:Boolean, wasActivePet:Boolean) : void
      {
         DarkenManager.showLoadingSpiral(false);
         GuiManager.resetPetWindowListInDen();
         if(status)
         {
            if(wasFound)
            {
               SBTracker.trackPageview("/game/play/popup/pet/petInventory/free");
               --this._idx;
               --this._currSelectedIdx;
               this._hasRecycled = true;
               if(wasActivePet)
               {
                  AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,"");
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
               new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14786));
            }
         }
      }
      
      private function onPetSwitch(status:Boolean = true) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(status)
         {
            this.destroy();
         }
         else
         {
            PetManager.myActivePetInvId = this._previousPetInvId;
            this.reloadPets();
         }
      }
      
      private function winMouseDown(evt:MouseEvent) : void
      {
         var i:int = 0;
         var myPet:Object = null;
         var mc:MovieClip = null;
         evt.stopPropagation();
         if((this._isRecycling || this._recycleOneOnly) && Boolean(evt.currentTarget.cageIcon.visible))
         {
            if(!(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,this._petList[evt.currentTarget.index].type) && PetManager.myActivePetInvId == this._petList[evt.currentTarget.index].idx && !PartyManager.canSwitchPet(true)))
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14787),true,this.onConfirmFreePet,evt.currentTarget.index);
            }
         }
         else if(Boolean(evt.currentTarget.newPetIcon.visible))
         {
            PetManager.openPetFinder("",this.onPetSwitch);
         }
         else
         {
            if(Boolean(evt.currentTarget.gray.visible))
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
            this._idx = evt.currentTarget.index;
            this._currSelectedIdx = this._idx;
            if((evt.currentTarget.cir.currentFrameLabel == "downMouse" || evt.currentTarget.cir.currentFrameLabel == "down") && PartyManager.canSwitchPet(true))
            {
               evt.currentTarget.cir.gotoAndStop("up");
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
               for(i = 0; i < this._itemWindows.numWindowsCreated; i++)
               {
                  mc = MovieClip(this._itemWindows.bg.getChildAt(i));
                  mc.cir.gotoAndStop("up");
               }
               evt.currentTarget.cir.gotoAndStop("downMouse");
               myPet = this._petList[this._idx];
               this._bigPet = new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,this.onBigPetLoaded);
               this._inventoryMC.itemWindowPet.addChild(this._bigPet);
               this._inventoryMC.petNameTxt.text = this._bigPet.petName;
               this._inventoryMC.butterfly.visible = false;
               if(myPet.masteryCounter >= PetManager.MASTERY_ACHIV_MIN_COUNT)
               {
                  this._inventoryMC.bMastery.visible = true;
                  this._inventoryMC.bMastery.icon.gotoAndStop(PetManager.petNameForDefId(myPet.defId) + "1");
                  if((myPet.uBits >> 8 & 0x0F) > 0)
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
               this._previousPetInvId = PetManager.myActivePetInvId;
               if(this._initialPetInvId == myPet.idx)
               {
                  this._idx = -1;
                  PetManager.myActivePetInvId = this._initialPetInvId;
               }
               else
               {
                  PetManager.myActivePetInvId = myPet.idx;
               }
               GuiManager.resetPetWindowListInDen();
            }
         }
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.numChildren >= 1)
         {
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
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.numChildren >= 1)
         {
            if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               evt.currentTarget.cir.gotoAndStop("down");
            }
            else if(evt.currentTarget.cir.currentFrameLabel != "down")
            {
               evt.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private function onCageBtn(evt:MouseEvent) : void
      {
         var i:int = 0;
         var mc:MovieClip = null;
         evt.stopPropagation();
         if(this._isRecycling)
         {
            this._isRecycling = false;
            for(i = 0; i < this._itemWindows.numWindowsCreated; i++)
            {
               mc = MovieClip(this._itemWindows.bg.getChildAt(i));
               mc.cageIcon.visible = false;
            }
         }
         else
         {
            this._isRecycling = true;
            for(i = 0; i < this._itemWindows.numWindowsCreated; i++)
            {
               mc = MovieClip(this._itemWindows.bg.getChildAt(i));
               if(Boolean(mc.hasPet))
               {
                  mc.cageIcon.visible = true;
               }
            }
         }
      }
      
      private function onCageOverBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.init(MovieClip(evt.currentTarget),LocalizationManager.translateIdOnly(14674),0,-30);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onCageOutBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onMasteryBtn(evt:MouseEvent) : void
      {
         var cat8:int = 0;
         var uBits:int = 0;
         var cat6:int = 0;
         var cat7:int = 0;
         var cat9:int = 0;
         var cat10:int = 0;
         var cat11:int = 0;
         evt.stopPropagation();
         var myPet:Object = this._petList[this._currSelectedIdx];
         if(myPet != null)
         {
            cat8 = myPet.uBits >> 8 & 0x0F;
            if(cat8 > 0)
            {
               cat8 = 0;
               evt.currentTarget.mouse.visible = true;
               evt.currentTarget.down.visible = false;
            }
            else
            {
               cat8 = 1;
               evt.currentTarget.mouse.visible = false;
               evt.currentTarget.down.visible = true;
            }
            uBits = int(myPet.uBits);
            cat6 = uBits & 0x0F;
            cat7 = uBits >> 4 & 0x0F;
            cat9 = uBits >> 12 & 0x0F;
            cat10 = uBits >> 16 & 0x0F;
            cat11 = uBits >> 20 & 0x0F;
            uBits = cat11 << 20 | cat10 << 16 | cat9 << 12 | cat8 << 8 | cat7 << 4 | cat6;
            myPet.uBits = cat8 << 8 | uBits;
            if(this._petViews[this._currSelectedIdx] != null)
            {
               this._petViews[this._currSelectedIdx].updateUBits(myPet.uBits);
            }
            this._bigPet.updateAllBits(myPet.lBits,myPet.uBits,myPet.eBits);
            DarkenManager.showLoadingSpiral(true);
            PetXtCommManager.sendPetMasteryRequest(cat8,myPet.idx);
         }
      }
      
      private function updateActivePet(updatingBeforeGameJoin:Boolean = false) : void
      {
         var myPet:Object = null;
         var callback:Function = null;
         if(updatingBeforeGameJoin)
         {
            callback = this.onPetUpdate;
         }
         else
         {
            callback = this.onPetSwitch;
         }
         if(this._idx > -1)
         {
            if(Boolean(this._petList) && this._petList.length > 0)
            {
               myPet = this._petList[this._idx];
               if(myPet != null)
               {
                  if(this._activePetModified)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PetXtCommManager.sendPetSwitchRequest(myPet.idx,callback);
                     this._activePetModified = false;
                     return;
                  }
                  if(PetManager.myActivePetInvId == 0 && MovieClip(this._itemWindows.bg.getChildAt(this._idx)).cir.currentFrameLabel == "up" && !this._noCurrentActivePet)
                  {
                     DarkenManager.showLoadingSpiral(true);
                     PetXtCommManager.sendPetSwitchRequest(0,callback);
                     return;
                  }
               }
            }
         }
         if(AvatarManager.playerAvatarWorldView.getActivePet() != null)
         {
            if(this._bigPet == null)
            {
               AvatarManager.playerAvatarWorldView.setActivePet(0,0,0,"");
            }
            else
            {
               AvatarManager.playerAvatarWorldView.setActivePet(this._bigPet.getLBits(),this._bigPet.getUBits(),this._bigPet.getEBits(),this._bigPet.petName);
            }
         }
         if(!updatingBeforeGameJoin)
         {
            this.destroy();
         }
         else
         {
            callback(true);
         }
      }
      
      private function reloadPets() : void
      {
         this._petList = PetManager.myPetList;
         while(this._inventoryMC.itemWindowPet.numChildren > 0)
         {
            this._inventoryMC.itemWindowPet.removeChildAt(0);
         }
         var myPet:Object = PetManager.myActivePet;
         this._bigPet = new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,this.onBigPetLoaded);
         this._inventoryMC.itemWindowPet.addChild(this._bigPet);
         this._inventoryMC.petNameTxt.text = this._bigPet.petName;
         this._inventoryMC.butterfly.visible = false;
         this.createItemWindows();
         if(AvatarManager.playerAvatarWorldView.getActivePet() != null)
         {
            AvatarManager.playerAvatarWorldView.setActivePet(this._bigPet.getLBits(),this._bigPet.getUBits(),this._bigPet.getEBits(),this._bigPet.petName);
         }
      }
      
      private function onPetUpdate(status:Boolean) : void
      {
         var gameObj:Object = null;
         DarkenManager.showLoadingSpiral(false);
         if(status)
         {
            gameObj = {"typeDefId":52};
            MinigameManager.handleGameClick(gameObj,null,false,this.reloadPets);
         }
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.updateActivePet();
      }
      
      private function onShopBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function onSalonBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.updateActivePet(true);
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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

