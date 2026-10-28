package org.osmf.media
{
   public class PluginInfoResource extends MediaResourceBase
   {
      
      private var _pluginInfo:PluginInfo;
      
      public function PluginInfoResource(pluginInfo:PluginInfo)
      {
         super();
         this._pluginInfo = pluginInfo;
      }
      
      public function get pluginInfo() : PluginInfo
      {
         return this._pluginInfo;
      }
   }
}

