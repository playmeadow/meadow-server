package org.osmf.media
{
   import flash.utils.Dictionary;
   
   public class MediaResourceBase
   {
      
      private var _metadata:Dictionary;
      
      private var _mediaType:String;
      
      private var _mimeType:String;
      
      public function MediaResourceBase()
      {
         super();
      }
      
      public function get mediaType() : String
      {
         return this._mediaType;
      }
      
      public function set mediaType(value:String) : void
      {
         this._mediaType = value;
      }
      
      public function get mimeType() : String
      {
         return this._mimeType;
      }
      
      public function set mimeType(value:String) : void
      {
         this._mimeType = value;
      }
      
      public function get metadataNamespaceURLs() : Vector.<String>
      {
         var key:String = null;
         var allKeys:Vector.<String> = new Vector.<String>();
         if(this._metadata != null)
         {
            for(key in this._metadata)
            {
               allKeys.push(key);
            }
         }
         return allKeys;
      }
      
      public function addMetadataValue(namespaceURL:String, value:Object) : void
      {
         if(this._metadata == null)
         {
            this._metadata = new Dictionary();
         }
         this._metadata[namespaceURL] = value;
      }
      
      public function getMetadataValue(namespaceURL:String) : Object
      {
         if(this._metadata != null)
         {
            return this._metadata[namespaceURL];
         }
         return null;
      }
      
      public function removeMetadataValue(namespaceURL:String) : Object
      {
         var value:Object = null;
         if(this._metadata != null)
         {
            value = this._metadata[namespaceURL];
            delete this._metadata[namespaceURL];
            return value;
         }
         return null;
      }
   }
}

