package gskinner.motion.easing
{
   public class Circular
   {
      
      public function Circular()
      {
         super();
      }
      
      public static function easeIn(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         return -(Math.sqrt(1 - ratio * ratio) - 1);
      }
      
      public static function easeOut(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         return Math.sqrt(1 - (ratio - 1) * (ratio - 1));
      }
      
      public static function easeInOut(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         ratio = ratio * 2;
         return ratio < 1 ? -0.5 * (Math.sqrt(1 - ratio * ratio) - 1) : 0.5 * (Math.sqrt(1 - (ratio = ratio - 2) * ratio) + 1);
      }
   }
}

