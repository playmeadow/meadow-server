package gui
{
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import game.MinigameManager;
   import game.MinigameXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class GameCardPopup
   {
      
      private static var instrObjs:Object;
      
      private static const LEADERBOARD_TYPE_ALLTIME:int = 1;
      
      private static const LEADERBOARD_TYPE_THISWEEK:int = 2;
      
      private static const LEADERBOARD_TYPE_BUDDY:int = 3;
      
      private var _onStartClicked:Function;
      
      private var _thePopup:MovieClip;
      
      private var _mediaHelper:MediaHelper;
      
      private var _parent:DisplayObjectContainer;
      
      private var _gameCard:Sprite;
      
      private var _onInstrClicked:Function;
      
      private var _onCloseCallback:Function;
      
      private var _showProModeBtn:Boolean;
      
      private var _proModeValue:Number;
      
      private var _isMultiplayer:Boolean;
      
      private var _originalBX:int;
      
      private var _joinGamePopup:MovieClip;
      
      private var _instructionsPopup:MovieClip;
      
      private var _instrInfo:Object;
      
      private var _numScreens:int;
      
      private var _currScreen:int;
      
      private var _gameName:String;
      
      private var _leaderBoardCache:Dictionary;
      
      private var _joinGameObj:Object;
      
      private var _showLeaderBoard:Boolean;
      
      public function GameCardPopup(param1:DisplayObjectContainer, param2:Object, param3:Function, param4:Function)
      {
         super();
         DarkenManager.showLoadingSpiral(true);
         this._parent = param1;
         this._joinGameObj = param2;
         this._gameCard = param2.mi.gameCardScreen;
         this._onStartClicked = param3;
         this._onCloseCallback = param4;
         var _loc5_:int = int(this._joinGameObj.mi.proModeUserVarRefId);
         this._showProModeBtn = _loc5_ > 0;
         this._proModeValue = gMainFrame.userInfo.userVarCache.getUserVarValueById(_loc5_);
         this._isMultiplayer = this._joinGameObj.mi.maxPlayers > 1;
         this._gameName = this._joinGameObj.swfName;
         this._showLeaderBoard = false;
         if(instrObjs == null)
         {
            this.setupInstructions();
         }
         this._mediaHelper = new MediaHelper();
         this._mediaHelper.init(3754,this.onGameCardLoaded);
      }
      
      public function destroy() : void
      {
         this.removeEventListeners();
         this._mediaHelper.destroy();
         this._mediaHelper = null;
         DarkenManager.unDarken(this._thePopup);
         this._parent.removeChild(this._thePopup);
         this._thePopup = null;
      }
      
      private function setupInstructions() : void
      {
         instrObjs = new Object();
         var _loc1_:Object = instrObjs["Pachinko"] = new Object();
         _loc1_.name = 11284;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11285;
         _loc1_.instrTxts[1] = 11286;
         _loc1_ = instrObjs["MiniGame_Memory"] = new Object();
         _loc1_.name = 11287;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11288;
         _loc1_.instrTxts[1] = 11289;
         _loc1_ = instrObjs["MoatMadness"] = new Object();
         _loc1_.name = 11290;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11291;
         _loc1_.instrTxts[1] = 11292;
         _loc1_ = instrObjs["ParachuteGlider"] = new Object();
         _loc1_.name = 11293;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11294;
         _loc1_.instrTxts[1] = 11295;
         _loc1_ = instrObjs["QuestParachuteGlider"] = new Object();
         _loc1_.name = 11293;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11294;
         _loc1_.instrTxts[1] = 11295;
         _loc1_ = instrObjs["Trivia"] = new Object();
         _loc1_.name = 11299;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11297;
         _loc1_.instrTxts[1] = 11298;
         _loc1_ = instrObjs["PhantomFighter"] = new Object();
         _loc1_.name = 11300;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11301;
         _loc1_.instrTxts[1] = 11302;
         _loc1_ = instrObjs["SpiderShooter"] = new Object();
         _loc1_.name = 11303;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11304;
         _loc1_.instrTxts[1] = 11305;
         _loc1_ = instrObjs["RiverRace"] = new Object();
         _loc1_.name = 11306;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11307;
         _loc1_.instrTxts[1] = 11308;
         _loc1_ = instrObjs["WindRider"] = new Object();
         _loc1_.name = 11309;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11310;
         _loc1_.instrTxts[1] = 11311;
         _loc1_ = instrObjs["DistanceChallenge"] = new Object();
         _loc1_.name = 11312;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11313;
         _loc1_.instrTxts[1] = 11314;
         _loc1_ = instrObjs["Twister"] = new Object();
         _loc1_.name = 11315;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11316;
         _loc1_.instrTxts[1] = 11317;
         _loc1_ = instrObjs["MicroMiraSays"] = new Object();
         _loc1_.name = 11318;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11319;
         _loc1_.instrTxts[1] = 11320;
         _loc1_ = instrObjs["GemBreaker"] = new Object();
         _loc1_.name = 11321;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11322;
         _loc1_.instrTxts[1] = 11323;
         _loc1_ = instrObjs["SuperSort"] = new Object();
         _loc1_.name = 11324;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11325;
         _loc1_.instrTxts[1] = 11326;
         _loc1_ = instrObjs["TowerDefense"] = new Object();
         _loc1_.name = 11327;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11328;
         _loc1_.instrTxts[1] = 11329;
         _loc1_ = instrObjs["FortSmasher"] = new Object();
         _loc1_.name = 11330;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11331;
         _loc1_.instrTxts[1] = 11332;
         _loc1_ = instrObjs["PillBugs"] = new Object();
         _loc1_.name = 11333;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11334;
         _loc1_.instrTxts[1] = 11335;
         _loc1_ = instrObjs["FeedingFrenzy"] = new Object();
         _loc1_.name = 11336;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11337;
         _loc1_.instrTxts[1] = 11338;
         _loc1_ = instrObjs["PhantomsTreasure"] = new Object();
         _loc1_.name = 11339;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11340;
         _loc1_.instrTxts[1] = 11341;
         _loc1_ = instrObjs["FashionShow"] = new Object();
         _loc1_.name = 11342;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11343;
         _loc1_.instrTxts[1] = 11344;
         _loc1_ = instrObjs["Adventure"] = new Object();
         _loc1_.name = "Adventure";
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = "\nHOW TO PLAY\n\n TBD.";
         _loc1_.instrTxts[1] = "\nHINT!\n\n Just Play!";
         _loc1_ = instrObjs["HorseRace"] = new Object();
         _loc1_.name = 11348;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11349;
         _loc1_.instrTxts[1] = 11350;
         _loc1_ = instrObjs["FallingPhantoms"] = new Object();
         _loc1_.name = 11351;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11352;
         _loc1_.instrTxts[1] = 11353;
         _loc1_ = instrObjs["HedgeHog"] = new Object();
         _loc1_.name = 11354;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11355;
         _loc1_.instrTxts[1] = 11356;
         _loc1_ = instrObjs["DolphinRace"] = new Object();
         _loc1_.name = 11357;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 11358;
         _loc1_.instrTxts[1] = 11359;
         _loc1_ = instrObjs["EagleFlap"] = new Object();
         _loc1_.name = 15735;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 15740;
         _loc1_.instrTxts[1] = 15741;
         _loc1_ = instrObjs["SpotOn"] = new Object();
         _loc1_.name = 19654;
         _loc1_.instrTxts = [];
         _loc1_.instrTxts[0] = 19686;
         _loc1_.instrTxts[1] = 19687;
      }
      
      private function onGameCardLoaded(param1:MovieClip) : void
      {
         this._thePopup = MovieClip(param1.getChildAt(0));
         this._joinGamePopup = this._thePopup.joinGame;
         this._instructionsPopup = this._thePopup.instructions;
         this.addEventListeners();
         if(this._joinGamePopup.msg)
         {
            this._joinGamePopup.msg.visible = false;
         }
         this._instructionsPopup.visible = false;
         this._joinGamePopup.visible = true;
         if(this._joinGamePopup.hasOwnProperty("gameTitle") && this._gameCard != null)
         {
            this._joinGamePopup.gameTitle.addChild(this._gameCard);
         }
         if(this._isMultiplayer && !Utility.canMultiplayer())
         {
            this._joinGamePopup.startBtn.activateGrayState(true);
            this._joinGamePopup.proStartBtn.activateGrayState(true);
         }
         if(this._showProModeBtn)
         {
            this._joinGamePopup.gotoAndPlay("pro");
            if(this._proModeValue <= 0)
            {
               this._joinGamePopup.proStartBtn.activateGrayState(true);
            }
         }
         this._thePopup.x = MainFrame.VIEW_WIDTH * 0.5;
         this._thePopup.y = MainFrame.VIEW_HEIGHT * 0.5;
         this._originalBX = this._thePopup.bx.y;
         DarkenManager.showLoadingSpiral(false);
         this._parent.addChild(this._thePopup);
         DarkenManager.darken(this._thePopup);
      }
      
      private function getVisibleLeaderBoard() : int
      {
         if(this._thePopup.leaderboards_popup.thisWeekUp.visible)
         {
            return LEADERBOARD_TYPE_THISWEEK;
         }
         if(this._thePopup.leaderboards_popup.allTimeUp.visible)
         {
            return LEADERBOARD_TYPE_ALLTIME;
         }
         return LEADERBOARD_TYPE_BUDDY;
      }
      
      private function addEventListeners() : void
      {
         this._thePopup.addEventListener(MouseEvent.MOUSE_DOWN,this.onPopup,false,0,true);
         this._thePopup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.onClose,false,0,true);
         this._joinGamePopup.startBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked,false,0,true);
         this._joinGamePopup.proStartBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked,false,0,true);
         this._joinGamePopup.instrBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.onInstructionsClicked,false,0,true);
         if(this._showLeaderBoard)
         {
            this._joinGamePopup.leaderboardsButton.gotoAndStop("active");
            this._joinGamePopup.leaderboards_popup.thisWeekDown.addEventListener(MouseEvent.MOUSE_DOWN,this.thisWeekClicked,false,0,true);
            this._joinGamePopup.leaderboards_popup.buddiesDown.addEventListener(MouseEvent.MOUSE_DOWN,this.buddiesClicked,false,0,true);
            this._joinGamePopup.leaderboards_popup.allTimeDown.addEventListener(MouseEvent.MOUSE_DOWN,this.allTimeClicked,false,0,true);
            this._joinGamePopup.leaderboards_popup.bx.addEventListener(MouseEvent.MOUSE_DOWN,this.leaderBoardBXClicked,false,0,true);
            this._joinGamePopup.leaderboardsButton.btn.addEventListener(MouseEvent.MOUSE_DOWN,this.leaderBoardClicked,false,0,true);
         }
         this._instructionsPopup.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.backHandler,false,0,true);
         this._instructionsPopup.backToMainBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.backBtnHandlerOnFirstScreen,false,0,true);
         this._instructionsPopup.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,this.nextHandler,false,0,true);
      }
      
      private function removeEventListeners() : void
      {
         this._thePopup.removeEventListener(MouseEvent.MOUSE_DOWN,this.onPopup);
         this._thePopup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.onClose);
         this._joinGamePopup.startBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked);
         this._joinGamePopup.proStartBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onAnyStartClicked);
         this._joinGamePopup.instrBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.onInstructionsClicked);
         if(this._showLeaderBoard)
         {
            this._joinGamePopup.leaderboards_popup.thisWeekDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.thisWeekClicked);
            this._joinGamePopup.leaderboards_popup.buddiesDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.buddiesClicked);
            this._joinGamePopup.leaderboards_popup.allTimeDown.removeEventListener(MouseEvent.MOUSE_DOWN,this.allTimeClicked);
            this._joinGamePopup.leaderboards_popup.bx.removeEventListener(MouseEvent.MOUSE_DOWN,this.leaderBoardBXClicked);
            this._joinGamePopup.leaderboardsButton.btn.removeEventListener(MouseEvent.MOUSE_DOWN,this.leaderBoardClicked);
         }
         this._instructionsPopup.backBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.backHandler);
         this._instructionsPopup.backToMainBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.backBtnHandlerOnFirstScreen);
         this._instructionsPopup.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,this.nextHandler);
      }
      
      private function onClose(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._onCloseCallback != null)
         {
            this._onCloseCallback();
         }
         else
         {
            this.destroy();
         }
      }
      
      private function thisWeekClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._joinGamePopup.leaderboards_popup.thisWeekUp.visible = true;
         this._joinGamePopup.leaderboards_popup.allTimeUp.visible = false;
         this._joinGamePopup.leaderboards_popup.buddiesUp.visible = false;
         this.onLeaderBoardSelected();
      }
      
      private function buddiesClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._joinGamePopup.leaderboards_popup.thisWeekUp.visible = false;
         this._joinGamePopup.leaderboards_popup.allTimeUp.visible = false;
         this._joinGamePopup.leaderboards_popup.buddiesUp.visible = true;
         this.onLeaderBoardSelected();
      }
      
      private function allTimeClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._joinGamePopup.leaderboards_popup.thisWeekUp.visible = false;
         this._joinGamePopup.leaderboards_popup.allTimeUp.visible = true;
         this._joinGamePopup.leaderboards_popup.buddiesUp.visible = false;
         this.onLeaderBoardSelected();
      }
      
      private function leaderBoardClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._joinGamePopup.leaderboardsButton.gotoAndPlay("off");
         this._joinGamePopup.gotoAndPlay("normal_l");
         this._joinGamePopup.gotoAndPlay("pro_l");
         this._thePopup.bx.y = -1000;
         if(this._joinGameObj != null && this._joinGameObj.typeDefId != -1)
         {
            this.onLeaderBoardSelected();
         }
      }
      
      private function leaderBoardBXClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._joinGamePopup.leaderboardsButton.gotoAndPlay("on");
         this._joinGamePopup.gotoAndPlay("normal_l_close");
         this._joinGamePopup.gotoAndPlay("pro_l_close");
         this._thePopup.bx.y = this._originalBX;
      }
      
      public function onLeaderBoardSelected() : void
      {
         if(this._thePopup != null && this._joinGameObj != null && this._joinGameObj.typeDefId != -1)
         {
            this._leaderBoardCache = MinigameManager.getLeaderBoardCache();
            if(this._leaderBoardCache[this._joinGameObj.typeDefId] != null && getTimer() - this._leaderBoardCache[this._joinGameObj.typeDefId]._cacheTime < 60000)
            {
               switch(this.getVisibleLeaderBoard())
               {
                  case LEADERBOARD_TYPE_ALLTIME:
                     this.populateLeaderBoard(this._leaderBoardCache[this._joinGameObj.typeDefId]._allTime);
                     break;
                  case LEADERBOARD_TYPE_BUDDY:
                     this.populateLeaderBoard(this._leaderBoardCache[this._joinGameObj.typeDefId]._buddy);
                     break;
                  case LEADERBOARD_TYPE_THISWEEK:
                     this.populateLeaderBoard(this._leaderBoardCache[this._joinGameObj.typeDefId]._thisWeek);
               }
            }
            else
            {
               this.populateLeaderBoard(null);
               DarkenManager.showLoadingSpiral(true);
               MinigameXtCommManager.sendMinigameLeaderboardRequest(this._joinGameObj.typeDefId);
            }
         }
      }
      
      private function populateLeaderBoard(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(param1 != null && param1.length > 0)
         {
            if(param1[0]._score != -1)
            {
               this._joinGamePopup.leaderboards_popup["p11"].text = param1[0]._name;
               this._joinGamePopup.leaderboards_popup["s11"].text = param1[0]._score;
            }
            else
            {
               this._joinGamePopup.leaderboards_popup["p11"].text = "";
               this._joinGamePopup.leaderboards_popup["s11"].text = "";
            }
            _loc2_ = 1;
            while(_loc2_ < 11)
            {
               if(_loc2_ < param1.length)
               {
                  this._joinGamePopup.leaderboards_popup["p" + _loc2_].text = param1[_loc2_]._name;
                  this._joinGamePopup.leaderboards_popup["s" + _loc2_].text = param1[_loc2_]._score;
                  if(param1[_loc2_]._name == param1[0]._name)
                  {
                     this._joinGamePopup.leaderboards_popup["p" + _loc2_].textColor = 26265;
                     this._joinGamePopup.leaderboards_popup["s" + _loc2_].textColor = 26265;
                  }
                  else
                  {
                     this._joinGamePopup.leaderboards_popup["p" + _loc2_].textColor = 4137240;
                     this._joinGamePopup.leaderboards_popup["s" + _loc2_].textColor = 4137240;
                  }
               }
               else
               {
                  this._joinGamePopup.leaderboards_popup["p" + _loc2_].text = "";
                  this._joinGamePopup.leaderboards_popup["s" + _loc2_].text = "";
               }
               _loc2_++;
            }
         }
         else
         {
            _loc2_ = 1;
            while(_loc2_ <= 11)
            {
               this._joinGamePopup.leaderboards_popup["p" + _loc2_].text = "";
               this._joinGamePopup.leaderboards_popup["s" + _loc2_].text = "";
               _loc2_++;
            }
         }
      }
      
      private function onAnyStartClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(param1.currentTarget.isGray)
         {
            return;
         }
         if(param1.currentTarget.name == "startBtn")
         {
            this._onStartClicked(0);
         }
         else if(param1.currentTarget.name == "proStartBtn")
         {
            this._onStartClicked(1);
         }
      }
      
      private function onInstructionsClicked(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._instructionsPopup.visible = true;
         this._joinGamePopup.visible = false;
         this._instructionsPopup.startBtn.visible = false;
         this._instrInfo = instrObjs[this._gameName];
         if(this._instrInfo == null)
         {
            throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + this._gameName + "\"]!");
         }
         this._instrInfo.displayName = this._gameName;
         this._numScreens = this._instrInfo.instrTxts.length;
         this._currScreen = 0;
         this.updateInstrScreen();
      }
      
      private function onPopup(param1:MouseEvent) : void
      {
         param1.stopPropagation();
      }
      
      private function backHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currScreen > 0)
         {
            --this._currScreen;
            this.updateInstrScreen();
            return;
         }
         throw new Error("Tried to go back on first instr screen!");
      }
      
      private function nextHandler(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         if(this._currScreen < this._numScreens - 1)
         {
            ++this._currScreen;
            this.updateInstrScreen();
            return;
         }
         throw new Error("Tried to go next on last instr screen!");
      }
      
      private function backBtnHandlerOnFirstScreen(param1:MouseEvent) : void
      {
         param1.stopPropagation();
         this._instructionsPopup.visible = false;
         this._joinGamePopup.visible = true;
      }
      
      private function updateInstrScreen() : void
      {
         LocalizationManager.translateId(this._instructionsPopup.gameName.gameNameTxt,instrObjs[this._instrInfo.displayName].name);
         LocalizationManager.translateId(this._instructionsPopup.gameInstr.gameInstrTxt,this._instrInfo.instrTxts[this._currScreen]);
         var _loc1_:int = 0;
         while(_loc1_ < this._instructionsPopup.instrImg.numChildren)
         {
            this._instructionsPopup.instrImg.getChildAt(_loc1_).visible = false;
            _loc1_++;
         }
         if(this._instructionsPopup.instrImg[this._instrInfo.name + this._currScreen])
         {
            this._instructionsPopup.instrImg[this._instrInfo.name + this._currScreen].visible = true;
         }
         if(this._currScreen == 0)
         {
            if(this._numScreens > 1)
            {
               this._instructionsPopup.nextBtn.visible = true;
               this._instructionsPopup.nextTxt.visible = true;
            }
            else
            {
               this._instructionsPopup.nextBtn.visible = false;
               this._instructionsPopup.nextTxt.visible = false;
            }
            this._instructionsPopup.backToMainBtn.visible = true;
            this._instructionsPopup.backBtn.visible = false;
         }
         else if(this._currScreen == this._numScreens - 1)
         {
            this._instructionsPopup.backBtn.visible = true;
            this._instructionsPopup.backTxt.visible = true;
            this._instructionsPopup.nextBtn.visible = false;
            this._instructionsPopup.nextTxt.visible = false;
            this._instructionsPopup.backToMainBtn.visible = false;
         }
         else
         {
            this._instructionsPopup.backBtn.visible = true;
            this._instructionsPopup.backTxt.visible = true;
            this._instructionsPopup.nextBtn.visible = true;
            this._instructionsPopup.nextTxt.visible = true;
            this._instructionsPopup.backToMainBtn.visible = false;
         }
         this._instructionsPopup.page.pageTxt.text = this._currScreen + 1 + " / " + this._numScreens;
         this._instructionsPopup.nextTxt.visible = false;
         this._instructionsPopup.backTxt.visible = false;
      }
   }
}

