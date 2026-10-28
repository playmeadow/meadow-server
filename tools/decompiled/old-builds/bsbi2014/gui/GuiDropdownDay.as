package gui
{
   import flash.display.MovieClip;
   
   public class GuiDropdownDay extends GuiDropdown
   {
      
      private var _numDaysShow:int = 31;
      
      public function GuiDropdownDay(initCurrDropDown:MovieClip)
      {
         super(initCurrDropDown);
      }
      
      public function updateDaysShown(numDaysToShow:int) : void
      {
         var itemHeight:int = 0;
         var scrollHeightDecrement:int = 0;
         var defaultTxt:String = null;
         if(Boolean(scrollItems) && Boolean(scrollItems.length > 0) && this._numDaysShow != numDaysToShow)
         {
            itemHeight = scrollContent["_item2"].y - scrollContent["_item1"].y;
            scrollHeightDecrement = 0;
            defaultTxt = null;
            this._numDaysShow = numDaysToShow;
            if(numDaysToShow == 30)
            {
               scrollHeightDecrement = itemHeight;
               if(selectedIdx > 29)
               {
                  selectedIdx = 29;
               }
            }
            else if(numDaysToShow == 29)
            {
               scrollHeightDecrement = itemHeight * 2;
               if(selectedIdx > 28)
               {
                  selectedIdx = 28;
               }
            }
            else if(numDaysToShow == 28)
            {
               scrollHeightDecrement = itemHeight * 3;
               if(selectedIdx > 27)
               {
                  selectedIdx = 27;
               }
            }
            if(selectedIdx == -1)
            {
               selectedIdx = 0;
               defaultTxt = "-";
            }
            this.rebuild(0.55,selectedIdx,defaultTxt,scrollHeightDecrement);
         }
      }
      
      private function rebuild(gap:Number, defaultIdx:int, defaultTxt:String, scrollHeightDecrement:Number) : void
      {
         dropdown.visible = false;
         if(Boolean(scrollbar))
         {
            scrollbar.destroy();
            scrollbar = null;
         }
         if(scrollContent.height > scrollView.height)
         {
            scrollbar = new SBScrollbar();
            scrollbar.init(scrollContent,scrollView.width,scrollView.height,gap,"scrollbar2",scrollContent["_item2"].y - scrollContent["_item1"].y,0,scrollHeightDecrement == -1 ? -1 : scrollContent.height - scrollHeightDecrement);
         }
         if(defaultIdx > 0)
         {
            if(Boolean(scrollbar))
            {
               scrollbar.scrollToElement(defaultIdx);
            }
            selectedIdx = defaultIdx;
            selectedTxt = scrollItems[defaultIdx];
            highlight.visible = true;
            highlight.y = selectedTxt.y + highlight.height * 0.5;
         }
         if(Boolean(defaultTxt))
         {
            this.selectedIdx = -1;
            dropdownTxt.text = defaultTxt;
         }
         else
         {
            this.selectedIdx = selectedIdx;
            selectedTxt = scrollItems[defaultIdx];
            dropdownTxt.text = selectedTxt.text;
         }
      }
   }
}

