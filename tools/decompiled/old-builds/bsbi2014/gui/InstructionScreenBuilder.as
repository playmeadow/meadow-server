package gui
{
   import com.sbi.popup.SBPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import localization.LocalizationManager;
   
   public class InstructionScreenBuilder
   {
      
      public static var guiLayer:DisplayLayer;
      
      public static var instrScreenContent:MovieClip;
      
      public static var instrInfo:Object;
      
      public static var instrObjs:Object;
      
      public static var numScreens:uint;
      
      public static var currScreen:uint;
      
      public static var instrPopup:SBPopup;
      
      private static var _joinGamePopup:SBPopup;
      
      private static var _killJoinGamePopup:Boolean;
      
      private static var _startGameFunction:Function;
      
      public function InstructionScreenBuilder()
      {
         super();
      }
      
      public static function init(initGuiLayer:DisplayLayer) : void
      {
         guiLayer = initGuiLayer;
         instrScreenContent = GETDEFINITIONBYNAME("InstructionsContent");
         instrScreenContent.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,backHandler,false,0,true);
         instrScreenContent.backToMainBtn.addEventListener(MouseEvent.MOUSE_DOWN,backBtnHandlerOnFirstScreen,false,0,true);
         instrScreenContent.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,nextHandler,false,0,true);
         instrObjs = new Object();
         var instrObj:Object = instrObjs["Pachinko"] = new Object();
         instrObj.name = 11284;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11285;
         instrObj.instrTxts[1] = 11286;
         instrObj = instrObjs["MiniGame_Memory"] = new Object();
         instrObj.name = 11287;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11288;
         instrObj.instrTxts[1] = 11289;
         instrObj = instrObjs["MoatMadness"] = new Object();
         instrObj.name = 11290;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11291;
         instrObj.instrTxts[1] = 11292;
         instrObj = instrObjs["ParachuteGlider"] = new Object();
         instrObj.name = 11293;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11294;
         instrObj.instrTxts[1] = 11295;
         instrObj = instrObjs["QuestParachuteGlider"] = new Object();
         instrObj.name = 11293;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11294;
         instrObj.instrTxts[1] = 11295;
         instrObj = instrObjs["Trivia"] = new Object();
         instrObj.name = 11299;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11297;
         instrObj.instrTxts[1] = 11298;
         instrObj = instrObjs["PhantomFighter"] = new Object();
         instrObj.name = 11300;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11301;
         instrObj.instrTxts[1] = 11302;
         instrObj = instrObjs["SpiderShooter"] = new Object();
         instrObj.name = 11303;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11304;
         instrObj.instrTxts[1] = 11305;
         instrObj = instrObjs["RiverRace"] = new Object();
         instrObj.name = 11306;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11307;
         instrObj.instrTxts[1] = 11308;
         instrObj = instrObjs["WindRider"] = new Object();
         instrObj.name = 11309;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11310;
         instrObj.instrTxts[1] = 11311;
         instrObj = instrObjs["DistanceChallenge"] = new Object();
         instrObj.name = 11312;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11313;
         instrObj.instrTxts[1] = 11314;
         instrObj = instrObjs["Twister"] = new Object();
         instrObj.name = 11315;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11316;
         instrObj.instrTxts[1] = 11317;
         instrObj = instrObjs["MicroMiraSays"] = new Object();
         instrObj.name = 11318;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11319;
         instrObj.instrTxts[1] = 11320;
         instrObj = instrObjs["GemBreaker"] = new Object();
         instrObj.name = 11321;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11322;
         instrObj.instrTxts[1] = 11323;
         instrObj = instrObjs["SuperSort"] = new Object();
         instrObj.name = 11324;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11325;
         instrObj.instrTxts[1] = 11326;
         instrObj = instrObjs["TowerDefense"] = new Object();
         instrObj.name = 11327;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11328;
         instrObj.instrTxts[1] = 11329;
         instrObj = instrObjs["FortSmasher"] = new Object();
         instrObj.name = 11330;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11331;
         instrObj.instrTxts[1] = 11332;
         instrObj = instrObjs["PillBugs"] = new Object();
         instrObj.name = 11333;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11334;
         instrObj.instrTxts[1] = 11335;
         instrObj = instrObjs["FeedingFrenzy"] = new Object();
         instrObj.name = 11336;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11337;
         instrObj.instrTxts[1] = 11338;
         instrObj = instrObjs["PhantomsTreasure"] = new Object();
         instrObj.name = 11339;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11340;
         instrObj.instrTxts[1] = 11341;
         instrObj = instrObjs["FashionShow"] = new Object();
         instrObj.name = 11342;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11343;
         instrObj.instrTxts[1] = 11344;
         instrObj = instrObjs["Adventure"] = new Object();
         instrObj.name = "Adventure";
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = "\nHOW TO PLAY\n\n TBD.";
         instrObj.instrTxts[1] = "\nHINT!\n\n Just Play!";
         instrObj = instrObjs["HorseRace"] = new Object();
         instrObj.name = 11348;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11349;
         instrObj.instrTxts[1] = 11350;
         instrObj = instrObjs["FallingPhantoms"] = new Object();
         instrObj.name = 11351;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11352;
         instrObj.instrTxts[1] = 11353;
         instrObj = instrObjs["HedgeHog"] = new Object();
         instrObj.name = 11354;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11355;
         instrObj.instrTxts[1] = 11356;
         instrObj = instrObjs["DolphinRace"] = new Object();
         instrObj.name = 11357;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 11358;
         instrObj.instrTxts[1] = 11359;
         instrObj = instrObjs["EagleFlap"] = new Object();
         instrObj.name = 15735;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 15740;
         instrObj.instrTxts[1] = 15741;
         instrObj = instrObjs["SpotOn"] = new Object();
         instrObj.name = 19654;
         instrObj.instrTxts = [];
         instrObj.instrTxts[0] = 19686;
         instrObj.instrTxts[1] = 19687;
      }
      
      public static function destroy() : void
      {
         instrScreenContent.backBtn.removeEventListener(MouseEvent.MOUSE_DOWN,backHandler);
         instrScreenContent.nextBtn.removeEventListener(MouseEvent.MOUSE_DOWN,nextHandler);
         instrScreenContent = null;
      }
      
      public static function getCurrentScreen() : uint
      {
         return currScreen;
      }
      
      public static function build(gameName:String, joinGamePopup:SBPopup, startGame:Function) : void
      {
         _joinGamePopup = joinGamePopup;
         _killJoinGamePopup = true;
         if(startGame != null)
         {
            _startGameFunction = startGame;
         }
         instrScreenContent.startBtn.visible = false;
         if(Boolean(instrPopup))
         {
            guiLayer.setChildIndex(instrPopup,guiLayer.numChildren - 1);
            return;
         }
         instrInfo = instrObjs[gameName];
         if(instrInfo == null)
         {
            throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + gameName + "\"]!");
         }
         instrInfo.displayName = gameName;
         numScreens = instrInfo.instrTxts.length;
         currScreen = 0;
         updateInstrScreen();
         instrPopup = new SBPopup(guiLayer,GETDEFINITIONBYNAME("InstructionsSkin"),instrScreenContent,true,true,true,false,true);
         instrPopup.closeCallback = closeHandler;
      }
      
      private static function startGameHandler(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         if(_startGameFunction != null)
         {
            closeHandler();
            _startGameFunction(null);
         }
      }
      
      public static function closeHandler() : void
      {
         if(_killJoinGamePopup)
         {
            _joinGamePopup.destroy();
            _joinGamePopup = null;
            _killJoinGamePopup = false;
         }
         instrPopup.destroy();
         instrPopup = null;
      }
      
      public static function backHandler(m:MouseEvent) : void
      {
         if(currScreen > 0)
         {
            --currScreen;
            updateInstrScreen();
            return;
         }
         throw new Error("Tried to go back on first instr screen!");
      }
      
      public static function nextHandler(m:MouseEvent) : void
      {
         if(currScreen < numScreens - 1)
         {
            ++currScreen;
            updateInstrScreen();
            return;
         }
         throw new Error("Tried to go next on last instr screen!");
      }
      
      public static function updateInstrScreen() : void
      {
         LocalizationManager.translateId(instrScreenContent.gameName.gameNameTxt,instrObjs[instrInfo.displayName].name);
         LocalizationManager.translateId(instrScreenContent.gameInstr.gameInstrTxt,instrInfo.instrTxts[currScreen]);
         for(var hac:int = 0; hac < instrScreenContent.instrImg.numChildren; hac++)
         {
            instrScreenContent.instrImg.getChildAt(hac).visible = false;
         }
         if(Boolean(instrScreenContent.instrImg[instrInfo.name + currScreen]))
         {
            instrScreenContent.instrImg[instrInfo.name + currScreen].visible = true;
         }
         if(currScreen == 0)
         {
            if(numScreens > 1)
            {
               instrScreenContent.nextBtn.visible = true;
               instrScreenContent.nextTxt.visible = true;
            }
            else
            {
               instrScreenContent.nextBtn.visible = false;
               instrScreenContent.nextTxt.visible = false;
            }
            instrScreenContent.backToMainBtn.visible = true;
            instrScreenContent.backBtn.visible = false;
         }
         else if(currScreen == numScreens - 1)
         {
            instrScreenContent.backBtn.visible = true;
            instrScreenContent.backTxt.visible = true;
            instrScreenContent.nextBtn.visible = false;
            instrScreenContent.nextTxt.visible = false;
            instrScreenContent.backToMainBtn.visible = false;
         }
         else
         {
            instrScreenContent.backBtn.visible = true;
            instrScreenContent.backTxt.visible = true;
            instrScreenContent.nextBtn.visible = true;
            instrScreenContent.nextTxt.visible = true;
            instrScreenContent.backToMainBtn.visible = false;
         }
         instrScreenContent.page.pageTxt.text = currScreen + 1 + " / " + numScreens;
         instrScreenContent.nextTxt.visible = false;
         instrScreenContent.backTxt.visible = false;
      }
      
      private static function backBtnHandlerOnFirstScreen(m:MouseEvent) : void
      {
         if(Boolean(m))
         {
            m.stopPropagation();
         }
         _killJoinGamePopup = false;
         _joinGamePopup.visible = true;
         instrPopup.soundEnabled = false;
         instrPopup.destroy();
         instrPopup = null;
      }
   }
}

