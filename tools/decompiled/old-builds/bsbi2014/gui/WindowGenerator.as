package gui
{
   import flash.display.MovieClip;
   
   public class WindowGenerator extends MovieClip
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
      
      private var _xOffset:int;
      
      private var _yOffset:int;
      
      private var _xStart:int;
      
      private var _yStart:int;
      
      private var _numToCreated:int;
      
      private var _fillCompletely:Boolean;
      
      private var _mediaWindows:Array;
      
      private var _numLoaded:int;
      
      private var _callback:Function;
      
      private var _mouseDown:Function;
      
      private var _mouseOver:Function;
      
      private var _mouseOut:Function;
      
      private var _mouseMemberOnlyDown:Function;
      
      public function WindowGenerator()
      {
         super();
      }
      
      public function init(xWinVis:int, yWinVis:int, totalNumWin:int, xOffset:Number, yOffset:Number, xStart:int, initWindowClass:Class, initItemList:Array, initIconLayerName:String, initMouseFunctions:Object = null, initCustomParams:Object = null, initCallback:Function = null, isSideways:Boolean = false, fillCompletely:Boolean = true) : void
      {
         this._xWinVis = xWinVis;
         this._yWinVis = yWinVis;
         this._totalNumWin = totalNumWin;
         this._xOffset = xOffset;
         this._yOffset = yOffset;
         this._xStart = xStart;
         this._yStart = this._yOffset * 0.5;
         this._fillCompletely = fillCompletely;
         this._callback = initCallback;
         var minNumWindows:int = this._totalNumWin;
         if(this._fillCompletely)
         {
            minNumWindows = this._xWinVis * this._yWinVis;
         }
         if(this._totalNumWin < minNumWindows)
         {
            this._totalNumWin = minNumWindows;
         }
         if(isSideways)
         {
            this._numRows = yWinVis;
            this._numCols = Math.ceil(this._totalNumWin / this._yWinVis);
         }
         else
         {
            this._numRows = Math.ceil(this._totalNumWin / this._xWinVis);
            this._numCols = xWinVis;
         }
         this.bg = new MovieClip();
         if(initMouseFunctions != null)
         {
            this._mouseDown = initMouseFunctions.mouseDown;
            this._mouseOut = initMouseFunctions.mouseOut;
            this._mouseOver = initMouseFunctions.mouseOver;
            this._mouseMemberOnlyDown = initMouseFunctions.memberOnlyDown;
         }
         this._mediaWindows = [this._totalNumWin];
         this._numLoaded = 0;
         for(var i:int = 0; i < this._totalNumWin; i++)
         {
            if(initWindowClass == ItemWindowBase)
            {
               new initWindowClass(initCustomParams.itemClassName,this.windowLoaded,initItemList != null && initItemList.length > i ? initItemList[i] : null,initIconLayerName,i,this._mouseDown,this._mouseOver,this._mouseOut,this._mouseMemberOnlyDown);
            }
            else
            {
               new initWindowClass(this.windowLoaded,initItemList != null && initItemList.length > i ? initItemList[i] : null,initIconLayerName,i,this._mouseDown,this._mouseOver,this._mouseOut,this._mouseMemberOnlyDown,initCustomParams);
            }
         }
      }
      
      public function destroy() : void
      {
         var i:int = 0;
         if(Boolean(this.bg))
         {
            while(this.bg.numChildren > 0)
            {
               this.bg.removeChildAt(0);
            }
            if(this.bg.parent == this)
            {
               removeChild(this.bg);
            }
         }
         if(Boolean(this._mediaWindows))
         {
            for(i = 0; i < this._mediaWindows.length; i++)
            {
               if(this._mediaWindows[i] != null && Boolean(this._mediaWindows[i].hasOwnProperty("destroy")))
               {
                  this._mediaWindows[i].destroy();
               }
            }
            this._mediaWindows = null;
         }
         if(Boolean(this.toolTip))
         {
            this.toolTip.resetTimerAndSetVisibility();
            this.toolTip = null;
         }
         this.bg = null;
      }
      
      public function get boxHeight() : int
      {
         return this._boxHeight;
      }
      
      public function get boxWidth() : int
      {
         return this._boxWidth;
      }
      
      private function windowLoaded(window:MovieClip, index:int = -1) : void
      {
         if(Boolean(this._mediaWindows))
         {
            this._mediaWindows[index == -1 ? window.index : index] = window;
            ++this._numLoaded;
            if(this._numLoaded == this._totalNumWin)
            {
               this.toolTip = ToolTipPopup(GETDEFINITIONBYNAME("Tooltip"));
               this._boxWidth = window.width;
               this._boxHeight = window.height;
               this.generateWindows();
               with(this.bg.graphics)
               {
                  
                  drawRect(0,0,_xWinVis * _boxWidth + (_xWinVis - 1) * _xOffset + 2 * _xStart,_numRows * _boxHeight + (_numRows - 1) * _yOffset + 2 * _yStart);
               }
               addChild(this.bg);
               if(this._callback != null)
               {
                  this._callback();
                  this._callback = null;
               }
            }
         }
      }
      
      private function generateWindows() : void
      {
         var y:int = 0;
         var x:int = 0;
         var newWindow:MovieClip = null;
         var windowsCreated:int = 0;
         loop0:
         for(y = 0; y < this._numRows; )
         {
            x = 0;
            while(true)
            {
               if(x >= this._numCols)
               {
                  y++;
                  continue loop0;
               }
               if(windowsCreated >= this._totalNumWin && !this._fillCompletely)
               {
                  break;
               }
               if(this._mediaWindows[windowsCreated] is ItemWindowBase)
               {
                  newWindow = this._mediaWindows[windowsCreated];
                  newWindow.x = this._xStart + this._xOffset * x + this._boxWidth * x;
                  newWindow.y = this._yStart + this._yOffset * y + this._boxHeight * y;
                  this.bg.addChild(newWindow);
                  windowsCreated++;
               }
               x++;
            }
            this.numWindowsCreated = windowsCreated;
            return;
         }
         this.numWindowsCreated = windowsCreated;
      }
   }
}

