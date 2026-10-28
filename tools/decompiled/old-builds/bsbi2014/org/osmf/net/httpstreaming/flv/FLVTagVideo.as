package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   
   [ExcludeClass]
   public class FLVTagVideo extends FLVTag
   {
      
      public static const FRAME_TYPE_KEYFRAME:int = 1;
      
      public static const FRAME_TYPE_INTER:int = 2;
      
      public static const FRAME_TYPE_DISPOSABLE_INTER:int = 3;
      
      public static const FRAME_TYPE_GENERATED_KEYFRAME:int = 4;
      
      public static const FRAME_TYPE_INFO:int = 5;
      
      public static const CODEC_ID_JPEG:int = 1;
      
      public static const CODEC_ID_SORENSON:int = 2;
      
      public static const CODEC_ID_SCREEN:int = 3;
      
      public static const CODEC_ID_VP6:int = 4;
      
      public static const CODEC_ID_VP6_ALPHA:int = 5;
      
      public static const CODEC_ID_SCREEN_V2:int = 6;
      
      public static const CODEC_ID_AVC:int = 7;
      
      public static const AVC_PACKET_TYPE_SEQUENCE_HEADER:int = 0;
      
      public static const AVC_PACKET_TYPE_NALU:int = 1;
      
      public static const AVC_PACKET_TYPE_END_OF_SEQUENCE:int = 2;
      
      public static const INFO_PACKET_SEEK_START:int = 0;
      
      public static const INFO_PACKET_SEEK_END:int = 1;
      
      public function FLVTagVideo(type:int = 9)
      {
         super(type);
      }
      
      public function get frameType() : int
      {
         return bytes[TAG_HEADER_BYTE_COUNT + 0] >> 4 & 0x0F;
      }
      
      public function set frameType(value:int) : void
      {
         bytes[TAG_HEADER_BYTE_COUNT + 0] &= 15;
         bytes[TAG_HEADER_BYTE_COUNT + 0] |= (value & 0x0F) << 4;
      }
      
      public function get codecID() : int
      {
         return bytes[TAG_HEADER_BYTE_COUNT + 0] & 0x0F;
      }
      
      public function set codecID(value:int) : void
      {
         bytes[TAG_HEADER_BYTE_COUNT + 0] &= 240;
         bytes[TAG_HEADER_BYTE_COUNT + 0] |= value & 0x0F;
      }
      
      public function get infoPacketValue() : int
      {
         if(this.frameType != FRAME_TYPE_INFO)
         {
            throw new Error("get infoPacketValue() not permitted unless frameType is FRAME_TYPE_INFO");
         }
         return bytes[TAG_HEADER_BYTE_COUNT + 1];
      }
      
      public function set infoPacketValue(value:int) : void
      {
         if(this.frameType != FRAME_TYPE_INFO)
         {
            throw new Error("get infoPacketValue() not permitted unless frameType is FRAME_TYPE_INFO");
         }
         bytes[TAG_HEADER_BYTE_COUNT + 1] = value;
         bytes.length = TAG_HEADER_BYTE_COUNT + 2;
         dataSize = 2;
      }
      
      public function get avcPacketType() : int
      {
         if(this.codecID != CODEC_ID_AVC)
         {
            throw new Error("get avcPacketType() not permitted unless codecID is CODEC_ID_AVC");
         }
         return bytes[TAG_HEADER_BYTE_COUNT + 1];
      }
      
      public function set avcPacketType(value:int) : void
      {
         if(this.codecID != CODEC_ID_AVC)
         {
            throw new Error("set avcPacketType() not permitted unless codecID is CODEC_ID_AVC");
         }
         bytes[TAG_HEADER_BYTE_COUNT + 1] = value;
         if(this.avcPacketType != AVC_PACKET_TYPE_NALU)
         {
            bytes[TAG_HEADER_BYTE_COUNT + 2] = 0;
            bytes[TAG_HEADER_BYTE_COUNT + 3] = 0;
            bytes[TAG_HEADER_BYTE_COUNT + 4] = 0;
            bytes.length = TAG_HEADER_BYTE_COUNT + 5;
            dataSize = 5;
         }
      }
      
      public function get avcCompositionTimeOffset() : int
      {
         if(this.codecID != CODEC_ID_AVC || this.avcPacketType != AVC_PACKET_TYPE_NALU)
         {
            throw new Error("get avcCompositionTimeOffset() not permitted unless codecID is CODEC_ID_AVC and avcPacketType is AVC NALU");
         }
         var value:int = bytes[TAG_HEADER_BYTE_COUNT + 2] << 16;
         value |= bytes[TAG_HEADER_BYTE_COUNT + 3] << 8;
         value |= bytes[TAG_HEADER_BYTE_COUNT + 4];
         if(Boolean(value & 0x800000))
         {
            value |= 4278190080;
         }
         return value;
      }
      
      public function set avcCompositionTimeOffset(value:int) : void
      {
         if(this.codecID != CODEC_ID_AVC || this.avcPacketType != AVC_PACKET_TYPE_NALU)
         {
            throw new Error("set avcCompositionTimeOffset() not permitted unless codecID is CODEC_ID_AVC and avcPacketType is AVC NALU");
         }
         bytes[TAG_HEADER_BYTE_COUNT + 2] = value >> 16 & 0xFF;
         bytes[TAG_HEADER_BYTE_COUNT + 3] = value >> 8 & 0xFF;
         bytes[TAG_HEADER_BYTE_COUNT + 4] = value & 0xFF;
      }
      
      override public function get data() : ByteArray
      {
         var data:ByteArray = new ByteArray();
         if(this.codecID == CODEC_ID_AVC)
         {
            data.writeBytes(bytes,TAG_HEADER_BYTE_COUNT + 5,dataSize - 5);
         }
         else
         {
            data.writeBytes(bytes,TAG_HEADER_BYTE_COUNT + 1,dataSize - 1);
         }
         return data;
      }
      
      override public function set data(value:ByteArray) : void
      {
         if(this.codecID == CODEC_ID_AVC)
         {
            bytes.length = TAG_HEADER_BYTE_COUNT + value.length + 5;
            bytes.position = TAG_HEADER_BYTE_COUNT + 5;
            bytes.writeBytes(value,0,value.length);
            dataSize = value.length + 5;
         }
         else
         {
            bytes.length = TAG_HEADER_BYTE_COUNT + value.length + 1;
            bytes.position = TAG_HEADER_BYTE_COUNT + 1;
            bytes.writeBytes(value,0,value.length);
            dataSize = value.length + 1;
         }
      }
   }
}

