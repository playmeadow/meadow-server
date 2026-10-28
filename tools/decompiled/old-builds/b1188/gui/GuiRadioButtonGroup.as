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
         var _loc3_:DisplayObject = null;
         var _loc4_:DisplayObject = null;
         super();
         this.currRadioButton = param1;
         if(this.currRadioButton.numChildren <= 1)
         {
            throw new Error("GuiRadioButtonGroup requires two or more radio buttons!");
         }
         this.radioButtons = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.currRadioButton.numChildren)
         {
            _loc3_ = this.currRadioButton.getChildAt(_loc2_);
            this.radioButtons.push(_loc3_);
            if(_loc3_ is MovieClip)
            {
               MovieClip(_loc3_).stop();
            }
            _loc3_.addEventListener(MouseEvent.CLICK,this.checkBoxClickHandler,false,0,true);
            _loc3_.addEventListener(MouseEvent.MOUSE_OVER,this.boxOverHandler,false,0,true);
            _loc3_.addEventListener(MouseEvent.MOUSE_OUT,this.boxOutHandler,false,0,true);
            if(_loc3_["mouse"])
            {
               _loc3_["mouse"].visible = false;
            }
            _loc4_ = _loc3_["_circle"];
            _loc4_.visible = false;
            if(_loc4_ is MovieClip)
            {
               MovieClip(_loc4_).stop();
            }
            _loc2_++;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.currRadioButton.numChildren)
         {
            _loc2_ = this.currRadioButton.getChildAt(_loc1_);
            _loc2_.removeEventListener(MouseEvent.CLICK,this.checkBoxClickHandler);
            _loc2_.removeEventListener(MouseEvent.MOUSE_OVER,this.boxOverHandler);
            _loc2_.removeEventListener(MouseEvent.MOUSE_OUT,this.boxOutHandler);
            _loc1_++;
         }
         this.radioButtons = null;
      }
      
      public function get selected() : int
      {
         return this.radioButtons.indexOf(this._selectedRadioButton);
      }
      
      public function set selected(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = int(this.radioButtons.length);
         if(param1 == this.selected || param1 < 0 || param1 >= _loc3_)
         {
            return;
         }
         while(_loc2_ < _loc3_)
         {
            if(_loc2_ != param1)
            {
               this.radioButtons[_loc2_]["_circle"].visible = false;
            }
            _loc2_++;
         }
         this.setSelectedRadioButton(this.radioButtons[param1]);
      }
      
      public function reset() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this.radioButtons.length)
         {
            this.radioButtons[_loc1_]["_circle"].visible = false;
            _loc1_++;
         }
         this._selectedRadioButton = null;
      }
      
      private function setSelectedRadioButton(param1:DisplayObject) : void
      {
         this._selectedRadioButton = param1;
         this._selectedRadioButton["_circle"].visible = true;
      }
      
      private function checkBoxClickHandler(param1:MouseEvent) : void
      {
         this.selected = this.radioButtons.indexOf(param1.currentTarget);
         param1.currentTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
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

