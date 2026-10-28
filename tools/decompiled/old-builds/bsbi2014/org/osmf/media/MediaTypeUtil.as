package org.osmf.media
{
   [ExcludeClass]
   public class MediaTypeUtil
   {
      
      public static const METADATA_MATCH_FOUND:int = 0;
      
      public static const METADATA_CONFLICTS_FOUND:int = 1;
      
      public static const METADATA_MATCH_UNKNOWN:int = 2;
      
      public function MediaTypeUtil()
      {
         super();
      }
      
      public static function checkMetadataMatchWithResource(resource:MediaResourceBase, mediaTypesSupported:Vector.<String>, mimeTypesSupported:Vector.<String>) : int
      {
         var mediaType:String = Boolean(resource) ? resource.mediaType : null;
         var mimeType:String = Boolean(resource) ? resource.mimeType : null;
         return checkMetadataMatch(mediaType,mimeType,mediaTypesSupported,mimeTypesSupported);
      }
      
      public static function checkMetadataMatch(mediaType:String, mimeType:String, mediaTypesSupported:Vector.<String>, mimeTypesSupported:Vector.<String>) : int
      {
         if(mediaType != null)
         {
            if(mimeType != null)
            {
               return matchType(mediaType,mediaTypesSupported) && matchType(mimeType,mimeTypesSupported) ? METADATA_MATCH_FOUND : METADATA_CONFLICTS_FOUND;
            }
            return matchType(mediaType,mediaTypesSupported) ? METADATA_MATCH_FOUND : METADATA_CONFLICTS_FOUND;
         }
         if(mimeType != null)
         {
            return matchType(mimeType,mimeTypesSupported) ? METADATA_MATCH_FOUND : METADATA_CONFLICTS_FOUND;
         }
         return METADATA_MATCH_UNKNOWN;
      }
      
      private static function matchType(type:String, typesSupported:Vector.<String>) : Boolean
      {
         for(var i:int = 0; i < typesSupported.length; i++)
         {
            if(type == typesSupported[i])
            {
               return true;
            }
         }
         return false;
      }
   }
}

