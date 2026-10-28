package gui
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import loader.MediaHelper;
   
   public class ItemWindowAvatarIcon extends ItemWindowBase
   {
      
      private var _currColor:String;
      
      private var _mediaHelper:MediaHelper;
      
      private var _currIconId:int;
      
      public function ItemWindowAvatarIcon(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._currColor = param9.currColor;
         this._currIconId = int(param2);
         super(1734,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function updateColor(param1:String) : void
      {
         this._currColor = param1;
         if(_window)
         {
            _window.gotoAndStop(this._currColor);
         }
      }
      
      public function get currIconId() : int
      {
         return this._currIconId;
      }
      
      public function get currWindow() : MovieClip
      {
         return _window;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         if(_currItem is int)
         {
            _itemYLocation = param1;
            _itemXLocation = param2;
            this._mediaHelper = new MediaHelper();
            this._mediaHelper.init(int(_currItem),this.onCurrItemLoaded);
         }
         else if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            if(_iconLayerName != "" && _currItem.hasOwnProperty(_iconLayerName))
            {
               _window.itemWindow.addChild(_currItem[_iconLayerName]);
            }
            else
            {
               _window.itemWindow.addChild(DisplayObject(_currItem));
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.gotoAndStop(this._currColor);
      }
      
      private function onCurrItemLoaded(param1:MovieClip) : void
      {
         if(param1)
         {
            _currItem = param1.getChildAt(0);
            this.loadCurrItem();
         }
      }
   }
}

