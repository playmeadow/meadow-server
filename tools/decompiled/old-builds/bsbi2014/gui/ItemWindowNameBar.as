package gui
{
   import avatar.AvatarManager;
   import avatar.NameBar;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class ItemWindowNameBar extends ItemWindowBase
   {
      
      private var _isMember:Boolean;
      
      private var _nameBarData:Object;
      
      private var _userName:String;
      
      private var _avName:String;
      
      private var _isBuddy:Boolean;
      
      private var _isBlocked:Boolean;
      
      public function ItemWindowNameBar(windowLoaded:Function, currItem:MovieClip, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._isMember = customParams[index].isMember;
         this._nameBarData = customParams[index].nameBarData;
         this._userName = customParams[index].userName;
         this._avName = customParams[index].avName;
         this._isBuddy = customParams[index].isBuddy;
         this._isBlocked = customParams[index].isBlocked;
         super(this._isMember ? "memberNameBar" : "FreeNameBar",windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      public function get userName() : String
      {
         return this._userName;
      }
      
      public function updateToBeCentered(totalWidth:int) : void
      {
         _window.x += (totalWidth - _window.width) * 0.5;
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
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
         _window.setAvName(LocalizationManager.translateAvatarName(this._avName));
         _window.x += _window.width * 0.5;
         _window.y += _window.height * 0.5;
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window))
         {
            if(_mouseDown != null)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
         }
      }
   }
}

