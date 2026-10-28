package com.sbi.prediction
{
   public class LinkedList
   {
      
      public var head:Node = null;
      
      public var tail:Node = null;
      
      public function LinkedList()
      {
         super();
      }
      
      public function insertAtStart(param1:Object) : Node
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Obj is Null");
         }
         var _loc2_:Node = new Node();
         _loc2_.data = param1;
         if(this.head == null)
         {
            _loc2_.next = null;
            _loc2_.prev = null;
            this.head = _loc2_;
            this.tail = _loc2_;
         }
         else
         {
            _loc2_.next = this.head;
            this.head.prev = _loc2_;
            _loc2_.prev = null;
            this.head = _loc2_;
         }
         return this.head;
      }
      
      public function insertAtStartLRU(param1:Object, param2:Object) : Node
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param2 == null)
         {
            throw new ArgumentError("Obj is Null");
         }
         var _loc3_:Node = new Node();
         _loc3_.data = param2;
         _loc3_.key = param1;
         if(this.head == null)
         {
            _loc3_.next = null;
            _loc3_.prev = null;
            this.head = _loc3_;
            this.tail = _loc3_;
         }
         else
         {
            _loc3_.next = this.head;
            this.head.prev = _loc3_;
            _loc3_.prev = null;
            this.head = _loc3_;
         }
         return this.head;
      }
      
      public function displayList() : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc1_:Node = null;
         if(this.head != null)
         {
            trace("\nContents of the Linked List: \n");
            _loc1_ = this.head;
            while(_loc1_ != null)
            {
               trace(_loc1_.data);
               _loc1_ = _loc1_.next;
            }
         }
         else
         {
            trace("\nLinked List is empty");
         }
      }
      
      public function insertAtEnd(param1:Object) : void
      {
      }
      
      public function removeAtStart() : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc1_:Node = null;
         if(this.head != null)
         {
            _loc1_ = this.head;
            this.head = this.head.next;
            this.head.prev = null;
            _loc1_ = null;
         }
         else
         {
            trace("\nLinked List is empty");
         }
      }
      
      public function removeAtEnd() : Node
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc1_:Node = null;
         if(this.tail != null)
         {
            _loc1_ = this.tail;
            this.tail = this.tail.prev;
            this.tail.next = null;
         }
         else
         {
            trace("\nLinked List is empty");
         }
         return _loc1_;
      }
      
      public function removeNode(param1:Object) : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Obj is Null");
         }
         var _loc2_:Node = null;
         if(this.head != null)
         {
            _loc2_ = this.head;
            while(_loc2_ != null)
            {
               _loc2_ = _loc2_.next;
            }
         }
         else
         {
            trace("\nLinked List is empty");
         }
      }
   }
}

