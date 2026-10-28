package com.carlcalderon.arthropod
{
   import flash.display.BitmapData;
   import flash.display.Stage;
   import flash.events.StatusEvent;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.net.LocalConnection;
   import flash.system.System;
   
   public class Debug
   {
      
      public static const NAME:String = "Debug";
      
      public static const VERSION:String = "0.74";
      
      public static var password:String = "CDC309AF";
      
      public static var RED:uint = 13369344;
      
      public static var GREEN:uint = 52224;
      
      public static var BLUE:uint = 6710988;
      
      public static var PINK:uint = 13369548;
      
      public static var YELLOW:uint = 13421568;
      
      public static var LIGHT_BLUE:uint = 52428;
      
      public static var ignoreStatus:Boolean = true;
      
      public static var secure:Boolean = false;
      
      public static var secureDomain:String = "*";
      
      public static var allowLog:Boolean = true;
      
      private static const DOMAIN:String = "com.carlcalderon.Arthropod";
      
      private static const CHECK:String = ".161E714B6C1A76DE7B9865F88B32FCCE8FABA7B5.1";
      
      private static const TYPE:String = "app";
      
      private static const CONNECTION:String = "arthropod";
      
      private static const LOG_OPERATION:String = "debug";
      
      private static const ERROR_OPERATION:String = "debugError";
      
      private static const WARNING_OPERATION:String = "debugWarning";
      
      private static const ARRAY_OPERATION:String = "debugArray";
      
      private static const BITMAP_OPERATION:String = "debugBitmapData";
      
      private static const OBJECT_OPERATION:String = "debugObject";
      
      private static const MEMORY_OPERATION:String = "debugMemory";
      
      private static const CLEAR_OPERATION:String = "debugClear";
      
      private static var hasEventListeners:Boolean = false;
      
      private static var lc:LocalConnection = new LocalConnection();
      
      public function Debug()
      {
         super();
      }
      
      public static function log(param1:*, param2:uint = 16711422) : Boolean
      {
         return send("debug",String(param1),param2);
      }
      
      public static function error(param1:*) : Boolean
      {
         return send("debugError",String(param1),13369344);
      }
      
      public static function warning(param1:*) : Boolean
      {
         return send("debugWarning",String(param1),13421568);
      }
      
      public static function clear() : Boolean
      {
         return send("debugClear",0,0);
      }
      
      public static function array(param1:Array) : Boolean
      {
         return send("debugArray",param1,null);
      }
      
      public static function bitmap(param1:*, param2:String = null) : Boolean
      {
         var _loc6_:BitmapData = new BitmapData(100,100,true,16777215);
         var _loc3_:Matrix = new Matrix();
         var _loc4_:Number = 100 / (param1.width >= param1.height ? param1.width : param1.height);
         _loc3_.scale(_loc4_,_loc4_);
         _loc6_.draw(param1,_loc3_,null,null,null,true);
         var _loc5_:Rectangle = new Rectangle(0,0,Math.floor(param1.width * _loc4_),Math.floor(param1.height * _loc4_));
         return send("debugBitmapData",_loc6_.getPixels(_loc5_),{
            "bounds":_loc5_,
            "lbl":param2
         });
      }
      
      public static function snapshot(param1:Stage, param2:String = null) : Boolean
      {
         if(param1)
         {
            return bitmap(param1,param2);
         }
         return false;
      }
      
      public static function object(param1:*) : Boolean
      {
         return send("debugObject",param1,null);
      }
      
      public static function memory() : Boolean
      {
         return send("debugMemory",System.totalMemory,null);
      }
      
      private static function send(param1:String, param2:*, param3:*) : Boolean
      {
         if(!secure)
         {
            lc.allowInsecureDomain("*");
         }
         else
         {
            lc.allowDomain(secureDomain);
         }
         if(!hasEventListeners)
         {
            if(ignoreStatus)
            {
               lc.addEventListener("status",ignore);
            }
            else
            {
               lc.addEventListener("status",status);
            }
            hasEventListeners = true;
         }
         if(allowLog)
         {
            try
            {
               lc.send("app#com.carlcalderon.Arthropod.161E714B6C1A76DE7B9865F88B32FCCE8FABA7B5.1:arthropod",param1,password,param2,param3);
               return true;
            }
            catch(e:*)
            {
               var _loc6_:Boolean = false;
            }
            return _loc6_;
         }
         return false;
      }
      
      private static function status(param1:StatusEvent) : void
      {
         trace("Arthropod status:\n" + param1.toString());
      }
      
      private static function ignore(param1:StatusEvent) : void
      {
      }
   }
}

