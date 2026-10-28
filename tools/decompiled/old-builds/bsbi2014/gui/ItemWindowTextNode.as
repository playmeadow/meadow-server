package gui
{
   import flash.events.MouseEvent;
   
   public class ItemWindowTextNode extends ItemWindowBase
   {
      
      private var _originalText:String;
      
      public function ItemWindowTextNode(windowLoaded:Function, currItem:String, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super("chatTextNode",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(Boolean(_currItem))
         {
            this.setupText();
         }
         addEventListener(MouseEvent.ROLL_OVER,this.onRollOver,false,0,true);
         addEventListener(MouseEvent.ROLL_OUT,this.onRollOut,false,0,true);
      }
      
      override protected function removeEventListeners() : void
      {
         removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         super.removeEventListeners();
      }
      
      public function get text() : String
      {
         return this._originalText;
      }
      
      public function updateToBeCentered(totalWidth:int) : void
      {
         _window.x += (totalWidth - _window.width) * 0.5;
      }
      
      private function setupText() : void
      {
         var i:int = 0;
         var currString:String = null;
         _window.txt.text = _currItem;
         this._originalText = String(_currItem);
         if(_window.txt.textWidth > _window.txt.width)
         {
            _window.txt.text = "";
            i = 0;
            currString = "";
            while(_window.txt.textWidth < _window.txt.width)
            {
               currString += String(_currItem).charAt(i);
               _window.txt.text = currString + "...";
               i++;
            }
            _window.txt.text = currString.slice(0,currString.length - 1) + "...";
         }
      }
      
      private function onRollOver(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(_window) && _window.currentFrameLabel != "on")
         {
            _window.gotoAndStop("on");
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function onRollOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(Boolean(_window) && _window.currentFrameLabel != "off")
         {
            _window.gotoAndStop("off");
         }
      }
   }
}

