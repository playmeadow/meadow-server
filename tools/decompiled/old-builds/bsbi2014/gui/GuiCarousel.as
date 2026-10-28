package gui
{
   import achievement.AchievementXtCommManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.debug.DebugUtility;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   import flash.utils.getTimer;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class GuiCarousel
   {
      
      private static const SPIN_UPDATE_MS:int = 20;
      
      private static const BUTTON_HOLD_DELAY:int = 500;
      
      public var spinSpeed:Number = 3;
      
      public var upBtn:MovieClip;
      
      public var downBtn:MovieClip;
      
      public var itemsHolder:MovieClip;
      
      public var scrollerMask:Sprite;
      
      public var itemHolders:Vector.<DisplayObject>;
      
      public var itemInfos:Vector.<ItemInfo>;
      
      public var contentItems:Array;
      
      public var fullContentItems:Array;
      
      public var oceanOnlyItems:Array;
      
      public var doneSpinningCallback:Function;
      
      public var soundsEnabled:Boolean;
      
      public var showOnlyOceanAnimals:Boolean;
      
      public var isChoosingFirstNonMember:Boolean;
      
      public var newOceanIndex:int;
      
      private var _callDone:Boolean;
      
      private var _itemCycleDown:Boolean;
      
      private var _autoCycleDown:Boolean;
      
      private var _autoScroll:Boolean;
      
      private var _contentItemIndex:int;
      
      private var _targetContentItemIndex:int;
      
      private var _centerItemHolderIndex:int;
      
      private var _centerItemHolderGlowFilter:GlowFilter;
      
      private var _hoverItemHolderGlowFilter:GlowFilter;
      
      private var _centerTextFormatShadow:TextFormat;
      
      private var _centerTextFormatLight:TextFormat;
      
      private var _itemCycleTimer:Timer;
      
      private var _btnHoldTimer:Timer;
      
      private var _textFieldMode:Boolean;
      
      private var _lastTimer:int;
      
      private var _randomizing:Boolean;
      
      private var _lockViews:Array;
      
      private var _mediaHolder:Array;
      
      private var _lockViewIdx:int;
      
      private var _numToLoad:int;
      
      private var _continueCallback:Function;
      
      private var _isFromLogin:Boolean;
      
      private var _avtViewsFlag:int;
      
      private var _priceTag:MovieClip;
      
      private var _myGemCount:int;
      
      private var _redBuyBtn:MovieClip;
      
      private var _greenBuyBtn:MovieClip;
      
      private var _nextBtn:MovieClip;
      
      private var _guiAsset:MovieClip;
      
      private var _hasLoaded:Boolean;
      
      private var _startingIndex:int;
      
      public function GuiCarousel(initAsset:MovieClip)
      {
         super();
         this._guiAsset = initAsset;
      }
      
      public function init(initContentItems:Array, initDoneSpinningCallback:Function = null, initSoundsEnabled:Boolean = false, shrinkMode:Boolean = false, initContinueCallback:Function = null, isFromLogin:Boolean = false, initStartIndex:int = -1) : void
      {
         var i:int = 0;
         var itemPlaceholder:DisplayObject = null;
         var iht:int = 0;
         var ali:int = 0;
         var numTotalAvatars:int = 0;
         var lockMediaHelper:MediaHelper = null;
         var currAvtDef:Object = null;
         this._lastTimer = getTimer();
         var contentItemsLength:int = int(initContentItems.length);
         this._textFieldMode = initContentItems[0] is String;
         this.fullContentItems = initContentItems;
         this.oceanOnlyItems = [];
         var tempArray:Array = [];
         this._startingIndex = initStartIndex;
         this._avtViewsFlag = gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG);
         for(i = 0; i < contentItemsLength; i++)
         {
            if(Boolean(AvatarUtility.avatarDefInfo && AvatarUtility.avatarDefInfo.length > 0) && Boolean(i < AvatarUtility.avatarDefInfo.length) && Boolean(AvatarUtility.avatarDefInfo[i]))
            {
               if((this._avtViewsFlag & 1 << AvatarUtility.avatarTypes[i] - 1) != 0)
               {
                  tempArray.push(initContentItems[i]);
               }
               if(Utility.isOcean(AvatarUtility.avatarDefInfo[i].enviroFlag))
               {
                  this.oceanOnlyItems.push(initContentItems[i]);
               }
            }
         }
         if(this.showOnlyOceanAnimals)
         {
            this.contentItems = this.oceanOnlyItems;
         }
         else if(this._textFieldMode || initContentItems[0] is MovieClip)
         {
            this.contentItems = initContentItems;
         }
         else
         {
            this.contentItems = tempArray;
         }
         contentItemsLength = int(this.contentItems.length);
         this._isFromLogin = isFromLogin;
         if(contentItemsLength < 1)
         {
            throw new Error("Attempted to init GuiCarousel with content array length less than one!");
         }
         for(var ici:int = 0; ici < contentItemsLength; ici++)
         {
            if(!(initContentItems[ici] is String) && !(initContentItems[ici] is DisplayObject))
            {
               throw new Error("Attempted to init GuiCarousel with non-DisplayObject content array!");
            }
         }
         this.doneSpinningCallback = initDoneSpinningCallback;
         this.soundsEnabled = initSoundsEnabled;
         this.upBtn = this._guiAsset._up;
         this.downBtn = this._guiAsset._down;
         this.itemsHolder = this._guiAsset._items;
         this.scrollerMask = this._guiAsset.scrollerMask;
         if(!(Boolean(this.upBtn) && Boolean(this.downBtn) && Boolean(this.itemsHolder) && this.scrollerMask))
         {
            throw new Error("GuiCarousel is missing parts or they are named incorrectly!");
         }
         this.upBtn.stop();
         this.upBtn.mouseChildren = false;
         this.upBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.upBtnMouseDownHandler,false,0,true);
         this.upBtn.addEventListener(MouseEvent.MOUSE_UP,this.upBtnMouseUpOutHandler,false,0,true);
         this.upBtn.addEventListener(MouseEvent.MOUSE_OUT,this.upBtnMouseUpOutHandler,false,0,true);
         this.downBtn.stop();
         this.downBtn.mouseChildren = false;
         this.downBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.downBtnMouseDownHandler,false,0,true);
         this.downBtn.addEventListener(MouseEvent.MOUSE_UP,this.downBtnMouseUpOutHandler,false,0,true);
         this.downBtn.addEventListener(MouseEvent.MOUSE_OUT,this.downBtnMouseUpOutHandler,false,0,true);
         this._myGemCount = gMainFrame.clientInfo.gemCount;
         if(!this._textFieldMode)
         {
            if(this._guiAsset.parent.hasOwnProperty("tag"))
            {
               this._priceTag = this._guiAsset.parent["tag"];
               this._priceTag.visible = false;
            }
            if(this._guiAsset.parent.hasOwnProperty("buy_btn_red"))
            {
               this._redBuyBtn = this._guiAsset.parent["buy_btn_red"];
               this._greenBuyBtn = this._guiAsset.parent["buy_btn_green"];
               this._nextBtn = this._guiAsset.parent["next_btn"];
               this._redBuyBtn.visible = false;
            }
            if(!this._isFromLogin)
            {
               this._nextBtn.visible = false;
            }
         }
         this.itemInfos = new Vector.<ItemInfo>(2);
         var itemCountIdx:int = 0;
         while(this.itemsHolder.hasOwnProperty("_item" + itemCountIdx))
         {
            itemPlaceholder = this.itemsHolder["_item" + itemCountIdx];
            this.itemInfos[int(itemCountIdx)] = new ItemInfo();
            this.itemInfos[int(itemCountIdx)].stopY = itemPlaceholder.y;
            if(!this._textFieldMode)
            {
               itemPlaceholder.visible = false;
            }
            itemCountIdx++;
         }
         if(itemCountIdx == 0)
         {
            throw new Error("GuiCarousel did not have any _item# instances inside it!");
         }
         if(shrinkMode)
         {
            throw new Error("shrinkMode not supported yet!");
         }
         this.itemInfos[itemCountIdx] = new ItemInfo();
         this.itemInfos[itemCountIdx].stopY = this.itemInfos.length > 2 ? this.itemInfos[itemCountIdx - 1].stopY + (this.itemInfos[itemCountIdx - 1].stopY - this.itemInfos[itemCountIdx - 2].stopY) : this.itemInfos[itemCountIdx - 1].stopY + this.itemsHolder["_item1"].height;
         if(this._textFieldMode)
         {
            this.itemHolders = new Vector.<DisplayObject>(itemCountIdx);
            for(iht = 0; iht < itemCountIdx; iht++)
            {
               this.itemHolders[iht] = this.itemsHolder["_item" + iht];
               this.itemHolders[iht].addEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler,false,0,true);
               this.itemHolders[iht].addEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler,false,0,true);
               this.itemHolders[iht].addEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler,false,0,true);
            }
         }
         else
         {
            this.itemHolders = new Vector.<DisplayObject>(itemCountIdx);
            for(ali = 0; ali < itemCountIdx; ali++)
            {
               this.itemHolders[ali] = new Sprite();
               this.itemHolders[ali].y = this.itemInfos[ali].stopY;
               this.itemHolders[ali].addEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler,false,0,true);
               this.itemHolders[ali].addEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler,false,0,true);
               this.itemHolders[ali].addEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler,false,0,true);
               this.itemsHolder.addChild(this.itemHolders[ali]);
            }
         }
         this._hoverItemHolderGlowFilter = new GlowFilter(16777215,1,16,16,3);
         this._centerItemHolderIndex = itemCountIdx / 2;
         if(this._textFieldMode)
         {
            this._centerTextFormatShadow = TextField(this.itemsHolder["_item1"]).getTextFormat();
            this._centerTextFormatLight = TextField(this.itemsHolder["_item" + this._centerItemHolderIndex]).getTextFormat();
         }
         else
         {
            this._centerItemHolderGlowFilter = new GlowFilter(3407667,1,16,16,2);
            if(this.shouldFilter())
            {
               this.itemHolders[this._centerItemHolderIndex].filters = [this._centerItemHolderGlowFilter];
            }
         }
         this._btnHoldTimer = new Timer(BUTTON_HOLD_DELAY,1);
         this._btnHoldTimer.addEventListener(TimerEvent.TIMER,this.btnHoldTimerHandler,false,0,true);
         this._itemCycleTimer = new Timer(SPIN_UPDATE_MS);
         this._autoScroll = false;
         if(this._textFieldMode)
         {
            this.spinSpeed = 3;
         }
         else
         {
            this.spinSpeed = 8;
         }
         this._callDone = true;
         this._continueCallback = initContinueCallback;
         this._lockViewIdx = 0;
         this._numToLoad = 0;
         if(contentItemsLength > 0 && this.contentItems[0] is AvatarView)
         {
            numTotalAvatars = int(AvatarUtility.avatarDefInfo.length);
            this._lockViews = [];
            this._mediaHolder = [];
            for(i = 0; i < numTotalAvatars; i++)
            {
               currAvtDef = AvatarUtility.avatarDefInfo[i];
               if(Boolean(currAvtDef))
               {
                  if(Boolean(currAvtDef.isMemberOnly))
                  {
                     ++this._numToLoad;
                     lockMediaHelper = new MediaHelper();
                     lockMediaHelper.init(360,this.lockMediaCallback,{
                        "index":i,
                        "isMemberOnly":true
                     });
                     this._mediaHolder.push(lockMediaHelper);
                  }
                  if(Utility.isOcean(currAvtDef.enviroFlag))
                  {
                     ++this._numToLoad;
                     lockMediaHelper = new MediaHelper();
                     lockMediaHelper.init(1165,this.lockMediaCallback,{
                        "index":i,
                        "isOcean":true
                     });
                     this._mediaHolder.push(lockMediaHelper);
                  }
                  if(currAvtDef.availability >= AvatarUtility.AVT_AVAIL_ENDANGERED)
                  {
                     ++this._numToLoad;
                     lockMediaHelper = new MediaHelper();
                     lockMediaHelper.init(1387,this.lockMediaCallback,{
                        "index":i,
                        "isEndangered":true
                     });
                     this._mediaHolder.push(lockMediaHelper);
                  }
               }
            }
         }
         else
         {
            this.spinToIndex(initStartIndex == -1 ? int(contentItemsLength / 2) : initStartIndex,true);
            if(this._continueCallback != null)
            {
               this._continueCallback();
            }
         }
         this._hasLoaded = true;
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         this._btnHoldTimer.stop();
         this._btnHoldTimer = null;
         this._itemCycleTimer.stop();
         this._itemCycleTimer = null;
         if(Boolean(this._mediaHolder))
         {
            for(i = 0; i < this._mediaHolder.length; i++)
            {
               this._mediaHolder[i].destroy();
            }
            this._mediaHolder = null;
         }
         this.upBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.upBtnMouseDownHandler);
         this.upBtn.removeEventListener(MouseEvent.MOUSE_UP,this.upBtnMouseUpOutHandler);
         this.upBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.upBtnMouseUpOutHandler);
         this.downBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.downBtnMouseDownHandler);
         this.downBtn.removeEventListener(MouseEvent.MOUSE_UP,this.downBtnMouseUpOutHandler);
         this.downBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.downBtnMouseUpOutHandler);
         for(i = 0; i < this.itemHolders.length; i++)
         {
            this.itemHolders[i].removeEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler);
            this.itemHolders[i].removeEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler);
            this.itemHolders[i].removeEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler);
         }
         this.itemHolders = null;
      }
      
      private function lockMediaCallback(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            if(!this._lockViews[img.passback.index])
            {
               this._lockViews[img.passback.index] = {
                  "memberOnly":null,
                  "ocean":null,
                  "endangered":null
               };
            }
            if(Boolean(img.passback.isMemberOnly))
            {
               this._lockViews[img.passback.index].memberOnly = img;
            }
            else if(Boolean(img.passback.isOcean))
            {
               img.scaleX = 2;
               img.scaleY = 2;
               this._lockViews[img.passback.index].ocean = img;
            }
            else if(Boolean(img.passback.isEndangered))
            {
               this._lockViews[img.passback.index].endangered = img;
            }
            ++this._lockViewIdx;
            if(this._lockViewIdx >= this._numToLoad)
            {
               this.spinToIndex(this._startingIndex == -1 ? int(this.contentItems.length / 2) : this._startingIndex,true);
               if(this._continueCallback != null)
               {
                  this._continueCallback();
               }
            }
            img.mediaHelper.destroy();
            delete img.mediaHelper;
            delete img.passback;
         }
      }
      
      public function get contentItemIndex() : int
      {
         return this._contentItemIndex;
      }
      
      public function set contentItemIndex(setContentItemIndex:int) : void
      {
         if(setContentItemIndex == this._contentItemIndex)
         {
            return;
         }
         this.spinToIndex(setContentItemIndex);
      }
      
      public function get selectedContentItem() : *
      {
         return Boolean(this.contentItems) ? this.contentItems[this._contentItemIndex] : null;
      }
      
      public function set selectedContentItem(setContentItem:*) : void
      {
         this.spinToIndex(this.contentItems.indexOf(setContentItem));
      }
      
      public function get hasLoaded() : Boolean
      {
         return this._hasLoaded;
      }
      
      private function shouldFilter() : Boolean
      {
         var avatarView:DisplayObject = null;
         if(this.itemHolders[this._centerItemHolderIndex] is Sprite && DisplayObjectContainer(this.itemHolders[this._centerItemHolderIndex]).numChildren > 0 && this.contentItems[0] is AvatarView)
         {
            avatarView = DisplayObjectContainer(this.itemHolders[this._centerItemHolderIndex]).getChildAt(0);
            if(AvatarUtility.isExtinct(AvatarUtility.findAvDefByType(AvatarView(avatarView).avTypeId).availability))
            {
               return false;
            }
            if(gMainFrame.userInfo.isMember)
            {
            }
            return true;
         }
         if(!DisplayObject(this.contentItems[this._centerItemHolderIndex]).parent is Loader)
         {
            return true;
         }
         return false;
      }
      
      public function redrawItems() : void
      {
         this._myGemCount = gMainFrame.clientInfo.gemCount;
         if(!this._textFieldMode)
         {
            this._priceTag.visible = false;
            this._redBuyBtn.visible = false;
            this._greenBuyBtn.visible = false;
         }
         this.setupContentItems();
         this.soundsEnabled = false;
         this.spinToAnimal(SharedAvatarAnimalConstants.AV_GIRAFFE,true);
         this.displayItems(true,true);
         this.soundsEnabled = true;
      }
      
      public function setupContentItems() : void
      {
         var i:int = 0;
         if(!this.showOnlyOceanAnimals)
         {
            this._avtViewsFlag = gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG);
            this.contentItems = [];
            for(i = 0; i < this.fullContentItems.length; i++)
            {
               if((this._avtViewsFlag & 1 << AvatarUtility.avatarTypes[i] - 1) != 0)
               {
                  this.contentItems.push(this.fullContentItems[i]);
               }
            }
            this._contentItemIndex = 0;
         }
         else
         {
            this._contentItemIndex = 0;
            this.contentItems = this.oceanOnlyItems;
         }
      }
      
      public function removeAllChildren() : void
      {
         var itemHoldersLength:int = 0;
         var i:int = 0;
         var itemHolderContainer:DisplayObjectContainer = null;
         if(Boolean(this.itemHolders) && Boolean(this.contentItems))
         {
            itemHoldersLength = Math.min(this.itemHolders.length,this.contentItems.length);
            for(i = 0; i < itemHoldersLength; i++)
            {
               itemHolderContainer = DisplayObjectContainer(this.itemHolders[i]);
               while(itemHolderContainer.numChildren > 0)
               {
                  itemHolderContainer.removeChildAt(0);
               }
            }
         }
      }
      
      public function clearItems() : void
      {
         var ihLength:int = 0;
         var cih:int = 0;
         if(!this._textFieldMode)
         {
            ihLength = int(this.itemHolders.length);
            for(cih = 0; cih < ihLength; cih++)
            {
               if(this.itemsHolder.contains(this.itemHolders[cih]))
               {
                  this.itemsHolder.removeChild(this.itemHolders[cih]);
               }
            }
            return;
         }
         throw new Error("Clearing itemHolders for textFieldMode carousels is not supported!");
      }
      
      public function pickRandomItem(snapToRandom:Boolean = false) : void
      {
         var rpt:int = 0;
         var rcil:int = int(this.contentItems.length);
         var rt:int = int(Math.random() * rcil);
         if(!snapToRandom)
         {
            this._randomizing = true;
            rpt = rt + (Math.random() < 0.5 ? 8 : -8);
            if(rpt < 0)
            {
               rpt += rcil;
            }
            if(rpt >= rcil)
            {
               rpt -= rcil;
            }
            this._callDone = false;
            this.spinToIndex(rpt,true);
            this._callDone = true;
         }
         this.spinToIndex(rt,snapToRandom);
      }
      
      public function spinToAnimal(avType:int, snap:Boolean = false) : void
      {
         var found:Boolean = false;
         for(var i:int = 0; i < this.contentItems.length; i++)
         {
            if(this.contentItems[i].avTypeId == avType)
            {
               found = true;
               break;
            }
         }
         if(found)
         {
            this.spinToIndex(i,snap);
         }
         else
         {
            this.pickRandomItem(snap);
         }
      }
      
      private function spin() : void
      {
         if(this.soundsEnabled)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         this.startSpin();
      }
      
      public function spinToIndex(newIndex:int, snap:Boolean = false) : void
      {
         if(this._itemCycleTimer.hasEventListener(TimerEvent.TIMER) || newIndex < 0 || newIndex >= this.contentItems.length)
         {
            return;
         }
         if(!this._textFieldMode)
         {
            this._priceTag.visible = false;
            this._redBuyBtn.visible = false;
            this._greenBuyBtn.visible = false;
         }
         if(!snap && this.soundsEnabled)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         if(Math.abs(this._contentItemIndex - newIndex) < this.contentItems.length / 2)
         {
            this._itemCycleDown = this._contentItemIndex - newIndex > 0;
         }
         else
         {
            this._itemCycleDown = this._contentItemIndex - newIndex <= 0;
         }
         if(snap)
         {
            this._contentItemIndex = this._targetContentItemIndex = newIndex;
            this.displayItems(true,true);
            DarkenManager.showLoadingSpiral(false);
         }
         else
         {
            this._targetContentItemIndex = newIndex;
            this.startSpin();
         }
      }
      
      private function startSpin() : void
      {
         var khl:int = 0;
         var kh:int = 0;
         if(this._textFieldMode)
         {
            TextField(this.itemHolders[this._centerItemHolderIndex]).setTextFormat(this._centerTextFormatShadow);
            TextField(this.itemHolders[this._centerItemHolderIndex]).defaultTextFormat = this._centerTextFormatShadow;
         }
         else
         {
            khl = int(this.itemHolders.length);
            for(kh = 0; kh < khl; kh++)
            {
               this.itemHolders[kh].filters = [];
            }
         }
         if(!this._itemCycleDown)
         {
            this.setupHolders();
         }
         this._itemCycleTimer.addEventListener(TimerEvent.TIMER,this.itemCycleUpdate,false,0,true);
         this._lastTimer = getTimer();
         this._itemCycleTimer.start();
      }
      
      private function setupHolders(cycle:Boolean = true) : void
      {
         var itemHoldersLength:int = int(this.itemHolders.length);
         for(var cl:int = 0; cl < itemHoldersLength; cl++)
         {
            this.itemHolders[cl].y = this.itemInfos[int(this._itemCycleDown || !cycle ? cl : cl + 1)].stopY;
         }
         if(cycle)
         {
            this.cycleItems();
         }
      }
      
      private function cycleItems() : void
      {
         var contentItemsLength:int = int(this.contentItems.length);
         if(this._itemCycleDown)
         {
            if(--this._contentItemIndex == -1)
            {
               this._contentItemIndex = contentItemsLength - 1;
            }
         }
         else if(++this._contentItemIndex == contentItemsLength)
         {
            this._contentItemIndex = 0;
         }
         this.displayItems(!this._autoScroll && this._targetContentItemIndex == this._contentItemIndex);
      }
      
      private function displayItems(done:Boolean = true, snap:Boolean = false) : void
      {
         var abt:int = 0;
         var aat:int = 0;
         var rci:int = 0;
         var memOnlyIdx:int = 0;
         var abi:int = 0;
         var aai:int = 0;
         var itemHolderContainer:DisplayObjectContainer = null;
         var index:int = 0;
         var currAvtDef:Object = null;
         DarkenManager.showLoadingSpiral(false);
         var itemHoldersLength:int = Math.min(this.itemHolders.length,this.contentItems.length);
         var contentItemsLength:int = int(this.contentItems.length);
         var startContentItemsIdx:int = this._contentItemIndex - int(itemHoldersLength / 2);
         if(startContentItemsIdx < 0)
         {
            startContentItemsIdx += contentItemsLength;
         }
         if(this._textFieldMode)
         {
            abt = 0;
            aat = startContentItemsIdx;
            while(abt < itemHoldersLength)
            {
               LocalizationManager.updateToFit(TextField(this.itemHolders[abt]),this.contentItems[aat],false,false);
               if(++aat >= contentItemsLength)
               {
                  aat = 0;
               }
               abt++;
            }
         }
         else
         {
            for(rci = 0; rci < contentItemsLength; rci++)
            {
               if(DisplayObject(this.contentItems[rci]).parent != null && !DisplayObject(this.contentItems[rci]).parent is Loader)
               {
                  DisplayObject(this.contentItems[rci]).parent.removeChild(this.contentItems[rci]);
               }
            }
            if(this._lockViews == null || this._lockViewIdx >= this._numToLoad)
            {
               abi = 0;
               aai = startContentItemsIdx;
               while(abi < itemHoldersLength)
               {
                  itemHolderContainer = DisplayObjectContainer(this.itemHolders[abi]);
                  while(itemHolderContainer.numChildren > 0)
                  {
                     itemHolderContainer.removeChildAt(0);
                  }
                  itemHolderContainer.addChild(this.contentItems[aai]);
                  if(this.contentItems[aai] is AvatarView)
                  {
                     index = -1;
                     if(this.showOnlyOceanAnimals)
                     {
                        if(aai == this._contentItemIndex)
                        {
                           this.newOceanIndex = aai;
                        }
                        index = AvatarUtility.findAvatarIndexByType(this.contentItems[aai].avTypeId);
                     }
                     else
                     {
                        index = AvatarUtility.findAvatarIndexByType(this.contentItems[aai].avTypeId);
                     }
                     if(index != -1)
                     {
                        currAvtDef = AvatarUtility.avatarDefInfo[index];
                        if(!gMainFrame.userInfo.isMember)
                        {
                           if(Boolean(currAvtDef.isMemberOnly))
                           {
                              this._lockViews[index].memberOnly.y = 40;
                              itemHolderContainer.addChild(MovieClip(this._lockViews[index].memberOnly));
                           }
                        }
                        if(!this._isFromLogin && Utility.isOcean(currAvtDef.enviroFlag))
                        {
                           if(Boolean(this._lockViews[index].ocean))
                           {
                              this._lockViews[index].ocean.x = 90;
                              this._lockViews[index].ocean.y = -85;
                              itemHolderContainer.addChild(MovieClip(this._lockViews[index].ocean));
                           }
                        }
                        if(AvatarUtility.isExtinct(currAvtDef.availability))
                        {
                           this.contentItems[aai].blackOut();
                           if(Boolean(this._lockViews[index].endangered))
                           {
                              itemHolderContainer.addChild(MovieClip(this._lockViews[index].endangered));
                           }
                        }
                        else if(AvatarUtility.isEndangered(currAvtDef.availability))
                        {
                           if(Boolean(this._lockViews[index].endangered))
                           {
                              itemHolderContainer.addChild(MovieClip(this._lockViews[index].endangered));
                           }
                        }
                     }
                  }
                  if(++aai >= contentItemsLength)
                  {
                     aai = 0;
                  }
                  abi++;
               }
            }
            else
            {
               DebugUtility.debugTrace("_lockViewIdx=" + this._lockViewIdx + " _lockViews.length=" + this._lockViews.length);
            }
         }
         if(snap || done && this._callDone)
         {
            if(snap || this._itemCycleDown)
            {
               this.doneSpinning();
            }
         }
      }
      
      private function doneSpinning() : void
      {
         var itemHoldersLength:int = 0;
         var centerIH:DisplayObject = null;
         var globalIH:Point = null;
         var fh:int = 0;
         var index:int = 0;
         this._autoScroll = false;
         if(this._textFieldMode)
         {
            TextField(this.itemHolders[this._centerItemHolderIndex]).setTextFormat(this._centerTextFormatLight);
            TextField(this.itemHolders[this._centerItemHolderIndex]).defaultTextFormat = this._centerTextFormatLight;
            LocalizationManager.updateToFit(TextField(this.itemHolders[this._centerItemHolderIndex]),this.contentItems[this._contentItemIndex],false,false);
         }
         else
         {
            itemHoldersLength = int(this.itemHolders.length);
            centerIH = this.itemHolders[this._centerItemHolderIndex];
            globalIH = centerIH.localToGlobal(new Point(centerIH.mouseX,centerIH.mouseY));
            if(this.scrollerMask.hitTestPoint(globalIH.x,globalIH.y))
            {
               for(fh = 0; fh < itemHoldersLength; fh++)
               {
                  if(this.itemHolders[fh].hitTestPoint(globalIH.x,globalIH.y,true))
                  {
                     this.itemHolders[fh].filters = [this._hoverItemHolderGlowFilter];
                     break;
                  }
               }
            }
            if(this.shouldFilter())
            {
               centerIH.filters = [this._centerItemHolderGlowFilter];
            }
            else
            {
               centerIH.filters = [];
            }
            if(!this._isFromLogin && !this._btnHoldTimer.running)
            {
               index = index = AvatarUtility.findAvatarIndexByType(this.contentItems[this._contentItemIndex].avTypeId);
               if(!this.isChoosingFirstNonMember)
               {
                  this._priceTag.txt.text = AvatarUtility.avatarDefInfo[index].cost;
                  if(this._myGemCount < AvatarUtility.avatarDefInfo[index].cost)
                  {
                     this._priceTag.gotoAndStop("red");
                     this._priceTag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     this._priceTag.gotoAndStop("green");
                     this._priceTag.textColor = "0xFFFFFFFF";
                  }
               }
               else
               {
                  LocalizationManager.translateId(this._priceTag.txt,11176);
                  this._redBuyBtn.visible = false;
               }
               if(!AvatarUtility.isExtinct(AvatarUtility.avatarDefInfo[index].availability))
               {
                  this._greenBuyBtn.visible = true;
                  if(this._myGemCount < AvatarUtility.avatarDefInfo[index].cost)
                  {
                     this._redBuyBtn.visible = true;
                  }
                  this._priceTag.visible = true;
               }
            }
         }
         if(this.soundsEnabled && !this._btnHoldTimer.running)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenStopSound();
         }
         if((!this._randomizing || this._itemCycleTimer.running) && this.doneSpinningCallback != null)
         {
            this._randomizing = false;
            this.doneSpinningCallback();
         }
      }
      
      private function itemCycleUpdate(t:TimerEvent) : void
      {
         var cd:int = 0;
         var cu:int = 0;
         var cyclingDone:Boolean = false;
         var itemHoldersLength:int = int(this.itemHolders.length);
         var stopped:Boolean = false;
         var currTimer:int = getTimer();
         var timerScale:Number = (currTimer - this._lastTimer) / 20;
         var spinSpeedScaled:Number = timerScale * this.spinSpeed;
         if(this._itemCycleDown)
         {
            for(cd = 0; cd < itemHoldersLength; cd++)
            {
               if(this.itemHolders[cd].y + spinSpeedScaled < this.itemInfos[cd + 1].stopY)
               {
                  this.itemHolders[cd].y += spinSpeedScaled;
               }
               else
               {
                  this.itemHolders[cd].y = this.itemInfos[cd + 1].stopY;
                  stopped = true;
               }
            }
         }
         else
         {
            for(cu = 0; cu < itemHoldersLength; cu++)
            {
               if(this.itemHolders[cu].y - spinSpeedScaled > this.itemInfos[cu].stopY)
               {
                  this.itemHolders[cu].y -= spinSpeedScaled;
               }
               else
               {
                  this.itemHolders[cu].y = this.itemInfos[cu].stopY;
                  stopped = true;
               }
            }
         }
         this._lastTimer = currTimer;
         if(stopped)
         {
            if(this._itemCycleDown)
            {
               this.setupHolders();
            }
            cyclingDone = Boolean(!this._autoScroll && this._targetContentItemIndex == this._contentItemIndex);
            if(cyclingDone)
            {
               this._itemCycleTimer.removeEventListener(TimerEvent.TIMER,this.itemCycleUpdate);
               this._itemCycleTimer.reset();
               this._randomizing = false;
            }
            if(!this._itemCycleDown)
            {
               this.setupHolders(!cyclingDone);
               if(cyclingDone)
               {
                  this.doneSpinning();
               }
            }
         }
      }
      
      private function upBtnMouseDownHandler(m:MouseEvent) : void
      {
         var uItemIdx:int = 0;
         if(!this._itemCycleTimer.running)
         {
            uItemIdx = this._contentItemIndex - 1;
            if(uItemIdx == -1)
            {
               uItemIdx = this.contentItems.length - 1;
            }
            this._btnHoldTimer.start();
            this.spinToIndex(uItemIdx,false);
            this._autoCycleDown = true;
         }
      }
      
      private function downBtnMouseDownHandler(m:MouseEvent) : void
      {
         var dItemIdx:int = 0;
         if(!this._itemCycleTimer.running)
         {
            dItemIdx = this._contentItemIndex + 1;
            if(dItemIdx == this.contentItems.length)
            {
               dItemIdx = 0;
            }
            this._btnHoldTimer.start();
            this.spinToIndex(dItemIdx,false);
            this._autoCycleDown = false;
         }
      }
      
      private function btnHoldTimerHandler(t:TimerEvent) : void
      {
         this._autoScroll = true;
         this._itemCycleDown = this._autoCycleDown;
         this._btnHoldTimer.reset();
         this.spin();
      }
      
      private function upBtnMouseUpOutHandler(m:MouseEvent) : void
      {
         this._btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(this._autoScroll)
         {
            this._autoScroll = false;
            this._targetContentItemIndex = this._contentItemIndex - 1;
            if(this._targetContentItemIndex == -1)
            {
               this._targetContentItemIndex = this.contentItems.length - 1;
            }
         }
      }
      
      private function downBtnMouseUpOutHandler(m:MouseEvent) : void
      {
         this._btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(this._autoScroll)
         {
            this._autoScroll = false;
            this._targetContentItemIndex = this._contentItemIndex;
         }
      }
      
      private function itemMouseDownHandler(m:MouseEvent) : void
      {
         this.spinToIndex(this.contentItems.indexOf(this._textFieldMode ? m.currentTarget.text : m.currentTarget.getChildAt(0)),false);
      }
      
      private function itemMouseOverHandler(m:MouseEvent) : void
      {
         if(!this._itemCycleTimer.hasEventListener(TimerEvent.TIMER) && m.currentTarget != this.itemHolders[this._centerItemHolderIndex])
         {
            m.currentTarget.filters = [this._hoverItemHolderGlowFilter];
         }
      }
      
      private function itemMouseOutHandler(m:MouseEvent) : void
      {
         if(!this._textFieldMode && !this._itemCycleTimer.hasEventListener(TimerEvent.TIMER) && m.currentTarget == this.itemHolders[this._centerItemHolderIndex])
         {
            if(this.shouldFilter())
            {
               m.currentTarget.filters = [this._centerItemHolderGlowFilter];
            }
         }
         else
         {
            m.currentTarget.filters = [];
         }
      }
   }
}

class ItemInfo
{
   
   public var stopY:Number;
   
   public function ItemInfo()
   {
      super();
   }
}
