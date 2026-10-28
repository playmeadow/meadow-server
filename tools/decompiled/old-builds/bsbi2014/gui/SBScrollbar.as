package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import gskinner.motion.GTween;
   import gskinner.motion.easing.Quadratic;
   
   public class SBScrollbar extends MovieClip
   {
      
      private const MIN_HANDLE_HEIGHT:int = 30;
      
      private const EASE_TIME:Number = 0.001;
      
      private const EASE_BUTTON_TIME:Number = 0.5;
      
      private var _scrollContentMask:MovieClip;
      
      private var _wheelScrollPercent:Number;
      
      private var _wheelScrollChange:Number;
      
      private var _scrollHeight:Number;
      
      private var _bounds:Rectangle;
      
      private var _scrollTween:GTween;
      
      private var _scrollContent:MovieClip;
      
      private var _scrollContentHeight:Number;
      
      private var _track:MovieClip;
      
      private var _scrollHandle:MovieClip;
      
      private var _topBtn:MovieClip;
      
      private var _bottomBtn:MovieClip;
      
      private var _gap:Number;
      
      private var _snapHeight:Number;
      
      private var _viewableWidth:Number;
      
      private var _viewableHeight:Number;
      
      private var _adjTrackHeight:Number;
      
      private var _handleMovementPercentage:Number;
      
      private var _currContentY:Number;
      
      private var _numRowsInView:int;
      
      private var _fullScreenScrollChange:Number;
      
      private var _numPerRow:int;
      
      public function SBScrollbar()
      {
         super();
      }
      
      public function init(scrollContent:MovieClip, viewableWidth:Number, viewableHeight:Number, gap:Number, scrollbarClass:String, snapHeight:Number, yStartPos:Number = 0, scrollableHeight:Number = -1) : void
      {
         this._scrollContent = scrollContent;
         this._scrollContent.y = 0;
         this._scrollContent.x = 0;
         var scrollbar:MovieClip = GETDEFINITIONBYNAME(scrollbarClass);
         if(Boolean(scrollbar.track) && Boolean(scrollbar.handle))
         {
            this._track = scrollbar.track;
            this._scrollHandle = scrollbar.handle;
            this._topBtn = scrollbar.topBtn;
            this._bottomBtn = scrollbar.botBtn;
            this._snapHeight = snapHeight;
            this._gap = gap;
            this._viewableWidth = viewableWidth;
            this._viewableHeight = viewableHeight;
            this._numPerRow = Math.round(this._viewableWidth / this._scrollContent.boxWidth);
            if(scrollableHeight < this._viewableHeight)
            {
               this._scrollContentHeight = this._scrollContent.height;
            }
            else
            {
               this._scrollContentHeight = scrollableHeight;
            }
            this._scrollContentMask = this.createMask(this._viewableWidth,this._viewableHeight);
            this._scrollContent.parent.addChild(this._scrollContentMask);
            this._scrollContentMask.x = this._scrollContent.x;
            this._scrollContentMask.y = this._scrollContent.y;
            this._scrollContent.mask = this._scrollContentMask;
            this._scrollHeight = this._scrollContentHeight - this._scrollContentMask.height;
            if(yStartPos <= 0)
            {
               this._currContentY = 0;
            }
            else if(yStartPos > this._scrollHeight)
            {
               this._currContentY = this._scrollHeight;
            }
            else
            {
               this._currContentY = yStartPos;
            }
            this.setupAllItems();
            this._numRowsInView = Math.round(this._viewableHeight / this._snapHeight);
            this._fullScreenScrollChange = this._snapHeight * (this._numRowsInView - 1);
            this._handleMovementPercentage = 0;
            this._bounds = new Rectangle(this._track.x,this._scrollContentMask.y,0,Math.round(this._bottomBtn.y - this._scrollHandle.height));
            this._bounds.top = this._topBtn.height;
            this._adjTrackHeight = this._track.height - this._scrollHandle.height;
            this._wheelScrollPercent = this._snapHeight / (this._scrollContentHeight - this._scrollContentMask.height);
            this._wheelScrollChange = this._wheelScrollPercent * (this._scrollContentMask.y + this._scrollContentMask.height - this._scrollHandle.height);
            this.setScrollHandleLocation(this._currContentY);
            this.updateLoadItems();
            this._scrollContent.y = this._scrollContentMask.y - this._currContentY;
            return;
         }
         throw new Error("Error: SBSCrollbar.init()- The 5th parameter must contain two symbols; \'track\' and \'handle\'.");
      }
      
      public function destroy() : void
      {
         if(Boolean(this._scrollHandle))
         {
            this._scrollHandle.y = 0;
            this._scrollContent.y = 0;
         }
         if(Boolean(this._scrollContent))
         {
            if(Boolean(this._scrollContent.stage))
            {
               this._scrollContent.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
               this._scrollContent.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveHandler);
            }
            if(Boolean(this._scrollContent.parent))
            {
               this._scrollContent.parent.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler);
               if(Boolean(this._scrollContent.stage))
               {
                  this._scrollContent.parent.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
               }
               if(Boolean(this._scrollContent.parent.parent))
               {
                  this._scrollContent.parent.parent.removeEventListener(MouseEvent.ROLL_OUT,this.onStageOut);
               }
               if(Boolean(this._scrollContent.parent) && Boolean(this._scrollContent.parent.parent) && Boolean(this._scrollContent.parent.parent.parent))
               {
                  this._scrollContent.parent.parent.parent.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
               }
               if(Boolean(this._scrollContentMask) && Boolean(this._scrollContentMask.parent))
               {
                  this._scrollContentMask.parent.removeChild(this._scrollContentMask);
               }
               if(Boolean(this._track) && Boolean(this._track.parent) && this._track.parent == this._scrollContent.parent)
               {
                  this._scrollContent.parent.removeChild(this._track);
               }
               if(Boolean(this._scrollHandle) && Boolean(this._scrollHandle.parent) && this._scrollHandle.parent == this._scrollContent.parent)
               {
                  this._scrollHandle.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownHandler);
                  this._scrollContent.parent.removeChild(this._scrollHandle);
               }
               if(Boolean(this._topBtn) && Boolean(this._topBtn.parent) && this._topBtn.parent == this._scrollContent.parent)
               {
                  this._topBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick);
                  this._scrollContent.parent.removeChild(this._topBtn);
               }
               if(Boolean(this._bottomBtn) && Boolean(this._bottomBtn.parent) && this._bottomBtn.parent == this._scrollContent.parent)
               {
                  this._bottomBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick);
                  this._scrollContent.parent.removeChild(this._bottomBtn);
               }
            }
         }
         this._track = null;
         this._scrollHandle = null;
         this._topBtn = null;
         this._bottomBtn = null;
         this._scrollContent = null;
         this._scrollContentMask = null;
         this._bounds = null;
         this._gap = NaN;
         this._snapHeight = NaN;
         this._viewableWidth = NaN;
         this._viewableHeight = NaN;
         this._adjTrackHeight = NaN;
         this._handleMovementPercentage = NaN;
         this._currContentY = NaN;
         this._numRowsInView = NaN;
         this._fullScreenScrollChange = NaN;
      }
      
      public function get scrollHeight() : Number
      {
         return this._scrollHeight;
      }
      
      public function get getMaskHeight() : Number
      {
         return this._scrollContentMask.height;
      }
      
      public function get getMaskY() : Number
      {
         return this._scrollContentMask.y;
      }
      
      public function get scrollYValue() : Number
      {
         if(this._scrollContentHeight <= this._scrollContentMask.height)
         {
            this._currContentY = 0;
         }
         return this._currContentY;
      }
      
      public function get scrollYPercentage() : Number
      {
         if(this._scrollContentHeight <= this._scrollContentMask.height)
         {
            return this._currContentY = 0;
         }
         return this._currContentY / this._scrollHeight;
      }
      
      public function get getScrollContentParent() : MovieClip
      {
         return MovieClip(this._scrollContent.parent);
      }
      
      public function scrollToElement(elIdx:int) : void
      {
         if(elIdx < 0 || elIdx > this._scrollContentHeight / this._snapHeight)
         {
            throw new Error("Invalid index.");
         }
         this.updateContentPosition(Math.min(this._scrollHeight,elIdx * this._snapHeight - this._currContentY));
      }
      
      private function setupAllItems() : void
      {
         this._scrollContent.parent.addChild(this._track);
         this._track.x = Math.round(this._scrollContent.x + this._viewableWidth + this._gap + this._track.width * 0.5);
         this._track.y = this._scrollContent.y + this._topBtn.height;
         this._track.height = this._scrollContentMask.height - this._topBtn.height - this._bottomBtn.height;
         this._scrollContent.parent.addChild(this._topBtn);
         this._topBtn.x = this._track.x;
         this._topBtn.y = this._scrollContent.y;
         this._scrollContent.parent.addChild(this._bottomBtn);
         this._bottomBtn.x = this._track.x;
         this._bottomBtn.y = this._track.y + this._track.height;
         this._scrollContent.parent.addChild(this._scrollHandle);
         this._scrollHandle.x = this._track.x;
         this._scrollHandle.y = this._track.y;
         this.resizeHandle();
      }
      
      private function snapToPlace() : void
      {
         var newPos:Number = Math.round(this._scrollHeight * this._handleMovementPercentage / this._snapHeight);
         newPos = this._snapHeight * newPos;
         var percent:Number = newPos / this._scrollHeight;
         this._currContentY = this._scrollHeight * percent;
         new GTween(this._scrollContent,this.EASE_BUTTON_TIME,{"y":this._scrollContentMask.y - this._currContentY},{"ease":Quadratic.easeOut});
         this.setScrollHandleLocation(this._currContentY);
         var handlePos:Number = Math.max(this._scrollHandle.y,this._track.y);
         new GTween(this._scrollHandle,this.EASE_BUTTON_TIME,{"y":handlePos},{"ease":Quadratic.easeOut});
      }
      
      private function setScrollHandleLocation(contentYValue:Number) : void
      {
         var percent:Number = Math.min(1,contentYValue / this._scrollHeight);
         var newPos:Number = percent * this._scrollHeight;
         newPos /= this._snapHeight;
         this._handleMovementPercentage = newPos * this._snapHeight / this._scrollHeight;
         this._scrollHandle.y = Math.max(this._handleMovementPercentage * this._adjTrackHeight + this._topBtn.height,this._track.y);
      }
      
      private function loadCurrViewableObjects(currContentY:Number) : void
      {
         var currRow:int = Math.ceil(currContentY / this._snapHeight);
         var currStartIndex:int = currRow * this._numPerRow;
         var currEndIndex:int = currStartIndex + this._numRowsInView * this._numPerRow;
         var numChildren:int = int(this._scrollContent.bg.numChildren);
         for(var i:int = currStartIndex; i < currEndIndex; i++)
         {
            if(i < numChildren)
            {
               this._scrollContent.bg.getChildAt(i).loadCurrItem(currContentY);
            }
         }
      }
      
      private function updateLoadItems(isScrollbar:Boolean = false) : void
      {
         var newPos:Number = NaN;
         var percent:Number = NaN;
         if(this._scrollContent.hasOwnProperty("bg"))
         {
            if(!isScrollbar)
            {
               this.loadCurrViewableObjects(this._currContentY);
            }
            else
            {
               newPos = Math.round(this._scrollHeight * this._handleMovementPercentage / this._snapHeight);
               newPos = this._snapHeight * newPos;
               percent = newPos / this._scrollHeight;
               this.loadCurrViewableObjects(this._scrollHeight * percent);
            }
         }
      }
      
      private function updateContentPosition(scrollAmount:Number = NaN) : void
      {
         if(!isNaN(scrollAmount))
         {
            this._currContentY += scrollAmount;
            this.setScrollHandleLocation(this._currContentY);
            this.updateLoadItems();
            this._scrollTween = new GTween(this._scrollContent,this.EASE_BUTTON_TIME,{"y":this._scrollContentMask.y - this._currContentY},{"ease":Quadratic.easeOut});
         }
         else
         {
            this._handleMovementPercentage = Math.min(1,(this._scrollHandle.y - this._topBtn.height) / this._adjTrackHeight);
            this.updateLoadItems(true);
            this._scrollTween = new GTween(this._scrollContent,this.EASE_TIME,{"y":this._scrollContentMask.y - this._scrollHeight * this._handleMovementPercentage},{"ease":Quadratic.easeOut});
         }
      }
      
      private function onBtnClick(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var scrollAmt:Number = 0;
         if(Boolean(this._scrollTween))
         {
            this._scrollTween.end();
         }
         if(evt.currentTarget.name == this._topBtn.name)
         {
            scrollAmt = this.scrollUp();
         }
         else
         {
            scrollAmt = this.scrollDown();
         }
         if(scrollAmt != 0)
         {
            this.updateContentPosition(scrollAmt);
         }
      }
      
      private function scrollUp() : Number
      {
         var j:int = 0;
         var scrollAmt:int = 0;
         if(this._currContentY > 0)
         {
            if(this._currContentY >= this._fullScreenScrollChange)
            {
               scrollAmt = -this._fullScreenScrollChange;
            }
            else
            {
               for(j = this._numRowsInView - 2; j > 0; j--)
               {
                  if(this._currContentY >= this._snapHeight * j)
                  {
                     scrollAmt = -(this._snapHeight * j);
                     break;
                  }
               }
               if(scrollAmt > -this._currContentY)
               {
                  scrollAmt = -this._currContentY;
               }
            }
         }
         return scrollAmt;
      }
      
      private function scrollDown() : Number
      {
         var i:int = 0;
         var scrollAmt:Number = 0;
         var contentHeightBelowWindow:Number = this._scrollContentHeight - this._currContentY - this._viewableHeight;
         if(contentHeightBelowWindow > 0)
         {
            if(contentHeightBelowWindow >= this._fullScreenScrollChange)
            {
               scrollAmt = this._fullScreenScrollChange;
            }
            else
            {
               for(i = this._numRowsInView - 2; i > 0; i--)
               {
                  if(contentHeightBelowWindow >= this._snapHeight * i)
                  {
                     scrollAmt = this._snapHeight * i;
                     break;
                  }
               }
               if(scrollAmt < contentHeightBelowWindow)
               {
                  scrollAmt = contentHeightBelowWindow;
               }
            }
         }
         return scrollAmt;
      }
      
      private function onMouseDownHandler(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(this._scrollHandle.height < this._scrollContentHeight - 3)
         {
            this._scrollHandle.startDrag(false,this._bounds);
            this._scrollContent.parent.parent.addEventListener(MouseEvent.ROLL_OUT,this.onStageOut,false,0,true);
            this._scrollContent.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveHandler,false,0,true);
            this._scrollContent.parent.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler,false,0,true);
            this._scrollContent.parent.parent.parent.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler,false,0,true);
         }
      }
      
      private function onStageOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.onMouseUpHandler(evt);
      }
      
      private function onMouseUpHandler(evt:MouseEvent = null) : void
      {
         if(Boolean(evt))
         {
            evt.stopPropagation();
         }
         this._scrollHandle.stopDrag();
         if(Boolean(this._scrollTween))
         {
            this._scrollTween.end();
         }
         if(this._snapHeight > 0)
         {
            this.snapToPlace();
         }
         if(Boolean(this._scrollContent.stage))
         {
            this._scrollContent.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveHandler);
         }
         if(Boolean(this._scrollContent.parent.stage))
         {
            this._scrollContent.parent.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
         }
         if(Boolean(this._scrollContent.parent.parent))
         {
            this._scrollContent.parent.parent.removeEventListener(MouseEvent.ROLL_OUT,this.onStageOut);
         }
         if(Boolean(this._scrollContent.parent.parent.parent))
         {
            this._scrollContent.parent.parent.parent.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
         }
      }
      
      private function onTrackDown(evt:MouseEvent) : void
      {
         var scrollAmt:Number = 0;
         var point:Number = Math.ceil(evt.localY * evt.currentTarget.scaleY);
         if(Boolean(this._scrollTween))
         {
            this._scrollTween.end();
         }
         if(point < this._scrollHandle.y + this._scrollHandle.height - this._topBtn.height)
         {
            scrollAmt = this.scrollUp();
         }
         else
         {
            scrollAmt = this.scrollDown();
         }
         if(scrollAmt != 0)
         {
            this.updateContentPosition(scrollAmt);
         }
      }
      
      private function onMouseMoveHandler(evt:MouseEvent) : void
      {
         this.updateContentPosition();
      }
      
      private function onMouseWheelHandler(evt:MouseEvent) : void
      {
         var scrollAmt:Number = 0;
         if(evt.delta > 0)
         {
            scrollAmt = this.scrollUp();
         }
         else
         {
            scrollAmt = this.scrollDown();
         }
         if(scrollAmt != 0)
         {
            this.updateContentPosition(scrollAmt);
         }
      }
      
      private function createMask(viewableWidth:Number, viewableHeight:Number) : MovieClip
      {
         var maskMC:MovieClip = new MovieClip();
         maskMC.graphics.beginFill(16777215);
         maskMC.graphics.drawRect(0,0,viewableWidth,viewableHeight);
         maskMC.graphics.endFill();
         return maskMC;
      }
      
      private function resizeHandle() : void
      {
         var handleHeight:Number = NaN;
         if(this._scrollContentHeight <= this._scrollContentMask.height || this._currContentY != this._scrollHeight && this._scrollContentHeight - this._currContentY - this._viewableHeight < this._snapHeight)
         {
            this._scrollHandle.visible = false;
            if(Boolean(this._topBtn.hasGrayState) && Boolean(this._bottomBtn.hasGrayState))
            {
               this._topBtn.activateGrayState(true);
               this._bottomBtn.activateGrayState(true);
            }
            if(this._scrollContent.parent.hasEventListener(MouseEvent.MOUSE_WHEEL))
            {
               this._scrollContent.parent.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler);
            }
         }
         else
         {
            handleHeight = this._scrollContentMask.height / this._scrollContentHeight * this._scrollContentMask.height - this._topBtn.height - this._bottomBtn.height;
            this._topBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick,false,0,true);
            this._bottomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick,false,0,true);
            this._scrollHandle.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownHandler,false,0,true);
            this._track.addEventListener(MouseEvent.MOUSE_DOWN,this.onTrackDown,false,0,true);
            this._scrollContent.parent.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler,false,0,true);
            if(handleHeight < this.MIN_HANDLE_HEIGHT)
            {
               handleHeight = this.MIN_HANDLE_HEIGHT;
            }
            this._scrollHandle.mid.height = handleHeight - this._scrollHandle.top.height - this._scrollHandle.bot.height;
            this._scrollHandle.top.y = 0;
            this._scrollHandle.mid.y = this._scrollHandle.top.y + this._scrollHandle.top.height - 0.1;
            this._scrollHandle.bot.y = this._scrollHandle.mid.y + this._scrollHandle.mid.height - 0.1;
         }
      }
   }
}

