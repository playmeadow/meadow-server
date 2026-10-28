package gui.itemWindows
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import avatar.UserInfo;
   import flash.display.MovieClip;
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
         _onBxBtn = param9.onBxBtn;
         _scriptDefId = param9.scriptDefId;
         super(2301,param1,param2,param3,param4,param5,param6,param7,param8);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.bx.visible = false;
         super.setChildrenAndInitialConditions();
      }
      
      override public function loadCurrItem(param1:int = 0, param2:int = 0) : void
      {
         var _loc4_:Avatar = null;
         var _loc3_:AvatarInfo = null;
         if(!_isCurrItemLoaded)
         {
            setChildrenAndInitialConditions();
            addEventListeners();
            while(_window.char.charLayer.numChildren > 0)
            {
               _window.char.charLayer.removeChildAt(0);
            }
            _window.char.gotoAndPlay("waiting");
            LocalizationManager.translateId(_window.nameBar.firstName_txt,11101);
            _window.nameBar.lastName_txt.text = "";
            _window.char.gotoAndPlay("up");
            _loc4_ = AvatarManager.getAvatarBySfsUserId(int(_currItem));
            if(_loc4_)
            {
               _loc3_ = gMainFrame.userInfo.getAvatarInfoByUserName(_loc4_.userName);
            }
            if(_loc4_ == null || _loc3_ == null)
            {
               AvatarXtCommManager.requestAvatarGetBySfsId(int(_currItem),onAvatarGetReceived);
            }
            else
            {
               setupAvatar(_loc4_,_loc3_.currPet);
            }
            _isCurrItemLoaded = true;
         }
      }
      
      override protected function addEventListeners() : void
      {
         _window.bx.addEventListener("mouseDown",_onBxBtn,false,0,true);
         super.addEventListeners();
      }
      
      override protected function removeEventListeners() : void
      {
         _window.bx.removeEventListener("mouseDown",_onBxBtn);
         super.removeEventListeners();
      }
      
      public function showXBtn(param1:Boolean) : void
      {
         _window.bx.visible = param1;
      }
      
      public function get userName() : String
      {
         return _currUserName;
      }
      
      public function get char() : MovieClip
      {
         return _window.char;
      }
      
      private function setupAvatar(param1:Avatar, param2:Object) : void
      {
         var _loc5_:GuiPet = null;
         var _loc10_:AvatarView = null;
         var _loc9_:Point = null;
         var _loc8_:String = null;
         var _loc7_:int = 0;
         var _loc6_:String = null;
         var _loc4_:String = null;
         var _loc11_:Object = QuestXtCommManager.getScriptDef(_scriptDefId);
         if(_loc11_.playAsPet)
         {
            _loc5_ = new GuiPet(param2.createdAt,0,param2.lBits,param2.uBits,param2.eBits,param2.type,param2.name,param2.personalityDefId,param2.favoriteToyDefId,param2.favoriteFoodDefId,onBigPetLoaded);
            _window.char.charLayer.addChild(_loc5_);
            _window.nameBar.firstName_txt.text = _loc5_.petName;
         }
         else
         {
            _loc10_ = new AvatarView();
            _loc10_.init(param1);
            _loc10_.playAnim(15,false,0,null,true);
            _loc10_.scaleX = 0.7;
            _loc10_.scaleY = 0.7;
            _loc9_ = AvatarUtility.getAvatarMinigameLobbyOffset(_loc10_.avTypeId);
            _loc10_.x = _loc9_.x;
            _loc10_.y = _loc9_.y + 5;
            _window.char.charLayer.addChild(_loc10_);
            _loc8_ = param1.avName;
            _loc7_ = _loc8_.indexOf(" ");
            if(_loc7_ != -1)
            {
               _loc6_ = _loc8_.substr(0,_loc7_);
               _loc4_ = _loc8_.substr(_loc7_ + 1,_loc8_.length);
            }
            else
            {
               _loc6_ = _loc8_;
            }
            _window.nameBar.firstName_txt.text = _loc6_;
            if(_loc4_)
            {
               _window.nameBar.lastName_txt.text = _loc4_;
            }
         }
         _currUserName = param1.userName;
         _ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(param1.userName,param1.perUserAvId);
         var _loc3_:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(param1.userName);
         if(_ai && _loc3_ && _ai.questLevel > 0)
         {
            loadQuestShape(_loc3_.nameBarData);
         }
      }
      
      private function onAvatarGetReceived(param1:String, param2:Boolean, param3:int, param4:int) : void
      {
         var _loc7_:AvatarInfo = null;
         var _loc5_:int = 0;
         var _loc6_:Avatar = null;
         if(param2)
         {
            _loc7_ = gMainFrame.userInfo.getAvatarInfoByUserName(param1);
            if(!_loc7_)
            {
               throw new Error("onAvatarSFSGetReceived and avInfo is null");
            }
            _loc5_ = _loc7_.perUserAvId;
            _loc6_ = AvatarManager.getAvatarByUserName(param1);
            if(_loc6_ == null)
            {
               _loc6_ = AvatarUtility.generateNew(_loc5_,null,param1,-1,0);
            }
            setupAvatar(_loc6_,_loc7_.currPet);
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
         Utility.createXpShape(_ai.questLevel,true,_window.xpShape[_loc2_].mouse.up.icon,null,param1);
      }
   }
}

