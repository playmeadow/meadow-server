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
      
      public function init(initParent:Object, initValueChangedCallback:Function, initVisible:Boolean = false) : void
      {
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
      
      private function sliderMouseDownHandler(m:MouseEvent) : void
      {
         this._drag = true;
         this.sliderMouseMoveHandler(m);
      }
      
      private function onKeyDown(evt:KeyboardEvent) : void
      {
         var hasChanged:Boolean = false;
         var sliderVal:Number = NaN;
         if(evt.keyCode == Keyboard.NUMPAD_ADD)
         {
            this._nub.x += 1;
            hasChanged = true;
         }
         else if(evt.keyCode == Keyboard.NUMPAD_SUBTRACT)
         {
            this._nub.x -= 1;
            hasChanged = true;
         }
         else if(evt.keyCode == Keyboard.EQUAL)
         {
            this._nub.x += 0.1;
            hasChanged = true;
         }
         else if(evt.keyCode == Keyboard.MINUS)
         {
            this._nub.x -= 0.1;
            hasChanged = true;
         }
         if(hasChanged)
         {
            sliderVal = this._nub.x * SLIDER_MAX / SLIDER_WIDTH;
            this._layerManager.bkg.scaleX = this._layerManager.bkg.scaleY = sliderVal;
            this._value.text = String(sliderVal);
         }
      }
      
      private function sliderMouseMoveHandler(m:MouseEvent) : void
      {
         var sliderX:Number = NaN;
         var sliderVal:Number = NaN;
         if(this._drag && m.target is DisplayObject && this._slider.contains(DisplayObject(m.target)))
         {
            m.stopPropagation();
            sliderX = m.localX;
            if(m.target == this._nub)
            {
               sliderX += this._nub.x;
            }
            if(sliderX < 0)
            {
               sliderX = 0;
            }
            if(sliderX > SLIDER_WIDTH)
            {
               sliderX = SLIDER_WIDTH;
            }
            this._nub.x = sliderX;
            sliderVal = sliderX * SLIDER_MAX / SLIDER_WIDTH;
            this._layerManager.bkg.scaleX = this._layerManager.bkg.scaleY = sliderVal;
            this._value.text = String(sliderVal);
         }
      }
      
      private function sliderMouseOutHandler(m:MouseEvent) : void
      {
         if(!m.relatedObject || !this._slider.contains(m.relatedObject))
         {
            this._drag = false;
         }
      }
      
      private function sliderMouseUpHandler(m:MouseEvent) : void
      {
         this._drag = false;
      }
   }
}

