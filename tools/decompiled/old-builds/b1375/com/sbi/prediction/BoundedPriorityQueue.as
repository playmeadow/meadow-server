package com.sbi.prediction
{
   public class BoundedPriorityQueue
   {
      
      public var maxSize:int;
      
      public var threshold:int;
      
      public var items:Array;
      
      public var priorities:Array;
      
      public function BoundedPriorityQueue(param1:int)
      {
         super();
         this.maxSize = param1;
         threshold = 0;
         items = [];
         priorities = [];
      }
      
      public function add(param1:Object, param2:int) : void
      {
         var _loc3_:* = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc8_:int = 0;
         if(items.length === maxSize)
         {
            if(param2 <= threshold)
            {
               return;
            }
            items.pop();
            priorities.pop();
         }
         if(priorities.length > 60)
         {
            _loc4_ = 0;
            _loc7_ = int(priorities.length);
            while(_loc4_ !== _loc7_)
            {
               _loc6_ = Math.floor((_loc4_ + _loc7_) / 2);
               if(param2 > priorities[_loc6_])
               {
                  _loc7_ = _loc6_;
               }
               else
               {
                  _loc4_ = _loc6_ + 1;
               }
            }
            _loc3_ = _loc4_;
         }
         else
         {
            _loc5_ = int(priorities.length);
            _loc8_ = 0;
            while(_loc8_ < _loc5_)
            {
               if(param2 > priorities[_loc8_])
               {
                  break;
               }
               _loc8_++;
            }
            _loc3_ = _loc8_;
         }
         items.splice(_loc3_,0,param1);
         priorities.splice(_loc3_,0,param2);
         threshold = priorities[maxSize - 1] ? priorities[maxSize - 1] : 0;
      }
      
      public function remove() : Object
      {
         if(items.length === 0)
         {
            return null;
         }
         priorities.shift();
         threshold = priorities[maxSize - 1] ? priorities[maxSize - 1] : 0;
         return items.shift();
      }
      
      public function removeItemAt(param1:int) : void
      {
         priorities.splice(param1,1);
         items.splice(param1,1);
         threshold = priorities[maxSize - 1] ? priorities[maxSize - 1] : 0;
      }
   }
}

