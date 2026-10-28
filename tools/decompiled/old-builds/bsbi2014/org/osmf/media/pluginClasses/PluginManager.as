package org.osmf.media.pluginClasses
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.events.LoadEvent;
   import org.osmf.events.MediaErrorEvent;
   import org.osmf.events.MediaFactoryEvent;
   import org.osmf.events.PluginManagerEvent;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactory;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.PluginInfoResource;
   import org.osmf.media.URLResource;
   import org.osmf.traits.LoadState;
   import org.osmf.traits.LoadTrait;
   import org.osmf.traits.MediaTraitType;
   import org.osmf.utils.OSMFStrings;
   import org.osmf.utils.Version;
   
   [Event(name="pluginLoadError",type="org.osmf.events.PluginManagerEvent")]
   [Event(name="pluginLoad",type="org.osmf.events.PluginManagerEvent")]
   [ExcludeClass]
   public class PluginManager extends EventDispatcher
   {
      
      private static const STATIC_PLUGIN_MEDIA_INFO_ID:String = "org.osmf.plugins.StaticPluginLoader";
      
      private static const DYNAMIC_PLUGIN_MEDIA_INFO_ID:String = "org.osmf.plugins.DynamicPluginLoader";
      
      private var _mediaFactory:MediaFactory;
      
      private var _pluginFactory:MediaFactory;
      
      private var _pluginMap:Dictionary;
      
      private var _pluginList:Vector.<PluginEntry>;
      
      private var notificationFunctions:Vector.<Function>;
      
      private var createdElements:Dictionary;
      
      private var minimumSupportedFrameworkVersion:String;
      
      private var staticPluginLoader:StaticPluginLoader;
      
      private var dynamicPluginLoader:DynamicPluginLoader;
      
      public function PluginManager(mediaFactory:MediaFactory)
      {
         super();
         this._mediaFactory = mediaFactory;
         this._mediaFactory.addEventListener(MediaFactoryEvent.MEDIA_ELEMENT_CREATE,this.onMediaElementCreate);
         this.minimumSupportedFrameworkVersion = Version.lastAPICompatibleVersion;
         this.initPluginFactory();
         this._pluginMap = new Dictionary();
         this._pluginList = new Vector.<PluginEntry>();
      }
      
      public function loadPlugin(resource:MediaResourceBase) : void
      {
         var identifier:Object = null;
         var pluginEntry:PluginEntry = null;
         var onLoadStateChange:Function = null;
         var onMediaError:Function = null;
         var pluginElement:MediaElement = null;
         var loadTrait:LoadTrait = null;
         onLoadStateChange = function(event:LoadEvent):void
         {
            var pluginLoadTrait:PluginLoadTrait = null;
            if(event.loadState == LoadState.READY)
            {
               pluginEntry.state = PluginLoadingState.LOADED;
               _pluginList.push(pluginEntry);
               pluginLoadTrait = pluginElement.getTrait(MediaTraitType.LOAD) as PluginLoadTrait;
               if(pluginLoadTrait.pluginInfo.mediaElementCreationNotificationFunction != null)
               {
                  invokeMediaElementCreationNotificationForCreatedMediaElements(pluginLoadTrait.pluginInfo.mediaElementCreationNotificationFunction);
                  if(notificationFunctions == null)
                  {
                     notificationFunctions = new Vector.<Function>();
                  }
                  notificationFunctions.push(pluginLoadTrait.pluginInfo.mediaElementCreationNotificationFunction);
               }
               dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD,false,false,resource));
            }
            else if(event.loadState == LoadState.LOAD_ERROR)
            {
               delete _pluginMap[identifier];
               dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD_ERROR,false,false,resource));
            }
         };
         onMediaError = function(event:MediaErrorEvent):void
         {
            dispatchEvent(event.clone());
         };
         if(resource == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         identifier = this.getPluginIdentifier(resource);
         pluginEntry = this._pluginMap[identifier] as PluginEntry;
         if(pluginEntry != null)
         {
            dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD,false,false,resource));
         }
         else
         {
            pluginElement = this._pluginFactory.createMediaElement(resource);
            if(pluginElement != null)
            {
               pluginEntry = new PluginEntry(pluginElement,PluginLoadingState.LOADING);
               this._pluginMap[identifier] = pluginEntry;
               loadTrait = pluginElement.getTrait(MediaTraitType.LOAD) as LoadTrait;
               if(loadTrait != null)
               {
                  loadTrait.addEventListener(LoadEvent.LOAD_STATE_CHANGE,onLoadStateChange);
                  loadTrait.addEventListener(MediaErrorEvent.MEDIA_ERROR,onMediaError);
                  loadTrait.load();
               }
               else
               {
                  dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD_ERROR,false,false,resource));
               }
            }
            else
            {
               dispatchEvent(new PluginManagerEvent(PluginManagerEvent.PLUGIN_LOAD_ERROR,false,false,resource));
            }
         }
      }
      
      public function get mediaFactory() : MediaFactory
      {
         return this._mediaFactory;
      }
      
      private function getPluginIdentifier(resource:MediaResourceBase) : Object
      {
         var identifier:Object = null;
         if(resource is URLResource)
         {
            identifier = (resource as URLResource).url;
         }
         else if(resource is PluginInfoResource)
         {
            identifier = (resource as PluginInfoResource).pluginInfo;
         }
         return identifier;
      }
      
      private function initPluginFactory() : void
      {
         this._pluginFactory = new MediaFactory();
         this.staticPluginLoader = new StaticPluginLoader(this.mediaFactory,this.minimumSupportedFrameworkVersion);
         this.dynamicPluginLoader = new DynamicPluginLoader(this.mediaFactory,this.minimumSupportedFrameworkVersion);
         var staticPluginItem:MediaFactoryItem = new MediaFactoryItem(STATIC_PLUGIN_MEDIA_INFO_ID,this.staticPluginLoader.canHandleResource,this.createStaticPluginElement);
         this._pluginFactory.addItem(staticPluginItem);
         var dynamicPluginItem:MediaFactoryItem = new MediaFactoryItem(DYNAMIC_PLUGIN_MEDIA_INFO_ID,this.dynamicPluginLoader.canHandleResource,this.createDynamicPluginElement);
         this._pluginFactory.addItem(dynamicPluginItem);
      }
      
      private function createStaticPluginElement() : MediaElement
      {
         return new PluginElement(this.staticPluginLoader);
      }
      
      private function createDynamicPluginElement() : MediaElement
      {
         return new PluginElement(this.dynamicPluginLoader);
      }
      
      private function onMediaElementCreate(event:MediaFactoryEvent) : void
      {
         this.invokeMediaElementCreationNotifications(event.mediaElement);
         if(this.createdElements == null)
         {
            this.createdElements = new Dictionary(true);
         }
         this.createdElements[event.mediaElement] = true;
      }
      
      private function invokeMediaElementCreationNotifications(mediaElement:MediaElement) : void
      {
         var func:Function = null;
         for each(func in this.notificationFunctions)
         {
            this.invokeMediaElementCreationNotificationFunction(func,mediaElement);
         }
      }
      
      private function invokeMediaElementCreationNotificationFunction(func:Function, mediaElement:MediaElement) : void
      {
         try
         {
            func.call(null,mediaElement);
         }
         catch(error:Error)
         {
         }
      }
      
      private function invokeMediaElementCreationNotificationForCreatedMediaElements(func:Function) : void
      {
         var elem:Object = null;
         for(elem in this.createdElements)
         {
            this.invokeMediaElementCreationNotificationFunction(func,elem as MediaElement);
         }
      }
   }
}

