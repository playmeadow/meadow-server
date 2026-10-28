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
      
      public function GameBase()
      {
         super();
         MinigameManager._pvpPromptReplay = false;
         this._miniGameDefID = MinigameManager.minigameInfoCache.currMinigameId;
         this._trackerVal = new Array();
         this._trackerNum = new Array();
         this._trackerMain = new Array();
         if(this._miniGameDefID != -1)
         {
            this._inRoomGame = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).isInRoomGame;
         }
         else
         {
            this._inRoomGame = false;
         }
         this._gameIdleTimer = 0;
         this._totalGemsEarned = 0;
         this._guiButtons = [];
         this._gameStartTime = getTimer();
      }
      
      protected function loadScene(param1:String) : void
      {
         this._sceneName = param1;
         this._gemMultiplierMediaHelper = new MediaHelper();
         this._gemMultiplierMediaHelper.init(1067,this.gemMultiplierMediaHandler);
      }
      
      private function gemMultiplierMediaHandler(param1:MovieClip) : void
      {
         this._gemMultiplierMC = param1;
         this._gameLoader = new LoaderCacheEntry_URL(MainFrame.ROOMS_FOLDER + this._sceneName.toLowerCase());
         this._gameLoader.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.loadComplete);
         this._gameLoader.load();
      }
      
      private function loadComplete(param1:LoaderEvent) : void
      {
         var _loc2_:Object = null;
         _loc2_ = this._gameLoader.data;
         this._gameLoader.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.loadComplete);
         this._scene = new SceneLoader();
         this._scene.setScene(_loc2_,true);
         this._scene.addEventListener(Event.COMPLETE,this.sceneLoaded,false,0,true);
      }
      
      protected function releaseBase() : void
      {
         var _loc2_:GuiButton = null;
         var _loc1_:Number = (getTimer() - this._gameStartTime) / 1000;
         if(this._kickPopup != null)
         {
            this._kickPopup.destroy();
            this._kickPopup = null;
         }
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.resetKeyIdleTimer,false);
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.resetMouseDownIdleTimer,false);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.resetMouseMoveIdleTimer,false);
         stage.removeEventListener(Event.ENTER_FRAME,this.gameBaseHeartbeat);
         for each(_loc2_ in this._guiButtons)
         {
            _loc2_.release();
         }
         this._guiButtons = [];
         if(this._scene)
         {
            this._scene.release();
         }
         this._gameLoader = null;
      }
      
      protected function sceneLoaded(param1:Event) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Object = null;
         this._scene.removeEventListener(Event.COMPLETE,this.sceneLoaded);
         param1 = new Event(Event.COMPLETE);
         dispatchEvent(param1);
         var _loc3_:Array = this._scene.getActorList("ActorLayer");
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            _loc4_ = _loc3_[_loc2_];
            if(_loc4_.s.content is MovieClip)
            {
               LocalizationManager.findAllTextfields(_loc4_.s.content);
            }
            _loc2_++;
         }
         this._lastIdleTimer = getTimer();
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.resetKeyIdleTimer,false);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.resetMouseDownIdleTimer,false);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.resetMouseMoveIdleTimer,false);
         stage.addEventListener(Event.ENTER_FRAME,this.gameBaseHeartbeat);
      }
      
      private function gameBaseHeartbeat(param1:Event) : void
      {
         var _loc2_:Number = (getTimer() - this._lastIdleTimer) / 1000;
         this._lastIdleTimer = getTimer();
         if(this._inRoomGame == false)
         {
            this._gameIdleTimer += _loc2_;
            if(this._gameIdleTimer > 3 * 60)
            {
               if(this._gameIdleTimer > 4 * 60)
               {
                  if(this.hasOwnProperty("end"))
                  {
                     this["end"](null);
                  }
               }
               else if(this._kickPopup == null)
               {
                  this._kickPopup = new SBOkPopup(GuiManager.guiLayer,LocalizationManager.translateIdOnly(14681),false,this.onKickWarningPopup);
                  AJAudio.playIdleWarningSound();
               }
            }
         }
      }
      
      private function onKickWarningPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         SBOkPopup.destroyInParentChain(param1.target.parent);
         this._kickPopup = null;
         this._gameIdleTimer = 0;
      }
      
      private function resetKeyIdleTimer(param1:KeyboardEvent) : void
      {
         if(this._kickPopup != null)
         {
            this._kickPopup.destroy();
            this._kickPopup = null;
         }
         this._gameIdleTimer = 0;
      }
      
      private function resetMouseMoveIdleTimer(param1:MouseEvent) : void
      {
         if(this._kickPopup == null)
         {
            this._gameIdleTimer = 0;
         }
      }
      
      private function resetMouseDownIdleTimer(param1:Event) : void
      {
         if(this._kickPopup != null)
         {
            this._kickPopup.destroy();
            this._kickPopup = null;
         }
         this._gameIdleTimer = 0;
      }
      
      protected function showGemMultiplierDlg(param1:Function) : MovieClip
      {
         var _loc2_:Number = NaN;
         var _loc3_:MovieClip = null;
         if(this._totalGemsEarned > 0)
         {
            _loc2_ = 1;
            if(this._miniGameDefID != -1)
            {
               _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).gemMultiplier;
            }
            if(_loc2_ > 1)
            {
               if(this._activeDlg != null)
               {
                  this.hideDlg();
               }
               if(this._activeDlg == null && Boolean(this._gemMultiplierMC))
               {
                  if(this._closeBtn)
                  {
                     this._closeBtn.visible = false;
                  }
                  this._pauseGame = true;
                  _loc3_ = this._gemMultiplierMC.getChildAt(0) as MovieClip;
                  this._guiLayer.addChild(_loc3_);
                  this._activeDlg = new GuiDialog(_loc3_,[{
                     "name":"x_btn",
                     "f":param1
                  }]);
                  this._activeDlgMC = _loc3_;
                  _loc3_.x = 450;
                  _loc3_.y = 275;
                  _loc3_.Gems_Earned.text = this._totalGemsEarned / _loc2_;
                  _loc3_.Gem_Bonus.text = _loc2_ + "x";
                  _loc3_.Gems_Total.text = this._totalGemsEarned;
                  return _loc3_;
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
            this._guiLayer.addChild(_loc4_);
         }
         else
         {
            if(this._activeDlg != null)
            {
               this.hideDlg();
            }
            if(this._activeDlg == null)
            {
               if(this._closeBtn)
               {
                  this._closeBtn.visible = false;
               }
               this._pauseGame = true;
               _loc4_ = GETDEFINITIONBYNAME(param1);
               this._guiLayer.addChild(_loc4_);
               this._activeDlg = new GuiDialog(_loc4_,param2);
               this._activeDlgMC = _loc4_;
            }
         }
         return _loc4_;
      }
      
      protected function hideDlg() : void
      {
         if(this._activeDlg)
         {
            this._activeDlg.release();
            this._guiLayer.removeChild(this._activeDlgMC);
            this._activeDlg = null;
            this._activeDlgMC = null;
            this._pauseGame = false;
            if(this._closeBtn)
            {
               this._closeBtn.visible = true;
            }
         }
      }
      
      protected function addBtn(param1:String, param2:int, param3:int, param4:Function) : MovieClip
      {
         var _loc5_:MovieClip = GETDEFINITIONBYNAME(param1);
         _loc5_.x = param2;
         _loc5_.y = param3;
         this._guiLayer.addChild(_loc5_);
         var _loc6_:GuiButton = new GuiButton(_loc5_,param4);
         this._guiButtons.push(_loc6_);
         return _loc5_;
      }
      
      private function mainTracker() : void
      {
         var _loc1_:int = 0;
         if(this._miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
         }
         this._trackerNum.push(this._trackerMain[this._trackerMain.length - 1] - _loc1_ * 7 - 78922);
         this.numTracker();
      }
      
      protected function loadSound(param1:Class) : Sound
      {
         var _loc2_:Sound = new param1() as Sound;
         var _loc3_:SoundTransform = new SoundTransform(0,0);
         _loc2_.play(0,0,_loc3_);
         return _loc2_;
      }
      
      public function valueTrackerCommit() : void
      {
         var _loc1_:int = 0;
         if(this._miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
            if(_loc1_ != 0)
            {
               MinigameManager.sendScore(this._trackerMain[this._trackerMain.length - 1],this._trackerVal[this._trackerVal.length - 1],this._trackerNum[this._trackerNum.length - 1],_loc1_,this._miniGameDefID);
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
         if(this._miniGameDefID != -1)
         {
            _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
         }
         this._trackerVal.push(this._trackerNum[this._trackerNum.length - 1] - _loc1_ * 9 + 15645);
      }
      
      protected function addGemsToBalance(param1:int) : void
      {
         var _loc2_:Number = 1;
         if(this._miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).gemMultiplier;
         }
         if(_loc2_ > 1)
         {
            param1 *= _loc2_;
         }
         this._totalGemsEarned += param1;
         MinigameManager.awardGems(param1,this._miniGameDefID);
      }
      
      public function valueTrackerCurrent() : Number
      {
         var _loc1_:int = 0;
         if(this._trackerMain.length > 0)
         {
            _loc1_ = 0;
            if(this._miniGameDefID != -1)
            {
               _loc1_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
            }
            return 9999999 - (this._trackerMain[this._trackerMain.length - 1] - _loc1_ * 5 + MinigameManager.getScoreSN());
         }
         return 0;
      }
      
      public function getScene() : SceneLoader
      {
         return this._scene;
      }
      
      public function getPaused() : Boolean
      {
         return this._pauseGame;
      }
      
      public function getGuiLayer() : Sprite
      {
         return this._guiLayer;
      }
      
      public function valueTracker(param1:Number) : void
      {
         var _loc2_:int = 0;
         if(this._miniGameDefID != -1)
         {
            _loc2_ = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
         }
         this._trackerMain.push(9999999 - (param1 - _loc2_ * 5 + MinigameManager.getScoreSN()));
         if(this._trackerMain.length >= 3)
         {
            this._trackerMain.shift();
         }
         this.mainTracker();
      }
   }
}

