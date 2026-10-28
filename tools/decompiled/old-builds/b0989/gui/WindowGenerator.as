package gui
{
   import flash.display.MovieClip;
   import flash.utils.getDefinitionByName;
   
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
      
      public function init(param1:int, param2:int, param3:int, param4:Number, param5:Number, param6:int, param7:Class, param8:Array, param9:String, param10:Object = null, param11:Object = null, param12:Function = null, param13:Boolean = false, param14:Boolean = true) : void
      {
         this._xWinVis = param1;
         this._yWinVis = param2;
         this._totalNumWin = param3;
         this._xOffset = param4;
         this._yOffset = param5;
         this._xStart = param6;
         this._yStart = this._yOffset * 0.5;
         this._fillCompletely = param14;
         this._callback = param12;
         var _loc15_:int = this._totalNumWin;
         if(this._fillCompletely)
         {
            _loc15_ = this._xWinVis * this._yWinVis;
         }
         if(this._totalNumWin < _loc15_)
         {
            this._totalNumWin = _loc15_;
         }
         if(param13)
         {
            this._numRows = param2;
            this._numCols = Math.ceil(this._totalNumWin / this._yWinVis);
         }
         else
         {
            this._numRows = Math.ceil(this._totalNumWin / this._xWinVis);
            this._numCols = param1;
         }
         this.bg = new MovieClip();
         if(param10 != null)
         {
            this._mouseDown = param10.mouseDown;
            this._mouseOut = param10.mouseOut;
            this._mouseOver = param10.mouseOver;
            this._mouseMemberOnlyDown = param10.memberOnlyDown;
         }
         this._mediaWindows = [this._totalNumWin];
         this._numLoaded = 0;
         var _loc16_:int = 0;
         while(_loc16_ < this._totalNumWin)
         {
            if(param7 == ItemWindowBase)
            {
               new param7(param11.itemClassName,this.windowLoaded,param8 != null && param8.length > _loc16_ ? param8[_loc16_] : null,param9,_loc16_,this._mouseDown,this._mouseOver,this._mouseOut,this._mouseMemberOnlyDown);
            }
            else
            {
               new param7(this.windowLoaded,param8 != null && param8.length > _loc16_ ? param8[_loc16_] : null,param9,_loc16_,this._mouseDown,this._mouseOver,this._mouseOut,this._mouseMemberOnlyDown,param11);
            }
            _loc16_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(this.bg)
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
         if(this._mediaWindows)
         {
            _loc1_ = 0;
            while(_loc1_ < this._mediaWindows.length)
            {
               if(this._mediaWindows[_loc1_] != null && Boolean(this._mediaWindows[_loc1_].hasOwnProperty("destroy")))
               {
                  this._mediaWindows[_loc1_].destroy();
               }
               _loc1_++;
            }
            this._mediaWindows = null;
         }
         if(this.toolTip)
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
      
      private function windowLoaded(param1:MovieClip, param2:int = -1) : void
      {
         var window:MovieClip = param1;
         var index:int = param2;
         if(this._mediaWindows)
         {
            this._mediaWindows[index == -1 ? window.index : index] = window;
            ++this._numLoaded;
            if(this._numLoaded == this._totalNumWin)
            {
               this.toolTip = new (getDefinitionByName("Tooltip") as Class)();
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
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         loop0:
         while(_loc2_ < this._numRows)
         {
            _loc3_ = 0;
            while(true)
            {
               if(_loc3_ >= this._numCols)
               {
                  _loc2_++;
                  continue loop0;
               }
               if(_loc1_ >= this._totalNumWin && !this._fillCompletely)
               {
                  break;
               }
               if(this._mediaWindows[_loc1_] is ItemWindowBase)
               {
                  _loc4_ = this._mediaWindows[_loc1_];
                  _loc4_.x = this._xStart + this._xOffset * _loc3_ + this._boxWidth * _loc3_;
                  _loc4_.y = this._yStart + this._yOffset * _loc2_ + this._boxHeight * _loc2_;
                  this.bg.addChild(_loc4_);
                  _loc1_++;
               }
               _loc3_++;
            }
            this.numWindowsCreated = _loc1_;
            return;
         }
         this.numWindowsCreated = _loc1_;
      }
   }
}

