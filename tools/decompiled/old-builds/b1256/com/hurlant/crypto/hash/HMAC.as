package com.hurlant.crypto.hash
{
   import flash.utils.ByteArray;
   
   public class HMAC
   {
      
      private var hash:IHash;
      
      private var bits:uint;
      
      public function HMAC(param1:IHash, param2:uint = 0)
      {
         super();
         this.hash = param1;
         this.bits = param2;
      }
      
      public function getHashSize() : uint
      {
         if(bits != 0)
         {
            return bits / 8;
         }
         return hash.getHashSize();
      }
      
      public function compute(param1:ByteArray, param2:ByteArray) : ByteArray
      {
         var _loc4_:ByteArray = null;
         var _loc8_:* = 0;
         if(param1.length > hash.getInputSize())
         {
            _loc4_ = hash.hash(param1);
         }
         else
         {
            _loc4_ = new ByteArray();
            _loc4_.writeBytes(param1);
         }
         while(_loc4_.length < hash.getInputSize())
         {
            _loc4_[_loc4_.length] = 0;
         }
         var _loc6_:ByteArray = new ByteArray();
         var _loc3_:ByteArray = new ByteArray();
         _loc8_ = 0;
         while(_loc8_ < _loc4_.length)
         {
            _loc6_[_loc8_] = _loc4_[_loc8_] ^ 0x36;
            _loc3_[_loc8_] = _loc4_[_loc8_] ^ 0x5C;
            _loc8_++;
         }
         _loc6_.position = _loc4_.length;
         _loc6_.writeBytes(param2);
         var _loc7_:ByteArray = hash.hash(_loc6_);
         _loc3_.position = _loc4_.length;
         _loc3_.writeBytes(_loc7_);
         var _loc5_:ByteArray = hash.hash(_loc3_);
         if(bits > 0 && bits < 8 * _loc5_.length)
         {
            _loc5_.length = bits / 8;
         }
         return _loc5_;
      }
      
      public function dispose() : void
      {
         hash = null;
         bits = 0;
      }
      
      public function toString() : String
      {
         return "hmac-" + (bits > 0 ? bits + "-" : "") + hash.toString();
      }
   }
}

