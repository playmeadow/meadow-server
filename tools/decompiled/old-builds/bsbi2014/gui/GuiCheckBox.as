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
      
      public var grayBox:MovieClip;
      
      public var check:MovieClip;
      
      public var chkTxt:TextField;
      
      private var _currCheckBox:MovieClip;
      
      private var _checkCallback:Function;
      
      private var _glow:GlowFilter;
      
      public function GuiCheckBox(initAsset:MovieClip, initCheckCallback:Function = null)
      {
         super();
         this._currCheckBox = initAsset;
         this._checkCallback = initCheckCallback;
      }
      
      public function init(initChkTxt:TextField = null) : void
      {
         this.chkTxt = initChkTxt;
         this.box = this._currCheckBox["_box"];
         this.check = this.box["_check"];
         this.grayBox = this._currCheckBox["_boxGray"];
         if(Boolean(this.grayBox))
         {
            this.grayBox.visible = false;
         }
         if(!(Boolean(this.box) && Boolean(this.check)))
         {
            throw new Error("GuiCheckBox is missing parts or they are named incorrectly!");
         }
         this.box.stop();
         this.check.stop();
         this._currCheckBox.tabEnabled = true;
         this._glow = new GlowFilter(5562619,1,6,6,2,2);
         this._currCheckBox.addEventListener(KeyboardEvent.KEY_DOWN,this.checkBoxKeyDownHandler,false,0,true);
         this._currCheckBox.addEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler,false,0,true);
         this._currCheckBox.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         this._currCheckBox.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         if(this.chkTxt != null)
         {
            this.chkTxt.addEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler,false,0,true);
            this.chkTxt.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
            this.chkTxt.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
         }
      }
      
      public function destroy() : void
      {
         this._currCheckBox.removeEventListener(KeyboardEvent.KEY_DOWN,this.checkBoxKeyDownHandler);
         this._currCheckBox.removeEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler);
         this._currCheckBox.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         this._currCheckBox.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         if(this.chkTxt != null)
         {
            this.chkTxt.removeEventListener(MouseEvent.MOUSE_DOWN,this.checkBoxClickHandler);
            this.chkTxt.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            this.chkTxt.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         }
         this._currCheckBox = null;
         this._checkCallback = null;
      }
      
      public function get gray() : Boolean
      {
         if(Boolean(this.grayBox))
         {
            return this.grayBox.visible;
         }
         return false;
      }
      
      public function set gray(setGrayed:Boolean) : void
      {
         if(Boolean(this.grayBox))
         {
            this.grayBox.visible = setGrayed;
            this.box.visible = !setGrayed;
         }
      }
      
      public function get checked() : Boolean
      {
         return this.check.visible;
      }
      
      public function set checked(setChecked:Boolean) : void
      {
         this.check.visible = setChecked;
      }
      
      private function checkBoxKeyDownHandler(k:KeyboardEvent) : void
      {
         if(!this.gray)
         {
            if(k.keyCode == Keyboard.SPACE)
            {
               this.checked = !this.checked;
            }
            if(this._checkCallback != null)
            {
               this._checkCallback();
            }
         }
      }
      
      private function checkBoxClickHandler(m:MouseEvent) : void
      {
         if(!this.gray)
         {
            this.checked = !this.checked;
            if(this._checkCallback != null)
            {
               this._checkCallback();
            }
         }
      }
      
      private function onRollOver(evt:MouseEvent) : void
      {
         if(!this.gray)
         {
            this.box.filters = [this._glow];
            if(Boolean(this.chkTxt))
            {
               this.chkTxt.filters = [this._glow];
            }
         }
      }
      
      private function onRollOut(evt:MouseEvent) : void
      {
         if(!this.gray)
         {
            this.box.filters = null;
            if(Boolean(this.chkTxt))
            {
               this.chkTxt.filters = null;
            }
         }
      }
   }
}

