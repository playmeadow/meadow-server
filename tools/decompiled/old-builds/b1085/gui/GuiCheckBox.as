package gui
{
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.ui.Keyboard;
   
   public class GuiCheckBox
   {
      
      public var box:MovieClip;
      
      public var check:MovieClip;
      
      public var chkTxt:TextField;
      
      private var _currCheckBox:MovieClip;
      
      private var _checkCallback:Function;
      
      private var _glow:GlowFilter;
      
      public function GuiCheckBox(param1:MovieClip, param2:Function = null)
      {
         super();
         this._currCheckBox = param1;
         this._checkCallback = param2;
      }
      
      public function init(param1:TextField = null) : void
      {
         this.chkTxt = param1;
         this.box = this._currCheckBox["_box"];
         this.check = this.box["_check"];
         if(!(Boolean(this.box) && Boolean(this.check)))
         {
            throw new Error("GuiCheckBox is missing parts or they are named incorrectly!");
         }
         this.box.stop();
         this.check.stop();
         this._currCheckBox.tabEnabled = true;
         this._glow = new GlowFilter(5562619,1,6,6,2,2);
         this._currCheckBox.addEventListener(KeyboardEvent.KEY_DOWN,this.checkBoxKeyDownHandler,false,0,true);
         this._currCheckBox.addEventListener(MouseEvent.CLICK,this.checkBoxClickHandler,false,0,true);
         this._currCheckBox.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this._currCheckBox.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         if(this.chkTxt != null)
         {
            this.chkTxt.addEventListener(MouseEvent.CLICK,this.checkBoxClickHandler,false,0,true);
            this.chkTxt.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            this.chkTxt.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         }
      }
      
      public function destroy() : void
      {
         this._currCheckBox.removeEventListener(KeyboardEvent.KEY_DOWN,this.checkBoxKeyDownHandler);
         this._currCheckBox.removeEventListener(MouseEvent.CLICK,this.checkBoxClickHandler);
         this._currCheckBox.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this._currCheckBox.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         if(this.chkTxt != null)
         {
            this.chkTxt.removeEventListener(MouseEvent.CLICK,this.checkBoxClickHandler);
            this.chkTxt.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.chkTxt.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         }
         this._currCheckBox = null;
         this._checkCallback = null;
      }
      
      public function get checked() : Boolean
      {
         return this.check.visible;
      }
      
      public function set checked(param1:Boolean) : void
      {
         this.check.visible = param1;
      }
      
      private function checkBoxKeyDownHandler(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == Keyboard.SPACE)
         {
            this.checked = !this.checked;
         }
         if(this._checkCallback != null)
         {
            this._checkCallback();
         }
      }
      
      private function checkBoxClickHandler(param1:MouseEvent) : void
      {
         this.checked = !this.checked;
         if(this._checkCallback != null)
         {
            this._checkCallback();
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         this.box.filters = [this._glow];
         if(this.chkTxt)
         {
            this.chkTxt.filters = [this._glow];
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         this.box.filters = null;
         if(this.chkTxt)
         {
            this.chkTxt.filters = null;
         }
      }
   }
}

