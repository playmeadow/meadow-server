package org.osmf.metadata
{
   import org.osmf.elements.compositeClasses.CompositionMode;
   
   [ExcludeClass]
   public class MetadataSynthesizer
   {
      
      public function MetadataSynthesizer()
      {
         super();
      }
      
      public function synthesize(namespaceURL:String, targetParentMetadata:Metadata, metadatas:Vector.<Metadata>, mode:String, serialElementActiveChildMetadata:Metadata) : Metadata
      {
         var result:Metadata = null;
         if(mode == CompositionMode.SERIAL && Boolean(serialElementActiveChildMetadata))
         {
            result = serialElementActiveChildMetadata.getValue(namespaceURL) as Metadata;
         }
         else
         {
            result = metadatas.length >= 1 ? metadatas[0] : null;
         }
         return result;
      }
   }
}

