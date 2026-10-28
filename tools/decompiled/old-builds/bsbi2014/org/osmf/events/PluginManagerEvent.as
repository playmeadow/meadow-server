package org.osmf.events
{
   import flash.events.Event;
   import org.osmf.media.MediaResourceBase;
   
   [ExcludeClass]
   public class PluginManagerEvent extends Event
   {
      
      public static const PLUGIN_LOAD:String = "pluginLoad";
      
      public static const PLUGIN_LOAD_ERROR:String = "pluginLoadError";
      
      private var _resource:MediaResourceBase;
      
      public function PluginManagerEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, resource:MediaResourceBase = null)
      {
         super(type,bubbles,cancelable);
         this._resource = resource;
      }
      
      public function get resource() : MediaResourceBase
      {
         return this._resource;
      }
      
      override public function clone() : Event
      {
         return new PluginManagerEvent(type,bubbles,cancelable,this._resource);
      }
   }
}

