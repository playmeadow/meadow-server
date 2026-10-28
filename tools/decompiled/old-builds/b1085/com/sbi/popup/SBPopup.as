package com.sbi.popup
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   
   public dynamic class SBPopup extends Sprite
   {
      
      public var skin:SBPopupSkin;
      
      public var content:DisplayObject;
      
      public var popupFilters:Array;
      
      public var _enabled:Boolean = true;
      
      public var _selected:Boolean = true;
      
      public var _modal:Boolean = false;
      
      public var _darken:Boolean = false;
      
      public var suppressMouseDown:Boolean = false;
      
      public var closeCallback:Function;
      
      public var restoreLastPos:Boolean = true;
      
      public var lastPosX:Number;
      
      public var lastPosY:Number;
      
      public var draggable:Boolean = true;
      
      public var soundsEnabled:Boolean = true;
      
      public var bxClosesPopup:Boolean = true;
      
      public function SBPopup(param1:DisplayObjectContainer, param2:MovieClip, param3:DisplayObject, param4:Boolean = true, param5:Boolean = true, param6:Boolean = false, param7:Boolean = false, param8:Boolean = false, param9:String = null, param10:Number = undefined, param11:Number = undefined, param12:Number = undefined, param13:Number = undefined, param14:Array = null, param15:Array = null)
      {
         super();
         this.skin = new SBPopupSkin(param2);
         this.addChild(this.skin.s);
         if(param3)
         {
            this.content = param3;
            this.content.name = "content";
            this.content.x = this.skin.s["c"].x;
            this.content.y = this.skin.s["c"].y;
            this.content.width = this.skin.s["c"].width;
            this.content.height = this.skin.s["c"].height;
            this.skin.s.addChildAt(this.content,this.skin.s.getChildIndex(this.skin.s["c"]));
         }
         this.skin.s["c"].visible = false;
         if(this.skin.s.getChildByName("bx"))
         {
            this.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.bxHandler,false,0,true);
         }
         param1.addChild(this);
         this.visible = false;
         width = param12 ? param12 : this.skin.s.width;
         height = param13 ? param13 : this.skin.s.height;
         if(parent.stage)
         {
            x = param10 ? param10 : MainFrame.VIEW_WIDTH * 0.5;
            y = param11 ? param11 : MainFrame.VIEW_HEIGHT * 0.5;
         }
         this.lastPosX = x;
         this.lastPosY = y;
         this.modal = param6;
         this.draggable = param7;
         this.enabled = param5;
         this.suppressMouseDown = false;
         this.popupFilters = param14;
         SBPopupManager.popups.push(this);
         if(param8)
         {
            this._darken = true;
         }
         if(param4)
         {
            this.open();
         }
      }
      
      public static function isChildOf(param1:DisplayObjectContainer, param2:DisplayObjectContainer, param3:DisplayObject) : Boolean
      {
         var _loc4_:DisplayObject = param3;
         while(_loc4_ != param2)
         {
            if(_loc4_ == param1)
            {
               return true;
            }
            _loc4_ = _loc4_.parent;
         }
         return false;
      }
      
      public function get darken() : Boolean
      {
         return this._darken;
      }
      
      public function get selected() : Boolean
      {
         return this._selected;
      }
      
      public function set selected(param1:Boolean) : void
      {
         if(param1)
         {
         }
         this._selected = param1;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(param1:Boolean) : void
      {
         if(param1)
         {
            mouseChildren = true;
         }
         else
         {
            mouseChildren = false;
         }
         this._enabled = param1;
      }
      
      override public function set visible(param1:Boolean) : void
      {
         if(param1)
         {
            if(this._modal)
            {
               SBPopupManager.modalSBPopup = this;
            }
            if(this._darken && SBPopupManager.darken != null)
            {
               SBPopupManager.darken(this);
            }
         }
         else
         {
            if(this._modal && SBPopupManager.modalSBPopup == this)
            {
               SBPopupManager.modalSBPopup = null;
            }
            if(!this._darken && SBPopupManager.lighten != null)
            {
               SBPopupManager.lighten(this);
            }
         }
         super.visible = param1;
      }
      
      public function get modal() : Boolean
      {
         return Boolean(this._modal && visible);
      }
      
      public function set modal(param1:Boolean) : void
      {
         if(param1)
         {
            if(visible)
            {
               if(Boolean(SBPopupManager.modalSBPopup) && Boolean(SBPopupManager.modalSBPopup != this) && SBPopupManager.modalSBPopup.modal)
               {
                  throw new Error("Attempted to make two or more modal dialogs active at once!");
               }
               SBPopupManager.modalSBPopup = this;
            }
         }
         else if(SBPopupManager.modalSBPopup == this)
         {
            SBPopupManager.modalSBPopup = null;
         }
         this._modal = param1;
      }
      
      public function addListeners() : void
      {
         addEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler,false,0,true);
         addEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler,false,0,true);
      }
      
      public function removeListeners() : void
      {
         removeEventListener(MouseEvent.MOUSE_DOWN,this.mouseDownHandler);
         removeEventListener(MouseEvent.MOUSE_UP,this.mouseUpHandler);
      }
      
      public function open() : void
      {
         if(visible)
         {
            return;
         }
         if(this._darken)
         {
            if(Boolean(SBPopupManager) && SBPopupManager.darken != null)
            {
               SBPopupManager.darken(this);
            }
         }
         this.addListeners();
         this.setFilters(this.popupFilters);
         if(0)
         {
            x = this.lastPosX;
            y = this.lastPosY;
         }
         this.visible = true;
         if(parent)
         {
            this.bringToFront();
         }
         if(this._modal)
         {
            SBPopupManager.modalSBPopup = this;
         }
      }
      
      public function close() : void
      {
         if(!visible)
         {
            return;
         }
         if(this._darken)
         {
            if(Boolean(SBPopupManager) && SBPopupManager.lighten != null)
            {
               SBPopupManager.lighten(this);
            }
         }
         this.removeListeners();
         this.setFilters([]);
         this.lastPosX = x;
         this.lastPosY = y;
         this.visible = false;
         if(this._modal)
         {
            if(SBPopupManager.modalSBPopup == this)
            {
               SBPopupManager.modalSBPopup = null;
            }
         }
         if(this.closeCallback != null)
         {
            this.closeCallback();
         }
      }
      
      public function destroy() : void
      {
         if(visible)
         {
            this.close();
         }
         if(Boolean(this.skin) && Boolean(this.skin.s))
         {
            removeChild(this.skin.s);
            if(this.content)
            {
               this.skin.s.removeChild(this.content);
               this.content = null;
            }
            this.skin.s = null;
         }
         this.closeCallback = null;
         if(parent)
         {
            parent.removeChild(this);
         }
         var _loc1_:int = SBPopupManager.popups.indexOf(this);
         if(_loc1_ > 0)
         {
            SBPopupManager.popups.splice(_loc1_,1);
         }
      }
      
      public function setFilters(param1:Array = null) : void
      {
      }
      
      public function bxHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(visible && this.bxClosesPopup)
         {
            this.close();
         }
      }
      
      public function bringContentToFront() : void
      {
         this.skin.s.setChildIndex(this.content,this.skin.s.getChildIndex(this.skin.s["c"]));
      }
      
      public function mouseDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this.suppressMouseDown)
         {
            this.suppressMouseDown = false;
            return;
         }
         if(!(param1.target is DisplayObject))
         {
            throw new Error("mouseDownHandler mouse event got a non-DisplayObject object!");
         }
         if(this.draggable && SBPopupManager.checkModalSBPopup(this,true) && (Boolean(SBPopup.isChildOf(this.skin.s["ba"],this,DisplayObject(param1.target)) || param1.target == this.content) || Boolean(this.content is DisplayObjectContainer && DisplayObjectContainer(this.content).getChildByName("titleDragBar") && param1.target == this.content["titleDragBar"])))
         {
            startDrag();
         }
      }
      
      public function bringToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function mouseUpHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!(param1.target is DisplayObject))
         {
            throw new Error("mouseDownHandler mouse event got a non-DisplayObject object!");
         }
         if(this.draggable && SBPopupManager.checkModalSBPopup(this,false) && (Boolean(SBPopup.isChildOf(this.skin.s["ba"],this,DisplayObject(param1.target)) || param1.target == this.content) || Boolean(this.content is DisplayObjectContainer && DisplayObjectContainer(this.content).getChildByName("titleDragBar") && param1.target == this.content["titleDragBar"])))
         {
            stopDrag();
         }
      }
      
      public function get closeBtn() : MovieClip
      {
         return this.skin.s["bx"];
      }
   }
}

