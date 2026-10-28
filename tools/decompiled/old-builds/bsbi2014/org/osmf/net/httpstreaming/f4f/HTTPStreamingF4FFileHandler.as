package org.osmf.net.httpstreaming.f4f
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import org.osmf.events.HTTPStreamingFileHandlerEvent;
   import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
   
   [ExcludeClass]
   public class HTTPStreamingF4FFileHandler extends HTTPStreamingFileHandlerBase
   {
      
      private static const MAX_BYTES_PER_MDAT_READ:uint = 5 * 1024;
      
      private var _afra:AdobeFragmentRandomAccessBox;
      
      private var _ba:ByteArray;
      
      private var _boxInfoPending:Boolean;
      
      private var _bytesNeeded:uint;
      
      private var _bytesReadSinceAfraStart:uint;
      
      private var _countingReadBytes:Boolean;
      
      private var _mdatBytesPending:uint;
      
      private var _nextBox:BoxInfo;
      
      private var _parser:BoxParser = new BoxParser();
      
      private var _seekToTime:Number;
      
      private var _mdatBytesOffset:Number;
      
      private var _processRequestWasSeek:Boolean = false;
      
      public function HTTPStreamingF4FFileHandler()
      {
         super();
      }
      
      override public function beginProcessFile(seek:Boolean, seekTime:Number) : void
      {
         this._processRequestWasSeek = seek;
         this._seekToTime = seek ? seekTime : 0;
         this._bytesNeeded = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH + F4FConstants.FIELD_LARGE_SIZE_LENGTH + F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
         this._bytesReadSinceAfraStart = 0;
         this._countingReadBytes = false;
         this._boxInfoPending = true;
         this._nextBox = null;
      }
      
      override public function get inputBytesNeeded() : Number
      {
         return this._bytesNeeded;
      }
      
      override public function processFileSegment(input:IDataInput) : ByteArray
      {
         var pos:uint = 0;
         var abst:AdobeBootstrapBox = null;
         if(input.bytesAvailable < this._bytesNeeded)
         {
            return null;
         }
         var returnByteArray:ByteArray = null;
         var bytesRead:Number = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH;
         if(this._boxInfoPending)
         {
            this._ba = new ByteArray();
            input.readBytes(this._ba,0,bytesRead);
            if(this._countingReadBytes)
            {
               this._bytesReadSinceAfraStart += bytesRead;
            }
            this._parser.init(this._ba);
            this._nextBox = this._parser.getNextBoxInfo();
            if(this._nextBox.size == F4FConstants.FLAG_USE_LARGE_SIZE)
            {
               bytesRead += F4FConstants.FIELD_LARGE_SIZE_LENGTH;
               this._ba.position = 0;
               input.readBytes(this._ba,0,F4FConstants.FIELD_LARGE_SIZE_LENGTH);
               if(this._countingReadBytes)
               {
                  this._bytesReadSinceAfraStart += F4FConstants.FIELD_LARGE_SIZE_LENGTH;
               }
               this._nextBox.size = this._parser.readLongUIntToNumber();
            }
            this._boxInfoPending = false;
            if(this._nextBox.type == F4FConstants.BOX_TYPE_MDAT)
            {
               this._bytesNeeded = 0;
               this._mdatBytesPending = this._nextBox.size - bytesRead;
            }
            else
            {
               this._bytesNeeded = this._nextBox.size - bytesRead;
               this._mdatBytesPending = 0;
               if(this._nextBox.type == F4FConstants.BOX_TYPE_AFRA)
               {
                  this._bytesReadSinceAfraStart = bytesRead;
                  this._countingReadBytes = true;
               }
            }
         }
         else if(this._bytesNeeded > 0)
         {
            pos = this._ba.position;
            input.readBytes(this._ba,this._ba.length,this._nextBox.size - bytesRead);
            if(this._countingReadBytes)
            {
               this._bytesReadSinceAfraStart += this._nextBox.size - bytesRead;
            }
            this._ba.position = pos;
            if(this._nextBox.type == F4FConstants.BOX_TYPE_ABST)
            {
               abst = this._parser.readAdobeBootstrapBox(this._nextBox);
               if(abst != null)
               {
                  dispatchEvent(new HTTPStreamingFileHandlerEvent(HTTPStreamingFileHandlerEvent.NOTIFY_BOOTSTRAP_BOX,false,false,0,null,false,false,abst));
               }
            }
            else if(this._nextBox.type == F4FConstants.BOX_TYPE_AFRA)
            {
               this._afra = this._parser.readFragmentRandomAccessBox(this._nextBox);
               this.processSeekToTime();
            }
            else if(this._nextBox.type == F4FConstants.BOX_TYPE_MOOF)
            {
            }
            this._bytesNeeded = F4FConstants.FIELD_SIZE_LENGTH + F4FConstants.FIELD_TYPE_LENGTH + F4FConstants.FIELD_LARGE_SIZE_LENGTH + F4FConstants.FIELD_EXTENDED_TYPE_LENGTH;
            this._boxInfoPending = true;
            this._nextBox = null;
         }
         else
         {
            returnByteArray = this.getMDATBytes(input,false);
         }
         return returnByteArray;
      }
      
      override public function endProcessFile(input:IDataInput) : ByteArray
      {
         if(this._bytesNeeded > 0)
         {
            dispatchEvent(new HTTPStreamingFileHandlerEvent(HTTPStreamingFileHandlerEvent.NOTIFY_ERROR,false,false,0,null,false,false,null,true));
         }
         return this.getMDATBytes(input,true);
      }
      
      override public function flushFileSegment(input:IDataInput) : ByteArray
      {
         return null;
      }
      
      private function getMDATBytes(input:IDataInput, endOfFile:Boolean) : ByteArray
      {
         var ba:ByteArray = null;
         var bytesToRead:uint = 0;
         if(input == null)
         {
            return null;
         }
         this.skipSeekBytes(input);
         if(this._mdatBytesPending > 0)
         {
            bytesToRead = this._mdatBytesPending < input.bytesAvailable ? this._mdatBytesPending : input.bytesAvailable;
            if(!endOfFile && bytesToRead > MAX_BYTES_PER_MDAT_READ)
            {
               bytesToRead = MAX_BYTES_PER_MDAT_READ;
            }
            ba = new ByteArray();
            this._mdatBytesPending -= bytesToRead;
            input.readBytes(ba,0,bytesToRead);
         }
         return ba;
      }
      
      private function skipSeekBytes(input:IDataInput) : void
      {
         var skip:uint = 0;
         var ba:ByteArray = null;
         if(this._bytesReadSinceAfraStart < this._mdatBytesOffset)
         {
            skip = this._mdatBytesOffset - this._bytesReadSinceAfraStart;
            if(input.bytesAvailable < skip)
            {
               skip = input.bytesAvailable;
            }
            ba = new ByteArray();
            input.readBytes(ba,0,skip);
            this._bytesReadSinceAfraStart += skip;
            this._mdatBytesPending -= skip;
         }
      }
      
      private function processSeekToTime() : void
      {
         var timeBias:Number = 0;
         var entry:LocalRandomAccessEntry = null;
         if(this._seekToTime <= 0)
         {
            this._mdatBytesOffset = 0;
         }
         else
         {
            entry = this.getMDATBytesOffset(this._seekToTime);
            if(entry != null)
            {
               this._mdatBytesOffset = entry.offset;
               timeBias = entry.time;
            }
            else
            {
               this._mdatBytesOffset = 0;
            }
         }
      }
      
      private function getMDATBytesOffset(seekToTime:Number) : LocalRandomAccessEntry
      {
         return !isNaN(seekToTime) ? this._afra.findNearestKeyFrameOffset(seekToTime * this._afra.timeScale) : null;
      }
   }
}

