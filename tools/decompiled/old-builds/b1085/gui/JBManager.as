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
      
      public static function set numUnclaimedGifts(param1:int) : void
      {
         _numUnclaimedGifts = param1;
      }
      
      public static function removeUnseenPage(param1:int) : void
      {
         --_numUnseenPages;
         delete _unseenPagesIds[param1];
      }
      
      public static function checkUnseenPage(param1:Array) : void
      {
         var _loc2_:Object = null;
         var _loc3_:int = 0;
         if(Boolean(param1) && param1.length > 0)
         {
            if(_hasLoadedDefs)
            {
               if(_unseenPagesIds.length > 0)
               {
                  _currRoomJBItems = null;
                  for each(_loc2_ in param1)
                  {
                     for each(_loc3_ in _unseenPagesIds)
                     {
                        if(_loc3_ == _loc2_.refId)
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
               _currRoomJBItems = param1;
            }
         }
      }
      
      private static function onFactListReceived(param1:Array) : void
      {
         var _loc5_:Array = null;
         var _loc6_:Object = null;
         var _loc7_:int = 0;
         _hasLoadedDefs = true;
         var _loc2_:int = int(param1.length);
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc6_ = param1[_loc4_];
            if(!_defPages[_loc6_.userVarId])
            {
               _defPages[_loc6_.userVarId] = [];
               if(!gMainFrame.userInfo.userVarCache.isBitSet(_loc6_.userVarId,JB_PAGE_BIT_IDX))
               {
                  ++_numUnseenPages;
                  _unseenPagesIds[_loc6_.userVarId] = _loc6_.id;
               }
            }
            _defPages[_loc6_.userVarId].push(_loc6_);
            NGFactManager.updateFactDefCache(_loc6_);
            _loc4_++;
         }
         for each(_loc5_ in _defPages)
         {
            _loc7_ = 0;
            _loc4_ = 0;
            while(_loc4_ < _loc5_.length)
            {
               if(gMainFrame.userInfo.userVarCache.isBitSet(_loc5_[_loc4_].userVarId,_loc5_[_loc4_].bitIdx))
               {
                  _loc7_++;
               }
               _loc4_++;
            }
            if(_loc7_ == _loc5_.length)
            {
               if(!(Boolean(gMainFrame.userInfo.userVarCache.isBitSet(_loc5_[_loc4_ - 1].userVarId,JB_KEEP_GIFT)) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(_loc5_[_loc4_ - 1].userVarId,JB_DISCARD_GIFT))))
               {
                  ++_numUnclaimedGifts;
               }
            }
         }
         if(_currRoomJBItems)
         {
            checkUnseenPage(_currRoomJBItems);
         }
         GuiManager.updateJBIcon();
      }
   }
}

