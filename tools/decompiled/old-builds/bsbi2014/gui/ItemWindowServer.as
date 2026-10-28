package gui
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ItemWindowServer extends ItemWindowBase
   {
      
      public function ItemWindowServer(windowLoaded:Function, currItem:MovieClip, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         super("serverBarSml",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.txt.mouseEnabled = false;
         _window.buddy.mouseEnabled = false;
         _window.g1.mouseEnabled = false;
         _window.g2.mouseEnabled = false;
         _window.g3.mouseEnabled = false;
         _window.o1.mouseEnabled = false;
         _window.o2.mouseEnabled = false;
         _window.o3.mouseEnabled = false;
         _window.full.mouseEnabled = false;
         _window.full.mouseChildren = false;
      }
      
      public function get full() : Boolean
      {
         return _window.full.visible;
      }
      
      public function set text(value:String) : void
      {
         _window.txt.text = value;
      }
      
      public function get textField() : TextField
      {
         return _window.txt;
      }
      
      public function set buddy(value:Boolean) : void
      {
         _window.buddy.visible = value;
      }
      
      public function set flag(value:int) : void
      {
         _window.flag.gotoAndStop(value);
      }
      
      public function set population(value:String) : void
      {
         switch(value)
         {
            case "0":
               _window.full.visible = false;
               _window.o1.visible = false;
               _window.o2.visible = false;
               _window.o3.visible = false;
               break;
            case "1":
               _window.o1.visible = true;
               _window.o2.visible = false;
               _window.o3.visible = false;
               _window.full.visible = false;
               break;
            case "2":
               _window.o1.visible = true;
               _window.o2.visible = true;
               _window.o3.visible = false;
               _window.full.visible = false;
               break;
            case "3":
               _window.o1.visible = true;
               _window.o2.visible = true;
               _window.o3.visible = true;
               _window.full.visible = false;
               break;
            case "4":
               _window.full.visible = true;
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window))
         {
            if(_mouseDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener(MouseEvent.ROLL_OVER,_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener(MouseEvent.ROLL_OUT,_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
      }
   }
}

