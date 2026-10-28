package org.osmf.metadata
{
   [ExcludeClass]
   public class NullMetadataSynthesizer extends MetadataSynthesizer
   {
      
      public function NullMetadataSynthesizer()
      {
         super();
      }
      
      override public function synthesize(namespaceURL:String, targetParentMetadata:Metadata, metadatas:Vector.<Metadata>, mode:String, activeParentMetadata:Metadata) : Metadata
      {
         return null;
      }
   }
}

