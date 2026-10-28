package playerWall
{
   public class PostMessage
   {
      
      private var _message:String;
      
      private var _senderUserName:String;
      
      private var _patternId:int;
      
      private var _color:String;
      
      private var _msgId:String;
      
      private var _postTime:Number;
      
      private var _isBuddy:Boolean;
      
      private var _iconId:int;
      
      public function PostMessage(param1:String, param2:String, param3:String, param4:int, param5:int, param6:String, param7:Number, param8:Boolean)
      {
         super();
         this._msgId = param1;
         this._message = param2;
         this._senderUserName = param3;
         this._iconId = param4;
         this._patternId = param5;
         this._color = param6;
         this._postTime = param7;
         this._isBuddy = param8;
      }
      
      public function get msgId() : String
      {
         return this._msgId;
      }
      
      public function get message() : String
      {
         return this._message;
      }
      
      public function get senderUserName() : String
      {
         return this._senderUserName;
      }
      
      public function get iconId() : int
      {
         return this._iconId;
      }
      
      public function get patternId() : int
      {
         return this._patternId;
      }
      
      public function get color() : String
      {
         return this._color;
      }
      
      public function get postTime() : Number
      {
         return this._postTime;
      }
      
      public function get isBuddy() : Boolean
      {
         return this._isBuddy;
      }
      
      public function set msgId(param1:String) : void
      {
         this._msgId = param1;
      }
      
      public function set message(param1:String) : void
      {
         this._message = param1;
      }
      
      public function set senderUserName(param1:String) : void
      {
         this._senderUserName = param1;
      }
      
      public function set patternId(param1:int) : void
      {
         this._patternId = param1;
      }
      
      public function set color(param1:String) : void
      {
         this._color = param1;
      }
      
      public function set postTime(param1:Number) : void
      {
         this._postTime = param1;
      }
      
      public function set isBuddy(param1:Boolean) : void
      {
         this._isBuddy = param1;
      }
   }
}

