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
      
      public function GuiRadioButtonGroup(initCurrRadioButton:MovieClip)
      {
         var rbdo:DisplayObject = null;
         var rbdobc:DisplayObject = null;
         super();
         this.currRadioButton = initCurrRadioButton;
         if(this.currRadioButton.numChildren <= 1)
         {
            throw new Error("GuiRadioButtonGroup requires two or more radio buttons!");
         }
         this.radioButtons = [];
         var irb:int = 0;
         while(irb < this.currRadioButton.numChildren)
         {
            rbdo = this.currRadioButton.getChildAt(irb);
            this.radioButtons.push(rbdo);
            if(rbdo is MovieClip)
            {
               MovieClip(rbdo).stop();
            }
            rbdo.addEventListener(MouseEvent.CLICK,this.checkBoxClickHandler,false,0,true);
            rbdobc = rbdo["_circle"];
            rbdobc.visible = false;
            if(rbdobc is MovieClip)
            {
               MovieClip(rbdobc).stop();
            }
            irb++;
         }
      }
      
      public function destroy() : void
      {
         var rbdo:DisplayObject = null;
         var irb:int = 0;
         while(irb < this.currRadioButton.numChildren)
         {
            rbdo = this.currRadioButton.getChildAt(irb);
            rbdo.removeEventListener(MouseEvent.CLICK,this.checkBoxClickHandler);
            irb++;
         }
         this.radioButtons = null;
      }
      
      public function get selected() : int
      {
         return this.radioButtons.indexOf(this._selectedRadioButton);
      }
      
      public function set selected(setSelected:int) : void
      {
         var ssi:int = 0;
         var rbLength:int = int(this.radioButtons.length);
         if(setSelected == this.selected || setSelected < 0 || setSelected >= rbLength)
         {
            return;
         }
         while(ssi < rbLength)
         {
            if(ssi != setSelected)
            {
               this.radioButtons[ssi]["_circle"].visible = false;
            }
            ssi++;
         }
         this.setSelectedRadioButton(this.radioButtons[setSelected]);
      }
      
      public function reset() : void
      {
         for(var i:int = 0; i < this.radioButtons.length; i++)
         {
            this.radioButtons[i]["_circle"].visible = false;
         }
         this._selectedRadioButton = null;
      }
      
      private function setSelectedRadioButton(newSelected:DisplayObject) : void
      {
         this._selectedRadioButton = newSelected;
         this._selectedRadioButton["_circle"].visible = true;
      }
      
      private function checkBoxClickHandler(m:MouseEvent) : void
      {
         this.selected = this.radioButtons.indexOf(m.currentTarget);
         m.currentTarget.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
      }
   }
}

