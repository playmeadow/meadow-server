package buddy
{
   import com.sbi.client.SFClient;
   import localization.LocalizationManager;
   
   public class Buddy
   {
      
      private var _userName:String;
      
      private var _onlineStatus:int;
      
      private var _numDaysSinceLastLogin:int;
      
      private var _userNameModerationFlag:int;
      
      private var _accountType:int;
      
      public function Buddy()
      {
         super();
      }
      
      public function init(userName:String, userNameModerationFlag:int, onlineStatus:int, accountType:int, numDaysSinceLastLogin:int = 0) : void
      {
         this._userName = userName;
         this._onlineStatus = onlineStatus;
         this._numDaysSinceLastLogin = numDaysSinceLastLogin;
         this._userNameModerationFlag = userNameModerationFlag;
         this._accountType = accountType;
      }
      
      public function get userName() : String
      {
         return this._userName;
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
      
      public function set userName(value:String) : void
      {
         this._userName = value;
      }
      
      public function set userNameModeratedFlag(value:int) : void
      {
         this._userNameModerationFlag = value;
      }
      
      public function set onlineStatus(value:int) : void
      {
         this._onlineStatus = value;
      }
      
      public function set numDaysSinceLastLogin(value:int) : void
      {
         this._numDaysSinceLastLogin = value;
      }
   }
}

