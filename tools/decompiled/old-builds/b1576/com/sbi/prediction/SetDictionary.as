package com.sbi.prediction
{
   import flash.utils.Dictionary;
   
   public final dynamic class SetDictionary extends Dictionary
   {
      
      public function SetDictionary(param1:Boolean = false)
      {
         super(param1);
      }
      
      public function insertKeyValue(param1:Object) : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Key is Nothing");
         }
         if(this[param1] != null)
         {
            return;
         }
         this[param1] = param1;
      }
      
      public function insertKey(param1:Object, param2:Object) : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Key is Nothing");
         }
         if(this[param1] != null)
         {
            return;
         }
         this[param1] = param2;
      }
      
      public function insertArray(param1:Array) : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ReferenceError("Argument instance is null");
         }
         if(param1.length > 0)
         {
            for each(var _loc2_:Object in param1)
            {
               if(this[_loc2_] != null)
               {
                  trace("Value for key:" + _loc2_ + " already exists");
               }
               else
               {
                  this[_loc2_] = _loc2_;
               }
            }
         }
      }
      
      public function getSize() : int
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc1_:int = 0;
         for(var _loc2_:Object in this)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      public function removeKey(param1:Object) : void
      {
         var _loc2_:Object = null;
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Key is null");
         }
         if(this[param1] != null)
         {
            _loc2_ = this[param1];
            this[param1] = null;
            delete this[param1];
         }
         else
         {
            trace("Value for key: " + param1 + " does not exist");
         }
      }
      
      public function clear() : void
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         for(var _loc1_:Object in this)
         {
            this[_loc1_] = null;
            delete this[_loc1_];
         }
      }
      
      public function containsKey(param1:Object) : Boolean
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Key passed is null");
         }
         if(this[param1] != null)
         {
            return true;
         }
         return false;
      }
      
      public function containsValue(param1:Object) : Boolean
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(param1 == null)
         {
            throw new ArgumentError("Value passed is null");
         }
         for(var _loc2_:Object in this)
         {
            if(this[_loc2_] != null)
            {
               if(this[_loc2_] == param1)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function toString() : Object
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc2_:String = "";
         for(var _loc1_:Object in this)
         {
            if(this[_loc1_] != null)
            {
               _loc2_ += "key: " + _loc1_ + " value: " + this[_loc1_] + "\n";
            }
         }
         return _loc2_;
      }
      
      public function getKeys(param1:Boolean = true, param2:int = -1) : Array
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc4_:Array = [];
         for(var _loc3_:Object in this)
         {
            _loc4_.push(_loc3_);
         }
         if(param1)
         {
            if(param2 == -1)
            {
               return _loc4_.sort();
            }
            return _loc4_.sort(param2);
         }
         return _loc4_;
      }
      
      public function getValues(param1:Boolean = true, param2:int = -1) : Array
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc4_:Array = [];
         for(var _loc3_:Object in this)
         {
            if(this[_loc3_] != null)
            {
               _loc4_.push(this[_loc3_]);
            }
         }
         if(param1)
         {
            if(param2 == -1)
            {
               return _loc4_.sort();
            }
            return _loc4_.sort(param2);
         }
         return _loc4_;
      }
      
      public function clone() : SetDictionary
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         var _loc2_:SetDictionary = new SetDictionary();
         for(var _loc1_:Object in this)
         {
            _loc2_.insertKey(_loc1_,this[_loc1_]);
         }
         return _loc2_;
      }
      
      public function getValue(param1:Object) : Object
      {
         if(this == null)
         {
            throw new ReferenceError("Object instance is null");
         }
         if(this[param1] != null)
         {
            return this[param1];
         }
         return null;
      }
   }
}

