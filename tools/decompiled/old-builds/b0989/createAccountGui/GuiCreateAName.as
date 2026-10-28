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
   
   public class GuiCreateAName extends SBScreen
   {
      
      private static const AVT_NAMES_1:int = 1610;
      
      private static const AVT_NAMES_2:int = 1611;
      
      private static const AVT_NAMES_3:int = 1612;
      
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
      
      private var _avtNames:Array;
      
      private var _newAvatarFacilitator:INewAvatar;
      
      private var _isFromWorld:Boolean;
      
      private var _isChoosingFirstNonMember:Boolean;
      
      private var _isValid:Boolean;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      public function GuiCreateAName(param1:Object, param2:SBWizard, param3:Boolean)
      {
         this._createANameScreen = param3 ? param1.registrationPanel.createAName : param1.accountCreation.registrationPanel.createAName;
         this._backBtn = param3 ? param1.back_btn : param1.accountCreation.back_btn;
         this._playBtn = param3 ? param1.play_btn : param1.accountCreation.play_btn;
         super(this._createANameScreen,param2);
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
         this._newAvatarFacilitator = param2 ? new NewWorldAvatar() : INewAvatar(param1);
         this._avatarNameIndexes = new Array(3);
         LocalizationXtCommManager.sendTranslateStringRequest(AVT_NAMES_1,LocalizationXtCommManager.LANG_ENG,this.onAvtNameListReceived);
         LocalizationXtCommManager.sendTranslateStringRequest(AVT_NAMES_2,LocalizationXtCommManager.LANG_ENG,this.onAvtNameListReceived);
         LocalizationXtCommManager.sendTranslateStringRequest(AVT_NAMES_3,LocalizationXtCommManager.LANG_ENG,this.onAvtNameListReceived);
         this._avatarNameTxt.restrict = "A-Za-z0-9 ";
         this._avatarNameTxt.maxChars = 23;
         this._isFromWorld = param2;
         if(!this._isFromWorld)
         {
            this._voBtn.stop();
            this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
         }
         this._backBtn.visible = false;
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
         MovieClip(this._createANameScreen.parent).gotoAndPlay("backChooseAName");
         CreateAccountGui.currAvatar().gotoAndPlay("backChooseAName");
         MovieClip(this._createANameScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("backChooseAName");
         this.enterFromBoth();
      }
      
      public function enterFromPrev() : void
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
         this._newAvatarFacilitator.hideConnectingMsg();
         this._name1Carousel.pickRandomItem(true);
         this._name2Carousel.pickRandomItem(true);
         this._name3Carousel.pickRandomItem(true);
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
         if(!this._isValid)
         {
            if(this._isFromWorld)
            {
               if(AvatarSwitch.numTotalAvatars >= SwitchManager.NUM_AVATAR_SLOTS)
               {
                  new SBOkPopup(GuiManager.guiLayer,"You don\'t have any open animal slots. Free an animal.",true,this.onSlotsFullOk);
                  return true;
               }
               if(AvatarUtility.creationAssets.isCreatingWithoutChoosing)
               {
                  if((gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG) & 1 << AvatarUtility.creationAssets.currType - 1) != 0)
                  {
                     _loc2_ = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(AvatarUtility.creationAssets.currType)];
                     new SBYesNoPopup(this._createANameScreen.parent.parent.parent.parent,"You already have the " + AvatarUtility.creationAssets.currAvatarName + ". Would you like to create another one for " + _loc2_.cost + " gems?",true,this.onDiamondShopConfirmBuy);
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
            this._newAvatarFacilitator.newAvatarData(_loc1_,this._avatarNameTxt.text,this._avatarNameIndexes,this.avNameValidCallback,this._isFromWorld ? AvatarUtility.creationAssets.isCreatingWithoutChoosing : false);
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
               MovieClip(this._createANameScreen.parent).gotoAndPlay("playPlayerAccountOne");
               CreateAccountGui.currAvatar().gotoAndPlay("playPlayerAccountOne");
               MovieClip(this._createANameScreen.parent.parent).bg[CreateAccountGui.currBG() + "Bg"].gotoAndPlay("playPlayerAccountOne");
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
      
      public function close() : void
      {
         AvatarSwitch.addAvatarCallback = null;
         this._newAvatarFacilitator.nameTypeScreenDone();
      }
      
      private function onCloseNotEnoughGems() : void
      {
         UpsellManager.displayPopup(UpsellManager.EXTRA_DIAMONDS_AS_MEMBER,"extraDiamonds");
      }
      
      private function onDiamondApprovePurchase() : void
      {
         var _loc1_:int = this._isFromWorld ? AvatarUtility.creationAssets.currType : CreateAccountGui.currType();
         this._newAvatarFacilitator.newAvatarData(_loc1_,this._avatarNameTxt.text,this._avatarNameIndexes,this.avNameValidCallback,true);
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
               this._newAvatarFacilitator.newAvatarData(_loc4_,this._avatarNameTxt.text,this._avatarNameIndexes,this.avNameValidCallback);
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
      
      private function onAvtNameListReceived(param1:int, param2:String) : void
      {
         if(this._avtNames == null)
         {
            this._avtNames = [];
         }
         var _loc3_:Array = param2.split("|");
         var _loc4_:int = -1;
         if(param1 == AVT_NAMES_1)
         {
            _loc4_ = 0;
         }
         else if(param1 == AVT_NAMES_2)
         {
            _loc4_ = 1;
         }
         else if(param1 == AVT_NAMES_3)
         {
            _loc4_ = 2;
         }
         this._avtNames[_loc4_] = _loc3_;
         if(Boolean(this._avtNames[0]) && Boolean(this._avtNames[1]) && Boolean(this._avtNames[2]))
         {
            this.setupNameLists(this._avtNames[0],this._avtNames[1],this._avtNames[2]);
         }
      }
      
      private function setupNameLists(param1:Array, param2:Array, param3:Array) : void
      {
         this._name1Carousel.init(param1,this.names1Changed);
         this._name2Carousel.init(param2,this.names2Changed);
         this._name3Carousel.init(param3,this.names3Changed);
         this.randomizeNames();
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
            this._avatarNameTxt.text = this._name1Carousel.selectedContentItem + " " + this._name2Carousel.selectedContentItem + this._name3Carousel.selectedContentItem;
            this._avatarNameIndexes[0] = this._name1Carousel.contentItemIndex;
         }
         if(!this._name1Carousel.soundsEnabled)
         {
            this._name1Carousel.soundsEnabled = true;
         }
      }
      
      private function names2Changed() : void
      {
         if(Boolean(this._name1Carousel.selectedContentItem) && Boolean(this._name2Carousel.selectedContentItem) && Boolean(this._name3Carousel.selectedContentItem))
         {
            this._avatarNameTxt.text = this._name1Carousel.selectedContentItem + " " + this._name2Carousel.selectedContentItem + this._name3Carousel.selectedContentItem;
            this._avatarNameIndexes[1] = this._name2Carousel.contentItemIndex;
         }
         if(!this._name2Carousel.soundsEnabled)
         {
            this._name2Carousel.soundsEnabled = true;
         }
      }
      
      private function names3Changed() : void
      {
         if(Boolean(this._name1Carousel.selectedContentItem) && Boolean(this._name2Carousel.selectedContentItem) && Boolean(this._name3Carousel.selectedContentItem))
         {
            this._avatarNameTxt.text = this._name1Carousel.selectedContentItem + " " + this._name2Carousel.selectedContentItem + this._name3Carousel.selectedContentItem;
            this._avatarNameIndexes[2] = this._name3Carousel.contentItemIndex;
         }
         if(!this._name3Carousel.soundsEnabled)
         {
            this._name3Carousel.soundsEnabled = true;
         }
      }
      
      private function randomLeverMouseDownHandler(param1:MouseEvent) : void
      {
         if(this._randomNameLever.currentFrameLabel == "_up")
         {
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

