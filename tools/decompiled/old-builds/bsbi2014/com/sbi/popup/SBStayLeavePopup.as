package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public dynamic class SBStayLeavePopup extends SBStandardPopup
   {
      
      private var _stayBtn:MovieClip;
      
      private var _leaveBtn:MovieClip;
      
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      public function SBStayLeavePopup(init_parent:DisplayObjectContainer, init_message:String = null, init_darken:Boolean = true, init_confirmCallback:Function = null, init_passbackObject:Object = null, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = false, init_title:String = null, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_children:Array = null)
      {
         this._confirmCallback = init_confirmCallback;
         this._passbackObject = init_passbackObject;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var skin:MovieClip = GETDEFINITIONBYNAME("YesNoPopupSkin");
         var content:MovieClip = GETDEFINITIONBYNAME("LeaveStayPopupContent");
         this._stayBtn = content.stayBtn;
         this._leaveBtn = content.leaveBtn;
         this._stayBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onStayLeaveBtn,false,0,true);
         this._leaveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onStayLeaveBtn,false,0,true);
         _resizeCallback = this.onResize;
         super(init_parent,init_message,init_darken,content,skin,autoOpen,init_enabled,init_modal,init_draggable,init_title,init_x,init_y,init_width,init_height,init_children);
      }
      
      override public function destroy() : void
      {
         this._stayBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStayLeaveBtn);
         this._leaveBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onStayLeaveBtn);
         super.destroy();
      }
      
      private function onResize() : void
      {
         this._stayBtn.y = _text.height + _btnTxtGap + 0.5 * _btnHeight;
         this._leaveBtn.y = this._stayBtn.y;
      }
      
      private function onStayLeaveBtn(evt:MouseEvent) : void
      {
         var o:Object = null;
         evt.stopPropagation();
         this.destroy();
         if(this._confirmCallback != null)
         {
            o = {
               "status":evt.currentTarget == this._leaveBtn,
               "passback":this._passbackObject
            };
            this._confirmCallback(o);
         }
      }
   }
}

