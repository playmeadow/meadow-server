package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   import loader.MediaHelper;
   
   public class ItemWindowBase extends MovieClip
   {
      
      protected var _window:MovieClip;
      
      protected var _currItem:Object;
      
      protected var _mouseDown:Function;
      
      protected var _mouseOver:Function;
      
      protected var _mouseOut:Function;
      
      protected var _memberOnlyDown:Function;
      
      protected var _index:int;
      
      protected var _spiral:LoadingSpiral;
      
      protected var _windowLoadedCallback:Function;
      
      protected var _iconLayerName:String;
      
      protected var _isCurrItemLoaded:Boolean;
      
      protected var _itemYLocation:int;
      
      protected var _itemXLocation:int;
      
      protected var _useToolTip:Boolean;
      
      protected var _windowGenerator:WindowGenerator;
      
      private var _windowMediaHelper:MediaHelper;
      
      private var _memberOnlyTrackingName:String;
      
      public function ItemWindowBase(param1:*, param2:Function, param3:Object, param4:String, param5:int, param6:Function, param7:Function, param8:Function, param9:Function, param10:Boolean = false)
      {
         super();
         this._currItem = param3;
         this._iconLayerName = param4;
         this._mouseDown = param6;
         this._mouseOver = param7;
         this._mouseOut = param8;
         this._memberOnlyDown = param9;
         this._index = param5;
         this._windowLoadedCallback = param2;
         this._useToolTip = param10;
         if(param1 is String)
         {
            this._window = new (getDefinitionByName(param1) as Class)();
            addChild(this._window);
            this.addEventListeners();
            this.setChildrenAndInitialConditions();
            this.onWindowLoadCallback();
         }
         else
         {
            if(!(param1 is int))
            {
               throw new Error("windowClassOrId is not of type string or int. WindowClassOrId = " + param1);
            }
            this._windowMediaHelper = new MediaHelper();
            this._windowMediaHelper.init(param1,this.onWindowLoaded);
         }
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(this._spiral)
         {
            this._spiral.destroy();
         }
         if(this._windowMediaHelper)
         {
            this._windowMediaHelper.destroy();
         }
         if(Boolean(this._window) && this._window.parent == this)
         {
            removeChild(this._window);
         }
         if(Boolean(this._currItem) && this._currItem.hasOwnProperty("destroy"))
         {
            this._currItem.destroy();
         }
         this._windowGenerator = null;
         this._window = null;
         this._windowLoadedCallback = null;
         this._currItem = null;
         this._mouseDown = null;
         this._mouseOver = null;
         this._mouseOut = null;
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         this._itemYLocation = param1;
         this._itemXLocation = param2;
         if(Boolean(this._currItem) && !this._isCurrItemLoaded)
         {
            this._isCurrItemLoaded = true;
            if(this._iconLayerName != "" && this._currItem.hasOwnProperty(this._iconLayerName))
            {
               this._window.addChild(this._currItem[this._iconLayerName]);
            }
            else
            {
               this._window.addChild(DisplayObject(this._currItem));
            }
         }
      }
      
      protected function onWindowLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            this._window = MovieClip(param1.getChildAt(0));
            addChild(this._window);
            this.setChildrenAndInitialConditions();
            this.onWindowLoadCallback();
            this.addEventListeners();
            this._windowMediaHelper.destroy();
            this._windowMediaHelper = null;
         }
      }
      
      protected function onWindowLoadCallback() : void
      {
         if(this._windowLoadedCallback != null)
         {
            this._windowLoadedCallback(this);
         }
      }
      
      protected function setChildrenAndInitialConditions() : void
      {
      }
      
      protected function onWindowRollOver(param1:MouseEvent) : void
      {
         if(this._useToolTip && this.parent != null)
         {
            if(this._windowGenerator == null)
            {
               this._windowGenerator = WindowGenerator(this.parent.parent);
            }
            this._windowGenerator.toolTip.init(this._windowGenerator.parent.parent,this._currItem.name,this.x + this._windowGenerator.boxWidth * 0.5 + this._windowGenerator.parent.x + this._itemXLocation,this.y + this._windowGenerator.boxHeight - this._itemYLocation + this._windowGenerator.parent.y - 5);
            this._windowGenerator.toolTip.startTimer(param1);
         }
      }
      
      protected function onWindowRollOut(param1:MouseEvent) : void
      {
         if(this._useToolTip && this.parent != null)
         {
            this._windowGenerator.toolTip.resetTimerAndSetVisibility();
         }
      }
      
      protected function addEventListeners() : void
      {
         if(Boolean(this._window) && Boolean(this._currItem))
         {
            if(this._mouseDown != null && !(this._memberOnlyDown != null && !gMainFrame.userInfo.isMember))
            {
               addEventListener(MouseEvent.MOUSE_DOWN,this._mouseDown,false,0,true);
            }
            if(this._mouseOver != null)
            {
               if(this._useToolTip)
               {
                  addEventListener(MouseEvent.ROLL_OVER,this.onWindowRollOver,false,0,true);
               }
               addEventListener(MouseEvent.ROLL_OVER,this._mouseOver,false,0,true);
            }
            if(this._mouseOut != null)
            {
               if(this._useToolTip)
               {
                  addEventListener(MouseEvent.ROLL_OUT,this.onWindowRollOut,false,0,true);
               }
               addEventListener(MouseEvent.ROLL_OUT,this._mouseOut,false,0,true);
            }
            if(this._memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,this._memberOnlyDown,false,0,true);
            }
         }
      }
      
      protected function removeEventListeners() : void
      {
         if(this._mouseDown != null)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this._mouseDown);
         }
         if(this._mouseOver != null)
         {
            if(this._useToolTip)
            {
               removeEventListener(MouseEvent.ROLL_OVER,this.onWindowRollOut);
            }
            removeEventListener(MouseEvent.ROLL_OVER,this._mouseOver);
         }
         if(this._mouseOut != null)
         {
            if(this._useToolTip)
            {
               removeEventListener(MouseEvent.ROLL_OUT,this.onWindowRollOut);
            }
            removeEventListener(MouseEvent.ROLL_OUT,this._mouseOut);
         }
         if(this._memberOnlyDown != null)
         {
            removeEventListener(MouseEvent.MOUSE_DOWN,this._memberOnlyDown);
         }
      }
   }
}

