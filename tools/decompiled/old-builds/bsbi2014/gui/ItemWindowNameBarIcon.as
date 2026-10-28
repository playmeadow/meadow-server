package gui
{
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class ItemWindowNameBarIcon extends ItemWindowBase
   {
      
      private var _currFrameLabel:String;
      
      private var _loadIcons:Boolean;
      
      private var _icon1:MovieClip;
      
      private var _icon2:MovieClip;
      
      private var _iconsMediaHelper:MediaHelper;
      
      private var _callbackFunction:Function;
      
      private var _triedToLoadCurrItem:Boolean;
      
      public function ItemWindowNameBarIcon(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._currFrameLabel = customParams.currFrameLabel;
         this._loadIcons = customParams.loadIcons;
         this._callbackFunction = customParams.callbackFunction;
         super("selNub",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      public function get mouse() : MovieClip
      {
         return _window.mouse;
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         _itemYLocation = currYLocation;
         _itemXLocation = currXLocation;
         if(Boolean(_currItem && !_isCurrItemLoaded) && Boolean(!this._loadIcons) && _window.hasOwnProperty("mouse"))
         {
            _isCurrItemLoaded = true;
            _window.mouse.gotoAndStop(1);
            _window.mouse.mouse.icon.addChild(_currItem.iconMouse);
            _window.mouse.up.icon.addChild(_currItem.iconUp);
         }
         else
         {
            this._triedToLoadCurrItem = true;
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(Boolean(_currItem))
         {
            _window.scaleX = 1.5;
            _window.scaleY = 1.5;
            _window.gotoAndStop(this._currFrameLabel);
            _window = _window[this._currFrameLabel];
            _window.y += _window.height * 0.5;
            while(_window.mouse.mouse.icon.numChildren > 0)
            {
               _window.mouse.mouse.icon.removeChildAt(0);
            }
            while(_window.mouse.up.icon.numChildren > 0)
            {
               _window.mouse.up.icon.removeChildAt(0);
            }
            if(this._loadIcons)
            {
               _window.mouse.gotoAndStop(1);
               this.loadIcon();
            }
         }
         else
         {
            _window.visible = false;
         }
      }
      
      private function loadIcon() : void
      {
         this._iconsMediaHelper = new MediaHelper();
         this._iconsMediaHelper.init(int(_currItem),this.onIconsLoaded);
      }
      
      private function onIconsLoaded(mc:MovieClip) : void
      {
         if(Boolean(mc) && Boolean(_window))
         {
            if(this._icon1 == null)
            {
               this._icon1 = mc;
               this._iconsMediaHelper = new MediaHelper();
               this._iconsMediaHelper.init(int(_currItem),this.onIconsLoaded);
            }
            else
            {
               this._loadIcons = false;
               this._icon2 = mc;
               _currItem = {
                  "iconMouse":this._icon1,
                  "iconUp":this._icon2
               };
               this._callbackFunction(this._icon1,this._icon2,_index);
               this._icon1 = null;
               this._icon2 = null;
               this._callbackFunction = null;
               this._iconsMediaHelper.destroy();
               this._iconsMediaHelper = null;
               if(this._triedToLoadCurrItem)
               {
                  this.loadCurrItem();
               }
            }
         }
      }
   }
}

