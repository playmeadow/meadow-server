package gui
{
   import avatar.AvatarManager;
   import avatar.UserCommXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import game.MinigameManager;
   import gskinner.motion.GTween;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   import pet.WorldPet;
   
   public class ActionManager
   {
      
      private const ACTIONWINDOW_DIM_ALPHA:Number = 0.5;
      
      private const ACTIONWINDOW_BRIGHT_ALPHA:Number = 1;
      
      public var actionBtn:MovieClip;
      
      public var actionWindow:MovieClip;
      
      public var emoteBtn:MovieClip;
      
      public var emoteWindow:Sprite;
      
      public var safeChatBtn:MovieClip;
      
      public var safeChatTree:MovieClip;
      
      public var setActionCallback:Function;
      
      public var actionSprites:Array = ["sit1BtnCont","sit2BtnCont","sit3BtnCont","sit4BtnCont","danceAnim_btnCont","sleepAnim_btnCont","hopAnim_btnCont","playAnim_btnCont","pose1BtnCont","pose2BtnCont","diveAnim_btnCont","swirlAnim_btnCont"];
      
      public var actionStrings:Object;
      
      private var _actions:MovieClip;
      
      private var _petActions:MovieClip;
      
      private var _gameTab:MovieClip;
      
      private var _isGameTabOpen:Boolean;
      
      private var _sideMenuTweenFinished:Boolean;
      
      private var _pvpScrollBar:SBScrollbar;
      
      private var _pvpItemWindows:WindowGenerator;
      
      private var _pvpGameList:Array;
      
      private var _views:Array;
      
      public function ActionManager(param1:Function, param2:MovieClip, param3:MovieClip, param4:MovieClip, param5:Sprite, param6:MovieClip, param7:MovieClip)
      {
         super();
         if(this.setActionCallback != null)
         {
            throw new Error("ERROR: Singleton ActionManager did not expect to be created twice!");
         }
         this.setActionCallback = param1;
         this.actionBtn = param2;
         this.actionBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler,false,0,true);
         this.actionWindow = param3;
         this._gameTab = param3.hudGameTab;
         this._gameTab.gameCancelTabBtn.visible = false;
         if(Utility.canPVP())
         {
            this._gameTab.gameTabBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onGameTab,false,0,true);
            this._gameTab.gameCancelTabBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCancelGameTab,false,0,true);
         }
         else
         {
            this._gameTab.gameTabBtn.activateGrayState(true);
         }
         this.addAllActions();
         this.actionWindow.addChild(this._actions);
         this.actionWindow.addChild(this._petActions);
         this._petActions.visible = false;
         this.actionWindow.poseBtns = this._actions.poseBtns;
         this.actionWindow.diveBtn = this._actions.diveBtn;
         this.actionWindow.swirlBtn = this._actions.swirlBtn;
         this.actionWindow.visible = false;
         this.emoteBtn = param4;
         this.emoteWindow = param5;
         this.safeChatBtn = param6;
         this.safeChatTree = param7;
      }
      
      public function turnOnOceanActions(param1:Boolean) : void
      {
         this.actionWindow.poseBtns.visible = param1;
         this.actionWindow.diveBtn.visible = param1;
         this.actionWindow.swirlBtn.visible = param1;
      }
      
      public function turnOnPetActions(param1:Boolean) : void
      {
         if(param1)
         {
            this._petActions.visible = true;
            this._actions.visible = false;
         }
         else
         {
            this._petActions.visible = false;
            this._actions.visible = true;
         }
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:Sprite, param5:MovieClip, param6:MovieClip) : void
      {
         if(this.actionBtn)
         {
            this.actionBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler);
         }
         this.actionBtn = param1;
         this.actionBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler,false,0,true);
         while(this.actionWindow.numChildren > 2)
         {
            this.actionWindow.removeChildAt(this.actionWindow.numChildren - 1);
         }
         this.actionWindow = param2;
         this._gameTab = param2.hudGameTab;
         if(this._gameTab)
         {
            this._gameTab.gameCancelTabBtn.visible = false;
            if(Utility.canPVP())
            {
               this._gameTab.gameTabBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onGameTab,false,0,true);
               this._gameTab.gameCancelTabBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onCancelGameTab,false,0,true);
            }
            else
            {
               this._gameTab.gameTabBtn.activateGrayState(true);
            }
         }
         this.actionWindow.addChild(this._actions);
         this.actionWindow.addChild(this._petActions);
         this._petActions.visible = false;
         this.actionWindow.poseBtns = this._actions.poseBtns;
         this.actionWindow.diveBtn = this._actions.diveBtn;
         this.actionWindow.swirlBtn = this._actions.swirlBtn;
         this.actionWindow.visible = false;
         this.emoteBtn = param3;
         this.emoteWindow = param4;
         this.actionWindow = param2;
         this.safeChatBtn = param5;
         this.safeChatTree = param6;
      }
      
      private function addAllActions() : void
      {
         var _loc5_:uint = 0;
         var _loc7_:Number = NaN;
         var _loc11_:int = 0;
         var _loc13_:Sprite = null;
         var _loc14_:Sprite = null;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc1_:uint = 10;
         var _loc2_:uint = 25;
         var _loc3_:uint = 40;
         var _loc4_:uint = 91;
         _loc5_ = 2;
         var _loc6_:Number = -72;
         _loc7_ = -50;
         var _loc8_:Number = -88;
         var _loc9_:int = 4;
         var _loc10_:int = 2;
         _loc11_ = 8;
         this._actions = new MovieClip();
         this._petActions = new MovieClip();
         var _loc12_:uint = 0;
         while(_loc12_ < this.actionSprites.length)
         {
            if(_loc12_ < _loc11_)
            {
               _loc13_ = GETDEFINITIONBYNAME(_loc12_ < _loc9_ ? "sitBtns" : this.actionSprites[_loc12_]);
               if(_loc12_ == 0)
               {
                  _loc13_.x = this.actionWindow.width * 0.5 + _loc6_ - _loc2_ - 30;
                  _loc13_.y = _loc1_ + Math.floor(_loc12_ / _loc5_) * _loc3_ + _loc7_;
                  this._actions.addChild(_loc13_);
                  _loc15_ = 1;
                  while(_loc15_ <= 4)
                  {
                     _loc14_ = _loc13_["sit" + _loc15_ + "Btn"];
                     _loc14_.buttonMode = true;
                     _loc14_.useHandCursor = true;
                     _loc14_.mouseChildren = false;
                     _loc14_.tabEnabled = true;
                     _loc14_.tabChildren = false;
                     _loc14_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
                     _loc15_++;
                  }
               }
               else if(_loc12_ >= _loc9_)
               {
                  _loc13_.x = _loc2_ + (_loc12_ % _loc5_ * _loc4_ + _loc6_);
                  _loc13_.y = _loc1_ + Math.floor(_loc12_ / _loc5_) * _loc3_ + _loc8_;
                  this._actions.addChild(_loc13_);
                  _loc13_.buttonMode = true;
                  _loc13_.useHandCursor = true;
                  _loc13_.mouseChildren = false;
                  _loc13_.tabEnabled = true;
                  _loc13_.tabChildren = false;
                  _loc13_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
               }
            }
            else
            {
               _loc13_ = GETDEFINITIONBYNAME(_loc12_ == _loc11_ ? "poseBtns" : this.actionSprites[_loc12_]);
               if(_loc12_ == _loc11_)
               {
                  _loc13_.visible = false;
                  this._actions.poseBtns = _loc13_;
                  _loc13_.x = this.actionWindow.width * 0.5 + _loc6_ - _loc2_ - 30;
                  _loc13_.y = _loc1_ + Math.floor((_loc12_ - _loc11_) / _loc5_) * _loc3_ + _loc7_;
                  this._actions.addChild(_loc13_);
                  _loc16_ = 1;
                  while(_loc16_ <= 2)
                  {
                     _loc14_ = _loc13_["pose" + _loc16_ + "Btn"];
                     _loc14_.buttonMode = true;
                     _loc14_.useHandCursor = true;
                     _loc14_.mouseChildren = false;
                     _loc14_.tabEnabled = true;
                     _loc14_.tabChildren = false;
                     _loc14_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
                     _loc16_++;
                  }
               }
               else if(_loc12_ >= _loc11_ + _loc10_)
               {
                  _loc13_.visible = false;
                  if(_loc12_ == this.actionSprites.length - 1)
                  {
                     this._actions.diveBtn = _loc13_;
                  }
                  else
                  {
                     this._actions.swirlBtn = _loc13_;
                  }
                  _loc13_.x = _loc2_ + ((_loc12_ - 5) % _loc5_ * _loc4_ + _loc6_);
                  _loc13_.y = _loc1_ + Math.floor((_loc12_ - 5) / _loc5_) * _loc3_ + _loc8_;
                  this._actions.addChild(_loc13_);
                  _loc13_.buttonMode = true;
                  _loc13_.useHandCursor = true;
                  _loc13_.mouseChildren = false;
                  _loc13_.tabEnabled = true;
                  _loc13_.tabChildren = false;
                  _loc13_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
               }
            }
            _loc12_++;
         }
         _loc13_ = GETDEFINITIONBYNAME("playPetAnim_btnCont");
         _loc13_.y = -31;
         _loc13_.buttonMode = true;
         _loc13_.useHandCursor = true;
         _loc13_.mouseChildren = false;
         _loc13_.tabEnabled = true;
         _loc13_.tabChildren = false;
         _loc13_.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetPlayBtn,false,0,true);
         this._petActions.addChild(_loc13_);
         _loc13_ = GETDEFINITIONBYNAME("dancePetAnim_btnCont");
         this._petActions.danceBtn = _loc13_;
         _loc13_.y = 31;
         _loc13_.buttonMode = true;
         _loc13_.useHandCursor = true;
         _loc13_.mouseChildren = false;
         _loc13_.tabEnabled = true;
         _loc13_.tabChildren = false;
         _loc13_.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
         this._petActions.addChild(_loc13_);
         this.actionStrings = new Object();
         this.actionStrings["sit1BtnCont"] = this.actionStrings["pose1BtnCont"] = [":sitNW:",":poseLeft:"];
         this.actionStrings["sit2BtnCont"] = [":sitNE:"];
         this.actionStrings["sit3BtnCont"] = [":sitSE:"];
         this.actionStrings["sit4BtnCont"] = this.actionStrings["pose2BtnCont"] = [":sitSW:",":poseRight:"];
         this.actionStrings["danceAnim_btnCont"] = this.actionStrings["dancePetAnim_btnCont"] = [":dance:"];
         this.actionStrings["sleepAnim_btnCont"] = this.actionStrings["diveAnim_btnCont"] = [":sleep:",":dive:"];
         this.actionStrings["hopAnim_btnCont"] = this.actionStrings["swirlAnim_btnCont"] = [":hop:",":swirl:"];
         this.actionStrings["playAnim_btnCont"] = [":play:"];
      }
      
      public function destroy() : void
      {
         this.setActionCallback = null;
         this.actionBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler);
         this.actionBtn = null;
         this.actionWindow.visible = false;
         this.actionWindow = null;
         this.emoteBtn = null;
         this.emoteWindow = null;
         this.safeChatBtn = null;
         this.safeChatTree = null;
      }
      
      public function getActionString(param1:Sprite) : String
      {
         var _loc2_:String = param1["constructor"].toString();
         var _loc3_:String = _loc2_.slice(7,_loc2_.length - 1);
         if(this.actionStrings[_loc3_])
         {
            if(this.actionStrings[_loc3_].length > 1)
            {
               return this.actionStrings[_loc2_.slice(7,_loc2_.length - 1)][AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? 0 : 1];
            }
            return this.actionStrings[_loc2_.slice(7,_loc2_.length - 1)][0];
         }
         return null;
      }
      
      public function matchActionString(param1:String) : Sprite
      {
         var _loc2_:String = null;
         var _loc3_:int = 0;
         for each(_loc2_ in this.actionSprites)
         {
            _loc3_ = int(this.actionStrings[_loc2_].indexOf(param1));
            if(_loc3_ != -1)
            {
               if(this.actionStrings[_loc2_].length <= 1)
               {
                  return GETDEFINITIONBYNAME(_loc2_);
               }
               if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? _loc3_ == 0 : _loc3_ == 1)
               {
                  return GETDEFINITIONBYNAME(_loc2_);
               }
            }
         }
         return null;
      }
      
      public function openActions() : void
      {
         if(!this.actionWindow.visible)
         {
            this.actionWindow.visible = true;
            this.brightenActions();
         }
      }
      
      public function dimActions() : void
      {
         if(this.actionWindow.visible && this.actionWindow.alpha != this.ACTIONWINDOW_DIM_ALPHA)
         {
            this.actionWindow.alpha = this.ACTIONWINDOW_DIM_ALPHA;
         }
      }
      
      public function brightenActions() : void
      {
         if(this.actionWindow.alpha != this.ACTIONWINDOW_BRIGHT_ALPHA)
         {
            this.actionWindow.alpha = this.ACTIONWINDOW_BRIGHT_ALPHA;
         }
      }
      
      public function closeActions() : void
      {
         if(this.actionWindow.visible)
         {
            this.actionWindow.visible = false;
            this.brightenActions();
            this.actionBtn.downToUpState();
            this.closeSideMenu(this._gameTab);
         }
      }
      
      public function hideCancelBtn() : void
      {
         if(this._gameTab)
         {
            this._gameTab.gameCancelTabBtn.visible = false;
         }
      }
      
      public function grayOutPetDanceBtn(param1:Boolean) : void
      {
         if(this._petActions)
         {
            this._petActions.danceBtn.activateGrayState(param1);
         }
      }
      
      private function actionBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(this.actionWindow.visible)
            {
               this.closeActions();
            }
            else
            {
               if(this.safeChatTree.visible)
               {
                  this.safeChatBtn.dispatchEvent(param1);
               }
               if(this.emoteWindow.visible)
               {
                  this.emoteBtn.dispatchEvent(param1);
               }
               this.openActions();
            }
         }
      }
      
      private function onGameTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this._isGameTabOpen)
         {
            if(this._pvpItemWindows == null)
            {
               this._pvpGameList = MinigameManager.minigameInfoCache.getAllReadyForPvpGameDefs();
               this.createPVPWindows();
               this.getPVPIcons();
            }
            else
            {
               this._gameTab.itemWindow.addChild(this._pvpItemWindows);
               if(this._pvpScrollBar)
               {
                  this._pvpScrollBar.destroy();
               }
               this._pvpScrollBar = new SBScrollbar();
               this._pvpScrollBar.init(this._pvpItemWindows,155,156,10,"scrollbar2",78);
            }
            this.openSideMenu(this._gameTab);
         }
         else
         {
            this.closeSideMenu(this._gameTab);
         }
      }
      
      private function onCancelGameTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         param1.currentTarget.visible = false;
         UserCommXtCommManager.sendCustomPVPMessage(false,MinigameManager.minigameInfoCache.currMinigameId);
         MinigameManager.readySelfForCustomPVPGame(-1,"");
      }
      
      private function openSideMenu(param1:MovieClip) : void
      {
         if(!this._isGameTabOpen)
         {
            new GTween(param1,0.5,{"x":param1.x + 175},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._sideMenuTweenFinished = false;
            this._isGameTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private function closeSideMenu(param1:MovieClip) : void
      {
         if(this._isGameTabOpen && this._sideMenuTweenFinished)
         {
            new GTween(param1,0.5,{"x":param1.x - 175},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._sideMenuTweenFinished = false;
            this._isGameTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private function createPVPWindows() : void
      {
         if(this._pvpScrollBar)
         {
            this._pvpScrollBar.destroy();
            this._pvpScrollBar = null;
         }
         if(Boolean(this._pvpItemWindows) && this._pvpItemWindows.numChildren > 0)
         {
            this._pvpItemWindows.destroy();
            this._pvpItemWindows = null;
         }
         var _loc1_:int = int(this._pvpGameList.length);
         var _loc2_:int = Math.min(_loc1_,2);
         this._pvpItemWindows = new WindowGenerator();
         this._pvpItemWindows.init(_loc2_,_loc2_,_loc1_,2,2,0,ItemWindowGame,null,"",{
            "mouseDown":this.sideMenuMouseDown,
            "mouseOver":this.sideMenuMouseOver,
            "mouseOut":this.winMouseOut
         },null,null,false,false);
         this._gameTab.itemWindow.addChild(this._pvpItemWindows);
         this._pvpScrollBar = new SBScrollbar();
         this._pvpScrollBar.init(this._pvpItemWindows,155,156,10,"scrollbar2",78,0,Math.ceil(_loc1_ / _loc2_) * 78);
      }
      
      private function getPVPIcons() : void
      {
         var _loc2_:MediaHelper = null;
         this._views = new Array();
         var _loc1_:int = 0;
         while(_loc1_ < this._pvpGameList.length)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(this._pvpGameList[_loc1_].gameCardMediaId,this.mediaHelperCallback,true);
            this._views[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc3_:MovieClip = null;
         var _loc2_:int = 0;
         while(_loc2_ < this._views.length)
         {
            if(this._views[_loc2_] == param1.mediaHelper)
            {
               _loc3_ = MovieClip(this._pvpItemWindows.bg.getChildAt(_loc2_));
               _loc3_.itemLayer.addChild(param1);
            }
            _loc2_++;
         }
      }
      
      private function sideMenuComplete(param1:GTween) : void
      {
         this._sideMenuTweenFinished = true;
      }
      
      private function sideMenuMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(MinigameManager.minigameInfoCache.currMinigameId == this._pvpGameList[param1.currentTarget.index].gameDefId)
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,this._pvpGameList[param1.currentTarget.index].gameDefId);
            MinigameManager.readySelfForCustomPVPGame(-1,"");
            this._gameTab.gameCancelTabBtn.visible = false;
         }
         else
         {
            UserCommXtCommManager.sendCustomPVPMessage(true,this._pvpGameList[param1.currentTarget.index].gameDefId);
            MinigameManager.readySelfForCustomPVPGame(this._pvpGameList[param1.currentTarget.index].gameDefId,"");
            this._gameTab.gameCancelTabBtn.visible = true;
         }
         this.closeActions();
      }
      
      private function sideMenuMouseOver(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.init(this._gameTab.itemWindow,LocalizationManager.translateIdOnly(this._pvpGameList[param1.currentTarget.index].titleStrId),param1.currentTarget.x + param1.currentTarget.width * 0.5,param1.currentTarget.y + this._pvpItemWindows.y + 70);
         GuiManager.toolTip.startTimer(param1);
         AJAudio.playSubMenuBtnRollover();
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function actionClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!this.actionBtn.isGray && !param1.currentTarget.isGray)
         {
            this.setActionCallback(new param1.target.constructor());
            this.actionBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            param1.currentTarget.downToUpState();
         }
      }
      
      private function onPetPlayBtn(param1:MouseEvent) : void
      {
         var _loc2_:WorldPet = null;
         param1.stopPropagation();
         if(AvatarManager.playerAvatarWorldView)
         {
            _loc2_ = AvatarManager.playerAvatarWorldView.getActivePet();
            if(_loc2_)
            {
               AvatarManager.playerAvatarWorldView.faceAnim(0,0,false);
               _loc2_.onClick(param1);
            }
         }
         this.actionBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         param1.currentTarget.downToUpState();
      }
   }
}

