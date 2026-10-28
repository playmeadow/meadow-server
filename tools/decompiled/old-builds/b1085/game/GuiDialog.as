package game
{
   import flash.display.MovieClip;
   
   public class GuiDialog
   {
      
      private var _mc:MovieClip;
      
      private var _buttons:Array;
      
      public function GuiDialog(param1:MovieClip, param2:Array)
      {
         var _loc3_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:MovieClip = null;
         var _loc6_:GuiButton = null;
         var _loc7_:String = null;
         var _loc8_:Object = null;
         var _loc9_:String = null;
         super();
         this._mc = param1;
         this._buttons = [];
         while(_loc3_ < param2.length)
         {
            _loc4_ = param2[_loc3_];
            _loc5_ = this._mc[_loc4_.name];
            if(!_loc5_)
            {
               _loc7_ = _loc4_.name;
               _loc8_ = this._mc;
               while(_loc7_.indexOf(".") != -1)
               {
                  _loc9_ = _loc7_.substring(0,_loc7_.indexOf("."));
                  _loc8_ = _loc8_[_loc9_];
                  _loc7_ = _loc7_.substring(_loc7_.indexOf(".") + 1,_loc7_.length);
               }
               _loc5_ = _loc8_[_loc7_];
               if(!_loc5_)
               {
                  throw new Error("ERROR: Button Not Found:\" " + _loc4_.name + "\" verify button names across SWF files.");
               }
            }
            _loc6_ = new GuiButton(_loc5_,_loc4_.f);
            _loc3_++;
         }
      }
      
      public function release() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < this._buttons.length)
         {
            this._buttons.release();
            _loc1_++;
         }
         this._buttons = [];
      }
   }
}

