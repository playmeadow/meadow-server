package gui
{
   import flash.display.MovieClip;
   
   public class GuiStatusIcon
   {
      
      public function GuiStatusIcon()
      {
         super();
      }
      
      public static function initClip(param1:MovieClip) : void
      {
         param1.visible = false;
         param1["_x"].visible = false;
         param1["_wait"].visible = true;
         param1["_check"].visible = false;
      }
      
      public static function showX(param1:MovieClip) : void
      {
         param1["_x"].visible = true;
         param1["_wait"].visible = false;
         param1["_check"].visible = false;
      }
      
      public static function showWait(param1:MovieClip) : void
      {
         param1["_x"].visible = false;
         param1["_wait"].visible = true;
         param1["_check"].visible = false;
      }
      
      public static function showCheck(param1:MovieClip) : void
      {
         param1["_x"].visible = false;
         param1["_wait"].visible = false;
         param1["_check"].visible = true;
      }
   }
}

