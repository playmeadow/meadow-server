package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
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
      
      public function init(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:Number = 0, param8:Number = -1) : void
      {
         this._scrollContent = param1;
         this._scrollContent.y = 0;
         this._scrollContent.x = 0;
         var _loc9_:MovieClip = new (getDefinitionByName(param5) as Class)();
         if(Boolean(_loc9_.track) && Boolean(_loc9_.handle))
         {
            this._track = _loc9_.track;
            this._scrollHandle = _loc9_.handle;
            this._topBtn = _loc9_.topBtn;
            this._bottomBtn = _loc9_.botBtn;
            this._snapHeight = param6;
            this._gap = param4;
            this._viewableWidth = param2;
            this._viewableHeight = param3;
            this._numPerRow = Math.round(this._viewableWidth / this._scrollContent.boxWidth);
            if(param8 < this._viewableHeight)
            {
               this._scrollContentHeight = this._scrollContent.height;
            }
            else
            {
               this._scrollContentHeight = param8;
            }
            this._scrollContentMask = this.createMask(this._viewableWidth,this._viewableHeight);
            this._scrollContent.parent.addChild(this._scrollContentMask);
            this._scrollContentMask.x = this._scrollContent.x;
            this._scrollContentMask.y = this._scrollContent.y;
            this._scrollContent.mask = this._scrollContentMask;
            this._scrollHeight = this._scrollContentHeight - this._scrollContentMask.height;
            if(param7 <= 0)
            {
               this._currContentY = 0;
            }
            else if(param7 > this._scrollHeight)
            {
               this._currContentY = this._scrollHeight;
            }
            else
            {
               this._currContentY = param7;
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
         if(this._scrollHandle)
         {
            this._scrollHandle.y = 0;
            this._scrollContent.y = 0;
         }
         if(this._scrollContent)
         {
            if(this._scrollContent.stage)
            {
               this._scrollContent.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
               this._scrollContent.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveHandler);
            }
            if(this._scrollContent.parent)
            {
               this._scrollContent.parent.removeEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler);
               if(this._scrollContent.stage)
               {
                  this._scrollContent.parent.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
               }
               if(this._scrollContent.parent.parent)
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
               if(Boolean(this._track) && Boolean(this._track.parent))
               {
                  this._scrollContent.parent.removeChild(this._track);
               }
               if(Boolean(this._scrollHandle) && Boolean(this._scrollHandle.parent))
               {
                  this._scrollHandle.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownHandler);
                  this._scrollContent.parent.removeChild(this._scrollHandle);
               }
               if(Boolean(this._topBtn) && Boolean(this._topBtn.parent))
               {
                  this._topBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick);
                  this._scrollContent.parent.removeChild(this._topBtn);
               }
               if(Boolean(this._bottomBtn) && Boolean(this._bottomBtn.parent))
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
      
      public function scrollToElement(param1:int) : void
      {
         if(param1 < 0 || param1 > this._scrollContentHeight / this._snapHeight)
         {
            throw new Error("Invalid index.");
         }
         this.updateContentPosition(param1 * this._snapHeight - this._currContentY);
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
         var _loc1_:Number = Math.round(this._scrollHeight * this._handleMovementPercentage / this._snapHeight);
         _loc1_ = this._snapHeight * _loc1_;
         var _loc2_:Number = _loc1_ / this._scrollHeight;
         this._currContentY = this._scrollHeight * _loc2_;
         new GTween(this._scrollContent,this.EASE_BUTTON_TIME,{"y":this._scrollContentMask.y - this._currContentY},{"ease":Quadratic.easeOut});
         this.setScrollHandleLocation(this._currContentY);
         var _loc3_:Number = Math.max(this._scrollHandle.y,this._track.y);
         new GTween(this._scrollHandle,this.EASE_BUTTON_TIME,{"y":_loc3_},{"ease":Quadratic.easeOut});
      }
      
      private function setScrollHandleLocation(param1:Number) : void
      {
         var _loc2_:Number = param1 / this._scrollHeight;
         var _loc3_:Number = _loc2_ * this._scrollHeight;
         _loc3_ /= this._snapHeight;
         this._handleMovementPercentage = _loc3_ * this._snapHeight / this._scrollHeight;
         this._scrollHandle.y = Math.max(this._handleMovementPercentage * this._adjTrackHeight + this._topBtn.height,this._track.y);
      }
      
      private function loadCurrViewableObjects(param1:Number) : void
      {
         var _loc2_:int = Math.ceil(param1 / this._snapHeight);
         var _loc3_:int = _loc2_ * this._numPerRow;
         var _loc4_:int = _loc3_ + this._numRowsInView * this._numPerRow;
         var _loc5_:int = int(this._scrollContent.bg.numChildren);
         var _loc6_:int = _loc3_;
         while(_loc6_ < _loc4_)
         {
            if(_loc6_ < _loc5_)
            {
               this._scrollContent.bg.getChildAt(_loc6_).loadCurrItem(param1);
            }
            _loc6_++;
         }
      }
      
      private function updateLoadItems(param1:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._scrollContent.hasOwnProperty("bg"))
         {
            if(!param1)
            {
               this.loadCurrViewableObjects(this._currContentY);
            }
            else
            {
               _loc2_ = Math.round(this._scrollHeight * this._handleMovementPercentage / this._snapHeight);
               _loc2_ = this._snapHeight * _loc2_;
               _loc3_ = _loc2_ / this._scrollHeight;
               this.loadCurrViewableObjects(this._scrollHeight * _loc3_);
            }
         }
      }
      
      private function updateContentPosition(param1:Number = NaN) : void
      {
         if(!isNaN(param1))
         {
            this._currContentY += param1;
            this.setScrollHandleLocation(this._currContentY);
            this.updateLoadItems();
            this._scrollTween = new GTween(this._scrollContent,this.EASE_BUTTON_TIME,{"y":this._scrollContentMask.y - this._currContentY},{"ease":Quadratic.easeOut});
         }
         else
         {
            this._handleMovementPercentage = (this._scrollHandle.y - this._topBtn.height) / this._adjTrackHeight;
            this.updateLoadItems(true);
            this._scrollTween = new GTween(this._scrollContent,this.EASE_TIME,{"y":this._scrollContentMask.y - this._scrollHeight * this._handleMovementPercentage},{"ease":Quadratic.easeOut});
         }
      }
      
      private function onBtnClick(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         if(this._scrollTween)
         {
            this._scrollTween.end();
         }
         if(param1.currentTarget.name == this._topBtn.name)
         {
            _loc2_ = this.scrollUp();
         }
         else
         {
            _loc2_ = this.scrollDown();
         }
         if(_loc2_ != 0)
         {
            this.updateContentPosition(_loc2_);
         }
      }
      
      private function scrollUp() : Number
      {
         var _loc2_:* = 0;
         var _loc1_:int = 0;
         if(this._currContentY > 0)
         {
            if(this._currContentY >= this._fullScreenScrollChange)
            {
               _loc1_ = -this._fullScreenScrollChange;
            }
            else
            {
               _loc2_ = int(this._numRowsInView - 2);
               while(_loc2_ > 0)
               {
                  if(this._currContentY >= this._snapHeight * _loc2_)
                  {
                     _loc1_ = -(this._snapHeight * _loc2_);
                     break;
                  }
                  _loc2_--;
               }
               if(_loc1_ > -this._currContentY)
               {
                  _loc1_ = -this._currContentY;
               }
            }
         }
         return _loc1_;
      }
      
      private function scrollDown() : Number
      {
         var _loc3_:* = 0;
         var _loc1_:Number = 0;
         var _loc2_:Number = this._scrollContentHeight - this._currContentY - this._viewableHeight;
         if(_loc2_ > 0)
         {
            if(_loc2_ >= this._fullScreenScrollChange)
            {
               _loc1_ = this._fullScreenScrollChange;
            }
            else
            {
               _loc3_ = int(this._numRowsInView - 2);
               while(_loc3_ > 0)
               {
                  if(_loc2_ >= this._snapHeight * _loc3_)
                  {
                     _loc1_ = this._snapHeight * _loc3_;
                     break;
                  }
                  _loc3_--;
               }
               if(_loc1_ < _loc2_)
               {
                  _loc1_ = _loc2_;
               }
            }
         }
         return _loc1_;
      }
      
      private function onMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._scrollHandle.height < this._scrollContentHeight - 3)
         {
            this._scrollHandle.startDrag(false,this._bounds);
            this._scrollContent.parent.parent.addEventListener(MouseEvent.ROLL_OUT,this.onStageOut,false,0,true);
            this._scrollContent.stage.addEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveHandler,false,0,true);
            this._scrollContent.parent.stage.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler,false,0,true);
            this._scrollContent.parent.parent.parent.addEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler,false,0,true);
         }
      }
      
      private function onStageOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.onMouseUpHandler(param1);
      }
      
      private function onMouseUpHandler(param1:MouseEvent = null) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         this._scrollHandle.stopDrag();
         if(this._scrollTween)
         {
            this._scrollTween.end();
         }
         if(this._snapHeight > 0)
         {
            this.snapToPlace();
         }
         if(this._scrollContent.stage)
         {
            this._scrollContent.stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.onMouseMoveHandler);
         }
         if(this._scrollContent.parent.stage)
         {
            this._scrollContent.parent.stage.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
         }
         if(this._scrollContent.parent.parent)
         {
            this._scrollContent.parent.parent.removeEventListener(MouseEvent.ROLL_OUT,this.onStageOut);
         }
         if(this._scrollContent.parent.parent.parent)
         {
            this._scrollContent.parent.parent.parent.removeEventListener(MouseEvent.MOUSE_UP,this.onMouseUpHandler);
         }
      }
      
      private function onTrackDown(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         var _loc3_:Number = Math.ceil(param1.localY * param1.currentTarget.scaleY);
         if(this._scrollTween)
         {
            this._scrollTween.end();
         }
         if(_loc3_ < this._scrollHandle.y + this._scrollHandle.height - this._topBtn.height)
         {
            _loc2_ = this.scrollUp();
         }
         else
         {
            _loc2_ = this.scrollDown();
         }
         if(_loc2_ != 0)
         {
            this.updateContentPosition(_loc2_);
         }
      }
      
      private function onMouseMoveHandler(param1:MouseEvent) : void
      {
         this.updateContentPosition();
      }
      
      private function onMouseWheelHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = 0;
         if(param1.delta > 0)
         {
            _loc2_ = this.scrollUp();
         }
         else
         {
            _loc2_ = this.scrollDown();
         }
         if(_loc2_ != 0)
         {
            this.updateContentPosition(_loc2_);
         }
      }
      
      private function createMask(param1:Number, param2:Number) : MovieClip
      {
         var _loc3_:MovieClip = new MovieClip();
         _loc3_.graphics.beginFill(16777215);
         _loc3_.graphics.drawRect(0,0,param1,param2);
         _loc3_.graphics.endFill();
         return _loc3_;
      }
      
      private function resizeHandle() : void
      {
         var _loc1_:Number = NaN;
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
            _loc1_ = this._scrollContentMask.height / this._scrollContentHeight * this._scrollContentMask.height - this._topBtn.height - this._bottomBtn.height;
            this._topBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick,false,0,true);
            this._bottomBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnClick,false,0,true);
            this._scrollHandle.addEventListener(MouseEvent.MOUSE_DOWN,this.onMouseDownHandler,false,0,true);
            this._track.addEventListener(MouseEvent.MOUSE_DOWN,this.onTrackDown,false,0,true);
            this._scrollContent.parent.addEventListener(MouseEvent.MOUSE_WHEEL,this.onMouseWheelHandler,false,0,true);
            if(_loc1_ < this.MIN_HANDLE_HEIGHT)
            {
               _loc1_ = this.MIN_HANDLE_HEIGHT;
            }
            this._scrollHandle.mid.height = _loc1_ - this._scrollHandle.top.height - this._scrollHandle.bot.height;
            this._scrollHandle.top.y = 0;
            this._scrollHandle.mid.y = this._scrollHandle.top.y + this._scrollHandle.top.height - 0.1;
            this._scrollHandle.bot.y = this._scrollHandle.mid.y + this._scrollHandle.mid.height - 0.1;
         }
      }
   }
}

