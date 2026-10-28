package gui
{
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.UserCommXtCommManager;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   import pet.PetManager;
   import quest.QuestManager;
   import quest.QuestXtCommManager;
   import room.RoomXtCommManager;
   
   public class ItemWindowAdventure extends ItemWindowBase
   {
      
      private var _scriptDef:Object;
      
      public function ItemWindowAdventure(windowLoaded:Function, currItem:MovieClip, iconLayerName:String, index:int, mouseDown:Function = null, mouseOver:Function = null, mouseOut:Function = null, memberOnlyDown:Function = null, customParams:Object = null)
      {
         this._scriptDef = QuestXtCommManager.getScriptDef(customParams.scriptIds[index]);
         super(this._scriptDef.bannerMediaRefId,windowLoaded,currItem,iconLayerName,index,mouseDown,mouseOver,mouseOut,memberOnlyDown);
      }
      
      override protected function setChildrenAndInitialConditions() : void
      {
         var ai:AvatarInfo = null;
         _window.txt.mouseEnabled = false;
         _window.txt.mouseChildren = false;
         LocalizationManager.translateId(_window.txt.titleTxt,this._scriptDef.titleStrId);
         if(Boolean(_window["memLock"]))
         {
            _window["memLock"].visible = this._scriptDef.membersOnly;
            _window["memLock"].mouseEnabled = false;
            _window["memLock"].mouseChildren = false;
            ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(Boolean(ai))
            {
               if(ai.questLevel < this._scriptDef.levelMin)
               {
                  _window.tag.visible = false;
               }
            }
         }
         if(this._scriptDef.defId == 21)
         {
            _window.tag.visible = false;
         }
      }
      
      override protected function addEventListeners() : void
      {
         if(Boolean(_window))
         {
            if(_mouseDown != null && !(_memberOnlyDown != null && !gMainFrame.userInfo.isMember))
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_mouseDown,false,0,true);
            }
            if(_mouseOver != null)
            {
               addEventListener(MouseEvent.ROLL_OVER,_mouseOver,false,0,true);
            }
            if(_mouseOut != null)
            {
               addEventListener(MouseEvent.ROLL_OUT,_mouseOut,false,0,true);
            }
            if(_memberOnlyDown != null && !gMainFrame.userInfo.isMember)
            {
               addEventListener(MouseEvent.MOUSE_DOWN,_memberOnlyDown,false,0,true);
            }
         }
      }
      
      public function performContinueChecks() : Object
      {
         var ai:AvatarInfo = null;
         var myPet:Object = null;
         if(QuestManager.isInPrivateAdventureState)
         {
            QuestManager.showLeaveQuestLobbyPopup(this.performContinueChecks);
            return null;
         }
         if(AvatarManager.isMyUserInCustomPVPState())
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,0);
         }
         if(!RoomXtCommManager.isSwitching)
         {
            if(Boolean(this._scriptDef.membersOnly) && !gMainFrame.userInfo.isMember)
            {
               UpsellManager.displayPopup(UpsellManager.ADVENTURES,"adventure/" + this._scriptDef.defId);
               return null;
            }
            ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(Boolean(ai))
            {
               if(Boolean(this._scriptDef.playAsPet))
               {
                  myPet = PetManager.myActivePet;
                  if(!Boolean(myPet))
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19656));
                     return null;
                  }
                  if(!PetManager.canPetGoInEnviroType(myPet.type,this._scriptDef.avatarType))
                  {
                     switch(this._scriptDef.avatarType)
                     {
                        case 1:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19648));
                           break;
                        case 2:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19649));
                           break;
                        case 4:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19650));
                           break;
                        case 5:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(19655));
                     }
                     return null;
                  }
               }
               else
               {
                  if(Boolean(AvatarManager.playerAvatar) && !AvatarManager.isValidEnviro(this._scriptDef.avatarType))
                  {
                     switch(this._scriptDef.avatarType)
                     {
                        case 1:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(15706));
                           break;
                        case 2:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18476));
                           break;
                        case 4:
                           new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(18475));
                           break;
                        case 5:
                     }
                     return null;
                  }
                  if(ai.questLevel < this._scriptDef.levelMin)
                  {
                     new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,this._scriptDef.levelMin));
                     return null;
                  }
                  if(this._scriptDef.avatarLimit == 1 && Boolean(_window.tag.visible))
                  {
                     return {
                        "func":QuestXtCommManager.sendQuestCreateJoinPublic,
                        "defId":this._scriptDef.defId
                     };
                  }
               }
               if(Boolean(_window.tag.visible))
               {
                  return {
                     "func":AdventureExpertPopup.init,
                     "defId":this._scriptDef.defId
                  };
               }
               return null;
            }
            return null;
         }
         return null;
      }
   }
}

