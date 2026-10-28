package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
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
      
      public function SBAJOkPopup(init_parent:DisplayObjectContainer, init_message:String = null, init_title:String = null, okBtnCallback:Function = null, init_darken:Boolean = true, init_content:MovieClip = null, init_skin:MovieClip = null, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = false, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_children:Array = null)
      {
         if(okBtnCallback != null)
         {
            this._okBtnCallback = okBtnCallback;
         }
         else
         {
            this._okBtnCallback = this.onOkBtn;
         }
         this._skin = GETDEFINITIONBYNAME("BroadcastPopupSkin");
         this._content = GETDEFINITIONBYNAME("BroadcastPopupContent");
         this._top = this._skin.ba.t;
         this._mid = this._skin.ba.m;
         this._bot = this._skin.ba.b;
         this._okBtn = this._content.okBtn;
         this._okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this._okBtnCallback,false,0,true);
         this._messageText = this._content.text;
         this._titleText = this._content.titleTxt;
         this._messageText.autoSize = TextFieldAutoSize.CENTER;
         this._titleText.autoSize = TextFieldAutoSize.CENTER;
         this.setMessageText(init_message);
         if(Boolean(init_title))
         {
            this._titleText.text = init_title;
         }
         super(init_parent,this._skin,this._content,autoOpen,init_enabled,init_modal,init_draggable,init_darken,init_title,init_x,init_y,init_width,init_height,init_children);
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
      
      public function setMessageText(newText:String) : void
      {
         this._messageText.text = newText;
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
      
      private function onOkBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         this.destroy();
      }
   }
}

