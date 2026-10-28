package org.osmf.media.pluginClasses
{
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfo;
   import org.osmf.media.PluginInfoResource;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   
   internal class StaticPluginLoader extends PluginLoader
   {
      
      public function StaticPluginLoader(mediaFactory:MediaFactory, minimumSupportedFrameworkVersion:String)
      {
         super(mediaFactory,minimumSupportedFrameworkVersion);
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         return resource is PluginInfoResource;
      }
      
      override protected function executeLoad(loadTrait:LoadTrait) : void
      {
         updateLoadTrait(loadTrait,LoadState.LOADING);
         var classResource:PluginInfoResource = loadTrait.resource as PluginInfoResource;
         var pluginInfo:PluginInfo = classResource.pluginInfo;
         loadFromPluginInfo(loadTrait,pluginInfo);
      }
      
      override protected function executeUnload(loadTrait:LoadTrait) : void
      {
         var pluginLoadTrait:PluginLoadTrait = loadTrait as PluginLoadTrait;
         var pluginInfo:PluginInfo = pluginLoadTrait.pluginInfo;
         updateLoadTrait(loadTrait,LoadState.UNLOADING);
         unloadFromPluginInfo(pluginInfo);
         updateLoadTrait(loadTrait,LoadState.UNINITIALIZED);
      }
   }
}

