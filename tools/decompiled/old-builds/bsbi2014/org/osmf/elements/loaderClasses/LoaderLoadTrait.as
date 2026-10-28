package org.osmf.elements.loaderClasses
{
   import flash.display.Loader;
   import flash.events.ProgressEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   [ExcludeClass]
   public class LoaderLoadTrait extends LoadTrait
   {
      
      private var _loader:Loader;
      
      public function LoaderLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      public function set loader(value:Loader) : void
      {
         this._loader = value;
      }
      
      override protected function loadStateChangeStart(newState:String) : void
      {
         if(newState == LoadState.LOADING)
         {
            this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onContentLoadProgress,false,0,true);
         }
         else if(newState == LoadState.READY)
         {
            setBytesTotal(this.loader.contentLoaderInfo.bytesTotal);
            setBytesLoaded(this.loader.contentLoaderInfo.bytesLoaded);
            this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.onContentLoadProgress,false,0,true);
         }
         else if(newState == LoadState.UNINITIALIZED)
         {
            setBytesLoaded(0);
         }
      }
      
      private function onContentLoadProgress(event:ProgressEvent) : void
      {
         setBytesTotal(event.bytesTotal);
         setBytesLoaded(event.bytesLoaded);
      }
   }
}

