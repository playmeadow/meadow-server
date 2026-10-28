package gui
{
   public class JBManager
   {
      
      private static const JB_FACT_LIST_ID:int = 54;
      
      private static const JB_PAGE_BIT_IDX:int = 29;
      
      private static const JB_KEEP_GIFT:int = 31;
      
      private static const JB_DISCARD_GIFT:int = 30;
      
      private static var _defPages:Array;
      
      private static var _unseenPagesIds:Array;
      
      private static var _currRoomJBItems:Array;
      
      private static var _numUnclaimedGifts:int;
      
      private static var _hasLoadedDefs:Boolean;
      
      private static var _numUnseenPages:int;
      
      public function JBManager()
      {
         super();
      }
      
      public static function init() : void
      {
         _defPages = [];
         _unseenPagesIds = [];
         GenericListXtCommManager.requestGenericList(54,onFactListReceived);
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
         _numUnseenPages = _numUnseenPages - 1;
         delete _unseenPagesIds[param1];
      }
      
      public static function checkUnseenPage(param1:Array) : void
      {
         if(param1 && param1.length > 0)
         {
            if(_hasLoadedDefs)
            {
               if(_unseenPagesIds.length > 0)
               {
                  _currRoomJBItems = null;
                  loop0:
                  for each(var _loc2_:Object in param1)
                  {
                     var _loc5_:int = 0;
                     var _loc4_:Array = _unseenPagesIds;
                     do
                     {
                        for each(var _loc3_:int in _loc4_)
                        {
                        }
                        continue loop0;
                     }
                     while(_loc3_ != _loc2_.refId);
                     GuiManager.showJBGlow(true);
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
         var _loc8_:int = 0;
         var _loc7_:Object = null;
         var _loc6_:int = 0;
         _hasLoadedDefs = true;
         var _loc5_:int = int(param1.length);
         var _loc4_:int = 0;
         var _loc3_:Boolean = false;
         _loc8_ = 0;
         while(_loc8_ < _loc5_)
         {
            _loc7_ = param1[_loc8_];
            if(!_defPages[_loc7_.userVarId])
            {
               _defPages[_loc7_.userVarId] = [];
               if(!gMainFrame.userInfo.userVarCache.isBitSet(_loc7_.userVarId,29))
               {
                  _numUnseenPages = _numUnseenPages + 1;
                  _unseenPagesIds[_loc7_.userVarId] = _loc7_.id;
               }
               else
               {
                  _loc3_ = true;
               }
            }
            _defPages[_loc7_.userVarId].push(_loc7_);
            NGFactManager.updateFactDefCache(_loc7_);
            _loc8_++;
         }
         for each(var _loc2_:Array in _defPages)
         {
            _loc6_ = 0;
            _loc8_ = 0;
            while(_loc8_ < _loc2_.length)
            {
               if(gMainFrame.userInfo.userVarCache.isBitSet(_loc2_[_loc8_].userVarId,_loc2_[_loc8_].bitIdx))
               {
                  _loc6_++;
                  _loc3_ = true;
               }
               _loc8_++;
            }
            if(_loc6_ == _loc2_.length)
            {
               if(!(gMainFrame.userInfo.userVarCache.isBitSet(_loc2_[_loc8_ - 1].userVarId,31) || Boolean(gMainFrame.userInfo.userVarCache.isBitSet(_loc2_[_loc8_ - 1].userVarId,30))))
               {
                  _numUnclaimedGifts = _numUnclaimedGifts + 1;
               }
            }
         }
         if(_currRoomJBItems)
         {
            checkUnseenPage(_currRoomJBItems);
         }
         GuiManager.updateJBIcon(_loc3_);
      }
   }
}

