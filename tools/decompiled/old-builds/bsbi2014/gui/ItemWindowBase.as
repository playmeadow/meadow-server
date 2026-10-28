package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
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
      
      public function ItemWindowBase(windowClassOrId:*, windowLoadedCallback:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function, mouseOver:Function, mouseOut:Function, memberOnlyDown:Function, useToolTip:Boolean = false)
      {
         var split:Array = null;
         super();
         this._currItem = currItem;
         this._iconLayerName = iconLayerName;
         this._mouseDown = mouseDown;
         this._mouseOver = mouseOver;
         this._mouseOut = mouseOut;
         this._memberOnlyDown = memberOnlyDown;
         this._index = index;
         this._windowLoadedCallback = windowLoadedCallback;
         this._useToolTip = useToolTip;
         if(windowClassOrId is String)
         {
            split = String(windowClassOrId).split("|");
            this._window = GETDEFINITIONBYNAME(split[0],split.length > 1 ? false : true);
            addChild(this._window);
            this.addEventListeners();
            this.setChildrenAndInitialConditions();
            this.onWindowLoadCallback();
         }
         else
         {
            if(!(windowClassOrId is int))
            {
               throw new Error("windowClassOrId is not of type string or int. WindowClassOrId = " + windowClassOrId);
            }
            this._windowMediaHelper = new MediaHelper();
            this._windowMediaHelper.init(windowClassOrId,this.onWindowLoaded);
         }
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         if(Boolean(this._spiral))
         {
            this._spiral.destroy();
         }
         if(Boolean(this._windowMediaHelper))
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
      
      public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         this._itemYLocation = currYLocation;
         this._itemXLocation = currXLocation;
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
      
      protected function onWindowLoaded(mc:MovieClip) : void
      {
         if(Boolean(mc))
         {
            this._window = MovieClip(mc.getChildAt(0));
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
      
      protected function onWindowRollOver(evt:MouseEvent) : void
      {
         if(this._useToolTip && this.parent != null)
         {
            if(this._windowGenerator == null)
            {
               this._windowGenerator = WindowGenerator(this.parent.parent);
            }
            this._windowGenerator.toolTip.init(this._windowGenerator.parent.parent,this._currItem.name,this.x + this._windowGenerator.boxWidth * 0.5 + this._windowGenerator.parent.x + this._itemXLocation,this.y + this._windowGenerator.boxHeight - this._itemYLocation + this._windowGenerator.parent.y - 5);
            this._windowGenerator.toolTip.startTimer(evt);
         }
      }
      
      protected function onWindowRollOut(evt:MouseEvent) : void
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

