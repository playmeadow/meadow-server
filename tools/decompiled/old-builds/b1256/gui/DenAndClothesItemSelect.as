package gui
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import item.Item;
   import localization.LocalizationManager;
   
   public class DenAndClothesItemSelect
   {
      
      private static var _normalClothesScrollValue:Number = 0;
      
      private static var _normalDenScrollValue:Number = 0;
      
      private static var _eCardClothesScrollValue:Number = 0;
      
      private static var _eCardDenScrollValue:Number = 0;
      
      private static var _tradeClothesScrollValue:Number = 0;
      
      private static var _tradeDenScrollvalue:Number = 0;
      
      private static var _normalListViewType:int = 0;
      
      private static var _eCardListViewType:int = 0;
      
      private static var _tradeListViewType:int = 1;
      
      private static var _normalDenListSortType:int = 2;
      
      private static var _normalClothingListSortType:int = 2;
      
      private static var _eCardDenListSortType:int = 2;
      
      private static var _eCardClothingListSortType:int = 2;
      
      private static var _tradeDenListSortType:int = 2;
      
      private static var _tradeClothingListSortType:int = 2;
      
      public const WIN_DOWN_STATE:int = 3;
      
      private const NUM_X_WIN:int = 3;
      
      private const NUM_Y_WIN:int = 4;
      
      private const X_WIN_OFFSET:Number = 2;
      
      private const Y_WIN_OFFSET:Number = 2;
      
      private const X_WIN_START:Number = 0;
      
      private const SCROLLBAR_GAP:int = 5;
      
      private const CLOTHING_VIEW_TYPE:int = 0;
      
      private const DEN_VIEW_TYPE:int = 1;
      
      private var _content:MovieClip;
      
      private var _contentPopup:SBPopup;
      
      private var _onCloseCallback:Function;
      
      private var _onGiftBtnCallback:Function;
      
      private var _giftItemIdx:int = -1;
      
      private var _isECard:Boolean;
      
      private var _isChoosingItemsToTrade:Boolean;
      
      private var _itemClothingWindows:WindowGenerator;
      
      private var _itemDenWindows:WindowGenerator;
      
      private var _tradeWindows:WindowGenerator;
      
      private var _scrollButtons:SBScrollbar;
      
      private var _headItems:Array;
      
      private var _neckItems:Array;
      
      private var _backItems:Array;
      
      private var _legItems:Array;
      
      private var _tailItems:Array;
      
      private var _itemTypeItems:Array;
      
      private var _allNewestItems:Array;
      
      private var _allOldestItems:Array;
      
      private var _currClothesArray:Array;
      
      private var _currDenItemsArray:Array;
      
      private var _floorItems:Array;
      
      private var _themeItems:Array;
      
      private var _itemTypeDenItems:Array;
      
      private var _allOldestDenItems:Array;
      
      private var _allNewestDenItems:Array;
      
      private var _currDownMC:Object;
      
      private var _currGiftMC:Object;
      
      private var _spirals:Array;
      
      private var _giftDownIdx:int;
      
      public function DenAndClothesItemSelect()
      {
         super();
      }
      
      public function init(param1:Array, param2:Array, param3:DisplayLayer, param4:Function, param5:Function, param6:Boolean = true, param7:Boolean = false) : void
      {
         var _loc8_:Array = null;
         _content = GETDEFINITIONBYNAME("ECardCreationClothesContent");
         _contentPopup = new SBPopup(param3,GETDEFINITIONBYNAME("ECardCreationClothesSkin"),_content,true,true,false,false,true);
         _onGiftBtnCallback = param4;
         _onCloseCallback = param5;
         _isECard = param6;
         _isChoosingItemsToTrade = param7;
         _currClothesArray = _allNewestItems = param1;
         param2 = discardAudioItems(param2);
         _currDenItemsArray = _allNewestDenItems = param2;
         setInitialStatesAndVisibility();
         if(_isChoosingItemsToTrade)
         {
            if(_tradeListViewType == 0)
            {
               _loc8_ = _currClothesArray = convertIntToList(_tradeClothingListSortType,true);
            }
            else
            {
               _loc8_ = _currDenItemsArray = convertIntToList(_tradeDenListSortType,false);
            }
         }
         else if(_isECard)
         {
            if(_eCardListViewType == 0)
            {
               _loc8_ = _currClothesArray = convertIntToList(_eCardClothingListSortType,true);
            }
            else
            {
               _loc8_ = _currDenItemsArray = convertIntToList(_eCardDenListSortType,false);
            }
         }
         else if(_normalListViewType == 0)
         {
            _loc8_ = _currClothesArray = convertIntToList(_normalClothingListSortType,true);
         }
         else
         {
            _loc8_ = _currDenItemsArray = convertIntToList(_normalDenListSortType,false);
         }
         buildItemWindows(_loc8_);
         addListeners();
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         setCachingOptions();
         if(_content)
         {
            removeListeners();
            _content = null;
         }
         if(_contentPopup)
         {
            _contentPopup.destroy();
            _contentPopup = null;
         }
         if(_tradeWindows)
         {
            _tradeWindows.destroy();
            _tradeWindows = null;
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
         _spirals = null;
      }
      
      public function showHide() : void
      {
         var _loc1_:Array = null;
         if(_currGiftMC)
         {
            _currGiftMC.gift.visible = true;
         }
         if(_contentPopup.visible)
         {
            _contentPopup.close();
            setCachingOptions();
         }
         else
         {
            if(_isChoosingItemsToTrade)
            {
               if(_tradeListViewType == 0)
               {
                  _loc1_ = _currClothesArray = convertIntToList(_tradeClothingListSortType,true);
               }
               else
               {
                  _loc1_ = _currDenItemsArray = convertIntToList(_tradeDenListSortType,false);
               }
            }
            else if(_isECard)
            {
               if(_eCardListViewType == 0)
               {
                  _loc1_ = _currClothesArray = convertIntToList(_eCardClothingListSortType,true);
               }
               else
               {
                  _loc1_ = _currDenItemsArray = convertIntToList(_eCardDenListSortType,false);
               }
            }
            else if(_normalListViewType == 0)
            {
               _loc1_ = _currClothesArray = convertIntToList(_normalClothingListSortType,true);
            }
            else
            {
               _loc1_ = _currDenItemsArray = convertIntToList(_normalDenListSortType,false);
            }
            buildItemWindows(_loc1_);
            _contentPopup.open();
         }
      }
      
      public function removeGift() : void
      {
         _giftItemIdx = -1;
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
      
      private function setInitialStatesAndVisibility() : void
      {
         var _loc1_:int = 0;
         _content.denBtnUp.visible = true;
         _content.denBtnDown.visible = false;
         _content.clothesBtnUp.visible = false;
         _content.clothesBtnDown.visible = true;
         if(!_isECard)
         {
            _content.addBtn.visible = false;
         }
         _content.petsBtnUp.visible = false;
         _content.petsBtnDown.visible = false;
         _headItems = Utility.sortItemsAll(_currClothesArray,0,8,9,10);
         _neckItems = Utility.sortItemsAll(_currClothesArray,0,7);
         _backItems = Utility.sortItemsAll(_currClothesArray,0,6);
         _legItems = Utility.sortItemsAll(_currClothesArray,0,5);
         _tailItems = Utility.sortItemsAll(_currClothesArray,0,4);
         _itemTypeItems = Utility.sortByItem(_currClothesArray,0);
         _allOldestItems = _allNewestItems.concat().reverse();
         if(_isChoosingItemsToTrade)
         {
            _loc1_ = _tradeListViewType;
         }
         else if(_isECard)
         {
            _loc1_ = _eCardListViewType;
         }
         else
         {
            _loc1_ = _normalListViewType;
         }
         if(_isChoosingItemsToTrade)
         {
            LocalizationManager.translateId(_content.clothesTxt,11260);
         }
         if(_loc1_ == 0)
         {
            _content.denBtnUp.visible = false;
            _content.denBtnDown.visible = true;
            _content.clothesBtnUp.visible = true;
            _content.clothesBtnDown.visible = false;
            LocalizationManager.translateId(_content.sort8.txt,11205);
            LocalizationManager.translateId(_content.sort7.txt,11206);
            LocalizationManager.translateId(_content.sort6.txt,11207);
            LocalizationManager.translateId(_content.sort5.txt,11208);
            LocalizationManager.translateId(_content.sort4.txt,11209);
            LocalizationManager.translateId(_content.sort3.txt,11210);
            LocalizationManager.translateId(_content.sort2.txt,11211);
            LocalizationManager.translateId(_content.sort1.txt,11212);
            _content.sort6.visible = true;
            _content.sort7.visible = true;
            _content.sort8.visible = true;
         }
         else
         {
            LocalizationManager.translateId(_content.sort5.txt,11216);
            LocalizationManager.translateId(_content.sort4.txt,11215);
            LocalizationManager.translateId(_content.sort3.txt,11210);
            LocalizationManager.translateId(_content.sort2.txt,11211);
            LocalizationManager.translateId(_content.sort1.txt,11212);
            _content.sort6.visible = false;
            _content.sort7.visible = false;
            _content.sort8.visible = false;
         }
         _floorItems = Utility.sortItems(_currDenItemsArray,0,0,1);
         _themeItems = Utility.sortItems(_currDenItemsArray,0,2,3);
         _itemTypeDenItems = Utility.sortByItem(_currDenItemsArray,0);
         _allOldestDenItems = _allNewestDenItems.concat().reverse();
         _spirals = [];
         _content.sortPopup.visible = false;
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
      
      private function buildItemWindows(param1:Array) : void
      {
         var _loc2_:WindowGenerator = null;
         var _loc14_:Number = NaN;
         var _loc10_:int = 0;
         var _loc15_:Boolean = false;
         var _loc4_:Array = null;
         var _loc3_:Array = null;
         var _loc12_:Array = null;
         var _loc11_:Object = null;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         if(_scrollButtons)
         {
            _scrollButtons.destroy();
            _scrollButtons = null;
         }
         if(!_isECard && _tradeWindows)
         {
            _tradeWindows.destroy();
            _tradeWindows = null;
         }
         while(_content.itemBlock.numChildren > 0)
         {
            _content.itemBlock.removeChildAt(0);
         }
         var _loc9_:int = int(param1.length);
         var _loc7_:int = 0;
         if(_isChoosingItemsToTrade)
         {
            _loc4_ = TradeManager.initiationTradeList;
         }
         else
         {
            _loc4_ = gMainFrame.userInfo.getMyTradeList();
         }
         var _loc13_:int = int(_loc4_.length);
         if(_isECard)
         {
            _loc10_ = Math.ceil(param1.length / 3) * 3;
            if(_eCardListViewType == 0)
            {
               _loc14_ = _eCardClothesScrollValue;
               _loc2_ = _itemClothingWindows;
            }
            else
            {
               _loc14_ = _eCardDenScrollValue;
               _loc2_ = _itemDenWindows;
            }
         }
         else if(param1 == _currClothesArray)
         {
            if(_isChoosingItemsToTrade)
            {
               _loc10_ = Math.ceil((param1.length - TradeManager.numClothingItemsInInitiateTradeList) / 3) * 3;
               _loc14_ = _tradeClothesScrollValue;
            }
            else
            {
               _loc10_ = Math.ceil((param1.length - TradeManager.numClothingItemsInMyTradeList) / 3) * 3;
               _loc14_ = _normalClothesScrollValue;
            }
         }
         else
         {
            if(param1 != _currDenItemsArray)
            {
               throw new Error("None of our lists match given items list");
            }
            if(_isChoosingItemsToTrade)
            {
               _loc10_ = Math.ceil((param1.length - TradeManager.numDenItemsInInitiateTradeList) / 3) * 3;
               _loc14_ = _tradeDenScrollvalue;
            }
            else
            {
               _loc10_ = Math.ceil((param1.length - TradeManager.numDenItemsInMyTradeList) / 3) * 3;
               _loc14_ = _normalDenScrollValue;
            }
         }
         if(_loc2_ == null)
         {
            _loc3_ = [];
            _loc12_ = [];
            _loc11_ = null;
            _loc6_ = 0;
            _loc8_ = 0;
            for(; _loc8_ < _loc9_; _loc8_++)
            {
               if(_loc8_ < _loc9_)
               {
                  _loc11_ = param1[_loc8_].clone();
                  if(!_isECard)
                  {
                     _loc5_ = 0;
                     while(_loc5_ < _loc13_)
                     {
                        if(_isChoosingItemsToTrade)
                        {
                           if((_loc11_ is Item && _loc4_[_loc5_] is Item || _loc11_ is DenItem && _loc4_[_loc5_] is DenItem) && _loc11_.invIdx == _loc4_[_loc5_].invIdx)
                           {
                              _loc15_ = true;
                              break;
                           }
                        }
                        else if((_loc11_ is Item && _loc4_[_loc5_].type == 0 || _loc11_ is DenItem && _loc4_[_loc5_].type == 1) && _loc11_.invIdx == _loc4_[_loc5_].invIdx)
                        {
                           _loc15_ = true;
                           break;
                        }
                        _loc5_++;
                     }
                     if(_loc15_)
                     {
                        _loc15_ = false;
                        _loc7_++;
                        continue;
                     }
                  }
                  if(_giftItemIdx == _loc11_.invIdx)
                  {
                     _giftDownIdx = _loc6_ + _loc7_;
                  }
                  _loc12_.push(_loc6_ + _loc7_);
                  if(_loc11_)
                  {
                     _loc3_.push(_loc11_);
                  }
               }
               _loc6_++;
            }
            _loc2_ = new WindowGenerator();
            if(_isECard)
            {
               if(_eCardListViewType == 0)
               {
                  _itemClothingWindows = _loc2_;
               }
               else
               {
                  _itemDenWindows = _loc2_;
               }
            }
            else
            {
               _tradeWindows = _loc2_;
            }
            _loc2_.init(3,4,Math.max(_loc10_,12),2,2,0,ItemWindowOriginal,_loc3_,"icon",{
               "mouseDown":winMouseDown,
               "mouseOver":winMouseOver,
               "mouseOut":winMouseOut
            },{
               "giftItemIdx":_giftItemIdx,
               "isECard":_isECard,
               "isChoosingForTradeList":_isChoosingItemsToTrade,
               "indexArray":_loc12_
            },onListLoaded);
         }
         _content.itemBlock.addChild(_loc2_);
         _scrollButtons = new SBScrollbar();
         _scrollButtons.init(_loc2_,_loc2_.width,_loc2_.boxHeight * 4 + 2 * (4 - 1) + 2,5,"scrollbar2",_loc2_.boxHeight + 2,_loc14_);
      }
      
      private function onListLoaded() : void
      {
         if(_isECard)
         {
            if(_eCardListViewType == 0)
            {
               _currDownMC = _itemClothingWindows.bg.getChildAt(_giftDownIdx);
            }
            else
            {
               _currDownMC = _itemDenWindows.bg.getChildAt(_giftDownIdx);
            }
         }
         else
         {
            _currDownMC = _tradeWindows.bg.getChildAt(_giftDownIdx);
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
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(_content.denBtnUp.visible)
         {
            _loc2_ = _currDenItemsArray[param1.currentTarget.index];
         }
         else
         {
            _loc2_ = _currClothesArray[param1.currentTarget.index];
         }
         if(_loc2_)
         {
            if(_isECard)
            {
               if(param1.currentTarget.gift.visible && _loc2_.invIdx == _giftItemIdx)
               {
                  _giftItemIdx = -1;
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
               _onCloseCallback(_loc2_);
               destroy();
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
         }
         if(_isECard)
         {
            if(_scrollButtons)
            {
               if(_eCardListViewType == 0)
               {
                  _eCardClothesScrollValue = _scrollButtons.scrollYValue;
               }
               else
               {
                  _eCardDenScrollValue = _scrollButtons.scrollYValue;
               }
            }
            _onCloseCallback();
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
            if(_content.denBtnUp.visible)
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
         _content.sortPopup.visible = !_content.sortPopup.visible;
      }
      
      private function onSortBtns(param1:MouseEvent) : void
      {
         var _loc3_:Array = null;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _content.sort8.name)
         {
            _loc2_ = 0;
            _loc4_ = 8;
            _loc3_ = _currClothesArray = _headItems;
         }
         else if(param1.currentTarget.name == _content.sort7.name)
         {
            _loc2_ = 0;
            _loc4_ = 7;
            _loc3_ = _currClothesArray = _neckItems;
         }
         else if(param1.currentTarget.name == _content.sort6.name)
         {
            _loc2_ = 0;
            _loc4_ = 6;
            _loc3_ = _currClothesArray = _backItems;
         }
         else if(param1.currentTarget.name == _content.sort5.name)
         {
            _loc4_ = 5;
            if(_content.denBtnUp.visible)
            {
               _loc2_ = 1;
               _loc3_ = _currDenItemsArray = _floorItems;
            }
            else
            {
               _loc2_ = 0;
               _loc3_ = _currClothesArray = _legItems;
            }
         }
         else if(param1.currentTarget.name == _content.sort4.name)
         {
            _loc4_ = 4;
            if(_content.denBtnUp.visible)
            {
               _loc2_ = 1;
               _loc3_ = _currDenItemsArray = _themeItems;
            }
            else
            {
               _loc2_ = 0;
               _loc3_ = _currClothesArray = _tailItems;
            }
         }
         else if(param1.currentTarget.name == _content.sort3.name)
         {
            _loc4_ = 3;
            if(_content.denBtnUp.visible)
            {
               _loc2_ = 1;
               _loc3_ = _currDenItemsArray = _itemTypeDenItems;
            }
            else
            {
               _loc2_ = 0;
               _loc3_ = _currClothesArray = _itemTypeItems;
            }
         }
         else if(param1.currentTarget.name == _content.sort2.name)
         {
            _loc4_ = 2;
            if(_content.denBtnUp.visible)
            {
               _loc2_ = 1;
               _loc3_ = _currDenItemsArray = _allNewestDenItems;
            }
            else
            {
               _loc2_ = 0;
               _loc3_ = _currClothesArray = _allNewestItems;
            }
         }
         else if(param1.currentTarget.name == _content.sort1.name)
         {
            _loc4_ = 1;
            if(_content.denBtnUp.visible)
            {
               _loc2_ = 1;
               _loc3_ = _currDenItemsArray = _allOldestDenItems;
            }
            else
            {
               _loc2_ = 0;
               _loc3_ = _currClothesArray = _allOldestItems;
            }
         }
         else if(param1.currentTarget.name == _content.sortPopup.bg.name)
         {
            _content.sortPopup.visible = !_content.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         setCachingOptions(_loc2_,_loc4_,true);
         buildItemWindows(_loc3_);
         _content.sortPopup.visible = !_content.sortPopup.visible;
      }
      
      private function tabBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == _content.denBtnDown.name)
         {
            _loc2_ = 1;
         }
         else if(param1.currentTarget.name == _content.clothesBtnDown.name)
         {
            _loc2_ = 0;
         }
         if(param1.currentTarget.name == _content.denBtnDown.name)
         {
            _content.denBtnUp.visible = true;
            _content.denBtnDown.visible = false;
            _content.clothesBtnUp.visible = false;
            _content.clothesBtnDown.visible = true;
            LocalizationManager.translateId(_content.sort5.txt,11216);
            _content.sort4.txt.text = "Floors";
            LocalizationManager.translateId(_content.sort3.txt,11210);
            LocalizationManager.translateId(_content.sort2.txt,11211);
            LocalizationManager.translateId(_content.sort1.txt,11212);
            _content.sort6.visible = false;
            _content.sort7.visible = false;
            _content.sort8.visible = false;
            setCachingOptions(_loc2_,-1,false,false,true);
            buildItemWindows(_currDenItemsArray);
         }
         else if(param1.currentTarget.name == _content.clothesBtnDown.name)
         {
            _content.denBtnUp.visible = false;
            _content.denBtnDown.visible = true;
            _content.clothesBtnUp.visible = true;
            _content.clothesBtnDown.visible = false;
            LocalizationManager.translateId(_content.sort8.txt,11205);
            LocalizationManager.translateId(_content.sort7.txt,11206);
            LocalizationManager.translateId(_content.sort6.txt,11207);
            LocalizationManager.translateId(_content.sort5.txt,11208);
            LocalizationManager.translateId(_content.sort4.txt,11209);
            LocalizationManager.translateId(_content.sort3.txt,11210);
            LocalizationManager.translateId(_content.sort2.txt,11211);
            LocalizationManager.translateId(_content.sort1.txt,11212);
            _content.sort6.visible = true;
            _content.sort7.visible = true;
            _content.sort8.visible = true;
            setCachingOptions(_loc2_,-1,false,true);
            buildItemWindows(_currClothesArray);
         }
      }
      
      private function setCachingOptions(param1:int = -1, param2:int = -1, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         if(_scrollButtons)
         {
            if(_isChoosingItemsToTrade)
            {
               if(_tradeListViewType == 0)
               {
                  if(param3)
                  {
                     _tradeClothesScrollValue = 0;
                  }
                  else
                  {
                     _tradeClothesScrollValue = _scrollButtons.scrollYValue;
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
                  }
                  else
                  {
                     _tradeDenScrollvalue = _scrollButtons.scrollYValue;
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
                  _currClothesArray = convertIntToList(_tradeClothingListSortType,true);
               }
               if(param5)
               {
                  _currDenItemsArray = convertIntToList(_tradeDenListSortType,false);
               }
            }
            else if(_isECard)
            {
               if(_eCardListViewType == 0)
               {
                  if(param3)
                  {
                     _eCardClothesScrollValue = 0;
                     if(_itemClothingWindows)
                     {
                        _itemClothingWindows.destroy();
                        _itemClothingWindows = null;
                     }
                  }
                  else
                  {
                     _eCardClothesScrollValue = _scrollButtons.scrollYValue;
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
                     if(_itemDenWindows)
                     {
                        _itemDenWindows.destroy();
                        _itemDenWindows = null;
                     }
                  }
                  else
                  {
                     _eCardDenScrollValue = _scrollButtons.scrollYValue;
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
                  _currClothesArray = convertIntToList(_eCardClothingListSortType,true);
               }
               if(param5)
               {
                  _currDenItemsArray = convertIntToList(_eCardDenListSortType,false);
               }
            }
            else
            {
               if(_normalListViewType == 0)
               {
                  if(param3)
                  {
                     _normalClothesScrollValue = 0;
                  }
                  else
                  {
                     _normalClothesScrollValue = _scrollButtons.scrollYValue;
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
                  }
                  else
                  {
                     _normalDenScrollValue = _scrollButtons.scrollYValue;
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
                  _currClothesArray = convertIntToList(_normalClothingListSortType,true);
               }
               if(param5)
               {
                  _currDenItemsArray = convertIntToList(_normalDenListSortType,false);
               }
            }
         }
      }
      
      private function convertIntToList(param1:int, param2:Boolean) : Array
      {
         var _loc3_:Array = null;
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
                  _loc3_ = _itemTypeItems;
                  break;
               case 3:
                  _loc3_ = _tailItems;
                  break;
               case 4:
                  _loc3_ = _legItems;
                  break;
               case 5:
                  _loc3_ = _backItems;
                  break;
               case 6:
                  _loc3_ = _neckItems;
                  break;
               case 7:
                  _loc3_ = _headItems;
            }
         }
         else
         {
            switch(param1 - 1)
            {
               case 0:
                  _loc3_ = _allOldestDenItems;
                  break;
               case 1:
                  _loc3_ = _allNewestDenItems;
                  break;
               case 2:
                  _loc3_ = _itemTypeDenItems;
                  break;
               case 3:
                  _loc3_ = _themeItems;
                  break;
               case 4:
                  _loc3_ = _floorItems;
            }
         }
         return _loc3_;
      }
      
      private function addListeners() : void
      {
         _contentPopup.skin.s["bx"].addEventListener("mouseDown",onClose,false,0,true);
         _content.addBtn.addEventListener("mouseDown",onAddGiftBtn,false,0,true);
         _content.sortBtn.addEventListener("mouseDown",onSortByBtn,false,0,true);
         _content.sort8.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort7.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort6.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort5.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort4.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort3.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort2.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.sort1.addEventListener("mouseDown",onSortBtns,false,0,true);
         _content.denBtnUp.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _content.denBtnDown.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _content.clothesBtnUp.addEventListener("mouseDown",tabBtnHandler,false,0,true);
         _content.clothesBtnDown.addEventListener("mouseDown",tabBtnHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         _contentPopup.skin.s["bx"].removeEventListener("mouseDown",onClose);
         _content.addBtn.removeEventListener("mouseDown",onAddGiftBtn);
         _content.sortBtn.removeEventListener("mouseDown",onSortByBtn);
         _content.sort8.removeEventListener("mouseDown",onSortBtns);
         _content.sort7.removeEventListener("mouseDown",onSortBtns);
         _content.sort6.removeEventListener("mouseDown",onSortBtns);
         _content.sort5.removeEventListener("mouseDown",onSortBtns);
         _content.sort4.removeEventListener("mouseDown",onSortBtns);
         _content.sort3.removeEventListener("mouseDown",onSortBtns);
         _content.sort2.removeEventListener("mouseDown",onSortBtns);
         _content.sort1.removeEventListener("mouseDown",onSortBtns);
         _content.denBtnUp.addEventListener("mouseDown",tabBtnHandler);
         _content.denBtnDown.addEventListener("mouseDown",tabBtnHandler);
         _content.clothesBtnUp.addEventListener("mouseDown",tabBtnHandler);
         _content.clothesBtnDown.addEventListener("mouseDown",tabBtnHandler);
      }
   }
}

