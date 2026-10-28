package org.osmf.media
{
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import org.osmf.elements.ProxyElement;
   import org.osmf.events.MediaFactoryEvent;
   import org.osmf.events.PluginManagerEvent;
   import org.osmf.media.pluginClasses.PluginManager;
   import org.osmf.utils.OSMFStrings;
   
   [Event(name="mediaElementCreate",type="org.osmf.events.MediaFactoryEvent")]
   [Event(name="pluginLoadError",type="org.osmf.events.MediaFactoryEvent")]
   [Event(name="pluginLoad",type="org.osmf.events.MediaFactoryEvent")]
   public class MediaFactory extends EventDispatcher
   {
      
      private var pluginManager:PluginManager;
      
      private var allItems:Dictionary;
      
      public function MediaFactory()
      {
         super();
         this.allItems = new Dictionary();
      }
      
      private static function getItemsByResource(resource:MediaResourceBase, items:Vector.<MediaFactoryItem>) : Vector.<MediaFactoryItem>
      {
         var item:MediaFactoryItem = null;
         var results:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
         for each(item in items)
         {
            if(Boolean(item.canHandleResourceFunction(resource)))
            {
               results.push(item);
            }
         }
         return results;
      }
      
      private static function getIndexOfItem(id:String, items:Vector.<MediaFactoryItem>) : int
      {
         var item:MediaFactoryItem = null;
         for(var i:int = 0; i < items.length; i++)
         {
            item = items[i] as MediaFactoryItem;
            if(item.id == id)
            {
               return i;
            }
         }
         return -1;
      }
      
      public function addItem(item:MediaFactoryItem) : void
      {
         if(item == null || item.id == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         var items:Vector.<MediaFactoryItem> = this.findOrCreateItems(item.type);
         var existingIndex:int = getIndexOfItem(item.id,items);
         if(existingIndex != -1)
         {
            items[existingIndex] = item;
         }
         else
         {
            items.push(item);
         }
      }
      
      public function removeItem(item:MediaFactoryItem) : void
      {
         var existingIndex:int = 0;
         if(item == null || item.id == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
         }
         var items:Vector.<MediaFactoryItem> = this.allItems[item.type];
         if(items != null)
         {
            existingIndex = items.indexOf(item);
            if(existingIndex != -1)
            {
               items.splice(existingIndex,1);
            }
         }
      }
      
      public function get numItems() : int
      {
         var type:String = null;
         var items:Vector.<MediaFactoryItem> = null;
         var numItems:int = 0;
         for each(type in MediaFactoryItemType.ALL_TYPES)
         {
            items = this.allItems[type];
            if(items != null)
            {
               numItems += items.length;
            }
         }
         return numItems;
      }
      
      public function getItemAt(index:int) : MediaFactoryItem
      {
         var type:String = null;
         var items:Vector.<MediaFactoryItem> = null;
         var result:MediaFactoryItem = null;
         if(index >= 0)
         {
            for each(type in MediaFactoryItemType.ALL_TYPES)
            {
               items = this.allItems[type];
               if(items != null)
               {
                  if(index < items.length)
                  {
                     result = items[index];
                     break;
                  }
                  index -= items.length;
               }
            }
         }
         return result;
      }
      
      public function getItemById(id:String) : MediaFactoryItem
      {
         var type:String = null;
         var items:Vector.<MediaFactoryItem> = null;
         var existingIndex:int = 0;
         var result:MediaFactoryItem = null;
         for each(type in MediaFactoryItemType.ALL_TYPES)
         {
            items = this.allItems[type];
            if(items != null)
            {
               existingIndex = getIndexOfItem(id,items);
               if(existingIndex != -1)
               {
                  result = items[existingIndex];
                  break;
               }
            }
         }
         return result;
      }
      
      public function loadPlugin(resource:MediaResourceBase) : void
      {
         this.createPluginManager();
         this.pluginManager.loadPlugin(resource);
      }
      
      public function createMediaElement(resource:MediaResourceBase) : MediaElement
      {
         var proxyElement:MediaElement = null;
         this.createPluginManager();
         var mediaElement:MediaElement = this.createMediaElementByResource(resource,MediaFactoryItemType.STANDARD);
         if(mediaElement != null)
         {
            proxyElement = this.createMediaElementByResource(mediaElement.resource,MediaFactoryItemType.PROXY,mediaElement);
            mediaElement = proxyElement != null ? proxyElement : mediaElement;
            dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.MEDIA_ELEMENT_CREATE,false,false,null,mediaElement));
         }
         return mediaElement;
      }
      
      protected function resolveItems(resource:MediaResourceBase, items:Vector.<MediaFactoryItem>) : MediaFactoryItem
      {
         var item:MediaFactoryItem = null;
         if(resource == null || items == null)
         {
            return null;
         }
         var firstNativeItem:MediaFactoryItem = null;
         for(var i:int = 0; i < items.length; i++)
         {
            item = items[i] as MediaFactoryItem;
            if(item.id.indexOf("org.osmf") == -1)
            {
               return item;
            }
            if(firstNativeItem == null)
            {
               firstNativeItem = item;
            }
         }
         return firstNativeItem;
      }
      
      private function findOrCreateItems(type:String) : Vector.<MediaFactoryItem>
      {
         if(this.allItems[type] == null)
         {
            this.allItems[type] = new Vector.<MediaFactoryItem>();
         }
         return this.allItems[type] as Vector.<MediaFactoryItem>;
      }
      
      private function createMediaElementByResource(resource:MediaResourceBase, itemType:String, wrappedElement:MediaElement = null) : MediaElement
      {
         var item:MediaFactoryItem = null;
         var nextElementToWrap:MediaElement = null;
         var i:int = 0;
         var proxyItem:MediaFactoryItem = null;
         var proxyElement:ProxyElement = null;
         var mediaElement:MediaElement = null;
         var items:Vector.<MediaFactoryItem> = getItemsByResource(resource,this.allItems[itemType]);
         if(itemType == MediaFactoryItemType.STANDARD)
         {
            item = this.resolveItems(resource,items) as MediaFactoryItem;
            if(item != null)
            {
               mediaElement = this.invokeMediaElementCreationFunction(item);
            }
         }
         else if(itemType == MediaFactoryItemType.PROXY)
         {
            nextElementToWrap = wrappedElement;
            for(i = int(items.length); i > 0; i--)
            {
               proxyItem = items[i - 1] as MediaFactoryItem;
               proxyElement = this.invokeMediaElementCreationFunction(proxyItem) as ProxyElement;
               if(proxyElement != null)
               {
                  proxyElement.proxiedElement = nextElementToWrap;
                  nextElementToWrap = proxyElement;
               }
            }
            mediaElement = nextElementToWrap;
         }
         if(mediaElement != null)
         {
            mediaElement.resource = resource;
         }
         return mediaElement;
      }
      
      private function onPluginLoad(event:PluginManagerEvent) : void
      {
         dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD,false,false,event.resource));
      }
      
      private function onPluginLoadError(event:PluginManagerEvent) : void
      {
         dispatchEvent(new MediaFactoryEvent(MediaFactoryEvent.PLUGIN_LOAD_ERROR,false,false,event.resource));
      }
      
      private function invokeMediaElementCreationFunction(item:MediaFactoryItem) : MediaElement
      {
         var mediaElement:MediaElement = null;
         try
         {
            mediaElement = item.mediaElementCreationFunction();
         }
         catch(error:Error)
         {
         }
         return mediaElement;
      }
      
      private function createPluginManager() : void
      {
         if(this.pluginManager == null)
         {
            this.pluginManager = new PluginManager(this);
            this.pluginManager.addEventListener(PluginManagerEvent.PLUGIN_LOAD,this.onPluginLoad);
            this.pluginManager.addEventListener(PluginManagerEvent.PLUGIN_LOAD_ERROR,this.onPluginLoadError);
         }
      }
   }
}

