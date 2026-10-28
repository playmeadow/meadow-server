package org.osmf.captioning.loader
{
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.captioning.parsers.DFXPParser;
   import org.osmf.captioning.parsers.ICaptioningParser;
   import org.osmf.events.LoaderEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.HTTPLoadTrait;
   import org.osmf.utils.HTTPLoader;
   
   public class CaptioningLoader extends LoaderBase
   {
      
      private var httpLoader:HTTPLoader;
      
      public function CaptioningLoader(httpLoader:HTTPLoader = null)
      {
         super();
         this.httpLoader = httpLoader != null ? httpLoader : new HTTPLoader();
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         return this.httpLoader.canHandleResource(resource);
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         var httpLoadTrait:HTTPLoadTrait = null;
         var onHTTPLoaderStateChange:Function = null;
         var onLoadError:Function = null;
         onHTTPLoaderStateChange = function(event:LoaderEvent):void
         {
            var parser:ICaptioningParser = null;
            var captioningDocument:CaptioningDocument = null;
            if(event.newState == LoadState.READY)
            {
               httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE,onHTTPLoaderStateChange);
               httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR,onLoadError);
               parser = createCaptioningParser();
               try
               {
                  captioningDocument = parser.parse(httpLoadTrait.urlLoader.data.toString());
               }
               catch(e:Error)
               {
                  updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
               }
               CaptioningLoadTrait(loadTrait).document = captioningDocument;
               updateLoadTrait(loadTrait,LoadState.READY);
            }
            else if(event.newState == LoadState.LOAD_ERROR)
            {
               httpLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE,onHTTPLoaderStateChange);
               updateLoadTrait(loadTrait,event.newState);
            }
         };
         onLoadError = function(event:MediaErrorEvent):void
         {
            httpLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR,onLoadError);
            loadTrait.dispatchEvent(event.clone());
         };
         updateLoadTrait(loadTrait,LoadState.LOADING);
         this.httpLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE,onHTTPLoaderStateChange);
         httpLoadTrait = new HTTPLoadTrait(this.httpLoader,loadTrait.resource);
         httpLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR,onLoadError);
         this.httpLoader.load(httpLoadTrait);
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.UNLOADING);
         updateLoadTrait(loadTrait,LoadState.UNINITIALIZED);
      }
      
      protected function createCaptioningParser() : ICaptioningParser
      {
         return new DFXPParser();
      }
   }
}

