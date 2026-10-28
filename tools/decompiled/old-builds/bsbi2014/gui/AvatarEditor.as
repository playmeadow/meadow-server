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
   import com.sbi.client.KeepAlive;
   import com.sbi.debug.DebugUtility;
   import com.sbi.graphics.LayerAnim;
   import com.sbi.graphics.PaletteHelper;
   import com.sbi.popup.*;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.DefPacksDefHelper;
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
      
      private const SCROLLBAR_GAP:int = 5;
      
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
      
      private var _cellWidth:Number;
      
      private var _cellHeight:Number;
      
      private var _numXColors:int;
      
      private var _numYColors:int;
      
      private var _tabOpenId:int;
      
      private var _mainScrollbar:SBScrollbar;
      
      private var _itemClothingWindows:WindowGenerator;
      
      private var _itemTradeWindows:WindowGenerator;
      
      private var _tradeClothingWindows:WindowGenerator;
      
      private var _tradeDenWindows:WindowGenerator;
      
      private var _numItemsInCurrentArray:int;
      
      public var numClothingItemsInTradeListInitially:int;
      
      public var numDenItemsInTradeListInitially:int;
      
      private var _nameBars:Array;
      
      private var _nameBarData:int;
      
      private var _userInfo:UserInfo;
      
      private var _nameBarScrollBar:SBScrollbar;
      
      private var _nameBarItemWindows:WindowGenerator;
      
      private var _nameBarItemWinHeight:int;
      
      private var _namebarBadgeDefs:Array;
      
      private var _namebarBadgeMediaIds:Array;
      
      private var _namebarBadgeImages:Array;
      
      private var _shop:Shop;
      
      private var _spirals:Array;
      
      private var _petInventory:PetInventory;
      
      private var _myPet:GuiPet;
      
      private var _loadingMediaHelper:MediaHelper;
      
      public function AvatarEditor()
      {
         super();
      }
      
      public function init(worldAvatar:Avatar, guiLayer:DisplayLayer, initMakePopup:Boolean = true, initCloseCallback:Function = null, initIsFFM:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._worldAvatar = worldAvatar;
         this._makePopup = initMakePopup;
         this._onCloseCallback = initCloseCallback;
         this._guiLayer = guiLayer;
         this._isFFM = initIsFFM;
         this._isInQuest = gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST;
         this._avatarEditorView = new AvatarEditorView();
         this._avatarEditorView.init(this._worldAvatar);
         this._gamePalette = PaletteHelper.gamePalette;
         this._avatarPalette1 = PaletteHelper.avatarPalette1;
         this._avatarPalette2 = PaletteHelper.avatarPalette2;
         this._patterns = [];
         this._eyes = [];
         this.createPatternsAndEyesArrays();
         this._tabOpenId = 0;
         this._spirals = [];
         this._currClothesArray = this._allNewestClothes = this._avatarEditorView.inventoryClothingItems;
         this._headItems = Utility.sortItemsAll(this._currClothesArray,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
         this._neckItems = Utility.sortItemsAll(this._currClothesArray,0,Item.NECK_LAYER);
         this._backItems = Utility.sortItemsAll(this._currClothesArray,0,Item.BACK_LAYER);
         this._legItems = Utility.sortItemsAll(this._currClothesArray,0,Item.LEG_LAYER);
         this._tailItems = Utility.sortItemsAll(this._currClothesArray,0,Item.TAIL_LAYER);
         this._itemTypeItems = Utility.sortByItem(this._currClothesArray,0);
         this._allOldestClothes = this._allNewestClothes.concat().reverse();
         if(Boolean(this._currClothesArray))
         {
            this._currClothesArray = this.convertIntToList(_mainClothingSortType,true,false);
         }
         this._fullClothesList = this._fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
         if(Boolean(this._fullClothesList))
         {
            this._fullHeadItems = Utility.sortItemsAll(this._fullClothesList,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
            this._fullNeckItems = Utility.sortItemsAll(this._fullClothesList,0,Item.NECK_LAYER);
            this._fullBackItems = Utility.sortItemsAll(this._fullClothesList,0,Item.BACK_LAYER);
            this._fullLegItems = Utility.sortItemsAll(this._fullClothesList,0,Item.LEG_LAYER);
            this._fullTailItems = Utility.sortItemsAll(this._fullClothesList,0,Item.TAIL_LAYER);
            this._fullItemTypeItems = Utility.sortByItem(this._fullClothesList,0);
            this._fullAllOldestClothes = this._fullallNewestClothes.concat().reverse();
         }
         if(Boolean(worldAvatar.inventoryDenFull.itemArray))
         {
            this._currDenItemsArray = this._allNewestDenItems = this.discardAudioItems(worldAvatar.inventoryDenFull.itemArray);
            this._floorItems = Utility.sortItems(this._currDenItemsArray,0,DenItem.SORT_FLOOR,DenItem.SORT_WALL);
            this._themeItems = Utility.sortItems(this._currDenItemsArray,0,DenItem.SORT_FLOORING,DenItem.SORT_WALLPAPER);
            this._itemTypeDenItems = Utility.sortByItem(this._currDenItemsArray,0);
            this._allOldestDenItems = this._allNewestDenItems.concat().reverse();
         }
         this._currTradesArray = gMainFrame.userInfo.getMyTradeList().slice();
         this.numClothingItemsInTradeListInitially = TradeManager.numClothingItemsInMyTradeList;
         this.numDenItemsInTradeListInitially = TradeManager.numDenItemsInMyTradeList;
         this._loadingMediaHelper = new MediaHelper();
         this._loadingMediaHelper.init(this.AVEDITOR_MEDIA_ID,this.onMediaItemLoaded,true);
      }
      
      public function destroy() : void
      {
         var spiral:LoadingSpiral = null;
         DarkenManager.showLoadingSpiral(false);
         KeepAlive.stopKATimer(this.avEditor);
         this.removeListeners();
         if(Boolean(this._mainScrollbar))
         {
            if(this._mainScrollbar.getScrollContentParent == this.avEditor.itemBlock)
            {
               _mainScrollYPosition = this._mainScrollbar.scrollYValue;
            }
            else if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
            {
               _tradeClothingScrollYPosition = this._mainScrollbar.scrollYValue;
            }
            else
            {
               _tradeDenScrollYPosition = this._mainScrollbar.scrollYValue;
            }
            this._mainScrollbar.destroy();
         }
         this._mainScrollbar = null;
         if(Boolean(this._itemClothingWindows))
         {
            this._itemClothingWindows.destroy();
            this._itemClothingWindows = null;
         }
         if(Boolean(this._itemTradeWindows))
         {
            this._itemTradeWindows.destroy();
            this._itemTradeWindows = null;
         }
         if(Boolean(this._tradeClothingWindows))
         {
            this._tradeClothingWindows.destroy();
            this._tradeClothingWindows = null;
         }
         if(Boolean(this._tradeDenWindows))
         {
            this._tradeDenWindows.destroy();
            this._tradeDenWindows = null;
         }
         if(Boolean(this._avatarEditorView))
         {
            this.avEditor.charBox.removeChild(this._avatarEditorView);
            this._avatarEditorView.destroy();
            this._avatarEditorView = null;
            this._itemsOn = null;
            this._itemsOff = null;
            this._tradeItemsIn = null;
            this._tradeItemsOut = null;
            this._patterns = null;
            this._eyes = null;
            this._avatarPalette1 = null;
            this._avatarPalette2 = null;
         }
         if(Boolean(this._myPet))
         {
            this._myPet.destroy();
            this._myPet = null;
         }
         this._colorTableColor1.destroy();
         this._colorTableColor2.destroy();
         this._colorTablePatterns.destroy();
         this._colorTableEyes.destroy();
         this._namebarBadgeMediaIds = null;
         this._nameBars = null;
         this._userInfo = null;
         this._namebarBadgeImages = null;
         if(Boolean(this._nameBarScrollBar))
         {
            this._nameBarScrollBar.destroy();
         }
         if(Boolean(this._nameBarItemWindows))
         {
            this._nameBarItemWindows.destroy();
            this._nameBarItemWindows = null;
         }
         this._currClothesArray = null;
         this._headItems = null;
         this._neckItems = null;
         this._backItems = null;
         this._legItems = null;
         this._tailItems = null;
         this._itemTypeItems = null;
         this._allOldestClothes = null;
         this._fullHeadItems = null;
         this._fullNeckItems = null;
         this._fullBackItems = null;
         this._fullLegItems = null;
         this._fullTailItems = null;
         this._fullItemTypeItems = null;
         this._fullAllOldestClothes = null;
         this._currDenItemsArray = null;
         this._floorItems = null;
         this._themeItems = null;
         this._itemTypeDenItems = null;
         this._allOldestDenItems = null;
         this._currTradesArray = null;
         this._onCloseCallback = null;
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            for each(spiral in this._spirals)
            {
               spiral.destroy();
            }
         }
         this._spirals = null;
         DarkenManager.unDarken(this.avEditor);
         this._guiLayer.removeChild(this.avEditor);
      }
      
      public function get onCloseCallback() : Function
      {
         return this._onCloseCallback;
      }
      
      public function set onCloseCallback(callback:Function) : void
      {
         this._onCloseCallback = callback;
      }
      
      private function onMediaItemLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            this.avEditor = MovieClip(img.getChildAt(0));
            this.xBtn = this.avEditor.bx;
            this.block = this.avEditor.block;
            this.block.visible = this._isFFM;
            this._tradeSort = this.avEditor.tradeWindow.sortPopup;
            this._tradeWindow = this.avEditor.tradeWindow;
            this.avEditor.x = MainFrame.VIEW_WIDTH * 0.5;
            this.avEditor.y = MainFrame.VIEW_HEIGHT * 0.5;
            this.avEditor.nonmember.text = this._worldAvatar.avName;
            this._userInfo = gMainFrame.userInfo.getUserInfoByUserName(this._worldAvatar.userName);
            this._itemsOn = [];
            this._itemsOff = [];
            this._tradeItemsIn = [];
            this._tradeItemsOut = [];
            this._namebarBadgeImages = [];
            this._nameBars = new Array("goldBtn","blackBtn","blueBtn","brownBtn","greenBtn","pinkBtn","purpleBtn","redBtn","tealBtn","whiteBtn");
            this._nameBarData = gMainFrame.userInfo.playerUserInfo.nameBarData;
            this._nameBarItemWinHeight = this.avEditor.namebarPopup.itemWindow.height;
            this.setInitAssetVisibility();
            this.positionAndDrawAvatarView();
            this._waitForApResponse = false;
            this._waitForIuResponse = false;
            if(Boolean(this._currClothesArray))
            {
               this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
            }
            this.addListeners();
            KeepAlive.startKATimer(this.avEditor);
            this._loadingMediaHelper.destroy();
            this._loadingMediaHelper = null;
            DarkenManager.showLoadingSpiral(false);
            this._guiLayer.addChild(this.avEditor);
            DarkenManager.darken(this.avEditor);
            QuestManager.avatarEditorInitComplete();
         }
      }
      
      private function setInitAssetVisibility() : void
      {
         var ai:AvatarInfo = null;
         var isShowingLevel:Boolean = false;
         var currFrameName:String = null;
         this.avEditor.colorTableBlock.patternsAndEyes.visible = false;
         var avColors:Array = this._avatarEditorView.colors;
         var baseColor1:int = avColors[0] >> 24 & 0xFF;
         var baseColor2:int = avColors[0] >> 16 & 0xFF;
         var pattColor:int = avColors[1] >> 24 & 0xFF;
         var eyeColor:int = avColors[2] >> 24 & 0xFF;
         this._colorTableColor1 = new ColorTable();
         this._colorTableColor1.init(this.CT_ID_C1,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette1,baseColor1,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTableColor2 = new ColorTable();
         this._colorTableColor2.init(this.CT_ID_C2,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette2,baseColor2,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTablePatterns = new ColorTable();
         this._colorTablePatterns.init(this.CT_ID_PATT,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette1,pattColor,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTableEyes = new ColorTable();
         this._colorTableEyes.init(this.CT_ID_EYES,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette1,eyeColor,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTableColor1.x = this.CT_X;
         this._colorTableColor1.y = this.CT_Y_TOP;
         this._colorTableColor2.x = this.CT_X;
         this._colorTableColor2.y = this.CT_Y_BOT;
         this._colorTablePatterns.x = this.CT_X;
         this._colorTablePatterns.y = this.CT_Y_BOT;
         this._colorTableEyes.x = this.CT_X;
         this._colorTableEyes.y = this.CT_Y_BOT;
         this.avEditor.colorTableBlock.patternsAndEyes.visible = false;
         this.avEditor.colorTableBlock.colors.addChild(this._colorTableColor1);
         this.avEditor.colorTableBlock.colors.addChild(this._colorTableColor2);
         this._eyePattWindow = this.avEditor.colorTableBlock.patternsAndEyes.previewWin;
         this._lArrowBtn = this.avEditor.colorTableBlock.patternsAndEyes.arrowBtnL;
         this._rArrowBtn = this.avEditor.colorTableBlock.patternsAndEyes.arrowBtnR;
         LocalizationManager.translateId(this.avEditor.sortPopup.sort8.txt,11205);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort7.txt,11206);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort6.txt,11207);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort5.txt,11208);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort4.txt,11209);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort3.txt,11210);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort2.txt,11211);
         LocalizationManager.translateId(this.avEditor.sortPopup.sort1.txt,11212);
         this.avEditor.clothesBtnUp.visible = true;
         this.avEditor.clothesBtnDown.visible = false;
         this.avEditor.tradeBtnUp.visible = false;
         this.avEditor.tradeBtnDown.visible = Boolean(this._fullClothesList) ? true : false;
         this._tradeWindow.visible = false;
         this.avEditor.blackout.visible = false;
         this.avEditor.blackoutFull.visible = false;
         this.avEditor.patternTabUp.visible = false;
         this.avEditor.eyesTabUp.visible = false;
         this.avEditor.sortPopup.visible = false;
         this.avEditor.tradeHelpPopup.visible = false;
         this.avEditor.infoBtn.visible = false;
         this.avEditor.howTxt.visible = false;
         this.avEditor.currencyBar.visible = false;
         this.avEditor.statsPanel.visible = false;
         this.avEditor.block.visible = false;
         this._tradeWindow.petsBtnDown.visible = false;
         this._tradeWindow.petsBtnUp.visible = false;
         if(this._allNewestClothes.length <= 0)
         {
            this.avEditor.sortBtn.visible = false;
         }
         if(gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST)
         {
            this.avEditor.petsBtn.activateGrayState(true);
         }
         else
         {
            this.loadPetView();
         }
         this.avEditor.namebarPopup.visible = false;
         for(var i:int = 0; i < this._nameBars.length; i++)
         {
            this.avEditor.namebarPopup[this._nameBars[i]].txt.text = this._worldAvatar.avName;
            this.avEditor.namebarPopup[this._nameBars[i]].id = i;
         }
         if(!gMainFrame.userInfo.isMember)
         {
            this.avEditor.nonmember.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            this.avEditor.nonmember.nubData = AvatarManager.playerAvatarWorldView.nubData;
            this.avEditor.nonmember.visible = true;
            this.avEditor.member.visible = false;
            this.avEditor.nonmember.txt.text = this._worldAvatar.avName;
         }
         else
         {
            this.avEditor.member.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            this.avEditor.member.nubData = AvatarManager.playerAvatarWorldView.nubData;
            this.avEditor.member.xpShapeIcons = AvatarManager.playerAvatarWorldView.xpShapeIcons;
            this.avEditor.nonmember.visible = false;
            this.avEditor.member.visible = true;
            this.avEditor.member.setNubType(NameBar.BUDDY,false);
            this.avEditor.member.isBlocked = false;
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(this._worldAvatar.userName);
            if(!this._worldAvatar.isShaman && !this._userInfo.isGuide)
            {
               this.avEditor.member.setColorBadgeAndXp(this._nameBarData,ai.questLevel,ai.isMember);
            }
            else
            {
               this.avEditor.member.setColorBadgeAndXp(0,0,false);
            }
            this.avEditor.member.setAvName(this._worldAvatar.avName,false);
            isShowingLevel = (this._nameBarData >> 16 & 0xFF) == 0 && ai.isMember || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST || gMainFrame.clientInfo.roomType == Utility.ROOMTYPE_QUEST_STAGING;
            if(isShowingLevel)
            {
               this.avEditor.namebarPopup.advLockToggle.toggleBtn.gotoAndStop("startingOn");
            }
            else
            {
               this.avEditor.namebarPopup.advLockToggle.toggleBtn.gotoAndStop("startingOff");
               this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = false;
            }
            if(ai.questLevel > 0)
            {
               currFrameName = this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.currentLabels[Utility.getColorId(this._nameBarData) - 1].name;
               this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.gotoAndStop(currFrameName);
               Utility.createXpShape(ai.questLevel,ai.isMember,this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape[currFrameName].mouse.up.icon,null,int.MAX_VALUE);
            }
         }
         if(this._isFFM)
         {
            if(Boolean(this.avEditor.petsBtn.hasGrayState))
            {
               this.avEditor.petsBtn.activateGrayState(true);
            }
            if(Boolean(this.avEditor.shopBtn.hasGrayState))
            {
               this.avEditor.shopBtn.activateGrayState(true);
            }
            if(Boolean(this.avEditor.recycleClothesBtn.hasGrayState))
            {
               this.avEditor.recycleClothesBtn.activateGrayState(true);
            }
            if(Boolean(this.avEditor.sortBtn.hasGrayState))
            {
               this.avEditor.sortBtn.activateGrayState(true);
            }
            if(Boolean(this.avEditor.tradeBtnDown.hasGrayState))
            {
               this.avEditor.tradeBtnDown.activateGrayState(true);
            }
            this.avEditor.block.visible = true;
         }
         this.avEditor.statsBtn.visible = false;
         this.avEditor.itemCounter.counterTxt.text = this._allNewestClothes.length + "/" + Shop.maxItems;
      }
      
      private function positionAndDrawAvatarView(reInitView:Boolean = false) : void
      {
         if(reInitView)
         {
            if(Boolean(this._avatarEditorView) && Boolean(this._avatarEditorView.parent))
            {
               this.avEditor.charBox.removeChild(this._avatarEditorView);
            }
            this._avatarEditorView = new AvatarEditorView();
            this._avatarEditorView.init(this._worldAvatar);
         }
         var offset:Point = AvatarUtility.getAvatarViewPosition(this._avatarEditorView.avTypeId);
         this._avatarEditorView.x = offset.x;
         this._avatarEditorView.y = offset.y;
         if(Utility.isOcean(this._worldAvatar.enviroTypeFlag))
         {
            if(Utility.isLand(this._worldAvatar.enviroTypeFlag))
            {
               this.avEditor.charBox.gotoAndStop(3);
            }
            else
            {
               this.avEditor.charBox.gotoAndStop(2);
            }
         }
         this.avEditor.charBox.addChild(this._avatarEditorView);
         this._avatarEditorView.playAnim(LayerAnim.AN_BBCARD);
      }
      
      private function colorCurrEyePattIcon() : void
      {
         if(this._tabOpenId == PATTERN_TAB_ID)
         {
            if(Boolean(this._patterns) && Boolean(this._patterns.length > 0) && Boolean(this._patterns[this._currPattern]))
            {
               if(this._patterns[this._currPattern].icon.numChildren > 0)
               {
                  this._patterns[this._currPattern].icon.getChildAt(0).setLayerColor(2,this._avatarEditorView.colors[1]);
                  this._patterns[this._currPattern].icon.getChildAt(0).paint(0);
               }
            }
         }
         else if(this._tabOpenId == EYE_TAB_ID)
         {
            if(Boolean(this._eyes) && Boolean(this._eyes.length > 0) && Boolean(this._eyes[this._currEye]))
            {
               if(this._eyes[this._currEye].icon.numChildren > 0)
               {
                  this._eyes[this._currEye].icon.getChildAt(0).setLayerColor(3,this._avatarEditorView.colors[2]);
                  this._eyes[this._currEye].icon.getChildAt(0).paint(0);
               }
            }
         }
      }
      
      private function onColorChanged(tableId:int, newColorIndex:int) : void
      {
         var avColors0:uint = 0;
         var avColors1:uint = 0;
         var avColors2:uint = 0;
         var base1:int = 0;
         var base2:int = 0;
         var base3:int = 0;
         var base4:int = 0;
         var pattern1:int = 0;
         var pattern2:int = 0;
         var pattern3:int = 0;
         var pattern4:int = 0;
         var eye1:int = 0;
         var eye2:int = 0;
         var eye3:int = 0;
         var eye4:int = 0;
         var avColors:Array = this._avatarEditorView.colors;
         avColors0 = uint(avColors[0]);
         avColors1 = uint(avColors[1]);
         avColors2 = uint(avColors[2]);
         switch(tableId)
         {
            case this.CT_ID_C1:
            case this.CT_ID_C2:
               base3 = avColors0 >> 8 & 0xFF;
               base4 = avColors0 & 0xFF;
               if(tableId == this.CT_ID_C1)
               {
                  base1 = newColorIndex;
                  base2 = avColors0 >> 16 & 0xFF;
               }
               else
               {
                  base1 = avColors0 >> 24 & 0xFF;
                  base2 = newColorIndex;
               }
               avColors0 = uint(base1 << 24 | base2 << 16 | base3 << 8 | base4);
               break;
            case this.CT_ID_PATT:
               pattern1 = newColorIndex;
               pattern2 = avColors1 >> 16 & 0xFF;
               pattern3 = avColors1 >> 8 & 0xFF;
               pattern4 = avColors1 & 0xFF;
               avColors1 = uint(pattern1 << 24 | pattern2 << 16 | pattern3 << 8 | pattern4);
               break;
            case this.CT_ID_EYES:
               eye1 = newColorIndex;
               eye2 = avColors2 >> 16 & 0xFF;
               eye3 = avColors2 >> 8 & 0xFF;
               eye4 = avColors2 & 0xFF;
               avColors2 = uint(eye1 << 24 | eye2 << 16 | eye3 << 8 | eye4);
         }
         this._avatarEditorView.colors = [avColors0,avColors1,avColors2];
         if(tableId == this.CT_ID_EYES || tableId == this.CT_ID_PATT)
         {
            this.colorCurrEyePattIcon();
         }
      }
      
      private function loadPetView() : void
      {
         var myPetList:Array = null;
         var i:int = 0;
         var myPet:Object = null;
         if(gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
         {
            myPetList = PetManager.myPetList;
            while(this.avEditor.itemWindowPet2.numChildren > 0)
            {
               this.avEditor.itemWindowPet2.removeChildAt(0);
            }
            while(this.avEditor.itemWindowPet1.numChildren > 0)
            {
               this.avEditor.itemWindowPet1.removeChildAt(0);
            }
            for(i = 0; i < myPetList.length; i++)
            {
               if(myPetList[i].idx == PetManager.myActivePetInvId)
               {
                  myPet = myPetList[i];
                  if(!PetManager.canCurrAvatarUsePet(AvatarManager.playerAvatar.enviroTypeFlag,myPet.type))
                  {
                     break;
                  }
                  this._myPet = new GuiPet(myPet.idx,myPet.lBits,myPet.uBits,myPet.eBits,myPet.type,myPet.name,this.onPetLoaded);
                  if(this._myPet.isGround())
                  {
                     this.avEditor.itemWindowPet2.addChild(this._myPet);
                  }
                  else
                  {
                     this.avEditor.itemWindowPet1.addChild(this._myPet);
                  }
                  break;
               }
            }
         }
      }
      
      private function onPetLoaded(content:MovieClip, pet:GuiPet) : void
      {
         this._myPet.scaleX = this._myPet.scaleY = 2;
         var matrix:Matrix = this._myPet.transform.matrix;
         matrix.scale(-1,1);
         this._myPet.transform.matrix = matrix;
      }
      
      private function discardAudioItems(items:Array) : Array
      {
         var tempArray:Array = [];
         for(var i:int = 0; i < items.length; i++)
         {
            if(items[i].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
            {
               tempArray.push(items[i]);
            }
         }
         return tempArray;
      }
      
      private function sendChangesRequest() : void
      {
         var sendRequest:Boolean = false;
         this.wereItemsOnOriginally(this._itemsOn,this._itemsOff);
         if(this._itemsOn.length > 0 || this._itemsOff.length > 0)
         {
            ItemXtCommManager.requestItemUse(this.itemUseResponse,this._itemsOn.concat(),this._itemsOff.concat());
            this._waitForIuResponse = true;
            sendRequest = true;
         }
         else if(Boolean(this._recycle))
         {
            DarkenManager.showLoadingSpiral(false);
            this._recycle.init(RecycleItems.RECYCLE_ACCESSORIES,this._guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
         if(gMainFrame.userInfo.playerUserInfo.nameBarData != this._nameBarData)
         {
            AvatarXtCommManager.requestColorChange(this._avatarEditorView.colors,this._nameBarData,this.avatarPaintResponse);
            this._waitForApResponse = true;
            sendRequest = true;
         }
         else if(this._worldAvatar.colors[0] != this._avatarEditorView.colors[0] || this._worldAvatar.colors[1] != this._avatarEditorView.colors[1] || this._worldAvatar.colors[2] != this._avatarEditorView.colors[2])
         {
            AvatarXtCommManager.requestColorChange(this._avatarEditorView.colors,gMainFrame.userInfo.playerUserInfo.nameBarData,this.avatarPaintResponse);
            this._waitForApResponse = true;
            sendRequest = true;
         }
         if(this._tradeItemsIn.length > 0 || this._tradeItemsOut.length > 0)
         {
            if(this._waitForIuResponse)
            {
               this._sendDelayedTradeRequest = true;
            }
            else
            {
               TradeManager.changeTradeList(this._tradeItemsIn,this._tradeItemsOut);
               this._tradeItemsIn.length = 0;
               this._tradeItemsOut.length = 0;
            }
         }
         if(!this._waitForIuResponse && !this._waitForApResponse)
         {
            if(this._onCloseCallback != null && this._shop == null && this._recycle == null)
            {
               this._onCloseCallback();
            }
         }
         if(sendRequest)
         {
            DarkenManager.showLoadingSpiral(true);
         }
         else
         {
            this._worldAvatar.dispatchEvent(new AvatarEvent(AvatarEvent.AVATAR_CHANGED));
         }
      }
      
      private function itemUseResponse(itemsOn:Array, itemsOff:Array, status:Boolean) : void
      {
         var i:int = 0;
         var j:int = 0;
         if(status)
         {
            DebugUtility.debugTrace("AvatarEditor: Changes made to avatar were successful");
            for(i = 0; i < itemsOn.length; i++)
            {
               DebugUtility.debugTrace("Item #" + itemsOn[i] + ": PUT ON");
            }
            for(j = 0; j < itemsOff.length; j++)
            {
               DebugUtility.debugTrace("Item #" + itemsOff[j] + ": TAKEN OFF");
            }
         }
         this.applyChanges(status);
      }
      
      private function avatarPaintResponse(changesApplied:Boolean) : void
      {
         var setCacheInfo:AvatarInfo = null;
         var avColors:Array = null;
         if(changesApplied)
         {
            setCacheInfo = gMainFrame.userInfo.playerAvatarInfo;
            avColors = this._avatarEditorView.colors;
            if(Boolean(setCacheInfo))
            {
               setCacheInfo.colors = avColors;
            }
            gMainFrame.userInfo.playerUserInfo.nameBarData = this._nameBarData;
            this._worldAvatar.setColors(avColors[0],avColors[1],avColors[2]);
         }
         this._waitForApResponse = false;
         if(!this._waitForIuResponse && !this._waitForApResponse)
         {
            if(this._onCloseCallback != null && this._shop == null && this._recycle == null)
            {
               this._onCloseCallback();
            }
         }
         DarkenManager.showLoadingSpiral(false);
      }
      
      private function applyChanges(changesApplied:Boolean) : void
      {
         var viewAvatar:Avatar = null;
         if(!changesApplied)
         {
            DarkenManager.showLoadingSpiral(false);
            DebugUtility.debugTrace("WARNING: Changes were not made to your avatar");
         }
         else
         {
            viewAvatar = this._avatarEditorView.viewAvatar;
            AvatarManager.playerAvatar.rangedAttack = viewAvatar.rangedAttack;
            AvatarManager.playerAvatar.meleeAttack = viewAvatar.meleeAttack;
            AvatarManager.playerAvatar.defense = viewAvatar.defense;
            AvatarManager.playerAvatar.fierceAttack = viewAvatar.fierceAttack;
            AvatarManager.playerAvatar.healingPower = viewAvatar.healingPower;
         }
         this._itemsOn.length = 0;
         this._itemsOff.length = 0;
         this._waitForIuResponse = false;
         if(this._sendDelayedTradeRequest)
         {
            TradeManager.changeTradeList(this._tradeItemsIn,this._tradeItemsOut);
            this._tradeItemsIn.length = 0;
            this._tradeItemsOut.length = 0;
         }
         if(!this._waitForIuResponse && !this._waitForApResponse)
         {
            if(this._onCloseCallback != null && this._shop == null && this._recycle == null)
            {
               this._onCloseCallback();
            }
         }
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(this.xBtn != null && !this.xBtn.isGray)
         {
            this.sendChangesRequest();
         }
      }
      
      private function colorTableTabClick(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
            if(evt.currentTarget.name == this.avEditor.colorsTabDnBtn.name)
            {
               this.openTab(COLOR_TAB_ID);
            }
            else if(evt.currentTarget.name == this.avEditor.patternTabDnBtn.name)
            {
               this.openTab(PATTERN_TAB_ID);
            }
            else if(evt.currentTarget.name == this.avEditor.eyesTabDnBtn.name)
            {
               this.openTab(EYE_TAB_ID);
            }
            else
            {
               DebugUtility.debugTrace("Error AvatarEditor on colorTableTabClick handler: Invalid tab: " + evt.currentTarget.name);
            }
         }
      }
      
      private function colorTableTabOverClick(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.name == this.avEditor.colorsTabDnBtn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14621),665,105);
         }
         else if(evt.currentTarget.name == this.avEditor.patternTabDnBtn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14622),820,105);
         }
         else if(evt.currentTarget.name == this.avEditor.eyesTabDnBtn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,LocalizationManager.translateIdOnly(14623),742,105);
         }
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function btnOutHandler(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function openTab(tabId:int) : void
      {
         if(tabId == COLOR_TAB_ID)
         {
            this.openColorTableColorsTab();
         }
         else if(tabId == PATTERN_TAB_ID)
         {
            this.openColorTablePatternEyesTab(true);
         }
         else if(tabId == EYE_TAB_ID)
         {
            this.openColorTablePatternEyesTab(false);
         }
         else
         {
            DebugUtility.debugTrace("Error AvatarEditor on openTab: Invalid tabId: " + tabId);
         }
      }
      
      private function openColorTableColorsTab() : void
      {
         this.avEditor.colorsTabUp.visible = true;
         this.avEditor.eyesTabUp.visible = false;
         this.avEditor.patternTabUp.visible = false;
         this._tabOpenId = 0;
         this.avEditor.colorTableBlock.colors.visible = true;
         this.avEditor.colorTableBlock.patternsAndEyes.visible = false;
      }
      
      private function openColorTablePatternEyesTab(isPattern:Boolean) : void
      {
         this.avEditor.colorTableBlock.patternsAndEyes.visible = true;
         this.avEditor.colorTableBlock.colors.visible = false;
         while(this._eyePattWindow.numChildren > 1)
         {
            this._eyePattWindow.removeChildAt(1);
         }
         if(isPattern)
         {
            this._tabOpenId = 1;
            this.avEditor.colorsTabUp.visible = false;
            this.avEditor.eyesTabUp.visible = false;
            this.avEditor.patternTabUp.visible = true;
            LocalizationManager.translateId(this.avEditor.colorTableBlock.patternsAndEyes.topTxt,11213);
            if(Boolean(this.avEditor.colorTableBlock.patternsAndEyes.contains(this._colorTableEyes)))
            {
               this.avEditor.colorTableBlock.patternsAndEyes.removeChild(this._colorTableEyes);
            }
            this.avEditor.colorTableBlock.patternsAndEyes.addChild(this._colorTablePatterns);
            if(this._patterns.length > 0)
            {
               if(this._patterns.length <= 1)
               {
                  this._lArrowBtn.visible = false;
                  this._rArrowBtn.visible = false;
               }
               if(Boolean(this._patterns[this._currPattern]))
               {
                  this._eyePattWindow.addChild(this._patterns[this._currPattern].icon);
               }
            }
            else
            {
               this._eyePattWindow.visible = false;
               this.avEditor.lArrBtn.visible = false;
               this.avEditor.rArrBtn.visible = false;
            }
         }
         else
         {
            this._tabOpenId = 2;
            this.avEditor.colorsTabUp.visible = false;
            this.avEditor.eyesTabUp.visible = true;
            this.avEditor.patternTabUp.visible = false;
            LocalizationManager.translateId(this.avEditor.colorTableBlock.patternsAndEyes.topTxt,11214);
            if(Boolean(this.avEditor.colorTableBlock.patternsAndEyes.contains(this._colorTablePatterns)))
            {
               this.avEditor.colorTableBlock.patternsAndEyes.removeChild(this._colorTablePatterns);
            }
            this.avEditor.colorTableBlock.patternsAndEyes.addChild(this._colorTableEyes);
            if(this._eyes.length > 0)
            {
               if(this._eyes.length <= 1)
               {
                  this._lArrowBtn.visible = false;
                  this._rArrowBtn.visible = false;
               }
               if(Boolean(this._eyes[this._currEye]))
               {
                  this._eyePattWindow.addChild(this._eyes[this._currEye].icon);
               }
            }
            else
            {
               this._eyePattWindow.visible = false;
               this._lArrowBtn.visible = false;
               this._rArrowBtn.visible = false;
            }
         }
         this.colorCurrEyePattIcon();
         this.avEditor.colorTableBlock.patternsAndEyes.visible = true;
         this.avEditor.colorTableBlock.colors.visible = false;
      }
      
      private function createPatternsAndEyesArrays() : void
      {
         var temp:Array = this._avatarEditorView.inventoryBodyModItems;
         this._eyes = [];
         this._patterns = [];
         this._patterns.push(null);
         for(var i:int = 0; i < temp.length; i++)
         {
            if(temp[i].layerId == Item.PATTERN_LAYER)
            {
               if(Boolean(temp[i].getInUse(this._worldAvatar.perUserAvId)))
               {
                  this._currPattern = this._patterns.length;
               }
               this._patterns.push(temp[i]);
            }
            else if(temp[i].layerId == Item.EYE_LAYER)
            {
               if(Boolean(temp[i].getInUse(this._worldAvatar.perUserAvId)))
               {
                  this._currEye = this._eyes.length;
               }
               this._eyes.push(temp[i]);
            }
         }
      }
      
      private function arrowBtnHandler(evt:MouseEvent) : void
      {
         var incr:int = 0;
         var currItem:Item = null;
         var invIdx:int = 0;
         var currAccIdx:int = 0;
         var currAccList:Array = null;
         evt.stopPropagation();
         if(evt.currentTarget.name == this._lArrowBtn.name)
         {
            incr = -1;
         }
         else if(evt.currentTarget.name == this._rArrowBtn.name)
         {
            incr = 1;
         }
         while(this._eyePattWindow.numChildren > 1)
         {
            this._eyePattWindow.removeChildAt(1);
         }
         var currItemInUse:Boolean = false;
         if(this._tabOpenId == 1)
         {
            currItem = this._patterns[this._currPattern];
            currAccIdx = this._currPattern;
            currAccList = this._patterns;
         }
         else if(this._tabOpenId == 2)
         {
            currItem = this._eyes[this._currEye];
            currAccIdx = this._currEye;
            currAccList = this._eyes;
         }
         currAccIdx += incr;
         if(currAccIdx < 0)
         {
            currAccIdx = currAccList.length - 1;
         }
         else if(currAccIdx > currAccList.length - 1)
         {
            currAccIdx = 0;
         }
         if(currAccList[currAccIdx] == null)
         {
            this.hideItem(currItem);
         }
         else
         {
            currItem = currAccList[currAccIdx];
            this.showItem(currItem,this.hideBodModWhenShowingBodMod);
         }
         if(Boolean(currAccList[currAccIdx]) && currAccList[currAccIdx].icon != null)
         {
            this._eyePattWindow.addChild(currAccList[currAccIdx].icon);
         }
         if(this._tabOpenId == 1)
         {
            this._currPattern = currAccIdx;
         }
         else if(this._tabOpenId == 2)
         {
            this._currEye = currAccIdx;
         }
         this.colorCurrEyePattIcon();
      }
      
      public function showItem(showItem:Item, callbackFunc:Function = null) : void
      {
         var sendId:int = 0;
         var itemList:Array = null;
         var worldItemList:Array = null;
         var found:Boolean = false;
         var j:int = 0;
         var k:int = 0;
         if(Boolean(showItem))
         {
            sendId = showItem.invIdx;
            if(Boolean(this._itemsOn) && Boolean(this._itemsOff))
            {
               if(showItem.type == Item.CLOTHING_TYPE)
               {
                  itemList = this._avatarEditorView.inventoryClothingItems;
                  worldItemList = this._worldAvatar.inventoryClothing.itemArray;
               }
               else
               {
                  itemList = this._avatarEditorView.inventoryBodyModItems;
                  worldItemList = this._worldAvatar.inventoryBodyMod.itemArray;
               }
               for(j = 0; j < itemList.length; j++)
               {
                  if(itemList[j].invIdx == showItem.invIdx)
                  {
                     if(this._itemsOff.indexOf(sendId) != -1)
                     {
                        this._itemsOff.splice(this._itemsOff.indexOf(sendId),1);
                     }
                     for(k = 0; k < worldItemList.length; k++)
                     {
                        if(showItem.invIdx == worldItemList[k].invIdx)
                        {
                           found = true;
                           if(!worldItemList[k].getInUse(this._worldAvatar.perUserAvId))
                           {
                              if(this._itemsOn.indexOf(sendId) == -1)
                              {
                                 this._itemsOn.push(sendId);
                              }
                              break;
                           }
                        }
                     }
                     if(!found && this._itemsOn.indexOf(sendId) == -1)
                     {
                        this._itemsOn.push(sendId);
                     }
                     break;
                  }
               }
            }
            this._avatarEditorView.showAccessory(showItem,callbackFunc);
         }
      }
      
      public function hideItem(hideItem:Item) : void
      {
         var sendId:int = 0;
         var itemList:Array = null;
         var i:int = 0;
         if(Boolean(hideItem))
         {
            sendId = hideItem.invIdx;
            if(Boolean(this._itemsOn) && Boolean(this._itemsOff))
            {
               if(hideItem.type == Item.CLOTHING_TYPE)
               {
                  itemList = this._avatarEditorView.inventoryClothingItems;
               }
               else
               {
                  itemList = this._avatarEditorView.inventoryBodyModItems;
               }
               for(i = 0; i < itemList.length; i++)
               {
                  if(itemList[i].invIdx == hideItem.invIdx)
                  {
                     if(this._itemsOff.indexOf(sendId) == -1)
                     {
                        this._itemsOff.push(sendId);
                     }
                     if(this._itemsOn.indexOf(sendId) != -1)
                     {
                        this._itemsOn.splice(this._itemsOn.indexOf(sendId),1);
                     }
                     break;
                  }
               }
            }
            this._avatarEditorView.hideAccessory(hideItem);
         }
      }
      
      public function onShopBtnHandler(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(this.avEditor.shopBtn.isGray))
         {
            return;
         }
         this._shop = new Shop();
         if(AvatarManager.roomEnviroType == Utility.ENVIRO_OCEAN)
         {
            this._shop.init(GenericListXtCommManager.ACC_BAHARIBAY_SHOP_ID,DefPacksDefHelper.DEF_ITEM,this._worldAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
         else
         {
            this._shop.init(GenericListXtCommManager.ACC_JAMAA_SHOP_ID,DefPacksDefHelper.DEF_ITEM,this._worldAvatar,this._guiLayer,true,this.onShopClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
         this.sendChangesRequest();
      }
      
      public function onShopBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this.avEditor.shopBtn.isGray))
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(evt.currentTarget),AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? LocalizationManager.translateIdOnly(14624) : LocalizationManager.translateIdOnly(14625),0,-45,true);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onShopBtnOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function onPetBtnHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this.avEditor.petsBtn.isGray))
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         this._petInventory = new PetInventory();
         this._petInventory.init(this.onPetInventoryClose);
      }
      
      private function onPetInventoryClose() : void
      {
         this._petInventory = null;
         this.loadPetView();
      }
      
      private function onPetBtnOverHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this.avEditor.petsBtn.isGray))
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(evt.currentTarget),LocalizationManager.translateIdOnly(11240),0,-45,true);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onPetBtnOutHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function onRecycleClothesBtn(evt:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
         if(Boolean(this.avEditor.recycleClothesBtn.isGray))
         {
            return;
         }
         DarkenManager.showLoadingSpiral(true);
         this._recycle = new RecycleItems();
         this.sendChangesRequest();
      }
      
      public function openRecycle() : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(this._recycle) && !this._recycle.hasBeenInited())
         {
            this._recycle.init(RecycleItems.RECYCLE_ACCESSORIES,this._guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
      }
      
      private function onRecycleClothesBtnOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this.avEditor.recycleClothesBtn.isGray))
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(evt.currentTarget),LocalizationManager.translateIdOnly(14626),0,-35);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function onRecycleClose(itemRecycled:Boolean = false) : void
      {
         if(Boolean(this._recycle))
         {
            this._recycle.destroy();
            this._recycle = null;
         }
         if(itemRecycled)
         {
            this.avEditor.tradeBtnUp.visible = false;
            this.avEditor.tradeBtnDown.visible = true;
            this.avEditor.clothesBtnUp.visible = true;
            this.avEditor.clothesBtnDown.visible = false;
            this.avEditor.sortBtn.visible = true;
            this.avEditor.itemCounter.visible = true;
            this.avEditor.infoBtn.visible = false;
            this.avEditor.howTxt.visible = false;
            this._itemsOn = [];
            this._itemsOff = [];
            this.positionAndDrawAvatarView(true);
            this.createPatternsAndEyesArrays();
            this._currClothesArray = this._allNewestClothes = this._avatarEditorView.inventoryClothingItems;
            this._headItems = Utility.sortItemsAll(this._currClothesArray,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
            this._neckItems = Utility.sortItemsAll(this._currClothesArray,0,Item.NECK_LAYER);
            this._backItems = Utility.sortItemsAll(this._currClothesArray,0,Item.BACK_LAYER);
            this._legItems = Utility.sortItemsAll(this._currClothesArray,0,Item.LEG_LAYER);
            this._tailItems = Utility.sortItemsAll(this._currClothesArray,0,Item.TAIL_LAYER);
            this._itemTypeItems = Utility.sortByItem(this._currClothesArray,0);
            this._allOldestClothes = this._allNewestClothes.concat().reverse();
            if(Boolean(this._currClothesArray))
            {
               this._currClothesArray = this.convertIntToList(_mainClothingSortType,true,false);
            }
            this._fullClothesList = this._fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
            this._fullHeadItems = Utility.sortItemsAll(this._fullClothesList,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
            this._fullNeckItems = Utility.sortItemsAll(this._fullClothesList,0,Item.NECK_LAYER);
            this._fullBackItems = Utility.sortItemsAll(this._fullClothesList,0,Item.BACK_LAYER);
            this._fullLegItems = Utility.sortItemsAll(this._fullClothesList,0,Item.LEG_LAYER);
            this._fullTailItems = Utility.sortItemsAll(this._fullClothesList,0,Item.TAIL_LAYER);
            this._itemTypeDenItems = Utility.sortByItem(this._currClothesArray,0);
            this._fullAllOldestClothes = this._fullallNewestClothes.concat().reverse();
            this.avEditor.itemCounter.counterTxt.text = this._allNewestClothes.length + "/" + Shop.maxItems;
            this._currTradesArray = gMainFrame.userInfo.getMyTradeList().slice();
            this._itemTradeWindows = null;
            if(Boolean(this._itemClothingWindows))
            {
               this._itemClothingWindows.destroy();
               this._itemClothingWindows = null;
            }
            this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
         }
      }
      
      private function onShopClose(purchasedItems:Boolean) : void
      {
         if(Boolean(this._shop))
         {
            this._shop.destroy();
            this._shop = null;
         }
         if(purchasedItems)
         {
            this.avEditor.tradeBtnUp.visible = false;
            this.avEditor.tradeBtnDown.visible = true;
            this.avEditor.clothesBtnUp.visible = true;
            this.avEditor.clothesBtnDown.visible = false;
            this.avEditor.sortBtn.visible = true;
            this.avEditor.itemCounter.visible = true;
            this.avEditor.infoBtn.visible = false;
            this.avEditor.howTxt.visible = false;
            this._itemsOn = [];
            this._itemsOff = [];
            this.positionAndDrawAvatarView(true);
            this.createPatternsAndEyesArrays();
            this._currClothesArray = this._allNewestClothes = this._avatarEditorView.inventoryClothingItems;
            this._headItems = Utility.sortItemsAll(this._currClothesArray,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
            this._neckItems = Utility.sortItemsAll(this._currClothesArray,0,Item.NECK_LAYER);
            this._backItems = Utility.sortItemsAll(this._currClothesArray,0,Item.BACK_LAYER);
            this._legItems = Utility.sortItemsAll(this._currClothesArray,0,Item.LEG_LAYER);
            this._tailItems = Utility.sortItemsAll(this._currClothesArray,0,Item.TAIL_LAYER);
            this._itemTypeItems = Utility.sortByItem(this._currClothesArray,0);
            this._allOldestClothes = this._allNewestClothes.concat().reverse();
            if(Boolean(this._currClothesArray))
            {
               this._currClothesArray = this.convertIntToList(_mainClothingSortType,true,false);
            }
            this._fullClothesList = this._fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
            this._fullHeadItems = Utility.sortItemsAll(this._fullClothesList,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
            this._fullNeckItems = Utility.sortItemsAll(this._fullClothesList,0,Item.NECK_LAYER);
            this._fullBackItems = Utility.sortItemsAll(this._fullClothesList,0,Item.BACK_LAYER);
            this._fullLegItems = Utility.sortItemsAll(this._fullClothesList,0,Item.LEG_LAYER);
            this._fullTailItems = Utility.sortItemsAll(this._fullClothesList,0,Item.TAIL_LAYER);
            this._itemTypeDenItems = Utility.sortByItem(this._currClothesArray,0);
            this._fullAllOldestClothes = this._fullallNewestClothes.concat().reverse();
            this.avEditor.itemCounter.counterTxt.text = this._allNewestClothes.length + "/" + Shop.maxItems;
            if(Boolean(this._itemClothingWindows))
            {
               this._itemClothingWindows.destroy();
               this._itemClothingWindows = null;
            }
            this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
         }
      }
      
      private function numTradeItemsInClothesList(clothes:Array) : int
      {
         var j:int = 0;
         var count:int = 0;
         for(var i:int = 0; i < this._currTradesArray.length; i++)
         {
            if(this._currTradesArray[i].type == 0)
            {
               for(j = 0; j < clothes.length; j++)
               {
                  if(this._currTradesArray[i].invIdx == clothes[j].invIdx)
                  {
                     count++;
                     break;
                  }
               }
            }
         }
         return count;
      }
      
      private function numTradeItemsInDenItemsList(denItems:Array) : int
      {
         var j:int = 0;
         var count:int = 0;
         for(var i:int = 0; i < this._currTradesArray.length; i++)
         {
            if(this._currTradesArray[i].type == 1)
            {
               for(j = 0; j < denItems.length; j++)
               {
                  if(this._currTradesArray[i].invIdx == denItems[j].invIdx)
                  {
                     count++;
                     break;
                  }
               }
            }
         }
         return count;
      }
      
      private function createItemWindows(itemsArray:Array, parent:MovieClip, updateMainScroll:Boolean = false) : void
      {
         var currItemWindow:WindowGenerator = null;
         var numItemsInCurrentArray:int = 0;
         var numWin:int = 0;
         var found:Boolean = false;
         var isTradeList:Boolean = false;
         var isChoosingForTradeList:Boolean = false;
         var isClothing:Boolean = false;
         var currItems:Array = null;
         var indexArray:Array = null;
         var currItem:Object = null;
         var j:int = 0;
         var i:int = 0;
         var m:int = 0;
         var tempItem:Object = null;
         var l:int = 0;
         if(Boolean(this._mainScrollbar) && this._mainScrollbar.getScrollContentParent == parent)
         {
            if(parent == this.avEditor.itemBlock && updateMainScroll)
            {
               _mainScrollYPosition = this._mainScrollbar.scrollYValue;
            }
            this._mainScrollbar.destroy();
            this._mainScrollbar = null;
         }
         var numSkipped:int = 0;
         if(itemsArray == this._currTradesArray)
         {
            isTradeList = true;
         }
         else
         {
            isTradeList = false;
         }
         if(isTradeList)
         {
            numItemsInCurrentArray = 12;
            numWin = Math.ceil(numItemsInCurrentArray / this.NUM_X_WIN) * this.NUM_X_WIN;
         }
         else if(itemsArray == this._allNewestClothes || itemsArray == this._currClothesArray || itemsArray == this._fullClothesList || Boolean(this._tradeWindow.visible) && Boolean(this._tradeWindow.clothesBtnUp.visible))
         {
            isClothing = true;
            numItemsInCurrentArray = Math.max(itemsArray.length,12);
            if(parent == this.avEditor.itemBlock)
            {
               numWin = Math.ceil(itemsArray.length / this.NUM_X_WIN) * this.NUM_X_WIN;
            }
            else
            {
               numWin = Math.ceil((itemsArray.length - this.numTradeItemsInClothesList(itemsArray)) / this.NUM_X_WIN) * this.NUM_X_WIN;
            }
         }
         else
         {
            if(!(itemsArray == this._currDenItemsArray || itemsArray == this._allNewestDenItems))
            {
               throw new Error("None of our lists match given items list");
            }
            numItemsInCurrentArray = Math.max(itemsArray.length,12);
            numWin = Math.ceil((itemsArray.length - this.numTradeItemsInDenItemsList(itemsArray)) / this.NUM_X_WIN) * this.NUM_X_WIN;
         }
         if(Boolean(this.avEditor.tradeBtnUp.visible))
         {
            isChoosingForTradeList = true;
         }
         if(parent == this.avEditor.itemBlock)
         {
            if(isChoosingForTradeList)
            {
               currItemWindow = this._itemTradeWindows;
            }
            else
            {
               currItemWindow = this._itemClothingWindows;
            }
            while(this.avEditor.itemBlock.numChildren > 0)
            {
               this.avEditor.itemBlock.removeChildAt(0);
            }
         }
         else if(parent == this._tradeWindow.itemBlock)
         {
            if(isClothing)
            {
               currItemWindow = this._tradeClothingWindows;
            }
            else
            {
               currItemWindow = this._tradeDenWindows;
            }
            while(this._tradeWindow.itemBlock.numChildren > 0)
            {
               this._tradeWindow.itemBlock.removeChildAt(0);
            }
         }
         if(currItemWindow == null)
         {
            currItems = [];
            indexArray = [];
            currItem = null;
            for(i = 0; i < numItemsInCurrentArray; i++)
            {
               if(i < numItemsInCurrentArray)
               {
                  if(Boolean(itemsArray[i]))
                  {
                     if(Boolean(this.avEditor.clothesBtnUp.visible))
                     {
                        currItem = itemsArray[i];
                     }
                     else if(isTradeList)
                     {
                        tempItem = null;
                        if(itemsArray[i].type == TradeManager.CLOTHING_TYPE)
                        {
                           for(m = 0; m < this._fullClothesList.length; m++)
                           {
                              if(this._fullClothesList[m].invIdx == itemsArray[i].invIdx)
                              {
                                 tempItem = this._fullClothesList[m];
                                 break;
                              }
                           }
                           if(Boolean(tempItem))
                           {
                              currItem = new Item();
                              currItem.init(tempItem.defId,tempItem.invIdx,tempItem.color,tempItem.inUseFlagLand,tempItem.inUseFlagOcean);
                           }
                        }
                        else
                        {
                           for(m = 0; m < this._allNewestDenItems.length; m++)
                           {
                              if(this._allNewestDenItems[m].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 if(this._allNewestDenItems[m].invIdx == itemsArray[i].invIdx)
                                 {
                                    tempItem = this._allNewestDenItems[m];
                                    break;
                                 }
                              }
                           }
                           if(Boolean(tempItem))
                           {
                              currItem = new DenItem();
                              currItem.init(tempItem.itemDefId,tempItem.invIdx,tempItem.categoryId,tempItem.version,tempItem.refId);
                           }
                        }
                     }
                     else
                     {
                        currItem = itemsArray[i];
                        for(l = 0; l < this._currTradesArray.length; l++)
                        {
                           if((currItem is Item && this._currTradesArray[l].type == 0 || currItem is DenItem && this._currTradesArray[l].type == 1) && currItem.invIdx == this._currTradesArray[l].invIdx)
                           {
                              found = true;
                              break;
                           }
                        }
                        if(found)
                        {
                           found = false;
                           numSkipped++;
                           continue;
                        }
                     }
                     indexArray.push(j + numSkipped);
                     if(Boolean(currItem))
                     {
                        currItems.push(currItem);
                     }
                  }
               }
               j++;
            }
            currItemWindow = new WindowGenerator();
            currItemWindow.init(this.NUM_X_WIN,this.NUM_Y_WIN,Math.max(numWin,12),this.X_WIN_OFFSET,this.Y_WIN_OFFSET,this.X_WIN_START,ItemWindowOriginal,currItems,"icon",{
               "mouseDown":this.winMouseClick,
               "mouseOver":this.winMouseOver,
               "mouseOut":this.winMouseOut,
               "memberOnlyDown":this.memberOnlyDown
            },{
               "isAvatarEditor":true,
               "isTradeList":isTradeList,
               "isChoosingForTradeList":isChoosingForTradeList,
               "indexArray":indexArray
            });
            if(parent == this.avEditor.itemBlock)
            {
               if(isChoosingForTradeList)
               {
                  this._itemTradeWindows = currItemWindow;
               }
               else
               {
                  this._itemClothingWindows = currItemWindow;
               }
            }
            else if(isClothing)
            {
               this._tradeClothingWindows = currItemWindow;
            }
            else
            {
               this._tradeDenWindows = currItemWindow;
            }
         }
         parent.addChild(currItemWindow);
         this.createScrollbar(currItemWindow);
      }
      
      private function createScrollbar(currItemWindow:WindowGenerator) : void
      {
         var scrollValue:Number = NaN;
         if(Boolean(currItemWindow))
         {
            if(currItemWindow.parent == this.avEditor.itemBlock)
            {
               scrollValue = _mainScrollYPosition;
            }
            else if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
            {
               scrollValue = _tradeClothingScrollYPosition;
            }
            else
            {
               scrollValue = _tradeDenScrollYPosition;
            }
            this._mainScrollbar = new SBScrollbar();
            this._mainScrollbar.init(currItemWindow,currItemWindow.width,currItemWindow.boxHeight * this.NUM_Y_WIN + this.Y_WIN_OFFSET * this.NUM_Y_WIN + this.Y_WIN_START * 2,this.SCROLLBAR_GAP,"scrollbar2",currItemWindow.boxHeight + this.Y_WIN_OFFSET,scrollValue,currItemWindow.height);
         }
      }
      
      private function openCloseTradeWindow(parent:MovieClip) : void
      {
         var isClothing:Boolean = false;
         var currArray:Array = null;
         this._tradeWindow.visible = !this._tradeWindow.visible;
         this.avEditor.blackoutFull.visible = !this.avEditor.blackoutFull.visible;
         if(this._tradeWindow.visible)
         {
            if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
            {
               this._tradeWindow.denBtnUp.visible = false;
               this._tradeWindow.denBtnDown.visible = true;
               this._tradeWindow.clothesBtnUp.visible = true;
               this._tradeWindow.clothesBtnDown.visible = false;
               this._tradeSort.sort7.visible = true;
               this._tradeSort.sort6.visible = true;
               this._tradeSort.sort5.visible = true;
               LocalizationManager.translateId(this._tradeSort.sort8.txt,11205);
               LocalizationManager.translateId(this._tradeSort.sort7.txt,11206);
               LocalizationManager.translateId(this._tradeSort.sort6.txt,11207);
               LocalizationManager.translateId(this._tradeSort.sort5.txt,11208);
               LocalizationManager.translateId(this._tradeSort.sort4.txt,11209);
               LocalizationManager.translateId(this._tradeSort.sort3.txt,11210);
               LocalizationManager.translateId(this._tradeSort.sort2.txt,11211);
               LocalizationManager.translateId(this._tradeSort.sort1.txt,11212);
            }
            else
            {
               this._tradeWindow.denBtnUp.visible = true;
               this._tradeWindow.denBtnDown.visible = false;
               this._tradeWindow.clothesBtnUp.visible = false;
               this._tradeWindow.clothesBtnDown.visible = true;
               LocalizationManager.translateId(this._tradeSort.sort4.txt,11215);
               LocalizationManager.translateId(this._tradeSort.sort3.txt,11216);
               LocalizationManager.translateId(this._tradeSort.sort2.txt,11211);
               LocalizationManager.translateId(this._tradeSort.sort1.txt,11212);
               this._tradeSort.sort5.visible = false;
               this._tradeSort.sort6.visible = false;
               this._tradeSort.sort7.visible = false;
               this._tradeSort.sort8.visible = false;
            }
            this._tradeSort.visible = false;
            isClothing = _tradeListViewType == this.CLOTHING_VIEW_TYPE;
            currArray = this.convertIntToList(isClothing ? _tradeClothingSortType : _tradeDenSortType,isClothing);
            this.createItemWindows(currArray,parent);
         }
         else
         {
            if(Boolean(this._mainScrollbar))
            {
               if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  _tradeClothingScrollYPosition = this._mainScrollbar.scrollYValue;
               }
               else
               {
                  _tradeDenScrollYPosition = this._mainScrollbar.scrollYValue;
               }
            }
            this.createItemWindows(this._currTradesArray,this.avEditor.itemBlock);
         }
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(evt.currentTarget.numChildren >= 2)
         {
            if(evt.currentTarget.cir.currentFrameLabel == "down")
            {
               evt.currentTarget.cir.gotoAndStop("downMouse");
            }
            else if(evt.currentTarget.cir.currentFrameLabel != "downMouse")
            {
               evt.currentTarget.cir.gotoAndStop("over");
            }
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(evt.currentTarget.numChildren >= 2)
         {
            if(evt.currentTarget.cir.currentFrameLabel == "downMouse")
            {
               evt.currentTarget.cir.gotoAndStop("down");
            }
            else if(evt.currentTarget.cir.currentFrameLabel != "down")
            {
               evt.currentTarget.cir.gotoAndStop("up");
            }
         }
      }
      
      private function winMouseClick(evt:MouseEvent) : void
      {
         var currItem:Object = null;
         var avTypesThatCanUse:Array = null;
         var avatarNamesString:String = null;
         var locString:String = null;
         var i:int = 0;
         var isClothing:Boolean = false;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(this.avEditor.clothesBtnUp.visible))
         {
            currItem = this._currClothesArray[evt.currentTarget.index];
         }
         else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
         {
            currItem = this._fullClothesList[evt.currentTarget.index];
         }
         else if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
         {
            currItem = this._currDenItemsArray[evt.currentTarget.index];
         }
         else if(Boolean(this.avEditor.tradeBtnUp.visible))
         {
            currItem = this._currTradesArray[evt.currentTarget.index];
         }
         if(Boolean(currItem))
         {
            if(!this._tradeWindow.visible && Boolean(this.avEditor.clothesBtnUp.visible))
            {
               if(!ItemXtCommManager.canUseItem(currItem.defId,this._worldAvatar.avTypeId))
               {
                  avTypesThatCanUse = ItemXtCommManager.avTypeThatCanUseItem(currItem.defId);
                  if(avTypesThatCanUse.length > 0)
                  {
                     if(avTypesThatCanUse.length == 1)
                     {
                        new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14698,LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(avTypesThatCanUse[0]).titleStrRef)));
                     }
                     else
                     {
                        avatarNamesString = "";
                        for(i = 0; i < avTypesThatCanUse.length; i++)
                        {
                           locString = LocalizationManager.translateIdOnly(gMainFrame.userInfo.getAvatarDefByAvType(avTypesThatCanUse[i]).titleStrRef);
                           if(avatarNamesString == "")
                           {
                              avatarNamesString += locString;
                           }
                           else
                           {
                              avatarNamesString += ", " + locString;
                           }
                        }
                        new SBOkPopup(this._guiLayer,LocalizationManager.translateIdAndInsertOnly(14698,avatarNamesString));
                     }
                  }
                  return;
               }
               if(evt.currentTarget.cir.currentFrameLabel == "downMouse" && Boolean(currItem.getInUse(this._worldAvatar.perUserAvId)))
               {
                  this.hideItem(Item(currItem));
                  evt.currentTarget.cir.gotoAndStop("over");
               }
               else if(evt.currentTarget.cir.currentFrameLabel != "downMouse" && !currItem.getInUse(this._worldAvatar.perUserAvId))
               {
                  this.showItem(Item(currItem),this.hideItemWhenShowingItem);
                  evt.currentTarget.cir.gotoAndStop("downMouse");
               }
               else
               {
                  DebugUtility.debugTrace("Item is in use? But not in use? Huuuuuuuuh");
               }
            }
            else if(!this._tradeWindow.visible && Boolean(this.avEditor.tradeBtnUp.visible))
            {
               evt.currentTarget.cir.gotoAndStop("up");
               if(Boolean(evt.currentTarget.removeBtn.visible))
               {
                  this._currTradesArray.splice(evt.currentTarget.index,1);
                  if(currItem.type == TradeManager.CLOTHING_TYPE)
                  {
                     TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                  }
                  else
                  {
                     TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                  }
                  this.addRemoveTradeItemFromList(currItem,false);
                  if(Boolean(this._itemTradeWindows))
                  {
                     this._itemTradeWindows.destroy();
                     this._itemTradeWindows = null;
                  }
                  this.createItemWindows(this._currTradesArray,this.avEditor.itemBlock);
               }
               else
               {
                  this.openCloseTradeWindow(this._tradeWindow.itemBlock);
               }
            }
            else if(this._tradeWindow.visible && (Boolean(this._tradeWindow.denBtnUp.visible) || Boolean(this._tradeWindow.clothesBtnUp.visible)))
            {
               evt.currentTarget.cir.gotoAndStop("up");
               if(currItem is Item)
               {
                  currItem = {
                     "type":TradeManager.CLOTHING_TYPE,
                     "invIdx":currItem.invIdx
                  };
                  if(Boolean(this._tradeClothingWindows))
                  {
                     this._tradeClothingWindows.destroy();
                     this._tradeClothingWindows = null;
                  }
               }
               else if(currItem is DenItem)
               {
                  currItem = {
                     "type":TradeManager.DEN_TYPE,
                     "invIdx":currItem.invIdx
                  };
                  if(Boolean(this._tradeDenWindows))
                  {
                     this._tradeDenWindows.destroy();
                     this._tradeDenWindows = null;
                  }
               }
               this._currTradesArray.push(currItem);
               if(currItem.type == TradeManager.CLOTHING_TYPE)
               {
                  TradeManager.adjustByOnNumClothingItemsInMyTradeList(1);
               }
               else
               {
                  TradeManager.adjustByOnNumDenItemsInMyTradeList(1);
               }
               this.addRemoveTradeItemFromList(currItem,true);
               if(Boolean(this._itemTradeWindows))
               {
                  this._itemTradeWindows.destroy();
                  this._itemTradeWindows = null;
               }
               this.openCloseTradeWindow(null);
            }
            else
            {
               DebugUtility.debugTrace("Wow nothing is visible? How is that possible?");
            }
            AJAudio.playSubMenuBtnClick();
         }
         else if(Boolean(evt.currentTarget.addBtn.visible))
         {
            isClothing = _tradeListViewType == this.CLOTHING_VIEW_TYPE;
            if(isClothing)
            {
               this._fullClothesList = this.convertIntToList(_tradeClothingSortType,isClothing);
            }
            else
            {
               this._currDenItemsArray = this.convertIntToList(_tradeDenSortType,isClothing);
            }
            this.openCloseTradeWindow(this._tradeWindow.itemBlock);
         }
         else
         {
            DebugUtility.debugTrace("Curr Item is null, and the addBtn is not visible??");
         }
      }
      
      private function memberOnlyDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         UpsellManager.displayPopup(UpsellManager.ACCESSORIES,"equipAccessory/" + this._currClothesArray[evt.currentTarget.index].name);
      }
      
      private function hideItemWhenShowingItem(hideItem:Item) : void
      {
         var j:int = 0;
         var k:int = 0;
         var mc:MovieClip = null;
         var onIndex:int = this._itemsOn.indexOf(hideItem.invIdx);
         if(onIndex == -1)
         {
            for(j = 0; j < this._currClothesArray.length; j++)
            {
               if(this._currClothesArray[j].invIdx == hideItem.invIdx)
               {
                  if(Boolean(this._itemsOff))
                  {
                     this._itemsOff.push(hideItem.invIdx);
                     break;
                  }
               }
            }
         }
         if(Boolean(this._itemsOn))
         {
            if(onIndex != -1)
            {
               this._itemsOn.splice(this._itemsOn.indexOf(hideItem.invIdx),1);
            }
         }
         if(Boolean(this._itemClothingWindows))
         {
            for(k = 0; k < this._itemClothingWindows.bg.numChildren; k++)
            {
               mc = MovieClip(this._itemClothingWindows.bg.getChildAt(k));
               if(this._currClothesArray[mc.index].invIdx == hideItem.invIdx)
               {
                  mc.cir.gotoAndStop("up");
                  break;
               }
            }
         }
      }
      
      private function hideBodModWhenShowingBodMod(hideItem:Item) : void
      {
         var j:int = 0;
         var items:Array = this._avatarEditorView.inventoryBodyModItems;
         var onIndex:int = this._itemsOn.indexOf(hideItem.invIdx);
         if(onIndex == -1)
         {
            for(j = 0; j < items.length; j++)
            {
               if(items[j].invIdx == hideItem.invIdx)
               {
                  if(Boolean(this._itemsOff))
                  {
                     this._itemsOff.push(hideItem.invIdx);
                     break;
                  }
               }
            }
         }
         if(Boolean(this._itemsOn))
         {
            if(onIndex != -1)
            {
               this._itemsOn.splice(this._itemsOn.indexOf(hideItem.invIdx),1);
            }
         }
      }
      
      private function wereItemsOnOriginally(itemsOn:Array, itemsOff:Array) : void
      {
         var i:int = 0;
         var j:int = 0;
         var itemList:Array = this._worldAvatar.inventoryClothing.itemArray.concat(this._worldAvatar.inventoryBodyMod.itemArray);
         for(i = 0; i < itemsOn.length; i++)
         {
            for(j = 0; j < itemList.length; j++)
            {
               if(itemsOn[i] == itemList[j].invIdx && Boolean(itemList[j].getInUse(this._worldAvatar.perUserAvId)))
               {
                  itemsOn.splice(i,1);
                  i--;
                  break;
               }
            }
         }
         for(i = 0; i < itemsOff.length; i++)
         {
            for(j = 0; j < itemList.length; j++)
            {
               if(itemsOff[i] == itemList[j].invIdx && !itemList[j].getInUse(this._worldAvatar.perUserAvId))
               {
                  itemsOff.splice(i,1);
                  i--;
                  break;
               }
            }
         }
         this._itemsOn = itemsOn;
         this._itemsOff = itemsOff;
      }
      
      private function addRemoveTradeItemFromList(tradeItem:Object, isAdding:Boolean) : void
      {
         var i:int = 0;
         var j:int = 0;
         var origTradingList:Array = gMainFrame.userInfo.getMyTradeList();
         if(isAdding)
         {
            for(i = 0; i < origTradingList.length; i++)
            {
               if(origTradingList[i].invIdx == tradeItem.invIdx && origTradingList[i].type == tradeItem.type)
               {
                  this._tradeItemsOut.splice(this._tradeItemsOut.indexOf(tradeItem),1);
                  return;
               }
            }
            this._tradeItemsIn.push(tradeItem);
         }
         else
         {
            for(i = 0; i < origTradingList.length; i++)
            {
               if(origTradingList[i].invIdx == tradeItem.invIdx && origTradingList[i].type == tradeItem.type)
               {
                  this._tradeItemsOut.push(tradeItem);
                  return;
               }
            }
            this._tradeItemsIn.splice(this._tradeItemsIn.indexOf(tradeItem),1);
         }
      }
      
      private function sortByHandler(evt:MouseEvent) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         if(Boolean(this.avEditor.sortBtn.isGray))
         {
            return;
         }
         if(!this._tradeWindow.visible)
         {
            this.avEditor.sortPopup.visible = !this.avEditor.sortPopup.visible;
         }
         else
         {
            this._tradeSort.visible = !this._tradeSort.visible;
         }
      }
      
      private function sortBtnHandler(evt:MouseEvent) : void
      {
         var buildArray:Array = null;
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         var currListView:int = this.CLOTHING_VIEW_TYPE;
         if(evt.currentTarget.name == this.avEditor.sortPopup.sort8.name)
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullHeadItems;
               _tradeClothingSortType = 8;
            }
            else
            {
               buildArray = this._currClothesArray = this._headItems;
               _mainClothingSortType = 8;
            }
         }
         else if(evt.currentTarget.name == this.avEditor.sortPopup.sort7.name)
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullNeckItems;
               _tradeClothingSortType = 7;
            }
            else
            {
               buildArray = this._currClothesArray = this._neckItems;
               _mainClothingSortType = 7;
            }
         }
         else if(evt.currentTarget.name == (this.avEditor.sortPopup.sort6.name || this._tradeSort.sort6.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullBackItems;
               _tradeClothingSortType = 6;
            }
            else
            {
               buildArray = this._currClothesArray = this._backItems;
               _mainClothingSortType = 6;
            }
         }
         else if(evt.currentTarget.name == (this.avEditor.sortPopup.sort5.name || this._tradeSort.sort5.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               buildArray = this._currDenItemsArray = this._floorItems;
               currListView = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 5;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullLegItems;
               _tradeClothingSortType = 5;
            }
            else
            {
               buildArray = this._currClothesArray = this._legItems;
               _mainClothingSortType = 5;
            }
         }
         else if(evt.currentTarget.name == (this.avEditor.sortPopup.sort4.name || this._tradeSort.sort4.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               buildArray = this._currDenItemsArray = this._themeItems;
               currListView = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 4;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullTailItems;
               _tradeClothingSortType = 4;
            }
            else
            {
               buildArray = this._currClothesArray = this._tailItems;
               _mainClothingSortType = 4;
            }
         }
         else if(evt.currentTarget.name == (this.avEditor.sortPopup.sort3.name || this._tradeSort.sort3.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               buildArray = this._currDenItemsArray = this._itemTypeDenItems;
               currListView = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 3;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullItemTypeItems;
               _tradeClothingSortType = 3;
            }
            else
            {
               buildArray = this._currClothesArray = this._itemTypeItems;
               _mainClothingSortType = 3;
            }
         }
         else if(evt.currentTarget.name == (this.avEditor.sortPopup.sort2.name || this._tradeSort.sort2.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               buildArray = this._currDenItemsArray = this._allNewestDenItems;
               currListView = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 2;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullallNewestClothes;
               _tradeClothingSortType = 2;
            }
            else
            {
               buildArray = this._currClothesArray = this._allNewestClothes;
               _mainClothingSortType = 2;
            }
         }
         else if(evt.currentTarget.name == (this.avEditor.sortPopup.sort1.name || this._tradeSort.sort1.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               buildArray = this._currDenItemsArray = this._allOldestDenItems;
               currListView = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 1;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               buildArray = this._fullClothesList = this._fullAllOldestClothes;
               _tradeClothingSortType = 1;
            }
            else
            {
               buildArray = this._currClothesArray = this._allOldestClothes;
               _mainClothingSortType = 1;
            }
         }
         else if(evt.currentTarget.name == this.avEditor.sortPopup.bg.name)
         {
            this.avEditor.sortPopup.visible = !this.avEditor.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         if(Boolean(buildArray))
         {
            if(this._tradeWindow.visible)
            {
               if(Boolean(this._mainScrollbar))
               {
                  if(currListView == this.CLOTHING_VIEW_TYPE)
                  {
                     _tradeClothingScrollYPosition = 0;
                  }
                  else
                  {
                     _tradeDenScrollYPosition = 0;
                  }
               }
               this._tradeSort.visible = !this._tradeSort.visible;
               if(currListView == this.CLOTHING_VIEW_TYPE)
               {
                  this._tradeClothingWindows.destroy();
                  this._tradeClothingWindows = null;
               }
               else
               {
                  this._tradeDenWindows.destroy();
                  this._tradeDenWindows = null;
               }
               this.createItemWindows(buildArray,this._tradeWindow.itemBlock);
            }
            else
            {
               if(currListView == this.CLOTHING_VIEW_TYPE)
               {
                  this._itemClothingWindows.destroy();
                  this._itemClothingWindows = null;
               }
               else
               {
                  this._itemTradeWindows.destroy();
                  this._itemTradeWindows = null;
               }
               _mainScrollYPosition = 0;
               this._mainScrollbar.destroy();
               this._mainScrollbar = null;
               this.avEditor.sortPopup.visible = !this.avEditor.sortPopup.visible;
               this.createItemWindows(buildArray,this.avEditor.itemBlock);
            }
         }
      }
      
      private function clothesDenAndTradeHandler(e:MouseEvent) : void
      {
         e.stopPropagation();
         if(!this._tradeWindow.visible && e.currentTarget.name == this.avEditor.clothesBtnDown.name)
         {
            if(e.currentTarget.name == this.avEditor.clothesBtnDown.name)
            {
               this._currClothesArray = this.convertIntToList(_mainClothingSortType,true,false);
            }
            this.avEditor.tradeBtnUp.visible = false;
            this.avEditor.tradeBtnDown.visible = true;
            this.avEditor.clothesBtnUp.visible = true;
            this.avEditor.clothesBtnDown.visible = false;
            this.avEditor.sortBtn.visible = true;
            this.avEditor.itemCounter.visible = true;
            this.avEditor.infoBtn.visible = false;
            this.avEditor.howTxt.visible = false;
            LocalizationManager.translateId(this.avEditor.sortPopup.sort8.txt,11205);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort7.txt,11206);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort6.txt,11207);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort5.txt,11208);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort4.txt,11209);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort3.txt,11210);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort2.txt,11211);
            LocalizationManager.translateId(this.avEditor.sortPopup.sort1.txt,11212);
            this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
         }
         else if(!this._tradeWindow.visible && e.currentTarget.name == this.avEditor.tradeBtnDown.name)
         {
            if(Boolean(this.avEditor.tradeBtnDown.isGray))
            {
               return;
            }
            if(e.currentTarget.name == this.avEditor.tradeBtnDown.name)
            {
               this._currClothesArray = this.convertIntToList(_mainClothingSortType,true,false);
            }
            this.avEditor.tradeBtnUp.visible = true;
            this.avEditor.tradeBtnDown.visible = false;
            this.avEditor.clothesBtnUp.visible = false;
            this.avEditor.clothesBtnDown.visible = true;
            this.avEditor.sortBtn.visible = false;
            this.avEditor.itemCounter.visible = false;
            this.avEditor.infoBtn.visible = true;
            this.avEditor.howTxt.visible = true;
            if(!gMainFrame.userInfo.userVarCache.isBitSet(AchievementXtCommManager.UV_TRADING,0))
            {
               this.avEditor.tradeHelpPopup.visible = true;
               LocalizationManager.translateId(this.avEditor.tradeHelpPopup.txt,11217);
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TRADING,0);
            }
            this.createItemWindows(this._currTradesArray,this.avEditor.itemBlock,true);
         }
         else if(this._tradeWindow.visible && e.currentTarget.name == this._tradeWindow.clothesBtnDown.name)
         {
            this._tradeWindow.denBtnUp.visible = false;
            this._tradeWindow.denBtnDown.visible = true;
            this._tradeWindow.clothesBtnUp.visible = true;
            this._tradeWindow.clothesBtnDown.visible = false;
            LocalizationManager.translateId(this._tradeSort.sort8.txt,11205);
            LocalizationManager.translateId(this._tradeSort.sort7.txt,11206);
            LocalizationManager.translateId(this._tradeSort.sort6.txt,11207);
            LocalizationManager.translateId(this._tradeSort.sort5.txt,11208);
            LocalizationManager.translateId(this._tradeSort.sort4.txt,11209);
            LocalizationManager.translateId(this._tradeSort.sort3.txt,11210);
            LocalizationManager.translateId(this._tradeSort.sort2.txt,11211);
            LocalizationManager.translateId(this._tradeSort.sort1.txt,11212);
            this._tradeSort.sort5.visible = true;
            this._tradeSort.sort6.visible = true;
            this._tradeSort.sort7.visible = true;
            this._tradeSort.sort8.visible = true;
            if(Boolean(this._mainScrollbar))
            {
               if(_tradeListViewType == this.DEN_VIEW_TYPE)
               {
                  _tradeDenScrollYPosition = this._mainScrollbar.scrollYValue;
               }
            }
            _tradeListViewType = this.CLOTHING_VIEW_TYPE;
            this._fullClothesList = this.convertIntToList(_tradeClothingSortType,true);
            this.createItemWindows(this._fullClothesList,this._tradeWindow.itemBlock);
         }
         else if(this._tradeWindow.visible && e.currentTarget.name == this._tradeWindow.denBtnDown.name)
         {
            this._tradeWindow.denBtnUp.visible = true;
            this._tradeWindow.denBtnDown.visible = false;
            this._tradeWindow.clothesBtnUp.visible = false;
            this._tradeWindow.clothesBtnDown.visible = true;
            LocalizationManager.translateId(this._tradeSort.sort4.txt,11215);
            LocalizationManager.translateId(this._tradeSort.sort3.txt,11216);
            LocalizationManager.translateId(this._tradeSort.sort2.txt,11211);
            LocalizationManager.translateId(this._tradeSort.sort1.txt,11212);
            this._tradeSort.sort5.visible = false;
            this._tradeSort.sort6.visible = false;
            this._tradeSort.sort7.visible = false;
            this._tradeSort.sort8.visible = false;
            if(Boolean(this._mainScrollbar))
            {
               if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  _tradeClothingScrollYPosition = this._mainScrollbar.scrollYValue;
               }
            }
            _tradeListViewType = this.DEN_VIEW_TYPE;
            this._currDenItemsArray = this.convertIntToList(_tradeDenSortType,false);
            this.createItemWindows(this._currDenItemsArray,this._tradeWindow.itemBlock);
         }
      }
      
      private function onCloseTradeWindow(e:MouseEvent) : void
      {
         e.stopPropagation();
         this._tradeWindow.visible = !this._tradeWindow.visible;
         this.avEditor.blackoutFull.visible = !this.avEditor.blackoutFull.visible;
         if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
         {
            _tradeClothingScrollYPosition = this._mainScrollbar.scrollYValue;
         }
         else
         {
            _tradeDenScrollYPosition = this._mainScrollbar.scrollYValue;
         }
      }
      
      private function blockMouseBlockerHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onCloseTradeHelpPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.avEditor.tradeHelpPopup.visible = false;
      }
      
      private function onInfoBtnDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(22);
      }
      
      private function onNameBarPopupClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.avEditor.namebarPopup.visible = false;
      }
      
      private function onColorNameBar(evt:MouseEvent) : void
      {
         var currFrameName:String = null;
         evt.stopPropagation();
         if(!this._userInfo.isMember || this._worldAvatar.isShaman || this._userInfo.isGuide)
         {
            UpsellManager.displayPopup(UpsellManager.NAMEBARS,"namebarColor");
            return;
         }
         this._nameBarData = (this._nameBarData & 0xFFFF00) + evt.currentTarget.id;
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(this._worldAvatar.userName);
         this.avEditor.member.setColorBadgeAndXp(this._nameBarData,ai.questLevel,ai.isMember);
         this.avEditor.member.setAvName(this._worldAvatar.avName,false);
         if(ai.questLevel > 0)
         {
            currFrameName = this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.currentLabels[Utility.getColorId(this._nameBarData) - 1].name;
            this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.gotoAndStop(currFrameName);
            Utility.createXpShape(ai.questLevel,ai.isMember,this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape[currFrameName].mouse.up.icon,null,int.MAX_VALUE);
         }
         this.createNamebarIconWindows();
      }
      
      private function onNameBarPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onMemberNameBar(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnClick();
         this.avEditor.namebarPopup.visible = !this.avEditor.namebarPopup.visible;
         if(Boolean(this.avEditor.namebarPopup.visible))
         {
            if(this._namebarBadgeImages.length > 0)
            {
               this.createNamebarIconWindows();
            }
            else
            {
               GenericListXtCommManager.requestGenericList(GuiManager.NAME_BAR_ICONS_LIST_ID,this.onNamebarBadgeIdsLoaded);
            }
         }
      }
      
      private function onMemberNameBarOver(evt:MouseEvent) : void
      {
         if(this._isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onAdvIconToggle(evt:MouseEvent) : void
      {
         var ai:AvatarInfo = null;
         evt.stopPropagation();
         if(Boolean(gMainFrame.userInfo.isMember) || this._worldAvatar.isShaman || this._userInfo.isGuide)
         {
            if(evt.currentTarget.currentLabel == "off" || evt.currentTarget.currentLabel == "startingOff")
            {
               evt.currentTarget.gotoAndPlay("on");
               this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = true;
            }
            else
            {
               evt.currentTarget.gotoAndPlay("off");
               this.avEditor.namebarPopup.advLockToggle.toggleBtn.shape.visible = false;
            }
            if(this._nameBarData != -1)
            {
               this._nameBarData = (this._nameBarData & 0xFFFF) + ((evt.currentTarget.currentLabel == "off" ? 1 : 0) << 16);
            }
            else
            {
               this._nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0xFFFF) + ((evt.currentTarget.currentLabel == "off" ? 1 : 0) << 16);
            }
            ai = gMainFrame.userInfo.getAvatarInfoByUserName(this._worldAvatar.userName);
            this.avEditor.member.setColorBadgeAndXp(this._nameBarData,ai.questLevel,ai.isMember);
         }
         else
         {
            UpsellManager.displayPopup(UpsellManager.NAMEBARS,"nameBarAdvIcon");
         }
      }
      
      private function onAdvIconToggleOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.toggleBG.currentFrameLabel != "over")
         {
            evt.currentTarget.toggleBG.gotoAndStop("over");
         }
         if(evt.currentTarget.toggleKnob.currentFrameLabel != "over")
         {
            evt.currentTarget.toggleKnob.gotoAndStop("over");
         }
      }
      
      private function onAdvIconToggleOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(evt.currentTarget.toggleBG.currentFrameLabel != "up")
         {
            evt.currentTarget.toggleBG.gotoAndStop("up");
         }
         if(evt.currentTarget.toggleKnob.currentFrameLabel != "up")
         {
            evt.currentTarget.toggleKnob.gotoAndStop("up");
         }
      }
      
      private function onNamebarBadgeIdsLoaded(namebarDefIds:Array) : void
      {
         var badgeDef:Object = null;
         this._namebarBadgeDefs = [];
         this._namebarBadgeMediaIds = [];
         for(var i:int = 0; i < namebarDefIds.length; i++)
         {
            badgeDef = GuiManager.getNamebarBadgeDef(namebarDefIds[i]);
            if(Boolean(badgeDef) && (badgeDef.pendingFlagsBit == 0 || Boolean(gMainFrame.userInfo.isPendingFlagSet(badgeDef.pendingFlagsBit))))
            {
               this._namebarBadgeDefs.push(badgeDef);
               this._namebarBadgeMediaIds.push(badgeDef.mediaRefId);
            }
         }
         this.createNamebarIconWindows();
      }
      
      private function onNamebarIconsLoaded(mc1:MovieClip, mc2:MovieClip, index:int) : void
      {
         if(Boolean(mc1) && Boolean(mc2))
         {
            this._namebarBadgeImages[index] = {
               "iconMouse":mc1,
               "iconUp":mc2
            };
         }
      }
      
      private function createNamebarIconWindows() : void
      {
         var listToLoad:Array = null;
         var loadIcons:Boolean = false;
         if(Boolean(this._nameBarScrollBar))
         {
            this._nameBarScrollBar.destroy();
            this._nameBarScrollBar = null;
         }
         if(Boolean(this._nameBarItemWindows))
         {
            this._nameBarItemWindows.destroy();
            this._nameBarItemWindows = null;
         }
         while(this.avEditor.namebarPopup.itemWindow.numChildren > 0)
         {
            this.avEditor.namebarPopup.itemWindow.removeChildAt(0);
         }
         if(Boolean(this._namebarBadgeImages) && Boolean(this._namebarBadgeImages.length > 0) && this._namebarBadgeImages[0] != null)
         {
            listToLoad = this._namebarBadgeImages;
         }
         else
         {
            listToLoad = this._namebarBadgeMediaIds;
            loadIcons = true;
         }
         this._nameBarItemWindows = new WindowGenerator();
         this._nameBarItemWindows.init(5,7,listToLoad.length,4,5,5,ItemWindowNameBarIcon,listToLoad,"",{
            "mouseDown":this.onNamebarBadgeIconDown,
            "mouseOver":this.onNamebarBadgeIconOver,
            "mouseOut":this.onNamebarBadgeIconOut
         },{
            "currFrameLabel":this.avEditor.member["e"].currentLabel,
            "loadIcons":loadIcons,
            "callbackFunction":this.onNamebarIconsLoaded
         },this.onIconWindowwsLoaded,false,false);
      }
      
      private function onIconWindowwsLoaded() : void
      {
         this.avEditor.namebarPopup.itemWindow.addChild(this._nameBarItemWindows);
         this._nameBarScrollBar = new SBScrollbar();
         this._nameBarScrollBar.init(this._nameBarItemWindows,this._nameBarItemWindows.width,this._nameBarItemWinHeight,8,"scrollbar2",this._nameBarItemWindows.boxHeight + 4);
      }
      
      private function onNamebarBadgeIconOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         AJAudio.playSubMenuBtnRollover();
         evt.currentTarget.mouse.gotoAndStop(3);
      }
      
      private function onNamebarBadgeIconOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.mouse.gotoAndStop(1);
      }
      
      private function onNamebarBadgeIconDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!gMainFrame.userInfo.isMember || this._worldAvatar.isShaman || this._userInfo.isGuide)
         {
            UpsellManager.displayPopup(UpsellManager.NAMEBARS,"namebarIcon");
            return;
         }
         var badgeDef:Object = this._namebarBadgeDefs[evt.currentTarget.index];
         if(!badgeDef || !gMainFrame.userInfo.isPendingFlagSet(badgeDef.pendingFlagsBit))
         {
            return;
         }
         var badgeId:int = badgeDef.defId - 1;
         if(this._nameBarData != -1)
         {
            this._nameBarData = (this._nameBarData & 0xFF00FF) + (badgeId << 8);
         }
         else
         {
            this._nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0xFF00FF) + (badgeId << 8);
         }
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(this._worldAvatar.userName);
         this.avEditor.member.setColorBadgeAndXp(this._nameBarData,ai.questLevel,ai.isMember);
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onStatsBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.avEditor.statsPanel.visible = !this.avEditor.statsPanel.visible;
         this.avEditor.currencyBar.visible = !this.avEditor.currencyBar.visible;
         this.avEditor.colorTableBlock.visible = !this.avEditor.colorTableBlock.visible;
         this.avEditor.colorCont.visible = !this.avEditor.colorCont.visible;
      }
      
      private function onStatsBtnOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this.avEditor.statsBtn.isGray))
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(evt.currentTarget),LocalizationManager.translateIdOnly(14627),0,-45,true);
         GuiManager.toolTip.startTimer(evt);
      }
      
      private function convertIntToList(i:int, isClothing:Boolean, isFullList:Boolean = true) : Array
      {
         var a:Array = null;
         if(isClothing)
         {
            switch(i)
            {
               case 1:
                  if(isFullList)
                  {
                     a = this._fullAllOldestClothes;
                  }
                  else
                  {
                     a = this._allOldestClothes;
                  }
                  break;
               case 2:
                  if(isFullList)
                  {
                     a = this._fullallNewestClothes;
                  }
                  else
                  {
                     a = this._allNewestClothes;
                  }
                  break;
               case 3:
                  if(isFullList)
                  {
                     a = this._fullItemTypeItems;
                  }
                  else
                  {
                     a = this._itemTypeItems;
                  }
                  break;
               case 4:
                  if(isFullList)
                  {
                     a = this._fullTailItems;
                  }
                  else
                  {
                     a = this._tailItems;
                  }
                  break;
               case 5:
                  if(isFullList)
                  {
                     a = this._fullLegItems;
                  }
                  else
                  {
                     a = this._legItems;
                  }
                  break;
               case 6:
                  if(isFullList)
                  {
                     a = this._fullBackItems;
                  }
                  else
                  {
                     a = this._backItems;
                  }
                  break;
               case 7:
                  if(isFullList)
                  {
                     a = this._fullNeckItems;
                  }
                  else
                  {
                     a = this._neckItems;
                  }
                  break;
               case 8:
                  if(isFullList)
                  {
                     a = this._fullHeadItems;
                  }
                  else
                  {
                     a = this._headItems;
                  }
            }
         }
         else
         {
            switch(i)
            {
               case 1:
                  a = this._allOldestDenItems;
                  break;
               case 2:
                  a = this._allNewestDenItems;
                  break;
               case 3:
                  a = this._itemTypeDenItems;
                  break;
               case 4:
                  a = this._themeItems;
                  break;
               case 5:
                  a = this._floorItems;
            }
         }
         return a;
      }
      
      private function addListeners() : void
      {
         this.avEditor.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this.xBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this.block.addEventListener(MouseEvent.MOUSE_DOWN,this.blockMouseBlockerHandler,false,0,true);
         this.block.addEventListener(MouseEvent.ROLL_OUT,this.blockMouseBlockerHandler,false,0,true);
         this.block.addEventListener(MouseEvent.ROLL_OVER,this.blockMouseBlockerHandler,false,0,true);
         this.avEditor.petsBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetBtnHandler,false,0,true);
         this.avEditor.petsBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onPetBtnOverHandler,false,0,true);
         this.avEditor.petsBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onPetBtnOutHandler,false,0,true);
         this.avEditor.shopBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onShopBtnHandler,false,0,true);
         this.avEditor.shopBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onShopBtnOverHandler,false,0,true);
         this.avEditor.shopBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onShopBtnOutHandler,false,0,true);
         this.avEditor.sortBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sortByHandler,false,0,true);
         this._tradeWindow.sortBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.sortByHandler,false,0,true);
         this.avEditor.sortPopup.sort8.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort7.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort6.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort5.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort4.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort3.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort2.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.sort1.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.sortPopup.bg.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort8.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort7.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort6.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort5.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort4.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort3.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort2.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this._tradeSort.sort1.addEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler,false,0,true);
         this.avEditor.colorsTabDnBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.colorTableTabClick,false,0,true);
         this.avEditor.colorsTabDnBtn.addEventListener(MouseEvent.MOUSE_OVER,this.colorTableTabOverClick,false,0,true);
         this.avEditor.colorsTabDnBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this.avEditor.patternTabDnBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.colorTableTabClick,false,0,true);
         this.avEditor.patternTabDnBtn.addEventListener(MouseEvent.MOUSE_OVER,this.colorTableTabOverClick,false,0,true);
         this.avEditor.patternTabDnBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this.avEditor.eyesTabDnBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.colorTableTabClick,false,0,true);
         this.avEditor.eyesTabDnBtn.addEventListener(MouseEvent.MOUSE_OVER,this.colorTableTabOverClick,false,0,true);
         this.avEditor.eyesTabDnBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         this._lArrowBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler,false,0,true);
         this._rArrowBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler,false,0,true);
         this.avEditor.clothesBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         this.avEditor.clothesBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         if(Utility.canTrade())
         {
            this.avEditor.tradeBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
            this.avEditor.tradeBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         }
         else
         {
            this.avEditor.tradeBtnDown.activateGrayState(true);
         }
         this._tradeWindow.denBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         this._tradeWindow.denBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         this._tradeWindow.clothesBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         this._tradeWindow.clothesBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler,false,0,true);
         this._tradeWindow["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseTradeWindow,false,0,true);
         this.avEditor.tradeHelpPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onCloseTradeHelpPopup,false,0,true);
         this.avEditor.infoBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onInfoBtnDown,false,0,true);
         this.avEditor.namebarPopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onNameBarPopup,false,0,true);
         this.avEditor.namebarPopup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onNameBarPopupClose,false,0,true);
         for(var i:int = 0; i < this._nameBars.length; i++)
         {
            this.avEditor.namebarPopup[this._nameBars[i]].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorNameBar,false,0,true);
         }
         this.avEditor.member.addEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar,false,0,true);
         this.avEditor.member.addEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver,false,0,true);
         this.avEditor.nonmember.addEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar,false,0,true);
         this.avEditor.nonmember.addEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver,false,0,true);
         this.avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAdvIconToggle,false,0,true);
         this.avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onAdvIconToggleOver,false,0,true);
         this.avEditor.namebarPopup.advLockToggle.toggleBtn.addEventListener(MouseEvent.MOUSE_OUT,this.onAdvIconToggleOut,false,0,true);
         this.avEditor.recycleClothesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onRecycleClothesBtn,false,0,true);
         this.avEditor.recycleClothesBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onRecycleClothesBtnOver,false,0,true);
         this.avEditor.recycleClothesBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         if(this._isInQuest)
         {
            this.avEditor.statsBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onStatsBtn,false,0,true);
            this.avEditor.statsBtn.addEventListener(MouseEvent.MOUSE_OVER,this.onStatsBtnOver,false,0,true);
            this.avEditor.statsBtn.addEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler,false,0,true);
         }
      }
      
      private function removeListeners() : void
      {
         var i:int = 0;
         this.avEditor.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this.xBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this.block.removeEventListener(MouseEvent.MOUSE_DOWN,this.blockMouseBlockerHandler);
         this.block.removeEventListener(MouseEvent.ROLL_OUT,this.blockMouseBlockerHandler);
         this.block.removeEventListener(MouseEvent.ROLL_OVER,this.blockMouseBlockerHandler);
         this.avEditor.petsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPetBtnHandler);
         this.avEditor.petsBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onPetBtnOverHandler);
         this.avEditor.petsBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onPetBtnOutHandler);
         this.avEditor.shopBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onShopBtnHandler);
         this.avEditor.shopBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onShopBtnOverHandler);
         this.avEditor.shopBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onShopBtnOutHandler);
         this.avEditor.sortBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortByHandler);
         this._tradeWindow.sortBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortByHandler);
         this.avEditor.sortPopup.sort8.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort7.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort6.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort5.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort4.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort3.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort2.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.sort1.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.sortPopup.bg.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort8.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort7.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort6.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort5.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort4.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort3.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort2.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this._tradeSort.sort1.removeEventListener(MouseEvent.MOUSE_DOWN,this.sortBtnHandler);
         this.avEditor.colorsTabDnBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.colorTableTabClick);
         this.avEditor.colorsTabDnBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.colorTableTabOverClick);
         this.avEditor.colorsTabDnBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.avEditor.patternTabDnBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.colorTableTabClick);
         this.avEditor.eyesTabDnBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.colorTableTabOverClick);
         this.avEditor.eyesTabDnBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this.avEditor.eyesTabDnBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.colorTableTabClick);
         this.avEditor.eyesTabDnBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.colorTableTabOverClick);
         this.avEditor.eyesTabDnBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         this._lArrowBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler);
         this._rArrowBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.arrowBtnHandler);
         this.avEditor.clothesBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         this.avEditor.clothesBtnDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         if(Utility.canTrade())
         {
            this.avEditor.tradeBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
            this.avEditor.tradeBtnDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         }
         this._tradeWindow.denBtnDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         this._tradeWindow.denBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         this._tradeWindow.clothesBtnDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         this._tradeWindow.clothesBtnUp.removeEventListener(MouseEvent.MOUSE_DOWN,this.clothesDenAndTradeHandler);
         this._tradeWindow["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseTradeWindow);
         this.avEditor.tradeHelpPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onCloseTradeHelpPopup);
         this.avEditor.infoBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInfoBtnDown);
         this.avEditor.namebarPopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onNameBarPopup);
         this.avEditor.namebarPopup["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onNameBarPopupClose);
         if(Boolean(this._nameBars))
         {
            for(i = 0; i < this._nameBars.length; i++)
            {
               this.avEditor.namebarPopup[this._nameBars[i]].removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorNameBar);
            }
         }
         this.avEditor.member.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar);
         this.avEditor.nonmember.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar);
         this.avEditor.member.removeEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver);
         this.avEditor.nonmember.removeEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver);
         this.avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAdvIconToggle);
         this.avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onAdvIconToggleOver);
         this.avEditor.namebarPopup.advLockToggle.toggleBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.onAdvIconToggleOut);
         this.avEditor.recycleClothesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onRecycleClothesBtn);
         this.avEditor.recycleClothesBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onRecycleClothesBtnOver);
         this.avEditor.recycleClothesBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         if(this._isInQuest)
         {
            this.avEditor.statsBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStatsBtn);
            this.avEditor.statsBtn.removeEventListener(MouseEvent.MOUSE_OVER,this.onStatsBtnOver);
            this.avEditor.statsBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.btnOutHandler);
         }
      }
   }
}

