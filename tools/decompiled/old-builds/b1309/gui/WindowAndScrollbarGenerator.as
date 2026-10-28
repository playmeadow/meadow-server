package gui
{
   import flash.display.MovieClip;
   import gui.itemWindows.ItemWindowBase;
   
   public class WindowAndScrollbarGenerator extends MovieClip
   {
      
      public var bg:MovieClip;
      
      public var numWindowsCreated:int;
      
      public var toolTip:ToolTipPopup;
      
      private var _xWinVis:int;
      
      private var _yWinVis:int;
      
      private var _numRows:int;
      
      private var _numCols:int;
      
      private var _totalNumWin:int;
      
      private var _winWidth:int;
      
      private var _winHeight:int;
      
      private var _boxWidth:int;
      
      private var _boxHeight:int;
      
      private var _xOffset:Number;
      
      private var _yOffset:Number;
      
      private var _xStart:Number;
      
      private var _numToCreated:int;
      
      private var _fillCompletely:Boolean;
      
      private var _mediaWindows:Array;
      
      private var _singleLoadWindow:MovieClip;
      
      private var _numLoaded:int;
      
      private var _callback:Function;
      
      private var _mouseDown:Function;
      
      private var _mouseOver:Function;
      
      private var _mouseOut:Function;
      
      private var _mouseMemberOnlyDown:Function;
      
      private var _dynamicScrollbar:SBDynamicScrollbar;
      
      private var _isSideways:Boolean;
      
      private var _windowClass:Class;
      
      private var _itemList:Array;
      
      private var _iconLayerName:String;
      
      private var _customParams:Object;
      
      private var _loading:Boolean;
      
      private var _loadingQueue:Array;
      
      private var _manyLoadedWindows:Array;
      
      private var _updateScrollPosition:Boolean;
      
      private var _manyLoadingWindowIndexOffset:int;
      
      private var _maxNumWindows:int;
      
      private var _onInsertManyCallback:Function;
      
      private var _insertAtTop:Boolean;
      
      private var _numWindowsToLoad:int;
      
      public function WindowAndScrollbarGenerator()
      {
         super();
      }
      
      public function init(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:int, param8:Number, param9:Number, param10:Number, param11:Number, param12:Class, param13:Array, param14:String, param15:int = 0, param16:Object = null, param17:Object = null, param18:Function = null, param19:Boolean = true, param20:Boolean = false, param21:Boolean = true, param22:Boolean = false, param23:Boolean = false) : void
      {
         _xWinVis = param5;
         _yWinVis = param6;
         _totalNumWin = param13 ? param13.length : 0;
         _maxNumWindows = param15;
         _xOffset = param8;
         _yOffset = param9;
         _xStart = param10;
         _fillCompletely = param21;
         _callback = param18;
         _isSideways = param20;
         _windowClass = param12;
         _itemList = param13;
         _iconLayerName = param14;
         _customParams = param17;
         if(_fillCompletely)
         {
            param7 = _xWinVis * _yWinVis;
         }
         if(_totalNumWin < param7)
         {
            _totalNumWin = param7;
         }
         if(param20)
         {
            _numRows = param6;
            _numCols = Math.ceil(_totalNumWin / _yWinVis);
         }
         else
         {
            _numRows = Math.ceil(_totalNumWin / _xWinVis);
            _numCols = param5;
         }
         if(param16 != null)
         {
            _mouseDown = param16.mouseDown;
            _mouseOut = param16.mouseOut;
            _mouseOver = param16.mouseOver;
            _mouseMemberOnlyDown = param16.memberOnlyDown;
         }
         bg = new MovieClip();
         bg.graphics.beginFill(0);
         bg.graphics.drawRect(0,0,0,0);
         addChild(bg);
         _dynamicScrollbar = new SBDynamicScrollbar(bg,param1,param2,param7,param5,param6,param8,param9,param10,param11,param3,_maxNumWindows,param19,param4,-1,param22,param23,param20);
         _mediaWindows = [];
         _loadingQueue = [];
         _manyLoadedWindows = [];
         _numLoaded = 0;
         toolTip = ToolTipPopup(GETDEFINITIONBYNAME("Tooltip"));
         loadWindows(_totalNumWin,onInitialWindowsLoaded,true,true);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(_dynamicScrollbar)
         {
            _dynamicScrollbar.destroy();
            _dynamicScrollbar = null;
         }
         if(bg)
         {
            while(bg.numChildren > 0)
            {
               bg.removeChildAt(0);
            }
            if(bg.parent == this)
            {
               removeChild(bg);
            }
         }
         if(_mediaWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < _mediaWindows.length)
            {
               if(_mediaWindows[_loc1_] != null && _mediaWindows[_loc1_].hasOwnProperty("destroy"))
               {
                  _mediaWindows[_loc1_].destroy();
               }
               _loc1_++;
            }
            _mediaWindows = null;
         }
         if(toolTip)
         {
            toolTip.resetTimerAndSetVisibility();
            toolTip = null;
         }
         bg = null;
      }
      
      public function get boxHeight() : int
      {
         return _boxHeight;
      }
      
      public function get boxWidth() : int
      {
         return _boxWidth;
      }
      
      public function get mediaWindows() : Array
      {
         return _mediaWindows;
      }
      
      public function get scrollYValue() : Number
      {
         return _dynamicScrollbar.scrollYValue;
      }
      
      public function get totalNumWindows() : int
      {
         return _totalNumWin;
      }
      
      public function deleteItem(param1:int, param2:*) : void
      {
         if(_dynamicScrollbar.deleteTweenItem(param1))
         {
            _numLoaded = _numLoaded - 1;
            _totalNumWin = _totalNumWin - 1;
            _mediaWindows.splice(param1,1);
         }
         if(param2 && param2 != _itemList)
         {
            param2.splice(param1,1);
         }
         _itemList.splice(param1,1);
      }
      
      public function isIndexInView(param1:int) : Boolean
      {
         return _dynamicScrollbar.getIsIndexInView(param1);
      }
      
      public function get scrollContentHeight() : Number
      {
         if(_dynamicScrollbar)
         {
            return _dynamicScrollbar.scrollContentHeight;
         }
         return 0;
      }
      
      public function insertItem(param1:*, param2:Boolean, param3:Boolean = false) : void
      {
         _insertAtTop = param3;
         if(param1 != null)
         {
            if(_itemList)
            {
               if(param3)
               {
                  _itemList.unshift(param1);
               }
               else
               {
                  _itemList.push(param1);
               }
            }
         }
         loadWindows(1,onSingleWindowLoaded,param2);
      }
      
      public function insertMany(param1:Array, param2:Boolean, param3:Boolean = false, param4:Function = null) : void
      {
         var _loc5_:int = 0;
         _insertAtTop = param3;
         if(_itemList)
         {
            _loc5_ = 0;
            while(_loc5_ < param1.length)
            {
               if(param1[_loc5_] != null)
               {
                  _itemList.push(param1[_loc5_]);
               }
               _loc5_++;
            }
         }
         _onInsertManyCallback = param4;
         _manyLoadingWindowIndexOffset = _insertAtTop ? 0 : _dynamicScrollbar.getNumOfAssets();
         loadWindows(param1.length,onManyWindowsLoaded,param2);
      }
      
      public function updateItem(param1:int, param2:*) : void
      {
         _dynamicScrollbar.updateItem(param1,param2);
      }
      
      public function findItemAndUpdate(param1:*) : void
      {
         _dynamicScrollbar.findItemAndUpdate(param1);
      }
      
      public function findOpenWindowAndUpdate(param1:*) : void
      {
         _dynamicScrollbar.findOpenAndUpdate(param1);
      }
      
      public function callUpdateInWindow() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _mediaWindows.length)
         {
            if(_mediaWindows[_loc1_].hasOwnProperty("update"))
            {
               _mediaWindows[_loc1_].update();
            }
            _loc1_++;
         }
      }
      
      public function callUpdateInWindowWithInput(param1:Object) : void
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < _mediaWindows.length)
         {
            if(_mediaWindows[_loc2_].hasOwnProperty("update"))
            {
               _mediaWindows[_loc2_].update(param1);
            }
            _loc2_++;
         }
      }
      
      public function callUpdateOnWindowWithInput(param1:int, param2:Object) : void
      {
         if(_mediaWindows[param1] && _mediaWindows[param1].hasOwnProperty("update"))
         {
            _mediaWindows[param1].update(param2);
         }
      }
      
      public function callUpdateOnWindow(param1:int) : void
      {
         if(_mediaWindows[param1] && _mediaWindows[param1].hasOwnProperty("update"))
         {
            _mediaWindows[param1].update();
         }
      }
      
      public function handleSearchInput(param1:String) : void
      {
         _dynamicScrollbar.handleSearchInput(param1);
      }
      
      public function handleScrollBtnClick(param1:Boolean) : void
      {
         _dynamicScrollbar.handleExternalScrollClick(param1);
      }
      
      public function scrollToIndex(param1:int, param2:Boolean) : void
      {
         _dynamicScrollbar.scrollToElement(param1,param2);
      }
      
      private function loadWindows(param1:int, param2:Function, param3:Boolean, param4:Boolean = false) : void
      {
         var _loc5_:int = 0;
         if(!_loading)
         {
            if(param1 > 0)
            {
               _loading = true;
               if(!param4)
               {
                  _totalNumWin += param1;
               }
               _updateScrollPosition = param3;
               _numWindowsToLoad = _insertAtTop ? param1 : _totalNumWin;
               if(_insertAtTop)
               {
                  _numLoaded = 0;
               }
               _loc5_ = int(_insertAtTop ? 0 : _numLoaded);
               while(_loc5_ < _numWindowsToLoad)
               {
                  if(_windowClass == ItemWindowBase)
                  {
                     new _windowClass(_customParams.itemClassName,param2,_itemList != null && _itemList.length > _loc5_ ? _itemList[_loc5_] : null,_iconLayerName,_loc5_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown);
                  }
                  else
                  {
                     new _windowClass(param2,_itemList != null && _itemList.length > _loc5_ ? _itemList[_loc5_] : null,_iconLayerName,_loc5_,_mouseDown,_mouseOver,_mouseOut,_mouseMemberOnlyDown,_customParams);
                  }
                  _loc5_++;
               }
            }
            else if(_callback != null)
            {
               _callback();
               _callback = null;
            }
         }
         else
         {
            _loadingQueue.push({
               "numWindows":param1,
               "callback":param2,
               "updateScrollPosition":param3
            });
         }
      }
      
      private function onInitialWindowsLoaded(param1:MovieClip, param2:int = -1) : void
      {
         if(_mediaWindows && _dynamicScrollbar)
         {
            _mediaWindows[param2 == -1 ? param1.index : param2] = param1;
            _numLoaded = _numLoaded + 1;
            if(_numLoaded == _totalNumWin)
            {
               _boxWidth = param1.width;
               _boxHeight = param1.height;
               numWindowsCreated = _totalNumWin;
               _dynamicScrollbar.insertMany(_mediaWindows,_updateScrollPosition,false,true);
               if(_callback != null)
               {
                  _callback();
                  _callback = null;
               }
               checkForMoreToLoad();
            }
         }
      }
      
      private function onSingleWindowLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(_mediaWindows && _dynamicScrollbar)
         {
            _loc3_ = int(param2 == -1 ? param1.index : param2);
            if(_mediaWindows[_loc3_])
            {
               _mediaWindows.splice(_loc3_,0,param1);
            }
            else
            {
               _mediaWindows[_loc3_] = param1;
            }
            if(_insertAtTop)
            {
               _loc4_ = 1;
               while(_loc4_ < _mediaWindows.length)
               {
                  _mediaWindows[_loc4_].index++;
                  _loc4_++;
               }
            }
            _numLoaded = _numLoaded + 1;
            _dynamicScrollbar.insert(param1,_updateScrollPosition,_insertAtTop);
            numWindowsCreated = _totalNumWin;
            checkForMoreToLoad();
         }
      }
      
      private function onManyWindowsLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc5_:int = 0;
         if(_mediaWindows && _dynamicScrollbar)
         {
            _loc4_ = int(param2 == -1 ? param1.index : param2);
            if(_mediaWindows[_loc4_])
            {
               _mediaWindows.splice(_loc4_,0,param1);
            }
            else
            {
               _mediaWindows[_loc4_] = param1;
            }
            _manyLoadedWindows[_loc4_ - _manyLoadingWindowIndexOffset] = param1;
            _numLoaded = _numLoaded + 1;
            if(_numLoaded == _numWindowsToLoad)
            {
               numWindowsCreated = _totalNumWin;
               if(_insertAtTop)
               {
                  _loc3_ = _mediaWindows[_mediaWindows.length - 1].index + 1;
                  _loc5_ = _numLoaded;
                  while(_loc5_ < _mediaWindows.length)
                  {
                     _mediaWindows[_loc5_].index = _loc3_++;
                     _loc5_++;
                  }
               }
               _dynamicScrollbar.insertMany(_manyLoadedWindows,_updateScrollPosition,false,_insertAtTop);
               _manyLoadedWindows = [];
               if(!checkForMoreToLoad())
               {
                  if(_onInsertManyCallback != null)
                  {
                     _onInsertManyCallback();
                     _onInsertManyCallback = null;
                  }
               }
            }
         }
      }
      
      private function checkForMoreToLoad() : Boolean
      {
         var _loc1_:Object = null;
         _loading = false;
         _updateScrollPosition = false;
         if(_loadingQueue.length > 0)
         {
            _loc1_ = _loadingQueue.shift();
            _manyLoadingWindowIndexOffset = _dynamicScrollbar.getNumOfAssets();
            loadWindows(_loc1_.numWindows,_loc1_.callback,_loc1_.updateScrollPosition);
            return true;
         }
         return false;
      }
   }
}

