package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   
   public class WelcomeToCarnival
   {
      
      public static const WELCOME_CARNIVAL_MEDIA_ID:int = 1594;
      
      private var _popup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      public function WelcomeToCarnival()
      {
         super();
      }
      
      public function init() : void
      {
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(WELCOME_CARNIVAL_MEDIA_ID,this.mediaCallback,true);
      }
      
      public function destroy() : void
      {
         this.removeListeners();
         this._mediaHelper.destroy();
         GuiManager.guiLayer.removeChild(this._popup);
         DarkenManager.unDarken(this._popup);
         this._popup = null;
      }
      
      private function mediaCallback(param1:MovieClip) : void
      {
         this._popup = MovieClip(param1.getChildAt(0));
         this._popup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._popup.y = MainFrame.VIEW_HEIGHT * 0.5;
         GuiManager.guiLayer.addChild(this._popup);
         this.addListeners();
         this.setInitialConditions();
         DarkenManager.showLoadingSpiral(false);
         DarkenManager.darken(this._popup);
      }
      
      private function setInitialConditions() : void
      {
      }
      
      private function popupCloseHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this.destroy();
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function addListeners() : void
      {
         this._popup["bx"].addEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler,false,0,true);
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
      }
      
      private function removeListeners() : void
      {
         this._popup["bx"].removeEventListener(MouseEvent.MOUSE_DOWN,this.popupCloseHandler);
         this._popup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
      }
   }
}

