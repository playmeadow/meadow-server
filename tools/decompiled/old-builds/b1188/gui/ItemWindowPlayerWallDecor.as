package gui
{
   import flash.events.MouseEvent;
   
   public class ItemWindowPlayerWallDecor extends ItemWindowBase
   {
      
      public function ItemWindowPlayerWallDecor(param1:Function, param2:Object, param3:String, param4:int, param5:Function, param6:Function, param7:Function, param8:Function, param9:Boolean = false)
      {
         super(param2,param1,null,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override protected function addEventListeners() : void
      {
         if(_mouseDown != null)
         {
            addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
         }
      }
   }
}

