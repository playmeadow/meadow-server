package gui
{
   import ecard.ECardImageBase;
   
   public class ItemWindowStamp extends ItemWindowBase
   {
      
      private var stampImageBase:ECardImageBase;
      
      public function ItemWindowStamp(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super("StampBtn",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         _itemYLocation = currYLocation;
         _itemXLocation = currXLocation;
         if(Boolean(_currItem) && !_isCurrItemLoaded)
         {
            _isCurrItemLoaded = true;
            this.stampImageBase = new ECardImageBase();
            this.stampImageBase.init(int(_currItem),this.onImageLoaded);
         }
      }
      
      private function onImageLoaded() : void
      {
         if(_iconLayerName != "" && this.stampImageBase.hasOwnProperty(_iconLayerName))
         {
            _window.imgLayer.addChild(this.stampImageBase[_iconLayerName]);
         }
         this.stampImageBase[_iconLayerName].scaleX = 0.6;
         this.stampImageBase[_iconLayerName].scaleY = 0.6;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
      }
   }
}

