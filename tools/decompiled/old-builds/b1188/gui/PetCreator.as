package gui
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Exponential;
   import gskinner.motion.plugins.MotionBlurPlugin;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   import pet.PetXtCommManager;
   
   public class PetCreator
   {
      
      private static const PET_FINDER_MEDIA_ID:int = 4058;
      
      private static const PET_NAMES_1:int = 205;
      
      private static const PET_NAMES_2:int = 206;
      
      private static const PET_DEF_LIST:int = 312;
      
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
      
      private var _petDefId:int;
      
      private var _isFromRedemption:Boolean;
      
      private var _petData:Array;
      
      private var _currencyType:int;
      
      private var _specialDef:Object;
      
      private var _shopId:int;
      
      private var _petNames:Array;
      
      private var _gemCount:int;
      
      private var _catArray:Array;
      
      private var _currPetDef:Object;
      
      private var _att3:Array;
      
      private var _att2:Array;
      
      private var _att1:Array;
      
      private var _eyes:Array;
      
      private var _colors2:Array;
      
      private var _colors1:Array;
      
      private var _catIndexArray:Array;
      
      private var _currColor1Index:int;
      
      private var _currAtt3Index:int;
      
      private var _currAtt2Index:int;
      
      private var _currAtt1Index:int;
      
      private var _currEyeIndex:int;
      
      private var _currColor2Index:int;
      
      private var _currIndex:int;
      
      private var _screenPositionIndex:int;
      
      private var _creatingWithoutChoosing:Boolean;
      
      private var _tweenInProgress:Boolean;
      
      private var _currEnviroPetDefIds:Array;
      
      private var _specialDefCost:int;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _petMC:MovieClip;
      
      private var _oopsPopup:MovieClip;
      
      private var _createPanel:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _adoptPetBtn:MovieClip;
      
      private var _diamondBuyBtnRed:MovieClip;
      
      private var _diamondBuyBtnGreen:MovieClip;
      
      private var _bigPetWindow:MovieClip;
      
      private var _background:MovieClip;
      
      private var _closeBtn:MovieClip;
      
      private var _createPanelCont:MovieClip;
      
      private var _choosePetPanel:MovieClip;
      
      private var _namePanel:MovieClip;
      
      private var _settingsPanel:MovieClip;
      
      private var _diamondBuyBtn:MovieClip;
      
      private var _oopsCostPopup:MovieClip;
      
      private var _nameScroller1:GuiCarousel;
      
      private var _nameScroller2:GuiCarousel;
      
      private var _petWindows:WindowGenerator;
      
      private var _scrollBar:SBScrollbar;
      
      private var _currPet:GuiPet;
      
      private var _colorTableColor1:ColorTable;
      
      private var _colorTableColor2:ColorTable;
      
      private var _petInventory:PetInventory;
      
      private var _bgTween:GTween;
      
      private var _petTween:GTween;
      
      private var _panelTween:GTween;
      
      private var _guiLayer:DisplayLayer;
      
      private var _closeCallback:Function;
      
      public function PetCreator()
      {
         super();
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
         this._petData = param4;
         this._currencyType = param5;
         this._specialDef = param6;
         this._shopId = param7;
         this._creatingWithoutChoosing = this._isFromRedemption || Boolean(this._specialDef);
         MotionBlurPlugin.install();
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(PET_FINDER_MEDIA_ID,this.onMediaItemLoaded);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         if(this._nameScroller1)
         {
            this._nameScroller1.destroy();
            this._nameScroller1 = null;
         }
         if(this._nameScroller2)
         {
            this._nameScroller2.destroy();
            this._nameScroller2 = null;
         }
         if(this._petWindows)
         {
            this._petWindows.destroy();
            this._petWindows = null;
         }
         if(this._scrollBar)
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(this._currPet)
         {
            this._currPet.destroy();
            this._currPet = null;
         }
         if(this._colorTableColor1)
         {
            this._colorTableColor1.destroy();
            this._colorTableColor1 = null;
         }
         if(this._colorTableColor2)
         {
            this._colorTableColor2.destroy();
            this._colorTableColor2 = null;
         }
         if(this._loadingMediaHelper)
         {
            this._loadingMediaHelper.destroy();
            this._loadingMediaHelper = null;
         }
         if(this._petInventory)
         {
            this._petInventory.destroy();
            this._petInventory = null;
         }
         if(this._bgTween)
         {
            this._bgTween.end();
            this._bgTween = null;
         }
         if(this._petTween)
         {
            this._petTween.end();
            this._petTween = null;
         }
         if(this._panelTween)
         {
            this._panelTween.end();
            this._panelTween = null;
         }
         this._closeCallback = null;
         DarkenManager.unDarken(this._petMC);
         this._guiLayer.removeChild(this._petMC);
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._petMC = MovieClip(param1.getChildAt(0));
            this._petMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._petMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._oopsPopup = this._petMC.oopsPopup;
            this._createPanelCont = this._petMC.createPanel.panelCont;
            this._choosePetPanel = this._createPanelCont.choosePet;
            this._settingsPanel = this._createPanelCont.customSettingsPanel.petSettings;
            this._namePanel = this._createPanelCont.createAName;
            this._diamondBuyBtnGreen = this._petMC.diamond_buy_btn_green;
            this._diamondBuyBtnRed = this._petMC.diamond_buy_btn_red;
            this._adoptPetBtn = this._petMC.adoptPetBtn;
            this._backBtn = this._petMC.back_btn;
            this._nextBtn = this._petMC.next_btn;
            this._bigPetWindow = this._petMC.petWindow;
            this._closeBtn = this._petMC.bx;
            this._background = this._petMC.bg;
            this._oopsCostPopup = this._petMC.oopsCostPopup;
            this._diamondBuyBtn = this._diamondBuyBtnGreen;
            this.startPetCreatorSetup();
         }
      }
      
      private function onNamesLoaded(param1:int, param2:Array) : void
      {
         var _loc5_:Array = null;
         var _loc6_:String = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:Object = [];
         var _loc4_:int = -1;
         switch(param1)
         {
            case PET_NAMES_1:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc3_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc4_ = 1;
               }
               else
               {
                  _loc3_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc4_ = 0;
               }
               break;
            case PET_NAMES_2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc3_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc4_ = 0;
               }
               else
               {
                  _loc3_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc4_ = 1;
               }
         }
         if(_loc4_ != -1)
         {
            _loc8_ = 0;
            while(_loc8_ < param2.length)
            {
               if(_loc4_ == 0)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(param2[_loc8_]).split("$");
                  _loc6_ = _loc5_[0];
                  _loc7_ = Utility.findIndexToInsert(_loc3_.names,_loc6_);
                  _loc3_.names.splice(_loc7_,0,_loc6_);
                  if(_loc5_[1])
                  {
                     _loc3_.types.splice(_loc7_,0,_loc5_[1]);
                  }
                  else
                  {
                     _loc3_.types.splice(_loc7_,0,"m");
                  }
               }
               else if(_loc4_ == 1)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(param2[_loc8_]).split("$");
                  _loc6_ = _loc5_[0].toLowerCase();
                  _loc7_ = Utility.findIndexToInsert(_loc3_.names,_loc6_);
                  _loc3_.names.splice(_loc7_,0,_loc6_);
                  if(_loc5_[1])
                  {
                     _loc3_.femNames.splice(_loc7_,0,_loc5_[1].toLowerCase());
                  }
                  else
                  {
                     _loc3_.femNames.splice(_loc7_,0,_loc6_);
                  }
               }
               _loc3_.locIds.splice(_loc7_,0,param2[_loc8_]);
               _loc8_++;
            }
            this._petNames[_loc4_] = _loc3_;
         }
         if(this._petNames[0] != -1 && this._petNames[1] != -1)
         {
            this.setupPetNames(this._petNames[0].names,this._petNames[1].names);
         }
      }
      
      private function name1Changed() : void
      {
         if(Boolean(this._nameScroller1 && this._nameScroller2) && Boolean(this._nameScroller1.selectedContentItem) && Boolean(this._nameScroller2.selectedContentItem))
         {
            this._namePanel.aml_name_txt.text = this._nameScroller1.selectedContentItem + this._nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(this._namePanel.aml_name_txt,this._namePanel.aml_name_txt.text);
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
            this._namePanel.aml_name_txt.text = this._nameScroller1.selectedContentItem + this._nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(this._namePanel.aml_name_txt,this._namePanel.aml_name_txt.text);
         }
         if(Boolean(this._nameScroller2) && !this._nameScroller2.soundsEnabled)
         {
            this._nameScroller2.soundsEnabled = true;
         }
      }
      
      private function onPetDefsLoaded(param1:int, param2:Array, param3:Function) : void
      {
         var _loc4_:Object = null;
         this._currEnviroPetDefIds = [];
         var _loc5_:int = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = PetManager.getPetDef(param2[_loc5_]);
            if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc4_.type))
            {
               this._currEnviroPetDefIds.push(param2[_loc5_]);
            }
            _loc5_++;
         }
         this.setupCurrentPet();
         this.setupChoosePanel();
         this.buildPetWindows();
      }
      
      private function onPetWindowsLoaded() : void
      {
         this._choosePetPanel.itemWindow.addChild(this._petWindows);
         this._scrollBar = new SBScrollbar();
         this._scrollBar.init(this._petWindows,this._petWindows.width,this._petWindows.boxHeight * 3 + 2 * 3,12,"scrollbar2",this._petWindows.boxHeight + 2,0);
         this._scrollBar.scrollToElement(this._currIndex / 3,true);
      }
      
      private function onPetLoadedOnStage(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc4_:GlowFilter = null;
         this._colors1 = param1.getCol1();
         this._colors2 = param1.getCol2();
         this._eyes = param1.getEyes();
         this._att1 = param1.getAtt1();
         this._att2 = param1.getAtt2();
         this._att3 = param1.getAtt3();
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
         var _loc5_:int = int(this._currPet.getLBits());
         var _loc6_:int = int(this._currPet.getUBits());
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
         this._currPet.scaleX = 5;
         this._currPet.scaleY = 5;
         this._currPet.x = 20;
         this._currPet.y = 110;
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
         var _loc3_:Array = PetManager.packPetBits(this._catArray);
         this._currPet.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
      }
      
      private function onAdoptYesBtn(param1:Object = null) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1 == null || Boolean(param1.status))
         {
            DarkenManager.showLoadingSpiral(true);
            _loc2_ = PetManager.packPetBits(this._catArray);
            _loc3_ = LocalizationManager.isCurrLanguageReversed() ? int(this._petNames[1].locIds[this._nameScroller2.contentItemIndex]) : int(this._petNames[0].locIds[this._nameScroller1.contentItemIndex]);
            _loc4_ = LocalizationManager.isCurrLanguageReversed() ? int(this._petNames[0].locIds[this._nameScroller1.contentItemIndex]) : int(this._petNames[1].locIds[this._nameScroller2.contentItemIndex]);
            if(Boolean(this._specialDef) && !PetManager.isPetAvailable(this._petDefId))
            {
               if(this._shopId == 0)
               {
                  this._shopId = GenericListXtCommManager.DIAMOND_PET_LIST;
               }
               PetXtCommManager.sendPetShopBuyRequest(this._shopId,this._specialDef.defId,_loc2_[0],_loc2_[1],_loc2_[2],_loc3_,_loc4_,this.onCreateResponse,this._isFromRedemption);
            }
            else
            {
               PetXtCommManager.sendPetCreateRequest(_loc2_[0],_loc2_[1],_loc2_[2],_loc3_,_loc4_,this.onCreateResponse,this._isFromRedemption);
            }
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/pet/petFinder/didNotKeep",-1,SBTracker.TYPE_EVENT);
         }
      }
      
      private function onBuyInDiamondShopConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            if(this._gemCount < param1.passback)
            {
               DarkenManager.darken(this._oopsCostPopup);
               this._oopsCostPopup.currency.gotoAndStop("gems");
               this._oopsCostPopup.gemsTxt.text = this._gemCount;
               this._oopsCostPopup.costTxt.text = param1.passback;
               this._oopsCostPopup.needTxt.text = param1.passback - this._gemCount;
               this._oopsCostPopup.visible = true;
            }
            else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14783),true,this.confirmRecycle);
            }
            else
            {
               this.onAdoptYesBtn(param1);
            }
         }
         else
         {
            this.close();
         }
      }
      
      private function onOkLandPet(param1:MouseEvent) : void
      {
         SBOkPopup.destroyInParentChain(param1.target.parent);
         this.close();
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
         this._petInventory = null;
         if(param1)
         {
            if(this._specialDef)
            {
               GuiManager.showDiamondConfirmation(this._specialDefCost,this.onAdoptYesBtn);
            }
            else
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14785,Utility.convertNumberToString(PetManager.getPetDef(this._petDefId).cost)),true,this.onAdoptYesBtn);
            }
         }
      }
      
      private function onCreateResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/petFinder/keep");
         GuiManager.resetPetWindowListInDen();
         this.close();
      }
      
      private function startPetCreatorSetup() : void
      {
         this.buildPetList();
         this._petNames = [-1,-1];
         GenericListXtCommManager.requestGenericList(PET_NAMES_1,this.onNamesLoaded);
         GenericListXtCommManager.requestGenericList(PET_NAMES_2,this.onNamesLoaded);
         this._petMC.bx.visible = !this._isFromRedemption;
         this._oopsPopup.visible = false;
         this._backBtn.visible = false;
         this._diamondBuyBtnGreen.visible = false;
         this._diamondBuyBtnRed.visible = false;
         this._adoptPetBtn.visible = false;
         this._oopsCostPopup.visible = false;
         this.addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         this._guiLayer.addChild(this._petMC);
         this._petMC.x = MainFrame.VIEW_WIDTH * 0.5;
         this._petMC.y = MainFrame.VIEW_HEIGHT * 0.5;
         DarkenManager.darken(this._petMC);
      }
      
      private function buildPetList() : void
      {
         if(this._currEnviroPetDefIds == null)
         {
            GenericListXtCommManager.requestGenericList(PET_DEF_LIST,this.onPetDefsLoaded);
         }
         else
         {
            this.setupCurrentPet();
            this.setupChoosePanel();
            this.buildPetWindows();
         }
      }
      
      private function setupCurrentPet() : void
      {
         var _loc1_:Array = null;
         if(this._petDefId == -1)
         {
            this._currIndex = Math.floor(Math.random() * this._currEnviroPetDefIds.length);
            this._petDefId = this._currEnviroPetDefIds[this._currIndex];
         }
         else
         {
            this._currIndex = this._currEnviroPetDefIds.indexOf(this._petDefId);
            if(this._currIndex == -1)
            {
               this._currEnviroPetDefIds.push(this._petDefId);
               this._currIndex = this._currEnviroPetDefIds.length - 1;
            }
         }
         this._currPetDef = PetManager.getPetDef(this._petDefId);
         if(this._currPetDef.isDiamond)
         {
            this._specialDef = DiamondXtCommManager.getDiamondDefByRefId(this._petDefId,DiamondXtCommManager.DIAMOND_TYPE_PET);
            this._nextBtn.sparkle.visible = this._backBtn.sparkle.visible = true;
         }
         else
         {
            if(!this._creatingWithoutChoosing)
            {
               this._specialDef = null;
            }
            this._nextBtn.sparkle.visible = this._backBtn.sparkle.visible = false;
         }
         if(this._petData)
         {
            _loc1_ = this._petData;
            this._catArray = PetManager.unpackPetBits(this._petData[0],this._petData[1],this._petData[2]);
         }
         else
         {
            this._catArray = PetManager.createRandomPet(this._petDefId);
            _loc1_ = PetManager.packPetBits(this._catArray);
         }
         this._currPet = PetManager.getGuiPet(0,_loc1_[0],_loc1_[1],_loc1_[2],this._currPetDef.type,this._currPetDef.title,this.onPetLoadedOnStage);
         LocalizationManager.updateToFit(this._choosePetPanel.petNameText,this._currPetDef.title);
         if(this._currPet.canGoInOcean())
         {
            this._background.gotoAndStop("ocean");
         }
         else
         {
            this._background.gotoAndStop("forest");
         }
         while(this._bigPetWindow.numChildren > 0)
         {
            this._bigPetWindow.removeChildAt(0);
         }
         this._bigPetWindow.addChild(this._currPet);
         this.openTab(COLOR_TAB_ID);
      }
      
      private function setupChoosePanel() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(this._isFromRedemption)
         {
            this._choosePetPanel.tag.visible = false;
         }
         else
         {
            if(this._specialDef)
            {
               if(PetManager.isPetAvailable(this._petDefId) && PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,this._currPetDef.type))
               {
                  this._currencyType = Item.GEM_CURRENCY;
                  this._specialDefCost = this._currPetDef.cost;
               }
               else
               {
                  this._currencyType = Item.DIAMOND_CURRENCY;
                  this._specialDefCost = this._specialDef.value;
               }
            }
            else
            {
               this._currencyType = Item.GEM_CURRENCY;
            }
            this._choosePetPanel.tag.visible = true;
            this._choosePetPanel.tag.txt.text = this._specialDef ? this._specialDefCost : this._currPetDef.cost;
            switch(this._currencyType)
            {
               case Item.GEM_CURRENCY:
                  this._gemCount = gMainFrame.clientInfo.gemCount;
                  _loc1_ = "red";
                  _loc2_ = "green";
                  break;
               case Item.TICKET_CURRENCY:
                  this._gemCount = gMainFrame.clientInfo.ticketCount;
                  _loc1_ = "ticketRed";
                  _loc2_ = "ticketGreen";
                  break;
               case Item.CRYSTAL_CURRENCY:
                  this._gemCount = gMainFrame.clientInfo.crystalCount;
                  _loc1_ = "earthRed";
                  _loc2_ = "earthGreen";
                  break;
               case Item.DIAMOND_CURRENCY:
                  this._gemCount = gMainFrame.clientInfo.diamondCount;
                  _loc1_ = "diamondRed";
                  _loc2_ = "diamondGreen";
            }
            if(this._gemCount < (this._specialDef ? this._specialDefCost : this._currPetDef.cost))
            {
               this._diamondBuyBtn = this._diamondBuyBtnRed;
               this._choosePetPanel.tag.gotoAndStop(_loc1_);
               this._choosePetPanel.tag.txt.textColor = "0x800000";
            }
            else
            {
               this._diamondBuyBtn = this._diamondBuyBtnGreen;
               this._choosePetPanel.tag.gotoAndStop(_loc2_);
               this._choosePetPanel.tag.txt.textColor = "0xffffff";
            }
         }
         if(this._creatingWithoutChoosing)
         {
            this.onNextBtn(null);
         }
      }
      
      private function buildPetWindows() : void
      {
         if(this._petWindows)
         {
            this._petWindows.destroy();
         }
         this._petWindows = new WindowGenerator();
         this._petWindows.init(3,3,this._currEnviroPetDefIds.length,2,2,2,ItemWindowAvatarOrPetSelect,this._currEnviroPetDefIds,"",{
            "mouseDown":this.chooseMouseDown,
            "mouseOver":this.chooseMouseOver,
            "mouseOut":this.chooseMouseOut
         },{
            "isPet":true,
            "selectedIndex":this._currIndex
         },this.onPetWindowsLoaded,false,false);
      }
      
      private function setupPetNames(param1:Array, param2:Array) : void
      {
         this._nameScroller1 = new GuiCarousel(this._namePanel.nameScroller1);
         this._nameScroller1.init(param1,this.name1Changed);
         this._nameScroller2 = new GuiCarousel(this._namePanel.nameScroller2);
         this._nameScroller2.init(param2,this.name2Changed);
         this.randomizeNames();
         this._namePanel.nameLever.visible = true;
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
      
      private function setupColorTables() : void
      {
         if(this._colorTableColor1)
         {
            this._settingsPanel.colorTableBlock.colors.removeChild(this._colorTableColor1);
            this._colorTableColor1.destroy();
         }
         if(this._colorTableColor2)
         {
            this._settingsPanel.colorTableBlock.colors.removeChild(this._colorTableColor2);
            this._colorTableColor2.destroy();
         }
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
         this._settingsPanel.colorTableBlock.colors.addChild(this._colorTableColor1);
         this._settingsPanel.colorTableBlock.colors.addChild(this._colorTableColor2);
         this._colorTableColor1.x = CT_X;
         this._colorTableColor1.y = CT_Y_TOP;
         this._colorTableColor2.x = CT_X;
         this._colorTableColor2.y = CT_Y_BOT;
      }
      
      private function addEventListeners() : void
      {
         this._petMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetFinderDown,false,0,true);
         this._closeBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseDown,false,0,true);
         this._adoptPetBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetOrDiamondBtn,false,0,true);
         this._diamondBuyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetOrDiamondBtn,false,0,true);
         this._namePanel.nameLever.addEventListener(MouseEvent.MOUSE_DOWN,this.onLeverDown,false,0,true);
         this._backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn,false,0,true);
         this._nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn,false,0,true);
         this._oopsPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onOopsPopupClose,false,0,true);
         this._oopsCostPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose,false,0,true);
         this._settingsPanel.eyesDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn,false,0,true);
         this._settingsPanel.traitsDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn,false,0,true);
         this._settingsPanel.colorsDownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._petMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPetFinderDown);
         this._closeBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseDown);
         this._adoptPetBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetOrDiamondBtn);
         this._diamondBuyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAdoptPetOrDiamondBtn);
         this._namePanel.nameLever.removeEventListener(MouseEvent.MOUSE_DOWN,this.onLeverDown);
         this._backBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBackBtn);
         this._nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNextBtn);
         this._oopsPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onOopsPopupClose);
         this._oopsCostPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCostPopupClose);
         this._settingsPanel.eyesDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
         this._settingsPanel.traitsDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
         this._settingsPanel.colorsDownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorsEyesTraitsDownBtn);
      }
      
      private function onPetFinderDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.close();
      }
      
      private function onAdoptPetOrDiamondBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._isFromRedemption)
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14781),true,this.onAdoptYesBtn);
            return;
         }
         var _loc2_:Object = PetManager.getPetDef(this._petDefId);
         var _loc3_:int = this._specialDef ? this._specialDefCost : int(_loc2_.cost);
         if(!gMainFrame.userInfo.isMember && Boolean(_loc2_.isMember))
         {
            UpsellManager.displayPopup(UpsellManager.PETS,"buyMemberPet");
         }
         else if(Boolean(this._specialDef) && PetManager.isPetAvailable(this._petDefId))
         {
            if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc2_.type))
            {
               new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14782,_loc2_.title.toLowerCase(),_loc2_.cost),true,this.onBuyInDiamondShopConfirm,_loc2_.cost);
            }
            else
            {
               new SBOkPopup(this._guiLayer,LocalizationManager.translateIdOnly(15813),true,this.onOkLandPet);
            }
         }
         else if(this._gemCount < _loc3_)
         {
            if(this._specialDef)
            {
               UpsellManager.displayPopup(UpsellManager.EXTRA_DIAMONDS_AS_MEMBER,"extraDiamonds");
            }
            else
            {
               DarkenManager.darken(this._oopsCostPopup);
               if(this._currencyType == Item.GEM_CURRENCY)
               {
                  this._oopsCostPopup.currency.gotoAndStop("gems");
               }
               else if(this._currencyType == Item.TICKET_CURRENCY)
               {
                  this._oopsCostPopup.currency.gotoAndStop("tickets");
               }
               else if(this._currencyType == Item.CRYSTAL_CURRENCY)
               {
                  this._oopsCostPopup.currency.gotoAndStop("earth");
               }
               else if(this._currencyType == Item.DIAMOND_CURRENCY)
               {
                  this._oopsCostPopup.currency.gotoAndStop("diamonds");
               }
               this._oopsCostPopup.gemsTxt.text = this._gemCount;
               this._oopsCostPopup.costTxt.text = _loc3_;
               this._oopsCostPopup.needTxt.text = _loc3_ - this._gemCount;
               this._oopsCostPopup.visible = true;
            }
         }
         else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdOnly(14783),true,this.confirmRecycle);
         }
         else if(this._specialDef)
         {
            GuiManager.showDiamondConfirmation(_loc3_,this.onAdoptYesBtn);
         }
         else
         {
            new SBYesNoPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(this._specialDef ? 14784 : 14785,Utility.convertNumberToString(_loc3_)),true,this.onAdoptYesBtn);
         }
      }
      
      private function onLeverDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._namePanel.nameLever.currentFrameLabel == "_up")
         {
            this._nameScroller2.soundsEnabled = false;
            AJAudio.playRandomLever();
            this._namePanel.nameLever.gotoAndPlay("_play");
            this._nameScroller1.pickRandomItem();
            this._nameScroller2.pickRandomItem();
            this._nameScroller2.soundsEnabled = true;
         }
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._bgTween)
         {
            this._bgTween.end();
         }
         if(this._petTween)
         {
            this._petTween.end();
         }
         if(this._panelTween)
         {
            this._panelTween.end();
         }
         var _loc2_:Function = Exponential.easeOut;
         var _loc3_:Number = 1.5;
         if(this._screenPositionIndex == 1)
         {
            this._bgTween = new GTween(this._background,_loc3_,{"x":this._background.x + 432},{"ease":_loc2_},{"MotionBlurEnabled":true});
            this._petTween = new GTween(this._bigPetWindow,_loc3_,{"x":this._bigPetWindow.x + 407},{"ease":_loc2_});
            this._panelTween = new GTween(this._createPanelCont,_loc3_,{"x":this._createPanelCont.x + 485},{"ease":_loc2_},{"MotionBlurEnabled":true});
            this._backBtn.visible = false;
         }
         else
         {
            this._panelTween = new GTween(this._createPanelCont,_loc3_,{"x":this._createPanelCont.x + 872},{"ease":_loc2_},{"MotionBlurEnabled":true});
            if(this._creatingWithoutChoosing)
            {
               this._backBtn.visible = false;
            }
            this._nextBtn.visible = true;
         }
         --this._screenPositionIndex;
         this._diamondBuyBtn.visible = false;
         this._adoptPetBtn.visible = false;
      }
      
      private function onNextBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this._bgTween)
         {
            this._bgTween.end();
         }
         if(this._petTween)
         {
            this._petTween.end();
         }
         if(this._panelTween)
         {
            this._panelTween.end();
         }
         var _loc2_:Number = 1.5;
         var _loc3_:Function = Exponential.easeOut;
         if(this._screenPositionIndex == 0)
         {
            if(param1 == null)
            {
               this._background.x -= 432;
               this._bigPetWindow.x -= 407;
               this._createPanelCont.x -= 485;
            }
            else
            {
               this._bgTween = new GTween(this._background,_loc2_,{"x":this._background.x - 432},{"ease":_loc3_},{"MotionBlurEnabled":true});
               this._petTween = new GTween(this._bigPetWindow,_loc2_,{"x":this._bigPetWindow.x - 407},{"ease":_loc3_});
               this._panelTween = new GTween(this._createPanelCont,_loc2_,{"x":this._createPanelCont.x - 485},{"ease":_loc3_},{"MotionBlurEnabled":true});
            }
         }
         else
         {
            this._panelTween = new GTween(this._createPanelCont,_loc2_,{"x":this._createPanelCont.x - 872},{"ease":_loc3_},{"MotionBlurEnabled":true});
         }
         ++this._screenPositionIndex;
         if(this._screenPositionIndex == 2)
         {
            this._nextBtn.visible = false;
            if(Boolean(this._currPetDef.isDiamond) && !PetManager.isPetAvailable(this._petDefId))
            {
               this._diamondBuyBtn.visible = true;
            }
            else
            {
               this._adoptPetBtn.visible = true;
            }
            this._backBtn.visible = true;
         }
         else
         {
            this._nextBtn.visible = true;
            if(!this._creatingWithoutChoosing)
            {
               this._backBtn.visible = true;
            }
         }
      }
      
      private function onOopsPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._oopsPopup.visible = false;
      }
      
      private function onCostPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(this._oopsCostPopup);
         this._oopsCostPopup.visible = false;
      }
      
      private function onColorsEyesTraitsDownBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == this._settingsPanel.colorsDownBtn.name)
         {
            this.openTab(COLOR_TAB_ID);
         }
         else if(param1.currentTarget.name == this._settingsPanel.traitsDownBtn.name)
         {
            this.openTab(TRAITS_TAB_ID);
         }
         else if(param1.currentTarget.name == this._settingsPanel.eyesDownBtn.name)
         {
            this.openTab(EYE_TAB_ID);
         }
      }
      
      private function chooseMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currIndex != param1.currentTarget.index)
         {
            ItemWindowAvatarOrPetSelect(this._petWindows.bg.getChildAt(this._currIndex)).deselect();
            this._currIndex = param1.currentTarget.index;
            this._petDefId = this._currEnviroPetDefIds[this._currIndex];
            if(param1.currentTarget.currWindow.currentFrameLabel != "down")
            {
               param1.currentTarget.currWindow.gotoAndStop("down");
            }
            param1.currentTarget.setupLayers();
            this.setupCurrentPet();
            this.setupChoosePanel();
         }
      }
      
      private function chooseMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = "";
         if(param1.currentTarget.currWindow.currentFrameLabel == _loc2_ + "down")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "downMouse");
         }
         else if(param1.currentTarget.currWindow.currentFrameLabel != _loc2_ + "downMouse")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "over");
         }
         param1.currentTarget.setupLayers();
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function chooseMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:String = "";
         if(param1.currentTarget.currWindow.currentFrameLabel == _loc2_ + "downMouse")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "down");
         }
         else if(param1.currentTarget.currWindow.currentFrameLabel != _loc2_ + "down")
         {
            param1.currentTarget.currWindow.gotoAndStop(_loc2_ + "up");
         }
         param1.currentTarget.setupLayers();
      }
      
      private function colorEyesTraitsOver(param1:MouseEvent) : void
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
      
      private function colorEyesTraitsOut(param1:MouseEvent) : void
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
      
      private function onColorEyesTraitsDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:Array = null;
         var _loc4_:Array = null;
         var _loc5_:* = 0;
         var _loc6_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._settingsPanel.colorTableBlock.eyes["win" + param1.currentTarget.index].name)
         {
            this._settingsPanel.colorTableBlock.eyes["win" + (this._currEyeIndex - 1)].cir.gotoAndStop("up");
            this._currEyeIndex = param1.currentTarget.index + 1;
            param1.currentTarget.cir.gotoAndStop("down");
            AJAudio.playSubMenuBtnClick();
            this._catIndexArray[this._eyes[1]] = this._currEyeIndex;
            this._catArray[this._eyes[1]] = this._currEyeIndex - 2;
            this._currPet.colorMyItem(this._eyes[1],this._eyes[this._currEyeIndex],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
            _loc3_ = PetManager.packPetBits(this._catArray);
            this._currPet.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
         }
         else if(param1.currentTarget.index < 4)
         {
            _loc5_ = 0;
            if(param1.currentTarget.name == this._settingsPanel.colorTableBlock.traits["lBtn" + param1.currentTarget.index].name)
            {
               _loc5_--;
            }
            else if(param1.currentTarget.name == this._settingsPanel.colorTableBlock.traits["rBtn" + param1.currentTarget.index].name)
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
                  this._currPet.colorMyItem(_loc4_[1],_loc4_[_loc6_],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                  this._catArray[_loc4_[1]] = _loc6_ - 2;
                  _loc3_ = PetManager.packPetBits(this._catArray);
                  this._currPet.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
                  this["_currAtt" + param1.currentTarget.index + "Index"] = _loc6_;
               }
            }
         }
      }
      
      private function openTab(param1:int) : void
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
      }
      
      private function openColorTableColorsTab() : void
      {
         this._settingsPanel.traitsTabUp.visible = false;
         this._settingsPanel.eyesTabUp.visible = false;
         this._settingsPanel.colorsTabUp.visible = true;
         this._settingsPanel.colorTableBlock.colors.visible = true;
         this._settingsPanel.colorTableBlock.eyes.visible = false;
         this._settingsPanel.colorTableBlock.traits.visible = false;
      }
      
      private function openTraitsOrEyesTab(param1:Boolean) : void
      {
         var _loc2_:MovieClip = null;
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         if(param1)
         {
            this._settingsPanel.colorsTabUp.visible = false;
            this._settingsPanel.eyesTabUp.visible = false;
            this._settingsPanel.traitsTabUp.visible = true;
            this._settingsPanel.colorTableBlock.colors.visible = false;
            this._settingsPanel.colorTableBlock.eyes.visible = false;
            this._settingsPanel.colorTableBlock.traits.visible = true;
            _loc3_ = 1;
            while(_loc3_ < 4)
            {
               _loc2_ = this._settingsPanel.colorTableBlock.traits["win" + _loc3_];
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
               this._settingsPanel.colorTableBlock.traits["traits" + _loc3_ + "Txt"].text = "";
               _loc4_ = this["_att" + _loc3_];
               if((Boolean(_loc4_)) && _loc4_.length > 0)
               {
                  LocalizationManager.translateId(this._settingsPanel.colorTableBlock.traits["traits" + _loc3_ + "Txt"],_loc4_[0]);
                  if(_loc4_.length > this["_currAtt" + _loc3_ + "Index"])
                  {
                     this._currPet.colorMyItem(this["_att" + _loc3_][1],_loc4_[this["_currAtt" + _loc3_ + "Index"]],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                     _loc2_.iconLayer.addChild(_loc4_[this["_currAtt" + _loc3_ + "Index"]]);
                     this._settingsPanel.colorTableBlock.traits["lBtn" + _loc3_].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     this._settingsPanel.colorTableBlock.traits["rBtn" + _loc3_].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     this._settingsPanel.colorTableBlock.traits["rBtn" + _loc3_].index = _loc3_;
                     this._settingsPanel.colorTableBlock.traits["lBtn" + _loc3_].index = _loc3_;
                  }
               }
               _loc3_++;
            }
         }
         else
         {
            this._settingsPanel.colorsTabUp.visible = false;
            this._settingsPanel.eyesTabUp.visible = true;
            this._settingsPanel.traitsTabUp.visible = false;
            this._settingsPanel.colorTableBlock.colors.visible = false;
            this._settingsPanel.colorTableBlock.traits.visible = false;
            this._settingsPanel.colorTableBlock.eyes.visible = true;
            _loc3_ = 1;
            while(_loc3_ < 7)
            {
               _loc2_ = this._settingsPanel.colorTableBlock.eyes["win" + _loc3_];
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
                     this._currPet.colorMyItem(this._eyes[1],this._eyes[_loc3_ + 1],this._colors1[this._currColor1Index][0],this._colors1[this._currColor1Index][1],this._colors1[this._currColor1Index][2],this._colors2[this._currColor2Index][0],this._colors2[this._currColor2Index][1],this._colors2[this._currColor2Index][2]);
                     _loc2_.iconLayer.addChild(this._eyes[_loc3_ + 1]);
                     if(!_loc2_.hasEventListener(MouseEvent.MOUSE_DOWN))
                     {
                        _loc2_.addEventListener(MouseEvent.MOUSE_DOWN,this.onColorEyesTraitsDown,false,0,true);
                     }
                     if(!_loc2_.hasEventListener(MouseEvent.ROLL_OVER))
                     {
                        _loc2_.addEventListener(MouseEvent.ROLL_OVER,this.colorEyesTraitsOver,false,0,true);
                     }
                     if(!_loc2_.hasEventListener(MouseEvent.ROLL_OUT))
                     {
                        _loc2_.addEventListener(MouseEvent.ROLL_OUT,this.colorEyesTraitsOut,false,0,true);
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
      
      private function close() : void
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
   }
}

