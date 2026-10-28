package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   public class b2Contact
   {
      
      public static var e_nonSolidFlag:uint = 1;
      
      public static var e_slowFlag:uint = 2;
      
      public static var e_islandFlag:uint = 4;
      
      public static var e_toiFlag:uint = 8;
      
      public static var s_registers:Array;
      
      public static var s_initialized:Boolean = false;
      
      public var m_flags:uint;
      
      public var m_prev:b2Contact;
      
      public var m_next:b2Contact;
      
      public var m_node1:b2ContactEdge = new b2ContactEdge();
      
      public var m_node2:b2ContactEdge = new b2ContactEdge();
      
      public var m_shape1:b2Shape;
      
      public var m_shape2:b2Shape;
      
      public var m_manifoldCount:int;
      
      public var m_friction:Number;
      
      public var m_restitution:Number;
      
      public var m_toi:Number;
      
      public function b2Contact(param1:b2Shape = null, param2:b2Shape = null)
      {
         super();
         m_flags = 0;
         if(!param1 || !param2)
         {
            m_shape1 = null;
            m_shape2 = null;
            return;
         }
         if(param1.IsSensor() || param2.IsSensor())
         {
            m_flags |= e_nonSolidFlag;
         }
         m_shape1 = param1;
         m_shape2 = param2;
         m_manifoldCount = 0;
         m_friction = Math.sqrt(m_shape1.m_friction * m_shape2.m_friction);
         m_restitution = b2Math.b2Max(m_shape1.m_restitution,m_shape2.m_restitution);
         m_prev = null;
         m_next = null;
         m_node1.contact = null;
         m_node1.prev = null;
         m_node1.next = null;
         m_node1.other = null;
         m_node2.contact = null;
         m_node2.prev = null;
         m_node2.next = null;
         m_node2.other = null;
      }
      
      public static function AddType(param1:Function, param2:Function, param3:int, param4:int) : void
      {
         s_registers[param3][param4].createFcn = param1;
         s_registers[param3][param4].destroyFcn = param2;
         s_registers[param3][param4].primary = true;
         if(param3 != param4)
         {
            s_registers[param4][param3].createFcn = param1;
            s_registers[param4][param3].destroyFcn = param2;
            s_registers[param4][param3].primary = false;
         }
      }
      
      public static function InitializeRegisters() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = 0;
         s_registers = new Array(2);
         _loc2_ = 0;
         while(_loc2_ < 2)
         {
            s_registers[_loc2_] = new Array(2);
            _loc1_ = 0;
            while(_loc1_ < 2)
            {
               s_registers[_loc2_][_loc1_] = new b2ContactRegister();
               _loc1_++;
            }
            _loc2_++;
         }
         AddType(b2CircleContact.Create,b2CircleContact.Destroy,0,0);
         AddType(b2PolyAndCircleContact.Create,b2PolyAndCircleContact.Destroy,1,0);
         AddType(b2PolygonContact.Create,b2PolygonContact.Destroy,1,1);
      }
      
      public static function Create(param1:b2Shape, param2:b2Shape, param3:*) : b2Contact
      {
         var _loc4_:b2Contact = null;
         var _loc10_:int = 0;
         var _loc8_:b2Manifold = null;
         if(s_initialized == false)
         {
            InitializeRegisters();
            s_initialized = true;
         }
         var _loc6_:int = param1.m_type;
         var _loc7_:int = param2.m_type;
         var _loc5_:b2ContactRegister = s_registers[_loc6_][_loc7_];
         var _loc9_:Function = _loc5_.createFcn;
         if(_loc9_ != null)
         {
            if(_loc5_.primary)
            {
               return _loc9_(param1,param2,param3);
            }
            _loc4_ = _loc9_(param2,param1,param3);
            _loc10_ = 0;
            while(_loc10_ < _loc4_.m_manifoldCount)
            {
               _loc8_ = _loc4_.GetManifolds()[_loc10_];
               _loc8_.normal = _loc8_.normal.Negative();
               _loc10_++;
            }
            return _loc4_;
         }
         return null;
      }
      
      public static function Destroy(param1:b2Contact, param2:*) : void
      {
         if(param1.m_manifoldCount > 0)
         {
            param1.m_shape1.m_body.WakeUp();
            param1.m_shape2.m_body.WakeUp();
         }
         var _loc4_:int = param1.m_shape1.m_type;
         var _loc6_:int = param1.m_shape2.m_type;
         var _loc3_:b2ContactRegister = s_registers[_loc4_][_loc6_];
         var _loc5_:Function = _loc3_.destroyFcn;
         _loc5_(param1,param2);
      }
      
      public function GetManifolds() : Array
      {
         return null;
      }
      
      public function GetManifoldCount() : int
      {
         return m_manifoldCount;
      }
      
      public function IsSolid() : Boolean
      {
         return (m_flags & e_nonSolidFlag) == 0;
      }
      
      public function GetNext() : b2Contact
      {
         return m_next;
      }
      
      public function GetShape1() : b2Shape
      {
         return m_shape1;
      }
      
      public function GetShape2() : b2Shape
      {
         return m_shape2;
      }
      
      public function Update(param1:b2ContactListener) : void
      {
         var _loc3_:int = m_manifoldCount;
         Evaluate(param1);
         var _loc5_:int = m_manifoldCount;
         var _loc4_:b2Body = m_shape1.m_body;
         var _loc2_:b2Body = m_shape2.m_body;
         if(_loc5_ == 0 && _loc3_ > 0)
         {
            _loc4_.WakeUp();
            _loc2_.WakeUp();
         }
         if(_loc4_.IsStatic() || _loc4_.IsBullet() || _loc2_.IsStatic() || _loc2_.IsBullet())
         {
            m_flags &= ~e_slowFlag;
         }
         else
         {
            m_flags |= e_slowFlag;
         }
      }
      
      public function Evaluate(param1:b2ContactListener) : void
      {
      }
   }
}

