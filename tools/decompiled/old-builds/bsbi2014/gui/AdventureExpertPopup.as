package gui
{
   import avatar.AvatarInfo;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import quest.QuestXtCommManager;
   
   public class AdventureExpertPopup
   {
      
      private static var _difficultyPopup:MovieClip;
      
      private static var _mediaHelper:MediaHelper;
      
      private static var _guiLayer:DisplayLayer;
      
      private static var _autoStart:Boolean;
      
      private static var _scriptDef:Object;
      
      private static const ADVENTURE_EXPERT_ID:int = 2288;
      
      public function AdventureExpertPopup()
      {
         super();
      }
      
      public static function init(initScriptDefId:int, autoStart:Boolean = false) : void
      {
         _scriptDef = QuestXtCommManager.getScriptDef(initScriptDefId);
         _guiLayer = GuiManager.guiLayer;
         _autoStart = autoStart;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(ADVENTURE_EXPERT_ID,onExpertLoaded);
      }
      
      public static function destroy() : void
      {
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         if(Boolean(_difficultyPopup))
         {
            DarkenManager.unDarken(_difficultyPopup);
            _guiLayer.removeChild(_difficultyPopup);
            _difficultyPopup = null;
         }
      }
      
      private static function onExpertLoaded(img:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _difficultyPopup = MovieClip(img.getChildAt(0));
         _difficultyPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _difficultyPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         _difficultyPopup.nonMemLock.visible = !gMainFrame.userInfo.isMember;
         _difficultyPopup.dModeCont.visible = false;
         _difficultyPopup.scrim.visible = false;
         addEventListeners();
         _guiLayer.addChild(_difficultyPopup);
         DarkenManager.darken(_difficultyPopup);
      }
      
      private static function onPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
      }
      
      private static function onCloseBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         destroy();
      }
      
      private static function onDifficulty(evt:MouseEvent) : void
      {
         var ai:AvatarInfo = null;
         evt.stopPropagation();
         var difficulty:int = 0;
         if(evt.currentTarget.name == _difficultyPopup.dModeCont.hardBtn.name)
         {
            ai = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
            if(Boolean(ai) && ai.questLevel < _scriptDef.levelMin + 1)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_scriptDef.levelMin + 1));
               return;
            }
            difficulty = 1;
         }
         if(_difficultyPopup.joinName == _difficultyPopup.joinBtn.name)
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(_scriptDef.defId,difficulty,_autoStart);
            destroy();
            DarkenManager.showLoadingSpiral(true);
            return;
         }
         if(!gMainFrame.userInfo.isMember)
         {
            UpsellManager.displayPopup(UpsellManager.DIAMONDS,"customAdventure/");
            destroy();
            return;
         }
         QuestXtCommManager.sendQuestCreatePrivate(_scriptDef.defId,difficulty,false);
         destroy();
         DarkenManager.showLoadingSpiral(true);
      }
      
      private static function onJoinTypeBtn(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         var ai:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(gMainFrame.userInfo.myUserName,gMainFrame.userInfo.myPerUserAvId);
         if(Boolean(ai) && ai.questLevel < _scriptDef.levelMin)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_scriptDef.levelMin));
            return;
         }
         if(!gMainFrame.userInfo.isMember && evt.currentTarget.name == _difficultyPopup.hostBtn.name)
         {
            UpsellManager.displayPopup(UpsellManager.DIAMONDS,"customAdventure/");
         }
         else if(_scriptDef.difficulty != 0)
         {
            _difficultyPopup.dModeCont.visible = true;
            _difficultyPopup.scrim.visible = true;
            _difficultyPopup.joinName = evt.currentTarget.name;
         }
         else
         {
            if(evt.currentTarget.name == _difficultyPopup.joinBtn.name)
            {
               QuestXtCommManager.sendQuestCreateJoinPublic(_scriptDef.defId,0,_autoStart);
            }
            else
            {
               QuestXtCommManager.sendQuestCreatePrivate(_scriptDef.defId,0,false);
            }
            destroy();
         }
      }
      
      private static function onCloseModeCont(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         _difficultyPopup.dModeCont.visible = false;
         _difficultyPopup.scrim.visible = false;
      }
      
      private static function addEventListeners() : void
      {
         if(Boolean(_difficultyPopup))
         {
            _difficultyPopup.addEventListener(MouseEvent.MOUSE_DOWN,onPopup,false,0,true);
            _difficultyPopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn,false,0,true);
            _difficultyPopup.dModeCont.normalBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDifficulty,false,0,true);
            _difficultyPopup.dModeCont.hardBtn.addEventListener(MouseEvent.MOUSE_DOWN,onDifficulty,false,0,true);
            _difficultyPopup.dModeCont.bx.addEventListener(MouseEvent.MOUSE_DOWN,onCloseModeCont,false,0,true);
            _difficultyPopup.joinBtn.addEventListener(MouseEvent.MOUSE_DOWN,onJoinTypeBtn,false,0,true);
            _difficultyPopup.hostBtn.addEventListener(MouseEvent.MOUSE_DOWN,onJoinTypeBtn,false,0,true);
         }
      }
      
      private static function removeEventListeners() : void
      {
         if(Boolean(_difficultyPopup))
         {
            _difficultyPopup.removeEventListener(MouseEvent.MOUSE_DOWN,onPopup);
            _difficultyPopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onCloseBtn);
            _difficultyPopup.dModeCont.normalBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDifficulty);
            _difficultyPopup.dModeCont.hardBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onDifficulty);
            _difficultyPopup.dModeCont.bx.removeEventListener(MouseEvent.MOUSE_DOWN,onCloseModeCont);
            _difficultyPopup.joinBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoinTypeBtn);
            _difficultyPopup.hostBtn.removeEventListener(MouseEvent.MOUSE_DOWN,onJoinTypeBtn);
         }
      }
   }
}

