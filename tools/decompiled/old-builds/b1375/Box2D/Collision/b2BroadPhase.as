package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   public class b2BroadPhase
   {
      
      public static var s_validate:Boolean = false;
      
      public static const b2_invalid:uint = 65535;
      
      public static const b2_nullEdge:uint = 65535;
      
      public var m_pairManager:b2PairManager = new b2PairManager();
      
      public var m_proxyPool:Array = new Array(4096);
      
      public var m_freeProxy:uint;
      
      public var m_bounds:Array = new Array(2 * 512);
      
      public var m_queryResults:Array = new Array(512);
      
      public var m_queryResultCount:int;
      
      public var m_worldAABB:b2AABB;
      
      public var m_quantizationFactor:b2Vec2 = new b2Vec2();
      
      public var m_proxyCount:int;
      
      public var m_timeStamp:uint;
      
      public function b2BroadPhase(param1:b2AABB, param2:b2PairCallback)
      {
         var _loc7_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:b2Proxy = null;
         super();
         m_pairManager.Initialize(this,param2);
         m_worldAABB = param1;
         m_proxyCount = 0;
         _loc7_ = 0;
         while(_loc7_ < 512)
         {
            m_queryResults[_loc7_] = 0;
            _loc7_++;
         }
         m_bounds = new Array(2);
         _loc7_ = 0;
         while(_loc7_ < 2)
         {
            m_bounds[_loc7_] = new Array(2 * 512);
            _loc5_ = 0;
            while(_loc5_ < 2 * 512)
            {
               m_bounds[_loc7_][_loc5_] = new b2Bound();
               _loc5_++;
            }
            _loc7_++;
         }
         var _loc4_:Number = param1.upperBound.x - param1.lowerBound.x;
         var _loc3_:Number = param1.upperBound.y - param1.lowerBound.y;
         m_quantizationFactor.x = 65535 / _loc4_;
         m_quantizationFactor.y = 65535 / _loc3_;
         _loc7_ = 0;
         while(_loc7_ < 512 - 1)
         {
            _loc6_ = new b2Proxy();
            m_proxyPool[_loc7_] = _loc6_;
            _loc6_.SetNext(_loc7_ + 1);
            _loc6_.timeStamp = 0;
            _loc6_.overlapCount = 65535;
            _loc6_.userData = null;
            _loc7_++;
         }
         _loc6_ = new b2Proxy();
         m_proxyPool[511] = _loc6_;
         _loc6_.SetNext(b2Pair.b2_nullProxy);
         _loc6_.timeStamp = 0;
         _loc6_.overlapCount = 65535;
         _loc6_.userData = null;
         m_freeProxy = 0;
         m_timeStamp = 1;
         m_queryResultCount = 0;
      }
      
      public static function BinarySearch(param1:Array, param2:int, param3:uint) : uint
      {
         var _loc4_:int = 0;
         var _loc7_:b2Bound = null;
         var _loc6_:int = 0;
         var _loc5_:int = param2 - 1;
         while(_loc6_ <= _loc5_)
         {
            _loc4_ = (_loc6_ + _loc5_) / 2;
            _loc7_ = param1[_loc4_];
            if(_loc7_.value > param3)
            {
               _loc5_ = _loc4_ - 1;
            }
            else
            {
               if(_loc7_.value >= param3)
               {
                  return uint(_loc4_);
               }
               _loc6_ = _loc4_ + 1;
            }
         }
         return uint(_loc6_);
      }
      
      public function InRange(param1:b2AABB) : Boolean
      {
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         _loc5_ = param1.lowerBound.x;
         _loc3_ = param1.lowerBound.y;
         _loc5_ -= m_worldAABB.upperBound.x;
         _loc3_ -= m_worldAABB.upperBound.y;
         _loc4_ = m_worldAABB.lowerBound.x;
         _loc2_ = m_worldAABB.lowerBound.y;
         _loc4_ -= param1.upperBound.x;
         _loc2_ -= param1.upperBound.y;
         _loc5_ = b2Math.b2Max(_loc5_,_loc4_);
         _loc3_ = b2Math.b2Max(_loc3_,_loc2_);
         return b2Math.b2Max(_loc5_,_loc3_) < 0;
      }
      
      public function GetProxy(param1:int) : b2Proxy
      {
         var _loc2_:b2Proxy = m_proxyPool[param1];
         if(param1 == b2Pair.b2_nullProxy || _loc2_.IsValid() == false)
         {
            return null;
         }
         return _loc2_;
      }
      
      public function CreateProxy(param1:b2AABB, param2:*) : uint
      {
         var _loc6_:* = 0;
         var _loc20_:b2Proxy = null;
         var _loc4_:int = 0;
         var _loc17_:Array = null;
         var _loc5_:* = 0;
         var _loc21_:* = 0;
         var _loc22_:Array = null;
         var _loc19_:Array = null;
         var _loc9_:Array = null;
         var _loc12_:int = 0;
         var _loc3_:int = 0;
         var _loc23_:b2Bound = null;
         var _loc16_:b2Bound = null;
         var _loc8_:b2Bound = null;
         var _loc11_:int = 0;
         var _loc13_:b2Proxy = null;
         var _loc14_:int = 0;
         var _loc10_:uint = m_freeProxy;
         _loc20_ = m_proxyPool[_loc10_];
         m_freeProxy = _loc20_.GetNext();
         _loc20_.overlapCount = 0;
         _loc20_.userData = param2;
         var _loc18_:uint = 2 * m_proxyCount;
         var _loc7_:Array = [];
         var _loc15_:Array = [];
         ComputeBounds(_loc7_,_loc15_,param1);
         _loc4_ = 0;
         while(_loc4_ < 2)
         {
            _loc17_ = m_bounds[_loc4_];
            _loc22_ = [_loc5_];
            _loc19_ = [_loc21_];
            Query(_loc22_,_loc19_,_loc7_[_loc4_],_loc15_[_loc4_],_loc17_,_loc18_,_loc4_);
            _loc5_ = uint(_loc22_[0]);
            _loc21_ = uint(_loc19_[0]);
            _loc9_ = [];
            _loc3_ = _loc18_ - _loc21_;
            _loc12_ = 0;
            while(_loc12_ < _loc3_)
            {
               _loc9_[_loc12_] = new b2Bound();
               _loc23_ = _loc9_[_loc12_];
               _loc16_ = _loc17_[int(_loc21_ + _loc12_)];
               _loc23_.value = _loc16_.value;
               _loc23_.proxyId = _loc16_.proxyId;
               _loc23_.stabbingCount = _loc16_.stabbingCount;
               _loc12_++;
            }
            _loc3_ = int(_loc9_.length);
            _loc11_ = _loc21_ + 2;
            _loc12_ = 0;
            while(_loc12_ < _loc3_)
            {
               _loc16_ = _loc9_[_loc12_];
               _loc23_ = _loc17_[int(_loc11_ + _loc12_)];
               _loc23_.value = _loc16_.value;
               _loc23_.proxyId = _loc16_.proxyId;
               _loc23_.stabbingCount = _loc16_.stabbingCount;
               _loc12_++;
            }
            _loc9_ = [];
            _loc3_ = _loc21_ - _loc5_;
            _loc12_ = 0;
            while(_loc12_ < _loc3_)
            {
               _loc9_[_loc12_] = new b2Bound();
               _loc23_ = _loc9_[_loc12_];
               _loc16_ = _loc17_[int(_loc5_ + _loc12_)];
               _loc23_.value = _loc16_.value;
               _loc23_.proxyId = _loc16_.proxyId;
               _loc23_.stabbingCount = _loc16_.stabbingCount;
               _loc12_++;
            }
            _loc3_ = int(_loc9_.length);
            _loc11_ = _loc5_ + 1;
            _loc12_ = 0;
            while(_loc12_ < _loc3_)
            {
               _loc16_ = _loc9_[_loc12_];
               _loc23_ = _loc17_[int(_loc11_ + _loc12_)];
               _loc23_.value = _loc16_.value;
               _loc23_.proxyId = _loc16_.proxyId;
               _loc23_.stabbingCount = _loc16_.stabbingCount;
               _loc12_++;
            }
            _loc21_++;
            _loc23_ = _loc17_[_loc5_];
            _loc16_ = _loc17_[_loc21_];
            _loc23_.value = _loc7_[_loc4_];
            _loc23_.proxyId = _loc10_;
            _loc16_.value = _loc15_[_loc4_];
            _loc16_.proxyId = _loc10_;
            _loc8_ = _loc17_[int(_loc5_ - 1)];
            _loc23_.stabbingCount = _loc5_ == 0 ? 0 : _loc8_.stabbingCount;
            _loc8_ = _loc17_[int(_loc21_ - 1)];
            _loc16_.stabbingCount = _loc8_.stabbingCount;
            _loc6_ = _loc5_;
            while(_loc6_ < _loc21_)
            {
               _loc8_ = _loc17_[_loc6_];
               _loc8_.stabbingCount++;
               _loc6_++;
            }
            _loc6_ = _loc5_;
            while(_loc6_ < _loc18_ + 2)
            {
               _loc23_ = _loc17_[_loc6_];
               _loc13_ = m_proxyPool[_loc23_.proxyId];
               if(_loc23_.IsLower())
               {
                  _loc13_.lowerBounds[_loc4_] = _loc6_;
               }
               else
               {
                  _loc13_.upperBounds[_loc4_] = _loc6_;
               }
               _loc6_++;
            }
            _loc4_++;
         }
         m_proxyCount = m_proxyCount + 1;
         _loc14_ = 0;
         while(_loc14_ < m_queryResultCount)
         {
            m_pairManager.AddBufferedPair(_loc10_,m_queryResults[_loc14_]);
            _loc14_++;
         }
         m_pairManager.Commit();
         m_queryResultCount = 0;
         IncrementTimeStamp();
         return _loc10_;
      }
      
      public function DestroyProxy(param1:uint) : void
      {
         var _loc19_:b2Bound = null;
         var _loc12_:b2Bound = null;
         var _loc3_:int = 0;
         var _loc13_:Array = null;
         var _loc4_:* = 0;
         var _loc17_:* = 0;
         var _loc14_:* = 0;
         var _loc5_:* = 0;
         var _loc7_:Array = null;
         var _loc9_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:int = 0;
         var _loc6_:* = 0;
         var _loc10_:b2Proxy = null;
         var _loc18_:int = 0;
         var _loc11_:int = 0;
         var _loc16_:b2Proxy = m_proxyPool[param1];
         var _loc15_:int = 2 * m_proxyCount;
         _loc3_ = 0;
         while(_loc3_ < 2)
         {
            _loc13_ = m_bounds[_loc3_];
            _loc4_ = uint(_loc16_.lowerBounds[_loc3_]);
            _loc17_ = uint(_loc16_.upperBounds[_loc3_]);
            _loc19_ = _loc13_[_loc4_];
            _loc14_ = _loc19_.value;
            _loc12_ = _loc13_[_loc17_];
            _loc5_ = _loc12_.value;
            _loc7_ = [];
            _loc2_ = _loc17_ - _loc4_ - 1;
            _loc9_ = 0;
            while(_loc9_ < _loc2_)
            {
               _loc7_[_loc9_] = new b2Bound();
               _loc19_ = _loc7_[_loc9_];
               _loc12_ = _loc13_[int(_loc4_ + 1 + _loc9_)];
               _loc19_.value = _loc12_.value;
               _loc19_.proxyId = _loc12_.proxyId;
               _loc19_.stabbingCount = _loc12_.stabbingCount;
               _loc9_++;
            }
            _loc2_ = int(_loc7_.length);
            _loc8_ = _loc4_;
            _loc9_ = 0;
            while(_loc9_ < _loc2_)
            {
               _loc12_ = _loc7_[_loc9_];
               _loc19_ = _loc13_[int(_loc8_ + _loc9_)];
               _loc19_.value = _loc12_.value;
               _loc19_.proxyId = _loc12_.proxyId;
               _loc19_.stabbingCount = _loc12_.stabbingCount;
               _loc9_++;
            }
            _loc7_ = [];
            _loc2_ = _loc15_ - _loc17_ - 1;
            _loc9_ = 0;
            while(_loc9_ < _loc2_)
            {
               _loc7_[_loc9_] = new b2Bound();
               _loc19_ = _loc7_[_loc9_];
               _loc12_ = _loc13_[int(_loc17_ + 1 + _loc9_)];
               _loc19_.value = _loc12_.value;
               _loc19_.proxyId = _loc12_.proxyId;
               _loc19_.stabbingCount = _loc12_.stabbingCount;
               _loc9_++;
            }
            _loc2_ = int(_loc7_.length);
            _loc8_ = _loc17_ - 1;
            _loc9_ = 0;
            while(_loc9_ < _loc2_)
            {
               _loc12_ = _loc7_[_loc9_];
               _loc19_ = _loc13_[int(_loc8_ + _loc9_)];
               _loc19_.value = _loc12_.value;
               _loc19_.proxyId = _loc12_.proxyId;
               _loc19_.stabbingCount = _loc12_.stabbingCount;
               _loc9_++;
            }
            _loc2_ = _loc15_ - 2;
            _loc6_ = _loc4_;
            while(_loc6_ < _loc2_)
            {
               _loc19_ = _loc13_[_loc6_];
               _loc10_ = m_proxyPool[_loc19_.proxyId];
               if(_loc19_.IsLower())
               {
                  _loc10_.lowerBounds[_loc3_] = _loc6_;
               }
               else
               {
                  _loc10_.upperBounds[_loc3_] = _loc6_;
               }
               _loc6_++;
            }
            _loc2_ = _loc17_ - 1;
            _loc18_ = _loc4_;
            while(_loc18_ < _loc2_)
            {
               _loc19_ = _loc13_[_loc18_];
               _loc19_.stabbingCount--;
               _loc18_++;
            }
            Query([0],[0],_loc14_,_loc5_,_loc13_,_loc15_ - 2,_loc3_);
            _loc3_++;
         }
         _loc11_ = 0;
         while(_loc11_ < m_queryResultCount)
         {
            m_pairManager.RemoveBufferedPair(param1,m_queryResults[_loc11_]);
            _loc11_++;
         }
         m_pairManager.Commit();
         m_queryResultCount = 0;
         IncrementTimeStamp();
         _loc16_.userData = null;
         _loc16_.overlapCount = 65535;
         _loc16_.lowerBounds[0] = 65535;
         _loc16_.lowerBounds[1] = 65535;
         _loc16_.upperBounds[0] = 65535;
         _loc16_.upperBounds[1] = 65535;
         _loc16_.SetNext(m_freeProxy);
         m_freeProxy = param1;
         m_proxyCount = m_proxyCount - 1;
      }
      
      public function MoveProxy(param1:uint, param2:b2AABB) : void
      {
         var _loc8_:Array = null;
         var _loc3_:int = 0;
         var _loc4_:* = 0;
         var _loc7_:* = 0;
         var _loc22_:b2Bound = null;
         var _loc10_:b2Bound = null;
         var _loc19_:b2Bound = null;
         var _loc20_:* = 0;
         var _loc23_:b2Proxy = null;
         var _loc13_:Array = null;
         var _loc6_:* = 0;
         var _loc21_:* = 0;
         var _loc12_:* = 0;
         var _loc5_:* = 0;
         var _loc9_:int = 0;
         var _loc17_:int = 0;
         var _loc11_:* = 0;
         var _loc15_:b2Proxy = null;
         if(param1 == b2Pair.b2_nullProxy || 512 <= param1)
         {
            return;
         }
         if(param2.IsValid() == false)
         {
            return;
         }
         var _loc14_:uint = 2 * m_proxyCount;
         var _loc18_:b2Proxy = m_proxyPool[param1];
         var _loc16_:b2BoundValues = new b2BoundValues();
         ComputeBounds(_loc16_.lowerValues,_loc16_.upperValues,param2);
         var _loc24_:b2BoundValues = new b2BoundValues();
         _loc4_ = 0;
         while(_loc4_ < 2)
         {
            _loc22_ = m_bounds[_loc4_][_loc18_.lowerBounds[_loc4_]];
            _loc24_.lowerValues[_loc4_] = _loc22_.value;
            _loc22_ = m_bounds[_loc4_][_loc18_.upperBounds[_loc4_]];
            _loc24_.upperValues[_loc4_] = _loc22_.value;
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < 2)
         {
            _loc13_ = m_bounds[_loc4_];
            _loc6_ = uint(_loc18_.lowerBounds[_loc4_]);
            _loc21_ = uint(_loc18_.upperBounds[_loc4_]);
            _loc12_ = uint(_loc16_.lowerValues[_loc4_]);
            _loc5_ = uint(_loc16_.upperValues[_loc4_]);
            _loc22_ = _loc13_[_loc6_];
            _loc9_ = _loc12_ - _loc22_.value;
            _loc22_.value = _loc12_;
            _loc22_ = _loc13_[_loc21_];
            _loc17_ = _loc5_ - _loc22_.value;
            _loc22_.value = _loc5_;
            if(_loc9_ < 0)
            {
               _loc7_ = _loc6_;
               while(_loc7_ > 0 && _loc12_ < (_loc13_[int(_loc7_ - 1)] as b2Bound).value)
               {
                  _loc22_ = _loc13_[_loc7_];
                  _loc10_ = _loc13_[int(_loc7_ - 1)];
                  _loc11_ = _loc10_.proxyId;
                  _loc15_ = m_proxyPool[_loc10_.proxyId];
                  _loc10_.stabbingCount++;
                  if(_loc10_.IsUpper() == true)
                  {
                     if(TestOverlap(_loc16_,_loc15_))
                     {
                        m_pairManager.AddBufferedPair(param1,_loc11_);
                     }
                     _loc8_ = _loc15_.upperBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_++;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount++;
                  }
                  else
                  {
                     _loc8_ = _loc15_.lowerBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_++;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount--;
                  }
                  _loc8_ = _loc18_.lowerBounds;
                  _loc3_ = int(_loc8_[_loc4_]);
                  _loc3_--;
                  _loc8_[_loc4_] = _loc3_;
                  _loc22_.Swap(_loc10_);
                  _loc7_--;
               }
            }
            if(_loc17_ > 0)
            {
               _loc7_ = _loc21_;
               while(_loc7_ < _loc14_ - 1 && (_loc13_[int(_loc7_ + 1)] as b2Bound).value <= _loc5_)
               {
                  _loc22_ = _loc13_[_loc7_];
                  _loc19_ = _loc13_[int(_loc7_ + 1)];
                  _loc20_ = _loc19_.proxyId;
                  _loc23_ = m_proxyPool[_loc20_];
                  _loc19_.stabbingCount++;
                  if(_loc19_.IsLower() == true)
                  {
                     if(TestOverlap(_loc16_,_loc23_))
                     {
                        m_pairManager.AddBufferedPair(param1,_loc20_);
                     }
                     _loc8_ = _loc23_.lowerBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_--;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount++;
                  }
                  else
                  {
                     _loc8_ = _loc23_.upperBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_--;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount--;
                  }
                  _loc8_ = _loc18_.upperBounds;
                  _loc3_ = int(_loc8_[_loc4_]);
                  _loc3_++;
                  _loc8_[_loc4_] = _loc3_;
                  _loc22_.Swap(_loc19_);
                  _loc7_++;
               }
            }
            if(_loc9_ > 0)
            {
               _loc7_ = _loc6_;
               while(_loc7_ < _loc14_ - 1 && (_loc13_[int(_loc7_ + 1)] as b2Bound).value <= _loc12_)
               {
                  _loc22_ = _loc13_[_loc7_];
                  _loc19_ = _loc13_[int(_loc7_ + 1)];
                  _loc20_ = _loc19_.proxyId;
                  _loc23_ = m_proxyPool[_loc20_];
                  _loc19_.stabbingCount--;
                  if(_loc19_.IsUpper())
                  {
                     if(TestOverlap(_loc24_,_loc23_))
                     {
                        m_pairManager.RemoveBufferedPair(param1,_loc20_);
                     }
                     _loc8_ = _loc23_.upperBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_--;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount--;
                  }
                  else
                  {
                     _loc8_ = _loc23_.lowerBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_--;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount++;
                  }
                  _loc8_ = _loc18_.lowerBounds;
                  _loc3_ = int(_loc8_[_loc4_]);
                  _loc3_++;
                  _loc8_[_loc4_] = _loc3_;
                  _loc22_.Swap(_loc19_);
                  _loc7_++;
               }
            }
            if(_loc17_ < 0)
            {
               _loc7_ = _loc21_;
               while(_loc7_ > 0 && _loc5_ < (_loc13_[int(_loc7_ - 1)] as b2Bound).value)
               {
                  _loc22_ = _loc13_[_loc7_];
                  _loc10_ = _loc13_[int(_loc7_ - 1)];
                  _loc11_ = _loc10_.proxyId;
                  _loc15_ = m_proxyPool[_loc11_];
                  _loc10_.stabbingCount--;
                  if(_loc10_.IsLower() == true)
                  {
                     if(TestOverlap(_loc24_,_loc15_))
                     {
                        m_pairManager.RemoveBufferedPair(param1,_loc11_);
                     }
                     _loc8_ = _loc15_.lowerBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_++;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount--;
                  }
                  else
                  {
                     _loc8_ = _loc15_.upperBounds;
                     _loc3_ = int(_loc8_[_loc4_]);
                     _loc3_++;
                     _loc8_[_loc4_] = _loc3_;
                     _loc22_.stabbingCount++;
                  }
                  _loc8_ = _loc18_.upperBounds;
                  _loc3_ = int(_loc8_[_loc4_]);
                  _loc3_--;
                  _loc8_[_loc4_] = _loc3_;
                  _loc22_.Swap(_loc10_);
                  _loc7_--;
               }
            }
            _loc4_++;
         }
      }
      
      public function Commit() : void
      {
         m_pairManager.Commit();
      }
      
      public function QueryAABB(param1:b2AABB, param2:*, param3:int) : int
      {
         var _loc4_:int = 0;
         var _loc9_:int = 0;
         var _loc11_:int = 0;
         var _loc8_:b2Proxy = null;
         var _loc5_:Array = [];
         var _loc12_:Array = [];
         ComputeBounds(_loc5_,_loc12_,param1);
         var _loc10_:Array = [_loc4_];
         var _loc7_:Array = [_loc9_];
         Query(_loc10_,_loc7_,_loc5_[0],_loc12_[0],m_bounds[0],2 * m_proxyCount,0);
         Query(_loc10_,_loc7_,_loc5_[1],_loc12_[1],m_bounds[1],2 * m_proxyCount,1);
         var _loc6_:int = 0;
         _loc11_ = 0;
         while(_loc11_ < m_queryResultCount && _loc6_ < param3)
         {
            _loc8_ = m_proxyPool[m_queryResults[_loc11_]];
            param2[_loc11_] = _loc8_.userData;
            _loc11_++;
            ++_loc6_;
         }
         m_queryResultCount = 0;
         IncrementTimeStamp();
         return _loc6_;
      }
      
      public function Validate() : void
      {
         var _loc6_:* = null;
         var _loc7_:* = null;
         var _loc8_:* = null;
         var _loc5_:Boolean = false;
         var _loc2_:int = 0;
         var _loc1_:b2Bound = null;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc10_:* = 0;
         var _loc9_:b2Bound = null;
         _loc2_ = 0;
         while(_loc2_ < 2)
         {
            _loc1_ = m_bounds[_loc2_];
            _loc3_ = uint(2 * m_proxyCount);
            _loc4_ = 0;
            _loc10_ = 0;
            while(_loc10_ < _loc3_)
            {
               _loc9_ = _loc1_[_loc10_];
               if(_loc9_.IsLower() == true)
               {
                  _loc4_++;
               }
               else
               {
                  _loc4_--;
               }
               _loc10_++;
            }
            _loc2_++;
         }
      }
      
      private function ComputeBounds(param1:Array, param2:Array, param3:b2AABB) : void
      {
         var _loc7_:Number = param3.lowerBound.x;
         var _loc6_:Number = param3.lowerBound.y;
         _loc7_ = b2Math.b2Min(_loc7_,m_worldAABB.upperBound.x);
         _loc6_ = b2Math.b2Min(_loc6_,m_worldAABB.upperBound.y);
         _loc7_ = b2Math.b2Max(_loc7_,m_worldAABB.lowerBound.x);
         _loc6_ = b2Math.b2Max(_loc6_,m_worldAABB.lowerBound.y);
         var _loc4_:Number = param3.upperBound.x;
         var _loc5_:Number = param3.upperBound.y;
         _loc4_ = b2Math.b2Min(_loc4_,m_worldAABB.upperBound.x);
         _loc5_ = b2Math.b2Min(_loc5_,m_worldAABB.upperBound.y);
         _loc4_ = b2Math.b2Max(_loc4_,m_worldAABB.lowerBound.x);
         _loc5_ = b2Math.b2Max(_loc5_,m_worldAABB.lowerBound.y);
         param1[0] = uint(m_quantizationFactor.x * (_loc7_ - m_worldAABB.lowerBound.x)) & 65535 - 1;
         param2[0] = uint(m_quantizationFactor.x * (_loc4_ - m_worldAABB.lowerBound.x)) & 0xFFFF | 1;
         param1[1] = uint(m_quantizationFactor.y * (_loc6_ - m_worldAABB.lowerBound.y)) & 65535 - 1;
         param2[1] = uint(m_quantizationFactor.y * (_loc5_ - m_worldAABB.lowerBound.y)) & 0xFFFF | 1;
      }
      
      private function TestOverlapValidate(param1:b2Proxy, param2:b2Proxy) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Array = null;
         var _loc5_:b2Bound = null;
         var _loc6_:b2Bound = null;
         _loc4_ = 0;
         while(_loc4_ < 2)
         {
            _loc3_ = m_bounds[_loc4_];
            _loc5_ = _loc3_[param1.lowerBounds[_loc4_]];
            _loc6_ = _loc3_[param2.upperBounds[_loc4_]];
            if(_loc5_.value > _loc6_.value)
            {
               return false;
            }
            _loc5_ = _loc3_[param1.upperBounds[_loc4_]];
            _loc6_ = _loc3_[param2.lowerBounds[_loc4_]];
            if(_loc5_.value < _loc6_.value)
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public function TestOverlap(param1:b2BoundValues, param2:b2Proxy) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:Array = null;
         var _loc5_:b2Bound = null;
         _loc4_ = 0;
         while(_loc4_ < 2)
         {
            _loc3_ = m_bounds[_loc4_];
            _loc5_ = _loc3_[param2.upperBounds[_loc4_]];
            if(param1.lowerValues[_loc4_] > _loc5_.value)
            {
               return false;
            }
            _loc5_ = _loc3_[param2.lowerBounds[_loc4_]];
            if(param1.upperValues[_loc4_] < _loc5_.value)
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      private function Query(param1:Array, param2:Array, param3:uint, param4:uint, param5:Array, param6:uint, param7:int) : void
      {
         var _loc13_:b2Bound = null;
         var _loc12_:* = 0;
         var _loc14_:int = 0;
         var _loc8_:int = 0;
         var _loc11_:b2Proxy = null;
         var _loc10_:uint = BinarySearch(param5,param6,param3);
         var _loc9_:uint = BinarySearch(param5,param6,param4);
         _loc12_ = _loc10_;
         while(_loc12_ < _loc9_)
         {
            _loc13_ = param5[_loc12_];
            if(_loc13_.IsLower())
            {
               IncrementOverlapCount(_loc13_.proxyId);
            }
            _loc12_++;
         }
         if(_loc10_ > 0)
         {
            _loc14_ = _loc10_ - 1;
            _loc13_ = param5[_loc14_];
            _loc8_ = int(_loc13_.stabbingCount);
            while(_loc8_)
            {
               _loc13_ = param5[_loc14_];
               if(_loc13_.IsLower())
               {
                  _loc11_ = m_proxyPool[_loc13_.proxyId];
                  if(_loc10_ <= _loc11_.upperBounds[param7])
                  {
                     IncrementOverlapCount(_loc13_.proxyId);
                     _loc8_--;
                  }
               }
               _loc14_--;
            }
         }
         param1[0] = _loc10_;
         param2[0] = _loc9_;
      }
      
      private function IncrementOverlapCount(param1:uint) : void
      {
         var _loc2_:b2Proxy = m_proxyPool[param1];
         if(_loc2_.timeStamp < m_timeStamp)
         {
            _loc2_.timeStamp = m_timeStamp;
            _loc2_.overlapCount = 1;
         }
         else
         {
            _loc2_.overlapCount = 2;
            m_queryResults[m_queryResultCount] = param1;
            m_queryResultCount = m_queryResultCount + 1;
         }
      }
      
      private function IncrementTimeStamp() : void
      {
         var _loc1_:* = 0;
         if(m_timeStamp == 65535)
         {
            _loc1_ = 0;
            while(_loc1_ < 512)
            {
               (m_proxyPool[_loc1_] as b2Proxy).timeStamp = 0;
               _loc1_++;
            }
            m_timeStamp = 1;
         }
         else
         {
            m_timeStamp = m_timeStamp + 1;
         }
      }
   }
}

