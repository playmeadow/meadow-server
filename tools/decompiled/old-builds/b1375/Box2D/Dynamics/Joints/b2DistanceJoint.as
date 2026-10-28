package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   
   public class b2DistanceJoint extends b2Joint
   {
      
      public var m_localAnchor1:b2Vec2 = new b2Vec2();
      
      public var m_localAnchor2:b2Vec2 = new b2Vec2();
      
      public var m_u:b2Vec2 = new b2Vec2();
      
      public var m_frequencyHz:Number;
      
      public var m_dampingRatio:Number;
      
      public var m_gamma:Number;
      
      public var m_bias:Number;
      
      public var m_impulse:Number;
      
      public var m_mass:Number;
      
      public var m_length:Number;
      
      public function b2DistanceJoint(param1:b2DistanceJointDef)
      {
         var _loc2_:* = null;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         super(param1);
         m_localAnchor1.SetV(param1.localAnchor1);
         m_localAnchor2.SetV(param1.localAnchor2);
         m_length = param1.length;
         m_frequencyHz = param1.frequencyHz;
         m_dampingRatio = param1.dampingRatio;
         m_impulse = 0;
         m_gamma = 0;
         m_bias = 0;
         m_inv_dt = 0;
      }
      
      override public function InitVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc14_:b2Mat22 = null;
         var _loc19_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         m_inv_dt = param1.inv_dt;
         var _loc15_:b2Body = m_body1;
         var _loc10_:b2Body = m_body2;
         _loc14_ = _loc15_.m_xf.R;
         var _loc5_:Number = m_localAnchor1.x - _loc15_.m_sweep.localCenter.x;
         var _loc9_:Number = m_localAnchor1.y - _loc15_.m_sweep.localCenter.y;
         _loc19_ = _loc14_.col1.x * _loc5_ + _loc14_.col2.x * _loc9_;
         _loc9_ = _loc14_.col1.y * _loc5_ + _loc14_.col2.y * _loc9_;
         _loc5_ = _loc19_;
         _loc14_ = _loc10_.m_xf.R;
         var _loc4_:Number = m_localAnchor2.x - _loc10_.m_sweep.localCenter.x;
         var _loc3_:Number = m_localAnchor2.y - _loc10_.m_sweep.localCenter.y;
         _loc19_ = _loc14_.col1.x * _loc4_ + _loc14_.col2.x * _loc3_;
         _loc3_ = _loc14_.col1.y * _loc4_ + _loc14_.col2.y * _loc3_;
         _loc4_ = _loc19_;
         m_u.x = _loc10_.m_sweep.c.x + _loc4_ - _loc15_.m_sweep.c.x - _loc5_;
         m_u.y = _loc10_.m_sweep.c.y + _loc3_ - _loc15_.m_sweep.c.y - _loc9_;
         var _loc16_:Number = Math.sqrt(m_u.x * m_u.x + m_u.y * m_u.y);
         if(_loc16_ > 0.005)
         {
            m_u.Multiply(1 / _loc16_);
         }
         else
         {
            m_u.SetZero();
         }
         var _loc7_:Number = _loc5_ * m_u.y - _loc9_ * m_u.x;
         var _loc6_:Number = _loc4_ * m_u.y - _loc3_ * m_u.x;
         var _loc11_:Number = _loc15_.m_invMass + _loc15_.m_invI * _loc7_ * _loc7_ + _loc10_.m_invMass + _loc10_.m_invI * _loc6_ * _loc6_;
         m_mass = 1 / _loc11_;
         if(m_frequencyHz > 0)
         {
            _loc8_ = _loc16_ - m_length;
            _loc13_ = 2 * 3.141592653589793 * m_frequencyHz;
            _loc2_ = 2 * m_mass * m_dampingRatio * _loc13_;
            _loc12_ = m_mass * _loc13_ * _loc13_;
            m_gamma = 1 / (param1.dt * (_loc2_ + param1.dt * _loc12_));
            m_bias = _loc8_ * param1.dt * _loc12_ * m_gamma;
            m_mass = 1 / (_loc11_ + m_gamma);
         }
         if(param1.warmStarting)
         {
            m_impulse *= param1.dtRatio;
            _loc17_ = m_impulse * m_u.x;
            _loc18_ = m_impulse * m_u.y;
            _loc15_.m_linearVelocity.x -= _loc15_.m_invMass * _loc17_;
            _loc15_.m_linearVelocity.y -= _loc15_.m_invMass * _loc18_;
            _loc15_.m_angularVelocity -= _loc15_.m_invI * (_loc5_ * _loc18_ - _loc9_ * _loc17_);
            _loc10_.m_linearVelocity.x += _loc10_.m_invMass * _loc17_;
            _loc10_.m_linearVelocity.y += _loc10_.m_invMass * _loc18_;
            _loc10_.m_angularVelocity += _loc10_.m_invI * (_loc4_ * _loc18_ - _loc3_ * _loc17_);
         }
         else
         {
            m_impulse = 0;
         }
      }
      
      override public function SolveVelocityConstraints(param1:b2TimeStep) : void
      {
         var _loc11_:b2Mat22 = null;
         var _loc14_:b2Body = m_body1;
         var _loc6_:b2Body = m_body2;
         _loc11_ = _loc14_.m_xf.R;
         var _loc4_:Number = m_localAnchor1.x - _loc14_.m_sweep.localCenter.x;
         var _loc5_:Number = m_localAnchor1.y - _loc14_.m_sweep.localCenter.y;
         var _loc17_:Number = _loc11_.col1.x * _loc4_ + _loc11_.col2.x * _loc5_;
         _loc5_ = _loc11_.col1.y * _loc4_ + _loc11_.col2.y * _loc5_;
         _loc4_ = _loc17_;
         _loc11_ = _loc6_.m_xf.R;
         var _loc3_:Number = m_localAnchor2.x - _loc6_.m_sweep.localCenter.x;
         var _loc2_:Number = m_localAnchor2.y - _loc6_.m_sweep.localCenter.y;
         _loc17_ = _loc11_.col1.x * _loc3_ + _loc11_.col2.x * _loc2_;
         _loc2_ = _loc11_.col1.y * _loc3_ + _loc11_.col2.y * _loc2_;
         _loc3_ = _loc17_;
         var _loc8_:Number = _loc14_.m_linearVelocity.x + -_loc14_.m_angularVelocity * _loc5_;
         var _loc10_:Number = _loc14_.m_linearVelocity.y + _loc14_.m_angularVelocity * _loc4_;
         var _loc12_:Number = _loc6_.m_linearVelocity.x + -_loc6_.m_angularVelocity * _loc2_;
         var _loc13_:Number = _loc6_.m_linearVelocity.y + _loc6_.m_angularVelocity * _loc3_;
         var _loc9_:Number = m_u.x * (_loc12_ - _loc8_) + m_u.y * (_loc13_ - _loc10_);
         var _loc7_:Number = -m_mass * (_loc9_ + m_bias + m_gamma * m_impulse);
         m_impulse += _loc7_;
         var _loc15_:Number = _loc7_ * m_u.x;
         var _loc16_:Number = _loc7_ * m_u.y;
         _loc14_.m_linearVelocity.x -= _loc14_.m_invMass * _loc15_;
         _loc14_.m_linearVelocity.y -= _loc14_.m_invMass * _loc16_;
         _loc14_.m_angularVelocity -= _loc14_.m_invI * (_loc4_ * _loc16_ - _loc5_ * _loc15_);
         _loc6_.m_linearVelocity.x += _loc6_.m_invMass * _loc15_;
         _loc6_.m_linearVelocity.y += _loc6_.m_invMass * _loc16_;
         _loc6_.m_angularVelocity += _loc6_.m_invI * (_loc3_ * _loc16_ - _loc2_ * _loc15_);
      }
      
      override public function SolvePositionConstraints() : Boolean
      {
         var _loc4_:b2Mat22 = null;
         if(m_frequencyHz > 0)
         {
            return true;
         }
         var _loc7_:b2Body = m_body1;
         var _loc9_:b2Body = m_body2;
         _loc4_ = _loc7_.m_xf.R;
         var _loc3_:Number = m_localAnchor1.x - _loc7_.m_sweep.localCenter.x;
         var _loc6_:Number = m_localAnchor1.y - _loc7_.m_sweep.localCenter.y;
         var _loc14_:Number = _loc4_.col1.x * _loc3_ + _loc4_.col2.x * _loc6_;
         _loc6_ = _loc4_.col1.y * _loc3_ + _loc4_.col2.y * _loc6_;
         _loc3_ = _loc14_;
         _loc4_ = _loc9_.m_xf.R;
         var _loc2_:Number = m_localAnchor2.x - _loc9_.m_sweep.localCenter.x;
         var _loc1_:Number = m_localAnchor2.y - _loc9_.m_sweep.localCenter.y;
         _loc14_ = _loc4_.col1.x * _loc2_ + _loc4_.col2.x * _loc1_;
         _loc1_ = _loc4_.col1.y * _loc2_ + _loc4_.col2.y * _loc1_;
         _loc2_ = _loc14_;
         var _loc11_:Number = _loc9_.m_sweep.c.x + _loc2_ - _loc7_.m_sweep.c.x - _loc3_;
         var _loc10_:Number = _loc9_.m_sweep.c.y + _loc1_ - _loc7_.m_sweep.c.y - _loc6_;
         var _loc8_:Number = Math.sqrt(_loc11_ * _loc11_ + _loc10_ * _loc10_);
         _loc11_ /= _loc8_;
         _loc10_ /= _loc8_;
         var _loc5_:Number = _loc8_ - m_length;
         _loc5_ = b2Math.b2Clamp(_loc5_,-0.2,0.2);
         var _loc15_:Number = -m_mass * _loc5_;
         m_u.Set(_loc11_,_loc10_);
         var _loc12_:Number = _loc15_ * m_u.x;
         var _loc13_:Number = _loc15_ * m_u.y;
         _loc7_.m_sweep.c.x -= _loc7_.m_invMass * _loc12_;
         _loc7_.m_sweep.c.y -= _loc7_.m_invMass * _loc13_;
         _loc7_.m_sweep.a -= _loc7_.m_invI * (_loc3_ * _loc13_ - _loc6_ * _loc12_);
         _loc9_.m_sweep.c.x += _loc9_.m_invMass * _loc12_;
         _loc9_.m_sweep.c.y += _loc9_.m_invMass * _loc13_;
         _loc9_.m_sweep.a += _loc9_.m_invI * (_loc2_ * _loc13_ - _loc1_ * _loc12_);
         _loc7_.SynchronizeTransform();
         _loc9_.SynchronizeTransform();
         return b2Math.b2Abs(_loc5_) < 0.005;
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
         var _loc1_:b2Vec2 = new b2Vec2();
         _loc1_.SetV(m_u);
         _loc1_.Multiply(m_inv_dt * m_impulse);
         return _loc1_;
      }
      
      override public function GetReactionTorque() : Number
      {
         return 0;
      }
   }
}

