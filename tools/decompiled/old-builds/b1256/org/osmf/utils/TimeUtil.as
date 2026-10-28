package org.osmf.utils
{
   public class TimeUtil
   {
      
      public function TimeUtil()
      {
         super();
      }
      
      public static function parseTime(param1:String) : Number
      {
         var _loc4_:int = 0;
         var _loc2_:Number = 0;
         var _loc3_:Array = param1.split(":");
         if(_loc3_.length > 1)
         {
            _loc2_ = _loc3_[0] * 3600;
            _loc2_ += _loc3_[1] * 60;
            _loc2_ += Number(_loc3_[2]);
         }
         else
         {
            _loc4_ = 0;
            switch(param1.charAt(param1.length - 1))
            {
               case "h":
                  _loc4_ = 3600;
                  break;
               case "m":
                  _loc4_ = 60;
                  break;
               case "s":
                  _loc4_ = 1;
            }
            if(_loc4_)
            {
               _loc2_ = Number(param1.substr(0,param1.length - 1)) * _loc4_;
            }
            else
            {
               _loc2_ = Number(param1);
            }
         }
         return _loc2_;
      }
      
      public static function formatAsTimeCode(param1:Number) : String
      {
         var _loc4_:Number = Math.floor(param1 / 3600);
         _loc4_ = isNaN(_loc4_) ? 0 : _loc4_;
         var _loc3_:Number = Math.floor(param1 % 3600 / 60);
         _loc3_ = isNaN(_loc3_) ? 0 : _loc3_;
         var _loc2_:Number = Math.floor(param1 % 3600 % 60);
         _loc2_ = isNaN(_loc2_) ? 0 : _loc2_;
         return (_loc4_ == 0 ? "" : (_loc4_ < 10 ? "0" + _loc4_.toString() + ":" : _loc4_.toString() + ":")) + (_loc3_ < 10 ? "0" + _loc3_.toString() : _loc3_.toString()) + ":" + (_loc2_ < 10 ? "0" + _loc2_.toString() : _loc2_.toString());
      }
   }
}

