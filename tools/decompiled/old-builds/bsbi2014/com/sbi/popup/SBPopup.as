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
      
      public function SBPopup(init_parent:DisplayObjectContainer, init_skin:MovieClip, init_content:DisplayObject, autoOpen:Boolean = true, init_enabled:Boolean = true, init_modal:Boolean = false, init_draggable:Boolean = false, init_darken:Boolean = false, init_title:String = null, init_x:Number = undefined, init_y:Number = undefined, init_width:Number = undefined, init_height:Number = undefined, init_filters:Array = null, init_children:Array = null)
      {
         super();
         this.skin = new SBPopupSkin(init_skin);
         this.addChild(this.skin.s);
         if(Boolean(init_content))
         {
            this.content = init_content;
            this.content.name = "content";
            this.content.x = this.skin.s["c"].x;
            this.content.y = this.skin.s["c"].y;
            this.content.width = this.skin.s["c"].width;
            this.content.height = this.skin.s["c"].height;
            this.skin.s.addChildAt(this.content,this.skin.s.getChildIndex(this.skin.s["c"]));
         }
         this.skin.s["c"].visible = false;
         if(Boolean(this.skin.s.getChildByName("bx")))
         {
            this.skin.s["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.bxHandler,false,0,true);
         }
         init_parent.addChild(this);
         this.visible = false;
         width = Boolean(init_width) ? init_width : this.skin.s.width;
         height = Boolean(init_height) ? init_height : this.skin.s.height;
         if(Boolean(parent.stage))
         {
            x = Boolean(init_x) ? init_x : MainFrame.VIEW_WIDTH * 0.5;
            y = Boolean(init_y) ? init_y : MainFrame.VIEW_HEIGHT * 0.5;
         }
         this.lastPosX = x;
         this.lastPosY = y;
         this.modal = init_modal;
         this.draggable = init_draggable;
         this.enabled = init_enabled;
         this.suppressMouseDown = false;
         this.popupFilters = init_filters;
         SBPopupManager.popups.push(this);
         if(init_darken)
         {
            this._darken = true;
         }
         if(autoOpen)
         {
            this.open();
         }
      }
      
      public static function isChildOf(testParent:DisplayObjectContainer, stopParent:DisplayObjectContainer, testChild:DisplayObject) : Boolean
      {
         var c:DisplayObject = testChild;
         while(c != stopParent)
         {
            if(c == testParent)
            {
               return true;
            }
            c = c.parent;
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
      
      public function set selected(select:Boolean) : void
      {
         if(select)
         {
         }
         this._selected = select;
      }
      
      public function get enabled() : Boolean
      {
         return this._enabled;
      }
      
      public function set enabled(enable:Boolean) : void
      {
         if(enable)
         {
            mouseChildren = true;
         }
         else
         {
            mouseChildren = false;
         }
         this._enabled = enable;
      }
      
      override public function set visible(make_visible:Boolean) : void
      {
         if(make_visible)
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
         super.visible = make_visible;
      }
      
      public function get modal() : Boolean
      {
         return Boolean(this._modal && visible);
      }
      
      public function set modal(make_modal:Boolean) : void
      {
         if(make_modal)
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
         this._modal = make_modal;
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
            trace("WARNING: Tried to open an already opened popup... ignored...");
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
         if(Boolean(0))
         {
            x = this.lastPosX;
            y = this.lastPosY;
         }
         this.visible = true;
         if(Boolean(parent))
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
            trace("WARNING: Tried to close an already closed popup... ignored...");
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
            if(Boolean(this.content))
            {
               this.skin.s.removeChild(this.content);
               this.content = null;
            }
            this.skin.s = null;
         }
         this.closeCallback = null;
         if(Boolean(parent))
         {
            parent.removeChild(this);
         }
         var idx:int = SBPopupManager.popups.indexOf(this);
         if(idx > 0)
         {
            SBPopupManager.popups.splice(idx,1);
         }
      }
      
      public function setFilters(newFilters:Array = null) : void
      {
      }
      
      public function bxHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(visible && this.bxClosesPopup)
         {
            this.close();
         }
      }
      
      public function bringContentToFront() : void
      {
         this.skin.s.setChildIndex(this.content,this.skin.s.getChildIndex(this.skin.s["c"]));
      }
      
      public function mouseDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(this.suppressMouseDown)
         {
            this.suppressMouseDown = false;
            return;
         }
         if(!(m.target is DisplayObject))
         {
            throw new Error("mouseDownHandler mouse event got a non-DisplayObject object!");
         }
         if(this.draggable && SBPopupManager.checkModalSBPopup(this,true) && (Boolean(SBPopup.isChildOf(this.skin.s["ba"],this,DisplayObject(m.target)) || m.target == this.content) || Boolean(this.content is DisplayObjectContainer && DisplayObjectContainer(this.content).getChildByName("titleDragBar") && m.target == this.content["titleDragBar"])))
         {
            startDrag();
         }
      }
      
      public function bringToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function mouseUpHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!(m.target is DisplayObject))
         {
            throw new Error("mouseDownHandler mouse event got a non-DisplayObject object!");
         }
         if(this.draggable && SBPopupManager.checkModalSBPopup(this,false) && (Boolean(SBPopup.isChildOf(this.skin.s["ba"],this,DisplayObject(m.target)) || m.target == this.content) || Boolean(this.content is DisplayObjectContainer && DisplayObjectContainer(this.content).getChildByName("titleDragBar") && m.target == this.content["titleDragBar"])))
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

