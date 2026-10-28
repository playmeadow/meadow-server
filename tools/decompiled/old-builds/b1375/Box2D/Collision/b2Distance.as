package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Distance
   {
      
      public static var g_GJK_Iterations:int = 0;
      
      private static var s_p1s:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var s_p2s:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var s_points:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2()];
      
      private static var gPoint:b2Point = new b2Point();
      
      public function b2Distance()
      {
         super();
      }
      
      public static function ProcessTwo(param1:b2Vec2, param2:b2Vec2, param3:Array, param4:Array, param5:Array) : int
      {
         var _loc6_:b2Vec2 = param5[0];
         var _loc7_:b2Vec2 = param5[1];
         var _loc15_:b2Vec2 = param3[0];
         var _loc17_:b2Vec2 = param3[1];
         var _loc16_:b2Vec2 = param4[0];
         var _loc14_:b2Vec2 = param4[1];
         var _loc12_:Number = -_loc7_.x;
         var _loc13_:Number = -_loc7_.y;
         var _loc9_:Number = _loc6_.x - _loc7_.x;
         var _loc8_:Number = _loc6_.y - _loc7_.y;
         var _loc11_:Number = Math.sqrt(_loc9_ * _loc9_ + _loc8_ * _loc8_);
         _loc9_ /= _loc11_;
         _loc8_ /= _loc11_;
         var _loc10_:Number = _loc12_ * _loc9_ + _loc13_ * _loc8_;
         if(_loc10_ <= 0 || _loc11_ < Number.MIN_VALUE)
         {
            param1.SetV(_loc17_);
            param2.SetV(_loc14_);
            _loc15_.SetV(_loc17_);
            _loc16_.SetV(_loc14_);
            _loc6_.SetV(_loc7_);
            return 1;
         }
         _loc10_ /= _loc11_;
         param1.x = _loc17_.x + _loc10_ * (_loc15_.x - _loc17_.x);
         param1.y = _loc17_.y + _loc10_ * (_loc15_.y - _loc17_.y);
         param2.x = _loc14_.x + _loc10_ * (_loc16_.x - _loc14_.x);
         param2.y = _loc14_.y + _loc10_ * (_loc16_.y - _loc14_.y);
         return 2;
      }
      
      public static function ProcessThree(param1:b2Vec2, param2:b2Vec2, param3:Array, param4:Array, param5:Array) : int
      {
         var _loc16_:Number = NaN;
         var _loc6_:b2Vec2 = param5[0];
         var _loc8_:b2Vec2 = param5[1];
         var _loc10_:b2Vec2 = param5[2];
         var _loc37_:b2Vec2 = param3[0];
         var _loc39_:b2Vec2 = param3[1];
         var _loc40_:b2Vec2 = param3[2];
         var _loc36_:b2Vec2 = param4[0];
         var _loc35_:b2Vec2 = param4[1];
         var _loc41_:b2Vec2 = param4[2];
         var _loc14_:Number = _loc6_.x;
         var _loc9_:Number = _loc6_.y;
         var _loc29_:Number = _loc8_.x;
         var _loc27_:Number = _loc8_.y;
         var _loc11_:Number = _loc10_.x;
         var _loc13_:Number = _loc10_.y;
         var _loc33_:Number = _loc29_ - _loc14_;
         var _loc38_:Number = _loc27_ - _loc9_;
         var _loc19_:Number = _loc11_ - _loc14_;
         var _loc18_:Number = _loc13_ - _loc9_;
         var _loc21_:Number = _loc11_ - _loc29_;
         var _loc17_:Number = _loc13_ - _loc27_;
         var _loc24_:Number = -(_loc14_ * _loc33_ + _loc9_ * _loc38_);
         var _loc26_:Number = _loc29_ * _loc33_ + _loc27_ * _loc38_;
         var _loc7_:Number = -(_loc14_ * _loc19_ + _loc9_ * _loc18_);
         var _loc12_:Number = _loc11_ * _loc19_ + _loc13_ * _loc18_;
         var _loc28_:Number = -(_loc29_ * _loc21_ + _loc27_ * _loc17_);
         var _loc34_:Number = _loc11_ * _loc21_ + _loc13_ * _loc17_;
         if(_loc12_ <= 0 && _loc34_ <= 0)
         {
            param1.SetV(_loc40_);
            param2.SetV(_loc41_);
            _loc37_.SetV(_loc40_);
            _loc36_.SetV(_loc41_);
            _loc6_.SetV(_loc10_);
            return 1;
         }
         var _loc25_:Number = _loc33_ * _loc18_ - _loc38_ * _loc19_;
         var _loc20_:Number = _loc25_ * (_loc14_ * _loc27_ - _loc9_ * _loc29_);
         var _loc23_:Number = _loc25_ * (_loc29_ * _loc13_ - _loc27_ * _loc11_);
         if(_loc23_ <= 0 && _loc28_ >= 0 && _loc34_ >= 0 && _loc28_ + _loc34_ > 0)
         {
            _loc16_ = _loc28_ / (_loc28_ + _loc34_);
            param1.x = _loc39_.x + _loc16_ * (_loc40_.x - _loc39_.x);
            param1.y = _loc39_.y + _loc16_ * (_loc40_.y - _loc39_.y);
            param2.x = _loc35_.x + _loc16_ * (_loc41_.x - _loc35_.x);
            param2.y = _loc35_.y + _loc16_ * (_loc41_.y - _loc35_.y);
            _loc37_.SetV(_loc40_);
            _loc36_.SetV(_loc41_);
            _loc6_.SetV(_loc10_);
            return 2;
         }
         var _loc22_:Number = _loc25_ * (_loc11_ * _loc9_ - _loc13_ * _loc14_);
         if(_loc22_ <= 0 && _loc7_ >= 0 && _loc12_ >= 0 && _loc7_ + _loc12_ > 0)
         {
            _loc16_ = _loc7_ / (_loc7_ + _loc12_);
            param1.x = _loc37_.x + _loc16_ * (_loc40_.x - _loc37_.x);
            param1.y = _loc37_.y + _loc16_ * (_loc40_.y - _loc37_.y);
            param2.x = _loc36_.x + _loc16_ * (_loc41_.x - _loc36_.x);
            param2.y = _loc36_.y + _loc16_ * (_loc41_.y - _loc36_.y);
            _loc39_.SetV(_loc40_);
            _loc35_.SetV(_loc41_);
            _loc8_.SetV(_loc10_);
            return 2;
         }
         var _loc15_:Number = _loc23_ + _loc22_ + _loc20_;
         _loc15_ = 1 / _loc15_;
         var _loc32_:Number = _loc23_ * _loc15_;
         var _loc31_:Number = _loc22_ * _loc15_;
         var _loc30_:Number = 1 - _loc32_ - _loc31_;
         param1.x = _loc32_ * _loc37_.x + _loc31_ * _loc39_.x + _loc30_ * _loc40_.x;
         param1.y = _loc32_ * _loc37_.y + _loc31_ * _loc39_.y + _loc30_ * _loc40_.y;
         param2.x = _loc32_ * _loc36_.x + _loc31_ * _loc35_.x + _loc30_ * _loc41_.x;
         param2.y = _loc32_ * _loc36_.y + _loc31_ * _loc35_.y + _loc30_ * _loc41_.y;
         return 3;
      }
      
      public static function InPoints(param1:b2Vec2, param2:Array, param3:int) : Boolean
      {
         var _loc10_:int = 0;
         var _loc7_:b2Vec2 = null;
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = 100 * Number.MIN_VALUE;
         _loc10_ = 0;
         while(_loc10_ < param3)
         {
            _loc7_ = param2[_loc10_];
            _loc6_ = Math.abs(param1.x - _loc7_.x);
            _loc5_ = Math.abs(param1.y - _loc7_.y);
            _loc4_ = Math.max(Math.abs(param1.x),Math.abs(_loc7_.x));
            _loc9_ = Math.max(Math.abs(param1.y),Math.abs(_loc7_.y));
            if(_loc6_ < _loc8_ * (_loc4_ + 1) && _loc5_ < _loc8_ * (_loc9_ + 1))
            {
               return true;
            }
            _loc10_++;
         }
         return false;
      }
      
      public static function DistanceGeneric(param1:b2Vec2, param2:b2Vec2, param3:*, param4:b2XForm, param5:*, param6:b2XForm) : Number
      {
         var _loc11_:b2Vec2 = null;
         var _loc9_:int = 0;
         _loc9_ = 20;
         var _loc22_:int = 0;
         var _loc20_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc10_:b2Vec2 = null;
         var _loc13_:b2Vec2 = null;
         var _loc15_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc12_:int = 0;
         var _loc17_:Array = s_p1s;
         var _loc16_:Array = s_p2s;
         var _loc21_:Array = s_points;
         var _loc23_:int = 0;
         param1.SetV(param3.GetFirstVertex(param4));
         param2.SetV(param5.GetFirstVertex(param6));
         var _loc8_:Number = 0;
         _loc22_ = 0;
         while(_loc22_ < 20)
         {
            _loc20_ = param2.x - param1.x;
            _loc19_ = param2.y - param1.y;
            _loc10_ = param3.Support(param4,_loc20_,_loc19_);
            _loc13_ = param5.Support(param6,-_loc20_,-_loc19_);
            _loc8_ = _loc20_ * _loc20_ + _loc19_ * _loc19_;
            _loc15_ = _loc13_.x - _loc10_.x;
            _loc18_ = _loc13_.y - _loc10_.y;
            _loc14_ = _loc20_ * _loc15_ + _loc19_ * _loc18_;
            if(_loc8_ - _loc14_ <= 0.01 * _loc8_)
            {
               if(_loc23_ == 0)
               {
                  param1.SetV(_loc10_);
                  param2.SetV(_loc13_);
               }
               g_GJK_Iterations = _loc22_;
               return Math.sqrt(_loc8_);
            }
            switch(_loc23_)
            {
               case 0:
                  _loc11_ = _loc17_[0];
                  _loc11_.SetV(_loc10_);
                  _loc11_ = _loc16_[0];
                  _loc11_.SetV(_loc13_);
                  _loc11_ = _loc21_[0];
                  _loc11_.x = _loc15_;
                  _loc11_.y = _loc18_;
                  param1.SetV(_loc17_[0]);
                  param2.SetV(_loc16_[0]);
                  _loc23_++;
                  break;
               case 1:
                  _loc11_ = _loc17_[1];
                  _loc11_.SetV(_loc10_);
                  _loc11_ = _loc16_[1];
                  _loc11_.SetV(_loc13_);
                  _loc11_ = _loc21_[1];
                  _loc11_.x = _loc15_;
                  _loc11_.y = _loc18_;
                  _loc23_ = ProcessTwo(param1,param2,_loc17_,_loc16_,_loc21_);
                  break;
               case 2:
                  _loc11_ = _loc17_[2];
                  _loc11_.SetV(_loc10_);
                  _loc11_ = _loc16_[2];
                  _loc11_.SetV(_loc13_);
                  _loc11_ = _loc21_[2];
                  _loc11_.x = _loc15_;
                  _loc11_.y = _loc18_;
                  _loc23_ = ProcessThree(param1,param2,_loc17_,_loc16_,_loc21_);
            }
            if(_loc23_ == 3)
            {
               g_GJK_Iterations = _loc22_;
               return 0;
            }
            _loc7_ = -1.7976931348623157e+308;
            _loc12_ = 0;
            while(_loc12_ < _loc23_)
            {
               _loc11_ = _loc21_[_loc12_];
               _loc7_ = b2Math.b2Max(_loc7_,_loc11_.x * _loc11_.x + _loc11_.y * _loc11_.y);
               _loc12_++;
            }
            if(_loc23_ == 3 || _loc8_ <= 100 * Number.MIN_VALUE * _loc7_)
            {
               g_GJK_Iterations = _loc22_;
               _loc20_ = param2.x - param1.x;
               _loc19_ = param2.y - param1.y;
               _loc8_ = _loc20_ * _loc20_ + _loc19_ * _loc19_;
               return Math.sqrt(_loc8_);
            }
            _loc22_++;
         }
         g_GJK_Iterations = 20;
         return Math.sqrt(_loc8_);
      }
      
      public static function DistanceCC(param1:b2Vec2, param2:b2Vec2, param3:b2CircleShape, param4:b2XForm, param5:b2CircleShape, param6:b2XForm) : Number
      {
         var _loc16_:b2Mat22 = null;
         var _loc10_:b2Vec2 = null;
         var _loc20_:Number = NaN;
         var _loc11_:Number = NaN;
         _loc16_ = param4.R;
         _loc10_ = param3.m_localPosition;
         var _loc12_:Number = param4.position.x + (_loc16_.col1.x * _loc10_.x + _loc16_.col2.x * _loc10_.y);
         var _loc19_:Number = param4.position.y + (_loc16_.col1.y * _loc10_.x + _loc16_.col2.y * _loc10_.y);
         _loc16_ = param6.R;
         _loc10_ = param5.m_localPosition;
         var _loc15_:Number = param6.position.x + (_loc16_.col1.x * _loc10_.x + _loc16_.col2.x * _loc10_.y);
         var _loc13_:Number = param6.position.y + (_loc16_.col1.y * _loc10_.x + _loc16_.col2.y * _loc10_.y);
         var _loc9_:Number = _loc15_ - _loc12_;
         var _loc8_:Number = _loc13_ - _loc19_;
         var _loc7_:Number = _loc9_ * _loc9_ + _loc8_ * _loc8_;
         var _loc17_:Number = param3.m_radius - 0.04;
         var _loc18_:Number = param5.m_radius - 0.04;
         var _loc14_:Number = _loc17_ + _loc18_;
         if(_loc7_ > _loc14_ * _loc14_)
         {
            _loc20_ = Math.sqrt(_loc7_);
            _loc9_ /= _loc20_;
            _loc8_ /= _loc20_;
            _loc11_ = _loc20_ - _loc14_;
            param1.x = _loc12_ + _loc17_ * _loc9_;
            param1.y = _loc19_ + _loc17_ * _loc8_;
            param2.x = _loc15_ - _loc18_ * _loc9_;
            param2.y = _loc13_ - _loc18_ * _loc8_;
            return _loc11_;
         }
         if(_loc7_ > Number.MIN_VALUE * Number.MIN_VALUE)
         {
            _loc20_ = Math.sqrt(_loc7_);
            _loc9_ /= _loc20_;
            _loc8_ /= _loc20_;
            param1.x = _loc12_ + _loc17_ * _loc9_;
            param1.y = _loc19_ + _loc17_ * _loc8_;
            param2.x = param1.x;
            param2.y = param1.y;
            return 0;
         }
         param1.x = _loc12_;
         param1.y = _loc19_;
         param2.x = param1.x;
         param2.y = param1.y;
         return 0;
      }
      
      public static function DistancePC(param1:b2Vec2, param2:b2Vec2, param3:b2PolygonShape, param4:b2XForm, param5:b2CircleShape, param6:b2XForm) : Number
      {
         var _loc13_:b2Mat22 = null;
         var _loc9_:b2Vec2 = null;
         var _loc8_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc10_:b2Point = gPoint;
         _loc9_ = param5.m_localPosition;
         _loc13_ = param6.R;
         _loc10_.p.x = param6.position.x + (_loc13_.col1.x * _loc9_.x + _loc13_.col2.x * _loc9_.y);
         _loc10_.p.y = param6.position.y + (_loc13_.col1.y * _loc9_.x + _loc13_.col2.y * _loc9_.y);
         var _loc11_:Number = DistanceGeneric(param1,param2,param3,param4,_loc10_,b2Math.b2XForm_identity);
         var _loc12_:Number = param5.m_radius - 0.04;
         if(_loc11_ > _loc12_)
         {
            _loc11_ -= _loc12_;
            _loc8_ = param2.x - param1.x;
            _loc7_ = param2.y - param1.y;
            _loc14_ = Math.sqrt(_loc8_ * _loc8_ + _loc7_ * _loc7_);
            _loc8_ /= _loc14_;
            _loc7_ /= _loc14_;
            param2.x -= _loc12_ * _loc8_;
            param2.y -= _loc12_ * _loc7_;
         }
         else
         {
            _loc11_ = 0;
            param2.x = param1.x;
            param2.y = param1.y;
         }
         return _loc11_;
      }
      
      public static function Distance(param1:b2Vec2, param2:b2Vec2, param3:b2Shape, param4:b2XForm, param5:b2Shape, param6:b2XForm) : Number
      {
         var _loc7_:int = param3.m_type;
         var _loc8_:int = param5.m_type;
         if(_loc7_ == 0 && _loc8_ == 0)
         {
            return DistanceCC(param1,param2,param3 as b2CircleShape,param4,param5 as b2CircleShape,param6);
         }
         if(_loc7_ == 1 && _loc8_ == 0)
         {
            return DistancePC(param1,param2,param3 as b2PolygonShape,param4,param5 as b2CircleShape,param6);
         }
         if(_loc7_ == 0 && _loc8_ == 1)
         {
            return DistancePC(param2,param1,param5 as b2PolygonShape,param6,param3 as b2CircleShape,param4);
         }
         if(_loc7_ == 1 && _loc8_ == 1)
         {
            return DistanceGeneric(param1,param2,param3 as b2PolygonShape,param4,param5 as b2PolygonShape,param6);
         }
         return 0;
      }
   }
}

