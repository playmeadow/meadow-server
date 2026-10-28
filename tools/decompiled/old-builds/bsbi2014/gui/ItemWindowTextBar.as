package gui
{
   import flash.text.TextField;
   
   public class ItemWindowTextBar extends ItemWindowBase
   {
      
      public function ItemWindowTextBar(windowLoaded:Function, currItem:String, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super("userDenBtnCont",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         _itemYLocation = currYLocation;
         _itemXLocation = currXLocation;
         if(Boolean(_currItem))
         {
            _window.txt.text = _currItem;
         }
      }
      
      public function get txt() : TextField
      {
         return _window.txt;
      }
      
      public function setText(updateText:String) : void
      {
         _currItem = updateText;
         _window.txt.text = updateText;
      }
   }
}

