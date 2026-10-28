package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   
   public class b2Island
   {
      
      private static var s_reportCR:b2ContactResult = new b2ContactResult();
      
      public var m_allocator:*;
      
      public var m_listener:b2ContactListener;
      
      public var m_bodies:Array;
      
      public var m_contacts:Array;
      
      public var m_joints:Array;
      
      public var m_bodyCount:int;
      
      public var m_jointCount:int;
      
      public var m_contactCount:int;
      
      public var m_bodyCapacity:int;
      
      public var m_contactCapacity:int;
      
      public var m_jointCapacity:int;
      
      public var m_positionIterationCount:int;
      
      public function b2Island(param1:int, param2:int, param3:int, param4:*, param5:b2ContactListener)
      {
         var _loc6_:int = 0;
         super();
         m_bodyCapacity = param1;
         m_contactCapacity = param2;
         m_jointCapacity = param3;
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
         m_allocator = param4;
         m_listener = param5;
         m_bodies = new Array(param1);
         _loc6_ = 0;
         while(_loc6_ < param1)
         {
            m_bodies[_loc6_] = null;
            _loc6_++;
         }
         m_contacts = new Array(param2);
         _loc6_ = 0;
         while(_loc6_ < param2)
         {
            m_contacts[_loc6_] = null;
            _loc6_++;
         }
         m_joints = new Array(param3);
         _loc6_ = 0;
         while(_loc6_ < param3)
         {
            m_joints[_loc6_] = null;
            _loc6_++;
         }
         m_positionIterationCount = 0;
      }
      
      public function Clear() : void
      {
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
      }
      
      public function Solve(param1:b2TimeStep, param2:b2Vec2, param3:Boolean, param4:Boolean) : void
      {
         var _loc11_:int = 0;
         var _loc6_:b2Body = null;
         var _loc5_:b2Joint = null;
         var _loc9_:int = 0;
         var _loc7_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc15_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc14_:Number = NaN;
         _loc11_ = 0;
         while(_loc11_ < m_bodyCount)
         {
            _loc6_ = m_bodies[_loc11_];
            if(!_loc6_.IsStatic())
            {
               _loc6_.m_linearVelocity.x += param1.dt * (param2.x + _loc6_.m_invMass * _loc6_.m_force.x);
               _loc6_.m_linearVelocity.y += param1.dt * (param2.y + _loc6_.m_invMass * _loc6_.m_force.y);
               _loc6_.m_angularVelocity += param1.dt * _loc6_.m_invI * _loc6_.m_torque;
               _loc6_.m_force.SetZero();
               _loc6_.m_torque = 0;
               _loc6_.m_linearVelocity.Multiply(b2Math.b2Clamp(1 - param1.dt * _loc6_.m_linearDamping,0,1));
               _loc6_.m_angularVelocity *= b2Math.b2Clamp(1 - param1.dt * _loc6_.m_angularDamping,0,1);
               if(_loc6_.m_linearVelocity.LengthSquared() > 40000)
               {
                  _loc6_.m_linearVelocity.Normalize();
                  _loc6_.m_linearVelocity.x *= 200;
                  _loc6_.m_linearVelocity.y *= 200;
               }
               if(_loc6_.m_angularVelocity * _loc6_.m_angularVelocity > 62500)
               {
                  if(_loc6_.m_angularVelocity < 0)
                  {
                     _loc6_.m_angularVelocity = -250;
                  }
                  else
                  {
                     _loc6_.m_angularVelocity = 250;
                  }
               }
            }
            _loc11_++;
         }
         var _loc12_:b2ContactSolver = new b2ContactSolver(param1,m_contacts,m_contactCount,m_allocator);
         _loc12_.InitVelocityConstraints(param1);
         _loc11_ = 0;
         while(_loc11_ < m_jointCount)
         {
            _loc5_ = m_joints[_loc11_];
            _loc5_.InitVelocityConstraints(param1);
            _loc11_++;
         }
         _loc11_ = 0;
         while(_loc11_ < param1.maxIterations)
         {
            _loc12_.SolveVelocityConstraints();
            _loc9_ = 0;
            while(_loc9_ < m_jointCount)
            {
               _loc5_ = m_joints[_loc9_];
               _loc5_.SolveVelocityConstraints(param1);
               _loc9_++;
            }
            _loc11_++;
         }
         _loc12_.FinalizeVelocityConstraints();
         _loc11_ = 0;
         while(_loc11_ < m_bodyCount)
         {
            _loc6_ = m_bodies[_loc11_];
            if(!_loc6_.IsStatic())
            {
               _loc6_.m_sweep.c0.SetV(_loc6_.m_sweep.c);
               _loc6_.m_sweep.a0 = _loc6_.m_sweep.a;
               _loc6_.m_sweep.c.x += param1.dt * _loc6_.m_linearVelocity.x;
               _loc6_.m_sweep.c.y += param1.dt * _loc6_.m_linearVelocity.y;
               _loc6_.m_sweep.a += param1.dt * _loc6_.m_angularVelocity;
               _loc6_.SynchronizeTransform();
            }
            _loc11_++;
         }
         if(param3)
         {
            _loc11_ = 0;
            while(_loc11_ < m_jointCount)
            {
               _loc5_ = m_joints[_loc11_];
               _loc5_.InitPositionConstraints();
               _loc11_++;
            }
            m_positionIterationCount = 0;
            while(m_positionIterationCount < param1.maxIterations)
            {
               _loc7_ = _loc12_.SolvePositionConstraints(0.2);
               _loc13_ = true;
               _loc11_ = 0;
               while(_loc11_ < m_jointCount)
               {
                  _loc5_ = m_joints[_loc11_];
                  _loc10_ = _loc5_.SolvePositionConstraints();
                  _loc13_ &&= _loc10_;
                  _loc11_++;
               }
               if(_loc7_ && _loc13_)
               {
                  break;
               }
               m_positionIterationCount = m_positionIterationCount + 1;
            }
         }
         Report(_loc12_.m_constraints);
         if(param4)
         {
            _loc15_ = 1.7976931348623157e+308;
            _loc8_ = 0.0001;
            _loc14_ = 0.0001234567901234568;
            _loc11_ = 0;
            while(_loc11_ < m_bodyCount)
            {
               _loc6_ = m_bodies[_loc11_];
               if(_loc6_.m_invMass != 0)
               {
                  if((_loc6_.m_flags & b2Body.e_allowSleepFlag) == 0)
                  {
                     _loc6_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  if((_loc6_.m_flags & b2Body.e_allowSleepFlag) == 0 || _loc6_.m_angularVelocity * _loc6_.m_angularVelocity > _loc14_ || b2Math.b2Dot(_loc6_.m_linearVelocity,_loc6_.m_linearVelocity) > _loc8_)
                  {
                     _loc6_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  else
                  {
                     _loc6_.m_sleepTime += param1.dt;
                     _loc15_ = b2Math.b2Min(_loc15_,_loc6_.m_sleepTime);
                  }
               }
               _loc11_++;
            }
            if(_loc15_ >= 0.5)
            {
               _loc11_ = 0;
               while(_loc11_ < m_bodyCount)
               {
                  _loc6_ = m_bodies[_loc11_];
                  _loc6_.m_flags = _loc6_.m_flags | b2Body.e_sleepFlag;
                  _loc6_.m_linearVelocity.SetZero();
                  _loc6_.m_angularVelocity = 0;
                  _loc11_++;
               }
            }
         }
      }
      
      public function SolveTOI(param1:b2TimeStep) : void
      {
         var _loc6_:int = 0;
         var _loc3_:b2Body = null;
         var _loc4_:Boolean = false;
         var _loc5_:b2ContactSolver = new b2ContactSolver(param1,m_contacts,m_contactCount,m_allocator);
         _loc6_ = 0;
         while(_loc6_ < param1.maxIterations)
         {
            _loc5_.SolveVelocityConstraints();
            _loc6_++;
         }
         _loc6_ = 0;
         while(_loc6_ < m_bodyCount)
         {
            _loc3_ = m_bodies[_loc6_];
            if(!_loc3_.IsStatic())
            {
               _loc3_.m_sweep.c0.SetV(_loc3_.m_sweep.c);
               _loc3_.m_sweep.a0 = _loc3_.m_sweep.a;
               _loc3_.m_sweep.c.x += param1.dt * _loc3_.m_linearVelocity.x;
               _loc3_.m_sweep.c.y += param1.dt * _loc3_.m_linearVelocity.y;
               _loc3_.m_sweep.a += param1.dt * _loc3_.m_angularVelocity;
               _loc3_.SynchronizeTransform();
            }
            _loc6_++;
         }
         var _loc2_:Number = 0.75;
         _loc6_ = 0;
         while(_loc6_ < param1.maxIterations)
         {
            _loc4_ = _loc5_.SolvePositionConstraints(_loc2_);
            if(_loc4_)
            {
               break;
            }
            _loc6_++;
         }
         Report(_loc5_.m_constraints);
      }
      
      public function Report(param1:Array) : void
      {
         var _loc13_:* = null;
         var _loc7_:* = null;
         var _loc9_:int = 0;
         var _loc2_:b2Contact = null;
         var _loc15_:b2ContactConstraint = null;
         var _loc11_:b2ContactResult = null;
         var _loc14_:b2Body = null;
         var _loc8_:int = 0;
         var _loc12_:Array = null;
         var _loc5_:int = 0;
         var _loc3_:b2Manifold = null;
         var _loc6_:int = 0;
         var _loc10_:b2ManifoldPoint = null;
         var _loc4_:b2ContactConstraintPoint = null;
         if(m_listener == null)
         {
            return;
         }
         _loc9_ = 0;
         while(_loc9_ < m_contactCount)
         {
            _loc2_ = m_contacts[_loc9_];
            _loc15_ = param1[_loc9_];
            _loc11_ = s_reportCR;
            _loc11_.shape1 = _loc2_.m_shape1;
            _loc11_.shape2 = _loc2_.m_shape2;
            _loc14_ = _loc11_.shape1.m_body;
            _loc8_ = _loc2_.m_manifoldCount;
            _loc12_ = _loc2_.GetManifolds();
            _loc5_ = 0;
            while(_loc5_ < _loc8_)
            {
               _loc3_ = _loc12_[_loc5_];
               _loc11_.normal.SetV(_loc3_.normal);
               _loc6_ = 0;
               while(_loc6_ < _loc3_.pointCount)
               {
                  _loc10_ = _loc3_.points[_loc6_];
                  _loc4_ = _loc15_.points[_loc6_];
                  _loc11_.position = _loc14_.GetWorldPoint(_loc10_.localPoint1);
                  _loc11_.normalImpulse = _loc4_.normalImpulse;
                  _loc11_.tangentImpulse = _loc4_.tangentImpulse;
                  _loc11_.id.key = _loc10_.id.key;
                  m_listener.Result(_loc11_);
                  _loc6_++;
               }
               _loc5_++;
            }
            _loc9_++;
         }
      }
      
      public function AddBody(param1:b2Body) : void
      {
         m_bodies[m_bodyCount++] = param1;
      }
      
      public function AddContact(param1:b2Contact) : void
      {
         m_contacts[m_contactCount++] = param1;
      }
      
      public function AddJoint(param1:b2Joint) : void
      {
         m_joints[m_jointCount++] = param1;
      }
   }
}

