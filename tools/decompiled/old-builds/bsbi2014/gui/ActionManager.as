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
      
      public function ActionManager(actionCallbackRef:Function, actBtn:MovieClip, actWindow:MovieClip, emoticonBtn:MovieClip, emoticonWindow:Sprite, safeChatButton:MovieClip, safeChatTreeGui:MovieClip)
      {
         super();
         if(this.setActionCallback != null)
         {
            throw new Error("ERROR: Singleton ActionManager did not expect to be created twice!");
         }
         this.setActionCallback = actionCallbackRef;
         this.actionBtn = actBtn;
         this.actionBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler,false,0,true);
         this.actionWindow = actWindow;
         this._gameTab = actWindow.hudGameTab;
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
         LocalizationManager.translateId(this._gameTab.buddyGamesTxt,6285);
         this.addAllActions();
         this.actionWindow.addChild(this._actions);
         this.actionWindow.addChild(this._petActions);
         this._petActions.visible = false;
         this.actionWindow.poseBtns = this._actions.poseBtns;
         this.actionWindow.diveBtn = this._actions.diveBtn;
         this.actionWindow.swirlBtn = this._actions.swirlBtn;
         this.actionWindow.sitBtns = this._actions.sitBtns;
         this.actionWindow.visible = false;
         this.emoteBtn = emoticonBtn;
         this.emoteWindow = emoticonWindow;
         this.safeChatBtn = safeChatButton;
         this.safeChatTree = safeChatTreeGui;
         this.setupTitleBanner();
      }
      
      public function turnOnOceanActions(b:Boolean) : void
      {
         this.actionWindow.poseBtns.visible = b;
         this.actionWindow.diveBtn.visible = b;
         this.actionWindow.swirlBtn.visible = b;
         this.actionWindow.sitBtns.visible = !b;
      }
      
      public function turnOnPetActions(b:Boolean) : void
      {
         if(b)
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
      
      public function grayGameTab(gray:Boolean) : void
      {
         this._gameTab.gameTabBtn.activateGrayState(gray);
      }
      
      public function reload(actBtn:MovieClip, actWindow:MovieClip, emoticonBtn:MovieClip, emoticonWindow:Sprite, safeChatButton:MovieClip, safeChatTreeGui:MovieClip) : void
      {
         if(Boolean(this.actionBtn))
         {
            this.actionBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler);
         }
         this.actionBtn = actBtn;
         this.actionBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.actionBtnDownHandler,false,0,true);
         while(this.actionWindow.numChildren > 2)
         {
            this.actionWindow.removeChildAt(this.actionWindow.numChildren - 1);
         }
         this.actionWindow = actWindow;
         this._gameTab = actWindow.hudGameTab;
         if(Boolean(this._gameTab))
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
            LocalizationManager.translateId(this._gameTab.buddyGamesTxt,6285);
            this.setupTitleBanner();
         }
         this.addAllActions();
         this.actionWindow.addChild(this._actions);
         this.actionWindow.addChild(this._petActions);
         this._petActions.visible = false;
         this.actionWindow.poseBtns = this._actions.poseBtns;
         this.actionWindow.diveBtn = this._actions.diveBtn;
         this.actionWindow.swirlBtn = this._actions.swirlBtn;
         this.actionWindow.sitBtns = this._actions.sitBtns;
         this.actionWindow.visible = false;
         this.emoteBtn = emoticonBtn;
         this.emoteWindow = emoticonWindow;
         this.actionWindow = actWindow;
         this.safeChatBtn = safeChatButton;
         this.safeChatTree = safeChatTreeGui;
         this.actionBtn.downToUpState();
      }
      
      private function addAllActions() : void
      {
         var b:Sprite = null;
         var s:Sprite = null;
         var j:int = 0;
         var k:int = 0;
         var ACTIONS_MARGIN_TOP:uint = 10;
         var ACTIONS_MARGIN_LEFT:uint = 25;
         var ACTIONS_STEP_V:uint = 40;
         var ACTIONS_STEP_H:uint = 91;
         var ACTIONS_ROW_MAX:uint = 2;
         var ACTIONS_WINDOW_OFFSET_X:Number = -72;
         var ACTIONS_WINDOW_OFFSET_Y:Number = -50;
         var ACTIONS_WINDOW_OFFSET_Y_SIT:Number = -88;
         var ACTIONS_NUM_SIT_BTNS:int = 4;
         var ACTIONS_NUM_POSE_BTNS:int = 2;
         var ACTIONS_NUM_LAND_BTNS:int = 8;
         this._actions = new MovieClip();
         this._petActions = new MovieClip();
         for(var i:uint = 0; i < this.actionSprites.length; i++)
         {
            if(i < ACTIONS_NUM_LAND_BTNS)
            {
               b = GETDEFINITIONBYNAME(i < ACTIONS_NUM_SIT_BTNS ? "sitBtns" : this.actionSprites[i]);
               if(i == 0)
               {
                  b.x = this.actionWindow.ba.width * 0.5 + ACTIONS_WINDOW_OFFSET_X - ACTIONS_MARGIN_LEFT - 5;
                  b.y = ACTIONS_MARGIN_TOP + Math.floor(i / ACTIONS_ROW_MAX) * ACTIONS_STEP_V + ACTIONS_WINDOW_OFFSET_Y;
                  this._actions.addChild(b);
                  this._actions.sitBtns = b;
                  for(j = 1; j <= 4; j++)
                  {
                     s = b["sit" + j + "Btn"];
                     s.buttonMode = true;
                     s.useHandCursor = true;
                     s.mouseChildren = false;
                     s.tabEnabled = true;
                     s.tabChildren = false;
                     s.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
                  }
               }
               else if(i >= ACTIONS_NUM_SIT_BTNS)
               {
                  b.x = ACTIONS_MARGIN_LEFT + (i % ACTIONS_ROW_MAX * ACTIONS_STEP_H + ACTIONS_WINDOW_OFFSET_X);
                  b.y = ACTIONS_MARGIN_TOP + Math.floor(i / ACTIONS_ROW_MAX) * ACTIONS_STEP_V + ACTIONS_WINDOW_OFFSET_Y_SIT;
                  this._actions.addChild(b);
                  b.buttonMode = true;
                  b.useHandCursor = true;
                  b.mouseChildren = false;
                  b.tabEnabled = true;
                  b.tabChildren = false;
                  b.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
               }
            }
            else
            {
               b = GETDEFINITIONBYNAME(i == ACTIONS_NUM_LAND_BTNS ? "poseBtns" : this.actionSprites[i]);
               if(i == ACTIONS_NUM_LAND_BTNS)
               {
                  b.visible = false;
                  this._actions.poseBtns = b;
                  b.x = this.actionWindow.ba.width * 0.5 + ACTIONS_WINDOW_OFFSET_X - ACTIONS_MARGIN_LEFT - 5;
                  b.y = ACTIONS_MARGIN_TOP + Math.floor((i - ACTIONS_NUM_LAND_BTNS) / ACTIONS_ROW_MAX) * ACTIONS_STEP_V + ACTIONS_WINDOW_OFFSET_Y;
                  this._actions.addChild(b);
                  for(k = 1; k <= 2; k++)
                  {
                     s = b["pose" + k + "Btn"];
                     s.buttonMode = true;
                     s.useHandCursor = true;
                     s.mouseChildren = false;
                     s.tabEnabled = true;
                     s.tabChildren = false;
                     s.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
                  }
               }
               else if(i >= ACTIONS_NUM_LAND_BTNS + ACTIONS_NUM_POSE_BTNS)
               {
                  b.visible = false;
                  if(i == this.actionSprites.length - 1)
                  {
                     this._actions.diveBtn = b;
                  }
                  else
                  {
                     this._actions.swirlBtn = b;
                  }
                  b.x = ACTIONS_MARGIN_LEFT + ((i - 5) % ACTIONS_ROW_MAX * ACTIONS_STEP_H + ACTIONS_WINDOW_OFFSET_X);
                  b.y = ACTIONS_MARGIN_TOP + Math.floor((i - 5) / ACTIONS_ROW_MAX) * ACTIONS_STEP_V + ACTIONS_WINDOW_OFFSET_Y_SIT;
                  this._actions.addChild(b);
                  b.buttonMode = true;
                  b.useHandCursor = true;
                  b.mouseChildren = false;
                  b.tabEnabled = true;
                  b.tabChildren = false;
                  b.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
               }
            }
         }
         b = GETDEFINITIONBYNAME("playPetAnim_btnCont");
         b.y = -31;
         b.buttonMode = true;
         b.useHandCursor = true;
         b.mouseChildren = false;
         b.tabEnabled = true;
         b.tabChildren = false;
         b.addEventListener(MouseEvent.MOUSE_DOWN,this.onPetPlayBtn,false,0,true);
         this._petActions.addChild(b);
         b = GETDEFINITIONBYNAME("dancePetAnim_btnCont");
         this._petActions.danceBtn = b;
         b.y = 31;
         b.buttonMode = true;
         b.useHandCursor = true;
         b.mouseChildren = false;
         b.tabEnabled = true;
         b.tabChildren = false;
         b.addEventListener(MouseEvent.MOUSE_DOWN,this.actionClickHandler,false,0,true);
         this._petActions.addChild(b);
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
      
      private function setupTitleBanner() : void
      {
         var titleBanner:Sprite = GETDEFINITIONBYNAME("AnimsTitleBanner");
         titleBanner.x = -91.75;
         titleBanner.y = -91.25;
         this.actionWindow.addChild(titleBanner);
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
      
      public function getActionString(action:Sprite) : String
      {
         var actionString:String = action["constructor"].toString();
         var index:String = actionString.slice(7,actionString.length - 1);
         if(Boolean(this.actionStrings[index]))
         {
            if(this.actionStrings[index].length > 1)
            {
               return this.actionStrings[actionString.slice(7,actionString.length - 1)][AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? 0 : 1];
            }
            return this.actionStrings[actionString.slice(7,actionString.length - 1)][0];
         }
         return null;
      }
      
      public function matchActionString(actionStr:String) : Sprite
      {
         var asprs:String = null;
         var index:int = 0;
         for each(asprs in this.actionSprites)
         {
            index = int(this.actionStrings[asprs].indexOf(actionStr));
            if(index != -1)
            {
               if(this.actionStrings[asprs].length <= 1)
               {
                  return GETDEFINITIONBYNAME(asprs);
               }
               if(AvatarManager.roomEnviroType == Utility.ENVIRO_LAND ? index == 0 : index == 1)
               {
                  return GETDEFINITIONBYNAME(asprs);
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
         if(Boolean(this._gameTab))
         {
            this._gameTab.gameCancelTabBtn.visible = false;
         }
      }
      
      public function grayOutPetDanceBtn(b:Boolean) : void
      {
         if(Boolean(this._petActions))
         {
            this._petActions.danceBtn.activateGrayState(b);
         }
      }
      
      private function actionBtnDownHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!m.currentTarget.isGray)
         {
            if(this.actionWindow.visible)
            {
               this.closeActions();
            }
            else
            {
               if(this.safeChatTree.visible)
               {
                  this.safeChatBtn.dispatchEvent(m);
               }
               if(this.emoteWindow.visible)
               {
                  this.emoteBtn.dispatchEvent(m);
               }
               this.openActions();
            }
         }
      }
      
      private function onGameTab(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(!evt.currentTarget.isGray)
         {
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
                  if(Boolean(this._pvpScrollBar))
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
      }
      
      private function onCancelGameTab(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         evt.currentTarget.visible = false;
         UserCommXtCommManager.sendCustomPVPMessage(false,MinigameManager.minigameInfoCache.currMinigameId);
         MinigameManager.readySelfForCustomPVPGame(-1,"");
      }
      
      private function openSideMenu(sideMenu:MovieClip) : void
      {
         if(!this._isGameTabOpen)
         {
            new GTween(sideMenu,0.5,{"x":sideMenu.x + 175},{
               "ease":TweenManager.quadratic,
               "onComplete":this.sideMenuComplete
            });
            this._sideMenuTweenFinished = false;
            this._isGameTabOpen = true;
            AJAudio.playBuddyCardOpen();
         }
      }
      
      private function closeSideMenu(sideMenu:MovieClip) : void
      {
         if(this._isGameTabOpen && this._sideMenuTweenFinished)
         {
            new GTween(sideMenu,0.5,{"x":sideMenu.x - 175},{
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
         if(Boolean(this._pvpScrollBar))
         {
            this._pvpScrollBar.destroy();
            this._pvpScrollBar = null;
         }
         if(Boolean(this._pvpItemWindows) && this._pvpItemWindows.numChildren > 0)
         {
            this._pvpItemWindows.destroy();
            this._pvpItemWindows = null;
         }
         var numItemsInCurrentArray:int = int(this._pvpGameList.length);
         var xCount:int = Math.min(numItemsInCurrentArray,2);
         this._pvpItemWindows = new WindowGenerator();
         this._pvpItemWindows.init(xCount,xCount,numItemsInCurrentArray,2,2,0,ItemWindowGame,null,"",{
            "mouseDown":this.sideMenuMouseDown,
            "mouseOver":this.sideMenuMouseOver,
            "mouseOut":this.winMouseOut
         },null,null,false,false);
         this._gameTab.itemWindow.addChild(this._pvpItemWindows);
         this._pvpScrollBar = new SBScrollbar();
         this._pvpScrollBar.init(this._pvpItemWindows,155,156,10,"scrollbar2",78,0,Math.ceil(numItemsInCurrentArray / xCount) * 78);
      }
      
      private function getPVPIcons() : void
      {
         var pvpGameHelper:MediaHelper = null;
         this._views = new Array();
         for(var i:int = 0; i < this._pvpGameList.length; i++)
         {
            pvpGameHelper = new MediaHelper();
            pvpGameHelper.init(this._pvpGameList[i].gameCardMediaId,this.mediaHelperCallback,true);
            this._views[i] = pvpGameHelper;
         }
      }
      
      private function mediaHelperCallback(img:MovieClip) : void
      {
         var mc:MovieClip = null;
         for(var i:int = 0; i < this._views.length; i++)
         {
            if(this._views[i] == img.mediaHelper)
            {
               mc = MovieClip(this._pvpItemWindows.bg.getChildAt(i));
               mc.itemLayer.addChild(img);
            }
         }
      }
      
      private function sideMenuComplete(tween:GTween) : void
      {
         this._sideMenuTweenFinished = true;
      }
      
      private function sideMenuMouseDown(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         if(MinigameManager.minigameInfoCache.currMinigameId == this._pvpGameList[evt.currentTarget.index].gameDefId)
         {
            UserCommXtCommManager.sendCustomPVPMessage(false,this._pvpGameList[evt.currentTarget.index].gameDefId);
            MinigameManager.readySelfForCustomPVPGame(-1,"");
            this._gameTab.gameCancelTabBtn.visible = false;
         }
         else
         {
            UserCommXtCommManager.sendCustomPVPMessage(true,this._pvpGameList[evt.currentTarget.index].gameDefId);
            MinigameManager.readySelfForCustomPVPGame(this._pvpGameList[evt.currentTarget.index].gameDefId,"");
            this._gameTab.gameCancelTabBtn.visible = true;
         }
         this.closeActions();
      }
      
      private function sideMenuMouseOver(evt:MouseEvent) : void
      {
         var globalPoint:Point = null;
         evt.stopPropagation();
         if(this._sideMenuTweenFinished)
         {
            globalPoint = evt.currentTarget.localToGlobal(new Point(0,0));
            GuiManager.toolTip.init(this.actionWindow,LocalizationManager.translateIdOnly(this._pvpGameList[evt.currentTarget.index].titleStrId),globalPoint.x - this.actionWindow.x + this.actionWindow.hudGameTab.x + this.actionWindow.hudGameTab.itemWindow.x - evt.currentTarget.width,globalPoint.y - this.actionWindow.y + evt.currentTarget.height + this._gameTab.y);
            GuiManager.toolTip.startTimer(evt);
            AJAudio.playSubMenuBtnRollover();
         }
      }
      
      private function winMouseOut(evt:MouseEvent) : void
      {
         evt.stopPropagation();
         GuiManager.toolTip.resetTimerAndSetVisibility();
      }
      
      private function actionClickHandler(m:MouseEvent) : void
      {
         m.stopPropagation();
         if(!this.actionBtn.isGray && !m.currentTarget.isGray)
         {
            this.setActionCallback(new m.target.constructor());
            this.actionBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
            m.currentTarget.downToUpState();
         }
      }
      
      private function onPetPlayBtn(m:MouseEvent) : void
      {
         var myPet:WorldPet = null;
         m.stopPropagation();
         if(Boolean(AvatarManager.playerAvatarWorldView))
         {
            myPet = AvatarManager.playerAvatarWorldView.getActivePet();
            if(Boolean(myPet))
            {
               AvatarManager.playerAvatarWorldView.faceAnim(0,0,false);
               myPet.onClick(m);
            }
         }
         this.actionBtn.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN));
         m.currentTarget.downToUpState();
      }
   }
}

