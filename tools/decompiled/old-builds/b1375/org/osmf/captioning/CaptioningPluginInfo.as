package org.osmf.captioning
{
   import org.osmf.captioning.media.CaptioningProxyElement;
   import org.osmf.media.MediaElement;
   import org.osmf.media.MediaFactoryItem;
   import org.osmf.media.PluginInfo;
   import org.osmf.net.NetLoader;
   
   public class CaptioningPluginInfo extends PluginInfo
   {
      
      public static const CAPTIONING_METADATA_NAMESPACE:String = "http://www.osmf.org/captioning/1.0";
      
      public static const CAPTIONING_METADATA_KEY_URI:String = "uri";
      
      public static const CAPTIONING_TEMPORAL_METADATA_NAMESPACE:String = "http://www.osmf.org/temporal/captioning";
      
      public function CaptioningPluginInfo()
      {
         var _loc1_:Vector.<MediaFactoryItem> = new Vector.<MediaFactoryItem>();
         var _loc2_:NetLoader = new NetLoader();
         var _loc3_:MediaFactoryItem = new MediaFactoryItem("org.osmf.captioning.CaptioningPluginInfo",_loc2_.canHandleResource,createCaptioningProxyElement,"proxy");
         _loc1_.push(_loc3_);
         super(_loc1_);
      }
      
      private function createCaptioningProxyElement() : MediaElement
      {
         return new CaptioningProxyElement();
      }
   }
}

