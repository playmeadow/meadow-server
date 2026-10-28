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
      
      public function SBYesNoPopup(init_parent:DisplayObjectContainer, init_message:String = null, init_darken:Boolean = true, init_confirmCallback:Function = null, init_passbackObject:Object = null, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = false, init_title:String = null, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_children:Array = null)
      {
         this._confirmCallback = init_confirmCallback;
         this._passbackObject = init_passbackObject;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var skin:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var content:MovieClip = GETDEFINITIONBYNAME("YesNoPopupContent");
         this._yesBtn = content.yesBtn;
         this._noBtn = content.noBtn;
         this._yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onYesNoBtn,false,0,true);
         this._noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onYesNoBtn,false,0,true);
         _resizeCallback = this.onResize;
         super(init_parent,init_message,init_darken,content,skin,autoOpen,init_enabled,init_modal,init_draggable,init_title,init_x,init_y,init_width,init_height,init_children);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleYesNoKeyDown,false,0,true);
      }
      
      override public function destroy() : void
      {
         if(Boolean(stage))
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
      
      private function handleYesNoKeyDown(event:KeyboardEvent) : void
      {
         switch(event.keyCode)
         {
            case Keyboard.ENTER:
            case Keyboard.SPACE:
               event.stopPropagation();
               this.handleYesNo(true);
               break;
            case Keyboard.BACKSPACE:
            case Keyboard.DELETE:
            case Keyboard.ESCAPE:
               event.stopPropagation();
               this.handleYesNo(false);
         }
      }
      
      private function onYesNoBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.handleYesNo(evt.currentTarget == this._yesBtn);
      }
      
      private function handleYesNo(onYes:Boolean) : void
      {
         var fileRef:FileReference = null;
         var o:Object = null;
         this.destroy();
         if(Boolean(onYes) && Boolean(this._passbackObject) && this._passbackObject.hasOwnProperty("FileReference"))
         {
            fileRef = new FileReference();
            fileRef.save(this._passbackObject.ImageData,this._passbackObject.SaveName);
         }
         if(this._confirmCallback != null)
         {
            o = {
               "status":onYes,
               "passback":this._passbackObject
            };
            this._confirmCallback(o);
         }
      }
   }
}

