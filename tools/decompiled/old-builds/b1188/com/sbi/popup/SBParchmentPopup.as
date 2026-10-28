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
      
      public function SBParchmentPopup(param1:DisplayObjectContainer, param2:int = 0, param3:String = null, param4:Boolean = true, param5:Function = null, param6:Object = null)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._parent = param1;
         this._type = param2;
         this._message = param3;
         this._darken = param4;
         this._confirmCallback = param5;
         this._passback = param6;
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(2106,this.onMediaLoaded);
      }
      
      public function destroy() : void
      {
         var _loc1_:int = 0;
         if(this._popup)
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
            _loc1_ = SBPopupManager.nonSBPopups.indexOf(this);
            if(_loc1_ >= 0)
            {
               SBPopupManager.nonSBPopups.splice(_loc1_,1);
            }
            this._popup = null;
         }
      }
      
      private function onMediaLoaded(param1:MovieClip) : void
      {
         var img:MovieClip = param1;
         if(img)
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
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function onBtnDown(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         param1.stopPropagation();
         if(this._confirmCallback != null)
         {
            _loc2_ = {
               "status":param1.currentTarget == this._popup.contBtn || param1.currentTarget == this._popup.contOnlyBtn || param1.currentTarget == this._popup.yesBtn || param1.currentTarget == this._popup.okBtn,
               "passback":this._passback
            };
            this.destroy();
            this._confirmCallback(_loc2_);
         }
         else
         {
            this.destroy();
         }
      }
   }
}

