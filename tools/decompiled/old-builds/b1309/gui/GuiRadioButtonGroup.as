package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class GuiRadioButtonGroup
   {
      
      public var radioButtons:Array;
      
      public var currRadioButton:MovieClip;
      
      private var _selectedRadioButton:DisplayObject;
      
      public function GuiRadioButtonGroup(param1:MovieClip)
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:DisplayObject = null;
         super();
         currRadioButton = param1;
         if(currRadioButton.numChildren <= 1)
         {
            throw new Error("GuiRadioButtonGroup requires two or more radio buttons!");
         }
         radioButtons = [];
         var _loc3_:int = 0;
         while(_loc3_ < currRadioButton.numChildren)
         {
            _loc4_ = currRadioButton.getChildAt(_loc3_);
            radioButtons.push(_loc4_);
            if(_loc4_ is MovieClip)
            {
               MovieClip(_loc4_).stop();
            }
            _loc4_.addEventListener("click",checkBoxClickHandler,false,0,true);
            _loc4_.addEventListener("mouseOver",boxOverHandler,false,0,true);
            _loc4_.addEventListener("mouseOut",boxOutHandler,false,0,true);
            if(_loc4_["mouse"])
            {
               _loc4_["mouse"].visible = false;
            }
            _loc2_ = _loc4_["_circle"];
            _loc2_.visible = false;
            if(_loc2_ is MovieClip)
            {
               MovieClip(_loc2_).stop();
            }
            _loc3_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < currRadioButton.numChildren)
         {
            _loc2_ = currRadioButton.getChildAt(_loc1_);
            _loc2_.removeEventListener("click",checkBoxClickHandler);
            _loc2_.removeEventListener("mouseOver",boxOverHandler);
            _loc2_.removeEventListener("mouseOut",boxOutHandler);
            _loc1_++;
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
         selected = radioButtons.indexOf(param1.currentTarget);
         param1.currentTarget.dispatchEvent(new MouseEvent("mouseDown"));
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

