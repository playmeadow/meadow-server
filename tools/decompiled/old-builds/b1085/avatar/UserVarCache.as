package avatar
{
   public class UserVarCache
   {
      
      private var _cache:Object;
      
      public function UserVarCache()
      {
         super();
      }
      
      public function init() : void
      {
         this._cache = new Object();
      }
      
      public function set playerUserVars(param1:Object) : void
      {
         var _loc2_:String = null;
         this._cache = new Object();
         for(_loc2_ in param1)
         {
            this._cache[_loc2_] = {
               "value":param1[_loc2_].value,
               "type":param1[_loc2_].type
            };
         }
      }
      
      public function get playerUserVars() : Object
      {
         return this._cache;
      }
      
      public function getUserVarValueById(param1:int) : int
      {
         if(Boolean(this._cache) && Boolean(this._cache[param1]))
         {
            return this._cache[param1].value;
         }
         return -1;
      }
      
      public function getUserVarTypeById(param1:int) : int
      {
         if(Boolean(this._cache) && Boolean(this._cache[param1]))
         {
            return this._cache[param1].type;
         }
         return -1;
      }
      
      public function isBitSet(param1:int, param2:int) : Boolean
      {
         if(Boolean(this._cache) && Boolean(this._cache[param1]))
         {
            return Boolean(this._cache[param1].value & 1 << param2);
         }
         return false;
      }
      
      public function updateUserVar(param1:int, param2:int, param3:int = -1) : void
      {
         if(!this._cache)
         {
            this._cache = new Object();
         }
         if(this._cache[param1])
         {
            this._cache[param1].value = param2;
         }
         else
         {
            this._cache[param1] = {
               "value":param2,
               "type":param3
            };
         }
      }
   }
}

