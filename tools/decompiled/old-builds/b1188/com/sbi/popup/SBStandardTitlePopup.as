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
      
      public function SBStandardTitlePopup(param1:DisplayObjectContainer, param2:String, param3:String = null, param4:int = 370, param5:Function = null, param6:Boolean = true, param7:Boolean = true)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._popupMediaHelper = new MediaHelper();
         this._popupMediaHelper.init(param4,this.onMediaLoaded,{
            "parent":param1,
            "message":param2,
            "title":param3,
            "closeCallback":param5,
            "autoOpen":param6,
            "darken":param7
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
         if(this._loadedMC)
         {
            this._loadedMC.visible = true;
         }
         if(this._loadedMC.passback.darken)
         {
            DarkenManager.darken(this._loadedMC);
         }
         this._openWasCalled = true;
      }
      
      public function close() : void
      {
         if(this._loadedMC)
         {
            this._loadedMC.visible = false;
         }
         if(this._loadedMC.passback.darken)
         {
            DarkenManager.unDarken(this._loadedMC);
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         if(param1)
         {
            this._loadedMC = param1.getChildAt(0) as MovieClip;
            this._popupMediaHelper.destroy();
            this._popupMediaHelper = null;
            this._loadedMC.x = MainFrame.VIEW_WIDTH * 0.5;
            this._loadedMC.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._loadedMC.parent.parent.x = this._loadedMC.x;
            this._loadedMC.parent.parent.y = this._loadedMC.y;
            this._loadedMC.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
            this._loadedMC.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            this._loadedMC.passback = this._loadedMC.parent["passback"];
            if(this._loadedMC.passback.title)
            {
               this._loadedMC.titleTxt.text = this._loadedMC.passback.title;
            }
            if(this._loadedMC.passback.message)
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
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._loadedMC.passback.closeCallback)
         {
            this._loadedMC.passback.closeCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
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

