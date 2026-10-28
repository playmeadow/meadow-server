package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public dynamic class SBStayLeavePopup extends SBStandardPopup
   {
      
      private var _stayBtn:MovieClip;
      
      private var _leaveBtn:MovieClip;
      
      private var _confirmCallback:Function;
      
      private var _passbackObject:Object;
      
      public function SBStayLeavePopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:Function = null, param5:Object = null, param6:Boolean = true, param7:Boolean = true, param8:Boolean = false, param9:Boolean = false, param10:String = null, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Array = null)
      {
         this._confirmCallback = param4;
         this._passbackObject = param5;
         _verticalOffset = -20;
         _btnTxtGap = 6;
         _btnHeight = 44;
         var _loc16_:MovieClip = new (getDefinitionByName("YesNoPopupSkin") as Class)();
         var _loc17_:MovieClip = new (getDefinitionByName("LeaveStayPopupContent") as Class)();
         this._stayBtn = _loc17_.stayBtn;
         this._leaveBtn = _loc17_.leaveBtn;
         this._stayBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onStayLeaveBtn,false,0,true);
         this._leaveBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onStayLeaveBtn,false,0,true);
         _resizeCallback = this.onResize;
         super(param1,param2,param3,_loc17_,_loc16_,param6,param7,param8,param9,param10,param11,param12,param13,param14,param15);
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
      
      private function onStayLeaveBtn(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         this.destroy();
         if(this._confirmCallback != null)
         {
            _loc2_ = {
               "status":param1.currentTarget == this._leaveBtn,
               "passback":this._passbackObject
            };
            this._confirmCallback(_loc2_);
         }
      }
   }
}

