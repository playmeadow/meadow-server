package room
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class DebugGUITextbox extends Sprite
   {
      
      private static const BG_COLOR:Number = 16777215;
      
      private static const TXT_COLOR:Number = 0;
      
      private static const TXTBOX_HEIGHT:Number = 22;
      
      private var _bg:Sprite;
      
      private var _txt:TextField;
      
      public function DebugGUITextbox()
      {
         super();
      }
      
      public function init(initParent:DisplayObjectContainer, initTxtText:String = "", initVisible:Boolean = false, initSelectable:Boolean = false, initNoBackground:Boolean = false, initWidth:Number = 800) : void
      {
         if(!initNoBackground)
         {
            this._bg = new Sprite();
            with(this._bg.graphics)
            {
               
               beginFill(BG_COLOR);
               drawRect(0,0,initWidth,TXTBOX_HEIGHT);
            }
            addChild(this._bg);
         }
         this._txt = new TextField();
         with(this._txt)
         {
            text = initTxtText;
            textColor = TXT_COLOR;
            width = initWidth;
            height = TXTBOX_HEIGHT;
            if(!initSelectable)
            {
               mouseEnabled = false;
               selectable = false;
            }
         }
         addChild(this._txt);
         visible = initVisible;
         addEventListener(MouseEvent.MOUSE_DOWN,this.txtboxMouseDownHandler,false,0,true);
         initParent.addChild(this);
      }
      
      public function toggleVisiblity() : void
      {
         visible = !visible;
      }
      
      public function get txt() : TextField
      {
         return this._txt;
      }
      
      public function get text() : String
      {
         return this._txt.text;
      }
      
      public function set text(setStr:String) : void
      {
         this._txt.text = setStr;
      }
      
      private function txtboxMouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
      }
   }
}

