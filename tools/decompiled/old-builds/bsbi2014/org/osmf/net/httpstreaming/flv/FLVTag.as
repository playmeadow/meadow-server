package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   [ExcludeClass]
   public class FLVTag
   {
      
      public static const TAG_TYPE_AUDIO:int = 8;
      
      public static const TAG_TYPE_VIDEO:int = 9;
      
      public static const TAG_TYPE_SCRIPTDATAOBJECT:int = 18;
      
      public static const TAG_FLAG_ENCRYPTED:int = 32;
      
      public static const TAG_TYPE_ENCRYPTED_AUDIO:int = TAG_TYPE_AUDIO + TAG_FLAG_ENCRYPTED;
      
      public static const TAG_TYPE_ENCRYPTED_VIDEO:int = TAG_TYPE_VIDEO + TAG_FLAG_ENCRYPTED;
      
      public static const TAG_TYPE_ENCRYPTED_SCRIPTDATAOBJECT:int = TAG_TYPE_SCRIPTDATAOBJECT + TAG_FLAG_ENCRYPTED;
      
      internal static const TAG_HEADER_BYTE_COUNT:int = 11;
      
      internal static const PREV_TAG_BYTE_COUNT:int = 4;
      
      protected var bytes:ByteArray = null;
      
      public function FLVTag(type:int)
      {
         super();
         this.bytes = new ByteArray();
         this.bytes.length = TAG_HEADER_BYTE_COUNT;
         this.bytes[0] = type;
      }
      
      public function read(input:IDataInput) : void
      {
         this.readType(input);
         this.readRemainingHeader(input);
         this.readData(input);
         this.readPrevTag(input);
      }
      
      public function readType(input:IDataInput) : void
      {
         if(input.bytesAvailable < 1)
         {
            throw new Error("FLVTag.readType() input too short");
         }
         input.readBytes(this.bytes,0,1);
      }
      
      public function readRemaining(input:IDataInput) : void
      {
         this.readRemainingHeader(input);
         this.readData(input);
         this.readPrevTag(input);
      }
      
      public function readRemainingHeader(input:IDataInput) : void
      {
         if(input.bytesAvailable < 10)
         {
            throw new Error("FLVTag.readHeader() input too short");
         }
         input.readBytes(this.bytes,1,TAG_HEADER_BYTE_COUNT - 1);
      }
      
      public function readData(input:IDataInput) : void
      {
         if(this.dataSize > 0)
         {
            if(input.bytesAvailable < this.dataSize)
            {
               throw new Error("FLVTag().readData input shorter than dataSize");
            }
            input.readBytes(this.bytes,TAG_HEADER_BYTE_COUNT,this.dataSize);
         }
      }
      
      public function readPrevTag(input:IDataInput) : void
      {
         if(input.bytesAvailable < 4)
         {
            throw new Error("FLVTag.readPrevTag() input too short");
         }
         input.readUnsignedInt();
      }
      
      public function write(output:IDataOutput) : void
      {
         output.writeBytes(this.bytes,0,TAG_HEADER_BYTE_COUNT + this.dataSize);
         output.writeUnsignedInt(TAG_HEADER_BYTE_COUNT + this.dataSize);
      }
      
      public function get tagType() : uint
      {
         return this.bytes[0];
      }
      
      public function set tagType(value:uint) : void
      {
         this.bytes[0] = value;
      }
      
      public function get isEncrpted() : Boolean
      {
         return Boolean(this.bytes[0] & TAG_FLAG_ENCRYPTED) ? true : false;
      }
      
      public function get dataSize() : uint
      {
         return this.bytes[1] << 16 | this.bytes[2] << 8 | this.bytes[3];
      }
      
      public function set dataSize(value:uint) : void
      {
         this.bytes[1] = value >> 16 & 0xFF;
         this.bytes[2] = value >> 8 & 0xFF;
         this.bytes[3] = value & 0xFF;
         this.bytes.length = TAG_HEADER_BYTE_COUNT + value;
      }
      
      public function get timestamp() : uint
      {
         return this.bytes[7] << 24 | this.bytes[4] << 16 | this.bytes[5] << 8 | this.bytes[6];
      }
      
      public function set timestamp(value:uint) : void
      {
         this.bytes[7] = value >> 24 & 0xFF;
         this.bytes[4] = value >> 16 & 0xFF;
         this.bytes[5] = value >> 8 & 0xFF;
         this.bytes[6] = value & 0xFF;
      }
      
      public function get data() : ByteArray
      {
         var data:ByteArray = new ByteArray();
         data.writeBytes(this.bytes,TAG_HEADER_BYTE_COUNT,this.dataSize);
         return data;
      }
      
      public function set data(value:ByteArray) : void
      {
         this.bytes.length = TAG_HEADER_BYTE_COUNT + value.length;
         this.bytes.position = TAG_HEADER_BYTE_COUNT;
         this.bytes.writeBytes(value,0,value.length);
         this.dataSize = value.length;
      }
   }
}

