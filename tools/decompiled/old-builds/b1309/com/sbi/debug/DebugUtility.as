package com.sbi.debug
{
   import com.carlcalderon.arthropod.Debug;
   import flash.display.DisplayObjectContainer;
   
   public class DebugUtility
   {
      
      private static var _debugStrings:Vector.<String> = new Vector.<String>();
      
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
      
      public static function getTrackedDebugStatements() : String
      {
         if(_debugStrings.length >= 5)
         {
            _debugStrings = _debugStrings.slice(_debugStrings.length - 5);
         }
         return _debugStrings.join("\n");
      }
      
      private static function keepTrackOf(param1:String) : void
      {
         if(param1.charAt(param1.length - 1) == "\n")
         {
            param1 = param1.substr(0,param1.length - 2);
         }
         if(_debugStrings.length >= 100)
         {
            _debugStrings = _debugStrings.slice(95);
         }
         else
         {
            _debugStrings.push(param1);
         }
      }
   }
}

