package org.osmf.net.dvr
{
   [ExcludeClass]
   public class DVRUtils
   {
      
      public function DVRUtils()
      {
         super();
      }
      
      public static function calculateOffset(beginOffset:Number, endOffset:Number, currentDuration:Number) : Number
      {
         var offset:Number = 0;
         if(endOffset != 0)
         {
            if(currentDuration > endOffset)
            {
               offset = currentDuration - endOffset;
            }
            else
            {
               offset = Math.min(beginOffset,currentDuration);
            }
         }
         else if(beginOffset != 0)
         {
            offset = Math.min(beginOffset,currentDuration);
         }
         return offset;
      }
   }
}

