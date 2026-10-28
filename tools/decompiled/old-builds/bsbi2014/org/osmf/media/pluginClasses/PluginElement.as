package org.osmf.media.pluginClasses
{
   import org.osmf.media.LoadableElementBase;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   internal class PluginElement extends LoadableElementBase
   {
      
      public function PluginElement(loader:PluginLoader, resource:MediaResourceBase = null)
      {
         super(resource,loader);
      }
      
      override protected function createLoadTrait(resource:MediaResourceBase, loader:LoaderBase) : LoadTrait
      {
         return new PluginLoadTrait(loader,resource);
      }
   }
}

