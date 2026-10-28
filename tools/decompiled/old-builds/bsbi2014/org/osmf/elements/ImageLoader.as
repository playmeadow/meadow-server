package org.osmf.elements
{
   import org.osmf.elements.loaderClasses.LoaderUtils;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaType;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.*;
   
   public class ImageLoader extends LoaderBase
   {
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["image/png","image/gif","image/jpeg"]);
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.IMAGE]);
      
      private var checkPolicyFile:Boolean;
      
      public function ImageLoader(checkPolicyFile:Boolean = true)
      {
         super();
         this.checkPolicyFile = checkPolicyFile;
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var url:URL = null;
         var rt:int = MediaTypeUtil.checkMetadataMatchWithResource(resource,MEDIA_TYPES_SUPPORTED,MIME_TYPES_SUPPORTED);
         if(rt != MediaTypeUtil.METADATA_MATCH_UNKNOWN)
         {
            return rt == MediaTypeUtil.METADATA_MATCH_FOUND;
         }
         var urlResource:URLResource = resource as URLResource;
         if(urlResource != null && urlResource.url != null)
         {
            url = new URL(urlResource.url);
            return url.path.search(/\.gif$|\.jpg$|\.png$/i) != -1;
         }
         return false;
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         LoaderUtils.loadLoadTrait(loadTrait,updateLoadTrait,false,this.checkPolicyFile);
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         LoaderUtils.unloadLoadTrait(loadTrait,updateLoadTrait);
      }
   }
}

