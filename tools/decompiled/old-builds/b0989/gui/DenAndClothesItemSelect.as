package gui
{
   import com.sbi.debug.DebugUtility;
   import com.sbi.popup.SBPopup;
   import den.DenItem;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import item.Item;
   import item.ItemXtCommManager;
   
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
         this._content = new (getDefinitionByName("ECardCreationClothesContent") as Class)();
         this._contentPopup = new SBPopup(param3,new (getDefinitionByName("ECardCreationClothesSkin") as Class)(),this._content,true,true,false,false,true);
         this._onGiftBtnCallback = param4;
         this._onCloseCallback = param5;
         this._isECard = param6;
         this._isChoosingItemsToTrade = param7;
         this._currClothesArray = this._allNewestItems = param1;
         param2 = this.discardAudioItems(param2);
         this._currDenItemsArray = this._allNewestDenItems = param2;
         this.setInitialStatesAndVisibility();
         if(this._isChoosingItemsToTrade)
         {
            if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
            {
               _loc8_ = this._currClothesArray = this.convertIntToList(_tradeClothingListSortType,true);
            }
            else
            {
               _loc8_ = this._currDenItemsArray = this.convertIntToList(_tradeDenListSortType,false);
            }
         }
         else if(this._isECard)
         {
            if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
            {
               _loc8_ = this._currClothesArray = this.convertIntToList(_eCardClothingListSortType,true);
            }
            else
            {
               _loc8_ = this._currDenItemsArray = this.convertIntToList(_eCardDenListSortType,false);
            }
         }
         else if(_normalListViewType == this.CLOTHING_VIEW_TYPE)
         {
            _loc8_ = this._currClothesArray = this.convertIntToList(_normalClothingListSortType,true);
         }
         else
         {
            _loc8_ = this._currDenItemsArray = this.convertIntToList(_normalDenListSortType,false);
         }
         this.buildItemWindows(_loc8_);
         this.addListeners();
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         this.setCachingOptions();
         if(this._content)
         {
            this.removeListeners();
            this._content = null;
         }
         if(this._contentPopup)
         {
            this._contentPopup.destroy();
            this._contentPopup = null;
         }
         if(this._tradeWindows)
         {
            this._tradeWindows.destroy();
            this._tradeWindows = null;
         }
         if(this._itemClothingWindows)
         {
            this._itemClothingWindows.destroy();
            this._itemClothingWindows = null;
         }
         if(this._itemDenWindows)
         {
            this._itemDenWindows.destroy();
            this._itemDenWindows = null;
         }
         if(Boolean(this._spirals) && this._spirals.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this._spirals.length)
            {
               if(this._spirals[_loc1_])
               {
                  this._spirals[_loc1_].destroy();
               }
               _loc1_++;
            }
         }
         this._spirals = null;
      }
      
      public function showHide() : void
      {
         var _loc1_:Array = null;
         if(this._currGiftMC)
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
                  _loc1_ = this._currClothesArray = this.convertIntToList(_tradeClothingListSortType,true);
               }
               else
               {
                  _loc1_ = this._currDenItemsArray = this.convertIntToList(_tradeDenListSortType,false);
               }
            }
            else if(this._isECard)
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  _loc1_ = this._currClothesArray = this.convertIntToList(_eCardClothingListSortType,true);
               }
               else
               {
                  _loc1_ = this._currDenItemsArray = this.convertIntToList(_eCardDenListSortType,false);
               }
            }
            else if(_normalListViewType == this.CLOTHING_VIEW_TYPE)
            {
               _loc1_ = this._currClothesArray = this.convertIntToList(_normalClothingListSortType,true);
            }
            else
            {
               _loc1_ = this._currDenItemsArray = this.convertIntToList(_normalDenListSortType,false);
            }
            this.buildItemWindows(_loc1_);
            this._contentPopup.open();
         }
      }
      
      public function removeGift() : void
      {
         this._giftItemIdx = -1;
         if(this._currDownMC)
         {
            this._currDownMC.resetDownGift();
         }
         if(this._currGiftMC)
         {
            this._currGiftMC.gift.visible = false;
            this._currGiftMC = null;
         }
      }
      
      private function setInitialStatesAndVisibility() : void
      {
         var _loc1_:int = 0;
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
            _loc1_ = _tradeListViewType;
         }
         else if(this._isECard)
         {
            _loc1_ = _eCardListViewType;
         }
         else
         {
            _loc1_ = _normalListViewType;
         }
         if(this._isChoosingItemsToTrade)
         {
            this._content.clothesTxt.text = "ADD TO TRADE";
         }
         if(_loc1_ == this.CLOTHING_VIEW_TYPE)
         {
            this._content.denBtnUp.visible = false;
            this._content.denBtnDown.visible = true;
            this._content.clothesBtnUp.visible = true;
            this._content.clothesBtnDown.visible = false;
            this._content.sort8.txt.text = "Head";
            this._content.sort7.txt.text = "Neck";
            this._content.sort6.txt.text = "Back";
            this._content.sort5.txt.text = "Legs";
            this._content.sort4.txt.text = "Tail";
            this._content.sort3.txt.text = "Item";
            this._content.sort2.txt.text = "All Newest";
            this._content.sort1.txt.text = "All Oldest";
            this._content.sort6.visible = true;
            this._content.sort7.visible = true;
            this._content.sort8.visible = true;
         }
         else
         {
            this._content.sort5.txt.text = "Items";
            this._content.sort4.txt.text = "Floors & Walls";
            this._content.sort3.txt.text = "Item";
            this._content.sort2.txt.text = "All Newest";
            this._content.sort1.txt.text = "All Oldest";
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
      
      private function buildItemWindows(param1:Array) : void
      {
         var _loc2_:WindowGenerator = null;
         var _loc3_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:Boolean = false;
         var _loc8_:Array = null;
         var _loc10_:Array = null;
         var _loc11_:Array = null;
         var _loc12_:Object = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         if(this._scrollButtons)
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
         var _loc4_:int = int(param1.length);
         var _loc7_:int = 0;
         if(this._isChoosingItemsToTrade)
         {
            _loc8_ = TradeManager.initiationTradeList;
         }
         else
         {
            _loc8_ = gMainFrame.userInfo.getMyTradeList();
         }
         var _loc9_:int = int(_loc8_.length);
         if(this._isECard)
         {
            _loc5_ = Math.ceil(param1.length / this.NUM_X_WIN) * this.NUM_X_WIN;
            if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
            {
               _loc3_ = _eCardClothesScrollValue;
               _loc2_ = this._itemClothingWindows;
            }
            else
            {
               _loc3_ = _eCardDenScrollValue;
               _loc2_ = this._itemDenWindows;
            }
         }
         else if(param1 == this._currClothesArray)
         {
            if(this._isChoosingItemsToTrade)
            {
               _loc5_ = Math.ceil((param1.length - TradeManager.numClothingItemsInInitiateTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               _loc3_ = _tradeClothesScrollValue;
            }
            else
            {
               _loc5_ = Math.ceil((param1.length - TradeManager.numClothingItemsInMyTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               _loc3_ = _normalClothesScrollValue;
            }
         }
         else
         {
            if(param1 != this._currDenItemsArray)
            {
               throw new Error("None of our lists match given items list");
            }
            if(this._isChoosingItemsToTrade)
            {
               _loc5_ = Math.ceil((param1.length - TradeManager.numDenItemsInInitiateTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               _loc3_ = _tradeDenScrollvalue;
            }
            else
            {
               _loc5_ = Math.ceil((param1.length - TradeManager.numDenItemsInMyTradeList) / this.NUM_X_WIN) * this.NUM_X_WIN;
               _loc3_ = _normalDenScrollValue;
            }
         }
         if(_loc2_ == null)
         {
            _loc10_ = [];
            _loc11_ = [];
            _loc12_ = null;
            _loc13_ = 0;
            _loc14_ = 0;
            for(; _loc14_ < _loc4_; _loc14_++)
            {
               if(_loc14_ < _loc4_)
               {
                  _loc12_ = param1[_loc14_].clone();
                  if(!this._isECard)
                  {
                     _loc15_ = 0;
                     while(_loc15_ < _loc9_)
                     {
                        if(this._isChoosingItemsToTrade)
                        {
                           if((_loc12_ is Item && _loc8_[_loc15_] is Item || _loc12_ is DenItem && _loc8_[_loc15_] is DenItem) && _loc12_.invIdx == _loc8_[_loc15_].invIdx)
                           {
                              _loc6_ = true;
                              break;
                           }
                        }
                        else if((_loc12_ is Item && _loc8_[_loc15_].type == 0 || _loc12_ is DenItem && _loc8_[_loc15_].type == 1) && _loc12_.invIdx == _loc8_[_loc15_].invIdx)
                        {
                           _loc6_ = true;
                           break;
                        }
                        _loc15_++;
                     }
                     if(_loc6_)
                     {
                        _loc6_ = false;
                        _loc7_++;
                        continue;
                     }
                  }
                  if(this._giftItemIdx == _loc12_.invIdx)
                  {
                     this._giftDownIdx = _loc13_ + _loc7_;
                  }
                  _loc11_.push(_loc13_ + _loc7_);
                  if(_loc12_)
                  {
                     _loc10_.push(_loc12_);
                  }
               }
               _loc13_++;
            }
            _loc2_ = new WindowGenerator();
            if(this._isECard)
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  this._itemClothingWindows = _loc2_;
               }
               else
               {
                  this._itemDenWindows = _loc2_;
               }
            }
            else
            {
               this._tradeWindows = _loc2_;
            }
            _loc2_.init(this.NUM_X_WIN,this.NUM_Y_WIN,Math.max(_loc5_,12),this.X_WIN_OFFSET,this.Y_WIN_OFFSET,this.X_WIN_START,ItemWindowOriginal,_loc10_,"icon",{
               "mouseDown":this.winMouseDown,
               "mouseOver":this.winMouseOver,
               "mouseOut":this.winMouseOut
            },{
               "giftItemIdx":this._giftItemIdx,
               "isECard":this._isECard,
               "isChoosingForTradeList":this._isChoosingItemsToTrade,
               "indexArray":_loc11_
            },this.onListLoaded);
         }
         this._content.itemBlock.addChild(_loc2_);
         this._scrollButtons = new SBScrollbar();
         this._scrollButtons.init(_loc2_,_loc2_.width,_loc2_.boxHeight * this.NUM_Y_WIN + this.Y_WIN_OFFSET * (this.NUM_Y_WIN - 1) + this.Y_WIN_OFFSET,this.SCROLLBAR_GAP,"scrollbar2",_loc2_.boxHeight + this.Y_WIN_OFFSET,_loc3_);
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
      
      private function winMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:String = null;
         param1.stopPropagation();
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
         }
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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
      
      private function winMouseDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(this._content.denBtnUp.visible)
         {
            _loc2_ = this._currDenItemsArray[param1.currentTarget.index];
         }
         else
         {
            _loc2_ = this._currClothesArray[param1.currentTarget.index];
         }
         if(_loc2_)
         {
            if(this._isECard)
            {
               if(Boolean(param1.currentTarget.gift.visible) && _loc2_.invIdx == this._giftItemIdx)
               {
                  this._giftItemIdx = -1;
                  param1.currentTarget.gift.visible = false;
               }
               else if(!param1.currentTarget.gift.visible && _loc2_.invIdx != this._giftItemIdx)
               {
                  if(this._currDownMC)
                  {
                     this._currDownMC.resetDownGift();
                  }
                  this._currDownMC = param1.currentTarget.currDownGift = param1.currentTarget;
                  this._giftItemIdx = _loc2_.invIdx;
                  if(this._giftItemIdx <= 0)
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
               if(_loc2_ is Item)
               {
                  TradeManager.adjustByOnNumClothingItemsInInitiateTradeList(1);
               }
               else
               {
                  TradeManager.adjustByOnNumDenItemsInInitiateTradeList(1);
               }
               this._onCloseCallback(_loc2_);
               this.destroy();
            }
         }
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currDownMC)
         {
            this._currDownMC.resetDownGift();
            this._giftItemIdx = -1;
         }
         if(this._isECard)
         {
            if(this._scrollButtons)
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
      
      private function onAddGiftBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._giftItemIdx > 0)
         {
            this._currGiftMC = this._currDownMC;
            if(this._content.denBtnUp.visible)
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
            return;
         }
      }
      
      private function onSortByBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._content.sortPopup.visible = !this._content.sortPopup.visible;
      }
      
      private function onSortBtns(param1:MouseEvent) : void
      {
         var _loc2_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._content.sort8.name)
         {
            _loc3_ = this.CLOTHING_VIEW_TYPE;
            _loc4_ = 8;
            _loc2_ = this._currClothesArray = this._headItems;
         }
         else if(param1.currentTarget.name == this._content.sort7.name)
         {
            _loc3_ = this.CLOTHING_VIEW_TYPE;
            _loc4_ = 7;
            _loc2_ = this._currClothesArray = this._neckItems;
         }
         else if(param1.currentTarget.name == this._content.sort6.name)
         {
            _loc3_ = this.CLOTHING_VIEW_TYPE;
            _loc4_ = 6;
            _loc2_ = this._currClothesArray = this._backItems;
         }
         else if(param1.currentTarget.name == this._content.sort5.name)
         {
            _loc4_ = 5;
            if(this._content.denBtnUp.visible)
            {
               _loc3_ = this.DEN_VIEW_TYPE;
               _loc2_ = this._currDenItemsArray = this._floorItems;
            }
            else
            {
               _loc3_ = this.CLOTHING_VIEW_TYPE;
               _loc2_ = this._currClothesArray = this._legItems;
            }
         }
         else if(param1.currentTarget.name == this._content.sort4.name)
         {
            _loc4_ = 4;
            if(this._content.denBtnUp.visible)
            {
               _loc3_ = this.DEN_VIEW_TYPE;
               _loc2_ = this._currDenItemsArray = this._themeItems;
            }
            else
            {
               _loc3_ = this.CLOTHING_VIEW_TYPE;
               _loc2_ = this._currClothesArray = this._tailItems;
            }
         }
         else if(param1.currentTarget.name == this._content.sort3.name)
         {
            _loc4_ = 3;
            if(this._content.denBtnUp.visible)
            {
               _loc3_ = this.DEN_VIEW_TYPE;
               _loc2_ = this._currDenItemsArray = this._itemTypeDenItems;
            }
            else
            {
               _loc3_ = this.CLOTHING_VIEW_TYPE;
               _loc2_ = this._currClothesArray = this._itemTypeItems;
            }
         }
         else if(param1.currentTarget.name == this._content.sort2.name)
         {
            _loc4_ = 2;
            if(this._content.denBtnUp.visible)
            {
               _loc3_ = this.DEN_VIEW_TYPE;
               _loc2_ = this._currDenItemsArray = this._allNewestDenItems;
            }
            else
            {
               _loc3_ = this.CLOTHING_VIEW_TYPE;
               _loc2_ = this._currClothesArray = this._allNewestItems;
            }
         }
         else if(param1.currentTarget.name == this._content.sort1.name)
         {
            _loc4_ = 1;
            if(this._content.denBtnUp.visible)
            {
               _loc3_ = this.DEN_VIEW_TYPE;
               _loc2_ = this._currDenItemsArray = this._allOldestDenItems;
            }
            else
            {
               _loc3_ = this.CLOTHING_VIEW_TYPE;
               _loc2_ = this._currClothesArray = this._allOldestItems;
            }
         }
         else if(param1.currentTarget.name == this._content.sortPopup.bg.name)
         {
            this._content.sortPopup.visible = !this._content.sortPopup.visible;
         }
         else
         {
            DebugUtility.debugTrace("ERROR");
         }
         this.setCachingOptions(_loc3_,_loc4_,true);
         this.buildItemWindows(_loc2_);
         this._content.sortPopup.visible = !this._content.sortPopup.visible;
      }
      
      private function tabBtnHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         param1.stopPropagation();
         if(param1.currentTarget.name == this._content.denBtnDown.name)
         {
            _loc2_ = this.DEN_VIEW_TYPE;
         }
         else if(param1.currentTarget.name == this._content.clothesBtnDown.name)
         {
            _loc2_ = this.CLOTHING_VIEW_TYPE;
         }
         if(param1.currentTarget.name == this._content.denBtnDown.name)
         {
            this._content.denBtnUp.visible = true;
            this._content.denBtnDown.visible = false;
            this._content.clothesBtnUp.visible = false;
            this._content.clothesBtnDown.visible = true;
            this._content.sort5.txt.text = "Items";
            this._content.sort4.txt.text = "Floors";
            this._content.sort3.txt.text = "Item";
            this._content.sort2.txt.text = "All Newest";
            this._content.sort1.txt.text = "All Oldest";
            this._content.sort6.visible = false;
            this._content.sort7.visible = false;
            this._content.sort8.visible = false;
            this.setCachingOptions(_loc2_,-1,false,false,true);
            this.buildItemWindows(this._currDenItemsArray);
         }
         else if(param1.currentTarget.name == this._content.clothesBtnDown.name)
         {
            this._content.denBtnUp.visible = false;
            this._content.denBtnDown.visible = true;
            this._content.clothesBtnUp.visible = true;
            this._content.clothesBtnDown.visible = false;
            this._content.sort8.txt.text = "Head";
            this._content.sort7.txt.text = "Neck";
            this._content.sort6.txt.text = "Back";
            this._content.sort5.txt.text = "Legs";
            this._content.sort4.txt.text = "Tail";
            this._content.sort3.txt.text = "Item";
            this._content.sort2.txt.text = "All Newest";
            this._content.sort1.txt.text = "All Oldest";
            this._content.sort6.visible = true;
            this._content.sort7.visible = true;
            this._content.sort8.visible = true;
            this.setCachingOptions(_loc2_,-1,false,true);
            this.buildItemWindows(this._currClothesArray);
         }
      }
      
      private function setCachingOptions(param1:int = -1, param2:int = -1, param3:Boolean = false, param4:Boolean = false, param5:Boolean = false) : void
      {
         if(this._scrollButtons)
         {
            if(this._isChoosingItemsToTrade)
            {
               if(_tradeListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  if(param3)
                  {
                     _tradeClothesScrollValue = 0;
                  }
                  else
                  {
                     _tradeClothesScrollValue = this._scrollButtons.scrollYValue;
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
                     _tradeDenScrollvalue = this._scrollButtons.scrollYValue;
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
                  this._currClothesArray = this.convertIntToList(_tradeClothingListSortType,true);
               }
               if(param5)
               {
                  this._currDenItemsArray = this.convertIntToList(_tradeDenListSortType,false);
               }
            }
            else if(this._isECard)
            {
               if(_eCardListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  if(param3)
                  {
                     _eCardClothesScrollValue = 0;
                     if(this._itemClothingWindows)
                     {
                        this._itemClothingWindows.destroy();
                        this._itemClothingWindows = null;
                     }
                  }
                  else
                  {
                     _eCardClothesScrollValue = this._scrollButtons.scrollYValue;
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
                     if(this._itemDenWindows)
                     {
                        this._itemDenWindows.destroy();
                        this._itemDenWindows = null;
                     }
                  }
                  else
                  {
                     _eCardDenScrollValue = this._scrollButtons.scrollYValue;
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
                  this._currClothesArray = this.convertIntToList(_eCardClothingListSortType,true);
               }
               if(param5)
               {
                  this._currDenItemsArray = this.convertIntToList(_eCardDenListSortType,false);
               }
            }
            else
            {
               if(_normalListViewType == this.CLOTHING_VIEW_TYPE)
               {
                  if(param3)
                  {
                     _normalClothesScrollValue = 0;
                  }
                  else
                  {
                     _normalClothesScrollValue = this._scrollButtons.scrollYValue;
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
                     _normalDenScrollValue = this._scrollButtons.scrollYValue;
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
                  this._currClothesArray = this.convertIntToList(_normalClothingListSortType,true);
               }
               if(param5)
               {
                  this._currDenItemsArray = this.convertIntToList(_normalDenListSortType,false);
               }
            }
         }
      }
      
      private function convertIntToList(param1:int, param2:Boolean) : Array
      {
         var _loc3_:Array = null;
         if(param2)
         {
            switch(param1)
            {
               case 1:
                  _loc3_ = this._allOldestItems;
                  break;
               case 2:
                  _loc3_ = this._allNewestItems;
                  break;
               case 3:
                  _loc3_ = this._itemTypeItems;
                  break;
               case 4:
                  _loc3_ = this._tailItems;
                  break;
               case 5:
                  _loc3_ = this._legItems;
                  break;
               case 6:
                  _loc3_ = this._backItems;
                  break;
               case 7:
                  _loc3_ = this._neckItems;
                  break;
               case 8:
                  _loc3_ = this._headItems;
            }
         }
         else
         {
            switch(param1)
            {
               case 1:
                  _loc3_ = this._allOldestDenItems;
                  break;
               case 2:
                  _loc3_ = this._allNewestDenItems;
                  break;
               case 3:
                  _loc3_ = this._itemTypeDenItems;
                  break;
               case 4:
                  _loc3_ = this._themeItems;
                  break;
               case 5:
                  _loc3_ = this._floorItems;
            }
         }
         return _loc3_;
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

