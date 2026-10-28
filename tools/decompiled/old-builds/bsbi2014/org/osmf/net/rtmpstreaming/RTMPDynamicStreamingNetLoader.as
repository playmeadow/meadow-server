package org.osmf.net.rtmpstreaming
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.net.NetStreamPlayTransitions;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetConnectionFactoryBase;
   import org.osmf.net.NetLoader;
   import org.osmf.net.NetStreamLoadTrait;
   import org.osmf.net.NetStreamSwitchManager;
   import org.osmf.net.NetStreamSwitchManagerBase;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.SwitchingRuleBase;
   
   public class RTMPDynamicStreamingNetLoader extends NetLoader
   {
      
      public function RTMPDynamicStreamingNetLoader(factory:NetConnectionFactoryBase = null)
      {
         super(factory);
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;
         return dsResource != null && NetStreamUtils.isRTMPStream(dsResource.host) || Boolean(super.canHandleResource(resource));
      }
      
      override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         var metrics:RTMPNetStreamMetrics = null;
         if(dsResource != null)
         {
            metrics = new RTMPNetStreamMetrics(netStream);
            return new NetStreamSwitchManager(connection,netStream,dsResource,metrics,this.getDefaultSwitchingRules(metrics));
         }
         return null;
      }
      
      private function getDefaultSwitchingRules(metrics:RTMPNetStreamMetrics) : Vector.<SwitchingRuleBase>
      {
         var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
         rules.push(new SufficientBandwidthRule(metrics));
         rules.push(new InsufficientBandwidthRule(metrics));
         rules.push(new DroppedFramesRule(metrics));
         rules.push(new InsufficientBufferRule(metrics));
         return rules;
      }
      
      override protected function reconnectStream(loadTrait:NetStreamLoadTrait) : void
      {
         var nsPlayOptions:NetStreamPlayOptions = null;
         var currentStreamItem:DynamicStreamingItem = null;
         var streamName:String = null;
         var dsResource:DynamicStreamingResource = loadTrait.resource as DynamicStreamingResource;
         if(dsResource == null)
         {
            super.reconnectStream(loadTrait);
         }
         else
         {
            nsPlayOptions = new NetStreamPlayOptions();
            loadTrait.netStream.attach(loadTrait.connection);
            nsPlayOptions.transition = NetStreamPlayTransitions.RESUME;
            currentStreamItem = dsResource.streamItems[loadTrait.switchManager.currentIndex];
            streamName = currentStreamItem.streamName;
            nsPlayOptions.streamName = streamName;
            loadTrait.netStream.play2(nsPlayOptions);
         }
      }
   }
}

