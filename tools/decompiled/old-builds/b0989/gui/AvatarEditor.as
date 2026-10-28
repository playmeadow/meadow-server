package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarEditorView;
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
   import pet.GuiPet;
   import pet.PetManager;
   
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
      
      private const CT_HEIGHT:int = 120;
      
      private const CT_NUM_COLS:int = 10;
      
      private const CT_NUM_ROWS:int = 4;
      
      private const CT_Y_TOP:int = 41;
      
      private const CT_Y_BOT:int = 205;
      
      private const CT_X:int = 20;
      
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
      
      private var _numAvatarNamesToLoad:int;
      
      private var _numAvatarNamesLoaded:int;
      
      private var _avatarNamesString:String;
      
      public function AvatarEditor()
      {
         super();
      }
      
      public function init(param1:Avatar, param2:DisplayLayer, param3:Boolean = true, param4:Function = null, param5:Boolean = false) : void
      {
         DarkenManager.showLoadingSpiral(true);
         this._worldAvatar = param1;
         this._makePopup = param3;
         this._onCloseCallback = param4;
         this._guiLayer = param2;
         this._isFFM = param5;
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
         if(this._currClothesArray)
         {
            this._currClothesArray = this.convertIntToList(_mainClothingSortType,true,false);
         }
         this._fullClothesList = this._fullallNewestClothes = gMainFrame.userInfo.playerAvatarInfo.getFullItems();
         if(this._fullClothesList)
         {
            this._fullHeadItems = Utility.sortItemsAll(this._fullClothesList,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
            this._fullNeckItems = Utility.sortItemsAll(this._fullClothesList,0,Item.NECK_LAYER);
            this._fullBackItems = Utility.sortItemsAll(this._fullClothesList,0,Item.BACK_LAYER);
            this._fullLegItems = Utility.sortItemsAll(this._fullClothesList,0,Item.LEG_LAYER);
            this._fullTailItems = Utility.sortItemsAll(this._fullClothesList,0,Item.TAIL_LAYER);
            this._fullItemTypeItems = Utility.sortByItem(this._fullClothesList,0);
            this._fullAllOldestClothes = this._fullallNewestClothes.concat().reverse();
         }
         if(param1.inventoryDenFull.itemArray)
         {
            this._currDenItemsArray = this._allNewestDenItems = this.discardAudioItems(param1.inventoryDenFull.itemArray);
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
         var _loc1_:LoadingSpiral = null;
         DarkenManager.showLoadingSpiral(false);
         KeepAlive.stopKATimer(this.avEditor);
         this.removeListeners();
         if(this._mainScrollbar)
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
         if(this._itemClothingWindows)
         {
            this._itemClothingWindows.destroy();
            this._itemClothingWindows = null;
         }
         if(this._itemTradeWindows)
         {
            this._itemTradeWindows.destroy();
            this._itemTradeWindows = null;
         }
         if(this._tradeClothingWindows)
         {
            this._tradeClothingWindows.destroy();
            this._tradeClothingWindows = null;
         }
         if(this._tradeDenWindows)
         {
            this._tradeDenWindows.destroy();
            this._tradeDenWindows = null;
         }
         if(this._avatarEditorView)
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
         if(this._myPet)
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
         if(this._nameBarScrollBar)
         {
            this._nameBarScrollBar.destroy();
         }
         if(this._nameBarItemWindows)
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
            for each(_loc1_ in this._spirals)
            {
               _loc1_.destroy();
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
      
      public function set onCloseCallback(param1:Function) : void
      {
         this._onCloseCallback = param1;
      }
      
      private function onMediaItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this.avEditor = MovieClip(param1.getChildAt(0));
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
            if(this._currClothesArray)
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
            if(this._isFFM)
            {
               GuiManager.setFFMAvatarEditor();
            }
         }
      }
      
      private function setInitAssetVisibility() : void
      {
         this.avEditor.colorTableBlock.patternsAndEyes.visible = false;
         var _loc1_:Array = this._avatarEditorView.colors;
         var _loc2_:int = _loc1_[0] >> 24 & 0xFF;
         var _loc3_:int = _loc1_[0] >> 16 & 0xFF;
         var _loc4_:int = _loc1_[1] >> 24 & 0xFF;
         var _loc5_:int = _loc1_[2] >> 24 & 0xFF;
         this._colorTableColor1 = new ColorTable();
         this._colorTableColor1.init(this.CT_ID_C1,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette1,_loc2_,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTableColor2 = new ColorTable();
         this._colorTableColor2.init(this.CT_ID_C2,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette2,_loc3_,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTablePatterns = new ColorTable();
         this._colorTablePatterns.init(this.CT_ID_PATT,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette1,_loc4_,this.onColorChanged,this.CT_SECRET_COLOR);
         this._colorTableEyes = new ColorTable();
         this._colorTableEyes.init(this.CT_ID_EYES,this.CT_WIDTH,this.CT_HEIGHT,this.CT_NUM_COLS,this.CT_NUM_ROWS,this._gamePalette,this._avatarPalette1,_loc5_,this.onColorChanged,this.CT_SECRET_COLOR);
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
         this.avEditor.sortPopup.sort8.txt.text = "Head";
         this.avEditor.sortPopup.sort7.txt.text = "Neck";
         this.avEditor.sortPopup.sort6.txt.text = "Back";
         this.avEditor.sortPopup.sort5.txt.text = "Legs";
         this.avEditor.sortPopup.sort4.txt.text = "Tail";
         this.avEditor.sortPopup.sort3.txt.text = "Item";
         this.avEditor.sortPopup.sort2.txt.text = "All Newest";
         this.avEditor.sortPopup.sort1.txt.text = "All Oldest";
         this.avEditor.clothesBtnUp.visible = true;
         this.avEditor.clothesBtnDown.visible = false;
         this.avEditor.tradeBtnUp.visible = false;
         this.avEditor.tradeBtnDown.visible = this._fullClothesList ? true : false;
         this._tradeWindow.visible = false;
         this.avEditor.blackout.visible = false;
         this.avEditor.patternTabUp.visible = false;
         this.avEditor.eyesTabUp.visible = false;
         this.avEditor.sortPopup.visible = false;
         this.avEditor.tradeHelpPopup.visible = false;
         this.avEditor.infoBtn.visible = false;
         this.avEditor.howTxt.visible = false;
         this.avEditor.currencyBar.visible = false;
         this.avEditor.statsPanel.visible = false;
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
         var _loc6_:int = 0;
         while(_loc6_ < this._nameBars.length)
         {
            this.avEditor.namebarPopup[this._nameBars[_loc6_]].txt.text = this._worldAvatar.avName;
            this.avEditor.namebarPopup[this._nameBars[_loc6_]].id = _loc6_;
            _loc6_++;
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
            this.avEditor.nonmember.visible = false;
            this.avEditor.member.visible = true;
            this.avEditor.member.setNubType(NameBar.BUDDY,false);
            this.avEditor.member.isBlocked = false;
            if(!this._worldAvatar.isShaman && !this._userInfo.isGuide)
            {
               this.avEditor.member.setColorAndBadge(gMainFrame.userInfo.playerUserInfo.nameBarData);
            }
            else
            {
               this.avEditor.member.setColorAndBadge(0);
            }
            this.avEditor.member.setAvName(this._worldAvatar.avName,false);
         }
         if(this._isFFM)
         {
            if(this.avEditor.petsBtn.hasGrayState)
            {
               this.avEditor.petsBtn.activateGrayState(true);
            }
            if(this.avEditor.shopBtn.hasGrayState)
            {
               this.avEditor.shopBtn.activateGrayState(true);
            }
            if(this.avEditor.recycleClothesBtn.hasGrayState)
            {
               this.avEditor.recycleClothesBtn.activateGrayState(true);
            }
            if(this.avEditor.sortBtn.hasGrayState)
            {
               this.avEditor.sortBtn.activateGrayState(true);
            }
            if(this.avEditor.tradeBtnDown.hasGrayState)
            {
               this.avEditor.tradeBtnDown.activateGrayState(true);
            }
         }
         this.avEditor.statsBtn.visible = false;
         this.avEditor.itemCounter.counterTxt.text = this._allNewestClothes.length + "/" + Shop.maxItems;
      }
      
      private function positionAndDrawAvatarView(param1:Boolean = false) : void
      {
         if(param1)
         {
            if(Boolean(this._avatarEditorView) && Boolean(this._avatarEditorView.parent))
            {
               this.avEditor.charBox.removeChild(this._avatarEditorView);
            }
            this._avatarEditorView = new AvatarEditorView();
            this._avatarEditorView.init(this._worldAvatar);
         }
         var _loc2_:Point = AvatarUtility.getAvatarViewPosition(this._avatarEditorView.avTypeId);
         this._avatarEditorView.x = _loc2_.x;
         this._avatarEditorView.y = _loc2_.y;
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
      
      private function onColorChanged(param1:int, param2:int) : void
      {
         var _loc4_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:uint = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc3_:Array = this._avatarEditorView.colors;
         _loc4_ = uint(_loc3_[0]);
         _loc5_ = uint(_loc3_[1]);
         _loc6_ = uint(_loc3_[2]);
         switch(param1)
         {
            case this.CT_ID_C1:
            case this.CT_ID_C2:
               _loc9_ = _loc4_ >> 8 & 0xFF;
               _loc10_ = _loc4_ & 0xFF;
               if(param1 == this.CT_ID_C1)
               {
                  _loc7_ = param2;
                  _loc8_ = _loc4_ >> 16 & 0xFF;
               }
               else
               {
                  _loc7_ = _loc4_ >> 24 & 0xFF;
                  _loc8_ = param2;
               }
               _loc4_ = uint(_loc7_ << 24 | _loc8_ << 16 | _loc9_ << 8 | _loc10_);
               break;
            case this.CT_ID_PATT:
               _loc11_ = param2;
               _loc12_ = _loc5_ >> 16 & 0xFF;
               _loc13_ = _loc5_ >> 8 & 0xFF;
               _loc14_ = _loc5_ & 0xFF;
               _loc5_ = uint(_loc11_ << 24 | _loc12_ << 16 | _loc13_ << 8 | _loc14_);
               break;
            case this.CT_ID_EYES:
               _loc15_ = param2;
               _loc16_ = _loc6_ >> 16 & 0xFF;
               _loc17_ = _loc6_ >> 8 & 0xFF;
               _loc18_ = _loc6_ & 0xFF;
               _loc6_ = uint(_loc15_ << 24 | _loc16_ << 16 | _loc17_ << 8 | _loc18_);
         }
         this._avatarEditorView.colors = [_loc4_,_loc5_,_loc6_];
         if(param1 == this.CT_ID_EYES || param1 == this.CT_ID_PATT)
         {
            this.colorCurrEyePattIcon();
         }
      }
      
      private function loadPetView() : void
      {
         var _loc1_:Array = null;
         var _loc2_:int = 0;
         var _loc3_:Object = null;
         if(gMainFrame.clientInfo.roomType != Utility.ROOMTYPE_QUEST)
         {
            _loc1_ = PetManager.myPetList;
            while(this.avEditor.itemWindowPet2.numChildren > 0)
            {
               this.avEditor.itemWindowPet2.removeChildAt(0);
            }
            while(this.avEditor.itemWindowPet1.numChildren > 0)
            {
               this.avEditor.itemWindowPet1.removeChildAt(0);
            }
            _loc2_ = 0;
            while(_loc2_ < _loc1_.length)
            {
               if(_loc1_[_loc2_].idx == PetManager.myActivePetInvId)
               {
                  _loc3_ = _loc1_[_loc2_];
                  if(PetManager.getEnviroTypeByPetType(_loc3_.type) != AvatarManager.roomEnviroType)
                  {
                     break;
                  }
                  this._myPet = new GuiPet(_loc3_.idx,_loc3_.lBits,_loc3_.uBits,_loc3_.eBits,_loc3_.type,_loc3_.name,this.onPetLoaded);
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
               _loc2_++;
            }
         }
      }
      
      private function onPetLoaded(param1:MovieClip) : void
      {
         this._myPet.scaleX = this._myPet.scaleY = 2;
         var _loc2_:Matrix = this._myPet.transform.matrix;
         _loc2_.scale(-1,1);
         this._myPet.transform.matrix = _loc2_;
      }
      
      private function discardAudioItems(param1:Array) : Array
      {
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         while(_loc3_ < param1.length)
         {
            if(param1[_loc3_].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
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
         this.wereItemsOnOriginally(this._itemsOn,this._itemsOff);
         if(this._itemsOn.length > 0 || this._itemsOff.length > 0)
         {
            ItemXtCommManager.requestItemUse(this.itemUseResponse,this._itemsOn.concat(),this._itemsOff.concat());
            this._waitForIuResponse = true;
            _loc1_ = true;
         }
         else if(this._recycle)
         {
            DarkenManager.showLoadingSpiral(false);
            this._recycle.init(RecycleItems.RECYCLE_ACCESSORIES,this._guiLayer,false,this.onRecycleClose,MainFrame.VIEW_WIDTH * 0.5,MainFrame.VIEW_HEIGHT * 0.5);
         }
         if(gMainFrame.userInfo.playerUserInfo.nameBarData != this._nameBarData)
         {
            AvatarXtCommManager.requestColorChange(this._avatarEditorView.colors,this._nameBarData,this.avatarPaintResponse);
            this._waitForApResponse = true;
            _loc1_ = true;
         }
         else if(this._worldAvatar.colors[0] != this._avatarEditorView.colors[0] || this._worldAvatar.colors[1] != this._avatarEditorView.colors[1] || this._worldAvatar.colors[2] != this._avatarEditorView.colors[2])
         {
            AvatarXtCommManager.requestColorChange(this._avatarEditorView.colors,gMainFrame.userInfo.playerUserInfo.nameBarData,this.avatarPaintResponse);
            this._waitForApResponse = true;
            _loc1_ = true;
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
         if(_loc1_)
         {
            DarkenManager.showLoadingSpiral(true);
         }
      }
      
      private function itemUseResponse(param1:Array, param2:Array, param3:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(param3)
         {
            DebugUtility.debugTrace("AvatarEditor: Changes made to avatar were successful");
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               DebugUtility.debugTrace("Item #" + param1[_loc4_] + ": PUT ON");
               _loc4_++;
            }
            _loc5_ = 0;
            while(_loc5_ < param2.length)
            {
               DebugUtility.debugTrace("Item #" + param2[_loc5_] + ": TAKEN OFF");
               _loc5_++;
            }
         }
         this.applyChanges(param3);
      }
      
      private function avatarPaintResponse(param1:Boolean) : void
      {
         var _loc2_:AvatarInfo = null;
         var _loc3_:Array = null;
         if(param1)
         {
            _loc2_ = gMainFrame.userInfo.playerAvatarInfo;
            _loc3_ = this._avatarEditorView.colors;
            if(_loc2_)
            {
               _loc2_.colors = _loc3_;
            }
            gMainFrame.userInfo.playerUserInfo.nameBarData = this._nameBarData;
            this._worldAvatar.setColors(_loc3_[0],_loc3_[1],_loc3_[2]);
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
            _loc2_ = this._avatarEditorView.viewAvatar;
            AvatarManager.playerAvatar.rangedAttack = _loc2_.rangedAttack;
            AvatarManager.playerAvatar.meleeAttack = _loc2_.meleeAttack;
            AvatarManager.playerAvatar.defense = _loc2_.defense;
            AvatarManager.playerAvatar.fierceAttack = _loc2_.fierceAttack;
            AvatarManager.playerAvatar.healingPower = _loc2_.healingPower;
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
         this.sendChangesRequest();
      }
      
      private function colorTableTabClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == this.avEditor.colorsTabDnBtn.name)
         {
            this.openTab(COLOR_TAB_ID);
         }
         else if(param1.currentTarget.name == this.avEditor.patternTabDnBtn.name)
         {
            this.openTab(PATTERN_TAB_ID);
         }
         else if(param1.currentTarget.name == this.avEditor.eyesTabDnBtn.name)
         {
            this.openTab(EYE_TAB_ID);
         }
         else
         {
            DebugUtility.debugTrace("Error AvatarEditor on colorTableTabClick handler: Invalid tab: " + param1.currentTarget.name);
         }
      }
      
      private function colorTableTabOverClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.name == this.avEditor.colorsTabDnBtn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,"Change Colors",665,105);
         }
         else if(param1.currentTarget.name == this.avEditor.patternTabDnBtn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,"Change Patterns",820,105);
         }
         else if(param1.currentTarget.name == this.avEditor.eyesTabDnBtn.name)
         {
            GuiManager.toolTip.init(this._guiLayer,"Change Eyes",742,105);
         }
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function btnOutHandler(param1:MouseEvent) : void
      {
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      public function openTab(param1:int) : void
      {
         if(param1 == COLOR_TAB_ID)
         {
            this.openColorTableColorsTab();
         }
         else if(param1 == PATTERN_TAB_ID)
         {
            this.openColorTablePatternEyesTab(true);
         }
         else if(param1 == EYE_TAB_ID)
         {
            this.openColorTablePatternEyesTab(false);
         }
         else
         {
            DebugUtility.debugTrace("Error AvatarEditor on openTab: Invalid tabId: " + param1);
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
      
      private function openColorTablePatternEyesTab(param1:Boolean) : void
      {
         this.avEditor.colorTableBlock.patternsAndEyes.visible = true;
         this.avEditor.colorTableBlock.colors.visible = false;
         while(this._eyePattWindow.numChildren > 1)
         {
            this._eyePattWindow.removeChildAt(1);
         }
         if(param1)
         {
            this._tabOpenId = 1;
            this.avEditor.colorsTabUp.visible = false;
            this.avEditor.eyesTabUp.visible = false;
            this.avEditor.patternTabUp.visible = true;
            this.avEditor.colorTableBlock.patternsAndEyes.topTxt.text = "Pattern";
            if(this.avEditor.colorTableBlock.patternsAndEyes.contains(this._colorTableEyes))
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
               if(this._patterns[this._currPattern])
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
            this.avEditor.colorTableBlock.patternsAndEyes.topTxt.text = "Eyes";
            if(this.avEditor.colorTableBlock.patternsAndEyes.contains(this._colorTablePatterns))
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
               if(this._eyes[this._currEye])
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
         var _loc1_:Array = this._avatarEditorView.inventoryBodyModItems;
         this._eyes = [];
         this._patterns = [];
         this._patterns.push(null);
         var _loc2_:int = 0;
         while(_loc2_ < _loc1_.length)
         {
            if(_loc1_[_loc2_].layerId == Item.PATTERN_LAYER)
            {
               if(_loc1_[_loc2_].getInUse(this._worldAvatar.dbAvId))
               {
                  this._currPattern = this._patterns.length;
               }
               this._patterns.push(_loc1_[_loc2_]);
            }
            else if(_loc1_[_loc2_].layerId == Item.EYE_LAYER)
            {
               if(_loc1_[_loc2_].getInUse(this._worldAvatar.dbAvId))
               {
                  this._currEye = this._eyes.length;
               }
               this._eyes.push(_loc1_[_loc2_]);
            }
            _loc2_++;
         }
      }
      
      private function arrowBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Item = null;
         var _loc4_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._lArrowBtn.name)
         {
            _loc2_ = -1;
         }
         else if(param1.currentTarget.name == this._rArrowBtn.name)
         {
            _loc2_ = 1;
         }
         while(this._eyePattWindow.numChildren > 1)
         {
            this._eyePattWindow.removeChildAt(1);
         }
         var _loc5_:Boolean = false;
         if(this._tabOpenId == 1)
         {
            _loc3_ = this._patterns[this._currPattern];
            _loc6_ = this._currPattern;
            _loc7_ = this._patterns;
         }
         else if(this._tabOpenId == 2)
         {
            _loc3_ = this._eyes[this._currEye];
            _loc6_ = this._currEye;
            _loc7_ = this._eyes;
         }
         _loc6_ += _loc2_;
         if(_loc6_ < 0)
         {
            _loc6_ = _loc7_.length - 1;
         }
         else if(_loc6_ > _loc7_.length - 1)
         {
            _loc6_ = 0;
         }
         if(_loc7_[_loc6_] == null)
         {
            this.hideItem(_loc3_);
         }
         else
         {
            _loc3_ = _loc7_[_loc6_];
            this.showItem(_loc3_,this.hideBodModWhenShowingBodMod);
         }
         if(Boolean(_loc7_[_loc6_]) && _loc7_[_loc6_].icon != null)
         {
            this._eyePattWindow.addChild(_loc7_[_loc6_].icon);
         }
         if(this._tabOpenId == 1)
         {
            this._currPattern = _loc6_;
         }
         else if(this._tabOpenId == 2)
         {
            this._currEye = _loc6_;
         }
         this.colorCurrEyePattIcon();
      }
      
      public function showItem(param1:Item, param2:Function = null) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:Boolean = false;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         if(param1)
         {
            _loc3_ = param1.invIdx;
            if(Boolean(this._itemsOn) && Boolean(this._itemsOff))
            {
               if(param1.type == Item.CLOTHING_TYPE)
               {
                  _loc4_ = this._avatarEditorView.inventoryClothingItems;
                  _loc5_ = this._worldAvatar.inventoryClothing.itemArray;
               }
               else
               {
                  _loc4_ = this._avatarEditorView.inventoryBodyModItems;
                  _loc5_ = this._worldAvatar.inventoryBodyMod.itemArray;
               }
               _loc7_ = 0;
               while(_loc7_ < _loc4_.length)
               {
                  if(_loc4_[_loc7_].invIdx == param1.invIdx)
                  {
                     if(this._itemsOff.indexOf(_loc3_) != -1)
                     {
                        this._itemsOff.splice(this._itemsOff.indexOf(_loc3_),1);
                     }
                     _loc8_ = 0;
                     while(_loc8_ < _loc5_.length)
                     {
                        if(param1.invIdx == _loc5_[_loc8_].invIdx)
                        {
                           _loc6_ = true;
                           if(!_loc5_[_loc8_].getInUse(this._worldAvatar.dbAvId))
                           {
                              if(this._itemsOn.indexOf(_loc3_) == -1)
                              {
                                 this._itemsOn.push(_loc3_);
                              }
                              break;
                           }
                        }
                        _loc8_++;
                     }
                     if(!_loc6_ && this._itemsOn.indexOf(_loc3_) == -1)
                     {
                        this._itemsOn.push(_loc3_);
                     }
                     break;
                  }
                  _loc7_++;
               }
            }
            this._avatarEditorView.showAccessory(param1,param2);
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
            if(Boolean(this._itemsOn) && Boolean(this._itemsOff))
            {
               if(param1.type == Item.CLOTHING_TYPE)
               {
                  _loc3_ = this._avatarEditorView.inventoryClothingItems;
               }
               else
               {
                  _loc3_ = this._avatarEditorView.inventoryBodyModItems;
               }
               _loc4_ = 0;
               while(_loc4_ < _loc3_.length)
               {
                  if(_loc3_[_loc4_].invIdx == param1.invIdx)
                  {
                     if(this._itemsOff.indexOf(_loc2_) == -1)
                     {
                        this._itemsOff.push(_loc2_);
                     }
                     if(this._itemsOn.indexOf(_loc2_) != -1)
                     {
                        this._itemsOn.splice(this._itemsOn.indexOf(_loc2_),1);
                     }
                     break;
                  }
                  _loc4_++;
               }
            }
            this._avatarEditorView.hideAccessory(param1);
         }
      }
      
      public function onShopBtnHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this.avEditor.shopBtn.isGray)
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
      
      public function onShopBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this.avEditor.shopBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? "Jam Mart Clothing" : "Bahari Bargains",0,-45,true);
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
         if(this.avEditor.petsBtn.isGray)
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
      
      private function onPetBtnOverHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this.avEditor.petsBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),"Pets",0,-45,true);
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
         if(this.avEditor.recycleClothesBtn.isGray)
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
      
      private function onRecycleClothesBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this.avEditor.recycleClothesBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),"Recycle",0,-35);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function onRecycleClose(param1:Boolean = false) : void
      {
         if(this._recycle)
         {
            this._recycle.destroy();
            this._recycle = null;
         }
         if(param1)
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
            if(this._currClothesArray)
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
            if(this._itemClothingWindows)
            {
               this._itemClothingWindows.destroy();
               this._itemClothingWindows = null;
            }
            this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
         }
      }
      
      private function onShopClose(param1:Boolean) : void
      {
         if(this._shop)
         {
            this._shop.destroy();
            this._shop = null;
         }
         if(param1)
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
            if(this._currClothesArray)
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
            if(this._itemClothingWindows)
            {
               this._itemClothingWindows.destroy();
               this._itemClothingWindows = null;
            }
            this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
         }
      }
      
      private function numTradeItemsInClothesList(param1:Array) : int
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._currTradesArray.length)
         {
            if(this._currTradesArray[_loc3_].type == 0)
            {
               _loc4_ = 0;
               while(_loc4_ < param1.length)
               {
                  if(this._currTradesArray[_loc3_].invIdx == param1[_loc4_].invIdx)
                  {
                     _loc2_++;
                     break;
                  }
                  _loc4_++;
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function numTradeItemsInDenItemsList(param1:Array) : int
      {
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         while(_loc3_ < this._currTradesArray.length)
         {
            if(this._currTradesArray[_loc3_].type == 1)
            {
               _loc4_ = 0;
               while(_loc4_ < param1.length)
               {
                  if(this._currTradesArray[_loc3_].invIdx == param1[_loc4_].invIdx)
                  {
                     _loc2_++;
                     break;
                  }
                  _loc4_++;
               }
            }
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function createItemWindows(param1:Array, param2:MovieClip, param3:Boolean = false) : void
      {
         var _loc4_:WindowGenerator = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Array = null;
         var _loc13_:Array = null;
         var _loc14_:Object = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Object = null;
         var _loc19_:int = 0;
         if(Boolean(this._mainScrollbar) && this._mainScrollbar.getScrollContentParent == param2)
         {
            if(param2 == this.avEditor.itemBlock && param3)
            {
               _mainScrollYPosition = this._mainScrollbar.scrollYValue;
            }
            this._mainScrollbar.destroy();
            this._mainScrollbar = null;
         }
         var _loc7_:int = 0;
         if(param1 == this._currTradesArray)
         {
            _loc9_ = true;
         }
         else
         {
            _loc9_ = false;
         }
         if(_loc9_)
         {
            _loc5_ = 12;
            _loc6_ = Math.ceil(_loc5_ / this.NUM_X_WIN) * this.NUM_X_WIN;
         }
         else if(param1 == this._allNewestClothes || param1 == this._currClothesArray || param1 == this._fullClothesList || Boolean(this._tradeWindow.visible) && Boolean(this._tradeWindow.clothesBtnUp.visible))
         {
            _loc11_ = true;
            _loc5_ = Math.max(param1.length,12);
            if(param2 == this.avEditor.itemBlock)
            {
               _loc6_ = Math.ceil(param1.length / this.NUM_X_WIN) * this.NUM_X_WIN;
            }
            else
            {
               _loc6_ = Math.ceil((param1.length - this.numTradeItemsInClothesList(param1)) / this.NUM_X_WIN) * this.NUM_X_WIN;
            }
         }
         else
         {
            if(!(param1 == this._currDenItemsArray || param1 == this._allNewestDenItems))
            {
               throw new Error("None of our lists match given items list");
            }
            _loc5_ = Math.max(param1.length,12);
            _loc6_ = Math.ceil((param1.length - this.numTradeItemsInDenItemsList(param1)) / this.NUM_X_WIN) * this.NUM_X_WIN;
         }
         if(this.avEditor.tradeBtnUp.visible)
         {
            _loc10_ = true;
         }
         if(param2 == this.avEditor.itemBlock)
         {
            if(_loc10_)
            {
               _loc4_ = this._itemTradeWindows;
            }
            else
            {
               _loc4_ = this._itemClothingWindows;
            }
            while(this.avEditor.itemBlock.numChildren > 0)
            {
               this.avEditor.itemBlock.removeChildAt(0);
            }
         }
         else if(param2 == this._tradeWindow.itemBlock)
         {
            if(_loc11_)
            {
               _loc4_ = this._tradeClothingWindows;
            }
            else
            {
               _loc4_ = this._tradeDenWindows;
            }
            while(this._tradeWindow.itemBlock.numChildren > 0)
            {
               this._tradeWindow.itemBlock.removeChildAt(0);
            }
         }
         if(_loc4_ == null)
         {
            _loc12_ = [];
            _loc13_ = [];
            _loc14_ = null;
            _loc16_ = 0;
            for(; _loc16_ < _loc5_; _loc16_++)
            {
               if(_loc16_ < _loc5_)
               {
                  if(param1[_loc16_])
                  {
                     if(this.avEditor.clothesBtnUp.visible)
                     {
                        _loc14_ = param1[_loc16_];
                     }
                     else if(_loc9_)
                     {
                        _loc18_ = null;
                        if(param1[_loc16_].type == TradeManager.CLOTHING_TYPE)
                        {
                           _loc17_ = 0;
                           while(_loc17_ < this._fullClothesList.length)
                           {
                              if(this._fullClothesList[_loc17_].invIdx == param1[_loc16_].invIdx)
                              {
                                 _loc18_ = this._fullClothesList[_loc17_];
                                 break;
                              }
                              _loc17_++;
                           }
                           if(_loc18_)
                           {
                              _loc14_ = new Item();
                              _loc14_.init(_loc18_.defId,_loc18_.invIdx,_loc18_.color,_loc18_.inUseFlagLand,_loc18_.inUseFlagOcean);
                           }
                        }
                        else
                        {
                           _loc17_ = 0;
                           while(_loc17_ < this._allNewestDenItems.length)
                           {
                              if(this._allNewestDenItems[_loc17_].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
                              {
                                 if(this._allNewestDenItems[_loc17_].invIdx == param1[_loc16_].invIdx)
                                 {
                                    _loc18_ = this._allNewestDenItems[_loc17_];
                                    break;
                                 }
                              }
                              _loc17_++;
                           }
                           if(_loc18_)
                           {
                              _loc14_ = new DenItem();
                              _loc14_.init(_loc18_.itemDefId,_loc18_.invIdx,_loc18_.categoryId,_loc18_.version,_loc18_.refId);
                           }
                        }
                     }
                     else
                     {
                        _loc14_ = param1[_loc16_];
                        _loc19_ = 0;
                        while(_loc19_ < this._currTradesArray.length)
                        {
                           if((_loc14_ is Item && this._currTradesArray[_loc19_].type == 0 || _loc14_ is DenItem && this._currTradesArray[_loc19_].type == 1) && _loc14_.invIdx == this._currTradesArray[_loc19_].invIdx)
                           {
                              _loc8_ = true;
                              break;
                           }
                           _loc19_++;
                        }
                        if(_loc8_)
                        {
                           _loc8_ = false;
                           _loc7_++;
                           continue;
                        }
                     }
                     _loc13_.push(_loc15_ + _loc7_);
                     if(_loc14_)
                     {
                        _loc12_.push(_loc14_);
                     }
                  }
               }
               _loc15_++;
            }
            _loc4_ = new WindowGenerator();
            _loc4_.init(this.NUM_X_WIN,this.NUM_Y_WIN,Math.max(_loc6_,12),this.X_WIN_OFFSET,this.Y_WIN_OFFSET,this.X_WIN_START,ItemWindowOriginal,_loc12_,"icon",{
               "mouseDown":this.winMouseClick,
               "mouseOver":this.winMouseOver,
               "mouseOut":this.winMouseOut,
               "memberOnlyDown":this.memberOnlyDown
            },{
               "isAvatarEditor":true,
               "isTradeList":_loc9_,
               "isChoosingForTradeList":_loc10_,
               "indexArray":_loc13_
            });
            if(param2 == this.avEditor.itemBlock)
            {
               if(_loc10_)
               {
                  this._itemTradeWindows = _loc4_;
               }
               else
               {
                  this._itemClothingWindows = _loc4_;
               }
            }
            else if(_loc11_)
            {
               this._tradeClothingWindows = _loc4_;
            }
            else
            {
               this._tradeDenWindows = _loc4_;
            }
         }
         param2.addChild(_loc4_);
         this.createScrollbar(_loc4_);
      }
      
      private function createScrollbar(param1:WindowGenerator) : void
      {
         var _loc2_:Number = NaN;
         if(param1)
         {
            if(param1.parent == this.avEditor.itemBlock)
            {
               _loc2_ = _mainScrollYPosition;
            }
            else if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
            {
               _loc2_ = _tradeClothingScrollYPosition;
            }
            else
            {
               _loc2_ = _tradeDenScrollYPosition;
            }
            this._mainScrollbar = new SBScrollbar();
            this._mainScrollbar.init(param1,param1.width,param1.boxHeight * this.NUM_Y_WIN + this.Y_WIN_OFFSET * this.NUM_Y_WIN + this.Y_WIN_START * 2,this.SCROLLBAR_GAP,"scrollbar2",param1.boxHeight + this.Y_WIN_OFFSET,_loc2_,param1.height);
         }
      }
      
      private function openCloseTradeWindow(param1:MovieClip) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Array = null;
         this._tradeWindow.visible = !this._tradeWindow.visible;
         this.avEditor.blackout.visible = !this.avEditor.blackout.visible;
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
               this._tradeSort.sort8.txt.text = "Head";
               this._tradeSort.sort7.txt.text = "Neck";
               this._tradeSort.sort6.txt.text = "Back";
               this._tradeSort.sort5.txt.text = "Legs";
               this._tradeSort.sort4.txt.text = "Tail";
               this._tradeSort.sort3.txt.text = "Item";
               this._tradeSort.sort2.txt.text = "All Newest";
               this._tradeSort.sort1.txt.text = "All Oldest";
            }
            else
            {
               this._tradeWindow.denBtnUp.visible = true;
               this._tradeWindow.denBtnDown.visible = false;
               this._tradeWindow.clothesBtnUp.visible = false;
               this._tradeWindow.clothesBtnDown.visible = true;
               this._tradeSort.sort4.txt.text = "Floors & Walls";
               this._tradeSort.sort3.txt.text = "Items";
               this._tradeSort.sort2.txt.text = "All Newest";
               this._tradeSort.sort1.txt.text = "All Oldest";
               this._tradeSort.sort5.visible = false;
               this._tradeSort.sort6.visible = false;
               this._tradeSort.sort7.visible = false;
               this._tradeSort.sort8.visible = false;
            }
            this._tradeSort.visible = false;
            _loc2_ = _tradeListViewType == this.CLOTHING_VIEW_TYPE;
            _loc3_ = this.convertIntToList(_loc2_ ? _tradeClothingSortType : _tradeDenSortType,_loc2_);
            this.createItemWindows(_loc3_,param1);
         }
         else
         {
            if(this._mainScrollbar)
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
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(param1.currentTarget.isAvatarSpecific)
         {
            _loc2_ = String(ItemXtCommManager.getFirstAvTypeThatCanUseItem(param1.currentTarget.defId));
            if(_loc2_ != "-1")
            {
               if(param1.currentTarget.avtSpecificIcon.currentFrameLabel != _loc2_)
               {
                  param1.currentTarget.avtSpecificIcon.gotoAndStop(_loc2_);
               }
               param1.currentTarget.avtSpecificIcon.visible = true;
               param1.currentTarget.avtSpecificHighlight.visible = true;
               return;
            }
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
         if(param1.currentTarget.isAvatarSpecific)
         {
            param1.currentTarget.avtSpecificIcon.visible = false;
            param1.currentTarget.avtSpecificHighlight.visible = false;
            return;
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
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this.avEditor.clothesBtnUp.visible)
         {
            _loc2_ = this._currClothesArray[param1.currentTarget.index];
         }
         else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
         {
            _loc2_ = this._fullClothesList[param1.currentTarget.index];
         }
         else if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
         {
            _loc2_ = this._currDenItemsArray[param1.currentTarget.index];
         }
         else if(this.avEditor.tradeBtnUp.visible)
         {
            _loc2_ = this._currTradesArray[param1.currentTarget.index];
         }
         if(_loc2_)
         {
            if(!this._tradeWindow.visible && Boolean(this.avEditor.clothesBtnUp.visible))
            {
               if(!ItemXtCommManager.canUseItem(_loc2_.defId,this._worldAvatar.avTypeId))
               {
                  _loc3_ = ItemXtCommManager.avTypeThatCanUseItem(_loc2_.defId);
                  if(_loc3_.length > 0)
                  {
                     if(_loc3_.length == 1)
                     {
                        LocalizationXtCommManager.sendTranslateStringRequest(gMainFrame.userInfo.getAvatarDefByAvType(_loc3_[0]).titleStrRef,LocalizationXtCommManager.LANG_ENG,this.onAvatarNameLocalization);
                     }
                     else
                     {
                        this._avatarNamesString = "";
                        this._numAvatarNamesLoaded = 0;
                        this._numAvatarNamesToLoad = _loc3_.length;
                        _loc4_ = 0;
                        while(_loc4_ < this._numAvatarNamesToLoad)
                        {
                           LocalizationXtCommManager.sendTranslateStringRequest(gMainFrame.userInfo.getAvatarDefByAvType(_loc3_[_loc4_]).titleStrRef,LocalizationXtCommManager.LANG_ENG,this.onAvatarNameLocalization,true);
                           _loc4_++;
                        }
                     }
                  }
                  return;
               }
               if(param1.currentTarget.cir.currentFrameLabel == "downMouse" && Boolean(_loc2_.getInUse(this._worldAvatar.dbAvId)))
               {
                  this.hideItem(Item(_loc2_));
                  param1.currentTarget.cir.gotoAndStop("over");
               }
               else if(param1.currentTarget.cir.currentFrameLabel != "downMouse" && !_loc2_.getInUse(this._worldAvatar.dbAvId))
               {
                  this.showItem(Item(_loc2_),this.hideItemWhenShowingItem);
                  param1.currentTarget.cir.gotoAndStop("downMouse");
               }
               else
               {
                  DebugUtility.debugTrace("Item is in use? But not in use? Huuuuuuuuh");
               }
            }
            else if(!this._tradeWindow.visible && Boolean(this.avEditor.tradeBtnUp.visible))
            {
               param1.currentTarget.cir.gotoAndStop("up");
               if(param1.currentTarget.removeBtn.visible)
               {
                  this._currTradesArray.splice(param1.currentTarget.index,1);
                  if(_loc2_.type == TradeManager.CLOTHING_TYPE)
                  {
                     TradeManager.adjustByOnNumClothingItemsInMyTradeList(-1);
                  }
                  else
                  {
                     TradeManager.adjustByOnNumDenItemsInMyTradeList(-1);
                  }
                  this.addRemoveTradeItemFromList(_loc2_,false);
                  if(this._itemTradeWindows)
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
               param1.currentTarget.cir.gotoAndStop("up");
               if(_loc2_ is Item)
               {
                  _loc2_ = {
                     "type":TradeManager.CLOTHING_TYPE,
                     "invIdx":_loc2_.invIdx
                  };
                  if(this._tradeClothingWindows)
                  {
                     this._tradeClothingWindows.destroy();
                     this._tradeClothingWindows = null;
                  }
               }
               else if(_loc2_ is DenItem)
               {
                  _loc2_ = {
                     "type":TradeManager.DEN_TYPE,
                     "invIdx":_loc2_.invIdx
                  };
                  if(this._tradeDenWindows)
                  {
                     this._tradeDenWindows.destroy();
                     this._tradeDenWindows = null;
                  }
               }
               this._currTradesArray.push(_loc2_);
               if(_loc2_.type == TradeManager.CLOTHING_TYPE)
               {
                  TradeManager.adjustByOnNumClothingItemsInMyTradeList(1);
               }
               else
               {
                  TradeManager.adjustByOnNumDenItemsInMyTradeList(1);
               }
               this.addRemoveTradeItemFromList(_loc2_,true);
               if(this._itemTradeWindows)
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
         else if(param1.currentTarget.addBtn.visible)
         {
            _loc5_ = _tradeListViewType == this.CLOTHING_VIEW_TYPE;
            if(_loc5_)
            {
               this._fullClothesList = this.convertIntToList(_tradeClothingSortType,_loc5_);
            }
            else
            {
               this._currDenItemsArray = this.convertIntToList(_tradeDenSortType,_loc5_);
            }
            this.openCloseTradeWindow(this._tradeWindow.itemBlock);
         }
         else
         {
            DebugUtility.debugTrace("Curr Item is null, and the addBtn is not visible??");
         }
      }
      
      private function memberOnlyDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         UpsellManager.displayPopup(UpsellManager.ACCESSORIES,"equipAccessory/" + this._currClothesArray[param1.currentTarget.index].name);
      }
      
      private function onAvatarNameLocalization(param1:int, param2:String, param3:Object = null) : void
      {
         ++this._numAvatarNamesLoaded;
         if(param3)
         {
            if(this._avatarNamesString == "")
            {
               this._avatarNamesString += param2;
            }
            else if(this._numAvatarNamesToLoad == this._numAvatarNamesLoaded)
            {
               this._avatarNamesString += " or " + param2;
               new SBOkPopup(this._guiLayer,"You have to be a " + this._avatarNamesString + " to use this item!");
            }
            else
            {
               this._avatarNamesString += ", " + param2;
            }
         }
         else
         {
            new SBOkPopup(this._guiLayer,"You have to be a " + param2 + " to use this item!");
         }
      }
      
      private function hideItemWhenShowingItem(param1:Item) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc2_:int = this._itemsOn.indexOf(param1.invIdx);
         if(_loc2_ == -1)
         {
            _loc3_ = 0;
            while(_loc3_ < this._currClothesArray.length)
            {
               if(this._currClothesArray[_loc3_].invIdx == param1.invIdx)
               {
                  if(this._itemsOff)
                  {
                     this._itemsOff.push(param1.invIdx);
                     break;
                  }
               }
               _loc3_++;
            }
         }
         if(this._itemsOn)
         {
            if(_loc2_ != -1)
            {
               this._itemsOn.splice(this._itemsOn.indexOf(param1.invIdx),1);
            }
         }
         if(this._itemClothingWindows)
         {
            _loc4_ = 0;
            while(_loc4_ < this._itemClothingWindows.bg.numChildren)
            {
               _loc5_ = MovieClip(this._itemClothingWindows.bg.getChildAt(_loc4_));
               if(this._currClothesArray[_loc5_.index].invIdx == param1.invIdx)
               {
                  _loc5_.cir.gotoAndStop("up");
                  break;
               }
               _loc4_++;
            }
         }
      }
      
      private function hideBodModWhenShowingBodMod(param1:Item) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Array = this._avatarEditorView.inventoryBodyModItems;
         var _loc3_:int = this._itemsOn.indexOf(param1.invIdx);
         if(_loc3_ == -1)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length)
            {
               if(_loc2_[_loc4_].invIdx == param1.invIdx)
               {
                  if(this._itemsOff)
                  {
                     this._itemsOff.push(param1.invIdx);
                     break;
                  }
               }
               _loc4_++;
            }
         }
         if(this._itemsOn)
         {
            if(_loc3_ != -1)
            {
               this._itemsOn.splice(this._itemsOn.indexOf(param1.invIdx),1);
            }
         }
      }
      
      private function wereItemsOnOriginally(param1:Array, param2:Array) : void
      {
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         var _loc5_:Array = this._worldAvatar.inventoryClothing.itemArray.concat(this._worldAvatar.inventoryBodyMod.itemArray);
         _loc3_ = 0;
         while(_loc3_ < param1.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               if(param1[_loc3_] == _loc5_[_loc4_].invIdx && Boolean(_loc5_[_loc4_].getInUse(this._worldAvatar.dbAvId)))
               {
                  param1.splice(_loc3_,1);
                  _loc3_--;
                  break;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < param2.length)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               if(param2[_loc3_] == _loc5_[_loc4_].invIdx && !_loc5_[_loc4_].getInUse(this._worldAvatar.dbAvId))
               {
                  param2.splice(_loc3_,1);
                  _loc3_--;
                  break;
               }
               _loc4_++;
            }
            _loc3_++;
         }
         this._itemsOn = param1;
         this._itemsOff = param2;
      }
      
      private function addRemoveTradeItemFromList(param1:Object, param2:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc3_:Array = gMainFrame.userInfo.getMyTradeList();
         if(param2)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(_loc3_[_loc4_].invIdx == param1.invIdx && _loc3_[_loc4_].type == param1.type)
               {
                  this._tradeItemsOut.splice(this._tradeItemsOut.indexOf(param1),1);
                  return;
               }
               _loc4_++;
            }
            this._tradeItemsIn.push(param1);
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               if(_loc3_[_loc4_].invIdx == param1.invIdx && _loc3_[_loc4_].type == param1.type)
               {
                  this._tradeItemsOut.push(param1);
                  return;
               }
               _loc4_++;
            }
            this._tradeItemsIn.splice(this._tradeItemsIn.indexOf(param1),1);
         }
      }
      
      private function sortByHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(this.avEditor.sortBtn.isGray)
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
      
      private function sortBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         if(param1)
         {
            param1.stopPropagation();
         }
         var _loc3_:int = this.CLOTHING_VIEW_TYPE;
         if(param1.currentTarget.name == this.avEditor.sortPopup.sort8.name)
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullHeadItems;
               _tradeClothingSortType = 8;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._headItems;
               _mainClothingSortType = 8;
            }
         }
         else if(param1.currentTarget.name == this.avEditor.sortPopup.sort7.name)
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullNeckItems;
               _tradeClothingSortType = 7;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._neckItems;
               _mainClothingSortType = 7;
            }
         }
         else if(param1.currentTarget.name == (this.avEditor.sortPopup.sort6.name || this._tradeSort.sort6.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullBackItems;
               _tradeClothingSortType = 6;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._backItems;
               _mainClothingSortType = 6;
            }
         }
         else if(param1.currentTarget.name == (this.avEditor.sortPopup.sort5.name || this._tradeSort.sort5.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               _loc2_ = this._currDenItemsArray = this._floorItems;
               _loc3_ = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 5;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullLegItems;
               _tradeClothingSortType = 5;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._legItems;
               _mainClothingSortType = 5;
            }
         }
         else if(param1.currentTarget.name == (this.avEditor.sortPopup.sort4.name || this._tradeSort.sort4.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               _loc2_ = this._currDenItemsArray = this._themeItems;
               _loc3_ = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 4;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullTailItems;
               _tradeClothingSortType = 4;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._tailItems;
               _mainClothingSortType = 4;
            }
         }
         else if(param1.currentTarget.name == (this.avEditor.sortPopup.sort3.name || this._tradeSort.sort3.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               _loc2_ = this._currDenItemsArray = this._itemTypeDenItems;
               _loc3_ = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 3;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullItemTypeItems;
               _tradeClothingSortType = 3;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._itemTypeItems;
               _mainClothingSortType = 3;
            }
         }
         else if(param1.currentTarget.name == (this.avEditor.sortPopup.sort2.name || this._tradeSort.sort2.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               _loc2_ = this._currDenItemsArray = this._allNewestDenItems;
               _loc3_ = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 2;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullallNewestClothes;
               _tradeClothingSortType = 2;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._allNewestClothes;
               _mainClothingSortType = 2;
            }
         }
         else if(param1.currentTarget.name == (this.avEditor.sortPopup.sort1.name || this._tradeSort.sort1.name))
         {
            if(this._tradeWindow.visible && Boolean(this._tradeWindow.denBtnUp.visible))
            {
               _loc2_ = this._currDenItemsArray = this._allOldestDenItems;
               _loc3_ = this.DEN_VIEW_TYPE;
               _tradeDenSortType = 1;
            }
            else if(this._tradeWindow.visible && Boolean(this._tradeWindow.clothesBtnUp.visible))
            {
               _loc2_ = this._fullClothesList = this._fullAllOldestClothes;
               _tradeClothingSortType = 1;
            }
            else
            {
               _loc2_ = this._currClothesArray = this._allOldestClothes;
               _mainClothingSortType = 1;
            }
         }
         else if(param1.currentTarget.name == this.avEditor.sortPopup.bg.name)
         {
            this.avEditor.sortPopup.visible = !this.avEditor.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         if(_loc2_)
         {
            if(this._tradeWindow.visible)
            {
               if(this._mainScrollbar)
               {
                  if(_loc3_ == this.CLOTHING_VIEW_TYPE)
                  {
                     _tradeClothingScrollYPosition = 0;
                  }
                  else
                  {
                     _tradeDenScrollYPosition = 0;
                  }
               }
               this._tradeSort.visible = !this._tradeSort.visible;
               if(_loc3_ == this.CLOTHING_VIEW_TYPE)
               {
                  this._tradeClothingWindows.destroy();
                  this._tradeClothingWindows = null;
               }
               else
               {
                  this._tradeDenWindows.destroy();
                  this._tradeDenWindows = null;
               }
               this.createItemWindows(_loc2_,this._tradeWindow.itemBlock);
            }
            else
            {
               if(_loc3_ == this.CLOTHING_VIEW_TYPE)
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
               this.createItemWindows(_loc2_,this.avEditor.itemBlock);
            }
         }
      }
      
      private function clothesDenAndTradeHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._tradeWindow.visible && param1.currentTarget.name == this.avEditor.clothesBtnDown.name)
         {
            if(param1.currentTarget.name == this.avEditor.clothesBtnDown.name)
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
            this.avEditor.sortPopup.sort8.txt.text = "Head";
            this.avEditor.sortPopup.sort7.txt.text = "Neck";
            this.avEditor.sortPopup.sort6.txt.text = "Back";
            this.avEditor.sortPopup.sort5.txt.text = "Legs";
            this.avEditor.sortPopup.sort4.txt.text = "Tail";
            this.avEditor.sortPopup.sort3.txt.text = "Item";
            this.avEditor.sortPopup.sort2.txt.text = "All Newest";
            this.avEditor.sortPopup.sort1.txt.text = "All Oldest";
            this.createItemWindows(this._currClothesArray,this.avEditor.itemBlock);
         }
         else if(!this._tradeWindow.visible && param1.currentTarget.name == this.avEditor.tradeBtnDown.name)
         {
            if(this.avEditor.tradeBtnDown.isGray)
            {
               return;
            }
            if(param1.currentTarget.name == this.avEditor.tradeBtnDown.name)
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
               this.avEditor.tradeHelpPopup.txt.text = "Click the + to add items to your trade list. These are the items you want to trade with other Jammers.";
               AchievementXtCommManager.requestSetUserVar(AchievementXtCommManager.UV_TRADING,0);
            }
            this.createItemWindows(this._currTradesArray,this.avEditor.itemBlock,true);
         }
         else if(this._tradeWindow.visible && param1.currentTarget.name == this._tradeWindow.clothesBtnDown.name)
         {
            this._tradeWindow.denBtnUp.visible = false;
            this._tradeWindow.denBtnDown.visible = true;
            this._tradeWindow.clothesBtnUp.visible = true;
            this._tradeWindow.clothesBtnDown.visible = false;
            this._tradeSort.sort8.txt.text = "Head";
            this._tradeSort.sort7.txt.text = "Neck";
            this._tradeSort.sort6.txt.text = "Back";
            this._tradeSort.sort5.txt.text = "Legs";
            this._tradeSort.sort4.txt.text = "Tail";
            this._tradeSort.sort3.txt.text = "Item";
            this._tradeSort.sort2.txt.text = "All Newest";
            this._tradeSort.sort1.txt.text = "All Oldest";
            this._tradeSort.sort5.visible = true;
            this._tradeSort.sort6.visible = true;
            this._tradeSort.sort7.visible = true;
            this._tradeSort.sort8.visible = true;
            if(this._mainScrollbar)
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
         else if(this._tradeWindow.visible && param1.currentTarget.name == this._tradeWindow.denBtnDown.name)
         {
            this._tradeWindow.denBtnUp.visible = true;
            this._tradeWindow.denBtnDown.visible = false;
            this._tradeWindow.clothesBtnUp.visible = false;
            this._tradeWindow.clothesBtnDown.visible = true;
            this._tradeSort.sort4.txt.text = "Floors & Walls";
            this._tradeSort.sort3.txt.text = "Items";
            this._tradeSort.sort2.txt.text = "All Newest";
            this._tradeSort.sort1.txt.text = "All Oldest";
            this._tradeSort.sort5.visible = false;
            this._tradeSort.sort6.visible = false;
            this._tradeSort.sort7.visible = false;
            this._tradeSort.sort8.visible = false;
            if(this._mainScrollbar)
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
      
      private function onCloseTradeWindow(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._tradeWindow.visible = !this._tradeWindow.visible;
         this.avEditor.blackout.visible = !this.avEditor.blackout.visible;
         if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
         {
            _tradeClothingScrollYPosition = this._mainScrollbar.scrollYValue;
         }
         else
         {
            _tradeDenScrollYPosition = this._mainScrollbar.scrollYValue;
         }
      }
      
      private function blockMouseBlockerHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onCloseTradeHelpPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.avEditor.tradeHelpPopup.visible = false;
      }
      
      private function onInfoBtnDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GenericListGuiManager.genericListVolumeClicked(22);
      }
      
      private function onNameBarPopupClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.avEditor.namebarPopup.visible = false;
      }
      
      private function onColorNameBar(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._userInfo.isMember || this._worldAvatar.isShaman || this._userInfo.isGuide)
         {
            UpsellManager.displayPopup(UpsellManager.NAMEBARS,"namebarColor");
            return;
         }
         this._nameBarData = (this._nameBarData & 0xFF00) + param1.currentTarget.id;
         this.avEditor.member.setColorAndBadge(this._nameBarData);
         this.avEditor.member.setAvName(this._worldAvatar.avName,false);
         this.createNamebarIconWindows();
      }
      
      private function onNameBarPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onMemberNameBar(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnClick();
         this.avEditor.namebarPopup.visible = !this.avEditor.namebarPopup.visible;
         if(this.avEditor.namebarPopup.visible)
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
      
      private function onMemberNameBarOver(param1:MouseEvent) : void
      {
         if(this._isFFM)
         {
            return;
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function onNamebarBadgeIdsLoaded(param1:Array) : void
      {
         var _loc3_:Object = null;
         this._namebarBadgeDefs = [];
         this._namebarBadgeMediaIds = [];
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = GuiManager.getNamebarBadgeDef(param1[_loc2_]);
            if(Boolean(_loc3_) && (_loc3_.pendingFlagsBit == 0 || Boolean(gMainFrame.userInfo.isPendingFlagSet(_loc3_.pendingFlagsBit))))
            {
               this._namebarBadgeDefs.push(_loc3_);
               this._namebarBadgeMediaIds.push(_loc3_.mediaRefId);
            }
            _loc2_++;
         }
         this.createNamebarIconWindows();
      }
      
      private function onNamebarIconsLoaded(param1:MovieClip, param2:MovieClip, param3:int) : void
      {
         if(Boolean(param1) && Boolean(param2))
         {
            this._namebarBadgeImages[param3] = {
               "iconMouse":param1,
               "iconUp":param2
            };
         }
      }
      
      private function createNamebarIconWindows() : void
      {
         var _loc1_:Array = null;
         var _loc2_:Boolean = false;
         if(this._nameBarScrollBar)
         {
            this._nameBarScrollBar.destroy();
            this._nameBarScrollBar = null;
         }
         if(this._nameBarItemWindows)
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
            _loc1_ = this._namebarBadgeImages;
         }
         else
         {
            _loc1_ = this._namebarBadgeMediaIds;
            _loc2_ = true;
         }
         this._nameBarItemWindows = new WindowGenerator();
         this._nameBarItemWindows.init(4,8,_loc1_.length,4,6,5,ItemWindowNameBarIcon,_loc1_,"",{
            "mouseDown":this.onNamebarBadgeIconDown,
            "mouseOver":this.onNamebarBadgeIconOver,
            "mouseOut":this.onNamebarBadgeIconOut
         },{
            "currFrameLabel":this.avEditor.member["e"].currentLabel,
            "loadIcons":_loc2_,
            "callbackFunction":this.onNamebarIconsLoaded
         },this.onIconWindowwsLoaded,false,false);
      }
      
      private function onIconWindowwsLoaded() : void
      {
         this.avEditor.namebarPopup.itemWindow.addChild(this._nameBarItemWindows);
         this._nameBarScrollBar = new SBScrollbar();
         this._nameBarScrollBar.init(this._nameBarItemWindows,this._nameBarItemWindows.width,this._nameBarItemWinHeight,8,"scrollbar2",this._nameBarItemWindows.boxHeight + 4);
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
         if(!gMainFrame.userInfo.isMember || this._worldAvatar.isShaman || this._userInfo.isGuide)
         {
            UpsellManager.displayPopup(UpsellManager.NAMEBARS,"namebarIcon");
            return;
         }
         var _loc2_:Object = this._namebarBadgeDefs[param1.currentTarget.index];
         if(!_loc2_ || !gMainFrame.userInfo.isPendingFlagSet(_loc2_.pendingFlagsBit))
         {
            return;
         }
         var _loc3_:int = _loc2_.defId - 1;
         if(this._nameBarData != -1)
         {
            this._nameBarData = (this._nameBarData & 0xFF) + (_loc3_ << 8);
         }
         else
         {
            this._nameBarData = (gMainFrame.userInfo.playerUserInfo.nameBarData & 0xFF) + (_loc3_ << 8);
         }
         this.avEditor.member.setColorAndBadge(this._nameBarData);
         AJAudio.playSubMenuBtnClick();
      }
      
      private function onStatsBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.avEditor.statsPanel.visible = !this.avEditor.statsPanel.visible;
         this.avEditor.currencyBar.visible = !this.avEditor.currencyBar.visible;
         this.avEditor.colorTableBlock.visible = !this.avEditor.colorTableBlock.visible;
         this.avEditor.colorCont.visible = !this.avEditor.colorCont.visible;
      }
      
      private function onStatsBtnOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this.avEditor.statsBtn.isGray)
         {
            return;
         }
         GuiManager.toolTip.init(MovieClip(param1.currentTarget),"Stats",0,-45,true);
         GuiManager.toolTip.startTimer(param1);
      }
      
      private function convertIntToList(param1:int, param2:Boolean, param3:Boolean = true) : Array
      {
         var _loc4_:Array = null;
         if(param2)
         {
            switch(param1)
            {
               case 1:
                  if(param3)
                  {
                     _loc4_ = this._fullAllOldestClothes;
                  }
                  else
                  {
                     _loc4_ = this._allOldestClothes;
                  }
                  break;
               case 2:
                  if(param3)
                  {
                     _loc4_ = this._fullallNewestClothes;
                  }
                  else
                  {
                     _loc4_ = this._allNewestClothes;
                  }
                  break;
               case 3:
                  if(param3)
                  {
                     _loc4_ = this._fullItemTypeItems;
                  }
                  else
                  {
                     _loc4_ = this._itemTypeItems;
                  }
                  break;
               case 4:
                  if(param3)
                  {
                     _loc4_ = this._fullTailItems;
                  }
                  else
                  {
                     _loc4_ = this._tailItems;
                  }
                  break;
               case 5:
                  if(param3)
                  {
                     _loc4_ = this._fullLegItems;
                  }
                  else
                  {
                     _loc4_ = this._legItems;
                  }
                  break;
               case 6:
                  if(param3)
                  {
                     _loc4_ = this._fullBackItems;
                  }
                  else
                  {
                     _loc4_ = this._backItems;
                  }
                  break;
               case 7:
                  if(param3)
                  {
                     _loc4_ = this._fullNeckItems;
                  }
                  else
                  {
                     _loc4_ = this._neckItems;
                  }
                  break;
               case 8:
                  if(param3)
                  {
                     _loc4_ = this._fullHeadItems;
                  }
                  else
                  {
                     _loc4_ = this._headItems;
                  }
            }
         }
         else
         {
            switch(param1)
            {
               case 1:
                  _loc4_ = this._allOldestDenItems;
                  break;
               case 2:
                  _loc4_ = this._allNewestDenItems;
                  break;
               case 3:
                  _loc4_ = this._itemTypeDenItems;
                  break;
               case 4:
                  _loc4_ = this._themeItems;
                  break;
               case 5:
                  _loc4_ = this._floorItems;
            }
         }
         return _loc4_;
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
         var _loc1_:int = 0;
         while(_loc1_ < this._nameBars.length)
         {
            this.avEditor.namebarPopup[this._nameBars[_loc1_]].addEventListener(MouseEvent.MOUSE_DOWN,this.onColorNameBar,false,0,true);
            _loc1_++;
         }
         this.avEditor.member.addEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar,false,0,true);
         this.avEditor.member.addEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver,false,0,true);
         this.avEditor.nonmember.addEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar,false,0,true);
         this.avEditor.nonmember.addEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver,false,0,true);
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
         var _loc1_:int = 0;
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
         if(this._nameBars)
         {
            _loc1_ = 0;
            while(_loc1_ < this._nameBars.length)
            {
               this.avEditor.namebarPopup[this._nameBars[_loc1_]].removeEventListener(MouseEvent.MOUSE_DOWN,this.onColorNameBar);
               _loc1_++;
            }
         }
         this.avEditor.member.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar);
         this.avEditor.nonmember.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMemberNameBar);
         this.avEditor.member.removeEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver);
         this.avEditor.nonmember.removeEventListener(MouseEvent.MOUSE_OVER,this.onMemberNameBarOver);
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

