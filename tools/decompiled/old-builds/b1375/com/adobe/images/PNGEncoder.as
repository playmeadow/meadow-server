package com.adobe.images
{
   import flash.display.BitmapData;
   import flash.geom.*;
   import flash.utils.ByteArray;
   
   public class PNGEncoder
   {
      
      private static var crcTable:Array;
      
      private static var crcTableComputed:Boolean = false;
      
      public function PNGEncoder()
      {
         super();
      }
      
      public static function encode(param1:BitmapData) : ByteArray
      {
         var _loc7_:int = 0;
         var _loc3_:* = 0;
         var _loc5_:int = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(2303741511);
         _loc2_.writeUnsignedInt(218765834);
         var _loc4_:ByteArray = new ByteArray();
         _loc4_.writeInt(param1.width);
         _loc4_.writeInt(param1.height);
         _loc4_.writeUnsignedInt(134610944);
         _loc4_.writeByte(0);
         writeChunk(_loc2_,1229472850,_loc4_);
         var _loc6_:ByteArray = new ByteArray();
         _loc7_ = 0;
         while(_loc7_ < param1.height)
         {
            _loc6_.writeByte(0);
            if(!param1.transparent)
            {
               _loc5_ = 0;
               while(_loc5_ < param1.width)
               {
                  _loc3_ = param1.getPixel(_loc5_,_loc7_);
                  _loc6_.writeUnsignedInt(uint((_loc3_ & 0xFFFFFF) << 8 | 0xFF));
                  _loc5_++;
               }
            }
            else
            {
               _loc5_ = 0;
               while(_loc5_ < param1.width)
               {
                  _loc3_ = param1.getPixel32(_loc5_,_loc7_);
                  _loc6_.writeUnsignedInt(uint((_loc3_ & 0xFFFFFF) << 8 | _loc3_ >>> 24));
                  _loc5_++;
               }
            }
            _loc7_++;
         }
         _loc6_.compress();
         writeChunk(_loc2_,1229209940,_loc6_);
         writeChunk(_loc2_,1229278788,null);
         return _loc2_;
      }
      
      private static function writeChunk(param1:ByteArray, param2:uint, param3:ByteArray) : void
      {
         var _loc5_:* = 0;
         var _loc7_:* = 0;
         var _loc9_:* = 0;
         var _loc10_:int = 0;
         if(!crcTableComputed)
         {
            crcTableComputed = true;
            crcTable = [];
            _loc7_ = 0;
            while(_loc7_ < 256)
            {
               _loc5_ = _loc7_;
               _loc9_ = 0;
               while(_loc9_ < 8)
               {
                  if(_loc5_ & 1)
                  {
                     _loc5_ = uint(0xEDB88320 ^ uint(_loc5_ >>> 1));
                  }
                  else
                  {
                     _loc5_ >>>= 1;
                  }
                  _loc9_++;
               }
               crcTable[_loc7_] = _loc5_;
               _loc7_++;
            }
         }
         var _loc8_:uint = 0;
         if(param3 != null)
         {
            _loc8_ = param3.length;
         }
         param1.writeUnsignedInt(_loc8_);
         var _loc6_:uint = param1.position;
         param1.writeUnsignedInt(param2);
         if(param3 != null)
         {
            param1.writeBytes(param3);
         }
         var _loc4_:uint = param1.position;
         param1.position = _loc6_;
         _loc5_ = uint(4294967295);
         _loc10_ = 0;
         while(_loc10_ < _loc4_ - _loc6_)
         {
            _loc5_ = uint(crcTable[(_loc5_ ^ param1.readUnsignedByte()) & 0xFF] ^ uint(_loc5_ >>> 8));
            _loc10_++;
         }
         _loc5_ ^= 4294967295;
         param1.position = _loc4_;
         param1.writeUnsignedInt(_loc5_);
      }
   }
}

