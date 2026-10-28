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
      
      public function RTMPDynamicStreamingNetLoader(param1:NetConnectionFactoryBase = null)
      {
         super(param1);
      }
      
      override public function canHandleResource(param1:MediaResourceBase) : Boolean
      {
         var _loc2_:DynamicStreamingResource = param1 as DynamicStreamingResource;
         return _loc2_ != null && NetStreamUtils.isRTMPStream(_loc2_.host) || Boolean(super.canHandleResource(param1));
      }
      
      override protected function createNetStreamSwitchManager(param1:NetConnection, param2:NetStream, param3:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         var _loc4_:RTMPNetStreamMetrics = null;
         if(param3 != null)
         {
            _loc4_ = new RTMPNetStreamMetrics(param2);
            return new NetStreamSwitchManager(param1,param2,param3,_loc4_,this.getDefaultSwitchingRules(_loc4_));
         }
         return null;
      }
      
      private function getDefaultSwitchingRules(param1:RTMPNetStreamMetrics) : Vector.<SwitchingRuleBase>
      {
         var _loc2_:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
         _loc2_.push(new SufficientBandwidthRule(param1));
         _loc2_.push(new InsufficientBandwidthRule(param1));
         _loc2_.push(new DroppedFramesRule(param1));
         _loc2_.push(new InsufficientBufferRule(param1));
         return _loc2_;
      }
      
      override protected function reconnectStream(param1:NetStreamLoadTrait) : void
      {
         var _loc3_:NetStreamPlayOptions = null;
         var _loc4_:DynamicStreamingItem = null;
         var _loc5_:String = null;
         var _loc2_:DynamicStreamingResource = param1.resource as DynamicStreamingResource;
         if(_loc2_ == null)
         {
            super.reconnectStream(param1);
         }
         else
         {
            _loc3_ = new NetStreamPlayOptions();
            param1.netStream.attach(param1.connection);
            _loc3_.transition = NetStreamPlayTransitions.RESUME;
            _loc4_ = _loc2_.streamItems[param1.switchManager.currentIndex];
            _loc5_ = _loc4_.streamName;
            _loc3_.streamName = _loc5_;
            param1.netStream.play2(_loc3_);
         }
      }
   }
}

