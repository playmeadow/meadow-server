package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2PolyAndCircleContact extends b2Contact
   {
      
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
      
      private var m_manifolds:Array = [new b2Manifold()];
      
      public var m_manifold:b2Manifold;
      
      private var m0:b2Manifold = new b2Manifold();
      
      public function b2PolyAndCircleContact(param1:b2Shape, param2:b2Shape)
      {
         super(param1,param2);
         m_manifold = m_manifolds[0];
         b2Settings.b2Assert(m_shape1.m_type == 1);
         b2Settings.b2Assert(m_shape2.m_type == 0);
         m_manifold.pointCount = 0;
         var _loc3_:b2ManifoldPoint = m_manifold.points[0];
         _loc3_.normalImpulse = 0;
         _loc3_.tangentImpulse = 0;
      }
      
      public static function Create(param1:b2Shape, param2:b2Shape, param3:*) : b2Contact
      {
         return new b2PolyAndCircleContact(param1,param2);
      }
      
      public static function Destroy(param1:b2Contact, param2:*) : void
      {
      }
      
      override public function Evaluate(param1:b2ContactListener) : void
      {
         var _loc13_:int = 0;
         var _loc2_:b2Vec2 = null;
         var _loc7_:b2Vec2 = null;
         var _loc5_:b2ManifoldPoint = null;
         var _loc3_:b2ManifoldPoint = null;
         var _loc12_:Boolean = false;
         var _loc11_:* = 0;
         var _loc10_:int = 0;
         var _loc6_:b2Body = m_shape1.m_body;
         var _loc9_:b2Body = m_shape2.m_body;
         m0.Set(m_manifold);
         b2Collision.b2CollidePolygonAndCircle(m_manifold,m_shape1 as b2PolygonShape,_loc6_.m_xf,m_shape2 as b2CircleShape,_loc9_.m_xf);
         var _loc8_:Array = [false,false];
         var _loc4_:b2ContactPoint = s_evalCP;
         _loc4_.shape1 = m_shape1;
         _loc4_.shape2 = m_shape2;
         _loc4_.friction = m_friction;
         _loc4_.restitution = m_restitution;
         if(m_manifold.pointCount > 0)
         {
            _loc13_ = 0;
            while(_loc13_ < m_manifold.pointCount)
            {
               _loc3_ = m_manifold.points[_loc13_];
               _loc3_.normalImpulse = 0;
               _loc3_.tangentImpulse = 0;
               _loc12_ = false;
               _loc11_ = _loc3_.id._key;
               _loc10_ = 0;
               while(_loc10_ < m0.pointCount)
               {
                  if(_loc8_[_loc10_] != true)
                  {
                     _loc5_ = m0.points[_loc10_];
                     if(_loc5_.id._key == _loc11_)
                     {
                        _loc8_[_loc10_] = true;
                        _loc3_.normalImpulse = _loc5_.normalImpulse;
                        _loc3_.tangentImpulse = _loc5_.tangentImpulse;
                        _loc12_ = true;
                        if(param1 != null)
                        {
                           _loc4_.position = _loc6_.GetWorldPoint(_loc3_.localPoint1);
                           _loc2_ = _loc6_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                           _loc7_ = _loc9_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                           _loc4_.velocity.Set(_loc7_.x - _loc2_.x,_loc7_.y - _loc2_.y);
                           _loc4_.normal.SetV(m_manifold.normal);
                           _loc4_.separation = _loc3_.separation;
                           _loc4_.id.key = _loc11_;
                           param1.Persist(_loc4_);
                        }
                        break;
                     }
                  }
                  _loc10_++;
               }
               if(_loc12_ == false && param1 != null)
               {
                  _loc4_.position = _loc6_.GetWorldPoint(_loc3_.localPoint1);
                  _loc2_ = _loc6_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc7_ = _loc9_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc4_.velocity.Set(_loc7_.x - _loc2_.x,_loc7_.y - _loc2_.y);
                  _loc4_.normal.SetV(m_manifold.normal);
                  _loc4_.separation = _loc3_.separation;
                  _loc4_.id.key = _loc11_;
                  param1.Add(_loc4_);
               }
               _loc13_++;
            }
            m_manifoldCount = 1;
         }
         else
         {
            m_manifoldCount = 0;
         }
         if(param1 == null)
         {
            return;
         }
         _loc13_ = 0;
         while(_loc13_ < m0.pointCount)
         {
            if(!_loc8_[_loc13_])
            {
               _loc5_ = m0.points[_loc13_];
               _loc4_.position = _loc6_.GetWorldPoint(_loc5_.localPoint1);
               _loc2_ = _loc6_.GetLinearVelocityFromLocalPoint(_loc5_.localPoint1);
               _loc7_ = _loc9_.GetLinearVelocityFromLocalPoint(_loc5_.localPoint2);
               _loc4_.velocity.Set(_loc7_.x - _loc2_.x,_loc7_.y - _loc2_.y);
               _loc4_.normal.SetV(m0.normal);
               _loc4_.separation = _loc5_.separation;
               _loc4_.id.key = _loc5_.id._key;
               param1.Remove(_loc4_);
            }
            _loc13_++;
         }
      }
      
      override public function GetManifolds() : Array
      {
         return m_manifolds;
      }
   }
}

