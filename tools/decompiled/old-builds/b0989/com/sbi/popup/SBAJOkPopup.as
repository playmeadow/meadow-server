package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getDefinitionByName;
   
   public dynamic class SBAJOkPopup extends SBPopup
   {
      
      protected var _messageText:TextField;
      
      protected var _titleText:TextField;
      
      protected var _skin:MovieClip;
      
      protected var _content:MovieClip;
      
      protected var _top:MovieClip;
      
      protected var _mid:MovieClip;
      
      protected var _bot:MovieClip;
      
      private var _titleToMessageDifference:int = 5;
      
      private var _btnTxtGap:int = 10;
      
      private var _verticalOffset:int = 13;
      
      private var _okBtn:MovieClip;
      
      private var _okBtnCallback:Function;
      
      public function SBAJOkPopup(param1:DisplayObjectContainer, param2:String = null, param3:String = null, param4:Function = null, param5:Boolean = true, param6:MovieClip = null, param7:MovieClip = null, param8:Boolean = true, param9:Boolean = true, param10:Boolean = false, param11:Boolean = false, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Number = undefined, param16:Array = null)
      {
         if(param4 != null)
         {
            this._okBtnCallback = param4;
         }
         else
         {
            this._okBtnCallback = this.onOkBtn;
         }
         this._skin = new (getDefinitionByName("BroadcastPopupSkin") as Class)();
         this._content = new (getDefinitionByName("BroadcastPopupContent") as Class)();
         this._top = this._skin.ba.t;
         this._mid = this._skin.ba.m;
         this._bot = this._skin.ba.b;
         this._okBtn = this._content.okBtn;
         this._okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._okBtnCallback,false,0,true);
         this._messageText = this._content.text;
         this._titleText = this._content.titleTxt;
         this._messageText.autoSize = TextFieldAutoSize.CENTER;
         this._titleText.autoSize = TextFieldAutoSize.CENTER;
         this.setMessageText(param2);
         if(param3)
         {
            this._titleText.text = param3;
         }
         super(param1,this._skin,this._content,param8,param9,param10,param11,param5,param3,param12,param13,param14,param15,param16);
      }
      
      public static function destroyInParentChain(param1:DisplayObject) : void
      {
         while(Boolean(param1) && Boolean(param1 != gMainFrame.stage) && !(param1 is SBOkPopup))
         {
            param1 = param1.parent;
         }
         if(param1 is SBOkPopup)
         {
            SBOkPopup(param1).destroy();
         }
      }
      
      override public function destroy() : void
      {
         this._okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this._okBtnCallback);
         super.destroy();
      }
      
      public function setMessageText(param1:String) : void
      {
         this._messageText.text = param1;
         this.resize();
      }
      
      private function resize() : void
      {
         this._mid.height = Math.floor(this._messageText.height);
         this._mid.y = Math.floor(-(this._mid.height * 0.5));
         this._top.y = this._mid.y - this._top.height;
         this._bot.y = this._mid.y + this._mid.height;
         this._titleText.y = 0;
         this._messageText.y = this._titleText.height + this._titleToMessageDifference;
         this._okBtn.y = this._messageText.y + this._messageText.height + this._btnTxtGap + this._okBtn.height * 0.5;
         this._skin.c.height = this._titleText.height + this._titleToMessageDifference + this._messageText.height + this._btnTxtGap + this._okBtn.height;
         this._skin.c.y = -(this._skin.ba.height * 0.5) + this._verticalOffset;
         this._content.x = this._skin.c.x;
         this._content.y = this._skin.c.y;
         this._content.width = this._skin.c.width;
         this._content.height = this._skin.c.height;
      }
      
      private function onOkBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.destroy();
      }
   }
}

