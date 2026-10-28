package gskinner.motion.easing
{
   public class Linear
   {
      
      public function Linear()
      {
         super();
      }
      
      public static function easeNone(ratio:Number, unused1:Number, unused2:Number, unused3:Number) : Number
      {
         return ratio;
      }
   }
}

