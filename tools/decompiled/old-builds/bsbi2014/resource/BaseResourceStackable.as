package resource
{
   import com.sbi.loader.IResourceStackable;
   import flash.events.Event;
   
   public class BaseResourceStackable implements IResourceStackable
   {
      
      protected var _resourceDoneLoadingCallback:Function;
      
      public function BaseResourceStackable()
      {
         super();
      }
      
      public function init(callback:Function) : void
      {
         this._resourceDoneLoadingCallback = callback;
      }
      
      protected function resourceLoadCompleteHandler(e:Event) : void
      {
         this._resourceDoneLoadingCallback(this);
         this._resourceDoneLoadingCallback = null;
      }
   }
}

