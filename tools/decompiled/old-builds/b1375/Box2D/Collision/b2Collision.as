package Box2D.Collision
{
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Collision
   {
      
      public static const b2_nullFeature:uint = 255;
      
      private static var b2CollidePolyTempVec:b2Vec2 = new b2Vec2();
      
      public function b2Collision()
      {
         super();
      }
      
      public static function ClipSegmentToLine(param1:Array, param2:Array, param3:b2Vec2, param4:Number) : int
      {
         var _loc11_:ClipVertex = null;
         var _loc13_:Number = NaN;
         var _loc12_:b2Vec2 = null;
         var _loc6_:ClipVertex = null;
         var _loc8_:int = 0;
         _loc11_ = param2[0];
         var _loc9_:b2Vec2 = _loc11_.v;
         _loc11_ = param2[1];
         var _loc10_:b2Vec2 = _loc11_.v;
         var _loc7_:Number = b2Math.b2Dot(param3,_loc9_) - param4;
         var _loc5_:Number = b2Math.b2Dot(param3,_loc10_) - param4;
         if(_loc7_ <= 0)
         {
            param1[_loc8_++] = param2[0];
         }
         if(_loc5_ <= 0)
         {
            param1[_loc8_++] = param2[1];
         }
         if(_loc7_ * _loc5_ < 0)
         {
            _loc13_ = _loc7_ / (_loc7_ - _loc5_);
            _loc11_ = param1[_loc8_];
            _loc12_ = _loc11_.v;
            _loc12_.x = _loc9_.x + _loc13_ * (_loc10_.x - _loc9_.x);
            _loc12_.y = _loc9_.y + _loc13_ * (_loc10_.y - _loc9_.y);
            _loc11_ = param1[_loc8_];
            if(_loc7_ > 0)
            {
               _loc6_ = param2[0];
               _loc11_.id = _loc6_.id;
            }
            else
            {
               _loc6_ = param2[1];
               _loc11_.id = _loc6_.id;
            }
            _loc8_++;
         }
         return _loc8_;
      }
      
      public static function EdgeSeparation(param1:b2PolygonShape, param2:b2XForm, param3:int, param4:b2PolygonShape, param5:b2XForm) : Number
      {
         var _loc22_:b2Mat22 = null;
         var _loc18_:b2Vec2 = null;
         var _loc19_:int = 0;
         var _loc10_:Number = NaN;
         var _loc24_:int = param1.m_vertexCount;
         var _loc7_:Array = param1.m_vertices;
         var _loc25_:Array = param1.m_normals;
         var _loc23_:int = param4.m_vertexCount;
         var _loc6_:Array = param4.m_vertices;
         _loc22_ = param2.R;
         _loc18_ = _loc25_[param3];
         var _loc15_:Number = _loc22_.col1.x * _loc18_.x + _loc22_.col2.x * _loc18_.y;
         var _loc13_:Number = _loc22_.col1.y * _loc18_.x + _loc22_.col2.y * _loc18_.y;
         _loc22_ = param5.R;
         var _loc8_:Number = _loc22_.col1.x * _loc15_ + _loc22_.col1.y * _loc13_;
         var _loc9_:Number = _loc22_.col2.x * _loc15_ + _loc22_.col2.y * _loc13_;
         var _loc14_:int = 0;
         var _loc17_:Number = 1.7976931348623157e+308;
         _loc19_ = 0;
         while(_loc19_ < _loc23_)
         {
            _loc18_ = _loc6_[_loc19_];
            _loc10_ = _loc18_.x * _loc8_ + _loc18_.y * _loc9_;
            if(_loc10_ < _loc17_)
            {
               _loc17_ = _loc10_;
               _loc14_ = _loc19_;
            }
            _loc19_++;
         }
         _loc18_ = _loc7_[param3];
         _loc22_ = param2.R;
         var _loc20_:Number = param2.position.x + (_loc22_.col1.x * _loc18_.x + _loc22_.col2.x * _loc18_.y);
         var _loc21_:Number = param2.position.y + (_loc22_.col1.y * _loc18_.x + _loc22_.col2.y * _loc18_.y);
         _loc18_ = _loc6_[_loc14_];
         _loc22_ = param5.R;
         var _loc11_:Number = param5.position.x + (_loc22_.col1.x * _loc18_.x + _loc22_.col2.x * _loc18_.y);
         var _loc12_:Number = param5.position.y + (_loc22_.col1.y * _loc18_.x + _loc22_.col2.y * _loc18_.y);
         _loc11_ -= _loc20_;
         _loc12_ -= _loc21_;
         return _loc11_ * _loc15_ + _loc12_ * _loc13_;
      }
      
      public static function FindMaxSeparation(param1:Array, param2:b2PolygonShape, param3:b2XForm, param4:b2PolygonShape, param5:b2XForm) : Number
      {
         var _loc17_:b2Vec2 = null;
         var _loc22_:b2Mat22 = null;
         var _loc18_:int = 0;
         var _loc16_:Number = NaN;
         var _loc14_:int = 0;
         var _loc7_:Number = NaN;
         var _loc6_:int = 0;
         var _loc23_:int = param2.m_vertexCount;
         var _loc25_:Array = param2.m_normals;
         _loc22_ = param5.R;
         _loc17_ = param4.m_centroid;
         var _loc12_:Number = param5.position.x + (_loc22_.col1.x * _loc17_.x + _loc22_.col2.x * _loc17_.y);
         var _loc11_:Number = param5.position.y + (_loc22_.col1.y * _loc17_.x + _loc22_.col2.y * _loc17_.y);
         _loc22_ = param3.R;
         _loc17_ = param2.m_centroid;
         _loc12_ -= param3.position.x + (_loc22_.col1.x * _loc17_.x + _loc22_.col2.x * _loc17_.y);
         _loc11_ -= param3.position.y + (_loc22_.col1.y * _loc17_.x + _loc22_.col2.y * _loc17_.y);
         var _loc13_:Number = _loc12_ * param3.R.col1.x + _loc11_ * param3.R.col1.y;
         var _loc10_:Number = _loc12_ * param3.R.col2.x + _loc11_ * param3.R.col2.y;
         var _loc8_:int = 0;
         var _loc19_:Number = -1.7976931348623157e+308;
         _loc18_ = 0;
         while(_loc18_ < _loc23_)
         {
            _loc17_ = _loc25_[_loc18_];
            _loc16_ = _loc17_.x * _loc13_ + _loc17_.y * _loc10_;
            if(_loc16_ > _loc19_)
            {
               _loc19_ = _loc16_;
               _loc8_ = _loc18_;
            }
            _loc18_++;
         }
         var _loc20_:Number = EdgeSeparation(param2,param3,_loc8_,param4,param5);
         if(_loc20_ > 0)
         {
            return _loc20_;
         }
         var _loc15_:int = _loc8_ - 1 >= 0 ? _loc8_ - 1 : _loc23_ - 1;
         var _loc9_:Number = EdgeSeparation(param2,param3,_loc15_,param4,param5);
         if(_loc9_ > 0)
         {
            return _loc9_;
         }
         var _loc24_:int = _loc8_ + 1 < _loc23_ ? _loc8_ + 1 : 0;
         var _loc21_:Number = EdgeSeparation(param2,param3,_loc24_,param4,param5);
         if(_loc21_ > 0)
         {
            return _loc21_;
         }
         if(_loc9_ > _loc20_ && _loc9_ > _loc21_)
         {
            _loc6_ = -1;
            _loc14_ = _loc15_;
            _loc7_ = _loc9_;
         }
         else
         {
            if(_loc21_ <= _loc20_)
            {
               param1[0] = _loc8_;
               return _loc20_;
            }
            _loc6_ = 1;
            _loc14_ = _loc24_;
            _loc7_ = _loc21_;
         }
         while(true)
         {
            if(_loc6_ == -1)
            {
               _loc8_ = _loc14_ - 1 >= 0 ? _loc14_ - 1 : _loc23_ - 1;
            }
            else
            {
               _loc8_ = _loc14_ + 1 < _loc23_ ? _loc14_ + 1 : 0;
            }
            _loc20_ = EdgeSeparation(param2,param3,_loc8_,param4,param5);
            if(_loc20_ > 0)
            {
               break;
            }
            if(_loc20_ <= _loc7_)
            {
               param1[0] = _loc14_;
               return _loc7_;
            }
            _loc14_ = _loc8_;
            _loc7_ = _loc20_;
         }
         return _loc20_;
      }
      
      public static function FindIncidentEdge(param1:Array, param2:b2PolygonShape, param3:b2XForm, param4:int, param5:b2PolygonShape, param6:b2XForm) : void
      {
         var _loc16_:b2Mat22 = null;
         var _loc13_:b2Vec2 = null;
         var _loc14_:int = 0;
         var _loc12_:Number = NaN;
         var _loc15_:ClipVertex = null;
         var _loc18_:int = param2.m_vertexCount;
         var _loc23_:Array = param2.m_normals;
         var _loc17_:int = param5.m_vertexCount;
         var _loc8_:Array = param5.m_vertices;
         var _loc19_:Array = param5.m_normals;
         _loc16_ = param3.R;
         _loc13_ = _loc23_[param4];
         var _loc9_:Number = _loc16_.col1.x * _loc13_.x + _loc16_.col2.x * _loc13_.y;
         var _loc10_:Number = _loc16_.col1.y * _loc13_.x + _loc16_.col2.y * _loc13_.y;
         _loc16_ = param6.R;
         var _loc21_:Number = _loc16_.col1.x * _loc9_ + _loc16_.col1.y * _loc10_;
         _loc10_ = _loc16_.col2.x * _loc9_ + _loc16_.col2.y * _loc10_;
         _loc9_ = _loc21_;
         var _loc7_:int = 0;
         var _loc11_:Number = 1.7976931348623157e+308;
         _loc14_ = 0;
         while(_loc14_ < _loc17_)
         {
            _loc13_ = _loc19_[_loc14_];
            _loc12_ = _loc9_ * _loc13_.x + _loc10_ * _loc13_.y;
            if(_loc12_ < _loc11_)
            {
               _loc11_ = _loc12_;
               _loc7_ = _loc14_;
            }
            _loc14_++;
         }
         var _loc22_:int = _loc7_;
         var _loc20_:int = _loc22_ + 1 < _loc17_ ? _loc22_ + 1 : 0;
         _loc15_ = param1[0];
         _loc13_ = _loc8_[_loc22_];
         _loc16_ = param6.R;
         _loc15_.v.x = param6.position.x + (_loc16_.col1.x * _loc13_.x + _loc16_.col2.x * _loc13_.y);
         _loc15_.v.y = param6.position.y + (_loc16_.col1.y * _loc13_.x + _loc16_.col2.y * _loc13_.y);
         _loc15_.id.features.referenceEdge = param4;
         _loc15_.id.features.incidentEdge = _loc22_;
         _loc15_.id.features.incidentVertex = 0;
         _loc15_ = param1[1];
         _loc13_ = _loc8_[_loc20_];
         _loc16_ = param6.R;
         _loc15_.v.x = param6.position.x + (_loc16_.col1.x * _loc13_.x + _loc16_.col2.x * _loc13_.y);
         _loc15_.v.y = param6.position.y + (_loc16_.col1.y * _loc13_.x + _loc16_.col2.y * _loc13_.y);
         _loc15_.id.features.referenceEdge = param4;
         _loc15_.id.features.incidentEdge = _loc20_;
         _loc15_.id.features.incidentVertex = 1;
      }
      
      public static function b2CollidePolygons(param1:b2Manifold, param2:b2PolygonShape, param3:b2XForm, param4:b2PolygonShape, param5:b2XForm) : void
      {
         var _loc30_:ClipVertex = null;
         var _loc28_:b2PolygonShape = null;
         var _loc29_:b2PolygonShape = null;
         var _loc13_:int = 0;
         var _loc20_:* = 0;
         var _loc10_:Number = NaN;
         _loc10_ = 0.98;
         var _loc11_:Number = NaN;
         _loc11_ = 0.001;
         var _loc17_:b2Vec2 = null;
         var _loc8_:int = 0;
         var _loc32_:int = 0;
         var _loc27_:Number = NaN;
         var _loc34_:b2ManifoldPoint = null;
         param1.pointCount = 0;
         var _loc22_:int = 0;
         var _loc14_:Array = [_loc22_];
         var _loc15_:Number = FindMaxSeparation(_loc14_,param2,param3,param4,param5);
         _loc22_ = int(_loc14_[0]);
         if(_loc15_ > 0)
         {
            return;
         }
         var _loc21_:int = 0;
         var _loc36_:Array = [_loc21_];
         var _loc12_:Number = FindMaxSeparation(_loc36_,param4,param5,param2,param3);
         _loc21_ = int(_loc36_[0]);
         if(_loc12_ > 0)
         {
            return;
         }
         var _loc33_:b2XForm = new b2XForm();
         var _loc37_:b2XForm = new b2XForm();
         if(_loc12_ > 0.98 * _loc15_ + 0.001)
         {
            _loc28_ = param4;
            _loc29_ = param2;
            _loc33_.Set(param5);
            _loc37_.Set(param3);
            _loc13_ = _loc21_;
            _loc20_ = 1;
         }
         else
         {
            _loc28_ = param2;
            _loc29_ = param4;
            _loc33_.Set(param3);
            _loc37_.Set(param5);
            _loc13_ = _loc22_;
            _loc20_ = 0;
         }
         var _loc24_:Array = [new ClipVertex(),new ClipVertex()];
         FindIncidentEdge(_loc24_,_loc28_,_loc33_,_loc13_,_loc29_,_loc37_);
         var _loc38_:int = _loc28_.m_vertexCount;
         var _loc9_:Array = _loc28_.m_vertices;
         var _loc31_:b2Vec2 = _loc9_[_loc13_];
         var _loc16_:b2Vec2 = _loc31_.Copy();
         if(_loc13_ + 1 < _loc38_)
         {
            _loc31_ = _loc9_[int(_loc13_ + 1)];
            _loc17_ = _loc31_.Copy();
         }
         else
         {
            _loc31_ = _loc9_[0];
            _loc17_ = _loc31_.Copy();
         }
         var _loc7_:b2Vec2 = b2Math.SubtractVV(_loc17_,_loc16_);
         var _loc6_:b2Vec2 = b2Math.b2MulMV(_loc33_.R,b2Math.SubtractVV(_loc17_,_loc16_));
         _loc6_.Normalize();
         var _loc23_:b2Vec2 = b2Math.b2CrossVF(_loc6_,1);
         _loc16_ = b2Math.b2MulX(_loc33_,_loc16_);
         _loc17_ = b2Math.b2MulX(_loc33_,_loc17_);
         var _loc19_:Number = b2Math.b2Dot(_loc23_,_loc16_);
         var _loc35_:Number = -b2Math.b2Dot(_loc6_,_loc16_);
         var _loc39_:Number = b2Math.b2Dot(_loc6_,_loc17_);
         var _loc25_:Array = [new ClipVertex(),new ClipVertex()];
         var _loc26_:Array = [new ClipVertex(),new ClipVertex()];
         _loc8_ = ClipSegmentToLine(_loc25_,_loc24_,_loc6_.Negative(),_loc35_);
         if(_loc8_ < 2)
         {
            return;
         }
         _loc8_ = ClipSegmentToLine(_loc26_,_loc25_,_loc6_,_loc39_);
         if(_loc8_ < 2)
         {
            return;
         }
         param1.normal = _loc20_ ? _loc23_.Negative() : _loc23_.Copy();
         var _loc18_:int = 0;
         _loc32_ = 0;
         while(_loc32_ < 2)
         {
            _loc30_ = _loc26_[_loc32_];
            _loc27_ = b2Math.b2Dot(_loc23_,_loc30_.v) - _loc19_;
            if(_loc27_ <= 0)
            {
               _loc34_ = param1.points[_loc18_];
               _loc34_.separation = _loc27_;
               _loc34_.localPoint1 = b2Math.b2MulXT(param3,_loc30_.v);
               _loc34_.localPoint2 = b2Math.b2MulXT(param5,_loc30_.v);
               _loc34_.id.key = _loc30_.id._key;
               _loc34_.id.features.flip = _loc20_;
               _loc18_++;
            }
            _loc32_++;
         }
         param1.pointCount = _loc18_;
      }
      
      public static function b2CollideCircles(param1:b2Manifold, param2:b2CircleShape, param3:b2XForm, param4:b2CircleShape, param5:b2XForm) : void
      {
         var _loc22_:b2Mat22 = null;
         var _loc19_:b2Vec2 = null;
         var _loc13_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc14_:Number = NaN;
         param1.pointCount = 0;
         _loc22_ = param3.R;
         _loc19_ = param2.m_localPosition;
         var _loc7_:Number = param3.position.x + (_loc22_.col1.x * _loc19_.x + _loc22_.col2.x * _loc19_.y);
         var _loc9_:Number = param3.position.y + (_loc22_.col1.y * _loc19_.x + _loc22_.col2.y * _loc19_.y);
         _loc22_ = param5.R;
         _loc19_ = param4.m_localPosition;
         var _loc21_:Number = param5.position.x + (_loc22_.col1.x * _loc19_.x + _loc22_.col2.x * _loc19_.y);
         var _loc20_:Number = param5.position.y + (_loc22_.col1.y * _loc19_.x + _loc22_.col2.y * _loc19_.y);
         var _loc16_:Number = _loc21_ - _loc7_;
         var _loc15_:Number = _loc20_ - _loc9_;
         var _loc8_:Number = _loc16_ * _loc16_ + _loc15_ * _loc15_;
         var _loc23_:Number = param2.m_radius;
         var _loc24_:Number = param4.m_radius;
         var _loc10_:Number = _loc23_ + _loc24_;
         if(_loc8_ > _loc10_ * _loc10_)
         {
            return;
         }
         if(_loc8_ < Number.MIN_VALUE)
         {
            _loc13_ = -_loc10_;
            param1.normal.Set(0,1);
         }
         else
         {
            _loc25_ = Math.sqrt(_loc8_);
            _loc13_ = _loc25_ - _loc10_;
            _loc14_ = 1 / _loc25_;
            param1.normal.x = _loc14_ * _loc16_;
            param1.normal.y = _loc14_ * _loc15_;
         }
         param1.pointCount = 1;
         var _loc6_:b2ManifoldPoint = param1.points[0];
         _loc6_.id.key = 0;
         _loc6_.separation = _loc13_;
         _loc7_ += _loc23_ * param1.normal.x;
         _loc9_ += _loc23_ * param1.normal.y;
         _loc21_ -= _loc24_ * param1.normal.x;
         _loc20_ -= _loc24_ * param1.normal.y;
         var _loc18_:Number = 0.5 * (_loc7_ + _loc21_);
         var _loc17_:Number = 0.5 * (_loc9_ + _loc20_);
         var _loc11_:Number = _loc18_ - param3.position.x;
         var _loc12_:Number = _loc17_ - param3.position.y;
         _loc6_.localPoint1.x = _loc11_ * param3.R.col1.x + _loc12_ * param3.R.col1.y;
         _loc6_.localPoint1.y = _loc11_ * param3.R.col2.x + _loc12_ * param3.R.col2.y;
         _loc11_ = _loc18_ - param5.position.x;
         _loc12_ = _loc17_ - param5.position.y;
         _loc6_.localPoint2.x = _loc11_ * param5.R.col1.x + _loc12_ * param5.R.col1.y;
         _loc6_.localPoint2.y = _loc11_ * param5.R.col2.x + _loc12_ * param5.R.col2.y;
      }
      
      public static function b2CollidePolygonAndCircle(param1:b2Manifold, param2:b2PolygonShape, param3:b2XForm, param4:b2CircleShape, param5:b2XForm) : void
      {
         var _loc12_:b2ManifoldPoint = null;
         var _loc18_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc23_:b2Vec2 = null;
         var _loc29_:b2Mat22 = null;
         var _loc34_:Number = NaN;
         var _loc24_:int = 0;
         var _loc28_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc21_:Number = NaN;
         param1.pointCount = 0;
         _loc29_ = param5.R;
         _loc23_ = param4.m_localPosition;
         var _loc10_:Number = param5.position.x + (_loc29_.col1.x * _loc23_.x + _loc29_.col2.x * _loc23_.y);
         var _loc11_:Number = param5.position.y + (_loc29_.col1.y * _loc23_.x + _loc29_.col2.y * _loc23_.y);
         _loc18_ = _loc10_ - param3.position.x;
         _loc17_ = _loc11_ - param3.position.y;
         _loc29_ = param3.R;
         var _loc33_:Number = _loc18_ * _loc29_.col1.x + _loc17_ * _loc29_.col1.y;
         var _loc32_:Number = _loc18_ * _loc29_.col2.x + _loc17_ * _loc29_.col2.y;
         var _loc30_:* = 0;
         var _loc16_:Number = -1.7976931348623157e+308;
         var _loc31_:Number = param4.m_radius;
         var _loc25_:int = param2.m_vertexCount;
         var _loc8_:Array = param2.m_vertices;
         var _loc27_:Array = param2.m_normals;
         _loc24_ = 0;
         while(_loc24_ < _loc25_)
         {
            _loc23_ = _loc8_[_loc24_];
            _loc18_ = _loc33_ - _loc23_.x;
            _loc17_ = _loc32_ - _loc23_.y;
            _loc23_ = _loc27_[_loc24_];
            _loc28_ = _loc23_.x * _loc18_ + _loc23_.y * _loc17_;
            if(_loc28_ > _loc31_)
            {
               return;
            }
            if(_loc28_ > _loc16_)
            {
               _loc16_ = _loc28_;
               _loc30_ = _loc24_;
            }
            _loc24_++;
         }
         if(_loc16_ < Number.MIN_VALUE)
         {
            param1.pointCount = 1;
            _loc23_ = _loc27_[_loc30_];
            _loc29_ = param3.R;
            param1.normal.x = _loc29_.col1.x * _loc23_.x + _loc29_.col2.x * _loc23_.y;
            param1.normal.y = _loc29_.col1.y * _loc23_.x + _loc29_.col2.y * _loc23_.y;
            _loc12_ = param1.points[0];
            _loc12_.id.features.incidentEdge = _loc30_;
            _loc12_.id.features.incidentVertex = 255;
            _loc12_.id.features.referenceEdge = 0;
            _loc12_.id.features.flip = 0;
            _loc13_ = _loc10_ - _loc31_ * param1.normal.x;
            _loc9_ = _loc11_ - _loc31_ * param1.normal.y;
            _loc18_ = _loc13_ - param3.position.x;
            _loc17_ = _loc9_ - param3.position.y;
            _loc29_ = param3.R;
            _loc12_.localPoint1.x = _loc18_ * _loc29_.col1.x + _loc17_ * _loc29_.col1.y;
            _loc12_.localPoint1.y = _loc18_ * _loc29_.col2.x + _loc17_ * _loc29_.col2.y;
            _loc18_ = _loc13_ - param5.position.x;
            _loc17_ = _loc9_ - param5.position.y;
            _loc29_ = param5.R;
            _loc12_.localPoint2.x = _loc18_ * _loc29_.col1.x + _loc17_ * _loc29_.col1.y;
            _loc12_.localPoint2.y = _loc18_ * _loc29_.col2.x + _loc17_ * _loc29_.col2.y;
            _loc12_.separation = _loc16_ - _loc31_;
            return;
         }
         var _loc20_:Number = _loc30_;
         var _loc22_:int = _loc20_ + 1 < _loc25_ ? _loc20_ + 1 : 0;
         _loc23_ = _loc8_[_loc20_];
         var _loc15_:b2Vec2 = _loc8_[_loc22_];
         var _loc6_:Number = _loc15_.x - _loc23_.x;
         var _loc7_:Number = _loc15_.y - _loc23_.y;
         var _loc14_:Number = Math.sqrt(_loc6_ * _loc6_ + _loc7_ * _loc7_);
         _loc6_ /= _loc14_;
         _loc7_ /= _loc14_;
         _loc18_ = _loc33_ - _loc23_.x;
         _loc17_ = _loc32_ - _loc23_.y;
         var _loc26_:Number = _loc18_ * _loc6_ + _loc17_ * _loc7_;
         _loc12_ = param1.points[0];
         if(_loc26_ <= 0)
         {
            _loc21_ = _loc23_.x;
            _loc19_ = _loc23_.y;
            _loc12_.id.features.incidentEdge = 255;
            _loc12_.id.features.incidentVertex = _loc20_;
         }
         else if(_loc26_ >= _loc14_)
         {
            _loc21_ = _loc15_.x;
            _loc19_ = _loc15_.y;
            _loc12_.id.features.incidentEdge = 255;
            _loc12_.id.features.incidentVertex = _loc22_;
         }
         else
         {
            _loc21_ = _loc6_ * _loc26_ + _loc23_.x;
            _loc19_ = _loc7_ * _loc26_ + _loc23_.y;
            _loc12_.id.features.incidentEdge = _loc30_;
            _loc12_.id.features.incidentVertex = 255;
         }
         _loc18_ = _loc33_ - _loc21_;
         _loc17_ = _loc32_ - _loc19_;
         _loc34_ = Math.sqrt(_loc18_ * _loc18_ + _loc17_ * _loc17_);
         _loc18_ /= _loc34_;
         _loc17_ /= _loc34_;
         if(_loc34_ > _loc31_)
         {
            return;
         }
         param1.pointCount = 1;
         _loc29_ = param3.R;
         param1.normal.x = _loc29_.col1.x * _loc18_ + _loc29_.col2.x * _loc17_;
         param1.normal.y = _loc29_.col1.y * _loc18_ + _loc29_.col2.y * _loc17_;
         _loc13_ = _loc10_ - _loc31_ * param1.normal.x;
         _loc9_ = _loc11_ - _loc31_ * param1.normal.y;
         _loc18_ = _loc13_ - param3.position.x;
         _loc17_ = _loc9_ - param3.position.y;
         _loc29_ = param3.R;
         _loc12_.localPoint1.x = _loc18_ * _loc29_.col1.x + _loc17_ * _loc29_.col1.y;
         _loc12_.localPoint1.y = _loc18_ * _loc29_.col2.x + _loc17_ * _loc29_.col2.y;
         _loc18_ = _loc13_ - param5.position.x;
         _loc17_ = _loc9_ - param5.position.y;
         _loc29_ = param5.R;
         _loc12_.localPoint2.x = _loc18_ * _loc29_.col1.x + _loc17_ * _loc29_.col1.y;
         _loc12_.localPoint2.y = _loc18_ * _loc29_.col2.x + _loc17_ * _loc29_.col2.y;
         _loc12_.separation = _loc34_ - _loc31_;
         _loc12_.id.features.referenceEdge = 0;
         _loc12_.id.features.flip = 0;
      }
      
      public static function b2TestOverlap(param1:b2AABB, param2:b2AABB) : Boolean
      {
         var _loc4_:b2Vec2 = param2.lowerBound;
         var _loc3_:b2Vec2 = param1.upperBound;
         var _loc8_:Number = _loc4_.x - _loc3_.x;
         var _loc7_:Number = _loc4_.y - _loc3_.y;
         _loc4_ = param1.lowerBound;
         _loc3_ = param2.upperBound;
         var _loc6_:Number = _loc4_.x - _loc3_.x;
         var _loc5_:Number = _loc4_.y - _loc3_.y;
         if(_loc8_ > 0 || _loc7_ > 0)
         {
            return false;
         }
         if(_loc6_ > 0 || _loc5_ > 0)
         {
            return false;
         }
         return true;
      }
   }
}

