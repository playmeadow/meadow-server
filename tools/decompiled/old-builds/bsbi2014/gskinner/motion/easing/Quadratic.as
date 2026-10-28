package gskinner.motion.easing
{
   public class Quadratic
   {
      
      public function Quadratic()
      {
         super();
      }
      
      public static function easeIn(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         return ratio * ratio;
      }
      
      public static function easeOut(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         return -ratio * (ratio - 2);
      }
      
      public static function easeInOut(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         return ratio < 0.5 ? 2 * ratio * ratio : -2 * ratio * (ratio - 2) - 1;
      }
   }
}

