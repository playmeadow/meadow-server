package org.osmf.elements.f4mClasses
{
   internal class DateUtil
   {
      
      public function DateUtil()
      {
         super();
      }
      
      public static function parseW3CDTF(param1:String) : Date
      {
         var _loc4_:Date = null;
         var _loc9_:String = null;
         var _loc3_:String = null;
         var _loc11_:Array = null;
         var _loc17_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc13_:String = null;
         var _loc20_:Array = null;
         var _loc7_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc15_:Array = null;
         var _loc14_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc12_:String = null;
         try
         {
            _loc9_ = param1.substring(0,param1.indexOf("T"));
            _loc3_ = param1.substring(param1.indexOf("T") + 1,param1.length);
            _loc11_ = _loc9_.split("-");
            _loc17_ = _loc11_.shift();
            _loc16_ = _loc11_.shift();
            _loc8_ = _loc11_.shift();
            if(_loc3_.indexOf("Z") != -1)
            {
               _loc10_ = 1;
               _loc6_ = 0;
               _loc21_ = 0;
               _loc3_ = _loc3_.replace("Z","");
            }
            else if(_loc3_.indexOf("+") != -1)
            {
               _loc10_ = 1;
               _loc13_ = _loc3_.substring(_loc3_.indexOf("+") + 1,_loc3_.length);
               _loc6_ = Number(_loc13_.substring(0,_loc13_.indexOf(":")));
               _loc21_ = Number(_loc13_.substring(_loc13_.indexOf(":") + 1,_loc13_.length));
               _loc3_ = _loc3_.substring(0,_loc3_.indexOf("+"));
            }
            else
            {
               _loc10_ = -1;
               _loc13_ = _loc3_.substring(_loc3_.indexOf("-") + 1,_loc3_.length);
               _loc6_ = Number(_loc13_.substring(0,_loc13_.indexOf(":")));
               _loc21_ = Number(_loc13_.substring(_loc13_.indexOf(":") + 1,_loc13_.length));
               _loc3_ = _loc3_.substring(0,_loc3_.indexOf("-"));
            }
            _loc20_ = _loc3_.split(":");
            _loc7_ = _loc20_.shift();
            _loc2_ = _loc20_.shift();
            _loc15_ = _loc20_.length > 0 ? String(_loc20_.shift()).split(".") : null;
            _loc14_ = _loc15_ != null && _loc15_.length > 0 ? Number(_loc15_.shift()) : 0;
            _loc19_ = _loc15_ != null && _loc15_.length > 0 ? Number(_loc15_.shift()) : 0;
            _loc5_ = Date.UTC(_loc17_,_loc16_ - 1,_loc8_,_loc7_,_loc2_,_loc14_,_loc19_);
            _loc18_ = (_loc6_ * 3600000 + _loc21_ * 60000) * _loc10_;
            _loc4_ = new Date(_loc5_ - _loc18_);
            if(_loc4_.toString() == "Invalid Date")
            {
               throw new Error("This date does not conform to W3CDTF.");
            }
         }
         catch(e:Error)
         {
            _loc12_ = "Unable to parse the string [" + param1 + "] into a date. ";
            _loc12_ = _loc12_ + ("The internal error was: " + e.toString());
            throw new Error(_loc12_);
         }
         return _loc4_;
      }
   }
}

