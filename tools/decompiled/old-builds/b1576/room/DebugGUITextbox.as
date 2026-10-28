package room
{
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class DebugGUITextbox extends Sprite
   {
      
      private static const BG_HEADER_COLOR:Number = 0;
      
      private static const BG_COLOR:Number = 6710886;
      
      private static const BG_ALPHA:Number = 0.6;
      
      private static const TXT_FONT:String = "Lucida Console";
      
      private static const TXT_COLOR:Number = 16777215;
      
      private static const TITLE_ROW_HEIGHT:int = 15;
      
      private var _parent:DisplayObjectContainer;
      
      private var _titleTextField:TextField;
      
      private var _textField:TextField;
      
      public function DebugGUITextbox(param1:DisplayObjectContainer, param2:String = "", param3:String = "", param4:Boolean = false, param5:Boolean = false, param6:Boolean = true, param7:Number = 800, param8:Number = 15)
      {
         super();
         var _loc9_:Boolean = param3.length > 0;
         if(param6)
         {
            initBackgroundLayer(param7,param8,_loc9_);
         }
         if(_loc9_)
         {
            initTitleLayer(param3,param7,param6);
         }
         initTextLayer(param2,param7,param8,param5,_loc9_);
         visible = param4;
         updateParent(false,param1);
      }
      
      private function initBackgroundLayer(param1:Number, param2:Number, param3:Boolean) : void
      {
         var _loc4_:Sprite = new Sprite();
         _loc4_.alpha = 0.6;
         var _loc6_:int = 0;
         var _loc5_:int = param2;
         if(param3)
         {
            _loc6_ += 15;
            _loc5_ -= 15;
         }
         _loc4_.graphics.beginFill(6710886);
         _loc4_.graphics.drawRect(0,_loc6_,param1,_loc5_);
         addChild(_loc4_);
      }
      
      private function initTitleLayer(param1:String, param2:Number, param3:Boolean) : void
      {
         var _loc5_:Sprite = null;
         if(param3)
         {
            _loc5_ = new Sprite();
            _loc5_.alpha = 0.6;
            _loc5_.graphics.beginFill(0);
            _loc5_.graphics.drawRect(0,0,param2,15);
            addChild(_loc5_);
         }
         _titleTextField = new TextField();
         var _loc4_:TextFormat = new TextFormat();
         _loc4_.font = "Lucida Console";
         _loc4_.size = 12;
         _loc4_.bold = true;
         _titleTextField.defaultTextFormat = _loc4_;
         _titleTextField.text = param1;
         _titleTextField.textColor = 16777215;
         _titleTextField.width = param2;
         _titleTextField.height = 15;
         _titleTextField.mouseEnabled = false;
         _titleTextField.selectable = false;
         addChild(_titleTextField);
      }
      
      private function initTextLayer(param1:String, param2:Number, param3:Number, param4:Boolean, param5:Boolean) : void
      {
         _textField = new TextField();
         var _loc6_:TextFormat = new TextFormat();
         _loc6_.font = "Lucida Console";
         _loc6_.size = 10;
         _textField.defaultTextFormat = _loc6_;
         _textField.text = param1;
         _textField.textColor = 16777215;
         _textField.width = param2;
         _textField.height = param3;
         if(param5)
         {
            _textField.y = 15;
            _textField.height -= 15;
         }
         if(!param4)
         {
            _textField.mouseEnabled = false;
            _textField.selectable = false;
         }
         else
         {
            addEventListener("mouseDown",stopPropagationMouseEventHandler,false,0,true);
         }
         addChild(_textField);
      }
      
      private function updateParent(param1:Boolean, param2:DisplayObjectContainer = null) : void
      {
         var _loc4_:Boolean = false;
         var _loc3_:Boolean = _parent == null;
         if(param2 && param2 != _parent)
         {
            if(_parent && param1)
            {
               _parent.removeChild(this);
            }
            _parent = param2;
            _loc4_ = true;
         }
         if(_parent)
         {
            if(visible)
            {
               _parent.addChild(this);
            }
            else if(!_loc3_ && !_loc4_)
            {
               _parent.removeChild(this);
            }
         }
      }
      
      public function setVisibility(param1:Boolean, param2:DisplayObjectContainer = null) : void
      {
         var _loc3_:Boolean = visible;
         visible = param1;
         updateParent(visible,param2);
      }
      
      public function toggleVisiblity(param1:DisplayObjectContainer = null) : Boolean
      {
         var _loc2_:Boolean = visible;
         visible = !visible;
         updateParent(_loc2_,param1);
         return visible;
      }
      
      public function get textField() : TextField
      {
         return _textField;
      }
      
      public function get text() : String
      {
         return _textField.text;
      }
      
      public function set text(param1:String) : void
      {
         _textField.text = param1;
      }
      
      public function get titleTextField() : TextField
      {
         return _titleTextField;
      }
      
      private function stopPropagationMouseEventHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
   }
}

