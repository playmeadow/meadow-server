package gui
{
   import collection.AccItemCollection;
   import collection.DenItemCollection;
   import collection.IitemCollection;
   import collection.TradeItemCollection;
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import gui.itemWindows.ItemWindowOriginal;
   import inventory.Iitem;
   import item.Item;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DenAndClothesItemSelect
   {
      
      private static var LAST_VIEWED_TYPE:int = 0;
      
      private const POPUP_MEDIA_ID:int = 4616;
      
      private const WIN_DOWN_STATE:int = 3;
      
      private const NUM_X_WIN:int = 3;
      
      private const NUM_Y_WIN:int = 4;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const SCROLLBAR_GAP:int = 2;
      
      private const CLOTHING_VIEW_TYPE:int = 0;
      
      private const DEN_VIEW_TYPE:int = 1;
      
      private var _normalClothesScrollValue:Number = 0;
      
      private var _normalDenScrollValue:Number = 0;
      
      private var _eCardClothesScrollValue:Number = 0;
      
      private var _eCardDenScrollValue:Number = 0;
      
      private var _tradeClothesScrollValue:Number = 0;
      
      private var _tradeDenScrollvalue:Number = 0;
      
      private var _normalListViewType:int = 0;
      
      private var _eCardListViewType:int = 0;
      
      private var _tradeListViewType:int = 1;
      
      private var _normalDenListSortType:int = 2;
      
      private var _normalClothingListSortType:int = 2;
      
      private var _eCardDenListSortType:int = 2;
      
      private var _eCardClothingListSortType:int = 2;
      
      private var _tradeDenListSortType:int = 2;
      
      private var _tradeClothingListSortType:int = 2;
      
      private var _normalClothingSearchText:String = "";
      
      private var _normalDenSearchText:String = "";
      
      private var _eCardClothesSearchText:String = "";
      
      private var _eCardDenSearchText:String = "";
      
      private var _tradeClothesSearchText:String = "";
      
      private var _tradeDenSearchText:String = "";
      
      private var _popup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _guiLayer:DisplayLayer;
      
      private var _onCloseCallback:Function;
      
      private var _onGiftBtnCallback:Function;
      
      private var _giftItemIdx:int = -1;
      
      private var _giftDownIdx:int;
      
      private var _isECard:Boolean;
      
      private var _isChoosingItemsToTrade:Boolean;
      
      private var _spirals:Array;
      
      private var _itemClothingWindows:WindowAndScrollbarGenerator;
      
      private var _itemDenWindows:WindowAndScrollbarGenerator;
      
      private var _currItemWindow:WindowAndScrollbarGenerator;
      
      private var _headItems:AccItemCollection;
      
      private var _neckItems:AccItemCollection;
      
      private var _backItems:AccItemCollection;
      
      private var _legItems:AccItemCollection;
      
      private var _tailItems:AccItemCollection;
      
      private var _allNewestItems:AccItemCollection;
      
      private var _allOldestItems:AccItemCollection;
      
      private var _currClothesArray:AccItemCollection;
      
      private var _currDenItemsArray:DenItemCollection;
      
      private var _allOldestDenItems:DenItemCollection;
      
      private var _allNewestDenItems:DenItemCollection;
      
      private var _denItemsGemLow:DenItemCollection;
      
      private var _denItemsGemHigh:DenItemCollection;
      
      private var _denItemsNameLow:DenItemCollection;
      
      private var _denItemsNameHigh:DenItemCollection;
      
      private var _customInitiationTradeList:TradeItemCollection;
      
      private var _currDownMC:Object;
      
      private var _currGiftMC:Object;
      
      public function DenAndClothesItemSelect()
      {
         super();
      }
      
      public function init(param1:AccItemCollection, param2:DenItemCollection, param3:DisplayLayer, param4:Function, param5:Function, param6:Boolean = true, param7:Boolean = false, param8:TradeItemCollection = null) : void
      {
         DarkenManager.showLoadingSpiral(true);
         _onGiftBtnCallback = param4;
         _onCloseCallback = param5;
         _isECard = param6;
         _isChoosingItemsToTrade = param7;
         _guiLayer = param3;
         _customInitiationTradeList = param8;
         _currClothesArray = _allNewestItems = param1;
         param2 = param2;
         _currDenItemsArray = _allNewestDenItems = Utility.discardDefaultAudioItem(param2);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(4616,onPopupLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         setCachingOptions();
         if(_popup)
         {
            removeListeners();
            DarkenManager.unDarken(_popup);
            _guiLayer.removeChild(_popup);
            _popup = null;
         }
         if(_itemClothingWindows)
         {
            _itemClothingWindows.destroy();
            _itemClothingWindows = null;
         }
         if(_itemDenWindows)
         {
            _itemDenWindows.destroy();
            _itemDenWindows = null;
         }
         if(_currItemWindow)
         {
            _currItemWindow.destroy();
            _currItemWindow = null;
         }
         if(_spirals && _spirals.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < _spirals.length)
            {
               if(_spirals[_loc1_])
               {
                  _spirals[_loc1_].destroy();
               }
               _loc1_++;
            }
         }
         _onCloseCallback = null;
         _spirals = null;
      }
      
      public function removeGift() : void
      {
         _giftItemIdx = -1;
         _giftDownIdx = -1;
         if(_currDownMC)
         {
            _currDownMC.resetDownGift();
         }
         if(_currGiftMC)
         {
            _currGiftMC.gift.visible = false;
            _currGiftMC = null;
         }
      }
      
      private function onPopupLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _popup = param1.getChildAt(0) as MovieClip;
         _popup.x = 900 * 0.5;
         _popup.y = 550 * 0.5;
         _guiLayer.addChild(_popup);
         DarkenManager.darken(_popup);
         setInitialStatesAndVisibility();
         addListeners();
         if(_isChoosingItemsToTrade)
         {
            if(_tradeListViewType == 0)
            {
               buildItemWindows(_currClothesArray = convertIntToList(_tradeClothingListSortType,true) as AccItemCollection);
            }
            else
            {
               buildItemWindows(_currDenItemsArray = convertIntToList(_tradeDenListSortType,false) as DenItemCollection);
            }
         }
         else if(_isECard)
         {
            if(_eCardListViewType == 0)
            {
               buildItemWindows(_currClothesArray = convertIntToList(_eCardClothingListSortType,true) as AccItemCollection);
            }
            else
            {
               buildItemWindows(_currDenItemsArray = convertIntToList(_eCardDenListSortType,false) as DenItemCollection);
            }
         }
         else if(_normalListViewType == 0)
         {
            buildItemWindows(_currClothesArray = convertIntToList(_normalClothingListSortType,true) as AccItemCollection);
         }
         else
         {
            buildItemWindows(_currDenItemsArray = convertIntToList(_normalDenListSortType,false) as DenItemCollection);
         }
      }
      
      private function setInitialStatesAndVisibility() : void
      {
         var _loc1_:int = 0;
         _popup.denBtnUp.visible = true;
         _popup.denBtnDown.visible = false;
         _popup.clothesBtnUp.visible = false;
         _popup.clothesBtnDown.visible = true;
         _popup.gotoAndStop(_isECard ? "addItem" : "selectItem");
         _popup.petsBtnUp.visible = false;
         _popup.petsBtnDown.visible = false;
         _headItems = Utility.sortItemsAll(_currClothesArray,0,8,9,10) as AccItemCollection;
         _neckItems = Utility.sortItemsAll(_currClothesArray,0,7) as AccItemCollection;
         _backItems = Utility.sortItemsAll(_currClothesArray,0,6) as AccItemCollection;
         _legItems = Utility.sortItemsAll(_currClothesArray,0,5) as AccItemCollection;
         _tailItems = Utility.sortItemsAll(_currClothesArray,0,4) as AccItemCollection;
         _allOldestItems = new AccItemCollection();
         _allOldestItems.setCoreArray(_allNewestItems.getCoreArray().concat().reverse());
         if(_isChoosingItemsToTrade)
         {
            _loc1_ = _tradeListViewType = LAST_VIEWED_TYPE;
         }
         else if(_isECard)
         {
            _loc1_ = _eCardListViewType = LAST_VIEWED_TYPE;
         }
         else
         {
            _loc1_ = _normalListViewType = LAST_VIEWED_TYPE;
         }
         if(_isChoosingItemsToTrade)
         {
            LocalizationManager.translateId(_popup.clothesTxt,11260);
         }
         if(_loc1_ == 0)
         {
            _popup.denBtnUp.visible = false;
            _popup.denBtnDown.visible = true;
            _popup.clothesBtnUp.visible = true;
            _popup.clothesBtnDown.visible = false;
            _popup.sortBtnAccessories.visible = true;
            _popup.sortBtn.visible = false;
            _popup.sortPopupAccessories.sort1.activateSpecifiedItem(true,"time","sort1Dn");
         }
         else
         {
            _popup.sortBtn.gotoAndStop("timeBtnDn");
            _popup.sortBtnAccessories.visible = false;
            _popup.sortBtn.visible = true;
         }
         _allOldestDenItems = new DenItemCollection();
         _allOldestDenItems.setCoreArray(_allNewestDenItems.getCoreArray().concat().reverse());
         _denItemsGemLow = new DenItemCollection(_allNewestDenItems.getCoreArray().concat().sortOn("value",16));
         _denItemsGemHigh = new DenItemCollection(_denItemsGemLow.getCoreArray().concat().reverse());
         _denItemsNameLow = new DenItemCollection(_allNewestDenItems.getCoreArray().concat().sortOn("name",2));
         _denItemsNameHigh = new DenItemCollection(_denItemsNameLow.getCoreArray().concat().reverse());
         _popup.searchBar.mouse.searchTxt.visible = false;
         _popup.searchBar.shortTextWidth = _popup.searchBar.mouse.txt.width + 10;
         _popup.searchBar.wideTextWidth = _popup.searchBar.mouse.searchTxt.width + 10;
         _popup.searchBar.mouse.b.xBtn.visible = false;
         _spirals = [];
         _popup.sortingPopup.visible = false;
         _popup.sortPopupAccessories.visible = false;
      }
      
      private function buildItemWindows(param1:IitemCollection, param2:Boolean = false) : void
      {
         var _loc11_:Number = NaN;
         var _loc4_:IitemCollection = null;
         var _loc12_:TradeItemCollection = null;
         var _loc15_:int = 0;
         var _loc3_:Array = null;
         var _loc5_:Array = null;
         var _loc16_:Iitem = null;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc13_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         while(_popup.itemBlock.numChildren > 1)
         {
            _popup.itemBlock.removeChildAt(_popup.itemBlock.numChildren - 1);
         }
         var _loc14_:String = "";
         if(_isChoosingItemsToTrade)
         {
            _loc4_ = TradeManager.initiationTradeList;
            _loc15_ = int(_loc4_.length);
         }
         else
         {
            _loc12_ = _customInitiationTradeList ? _customInitiationTradeList : gMainFrame.userInfo.getMyTradeList();
            _loc15_ = int(_loc12_.length);
         }
         if(_isECard)
         {
            if(_eCardListViewType == 0)
            {
               _loc11_ = _eCardClothesScrollValue;
               _loc14_ = _eCardClothesSearchText;
               _currItemWindow = _itemClothingWindows;
            }
            else
            {
               _loc11_ = _eCardDenScrollValue;
               _loc14_ = _eCardDenSearchText;
               _currItemWindow = _itemDenWindows;
            }
            LAST_VIEWED_TYPE = _eCardListViewType;
         }
         else if(param1 == _currClothesArray)
         {
            if(_isChoosingItemsToTrade)
            {
               _loc11_ = _tradeClothesScrollValue;
               _loc14_ = _tradeClothesSearchText;
            }
            else
            {
               _loc11_ = _normalClothesScrollValue;
               _loc14_ = _normalClothingSearchText;
            }
            _currItemWindow = _itemClothingWindows;
            LAST_VIEWED_TYPE = 0;
         }
         else
         {
            if(param1 != _currDenItemsArray)
            {
               throw new Error("None of our lists match given items list");
            }
            if(_isChoosingItemsToTrade)
            {
               _loc11_ = _tradeDenScrollvalue;
               _loc14_ = _tradeDenSearchText;
            }
            else
            {
               _loc11_ = _normalDenScrollValue;
               _loc14_ = _normalDenSearchText;
            }
            _currItemWindow = _itemDenWindows;
            LAST_VIEWED_TYPE = 1;
         }
         if(_currItemWindow == null || param2)
         {
            _loc3_ = [];
            _loc5_ = [];
            _loc16_ = null;
            _loc8_ = 0;
            _loc10_ = int(param1.length);
            _loc6_ = 0;
            _loc7_ = 0;
            for(; _loc7_ < _loc10_; _loc7_++)
            {
               if(_loc7_ < _loc10_)
               {
                  _loc16_ = param1.getIitem(_loc7_).clone();
                  if(!_isECard)
                  {
                     _loc9_ = 0;
                     while(_loc9_ < _loc15_)
                     {
                        if(_isChoosingItemsToTrade)
                        {
                           if((_loc16_ is Item && _loc4_.getIitem(_loc9_) is Item || _loc16_ is DenItem && _loc4_.getIitem(_loc9_) is DenItem) && _loc16_.invIdx == _loc4_.getIitem(_loc9_).invIdx)
                           {
                              _loc13_ = true;
                              break;
                           }
                        }
                        else if((_loc16_ is Item && _loc12_.getTradeItem(_loc9_).itemType == 0 || _loc16_ is DenItem && _loc12_.getTradeItem(_loc9_).itemType == 1) && _loc16_.invIdx == _loc12_.getTradeItem(_loc9_).invIdx)
                        {
                           _loc13_ = true;
                           break;
                        }
                        _loc9_++;
                     }
                     if(_loc13_)
                     {
                        _loc13_ = false;
                        _loc6_++;
                        continue;
                     }
                  }
                  if(_giftItemIdx == _loc16_.invIdx)
                  {
                     _giftDownIdx = _loc8_ + _loc6_;
                  }
                  _loc5_.push(_loc8_ + _loc6_);
                  if(_loc16_)
                  {
                     _loc3_.push(_loc16_);
                  }
               }
               _loc8_++;
            }
            _currItemWindow = new WindowAndScrollbarGenerator();
            if(LAST_VIEWED_TYPE == 0)
            {
               _itemClothingWindows = _currItemWindow;
            }
            else
            {
               _itemDenWindows = _currItemWindow;
            }
            _popup.searchBar.mouse.searchTxt.text = "";
            _currItemWindow.init(_popup.itemBlock.width,_popup.itemBlock.height,2,_loc11_,3,4,12,2,2,0,2 * 0.5,ItemWindowOriginal,_loc3_,"icon",0,{
               "mouseDown":winMouseDown,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{
               "giftItemIdx":_giftItemIdx,
               "isECard":_isECard,
               "isChoosingForTradeList":_isChoosingItemsToTrade,
               "indexArray":_loc5_
            },onListLoaded);
         }
         else
         {
            _popup.searchBar.mouse.searchTxt.text = _loc14_;
            onListLoaded();
         }
         _popup.itemBlock.addChild(_currItemWindow);
      }
      
      private function onListLoaded() : void
      {
         onSearchTextInput(null);
         if(_giftDownIdx != -1)
         {
            if(_itemClothingWindows)
            {
               (_itemClothingWindows.bg.getChildAt(_giftDownIdx) as ItemWindowOriginal).resetDownGift();
            }
            if(_itemDenWindows)
            {
               (_itemDenWindows.bg.getChildAt(_giftDownIdx) as ItemWindowOriginal).resetDownGift();
            }
            if(LAST_VIEWED_TYPE == 0)
            {
               _currDownMC = _itemClothingWindows.bg.getChildAt(_giftDownIdx);
            }
            else
            {
               _currDownMC = _itemDenWindows.bg.getChildAt(_giftDownIdx);
            }
         }
      }
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Iitem = null;
         param1.stopPropagation();
         if(param1.currentTarget.name == "previewBtn")
         {
            _loc2_ = param1.currentTarget.parent.parent.currItem;
            GuiManager.openMasterpiecePreview((_loc2_ as DenItem).uniqueImageId,(_loc2_ as DenItem).uniqueImageCreator,(_loc2_ as DenItem).version);
         }
         else
         {
            if(_popup.denBtnUp.visible)
            {
               _loc2_ = _currDenItemsArray.getIitem(param1.currentTarget.index);
            }
            else
            {
               _loc2_ = _currClothesArray.getIitem(param1.currentTarget.index);
            }
            if(_loc2_)
            {
               if(_loc2_.isApproved)
               {
                  if(_isECard)
                  {
                     if(param1.currentTarget.gift.visible && _loc2_.invIdx == _giftItemIdx)
                     {
                        _giftItemIdx = -1;
                        _giftDownIdx = -1;
                        param1.currentTarget.gift.visible = false;
                     }
                     else if(!param1.currentTarget.gift.visible && _loc2_.invIdx != _giftItemIdx)
                     {
                        if(_currDownMC)
                        {
                           _currDownMC.resetDownGift();
                        }
                        _currDownMC = param1.currentTarget.currDownGift = param1.currentTarget;
                        _giftItemIdx = _loc2_.invIdx;
                        _giftDownIdx = param1.currentTarget.index;
                        if(_giftItemIdx <= 0)
                        {
                           return;
                        }
                     }
                     else
                     {
                        DebugUtility.debugTrace("WARNING: Huuuuuuuuh");
                     }
                  }
                  else
                  {
                     _loc2_ is Item ? TradeManager.adjustByOnNumClothingItemsInInitiateTradeList(1) : TradeManager.adjustByOnNumDenItemsInInitiateTradeList(1);
                     if(_onCloseCallback != null)
                     {
                        _onCloseCallback(_loc2_);
                     }
                     else
                     {
                        destroy();
                     }
                  }
               }
               else
               {
                  new SBOkPopup(_guiLayer,LocalizationManager.translateIdOnly(25199));
               }
            }
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_currDownMC)
         {
            _currDownMC.resetDownGift();
            _giftItemIdx = -1;
            _giftDownIdx = -1;
         }
         if(_isECard)
         {
            if(_currItemWindow)
            {
               if(_eCardListViewType == 0)
               {
                  _eCardClothesScrollValue = _currItemWindow.scrollYValue;
               }
               else
               {
                  _eCardDenScrollValue = _currItemWindow.scrollYValue;
               }
            }
         }
         if(_onCloseCallback != null)
         {
            _onCloseCallback(null);
         }
         else
         {
            destroy();
         }
      }
      
      private function onAddGiftBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_giftItemIdx > 0)
         {
            _currGiftMC = _currDownMC;
            if(_popup.denBtnUp.visible)
            {
               _onGiftBtnCallback(_giftItemIdx,false);
            }
            else
            {
               _onGiftBtnCallback(_giftItemIdx);
            }
         }
         else if(_giftItemIdx == 0)
         {
            return;
         }
      }
      
      private function onSortByBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget == _popup.sortBtnAccessories)
         {
            _popup.sortPopupAccessories.visible = !_popup.sortPopupAccessories.visible;
         }
         else if(param1.currentTarget == _popup.sortBtn)
         {
            _popup.sortingPopup.visible = !_popup.sortingPopup.visible;
         }
      }
      
      private function onDenSortBtns(param1:MouseEvent) : void
      {
         var _loc5_:String = null;
         var _loc3_:IitemCollection = null;
         var _loc2_:int = 0;
         var _loc4_:Boolean = false;
         param1.stopPropagation();
         if(param1.currentTarget.name == "timeBtn")
         {
            if(_currDenItemsArray == _allNewestDenItems)
            {
               _loc2_ = 1;
               _loc4_ = _currDenItemsArray != _allOldestDenItems;
               _loc3_ = _currDenItemsArray = _allOldestDenItems;
               _loc5_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Dn");
            }
            else
            {
               _loc2_ = 2;
               _loc4_ = _currDenItemsArray != _allNewestDenItems;
               _loc3_ = _currDenItemsArray = _allNewestDenItems;
               _loc5_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Up");
            }
         }
         else if(param1.currentTarget.name == "gemBtn")
         {
            if(_currDenItemsArray == _denItemsGemLow)
            {
               _loc2_ = 3;
               _loc4_ = _currDenItemsArray != _denItemsGemHigh;
               _loc3_ = _currDenItemsArray = _denItemsGemHigh;
               _loc5_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"gemIcon",param1.currentTarget.name + "Up");
            }
            else
            {
               _loc2_ = 4;
               _loc4_ = _currDenItemsArray != _denItemsGemLow;
               _loc3_ = _currDenItemsArray = _denItemsGemLow;
               _loc5_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"gemIcon",param1.currentTarget.name + "Dn");
            }
         }
         else if(param1.currentTarget.name == "abcBtn")
         {
            if(_currDenItemsArray == _denItemsNameHigh)
            {
               _loc2_ = 5;
               _loc4_ = _currDenItemsArray != _denItemsNameLow;
               _loc3_ = _currDenItemsArray = _denItemsNameLow;
               _loc5_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"abc",param1.currentTarget.name + "Dn");
            }
            else
            {
               _loc2_ = 6;
               _loc4_ = _currDenItemsArray != _denItemsNameHigh;
               _loc3_ = _currDenItemsArray = _denItemsNameHigh;
               _loc5_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"abc",param1.currentTarget.name + "Up");
            }
         }
         _popup.sortBtn.gotoAndStop(param1.currentTarget.name + _loc5_);
         _popup.sortingPopup.visible = false;
         setCachingOptions(1,_loc2_,true);
         buildItemWindows(_loc3_,_loc4_);
         _popup.sortingPopup.visible = !_popup.sortingPopup.visible;
      }
      
      private function onAccessorySortBtns(param1:MouseEvent) : void
      {
         var _loc3_:AccItemCollection = null;
         var _loc2_:int = 0;
         var _loc4_:Boolean = false;
         param1.stopPropagation();
         var _loc5_:String = "";
         if(param1.currentTarget.name == _popup.sortPopupAccessories.sort6.name)
         {
            _loc2_ = 7;
            _loc4_ = _currClothesArray != _headItems;
            _loc3_ = _currClothesArray = _headItems;
         }
         else if(param1.currentTarget.name == _popup.sortPopupAccessories.sort5.name)
         {
            _loc2_ = 6;
            _loc4_ = _currClothesArray != _neckItems;
            _loc3_ = _currClothesArray = _neckItems;
         }
         else if(param1.currentTarget.name == _popup.sortPopupAccessories.sort4.name)
         {
            _loc2_ = 5;
            _loc4_ = _currClothesArray != _backItems;
            _loc3_ = _currClothesArray = _backItems;
         }
         else if(param1.currentTarget.name == _popup.sortPopupAccessories.sort3.name)
         {
            _loc2_ = 4;
            _loc4_ = _currClothesArray != _legItems;
            _loc3_ = _currClothesArray = _legItems;
         }
         else if(param1.currentTarget.name == _popup.sortPopupAccessories.sort2.name)
         {
            _loc2_ = 3;
            _loc4_ = _currClothesArray != _tailItems;
            _loc3_ = _currClothesArray = _tailItems;
         }
         else if(param1.currentTarget.name == _popup.sortPopupAccessories.sort1.name)
         {
            if(_currClothesArray == _allOldestItems)
            {
               _loc2_ = 2;
               _loc4_ = _currClothesArray != _allNewestItems;
               _loc3_ = _currClothesArray = _allNewestItems;
               _loc5_ = "Dn";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Up");
            }
            else
            {
               _loc2_ = 1;
               _loc4_ = _currClothesArray != _allOldestItems;
               _loc3_ = _currClothesArray = _allOldestItems;
               _loc5_ = "Up";
               (param1.currentTarget as GuiSoundButton).activateSpecifiedItem(true,"time",param1.currentTarget.name + "Dn");
            }
         }
         _popup.sortBtnAccessories.gotoAndStop(param1.currentTarget.name + _loc5_);
         if(_loc3_)
         {
            setCachingOptions(0,_loc2_,true);
            buildItemWindows(_loc3_,_loc4_);
            _popup.sortPopupAccessories.visible = !_popup.sortPopupAccessories.visible;
         }
      }
      
      private function tabBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _popup.denBtnDown.name)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget.name == _popup.clothesBtnDown.name)
         {
            _loc2_ = 0;
         }
         if(param1.currentTarget.name == _popup.denBtnDown.name)
         {
            _popup.denBtnUp.visible = true;
            _popup.denBtnDown.visible = false;
            _popup.clothesBtnUp.visible = false;
            _popup.clothesBtnDown.visible = true;
            _popup.sortBtn.visible = true;
            _popup.sortBtnAccessories.visible = false;
            setCachingOptions(_loc2_,-1,false,false,true);
            buildItemWindows(_currDenItemsArray);
         }
         else if(param1.currentTarget.name == _popup.clothesBtnDown.name)
         {
            _popup.denBtnUp.visible = false;
            _popup.denBtnDown.visible = true;
            _popup.clothesBtnUp.visible = true;
            _popup.clothesBtnDown.visible = false;
            _popup.sortBtn.visible = false;
            _popup.sortBtnAccessories.visible = true;
            setCachingOptions(_loc2_,-1,false,true);
            buildItemWindows(_currClothesArray);
         }
         _popup.sortingPopup.visible = false;
         _popup.sortPopupAccessories.visible = false;
      }
      
      private function setCachingOptions(param1:int = -1, param2:int = -1, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         if(_currItemWindow)
         {
            if(_isChoosingItemsToTrade)
            {
               if(_tradeListViewType == 0)
               {
                  if(param3)
                  {
                     _tradeClothesScrollValue = 0;
                     _tradeClothesSearchText = "";
                  }
                  else
                  {
                     _tradeClothesScrollValue = _currItemWindow.scrollYValue;
                     _tradeClothesSearchText = _popup.searchBar.mouse.searchTxt.text;
                  }
                  if(param2 != -1)
                  {
                     _tradeClothingListSortType = param2;
                  }
               }
               else
               {
                  if(param3)
                  {
                     _tradeDenScrollvalue = 0;
                     _tradeDenSearchText = "";
                  }
                  else
                  {
                     _tradeDenScrollvalue = _currItemWindow.scrollYValue;
                     _tradeDenSearchText = _popup.searchBar.mouse.searchTxt.text;
                  }
                  if(param2 != -1)
                  {
                     _tradeDenListSortType = param2;
                  }
               }
               if(param1 != -1)
               {
                  _tradeListViewType = param1;
               }
               if(param4)
               {
                  _currClothesArray = convertIntToList(_tradeClothingListSortType,true) as AccItemCollection;
               }
               if(param5)
               {
                  _currDenItemsArray = convertIntToList(_tradeDenListSortType,false) as DenItemCollection;
               }
            }
            else if(_isECard)
            {
               if(_eCardListViewType == 0)
               {
                  if(param3)
                  {
                     _eCardClothesScrollValue = 0;
                     _eCardClothesSearchText = "";
                     if(_itemClothingWindows)
                     {
                        _itemClothingWindows.destroy();
                        _itemClothingWindows = null;
                     }
                  }
                  else
                  {
                     _eCardClothesScrollValue = _currItemWindow.scrollYValue;
                     _eCardClothesSearchText = _popup.searchBar.mouse.searchTxt.text;
                  }
                  if(param2 != -1)
                  {
                     _eCardClothingListSortType = param2;
                  }
               }
               else
               {
                  if(param3)
                  {
                     _eCardDenScrollValue = 0;
                     _eCardDenSearchText = "";
                     if(_itemDenWindows)
                     {
                        _itemDenWindows.destroy();
                        _itemDenWindows = null;
                     }
                  }
                  else
                  {
                     _eCardDenScrollValue = _currItemWindow.scrollYValue;
                     _eCardDenSearchText = _popup.searchBar.mouse.searchTxt.text;
                  }
                  if(param2 != -1)
                  {
                     _eCardDenListSortType = param2;
                  }
               }
               if(param1 != -1)
               {
                  _eCardListViewType = param1;
               }
               if(param4)
               {
                  _currClothesArray = convertIntToList(_eCardClothingListSortType,true) as AccItemCollection;
               }
               if(param5)
               {
                  _currDenItemsArray = convertIntToList(_eCardDenListSortType,false) as DenItemCollection;
               }
            }
            else
            {
               if(_normalListViewType == 0)
               {
                  if(param3)
                  {
                     _normalClothesScrollValue = 0;
                     _normalClothingSearchText = "";
                  }
                  else
                  {
                     _normalClothesScrollValue = _currItemWindow.scrollYValue;
                     _normalClothingSearchText = _popup.searchBar.mouse.searchTxt.text;
                  }
                  if(param2 != -1)
                  {
                     _normalClothingListSortType = param2;
                  }
               }
               else
               {
                  if(param3)
                  {
                     _normalDenScrollValue = 0;
                     _normalDenSearchText = "";
                  }
                  else
                  {
                     _normalDenScrollValue = _currItemWindow.scrollYValue;
                     _normalDenSearchText = _popup.searchBar.mouse.searchTxt.text;
                  }
                  if(param2 != -1)
                  {
                     _normalDenListSortType = param2;
                  }
               }
               if(param1 != -1)
               {
                  _normalListViewType = param1;
               }
               if(param4)
               {
                  _currClothesArray = convertIntToList(_normalClothingListSortType,true) as AccItemCollection;
               }
               if(param5)
               {
                  _currDenItemsArray = convertIntToList(_normalDenListSortType,false) as DenItemCollection;
               }
            }
         }
      }
      
      private function convertIntToList(param1:int, param2:Boolean) : IitemCollection
      {
         var _loc3_:AccItemCollection = null;
         var _loc4_:DenItemCollection = null;
         if(param2)
         {
            switch(param1 - 1)
            {
               case 0:
                  _loc3_ = _allOldestItems;
                  break;
               case 1:
                  _loc3_ = _allNewestItems;
                  break;
               case 2:
                  _loc3_ = _tailItems;
                  break;
               case 3:
                  _loc3_ = _legItems;
                  break;
               case 4:
                  _loc3_ = _backItems;
                  break;
               case 5:
                  _loc3_ = _neckItems;
                  break;
               case 6:
                  _loc3_ = _headItems;
            }
            return _loc3_ as IitemCollection;
         }
         switch(param1 - 1)
         {
            case 0:
               _loc4_ = _allNewestDenItems;
               break;
            case 1:
               _loc4_ = _allOldestDenItems;
               break;
            case 2:
               _loc4_ = _denItemsGemLow;
               break;
            case 3:
               _loc4_ = _denItemsNameLow;
               break;
            case 4:
               _loc4_ = _denItemsNameHigh;
         }
         return _loc4_ as IitemCollection;
      }
      
      private function clearCurrentSearchText() : void
      {
         if(_isChoosingItemsToTrade)
         {
            if(_tradeListViewType == 0)
            {
               _tradeClothesSearchText = "";
            }
            else
            {
               _tradeDenSearchText = "";
            }
         }
         else if(_isECard)
         {
            if(_eCardListViewType == 0)
            {
               _eCardClothesSearchText = "";
            }
            else
            {
               _eCardDenSearchText = "";
            }
         }
         else if(_eCardListViewType == 0)
         {
            _normalClothingSearchText = "";
         }
         else
         {
            _normalDenSearchText = "";
         }
      }
      
      private function onSearchTextInput(param1:Event) : void
      {
         if(_currItemWindow)
         {
            _currItemWindow.handleSearchInput(_popup.searchBar.mouse.searchTxt.text);
            resizeSearchBtn(_popup.searchBar.mouse,_popup.searchBar.mouse.searchTxt.text.length > 0);
         }
      }
      
      private function onSearchBarDown(param1:MouseEvent) : void
      {
         var _loc2_:MovieClip = _popup.searchBar.mouse;
         AJAudio.playHudBtnClick();
         if(param1)
         {
            param1.stopPropagation();
            if(_loc2_.open)
            {
               if(!_loc2_.b.hitTestPoint(param1.stageX,param1.stageY,false))
               {
                  return;
               }
               _loc2_.open = false;
               _loc2_.searchTxt.text = "";
               clearCurrentSearchText();
               onSearchTextInput(null);
            }
            else
            {
               _loc2_.open = true;
               gMainFrame.stage.focus = _loc2_.searchTxt;
            }
         }
         else
         {
            _loc2_.open = false;
            _loc2_.searchTxt.text = "";
            clearCurrentSearchText();
            onSearchTextInput(null);
         }
         resizeSearchBtn(_loc2_,_loc2_.open);
      }
      
      private function resizeSearchBtn(param1:MovieClip, param2:Boolean) : void
      {
         if(gMainFrame.stage.focus == _popup.searchBar.mouse.searchTxt)
         {
            param2 = true;
         }
         param1.m.width = param2 ? _popup.searchBar.wideTextWidth : _popup.searchBar.shortTextWidth;
         param1.b.x = param1.m.x + param1.m.width;
         param1.open = param2;
         param1.b.xBtn.visible = param1.open;
         param1.txt.visible = !param1.open;
         param1.txt.visible = !param1.open;
         param1.searchTxt.visible = param1.open;
         if(param2)
         {
            _popup.sortingPopup.visible = false;
            _popup.sortBtn.visible = false;
            _popup.sortPopupAccessories.visible = false;
            _popup.sortBtnAccessories.visible = false;
         }
         else if(_isChoosingItemsToTrade)
         {
            if(_tradeListViewType == 0)
            {
               _popup.sortBtnAccessories.visible = true;
            }
            else
            {
               _popup.sortBtn.visible = true;
            }
         }
         else if(_eCardListViewType == 0)
         {
            _popup.sortBtnAccessories.visible = true;
         }
         else
         {
            _popup.sortBtn.visible = true;
         }
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
      
      private function addListeners() : void
      {
         _popup.bx.addEventListener("mouseDown",onClose,false,0,true);
         if(_popup.addBtn)
         {
            _popup.addBtn.addEventListener("mouseDown",onAddGiftBtn,false,0,true);
         }
         _popup.sortBtn.addEventListener("mouseDown",onSortByBtn,false,0,true);
         _popup.sortBtnAccessories.addEventListener("mouseDown",onSortByBtn,false,0,true);
         _popup.sortPopupAccessories.sort6.addEventListener("mouseDown",onAccessorySortBtns,false,0,true);
         _popup.sortPopupAccessories.sort5.addEventListener("mouseDown",onAccessorySortBtns,false,0,true);
         _popup.sortPopupAccessories.sort4.addEventListener("mouseDown",onAccessorySortBtns,false,0,true);
         _popup.sortPopupAccessories.sort3.addEventListener("mouseDown",onAccessorySortBtns,false,0,true);
         _popup.sortPopupAccessories.sort2.addEventListener("mouseDown",onAccessorySortBtns,false,0,true);
         _popup.sortPopupAccessories.sort1.addEventListener("mouseDown",onAccessorySortBtns,false,0,true);
         _popup.sortingPopup.timeBtn.addEventListener("mouseDown",onDenSortBtns,false,0,true);
         _popup.sortingPopup.gemBtn.addEventListener("mouseDown",onDenSortBtns,false,0,true);
         _popup.sortingPopup.abcBtn.addEventListener("mouseDown",onDenSortBtns,false,0,true);
         _popup.denBtnUp.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _popup.denBtnDown.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _popup.clothesBtnUp.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _popup.clothesBtnDown.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _popup.searchBar.addEventListener("change",onSearchTextInput,false,0,true);
         _popup.searchBar.addEventListener("mouseDown",onSearchBarDown,false,0,true);
         _popup.searchBar.addEventListener("mouseOver",onSearchBarOver,false,0,true);
         _popup.searchBar.addEventListener("mouseOut",onSearchBarOut,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _popup.bx.removeEventListener("mouseDown",onClose);
         if(_popup.addBtn)
         {
            _popup.addBtn.removeEventListener("mouseDown",onAddGiftBtn);
         }
         _popup.sortBtn.removeEventListener("mouseDown",onSortByBtn);
         _popup.sortBtnAccessories.removeEventListener("mouseDown",onSortByBtn);
         _popup.sortPopupAccessories.sort6.removeEventListener("mouseDown",onAccessorySortBtns);
         _popup.sortPopupAccessories.sort5.removeEventListener("mouseDown",onAccessorySortBtns);
         _popup.sortPopupAccessories.sort4.removeEventListener("mouseDown",onAccessorySortBtns);
         _popup.sortPopupAccessories.sort3.removeEventListener("mouseDown",onAccessorySortBtns);
         _popup.sortPopupAccessories.sort2.removeEventListener("mouseDown",onAccessorySortBtns);
         _popup.sortPopupAccessories.sort1.removeEventListener("mouseDown",onAccessorySortBtns);
         _popup.sortingPopup.timeBtn.removeEventListener("mouseDown",onDenSortBtns);
         _popup.sortingPopup.gemBtn.removeEventListener("mouseDown",onDenSortBtns);
         _popup.sortingPopup.abcBtn.removeEventListener("mouseDown",onDenSortBtns);
         _popup.denBtnUp.addEventListener("mouseDown",tabBtnHandler);
         _popup.denBtnDown.addEventListener("mouseDown",tabBtnHandler);
         _popup.clothesBtnUp.addEventListener("mouseDown",tabBtnHandler);
         _popup.clothesBtnDown.addEventListener("mouseDown",tabBtnHandler);
         _popup.searchBar.removeEventListener("change",onSearchTextInput);
         _popup.searchBar.removeEventListener("mouseDown",onSearchBarDown);
         _popup.searchBar.removeEventListener("mouseOver",onSearchBarOver);
         _popup.searchBar.removeEventListener("mouseOut",onSearchBarOut);
      }
   }
}

