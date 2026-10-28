package org.osmf.net.dvr
{
   import flash.events.Event;
   import flash.net.NetConnection;
   import flash.net.Responder;
   import flash.utils.Dictionary;
   import org.osmf.events.MediaError;
   import org.osmf.events.MediaErrorCodes;
   import org.osmf.events.NetConnectionFactoryEvent;
   import org.osmf.media.URLResource;
   import org.osmf.net.DynamicStreamingItem;
   import org.osmf.net.DynamicStreamingResource;
   import org.osmf.net.NetConnectionFactory;
   import org.osmf.net.NetConnectionFactoryBase;
   import org.osmf.net.NetStreamUtils;
   import org.osmf.net.StreamingURLResource;
   
   [ExcludeClass]
   public class DVRCastNetConnectionFactory extends NetConnectionFactoryBase
   {
      
      private var innerFactory:NetConnectionFactoryBase;
      
      private var subscribedStreams:Dictionary = new Dictionary();
      
      public function DVRCastNetConnectionFactory(factory:NetConnectionFactoryBase = null)
      {
         this.innerFactory = factory || new NetConnectionFactory();
         this.innerFactory.addEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,this.onCreationComplete);
         this.innerFactory.addEventListener(NetConnectionFactoryEvent.CREATION_ERROR,this.onCreationError);
         super();
      }
      
      override public function create(resource:URLResource) : void
      {
         this.innerFactory.create(resource);
      }
      
      override public function closeNetConnection(netConnection:NetConnection) : void
      {
         var streamName:String = this.subscribedStreams[netConnection];
         if(streamName != null)
         {
            netConnection.call(DVRCastConstants.RPC_UNSUBSCRIBE,null,streamName);
            delete this.subscribedStreams[netConnection];
         }
         this.innerFactory.closeNetConnection(netConnection);
      }
      
      private function onCreationComplete(event:NetConnectionFactoryEvent) : void
      {
         var urlIncludesFMSApplicationInstance:Boolean;
         var dynamicResource:DynamicStreamingResource;
         var responder:Responder;
         var urlResource:URLResource = null;
         var netConnection:NetConnection = null;
         var streamNames:Vector.<String> = null;
         var totalRpcSubscribeInvocation:int = 0;
         var streamingResource:StreamingURLResource = null;
         var onStreamSubscriptionResult:Function = null;
         var onStreamInfoRetrieverComplete:Function = null;
         var onServerCallError:Function = null;
         var items:Vector.<DynamicStreamingItem> = null;
         var i:int = 0;
         onStreamSubscriptionResult = function(result:Object):void
         {
            var streamInfoRetriever:DVRCastStreamInfoRetriever = null;
            --totalRpcSubscribeInvocation;
            if(totalRpcSubscribeInvocation <= 0)
            {
               streamInfoRetriever = new DVRCastStreamInfoRetriever(netConnection,streamNames[0]);
               streamInfoRetriever.addEventListener(Event.COMPLETE,onStreamInfoRetrieverComplete);
               streamInfoRetriever.retrieve();
            }
         };
         onStreamInfoRetrieverComplete = function(event:Event):void
         {
            var recordingInfo:DVRCastRecordingInfo = null;
            var streamInfoRetriever:DVRCastStreamInfoRetriever = event.target as DVRCastStreamInfoRetriever;
            removeEventListener(NetConnectionFactoryEvent.CREATION_COMPLETE,onCreationComplete);
            if(streamInfoRetriever.streamInfo != null)
            {
               if(streamInfoRetriever.streamInfo.offline == true)
               {
                  dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_ERROR,false,false,netConnection,urlResource,new MediaError(MediaErrorCodes.DVRCAST_CONTENT_OFFLINE)));
                  for(i = 0; i < streamNames.length; ++i)
                  {
                     netConnection.call(DVRCastConstants.RPC_UNSUBSCRIBE,null,streamNames[i]);
                  }
                  netConnection = null;
               }
               else
               {
                  recordingInfo = new DVRCastRecordingInfo();
                  recordingInfo.startDuration = streamInfoRetriever.streamInfo.currentLength;
                  recordingInfo.startOffset = calculateOffset(streamInfoRetriever.streamInfo);
                  recordingInfo.startTime = new Date();
                  streamingResource.addMetadataValue(DVRCastConstants.STREAM_INFO_KEY,streamInfoRetriever.streamInfo);
                  streamingResource.addMetadataValue(DVRCastConstants.RECORDING_INFO_KEY,recordingInfo);
                  subscribedStreams[netConnection] = streamNames[0];
                  dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_COMPLETE,false,false,netConnection,urlResource));
               }
            }
            else
            {
               onServerCallError(streamInfoRetriever.error);
            }
         };
         onServerCallError = function(error:Object):void
         {
            dispatchEvent(new NetConnectionFactoryEvent(NetConnectionFactoryEvent.CREATION_ERROR,false,false,netConnection,urlResource,new MediaError(MediaErrorCodes.DVRCAST_SUBSCRIBE_FAILED,Boolean(error) ? error.message : "")));
         };
         urlResource = event.resource as URLResource;
         netConnection = event.netConnection;
         streamNames = new Vector.<String>();
         totalRpcSubscribeInvocation = 0;
         event.stopImmediatePropagation();
         streamingResource = urlResource as StreamingURLResource;
         urlIncludesFMSApplicationInstance = Boolean(streamingResource) ? streamingResource.urlIncludesFMSApplicationInstance : false;
         dynamicResource = streamingResource as DynamicStreamingResource;
         if(dynamicResource != null)
         {
            items = dynamicResource.streamItems;
            totalRpcSubscribeInvocation = int(items.length);
            for(i = 0; i < items.length; i++)
            {
               streamNames.push(items[i].streamName);
            }
         }
         else
         {
            totalRpcSubscribeInvocation = 1;
            streamNames.push(NetStreamUtils.getStreamNameFromURL(urlResource.url,urlIncludesFMSApplicationInstance));
         }
         responder = new TestableResponder(onStreamSubscriptionResult,onServerCallError);
         for(i = 0; i < streamNames.length; i++)
         {
            event.netConnection.call(DVRCastConstants.RPC_SUBSCRIBE,responder,streamNames[i]);
         }
      }
      
      private function onCreationError(event:NetConnectionFactoryEvent) : void
      {
         dispatchEvent(event.clone());
      }
      
      private function calculateOffset(streamInfo:DVRCastStreamInfo) : Number
      {
         return DVRUtils.calculateOffset(streamInfo.beginOffset,streamInfo.endOffset,streamInfo.currentLength);
      }
   }
}

