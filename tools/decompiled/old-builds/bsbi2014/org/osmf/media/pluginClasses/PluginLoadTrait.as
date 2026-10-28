package org.osmf.media.pluginClasses
{
   import flash.display.Loader;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfo;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   
   [ExcludeClass]
   internal class PluginLoadTrait extends LoadTrait
   {
      
      private var _pluginInfo:PluginInfo;
      
      private var _loader:Loader;
      
      public function PluginLoadTrait(loader:LoaderBase, resource:MediaResourceBase)
      {
         super(loader,resource);
      }
      
      public function get pluginInfo() : PluginInfo
      {
         return this._pluginInfo;
      }
      
      public function set pluginInfo(value:PluginInfo) : void
      {
         this._pluginInfo = value;
      }
      
      public function get loader() : Loader
      {
         return this._loader;
      }
      
      public function set loader(value:Loader) : void
      {
         this._loader = value;
      }
   }
}

