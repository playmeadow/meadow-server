package buddy
{
   import com.sbi.client.SFClient;
   import localization.LocalizationManager;
   
   public class Buddy
   {
      
      private var _userName:String;
      
      private var _uuid:String;
      
      private var _onlineStatus:int;
      
      private var _numDaysSinceLastLogin:int;
      
      private var _userNameModerationFlag:int;
      
      private var _accountType:int;
      
      public function Buddy()
      {
         super();
      }
      
      public function init(param1:String, param2:String, param3:int, param4:int, param5:int, param6:int = 0) : void
      {
         this._userName = param1;
         this._uuid = param2;
         this._onlineStatus = param4;
         this._numDaysSinceLastLogin = param6;
         this._userNameModerationFlag = param3;
         this._accountType = param5;
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function get uuid() : String
      {
         return this._uuid;
      }
      
      public function get userNameModerated() : String
      {
         if(this._userNameModerationFlag > 0)
         {
            return this._userName;
         }
         return LocalizationManager.translateIdOnly(LocalizationManager.NEW_JAMMER_USERNAME);
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
      
      public function get accountType() : int
      {
         return this._accountType;
      }
      
      public function set userName(param1:String) : void
      {
         this._userName = param1;
      }
      
      public function set uuid(param1:String) : void
      {
         this._uuid = param1;
      }
      
      public function set userNameModeratedFlag(param1:int) : void
      {
         this._userNameModerationFlag = param1;
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

