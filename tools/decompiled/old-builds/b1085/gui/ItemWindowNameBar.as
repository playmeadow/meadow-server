package gui
{
   import avatar.AvatarManager;
   import avatar.NameBar;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
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
         this._isMember = param9[param4].isMember;
         this._nameBarData = param9[param4].nameBarData;
         this._userName = param9[param4].userName;
         this._avName = param9[param4].avName;
         this._isBuddy = param9[param4].isBuddy;
         this._isBlocked = param9[param4].isBlocked;
         super(this._isMember ? "memberNameBar" : "FreeNameBar",param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function updateToBeCentered(param1:int) : void
      {
         _window.x += (param1 - _window.width) * 0.5;
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         if(this._isMember)
         {
            _window.nubData = AvatarManager.playerAvatarWorldView.nubData;
            _window.setNubType(this._isBuddy ? NameBar.BUDDY : NameBar.NON_BUDDY);
            _window.setColorAndBadge(this._nameBarData);
         }
         else
         {
            _window.iconIds = AvatarManager.playerAvatarWorldView.nameBarIconIds;
            _window.nubData = AvatarManager.playerAvatarWorldView.nubData;
         }
         _window.isBlocked = this._isBlocked;
         _window.setAvName(this._avName);
         _window.x += _window.width * 0.5;
         _window.y += _window.height * 0.5;
      }
      
      override protected function addEventListeners() : void
      {
         if(_window)
         {
            if(_mouseDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
         }
      }
   }
}

