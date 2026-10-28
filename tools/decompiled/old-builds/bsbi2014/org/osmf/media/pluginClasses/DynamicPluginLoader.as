package org.osmf.media.pluginClasses
{
   import flash.display.DisplayObject;
   import org.osmf.elements.SWFLoader;
   import org.osmf.elements.loaderClasses.LoaderLoadTrait;
   import org.osmf.events.LoaderEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfo;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   
   internal class DynamicPluginLoader extends PluginLoader
   {
      
      private static const PLUGININFO_PROPERTY_NAME:String = "pluginInfo";
      
      public function DynamicPluginLoader(mediaFactory:MediaFactory, minimumSupportedFrameworkVersion:String)
      {
         super(mediaFactory,minimumSupportedFrameworkVersion);
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         return new SWFLoader().canHandleResource(resource);
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         var swfLoader:SWFLoader = null;
         var loaderLoadTrait:LoaderLoadTrait = null;
         var onSWFLoaderStateChange:Function = null;
         var onLoadError:Function = null;
         onSWFLoaderStateChange = function(event:LoaderEvent):void
         {
            var root:DisplayObject = null;
            var pluginInfo:PluginInfo = null;
            if(event.newState == LoadState.READY)
            {
               swfLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE,onSWFLoaderStateChange);
               loaderLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR,onLoadError);
               root = loaderLoadTrait.loader.content;
               pluginInfo = root[PLUGININFO_PROPERTY_NAME] as PluginInfo;
               loadFromPluginInfo(loadTrait,pluginInfo,loaderLoadTrait.loader);
            }
            else if(event.newState == LoadState.LOAD_ERROR)
            {
               swfLoader.removeEventListener(LoaderEvent.LOAD_STATE_CHANGE,onSWFLoaderStateChange);
               updateLoadTrait(loadTrait,event.newState);
            }
         };
         onLoadError = function(event:MediaErrorEvent):void
         {
            loaderLoadTrait.removeEventListener(MediaErrorEvent.MEDIA_ERROR,onLoadError);
            loadTrait.dispatchEvent(event.clone());
         };
         updateLoadTrait(loadTrait,LoadState.LOADING);
         swfLoader = new SWFLoader(true);
         swfLoader.validateLoadedContentFunction = this.validateLoadedContent;
         swfLoader.addEventListener(LoaderEvent.LOAD_STATE_CHANGE,onSWFLoaderStateChange);
         loaderLoadTrait = new LoaderLoadTrait(swfLoader,loadTrait.resource);
         loaderLoadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR,onLoadError);
         swfLoader.load(loaderLoadTrait);
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.UNLOADING);
         var pluginLoadTrait:PluginLoadTrait = loadTrait as PluginLoadTrait;
         unloadFromPluginInfo(pluginLoadTrait.pluginInfo);
         pluginLoadTrait.loader.unloadAndStop();
         updateLoadTrait(loadTrait,LoadState.UNINITIALIZED);
      }
      
      private function validateLoadedContent(displayObject:DisplayObject) : Boolean
      {
         var pluginInfo:Object = displayObject.hasOwnProperty(PLUGININFO_PROPERTY_NAME) ? displayObject[PLUGININFO_PROPERTY_NAME] : null;
         return pluginInfo != null ? isPluginCompatible(pluginInfo) : false;
      }
   }
}

