package com.sbi.corelib.math
{
   import flash.geom.Point;
   
   public class Collision
   {
      
      public function Collision()
      {
         super();
      }
      
      public static function segIntersection(param1:Point, param2:Point, param3:Point, param4:Point) : Point
      {
         var _loc5_:Number = param2.x - param1.x;
         var _loc6_:Number = param2.y - param1.y;
         var _loc7_:Number = param4.x - param3.x;
         var _loc8_:Number = param4.y - param3.y;
         var _loc9_:Number = _loc5_ * _loc8_ - _loc6_ * _loc7_;
         if(_loc9_ == 0)
         {
            return null;
         }
         var _loc10_:Number = param3.x - param1.x;
         var _loc11_:Number = param3.y - param1.y;
         var _loc12_:Number = (_loc10_ * _loc8_ - _loc11_ * _loc7_) / _loc9_;
         if(_loc12_ < 0 || _loc12_ > 1)
         {
            return null;
         }
         var _loc13_:Number = (_loc10_ * _loc6_ - _loc11_ * _loc5_) / _loc9_;
         if(_loc13_ < 0 || _loc13_ > 1)
         {
            return null;
         }
         return new Point(param1.x + _loc12_ * _loc5_,param1.y + _loc12_ * _loc6_);
      }
      
      public static function circleHitCircle(param1:Point, param2:Number, param3:Point, param4:Number) : Boolean
      {
         var _loc5_:Point = param3.subtract(param1);
         var _loc6_:Number = _loc5_.x * _loc5_.x + _loc5_.y * _loc5_.y;
         return Boolean(_loc6_ < (param2 + param4) * (param2 + param4));
      }
      
      public static function pointHitCircle(param1:Point, param2:Point, param3:Number) : Boolean
      {
         var _loc4_:Point = param1.subtract(param2);
         var _loc5_:Number = _loc4_.x * _loc4_.x + _loc4_.y * _loc4_.y;
         return Boolean(_loc5_ < param3 * param3);
      }
      
      public static function movingCircleVsRay(param1:Point, param2:Number, param3:Point, param4:Number, param5:Point, param6:Point) : Number
      {
         var _loc9_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Point = null;
         var _loc23_:Point = null;
         var _loc24_:Point = null;
         var _loc7_:Point = param6.subtract(param5);
         var _loc8_:Point = param1.subtract(param5);
         var _loc10_:Point = new Point();
         var _loc11_:Point = new Point(param3.x * param4,param3.y * param4);
         var _loc12_:Number = param3.x * param3.y;
         var _loc13_:Number;
         var _loc14_:Number = _loc13_ = _loc11_.x * _loc7_.y - _loc11_.y * _loc7_.x;
         if(_loc14_ == 0)
         {
            _loc9_ = _loc8_.x * _loc7_.x + _loc8_.y * _loc7_.y;
            _loc10_.x = _loc8_.x - _loc7_.x * _loc9_;
            _loc10_.y = _loc8_.y - _loc7_.y * _loc9_;
            param4 = 0;
            return _loc10_.x * _loc10_.y <= param2 ? -1 : 1;
         }
         _loc13_ /= _loc14_;
         _loc9_ = 0;
         if(_loc9_ <= param2)
         {
            _loc15_ = _loc8_.x * _loc7_.y - _loc8_.y * _loc7_.x;
            _loc16_ = -(_loc15_ * _loc13_) / _loc14_;
            _loc17_ = -(_loc13_ * _loc7_.y);
            _loc18_ = _loc13_ * _loc7_.x;
            _loc19_ = _loc17_ * _loc17_ + _loc18_ * _loc18_;
            if(_loc19_)
            {
               _loc19_ = Math.sqrt(_loc19_);
               _loc17_ /= _loc19_;
               _loc18_ /= _loc19_;
            }
            _loc20_ = Math.abs(param2 / (_loc11_.x * _loc17_ + _loc11_.y * _loc18_));
            if(_loc16_ < -_loc20_)
            {
               return -1;
            }
            if(_loc16_ - _loc20_ > 1)
            {
               return -1;
            }
            _loc21_ = _loc16_ - _loc20_ < 0 ? 0 : _loc16_ - _loc20_;
            _loc22_ = new Point(param1.x + param3.x * _loc21_,param1.y + param3.y * _loc21_);
            _loc23_ = _loc22_.subtract(param5);
            _loc24_ = _loc22_.subtract(param6);
            if(_loc23_.x * _loc7_.x + _loc23_.y * _loc7_.y < 0)
            {
               return Ray_Vs_Sphere(param1,param3,param4,param5,param2);
            }
            if(_loc24_.x * _loc7_.x + _loc24_.y * _loc7_.y > 0)
            {
               return Ray_Vs_Sphere(param1,param3,param4,param6,param2);
            }
            return _loc21_;
         }
         return -1;
      }
      
      public static function rayHitCircle(param1:Point, param2:Number, param3:Point, param4:Point) : Boolean
      {
         var _loc5_:Point = param1.subtract(param3);
         var _loc6_:Point = param4.subtract(param3);
         var _loc7_:Number = (_loc5_.x * _loc6_.x + _loc5_.y * _loc6_.y) / (_loc6_.x * _loc6_.x + _loc6_.y * _loc6_.y);
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         if(_loc7_ > 1)
         {
            _loc7_ = 1;
         }
         var _loc8_:Point = new Point(param3.x + _loc7_ * _loc6_.x,param3.y + _loc7_ * _loc6_.y);
         var _loc9_:Point = param1.subtract(_loc8_);
         var _loc10_:Number = _loc9_.x * _loc9_.x + _loc9_.y * _loc9_.y;
         return Boolean(_loc10_ <= param2 * param2);
      }
      
      public static function Ray_Vs_Sphere(param1:Point, param2:Point, param3:Number, param4:Point, param5:Number) : Number
      {
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Point = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc6_:Number = param5 * param5;
         var _loc7_:Point = param4.subtract(param1);
         var _loc8_:Number = _loc7_.x * _loc7_.x + _loc7_.y * _loc7_.y;
         var _loc9_:Point = new Point(param2.x * param3,param2.y * param3);
         var _loc10_:Point = _loc9_.add(param1);
         var _loc11_:Number = _loc9_.x * _loc7_.x + _loc9_.y * _loc7_.y;
         var _loc12_:Point = param4.subtract(_loc10_);
         var _loc13_:Number = _loc9_.x * _loc12_.x + _loc9_.y * _loc12_.y;
         var _loc14_:Number = (_loc12_.x + _loc12_.y) * (_loc12_.x + _loc12_.y);
         var _loc15_:Number = _loc9_.x * _loc7_.y - _loc9_.y * _loc7_.x;
         var _loc16_:Number = _loc15_ * _loc15_;
         var _loc17_:Number = _loc9_.x * _loc9_.x + _loc9_.y * _loc9_.y;
         if(_loc11_ > 0 && (_loc13_ < 0 || _loc14_ < _loc6_) && _loc16_ < _loc6_ * _loc17_ && _loc17_ > 0.00001)
         {
            _loc18_ = Math.sqrt(_loc6_ - _loc16_ / _loc17_);
            _loc19_ = Math.sqrt(_loc17_);
            _loc20_ = 1 / _loc19_;
            _loc21_ = new Point(_loc9_.x * _loc20_,_loc9_.y * _loc20_);
            _loc22_ = _loc21_.x * _loc7_.x + _loc21_.y * _loc7_.y;
            _loc23_ = param3 * (_loc22_ - _loc18_) * _loc20_;
            return _loc23_ < 0 ? 0 : _loc23_;
         }
         if(_loc8_ < _loc6_)
         {
            return 0;
         }
         return -1;
      }
   }
}

