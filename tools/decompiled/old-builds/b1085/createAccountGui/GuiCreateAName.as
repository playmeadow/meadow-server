package createAccountGui
{
   import achievement.AchievementXtCommManager;
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
      
      public function GuiCreateAName(param1:Object, param2:SBWizard, param3:Boolean)
      {
         this._createANameScreen = param3 ? param1.registrationPanel.createAName : param1.accountCreation.registrationPanel.createAName;
         this._backBtn = param3 ? param1.back_btn : param1.accountCreation.back_btn;
         this._playBtn = param3 ? param1.play_btn : param1.accountCreation.play_btn;
         super(this._createANameScreen,param2);
         this._registrationPanel = MovieClip(this._createANameScreen.parent);
         this._name1Carousel = new GuiCarousel(this._createANameScreen.nameScroller1);
         this._name2Carousel = new GuiCarousel(this._createANameScreen.nameScroller2);
         this._name3Carousel = new GuiCarousel(this._createANameScreen.nameScroller3);
         this._randomNameLever = this._createANameScreen.nameLever;
         this._randomNameLever.addEventListener(MouseEvent.MOUSE_DOWN,this.randomLeverMouseDownHandler,false,0,true);
         this._avatarNameTxt = this._createANameScreen.aml_name_txt;
         this._titleTxt = this._createANameScreen.choose_name_title_txt;
         if(param3)
         {
            this._nextBtn = param1.next_btn;
            this._buyBtnGreen = param1.buy_btn_green;
            this._buyBtnRed = param1.buy_btn_red;
         }
         else
         {
            this._voBtn = this._createANameScreen.vo_btn;
         }
      }
      
      public function init(param1:Object, param2:Boolean = false) : void
      {
         onEnterFromPrev = this.enterFromPrev;
         onEnterFromNext = this.enterFromNext;
         onLeaveToPrev = this.leaveToPrev;
         onLeaveToNext = this.leaveToNext;
         onPlay = param2 ? this.leaveToNext : null;
         onClose = this.close;
         updateScreen = this.updateScreenAssets;
         this._newAvatarFacilitator = param2 ? new NewWorldAvatar() : INewAvatar(param1);
         this._avatarNameTxt.restrict = "A-Za-z0-9 ";
         this._avatarNameTxt.maxChars = 23;
         this._isFromWorld = param2;
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
         if(param2)
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
      
      public function enterFromNext(param1:Boolean = false) : void
      {
         this._isChoosingFirstNonMember = param1;
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
            this._buyBtnGreen.visible = AvatarUtility.creationAssets.hasEnoughGems;
            this._buyBtnRed.visible = !this._buyBtnGreen.visible;
         }
         this._backBtn.visible = this._isFromWorld ? !AvatarUtility.creationAssets.isCreatingWithoutChoosing : true;
         this._isValid = false;
         this.enterFromBoth();
      }
      
      public function enterFromBoth() : void
      {
         if(this._newAvatarFacilitator.playSound)
         {
            if(CreateAccountGui.vo2Sound)
            {
               CreateAccountGui.vo2Sound.play();
               if(CreateAccountGui.vo2Sound.sc)
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
         var _loc1_:int = 0;
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         AJAudio.stopRandomLever();
         AJAudio.stopNameGenRotationSound();
         if(!this._isValid)
         {
            if(this._isFromWorld)
            {
               if(AvatarSwitch.numTotalAvatars >= SwitchManager.NUM_AVATAR_SLOTS)
               {
                  new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14690),true,this.onSlotsFullOk);
                  return true;
               }
               if(AvatarUtility.creationAssets.isCreatingWithoutChoosing)
               {
                  if(!gMainFrame.userInfo.isMember)
                  {
                     _loc2_ = AvatarUtility.avatarDefInfo[AvatarUtility.findAvDefIndexByType(AvatarUtility.creationAssets.currType)];
                     if(_loc2_.isMemberOnly)
                     {
                        UpsellManager.displayPopup(UpsellManager.ANIMALS,"createMembersOnlyAvatar");
                        return false;
                     }
                  }
               }
               if(AvatarUtility.creationAssets.isCreatingWithoutChoosing)
               {
                  if((gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG) & 1 << AvatarUtility.creationAssets.currType - 1) != 0)
                  {
                     _loc3_ = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(AvatarUtility.creationAssets.currType)];
                     new SBYesNoPopup(this._registrationPanel.parent.parent.parent,LocalizationManager.translateIdAndInsertOnly(14782,AvatarUtility.creationAssets.currAvatarName,_loc3_.cost),true,this.onDiamondShopConfirmBuy);
                     return false;
                  }
               }
               if(!this._isChoosingFirstNonMember && !AvatarUtility.creationAssets.hasEnoughGems)
               {
                  DarkenManager.showLoadingSpiral(true);
                  if(AvatarUtility.creationAssets.isCreatingWithoutChoosing)
                  {
                     this.onCloseNotEnoughGems();
                  }
                  else
                  {
                     Utility.setupNotEnoughGemsPopup(AvatarUtility.creationAssets.parent,AvatarUtility.creationAssets.currAvatarCost,AvatarUtility.creationAssets.currencyType);
                  }
                  return false;
               }
               if(AvatarUtility.creationAssets.isCreatingWithoutChoosing)
               {
                  GuiManager.showDiamondConfirmation(AvatarUtility.creationAssets.currAvatarCost,this.onDiamondApprovePurchase);
                  return false;
               }
            }
            _loc1_ = this._isFromWorld ? AvatarUtility.creationAssets.currType : CreateAccountGui.currType();
            this._newAvatarFacilitator.newAvatarData(_loc1_,this._avatarNameTxt.text,this._avatarNameChosenIds,this.avNameValidCallback,this._isFromWorld ? AvatarUtility.creationAssets.isCreatingWithoutChoosing : false);
         }
         if(this._isValid)
         {
            if(CreateAccountGui.vo2Sound)
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
            if(CreateAccountGui.vo2Sound)
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
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         this._createANameScreen = this._registrationPanel.createAName;
         this._avatarNameTxt = this._createANameScreen.aml_name_txt;
         if(this._name1Carousel)
         {
            this._name1Carousel.destroy();
            this._name1Carousel = null;
         }
         this._name1Carousel = new GuiCarousel(this._createANameScreen.nameScroller1);
         if(this._name2Carousel)
         {
            this._name2Carousel.destroy();
            this._name2Carousel = null;
         }
         this._name2Carousel = new GuiCarousel(this._createANameScreen.nameScroller2);
         if(this._name3Carousel)
         {
            this._name3Carousel.destroy();
            this._name3Carousel = null;
         }
         this._name3Carousel = new GuiCarousel(this._createANameScreen.nameScroller3);
         this.setupNameLists(this._avtNames[0].names,this._avtNames[1].names,this._avtNames[2].names);
         if(param1 || (this._isFromWorld ? Boolean(AvatarUtility.creationAssets.isCreatingWithoutChoosing) : Boolean(false)))
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
               this._buyBtnGreen.visible = AvatarUtility.creationAssets.hasEnoughGems;
               this._buyBtnRed.visible = !this._buyBtnGreen.visible;
            }
            else
            {
               this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
               if(CreateAccountGui.vo2Sound.sc)
               {
                  this._voBtn.play();
               }
            }
            this._backBtn.visible = this._isFromWorld ? !AvatarUtility.creationAssets.isCreatingWithoutChoosing : true;
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
            case AVT_NAMES_1:
               _loc4_ = 0;
               _loc3_ = {
                  "names":[],
                  "locIds":[]
               };
               break;
            case AVT_NAMES_2:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc3_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc4_ = 2;
               }
               else
               {
                  _loc3_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc4_ = 1;
               }
               break;
            case AVT_NAMES_3:
               if(LocalizationManager.isCurrLanguageReversed())
               {
                  _loc3_ = {
                     "names":[],
                     "types":[],
                     "locIds":[]
                  };
                  _loc4_ = 1;
               }
               else
               {
                  _loc3_ = {
                     "names":[],
                     "femNames":[],
                     "locIds":[]
                  };
                  _loc4_ = 2;
               }
         }
         if(_loc4_ != -1)
         {
            _loc8_ = 0;
            while(_loc8_ < param2.length)
            {
               if(_loc4_ == 1)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(param2[_loc8_]).split("$");
                  _loc6_ = _loc5_[0];
                  _loc7_ = Utility.findIndexToInsert(_loc3_.names,_loc6_);
                  _loc3_.names.splice(_loc7_,0,_loc6_);
                  if(_loc5_[1])
                  {
                     _loc3_.types.splice(_loc7_,0,_loc5_[1]);
                  }
               }
               else if(_loc4_ == 2)
               {
                  _loc5_ = LocalizationManager.translateIdOnly(param2[_loc8_]).split("$");
                  _loc6_ = _loc5_[0].toLowerCase();
                  _loc7_ = Utility.findIndexToInsert(_loc3_.names,_loc6_);
                  _loc3_.names.splice(_loc7_,0,_loc6_);
                  if(_loc5_[1])
                  {
                     _loc3_.femNames.splice(_loc7_,0,_loc5_[1].toLowerCase());
                  }
               }
               else
               {
                  _loc6_ = LocalizationManager.translateIdOnly(param2[_loc8_]);
                  _loc7_ = Utility.findIndexToInsert(_loc3_.names,_loc6_);
                  _loc3_.names.splice(_loc7_,0,_loc6_);
               }
               _loc3_.locIds.splice(_loc7_,0,param2[_loc8_]);
               _loc8_++;
            }
            this._avtNames[_loc4_] = _loc3_;
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
         var _loc1_:int = this._isFromWorld ? AvatarUtility.creationAssets.currType : CreateAccountGui.currType();
         this._newAvatarFacilitator.newAvatarData(_loc1_,this._avatarNameTxt.text,this._avatarNameChosenIds,this.avNameValidCallback,true);
      }
      
      private function onSlotsFullOk(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         this.close();
      }
      
      private function onDiamondShopConfirmBuy(param1:Object) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(param1.status)
         {
            _loc2_ = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(AvatarUtility.creationAssets.currType)];
            _loc3_ = int(gMainFrame.clientInfo.gemCount);
            if(_loc3_ < _loc2_.cost)
            {
               DarkenManager.showLoadingSpiral(true);
               Utility.setupNotEnoughGemsPopup(AvatarUtility.creationAssets.parent,_loc2_.cost,Item.GEM_CURRENCY);
            }
            else
            {
               _loc4_ = AvatarUtility.creationAssets.currType;
               this._newAvatarFacilitator.newAvatarData(_loc4_,this._avatarNameTxt.text,this._avatarNameChosenIds,this.avNameValidCallback);
            }
         }
         else
         {
            this.close();
         }
      }
      
      private function avNameValidCallback(param1:Boolean) : void
      {
         if(param1)
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
      
      private function setupNameLists(param1:Array, param2:Array, param3:Array) : void
      {
         this._name1Carousel.init(param1,this.names1Changed,false,false,null,false,this._avatarNameIndexes[0]);
         this._name2Carousel.init(param2,this.names2Changed,false,false,null,false,this._avatarNameIndexes[1]);
         this._name3Carousel.init(param3,this.names3Changed,false,false,null,false,this._avatarNameIndexes[2]);
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
            if(this._name3Carousel.contentItems == this._avtNames[2].femNames)
            {
               this._name3Carousel.contentItems = this._avtNames[2].names;
            }
            else if(Boolean(this._avtNames[2].femNames) && Boolean(this._avtNames[2].femNames[0]))
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
      
      private function randomLeverMouseDownHandler(param1:MouseEvent) : void
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
      
      private function stopVOButton(param1:Event) : void
      {
         CreateAccountGui.vo2Sound.stop();
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
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
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo2Sound.play();
            if(CreateAccountGui.vo2Sound.sc)
            {
               CreateAccountGui.vo2Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
   }
}

