package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   
   public class b2ContactManager extends b2PairCallback
   {
      
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
      
      public var m_world:b2World;
      
      public var m_nullContact:b2NullContact = new b2NullContact();
      
      public var m_destroyImmediate:Boolean;
      
      public function b2ContactManager()
      {
         super();
         m_world = null;
         m_destroyImmediate = false;
      }
      
      override public function PairAdded(param1:*, param2:*) : *
      {
         var _loc6_:b2Shape = param1 as b2Shape;
         var _loc5_:b2Shape = param2 as b2Shape;
         var _loc7_:b2Body = _loc6_.m_body;
         var _loc3_:b2Body = _loc5_.m_body;
         if(_loc7_.IsStatic() && _loc3_.IsStatic())
         {
            return m_nullContact;
         }
         if(_loc6_.m_body == _loc5_.m_body)
         {
            return m_nullContact;
         }
         if(_loc3_.IsConnected(_loc7_))
         {
            return m_nullContact;
         }
         if(m_world.m_contactFilter != null && m_world.m_contactFilter.ShouldCollide(_loc6_,_loc5_) == false)
         {
            return m_nullContact;
         }
         var _loc4_:b2Contact = b2Contact.Create(_loc6_,_loc5_,m_world.m_blockAllocator);
         if(_loc4_ == null)
         {
            return m_nullContact;
         }
         _loc6_ = _loc4_.m_shape1;
         _loc5_ = _loc4_.m_shape2;
         _loc7_ = _loc6_.m_body;
         _loc3_ = _loc5_.m_body;
         _loc4_.m_prev = null;
         _loc4_.m_next = m_world.m_contactList;
         if(m_world.m_contactList != null)
         {
            m_world.m_contactList.m_prev = _loc4_;
         }
         m_world.m_contactList = _loc4_;
         _loc4_.m_node1.contact = _loc4_;
         _loc4_.m_node1.other = _loc3_;
         _loc4_.m_node1.prev = null;
         _loc4_.m_node1.next = _loc7_.m_contactList;
         if(_loc7_.m_contactList != null)
         {
            _loc7_.m_contactList.prev = _loc4_.m_node1;
         }
         _loc7_.m_contactList = _loc4_.m_node1;
         _loc4_.m_node2.contact = _loc4_;
         _loc4_.m_node2.other = _loc7_;
         _loc4_.m_node2.prev = null;
         _loc4_.m_node2.next = _loc3_.m_contactList;
         if(_loc3_.m_contactList != null)
         {
            _loc3_.m_contactList.prev = _loc4_.m_node2;
         }
         _loc3_.m_contactList = _loc4_.m_node2;
         ++m_world.m_contactCount;
         return _loc4_;
      }
      
      override public function PairRemoved(param1:*, param2:*, param3:*) : void
      {
         if(param3 == null)
         {
            return;
         }
         var _loc4_:b2Contact = param3 as b2Contact;
         if(_loc4_ == m_nullContact)
         {
            return;
         }
         Destroy(_loc4_);
      }
      
      public function Destroy(param1:b2Contact) : void
      {
         var _loc16_:b2Body = null;
         var _loc8_:b2Body = null;
         var _loc14_:Array = null;
         var _loc15_:b2ContactPoint = null;
         var _loc12_:int = 0;
         var _loc4_:b2Manifold = null;
         var _loc9_:int = 0;
         var _loc3_:b2ManifoldPoint = null;
         var _loc2_:b2Vec2 = null;
         var _loc5_:b2Vec2 = null;
         var _loc7_:b2Shape = param1.m_shape1;
         var _loc6_:b2Shape = param1.m_shape2;
         var _loc11_:int = param1.m_manifoldCount;
         if(_loc11_ > 0 && m_world.m_contactListener)
         {
            _loc16_ = _loc7_.m_body;
            _loc8_ = _loc6_.m_body;
            _loc14_ = param1.GetManifolds();
            _loc15_ = s_evalCP;
            _loc15_.shape1 = param1.m_shape1;
            _loc15_.shape2 = param1.m_shape2;
            _loc15_.friction = param1.m_friction;
            _loc15_.restitution = param1.m_restitution;
            _loc12_ = 0;
            while(_loc12_ < _loc11_)
            {
               _loc4_ = _loc14_[_loc12_];
               _loc15_.normal.SetV(_loc4_.normal);
               _loc9_ = 0;
               while(_loc9_ < _loc4_.pointCount)
               {
                  _loc3_ = _loc4_.points[_loc9_];
                  _loc15_.position = _loc16_.GetWorldPoint(_loc3_.localPoint1);
                  _loc2_ = _loc16_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc5_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc15_.velocity.Set(_loc5_.x - _loc2_.x,_loc5_.y - _loc2_.y);
                  _loc15_.separation = _loc3_.separation;
                  _loc15_.id.key = _loc3_.id._key;
                  m_world.m_contactListener.Remove(_loc15_);
                  _loc9_++;
               }
               _loc12_++;
            }
         }
         if(param1.m_prev)
         {
            param1.m_prev.m_next = param1.m_next;
         }
         if(param1.m_next)
         {
            param1.m_next.m_prev = param1.m_prev;
         }
         if(param1 == m_world.m_contactList)
         {
            m_world.m_contactList = param1.m_next;
         }
         var _loc10_:b2Body = _loc7_.m_body;
         var _loc13_:b2Body = _loc6_.m_body;
         if(param1.m_node1.prev)
         {
            param1.m_node1.prev.next = param1.m_node1.next;
         }
         if(param1.m_node1.next)
         {
            param1.m_node1.next.prev = param1.m_node1.prev;
         }
         if(param1.m_node1 == _loc10_.m_contactList)
         {
            _loc10_.m_contactList = param1.m_node1.next;
         }
         if(param1.m_node2.prev)
         {
            param1.m_node2.prev.next = param1.m_node2.next;
         }
         if(param1.m_node2.next)
         {
            param1.m_node2.next.prev = param1.m_node2.prev;
         }
         if(param1.m_node2 == _loc13_.m_contactList)
         {
            _loc13_.m_contactList = param1.m_node2.next;
         }
         b2Contact.Destroy(param1,m_world.m_blockAllocator);
         --m_world.m_contactCount;
      }
      
      public function Collide() : void
      {
         var _loc2_:b2Contact = null;
         var _loc3_:b2Body = null;
         var _loc1_:b2Body = null;
         _loc2_ = m_world.m_contactList;
         while(_loc2_)
         {
            _loc3_ = _loc2_.m_shape1.m_body;
            _loc1_ = _loc2_.m_shape2.m_body;
            if(!(_loc3_.IsSleeping() && _loc1_.IsSleeping()))
            {
               _loc2_.Update(m_world.m_contactListener);
            }
            _loc2_ = _loc2_.m_next;
         }
      }
   }
}

