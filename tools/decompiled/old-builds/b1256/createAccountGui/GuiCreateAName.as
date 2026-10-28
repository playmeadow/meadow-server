package createAccountGui
{
   import Party.PartyManager;
   import avatar.Avatar;
   import avatar.AvatarSwitch;
   import avatar.AvatarUtility;
   import avatar.INewAvatar;
   import avatar.NewWorldAvatar;
   import com.sbi.analytics.SBTracker;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import com.sbi.popup.SBYesNoPopup;
   import createAccountFlow.CreateAccountGui;
   import currency.UserCurrency;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiCarousel;
   import gui.GuiManager;
   import gui.UpsellManager;
   import localization.LocalizationManager;
   
   public class GuiCreateAName extends SBScreen
   {
      
      private static const AVT_NAMES_1:int = 200;
      
      private static const AVT_NAMES_2:int = 202;
      
      private static const AVT_NAMES_3:int = 203;
      
      private var _createANameScreen:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _playBtn:MovieClip;
      
      private var _voBtn:MovieClip;
      
      private var _name1Carousel:GuiCarousel;
      
      private var _name2Carousel:GuiCarousel;
      
      private var _name3Carousel:GuiCarousel;
      
      private var _randomNameLever:MovieClip;
      
      private var _avatarNameTxt:TextField;
      
      private var _titleTxt:TextField;
      
      private var _avatarNameIndexes:Array;
      
      private var _avatarNameChosenIds:Array;
      
      private var _avtNames:Array;
      
      private var _newAvatarFacilitator:INewAvatar;
      
      private var _isFromWorld:Boolean;
      
      private var _isChoosingFirstNonMember:Boolean;
      
      private var _isValid:Boolean;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _buyBtnDiamondGreen:MovieClip;
      
      private var _buyBtnDiamondRed:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _registrationPanel:MovieClip;
      
      private var _isRandomSpin:Boolean;
      
      private var _creationAssets:GuiAvatarCreationAssets;
      
      private var _isFastPass:Boolean;
      
      public function GuiCreateAName(param1:Object, param2:SBWizard, param3:Boolean, param4:Boolean = false)
      {
         _createANameScreen = param1.registrationPanel.createAName;
         _backBtn = param1.back_btn;
         _playBtn = param1.play_btn;
         _voBtn = _createANameScreen.vo_btn;
         super(_createANameScreen,param2);
         _creationAssets = GuiAvatarCreationAssets(param2.creationAssets);
         _registrationPanel = MovieClip(_createANameScreen.parent);
         _name1Carousel = new GuiCarousel(_createANameScreen.nameScroller1);
         _name2Carousel = new GuiCarousel(_createANameScreen.nameScroller2);
         _name3Carousel = new GuiCarousel(_createANameScreen.nameScroller3);
         _randomNameLever = _createANameScreen.nameLever;
         _randomNameLever.addEventListener("mouseDown",randomLeverMouseDownHandler,false,0,true);
         _avatarNameTxt = _createANameScreen.aml_name_txt;
         _titleTxt = _createANameScreen.choose_name_title_txt;
         _isFastPass = param4;
         if(param3)
         {
            _nextBtn = param1.next_btn;
            _buyBtnGreen = param1.buy_btn_green;
            _buyBtnRed = param1.buy_btn_red;
            _buyBtnDiamondGreen = param1.diamond_buy_btn_green;
            _buyBtnDiamondRed = param1.diamond_buy_btn_red;
         }
      }
      
      public function init(param1:Object, param2:Boolean = false, param3:Boolean = false) : void
      {
         onEnterFromPrev = enterFromPrev;
         onEnterFromNext = enterFromNext;
         onLeaveToPrev = leaveToPrev;
         onLeaveToNext = leaveToNext;
         onPlay = param2 ? leaveToNext : null;
         onClose = close;
         updateScreen = updateScreenAssets;
         _newAvatarFacilitator = param2 ? new NewWorldAvatar() : INewAvatar(param1);
         _avatarNameTxt.restrict = "A-Za-z0-9 ";
         _avatarNameTxt.maxChars = 23;
         _isFromWorld = param2;
         _isFastPass = param3;
         if(!_isFromWorld || _isFastPass)
         {
            _voBtn.stop();
            _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
         }
         _backBtn.visible = false;
         _avatarNameIndexes = [-1,-1,-1];
         _avatarNameChosenIds = [0,0,0];
         if(_avtNames == null)
         {
            _avtNames = [-1,-1,-1];
         }
         if(param2)
         {
            GenericListXtCommManager.requestGenericList(200,onNamesLoaded);
            GenericListXtCommManager.requestGenericList(202,onNamesLoaded);
            GenericListXtCommManager.requestGenericList(203,onNamesLoaded);
         }
      }
      
      override public function destroy() : void
      {
         _createANameScreen = null;
         _name1Carousel.destroy();
         _name1Carousel = null;
         _name2Carousel.destroy();
         _name2Carousel = null;
         _name3Carousel.destroy();
         _name3Carousel = null;
         _newAvatarFacilitator = null;
         super.destroy();
      }
      
      public function enterFromNext(param1:Boolean = false) : void
      {
         _isChoosingFirstNonMember = param1;
         _isValid = false;
         _registrationPanel.gotoAndPlay("backChooseAName");
         CreateAccountGui.currAvatar().gotoAndPlay("backChooseAName");
         MovieClip(_registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backChooseAName");
         enterFromBoth();
      }
      
      public function enterFromPrev() : void
      {
         _newAvatarFacilitator.hideConnectingMsg();
         if(_isFromWorld)
         {
            _nextBtn.visible = false;
            if(_creationAssets.isDiamondAvatar && !AvatarUtility.getAvatarDefIsViewable(_creationAssets.currAvatar,_creationAssets.currCustomAvId != -1))
            {
               _buyBtnDiamondGreen.visible = _creationAssets.hasEnoughGems;
               _buyBtnDiamondRed.visible = !_buyBtnDiamondGreen.visible;
               _buyBtnGreen.visible = _buyBtnRed.visible = false;
            }
            else if(_isFastPass)
            {
               _playBtn.visible = true;
               _buyBtnGreen.visible = _buyBtnRed.visible = _buyBtnDiamondGreen.visible = _buyBtnDiamondRed.visible = false;
            }
            else
            {
               _buyBtnGreen.visible = _creationAssets.hasEnoughGems;
               _buyBtnRed.visible = !_buyBtnGreen.visible;
               _buyBtnDiamondGreen.visible = _buyBtnDiamondRed.visible = false;
            }
            _backBtn.sparkle.visible = _creationAssets.isDiamondAvatar;
         }
         _backBtn.visible = _isFromWorld ? !_creationAssets.isCreatingWithoutChoosing : true;
         _isValid = false;
         enterFromBoth();
      }
      
      public function enterFromBoth() : void
      {
         if(_newAvatarFacilitator.playSound || _isFastPass)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.play();
               if(CreateAccountGui.vo2Sound.sc)
               {
                  CreateAccountGui.vo2Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
                  _voBtn.play();
               }
            }
         }
         if(_isFromWorld)
         {
            SBTracker.trackPageview("/game/play/popup/avatarCreation/CreateAName");
         }
         else
         {
            CreateAccountGui.trackUserCreateAccountPageChange("CreateAName");
         }
      }
      
      public function leaveToNext() : Boolean
      {
         var _loc4_:Avatar = null;
         var _loc1_:Object = null;
         var _loc3_:Object = null;
         var _loc2_:int = 0;
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         if(_isFastPass)
         {
            AvatarSwitch.addFastPassAvatarCallback = onFastPassComplete;
         }
         if(!_isValid)
         {
            if(_isFromWorld)
            {
               if(gMainFrame.clientInfo.roomType == 5)
               {
                  _loc4_ = new Avatar();
                  _loc4_.init(0,"",_creationAssets.currType,[]);
                  if(!PartyManager.canSwitchToAvatar(_loc4_,true))
                  {
                     _loc4_.destroy();
                     _loc4_ = null;
                     return false;
                  }
               }
               if(AvatarSwitch.numTotalAvatars >= 36)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14690),true,onSlotsFullOk);
                  return true;
               }
               if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
               {
                  if(!gMainFrame.userInfo.isMember)
                  {
                     _loc1_ = AvatarUtility.findAvDefByType(_creationAssets.currType,_creationAssets.currCustomAvId);
                     if(_loc1_.isMemberOnly)
                     {
                        UpsellManager.displayPopup(3,"createMembersOnlyAvatar");
                        return false;
                     }
                  }
               }
               if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
               {
                  if(AvatarUtility.getAvatarDefIsViewable(_creationAssets.currAvatar,_creationAssets.currCustomAvId != -1))
                  {
                     _loc3_ = AvatarUtility.findAvDefByType(_creationAssets.currType,_creationAssets.currCustomAvId);
                     new SBYesNoPopup(_registrationPanel.parent.parent.parent,LocalizationManager.translateIdAndInsertOnly(14782,_creationAssets.currAvatarName,_loc3_.cost),true,onDiamondShopConfirmBuy,_creationAssets.avatarDiamondDefId);
                     return false;
                  }
               }
               if(!_isChoosingFirstNonMember && !_creationAssets.hasEnoughGems)
               {
                  DarkenManager.showLoadingSpiral(true);
                  if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
                  {
                     onCloseNotEnoughGems();
                  }
                  else
                  {
                     Utility.setupNotEnoughGemsPopup(_creationAssets.parent,_creationAssets.currAvatarCost,_creationAssets.currencyType);
                  }
                  return false;
               }
               if(_creationAssets.isCreatingWithoutChoosing || _creationAssets.isDiamondAvatar)
               {
                  GuiManager.showDiamondConfirmation(_creationAssets.currAvatarCost,onDiamondApprovePurchase);
                  return false;
               }
            }
            _loc2_ = _isFromWorld ? _creationAssets.currType : CreateAccountGui.currType();
            _newAvatarFacilitator.newAvatarData(_loc2_,_avatarNameTxt.text,_avatarNameChosenIds,avNameValidCallback,_creationAssets.avatarDiamondDefId,_creationAssets.currCustomAvId,_isFastPass);
         }
         if(_isValid)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.stop();
            }
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
            if(!_isFromWorld)
            {
               _registrationPanel.gotoAndPlay("playPlayerAccountOne");
               CreateAccountGui.currAvatar().gotoAndPlay("playPlayerAccountOne");
               MovieClip(_registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("playPlayerAccountOne");
            }
            return true;
         }
         return false;
      }
      
      public function leaveToBoth() : Boolean
      {
         return true;
      }
      
      public function leaveToPrev() : Boolean
      {
         _backBtn.visible = false;
         if(!_isFromWorld || _isFastPass)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.stop();
            }
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         return true;
      }
      
      public function loadNameLists() : void
      {
         GenericListXtCommManager.requestGenericList(200,onNamesLoaded,null,_isFromWorld);
         GenericListXtCommManager.requestGenericList(202,onNamesLoaded,null,_isFromWorld);
         GenericListXtCommManager.requestGenericList(203,onNamesLoaded,null,_isFromWorld);
      }
      
      public function close() : void
      {
         AvatarSwitch.addAvatarCallback = null;
         AvatarSwitch.addFastPassAvatarCallback = null;
         _newAvatarFacilitator.nameTypeScreenDone();
      }
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         _createANameScreen = _registrationPanel.createAName;
         _avatarNameTxt = _createANameScreen.aml_name_txt;
         if(_name1Carousel && _name1Carousel.hasLoaded)
         {
            _name1Carousel.destroy();
            _name1Carousel = null;
         }
         _name1Carousel = new GuiCarousel(_createANameScreen.nameScroller1);
         if(_name2Carousel && _name1Carousel.hasLoaded)
         {
            _name2Carousel.destroy();
            _name2Carousel = null;
         }
         _name2Carousel = new GuiCarousel(_createANameScreen.nameScroller2);
         if(_name3Carousel && _name1Carousel.hasLoaded)
         {
            _name3Carousel.destroy();
            _name3Carousel = null;
         }
         _name3Carousel = new GuiCarousel(_createANameScreen.nameScroller3);
         if(_avtNames[0] != -1)
         {
            setupNameLists(_avtNames[0].names,_avtNames[1].names,_avtNames[2].names);
         }
         if(param1 || (_isFromWorld ? _creationAssets.isCreatingWithoutChoosing : false))
         {
            _backBtn = MovieClip(_registrationPanel.parent).back_btn;
            _playBtn = MovieClip(_registrationPanel.parent).play_btn;
            _randomNameLever = _createANameScreen.nameLever;
            _randomNameLever.addEventListener("mouseDown",randomLeverMouseDownHandler,false,0,true);
            _titleTxt = _createANameScreen.choose_name_title_txt;
            _voBtn = _createANameScreen.vo_btn;
            if(_isFromWorld)
            {
               _nextBtn = MovieClip(_registrationPanel.parent).next_btn;
               _buyBtnGreen = MovieClip(_registrationPanel.parent).buy_btn_green;
               _buyBtnRed = MovieClip(_registrationPanel.parent).buy_btn_red;
               _buyBtnDiamondGreen = MovieClip(_registrationPanel.parent).diamond_buy_btn_green;
               _buyBtnDiamondRed = MovieClip(_registrationPanel.parent).diamond_buy_btn_red;
               if(!_isFastPass)
               {
                  _voBtn.visible = false;
               }
               if(_creationAssets.isDiamondAvatar && !AvatarUtility.getAvatarDefIsViewable(_creationAssets.currAvatar,_creationAssets.currCustomAvId != -1))
               {
                  _buyBtnDiamondGreen.visible = _creationAssets.hasEnoughGems;
                  _buyBtnDiamondRed.visible = !_buyBtnDiamondGreen.visible;
                  _buyBtnGreen.visible = _buyBtnRed.visible = false;
               }
               else if(_isFastPass)
               {
                  _playBtn.visible = true;
                  _buyBtnGreen.visible = _buyBtnRed.visible = _buyBtnDiamondGreen.visible = _buyBtnDiamondRed.visible = false;
               }
               else
               {
                  _buyBtnGreen.visible = _creationAssets.hasEnoughGems;
                  _buyBtnRed.visible = !_buyBtnGreen.visible;
                  _buyBtnDiamondGreen.visible = _buyBtnDiamondRed.visible = false;
               }
               _backBtn.sparkle.visible = _creationAssets.isDiamondAvatar;
            }
            if(!_isFromWorld || _isFastPass)
            {
               _voBtn.addEventListener("click",voBtnClickHandler,false,0,true);
               if(CreateAccountGui.vo2Sound.sc)
               {
                  _voBtn.play();
               }
            }
            _backBtn.visible = _isFromWorld ? !_creationAssets.isCreatingWithoutChoosing : true;
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
         switch(param1 - 200)
         {
            case 0:
               _loc3_ = 0;
               _loc4_ = {
                  "names":[],
                  "locIds":[]
               };
               break;
            case 2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc4_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc3_ = 2;
               }
               else
               {
                  _loc4_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc3_ = 1;
               }
               break;
            case 3:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc4_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc3_ = 1;
                  break;
               }
               _loc4_ = {
                  "names":[],
                  "femNames":[],
                  "locIds":[]
               };
               _loc3_ = 2;
         }
         if(_loc3_ != -1)
         {
            _loc7_ = 0;
            while(_loc7_ < param2.length)
            {
               if(_loc3_ == 1)
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
               else if(_loc3_ == 2)
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
               else
               {
                  _loc5_ = LocalizationManager.translateIdOnly(param2[_loc7_]);
                  _loc8_ = Utility.findIndexToInsert(_loc4_.names,_loc5_);
                  _loc4_.names.splice(_loc8_,0,_loc5_);
               }
               _loc4_.locIds.splice(_loc8_,0,param2[_loc7_]);
               _loc7_++;
            }
            _avtNames[_loc3_] = _loc4_;
         }
         if(_avtNames[0] != -1 && _avtNames[1] != -1 && _avtNames[2] != -1)
         {
            setupNameLists(_avtNames[0].names,_avtNames[1].names,_avtNames[2].names);
         }
      }
      
      private function onCloseNotEnoughGems() : void
      {
         UpsellManager.displayPopup(-1,"extraDiamonds");
      }
      
      private function onDiamondApprovePurchase() : void
      {
         var _loc1_:int = _isFromWorld ? _creationAssets.currType : CreateAccountGui.currType();
         _newAvatarFacilitator.newAvatarData(_loc1_,_avatarNameTxt.text,_avatarNameChosenIds,avNameValidCallback,_creationAssets.avatarDiamondDefId);
      }
      
      private function onSlotsFullOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         close();
      }
      
      private function onDiamondShopConfirmBuy(param1:Object) : void
      {
         var _loc3_:Object = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         if(param1.status)
         {
            _loc3_ = AvatarUtility.findAvDefByType(_creationAssets.currType,_creationAssets.currCustomAvId);
            _loc4_ = UserCurrency.getCurrency(0);
            if(_loc4_ < _loc3_.diamondCost)
            {
               DarkenManager.showLoadingSpiral(true);
               Utility.setupNotEnoughGemsPopup(_creationAssets.parent,_loc3_.diamondCost,0);
            }
            else
            {
               _loc2_ = _creationAssets.currType;
               _newAvatarFacilitator.newAvatarData(_loc2_,_avatarNameTxt.text,_avatarNameChosenIds,avNameValidCallback,param1.passback);
            }
         }
         else
         {
            close();
         }
      }
      
      private function avNameValidCallback(param1:Boolean) : void
      {
         if(param1)
         {
            _isValid = true;
            if(super.parentWizard != null)
            {
               super.parentWizard.next();
            }
            _newAvatarFacilitator.nameTypeScreenDone();
         }
         else
         {
            DebugUtility.debugTrace("ERROR: Invalid avname?!");
         }
      }
      
      private function onFastPassComplete(param1:Boolean) : void
      {
         if(param1)
         {
            avNameValidCallback(true);
         }
         else
         {
            new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(11233));
         }
      }
      
      private function setupNameLists(param1:Array, param2:Array, param3:Array) : void
      {
         _name1Carousel.init(param1,names1Changed,false,false,null,false,_avatarNameIndexes[0]);
         _name2Carousel.init(param2,names2Changed,false,false,null,false,_avatarNameIndexes[1]);
         _name3Carousel.init(param3,names3Changed,false,false,null,false,_avatarNameIndexes[2]);
         if(_avatarNameIndexes[0] == -1)
         {
            randomizeNames();
         }
      }
      
      private function randomizeNames() : void
      {
         _name1Carousel.soundsEnabled = false;
         _name2Carousel.soundsEnabled = false;
         _name3Carousel.soundsEnabled = false;
         _name1Carousel.pickRandomItem(true);
         _name2Carousel.pickRandomItem(true);
         _name3Carousel.pickRandomItem(true);
         _name1Carousel.soundsEnabled = true;
         _name2Carousel.soundsEnabled = true;
         _name3Carousel.soundsEnabled = true;
      }
      
      private function names1Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            LocalizationManager.updateToFit(_avatarNameTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + _name3Carousel.selectedContentItem);
            _avatarNameChosenIds[0] = _avtNames[0].locIds[_name1Carousel.contentItemIndex];
            _avatarNameIndexes[0] = _name1Carousel.contentItemIndex;
         }
      }
      
      private function names2Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            LocalizationManager.updateToFit(_avatarNameTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + _name3Carousel.selectedContentItem);
            _avatarNameChosenIds[1] = _avtNames[1].locIds[_name2Carousel.contentItemIndex];
            _avatarNameIndexes[1] = _name2Carousel.contentItemIndex;
         }
         if(!_name2Carousel.soundsEnabled && _isRandomSpin)
         {
            _name2Carousel.soundsEnabled = true;
            _name3Carousel.soundsEnabled = true;
            _isRandomSpin = false;
         }
         if(_avtNames[2] && _name3Carousel.hasLoaded)
         {
            if(_avtNames[1].types[_name2Carousel.contentItemIndex] != "f")
            {
               if(_name3Carousel.contentItems != _avtNames[2].names)
               {
                  _name3Carousel.contentItems = _avtNames[2].names;
               }
            }
            else if(_avtNames[2].femNames && _avtNames[2].femNames[0] && _name3Carousel.contentItems != _avtNames[2].femNames)
            {
               _name3Carousel.contentItems = _avtNames[2].femNames;
            }
            if(_name3Carousel.soundsEnabled)
            {
               _name3Carousel.soundsEnabled = false;
               _name3Carousel.spinToIndex(_name3Carousel.contentItemIndex,true);
               _name3Carousel.soundsEnabled = true;
            }
            else
            {
               _name3Carousel.spinToIndex(_name3Carousel.contentItemIndex,true);
            }
         }
      }
      
      private function names3Changed() : void
      {
         if(_name1Carousel.selectedContentItem && _name2Carousel.selectedContentItem && _name3Carousel.selectedContentItem)
         {
            LocalizationManager.updateToFit(_avatarNameTxt,_name1Carousel.selectedContentItem + " " + _name2Carousel.selectedContentItem + _name3Carousel.selectedContentItem);
            _avatarNameChosenIds[2] = _avtNames[2].locIds[_name3Carousel.contentItemIndex];
            _avatarNameIndexes[2] = _name3Carousel.contentItemIndex;
         }
         if(!_name3Carousel.soundsEnabled && _isRandomSpin)
         {
            _name3Carousel.soundsEnabled = true;
            _name2Carousel.soundsEnabled = true;
            _isRandomSpin = false;
         }
      }
      
      private function randomLeverMouseDownHandler(param1:MouseEvent) : void
      {
         if(_randomNameLever.currentFrameLabel == "_up")
         {
            _isRandomSpin = true;
            _name2Carousel.soundsEnabled = false;
            _name3Carousel.soundsEnabled = false;
            AJAudio.playRandomLever();
            _randomNameLever.gotoAndPlay("_play");
            _name1Carousel.pickRandomItem();
            _name2Carousel.pickRandomItem();
            _name3Carousel.pickRandomItem();
         }
      }
      
      private function stopVOButton(param1:Event) : void
      {
         CreateAccountGui.vo2Sound.stop();
         _voBtn.stop();
         _voBtn.gotoAndStop(1);
      }
      
      private function enableNext() : void
      {
      }
      
      private function tipsNeedTxtClickHandler(param1:MouseEvent) : void
      {
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         if(CreateAccountGui.vo2Sound.isPlaying)
         {
            CreateAccountGui.vo2Sound.stop();
            _voBtn.stop();
            _voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo2Sound.play();
            if(CreateAccountGui.vo2Sound.sc)
            {
               CreateAccountGui.vo2Sound.sc.addEventListener("soundComplete",stopVOButton,false,0,true);
               _voBtn.play();
            }
         }
      }
   }
}

