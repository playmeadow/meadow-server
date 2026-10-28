package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.metadata.Metadata;
   
   public class MediaElementEvent extends Event
   {
      
      public static const TRAIT_ADD:String = "traitAdd";
      
      public static const TRAIT_REMOVE:String = "traitRemove";
      
      public static const METADATA_ADD:String = "metadataAdd";
      
      public static const METADATA_REMOVE:String = "metadataRemove";
      
      private var _traitType:String;
      
      private var _namespaceURL:String;
      
      private var _metadata:Metadata;
      
      public function MediaElementEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, traitType:String = null, namespaceURL:String = null, metadata:Metadata = null)
      {
         super(type,bubbles,cancelable);
         this._traitType = traitType;
         this._namespaceURL = namespaceURL;
         this._metadata = metadata;
      }
      
      override public function clone() : Event
      {
         return new MediaElementEvent(type,bubbles,cancelable,this.traitType,this.namespaceURL,this.metadata);
      }
      
      public function get traitType() : String
      {
         return this._traitType;
      }
      
      public function get namespaceURL() : String
      {
         return this._namespaceURL;
      }
      
      public function get metadata() : Metadata
      {
         return this._metadata;
      }
   }
}

