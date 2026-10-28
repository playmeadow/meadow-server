package gui
{
   public class JBManager
   {
      
      private static var _defPages:Array;
      
      private static var _unseenPagesIds:Array;
      
      private static var _currRoomJBItems:Array;
      
      private static var _numUnclaimedGifts:int;
      
      private static var _hasLoadedDefs:Boolean;
      
      private static var _numUnseenPages:int;
      
      private static const JB_FACT_LIST_ID:int = 54;
      
      private static const JB_PAGE_BIT_IDX:int = 29;
      
      private static const JB_KEEP_GIFT:int = 31;
      
      private static const JB_DISCARD_GIFT:int = 30;
      
      public function JBManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _defPages = [];
         _unseenPagesIds = [];
         GenericListXtCommManager.requestGenericList(JB_FACT_LIST_ID,onFactListReceived);
      }
      
      public static function get numUnseenPages() : int
      {
         return _numUnseenPages;
      }
      
      public static function get numUnclaimedGifts() : int
      {
         return _numUnclaimedGifts;
      }
      
      public static function set numUnclaimedGifts(value:int) : void
      {
         _numUnclaimedGifts = value;
      }
      
      public static function removeUnseenPage(pageUserVarId:int) : void
      {
         --_numUnseenPages;
         delete _unseenPagesIds[pageUserVarId];
      }
      
      public static function checkUnseenPage(currRoomJBItems:Array) : void
      {
         var currJBItem:Object = null;
         var currUnseenId:int = 0;
         if(Boolean(currRoomJBItems) && currRoomJBItems.length > 0)
         {
            if(_hasLoadedDefs)
            {
               if(_unseenPagesIds.length > 0)
               {
                  _currRoomJBItems = null;
                  for each(currJBItem in currRoomJBItems)
                  {
                     for each(currUnseenId in _unseenPagesIds)
                     {
                        if(currUnseenId == currJBItem.refId)
                        {
                           GuiManager.showJBGlow(true);
                           break;
                        }
                     }
                  }
               }
            }
            else
            {
               _currRoomJBItems = currRoomJBItems;
            }
         }
      }
      
      private static function onFactListReceived(factDefs:Array) : void
      {
         var page:Array = null;
         var currDef:Object = null;
         var numBitsSet:int = 0;
         _hasLoadedDefs = true;
         var defsLength:int = int(factDefs.length);
         var bitIndex:int = 0;
         for(var i:int = 0; i < defsLength; i++)
         {
            currDef = factDefs[i];
            if(!_defPages[currDef.userVarId])
            {
               _defPages[currDef.userVarId] = [];
               if(!gMainFrame.userInfo.userVarCache.isBitSet(currDef.userVarId,JB_PAGE_BIT_IDX))
               {
                  ++_numUnseenPages;
                  _unseenPagesIds[currDef.userVarId] = currDef.id;
               }
            }
            _defPages[currDef.userVarId].push(currDef);
            NGFactManager.updateFactDefCache(currDef);
         }
         for each(page in _defPages)
         {
            numBitsSet = 0;
            for(i = 0; i < page.length; i++)
            {
               if(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(page[i].userVarId,page[i].bitIdx)))
               {
                  numBitsSet++;
               }
            }
            if(numBitsSet == page.length)
            {
               if(!(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(page[i - 1].userVarId,JB_KEEP_GIFT)) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(page[i - 1].userVarId,JB_DISCARD_GIFT))))
               {
                  ++_numUnclaimedGifts;
               }
            }
         }
         if(Boolean(_currRoomJBItems))
         {
            checkUnseenPage(_currRoomJBItems);
         }
         GuiManager.updateJBIcon();
      }
   }
}

