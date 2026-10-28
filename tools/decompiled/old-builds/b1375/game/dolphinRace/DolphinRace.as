package game.dolphinRace
{
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import collection.IitemCollection;
   import com.sbi.corelib.audio.SBMusic;
   import com.sbi.corelib.math.RandomSeed;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.media.SoundChannel;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import item.Item;
   import item.ItemXtCommManager;
   import loader.MediaHelper;
   import localization.LocalizationManager;
   
   public class DolphinRace extends GameBase implements IMinigame
   {
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const MAX_PLAYERS:int = 4;
      
      private static const STATE_LOADING_ASSETS:int = 0;
      
      private static const STATE_LOADING_ITEMLISTS:int = 1;
      
      private static const STATE_WAITING_FOR_START:int = 2;
      
      private static const STATE_RACE_INTRO:int = 3;
      
      private static const STATE_WAITING_FOR_INTRO_COMPLETE:int = 4;
      
      public static const STATE_RACING:int = 5;
      
      private static const STATE_RACE_RESULTS:int = 7;
      
      private static const STARTING_Y:Number = 261.95;
      
      private static const ACCESSORY_LIST_OCEAN:int = 91;
      
      public var _proMode:int;
      
      public var _gameState:int = 0;
      
      private var _dolphinRaceData:DolphinRaceData;
      
      private var _displayAchievementTimer:Number;
      
      public var _messageServer:Function;
      
      public var _leaveMinigame:Function;
      
      public var _myId:uint;
      
      public var _pIDs:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _availableItems:Array;
      
      public var _availableItemColors:Array;
      
      public var _layerBackgroundGround:Sprite;
      
      public var _layerMidGUI:Sprite;
      
      public var _layerLaneTextures:Sprite;
      
      public var _layerHurdles:Sprite;
      
      public var _layerPlayer:Sprite;
      
      public var _layerPlayers:Array;
      
      public var _layerAIPlayers:Array;
      
      private var _lastTime:Number;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _gameRandomizer:RandomSeed;
      
      public var _raceRandomizer:RandomSeed;
      
      private var _numPlayers:uint;
      
      private var _newPlayersJoined:Boolean = false;
      
      private var _aiplayers:Array;
      
      private var _players:Array;
      
      public var _myPlayer:DolphinRacePlayer;
      
      private var _trackPositions:Array;
      
      private var _ripples:Array;
      
      private var _theTrack:MovieClip;
      
      public var _theHurdles:Array;
      
      private var _nextHurdleIndex:int;
      
      public var _aiProfileHard:DolphinRaceAIProfile = new DolphinRaceAIProfile(100,0,175);
      
      public var _aiProfileMed:DolphinRaceAIProfile = new DolphinRaceAIProfile(75,0.5,200);
      
      public var _aiProfileEasy:DolphinRaceAIProfile = new DolphinRaceAIProfile(50,1,200);
      
      public var _aiProfiles:Array = [_aiProfileHard,_aiProfileMed,_aiProfileEasy];
      
      private var _upArrow:Boolean;
      
      private var _downArrow:Boolean;
      
      private var _gameGUI:Object;
      
      public var _startingLineX:int;
      
      public var _waitingPopup:MovieClip;
      
      public var _countdownTimer:Number;
      
      public var _lastEmoteTimer:Number;
      
      public var _raceResultsTimer:Number;
      
      public var _trackLength:int;
      
      public var _debugText:TextField;
      
      public var _totalConsecutiveWins:int;
      
      private var _gemsEarned:int;
      
      private var _resultsPopup:MovieClip;
      
      public var _factsOrder:Array;
      
      public var _factsIndex:int;
      
      private var _mediaObjectHelper:MediaHelper;
      
      private var _loadingImage:Boolean;
      
      private var _factImageMediaObject:MovieClip;
      
      private var _trackIndexOverride:int;
      
      private const _audio:Array = ["aj_popUp.mp3","aj_PopUp_ReadySet.mp3","aj_PopUp_Go.mp3","aj_dolphinSwim.mp3","aj_dolphinWaterEnter.mp3","aj_dolphinWaterExit.mp3","aj_dr_ballChain.mp3","aj_dr_imp_buoyLarge.mp3","aj_dr_imp_buoySmall_1.mp3","aj_dr_imp_buoySmall_2.mp3","aj_dr_imp_seagull_1.mp3","aj_dr_imp_seagull_2.mp3","aj_dr_imp_seagull_3.mp3","aj_dr_rockslide.mp3","aj_dr_imp_buoyMed.mp3","aj_dr_ringStinger.mp3","aj_dr_turbo.mp3","aj_popUp.mp3","aj_popUp.mp3","aj_popUp.mp3"];
      
      internal var _soundNameAJPopUp:String = _audio[0];
      
      internal var _soundNameAJPopUpReadySet:String = _audio[1];
      
      internal var _soundNameAJPopUpGo:String = _audio[2];
      
      internal var _soundNameAJDolphinSwim:String = _audio[3];
      
      internal var _soundNameAJDolphinWaterEnter:String = _audio[4];
      
      internal var _soundNameAJDolphinWaterExit:String = _audio[5];
      
      internal var _soundNameAJDRBallChain:String = _audio[6];
      
      internal var _soundNameAJDRImpBuoyLarge:String = _audio[7];
      
      internal var _soundNameAJDRImpBuoySmall1:String = _audio[8];
      
      internal var _soundNameAJDRImpBuoySmall2:String = _audio[9];
      
      internal var _soundNameAJDRImpSeagull1:String = _audio[10];
      
      internal var _soundNameAJDRImpSeagull2:String = _audio[11];
      
      internal var _soundNameAJDRImpSeagull3:String = _audio[12];
      
      internal var _soundNameAJDRRockslide:String = _audio[13];
      
      internal var _soundNameAJDRImpBuoyMed:String = _audio[14];
      
      internal var _soundNameAJDRRingStinger:String = _audio[15];
      
      internal var _soundNameAJDRTurbo:String = _audio[16];
      
      public var _soundMan:SoundManager;
      
      public var _SFX_Music:SBMusic;
      
      public var _SFX_StartMusic:SBMusic;
      
      public var _SFX_EndMusic:SBMusic;
      
      public var _SFX_StartSwim:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function DolphinRace()
      {
         super();
         _displayAchievementTimer = 0;
         _dolphinRaceData = new DolphinRaceData();
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("aj_mus_dolphin",0.8);
         _SFX_StartMusic = _soundMan.addStream("aj_dr_musIntro",0.8);
         _SFX_StartSwim = _soundMan.addStream("aj_dolphinSwimIntro",0.2);
         _SFX_EndMusic = _soundMan.addStream("aj_dr_musOutro",0.8);
         _soundMan.addSoundByName(_audioByName[_soundNameAJPopUp],_soundNameAJPopUp,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameAJPopUpReadySet],_soundNameAJPopUpReadySet,0.3);
         _soundMan.addSoundByName(_audioByName[_soundNameAJPopUpGo],_soundNameAJPopUpGo,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDolphinSwim],_soundNameAJDolphinSwim,0.1);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDolphinWaterEnter],_soundNameAJDolphinWaterEnter,0.21);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDolphinWaterExit],_soundNameAJDolphinWaterExit,0.21);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRBallChain],_soundNameAJDRBallChain,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpBuoyLarge],_soundNameAJDRImpBuoyLarge,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpBuoySmall1],_soundNameAJDRImpBuoySmall1,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpBuoySmall2],_soundNameAJDRImpBuoySmall2,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpSeagull1],_soundNameAJDRImpSeagull1,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpSeagull2],_soundNameAJDRImpSeagull2,0.4);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpSeagull3],_soundNameAJDRImpSeagull3,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRRockslide],_soundNameAJDRRockslide,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRImpBuoyMed],_soundNameAJDRImpBuoyMed,0.35);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRRingStinger],_soundNameAJDRRingStinger,0.25);
         _soundMan.addSoundByName(_audioByName[_soundNameAJDRTurbo],_soundNameAJDRTurbo,0.3);
      }
      
      public function start(param1:uint, param2:Array, param3:Function, param4:Function) : void
      {
         _myId = param1;
         _pIDs = param2;
         _messageServer = param3;
         _leaveMinigame = param4;
         _numPlayers = param2.length;
         init();
      }
      
      public function end(param1:Array) : void
      {
         var _loc2_:int = 0;
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         if(_resultsPopup)
         {
            _guiLayer.removeChild(_resultsPopup);
            _resultsPopup = null;
         }
         while(_players.length > 0)
         {
            if(_players[0] != null)
            {
               _players[0].remove();
            }
            _players.splice(0,1);
         }
         while(_aiplayers.length > 0)
         {
            if(_aiplayers[0] != null)
            {
               _aiplayers[0].remove();
            }
            _aiplayers.splice(0,1);
         }
         releaseBase();
         _bInit = false;
         _loc2_ = 0;
         while(_loc2_ < _availableItems.length)
         {
            if(_availableItems[_loc2_])
            {
               _availableItems[_loc2_].destroy();
               _availableItems[_loc2_] = null;
            }
            _loc2_++;
         }
         removeLayer(_layerMidGUI);
         removeLayer(_layerBackgroundGround);
         removeLayer(_layerLaneTextures);
         removeLayer(_layerHurdles);
         removeLayer(_layerPlayer);
         removeLayer(_guiLayer);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("keyUp",keyHandleUp);
         stage.removeEventListener("keyDown",keyHandleDown);
         stage.removeEventListener("mouseDown",mouseHandleDown);
         if(_leaveMinigame != null)
         {
            _leaveMinigame(false);
         }
      }
      
      public function randomizeArray(param1:Array) : Array
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:* = undefined;
         var _loc5_:Number = param1.length - 1;
         _loc2_ = 0;
         while(_loc2_ < _loc5_)
         {
            _loc3_ = Math.round(Math.random() * _loc5_);
            _loc4_ = param1[_loc2_];
            param1[_loc2_] = param1[_loc3_];
            param1[_loc3_] = _loc4_;
            _loc2_++;
         }
         return param1;
      }
      
      public function updatePearl(param1:int) : void
      {
         _gameGUI.loader.content.pearl.pearl(param1);
      }
      
      private function init() : void
      {
         var _loc1_:int = 0;
         _gemsEarned = 0;
         _upArrow = false;
         _downArrow = false;
         _lastEmoteTimer = 0;
         _displayAchievementTimer = 0;
         _totalConsecutiveWins = 0;
         _factsOrder = [];
         _loc1_ = 0;
         while(_loc1_ < _dolphinRaceData._facts.length)
         {
            _factsOrder.push(_loc1_);
            _loc1_++;
         }
         _factsOrder = randomizeArray(_factsOrder);
         _factsIndex = 0;
         if(!_bInit)
         {
            _factImageMediaObject = null;
            _mediaObjectHelper = null;
            _loadingImage = false;
            _resultsPopup = null;
            _layerMidGUI = new Sprite();
            _layerBackgroundGround = new Sprite();
            _layerLaneTextures = new Sprite();
            _layerHurdles = new Sprite();
            _layerPlayer = new Sprite();
            _layerPlayers = new Array(4);
            _layerAIPlayers = new Array(4);
            _loc1_ = 0;
            while(_loc1_ < 4)
            {
               _layerPlayers[_loc1_] = new Sprite();
               _layerPlayer.addChild(_layerPlayers[_loc1_]);
               _layerAIPlayers[_loc1_] = new Sprite();
               _layerPlayer.addChild(_layerAIPlayers[_loc1_]);
               _loc1_++;
            }
            if(_numPlayers <= 0 || _numPlayers > 4)
            {
               throw new Error("Illegal number of players! numPlayers:" + _numPlayers);
            }
            _layerMidGUI.mouseEnabled = true;
            _layerBackgroundGround.mouseEnabled = false;
            _layerHurdles.mouseEnabled = false;
            _layerLaneTextures.mouseEnabled = false;
            _layerPlayer.mouseEnabled = false;
            _guiLayer = new Sprite();
            addChild(_layerBackgroundGround);
            addChild(_layerLaneTextures);
            addChild(_layerHurdles);
            addChild(_layerMidGUI);
            addChild(_layerPlayer);
            addChild(_guiLayer);
            _aiplayers = new Array(4);
            _players = new Array(4);
            loadScene("DolphinRace/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      public function loadNextFactImage() : void
      {
         if(!_loadingImage)
         {
            _factsIndex = _factsIndex + 1;
            if(_factsIndex >= _factsOrder.length)
            {
               _factsIndex = 0;
            }
            _loadingImage = true;
            if(_mediaObjectHelper != null)
            {
               _mediaObjectHelper.destroy();
            }
            _mediaObjectHelper = new MediaHelper();
            _mediaObjectHelper.init(_dolphinRaceData._facts[_factsOrder[_factsIndex]].imageID,mediaObjectLoaded);
         }
      }
      
      private function mediaObjectLoaded(param1:MovieClip) : void
      {
         if(_factImageMediaObject != null && _resultsPopup)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
         }
         param1.x = 0;
         param1.y = 0;
         _factImageMediaObject = param1;
         if(_resultsPopup)
         {
            _resultsPopup.result_pic.addChild(_factImageMediaObject);
         }
         _loadingImage = false;
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc4_:int = 0;
         var _loc3_:Object = null;
         var _loc2_:* = null;
         _soundMan = new SoundManager(this);
         loadSounds();
         _debugText = new TextField();
         _debugText.text = "";
         _debugText.x = 20;
         _debugText.y = 20;
         _debugText.width = 300;
         _loc3_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",847,1,onCloseButton);
         _loc3_ = _scene.getLayer("dolphinRace_emoButton_cool");
         addBtn("DolphinRace_emoButton_cool",_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,onEmoteCoolButton);
         _loc3_ = _scene.getLayer("dolphinRace_emoButton_sneaky");
         addBtn("DolphinRace_emoButton_sneaky",_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,onEmoteSneakyButton);
         _loc3_ = _scene.getLayer("dolphinRace_emoButton_wink");
         addBtn("DolphinRace_emoButton_wink",_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,onEmoteWinkButton);
         _loc3_ = _scene.getLayer("dolphinRace_emoButton_tongue");
         addBtn("DolphinRace_emoButton_tongue",_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,onEmoteTongueButton);
         _loc3_ = _scene.getLayer("dolphinRace_emoButton_surprise");
         addBtn("DolphinRace_emoButton_surprise",_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,onEmoteSurpriseButton);
         _loc3_ = _scene.getLayer("dolphinRace_emoButton_sleep");
         addBtn("DolphinRace_emoButton_sleep",_loc3_.x + _loc3_.width / 2,_loc3_.y + _loc3_.height / 2,onEmoteSleepButton);
         _trackPositions = [];
         _ripples = [];
         _loc3_ = _scene.getLayer("track");
         _theTrack = _loc3_.loader.content;
         _theTrack.startLineContainer.x = 280;
         _trackIndexOverride = -1;
         _trackPositions.push(_loc3_.loader.content.dolphin1.container);
         _trackPositions.push(_loc3_.loader.content.dolphin2.container);
         _trackPositions.push(_loc3_.loader.content.dolphin3.container);
         _trackPositions.push(_loc3_.loader.content.dolphin4.container);
         _ripples.push(_loc3_.loader.content.ripples1);
         _ripples.push(_loc3_.loader.content.ripples2);
         _ripples.push(_loc3_.loader.content.ripples3);
         _ripples.push(_loc3_.loader.content.ripples4);
         _layerBackgroundGround.addChild(_loc3_.loader.content);
         _sceneLoaded = true;
         stage.addEventListener("keyDown",keyHandleDown);
         stage.addEventListener("keyUp",keyHandleUp);
         stage.addEventListener("enterFrame",heartbeat,false,0,true);
         stage.addEventListener("mouseDown",mouseHandleDown);
         _waitingPopup = GETDEFINITIONBYNAME("dolphinRace_waiting");
         _waitingPopup.x = 450;
         _waitingPopup.y = 275;
         _waitingPopup.gotoAndPlay("waiting");
         _guiLayer.addChild(_waitingPopup);
         startGame();
         super.sceneLoaded(param1);
      }
      
      public function setWaterEffectVisibility(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            _theTrack["zoom" + param1].visible = true;
            _theTrack["ripples" + param1].visible = true;
         }
         else
         {
            _theTrack["zoom" + param1].visible = false;
            _theTrack["ripples" + param1].visible = false;
         }
      }
      
      public function boost(param1:int, param2:Boolean) : void
      {
         if(param2)
         {
            _theTrack["zoom" + param1].boostOn();
         }
         else
         {
            _theTrack["zoom" + param1].boostOff();
         }
      }
      
      public function inMotionEffects() : void
      {
         var _loc1_:int = 0;
         _theTrack.inMotionEffects();
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            _ripples[_loc1_].splash.visible = true;
            _ripples[_loc1_].effects.visible = true;
            _loc1_++;
         }
      }
      
      public function noMotionEffects() : void
      {
         _theTrack.noMotionEffects();
      }
      
      public function message(param1:Array) : void
      {
         var _loc18_:* = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc3_:int = 0;
         var _loc16_:int = 0;
         var _loc22_:int = 0;
         var _loc7_:int = 0;
         var _loc15_:int = 0;
         var _loc21_:* = 0;
         var _loc2_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc13_:int = 0;
         var _loc8_:DisplayObject = null;
         var _loc20_:int = 0;
         var _loc19_:int = 0;
         var _loc12_:int = 0;
         var _loc28_:int = 0;
         var _loc26_:int = 0;
         var _loc17_:int = 0;
         var _loc5_:int = 0;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc14_:int = 0;
         var _loc25_:int = 0;
         var _loc11_:int = 0;
         var _loc4_:int = 0;
         var _loc27_:int = 0;
         if(param1[0] == "ml")
         {
            _loc24_ = int(param1[2]);
            if(_players[_loc24_])
            {
               if(_gameState == 3 || _gameState == 4 || _gameState == 5)
               {
                  playerLeftGame(_loc24_);
               }
               else
               {
                  _players[_loc24_].remove();
               }
               _players[_loc24_] = null;
            }
            _numPlayers = _numPlayers - 1;
         }
         else if(param1[0] == "ms")
         {
            _loc23_ = 1;
            _loc15_ = 0;
            _proMode = parseInt(param1[_loc23_++]);
            _loc21_ = uint(parseInt(param1[_loc23_++]));
            _startingLineX = parseInt(param1[_loc23_++]);
            _gameRandomizer = new RandomSeed(_loc21_);
            _loc15_ = 0;
            while(_loc15_ < _numPlayers)
            {
               _loc2_ = param1[_loc23_++] == _myId;
               _loc24_ = int(param1[_loc23_++]);
               _players[_loc24_] = new DolphinRacePlayer(this as DolphinRace);
               _players[_loc24_].setupHumanPlayer(_loc24_,_loc2_,param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++],param1[_loc23_++]);
               if(_loc2_)
               {
                  _myPlayer = _players[_loc24_];
               }
               _newPlayersJoined = true;
               _loc15_++;
            }
            _loc6_ = Number(param1[_loc23_++]);
            _loc13_ = int(param1[_loc23_++]);
            _loc15_ = 0;
            while(_loc15_ < _loc13_)
            {
               _aiplayers[_loc15_] = new DolphinRacePlayer(this as DolphinRace);
               _aiplayers[_loc15_].setupAIPlayer(_gameRandomizer.integer(9999999),_loc15_,_startingLineX,param1[_loc23_++]);
               _loc15_++;
            }
         }
         else if(param1[0] == "mm")
         {
            _loc23_ = 3;
            if(param1[2] == "ex")
            {
               hideDlg();
               _loc8_ = showDlg("dolphinRace_error",[{
                  "name":"exitButton",
                  "f":onErrorExit
               }]);
               _loc8_.x = 450;
               _loc8_.y = 275;
            }
            else if(param1[2] == "uj")
            {
               _numPlayers = param1[_loc23_++];
               _loc20_ = 0;
               while(_loc20_ < _numPlayers)
               {
                  _loc24_ = int(param1[_loc23_++]);
                  _loc19_ = int(param1[_loc23_++]);
                  _loc12_ = int(param1[_loc23_++]);
                  _loc28_ = int(param1[_loc23_++]);
                  _loc26_ = int(param1[_loc23_++]);
                  _loc17_ = int(param1[_loc23_++]);
                  _loc5_ = int(param1[_loc23_++]);
                  _loc9_ = param1[_loc23_++];
                  _loc10_ = param1[_loc23_++];
                  _loc14_ = int(param1[_loc23_++]);
                  if(_players[_loc24_] == null)
                  {
                     _players[_loc24_] = new DolphinRacePlayer(this as DolphinRace);
                     _players[_loc24_].setupHumanPlayer(_loc24_,false,_loc19_,_loc12_,_loc28_,_loc26_,_loc17_,_loc5_,_loc9_,_loc10_,_loc14_);
                     _newPlayersJoined = true;
                  }
                  _loc20_++;
               }
            }
            else if(param1[2] == "boo")
            {
               _loc18_ = uint(int(param1[_loc23_++]));
               if(_loc18_ < 4 && _players[_loc18_] != null)
               {
                  _players[_loc18_].boost(true);
               }
            }
            else if(param1[2] == "jump")
            {
               _loc18_ = uint(int(param1[_loc23_++]));
               if(_loc18_ < 4 && _players[_loc18_] != null)
               {
                  _players[_loc18_].receiveJump(int(param1[_loc23_++]));
               }
            }
            else if(param1[2] == "dive")
            {
               _loc18_ = uint(int(param1[_loc23_++]));
               if(_loc18_ < 4 && _players[_loc18_] != null)
               {
                  _players[_loc18_].dive(true);
               }
            }
            else if(param1[2] == "fall")
            {
               _loc18_ = uint(int(param1[_loc23_++]));
               if(_loc18_ < 4 && _players[_loc18_] != null)
               {
                  _players[_loc18_].receiveFall();
               }
            }
            else if(param1[2] == "pos")
            {
               _loc18_ = uint(int(param1[_loc23_++]));
               if(_loc18_ < 4 && _players[_loc18_] != null && _players[_loc18_]._trackLayer && _players[_loc18_]._trackLayer.parent)
               {
                  _players[_loc18_].receivePositionData(int(param1[_loc23_++]),int(param1[_loc23_++]),int(param1[_loc23_++]),int(param1[_loc23_++]));
               }
            }
            else if(param1[2] == "cs")
            {
               _soundMan.playByName(_soundNameAJPopUpReadySet);
               _waitingPopup.gotoAndPlay("ready");
               _countdownTimer = 1.5;
            }
            else if(param1[2] == "em")
            {
               if(_myPlayer != null && param1[4] != _myPlayer._playerID)
               {
                  _loc16_ = 0;
                  while(_loc16_ < _players.length)
                  {
                     if(_players[_loc16_] != null && _players[_loc16_]._playerID == param1[4])
                     {
                        _players[_loc16_].showEmote(param1[3]);
                        break;
                     }
                     _loc16_++;
                  }
               }
            }
            else if(param1[2] == "ri")
            {
               _loc25_ = int(param1[_loc23_++]);
               _loc22_ = int(param1[_loc23_++]);
               _raceRandomizer = new RandomSeed(_loc25_);
               _loc16_ = 0;
               while(_loc16_ < _aiplayers.length)
               {
                  _aiplayers[_loc16_].setAIRaceRanomizer(_raceRandomizer.integer(9999999));
                  _aiplayers[_loc16_]._avatar.visible = false;
                  _loc16_++;
               }
               _loc11_ = 2;
               _loc16_ = 0;
               while(_loc16_ < _loc22_)
               {
                  _loc7_ = int(param1[_loc23_++]);
                  if(_players[_loc7_] != null)
                  {
                     if(_gameState == 7)
                     {
                        _players[_loc7_].prepareForStart(_startingLineX);
                     }
                     _players[_loc7_]._laneMarkerIndex = _players[_loc7_] == _myPlayer ? 1 : _loc11_++;
                  }
                  _loc16_++;
               }
               _loc16_ = 0;
               while(_loc16_ < _aiplayers.length)
               {
                  if(_players[_loc16_] == null || _players[_loc16_]._trackLayer == null || _players[_loc16_]._avatar.visible == false)
                  {
                     _aiplayers[_loc16_].prepareForStart(_startingLineX);
                     _aiplayers[_loc16_]._laneMarkerIndex = _loc11_++;
                  }
                  _loc16_++;
               }
               setGameState(3);
            }
            else if(param1[2] == "rs")
            {
               if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
               {
                  AchievementXtCommManager.requestSetUserVar(357,1);
               }
               _loc16_ = 0;
               while(_loc16_ < _players.length)
               {
                  if(_players[_loc16_] != null)
                  {
                     _players[_loc16_].start();
                  }
                  _loc16_++;
               }
               _loc16_ = 0;
               while(_loc16_ < _aiplayers.length)
               {
                  if(_aiplayers[_loc16_]._avatar.visible)
                  {
                     _aiplayers[_loc16_].start();
                  }
                  _loc16_++;
               }
               setGameState(5);
            }
            else if(param1[2] == "rr")
            {
               _raceResultsTimer = param1[_loc23_++];
               _raceResultsTimer += 1;
               _loc22_ = int(param1[_loc23_++]);
               _loc16_ = 0;
               while(_loc16_ < 4)
               {
                  _loc4_ = int(param1[_loc23_++]);
                  _aiplayers[_loc4_]._finishPlace = param1[_loc23_++];
                  if(_aiplayers[_loc4_]._finishPlace < 1 || _aiplayers[_loc4_]._finishPlace > 4)
                  {
                     _aiplayers[_loc4_]._finishPlace = 4;
                  }
                  _loc16_++;
               }
               _loc16_ = 0;
               while(_loc16_ < _loc22_)
               {
                  _loc18_ = uint(int(param1[_loc23_++]));
                  _loc27_ = int(param1[_loc23_++]);
                  if(_loc18_ < 4 && _players[_loc18_] != null)
                  {
                     _players[_loc18_]._finishPlace = _loc27_;
                     if(_players[_loc18_]._finishPlace < 1 || _players[_loc18_]._finishPlace > 4)
                     {
                        _players[_loc18_]._finishPlace = 4;
                     }
                  }
                  _loc16_++;
               }
               setGameState(7);
            }
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc7_:int = 0;
         var _loc5_:* = null;
         var _loc4_:DolphinRacePlayer = null;
         var _loc2_:int = 0;
         var _loc3_:Boolean = false;
         var _loc6_:int = 0;
         if(_sceneLoaded)
         {
            _frameTime = (getTimer() - _lastTime) / 1000;
            if(_frameTime > 0.5)
            {
               _frameTime = 0.5;
            }
            _lastTime = getTimer();
            if(_lastEmoteTimer > 0)
            {
               _lastEmoteTimer -= _frameTime;
            }
            if(_newPlayersJoined)
            {
               if(_gameGUI == null)
               {
                  _gameGUI = _scene.getLayer("gameGUI");
                  _layerMidGUI.addChild(_gameGUI.loader.content);
                  _gameGUI.loader.content.setType(_proMode);
               }
               _loc2_ = 0;
               _loc7_ = 0;
               while(_loc7_ < _players.length)
               {
                  if(_players[_loc7_] != null)
                  {
                     if(_players[_loc7_]._avatar == null)
                     {
                        if(_players[_loc7_]._localPlayer)
                        {
                           _players[_loc7_].init(_trackPositions[_trackPositions.length - 1],_loc7_,_ripples[_ripples.length - 1]);
                        }
                        else
                        {
                           _players[_loc7_].init(_trackPositions[_loc2_],_loc7_,_ripples[_loc2_]);
                           _loc2_++;
                        }
                        if(_gameState != 7)
                        {
                           _players[_loc7_].prepareForStart(_startingLineX);
                        }
                     }
                     else if(!_players[_loc7_]._localPlayer)
                     {
                        _loc2_++;
                     }
                  }
                  _loc7_++;
               }
               _loc2_ = 0;
               _loc7_ = 0;
               while(_loc7_ < 4)
               {
                  if(_aiplayers[_loc7_]._avatar == null)
                  {
                     if(_loc7_ < _players.length && _players[_loc7_] != null && _players[_loc7_]._localPlayer)
                     {
                        _aiplayers[_loc7_].init(_trackPositions[_trackPositions.length - 1],_loc7_,_ripples[_ripples.length - 1]);
                     }
                     else
                     {
                        _aiplayers[_loc7_].init(_trackPositions[_loc2_],_loc7_,_ripples[_loc2_]);
                        _loc2_++;
                     }
                  }
                  else if(_loc7_ < _players.length && _players[_loc7_] != null && !_players[_loc7_]._localPlayer)
                  {
                     _loc2_++;
                  }
                  _loc7_++;
               }
               _newPlayersJoined = false;
            }
            if(!_upArrow)
            {
               if(_downArrow)
               {
               }
            }
            switch(_gameState)
            {
               case 0:
                  if(_myPlayer != null && _myPlayer._animsLoaded)
                  {
                     setGameState(1);
                  }
                  break;
               case 1:
                  if(_availableItems != null)
                  {
                     setGameState(2);
                  }
                  break;
               case 2:
               case 3:
                  _loc3_ = true;
                  _loc7_ = 0;
                  while(_loc7_ < _players.length)
                  {
                     if(_players[_loc7_] != null && _players[_loc7_]._avatar != null)
                     {
                        _loc4_ = _players[_loc7_];
                        if(!_loc4_.heartbeatIntro(_frameTime))
                        {
                           _loc3_ = false;
                        }
                        if(_loc4_._localPlayer)
                        {
                           _loc4_.updateY(_frameTime);
                        }
                        else
                        {
                           _loc4_.interpolateY(_frameTime);
                        }
                     }
                     _loc7_++;
                  }
                  _loc7_ = 0;
                  while(_loc7_ < 4)
                  {
                     if(_aiplayers[_loc7_]._avatar.visible)
                     {
                        if(!_aiplayers[_loc7_].heartbeatIntro(_frameTime))
                        {
                           _loc3_ = false;
                        }
                     }
                     _loc7_++;
                  }
                  if(_gameState == 3 && _loc3_)
                  {
                     setGameState(4);
                  }
                  break;
               case 4:
                  _loc7_ = 0;
                  while(_loc7_ < _players.length)
                  {
                     if(_players[_loc7_] != null && _players[_loc7_]._avatar != null)
                     {
                        _loc4_ = _players[_loc7_];
                        if(_loc4_._localPlayer)
                        {
                           _loc4_.updateY(_frameTime);
                        }
                        else
                        {
                           _loc4_.interpolateY(_frameTime);
                        }
                     }
                     _loc7_++;
                  }
                  if(_countdownTimer > 0)
                  {
                     _countdownTimer -= _frameTime;
                     if(_countdownTimer <= 0)
                     {
                        _soundMan.playByName(_soundNameAJPopUpReadySet);
                        _waitingPopup.gotoAndPlay("set");
                     }
                  }
                  break;
               case 5:
                  _loc7_ = 0;
                  while(_loc7_ < _players.length)
                  {
                     if(_players[_loc7_] != null && _players[_loc7_]._avatar != null)
                     {
                        _loc4_ = _players[_loc7_];
                        _loc4_.heartbeat(_frameTime);
                        if(_gameGUI != null && _loc4_._laneMarkerIndex > 0 && _loc4_._laneMarkerIndex <= 4)
                        {
                           _gameGUI.loader.content["pMarker" + _loc4_._laneMarkerIndex].x = _gameGUI.loader.content.progressBar.x - _gameGUI.loader.content.progressBar.width / 2 + _gameGUI.loader.content.progressBar.width * _loc4_.percentComplete();
                        }
                     }
                     _loc7_++;
                  }
                  _loc7_ = 0;
                  while(_loc7_ < 4)
                  {
                     if(_aiplayers[_loc7_]._avatar.visible)
                     {
                        _aiplayers[_loc7_].heartbeat(_frameTime);
                        if(_gameGUI != null && _aiplayers[_loc7_]._laneMarkerIndex > 0 && _aiplayers[_loc7_]._laneMarkerIndex <= 4)
                        {
                           _gameGUI.loader.content["pMarker" + _aiplayers[_loc7_]._laneMarkerIndex].x = _gameGUI.loader.content.progressBar.x - _gameGUI.loader.content.progressBar.width / 2 + _gameGUI.loader.content.progressBar.width * _aiplayers[_loc7_].percentComplete();
                        }
                     }
                     _loc7_++;
                  }
                  if(_myPlayer._absoluteX < _trackLength + 100)
                  {
                     updateTrack(_myPlayer != null ? _myPlayer._trackX : 0);
                  }
                  break;
               case 7:
                  if(_raceResultsTimer > 1)
                  {
                     _raceResultsTimer -= _frameTime;
                     if(_raceResultsTimer <= 1)
                     {
                        _raceResultsTimer = 1;
                     }
                     if(_resultsPopup)
                     {
                        _loc6_ = _raceResultsTimer;
                        LocalizationManager.translateIdAndInsert(_resultsPopup.timerText,11431,_loc6_);
                     }
                  }
            }
            _loc7_ = 0;
            while(_loc7_ < _players.length)
            {
               if(_players[_loc7_] != null && _players[_loc7_]._avatar != null)
               {
                  _loc4_ = _players[_loc7_];
                  _loc4_._trackLayer.parent.x = _loc4_._absoluteX + _layerPlayer.x;
                  _loc4_._trackRipple.x = _loc4_._absoluteX + _layerPlayer.x;
               }
               _loc7_++;
            }
            _loc7_ = 0;
            while(_loc7_ < 4)
            {
               if(_aiplayers[_loc7_]._avatar.visible)
               {
                  _aiplayers[_loc7_]._trackLayer.parent.x = _aiplayers[_loc7_]._absoluteX + _layerPlayer.x;
                  _aiplayers[_loc7_]._trackRipple.x = _aiplayers[_loc7_]._absoluteX + _layerPlayer.x;
               }
               _loc7_++;
            }
            _gameTime += _frameTime;
            if(_displayAchievementTimer > 0)
            {
               _displayAchievementTimer -= _frameTime;
               if(_displayAchievementTimer <= 0)
               {
                  _displayAchievementTimer = 0;
                  AchievementManager.displayNewAchievements();
               }
            }
         }
      }
      
      public function startGame() : void
      {
         var _loc1_:int = 0;
         if(_sceneLoaded)
         {
         }
      }
      
      public function resetGame(param1:Boolean) : void
      {
         var _loc12_:int = 0;
         var _loc6_:DisplayObject = null;
         var _loc7_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc2_:MovieClip = null;
         var _loc10_:Array = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc3_:Array = null;
         var _loc11_:int = 0;
         var _loc5_:Array = null;
         if(_factImageMediaObject && _resultsPopup != null)
         {
            _factImageMediaObject.parent.removeChild(_factImageMediaObject);
            _factImageMediaObject = null;
         }
         if(!_loadingImage)
         {
            loadNextFactImage();
         }
         if(_resultsPopup)
         {
            _guiLayer.removeChild(_resultsPopup);
            _resultsPopup = null;
         }
         hideDlg();
         _closeBtn.x = 847;
         _closeBtn.y = 1;
         _countdownTimer = 0;
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         _nextHurdleIndex = 0;
         _theHurdles = [];
         if(_gameGUI)
         {
            _loc12_ = 1;
            while(_loc12_ <= 4)
            {
               _gameGUI.loader.content["pMarker" + _loc12_].x = _gameGUI.loader.content.progressBar.x - _gameGUI.loader.content.progressBar.width / 2;
               _loc12_++;
            }
         }
         while(_layerHurdles.numChildren > 0)
         {
            _loc6_ = _layerHurdles.getChildAt(0);
            _layerHurdles.removeChild(_loc6_);
         }
         if(_raceRandomizer != null)
         {
            _loc7_ = 1000;
            _loc4_ = GETDEFINITIONBYNAME("dolphinRace_obstacle");
            _loc2_ = GETDEFINITIONBYNAME("dolphinRace_ring");
            _loc4_.y = 261.95;
            _loc2_.y = 261.95;
            if(_proMode == 1)
            {
               if(_debugText != null)
               {
                  _debugText.text = "Pro Track Index = ";
               }
               _loc10_ = _dolphinRaceData._data.proTracks;
            }
            else
            {
               if(_debugText != null)
               {
                  _debugText.text = "Beginner Track Index = ";
               }
               _loc10_ = _dolphinRaceData._data.beginnerTracks;
            }
            if(_trackIndexOverride >= 0)
            {
               _loc8_ = _trackIndexOverride;
               _trackIndexOverride = -1;
            }
            else
            {
               _loc8_ = _raceRandomizer.integer(_loc10_.length);
            }
            if(_debugText != null)
            {
               _debugText.text += _loc8_;
            }
            _loc9_ = 0;
            while(_loc9_ < _loc10_[_loc8_].length)
            {
               _loc3_ = _dolphinRaceData._data.tiles[_loc10_[_loc8_][_loc9_]];
               _loc11_ = 0;
               while(_loc11_ < _loc3_.length)
               {
                  _loc7_ += _loc3_[_loc11_++];
                  if(_loc11_ < _loc3_.length)
                  {
                     _loc5_ = _dolphinRaceData._data.hurdles[_loc3_[_loc11_]];
                     _theHurdles.push(new DolphinRaceHurdle(this,_loc5_[0],_loc5_[1],_loc5_[2],_loc7_,_loc4_,_loc2_));
                     _loc11_++;
                  }
               }
               _loc9_++;
            }
            _trackLength = _loc7_ + 1000;
         }
         _layerLaneTextures.x = 0;
         _layerHurdles.x = 0;
         _layerPlayer.x = 0;
         _theTrack.startLineContainer.x = -100;
         addFinishBuoy(280);
         if(param1)
         {
            updateTrack(0);
         }
      }
      
      public function addFinishBuoy(param1:Number) : void
      {
         if(_theTrack.startLineContainer.x < 0)
         {
            _theTrack.startLineContainer.x = param1;
         }
      }
      
      public function updateTrack(param1:Number) : void
      {
         var _loc4_:int = 0;
         var _loc2_:DisplayObject = null;
         var _loc3_:MovieClip = null;
         _loc4_ = _layerHurdles.numChildren;
         while(_loc4_ > 0)
         {
            _loc4_--;
            _loc2_ = _layerHurdles.getChildAt(_loc4_);
            if(_loc2_.x + _layerHurdles.x < -_loc2_.width)
            {
               _layerHurdles.removeChild(_loc2_);
            }
         }
         if(_raceRandomizer != null)
         {
            _layerLaneTextures.x -= param1;
            _layerHurdles.x -= param1;
            _layerPlayer.x -= param1;
            _theTrack.moveBuoys(param1);
            if(_theTrack.startLineContainer.x > -100)
            {
               _theTrack.startLineContainer.x -= param1;
            }
            while(_nextHurdleIndex < _theHurdles.length)
            {
               if(_theHurdles[_nextHurdleIndex]._x + _layerHurdles.x >= 1000)
               {
                  break;
               }
               if(_theHurdles[_nextHurdleIndex]._type == 2)
               {
                  _loc3_ = GETDEFINITIONBYNAME("dolphinRace_obstacle");
                  _loc3_.y = 261.95;
               }
               else
               {
                  _loc3_ = GETDEFINITIONBYNAME("dolphinRace_ring");
                  _loc3_.y = _theHurdles[_nextHurdleIndex]._y;
               }
               _loc3_.x = _theHurdles[_nextHurdleIndex]._x;
               _theHurdles[_nextHurdleIndex].setHurdle(_loc3_);
               _layerHurdles.addChild(_loc3_);
               _nextHurdleIndex = _nextHurdleIndex + 1;
            }
         }
      }
      
      private function playerLeftGame(param1:int) : void
      {
         _aiplayers[param1].replacePlayer(_players[param1]);
      }
      
      private function onCloseButton() : void
      {
         _soundMan.playByName(_soundNameAJPopUp);
         var _loc1_:MovieClip = showDlg("dolphinRace_leaveGame",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_gemsEarned);
      }
      
      private function onErrorExit() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            end(null);
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function emoteButton(param1:int) : void
      {
         var _loc2_:Array = null;
         if(_lastEmoteTimer <= 0)
         {
            if(_myPlayer != null)
            {
               _myPlayer.showEmote(param1);
               _loc2_ = [];
               _loc2_[0] = "em";
               _loc2_[1] = param1;
               _loc2_[2] = _myPlayer._playerID;
               _messageServer(_loc2_);
               _lastEmoteTimer = 1;
            }
         }
      }
      
      private function onEmoteCoolButton() : void
      {
         emoteButton(1);
      }
      
      private function onEmoteSneakyButton() : void
      {
         emoteButton(2);
      }
      
      private function onEmoteWinkButton() : void
      {
         emoteButton(3);
      }
      
      private function onEmoteTongueButton() : void
      {
         emoteButton(4);
      }
      
      private function onEmoteSurpriseButton() : void
      {
         emoteButton(5);
      }
      
      private function onEmoteSleepButton() : void
      {
         emoteButton(6);
      }
      
      private function keyHandleUp(param1:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         switch(int(param1.keyCode) - 38)
         {
            case 0:
               if(_myPlayer._upArrow)
               {
                  _myPlayer._upArrow = false;
               }
               break;
            case 2:
               if(_myPlayer._downArrow)
               {
                  _myPlayer._downArrow = false;
               }
         }
      }
      
      private function debugReset() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _players.length)
         {
            if(_players[_loc1_] != null && _players[_loc1_]._avatar != null)
            {
               _players[_loc1_]._absoluteX = 5000000;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            if(_aiplayers[_loc1_]._avatar.visible)
            {
               _aiplayers[_loc1_]._absoluteX = 5000000;
            }
            _loc1_++;
         }
      }
      
      private function mouseHandleDown(param1:MouseEvent) : void
      {
      }
      
      private function keyHandleDown(param1:KeyboardEvent) : void
      {
         switch(int(param1.keyCode) - 38)
         {
            case 0:
               if(!_upArrow)
               {
                  _myPlayer._upArrow = true;
               }
               break;
            case 2:
               if(!_downArrow)
               {
                  _myPlayer._downArrow = true;
               }
         }
      }
      
      public function gotItemListCallback(param1:IitemCollection, param2:String, param3:Array = null) : void
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Item = null;
         _availableItems = new Array(param1.length);
         var _loc6_:int = 100;
         _loc4_ = 0;
         while(_loc4_ < param1.length)
         {
            _loc5_ = param1.getIitem(_loc4_) as Item;
            _availableItems[_loc4_] = new Item();
            _availableItems[_loc4_].init(_loc5_.defId,_loc6_++,_loc5_.color);
            _availableItems[_loc4_].makeSmallIcon();
            _loc4_++;
         }
         _availableItemColors = param3;
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            if(_aiplayers[_loc7_]._avatar != null)
            {
               _aiplayers[_loc7_].initFinalize();
            }
            _loc7_++;
         }
      }
      
      private function setGameState(param1:int) : void
      {
         var _loc8_:int = 0;
         var _loc7_:Array = null;
         var _loc5_:Array = null;
         var _loc4_:Object = null;
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:SoundChannel = null;
         if(_gameState != param1)
         {
            switch(param1)
            {
               case 0:
                  break;
               case 1:
                  resetGame(false);
                  ItemXtCommManager.requestShopList(gotItemListCallback,91);
                  break;
               case 2:
                  _loc7_ = [];
                  _loc7_[0] = "ready";
                  _messageServer(_loc7_);
                  _soundMan.playStream(_SFX_StartSwim);
                  _loc6_ = _soundMan.playStream(_SFX_StartMusic);
                  break;
               case 3:
                  _loc8_ = 0;
                  while(_loc8_ < 4)
                  {
                     if(_aiplayers[_loc8_]._avatar.visible)
                     {
                        _soundMan.playStream(_SFX_StartSwim);
                        break;
                     }
                     _loc8_++;
                  }
                  if(_gameState == 7)
                  {
                     _loc6_ = _soundMan.playStream(_SFX_StartMusic);
                     _soundMan.playStream(_SFX_StartSwim);
                     resetGame(true);
                  }
                  else
                  {
                     resetGame(false);
                  }
                  break;
               case 4:
                  _loc7_ = [];
                  _loc7_[0] = "intro";
                  _messageServer(_loc7_);
                  break;
               case 5:
                  inMotionEffects();
                  _soundMan.playByName(_soundNameAJPopUpGo);
                  _waitingPopup.gotoAndPlay("goOff");
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                  }
                  _musicLoop = _soundMan.playStream(_SFX_Music,0,99999);
                  break;
               case 7:
                  if(_musicLoop)
                  {
                     _musicLoop.stop();
                  }
                  _musicLoop = _soundMan.playStream(_SFX_EndMusic);
                  hideDlg();
                  _resultsPopup = showDlg("dolphinRace_results",[],450,275,false);
                  _closeBtn.parent.setChildIndex(_closeBtn,_closeBtn.parent.numChildren - 1);
                  _closeBtn.x = 790;
                  _closeBtn.y = 19;
                  if(_factImageMediaObject)
                  {
                     _resultsPopup.result_pic.addChild(_factImageMediaObject);
                  }
                  LocalizationManager.translateId(_resultsPopup.result_fact,_dolphinRaceData._facts[_factsOrder[_factsIndex]].text);
                  _loc5_ = [];
                  _loc8_ = 0;
                  while(_loc8_ < _players.length)
                  {
                     if(_players[_loc8_] != null && _players[_loc8_]._avatar != null)
                     {
                        _loc5_.push(_players[_loc8_]);
                     }
                     else if(_aiplayers[_loc8_]._avatar.visible)
                     {
                        _loc5_.push(_aiplayers[_loc8_]);
                     }
                     _loc8_++;
                  }
                  _loc5_.sortOn("_finishPlace",[16]);
                  _loc2_ = 1;
                  _loc8_ = 0;
                  while(_loc8_ < 4)
                  {
                     _loc4_ = _resultsPopup["playerTag" + (_loc8_ + 1)];
                     if(_loc8_ < _loc5_.length)
                     {
                        if(_loc8_ > 0 && _loc5_[_loc8_]._finishPlace != _loc5_[_loc8_ - 1]._finishPlace)
                        {
                           _loc2_++;
                        }
                        if(_loc5_[_loc8_] == _myPlayer)
                        {
                           _displayAchievementTimer = 3;
                           _loc4_.setInfo(1,_loc2_);
                           if(_proMode == 1 && _myPlayer._perfectRace)
                           {
                              AchievementXtCommManager.requestSetUserVar(361,1);
                           }
                           if(_loc2_ == 1)
                           {
                              _totalConsecutiveWins = _totalConsecutiveWins + 1;
                              if(_totalConsecutiveWins == 5)
                              {
                                 if(_proMode == 1)
                                 {
                                    AchievementXtCommManager.requestSetUserVar(359,1);
                                 }
                              }
                              if(_messageServer != null)
                              {
                                 if(_proMode == 1)
                                 {
                                    _messageServer(["_a",38]);
                                 }
                                 else
                                 {
                                    _messageServer(["_a",37]);
                                 }
                              }
                              if(gMainFrame.userInfo.userVarCache.getUserVarValueById(358) >= 9)
                              {
                                 AchievementXtCommManager.requestSetUserVar(362,1);
                              }
                              AchievementXtCommManager.requestSetUserVar(358,1);
                              if(_proMode == 1)
                              {
                                 AchievementXtCommManager.requestSetUserVar(360,1);
                              }
                           }
                           else
                           {
                              _totalConsecutiveWins = 0;
                           }
                        }
                        else
                        {
                           _loc4_.setInfo(0,_loc5_[_loc8_]._finishPlace);
                        }
                        _loc4_.playerName.text = LocalizationManager.translateAvatarName(_loc5_[_loc8_]._name);
                        LocalizationManager.translateIdAndInsert(_loc4_.gemsEarned,11097,0);
                        _loc3_ = 0;
                        switch(_loc2_ - 1)
                        {
                           case 0:
                              LocalizationManager.translateId(_loc4_.place,11434);
                              _loc3_ = _proMode == 1 ? 150 : 100;
                              break;
                           case 1:
                              LocalizationManager.translateId(_loc4_.place,11435);
                              _loc3_ = _proMode == 1 ? 125 : 75;
                              break;
                           case 2:
                              LocalizationManager.translateId(_loc4_.place,11436);
                              _loc3_ = _proMode == 1 ? 100 : 50;
                              break;
                           case 3:
                              LocalizationManager.translateId(_loc4_.place,11437);
                              _loc3_ = _proMode == 1 ? 75 : 40;
                              break;
                           case 4:
                              LocalizationManager.translateId(_loc4_.place,11438);
                              _loc3_ = _proMode == 1 ? 50 : 30;
                              break;
                           case 5:
                              LocalizationManager.translateId(_loc4_.place,11439);
                              _loc3_ = _proMode == 1 ? 25 : 25;
                        }
                        LocalizationManager.translateIdAndInsert(_loc4_.gemsEarned,11097,_loc3_);
                        if(_loc5_[_loc8_] == _myPlayer)
                        {
                           _gemsEarned += _loc3_;
                           addGemsToBalance(_loc3_);
                        }
                        _loc4_.setTagWidth();
                        _loc4_.visible = true;
                     }
                     else
                     {
                        _loc4_.visible = false;
                     }
                     _loc8_++;
                  }
            }
            if(_loc6_ != null)
            {
               if(_musicLoop)
               {
                  _musicLoop.stop();
               }
               _musicLoop = _loc6_;
            }
            _gameState = param1;
         }
      }
   }
}

