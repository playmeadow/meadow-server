package gui
{
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.debug.DebugUtility;
   import currency.UserCurrency;
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
         _guiAsset = param1;
      }
      
      public function init(param1:Array, param2:Function = null, param3:Boolean = false, param4:Boolean = false, param5:Function = null, param6:Boolean = false, param7:int = -1) : void
      {
         var _loc12_:int = 0;
         var _loc14_:int = 0;
         var _loc11_:DisplayObject = null;
         var _loc13_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:MediaHelper = null;
         var _loc16_:Object = null;
         _lastTimer = getTimer();
         var _loc18_:int = int(param1.length);
         _textFieldMode = param1[0] is String;
         fullContentItems = param1;
         oceanOnlyItems = [];
         var _loc15_:Array = [];
         _startingIndex = param7;
         if(showOnlyOceanAnimals)
         {
            contentItems = oceanOnlyItems;
         }
         else if(_textFieldMode || param1[0] is MovieClip)
         {
            contentItems = param1;
         }
         else
         {
            contentItems = _loc15_;
         }
         _loc18_ = int(contentItems.length);
         _isFromLogin = param6;
         if(_loc18_ < 1)
         {
            throw new Error("Attempted to init GuiCarousel with content array length less than one!");
         }
         _loc14_ = 0;
         while(_loc14_ < _loc18_)
         {
            if(!(param1[_loc14_] is String) && !(param1[_loc14_] is DisplayObject))
            {
               throw new Error("Attempted to init GuiCarousel with non-DisplayObject content array!");
            }
            _loc14_++;
         }
         doneSpinningCallback = param2;
         soundsEnabled = param3;
         upBtn = _guiAsset._up;
         downBtn = _guiAsset._down;
         itemsHolder = _guiAsset._items;
         scrollerMask = _guiAsset.scrollerMask;
         if(!(upBtn && downBtn && itemsHolder && scrollerMask))
         {
            throw new Error("GuiCarousel is missing parts or they are named incorrectly!");
         }
         upBtn.stop();
         upBtn.addEventListener("mouseDown",upBtnMouseDownHandler,false,0,true);
         upBtn.addEventListener("mouseUp",upBtnMouseUpOutHandler,false,0,true);
         upBtn.addEventListener("mouseOut",upBtnMouseUpOutHandler,false,0,true);
         downBtn.stop();
         downBtn.addEventListener("mouseDown",downBtnMouseDownHandler,false,0,true);
         downBtn.addEventListener("mouseUp",downBtnMouseUpOutHandler,false,0,true);
         downBtn.addEventListener("mouseOut",downBtnMouseUpOutHandler,false,0,true);
         _myGemCount = UserCurrency.getCurrency(0);
         if(!_textFieldMode)
         {
            if(_guiAsset.parent.hasOwnProperty("tag"))
            {
               _priceTag = _guiAsset.parent["tag"];
               _priceTag.visible = false;
            }
            if(_guiAsset.parent.hasOwnProperty("buy_btn_red"))
            {
               _redBuyBtn = _guiAsset.parent["buy_btn_red"];
               _greenBuyBtn = _guiAsset.parent["buy_btn_green"];
               _nextBtn = _guiAsset.parent["next_btn"];
               _redBuyBtn.visible = false;
            }
            if(!_isFromLogin)
            {
               _nextBtn.visible = false;
            }
         }
         itemInfos = new Vector.<ItemInfo>(2);
         var _loc17_:int = 0;
         while(itemsHolder.hasOwnProperty("_item" + _loc17_))
         {
            _loc11_ = itemsHolder["_item" + _loc17_];
            itemInfos[_loc17_] = new ItemInfo();
            itemInfos[_loc17_].stopY = _loc11_.y;
            if(!_textFieldMode)
            {
               _loc11_.visible = false;
            }
            _loc17_++;
         }
         if(_loc17_ == 0)
         {
            throw new Error("GuiCarousel did not have any _item# instances inside it!");
         }
         if(param4)
         {
            throw new Error("shrinkMode not supported yet!");
         }
         itemInfos[_loc17_] = new ItemInfo();
         itemInfos[_loc17_].stopY = itemInfos.length > 2 ? itemInfos[_loc17_ - 1].stopY + (itemInfos[_loc17_ - 1].stopY - itemInfos[_loc17_ - 2].stopY) : itemInfos[_loc17_ - 1].stopY + itemsHolder["_item1"].height;
         if(_textFieldMode)
         {
            itemHolders = new Vector.<DisplayObject>(_loc17_);
            _loc13_ = 0;
            while(_loc13_ < _loc17_)
            {
               itemHolders[_loc13_] = itemsHolder["_item" + _loc13_];
               itemHolders[_loc13_].addEventListener("mouseDown",itemMouseDownHandler,false,0,true);
               itemHolders[_loc13_].addEventListener("mouseOver",itemMouseOverHandler,false,0,true);
               itemHolders[_loc13_].addEventListener("mouseOut",itemMouseOutHandler,false,0,true);
               _loc13_++;
            }
         }
         else
         {
            itemHolders = new Vector.<DisplayObject>(_loc17_);
            _loc9_ = 0;
            while(_loc9_ < _loc17_)
            {
               itemHolders[_loc9_] = new Sprite();
               itemHolders[_loc9_].y = itemInfos[_loc9_].stopY;
               itemHolders[_loc9_].addEventListener("mouseDown",itemMouseDownHandler,false,0,true);
               itemHolders[_loc9_].addEventListener("mouseOver",itemMouseOverHandler,false,0,true);
               itemHolders[_loc9_].addEventListener("mouseOut",itemMouseOutHandler,false,0,true);
               itemsHolder.addChild(itemHolders[_loc9_]);
               _loc9_++;
            }
         }
         _hoverItemHolderGlowFilter = new GlowFilter(16777215,1,16,16,3);
         _centerItemHolderIndex = _loc17_ / 2;
         if(_textFieldMode)
         {
            _centerTextFormatShadow = TextField(itemsHolder["_item1"]).getTextFormat();
            _centerTextFormatLight = TextField(itemsHolder["_item" + _centerItemHolderIndex]).getTextFormat();
         }
         else
         {
            _centerItemHolderGlowFilter = new GlowFilter(3407667,1,16,16,2);
            if(shouldFilter())
            {
               itemHolders[_centerItemHolderIndex].filters = [_centerItemHolderGlowFilter];
            }
         }
         _btnHoldTimer = new Timer(500,1);
         _btnHoldTimer.addEventListener("timer",btnHoldTimerHandler,false,0,true);
         _itemCycleTimer = new Timer(20);
         _autoScroll = false;
         if(_textFieldMode)
         {
            spinSpeed = 3;
         }
         else
         {
            spinSpeed = 8;
         }
         _callDone = true;
         _continueCallback = param5;
         _lockViewIdx = 0;
         _numToLoad = 0;
         if(_loc18_ > 0 && contentItems[0] is AvatarView)
         {
            _loc8_ = AvatarUtility.numAvatarDefs;
            _lockViews = [];
            _mediaHolder = [];
            _loc12_ = 0;
            while(_loc12_ < _loc8_)
            {
               _loc16_ = AvatarUtility.getAvatarDefByIndex(_loc12_);
               if(_loc16_)
               {
                  if(_loc16_.isMemberOnly)
                  {
                     _numToLoad = _numToLoad + 1;
                     _loc10_ = new MediaHelper();
                     _loc10_.init(360,lockMediaCallback,{
                        "index":_loc12_,
                        "isMemberOnly":true
                     });
                     _mediaHolder.push(_loc10_);
                  }
                  if(Utility.isOcean(_loc16_.enviroFlag))
                  {
                     _numToLoad = _numToLoad + 1;
                     _loc10_ = new MediaHelper();
                     _loc10_.init(1165,lockMediaCallback,{
                        "index":_loc12_,
                        "isOcean":true
                     });
                     _mediaHolder.push(_loc10_);
                  }
                  if(_loc16_.availability >= 2)
                  {
                     _numToLoad = _numToLoad + 1;
                     _loc10_ = new MediaHelper();
                     _loc10_.init(1387,lockMediaCallback,{
                        "index":_loc12_,
                        "isEndangered":true
                     });
                     _mediaHolder.push(_loc10_);
                  }
               }
               _loc12_++;
            }
         }
         else
         {
            spinToIndex(param7 == -1 ? _loc18_ / 2 : param7,true);
            if(_continueCallback != null)
            {
               _continueCallback();
            }
         }
         _hasLoaded = true;
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         _btnHoldTimer.stop();
         _btnHoldTimer = null;
         _itemCycleTimer.stop();
         _itemCycleTimer = null;
         if(_mediaHolder)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaHolder.length)
            {
               _mediaHolder[_loc1_].destroy();
               _loc1_++;
            }
            _mediaHolder = null;
         }
         upBtn.removeEventListener("mouseDown",upBtnMouseDownHandler);
         upBtn.removeEventListener("mouseUp",upBtnMouseUpOutHandler);
         upBtn.removeEventListener("mouseOut",upBtnMouseUpOutHandler);
         downBtn.removeEventListener("mouseDown",downBtnMouseDownHandler);
         downBtn.removeEventListener("mouseUp",downBtnMouseUpOutHandler);
         downBtn.removeEventListener("mouseOut",downBtnMouseUpOutHandler);
         _loc1_ = 0;
         while(_loc1_ < itemHolders.length)
         {
            itemHolders[_loc1_].removeEventListener("mouseDown",itemMouseDownHandler);
            itemHolders[_loc1_].removeEventListener("mouseOver",itemMouseOverHandler);
            itemHolders[_loc1_].removeEventListener("mouseOut",itemMouseOutHandler);
            _loc1_++;
         }
         itemHolders = null;
      }
      
      private function lockMediaCallback(param1:MovieClip) : void
      {
         if(param1)
         {
            if(!_lockViews[param1.passback.index])
            {
               _lockViews[param1.passback.index] = {
                  "memberOnly":null,
                  "ocean":null,
                  "endangered":null
               };
            }
            if(param1.passback.isMemberOnly)
            {
               _lockViews[param1.passback.index].memberOnly = param1;
            }
            else if(param1.passback.isOcean)
            {
               param1.scaleX = 2;
               param1.scaleY = 2;
               _lockViews[param1.passback.index].ocean = param1;
            }
            else if(param1.passback.isEndangered)
            {
               _lockViews[param1.passback.index].endangered = param1;
            }
            _lockViewIdx = _lockViewIdx + 1;
            if(_lockViewIdx >= _numToLoad)
            {
               spinToIndex(_startingIndex == -1 ? contentItems.length / 2 : _startingIndex,true);
               if(_continueCallback != null)
               {
                  _continueCallback();
               }
            }
            param1.mediaHelper.destroy();
            delete param1.mediaHelper;
            delete param1.passback;
         }
      }
      
      public function get contentItemIndex() : int
      {
         return _contentItemIndex;
      }
      
      public function set contentItemIndex(param1:int) : void
      {
         if(param1 == _contentItemIndex)
         {
            return;
         }
         spinToIndex(param1);
      }
      
      public function get selectedContentItem() : *
      {
         return contentItems ? contentItems[_contentItemIndex] : null;
      }
      
      public function set selectedContentItem(param1:*) : void
      {
         spinToIndex(contentItems.indexOf(param1));
      }
      
      public function get hasLoaded() : Boolean
      {
         return _hasLoaded;
      }
      
      private function shouldFilter() : Boolean
      {
         var _loc1_:DisplayObject = null;
         if(itemHolders[_centerItemHolderIndex] is Sprite && DisplayObjectContainer(itemHolders[_centerItemHolderIndex]).numChildren > 0 && contentItems[0] is AvatarView)
         {
            _loc1_ = DisplayObjectContainer(itemHolders[_centerItemHolderIndex]).getChildAt(0);
            if(AvatarUtility.isExtinct(AvatarUtility.findAvDefByType(AvatarView(_loc1_).avTypeId,AvatarView(_loc1_).customAvId).availability))
            {
               return false;
            }
            if(gMainFrame.userInfo.isMember)
            {
            }
            return true;
         }
         if(!DisplayObject(contentItems[_centerItemHolderIndex]).parent is Loader)
         {
            return true;
         }
         return false;
      }
      
      public function redrawItems() : void
      {
         _myGemCount = UserCurrency.getCurrency(0);
         if(!_textFieldMode)
         {
            _priceTag.visible = false;
            _redBuyBtn.visible = false;
            _greenBuyBtn.visible = false;
         }
         setupContentItems();
         soundsEnabled = false;
         spinToAnimal(26,true);
         displayItems(true,true);
         soundsEnabled = true;
      }
      
      public function setupContentItems() : void
      {
         var _loc1_:int = 0;
         if(!showOnlyOceanAnimals)
         {
            contentItems = [];
            _loc1_ = 0;
            while(_loc1_ < fullContentItems.length)
            {
               if(AvatarUtility.getAvatarDefIsViewableWithAvId(AvatarUtility.getAvatarTypeByIndex(_loc1_),fullContentItems[_loc1_].customAvId != -1))
               {
                  contentItems.push(fullContentItems[_loc1_]);
               }
               _loc1_++;
            }
            _contentItemIndex = 0;
         }
         else
         {
            _contentItemIndex = 0;
            contentItems = oceanOnlyItems;
         }
      }
      
      public function removeAllChildren() : void
      {
         var _loc1_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:DisplayObjectContainer = null;
         if(itemHolders && contentItems)
         {
            _loc1_ = Math.min(itemHolders.length,contentItems.length);
            _loc3_ = 0;
            while(_loc3_ < _loc1_)
            {
               _loc2_ = DisplayObjectContainer(itemHolders[_loc3_]);
               while(_loc2_.numChildren > 0)
               {
                  _loc2_.removeChildAt(0);
               }
               _loc3_++;
            }
         }
      }
      
      public function clearItems() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(!_textFieldMode)
         {
            _loc2_ = int(itemHolders.length);
            _loc1_ = 0;
            while(_loc1_ < _loc2_)
            {
               if(itemsHolder.contains(itemHolders[_loc1_]))
               {
                  itemsHolder.removeChild(itemHolders[_loc1_]);
               }
               _loc1_++;
            }
            return;
         }
         throw new Error("Clearing itemHolders for textFieldMode carousels is not supported!");
      }
      
      public function pickRandomItem(param1:Boolean = false) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(contentItems.length);
         var _loc4_:int = Math.random() * _loc3_;
         if(!param1)
         {
            _randomizing = true;
            _loc2_ = _loc4_ + (Math.random() < 0.5 ? 8 : -8);
            if(_loc2_ < 0)
            {
               _loc2_ += _loc3_;
            }
            if(_loc2_ >= _loc3_)
            {
               _loc2_ -= _loc3_;
            }
            _callDone = false;
            spinToIndex(_loc2_,true);
            _callDone = true;
         }
         spinToIndex(_loc4_,param1);
      }
      
      public function spinToAnimal(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < contentItems.length)
         {
            if(contentItems[_loc3_].avTypeId == param1)
            {
               _loc4_ = true;
               break;
            }
            _loc3_++;
         }
         if(_loc4_)
         {
            spinToIndex(_loc3_,param2);
         }
         else
         {
            pickRandomItem(param2);
         }
      }
      
      private function spin() : void
      {
         if(soundsEnabled)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         startSpin();
      }
      
      public function spinToIndex(param1:int, param2:Boolean = false) : void
      {
         if(_itemCycleTimer.hasEventListener("timer") || param1 < 0 || param1 >= contentItems.length || param1 == _contentItemIndex)
         {
            return;
         }
         if(!_textFieldMode)
         {
            _priceTag.visible = false;
            _redBuyBtn.visible = false;
            _greenBuyBtn.visible = false;
         }
         if(!param2 && soundsEnabled)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         if(Math.abs(_contentItemIndex - param1) < contentItems.length / 2)
         {
            _itemCycleDown = _contentItemIndex - param1 > 0;
         }
         else
         {
            _itemCycleDown = _contentItemIndex - param1 <= 0;
         }
         if(param2)
         {
            _contentItemIndex = _targetContentItemIndex = param1;
            displayItems(true,true);
            DarkenManager.showLoadingSpiral(false);
         }
         else
         {
            _targetContentItemIndex = param1;
            startSpin();
         }
      }
      
      private function startSpin() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(_textFieldMode)
         {
            TextField(itemHolders[_centerItemHolderIndex]).setTextFormat(_centerTextFormatShadow);
            TextField(itemHolders[_centerItemHolderIndex]).defaultTextFormat = _centerTextFormatShadow;
         }
         else
         {
            _loc1_ = int(itemHolders.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               itemHolders[_loc2_].filters = [];
               _loc2_++;
            }
         }
         if(!_itemCycleDown)
         {
            setupHolders();
         }
         _itemCycleTimer.addEventListener("timer",itemCycleUpdate,false,0,true);
         _lastTimer = getTimer();
         _itemCycleTimer.start();
      }
      
      private function setupHolders(param1:Boolean = true) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(itemHolders.length);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            itemHolders[_loc2_].y = itemInfos[int(_itemCycleDown || !param1 ? _loc2_ : _loc2_ + 1)].stopY;
            _loc2_++;
         }
         if(param1)
         {
            cycleItems();
         }
      }
      
      private function cycleItems() : void
      {
         var _loc1_:int = int(contentItems.length);
         if(_itemCycleDown)
         {
            if(--_contentItemIndex == -1)
            {
               _contentItemIndex = _loc1_ - 1;
            }
         }
         else if(++_contentItemIndex == _loc1_)
         {
            _contentItemIndex = 0;
         }
         displayItems(!_autoScroll && _targetContentItemIndex == _contentItemIndex);
      }
      
      private function displayItems(param1:Boolean = true, param2:Boolean = false) : void
      {
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc13_:DisplayObjectContainer = null;
         var _loc3_:int = 0;
         var _loc12_:Object = null;
         DarkenManager.showLoadingSpiral(false);
         var _loc11_:int = Math.min(itemHolders.length,contentItems.length);
         var _loc14_:int = int(contentItems.length);
         var _loc4_:int = _contentItemIndex - int(_loc11_ / 2);
         if(_loc4_ < 0)
         {
            _loc4_ += _loc14_;
         }
         if(_textFieldMode)
         {
            _loc7_ = 0;
            _loc9_ = _loc4_;
            while(_loc7_ < _loc11_)
            {
               LocalizationManager.updateToFit(TextField(itemHolders[_loc7_]),contentItems[_loc9_],false,false,false);
               if(++_loc9_ >= _loc14_)
               {
                  _loc9_ = 0;
               }
               _loc7_++;
            }
         }
         else
         {
            _loc10_ = 0;
            while(_loc10_ < _loc14_)
            {
               if(DisplayObject(contentItems[_loc10_]).parent != null && !DisplayObject(contentItems[_loc10_]).parent is Loader)
               {
                  DisplayObject(contentItems[_loc10_]).parent.removeChild(contentItems[_loc10_]);
               }
               _loc10_++;
            }
            if(_lockViews == null || _lockViewIdx >= _numToLoad)
            {
               _loc5_ = 0;
               _loc6_ = _loc4_;
               while(_loc5_ < _loc11_)
               {
                  _loc13_ = DisplayObjectContainer(itemHolders[_loc5_]);
                  while(_loc13_.numChildren > 0)
                  {
                     _loc13_.removeChildAt(0);
                  }
                  _loc13_.addChild(contentItems[_loc6_]);
                  if(contentItems[_loc6_] is AvatarView)
                  {
                     _loc3_ = -1;
                     if(showOnlyOceanAnimals)
                     {
                        if(_loc6_ == _contentItemIndex)
                        {
                           newOceanIndex = _loc6_;
                        }
                        _loc3_ = AvatarUtility.findAvatarIndexByType(contentItems[_loc6_].avTypeId,contentItems[_loc6_].customAvId);
                     }
                     else
                     {
                        _loc3_ = AvatarUtility.findAvatarIndexByType(contentItems[_loc6_].avTypeId,contentItems[_loc6_].customAvId);
                     }
                     if(_loc3_ != -1)
                     {
                        _loc12_ = AvatarUtility.getAvatarDefByIndex(_loc3_);
                        if(!gMainFrame.userInfo.isMember)
                        {
                           if(_loc12_.isMemberOnly)
                           {
                              _lockViews[_loc3_].memberOnly.y = 40;
                              _loc13_.addChild(MovieClip(_lockViews[_loc3_].memberOnly));
                           }
                        }
                        if(!_isFromLogin && Utility.isOcean(_loc12_.enviroFlag))
                        {
                           if(_lockViews[_loc3_].ocean)
                           {
                              _lockViews[_loc3_].ocean.x = 90;
                              _lockViews[_loc3_].ocean.y = -85;
                              _loc13_.addChild(MovieClip(_lockViews[_loc3_].ocean));
                           }
                        }
                        if(AvatarUtility.isExtinct(_loc12_.availability))
                        {
                           contentItems[_loc6_].blackOut();
                           if(_lockViews[_loc3_].endangered)
                           {
                              _loc13_.addChild(MovieClip(_lockViews[_loc3_].endangered));
                           }
                        }
                        else if(AvatarUtility.isEndangered(_loc12_.availability))
                        {
                           if(_lockViews[_loc3_].endangered)
                           {
                              _loc13_.addChild(MovieClip(_lockViews[_loc3_].endangered));
                           }
                        }
                     }
                  }
                  if(++_loc6_ >= _loc14_)
                  {
                     _loc6_ = 0;
                  }
                  _loc5_++;
               }
            }
            else
            {
               DebugUtility.debugTrace("_lockViewIdx=" + _lockViewIdx + " _lockViews.length=" + _lockViews.length);
            }
         }
         if(param2 || param1 && _callDone)
         {
            if(param2 || _itemCycleDown)
            {
               doneSpinning();
            }
         }
      }
      
      private function doneSpinning() : void
      {
         var _loc5_:int = 0;
         var _loc6_:DisplayObject = null;
         var _loc3_:Point = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         _autoScroll = false;
         if(_textFieldMode)
         {
            TextField(itemHolders[_centerItemHolderIndex]).setTextFormat(_centerTextFormatLight);
            TextField(itemHolders[_centerItemHolderIndex]).defaultTextFormat = _centerTextFormatLight;
            LocalizationManager.updateToFit(TextField(itemHolders[_centerItemHolderIndex]),contentItems[_contentItemIndex],false,false,false);
         }
         else
         {
            _loc5_ = int(itemHolders.length);
            _loc6_ = itemHolders[_centerItemHolderIndex];
            _loc3_ = _loc6_.localToGlobal(new Point(_loc6_.mouseX,_loc6_.mouseY));
            if(scrollerMask.hitTestPoint(_loc3_.x,_loc3_.y))
            {
               _loc4_ = 0;
               while(_loc4_ < _loc5_)
               {
                  if(itemHolders[_loc4_].hitTestPoint(_loc3_.x,_loc3_.y,true))
                  {
                     itemHolders[_loc4_].filters = [_hoverItemHolderGlowFilter];
                     break;
                  }
                  _loc4_++;
               }
            }
            if(shouldFilter())
            {
               _loc6_.filters = [_centerItemHolderGlowFilter];
            }
            else
            {
               _loc6_.filters = [];
            }
            if(!_isFromLogin && !_btnHoldTimer.running)
            {
               _loc2_ = _loc2_ = AvatarUtility.findAvatarIndexByType(contentItems[_contentItemIndex].avTypeId,contentItems[_contentItemIndex].customAvId);
               _loc1_ = AvatarUtility.getAvatarDefByIndex(_loc2_);
               if(!isChoosingFirstNonMember)
               {
                  _priceTag.txt.text = _loc1_.cost;
                  if(_myGemCount < _loc1_.cost)
                  {
                     _priceTag.gotoAndStop("red");
                     _priceTag.txt.textColor = "0x800000";
                  }
                  else
                  {
                     _priceTag.gotoAndStop("green");
                     _priceTag.textColor = "0xFFFFFFFF";
                  }
               }
               else
               {
                  LocalizationManager.translateId(_priceTag.txt,11176);
                  _redBuyBtn.visible = false;
               }
               if(!AvatarUtility.isExtinct(_loc1_.availability))
               {
                  _greenBuyBtn.visible = true;
                  if(_myGemCount < _loc1_.cost)
                  {
                     _redBuyBtn.visible = true;
                  }
                  _priceTag.visible = true;
               }
            }
         }
         if(soundsEnabled && !_btnHoldTimer.running)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenStopSound();
         }
         if((!_randomizing || _itemCycleTimer.running) && doneSpinningCallback != null)
         {
            _randomizing = false;
            doneSpinningCallback();
         }
      }
      
      private function itemCycleUpdate(param1:TimerEvent) : void
      {
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc2_:Boolean = false;
         var _loc7_:int = int(itemHolders.length);
         var _loc5_:Boolean = false;
         var _loc6_:int = getTimer();
         var _loc4_:Number = (_loc6_ - _lastTimer) / 20;
         var _loc3_:Number = _loc4_ * spinSpeed;
         if(_itemCycleDown)
         {
            _loc9_ = 0;
            while(_loc9_ < _loc7_)
            {
               if(itemHolders[_loc9_].y + _loc3_ < itemInfos[_loc9_ + 1].stopY)
               {
                  itemHolders[_loc9_].y += _loc3_;
               }
               else
               {
                  itemHolders[_loc9_].y = itemInfos[_loc9_ + 1].stopY;
                  _loc5_ = true;
               }
               _loc9_++;
            }
         }
         else
         {
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               if(itemHolders[_loc8_].y - _loc3_ > itemInfos[_loc8_].stopY)
               {
                  itemHolders[_loc8_].y -= _loc3_;
               }
               else
               {
                  itemHolders[_loc8_].y = itemInfos[_loc8_].stopY;
                  _loc5_ = true;
               }
               _loc8_++;
            }
         }
         _lastTimer = _loc6_;
         if(_loc5_)
         {
            if(_itemCycleDown)
            {
               setupHolders();
            }
            _loc2_ = !_autoScroll && _targetContentItemIndex == _contentItemIndex;
            if(_loc2_)
            {
               _itemCycleTimer.removeEventListener("timer",itemCycleUpdate);
               _itemCycleTimer.reset();
               _randomizing = false;
            }
            if(!_itemCycleDown)
            {
               setupHolders(!_loc2_);
               if(_loc2_)
               {
                  doneSpinning();
               }
            }
         }
      }
      
      private function upBtnMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!_itemCycleTimer.running)
         {
            _loc2_ = _contentItemIndex - 1;
            if(_loc2_ == -1)
            {
               _loc2_ = contentItems.length - 1;
            }
            _btnHoldTimer.start();
            spinToIndex(_loc2_,false);
            _autoCycleDown = true;
         }
      }
      
      private function downBtnMouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:int = 0;
         if(!_itemCycleTimer.running)
         {
            _loc2_ = _contentItemIndex + 1;
            if(_loc2_ == contentItems.length)
            {
               _loc2_ = 0;
            }
            _btnHoldTimer.start();
            spinToIndex(_loc2_,false);
            _autoCycleDown = false;
         }
      }
      
      private function btnHoldTimerHandler(param1:TimerEvent) : void
      {
         _autoScroll = true;
         _itemCycleDown = _autoCycleDown;
         _btnHoldTimer.reset();
         spin();
      }
      
      private function upBtnMouseUpOutHandler(param1:MouseEvent) : void
      {
         _btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(_autoScroll)
         {
            _autoScroll = false;
            _targetContentItemIndex = _contentItemIndex - 1;
            if(_targetContentItemIndex == -1)
            {
               _targetContentItemIndex = contentItems.length - 1;
            }
         }
      }
      
      private function downBtnMouseUpOutHandler(param1:MouseEvent) : void
      {
         _btnHoldTimer.reset();
         AJAudio.stopNameGenRotationSound();
         if(_autoScroll)
         {
            _autoScroll = false;
            _targetContentItemIndex = _contentItemIndex;
         }
      }
      
      private function itemMouseDownHandler(param1:MouseEvent) : void
      {
         spinToIndex(contentItems.indexOf(_textFieldMode ? param1.currentTarget.text : param1.currentTarget.getChildAt(0)),false);
      }
      
      private function itemMouseOverHandler(param1:MouseEvent) : void
      {
         if(!_itemCycleTimer.hasEventListener("timer") && param1.currentTarget != itemHolders[_centerItemHolderIndex])
         {
            param1.currentTarget.filters = [_hoverItemHolderGlowFilter];
         }
      }
      
      private function itemMouseOutHandler(param1:MouseEvent) : void
      {
         if(!_textFieldMode && !_itemCycleTimer.hasEventListener("timer") && param1.currentTarget == itemHolders[_centerItemHolderIndex])
         {
            if(shouldFilter())
            {
               param1.currentTarget.filters = [_centerItemHolderGlowFilter];
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
