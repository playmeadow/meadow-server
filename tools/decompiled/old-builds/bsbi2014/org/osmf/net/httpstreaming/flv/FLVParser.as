package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   [ExcludeClass]
   public class FLVParser
   {
      
      private var state:String;
      
      private var savedBytes:ByteArray;
      
      private var currentTag:FLVTag = null;
      
      private var flvHeader:FLVHeader;
      
      public function FLVParser(startWithFileHeader:Boolean)
      {
         super();
         this.savedBytes = new ByteArray();
         if(startWithFileHeader)
         {
            this.state = FLVParserState.FILE_HEADER;
         }
         else
         {
            this.state = FLVParserState.TYPE;
         }
      }
      
      public function flush(output:IDataOutput) : void
      {
         output.writeBytes(this.savedBytes);
      }
      
      public function parse(input:IDataInput, consumeAll:Boolean, onEachFLVTag:Function) : void
      {
         var source:IDataInput = null;
         var type:int = 0;
         var continueParsing:Boolean = true;
         while(continueParsing)
         {
            switch(this.state)
            {
               case FLVParserState.FILE_HEADER:
                  source = this.byteSource(input,FLVHeader.MIN_FILE_HEADER_BYTE_COUNT);
                  if(source != null)
                  {
                     this.flvHeader = new FLVHeader();
                     this.flvHeader.readHeader(source);
                     this.state = FLVParserState.FILE_HEADER_REST;
                  }
                  else
                  {
                     continueParsing = false;
                  }
                  break;
               case FLVParserState.FILE_HEADER_REST:
                  source = this.byteSource(input,this.flvHeader.restBytesNeeded);
                  if(source != null)
                  {
                     this.flvHeader.readRest(source);
                     this.state = FLVParserState.TYPE;
                  }
                  else
                  {
                     continueParsing = false;
                  }
                  break;
               case FLVParserState.TYPE:
                  source = this.byteSource(input,1);
                  if(source != null)
                  {
                     type = source.readByte();
                     switch(type)
                     {
                        case FLVTag.TAG_TYPE_AUDIO:
                        case FLVTag.TAG_TYPE_ENCRYPTED_AUDIO:
                           this.currentTag = new FLVTagAudio(type);
                           break;
                        case FLVTag.TAG_TYPE_VIDEO:
                        case FLVTag.TAG_TYPE_ENCRYPTED_VIDEO:
                           this.currentTag = new FLVTagVideo(type);
                           break;
                        case FLVTag.TAG_TYPE_SCRIPTDATAOBJECT:
                        case FLVTag.TAG_TYPE_ENCRYPTED_SCRIPTDATAOBJECT:
                           this.currentTag = new FLVTagScriptDataObject(type);
                           break;
                        default:
                           this.currentTag = new FLVTag(type);
                     }
                     this.state = FLVParserState.HEADER;
                  }
                  else
                  {
                     continueParsing = false;
                  }
                  break;
               case FLVParserState.HEADER:
                  source = this.byteSource(input,FLVTag.TAG_HEADER_BYTE_COUNT - 1);
                  if(source != null)
                  {
                     this.currentTag.readRemainingHeader(source);
                     if(Boolean(this.currentTag.dataSize))
                     {
                        this.state = FLVParserState.DATA;
                     }
                     else
                     {
                        this.state = FLVParserState.PREV_TAG;
                     }
                  }
                  else
                  {
                     continueParsing = false;
                  }
                  break;
               case FLVParserState.DATA:
                  source = this.byteSource(input,this.currentTag.dataSize);
                  if(source != null)
                  {
                     this.currentTag.readData(source);
                     this.state = FLVParserState.PREV_TAG;
                  }
                  else
                  {
                     continueParsing = false;
                  }
                  break;
               case FLVParserState.PREV_TAG:
                  source = this.byteSource(input,FLVTag.PREV_TAG_BYTE_COUNT);
                  if(source != null)
                  {
                     this.currentTag.readPrevTag(source);
                     this.state = FLVParserState.TYPE;
                     continueParsing = onEachFLVTag(this.currentTag);
                  }
                  else
                  {
                     continueParsing = false;
                  }
                  break;
               default:
                  throw new Error("FLVParser state machine in unknown state");
            }
         }
         if(consumeAll)
         {
            input.readBytes(this.savedBytes,this.savedBytes.length);
         }
      }
      
      private function byteSource(input:IDataInput, numBytes:int) : IDataInput
      {
         var needed:int = 0;
         if(this.savedBytes.bytesAvailable + input.bytesAvailable < numBytes)
         {
            return null;
         }
         if(Boolean(this.savedBytes.bytesAvailable))
         {
            needed = numBytes - this.savedBytes.bytesAvailable;
            if(needed > 0)
            {
               input.readBytes(this.savedBytes,this.savedBytes.length,needed);
            }
            return this.savedBytes;
         }
         this.savedBytes.length = 0;
         return input;
      }
   }
}

