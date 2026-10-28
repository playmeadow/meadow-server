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
   import flash.ui.Keyboard;
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
      
      public function get activeDlgMC() : MovieClip
      {
         return this._activeDlgMC;
      }
      
      protected function loadScene(sceneName:String) : void
      {
         this._sceneName = sceneName;
         this._gemMultiplierMediaHelper = new MediaHelper();
         this._gemMultiplierMediaHelper.init(1067,this.gemMultiplierMediaHandler);
      }
      
      private function gemMultiplierMediaHandler(mc:MovieClip) : void
      {
         this._gemMultiplierMC = mc;
         this._gameLoader = new LoaderCacheEntry_URL(MainFrame.ROOMS_FOLDER + this._sceneName.toLowerCase());
         this._gameLoader.addEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.loadComplete);
         this._gameLoader.load();
      }
      
      private function loadComplete(e:LoaderEvent) : void
      {
         var scene:Object = null;
         scene = this._gameLoader.data;
         this._gameLoader.removeEventListener(LoaderEvent.ON_LOAD_COMPLETE,this.loadComplete);
         this._scene = new SceneLoader();
         this._scene.setScene(scene,true);
         this._scene.addEventListener(Event.COMPLETE,this.sceneLoaded,false,0,true);
      }
      
      protected function releaseBase() : void
      {
         var guiBtn:GuiButton = null;
         var gameTime:Number = (getTimer() - this._gameStartTime) / 1000;
         if(this._kickPopup != null)
         {
            this._kickPopup.destroy();
            this._kickPopup = null;
         }
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.gemMultiplierCloseKeyDown);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.resetKeyIdleTimer,false);
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.resetMouseDownIdleTimer,false);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.resetMouseMoveIdleTimer,false);
         stage.removeEventListener(Event.ENTER_FRAME,this.gameBaseHeartbeat);
         for each(guiBtn in this._guiButtons)
         {
            guiBtn.release();
         }
         this._guiButtons = [];
         if(Boolean(this._scene))
         {
            this._scene.release();
         }
         this._gameLoader = null;
      }
      
      protected function sceneLoaded(e:Event) : void
      {
         var i:int = 0;
         var o:Object = null;
         this._scene.removeEventListener(Event.COMPLETE,this.sceneLoaded);
         e = new Event(Event.COMPLETE);
         dispatchEvent(e);
         var a:Array = this._scene.getActorList("ActorLayer");
         for(i = 0; i < a.length; i++)
         {
            o = a[i];
            if(o.s.content is MovieClip)
            {
               LocalizationManager.findAllTextfields(o.s.content);
            }
         }
         this._lastIdleTimer = getTimer();
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.resetKeyIdleTimer,false);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.resetMouseDownIdleTimer,false);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.resetMouseMoveIdleTimer,false);
         stage.addEventListener(Event.ENTER_FRAME,this.gameBaseHeartbeat);
      }
      
      private function gameBaseHeartbeat(e:Event) : void
      {
         var frameTime:Number = (getTimer() - this._lastIdleTimer) / 1000;
         this._lastIdleTimer = getTimer();
         if(this._inRoomGame == false)
         {
            this._gameIdleTimer += frameTime;
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
      
      private function onKickWarningPopup(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         SBOkPopup.destroyInParentChain(evt.target.parent);
         this._kickPopup = null;
         this._gameIdleTimer = 0;
      }
      
      private function resetKeyIdleTimer(event:KeyboardEvent) : void
      {
         if(this._kickPopup != null)
         {
            this._kickPopup.destroy();
            this._kickPopup = null;
         }
         this._gameIdleTimer = 0;
      }
      
      private function resetMouseMoveIdleTimer(event:MouseEvent) : void
      {
         if(this._kickPopup == null)
         {
            this._gameIdleTimer = 0;
         }
      }
      
      private function resetMouseDownIdleTimer(evt:Event) : void
      {
         if(this._kickPopup != null)
         {
            this._kickPopup.destroy();
            this._kickPopup = null;
         }
         this._gameIdleTimer = 0;
      }
      
      private function gemMultiplierClose() : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.gemMultiplierCloseKeyDown);
         if(this._onCloseCallback != null)
         {
            this._onCloseCallback();
            this._onCloseCallback = null;
         }
      }
      
      private function gemMultiplierCloseKeyDown(event:KeyboardEvent) : void
      {
         switch(event.keyCode)
         {
            case Keyboard.ENTER:
            case Keyboard.SPACE:
            case Keyboard.BACKSPACE:
            case Keyboard.DELETE:
            case Keyboard.ESCAPE:
               this.gemMultiplierClose();
         }
      }
      
      protected function showGemMultiplierDlg(onCloseCallback:Function) : MovieClip
      {
         var gemMultiplier:Number = NaN;
         var mc:MovieClip = null;
         if(this._totalGemsEarned > 0)
         {
            gemMultiplier = 1;
            if(this._miniGameDefID != -1)
            {
               gemMultiplier = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).gemMultiplier;
            }
            if(gemMultiplier > 1)
            {
               if(this._activeDlg != null)
               {
                  this.hideDlg();
               }
               if(this._activeDlg == null && Boolean(this._gemMultiplierMC))
               {
                  if(Boolean(this._closeBtn))
                  {
                     this._closeBtn.visible = false;
                  }
                  this._pauseGame = true;
                  mc = this._gemMultiplierMC.getChildAt(0) as MovieClip;
                  this._guiLayer.addChild(mc);
                  this._onCloseCallback = onCloseCallback;
                  this._activeDlg = new GuiDialog(mc,[{
                     "name":"x_btn",
                     "f":onCloseCallback
                  }]);
                  stage.addEventListener(KeyboardEvent.KEY_DOWN,this.gemMultiplierCloseKeyDown);
                  this._activeDlgMC = mc;
                  mc.x = 450;
                  mc.y = 275;
                  LocalizationManager.translateIdAndInsert(mc.Gems_Earned,10062,this._totalGemsEarned / gemMultiplier);
                  LocalizationManager.translateIdAndInsert(mc.Gem_Bonus,10063,gemMultiplier);
                  LocalizationManager.translateIdAndInsert(mc.Gems_Total,10064,this._totalGemsEarned);
                  return mc;
               }
            }
         }
         return null;
      }
      
      protected function showDlg(defName:String, buttons:Array, bModal:Boolean = true) : MovieClip
      {
         var mc:MovieClip = null;
         if(!bModal)
         {
            mc = GETDEFINITIONBYNAME(defName);
            this._guiLayer.addChild(mc);
         }
         else
         {
            if(this._activeDlg != null)
            {
               this.hideDlg();
            }
            if(this._activeDlg == null)
            {
               if(Boolean(this._closeBtn))
               {
                  this._closeBtn.visible = false;
               }
               this._pauseGame = true;
               mc = GETDEFINITIONBYNAME(defName);
               this._guiLayer.addChild(mc);
               this._activeDlg = new GuiDialog(mc,buttons);
               this._activeDlgMC = mc;
            }
         }
         return mc;
      }
      
      protected function hideDlg() : void
      {
         if(Boolean(this._activeDlg))
         {
            this._activeDlg.release();
            this._guiLayer.removeChild(this._activeDlgMC);
            this._activeDlg = null;
            this._activeDlgMC = null;
            this._pauseGame = false;
            if(Boolean(this._closeBtn))
            {
               this._closeBtn.visible = true;
            }
         }
      }
      
      protected function addBtn(defName:String, x:int, y:int, func:Function) : MovieClip
      {
         var mc:MovieClip = GETDEFINITIONBYNAME(defName);
         mc.x = x;
         mc.y = y;
         this._guiLayer.addChild(mc);
         var guiBtn:GuiButton = new GuiButton(mc,func);
         this._guiButtons.push(guiBtn);
         return mc;
      }
      
      private function mainTracker() : void
      {
         var lbV:int = 0;
         if(this._miniGameDefID != -1)
         {
            lbV = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
         }
         this._trackerNum.push(this._trackerMain[this._trackerMain.length - 1] - lbV * 7 - 78922);
         this.numTracker();
      }
      
      protected function loadSound(sndClass:Class) : Sound
      {
         var snd:Sound = new sndClass() as Sound;
         var st:SoundTransform = new SoundTransform(0,0);
         snd.play(0,0,st);
         return snd;
      }
      
      public function valueTrackerCommit() : void
      {
         var lbV:int = 0;
         if(this._miniGameDefID != -1)
         {
            lbV = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
            if(lbV != 0)
            {
               MinigameManager.sendScore(this._trackerMain[this._trackerMain.length - 1],this._trackerVal[this._trackerVal.length - 1],this._trackerNum[this._trackerNum.length - 1],lbV,this._miniGameDefID);
            }
         }
      }
      
      protected function removeLayer(o:Sprite) : void
      {
         while(Boolean(o.numChildren))
         {
            o.removeChild(o.getChildAt(0));
         }
         o.parent.removeChild(o);
      }
      
      protected function addToPetMastery(amount:int) : void
      {
         MinigameManager.awardPetMasteryPoints(amount);
      }
      
      private function numTracker() : void
      {
         var lbV:int = 0;
         if(this._miniGameDefID != -1)
         {
            lbV = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
         }
         this._trackerVal.push(this._trackerNum[this._trackerNum.length - 1] - lbV * 9 + 15645);
      }
      
      protected function addGemsToBalance(amount:int) : void
      {
         var gemMultiplier:Number = 1;
         if(this._miniGameDefID != -1)
         {
            gemMultiplier = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).gemMultiplier;
         }
         if(gemMultiplier > 1)
         {
            amount *= gemMultiplier;
         }
         this._totalGemsEarned += amount;
         MinigameManager.awardGems(amount,this._miniGameDefID);
      }
      
      public function valueTrackerCurrent() : Number
      {
         var lbV:int = 0;
         if(this._trackerMain.length > 0)
         {
            lbV = 0;
            if(this._miniGameDefID != -1)
            {
               lbV = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
            }
            return 9999999 - (this._trackerMain[this._trackerMain.length - 1] - lbV * 5 + MinigameManager.getScoreSN());
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
      
      public function valueTracker(value:Number) : void
      {
         var lbV:int = 0;
         if(this._miniGameDefID != -1)
         {
            lbV = MinigameManager.minigameInfoCache.getMinigameInfo(this._miniGameDefID).lbUseVarRef;
         }
         this._trackerMain.push(9999999 - (value - lbV * 5 + MinigameManager.getScoreSN()));
         if(this._trackerMain.length >= 3)
         {
            this._trackerMain.shift();
         }
         this.mainTracker();
      }
   }
}

