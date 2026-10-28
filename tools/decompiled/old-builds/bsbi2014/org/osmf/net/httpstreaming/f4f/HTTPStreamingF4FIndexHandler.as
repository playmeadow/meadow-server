package org.osmf.net.httpstreaming.f4f
{
   import flash.net.URLRequest;
   import flash.utils.ByteArray;
   import org.osmf.elements.f4mClasses.BootstrapInfo;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.events.HTTPStreamingFileHandlerEvent;
   import org.osmf.events.HTTPStreamingIndexHandlerEvent;
   import org.osmf.net.dvr.DVRUtils;
   import org.osmf.net.httpstreaming.HTTPStreamRequest;
   import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
   import org.osmf.net.httpstreaming.HTTPStreamingIndexHandlerBase;
   import org.osmf.net.httpstreaming.HTTPStreamingUtils;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   
   [ExcludeClass]
   public class HTTPStreamingF4FIndexHandler extends HTTPStreamingIndexHandlerBase
   {
      
      public static const DEFAULT_FRAGMENTS_THRESHOLD:uint = 5;
      
      private var pendingIndexLoads:int;
      
      private var pendingIndexUpdates:int;
      
      private var bootstrapBoxes:Vector.<AdobeBootstrapBox>;
      
      private var serverBaseURL:String;
      
      private var streamInfos:Vector.<HTTPStreamingF4FStreamInfo>;
      
      private var currentQuality:int;
      
      private var currentFAI:FragmentAccessInformation;
      
      private var fragmentsThreshold:uint;
      
      private var fragmentRunTablesUpdating:Boolean;
      
      private var f4fIndexInfo:HTTPStreamingF4FIndexInfo;
      
      private var fileHandler:HTTPStreamingFileHandlerBase;
      
      private var dvrGetStreamInfoCall:Boolean;
      
      private var playInProgress:Boolean;
      
      private var offsetFromCurrent:Number = 5;
      
      private var delay:Number = 0.05;
      
      private var pureLiveOffset:Number = NaN;
      
      public function HTTPStreamingF4FIndexHandler(fileHandler:HTTPStreamingFileHandlerBase, fragmentsThreshold:uint = 5)
      {
         super();
         this.currentQuality = -1;
         this.currentFAI = null;
         this.fragmentRunTablesUpdating = false;
         this.fileHandler = fileHandler;
         this.fragmentsThreshold = fragmentsThreshold;
         this.dvrGetStreamInfoCall = false;
         fileHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_BOOTSTRAP_BOX,this.onNewBootstrapBox);
      }
      
      public function get bootstrapInfo() : AdobeBootstrapBox
      {
         return this.currentQuality < 0 ? null : this.bootstrapBoxes[this.currentQuality];
      }
      
      override public function dvrGetStreamInfo(indexInfo:Object) : void
      {
         this.dvrGetStreamInfoCall = true;
         this.playInProgress = false;
         this.initialize(indexInfo);
      }
      
      override public function initialize(indexInfo:Object) : void
      {
         var bootstrapBox:AdobeBootstrapBox = null;
         var bootstrap:BootstrapInfo = null;
         this.f4fIndexInfo = indexInfo as HTTPStreamingF4FIndexInfo;
         if(this.f4fIndexInfo == null || this.f4fIndexInfo.streamInfos == null || this.f4fIndexInfo.streamInfos.length <= 0)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR));
            return;
         }
         this.bootstrapBoxes = new Vector.<AdobeBootstrapBox>(this.f4fIndexInfo.streamInfos.length);
         this.fragmentRunTablesUpdating = false;
         this.playInProgress = false;
         this.pendingIndexLoads = 0;
         this.pureLiveOffset = NaN;
         this.serverBaseURL = this.f4fIndexInfo.serverBaseURL;
         this.streamInfos = this.f4fIndexInfo.streamInfos;
         for(var i:int = 0; i < this.streamInfos.length; i++)
         {
            bootstrap = this.streamInfos[i].bootstrapInfo;
            if(bootstrap == null || bootstrap.url == null && bootstrap.data == null)
            {
               dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR));
               return;
            }
            if(bootstrap.data != null)
            {
               bootstrapBox = this.processBootstrapData(bootstrap.data,null);
               if(bootstrapBox == null)
               {
                  dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR));
                  return;
               }
               this.bootstrapBoxes[i] = bootstrapBox;
            }
            else
            {
               ++this.pendingIndexLoads;
               dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX,false,false,false,NaN,null,null,new URLRequest(HTTPStreamingUtils.normalizeURL(bootstrap.url)),i,true));
            }
         }
         if(this.pendingIndexLoads == 0)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_RATES,false,false,false,NaN,this.getStreamNames(this.streamInfos),this.getQualityRates(this.streamInfos)));
            this.notifyIndexReady(0);
         }
      }
      
      override public function processIndexData(data:*, indexContext:Object) : void
      {
         var index:int = indexContext as int;
         var bootstrapBox:AdobeBootstrapBox = this.processBootstrapData(data,index);
         if(bootstrapBox == null)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR));
            return;
         }
         if(!this.fragmentRunTablesUpdating)
         {
            --this.pendingIndexLoads;
         }
         else
         {
            --this.pendingIndexUpdates;
            if(this.pendingIndexUpdates == 0)
            {
               this.fragmentRunTablesUpdating = false;
               this.dispatchDVRStreamInfo(bootstrapBox);
            }
         }
         if(this.bootstrapBoxes[index] == null || this.bootstrapBoxes[index].bootstrapVersion < bootstrapBox.bootstrapVersion || this.bootstrapBoxes[index].currentMediaTime < bootstrapBox.currentMediaTime)
         {
            this.delay = 0.05;
            this.bootstrapBoxes[index] = bootstrapBox;
         }
         if(this.pendingIndexLoads == 0 && !this.fragmentRunTablesUpdating)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_RATES,false,false,false,NaN,this.getStreamNames(this.streamInfos),this.getQualityRates(this.streamInfos)));
            this.notifyIndexReady(index);
         }
      }
      
      override public function getFileForTime(time:Number, quality:int) : HTTPStreamRequest
      {
         var fdp:FragmentDurationPair = null;
         var segId:uint = 0;
         var requestUrl:String = null;
         var abst:AdobeBootstrapBox = this.bootstrapBoxes[quality];
         var streamRequest:HTTPStreamRequest = null;
         if(!this.playInProgress && this.stopPlaying(abst))
         {
            return null;
         }
         this.checkMetadata(quality,abst);
         var frt:AdobeFragmentRunTable = this.getFragmentRunTable(abst);
         if(time >= 0 && time * abst.timeScale <= abst.currentMediaTime && quality >= 0 && quality < this.streamInfos.length)
         {
            this.currentFAI = frt.findFragmentIdByTime(time * abst.timeScale,abst.currentMediaTime,abst.contentComplete() ? false : abst.live);
            if(this.currentFAI == null || this.fragmentOverflow(abst,this.currentFAI.fragId))
            {
               if(abst.contentComplete())
               {
                  if(abst.live)
                  {
                     return new HTTPStreamRequest(null,quality,-1,-1,true);
                  }
                  return null;
               }
               this.adjustDelay();
               this.refreshBootstrapInfo(quality);
               return new HTTPStreamRequest(null,quality,0,this.delay);
            }
            this.playInProgress = true;
            fdp = frt.fragmentDurationPairs[0];
            segId = abst.findSegmentId(this.currentFAI.fragId - fdp.firstFragment + 1);
            requestUrl = "";
            if((this.streamInfos[quality].streamName as String).indexOf("http") != 0)
            {
               requestUrl = this.serverBaseURL + "/" + this.streamInfos[quality].streamName + "Seg" + segId + "-Frag" + this.currentFAI.fragId;
            }
            else
            {
               requestUrl = this.streamInfos[quality].streamName + "Seg" + segId + "-Frag" + this.currentFAI.fragId;
            }
            streamRequest = new HTTPStreamRequest(requestUrl);
            this.checkQuality(quality);
            this.notifyFragmentDuration(this.currentFAI.fragDuration / abst.timeScale);
         }
         return streamRequest;
      }
      
      override public function getNextFile(quality:int) : HTTPStreamRequest
      {
         var frt:AdobeFragmentRunTable = null;
         var oldCurrentFAI:FragmentAccessInformation = null;
         var fdp:FragmentDurationPair = null;
         var segId:uint = 0;
         var requestUrl:String = null;
         var abst:AdobeBootstrapBox = this.bootstrapBoxes[quality];
         var streamRequest:HTTPStreamRequest = null;
         if(!this.playInProgress && this.stopPlaying(abst))
         {
            return null;
         }
         this.checkMetadata(quality,abst);
         if(quality >= 0 && quality < this.streamInfos.length)
         {
            frt = this.getFragmentRunTable(abst);
            oldCurrentFAI = this.currentFAI;
            this.currentFAI = frt.validateFragment(this.currentFAI.fragId + 1,abst.currentMediaTime,abst.contentComplete() ? false : abst.live);
            if(this.currentFAI == null || this.fragmentOverflow(abst,this.currentFAI.fragId))
            {
               if(!abst.live || abst.contentComplete())
               {
                  if(abst.live)
                  {
                     return new HTTPStreamRequest(null,quality,-1,-1,true);
                  }
                  return null;
               }
               this.adjustDelay();
               this.currentFAI = oldCurrentFAI;
               this.refreshBootstrapInfo(quality);
               return new HTTPStreamRequest(null,quality,0,this.delay);
            }
            this.playInProgress = true;
            fdp = frt.fragmentDurationPairs[0];
            segId = abst.findSegmentId(this.currentFAI.fragId - fdp.firstFragment + 1);
            requestUrl = "";
            if((this.streamInfos[quality].streamName as String).indexOf("http") != 0)
            {
               requestUrl = this.serverBaseURL + "/" + this.streamInfos[quality].streamName + "Seg" + segId + "-Frag" + this.currentFAI.fragId;
            }
            else
            {
               requestUrl = this.streamInfos[quality].streamName + "Seg" + segId + "-Frag" + this.currentFAI.fragId;
            }
            streamRequest = new HTTPStreamRequest(requestUrl);
            this.checkQuality(quality);
            this.notifyFragmentDuration(this.currentFAI.fragDuration / abst.timeScale);
         }
         return streamRequest;
      }
      
      internal function calculateSegmentDuration(abst:AdobeBootstrapBox, timeBias:Number) : Number
      {
         var fragmentDurationPair:FragmentDurationPair = null;
         var duration:Number = NaN;
         var durationAccrued:Number = NaN;
         var fragmentDurationPairs:Vector.<FragmentDurationPair> = abst.fragmentRunTables[0].fragmentDurationPairs;
         var fragmentId:uint = this.currentFAI.fragId;
         var index:int = fragmentDurationPairs.length - 1;
         while(index >= 0)
         {
            fragmentDurationPair = fragmentDurationPairs[index];
            if(fragmentDurationPair.firstFragment <= fragmentId)
            {
               duration = fragmentDurationPair.duration;
               durationAccrued = fragmentDurationPair.durationAccrued;
               durationAccrued += (fragmentId - fragmentDurationPair.firstFragment) * fragmentDurationPair.duration;
               if(timeBias > 0)
               {
                  duration -= timeBias - durationAccrued;
               }
               return duration;
            }
            index--;
         }
         return 0;
      }
      
      private function checkQuality(quality:int) : void
      {
         var prevAdditionalHeader:ByteArray = null;
         var newAdditionalHeader:ByteArray = null;
         var flvTag:FLVTagScriptDataObject = null;
         if(this.currentQuality != quality)
         {
            prevAdditionalHeader = this.currentQuality < 0 ? null : this.streamInfos[this.currentQuality].additionalHeader;
            this.currentQuality = quality;
            newAdditionalHeader = this.streamInfos[this.currentQuality].additionalHeader;
            if(newAdditionalHeader != prevAdditionalHeader && newAdditionalHeader != null)
            {
               flvTag = new FLVTagScriptDataObject();
               flvTag.data = newAdditionalHeader;
               dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_SCRIPT_DATA,false,false,false,NaN,null,null,null,null,true,0,flvTag,true,false));
            }
         }
      }
      
      private function checkMetadata(quality:int, abst:AdobeBootstrapBox) : void
      {
         if(this.currentQuality != quality)
         {
            this.notifyTotalDuration(abst.totalDuration / abst.timeScale,quality);
         }
      }
      
      private function refreshBootstrapInfo(quality:uint) : void
      {
         ++this.pendingIndexUpdates;
         this.fragmentRunTablesUpdating = true;
         dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX,false,false,false,NaN,null,null,new URLRequest(HTTPStreamingUtils.normalizeURL((this.streamInfos[quality] as HTTPStreamingF4FStreamInfo).bootstrapInfo.url)),quality,true));
      }
      
      private function processBootstrapData(data:*, indexContext:Object) : AdobeBootstrapBox
      {
         var boxes:Vector.<Box> = null;
         var bootstrapBox:AdobeBootstrapBox = null;
         var parser:BoxParser = new BoxParser();
         data.position = 0;
         parser.init(data);
         try
         {
            boxes = parser.getBoxes();
         }
         catch(e:Error)
         {
            boxes = null;
         }
         if(boxes == null || boxes.length < 1)
         {
            return null;
         }
         bootstrapBox = boxes[0] as AdobeBootstrapBox;
         if(bootstrapBox == null)
         {
            return null;
         }
         if(this.serverBaseURL == null || this.serverBaseURL.length <= 0)
         {
            if(bootstrapBox.serverBaseURLs == null || bootstrapBox.serverBaseURLs.length <= 0)
            {
               return null;
            }
         }
         return bootstrapBox;
      }
      
      private function getQualityRates(streamInfos:Vector.<HTTPStreamingF4FStreamInfo>) : Array
      {
         var i:int = 0;
         var streamInfo:HTTPStreamingF4FStreamInfo = null;
         var rates:Array = [];
         if(streamInfos.length >= 1)
         {
            for(i = 0; i < streamInfos.length; i++)
            {
               streamInfo = streamInfos[i] as HTTPStreamingF4FStreamInfo;
               rates.push(streamInfo.bitrate);
            }
         }
         return rates;
      }
      
      private function getStreamNames(streamInfos:Vector.<HTTPStreamingF4FStreamInfo>) : Array
      {
         var i:int = 0;
         var streamInfo:HTTPStreamingF4FStreamInfo = null;
         var streamNames:Array = [];
         if(streamInfos.length >= 1)
         {
            for(i = 0; i < streamInfos.length; i++)
            {
               streamInfo = streamInfos[i] as HTTPStreamingF4FStreamInfo;
               streamNames.push(streamInfo.streamName);
            }
         }
         return streamNames;
      }
      
      private function getFragmentRunTable(abst:AdobeBootstrapBox) : AdobeFragmentRunTable
      {
         return abst.fragmentRunTables[0];
      }
      
      private function notifyTotalDuration(duration:Number, quality:int) : void
      {
         var sdo:FLVTagScriptDataObject = new FLVTagScriptDataObject();
         var metaInfo:Object = this.f4fIndexInfo.streamInfos[quality].streamMetadata;
         if(metaInfo == null)
         {
            metaInfo = new Object();
         }
         metaInfo.duration = duration;
         sdo.objects = ["onMetaData",metaInfo];
         dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_SCRIPT_DATA,false,false,false,NaN,null,null,null,null,false,0,sdo,false,true));
      }
      
      private function notifyFragmentDuration(duration:Number) : void
      {
         dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_SEGMENT_DURATION,false,false,false,NaN,null,null,null,null,true,duration));
      }
      
      private function notifyIndexReady(quality:int) : void
      {
         var abst:AdobeBootstrapBox = this.bootstrapBoxes[quality];
         var frt:AdobeFragmentRunTable = this.getFragmentRunTable(abst);
         this.dispatchDVRStreamInfo(abst);
         if(!this.dvrGetStreamInfoCall)
         {
            if(abst.live && this.f4fIndexInfo.dvrInfo == null && isNaN(this.pureLiveOffset))
            {
               this.pureLiveOffset = abst.currentMediaTime - this.offsetFromCurrent * abst.timeScale > 0 ? abst.currentMediaTime / abst.timeScale - this.offsetFromCurrent : NaN;
            }
            dispatchEvent(new HTTPStreamingIndexHandlerEvent(HTTPStreamingIndexHandlerEvent.NOTIFY_INDEX_READY,false,false,abst.live,this.pureLiveOffset));
         }
         this.dvrGetStreamInfoCall = false;
      }
      
      private function stopPlaying(abst:AdobeBootstrapBox) : Boolean
      {
         var frt:AdobeFragmentRunTable = this.getFragmentRunTable(abst);
         if(this.f4fIndexInfo.dvrInfo == null && abst.live && frt.tableComplete() || this.f4fIndexInfo.dvrInfo != null && this.f4fIndexInfo.dvrInfo.offline)
         {
            return true;
         }
         return false;
      }
      
      private function onNewBootstrapBox(event:HTTPStreamingFileHandlerEvent) : void
      {
         var abst:AdobeBootstrapBox = this.bootstrapBoxes[this.currentQuality];
         if(abst.bootstrapVersion < event.bootstrapBox.bootstrapVersion || abst.currentMediaTime < event.bootstrapBox.currentMediaTime)
         {
            this.bootstrapBoxes[this.currentQuality] = event.bootstrapBox;
            this.dispatchDVRStreamInfo(event.bootstrapBox);
         }
      }
      
      private function dispatchDVRStreamInfo(abst:AdobeBootstrapBox) : void
      {
         var frt:AdobeFragmentRunTable = this.getFragmentRunTable(abst);
         if(this.f4fIndexInfo.dvrInfo != null)
         {
            this.f4fIndexInfo.dvrInfo.isRecording = !frt.tableComplete();
            if(isNaN(this.f4fIndexInfo.dvrInfo.startTime))
            {
               this.f4fIndexInfo.dvrInfo.startTime = frt.tableComplete() ? 0 : DVRUtils.calculateOffset(this.f4fIndexInfo.dvrInfo.beginOffset < 0 || isNaN(this.f4fIndexInfo.dvrInfo.beginOffset) ? 0 : this.f4fIndexInfo.dvrInfo.beginOffset,this.f4fIndexInfo.dvrInfo.endOffset < 0 || isNaN(this.f4fIndexInfo.dvrInfo.endOffset) ? 0 : this.f4fIndexInfo.dvrInfo.endOffset,abst.totalDuration / abst.timeScale);
               this.f4fIndexInfo.dvrInfo.startTime += frt.fragmentDurationPairs[0].durationAccrued / abst.timeScale;
               if(this.f4fIndexInfo.dvrInfo.startTime > abst.currentMediaTime)
               {
                  this.f4fIndexInfo.dvrInfo.startTime = abst.currentMediaTime;
               }
            }
            this.f4fIndexInfo.dvrInfo.curLength = abst.currentMediaTime / abst.timeScale - this.f4fIndexInfo.dvrInfo.startTime;
            dispatchEvent(new DVRStreamInfoEvent(DVRStreamInfoEvent.DVRSTREAMINFO,false,false,this.f4fIndexInfo.dvrInfo));
         }
      }
      
      private function fragmentOverflow(abst:AdobeBootstrapBox, fragId:uint) : Boolean
      {
         var fragmentRunTable:AdobeFragmentRunTable = abst.fragmentRunTables[0];
         var fdp:FragmentDurationPair = fragmentRunTable.fragmentDurationPairs[0];
         var segmentRunTable:AdobeSegmentRunTable = abst.segmentRunTables[0];
         return segmentRunTable == null || segmentRunTable.totalFragments + fdp.firstFragment - 1 < fragId;
      }
      
      private function adjustDelay() : void
      {
         if(this.delay < 1)
         {
            this.delay *= 2;
            if(this.delay > 1)
            {
               this.delay = 1;
            }
         }
      }
   }
}

