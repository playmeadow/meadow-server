package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GuiRadioButtonGroup
   {
      
      public var radioButtons:Array;
      
      private var _currRadioButtons:Object;
      
      private var _numButtons:int;
      
      private var _selectedRadioButton:DisplayObject;
      
      public function GuiRadioButtonGroup(param1:Object)
      {
         var _loc4_:int = 0;
         var _loc3_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         super();
         _currRadioButtons = param1;
         if(_currRadioButtons is Array)
         {
            if(_currRadioButtons.length <= 1)
            {
               throw new Error("GuiRadioButtonGroup requires two or more radio buttons!");
            }
            _numButtons = _currRadioButtons.length;
         }
         else
         {
            if(!(_currRadioButtons is MovieClip))
            {
               throw new Error("GuiRadioButtonGroup requires buttons to be array or movieclip!");
            }
            if(_currRadioButtons.numChildren <= 1)
            {
               throw new Error("GuiRadioButtonGroup requires two or more radio buttons!");
            }
            _numButtons = _currRadioButtons.numChildren;
         }
         radioButtons = [];
         _loc4_ = 0;
         while(_loc4_ < _numButtons)
         {
            _loc3_ = _currRadioButtons is Array ? _currRadioButtons[_loc4_] : _currRadioButtons.getChildAt(_loc4_);
            radioButtons.push(_loc3_);
            if(_loc3_ is MovieClip)
            {
               MovieClip(_loc3_).stop();
            }
            _loc3_.addEventListener("click",checkBoxClickHandler,false,0,true);
            _loc3_.addEventListener("mouseOver",boxOverHandler,false,0,true);
            _loc3_.addEventListener("mouseOut",boxOutHandler,false,0,true);
            if(_loc3_["mouse"])
            {
               _loc3_["mouse"].visible = false;
            }
            _loc2_ = _loc3_["_circle"];
            _loc2_.visible = false;
            if(_loc2_ is MovieClip)
            {
               MovieClip(_loc2_).stop();
            }
            _loc4_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:int = 0;
         var _loc1_:DisplayObject = null;
         _loc2_ = 0;
         while(_loc2_ < _numButtons)
         {
            _loc1_ = _currRadioButtons is Array ? _currRadioButtons[_loc2_] : _currRadioButtons.getChildAt(_loc2_);
            _loc1_.removeEventListener("click",checkBoxClickHandler);
            _loc1_.removeEventListener("mouseOver",boxOverHandler);
            _loc1_.removeEventListener("mouseOut",boxOutHandler);
            _loc2_++;
         }
         radioButtons = null;
      }
      
      public function get selected() : int
      {
         return radioButtons.indexOf(_selectedRadioButton);
      }
      
      public function set selected(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(radioButtons.length);
         if(param1 == selected || param1 < 0 || param1 >= _loc3_)
         {
            return;
         }
         while(_loc2_ < _loc3_)
         {
            if(_loc2_ != param1)
            {
               radioButtons[_loc2_]["_circle"].visible = false;
            }
            _loc2_++;
         }
         setSelectedRadioButton(radioButtons[param1]);
      }
      
      public function get currRadioButton() : Object
      {
         return _currRadioButtons;
      }
      
      public function reset() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < radioButtons.length)
         {
            radioButtons[_loc1_]["_circle"].visible = false;
            _loc1_++;
         }
         _selectedRadioButton = null;
      }
      
      private function setSelectedRadioButton(param1:DisplayObject) : void
      {
         _selectedRadioButton = param1;
         _selectedRadioButton["_circle"].visible = true;
      }
      
      private function checkBoxClickHandler(param1:MouseEvent) : void
      {
         if(radioButtons)
         {
            selected = radioButtons.indexOf(param1.currentTarget);
            param1.currentTarget.dispatchEvent(new MouseEvent("mouseDown"));
         }
      }
      
      private function boxOverHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget.mouse)
         {
            param1.currentTarget.mouse.visible = true;
         }
      }
      
      private function boxOutHandler(param1:MouseEvent) : void
      {
         if(param1.currentTarget.mouse)
         {
            param1.currentTarget.mouse.visible = false;
         }
      }
   }
}

