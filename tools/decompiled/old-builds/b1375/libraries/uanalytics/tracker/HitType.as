package libraries.uanalytics.tracker
{
   import flash.system.System;
   import flash.utils.describeType;
   
   public class HitType
   {
      
      public static const PAGEVIEW:String = "pageview";
      
      public static const SCREENVIEW:String = "screenview";
      
      public static const EVENT:String = "event";
      
      public static const TRANSACTION:String = "transaction";
      
      public static const ITEM:String = "item";
      
      public static const SOCIAL:String = "social";
      
      public static const EXCEPTION:String = "exception";
      
      public static const TIMING:String = "timing";
      
      public function HitType()
      {
         super();
      }
      
      public static function isValid(param1:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc3_:XML = describeType(HitType);
         var _loc5_:Boolean = false;
         for each(var _loc2_:XML in _loc3_.constant)
         {
            _loc4_ = String(_loc2_.@name);
            if(HitType[_loc4_] == param1)
            {
               _loc5_ = true;
               break;
            }
         }
         System.disposeXML(_loc3_);
         if(_loc5_)
         {
            return true;
         }
         return false;
      }
   }
}

