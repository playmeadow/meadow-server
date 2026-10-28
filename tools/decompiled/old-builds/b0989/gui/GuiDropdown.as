package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   
   public class GuiDropdown
   {
      
      public var dropdownTxt:TextField;
      
      public var dropdownBtn:MovieClip;
      
      public var dropdown:MovieClip;
      
      public var scrollContent:MovieClip;
      
      public var scrollView:MovieClip;
      
      public var highlight:MovieClip;
      
      public var scrollbar:SBScrollbar;
      
      public var selectedTxt:TextField;
      
      public var selectedIdx:int;
      
      public var scrollItems:Array;
      
      public var blockItemDown:Boolean;
      
      public var currDropDown:MovieClip;
      
      public function GuiDropdown(param1:MovieClip)
      {
         var _loc3_:DisplayObject = null;
         super();
         this.currDropDown = param1;
         this.dropdownTxt = this.currDropDown.dropdown_txt;
         this.dropdownBtn = this.currDropDown.dropdown_btn;
         this.dropdown = this.currDropDown._dropdown;
         this.scrollContent = this.dropdown.scroll_content;
         this.highlight = this.scrollContent.dropdown_h;
         this.scrollView = this.dropdown.scroll_view;
         this.scrollItems = [];
         var _loc2_:int = 0;
         while(_loc2_ < this.scrollContent.numChildren)
         {
            _loc3_ = this.scrollContent.getChildAt(_loc2_);
            if(_loc3_.name.indexOf("_item") == 0)
            {
               _loc3_.addEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler,false,0,true);
               this.scrollItems[int(_loc3_.name.substr(5)) - 1] = _loc3_;
            }
            _loc2_++;
         }
      }
      
      public function init(param1:Number, param2:int = 0, param3:String = null) : void
      {
         this.dropdown.visible = false;
         if(this.scrollContent.height > this.scrollView.height)
         {
            this.scrollbar = new SBScrollbar();
            this.scrollbar.init(this.scrollContent,this.scrollView.width,this.scrollView.height,param1,"scrollbar2",this.scrollContent["_item2"].y - this.scrollContent["_item1"].y);
         }
         if(param2 > 0)
         {
            if(this.scrollbar)
            {
               this.scrollbar.scrollToElement(param2);
            }
            this.selectedIdx = param2;
            this.selectedTxt = this.scrollItems[param2];
            this.highlight.visible = true;
            this.highlight.y = this.selectedTxt.y + this.highlight.height * 0.5;
         }
         if(param3)
         {
            this.selectedIdx = -1;
            this.dropdownTxt.text = param3;
         }
         else
         {
            this.selectedIdx = this.selectedIdx;
            this.selectedTxt = this.scrollItems[param2];
            this.dropdownTxt.text = this.selectedTxt.text;
         }
         this.scrollView.visible = false;
         this.dropdownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.dropdownBtnMouseDownHandler,false,0,true);
         this.currDropDown.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
      }
      
      public function destroy() : void
      {
         var _loc2_:DisplayObject = null;
         var _loc1_:int = 0;
         while(_loc1_ < this.scrollContent.numChildren)
         {
            _loc2_ = this.scrollContent.getChildAt(_loc1_);
            if(_loc2_.name.indexOf("_item") == 0)
            {
               _loc2_.removeEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler);
            }
            _loc1_++;
         }
         this.scrollItems = null;
         if(this.scrollbar)
         {
            this.scrollbar.destroy();
            this.scrollbar = null;
         }
         this.dropdownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.dropdownBtnMouseDownHandler);
         this.currDropDown.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
      }
      
      public function reset(param1:int = 0, param2:String = null) : void
      {
         if(this.scrollbar)
         {
            this.scrollbar.scrollToElement(param1);
         }
         if(param1)
         {
            if(this.scrollbar)
            {
               this.scrollbar.scrollToElement(param1);
            }
            this.selectedIdx = param1;
            this.selectedTxt = this.scrollItems[param1];
            this.highlight.visible = true;
            this.highlight.y = this.selectedTxt.y + this.highlight.height * 0.5;
         }
         if(param2)
         {
            this.selectedIdx = -1;
            this.dropdownTxt.text = param2;
         }
         else
         {
            this.selectedIdx = this.selectedIdx;
            this.selectedTxt = this.scrollItems[param1];
            this.dropdownTxt.text = this.selectedTxt.text;
         }
      }
      
      public function closeDropdownSilent() : void
      {
         this.focusOutHandler(null);
         GuiSoundToggleButton(this.dropdownBtn).downToUpState();
      }
      
      private function keyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.SPACE)
         {
            this.dropdownBtnMouseDownHandler(null);
         }
      }
      
      private function dropdownBtnMouseDownHandler(param1:MouseEvent) : void
      {
         this.dropdown.visible = !this.dropdown.visible;
      }
      
      private function focusOutHandler(param1:FocusEvent) : void
      {
         if(this.dropdown.visible)
         {
            this.dropdown.visible = false;
         }
      }
      
      private function itemMouseDownHandler(param1:MouseEvent) : void
      {
         if(!this.blockItemDown)
         {
            this.selectedTxt = TextField(param1.currentTarget);
            this.selectedIdx = int(this.selectedTxt.name.substr(5)) - 1;
            this.dropdownTxt.text = this.selectedTxt.text;
            this.highlight.visible = true;
            this.highlight.y = this.selectedTxt.y + this.highlight.height * 0.5;
            this.dropdownBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            this.dropdownBtn.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT));
         }
      }
   }
}

