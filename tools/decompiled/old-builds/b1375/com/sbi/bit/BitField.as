package com.sbi.bit
{
   public class BitField
   {
      
      private var _bitField:uint;
      
      public function BitField(param1:uint = 0)
      {
         super();
         _bitField = param1;
      }
      
      public function updateBitField(param1:uint, param2:BitWiseOperator) : void
      {
         switch(param2)
         {
            case BitWiseOperator.AND:
               _bitField &= param1;
               break;
            case BitWiseOperator.OR:
               _bitField |= param1;
               break;
            case BitWiseOperator.XOR:
               _bitField ^= param1;
               break;
            case BitWiseOperator.NOT:
               _bitField = ~_bitField;
         }
      }
      
      public function setBit(param1:uint, param2:Boolean) : Boolean
      {
         if(param1 < 0 || param1 > 31)
         {
            throw new Error("Attempted to set bit outside of normal range. bit=" + param1);
         }
         var _loc3_:uint = _bitField;
         if(param2)
         {
            _bitField |= 1 << param1;
         }
         else
         {
            _bitField &= ~(1 << param1);
         }
         return _loc3_ != _bitField;
      }
      
      public function isBitSet(param1:uint) : Boolean
      {
         if(param1 < 0 || param1 > 31)
         {
            throw new Error("Attempted to read bit outside of normal range. bit=" + param1);
         }
         return (_bitField & 1 << param1) != 0;
      }
      
      public function getInt() : uint
      {
         return _bitField;
      }
   }
}

