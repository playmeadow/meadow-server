package gui
{
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.corelib.audio.SBAudio;
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
      
      private static const SPIN_UPDATE_MS:int = 1;
      
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
      
      public var showOnlyOceanAnimals:Boolean;
      
      public var isChoosingFirstNonMember:Boolean;
      
      public var newOceanIndex:int;
      
      private var _soundsEnabled:Boolean;
      
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
      
      public function init(param1:Array, param2:Function = null, param3:Function = null, param4:Boolean = false, param5:int = -1) : void
      {
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc7_:DisplayObject = null;
         var _loc13_:int = 0;
         var _loc16_:int = 0;
         var _loc8_:int = 0;
         var _loc15_:MediaHelper = null;
         var _loc6_:Object = null;
         _lastTimer = getTimer();
         var _loc14_:int = int(param1.length);
         _textFieldMode = param1[0] is String;
         fullContentItems = param1;
         oceanOnlyItems = [];
         var _loc11_:Array = [];
         _startingIndex = param5;
         _soundsEnabled = !SBAudio.areSoundsMuted;
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
            contentItems = _loc11_;
         }
         _loc14_ = int(contentItems.length);
         _isFromLogin = param4;
         if(_loc14_ < 1)
         {
            throw new Error("Attempted to init GuiCarousel with content array length less than one!");
         }
         _loc12_ = 0;
         while(_loc12_ < _loc14_)
         {
            if(!(param1[_loc12_] is String) && !(param1[_loc12_] is DisplayObject))
            {
               throw new Error("Attempted to init GuiCarousel with non-DisplayObject content array!");
            }
            _loc12_++;
         }
         doneSpinningCallback = param2;
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
         var _loc10_:int = 0;
         while(itemsHolder.hasOwnProperty("_item" + _loc10_))
         {
            _loc7_ = itemsHolder["_item" + _loc10_];
            itemInfos[_loc10_] = new ItemInfo();
            itemInfos[_loc10_].stopY = _loc7_.y;
            if(!_textFieldMode)
            {
               _loc7_.visible = false;
            }
            _loc10_++;
         }
         if(_loc10_ == 0)
         {
            throw new Error("GuiCarousel did not have any _item# instances inside it!");
         }
         itemInfos[_loc10_] = new ItemInfo();
         itemInfos[_loc10_].stopY = itemInfos.length > 2 ? itemInfos[_loc10_ - 1].stopY + (itemInfos[_loc10_ - 1].stopY - itemInfos[_loc10_ - 2].stopY) : itemInfos[_loc10_ - 1].stopY + itemsHolder["_item1"].height;
         if(_textFieldMode)
         {
            itemHolders = new Vector.<DisplayObject>(_loc10_);
            _loc13_ = 0;
            while(_loc13_ < _loc10_)
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
            itemHolders = new Vector.<DisplayObject>(_loc10_);
            _loc16_ = 0;
            while(_loc16_ < _loc10_)
            {
               itemHolders[_loc16_] = new Sprite();
               itemHolders[_loc16_].y = itemInfos[_loc16_].stopY;
               itemHolders[_loc16_].addEventListener("mouseDown",itemMouseDownHandler,false,0,true);
               itemHolders[_loc16_].addEventListener("mouseOver",itemMouseOverHandler,false,0,true);
               itemHolders[_loc16_].addEventListener("mouseOut",itemMouseOutHandler,false,0,true);
               itemsHolder.addChild(itemHolders[_loc16_]);
               _loc16_++;
            }
         }
         _hoverItemHolderGlowFilter = new GlowFilter(16777215,1,16,16,3);
         _centerItemHolderIndex = _loc10_ / 2;
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
         _itemCycleTimer = new Timer(1);
         _autoScroll = false;
         if(_textFieldMode)
         {
            spinSpeed = 4;
         }
         else
         {
            spinSpeed = 8;
         }
         _callDone = true;
         _continueCallback = param3;
         _lockViewIdx = 0;
         _numToLoad = 0;
         if(_loc14_ > 0 && contentItems[0] is AvatarView)
         {
            _loc8_ = AvatarUtility.numAvatarDefs;
            _lockViews = [];
            _mediaHolder = [];
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _loc6_ = AvatarUtility.getAvatarDefByIndex(_loc9_);
               if(_loc6_)
               {
                  if(_loc6_.isMemberOnly)
                  {
                     _numToLoad = _numToLoad + 1;
                     _loc15_ = new MediaHelper();
                     _loc15_.init(360,lockMediaCallback,{
                        "index":_loc9_,
                        "isMemberOnly":true
                     });
                     _mediaHolder.push(_loc15_);
                  }
                  if(Utility.isOcean(_loc6_.enviroFlag))
                  {
                     _numToLoad = _numToLoad + 1;
                     _loc15_ = new MediaHelper();
                     _loc15_.init(1165,lockMediaCallback,{
                        "index":_loc9_,
                        "isOcean":true
                     });
                     _mediaHolder.push(_loc15_);
                  }
                  if(_loc6_.availability >= 2)
                  {
                     _numToLoad = _numToLoad + 1;
                     _loc15_ = new MediaHelper();
                     _loc15_.init(1387,lockMediaCallback,{
                        "index":_loc9_,
                        "isEndangered":true
                     });
                     _mediaHolder.push(_loc15_);
                  }
               }
               _loc9_++;
            }
         }
         else
         {
            if(param5 == -1)
            {
               pickRandomItem(true);
            }
            else
            {
               spinToIndex(param5,true);
            }
            if(_continueCallback != null)
            {
               _continueCallback();
            }
         }
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
      
      public function set soundsEnabled(param1:Boolean) : void
      {
         _soundsEnabled = param1;
      }
      
      public function get soundsEnabled() : Boolean
      {
         return _soundsEnabled;
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
               if(_startingIndex == -1)
               {
                  pickRandomItem(true);
               }
               else
               {
                  spinToIndex(_startingIndex,true);
               }
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
         _soundsEnabled = false;
         spinToAnimal(26,true);
         displayItems(true,true);
         _soundsEnabled = true;
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
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc1_:DisplayObjectContainer = null;
         if(itemHolders && contentItems)
         {
            _loc3_ = Math.min(itemHolders.length,contentItems.length);
            _loc2_ = 0;
            while(_loc2_ < _loc3_)
            {
               _loc1_ = DisplayObjectContainer(itemHolders[_loc2_]);
               while(_loc1_.numChildren > 0)
               {
                  _loc1_.removeChildAt(0);
               }
               _loc2_++;
            }
         }
      }
      
      public function clearItems() : void
      {
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         if(!_textFieldMode)
         {
            _loc1_ = int(itemHolders.length);
            _loc2_ = 0;
            while(_loc2_ < _loc1_)
            {
               if(itemsHolder.contains(itemHolders[_loc2_]))
               {
                  itemsHolder.removeChild(itemHolders[_loc2_]);
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
         var _loc2_:int = int(contentItems.length);
         var _loc3_:int = Math.random() * _loc2_;
         if(!param1)
         {
            _randomizing = true;
            _loc4_ = _loc3_ + (Math.random() < 0.5 ? 8 : -8);
            if(_loc4_ < 0)
            {
               _loc4_ += _loc2_;
            }
            if(_loc4_ >= _loc2_)
            {
               _loc4_ -= _loc2_;
            }
            _callDone = false;
            spinToIndex(_loc4_,true);
            _callDone = true;
         }
         spinToIndex(_loc3_,param1);
      }
      
      public function spinToAnimal(param1:int, param2:Boolean = false) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Boolean = false;
         _loc4_ = 0;
         while(_loc4_ < contentItems.length)
         {
            if(contentItems[_loc4_].avTypeId == param1)
            {
               _loc3_ = true;
               break;
            }
            _loc4_++;
         }
         if(_loc3_)
         {
            spinToIndex(_loc4_,param2);
         }
         else
         {
            pickRandomItem(param2);
         }
      }
      
      private function spin() : void
      {
         if(_soundsEnabled && hasLoaded)
         {
            AJAudio.stopNameGenRotationSound();
            AJAudio.playNameGenRotationSound(-1);
         }
         startSpin();
      }
      
      public function spinToIndex(param1:int, param2:Boolean = false) : void
      {
         if(_itemCycleTimer.hasEventListener("timer") || param1 < 0 || param1 >= contentItems.length)
         {
            return;
         }
         if(!_textFieldMode)
         {
            _priceTag.visible = false;
            _redBuyBtn.visible = false;
            _greenBuyBtn.visible = false;
         }
         if(!param2 && _soundsEnabled && hasLoaded)
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
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         if(_textFieldMode)
         {
            TextField(itemHolders[_centerItemHolderIndex]).setTextFormat(_centerTextFormatShadow);
            TextField(itemHolders[_centerItemHolderIndex]).defaultTextFormat = _centerTextFormatShadow;
         }
         else
         {
            _loc2_ = int(itemHolders.length);
            _loc1_ = 0;
            while(_loc1_ < _loc2_)
            {
               itemHolders[_loc1_].filters = [];
               _loc1_++;
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
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc14_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:DisplayObjectContainer = null;
         var _loc8_:int = 0;
         var _loc3_:Object = null;
         DarkenManager.showLoadingSpiral(false);
         var _loc9_:int = Math.min(itemHolders.length,contentItems.length);
         var _loc13_:int = int(contentItems.length);
         var _loc4_:int = _contentItemIndex - int(_loc9_ / 2);
         if(_loc4_ < 0)
         {
            _loc4_ += _loc13_;
         }
         if(_textFieldMode)
         {
            _loc11_ = 0;
            _loc12_ = _loc4_;
            while(_loc11_ < _loc9_)
            {
               LocalizationManager.updateToFit(TextField(itemHolders[_loc11_]),contentItems[_loc12_],false,false,false);
               if(++_loc12_ >= _loc13_)
               {
                  _loc12_ = 0;
               }
               _loc11_++;
            }
         }
         else
         {
            _loc14_ = 0;
            while(_loc14_ < _loc13_)
            {
               if(DisplayObject(contentItems[_loc14_]).parent != null && !DisplayObject(contentItems[_loc14_]).parent is Loader)
               {
                  DisplayObject(contentItems[_loc14_]).parent.removeChild(contentItems[_loc14_]);
               }
               _loc14_++;
            }
            if(_lockViews == null || _lockViewIdx >= _numToLoad)
            {
               _loc7_ = 0;
               _loc5_ = _loc4_;
               while(_loc7_ < _loc9_)
               {
                  _loc6_ = DisplayObjectContainer(itemHolders[_loc7_]);
                  while(_loc6_.numChildren > 0)
                  {
                     _loc6_.removeChildAt(0);
                  }
                  _loc6_.addChild(contentItems[_loc5_]);
                  if(contentItems[_loc5_] is AvatarView)
                  {
                     _loc8_ = -1;
                     if(showOnlyOceanAnimals)
                     {
                        if(_loc5_ == _contentItemIndex)
                        {
                           newOceanIndex = _loc5_;
                        }
                        _loc8_ = AvatarUtility.findAvatarIndexByType(contentItems[_loc5_].avTypeId,contentItems[_loc5_].customAvId);
                     }
                     else
                     {
                        _loc8_ = AvatarUtility.findAvatarIndexByType(contentItems[_loc5_].avTypeId,contentItems[_loc5_].customAvId);
                     }
                     if(_loc8_ != -1)
                     {
                        _loc3_ = AvatarUtility.getAvatarDefByIndex(_loc8_);
                        if(!gMainFrame.userInfo.isMember)
                        {
                           if(_loc3_.isMemberOnly)
                           {
                              _lockViews[_loc8_].memberOnly.y = 40;
                              _loc6_.addChild(MovieClip(_lockViews[_loc8_].memberOnly));
                           }
                        }
                        if(!_isFromLogin && Utility.isOcean(_loc3_.enviroFlag))
                        {
                           if(_lockViews[_loc8_].ocean)
                           {
                              _lockViews[_loc8_].ocean.x = 90;
                              _lockViews[_loc8_].ocean.y = -85;
                              _loc6_.addChild(MovieClip(_lockViews[_loc8_].ocean));
                           }
                        }
                        if(AvatarUtility.isExtinct(_loc3_.availability))
                        {
                           contentItems[_loc5_].blackOut();
                           if(_lockViews[_loc8_].endangered)
                           {
                              _loc6_.addChild(MovieClip(_lockViews[_loc8_].endangered));
                           }
                        }
                        else if(AvatarUtility.isEndangered(_loc3_.availability))
                        {
                           if(_lockViews[_loc8_].endangered)
                           {
                              _loc6_.addChild(MovieClip(_lockViews[_loc8_].endangered));
                           }
                        }
                     }
                  }
                  if(++_loc5_ >= _loc13_)
                  {
                     _loc5_ = 0;
                  }
                  _loc7_++;
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
         var _loc6_:int = 0;
         var _loc3_:DisplayObject = null;
         var _loc2_:Point = null;
         var _loc1_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:Object = null;
         _autoScroll = false;
         if(_textFieldMode)
         {
            TextField(itemHolders[_centerItemHolderIndex]).setTextFormat(_centerTextFormatLight);
            TextField(itemHolders[_centerItemHolderIndex]).defaultTextFormat = _centerTextFormatLight;
            LocalizationManager.updateToFit(TextField(itemHolders[_centerItemHolderIndex]),contentItems[_contentItemIndex],false,false,false);
         }
         else
         {
            _loc6_ = int(itemHolders.length);
            _loc3_ = itemHolders[_centerItemHolderIndex];
            _loc2_ = _loc3_.localToGlobal(new Point(_loc3_.mouseX,_loc3_.mouseY));
            if(scrollerMask.hitTestPoint(_loc2_.x,_loc2_.y))
            {
               _loc1_ = 0;
               while(_loc1_ < _loc6_)
               {
                  if(itemHolders[_loc1_].hitTestPoint(_loc2_.x,_loc2_.y,true))
                  {
                     itemHolders[_loc1_].filters = [_hoverItemHolderGlowFilter];
                     break;
                  }
                  _loc1_++;
               }
            }
            if(shouldFilter())
            {
               _loc3_.filters = [_centerItemHolderGlowFilter];
            }
            else
            {
               _loc3_.filters = [];
            }
            if(!_isFromLogin && !_btnHoldTimer.running)
            {
               _loc5_ = _loc5_ = AvatarUtility.findAvatarIndexByType(contentItems[_contentItemIndex].avTypeId,contentItems[_contentItemIndex].customAvId);
               _loc4_ = AvatarUtility.getAvatarDefByIndex(_loc5_);
               if(!isChoosingFirstNonMember)
               {
                  _priceTag.txt.text = _loc4_.cost;
                  if(_myGemCount < _loc4_.cost)
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
               if(!AvatarUtility.isExtinct(_loc4_.availability))
               {
                  _greenBuyBtn.visible = true;
                  if(_myGemCount < _loc4_.cost)
                  {
                     _redBuyBtn.visible = true;
                  }
                  _priceTag.visible = true;
               }
            }
         }
         if(_soundsEnabled && !_btnHoldTimer.running)
         {
            if(hasLoaded)
            {
               AJAudio.stopNameGenRotationSound();
               AJAudio.playNameGenStopSound();
            }
            else
            {
               _hasLoaded = true;
            }
         }
         if(!_randomizing || _itemCycleTimer.running)
         {
            _randomizing = false;
            if(doneSpinningCallback != null)
            {
               doneSpinningCallback();
            }
         }
      }
      
      private function itemCycleUpdate(param1:TimerEvent) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:int = int(itemHolders.length);
         var _loc3_:Boolean = false;
         var _loc5_:int = getTimer();
         var _loc6_:Number = (_loc5_ - _lastTimer) / 20;
         var _loc7_:Number = _loc6_ * spinSpeed;
         if(_itemCycleDown)
         {
            _loc2_ = 0;
            while(_loc2_ < _loc9_)
            {
               if(itemHolders[_loc2_].y + _loc7_ < itemInfos[_loc2_ + 1].stopY)
               {
                  itemHolders[_loc2_].y += _loc7_;
               }
               else
               {
                  itemHolders[_loc2_].y = itemInfos[_loc2_ + 1].stopY;
                  _loc3_ = true;
               }
               _loc2_++;
            }
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < _loc9_)
            {
               if(itemHolders[_loc4_].y - _loc7_ > itemInfos[_loc4_].stopY)
               {
                  itemHolders[_loc4_].y -= _loc7_;
               }
               else
               {
                  itemHolders[_loc4_].y = itemInfos[_loc4_].stopY;
                  _loc3_ = true;
               }
               _loc4_++;
            }
         }
         _lastTimer = _loc5_;
         if(_loc3_)
         {
            if(_itemCycleDown)
            {
               setupHolders();
            }
            _loc8_ = !_autoScroll && _targetContentItemIndex == _contentItemIndex;
            if(_loc8_)
            {
               _itemCycleTimer.removeEventListener("timer",itemCycleUpdate);
               _itemCycleTimer.reset();
               _randomizing = false;
            }
            if(!_itemCycleDown)
            {
               setupHolders(!_loc8_);
               if(_loc8_)
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
