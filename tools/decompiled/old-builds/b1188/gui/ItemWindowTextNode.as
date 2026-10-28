package gui
{
   import flash.events.MouseEvent;
   
   public class ItemWindowTextNode extends ItemWindowBase
   {
      
      private var _originalText:String;
      
      public function ItemWindowTextNode(param1:Function, param2:String, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("chatTextNode",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_currItem)
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
      
      public function updateToBeCentered(param1:int) : void
      {
         _window.x += (param1 - _window.width) * 0.5;
      }
      
      private function setupText() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         _window.txt.text = _currItem;
         this._originalText = String(_currItem);
         if(_window.txt.textWidth > _window.txt.width)
         {
            _window.txt.text = "";
            _loc1_ = 0;
            _loc2_ = "";
            while(_window.txt.textWidth < _window.txt.width)
            {
               _loc2_ += String(_currItem).charAt(_loc1_);
               _window.txt.text = _loc2_ + "...";
               _loc1_++;
            }
            _window.txt.text = _loc2_.slice(0,_loc2_.length - 1) + "...";
         }
      }
      
      private function onRollOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(Boolean(_window) && _window.currentFrameLabel != "on")
         {
            _window.gotoAndStop("on");
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function onRollOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(Boolean(_window) && _window.currentFrameLabel != "off")
         {
            _window.gotoAndStop("off");
         }
      }
   }
}

