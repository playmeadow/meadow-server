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
      
      public function set playerUserVars(userVars:Object) : void
      {
         var userVarId:String = null;
         this._cache = new Object();
         for(userVarId in userVars)
         {
            this._cache[userVarId] = {
               "value":userVars[userVarId].value,
               "type":userVars[userVarId].type
            };
         }
      }
      
      public function get playerUserVars() : Object
      {
         return this._cache;
      }
      
      public function getUserVarValueById(userVarDefId:int) : int
      {
         if(Boolean(this._cache) && Boolean(this._cache[userVarDefId]))
         {
            return this._cache[userVarDefId].value;
         }
         return -1;
      }
      
      public function getUserVarTypeById(userVarDefId:int) : int
      {
         if(Boolean(this._cache) && Boolean(this._cache[userVarDefId]))
         {
            return this._cache[userVarDefId].type;
         }
         return -1;
      }
      
      public function isBitSet(userVarDefId:int, bitIdx:int) : Boolean
      {
         if(Boolean(this._cache) && Boolean(this._cache[userVarDefId]))
         {
            return Boolean(this._cache[userVarDefId].value & 1 << bitIdx);
         }
         return false;
      }
      
      public function numBitsSet(userVarValue:int, numBitsToCheck:int) : int
      {
         if(userVarValue == 0)
         {
            return 0;
         }
         var numSet:int = 0;
         for(var i:int = 0; i < numBitsToCheck; i++)
         {
            if((userVarValue & 1 << i) != 0)
            {
               numSet++;
            }
         }
         return numSet;
      }
      
      public function updateUserVar(defId:int, value:int, type:int = -1) : void
      {
         if(!this._cache)
         {
            this._cache = new Object();
         }
         if(Boolean(this._cache[defId]))
         {
            this._cache[defId].value = value;
         }
         else
         {
            this._cache[defId] = {
               "value":value,
               "type":type
            };
         }
      }
   }
}

