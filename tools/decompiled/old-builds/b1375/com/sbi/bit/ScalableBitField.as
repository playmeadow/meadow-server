package com.sbi.bit
{
   public class ScalableBitField
   {
      
      private static const MAX_ARRAY_SIZE:uint = 8;
      
      private static const NUM_BITS_PER_BITFIELD:uint = 32;
      
      private var _bitFields:Vector.<BitField>;
      
      public function ScalableBitField(param1:String)
      {
         var _loc3_:* = 0;
         super();
         _bitFields = new Vector.<BitField>();
         var _loc2_:Array = param1.split(",");
         _loc3_ = 0;
         while(_loc3_ < _loc2_.length)
         {
            _bitFields[_loc3_] = new BitField(_loc2_[_loc3_]);
            _loc3_++;
         }
         trim();
      }
      
      public function updateBitField(param1:ScalableBitField, param2:BitWiseOperator) : void
      {
         var _loc5_:* = 0;
         var _loc4_:* = 0;
         if(param2 == BitWiseOperator.NOT)
         {
            _loc5_ = 0;
            while(_loc5_ < _bitFields.length)
            {
               _bitFields[_loc5_].updateBitField(0,param2);
               _loc5_++;
            }
            trim();
            return;
         }
         if(param1 == null)
         {
            throw new Error("Attempted to update bit field with null changes: op:" + param2);
         }
         var _loc3_:uint = param1._bitFields.length;
         if(_loc3_ > _bitFields.length)
         {
            resizeBitFields(_loc3_);
         }
         _loc5_ = 0;
         while(_loc5_ < _bitFields.length)
         {
            _loc4_ = uint(_loc5_ < _loc3_ ? param1._bitFields[_loc5_].getInt() : 0);
            _bitFields[_loc5_].updateBitField(_loc4_,param2);
            _loc5_++;
         }
         trim();
      }
      
      public function setBit(param1:uint, param2:Boolean) : Boolean
      {
         if(param1 < 0)
         {
            throw new Error("ERROR: Attempted to set a negative bit index. bit=" + param1);
         }
         var _loc3_:uint = getArrayIndexForBit(param1);
         if(_loc3_ >= _bitFields.length)
         {
            if(!param2)
            {
               return false;
            }
            resizeBitFields(_loc3_ + 1);
         }
         var _loc4_:Boolean = _bitFields[_loc3_].setBit(getTranslatedBit(param1),param2);
         if(!param2 && _loc4_)
         {
            trim();
         }
         return _loc4_;
      }
      
      public function isBitSet(param1:uint) : Boolean
      {
         if(param1 < 0)
         {
            throw new Error("Attempted to check a negative bit index. bit=" + param1);
         }
         var _loc2_:uint = getArrayIndexForBit(param1);
         return _loc2_ >= _bitFields.length ? false : _bitFields[_loc2_].isBitSet(getTranslatedBit(param1));
      }
      
      private function getArrayIndexForBit(param1:uint) : uint
      {
         return param1 / 32;
      }
      
      private function getTranslatedBit(param1:uint) : uint
      {
         return param1 % 32;
      }
      
      private function trim() : void
      {
         var _loc2_:uint = _bitFields.length - 1;
         while(_loc2_ > 0 && _bitFields[_loc2_].getInt() == 0)
         {
            _loc2_--;
         }
         var _loc1_:uint = _loc2_ + 1;
         if(_loc1_ != _bitFields.length)
         {
            resizeBitFields(_loc1_);
         }
      }
      
      private function resizeBitFields(param1:uint) : void
      {
         var _loc2_:* = 0;
         if(param1 > 8)
         {
            throw new Error("Blocking operation that requires more than 8 elements: " + param1);
         }
         if(param1 < _bitFields.length)
         {
            _bitFields.splice(param1,_bitFields.length);
         }
         else if(param1 > _bitFields.length)
         {
            _loc2_ = _bitFields.length;
            while(_loc2_ < param1)
            {
               _bitFields[_loc2_] = new BitField(0);
               _loc2_++;
            }
         }
      }
   }
}

