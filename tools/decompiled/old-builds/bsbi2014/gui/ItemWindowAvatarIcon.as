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
      
      public function ItemWindowAvatarIcon(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._currColor = customParams.currColor;
         this._currIconId = int(currItem);
         super(1734,windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      public function updateColor(newColor:String) : void
      {
         this._currColor = newColor;
         if(Boolean(_window))
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
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         if(_currItem is int)
         {
            _itemYLocation = currYLocation;
            _itemXLocation = currXLocation;
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
      
      private function onCurrItemLoaded(img:MovieClip) : void
      {
         if(Boolean(img))
         {
            _currItem = img.getChildAt(0);
            this.loadCurrItem();
         }
      }
   }
}

