package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.ui.Mouse;
   import gui.CursorManager;
   
   public class LoadCursorResourceStackable implements IResourceStackable
   {
      
      public function LoadCursorResourceStackable()
      {
         super();
      }
      
      public function init(callback:Function) : void
      {
         if(Boolean(Mouse["supportsNativeCursor"]))
         {
            CursorManager.init();
         }
         callback(this);
      }
   }
}

