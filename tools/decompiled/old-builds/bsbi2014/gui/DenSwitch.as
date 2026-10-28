package gui
{
   import avatar.UserInfo;
   import den.DenXtCommManager;
   
   public class DenSwitch
   {
      
      public static var activeDenIdx:int;
      
      public static var playerUserInfo:UserInfo;
      
      public static var playerUsername:String;
      
      public static var playerSfsUserId:int;
      
      private static var _denList:Array;
      
      private static var _addDenCallback:Function;
      
      private static var _removeCallback:Function;
      
      private static var _switchIdx:int;
      
      private static var _removeIdx:int;
      
      private static var _maxSlots:int;
      
      private static var _numSlots:int;
      
      public static const RECYCLE_DEN_ROOM:int = 99;
      
      public function DenSwitch()
      {
         super();
      }
      
      public static function init(initActiveDenIdx:int) : void
      {
         setActiveDenIdx(initActiveDenIdx);
      }
      
      public static function destroy() : void
      {
      }
      
      public static function setActiveDenIdx(newActiveDenIdx:int) : void
      {
         activeDenIdx = newActiveDenIdx;
      }
      
      public static function denInfoSet() : void
      {
      }
      
      private static function updateDens() : void
      {
      }
      
      public static function get numSlots() : int
      {
         return _numSlots;
      }
      
      public static function get numDens() : int
      {
         var numDens:int = 0;
         for(var i:int = 0; i < _denList.length; i++)
         {
            if(Boolean(_denList[i]))
            {
               numDens++;
            }
         }
         return numDens;
      }
      
      public static function addNewDen(caIdx:int, denName:String, addDenCallback:Function) : void
      {
         _addDenCallback = addDenCallback;
      }
      
      public static function addDenResponse(success:Boolean, newDenId:int) : void
      {
         if(success)
         {
         }
         if(_addDenCallback != null)
         {
            _addDenCallback(success);
         }
      }
      
      public static function switchDens(switchIdx:int, switchDensCallback:Function = null) : void
      {
         if(switchIdx < 0 || switchIdx >= _denList.length)
         {
            throw new Error("Invalid switchIdx:" + switchIdx);
         }
         _switchIdx = switchIdx;
         activeDenIdx = _denList[_switchIdx].invId;
         DenXtCommManager.requestDenChange(switchIdx,switchDensCallback);
      }
      
      public static function denListResponse(dList:Array) : void
      {
         _denList = dList;
      }
      
      public static function removeDen(removeIdx:int, removeDensCallback:Function) : void
      {
         if(removeIdx < 0 || removeIdx >= _denList.length)
         {
            throw new Error("Invalid removeIdx:" + removeIdx);
         }
         _removeCallback = removeDensCallback;
         _removeIdx = removeIdx;
         if(_denList[removeIdx].invId != activeDenIdx && _denList[removeIdx].invId > 0)
         {
            DenXtCommManager.requestRecycle(false,_denList[removeIdx].invId,denRecycleResponse);
         }
         else
         {
            denRecycleResponse(false);
         }
      }
      
      public static function denRecycleResponse(success:Boolean) : void
      {
         if(success)
         {
            _denList[_removeIdx] = null;
         }
         if(_removeCallback != null)
         {
            _removeCallback(success,_removeIdx);
         }
         _removeIdx = -1;
      }
      
      public static function get denList() : Array
      {
         return _denList;
      }
      
      public static function get nextFreeSlotIdx() : int
      {
         for(var i:int = 0; i < SwitchManager.NUM_DEN_ROOM_SLOTS; i++)
         {
            if(!_denList[i])
            {
               return i;
            }
         }
         return -1;
      }
      
      public static function haveOceanDen() : Boolean
      {
         for(var i:int = 0; i < _denList.length; i++)
         {
            if(Boolean(_denList[i]) && _denList[i].enviroType == Utility.ENVIRO_OCEAN)
            {
               return true;
            }
         }
         return false;
      }
   }
}

