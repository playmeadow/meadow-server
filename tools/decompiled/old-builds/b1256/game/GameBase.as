package game
{
   import com.sbi.loader.LoaderCacheEntry_URL;
   import com.sbi.loader.LoaderEvent;
   import com.sbi.loader.SceneLoader;
   import com.sbi.popup.SBOkPopup;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import flash.utils.getTimer;
   import gui.GuiManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class GameBase extends Sprite
   {
      
      private var _activeDlgMC:MovieClip;
      
      private var _activeDlg:GuiDialog;
      
      private var _guiButtons:Array;
      
      private var _gemMultiplierMC:MovieClip;
      
      private var _gemMultiplierMediaHelper:MediaHelper;
      
      private var _gameLoader:LoaderCacheEntry_URL;
      
      private var _sceneName:String;
      
      protected var _pauseGame:Boolean;
      
      private var _trackerVal:Array;
      
      protected var _scene:SceneLoader;
      
      protected var _closeBtn:MovieClip;
      
      protected var _guiLayer:Sprite;
      
      private var _gameStartTime:int;
      
      public var _totalGemsEarned:int;
      
      protected var _gameIdleTimer:Number;
      
      private var _trackerMain:Array;
      
      private var _lastIdleTimer:Number;
      
      private var _kickPopup:SBOkPopup;
      
      protected var _miniGameDefID:int;
      
      private var _inRoomGame:Boolean;
      
      private var _trackerNum:Array;
      
      private var _onCloseCallback:Function;
      
      public function GameBase()
      {
         super();
         MinigameManager._pvpPromptReplay = false;
         _miniGameDefID = MinigameManager.minigameInfoCache.currMinigameId;
         _trackerVal = [];
         _trackerNum = [];
         _trackerMain = [];
         if(_miniGameDefID != -1)
         {
            _inRoomGame = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).isInRoomGame;
         }
         else
         {
            _inRoomGame = false;
         }
         _gameIdleTimer = 0;
         _totalGemsEarned = 0;
         _guiButtons = [];
         _gameStartTime = getTimer();
      }
      
      public function get activeDlgMC() : MovieClip
      {
         return _activeDlgMC;
      }
      
      protected function loadScene(param1:String) : void
      {
         _sceneName = param1;
         _gemMultiplierMediaHelper = new MediaHelper();
         _gemMultiplierMediaHelper.init(1067,gemMultiplierMediaHandler);
      }
      
      private function gemMultiplierMediaHandler(param1:MovieClip) : void
      {
         _gemMultiplierMC = param1;
         _gameLoader = new LoaderCacheEntry_URL("roomDefs/" + _sceneName.toLowerCase());
         _gameLoader.addEventListener("OnLoadComplete",loadComplete);
         _gameLoader.load();
      }
      
      private function loadComplete(param1:LoaderEvent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = _gameLoader.data;
         _gameLoader.removeEventListener("OnLoadComplete",loadComplete);
         _scene = new SceneLoader();
         _scene.setScene(_loc2_,true);
         _scene.addEventListener("complete",sceneLoaded,false,0,true);
      }
      
      protected function releaseBase() : void
      {
         var _loc2_:Number = (getTimer() - _gameStartTime) / 1000;
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         if(stage)
         {
            stage.removeEventListener("keyDown",gemMultiplierCloseKeyDown);
            stage.removeEventListener("keyDown",resetKeyIdleTimer,false);
            stage.removeEventListener("mouseDown",resetMouseDownIdleTimer,false);
            stage.removeEventListener("mouseMove",resetMouseMoveIdleTimer,false);
            stage.removeEventListener("enterFrame",gameBaseHeartbeat);
         }
         for each(var _loc1_:GuiButton in _guiButtons)
         {
            _loc1_.release();
         }
         _guiButtons = [];
         if(_scene)
         {
            _scene.release();
         }
         _gameLoader = null;
      }
      
      protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         _scene.removeEventListener("complete",sceneLoaded);
         param1 = new Event("complete");
         dispatchEvent(param1);
         var _loc2_:Array = _scene.getActorList("ActorLayer");
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc3_ = _loc2_[_loc4_];
            if(_loc3_.s.content is MovieClip)
            {
               LocalizationManager.findAllTextfields(_loc3_.s.content);
            }
            _loc4_++;
         }
         _lastIdleTimer = getTimer();
         stage.addEventListener("keyDown",resetKeyIdleTimer,false);
         stage.addEventListener("mouseDown",resetMouseDownIdleTimer,false);
         stage.addEventListener("mouseMove",resetMouseMoveIdleTimer,false);
         stage.addEventListener("enterFrame",gameBaseHeartbeat);
      }
      
      private function gameBaseHeartbeat(param1:Event) : void
      {
         var _loc2_:Number = (getTimer() - _lastIdleTimer) / 1000;
         _lastIdleTimer = getTimer();
         if(_inRoomGame == false)
         {
            _gameIdleTimer += _loc2_;
            if(_gameIdleTimer > 180)
            {
               if(_gameIdleTimer > 240)
               {
                  if(this.hasOwnProperty("end"))
                  {
                     this["end"](null);
                  }
               }
               else if(_kickPopup == null)
               {
                  _kickPopup = new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14681),false,onKickWarningPopup);
                  AJAudio.playIdleWarningSound();
               }
            }
         }
      }
      
      private function onKickWarningPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         _kickPopup = null;
         _gameIdleTimer = 0;
      }
      
      private function resetKeyIdleTimer(param1:KeyboardEvent) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private function resetMouseMoveIdleTimer(param1:MouseEvent) : void
      {
         if(_kickPopup == null)
         {
            _gameIdleTimer = 0;
         }
      }
      
      private function resetMouseDownIdleTimer(param1:Event) : void
      {
         if(_kickPopup != null)
         {
            _kickPopup.destroy();
            _kickPopup = null;
         }
         _gameIdleTimer = 0;
      }
      
      private function gemMultiplierClose() : void
      {
         stage.removeEventListener("keyDown",gemMultiplierCloseKeyDown);
         if(_onCloseCallback != null)
         {
            _onCloseCallback();
            _onCloseCallback = null;
         }
      }
      
      private function gemMultiplierCloseKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
            case 8:
            case 46:
            case 27:
               gemMultiplierClose();
         }
      }
      
      protected function showGemMultiplierDlg(param1:Function) : MovieClip
      {
         var _loc3_:Number = NaN;
         var _loc2_:MovieClip = null;
         if(_totalGemsEarned > 0)
         {
            _loc3_ = 1;
            if(_miniGameDefID != -1)
            {
               _loc3_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).gemMultiplier;
            }
            if(_loc3_ > 1)
            {
               if(_activeDlg != null)
               {
                  hideDlg();
               }
               if(_activeDlg == null && _gemMultiplierMC)
               {
                  if(_closeBtn)
                  {
                     _closeBtn.visible = false;
                  }
                  _pauseGame = true;
                  _loc2_ = _gemMultiplierMC.getChildAt(0) as MovieClip;
                  _guiLayer.addChild(_loc2_);
                  _onCloseCallback = param1;
                  _activeDlg = new GuiDialog(_loc2_,[{
                     "name":"x_btn",
                     "f":param1
                  }]);
                  stage.addEventListener("keyDown",gemMultiplierCloseKeyDown);
                  _activeDlgMC = _loc2_;
                  _loc2_.x = 450;
                  _loc2_.y = 275;
                  LocalizationManager.translateIdAndInsert(_loc2_.Gems_Earned,10062,_totalGemsEarned / _loc3_);
                  LocalizationManager.translateIdAndInsert(_loc2_.Gem_Bonus,10063,_loc3_);
                  LocalizationManager.translateIdAndInsert(_loc2_.Gems_Total,10064,_totalGemsEarned);
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      protected function showDlg(param1:String, param2:Array, param3:Boolean = true) : MovieClip
      {
         var _loc4_:MovieClip = null;
         if(!param3)
         {
            _loc4_ = GETDEFINITIONBYNAME(param1);
            _guiLayer.addChild(_loc4_);
         }
         else
         {
            if(_activeDlg != null)
            {
               hideDlg();
            }
            if(_activeDlg == null)
            {
               if(_closeBtn)
               {
                  _closeBtn.visible = false;
               }
               _pauseGame = true;
               _loc4_ = GETDEFINITIONBYNAME(param1);
               _guiLayer.addChild(_loc4_);
               _activeDlg = new GuiDialog(_loc4_,param2);
               _activeDlgMC = _loc4_;
            }
         }
         return _loc4_;
      }
      
      protected function hideDlg() : void
      {
         if(_activeDlg)
         {
            _activeDlg.release();
            _guiLayer.removeChild(_activeDlgMC);
            _activeDlg = null;
            _activeDlgMC = null;
            _pauseGame = false;
            if(_closeBtn)
            {
               _closeBtn.visible = true;
            }
         }
      }
      
      protected function addBtn(param1:String, param2:int, param3:int, param4:Function) : MovieClip
      {
         var _loc5_:MovieClip = GETDEFINITIONBYNAME(param1);
         _loc5_.x = param2;
         _loc5_.y = param3;
         _guiLayer.addChild(_loc5_);
         var _loc6_:GuiButton = new GuiButton(_loc5_,param4);
         _guiButtons.push(_loc6_);
         return _loc5_;
      }
      
      private function mainTracker() : void
      {
         var _loc1_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         _trackerNum.push(_trackerMain[_trackerMain.length - 1] - _loc1_ * 7 - 78922);
         numTracker();
      }
      
      protected function loadSound(param1:Class) : Sound
      {
         var _loc3_:Sound = new param1() as Sound;
         var _loc2_:SoundTransform = new SoundTransform(0,0);
         _loc3_.play(0,0,_loc2_);
         return _loc3_;
      }
      
      public function valueTrackerCommit() : void
      {
         var _loc1_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
            if(_loc1_ != 0)
            {
               MinigameManager.sendScore(_trackerMain[_trackerMain.length - 1],_trackerVal[_trackerVal.length - 1],_trackerNum[_trackerNum.length - 1],_loc1_,_miniGameDefID);
            }
         }
      }
      
      protected function removeLayer(param1:Sprite) : void
      {
         while(param1.numChildren)
         {
            param1.removeChild(param1.getChildAt(0));
         }
         param1.parent.removeChild(param1);
      }
      
      protected function addToPetMastery(param1:int) : void
      {
         MinigameManager.awardPetMasteryPoints(param1);
      }
      
      private function numTracker() : void
      {
         var _loc1_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         _trackerVal.push(_trackerNum[_trackerNum.length - 1] - _loc1_ * 9 + 15645);
      }
      
      protected function addGemsToBalance(param1:int) : void
      {
         var _loc2_:Number = 1;
         if(_miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).gemMultiplier;
         }
         if(_loc2_ > 1)
         {
            param1 *= _loc2_;
         }
         _totalGemsEarned += param1;
         MinigameManager.awardGems(param1,_miniGameDefID);
      }
      
      public function valueTrackerCurrent() : Number
      {
         var _loc1_:int = 0;
         if(_trackerMain.length > 0)
         {
            _loc1_ = 0;
            if(_miniGameDefID != -1)
            {
               _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
            }
            return 9999999 - (_trackerMain[_trackerMain.length - 1] - _loc1_ * 5 + MinigameManager.getScoreSN());
         }
         return 0;
      }
      
      public function getScene() : SceneLoader
      {
         return _scene;
      }
      
      public function getPaused() : Boolean
      {
         return _pauseGame;
      }
      
      public function getGuiLayer() : Sprite
      {
         return _guiLayer;
      }
      
      public function valueTracker(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(_miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(_miniGameDefID).lbUseVarRef;
         }
         _trackerMain.push(9999999 - (param1 - _loc2_ * 5 + MinigameManager.getScoreSN()));
         if(_trackerMain.length >= 3)
         {
            _trackerMain.shift();
         }
         mainTracker();
      }
   }
}

