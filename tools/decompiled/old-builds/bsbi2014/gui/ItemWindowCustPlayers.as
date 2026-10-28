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
      
      public function ItemWindowCustPlayers(windowLoaded:Function, currItem:Object, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._onBxBtn = customParams.onBxBtn;
         this._scriptDefId = customParams.scriptDefId;
         super(2301,windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         _window.bx.visible = false;
         super.setChildrenAndInitialConditions();
      }
      
      override public function loadCurrItem(currYLocation:int = 0, currXLocation:int = 0) : void
      {
         var joinedAvatarInfo:AvatarInfo = null;
         while(_window.char.charLayer.numChildren > 0)
         {
            _window.char.charLayer.removeChildAt(0);
         }
         _window.char.gotoAndPlay("waiting");
         LocalizationManager.translateId(_window.nameBar.firstName_txt,11101);
         _window.nameBar.lastName_txt.text = "";
         _window.char.gotoAndPlay("up");
         var joinedAvatarRef:Avatar = AvatarManager.getAvatarBySfsUserId(int(_currItem));
         if(Boolean(joinedAvatarRef))
         {
            joinedAvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(joinedAvatarRef.userName);
         }
         if(joinedAvatarRef == null || joinedAvatarInfo == null)
         {
            AvatarXtCommManager.requestAvatarGetBySfsId(int(_currItem),this.onAvatarGetReceived);
         }
         else
         {
            this.setupAvatar(joinedAvatarRef,joinedAvatarInfo.currPet);
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
      
      public function showXBtn(show:Boolean) : void
      {
         _window.bx.visible = show;
      }
      
      public function get userName() : String
      {
         return this._currUserName;
      }
      
      public function get char() : MovieClip
      {
         return _window.char;
      }
      
      private function setupAvatar(avt:Avatar, currPet:Object) : void
      {
         var bigPet:GuiPet = null;
         var avtView:AvatarView = null;
         var offset:Point = null;
         var avName:String = null;
         var space:int = 0;
         var firstName:String = null;
         var lastName:String = null;
         var scriptDef:Object = QuestXtCommManager.getScriptDef(this._scriptDefId);
         if(Boolean(scriptDef.playAsPet))
         {
            bigPet = new GuiPet(0,currPet.lBits,currPet.uBits,currPet.eBits,currPet.type,currPet.name,this.onBigPetLoaded);
            _window.char.charLayer.addChild(bigPet);
            _window.nameBar.firstName_txt.text = bigPet.petName;
         }
         else
         {
            avtView = new AvatarView();
            avtView.init(avt);
            avtView.playAnim(LayerAnim.AN_HUD_AVT);
            avtView.scaleX = 0.7;
            avtView.scaleY = 0.7;
            offset = AvatarUtility.getAvatarMinigameLobbyOffset(avtView.avTypeId);
            avtView.x = offset.x;
            avtView.y = offset.y + 5;
            _window.char.charLayer.addChild(avtView);
            avName = avt.avName;
            space = avName.indexOf(" ");
            if(space != -1)
            {
               firstName = avName.substr(0,space);
               lastName = avName.substr(space + 1,avName.length);
            }
            else
            {
               firstName = avName;
            }
            _window.nameBar.firstName_txt.text = firstName;
            if(Boolean(lastName))
            {
               _window.nameBar.lastName_txt.text = lastName;
            }
         }
         this._currUserName = avt.userName;
         this._ai = gMainFrame.userInfo.getAvatarInfoByUserNameThenPerUserAvId(avt.userName,avt.perUserAvId);
         var ui:UserInfo = gMainFrame.userInfo.getUserInfoByUserName(avt.userName);
         if(Boolean(this._ai) && Boolean(ui) && this._ai.questLevel > 0)
         {
            this.loadQuestShape(ui.nameBarData);
         }
      }
      
      private function onAvatarGetReceived(userName:String, status:Boolean, onlineStatus:int, sfsUserId:int) : void
      {
         var avInfo:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUserName(userName);
         if(!avInfo)
         {
            throw new Error("onAvatarSFSGetReceived and avInfo is null");
         }
         var perUserAvId:int = avInfo.perUserAvId;
         var avt:Avatar = AvatarManager.getAvatarByUserName(userName);
         if(avt == null)
         {
            avt = AvatarUtility.generateNew(perUserAvId,null,userName,-1,0);
         }
         this.setupAvatar(avt,avInfo.currPet);
      }
      
      private function onBigPetLoaded(content:MovieClip, guiPet:GuiPet) : void
      {
         guiPet.scaleX = guiPet.scaleY = 1.5;
         guiPet.y += 30;
      }
      
      private function loadQuestShape(nameBarData:int) : void
      {
         var currFrameName:String = _window.xpShape.currentLabels[Utility.getColorId(nameBarData) - 1].name;
         _window.xpShape.visible = true;
         if(currFrameName == "black")
         {
            _window.xpShape.gotoAndStop(2);
            _window.xpShape.gotoAndStop(currFrameName);
         }
         if(_window.xpShape.currentFrameLabel != currFrameName)
         {
            _window.xpShape.gotoAndStop(currFrameName);
         }
         Utility.createXpShape(this._ai.questLevel,true,_window.xpShape[currFrameName].mouse.up.icon,null,nameBarData);
      }
   }
}

