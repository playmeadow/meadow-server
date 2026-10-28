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
      
      public function CaptioningProxyElement(param1:MediaElement = null, param2:Boolean = true)
      {
         super(param1);
         this._continueLoadOnFailure = param2;
      }
      
      public function get continueLoadOnFailure() : Boolean
      {
         return this._continueLoadOnFailure;
      }
      
      override public function set proxiedElement(param1:MediaElement) : void
      {
         var _loc2_:MediaElement = null;
         var _loc3_:MediaResourceBase = null;
         var _loc4_:Metadata = null;
         var _loc5_:String = null;
         super.proxiedElement = param1;
         if(param1 != null)
         {
            _loc2_ = super.proxiedElement;
            _loc3_ = Boolean(_loc2_) && _loc2_.resource != null ? _loc2_.resource : resource;
            if(_loc3_ == null)
            {
               dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
            }
            else
            {
               _loc4_ = _loc3_.getMetadataValue(CaptioningPluginInfo.CAPTIONING_METADATA_NAMESPACE) as Metadata;
               if(_loc4_ == null)
               {
                  if(!this._continueLoadOnFailure)
                  {
                     dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MEDIA_ERROR_INVALID_PROXIED_ELEMENT)));
                  }
               }
               else
               {
                  _loc5_ = _loc4_.getValue(CaptioningPluginInfo.CAPTIONING_METADATA_KEY_URI);
                  if(_loc5_ != null)
                  {
                     this.loadTrait = new CaptioningLoadTrait(new CaptioningLoader(),new URLResource(_loc5_));
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
      
      private function onLoadStateChange(param1:LoadEvent) : void
      {
         var _loc2_:CaptioningDocument = null;
         var _loc3_:MediaElement = null;
         var _loc4_:TimelineMetadata = null;
         var _loc5_:int = 0;
         var _loc6_:Caption = null;
         if(param1.loadState == LoadState.READY)
         {
            _loc2_ = this.loadTrait.document;
            if(_loc2_)
            {
               _loc3_ = super.proxiedElement;
               _loc4_ = proxiedElement.getMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE) as TimelineMetadata;
               if(_loc4_ == null)
               {
                  _loc4_ = new TimelineMetadata(proxiedElement);
                  proxiedElement.addMetadata(CaptioningPluginInfo.CAPTIONING_TEMPORAL_METADATA_NAMESPACE,_loc4_);
               }
               _loc5_ = 0;
               while(_loc5_ < _loc2_.numCaptions)
               {
                  _loc6_ = _loc2_.getCaptionAt(_loc5_);
                  _loc4_.addMarker(_loc6_);
                  _loc5_++;
               }
            }
            this.cleanUp();
         }
         else if(param1.loadState == LoadState.LOAD_ERROR)
         {
            if(!this._continueLoadOnFailure)
            {
               dispatchEvent(param1.clone());
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
         var _loc1_:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
         if(_loc1_ != null && _loc1_.loadState == LoadState.UNINITIALIZED)
         {
            _loc1_.load();
         }
      }
   }
}

