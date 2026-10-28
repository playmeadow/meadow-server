package org.osmf.media
{
   import org.osmf.events.LoadEvent;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitType;
   
   public class LoadableElementBase extends MediaElement
   {
      
      private var _loader:LoaderBase;
      
      public function LoadableElementBase(resource:MediaResourceBase = null, loader:LoaderBase = null)
      {
         super();
         this._loader = loader;
         this.resource = resource;
      }
      
      override public function set resource(value:MediaResourceBase) : void
      {
         super.resource = value;
         this.updateLoadTrait();
      }
      
      final protected function get loader() : LoaderBase
      {
         return this._loader;
      }
      
      final protected function set loader(value:LoaderBase) : void
      {
         this._loader = value;
      }
      
      protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase) : LoadTrait
      {
         return new LoadTrait(this._loader,resource);
      }
      
      protected function processLoadingState() : void
      {
      }
      
      protected function processReadyState() : void
      {
      }
      
      protected function processUnloadingState() : void
      {
      }
      
      protected function getLoaderForResource(resource:MediaResourceBase, alternateLoaders:Vector.<LoaderBase>) : LoaderBase
      {
         var loaderFound:Boolean = false;
         var alternateLoader:LoaderBase = null;
         var result:LoaderBase = this.loader;
         if(resource != null && (this.loader == null || this.loader.canHandleResource(resource) == false))
         {
            loaderFound = false;
            for each(alternateLoader in alternateLoaders)
            {
               if(this.loader == null || this.loader != alternateLoader)
               {
                  if(alternateLoader.canHandleResource(resource))
                  {
                     result = alternateLoader;
                     break;
                  }
               }
            }
            if(result == null && alternateLoaders != null)
            {
               result = alternateLoaders[alternateLoaders.length - 1];
            }
         }
         return result;
      }
      
      private function onLoadStateChange(event:LoadEvent) : void
      {
         if(event.loadState == LoadState.LOADING)
         {
            this.processLoadingState();
         }
         else if(event.loadState == LoadState.READY)
         {
            this.processReadyState();
         }
         else if(event.loadState == LoadState.UNLOADING)
         {
            this.processUnloadingState();
         }
      }
      
      private function updateLoadTrait() : void
      {
         var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
         if(loadTrait != null)
         {
            if(loadTrait.loadState == LoadState.READY)
            {
               loadTrait.unload();
            }
            loadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE,this.onLoadStateChange);
            removeTrait(MediaTraitType.LOAD);
         }
         if(this.loader != null)
         {
            loadTrait = this.createLoadTrait(resource,this.loader);
            loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE,this.onLoadStateChange,false,10);
            addTrait(MediaTraitType.LOAD,loadTrait);
         }
      }
   }
}

