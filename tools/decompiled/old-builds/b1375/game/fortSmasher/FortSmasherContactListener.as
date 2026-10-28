package game.fortSmasher
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2ContactPoint;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2ContactResult;
   import Box2D.Dynamics.b2ContactListener;
   import flash.utils.Dictionary;
   
   public class FortSmasherContactListener extends b2ContactListener
   {
      
      public var contactStack:Array = [];
      
      private var shapeLookup:Dictionary = new Dictionary();
      
      public function FortSmasherContactListener()
      {
         super();
      }
      
      override public function Add(param1:b2ContactPoint) : void
      {
         var _loc4_:b2Shape = param1.shape1;
         var _loc3_:b2Shape = param1.shape2;
         var _loc2_:b2Vec2 = param1.position;
         if((_loc4_.m_isSensor || _loc3_.m_isSensor) && (_loc4_.m_body.m_userData && _loc4_.m_body.m_userData.name == "ball" || _loc3_.m_body.m_userData && _loc3_.m_body.m_userData.name == "ball"))
         {
            contactStack.push(new FortSmasherCustomContactPoint(_loc4_,_loc3_,0,0,_loc2_));
         }
         else if(_loc4_.m_body.m_userData && _loc4_.m_body.m_userData.hasOwnProperty("type") && _loc4_.m_body.m_userData.type == 4)
         {
            _loc4_.m_body.m_userData.linVelX = _loc4_.m_body.m_linearVelocity.x;
            _loc4_.m_body.m_userData.linVelY = _loc4_.m_body.m_linearVelocity.y;
            _loc4_.m_body.m_userData.angVel = _loc4_.m_body.m_angularVelocity;
         }
         else if(_loc3_.m_body.m_userData && _loc3_.m_body.m_userData.hasOwnProperty("type") && _loc3_.m_body.m_userData.type == 4)
         {
            _loc3_.m_body.m_userData.linVelX = _loc3_.m_body.m_linearVelocity.x;
            _loc3_.m_body.m_userData.linVelY = _loc3_.m_body.m_linearVelocity.y;
            _loc3_.m_body.m_userData.angVel = _loc3_.m_body.m_angularVelocity;
         }
      }
      
      public function reset() : void
      {
         shapeLookup = new Dictionary();
      }
      
      override public function Result(param1:b2ContactResult) : void
      {
         var _loc3_:b2Shape = param1.shape1;
         var _loc2_:b2Shape = param1.shape2;
         var _loc6_:Number = param1.normalImpulse;
         var _loc4_:Number = param1.tangentImpulse;
         var _loc5_:b2Vec2 = param1.position;
         if(_loc6_ > 2 && shapeLookup[_loc3_] == null)
         {
            shapeLookup[_loc3_] = _loc2_;
            contactStack.push(new FortSmasherCustomContactPoint(_loc3_,_loc2_,_loc6_,_loc4_,_loc5_));
         }
      }
   }
}

