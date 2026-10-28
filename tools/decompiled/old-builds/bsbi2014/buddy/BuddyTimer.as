package buddy
{
   import flash.utils.Timer;
   
   public class BuddyTimer extends Timer
   {
      
      public var userName:String;
      
      public function BuddyTimer(delay:Number, repeatCount:int = 0)
      {
         super(delay,repeatCount);
      }
   }
}

