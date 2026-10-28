package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.net.FileReference;
   import flash.ui.Keyboard;
   
   public dynamic class SBYesNoPopup extends SBStandardPopup
   {
      
      private var _yesBtn:MovieClip;
      
      private var _noBtn:MovieClip;
      
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      public function SBYesNoPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Object = null, param6:Boolean = true, param7:Boolean = true, param8:Boolean = false, param9:Boolean = false, param10:String = null, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Array = null)
      {
         this._confirmCallback = param4;
         this._passbackObject = param5;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var _loc16_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var _loc17_:MovieClip = GETDEFINITIONBYNAME("YesNoPopupContent");
         this._yesBtn = _loc17_.yesBtn;
         this._noBtn = _loc17_.noBtn;
         this._yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onYesNoBtn,false,0,true);
         this._noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onYesNoBtn,false,0,true);
         _resizeCallback = this.onResize;
         super(param1,param2,param3,_loc17_,_loc16_,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleYesNoKeyDown,false,0,true);
      }
      
      override public function destroy() : void
      {
         if(stage)
         {
            stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.handleYesNoKeyDown);
         }
         this._yesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onYesNoBtn);
         this._noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onYesNoBtn);
         super.destroy();
      }
      
      private function onResize() : void
      {
         this._yesBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
         this._noBtn.y = this._yesBtn.y;
      }
      
      private function handleYesNoKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case Keyboard.ENTER:
            case Keyboard.SPACE:
               param1.stopPropagation();
               this.handleYesNo(true);
               break;
            case Keyboard.BACKSPACE:
            case Keyboard.DELETE:
            case Keyboard.ESCAPE:
               param1.stopPropagation();
               this.handleYesNo(false);
         }
      }
      
      private function onYesNoBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.handleYesNo(param1.currentTarget == this._yesBtn);
      }
      
      private function handleYesNo(param1:Boolean) : void
      {
         var _loc2_:FileReference = null;
         var _loc3_:Object = null;
         this.destroy();
         if(Boolean(param1) && Boolean(this._passbackObject) && this._passbackObject.hasOwnProperty("FileReference"))
         {
            _loc2_ = new FileReference();
            _loc2_.save(this._passbackObject.ImageData,this._passbackObject.SaveName);
         }
         if(this._confirmCallback != null)
         {
            _loc3_ = {
               "status":param1,
               "passback":this._passbackObject
            };
            this._confirmCallback(_loc3_);
         }
      }
   }
}

