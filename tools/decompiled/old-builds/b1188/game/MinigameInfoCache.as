package game
{
   public class MinigameInfoCache
   {
      
      public var currMinigameId:int;
      
      private var minigameInfo:Object;
      
      public function MinigameInfoCache()
      {
         super();
      }
      
      public function init() : void
      {
         this.minigameInfo = new Object();
         this.currMinigameId = -1;
      }
      
      public function destroy() : void
      {
         this.minigameInfo = null;
      }
      
      public function get playerMinigameInfo() : MinigameInfo
      {
         return this.minigameInfo[this.currMinigameId];
      }
      
      public function set playerMinigameInfo(param1:MinigameInfo) : void
      {
         this.currMinigameId = param1.gameDefId;
         this.minigameInfo[this.currMinigameId] = param1;
      }
      
      public function getMinigameInfo(param1:int) : MinigameInfo
      {
         return this.minigameInfo[param1];
      }
      
      public function getMinigameInfoByExtName(param1:String) : MinigameInfo
      {
         var _loc2_:MinigameInfo = null;
         for each(_loc2_ in this.minigameInfo)
         {
            if(_loc2_.extName == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getMinigameInfoBySwfName(param1:String) : MinigameInfo
      {
         var _loc2_:MinigameInfo = null;
         for each(_loc2_ in this.minigameInfo)
         {
            if(_loc2_.swfName == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getAllReadyForPvpGameDefs() : Array
      {
         var _loc1_:Array = null;
         var _loc2_:MinigameInfo = null;
         if(this.minigameInfo)
         {
            _loc1_ = [];
            for each(_loc2_ in this.minigameInfo)
            {
               if(_loc2_.readyForPVP)
               {
                  _loc1_.push(_loc2_);
               }
            }
            _loc1_.sortOn(["gameDefId"],Array.DESCENDING | Array.NUMERIC);
            return _loc1_;
         }
         return null;
      }
      
      public function setMinigameInfo(param1:int, param2:MinigameInfo) : void
      {
         this.minigameInfo[param1] = param2;
      }
   }
}

