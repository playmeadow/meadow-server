package org.osmf.media.pluginClasses
{
   internal class PluginLoadingState
   {
      
      public static const LOADING:PluginLoadingState = new PluginLoadingState("Loading");
      
      public static const LOADED:PluginLoadingState = new PluginLoadingState("Loaded");
      
      private var _state:String;
      
      public function PluginLoadingState(state:String)
      {
         super();
         this._state = state;
      }
      
      public function get state() : String
      {
         return this._state;
      }
   }
}

