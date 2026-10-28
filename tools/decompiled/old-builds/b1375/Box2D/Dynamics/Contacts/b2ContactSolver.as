package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2ContactSolver
   {
      
      public var m_step:b2TimeStep = new b2TimeStep();
      
      public var m_allocator:*;
      
      public var m_constraints:Array = [];
      
      public var m_constraintCount:int;
      
      public function b2ContactSolver(param1:b2TimeStep, param2:Array, param3:int, param4:*)
      {
         var _loc15_:b2Contact = null;
         var _loc34_:int = 0;
         var _loc32_:* = null;
         var _loc42_:b2Mat22 = null;
         var _loc20_:b2Body = null;
         var _loc12_:b2Body = null;
         var _loc31_:int = 0;
         var _loc39_:Array = null;
         var _loc28_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc29_:int = 0;
         var _loc9_:b2Manifold = null;
         var _loc14_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc26_:b2ContactConstraint = null;
         var _loc30_:* = 0;
         var _loc41_:b2ManifoldPoint = null;
         var _loc10_:b2ContactConstraintPoint = null;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc45_:Number = NaN;
         var _loc47_:Number = NaN;
         var _loc44_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc46_:Number = NaN;
         var _loc43_:Number = NaN;
         var _loc18_:Number = NaN;
         super();
         m_step.dt = param1.dt;
         m_step.inv_dt = param1.inv_dt;
         m_step.maxIterations = param1.maxIterations;
         m_allocator = param4;
         m_constraintCount = 0;
         _loc34_ = 0;
         while(_loc34_ < param3)
         {
            _loc15_ = param2[_loc34_];
            m_constraintCount += _loc15_.m_manifoldCount;
            _loc34_++;
         }
         _loc34_ = 0;
         while(_loc34_ < m_constraintCount)
         {
            m_constraints[_loc34_] = new b2ContactConstraint();
            _loc34_++;
         }
         var _loc7_:int = 0;
         _loc34_ = 0;
         while(_loc34_ < param3)
         {
            _loc15_ = param2[_loc34_];
            _loc20_ = _loc15_.m_shape1.m_body;
            _loc12_ = _loc15_.m_shape2.m_body;
            _loc31_ = _loc15_.m_manifoldCount;
            _loc39_ = _loc15_.GetManifolds();
            _loc28_ = _loc15_.m_friction;
            _loc16_ = _loc15_.m_restitution;
            _loc38_ = _loc20_.m_linearVelocity.x;
            _loc40_ = _loc20_.m_linearVelocity.y;
            _loc19_ = _loc12_.m_linearVelocity.x;
            _loc21_ = _loc12_.m_linearVelocity.y;
            _loc33_ = _loc20_.m_angularVelocity;
            _loc35_ = _loc12_.m_angularVelocity;
            _loc29_ = 0;
            while(_loc29_ < _loc31_)
            {
               _loc9_ = _loc39_[_loc29_];
               _loc14_ = _loc9_.normal.x;
               _loc17_ = _loc9_.normal.y;
               _loc26_ = m_constraints[_loc7_];
               _loc26_.body1 = _loc20_;
               _loc26_.body2 = _loc12_;
               _loc26_.manifold = _loc9_;
               _loc26_.normal.x = _loc14_;
               _loc26_.normal.y = _loc17_;
               _loc26_.pointCount = _loc9_.pointCount;
               _loc26_.friction = _loc28_;
               _loc26_.restitution = _loc16_;
               _loc30_ = 0;
               while(_loc30_ < _loc26_.pointCount)
               {
                  _loc41_ = _loc9_.points[_loc30_];
                  _loc10_ = _loc26_.points[_loc30_];
                  _loc10_.normalImpulse = _loc41_.normalImpulse;
                  _loc10_.tangentImpulse = _loc41_.tangentImpulse;
                  _loc10_.separation = _loc41_.separation;
                  _loc10_.positionImpulse = 0;
                  _loc10_.localAnchor1.SetV(_loc41_.localPoint1);
                  _loc10_.localAnchor2.SetV(_loc41_.localPoint2);
                  _loc42_ = _loc20_.m_xf.R;
                  _loc25_ = _loc41_.localPoint1.x - _loc20_.m_sweep.localCenter.x;
                  _loc27_ = _loc41_.localPoint1.y - _loc20_.m_sweep.localCenter.y;
                  _loc22_ = _loc42_.col1.x * _loc25_ + _loc42_.col2.x * _loc27_;
                  _loc27_ = _loc42_.col1.y * _loc25_ + _loc42_.col2.y * _loc27_;
                  _loc25_ = _loc22_;
                  _loc10_.r1.Set(_loc25_,_loc27_);
                  _loc42_ = _loc12_.m_xf.R;
                  _loc6_ = _loc41_.localPoint2.x - _loc12_.m_sweep.localCenter.x;
                  _loc5_ = _loc41_.localPoint2.y - _loc12_.m_sweep.localCenter.y;
                  _loc22_ = _loc42_.col1.x * _loc6_ + _loc42_.col2.x * _loc5_;
                  _loc5_ = _loc42_.col1.y * _loc6_ + _loc42_.col2.y * _loc5_;
                  _loc6_ = _loc22_;
                  _loc10_.r2.Set(_loc6_,_loc5_);
                  _loc36_ = _loc25_ * _loc25_ + _loc27_ * _loc27_;
                  _loc37_ = _loc6_ * _loc6_ + _loc5_ * _loc5_;
                  _loc13_ = _loc25_ * _loc14_ + _loc27_ * _loc17_;
                  _loc11_ = _loc6_ * _loc14_ + _loc5_ * _loc17_;
                  _loc8_ = _loc20_.m_invMass + _loc12_.m_invMass;
                  _loc8_ = _loc8_ + (_loc20_.m_invI * (_loc36_ - _loc13_ * _loc13_) + _loc12_.m_invI * (_loc37_ - _loc11_ * _loc11_));
                  _loc10_.normalMass = 1 / _loc8_;
                  _loc45_ = _loc20_.m_mass * _loc20_.m_invMass + _loc12_.m_mass * _loc12_.m_invMass;
                  _loc45_ = _loc45_ + (_loc20_.m_mass * _loc20_.m_invI * (_loc36_ - _loc13_ * _loc13_) + _loc12_.m_mass * _loc12_.m_invI * (_loc37_ - _loc11_ * _loc11_));
                  _loc10_.equalizedMass = 1 / _loc45_;
                  _loc47_ = _loc17_;
                  _loc44_ = -_loc14_;
                  _loc24_ = _loc25_ * _loc47_ + _loc27_ * _loc44_;
                  _loc46_ = _loc6_ * _loc47_ + _loc5_ * _loc44_;
                  _loc43_ = _loc20_.m_invMass + _loc12_.m_invMass;
                  _loc43_ = _loc43_ + (_loc20_.m_invI * (_loc36_ - _loc24_ * _loc24_) + _loc12_.m_invI * (_loc37_ - _loc46_ * _loc46_));
                  _loc10_.tangentMass = 1 / _loc43_;
                  _loc10_.velocityBias = 0;
                  if(_loc10_.separation > 0)
                  {
                     _loc10_.velocityBias = -60 * _loc10_.separation;
                  }
                  _loc22_ = _loc19_ + -_loc35_ * _loc5_ - _loc38_ - -_loc33_ * _loc27_;
                  _loc23_ = _loc21_ + _loc35_ * _loc6_ - _loc40_ - _loc33_ * _loc25_;
                  _loc18_ = _loc26_.normal.x * _loc22_ + _loc26_.normal.y * _loc23_;
                  if(_loc18_ < -1)
                  {
                     _loc10_.velocityBias += -_loc26_.restitution * _loc18_;
                  }
                  _loc30_++;
               }
               _loc7_++;
               _loc29_++;
            }
            _loc34_++;
         }
      }
      
      public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc14_:* = null;
         var _loc2_:* = null;
         var _loc17_:* = null;
         var _loc16_:int = 0;
         var _loc6_:b2ContactConstraint = null;
         var _loc18_:b2Body = null;
         var _loc9_:b2Body = null;
         var _loc4_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc12_:int = 0;
         var _loc11_:int = 0;
         var _loc7_:b2ContactConstraintPoint = null;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc5_:b2ContactConstraintPoint = null;
         _loc16_ = 0;
         while(_loc16_ < m_constraintCount)
         {
            _loc6_ = m_constraints[_loc16_];
            _loc18_ = _loc6_.body1;
            _loc9_ = _loc6_.body2;
            _loc4_ = _loc18_.m_invMass;
            _loc10_ = _loc18_.m_invI;
            _loc3_ = _loc9_.m_invMass;
            _loc8_ = _loc9_.m_invI;
            _loc13_ = _loc6_.normal.x;
            _loc22_ = _loc15_ = _loc6_.normal.y;
            _loc19_ = -_loc13_;
            if(param1.warmStarting)
            {
               _loc11_ = _loc6_.pointCount;
               _loc12_ = 0;
               while(_loc12_ < _loc11_)
               {
                  _loc7_ = _loc6_.points[_loc12_];
                  _loc7_.normalImpulse = _loc7_.normalImpulse * param1.dtRatio;
                  _loc7_.tangentImpulse *= param1.dtRatio;
                  _loc20_ = _loc7_.normalImpulse * _loc13_ + _loc7_.tangentImpulse * _loc22_;
                  _loc21_ = _loc7_.normalImpulse * _loc15_ + _loc7_.tangentImpulse * _loc19_;
                  _loc18_.m_angularVelocity -= _loc10_ * (_loc7_.r1.x * _loc21_ - _loc7_.r1.y * _loc20_);
                  _loc18_.m_linearVelocity.x -= _loc4_ * _loc20_;
                  _loc18_.m_linearVelocity.y -= _loc4_ * _loc21_;
                  _loc9_.m_angularVelocity += _loc8_ * (_loc7_.r2.x * _loc21_ - _loc7_.r2.y * _loc20_);
                  _loc9_.m_linearVelocity.x += _loc3_ * _loc20_;
                  _loc9_.m_linearVelocity.y += _loc3_ * _loc21_;
                  _loc12_++;
               }
            }
            else
            {
               _loc11_ = _loc6_.pointCount;
               _loc12_ = 0;
               while(_loc12_ < _loc11_)
               {
                  _loc5_ = _loc6_.points[_loc12_];
                  _loc5_.normalImpulse = 0;
                  _loc5_.tangentImpulse = 0;
                  _loc12_++;
               }
            }
            _loc16_++;
         }
      }
      
      public function SolveVelocityConstraints() : void
      {
         var _loc25_:int = 0;
         var _loc9_:b2ContactConstraintPoint = null;
         var _loc18_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc33_:* = null;
         var _loc26_:* = null;
         var _loc28_:int = 0;
         var _loc19_:b2ContactConstraint = null;
         var _loc15_:b2Body = null;
         var _loc10_:b2Body = null;
         var _loc27_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc1_:b2Vec2 = null;
         var _loc6_:b2Vec2 = null;
         var _loc4_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc23_:int = 0;
         var _loc16_:Number = NaN;
         _loc28_ = 0;
         while(_loc28_ < m_constraintCount)
         {
            _loc19_ = m_constraints[_loc28_];
            _loc15_ = _loc19_.body1;
            _loc10_ = _loc19_.body2;
            _loc27_ = _loc15_.m_angularVelocity;
            _loc29_ = _loc10_.m_angularVelocity;
            _loc1_ = _loc15_.m_linearVelocity;
            _loc6_ = _loc10_.m_linearVelocity;
            _loc4_ = _loc15_.m_invMass;
            _loc11_ = _loc15_.m_invI;
            _loc2_ = _loc10_.m_invMass;
            _loc7_ = _loc10_.m_invI;
            _loc12_ = _loc19_.normal.x;
            _loc37_ = _loc14_ = _loc19_.normal.y;
            _loc34_ = -_loc12_;
            _loc22_ = _loc19_.friction;
            _loc23_ = _loc19_.pointCount;
            _loc25_ = 0;
            while(_loc25_ < _loc23_)
            {
               _loc9_ = _loc19_.points[_loc25_];
               _loc31_ = _loc6_.x + -_loc29_ * _loc9_.r2.y - _loc1_.x - -_loc27_ * _loc9_.r1.y;
               _loc30_ = _loc6_.y + _loc29_ * _loc9_.r2.x - _loc1_.y - _loc27_ * _loc9_.r1.x;
               _loc13_ = _loc31_ * _loc12_ + _loc30_ * _loc14_;
               _loc20_ = -_loc9_.normalMass * (_loc13_ - _loc9_.velocityBias);
               _loc8_ = _loc31_ * _loc37_ + _loc30_ * _loc34_;
               _loc24_ = _loc9_.tangentMass * -_loc8_;
               _loc35_ = b2Math.b2Max(_loc9_.normalImpulse + _loc20_,0);
               _loc20_ = _loc35_ - _loc9_.normalImpulse;
               _loc16_ = _loc22_ * _loc9_.normalImpulse;
               _loc32_ = b2Math.b2Clamp(_loc9_.tangentImpulse + _loc24_,-_loc16_,_loc16_);
               _loc24_ = _loc32_ - _loc9_.tangentImpulse;
               _loc36_ = _loc20_ * _loc12_ + _loc24_ * _loc37_;
               _loc38_ = _loc20_ * _loc14_ + _loc24_ * _loc34_;
               _loc1_.x -= _loc4_ * _loc36_;
               _loc1_.y -= _loc4_ * _loc38_;
               _loc27_ -= _loc11_ * (_loc9_.r1.x * _loc38_ - _loc9_.r1.y * _loc36_);
               _loc6_.x += _loc2_ * _loc36_;
               _loc6_.y += _loc2_ * _loc38_;
               _loc29_ += _loc7_ * (_loc9_.r2.x * _loc38_ - _loc9_.r2.y * _loc36_);
               _loc9_.normalImpulse = _loc35_;
               _loc9_.tangentImpulse = _loc32_;
               _loc25_++;
            }
            _loc15_.m_angularVelocity = _loc27_;
            _loc10_.m_angularVelocity = _loc29_;
            _loc28_++;
         }
      }
      
      public function FinalizeVelocityConstraints() : void
      {
         var _loc6_:int = 0;
         var _loc1_:b2ContactConstraint = null;
         var _loc2_:b2Manifold = null;
         var _loc3_:int = 0;
         var _loc4_:b2ManifoldPoint = null;
         var _loc5_:b2ContactConstraintPoint = null;
         _loc6_ = 0;
         while(_loc6_ < m_constraintCount)
         {
            _loc1_ = m_constraints[_loc6_];
            _loc2_ = _loc1_.manifold;
            _loc3_ = 0;
            while(_loc3_ < _loc1_.pointCount)
            {
               _loc4_ = _loc2_.points[_loc3_];
               _loc5_ = _loc1_.points[_loc3_];
               _loc4_.normalImpulse = _loc5_.normalImpulse;
               _loc4_.tangentImpulse = _loc5_.tangentImpulse;
               _loc3_++;
            }
            _loc6_++;
         }
      }
      
      public function SolvePositionConstraints(param1:Number) : Boolean
      {
         var _loc37_:b2Mat22 = null;
         var _loc32_:b2Vec2 = null;
         var _loc33_:int = 0;
         var _loc26_:b2ContactConstraint = null;
         var _loc18_:b2Body = null;
         var _loc9_:b2Body = null;
         var _loc22_:b2Vec2 = null;
         var _loc24_:Number = NaN;
         var _loc23_:b2Vec2 = null;
         var _loc20_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc30_:int = 0;
         var _loc31_:int = 0;
         var _loc8_:b2ContactConstraintPoint = null;
         var _loc25_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc34_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc38_:Number = 0;
         _loc33_ = 0;
         while(_loc33_ < m_constraintCount)
         {
            _loc26_ = m_constraints[_loc33_];
            _loc18_ = _loc26_.body1;
            _loc9_ = _loc26_.body2;
            _loc22_ = _loc18_.m_sweep.c;
            _loc24_ = _loc18_.m_sweep.a;
            _loc23_ = _loc9_.m_sweep.c;
            _loc20_ = _loc9_.m_sweep.a;
            _loc5_ = _loc18_.m_mass * _loc18_.m_invMass;
            _loc12_ = _loc18_.m_mass * _loc18_.m_invI;
            _loc3_ = _loc9_.m_mass * _loc9_.m_invMass;
            _loc7_ = _loc9_.m_mass * _loc9_.m_invI;
            _loc13_ = _loc26_.normal.x;
            _loc14_ = _loc26_.normal.y;
            _loc30_ = _loc26_.pointCount;
            _loc31_ = 0;
            while(_loc31_ < _loc30_)
            {
               _loc8_ = _loc26_.points[_loc31_];
               _loc37_ = _loc18_.m_xf.R;
               _loc32_ = _loc18_.m_sweep.localCenter;
               _loc25_ = _loc8_.localAnchor1.x - _loc32_.x;
               _loc28_ = _loc8_.localAnchor1.y - _loc32_.y;
               _loc21_ = _loc37_.col1.x * _loc25_ + _loc37_.col2.x * _loc28_;
               _loc28_ = _loc37_.col1.y * _loc25_ + _loc37_.col2.y * _loc28_;
               _loc25_ = _loc21_;
               _loc37_ = _loc9_.m_xf.R;
               _loc32_ = _loc9_.m_sweep.localCenter;
               _loc4_ = _loc8_.localAnchor2.x - _loc32_.x;
               _loc2_ = _loc8_.localAnchor2.y - _loc32_.y;
               _loc21_ = _loc37_.col1.x * _loc4_ + _loc37_.col2.x * _loc2_;
               _loc2_ = _loc37_.col1.y * _loc4_ + _loc37_.col2.y * _loc2_;
               _loc4_ = _loc21_;
               _loc16_ = _loc22_.x + _loc25_;
               _loc19_ = _loc22_.y + _loc28_;
               _loc36_ = _loc23_.x + _loc4_;
               _loc35_ = _loc23_.y + _loc2_;
               _loc11_ = _loc36_ - _loc16_;
               _loc10_ = _loc35_ - _loc19_;
               _loc27_ = _loc11_ * _loc13_ + _loc10_ * _loc14_ + _loc8_.separation;
               _loc38_ = b2Math.b2Min(_loc38_,_loc27_);
               _loc6_ = param1 * b2Math.b2Clamp(_loc27_ + 0.005,-0.2,0);
               _loc29_ = -_loc8_.equalizedMass * _loc6_;
               _loc34_ = _loc8_.positionImpulse;
               _loc8_.positionImpulse = b2Math.b2Max(_loc34_ + _loc29_,0);
               _loc29_ = _loc8_.positionImpulse - _loc34_;
               _loc15_ = _loc29_ * _loc13_;
               _loc17_ = _loc29_ * _loc14_;
               _loc22_.x -= _loc5_ * _loc15_;
               _loc22_.y -= _loc5_ * _loc17_;
               _loc24_ -= _loc12_ * (_loc25_ * _loc17_ - _loc28_ * _loc15_);
               _loc18_.m_sweep.a = _loc24_;
               _loc18_.SynchronizeTransform();
               _loc23_.x += _loc3_ * _loc15_;
               _loc23_.y += _loc3_ * _loc17_;
               _loc20_ += _loc7_ * (_loc4_ * _loc17_ - _loc2_ * _loc15_);
               _loc9_.m_sweep.a = _loc20_;
               _loc9_.SynchronizeTransform();
               _loc31_++;
            }
            _loc33_++;
         }
         return _loc38_ >= -1.5 * 0.005;
      }
   }
}

