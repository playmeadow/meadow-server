package createAccountGui
{
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.NewWorldAvatar;
   import com.sbi.analytics.SBTracker;
   import com.sbi.popup.SBOkPopup;
   import com.sbi.popup.SBScreen;
   import com.sbi.popup.SBWizard;
   import createAccountFlow.CreateAccountGui;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import gui.ItemWindowAvatarOrPetSelect;
   import gui.LoadingSpiral;
   import gui.SBScrollbar;
   import gui.UpsellManager;
   import gui.WindowGenerator;
   import item.Item;
   import localization.LocalizationManager;
   
   public class GuiChooseAnimal extends SBScreen
   {
      
      private var _chooseScreen:MovieClip;
      
      private var _voBtn:MovieClip;
      
      private var _backBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _playBtn:MovieClip;
      
      private var _itemWindow:MovieClip;
      
      private var _avatarHolder:MovieClip;
      
      private var _currAvatarImage:MovieClip;
      
      private var _currAvt:Avatar;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _buyBtnDiamondGreen:MovieClip;
      
      private var _buyBtnDiamondRed:MovieClip;
      
      private var _tag:MovieClip;
      
      private var _amlNameTxt:TextField;
      
      private var _titleText:TextField;
      
      private var _avatarWindows:WindowGenerator;
      
      private var _scrollBar:SBScrollbar;
      
      private var _itemsLoadingSpiral:LoadingSpiral;
      
      private var _currAvatarIconIds:Array;
      
      private var _currAvatarTypes:Array;
      
      private var _currCreationAvatars:Array;
      
      private var _oceanOnlyIconIds:Array;
      
      private var _oceanOnlyTypes:Array;
      
      private var _usableAvatarIconIds:Array;
      
      private var _usableAvatarTypes:Array;
      
      private var _usableCreationAvatars:Array;
      
      private var _currBG:String;
      
      private var _avatarNamesByType:Object;
      
      private var _newAvatarFacilitator:NewWorldAvatar;
      
      private var _currType:int;
      
      private var _myCurrencyCount:int;
      
      private var _currCost:int;
      
      private var _currIndex:int;
      
      private var _isChoosingOceanAvatars:Boolean;
      
      private var _isChoosingFirstNonMember:Boolean;
      
      private var _isFromWorld:Boolean;
      
      private var _hasEnoughGems:Boolean;
      
      private var _wizard:SBWizard;
      
      private var _isCreatingWithoutChoosing:Boolean;
      
      private var _diamondCost:int;
      
      private var _currencyType:int;
      
      private var _scrollYValue:int;
      
      private var _originalWindowsHeight:int;
      
      private var _originalWindowsWidth:int;
      
      private var _isMovingScreens:Boolean;
      
      private var _registrationPanel:MovieClip;
      
      private var _avatarSelect:MovieClip;
      
      private var _isFastPass:Boolean;
      
      public function GuiChooseAnimal(param1:Object, param2:SBWizard, param3:Boolean, param4:Boolean = false)
      {
         this._chooseScreen = param3 ? param1.registrationPanel.chooseAnimal : param1.registrationPanel.chooseAnimal;
         super(this._chooseScreen,param2);
         this._registrationPanel = MovieClip(this._chooseScreen.parent);
         this._avatarSelect = MovieClip(this._chooseScreen.parent.parent);
         this._amlNameTxt = this._chooseScreen.animalNameText;
         this._itemWindow = this._chooseScreen.itemWindow;
         this._titleText = this._chooseScreen.titleText;
         this._isFromWorld = param3;
         this._wizard = param2;
         this._isFastPass = param4;
         this._voBtn = this._chooseScreen.vo_btn;
         this._playBtn = param1.play_btn;
         this._backBtn = param1.back_btn;
         this._nextBtn = param1.next_btn;
         this._avatarHolder = param1.allAvatars;
         if(param3)
         {
            this._buyBtnGreen = param1.buy_btn_green;
            this._buyBtnRed = param1.buy_btn_red;
            this._buyBtnDiamondGreen = param1.diamond_buy_btn_green;
            this._buyBtnDiamondRed = param1.diamond_buy_btn_red;
            this._tag = this._chooseScreen.tag;
         }
      }
      
      public function init() : void
      {
         onEnterFromNext = this.enterFromNext;
         onEnterFromPrev = this.enterFromPrev;
         onLeaveToPrev = this.leaveToPrev;
         onLeaveToNext = this.leaveToNext;
         onClose = this.leaveToPrev;
         updateScreen = this.updateScreenAssets;
         if(!this._isFromWorld || this._isFastPass)
         {
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
            this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
         }
         if(this._isFromWorld)
         {
            this._buyBtnGreen.visible = false;
            this._buyBtnRed.visible = false;
            this._buyBtnDiamondGreen.visible = false;
            this._buyBtnDiamondRed.visible = false;
            this._tag.visible = false;
            this._voBtn.visible = this._isFastPass;
            this._chooseScreen.reg.visible = !this._isFastPass;
            this._chooseScreen.fastTrack.visible = this._isFastPass;
         }
         this._backBtn.visible = false;
         this._playBtn.visible = false;
         this._amlNameTxt.text = "";
         this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
         this._newAvatarFacilitator = new NewWorldAvatar();
         this._usableAvatarIconIds = [];
         this._usableAvatarTypes = [];
         this._usableCreationAvatars = [];
         this._currAvatarIconIds = [];
         this._currAvatarTypes = [];
         this._currCreationAvatars = [];
         this._avatarNamesByType = [];
         this._oceanOnlyIconIds = [];
         this._itemsLoadingSpiral = new LoadingSpiral(this._itemWindow,this._itemWindow.width * 0.5,this._itemWindow.height * 0.5);
         this._itemsLoadingSpiral.visible = true;
         this.setupIcons();
         if((!this._isFromWorld || this._isFastPass) && Boolean(CreateAccountGui.vo1Sound))
         {
            CreateAccountGui.vo1Sound.play();
            if(CreateAccountGui.vo1Sound.sc)
            {
               CreateAccountGui.vo1Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
      
      override public function destroy() : void
      {
         if(this._avatarWindows)
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         if(this._scrollBar)
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         super.destroy();
      }
      
      public function destroyReloadedItems() : void
      {
         if(this._avatarWindows)
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         if(this._scrollBar)
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
      }
      
      public function setup(param1:Boolean, param2:Boolean, param3:int = -1, param4:Boolean = false, param5:Boolean = false) : void
      {
         this._isMovingScreens = false;
         this._currencyType = this.currencyType;
         this._isFastPass = param5;
         this.setupIcons(true);
         if(this.currencyType == Item.GEM_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
         }
         else if(this.currencyType == Item.DIAMOND_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
         }
         this._isChoosingOceanAvatars = param1;
         this._isChoosingFirstNonMember = param2;
         this._nextBtn.visible = true;
         this._buyBtnGreen.visible = false;
         this._buyBtnRed.visible = false;
         this._buyBtnDiamondGreen.visible = false;
         this._buyBtnDiamondRed.visible = false;
         this._backBtn.visible = false;
         this._isCreatingWithoutChoosing = param4;
         if(this._isChoosingOceanAvatars)
         {
            this._currAvatarIconIds = this._oceanOnlyIconIds;
            this._currAvatarTypes = this._oceanOnlyTypes;
         }
         else
         {
            this._currAvatarIconIds = this._usableAvatarIconIds;
            this._currAvatarTypes = this._usableAvatarTypes;
            this._currCreationAvatars = this._usableCreationAvatars;
         }
         this.pickRandomAvatar(param3);
         this._wizard.creationAssets.creationWiz.step = param4 ? 2 : 1;
         if(Boolean(this._currAvatarImage) && Boolean(this._currBG))
         {
            if(!param4)
            {
               this.enterFromPrev();
               this._nextBtn.visible = true;
               this._tag.visible = true;
            }
            else
            {
               this._nextBtn.visible = false;
               this._tag.visible = false;
            }
         }
         if(!param4)
         {
            this.createAvatarWindows();
         }
      }
      
      public function enterFromNext() : void
      {
         this._registrationPanel.gotoAndPlay("backChooseAnAnimal");
         this._currAvatarImage.gotoAndPlay("backChooseAnAnimal");
         this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("backChooseAnAnimal");
         if(this._isFromWorld)
         {
            this._buyBtnGreen.visible = false;
            this._buyBtnRed.visible = false;
            this._buyBtnDiamondGreen.visible = false;
            this._buyBtnDiamondRed.visible = false;
            this._nextBtn.visible = true;
         }
         this.enterFromBoth();
      }
      
      public function enterFromPrev() : void
      {
         this._registrationPanel.gotoAndStop("intro");
         if(this._currAvatarImage)
         {
            this._currAvatarImage.gotoAndStop("chooseAnAnimal");
         }
         if(this._currBG)
         {
            this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("intro");
         }
         this.enterFromBoth();
      }
      
      public function enterFromBoth() : void
      {
         if((!this._isFromWorld || this._isFastPass) && Boolean(CreateAccountGui.vo1Sound))
         {
            if(!CreateAccountGui.vo1Sound.isPlaying)
            {
               CreateAccountGui.vo1Sound.play();
               if(CreateAccountGui.vo1Sound.sc)
               {
                  CreateAccountGui.vo1Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
                  this._voBtn.play();
               }
            }
         }
         this._isMovingScreens = false;
         if(this._isFromWorld)
         {
            SBTracker.trackPageview("/game/play/popup/avatarCreation/ChooseAnimal");
         }
         else
         {
            CreateAccountGui.trackUserCreateAccountPageChange("ChooseAnimal");
         }
      }
      
      public function leaveToNext() : Boolean
      {
         var _loc1_:Object = null;
         if(this._nextBtn.isGray)
         {
            return false;
         }
         if(!this._isFromWorld || this._isFastPass)
         {
            if(CreateAccountGui.vo1Sound)
            {
               CreateAccountGui.vo1Sound.stop();
            }
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         if(!gMainFrame.userInfo.isMember)
         {
            _loc1_ = AvatarUtility.findAvDefByType(this._currType,this.currCustomAvId);
            if(_loc1_.isMemberOnly)
            {
               if(this._isCreatingWithoutChoosing)
               {
                  if(this._registrationPanel.currentFrameLabel != "chooseAName")
                  {
                     this._registrationPanel.gotoAndStop("chooseAName");
                  }
                  if(this._currAvatarImage.currentFrameLabel != "chooseAName")
                  {
                     this._currAvatarImage.gotoAndStop("chooseAName");
                  }
                  if(this._avatarSelect.bg[this._currBG + "Bg"].currentFrameLabel != "chooseAName")
                  {
                     this._avatarSelect.bg[this._currBG + "Bg"].gotoAndStop("chooseAName");
                  }
                  return true;
               }
               UpsellManager.displayPopup(UpsellManager.ANIMALS,"createMembersOnlyAvatar");
            }
            else if(AvatarUtility.numNonMemberAvatars() >= 2 && !this._isChoosingFirstNonMember)
            {
               UpsellManager.displayPopup(UpsellManager.ANIMAL_SLOTS,"buyThirdAvatar");
            }
            else
            {
               if(!(this._isChoosingFirstNonMember && _loc1_.enviroFlag == 2))
               {
                  if(this._isCreatingWithoutChoosing)
                  {
                     this._registrationPanel.gotoAndStop("chooseAName");
                     this._currAvatarImage.gotoAndStop("chooseAName");
                     this._avatarSelect.bg[this._currBG + "Bg"].gotoAndStop("chooseAName");
                  }
                  else
                  {
                     this._registrationPanel.gotoAndPlay("playChooseAName");
                     this._currAvatarImage.gotoAndPlay("playChooseAName");
                     this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("playChooseAName");
                  }
                  this._isMovingScreens = true;
                  return true;
               }
               new SBOkPopup(this._avatarSelect.parent.parent,LocalizationManager.translateIdOnly(14689));
            }
            return false;
         }
         if(this._isCreatingWithoutChoosing)
         {
            this._registrationPanel.gotoAndStop("chooseAName");
            this._currAvatarImage.gotoAndStop("chooseAName");
            this._avatarSelect.bg[this._currBG + "Bg"].gotoAndStop("chooseAName");
         }
         else
         {
            this._registrationPanel.gotoAndPlay("playChooseAName");
            this._currAvatarImage.gotoAndPlay("playChooseAName");
            this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("playChooseAName");
         }
         this._isMovingScreens = true;
         return true;
      }
      
      public function leaveToPrev() : Boolean
      {
         if(!this._isFromWorld || this._isFastPass)
         {
            if(CreateAccountGui.vo1Sound)
            {
               CreateAccountGui.vo1Sound.stop();
            }
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         this._newAvatarFacilitator.nameTypeScreenDone();
         this._isMovingScreens = true;
         return true;
      }
      
      public function leaveToBoth() : Boolean
      {
         return true;
      }
      
      public function updateScreenAssets(param1:Boolean = false) : void
      {
         this._chooseScreen = this._registrationPanel.chooseAnimal;
         this._amlNameTxt = this._chooseScreen.animalNameText;
         this._itemWindow = this._chooseScreen.itemWindow;
         this._titleText = this._chooseScreen.titleText;
         this._voBtn = this._chooseScreen.vo_btn;
         if(this._isFromWorld)
         {
            this._tag = this._chooseScreen.tag;
            this._buyBtnGreen = this._avatarSelect.buy_btn_green;
            this._buyBtnRed = this._avatarSelect.buy_btn_red;
            this._buyBtnDiamondGreen = this._avatarSelect.diamond_buy_btn_green;
            this._buyBtnDiamondRed = this._avatarSelect.diamond_buy_btn_red;
         }
         if(param1)
         {
            this.setupAvatarTextItems();
            this.createAvatarWindows();
            if(this._isFromWorld)
            {
               this._buyBtnGreen.visible = false;
               this._buyBtnRed.visible = false;
               this._buyBtnDiamondGreen.visible = false;
               this._buyBtnDiamondRed.visible = false;
               this._tag.visible = true;
            }
            if(!this._isFromWorld || this._isFastPass)
            {
               this._playBtn.visible = false;
               this._voBtn.stop();
               this._voBtn.gotoAndStop(1);
               this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
               this._voBtn = this._chooseScreen.vo_btn;
            }
            if((!this._isFromWorld || this._isFastPass) && Boolean(CreateAccountGui.vo1Sound))
            {
               if(CreateAccountGui.vo1Sound.sc)
               {
                  this._voBtn.play();
               }
            }
         }
      }
      
      public function get currencyType() : int
      {
         return this._currencyType;
      }
      
      public function get isCreatingWithoutChoosing() : Boolean
      {
         return this._isCreatingWithoutChoosing;
      }
      
      public function get currAvatarImage() : MovieClip
      {
         return this._currAvatarImage;
      }
      
      public function get currAvatar() : Avatar
      {
         return this._currAvt;
      }
      
      public function get currBG() : String
      {
         return this._currBG;
      }
      
      public function get currType() : int
      {
         return this._currType;
      }
      
      public function get currCustomAvId() : int
      {
         if(this._currAvt)
         {
            return this._currAvt.customAvId;
         }
         return -1;
      }
      
      public function get hasEnoughGems() : Boolean
      {
         return this._hasEnoughGems;
      }
      
      public function get currAvatarCost() : int
      {
         return this._diamondCost == -1 ? this._currCost : this._diamondCost;
      }
      
      public function get currAvatarName() : String
      {
         return LocalizationManager.translateIdOnly(this._avatarNamesByType[this._currType + (this.currCustomAvId == -1 ? "0" : "1")]);
      }
      
      public function get isDiamondAvatar() : Boolean
      {
         return AvatarUtility.findAvDefByType(this._currType,this.currCustomAvId).isDiamond;
      }
      
      public function get avatarDiamondDefId() : int
      {
         return AvatarUtility.findAvDefByType(this._currType,this.currCustomAvId).diamondDefId;
      }
      
      private function setCurrAvatarNameText() : void
      {
         var _loc1_:int = parseInt(this._currType + (this.currCustomAvId == -1 ? "0" : "1"));
         if(this._avatarNamesByType[_loc1_])
         {
            LocalizationManager.translateId(this._amlNameTxt,this._avatarNamesByType[_loc1_]);
         }
      }
      
      private function setupIcons(param1:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Avatar = null;
         var _loc2_:Array = AvatarUtility.creationAvatarsList;
         this._usableAvatarIconIds = [];
         this._usableAvatarTypes = [];
         this._oceanOnlyIconIds = [];
         this._oceanOnlyTypes = [];
         var _loc6_:int = 0;
         for(; _loc6_ < _loc2_.length; _loc6_++)
         {
            try
            {
               _loc4_ = AvatarUtility.getAvatarDefByIndex(_loc6_);
               if(_loc4_)
               {
                  _loc5_ = _loc2_[_loc6_];
                  _loc3_ = int(gMainFrame.userInfo.getAvatarDefByAvatar(_loc5_).iconMediaId);
                  if(this._isFastPass && (Boolean(_loc4_.isDiamond || _loc4_.isMemberOnly) || Boolean(!Utility.isLand(_loc4_.enviroFlag))))
                  {
                     continue;
                  }
                  if((!this._isFromWorld || this._isFastPass) && (AvatarUtility.isEndangered(_loc4_.availability) || AvatarUtility.isExtinct(_loc4_.availability)))
                  {
                     continue;
                  }
                  if(Boolean(_loc4_.isDiamond) || AvatarUtility.getAvatarDefIsViewable(_loc5_,_loc5_.customAvId != -1))
                  {
                     this._usableAvatarIconIds.push(_loc3_);
                     this._usableAvatarTypes.push(_loc5_.avTypeId);
                     this._usableCreationAvatars.push(_loc5_);
                     if(Utility.isOcean(_loc4_.enviroFlag) && !this._isFastPass)
                     {
                        this._oceanOnlyIconIds.push(_loc3_);
                        this._oceanOnlyTypes.push(_loc5_.avTypeId);
                     }
                  }
                  this._avatarNamesByType[_loc5_.avTypeId + (_loc5_.customAvId != -1 ? "1" : "0")] = gMainFrame.userInfo.getAvatarDefByAvatar(_loc5_).titleStrRef;
                  if(Boolean(this._currType) && _loc5_.avTypeId == this._currType)
                  {
                     this.setCurrAvatarNameText();
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         this._currAvatarIconIds = this._usableAvatarIconIds;
         this._currAvatarTypes = this._usableAvatarTypes;
         this._currCreationAvatars = this._usableCreationAvatars;
         if((!this._isFromWorld || this._isFastPass) && !param1)
         {
            this.pickRandomAvatar();
            this.createAvatarWindows();
         }
      }
      
      private function pickRandomAvatar(param1:int = -1) : void
      {
         var _loc2_:int = 0;
         if(param1 == -1)
         {
            this._currIndex = Math.floor(Math.random() * (this._currAvatarTypes.length - 1 - 0 + 1)) + 0;
            param1 = int(this._currAvatarTypes[this._currIndex]);
         }
         else
         {
            _loc2_ = 0;
            while(_loc2_ < this._currAvatarTypes.length)
            {
               if(this._currAvatarTypes[_loc2_] == param1)
               {
                  this._currIndex = _loc2_;
                  break;
               }
               _loc2_++;
            }
         }
         this._currType = param1;
         this._currAvt = this._currCreationAvatars[this._currIndex];
         this.setupCurrAvatar();
      }
      
      private function createAvatarWindows() : void
      {
         if(Boolean(this._avatarWindows) && this._avatarWindows.numWindowsCreated > 0)
         {
            this._itemWindow.addChild(this._avatarWindows);
            if(this._isFromWorld && !this._isFastPass)
            {
               if(this._scrollBar)
               {
                  this._scrollYValue = this._scrollBar.scrollYValue;
                  this._scrollBar.destroy();
                  this._scrollBar = null;
               }
               this._scrollBar = new SBScrollbar();
               this._scrollBar.init(this._avatarWindows,this._originalWindowsWidth,this._avatarWindows.boxHeight * 3 + 2 * 3,12,"scrollbar2",this._avatarWindows.boxHeight + 2,this._scrollYValue,this._originalWindowsHeight);
            }
            return;
         }
         this._itemsLoadingSpiral.visible = true;
         if(this._scrollBar)
         {
            this._scrollYValue = this._scrollBar.scrollYValue;
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(this._avatarWindows)
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         this._avatarWindows = new WindowGenerator();
         this._avatarWindows.init(3,3,this._currAvatarIconIds.length,2,2,2,ItemWindowAvatarOrPetSelect,this._currAvatarIconIds,"",{
            "mouseDown":this.winMouseDown,
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut
         },{
            "forCreation":!this._isFromWorld || this._isFastPass,
            "avTypes":this._currAvatarTypes,
            "creationAvatars":this._currCreationAvatars,
            "selectedIndex":this._currIndex
         },this.onAvatarIconWindowsLoaded,false,false);
         this._itemWindow.addChild(this._avatarWindows);
      }
      
      private function onAvatarIconWindowsLoaded() : void
      {
         if(this._isFromWorld && !this._isFastPass && this._scrollBar == null)
         {
            this._originalWindowsHeight = this._avatarWindows.height;
            this._originalWindowsWidth = this._avatarWindows.width;
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._avatarWindows,this._originalWindowsWidth,this._avatarWindows.boxHeight * 3 + 2 * 3,12,"scrollbar2",this._avatarWindows.boxHeight + 2,this._scrollYValue,this._originalWindowsHeight);
            this._scrollBar.scrollToElement(this._currIndex / 3,true);
         }
         this._itemsLoadingSpiral.visible = false;
      }
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._isMovingScreens && this._currIndex != param1.currentTarget.index)
         {
            MovieClip(this._avatarWindows.bg.getChildAt(this._currIndex)).deselect();
            this._currIndex = param1.currentTarget.index;
            this._currType = this._currAvatarTypes[param1.currentTarget.index];
            this._currAvt = this._currCreationAvatars[this._currIndex];
            if(param1.currentTarget.currWindow.currentFrameLabel != (param1.currentTarget.isDiamond ? "diamond_down" : "down"))
            {
               param1.currentTarget.currWindow.gotoAndStop(param1.currentTarget.isDiamond ? "diamond_down" : "down");
            }
            param1.currentTarget.setupLayers();
            this.setupCurrAvatar();
         }
      }
      
      private function setupCurrAvatar() : void
      {
         var _loc2_:Array = null;
         var _loc1_:Array = this._avatarHolder.currentLabels;
         var _loc3_:String = this.currCustomAvId != -1 ? "special_" : "";
         var _loc4_:int = this.currCustomAvId != -1 ? this.currCustomAvId : this._currType;
         var _loc5_:int = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc2_ = _loc1_[_loc5_].name.split("_");
            if(_loc3_ == "" && _loc2_[1] == _loc4_ || _loc3_.indexOf(_loc2_[0]) >= 0 && _loc2_[2] == _loc4_)
            {
               this._currBG = _loc3_ == "" ? _loc2_[0] : _loc2_[1];
               this._avatarHolder.gotoAndStop(_loc3_ + this._currBG + "_" + _loc4_);
               this._currAvatarImage = this._avatarHolder[_loc3_ + "avatar" + _loc4_];
               break;
            }
            _loc5_++;
         }
         if(this._currAvatarImage)
         {
            this._currAvatarImage.gotoAndPlay("intro");
            this.setupAvatarTextItems();
         }
         if(this._currBG)
         {
            if(this._avatarSelect.bg.currentFrameLabel != this._currBG)
            {
               this._avatarSelect.bg.gotoAndStop(this._currBG);
               this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("intro");
            }
         }
      }
      
      private function setupAvatarTextItems() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Boolean = false;
         if(this._currAvatarImage)
         {
            this.setCurrAvatarNameText();
            _loc1_ = AvatarUtility.findAvDefByType(this._currType,this.currCustomAvId);
            if(this._isFromWorld)
            {
               _loc2_ = Boolean(_loc1_.isDiamond) && !AvatarUtility.getAvatarDefIsViewableWithAvId(this._currType,this.currCustomAvId != -1);
               if(_loc2_)
               {
                  this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
                  this._diamondCost = _loc1_.diamondCost;
               }
               else
               {
                  this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
                  this._diamondCost = -1;
               }
               this._currCost = this._diamondCost == -1 ? int(_loc1_.cost) : this._diamondCost;
               if(!this._isChoosingFirstNonMember)
               {
                  this._tag.txt.text = Utility.convertNumberToString(this._currCost);
                  if(this._myCurrencyCount < this._currCost)
                  {
                     this._hasEnoughGems = false;
                     this._tag.gotoAndStop(_loc2_ ? "diamondRed" : "red");
                     this._tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._hasEnoughGems = true;
                     this._tag.gotoAndStop(_loc2_ ? "diamondGreen" : "green");
                     this._tag.textColor = "0xFFFFFFFF";
                  }
               }
               else
               {
                  this._hasEnoughGems = true;
                  LocalizationManager.translateId(this._tag.txt,11176);
               }
            }
            if(AvatarUtility.isEndangered(_loc1_.availability))
            {
               if(this._currType == 13 || this._currType == 16 || this._currType == 26)
               {
                  LocalizationManager.translateId(this._avatarSelect.endangeredSign.txt,11177);
               }
               else if(this._currType == 6)
               {
                  LocalizationManager.translateId(this._avatarSelect.endangeredSign.txt,14226);
               }
               else
               {
                  LocalizationManager.translateId(this._avatarSelect.endangeredSign.txt,11178);
               }
               this._avatarSelect.endangeredSign.visible = true;
            }
            else
            {
               this._avatarSelect.endangeredSign.visible = false;
            }
            if(AvatarUtility.isEndangered(_loc1_.availability) || AvatarUtility.isExtinct(_loc1_.availability))
            {
               this._nextBtn.activateGrayState(true);
               if(this._isFromWorld)
               {
                  this._tag.visible = false;
                  this._nextBtn.sparkle.visible = false;
               }
            }
            else
            {
               this._nextBtn.activateGrayState(false);
               if(this._isFromWorld)
               {
                  this._nextBtn.sparkle.visible = _loc1_.isDiamond;
                  this._tag.visible = true;
               }
            }
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc2_:String = param1.currentTarget.isDiamond ? "diamond_" : "";
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
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc2_:String = param1.currentTarget.isDiamond ? "diamond_" : "";
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
      
      private function stopVOButton(param1:Event) : void
      {
         if(CreateAccountGui)
         {
            CreateAccountGui.vo1Sound.stop();
         }
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
      }
      
      private function voBtnClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(CreateAccountGui.vo1Sound.isPlaying)
         {
            CreateAccountGui.vo1Sound.stop();
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo1Sound.play();
            if(CreateAccountGui.vo1Sound.sc)
            {
               CreateAccountGui.vo1Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
   }
}

