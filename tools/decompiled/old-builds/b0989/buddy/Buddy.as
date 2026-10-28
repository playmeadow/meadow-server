package buddy
{
   import com.sbi.client.SFClient;
   
   public class Buddy
   {
      
      private var _userName:String;
      
      private var _onlineStatus:int;
      
      private var _numDaysSinceLastLogin:int;
      
      public function Buddy()
      {
         super();
      }
      
      public function init(param1:String, param2:int, param3:int = 0) : void
      {
         this._userName = param1;
         this._onlineStatus = param2;
         this._numDaysSinceLastLogin = param3;
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function get onlineStatus() : int
      {
         return this._onlineStatus;
      }
      
      public function get isOnline() : Boolean
      {
         return this._onlineStatus == SFClient.STATUS_ONLINE;
      }
      
      public function get numDaysSinceLastLogin() : int
      {
         return this._numDaysSinceLastLogin;
      }
      
      public function set userName(param1:String) : void
      {
         this._userName = param1;
      }
      
      public function set onlineStatus(param1:int) : void
      {
         this._onlineStatus = param1;
      }
      
      public function set numDaysSinceLastLogin(param1:int) : void
      {
         this._numDaysSinceLastLogin = param1;
      }
   }
}

