package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public dynamic class SBStandardTitlePopup
   {
      
      public static const THANK_YOU_MEDIA_ID:int = 370;
      
      private var _popupMediaHelper:MediaHelper;
      
      private var _openWasCalled:Boolean;
      
      protected var _loadedMC:MovieClip;
      
      protected var _top:MovieClip;
      
      protected var _mid:MovieClip;
      
      protected var _bot:MovieClip;
      
      public function SBStandardTitlePopup(init_parent:DisplayObjectContainer, init_message:String, init_title:String = null, init_mediaId:int = 370, init_closeCallback:Function = null, init_autoOpen:Boolean = true, init_darken:Boolean = true)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._popupMediaHelper = new MediaHelper();
         this._popupMediaHelper.init(init_mediaId,this.onMediaLoaded,{
            "parent":init_parent,
            "message":init_message,
            "title":init_title,
            "closeCallback":init_closeCallback,
            "autoOpen":init_autoOpen,
            "darken":init_darken
         });
      }
      
      public function destroy() : void
      {
         DarkenManager.unDarken(this._loadedMC);
         this._loadedMC.passback.parent.removeChild(this._loadedMC);
         this._loadedMC.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._loadedMC.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._loadedMC = null;
         this._top = null;
         this._mid = null;
         this._bot = null;
         this._openWasCalled = false;
      }
      
      public function open() : void
      {
         if(Boolean(this._loadedMC))
         {
            this._loadedMC.visible = true;
         }
         if(Boolean(this._loadedMC.passback.darken))
         {
            DarkenManager.darken(this._loadedMC);
         }
         this._openWasCalled = true;
      }
      
      public function close() : void
      {
         if(Boolean(this._loadedMC))
         {
            this._loadedMC.visible = false;
         }
         if(Boolean(this._loadedMC.passback.darken))
         {
            DarkenManager.unDarken(this._loadedMC);
         }
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(Boolean(img))
         {
            this._loadedMC = img.getChildAt(0) as MovieClip;
            this._popupMediaHelper.destroy();
            this._popupMediaHelper = null;
            this._loadedMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._loadedMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._loadedMC.parent.parent.x = this._loadedMC.x;
            this._loadedMC.parent.parent.y = this._loadedMC.y;
            this._loadedMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            this._loadedMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._loadedMC.passback = this._loadedMC.parent["passback"];
            if(Boolean(this._loadedMC.passback.title))
            {
               this._loadedMC.titleTxt.text = this._loadedMC.passback.title;
            }
            if(Boolean(this._loadedMC.passback.message))
            {
               this._loadedMC.txt.bodyTxt.autoSize = TextFieldAutoSize.CENTER;
               this._loadedMC.txt.bodyTxt.text = this._loadedMC.passback.message;
            }
            this._top = this._loadedMC.ba.t;
            this._mid = this._loadedMC.ba.m;
            this._bot = this._loadedMC.ba.b;
            this.resize();
            if(!this._loadedMC.passback.autoOpen && !this._openWasCalled)
            {
               this._loadedMC.visible = false;
            }
            else
            {
               this.open();
            }
            this._loadedMC.passback.parent.addChild(this._loadedMC);
         }
      }
      
      private function onClose(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(this._loadedMC.passback.closeCallback))
         {
            this._loadedMC.passback.closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function resize() : void
      {
         this._mid.height = Math.floor(this._loadedMC.txt.height);
         this._top.y = this._mid.y - this._mid.height * 0.5 - this._top.height * 0.5;
         this._bot.y = this._mid.y + this._mid.height * 0.5 + this._bot.height * 0.5;
         this._loadedMC.titleTxt.y = this._top.y - 23;
         this._loadedMC.bx.y = this._loadedMC.titleTxt.y;
         this._loadedMC.txt.y -= this._mid.height * 0.5 - 29;
      }
   }
}

