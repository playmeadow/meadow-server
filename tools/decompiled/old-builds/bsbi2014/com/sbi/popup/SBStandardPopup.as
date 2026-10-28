package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public dynamic class SBStandardPopup extends SBPopup
   {
      
      protected var _text:TextField;
      
      protected var _skin:MovieClip;
      
      protected var _content:MovieClip;
      
      protected var _top:MovieClip;
      
      protected var _mid:MovieClip;
      
      protected var _bot:MovieClip;
      
      protected var _verticalOffset:Number = 0;
      
      protected var _btnTxtGap:Number = 0;
      
      protected var _btnHeight:Number = 0;
      
      protected var _resizeCallback:Function;
      
      public function SBStandardPopup(init_parent:DisplayObjectContainer, init_message:String = null, init_darken:Boolean = true, init_content:MovieClip = null, init_skin:MovieClip = null, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = false, init_title:String = null, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_children:Array = null)
      {
         if(Boolean(init_skin))
         {
            this._skin = init_skin;
         }
         else
         {
            this._skin = GETDEFINITIONBYNAME("PopupSkin");
         }
         if(Boolean(init_content))
         {
            this._content = init_content;
         }
         else
         {
            this._content = GETDEFINITIONBYNAME("PopupContent");
         }
         this._top = this._skin.ba.t;
         this._mid = this._skin.ba.m;
         this._bot = this._skin.ba.b;
         this._text = this._content.text;
         this._text.autoSize = TextFieldAutoSize.CENTER;
         if(Boolean(init_message))
         {
            this.setText(init_message);
         }
         super(init_parent,this._skin,this._content,autoOpen,init_enabled,init_modal,init_draggable,init_darken,init_title,init_x,init_y,init_width,init_height,init_children);
      }
      
      public function setText(newText:String) : void
      {
         this._text.text = newText;
         this.resize();
      }
      
      public function setHtmlText(newHtmlText:String) : void
      {
         this._text.htmlText = newHtmlText;
         this.resize();
      }
      
      private function resize() : void
      {
         this._mid.height = Math.floor(this._text.height);
         this._mid.y = Math.floor(-(this._mid.height * 0.5) + this._verticalOffset);
         this._top.y = this._mid.y - this._top.height;
         this._bot.y = this._mid.y + this._mid.height;
         this._text.y = 0;
         this._skin.c.height = this._text.height + this._btnTxtGap + this._btnHeight;
         this._skin.c.y = this._mid.y;
         if(this._resizeCallback != null)
         {
            this._resizeCallback();
         }
         this._content.x = this._skin["c"].x;
         this._content.y = this._skin["c"].y;
         this._content.width = this._skin["c"].width;
         this._content.height = this._skin["c"].height;
      }
   }
}

