package gui.itemWindows
{
   import avatar.AvatarManager;
   import avatar.NameBar;
   import flash.display.MovieClip;
   import gui.MySettings;
   import localization.LocalizationManager;
   
   public class ItemWindowNameBar extends ItemWindowBase
   {
      
      private var _isMember:Boolean;
      
      private var _nameBarData:Object;
      
      private var _userName:String;
      
      private var _avName:String;
      
      private var _isBuddy:Boolean;
      
      private var _isBlocked:Boolean;
      
      public function ItemWindowNameBar(param1:Function, param2:MovieClip, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         _isMember = param9[param4].isMember;
         _nameBarData = param9[param4].nameBarData;
         _userName = param9[param4].userName;
         _avName = param9[param4].avName;
         _isBuddy = param9[param4].isBuddy;
         _isBlocked = param9[param4].isBlocked;
         super(_isMember ? "memberNameBar" : "FreeNameBar",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get userName() : String
      {
         return _userName;
      }
      
      public function updateToBeCentered(param1:int) : void
      {
         _window.x += (param1 - _window.width) * 0.5;
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(_isMember)
         {
            _window.setNubType(_isBuddy ? NameBar.BUDDY : NameBar.NON_BUDDY);
            _window.setColorAndBadge(_nameBarData);
         }
         else
         {
            _window.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
         }
         _window.isBlocked = _isBlocked;
         _window.setAvName(LocalizationManager.translateAvatarName(_avName),Utility.isSettingOn(MySettings.SETTINGS_USERNAME_BADGE));
         _window.x += _window.width * 0.5;
         _window.y += _window.height * 0.5;
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null)
            {
               addEventListener("mouseDown",_mouseDown,false,0,true);
            }
         }
      }
   }
}

