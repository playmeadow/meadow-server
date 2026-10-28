package gui
{
   import avatar.AvatarManager;
   import avatar.UserCommXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import game.MinigameManager;
   import gskinner.motion.GTween;
   import gui.itemWindows.ItemWindowGame;
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
         if(setActionCallback != null)
         {
            throw new Error("ERROR: Singleton ActionManager did not expect to be created twice!");
         }
         setActionCallback = param1;
         actionBtn = param2;
         actionBtn.addEventListener("mouseDown",actionBtnDownHandler,false,0,true);
         actionWindow = param3;
         _gameTab = param3.hudGameTab;
         _gameTab.gameCancelTabBtn.visible = false;
         if(Utility.canPVP())
         {
            _gameTab.gameTabBtn.addEventListener("mouseDown",onGameTab,false,0,true);
            _gameTab.gameCancelTabBtn.addEventListener("mouseDown",onCancelGameTab,false,0,true);
         }
         else
         {
            _gameTab.gameTabBtn.activateGrayState(true);
         }
         LocalizationManager.translateId(_gameTab.buddyGamesTxt,6285);
         addAllActions();
         actionWindow.addChild(_actions);
         actionWindow.addChild(_petActions);
         _petActions.visible = false;
         actionWindow.poseBtns = _actions.poseBtns;
         actionWindow.diveBtn = _actions.diveBtn;
         actionWindow.swirlBtn = _actions.swirlBtn;
         actionWindow.sitBtns = _actions.sitBtns;
         actionWindow.visible = false;
         emoteBtn = param4;
         emoteWindow = param5;
         safeChatBtn = param6;
         safeChatTree = param7;
         setupTitleBanner();
      }
      
      public function turnOnOceanActions(param1:Boolean) : void
      {
         actionWindow.poseBtns.visible = param1;
         actionWindow.diveBtn.visible = param1;
         actionWindow.swirlBtn.visible = param1;
         actionWindow.sitBtns.visible = !param1;
      }
      
      public function turnOnPetActions(param1:Boolean) : void
      {
         if(param1)
         {
            _petActions.visible = true;
            _actions.visible = false;
         }
         else
         {
            _petActions.visible = false;
            _actions.visible = true;
         }
      }
      
      public function grayGameTab(param1:Boolean) : void
      {
         _gameTab.gameTabBtn.activateGrayState(param1);
      }
      
      public function reload(param1:MovieClip, param2:MovieClip, param3:MovieClip, param4:Sprite, param5:MovieClip, param6:MovieClip, param7:Function) : void
      {
         setActionCallback = param7;
         if(actionBtn)
         {
            actionBtn.removeEventListener("mouseDown",actionBtnDownHandler);
         }
         actionBtn = param1;
         actionBtn.addEventListener("mouseDown",actionBtnDownHandler,false,0,true);
         while(actionWindow.numChildren > 2)
         {
            actionWindow.removeChildAt(actionWindow.numChildren - 1);
         }
         actionWindow = param2;
         _gameTab = param2.hudGameTab;
         if(_gameTab)
         {
            _gameTab.gameCancelTabBtn.visible = false;
            _gameTab.visible = !MinigameManager.inMinigame();
            if(Utility.canPVP())
            {
               _gameTab.gameTabBtn.addEventListener("mouseDown",onGameTab,false,0,true);
               _gameTab.gameCancelTabBtn.addEventListener("mouseDown",onCancelGameTab,false,0,true);
            }
            else
            {
               _gameTab.gameTabBtn.activateGrayState(true);
            }
            LocalizationManager.translateId(_gameTab.buddyGamesTxt,6285);
            setupTitleBanner();
         }
         addAllActions();
         actionWindow.addChild(_actions);
         actionWindow.addChild(_petActions);
         _petActions.visible = false;
         actionWindow.poseBtns = _actions.poseBtns;
         actionWindow.diveBtn = _actions.diveBtn;
         actionWindow.swirlBtn = _actions.swirlBtn;
         actionWindow.sitBtns = _actions.sitBtns;
         actionWindow.visible = false;
         emoteBtn = param3;
         emoteWindow = param4;
         actionWindow = param2;
         safeChatBtn = param5;
         safeChatTree = param6;
         actionBtn.downToUpState();
      }
      
      private function addAllActions() : void
      {
         var _loc14_:* = 0;
         _loc14_ = 10;
         var _loc11_:* = 0;
         _loc11_ = 25;
         var _loc13_:* = 0;
         _loc13_ = 40;
         var _loc5_:* = 0;
         _loc5_ = 91;
         var _loc2_:* = 0;
         _loc2_ = 2;
         var _loc1_:Number = NaN;
         _loc1_ = -72;
         var _loc4_:Number = NaN;
         _loc4_ = -50;
         var _loc10_:Number = NaN;
         _loc10_ = -88;
         var _loc15_:int = 0;
         _loc15_ = 4;
         var _loc16_:int = 0;
         _loc16_ = 2;
         var _loc7_:int = 0;
         _loc7_ = 8;
         var _loc6_:* = 0;
         var _loc3_:Sprite = null;
         var _loc12_:Sprite = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         _actions = new MovieClip();
         _petActions = new MovieClip();
         _loc6_ = 0;
         while(_loc6_ < actionSprites.length)
         {
            if(_loc6_ < 8)
            {
               _loc3_ = GETDEFINITIONBYNAME(_loc6_ < 4 ? "sitBtns" : actionSprites[_loc6_]);
               if(_loc6_ == 0)
               {
                  _loc3_.x = actionWindow.ba.width * 0.5 + -72 - 25 - 5;
                  _loc3_.y = 10 + Math.floor(_loc6_ / 2) * 40 + -50;
                  _actions.addChild(_loc3_);
                  _actions.sitBtns = _loc3_;
                  _loc8_ = 1;
                  while(_loc8_ <= 4)
                  {
                     _loc12_ = _loc3_["sit" + _loc8_ + "Btn"];
                     _loc12_.buttonMode = true;
                     _loc12_.useHandCursor = true;
                     _loc12_.tabEnabled = true;
                     _loc12_.tabChildren = false;
                     _loc12_.addEventListener("mouseDown",actionClickHandler,false,0,true);
                     _loc8_++;
                  }
               }
               else if(_loc6_ >= 4)
               {
                  _loc3_.x = 25 + (_loc6_ % 2 * 91 + -72);
                  _loc3_.y = 10 + Math.floor(_loc6_ / 2) * 40 + -88;
                  _actions.addChild(_loc3_);
                  _loc3_.buttonMode = true;
                  _loc3_.useHandCursor = true;
                  _loc3_.tabEnabled = true;
                  _loc3_.tabChildren = false;
                  _loc3_.addEventListener("mouseDown",actionClickHandler,false,0,true);
               }
            }
            else
            {
               _loc3_ = GETDEFINITIONBYNAME(_loc6_ == 8 ? "poseBtns" : actionSprites[_loc6_]);
               if(_loc6_ == 8)
               {
                  _loc3_.visible = false;
                  _actions.poseBtns = _loc3_;
                  _loc3_.x = actionWindow.ba.width * 0.5 + -72 - 25 - 5;
                  _loc3_.y = 10 + Math.floor((_loc6_ - 8) / 2) * 40 + -50;
                  _actions.addChild(_loc3_);
                  _loc9_ = 1;
                  while(_loc9_ <= 2)
                  {
                     _loc12_ = _loc3_["pose" + _loc9_ + "Btn"];
                     _loc12_.buttonMode = true;
                     _loc12_.useHandCursor = true;
                     _loc12_.tabEnabled = true;
                     _loc12_.tabChildren = false;
                     _loc12_.addEventListener("mouseDown",actionClickHandler,false,0,true);
                     _loc9_++;
                  }
               }
               else if(_loc6_ >= 8 + 2)
               {
                  _loc3_.visible = false;
                  if(_loc6_ == actionSprites.length - 1)
                  {
                     _actions.diveBtn = _loc3_;
                  }
                  else
                  {
                     _actions.swirlBtn = _loc3_;
                  }
                  _loc3_.x = 25 + ((_loc6_ - 5) % 2 * 91 + -72);
                  _loc3_.y = 10 + Math.floor((_loc6_ - 5) / 2) * 40 + -88;
                  _actions.addChild(_loc3_);
                  _loc3_.buttonMode = true;
                  _loc3_.useHandCursor = true;
                  _loc3_.tabEnabled = true;
                  _loc3_.tabChildren = false;
                  _loc3_.addEventListener("mouseDown",actionClickHandler,false,0,true);
               }
            }
            _loc6_++;
         }
         _loc3_ = GETDEFINITIONBYNAME("playPetAnim_btnCont");
         _loc3_.y = -31;
         _loc3_.buttonMode = true;
         _loc3_.useHandCursor = true;
         _loc3_.tabEnabled = true;
         _loc3_.tabChildren = false;
         _loc3_.addEventListener("mouseDown",onPetPlayBtn,false,0,true);
         _petActions.addChild(_loc3_);
         _loc3_ = GETDEFINITIONBYNAME("dancePetAnim_btnCont");
         _petActions.danceBtn = _loc3_;
         _loc3_.y = 31;
         _loc3_.buttonMode = true;
         _loc3_.useHandCursor = true;
         _loc3_.tabEnabled = true;
         _loc3_.tabChildren = false;
         _loc3_.addEventListener("mouseDown",actionClickHandler,false,0,true);
         _petActions.addChild(_loc3_);
         actionStrings = {};
         actionStrings["sit1BtnCont"] = actionStrings["pose1BtnCont"] = [":sitNW:",":poseLeft:"];
         actionStrings["sit2BtnCont"] = [":sitNE:"];
         actionStrings["sit3BtnCont"] = [":sitSE:"];
         actionStrings["sit4BtnCont"] = actionStrings["pose2BtnCont"] = [":sitSW:",":poseRight:"];
         actionStrings["danceAnim_btnCont"] = actionStrings["dancePetAnim_btnCont"] = [":dance:"];
         actionStrings["sleepAnim_btnCont"] = actionStrings["diveAnim_btnCont"] = [":sleep:",":dive:"];
         actionStrings["hopAnim_btnCont"] = actionStrings["swirlAnim_btnCont"] = [":hop:",":swirl:"];
         actionStrings["playAnim_btnCont"] = [":play:"];
      }
      
      private function setupTitleBanner() : void
      {
         var _loc1_:Sprite = GETDEFINITIONBYNAME("AnimsTitleBanner");
         _loc1_.x = -91.75;
         _loc1_.y = -91.25;
         actionWindow.addChild(_loc1_);
      }
      
      public function destroy() : void
      {
         setActionCallback = null;
         actionBtn.removeEventListener("mouseDown",actionBtnDownHandler);
         actionBtn = null;
         actionWindow.visible = false;
         actionWindow = null;
         emoteBtn = null;
         emoteWindow = null;
         safeChatBtn = null;
         safeChatTree = null;
      }
      
      public function getActionString(param1:Sprite) : String
      {
         var _loc2_:String = param1["constructor"].toString();
         var _loc3_:String = _loc2_.slice(7,_loc2_.length - 1);
         if(actionStrings[_loc3_])
         {
            if(actionStrings[_loc3_].length > 1)
            {
               return actionStrings[_loc2_.slice(7,_loc2_.length - 1)][AvatarManager.roomEnviroType == 0 ? 0 : 1];
            }
            return actionStrings[_loc2_.slice(7,_loc2_.length - 1)][0];
         }
         return null;
      }
      
      public function matchActionString(param1:String) : Sprite
      {
         var _loc3_:int = 0;
         for each(var _loc2_:String in actionSprites)
         {
            _loc3_ = int(actionStrings[_loc2_].indexOf(param1));
            if(_loc3_ != -1)
            {
               if(actionStrings[_loc2_].length <= 1)
               {
                  return GETDEFINITIONBYNAME(_loc2_);
               }
               if(AvatarManager.roomEnviroType == 0 ? _loc3_ == 0 : _loc3_ == 1)
               {
                  return GETDEFINITIONBYNAME(_loc2_);
               }
            }
         }
         return null;
      }
      
      public function openActions() : void
      {
         if(!actionWindow.visible)
         {
            actionWindow.visible = true;
            brightenActions();
         }
      }
      
      public function dimActions() : void
      {
         if(actionWindow.visible && actionWindow.alpha != 0.5)
         {
            actionWindow.alpha = 0.5;
         }
      }
      
      public function brightenActions() : void
      {
         if(actionWindow.alpha != 1)
         {
            actionWindow.alpha = 1;
         }
      }
      
      public function closeActions() : void
      {
         if(actionWindow.visible)
         {
            actionWindow.visible = false;
            brightenActions();
            actionBtn.downToUpState();
            closeSideMenu(_gameTab);
         }
      }
      
      public function hideCancelBtn() : void
      {
         if(_gameTab)
         {
            _gameTab.gameCancelTabBtn.visible = false;
         }
      }
      
      public function grayOutPetDanceBtn(param1:Boolean) : void
      {
         if(_petActions)
         {
            _petActions.danceBtn.activateGrayState(param1);
         }
      }
      
      private function actionBtnDownHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(actionWindow.visible)
            {
               closeActions();
            }
            else
            {
               if(safeChatTree.visible)
               {
                  safeChatBtn.dispatchEvent(param1);
               }
               if(emoteWindow.visible)
               {
                  emoteBtn.dispatchEvent(param1);
               }
               openActions();
            }
         }
      }
      
      private function onGameTab(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!param1.currentTarget.isGray)
         {
            if(!_isGameTabOpen)
            {
               if(_pvpItemWindows == null)
               {
                  _pvpGameList = MinigameManager.minigameInfoCache.getAllReadyForPvpGameDefs();
                  createPVPWindows();
                  getPVPIcons();
               }
               else
               {
                  _gameTab.itemWindow.addChild(_pvpItemWindows);
                  if(_pvpScrollBar)
                  {
                     _pvpScrollBar.destroy();
                  }
                  _pvpScrollBar = new SBScrollbar();
                  _pvpScrollBar.init(_pvpItemWindows,155,156,3,"scrollbar2",78);
               }
               openSideMenu(_gameTab);
            }
            else
            {
               closeSideMenu(_gameTab);
            }
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
         if(!_isGameTabOpen)
         {
            new GTween(param1,0.5,{"x":param1.x + 175},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isGameTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private function closeSideMenu(param1:MovieClip) : void
      {
         if(_isGameTabOpen && _sideMenuTweenFinished)
         {
            new GTween(param1,0.5,{"x":param1.x - 175},{
               "ease":TweenManager.quadratic,
               "onComplete":sideMenuComplete
            });
            _sideMenuTweenFinished = false;
            _isGameTabOpen = false;
            AJAudio.playBuddyCardClose();
         }
      }
      
      private function createPVPWindows() : void
      {
         if(_pvpScrollBar)
         {
            _pvpScrollBar.destroy();
            _pvpScrollBar = null;
         }
         if(_pvpItemWindows && _pvpItemWindows.numChildren > 0)
         {
            _pvpItemWindows.destroy();
            _pvpItemWindows = null;
         }
         var _loc1_:int = int(_pvpGameList.length);
         var _loc2_:int = Math.min(_loc1_,2);
         _pvpItemWindows = new WindowGenerator();
         _pvpItemWindows.init(_loc2_,_loc2_,_loc1_,2,2,0,ItemWindowGame,null,"",{
            "mouseDown":sideMenuMouseDown,
            "mouseOver":sideMenuMouseOver,
            "mouseOut":winMouseOut
         },null,null,false,false);
         _gameTab.itemWindow.addChild(_pvpItemWindows);
         _pvpScrollBar = new SBScrollbar();
         _pvpScrollBar.init(_pvpItemWindows,155,156,3,"scrollbar2",78,0,Math.ceil(_loc1_ / _loc2_) * 78);
      }
      
      private function getPVPIcons() : void
      {
         var _loc1_:int = 0;
         var _loc2_:MediaHelper = null;
         _views = [];
         _loc1_ = 0;
         while(_loc1_ < _pvpGameList.length)
         {
            _loc2_ = new MediaHelper();
            _loc2_.init(_pvpGameList[_loc1_].gameCardMediaId,mediaHelperCallback,true);
            _views[_loc1_] = _loc2_;
            _loc1_++;
         }
      }
      
      private function mediaHelperCallback(param1:MovieClip) : void
      {
         var _loc3_:int = 0;
         var _loc2_:MovieClip = null;
         _loc3_ = 0;
         while(_loc3_ < _views.length)
         {
            if(_views[_loc3_] == param1.mediaHelper)
            {
               _loc2_ = MovieClip(_pvpItemWindows.bg.getChildAt(_loc3_));
               _loc2_.itemLayer.addChild(param1);
            }
            _loc3_++;
         }
      }
      
      private function sideMenuComplete(param1:GTween) : void
      {
         _sideMenuTweenFinished = true;
      }
      
      private function sideMenuMouseDown(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(MinigameManager.minigameInfoCache.currMinigameId == _pvpGameList[param1.currentTarget.index].gameDefId)
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,_pvpGameList[param1.currentTarget.index].gameDefId);
            MinigameManager.readySelfForCustomPVPGame(-1,"");
            _gameTab.gameCancelTabBtn.visible = false;
         }
         else
         {
            UserCommXtCommManager.sendCustomPVPMessage(true,_pvpGameList[param1.currentTarget.index].gameDefId);
            MinigameManager.readySelfForCustomPVPGame(_pvpGameList[param1.currentTarget.index].gameDefId,"");
            _gameTab.gameCancelTabBtn.visible = true;
         }
         closeActions();
      }
      
      private function sideMenuMouseOver(param1:MouseEvent) : void
      {
         var _loc2_:Point = null;
         param1.stopPropagation();
         if(_sideMenuTweenFinished)
         {
            _loc2_ = param1.currentTarget.localToGlobal(new Point(0,0));
            GuiManager.toolTip.init(actionWindow,LocalizationManager.translateIdOnly(_pvpGameList[param1.currentTarget.index].titleStrId),_loc2_.x - actionWindow.x + actionWindow.hudGameTab.x + actionWindow.hudGameTab.itemWindow.x - param1.currentTarget.width,_loc2_.y - actionWindow.y + param1.currentTarget.height + _gameTab.y);
            GuiManager.toolTip.startTimer(param1);
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function winMouseOut(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function actionClickHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(!actionBtn.isGray && !param1.currentTarget.isGray)
         {
            setActionCallback(new param1.currentTarget.constructor());
            actionBtn.dispatchEvent(new MouseEvent("mouseDown"));
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
         actionBtn.dispatchEvent(new MouseEvent("mouseDown"));
         param1.currentTarget.downToUpState();
      }
   }
}

