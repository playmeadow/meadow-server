package org.osmf.elements
{
   import flash.events.Event;
   import org.osmf.elements.proxyClasses.LoadFromDocumentLoadTrait;
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.utils.OSMFStrings;
   
   public class LoadFromDocumentElement extends ProxyElement
   {
      
      private var _resource:MediaResourceBase;
      
      private var loadTrait:LoadFromDocumentLoadTrait;
      
      private var loader:LoaderBase;
      
      public function LoadFromDocumentElement(resource:MediaResourceBase = null, loader:LoaderBase = null)
      {
         super(null);
         this.loader = loader;
         this.resource = resource;
         if(loader == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
      }
      
      override public function set resource(value:MediaResourceBase) : void
      {
         if(this._resource != value && value != null)
         {
            this._resource = value;
            this.loadTrait = new LoadFromDocumentLoadTrait(this.loader,this.resource);
            this.loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE,this.onLoadStateChange,false,int.MAX_VALUE);
            if(super.getTrait(MediaTraitType.LOAD) != null)
            {
               super.removeTrait(MediaTraitType.LOAD);
            }
            super.addTrait(MediaTraitType.LOAD,this.loadTrait);
         }
      }
      
      override public function get resource() : MediaResourceBase
      {
         return this._resource;
      }
      
      private function onLoaderStateChange(event:Event) : void
      {
         removeTrait(MediaTraitType.LOAD);
         proxiedElement = this.loadTrait.mediaElement;
      }
      
      private function onLoadStateChange(event:LoadEvent) : void
      {
         var proxiedLoadTrait:LoadTrait = null;
         var onProxiedElementLoadStateChange:Function = null;
         if(event.loadState == LoadState.READY)
         {
            onProxiedElementLoadStateChange = function(event:LoadEvent):void
            {
               if(event.loadState == LoadState.LOADING)
               {
                  event.stopImmediatePropagation();
               }
               else
               {
                  proxiedLoadTrait.removeEventListener(LoadEvent.LOAD_STATE_CHANGE,onProxiedElementLoadStateChange);
               }
            };
            event.stopImmediatePropagation();
            removeTrait(MediaTraitType.LOAD);
            proxiedLoadTrait = this.loadTrait.mediaElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
            proxiedLoadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE,onProxiedElementLoadStateChange,false,int.MAX_VALUE);
            proxiedElement = this.loadTrait.mediaElement;
            if(proxiedLoadTrait.loadState == LoadState.UNINITIALIZED)
            {
               proxiedLoadTrait.load();
            }
         }
      }
   }
}

