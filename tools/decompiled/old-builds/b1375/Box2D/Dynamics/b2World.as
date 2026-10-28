package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   
   public class b2World
   {
      
      public static var m_positionCorrection:Boolean;
      
      public static var m_warmStarting:Boolean;
      
      public static var m_continuousPhysics:Boolean;
      
      private static var s_jointColor:b2Color = new b2Color(0.5,0.8,0.8);
      
      private static var s_coreColor:b2Color = new b2Color(0.9,0.6,0.6);
      
      private static var s_xf:b2XForm = new b2XForm();
      
      public var m_blockAllocator:*;
      
      public var m_stackAllocator:*;
      
      public var m_lock:Boolean;
      
      public var m_broadPhase:b2BroadPhase;
      
      public var m_contactManager:b2ContactManager = new b2ContactManager();
      
      public var m_bodyList:b2Body;
      
      public var m_jointList:b2Joint;
      
      public var m_contactList:b2Contact;
      
      public var m_bodyCount:int;
      
      public var m_contactCount:int;
      
      public var m_jointCount:int;
      
      public var m_gravity:b2Vec2;
      
      public var m_allowSleep:Boolean;
      
      public var m_groundBody:b2Body;
      
      public var m_destructionListener:b2DestructionListener;
      
      public var m_boundaryListener:b2BoundaryListener;
      
      public var m_contactFilter:b2ContactFilter;
      
      public var m_contactListener:b2ContactListener;
      
      public var m_debugDraw:b2DebugDraw;
      
      public var m_inv_dt0:Number;
      
      public var m_positionIterationCount:int;
      
      public function b2World(param1:b2AABB, param2:b2Vec2, param3:Boolean)
      {
         super();
         m_destructionListener = null;
         m_boundaryListener = null;
         m_contactFilter = b2ContactFilter.b2_defaultFilter;
         m_contactListener = null;
         m_debugDraw = null;
         m_bodyList = null;
         m_contactList = null;
         m_jointList = null;
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
         m_positionCorrection = true;
         m_warmStarting = true;
         m_continuousPhysics = true;
         m_allowSleep = param3;
         m_gravity = param2;
         m_lock = false;
         m_inv_dt0 = 0;
         m_contactManager.m_world = this;
         m_broadPhase = new b2BroadPhase(param1,m_contactManager);
         var _loc4_:b2BodyDef = new b2BodyDef();
         m_groundBody = CreateBody(_loc4_);
      }
      
      public function SetDestructionListener(param1:b2DestructionListener) : void
      {
         m_destructionListener = param1;
      }
      
      public function SetBoundaryListener(param1:b2BoundaryListener) : void
      {
         m_boundaryListener = param1;
      }
      
      public function SetContactFilter(param1:b2ContactFilter) : void
      {
         m_contactFilter = param1;
      }
      
      public function SetContactListener(param1:b2ContactListener) : void
      {
         m_contactListener = param1;
      }
      
      public function SetDebugDraw(param1:b2DebugDraw) : void
      {
         m_debugDraw = param1;
      }
      
      public function Validate() : void
      {
         m_broadPhase.Validate();
      }
      
      public function GetProxyCount() : int
      {
         return m_broadPhase.m_proxyCount;
      }
      
      public function GetPairCount() : int
      {
         return m_broadPhase.m_pairManager.m_pairCount;
      }
      
      public function CreateBody(param1:b2BodyDef) : b2Body
      {
         if(m_lock == true)
         {
            return null;
         }
         var _loc2_:b2Body = new b2Body(param1,this);
         _loc2_.m_prev = null;
         _loc2_.m_next = m_bodyList;
         if(m_bodyList)
         {
            m_bodyList.m_prev = _loc2_;
         }
         m_bodyList = _loc2_;
         m_bodyCount = m_bodyCount + 1;
         return _loc2_;
      }
      
      public function DestroyBody(param1:b2Body) : void
      {
         var _loc4_:b2JointEdge = null;
         var _loc2_:b2Shape = null;
         if(m_lock == true)
         {
            return;
         }
         var _loc5_:b2JointEdge = param1.m_jointList;
         while(_loc5_)
         {
            _loc4_ = _loc5_;
            _loc5_ = _loc5_.next;
            if(m_destructionListener)
            {
               m_destructionListener.SayGoodbyeJoint(_loc4_.joint);
            }
            DestroyJoint(_loc4_.joint);
         }
         var _loc3_:b2Shape = param1.m_shapeList;
         while(_loc3_)
         {
            _loc2_ = _loc3_;
            _loc3_ = _loc3_.m_next;
            if(m_destructionListener)
            {
               m_destructionListener.SayGoodbyeShape(_loc2_);
            }
            _loc2_.DestroyProxy(m_broadPhase);
            b2Shape.Destroy(_loc2_,m_blockAllocator);
         }
         if(param1.m_prev)
         {
            param1.m_prev.m_next = param1.m_next;
         }
         if(param1.m_next)
         {
            param1.m_next.m_prev = param1.m_prev;
         }
         if(param1 == m_bodyList)
         {
            m_bodyList = param1.m_next;
         }
         m_bodyCount = m_bodyCount - 1;
      }
      
      public function CreateJoint(param1:b2JointDef) : b2Joint
      {
         var _loc3_:b2Body = null;
         var _loc2_:b2Shape = null;
         var _loc4_:b2Joint = b2Joint.Create(param1,m_blockAllocator);
         _loc4_.m_prev = null;
         _loc4_.m_next = m_jointList;
         if(m_jointList)
         {
            m_jointList.m_prev = _loc4_;
         }
         m_jointList = _loc4_;
         m_jointCount = m_jointCount + 1;
         _loc4_.m_node1.joint = _loc4_;
         _loc4_.m_node1.other = _loc4_.m_body2;
         _loc4_.m_node1.prev = null;
         _loc4_.m_node1.next = _loc4_.m_body1.m_jointList;
         if(_loc4_.m_body1.m_jointList)
         {
            _loc4_.m_body1.m_jointList.prev = _loc4_.m_node1;
         }
         _loc4_.m_body1.m_jointList = _loc4_.m_node1;
         _loc4_.m_node2.joint = _loc4_;
         _loc4_.m_node2.other = _loc4_.m_body1;
         _loc4_.m_node2.prev = null;
         _loc4_.m_node2.next = _loc4_.m_body2.m_jointList;
         if(_loc4_.m_body2.m_jointList)
         {
            _loc4_.m_body2.m_jointList.prev = _loc4_.m_node2;
         }
         _loc4_.m_body2.m_jointList = _loc4_.m_node2;
         if(param1.collideConnected == false)
         {
            _loc3_ = param1.body1.m_shapeCount < param1.body2.m_shapeCount ? param1.body1 : param1.body2;
            _loc2_ = _loc3_.m_shapeList;
            while(_loc2_)
            {
               _loc2_.RefilterProxy(m_broadPhase,_loc3_.m_xf);
               _loc2_ = _loc2_.m_next;
            }
         }
         return _loc4_;
      }
      
      public function DestroyJoint(param1:b2Joint) : void
      {
         var _loc4_:b2Body = null;
         var _loc3_:b2Shape = null;
         var _loc5_:Boolean = param1.m_collideConnected;
         if(param1.m_prev)
         {
            param1.m_prev.m_next = param1.m_next;
         }
         if(param1.m_next)
         {
            param1.m_next.m_prev = param1.m_prev;
         }
         if(param1 == m_jointList)
         {
            m_jointList = param1.m_next;
         }
         var _loc6_:b2Body = param1.m_body1;
         var _loc2_:b2Body = param1.m_body2;
         _loc6_.WakeUp();
         _loc2_.WakeUp();
         if(param1.m_node1.prev)
         {
            param1.m_node1.prev.next = param1.m_node1.next;
         }
         if(param1.m_node1.next)
         {
            param1.m_node1.next.prev = param1.m_node1.prev;
         }
         if(param1.m_node1 == _loc6_.m_jointList)
         {
            _loc6_.m_jointList = param1.m_node1.next;
         }
         param1.m_node1.prev = null;
         param1.m_node1.next = null;
         if(param1.m_node2.prev)
         {
            param1.m_node2.prev.next = param1.m_node2.next;
         }
         if(param1.m_node2.next)
         {
            param1.m_node2.next.prev = param1.m_node2.prev;
         }
         if(param1.m_node2 == _loc2_.m_jointList)
         {
            _loc2_.m_jointList = param1.m_node2.next;
         }
         param1.m_node2.prev = null;
         param1.m_node2.next = null;
         b2Joint.Destroy(param1,m_blockAllocator);
         m_jointCount = m_jointCount - 1;
         if(_loc5_ == false)
         {
            _loc4_ = _loc6_.m_shapeCount < _loc2_.m_shapeCount ? _loc6_ : _loc2_;
            _loc3_ = _loc4_.m_shapeList;
            while(_loc3_)
            {
               _loc3_.RefilterProxy(m_broadPhase,_loc4_.m_xf);
               _loc3_ = _loc3_.m_next;
            }
         }
      }
      
      public function Refilter(param1:b2Shape) : void
      {
         param1.RefilterProxy(m_broadPhase,param1.m_body.m_xf);
      }
      
      public function SetWarmStarting(param1:Boolean) : void
      {
         m_warmStarting = param1;
      }
      
      public function SetPositionCorrection(param1:Boolean) : void
      {
         m_positionCorrection = param1;
      }
      
      public function SetContinuousPhysics(param1:Boolean) : void
      {
         m_continuousPhysics = param1;
      }
      
      public function GetBodyCount() : int
      {
         return m_bodyCount;
      }
      
      public function GetJointCount() : int
      {
         return m_jointCount;
      }
      
      public function GetContactCount() : int
      {
         return m_contactCount;
      }
      
      public function SetGravity(param1:b2Vec2) : void
      {
         m_gravity = param1;
      }
      
      public function GetGroundBody() : b2Body
      {
         return m_groundBody;
      }
      
      public function Step(param1:Number, param2:int) : void
      {
         m_lock = true;
         var _loc3_:b2TimeStep = new b2TimeStep();
         _loc3_.dt = param1;
         _loc3_.maxIterations = param2;
         if(param1 > 0)
         {
            _loc3_.inv_dt = 1 / param1;
         }
         else
         {
            _loc3_.inv_dt = 0;
         }
         _loc3_.dtRatio = m_inv_dt0 * param1;
         _loc3_.positionCorrection = m_positionCorrection;
         _loc3_.warmStarting = m_warmStarting;
         m_contactManager.Collide();
         if(_loc3_.dt > 0)
         {
            Solve(_loc3_);
         }
         if(m_continuousPhysics && _loc3_.dt > 0)
         {
            SolveTOI(_loc3_);
         }
         DrawDebugData();
         m_inv_dt0 = _loc3_.inv_dt;
         m_lock = false;
      }
      
      public function Query(param1:b2AABB, param2:Array, param3:int) : int
      {
         var _loc6_:int = 0;
         var _loc5_:Array = new Array(param3);
         var _loc4_:int = m_broadPhase.QueryAABB(param1,_loc5_,param3);
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            param2[_loc6_] = _loc5_[_loc6_];
            _loc6_++;
         }
         return _loc4_;
      }
      
      public function GetBodyList() : b2Body
      {
         return m_bodyList;
      }
      
      public function GetJointList() : b2Joint
      {
         return m_jointList;
      }
      
      public function Solve(param1:b2TimeStep) : void
      {
         var _loc4_:b2Body = null;
         var _loc5_:b2Contact = null;
         var _loc9_:b2Joint = null;
         var _loc6_:b2Body = null;
         var _loc2_:int = 0;
         var _loc3_:b2Body = null;
         var _loc12_:b2ContactEdge = null;
         var _loc8_:b2JointEdge = null;
         var _loc10_:int = 0;
         var _loc7_:Boolean = false;
         m_positionIterationCount = 0;
         var _loc11_:b2Island = new b2Island(m_bodyCount,m_contactCount,m_jointCount,m_stackAllocator,m_contactListener);
         _loc4_ = m_bodyList;
         while(_loc4_)
         {
            _loc4_.m_flags &= ~b2Body.e_islandFlag;
            _loc4_ = _loc4_.m_next;
         }
         _loc5_ = m_contactList;
         while(_loc5_)
         {
            _loc5_.m_flags &= ~b2Contact.e_islandFlag;
            _loc5_ = _loc5_.m_next;
         }
         _loc9_ = m_jointList;
         while(_loc9_)
         {
            _loc9_.m_islandFlag = false;
            _loc9_ = _loc9_.m_next;
         }
         var _loc13_:int = m_bodyCount;
         var _loc14_:Array = new Array(_loc13_);
         _loc6_ = m_bodyList;
         while(_loc6_)
         {
            if(!(_loc6_.m_flags & (b2Body.e_islandFlag | b2Body.e_sleepFlag | b2Body.e_frozenFlag)))
            {
               if(!_loc6_.IsStatic())
               {
                  _loc11_.Clear();
                  _loc2_ = 0;
                  _loc14_[_loc2_++] = _loc6_;
                  _loc6_.m_flags |= b2Body.e_islandFlag;
                  while(_loc2_ > 0)
                  {
                     _loc4_ = _loc14_[--_loc2_];
                     _loc11_.AddBody(_loc4_);
                     _loc4_.m_flags &= ~b2Body.e_sleepFlag;
                     if(!_loc4_.IsStatic())
                     {
                        _loc12_ = _loc4_.m_contactList;
                        while(_loc12_)
                        {
                           if(!(_loc12_.contact.m_flags & (b2Contact.e_islandFlag | b2Contact.e_nonSolidFlag)))
                           {
                              if(_loc12_.contact.m_manifoldCount != 0)
                              {
                                 _loc11_.AddContact(_loc12_.contact);
                                 _loc12_.contact.m_flags |= b2Contact.e_islandFlag;
                                 _loc3_ = _loc12_.other;
                                 if(!(_loc3_.m_flags & b2Body.e_islandFlag))
                                 {
                                    _loc14_[_loc2_++] = _loc3_;
                                    _loc3_.m_flags |= b2Body.e_islandFlag;
                                 }
                              }
                           }
                           _loc12_ = _loc12_.next;
                        }
                        _loc8_ = _loc4_.m_jointList;
                        while(_loc8_)
                        {
                           if(_loc8_.joint.m_islandFlag != true)
                           {
                              _loc11_.AddJoint(_loc8_.joint);
                              _loc8_.joint.m_islandFlag = true;
                              _loc3_ = _loc8_.other;
                              if(!(_loc3_.m_flags & b2Body.e_islandFlag))
                              {
                                 _loc14_[_loc2_++] = _loc3_;
                                 _loc3_.m_flags |= b2Body.e_islandFlag;
                              }
                           }
                           _loc8_ = _loc8_.next;
                        }
                     }
                  }
                  _loc11_.Solve(param1,m_gravity,m_positionCorrection,m_allowSleep);
                  if(_loc11_.m_positionIterationCount > m_positionIterationCount)
                  {
                     m_positionIterationCount = _loc11_.m_positionIterationCount;
                  }
                  _loc10_ = 0;
                  while(_loc10_ < _loc11_.m_bodyCount)
                  {
                     _loc4_ = _loc11_.m_bodies[_loc10_];
                     if(_loc4_.IsStatic())
                     {
                        _loc4_.m_flags &= ~b2Body.e_islandFlag;
                     }
                     _loc10_++;
                  }
               }
            }
            _loc6_ = _loc6_.m_next;
         }
         _loc4_ = m_bodyList;
         while(_loc4_)
         {
            if(!(_loc4_.m_flags & (b2Body.e_sleepFlag | b2Body.e_frozenFlag)))
            {
               if(!_loc4_.IsStatic())
               {
                  _loc7_ = _loc4_.SynchronizeShapes();
                  if(_loc7_ == false && m_boundaryListener != null)
                  {
                     m_boundaryListener.Violation(_loc4_);
                  }
               }
            }
            _loc4_ = _loc4_.m_next;
         }
         m_broadPhase.Commit();
      }
      
      public function SolveTOI(param1:b2TimeStep) : void
      {
         var _loc7_:b2Body = null;
         var _loc6_:b2Shape = null;
         var _loc2_:b2Shape = null;
         var _loc18_:b2Body = null;
         var _loc11_:b2Body = null;
         var _loc17_:b2ContactEdge = null;
         var _loc9_:b2Contact = null;
         var _loc21_:b2Contact = null;
         var _loc14_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc10_:b2Body = null;
         var _loc4_:int = 0;
         var _loc3_:b2Body = null;
         var _loc16_:b2TimeStep = null;
         var _loc13_:int = 0;
         var _loc12_:Boolean = false;
         var _loc15_:b2Island = new b2Island(m_bodyCount,32,0,m_stackAllocator,m_contactListener);
         var _loc19_:int = m_bodyCount;
         var _loc20_:Array = new Array(_loc19_);
         _loc7_ = m_bodyList;
         while(_loc7_)
         {
            _loc7_.m_flags &= ~b2Body.e_islandFlag;
            _loc7_.m_sweep.t0 = 0;
            _loc7_ = _loc7_.m_next;
         }
         _loc9_ = m_contactList;
         while(_loc9_)
         {
            _loc9_.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag);
            _loc9_ = _loc9_.m_next;
         }
         while(true)
         {
            _loc21_ = null;
            _loc14_ = 1;
            _loc9_ = m_contactList;
            for(; _loc9_; _loc9_ = _loc9_.m_next)
            {
               if(!(_loc9_.m_flags & (b2Contact.e_slowFlag | b2Contact.e_nonSolidFlag)))
               {
                  _loc8_ = 1;
                  if(_loc9_.m_flags & b2Contact.e_toiFlag)
                  {
                     _loc8_ = _loc9_.m_toi;
                  }
                  else
                  {
                     _loc6_ = _loc9_.m_shape1;
                     _loc2_ = _loc9_.m_shape2;
                     _loc18_ = _loc6_.m_body;
                     _loc11_ = _loc2_.m_body;
                     if((_loc18_.IsStatic() || _loc18_.IsSleeping()) && (_loc11_.IsStatic() || _loc11_.IsSleeping()))
                     {
                        continue;
                     }
                     _loc5_ = _loc18_.m_sweep.t0;
                     if(_loc18_.m_sweep.t0 < _loc11_.m_sweep.t0)
                     {
                        _loc5_ = _loc11_.m_sweep.t0;
                        _loc18_.m_sweep.Advance(_loc5_);
                     }
                     else if(_loc11_.m_sweep.t0 < _loc18_.m_sweep.t0)
                     {
                        _loc5_ = _loc18_.m_sweep.t0;
                        _loc11_.m_sweep.Advance(_loc5_);
                     }
                     _loc8_ = b2TimeOfImpact.TimeOfImpact(_loc9_.m_shape1,_loc18_.m_sweep,_loc9_.m_shape2,_loc11_.m_sweep);
                     if(_loc8_ > 0 && _loc8_ < 1)
                     {
                        _loc8_ = (1 - _loc8_) * _loc5_ + _loc8_;
                        if(_loc8_ > 1)
                        {
                           _loc8_ = 1;
                        }
                     }
                     _loc9_.m_toi = _loc8_;
                     _loc9_.m_flags |= b2Contact.e_toiFlag;
                  }
                  if(Number.MIN_VALUE < _loc8_ && _loc8_ < _loc14_)
                  {
                     _loc21_ = _loc9_;
                     _loc14_ = _loc8_;
                  }
               }
            }
            if(_loc21_ == null || 1 - 100 * Number.MIN_VALUE < _loc14_)
            {
               break;
            }
            _loc6_ = _loc21_.m_shape1;
            _loc2_ = _loc21_.m_shape2;
            _loc18_ = _loc6_.m_body;
            _loc11_ = _loc2_.m_body;
            _loc18_.Advance(_loc14_);
            _loc11_.Advance(_loc14_);
            _loc21_.Update(m_contactListener);
            _loc21_.m_flags &= ~b2Contact.e_toiFlag;
            if(_loc21_.m_manifoldCount != 0)
            {
               _loc10_ = _loc18_;
               if(_loc10_.IsStatic())
               {
                  _loc10_ = _loc11_;
               }
               _loc15_.Clear();
               _loc4_ = 0;
               _loc20_[_loc4_++] = _loc10_;
               _loc10_.m_flags |= b2Body.e_islandFlag;
               while(_loc4_ > 0)
               {
                  _loc7_ = _loc20_[--_loc4_];
                  _loc15_.AddBody(_loc7_);
                  _loc7_.m_flags &= ~b2Body.e_sleepFlag;
                  if(!_loc7_.IsStatic())
                  {
                     _loc17_ = _loc7_.m_contactList;
                     while(_loc17_)
                     {
                        if(_loc15_.m_contactCount != _loc15_.m_contactCapacity)
                        {
                           if(!(_loc17_.contact.m_flags & (b2Contact.e_islandFlag | b2Contact.e_slowFlag | b2Contact.e_nonSolidFlag)))
                           {
                              if(_loc17_.contact.m_manifoldCount != 0)
                              {
                                 _loc15_.AddContact(_loc17_.contact);
                                 _loc17_.contact.m_flags |= b2Contact.e_islandFlag;
                                 _loc3_ = _loc17_.other;
                                 if(!(_loc3_.m_flags & b2Body.e_islandFlag))
                                 {
                                    if(_loc3_.IsStatic() == false)
                                    {
                                       _loc3_.Advance(_loc14_);
                                       _loc3_.WakeUp();
                                    }
                                    _loc20_[_loc4_++] = _loc3_;
                                    _loc3_.m_flags |= b2Body.e_islandFlag;
                                 }
                              }
                           }
                        }
                        _loc17_ = _loc17_.next;
                     }
                  }
               }
               _loc16_ = new b2TimeStep();
               _loc16_.dt = (1 - _loc14_) * param1.dt;
               _loc16_.inv_dt = 1 / _loc16_.dt;
               _loc16_.maxIterations = param1.maxIterations;
               _loc15_.SolveTOI(_loc16_);
               _loc13_ = 0;
               while(_loc13_ < _loc15_.m_bodyCount)
               {
                  _loc7_ = _loc15_.m_bodies[_loc13_];
                  _loc7_.m_flags = _loc7_.m_flags & ~b2Body.e_islandFlag;
                  if(!(_loc7_.m_flags & (b2Body.e_sleepFlag | b2Body.e_frozenFlag)))
                  {
                     if(!_loc7_.IsStatic())
                     {
                        _loc12_ = _loc7_.SynchronizeShapes();
                        if(_loc12_ == false && m_boundaryListener != null)
                        {
                           m_boundaryListener.Violation(_loc7_);
                        }
                        _loc17_ = _loc7_.m_contactList;
                        while(_loc17_)
                        {
                           _loc17_.contact.m_flags &= ~b2Contact.e_toiFlag;
                           _loc17_ = _loc17_.next;
                        }
                     }
                  }
                  _loc13_++;
               }
               _loc13_ = 0;
               while(_loc13_ < _loc15_.m_contactCount)
               {
                  _loc9_ = _loc15_.m_contacts[_loc13_];
                  _loc9_.m_flags = _loc9_.m_flags & ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag);
                  _loc13_++;
               }
               m_broadPhase.Commit();
            }
         }
      }
      
      public function DrawJoint(param1:b2Joint) : void
      {
         var _loc3_:b2PulleyJoint = null;
         var _loc5_:b2Vec2 = null;
         var _loc4_:b2Vec2 = null;
         var _loc10_:b2Body = param1.m_body1;
         var _loc11_:b2Body = param1.m_body2;
         var _loc2_:b2XForm = _loc10_.m_xf;
         var _loc9_:b2XForm = _loc11_.m_xf;
         var _loc13_:b2Vec2 = _loc2_.position;
         var _loc12_:b2Vec2 = _loc9_.position;
         var _loc8_:b2Vec2 = param1.GetAnchor1();
         var _loc7_:b2Vec2 = param1.GetAnchor2();
         var _loc6_:b2Color = s_jointColor;
         switch(param1.m_type - 3)
         {
            case 0:
               m_debugDraw.DrawSegment(_loc8_,_loc7_,_loc6_);
               break;
            case 1:
               _loc3_ = param1 as b2PulleyJoint;
               _loc5_ = _loc3_.GetGroundAnchor1();
               _loc4_ = _loc3_.GetGroundAnchor2();
               m_debugDraw.DrawSegment(_loc5_,_loc8_,_loc6_);
               m_debugDraw.DrawSegment(_loc4_,_loc7_,_loc6_);
               m_debugDraw.DrawSegment(_loc5_,_loc4_,_loc6_);
               break;
            case 2:
               m_debugDraw.DrawSegment(_loc8_,_loc7_,_loc6_);
               break;
            default:
               if(_loc10_ != m_groundBody)
               {
                  m_debugDraw.DrawSegment(_loc13_,_loc8_,_loc6_);
               }
               m_debugDraw.DrawSegment(_loc8_,_loc7_,_loc6_);
               if(_loc11_ != m_groundBody)
               {
                  m_debugDraw.DrawSegment(_loc12_,_loc7_,_loc6_);
               }
         }
      }
      
      public function DrawShape(param1:b2Shape, param2:b2XForm, param3:b2Color, param4:Boolean) : void
      {
         var _loc9_:b2CircleShape = null;
         var _loc11_:b2Vec2 = null;
         var _loc14_:Number = NaN;
         var _loc5_:b2Vec2 = null;
         var _loc10_:int = 0;
         var _loc8_:b2PolygonShape = null;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc7_:Array = null;
         var _loc15_:Array = null;
         var _loc6_:b2Color = s_coreColor;
         switch(param1.m_type)
         {
            case 0:
               _loc9_ = param1 as b2CircleShape;
               _loc11_ = b2Math.b2MulX(param2,_loc9_.m_localPosition);
               _loc14_ = _loc9_.m_radius;
               _loc5_ = param2.R.col1;
               m_debugDraw.DrawSolidCircle(_loc11_,_loc14_,_loc5_,param3);
               if(param4)
               {
                  m_debugDraw.DrawCircle(_loc11_,_loc14_ - 0.04,_loc6_);
               }
               break;
            case 1:
               _loc8_ = param1 as b2PolygonShape;
               _loc12_ = _loc8_.GetVertexCount();
               _loc13_ = _loc8_.GetVertices();
               _loc7_ = new Array(8);
               _loc10_ = 0;
               while(_loc10_ < _loc12_)
               {
                  _loc7_[_loc10_] = b2Math.b2MulX(param2,_loc13_[_loc10_]);
                  _loc10_++;
               }
               m_debugDraw.DrawSolidPolygon(_loc7_,_loc12_,param3);
               if(param4)
               {
                  _loc15_ = _loc8_.GetCoreVertices();
                  _loc10_ = 0;
                  while(_loc10_ < _loc12_)
                  {
                     _loc7_[_loc10_] = b2Math.b2MulX(param2,_loc15_[_loc10_]);
                     _loc10_++;
                  }
                  m_debugDraw.DrawPolygon(_loc7_,_loc12_,_loc6_);
               }
         }
      }
      
      public function DrawDebugData() : void
      {
         var _loc23_:int = 0;
         var _loc18_:b2Body = null;
         var _loc24_:b2Shape = null;
         var _loc20_:b2Joint = null;
         var _loc10_:b2BroadPhase = null;
         var _loc13_:b2XForm = null;
         var _loc28_:Boolean = false;
         var _loc15_:* = 0;
         var _loc2_:b2Pair = null;
         var _loc4_:b2Proxy = null;
         var _loc3_:b2Proxy = null;
         var _loc12_:b2Vec2 = null;
         var _loc1_:b2Vec2 = null;
         var _loc27_:b2Proxy = null;
         var _loc19_:b2PolygonShape = null;
         var _loc17_:b2OBB = null;
         var _loc22_:b2Vec2 = null;
         var _loc26_:b2Mat22 = null;
         var _loc21_:b2Vec2 = null;
         var _loc14_:Number = NaN;
         if(m_debugDraw == null)
         {
            return;
         }
         m_debugDraw.m_sprite.graphics.clear();
         var _loc16_:uint = m_debugDraw.GetFlags();
         var _loc5_:b2Vec2 = new b2Vec2();
         var _loc9_:b2Vec2 = new b2Vec2();
         var _loc8_:b2Vec2 = new b2Vec2();
         var _loc25_:b2Color = new b2Color(0,0,0);
         var _loc11_:b2AABB = new b2AABB();
         var _loc6_:b2AABB = new b2AABB();
         var _loc7_:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2(),new b2Vec2()];
         if(_loc16_ & b2DebugDraw.e_shapeBit)
         {
            _loc28_ = (_loc16_ & b2DebugDraw.e_coreShapeBit) == b2DebugDraw.e_coreShapeBit;
            _loc18_ = m_bodyList;
            while(_loc18_)
            {
               _loc13_ = _loc18_.m_xf;
               _loc24_ = _loc18_.GetShapeList();
               while(_loc24_)
               {
                  if(_loc18_.IsStatic())
                  {
                     DrawShape(_loc24_,_loc13_,new b2Color(0.5,0.9,0.5),_loc28_);
                  }
                  else if(_loc18_.IsSleeping())
                  {
                     DrawShape(_loc24_,_loc13_,new b2Color(0.5,0.5,0.9),_loc28_);
                  }
                  else
                  {
                     DrawShape(_loc24_,_loc13_,new b2Color(0.9,0.9,0.9),_loc28_);
                  }
                  _loc24_ = _loc24_.m_next;
               }
               _loc18_ = _loc18_.m_next;
            }
         }
         if(_loc16_ & b2DebugDraw.e_jointBit)
         {
            _loc20_ = m_jointList;
            while(_loc20_)
            {
               DrawJoint(_loc20_);
               _loc20_ = _loc20_.m_next;
            }
         }
         if(_loc16_ & b2DebugDraw.e_pairBit)
         {
            _loc10_ = m_broadPhase;
            _loc5_.Set(1 / _loc10_.m_quantizationFactor.x,1 / _loc10_.m_quantizationFactor.y);
            _loc25_.Set(0.9,0.9,0.3);
            _loc23_ = 0;
            while(_loc23_ < b2Pair.b2_tableCapacity)
            {
               _loc15_ = uint(_loc10_.m_pairManager.m_hashTable[_loc23_]);
               while(_loc15_ != b2Pair.b2_nullPair)
               {
                  _loc2_ = _loc10_.m_pairManager.m_pairs[_loc15_];
                  _loc4_ = _loc10_.m_proxyPool[_loc2_.proxyId1];
                  _loc3_ = _loc10_.m_proxyPool[_loc2_.proxyId2];
                  _loc11_.lowerBound.x = _loc10_.m_worldAABB.lowerBound.x + _loc5_.x * _loc10_.m_bounds[0][_loc4_.lowerBounds[0]].value;
                  _loc11_.lowerBound.y = _loc10_.m_worldAABB.lowerBound.y + _loc5_.y * _loc10_.m_bounds[1][_loc4_.lowerBounds[1]].value;
                  _loc11_.upperBound.x = _loc10_.m_worldAABB.lowerBound.x + _loc5_.x * _loc10_.m_bounds[0][_loc4_.upperBounds[0]].value;
                  _loc11_.upperBound.y = _loc10_.m_worldAABB.lowerBound.y + _loc5_.y * _loc10_.m_bounds[1][_loc4_.upperBounds[1]].value;
                  _loc6_.lowerBound.x = _loc10_.m_worldAABB.lowerBound.x + _loc5_.x * _loc10_.m_bounds[0][_loc3_.lowerBounds[0]].value;
                  _loc6_.lowerBound.y = _loc10_.m_worldAABB.lowerBound.y + _loc5_.y * _loc10_.m_bounds[1][_loc3_.lowerBounds[1]].value;
                  _loc6_.upperBound.x = _loc10_.m_worldAABB.lowerBound.x + _loc5_.x * _loc10_.m_bounds[0][_loc3_.upperBounds[0]].value;
                  _loc6_.upperBound.y = _loc10_.m_worldAABB.lowerBound.y + _loc5_.y * _loc10_.m_bounds[1][_loc3_.upperBounds[1]].value;
                  _loc9_.x = 0.5 * (_loc11_.lowerBound.x + _loc11_.upperBound.x);
                  _loc9_.y = 0.5 * (_loc11_.lowerBound.y + _loc11_.upperBound.y);
                  _loc8_.x = 0.5 * (_loc6_.lowerBound.x + _loc6_.upperBound.x);
                  _loc8_.y = 0.5 * (_loc6_.lowerBound.y + _loc6_.upperBound.y);
                  m_debugDraw.DrawSegment(_loc9_,_loc8_,_loc25_);
                  _loc15_ = _loc2_.next;
               }
               _loc23_++;
            }
         }
         if(_loc16_ & b2DebugDraw.e_aabbBit)
         {
            _loc10_ = m_broadPhase;
            _loc12_ = _loc10_.m_worldAABB.lowerBound;
            _loc1_ = _loc10_.m_worldAABB.upperBound;
            _loc5_.Set(1 / _loc10_.m_quantizationFactor.x,1 / _loc10_.m_quantizationFactor.y);
            _loc25_.Set(0.9,0.3,0.9);
            _loc23_ = 0;
            while(_loc23_ < 512)
            {
               _loc27_ = _loc10_.m_proxyPool[_loc23_];
               if(_loc27_.IsValid() != false)
               {
                  _loc11_.lowerBound.x = _loc12_.x + _loc5_.x * _loc10_.m_bounds[0][_loc27_.lowerBounds[0]].value;
                  _loc11_.lowerBound.y = _loc12_.y + _loc5_.y * _loc10_.m_bounds[1][_loc27_.lowerBounds[1]].value;
                  _loc11_.upperBound.x = _loc12_.x + _loc5_.x * _loc10_.m_bounds[0][_loc27_.upperBounds[0]].value;
                  _loc11_.upperBound.y = _loc12_.y + _loc5_.y * _loc10_.m_bounds[1][_loc27_.upperBounds[1]].value;
                  _loc7_[0].Set(_loc11_.lowerBound.x,_loc11_.lowerBound.y);
                  _loc7_[1].Set(_loc11_.upperBound.x,_loc11_.lowerBound.y);
                  _loc7_[2].Set(_loc11_.upperBound.x,_loc11_.upperBound.y);
                  _loc7_[3].Set(_loc11_.lowerBound.x,_loc11_.upperBound.y);
                  m_debugDraw.DrawPolygon(_loc7_,4,_loc25_);
               }
               _loc23_++;
            }
            _loc7_[0].Set(_loc12_.x,_loc12_.y);
            _loc7_[1].Set(_loc1_.x,_loc12_.y);
            _loc7_[2].Set(_loc1_.x,_loc1_.y);
            _loc7_[3].Set(_loc12_.x,_loc1_.y);
            m_debugDraw.DrawPolygon(_loc7_,4,new b2Color(0.3,0.9,0.9));
         }
         if(_loc16_ & b2DebugDraw.e_obbBit)
         {
            _loc25_.Set(0.5,0.3,0.5);
            _loc18_ = m_bodyList;
            while(_loc18_)
            {
               _loc13_ = _loc18_.m_xf;
               _loc24_ = _loc18_.GetShapeList();
               while(_loc24_)
               {
                  if(_loc24_.m_type == 1)
                  {
                     _loc19_ = _loc24_ as b2PolygonShape;
                     _loc17_ = _loc19_.GetOBB();
                     _loc22_ = _loc17_.extents;
                     _loc7_[0].Set(-_loc22_.x,-_loc22_.y);
                     _loc7_[1].Set(_loc22_.x,-_loc22_.y);
                     _loc7_[2].Set(_loc22_.x,_loc22_.y);
                     _loc7_[3].Set(-_loc22_.x,_loc22_.y);
                     _loc23_ = 0;
                     while(_loc23_ < 4)
                     {
                        _loc26_ = _loc17_.R;
                        _loc21_ = _loc7_[_loc23_];
                        _loc14_ = _loc17_.center.x + (_loc26_.col1.x * _loc21_.x + _loc26_.col2.x * _loc21_.y);
                        _loc7_[_loc23_].y = _loc17_.center.y + (_loc26_.col1.y * _loc21_.x + _loc26_.col2.y * _loc21_.y);
                        _loc7_[_loc23_].x = _loc14_;
                        _loc26_ = _loc13_.R;
                        _loc14_ = _loc13_.position.x + (_loc26_.col1.x * _loc21_.x + _loc26_.col2.x * _loc21_.y);
                        _loc7_[_loc23_].y = _loc13_.position.y + (_loc26_.col1.y * _loc21_.x + _loc26_.col2.y * _loc21_.y);
                        _loc7_[_loc23_].x = _loc14_;
                        _loc23_++;
                     }
                     m_debugDraw.DrawPolygon(_loc7_,4,_loc25_);
                  }
                  _loc24_ = _loc24_.m_next;
               }
               _loc18_ = _loc18_.m_next;
            }
         }
         if(_loc16_ & b2DebugDraw.e_centerOfMassBit)
         {
            _loc18_ = m_bodyList;
            while(_loc18_)
            {
               _loc13_ = s_xf;
               _loc13_.R = _loc18_.m_xf.R;
               _loc13_.position = _loc18_.GetWorldCenter();
               m_debugDraw.DrawXForm(_loc13_);
               _loc18_ = _loc18_.m_next;
            }
         }
      }
   }
}

