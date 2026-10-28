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
      
      public static function debugTrace(d:String, color:uint = 16711422) : void
      {
         trace(d);
         Debug.log(d,color);
      }
      
      public static function debugTraceObject(oName:String, o:Object, lev:int = 0) : void
      {
      }
      
      public static function debugTraceArray(aName:String, a:Array, oneElementPerLineMode:Boolean = false) : void
      {
      }
      
      public static function debugTraceDisplayObjectContainer(docName:String, doc:DisplayObjectContainer, recurse:Boolean = false, lev:int = 0) : void
      {
      }
   }
}

