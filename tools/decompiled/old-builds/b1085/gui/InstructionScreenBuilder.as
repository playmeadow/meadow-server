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
      
      public static function init(param1:DisplayLayer) : void
      {
         guiLayer = param1;
         instrScreenContent = GETDEFINITIONBYNAME("InstructionsContent");
         instrScreenContent.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,backHandler,false,0,true);
         instrScreenContent.backToMainBtn.addEventListener(MouseEvent.MOUSE_DOWN,backBtnHandlerOnFirstScreen,false,0,true);
         instrScreenContent.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,nextHandler,false,0,true);
         instrObjs = new Object();
         var _loc2_:Object = instrObjs["Pachinko"] = new Object();
         _loc2_.name = 11284;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11285;
         _loc2_.instrTxts[1] = 11286;
         _loc2_ = instrObjs["MiniGame_Memory"] = new Object();
         _loc2_.name = 11287;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11288;
         _loc2_.instrTxts[1] = 11289;
         _loc2_ = instrObjs["MoatMadness"] = new Object();
         _loc2_.name = 11290;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11291;
         _loc2_.instrTxts[1] = 11292;
         _loc2_ = instrObjs["ParachuteGlider"] = new Object();
         _loc2_.name = 11293;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11294;
         _loc2_.instrTxts[1] = 11295;
         _loc2_ = instrObjs["QuestParachuteGlider"] = new Object();
         _loc2_.name = 11293;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11294;
         _loc2_.instrTxts[1] = 11295;
         _loc2_ = instrObjs["Trivia"] = new Object();
         _loc2_.name = 11299;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11297;
         _loc2_.instrTxts[1] = 11298;
         _loc2_ = instrObjs["PhantomFighter"] = new Object();
         _loc2_.name = 11300;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11301;
         _loc2_.instrTxts[1] = 11302;
         _loc2_ = instrObjs["SpiderShooter"] = new Object();
         _loc2_.name = 11303;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11304;
         _loc2_.instrTxts[1] = 11305;
         _loc2_ = instrObjs["RiverRace"] = new Object();
         _loc2_.name = 11306;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11307;
         _loc2_.instrTxts[1] = 11308;
         _loc2_ = instrObjs["WindRider"] = new Object();
         _loc2_.name = 11309;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11310;
         _loc2_.instrTxts[1] = 11311;
         _loc2_ = instrObjs["DistanceChallenge"] = new Object();
         _loc2_.name = 11312;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11313;
         _loc2_.instrTxts[1] = 11314;
         _loc2_ = instrObjs["Twister"] = new Object();
         _loc2_.name = 11315;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11316;
         _loc2_.instrTxts[1] = 11317;
         _loc2_ = instrObjs["MicroMiraSays"] = new Object();
         _loc2_.name = 11318;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11319;
         _loc2_.instrTxts[1] = 11320;
         _loc2_ = instrObjs["GemBreaker"] = new Object();
         _loc2_.name = 11321;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11322;
         _loc2_.instrTxts[1] = 11323;
         _loc2_ = instrObjs["SuperSort"] = new Object();
         _loc2_.name = 11324;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11325;
         _loc2_.instrTxts[1] = 11326;
         _loc2_ = instrObjs["TowerDefense"] = new Object();
         _loc2_.name = 11327;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11328;
         _loc2_.instrTxts[1] = 11329;
         _loc2_ = instrObjs["FortSmasher"] = new Object();
         _loc2_.name = 11330;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11331;
         _loc2_.instrTxts[1] = 11332;
         _loc2_ = instrObjs["PillBugs"] = new Object();
         _loc2_.name = 11333;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11334;
         _loc2_.instrTxts[1] = 11335;
         _loc2_ = instrObjs["FeedingFrenzy"] = new Object();
         _loc2_.name = 11336;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11337;
         _loc2_.instrTxts[1] = 11338;
         _loc2_ = instrObjs["PhantomsTreasure"] = new Object();
         _loc2_.name = 11339;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11340;
         _loc2_.instrTxts[1] = 11341;
         _loc2_ = instrObjs["FashionShow"] = new Object();
         _loc2_.name = 11342;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11343;
         _loc2_.instrTxts[1] = 11344;
         _loc2_ = instrObjs["Adventure"] = new Object();
         _loc2_.name = "Adventure";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n TBD.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Just Play!";
         _loc2_ = instrObjs["HorseRace"] = new Object();
         _loc2_.name = 11348;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11349;
         _loc2_.instrTxts[1] = 11350;
         _loc2_ = instrObjs["FallingPhantoms"] = new Object();
         _loc2_.name = 11351;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11352;
         _loc2_.instrTxts[1] = 11353;
         _loc2_ = instrObjs["HedgeHog"] = new Object();
         _loc2_.name = 11354;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11355;
         _loc2_.instrTxts[1] = 11356;
         _loc2_ = instrObjs["DolphinRace"] = new Object();
         _loc2_.name = 11357;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 11358;
         _loc2_.instrTxts[1] = 11359;
         _loc2_ = instrObjs["EagleFlap"] = new Object();
         _loc2_.name = 15735;
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = 15740;
         _loc2_.instrTxts[1] = 15741;
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
      
      public static function build(param1:String, param2:SBPopup, param3:Function) : void
      {
         _joinGamePopup = param2;
         _killJoinGamePopup = true;
         if(param3 != null)
         {
            _startGameFunction = param3;
         }
         instrScreenContent.startBtn.visible = false;
         if(instrPopup)
         {
            guiLayer.setChildIndex(instrPopup,guiLayer.numChildren - 1);
            return;
         }
         instrInfo = instrObjs[param1];
         if(instrInfo == null)
         {
            throw new Error("InstructionScreenBuilder could not find instrObjs[\"" + param1 + "\"]!");
         }
         instrInfo.displayName = param1;
         numScreens = instrInfo.instrTxts.length;
         currScreen = 0;
         updateInstrScreen();
         instrPopup = new SBPopup(guiLayer,GETDEFINITIONBYNAME("InstructionsSkin"),instrScreenContent,true,true,true,false,true);
         instrPopup.closeCallback = closeHandler;
      }
      
      private static function startGameHandler(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
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
      
      public static function backHandler(param1:MouseEvent) : void
      {
         if(currScreen > 0)
         {
            --currScreen;
            updateInstrScreen();
            return;
         }
         throw new Error("Tried to go back on first instr screen!");
      }
      
      public static function nextHandler(param1:MouseEvent) : void
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
         instrScreenContent.gameInstr.gameInstrTxt.text = instrInfo.instrTxts[currScreen];
         LocalizationManager.translateId(instrScreenContent.gameInstr.gameInstrTxt,instrInfo.instrTxts[currScreen]);
         var _loc1_:int = 0;
         while(_loc1_ < instrScreenContent.instrImg.numChildren)
         {
            instrScreenContent.instrImg.getChildAt(_loc1_).visible = false;
            _loc1_++;
         }
         if(instrScreenContent.instrImg[instrInfo.name + currScreen])
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
      
      private static function backBtnHandlerOnFirstScreen(param1:MouseEvent) : void
      {
         if(param1)
         {
            param1.stopPropagation();
         }
         _killJoinGamePopup = false;
         _joinGamePopup.visible = true;
         instrPopup.soundEnabled = false;
         instrPopup.destroy();
         instrPopup = null;
      }
   }
}

