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
      
      public function HTTPStreamingF4FIndexHandler(param1:HTTPStreamingFileHandlerBase, param2:uint = 5)
      {
         super();
         currentQuality = -1;
         currentFAI = null;
         fragmentRunTablesUpdating = false;
         this.fileHandler = param1;
         this.fragmentsThreshold = param2;
         dvrGetStreamInfoCall = false;
         param1.addEventListener("notifyBootstrapBox",onNewBootstrapBox);
      }
      
      public function get bootstrapInfo() : AdobeBootstrapBox
      {
         return currentQuality < 0 ? null : bootstrapBoxes[currentQuality];
      }
      
      override public function dvrGetStreamInfo(param1:Object) : void
      {
         dvrGetStreamInfoCall = true;
         playInProgress = false;
         initialize(param1);
      }
      
      override public function initialize(param1:Object) : void
      {
         var _loc2_:AdobeBootstrapBox = null;
         var _loc4_:int = 0;
         var _loc3_:BootstrapInfo = null;
         f4fIndexInfo = param1 as HTTPStreamingF4FIndexInfo;
         if(f4fIndexInfo == null || f4fIndexInfo.streamInfos == null || f4fIndexInfo.streamInfos.length <= 0)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyError"));
            return;
         }
         bootstrapBoxes = new Vector.<AdobeBootstrapBox>(f4fIndexInfo.streamInfos.length);
         fragmentRunTablesUpdating = false;
         playInProgress = false;
         pendingIndexLoads = 0;
         pureLiveOffset = NaN;
         serverBaseURL = f4fIndexInfo.serverBaseURL;
         streamInfos = f4fIndexInfo.streamInfos;
         _loc4_ = 0;
         while(_loc4_ < streamInfos.length)
         {
            _loc3_ = streamInfos[_loc4_].bootstrapInfo;
            if(_loc3_ == null || _loc3_.url == null && _loc3_.data == null)
            {
               dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyError"));
               return;
            }
            if(_loc3_.data != null)
            {
               _loc2_ = processBootstrapData(_loc3_.data,null);
               if(_loc2_ == null)
               {
                  dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyError"));
                  return;
               }
               bootstrapBoxes[_loc4_] = _loc2_;
            }
            else
            {
               pendingIndexLoads = pendingIndexLoads + 1;
               dispatchEvent(new HTTPStreamingIndexHandlerEvent("requestLoadIndex",false,false,false,NaN,null,null,new URLRequest(HTTPStreamingUtils.normalizeURL(_loc3_.url)),_loc4_,true));
            }
            _loc4_++;
         }
         if(pendingIndexLoads == 0)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyRates",false,false,false,NaN,getStreamNames(streamInfos),getQualityRates(streamInfos)));
            notifyIndexReady(0);
         }
      }
      
      override public function processIndexData(param1:*, param2:Object) : void
      {
         var _loc4_:int = param2 as int;
         var _loc3_:AdobeBootstrapBox = processBootstrapData(param1,_loc4_);
         if(_loc3_ == null)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyError"));
            return;
         }
         if(!fragmentRunTablesUpdating)
         {
            pendingIndexLoads = pendingIndexLoads - 1;
         }
         else
         {
            pendingIndexUpdates = pendingIndexUpdates - 1;
            if(pendingIndexUpdates == 0)
            {
               fragmentRunTablesUpdating = false;
               dispatchDVRStreamInfo(_loc3_);
            }
         }
         if(bootstrapBoxes[_loc4_] == null || bootstrapBoxes[_loc4_].bootstrapVersion < _loc3_.bootstrapVersion || bootstrapBoxes[_loc4_].currentMediaTime < _loc3_.currentMediaTime)
         {
            delay = 0.05;
            bootstrapBoxes[_loc4_] = _loc3_;
         }
         if(pendingIndexLoads == 0 && !fragmentRunTablesUpdating)
         {
            dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyRates",false,false,false,NaN,getStreamNames(streamInfos),getQualityRates(streamInfos)));
            notifyIndexReady(_loc4_);
         }
      }
      
      override public function getFileForTime(param1:Number, param2:int) : HTTPStreamRequest
      {
         var _loc7_:FragmentDurationPair = null;
         var _loc3_:* = 0;
         var _loc8_:String = null;
         var _loc6_:AdobeBootstrapBox = bootstrapBoxes[param2];
         var _loc4_:HTTPStreamRequest = null;
         if(!playInProgress && stopPlaying(_loc6_))
         {
            return null;
         }
         checkMetadata(param2,_loc6_);
         var _loc5_:AdobeFragmentRunTable = getFragmentRunTable(_loc6_);
         if(param1 >= 0 && param1 * _loc6_.timeScale <= _loc6_.currentMediaTime && param2 >= 0 && param2 < streamInfos.length)
         {
            currentFAI = _loc5_.findFragmentIdByTime(param1 * _loc6_.timeScale,_loc6_.currentMediaTime,_loc6_.contentComplete() ? false : _loc6_.live);
            if(currentFAI == null || fragmentOverflow(_loc6_,currentFAI.fragId))
            {
               if(_loc6_.contentComplete())
               {
                  if(_loc6_.live)
                  {
                     return new HTTPStreamRequest(null,param2,-1,-1,true);
                  }
                  return null;
               }
               adjustDelay();
               refreshBootstrapInfo(param2);
               return new HTTPStreamRequest(null,param2,0,delay);
            }
            playInProgress = true;
            _loc7_ = _loc5_.fragmentDurationPairs[0];
            _loc3_ = _loc6_.findSegmentId(currentFAI.fragId - _loc7_.firstFragment + 1);
            _loc8_ = "";
            if((streamInfos[param2].streamName as String).indexOf("http") != 0)
            {
               _loc8_ = serverBaseURL + "/" + streamInfos[param2].streamName + "Seg" + _loc3_ + "-Frag" + currentFAI.fragId;
            }
            else
            {
               _loc8_ = streamInfos[param2].streamName + "Seg" + _loc3_ + "-Frag" + currentFAI.fragId;
            }
            _loc4_ = new HTTPStreamRequest(_loc8_);
            checkQuality(param2);
            notifyFragmentDuration(currentFAI.fragDuration / _loc6_.timeScale);
         }
         return _loc4_;
      }
      
      override public function getNextFile(param1:int) : HTTPStreamRequest
      {
         var _loc5_:AdobeFragmentRunTable = null;
         var _loc2_:FragmentAccessInformation = null;
         var _loc7_:FragmentDurationPair = null;
         var _loc3_:* = 0;
         var _loc8_:String = null;
         var _loc6_:AdobeBootstrapBox = bootstrapBoxes[param1];
         var _loc4_:HTTPStreamRequest = null;
         if(!playInProgress && stopPlaying(_loc6_))
         {
            return null;
         }
         checkMetadata(param1,_loc6_);
         if(param1 >= 0 && param1 < streamInfos.length)
         {
            _loc5_ = getFragmentRunTable(_loc6_);
            _loc2_ = currentFAI;
            currentFAI = _loc5_.validateFragment(currentFAI.fragId + 1,_loc6_.currentMediaTime,_loc6_.contentComplete() ? false : _loc6_.live);
            if(currentFAI == null || fragmentOverflow(_loc6_,currentFAI.fragId))
            {
               if(!_loc6_.live || _loc6_.contentComplete())
               {
                  if(_loc6_.live)
                  {
                     return new HTTPStreamRequest(null,param1,-1,-1,true);
                  }
                  return null;
               }
               adjustDelay();
               currentFAI = _loc2_;
               refreshBootstrapInfo(param1);
               return new HTTPStreamRequest(null,param1,0,delay);
            }
            playInProgress = true;
            _loc7_ = _loc5_.fragmentDurationPairs[0];
            _loc3_ = _loc6_.findSegmentId(currentFAI.fragId - _loc7_.firstFragment + 1);
            _loc8_ = "";
            if((streamInfos[param1].streamName as String).indexOf("http") != 0)
            {
               _loc8_ = serverBaseURL + "/" + streamInfos[param1].streamName + "Seg" + _loc3_ + "-Frag" + currentFAI.fragId;
            }
            else
            {
               _loc8_ = streamInfos[param1].streamName + "Seg" + _loc3_ + "-Frag" + currentFAI.fragId;
            }
            _loc4_ = new HTTPStreamRequest(_loc8_);
            checkQuality(param1);
            notifyFragmentDuration(currentFAI.fragDuration / _loc6_.timeScale);
         }
         return _loc4_;
      }
      
      internal function calculateSegmentDuration(param1:AdobeBootstrapBox, param2:Number) : Number
      {
         var _loc3_:FragmentDurationPair = null;
         var _loc4_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc6_:Vector.<FragmentDurationPair> = param1.fragmentRunTables[0].fragmentDurationPairs;
         var _loc7_:uint = currentFAI.fragId;
         var _loc5_:int = _loc6_.length - 1;
         while(_loc5_ >= 0)
         {
            _loc3_ = _loc6_[_loc5_];
            if(_loc3_.firstFragment <= _loc7_)
            {
               _loc4_ = _loc3_.duration;
               _loc8_ = _loc3_.durationAccrued;
               _loc8_ = _loc8_ + (_loc7_ - _loc3_.firstFragment) * _loc3_.duration;
               if(param2 > 0)
               {
                  _loc4_ -= param2 - _loc8_;
               }
               return _loc4_;
            }
            _loc5_--;
         }
         return 0;
      }
      
      private function checkQuality(param1:int) : void
      {
         var _loc4_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc2_:FLVTagScriptDataObject = null;
         if(currentQuality != param1)
         {
            _loc4_ = currentQuality < 0 ? null : streamInfos[currentQuality].additionalHeader;
            currentQuality = param1;
            _loc3_ = streamInfos[currentQuality].additionalHeader;
            if(_loc3_ != _loc4_ && _loc3_ != null)
            {
               _loc2_ = new FLVTagScriptDataObject();
               _loc2_.data = _loc3_;
               dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyScriptData",false,false,false,NaN,null,null,null,null,true,0,_loc2_,true,false));
            }
         }
      }
      
      private function checkMetadata(param1:int, param2:AdobeBootstrapBox) : void
      {
         if(currentQuality != param1)
         {
            notifyTotalDuration(param2.totalDuration / param2.timeScale,param1);
         }
      }
      
      private function refreshBootstrapInfo(param1:uint) : void
      {
         pendingIndexUpdates = pendingIndexUpdates + 1;
         fragmentRunTablesUpdating = true;
         dispatchEvent(new HTTPStreamingIndexHandlerEvent("requestLoadIndex",false,false,false,NaN,null,null,new URLRequest(HTTPStreamingUtils.normalizeURL((streamInfos[param1] as HTTPStreamingF4FStreamInfo).bootstrapInfo.url)),param1,true));
      }
      
      private function processBootstrapData(param1:*, param2:Object) : AdobeBootstrapBox
      {
         var _loc4_:* = undefined;
         var _loc3_:AdobeBootstrapBox = null;
         var _loc5_:BoxParser = new BoxParser();
         param1.position = 0;
         _loc5_.init(param1);
         try
         {
            _loc4_ = _loc5_.getBoxes();
         }
         catch(e:Error)
         {
            _loc4_ = null;
         }
         if(_loc4_ == null || _loc4_.length < 1)
         {
            return null;
         }
         _loc3_ = _loc4_[0] as AdobeBootstrapBox;
         if(_loc3_ == null)
         {
            return null;
         }
         if(serverBaseURL == null || serverBaseURL.length <= 0)
         {
            if(_loc3_.serverBaseURLs == null || _loc3_.serverBaseURLs.length <= 0)
            {
               return null;
            }
         }
         return _loc3_;
      }
      
      private function getQualityRates(param1:Vector.<HTTPStreamingF4FStreamInfo>) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:HTTPStreamingF4FStreamInfo = null;
         var _loc3_:Array = [];
         if(param1.length >= 1)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc2_ = param1[_loc4_] as HTTPStreamingF4FStreamInfo;
               _loc3_.push(_loc2_.bitrate);
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      private function getStreamNames(param1:Vector.<HTTPStreamingF4FStreamInfo>) : Array
      {
         var _loc4_:int = 0;
         var _loc2_:HTTPStreamingF4FStreamInfo = null;
         var _loc3_:Array = [];
         if(param1.length >= 1)
         {
            _loc4_ = 0;
            while(_loc4_ < param1.length)
            {
               _loc2_ = param1[_loc4_] as HTTPStreamingF4FStreamInfo;
               _loc3_.push(_loc2_.streamName);
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      private function getFragmentRunTable(param1:AdobeBootstrapBox) : AdobeFragmentRunTable
      {
         return param1.fragmentRunTables[0];
      }
      
      private function notifyTotalDuration(param1:Number, param2:int) : void
      {
         var _loc4_:FLVTagScriptDataObject = new FLVTagScriptDataObject();
         var _loc3_:Object = this.f4fIndexInfo.streamInfos[param2].streamMetadata;
         if(_loc3_ == null)
         {
            _loc3_ = {};
         }
         _loc3_.duration = param1;
         _loc4_.objects = ["onMetaData",_loc3_];
         dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyScriptData",false,false,false,NaN,null,null,null,null,false,0,_loc4_,false,true));
      }
      
      private function notifyFragmentDuration(param1:Number) : void
      {
         dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifySegmentDuration",false,false,false,NaN,null,null,null,null,true,param1));
      }
      
      private function notifyIndexReady(param1:int) : void
      {
         var _loc3_:AdobeBootstrapBox = bootstrapBoxes[param1];
         var _loc2_:AdobeFragmentRunTable = getFragmentRunTable(_loc3_);
         dispatchDVRStreamInfo(_loc3_);
         if(!dvrGetStreamInfoCall)
         {
            if(_loc3_.live && f4fIndexInfo.dvrInfo == null && isNaN(pureLiveOffset))
            {
               pureLiveOffset = _loc3_.currentMediaTime - offsetFromCurrent * _loc3_.timeScale > 0 ? _loc3_.currentMediaTime / _loc3_.timeScale - offsetFromCurrent : NaN;
            }
            dispatchEvent(new HTTPStreamingIndexHandlerEvent("notifyIndexReady",false,false,_loc3_.live,pureLiveOffset));
         }
         dvrGetStreamInfoCall = false;
      }
      
      private function stopPlaying(param1:AdobeBootstrapBox) : Boolean
      {
         var _loc2_:AdobeFragmentRunTable = getFragmentRunTable(param1);
         if(f4fIndexInfo.dvrInfo == null && param1.live && _loc2_.tableComplete() || f4fIndexInfo.dvrInfo != null && f4fIndexInfo.dvrInfo.offline)
         {
            return true;
         }
         return false;
      }
      
      private function onNewBootstrapBox(param1:HTTPStreamingFileHandlerEvent) : void
      {
         var _loc2_:AdobeBootstrapBox = bootstrapBoxes[currentQuality];
         if(_loc2_.bootstrapVersion < param1.bootstrapBox.bootstrapVersion || _loc2_.currentMediaTime < param1.bootstrapBox.currentMediaTime)
         {
            bootstrapBoxes[currentQuality] = param1.bootstrapBox;
            dispatchDVRStreamInfo(param1.bootstrapBox);
         }
      }
      
      private function dispatchDVRStreamInfo(param1:AdobeBootstrapBox) : void
      {
         var _loc2_:AdobeFragmentRunTable = getFragmentRunTable(param1);
         if(f4fIndexInfo.dvrInfo != null)
         {
            f4fIndexInfo.dvrInfo.isRecording = !_loc2_.tableComplete();
            if(isNaN(f4fIndexInfo.dvrInfo.startTime))
            {
               f4fIndexInfo.dvrInfo.startTime = _loc2_.tableComplete() ? 0 : DVRUtils.calculateOffset(f4fIndexInfo.dvrInfo.beginOffset < 0 || isNaN(f4fIndexInfo.dvrInfo.beginOffset) ? 0 : f4fIndexInfo.dvrInfo.beginOffset,f4fIndexInfo.dvrInfo.endOffset < 0 || isNaN(f4fIndexInfo.dvrInfo.endOffset) ? 0 : f4fIndexInfo.dvrInfo.endOffset,param1.totalDuration / param1.timeScale);
               f4fIndexInfo.dvrInfo.startTime += _loc2_.fragmentDurationPairs[0].durationAccrued / param1.timeScale;
               if(f4fIndexInfo.dvrInfo.startTime > param1.currentMediaTime)
               {
                  f4fIndexInfo.dvrInfo.startTime = param1.currentMediaTime;
               }
            }
            f4fIndexInfo.dvrInfo.curLength = param1.currentMediaTime / param1.timeScale - f4fIndexInfo.dvrInfo.startTime;
            dispatchEvent(new DVRStreamInfoEvent("DVRStreamInfo",false,false,f4fIndexInfo.dvrInfo));
         }
      }
      
      private function fragmentOverflow(param1:AdobeBootstrapBox, param2:uint) : Boolean
      {
         var _loc4_:AdobeFragmentRunTable = param1.fragmentRunTables[0];
         var _loc5_:FragmentDurationPair = _loc4_.fragmentDurationPairs[0];
         var _loc3_:AdobeSegmentRunTable = param1.segmentRunTables[0];
         return _loc3_ == null || _loc3_.totalFragments + _loc5_.firstFragment - 1 < param2;
      }
      
      private function adjustDelay() : void
      {
         if(delay < 1)
         {
            delay *= 2;
            if(delay > 1)
            {
               delay = 1;
            }
         }
      }
   }
}

