package com.sbi.prediction
{
   public class LRUCache
   {
      
      public var dict:SetDictionary = null;
      
      public var list:LinkedList = null;
      
      private var _maxCacheSizeLimit:int = 0;
      
      public function LRUCache(param1:int = 10)
      {
         super();
         dict = new SetDictionary();
         list = new LinkedList();
         _maxCacheSizeLimit = param1;
      }
      
      public function insertInCache(param1:Object) : void
      {
         var _loc3_:Node = null;
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Object is Null");
         }
         var _loc2_:Node = null;
         if(dict.containsKey(param1))
         {
            _loc3_ = dict.getValue(param1) as Node;
            if(_loc3_.next != null)
            {
               _loc3_.next.prev = _loc3_.prev;
            }
            if(_loc3_.prev != null)
            {
               _loc3_.prev.next = _loc3_.next;
            }
            _loc3_.next = null;
            _loc3_.prev = null;
            dict.removeKey(param1);
         }
         else if(dict.getSize() == _maxCacheSizeLimit)
         {
            removeCacheElement();
         }
         dict.insertKey(param1,list.insertAtStartLRU(param1,param1));
      }
      
      public function insertKeyInCache(param1:Object, param2:Object) : void
      {
         var _loc4_:Node = null;
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Key is Null");
         }
         if(param2 == null)
         {
            throw new ArgumentError("Value is Null");
         }
         var _loc3_:Node = null;
         if(dict.containsKey(param1))
         {
            _loc4_ = dict.getValue(param1) as Node;
            if(_loc4_.next != null)
            {
               _loc4_.next.prev = _loc4_.prev;
            }
            if(_loc4_.prev != null)
            {
               _loc4_.prev.next = _loc4_.next;
            }
            _loc4_.next = null;
            _loc4_.prev = null;
            dict.removeKey(param1);
         }
         else if(dict.getSize() == _maxCacheSizeLimit)
         {
            removeCacheElement();
         }
         dict.insertKey(param1,list.insertAtStartLRU(param1,param2));
      }
      
      public function removeCacheElement() : void
      {
         dict.removeKey(list.removeAtEnd().key);
      }
      
      public function getData(param1:Object) : Object
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Key is Null");
         }
         var _loc2_:Node = null;
         if(dict.containsKey(param1))
         {
            return (dict.getValue(param1) as Node).data;
         }
         return null;
      }
      
      public function clearCache() : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         dict = new SetDictionary();
         list = new LinkedList();
      }
      
      public function getCacheSize() : int
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         return dict.getSize();
      }
   }
}

