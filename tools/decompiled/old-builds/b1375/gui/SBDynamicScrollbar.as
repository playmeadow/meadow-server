package gui
{
   import com.greensock.BlitMask;
   import com.greensock.TimelineLite;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.greensock.easing.Quad;
   import com.greensock.easing.SlowMo;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class SBDynamicScrollbar
   {
      
      private const EASE_TIME:Number = 0.5;
      
      private const EASE_TIME_HANDLE:Number = 0.001;
      
      private const MIN_HANDLE_HEIGHT:int = 30;
      
      private var _timeLine:TimelineLite;
      
      private var _scrollContentMask:BlitMask;
      
      private var _maskTween:TweenMax;
      
      private var _windowAndScrollbarGenerator:WindowAndScrollbarGenerator;
      
      private var _xWinVis:Number;
      
      private var _yWinVis:Number;
      
      private var _xOffset:Number;
      
      private var _yOffset:Number;
      
      private var _xStart:Number;
      
      private var _yStart:Number;
      
      private var _tallestItem:Number = 0;
      
      private var _widestItem:Number = 0;
      
      private var _snapHeight:Number;
      
      private var _snapWidth:Number;
      
      private var _gapBetweenBarAndCont:Number;
      
      private var _viewableWidth:Number;
      
      private var _viewableHeight:Number;
      
      private var _numPerRow:Number;
      
      private var _scrollContentHeight:Number;
      
      private var _scrollContentWidth:Number;
      
      private var _scrollHeight:Number;
      
      private var _scrollWidth:Number;
      
      private var _handleMovementPercentage:Number;
      
      private var _bounds:Rectangle;
      
      private var _adjTrackHeight:Number;
      
      private var _adjTrackWidth:Number;
      
      private var _wheelScrollPercent:Number;
      
      private var _wheelScrollChange:Number;
      
      private var _currContentY:Number;
      
      private var _currContentX:Number;
      
      private var _snapToTop:Boolean;
      
      private var _hasCustomStart:Boolean;
      
      private var _minimumNumWindows:int;
      
      private var _maximumNumWindows:int;
      
      private var _searchString:String;
      
      private var _currScrollAmount:Number;
      
      private var _tweenPositions:Vector.<Point>;
      
      private var _assets:Vector.<MovieClip>;
      
      private var _removedItemsForSearch:Array;
      
      private var _track:MovieClip;
      
      private var _scrollHandle:MovieClip;
      
      private var _topBtn:MovieClip;
      
      private var _bottomBtn:MovieClip;
      
      private var _scrollContent:MovieClip;
      
      private var _numRowsInView:Number;
      
      private var _fullScreenScrollChange:Number;
      
      private var _hideScrollbar:Boolean;
      
      private var _hideScrollbarWhenNotNeeded:Boolean;
      
      private var _isHorizontal:Boolean;
      
      private var _isDraggingScrollHandle:Boolean;
      
      public function SBDynamicScrollbar(param1:MovieClip, param2:Number, param3:Number, param4:int, param5:Number, param6:Number, param7:Number, param8:Number, param9:Number, param10:Number, param11:Number, param12:int = 0, param13:Boolean = true, param14:Number = 0, param15:Number = -1, param16:Boolean = false, param17:Boolean = false, param18:Boolean = false)
      {
         super();
         if(!param1.parent is WindowAndScrollbarGenerator)
         {
            throw new Error("Parent must be WindowAndScrollbarGenerator");
         }
         _windowAndScrollbarGenerator = param1.parent as WindowAndScrollbarGenerator;
         _xWinVis = param5;
         _yWinVis = param6;
         _minimumNumWindows = param4;
         _maximumNumWindows = param12;
         _xOffset = param7;
         _yOffset = param8;
         _xStart = param9;
         _yStart = param10;
         _scrollContent = param1;
         _snapToTop = param13;
         _hideScrollbar = param16;
         _hideScrollbarWhenNotNeeded = param17;
         _isHorizontal = param18;
         setupCommonItems(GETDEFINITIONBYNAME("scrollbar2"),param15,param11,param2,param3,param14,30,30);
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         if(_timeLine)
         {
            _timeLine.kill();
            _timeLine = null;
         }
         if(_scrollContentMask)
         {
            _scrollContentMask.dispose();
            _scrollContentMask = null;
         }
         if(_maskTween)
         {
            _maskTween.kill();
            _maskTween = null;
         }
         _scrollContent.parent.removeChild(_track);
         _scrollContent.parent.removeChild(_topBtn);
         _scrollContent.parent.removeChild(_bottomBtn);
         _scrollContent.parent.removeChild(_scrollHandle);
         _topBtn.removeEventListener("mouseDown",onBtnClick);
         _bottomBtn.removeEventListener("mouseDown",onBtnClick);
         _scrollHandle.removeEventListener("mouseDown",onMouseDownHandler);
         _track.removeEventListener("mouseDown",onTrackDown);
         _scrollContent.parent.removeEventListener("mouseWheel",onMouseWheelHandler);
         _scrollContent.parent.removeEventListener("mouseUp",onMouseUpHandler);
         var _loc1_:int = _scrollContent.numChildren;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _scrollContent.removeChildAt(0);
            _loc2_++;
         }
         _scrollContent = null;
      }
      
      public function insert(param1:MovieClip, param2:Boolean, param3:Boolean = false) : void
      {
         var _loc4_:Boolean = false;
         doInsert(param1,true,false,param3);
         if(!param2)
         {
            _loc4_ = param2;
            if(isNaN(_handleMovementPercentage))
            {
               _loc4_ = true;
            }
            else if(_snapToTop)
            {
               if(_handleMovementPercentage == 0)
               {
                  _loc4_ = true;
               }
            }
            else if(_handleMovementPercentage == 1)
            {
               _loc4_ = true;
            }
         }
         updateItemSizesAndMove(_loc4_);
      }
      
      public function insertMany(param1:Array, param2:Boolean, param3:Boolean = false, param4:Boolean = false) : void
      {
         var _loc7_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:int = int(param1.length);
         if(_loc6_ > 0)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               if(param1[_loc7_])
               {
                  doInsert(param1[_loc7_],_loc7_ + 1 == _loc6_,false,param3);
               }
               _loc7_++;
            }
            if(!param2)
            {
               _loc5_ = param2;
               if(isNaN(_handleMovementPercentage))
               {
                  _loc5_ = true;
               }
               else if(_snapToTop)
               {
                  if(_handleMovementPercentage == 0)
                  {
                     _loc5_ = true;
                  }
               }
               else if(_handleMovementPercentage == 1)
               {
                  _loc5_ = true;
               }
            }
            updateItemSizesAndMove(_loc5_);
         }
      }
      
      public function deleteTweenItem(param1:int, param2:Boolean = false, param3:Boolean = false) : Boolean
      {
         var _loc11_:int = 0;
         var _loc6_:Array = null;
         var _loc10_:int = 0;
         var _loc7_:Boolean = param3 || _minimumNumWindows < _assets.length;
         var _loc9_:MovieClip = _assets.splice(param1,1)[0];
         var _loc8_:int = 0;
         if(_loc7_)
         {
            if(_isHorizontal)
            {
               if(_loc9_.hasOwnProperty("sizeCont") && _loc9_.sizeCont != null)
               {
                  _loc8_ = int(_loc9_.sizeCont.width);
               }
               else
               {
                  _loc8_ = _loc9_.width;
               }
               _loc8_ += _xOffset;
            }
            else if(_numPerRow == 1 || (_assets.length + 1) % _numPerRow == 1)
            {
               if(_loc9_.hasOwnProperty("sizeCont") && _loc9_.sizeCont != null)
               {
                  _loc8_ = int(_loc9_.sizeCont.height);
               }
               else
               {
                  _loc8_ = _loc9_.height;
               }
               _loc8_ += _yOffset;
            }
         }
         var _loc5_:Vector.<Point> = _tweenPositions.concat();
         var _loc4_:int = _loc5_.length - 1;
         _loc11_ = param1;
         while(_loc11_ < _loc4_)
         {
            if(_assets[_loc11_])
            {
               if(!param3)
               {
                  _assets[_loc11_].index = _loc11_;
               }
               _assets[_loc11_].visibilityIndex = _loc11_;
               _tweenPositions[_loc11_ + 1] = _loc5_[_loc11_];
            }
            _loc11_++;
         }
         _tweenPositions.splice(param1,1);
         _timeLine.remove(_loc9_);
         if(!_loc7_ && !param3)
         {
            _assets.push(_loc9_);
            _timeLine.add(TweenMax.to(_loc9_,0.5,{"ease":Quad.easeOut}),0);
            _tweenPositions.push(_loc5_[_loc5_.length - 1]);
         }
         if(!param3)
         {
            _loc6_ = _timeLine.getChildren(false,true,false);
            _loc10_ = int(_loc6_.length);
            _loc11_ = 0;
            while(_loc11_ < _loc10_)
            {
               TweenMax(_loc6_[_loc11_]).invalidate();
               TweenMax(_loc6_[_loc11_]).updateTo({
                  "x":_tweenPositions[_loc11_].x,
                  "y":_tweenPositions[_loc11_].y
               });
               _loc11_++;
            }
         }
         if(_loc7_)
         {
            if(_isHorizontal)
            {
               _scrollContentWidth -= _loc8_;
            }
            else
            {
               _scrollContentHeight -= _loc8_;
            }
            if(!param3)
            {
               if(param2)
               {
                  _scrollContent.removeChild(_loc9_);
               }
               else
               {
                  TweenLite.to(_loc9_,0.5,{
                     "alpha":0,
                     "scaleX":0,
                     "scaleY":0,
                     "x":"+=" + _loc9_.width * 0.5,
                     "ease":SlowMo.ease,
                     "onComplete":onTweenDeleted,
                     "onCompleteParams":[_loc9_]
                  });
               }
               updateItemSizesAndMove(false,true);
            }
            else
            {
               _loc9_.visible = false;
               if(_loc9_ && _loc9_.hasOwnProperty("removeLoadedItem"))
               {
                  _loc9_.removeLoadedItem();
               }
            }
         }
         else if(_loc9_ && _loc9_.hasOwnProperty("removeLoadedItem"))
         {
            _loc9_.removeLoadedItem();
         }
         if(!param3)
         {
            startTimelineTween();
            updateItemSizesAndMove(false,true);
         }
         return _loc7_;
      }
      
      public function handleSearchInput(param1:String) : void
      {
         var _loc2_:Boolean = false;
         var _loc7_:int = 0;
         var _loc5_:Boolean = false;
         var _loc3_:String = null;
         var _loc11_:* = undefined;
         var _loc12_:String = null;
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:Array = null;
         var _loc14_:int = 0;
         if(_searchString != "")
         {
            _loc7_ = 0;
            while(_loc7_ < param1.length)
            {
               if(_loc7_ >= _searchString.length)
               {
                  break;
               }
               if(param1.charAt(_loc7_) != _searchString.charAt(_loc7_))
               {
                  _loc2_ = true;
                  break;
               }
               _loc7_++;
            }
         }
         if(param1.length == 1 || _loc2_)
         {
            _currContentY = 0;
            _currContentX = 0;
            if(_searchString.length > 0)
            {
               clearScrollLists();
               _windowAndScrollbarGenerator.reloadInitialSet(handleSearchInput,param1);
               return;
            }
         }
         param1 = param1.toLowerCase();
         var _loc13_:int = param1.length - _searchString.length;
         if(_searchString != "")
         {
            if(_loc13_ == 0)
            {
               if(param1 == _searchString)
               {
                  return;
               }
               _loc5_ = true;
            }
            else if(Math.abs(_loc13_) == 1)
            {
               if(_loc13_ == 1)
               {
                  _loc5_ = param1.substr(0,param1.length - 1) != _searchString;
               }
               else
               {
                  _loc5_ = _searchString.substr(0,_searchString.length - 1) != param1;
               }
            }
            else
            {
               _loc5_ = true;
            }
            if(_loc5_)
            {
               _loc13_ = 0 - _searchString.length;
            }
         }
         var _loc8_:int = 0;
         var _loc10_:Array = [];
         if(_loc13_ > 0)
         {
            _loc12_ = _searchString;
            _loc4_ = _searchString.length;
            while(_loc4_ < param1.length)
            {
               _loc12_ += param1.charAt(_loc4_);
               _loc9_ = 0;
               while(_loc9_ < _assets.length)
               {
                  if(_assets[_loc9_])
                  {
                     _loc11_ = _assets[_loc9_];
                     _loc3_ = _loc11_.itemName;
                     if(_loc3_ == "" || !_loc11_.hasBeenHidden && _loc3_.toLowerCase().indexOf(_loc12_) == -1 && _loc11_.currItem.sortIdString.indexOf(_loc12_) == -1)
                     {
                        if(_loc10_[_loc8_] == null)
                        {
                           _loc10_[_loc8_] = {
                              "currItem":_loc11_,
                              "isRemoved":deleteTweenItem(_loc9_,true,true)
                           };
                        }
                        _loc9_--;
                     }
                  }
                  _loc8_++;
                  _loc9_++;
               }
               _removedItemsForSearch.push(_loc10_);
               _loc10_ = [];
               _loc8_ = 0;
               _loc4_++;
            }
            _loc6_ = _timeLine.getChildren(false,true,false);
            _loc14_ = int(_loc6_.length);
            _loc9_ = 0;
            while(_loc9_ < _loc14_)
            {
               TweenMax(_loc6_[_loc9_]).invalidate();
               TweenMax(_loc6_[_loc9_]).updateTo({
                  "x":_tweenPositions[_loc9_].x,
                  "y":_tweenPositions[_loc9_].y
               });
               _loc9_++;
            }
            updateLoadItems();
         }
         else if(_loc13_ < 0)
         {
            _loc4_ = 0;
            while(_loc4_ > _loc13_)
            {
               insertFromSearch();
               _loc4_--;
            }
            if(_loc5_)
            {
               _searchString = "";
               handleSearchInput(param1);
               return;
            }
         }
         startTimelineTween();
         _searchString = param1;
         if(param1 == "")
         {
            clearScrollLists();
            _windowAndScrollbarGenerator.reloadInitialSet(null);
            return;
         }
         if(_loc13_ > 0)
         {
            if(_assets.length < _windowAndScrollbarGenerator.numWindowsPerScreen)
            {
               _windowAndScrollbarGenerator.loadMoreWithSpecificName(_loc12_);
            }
         }
         updateItemSizesAndMove(false);
      }
      
      public function updateItem(param1:int, param2:*) : void
      {
         if(_assets[param1])
         {
            _assets[param1].updateWithInput(param2);
         }
      }
      
      public function findItemAndUpdate(param1:*) : void
      {
         var _loc3_:* = undefined;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _assets.length)
         {
            _loc3_ = _assets[_loc2_];
            if(_loc3_ && "currItem" in _loc3_)
            {
               if(_loc3_.currItem == param1)
               {
                  _loc3_.updateWithInput(param1);
                  break;
               }
            }
            _loc2_++;
         }
      }
      
      public function findOpenAndUpdate(param1:*) : Boolean
      {
         var _loc3_:* = undefined;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _assets.length)
         {
            _loc3_ = _assets[_loc2_];
            if(_loc3_)
            {
               if("isUsable" in _loc3_ && _loc3_.isUsable)
               {
                  _loc3_.updateWithInput(param1);
                  return true;
               }
            }
            _loc2_++;
         }
         return false;
      }
      
      public function clearScrollLists() : void
      {
         _timeLine = new TimelineLite();
         _timeLine.paused(true);
         _tweenPositions = new Vector.<Point>();
         _assets = new Vector.<MovieClip>();
         _removedItemsForSearch = [];
         while(_scrollContent.numChildren > 0)
         {
            _scrollContent.removeChildAt(0);
         }
         _scrollContentHeight = 0;
         _scrollContentWidth = 0;
         _handleMovementPercentage = 0;
         _searchString = "";
         _currContentY = 0;
         _currContentX = 0;
      }
      
      public function get scrollYValue() : Number
      {
         if(_scrollContentHeight <= _scrollContentMask.height)
         {
            _currContentY = 0;
         }
         return _currContentY;
      }
      
      public function get scrollYPercentage() : Number
      {
         if(_scrollContentHeight <= _scrollContentMask.height)
         {
            return _currContentY = 0;
         }
         return _currContentY / _scrollHeight;
      }
      
      public function get scrollXValue() : Number
      {
         if(_scrollContentWidth <= _scrollContentMask.width)
         {
            _currContentX = 0;
         }
         return _currContentX;
      }
      
      public function get scrollXPercentage() : Number
      {
         if(_scrollContentWidth <= _scrollContentMask.width)
         {
            return _currContentX = 0;
         }
         return _currContentX / _scrollWidth;
      }
      
      public function get getScrollContentParent() : MovieClip
      {
         return MovieClip(_scrollContent.parent);
      }
      
      public function scrollToElement(param1:int, param2:Boolean = false) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         if(_isHorizontal)
         {
            if(param1 < 0 || param1 > _scrollContentWidth / _snapWidth)
            {
               if(_windowAndScrollbarGenerator.loadNextSet(scrollToElement,param1,param2) == false)
               {
                  throw new Error("Invalid index.");
               }
               return;
            }
            _loc4_ = _scrollContentWidth - _currContentX - _viewableWidth;
            _loc3_ = Math.min(_scrollWidth,param1 * _snapWidth - _currContentX);
            if(_loc3_ > 0 && _loc3_ > _loc4_)
            {
               _loc3_ = _loc4_;
            }
            else
            {
               _loc3_ = _currContentX + _loc3_ > 0 ? _loc3_ : -_currContentX;
            }
         }
         else
         {
            if(param1 < 0 || param1 > _scrollContentHeight / _snapHeight)
            {
               if(_windowAndScrollbarGenerator.loadNextSet(scrollToElement,param1,param2) == false)
               {
                  throw new Error("Invalid index.");
               }
               return;
            }
            _loc4_ = _scrollContentHeight - _currContentY - _viewableHeight;
            _loc3_ = Math.min(_scrollHeight,param1 * _snapHeight - _currContentY);
            if(_loc3_ > 0 && _loc3_ > _loc4_)
            {
               _loc3_ = _loc4_;
            }
            else
            {
               _loc3_ = _currContentY + _loc3_ > 0 ? _loc3_ : -_currContentY;
            }
         }
         updateContentPosition(_loc3_,param2,false);
         snapToPlace();
      }
      
      public function getNumOfAssets() : int
      {
         return _assets.length;
      }
      
      public function get scrollContentHeight() : Number
      {
         return _scrollContentHeight;
      }
      
      public function get scrollContentWidth() : Number
      {
         return _scrollContentWidth;
      }
      
      public function getIsIndexInView(param1:int) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(_isHorizontal)
         {
            _loc3_ = Math.max(0,Math.floor(_currContentX / _snapWidth) - 1);
            _loc5_ = _loc3_;
            _loc4_ = _loc5_ + _numRowsInView + 2;
         }
         else
         {
            _loc2_ = Math.max(0,Math.floor(_currContentY / _snapHeight) - 1);
            _loc5_ = _loc2_ * _numPerRow;
            _loc4_ = _loc5_ + (_numRowsInView + 1) * _numPerRow + 1;
         }
         return param1 >= _loc5_ && param1 < _loc4_;
      }
      
      public function handleExternalScrollClick(param1:Boolean) : void
      {
         var _loc2_:Number = 0;
         if(param1)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function setupCommonItems(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : void
      {
         _timeLine = new TimelineLite();
         _timeLine.paused(true);
         _tweenPositions = new Vector.<Point>();
         _assets = new Vector.<MovieClip>();
         _removedItemsForSearch = [];
         if(param1.track && param1.handle)
         {
            _track = param1.track;
            _scrollHandle = param1.handle;
            _topBtn = param1.topBtn;
            _bottomBtn = param1.botBtn;
            _scrollContentMask = new BlitMask(_scrollContent,_scrollContent.x,_scrollContent.y,param4,param5,false,false,4294901760,false);
            _scrollContentMask.bitmapMode = false;
            _scrollContentHeight = 0;
            _scrollContentWidth = 0;
            _snapHeight = param7;
            _snapWidth = param8;
            _gapBetweenBarAndCont = param3;
            _viewableWidth = param4;
            _viewableHeight = param5;
            _handleMovementPercentage = 0;
            _searchString = "";
            if(param6 <= 0)
            {
               _currContentY = 0;
               _currContentX = 0;
            }
            else if(_isHorizontal)
            {
               if(param6 > _scrollWidth)
               {
                  _currContentX = _scrollWidth;
               }
               else
               {
                  _currContentX = param6;
                  _hasCustomStart = true;
               }
            }
            else if(param6 > _scrollHeight)
            {
               _currContentY = _scrollHeight;
            }
            else
            {
               _currContentY = param6;
               _hasCustomStart = true;
            }
            if(_isHorizontal)
            {
               _scrollContent.x = _scrollContentMask.x - _currContentX;
               setScrollHandleLocation(_currContentX);
            }
            else
            {
               _scrollContent.y = _scrollContentMask.y - _currContentY;
               setScrollHandleLocation(_currContentY);
            }
            setupScrollBar();
            return;
         }
         throw new Error("Error: SBDynamicScrollbar.init()- The 5th parameter must contain two symbols; \'track\' and \'handle\'.");
      }
      
      private function setupScrollBar(param1:Boolean = false) : void
      {
         if(!param1)
         {
            _scrollContent.parent.addChild(_track);
            _scrollContent.parent.addChild(_topBtn);
            _scrollContent.parent.addChild(_bottomBtn);
            _scrollContent.parent.addChild(_scrollHandle);
         }
         _track.x = Math.round(_scrollContent.x + _viewableWidth + _gapBetweenBarAndCont + _track.width * 0.5);
         _track.y = 0 + _topBtn.height;
         _track.height = _scrollContentMask.height - _topBtn.height - _bottomBtn.height - 2;
         _topBtn.x = _track.x;
         _topBtn.y = 0;
         _bottomBtn.x = _track.x;
         _bottomBtn.y = _track.y + _track.height;
         resizeHandle();
         _scrollHandle.x = _track.x;
         _scrollHandle.y = _track.y;
         if(_bounds)
         {
            _bounds.x = _track.x;
            _bounds.y = _scrollContentMask.y;
            _bounds.height = _bottomBtn.y - _scrollHandle.height + 2;
         }
         else
         {
            _bounds = new Rectangle(_track.x,_scrollContentMask.y,0,_bottomBtn.y - _scrollHandle.height + 2);
         }
         _bounds.top = _topBtn.height;
         _adjTrackHeight = _track.height - _scrollHandle.height;
         _adjTrackWidth = _track.width - _scrollHandle.width;
         if(_isHorizontal)
         {
            _wheelScrollPercent = _snapWidth / (_scrollContentWidth - _scrollContentMask.width);
            _wheelScrollChange = _wheelScrollPercent * (_scrollContentMask.x + _scrollContentMask.width - _scrollHandle.width);
         }
         else
         {
            _wheelScrollPercent = _snapHeight / (_scrollContentHeight - _scrollContentMask.height);
            _wheelScrollChange = _wheelScrollPercent * (_scrollContentMask.y + _scrollContentMask.height - _scrollHandle.height);
         }
         if(_hideScrollbar)
         {
            _track.visible = _scrollHandle.visible = _topBtn.visible = _bottomBtn.visible = false;
         }
      }
      
      private function resizeHandle() : void
      {
         var _loc1_:Number = _scrollContentMask.height / _scrollContentHeight * _scrollContentMask.height - _topBtn.height - _bottomBtn.height;
         if(_loc1_ < 30)
         {
            _loc1_ = 30;
         }
         _track.visible = _scrollHandle.visible = _topBtn.visible = _bottomBtn.visible = true;
         _scrollHandle.mid.height = _loc1_ - _scrollHandle.top.height - _scrollHandle.bot.height;
         _scrollHandle.top.y = 0;
         _scrollHandle.mid.y = _scrollHandle.top.y + _scrollHandle.top.height - 0.1;
         _scrollHandle.bot.y = _scrollHandle.mid.y + _scrollHandle.mid.height - 0.1;
         if(_scrollContentHeight - _yOffset <= _scrollContentMask.height)
         {
            _scrollHandle.visible = false;
            if(_topBtn.hasGrayState && _bottomBtn.hasGrayState)
            {
               _topBtn.activateGrayState(true);
               _bottomBtn.activateGrayState(true);
            }
            if(_scrollContent.parent.hasEventListener("mouseWheel"))
            {
               _scrollContent.parent.removeEventListener("mouseWheel",onMouseWheelHandler);
            }
            if(_hideScrollbarWhenNotNeeded)
            {
               _track.visible = _scrollHandle.visible = _topBtn.visible = _bottomBtn.visible = false;
            }
            updateLoadItems();
         }
         else
         {
            if(_topBtn.hasGrayState && _bottomBtn.hasGrayState)
            {
               _topBtn.activateGrayState(false);
               _bottomBtn.activateGrayState(false);
            }
            if(!_scrollContent.parent.hasEventListener("mouseWheel"))
            {
               _topBtn.addEventListener("mouseDown",onBtnClick,false,0,true);
               _bottomBtn.addEventListener("mouseDown",onBtnClick,false,0,true);
               _scrollHandle.addEventListener("mouseDown",onMouseDownHandler,false,0,true);
               _scrollContent.parent.addEventListener("mouseUp",onMouseUpHandler,false,0,true);
               _track.addEventListener("mouseDown",onTrackDown,false,0,true);
               _scrollContent.parent.addEventListener("mouseWheel",onMouseWheelHandler,false,0,true);
            }
         }
      }
      
      private function updateItemSizesAndMove(param1:Boolean, param2:Boolean = false) : void
      {
         if(_isHorizontal)
         {
            _numRowsInView = Math.ceil(_viewableWidth / _snapWidth);
            _fullScreenScrollChange = _snapWidth * Math.max(1,_numRowsInView - 1);
            _numPerRow = Math.round(_viewableWidth / _widestItem);
            _scrollWidth = Math.max(_viewableWidth,_scrollContentWidth) - _scrollContentMask.width;
            if(_currContentX > _scrollWidth)
            {
               _currContentX = _scrollWidth;
            }
         }
         else
         {
            _numRowsInView = Math.ceil(_viewableHeight / _snapHeight);
            _fullScreenScrollChange = _snapHeight * Math.max(1,_numRowsInView - 1);
            _numPerRow = Math.round(_viewableWidth / _widestItem);
            _scrollHeight = Math.max(_viewableHeight,_scrollContentHeight) - _scrollContentMask.height;
            if(_currContentY > _scrollHeight)
            {
               _currContentY = _scrollHeight;
            }
         }
         setupScrollBar(true);
         if(param1)
         {
            if(_snapToTop)
            {
               goToTop(param2);
            }
            else
            {
               goToBottom(param2);
            }
         }
         else
         {
            setScrollHandleLocation(_isHorizontal ? _currContentX : _currContentY);
            updateWithoutMoving(param2);
         }
         _scrollContentMask.update(null,false);
      }
      
      private function setScrollHandleLocation(param1:Number) : void
      {
         _handleMovementPercentage = Math.min(1,_isHorizontal ? param1 / _scrollWidth : param1 / _scrollHeight);
         if(isNaN(_handleMovementPercentage))
         {
            _handleMovementPercentage = 0;
         }
         if(_isHorizontal)
         {
            _scrollHandle.x = Math.max(_handleMovementPercentage * _adjTrackWidth + _topBtn.height,_track.x);
         }
         else
         {
            _scrollHandle.y = Math.max(_handleMovementPercentage * _adjTrackHeight + _topBtn.height,_track.y);
         }
      }
      
      private function loadCurrViewableObjects(param1:Number, param2:Boolean = false) : void
      {
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc10_:int = 0;
         if(_isHorizontal)
         {
            _loc5_ = Math.max(0,Math.round(param1 / _snapWidth));
            _loc9_ = Math.max(0,Math.round(param1 / _snapWidth) - 1);
            _loc8_ = Math.max(_numRowsInView,(_loc9_ / _numPerRow + 1) * _numRowsInView);
         }
         else
         {
            _loc5_ = Math.max(0,Math.round(param1 / _snapHeight));
            _loc3_ = Math.max(0,Math.round(param1 / _snapHeight) - 1);
            _loc9_ = _loc3_ * _numPerRow;
            _loc8_ = _loc9_ + _numRowsInView * _numPerRow + _numPerRow;
         }
         if(param2)
         {
            _loc8_++;
         }
         _loc7_ = int(_assets.length);
         var _loc4_:int = _loc9_;
         _loc10_ = _loc9_;
         while(_loc10_ < _loc8_)
         {
            if(_loc10_ < _loc7_)
            {
               if(_assets[_loc4_])
               {
                  _assets[_loc4_].loadCurrItem(_currContentY,_currContentX);
                  _assets[_loc4_].setStatesForVisibility(true);
               }
               else
               {
                  _loc10_--;
               }
               _loc4_++;
            }
            _loc10_++;
         }
         var _loc6_:Boolean = _handleMovementPercentage >= 0.99 || !isNaN(_currScrollAmount) && _currScrollAmount < 1;
         if(_searchString == "" && (_loc5_ != 0 && !param2 && _loc7_ != 0 && _loc7_ <= _loc8_ + _windowAndScrollbarGenerator.numWindowsPerScreen || _loc6_))
         {
            _windowAndScrollbarGenerator.loadNextSet(null);
         }
      }
      
      private function onMaskTweenComplete() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(_assets.length);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(_assets[_loc2_])
            {
               _assets[_loc2_].setStatesForVisibility(getIsIndexInView(_loc2_));
            }
            _loc2_++;
         }
      }
      
      private function updateLoadItems(param1:Boolean = false, param2:Boolean = false) : void
      {
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!param1)
         {
            loadCurrViewableObjects(_isHorizontal ? _currContentX : _currContentY,param2);
         }
         else
         {
            if(_isHorizontal)
            {
               _loc4_ = Math.ceil(_scrollWidth * _handleMovementPercentage / _snapWidth);
               _loc4_ = _snapWidth * _loc4_;
               _loc3_ = _loc4_ / _scrollWidth;
               _loc4_ = _scrollWidth * _loc3_;
            }
            else
            {
               _loc4_ = Math.ceil(_scrollHeight * _handleMovementPercentage / _snapHeight);
               _loc4_ = _snapHeight * _loc4_;
               _loc3_ = _loc4_ / _scrollHeight;
               _loc4_ = _scrollHeight * _loc3_;
            }
            loadCurrViewableObjects(_loc4_,param2);
         }
      }
      
      private function updateContentPosition(param1:Number = NaN, param2:Boolean = false, param3:Boolean = true) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         if(!isNaN(param1))
         {
            _currScrollAmount = param1;
            if(_maskTween)
            {
               _maskTween.vars.onComplete = null;
               _maskTween.totalProgress(1);
            }
            if(_isHorizontal)
            {
               _currContentX += param1;
               setScrollHandleLocation(_currContentX);
               if(param3)
               {
                  updateLoadItems();
               }
               _maskTween = new TweenMax(_scrollContent,param2 ? 0.001 : 0.5,{
                  "x":_scrollContentMask.x - _currContentX,
                  "ease":Quad.easeOut,
                  "onComplete":onMaskTweenComplete
               });
            }
            else
            {
               _currContentY += param1;
               setScrollHandleLocation(_currContentY);
               if(param3)
               {
                  updateLoadItems();
               }
               _maskTween = new TweenMax(_scrollContent,param2 ? 0.001 : 0.5,{
                  "y":_scrollContentMask.y - _currContentY,
                  "ease":Quad.easeOut,
                  "onComplete":onMaskTweenComplete
               });
            }
         }
         else
         {
            if(_isHorizontal)
            {
               _handleMovementPercentage = Math.min(1,(_scrollHandle.x - _topBtn.width) / _adjTrackWidth);
            }
            else
            {
               _handleMovementPercentage = Math.min(1,(_scrollHandle.y - _topBtn.height) / _adjTrackHeight);
            }
            if(_handleMovementPercentage < 0)
            {
               _handleMovementPercentage = 0;
            }
            if(param3)
            {
               updateLoadItems(true);
            }
            if(_maskTween)
            {
               _maskTween.vars.onComplete = null;
               _maskTween.totalProgress(1);
            }
            if(_isHorizontal)
            {
               _loc5_ = _scrollWidth * _handleMovementPercentage / _snapWidth;
               _loc5_ = _snapWidth * _loc5_;
               _loc4_ = Math.min(1,_loc5_ / _scrollWidth);
               _currContentX = _scrollWidth * _loc4_;
            }
            else
            {
               _loc5_ = _scrollHeight * _handleMovementPercentage / _snapHeight;
               _loc5_ = _snapHeight * _loc5_;
               _loc4_ = Math.min(1,_loc5_ / _scrollHeight);
               _currContentY = _scrollHeight * _loc4_;
            }
            if(_isHorizontal)
            {
               _maskTween = new TweenMax(_scrollContent,0.5,{
                  "x":_scrollContentMask.x - _scrollWidth * _handleMovementPercentage,
                  "ease":Quad.easeOut,
                  "onComplete":onMaskTweenComplete
               });
            }
            else
            {
               _maskTween = new TweenMax(_scrollContent,0.5,{
                  "y":_scrollContentMask.y - _scrollHeight * _handleMovementPercentage,
                  "ease":Quad.easeOut,
                  "onComplete":onMaskTweenComplete
               });
            }
         }
      }
      
      private function snapToPlace(param1:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         if(_isHorizontal)
         {
            _loc3_ = Math.ceil(_scrollWidth * _handleMovementPercentage / _snapWidth);
            _loc3_ = _snapWidth * _loc3_;
            _loc2_ = Math.min(1,_loc3_ / _scrollWidth);
            _currContentX = _scrollWidth * _loc2_;
            new TweenMax(_scrollContent,0.5,{
               "x":_scrollContentMask.x - _currContentX,
               "ease":Quad.easeOut
            });
            setScrollHandleLocation(_currContentX);
            _loc4_ = Math.max(_scrollHandle.x,_track.x);
            new TweenMax(_scrollHandle,0.5,{
               "x":_loc4_,
               "ease":Quad.easeOut
            });
         }
         else
         {
            _loc3_ = Math.ceil(_scrollHeight * _handleMovementPercentage / _snapHeight);
            _loc3_ = _snapHeight * _loc3_;
            _loc2_ = Math.min(1,_loc3_ / _scrollHeight);
            _currContentY = _scrollHeight * _loc2_;
            new TweenMax(_scrollContent,0.5,{
               "y":_scrollContentMask.y - _currContentY,
               "ease":Quad.easeOut
            });
            setScrollHandleLocation(_currContentY);
            _loc4_ = Math.max(_scrollHandle.y,_track.y);
            new TweenMax(_scrollHandle,0.5,{
               "y":_loc4_,
               "ease":Quad.easeOut
            });
         }
         updateLoadItems(false,param1);
      }
      
      private function goToBottom(param1:Boolean = false) : void
      {
         setScrollHandleLocation(_isHorizontal ? _scrollWidth : _scrollHeight);
         updateWithoutMoving(param1);
      }
      
      private function goToTop(param1:Boolean = false) : void
      {
         setScrollHandleLocation(0);
         updateWithoutMoving(param1);
      }
      
      private function updateWithoutMoving(param1:Boolean = false) : void
      {
         snapToPlace(param1);
      }
      
      private function onMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(_scrollHandle.height < _scrollContentHeight - 3)
         {
            _isDraggingScrollHandle = true;
            _scrollHandle.startDrag(false,_bounds);
            _scrollContent.parent.parent.addEventListener("rollOut",onStageOut,false,0,true);
            _scrollContent.stage.addEventListener("mouseMove",onMouseMoveHandler,false,0,true);
            _scrollContent.parent.stage.addEventListener("mouseUp",onMouseUpHandler,false,0,true);
            _scrollContent.parent.parent.parent.addEventListener("mouseUp",onMouseUpHandler,false,0,true);
         }
      }
      
      private function onStageOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         onMouseUpHandler(param1);
      }
      
      private function onMouseUpHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         if(_isDraggingScrollHandle)
         {
            _scrollHandle.stopDrag();
            if(_maskTween)
            {
               _maskTween.totalProgress(1);
            }
            if(_snapHeight > 0 || _snapWidth > 0)
            {
               snapToPlace();
            }
            if(_scrollContent.stage)
            {
               _scrollContent.stage.removeEventListener("mouseMove",onMouseMoveHandler);
            }
            if(_scrollContent.parent.stage)
            {
               _scrollContent.parent.stage.removeEventListener("mouseUp",onMouseUpHandler);
            }
            if(_scrollContent.parent.parent)
            {
               _scrollContent.parent.parent.removeEventListener("rollOut",onStageOut);
            }
            if(_scrollContent.parent.parent.parent)
            {
               _scrollContent.parent.parent.parent.removeEventListener("mouseUp",onMouseUpHandler);
            }
         }
         _isDraggingScrollHandle = false;
      }
      
      private function onTrackDown(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = Math.ceil(param1.localY * param1.currentTarget.scaleY);
         if(_maskTween)
         {
            _maskTween.totalProgress(1);
         }
         if(_loc3_ < _scrollHandle.y + _scrollHandle.height - _topBtn.height)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function onMouseMoveHandler(param1:MouseEvent) : void
      {
         updateContentPosition();
      }
      
      private function onMouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         if(param1.delta > 0)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function onBtnClick(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:Number = 0;
         if(_maskTween)
         {
            _maskTween.totalProgress(1);
         }
         if(param1.currentTarget.name == _topBtn.name)
         {
            _loc2_ = scrollUp();
         }
         else
         {
            _loc2_ = scrollDown();
         }
         if(_loc2_ != 0)
         {
            updateContentPosition(_loc2_);
         }
      }
      
      private function doInsert(param1:MovieClip, param2:Boolean, param3:Boolean = false, param4:Boolean = false) : void
      {
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:int = 0;
         if(_maximumNumWindows > 0 && _assets.length >= _maximumNumWindows)
         {
            deleteTweenItem(0,true,param3);
         }
         if(isNaN(_numPerRow))
         {
            _numPerRow = Math.round(_viewableWidth / (_scrollContent.parent as MovieClip).boxWidth);
         }
         var _loc11_:Number = Number(param1.hasOwnProperty("sizeCont") && param1.sizeCont != null ? param1.sizeCont.width : param1.width);
         var _loc12_:Number = Number(param1.hasOwnProperty("sizeCont") && param1.sizeCont != null ? param1.sizeCont.height : param1.height);
         if(_widestItem < _loc11_)
         {
            _widestItem = _loc11_;
            _snapWidth = Math.min(_scrollContentMask.width,_widestItem + _xOffset);
         }
         if(_tallestItem < _loc12_)
         {
            _tallestItem = _loc12_;
            _snapHeight = Math.min(_scrollContentMask.height,_tallestItem + _yOffset);
         }
         var _loc5_:Point = _assets.length > 0 ? _tweenPositions[_tweenPositions.length - 1] : null;
         var _loc8_:MovieClip = _assets.length > 0 ? _assets[_assets.length - 1] : null;
         var _loc6_:Object = _loc8_ ? (_loc8_.hasOwnProperty("sizeCont") && _loc8_.sizeCont != null ? {
            "width":_loc8_.sizeCont.width,
            "height":_loc8_.sizeCont.height
         } : {
            "width":_loc8_.width,
            "height":_loc8_.height
         }) : null;
         var _loc13_:Point = new Point(_xStart,_yStart);
         if(_isHorizontal)
         {
            _loc13_.x = _loc5_ == null ? _xStart : _loc5_.x + _loc6_.width + _xOffset;
         }
         else
         {
            _loc7_ = _tweenPositions.length % _xWinVis;
            _loc13_.x = _loc7_ == 0 ? _xStart : _loc5_.x + _loc6_.width + _xOffset;
            if(_loc7_ == 0)
            {
               _loc9_ = Math.floor(_tweenPositions.length / _xWinVis);
               _loc13_.y = _loc9_ == 0 ? _yStart : _loc5_.y + _loc6_.height + _yOffset;
               var _temp_11:* = §§findproperty(_scrollContentHeight);
               _scrollContentHeight += _loc12_ + _yOffset + (_loc9_ == 0 ? _yStart : 0);
            }
            else
            {
               _loc13_.y = _tweenPositions[_tweenPositions.length - 1].y;
            }
         }
         _scrollContentWidth += _loc11_ + _xOffset;
         _tweenPositions.push(new Point(_loc13_.x,_loc13_.y));
         if(param4)
         {
            param1.x = _xStart;
            param1.y = _yStart;
            if(!param3)
            {
               _scrollContent.addChild(param1);
               _assets.unshift(param1);
               _timeLine.add(TweenMax.to(param1,0.5,{"ease":Quad.easeOut}),0);
               if(param2)
               {
                  _timeLine.invalidate();
                  _loc10_ = 1;
                  while(_loc10_ < _assets.length)
                  {
                     TweenMax(_timeLine.getTweensOf(_assets[_loc10_],false)[0]).updateTo({
                        "x":_tweenPositions[_loc10_].x,
                        "y":_tweenPositions[_loc10_].y
                     });
                     _loc10_++;
                  }
                  _timeLine.restart();
               }
            }
         }
         else
         {
            param1.x = _loc13_.x;
            param1.y = _loc13_.y;
            if(!param3)
            {
               _scrollContent.addChild(param1);
               _assets.push(param1);
               _timeLine.add(TweenMax.to(param1,0.5,{"ease":Quad.easeOut}),0);
            }
         }
      }
      
      private function insertFromSearch() : void
      {
         var _loc7_:* = undefined;
         var _loc1_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc4_:Array = null;
         var _loc8_:* = 0;
         var _loc10_:int = 0;
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc2_:TweenMax = null;
         var _loc3_:Array = _removedItemsForSearch.pop();
         var _loc6_:Array = [];
         if(_loc3_ && _loc3_.length > 0)
         {
            _loc4_ = _timeLine.getChildren(false,true,false);
            _loc10_ = 0;
            while(_loc10_ < _loc3_.length)
            {
               if(_loc3_[_loc10_])
               {
                  _loc7_ = _loc3_[_loc10_].currItem;
                  _loc1_ = Boolean(_loc3_[_loc10_].isRemoved);
                  _loc11_ = false;
                  if(!_loc1_)
                  {
                     _loc5_ = 0;
                     while(_loc5_ < _assets.length)
                     {
                        if(_assets[_loc5_] == _loc7_)
                        {
                           _assets.splice(_loc5_,1);
                           _assets.splice(_loc10_,0,_loc7_);
                           _timeLine.remove(_loc7_);
                           _loc4_.splice(_loc5_,1);
                           _loc4_.splice(_loc10_,0,TweenMax.to(_loc7_,0.5,{
                              "alpha":1,
                              "ease":Quad.easeOut
                           }));
                           _loc8_ = _loc10_;
                           while(_loc8_ < _loc5_)
                           {
                              _assets[_loc8_].visibilityIndex = _loc8_;
                              _loc8_++;
                           }
                           _assets[_loc5_].visibilityIndex = _loc10_;
                           _loc11_ = true;
                           break;
                        }
                        _loc5_++;
                     }
                  }
                  if(!_loc11_)
                  {
                     if(_loc10_ < _tweenPositions.length - 1)
                     {
                        _tweenPositions.splice(_loc10_,0,_tweenPositions[_loc10_]);
                        _loc8_ = int(_loc10_ + 1);
                        while(_loc8_ < _tweenPositions.length - 1)
                        {
                           _tweenPositions[_loc8_] = _tweenPositions[_loc8_ + 1];
                           _assets[_loc8_].visibilityIndex = _loc8_;
                           _loc8_++;
                        }
                        _tweenPositions.pop();
                     }
                     doInsert(_loc7_,1,true);
                     _assets.splice(_loc10_,0,_loc7_);
                     _assets[_loc10_].visibilityIndex = _loc10_;
                     _assets[_assets.length - 1].visibilityIndex = _assets.length - 1;
                     _loc4_.splice(_loc10_,0,TweenMax.to(_loc7_,0.5,{
                        "alpha":1,
                        "ease":Quad.easeOut
                     }));
                  }
                  _loc7_.visible = true;
                  _loc3_[_loc10_] = null;
                  _loc6_[_loc10_] = true;
               }
               _loc10_++;
            }
            _timeLine.clear();
            _timeLine.insertMultiple(_loc4_);
            _loc9_ = int(_loc4_.length);
            _loc10_ = 0;
            while(_loc10_ < _loc9_)
            {
               _loc2_ = _loc4_[_loc10_];
               _loc2_.invalidate();
               if(_loc6_[_loc10_] && _loc2_.target.hasBeenHidden)
               {
                  _loc2_.target.updateWithInput(_loc2_.target.currItem);
               }
               _loc2_.updateTo({
                  "x":_tweenPositions[_loc10_].x,
                  "y":_tweenPositions[_loc10_].y
               });
               _loc10_++;
            }
         }
      }
      
      private function showAssetFromSearch(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Array = _timeLine.getChildren(false,true,false);
         var _loc4_:int = int(_loc2_.length);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            TweenMax(_loc2_[_loc3_]).invalidate();
            if(TweenMax(_loc2_[_loc3_]).target == param1)
            {
               TweenMax(_loc2_[_loc3_]).updateTo({"alpha":1});
            }
            _loc3_++;
         }
      }
      
      private function startTimelineTween() : void
      {
         _timeLine.invalidate();
         _timeLine.restart();
      }
      
      private function scrollUp() : Number
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         if(_isHorizontal)
         {
            _loc3_ = _currContentX;
            _loc2_ = _snapWidth;
         }
         else
         {
            _loc3_ = _currContentY;
            _loc2_ = _snapHeight;
         }
         if(_loc3_ > 0)
         {
            if(_loc3_ >= _fullScreenScrollChange)
            {
               _loc1_ = -_fullScreenScrollChange;
            }
            else
            {
               _loc4_ = _numRowsInView - 2;
               while(_loc4_ > 0)
               {
                  if(_loc3_ >= _loc2_ * _loc4_)
                  {
                     _loc1_ = -(_loc2_ * _loc4_);
                     break;
                  }
                  _loc4_--;
               }
               if(_loc1_ > -_loc3_)
               {
                  _loc1_ = -_loc3_;
               }
            }
         }
         return _loc1_;
      }
      
      private function scrollDown() : Number
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc5_:int = 0;
         var _loc1_:Number = 0;
         if(_isHorizontal)
         {
            _loc4_ = _currContentX;
            _loc2_ = _snapWidth;
            _loc3_ = _scrollContentWidth - _loc4_ - _viewableWidth;
         }
         else
         {
            _loc4_ = _currContentY;
            _loc2_ = _snapHeight;
            _loc3_ = _scrollContentHeight - _loc4_ - _viewableHeight;
         }
         if(_loc3_ > 0)
         {
            if(_loc3_ >= _fullScreenScrollChange)
            {
               _loc1_ = _fullScreenScrollChange;
            }
            else
            {
               _loc5_ = _numRowsInView - 2;
               while(_loc5_ > 0)
               {
                  if(_loc3_ >= _loc2_ * _loc5_)
                  {
                     _loc1_ = _loc2_ * _loc5_;
                     break;
                  }
                  _loc5_--;
               }
               if(_loc1_ < _loc3_)
               {
                  _loc1_ = _loc3_;
               }
            }
         }
         return _loc1_;
      }
      
      private function onTweenDeleted(param1:MovieClip) : void
      {
         if(_scrollContent && param1 && param1.parent == _scrollContent)
         {
            _scrollContent.removeChild(param1);
         }
      }
   }
}

