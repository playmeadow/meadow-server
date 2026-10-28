package org.osmf.captioning.loader
{
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   public class CaptioningLoadTrait extends LoadTrait
   {
      
      private var _document:CaptioningDocument;
      
      public function CaptioningLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
      }
      
      public function get document() : CaptioningDocument
      {
         return this._document;
      }
      
      public function set document(value:CaptioningDocument) : void
      {
         this._document = value;
      }
   }
}

