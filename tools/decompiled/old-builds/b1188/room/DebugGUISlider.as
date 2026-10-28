package room
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   
   public class DebugGUISlider
   {
      
      private static const SLIDER_X:Number = 400;
      
      private static const SLIDER_Y:Number = 200;
      
      private static const NUB_COLOR:Number = 16776960;
      
      private static const NUB_WIDTH:Number = 10;
      
      private static const NUB_HEIGHT:Number = 20;
      
      private static const SLIDER_WIDTH:Number = 120;
      
      private static const SLIDER_MAX:Number = 1;
      
      private static const SLIDER_INIT:Number = 1;
      
      private var _drag:Boolean;
      
      private var _slider:Sprite;
      
      private var _nub:Sprite;
      
      private var _value:TextField;
      
      private var _visible:Boolean;
      
      private var _layerManager:LayerManager;
      
      public var valueChangedCallback:Function;
      
      public function DebugGUISlider()
      {
         super();
      }
      
      public function init(param1:Object, param2:Function, param3:Boolean = false) : void
      {
         var initParent:Object = param1;
         var initValueChangedCallback:Function = param2;
         var initVisible:Boolean = param3;
         this._layerManager = LayerManager(initParent);
         initParent = initParent.fps;
         this._slider = new Sprite();
         this._nub = new Sprite();
         with(this._nub.graphics)
         {
            beginFill(NUB_COLOR);
            drawRect(-NUB_WIDTH * 0.5,-NUB_HEIGHT * 0.5,NUB_WIDTH,NUB_HEIGHT);
         }
         this._nub.x = SLIDER_WIDTH * SLIDER_INIT;
         this._nub.y = 0;
         with(this._slider.graphics)
         {
            lineStyle(2);
            moveTo(0,0);
            lineTo(SLIDER_WIDTH,0);
            beginFill(0,0);
            drawRect(-NUB_WIDTH,-NUB_HEIGHT,SLIDER_WIDTH + NUB_WIDTH + NUB_WIDTH,NUB_HEIGHT + NUB_HEIGHT);
         }
         this._slider.x = SLIDER_X;
         this._slider.y = SLIDER_Y;
         gMainFrame.stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyDown,false,0,true);
         this._slider.addEventListener(MouseEvent.MOUSE_DOWN,this.sliderMouseDownHandler,false,0,true);
         this._slider.addEventListener(MouseEvent.MOUSE_MOVE,this.sliderMouseMoveHandler,false,0,true);
         this._slider.addEventListener(MouseEvent.MOUSE_OUT,this.sliderMouseOutHandler,false,0,true);
         this._slider.addEventListener(MouseEvent.MOUSE_UP,this.sliderMouseUpHandler,false,0,true);
         this._slider.addChild(this._nub);
         initParent.addChild(this._slider);
         this._value = new TextField();
         this._value.x = SLIDER_X + SLIDER_WIDTH + NUB_WIDTH + NUB_WIDTH + NUB_WIDTH;
         this._value.y = this._slider.y;
         this._value.width = 32;
         this._value.text = String(SLIDER_INIT);
         initParent.addChild(this._value);
         this._visible = initVisible;
         this._slider.visible = this._visible;
         this._value.visible = this._visible;
         this.valueChangedCallback = initValueChangedCallback;
      }
      
      public function toggleVisiblity() : void
      {
         this._nub.x = SLIDER_WIDTH * this._layerManager.bkg.scaleX;
         this._value.text = String(this._layerManager.bkg.scaleX);
         this._visible = !this._visible;
         this._slider.visible = this._visible;
         this._value.visible = this._visible;
      }
      
      private function sliderMouseDownHandler(param1:MouseEvent) : void
      {
         this._drag = true;
         this.sliderMouseMoveHandler(param1);
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Number = NaN;
         if(param1.keyCode == Keyboard.NUMPAD_ADD)
         {
            this._nub.x += 1;
            _loc2_ = true;
         }
         else if(param1.keyCode == Keyboard.NUMPAD_SUBTRACT)
         {
            --this._nub.x;
            _loc2_ = true;
         }
         else if(param1.keyCode == Keyboard.EQUAL)
         {
            this._nub.x += 0.1;
            _loc2_ = true;
         }
         else if(param1.keyCode == Keyboard.MINUS)
         {
            this._nub.x -= 0.1;
            _loc2_ = true;
         }
         if(_loc2_)
         {
            _loc3_ = this._nub.x * SLIDER_MAX / SLIDER_WIDTH;
            this._layerManager.bkg.scaleX = this._layerManager.bkg.scaleY = _loc3_;
            this._value.text = String(_loc3_);
         }
      }
      
      private function sliderMouseMoveHandler(param1:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(this._drag && param1.target is DisplayObject && this._slider.contains(DisplayObject(param1.target)))
         {
            param1.stopPropagation();
            _loc2_ = param1.localX;
            if(param1.target == this._nub)
            {
               _loc2_ += this._nub.x;
            }
            if(_loc2_ < 0)
            {
               _loc2_ = 0;
            }
            if(_loc2_ > SLIDER_WIDTH)
            {
               _loc2_ = SLIDER_WIDTH;
            }
            this._nub.x = _loc2_;
            _loc3_ = _loc2_ * SLIDER_MAX / SLIDER_WIDTH;
            this._layerManager.bkg.scaleX = this._layerManager.bkg.scaleY = _loc3_;
            this._value.text = String(_loc3_);
         }
      }
      
      private function sliderMouseOutHandler(param1:MouseEvent) : void
      {
         if(!param1.relatedObject || !this._slider.contains(param1.relatedObject))
         {
            this._drag = false;
         }
      }
      
      private function sliderMouseUpHandler(param1:MouseEvent) : void
      {
         this._drag = false;
      }
   }
}

