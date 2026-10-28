package org.osmf.media
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.containers.IMediaContainer;
   import org.osmf.events.ContainerChangeEvent;
   import org.osmf.events.MediaElementEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.Metadata;
   import org.osmf.traits.MediaTraitBase;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="containerChange",type="org.osmf.events.ContainerChangeEvent")]
   [Event(name="mediaError",type="org.osmf.events.MediaErrorEvent")]
   [Event(name="metadataRemove",type="org.osmf.events.MediaElementEvent")]
   [Event(name="metadataAdd",type="org.osmf.events.MediaElementEvent")]
   [Event(name="traitRemove",type="org.osmf.events.MediaElementEvent")]
   [Event(name="traitAdd",type="org.osmf.events.MediaElementEvent")]
   public class MediaElement extends EventDispatcher
   {
      
      private var traits:Dictionary = new Dictionary();
      
      private var traitResolvers:Dictionary = new Dictionary();
      
      private var unresolvedTraits:Dictionary = new Dictionary();
      
      private var _traitTypes:Vector.<String> = new Vector.<String>();
      
      private var _resource:MediaResourceBase;
      
      private var _metadata:Metadata;
      
      private var _container:IMediaContainer;
      
      public function MediaElement()
      {
         super();
         this._metadata = this.createMetadata();
         this._metadata.addEventListener(MetadataEvent.VALUE_ADD,this.onMetadataValueAdd);
         this._metadata.addEventListener(MetadataEvent.VALUE_REMOVE,this.onMetadataValueRemove);
         this._metadata.addEventListener(MetadataEvent.VALUE_CHANGE,this.onMetadataValueChange);
         this.setupTraitResolvers();
         this.setupTraits();
         addEventListener(ContainerChangeEvent.CONTAINER_CHANGE,this.onContainerChange,false,Number.MAX_VALUE);
      }
      
      public function get traitTypes() : Vector.<String>
      {
         return this._traitTypes.concat();
      }
      
      public function hasTrait(type:String) : Boolean
      {
         if(type == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this.traits[type] != null;
      }
      
      public function getTrait(type:String) : MediaTraitBase
      {
         if(type == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this.traits[type];
      }
      
      public function get resource() : MediaResourceBase
      {
         return this._resource;
      }
      
      public function set resource(value:MediaResourceBase) : void
      {
         this._resource = value;
      }
      
      public function get container() : IMediaContainer
      {
         return this._container;
      }
      
      public function addMetadata(namespaceURL:String, metadata:Metadata) : void
      {
         if(namespaceURL == null || metadata == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.metadata.addValue(namespaceURL,metadata);
      }
      
      public function removeMetadata(namespaceURL:String) : Metadata
      {
         if(namespaceURL == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         return this.metadata.removeValue(namespaceURL) as Metadata;
      }
      
      public function getMetadata(namespaceURL:String) : Metadata
      {
         if(namespaceURL == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         return this.metadata.getValue(namespaceURL) as Metadata;
      }
      
      public function get metadataNamespaceURLs() : Vector.<String>
      {
         return this.metadata.keys;
      }
      
      protected function createMetadata() : Metadata
      {
         return new Metadata();
      }
      
      public function get metadata() : Metadata
      {
         return this._metadata;
      }
      
      protected function addTrait(type:String, instance:MediaTraitBase) : void
      {
         if(type == null || instance == null || type != instance.traitType)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         var traitResolver:MediaTraitResolver = this.traitResolvers[type];
         if(traitResolver != null)
         {
            traitResolver.addTrait(instance);
         }
         else
         {
            this.setLocalTrait(type,instance);
         }
      }
      
      protected function removeTrait(type:String) : MediaTraitBase
      {
         if(type == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         var trait:MediaTraitBase = this.traits[type];
         var traitResolver:MediaTraitResolver = this.traitResolvers[type];
         if(traitResolver != null)
         {
            return traitResolver.removeTrait(trait);
         }
         return this.setLocalTrait(type,null);
      }
      
      final protected function addTraitResolver(type:String, instance:MediaTraitResolver) : void
      {
         var currentlySetTrait:MediaTraitBase = null;
         if(instance == null || instance.type != type)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         if(this.traitResolvers[type] == null)
         {
            this.unresolvedTraits[type] = this.traits[type];
            this.traitResolvers[type] = instance;
            currentlySetTrait = this.traits[type];
            if(Boolean(currentlySetTrait))
            {
               instance.addTrait(currentlySetTrait);
            }
            this.processResolvedTraitChange(type,instance.resolvedTrait);
            instance.addEventListener(Event.CHANGE,this.onTraitResolverChange);
            return;
         }
         throw new ArgumentError(OSMFStrings.getString(OSMFStrings.TRAIT_RESOLVER_ALREADY_ADDED));
      }
      
      final protected function removeTraitResolver(type:String) : MediaTraitResolver
      {
         if(type == null || this.traitResolvers[type] == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         var instance:MediaTraitResolver = this.traitResolvers[type];
         instance.removeEventListener(Event.CHANGE,this.onTraitResolverChange);
         delete this.traitResolvers[type];
         var unresolvedTrait:MediaTraitBase = this.unresolvedTraits[type];
         if(unresolvedTrait != this.traits[type])
         {
            this.setLocalTrait(type,unresolvedTrait);
         }
         delete this.unresolvedTraits[type];
         return instance;
      }
      
      final protected function getTraitResolver(type:String) : MediaTraitResolver
      {
         return this.traitResolvers[type];
      }
      
      protected function setupTraitResolvers() : void
      {
      }
      
      protected function setupTraits() : void
      {
      }
      
      private function onMediaError(event:MediaErrorEvent) : void
      {
         dispatchEvent(event.clone());
      }
      
      private function setLocalTrait(type:String, instance:MediaTraitBase) : MediaTraitBase
      {
         var result:MediaTraitBase = this.traits[type];
         if(instance == null)
         {
            if(result != null)
            {
               result.removeEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError);
               result.dispose();
               dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE,false,false,type));
               this._traitTypes.splice(this._traitTypes.indexOf(type),1);
               delete this.traits[type];
            }
         }
         else if(result == null)
         {
            this.traits[type] = result = instance;
            this._traitTypes.push(type);
            result.addEventListener(MediaErrorEvent.MEDIA_ERROR,this.onMediaError);
            dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD,false,false,type));
         }
         else if(result != instance)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.TRAIT_INSTANCE_ALREADY_ADDED));
         }
         return result;
      }
      
      private function onTraitResolverChange(event:Event) : void
      {
         var resolver:MediaTraitResolver = event.target as MediaTraitResolver;
         this.processResolvedTraitChange(resolver.type,resolver.resolvedTrait);
      }
      
      private function processResolvedTraitChange(type:String, resolvedTrait:MediaTraitBase) : void
      {
         if(resolvedTrait != this.traits[type])
         {
            this.setLocalTrait(type,resolvedTrait);
         }
      }
      
      private function onContainerChange(event:ContainerChangeEvent) : void
      {
         if(this._container == event.oldContainer && this._container != event.newContainer)
         {
            this._container = event.newContainer;
         }
      }
      
      private function onMetadataValueAdd(event:MetadataEvent) : void
      {
         dispatchEvent(new MediaElementEvent(MediaElementEvent.METADATA_ADD,false,false,null,event.key,event.value as Metadata));
      }
      
      private function onMetadataValueChange(event:MetadataEvent) : void
      {
         dispatchEvent(new MediaElementEvent(MediaElementEvent.METADATA_REMOVE,false,false,null,event.key,event.oldValue as Metadata));
         dispatchEvent(new MediaElementEvent(MediaElementEvent.METADATA_ADD,false,false,null,event.key,event.value as Metadata));
      }
      
      private function onMetadataValueRemove(event:MetadataEvent) : void
      {
         dispatchEvent(new MediaElementEvent(MediaElementEvent.METADATA_REMOVE,false,false,null,event.key,event.value as Metadata));
      }
   }
}

