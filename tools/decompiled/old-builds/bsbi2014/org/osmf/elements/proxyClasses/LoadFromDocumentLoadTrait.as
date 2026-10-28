package org.osmf.elements.proxyClasses
{
   import org.osmf.events.LoadEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   [ExcludeClass]
   public class LoadFromDocumentLoadTrait extends LoadTrait
   {
      
      private var _mediaElement:MediaElement;
      
      public function LoadFromDocumentLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
      }
      
      override protected function loadStateChangeEnd() : void
      {
         dispatchEvent(new LoadEvent(LoadEvent.LOAD_STATE_CHANGE,false,false,loadState));
      }
      
      public function set mediaElement(value:MediaElement) : void
      {
         this._mediaElement = value;
      }
      
      public function get mediaElement() : MediaElement
      {
         return this._mediaElement;
      }
   }
}

