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
      
      public function set playerMinigameInfo(setMgInfo:MinigameInfo) : void
      {
         this.currMinigameId = setMgInfo.gameDefId;
         this.minigameInfo[this.currMinigameId] = setMgInfo;
      }
      
      public function getMinigameInfo(minigameDefId:int) : MinigameInfo
      {
         return this.minigameInfo[minigameDefId];
      }
      
      public function getMinigameInfoByExtName(minigameExtName:String) : MinigameInfo
      {
         var gmix:MinigameInfo = null;
         for each(gmix in this.minigameInfo)
         {
            if(gmix.extName == minigameExtName)
            {
               return gmix;
            }
         }
         return null;
      }
      
      public function getMinigameInfoBySwfName(minigameSwfName:String) : MinigameInfo
      {
         var gmis:MinigameInfo = null;
         for each(gmis in this.minigameInfo)
         {
            if(gmis.swfName == minigameSwfName)
            {
               return gmis;
            }
         }
         return null;
      }
      
      public function getAllReadyForPvpGameDefs() : Array
      {
         var pvpGameDefs:Array = null;
         var grfp:MinigameInfo = null;
         if(Boolean(this.minigameInfo))
         {
            pvpGameDefs = [];
            for each(grfp in this.minigameInfo)
            {
               if(grfp.readyForPVP)
               {
                  pvpGameDefs.push(grfp);
               }
            }
            pvpGameDefs.sortOn(["gameDefId"],[Array.DESCENDING]);
            return pvpGameDefs;
         }
         return null;
      }
      
      public function setMinigameInfo(setMinigameDefId:int, newGameDefInfo:MinigameInfo) : void
      {
         this.minigameInfo[setMinigameDefId] = newGameDefInfo;
      }
   }
}

