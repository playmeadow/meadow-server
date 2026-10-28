package com.hurlant.crypto.hash
{
   import flash.utils.ByteArray;
   
   public class SHABase implements IHash
   {
      
      public function SHABase()
      {
         super();
      }
      
      public function getInputSize() : uint
      {
         return 64;
      }
      
      public function getHashSize() : uint
      {
         return 0;
      }
      
      public function hash(param1:ByteArray) : ByteArray
      {
         var _loc8_:* = 0;
         var _loc3_:uint = param1.length;
         var _loc9_:String = param1.endian;
         param1.endian = "bigEndian";
         var _loc5_:uint = _loc3_ * 8;
         while(param1.length % 4 != 0)
         {
            param1[param1.length] = 0;
         }
         param1.position = 0;
         var _loc4_:Array = [];
         _loc8_ = 0;
         while(_loc8_ < param1.length)
         {
            _loc4_.push(param1.readUnsignedInt());
            _loc8_ += 4;
         }
         var _loc6_:Array = core(_loc4_,_loc5_);
         var _loc7_:ByteArray = new ByteArray();
         var _loc2_:uint = getHashSize() / 4;
         _loc8_ = 0;
         while(_loc8_ < _loc2_)
         {
            _loc7_.writeUnsignedInt(_loc6_[_loc8_]);
            _loc8_++;
         }
         param1.length = _loc3_;
         param1.endian = _loc9_;
         return _loc7_;
      }
      
      protected function core(param1:Array, param2:uint) : Array
      {
         return null;
      }
      
      public function toString() : String
      {
         return "sha";
      }
   }
}

