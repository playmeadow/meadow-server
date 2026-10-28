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
      
      public function GuiDropdown(initCurrDropDown:MovieClip)
      {
         var ido:DisplayObject = null;
         super();
         this.currDropDown = initCurrDropDown;
         this.dropdownTxt = this.currDropDown.dropdown_txt;
         this.dropdownBtn = this.currDropDown.dropdown_btn;
         this.dropdown = this.currDropDown._dropdown;
         this.scrollContent = this.dropdown.scroll_content;
         this.highlight = this.scrollContent.dropdown_h;
         this.scrollView = this.dropdown.scroll_view;
         this.scrollItems = [];
         for(var i:int = 0; i < this.scrollContent.numChildren; i++)
         {
            ido = this.scrollContent.getChildAt(i);
            if(ido.name.indexOf("_item") == 0)
            {
               ido.addEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler,false,0,true);
               this.scrollItems[int(ido.name.substr(5)) - 1] = ido;
            }
         }
      }
      
      public function init(gap:Number, defaultIdx:int = 0, defaultTxt:String = null) : void
      {
         this.dropdown.visible = false;
         if(this.scrollContent.height > this.scrollView.height)
         {
            this.scrollbar = new SBScrollbar();
            this.scrollbar.init(this.scrollContent,this.scrollView.width,this.scrollView.height,gap,"scrollbar2",this.scrollContent["_item2"].y - this.scrollContent["_item1"].y);
         }
         if(defaultIdx > 0)
         {
            if(Boolean(this.scrollbar))
            {
               this.scrollbar.scrollToElement(defaultIdx);
            }
            this.selectedIdx = defaultIdx;
            this.selectedTxt = this.scrollItems[defaultIdx];
            this.highlight.visible = true;
            this.highlight.y = this.selectedTxt.y + this.highlight.height * 0.5;
         }
         if(Boolean(defaultTxt))
         {
            this.selectedIdx = -1;
            this.dropdownTxt.text = defaultTxt;
         }
         else
         {
            this.selectedIdx = this.selectedIdx;
            this.selectedTxt = this.scrollItems[defaultIdx];
            this.dropdownTxt.text = this.selectedTxt.text;
         }
         this.scrollView.visible = false;
         this.dropdownBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.dropdownBtnMouseDownHandler,false,0,true);
         this.currDropDown.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler,false,0,true);
      }
      
      public function destroy() : void
      {
         var ido:DisplayObject = null;
         for(var i:int = 0; i < this.scrollContent.numChildren; i++)
         {
            ido = this.scrollContent.getChildAt(i);
            if(ido.name.indexOf("_item") == 0)
            {
               ido.removeEventListener(MouseEvent.MOUSE_DOWN,this.itemMouseDownHandler);
            }
         }
         this.scrollItems = null;
         if(Boolean(this.scrollbar))
         {
            this.scrollbar.destroy();
            this.scrollbar = null;
         }
         this.dropdownBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.dropdownBtnMouseDownHandler);
         this.currDropDown.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDownHandler);
      }
      
      public function reset(defaultIdx:int = 0, defaultText:String = null) : void
      {
         if(Boolean(this.scrollbar))
         {
            this.scrollbar.scrollToElement(defaultIdx);
         }
         if(Boolean(defaultIdx))
         {
            if(Boolean(this.scrollbar))
            {
               this.scrollbar.scrollToElement(defaultIdx);
            }
            this.selectedIdx = defaultIdx;
            this.selectedTxt = this.scrollItems[defaultIdx];
            this.highlight.visible = true;
            this.highlight.y = this.selectedTxt.y + this.highlight.height * 0.5;
         }
         if(Boolean(defaultText))
         {
            this.selectedIdx = -1;
            this.dropdownTxt.text = defaultText;
         }
         else
         {
            this.selectedIdx = this.selectedIdx;
            this.selectedTxt = this.scrollItems[defaultIdx];
            this.dropdownTxt.text = this.selectedTxt.text;
         }
      }
      
      public function closeDropdownSilent() : void
      {
         this.focusOutHandler(null);
         GuiSoundToggleButton(this.dropdownBtn).downToUpState();
      }
      
      private function keyDownHandler(k:KeyboardEvent) : void
      {
         if(k.keyCode == Keyboard.SPACE)
         {
            this.dropdownBtnMouseDownHandler(null);
         }
      }
      
      private function dropdownBtnMouseDownHandler(m:MouseEvent) : void
      {
         this.dropdown.visible = !this.dropdown.visible;
      }
      
      private function focusOutHandler(f:FocusEvent) : void
      {
         if(this.dropdown.visible)
         {
            this.dropdown.visible = false;
         }
      }
      
      private function itemMouseDownHandler(m:MouseEvent) : void
      {
         if(!this.blockItemDown)
         {
            this.selectedTxt = TextField(m.currentTarget);
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

