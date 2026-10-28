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
      
      public function GuiCarousel(param1:MovieClip)
      {
         super();
         this._guiAsset = param1;
      }
      
      public function init(param1:Array, param2:Function = null, param3:Boolean = false, param4:Boolean = false, param5:Function = null, param6:Boolean = false, param7:int = -1) : void
      {
         var _loc9_:int = 0;
         var _loc13_:DisplayObject = null;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:MediaHelper = null;
         var _loc18_:Object = null;
         this._lastTimer = getTimer();
         var _loc8_:int = int(param1.length);
         this._textFieldMode = param1[0] is String;
         this.fullContentItems = param1;
         this.oceanOnlyItems = [];
         var _loc10_:Array = [];
         this._startingIndex = param7;
         this._avtViewsFlag = gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG);
         _loc9_ = 0;
         while(_loc9_ < _loc8_)
         {
            if(Boolean(AvatarUtility.avatarDefInfo && AvatarUtility.avatarDefInfo.length > 0) && Boolean(_loc9_ < AvatarUtility.avatarDefInfo.length) && Boolean(AvatarUtility.avatarDefInfo[_loc9_]))
            {
               if((this._avtViewsFlag & 1 << AvatarUtility.avatarTypes[_loc9_] - 1) != 0)
               {
                  _loc10_.push(param1[_loc9_]);
               }
               if(Utility.isOcean(AvatarUtility.avatarDefInfo[_loc9_].enviroFlag))
               {
                  this.oceanOnlyItems.push(param1[_loc9_]);
               }
            }
            _loc9_++;
         }
         if(this.showOnlyOceanAnimals)
         {
            this.contentItems = this.oceanOnlyItems;
         }
         else if(this._textFieldMode || param1[0] is MovieClip)
         {
            this.contentItems = param1;
         }
         else
         {
            this.contentItems = _loc10_;
         }
         _loc8_ = int(this.contentItems.length);
         this._isFromLogin = param6;
         if(_loc8_ < 1)
         {
            throw new Error("Attempted to init GuiCarousel with content array length less than one!");
         }
         var _loc11_:int = 0;
         while(_loc11_ < _loc8_)
         {
            if(!(param1[_loc11_] is String) && !(param1[_loc11_] is DisplayObject))
            {
               throw new Error("Attempted to init GuiCarousel with non-DisplayObject content array!");
            }
            _loc11_++;
         }
         this.doneSpinningCallback = param2;
         this.soundsEnabled = param3;
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
         var _loc12_:int = 0;
         while(this.itemsHolder.hasOwnProperty("_item" + _loc12_))
         {
            _loc13_ = this.itemsHolder["_item" + _loc12_];
            this.itemInfos[int(_loc12_)] = new ItemInfo();
            this.itemInfos[int(_loc12_)].stopY = _loc13_.y;
            if(!this._textFieldMode)
            {
               _loc13_.visible = false;
            }
            _loc12_++;
         }
         if(_loc12_ == 0)
         {
            throw new Error("GuiCarousel did not have any _item# instances inside it!");
         }
         if(param4)
         {
            throw new Error("shrinkMode not supported yet!");
         }
         this.itemInfos[_loc12_] = new ItemInfo();
         this.itemInfos[_loc12_].stopY = this.itemInfos.length > 2 ? this.itemInfos[_loc12_ - 1].stopY + (this.itemInfos[_loc12_ - 1].stopY - this.itemInfos[_loc12_ - 2].stopY) : this.itemInfos[_loc12_ - 1].stopY + this.itemsHolder["_item1"].height;
         if(this._textFieldMode)
         {
            this.itemHolders = new Vector.<DisplayObject>(_loc12_);
            _loc14_ = 0;
            while(_loc14_ < _loc12_)
            {
               this.itemHolders[_loc14_] = this.itemsHolder["_item" + _loc14_];
               this.itemHolders[_loc14_].addEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler,false,0,true);
               this.itemHolders[_loc14_].addEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler,false,0,true);
               this.itemHolders[_loc14_].addEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler,false,0,true);
               _loc14_++;
            }
         }
         else
         {
            this.itemHolders = new Vector.<DisplayObject>(_loc12_);
            _loc15_ = 0;
            while(_loc15_ < _loc12_)
            {
               this.itemHolders[_loc15_] = new Sprite();
               this.itemHolders[_loc15_].y = this.itemInfos[_loc15_].stopY;
               this.itemHolders[_loc15_].addEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler,false,0,true);
               this.itemHolders[_loc15_].addEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler,false,0,true);
               this.itemHolders[_loc15_].addEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler,false,0,true);
               this.itemsHolder.addChild(this.itemHolders[_loc15_]);
               _loc15_++;
            }
         }
         this._hoverItemHolderGlowFilter = new GlowFilter(16777215,1,16,16,3);
         this._centerItemHolderIndex = _loc12_ / 2;
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
         this._continueCallback = param5;
         this._lockViewIdx = 0;
         this._numToLoad = 0;
         if(_loc8_ > 0 && this.contentItems[0] is AvatarView)
         {
            _loc16_ = int(AvatarUtility.avatarDefInfo.length);
            this._lockViews = [];
            this._mediaHolder = [];
            _loc9_ = 0;
            while(_loc9_ < _loc16_)
            {
               _loc18_ = AvatarUtility.avatarDefInfo[_loc9_];
               if(_loc18_)
               {
                  if(_loc18_.isMemberOnly)
                  {
                     ++this._numToLoad;
                     _loc17_ = new MediaHelper();
                     _loc17_.init(360,this.lockMediaCallback,{
                        "index":_loc9_,
                        "isMemberOnly":true
                     });
                     this._mediaHolder.push(_loc17_);
                  }
                  if(Utility.isOcean(_loc18_.enviroFlag))
                  {
                     ++this._numToLoad;
                     _loc17_ = new MediaHelper();
                     _loc17_.init(1165,this.lockMediaCallback,{
                        "index":_loc9_,
                        "isOcean":true
                     });
                     this._mediaHolder.push(_loc17_);
                  }
                  if(_loc18_.availability >= AvatarUtility.AVT_AVAIL_ENDANGERED)
                  {
                     ++this._numToLoad;
                     _loc17_ = new MediaHelper();
                     _loc17_.init(1387,this.lockMediaCallback,{
                        "index":_loc9_,
                        "isEndangered":true
                     });
                     this._mediaHolder.push(_loc17_);
                  }
               }
               _loc9_++;
            }
         }
         else
         {
            this.spinToIndex(param7 == -1 ? int(_loc8_ / 2) : param7,true);
            if(this._continueCallback != null)
            {
               this._continueCallback();
            }
         }
         this._hasLoaded = true;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         this._btnHoldTimer.stop();
         this._btnHoldTimer = null;
         this._itemCycleTimer.stop();
         this._itemCycleTimer = null;
         if(this._mediaHolder)
         {
            _loc1_ = 0;
            while(_loc1_ < this._mediaHolder.length)
            {
               this._mediaHolder[_loc1_].destroy();
               _loc1_++;
            }
            this._mediaHolder = null;
         }
         this.upBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.upBtnMouseDownHandler);
         this.upBtn.removeEventListener(MouseEvent.MOUSE_UP,this.upBtnMouseUpOutHandler);
         this.upBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.upBtnMouseUpOutHandler);
         this.downBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.downBtnMouseDownHandler);
         this.downBtn.removeEventListener(MouseEvent.MOUSE_UP,this.downBtnMouseUpOutHandler);
         this.downBtn.removeEventListener(MouseEvent.MOUSE_OUT,this.downBtnMouseUpOutHandler);
         _loc1_ = 0;
         while(_loc1_ < this.itemHolders.length)
         {
            this.itemHolders[_loc1_].removeEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler);
            this.itemHolders[_loc1_].removeEventListener(MouseEvent.MOUSE_OVER,this.itemMouseOverHandler);
            this.itemHolders[_loc1_].removeEventListener(MouseEvent.MOUSE_OUT,this.itemMouseOutHandler);
            _loc1_++;
         }
         this.itemHolders = null;
      }
      
      private function lockMediaCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            if(!this._lockViews[param1.passback.index])
            {
               this._lockViews[param1.passback.index] = {
                  "memberOnly":null,
                  "ocean":null,
                  "endangered":null
               };
            }
            if(param1.passback.isMemberOnly)
            {
               this._lockViews[param1.passback.index].memberOnly = param1;
            }
            else if(param1.passback.isOcean)
            {
               param1.scaleX = 2;
               param1.scaleY = 2;
               this._lockViews[param1.passback.index].ocean = param1;
            }
            else if(param1.passback.isEndangered)
            {
               this._lockViews[param1.passback.index].endangered = param1;
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
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
      }
      
      public function get contentItemIndex() : int
      {
         return this._contentItemIndex;
      }
      
      public function set contentItemIndex(param1:int) : void
      {
         if(param1 == this._contentItemIndex)
         {
            return;
         }
         this.spinToIndex(param1);
      }
      
      public function get selectedContentItem() : *
      {
         return this.contentItems ? this.contentItems[this._contentItemIndex] : null;
      }
      
      public function set selectedContentItem(param1:*) : void
      {
         this.spinToIndex(this.contentItems.indexOf(param1));
      }
      
      public function get hasLoaded() : Boolean
      {
         return this._hasLoaded;
      }
      
      private function shouldFilter() : Boolean
      {
         var _loc1_:DisplayObject = null;
         if(this.itemHolders[this._centerItemHolderIndex] is Sprite && DisplayObjectContainer(this.itemHolders[this._centerItemHolderIndex]).numChildren > 0 && this.contentItems[0] is AvatarView)
         {
            _loc1_ = DisplayObjectContainer(this.itemHolders[this._centerItemHolderIndex]).getChildAt(0);
            if(AvatarUtility.isExtinct(AvatarUtility.findAvDefByType(AvatarView(_loc1_).avTypeId).availability))
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
         var _loc1_:int = 0;
         if(!this.showOnlyOceanAnimals)
         {
            this._avtViewsFlag = gMainFrame.userInfo.userVarCache.getUserVarValueById(AchievementXtCommManager.UV_AVT_VIEWABLE_FLAG);
            this.contentItems = [];
            _loc1_ = 0;
            while(_loc1_ < this.fullContentItems.length)
            {
               if((this._avtViewsFlag & 1 << AvatarUtility.avatarTypes[_loc1_] - 1) != 0)
               {
                  this.contentItems.push(this.fullContentItems[_loc1_]);
               }
               _loc1_++;
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
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:DisplayObjectContainer = null;
         if(Boolean(this.itemHolders) && Boolean(this.contentItems))
         {
            _loc1_ = Math.min(this.itemHolders.length,this.contentItems.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               _loc3_ = DisplayObjectContainer(this.itemHolders[_loc2_]);
               while(_loc3_.numChildren > 0)
               {
                  _loc3_.removeChildAt(0);
               }
               _loc2_++;
            }
         }
      }
      
      public function clearItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!this._textFieldMode)
         {
            _loc1_ = int(this.itemHolders.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(this.itemsHolder.contains(this.itemHolders[_loc2_]))
               {
                  this.itemsHolder.removeChild(this.itemHolders[_loc2_]);
               }
               _loc2_++;
            }
            return;
         }
         throw new Error("Clearing itemHolders for textFieldMode carousels is not supported!");
      }
      
      public function pickRandomItem(param1:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc2_:int = int(this.contentItems.length);
         var _loc3_:int = int(Math.random() * _loc2_);
         if(!param1)
         {
            this._randomizing = true;
            _loc4_ = _loc3_ + (Math.random() < 0.5 ? 8 : -8);
            if(_loc4_ < 0)
            {
               _loc4_ += _loc2_;
            }
            if(_loc4_ >= _loc2_)
            {
               _loc4_ -= _loc2_;
            }
            this._callDone = false;
            this.spinToIndex(_loc4_,true);
            this._callDone = true;
         }
         this.spinToIndex(_loc3_,param1);
      }
      
      public function spinToAnimal(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         while(_loc4_ < this.contentItems.length)
         {
            if(this.contentItems[_loc4_].avTypeId == param1)
            {
               _loc3_ = true;
               break;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            this.spinToIndex(_loc4_,param2);
         }
         else
         {
            this.pickRandomItem(param2);
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
      
      public function spinToIndex(param1:int, param2:Boolean = false) : void
      {
         if(this._itemCycleTimer.hasEventListener(TimerEvent.TIMER) || param1 < 0 || param1 >= this.contentItems.length)
         {
            return;
         }
         if(!this._textFieldMode)
         {
            this._priceTag.visible = false;
            this._redBuyBtn.visible = false;
            this._greenBuyBtn.visible = false;
         }
         if(!param2 && this.soundsEnabled)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         if(Math.abs(this._contentItemIndex - param1) < this.contentItems.length / 2)
         {
            this._itemCycleDown = this._contentItemIndex - param1 > 0;
         }
         else
         {
            this._itemCycleDown = this._contentItemIndex - param1 <= 0;
         }
         if(param2)
         {
            this._contentItemIndex = this._targetContentItemIndex = param1;
            this.displayItems(true,true);
            DarkenManager.showLoadingSpiral(false);
         }
         else
         {
            this._targetContentItemIndex = param1;
            this.startSpin();
         }
      }
      
      private function startSpin() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(this._textFieldMode)
         {
            TextField(this.itemHolders[this._centerItemHolderIndex]).setTextFormat(this._centerTextFormatShadow);
            TextField(this.itemHolders[this._centerItemHolderIndex]).defaultTextFormat = this._centerTextFormatShadow;
         }
         else
         {
            _loc1_ = int(this.itemHolders.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               this.itemHolders[_loc2_].filters = [];
               _loc2_++;
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
      
      private function setupHolders(param1:Boolean = true) : void
      {
         var _loc2_:int = int(this.itemHolders.length);
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.itemHolders[_loc3_].y = this.itemInfos[int(this._itemCycleDown || !param1 ? _loc3_ : _loc3_ + 1)].stopY;
            _loc3_++;
         }
         if(param1)
         {
            this.cycleItems();
         }
      }
      
      private function cycleItems() : void
      {
         var _loc1_:int = int(this.contentItems.length);
         if(this._itemCycleDown)
         {
            if(--this._contentItemIndex == -1)
            {
               this._contentItemIndex = _loc1_ - 1;
            }
         }
         else if(++this._contentItemIndex == _loc1_)
         {
            this._contentItemIndex = 0;
         }
         this.displayItems(!this._autoScroll && this._targetContentItemIndex == this._contentItemIndex);
      }
      
      private function displayItems(param1:Boolean = true, param2:Boolean = false) : void
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:DisplayObjectContainer = null;
         var _loc13_:int = 0;
         var _loc14_:Object = null;
         DarkenManager.showLoadingSpiral(false);
         var _loc3_:int = Math.min(this.itemHolders.length,this.contentItems.length);
         var _loc4_:int = int(this.contentItems.length);
         var _loc5_:int = this._contentItemIndex - int(_loc3_ / 2);
         if(_loc5_ < 0)
         {
            _loc5_ += _loc4_;
         }
         if(this._textFieldMode)
         {
            _loc6_ = 0;
            _loc7_ = _loc5_;
            while(_loc6_ < _loc3_)
            {
               LocalizationManager.updateToFit(TextField(this.itemHolders[_loc6_]),this.contentItems[_loc7_],false,false);
               if(++_loc7_ >= _loc4_)
               {
                  _loc7_ = 0;
               }
               _loc6_++;
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < _loc4_)
            {
               if(DisplayObject(this.contentItems[_loc8_]).parent != null && !DisplayObject(this.contentItems[_loc8_]).parent is Loader)
               {
                  DisplayObject(this.contentItems[_loc8_]).parent.removeChild(this.contentItems[_loc8_]);
               }
               _loc8_++;
            }
            if(this._lockViews == null || this._lockViewIdx >= this._numToLoad)
            {
               _loc10_ = 0;
               _loc11_ = _loc5_;
               while(_loc10_ < _loc3_)
               {
                  _loc12_ = DisplayObjectContainer(this.itemHolders[_loc10_]);
                  while(_loc12_.numChildren > 0)
                  {
                     _loc12_.removeChildAt(0);
                  }
                  _loc12_.addChild(this.contentItems[_loc11_]);
                  if(this.contentItems[_loc11_] is AvatarView)
                  {
                     _loc13_ = -1;
                     if(this.showOnlyOceanAnimals)
                     {
                        if(_loc11_ == this._contentItemIndex)
                        {
                           this.newOceanIndex = _loc11_;
                        }
                        _loc13_ = AvatarUtility.findAvatarIndexByType(this.contentItems[_loc11_].avTypeId);
                     }
                     else
                     {
                        _loc13_ = AvatarUtility.findAvatarIndexByType(this.contentItems[_loc11_].avTypeId);
                     }
                     if(_loc13_ != -1)
                     {
                        _loc14_ = AvatarUtility.avatarDefInfo[_loc13_];
                        if(!gMainFrame.userInfo.isMember)
                        {
                           if(_loc14_.isMemberOnly)
                           {
                              this._lockViews[_loc13_].memberOnly.y = 40;
                              _loc12_.addChild(MovieClip(this._lockViews[_loc13_].memberOnly));
                           }
                        }
                        if(!this._isFromLogin && Utility.isOcean(_loc14_.enviroFlag))
                        {
                           if(this._lockViews[_loc13_].ocean)
                           {
                              this._lockViews[_loc13_].ocean.x = 90;
                              this._lockViews[_loc13_].ocean.y = -85;
                              _loc12_.addChild(MovieClip(this._lockViews[_loc13_].ocean));
                           }
                        }
                        if(AvatarUtility.isExtinct(_loc14_.availability))
                        {
                           this.contentItems[_loc11_].blackOut();
                           if(this._lockViews[_loc13_].endangered)
                           {
                              _loc12_.addChild(MovieClip(this._lockViews[_loc13_].endangered));
                           }
                        }
                        else if(AvatarUtility.isEndangered(_loc14_.availability))
                        {
                           if(this._lockViews[_loc13_].endangered)
                           {
                              _loc12_.addChild(MovieClip(this._lockViews[_loc13_].endangered));
                           }
                        }
                     }
                  }
                  if(++_loc11_ >= _loc4_)
                  {
                     _loc11_ = 0;
                  }
                  _loc10_++;
               }
            }
            else
            {
               DebugUtility.debugTrace("_lockViewIdx=" + this._lockViewIdx + " _lockViews.length=" + this._lockViews.length);
            }
         }
         if(param2 || param1 && this._callDone)
         {
            if(param2 || this._itemCycleDown)
            {
               this.doneSpinning();
            }
         }
      }
      
      private function doneSpinning() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         this._autoScroll = false;
         if(this._textFieldMode)
         {
            TextField(this.itemHolders[this._centerItemHolderIndex]).setTextFormat(this._centerTextFormatLight);
            TextField(this.itemHolders[this._centerItemHolderIndex]).defaultTextFormat = this._centerTextFormatLight;
            LocalizationManager.updateToFit(TextField(this.itemHolders[this._centerItemHolderIndex]),this.contentItems[this._contentItemIndex],false,false);
         }
         else
         {
            _loc1_ = int(this.itemHolders.length);
            _loc2_ = this.itemHolders[this._centerItemHolderIndex];
            _loc3_ = _loc2_.localToGlobal(new Point(_loc2_.mouseX,_loc2_.mouseY));
            if(this.scrollerMask.hitTestPoint(_loc3_.x,_loc3_.y))
            {
               _loc4_ = 0;
               while(_loc4_ < _loc1_)
               {
                  if(this.itemHolders[_loc4_].hitTestPoint(_loc3_.x,_loc3_.y,true))
                  {
                     this.itemHolders[_loc4_].filters = [this._hoverItemHolderGlowFilter];
                     break;
                  }
                  _loc4_++;
               }
            }
            if(this.shouldFilter())
            {
               _loc2_.filters = [this._centerItemHolderGlowFilter];
            }
            else
            {
               _loc2_.filters = [];
            }
            if(!this._isFromLogin && !this._btnHoldTimer.running)
            {
               _loc5_ = _loc5_ = AvatarUtility.findAvatarIndexByType(this.contentItems[this._contentItemIndex].avTypeId);
               if(!this.isChoosingFirstNonMember)
               {
                  this._priceTag.txt.text = AvatarUtility.avatarDefInfo[_loc5_].cost;
                  if(this._myGemCount < AvatarUtility.avatarDefInfo[_loc5_].cost)
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
               if(!AvatarUtility.isExtinct(AvatarUtility.avatarDefInfo[_loc5_].availability))
               {
                  this._greenBuyBtn.visible = true;
                  if(this._myGemCount < AvatarUtility.avatarDefInfo[_loc5_].cost)
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
      
      private function itemCycleUpdate(param1:TimerEvent) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:Boolean = false;
         var _loc2_:int = int(this.itemHolders.length);
         var _loc3_:Boolean = false;
         var _loc4_:int = getTimer();
         var _loc5_:Number = (_loc4_ - this._lastTimer) / 20;
         var _loc6_:Number = _loc5_ * this.spinSpeed;
         if(this._itemCycleDown)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc2_)
            {
               if(this.itemHolders[_loc7_].y + _loc6_ < this.itemInfos[_loc7_ + 1].stopY)
               {
                  this.itemHolders[_loc7_].y += _loc6_;
               }
               else
               {
                  this.itemHolders[_loc7_].y = this.itemInfos[_loc7_ + 1].stopY;
                  _loc3_ = true;
               }
               _loc7_++;
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < _loc2_)
            {
               if(this.itemHolders[_loc8_].y - _loc6_ > this.itemInfos[_loc8_].stopY)
               {
                  this.itemHolders[_loc8_].y -= _loc6_;
               }
               else
               {
                  this.itemHolders[_loc8_].y = this.itemInfos[_loc8_].stopY;
                  _loc3_ = true;
               }
               _loc8_++;
            }
         }
         this._lastTimer = _loc4_;
         if(_loc3_)
         {
            if(this._itemCycleDown)
            {
               this.setupHolders();
            }
            _loc9_ = Boolean(!this._autoScroll && this._targetContentItemIndex == this._contentItemIndex);
            if(_loc9_)
            {
               this._itemCycleTimer.removeEventListener(TimerEvent.TIMER,this.itemCycleUpdate);
               this._itemCycleTimer.reset();
               this._randomizing = false;
            }
            if(!this._itemCycleDown)
            {
               this.setupHolders(!_loc9_);
               if(_loc9_)
               {
                  this.doneSpinning();
               }
            }
         }
      }
      
      private function upBtnMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!this._itemCycleTimer.running)
         {
            _loc2_ = this._contentItemIndex - 1;
            if(_loc2_ == -1)
            {
               _loc2_ = this.contentItems.length - 1;
            }
            this._btnHoldTimer.start();
            this.spinToIndex(_loc2_,false);
            this._autoCycleDown = true;
         }
      }
      
      private function downBtnMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!this._itemCycleTimer.running)
         {
            _loc2_ = this._contentItemIndex + 1;
            if(_loc2_ == this.contentItems.length)
            {
               _loc2_ = 0;
            }
            this._btnHoldTimer.start();
            this.spinToIndex(_loc2_,false);
            this._autoCycleDown = false;
         }
      }
      
      private function btnHoldTimerHandler(param1:TimerEvent) : void
      {
         this._autoScroll = true;
         this._itemCycleDown = this._autoCycleDown;
         this._btnHoldTimer.reset();
         this.spin();
      }
      
      private function upBtnMouseUpOutHandler(param1:MouseEvent) : void
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
      
      private function downBtnMouseUpOutHandler(param1:MouseEvent) : void
      {
         this._btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(this._autoScroll)
         {
            this._autoScroll = false;
            this._targetContentItemIndex = this._contentItemIndex;
         }
      }
      
      private function itemMouseDownHandler(param1:MouseEvent) : void
      {
         this.spinToIndex(this.contentItems.indexOf(this._textFieldMode ? param1.currentTarget.text : param1.currentTarget.getChildAt(0)),false);
      }
      
      private function itemMouseOverHandler(param1:MouseEvent) : void
      {
         if(!this._itemCycleTimer.hasEventListener(TimerEvent.TIMER) && param1.currentTarget != this.itemHolders[this._centerItemHolderIndex])
         {
            param1.currentTarget.filters = [this._hoverItemHolderGlowFilter];
         }
      }
      
      private function itemMouseOutHandler(param1:MouseEvent) : void
      {
         if(!this._textFieldMode && !this._itemCycleTimer.hasEventListener(TimerEvent.TIMER) && param1.currentTarget == this.itemHolders[this._centerItemHolderIndex])
         {
            if(this.shouldFilter())
            {
               param1.currentTarget.filters = [this._centerItemHolderGlowFilter];
            }
         }
         else
         {
            param1.currentTarget.filters = [];
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
