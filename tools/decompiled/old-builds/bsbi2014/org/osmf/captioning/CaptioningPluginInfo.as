package org.osmf.captioning
{
   import org.osmf.captioning.media.CaptioningProxyElement;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.MediaFactoryItemType;
   import org.osmf.media.PluginInfo;
   import org.osmf.net.NetLoader;
   
   public class CaptioningPluginInfo extends PluginInfo
   {
      
      public static const CAPTIONING_METADATA_NAMESPACE:String = "http://www.osmf.org/captioning/1.0";
      
      public static const CAPTIONING_METADATA_KEY_URI:String = "uri";
      
      public static const CAPTIONING_TEMPORAL_METADATA_NAMESPACE:String = "http://www.osmf.org/temporal/captioning";
      
      public function CaptioningPluginInfo()
      {
         var items:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
         var loader:NetLoader = new NetLoader();
         var item:MediaFactoryItem = new MediaFactoryItem("org.osmf.captioning.CaptioningPluginInfo",loader.canHandleResource,this.createCaptioningProxyElement,MediaFactoryItemType.PROXY);
         items.push(item);
         super(items);
      }
      
      private function createCaptioningProxyElement() : MediaElement
      {
         return new CaptioningProxyElement();
      }
   }
}

