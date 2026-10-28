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
      
      public static function init(param1:int, param2:Boolean = false) : void
      {
         _scriptDef = QuestXtCommManager.getScriptDef(param1);
         _guiLayer = GuiManager.guiLayer;
         _autoStart = param2;
         DarkenManager.showLoadingSpiral(true);
         _mediaHelper = new MediaHelper();
         _mediaHelper.init(ADVENTURE_EXPERT_ID,onExpertLoaded);
      }
      
      public static function destroy() : void
      {
         removeEventListeners();
         _mediaHelper.destroy();
         _mediaHelper = null;
         if(_difficultyPopup)
         {
            DarkenManager.unDarken(_difficultyPopup);
            _guiLayer.removeChild(_difficultyPopup);
            _difficultyPopup = null;
         }
      }
      
      private static function onExpertLoaded(param1:MovieClip) : void
      {
         DarkenManager.showLoadingSpiral(false);
         _difficultyPopup = MovieClip(param1.getChildAt(0));
         _difficultyPopup.x = MainFrame.VIEW_WIDTH * 0.5;
         _difficultyPopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         _difficultyPopup.nonMemLock.visible = !gMainFrame.userInfo.isMember;
         _difficultyPopup.dModeCont.visible = false;
         _difficultyPopup.scrim.visible = false;
         addEventListeners();
         _guiLayer.addChild(_difficultyPopup);
         DarkenManager.darken(_difficultyPopup);
      }
      
      private static function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private static function onCloseBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         destroy();
      }
      
      private static function onDifficulty(param1:MouseEvent) : void
      {
         var _loc3_:AvatarInfo = null;
         param1.stopPropagation();
         var _loc2_:int = 0;
         if(param1.currentTarget.name == _difficultyPopup.dModeCont.hardBtn.name)
         {
            _loc3_ = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
            if(Boolean(_loc3_) && _loc3_.questLevel < _scriptDef.levelMin + 1)
            {
               new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14696,_scriptDef.levelMin + 1));
               return;
            }
            _loc2_ = 1;
         }
         if(_difficultyPopup.joinName == _difficultyPopup.joinBtn.name)
         {
            QuestXtCommManager.sendQuestCreateJoinPublic(_scriptDef.defId,_loc2_,_autoStart);
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
         QuestXtCommManager.sendQuestCreatePrivate(_scriptDef.defId,_loc2_,false);
         destroy();
         DarkenManager.showLoadingSpiral(true);
      }
      
      private static function onJoinTypeBtn(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         var _loc2_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByDbAvId(gMainFrame.userInfo.myDbAvId);
         if(Boolean(_loc2_) && _loc2_.questLevel < _scriptDef.levelMin)
         {
            new SBOkPopup(_guiLayer,LocalizationManager.translateIdAndInsertOnly(14697,_scriptDef.levelMin));
            return;
         }
         if(!gMainFrame.userInfo.isMember && param1.currentTarget.name == _difficultyPopup.hostBtn.name)
         {
            UpsellManager.displayPopup(UpsellManager.DIAMONDS,"customAdventure/");
         }
         else if(_scriptDef.difficulty != 0)
         {
            _difficultyPopup.dModeCont.visible = true;
            _difficultyPopup.scrim.visible = true;
            _difficultyPopup.joinName = param1.currentTarget.name;
         }
         else
         {
            if(param1.currentTarget.name == _difficultyPopup.joinBtn.name)
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
      
      private static function onCloseModeCont(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         _difficultyPopup.dModeCont.visible = false;
         _difficultyPopup.scrim.visible = false;
      }
      
      private static function addEventListeners() : void
      {
         if(_difficultyPopup)
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
         if(_difficultyPopup)
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

