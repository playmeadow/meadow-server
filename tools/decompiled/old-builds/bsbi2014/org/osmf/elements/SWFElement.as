package org.osmf.elements
{
   import org.osmf.elements.loaderClasses.LoaderLoadTrait;
   import org.osmf.elements.loaderClasses.LoaderUtils;
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitType;
   
   public class SWFElement extends LoadableElementBase
   {
      
      public function SWFElement(resource:URLResource = null, loader:SWFLoader = null)
      {
         if(loader == null)
         {
            loader = new SWFLoader();
         }
         super(resource,loader);
      }
      
      override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase) : LoadTrait
      {
         return new LoaderLoadTrait(loader,resource);
      }
      
      override protected function processReadyState() : void
      {
         var loaderLoadTrait:LoaderLoadTrait = getTrait(MediaTraitType.LOAD) as LoaderLoadTrait;
         addTrait(MediaTraitType.DISPLAY_OBJECT,LoaderUtils.createDisplayObjectTrait(loaderLoadTrait.loader,this));
      }
      
      override protected function processUnloadingState() : void
      {
         removeTrait(MediaTraitType.DISPLAY_OBJECT);
      }
   }
}

