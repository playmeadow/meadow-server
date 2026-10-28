package gui
{
   import flash.display.MovieClip;
   
   public class GuiDropdownDay extends GuiDropdown
   {
      
      private var _numDaysShow:int = 31;
      
      public function GuiDropdownDay(param1:MovieClip)
      {
         super(param1);
      }
      
      public function updateDaysShown(param1:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         if(Boolean(scrollItems) && Boolean(scrollItems.length > 0) && this._numDaysShow != param1)
         {
            _loc2_ = scrollContent["_item2"].y - scrollContent["_item1"].y;
            _loc3_ = 0;
            _loc4_ = null;
            this._numDaysShow = param1;
            if(param1 == 30)
            {
               _loc3_ = _loc2_;
               if(selectedIdx > 29)
               {
                  selectedIdx = 29;
               }
            }
            else if(param1 == 29)
            {
               _loc3_ = _loc2_ * 2;
               if(selectedIdx > 28)
               {
                  selectedIdx = 28;
               }
            }
            else if(param1 == 28)
            {
               _loc3_ = _loc2_ * 3;
               if(selectedIdx > 27)
               {
                  selectedIdx = 27;
               }
            }
            if(selectedIdx == -1)
            {
               selectedIdx = 0;
               _loc4_ = "-";
            }
            this.rebuild(0.55,selectedIdx,_loc4_,_loc3_);
         }
      }
      
      private function rebuild(param1:Number, param2:int, param3:String, param4:Number) : void
      {
         dropdown.visible = false;
         if(scrollbar)
         {
            scrollbar.destroy();
            scrollbar = null;
         }
         if(scrollContent.height > scrollView.height)
         {
            scrollbar = new SBScrollbar();
            scrollbar.init(scrollContent,scrollView.width,scrollView.height,param1,"scrollbar2",scrollContent["_item2"].y - scrollContent["_item1"].y,0,param4 == -1 ? -1 : scrollContent.height - param4);
         }
         if(param2 > 0)
         {
            if(scrollbar)
            {
               scrollbar.scrollToElement(param2);
            }
            selectedIdx = param2;
            selectedTxt = scrollItems[param2];
            highlight.visible = true;
            highlight.y = selectedTxt.y + highlight.height * 0.5;
         }
         if(param3)
         {
            this.selectedIdx = -1;
            dropdownTxt.text = param3;
         }
         else
         {
            this.selectedIdx = selectedIdx;
            selectedTxt = scrollItems[param2];
            dropdownTxt.text = selectedTxt.text;
         }
      }
   }
}

