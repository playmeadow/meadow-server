package gui
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBOkPopup;
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
      
      public function init(initClothes:Array, initDenItems:Array, initGuiLayer:DisplayLayer, initGiftBtnCallback:Function, initCloseCallback:Function, initIsEcard:Boolean = true, initIsChoosingItemsToTrade:Boolean = false) : void
      {
         var currBuildArray:Array = null;
         this._content = GETDEFINITIONBYNAME("ECardCreationClothesContent");
         this._contentPopup = new SBPopup(initGuiLayer,GETDEFINITIONBYNAME("ECardCreationClothesSkin"),this._content,true,true,false,false,true);
         this._onGiftBtnCallback = initGiftBtnCallback;
         this._onCloseCallback = initCloseCallback;
         this._isECard = initIsEcard;
         this._isChoosingItemsToTrade = initIsChoosingItemsToTrade;
         this._currClothesArray = this._allNewestItems = initClothes;
         initDenItems = this.discardAudioItems(initDenItems);
         this._currDenItemsArray = this._allNewestDenItems = initDenItems;
         this.setInitialStatesAndVisibility();
         if(this._isChoosingItemsToTrade)
         {
            if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
            {
               currBuildArray = this._currClothesArray = this.convertIntToList(_tradeClothingListSortType,true);
            }
            else
            {
               currBuildArray = this._currDenItemsArray = this.convertIntToList(_tradeDenListSortType,false);
            }
         }
         else if(this._isECard)
         {
            if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
            {
               currBuildArray = this._currClothesArray = this.convertIntToList(_eCardClothingListSortType,true);
            }
            else
            {
               currBuildArray = this._currDenItemsArray = this.convertIntToList(_eCardDenListSortType,false);
            }
         }
         else if(_normalListViewType == this.CLOTHING_VIEW_TYPE)
         {
            currBuildArray = this._currClothesArray = this.convertIntToList(_normalClothingListSortType,true);
         }
         else
         {
            currBuildArray = this._currDenItemsArray = this.convertIntToList(_normalDenListSortType,false);
         }
         this.buildItemWindows(currBuildArray);
         this.addListeners();
      }
      
      public function destroy() : void
      {
         var j:int = 0;
         this.setCachingOptions();
         if(Boolean(this._content))
         {
            this.removeListeners();
            this._content = null;
         }
         if(Boolean(this._contentPopup))
         {
            this._contentPopup.destroy();
            this._contentPopup = null;
         }
         if(Boolean(this._tradeWindows))
         {
            this._tradeWindows.destroy();
            this._tradeWindows = null;
         }
         if(Boolean(this._itemClothingWindows))
         {
            this._itemClothingWindows.destroy();
            this._itemClothingWindows = null;
         }
         if(Boolean(this._itemDenWindows))
         {
            this._itemDenWindows.destroy();
            this._itemDenWindows = null;
         }
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            for(j = 0; j < this._spirals.length; j++)
            {
               if(Boolean(this._spirals[j]))
               {
                  this._spirals[j].destroy();
               }
            }
         }
         this._spirals = null;
      }
      
      public function showHide() : void
      {
         var currBuildArray:Array = null;
         if(Boolean(this._currGiftMC))
         {
            this._currGiftMC.gift.visible = true;
         }
         if(this._contentPopup.visible)
         {
            this._contentPopup.close();
            this.setCachingOptions();
         }
         else
         {
            if(this._isChoosingItemsToTrade)
            {
               if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  currBuildArray = this._currClothesArray = this.convertIntToList(_tradeClothingListSortType,true);
               }
               else
               {
                  currBuildArray = this._currDenItemsArray = this.convertIntToList(_tradeDenListSortType,false);
               }
            }
            else if(this._isECard)
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  currBuildArray = this._currClothesArray = this.convertIntToList(_eCardClothingListSortType,true);
               }
               else
               {
                  currBuildArray = this._currDenItemsArray = this.convertIntToList(_eCardDenListSortType,false);
               }
            }
            else if(_normalListViewType == this.CLOTHING_VIEW_TYPE)
            {
               currBuildArray = this._currClothesArray = this.convertIntToList(_normalClothingListSortType,true);
            }
            else
            {
               currBuildArray = this._currDenItemsArray = this.convertIntToList(_normalDenListSortType,false);
            }
            this.buildItemWindows(currBuildArray);
            this._contentPopup.open();
         }
      }
      
      public function removeGift() : void
      {
         this._giftItemIdx = -1;
         if(Boolean(this._currDownMC))
         {
            this._currDownMC.resetDownGift();
         }
         if(Boolean(this._currGiftMC))
         {
            this._currGiftMC.gift.visible = false;
            this._currGiftMC = null;
         }
      }
      
      private function setInitialStatesAndVisibility() : void
      {
         var viewType:int = 0;
         this._content.denBtnUp.visible = true;
         this._content.denBtnDown.visible = false;
         this._content.clothesBtnUp.visible = false;
         this._content.clothesBtnDown.visible = true;
         if(!this._isECard)
         {
            this._content.addBtn.visible = false;
         }
         this._content.petsBtnUp.visible = false;
         this._content.petsBtnDown.visible = false;
         this._headItems = Utility.sortItemsAll(this._currClothesArray,0,Item.HEAD_LAYER_1,Item.HEAD_LAYER_2,Item.HEAD_LAYER_3);
         this._neckItems = Utility.sortItemsAll(this._currClothesArray,0,Item.NECK_LAYER);
         this._backItems = Utility.sortItemsAll(this._currClothesArray,0,Item.BACK_LAYER);
         this._legItems = Utility.sortItemsAll(this._currClothesArray,0,Item.LEG_LAYER);
         this._tailItems = Utility.sortItemsAll(this._currClothesArray,0,Item.TAIL_LAYER);
         this._itemTypeItems = Utility.sortByItem(this._currClothesArray,0);
         this._allOldestItems = this._allNewestItems.concat().reverse();
         if(this._isChoosingItemsToTrade)
         {
            viewType = _tradeListViewType;
         }
         else if(this._isECard)
         {
            viewType = _eCardListViewType;
         }
         else
         {
            viewType = _normalListViewType;
         }
         if(this._isChoosingItemsToTrade)
         {
            LocalizationManager.translateId(this._content.clothesTxt,11260);
         }
         if(viewType == this.CLOTHING_VIEW_TYPE)
         {
            this._content.denBtnUp.visible = false;
            this._content.denBtnDown.visible = true;
            this._content.clothesBtnUp.visible = true;
            this._content.clothesBtnDown.visible = false;
            LocalizationManager.translateId(this._content.sort8.txt,11205);
            LocalizationManager.translateId(this._content.sort7.txt,11206);
            LocalizationManager.translateId(this._content.sort6.txt,11207);
            LocalizationManager.translateId(this._content.sort5.txt,11208);
            LocalizationManager.translateId(this._content.sort4.txt,11209);
            LocalizationManager.translateId(this._content.sort3.txt,11210);
            LocalizationManager.translateId(this._content.sort2.txt,11211);
            LocalizationManager.translateId(this._content.sort1.txt,11212);
            this._content.sort6.visible = true;
            this._content.sort7.visible = true;
            this._content.sort8.visible = true;
         }
         else
         {
            LocalizationManager.translateId(this._content.sort5.txt,11216);
            LocalizationManager.translateId(this._content.sort4.txt,11215);
            LocalizationManager.translateId(this._content.sort3.txt,11210);
            LocalizationManager.translateId(this._content.sort2.txt,11211);
            LocalizationManager.translateId(this._content.sort1.txt,11212);
            this._content.sort6.visible = false;
            this._content.sort7.visible = false;
            this._content.sort8.visible = false;
         }
         this._floorItems = Utility.sortItems(this._currDenItemsArray,0,DenItem.SORT_FLOOR,DenItem.SORT_WALL);
         this._themeItems = Utility.sortItems(this._currDenItemsArray,0,DenItem.SORT_FLOORING,DenItem.SORT_WALLPAPER);
         this._itemTypeDenItems = Utility.sortByItem(this._currDenItemsArray,0);
         this._allOldestDenItems = this._allNewestDenItems.concat().reverse();
         this._spirals = [];
         this._content.sortPopup.visible = false;
      }
      
      private function discardAudioItems(denItems:Array) : Array
      {
         var tempArray:Array = [];
         for(var i:int = 0; i < denItems.length; i++)
         {
            if(denItems[i].itemDefId != DenItem.DEF_AUDIO_DEF_ID)
            {
               tempArray.push(denItems[i]);
            }
         }
         return tempArray;
      }
      
      private function buildItemWindows(itemsArray:Array) : void
      {
         var currItemWindow:WindowGenerator = null;
         var scrollValue:Number = NaN;
         var numWin:int = 0;
         var found:Boolean = false;
         var tradeList:Array = null;
         var currItems:Array = null;
         var indexArray:Array = null;
         var currItem:Object = null;
         var j:int = 0;
         var i:int = 0;
         var l:int = 0;
         if(Boolean(this._scrollButtons))
         {
            this._scrollButtons.destroy();
            this._scrollButtons = null;
         }
         if(!this._isECard && Boolean(this._tradeWindows))
         {
            this._tradeWindows.destroy();
            this._tradeWindows = null;
         }
         while(this._content.itemBlock.numChildren > 0)
         {
            this._content.itemBlock.removeChildAt(0);
         }
         var numItems:int = int(itemsArray.length);
         var numSkipped:int = 0;
         if(this._isChoosingItemsToTrade)
         {
            tradeList = TradeManager.initiationTradeList;
         }
         else
         {
            tradeList = gMainFrame.userInfo.getMyTradeList();
         }
         var tradesArrayLength:int = int(tradeList.length);
         if(this._isECard)
         {
            numWin = Math.ceil(itemsArray.length / this.NUM_X_WIN) * this.NUM_X_WIN;
            if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
            {
               scrollValue = _eCardClothesScrollValue;
               currItemWindow = this._itemClothingWindows;
            }
            else
            {
               scrollValue = _eCardDenScrollValue;
               currItemWindow = this._itemDenWindows;
            }
         }
         else if(itemsArray == this._currClothesArray)
         {
            if(this._isChoosingItemsToTrade)
            {
               numWin = Math.ceil((itemsArray.length - TradeManager.numClothingItemsInInitiateTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               scrollValue = _tradeClothesScrollValue;
            }
            else
            {
               numWin = Math.ceil((itemsArray.length - TradeManager.numClothingItemsInMyTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               scrollValue = _normalClothesScrollValue;
            }
         }
         else
         {
            if(itemsArray != this._currDenItemsArray)
            {
               throw new Error("None of our lists match given items list");
            }
            if(this._isChoosingItemsToTrade)
            {
               numWin = Math.ceil((itemsArray.length - TradeManager.numDenItemsInInitiateTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               scrollValue = _tradeDenScrollvalue;
            }
            else
            {
               numWin = Math.ceil((itemsArray.length - TradeManager.numDenItemsInMyTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               scrollValue = _normalDenScrollValue;
            }
         }
         if(currItemWindow == null)
         {
            currItems = [];
            indexArray = [];
            currItem = null;
            j = 0;
            for(i = 0; i < numItems; i++)
            {
               if(i < numItems)
               {
                  currItem = itemsArray[i].clone();
                  if(!this._isECard)
                  {
                     for(l = 0; l < tradesArrayLength; l++)
                     {
                        if(this._isChoosingItemsToTrade)
                        {
                           if((currItem is Item && tradeList[l] is Item || currItem is DenItem && tradeList[l] is DenItem) && currItem.invIdx == tradeList[l].invIdx)
                           {
                              found = true;
                              break;
                           }
                        }
                        else if((currItem is Item && tradeList[l].type == 0 || currItem is DenItem && tradeList[l].type == 1) && currItem.invIdx == tradeList[l].invIdx)
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
                  if(this._giftItemIdx == currItem.invIdx)
                  {
                     this._giftDownIdx = j + numSkipped;
                  }
                  indexArray.push(j + numSkipped);
                  if(Boolean(currItem))
                  {
                     currItems.push(currItem);
                  }
               }
               j++;
            }
            currItemWindow = new WindowGenerator();
            if(this._isECard)
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  this._itemClothingWindows = currItemWindow;
               }
               else
               {
                  this._itemDenWindows = currItemWindow;
               }
            }
            else
            {
               this._tradeWindows = currItemWindow;
            }
            currItemWindow.init(this.NUM_X_WIN,this.NUM_Y_WIN,Math.max(numWin,12),this.X_WIN_OFFSET,this.Y_WIN_OFFSET,this.X_WIN_START,ItemWindowOriginal,currItems,"icon",{
               "mouseDown":this.winMouseDown,
               "mouseOver":this.winMouseOver,
               "mouseOut":this.winMouseOut
            },{
               "giftItemIdx":this._giftItemIdx,
               "isECard":this._isECard,
               "isChoosingForTradeList":this._isChoosingItemsToTrade,
               "indexArray":indexArray
            },this.onListLoaded);
         }
         this._content.itemBlock.addChild(currItemWindow);
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(currItemWindow,currItemWindow.width,currItemWindow.boxHeight * this.NUM_Y_WIN + this.Y_WIN_OFFSET * (this.NUM_Y_WIN - 1) + this.Y_WIN_OFFSET,this.SCROLLBAR_GAP,"scrollbar2",currItemWindow.boxHeight + this.Y_WIN_OFFSET,scrollValue);
      }
      
      private function onListLoaded() : void
      {
         if(this._isECard)
         {
            if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
            {
               this._currDownMC = this._itemClothingWindows.bg.getChildAt(this._giftDownIdx);
            }
            else
            {
               this._currDownMC = this._itemDenWindows.bg.getChildAt(this._giftDownIdx);
            }
         }
         else
         {
            this._currDownMC = this._tradeWindows.bg.getChildAt(this._giftDownIdx);
         }
      }
      
      private function winMouseOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
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
      
      private function winMouseDown(evt:MouseEvent) : void
      {
         var currItem:Object = null;
         evt.stopPropagation();
         if(Boolean(this._content.denBtnUp.visible))
         {
            currItem = this._currDenItemsArray[evt.currentTarget.index];
         }
         else
         {
            currItem = this._currClothesArray[evt.currentTarget.index];
         }
         if(Boolean(currItem))
         {
            if(this._isECard)
            {
               if(Boolean(evt.currentTarget.gift.visible) && currItem.invIdx == this._giftItemIdx)
               {
                  this._giftItemIdx = -1;
                  evt.currentTarget.gift.visible = false;
               }
               else if(!evt.currentTarget.gift.visible && currItem.invIdx != this._giftItemIdx)
               {
                  if(Boolean(this._currDownMC))
                  {
                     this._currDownMC.resetDownGift();
                  }
                  this._currDownMC = evt.currentTarget.currDownGift = evt.currentTarget;
                  this._giftItemIdx = currItem.invIdx;
                  if(this._giftItemIdx <= 0)
                  {
                     new SBOkPopup(GuiManager.guiLayer,"ERROR 1: If you see this, come talk to Colter");
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
               if(currItem is Item)
               {
                  TradeManager.adjustByOnNumClothingItemsInInitiateTradeList(1);
               }
               else
               {
                  TradeManager.adjustByOnNumDenItemsInInitiateTradeList(1);
               }
               this._onCloseCallback(currItem);
               this.destroy();
            }
         }
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._currDownMC))
         {
            this._currDownMC.resetDownGift();
            this._giftItemIdx = -1;
         }
         if(this._isECard)
         {
            if(Boolean(this._scrollButtons))
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  _eCardClothesScrollValue = this._scrollButtons.scrollYValue;
               }
               else
               {
                  _eCardDenScrollValue = this._scrollButtons.scrollYValue;
               }
            }
            this._onCloseCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onAddGiftBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._giftItemIdx > 0)
         {
            this._currGiftMC = this._currDownMC;
            if(Boolean(this._content.denBtnUp.visible))
            {
               this._onGiftBtnCallback(this._giftItemIdx,false);
            }
            else
            {
               this._onGiftBtnCallback(this._giftItemIdx);
            }
         }
         else if(this._giftItemIdx == 0)
         {
            new SBOkPopup(GuiManager.guiLayer,"ERROR 2: If you see this, come talk to Colter");
            return;
         }
      }
      
      private function onSortByBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this._content.sortPopup.visible = !this._content.sortPopup.visible;
      }
      
      private function onSortBtns(evt:MouseEvent) : void
      {
         var arrayToBuild:Array = null;
         var currListViewType:int = 0;
         var currSortType:int = 0;
         evt.stopPropagation();
         if(evt.currentTarget.name == this._content.sort8.name)
         {
            currListViewType = this.CLOTHING_VIEW_TYPE;
            currSortType = 8;
            arrayToBuild = this._currClothesArray = this._headItems;
         }
         else if(evt.currentTarget.name == this._content.sort7.name)
         {
            currListViewType = this.CLOTHING_VIEW_TYPE;
            currSortType = 7;
            arrayToBuild = this._currClothesArray = this._neckItems;
         }
         else if(evt.currentTarget.name == this._content.sort6.name)
         {
            currListViewType = this.CLOTHING_VIEW_TYPE;
            currSortType = 6;
            arrayToBuild = this._currClothesArray = this._backItems;
         }
         else if(evt.currentTarget.name == this._content.sort5.name)
         {
            currSortType = 5;
            if(Boolean(this._content.denBtnUp.visible))
            {
               currListViewType = this.DEN_VIEW_TYPE;
               arrayToBuild = this._currDenItemsArray = this._floorItems;
            }
            else
            {
               currListViewType = this.CLOTHING_VIEW_TYPE;
               arrayToBuild = this._currClothesArray = this._legItems;
            }
         }
         else if(evt.currentTarget.name == this._content.sort4.name)
         {
            currSortType = 4;
            if(Boolean(this._content.denBtnUp.visible))
            {
               currListViewType = this.DEN_VIEW_TYPE;
               arrayToBuild = this._currDenItemsArray = this._themeItems;
            }
            else
            {
               currListViewType = this.CLOTHING_VIEW_TYPE;
               arrayToBuild = this._currClothesArray = this._tailItems;
            }
         }
         else if(evt.currentTarget.name == this._content.sort3.name)
         {
            currSortType = 3;
            if(Boolean(this._content.denBtnUp.visible))
            {
               currListViewType = this.DEN_VIEW_TYPE;
               arrayToBuild = this._currDenItemsArray = this._itemTypeDenItems;
            }
            else
            {
               currListViewType = this.CLOTHING_VIEW_TYPE;
               arrayToBuild = this._currClothesArray = this._itemTypeItems;
            }
         }
         else if(evt.currentTarget.name == this._content.sort2.name)
         {
            currSortType = 2;
            if(Boolean(this._content.denBtnUp.visible))
            {
               currListViewType = this.DEN_VIEW_TYPE;
               arrayToBuild = this._currDenItemsArray = this._allNewestDenItems;
            }
            else
            {
               currListViewType = this.CLOTHING_VIEW_TYPE;
               arrayToBuild = this._currClothesArray = this._allNewestItems;
            }
         }
         else if(evt.currentTarget.name == this._content.sort1.name)
         {
            currSortType = 1;
            if(Boolean(this._content.denBtnUp.visible))
            {
               currListViewType = this.DEN_VIEW_TYPE;
               arrayToBuild = this._currDenItemsArray = this._allOldestDenItems;
            }
            else
            {
               currListViewType = this.CLOTHING_VIEW_TYPE;
               arrayToBuild = this._currClothesArray = this._allOldestItems;
            }
         }
         else if(evt.currentTarget.name == this._content.sortPopup.bg.name)
         {
            this._content.sortPopup.visible = !this._content.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         this.setCachingOptions(currListViewType,currSortType,true);
         this.buildItemWindows(arrayToBuild);
         this._content.sortPopup.visible = !this._content.sortPopup.visible;
      }
      
      private function tabBtnHandler(e:MouseEvent) : void
      {
         var currListViewType:int = 0;
         e.stopPropagation();
         if(e.currentTarget.name == this._content.denBtnDown.name)
         {
            currListViewType = this.DEN_VIEW_TYPE;
         }
         else if(e.currentTarget.name == this._content.clothesBtnDown.name)
         {
            currListViewType = this.CLOTHING_VIEW_TYPE;
         }
         if(e.currentTarget.name == this._content.denBtnDown.name)
         {
            this._content.denBtnUp.visible = true;
            this._content.denBtnDown.visible = false;
            this._content.clothesBtnUp.visible = false;
            this._content.clothesBtnDown.visible = true;
            LocalizationManager.translateId(this._content.sort5.txt,11216);
            this._content.sort4.txt.text = "Floors";
            LocalizationManager.translateId(this._content.sort3.txt,11210);
            LocalizationManager.translateId(this._content.sort2.txt,11211);
            LocalizationManager.translateId(this._content.sort1.txt,11212);
            this._content.sort6.visible = false;
            this._content.sort7.visible = false;
            this._content.sort8.visible = false;
            this.setCachingOptions(currListViewType,-1,false,false,true);
            this.buildItemWindows(this._currDenItemsArray);
         }
         else if(e.currentTarget.name == this._content.clothesBtnDown.name)
         {
            this._content.denBtnUp.visible = false;
            this._content.denBtnDown.visible = true;
            this._content.clothesBtnUp.visible = true;
            this._content.clothesBtnDown.visible = false;
            LocalizationManager.translateId(this._content.sort8.txt,11205);
            LocalizationManager.translateId(this._content.sort7.txt,11206);
            LocalizationManager.translateId(this._content.sort6.txt,11207);
            LocalizationManager.translateId(this._content.sort5.txt,11208);
            LocalizationManager.translateId(this._content.sort4.txt,11209);
            LocalizationManager.translateId(this._content.sort3.txt,11210);
            LocalizationManager.translateId(this._content.sort2.txt,11211);
            LocalizationManager.translateId(this._content.sort1.txt,11212);
            this._content.sort6.visible = true;
            this._content.sort7.visible = true;
            this._content.sort8.visible = true;
            this.setCachingOptions(currListViewType,-1,false,true);
            this.buildItemWindows(this._currClothesArray);
         }
      }
      
      private function setCachingOptions(currListViewType:int = -1, currListSortType:int = -1, resetScrollingValue:Boolean = false, updateClothingList:Boolean = false, updateDenList:Boolean = false) : void
      {
         if(Boolean(this._scrollButtons))
         {
            if(this._isChoosingItemsToTrade)
            {
               if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  if(resetScrollingValue)
                  {
                     _tradeClothesScrollValue = 0;
                  }
                  else
                  {
                     _tradeClothesScrollValue = this._scrollButtons.scrollYValue;
                  }
                  if(currListSortType != -1)
                  {
                     _tradeClothingListSortType = currListSortType;
                  }
               }
               else
               {
                  if(resetScrollingValue)
                  {
                     _tradeDenScrollvalue = 0;
                  }
                  else
                  {
                     _tradeDenScrollvalue = this._scrollButtons.scrollYValue;
                  }
                  if(currListSortType != -1)
                  {
                     _tradeDenListSortType = currListSortType;
                  }
               }
               if(currListViewType != -1)
               {
                  _tradeListViewType = currListViewType;
               }
               if(updateClothingList)
               {
                  this._currClothesArray = this.convertIntToList(_tradeClothingListSortType,true);
               }
               if(updateDenList)
               {
                  this._currDenItemsArray = this.convertIntToList(_tradeDenListSortType,false);
               }
            }
            else if(this._isECard)
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  if(resetScrollingValue)
                  {
                     _eCardClothesScrollValue = 0;
                     if(Boolean(this._itemClothingWindows))
                     {
                        this._itemClothingWindows.destroy();
                        this._itemClothingWindows = null;
                     }
                  }
                  else
                  {
                     _eCardClothesScrollValue = this._scrollButtons.scrollYValue;
                  }
                  if(currListSortType != -1)
                  {
                     _eCardClothingListSortType = currListSortType;
                  }
               }
               else
               {
                  if(resetScrollingValue)
                  {
                     _eCardDenScrollValue = 0;
                     if(Boolean(this._itemDenWindows))
                     {
                        this._itemDenWindows.destroy();
                        this._itemDenWindows = null;
                     }
                  }
                  else
                  {
                     _eCardDenScrollValue = this._scrollButtons.scrollYValue;
                  }
                  if(currListSortType != -1)
                  {
                     _eCardDenListSortType = currListSortType;
                  }
               }
               if(currListViewType != -1)
               {
                  _eCardListViewType = currListViewType;
               }
               if(updateClothingList)
               {
                  this._currClothesArray = this.convertIntToList(_eCardClothingListSortType,true);
               }
               if(updateDenList)
               {
                  this._currDenItemsArray = this.convertIntToList(_eCardDenListSortType,false);
               }
            }
            else
            {
               if(_normalListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  if(resetScrollingValue)
                  {
                     _normalClothesScrollValue = 0;
                  }
                  else
                  {
                     _normalClothesScrollValue = this._scrollButtons.scrollYValue;
                  }
                  if(currListSortType != -1)
                  {
                     _normalClothingListSortType = currListSortType;
                  }
               }
               else
               {
                  if(resetScrollingValue)
                  {
                     _normalDenScrollValue = 0;
                  }
                  else
                  {
                     _normalDenScrollValue = this._scrollButtons.scrollYValue;
                  }
                  if(currListSortType != -1)
                  {
                     _normalDenListSortType = currListSortType;
                  }
               }
               if(currListViewType != -1)
               {
                  _normalListViewType = currListViewType;
               }
               if(updateClothingList)
               {
                  this._currClothesArray = this.convertIntToList(_normalClothingListSortType,true);
               }
               if(updateDenList)
               {
                  this._currDenItemsArray = this.convertIntToList(_normalDenListSortType,false);
               }
            }
         }
      }
      
      private function convertIntToList(i:int, isClothing:Boolean) : Array
      {
         var a:Array = null;
         if(isClothing)
         {
            switch(i)
            {
               case 1:
                  a = this._allOldestItems;
                  break;
               case 2:
                  a = this._allNewestItems;
                  break;
               case 3:
                  a = this._itemTypeItems;
                  break;
               case 4:
                  a = this._tailItems;
                  break;
               case 5:
                  a = this._legItems;
                  break;
               case 6:
                  a = this._backItems;
                  break;
               case 7:
                  a = this._neckItems;
                  break;
               case 8:
                  a = this._headItems;
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
         this._contentPopup.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._content.addBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAddGiftBtn,false,0,true);
         this._content.sortBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortByBtn,false,0,true);
         this._content.sort8.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort7.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort6.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort5.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort4.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort3.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort2.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.sort1.addEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns,false,0,true);
         this._content.denBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._content.denBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._content.clothesBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
         this._content.clothesBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler,false,0,true);
      }
      
      private function removeListeners() : void
      {
         this._contentPopup.skin.s["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._content.addBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAddGiftBtn);
         this._content.sortBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortByBtn);
         this._content.sort8.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort7.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort6.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort5.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort4.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort3.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort2.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.sort1.removeEventListener(MouseEvent.MOUSE_DOWN,this.onSortBtns);
         this._content.denBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._content.denBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._content.clothesBtnUp.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
         this._content.clothesBtnDown.addEventListener(MouseEvent.MOUSE_DOWN,this.tabBtnHandler);
      }
   }
}

