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
      
      public function PostMessage(msgId:String, message:String, senderUserName:String, iconId:int, patternId:int, color:String, postTime:Number, isBuddy:Boolean)
      {
         super();
         this._msgId = msgId;
         this._message = message;
         this._senderUserName = senderUserName;
         this._iconId = iconId;
         this._patternId = patternId;
         this._color = color;
         this._postTime = postTime;
         this._isBuddy = isBuddy;
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
      
      public function set msgId(value:String) : void
      {
         this._msgId = value;
      }
      
      public function set message(value:String) : void
      {
         this._message = value;
      }
      
      public function set senderUserName(value:String) : void
      {
         this._senderUserName = value;
      }
      
      public function set patternId(value:int) : void
      {
         this._patternId = value;
      }
      
      public function set color(value:String) : void
      {
         this._color = value;
      }
      
      public function set postTime(value:Number) : void
      {
         this._postTime = value;
      }
      
      public function set isBuddy(value:Boolean) : void
      {
         this._isBuddy = value;
      }
   }
}

