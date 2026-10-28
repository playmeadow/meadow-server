package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2Segment
   {
      
      public var p1:b2Vec2 = new b2Vec2();
      
      public var p2:b2Vec2 = new b2Vec2();
      
      public function b2Segment()
      {
         super();
      }
      
      public function TestSegment(param1:Array, param2:b2Vec2, param3:b2Segment, param4:Number) : Boolean
      {
         var _loc12_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc14_:b2Vec2 = param3.p1;
         var _loc15_:Number = param3.p2.x - _loc14_.x;
         var _loc16_:Number = param3.p2.y - _loc14_.y;
         var _loc9_:Number = p2.x - p1.x;
         var _loc7_:Number;
         var _loc10_:Number = _loc7_ = p2.y - p1.y;
         var _loc8_:Number = -_loc9_;
         var _loc18_:Number = 100 * Number.MIN_VALUE;
         var _loc13_:Number = -(_loc15_ * _loc10_ + _loc16_ * _loc8_);
         if(_loc13_ > _loc18_)
         {
            _loc12_ = _loc14_.x - p1.x;
            _loc11_ = _loc14_.y - p1.y;
            _loc6_ = _loc12_ * _loc10_ + _loc11_ * _loc8_;
            if(0 <= _loc6_ && _loc6_ <= param4 * _loc13_)
            {
               _loc5_ = -_loc15_ * _loc11_ + _loc16_ * _loc12_;
               if(-_loc18_ * _loc13_ <= _loc5_ && _loc5_ <= _loc13_ * (1 + _loc18_))
               {
                  _loc6_ /= _loc13_;
                  _loc17_ = Math.sqrt(_loc10_ * _loc10_ + _loc8_ * _loc8_);
                  _loc10_ /= _loc17_;
                  _loc8_ /= _loc17_;
                  param1[0] = _loc6_;
                  param2.Set(_loc10_,_loc8_);
                  return true;
               }
            }
         }
         return false;
      }
   }
}

