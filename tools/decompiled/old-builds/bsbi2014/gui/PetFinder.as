package gui
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBStayLeavePopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetBase;
   import pet.PetManager;
   import pet.PetXtCommManager;
   
   public class PetFinder
   {
      
      private static const PET_FINDER_MEDIA_ID:int = 1207;
      
      private static const PET_NAMES_1:int = 205;
      
      private static const PET_NAMES_2:int = 206;
      
      private static const LOADING_SPIRAL_SMALL:int = 397;
      
      private static const CT_WIDTH:int = 230;
      
      private static const CT_HEIGHT:int = 124;
      
      private static const CT_NUM_COLS:int = 5;
      
      private static const CT_NUM_ROWS:int = 4;
      
      private static const CT_Y_TOP:int = -135;
      
      private static const CT_Y_BOT:int = 30;
      
      private static const CT_X:int = -115;
      
      private static const CT_ID_TOP:int = 0;
      
      private static const CT_ID_BOT:int = 1;
      
      private static const COLOR_TAB_ID:int = 0;
      
      private static const TRAITS_TAB_ID:int = 1;
      
      private static const EYE_TAB_ID:int = 2;
      
      private var _guiLayer:DisplayLayer;
      
      private var _petInventory:PetInventory;
      
      private var _mediaHelpers:Array;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _petMC:MovieClip;
      
      private var _petPreview:MovieClip;
      
      private var _petSettings:MovieClip;
      
      private var _petToBeCreated:GuiPet;
      
      private var _closeCallback:Function;
      
      private var _petDefId:int;
      
      private var _gemCount:int;
      
      private var _findCount:int;
      
      private var _nameScroller1:GuiCarousel;
      
      private var _nameScroller2:GuiCarousel;
      
      private var _colorTableColor1:ColorTable;
      
      private var _colorTableColor2:ColorTable;
      
      private var _colors1:Array;
      
      private var _colors2:Array;
      
      private var _eyes:Array;
      
      private var _att1:Array;
      
      private var _att2:Array;
      
      private var _att3:Array;
      
      private var _catArray:Array;
      
      private var _catIndexArray:Array;
      
      private var _petData:Array;
      
      private var _currColor1Index:int;
      
      private var _currColor2Index:int;
      
      private var _currEyeIndex:int;
      
      private var _currAtt1Index:int;
      
      private var _currAtt2Index:int;
      
      private var _currAtt3Index:int;
      
      private var _numberIconsLoaded:int;
      
      private var _savedPets:Array;
      
      private var _numPetsLoaded:int;
      
      private var _hoverGlow:GlowFilter;
      
      private var _downGlow:GlowFilter;
      
      private var _chosenIndex:int;
      
      private var _isUsingSelectionMode:Boolean;
      
      private var _isFromRedemption:Boolean;
      
      private var _currencyType:int;
      
      private var _specialDef:Object;
      
      private var _shopId:int;
      
      private var _petNames:Array;
      
      public function PetFinder()
      {
         super();
      }
      
      public static function createRandomPet(petDefId:int) : Array
      {
         var cat1:int = Math.random() * 19;
         var cat2:int = Math.random() * 19;
         var cat3:int = 0;
         var cat4:int = Math.random() * 5;
         var cat5:int = Math.random() * 3;
         var cat6:int = Math.random() * 3;
         var cat7:int = Math.random() * 3;
         var cat8:int = 0;
         return [petDefId,cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8,0,0,0,0,0,0];
      }
      
      public static function packPetBits(cats:Array) : Array
      {
         var lBits:uint = uint(cats[5] << 28 | cats[4] << 24 | cats[3] << 19 | cats[2] << 14 | cats[1] << 8 | cats[0]);
         var uBits:uint = uint(cats[11] << 20 | cats[10] << 16 | cats[9] << 12 | cats[8] << 8 | cats[7] << 4 | cats[6]);
         var eBits:uint = 0;
         return [lBits,uBits,eBits];
      }
      
      public function init(petDefId:int = -1, closeCallback:Function = null, isFromRedemption:Boolean = false, petData:Array = null, currencyType:int = 0, specialDef:Object = null, shopId:int = 0) : void
      {
         DarkenManager.showLoadingSpiral(true);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/petFinder");
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = closeCallback;
         this._petDefId = petDefId;
         this._isFromRedemption = isFromRedemption;
         this._isUsingSelectionMode = petDefId == -1;
         this._petData = petData;
         this._currencyType = currencyType;
         this._specialDef = specialDef;
         this._shopId = shopId;
         this._mediaHelpers = [];
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(PET_FINDER_MEDIA_ID,this.onMediaItemLoaded);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         var petSelect:MovieClip = null;
         var o:Object = null;
         var j:int = 0;
         var child:Object = null;
         var currPet:GuiPet = null;
         this.removeEventListeners();
         if(Boolean(this._petMC))
         {
            DarkenManager.unDarken(this._petMC);
         }
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         this._nameScroller1 = null;
         this._nameScroller2 = null;
         if(Boolean(this._petMC))
         {
            petSelect = this._petMC.petSelect;
            for(i = 0; i < petSelect.numChildren; i++)
            {
               o = petSelect.getChildAt(i);
               if(Boolean(o) && o.hasOwnProperty("numChildren"))
               {
                  for(j = 0; j < o.numChildren; j++)
                  {
                     child = o.getChildAt(j);
                     if(Boolean(child) && child.hasOwnProperty("destroy"))
                     {
                        child.destroy();
                        child = null;
                     }
                  }
                  o = null;
               }
            }
         }
         if(Boolean(this._petToBeCreated))
         {
            this._petToBeCreated.destroy();
            this._petToBeCreated = null;
         }
         if(this._isUsingSelectionMode)
         {
            if(Boolean(this._savedPets))
            {
               for(i = 0; i < this._savedPets.length; i++)
               {
                  currPet = this._savedPets[i];
                  currPet.removeEventListener(MouseEvent.MOUSE_OVER,this.onPetMouseOver);
                  currPet.removeEventListener(MouseEvent.MOUSE_OUT,this.onPetMouseOut);
                  currPet.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPetDown);
                  currPet.destroy();
               }
               this._savedPets = null;
               this._hoverGlow = null;
               this._downGlow = null;
            }
         }
         if(Boolean(this._petInventory))
         {
            this._petInventory.destroy();
         }
         if(Boolean(this._petMC) && Boolean(this._petMC.parent) && this._petMC.parent == this._guiLayer)
         {
            this._guiLayer.removeChild(this._petMC);
            this._petMC = null;
         }
         for(i = 0; i < this._mediaHelpers.length; i++)
         {
            this._mediaHelpers[i].destroy();
            delete this._mediaHelpers[i];
         }
         this._mediaHelpers = [];
         this._numberIconsLoaded = 0;
         this._findCount = 0;
         if(this._closeCallback != null)
         {
            this._closeCallback();
            this._closeCallback = null;
         }
         SBTracker.flush(true);
      }
      
      private function setupPetSelect() : void
      {
         var child:Object = null;
         var matchedIndex:int = 0;
         var petDefId:int = 0;
         var petDef:Object = null;
         var petBits:Array = null;
         var currPet:GuiPet = null;
         this._petPreview.visible = false;
         this._petSettings.visible = false;
         this._petMC.petNamer.visible = false;
         this._petMC.backBtn.visible = false;
         this._petMC.nextBtn.activateGrayState(true);
         this._savedPets = [];
         this._hoverGlow = new GlowFilter(16777215,1,16,16,3);
         this._downGlow = new GlowFilter(14276889,1,16,16,7);
         if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            this._petMC.petSelect.gotoAndStop("ocean");
         }
         var petSelect:MovieClip = this._petMC.petSelect;
         for(var i:int = 0; i < petSelect.numChildren; i++)
         {
            child = petSelect.getChildAt(i);
            matchedIndex = int(child.name.indexOf("Pet"));
            if(matchedIndex > 0)
            {
               petDefId = PetManager.petDefIdForName(child.name.substr(0,matchedIndex));
               petDef = PetManager.getPetDef(petDefId);
               if(PetManager.isPetAvailable(petDefId) && PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,petDef.type))
               {
                  petBits = packPetBits(createRandomPet(petDefId));
                  currPet = PetManager.getGuiPet(this._savedPets.length,petBits[0],petBits[1],petBits[2],petDef.type,"?",this.onPetLoadedOnSelection);
                  child.addChild(currPet);
                  this._savedPets.push(currPet);
               }
               else
               {
                  child.visible = false;
               }
            }
         }
      }
      
      private function setupPetFinder(currGuiPet:GuiPet = null, useCurrPet:Boolean = false) : void
      {
         var petDef:Object = null;
         var petBits:Array = null;
         if(!useCurrPet)
         {
            this._petMC.petSelect.visible = false;
            petDef = PetManager.getPetDef(this._petDefId);
            if(this._isFromRedemption)
            {
               this._petPreview.tag.visible = false;
            }
            else
            {
               this._petPreview.tag.visible = true;
               this._petPreview.tag.txt.text = Boolean(this._specialDef) ? this._specialDef.value : petDef.cost;
               if(this._currencyType == Item.GEM_CURRENCY)
               {
                  this._gemCount = gMainFrame.clientInfo.gemCount;
                  if(this._gemCount < (Boolean(this._specialDef) ? this._specialDef.value : petDef.cost))
                  {
                     this._petPreview.tag.gotoAndStop("red");
                     this._petPreview.tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._petPreview.tag.gotoAndStop("green");
                  }
               }
               else if(this._currencyType == Item.TICKET_CURRENCY)
               {
                  this._gemCount = gMainFrame.clientInfo.ticketCount;
                  if(this._gemCount < (Boolean(this._specialDef) ? this._specialDef.value : petDef.cost))
                  {
                     this._petPreview.tag.gotoAndStop("ticketRed");
                     this._petPreview.tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._petPreview.tag.gotoAndStop("ticketGreen");
                  }
               }
               else if(this._currencyType == Item.ORB_CURRENCY)
               {
                  this._gemCount = gMainFrame.clientInfo.orbCount;
                  if(this._gemCount < (Boolean(this._specialDef) ? this._specialDef.value : petDef.cost))
                  {
                     this._petPreview.tag.gotoAndStop("orbRed");
                     this._petPreview.tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._petPreview.tag.gotoAndStop("orbGreen");
                  }
               }
               else if(this._currencyType == Item.DIAMOND_CURRENCY)
               {
                  this._gemCount = gMainFrame.clientInfo.diamondCount;
                  if(this._gemCount < (Boolean(this._specialDef) ? this._specialDef.value : petDef.cost))
                  {
                     this._petPreview.tag.gotoAndStop("diamondRed");
                     this._petPreview.tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._petPreview.tag.gotoAndStop("diamondGreen");
                  }
               }
            }
            if(Boolean(gMainFrame.userInfo.isMember) || !petDef.isMember)
            {
               this._petPreview.lock.visible = false;
            }
            if(!currGuiPet)
            {
               if(Boolean(this._petData))
               {
                  petBits = this._petData;
                  this._catArray = this.unpackPetBits(this._petData[0],this._petData[1],this._petData[2]);
               }
               else
               {
                  this._catArray = createRandomPet(this._petDefId);
                  petBits = packPetBits(this._catArray);
               }
               this._petToBeCreated = PetManager.getGuiPet(0,petBits[0],petBits[1],petBits[2],petDef.type,"?",this.onPetLoadedOnStage);
               this.addEventListeners();
            }
            else
            {
               this._catArray = this.unpackPetBits(currGuiPet.getLBits(),currGuiPet.getUBits(),currGuiPet.getEBits());
               this._petToBeCreated = PetManager.getGuiPet(0,currGuiPet.getLBits(),currGuiPet.getUBits(),currGuiPet.getEBits(),petDef.type,"?",this.onPetLoadedOnStage);
            }
            while(this._petPreview.itemWindow.numChildren > 0)
            {
               this._petPreview.itemWindow.removeChildAt(0);
            }
            this._petPreview.itemWindow.addChild(this._petToBeCreated);
            if(petDef.type == PetBase.TYPE_LAND_GROUND || petDef.type == PetBase.TYPE_LAND_AIR || petDef.type == PetBase.TYPE_AMPHIB_AIR || petDef.type == PetBase.TYPE_AMPHIB_GROUND)
            {
               this._petPreview.charBox.gotoAndStop(1);
            }
            else
            {
               this._petPreview.charBox.gotoAndStop(2);
            }
            if(petDef.status != PetManager.LIMITED_TIME)
            {
               this._petPreview.limitedTime.visible = false;
            }
         }
         this._petSettings.eyesTabUp.visible = false;
         this._petSettings.traitsTabUp.visible = false;
         this._petMC.petNamer.visible = false;
         if(!this._isUsingSelectionMode)
         {
            this._petMC.backBtn.visible = false;
         }
      }
      
      private function onCreateResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/petFinder/keep");
         GuiManager.resetPetWindowListInDen();
         this.destroy();
      }
      
      private function setupColorTables() : void
      {
         var colorArray:Array = new Array(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
         var colors1:Array = [];
         var colors2:Array = [];
         var colorsLengthTotal:int = Math.max(this._colors1.length,this._colors2.length);
         for(var i:int = 0; i < colorsLengthTotal; i++)
         {
            if(i < this._colors1.length)
            {
               colors1[i] = (this._colors1[i][0] << 16) + (this._colors1[i][1] << 8) + this._colors1[i][2];
            }
            if(i < this._colors2.length)
            {
               colors2[i] = (this._colors2[i][0] << 16) + (this._colors2[i][1] << 8) + this._colors2[i][2];
            }
         }
         this._colorTableColor1 = new ColorTable();
         this._colorTableColor1.init(CT_ID_TOP,CT_WIDTH,CT_HEIGHT,CT_NUM_COLS,CT_NUM_ROWS,colors1,colorArray,this._currColor1Index,this.onColorChanged);
         this._colorTableColor2 = new ColorTable();
         this._colorTableColor2.init(CT_ID_BOT,CT_WIDTH,CT_HEIGHT,CT_NUM_COLS,CT_NUM_ROWS,colors2,colorArray,this._currColor2Index,this.onColorChanged);
         this._petSettings.colorTableBlock.colors.addChild(this._colorTableColor1);
         this._petSettings.colorTableBlock.colors.addChild(this._colorTableColor2);
         this._colorTableColor1.x = CT_X;
         this._colorTableColor1.y = CT_Y_TOP;
         this._colorTableColor2.x = CT_X;
         this._colorTableColor2.y = CT_Y_BOT;
      }
      
      private function onPetFinderDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onLeverDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._petMC.petNamer.visible))
         {
            if(this._petMC.petNamer.nameLever.currentFrameLabel == "_up")
            {
               this._nameScroller2.soundsEnabled = false;
               AJAudio.playRandomLever();
               this._petMC.petNamer.nameLever.gotoAndPlay("_play");
               this._nameScroller1.pickRandomItem();
               this._nameScroller2.pickRandomItem();
               this._nameScroller2.soundsEnabled = true;
            }
         }
      }
      
      private function onCloseDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         new SBStayLeavePopup(this._guiLayer,LocalizationManager.translateIdOnly(14780),true,this.confirmCloseCallback);
      }
      
      private function confirmCloseCallback(o:Object) : void
      {
         if(Boolean(o.status))
         {
            this.destroy();
         }
      }
      
      private function onNextBtn(evt:MouseEvent = null) : void
      {
         var currDefId:int = 0;
         var useAlreadyCreatedPet:Boolean = false;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(!this._petMC.nextBtn.isGray)
         {
            if(Boolean(this._petMC.petSelect.visible))
            {
               this._petPreview.visible = true;
               this._petSettings.visible = true;
               currDefId = int(this._savedPets[this._chosenIndex].getDefID());
               if(this._petDefId != currDefId)
               {
                  this._petDefId = currDefId;
               }
               else
               {
                  useAlreadyCreatedPet = true;
               }
               this._petMC.petSelect.visible = false;
               this._petMC.backBtn.visible = true;
               this.setupPetFinder(this._savedPets[this._chosenIndex],useAlreadyCreatedPet);
               this.openTab(COLOR_TAB_ID);
            }
            else
            {
               this._petSettings.visible = false;
               this._petMC.petNamer.visible = true;
               this._petMC.nextBtn.visible = false;
               this._petMC.backBtn.visible = true;
            }
         }
      }
      
      private function onBackBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._petMC.petNamer.visible))
         {
            this._petSettings.visible = true;
            this._petSettings.colorTableBlock.visible = true;
            this._petSettings.colorsTabUp.visible = true;
            this._petSettings.eyesTabUp.visible = false;
            this._petSettings.traitsTabUp.visible = false;
            this._petSettings.colorsDownBtn.visible = true;
            this._petSettings.eyesDownBtn.visible = true;
            this._petSettings.traitsDownBtn.visible = true;
            this._petMC.petNamer.visible = false;
            this._petMC.nextBtn.visible = true;
            if(!this._isUsingSelectionMode)
            {
               this._petMC.backBtn.visible = false;
            }
            this.openTab(COLOR_TAB_ID);
         }
         else
         {
            this._petPreview.visible = false;
            this._petSettings.visible = false;
            this._petMC.petSelect.visible = true;
            this._petMC.backBtn.visible = false;
         }
      }
      
      private function onAdoptPetBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._isFromRedemption)
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14781),true,this.onAdoptYesBtn);
            return;
         }
         var currPetDef:Object = PetManager.getPetDef(this._petDefId);
         var currCost:int = Boolean(this._specialDef) ? int(this._specialDef.value) : int(currPetDef.cost);
         if(!gMainFrame.userInfo.isMember && Boolean(currPetDef.isMember))
         {
            UpsellManager.displayPopup(UpsellManager.PETS,"buyMemberPet");
         }
         else if(Boolean(this._specialDef) && PetManager.isPetAvailable(this._petDefId))
         {
            if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,currPetDef.type))
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14782,currPetDef.title.toLowerCase(),currPetDef.cost),true,this.onBuyInDiamondShopConfirm,currPetDef.cost);
            }
            else
            {
               new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(15813),true,this.onOkLandPet);
            }
         }
         else if(this._gemCount < currCost)
         {
            if(Boolean(this._specialDef))
            {
               UpsellManager.displayPopup(UpsellManager.EXTRA_DIAMONDS_AS_MEMBER,"extraDiamonds");
            }
            else
            {
               DarkenManager.darken(this._petMC.oopsCostPopup);
               if(this._currencyType == Item.GEM_CURRENCY)
               {
                  this._petMC.oopsCostPopup.currency.gotoAndStop("gems");
               }
               else if(this._currencyType == Item.TICKET_CURRENCY)
               {
                  this._petMC.oopsCostPopup.currency.gotoAndStop("tickets");
               }
               else if(this._currencyType == Item.ORB_CURRENCY)
               {
                  this._petMC.oopsCostPopup.currency.gotoAndStop("orbs");
               }
               else if(this._currencyType == Item.DIAMOND_CURRENCY)
               {
                  this._petMC.oopsCostPopup.currency.gotoAndStop("diamonds");
               }
               this._petMC.oopsCostPopup.gemsTxt.text = this._gemCount;
               this._petMC.oopsCostPopup.costTxt.text = currCost;
               this._petMC.oopsCostPopup.needTxt.text = currCost - this._gemCount;
               this._petMC.oopsCostPopup.visible = true;
            }
         }
         else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14783),true,this.confirmRecycle);
         }
         else if(Boolean(this._specialDef))
         {
            GuiManager.showDiamondConfirmation(currCost,this.onAdoptYesBtn);
         }
         else
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(Boolean(this._specialDef) ? 14784 : 14785,Utility.convertNumberToString(currCost)),true,this.onAdoptYesBtn);
         }
      }
      
      private function confirmRecycle(o:Object) : void
      {
         if(Boolean(o.status))
         {
            DarkenManager.showLoadingSpiral(true);
            this._petInventory = new PetInventory();
            this._petInventory.init(this.onPetInventoryClose,true);
         }
      }
      
      private function onPetInventoryClose(hasRecycled:Boolean) : void
      {
         this._petInventory = null;
         if(hasRecycled)
         {
            if(Boolean(this._specialDef))
            {
               GuiManager.showDiamondConfirmation(this._specialDef.value,this.onAdoptYesBtn);
            }
            else
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14785,Utility.convertNumberToString(PetManager.getPetDef(this._petDefId).cost)),true,this.onAdoptYesBtn);
            }
         }
      }
      
      private function onOkLandPet(evt:MouseEvent) : void
      {
         SBOkPopup.destroyInParentChain(evt.target.parent);
         this.destroy();
      }
      
      private function onBuyInDiamondShopConfirm(o:Object) : void
      {
         if(Boolean(o.status))
         {
            this._currencyType = Item.GEM_CURRENCY;
            this._gemCount = gMainFrame.clientInfo.gemCount;
            this._specialDef = null;
            if(this._gemCount < o.passback)
            {
               DarkenManager.darken(this._petMC.oopsCostPopup);
               this._petMC.oopsCostPopup.currency.gotoAndStop("gems");
               this._petMC.oopsCostPopup.gemsTxt.text = this._gemCount;
               this._petMC.oopsCostPopup.costTxt.text = o.passback;
               this._petMC.oopsCostPopup.needTxt.text = o.passback - this._gemCount;
               this._petMC.oopsCostPopup.visible = true;
            }
            else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14783),true,this.confirmRecycle);
            }
            else
            {
               this.onAdoptYesBtn(o);
            }
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onAdoptYesBtn(o:Object = null) : void
      {
         var petBits:Array = null;
         var firstLocId:int = 0;
         var secondLocId:int = 0;
         if(o == null || Boolean(o.status))
         {
            DarkenManager.showLoadingSpiral(true);
            petBits = packPetBits(this._catArray);
            firstLocId = LocalizationManager.isCurrLanguageReversed() ? int(this._petNames[1].locIds[this._nameScroller2.contentItemIndex]) : int(this._petNames[0].locIds[this._nameScroller1.contentItemIndex]);
            secondLocId = LocalizationManager.isCurrLanguageReversed() ? int(this._petNames[0].locIds[this._nameScroller1.contentItemIndex]) : int(this._petNames[1].locIds[this._nameScroller2.contentItemIndex]);
            if(Boolean(this._specialDef))
            {
               PetXtCommManager.sendPetShopBuyRequest(this._shopId,this._specialDef.defId,petBits[0],petBits[1],petBits[2],firstLocId,secondLocId,this.onCreateResponse,this._isFromRedemption);
            }
            else
            {
               PetXtCommManager.sendPetCreateRequest(petBits[0],petBits[1],petBits[2],firstLocId,secondLocId,this.onCreateResponse,this._isFromRedemption);
            }
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/pet/petFinder/didNotKeep",-1,SBTracker.TYPE_EVENT);
         }
      }
      
      private function onCostPopupClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         DarkenManager.unDarken(this._petMC.oopsCostPopup);
         this._petMC.oopsCostPopup.visible = false;
      }
      
      private function onColorsEyesTraitsDownBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.name == this._petSettings.colorsDownBtn.name)
         {
            this.openTab(COLOR_TAB_ID);
         }
         else if(evt.currentTarget.name == this._petSettings.traitsDownBtn.name)
         {
            this.openTab(TRAITS_TAB_ID);
         }
         else if(evt.currentTarget.name == this._petSettings.eyesDownBtn.name)
         {
            this.openTab(EYE_TAB_ID);
         }
      }
      
      public function openTab(tabId:int) : void
      {
         if(tabId == COLOR_TAB_ID)
         {
            this.openColorTableColorsTab();
         }
         else if(tabId == TRAITS_TAB_ID)
         {
            this.openTraitsOrEyesTab(true);
         }
         else if(tabId == EYE_TAB_ID)
         {
            this.openTraitsOrEyesTab(false);
         }
         else
         {
            DebugUtility.debugTrace("Error PetFinder on openTab: Invalid tabId: " + tabId);
         }
      }
      
      private function openColorTableColorsTab() : void
      {
         this._petSettings.traitsTabUp.visible = false;
         this._petSettings.eyesTabUp.visible = false;
         this._petSettings.colorsTabUp.visible = true;
         this._petSettings.colorTableBlock.colors.visible = true;
         this._petSettings.colorTableBlock.eyes.visible = false;
         this._petSettings.colorTableBlock.traits.visible = false;
      }
      
      private function openTraitsOrEyesTab(isTrait:Boolean) : void
      {
         var currWindow:MovieClip = null;
         var i:int = 0;
         var currAttArray:Array = null;
         if(isTrait)
         {
            this._petSettings.colorsTabUp.visible = false;
            this._petSettings.eyesTabUp.visible = false;
            this._petSettings.traitsTabUp.visible = true;
            this._petSettings.colorTableBlock.colors.visible = false;
            this._petSettings.colorTableBlock.eyes.visible = false;
            this._petSettings.colorTableBlock.traits.visible = true;
            for(i = 1; i < 4; i++)
            {
               currWindow = this._petSettings.colorTableBlock.traits["win" + i];
               while(currWindow.iconLayer.numChildren > 0)
               {
                  currWindow.iconLayer.removeChildAt(0);
               }
               currWindow.ocean.visible = false;
               currWindow.removeBtn.visible = false;
               currWindow.lockOpen.visible = false;
               currWindow.gift.visible = false;
               currWindow.lock.visible = false;
               currWindow.addBtn.visible = false;
               currWindow.gray.visible = false;
               this._petSettings.colorTableBlock.traits["traits" + i + "Txt"].text = "";
               currAttArray = this["_att" + i];
               if(Boolean(currAttArray) && currAttArray.length > 0)
               {
                  LocalizationManager.translateId(this._petSettings.colorTableBlock.traits["traits" + i + "Txt"],currAttArray[0]);
                  if(currAttArray.length > this["_currAtt" + i + "Index"])
                  {
                     this._petToBeCreated.colorMyItem(this["_att" + i][1],currAttArray[this["_currAtt" + i + "Index"]],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                     currWindow.iconLayer.addChild(currAttArray[this["_currAtt" + i + "Index"]]);
                     this._petSettings.colorTableBlock.traits["lBtn" + i].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     this._petSettings.colorTableBlock.traits["rBtn" + i].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     this._petSettings.colorTableBlock.traits["rBtn" + i].index = i;
                     this._petSettings.colorTableBlock.traits["lBtn" + i].index = i;
                  }
               }
            }
         }
         else
         {
            this._petSettings.colorsTabUp.visible = false;
            this._petSettings.eyesTabUp.visible = true;
            this._petSettings.traitsTabUp.visible = false;
            this._petSettings.colorTableBlock.colors.visible = false;
            this._petSettings.colorTableBlock.traits.visible = false;
            this._petSettings.colorTableBlock.eyes.visible = true;
            for(i = 1; i < 7; i++)
            {
               currWindow = this._petSettings.colorTableBlock.eyes["win" + i];
               while(currWindow.iconLayer.numChildren > 0)
               {
                  currWindow.iconLayer.removeChildAt(0);
               }
               currWindow.ocean.visible = false;
               currWindow.removeBtn.visible = false;
               currWindow.lockOpen.visible = false;
               currWindow.gift.visible = false;
               currWindow.lock.visible = false;
               currWindow.addBtn.visible = false;
               currWindow.gray.visible = false;
               if(Boolean(this._eyes) && this._eyes.length > 0)
               {
                  if(this._eyes.length > i + 1)
                  {
                     this._petToBeCreated.colorMyItem(this._eyes[1],this._eyes[i + 1],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                     currWindow.iconLayer.addChild(this._eyes[i + 1]);
                     if(!currWindow.hasEventListener(MouseEvent.MOUSE_DOWN))
                     {
                        currWindow.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     }
                     if(!currWindow.hasEventListener(MouseEvent.ROLL_OVER))
                     {
                        currWindow.addEventListener(MouseEvent.ROLL_OVER,this.winMouseOver,false,0,true);
                     }
                     if(!currWindow.hasEventListener(MouseEvent.ROLL_OUT))
                     {
                        currWindow.addEventListener(MouseEvent.ROLL_OUT,this.winMouseOut,false,0,true);
                     }
                     currWindow.index = i;
                     if(this._currEyeIndex == i + 1)
                     {
                        currWindow.cir.gotoAndStop("down");
                     }
                     else
                     {
                        currWindow.cir.gotoAndStop("up");
                     }
                  }
                  else
                  {
                     currWindow.gray.visible = true;
                  }
               }
            }
         }
      }
      
      private function onPetMouseOver(evt:MouseEvent) : void
      {
         if(evt.currentTarget.filters.length == 0)
         {
            evt.currentTarget.filters = [this._hoverGlow];
         }
      }
      
      private function onPetMouseOut(evt:MouseEvent) : void
      {
         if(evt.currentTarget.filters[0].strength != this._downGlow.strength)
         {
            evt.currentTarget.filters = [];
         }
      }
      
      private function onPetDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._savedPets[this._chosenIndex].filters = [];
         evt.currentTarget.filters = [this._downGlow];
         this._chosenIndex = evt.currentTarget.idx;
         this._petMC.nextBtn.activateGrayState(false);
      }
      
      private function onPetLoadedOnSelection(content:MovieClip, pet:GuiPet) : void
      {
         var currPet:GuiPet = null;
         var glow:GlowFilter = null;
         var i:int = 0;
         ++this._numPetsLoaded;
         if(this._numPetsLoaded >= this._savedPets.length)
         {
            for(i = 0; i < this._savedPets.length; i++)
            {
               currPet = this._savedPets[i];
               currPet.scaleX = 2;
               currPet.scaleY = 2;
               currPet.addEventListener(MouseEvent.MOUSE_OVER,this.onPetMouseOver,false,0,true);
               currPet.addEventListener(MouseEvent.MOUSE_OUT,this.onPetMouseOut,false,0,true);
               currPet.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetDown,false,0,true);
            }
            this.addEventListeners();
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._petMC);
            DarkenManager.darken(this._petMC);
         }
      }
      
      private function onPetLoadedOnStage(content:MovieClip, pet:GuiPet) : void
      {
         var glow:GlowFilter = null;
         var mc:MovieClip = this._petToBeCreated.getContent();
         this._colors1 = mc.getCol1();
         this._colors2 = mc.getCol2();
         this._eyes = mc.getEyes();
         this._att1 = mc.getAtt1();
         this._att2 = mc.getAtt2();
         this._att3 = mc.getAtt3();
         var i:int = 2;
         for(i = 2; i < this._eyes.length; i++)
         {
            glow = new GlowFilter(0,1,2,2,2);
            this._eyes[i].filters = [glow];
         }
         for(i = 2; i < this._att1.length; i++)
         {
            glow = new GlowFilter(0,1,2,2,2);
            this._att1[i].filters = [glow];
         }
         for(i = 2; i < this._att2.length; i++)
         {
            glow = new GlowFilter(0,1,2,2,2);
            this._att2[i].filters = [glow];
         }
         for(i = 2; i < this._att3.length; i++)
         {
            glow = new GlowFilter(0,1,2,2,2);
            this._att3[i].filters = [glow];
         }
         this._catIndexArray = [];
         var lowerBits:int = int(this._petToBeCreated.getLBits());
         var upperBits:int = int(this._petToBeCreated.getUBits());
         var cat1:int = lowerBits >> 8 & 0x3F;
         this._catIndexArray[1] = cat1;
         var cat2:int = lowerBits >> 14 & 0x1F;
         this._catIndexArray[2] = cat2;
         var cat3:int = lowerBits >> 19 & 0x1F;
         this._catIndexArray[3] = cat3;
         var cat4:int = (lowerBits >> 24 & 0x0F) + 2;
         this._catIndexArray[4] = cat4;
         var cat5:int = (lowerBits >> 28 & 0x0F) + 2;
         this._catIndexArray[5] = cat5;
         var cat6:int = (upperBits & 0x0F) + 2;
         this._catIndexArray[6] = cat6;
         var cat7:int = (upperBits >> 4 & 0x0F) + 2;
         this._catIndexArray[7] = cat7;
         var cat8:int = (upperBits >> 8 & 0x0F) + 2;
         this._catIndexArray[8] = cat8;
         this._currColor1Index = cat1;
         this._currColor2Index = cat2;
         this._currEyeIndex = this._eyes.length - 1 < this._catIndexArray[this._eyes[1]] ? int(this._eyes.length - 1) : int(this._catIndexArray[this._eyes[1]]);
         this._currAtt1Index = this._att1.length - 1 < this._catIndexArray[this._att1[1]] ? int(this._att1.length - 1) : int(this._catIndexArray[this._att1[1]]);
         this._currAtt2Index = this._att2.length - 1 < this._catIndexArray[this._att2[1]] ? int(this._att2.length - 1) : int(this._catIndexArray[this._att2[1]]);
         this._currAtt3Index = this._att3.length - 1 < this._catIndexArray[this._att3[1]] ? int(this._att3.length - 1) : int(this._catIndexArray[this._att3[1]]);
         this.setupColorTables();
         this._petToBeCreated.scaleX = 5;
         this._petToBeCreated.scaleY = 5;
         if(!this._isUsingSelectionMode)
         {
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._petMC);
            DarkenManager.darken(this._petMC);
         }
      }
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this._petMC = MovieClip(img.getChildAt(0));
            this._petMC.oopsCostPopup.visible = false;
            this._petMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._petMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._petPreview = this._petMC.petPreview;
            this._petSettings = this._petMC.petSettings;
            this._petNames = [-1,-1];
            GenericListXtCommManager.requestGenericList(PET_NAMES_1,this.onNamesLoaded);
            GenericListXtCommManager.requestGenericList(PET_NAMES_2,this.onNamesLoaded);
            if(this._petDefId == -1)
            {
               this.setupPetSelect();
            }
            else
            {
               this.setupPetFinder();
            }
            this._petMC.bx.visible = !this._isFromRedemption;
         }
      }
      
      private function onNamesLoaded(glId:int, locIds:Array) : void
      {
         var split:Array = null;
         var currName:String = null;
         var currIndex:int = 0;
         var i:int = 0;
         var tempArray:Object = [];
         var index:int = -1;
         switch(glId)
         {
            case PET_NAMES_1:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  tempArray = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  index = 1;
               }
               else
               {
                  tempArray = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  index = 0;
               }
               break;
            case PET_NAMES_2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  tempArray = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  index = 0;
               }
               else
               {
                  tempArray = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  index = 1;
               }
         }
         if(index != -1)
         {
            for(i = 0; i < locIds.length; i++)
            {
               if(index == 0)
               {
                  split = LocalizationManager.translateIdOnly(locIds[i]).split("$");
                  currName = split[0];
                  currIndex = Utility.findIndexToInsert(tempArray.names,currName);
                  tempArray.names.splice(currIndex,0,currName);
                  if(Boolean(split[1]))
                  {
                     tempArray.types.splice(currIndex,0,split[1]);
                  }
                  else
                  {
                     tempArray.types.splice(currIndex,0,"m");
                  }
               }
               else if(index == 1)
               {
                  split = LocalizationManager.translateIdOnly(locIds[i]).split("$");
                  currName = split[0].toLowerCase();
                  currIndex = Utility.findIndexToInsert(tempArray.names,currName);
                  tempArray.names.splice(currIndex,0,currName);
                  if(Boolean(split[1]))
                  {
                     tempArray.femNames.splice(currIndex,0,split[1].toLowerCase());
                  }
                  else
                  {
                     tempArray.femNames.splice(currIndex,0,currName);
                  }
               }
               tempArray.locIds.splice(currIndex,0,locIds[i]);
            }
            this._petNames[index] = tempArray;
         }
         if(this._petNames[0] != -1 && this._petNames[1] != -1)
         {
            this.setupPetNames(this._petNames[0].names,this._petNames[1].names);
         }
      }
      
      private function setupPetNames(names1:Array, names2:Array) : void
      {
         this._nameScroller1 = new GuiCarousel(this._petMC.petNamer.nameScroller1);
         this._nameScroller1.init(names1,this.name1Changed);
         this._nameScroller2 = new GuiCarousel(this._petMC.petNamer.nameScroller2);
         this._nameScroller2.init(names2,this.name2Changed);
         this.randomizeNames();
         this._petMC.petNamer.nameLever.visible = true;
      }
      
      private function randomizeNames() : void
      {
         this._nameScroller1.soundsEnabled = false;
         this._nameScroller2.soundsEnabled = false;
         this._nameScroller1.pickRandomItem(true);
         this._nameScroller2.pickRandomItem(true);
         this._nameScroller1.soundsEnabled = true;
         this._nameScroller2.soundsEnabled = true;
      }
      
      private function randZeroOrOne() : int
      {
         return Math.random() < 0.5 ? 0 : 1;
      }
      
      private function name1Changed() : void
      {
         if(Boolean(this._nameScroller1 && this._nameScroller2) && Boolean(this._nameScroller1.selectedContentItem) && Boolean(this._nameScroller2.selectedContentItem))
         {
            this._petMC.petNamer.aml_name_txt.text = this._nameScroller1.selectedContentItem + this._nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(this._petMC.petNamer.aml_name_txt,this._petMC.petNamer.aml_name_txt.text);
            if(this._petNames[0].types[this._nameScroller1.contentItemIndex] == "m")
            {
               if(this._nameScroller2.contentItems != this._petNames[1].names)
               {
                  this._nameScroller2.contentItems = this._petNames[1].names;
               }
            }
            else if(this._nameScroller2.contentItems != this._petNames[1].femNames && Boolean(this._petNames[1].femNames[0]))
            {
               this._nameScroller2.contentItems = this._petNames[1].femNames;
            }
            if(this._nameScroller2.soundsEnabled)
            {
               this._nameScroller2.soundsEnabled = false;
               this._nameScroller2.spinToIndex(this._nameScroller2.contentItemIndex,true);
               this._nameScroller2.soundsEnabled = true;
            }
            else
            {
               this._nameScroller2.spinToIndex(this._nameScroller2.contentItemIndex,true);
            }
         }
         if(Boolean(this._nameScroller1) && !this._nameScroller1.soundsEnabled)
         {
            this._nameScroller1.soundsEnabled = true;
         }
      }
      
      private function name2Changed() : void
      {
         if(Boolean(this._nameScroller1 && this._nameScroller2) && Boolean(this._nameScroller1.selectedContentItem) && Boolean(this._nameScroller2.selectedContentItem))
         {
            this._petMC.petNamer.aml_name_txt.text = this._nameScroller1.selectedContentItem + this._nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(this._petMC.petNamer.aml_name_txt,this._petMC.petNamer.aml_name_txt.text);
         }
         if(Boolean(this._nameScroller2) && !this._nameScroller2.soundsEnabled)
         {
            this._nameScroller2.soundsEnabled = true;
         }
      }
      
      private function onColorChanged(tableId:int, newColorIndex:int) : void
      {
         if(tableId == CT_ID_TOP)
         {
            this._currColor1Index = newColorIndex;
            this._catIndexArray[1] = this._currColor1Index;
            this._catArray[1] = this._currColor1Index;
         }
         else
         {
            this._currColor2Index = newColorIndex;
            this._catIndexArray[2] = this._currColor2Index;
            this._catArray[2] = this._currColor2Index;
         }
         var petBits:Array = packPetBits(this._catArray);
         this._petToBeCreated.updateAllBits(petBits[0],petBits[1],petBits[2]);
      }
      
      private function onColorEyesTraitsDown(evt:MouseEvent) : void
      {
         var currWindow:MovieClip = null;
         var petBits:Array = null;
         var currAttArray:Array = null;
         var increment:int = 0;
         var currAttIndex:int = 0;
         evt.stopPropagation();
         if(evt.currentTarget.name == this._petSettings.colorTableBlock.eyes["win" + evt.currentTarget.index].name)
         {
            this._petSettings.colorTableBlock.eyes["win" + (this._currEyeIndex - 1)].cir.gotoAndStop("up");
            this._currEyeIndex = evt.currentTarget.index + 1;
            evt.currentTarget.cir.gotoAndStop("down");
            AJAudio.playSubMenuBtnClick();
            this._catIndexArray[this._eyes[1]] = this._currEyeIndex;
            this._catArray[this._eyes[1]] = this._currEyeIndex - 2;
            this._petToBeCreated.colorMyItem(this._eyes[1],this._eyes[this._currEyeIndex],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
            petBits = packPetBits(this._catArray);
            this._petToBeCreated.updateAllBits(petBits[0],petBits[1],petBits[2]);
         }
         else if(evt.currentTarget.index < 4)
         {
            increment = 0;
            if(evt.currentTarget.name == this._petSettings.colorTableBlock.traits["lBtn" + evt.currentTarget.index].name)
            {
               increment--;
            }
            else if(evt.currentTarget.name == this._petSettings.colorTableBlock.traits["rBtn" + evt.currentTarget.index].name)
            {
               increment++;
            }
            if(increment != 0)
            {
               currAttArray = this["_att" + evt.currentTarget.index];
               currWindow = evt.currentTarget.parent["win" + evt.currentTarget.index];
               if(currWindow.iconLayer.numChildren > 0)
               {
                  currWindow.iconLayer.removeChildAt(0);
               }
               if(Boolean(currAttArray) && currAttArray.length > 0)
               {
                  currAttIndex = int(this["_currAtt" + evt.currentTarget.index + "Index"]);
                  if(increment > 0)
                  {
                     if(currAttArray.length > currAttIndex + increment)
                     {
                        currAttIndex += increment;
                        currWindow.iconLayer.addChild(currAttArray[currAttIndex]);
                     }
                     else
                     {
                        currAttIndex = 2;
                        currWindow.iconLayer.addChild(currAttArray[2]);
                     }
                  }
                  else if(currAttIndex + increment < 2)
                  {
                     currAttIndex = currAttArray.length - 1;
                     currWindow.iconLayer.addChild(currAttArray[currAttArray.length - 1]);
                  }
                  else
                  {
                     currAttIndex += increment;
                     currWindow.iconLayer.addChild(currAttArray[currAttIndex]);
                  }
                  this._catIndexArray[currAttArray[1]] = currAttIndex;
                  this._petToBeCreated.colorMyItem(currAttArray[1],currAttArray[currAttIndex],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                  this._catArray[currAttArray[1]] = currAttIndex - 2;
                  petBits = packPetBits(this._catArray);
                  this._petToBeCreated.updateAllBits(petBits[0],petBits[1],petBits[2]);
                  this["_currAtt" + evt.currentTarget.index + "Index"] = currAttIndex;
               }
            }
         }
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            evt.currentTarget.cir.gotoAndStop("down");
         }
         else if(evt.currentTarget.cir.currentFrameLabel == "over")
         {
            evt.currentTarget.cir.gotoAndStop("up");
         }
      }
      
      private function addEventListeners() : void
      {
         this._petMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetFinderDown,false,0,true);
         this._petMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseDown,false,0,true);
         this._petMC.petNamer.adoptPetBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetBtn,false,0,true);
         this._petMC.petNamer.nameLever.addEventListener(MouseEvent.MOUSE_DOWN,this.onLeverDown,false,0,true);
         this._petMC.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn,false,0,true);
         this._petMC.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn,false,0,true);
         this._petMC.oopsCostPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose,false,0,true);
         this._petSettings.eyesDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn,false,0,true);
         this._petSettings.traitsDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn,false,0,true);
         this._petSettings.colorsDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         if(Boolean(this._petMC))
         {
            this._petMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPetFinderDown);
            this._petMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseDown);
            this._petMC.petNamer.adoptPetBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetBtn);
            this._petMC.petNamer.nameLever.removeEventListener(MouseEvent.MOUSE_DOWN,this.onLeverDown);
            this._petMC.backBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn);
            this._petMC.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn);
            this._petMC.oopsCostPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose);
         }
         if(Boolean(this._petSettings))
         {
            this._petSettings.eyesDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
            this._petSettings.traitsDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
            this._petSettings.colorsDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
         }
      }
      
      private function unpackPetBits(lBits:uint, uBits:uint, eBits:uint) : Array
      {
         var defId:int = lBits & 0xFF;
         var cat1:int = lBits >> 8 & 0x3F;
         var cat2:int = lBits >> 14 & 0x1F;
         var cat3:int = lBits >> 19 & 0x1F;
         var cat4:int = lBits >> 24 & 0x0F;
         var cat5:int = lBits >> 28 & 0x0F;
         var cat6:int = uBits & 0x0F;
         var cat7:int = uBits >> 4 & 0x0F;
         var cat8:int = uBits >> 8 & 0x0F;
         var cat9:int = uBits >> 12 & 0x0F;
         var cat10:int = uBits >> 16 & 0x0F;
         var cat11:int = uBits >> 20 & 0x0F;
         var cat9Secondary:int = eBits & 0x0F;
         var cat10Secondary:int = eBits >> 4 & 0x0F;
         var cat11Secondary:int = eBits >> 8 & 0x0F;
         return [defId,cat1,cat2,cat3,cat4,cat5,cat6,cat7,cat8,cat9,cat10,cat11,cat9Secondary,cat10Secondary,cat11Secondary];
      }
   }
}

