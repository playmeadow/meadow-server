package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2XForm;
   
   public class b2TimeOfImpact
   {
      
      public static var s_p1:b2Vec2 = new b2Vec2();
      
      public static var s_p2:b2Vec2 = new b2Vec2();
      
      public static var s_xf1:b2XForm = new b2XForm();
      
      public static var s_xf2:b2XForm = new b2XForm();
      
      public function b2TimeOfImpact()
      {
         super();
      }
      
      public static function TimeOfImpact(param1:b2Shape, param2:b2Sweep, param3:b2Shape, param4:b2Sweep) : Number
      {
         var _loc22_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc23_:b2XForm = null;
         var _loc27_:b2XForm = null;
         var _loc28_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc29_:Number = param1.m_sweepRadius;
         var _loc30_:Number = param3.m_sweepRadius;
         var _loc5_:Number = param2.t0;
         var _loc24_:Number = param2.c.x - param2.c0.x;
         var _loc25_:Number = param2.c.y - param2.c0.y;
         var _loc15_:Number = param4.c.x - param4.c0.x;
         var _loc17_:Number = param4.c.y - param4.c0.y;
         var _loc8_:Number = param2.a - param2.a0;
         var _loc10_:Number = param4.a - param4.a0;
         var _loc18_:Number = 0;
         var _loc7_:b2Vec2 = s_p1;
         var _loc6_:b2Vec2 = s_p2;
         var _loc13_:int = 20;
         var _loc31_:int = 0;
         var _loc9_:Number = 0;
         var _loc12_:Number = 0;
         var _loc14_:Number = 0;
         var _loc20_:Number = 0;
         while(true)
         {
            _loc26_ = (1 - _loc18_) * _loc5_ + _loc18_;
            _loc23_ = s_xf1;
            _loc27_ = s_xf2;
            param2.GetXForm(_loc23_,_loc26_);
            param4.GetXForm(_loc27_,_loc26_);
            _loc14_ = b2Distance.Distance(_loc7_,_loc6_,param1,_loc23_,param3,_loc27_);
            if(_loc31_ == 0)
            {
               if(_loc14_ > 2 * 0.04)
               {
                  _loc20_ = 1.5 * 0.04;
               }
               else
               {
                  _loc22_ = 0.05 * 0.04;
                  _loc21_ = _loc14_ - 0.5 * 0.04;
                  _loc20_ = _loc22_ > _loc21_ ? _loc22_ : _loc21_;
               }
            }
            if(_loc14_ - _loc20_ < 0.05 * 0.04 || _loc31_ == _loc13_)
            {
               break;
            }
            _loc9_ = _loc6_.x - _loc7_.x;
            _loc12_ = _loc6_.y - _loc7_.y;
            _loc28_ = Math.sqrt(_loc9_ * _loc9_ + _loc12_ * _loc12_);
            _loc9_ /= _loc28_;
            _loc12_ /= _loc28_;
            _loc16_ = _loc9_ * (_loc24_ - _loc15_) + _loc12_ * (_loc25_ - _loc17_) + (_loc8_ < 0 ? -_loc8_ : _loc8_) * _loc29_ + (_loc10_ < 0 ? -_loc10_ : _loc10_) * _loc30_;
            if(_loc16_ == 0)
            {
               _loc18_ = 1;
               break;
            }
            _loc19_ = (_loc14_ - _loc20_) / _loc16_;
            _loc11_ = _loc18_ + _loc19_;
            if(_loc11_ < 0 || 1 < _loc11_)
            {
               _loc18_ = 1;
               break;
            }
            if(_loc11_ < (1 + 100 * Number.MIN_VALUE) * _loc18_)
            {
               break;
            }
            _loc18_ = _loc11_;
            _loc31_++;
         }
         return _loc18_;
      }
   }
}

