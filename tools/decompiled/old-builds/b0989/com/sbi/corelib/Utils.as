package com.sbi.corelib
{
   import com.sbi.debug.DebugUtility;
   import flash.utils.getDefinitionByName;
   
   public class Utils
   {
      
      public function Utils()
      {
         super();
      }
      
      public static function getDefByName(param1:String) : Class
      {
         var returnClass:Class = null;
         var getClassName:String = param1;
         try
         {
            returnClass = getDefinitionByName(getClassName) as Class;
         }
         catch(re:ReferenceError)
         {
            DebugUtility.debugTrace("WARNING: Missing class definition \"" + getClassName + "\"!");
            returnClass = null;
         }
         return returnClass;
      }
      
      public static function damerauLevenshteinDistance(param1:Array, param2:Array, param3:int) : int
      {
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc4_:int = param1.length + param2.length;
         var _loc5_:SimpleMatrix = new SimpleMatrix(param1.length + 2,param2.length + 2);
         _loc5_[0][0] = _loc4_;
         var _loc6_:int = 0;
         while(_loc6_ <= param1.length)
         {
            _loc5_[_loc6_ + 1][1] = _loc6_;
            _loc5_[_loc6_ + 1][0] = _loc4_;
            _loc6_++;
         }
         var _loc7_:int = 0;
         while(_loc7_ <= param2.length)
         {
            _loc5_[1][_loc7_ + 1] = _loc7_;
            _loc5_[0][_loc7_ + 1] = _loc4_;
            _loc7_++;
         }
         var _loc8_:Array = new Array(param3);
         var _loc9_:int = 0;
         while(_loc9_ < param3)
         {
            _loc8_[_loc9_] = 0;
            _loc9_++;
         }
         var _loc10_:int = 1;
         while(_loc10_ <= param1.length)
         {
            _loc11_ = 0;
            _loc12_ = 1;
            while(_loc12_ <= param2.length)
            {
               _loc13_ = int(_loc8_[param2[_loc12_ - 1]]);
               _loc14_ = _loc11_;
               _loc15_ = param1[_loc10_ - 1] == param2[_loc12_ - 1] ? 0 : 1;
               if(_loc15_ == 0)
               {
                  _loc11_ = _loc12_;
               }
               _loc5_[_loc10_ + 1][_loc12_ + 1] = Math.min(_loc5_[_loc10_][_loc12_] + _loc15_,_loc5_[_loc10_ + 1][_loc12_] + 1,_loc5_[_loc10_][_loc12_ + 1] + 1,_loc5_[_loc13_][_loc14_] + (_loc10_ - _loc13_ - 1) + 1 + (_loc12_ - _loc14_ - 1));
               _loc12_++;
            }
            _loc8_[param1[_loc10_ - 1]] = _loc10_;
            _loc10_++;
         }
         return _loc5_[param1.length + 1][param2.length + 1];
      }
   }
}

dynamic class SimpleMatrix extends Array
{
   
   public var rows:int;
   
   public var cols:int;
   
   public function SimpleMatrix(param1:int = 0, param2:int = -1)
   {
      super(param1);
      if(param2 == -1)
      {
         param2 = param1;
      }
      var _loc3_:int = 0;
      while(_loc3_ < param1)
      {
         this[_loc3_] = new Array(param2);
         _loc3_++;
      }
      this.rows = param1;
      this.cols = param2;
   }
}
