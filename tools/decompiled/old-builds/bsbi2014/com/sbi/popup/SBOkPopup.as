package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.ui.Keyboard;
   
   public dynamic class SBOkPopup extends SBStandardPopup
   {
      
      private var _okBtn:MovieClip;
      
      private var _okBtnCallback:Function;
      
      public function SBOkPopup(init_parent:DisplayObjectContainer, init_message:String = null, init_darken:Boolean = true, okBtnCallback:Function = null, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = false, init_title:String = null, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_children:Array = null)
      {
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         if(okBtnCallback != null)
         {
            this._okBtnCallback = okBtnCallback;
         }
         else
         {
            this._okBtnCallback = this.onOkBtn;
         }
         var skin:MovieClip = GETDEFINITIONBYNAME("OkPopupSkin");
         var content:MovieClip = GETDEFINITIONBYNAME("OkPopupContent");
         this._okBtn = content.okBtn;
         this._okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._okBtnCallback,false,0,true);
         _resizeCallback = this.onResize;
         super(init_parent,init_message,init_darken,content,skin,autoOpen,init_enabled,init_modal,init_draggable,init_title,init_x,init_y,init_width,init_height,init_children);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.handleOkKeyDown,false,0,true);
      }
      
      public static function destroyInParentChain(seekAndDestroy:DisplayObject) : void
      {
         while(Boolean(seekAndDestroy) && Boolean(seekAndDestroy != gMainFrame.stage) && !(seekAndDestroy is SBOkPopup))
         {
            seekAndDestroy = seekAndDestroy.parent;
         }
         if(seekAndDestroy is SBOkPopup)
         {
            SBOkPopup(seekAndDestroy).destroy();
         }
      }
      
      override public function destroy() : void
      {
         this._okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this._okBtnCallback);
         super.destroy();
      }
      
      private function onResize() : void
      {
         this._okBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
      }
      
      private function handleOkKeyDown(event:KeyboardEvent) : void
      {
         switch(event.keyCode)
         {
            case Keyboard.ENTER:
            case Keyboard.SPACE:
               this.onOkBtn(event);
         }
      }
      
      private function onOkBtn(evt:Event) : void
      {
         evt.stopPropagation();
         this.destroy();
      }
   }
}

