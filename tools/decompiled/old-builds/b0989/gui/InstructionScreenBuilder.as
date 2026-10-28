package gui
{
   import com.sbi.popup.SBPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
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
         instrScreenContent = new (getDefinitionByName("InstructionsContent") as Class)();
         instrScreenContent.backBtn.addEventListener(MouseEvent.MOUSE_DOWN,backHandler,false,0,true);
         instrScreenContent.backToMainBtn.addEventListener(MouseEvent.MOUSE_DOWN,backBtnHandlerOnFirstScreen,false,0,true);
         instrScreenContent.nextBtn.addEventListener(MouseEvent.MOUSE_DOWN,nextHandler,false,0,true);
         instrObjs = new Object();
         var _loc2_:Object = instrObjs["Pachinko"] = new Object();
         _loc2_.name = "Gem Ball";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click or hold the mouse button to shoot a ball.\n\n Shooting a ball into a sun lights it up.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Light up all three suns to earn a gem BONUS!";
         _loc2_ = instrObjs["MiniGame_Memory"] = new Object();
         _loc2_.name = "Double Up";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click on a hole to see the animal hiding there.\n\n Find a match for each animal to win gems.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Find all the matches before time runs out and earn a gem BONUS!";
         _loc2_ = instrObjs["MoatMadness"] = new Object();
         _loc2_.name = "Overflow";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click on pieces to rotate them.\n\n Create a path to your castle.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Create longer paths to earn more gems!";
         _loc2_ = instrObjs["ParachuteGlider"] = new Object();
         _loc2_.name = "Wind Rider";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to avoid phantoms.\n\n Collect as many gems as you can along the way.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Reach the ground without hitting a phantom to earn            a gem BONUS!";
         _loc2_ = instrObjs["FashionShow"] = new Object();
         _loc2_.name = "Fashion Show";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Answer trivia questions to earn gems.\n\n Use the mouse to select the correct answer.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Answers questions quickly to earn more gems!";
         _loc2_ = instrObjs["Trivia"] = new Object();
         _loc2_.name = "Temple of Trivia";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Answer trivia questions to earn gems.\n\n Use the mouse to select the correct answer.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Answers questions quickly to earn more gems!";
         _loc2_ = instrObjs["PhantomFighter"] = new Object();
         _loc2_.name = "Phantom Fighter";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to move your ship.\n\n Press the spacebar to blast the phantoms.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Red phantoms have to be hit more than once.";
         _loc2_ = instrObjs["SpiderShooter"] = new Object();
         _loc2_.name = "Spider Zapper";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click on spiders to zap them.\n\n Zapping more spiders earns you more gems.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Zap every spider in a round to earn a gem BONUS!";
         _loc2_ = instrObjs["RiverRace"] = new Object();
         _loc2_.name = "River Race";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to move your boat.\n\n Rapids give your boat a speed boost.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Cross the finish line first to earn a gem BONUS!";
         _loc2_ = instrObjs["WindRider"] = new Object();
         _loc2_.name = "Sky High";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to bounce off the clouds.\n\n Clouds disappear after you jump on them.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Reach the top to find a treasure chest full of gems!";
         _loc2_ = instrObjs["DistanceChallenge"] = new Object();
         _loc2_.name = "Long Shot";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click the mouse to fling the armadillo.\n\n Click at the right time to launch it even farther.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Land on the geysers and moles to get an extra boost of speed!";
         _loc2_ = instrObjs["Twister"] = new Object();
         _loc2_.name = "Twister";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Move the mouse to guide your bird.\n\n Avoid buildings and debris to escape the twister.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Fly through the rings to get a score BONUS!";
         _loc2_ = instrObjs["MicroMiraSays"] = new Object();
         _loc2_.name = "Mira Says";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Copy the pattern of colors and sounds.\n\n The more you match, the longer the pattern gets.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Copy the pattern quickly for more points!";
         _loc2_ = instrObjs["GemBreaker"] = new Object();
         _loc2_.name = "Gem Breaker";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Match 3 gems to knock them down.\n\n Break gems above phantoms to clear them.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Break 5 or more gems to make a combo and earn a point BONUS!";
         _loc2_ = instrObjs["SuperSort"] = new Object();
         _loc2_.name = "Super Sort";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to move the paddle.\n\n Sort the items into the correct bins.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Sort all the items correctly for a gem BONUS!";
         _loc2_ = instrObjs["TowerDefense"] = new Object();
         _loc2_.name = "Pest Control";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n To stop pests, place defenders along the path.\n\n Pests that escape will damage your health.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Extra tokens will award you a gem BONUS!";
         _loc2_ = instrObjs["FortSmasher"] = new Object();
         _loc2_.name = "Fruit Slinger";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click and drag the mouse to aim the slingshot.\n\n Destroy all the phantoms in a fort to win.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Different types of fruit have different abilities!";
         _loc2_ = instrObjs["PillBugs"] = new Object();
         _loc2_.name = "Pill Bugs";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Move and click the mouse to aim and shoot.\n\n Leftover pill bugs earn you a score BONUS!";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Hit every ladybug in a level to earn a bronze, silver or gold bug!";
         _loc2_ = instrObjs["FeedingFrenzy"] = new Object();
         _loc2_.name = "Eat \'Em Up";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Move the mouse to guide your fish.\n\n Eat smaller fish and avoid bigger fish.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Earn an extra life by catching the squid!";
         _loc2_ = instrObjs["PhantomsTreasure"] = new Object();
         _loc2_.name = "Phantom\'s Treasure";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click the mouse to find hidden objects.\n\n Find all the objects quickly for more points.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Leftover hints will earn you a score BONUS!";
         _loc2_ = instrObjs["FashionShow"] = new Object();
         _loc2_.name = "Best Dressed";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Dress in the best clothes to match the theme.\n\n Vote on the best dressed Jammer.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Remember to change your colors, eyes, and patterns too!";
         _loc2_ = instrObjs["Adventure"] = new Object();
         _loc2_.name = "Adventure";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n TBD.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Just Play!";
         _loc2_ = instrObjs["HorseRace"] = new Object();
         _loc2_.name = "Horse Race";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Click on the screen to jump over obstacles.\n\nClick the boost button to go extra fast.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Be sure to time your jumps right to clear all the obstacles!";
         _loc2_ = instrObjs["FallingPhantoms"] = new Object();
         _loc2_.name = "Falling Phantoms";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to avoid the phantoms.\n\nOutlast all your opponents to win!";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Last until the time runs out to earn a gem BONUS!";
         _loc2_ = instrObjs["HedgeHog"] = new Object();
         _loc2_.name = "Hedge Hog";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to get all the berries.\n\nWatch out for the pesky phantoms.";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Get a POWER CRYSTAL to catch the phantoms!";
         _loc2_ = instrObjs["DolphinRace"] = new Object();
         _loc2_.name = "Splash and Dash";
         _loc2_.instrTxts = [];
         _loc2_.instrTxts[0] = "\nHOW TO PLAY\n\n Use the arrow keys to avoid obstacles.\n\nGo through three rings to get a speed boost!";
         _loc2_.instrTxts[1] = "\nHINT!\n\n Win 10 races to unlock PRO MODE!";
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
         instrPopup = new SBPopup(guiLayer,new (getDefinitionByName("InstructionsSkin") as Class)(),instrScreenContent,true,true,true,false,true);
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
         instrScreenContent.gameName.gameNameTxt.text = instrObjs[instrInfo.displayName].name;
         instrScreenContent.gameInstr.gameInstrTxt.text = instrInfo.instrTxts[currScreen];
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

