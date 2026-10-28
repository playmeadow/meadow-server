package org.osmf.media.pluginClasses
{
   import org.osmf.media.MediaElement;
   
   internal class PluginEntry
   {
      
      private var _pluginElement:MediaElement;
      
      private var _state:PluginLoadingState;
      
      public function PluginEntry(pluginElement:MediaElement, state:PluginLoadingState)
      {
         super();
         this._pluginElement = pluginElement;
         this._state = state;
      }
      
      public function get pluginElement() : MediaElement
      {
         return this._pluginElement;
      }
      
      public function get state() : PluginLoadingState
      {
         return this._state;
      }
      
      public function set state(value:PluginLoadingState) : void
      {
         this._state = value;
      }
   }
}

