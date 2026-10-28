package gui
{
   import avatar.AvatarManager;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBYesNoPopup;
   import currency.UserCurrency;
   import diamond.DiamondXtCommManager;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Exponential;
   import gskinner.motion.plugins.MotionBlurPlugin;
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
      
      private var _gemCount:*;
      
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
      
      public function init(param1:int = -1, param2:Function = null, param3:Boolean = false, param4:Array = null, param5:int = 0, param6:Object = null, param7:int = 0, param8:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/petFinder");
         _guiLayer = GuiManager.guiLayer;
         _closeCallback = param2;
         _petDefId = param1;
         _isFromRedemption = param3;
         _petData = param4;
         _currencyType = param5;
         _specialDef = param6;
         _shopId = param7;
         _creatingWithoutChoosing = _isFromRedemption || _specialDef || param8;
         MotionBlurPlugin.install();
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(4058,onMediaItemLoaded);
      }
      
      public function destroy() : void
      {
         removeEventListeners();
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         if(_nameScroller1)
         {
            _nameScroller1.destroy();
            _nameScroller1 = null;
         }
         if(_nameScroller2)
         {
            _nameScroller2.destroy();
            _nameScroller2 = null;
         }
         if(_petWindows)
         {
            _petWindows.destroy();
            _petWindows = null;
         }
         if(_scrollBar)
         {
            _scrollBar.destroy();
            _scrollBar = null;
         }
         if(_currPet)
         {
            _currPet.destroy();
            _currPet = null;
         }
         if(_colorTableColor1)
         {
            _colorTableColor1.destroy();
            _colorTableColor1 = null;
         }
         if(_colorTableColor2)
         {
            _colorTableColor2.destroy();
            _colorTableColor2 = null;
         }
         if(_loadingMediaHelper)
         {
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
         }
         if(_petInventory)
         {
            _petInventory.destroy();
            _petInventory = null;
         }
         if(_bgTween)
         {
            _bgTween.end();
            _bgTween = null;
         }
         if(_petTween)
         {
            _petTween.end();
            _petTween = null;
         }
         if(_panelTween)
         {
            _panelTween.end();
            _panelTween = null;
         }
         _closeCallback = null;
         DarkenManager.unDarken(_petMC);
         _guiLayer.removeChild(_petMC);
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _petMC = MovieClip(param1.getChildAt(0));
            _petMC.x = 900 * 0.5;
            _petMC.y = 550 * 0.5;
            _oopsPopup = _petMC.oopsPopup;
            _createPanelCont = _petMC.createPanel.panelCont;
            _choosePetPanel = _createPanelCont.choosePet;
            _settingsPanel = _createPanelCont.customSettingsPanel.petSettings;
            _namePanel = _createPanelCont.createAName;
            _diamondBuyBtnGreen = _petMC.diamond_buy_btn_green;
            _diamondBuyBtnRed = _petMC.diamond_buy_btn_red;
            _adoptPetBtn = _petMC.adoptPetBtn;
            _backBtn = _petMC.back_btn;
            _nextBtn = _petMC.next_btn;
            _bigPetWindow = _petMC.petWindow;
            _closeBtn = _petMC.bx;
            _background = _petMC.bg;
            _oopsCostPopup = _petMC.oopsCostPopup;
            _diamondBuyBtn = _diamondBuyBtnGreen;
            startPetCreatorSetup();
         }
      }
      
      private function onNamesLoaded(param1:int, param2:Array) : void
      {
         var _loc6_:Array = null;
         var _loc5_:String = null;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:Object = [];
         var _loc3_:int = -1;
         switch(param1 - 205)
         {
            case 0:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc4_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc3_ = 1;
               }
               else
               {
                  _loc4_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc3_ = 0;
               }
               break;
            case 1:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc4_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc3_ = 0;
                  break;
               }
               _loc4_ = {
                  "names":[],
                  "femNames":[],
                  "locIds":[]
               };
               _loc3_ = 1;
         }
         if(_loc3_ != -1)
         {
            _loc7_ = 0;
            while(_loc7_ < param2.length)
            {
               if(_loc3_ == 0)
               {
                  _loc6_ = LocalizationManager.translateIdOnly(param2[_loc7_]).split("$");
                  _loc5_ = _loc6_[0];
                  _loc8_ = Utility.findIndexToInsert(_loc4_.names,_loc5_);
                  _loc4_.names.splice(_loc8_,0,_loc5_);
                  if(_loc6_[1])
                  {
                     _loc4_.types.splice(_loc8_,0,_loc6_[1]);
                  }
                  else
                  {
                     _loc4_.types.splice(_loc8_,0,"m");
                  }
               }
               else if(_loc3_ == 1)
               {
                  _loc6_ = LocalizationManager.translateIdOnly(param2[_loc7_]).split("$");
                  _loc5_ = _loc6_[0].toLowerCase();
                  _loc8_ = Utility.findIndexToInsert(_loc4_.names,_loc5_);
                  _loc4_.names.splice(_loc8_,0,_loc5_);
                  if(_loc6_[1])
                  {
                     _loc4_.femNames.splice(_loc8_,0,_loc6_[1].toLowerCase());
                  }
                  else
                  {
                     _loc4_.femNames.splice(_loc8_,0,_loc5_);
                  }
               }
               _loc4_.locIds.splice(_loc8_,0,param2[_loc7_]);
               _loc7_++;
            }
            _petNames[_loc3_] = _loc4_;
         }
         if(_petNames[0] != -1 && _petNames[1] != -1)
         {
            setupPetNames(_petNames[0].names,_petNames[1].names);
         }
      }
      
      private function name1Changed() : void
      {
         if(_nameScroller1 && _nameScroller2 && _nameScroller1.selectedContentItem && _nameScroller2.selectedContentItem)
         {
            _namePanel.aml_name_txt.text = _nameScroller1.selectedContentItem + _nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(_namePanel.aml_name_txt,_namePanel.aml_name_txt.text);
            if(_petNames[0].types[_nameScroller1.contentItemIndex] == "m")
            {
               if(_nameScroller2.contentItems != _petNames[1].names)
               {
                  _nameScroller2.contentItems = _petNames[1].names;
               }
            }
            else if(_nameScroller2.contentItems != _petNames[1].femNames && _petNames[1].femNames[0])
            {
               _nameScroller2.contentItems = _petNames[1].femNames;
            }
            if(_nameScroller2.soundsEnabled)
            {
               _nameScroller2.soundsEnabled = false;
               _nameScroller2.spinToIndex(_nameScroller2.contentItemIndex,true);
               _nameScroller2.soundsEnabled = true;
            }
            else
            {
               _nameScroller2.spinToIndex(_nameScroller2.contentItemIndex,true);
            }
         }
         if(_nameScroller1 && !_nameScroller1.soundsEnabled)
         {
            _nameScroller1.soundsEnabled = true;
         }
      }
      
      private function name2Changed() : void
      {
         if(_nameScroller1 && _nameScroller2 && _nameScroller1.selectedContentItem && _nameScroller2.selectedContentItem)
         {
            _namePanel.aml_name_txt.text = _nameScroller1.selectedContentItem + _nameScroller2.selectedContentItem;
            LocalizationManager.updateToFit(_namePanel.aml_name_txt,_namePanel.aml_name_txt.text);
         }
         if(_nameScroller2 && !_nameScroller2.soundsEnabled)
         {
            _nameScroller2.soundsEnabled = true;
         }
      }
      
      private function onPetDefsLoaded(param1:int, param2:Array, param3:Function) : void
      {
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         _currEnviroPetDefIds = [];
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = PetManager.getPetDef(param2[_loc5_]);
            if((_loc4_.isDiamond || PetManager.isPetAvailable(param2[_loc5_])) && PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc4_.type))
            {
               _currEnviroPetDefIds.push(param2[_loc5_]);
            }
            _loc5_++;
         }
         setupCurrentPet();
         setupChoosePanel();
         buildPetWindows();
      }
      
      private function onPetWindowsLoaded() : void
      {
         _choosePetPanel.itemWindow.addChild(_petWindows);
         _scrollBar = new SBScrollbar();
         _scrollBar.init(_petWindows,_petWindows.width,_petWindows.boxHeight * 3 + 6,12,"scrollbar2",_petWindows.boxHeight + 2,0);
         _scrollBar.scrollToElement(_currIndex / 3,true);
      }
      
      private function onPetLoadedOnStage(param1:MovieClip, param2:GuiPet) : void
      {
         var _loc8_:GlowFilter = null;
         _colors1 = param1.getCol1();
         _colors2 = param1.getCol2();
         _eyes = param1.getEyes();
         _att1 = param1.getAtt1();
         _att2 = param1.getAtt2();
         _att3 = param1.getAtt3();
         var _loc9_:int = 2;
         _loc9_ = 2;
         while(_loc9_ < _eyes.length)
         {
            _loc8_ = new GlowFilter(0,1,2,2,2);
            _eyes[_loc9_].filters = [_loc8_];
            _loc9_++;
         }
         _loc9_ = 2;
         while(_loc9_ < _att1.length)
         {
            _loc8_ = new GlowFilter(0,1,2,2,2);
            _att1[_loc9_].filters = [_loc8_];
            _loc9_++;
         }
         _loc9_ = 2;
         while(_loc9_ < _att2.length)
         {
            _loc8_ = new GlowFilter(0,1,2,2,2);
            _att2[_loc9_].filters = [_loc8_];
            _loc9_++;
         }
         _loc9_ = 2;
         while(_loc9_ < _att3.length)
         {
            _loc8_ = new GlowFilter(0,1,2,2,2);
            _att3[_loc9_].filters = [_loc8_];
            _loc9_++;
         }
         _catIndexArray = [];
         var _loc4_:int = int(_currPet.getLBits());
         var _loc7_:int = int(_currPet.getUBits());
         var _loc10_:int = _loc4_ >> 8 & 0x3F;
         _catIndexArray[1] = _loc10_;
         var _loc12_:int = _loc4_ >> 14 & 0x1F;
         _catIndexArray[2] = _loc12_;
         var _loc11_:int = _loc4_ >> 19 & 0x1F;
         _catIndexArray[3] = _loc11_;
         var _loc14_:int = (_loc4_ >> 24 & 0x0F) + 2;
         _catIndexArray[4] = _loc14_;
         var _loc13_:int = (_loc4_ >> 28 & 0x0F) + 2;
         _catIndexArray[5] = _loc13_;
         var _loc5_:int = (_loc7_ & 0x0F) + 2;
         _catIndexArray[6] = _loc5_;
         var _loc6_:int = (_loc7_ >> 4 & 0x0F) + 2;
         _catIndexArray[7] = _loc6_;
         var _loc3_:int = (_loc7_ >> 8 & 0x0F) + 2;
         _catIndexArray[8] = _loc3_;
         _currColor1Index = _loc10_;
         _currColor2Index = _loc12_;
         _currEyeIndex = _eyes.length - 1 < _catIndexArray[_eyes[1]] ? _eyes.length - 1 : _catIndexArray[_eyes[1]];
         _currAtt1Index = _att1.length - 1 < _catIndexArray[_att1[1]] ? _att1.length - 1 : _catIndexArray[_att1[1]];
         _currAtt2Index = _att2.length - 1 < _catIndexArray[_att2[1]] ? _att2.length - 1 : _catIndexArray[_att2[1]];
         _currAtt3Index = _att3.length - 1 < _catIndexArray[_att3[1]] ? _att3.length - 1 : _catIndexArray[_att3[1]];
         setupColorTables();
         _currPet.scaleX = 5;
         _currPet.scaleY = 5;
         _currPet.x = 20;
         _currPet.y = 110;
      }
      
      private function onColorChanged(param1:int, param2:int) : void
      {
         if(param1 == 0)
         {
            _currColor1Index = param2;
            _catIndexArray[1] = _currColor1Index;
            _catArray[1] = _currColor1Index;
         }
         else
         {
            _currColor2Index = param2;
            _catIndexArray[2] = _currColor2Index;
            _catArray[2] = _currColor2Index;
         }
         var _loc3_:Array = PetManager.packPetBits(_catArray);
         _currPet.updateAllBits(_loc3_[0],_loc3_[1],_loc3_[2]);
      }
      
      private function onAdoptYesBtn(param1:Object = null) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         if(param1 == null || param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            _loc3_ = PetManager.packPetBits(_catArray);
            _loc2_ = int(LocalizationManager.isCurrLanguageReversed() ? _petNames[1].locIds[_nameScroller2.contentItemIndex] : _petNames[0].locIds[_nameScroller1.contentItemIndex]);
            _loc4_ = int(LocalizationManager.isCurrLanguageReversed() ? _petNames[0].locIds[_nameScroller1.contentItemIndex] : _petNames[1].locIds[_nameScroller2.contentItemIndex]);
            if(_specialDef && !PetManager.isPetAvailable(_petDefId))
            {
               if(_shopId == 0)
               {
                  _shopId = 214;
               }
               PetXtCommManager.sendPetShopBuyRequest(_shopId,_specialDef.defId,_loc3_[0],_loc3_[1],_loc3_[2],_loc2_,_loc4_,onCreateResponse,_isFromRedemption);
            }
            else
            {
               PetXtCommManager.sendPetCreateRequest(_loc3_[0],_loc3_[1],_loc3_[2],_loc2_,_loc4_,onCreateResponse,_isFromRedemption);
            }
         }
         else
         {
            SBTracker.push();
            SBTracker.trackPageview("/game/play/popup/pet/petFinder/didNotKeep",-1,1);
         }
      }
      
      private function onBuyInDiamondShopConfirm(param1:Object) : void
      {
         if(param1.status)
         {
            if(_gemCount < param1.passback)
            {
               DarkenManager.darken(_oopsCostPopup);
               _oopsCostPopup.currency.gotoAndStop("gems");
               _oopsCostPopup.gemsTxt.text = _gemCount;
               _oopsCostPopup.costTxt.text = param1.passback;
               _oopsCostPopup.needTxt.text = param1.passback - _gemCount;
               _oopsCostPopup.visible = true;
            }
            else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14783),true,confirmRecycle);
            }
            else
            {
               onAdoptYesBtn(param1);
            }
         }
         else
         {
            close();
         }
      }
      
      private function onOkLandPet(param1:MouseEvent) : void
      {
         SBOkPopup.destroyInParentChain(param1.target.parent);
         close();
      }
      
      private function confirmRecycle(param1:Object) : void
      {
         if(param1.status)
         {
            DarkenManager.showLoadingSpiral(true);
            _petInventory = new PetInventory();
            _petInventory.init(onPetInventoryClose,true);
         }
      }
      
      private function onPetInventoryClose(param1:Boolean) : void
      {
         _petInventory = null;
         if(param1)
         {
            if(_specialDef)
            {
               GuiManager.showDiamondConfirmation(_specialDefCost,onAdoptYesBtn);
            }
            else
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14785,Utility.convertNumberToString(PetManager.getPetDef(_petDefId).cost)),true,onAdoptYesBtn);
            }
         }
      }
      
      private function onCreateResponse() : void
      {
         DarkenManager.showLoadingSpiral(false);
         SBTracker.push();
         SBTracker.trackPageview("/game/play/popup/pet/petFinder/keep");
         GuiManager.resetPetWindowListAndUpdateBtns();
         close();
      }
      
      private function startPetCreatorSetup() : void
      {
         buildPetList();
         _petNames = [-1,-1];
         GenericListXtCommManager.requestGenericList(205,onNamesLoaded);
         GenericListXtCommManager.requestGenericList(206,onNamesLoaded);
         _petMC.bx.visible = !_isFromRedemption;
         _oopsPopup.visible = false;
         _backBtn.visible = false;
         _diamondBuyBtnGreen.visible = false;
         _diamondBuyBtnRed.visible = false;
         _adoptPetBtn.visible = false;
         _oopsCostPopup.visible = false;
         addEventListeners();
         DarkenManager.showLoadingSpiral(false);
         _guiLayer.addChild(_petMC);
         _petMC.x = 900 * 0.5;
         _petMC.y = 550 * 0.5;
         DarkenManager.darken(_petMC);
      }
      
      private function buildPetList() : void
      {
         if(_currEnviroPetDefIds == null)
         {
            GenericListXtCommManager.requestGenericList(312,onPetDefsLoaded);
         }
         else
         {
            setupCurrentPet();
            setupChoosePanel();
            buildPetWindows();
         }
      }
      
      private function setupCurrentPet() : void
      {
         var _loc1_:Array = null;
         if(_petDefId == -1)
         {
            _currIndex = Math.floor(Math.random() * _currEnviroPetDefIds.length);
            _petDefId = _currEnviroPetDefIds[_currIndex];
         }
         else
         {
            _currIndex = _currEnviroPetDefIds.indexOf(_petDefId);
            if(_currIndex == -1)
            {
               _currEnviroPetDefIds.push(_petDefId);
               _currIndex = _currEnviroPetDefIds.length - 1;
            }
         }
         _currPetDef = PetManager.getPetDef(_petDefId);
         if(_currPetDef.isDiamond)
         {
            _specialDef = DiamondXtCommManager.getDiamondDefByRefId(_petDefId,2);
            _nextBtn.sparkle.visible = _backBtn.sparkle.visible = true;
         }
         else
         {
            if(!_creatingWithoutChoosing)
            {
               _specialDef = null;
            }
            _nextBtn.sparkle.visible = _backBtn.sparkle.visible = false;
         }
         if(_petData)
         {
            _loc1_ = _petData;
            _catArray = PetManager.unpackPetBits(_petData[0],_petData[1],_petData[2]);
         }
         else
         {
            _catArray = PetManager.createRandomPet(_petDefId);
            _loc1_ = PetManager.packPetBits(_catArray);
         }
         _currPet = PetManager.getGuiPet(0,_loc1_[0],_loc1_[1],_loc1_[2],_currPetDef.type,_currPetDef.title,onPetLoadedOnStage);
         LocalizationManager.updateToFit(_choosePetPanel.petNameText,_currPetDef.title);
         if(_currPet.canGoInOcean())
         {
            _background.gotoAndStop("ocean");
         }
         else
         {
            _background.gotoAndStop("forest");
         }
         while(_bigPetWindow.numChildren > 0)
         {
            _bigPetWindow.removeChildAt(0);
         }
         _bigPetWindow.addChild(_currPet);
         openTab(0);
      }
      
      private function setupChoosePanel() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         if(_isFromRedemption)
         {
            _choosePetPanel.tag.visible = false;
         }
         else
         {
            if(_specialDef)
            {
               if(PetManager.isPetAvailable(_petDefId) && PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_currPetDef.type))
               {
                  _currencyType = 0;
                  _specialDefCost = _currPetDef.cost;
               }
               else
               {
                  _currencyType = 3;
                  _specialDefCost = _specialDef.value;
               }
            }
            else
            {
               _currencyType = 0;
            }
            _choosePetPanel.tag.visible = true;
            _choosePetPanel.tag.txt.text = _specialDef ? _specialDefCost : _currPetDef.cost;
            _gemCount = UserCurrency.getCurrency(_currencyType);
            if(_gemCount == null)
            {
               throw new Error("Unable to get currency for currencyType=" + _currencyType);
            }
            switch(_currencyType)
            {
               case 0:
                  _loc1_ = "red";
                  _loc2_ = "green";
                  break;
               case 1:
                  _loc1_ = "ticketRed";
                  _loc2_ = "ticketGreen";
                  break;
               case 2:
                  _loc1_ = "earthRed";
                  _loc2_ = "earthGreen";
                  break;
               case 3:
                  _loc1_ = "diamondRed";
                  _loc2_ = "diamondGreen";
            }
            if(_gemCount < (_specialDef ? _specialDefCost : _currPetDef.cost))
            {
               _diamondBuyBtn = _diamondBuyBtnRed;
               _choosePetPanel.tag.gotoAndStop(_loc1_);
               _choosePetPanel.tag.txt.textColor = "0x800000";
            }
            else
            {
               _diamondBuyBtn = _diamondBuyBtnGreen;
               _choosePetPanel.tag.gotoAndStop(_loc2_);
               _choosePetPanel.tag.txt.textColor = "0xffffff";
            }
         }
         if(_creatingWithoutChoosing)
         {
            onNextBtn(null);
         }
      }
      
      private function buildPetWindows() : void
      {
         if(_petWindows)
         {
            _petWindows.destroy();
         }
         _petWindows = new WindowGenerator();
         _petWindows.init(3,3,_currEnviroPetDefIds.length,2,2,2,ItemWindowAvatarOrPetSelect,_currEnviroPetDefIds,"",{
            "mouseDown":chooseMouseDown,
            "mouseOver":chooseMouseOver,
            "mouseOut":chooseMouseOut
         },{
            "isPet":true,
            "selectedIndex":_currIndex
         },onPetWindowsLoaded,false,false);
      }
      
      private function setupPetNames(param1:Array, param2:Array) : void
      {
         _nameScroller1 = new GuiCarousel(_namePanel.nameScroller1);
         _nameScroller1.init(param1,name1Changed);
         _nameScroller2 = new GuiCarousel(_namePanel.nameScroller2);
         _nameScroller2.init(param2,name2Changed);
         randomizeNames();
         _namePanel.nameLever.visible = true;
      }
      
      private function randomizeNames() : void
      {
         _nameScroller1.soundsEnabled = false;
         _nameScroller2.soundsEnabled = false;
         _nameScroller1.pickRandomItem(true);
         _nameScroller2.pickRandomItem(true);
         _nameScroller1.soundsEnabled = true;
         _nameScroller2.soundsEnabled = true;
      }
      
      private function setupColorTables() : void
      {
         var _loc5_:int = 0;
         if(_colorTableColor1)
         {
            _settingsPanel.colorTableBlock.colors.removeChild(_colorTableColor1);
            _colorTableColor1.destroy();
         }
         if(_colorTableColor2)
         {
            _settingsPanel.colorTableBlock.colors.removeChild(_colorTableColor2);
            _colorTableColor2.destroy();
         }
         var _loc2_:Array = new Array(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19);
         var _loc4_:Array = [];
         var _loc3_:Array = [];
         var _loc1_:int = Math.max(_colors1.length,_colors2.length);
         _loc5_ = 0;
         while(_loc5_ < _loc1_)
         {
            if(_loc5_ < _colors1.length)
            {
               _loc4_[_loc5_] = (_colors1[_loc5_][0] << 16) + (_colors1[_loc5_][1] << 8) + _colors1[_loc5_][2];
            }
            if(_loc5_ < _colors2.length)
            {
               _loc3_[_loc5_] = (_colors2[_loc5_][0] << 16) + (_colors2[_loc5_][1] << 8) + _colors2[_loc5_][2];
            }
            _loc5_++;
         }
         _colorTableColor1 = new ColorTable();
         _colorTableColor1.init(0,230,124,5,4,_loc4_,_loc2_,_currColor1Index,onColorChanged);
         _colorTableColor2 = new ColorTable();
         _colorTableColor2.init(1,230,124,5,4,_loc3_,_loc2_,_currColor2Index,onColorChanged);
         _settingsPanel.colorTableBlock.colors.addChild(_colorTableColor1);
         _settingsPanel.colorTableBlock.colors.addChild(_colorTableColor2);
         _colorTableColor1.x = -115;
         _colorTableColor1.y = -135;
         _colorTableColor2.x = -115;
         _colorTableColor2.y = 30;
      }
      
      private function addEventListeners() : void
      {
         _petMC.addEventListener("mouseDown",onPetFinderDown,false,0,true);
         _closeBtn.addEventListener("mouseDown",onCloseDown,false,0,true);
         _adoptPetBtn.addEventListener("mouseDown",onAdoptPetOrDiamondBtn,false,0,true);
         _diamondBuyBtn.addEventListener("mouseDown",onAdoptPetOrDiamondBtn,false,0,true);
         _namePanel.nameLever.addEventListener("mouseDown",onLeverDown,false,0,true);
         _backBtn.addEventListener("mouseDown",onBackBtn,false,0,true);
         _nextBtn.addEventListener("mouseDown",onNextBtn,false,0,true);
         _oopsPopup.bx.addEventListener("mouseDown",onOopsPopupClose,false,0,true);
         _oopsCostPopup.bx.addEventListener("mouseDown",onCostPopupClose,false,0,true);
         _settingsPanel.eyesDownBtn.addEventListener("mouseDown",onColorsEyesTraitsDownBtn,false,0,true);
         _settingsPanel.traitsDownBtn.addEventListener("mouseDown",onColorsEyesTraitsDownBtn,false,0,true);
         _settingsPanel.colorsDownBtn.addEventListener("mouseDown",onColorsEyesTraitsDownBtn,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         _petMC.removeEventListener("mouseDown",onPetFinderDown);
         _closeBtn.removeEventListener("mouseDown",onCloseDown);
         _adoptPetBtn.removeEventListener("mouseDown",onAdoptPetOrDiamondBtn);
         _diamondBuyBtn.removeEventListener("mouseDown",onAdoptPetOrDiamondBtn);
         _namePanel.nameLever.removeEventListener("mouseDown",onLeverDown);
         _backBtn.removeEventListener("mouseDown",onBackBtn);
         _nextBtn.removeEventListener("mouseDown",onNextBtn);
         _oopsPopup.bx.removeEventListener("mouseDown",onOopsPopupClose);
         _oopsCostPopup.bx.removeEventListener("mouseDown",onCostPopupClose);
         _settingsPanel.eyesDownBtn.removeEventListener("mouseDown",onColorsEyesTraitsDownBtn);
         _settingsPanel.traitsDownBtn.removeEventListener("mouseDown",onColorsEyesTraitsDownBtn);
         _settingsPanel.colorsDownBtn.removeEventListener("mouseDown",onColorsEyesTraitsDownBtn);
      }
      
      private function onPetFinderDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         close();
      }
      
      private function onAdoptPetOrDiamondBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_isFromRedemption)
         {
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14781),true,onAdoptYesBtn);
            return;
         }
         var _loc2_:Object = PetManager.getPetDef(_petDefId);
         var _loc3_:int = int(_specialDef ? _specialDefCost : _loc2_.cost);
         if(!gMainFrame.userInfo.isMember && _loc2_.isMember)
         {
            UpsellManager.displayPopup(10,"buyMemberPet");
         }
         else if(_specialDef && PetManager.isPetAvailable(_petDefId))
         {
            if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc2_.type))
            {
               new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14782,_loc2_.title.toLowerCase(),_loc2_.cost),true,onBuyInDiamondShopConfirm,_loc2_.cost);
            }
            else
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(15813),true,onOkLandPet);
            }
         }
         else if(_gemCount < _loc3_)
         {
            if(_specialDef)
            {
               UpsellManager.displayPopup(-1,"extraDiamonds");
            }
            else
            {
               DarkenManager.darken(_oopsCostPopup);
               if(_currencyType == 0)
               {
                  _oopsCostPopup.currency.gotoAndStop("gems");
               }
               else if(_currencyType == 1)
               {
                  _oopsCostPopup.currency.gotoAndStop("tickets");
               }
               else if(_currencyType == 2)
               {
                  _oopsCostPopup.currency.gotoAndStop("earth");
               }
               else if(_currencyType == 3)
               {
                  _oopsCostPopup.currency.gotoAndStop("diamonds");
               }
               _oopsCostPopup.gemsTxt.text = _gemCount;
               _oopsCostPopup.costTxt.text = _loc3_;
               _oopsCostPopup.needTxt.text = _loc3_ - _gemCount;
               _oopsCostPopup.visible = true;
            }
         }
         else if(PetManager.myPetList.length + 1 > PetManager.getPetInventoryMax())
         {
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdOnly(14783),true,confirmRecycle);
         }
         else if(_specialDef)
         {
            GuiManager.showDiamondConfirmation(_loc3_,onAdoptYesBtn);
         }
         else
         {
            new SBYesNoPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(_specialDef ? 14784 : 14785,Utility.convertNumberToString(_loc3_)),true,onAdoptYesBtn);
         }
      }
      
      private function onLeverDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_namePanel.nameLever.currentFrameLabel == "_up")
         {
            _nameScroller2.soundsEnabled = false;
            AJAudio.playRandomLever();
            _namePanel.nameLever.gotoAndPlay("_play");
            _nameScroller1.pickRandomItem();
            _nameScroller2.pickRandomItem();
            _nameScroller2.soundsEnabled = true;
         }
      }
      
      private function onBackBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_bgTween)
         {
            _bgTween.end();
         }
         if(_petTween)
         {
            _petTween.end();
         }
         if(_panelTween)
         {
            _panelTween.end();
         }
         var _loc3_:Function = Exponential.easeOut;
         var _loc2_:Number = 1.5;
         if(_screenPositionIndex == 1)
         {
            _bgTween = new GTween(_background,_loc2_,{"x":_background.x + 432},{"ease":_loc3_},{"MotionBlurEnabled":true});
            _petTween = new GTween(_bigPetWindow,_loc2_,{"x":_bigPetWindow.x + 407},{"ease":_loc3_});
            _panelTween = new GTween(_createPanelCont,_loc2_,{"x":_createPanelCont.x + 485},{"ease":_loc3_},{"MotionBlurEnabled":true});
            _backBtn.visible = false;
         }
         else
         {
            _panelTween = new GTween(_createPanelCont,_loc2_,{"x":_createPanelCont.x + 872},{"ease":_loc3_},{"MotionBlurEnabled":true});
            if(_creatingWithoutChoosing)
            {
               _backBtn.visible = false;
            }
            _nextBtn.visible = true;
         }
         _screenPositionIndex = _screenPositionIndex - 1;
         _diamondBuyBtn.visible = false;
         _adoptPetBtn.visible = false;
      }
      
      private function onNextBtn(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_bgTween)
         {
            _bgTween.end();
         }
         if(_petTween)
         {
            _petTween.end();
         }
         if(_panelTween)
         {
            _panelTween.end();
         }
         var _loc2_:Number = 1.5;
         var _loc3_:Function = Exponential.easeOut;
         if(_screenPositionIndex == 0)
         {
            if(param1 == null)
            {
               _background.x -= 432;
               _bigPetWindow.x -= 407;
               _createPanelCont.x -= 485;
            }
            else
            {
               _bgTween = new GTween(_background,_loc2_,{"x":_background.x - 432},{"ease":_loc3_},{"MotionBlurEnabled":true});
               _petTween = new GTween(_bigPetWindow,_loc2_,{"x":_bigPetWindow.x - 407},{"ease":_loc3_});
               _panelTween = new GTween(_createPanelCont,_loc2_,{"x":_createPanelCont.x - 485},{"ease":_loc3_},{"MotionBlurEnabled":true});
            }
         }
         else
         {
            _panelTween = new GTween(_createPanelCont,_loc2_,{"x":_createPanelCont.x - 872},{"ease":_loc3_},{"MotionBlurEnabled":true});
         }
         _screenPositionIndex = _screenPositionIndex + 1;
         if(_screenPositionIndex == 2)
         {
            _nextBtn.visible = false;
            if(_currPetDef.isDiamond && !PetManager.isPetAvailable(_petDefId))
            {
               _diamondBuyBtn.visible = true;
            }
            else
            {
               _adoptPetBtn.visible = true;
            }
            _backBtn.visible = true;
         }
         else
         {
            _nextBtn.visible = true;
            if(!_creatingWithoutChoosing)
            {
               _backBtn.visible = true;
            }
         }
      }
      
      private function onOopsPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _oopsPopup.visible = false;
      }
      
      private function onCostPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         DarkenManager.unDarken(_oopsCostPopup);
         _oopsCostPopup.visible = false;
      }
      
      private function onColorsEyesTraitsDownBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == _settingsPanel.colorsDownBtn.name)
         {
            openTab(0);
         }
         else if(param1.currentTarget.name == _settingsPanel.traitsDownBtn.name)
         {
            openTab(1);
         }
         else if(param1.currentTarget.name == _settingsPanel.eyesDownBtn.name)
         {
            openTab(2);
         }
      }
      
      private function chooseMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currIndex != param1.currentTarget.index)
         {
            ItemWindowAvatarOrPetSelect(_petWindows.bg.getChildAt(_currIndex)).deselect();
            _currIndex = param1.currentTarget.index;
            _petDefId = _currEnviroPetDefIds[_currIndex];
            if(param1.currentTarget.currWindow.currentFrameLabel != "down")
            {
               param1.currentTarget.currWindow.gotoAndStop("down");
            }
            param1.currentTarget.setupLayers();
            setupCurrentPet();
            setupChoosePanel();
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
         var _loc6_:MovieClip = null;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _settingsPanel.colorTableBlock.eyes["win" + param1.currentTarget.index].name)
         {
            _settingsPanel.colorTableBlock.eyes["win" + (_currEyeIndex - 1)].cir.gotoAndStop("up");
            _currEyeIndex = param1.currentTarget.index + 1;
            param1.currentTarget.cir.gotoAndStop("down");
            AJAudio.playSubMenuBtnClick();
            _catIndexArray[_eyes[1]] = _currEyeIndex;
            _catArray[_eyes[1]] = _currEyeIndex - 2;
            _currPet.colorMyItem(_eyes[1],_eyes[_currEyeIndex],_colors1[_currColor1Index][0],_colors1[_currColor1Index][1],_colors1[_currColor1Index][2],_colors2[_currColor2Index][0],_colors2[_currColor2Index][1],_colors2[_currColor2Index][2]);
            _loc4_ = PetManager.packPetBits(_catArray);
            _currPet.updateAllBits(_loc4_[0],_loc4_[1],_loc4_[2]);
         }
         else if(param1.currentTarget.index < 4)
         {
            _loc3_ = 0;
            if(param1.currentTarget.name == _settingsPanel.colorTableBlock.traits["lBtn" + param1.currentTarget.index].name)
            {
               _loc3_--;
            }
            else if(param1.currentTarget.name == _settingsPanel.colorTableBlock.traits["rBtn" + param1.currentTarget.index].name)
            {
               _loc3_++;
            }
            if(_loc3_ != 0)
            {
               _loc5_ = this["_att" + param1.currentTarget.index];
               _loc6_ = param1.currentTarget.parent["win" + param1.currentTarget.index];
               if(_loc6_.iconLayer.numChildren > 0)
               {
                  _loc6_.iconLayer.removeChildAt(0);
               }
               if(_loc5_ && _loc5_.length > 0)
               {
                  _loc2_ = int(this["_currAtt" + param1.currentTarget.index + "Index"]);
                  if(_loc3_ > 0)
                  {
                     if(_loc5_.length > _loc2_ + _loc3_)
                     {
                        _loc2_ += _loc3_;
                        _loc6_.iconLayer.addChild(_loc5_[_loc2_]);
                     }
                     else
                     {
                        _loc2_ = 2;
                        _loc6_.iconLayer.addChild(_loc5_[2]);
                     }
                  }
                  else if(_loc2_ + _loc3_ < 2)
                  {
                     _loc2_ = _loc5_.length - 1;
                     _loc6_.iconLayer.addChild(_loc5_[_loc5_.length - 1]);
                  }
                  else
                  {
                     _loc2_ += _loc3_;
                     _loc6_.iconLayer.addChild(_loc5_[_loc2_]);
                  }
                  _catIndexArray[_loc5_[1]] = _loc2_;
                  _currPet.colorMyItem(_loc5_[1],_loc5_[_loc2_],_colors1[_currColor1Index][0],_colors1[_currColor1Index][1],_colors1[_currColor1Index][2],_colors2[_currColor2Index][0],_colors2[_currColor2Index][1],_colors2[_currColor2Index][2]);
                  _catArray[_loc5_[1]] = _loc2_ - 2;
                  _loc4_ = PetManager.packPetBits(_catArray);
                  _currPet.updateAllBits(_loc4_[0],_loc4_[1],_loc4_[2]);
                  this["_currAtt" + param1.currentTarget.index + "Index"] = _loc2_;
               }
            }
         }
      }
      
      private function openTab(param1:int) : void
      {
         if(param1 == 0)
         {
            openColorTableColorsTab();
         }
         else if(param1 == 1)
         {
            openTraitsOrEyesTab(true);
         }
         else if(param1 == 2)
         {
            openTraitsOrEyesTab(false);
         }
      }
      
      private function openColorTableColorsTab() : void
      {
         _settingsPanel.traitsTabUp.visible = false;
         _settingsPanel.eyesTabUp.visible = false;
         _settingsPanel.colorsTabUp.visible = true;
         _settingsPanel.colorTableBlock.colors.visible = true;
         _settingsPanel.colorTableBlock.eyes.visible = false;
         _settingsPanel.colorTableBlock.traits.visible = false;
      }
      
      private function openTraitsOrEyesTab(param1:Boolean) : void
      {
         var _loc3_:MovieClip = null;
         var _loc4_:int = 0;
         var _loc2_:Array = null;
         if(param1)
         {
            _settingsPanel.colorsTabUp.visible = false;
            _settingsPanel.eyesTabUp.visible = false;
            _settingsPanel.traitsTabUp.visible = true;
            _settingsPanel.colorTableBlock.colors.visible = false;
            _settingsPanel.colorTableBlock.eyes.visible = false;
            _settingsPanel.colorTableBlock.traits.visible = true;
            _loc4_ = 1;
            while(_loc4_ < 4)
            {
               _loc3_ = _settingsPanel.colorTableBlock.traits["win" + _loc4_];
               while(_loc3_.iconLayer.numChildren > 0)
               {
                  _loc3_.iconLayer.removeChildAt(0);
               }
               _loc3_.ocean.visible = false;
               _loc3_.removeBtn.visible = false;
               _loc3_.lockOpen.visible = false;
               _loc3_.gift.visible = false;
               _loc3_.lock.visible = false;
               _loc3_.addBtn.visible = false;
               _loc3_.gray.visible = false;
               _settingsPanel.colorTableBlock.traits["traits" + _loc4_ + "Txt"].text = "";
               _loc2_ = this["_att" + _loc4_];
               if(_loc2_ && _loc2_.length > 0)
               {
                  LocalizationManager.translateId(_settingsPanel.colorTableBlock.traits["traits" + _loc4_ + "Txt"],_loc2_[0]);
                  if(_loc2_.length > this["_currAtt" + _loc4_ + "Index"])
                  {
                     _currPet.colorMyItem(this["_att" + _loc4_][1],_loc2_[this["_currAtt" + _loc4_ + "Index"]],_colors1[_currColor1Index][0],_colors1[_currColor1Index][1],_colors1[_currColor1Index][2],_colors2[_currColor2Index][0],_colors2[_currColor2Index][1],_colors2[_currColor2Index][2]);
                     _loc3_.iconLayer.addChild(_loc2_[this["_currAtt" + _loc4_ + "Index"]]);
                     _settingsPanel.colorTableBlock.traits["lBtn" + _loc4_].addEventListener("mouseDown",onColorEyesTraitsDown,false,0,true);
                     _settingsPanel.colorTableBlock.traits["rBtn" + _loc4_].addEventListener("mouseDown",onColorEyesTraitsDown,false,0,true);
                     _settingsPanel.colorTableBlock.traits["rBtn" + _loc4_].index = _loc4_;
                     _settingsPanel.colorTableBlock.traits["lBtn" + _loc4_].index = _loc4_;
                  }
               }
               _loc4_++;
            }
         }
         else
         {
            _settingsPanel.colorsTabUp.visible = false;
            _settingsPanel.eyesTabUp.visible = true;
            _settingsPanel.traitsTabUp.visible = false;
            _settingsPanel.colorTableBlock.colors.visible = false;
            _settingsPanel.colorTableBlock.traits.visible = false;
            _settingsPanel.colorTableBlock.eyes.visible = true;
            _loc4_ = 1;
            while(_loc4_ < 7)
            {
               _loc3_ = _settingsPanel.colorTableBlock.eyes["win" + _loc4_];
               while(_loc3_.iconLayer.numChildren > 0)
               {
                  _loc3_.iconLayer.removeChildAt(0);
               }
               _loc3_.ocean.visible = false;
               _loc3_.removeBtn.visible = false;
               _loc3_.lockOpen.visible = false;
               _loc3_.gift.visible = false;
               _loc3_.lock.visible = false;
               _loc3_.addBtn.visible = false;
               _loc3_.gray.visible = false;
               if(_eyes && _eyes.length > 0)
               {
                  if(_eyes.length > _loc4_ + 1)
                  {
                     _currPet.colorMyItem(_eyes[1],_eyes[_loc4_ + 1],_colors1[_currColor1Index][0],_colors1[_currColor1Index][1],_colors1[_currColor1Index][2],_colors2[_currColor2Index][0],_colors2[_currColor2Index][1],_colors2[_currColor2Index][2]);
                     _loc3_.iconLayer.addChild(_eyes[_loc4_ + 1]);
                     if(!_loc3_.hasEventListener("mouseDown"))
                     {
                        _loc3_.addEventListener("mouseDown",onColorEyesTraitsDown,false,0,true);
                     }
                     if(!_loc3_.hasEventListener("rollOver"))
                     {
                        _loc3_.addEventListener("rollOver",colorEyesTraitsOver,false,0,true);
                     }
                     if(!_loc3_.hasEventListener("rollOut"))
                     {
                        _loc3_.addEventListener("rollOut",colorEyesTraitsOut,false,0,true);
                     }
                     _loc3_.index = _loc4_;
                     if(_currEyeIndex == _loc4_ + 1)
                     {
                        _loc3_.cir.gotoAndStop("down");
                     }
                     else
                     {
                        _loc3_.cir.gotoAndStop("up");
                     }
                  }
                  else
                  {
                     _loc3_.gray.visible = true;
                  }
               }
               _loc4_++;
            }
         }
      }
      
      private function close() : void
      {
         if(_closeCallback != null)
         {
            _closeCallback();
         }
         else
         {
            destroy();
         }
      }
   }
}

