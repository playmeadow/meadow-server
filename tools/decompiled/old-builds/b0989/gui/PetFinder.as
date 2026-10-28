package gui
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBStayLeavePopup;
   import com.sbi.popup.SBYesNoPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import item.Item;
   import loader.MediaHelper;
   import pet.GuiPet;
   import pet.PetBase;
   import pet.PetManager;
   import pet.PetXtCommManager;
   
   public class PetFinder
   {
      
      private static const PET_FINDER_MEDIA_ID:int = 1207;
      
      private static const PET_NAMES_1:int = 671;
      
      private static const PET_NAMES_2:int = 706;
      
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
      
      public function PetFinder()
      {
         super();
      }
      
      public static function createRandomPet(param1:int) : Array
      {
         var _loc2_:int = Math.random() * 19;
         var _loc3_:int = Math.random() * 19;
         var _loc4_:int = 0;
         var _loc5_:int = Math.random() * 5;
         var _loc6_:int = Math.random() * 3;
         var _loc7_:int = Math.random() * 3;
         var _loc8_:int = Math.random() * 3;
         var _loc9_:int = 0;
         return [param1,_loc2_,_loc3_,_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,0,0,0,0,0,0];
      }
      
      public static function packPetBits(param1:Array) : Array
      {
         var _loc2_:uint = uint(param1[5] << 28 | param1[4] << 24 | param1[3] << 19 | param1[2] << 14 | param1[1] << 8 | param1[0]);
         var _loc3_:uint = uint(param1[11] << 20 | param1[10] << 16 | param1[9] << 12 | param1[8] << 8 | param1[7] << 4 | param1[6]);
         var _loc4_:uint = 0;
         return [_loc2_,_loc3_,_loc4_];
      }
      
      public function init(param1:int = -1, param2:Function = null, param3:Boolean = false, param4:Array = null, param5:int = 0, param6:Object = null, param7:int = 0) : void
      {
         DarkenManager.showLoadingSpiral(true);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/petFinder");
         this._guiLayer = GuiManager.guiLayer;
         this._closeCallback = param2;
         this._petDefId = param1;
         this._isFromRedemption = param3;
         this._isUsingSelectionMode = param1 == -1;
         this._petData = param4;
         this._currencyType = param5;
         this._specialDef = param6;
         this._shopId = param7;
         this._mediaHelpers = [];
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(PET_FINDER_MEDIA_ID,this.onMediaItemLoaded);
         this._mediaHelpers.push(this._loadingMediaHelper);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:GuiPet = null;
         this.removeEventListeners();
         if(this._petMC)
         {
            DarkenManager.unDarken(this._petMC);
         }
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         this._nameScroller1 = null;
         this._nameScroller2 = null;
         if(this._petMC)
         {
            _loc2_ = this._petMC.petSelect;
            _loc1_ = 0;
            while(_loc1_ < _loc2_.numChildren)
            {
               _loc3_ = _loc2_.getChildAt(_loc1_);
               if(Boolean(_loc3_) && _loc3_.hasOwnProperty("numChildren"))
               {
                  _loc4_ = 0;
                  while(_loc4_ < _loc3_.numChildren)
                  {
                     _loc5_ = _loc3_.getChildAt(_loc4_);
                     if((Boolean(_loc5_)) && _loc5_.hasOwnProperty("destroy"))
                     {
                        _loc5_.destroy();
                        _loc5_ = null;
                     }
                     _loc4_++;
                  }
                  _loc3_ = null;
               }
               _loc1_++;
            }
         }
         if(this._petToBeCreated)
         {
            this._petToBeCreated.destroy();
            this._petToBeCreated = null;
         }
         if(this._isUsingSelectionMode)
         {
            if(this._savedPets)
            {
               _loc1_ = 0;
               while(_loc1_ < this._savedPets.length)
               {
                  _loc6_ = this._savedPets[_loc1_];
                  _loc6_.removeEventListener(MouseEvent.MOUSE_OVER,this.onPetMouseOver);
                  _loc6_.removeEventListener(MouseEvent.MOUSE_OUT,this.onPetMouseOut);
                  _loc6_.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPetDown);
                  _loc6_.destroy();
                  _loc1_++;
               }
               this._savedPets = null;
               this._hoverGlow = null;
               this._downGlow = null;
            }
         }
         if(this._petInventory)
         {
            this._petInventory.destroy();
         }
         if(Boolean(this._petMC) && Boolean(this._petMC.parent) && this._petMC.parent == this._guiLayer)
         {
            this._guiLayer.removeChild(this._petMC);
            this._petMC = null;
         }
         _loc1_ = 0;
         while(_loc1_ < this._mediaHelpers.length)
         {
            this._mediaHelpers[_loc1_].destroy();
            delete this._mediaHelpers[_loc1_];
            _loc1_++;
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
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Array = null;
         var _loc7_:GuiPet = null;
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
         var _loc1_:MovieClip = this._petMC.petSelect;
         var _loc8_:int = 0;
         while(_loc8_ < _loc1_.numChildren)
         {
            _loc2_ = _loc1_.getChildAt(_loc8_);
            _loc3_ = int(_loc2_.name.indexOf("Pet"));
            if(_loc3_ > 0)
            {
               _loc4_ = PetManager.petDefIdForName(_loc2_.name.substr(0,_loc3_));
               _loc5_ = PetManager.getPetDef(_loc4_);
               if(PetManager.isPetAvailable(_loc4_))
               {
                  _loc6_ = packPetBits(createRandomPet(_loc4_));
                  _loc7_ = PetManager.getGuiPet(this._savedPets.length,_loc6_[0],_loc6_[1],_loc6_[2],_loc5_.type,"?",this.onPetLoadedOnSelection);
                  _loc2_.addChild(_loc7_);
                  this._savedPets.push(_loc7_);
               }
               else
               {
                  _loc2_.visible = false;
               }
            }
            _loc8_++;
         }
      }
      
      private function setupPetFinder(param1:GuiPet = null, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         var _loc4_:Array = null;
         if(!param2)
         {
            this._petMC.petSelect.visible = false;
            _loc3_ = PetManager.getPetDef(this._petDefId);
            if(this._isFromRedemption)
            {
               this._petPreview.tag.visible = false;
            }
            else
            {
               this._petPreview.tag.visible = true;
               this._petPreview.tag.txt.text = this._specialDef ? this._specialDef.value : _loc3_.cost;
               if(this._currencyType == Item.GEM_CURRENCY)
               {
                  this._gemCount = gMainFrame.clientInfo.gemCount;
                  if(this._gemCount < (this._specialDef ? this._specialDef.value : _loc3_.cost))
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
                  if(this._gemCount < (this._specialDef ? this._specialDef.value : _loc3_.cost))
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
                  if(this._gemCount < (this._specialDef ? this._specialDef.value : _loc3_.cost))
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
                  if(this._gemCount < (this._specialDef ? this._specialDef.value : _loc3_.cost))
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
            if(Boolean(gMainFrame.userInfo.isMember) || !_loc3_.isMember)
            {
               this._petPreview.lock.visible = false;
            }
            if(!param1)
            {
               if(this._petData)
               {
                  _loc4_ = this._petData;
                  this._catArray = this.unpackPetBits(this._petData[0],this._petData[1],this._petData[2]);
               }
               else
               {
                  this._catArray = createRandomPet(this._petDefId);
                  _loc4_ = packPetBits(this._catArray);
               }
               this._petToBeCreated = PetManager.getGuiPet(0,_loc4_[0],_loc4_[1],_loc4_[2],_loc3_.type,"?",this.onPetLoadedOnStage);
               this.addEventListeners();
            }
            else
            {
               this._catArray = this.unpackPetBits(param1.getLBits(),param1.getUBits(),param1.getEBits());
               this._petToBeCreated = PetManager.getGuiPet(0,param1.getLBits(),param1.getUBits(),param1.getEBits(),_loc3_.type,"?",this.onPetLoadedOnStage);
            }
            while(this._petPreview.itemWindow.numChildren > 0)
            {
               this._petPreview.itemWindow.removeChildAt(0);
            }
            this._petPreview.itemWindow.addChild(this._petToBeCreated);
            if(_loc3_.type == PetBase.TYPE_LAND_GROUND || _loc3_.type == PetBase.TYPE_LAND_AIR || _loc3_.type == PetBase.TYPE_AMPHIB_AIR || _loc3_.type == PetBase.TYPE_AMPHIB_GROUND)
            {
               this._petPreview.charBox.gotoAndStop(1);
            }
            else
            {
               this._petPreview.charBox.gotoAndStop(2);
            }
            if(_loc3_.status != PetManager.LIMITED_TIME)
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
         var _loc1_:Array = new Array(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
         var _loc2_:Array = [];
         var _loc3_:Array = [];
         var _loc4_:int = Math.max(this._colors1.length,this._colors2.length);
         var _loc5_:int = 0;
         while(_loc5_ < _loc4_)
         {
            if(_loc5_ < this._colors1.length)
            {
               _loc2_[_loc5_] = (this._colors1[_loc5_][0] << 16) + (this._colors1[_loc5_][1] << 8) + this._colors1[_loc5_][2];
            }
            if(_loc5_ < this._colors2.length)
            {
               _loc3_[_loc5_] = (this._colors2[_loc5_][0] << 16) + (this._colors2[_loc5_][1] << 8) + this._colors2[_loc5_][2];
            }
            _loc5_++;
         }
         this._colorTableColor1 = new ColorTable();
         this._colorTableColor1.init(CT_ID_TOP,CT_WIDTH,CT_HEIGHT,CT_NUM_COLS,CT_NUM_ROWS,_loc2_,_loc1_,this._currColor1Index,this.onColorChanged);
         this._colorTableColor2 = new ColorTable();
         this._colorTableColor2.init(CT_ID_BOT,CT_WIDTH,CT_HEIGHT,CT_NUM_COLS,CT_NUM_ROWS,_loc3_,_loc1_,this._currColor2Index,this.onColorChanged);
         this._petSettings.colorTableBlock.colors.addChild(this._colorTableColor1);
         this._petSettings.colorTableBlock.colors.addChild(this._colorTableColor2);
         this._colorTableColor1.x = CT_X;
         this._colorTableColor1.y = CT_Y_TOP;
         this._colorTableColor2.x = CT_X;
         this._colorTableColor2.y = CT_Y_BOT;
      }
      
      private function onPetFinderDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onLeverDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._petMC.petNamer.visible)
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
      
      private function onCloseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         new SBStayLeavePopup(this._guiLayer,"Leave Pet Finder?",true,this.confirmCloseCallback);
      }
      
      private function confirmCloseCallback(param1:Object) : void
      {
         if(param1.status)
         {
            this.destroy();
         }
      }
      
      private function onNextBtn(param1:MouseEvent = null) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(!this._petMC.nextBtn.isGray)
         {
            if(this._petMC.petSelect.visible)
            {
               this._petPreview.visible = true;
               this._petSettings.visible = true;
               _loc2_ = int(this._savedPets[this._chosenIndex].getDefID());
               if(this._petDefId != _loc2_)
               {
                  this._petDefId = _loc2_;
               }
               else
               {
                  _loc3_ = true;
               }
               this._petMC.petSelect.visible = false;
               this._petMC.backBtn.visible = true;
               this.setupPetFinder(this._savedPets[this._chosenIndex],_loc3_);
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
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._petMC.petNamer.visible)
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
      
      private function onAdoptPetBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._isFromRedemption)
         {
            new SBYesNoPopup(this._guiLayer,"Are you sure you want to adopt this pet?",true,this.onAdoptYesBtn);
            return;
         }
         var _loc2_:Object = PetManager.getPetDef(this._petDefId);
         var _loc3_:int = this._specialDef ? int(this._specialDef.value) : int(_loc2_.cost);
         if(!gMainFrame.userInfo.isMember && Boolean(_loc2_.isMember))
         {
            UpsellManager.displayPopup(UpsellManager.PETS,"buyMemberPet");
         }
         else if(Boolean(this._specialDef) && PetManager.isPetAvailable(this._petDefId))
         {
            new SBYesNoPopup(this._guiLayer,"You already have the " + _loc2_.title.toLowerCase() + ". Would you like to create another one now for " + _loc2_.cost + " gems?",true,this.onBuyInDiamondShopConfirm,_loc2_.cost);
         }
         else if(this._gemCount < _loc3_)
         {
            if(this._specialDef)
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
               this._petMC.oopsCostPopup.costTxt.text = _loc3_;
               this._petMC.oopsCostPopup.needTxt.text = _loc3_ - this._gemCount;
               this._petMC.oopsCostPopup.visible = true;
            }
         }
         else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
         {
            new SBYesNoPopup(this._guiLayer,"Your pet list is full! Free a pet to open up a slot?",true,this.confirmRecycle);
         }
         else if(this._specialDef)
         {
            GuiManager.showDiamondConfirmation(_loc3_,this.onAdoptYesBtn);
         }
         else
         {
            new SBYesNoPopup(this._guiLayer,"Are you sure you want to spend " + Utility.convertNumberToString(_loc3_) + (this._specialDef ? " diamonds" : " gems") + " to adopt this pet?",true,this.onAdoptYesBtn);
         }
      }
      
      private function confirmRecycle(param1:Object) : void
      {
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            this._petInventory = new PetInventory();
            this._petInventory.init(this.onPetInventoryClose,true);
         }
      }
      
      private function onPetInventoryClose(param1:Boolean) : void
      {
         var _loc2_:String = null;
         this._petInventory = null;
         if(param1)
         {
            if(this._specialDef)
            {
               GuiManager.showDiamondConfirmation(this._specialDef.value,this.onAdoptYesBtn);
               return;
            }
            _loc2_ = Utility.convertNumberToString(PetManager.getPetDef(this._petDefId).cost) + " gems";
            new SBYesNoPopup(this._guiLayer,"Are you sure you want to spend " + _loc2_ + " to adopt this pet?",true,this.onAdoptYesBtn);
         }
      }
      
      private function onBuyInDiamondShopConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            this._currencyType = Item.GEM_CURRENCY;
            this._gemCount = gMainFrame.clientInfo.gemCount;
            this._specialDef = null;
            if(this._gemCount < param1.passback)
            {
               DarkenManager.darken(this._petMC.oopsCostPopup);
               this._petMC.oopsCostPopup.currency.gotoAndStop("gems");
               this._petMC.oopsCostPopup.gemsTxt.text = this._gemCount;
               this._petMC.oopsCostPopup.costTxt.text = param1.passback;
               this._petMC.oopsCostPopup.needTxt.text = param1.passback - this._gemCount;
               this._petMC.oopsCostPopup.visible = true;
            }
            else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
            {
               new SBYesNoPopup(this._guiLayer,"Your pet list is full! Free a pet to open up a slot?",true,this.confirmRecycle);
            }
            else
            {
               this.onAdoptYesBtn(param1);
            }
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onAdoptYesBtn(param1:Object = null) : void
      {
         var _loc2_:Array = null;
         if(param1 == null || Boolean(param1.status))
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = packPetBits(this._catArray);
            if(this._specialDef)
            {
               PetXtCommManager.sendPetShopBuyRequest(this._shopId,this._specialDef.defId,_loc2_[0],_loc2_[1],_loc2_[2],this._nameScroller1.contentItemIndex,this._nameScroller2.contentItemIndex,this.onCreateResponse,this._isFromRedemption);
            }
            else
            {
               PetXtCommManager.sendPetCreateRequest(_loc2_[0],_loc2_[1],_loc2_[2],this._nameScroller1.contentItemIndex,this._nameScroller2.contentItemIndex,this.onCreateResponse,this._isFromRedemption);
            }
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/pet/petFinder/didNotKeep");
         }
      }
      
      private function onCostPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._petMC.oopsCostPopup);
         this._petMC.oopsCostPopup.visible = false;
      }
      
      private function onColorsEyesTraitsDownBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == this._petSettings.colorsDownBtn.name)
         {
            this.openTab(COLOR_TAB_ID);
         }
         else if(param1.currentTarget.name == this._petSettings.traitsDownBtn.name)
         {
            this.openTab(TRAITS_TAB_ID);
         }
         else if(param1.currentTarget.name == this._petSettings.eyesDownBtn.name)
         {
            this.openTab(EYE_TAB_ID);
         }
      }
      
      public function openTab(param1:int) : void
      {
         if(param1 == COLOR_TAB_ID)
         {
            this.openColorTableColorsTab();
         }
         else if(param1 == TRAITS_TAB_ID)
         {
            this.openTraitsOrEyesTab(true);
         }
         else if(param1 == EYE_TAB_ID)
         {
            this.openTraitsOrEyesTab(false);
         }
         else
         {
            DebugUtility.debugTrace("Error PetFinder on openTab: Invalid tabId: " + param1);
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
      
      private function openTraitsOrEyesTab(param1:Boolean) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         if(param1)
         {
            this._petSettings.colorsTabUp.visible = false;
            this._petSettings.eyesTabUp.visible = false;
            this._petSettings.traitsTabUp.visible = true;
            this._petSettings.colorTableBlock.colors.visible = false;
            this._petSettings.colorTableBlock.eyes.visible = false;
            this._petSettings.colorTableBlock.traits.visible = true;
            _loc3_ = 1;
            while(_loc3_ < 4)
            {
               _loc2_ = this._petSettings.colorTableBlock.traits["win" + _loc3_];
               while(_loc2_.iconLayer.numChildren > 0)
               {
                  _loc2_.iconLayer.removeChildAt(0);
               }
               _loc2_.ocean.visible = false;
               _loc2_.removeBtn.visible = false;
               _loc2_.lockOpen.visible = false;
               _loc2_.gift.visible = false;
               _loc2_.lock.visible = false;
               _loc2_.addBtn.visible = false;
               _loc2_.gray.visible = false;
               this._petSettings.colorTableBlock.traits["traits" + _loc3_ + "Txt"].text = "";
               _loc4_ = this["_att" + _loc3_];
               if((Boolean(_loc4_)) && _loc4_.length > 0)
               {
                  this._petSettings.colorTableBlock.traits["traits" + _loc3_ + "Txt"].text = _loc4_[0];
                  if(_loc4_.length > this["_currAtt" + _loc3_ + "Index"])
                  {
                     this._petToBeCreated.colorMyItem(this["_att" + _loc3_][1],_loc4_[this["_currAtt" + _loc3_ + "Index"]],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                     _loc2_.iconLayer.addChild(_loc4_[this["_currAtt" + _loc3_ + "Index"]]);
                     this._petSettings.colorTableBlock.traits["lBtn" + _loc3_].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     this._petSettings.colorTableBlock.traits["rBtn" + _loc3_].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     this._petSettings.colorTableBlock.traits["rBtn" + _loc3_].index = _loc3_;
                     this._petSettings.colorTableBlock.traits["lBtn" + _loc3_].index = _loc3_;
                  }
               }
               _loc3_++;
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
            _loc3_ = 1;
            while(_loc3_ < 7)
            {
               _loc2_ = this._petSettings.colorTableBlock.eyes["win" + _loc3_];
               while(_loc2_.iconLayer.numChildren > 0)
               {
                  _loc2_.iconLayer.removeChildAt(0);
               }
               _loc2_.ocean.visible = false;
               _loc2_.removeBtn.visible = false;
               _loc2_.lockOpen.visible = false;
               _loc2_.gift.visible = false;
               _loc2_.lock.visible = false;
               _loc2_.addBtn.visible = false;
               _loc2_.gray.visible = false;
               if(Boolean(this._eyes) && this._eyes.length > 0)
               {
                  if(this._eyes.length > _loc3_ + 1)
                  {
                     this._petToBeCreated.colorMyItem(this._eyes[1],this._eyes[_loc3_ + 1],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                     _loc2_.iconLayer.addChild(this._eyes[_loc3_ + 1]);
                     if(!_loc2_.hasEventListener(MouseEvent.MOUSE_DOWN))
                     {
                        _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     }
                     if(!_loc2_.hasEventListener(MouseEvent.ROLL_OVER))
                     {
                        _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.winMouseOver,false,0,true);
                     }
                     if(!_loc2_.hasEventListener(MouseEvent.ROLL_OUT))
                     {
                        _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.winMouseOut,false,0,true);
                     }
                     _loc2_.index = _loc3_;
                     if(this._currEyeIndex == _loc3_ + 1)
                     {
                        _loc2_.cir.gotoAndStop("down");
                     }
                     else
                     {
                        _loc2_.cir.gotoAndStop("up");
                     }
                  }
                  else
                  {
                     _loc2_.gray.visible = true;
                  }
               }
               _loc3_++;
            }
         }
      }
      
      private function onPetMouseOver(param1:MouseEvent) : void
      {
         if(param1.currentTarget.filters.length == 0)
         {
            param1.currentTarget.filters = [this._hoverGlow];
         }
      }
      
      private function onPetMouseOut(param1:MouseEvent) : void
      {
         if(param1.currentTarget.filters[0].strength != this._downGlow.strength)
         {
            param1.currentTarget.filters = [];
         }
      }
      
      private function onPetDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._savedPets[this._chosenIndex].filters = [];
         param1.currentTarget.filters = [this._downGlow];
         this._chosenIndex = param1.currentTarget.idx;
         this._petMC.nextBtn.activateGrayState(false);
      }
      
      private function onPetLoadedOnSelection(param1:MovieClip) : void
      {
         var _loc2_:GuiPet = null;
         var _loc3_:GlowFilter = null;
         var _loc4_:int = 0;
         ++this._numPetsLoaded;
         if(this._numPetsLoaded >= this._savedPets.length)
         {
            _loc4_ = 0;
            while(_loc4_ < this._savedPets.length)
            {
               _loc2_ = this._savedPets[_loc4_];
               _loc2_.scaleX = 2;
               _loc2_.scaleY = 2;
               _loc2_.addEventListener(MouseEvent.MOUSE_OVER,this.onPetMouseOver,false,0,true);
               _loc2_.addEventListener(MouseEvent.MOUSE_OUT,this.onPetMouseOut,false,0,true);
               _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetDown,false,0,true);
               _loc4_++;
            }
            this.addEventListeners();
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this._petMC);
            DarkenManager.darken(this._petMC);
         }
      }
      
      private function onPetLoadedOnStage(param1:MovieClip) : void
      {
         var _loc4_:GlowFilter = null;
         LocalizationXtCommManager.sendTranslateStringRequest(PET_NAMES_1,LocalizationXtCommManager.LANG_ENG,this.onLocalizationReceived);
         LocalizationXtCommManager.sendTranslateStringRequest(PET_NAMES_2,LocalizationXtCommManager.LANG_ENG,this.onLocalizationReceived);
         var _loc2_:MovieClip = this._petToBeCreated.getContent();
         this._colors1 = _loc2_.getCol1();
         this._colors2 = _loc2_.getCol2();
         this._eyes = _loc2_.getEyes();
         this._att1 = _loc2_.getAtt1();
         this._att2 = _loc2_.getAtt2();
         this._att3 = _loc2_.getAtt3();
         var _loc3_:int = 2;
         _loc3_ = 2;
         while(_loc3_ < this._eyes.length)
         {
            _loc4_ = new GlowFilter(0,1,2,2,2);
            this._eyes[_loc3_].filters = [_loc4_];
            _loc3_++;
         }
         _loc3_ = 2;
         while(_loc3_ < this._att1.length)
         {
            _loc4_ = new GlowFilter(0,1,2,2,2);
            this._att1[_loc3_].filters = [_loc4_];
            _loc3_++;
         }
         _loc3_ = 2;
         while(_loc3_ < this._att2.length)
         {
            _loc4_ = new GlowFilter(0,1,2,2,2);
            this._att2[_loc3_].filters = [_loc4_];
            _loc3_++;
         }
         _loc3_ = 2;
         while(_loc3_ < this._att3.length)
         {
            _loc4_ = new GlowFilter(0,1,2,2,2);
            this._att3[_loc3_].filters = [_loc4_];
            _loc3_++;
         }
         this._catIndexArray = [];
         var _loc5_:int = int(this._petToBeCreated.getLBits());
         var _loc6_:int = int(this._petToBeCreated.getUBits());
         var _loc7_:int = _loc5_ >> 8 & 0x3F;
         this._catIndexArray[1] = _loc7_;
         var _loc8_:int = _loc5_ >> 14 & 0x1F;
         this._catIndexArray[2] = _loc8_;
         var _loc9_:int = _loc5_ >> 19 & 0x1F;
         this._catIndexArray[3] = _loc9_;
         var _loc10_:int = (_loc5_ >> 24 & 0x0F) + 2;
         this._catIndexArray[4] = _loc10_;
         var _loc11_:int = (_loc5_ >> 28 & 0x0F) + 2;
         this._catIndexArray[5] = _loc11_;
         var _loc12_:int = (_loc6_ & 0x0F) + 2;
         this._catIndexArray[6] = _loc12_;
         var _loc13_:int = (_loc6_ >> 4 & 0x0F) + 2;
         this._catIndexArray[7] = _loc13_;
         var _loc14_:int = (_loc6_ >> 8 & 0x0F) + 2;
         this._catIndexArray[8] = _loc14_;
         this._currColor1Index = _loc7_;
         this._currColor2Index = _loc8_;
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
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._petMC = MovieClip(param1.getChildAt(0));
            this._petMC.oopsCostPopup.visible = false;
            this._petMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._petMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._petPreview = this._petMC.petPreview;
            this._petSettings = this._petMC.petSettings;
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
      
      private function onLocalizationReceived(param1:int, param2:String) : void
      {
         var _loc3_:Array = param2.split("|");
         if(param1 == PET_NAMES_1)
         {
            this._nameScroller1 = new GuiCarousel(this._petMC.petNamer.nameScroller1);
            this._nameScroller1.init(_loc3_,this.name1Changed);
         }
         else if(param1 == PET_NAMES_2)
         {
            this._nameScroller2 = new GuiCarousel(this._petMC.petNamer.nameScroller2);
            this._nameScroller2.init(_loc3_,this.name2Changed);
         }
         if(Boolean(this._nameScroller1) && Boolean(this._nameScroller2))
         {
            this.randomizeNames();
            this._petMC.petNamer.nameLever.visible = true;
         }
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
         }
         if(Boolean(this._nameScroller2) && !this._nameScroller2.soundsEnabled)
         {
            this._nameScroller2.soundsEnabled = true;
         }
      }
      
      private function onColorChanged(param1:int, param2:int) : void
      {
         if(param1 == CT_ID_TOP)
         {
            this._currColor1Index = param2;
            this._catIndexArray[1] = this._currColor1Index;
            this._catArray[1] = this._currColor1Index;
         }
         else
         {
            this._currColor2Index = param2;
            this._catIndexArray[2] = this._currColor2Index;
            this._catArray[2] = this._currColor2Index;
         }
         var _loc3_:Array = packPetBits(this._catArray);
         this._petToBeCreated.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
      }
      
      private function onColorEyesTraitsDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._petSettings.colorTableBlock.eyes["win" + param1.currentTarget.index].name)
         {
            this._petSettings.colorTableBlock.eyes["win" + (this._currEyeIndex - 1)].cir.gotoAndStop("up");
            this._currEyeIndex = param1.currentTarget.index + 1;
            param1.currentTarget.cir.gotoAndStop("down");
            AJAudio.playSubMenuBtnClick();
            this._catIndexArray[this._eyes[1]] = this._currEyeIndex;
            this._catArray[this._eyes[1]] = this._currEyeIndex - 2;
            this._petToBeCreated.colorMyItem(this._eyes[1],this._eyes[this._currEyeIndex],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
            _loc3_ = packPetBits(this._catArray);
            this._petToBeCreated.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
         }
         else if(param1.currentTarget.index < 4)
         {
            _loc5_ = 0;
            if(param1.currentTarget.name == this._petSettings.colorTableBlock.traits["lBtn" + param1.currentTarget.index].name)
            {
               _loc5_--;
            }
            else if(param1.currentTarget.name == this._petSettings.colorTableBlock.traits["rBtn" + param1.currentTarget.index].name)
            {
               _loc5_++;
            }
            if(_loc5_ != 0)
            {
               _loc4_ = this["_att" + param1.currentTarget.index];
               _loc2_ = param1.currentTarget.parent["win" + param1.currentTarget.index];
               if(_loc2_.iconLayer.numChildren > 0)
               {
                  _loc2_.iconLayer.removeChildAt(0);
               }
               if(Boolean(_loc4_) && _loc4_.length > 0)
               {
                  _loc6_ = int(this["_currAtt" + param1.currentTarget.index + "Index"]);
                  if(_loc5_ > 0)
                  {
                     if(_loc4_.length > _loc6_ + _loc5_)
                     {
                        _loc6_ += _loc5_;
                        _loc2_.iconLayer.addChild(_loc4_[_loc6_]);
                     }
                     else
                     {
                        _loc6_ = 2;
                        _loc2_.iconLayer.addChild(_loc4_[2]);
                     }
                  }
                  else if(_loc6_ + _loc5_ < 2)
                  {
                     _loc6_ = _loc4_.length - 1;
                     _loc2_.iconLayer.addChild(_loc4_[_loc4_.length - 1]);
                  }
                  else
                  {
                     _loc6_ += _loc5_;
                     _loc2_.iconLayer.addChild(_loc4_[_loc6_]);
                  }
                  this._catIndexArray[_loc4_[1]] = _loc6_;
                  this._petToBeCreated.colorMyItem(_loc4_[1],_loc4_[_loc6_],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                  this._catArray[_loc4_[1]] = _loc6_ - 2;
                  _loc3_ = packPetBits(this._catArray);
                  this._petToBeCreated.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
                  this["_currAtt" + param1.currentTarget.index + "Index"] = _loc6_;
               }
            }
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
         {
            param1.currentTarget.cir.gotoAndStop("down");
         }
         else if(param1.currentTarget.cir.currentFrameLabel == "over")
         {
            param1.currentTarget.cir.gotoAndStop("up");
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
         if(this._petMC)
         {
            this._petMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPetFinderDown);
            this._petMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseDown);
            this._petMC.petNamer.adoptPetBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetBtn);
            this._petMC.petNamer.nameLever.removeEventListener(MouseEvent.MOUSE_DOWN,this.onLeverDown);
            this._petMC.backBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn);
            this._petMC.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn);
            this._petMC.oopsCostPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose);
         }
         if(this._petSettings)
         {
            this._petSettings.eyesDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
            this._petSettings.traitsDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
            this._petSettings.colorsDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
         }
      }
      
      private function unpackPetBits(param1:uint, param2:uint, param3:uint) : Array
      {
         var _loc4_:int = param1 & 0xFF;
         var _loc5_:int = param1 >> 8 & 0x3F;
         var _loc6_:int = param1 >> 14 & 0x1F;
         var _loc7_:int = param1 >> 19 & 0x1F;
         var _loc8_:int = param1 >> 24 & 0x0F;
         var _loc9_:int = param1 >> 28 & 0x0F;
         var _loc10_:int = param2 & 0x0F;
         var _loc11_:int = param2 >> 4 & 0x0F;
         var _loc12_:int = param2 >> 8 & 0x0F;
         var _loc13_:int = param2 >> 12 & 0x0F;
         var _loc14_:int = param2 >> 16 & 0x0F;
         var _loc15_:int = param2 >> 20 & 0x0F;
         var _loc16_:int = param3 & 0x0F;
         var _loc17_:int = param3 >> 4 & 0x0F;
         var _loc18_:int = param3 >> 8 & 0x0F;
         return [_loc4_,_loc5_,_loc6_,_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_,_loc15_,_loc16_,_loc17_,_loc18_];
      }
   }
}

