package org.osmf.traits
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.LoaderEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="bytesTotalChange",type="org.osmf.events.LoadEvent")]
   [Event(name="loadStateChange",type="org.osmf.events.LoadEvent")]
   public class LoadTrait extends MediaTraitBase
   {
      
      private var loader:LoaderBase;
      
      private var _resource:MediaResourceBase;
      
      private var _loadState:String;
      
      private var _bytesLoaded:Number;
      
      private var _bytesTotal:Number;
      
      public function LoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(MediaTraitType.LOAD);
         this.loader = loader;
         this._resource = resource;
         this._loadState = LoadState.UNINITIALIZED;
         if(loader != null)
         {
            loader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE,this.onLoadStateChange,false,int.MAX_VALUE,true);
         }
      }
      
      public function get resource() : MediaResourceBase
      {
         return this._resource;
      }
      
      public function get loadState() : String
      {
         return this._loadState;
      }
      
      public function load() : void
      {
         if(Boolean(this.loader))
         {
            if(this._loadState == LoadState.READY)
            {
               throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_READY));
            }
            if(this._loadState == LoadState.LOADING)
            {
               throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_LOADING));
            }
            this.loader.load(this);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.MUST_SET_LOADER));
      }
      
      public function unload() : void
      {
         if(Boolean(this.loader))
         {
            if(this._loadState == LoadState.UNLOADING)
            {
               throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADING));
            }
            if(this._loadState == LoadState.UNINITIALIZED)
            {
               throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.ALREADY_UNLOADED));
            }
            this.loader.unload(this);
            return;
         }
         throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.MUST_SET_LOADER));
      }
      
      public function get bytesLoaded() : Number
      {
         return this._bytesLoaded;
      }
      
      public function get bytesTotal() : Number
      {
         return this._bytesTotal;
      }
      
      final protected function setLoadState(newState:String) : void
      {
         if(this._loadState != newState)
         {
            this.loadStateChangeStart(newState);
            this._loadState = newState;
            this.loadStateChangeEnd();
         }
      }
      
      final protected function setBytesLoaded(value:Number) : void
      {
         if(isNaN(value) || value > this.bytesTotal || value < 0)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         if(value != this._bytesLoaded)
         {
            this.bytesLoadedChangeStart(value);
            this._bytesLoaded = value;
            this.bytesLoadedChangeEnd();
         }
      }
      
      final protected function setBytesTotal(value:Number) : void
      {
         if(value < this._bytesLoaded || value < 0)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         if(value != this._bytesTotal)
         {
            this.bytesTotalChangeStart(value);
            this._bytesTotal = value;
            this.bytesTotalChangeEnd();
         }
      }
      
      protected function bytesLoadedChangeStart(newValue:Number) : void
      {
      }
      
      protected function bytesLoadedChangeEnd() : void
      {
      }
      
      protected function bytesTotalChangeStart(newValue:Number) : void
      {
      }
      
      protected function bytesTotalChangeEnd() : void
      {
         dispatchEvent(new LoadEvent(LoadEvent.BYTES_TOTAL_CHANGE,false,false,null,this._bytesTotal));
      }
      
      protected function loadStateChangeStart(newState:String) : void
      {
      }
      
      protected function loadStateChangeEnd() : void
      {
         dispatchEvent(new LoadEvent(LoadEvent.LOAD_STATE_CHANGE,false,false,this._loadState));
      }
      
      private function onLoadStateChange(event:LoaderEvent) : void
      {
         if(event.loadTrait == this)
         {
            this.setLoadState(event.newState);
         }
      }
   }
}

