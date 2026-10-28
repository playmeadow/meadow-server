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
      
      public function init(param1:DisplayObjectContainer, param2:String = "", param3:Boolean = false, param4:Boolean = false, param5:Boolean = false, param6:Number = 800) : void
      {
         var initParent:DisplayObjectContainer = param1;
         var initTxtText:String = param2;
         var initVisible:Boolean = param3;
         var initSelectable:Boolean = param4;
         var initNoBackground:Boolean = param5;
         var initWidth:Number = param6;
         if(!initNoBackground)
         {
            _bg = new Sprite();
            with(_bg.graphics)
            {
               
               beginFill(BG_COLOR);
               drawRect(0,0,initWidth,TXTBOX_HEIGHT);
            }
            addChild(_bg);
         }
         _txt = new TextField();
         with(_txt)
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
         addChild(_txt);
         visible = initVisible;
         addEventListener("mouseDown",txtboxMouseDownHandler,false,0,true);
         initParent.addChild(this);
      }
      
      public function toggleVisiblity() : void
      {
         visible = !visible;
      }
      
      public function get txt() : TextField
      {
         return _txt;
      }
      
      public function get text() : String
      {
         return _txt.text;
      }
      
      public function set text(param1:String) : void
      {
         _txt.text = param1;
      }
      
      private function txtboxMouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

