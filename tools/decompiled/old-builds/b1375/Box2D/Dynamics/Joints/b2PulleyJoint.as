package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2PulleyJoint extends b2Joint
   {
      
      public static const b2_minPulleyLength:Number = 2;
      
      public var m_ground:b2Body;
      
      public var m_groundAnchor1:b2Vec2 = new b2Vec2();
      
      public var m_groundAnchor2:b2Vec2 = new b2Vec2();
      
      public var m_localAnchor1:b2Vec2 = new b2Vec2();
      
      public var m_localAnchor2:b2Vec2 = new b2Vec2();
      
      public var m_u1:b2Vec2 = new b2Vec2();
      
      public var m_u2:b2Vec2 = new b2Vec2();
      
      public var m_constant:Number;
      
      public var m_ratio:Number;
      
      public var m_maxLength1:Number;
      
      public var m_maxLength2:Number;
      
      public var m_pulleyMass:Number;
      
      public var m_limitMass1:Number;
      
      public var m_limitMass2:Number;
      
      public var m_force:Number;
      
      public var m_limitForce1:Number;
      
      public var m_limitForce2:Number;
      
      public var m_positionImpulse:Number;
      
      public var m_limitPositionImpulse1:Number;
      
      public var m_limitPositionImpulse2:Number;
      
      public var m_state:int;
      
      public var m_limitState1:int;
      
      public var m_limitState2:int;
      
      public function b2PulleyJoint(param1:b2PulleyJointDef)
      {
         var _loc2_:* = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         super(param1);
         m_ground = m_body1.m_world.m_groundBody;
         m_groundAnchor1.x = param1.groundAnchor1.x - m_ground.m_xf.position.x;
         m_groundAnchor1.y = param1.groundAnchor1.y - m_ground.m_xf.position.y;
         m_groundAnchor2.x = param1.groundAnchor2.x - m_ground.m_xf.position.x;
         m_groundAnchor2.y = param1.groundAnchor2.y - m_ground.m_xf.position.y;
         m_localAnchor1.SetV(param1.localAnchor1);
         m_localAnchor2.SetV(param1.localAnchor2);
         m_ratio = param1.ratio;
         m_constant = param1.length1 + m_ratio * param1.length2;
         m_maxLength1 = b2Math.b2Min(param1.maxLength1,m_constant - m_ratio * 2);
         m_maxLength2 = b2Math.b2Min(param1.maxLength2,(m_constant - 2) / m_ratio);
         m_force = 0;
         m_limitForce1 = 0;
         m_limitForce2 = 0;
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return m_body1.GetWorldPoint(m_localAnchor1);
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(m_localAnchor2);
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         var _loc1_:b2Vec2 = m_u2.Copy();
         _loc1_.Multiply(m_force);
         return _loc1_;
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
      
      public function GetGroundAnchor1() : b2Vec2
      {
         var _loc1_:b2Vec2 = m_ground.m_xf.position.Copy();
         _loc1_.Add(m_groundAnchor1);
         return _loc1_;
      }
      
      public function GetGroundAnchor2() : b2Vec2
      {
         var _loc1_:b2Vec2 = m_ground.m_xf.position.Copy();
         _loc1_.Add(m_groundAnchor2);
         return _loc1_;
      }
      
      public function GetLength1() : Number
      {
         var _loc1_:b2Vec2 = m_body1.GetWorldPoint(m_localAnchor1);
         var _loc4_:Number = m_ground.m_xf.position.x + m_groundAnchor1.x;
         var _loc5_:Number = m_ground.m_xf.position.y + m_groundAnchor1.y;
         var _loc3_:Number = _loc1_.x - _loc4_;
         var _loc2_:Number = _loc1_.y - _loc5_;
         return Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
      }
      
      public function GetLength2() : Number
      {
         var _loc1_:b2Vec2 = m_body2.GetWorldPoint(m_localAnchor2);
         var _loc4_:Number = m_ground.m_xf.position.x + m_groundAnchor2.x;
         var _loc5_:Number = m_ground.m_xf.position.y + m_groundAnchor2.y;
         var _loc3_:Number = _loc1_.x - _loc4_;
         var _loc2_:Number = _loc1_.y - _loc5_;
         return Math.sqrt(_loc3_ * _loc3_ + _loc2_ * _loc2_);
      }
      
      public function GetRatio() : Number
      {
         return m_ratio;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc26_:b2Mat22 = null;
         var _loc7_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc15_:b2Body = m_body1;
         var _loc6_:b2Body = m_body2;
         _loc26_ = _loc15_.m_xf.R;
         var _loc19_:Number = m_localAnchor1.x - _loc15_.m_sweep.localCenter.x;
         var _loc21_:Number = m_localAnchor1.y - _loc15_.m_sweep.localCenter.y;
         var _loc17_:Number = _loc26_.col1.x * _loc19_ + _loc26_.col2.x * _loc21_;
         _loc21_ = _loc26_.col1.y * _loc19_ + _loc26_.col2.y * _loc21_;
         _loc19_ = _loc17_;
         _loc26_ = _loc6_.m_xf.R;
         var _loc3_:Number = m_localAnchor2.x - _loc6_.m_sweep.localCenter.x;
         var _loc2_:Number = m_localAnchor2.y - _loc6_.m_sweep.localCenter.y;
         _loc17_ = _loc26_.col1.x * _loc3_ + _loc26_.col2.x * _loc2_;
         _loc2_ = _loc26_.col1.y * _loc3_ + _loc26_.col2.y * _loc2_;
         _loc3_ = _loc17_;
         var _loc12_:Number = _loc15_.m_sweep.c.x + _loc19_;
         var _loc16_:Number = _loc15_.m_sweep.c.y + _loc21_;
         var _loc25_:Number = _loc6_.m_sweep.c.x + _loc3_;
         var _loc24_:Number = _loc6_.m_sweep.c.y + _loc2_;
         var _loc13_:Number = m_ground.m_xf.position.x + m_groundAnchor1.x;
         var _loc14_:Number = m_ground.m_xf.position.y + m_groundAnchor1.y;
         var _loc11_:Number = m_ground.m_xf.position.x + m_groundAnchor2.x;
         var _loc10_:Number = m_ground.m_xf.position.y + m_groundAnchor2.y;
         m_u1.Set(_loc12_ - _loc13_,_loc16_ - _loc14_);
         m_u2.Set(_loc25_ - _loc11_,_loc24_ - _loc10_);
         var _loc8_:Number = m_u1.Length();
         var _loc9_:Number = m_u2.Length();
         if(_loc8_ > 0.005)
         {
            m_u1.Multiply(1 / _loc8_);
         }
         else
         {
            m_u1.SetZero();
         }
         if(_loc9_ > 0.005)
         {
            m_u2.Multiply(1 / _loc9_);
         }
         else
         {
            m_u2.SetZero();
         }
         var _loc5_:Number = m_constant - _loc8_ - m_ratio * _loc9_;
         if(_loc5_ > 0)
         {
            m_state = 0;
            m_force = 0;
         }
         else
         {
            m_state = 2;
            m_positionImpulse = 0;
         }
         if(_loc8_ < m_maxLength1)
         {
            m_limitState1 = 0;
            m_limitForce1 = 0;
         }
         else
         {
            m_limitState1 = 2;
            m_limitPositionImpulse1 = 0;
         }
         if(_loc9_ < m_maxLength2)
         {
            m_limitState2 = 0;
            m_limitForce2 = 0;
         }
         else
         {
            m_limitState2 = 2;
            m_limitPositionImpulse2 = 0;
         }
         var _loc18_:Number = _loc19_ * m_u1.y - _loc21_ * m_u1.x;
         var _loc20_:Number = _loc3_ * m_u2.y - _loc2_ * m_u2.x;
         m_limitMass1 = _loc15_.m_invMass + _loc15_.m_invI * _loc18_ * _loc18_;
         m_limitMass2 = _loc6_.m_invMass + _loc6_.m_invI * _loc20_ * _loc20_;
         m_pulleyMass = m_limitMass1 + m_ratio * m_ratio * m_limitMass2;
         m_limitMass1 = 1 / m_limitMass1;
         m_limitMass2 = 1 / m_limitMass2;
         m_pulleyMass = 1 / m_pulleyMass;
         if(param1.warmStarting)
         {
            _loc7_ = param1.dt * (-m_force - m_limitForce1) * m_u1.x;
            _loc4_ = param1.dt * (-m_force - m_limitForce1) * m_u1.y;
            _loc22_ = param1.dt * (-m_ratio * m_force - m_limitForce2) * m_u2.x;
            _loc23_ = param1.dt * (-m_ratio * m_force - m_limitForce2) * m_u2.y;
            _loc15_.m_linearVelocity.x += _loc15_.m_invMass * _loc7_;
            _loc15_.m_linearVelocity.y += _loc15_.m_invMass * _loc4_;
            _loc15_.m_angularVelocity += _loc15_.m_invI * (_loc19_ * _loc4_ - _loc21_ * _loc7_);
            _loc6_.m_linearVelocity.x += _loc6_.m_invMass * _loc22_;
            _loc6_.m_linearVelocity.y += _loc6_.m_invMass * _loc23_;
            _loc6_.m_angularVelocity += _loc6_.m_invI * (_loc3_ * _loc23_ - _loc2_ * _loc22_);
         }
         else
         {
            m_force = 0;
            m_limitForce1 = 0;
            m_limitForce2 = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc15_:b2Mat22 = null;
         var _loc12_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc18_:b2Body = m_body1;
         var _loc8_:b2Body = m_body2;
         _loc15_ = _loc18_.m_xf.R;
         var _loc4_:Number = m_localAnchor1.x - _loc18_.m_sweep.localCenter.x;
         var _loc6_:Number = m_localAnchor1.y - _loc18_.m_sweep.localCenter.y;
         var _loc20_:Number = _loc15_.col1.x * _loc4_ + _loc15_.col2.x * _loc6_;
         _loc6_ = _loc15_.col1.y * _loc4_ + _loc15_.col2.y * _loc6_;
         _loc4_ = _loc20_;
         _loc15_ = _loc8_.m_xf.R;
         var _loc3_:Number = m_localAnchor2.x - _loc8_.m_sweep.localCenter.x;
         var _loc2_:Number = m_localAnchor2.y - _loc8_.m_sweep.localCenter.y;
         _loc20_ = _loc15_.col1.x * _loc3_ + _loc15_.col2.x * _loc2_;
         _loc2_ = _loc15_.col1.y * _loc3_ + _loc15_.col2.y * _loc2_;
         _loc3_ = _loc20_;
         if(m_state == 2)
         {
            _loc12_ = _loc18_.m_linearVelocity.x + -_loc18_.m_angularVelocity * _loc6_;
            _loc14_ = _loc18_.m_linearVelocity.y + _loc18_.m_angularVelocity * _loc4_;
            _loc16_ = _loc8_.m_linearVelocity.x + -_loc8_.m_angularVelocity * _loc2_;
            _loc17_ = _loc8_.m_linearVelocity.y + _loc8_.m_angularVelocity * _loc3_;
            _loc13_ = -(m_u1.x * _loc12_ + m_u1.y * _loc14_) - m_ratio * (m_u2.x * _loc16_ + m_u2.y * _loc17_);
            _loc19_ = -param1.inv_dt * m_pulleyMass * _loc13_;
            _loc11_ = m_force;
            m_force = b2Math.b2Max(0,m_force + _loc19_);
            _loc19_ = m_force - _loc11_;
            _loc7_ = -param1.dt * _loc19_ * m_u1.x;
            _loc5_ = -param1.dt * _loc19_ * m_u1.y;
            _loc9_ = -param1.dt * m_ratio * _loc19_ * m_u2.x;
            _loc10_ = -param1.dt * m_ratio * _loc19_ * m_u2.y;
            _loc18_.m_linearVelocity.x += _loc18_.m_invMass * _loc7_;
            _loc18_.m_linearVelocity.y += _loc18_.m_invMass * _loc5_;
            _loc18_.m_angularVelocity += _loc18_.m_invI * (_loc4_ * _loc5_ - _loc6_ * _loc7_);
            _loc8_.m_linearVelocity.x += _loc8_.m_invMass * _loc9_;
            _loc8_.m_linearVelocity.y += _loc8_.m_invMass * _loc10_;
            _loc8_.m_angularVelocity += _loc8_.m_invI * (_loc3_ * _loc10_ - _loc2_ * _loc9_);
         }
         if(m_limitState1 == 2)
         {
            _loc12_ = _loc18_.m_linearVelocity.x + -_loc18_.m_angularVelocity * _loc6_;
            _loc14_ = _loc18_.m_linearVelocity.y + _loc18_.m_angularVelocity * _loc4_;
            _loc13_ = -(m_u1.x * _loc12_ + m_u1.y * _loc14_);
            _loc19_ = -param1.inv_dt * m_limitMass1 * _loc13_;
            _loc11_ = m_limitForce1;
            m_limitForce1 = b2Math.b2Max(0,m_limitForce1 + _loc19_);
            _loc19_ = m_limitForce1 - _loc11_;
            _loc7_ = -param1.dt * _loc19_ * m_u1.x;
            _loc5_ = -param1.dt * _loc19_ * m_u1.y;
            _loc18_.m_linearVelocity.x += _loc18_.m_invMass * _loc7_;
            _loc18_.m_linearVelocity.y += _loc18_.m_invMass * _loc5_;
            _loc18_.m_angularVelocity += _loc18_.m_invI * (_loc4_ * _loc5_ - _loc6_ * _loc7_);
         }
         if(m_limitState2 == 2)
         {
            _loc16_ = _loc8_.m_linearVelocity.x + -_loc8_.m_angularVelocity * _loc2_;
            _loc17_ = _loc8_.m_linearVelocity.y + _loc8_.m_angularVelocity * _loc3_;
            _loc13_ = -(m_u2.x * _loc16_ + m_u2.y * _loc17_);
            _loc19_ = -param1.inv_dt * m_limitMass2 * _loc13_;
            _loc11_ = m_limitForce2;
            m_limitForce2 = b2Math.b2Max(0,m_limitForce2 + _loc19_);
            _loc19_ = m_limitForce2 - _loc11_;
            _loc9_ = -param1.dt * _loc19_ * m_u2.x;
            _loc10_ = -param1.dt * _loc19_ * m_u2.y;
            _loc8_.m_linearVelocity.x += _loc8_.m_invMass * _loc9_;
            _loc8_.m_linearVelocity.y += _loc8_.m_invMass * _loc10_;
            _loc8_.m_angularVelocity += _loc8_.m_invI * (_loc3_ * _loc10_ - _loc2_ * _loc9_);
         }
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc20_:b2Mat22 = null;
         var _loc3_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc21_:b2Body = m_body1;
         var _loc8_:b2Body = m_body2;
         var _loc16_:Number = m_ground.m_xf.position.x + m_groundAnchor1.x;
         var _loc18_:Number = m_ground.m_xf.position.y + m_groundAnchor1.y;
         var _loc12_:Number = m_ground.m_xf.position.x + m_groundAnchor2.x;
         var _loc11_:Number = m_ground.m_xf.position.y + m_groundAnchor2.y;
         var _loc4_:Number = 0;
         if(m_state == 2)
         {
            _loc20_ = _loc21_.m_xf.R;
            _loc3_ = m_localAnchor1.x - _loc21_.m_sweep.localCenter.x;
            _loc6_ = m_localAnchor1.y - _loc21_.m_sweep.localCenter.y;
            _loc23_ = _loc20_.col1.x * _loc3_ + _loc20_.col2.x * _loc6_;
            _loc6_ = _loc20_.col1.y * _loc3_ + _loc20_.col2.y * _loc6_;
            _loc3_ = _loc23_;
            _loc20_ = _loc8_.m_xf.R;
            _loc2_ = m_localAnchor2.x - _loc8_.m_sweep.localCenter.x;
            _loc1_ = m_localAnchor2.y - _loc8_.m_sweep.localCenter.y;
            _loc23_ = _loc20_.col1.x * _loc2_ + _loc20_.col2.x * _loc1_;
            _loc1_ = _loc20_.col1.y * _loc2_ + _loc20_.col2.y * _loc1_;
            _loc2_ = _loc23_;
            _loc14_ = _loc21_.m_sweep.c.x + _loc3_;
            _loc22_ = _loc21_.m_sweep.c.y + _loc6_;
            _loc17_ = _loc8_.m_sweep.c.x + _loc2_;
            _loc15_ = _loc8_.m_sweep.c.y + _loc1_;
            m_u1.Set(_loc14_ - _loc16_,_loc22_ - _loc18_);
            m_u2.Set(_loc17_ - _loc12_,_loc15_ - _loc11_);
            _loc9_ = m_u1.Length();
            _loc10_ = m_u2.Length();
            if(_loc9_ > 0.005)
            {
               m_u1.Multiply(1 / _loc9_);
            }
            else
            {
               m_u1.SetZero();
            }
            if(_loc10_ > 0.005)
            {
               m_u2.Multiply(1 / _loc10_);
            }
            else
            {
               m_u2.SetZero();
            }
            _loc5_ = m_constant - _loc9_ - m_ratio * _loc10_;
            _loc4_ = b2Math.b2Max(_loc4_,-_loc5_);
            _loc5_ = b2Math.b2Clamp(_loc5_ + 0.005,-0.2,0);
            _loc13_ = -m_pulleyMass * _loc5_;
            _loc19_ = m_positionImpulse;
            m_positionImpulse = b2Math.b2Max(0,m_positionImpulse + _loc13_);
            _loc13_ = m_positionImpulse - _loc19_;
            _loc14_ = -_loc13_ * m_u1.x;
            _loc22_ = -_loc13_ * m_u1.y;
            _loc17_ = -m_ratio * _loc13_ * m_u2.x;
            _loc15_ = -m_ratio * _loc13_ * m_u2.y;
            _loc21_.m_sweep.c.x += _loc21_.m_invMass * _loc14_;
            _loc21_.m_sweep.c.y += _loc21_.m_invMass * _loc22_;
            _loc21_.m_sweep.a += _loc21_.m_invI * (_loc3_ * _loc22_ - _loc6_ * _loc14_);
            _loc8_.m_sweep.c.x += _loc8_.m_invMass * _loc17_;
            _loc8_.m_sweep.c.y += _loc8_.m_invMass * _loc15_;
            _loc8_.m_sweep.a += _loc8_.m_invI * (_loc2_ * _loc15_ - _loc1_ * _loc17_);
            _loc21_.SynchronizeTransform();
            _loc8_.SynchronizeTransform();
         }
         if(m_limitState1 == 2)
         {
            _loc20_ = _loc21_.m_xf.R;
            _loc3_ = m_localAnchor1.x - _loc21_.m_sweep.localCenter.x;
            _loc6_ = m_localAnchor1.y - _loc21_.m_sweep.localCenter.y;
            _loc23_ = _loc20_.col1.x * _loc3_ + _loc20_.col2.x * _loc6_;
            _loc6_ = _loc20_.col1.y * _loc3_ + _loc20_.col2.y * _loc6_;
            _loc3_ = _loc23_;
            _loc14_ = _loc21_.m_sweep.c.x + _loc3_;
            _loc22_ = _loc21_.m_sweep.c.y + _loc6_;
            m_u1.Set(_loc14_ - _loc16_,_loc22_ - _loc18_);
            _loc9_ = m_u1.Length();
            if(_loc9_ > 0.005)
            {
               m_u1.x *= 1 / _loc9_;
               m_u1.y *= 1 / _loc9_;
            }
            else
            {
               m_u1.SetZero();
            }
            _loc5_ = m_maxLength1 - _loc9_;
            _loc4_ = b2Math.b2Max(_loc4_,-_loc5_);
            _loc5_ = b2Math.b2Clamp(_loc5_ + 0.005,-0.2,0);
            _loc13_ = -m_limitMass1 * _loc5_;
            _loc7_ = m_limitPositionImpulse1;
            m_limitPositionImpulse1 = b2Math.b2Max(0,m_limitPositionImpulse1 + _loc13_);
            _loc13_ = m_limitPositionImpulse1 - _loc7_;
            _loc14_ = -_loc13_ * m_u1.x;
            _loc22_ = -_loc13_ * m_u1.y;
            _loc21_.m_sweep.c.x += _loc21_.m_invMass * _loc14_;
            _loc21_.m_sweep.c.y += _loc21_.m_invMass * _loc22_;
            _loc21_.m_sweep.a += _loc21_.m_invI * (_loc3_ * _loc22_ - _loc6_ * _loc14_);
            _loc21_.SynchronizeTransform();
         }
         if(m_limitState2 == 2)
         {
            _loc20_ = _loc8_.m_xf.R;
            _loc2_ = m_localAnchor2.x - _loc8_.m_sweep.localCenter.x;
            _loc1_ = m_localAnchor2.y - _loc8_.m_sweep.localCenter.y;
            _loc23_ = _loc20_.col1.x * _loc2_ + _loc20_.col2.x * _loc1_;
            _loc1_ = _loc20_.col1.y * _loc2_ + _loc20_.col2.y * _loc1_;
            _loc2_ = _loc23_;
            _loc17_ = _loc8_.m_sweep.c.x + _loc2_;
            _loc15_ = _loc8_.m_sweep.c.y + _loc1_;
            m_u2.Set(_loc17_ - _loc12_,_loc15_ - _loc11_);
            _loc10_ = m_u2.Length();
            if(_loc10_ > 0.005)
            {
               m_u2.x *= 1 / _loc10_;
               m_u2.y *= 1 / _loc10_;
            }
            else
            {
               m_u2.SetZero();
            }
            _loc5_ = m_maxLength2 - _loc10_;
            _loc4_ = b2Math.b2Max(_loc4_,-_loc5_);
            _loc5_ = b2Math.b2Clamp(_loc5_ + 0.005,-0.2,0);
            _loc13_ = -m_limitMass2 * _loc5_;
            _loc7_ = m_limitPositionImpulse2;
            m_limitPositionImpulse2 = b2Math.b2Max(0,m_limitPositionImpulse2 + _loc13_);
            _loc13_ = m_limitPositionImpulse2 - _loc7_;
            _loc17_ = -_loc13_ * m_u2.x;
            _loc15_ = -_loc13_ * m_u2.y;
            _loc8_.m_sweep.c.x += _loc8_.m_invMass * _loc17_;
            _loc8_.m_sweep.c.y += _loc8_.m_invMass * _loc15_;
            _loc8_.m_sweep.a += _loc8_.m_invI * (_loc2_ * _loc15_ - _loc1_ * _loc17_);
            _loc8_.SynchronizeTransform();
         }
         return _loc4_ < 0.005;
      }
   }
}

