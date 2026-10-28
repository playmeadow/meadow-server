package com.sbi.popup
{
   import flash.display.*;
   import flash.events.*;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.utils.getDefinitionByName;
   
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
      
      public function SBStandardPopup(param1:DisplayObjectContainer, param2:String = null, param3:Boolean = true, param4:MovieClip = null, param5:MovieClip = null, param6:Boolean = true, param7:Boolean = true, param8:Boolean = false, param9:Boolean = false, param10:String = null, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Number = undefined, param15:Array = null)
      {
         if(param5)
         {
            this._skin = param5;
         }
         else
         {
            this._skin = new (getDefinitionByName("PopupSkin") as Class)();
         }
         if(param4)
         {
            this._content = param4;
         }
         else
         {
            this._content = new (getDefinitionByName("PopupContent") as Class)();
         }
         this._top = this._skin.ba.t;
         this._mid = this._skin.ba.m;
         this._bot = this._skin.ba.b;
         this._text = this._content.text;
         this._text.autoSize = TextFieldAutoSize.CENTER;
         if(param2)
         {
            this.setText(param2);
         }
         super(param1,this._skin,this._content,param6,param7,param8,param9,param3,param10,param11,param12,param13,param14,param15);
      }
      
      public function setText(param1:String) : void
      {
         this._text.text = param1;
         this.resize();
      }
      
      public function setHtmlText(param1:String) : void
      {
         this._text.htmlText = param1;
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

