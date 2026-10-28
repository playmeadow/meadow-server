package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class GuiRadioButtonSingle
   {
      
      public var currRadioButton:MovieClip;
      
      public var bg:MovieClip;
      
      public var chkTxt:TextField;
      
      public var circle:MovieClip;
      
      public var grayBg:MovieClip;
      
      private var _selectedRadioButton:DisplayObject;
      
      private var _glow:GlowFilter;
      
      public function GuiRadioButtonSingle(param1:MovieClip, param2:TextField = null)
      {
         super();
         this.currRadioButton = param1;
         this.chkTxt = param2;
         this.bg = this.currRadioButton["bg"];
         this.circle = this.currRadioButton["_circle"];
         this.grayBg = this.currRadioButton["bgGray"];
         this.gray = false;
         this.circle.visible = false;
         this._glow = new GlowFilter(5562619,1,6,6,2,2);
         this.currRadioButton.addEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler,false,0,true);
         this.currRadioButton.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this.currRadioButton.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         if(this.chkTxt)
         {
            this.chkTxt.addEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler,false,0,true);
            this.chkTxt.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            this.chkTxt.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         }
      }
      
      public function destroy() : void
      {
         this.currRadioButton.removeEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler);
         this.currRadioButton.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this.currRadioButton.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         if(this.chkTxt)
         {
            this.chkTxt.removeEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler);
            this.chkTxt.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.chkTxt.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         }
      }
      
      public function get gray() : Boolean
      {
         if(this.grayBg)
         {
            return this.grayBg.visible;
         }
         return false;
      }
      
      public function set gray(param1:Boolean) : void
      {
         if(this.grayBg)
         {
            this.grayBg.visible = param1;
            this.bg.visible = !param1;
            this.circle.visible = !param1;
         }
      }
      
      public function get selected() : Boolean
      {
         return this.circle.visible;
      }
      
      public function set selected(param1:Boolean) : void
      {
         this.circle.visible = param1;
      }
      
      private function checkBoxClickHandler(param1:MouseEvent) : void
      {
         if(!this.gray)
         {
            this.selected = !this.selected;
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         if(!this.gray)
         {
            this.bg.filters = [this._glow];
            if(this.chkTxt)
            {
               this.chkTxt.filters = [this._glow];
            }
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         if(!this.gray)
         {
            this.bg.filters = null;
            if(this.chkTxt)
            {
               this.chkTxt.filters = null;
            }
         }
      }
   }
}

