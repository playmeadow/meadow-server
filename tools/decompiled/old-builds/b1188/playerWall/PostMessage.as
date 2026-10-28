package playerWall
{
   public class PostMessage
   {
      
      private var _message:String;
      
      private var _senderUserName:String;
      
      private var _patternId:int;
      
      private var _colorId:int;
      
      private var _msgId:String;
      
      private var _postTime:Number;
      
      private var _isBuddy:Boolean;
      
      private var _senderModeratedUserName:String;
      
      private var _avtDefId:int;
      
      private var _avtColors:Array;
      
      private var _avtEyeDefId:int;
      
      private var _avtPatternDefId:int;
      
      private var _senderDbId:int;
      
      private var _localizationId:int;
      
      private var _avtCustomId:int;
      
      public function PostMessage(param1:String, param2:String, param3:int, param4:String, param5:String, param6:int, param7:int, param8:Number, param9:Boolean, param10:int, param11:Array, param12:int, param13:int, param14:int, param15:int)
      {
         super();
         this._msgId = param1;
         this._message = param2;
         this._senderDbId = param3;
         this._senderUserName = param4;
         this._patternId = param6;
         this._colorId = param7;
         this._postTime = param8;
         this._isBuddy = param9;
         this._senderModeratedUserName = param5;
         this._avtDefId = param10;
         this._avtColors = param11;
         this._avtEyeDefId = param12;
         this._avtPatternDefId = param13;
         this._avtCustomId = param15;
         this._localizationId = param14;
      }
      
      public function get msgId() : String
      {
         return this._msgId;
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function get senderDbId() : int
      {
         return this._senderDbId;
      }
      
      public function get senderUserName() : String
      {
         return this._senderUserName;
      }
      
      public function get senderModeratedUserName() : String
      {
         return this._senderModeratedUserName;
      }
      
      public function get patternId() : int
      {
         return this._patternId;
      }
      
      public function get colorId() : int
      {
         return this._colorId;
      }
      
      public function get postTime() : Number
      {
         return this._postTime;
      }
      
      public function get isBuddy() : Boolean
      {
         return this._isBuddy;
      }
      
      public function get avtDefId() : int
      {
         return this._avtDefId;
      }
      
      public function get avtColors() : Array
      {
         return this._avtColors;
      }
      
      public function get avtEyeDefId() : int
      {
         return this._avtEyeDefId;
      }
      
      public function get avtPatternDefId() : int
      {
         return this._avtPatternDefId;
      }
      
      public function get localizationId() : int
      {
         return this._localizationId;
      }
      
      public function get avtCustomId() : int
      {
         return this._avtCustomId;
      }
      
      public function set msgId(param1:String) : void
      {
         this._msgId = param1;
      }
      
      public function set message(param1:String) : void
      {
         this._message = param1;
      }
      
      public function set senderDbId(param1:int) : void
      {
         this._senderDbId = param1;
      }
      
      public function set senderUserName(param1:String) : void
      {
         this._senderUserName = param1;
      }
      
      public function set senderModeratedUserName(param1:String) : void
      {
         this._senderModeratedUserName = param1;
      }
      
      public function set patternId(param1:int) : void
      {
         this._patternId = param1;
      }
      
      public function set colorId(param1:int) : void
      {
         this._colorId = param1;
      }
      
      public function set postTime(param1:Number) : void
      {
         this._postTime = param1;
      }
      
      public function set isBuddy(param1:Boolean) : void
      {
         this._isBuddy = param1;
      }
      
      public function set avtDefId(param1:int) : void
      {
         this._avtDefId = param1;
      }
      
      public function set avtColors(param1:Array) : void
      {
         this._avtColors = param1;
      }
      
      public function set avtEyeDefId(param1:int) : void
      {
         this._avtEyeDefId = param1;
      }
      
      public function set avtPatternDefId(param1:int) : void
      {
         this._avtPatternDefId = param1;
      }
      
      public function set localizationId(param1:int) : void
      {
         this._localizationId = param1;
      }
      
      public function set avtCustomId(param1:int) : void
      {
         this._avtCustomId = param1;
      }
   }
}

