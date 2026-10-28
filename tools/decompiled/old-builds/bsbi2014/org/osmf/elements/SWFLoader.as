package org.osmf.elements
{
   import org.osmf.elements.loaderClasses.LoaderUtils;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.MediaType;
   import org.osmf.media.MediaTypeUtil;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.URL;
   
   public class SWFLoader extends LoaderBase
   {
      
      public static var allowValidationOfLoadedContent:Boolean = true;
      
      private static const MIME_TYPES_SUPPORTED:Vector.<String> = Vector.<String>(["application/x-shockwave-flash"]);
      
      private static const MEDIA_TYPES_SUPPORTED:Vector.<String> = Vector.<String>([MediaType.SWF]);
      
      private var useCurrentSecurityDomain:Boolean = false;
      
      private var _validateLoadedContentFunction:Function = null;
      
      public function SWFLoader(useCurrentSecurityDomain:Boolean = false)
      {
         super();
         this.useCurrentSecurityDomain = useCurrentSecurityDomain;
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
            return url.path.search(/\.swf$/i) != -1;
         }
         return false;
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         LoaderUtils.loadLoadTrait(loadTrait,updateLoadTrait,this.useCurrentSecurityDomain,false,this.validateLoadedContentFunction);
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         LoaderUtils.unloadLoadTrait(loadTrait,updateLoadTrait);
      }
      
      public function get validateLoadedContentFunction() : Function
      {
         return allowValidationOfLoadedContent ? this._validateLoadedContentFunction : null;
      }
      
      public function set validateLoadedContentFunction(value:Function) : void
      {
         this._validateLoadedContentFunction = value;
      }
   }
}

