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
      
      public function PluginLoader(param1:MediaFactory, param2:String)
      {
         super();
         this.mediaFactory = param1;
         this.minimumSupportedFrameworkVersion = param2;
      }
      
      protected function unloadFromPluginInfo(param1:PluginInfo) : void
      {
         var _loc2_:int = 0;
         var _loc3_:MediaFactoryItem = null;
         var _loc4_:MediaFactoryItem = null;
         if(param1 != null)
         {
            _loc2_ = 0;
            while(_loc2_ < param1.numMediaFactoryItems)
            {
               _loc3_ = param1.getMediaFactoryItemAt(_loc2_);
               _loc4_ = this.mediaFactory.getItemById(_loc3_.id);
               if(_loc4_ != null)
               {
                  this.mediaFactory.removeItem(_loc4_);
               }
               _loc2_++;
            }
         }
      }
      
      protected function loadFromPluginInfo(param1:LoadTrait, param2:PluginInfo, param3:Loader = null) : void
      {
         var passedMediaFactory:MediaFactory = null;
         var i:int = 0;
         var pluginLoadTrait:PluginLoadTrait = null;
         var item:MediaFactoryItem = null;
         var loadTrait:LoadTrait = param1;
         var pluginInfo:PluginInfo = param2;
         var loader:Loader = param3;
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
                  i = 0;
                  while(i < pluginInfo.numMediaFactoryItems)
                  {
                     item = pluginInfo.getMediaFactoryItemAt(i);
                     if(item == null)
                     {
                        throw new RangeError();
                     }
                     this.mediaFactory.addItem(item);
                     i++;
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
      
      protected function isPluginCompatible(param1:Object) : Boolean
      {
         var _loc5_:Function = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = param1.hasOwnProperty(FRAMEWORK_VERSION_PROPERTY_NAME) ? param1[FRAMEWORK_VERSION_PROPERTY_NAME] : null;
         var _loc4_:Boolean = this.isPluginVersionSupported(_loc3_);
         if(_loc4_)
         {
            _loc5_ = param1.hasOwnProperty(IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME) ? param1[IS_FRAMEWORK_VERSION_SUPPORTED_PROPERTY_NAME] as Function : null;
            if(_loc5_ != null)
            {
               try
               {
                  _loc2_ = _loc5_(Version.version);
               }
               catch(error:Error)
               {
               }
            }
         }
         return _loc2_;
      }
      
      private function isPluginVersionSupported(param1:String) : Boolean
      {
         if(param1 == null || param1.length == 0)
         {
            return false;
         }
         var _loc2_:Object = VersionUtils.parseVersionString(this.minimumSupportedFrameworkVersion);
         var _loc3_:Object = VersionUtils.parseVersionString(param1);
         return _loc3_.major > _loc2_.major || _loc3_.major == _loc2_.major && _loc3_.minor >= _loc2_.minor;
      }
   }
}

