package org.osmf.elements
{
   import flash.display.Bitmap;
   import flash.display.Loader;
   import org.osmf.elements.loaderClasses.LoaderLoadTrait;
   import org.osmf.elements.loaderClasses.LoaderUtils;
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.traits.DisplayObjectTrait;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.traits.MediaTraitType;
   
   public class ImageElement extends LoadableElementBase
   {
      
      private var _smoothing:Boolean;
      
      public function ImageElement(resource:URLResource = null, loader:ImageLoader = null)
      {
         if(loader == null)
         {
            loader = new ImageLoader();
         }
         super(resource,loader);
      }
      
      public function get smoothing() : Boolean
      {
         return this._smoothing;
      }
      
      public function set smoothing(value:Boolean) : void
      {
         if(this._smoothing != value)
         {
            this._smoothing = value;
            this.applySmoothingSetting();
         }
      }
      
      override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase) : LoadTrait
      {
         return new LoaderLoadTrait(loader,resource);
      }
      
      override protected function processReadyState() : void
      {
         var loaderLoadTrait:LoaderLoadTrait = getTrait(MediaTraitType.LOAD) as LoaderLoadTrait;
         addTrait(MediaTraitType.DISPLAY_OBJECT,LoaderUtils.createDisplayObjectTrait(loaderLoadTrait.loader,this));
         this.applySmoothingSetting();
      }
      
      override protected function processUnloadingState() : void
      {
         removeTrait(MediaTraitType.DISPLAY_OBJECT);
      }
      
      private function applySmoothingSetting() : void
      {
         var loader:Loader = null;
         var bitmap:Bitmap = null;
         var displayObjectTrait:DisplayObjectTrait = getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
         if(Boolean(displayObjectTrait))
         {
            loader = displayObjectTrait.displayObject as Loader;
            if(loader != null)
            {
               try
               {
                  bitmap = loader.content as Bitmap;
                  if(bitmap != null)
                  {
                     bitmap.smoothing = this._smoothing;
                  }
               }
               catch(error:SecurityError)
               {
               }
            }
         }
      }
   }
}

