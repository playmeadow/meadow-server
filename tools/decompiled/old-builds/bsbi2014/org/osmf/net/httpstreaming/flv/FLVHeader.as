package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   [ExcludeClass]
   public class FLVHeader
   {
      
      public static const MIN_FILE_HEADER_BYTE_COUNT:int = 9;
      
      private var _hasVideoTags:Boolean = true;
      
      private var _hasAudioTags:Boolean = true;
      
      private var offset:uint;
      
      public function FLVHeader(input:IDataInput = null)
      {
         super();
         if(input != null)
         {
            this.readHeader(input);
            this.readRest(input);
         }
      }
      
      public function get hasAudioTags() : Boolean
      {
         return this._hasAudioTags;
      }
      
      public function set hasAudioTags(value:Boolean) : void
      {
         this._hasAudioTags = value;
      }
      
      public function get hasVideoTags() : Boolean
      {
         return this._hasVideoTags;
      }
      
      public function set hasVideoTags(value:Boolean) : void
      {
         this._hasVideoTags = value;
      }
      
      public function write(output:IDataOutput) : void
      {
         output.writeByte(70);
         output.writeByte(76);
         output.writeByte(86);
         output.writeByte(1);
         var flags:uint = 0;
         if(this._hasAudioTags)
         {
            flags |= 4;
         }
         if(this._hasVideoTags)
         {
            flags |= 1;
         }
         output.writeByte(flags);
         var offsetToWrite:uint = uint(MIN_FILE_HEADER_BYTE_COUNT);
         output.writeUnsignedInt(offsetToWrite);
         var previousTagSize0:uint = 0;
         output.writeUnsignedInt(previousTagSize0);
      }
      
      internal function readHeader(input:IDataInput) : void
      {
         if(input.bytesAvailable < MIN_FILE_HEADER_BYTE_COUNT)
         {
            throw new Error("FLVHeader() input too short");
         }
         if(input.readByte() != 70)
         {
            throw new Error("FLVHeader readHeader() Signature[0] not \'F\'");
         }
         if(input.readByte() != 76)
         {
            throw new Error("FLVHeader readHeader() Signature[1] not \'L\'");
         }
         if(input.readByte() != 86)
         {
            throw new Error("FLVHeader readHeader() Signature[2] not \'V\'");
         }
         if(input.readByte() != 1)
         {
            throw new Error("FLVHeader readHeader() Version not 0x01");
         }
         var flags:int = input.readByte();
         this._hasAudioTags = Boolean(flags & 4) ? true : false;
         this._hasVideoTags = Boolean(flags & 1) ? true : false;
         this.offset = input.readUnsignedInt();
         if(this.offset < MIN_FILE_HEADER_BYTE_COUNT)
         {
            throw new Error("FLVHeader() offset smaller than minimum");
         }
      }
      
      internal function readRest(input:IDataInput) : void
      {
         var discard:ByteArray = null;
         if(this.offset > MIN_FILE_HEADER_BYTE_COUNT)
         {
            if(this.offset - MIN_FILE_HEADER_BYTE_COUNT < input.bytesAvailable - FLVTag.PREV_TAG_BYTE_COUNT)
            {
               throw new Error("FLVHeader() input too short for nonstandard offset");
            }
            discard = new ByteArray();
            input.readBytes(discard,0,this.offset - MIN_FILE_HEADER_BYTE_COUNT);
         }
         if(input.bytesAvailable < FLVTag.PREV_TAG_BYTE_COUNT)
         {
            throw new Error("FLVHeader() input too short for previousTagSize0");
         }
         input.readUnsignedInt();
      }
      
      internal function get restBytesNeeded() : int
      {
         return FLVTag.PREV_TAG_BYTE_COUNT + (this.offset - MIN_FILE_HEADER_BYTE_COUNT);
      }
   }
}

