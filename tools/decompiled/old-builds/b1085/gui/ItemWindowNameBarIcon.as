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
      
      public function ItemWindowNameBarIcon(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._currFrameLabel = param9.currFrameLabel;
         this._loadIcons = param9.loadIcons;
         this._callbackFunction = param9.callbackFunction;
         super("selNub",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get mouse() : MovieClip
      {
         return _window.mouse;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
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
         if(_currItem)
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
      
      private function onIconsLoaded(param1:MovieClip) : void
      {
         if(Boolean(param1) && Boolean(_window))
         {
            if(this._icon1 == null)
            {
               this._icon1 = param1;
               this._iconsMediaHelper = new MediaHelper();
               this._iconsMediaHelper.init(int(_currItem),this.onIconsLoaded);
            }
            else
            {
               this._loadIcons = false;
               this._icon2 = param1;
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

