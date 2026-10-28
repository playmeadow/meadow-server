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
      
      public function Buddy()
      {
         super();
      }
      
      public function init(param1:String, param2:int, param3:int, param4:int = 0) : void
      {
         this._userName = param1;
         this._onlineStatus = param3;
         this._numDaysSinceLastLogin = param4;
         this._userNameModerationFlag = param2;
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
      
      public function set userName(param1:String) : void
      {
         this._userName = param1;
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

