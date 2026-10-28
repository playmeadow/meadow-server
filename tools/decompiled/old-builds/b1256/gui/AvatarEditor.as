package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarEditorView;
   import avatar.AvatarEvent;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarXtCommManager;
   import avatar.NameBar;
   import avatar.UserInfo;
   import com.greensock.TimelineLite;
   import com.greensock.easing.SlowMo;
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.popup.SBOkPopup;
   import currency.UserCurrency;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.GuiPet;
   import pet.PetManager;
   import quest.QuestManager;
   
   public class AvatarEditor
   {
      
      public static const COLOR_TAB_ID:int = 0;
      
      public static const PATTERN_TAB_ID:int = 1;
      
      public static const EYE_TAB_ID:int = 2;
      
      private static var _mainScrollYPosition:Number = 0;
      
      private static var _tradeClothingScrollYPosition:Number = 0;
      
      private static var _tradeDenScrollYPosition:Number = 0;
      
      private static var _tradeListViewType:int = 1;
      
      private static var _mainClothingSortType:int = 2;
      
      private static var _tradeClothingSortType:int = 2;
      
      private static var _tradeDenSortType:int = 2;
      
      private const CLOTHING_VIEW_TYPE:int = 0;
      
      private const DEN_VIEW_TYPE:int = 1;
      
      private const CT_WIDTH:int = 240;
      
      private const CT_HEIGHT:int = 150;
      
      private const CT_NUM_COLS:int = 10;
      
      private const CT_NUM_ROWS:int = 5;
      
      private const CT_Y_TOP:int = 12;
      
      private const CT_Y_BOT:int = 176;
      
      private const CT_X:int = 21;
      
      private const CT_ID_C1:int = 0;
      
      private const CT_ID_C2:int = 1;
      
      private const CT_ID_EYES:int = 2;
      
      private const CT_ID_PATT:int = 3;
      
      private const CT_SECRET_COLOR:int = 102;
      
      private const NUM_X_WIN:int = 3;
      
      private const NUM_Y_WIN:int = 4;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const Y_WIN_START:Number = 0;
      
      private const SCROLLBAR_GAP:int = 3;
      
      private const AVEDITOR_MEDIA_ID:int = 1352;
      
      public var avEditor:MovieClip;
      
      public var xBtn:MovieClip;
      
      public var block:Sprite;
      
      private var _makePopup:Boolean;
      
      private var _guiLayer:DisplayLayer;
      
      private var _isFFM:Boolean;
      
      private var _isInQuest:Boolean;
      
      private var _worldAvatar:Avatar;
      
      private var _avatarEditorView:AvatarEditorView;
      
      private var _itemsOn:Array;
      
      private var _itemsOff:Array;
      
      private var _tradeItemsIn:Array;
      
      private var _tradeItemsOut:Array;
      
      private var _currClothesArray:Array;
      
      private var _patterns:Array;
      
      private var _eyes:Array;
      
      private var _headItems:Array;
      
      private var _neckItems:Array;
      
      private var _backItems:Array;
      
      private var _legItems:Array;
      
      private var _tailItems:Array;
      
      private var _itemTypeItems:Array;
      
      private var _allNewestClothes:Array;
      
      private var _allOldestClothes:Array;
      
      private var _fullHeadItems:Array;
      
      private var _fullNeckItems:Array;
      
      private var _fullBackItems:Array;
      
      private var _fullLegItems:Array;
      
      private var _fullTailItems:Array;
      
      private var _fullItemTypeItems:Array;
      
      private var _fullallNewestClothes:Array;
      
      private var _fullAllOldestClothes:Array;
      
      private var _currDenItemsArray:Array;
      
      private var _currTradesArray:Array;
      
      private var _floorItems:Array;
      
      private var _themeItems:Array;
      
      private var _itemTypeDenItems:Array;
      
      private var _allOldestDenItems:Array;
      
      private var _allNewestDenItems:Array;
      
      private var _fullClothesList:Array;
      
      private var _currPattern:int;
      
      private var _currEye:int;
      
      private var _currentTab:int;
      
      private var _recycle:RecycleItems;
      
      private var _tradeSort:MovieClip;
      
      private var _tradeWindow:MovieClip;
      
      private var _eyePattWindow:MovieClip;
      
      private var _lArrowBtn:MovieClip;
      
      private var _rArrowBtn:MovieClip;
      
      private var _onCloseCallback:Function;
      
      private var _waitForApResponse:Boolean;
      
      private var _waitForIuResponse:Boolean;
      
      private var _sendDelayedTradeRequest:Boolean;
      
      private var _gamePalette:Array;
      
      private var _avatarPalette1:Array;
      
      private var _avatarPalette2:Array;
      
      private var _colorTableColor1:ColorTable;
      
      private var _colorTableColor2:ColorTable;
      
      private var _colorTablePatterns:ColorTable;
      
      private var _colorTableEyes:ColorTable;
      
      private var _customAvtIcon:MovieClip;
      
      private var _cellWidth:Number;
      
      private var _cellHeight:Number;
      
      private var _numXColors:int;
      
      private var _numYColors:int;
      
      private var _currCustomPatternColorIdx:int;
      
      private var _tabOpenId:int;
      
      private var _itemClothingWindows:WindowAndScrollbarGenerator;
      
      private var _itemTradeWindows:WindowAndScrollbarGenerator;
      
      private var _tradeClothingWindows:WindowAndScrollbarGenerator;
      
      private var _tradeDenWindows:WindowAndScrollbarGenerator;
      
      private var _numItemsInCurrentArray:int;
      
      public var numClothingItemsInTradeListInitially:int;
      
      public var numDenItemsInTradeListInitially:int;
      
      private var _nameBars:Array;
      
      private var _nameBarData:int;
      
      private var _userInfo:UserInfo;
      
      private var _nameBarItemWindows:WindowAndScrollbarGenerator;
      
      private var _nameBarItemWinHeight:int;
      
      private var _namebarBadgeDefs:Array;
      
      private var _namebarBadgeMediaIds:Array;
      
      private var _namebarBadgeImages:Array;
      
      private var _shop:Shop;
      
      private var _spirals:Array;
      
      private var _petInventory:PetInventory;
      
      private var _myPet:GuiPet;
      
      private var _loadingMediaHelper:MediaHelper;
      
      private var _loadingSpiral:LoadingSpiral;
      
      private var _achievementViewer:AchievementViewer;
      
      private var _gemTimeline:TimelineLite;
      
      public function AvatarEditor()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:Boolean = true, param4:Function = null, param5:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _worldAvatar = param1;
         _makePopup = param3;
         _onCloseCallback = param4;
         _guiLayer = param2;
         _isFFM = param5;
         _isInQuest = gMainFrame.clientInfo.roomType == 7;
         _avatarEditorView = new AvatarEditorView();
         _avatarEditorView.init(_worldAvatar);
         _gamePalette = PaletteHelper.gamePalette;
         _avatarPalette1 = PaletteHelper.avatarPalette1;
         _avatarPalette2 = PaletteHelper.avatarPalette2;
         _patterns = [];
         _eyes = [];
         createPatternsAndEyesArrays();
         _tabOpenId = 0;
         _spirals = [];
         _currClothesArray = _allNewestClothes = _avatarEditorView.inventoryClothingItems;
         _headItems = Utility.sortItemsAll(_currClothesArray,0,8,9,10);
         _neckItems = Utility.sortItemsAll(_currClothesArray,0,7);
         _backItems = Utility.sortItemsAll(_currClothesArray,0,6);
         _legItems = Utility.sortItemsAll(_currClothesArray,0,5);
         _tailItems = Utility.sortItemsAll(_currClothesArray,0,4);
         _itemTypeItems = Utility.sortByItem(_currClothesArray,0);
         _allOldestClothes = _allNewestClothes.concat().reverse();
         if(_currClothesArray)
         {
            _currClothesArray = convertIntToList(_mainClothingSortType,true,false);
         }
         _fullClothesList = _fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
         if(_fullClothesList)
         {
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,0,8,9,10);
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,0,7);
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,0,6);
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,0,5);
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,0,4);
            _fullItemTypeItems = Utility.sortByItem(_fullClothesList,0);
            _fullAllOldestClothes = _fullallNewestClothes.concat().reverse();
         }
         if(param1.inventoryDenFull.itemArray)
         {
            _currDenItemsArray = _allNewestDenItems = discardAudioItems(param1.inventoryDenFull.itemArray);
            _floorItems = Utility.sortItems(_currDenItemsArray,0,0,1);
            _themeItems = Utility.sortItems(_currDenItemsArray,0,2,3);
            _itemTypeDenItems = Utility.sortByItem(_currDenItemsArray,0);
            _allOldestDenItems = _allNewestDenItems.concat().reverse();
         }
         _currTradesArray = gMainFrame.userInfo.getMyTradeList().slice();
         numClothingItemsInTradeListInitially = TradeManager.numClothingItemsInMyTradeList;
         numDenItemsInTradeListInitially = TradeManager.numDenItemsInMyTradeList;
         _loadingMediaHelper = new MediaHelper();
         _loadingMediaHelper.init(1352,onMediaItemLoaded,true);
      }
      
      public function destroy() : void
      {
         var _loc1_:* = null;
         DarkenManager.showLoadingSpiral(false);
         KeepAlive.stopKATimer(avEditor);
         removeListeners();
         if(avEditor.tradeBtnUp.visible)
         {
            if(_itemTradeWindows)
            {
               _mainScrollYPosition = _itemTradeWindows.scrollYValue;
            }
            else if(_itemClothingWindows)
            {
               _mainScrollYPosition = _itemClothingWindows.scrollYValue;
            }
         }
         else if(_tradeListViewType == 0 && _tradeClothingWindows)
         {
            _tradeClothingScrollYPosition = _tradeClothingWindows.scrollYValue;
         }
         else if(_tradeDenWindows)
         {
            _tradeDenScrollYPosition = _tradeDenWindows.scrollYValue;
         }
         if(_itemClothingWindows)
         {
            _itemClothingWindows.destroy();
            _itemClothingWindows = null;
         }
         if(_itemTradeWindows)
         {
            _itemTradeWindows.destroy();
            _itemTradeWindows = null;
         }
         if(_tradeClothingWindows)
         {
            _tradeClothingWindows.destroy();
            _tradeClothingWindows = null;
         }
         if(_tradeDenWindows)
         {
            _tradeDenWindows.destroy();
            _tradeDenWindows = null;
         }
         if(_avatarEditorView)
         {
            avEditor.charBox.removeChild(_avatarEditorView);
            _avatarEditorView.destroy();
            _avatarEditorView = null;
            _itemsOn = null;
            _itemsOff = null;
            _tradeItemsIn = null;
            _tradeItemsOut = null;
            _patterns = null;
            _eyes = null;
            _avatarPalette1 = null;
            _avatarPalette2 = null;
         }
         if(_myPet)
         {
            _myPet.destroy();
            _myPet = null;
         }
         _colorTableColor1.destroy();
         _colorTableColor2.destroy();
         _colorTablePatterns.destroy();
         _colorTableEyes.destroy();
         _namebarBadgeMediaIds = null;
         _nameBars = null;
         _userInfo = null;
         _namebarBadgeImages = null;
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
            _nameBarItemWindows = null;
         }
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(_achievementViewer)
         {
            _achievementViewer.destroy();
            _achievementViewer = null;
         }
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
         if(_petInventory)
         {
            _petInventory.destroy();
            _petInventory = null;
         }
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
            _nameBarItemWindows = null;
         }
         _currClothesArray = null;
         _headItems = null;
         _neckItems = null;
         _backItems = null;
         _legItems = null;
         _tailItems = null;
         _itemTypeItems = null;
         _allOldestClothes = null;
         _fullHeadItems = null;
         _fullNeckItems = null;
         _fullBackItems = null;
         _fullLegItems = null;
         _fullTailItems = null;
         _fullItemTypeItems = null;
         _fullAllOldestClothes = null;
         _currDenItemsArray = null;
         _floorItems = null;
         _themeItems = null;
         _itemTypeDenItems = null;
         _allOldestDenItems = null;
         _currTradesArray = null;
         _onCloseCallback = null;
         if(_spirals && _spirals.length > 0)
         {
            for each(_loc1_ in _spirals)
            {
               _loc1_.destroy();
            }
         }
         _spirals = null;
         DarkenManager.unDarken(avEditor);
         _guiLayer.removeChild(avEditor);
      }
      
      public function get onCloseCallback() : Function
      {
         return _onCloseCallback;
      }
      
      public function set onCloseCallback(param1:Function) : void
      {
         _onCloseCallback = param1;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            avEditor = MovieClip(param1.getChildAt(0));
            xBtn = avEditor.bx;
            block = avEditor.block;
            block.visible = _isFFM;
            _tradeSort = avEditor.tradeWindow.sortPopup;
            _tradeWindow = avEditor.tradeWindow;
            avEditor.x = 900 * 0.5;
            avEditor.y = 550 * 0.5;
            avEditor.nonmember.text = _worldAvatar.avName;
            _userInfo = gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName);
            _itemsOn = [];
            _itemsOff = [];
            _tradeItemsIn = [];
            _tradeItemsOut = [];
            _namebarBadgeImages = [];
            _nameBars = new Array("goldBtn","blackBtn","blueBtn","brownBtn","greenBtn","pinkBtn","purpleBtn","redBtn","tealBtn","whiteBtn");
            _nameBarData = gMainFrame.userInfo.playerUserInfo.nameBarData;
            _nameBarItemWinHeight = avEditor.namebarPopup.itemWindow.height;
            setInitAssetVisibility();
            positionAndDrawAvatarView();
            _waitForApResponse = false;
            _waitForIuResponse = false;
            if(_currClothesArray)
            {
               createItemWindows(_currClothesArray,avEditor.itemBlock);
            }
            addListeners();
            KeepAlive.startKATimer(avEditor);
            _loadingMediaHelper.destroy();
            _loadingMediaHelper = null;
            DarkenManager.showLoadingSpiral(false);
            _guiLayer.addChild(avEditor);
            DarkenManager.darken(avEditor);
            QuestManager.avatarEditorInitComplete();
         }
      }
      
      public function get colorTableColor1() : ColorTable
      {
         return _colorTableColor1;
      }
      
      public function get colorTableColor2() : ColorTable
      {
         return _colorTableColor2;
      }
      
      public function get colorTablePatterns() : ColorTable
      {
         return _colorTablePatterns;
      }
      
      public function get colorTableEyes() : ColorTable
      {
         return _colorTableEyes;
      }
      
      public function get arrowBtnR() : MovieClip
      {
         return _rArrowBtn;
      }
      
      public function get arrowBtnL() : MovieClip
      {
         return _lArrowBtn;
      }
      
      private function setInitAssetVisibility() : void
      {
         var _loc11_:int = 0;
         var _loc3_:AvatarInfo = null;
         var _loc7_:Boolean = false;
         var _loc5_:String = null;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
         var _loc9_:Array = _avatarEditorView.colors;
         var _loc10_:int = _loc9_[0] >> 24 & 0xFF;
         var _loc2_:int = _loc9_[0] >> 16 & 0xFF;
         var _loc4_:int = _loc9_[1] >> 24 & 0xFF;
         var _loc6_:int = _loc9_[2] >> 24 & 0xFF;
         _colorTableColor1 = new ColorTable();
         _colorTableColor1.init(0,240,150,10,5,_gamePalette,_avatarPalette1,_loc10_,onColorChanged,102);
         _colorTableColor2 = new ColorTable();
         _colorTableColor2.init(1,240,150,10,5,_gamePalette,_avatarPalette2,_loc2_,onColorChanged,102);
         _colorTablePatterns = new ColorTable();
         _colorTablePatterns.init(3,240,150,10,5,_gamePalette,_avatarPalette1,_loc4_,onColorChanged,102);
         _colorTableEyes = new ColorTable();
         _colorTableEyes.init(2,240,150,10,5,_gamePalette,_avatarPalette1,_loc6_,onColorChanged,102);
         _colorTableColor1.x = 21;
         _colorTableColor1.y = 12;
         _colorTableColor2.x = 21;
         _colorTableColor2.y = 176;
         _colorTablePatterns.x = 21;
         _colorTablePatterns.y = 176;
         _colorTableEyes.x = 21;
         _colorTableEyes.y = 176;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
         avEditor.colorTableBlock.colors.addChild(_colorTableColor1);
         avEditor.colorTableBlock.colors.addChild(_colorTableColor2);
         _eyePattWindow = avEditor.colorTableBlock.patternsAndEyes.previewWin;
         _lArrowBtn = avEditor.colorTableBlock.patternsAndEyes.arrowBtnL;
         _rArrowBtn = avEditor.colorTableBlock.patternsAndEyes.arrowBtnR;
         LocalizationManager.translateId(avEditor.sortPopup.sort8.txt,11205);
         LocalizationManager.translateId(avEditor.sortPopup.sort7.txt,11206);
         LocalizationManager.translateId(avEditor.sortPopup.sort6.txt,11207);
         LocalizationManager.translateId(avEditor.sortPopup.sort5.txt,11208);
         LocalizationManager.translateId(avEditor.sortPopup.sort4.txt,11209);
         LocalizationManager.translateId(avEditor.sortPopup.sort3.txt,11210);
         LocalizationManager.translateId(avEditor.sortPopup.sort2.txt,11211);
         LocalizationManager.translateId(avEditor.sortPopup.sort1.txt,11212);
         avEditor.clothesBtnUp.visible = true;
         avEditor.clothesBtnDown.visible = false;
         avEditor.tradeBtnUp.visible = false;
         avEditor.tradeBtnDown.visible = _fullClothesList ? true : false;
         _tradeWindow.visible = false;
         avEditor.blackout.visible = false;
         avEditor.blackoutFull.visible = false;
         avEditor.patternTabUp.visible = false;
         avEditor.eyesTabUp.visible = false;
         avEditor.sortPopup.visible = false;
         avEditor.tradeHelpPopup.visible = false;
         avEditor.infoBtn.visible = false;
         avEditor.howTxt.visible = false;
         avEditor.currencyBar.visible = false;
         avEditor.statsPanel.visible = false;
         avEditor.block.visible = false;
         _tradeWindow.petsBtnDown.visible = false;
         _tradeWindow.petsBtnUp.visible = false;
         var _loc8_:String = "gem";
         if(UserCurrency.getCurrency(1) > 0)
         {
            _loc8_ += "Tic";
         }
         if(UserCurrency.getCurrency(3) > 0)
         {
            _loc8_ += "Dia";
         }
         avEditor.money.gotoAndStop(_loc8_);
         avEditor.money.mouse.gems.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(0));
         var _loc12_:int = 1;
         _gemTimeline = new TimelineLite();
         _gemTimeline.paused(true);
         _gemTimeline.to(avEditor.money.mouse.bg,0.1,{
            "scaleY":1,
            "alpha":0.3,
            "ease":SlowMo.ease
         },0);
         if(avEditor.money.mouse.tickets)
         {
            avEditor.money.mouse.tickets.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(1));
            _gemTimeline.to(avEditor.money.mouse.tickets,0.1,{
               "y":"+=" + 40 * _loc12_,
               "scaleX":1,
               "scaleY":1,
               "alpha":1,
               "ease":SlowMo.ease
            },0);
            _loc12_++;
         }
         if(avEditor.money.mouse.diamonds)
         {
            avEditor.money.mouse.diamonds.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(3));
            _gemTimeline.to(avEditor.money.mouse.diamonds,0.1,{
               "y":"+=" + 40 * _loc12_,
               "scaleX":1,
               "scaleY":1,
               "alpha":1,
               "ease":SlowMo.ease
            },0);
         }
         _achievementViewer = new AchievementViewer();
         _achievementViewer.loadMedia(287,avEditor);
         if(_allNewestClothes.length <= 0)
         {
            avEditor.sortBtn.visible = false;
         }
         if(gMainFrame.clientInfo.roomType == 7)
         {
            avEditor.petsBtn.activateGrayState(true);
         }
         else
         {
            loadPetView();
         }
         avEditor.namebarPopup.visible = false;
         var _loc1_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName);
         _loc11_ = 0;
         while(_loc11_ < _nameBars.length)
         {
            LocalizationManager.updateToFit(avEditor.namebarPopup[_nameBars[_loc11_]].txt,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE) && _loc1_ ? _loc1_.getModeratedUserName() : _worldAvatar.avName,false,false,false);
            avEditor.namebarPopup[_nameBars[_loc11_]].id = _loc11_;
            _loc11_++;
         }
         if(!gMainFrame.userInfo.isMember)
         {
            avEditor.nonmember.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            avEditor.nonmember.nubData = AvatarManager.playerAvatarWorldView.nubData;
            avEditor.nonmember.visible = true;
            avEditor.member.visible = false;
            LocalizationManager.updateToFit(avEditor.nonmember.txt,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE) && _loc1_ ? _loc1_.getModeratedUserName() : _worldAvatar.avName,false,false,false);
         }
         else
         {
            avEditor.member.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            avEditor.member.nubData = AvatarManager.playerAvatarWorldView.nubData;
            avEditor.member.xpShapeIcons = AvatarManager.playerAvatarWorldView.xpShapeIcons;
            avEditor.nonmember.visible = false;
            avEditor.member.visible = true;
            avEditor.member.setNubType(NameBar.BUDDY,false);
            avEditor.member.isBlocked = false;
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
            if(!_worldAvatar.isShaman && !_userInfo.isGuide)
            {
               avEditor.member.setColorBadgeAndXp(_nameBarData,_loc3_.questLevel,_loc3_.isMember);
            }
            else
            {
               avEditor.member.setColorBadgeAndXp(0,0,false);
            }
            avEditor.member.setAvName(_worldAvatar.avName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),_loc1_,false);
            _loc7_ = (_nameBarData >> 16 & 0x0F) == 0 && _loc3_.isMember || gMainFrame.clientInfo.roomType == 7 || gMainFrame.clientInfo.roomType == 8;
            if(_loc7_)
            {
               avEditor.namebarPopup.advLockToggle.toggleBtn.gotoAndStop("startingOn");
            }
            else
            {
               avEditor.namebarPopup.advLockToggle.toggleBtn.gotoAndStop("startingOff");
               avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = false;
            }
            if(_loc3_.questLevel > 0)
            {
               _loc5_ = avEditor.namebarPopup.advLockToggle.toggleBtn.shape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
               avEditor.namebarPopup.advLockToggle.toggleBtn.shape.gotoAndStop(_loc5_);
               Utility.createXpShape(_loc3_.questLevel,_loc3_.isMember,avEditor.namebarPopup.advLockToggle.toggleBtn.shape[_loc5_].mouse.up.icon,null,2147483647);
            }
         }
         if(_isFFM)
         {
            if(avEditor.petsBtn.hasGrayState)
            {
               avEditor.petsBtn.activateGrayState(true);
            }
            if(avEditor.shopBtn.hasGrayState)
            {
               avEditor.shopBtn.activateGrayState(true);
            }
            if(avEditor.recycleClothesBtn.hasGrayState)
            {
               avEditor.recycleClothesBtn.activateGrayState(true);
            }
            if(avEditor.sortBtn.hasGrayState)
            {
               avEditor.sortBtn.activateGrayState(true);
            }
            if(avEditor.tradeBtnDown.hasGrayState)
            {
               avEditor.tradeBtnDown.activateGrayState(true);
            }
            avEditor.block.visible = true;
         }
         else
         {
            avEditor.fiveMinCursor.visible = false;
         }
         avEditor.statsBtn.visible = false;
         avEditor.itemCounter.counterTxt.text = _allNewestClothes.length + "/" + Shop.maxItems;
         avEditor.searchBar.mouse.searchTxt.visible = false;
         avEditor.searchBar.shortTextWidth = avEditor.searchBar.mouse.txt.width + 10;
         avEditor.searchBar.wideTextWidth = avEditor.searchBar.mouse.searchTxt.width + 10;
         avEditor.searchBar.mouse.b.xBtn.visible = false;
      }
      
      private function positionAndDrawAvatarView(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(_avatarEditorView && _avatarEditorView.parent)
            {
               avEditor.charBox.removeChild(_avatarEditorView);
            }
            _avatarEditorView = new AvatarEditorView();
            _avatarEditorView.init(_worldAvatar);
         }
         var _loc2_:Point = AvatarUtility.getAvatarViewPosition(_avatarEditorView.avTypeId);
         _avatarEditorView.x = _loc2_.x;
         _avatarEditorView.y = _loc2_.y;
         if(Utility.isOcean(_worldAvatar.enviroTypeFlag))
         {
            if(Utility.isLand(_worldAvatar.enviroTypeFlag))
            {
               avEditor.charBox.gotoAndStop(3);
            }
            else
            {
               avEditor.charBox.gotoAndStop(2);
            }
         }
         avEditor.charBox.addChild(_avatarEditorView);
         _avatarEditorView.playAnim(13);
      }
      
      private function colorCurrEyePattIcon() : void
      {
         if(_tabOpenId == 1)
         {
            if(_patterns && _patterns.length > 0 && _patterns[_currPattern])
            {
               if(_patterns[_currPattern].icon.numChildren > 0)
               {
                  _patterns[_currPattern].icon.getChildAt(0).setLayerColor(2,_avatarEditorView.colors[1]);
                  _patterns[_currPattern].icon.getChildAt(0).paint(0);
               }
            }
         }
         else if(_tabOpenId == 2)
         {
            if(_eyes && _eyes.length > 0 && _eyes[_currEye])
            {
               if(_eyes[_currEye].icon.numChildren > 0)
               {
                  _eyes[_currEye].icon.getChildAt(0).setLayerColor(3,_avatarEditorView.colors[2]);
                  _eyes[_currEye].icon.getChildAt(0).paint(0);
               }
            }
         }
      }
      
      private function onColorChanged(param1:int, param2:int) : void
      {
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc8_:Array = _avatarEditorView.colors;
         var _loc16_:uint = uint(_loc8_[0]);
         var _loc17_:uint = uint(_loc8_[1]);
         var _loc18_:uint = uint(_loc8_[2]);
         switch(param1)
         {
            case 0:
            case 1:
               _loc12_ = _loc16_ >> 8 & 0xFF;
               _loc13_ = _loc16_ & 0xFF;
               if(param1 == 0)
               {
                  _loc14_ = param2;
                  _loc15_ = _loc16_ >> 16 & 0xFF;
               }
               else
               {
                  _loc14_ = _loc16_ >> 24 & 0xFF;
                  _loc15_ = param2;
               }
               _loc16_ = uint(_loc14_ << 24 | _loc15_ << 16 | _loc12_ << 8 | _loc13_);
               break;
            case 2:
               _loc9_ = param2;
               _loc7_ = _loc18_ >> 16 & 0xFF;
               _loc11_ = _loc18_ >> 8 & 0xFF;
               _loc10_ = _loc18_ & 0xFF;
               _loc18_ = uint(_loc9_ << 24 | _loc7_ << 16 | _loc11_ << 8 | _loc10_);
               break;
            case 3:
               _loc4_ = param2;
               _loc5_ = _loc17_ >> 16 & 0xFF;
               _loc6_ = _loc17_ >> 8 & 0xFF;
               _loc3_ = _loc17_ & 0xFF;
               _loc17_ = uint(_loc4_ << 24 | _loc5_ << 16 | _loc6_ << 8 | _loc3_);
         }
         _avatarEditorView.colors = [_loc16_,_loc17_,_loc18_];
         if(param1 == 2 || param1 == 3)
         {
            colorCurrEyePattIcon();
         }
      }
      
      private function loadPetView() : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc1_:Object = null;
         if(gMainFrame.clientInfo.roomType != 7)
         {
            _loc2_ = PetManager.myPetList;
            while(avEditor.itemWindowPet2.numChildren > 0)
            {
               avEditor.itemWindowPet2.removeChildAt(0);
            }
            while(avEditor.itemWindowPet1.numChildren > 0)
            {
               avEditor.itemWindowPet1.removeChildAt(0);
            }
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].idx == PetManager.myActivePetInvId)
               {
                  _loc1_ = _loc2_[_loc3_];
                  if(PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,_loc1_.type))
                  {
                     _myPet = new GuiPet(_loc1_.idx,_loc1_.lBits,_loc1_.uBits,_loc1_.eBits,_loc1_.type,_loc1_.name,onPetLoaded);
                     if(_myPet.isGround())
                     {
                        avEditor.itemWindowPet2.addChild(_myPet);
                     }
                     else
                     {
                        avEditor.itemWindowPet1.addChild(_myPet);
                     }
                  }
                  break;
               }
               _loc3_++;
            }
         }
      }
      
      private function onPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         _myPet.scaleX = _myPet.scaleY = 2;
         var _loc3_:Matrix = _myPet.transform.matrix;
         _loc3_.scale(-1,1);
         _myPet.transform.matrix = _loc3_;
      }
      
      private function discardAudioItems(param1:Array) : Array
      {
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_].itemDefId != 617)
            {
               _loc2_.push(param1[_loc3_]);
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function sendChangesRequest() : void
      {
         var _loc1_:Boolean = false;
         wereItemsOnOriginally(_itemsOn,_itemsOff);
         if(_itemsOn.length > 0 || _itemsOff.length > 0)
         {
            ItemXtCommManager.requestItemUse(itemUseResponse,_itemsOn.concat(),_itemsOff.concat());
            _waitForIuResponse = true;
            _loc1_ = true;
         }
         else if(_recycle)
         {
            DarkenManager.showLoadingSpiral(false);
            _recycle.init(0,_guiLayer,false,onRecycleClose,900 * 0.5,550 * 0.5);
         }
         if(gMainFrame.userInfo.playerUserInfo.nameBarData != _nameBarData)
         {
            AvatarXtCommManager.requestColorChange(_avatarEditorView.colors,_nameBarData,avatarPaintResponse);
            _waitForApResponse = true;
            _loc1_ = true;
         }
         else if(_worldAvatar.colors[0] != _avatarEditorView.colors[0] || _worldAvatar.colors[1] != _avatarEditorView.colors[1] || _worldAvatar.colors[2] != _avatarEditorView.colors[2])
         {
            AvatarXtCommManager.requestColorChange(_avatarEditorView.colors,gMainFrame.userInfo.playerUserInfo.nameBarData,avatarPaintResponse);
            _waitForApResponse = true;
            _loc1_ = true;
         }
         if(_tradeItemsIn.length > 0 || _tradeItemsOut.length > 0)
         {
            if(_waitForIuResponse)
            {
               _sendDelayedTradeRequest = true;
            }
            else
            {
               TradeManager.changeTradeList(_tradeItemsIn,_tradeItemsOut);
               _tradeItemsIn.length = 0;
               _tradeItemsOut.length = 0;
            }
         }
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null && _shop == null && _recycle == null)
            {
               _onCloseCallback();
            }
         }
         if(_loc1_)
         {
            DarkenManager.showLoadingSpiral(true);
         }
         else
         {
            _worldAvatar.dispatchEvent(new AvatarEvent("OnAvatarChanged"));
         }
      }
      
      private function itemUseResponse(param1:Array, param2:Array, param3:Boolean) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(param3)
         {
            DebugUtility.debugTrace("AvatarEditor: Changes made to avatar were successful");
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               DebugUtility.debugTrace("Item #" + param1[_loc5_] + ": PUT ON");
               _loc5_++;
            }
            _loc4_ = 0;
            while(_loc4_ < param2.length)
            {
               DebugUtility.debugTrace("Item #" + param2[_loc4_] + ": TAKEN OFF");
               _loc4_++;
            }
         }
         applyChanges(param3);
      }
      
      private function avatarPaintResponse(param1:Boolean) : void
      {
         var _loc2_:AvatarInfo = null;
         var _loc3_:Array = null;
         if(param1 && _avatarEditorView)
         {
            _loc2_ = gMainFrame.userInfo.playerAvatarInfo;
            _loc3_ = _avatarEditorView.colors;
            if(_loc2_)
            {
               _loc2_.colors = _loc3_;
            }
            gMainFrame.userInfo.playerUserInfo.nameBarData = _nameBarData;
            _worldAvatar.setColors(_loc3_[0],_loc3_[1],_loc3_[2]);
            AvatarManager.playerAvatarWorldView.updateSpecialPatternColorsAndApply();
         }
         _waitForApResponse = false;
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null && _shop == null && _recycle == null)
            {
               _onCloseCallback();
            }
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function applyChanges(param1:Boolean) : void
      {
         var _loc2_:Avatar = null;
         if(!param1)
         {
            DarkenManager.showLoadingSpiral(false);
            DebugUtility.debugTrace("WARNING: Changes were not made to your avatar");
         }
         else
         {
            _loc2_ = _avatarEditorView.viewAvatar;
            AvatarManager.playerAvatar.rangedAttack = _loc2_.rangedAttack;
            AvatarManager.playerAvatar.meleeAttack = _loc2_.meleeAttack;
            AvatarManager.playerAvatar.defense = _loc2_.defense;
            AvatarManager.playerAvatar.fierceAttack = _loc2_.fierceAttack;
            AvatarManager.playerAvatar.healingPower = _loc2_.healingPower;
         }
         _itemsOn.length = 0;
         _itemsOff.length = 0;
         _waitForIuResponse = false;
         if(_sendDelayedTradeRequest)
         {
            TradeManager.changeTradeList(_tradeItemsIn,_tradeItemsOut);
            _tradeItemsIn.length = 0;
            _tradeItemsOut.length = 0;
         }
         if(!_waitForIuResponse && !_waitForApResponse)
         {
            if(_onCloseCallback != null && _shop == null && _recycle == null)
            {
               _onCloseCallback();
            }
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(xBtn != null && !xBtn.isGray)
         {
            sendChangesRequest();
         }
      }
      
      private function colorTableTabClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(param1.currentTarget.name == avEditor.colorsTabDnBtn.name)
            {
               openTab(0);
            }
            else if(param1.currentTarget.name == avEditor.patternTabDnBtn.name)
            {
               openTab(1);
            }
            else if(param1.currentTarget.name == avEditor.eyesTabDnBtn.name)
            {
               openTab(2);
            }
            else
            {
               DebugUtility.debugTrace("Error AvatarEditor on colorTableTabClick handler: Invalid tab: " + param1.currentTarget.name);
            }
         }
      }
      
      private function colorTableTabOverClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == avEditor.colorsTabDnBtn.name)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14621),665,105);
         }
         else if(param1.currentTarget.name == avEditor.patternTabDnBtn.name)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14622),820,105);
         }
         else if(param1.currentTarget.name == avEditor.eyesTabDnBtn.name)
         {
            GuiManager.toolTip.init(_guiLayer,LocalizationManager.translateIdOnly(14623),742,105);
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function openTab(param1:int) : void
      {
         if(param1 == 0)
         {
            openColorTableColorsTab();
         }
         else if(param1 == 1)
         {
            openColorTablePatternEyesTab(true);
         }
         else if(param1 == 2)
         {
            openColorTablePatternEyesTab(false);
         }
         else
         {
            DebugUtility.debugTrace("Error AvatarEditor on openTab: Invalid tabId: " + param1);
         }
      }
      
      private function openColorTableColorsTab() : void
      {
         avEditor.colorsTabUp.visible = true;
         avEditor.eyesTabUp.visible = false;
         avEditor.patternTabUp.visible = false;
         _tabOpenId = 0;
         avEditor.colorTableBlock.colors.visible = true;
         avEditor.colorTableBlock.patternsAndEyes.visible = false;
      }
      
      private function openColorTablePatternEyesTab(param1:Boolean) : void
      {
         var _loc2_:Object = null;
         avEditor.colorTableBlock.patternsAndEyes.visible = true;
         avEditor.colorTableBlock.colors.visible = false;
         while(_eyePattWindow.numChildren > 1)
         {
            _eyePattWindow.removeChildAt(1);
         }
         if(param1)
         {
            _tabOpenId = 1;
            avEditor.colorsTabUp.visible = false;
            avEditor.eyesTabUp.visible = false;
            avEditor.patternTabUp.visible = true;
            avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.visible = _worldAvatar.customAvId != -1;
            if(avEditor.colorTableBlock.patternsAndEyes.contains(_colorTableEyes))
            {
               avEditor.colorTableBlock.patternsAndEyes.removeChild(_colorTableEyes);
            }
            LocalizationManager.translateId(avEditor.colorTableBlock.patternsAndEyes.topTxt,11213);
            if(_worldAvatar.customAvId != -1)
            {
               if(_customAvtIcon)
               {
                  avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.addChild(_customAvtIcon);
               }
               else
               {
                  _loc2_ = gMainFrame.userInfo.getAvatarDefByAvType(_worldAvatar.customAvId,true);
                  if(_loc2_)
                  {
                     _loadingSpiral = new LoadingSpiral(avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont,avEditor.colorTableBlock.patternsAndEyes.width * 0.5,avEditor.colorTableBlock.patternsAndEyes.height * 0.5);
                     _loadingMediaHelper = new MediaHelper();
                     _loadingMediaHelper.init(_loc2_.iconRefId,onCustomIconLoaded);
                  }
               }
            }
            else
            {
               avEditor.colorTableBlock.patternsAndEyes.addChild(_colorTablePatterns);
            }
            if(_patterns.length > 0)
            {
               if(_patterns.length <= 1)
               {
                  _lArrowBtn.visible = false;
                  _rArrowBtn.visible = false;
               }
               if(_patterns[_currPattern])
               {
                  _eyePattWindow.addChild(_patterns[_currPattern].icon);
               }
            }
            else
            {
               _eyePattWindow.visible = false;
               avEditor.lArrBtn.visible = false;
               avEditor.rArrBtn.visible = false;
            }
         }
         else
         {
            _tabOpenId = 2;
            avEditor.colorsTabUp.visible = false;
            avEditor.eyesTabUp.visible = true;
            avEditor.patternTabUp.visible = false;
            LocalizationManager.translateId(avEditor.colorTableBlock.patternsAndEyes.topTxt,11214);
            if(avEditor.colorTableBlock.patternsAndEyes.contains(_colorTablePatterns))
            {
               avEditor.colorTableBlock.patternsAndEyes.removeChild(_colorTablePatterns);
            }
            if(_customAvtIcon && avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.contains(_customAvtIcon))
            {
               avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.removeChild(_customAvtIcon);
               avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.visible = false;
            }
            avEditor.colorTableBlock.patternsAndEyes.addChild(_colorTableEyes);
            if(_eyes.length > 0)
            {
               if(_eyes.length <= 1)
               {
                  _lArrowBtn.visible = false;
                  _rArrowBtn.visible = false;
               }
               if(_eyes[_currEye])
               {
                  _eyePattWindow.addChild(_eyes[_currEye].icon);
               }
            }
            else
            {
               _eyePattWindow.visible = false;
               _lArrowBtn.visible = false;
               _rArrowBtn.visible = false;
            }
         }
         colorCurrEyePattIcon();
         avEditor.colorTableBlock.patternsAndEyes.visible = true;
         avEditor.colorTableBlock.colors.visible = false;
      }
      
      private function onCustomIconLoaded(param1:MovieClip) : void
      {
         if(_avatarEditorView)
         {
            _customAvtIcon = MovieClip(param1.getChildAt(0));
            if(_loadingSpiral)
            {
               if(_loadingSpiral.parent == avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont)
               {
                  avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.removeChild(_loadingSpiral);
               }
               _loadingSpiral.destroy();
               _loadingSpiral = null;
            }
            avEditor.colorTableBlock.patternsAndEyes.specialAvtIconCont.addChild(_customAvtIcon);
         }
      }
      
      private function createPatternsAndEyesArrays() : void
      {
         var _loc4_:int = 0;
         var _loc2_:Item = null;
         var _loc3_:Array = _avatarEditorView.inventoryBodyModItems;
         _eyes = [];
         _patterns = [];
         _patterns.push(null);
         var _loc1_:Object = _worldAvatar.customAvId != -1 ? gMainFrame.userInfo.getAvatarDefByAvatar(_worldAvatar) : null;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            if(_loc3_[_loc4_].layerId == 2)
            {
               if(_loc1_)
               {
                  if(_loc1_.patternRefId == _loc3_[_loc4_].itemDefId)
                  {
                     _currPattern = _patterns.length;
                     _patterns.push(_loc3_[_loc4_]);
                  }
               }
               else
               {
                  if(_loc3_[_loc4_].getInUse(_worldAvatar.perUserAvId))
                  {
                     _currPattern = _patterns.length;
                  }
                  _patterns.push(_loc3_[_loc4_]);
               }
            }
            else if(_loc3_[_loc4_].layerId == 3)
            {
               if(_loc3_[_loc4_].getInUse(_worldAvatar.perUserAvId))
               {
                  _currEye = _eyes.length;
               }
               _eyes.push(_loc3_[_loc4_]);
            }
            _loc4_++;
         }
         if(_loc1_)
         {
            if(_patterns.length == 1)
            {
               _currPattern = _patterns.length;
               _loc2_ = new Item();
               _loc2_.init(_loc1_.patternRefId);
               _patterns.push(_loc2_);
            }
            setCustomPatternColorIdx();
         }
      }
      
      private function setCustomPatternColorIdx() : void
      {
         var _loc2_:Array = null;
         var _loc1_:* = 0;
         var _loc4_:int = 0;
         var _loc3_:Item = _patterns[_currPattern];
         if(_loc3_)
         {
            _loc2_ = _loc3_.colors;
            _loc1_ = uint(_avatarEditorView.colors[1]);
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               if(_loc2_[_loc4_] == _loc1_)
               {
                  _currCustomPatternColorIdx = _loc4_;
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function arrowBtnHandler(param1:MouseEvent) : void
      {
         var _loc13_:int = 0;
         var _loc12_:* = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc11_:* = 0;
         var _loc10_:Item = null;
         var _loc8_:int = 0;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc9_:Array = null;
         param1.stopPropagation();
         if(param1.currentTarget.name == _lArrowBtn.name)
         {
            _loc13_ = -1;
         }
         else if(param1.currentTarget.name == _rArrowBtn.name)
         {
            _loc13_ = 1;
         }
         if(_tabOpenId == 1 && _worldAvatar.customAvId != -1)
         {
            _currCustomPatternColorIdx += _loc13_;
            if(_currCustomPatternColorIdx >= _patterns[_currPattern].colors.length)
            {
               _currCustomPatternColorIdx = 0;
            }
            else if(_currCustomPatternColorIdx < 0)
            {
               _currCustomPatternColorIdx = _patterns[_currPattern].colors.length - 1;
            }
            _loc12_ = uint(_patterns[_currPattern].colors[_currCustomPatternColorIdx]);
            _loc5_ = _loc12_ >> 24;
            _loc6_ = _loc12_ >> 16 & 0xFF;
            _loc7_ = _loc12_ >> 8 & 0xFF;
            _loc2_ = _loc12_ & 0xFF;
            _loc11_ = uint(_loc11_ = uint(_loc5_ << 24 | _loc6_ << 16 | _loc7_ << 8 | _loc2_));
            _avatarEditorView.colors = [_avatarEditorView.colors[0],_loc11_,_avatarEditorView.colors[2]];
            colorCurrEyePattIcon();
         }
         else
         {
            while(_eyePattWindow.numChildren > 1)
            {
               _eyePattWindow.removeChildAt(1);
            }
            _loc3_ = false;
            if(_tabOpenId == 1)
            {
               _loc10_ = _patterns[_currPattern];
               _loc4_ = _currPattern;
               _loc9_ = _patterns;
            }
            else if(_tabOpenId == 2)
            {
               _loc10_ = _eyes[_currEye];
               _loc4_ = _currEye;
               _loc9_ = _eyes;
            }
            _loc4_ += _loc13_;
            if(_loc4_ < 0)
            {
               _loc4_ = _loc9_.length - 1;
            }
            else if(_loc4_ > _loc9_.length - 1)
            {
               _loc4_ = 0;
            }
            if(_loc9_[_loc4_] == null)
            {
               hideItem(_loc10_);
            }
            else
            {
               _loc10_ = _loc9_[_loc4_];
               showItem(_loc10_,hideBodModWhenShowingBodMod);
            }
            if(_loc9_[_loc4_] && _loc9_[_loc4_].icon != null)
            {
               _eyePattWindow.addChild(_loc9_[_loc4_].icon);
            }
            if(_tabOpenId == 1)
            {
               _currPattern = _loc4_;
            }
            else if(_tabOpenId == 2)
            {
               _currEye = _loc4_;
            }
            colorCurrEyePattIcon();
         }
      }
      
      public function showItem(param1:Item, param2:Function = null) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Array = null;
         var _loc4_:Array = null;
         var _loc8_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1)
         {
            _loc3_ = param1.invIdx;
            if(_itemsOn && _itemsOff)
            {
               if(param1.type == 1)
               {
                  _loc5_ = _avatarEditorView.inventoryClothingItems;
                  _loc4_ = _worldAvatar.inventoryClothing.itemArray;
               }
               else
               {
                  _loc5_ = _avatarEditorView.inventoryBodyModItems;
                  _loc4_ = _worldAvatar.inventoryBodyMod.itemArray;
               }
               _loc6_ = 0;
               while(_loc6_ < _loc5_.length)
               {
                  if(_loc5_[_loc6_].invIdx == param1.invIdx)
                  {
                     if(_itemsOff.indexOf(_loc3_) != -1)
                     {
                        _itemsOff.splice(_itemsOff.indexOf(_loc3_),1);
                     }
                     _loc7_ = 0;
                     while(_loc7_ < _loc4_.length)
                     {
                        if(param1.invIdx == _loc4_[_loc7_].invIdx)
                        {
                           _loc8_ = true;
                           if(!_loc4_[_loc7_].getInUse(_worldAvatar.perUserAvId))
                           {
                              if(_itemsOn.indexOf(_loc3_) == -1)
                              {
                                 _itemsOn.push(_loc3_);
                              }
                              break;
                           }
                        }
                        _loc7_++;
                     }
                     if(!_loc8_ && _itemsOn.indexOf(_loc3_) == -1)
                     {
                        _itemsOn.push(_loc3_);
                     }
                     break;
                  }
                  _loc6_++;
               }
            }
            _avatarEditorView.showAccessory(param1,param2);
         }
      }
      
      public function hideItem(param1:Item) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         if(param1)
         {
            _loc2_ = param1.invIdx;
            if(_itemsOn && _itemsOff)
            {
               if(param1.type == 1)
               {
                  _loc3_ = _avatarEditorView.inventoryClothingItems;
               }
               else
               {
                  _loc3_ = _avatarEditorView.inventoryBodyModItems;
               }
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  if(_loc3_[_loc4_].invIdx == param1.invIdx)
                  {
                     if(_itemsOff.indexOf(_loc2_) == -1)
                     {
                        _itemsOff.push(_loc2_);
                     }
                     if(_itemsOn.indexOf(_loc2_) != -1)
                     {
                        _itemsOn.splice(_itemsOn.indexOf(_loc2_),1);
                     }
                     break;
                  }
                  _loc4_++;
               }
            }
            _avatarEditorView.hideAccessory(param1);
         }
      }
      
      public function onShopBtnHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(avEditor.shopBtn.isGray)
         {
            return;
         }
         _shop = new Shop();
         if(AvatarManager.roomEnviroType == 1)
         {
            _shop.init(50,1000,_worldAvatar,_guiLayer,onShopClose);
         }
         else
         {
            _shop.init(11,1000,_worldAvatar,_guiLayer,onShopClose);
         }
         sendChangesRequest();
      }
      
      public function onShopBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.shopBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),AvatarManager.roomEnviroType == 0 ? LocalizationManager.translateIdOnly(14624) : LocalizationManager.translateIdOnly(14625),0,-45,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onShopBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function onPetBtnHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.petsBtn.isGray)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         _petInventory = new PetInventory();
         _petInventory.init(onPetInventoryClose);
      }
      
      private function onPetInventoryClose() : void
      {
         _petInventory = null;
         reloadCurrencyCounts();
         loadPetView();
      }
      
      private function onPetBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.petsBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(11240),0,-45,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onPetBtnOutHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onRecycleClothesBtn(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(avEditor.recycleClothesBtn.isGray)
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         _recycle = new RecycleItems();
         sendChangesRequest();
      }
      
      public function openRecycle() : void
      {
         if(_recycle && !_recycle.hasBeenInited())
         {
            DarkenManager.showLoadingSpiral(false);
            _recycle.init(0,_guiLayer,false,onRecycleClose,900 * 0.5,550 * 0.5);
         }
      }
      
      private function onRecycleClothesBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.recycleClothesBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(14626),0,-35);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(_recycle)
         {
            _recycle.destroy();
            _recycle = null;
         }
         if(param1)
         {
            reloadCurrencyCounts();
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = true;
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.sortBtn.visible = true;
            avEditor.itemCounter.visible = true;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            _itemsOn = [];
            _itemsOff = [];
            positionAndDrawAvatarView(true);
            createPatternsAndEyesArrays();
            _currClothesArray = _allNewestClothes = _avatarEditorView.inventoryClothingItems;
            _headItems = Utility.sortItemsAll(_currClothesArray,0,8,9,10);
            _neckItems = Utility.sortItemsAll(_currClothesArray,0,7);
            _backItems = Utility.sortItemsAll(_currClothesArray,0,6);
            _legItems = Utility.sortItemsAll(_currClothesArray,0,5);
            _tailItems = Utility.sortItemsAll(_currClothesArray,0,4);
            _itemTypeItems = Utility.sortByItem(_currClothesArray,0);
            _allOldestClothes = _allNewestClothes.concat().reverse();
            if(_currClothesArray)
            {
               _currClothesArray = convertIntToList(_mainClothingSortType,true,false);
            }
            _fullClothesList = _fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,0,8,9,10);
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,0,7);
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,0,6);
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,0,5);
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,0,4);
            _itemTypeDenItems = Utility.sortByItem(_currClothesArray,0);
            _fullAllOldestClothes = _fullallNewestClothes.concat().reverse();
            avEditor.itemCounter.counterTxt.text = _allNewestClothes.length + "/" + Shop.maxItems;
            _currTradesArray = gMainFrame.userInfo.getMyTradeList().slice();
            _itemTradeWindows = null;
            if(_itemClothingWindows)
            {
               _itemClothingWindows.destroy();
               _itemClothingWindows = null;
            }
            createItemWindows(_currClothesArray,avEditor.itemBlock);
         }
      }
      
      private function onShopClose(param1:Boolean) : void
      {
         if(_shop)
         {
            _shop.destroy();
            _shop = null;
         }
         if(param1)
         {
            reloadCurrencyCounts();
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = true;
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.sortBtn.visible = true;
            avEditor.itemCounter.visible = true;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            _itemsOn = [];
            _itemsOff = [];
            positionAndDrawAvatarView(true);
            createPatternsAndEyesArrays();
            _currClothesArray = _allNewestClothes = _avatarEditorView.inventoryClothingItems;
            _headItems = Utility.sortItemsAll(_currClothesArray,0,8,9,10);
            _neckItems = Utility.sortItemsAll(_currClothesArray,0,7);
            _backItems = Utility.sortItemsAll(_currClothesArray,0,6);
            _legItems = Utility.sortItemsAll(_currClothesArray,0,5);
            _tailItems = Utility.sortItemsAll(_currClothesArray,0,4);
            _itemTypeItems = Utility.sortByItem(_currClothesArray,0);
            _allOldestClothes = _allNewestClothes.concat().reverse();
            if(_currClothesArray)
            {
               _currClothesArray = convertIntToList(_mainClothingSortType,true,false);
            }
            _fullClothesList = _fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
            _fullHeadItems = Utility.sortItemsAll(_fullClothesList,0,8,9,10);
            _fullNeckItems = Utility.sortItemsAll(_fullClothesList,0,7);
            _fullBackItems = Utility.sortItemsAll(_fullClothesList,0,6);
            _fullLegItems = Utility.sortItemsAll(_fullClothesList,0,5);
            _fullTailItems = Utility.sortItemsAll(_fullClothesList,0,4);
            _itemTypeDenItems = Utility.sortByItem(_currClothesArray,0);
            _fullAllOldestClothes = _fullallNewestClothes.concat().reverse();
            avEditor.itemCounter.counterTxt.text = _allNewestClothes.length + "/" + Shop.maxItems;
            if(_itemClothingWindows)
            {
               _itemClothingWindows.destroy();
               _itemClothingWindows = null;
            }
            createItemWindows(_currClothesArray,avEditor.itemBlock);
         }
      }
      
      private function numTradeItemsInClothesList(param1:Array) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _currTradesArray.length)
         {
            if(_currTradesArray[_loc4_].type == 0)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.length)
               {
                  if(_currTradesArray[_loc4_].invIdx == param1[_loc3_].invIdx)
                  {
                     _loc2_++;
                     break;
                  }
                  _loc3_++;
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function numTradeItemsInDenItemsList(param1:Array) : int
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _currTradesArray.length)
         {
            if(_currTradesArray[_loc4_].type == 1)
            {
               _loc3_ = 0;
               while(_loc3_ < param1.length)
               {
                  if(_currTradesArray[_loc4_].invIdx == param1[_loc3_].invIdx)
                  {
                     _loc2_++;
                     break;
                  }
                  _loc3_++;
               }
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function createItemWindows(param1:Array, param2:MovieClip, param3:Boolean = false) : void
      {
         var _loc6_:WindowAndScrollbarGenerator = null;
         var _loc4_:int = 0;
         var _loc17_:int = 0;
         var _loc20_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc7_:Array = null;
         var _loc18_:Array = null;
         var _loc16_:Object = null;
         var _loc13_:int = 0;
         var _loc15_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Object = null;
         var _loc10_:int = 0;
         var _loc19_:Number = NaN;
         var _loc14_:int = 0;
         _loc5_ = false;
         _loc5_ = true;
         param1 == _currTradesArray ? _loc5_ : (_loc5_);
         if(_loc5_)
         {
            _loc4_ = 12;
            _loc17_ = Math.ceil(_loc4_ / 3) * 3;
            avEditor.searchBar.visible = false;
         }
         else if(param1 == _allNewestClothes || param1 == _currClothesArray || param1 == _fullClothesList || _tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
         {
            _loc9_ = true;
            _loc4_ = Math.max(param1.length,12);
            if(param2 == avEditor.itemBlock)
            {
               _loc17_ = Math.ceil(param1.length / 3) * 3;
            }
            else
            {
               _loc17_ = Math.ceil((param1.length - numTradeItemsInClothesList(param1)) / 3) * 3;
            }
            onSearchBarDown(null);
            onSearchTextInput(null);
            if(_allNewestClothes.length <= 0)
            {
               avEditor.sortBtn.visible = false;
               avEditor.searchBar.visible = false;
            }
            else
            {
               avEditor.searchBar.visible = true;
            }
         }
         else
         {
            if(!(param1 == _currDenItemsArray || param1 == _allNewestDenItems))
            {
               throw new Error("None of our lists match given items list");
            }
            _loc4_ = Math.max(param1.length,12);
            _loc17_ = Math.ceil((param1.length - numTradeItemsInDenItemsList(param1)) / 3) * 3;
            avEditor.searchBar.visible = false;
         }
         if(avEditor.tradeBtnUp.visible)
         {
            _loc8_ = true;
         }
         if(param2 == avEditor.itemBlock)
         {
            if(_loc8_)
            {
               _loc6_ = _itemTradeWindows;
            }
            else
            {
               _loc6_ = _itemClothingWindows;
            }
            if(param3 && _loc6_)
            {
               _mainScrollYPosition = _loc6_.scrollYValue;
            }
            while(avEditor.itemBlock.numChildren > 1)
            {
               avEditor.itemBlock.removeChildAt(avEditor.itemBlock.numChildren - 1);
            }
         }
         else if(param2 == _tradeWindow.itemBlock)
         {
            if(_loc9_)
            {
               _loc6_ = _tradeClothingWindows;
            }
            else
            {
               _loc6_ = _tradeDenWindows;
               GuiManager.resetItemAndThemeDenWindows();
            }
            while(_tradeWindow.itemBlock.numChildren > 1)
            {
               _tradeWindow.itemBlock.removeChildAt(_tradeWindow.itemBlock.numChildren - 1);
            }
         }
         if(_loc6_ == null)
         {
            _loc7_ = [];
            _loc18_ = [];
            _loc16_ = null;
            _loc15_ = 0;
            for(; _loc15_ < _loc4_; _loc15_++)
            {
               if(_loc15_ < _loc4_)
               {
                  if(param1[_loc15_])
                  {
                     if(avEditor.clothesBtnUp.visible)
                     {
                        _loc16_ = param1[_loc15_];
                     }
                     else if(_loc5_)
                     {
                        _loc12_ = null;
                        if(param1[_loc15_].type == 0)
                        {
                           _loc11_ = 0;
                           while(_loc11_ < _fullClothesList.length)
                           {
                              if(_fullClothesList[_loc11_].invIdx == param1[_loc15_].invIdx)
                              {
                                 _loc12_ = _fullClothesList[_loc11_];
                                 break;
                              }
                              _loc11_++;
                           }
                           if(_loc12_)
                           {
                              _loc16_ = new Item();
                              _loc16_.init(_loc12_.defId,_loc12_.invIdx,_loc12_.color,_loc12_.inUseFlagLand,_loc12_.inUseFlagOcean);
                           }
                        }
                        else
                        {
                           _loc11_ = 0;
                           while(_loc11_ < _allNewestDenItems.length)
                           {
                              if(_allNewestDenItems[_loc11_].itemDefId != 617)
                              {
                                 if(_allNewestDenItems[_loc11_].invIdx == param1[_loc15_].invIdx)
                                 {
                                    _loc12_ = _allNewestDenItems[_loc11_];
                                    break;
                                 }
                              }
                              _loc11_++;
                           }
                           if(_loc12_)
                           {
                              _loc16_ = new DenItem();
                              _loc16_.init(_loc12_.itemDefId,_loc12_.invIdx,_loc12_.categoryId,_loc12_.version,_loc12_.refId);
                           }
                        }
                     }
                     else
                     {
                        _loc16_ = param1[_loc15_];
                        _loc10_ = 0;
                        while(_loc10_ < _currTradesArray.length)
                        {
                           if((_loc16_ is Item && _currTradesArray[_loc10_].type == 0 || _loc16_ is DenItem && _currTradesArray[_loc10_].type == 1) && _loc16_.invIdx == _currTradesArray[_loc10_].invIdx)
                           {
                              _loc20_ = true;
                              break;
                           }
                           _loc10_++;
                        }
                        if(_loc20_)
                        {
                           _loc20_ = false;
                           _loc14_++;
                           continue;
                        }
                     }
                     _loc18_.push(_loc13_ + _loc14_);
                     if(_loc16_)
                     {
                        _loc7_.push(_loc16_);
                     }
                  }
               }
               _loc13_++;
            }
            if(param2 == avEditor.itemBlock)
            {
               _loc19_ = _mainScrollYPosition;
            }
            else if(_tradeListViewType == 0)
            {
               _loc19_ = _tradeClothingScrollYPosition;
            }
            else
            {
               _loc19_ = _tradeDenScrollYPosition;
            }
            _loc6_ = new WindowAndScrollbarGenerator();
            _loc6_.init(param2.width,param2.height,3,_loc19_,3,4,12,2,2,0,ItemWindowOriginal,_loc7_,"icon",0,{
               "mouseDown":winMouseClick,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut,
               "memberOnlyDown":memberOnlyDown
            },{
               "isAvatarEditor":true,
               "isTradeList":_loc5_,
               "showAddRemoveBtns":_loc5_,
               "isChoosingForTradeList":_loc8_,
               "indexArray":_loc18_
            });
            if(param2 == avEditor.itemBlock)
            {
               if(_loc8_)
               {
                  _itemTradeWindows = _loc6_;
               }
               else
               {
                  _itemClothingWindows = _loc6_;
               }
            }
            else if(_loc9_)
            {
               _tradeClothingWindows = _loc6_;
            }
            else
            {
               _tradeDenWindows = _loc6_;
            }
         }
         param2.addChild(_loc6_);
      }
      
      private function openCloseTradeWindow(param1:MovieClip) : void
      {
         var _loc3_:Boolean = false;
         var _loc2_:Array = null;
         _tradeWindow.visible = !_tradeWindow.visible;
         avEditor.blackoutFull.visible = !avEditor.blackoutFull.visible;
         if(_tradeWindow.visible)
         {
            if(_tradeListViewType == 0)
            {
               _tradeWindow.denBtnUp.visible = false;
               _tradeWindow.denBtnDown.visible = true;
               _tradeWindow.clothesBtnUp.visible = true;
               _tradeWindow.clothesBtnDown.visible = false;
               _tradeSort.sort7.visible = true;
               _tradeSort.sort6.visible = true;
               _tradeSort.sort5.visible = true;
               LocalizationManager.translateId(_tradeSort.sort8.txt,11205);
               LocalizationManager.translateId(_tradeSort.sort7.txt,11206);
               LocalizationManager.translateId(_tradeSort.sort6.txt,11207);
               LocalizationManager.translateId(_tradeSort.sort5.txt,11208);
               LocalizationManager.translateId(_tradeSort.sort4.txt,11209);
               LocalizationManager.translateId(_tradeSort.sort3.txt,11210);
               LocalizationManager.translateId(_tradeSort.sort2.txt,11211);
               LocalizationManager.translateId(_tradeSort.sort1.txt,11212);
            }
            else
            {
               _tradeWindow.denBtnUp.visible = true;
               _tradeWindow.denBtnDown.visible = false;
               _tradeWindow.clothesBtnUp.visible = false;
               _tradeWindow.clothesBtnDown.visible = true;
               LocalizationManager.translateId(_tradeSort.sort4.txt,11215);
               LocalizationManager.translateId(_tradeSort.sort3.txt,11216);
               LocalizationManager.translateId(_tradeSort.sort2.txt,11211);
               LocalizationManager.translateId(_tradeSort.sort1.txt,11212);
               _tradeSort.sort5.visible = false;
               _tradeSort.sort6.visible = false;
               _tradeSort.sort7.visible = false;
               _tradeSort.sort8.visible = false;
            }
            if(_achievementViewer)
            {
               _achievementViewer.close();
            }
            _tradeSort.visible = false;
            _loc3_ = _tradeListViewType == 0;
            _loc2_ = convertIntToList(_loc3_ ? _tradeClothingSortType : _tradeDenSortType,_loc3_);
            createItemWindows(_loc2_,param1);
         }
         else
         {
            if(_tradeListViewType == 0 && _tradeClothingWindows)
            {
               _tradeClothingScrollYPosition = _tradeClothingWindows.scrollYValue;
            }
            else if(_tradeDenWindows)
            {
               _tradeDenScrollYPosition = _tradeDenWindows.scrollYValue;
            }
            createItemWindows(_currTradesArray,avEditor.itemBlock);
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.numChildren >= 2)
         {
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
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.numChildren >= 2)
         {
            if(param1.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               param1.currentTarget.cir.gotoAndStop("down");
            }
            else if(param1.currentTarget.cir.currentFrameLabel != "down")
            {
               param1.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private function winMouseClick(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Array = null;
         var _loc7_:String = null;
         var _loc5_:String = null;
         var _loc6_:int = 0;
         var _loc4_:Boolean = false;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(avEditor.clothesBtnUp.visible)
         {
            _loc2_ = _currClothesArray[param1.currentTarget.index];
         }
         else if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
         {
            _loc2_ = _fullClothesList[param1.currentTarget.index];
         }
         else if(_tradeWindow.visible && _tradeWindow.denBtnUp.visible)
         {
            _loc2_ = _currDenItemsArray[param1.currentTarget.index];
         }
         else if(avEditor.tradeBtnUp.visible)
         {
            _loc2_ = _currTradesArray[param1.currentTarget.index];
         }
         if(_loc2_)
         {
            if(!_tradeWindow.visible && avEditor.clothesBtnUp.visible)
            {
               if(!ItemXtCommManager.canUseItem(_loc2_.defId,_worldAvatar,_worldAvatar.customAvId != -1))
               {
                  _loc3_ = ItemXtCommManager.avTypeThatCanUseItem(_loc2_.defId);
                  if(_loc3_.length > 0)
                  {
                     if(_loc3_.length == 1)
                     {
                        new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14698,LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(_loc3_[0],false).titleStrRef)));
                     }
                     else
                     {
                        _loc7_ = "";
                        _loc6_ = 0;
                        while(_loc6_ < _loc3_.length)
                        {
                           _loc5_ = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(_loc3_[_loc6_],false).titleStrRef);
                           if(_loc7_ == "")
                           {
                              _loc7_ += _loc5_;
                           }
                           else
                           {
                              _loc7_ += ", " + _loc5_;
                           }
                           _loc6_++;
                        }
                        new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14698,_loc7_));
                     }
                  }
                  return;
               }
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse" && _loc2_.getInUse(_worldAvatar.perUserAvId))
               {
                  hideItem(Item(_loc2_));
                  param1.currentTarget.cir.gotoAndStop("over");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "downMouse" && !_loc2_.getInUse(_worldAvatar.perUserAvId))
               {
                  showItem(Item(_loc2_),hideItemWhenShowingItem);
                  param1.currentTarget.cir.gotoAndStop("downMouse");
               }
               else
               {
                  DebugUtility.debugTrace("Item is in use? But not in use? Huuuuuuuuh");
               }
            }
            else if(!_tradeWindow.visible && avEditor.tradeBtnUp.visible)
            {
               param1.currentTarget.cir.gotoAndStop("up");
               if(param1.currentTarget.removeBtn.visible)
               {
                  _currTradesArray.splice(param1.currentTarget.index,1);
                  if(_loc2_.type == 0)
                  {
                     TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                  }
                  else
                  {
                     TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                  }
                  addRemoveTradeItemFromList(_loc2_,false);
                  if(_itemTradeWindows)
                  {
                     _itemTradeWindows.destroy();
                     _itemTradeWindows = null;
                  }
                  createItemWindows(_currTradesArray,avEditor.itemBlock);
               }
               else
               {
                  openCloseTradeWindow(_tradeWindow.itemBlock);
               }
            }
            else if(_tradeWindow.visible && (_tradeWindow.denBtnUp.visible || _tradeWindow.clothesBtnUp.visible))
            {
               param1.currentTarget.cir.gotoAndStop("up");
               if(_loc2_ is Item)
               {
                  _loc2_ = {
                     "type":0,
                     "invIdx":_loc2_.invIdx
                  };
                  if(_tradeClothingWindows)
                  {
                     _tradeClothingWindows.destroy();
                     _tradeClothingWindows = null;
                  }
               }
               else if(_loc2_ is DenItem)
               {
                  _loc2_ = {
                     "type":1,
                     "invIdx":_loc2_.invIdx
                  };
                  if(_tradeDenWindows)
                  {
                     _tradeDenWindows.destroy();
                     _tradeDenWindows = null;
                  }
               }
               _currTradesArray.push(_loc2_);
               if(_loc2_.type == 0)
               {
                  TradeManager.adjustByOnNumClothingItemsInMyTradeList(1);
               }
               else
               {
                  TradeManager.adjustByOnNumDenItemsInMyTradeList(1);
               }
               addRemoveTradeItemFromList(_loc2_,true);
               if(_itemTradeWindows)
               {
                  _itemTradeWindows.destroy();
                  _itemTradeWindows = null;
               }
               openCloseTradeWindow(null);
            }
            else
            {
               DebugUtility.debugTrace("Wow nothing is visible? How is that possible?");
            }
            AJAudio.playSubMenuBtnClick();
         }
         else if(param1.currentTarget.addBtn.visible)
         {
            _loc4_ = _tradeListViewType == 0;
            if(_loc4_)
            {
               _fullClothesList = convertIntToList(_tradeClothingSortType,_loc4_);
            }
            else
            {
               _currDenItemsArray = convertIntToList(_tradeDenSortType,_loc4_);
            }
            openCloseTradeWindow(_tradeWindow.itemBlock);
         }
         else
         {
            DebugUtility.debugTrace("Curr Item is null, and the addBtn is not visible??");
         }
      }
      
      private function memberOnlyDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         UpsellManager.displayPopup(9,"equipAccessory/" + _currClothesArray[param1.currentTarget.index].name);
      }
      
      private function hideItemWhenShowingItem(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc2_:MovieClip = null;
         var _loc5_:int = _itemsOn.indexOf(param1.invIdx);
         if(_loc5_ == -1)
         {
            _loc3_ = 0;
            while(_loc3_ < _currClothesArray.length)
            {
               if(_currClothesArray[_loc3_].invIdx == param1.invIdx)
               {
                  if(_itemsOff)
                  {
                     _itemsOff.push(param1.invIdx);
                     break;
                  }
               }
               _loc3_++;
            }
         }
         if(_itemsOn)
         {
            if(_loc5_ != -1)
            {
               _itemsOn.splice(_itemsOn.indexOf(param1.invIdx),1);
            }
         }
         if(_itemClothingWindows)
         {
            _loc4_ = 0;
            while(_loc4_ < _itemClothingWindows.bg.numChildren)
            {
               _loc2_ = MovieClip(_itemClothingWindows.bg.getChildAt(_loc4_));
               if(_currClothesArray[_loc2_.index].invIdx == param1.invIdx)
               {
                  _loc2_.cir.gotoAndStop("up");
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function hideBodModWhenShowingBodMod(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = _avatarEditorView.inventoryBodyModItems;
         var _loc4_:int = _itemsOn.indexOf(param1.invIdx);
         if(_loc4_ == -1)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(_loc2_[_loc3_].invIdx == param1.invIdx)
               {
                  if(_itemsOff)
                  {
                     _itemsOff.push(param1.invIdx);
                     break;
                  }
               }
               _loc3_++;
            }
         }
         if(_itemsOn)
         {
            if(_loc4_ != -1)
            {
               _itemsOn.splice(_itemsOn.indexOf(param1.invIdx),1);
            }
         }
      }
      
      private function wereItemsOnOriginally(param1:Array, param2:Array) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:Array = _worldAvatar.inventoryClothing.itemArray.concat(_worldAvatar.inventoryBodyMod.itemArray);
         _loc5_ = 0;
         while(_loc5_ < param1.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(param1[_loc5_] == _loc3_[_loc4_].invIdx && _loc3_[_loc4_].getInUse(_worldAvatar.perUserAvId))
               {
                  param1.splice(_loc5_,1);
                  _loc5_--;
                  break;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         _loc5_ = 0;
         while(_loc5_ < param2.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(param2[_loc5_] == _loc3_[_loc4_].invIdx && !_loc3_[_loc4_].getInUse(_worldAvatar.perUserAvId))
               {
                  param2.splice(_loc5_,1);
                  _loc5_--;
                  break;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         _itemsOn = param1;
         _itemsOff = param2;
      }
      
      private function addRemoveTradeItemFromList(param1:Object, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = gMainFrame.userInfo.getMyTradeList();
         if(param2)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc3_.length)
            {
               if(_loc3_[_loc5_].invIdx == param1.invIdx && _loc3_[_loc5_].type == param1.type)
               {
                  _tradeItemsOut.splice(_tradeItemsOut.indexOf(param1),1);
                  return;
               }
               _loc5_++;
            }
            _tradeItemsIn.push(param1);
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < _loc3_.length)
            {
               if(_loc3_[_loc5_].invIdx == param1.invIdx && _loc3_[_loc5_].type == param1.type)
               {
                  _tradeItemsOut.push(param1);
                  return;
               }
               _loc5_++;
            }
            _tradeItemsIn.splice(_tradeItemsIn.indexOf(param1),1);
         }
      }
      
      private function sortByHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(avEditor.sortBtn.isGray)
         {
            return;
         }
         if(!_tradeWindow.visible)
         {
            avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
         }
         else
         {
            _tradeSort.visible = !_tradeSort.visible;
         }
      }
      
      private function sortBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc3_:int = 0;
         if(param1.currentTarget.name == avEditor.sortPopup.sort8.name)
         {
            if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullHeadItems;
               _tradeClothingSortType = 8;
            }
            else
            {
               _loc2_ = _currClothesArray = _headItems;
               _mainClothingSortType = 8;
            }
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.sort7.name)
         {
            if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullNeckItems;
               _tradeClothingSortType = 7;
            }
            else
            {
               _loc2_ = _currClothesArray = _neckItems;
               _mainClothingSortType = 7;
            }
         }
         else if(param1.currentTarget.name == (avEditor.sortPopup.sort6.name || _tradeSort.sort6.name))
         {
            if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullBackItems;
               _tradeClothingSortType = 6;
            }
            else
            {
               _loc2_ = _currClothesArray = _backItems;
               _mainClothingSortType = 6;
            }
         }
         else if(param1.currentTarget.name == (avEditor.sortPopup.sort5.name || _tradeSort.sort5.name))
         {
            if(_tradeWindow.visible && _tradeWindow.denBtnUp.visible)
            {
               _loc2_ = _currDenItemsArray = _floorItems;
               _loc3_ = 1;
               _tradeDenSortType = 5;
            }
            else if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullLegItems;
               _tradeClothingSortType = 5;
            }
            else
            {
               _loc2_ = _currClothesArray = _legItems;
               _mainClothingSortType = 5;
            }
         }
         else if(param1.currentTarget.name == (avEditor.sortPopup.sort4.name || _tradeSort.sort4.name))
         {
            if(_tradeWindow.visible && _tradeWindow.denBtnUp.visible)
            {
               _loc2_ = _currDenItemsArray = _themeItems;
               _loc3_ = 1;
               _tradeDenSortType = 4;
            }
            else if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullTailItems;
               _tradeClothingSortType = 4;
            }
            else
            {
               _loc2_ = _currClothesArray = _tailItems;
               _mainClothingSortType = 4;
            }
         }
         else if(param1.currentTarget.name == (avEditor.sortPopup.sort3.name || _tradeSort.sort3.name))
         {
            if(_tradeWindow.visible && _tradeWindow.denBtnUp.visible)
            {
               _loc2_ = _currDenItemsArray = _itemTypeDenItems;
               _loc3_ = 1;
               _tradeDenSortType = 3;
            }
            else if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullItemTypeItems;
               _tradeClothingSortType = 3;
            }
            else
            {
               _loc2_ = _currClothesArray = _itemTypeItems;
               _mainClothingSortType = 3;
            }
         }
         else if(param1.currentTarget.name == (avEditor.sortPopup.sort2.name || _tradeSort.sort2.name))
         {
            if(_tradeWindow.visible && _tradeWindow.denBtnUp.visible)
            {
               _loc2_ = _currDenItemsArray = _allNewestDenItems;
               _loc3_ = 1;
               _tradeDenSortType = 2;
            }
            else if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullallNewestClothes;
               _tradeClothingSortType = 2;
            }
            else
            {
               _loc2_ = _currClothesArray = _allNewestClothes;
               _mainClothingSortType = 2;
            }
         }
         else if(param1.currentTarget.name == (avEditor.sortPopup.sort1.name || _tradeSort.sort1.name))
         {
            if(_tradeWindow.visible && _tradeWindow.denBtnUp.visible)
            {
               _loc2_ = _currDenItemsArray = _allOldestDenItems;
               _loc3_ = 1;
               _tradeDenSortType = 1;
            }
            else if(_tradeWindow.visible && _tradeWindow.clothesBtnUp.visible)
            {
               _loc2_ = _fullClothesList = _fullAllOldestClothes;
               _tradeClothingSortType = 1;
            }
            else
            {
               _loc2_ = _currClothesArray = _allOldestClothes;
               _mainClothingSortType = 1;
            }
         }
         else if(param1.currentTarget.name == avEditor.sortPopup.bg.name)
         {
            avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         if(_loc2_)
         {
            if(_tradeWindow.visible)
            {
               if(_loc3_ == 0)
               {
                  _tradeClothingScrollYPosition = 0;
               }
               else
               {
                  _tradeDenScrollYPosition = 0;
               }
               _tradeSort.visible = !_tradeSort.visible;
               if(_loc3_ == 0)
               {
                  _tradeClothingWindows.destroy();
                  _tradeClothingWindows = null;
               }
               else
               {
                  _tradeDenWindows.destroy();
                  _tradeDenWindows = null;
               }
               createItemWindows(_loc2_,_tradeWindow.itemBlock);
            }
            else
            {
               if(_loc3_ == 0)
               {
                  _itemClothingWindows.destroy();
                  _itemClothingWindows = null;
               }
               else
               {
                  _itemTradeWindows.destroy();
                  _itemTradeWindows = null;
               }
               _mainScrollYPosition = 0;
               avEditor.sortPopup.visible = !avEditor.sortPopup.visible;
               createItemWindows(_loc2_,avEditor.itemBlock);
            }
         }
      }
      
      private function clothesDenAndTradeHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!_tradeWindow.visible && param1.currentTarget.name == avEditor.clothesBtnDown.name)
         {
            if(param1.currentTarget.name == avEditor.clothesBtnDown.name)
            {
               _currClothesArray = convertIntToList(_mainClothingSortType,true,false);
            }
            avEditor.tradeBtnUp.visible = false;
            avEditor.tradeBtnDown.visible = true;
            avEditor.clothesBtnUp.visible = true;
            avEditor.clothesBtnDown.visible = false;
            avEditor.sortBtn.visible = true;
            avEditor.itemCounter.visible = true;
            avEditor.infoBtn.visible = false;
            avEditor.howTxt.visible = false;
            LocalizationManager.translateId(avEditor.sortPopup.sort8.txt,11205);
            LocalizationManager.translateId(avEditor.sortPopup.sort7.txt,11206);
            LocalizationManager.translateId(avEditor.sortPopup.sort6.txt,11207);
            LocalizationManager.translateId(avEditor.sortPopup.sort5.txt,11208);
            LocalizationManager.translateId(avEditor.sortPopup.sort4.txt,11209);
            LocalizationManager.translateId(avEditor.sortPopup.sort3.txt,11210);
            LocalizationManager.translateId(avEditor.sortPopup.sort2.txt,11211);
            LocalizationManager.translateId(avEditor.sortPopup.sort1.txt,11212);
            createItemWindows(_currClothesArray,avEditor.itemBlock);
         }
         else if(!_tradeWindow.visible && param1.currentTarget.name == avEditor.tradeBtnDown.name)
         {
            if(avEditor.tradeBtnDown.isGray)
            {
               return;
            }
            if(param1.currentTarget.name == avEditor.tradeBtnDown.name)
            {
               _currClothesArray = convertIntToList(_mainClothingSortType,true,false);
            }
            avEditor.tradeBtnUp.visible = true;
            avEditor.tradeBtnDown.visible = false;
            avEditor.clothesBtnUp.visible = false;
            avEditor.clothesBtnDown.visible = true;
            avEditor.sortBtn.visible = false;
            avEditor.itemCounter.visible = false;
            avEditor.infoBtn.visible = true;
            avEditor.howTxt.visible = true;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(129,0))
            {
               avEditor.tradeHelpPopup.visible = true;
               LocalizationManager.translateId(avEditor.tradeHelpPopup.txt,11217);
               AchievementXtCommManager.requestSetUserVar(129,0);
            }
            createItemWindows(_currTradesArray,avEditor.itemBlock,true);
         }
         else if(_tradeWindow.visible && param1.currentTarget.name == _tradeWindow.clothesBtnDown.name)
         {
            _tradeWindow.denBtnUp.visible = false;
            _tradeWindow.denBtnDown.visible = true;
            _tradeWindow.clothesBtnUp.visible = true;
            _tradeWindow.clothesBtnDown.visible = false;
            LocalizationManager.translateId(_tradeSort.sort8.txt,11205);
            LocalizationManager.translateId(_tradeSort.sort7.txt,11206);
            LocalizationManager.translateId(_tradeSort.sort6.txt,11207);
            LocalizationManager.translateId(_tradeSort.sort5.txt,11208);
            LocalizationManager.translateId(_tradeSort.sort4.txt,11209);
            LocalizationManager.translateId(_tradeSort.sort3.txt,11210);
            LocalizationManager.translateId(_tradeSort.sort2.txt,11211);
            LocalizationManager.translateId(_tradeSort.sort1.txt,11212);
            _tradeSort.sort5.visible = true;
            _tradeSort.sort6.visible = true;
            _tradeSort.sort7.visible = true;
            _tradeSort.sort8.visible = true;
            if(_tradeListViewType == 1 && _tradeDenWindows)
            {
               _tradeDenScrollYPosition = _tradeDenWindows.scrollYValue;
            }
            _tradeListViewType = 0;
            _fullClothesList = convertIntToList(_tradeClothingSortType,true);
            createItemWindows(_fullClothesList,_tradeWindow.itemBlock);
         }
         else if(_tradeWindow.visible && param1.currentTarget.name == _tradeWindow.denBtnDown.name)
         {
            _tradeWindow.denBtnUp.visible = true;
            _tradeWindow.denBtnDown.visible = false;
            _tradeWindow.clothesBtnUp.visible = false;
            _tradeWindow.clothesBtnDown.visible = true;
            LocalizationManager.translateId(_tradeSort.sort4.txt,11215);
            LocalizationManager.translateId(_tradeSort.sort3.txt,11216);
            LocalizationManager.translateId(_tradeSort.sort2.txt,11211);
            LocalizationManager.translateId(_tradeSort.sort1.txt,11212);
            _tradeSort.sort5.visible = false;
            _tradeSort.sort6.visible = false;
            _tradeSort.sort7.visible = false;
            _tradeSort.sort8.visible = false;
            if(_tradeListViewType == 0 && _tradeClothingWindows)
            {
               _tradeClothingScrollYPosition = _tradeClothingWindows.scrollYValue;
            }
            _tradeListViewType = 1;
            _currDenItemsArray = convertIntToList(_tradeDenSortType,false);
            createItemWindows(_currDenItemsArray,_tradeWindow.itemBlock);
         }
      }
      
      private function onCloseTradeWindow(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _tradeWindow.visible = !_tradeWindow.visible;
         avEditor.blackoutFull.visible = !avEditor.blackoutFull.visible;
         if(_tradeListViewType == 0 && _tradeClothingWindows)
         {
            _tradeClothingScrollYPosition = _tradeClothingWindows.scrollYValue;
         }
         else if(_tradeDenWindows)
         {
            _tradeDenScrollYPosition = _tradeDenWindows.scrollYValue;
         }
      }
      
      private function blockMouseBlockerHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseTradeHelpPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.tradeHelpPopup.visible = false;
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(22);
      }
      
      private function onNameBarPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.namebarPopup.visible = false;
      }
      
      private function onColorNameBar(param1:MouseEvent) : void
      {
         var _loc3_:String = null;
         param1.stopPropagation();
         if(!_userInfo.isMember || _worldAvatar.isShaman || _userInfo.isGuide)
         {
            UpsellManager.displayPopup(5,"namebarColor");
            return;
         }
         _nameBarData = (_nameBarData & 0x0FFFFF00) + param1.currentTarget.id;
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
         avEditor.member.setColorBadgeAndXp(_nameBarData,_loc2_.questLevel,_loc2_.isMember);
         avEditor.member.setAvName(_worldAvatar.avName,Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE),gMainFrame.userInfo.getUserInfoByUserName(_worldAvatar.userName),false);
         if(_loc2_.questLevel > 0)
         {
            _loc3_ = avEditor.namebarPopup.advLockToggle.toggleBtn.shape.currentLabels[Utility.getColorId(_nameBarData) - 1].name;
            avEditor.namebarPopup.advLockToggle.toggleBtn.shape.gotoAndStop(_loc3_);
            Utility.createXpShape(_loc2_.questLevel,_loc2_.isMember,avEditor.namebarPopup.advLockToggle.toggleBtn.shape[_loc3_].mouse.up.icon,null,2147483647);
         }
         createNamebarIconWindows();
      }
      
      private function onNameBarPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMemberNameBar(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnClick();
         avEditor.namebarPopup.visible = !avEditor.namebarPopup.visible;
         if(avEditor.namebarPopup.visible)
         {
            if(_namebarBadgeImages.length > 0)
            {
               createNamebarIconWindows();
            }
            else
            {
               GenericListXtCommManager.requestGenericList(110,onNamebarBadgeIdsLoaded);
            }
         }
      }
      
      private function onMemberNameBarOver(param1:MouseEvent) : void
      {
         if(_isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onAdvIconToggle(param1:MouseEvent) : void
      {
         var _loc2_:AvatarInfo = null;
         param1.stopPropagation();
         if(gMainFrame.userInfo.isMember || _worldAvatar.isShaman || _userInfo.isGuide)
         {
            if(param1.currentTarget.currentLabel == "off" || param1.currentTarget.currentLabel == "startingOff")
            {
               param1.currentTarget.gotoAndPlay("on");
               avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = true;
            }
            else
            {
               param1.currentTarget.gotoAndPlay("off");
               avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = false;
            }
            if(_nameBarData != -1)
            {
               _nameBarData = (_nameBarData & 0xF0FFFF) + ((param1.currentTarget.currentLabel == "off" ? 1 : 0) << 16);
            }
            else
            {
               _nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0xF0FFFF) + ((param1.currentTarget.currentLabel == "off" ? 1 : 0) << 16);
            }
            _loc2_ = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
            avEditor.member.setColorBadgeAndXp(_nameBarData,_loc2_.questLevel,_loc2_.isMember);
         }
         else
         {
            UpsellManager.displayPopup(5,"nameBarAdvIcon");
         }
      }
      
      private function onAdvIconToggleOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onAdvIconToggleOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(param1.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            param1.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
      
      private function onNamebarBadgeIdsLoaded(param1:Array) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Object = null;
         _namebarBadgeDefs = [];
         _namebarBadgeMediaIds = [];
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc2_ = GuiManager.getNamebarBadgeDef(param1[_loc3_]);
            if(_loc2_ && (_loc2_.pendingFlagsBit == 0 || Boolean(gMainFrame.userInfo.isPendingFlagSet(_loc2_.pendingFlagsBit))))
            {
               _namebarBadgeDefs.push(_loc2_);
               _namebarBadgeMediaIds.push(_loc2_.mediaRefId);
            }
            _loc3_++;
         }
         createNamebarIconWindows();
      }
      
      private function onNamebarIconsLoaded(param1:MovieClip, param2:MovieClip, param3:int) : void
      {
         if(param1 && param2)
         {
            _namebarBadgeImages[param3] = {
               "iconMouse":param1,
               "iconUp":param2
            };
         }
      }
      
      private function createNamebarIconWindows() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Boolean = false;
         if(_nameBarItemWindows)
         {
            _nameBarItemWindows.destroy();
            _nameBarItemWindows = null;
         }
         while(avEditor.namebarPopup.itemWindow.numChildren > 1)
         {
            avEditor.namebarPopup.itemWindow.removeChildAt(avEditor.namebarPopup.itemWindow.numChildren - 1);
         }
         if(_namebarBadgeImages && _namebarBadgeImages.length > 0 && _namebarBadgeImages[0] != null)
         {
            _loc1_ = _namebarBadgeImages;
         }
         else
         {
            _loc1_ = _namebarBadgeMediaIds;
            _loc2_ = true;
         }
         _nameBarItemWindows = new WindowAndScrollbarGenerator();
         _nameBarItemWindows.init(avEditor.namebarPopup.itemWindow.width,_nameBarItemWinHeight,0,0,5,7,0,4,5,5,ItemWindowNameBarIcon,_loc1_,"",0,{
            "mouseDown":onNamebarBadgeIconDown,
            "mouseOver":onNamebarBadgeIconOver,
            "mouseOut":onNamebarBadgeIconOut
         },{
            "currFrameLabel":avEditor.member["e"].currentLabel,
            "loadIcons":_loc2_,
            "callbackFunction":onNamebarIconsLoaded
         },null,true,false);
         avEditor.namebarPopup.itemWindow.addChild(_nameBarItemWindows);
      }
      
      private function onNamebarBadgeIconOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playSubMenuBtnRollover();
         param1.currentTarget.mouse.gotoAndStop(3);
      }
      
      private function onNamebarBadgeIconOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.mouse.gotoAndStop(1);
      }
      
      private function onNamebarBadgeIconDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!gMainFrame.userInfo.isMember || _worldAvatar.isShaman || _userInfo.isGuide)
         {
            UpsellManager.displayPopup(5,"namebarIcon");
            return;
         }
         var _loc2_:Object = _namebarBadgeDefs[param1.currentTarget.index];
         if(!_loc2_ || !gMainFrame.userInfo.isPendingFlagSet(_loc2_.pendingFlagsBit))
         {
            return;
         }
         var _loc4_:int = _loc2_.defId - 1;
         if(_nameBarData != -1)
         {
            _nameBarData = (_nameBarData & 0x0FFF00FF) + (_loc4_ << 8);
         }
         else
         {
            _nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0x0FFF00FF) + (_loc4_ << 8);
         }
         var _loc3_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(_worldAvatar.userName);
         avEditor.member.setColorBadgeAndXp(_nameBarData,_loc3_.questLevel,_loc3_.isMember);
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onStatsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         avEditor.statsPanel.visible = !avEditor.statsPanel.visible;
         avEditor.currencyBar.visible = !avEditor.currencyBar.visible;
         avEditor.colorTableBlock.visible = !avEditor.colorTableBlock.visible;
         avEditor.colorCont.visible = !avEditor.colorCont.visible;
      }
      
      private function onStatsBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(avEditor.statsBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),LocalizationManager.translateIdOnly(14627),0,-45,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onGemsRollOverOut(param1:MouseEvent) : void
      {
         if(param1.type == "rollOver")
         {
            reloadCurrencyCounts();
            _gemTimeline.play();
         }
         else
         {
            _gemTimeline.reverse();
         }
      }
      
      private function onTrophyDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(_achievementViewer && _achievementViewer.hasBeenInited)
            {
               if(_achievementViewer.visible)
               {
                  _achievementViewer.close();
               }
               else
               {
                  _achievementViewer.open();
               }
            }
            else
            {
               if(_achievementViewer == null)
               {
                  _achievementViewer = new AchievementViewer();
               }
               _achievementViewer.init(avEditor.trophy.x + 15,avEditor.trophy.y + avEditor.trophy.height * 0.5 - 5,avEditor,287);
            }
         }
      }
      
      private function onSearchTextInput(param1:Event) : void
      {
         if(_itemClothingWindows)
         {
            _itemClothingWindows.handleSearchInput(avEditor.searchBar.mouse.searchTxt.text);
         }
      }
      
      private function onSearchBarDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = avEditor.searchBar;
         AJAudio.playHudBtnClick();
         if(param1)
         {
            param1.stopPropagation();
            if(_loc2_.open)
            {
               if(!_loc2_.mouse.b.hitTestPoint(param1.stageX,param1.stageY,true))
               {
                  return;
               }
               _loc2_.open = false;
               _loc2_.mouse.searchTxt.text = "";
               onSearchTextInput(null);
            }
            else
            {
               _loc2_.open = true;
               gMainFrame.stage.focus = _loc2_.mouse.searchTxt;
               avEditor.sortPopup.visible = false;
            }
         }
         else
         {
            _loc2_.open = false;
            _loc2_.mouse.searchTxt.text = "";
            onSearchTextInput(null);
         }
         _loc2_.mouse.b.xBtn.visible = _loc2_.open;
         _loc2_.mouse.txt.visible = !_loc2_.open;
         _loc2_.mouse.txt.visible = !_loc2_.open;
         _loc2_.mouse.searchTxt.visible = _loc2_.open;
         resizeSearchBtn(_loc2_.mouse,_loc2_.open);
      }
      
      private function onSearchBarOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         AJAudio.playHudBtnRollover();
      }
      
      private function onSearchBarOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function resizeSearchBtn(param1:MovieClip, param2:Boolean) : void
      {
         param1.m.width = param2 ? avEditor.searchBar.wideTextWidth : avEditor.searchBar.shortTextWidth;
         param1.b.x = param1.m.x + param1.m.width;
      }
      
      private function convertIntToList(param1:int, param2:Boolean, param3:Boolean = true) : Array
      {
         var _loc4_:Array = null;
         if(param2)
         {
            switch(param1 - 1)
            {
               case 0:
                  if(param3)
                  {
                     _loc4_ = _fullAllOldestClothes;
                  }
                  else
                  {
                     _loc4_ = _allOldestClothes;
                  }
                  break;
               case 1:
                  if(param3)
                  {
                     _loc4_ = _fullallNewestClothes;
                  }
                  else
                  {
                     _loc4_ = _allNewestClothes;
                  }
                  break;
               case 2:
                  if(param3)
                  {
                     _loc4_ = _fullItemTypeItems;
                  }
                  else
                  {
                     _loc4_ = _itemTypeItems;
                  }
                  break;
               case 3:
                  if(param3)
                  {
                     _loc4_ = _fullTailItems;
                  }
                  else
                  {
                     _loc4_ = _tailItems;
                  }
                  break;
               case 4:
                  if(param3)
                  {
                     _loc4_ = _fullLegItems;
                  }
                  else
                  {
                     _loc4_ = _legItems;
                  }
                  break;
               case 5:
                  if(param3)
                  {
                     _loc4_ = _fullBackItems;
                  }
                  else
                  {
                     _loc4_ = _backItems;
                  }
                  break;
               case 6:
                  if(param3)
                  {
                     _loc4_ = _fullNeckItems;
                  }
                  else
                  {
                     _loc4_ = _neckItems;
                  }
                  break;
               case 7:
                  if(param3)
                  {
                     _loc4_ = _fullHeadItems;
                     break;
                  }
                  _loc4_ = _headItems;
            }
         }
         else
         {
            switch(param1 - 1)
            {
               case 0:
                  _loc4_ = _allOldestDenItems;
                  break;
               case 1:
                  _loc4_ = _allNewestDenItems;
                  break;
               case 2:
                  _loc4_ = _itemTypeDenItems;
                  break;
               case 3:
                  _loc4_ = _themeItems;
                  break;
               case 4:
                  _loc4_ = _floorItems;
            }
         }
         return _loc4_;
      }
      
      private function reloadCurrencyCounts() : void
      {
         avEditor.money.mouse.gems.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(0));
         if(avEditor.money.mouse.tickets)
         {
            avEditor.money.mouse.tickets.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(1));
         }
         if(avEditor.money.mouse.diamonds)
         {
            avEditor.money.mouse.diamonds.currencyToolTipCont.currencyTxt.text = Utility.convertNumberToString(UserCurrency.getCurrency(3));
         }
      }
      
      private function addListeners() : void
      {
         var _loc1_:int = 0;
         avEditor.addEventListener("mouseDown",onPopup,false,0,true);
         xBtn.addEventListener("mouseDown",onClose,false,0,true);
         block.addEventListener("mouseDown",blockMouseBlockerHandler,false,0,true);
         block.addEventListener("rollOut",blockMouseBlockerHandler,false,0,true);
         block.addEventListener("rollOver",blockMouseBlockerHandler,false,0,true);
         avEditor.petsBtn.addEventListener("mouseDown",onPetBtnHandler,false,0,true);
         avEditor.petsBtn.addEventListener("mouseOver",onPetBtnOverHandler,false,0,true);
         avEditor.petsBtn.addEventListener("mouseOut",onPetBtnOutHandler,false,0,true);
         avEditor.shopBtn.addEventListener("mouseDown",onShopBtnHandler,false,0,true);
         avEditor.shopBtn.addEventListener("mouseOver",onShopBtnOverHandler,false,0,true);
         avEditor.shopBtn.addEventListener("mouseOut",onShopBtnOutHandler,false,0,true);
         avEditor.sortBtn.addEventListener("mouseDown",sortByHandler,false,0,true);
         _tradeWindow.sortBtn.addEventListener("mouseDown",sortByHandler,false,0,true);
         avEditor.sortPopup.sort8.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort7.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort6.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort5.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort4.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort3.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort2.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.sort1.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.sortPopup.bg.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort8.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort7.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort6.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort5.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort4.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort3.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort2.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         _tradeSort.sort1.addEventListener("mouseDown",sortBtnHandler,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.colorsTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.patternTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseDown",colorTableTabClick,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseOver",colorTableTabOverClick,false,0,true);
         avEditor.eyesTabDnBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         _lArrowBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         _rArrowBtn.addEventListener("mouseDown",arrowBtnHandler,false,0,true);
         avEditor.clothesBtnUp.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         avEditor.clothesBtnDown.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         if(Utility.canTrade())
         {
            avEditor.tradeBtnUp.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
            avEditor.tradeBtnDown.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         }
         else
         {
            avEditor.tradeBtnDown.activateGrayState(true);
         }
         _tradeWindow.denBtnDown.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         _tradeWindow.denBtnUp.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         _tradeWindow.clothesBtnDown.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         _tradeWindow.clothesBtnUp.addEventListener("mouseDown",clothesDenAndTradeHandler,false,0,true);
         _tradeWindow["bx"].addEventListener("mouseDown",onCloseTradeWindow,false,0,true);
         avEditor.tradeHelpPopup.bx.addEventListener("mouseDown",onCloseTradeHelpPopup,false,0,true);
         avEditor.infoBtn.addEventListener("mouseDown",onInfoBtnDown,false,0,true);
         avEditor.namebarPopup.addEventListener("mouseDown",onNameBarPopup,false,0,true);
         avEditor.namebarPopup["bx"].addEventListener("mouseDown",onNameBarPopupClose,false,0,true);
         _loc1_ = 0;
         while(_loc1_ < _nameBars.length)
         {
            avEditor.namebarPopup[_nameBars[_loc1_]].addEventListener("mouseDown",onColorNameBar,false,0,true);
            _loc1_++;
         }
         avEditor.member.addEventListener("mouseDown",onMemberNameBar,false,0,true);
         avEditor.member.addEventListener("mouseOver",onMemberNameBarOver,false,0,true);
         avEditor.nonmember.addEventListener("mouseDown",onMemberNameBar,false,0,true);
         avEditor.nonmember.addEventListener("mouseOver",onMemberNameBarOver,false,0,true);
         avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener("mouseDown",onAdvIconToggle,false,0,true);
         avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener("mouseOver",onAdvIconToggleOver,false,0,true);
         avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener("mouseOut",onAdvIconToggleOut,false,0,true);
         avEditor.recycleClothesBtn.addEventListener("mouseDown",onRecycleClothesBtn,false,0,true);
         avEditor.recycleClothesBtn.addEventListener("mouseOver",onRecycleClothesBtnOver,false,0,true);
         avEditor.recycleClothesBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         if(_isInQuest)
         {
            avEditor.statsBtn.addEventListener("mouseDown",onStatsBtn,false,0,true);
            avEditor.statsBtn.addEventListener("mouseOver",onStatsBtnOver,false,0,true);
            avEditor.statsBtn.addEventListener("mouseOut",btnOutHandler,false,0,true);
         }
         avEditor.money.addEventListener("rollOver",onGemsRollOverOut,false,0,true);
         avEditor.money.addEventListener("rollOut",onGemsRollOverOut,false,0,true);
         avEditor.trophy.addEventListener("mouseDown",onTrophyDown,false,0,true);
         avEditor.searchBar.addEventListener("change",onSearchTextInput,false,0,true);
         avEditor.searchBar.addEventListener("mouseDown",onSearchBarDown,false,0,true);
         avEditor.searchBar.addEventListener("mouseOver",onSearchBarOver,false,0,true);
         avEditor.searchBar.addEventListener("mouseOut",onSearchBarOut,false,0,true);
      }
      
      private function removeListeners() : void
      {
         var _loc1_:int = 0;
         avEditor.removeEventListener("mouseDown",onPopup);
         xBtn.removeEventListener("mouseDown",onClose);
         block.removeEventListener("mouseDown",blockMouseBlockerHandler);
         block.removeEventListener("rollOut",blockMouseBlockerHandler);
         block.removeEventListener("rollOver",blockMouseBlockerHandler);
         avEditor.petsBtn.removeEventListener("mouseDown",onPetBtnHandler);
         avEditor.petsBtn.removeEventListener("mouseOver",onPetBtnOverHandler);
         avEditor.petsBtn.removeEventListener("mouseOut",onPetBtnOutHandler);
         avEditor.shopBtn.removeEventListener("mouseDown",onShopBtnHandler);
         avEditor.shopBtn.removeEventListener("mouseOver",onShopBtnOverHandler);
         avEditor.shopBtn.removeEventListener("mouseOut",onShopBtnOutHandler);
         avEditor.sortBtn.removeEventListener("mouseDown",sortByHandler);
         _tradeWindow.sortBtn.removeEventListener("mouseDown",sortByHandler);
         avEditor.sortPopup.sort8.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort7.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort6.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort5.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort4.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort3.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort2.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.sort1.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.sortPopup.bg.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort8.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort7.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort6.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort5.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort4.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort3.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort2.removeEventListener("mouseDown",sortBtnHandler);
         _tradeSort.sort1.removeEventListener("mouseDown",sortBtnHandler);
         avEditor.colorsTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.colorsTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.colorsTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.patternTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         avEditor.eyesTabDnBtn.removeEventListener("mouseDown",colorTableTabClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOver",colorTableTabOverClick);
         avEditor.eyesTabDnBtn.removeEventListener("mouseOut",btnOutHandler);
         _lArrowBtn.removeEventListener("mouseDown",arrowBtnHandler);
         _rArrowBtn.removeEventListener("mouseDown",arrowBtnHandler);
         avEditor.clothesBtnUp.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         avEditor.clothesBtnDown.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         if(Utility.canTrade())
         {
            avEditor.tradeBtnUp.removeEventListener("mouseDown",clothesDenAndTradeHandler);
            avEditor.tradeBtnDown.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         }
         _tradeWindow.denBtnDown.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         _tradeWindow.denBtnUp.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         _tradeWindow.clothesBtnDown.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         _tradeWindow.clothesBtnUp.removeEventListener("mouseDown",clothesDenAndTradeHandler);
         _tradeWindow["bx"].removeEventListener("mouseDown",onCloseTradeWindow);
         avEditor.tradeHelpPopup.bx.removeEventListener("mouseDown",onCloseTradeHelpPopup);
         avEditor.infoBtn.removeEventListener("mouseDown",onInfoBtnDown);
         avEditor.namebarPopup.removeEventListener("mouseDown",onNameBarPopup);
         avEditor.namebarPopup["bx"].removeEventListener("mouseDown",onNameBarPopupClose);
         if(_nameBars)
         {
            _loc1_ = 0;
            while(_loc1_ < _nameBars.length)
            {
               avEditor.namebarPopup[_nameBars[_loc1_]].removeEventListener("mouseDown",onColorNameBar);
               _loc1_++;
            }
         }
         avEditor.member.removeEventListener("mouseDown",onMemberNameBar);
         avEditor.nonmember.removeEventListener("mouseDown",onMemberNameBar);
         avEditor.member.removeEventListener("mouseOver",onMemberNameBarOver);
         avEditor.nonmember.removeEventListener("mouseOver",onMemberNameBarOver);
         avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener("mouseDown",onAdvIconToggle);
         avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener("mouseOver",onAdvIconToggleOver);
         avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener("mouseOut",onAdvIconToggleOut);
         avEditor.recycleClothesBtn.removeEventListener("mouseDown",onRecycleClothesBtn);
         avEditor.recycleClothesBtn.removeEventListener("mouseOver",onRecycleClothesBtnOver);
         avEditor.recycleClothesBtn.removeEventListener("mouseOut",btnOutHandler);
         if(_isInQuest)
         {
            avEditor.statsBtn.removeEventListener("mouseDown",onStatsBtn);
            avEditor.statsBtn.removeEventListener("mouseOver",onStatsBtnOver);
            avEditor.statsBtn.removeEventListener("mouseOut",btnOutHandler);
         }
         avEditor.money.removeEventListener("rollOver",onGemsRollOverOut);
         avEditor.money.removeEventListener("rollOut",onGemsRollOverOut);
         avEditor.trophy.removeEventListener("mouseDown",onTrophyDown);
         avEditor.searchBar.removeEventListener("change",onSearchTextInput);
         avEditor.searchBar.removeEventListener("mouseDown",onSearchBarDown);
         avEditor.searchBar.removeEventListener("mouseOver",onSearchBarOver);
         avEditor.searchBar.removeEventListener("mouseOut",onSearchBarOut);
      }
   }
}

