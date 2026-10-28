package org.osmf.elements.proxyClasses
{
   import flash.events.Event;
   import org.osmf.events.MetadataEvent;
   import org.osmf.metadata.Metadata;
   
   [ExcludeClass]
   public class ProxyMetadata extends Metadata
   {
      
      private var proxiedMetadata:Metadata;
      
      public function ProxyMetadata()
      {
         super();
         this.proxiedMetadata = new Metadata();
         this.proxiedMetadata.addEventListener(MetadataEvent.VALUE_ADD,this.redispatchEvent);
         this.proxiedMetadata.addEventListener(MetadataEvent.VALUE_CHANGE,this.redispatchEvent);
         this.proxiedMetadata.addEventListener(MetadataEvent.VALUE_REMOVE,this.redispatchEvent);
      }
      
      public function set metadata(value:Metadata) : void
      {
         var url:String = null;
         this.proxiedMetadata.removeEventListener(MetadataEvent.VALUE_ADD,this.redispatchEvent);
         this.proxiedMetadata.removeEventListener(MetadataEvent.VALUE_CHANGE,this.redispatchEvent);
         this.proxiedMetadata.removeEventListener(MetadataEvent.VALUE_REMOVE,this.redispatchEvent);
         for each(url in this.proxiedMetadata.keys)
         {
            value.addValue(url,this.proxiedMetadata.getValue(url));
         }
         this.proxiedMetadata = value;
         this.proxiedMetadata.addEventListener(MetadataEvent.VALUE_ADD,this.redispatchEvent);
         this.proxiedMetadata.addEventListener(MetadataEvent.VALUE_CHANGE,this.redispatchEvent);
         this.proxiedMetadata.addEventListener(MetadataEvent.VALUE_REMOVE,this.redispatchEvent);
      }
      
      override public function getValue(key:String) : *
      {
         return this.proxiedMetadata.getValue(key);
      }
      
      override public function addValue(key:String, value:Object) : void
      {
         this.proxiedMetadata.addValue(key,value);
      }
      
      override public function removeValue(key:String) : *
      {
         return this.proxiedMetadata.removeValue(key);
      }
      
      override public function get keys() : Vector.<String>
      {
         return this.proxiedMetadata.keys;
      }
      
      private function redispatchEvent(event:Event) : void
      {
         dispatchEvent(event.clone());
      }
   }
}

