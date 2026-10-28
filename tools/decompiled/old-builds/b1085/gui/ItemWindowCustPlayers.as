package gui
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import com.sbi.graphics.LayerAnim;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import localization.LocalizationManager;
   
   public class ItemWindowCustPlayers extends ItemWindowBase
   {
      
      private var _onBxBtn:Function;
      
      private var _currUserName:String;
      
      private var _ai:AvatarInfo;
      
      public function ItemWindowCustPlayers(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._onBxBtn = param9.onBxBtn;
         super(2301,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.bx.visible = false;
         super.setChildrenAndInitialConditions();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         while(_window.char.charLayer.numChildren > 0)
         {
            _window.char.charLayer.removeChildAt(0);
         }
         _window.char.gotoAndPlay("waiting");
         LocalizationManager.translateId(_window.nameBar.firstName_txt,11101);
         _window.nameBar.lastName_txt.text = "";
         _window.char.gotoAndPlay("up");
         var _loc3_:Avatar = AvatarManager.getAvatarBySfsUserId(int(_currItem));
         if(_loc3_ == null)
         {
            AvatarXtCommManager.requestAvatarGetBySfsId(int(_currItem),this.onAvatarGetReceived);
         }
         else
         {
            this.setupAvatar(_loc3_);
         }
      }
      
      override protected function addEventListeners() : void
      {
         _window.bx.addEventListener(MouseEvent.MOUSE_DOWN,this._onBxBtn,false,0,true);
         super.addEventListeners();
      }
      
      override protected function removeEventListeners() : void
      {
         _window.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this._onBxBtn);
         super.removeEventListeners();
      }
      
      public function showXBtn(param1:Boolean) : void
      {
         _window.bx.visible = param1;
      }
      
      public function get userName() : String
      {
         return this._currUserName;
      }
      
      public function get char() : MovieClip
      {
         return _window.char;
      }
      
      private function setupAvatar(param1:Avatar) : void
      {
         var _loc6_:String = null;
         var _loc7_:String = null;
         this._currUserName = param1.userName;
         var _loc2_:AvatarView = new AvatarView();
         _loc2_.init(param1);
         _loc2_.playAnim(LayerAnim.AN_HUD_AVT);
         _loc2_.scaleX = 0.7;
         _loc2_.scaleY = 0.7;
         var _loc3_:Point = AvatarUtility.getAvatarMinigameLobbyOffset(_loc2_.avTypeId);
         _loc2_.x = _loc3_.x;
         _loc2_.y = _loc3_.y;
         _window.char.charLayer.addChild(_loc2_);
         var _loc4_:String = param1.avName;
         var _loc5_:int = _loc4_.indexOf(" ");
         if(_loc5_ != -1)
         {
            _loc6_ = _loc4_.substr(0,_loc5_);
            _loc7_ = _loc4_.substr(_loc5_ + 1,_loc4_.length);
         }
         else
         {
            _loc6_ = _loc4_;
         }
         _window.nameBar.firstName_txt.text = _loc6_;
         if(_loc7_)
         {
            _window.nameBar.lastName_txt.text = _loc7_;
         }
         this._ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenDbAvId(param1.userName,param1.dbAvId);
         var _loc8_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.userName);
         if(Boolean(this._ai) && Boolean(_loc8_) && this._ai.questLevel > 0)
         {
            this.loadQuestShape(_loc8_.nameBarData);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc5_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
         if(!_loc5_)
         {
            throw new Error("onAvatarSFSGetReceived and avInfo is null");
         }
         var _loc6_:int = _loc5_.dbAvId;
         var _loc7_:Avatar = AvatarManager.getAvatarByUserName(param1);
         if(_loc7_ == null)
         {
            _loc7_ = AvatarUtility.generateNew(_loc6_,null,param1,-1,0);
         }
         this.setupAvatar(_loc7_);
      }
      
      private function loadQuestShape(param1:int) : void
      {
         var _loc2_:String = _window.xpShape.currentLabels[Utility.getColorId(param1) - 1].name;
         _window.xpShape.visible = true;
         if(_loc2_ == "black")
         {
            _window.xpShape.gotoAndStop(2);
            _window.xpShape.gotoAndStop(_loc2_);
         }
         if(_window.xpShape.currentFrameLabel != _loc2_)
         {
            _window.xpShape.gotoAndStop(_loc2_);
         }
         Utility.createXpShape(this._ai.questLevel,true,_window.xpShape[_loc2_].mouse.up.icon,null,param1);
      }
   }
}

