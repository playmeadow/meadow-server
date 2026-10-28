package Box2D.Collision.Shapes
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2PolygonShape extends b2Shape
   {
      
      private static var s_computeMat:b2Mat22 = new b2Mat22();
      
      private static var s_sweptAABB1:b2AABB = new b2AABB();
      
      private static var s_sweptAABB2:b2AABB = new b2AABB();
      
      private var s_supportVec:b2Vec2 = new b2Vec2();
      
      public var m_centroid:b2Vec2;
      
      public var m_obb:b2OBB = new b2OBB();
      
      public var m_vertices:Array = new Array(8);
      
      public var m_normals:Array = new Array(8);
      
      public var m_coreVertices:Array = new Array(8);
      
      public var m_vertexCount:int;
      
      public function b2PolygonShape(param1:b2ShapeDef)
      {
         var _loc7_:int = 0;
         var _loc17_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         super(param1);
         m_type = 1;
         var _loc3_:b2PolygonDef = param1 as b2PolygonDef;
         m_vertexCount = _loc3_.vertexCount;
         var _loc16_:int = _loc7_;
         var _loc15_:int = _loc7_;
         _loc7_ = 0;
         while(_loc7_ < m_vertexCount)
         {
            m_vertices[_loc7_] = _loc3_.vertices[_loc7_].Copy();
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < m_vertexCount)
         {
            _loc16_ = _loc7_;
            _loc15_ = _loc7_ + 1 < m_vertexCount ? _loc7_ + 1 : 0;
            _loc17_ = m_vertices[_loc15_].x - m_vertices[_loc16_].x;
            _loc10_ = m_vertices[_loc15_].y - m_vertices[_loc16_].y;
            _loc6_ = Math.sqrt(_loc17_ * _loc17_ + _loc10_ * _loc10_);
            m_normals[_loc7_] = new b2Vec2(_loc10_ / _loc6_,-_loc17_ / _loc6_);
            _loc7_++;
         }
         m_centroid = ComputeCentroid(_loc3_.vertices,_loc3_.vertexCount);
         ComputeOBB(m_obb,m_vertices,m_vertexCount);
         _loc7_ = 0;
         while(_loc7_ < m_vertexCount)
         {
            _loc16_ = _loc7_ - 1 >= 0 ? _loc7_ - 1 : m_vertexCount - 1;
            _loc15_ = _loc7_;
            _loc12_ = Number(m_normals[_loc16_].x);
            _loc11_ = Number(m_normals[_loc16_].y);
            _loc13_ = Number(m_normals[_loc15_].x);
            _loc14_ = Number(m_normals[_loc15_].y);
            _loc9_ = m_vertices[_loc7_].x - m_centroid.x;
            _loc8_ = m_vertices[_loc7_].y - m_centroid.y;
            _loc5_ = _loc12_ * _loc9_ + _loc11_ * _loc8_ - 0.04;
            _loc4_ = _loc13_ * _loc9_ + _loc14_ * _loc8_ - 0.04;
            _loc2_ = 1 / (_loc12_ * _loc14_ - _loc11_ * _loc13_);
            m_coreVertices[_loc7_] = new b2Vec2(_loc2_ * (_loc14_ * _loc5_ - _loc11_ * _loc4_) + m_centroid.x,_loc2_ * (_loc12_ * _loc4_ - _loc13_ * _loc5_) + m_centroid.y);
            _loc7_++;
         }
      }
      
      public static function ComputeCentroid(param1:Array, param2:int) : b2Vec2
      {
         var _loc12_:int = 0;
         var _loc8_:b2Vec2 = null;
         var _loc6_:b2Vec2 = null;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc7_:b2Vec2 = new b2Vec2();
         var _loc14_:Number = 0;
         var _loc13_:Number = 0;
         var _loc16_:Number = 0;
         var _loc10_:Number = 0.3333333333333333;
         _loc12_ = 0;
         while(_loc12_ < param2)
         {
            _loc8_ = param1[_loc12_];
            _loc6_ = _loc12_ + 1 < param2 ? param1[int(_loc12_ + 1)] : param1[0];
            _loc5_ = _loc8_.x - _loc13_;
            _loc4_ = _loc8_.y - _loc16_;
            _loc9_ = _loc6_.x - _loc13_;
            _loc11_ = _loc6_.y - _loc16_;
            _loc3_ = _loc5_ * _loc11_ - _loc4_ * _loc9_;
            _loc15_ = 0.5 * _loc3_;
            _loc14_ += _loc15_;
            _loc7_.x += _loc15_ * _loc10_ * (_loc13_ + _loc8_.x + _loc6_.x);
            _loc7_.y += _loc15_ * _loc10_ * (_loc16_ + _loc8_.y + _loc6_.y);
            _loc12_++;
         }
         _loc7_.x *= 1 / _loc14_;
         _loc7_.y *= 1 / _loc14_;
         return _loc7_;
      }
      
      public static function ComputeOBB(param1:b2OBB, param2:Array, param3:int) : void
      {
         var _loc21_:int = 0;
         var _loc4_:b2Vec2 = null;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc20_:int = 0;
         var _loc19_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc23_:b2Mat22 = null;
         var _loc24_:Array = new Array(8 + 1);
         _loc21_ = 0;
         while(_loc21_ < param3)
         {
            _loc24_[_loc21_] = param2[_loc21_];
            _loc21_++;
         }
         _loc24_[param3] = _loc24_[0];
         var _loc11_:Number = 1.7976931348623157e+308;
         _loc21_ = 1;
         while(_loc21_ <= param3)
         {
            _loc4_ = _loc24_[int(_loc21_ - 1)];
            _loc16_ = _loc24_[_loc21_].x - _loc4_.x;
            _loc17_ = _loc24_[_loc21_].y - _loc4_.y;
            _loc13_ = Math.sqrt(_loc16_ * _loc16_ + _loc17_ * _loc17_);
            _loc16_ /= _loc13_;
            _loc17_ /= _loc13_;
            _loc5_ = -_loc17_;
            _loc6_ = _loc16_;
            _loc22_ = 1.7976931348623157e+308;
            _loc25_ = 1.7976931348623157e+308;
            _loc12_ = -1.7976931348623157e+308;
            _loc10_ = -1.7976931348623157e+308;
            _loc20_ = 0;
            while(_loc20_ < param3)
            {
               _loc19_ = _loc24_[_loc20_].x - _loc4_.x;
               _loc18_ = _loc24_[_loc20_].y - _loc4_.y;
               _loc14_ = _loc16_ * _loc19_ + _loc17_ * _loc18_;
               _loc15_ = _loc5_ * _loc19_ + _loc6_ * _loc18_;
               if(_loc14_ < _loc22_)
               {
                  _loc22_ = _loc14_;
               }
               if(_loc15_ < _loc25_)
               {
                  _loc25_ = _loc15_;
               }
               if(_loc14_ > _loc12_)
               {
                  _loc12_ = _loc14_;
               }
               if(_loc15_ > _loc10_)
               {
                  _loc10_ = _loc15_;
               }
               _loc20_++;
            }
            _loc7_ = (_loc12_ - _loc22_) * (_loc10_ - _loc25_);
            if(_loc7_ < 0.95 * _loc11_)
            {
               _loc11_ = _loc7_;
               param1.R.col1.x = _loc16_;
               param1.R.col1.y = _loc17_;
               param1.R.col2.x = _loc5_;
               param1.R.col2.y = _loc6_;
               _loc9_ = 0.5 * (_loc22_ + _loc12_);
               _loc8_ = 0.5 * (_loc25_ + _loc10_);
               _loc23_ = param1.R;
               param1.center.x = _loc4_.x + (_loc23_.col1.x * _loc9_ + _loc23_.col2.x * _loc8_);
               param1.center.y = _loc4_.y + (_loc23_.col1.y * _loc9_ + _loc23_.col2.y * _loc8_);
               param1.extents.x = 0.5 * (_loc12_ - _loc22_);
               param1.extents.y = 0.5 * (_loc10_ - _loc25_);
            }
            _loc21_++;
         }
      }
      
      override public function TestPoint(param1:b2XForm, param2:b2Vec2) : Boolean
      {
         var _loc8_:b2Vec2 = null;
         var _loc9_:int = 0;
         var _loc6_:Number = NaN;
         var _loc5_:b2Mat22 = param1.R;
         var _loc7_:Number = param2.x - param1.position.x;
         var _loc10_:Number = param2.y - param1.position.y;
         var _loc4_:Number = _loc7_ * _loc5_.col1.x + _loc10_ * _loc5_.col1.y;
         var _loc3_:Number = _loc7_ * _loc5_.col2.x + _loc10_ * _loc5_.col2.y;
         _loc9_ = 0;
         while(_loc9_ < m_vertexCount)
         {
            _loc8_ = m_vertices[_loc9_];
            _loc7_ = _loc4_ - _loc8_.x;
            _loc10_ = _loc3_ - _loc8_.y;
            _loc8_ = m_normals[_loc9_];
            _loc6_ = _loc8_.x * _loc7_ + _loc8_.y * _loc10_;
            if(_loc6_ > 0)
            {
               return false;
            }
            _loc9_++;
         }
         return true;
      }
      
      override public function TestSegment(param1:b2XForm, param2:Array, param3:b2Vec2, param4:b2Segment, param5:Number) : Boolean
      {
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc18_:b2Mat22 = null;
         var _loc12_:b2Vec2 = null;
         var _loc13_:int = 0;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc7_:Number = 0;
         var _loc14_:Number = param5;
         _loc20_ = param4.p1.x - param1.position.x;
         _loc21_ = param4.p1.y - param1.position.y;
         _loc18_ = param1.R;
         var _loc15_:Number = _loc20_ * _loc18_.col1.x + _loc21_ * _loc18_.col1.y;
         var _loc19_:Number = _loc20_ * _loc18_.col2.x + _loc21_ * _loc18_.col2.y;
         _loc20_ = param4.p2.x - param1.position.x;
         _loc21_ = param4.p2.y - param1.position.y;
         _loc18_ = param1.R;
         var _loc17_:Number = _loc20_ * _loc18_.col1.x + _loc21_ * _loc18_.col1.y;
         var _loc16_:Number = _loc20_ * _loc18_.col2.x + _loc21_ * _loc18_.col2.y;
         var _loc11_:Number = _loc17_ - _loc15_;
         var _loc10_:Number = _loc16_ - _loc19_;
         var _loc6_:* = -1;
         _loc13_ = 0;
         while(_loc13_ < m_vertexCount)
         {
            _loc12_ = m_vertices[_loc13_];
            _loc20_ = _loc12_.x - _loc15_;
            _loc21_ = _loc12_.y - _loc19_;
            _loc12_ = m_normals[_loc13_];
            _loc9_ = _loc12_.x * _loc20_ + _loc12_.y * _loc21_;
            _loc8_ = _loc12_.x * _loc11_ + _loc12_.y * _loc10_;
            if(_loc8_ < 0 && _loc9_ < _loc7_ * _loc8_)
            {
               _loc7_ = _loc9_ / _loc8_;
               _loc6_ = _loc13_;
            }
            else if(_loc8_ > 0 && _loc9_ < _loc14_ * _loc8_)
            {
               _loc14_ = _loc9_ / _loc8_;
            }
            if(_loc14_ < _loc7_)
            {
               return false;
            }
            _loc13_++;
         }
         if(_loc6_ >= 0)
         {
            param2[0] = _loc7_;
            _loc18_ = param1.R;
            _loc12_ = m_normals[_loc6_];
            param3.x = _loc18_.col1.x * _loc12_.x + _loc18_.col2.x * _loc12_.y;
            param3.y = _loc18_.col1.y * _loc12_.x + _loc18_.col2.y * _loc12_.y;
            return true;
         }
         return false;
      }
      
      override public function ComputeAABB(param1:b2AABB, param2:b2XForm) : void
      {
         var _loc5_:b2Mat22 = null;
         var _loc10_:b2Vec2 = null;
         var _loc7_:b2Mat22 = s_computeMat;
         _loc5_ = param2.R;
         _loc10_ = m_obb.R.col1;
         _loc7_.col1.x = _loc5_.col1.x * _loc10_.x + _loc5_.col2.x * _loc10_.y;
         _loc7_.col1.y = _loc5_.col1.y * _loc10_.x + _loc5_.col2.y * _loc10_.y;
         _loc10_ = m_obb.R.col2;
         _loc7_.col2.x = _loc5_.col1.x * _loc10_.x + _loc5_.col2.x * _loc10_.y;
         _loc7_.col2.y = _loc5_.col1.y * _loc10_.x + _loc5_.col2.y * _loc10_.y;
         _loc7_.Abs();
         var _loc9_:b2Mat22 = _loc7_;
         _loc10_ = m_obb.extents;
         var _loc4_:Number = _loc9_.col1.x * _loc10_.x + _loc9_.col2.x * _loc10_.y;
         var _loc6_:Number = _loc9_.col1.y * _loc10_.x + _loc9_.col2.y * _loc10_.y;
         _loc5_ = param2.R;
         _loc10_ = m_obb.center;
         var _loc3_:Number = param2.position.x + (_loc5_.col1.x * _loc10_.x + _loc5_.col2.x * _loc10_.y);
         var _loc8_:Number = param2.position.y + (_loc5_.col1.y * _loc10_.x + _loc5_.col2.y * _loc10_.y);
         param1.lowerBound.Set(_loc3_ - _loc4_,_loc8_ - _loc6_);
         param1.upperBound.Set(_loc3_ + _loc4_,_loc8_ + _loc6_);
      }
      
      override public function ComputeSweptAABB(param1:b2AABB, param2:b2XForm, param3:b2XForm) : void
      {
         var _loc4_:b2AABB = s_sweptAABB1;
         var _loc5_:b2AABB = s_sweptAABB2;
         ComputeAABB(_loc4_,param2);
         ComputeAABB(_loc5_,param3);
         param1.lowerBound.Set(_loc4_.lowerBound.x < _loc5_.lowerBound.x ? _loc4_.lowerBound.x : _loc5_.lowerBound.x,_loc4_.lowerBound.y < _loc5_.lowerBound.y ? _loc4_.lowerBound.y : _loc5_.lowerBound.y);
         param1.upperBound.Set(_loc4_.upperBound.x > _loc5_.upperBound.x ? _loc4_.upperBound.x : _loc5_.upperBound.x,_loc4_.upperBound.y > _loc5_.upperBound.y ? _loc4_.upperBound.y : _loc5_.upperBound.y);
      }
      
      override public function ComputeMass(param1:b2MassData) : void
      {
         var _loc15_:int = 0;
         var _loc7_:b2Vec2 = null;
         var _loc6_:b2Vec2 = null;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc20_:Number = 0;
         var _loc17_:Number = 0;
         var _loc18_:Number = 0;
         var _loc13_:Number = 0;
         var _loc16_:Number = 0;
         var _loc23_:Number = 0;
         var _loc24_:Number = 0.3333333333333333;
         _loc15_ = 0;
         while(_loc15_ < m_vertexCount)
         {
            _loc7_ = m_vertices[_loc15_];
            _loc6_ = _loc15_ + 1 < m_vertexCount ? m_vertices[int(_loc15_ + 1)] : m_vertices[0];
            _loc4_ = _loc7_.x - _loc16_;
            _loc3_ = _loc7_.y - _loc23_;
            _loc11_ = _loc6_.x - _loc16_;
            _loc14_ = _loc6_.y - _loc23_;
            _loc2_ = _loc4_ * _loc14_ - _loc3_ * _loc11_;
            _loc22_ = 0.5 * _loc2_;
            _loc18_ += _loc22_;
            _loc20_ += _loc22_ * _loc24_ * (_loc16_ + _loc7_.x + _loc6_.x);
            _loc17_ += _loc22_ * _loc24_ * (_loc23_ + _loc7_.y + _loc6_.y);
            _loc19_ = _loc16_;
            _loc21_ = _loc23_;
            _loc10_ = _loc4_;
            _loc9_ = _loc3_;
            _loc8_ = _loc11_;
            _loc12_ = _loc14_;
            _loc5_ = _loc24_ * (0.25 * (_loc10_ * _loc10_ + _loc8_ * _loc10_ + _loc8_ * _loc8_) + (_loc19_ * _loc10_ + _loc19_ * _loc8_)) + 0.5 * _loc19_ * _loc19_;
            _loc25_ = _loc24_ * (0.25 * (_loc9_ * _loc9_ + _loc12_ * _loc9_ + _loc12_ * _loc12_) + (_loc21_ * _loc9_ + _loc21_ * _loc12_)) + 0.5 * _loc21_ * _loc21_;
            _loc13_ += _loc2_ * (_loc5_ + _loc25_);
            _loc15_++;
         }
         param1.mass = m_density * _loc18_;
         _loc20_ *= 1 / _loc18_;
         _loc17_ *= 1 / _loc18_;
         param1.center.Set(_loc20_,_loc17_);
         param1.I = m_density * _loc13_;
      }
      
      public function GetOBB() : b2OBB
      {
         return m_obb;
      }
      
      public function GetCentroid() : b2Vec2
      {
         return m_centroid;
      }
      
      public function GetVertexCount() : int
      {
         return m_vertexCount;
      }
      
      public function GetVertices() : Array
      {
         return m_vertices;
      }
      
      public function GetCoreVertices() : Array
      {
         return m_coreVertices;
      }
      
      public function GetNormals() : Array
      {
         return m_normals;
      }
      
      public function GetFirstVertex(param1:b2XForm) : b2Vec2
      {
         return b2Math.b2MulX(param1,m_coreVertices[0]);
      }
      
      public function Centroid(param1:b2XForm) : b2Vec2
      {
         return b2Math.b2MulX(param1,m_centroid);
      }
      
      public function Support(param1:b2XForm, param2:Number, param3:Number) : b2Vec2
      {
         var _loc9_:b2Vec2 = null;
         var _loc5_:b2Mat22 = null;
         var _loc10_:int = 0;
         var _loc7_:Number = NaN;
         _loc5_ = param1.R;
         var _loc8_:Number = param2 * _loc5_.col1.x + param3 * _loc5_.col1.y;
         var _loc11_:Number = param2 * _loc5_.col2.x + param3 * _loc5_.col2.y;
         var _loc6_:int = 0;
         _loc9_ = m_coreVertices[0];
         var _loc4_:Number = _loc9_.x * _loc8_ + _loc9_.y * _loc11_;
         _loc10_ = 1;
         while(_loc10_ < m_vertexCount)
         {
            _loc9_ = m_coreVertices[_loc10_];
            _loc7_ = _loc9_.x * _loc8_ + _loc9_.y * _loc11_;
            if(_loc7_ > _loc4_)
            {
               _loc6_ = _loc10_;
               _loc4_ = _loc7_;
            }
            _loc10_++;
         }
         _loc5_ = param1.R;
         _loc9_ = m_coreVertices[_loc6_];
         s_supportVec.x = param1.position.x + (_loc5_.col1.x * _loc9_.x + _loc5_.col2.x * _loc9_.y);
         s_supportVec.y = param1.position.y + (_loc5_.col1.y * _loc9_.x + _loc5_.col2.y * _loc9_.y);
         return s_supportVec;
      }
      
      override public function UpdateSweepRadius(param1:b2Vec2) : void
      {
         var _loc4_:b2Vec2 = null;
         var _loc5_:int = 0;
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         m_sweepRadius = 0;
         _loc5_ = 0;
         while(_loc5_ < m_vertexCount)
         {
            _loc4_ = m_coreVertices[_loc5_];
            _loc3_ = _loc4_.x - param1.x;
            _loc2_ = _loc4_.y - param1.y;
            _loc3_ = Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
            if(_loc3_ > m_sweepRadius)
            {
               m_sweepRadius = _loc3_;
            }
            _loc5_++;
         }
      }
   }
}

