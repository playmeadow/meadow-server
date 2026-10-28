package org.osmf.media.pluginClasses
{
   import flash.display.Loader;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.PluginInfo;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.LoaderBase;
   import org.osmf.utils.Version;
   
   internal class PluginLoader extends LoaderBase
   {
      
      private static const FRAMEWORK_VERSION_PROPERTY_NAME:String = "frameworkVersion";
      
      private static const IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME:String = "isFrameworkVersionSupported";
      
      private var minimumSupportedFrameworkVersion:String;
      
      private var mediaFactory:MediaFactory;
      
      public function PluginLoader(mediaFactory:MediaFactory, minimumSupportedFrameworkVersion:String)
      {
         super();
         this.mediaFactory = mediaFactory;
         this.minimumSupportedFrameworkVersion = minimumSupportedFrameworkVersion;
      }
      
      protected function unloadFromPluginInfo(pluginInfo:PluginInfo) : void
      {
         var i:int = 0;
         var item:MediaFactoryItem = null;
         var actualItem:MediaFactoryItem = null;
         if(pluginInfo != null)
         {
            for(i = 0; i < pluginInfo.numMediaFactoryItems; i++)
            {
               item = pluginInfo.getMediaFactoryItemAt(i);
               actualItem = this.mediaFactory.getItemById(item.id);
               if(actualItem != null)
               {
                  this.mediaFactory.removeItem(actualItem);
               }
            }
         }
      }
      
      protected function loadFromPluginInfo(loadTrait:LoadTrait, pluginInfo:PluginInfo, loader:Loader = null) : void
      {
         var passedMediaFactory:MediaFactory = null;
         var i:int = 0;
         var pluginLoadTrait:PluginLoadTrait = null;
         var item:MediaFactoryItem = null;
         var invalidImplementation:Boolean = false;
         if(pluginInfo != null)
         {
            if(this.isPluginCompatible(pluginInfo))
            {
               try
               {
                  passedMediaFactory = loadTrait.resource.getMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE) as MediaFactory;
                  if(passedMediaFactory == null)
                  {
                     loadTrait.resource.addMetadataValue(PluginInfo.PLUGIN_MEDIAFACTORY_NAMESPACE,this.mediaFactory);
                  }
                  pluginInfo.initializePlugin(loadTrait.resource);
                  for(i = 0; i < pluginInfo.numMediaFactoryItems; i++)
                  {
                     item = pluginInfo.getMediaFactoryItemAt(i);
                     if(item == null)
                     {
                        throw new RangeError();
                     }
                     this.mediaFactory.addItem(item);
                  }
                  pluginLoadTrait = loadTrait as PluginLoadTrait;
                  pluginLoadTrait.pluginInfo = pluginInfo;
                  pluginLoadTrait.loader = loader;
                  updateLoadTrait(pluginLoadTrait,LoadState.READY);
               }
               catch(error:RangeError)
               {
                  invalidImplementation = true;
               }
            }
            else
            {
               updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
               loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.PLUGIN_VERSION_INVALID)));
            }
         }
         else
         {
            invalidImplementation = true;
         }
         if(invalidImplementation)
         {
            updateLoadTrait(loadTrait,LoadState.LOAD_ERROR);
            loadTrait.dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR,false,false,new MediaError(MediaErrorCodes.PLUGIN_IMPLEMENTATION_INVALID)));
         }
      }
      
      protected function isPluginCompatible(pluginInfo:Object) : Boolean
      {
         var versionSupportedFunction:Function = null;
         var isCompatible:Boolean = false;
         var version:String = pluginInfo.hasOwnProperty(FRAMEWORK_VERSION_PROPERTY_NAME) ? pluginInfo[FRAMEWORK_VERSION_PROPERTY_NAME] : null;
         var isSupported:Boolean = this.isPluginVersionSupported(version);
         if(isSupported)
         {
            versionSupportedFunction = pluginInfo.hasOwnProperty(IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME) ? pluginInfo[IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME] as Function : null;
            if(versionSupportedFunction != null)
            {
               try
               {
                  isCompatible = versionSupportedFunction(Version.version);
               }
               catch(error:Error)
               {
               }
            }
         }
         return isCompatible;
      }
      
      private function isPluginVersionSupported(pluginVersion:String) : Boolean
      {
         if(pluginVersion == null || pluginVersion.length == 0)
         {
            return false;
         }
         var minVersion:Object = VersionUtils.parseVersionString(this.minimumSupportedFrameworkVersion);
         var pVersion:Object = VersionUtils.parseVersionString(pluginVersion);
         return pVersion.major > minVersion.major || pVersion.major == minVersion.major && pVersion.minor >= minVersion.minor;
      }
   }
}

