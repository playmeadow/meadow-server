package org.osmf.elements
{
   import org.osmf.elements.proxyClasses.ProxyMetadata;
   import org.osmf.events.ContainerChangeEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.metadata.Metadata;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.utils.OSMFStrings;
   
   public class ProxyElement extends MediaElement
   {
      
      private var _proxiedMetadata:ProxyMetadata;
      
      private var _proxiedElement:MediaElement;
      
      private var _blockedTraits:Vector.<String>;
      
      public function ProxyElement(proxiedElement:MediaElement = null)
      {
         super();
         this.addEventListener(MediaElementEvent.TRAIT_ADD,this.onProxyTraitAdd,false,int.MAX_VALUE);
         this.addEventListener(MediaElementEvent.TRAIT_REMOVE,this.onProxyTraitRemove,false,int.MAX_VALUE);
         this.addEventListener(ContainerChangeEvent.CONTAINER_CHANGE,this.onProxyContainerChange);
         this.proxiedElement = proxiedElement;
      }
      
      public function get proxiedElement() : MediaElement
      {
         return this._proxiedElement;
      }
      
      public function set proxiedElement(value:MediaElement) : void
      {
         var traitType:String = null;
         if(value != this._proxiedElement)
         {
            if(this._proxiedElement != null)
            {
               this.toggleMediaElementListeners(this._proxiedElement,false);
               for each(traitType in this._proxiedElement.traitTypes)
               {
                  if(super.hasTrait(traitType) == false && (this._blockedTraits == null || this._blockedTraits.indexOf(traitType) == -1))
                  {
                     super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE,false,false,traitType));
                  }
               }
            }
            this._proxiedElement = value;
            if(this._proxiedElement != null)
            {
               ProxyMetadata(metadata).metadata = this._proxiedElement.metadata;
               this._proxiedElement.dispatchEvent(new ContainerChangeEvent(ContainerChangeEvent.CONTAINER_CHANGE,false,false,this._proxiedElement.container,container));
               this.toggleMediaElementListeners(this._proxiedElement,true);
               for each(traitType in this._proxiedElement.traitTypes)
               {
                  if(super.hasTrait(traitType) == false && (this._blockedTraits == null || this._blockedTraits.indexOf(traitType) == -1))
                  {
                     super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD,false,false,traitType));
                  }
               }
            }
         }
      }
      
      override public function get traitTypes() : Vector.<String>
      {
         var traitType:String = null;
         var results:Vector.<String> = new Vector.<String>();
         for each(traitType in MediaTraitType.ALL_TYPES)
         {
            if(this.hasTrait(traitType))
            {
               results.push(traitType);
            }
         }
         return results;
      }
      
      override public function hasTrait(type:String) : Boolean
      {
         if(type == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this.getTrait(type) != null;
      }
      
      override public function getTrait(type:String) : MediaTraitBase
      {
         if(type == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         var trait:MediaTraitBase = null;
         if(this.blocksTrait(type) == false)
         {
            trait = super.getTrait(type) || (this.proxiedElement != null ? this.proxiedElement.getTrait(type) : null);
         }
         return trait;
      }
      
      override public function get resource() : MediaResourceBase
      {
         return Boolean(this.proxiedElement) ? this.proxiedElement.resource : null;
      }
      
      override public function set resource(value:MediaResourceBase) : void
      {
         if(this.proxiedElement != null)
         {
            this.proxiedElement.resource = value;
         }
      }
      
      override protected function addTrait(type:String, instance:MediaTraitBase) : void
      {
         if(this.blocksTrait(type) == false && this.proxiedElement != null && this.proxiedElement.hasTrait(type) == true)
         {
            super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE,false,false,type));
         }
         super.addTrait(type,instance);
      }
      
      override protected function removeTrait(type:String) : MediaTraitBase
      {
         var result:MediaTraitBase = super.removeTrait(type);
         if(this.blocksTrait(type) == false && this.proxiedElement != null && this.proxiedElement.hasTrait(type) == true)
         {
            super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD,false,false,type));
         }
         return result;
      }
      
      override protected function createMetadata() : Metadata
      {
         return new ProxyMetadata();
      }
      
      final protected function get blockedTraits() : Vector.<String>
      {
         if(this._blockedTraits == null)
         {
            this._blockedTraits = new Vector.<String>();
         }
         return this._blockedTraits;
      }
      
      final protected function set blockedTraits(value:Vector.<String>) : void
      {
         var traitType:String = null;
         if(value == this._blockedTraits)
         {
            return;
         }
         var newlyBlockedTraitTypes:Array = [];
         var previouslyBlockedTraitTypes:Array = [];
         if(this._proxiedElement != null)
         {
            for each(traitType in MediaTraitType.ALL_TYPES)
            {
               if(value.indexOf(traitType) != -1)
               {
                  if(this._blockedTraits == null || this._blockedTraits.indexOf(traitType) == -1)
                  {
                     newlyBlockedTraitTypes.push(traitType);
                  }
               }
               else if(this._blockedTraits != null && this._blockedTraits.indexOf(traitType) != -1)
               {
                  previouslyBlockedTraitTypes.push(traitType);
               }
            }
         }
         if(this._proxiedElement != null)
         {
            for each(traitType in newlyBlockedTraitTypes)
            {
               if(this.proxiedElement.hasTrait(traitType) || Boolean(super.hasTrait(traitType)))
               {
                  dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE,false,false,traitType));
               }
            }
            this._blockedTraits = value;
            for each(traitType in previouslyBlockedTraitTypes)
            {
               if(this.proxiedElement.hasTrait(traitType) || Boolean(super.hasTrait(traitType)))
               {
                  dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD,false,false,traitType));
               }
            }
         }
         else
         {
            this._blockedTraits = value;
         }
      }
      
      private function toggleMediaElementListeners(mediaElement:MediaElement, add:Boolean) : void
      {
         if(add)
         {
            this._proxiedElement.addEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError);
            this._proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
            this._proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
            this._proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD,this.onMetadataEvent);
            this._proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE,this.onMetadataEvent);
         }
         else
         {
            this._proxiedElement.removeEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError);
            this._proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD,this.onTraitAdd);
            this._proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE,this.onTraitRemove);
            this._proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD,this.onMetadataEvent);
            this._proxiedElement.removeEventListener(MediaElementEvent.METADATA_REMOVE,this.onMetadataEvent);
         }
      }
      
      private function onMediaError(event:MediaErrorEvent) : void
      {
         dispatchEvent(event.clone());
      }
      
      private function onTraitAdd(event:MediaElementEvent) : void
      {
         this.processTraitsChangeEvent(event);
      }
      
      private function onTraitRemove(event:MediaElementEvent) : void
      {
         this.processTraitsChangeEvent(event);
      }
      
      private function onMetadataEvent(event:MediaElementEvent) : void
      {
         dispatchEvent(event.clone());
      }
      
      private function onProxyContainerChange(event:ContainerChangeEvent) : void
      {
         if(this.proxiedElement != null)
         {
            this.proxiedElement.dispatchEvent(event.clone());
         }
      }
      
      private function onProxyTraitAdd(event:MediaElementEvent) : void
      {
         this.processProxyTraitsChangeEvent(event);
      }
      
      private function onProxyTraitRemove(event:MediaElementEvent) : void
      {
         this.processProxyTraitsChangeEvent(event);
      }
      
      private function processTraitsChangeEvent(event:MediaElementEvent) : void
      {
         if(this.blocksTrait(event.traitType) == false && super.hasTrait(event.traitType) == false)
         {
            super.dispatchEvent(event.clone());
         }
      }
      
      private function processProxyTraitsChangeEvent(event:MediaElementEvent) : void
      {
         if(this.blocksTrait(event.traitType) == true)
         {
            event.stopImmediatePropagation();
         }
      }
      
      private function blocksTrait(traitType:String) : Boolean
      {
         return Boolean(this._blockedTraits) && this._blockedTraits.indexOf(traitType) != -1;
      }
   }
}

