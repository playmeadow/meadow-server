package game
{
   import flash.display.MovieClip;
   
   public class GuiDialog
   {
      
      private var _mc:MovieClip;
      
      private var _buttons:Array;
      
      public function GuiDialog(param1:MovieClip, param2:Array)
      {
         var _loc9_:int = 0;
         var _loc5_:Object = null;
         var _loc8_:MovieClip = null;
         var _loc7_:String = null;
         var _loc4_:Object = null;
         var _loc6_:String = null;
         var _loc3_:GuiButton = null;
         super();
         _mc = param1;
         _buttons = [];
         while(_loc9_ < param2.length)
         {
            _loc5_ = param2[_loc9_];
            _loc8_ = _mc[_loc5_.name];
            if(!_loc8_)
            {
               _loc7_ = _loc5_.name;
               _loc4_ = _mc;
               while(_loc7_.indexOf(".") != -1)
               {
                  _loc6_ = _loc7_.substring(0,_loc7_.indexOf("."));
                  _loc4_ = _loc4_[_loc6_];
                  _loc7_ = _loc7_.substring(_loc7_.indexOf(".") + 1,_loc7_.length);
               }
               _loc8_ = _loc4_[_loc7_];
               if(!_loc8_)
               {
                  throw new Error("ERROR: Button Not Found:\" " + _loc5_.name + "\" verify button names across SWF files.");
               }
            }
            _loc3_ = new GuiButton(_loc8_,_loc5_.f);
            _loc9_++;
         }
      }
      
      public function release() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _buttons.length)
         {
            _buttons.release();
            _loc1_++;
         }
         _buttons = [];
      }
   }
}

