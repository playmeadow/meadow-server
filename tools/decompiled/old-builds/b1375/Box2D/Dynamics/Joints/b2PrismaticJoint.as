package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2PrismaticJoint extends b2Joint
   {
      
      public var m_localAnchor1:b2Vec2 = new b2Vec2();
      
      public var m_localAnchor2:b2Vec2 = new b2Vec2();
      
      public var m_localXAxis1:b2Vec2 = new b2Vec2();
      
      public var m_localYAxis1:b2Vec2 = new b2Vec2();
      
      public var m_refAngle:Number;
      
      public var m_linearJacobian:b2Jacobian = new b2Jacobian();
      
      public var m_linearMass:Number;
      
      public var m_force:Number;
      
      public var m_angularMass:Number;
      
      public var m_torque:Number;
      
      public var m_motorJacobian:b2Jacobian = new b2Jacobian();
      
      public var m_motorMass:Number;
      
      public var m_motorForce:Number;
      
      public var m_limitForce:Number;
      
      public var m_limitPositionImpulse:Number;
      
      public var m_lowerTranslation:Number;
      
      public var m_upperTranslation:Number;
      
      public var m_maxMotorForce:Number;
      
      public var m_motorSpeed:Number;
      
      public var m_enableLimit:Boolean;
      
      public var m_enableMotor:Boolean;
      
      public var m_limitState:int;
      
      public function b2PrismaticJoint(param1:b2PrismaticJointDef)
      {
         var _loc2_:* = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         super(param1);
         m_localAnchor1.SetV(param1.localAnchor1);
         m_localAnchor2.SetV(param1.localAnchor2);
         m_localXAxis1.SetV(param1.localAxis1);
         m_localYAxis1.x = -m_localXAxis1.y;
         m_localYAxis1.y = m_localXAxis1.x;
         m_refAngle = param1.referenceAngle;
         m_linearJacobian.SetZero();
         m_linearMass = 0;
         m_force = 0;
         m_angularMass = 0;
         m_torque = 0;
         m_motorJacobian.SetZero();
         m_motorMass = 0;
         m_motorForce = 0;
         m_limitForce = 0;
         m_limitPositionImpulse = 0;
         m_lowerTranslation = param1.lowerTranslation;
         m_upperTranslation = param1.upperTranslation;
         m_maxMotorForce = param1.maxMotorForce;
         m_motorSpeed = param1.motorSpeed;
         m_enableLimit = param1.enableLimit;
         m_enableMotor = param1.enableMotor;
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
         var _loc5_:b2Mat22 = m_body1.m_xf.R;
         var _loc1_:Number = m_limitForce * (_loc5_.col1.x * m_localXAxis1.x + _loc5_.col2.x * m_localXAxis1.y);
         var _loc2_:Number = m_limitForce * (_loc5_.col1.y * m_localXAxis1.x + _loc5_.col2.y * m_localXAxis1.y);
         var _loc3_:Number = m_force * (_loc5_.col1.x * m_localYAxis1.x + _loc5_.col2.x * m_localYAxis1.y);
         var _loc4_:Number = m_force * (_loc5_.col1.y * m_localYAxis1.x + _loc5_.col2.y * m_localYAxis1.y);
         return new b2Vec2(m_limitForce * _loc1_ + m_force * _loc3_,m_limitForce * _loc2_ + m_force * _loc4_);
      }
      
      override public function GetReactionTorque() : Number
      {
         return m_torque;
      }
      
      public function GetJointTranslation() : Number
      {
         var _loc5_:* = null;
         var _loc6_:b2Body = m_body1;
         var _loc7_:b2Body = m_body2;
         var _loc4_:b2Vec2 = _loc6_.GetWorldPoint(m_localAnchor1);
         var _loc3_:b2Vec2 = _loc7_.GetWorldPoint(m_localAnchor2);
         var _loc9_:Number = _loc3_.x - _loc4_.x;
         var _loc8_:Number = _loc3_.y - _loc4_.y;
         var _loc1_:b2Vec2 = _loc6_.GetWorldVector(m_localXAxis1);
         return _loc1_.x * _loc9_ + _loc1_.y * _loc8_;
      }
      
      public function GetJointSpeed() : Number
      {
         var _loc17_:b2Mat22 = null;
         var _loc18_:b2Body = m_body1;
         var _loc9_:b2Body = m_body2;
         _loc17_ = _loc18_.m_xf.R;
         var _loc5_:Number = m_localAnchor1.x - _loc18_.m_sweep.localCenter.x;
         var _loc8_:Number = m_localAnchor1.y - _loc18_.m_sweep.localCenter.y;
         var _loc20_:Number = _loc17_.col1.x * _loc5_ + _loc17_.col2.x * _loc8_;
         _loc8_ = _loc17_.col1.y * _loc5_ + _loc17_.col2.y * _loc8_;
         _loc5_ = _loc20_;
         _loc17_ = _loc9_.m_xf.R;
         var _loc4_:Number = m_localAnchor2.x - _loc9_.m_sweep.localCenter.x;
         var _loc3_:Number = m_localAnchor2.y - _loc9_.m_sweep.localCenter.y;
         _loc20_ = _loc17_.col1.x * _loc4_ + _loc17_.col2.x * _loc3_;
         _loc3_ = _loc17_.col1.y * _loc4_ + _loc17_.col2.y * _loc3_;
         _loc4_ = _loc20_;
         var _loc14_:Number = _loc18_.m_sweep.c.x + _loc5_;
         var _loc19_:Number = _loc18_.m_sweep.c.y + _loc8_;
         var _loc16_:Number = _loc9_.m_sweep.c.x + _loc4_;
         var _loc15_:Number = _loc9_.m_sweep.c.y + _loc3_;
         var _loc11_:Number = _loc16_ - _loc14_;
         var _loc10_:Number = _loc15_ - _loc19_;
         var _loc2_:b2Vec2 = _loc18_.GetWorldVector(m_localXAxis1);
         var _loc1_:b2Vec2 = _loc18_.m_linearVelocity;
         var _loc7_:b2Vec2 = _loc9_.m_linearVelocity;
         var _loc12_:Number = _loc18_.m_angularVelocity;
         var _loc13_:Number = _loc9_.m_angularVelocity;
         return _loc11_ * (-_loc12_ * _loc2_.y) + _loc10_ * (_loc12_ * _loc2_.x) + (_loc2_.x * (_loc7_.x + -_loc13_ * _loc3_ - _loc1_.x - -_loc12_ * _loc8_) + _loc2_.y * (_loc7_.y + _loc13_ * _loc4_ - _loc1_.y - _loc12_ * _loc5_));
      }
      
      public function IsLimitEnabled() : Boolean
      {
         return m_enableLimit;
      }
      
      public function EnableLimit(param1:Boolean) : void
      {
         m_enableLimit = param1;
      }
      
      public function GetLowerLimit() : Number
      {
         return m_lowerTranslation;
      }
      
      public function GetUpperLimit() : Number
      {
         return m_upperTranslation;
      }
      
      public function SetLimits(param1:Number, param2:Number) : void
      {
         m_lowerTranslation = param1;
         m_upperTranslation = param2;
      }
      
      public function IsMotorEnabled() : Boolean
      {
         return m_enableMotor;
      }
      
      public function EnableMotor(param1:Boolean) : void
      {
         m_enableMotor = param1;
      }
      
      public function SetMotorSpeed(param1:Number) : void
      {
         m_motorSpeed = param1;
      }
      
      public function GetMotorSpeed() : Number
      {
         return m_motorSpeed;
      }
      
      public function SetMaxMotorForce(param1:Number) : void
      {
         m_maxMotorForce = param1;
      }
      
      public function GetMotorForce() : Number
      {
         return m_motorForce;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc28_:b2Mat22 = null;
         var _loc18_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc16_:b2Body = m_body1;
         var _loc13_:b2Body = m_body2;
         _loc28_ = _loc16_.m_xf.R;
         var _loc21_:Number = m_localAnchor1.x - _loc16_.m_sweep.localCenter.x;
         var _loc22_:Number = m_localAnchor1.y - _loc16_.m_sweep.localCenter.y;
         _loc18_ = _loc28_.col1.x * _loc21_ + _loc28_.col2.x * _loc22_;
         _loc22_ = _loc28_.col1.y * _loc21_ + _loc28_.col2.y * _loc22_;
         _loc21_ = _loc18_;
         _loc28_ = _loc13_.m_xf.R;
         var _loc7_:Number = m_localAnchor2.x - _loc13_.m_sweep.localCenter.x;
         var _loc5_:Number = m_localAnchor2.y - _loc13_.m_sweep.localCenter.y;
         _loc18_ = _loc28_.col1.x * _loc7_ + _loc28_.col2.x * _loc5_;
         _loc5_ = _loc28_.col1.y * _loc7_ + _loc28_.col2.y * _loc5_;
         _loc7_ = _loc18_;
         var _loc6_:Number = _loc16_.m_invMass;
         var _loc4_:Number = _loc13_.m_invMass;
         var _loc15_:Number = _loc16_.m_invI;
         var _loc12_:Number = _loc13_.m_invI;
         _loc28_ = _loc16_.m_xf.R;
         var _loc9_:Number = _loc28_.col1.x * m_localYAxis1.x + _loc28_.col2.x * m_localYAxis1.y;
         var _loc27_:Number = _loc28_.col1.y * m_localYAxis1.x + _loc28_.col2.y * m_localYAxis1.y;
         var _loc8_:Number = _loc13_.m_sweep.c.x + _loc7_ - _loc16_.m_sweep.c.x;
         var _loc10_:Number = _loc13_.m_sweep.c.y + _loc5_ - _loc16_.m_sweep.c.y;
         m_linearJacobian.linear1.x = -_loc9_;
         m_linearJacobian.linear1.y = -_loc27_;
         m_linearJacobian.linear2.x = _loc9_;
         m_linearJacobian.linear2.y = _loc27_;
         m_linearJacobian.angular1 = -(_loc8_ * _loc27_ - _loc10_ * _loc9_);
         m_linearJacobian.angular2 = _loc7_ * _loc27_ - _loc5_ * _loc9_;
         m_linearMass = _loc6_ + _loc15_ * m_linearJacobian.angular1 * m_linearJacobian.angular1 + _loc4_ + _loc12_ * m_linearJacobian.angular2 * m_linearJacobian.angular2;
         m_linearMass = 1 / m_linearMass;
         m_angularMass = _loc15_ + _loc12_;
         if(m_angularMass > Number.MIN_VALUE)
         {
            m_angularMass = 1 / m_angularMass;
         }
         if(m_enableLimit || m_enableMotor)
         {
            _loc28_ = _loc16_.m_xf.R;
            _loc2_ = _loc28_.col1.x * m_localXAxis1.x + _loc28_.col2.x * m_localXAxis1.y;
            _loc3_ = _loc28_.col1.y * m_localXAxis1.x + _loc28_.col2.y * m_localXAxis1.y;
            m_motorJacobian.linear1.x = -_loc2_;
            m_motorJacobian.linear1.y = -_loc3_;
            m_motorJacobian.linear2.x = _loc2_;
            m_motorJacobian.linear2.y = _loc3_;
            m_motorJacobian.angular1 = -(_loc8_ * _loc3_ - _loc10_ * _loc2_);
            m_motorJacobian.angular2 = _loc7_ * _loc3_ - _loc5_ * _loc2_;
            m_motorMass = _loc6_ + _loc15_ * m_motorJacobian.angular1 * m_motorJacobian.angular1 + _loc4_ + _loc12_ * m_motorJacobian.angular2 * m_motorJacobian.angular2;
            m_motorMass = 1 / m_motorMass;
            if(m_enableLimit)
            {
               _loc26_ = _loc8_ - _loc21_;
               _loc24_ = _loc10_ - _loc22_;
               _loc17_ = _loc2_ * _loc26_ + _loc3_ * _loc24_;
               if(b2Math.b2Abs(m_upperTranslation - m_lowerTranslation) < 2 * 0.005)
               {
                  m_limitState = 3;
               }
               else if(_loc17_ <= m_lowerTranslation)
               {
                  if(m_limitState != 1)
                  {
                     m_limitForce = 0;
                  }
                  m_limitState = 1;
               }
               else if(_loc17_ >= m_upperTranslation)
               {
                  if(m_limitState != 2)
                  {
                     m_limitForce = 0;
                  }
                  m_limitState = 2;
               }
               else
               {
                  m_limitState = 0;
                  m_limitForce = 0;
               }
            }
         }
         if(m_enableMotor == false)
         {
            m_motorForce = 0;
         }
         if(m_enableLimit == false)
         {
            m_limitForce = 0;
         }
         if(param1.warmStarting)
         {
            _loc14_ = param1.dt * (m_force * m_linearJacobian.linear1.x + (m_motorForce + m_limitForce) * m_motorJacobian.linear1.x);
            _loc11_ = param1.dt * (m_force * m_linearJacobian.linear1.y + (m_motorForce + m_limitForce) * m_motorJacobian.linear1.y);
            _loc23_ = param1.dt * (m_force * m_linearJacobian.linear2.x + (m_motorForce + m_limitForce) * m_motorJacobian.linear2.x);
            _loc25_ = param1.dt * (m_force * m_linearJacobian.linear2.y + (m_motorForce + m_limitForce) * m_motorJacobian.linear2.y);
            _loc19_ = param1.dt * (m_force * m_linearJacobian.angular1 - m_torque + (m_motorForce + m_limitForce) * m_motorJacobian.angular1);
            _loc20_ = param1.dt * (m_force * m_linearJacobian.angular2 + m_torque + (m_motorForce + m_limitForce) * m_motorJacobian.angular2);
            _loc16_.m_linearVelocity.x += _loc6_ * _loc14_;
            _loc16_.m_linearVelocity.y += _loc6_ * _loc11_;
            _loc16_.m_angularVelocity += _loc15_ * _loc19_;
            _loc13_.m_linearVelocity.x += _loc4_ * _loc23_;
            _loc13_.m_linearVelocity.y += _loc4_ * _loc25_;
            _loc13_.m_angularVelocity += _loc12_ * _loc20_;
         }
         else
         {
            m_force = 0;
            m_torque = 0;
            m_limitForce = 0;
            m_motorForce = 0;
         }
         m_limitPositionImpulse = 0;
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc12_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc16_:b2Body = m_body1;
         var _loc9_:b2Body = m_body2;
         var _loc3_:Number = _loc16_.m_invMass;
         var _loc2_:Number = _loc9_.m_invMass;
         var _loc11_:Number = _loc16_.m_invI;
         var _loc8_:Number = _loc9_.m_invI;
         var _loc17_:Number = m_linearJacobian.Compute(_loc16_.m_linearVelocity,_loc16_.m_angularVelocity,_loc9_.m_linearVelocity,_loc9_.m_angularVelocity);
         var _loc18_:Number = -param1.inv_dt * m_linearMass * _loc17_;
         m_force += _loc18_;
         var _loc15_:Number = param1.dt * _loc18_;
         _loc16_.m_linearVelocity.x += _loc3_ * _loc15_ * m_linearJacobian.linear1.x;
         _loc16_.m_linearVelocity.y += _loc3_ * _loc15_ * m_linearJacobian.linear1.y;
         _loc16_.m_angularVelocity += _loc11_ * _loc15_ * m_linearJacobian.angular1;
         _loc9_.m_linearVelocity.x += _loc2_ * _loc15_ * m_linearJacobian.linear2.x;
         _loc9_.m_linearVelocity.y += _loc2_ * _loc15_ * m_linearJacobian.linear2.y;
         _loc9_.m_angularVelocity += _loc8_ * _loc15_ * m_linearJacobian.angular2;
         var _loc13_:Number = _loc9_.m_angularVelocity - _loc16_.m_angularVelocity;
         var _loc10_:Number = -param1.inv_dt * m_angularMass * _loc13_;
         m_torque += _loc10_;
         var _loc7_:Number = param1.dt * _loc10_;
         _loc16_.m_angularVelocity -= _loc11_ * _loc7_;
         _loc9_.m_angularVelocity += _loc8_ * _loc7_;
         if(m_enableMotor && m_limitState != 3)
         {
            _loc4_ = m_motorJacobian.Compute(_loc16_.m_linearVelocity,_loc16_.m_angularVelocity,_loc9_.m_linearVelocity,_loc9_.m_angularVelocity) - m_motorSpeed;
            _loc6_ = -param1.inv_dt * m_motorMass * _loc4_;
            _loc19_ = m_motorForce;
            m_motorForce = b2Math.b2Clamp(m_motorForce + _loc6_,-m_maxMotorForce,m_maxMotorForce);
            _loc6_ = m_motorForce - _loc19_;
            _loc15_ = param1.dt * _loc6_;
            _loc16_.m_linearVelocity.x += _loc3_ * _loc15_ * m_motorJacobian.linear1.x;
            _loc16_.m_linearVelocity.y += _loc3_ * _loc15_ * m_motorJacobian.linear1.y;
            _loc16_.m_angularVelocity += _loc11_ * _loc15_ * m_motorJacobian.angular1;
            _loc9_.m_linearVelocity.x += _loc2_ * _loc15_ * m_motorJacobian.linear2.x;
            _loc9_.m_linearVelocity.y += _loc2_ * _loc15_ * m_motorJacobian.linear2.y;
            _loc9_.m_angularVelocity += _loc8_ * _loc15_ * m_motorJacobian.angular2;
         }
         if(m_enableLimit && m_limitState != 0)
         {
            _loc14_ = m_motorJacobian.Compute(_loc16_.m_linearVelocity,_loc16_.m_angularVelocity,_loc9_.m_linearVelocity,_loc9_.m_angularVelocity);
            _loc5_ = -param1.inv_dt * m_motorMass * _loc14_;
            if(m_limitState == 3)
            {
               m_limitForce += _loc5_;
            }
            else if(m_limitState == 1)
            {
               _loc12_ = m_limitForce;
               m_limitForce = b2Math.b2Max(m_limitForce + _loc5_,0);
               _loc5_ = m_limitForce - _loc12_;
            }
            else if(m_limitState == 2)
            {
               _loc12_ = m_limitForce;
               m_limitForce = b2Math.b2Min(m_limitForce + _loc5_,0);
               _loc5_ = m_limitForce - _loc12_;
            }
            _loc15_ = param1.dt * _loc5_;
            _loc16_.m_linearVelocity.x += _loc3_ * _loc15_ * m_motorJacobian.linear1.x;
            _loc16_.m_linearVelocity.y += _loc3_ * _loc15_ * m_motorJacobian.linear1.y;
            _loc16_.m_angularVelocity += _loc11_ * _loc15_ * m_motorJacobian.angular1;
            _loc9_.m_linearVelocity.x += _loc2_ * _loc15_ * m_motorJacobian.linear2.x;
            _loc9_.m_linearVelocity.y += _loc2_ * _loc15_ * m_motorJacobian.linear2.y;
            _loc9_.m_angularVelocity += _loc8_ * _loc15_ * m_motorJacobian.angular2;
         }
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc20_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc32_:b2Mat22 = null;
         var _loc19_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc17_:b2Body = m_body1;
         var _loc12_:b2Body = m_body2;
         var _loc6_:Number = _loc17_.m_invMass;
         var _loc3_:Number = _loc12_.m_invMass;
         var _loc13_:Number = _loc17_.m_invI;
         var _loc11_:Number = _loc12_.m_invI;
         _loc32_ = _loc17_.m_xf.R;
         var _loc22_:Number = m_localAnchor1.x - _loc17_.m_sweep.localCenter.x;
         var _loc23_:Number = m_localAnchor1.y - _loc17_.m_sweep.localCenter.y;
         _loc19_ = _loc32_.col1.x * _loc22_ + _loc32_.col2.x * _loc23_;
         _loc23_ = _loc32_.col1.y * _loc22_ + _loc32_.col2.y * _loc23_;
         _loc22_ = _loc19_;
         _loc32_ = _loc12_.m_xf.R;
         var _loc7_:Number = m_localAnchor2.x - _loc12_.m_sweep.localCenter.x;
         var _loc4_:Number = m_localAnchor2.y - _loc12_.m_sweep.localCenter.y;
         _loc19_ = _loc32_.col1.x * _loc7_ + _loc32_.col2.x * _loc4_;
         _loc4_ = _loc32_.col1.y * _loc7_ + _loc32_.col2.y * _loc4_;
         _loc7_ = _loc19_;
         var _loc15_:Number = _loc17_.m_sweep.c.x + _loc22_;
         var _loc18_:Number = _loc17_.m_sweep.c.y + _loc23_;
         var _loc30_:Number = _loc12_.m_sweep.c.x + _loc7_;
         var _loc29_:Number = _loc12_.m_sweep.c.y + _loc4_;
         var _loc27_:Number = _loc30_ - _loc15_;
         var _loc26_:Number = _loc29_ - _loc18_;
         _loc32_ = _loc17_.m_xf.R;
         var _loc9_:Number = _loc32_.col1.x * m_localYAxis1.x + _loc32_.col2.x * m_localYAxis1.y;
         var _loc31_:Number = _loc32_.col1.y * m_localYAxis1.x + _loc32_.col2.y * m_localYAxis1.y;
         var _loc5_:Number = _loc9_ * _loc27_ + _loc31_ * _loc26_;
         _loc5_ = b2Math.b2Clamp(_loc5_,-0.2,0.2);
         var _loc21_:Number = -m_linearMass * _loc5_;
         _loc17_.m_sweep.c.x += _loc6_ * _loc21_ * m_linearJacobian.linear1.x;
         _loc17_.m_sweep.c.y += _loc6_ * _loc21_ * m_linearJacobian.linear1.y;
         _loc17_.m_sweep.a += _loc13_ * _loc21_ * m_linearJacobian.angular1;
         _loc12_.m_sweep.c.x += _loc3_ * _loc21_ * m_linearJacobian.linear2.x;
         _loc12_.m_sweep.c.y += _loc3_ * _loc21_ * m_linearJacobian.linear2.y;
         _loc12_.m_sweep.a += _loc11_ * _loc21_ * m_linearJacobian.angular2;
         var _loc14_:Number = b2Math.b2Abs(_loc5_);
         var _loc16_:Number = _loc12_.m_sweep.a - _loc17_.m_sweep.a - m_refAngle;
         _loc16_ = b2Math.b2Clamp(_loc16_,-0.13962634015954636,0.13962634015954636);
         var _loc25_:Number = -m_angularMass * _loc16_;
         _loc17_.m_sweep.a -= _loc17_.m_invI * _loc25_;
         _loc12_.m_sweep.a += _loc12_.m_invI * _loc25_;
         _loc17_.SynchronizeTransform();
         _loc12_.SynchronizeTransform();
         var _loc24_:Number = b2Math.b2Abs(_loc16_);
         if(m_enableLimit && m_limitState != 0)
         {
            _loc32_ = _loc17_.m_xf.R;
            _loc22_ = m_localAnchor1.x - _loc17_.m_sweep.localCenter.x;
            _loc23_ = m_localAnchor1.y - _loc17_.m_sweep.localCenter.y;
            _loc19_ = _loc32_.col1.x * _loc22_ + _loc32_.col2.x * _loc23_;
            _loc23_ = _loc32_.col1.y * _loc22_ + _loc32_.col2.y * _loc23_;
            _loc22_ = _loc19_;
            _loc32_ = _loc12_.m_xf.R;
            _loc7_ = m_localAnchor2.x - _loc12_.m_sweep.localCenter.x;
            _loc4_ = m_localAnchor2.y - _loc12_.m_sweep.localCenter.y;
            _loc19_ = _loc32_.col1.x * _loc7_ + _loc32_.col2.x * _loc4_;
            _loc4_ = _loc32_.col1.y * _loc7_ + _loc32_.col2.y * _loc4_;
            _loc7_ = _loc19_;
            _loc15_ = _loc17_.m_sweep.c.x + _loc22_;
            _loc18_ = _loc17_.m_sweep.c.y + _loc23_;
            _loc30_ = _loc12_.m_sweep.c.x + _loc7_;
            _loc29_ = _loc12_.m_sweep.c.y + _loc4_;
            _loc27_ = _loc30_ - _loc15_;
            _loc26_ = _loc29_ - _loc18_;
            _loc32_ = _loc17_.m_xf.R;
            _loc1_ = _loc32_.col1.x * m_localXAxis1.x + _loc32_.col2.x * m_localXAxis1.y;
            _loc2_ = _loc32_.col1.y * m_localXAxis1.x + _loc32_.col2.y * m_localXAxis1.y;
            _loc8_ = _loc1_ * _loc27_ + _loc2_ * _loc26_;
            _loc10_ = 0;
            if(m_limitState == 3)
            {
               _loc20_ = b2Math.b2Clamp(_loc8_,-0.2,0.2);
               _loc10_ = -m_motorMass * _loc20_;
               _loc14_ = b2Math.b2Max(_loc14_,b2Math.b2Abs(_loc16_));
            }
            else if(m_limitState == 1)
            {
               _loc20_ = _loc8_ - m_lowerTranslation;
               _loc14_ = b2Math.b2Max(_loc14_,-_loc20_);
               _loc20_ = b2Math.b2Clamp(_loc20_ + 0.005,-0.2,0);
               _loc10_ = -m_motorMass * _loc20_;
               _loc28_ = m_limitPositionImpulse;
               m_limitPositionImpulse = b2Math.b2Max(m_limitPositionImpulse + _loc10_,0);
               _loc10_ = m_limitPositionImpulse - _loc28_;
            }
            else if(m_limitState == 2)
            {
               _loc20_ = _loc8_ - m_upperTranslation;
               _loc14_ = b2Math.b2Max(_loc14_,_loc20_);
               _loc20_ = b2Math.b2Clamp(_loc20_ - 0.005,0,0.2);
               _loc10_ = -m_motorMass * _loc20_;
               _loc28_ = m_limitPositionImpulse;
               m_limitPositionImpulse = b2Math.b2Min(m_limitPositionImpulse + _loc10_,0);
               _loc10_ = m_limitPositionImpulse - _loc28_;
            }
            _loc17_.m_sweep.c.x += _loc6_ * _loc10_ * m_motorJacobian.linear1.x;
            _loc17_.m_sweep.c.y += _loc6_ * _loc10_ * m_motorJacobian.linear1.y;
            _loc17_.m_sweep.a += _loc13_ * _loc10_ * m_motorJacobian.angular1;
            _loc12_.m_sweep.c.x += _loc3_ * _loc10_ * m_motorJacobian.linear2.x;
            _loc12_.m_sweep.c.y += _loc3_ * _loc10_ * m_motorJacobian.linear2.y;
            _loc12_.m_sweep.a += _loc11_ * _loc10_ * m_motorJacobian.angular2;
            _loc17_.SynchronizeTransform();
            _loc12_.SynchronizeTransform();
         }
         return _loc14_ <= 0.005 && _loc24_ <= 0.03490658503988659;
      }
   }
}

