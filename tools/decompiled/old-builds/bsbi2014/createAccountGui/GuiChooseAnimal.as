package createAccountGui
{
   import achievement.AchievementXtCommManager;
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
   import gui.ItemWindowAvatarSelect;
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
      
      private var _currAvatar:MovieClip;
      
      private var _buyBtnGreen:MovieClip;
      
      private var _buyBtnRed:MovieClip;
      
      private var _tag:MovieClip;
      
      private var _amlNameTxt:TextField;
      
      private var _titleText:TextField;
      
      private var _avatarWindows:WindowGenerator;
      
      private var _scrollBar:SBScrollbar;
      
      private var _itemsLoadingSpiral:LoadingSpiral;
      
      private var _currAvatarIconIds:Array;
      
      private var _currAvatarTypes:Array;
      
      private var _oceanOnlyIconIds:Array;
      
      private var _oceanOnlyTypes:Array;
      
      private var _usableAvatarIconIds:Array;
      
      private var _usableAvatarTypes:Array;
      
      private var _currBG:String;
      
      private var _avatarNamesByType:Object;
      
      private var _newAvatarFacilitator:NewWorldAvatar;
      
      private var _currType:int;
      
      private var _avtViewsFlag:int;
      
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
      
      private var _isMovingScreens:Boolean;
      
      private var _registrationPanel:MovieClip;
      
      private var _avatarSelect:MovieClip;
      
      public function GuiChooseAnimal(initLogin:Object, initWizard:SBWizard, isFromWorld:Boolean)
      {
         this._chooseScreen = isFromWorld ? initLogin.registrationPanel.chooseAnimal : initLogin.registrationPanel.chooseAnimal;
         super(this._chooseScreen,initWizard);
         this._registrationPanel = MovieClip(this._chooseScreen.parent);
         this._avatarSelect = MovieClip(this._chooseScreen.parent.parent);
         this._amlNameTxt = this._chooseScreen.animalNameText;
         this._itemWindow = this._chooseScreen.itemWindow;
         this._titleText = this._chooseScreen.titleText;
         this._isFromWorld = isFromWorld;
         this._wizard = initWizard;
         if(isFromWorld)
         {
            this._backBtn = initLogin.back_btn;
            this._nextBtn = initLogin.next_btn;
            this._playBtn = initLogin.play_btn;
            this._avatarHolder = initLogin.allAvatars;
            this._buyBtnGreen = initLogin.buy_btn_green;
            this._buyBtnRed = initLogin.buy_btn_red;
            this._tag = this._chooseScreen.tag;
         }
         else
         {
            this._voBtn = this._chooseScreen.vo_btn;
            this._playBtn = initLogin.play_btn;
            this._backBtn = initLogin.back_btn;
            this._nextBtn = initLogin.next_btn;
            this._avatarHolder = initLogin.allAvatars;
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
         if(!this._isFromWorld)
         {
            this._playBtn.visible = false;
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
            this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
         }
         else
         {
            this._buyBtnGreen.visible = false;
            this._buyBtnRed.visible = false;
            this._tag.visible = false;
         }
         this._backBtn.visible = false;
         this._amlNameTxt.text = "";
         this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
         this._newAvatarFacilitator = new NewWorldAvatar();
         this._usableAvatarIconIds = [];
         this._usableAvatarTypes = [];
         this._currAvatarIconIds = [];
         this._currAvatarTypes = [];
         this._avatarNamesByType = [];
         this._oceanOnlyIconIds = [];
         this._oceanOnlyTypes = [];
         this._avtViewsFlag = gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG);
         this._itemsLoadingSpiral = new LoadingSpiral(this._itemWindow,this._itemWindow.width * 0.5,this._itemWindow.height * 0.5);
         this._itemsLoadingSpiral.visible = true;
         this.setupIcons();
         if(!this._isFromWorld && Boolean(CreateAccountGui.vo1Sound))
         {
            CreateAccountGui.vo1Sound.play();
            if(Boolean(CreateAccountGui.vo1Sound.sc))
            {
               CreateAccountGui.vo1Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
      
      override public function destroy() : void
      {
         if(Boolean(this._avatarWindows))
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         if(Boolean(this._scrollBar))
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         super.destroy();
      }
      
      public function destroyReloadedItems() : void
      {
         if(Boolean(this._avatarWindows))
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         if(Boolean(this._scrollBar))
         {
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
      }
      
      public function setup(isChoosingOceanAvatars:Boolean, isChoosing:Boolean, avatarType:int = -1, skipToNameScreen:Boolean = false, currencyType:int = 0, specialValue:int = -1) : void
      {
         this._isMovingScreens = false;
         this._avtViewsFlag = gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG);
         this._currencyType = currencyType;
         this.setupIcons(true);
         if(currencyType == Item.GEM_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.gemCount;
         }
         else if(currencyType == Item.DIAMOND_CURRENCY)
         {
            this._myCurrencyCount = gMainFrame.clientInfo.diamondCount;
         }
         this._isChoosingOceanAvatars = isChoosingOceanAvatars;
         this._isChoosingFirstNonMember = isChoosing;
         this._nextBtn.visible = true;
         this._buyBtnGreen.visible = false;
         this._buyBtnRed.visible = false;
         this._backBtn.visible = false;
         this._isCreatingWithoutChoosing = skipToNameScreen;
         if(this._isChoosingOceanAvatars)
         {
            this._currAvatarIconIds = this._oceanOnlyIconIds;
            this._currAvatarTypes = this._oceanOnlyTypes;
         }
         else
         {
            this._currAvatarIconIds = this._usableAvatarIconIds;
            this._currAvatarTypes = this._usableAvatarTypes;
         }
         this.pickRandomAvatar(avatarType,specialValue);
         this._wizard.creationAssets.creationWiz.step = skipToNameScreen ? 2 : 1;
         if(Boolean(this._currAvatar) && Boolean(this._currBG))
         {
            if(!skipToNameScreen)
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
         if(!skipToNameScreen)
         {
            this.createAvatarWindows();
         }
      }
      
      public function enterFromNext() : void
      {
         this._registrationPanel.gotoAndPlay("backChooseAnAnimal");
         this._currAvatar.gotoAndPlay("backChooseAnAnimal");
         this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("backChooseAnAnimal");
         if(this._isFromWorld)
         {
            this._buyBtnGreen.visible = false;
            this._buyBtnRed.visible = false;
            this._nextBtn.visible = true;
         }
         this.enterFromBoth();
      }
      
      public function enterFromPrev() : void
      {
         this._registrationPanel.gotoAndStop("intro");
         if(Boolean(this._currAvatar))
         {
            this._currAvatar.gotoAndStop("chooseAnAnimal");
         }
         if(Boolean(this._currBG))
         {
            this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("intro");
         }
         this.enterFromBoth();
      }
      
      public function enterFromBoth() : void
      {
         if(!this._isFromWorld && Boolean(CreateAccountGui.vo1Sound))
         {
            CreateAccountGui.vo1Sound.play();
            if(Boolean(CreateAccountGui.vo1Sound.sc))
            {
               CreateAccountGui.vo1Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
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
         var currDef:Object = null;
         if(Boolean(this._nextBtn.isGray))
         {
            return false;
         }
         if(!this._isFromWorld)
         {
            if(Boolean(CreateAccountGui.vo1Sound))
            {
               CreateAccountGui.vo1Sound.stop();
            }
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         if(!gMainFrame.userInfo.isMember)
         {
            currDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvDefIndexByType(this._currType)];
            if(Boolean(currDef.isMemberOnly))
            {
               if(this._isCreatingWithoutChoosing)
               {
                  if(this._registrationPanel.currentFrameLabel != "chooseAName")
                  {
                     this._registrationPanel.gotoAndStop("chooseAName");
                  }
                  if(this._currAvatar.currentFrameLabel != "chooseAName")
                  {
                     this._currAvatar.gotoAndStop("chooseAName");
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
               if(!(this._isChoosingFirstNonMember && currDef.enviroFlag == 2))
               {
                  if(this._isCreatingWithoutChoosing)
                  {
                     this._registrationPanel.gotoAndStop("chooseAName");
                     this._currAvatar.gotoAndStop("chooseAName");
                     this._avatarSelect.bg[this._currBG + "Bg"].gotoAndStop("chooseAName");
                  }
                  else
                  {
                     this._registrationPanel.gotoAndPlay("playChooseAName");
                     this._currAvatar.gotoAndPlay("playChooseAName");
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
            this._currAvatar.gotoAndStop("chooseAName");
            this._avatarSelect.bg[this._currBG + "Bg"].gotoAndStop("chooseAName");
         }
         else
         {
            this._registrationPanel.gotoAndPlay("playChooseAName");
            this._currAvatar.gotoAndPlay("playChooseAName");
            this._avatarSelect.bg[this._currBG + "Bg"].gotoAndPlay("playChooseAName");
         }
         this._isMovingScreens = true;
         return true;
      }
      
      public function leaveToPrev() : Boolean
      {
         if(!this._isFromWorld)
         {
            if(Boolean(CreateAccountGui.vo1Sound))
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
      
      public function updateScreenAssets(isCurrentScreen:Boolean = false) : void
      {
         this._chooseScreen = this._registrationPanel.chooseAnimal;
         this._amlNameTxt = this._chooseScreen.animalNameText;
         this._itemWindow = this._chooseScreen.itemWindow;
         this._titleText = this._chooseScreen.titleText;
         if(this._isFromWorld)
         {
            this._tag = this._chooseScreen.tag;
            this._buyBtnGreen = this._avatarSelect.buy_btn_green;
            this._buyBtnRed = this._avatarSelect.buy_btn_red;
         }
         if(isCurrentScreen)
         {
            this.setupAvatarTextItems();
            this.createAvatarWindows();
            if(this._isFromWorld)
            {
               this._buyBtnGreen.visible = false;
               this._buyBtnRed.visible = false;
               this._tag.visible = true;
            }
            else
            {
               this._playBtn.visible = false;
               this._voBtn.stop();
               this._voBtn.gotoAndStop(1);
               this._voBtn.addEventListener(MouseEvent.CLICK,this.voBtnClickHandler,false,0,true);
               this._voBtn = this._chooseScreen.vo_btn;
            }
            if(!this._isFromWorld && Boolean(CreateAccountGui.vo1Sound))
            {
               if(Boolean(CreateAccountGui.vo1Sound.sc))
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
      
      public function get currAvatar() : MovieClip
      {
         return this._currAvatar;
      }
      
      public function get currBG() : String
      {
         return this._currBG;
      }
      
      public function get currType() : int
      {
         return this._currType;
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
         return LocalizationManager.translateIdOnly(this._avatarNamesByType[this._currType]);
      }
      
      private function setupIcons(isRecreating:Boolean = false) : void
      {
         var iconId:int = 0;
         var currDef:Object = null;
         var creationAvatar:Array = AvatarUtility.creationAvatars;
         this._usableAvatarIconIds = [];
         this._usableAvatarTypes = [];
         this._oceanOnlyIconIds = [];
         this._oceanOnlyTypes = [];
         for(var i:int = 0; i < creationAvatar.length; i++)
         {
            try
            {
               if(Boolean(AvatarUtility.avatarDefInfo && AvatarUtility.avatarDefInfo.length > 0) && Boolean(i < AvatarUtility.avatarDefInfo.length) && Boolean(AvatarUtility.avatarDefInfo[i]))
               {
                  iconId = int(gMainFrame.userInfo.getAvatarDefByAvType(creationAvatar[i].avTypeId).iconMediaId);
                  currDef = AvatarUtility.avatarDefInfo[i];
                  if((this._avtViewsFlag & 1 << AvatarUtility.avatarTypes[i] - 1) != 0)
                  {
                     if(!this._isFromWorld && (AvatarUtility.isEndangered(currDef.availability) || AvatarUtility.isExtinct(currDef.availability)))
                     {
                        continue;
                     }
                     this._usableAvatarIconIds.push(iconId);
                     this._usableAvatarTypes.push(creationAvatar[i].avTypeId);
                     if(Utility.isOcean(AvatarUtility.avatarDefInfo[i].enviroFlag))
                     {
                        this._oceanOnlyIconIds.push(iconId);
                        this._oceanOnlyTypes.push(creationAvatar[i].avTypeId);
                     }
                  }
                  this._avatarNamesByType[creationAvatar[i].avTypeId] = gMainFrame.userInfo.getAvatarDefByAvType(creationAvatar[i].avTypeId).titleStrRef;
                  if(Boolean(this._currType) && creationAvatar[i].avTypeId == this._currType)
                  {
                     LocalizationManager.translateId(this._amlNameTxt,this._avatarNamesByType[this._currType]);
                  }
               }
            }
            catch(e:Error)
            {
            }
         }
         this._currAvatarIconIds = this._usableAvatarIconIds;
         this._currAvatarTypes = this._usableAvatarTypes;
         if(!this._isFromWorld && !isRecreating)
         {
            this.pickRandomAvatar();
            this.createAvatarWindows();
         }
      }
      
      private function pickRandomAvatar(type:int = -1, diamondCost:int = -1) : void
      {
         var i:int = 0;
         if(type == -1)
         {
            this._currIndex = Math.floor(Math.random() * (this._currAvatarTypes.length - 1 - 0 + 1)) + 0;
            type = int(this._currAvatarTypes[this._currIndex]);
         }
         else
         {
            for(i = 0; i < this._currAvatarTypes.length; i++)
            {
               if(this._currAvatarTypes[i] == type)
               {
                  this._currIndex = i;
                  break;
               }
            }
         }
         this._diamondCost = diamondCost;
         this._currType = type;
         this.setupCurrAvatar();
      }
      
      private function createAvatarWindows() : void
      {
         if(Boolean(this._avatarWindows) && this._avatarWindows.numWindowsCreated > 0)
         {
            this._itemWindow.addChild(this._avatarWindows);
            if(this._isFromWorld)
            {
               if(Boolean(this._scrollBar))
               {
                  this._scrollYValue = this._scrollBar.scrollYValue;
                  this._scrollBar.destroy();
                  this._scrollBar = null;
               }
               this._scrollBar = new SBScrollbar();
               this._scrollBar.init(this._avatarWindows,this._avatarWindows.width,this._avatarWindows.boxHeight * 3 + 2 * 3,10,"scrollbar2",this._avatarWindows.boxHeight + 2,this._scrollYValue,this._avatarWindows.height);
            }
            return;
         }
         this._itemsLoadingSpiral.visible = true;
         if(Boolean(this._scrollBar))
         {
            this._scrollYValue = this._scrollBar.scrollYValue;
            this._scrollBar.destroy();
            this._scrollBar = null;
         }
         if(Boolean(this._avatarWindows))
         {
            this._avatarWindows.destroy();
            this._avatarWindows = null;
         }
         this._avatarWindows = new WindowGenerator();
         this._avatarWindows.init(3,3,this._currAvatarIconIds.length,2,2,2,ItemWindowAvatarSelect,this._currAvatarIconIds,"",{
            "mouseDown":this.winMouseDown,
            "mouseOver":this.winMouseOver,
            "mouseOut":this.winMouseOut
         },{
            "forCreation":!this._isFromWorld,
            "avTypes":this._currAvatarTypes
         },this.onAvatarIconWindowsLoaded,false,false);
         this._itemWindow.addChild(this._avatarWindows);
      }
      
      private function onAvatarIconWindowsLoaded() : void
      {
         if(this._isFromWorld && this._scrollBar == null)
         {
            this._scrollBar = new SBScrollbar();
            this._scrollBar.init(this._avatarWindows,this._avatarWindows.width,this._avatarWindows.boxHeight * 3 + 2 * 3,10,"scrollbar2",this._avatarWindows.boxHeight + 2,this._scrollYValue,this._avatarWindows.height);
         }
         this._itemsLoadingSpiral.visible = false;
         if(MovieClip(this._avatarWindows.bg.getChildAt(this._currIndex)).currWindow.currentFrameLabel != "down")
         {
            MovieClip(this._avatarWindows.bg.getChildAt(this._currIndex)).currWindow.gotoAndStop("down");
         }
      }
      
      private function winMouseDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!this._isMovingScreens && this._currIndex != evt.currentTarget.index)
         {
            MovieClip(this._avatarWindows.bg.getChildAt(this._currIndex)).deselect();
            this._currIndex = evt.currentTarget.index;
            this._currType = this._currAvatarTypes[evt.currentTarget.index];
            if(evt.currentTarget.currWindow.currentFrameLabel != "down")
            {
               evt.currentTarget.currWindow.gotoAndStop("down");
            }
            this.setupCurrAvatar();
         }
      }
      
      private function setupCurrAvatar() : void
      {
         var splitData:Array = null;
         var currLabels:Array = this._avatarHolder.currentLabels;
         for(var i:int = 0; i < currLabels.length; i++)
         {
            splitData = currLabels[i].name.split("_");
            if(splitData[1] == this._currType)
            {
               this._currBG = splitData[0];
               this._avatarHolder.gotoAndStop(this._currBG + "_" + this._currType);
               this._currAvatar = this._avatarHolder["avatar" + this._currType];
               break;
            }
         }
         if(Boolean(this._currAvatar))
         {
            this._currAvatar.gotoAndPlay("intro");
            this.setupAvatarTextItems();
         }
         if(Boolean(this._currBG))
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
         var avDef:Object = null;
         if(Boolean(this._currAvatar))
         {
            if(Boolean(this._avatarNamesByType[this._currType]))
            {
               LocalizationManager.translateId(this._amlNameTxt,this._avatarNamesByType[this._currType]);
            }
            avDef = AvatarUtility.avatarDefInfo[AvatarUtility.findAvatarIndexByType(this._currType)];
            if(this._isFromWorld)
            {
               this._currCost = this._diamondCost == -1 ? int(avDef.cost) : this._diamondCost;
               if(!this._isChoosingFirstNonMember)
               {
                  this._tag.txt.text = Utility.convertNumberToString(this._currCost);
                  if(this._myCurrencyCount < this._currCost)
                  {
                     this._hasEnoughGems = false;
                     this._tag.gotoAndStop("red");
                     this._tag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._hasEnoughGems = true;
                     this._tag.gotoAndStop("green");
                     this._tag.textColor = "0xFFFFFFFF";
                  }
               }
               else
               {
                  this._hasEnoughGems = true;
                  LocalizationManager.translateId(this._tag.txt,11176);
               }
            }
            if(AvatarUtility.isEndangered(avDef.availability))
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
            if(AvatarUtility.isEndangered(avDef.availability) || AvatarUtility.isExtinct(avDef.availability))
            {
               this._nextBtn.activateGrayState(true);
               if(this._isFromWorld)
               {
                  this._tag.visible = false;
               }
            }
            else
            {
               this._nextBtn.activateGrayState(false);
               if(this._isFromWorld)
               {
                  this._tag.visible = true;
               }
            }
         }
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(evt.currentTarget.currWindow.currentFrameLabel == "down")
         {
            evt.currentTarget.currWindow.gotoAndStop("downMouse");
         }
         else if(evt.currentTarget.currWindow.currentFrameLabel != "downMouse")
         {
            evt.currentTarget.currWindow.gotoAndStop("over");
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(evt.currentTarget.currWindow.currentFrameLabel == "downMouse")
         {
            evt.currentTarget.currWindow.gotoAndStop("down");
         }
         else if(evt.currentTarget.currWindow.currentFrameLabel != "down")
         {
            evt.currentTarget.currWindow.gotoAndStop("up");
         }
      }
      
      private function stopVOButton(e:Event) : void
      {
         if(Boolean(CreateAccountGui))
         {
            CreateAccountGui.vo1Sound.stop();
         }
         this._voBtn.stop();
         this._voBtn.gotoAndStop(1);
      }
      
      private function voBtnClickHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(CreateAccountGui.vo1Sound.isPlaying)
         {
            CreateAccountGui.vo1Sound.stop();
            this._voBtn.stop();
            this._voBtn.gotoAndStop(1);
         }
         else
         {
            CreateAccountGui.vo1Sound.play();
            if(Boolean(CreateAccountGui.vo1Sound.sc))
            {
               CreateAccountGui.vo1Sound.sc.addEventListener(Event.SOUND_COMPLETE,this.stopVOButton,false,0,true);
               this._voBtn.play();
            }
         }
      }
   }
}

