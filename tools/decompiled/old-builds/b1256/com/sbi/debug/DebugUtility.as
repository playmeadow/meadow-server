package com.sbi.debug
{
   import com.carlcalderon.arthropod.Debug;
   import flash.display.DisplayObjectContainer;
   
   public class DebugUtility
   {
      
      public function DebugUtility()
      {
         super();
      }
      
      public static function debugTrace(param1:String, param2:uint = 16711422) : void
      {
         trace(param1);
         Debug.log(param1,param2);
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
   }
}

