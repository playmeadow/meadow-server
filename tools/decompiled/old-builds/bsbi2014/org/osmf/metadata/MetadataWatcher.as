package org.osmf.metadata
{
   import flash.errors.IllegalOperationError;
   import org.osmf.events.MetadataEvent;
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   public class MetadataWatcher
   {
      
      private var parentMetadata:Metadata;
      
      private var namespaceURL:String;
      
      private var key:String;
      
      private var callback:Function;
      
      private var currentMetadata:Metadata;
      
      private var watching:Boolean;
      
      public function MetadataWatcher(parentMetadata:Metadata, namespaceURL:String, key:String, callback:Function)
      {
         super();
         if(parentMetadata == null || namespaceURL == null || callback == null)
         {
            throw new IllegalOperationError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         this.parentMetadata = parentMetadata;
         this.namespaceURL = namespaceURL;
         this.key = key;
         this.callback = callback;
      }
      
      public function watch(dispatchInitialChangeEvent:Boolean = true) : void
      {
         if(this.watching == false)
         {
            this.watching = true;
            this.parentMetadata.addEventListener(MetadataEvent.VALUE_ADD,this.onMetadataAdd,false,0,true);
            this.processWatchedMetadataChange(this.parentMetadata.getValue(this.namespaceURL) as Metadata);
            if(dispatchInitialChangeEvent == true)
            {
               if(this.key != null)
               {
                  this.callback(Boolean(this.currentMetadata) ? this.currentMetadata.getValue(this.key) : undefined);
               }
               else
               {
                  this.callback(Boolean(this.currentMetadata) ? this.currentMetadata : undefined);
               }
            }
         }
      }
      
      public function unwatch() : void
      {
         if(this.watching == true)
         {
            this.processWatchedMetadataChange(null,false);
            this.parentMetadata.removeEventListener(MetadataEvent.VALUE_ADD,this.onMetadataAdd);
            this.watching = false;
         }
      }
      
      private function processWatchedMetadataChange(metadata:Metadata, dispatchChange:Boolean = true) : void
      {
         var oldMetadata:Metadata = null;
         if(this.currentMetadata != metadata)
         {
            oldMetadata = this.currentMetadata;
            if(Boolean(this.currentMetadata))
            {
               this.currentMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE,this.onValueChange);
               this.currentMetadata.removeEventListener(MetadataEvent.VALUE_ADD,this.onValueAdd);
               this.currentMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE,this.onValueRemove);
               this.parentMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE,this.onMetadataRemove);
            }
            else
            {
               this.parentMetadata.removeEventListener(MetadataEvent.VALUE_ADD,this.onMetadataAdd);
            }
            this.currentMetadata = metadata;
            if(Boolean(metadata))
            {
               metadata.addEventListener(MetadataEvent.VALUE_CHANGE,this.onValueChange,false,0,true);
               metadata.addEventListener(MetadataEvent.VALUE_ADD,this.onValueAdd,false,0,true);
               metadata.addEventListener(MetadataEvent.VALUE_REMOVE,this.onValueRemove,false,0,true);
               this.parentMetadata.addEventListener(MetadataEvent.VALUE_REMOVE,this.onMetadataRemove);
            }
            else
            {
               this.parentMetadata.addEventListener(MetadataEvent.VALUE_ADD,this.onMetadataAdd);
            }
         }
      }
      
      private function onMetadataAdd(event:MetadataEvent) : void
      {
         var metadata:Metadata = event.value as Metadata;
         if(Boolean(metadata) && event.key == this.namespaceURL)
         {
            this.processWatchedMetadataChange(metadata);
            if(this.key == null)
            {
               this.callback(metadata);
            }
            else
            {
               this.callback(metadata.getValue(this.key));
            }
         }
      }
      
      private function onMetadataRemove(event:MetadataEvent) : void
      {
         var metadata:Metadata = event.value as Metadata;
         if(Boolean(metadata) && event.key == this.namespaceURL)
         {
            this.processWatchedMetadataChange(null);
            this.callback(undefined);
         }
      }
      
      private function onValueChange(event:MetadataEvent) : void
      {
         if(Boolean(this.key))
         {
            if(this.key == event.key)
            {
               this.callback(event.value);
            }
         }
         else
         {
            this.callback(event.target as Metadata);
         }
      }
      
      private function onValueAdd(event:MetadataEvent) : void
      {
         if(Boolean(this.key))
         {
            if(this.key == event.key)
            {
               this.callback(event.value);
            }
         }
         else
         {
            this.callback(event.target as Metadata);
         }
      }
      
      private function onValueRemove(event:MetadataEvent) : void
      {
         if(Boolean(this.key))
         {
            if(this.key == event.key)
            {
               this.callback(undefined);
            }
         }
         else
         {
            this.callback(event.target as Metadata);
         }
      }
   }
}

