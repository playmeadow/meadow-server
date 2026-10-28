package avatar
{
   public class CustomAvatarDef extends AvatarDef
   {
      
      private var _defId:int;
      
      private var _titleStrRef:int;
      
      private var _iconMediaId:int;
      
      private var _avatarRefId:int;
      
      private var _iconRefId:int;
      
      private var _particleRefId:int;
      
      private var _patternRefId:int;
      
      private var _titleStrRefId:int;
      
      public function CustomAvatarDef(param1:int, param2:int, param3:int, param4:int, param5:int, param6:int, param7:int)
      {
         _defId = param1;
         _avatarRefId = param2;
         _iconRefId = param3;
         _particleRefId = param4;
         _patternRefId = param5;
         _titleStrRefId = param6;
         _iconMediaId = param7;
         super(param1,0,0,0,0,0,false,0,0,_titleStrRefId,0,0,_iconMediaId,0);
      }
      
      override public function get patternRefId() : int
      {
         return _patternRefId;
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
      
      override public function get iconMediaId() : int
      {
         return _iconMediaId;
      }
      
      override public function get titleStrRef() : int
      {
         return _titleStrRef;
      }
      
      override public function get defId() : int
      {
         return _defId;
      }
   }
}

