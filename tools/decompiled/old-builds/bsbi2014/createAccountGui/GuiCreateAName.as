package createAccountGui
{
   import achievement.AchievementXtCommManager;
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
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.DarkenManager;
   import gui.GuiCarousel;
   import gui.GuiManager;
   import gui.PartyManager;
   import gui.SwitchManager;
   import gui.UpsellManager;
   import item.Item;
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
      
      private var _nextBtn:MovieClip;
      
      private var _registrationPanel:MovieClip;
      
      private var _isRandomSpin:Boolean;
      
      private var _creationAssets:GuiAvatarCreationAssets;
      
      public function GuiCreateAName(initLogin:Object, initWizard:SBWizard, isFromWorld:Boolean)
      {
         this._createANameScreen = initLogin.registrationPanel.createAName;
         this._backBtn = initLogin.back_btn;
         this._playBtn = initLogin.play_btn;
         super(this._createANameScreen,initWizard);
         this._creationAssets = GuiAvatarCreationAssets(initWizard.creationAssets);
         this._registrationPanel = MovieClip(this._createANameScreen.parent);
         this._name1Carousel = new GuiCarousel(this._createANameScreen.nameScroller1);
         this._name2Carousel = new GuiCarousel(this._createANameScreen.nameScroller2);
         this._name3Carousel = new GuiCarousel(this._createANameScreen.nameScroller3);
         this._randomNameLever = this._createANameScreen.nameLever;
         this._randomNameLever.addEventListener(MouseEvent.MOUSE_DOWN,this.randomLeverMouseDownHandler,false,0,true);
         this._avatarNameTxt = this._createANameScreen.aml_name_txt;
         this._titleTxt = this._createANameScreen.choose_name_title_txt;
         if(isFromWorld)
         {
            this._nextBtn = initLogin.next_btn;
            this._buyBtnGreen = initLogin.buy_btn_green;
            this._buyBtnRed = initLogin.buy_btn_red;
         }
         else
         {
            this._voBtn = this._createANameScreen.vo_btn;
         }
      }
      
      public function init(initNewAvFacilitator:Object, isFromWorld:Boolean = false) : void
      {
         onEnterFromPrev = this.enterFromPrev;
         onEnterFromNext = this.enterFromNext;
         onLeaveToPrev = this.leaveToPrev;
         onLeaveToNext = this.leaveToNext;
         onPlay = isFromWorld ? this.leaveToNext : null;
         onClose = this.close;
         updateScreen = this.updateScreenAssets;
         this._newAvatarFacilitator = isFromWorld ? new NewWorldAvatar() : INewAvatar(initNewAvFacilitator);
         this._avatarNameTxt.restrict = "A-Za-z0-9 ";
         this._avatarNameTxt.maxChars = 23;
         this._isFromWorld = isFromWorld;
         if(!this._isFromWorld)
         {
            this._voBtn.stop();
            this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
         }
         this._backBtn.visible = false;
         this._avatarNameIndexes = [-1,-1,-1];
         this._avatarNameChosenIds = [0,0,0];
         if(this._avtNames == null)
         {
            this._avtNames = [-1,-1,-1];
         }
         if(isFromWorld)
         {
            GenericListXtCommManager.requestGenericList(AVT_NAMES_1,this.onNamesLoaded);
            GenericListXtCommManager.requestGenericList(AVT_NAMES_2,this.onNamesLoaded);
            GenericListXtCommManager.requestGenericList(AVT_NAMES_3,this.onNamesLoaded);
         }
      }
      
      override public function destroy() : void
      {
         this._createANameScreen = null;
         this._name1Carousel.destroy();
         this._name1Carousel = null;
         this._name2Carousel.destroy();
         this._name2Carousel = null;
         this._name3Carousel.destroy();
         this._name3Carousel = null;
         this._newAvatarFacilitator = null;
         super.destroy();
      }
      
      public function enterFromNext(isChoosingFirstNonMember:Boolean = false) : void
      {
         this._isChoosingFirstNonMember = isChoosingFirstNonMember;
         this._isValid = false;
         this._registrationPanel.gotoAndPlay("backChooseAName");
         CreateAccountGui.currAvatar().gotoAndPlay("backChooseAName");
         MovieClip(this._registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backChooseAName");
         this.enterFromBoth();
      }
      
      public function enterFromPrev() : void
      {
         this._newAvatarFacilitator.hideConnectingMsg();
         if(this._isFromWorld)
         {
            this._nextBtn.visible = false;
            this._buyBtnGreen.visible = this._creationAssets.hasEnoughGems;
            this._buyBtnRed.visible = !this._buyBtnGreen.visible;
         }
         this._backBtn.visible = this._isFromWorld ? !this._creationAssets.isCreatingWithoutChoosing : true;
         this._isValid = false;
         this.enterFromBoth();
      }
      
      public function enterFromBoth() : void
      {
         if(this._newAvatarFacilitator.playSound)
         {
            if(Boolean(CreateAccountGui.vo2Sound))
            {
               CreateAccountGui.vo2Sound.play();
               if(Boolean(CreateAccountGui.vo2Sound.sc))
               {
                  CreateAccountGui.vo2Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
                  this._voBtn.play();
               }
            }
         }
         if(this._isFromWorld)
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
         var avType:int = 0;
         var tempAvt:Avatar = null;
         var currDef:Object = null;
         var avDef:Object = null;
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         if(!this._isValid)
         {
            if(this._isFromWorld)
            {
               if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_PARTY)
               {
                  tempAvt = new Avatar();
                  tempAvt.init(0,"",this._creationAssets.currType,[]);
                  if(!PartyManager.canSwitchToAvatar(tempAvt,true))
                  {
                     tempAvt.destroy();
                     tempAvt = null;
                     return false;
                  }
               }
               if(AvatarSwitch.numTotalAvatars >= SwitchManager.NUM_AVATAR_SLOTS)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14690),true,this.onSlotsFullOk);
                  return true;
               }
               if(this._creationAssets.isCreatingWithoutChoosing)
               {
                  if(!gMainFrame.userInfo.isMember)
                  {
                     currDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvDefIndexByType(this._creationAssets.currType)];
                     if(Boolean(currDef.isMemberOnly))
                     {
                        UpsellManager.displayPopup(UpsellManager.ANIMALS,"createMembersOnlyAvatar");
                        return false;
                     }
                  }
               }
               if(this._creationAssets.isCreatingWithoutChoosing)
               {
                  if((gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG) & 1 << this._creationAssets.currType - 1) != 0)
                  {
                     avDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(this._creationAssets.currType)];
                     new SBYesNoPopup(this._registrationPanel.parent.parent.parent,LocalizationManager.translateIdAndInsertOnly(14782,this._creationAssets.currAvatarName,avDef.cost),true,this.onDiamondShopConfirmBuy);
                     return false;
                  }
               }
               if(!this._isChoosingFirstNonMember && !this._creationAssets.hasEnoughGems)
               {
                  DarkenManager.showLoadingSpiral(true);
                  if(this._creationAssets.isCreatingWithoutChoosing)
                  {
                     this.onCloseNotEnoughGems();
                  }
                  else
                  {
                     Utility.setupNotEnoughGemsPopup(this._creationAssets.parent,this._creationAssets.currAvatarCost,this._creationAssets.currencyType);
                  }
                  return false;
               }
               if(this._creationAssets.isCreatingWithoutChoosing)
               {
                  GuiManager.showDiamondConfirmation(this._creationAssets.currAvatarCost,this.onDiamondApprovePurchase);
                  return false;
               }
            }
            avType = this._isFromWorld ? this._creationAssets.currType : CreateAccountGui.currType();
            this._newAvatarFacilitator.newAvatarData(avType,this._avatarNameTxt.text,this._avatarNameChosenIds,this.avNameValidCallback,this._isFromWorld ? this._creationAssets.isCreatingWithoutChoosing : false);
         }
         if(this._isValid)
         {
            if(Boolean(CreateAccountGui.vo2Sound))
            {
               CreateAccountGui.vo2Sound.stop();
            }
            if(!this._isFromWorld)
            {
               this._voBtn.stop();
               this._voBtn.gotoAndStop(1);
               this._registrationPanel.gotoAndPlay("playPlayerAccountOne");
               CreateAccountGui.currAvatar().gotoAndPlay("playPlayerAccountOne");
               MovieClip(this._registrationPanel.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("playPlayerAccountOne");
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
         this._backBtn.visible = false;
         if(!this._isFromWorld)
         {
            if(Boolean(CreateAccountGui.vo2Sound))
            {
               CreateAccountGui.vo2Sound.stop();
            }
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         return true;
      }
      
      public function loadNameLists() : void
      {
         GenericListXtCommManager.requestGenericList(AVT_NAMES_1,this.onNamesLoaded,null,this._isFromWorld);
         GenericListXtCommManager.requestGenericList(AVT_NAMES_2,this.onNamesLoaded,null,this._isFromWorld);
         GenericListXtCommManager.requestGenericList(AVT_NAMES_3,this.onNamesLoaded,null,this._isFromWorld);
      }
      
      public function close() : void
      {
         AvatarSwitch.addAvatarCallback = null;
         this._newAvatarFacilitator.nameTypeScreenDone();
      }
      
      public function updateScreenAssets(isCurrentScreen:Boolean = false) : void
      {
         this._createANameScreen = this._registrationPanel.createAName;
         this._avatarNameTxt = this._createANameScreen.aml_name_txt;
         if(Boolean(this._name1Carousel) && this._name1Carousel.hasLoaded)
         {
            this._name1Carousel.destroy();
            this._name1Carousel = null;
         }
         this._name1Carousel = new GuiCarousel(this._createANameScreen.nameScroller1);
         if(Boolean(this._name2Carousel) && this._name1Carousel.hasLoaded)
         {
            this._name2Carousel.destroy();
            this._name2Carousel = null;
         }
         this._name2Carousel = new GuiCarousel(this._createANameScreen.nameScroller2);
         if(Boolean(this._name3Carousel) && this._name1Carousel.hasLoaded)
         {
            this._name3Carousel.destroy();
            this._name3Carousel = null;
         }
         this._name3Carousel = new GuiCarousel(this._createANameScreen.nameScroller3);
         if(this._avtNames[0] != -1)
         {
            this.setupNameLists(this._avtNames[0].names,this._avtNames[1].names,this._avtNames[2].names);
         }
         if(isCurrentScreen || (this._isFromWorld ? Boolean(this._creationAssets.isCreatingWithoutChoosing) : Boolean(false)))
         {
            this._backBtn = MovieClip(this._registrationPanel.parent).back_btn;
            this._playBtn = MovieClip(this._registrationPanel.parent).play_btn;
            this._randomNameLever = this._createANameScreen.nameLever;
            this._randomNameLever.addEventListener(MouseEvent.MOUSE_DOWN,this.randomLeverMouseDownHandler,false,0,true);
            this._titleTxt = this._createANameScreen.choose_name_title_txt;
            this._voBtn = this._createANameScreen.vo_btn;
            if(this._isFromWorld)
            {
               this._nextBtn = MovieClip(this._registrationPanel.parent).next_btn;
               this._buyBtnGreen = MovieClip(this._registrationPanel.parent).buy_btn_green;
               this._buyBtnRed = MovieClip(this._registrationPanel.parent).buy_btn_red;
               this._voBtn.visible = false;
               this._buyBtnGreen.visible = this._creationAssets.hasEnoughGems;
               this._buyBtnRed.visible = !this._buyBtnGreen.visible;
            }
            else
            {
               this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
               if(Boolean(CreateAccountGui.vo2Sound.sc))
               {
                  this._voBtn.play();
               }
            }
            this._backBtn.visible = this._isFromWorld ? !this._creationAssets.isCreatingWithoutChoosing : true;
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
            case AVT_NAMES_1:
               index = 0;
               tempArray = {
                  "names":[],
                  "locIds":[]
               };
               break;
            case AVT_NAMES_2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  tempArray = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  index = 2;
               }
               else
               {
                  tempArray = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  index = 1;
               }
               break;
            case AVT_NAMES_3:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  tempArray = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  index = 1;
               }
               else
               {
                  tempArray = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  index = 2;
               }
         }
         if(index != -1)
         {
            for(i = 0; i < locIds.length; i++)
            {
               if(index == 1)
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
               else if(index == 2)
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
               else
               {
                  currName = LocalizationManager.translateIdOnly(locIds[i]);
                  currIndex = Utility.findIndexToInsert(tempArray.names,currName);
                  tempArray.names.splice(currIndex,0,currName);
               }
               tempArray.locIds.splice(currIndex,0,locIds[i]);
            }
            this._avtNames[index] = tempArray;
         }
         if(this._avtNames[0] != -1 && this._avtNames[1] != -1 && this._avtNames[2] != -1)
         {
            this.setupNameLists(this._avtNames[0].names,this._avtNames[1].names,this._avtNames[2].names);
         }
      }
      
      private function onCloseNotEnoughGems() : void
      {
         UpsellManager.displayPopup(UpsellManager.EXTRA_DIAMONDS_AS_MEMBER,"extraDiamonds");
      }
      
      private function onDiamondApprovePurchase() : void
      {
         var avType:int = this._isFromWorld ? this._creationAssets.currType : CreateAccountGui.currType();
         this._newAvatarFacilitator.newAvatarData(avType,this._avatarNameTxt.text,this._avatarNameChosenIds,this.avNameValidCallback,true);
      }
      
      private function onSlotsFullOk(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         this.close();
      }
      
      private function onDiamondShopConfirmBuy(o:Object) : void
      {
         var avDef:Object = null;
         var currGemsCount:int = 0;
         var avType:int = 0;
         if(Boolean(o.status))
         {
            avDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(this._creationAssets.currType)];
            currGemsCount = int(gMainFrame.clientInfo.gemCount);
            if(currGemsCount < avDef.cost)
            {
               DarkenManager.showLoadingSpiral(true);
               Utility.setupNotEnoughGemsPopup(this._creationAssets.parent,avDef.cost,Item.GEM_CURRENCY);
            }
            else
            {
               avType = this._creationAssets.currType;
               this._newAvatarFacilitator.newAvatarData(avType,this._avatarNameTxt.text,this._avatarNameChosenIds,this.avNameValidCallback);
            }
         }
         else
         {
            this.close();
         }
      }
      
      private function avNameValidCallback(valid:Boolean) : void
      {
         if(valid)
         {
            this._isValid = true;
            if(super.parentWizard != null)
            {
               super.parentWizard.next();
            }
            this._newAvatarFacilitator.nameTypeScreenDone();
         }
         else
         {
            DebugUtility.debugTrace("ERROR: Invalid avname?!");
         }
      }
      
      private function setupNameLists(names1:Array, names2:Array, names3:Array) : void
      {
         this._name1Carousel.init(names1,this.names1Changed,false,false,null,false,this._avatarNameIndexes[0]);
         this._name2Carousel.init(names2,this.names2Changed,false,false,null,false,this._avatarNameIndexes[1]);
         this._name3Carousel.init(names3,this.names3Changed,false,false,null,false,this._avatarNameIndexes[2]);
         if(this._avatarNameIndexes[0] == -1)
         {
            this.randomizeNames();
         }
      }
      
      private function randomizeNames() : void
      {
         this._name1Carousel.soundsEnabled = false;
         this._name2Carousel.soundsEnabled = false;
         this._name3Carousel.soundsEnabled = false;
         this._name1Carousel.pickRandomItem(true);
         this._name2Carousel.pickRandomItem(true);
         this._name3Carousel.pickRandomItem(true);
         this._name1Carousel.soundsEnabled = true;
         this._name2Carousel.soundsEnabled = true;
         this._name3Carousel.soundsEnabled = true;
      }
      
      private function names1Changed() : void
      {
         if(Boolean(this._name1Carousel.selectedContentItem) && Boolean(this._name2Carousel.selectedContentItem) && Boolean(this._name3Carousel.selectedContentItem))
         {
            LocalizationManager.updateToFit(this._avatarNameTxt,this._name1Carousel.selectedContentItem + " " + this._name2Carousel.selectedContentItem + this._name3Carousel.selectedContentItem);
            this._avatarNameChosenIds[0] = this._avtNames[0].locIds[this._name1Carousel.contentItemIndex];
            this._avatarNameIndexes[0] = this._name1Carousel.contentItemIndex;
         }
      }
      
      private function names2Changed() : void
      {
         if(Boolean(this._name1Carousel.selectedContentItem) && Boolean(this._name2Carousel.selectedContentItem) && Boolean(this._name3Carousel.selectedContentItem))
         {
            LocalizationManager.updateToFit(this._avatarNameTxt,this._name1Carousel.selectedContentItem + " " + this._name2Carousel.selectedContentItem + this._name3Carousel.selectedContentItem);
            this._avatarNameChosenIds[1] = this._avtNames[1].locIds[this._name2Carousel.contentItemIndex];
            this._avatarNameIndexes[1] = this._name2Carousel.contentItemIndex;
         }
         if(!this._name2Carousel.soundsEnabled && this._isRandomSpin)
         {
            this._name2Carousel.soundsEnabled = true;
            this._name3Carousel.soundsEnabled = true;
            this._isRandomSpin = false;
         }
         if(Boolean(this._avtNames[2]) && this._name3Carousel.hasLoaded)
         {
            if(this._avtNames[1].types[this._name2Carousel.contentItemIndex] != "f")
            {
               if(this._name3Carousel.contentItems != this._avtNames[2].names)
               {
                  this._name3Carousel.contentItems = this._avtNames[2].names;
               }
            }
            else if(Boolean(this._avtNames[2].femNames) && Boolean(this._avtNames[2].femNames[0]) && this._name3Carousel.contentItems != this._avtNames[2].femNames)
            {
               this._name3Carousel.contentItems = this._avtNames[2].femNames;
            }
            if(this._name3Carousel.soundsEnabled)
            {
               this._name3Carousel.soundsEnabled = false;
               this._name3Carousel.spinToIndex(this._name3Carousel.contentItemIndex,true);
               this._name3Carousel.soundsEnabled = true;
            }
            else
            {
               this._name3Carousel.spinToIndex(this._name3Carousel.contentItemIndex,true);
            }
         }
      }
      
      private function names3Changed() : void
      {
         if(Boolean(this._name1Carousel.selectedContentItem) && Boolean(this._name2Carousel.selectedContentItem) && Boolean(this._name3Carousel.selectedContentItem))
         {
            LocalizationManager.updateToFit(this._avatarNameTxt,this._name1Carousel.selectedContentItem + " " + this._name2Carousel.selectedContentItem + this._name3Carousel.selectedContentItem);
            this._avatarNameChosenIds[2] = this._avtNames[2].locIds[this._name3Carousel.contentItemIndex];
            this._avatarNameIndexes[2] = this._name3Carousel.contentItemIndex;
         }
         if(!this._name3Carousel.soundsEnabled && this._isRandomSpin)
         {
            this._name3Carousel.soundsEnabled = true;
            this._name2Carousel.soundsEnabled = true;
            this._isRandomSpin = false;
         }
      }
      
      private function randomLeverMouseDownHandler(m:MouseEvent) : void
      {
         if(this._randomNameLever.currentFrameLabel == "_up")
         {
            this._isRandomSpin = true;
            this._name2Carousel.soundsEnabled = false;
            this._name3Carousel.soundsEnabled = false;
            AJAudio.playRandomLever();
            this._randomNameLever.gotoAndPlay("_play");
            this._name1Carousel.pickRandomItem();
            this._name2Carousel.pickRandomItem();
            this._name3Carousel.pickRandomItem();
         }
      }
      
      private function stopVOButton(e:Event) : void
      {
         CreateAccountGui.vo2Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
      }
      
      private function enableNext() : void
      {
      }
      
      private function tipsNeedTxtClickHandler(m:MouseEvent) : void
      {
      }
      
      private function voBtnClickHandler(m:MouseEvent) : void
      {
         if(CreateAccountGui.vo2Sound.isPlaying)
         {
            CreateAccountGui.vo2Sound.stop();
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo2Sound.play();
            if(Boolean(CreateAccountGui.vo2Sound.sc))
            {
               CreateAccountGui.vo2Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
   }
}

