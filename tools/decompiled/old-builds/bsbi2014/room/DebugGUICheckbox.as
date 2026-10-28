package room
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DebugGUICheckbox extends Sprite
   {
      
      private static const BOX_COLOR:Number = 16777215;
      
      private static const CHK_COLOR:Number = 0;
      
      private static const CHKBOX_WIDTH:Number = 20;
      
      private static const CHKBOX_HEIGHT:Number = 20;
      
      private var _box:Sprite;
      
      private var _check:Sprite;
      
      private var _label:TextField;
      
      private var _visible:Boolean;
      
      public var valueChangedCallback:Function;
      
      public function DebugGUICheckbox()
      {
         super();
      }
      
      public function init(initParent:DisplayObjectContainer, initValueChangedCallback:Function, initLabel:String, initChecked:Boolean = false, initVisible:Boolean = false) : void
      {
         this._box = new Sprite();
         this._check = new Sprite();
         with(this._box.graphics)
         {
            beginFill(BOX_COLOR);
            drawRect(0,0,CHKBOX_WIDTH,CHKBOX_HEIGHT);
            endFill();
         }
         with(this._check.graphics)
         {
            lineStyle(2,CHK_COLOR);
            moveTo(0,0);
            lineTo(CHKBOX_WIDTH,CHKBOX_HEIGHT);
         }
         addEventListener(MouseEvent.MOUSE_DOWN,this.chkboxMouseDownHandler,false,0,true);
         this._box.addChild(this._check);
         addChild(this._box);
         this._label = new TextField();
         this._label.x = CHKBOX_WIDTH;
         this._label.height = CHKBOX_HEIGHT;
         this._label.text = initLabel;
         this._label.selectable = false;
         addChild(this._label);
         this._check.visible = initChecked;
         visible = initVisible;
         this.valueChangedCallback = initValueChangedCallback;
         initParent.addChild(this);
      }
      
      public function get checked() : Boolean
      {
         return this._check.visible;
      }
      
      public function set checked(setChecked:Boolean) : void
      {
         this._check.visible = setChecked;
      }
      
      public function get label() : TextField
      {
         return this._label;
      }
      
      public function toggleVisiblity() : void
      {
         visible = !visible;
      }
      
      public function toggleChecked() : void
      {
         this._check.visible = !this._check.visible;
      }
      
      private function chkboxMouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         this._check.visible = !this._check.visible;
         if(this.valueChangedCallback != null)
         {
            this.valueChangedCallback(this._check.visible);
         }
      }
   }
}

