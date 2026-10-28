package org.osmf.media
{
   import org.osmf.media.pluginClasses.VersionUtils;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.Version;
   
   public class PluginInfo
   {
      
      public static const PLUGIN_MEDIAFACTORY_NAMESPACE:String = "http://www.osmf.org/plugin/mediaFactory/1.0";
      
      private var _mediaFactoryItems:Vector.<MediaFactoryItem>;
      
      private var _mediaElementCreationNotificationFunction:Function;
      
      public function PluginInfo(mediaFactoryItems:Vector.<MediaFactoryItem> = null, mediaElementCreationNotificationFunction:Function = null)
      {
         super();
         this._mediaFactoryItems = mediaFactoryItems != null ? mediaFactoryItems : new Vector.<MediaFactoryItem>();
         this._mediaElementCreationNotificationFunction = mediaElementCreationNotificationFunction;
      }
      
      public function get numMediaFactoryItems() : int
      {
         return this._mediaFactoryItems.length;
      }
      
      public function get frameworkVersion() : String
      {
         return Version.version;
      }
      
      public function getMediaFactoryItemAt(index:int) : MediaFactoryItem
      {
         if(index < 0 || index >= this._mediaFactoryItems.length)
         {
            throw new RangeError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         return this._mediaFactoryItems[index] as MediaFactoryItem;
      }
      
      public function isFrameworkVersionSupported(version:String) : Boolean
      {
         if(version == null || version.length == 0)
         {
            return false;
         }
         var playerFrameworkVersion:Object = VersionUtils.parseVersionString(version);
         var pluginFrameworkVersion:Object = VersionUtils.parseVersionString(this.frameworkVersion);
         return playerFrameworkVersion.major > pluginFrameworkVersion.major || playerFrameworkVersion.major == pluginFrameworkVersion.major && playerFrameworkVersion.minor >= pluginFrameworkVersion.minor;
      }
      
      public function initializePlugin(resource:MediaResourceBase) : void
      {
      }
      
      public function get mediaElementCreationNotificationFunction() : Function
      {
         return this._mediaElementCreationNotificationFunction;
      }
      
      final protected function get mediaFactoryItems() : Vector.<MediaFactoryItem>
      {
         return this._mediaFactoryItems;
      }
      
      final protected function set mediaFactoryItems(value:Vector.<MediaFactoryItem>) : void
      {
         this._mediaFactoryItems = value;
      }
   }
}

