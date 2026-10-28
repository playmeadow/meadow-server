package org.osmf.net.httpstreaming
{
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.events.ProgressEvent;
   import flash.events.SecurityErrorEvent;
   import flash.events.TimerEvent;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.net.NetStreamAppendBytesAction;
   import flash.net.NetStreamPlayOptions;
   import flash.net.NetStreamPlayTransitions;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLStream;
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.Timer;
   import org.osmf.events.DVRStreamInfoEvent;
   import org.osmf.events.HTTPStreamingFileHandlerEvent;
   import org.osmf.events.HTTPStreamingIndexHandlerEvent;
   import org.osmf.net.NetStreamCodes;
   import org.osmf.net.httpstreaming.dvr.DVRInfo;
   import org.osmf.net.httpstreaming.flv.FLVHeader;
   import org.osmf.net.httpstreaming.flv.FLVParser;
   import org.osmf.net.httpstreaming.flv.FLVTag;
   import org.osmf.net.httpstreaming.flv.FLVTagAudio;
   import org.osmf.net.httpstreaming.flv.FLVTagScriptDataObject;
   import org.osmf.net.httpstreaming.flv.FLVTagVideo;
   
   [ExcludeClass]
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
      
      public function HTTPNetStream(connection:NetConnection, indexHandler:HTTPStreamingIndexHandlerBase, fileHandler:HTTPStreamingFileHandlerBase)
      {
         super(connection);
         this._savedBytes = new ByteArray();
         this.indexHandler = indexHandler;
         this.fileHandler = fileHandler;
         indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.NOTIFY_INDEX_READY,this.onIndexReady);
         indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.NOTIFY_RATES,this.onRates);
         indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.REQUEST_LOAD_INDEX,this.onRequestLoadIndexFile);
         indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.NOTIFY_ERROR,this.onIndexError);
         indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.NOTIFY_SEGMENT_DURATION,this.onSegmentDurationFromIndexHandler);
         indexHandler.addEventListener(HTTPStreamingIndexHandlerEvent.NOTIFY_SCRIPT_DATA,this.onScriptDataFromIndexHandler);
         indexHandler.addEventListener(DVRStreamInfoEvent.DVRSTREAMINFO,this.onDVRStreamInfo);
         fileHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_SEGMENT_DURATION,this.onSegmentDurationFromFileHandler);
         fileHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_SCRIPT_DATA,this.onScriptDataFromFileHandler);
         fileHandler.addEventListener(HTTPStreamingFileHandlerEvent.NOTIFY_ERROR,this.onErrorFromFileHandler);
         this.mainTimer = new Timer(MAIN_TIMER_INTERVAL);
         this.mainTimer.addEventListener(TimerEvent.TIMER,this.onMainTimer);
         this.mainTimer.start();
         this.addEventListener(NetStatusEvent.NET_STATUS,this.onNetStatus);
      }
      
      public function set enhancedSeek(value:Boolean) : void
      {
         this._enhancedSeekEnabled = value;
      }
      
      public function get enhancedSeek() : Boolean
      {
         return this._enhancedSeekEnabled;
      }
      
      public function get downloadRatio() : Number
      {
         return this._lastDownloadRatio;
      }
      
      public function set qualityLevel(value:int) : void
      {
         if(this._manualSwitchMode)
         {
            this.setQualityLevel(value);
            return;
         }
         throw new Error("qualityLevel cannot be set to this value at this time");
      }
      
      public function get qualityLevel() : int
      {
         return this._qualityLevel;
      }
      
      public function get manualSwitchMode() : Boolean
      {
         return this._manualSwitchMode;
      }
      
      public function set manualSwitchMode(value:Boolean) : void
      {
         this._manualSwitchMode = value;
      }
      
      public function get indexInfo() : HTTPStreamingIndexInfoBase
      {
         return this._indexInfo;
      }
      
      public function set indexInfo(value:HTTPStreamingIndexInfoBase) : void
      {
         this._indexInfo = value;
      }
      
      public function DVRGetStreamInfo(streamName:Object) : void
      {
         if(!this.indexIsReady)
         {
            this.indexHandler.dvrGetStreamInfo(this._indexInfo != null ? this._indexInfo : streamName);
         }
      }
      
      override public function play(... args) : void
      {
         if(args.length < 1)
         {
            throw new Error("HTTPStream.play() requires at least one argument");
         }
         super.play(null);
         this._signalPlayStartPending = true;
         var header:FLVHeader = new FLVHeader();
         var headerBytes:ByteArray = new ByteArray();
         header.write(headerBytes);
         this.attemptAppendBytes(headerBytes);
         this.setState(HTTPStreamingState.INIT);
         this._initialTime = -1;
         this._seekTime = -1;
         this.indexIsReady = false;
         this.indexHandler.initialize(this._indexInfo != null ? this._indexInfo : args[0]);
         if(args.length >= 2)
         {
            this._seekTarget = Number(args[1]);
            if(this._seekTarget < 0)
            {
               if(this._dvrInfo != null)
               {
                  this._seekTarget = this._dvrInfo.startTime;
               }
               else
               {
                  this._seekTarget = 0;
               }
            }
         }
         else
         {
            this._seekTarget = 0;
         }
         if(args.length >= 3)
         {
            this._playForDuration = Number(args[2]);
         }
         else
         {
            this._playForDuration = -1;
         }
         this._unpublishNotifyPending = false;
      }
      
      private function signalPlayStart() : void
      {
         dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
            "code":NetStreamCodes.NETSTREAM_PLAY_START,
            "level":"status"
         }));
      }
      
      override public function play2(param:NetStreamPlayOptions) : void
      {
         if(param.transition == NetStreamPlayTransitions.RESET)
         {
            this.setQualityLevelForStreamName(param.streamName);
            this.play(param.streamName,param.start,param.len);
         }
         else if(param.transition == NetStreamPlayTransitions.SWITCH)
         {
            this.setQualityLevelForStreamName(param.streamName);
         }
         else
         {
            super.play2(param);
         }
      }
      
      override public function seek(offset:Number) : void
      {
         if(offset < 0)
         {
            offset = 0;
         }
         if(this._state != HTTPStreamingState.INIT)
         {
            if(this._initialTime < 0)
            {
               this._seekTarget = offset + 0;
            }
            else
            {
               this._seekTarget = offset + this._initialTime;
            }
            this._seekTime = -1;
            this.setState(HTTPStreamingState.SEEK);
            super.seek(offset);
         }
         this._unpublishNotifyPending = false;
      }
      
      override public function close() : void
      {
         this.indexIsReady = false;
         switch(this._state)
         {
            case HTTPStreamingState.PLAY:
            case HTTPStreamingState.PLAY_START_NEXT:
            case HTTPStreamingState.PLAY_START_SEEK:
               this._urlStreamVideo.close();
         }
         this.setState(HTTPStreamingState.HALT);
         this.mainTimer.stop();
         dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
            "code":NetStreamCodes.NETSTREAM_PLAY_STOP,
            "level":"status"
         }));
         super.close();
      }
      
      override public function get time() : Number
      {
         if(this._seekTime >= 0 && this._initialTime >= 0)
         {
            this._lastValidTimeTime = super.time + this._seekTime - this._initialTime;
         }
         return this._lastValidTimeTime;
      }
      
      private function setState(value:String) : void
      {
         this._prevState = this._state;
         this._state = value;
      }
      
      private function insertScriptDataTag(tag:FLVTagScriptDataObject, first:Boolean = false) : void
      {
         if(!this._insertScriptDataTags)
         {
            this._insertScriptDataTags = new Vector.<FLVTagScriptDataObject>();
         }
         if(first)
         {
            this._insertScriptDataTags.unshift(tag);
         }
         else
         {
            this._insertScriptDataTags.push(tag);
         }
      }
      
      private function flvTagHandler(tag:FLVTag) : Boolean
      {
         var i:int = 0;
         var t:FLVTagScriptDataObject = null;
         var bytes:ByteArray = null;
         var currentTime:Number = NaN;
         var _muteTag:FLVTagVideo = null;
         var _unmuteTag:FLVTagVideo = null;
         var vTag:FLVTagVideo = null;
         var adjustment:int = 0;
         var compTime:int = 0;
         var aTag:FLVTagAudio = null;
         if(Boolean(this._insertScriptDataTags))
         {
            for(i = 0; i < this._insertScriptDataTags.length; i++)
            {
               t = this._insertScriptDataTags[i];
               t.timestamp = tag.timestamp;
               bytes = new ByteArray();
               t.write(bytes);
               this._flvParserProcessed += bytes.length;
               this.attemptAppendBytes(bytes);
            }
            this._insertScriptDataTags = null;
         }
         if(this._playForDuration >= 0)
         {
            if(this._initialTime >= 0)
            {
               currentTime = tag.timestamp / 1000 + this._fileTimeAdjustment;
               if(currentTime > this._initialTime + this._playForDuration)
               {
                  this.setState(HTTPStreamingState.STOP);
                  this._flvParserDone = true;
                  if(this._seekTime < 0)
                  {
                     this._seekTime = this._playForDuration + this._initialTime;
                  }
                  return false;
               }
            }
         }
         if(this._enhancedSeekTarget < 0)
         {
            if(this._initialTime < 0)
            {
               if(this._dvrInfo != null)
               {
                  this._initialTime = this._dvrInfo.startTime;
               }
               else
               {
                  this._initialTime = tag.timestamp / 1000 + this._fileTimeAdjustment;
               }
            }
            if(this._seekTime < 0)
            {
               this._seekTime = tag.timestamp / 1000 + this._fileTimeAdjustment;
            }
            bytes = new ByteArray();
            tag.write(bytes);
            this._flvParserProcessed += bytes.length;
            this.attemptAppendBytes(bytes);
            if(this._playForDuration >= 0)
            {
               if(this._segmentDuration >= 0 && this._flvParserIsSegmentStart)
               {
                  this._flvParserIsSegmentStart = false;
                  currentTime = tag.timestamp / 1000 + this._fileTimeAdjustment;
                  if(currentTime + this._segmentDuration >= this._initialTime + this._playForDuration)
                  {
                     return true;
                  }
                  this._flvParserDone = true;
                  return false;
               }
               return true;
            }
            this._flvParserDone = true;
            return false;
         }
         if(tag is FLVTagVideo)
         {
            if(this._flvParserIsSegmentStart)
            {
               _muteTag = new FLVTagVideo();
               _muteTag.timestamp = tag.timestamp;
               _muteTag.codecID = FLVTagVideo(tag).codecID;
               _muteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
               _muteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_START;
               this._enhancedSeekTags = new Vector.<FLVTagVideo>();
               this._enhancedSeekTags.push(_muteTag);
               this._flvParserIsSegmentStart = false;
            }
            if(tag.timestamp / 1000 + this._fileTimeAdjustment >= this._enhancedSeekTarget)
            {
               this._enhancedSeekTarget = -1;
               this._seekTime = tag.timestamp / 1000 + this._fileTimeAdjustment;
               if(this._initialTime < 0)
               {
                  this._initialTime = this._seekTime;
               }
               _unmuteTag = new FLVTagVideo();
               _unmuteTag.timestamp = tag.timestamp;
               _unmuteTag.codecID = this._enhancedSeekTags[0].codecID;
               _unmuteTag.frameType = FLVTagVideo.FRAME_TYPE_INFO;
               _unmuteTag.infoPacketValue = FLVTagVideo.INFO_PACKET_SEEK_END;
               this._enhancedSeekTags.push(_unmuteTag);
               for(i = 0; i < this._enhancedSeekTags.length; i++)
               {
                  vTag = this._enhancedSeekTags[i];
                  if(vTag.codecID == FLVTagVideo.CODEC_ID_AVC && vTag.avcPacketType == FLVTagVideo.AVC_PACKET_TYPE_NALU)
                  {
                     adjustment = tag.timestamp - vTag.timestamp;
                     compTime = vTag.avcCompositionTimeOffset;
                     compTime = vTag.avcCompositionTimeOffset;
                     compTime -= adjustment;
                     vTag.avcCompositionTimeOffset = compTime;
                     vTag.timestamp = tag.timestamp;
                  }
                  else
                  {
                     vTag.timestamp = tag.timestamp;
                  }
                  bytes = new ByteArray();
                  vTag.write(bytes);
                  this._flvParserProcessed += bytes.length;
                  this.attemptAppendBytes(bytes);
               }
               this._enhancedSeekTags = null;
               bytes = new ByteArray();
               tag.write(bytes);
               this._flvParserProcessed += bytes.length;
               this.attemptAppendBytes(bytes);
               if(this._playForDuration >= 0)
               {
                  return true;
               }
               this._flvParserDone = true;
               return false;
            }
            this._enhancedSeekTags.push(tag);
         }
         else if(tag is FLVTagScriptDataObject)
         {
            bytes = new ByteArray();
            tag.write(bytes);
            this._flvParserProcessed += bytes.length;
            this.attemptAppendBytes(bytes);
         }
         else if(tag is FLVTagAudio)
         {
            aTag = tag as FLVTagAudio;
            if(aTag.isCodecConfiguration)
            {
               bytes = new ByteArray();
               tag.write(bytes);
               this._flvParserProcessed += bytes.length;
               this.attemptAppendBytes(bytes);
            }
         }
         return true;
      }
      
      private function autoAdjustQuality(seeking:Boolean) : void
      {
         var proposedLevel:int = 0;
         var switchRatio:Number = NaN;
         if(!this._manualSwitchMode)
         {
            if(seeking)
            {
               this.setQualityLevel(0);
               return;
            }
            if(this._lastDownloadRatio < 1)
            {
               if(this.qualityLevel > 0)
               {
                  proposedLevel = this.qualityLevel - 1;
                  switchRatio = this._qualityRates[proposedLevel] / this._qualityRates[this.qualityLevel];
                  if(this._lastDownloadRatio < switchRatio)
                  {
                     this.setQualityLevel(0);
                  }
                  else
                  {
                     this.setQualityLevel(proposedLevel);
                  }
               }
            }
            else if(this.qualityLevel < this._numQualityLevels - 1)
            {
               proposedLevel = this.qualityLevel + 1;
               switchRatio = this._qualityRates[proposedLevel] / this._qualityRates[this.qualityLevel];
               if(this._lastDownloadRatio >= switchRatio)
               {
                  if(!(this._lastDownloadRatio > 100 || !this._aggressiveUpswitch))
                  {
                     while(++proposedLevel < this._numQualityLevels)
                     {
                        switchRatio = this._qualityRates[proposedLevel] / this._qualityRates[this.qualityLevel];
                        if(this._lastDownloadRatio < switchRatio)
                        {
                           break;
                        }
                     }
                     proposedLevel--;
                  }
                  this.setQualityLevel(proposedLevel);
               }
            }
         }
      }
      
      private function byteSource(input:IDataInput, numBytes:Number) : IDataInput
      {
         var needed:int = 0;
         if(numBytes < 0)
         {
            return null;
         }
         if(Boolean(numBytes))
         {
            if(this._savedBytes.bytesAvailable + input.bytesAvailable < numBytes)
            {
               return null;
            }
         }
         else if(this._savedBytes.bytesAvailable + input.bytesAvailable < 1)
         {
            return null;
         }
         if(Boolean(this._savedBytes.bytesAvailable))
         {
            needed = numBytes - this._savedBytes.bytesAvailable;
            if(needed > 0)
            {
               input.readBytes(this._savedBytes,this._savedBytes.length,needed);
            }
            return this._savedBytes;
         }
         this._savedBytes.length = 0;
         return input;
      }
      
      private function processAndAppend(inBytes:ByteArray) : uint
      {
         var bytes:ByteArray = null;
         var processed:uint = 0;
         if(!inBytes)
         {
            return 0;
         }
         if(Boolean(this._flvParser))
         {
            inBytes.position = 0;
            this._flvParserProcessed = 0;
            this._flvParser.parse(inBytes,true,this.flvTagHandler);
            processed += this._flvParserProcessed;
            if(!this._flvParserDone)
            {
               return processed;
            }
            bytes = new ByteArray();
            this._flvParser.flush(bytes);
            this._flvParser = null;
         }
         else
         {
            bytes = inBytes;
         }
         processed += bytes.length;
         if(this._state != HTTPStreamingState.STOP)
         {
            this.attemptAppendBytes(bytes);
         }
         return processed;
      }
      
      private function onMainTimer(timerEvent:TimerEvent) : void
      {
         var bytes:ByteArray = null;
         var nextRequest:HTTPStreamRequest = null;
         var date:Date = null;
         var endSegment:Boolean = false;
         var playCompleteInfo:Object = null;
         var playCompleteInfoSDOTag:FLVTagScriptDataObject = null;
         var tagBytes:ByteArray = null;
         var info:Object = null;
         var sdoTag:FLVTagScriptDataObject = null;
         var processLimit:int = 0;
         var processed:int = 0;
         var input:IDataInput = null;
         switch(this._state)
         {
            case HTTPStreamingState.INIT:
               this._seekAfterInit = true;
               break;
            case HTTPStreamingState.SEEK:
               switch(this._prevState)
               {
                  case HTTPStreamingState.PLAY:
                  case HTTPStreamingState.PLAY_START_NEXT:
                  case HTTPStreamingState.PLAY_START_SEEK:
                     this._urlStreamVideo.close();
               }
               this._dataAvailable = false;
               this._savedBytes.length = 0;
               if(this._enhancedSeekEnabled)
               {
                  this._enhancedSeekTarget = this._seekTarget;
               }
               this.setState(HTTPStreamingState.LOAD_SEEK);
               break;
            case HTTPStreamingState.LOAD_WAIT:
               if(this._lastDownloadRatio < 2)
               {
                  if(this.bufferLength < Math.max(7.5,this.bufferTime))
                  {
                     this.setState(HTTPStreamingState.LOAD_NEXT);
                  }
               }
               else if(this.bufferLength < Math.max(3.75,this.bufferTime))
               {
                  this.setState(HTTPStreamingState.LOAD_NEXT);
               }
               break;
            case HTTPStreamingState.LOAD_NEXT:
               this.autoAdjustQuality(false);
               if(this.qualityLevelHasChanged)
               {
                  bytes = this.fileHandler.flushFileSegment(Boolean(this._savedBytes.bytesAvailable) ? this._savedBytes : null);
                  this.processAndAppend(bytes);
                  info = new Object();
                  info.code = NetStreamCodes.NETSTREAM_PLAY_TRANSITION_COMPLETE;
                  info.level = "status";
                  sdoTag = new FLVTagScriptDataObject();
                  sdoTag.objects = ["onPlayStatus",info];
                  this.insertScriptDataTag(sdoTag);
                  this.qualityLevelHasChanged = false;
               }
               this.setState(HTTPStreamingState.LOAD);
               break;
            case HTTPStreamingState.LOAD_SEEK:
               if(!this._seekAfterInit)
               {
                  bytes = this.fileHandler.flushFileSegment(Boolean(this._savedBytes.bytesAvailable) ? this._savedBytes : null);
               }
               appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
               if(!this._seekAfterInit)
               {
                  this.autoAdjustQuality(true);
               }
               this._seekAfterInit = false;
               this.setState(HTTPStreamingState.LOAD);
               break;
            case HTTPStreamingState.LOAD:
               if(this._signalPlayStartPending)
               {
                  this.signalPlayStart();
                  this._signalPlayStartPending = false;
               }
               this._segmentDuration = -1;
               switch(this._prevState)
               {
                  case HTTPStreamingState.LOAD_SEEK:
                  case HTTPStreamingState.LOAD_SEEK_RETRY_WAIT:
                     nextRequest = this.indexHandler.getFileForTime(this._seekTarget,this.qualityLevel);
                     break;
                  case HTTPStreamingState.LOAD_NEXT:
                  case HTTPStreamingState.LOAD_NEXT_RETRY_WAIT:
                     nextRequest = this.indexHandler.getNextFile(this.qualityLevel);
                     break;
                  default:
                     throw new Error("in HTTPStreamState.LOAD with unknown _prevState " + this._prevState);
               }
               if(nextRequest != null && nextRequest.urlRequest != null)
               {
                  this._loadComplete = false;
                  this._urlStreamVideo.load(nextRequest.urlRequest);
                  date = new Date();
                  this._lastDownloadStartTime = date.getTime();
                  switch(this._prevState)
                  {
                     case HTTPStreamingState.LOAD_SEEK:
                     case HTTPStreamingState.LOAD_SEEK_RETRY_WAIT:
                        this.setState(HTTPStreamingState.PLAY_START_SEEK);
                        break;
                     case HTTPStreamingState.LOAD_NEXT:
                     case HTTPStreamingState.LOAD_NEXT_RETRY_WAIT:
                        this.setState(HTTPStreamingState.PLAY_START_NEXT);
                        break;
                     default:
                        throw new Error("in HTTPStreamState.LOAD(2) with unknown _prevState " + this._prevState);
                  }
               }
               else if(nextRequest != null && nextRequest.retryAfter >= 0)
               {
                  date = new Date();
                  this._retryAfterWaitUntil = date.getTime() + 1000 * nextRequest.retryAfter;
                  switch(this._prevState)
                  {
                     case HTTPStreamingState.LOAD_SEEK:
                     case HTTPStreamingState.LOAD_SEEK_RETRY_WAIT:
                        this.setState(HTTPStreamingState.LOAD_SEEK_RETRY_WAIT);
                        break;
                     case HTTPStreamingState.LOAD_NEXT:
                     case HTTPStreamingState.LOAD_NEXT_RETRY_WAIT:
                        this.setState(HTTPStreamingState.LOAD_NEXT_RETRY_WAIT);
                        break;
                     default:
                        throw new Error("in HTTPStreamState.LOAD(3) with unknown _prevState " + this._prevState);
                  }
               }
               else
               {
                  bytes = this.fileHandler.flushFileSegment(Boolean(this._savedBytes.bytesAvailable) ? this._savedBytes : null);
                  this.processAndAppend(bytes);
                  this.setState(HTTPStreamingState.STOP);
                  if(nextRequest != null && nextRequest.unpublishNotify)
                  {
                     this._unpublishNotifyPending = true;
                  }
               }
               break;
            case HTTPStreamingState.LOAD_SEEK_RETRY_WAIT:
            case HTTPStreamingState.LOAD_NEXT_RETRY_WAIT:
               date = new Date();
               if(date.getTime() > this._retryAfterWaitUntil)
               {
                  this.setState(HTTPStreamingState.LOAD);
               }
               break;
            case HTTPStreamingState.PLAY_START_NEXT:
               this.fileHandler.beginProcessFile(false,0);
               this.setState(HTTPStreamingState.PLAY_START_COMMON);
               break;
            case HTTPStreamingState.PLAY_START_SEEK:
               this.fileHandler.beginProcessFile(true,this._seekTarget);
               this.setState(HTTPStreamingState.PLAY_START_COMMON);
               break;
            case HTTPStreamingState.PLAY_START_COMMON:
               if(Boolean(this._initialTime < 0 || this._seekTime < 0 || this._insertScriptDataTags) || Boolean(this._enhancedSeekTarget >= 0) || this._playForDuration >= 0)
               {
                  if(this._enhancedSeekTarget >= 0 || this._playForDuration >= 0)
                  {
                     this._flvParserIsSegmentStart = true;
                  }
                  this._flvParser = new FLVParser(false);
                  this._flvParserDone = false;
               }
               this.setState(HTTPStreamingState.PLAY);
               break;
            case HTTPStreamingState.PLAY:
               endSegment = false;
               if(this._dataAvailable)
               {
                  processLimit = 65000 * 4;
                  processed = 0;
                  if(this._enhancedSeekTarget >= 0)
                  {
                     processLimit = 0;
                  }
                  input = null;
                  this._dataAvailable = false;
                  while(true)
                  {
                     input = this.byteSource(this._urlStreamVideo,this.fileHandler.inputBytesNeeded);
                     if(!(this._state == HTTPStreamingState.PLAY && (Boolean(input))))
                     {
                        break;
                     }
                     bytes = this.fileHandler.processFileSegment(input);
                     processed += this.processAndAppend(bytes);
                     if(processLimit > 0 && processed >= processLimit)
                     {
                        this._dataAvailable = true;
                        break;
                     }
                  }
                  if(this._state != HTTPStreamingState.PLAY)
                  {
                     break;
                  }
                  if(this._loadComplete && !input)
                  {
                     endSegment = true;
                  }
               }
               else if(this._loadComplete)
               {
                  endSegment = true;
               }
               if(endSegment)
               {
                  if(Boolean(this._urlStreamVideo.bytesAvailable))
                  {
                     this._urlStreamVideo.readBytes(this._savedBytes);
                  }
                  else
                  {
                     this._savedBytes.length = 0;
                  }
                  this.setState(HTTPStreamingState.END_SEGMENT);
               }
               break;
            case HTTPStreamingState.END_SEGMENT:
               bytes = this.fileHandler.endProcessFile(Boolean(this._savedBytes.bytesAvailable) ? this._savedBytes : null);
               this.processAndAppend(bytes);
               this._lastDownloadRatio = this._segmentDuration / this._lastDownloadDuration;
               if(this._state != HTTPStreamingState.STOP && this._state != HTTPStreamingState.HALT)
               {
                  this.setState(HTTPStreamingState.LOAD_WAIT);
               }
               break;
            case HTTPStreamingState.STOP:
               playCompleteInfo = new Object();
               playCompleteInfo.code = NetStreamCodes.NETSTREAM_PLAY_COMPLETE;
               playCompleteInfo.level = "status";
               playCompleteInfoSDOTag = new FLVTagScriptDataObject();
               playCompleteInfoSDOTag.objects = ["onPlayStatus",playCompleteInfo];
               tagBytes = new ByteArray();
               playCompleteInfoSDOTag.write(tagBytes);
               appendBytesAction(NetStreamAppendBytesAction.END_SEQUENCE);
               appendBytesAction(NetStreamAppendBytesAction.RESET_SEEK);
               this.attemptAppendBytes(tagBytes);
               this.setState(HTTPStreamingState.HALT);
               break;
            case HTTPStreamingState.HALT:
               break;
            default:
               throw new Error("HTTPStream cannot run undefined _state " + this._state);
         }
      }
      
      private function onURLStatus(progressEvent:ProgressEvent) : void
      {
         this._dataAvailable = true;
      }
      
      private function onURLComplete(event:Event) : void
      {
         var date:Date = new Date();
         this._lastDownloadDuration = (date.getTime() - this._lastDownloadStartTime) / 1000;
         this._loadComplete = true;
      }
      
      private function onRequestLoadIndexFile(event:HTTPStreamingIndexHandlerEvent) : void
      {
         var urlLoader:URLLoader = null;
         var requestContext:Object = null;
         var onIndexLoadComplete:Function = null;
         var onIndexURLError:Function = null;
         onIndexLoadComplete = function(innerEvent:Event):void
         {
            urlLoader.removeEventListener(Event.COMPLETE,onIndexLoadComplete);
            urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onIndexURLError);
            urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onIndexURLError);
            indexHandler.processIndexData(urlLoader.data,requestContext);
         };
         onIndexURLError = function(errorEvent:Event):void
         {
            urlLoader.removeEventListener(Event.COMPLETE,onIndexLoadComplete);
            urlLoader.removeEventListener(IOErrorEvent.IO_ERROR,onIndexURLError);
            urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR,onIndexURLError);
            handleURLError();
         };
         urlLoader = new URLLoader(event.request);
         requestContext = event.requestContext;
         if(event.binaryData)
         {
            urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
         }
         else
         {
            urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
         }
         urlLoader.addEventListener(Event.COMPLETE,onIndexLoadComplete);
         urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onIndexURLError);
         urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onIndexURLError);
      }
      
      private function onSegmentDurationFromFileHandler(event:HTTPStreamingFileHandlerEvent) : void
      {
         this._segmentDuration = event.segmentDuration;
      }
      
      private function onSegmentDurationFromIndexHandler(event:HTTPStreamingIndexHandlerEvent) : void
      {
         this._segmentDuration = event.segmentDuration;
      }
      
      private function onRates(event:HTTPStreamingIndexHandlerEvent) : void
      {
         this._qualityRates = event.rates;
         this._streamNames = event.streamNames;
         this._numQualityLevels = this._qualityRates.length;
      }
      
      private function onIndexReady(event:HTTPStreamingIndexHandlerEvent) : void
      {
         if(!this.indexIsReady)
         {
            if(event.live && this._dvrInfo == null && !isNaN(event.offset))
            {
               this._seekTarget = event.offset;
            }
            this._urlStreamVideo = new URLStream();
            this._urlStreamVideo.addEventListener(ProgressEvent.PROGRESS,this.onURLStatus,false,0,true);
            this._urlStreamVideo.addEventListener(Event.COMPLETE,this.onURLComplete,false,0,true);
            this._urlStreamVideo.addEventListener(IOErrorEvent.IO_ERROR,this.onVideoURLError,false,0,true);
            this._urlStreamVideo.addEventListener(SecurityErrorEvent.SECURITY_ERROR,this.onVideoURLError,false,0,true);
            this.setState(HTTPStreamingState.SEEK);
            this.indexIsReady = true;
         }
      }
      
      private function onVideoURLError(event:Event) : void
      {
         this.handleURLError();
      }
      
      private function handleURLError() : void
      {
         dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
            "code":NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND,
            "level":"error"
         }));
      }
      
      private function onScriptDataFromIndexHandler(event:HTTPStreamingIndexHandlerEvent) : void
      {
         this.onScriptData(event.scriptDataObject,event.scriptDataFirst,event.scriptDataImmediate);
      }
      
      private function onScriptDataFromFileHandler(event:HTTPStreamingFileHandlerEvent) : void
      {
         this.onScriptData(event.scriptDataObject,event.scriptDataFirst,event.scriptDataImmediate);
      }
      
      private function onErrorFromFileHandler(event:HTTPStreamingFileHandlerEvent) : void
      {
         this.setState(HTTPStreamingState.HALT);
         dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
            "code":NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID,
            "level":"error"
         }));
      }
      
      private function onScriptData(scriptDataObject:FLVTagScriptDataObject, scriptDataFirst:Boolean, scriptDataImmediate:Boolean) : void
      {
         if(scriptDataImmediate)
         {
            if(Boolean(client))
            {
               if(client.hasOwnProperty(scriptDataObject.objects[0]))
               {
                  client[scriptDataObject.objects[0]](scriptDataObject.objects[1]);
               }
            }
         }
         else
         {
            this.insertScriptDataTag(scriptDataObject,scriptDataFirst);
         }
      }
      
      private function onDVRStreamInfo(event:DVRStreamInfoEvent) : void
      {
         this._dvrInfo = event.info as DVRInfo;
         dispatchEvent(event.clone());
      }
      
      private function onIndexError(event:HTTPStreamingIndexHandlerEvent) : void
      {
         dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
            "code":NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND,
            "level":"error"
         }));
      }
      
      private function setQualityLevel(value:int) : void
      {
         if(value >= 0 && value < this._numQualityLevels)
         {
            if(value != this._qualityLevel)
            {
               this._qualityLevel = value;
               this.qualityLevelHasChanged = true;
               dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
                  "code":NetStreamCodes.NETSTREAM_PLAY_TRANSITION,
                  "level":"status",
                  "details":this._streamNames[value]
               }));
            }
            return;
         }
         throw new Error("qualityLevel cannot be set to this value at this time");
      }
      
      private function setQualityLevelForStreamName(streamName:String) : void
      {
         var i:int = 0;
         var level:int = -1;
         if(this._streamNames != null)
         {
            for(i = 0; i < this._streamNames.length; i++)
            {
               if(streamName == this._streamNames[i])
               {
                  level = i;
                  break;
               }
            }
         }
         if(level != -1)
         {
            this.setQualityLevel(level);
         }
      }
      
      private function attemptAppendBytes(bytes:ByteArray) : void
      {
         appendBytes(bytes);
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         if(event.info.code == NetStreamCodes.NETSTREAM_BUFFER_EMPTY && this._state == HTTPStreamingState.HALT)
         {
            this.finishStopProcess();
         }
      }
      
      private function finishStopProcess() : void
      {
         if(this._unpublishNotifyPending)
         {
            dispatchEvent(new NetStatusEvent(NetStatusEvent.NET_STATUS,false,false,{
               "code":NetStreamCodes.NETSTREAM_PLAY_UNPUBLISH_NOTIFY,
               "level":"status"
            }));
            this._unpublishNotifyPending = false;
         }
      }
   }
}

