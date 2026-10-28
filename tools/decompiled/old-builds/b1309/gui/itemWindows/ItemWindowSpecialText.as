package gui.itemWindows
{
   import flash.text.TextField;
   
   public class ItemWindowSpecialText extends ItemWindowBase
   {
      
      public function ItemWindowSpecialText(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         super("specialCharHighlightCont",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_currItem)
         {
            _window.txt.text = _currItem;
         }
         _window.txt.mouseEnabled = false;
         _window.up.mouseEnabled = false;
         _window.up.visible = false;
      }
      
      public function get txt() : TextField
      {
         return _window.txt;
      }
      
      public function setText(param1:String) : void
      {
         _currItem = param1;
         _window.txt.text = param1;
      }
   }
}

