package org.osmf.captioning.media
{
   import org.osmf.captioning.CaptioningPluginInfo;
   import org.osmf.captioning.loader.CaptioningLoadTrait;
   import org.osmf.captioning.loader.CaptioningLoader;
   import org.osmf.captioning.model.Caption;
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.elements.ProxyElement;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.TimelineMetadata;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.MediaTraitType;
   
   public class CaptioningProxyElement extends ProxyElement
   {
      
      public static const MEDIA_ERROR_INVALID_PROXIED_ELEMENT:int = 2201;
      
      private static const ERROR_MISSING_CAPTION_METADATA:String = "Media Element is missing Captioning metadata";
      
      private static const ERROR_MISSING_RESOURCE:String = "Media Element is missing a valid resource";
      
      private var loadTrait:CaptioningLoadTrait;
      
      private var _continueLoadOnFailure:Boolean;
      
      public function CaptioningProxyElement(proxiedElement:MediaElement = null, continueLoadOnFailure:Boolean = true)
      {
         super(proxiedElement);
         this._continueLoadOnFailure = continueLoadOnFailure;
      }
      
      public function get continueLoadOnFailure() : Boolean
      {
         return this._continueLoadOnFailure;
      }
      
      override public function set proxiedElement(value:MediaElement) : void
      {
         var mediaElement:MediaElement = null;
         var tempResource:MediaResourceBase = null;
         var metadata:Metadata = null;
         var timedTextURL:String = null;
         super.proxiedElement = value;
         if(value != null)
         {
            mediaElement = super.proxiedElement;
            tempResource = Boolean(mediaElement) && mediaElement.resource != null ? mediaElement.resource : resource;
            if(tempResource == null)
            {
               dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
            }
            else
            {
               metadata = tempResource.getMetadataValue(CaptioningPluginInfo.CAPTIONING_METADATA_NAMESPACE) as Metadata;
               if(metadata == null)
               {
                  if(!this._continueLoadOnFailure)
                  {
                     dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
                  }
               }
               else
               {
                  timedTextURL = metadata.getValue(CaptioningPluginInfo.CAPTIONING_METADATA_KEY_URI);
                  if(timedTextURL != null)
                  {
                     this.loadTrait = new CaptioningLoadTrait(new CaptioningLoader(),new URLResource(timedTextURL));
                     this.loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE,this.onLoadStateChange,false,99);
                     addTrait(MediaTraitType.LOAD,this.loadTrait);
                  }
                  else if(!this._continueLoadOnFailure)
                  {
                     dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
                  }
               }
            }
         }
      }
      
      private function onLoadStateChange(event:LoadEvent) : void
      {
         var document:CaptioningDocument = null;
         var mediaElement:MediaElement = null;
         var captionMetadata:TimelineMetadata = null;
         var i:int = 0;
         var caption:Caption = null;
         if(event.loadState == LoadState.READY)
         {
            document = this.loadTrait.document;
            if(Boolean(document))
            {
               mediaElement = super.proxiedElement;
               captionMetadata = proxiedElement.getMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
               if(captionMetadata == null)
               {
                  captionMetadata = new TimelineMetadata(proxiedElement);
                  proxiedElement.addMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE,captionMetadata);
               }
               for(i = 0; i < document.numCaptions; i++)
               {
                  caption = document.getCaptionAt(i);
                  captionMetadata.addMarker(caption);
               }
            }
            this.cleanUp();
         }
         else if(event.loadState == LoadState.LOAD_ERROR)
         {
            if(!this._continueLoadOnFailure)
            {
               dispatchEvent(event.clone());
            }
            else
            {
               this.cleanUp();
            }
         }
      }
      
      private function cleanUp() : void
      {
         removeTrait(MediaTraitType.LOAD);
         var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
         if(loadTrait != null && loadTrait.loadState == LoadState.UNINITIALIZED)
         {
            loadTrait.load();
         }
      }
   }
}

