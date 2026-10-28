package org.osmf.net.httpstreaming
{
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.media.MediaResourceBase;
   import org.osmf.media.URLResource;
   import org.osmf.metadata.Metadata;
   import org.osmf.metadata.MetadataNamespaces;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetLoader;
   import org.osmf.net.NetStreamLoadTrait;
   import org.osmf.net.NetStreamSwitchManager;
   import org.osmf.net.NetStreamSwitchManagerBase;
   import org.osmf.net.SwitchingRuleBase;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastDVRTrait;
   import org.osmf.net.httpstreaming.dvr.HTTPStreamingDVRCastTimeTrait;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FFileHandler;
   import org.osmf.net.httpstreaming.f4f.HTTPStreamingF4FIndexHandler;
   import org.osmf.net.rtmpstreaming.DroppedFramesRule;
   import org.osmf.traits.LoadState;
   
   public class HTTPStreamingNetLoader extends NetLoader
   {
      
      public function HTTPStreamingNetLoader()
      {
         super();
      }
      
      override public function canHandleResource(resource:MediaResourceBase) : Boolean
      {
         return resource.getMetadataValue(MetadataNamespaces.HTTP_STREAMING_METADATA) as Metadata != null;
      }
      
      override protected function createNetStream(connection:NetConnection, resource:URLResource) : NetStream
      {
         var fileHandler:HTTPStreamingFileHandlerBase = new HTTPStreamingF4FFileHandler();
         var indexHandler:HTTPStreamingIndexHandlerBase = new HTTPStreamingF4FIndexHandler(fileHandler);
         var httpNetStream:HTTPNetStream = new HTTPNetStream(connection,indexHandler,fileHandler);
         httpNetStream.manualSwitchMode = true;
         httpNetStream.indexInfo = HTTPStreamingUtils.createF4FIndexInfo(resource);
         return httpNetStream;
      }
      
      override protected function createNetStreamSwitchManager(connection:NetConnection, netStream:NetStream, dsResource:DynamicStreamingResource) : NetStreamSwitchManagerBase
      {
         var metrics:HTTPNetStreamMetrics = null;
         if(dsResource != null)
         {
            metrics = new HTTPNetStreamMetrics(netStream as HTTPNetStream);
            return new NetStreamSwitchManager(connection,netStream,dsResource,metrics,this.getDefaultSwitchingRules(metrics));
         }
         return null;
      }
      
      override protected function processFinishLoading(loadTrait:NetStreamLoadTrait) : void
      {
         var netStream:HTTPNetStream = null;
         var onDVRStreamInfo:Function = null;
         onDVRStreamInfo = function(event:DVRStreamInfoEvent):void
         {
            netStream.removeEventListener(DVRStreamInfoEvent.DVRSTREAMINFO,onDVRStreamInfo);
            loadTrait.setTrait(new HTTPStreamingDVRCastDVRTrait(loadTrait.connection,netStream,event.info as DVRInfo));
            loadTrait.setTrait(new HTTPStreamingDVRCastTimeTrait(loadTrait.connection,netStream,event.info as DVRInfo));
            updateLoadTrait(loadTrait,LoadState.READY);
         };
         var resource:URLResource = loadTrait.resource as URLResource;
         if(!this.dvrMetadataPresent(resource))
         {
            updateLoadTrait(loadTrait,LoadState.READY);
            return;
         }
         netStream = loadTrait.netStream as HTTPNetStream;
         netStream.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO,onDVRStreamInfo);
         netStream.DVRGetStreamInfo(null);
      }
      
      private function dvrMetadataPresent(resource:URLResource) : Boolean
      {
         var metadata:Metadata = resource.getMetadataValue(MetadataNamespaces.DVR_METADATA) as Metadata;
         return metadata != null;
      }
      
      private function getDefaultSwitchingRules(metrics:HTTPNetStreamMetrics) : Vector.<SwitchingRuleBase>
      {
         var rules:Vector.<SwitchingRuleBase> = new Vector.<SwitchingRuleBase>();
         rules.push(new DownloadRatioRule(metrics));
         rules.push(new DroppedFramesRule(metrics));
         return rules;
      }
   }
}

