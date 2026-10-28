package gui
{
   import flash.display.DisplayObject;
   
   public class ItemWindowStamp extends ItemWindowBase
   {
      
      public function ItemWindowStamp(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("StampBtn",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         _itemYLocation = param1;
         _itemXLocation = param2;
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            if(_iconLayerName != "" && _currItem.hasOwnProperty(_iconLayerName))
            {
               _window.imgLayer.addChild(_currItem[_iconLayerName]);
            }
            else
            {
               _window.imgLayer.addChild(DisplayObject(_currItem));
            }
         }
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _currItem[_iconLayerName].scaleX = 0.6;
         _currItem[_iconLayerName].scaleY = 0.6;
      }
   }
}

