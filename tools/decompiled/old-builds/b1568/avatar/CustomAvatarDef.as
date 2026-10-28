package avatar
{
   public class CustomAvatarDef extends AvatarDef
   {
      
      private var _avatarRefId:int;
      
      private var _iconRefId:int;
      
      private var _particleRefId:int;
      
      private var _patternRefIds:Array;
      
      private var _titleStrRefId:int;
      
      public function CustomAvatarDef(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int, param8:Boolean, param9:Function)
      {
         _avatarRefId = param2;
         _iconRefId = param3;
         _particleRefId = param4;
         GenericListXtCommManager.requestGenericList(param5,onPatternsLoaded,param9);
         _titleStrRefId = param6;
         var _loc10_:AvatarDef = gMainFrame.userInfo.getAvatarDefByAvType(_avatarRefId,false);
         super(param1,_loc10_.colorLayer1,_loc10_.colorLayer2,_loc10_.colorLayer3,0,_loc10_.defEyes,param8,_loc10_.enviroTypeFlag,_loc10_.cost,_titleStrRefId,_loc10_.availability,_loc10_.attackItemRefId,param7,_loc10_.status,_loc10_.mannequinColorLayer1,_loc10_.mannequinColorLayer2,_loc10_.mannequinColorLayer3,_loc10_.availabilityStartTime,_loc10_.availabilityEndTime);
      }
      
      override public function get patternRefIds() : Array
      {
         return _patternRefIds;
      }
      
      public function get particleRefId() : int
      {
         return _particleRefId;
      }
      
      public function get iconRefId() : int
      {
         return _iconRefId;
      }
      
      public function get avatarRefId() : int
      {
         return _avatarRefId;
      }
      
      private function onPatternsLoaded(param1:int, param2:Array, param3:Function) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 6;
         var _loc6_:int = int(param2[_loc4_++]);
         _patternRefIds = [];
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            _patternRefIds.push(int(param2[_loc4_ + _loc5_]));
            _loc5_++;
         }
         super.defPattern = _patternRefIds[0];
         if(param3 != null)
         {
            param3();
            param3 = null;
         }
      }
   }
}

