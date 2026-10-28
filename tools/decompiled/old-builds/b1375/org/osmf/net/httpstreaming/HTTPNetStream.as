package org.osmf.net.httpstreaming
{
   import flash.events.Event;
   import flash.events.NetStatusEvent;
   import flash.events.ProgressEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamPlayOptions;
   import flash.net.URLLoader;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.Timer;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.events.HTTPStreamingFileHandlerEvent;
   import org.osmf.events.HTTPStreamingIndexHandlerEvent;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.flv.FLVHeader;
   import org.osmf.net.httpstreaming.flv.FLVParser;
   import org.osmf.net.httpstreaming.flv.FLVTag;
   import org.osmf.net.httpstreaming.flv.FLVTagAudio;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   import org.osmf.net.httpstreaming.flv.FLVTagVideo;
   
   public class HTTPNetStream extends NetStream
   {
      
      private static const MAIN_TIMER_INTERVAL:int = 25;
      
      private var _indexInfo:HTTPStreamingIndexInfoBase = null;
      
      private var _numQualityLevels:int = 0;
      
      private var _qualityRates:Array;
      
      private var _streamNames:Array;
      
      private var _segmentDuration:Number = -1;
      
      private var _urlStreamVideo:URLStream = null;
      
      private var _loadComplete:Boolean = false;
      
      private var mainTimer:Timer;
      
      private var _dataAvailable:Boolean = false;
      
      private var _qualityLevel:int = 0;
      
      private var qualityLevelHasChanged:Boolean = false;
      
      private var _seekTarget:Number = -1;
      
      private var _lastDownloadStartTime:Number = -1;
      
      private var _lastDownloadDuration:Number;
      
      private var _lastDownloadRatio:Number = 0;
      
      private var _manualSwitchMode:Boolean = false;
      
      private var _aggressiveUpswitch:Boolean = true;
      
      private var indexHandler:HTTPStreamingIndexHandlerBase;
      
      private var fileHandler:HTTPStreamingFileHandlerBase;
      
      private var _totalDuration:Number = -1;
      
      private var _enhancedSeekTarget:Number = -1;
      
      private var _enhancedSeekEnabled:Boolean = false;
      
      private var _enhancedSeekTags:Vector.<FLVTagVideo>;
      
      private var _flvParserIsSegmentStart:Boolean = false;
      
      private var _savedBytes:ByteArray = null;
      
      private var _state:String = "init";
      
      private var _prevState:String = null;
      
      private var _seekAfterInit:Boolean;
      
      private var indexIsReady:Boolean = false;
      
      private var _insertScriptDataTags:Vector.<FLVTagScriptDataObject> = null;
      
      private var _flvParser:FLVParser = null;
      
      private var _flvParserDone:Boolean = true;
      
      private var _flvParserProcessed:uint;
      
      private var _initialTime:Number = -1;
      
      private var _seekTime:Number = -1;
      
      private var _fileTimeAdjustment:Number = 0;
      
      private var _playForDuration:Number = -1;
      
      private var _lastValidTimeTime:Number = 0;
      
      private var _retryAfterWaitUntil:Number = 0;
      
      private var _dvrInfo:DVRInfo = null;
      
      private var _unpublishNotifyPending:Boolean = false;
      
      private var _signalPlayStartPending:Boolean = false;
      
      public function HTTPNetStream(param1:NetConnection, param2:HTTPStreamingIndexHandlerBase, param3:HTTPStreamingFileHandlerBase)
      {
         super(param1);
         _savedBytes = new ByteArray();
         this.indexHandler = param2;
         this.fileHandler = param3;
         param2.addEventListener("notifyIndexReady",onIndexReady);
         param2.addEventListener("notifyRates",onRates);
         param2.addEventListener("requestLoadIndex",onRequestLoadIndexFile);
         param2.addEventListener("notifyError",onIndexError);
         param2.addEventListener("notifySegmentDuration",onSegmentDurationFromIndexHandler);
         param2.addEventListener("notifyScriptData",onScriptDataFromIndexHandler);
         param2.addEventListener("DVRStreamInfo",onDVRStreamInfo);
         param3.addEventListener("notifySegmentDuration",onSegmentDurationFromFileHandler);
         param3.addEventListener("notifyScriptData",onScriptDataFromFileHandler);
         param3.addEventListener("notifyError",onErrorFromFileHandler);
         mainTimer = new Timer(25);
         mainTimer.addEventListener("timer",onMainTimer);
         mainTimer.start();
         this.addEventListener("netStatus",onNetStatus);
      }
      
      public function set enhancedSeek(param1:Boolean) : void
      {
         _enhancedSeekEnabled = param1;
      }
      
      public function get enhancedSeek() : Boolean
      {
         return _enhancedSeekEnabled;
      }
      
      public function get downloadRatio() : Number
      {
         return _lastDownloadRatio;
      }
      
      public function set qualityLevel(param1:int) : void
      {
         if(_manualSwitchMode)
         {
            setQualityLevel(param1);
            return;
         }
         throw new Error("qualityLevel cannot be set to this value at this time");
      }
      
      public function get qualityLevel() : int
      {
         return _qualityLevel;
      }
      
      public function get manualSwitchMode() : Boolean
      {
         return _manualSwitchMode;
      }
      
      public function set manualSwitchMode(param1:Boolean) : void
      {
         _manualSwitchMode = param1;
      }
      
      public function get indexInfo() : HTTPStreamingIndexInfoBase
      {
         return _indexInfo;
      }
      
      public function set indexInfo(param1:HTTPStreamingIndexInfoBase) : void
      {
         _indexInfo = param1;
      }
      
      public function DVRGetStreamInfo(param1:Object) : void
      {
         if(!indexIsReady)
         {
            indexHandler.dvrGetStreamInfo(_indexInfo != null ? _indexInfo : param1);
         }
      }
      
      override public function play(... rest) : void
      {
         if(rest.length < 1)
         {
            throw new Error("HTTPStream.play() requires at least one argument");
         }
         super.play(null);
         _signalPlayStartPending = true;
         var _loc3_:FLVHeader = new FLVHeader();
         var _loc2_:ByteArray = new ByteArray();
         _loc3_.write(_loc2_);
         attemptAppendBytes(_loc2_);
         setState("init");
         _initialTime = -1;
         _seekTime = -1;
         indexIsReady = false;
         indexHandler.initialize(_indexInfo != null ? _indexInfo : rest[0]);
         if(rest.length >= 2)
         {
            _seekTarget = Number(rest[1]);
            if(_seekTarget < 0)
            {
               if(_dvrInfo != null)
               {
                  _seekTarget = _dvrInfo.startTime;
               }
               else
               {
                  _seekTarget = 0;
               }
            }
         }
         else
         {
            _seekTarget = 0;
         }
         if(rest.length >= 3)
         {
            _playForDuration = Number(rest[2]);
         }
         else
         {
            _playForDuration = -1;
         }
         _unpublishNotifyPending = false;
      }
      
      private function signalPlayStart() : void
      {
         dispatchEvent(new NetStatusEvent("netStatus",false,false,{
            "code":"NetStream.Play.Start",
            "level":"status"
         }));
      }
      
      override public function play2(param1:NetStreamPlayOptions) : void
      {
         if(param1.transition == "reset")
         {
            setQualityLevelForStreamName(param1.streamName);
            play(param1.streamName,param1.start,param1.len);
         }
         else if(param1.transition == "switch")
         {
            setQualityLevelForStreamName(param1.streamName);
         }
         else
         {
            super.play2(param1);
         }
      }
      
      override public function seek(param1:Number) : void
      {
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(_state != "init")
         {
            if(_initialTime < 0)
            {
               _seekTarget = param1 + 0;
            }
            else
            {
               _seekTarget = param1 + _initialTime;
            }
            _seekTime = -1;
            setState("seek");
            super.seek(param1);
         }
         _unpublishNotifyPending = false;
      }
      
      override public function close() : void
      {
         indexIsReady = false;
         switch(_state)
         {
            case "play":
            case "playStartNext":
            case "playStartSeek":
               _urlStreamVideo.close();
         }
         setState("halt");
         mainTimer.stop();
         dispatchEvent(new NetStatusEvent("netStatus",false,false,{
            "code":"NetStream.Play.Stop",
            "level":"status"
         }));
         super.close();
      }
      
      override public function get time() : Number
      {
         if(_seekTime >= 0 && _initialTime >= 0)
         {
            _lastValidTimeTime = super.time + _seekTime - _initialTime;
         }
         return _lastValidTimeTime;
      }
      
      private function setState(param1:String) : void
      {
         _prevState = _state;
         _state = param1;
      }
      
      private function insertScriptDataTag(param1:FLVTagScriptDataObject, param2:Boolean = false) : void
      {
         if(!_insertScriptDataTags)
         {
            _insertScriptDataTags = new Vector.<FLVTagScriptDataObject>();
         }
         if(param2)
         {
            _insertScriptDataTags.unshift(param1);
         }
         else
         {
            _insertScriptDataTags.push(param1);
         }
      }
      
      private function flvTagHandler(param1:FLVTag) : Boolean
      {
         var _loc11_:int = 0;
         var _loc4_:FLVTagScriptDataObject = null;
         var _loc3_:ByteArray = null;
         var _loc2_:Number = NaN;
         var _loc6_:FLVTagVideo = null;
         var _loc9_:FLVTagVideo = null;
         var _loc8_:FLVTagVideo = null;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:FLVTagAudio = null;
         if(_insertScriptDataTags)
         {
            _loc11_ = 0;
            while(_loc11_ < _insertScriptDataTags.length)
            {
               _loc4_ = _insertScriptDataTags[_loc11_];
               _loc4_.timestamp = param1.timestamp;
               _loc3_ = new ByteArray();
               _loc4_.write(_loc3_);
               _flvParserProcessed += _loc3_.length;
               attemptAppendBytes(_loc3_);
               _loc11_++;
            }
            _insertScriptDataTags = null;
         }
         if(_playForDuration >= 0)
         {
            if(_initialTime >= 0)
            {
               _loc2_ = param1.timestamp / 1000 + _fileTimeAdjustment;
               if(_loc2_ > _initialTime + _playForDuration)
               {
                  setState("stop");
                  _flvParserDone = true;
                  if(_seekTime < 0)
                  {
                     _seekTime = _playForDuration + _initialTime;
                  }
                  return false;
               }
            }
         }
         if(_enhancedSeekTarget < 0)
         {
            if(_initialTime < 0)
            {
               if(_dvrInfo != null)
               {
                  _initialTime = _dvrInfo.startTime;
               }
               else
               {
                  _initialTime = param1.timestamp / 1000 + _fileTimeAdjustment;
               }
            }
            if(_seekTime < 0)
            {
               _seekTime = param1.timestamp / 1000 + _fileTimeAdjustment;
            }
            _loc3_ = new ByteArray();
            param1.write(_loc3_);
            _flvParserProcessed += _loc3_.length;
            attemptAppendBytes(_loc3_);
            if(_playForDuration >= 0)
            {
               if(_segmentDuration >= 0 && _flvParserIsSegmentStart)
               {
                  _flvParserIsSegmentStart = false;
                  _loc2_ = param1.timestamp / 1000 + _fileTimeAdjustment;
                  if(_loc2_ + _segmentDuration >= _initialTime + _playForDuration)
                  {
                     return true;
                  }
                  _flvParserDone = true;
                  return false;
               }
               return true;
            }
            _flvParserDone = true;
            return false;
         }
         if(param1 is FLVTagVideo)
         {
            if(_flvParserIsSegmentStart)
            {
               _loc6_ = new FLVTagVideo();
               _loc6_.timestamp = param1.timestamp;
               _loc6_.codecID = FLVTagVideo(param1).codecID;
               _loc6_.frameType = 5;
               _loc6_.infoPacketValue = 0;
               _enhancedSeekTags = new Vector.<FLVTagVideo>();
               _enhancedSeekTags.push(_loc6_);
               _flvParserIsSegmentStart = false;
            }
            if(param1.timestamp / 1000 + _fileTimeAdjustment >= _enhancedSeekTarget)
            {
               _enhancedSeekTarget = -1;
               _seekTime = param1.timestamp / 1000 + _fileTimeAdjustment;
               if(_initialTime < 0)
               {
                  _initialTime = _seekTime;
               }
               _loc9_ = new FLVTagVideo();
               _loc9_.timestamp = param1.timestamp;
               _loc9_.codecID = _enhancedSeekTags[0].codecID;
               _loc9_.frameType = 5;
               _loc9_.infoPacketValue = 1;
               _enhancedSeekTags.push(_loc9_);
               _loc11_ = 0;
               while(_loc11_ < _enhancedSeekTags.length)
               {
                  _loc8_ = _enhancedSeekTags[_loc11_];
                  if(_loc8_.codecID == 7 && _loc8_.avcPacketType == 1)
                  {
                     _loc5_ = param1.timestamp - _loc8_.timestamp;
                     _loc7_ = _loc8_.avcCompositionTimeOffset;
                     _loc7_ = _loc8_.avcCompositionTimeOffset;
                     _loc7_ = _loc7_ - _loc5_;
                     _loc8_.avcCompositionTimeOffset = _loc7_;
                     _loc8_.timestamp = param1.timestamp;
                  }
                  else
                  {
                     _loc8_.timestamp = param1.timestamp;
                  }
                  _loc3_ = new ByteArray();
                  _loc8_.write(_loc3_);
                  _flvParserProcessed += _loc3_.length;
                  attemptAppendBytes(_loc3_);
                  _loc11_++;
               }
               _enhancedSeekTags = null;
               _loc3_ = new ByteArray();
               param1.write(_loc3_);
               _flvParserProcessed += _loc3_.length;
               attemptAppendBytes(_loc3_);
               if(_playForDuration >= 0)
               {
                  return true;
               }
               _flvParserDone = true;
               return false;
            }
            _enhancedSeekTags.push(param1);
         }
         else if(param1 is FLVTagScriptDataObject)
         {
            _loc3_ = new ByteArray();
            param1.write(_loc3_);
            _flvParserProcessed += _loc3_.length;
            attemptAppendBytes(_loc3_);
         }
         else if(param1 is FLVTagAudio)
         {
            _loc10_ = param1 as FLVTagAudio;
            if(_loc10_.isCodecConfiguration)
            {
               _loc3_ = new ByteArray();
               param1.write(_loc3_);
               _flvParserProcessed += _loc3_.length;
               attemptAppendBytes(_loc3_);
            }
         }
         return true;
      }
      
      private function autoAdjustQuality(param1:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         if(!_manualSwitchMode)
         {
            if(param1)
            {
               setQualityLevel(0);
               return;
            }
            if(_lastDownloadRatio < 1)
            {
               if(qualityLevel > 0)
               {
                  _loc2_ = qualityLevel - 1;
                  _loc3_ = _qualityRates[_loc2_] / _qualityRates[qualityLevel];
                  if(_lastDownloadRatio < _loc3_)
                  {
                     setQualityLevel(0);
                  }
                  else
                  {
                     setQualityLevel(_loc2_);
                  }
               }
            }
            else if(qualityLevel < _numQualityLevels - 1)
            {
               _loc2_ = qualityLevel + 1;
               _loc3_ = _qualityRates[_loc2_] / _qualityRates[qualityLevel];
               if(_lastDownloadRatio >= _loc3_)
               {
                  if(!(_lastDownloadRatio > 100 || !_aggressiveUpswitch))
                  {
                     while(++_loc2_ < _numQualityLevels)
                     {
                        _loc3_ = _qualityRates[_loc2_] / _qualityRates[qualityLevel];
                        if(_lastDownloadRatio < _loc3_)
                        {
                           break;
                        }
                     }
                     _loc2_--;
                  }
                  setQualityLevel(_loc2_);
               }
            }
         }
      }
      
      private function byteSource(param1:IDataInput, param2:Number) : IDataInput
      {
         var _loc3_:int = 0;
         if(param2 < 0)
         {
            return null;
         }
         if(param2)
         {
            if(_savedBytes.bytesAvailable + param1.bytesAvailable < param2)
            {
               return null;
            }
         }
         else if(_savedBytes.bytesAvailable + param1.bytesAvailable < 1)
         {
            return null;
         }
         if(_savedBytes.bytesAvailable)
         {
            _loc3_ = param2 - _savedBytes.bytesAvailable;
            if(_loc3_ > 0)
            {
               param1.readBytes(_savedBytes,_savedBytes.length,_loc3_);
            }
            return _savedBytes;
         }
         _savedBytes.length = 0;
         return param1;
      }
      
      private function processAndAppend(param1:ByteArray) : uint
      {
         var _loc3_:ByteArray = null;
         var _loc2_:uint = 0;
         if(!param1)
         {
            return 0;
         }
         if(_flvParser)
         {
            param1.position = 0;
            _flvParserProcessed = 0;
            _flvParser.parse(param1,true,flvTagHandler);
            _loc2_ += _flvParserProcessed;
            if(!_flvParserDone)
            {
               return _loc2_;
            }
            _loc3_ = new ByteArray();
            _flvParser.flush(_loc3_);
            _flvParser = null;
         }
         else
         {
            _loc3_ = param1;
         }
         _loc2_ += _loc3_.length;
         if(_state != "stop")
         {
            attemptAppendBytes(_loc3_);
         }
         return _loc2_;
      }
      
      private function onMainTimer(param1:TimerEvent) : void
      {
         var _loc4_:ByteArray = null;
         var _loc13_:Object = null;
         var _loc12_:FLVTagScriptDataObject = null;
         var _loc9_:HTTPStreamRequest = null;
         var _loc10_:Date = null;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:IDataInput = null;
         var _loc11_:Object = null;
         var _loc8_:FLVTagScriptDataObject = null;
         var _loc7_:ByteArray = null;
         switch(_state)
         {
            case "init":
               _seekAfterInit = true;
               break;
            case "seek":
               switch(_prevState)
               {
                  case "play":
                  case "playStartNext":
                  case "playStartSeek":
                     _urlStreamVideo.close();
               }
               _dataAvailable = false;
               _savedBytes.length = 0;
               if(_enhancedSeekEnabled)
               {
                  _enhancedSeekTarget = _seekTarget;
               }
               setState("loadSeek");
               break;
            case "loadWait":
               if(this._lastDownloadRatio < 2)
               {
                  if(this.bufferLength < Math.max(7.5,this.bufferTime))
                  {
                     setState("loadNext");
                  }
               }
               else if(this.bufferLength < Math.max(3.75,this.bufferTime))
               {
                  setState("loadNext");
               }
               break;
            case "loadNext":
               autoAdjustQuality(false);
               if(qualityLevelHasChanged)
               {
                  _loc4_ = fileHandler.flushFileSegment(_savedBytes.bytesAvailable ? _savedBytes : null);
                  processAndAppend(_loc4_);
                  _loc13_ = {};
                  _loc13_.code = "NetStream.Play.TransitionComplete";
                  _loc13_.level = "status";
                  _loc12_ = new FLVTagScriptDataObject();
                  _loc12_.objects = ["onPlayStatus",_loc13_];
                  insertScriptDataTag(_loc12_);
                  qualityLevelHasChanged = false;
               }
               setState("load");
               break;
            case "loadSeek":
               if(!_seekAfterInit)
               {
                  _loc4_ = fileHandler.flushFileSegment(_savedBytes.bytesAvailable ? _savedBytes : null);
               }
               appendBytesAction("resetSeek");
               if(!_seekAfterInit)
               {
                  autoAdjustQuality(true);
               }
               _seekAfterInit = false;
               setState("load");
               break;
            case "load":
               if(_signalPlayStartPending)
               {
                  signalPlayStart();
                  _signalPlayStartPending = false;
               }
               _segmentDuration = -1;
               switch(_prevState)
               {
                  case "loadSeek":
                  case "loadSeekRetryWait":
                     _loc9_ = indexHandler.getFileForTime(_seekTarget,qualityLevel);
                     break;
                  case "loadNext":
                  case "loadNextRetryWait":
                     _loc9_ = indexHandler.getNextFile(qualityLevel);
                     break;
                  default:
                     throw new Error("in HTTPStreamState.LOAD with unknown _prevState " + _prevState);
               }
               if(_loc9_ != null && _loc9_.urlRequest != null)
               {
                  _loadComplete = false;
                  _urlStreamVideo.load(_loc9_.urlRequest);
                  _loc10_ = new Date();
                  _lastDownloadStartTime = _loc10_.getTime();
                  switch(_prevState)
                  {
                     case "loadSeek":
                     case "loadSeekRetryWait":
                        setState("playStartSeek");
                        break;
                     case "loadNext":
                     case "loadNextRetryWait":
                        setState("playStartNext");
                        break;
                     default:
                        throw new Error("in HTTPStreamState.LOAD(2) with unknown _prevState " + _prevState);
                  }
               }
               else if(_loc9_ != null && _loc9_.retryAfter >= 0)
               {
                  _loc10_ = new Date();
                  _retryAfterWaitUntil = _loc10_.getTime() + 1000 * _loc9_.retryAfter;
                  switch(_prevState)
                  {
                     case "loadSeek":
                     case "loadSeekRetryWait":
                        setState("loadSeekRetryWait");
                        break;
                     case "loadNext":
                     case "loadNextRetryWait":
                        setState("loadNextRetryWait");
                        break;
                     default:
                        throw new Error("in HTTPStreamState.LOAD(3) with unknown _prevState " + _prevState);
                  }
               }
               else
               {
                  _loc4_ = fileHandler.flushFileSegment(_savedBytes.bytesAvailable ? _savedBytes : null);
                  processAndAppend(_loc4_);
                  setState("stop");
                  if(_loc9_ != null && _loc9_.unpublishNotify)
                  {
                     _unpublishNotifyPending = true;
                  }
               }
               break;
            case "loadSeekRetryWait":
            case "loadNextRetryWait":
               _loc10_ = new Date();
               if(_loc10_.getTime() > _retryAfterWaitUntil)
               {
                  setState("load");
               }
               break;
            case "playStartNext":
               fileHandler.beginProcessFile(false,0);
               setState("playStartCommon");
               break;
            case "playStartSeek":
               fileHandler.beginProcessFile(true,_seekTarget);
               setState("playStartCommon");
               break;
            case "playStartCommon":
               if(_initialTime < 0 || _seekTime < 0 || _insertScriptDataTags || _enhancedSeekTarget >= 0 || _playForDuration >= 0)
               {
                  if(_enhancedSeekTarget >= 0 || _playForDuration >= 0)
                  {
                     _flvParserIsSegmentStart = true;
                  }
                  _flvParser = new FLVParser(false);
                  _flvParserDone = false;
               }
               setState("play");
               break;
            case "play":
               _loc5_ = false;
               if(_dataAvailable)
               {
                  _loc6_ = 260000;
                  _loc3_ = 0;
                  if(_enhancedSeekTarget >= 0)
                  {
                     _loc6_ = 0;
                  }
                  _loc2_ = null;
                  _dataAvailable = false;
                  while(_state == "play" && _loc2_ == byteSource(_urlStreamVideo,fileHandler.inputBytesNeeded))
                  {
                     _loc4_ = fileHandler.processFileSegment(_loc2_);
                     _loc3_ += processAndAppend(_loc4_);
                     if(_loc6_ > 0 && _loc3_ >= _loc6_)
                     {
                        _dataAvailable = true;
                        break;
                     }
                  }
                  if(_state != "play")
                  {
                     break;
                  }
                  if(_loadComplete && !_loc2_)
                  {
                     _loc5_ = true;
                  }
               }
               else if(_loadComplete)
               {
                  _loc5_ = true;
               }
               if(_loc5_)
               {
                  if(_urlStreamVideo.bytesAvailable)
                  {
                     _urlStreamVideo.readBytes(_savedBytes);
                  }
                  else
                  {
                     _savedBytes.length = 0;
                  }
                  setState("endSegment");
               }
               break;
            case "endSegment":
               _loc4_ = fileHandler.endProcessFile(_savedBytes.bytesAvailable ? _savedBytes : null);
               processAndAppend(_loc4_);
               _lastDownloadRatio = _segmentDuration / _lastDownloadDuration;
               if(_state != "stop" && _state != "halt")
               {
                  setState("loadWait");
               }
               break;
            case "stop":
               _loc11_ = {};
               _loc11_.code = "NetStream.Play.Complete";
               _loc11_.level = "status";
               _loc8_ = new FLVTagScriptDataObject();
               _loc8_.objects = ["onPlayStatus",_loc11_];
               _loc7_ = new ByteArray();
               _loc8_.write(_loc7_);
               appendBytesAction("endSequence");
               appendBytesAction("resetSeek");
               attemptAppendBytes(_loc7_);
               setState("halt");
               break;
            case "halt":
               break;
            default:
               throw new Error("HTTPStream cannot run undefined _state " + _state);
         }
      }
      
      private function onURLStatus(param1:ProgressEvent) : void
      {
         _dataAvailable = true;
      }
      
      private function onURLComplete(param1:Event) : void
      {
         var _loc2_:Date = new Date();
         _lastDownloadDuration = (_loc2_.getTime() - _lastDownloadStartTime) / 1000;
         _loadComplete = true;
      }
      
      private function onRequestLoadIndexFile(param1:HTTPStreamingIndexHandlerEvent) : void
      {
         var event:HTTPStreamingIndexHandlerEvent = param1;
         var onIndexLoadComplete:* = function(param1:Event):void
         {
            urlLoader.removeEventListener("complete",onIndexLoadComplete);
            urlLoader.removeEventListener("ioError",onIndexURLError);
            urlLoader.removeEventListener("securityError",onIndexURLError);
            indexHandler.processIndexData(urlLoader.data,requestContext);
         };
         var onIndexURLError:* = function(param1:Event):void
         {
            urlLoader.removeEventListener("complete",onIndexLoadComplete);
            urlLoader.removeEventListener("ioError",onIndexURLError);
            urlLoader.removeEventListener("securityError",onIndexURLError);
            handleURLError();
         };
         var urlLoader:URLLoader = new URLLoader(event.request);
         var requestContext:Object = event.requestContext;
         if(event.binaryData)
         {
            urlLoader.dataFormat = "binary";
         }
         else
         {
            urlLoader.dataFormat = "text";
         }
         urlLoader.addEventListener("complete",onIndexLoadComplete);
         urlLoader.addEventListener("ioError",onIndexURLError);
         urlLoader.addEventListener("securityError",onIndexURLError);
      }
      
      private function onSegmentDurationFromFileHandler(param1:HTTPStreamingFileHandlerEvent) : void
      {
         _segmentDuration = param1.segmentDuration;
      }
      
      private function onSegmentDurationFromIndexHandler(param1:HTTPStreamingIndexHandlerEvent) : void
      {
         _segmentDuration = param1.segmentDuration;
      }
      
      private function onRates(param1:HTTPStreamingIndexHandlerEvent) : void
      {
         _qualityRates = param1.rates;
         _streamNames = param1.streamNames;
         _numQualityLevels = _qualityRates.length;
      }
      
      private function onIndexReady(param1:HTTPStreamingIndexHandlerEvent) : void
      {
         if(!indexIsReady)
         {
            if(param1.live && _dvrInfo == null && !isNaN(param1.offset))
            {
               _seekTarget = param1.offset;
            }
            _urlStreamVideo = new URLStream();
            _urlStreamVideo.addEventListener("progress",onURLStatus,false,0,true);
            _urlStreamVideo.addEventListener("complete",onURLComplete,false,0,true);
            _urlStreamVideo.addEventListener("ioError",onVideoURLError,false,0,true);
            _urlStreamVideo.addEventListener("securityError",onVideoURLError,false,0,true);
            setState("seek");
            indexIsReady = true;
         }
      }
      
      private function onVideoURLError(param1:Event) : void
      {
         handleURLError();
      }
      
      private function handleURLError() : void
      {
         dispatchEvent(new NetStatusEvent("netStatus",false,false,{
            "code":"NetStream.Play.StreamNotFound",
            "level":"error"
         }));
      }
      
      private function onScriptDataFromIndexHandler(param1:HTTPStreamingIndexHandlerEvent) : void
      {
         onScriptData(param1.scriptDataObject,param1.scriptDataFirst,param1.scriptDataImmediate);
      }
      
      private function onScriptDataFromFileHandler(param1:HTTPStreamingFileHandlerEvent) : void
      {
         onScriptData(param1.scriptDataObject,param1.scriptDataFirst,param1.scriptDataImmediate);
      }
      
      private function onErrorFromFileHandler(param1:HTTPStreamingFileHandlerEvent) : void
      {
         setState("halt");
         dispatchEvent(new NetStatusEvent("netStatus",false,false,{
            "code":"NetStream.Play.FileStructureInvalid",
            "level":"error"
         }));
      }
      
      private function onScriptData(param1:FLVTagScriptDataObject, param2:Boolean, param3:Boolean) : void
      {
         if(param3)
         {
            if(client)
            {
               if(client.hasOwnProperty(param1.objects[0]))
               {
                  client[param1.objects[0]](param1.objects[1]);
               }
            }
         }
         else
         {
            insertScriptDataTag(param1,param2);
         }
      }
      
      private function onDVRStreamInfo(param1:DVRStreamInfoEvent) : void
      {
         _dvrInfo = param1.info as DVRInfo;
         dispatchEvent(param1.clone());
      }
      
      private function onIndexError(param1:HTTPStreamingIndexHandlerEvent) : void
      {
         dispatchEvent(new NetStatusEvent("netStatus",false,false,{
            "code":"NetStream.Play.StreamNotFound",
            "level":"error"
         }));
      }
      
      private function setQualityLevel(param1:int) : void
      {
         if(param1 >= 0 && param1 < _numQualityLevels)
         {
            if(param1 != _qualityLevel)
            {
               _qualityLevel = param1;
               qualityLevelHasChanged = true;
               dispatchEvent(new NetStatusEvent("netStatus",false,false,{
                  "code":"NetStream.Play.Transition",
                  "level":"status",
                  "details":_streamNames[param1]
               }));
            }
            return;
         }
         throw new Error("qualityLevel cannot be set to this value at this time");
      }
      
      private function setQualityLevelForStreamName(param1:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:* = -1;
         if(_streamNames != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _streamNames.length)
            {
               if(param1 == _streamNames[_loc3_])
               {
                  _loc2_ = _loc3_;
                  break;
               }
               _loc3_++;
            }
         }
         if(_loc2_ != -1)
         {
            setQualityLevel(_loc2_);
         }
      }
      
      private function attemptAppendBytes(param1:ByteArray) : void
      {
         appendBytes(param1);
      }
      
      private function onNetStatus(param1:NetStatusEvent) : void
      {
         if(param1.info.code == "NetStream.Buffer.Empty" && _state == "halt")
         {
            finishStopProcess();
         }
      }
      
      private function finishStopProcess() : void
      {
         if(_unpublishNotifyPending)
         {
            dispatchEvent(new NetStatusEvent("netStatus",false,false,{
               "code":"NetStream.Play.UnpublishNotify",
               "level":"status"
            }));
            _unpublishNotifyPending = false;
         }
      }
   }
}

