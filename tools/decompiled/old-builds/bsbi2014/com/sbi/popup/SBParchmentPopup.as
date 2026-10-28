package com.sbi.popup
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextFieldAutoSize;
   import gui.DarkenManager;
   import loader.MediaHelper;
   
   public dynamic class SBParchmentPopup
   {
      
      public static const TYPE_OK:int = 0;
      
      public static const TYPE_YES_NO:int = 1;
      
      public static const TYPE_CONTINUE_EXIT:int = 2;
      
      public static const TYPE_CONTINUE_ONLY:int = 3;
      
      private var _parent:DisplayObjectContainer;
      
      private var _type:int;
      
      private var _message:String;
      
      private var _darken:Boolean;
      
      private var _confirmCallback:Function;
      
      private var _passback:Object;
      
      private var _mediaHelper:MediaHelper;
      
      private var _popup:MovieClip;
      
      public function SBParchmentPopup(init_parent:DisplayObjectContainer, init_type:int = 0, init_message:String = null, init_darken:Boolean = true, init_confirmCallback:Function = null, init_passbackObject:Object = null)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._parent = init_parent;
         this._type = init_type;
         this._message = init_message;
         this._darken = init_darken;
         this._confirmCallback = init_confirmCallback;
         this._passback = init_passbackObject;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(2106,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         var idx:int = 0;
         if(Boolean(this._popup))
         {
            DarkenManager.unDarken(this._popup);
            if(Boolean(this._parent) && Boolean(this._popup.parent) && this._popup.parent == this._parent)
            {
               this._parent.removeChild(this._popup);
            }
            this._popup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
            switch(this._type)
            {
               case TYPE_CONTINUE_EXIT:
                  this._popup.contBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown);
                  this._popup.exitBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown);
                  break;
               case TYPE_CONTINUE_ONLY:
                  this._popup.contOnlyBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown);
                  break;
               case TYPE_OK:
                  this._popup.okBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown);
                  break;
               case TYPE_YES_NO:
                  this._popup.yesBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown);
                  this._popup.noBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown);
            }
            idx = SBPopupManager.nonSBPopups.indexOf(this);
            if(idx >= 0)
            {
               SBPopupManager.nonSBPopups.splice(idx,1);
            }
            this._popup = null;
         }
      }
      
      private function onMediaLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            DarkenManager.showLoadingSpiral(false);
            this._popup = MovieClip(img.getChildAt(0));
            this._mediaHelper.destroy();
            this._mediaHelper = null;
            switch(this._type)
            {
               case TYPE_CONTINUE_EXIT:
                  this._popup.okBtn.visible = false;
                  this._popup.yesBtn.visible = false;
                  this._popup.noBtn.visible = false;
                  this._popup.contOnlyBtn.visible = false;
                  this._popup.contBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown,false,0,true);
                  this._popup.exitBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown,false,0,true);
                  break;
               case TYPE_CONTINUE_ONLY:
                  this._popup.okBtn.visible = false;
                  this._popup.yesBtn.visible = false;
                  this._popup.noBtn.visible = false;
                  this._popup.exitBtn.visible = false;
                  this._popup.contBtn.visible = false;
                  this._popup.contOnlyBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown,false,0,true);
                  break;
               case TYPE_OK:
                  this._popup.yesBtn.visible = false;
                  this._popup.noBtn.visible = false;
                  this._popup.contBtn.visible = false;
                  this._popup.exitBtn.visible = false;
                  this._popup.contOnlyBtn.visible = false;
                  this._popup.okBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown,false,0,true);
                  break;
               case TYPE_YES_NO:
                  this._popup.okBtn.visible = false;
                  this._popup.contBtn.visible = false;
                  this._popup.exitBtn.visible = false;
                  this._popup.contOnlyBtn.visible = false;
                  this._popup.yesBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown,false,0,true);
                  this._popup.noBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onBtnDown,false,0,true);
            }
            this._popup.txt.autoSize = TextFieldAutoSize.CENTER;
            this._popup.txt.text = this._message;
            with(this._popup.ba)
            {
               
               m.height = Math.floor(_popup.txt.height) + 44 + 8;
               m.y = Math.floor(-(m.height * 0.5));
               t.y = m.y - t.height;
               b.y = m.y + m.height;
               _popup.txt.y = m.y + 4;
               _popup.yesBtn.y = m.y + _popup.txt.height + 13;
               _popup.noBtn.y = m.y + _popup.txt.height + 13;
               _popup.okBtn.y = m.y + _popup.txt.height + 9;
               _popup.contBtn.y = m.y + _popup.txt.height + 13;
               _popup.exitBtn.y = m.y + _popup.txt.height + 13;
               _popup.contOnlyBtn.y = m.y + _popup.txt.height + 13;
            }
            this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
            this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
            this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
            this._parent.addChild(this._popup);
            if(this._darken)
            {
               DarkenManager.darken(this._popup);
            }
            SBPopupManager.nonSBPopups.push(this);
         }
      }
      
      private function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private function onBtnDown(evt:MouseEvent) : void
      {
         var o:Object = null;
         evt.stopPropagation();
         if(this._confirmCallback != null)
         {
            o = {
               "status":evt.currentTarget == this._popup.contBtn || evt.currentTarget == this._popup.contOnlyBtn || evt.currentTarget == this._popup.yesBtn || evt.currentTarget == this._popup.okBtn,
               "passback":this._passback
            };
            this.destroy();
            this._confirmCallback(o);
         }
         else
         {
            this.destroy();
         }
      }
   }
}

