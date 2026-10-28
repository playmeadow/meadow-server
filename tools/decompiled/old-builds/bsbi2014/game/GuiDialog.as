package game
{
   import flash.display.MovieClip;
   
   public class GuiDialog
   {
      
      private var _mc:MovieClip;
      
      private var _buttons:Array;
      
      public function GuiDialog(mc:MovieClip, buttons:Array)
      {
         var i:int = 0;
         var o:Object = null;
         var btn_mc:MovieClip = null;
         var btn:GuiButton = null;
         var buttonname:String = null;
         var buttonObject:Object = null;
         var layername:String = null;
         super();
         this._mc = mc;
         for(this._buttons = []; i < buttons.length; )
         {
            o = buttons[i];
            btn_mc = this._mc[o.name];
            if(!btn_mc)
            {
               buttonname = o.name;
               buttonObject = this._mc;
               while(buttonname.indexOf(".") != -1)
               {
                  layername = buttonname.substring(0,buttonname.indexOf("."));
                  buttonObject = buttonObject[layername];
                  buttonname = buttonname.substring(buttonname.indexOf(".") + 1,buttonname.length);
               }
               btn_mc = buttonObject[buttonname];
               if(!btn_mc)
               {
                  throw new Error("ERROR: Button Not Found:\" " + o.name + "\" verify button names across SWF files.");
               }
            }
            btn = new GuiButton(btn_mc,o.f);
            i++;
         }
      }
      
      public function release() : void
      {
         for(var i:int = 0; i < this._buttons.length; )
         {
            this._buttons.release();
            i++;
         }
         this._buttons = [];
      }
   }
}

