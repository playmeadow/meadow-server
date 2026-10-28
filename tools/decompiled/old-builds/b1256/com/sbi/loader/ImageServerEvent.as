package com.sbi.loader
{
   import flash.events.Event;
   
   public class ImageServerEvent extends Event
   {
      
      public static const ON_NEW_DATA:String = "OnNewData";
      
      public static const ON_GLOBAL_PALETTE:String = "OnGlobalPalette";
      
      public var id:uint;
      
      public var layer:int;
      
      public var imageData:*;
      
      public var versionNum:int;
      
      public var genericData:*;
      
      public var frames:int;
      
      public var success:Boolean = true;
      
      public function ImageServerEvent(param1:String)
      {
         super(param1);
      }
      
      override public function clone() : Event
      {
         return new ImageServerEvent(type);
      }
   }
}

