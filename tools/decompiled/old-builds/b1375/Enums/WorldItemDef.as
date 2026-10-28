package Enums
{
   public class WorldItemDef
   {
      
      public static const TYPE_DEN_ITEM:int = 0;
      
      public static const TYPE_GEMS:int = 1;
      
      public static const TYPE_DIAMONDS:int = 2;
      
      public static const TYPE_ACCESSORY_ITEM:int = 3;
      
      private var _defId:int;
      
      private var _mediaRefId:int;
      
      private var _descText:String;
      
      private var _giftType:int;
      
      private var _giftRefId:int;
      
      private var _giftAmount:int;
      
      private var _position:int;
      
      private var _userVarRefId:int;
      
      private var _userVarIndex:int;
      
      private var _endTime:int;
      
      private var _status:int;
      
      private var _popupType:int;
      
      public function WorldItemDef(param1:int, param2:int, param3:String, param4:int, param5:int, param6:int, param7:int, param8:int, param9:int, param10:int, param11:int = -1)
      {
         super();
         _defId = param1;
         _mediaRefId = param2;
         _descText = param3;
         _giftType = param4;
         _giftRefId = param5;
         _giftAmount = param6;
         _position = param7;
         _userVarRefId = param8;
         _userVarIndex = param9;
         _popupType = param10;
         _endTime = param11;
      }
      
      public function get defId() : int
      {
         return _defId;
      }
      
      public function get mediaRefId() : int
      {
         return _mediaRefId;
      }
      
      public function get descText() : String
      {
         return _descText;
      }
      
      public function get giftType() : int
      {
         return _giftType;
      }
      
      public function get giftRefId() : int
      {
         return _giftRefId;
      }
      
      public function get giftAmount() : int
      {
         return _giftAmount;
      }
      
      public function get position() : int
      {
         return _position;
      }
      
      public function get endTime() : int
      {
         return _endTime;
      }
      
      public function set endTime(param1:int) : void
      {
         _endTime = param1;
      }
      
      public function get status() : int
      {
         return _status;
      }
      
      public function set status(param1:int) : void
      {
         _status = param1;
      }
      
      public function get userVarRefId() : int
      {
         return _userVarRefId;
      }
      
      public function get userVarIndex() : int
      {
         return _userVarIndex;
      }
      
      public function get popupType() : int
      {
         return _popupType;
      }
   }
}

