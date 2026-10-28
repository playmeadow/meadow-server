package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import org.osmf.events.LoaderEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="loadStateChange",type="org.osmf.events.LoaderEvent")]
   public class LoaderBase extends EventDispatcher
   {
      
      public function LoaderBase()
      {
         super();
      }
      
      public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         return false;
      }
      
      final public function load(loadTrait:LoadTrait) : void
      {
         this.validateLoad(loadTrait);
         this.executeLoad(loadTrait);
      }
      
      final public function unload(loadTrait:LoadTrait) : void
      {
         this.validateUnload(loadTrait);
         this.executeUnload(loadTrait);
      }
      
      protected function executeLoad(loadTrait:LoadTrait) : void
      {
      }
      
      protected function executeUnload(loadTrait:LoadTrait) : void
      {
      }
      
      final protected function updateLoadTrait(loadTrait:LoadTrait, newState:String) : void
      {
         var oldState:String = null;
         if(newState != loadTrait.loadState)
         {
            oldState = loadTrait.loadState;
            dispatchEvent(new LoaderEvent(LoaderEvent.LOAD_STATE_CHANGE,false,false,this,loadTrait,oldState,newState));
         }
      }
      
      private function validateLoad(loadTrait:LoadTrait) : void
      {
         if(loadTrait == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(loadTrait.loadState == LoadState.READY)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_READY));
         }
         if(loadTrait.loadState == LoadState.LOADING)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_LOADING));
         }
         if(this.canHandleResource(loadTrait.resource) == false)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.LOADER_CANT_HANDLE_RESOURCE));
         }
      }
      
      private function validateUnload(loadTrait:LoadTrait) : void
      {
         if(loadTrait == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         if(loadTrait.loadState == LoadState.UNLOADING)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADING));
         }
         if(loadTrait.loadState == LoadState.UNINITIALIZED)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADED));
         }
         if(this.canHandleResource(loadTrait.resource) == false)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.LOADER_CANT_HANDLE_RESOURCE));
         }
      }
   }
}

