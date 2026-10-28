package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2MouseJoint extends b2Joint
   {
      
      private var K:b2Mat22 = new b2Mat22();
      
      private var K1:b2Mat22 = new b2Mat22();
      
      private var K2:b2Mat22 = new b2Mat22();
      
      public var m_localAnchor:b2Vec2 = new b2Vec2();
      
      public var m_target:b2Vec2 = new b2Vec2();
      
      public var m_impulse:b2Vec2 = new b2Vec2();
      
      public var m_mass:b2Mat22 = new b2Mat22();
      
      public var m_C:b2Vec2 = new b2Vec2();
      
      public var m_maxForce:Number;
      
      public var m_beta:Number;
      
      public var m_gamma:Number;
      
      public function b2MouseJoint(param1:b2MouseJointDef)
      {
         super(param1);
         m_target.SetV(param1.target);
         var _loc7_:Number = m_target.x - m_body2.m_xf.position.x;
         var _loc8_:Number = m_target.y - m_body2.m_xf.position.y;
         var _loc4_:b2Mat22 = m_body2.m_xf.R;
         m_localAnchor.x = _loc7_ * _loc4_.col1.x + _loc8_ * _loc4_.col1.y;
         m_localAnchor.y = _loc7_ * _loc4_.col2.x + _loc8_ * _loc4_.col2.y;
         m_maxForce = param1.maxForce;
         m_impulse.SetZero();
         var _loc2_:Number = m_body2.m_mass;
         var _loc6_:Number = 2 * 3.141592653589793 * param1.frequencyHz;
         var _loc3_:Number = 2 * _loc2_ * param1.dampingRatio * _loc6_;
         var _loc5_:Number = param1.timeStep * _loc2_ * (_loc6_ * _loc6_);
         m_gamma = 1 / (_loc3_ + _loc5_);
         m_beta = _loc5_ / (_loc3_ + _loc5_);
      }
      
      override public function GetAnchor1() : b2Vec2
      {
         return m_target;
      }
      
      override public function GetAnchor2() : b2Vec2
      {
         return m_body2.GetWorldPoint(m_localAnchor);
      }
      
      override public function GetReactionForce() : b2Vec2
      {
         return m_impulse;
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
      
      public function SetTarget(param1:b2Vec2) : void
      {
         if(m_body2.IsSleeping())
         {
            m_body2.WakeUp();
         }
         m_target = param1;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc4_:b2Mat22 = null;
         var _loc3_:b2Body = m_body2;
         _loc4_ = _loc3_.m_xf.R;
         var _loc5_:Number = m_localAnchor.x - _loc3_.m_sweep.localCenter.x;
         var _loc6_:Number = m_localAnchor.y - _loc3_.m_sweep.localCenter.y;
         var _loc10_:Number = _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
         _loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
         _loc5_ = _loc10_;
         var _loc7_:Number = _loc3_.m_invMass;
         var _loc2_:Number = _loc3_.m_invI;
         K1.col1.x = _loc7_;
         K1.col2.x = 0;
         K1.col1.y = 0;
         K1.col2.y = _loc7_;
         K2.col1.x = _loc2_ * _loc6_ * _loc6_;
         K2.col2.x = -_loc2_ * _loc5_ * _loc6_;
         K2.col1.y = -_loc2_ * _loc5_ * _loc6_;
         K2.col2.y = _loc2_ * _loc5_ * _loc5_;
         K.SetM(K1);
         K.AddM(K2);
         K.col1.x += m_gamma;
         K.col2.y += m_gamma;
         K.Invert(m_mass);
         m_C.x = _loc3_.m_sweep.c.x + _loc5_ - m_target.x;
         m_C.y = _loc3_.m_sweep.c.y + _loc6_ - m_target.y;
         _loc3_.m_angularVelocity *= 0.98;
         var _loc8_:Number = param1.dt * m_impulse.x;
         var _loc9_:Number = param1.dt * m_impulse.y;
         _loc3_.m_linearVelocity.x += _loc7_ * _loc8_;
         _loc3_.m_linearVelocity.y += _loc7_ * _loc9_;
         _loc3_.m_angularVelocity += _loc2_ * (_loc5_ * _loc9_ - _loc6_ * _loc8_);
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc8_:b2Mat22 = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc2_:b2Body = m_body2;
         _loc8_ = _loc2_.m_xf.R;
         var _loc9_:Number = m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
         var _loc10_:Number = m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
         _loc15_ = _loc8_.col1.x * _loc9_ + _loc8_.col2.x * _loc10_;
         _loc10_ = _loc8_.col1.y * _loc9_ + _loc8_.col2.y * _loc10_;
         _loc9_ = _loc15_;
         var _loc3_:Number = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc10_;
         var _loc4_:Number = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc9_;
         _loc8_ = m_mass;
         _loc15_ = _loc3_ + m_beta * param1.inv_dt * m_C.x + m_gamma * param1.dt * m_impulse.x;
         _loc16_ = _loc4_ + m_beta * param1.inv_dt * m_C.y + m_gamma * param1.dt * m_impulse.y;
         var _loc6_:Number = -param1.inv_dt * (_loc8_.col1.x * _loc15_ + _loc8_.col2.x * _loc16_);
         var _loc5_:Number = -param1.inv_dt * (_loc8_.col1.y * _loc15_ + _loc8_.col2.y * _loc16_);
         var _loc14_:Number = m_impulse.x;
         var _loc12_:Number = m_impulse.y;
         m_impulse.x += _loc6_;
         m_impulse.y += _loc5_;
         var _loc7_:Number = m_impulse.Length();
         if(_loc7_ > m_maxForce)
         {
            m_impulse.Multiply(m_maxForce / _loc7_);
         }
         _loc6_ = m_impulse.x - _loc14_;
         _loc5_ = m_impulse.y - _loc12_;
         var _loc11_:Number = param1.dt * _loc6_;
         var _loc13_:Number = param1.dt * _loc5_;
         _loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc11_;
         _loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc13_;
         _loc2_.m_angularVelocity += _loc2_.m_invI * (_loc9_ * _loc13_ - _loc10_ * _loc11_);
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         return true;
      }
   }
}

