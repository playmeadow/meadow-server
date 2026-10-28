package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class ItemWindowBook extends ItemWindowBase
   {
      
      private var _mediaHelper:MediaHelper;
      
      public function ItemWindowBook(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super(new (param9.currLoaderAppDomain.getDefinition("eBookLibraryCont") as Class)(),param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(_currItem.mediaId,this.onBookCoverLoaded);
      }
      
      override protected function addEventListeners() : void
      {
         super.addEventListeners();
         _window.itemWindow.addEventListener(MouseEvent.MOUSE_DOWN,this.onBookCoverDown,false,0,true);
      }
      
      private function onBookCoverLoaded(param1:MovieClip) : void
      {
         _window.itemWindow.addChild(param1.getChildAt(0));
      }
      
      private function onBookCoverDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.openEBook(_currItem.listId,true,true);
      }
   }
}

