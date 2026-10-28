package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2CircleContact extends b2Contact
   {
      
      private static const s_evalCP:b2ContactPoint = new b2ContactPoint();
      
      private var m_manifolds:Array = [new b2Manifold()];
      
      public var m_manifold:b2Manifold;
      
      private var m0:b2Manifold = new b2Manifold();
      
      public function b2CircleContact(param1:b2Shape, param2:b2Shape)
      {
         super(param1,param2);
         m_manifold = m_manifolds[0];
         m_manifold.pointCount = 0;
         var _loc3_:b2ManifoldPoint = m_manifold.points[0];
         _loc3_.normalImpulse = 0;
         _loc3_.tangentImpulse = 0;
      }
      
      public static function Create(param1:b2Shape, param2:b2Shape, param3:*) : b2Contact
      {
         return new b2CircleContact(param1,param2);
      }
      
      public static function Destroy(param1:b2Contact, param2:*) : void
      {
      }
      
      override public function Evaluate(param1:b2ContactListener) : void
      {
         var _loc2_:b2Vec2 = null;
         var _loc7_:b2Vec2 = null;
         var _loc5_:b2ManifoldPoint = null;
         var _loc3_:b2ManifoldPoint = null;
         var _loc6_:b2Body = m_shape1.m_body;
         var _loc8_:b2Body = m_shape2.m_body;
         m0.Set(m_manifold);
         b2Collision.b2CollideCircles(m_manifold,m_shape1 as b2CircleShape,_loc6_.m_xf,m_shape2 as b2CircleShape,_loc8_.m_xf);
         var _loc4_:b2ContactPoint = s_evalCP;
         _loc4_.shape1 = m_shape1;
         _loc4_.shape2 = m_shape2;
         _loc4_.friction = m_friction;
         _loc4_.restitution = m_restitution;
         if(m_manifold.pointCount > 0)
         {
            m_manifoldCount = 1;
            _loc3_ = m_manifold.points[0];
            if(m0.pointCount == 0)
            {
               _loc3_.normalImpulse = 0;
               _loc3_.tangentImpulse = 0;
               if(param1)
               {
                  _loc4_.position = _loc6_.GetWorldPoint(_loc3_.localPoint1);
                  _loc2_ = _loc6_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc7_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc4_.velocity.Set(_loc7_.x - _loc2_.x,_loc7_.y - _loc2_.y);
                  _loc4_.normal.SetV(m_manifold.normal);
                  _loc4_.separation = _loc3_.separation;
                  _loc4_.id.key = _loc3_.id._key;
                  param1.Add(_loc4_);
               }
            }
            else
            {
               _loc5_ = m0.points[0];
               _loc3_.normalImpulse = _loc5_.normalImpulse;
               _loc3_.tangentImpulse = _loc5_.tangentImpulse;
               if(param1)
               {
                  _loc4_.position = _loc6_.GetWorldPoint(_loc3_.localPoint1);
                  _loc2_ = _loc6_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint1);
                  _loc7_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc3_.localPoint2);
                  _loc4_.velocity.Set(_loc7_.x - _loc2_.x,_loc7_.y - _loc2_.y);
                  _loc4_.normal.SetV(m_manifold.normal);
                  _loc4_.separation = _loc3_.separation;
                  _loc4_.id.key = _loc3_.id._key;
                  param1.Persist(_loc4_);
               }
            }
         }
         else
         {
            m_manifoldCount = 0;
            if(m0.pointCount > 0 && param1)
            {
               _loc5_ = m0.points[0];
               _loc4_.position = _loc6_.GetWorldPoint(_loc5_.localPoint1);
               _loc2_ = _loc6_.GetLinearVelocityFromLocalPoint(_loc5_.localPoint1);
               _loc7_ = _loc8_.GetLinearVelocityFromLocalPoint(_loc5_.localPoint2);
               _loc4_.velocity.Set(_loc7_.x - _loc2_.x,_loc7_.y - _loc2_.y);
               _loc4_.normal.SetV(m0.normal);
               _loc4_.separation = _loc5_.separation;
               _loc4_.id.key = _loc5_.id._key;
               param1.Remove(_loc4_);
            }
         }
      }
      
      override public function GetManifolds() : Array
      {
         return m_manifolds;
      }
   }
}

