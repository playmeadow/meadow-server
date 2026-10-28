package com.sbi.debug
{
   import com.carlcalderon.arthropod.Debug;
   import flash.display.DisplayObjectContainer;
   
   public class DebugUtility
   {
      
      private static var _errorTrackingStrings:Vector.<String> = new Vector.<String>();
      
      public function DebugUtility()
      {
         super();
      }
      
      public static function debugTrace(param1:String, param2:uint = 16711422) : void
      {
         trace(param1);
         Debug.log(param1,param2);
         keepTrackOf(param1);
      }
      
      public static function debugTraceObject(param1:String, param2:Object, param3:int = 0) : void
      {
      }
      
      public static function debugTraceArray(param1:String, param2:Array, param3:Boolean = false) : void
      {
      }
      
      public static function debugTraceDisplayObjectContainer(param1:String, param2:DisplayObjectContainer, param3:Boolean = false, param4:int = 0) : void
      {
      }
      
      public static function debugErrorTracking(param1:String) : void
      {
         if(_errorTrackingStrings.length >= 100)
         {
            _errorTrackingStrings = _errorTrackingStrings.slice(95);
         }
         else
         {
            _errorTrackingStrings.push(param1);
         }
      }
      
      public static function clearDebugErrorTracking() : void
      {
         _errorTrackingStrings = new Vector.<String>();
      }
      
      public static function getTrackedDebugStatements() : String
      {
         if(_errorTrackingStrings.length >= 10)
         {
            _errorTrackingStrings = _errorTrackingStrings.slice(_errorTrackingStrings.length - 5);
         }
         return _errorTrackingStrings.join("\n");
      }
      
      private static function keepTrackOf(param1:String) : void
      {
         if(param1.charAt(param1.length - 1) == "\n")
         {
            param1 = param1.substr(0,param1.length - 2);
         }
      }
   }
}

