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
   import pet.GuiPet;
   import quest.QuestXtCommManager;
   
   public class ItemWindowCustPlayers extends ItemWindowBase
   {
      
      private var _onBxBtn:Function;
      
      private var _currUserName:String;
      
      private var _ai:AvatarInfo;
      
      private var _scriptDefId:int;
      
      public function ItemWindowCustPlayers(param1:Function, param2:Object, param3:String, param4:int, param5:Function = null, param6:Function = null, param7:Function = null, param8:Function = null, param9:Object = null)
      {
         this._onBxBtn = param9.onBxBtn;
         this._scriptDefId = param9.scriptDefId;
         super(2301,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.bx.visible = false;
         super.setChildrenAndInitialConditions();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc4_:AvatarInfo = null;
         while(_window.char.charLayer.numChildren > 0)
         {
            _window.char.charLayer.removeChildAt(0);
         }
         _window.char.gotoAndPlay("waiting");
         LocalizationManager.translateId(_window.nameBar.firstName_txt,11101);
         _window.nameBar.lastName_txt.text = "";
         _window.char.gotoAndPlay("up");
         var _loc3_:Avatar = AvatarManager.getAvatarBySfsUserId(int(_currItem));
         if(_loc3_)
         {
            _loc4_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc3_.userName);
         }
         if(_loc3_ == null || _loc4_ == null)
         {
            AvatarXtCommManager.requestAvatarGetBySfsId(int(_currItem),this.onAvatarGetReceived);
         }
         else
         {
            this.setupAvatar(_loc3_,_loc4_.currPet);
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
      
      private function setupAvatar(param1:Avatar, param2:Object) : void
      {
         var _loc5_:GuiPet = null;
         var _loc6_:AvatarView = null;
         var _loc7_:Point = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:String = null;
         var _loc3_:Object = QuestXtCommManager.getScriptDef(this._scriptDefId);
         if(_loc3_.playAsPet)
         {
            _loc5_ = new GuiPet(0,param2.lBits,param2.uBits,param2.eBits,param2.type,param2.name,this.onBigPetLoaded);
            _window.char.charLayer.addChild(_loc5_);
            _window.nameBar.firstName_txt.text = _loc5_.petName;
         }
         else
         {
            _loc6_ = new AvatarView();
            _loc6_.init(param1);
            _loc6_.playAnim(LayerAnim.AN_HUD_AVT);
            _loc6_.scaleX = 0.7;
            _loc6_.scaleY = 0.7;
            _loc7_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc6_.avTypeId);
            _loc6_.x = _loc7_.x;
            _loc6_.y = _loc7_.y + 5;
            _window.char.charLayer.addChild(_loc6_);
            _loc8_ = param1.avName;
            _loc9_ = _loc8_.indexOf(" ");
            if(_loc9_ != -1)
            {
               _loc10_ = _loc8_.substr(0,_loc9_);
               _loc11_ = _loc8_.substr(_loc9_ + 1,_loc8_.length);
            }
            else
            {
               _loc10_ = _loc8_;
            }
            _window.nameBar.firstName_txt.text = _loc10_;
            if(_loc11_)
            {
               _window.nameBar.lastName_txt.text = _loc11_;
            }
         }
         this._currUserName = param1.userName;
         this._ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param1.userName,param1.perUserAvId);
         var _loc4_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.userName);
         if(Boolean(this._ai) && Boolean(_loc4_) && this._ai.questLevel > 0)
         {
            this.loadQuestShape(_loc4_.nameBarData);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc5_:AvatarInfo = null;
         var _loc6_:int = 0;
         var _loc7_:Avatar = null;
         if(param2)
         {
            _loc5_ = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
            if(!_loc5_)
            {
               throw new Error("onAvatarSFSGetReceived and avInfo is null");
            }
            _loc6_ = _loc5_.perUserAvId;
            _loc7_ = AvatarManager.getAvatarByUserName(param1);
            if(_loc7_ == null)
            {
               _loc7_ = AvatarUtility.generateNew(_loc6_,null,param1,-1,0);
            }
            this.setupAvatar(_loc7_,_loc5_.currPet);
         }
      }
      
      private function onBigPetLoaded(param1:MovieClip, param2:GuiPet) : void
      {
         param2.scaleX = param2.scaleY = 1.5;
         param2.y += 30;
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

