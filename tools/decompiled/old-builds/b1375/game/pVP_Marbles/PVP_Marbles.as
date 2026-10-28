package game.pVP_Marbles
{
   import Box2D.Collision.Shapes.b2CircleDef;
   import Box2D.Collision.Shapes.b2PolygonDef;
   import Box2D.Collision.b2AABB;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2DebugDraw;
   import Box2D.Dynamics.b2World;
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import avatar.AvatarXtCommManager;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class PVP_Marbles extends GameBase implements IMinigame
   {
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      public static const GAMESTATE_LOADING:int = 0;
      
      public static const GAMESTATE_LOADING_AVATAR1:int = 1;
      
      public static const GAMESTATE_LOADING_AVATAR2:int = 2;
      
      public static const GAMESTATE_WAITING_FOR_START:int = 3;
      
      public static const GAMESTATE_STARTED:int = 4;
      
      public static const GAMESTATE_TURN_COMPLETE:int = 5;
      
      public static const GAMESTATE_GAME_OVER:int = 6;
      
      public static const GAMESTATE_WAITINGFORPLAYER:int = 7;
      
      public static const GAMESTATE_COINTOSS:int = 8;
      
      public static const GAMESTATE_HOWTOPLAY:int = 9;
      
      private static const SHOW_DEBUG:Boolean = false;
      
      private var LINEAR_DAMPING:Number = 0.4;
      
      private var THRESHOLD:Number = 0.01;
      
      private var TIMEOUT_TIME:Number = 15;
      
      public var messageServer:Function;
      
      public var leaveMinigame:Function;
      
      private var _playerAvatar1:Avatar;
      
      private var _playerAvatar2:Avatar;
      
      private var _playerAvatarView1:AvatarView;
      
      private var _playerAvatarView2:AvatarView;
      
      public var myId:uint;
      
      public var _pIDs:Array;
      
      public var _dbIDs:Array;
      
      public var _userNames:Array;
      
      private var _sceneLoaded:Boolean;
      
      private var _bInit:Boolean;
      
      public var _layerMain:Sprite;
      
      public var _layerPopups:Sprite;
      
      public var _serverStarted:Boolean;
      
      public var _gameState:int;
      
      private var _world:b2World;
      
      private var _contactListener:PVP_Marbles_ContactListener;
      
      private var _iterations:int = 10;
      
      private var _timeStep:Number = 0.041666666666666664;
      
      private var _phyScale:Number = 0.03333333333333333;
      
      private var _lastTime:int;
      
      private var _frameTime:Number;
      
      private var _gameTime:Number;
      
      public var _background:Object;
      
      public var _players:Array;
      
      public var _roundCompleteTimer:Number;
      
      public var _timeOutTimer:Number;
      
      public var _gameTimer:Object;
      
      public var _coinToss:Object;
      
      private var _drawLine:Boolean;
      
      private var _shootLine:MovieClip = new MovieClip();
      
      private var _shootVector:Point = new Point();
      
      private var _startPosX:Number;
      
      private var _startPosY:Number;
      
      private var _cueBallBody:b2Body;
      
      private var _activeCue:Object;
      
      private var _marblesP1:Array = [];
      
      private var _marblesP2:Array = [];
      
      private var _currentPattern:int = 3;
      
      private var _queueNextTurn:Boolean = false;
      
      private var _queueEndTurn:Boolean = false;
      
      public var _updatePositionTimer:Number;
      
      public var _serverPosition:Point;
      
      public var _lastServerPosition:Point;
      
      public var _trailingPosX:Number;
      
      public var _trailingPosY:Number;
      
      public var _hasTurn:Boolean = false;
      
      public var _lastTurn:Boolean = false;
      
      public var _hadFirstTurn:Boolean;
      
      public var _readyLevelDisplayTimer:Number;
      
      public var _readyLevelDisplay:Object;
      
      public var _marblesToReturn:int;
      
      public var _playerLeft:Boolean;
      
      private var _soundEnabled:Boolean = true;
      
      private var _currentPopup:MovieClip;
      
      private var _iWon:Boolean;
      
      private var _tie:Boolean;
      
      private var marble_player:Class;
      
      private var marble_player_2:Class;
      
      private var marble_1:Class;
      
      private var marble_2:Class;
      
      public var _soundMan:SoundManager;
      
      private var _audio:Array = ["marbles_large1.mp3","marbles_large2.mp3","marbles_large3.mp3","marbles_large4.mp3","marbles_small1.mp3","marbles_small2.mp3","marbles_small3.mp3","marbles_small4.mp3","marbles_small5.mp3","marbles_imp_wood.mp3","marbles_point.mp3","pvp_stinger_draw.mp3","pvp_stinger_fail.mp3","pvp_stinger_win.mp3","pvp_stinger_turn.mp3","popup_pvp_RedText_enter.mp3","popup_pvp_RedText_exit.mp3","pvp_timer_count_down.mp3","pvp_timeUp_buzzer.mp3"];
      
      private var _soundNameLarge1:String = _audio[0];
      
      private var _soundNameLarge2:String = _audio[1];
      
      private var _soundNameLarge3:String = _audio[2];
      
      private var _soundNameLarge4:String = _audio[3];
      
      private var _soundNameSmall1:String = _audio[4];
      
      private var _soundNameSmall2:String = _audio[5];
      
      private var _soundNameSmall3:String = _audio[6];
      
      private var _soundNameSmall4:String = _audio[7];
      
      private var _soundNameSmall5:String = _audio[8];
      
      private var _soundNameImpWood:String = _audio[9];
      
      private var _soundNamePoint:String = _audio[10];
      
      private var _soundNameTie:String = _audio[11];
      
      private var _soundNameLose:String = _audio[12];
      
      private var _soundNameWin:String = _audio[13];
      
      private var _soundNameTurn:String = _audio[14];
      
      private var _soundNameRedTextEnter:String = _audio[15];
      
      private var _soundNameRedTextExit:String = _audio[16];
      
      private var _soundNameTimerCount:String = _audio[17];
      
      private var _soundNameTimerDone:String = _audio[18];
      
      public function PVP_Marbles()
      {
         super();
         _serverStarted = false;
         _gameState = 0;
         init();
      }
      
      private function loadSounds() : void
      {
         _soundMan.addSoundByName(_audioByName[_soundNameLarge1],_soundNameLarge1,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameLarge1],_soundNameLarge2,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameLarge1],_soundNameLarge3,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameLarge1],_soundNameLarge4,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall1],_soundNameSmall1,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall2],_soundNameSmall2,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall3],_soundNameSmall3,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall4],_soundNameSmall4,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameSmall5],_soundNameSmall5,0.88);
         _soundMan.addSoundByName(_audioByName[_soundNameImpWood],_soundNameImpWood,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNamePoint],_soundNamePoint,0.61);
         _soundMan.addSoundByName(_audioByName[_soundNameTie],_soundNameTie,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameLose],_soundNameLose,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameWin],_soundNameWin,0.45);
         _soundMan.addSoundByName(_audioByName[_soundNameTurn],_soundNameTurn,0.6);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextEnter],_soundNameRedTextEnter,0.14);
         _soundMan.addSoundByName(_audioByName[_soundNameRedTextExit],_soundNameRedTextExit,0.13);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerCount],_soundNameTimerCount,0.2);
         _soundMan.addSoundByName(_audioByName[_soundNameTimerDone],_soundNameTimerDone,1);
      }
      
      public function start(param1:uint, param2:Array, param3:Function, param4:Function) : void
      {
         myId = param1;
         _pIDs = param2;
         messageServer = param3;
         leaveMinigame = param4;
         init();
      }
      
      public function message(param1:Array) : void
      {
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(param1[0] == "ml")
         {
            _playerLeft = true;
            if(_gameState <= 3)
            {
               end(null);
            }
            else
            {
               setGameState(6);
            }
         }
         else if(param1[0] == "ms")
         {
            _serverStarted = true;
            _dbIDs = [];
            _userNames = [];
            _loc3_ = 1;
            _loc4_ = 0;
            while(_loc4_ < _pIDs.length)
            {
               _dbIDs[_loc4_] = param1[_loc3_++];
               _userNames[_loc4_] = param1[_loc3_++];
               _loc4_++;
            }
            _currentPattern = param1[_loc3_++];
         }
         else if(param1[0] == "mm")
         {
            if(param1[2] == "endTurn")
            {
               _queueNextTurn = true;
            }
            else if(param1[2] == "start")
            {
               if(_pIDs.length == 2)
               {
                  _hasTurn = _pIDs[param1[3]] == myId;
                  _hadFirstTurn = _hasTurn;
               }
               else
               {
                  _hasTurn = true;
               }
               if(myId == _pIDs[0])
               {
                  _scene.getLayer("youorange").loader.content.gotoAndPlay("on");
               }
               else
               {
                  _scene.getLayer("youblue").loader.content.gotoAndPlay("on");
               }
               setGameState(8);
            }
            else if(param1[2] == "pos")
            {
               _serverPosition.x = param1[3];
               _serverPosition.y = param1[4];
            }
            else if(param1[2] == "shoot")
            {
               _loc4_ = 3;
               _activeCue.visible = false;
               _startPosX = param1[_loc4_++];
               _startPosY = param1[_loc4_++];
               _shootVector.x = param1[_loc4_++];
               _shootVector.y = param1[_loc4_++];
               createPlayerMarble();
               _activeCue = null;
               _cueBallBody.ApplyForce(new b2Vec2(-_shootVector.x * 3,-_shootVector.y * 3),_cueBallBody.GetWorldCenter());
               if(_timeOutTimer > 0)
               {
                  _gameTimer.time(TIMEOUT_TIME,TIMEOUT_TIME);
               }
            }
         }
      }
      
      public function end(param1:Array) : void
      {
         var _loc2_:Array = null;
         hideDlg();
         if(_gameTime > 5 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(86,1);
         }
         _loc2_ = [];
         _loc2_[0] = "quit";
         messageServer(_loc2_);
         releaseBase();
         stage.removeEventListener("keyDown",onHowToPlayKeyDown);
         stage.removeEventListener("enterFrame",heartbeat);
         stage.removeEventListener("mouseUp",mouseUpHandler);
         removeEventListener("mouseDown",mouseDownHandler);
         _bInit = false;
         _world = null;
         removeLayer(_layerMain);
         removeLayer(_layerPopups);
         removeLayer(_guiLayer);
         _layerMain = null;
         _layerPopups = null;
         _guiLayer = null;
         if(leaveMinigame != null)
         {
            leaveMinigame(false);
         }
      }
      
      private function init() : void
      {
         if(!_bInit)
         {
            _layerMain = new Sprite();
            _layerPopups = new Sprite();
            _guiLayer = new Sprite();
            addChild(_layerMain);
            addChild(_layerPopups);
            addChild(_guiLayer);
            loadScene("PVP_Marbles/room_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc8_:int = 0;
         var _loc4_:* = null;
         var _loc3_:* = null;
         var _loc6_:* = null;
         stage.quality = "medium";
         _soundMan = new SoundManager(this);
         loadSounds();
         _gameTimer = GETDEFINITIONBYNAME("Marbles_microGameTimer");
         _coinToss = GETDEFINITIONBYNAME("Marbles_coinToss");
         _gameTimer.x = 455;
         _gameTimer.y = 230;
         _coinToss.x = 455;
         _coinToss.y = 280;
         _background = _scene.getLayer("bg");
         _background.loader.content.circle.visible = false;
         _activeCue = _background.loader.content.cue1;
         _background.loader.content.cue2.visible = false;
         _closeBtn = addBtn("CloseButton",847,40,showExitConfirmationDlg);
         _layerMain.addChild(_background.loader);
         _layerMain.addChild(_shootLine);
         _layerPopups.addChild(_gameTimer as DisplayObject);
         _layerPopups.addChild(_coinToss as DisplayObject);
         _layerMain.addChild(_scene.getLayer("arrow").loader);
         _scene.getLayer("arrow").loader.visible = false;
         _gameTimer.player1Name.text = "";
         _gameTimer.player2Name.text = "";
         if(_pIDs.length == 2)
         {
            if(_pIDs[0] == myId)
            {
               _layerMain.addChild(_scene.getLayer("youorange").loader);
               _gameTimer.gotoAndStop("orange");
               _gameTimer.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
               _gameTimer.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
               _scene.getLayer("youorange").loader.x = 133;
               _scene.getLayer("youorange").loader.y = 166;
            }
            else
            {
               _layerMain.addChild(_scene.getLayer("youblue").loader);
               _gameTimer.gotoAndStop("blue");
               _gameTimer.player1Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[1],_dbIDs[1]).avName;
               _gameTimer.player2Name.text = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[0],_dbIDs[0]).avName;
               _scene.getLayer("youblue").loader.x = 133;
               _scene.getLayer("youblue").loader.y = 166;
            }
         }
         var _loc5_:b2AABB = new b2AABB();
         _loc5_.lowerBound.Set(-1000,-1000);
         _loc5_.upperBound.Set(1000,1000);
         var _loc7_:b2Vec2 = new b2Vec2(0,0);
         var _loc2_:Boolean = true;
         _world = new b2World(_loc5_,_loc7_,_loc2_);
         _contactListener = new PVP_Marbles_ContactListener();
         _world.SetContactListener(_contactListener);
         _startPosX = 0;
         _startPosY = 0;
         _trailingPosX = 600;
         _trailingPosY = 0;
         _playerLeft = false;
         _serverPosition = new Point();
         _lastServerPosition = new Point();
         _updatePositionTimer = 0;
         marble_player = getDefinitionByName("marble_player") as Class;
         marble_player_2 = getDefinitionByName("marble_player_2") as Class;
         marble_1 = getDefinitionByName("marble_orange") as Class;
         marble_2 = getDefinitionByName("marble_blue") as Class;
         createMarbles();
         _sceneLoaded = true;
         stage.addEventListener("enterFrame",heartbeat);
         stage.addEventListener("mouseUp",mouseUpHandler);
         addEventListener("mouseDown",mouseDownHandler);
         super.sceneLoaded(param1);
         _gameTime = 0;
         _lastTime = getTimer();
         _frameTime = 0;
         if(MainFrame.isInitialized())
         {
            setGameState(1);
         }
      }
      
      private function onHowToPlayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               sendReady();
               break;
            case 8:
            case 46:
            case 27:
               sendReady();
         }
      }
      
      private function showHowToPlay() : void
      {
         _currentPopup = showDlg("Marbles_HowToPlay",[{
            "name":"doneButton",
            "f":sendReady
         },{
            "name":"x_btn",
            "f":sendReady
         }]);
         _currentPopup.x = 450;
         _currentPopup.y = 275;
         stage.addEventListener("keyDown",onHowToPlayKeyDown);
         setGameState(9);
      }
      
      private function showWaitingForPlayer() : void
      {
         var _loc1_:MovieClip = showDlg("M_Waiting",[]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         var _loc3_:b2Body = null;
         var _loc2_:b2Body = null;
         if(param1.keyCode == 37 || param1.keyCode == 39)
         {
            _loc3_ = null;
            if(_world)
            {
               _loc3_ = _world.m_bodyList;
            }
            while(_loc3_)
            {
               _loc2_ = _loc3_;
               _loc3_ = _loc3_.GetNext();
               if(_loc2_.GetUserData())
               {
                  _loc2_.GetUserData().parent.removeChild(_loc2_.GetUserData());
               }
               _world.DestroyBody(_loc2_);
            }
            if(param1.keyCode == 37)
            {
               _currentPattern = _currentPattern - 1;
               if(_currentPattern < 1)
               {
                  _currentPattern = 14;
               }
            }
            else
            {
               _currentPattern = _currentPattern + 1;
               if(_currentPattern > 14)
               {
                  _currentPattern = 1;
               }
            }
            while(_marblesP1.length)
            {
               _marblesP1[0].parent.removeChild(_marblesP1[0]);
               _marblesP1.splice(0,1);
            }
            while(_marblesP2.length)
            {
               _marblesP2[0].parent.removeChild(_marblesP2[0]);
               _marblesP2.splice(0,1);
            }
            createMarbles();
         }
         else if(param1.keyCode == 32)
         {
            _soundEnabled = !_soundEnabled;
         }
      }
      
      private function createPlayerMarble() : void
      {
         var _loc1_:* = null;
         var _loc6_:b2BodyDef = null;
         var _loc5_:Object = null;
         var _loc7_:int = 0;
         var _loc4_:Number = NaN;
         var _loc3_:b2CircleDef = new b2CircleDef();
         _loc3_.density = 1;
         _loc3_.restitution = 1;
         _loc3_.friction = 0;
         var _loc2_:String = _activeCue == _scene.getLayer("bg").loader.content.cue1 ? "player_marble" : "player_marble_2";
         _loc5_ = new (_activeCue == _scene.getLayer("bg").loader.content.cue1 ? marble_player : marble_player_2)();
         _loc5_.lastPosX = _startPosX;
         _loc5_.lastPosY = _startPosY;
         _layerMain.addChild(_loc5_ as DisplayObject);
         _loc4_ = _loc5_.marble.width * 0.5;
         _loc3_.radius = _loc4_ * _phyScale;
         _loc5_.x = _startPosX;
         _loc5_.y = _startPosY;
         _loc6_ = new b2BodyDef();
         _loc6_.position.x = _loc5_.x * _phyScale;
         _loc6_.position.y = _loc5_.y * _phyScale;
         _loc6_.linearDamping = LINEAR_DAMPING;
         _loc6_.userData = _loc5_;
         _loc3_.isSensor = false;
         _cueBallBody = _world.CreateBody(_loc6_);
         _cueBallBody.CreateShape(_loc3_);
         _cueBallBody.SetMassFromShapes();
      }
      
      private function createMarbles() : void
      {
         var _loc2_:b2Body = null;
         var _loc11_:b2BodyDef = null;
         var _loc9_:Object = null;
         var _loc3_:* = null;
         var _loc12_:int = 0;
         var _loc10_:String = null;
         var _loc7_:Number = NaN;
         var _loc1_:Object = null;
         var _loc8_:Number = NaN;
         var _loc5_:b2CircleDef = new b2CircleDef();
         var _loc4_:b2PolygonDef = new b2PolygonDef();
         var _loc6_:MovieClip = _scene.getLayer("pattern").loader.content;
         _loc6_.gotoAndStop(_currentPattern);
         _loc5_.density = 1;
         _loc5_.restitution = 1;
         _loc5_.friction = 0;
         _loc12_ = 0;
         while(_loc12_ < _loc6_.numChildren)
         {
            _loc1_ = _loc6_.getChildAt(_loc12_);
            _loc10_ = getQualifiedClassName(_loc1_);
            if(_loc10_ == "marble_1")
            {
               _loc9_ = new marble_1();
            }
            else if(_loc10_ == "marble_2")
            {
               _loc9_ = new marble_2();
            }
            else
            {
               _loc9_ = new (getDefinitionByName(_loc10_) as Class)();
            }
            if(_loc9_.hasOwnProperty("marble"))
            {
               _loc8_ = Number(_loc9_.marble.width);
               _loc9_.lastPosX = _loc1_.x;
               _loc9_.lastPosY = _loc1_.y;
            }
            else
            {
               _loc8_ = Number(_loc9_.width);
            }
            _layerMain.addChild(_loc9_ as DisplayObject);
            _loc9_.x = _loc1_.x;
            _loc9_.y = _loc1_.y;
            _loc11_ = new b2BodyDef();
            _loc11_.position.x = _loc9_.x * _phyScale;
            _loc11_.position.y = _loc9_.y * _phyScale;
            _loc11_.angle = _loc1_.rotation * 3.141592653589793 / 180;
            _loc11_.linearDamping = LINEAR_DAMPING;
            _loc11_.userData = _loc9_;
            _loc2_ = _world.CreateBody(_loc11_);
            if(_loc9_ is (getDefinitionByName("obstacle_sq") as Class))
            {
               _loc4_.SetAsBox(_loc9_.width * 0.5 * _phyScale,_loc9_.height * 0.5 * _phyScale);
               _loc9_.rotation = _loc1_.rotation;
               _loc2_.CreateShape(_loc4_);
            }
            else if(_loc9_ is (getDefinitionByName("obstacle_tri") as Class))
            {
               _loc4_.vertexCount = 3;
               _loc4_.vertices[0].Set(0,-_loc9_.height * 0.5 * _phyScale);
               _loc4_.vertices[1].Set(_loc9_.width * 0.5 * _phyScale,_loc9_.height * 0.5 * _phyScale);
               _loc4_.vertices[2].Set(-_loc9_.width * 0.5 * _phyScale,_loc9_.height * 0.5 * _phyScale);
               _loc9_.rotation = _loc1_.rotation;
               _loc2_.CreateShape(_loc4_);
            }
            else if(_loc9_ is (getDefinitionByName("obstacle_cir") as Class))
            {
               _loc5_.density = 0;
               _loc5_.radius = _loc8_ * 0.48 * _phyScale;
               _loc2_.CreateShape(_loc5_);
               _loc5_.density = 1;
            }
            else
            {
               _loc7_ = _loc8_ * 0.5;
               _loc5_.radius = _loc7_ * _phyScale;
               _loc2_.CreateShape(_loc5_);
            }
            _loc2_.SetMassFromShapes();
            _loc12_++;
         }
      }
      
      private function endTurn() : void
      {
         var _loc1_:b2Body = null;
         _loc1_ = _world.m_bodyList;
         while(_loc1_)
         {
            _loc1_.PutToSleep();
            _loc1_ = _loc1_.m_next;
         }
         _roundCompleteTimer = 0.75;
         _queueEndTurn = true;
      }
      
      private function endTurnPart2() : void
      {
         var _loc1_:Object = _scene.getLayer("bg").loader.content;
         if(_cueBallBody.GetUserData() is marble_player)
         {
            _activeCue = _loc1_.cue2;
         }
         else
         {
            _activeCue = _loc1_.cue1;
         }
         _world.DestroyBody(_cueBallBody);
         if(_cueBallBody.GetUserData().parent)
         {
            _cueBallBody.GetUserData().parent.removeChild(_cueBallBody.GetUserData());
         }
         _cueBallBody = null;
         switchTurns();
      }
      
      private function returnMarble() : void
      {
         var _loc4_:int = 0;
         var _loc1_:b2Body = null;
         var _loc9_:b2Body = null;
         var _loc7_:b2BodyDef = null;
         var _loc3_:b2CircleDef = null;
         var _loc2_:b2PolygonDef = null;
         var _loc6_:Object = null;
         var _loc10_:int = 0;
         var _loc5_:Number = NaN;
         if(myId == _pIDs[0])
         {
            _loc4_ = int(!_hasTurn);
         }
         else
         {
            _loc4_ = int(_hasTurn);
         }
         var _loc8_:Object = null;
         if(_loc4_ == 0 && _marblesP1.length > 0)
         {
            _loc8_ = _marblesP1.pop();
         }
         else if(_loc4_ == 1 && _marblesP2.length > 0)
         {
            _loc8_ = _marblesP2.pop();
         }
         if(_loc8_)
         {
            _loc3_ = new b2CircleDef();
            _loc2_ = new b2PolygonDef();
            _loc3_.density = 1;
            _loc3_.restitution = 1;
            _loc3_.friction = 0;
            _loc6_ = _loc8_;
            _loc6_.x = 450;
            _loc6_.y = 275;
            _loc6_.lastPosX = _loc6_.x;
            _loc6_.lastPosY = _loc6_.y;
            _loc7_ = new b2BodyDef();
            _loc7_.position.x = _loc6_.x * _phyScale;
            _loc7_.position.y = _loc6_.y * _phyScale;
            _loc7_.linearDamping = LINEAR_DAMPING;
            _loc7_.userData = _loc6_;
            _loc1_ = _world.CreateBody(_loc7_);
            _loc5_ = _loc6_.marble.width * 0.5;
            _loc3_.radius = _loc5_ * _phyScale;
            _loc1_.CreateShape(_loc3_);
            _loc1_.SetMassFromShapes();
            _world.Step(_timeStep,_iterations);
            while(!_loc1_.IsSleeping())
            {
               _world.Step(_timeStep,_iterations);
            }
            _loc9_ = _world.GetBodyList();
            while(_loc9_)
            {
               if(!_loc9_.IsStatic() && _loc9_.GetUserData() is Object)
               {
                  _loc6_ = _loc9_.GetUserData();
                  _loc6_.x = _loc9_.GetPosition().x / _phyScale;
                  _loc6_.y = _loc9_.GetPosition().y / _phyScale;
                  _loc6_.lastPosX = _loc6_.x;
                  _loc6_.lastPosY = _loc6_.y;
               }
               _loc9_ = _loc9_.GetNext();
            }
         }
         _marblesToReturn = _marblesToReturn - 1;
         _loc8_ = null;
         if(_loc4_ == 0 && _marblesP1.length > 0)
         {
            _loc8_ = _marblesP1[_marblesP1.length - 1];
         }
         else if(_loc4_ == 1 && _marblesP2.length > 0)
         {
            _loc8_ = _marblesP2[_marblesP2.length - 1];
         }
         if(_marblesToReturn == 0 || _loc8_ == null)
         {
            _marblesToReturn = 0;
            switchTurns();
         }
         else
         {
            _loc8_.fade(fadedOut);
         }
      }
      
      private function switchTurns() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         if(_marblesP1.length == 6 || _marblesP2.length == 6)
         {
            if(myId == _pIDs[0])
            {
               _loc2_ = int(!_hasTurn);
               _loc3_ = int(_marblesP1.length);
               _loc1_ = int(_marblesP2.length);
            }
            else
            {
               _loc2_ = int(_hasTurn);
               _loc3_ = int(_marblesP2.length);
               _loc1_ = int(_marblesP1.length);
            }
            if(_hadFirstTurn && _hasTurn && _loc3_ == 6 && _loc1_ != 6 || !_hadFirstTurn && !_hasTurn && _loc1_ == 6 && _loc3_ != 6)
            {
               _hasTurn = !_hasTurn;
               _lastTurn = true;
               setGameState(5);
            }
            else
            {
               setGameState(6);
            }
         }
         else
         {
            _hasTurn = !_hasTurn;
            setGameState(5);
         }
      }
      
      private function shoot() : void
      {
         var _loc1_:Array = null;
         if(_hasTurn)
         {
            _loc1_ = new Array(5);
            _loc1_[0] = "shoot";
            _loc1_[1] = String(_activeCue.x);
            _loc1_[2] = String(_activeCue.y);
            _loc1_[3] = String(_shootVector.x);
            _loc1_[4] = String(_shootVector.y);
            messageServer(_loc1_);
         }
         if(_timeOutTimer > 0)
         {
            _gameTimer.time(TIMEOUT_TIME,TIMEOUT_TIME);
         }
         _scene.getLayer("arrow").loader.visible = false;
         _drawLine = false;
         _activeCue.visible = false;
         _activeCue = null;
         _cueBallBody.ApplyForce(new b2Vec2(-_shootVector.x * 3,-_shootVector.y * 3),_cueBallBody.GetWorldCenter());
      }
      
      private function mouseUpHandler(param1:MouseEvent) : void
      {
         if(_hasTurn && !_pauseGame && _gameState == 4 && _drawLine)
         {
            if(_shootVector.length > 20)
            {
               shoot();
            }
            else
            {
               _scene.getLayer("arrow").loader.visible = false;
               _activeCue.visible = true;
               _drawLine = false;
               _cueBallBody.GetUserData().visible = false;
            }
         }
      }
      
      private function mouseDownHandler(param1:MouseEvent) : void
      {
         var _loc2_:Object = null;
         if(_hasTurn && _activeCue && !_pauseGame && _gameState == 4)
         {
            _drawLine = true;
            _activeCue.visible = false;
            _startPosX = _activeCue.x;
            _startPosY = _activeCue.y;
            if(_cueBallBody == null)
            {
               createPlayerMarble();
            }
            else
            {
               _loc2_ = _cueBallBody.GetUserData();
               _loc2_.lastPosX = _startPosX;
               _loc2_.lastPosY = _startPosY;
               _loc2_.x = _startPosX;
               _loc2_.y = _startPosY;
               _cueBallBody.SetXForm(new b2Vec2(_loc2_.x * _phyScale,_loc2_.y * _phyScale),0);
               _cueBallBody.GetUserData().visible = true;
            }
         }
      }
      
      private function showExitConfirmationDlg() : void
      {
         var _loc1_:MovieClip = showDlg("ExitConfirmationDlg",[{
            "name":"button_yes",
            "f":onExit_Yes
         },{
            "name":"button_no",
            "f":onExit_No
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
      }
      
      private function onExit_Yes() : void
      {
         hideDlg();
         end(null);
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      public function sendReady() : void
      {
         var _loc1_:Array = null;
         stage.removeEventListener("keyDown",onHowToPlayKeyDown);
         hideDlg();
         _timeOutTimer = 0;
         _loc1_ = [];
         _loc1_[0] = "ready";
         messageServer(_loc1_);
         setGameState(3);
      }
      
      private function avatarAdCallback(param1:String = null) : void
      {
         var _loc2_:Point = null;
         switch(_gameState - 1)
         {
            case 0:
               _playerAvatarView1.playAnim(15,false,1,null);
               _loc2_ = AvatarUtility.getAvatarHudPosition(_playerAvatarView1.avTypeId);
               _playerAvatarView1.x = _loc2_.x;
               _playerAvatarView1.y = _loc2_.y;
               setGameState(2);
               break;
            case 1:
               _playerAvatarView2.playAnim(15,false,1,null);
               _loc2_ = AvatarUtility.getAvatarHudPosition(_playerAvatarView2.avTypeId);
               _playerAvatarView2.x = _loc2_.x;
               _playerAvatarView2.y = _loc2_.y;
               if(_gameTimer.portrait1 != null)
               {
                  _gameTimer.portrait1.portraitContainer.addChild(_playerAvatarView1);
                  _gameTimer.portrait2.portraitContainer.addChild(_playerAvatarView2);
               }
               showHowToPlay();
         }
      }
      
      public function setGameState(param1:int) : void
      {
         var _loc2_:* = null;
         var _loc4_:b2Body = null;
         var _loc3_:Object = null;
         if(_gameState != 6 && _gameState != param1)
         {
            if(_readyLevelDisplay && _readyLevelDisplay.loader && _readyLevelDisplay.loader.parent)
            {
               _readyLevelDisplay.loader.parent.removeChild(_readyLevelDisplay.loader);
               _readyLevelDisplay = null;
            }
            _gameState = param1;
            switch(param1 - 1)
            {
               case 0:
                  _playerAvatar1 = new Avatar();
                  if(_pIDs[0] == myId)
                  {
                     _playerAvatar1.init(_dbIDs[0],"pvp" + _dbIDs[0],1,[0,0,0],-1,null,_userNames[0]);
                     _playerAvatarView1 = new AvatarView();
                     _playerAvatarView1.init(_playerAvatar1);
                     AvatarXtCommManager.requestADForAvatar(_dbIDs[0],true,avatarAdCallback,_playerAvatar1);
                  }
                  else
                  {
                     _playerAvatar1.init(_dbIDs[1],"pvp" + _dbIDs[1],1,[0,0,0],-1,null,_userNames[1]);
                     _playerAvatarView1 = new AvatarView();
                     _playerAvatarView1.init(_playerAvatar1);
                     AvatarXtCommManager.requestADForAvatar(_dbIDs[1],true,avatarAdCallback,_playerAvatar1);
                  }
                  break;
               case 1:
                  _playerAvatar2 = new Avatar();
                  if(_pIDs[0] == myId)
                  {
                     _playerAvatar2.init(_dbIDs[1],"pvp" + _dbIDs[1],1,[0,0,0],-1,null,_userNames[1]);
                     _playerAvatarView2 = new AvatarView();
                     _playerAvatarView2.init(_playerAvatar2);
                     AvatarXtCommManager.requestADForAvatar(_dbIDs[1],true,avatarAdCallback,_playerAvatar2);
                  }
                  else
                  {
                     _playerAvatar2.init(_dbIDs[0],"pvp" + _dbIDs[0],1,[0,0,0],-1,null,_userNames[0]);
                     _playerAvatarView2 = new AvatarView();
                     _playerAvatarView2.init(_playerAvatar2);
                     AvatarXtCommManager.requestADForAvatar(_dbIDs[0],true,avatarAdCallback,_playerAvatar2);
                  }
                  break;
               case 2:
                  showWaitingForPlayer();
                  break;
               case 3:
                  hideDlg();
                  break;
               case 4:
                  _roundCompleteTimer = 1.5;
                  break;
               case 5:
                  _tie = _marblesP1.length == 6 && _marblesP2.length == 6;
                  _iWon = _pIDs[0] == myId && _marblesP1.length == 6 || _pIDs[1] == myId && _marblesP2.length == 6 || _playerLeft;
                  _readyLevelDisplay = GETDEFINITIONBYNAME("gameEnd");
                  _layerPopups.addChild(_readyLevelDisplay as DisplayObject);
                  _readyLevelDisplay.x = 450;
                  _readyLevelDisplay.y = 275;
                  if(_tie)
                  {
                     _readyLevelDisplay.setTie();
                     playSound(_soundNameTie);
                     addGemsToBalance(10);
                  }
                  else if(_iWon)
                  {
                     _readyLevelDisplay.setWin();
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(87,1);
                     }
                     playSound(_soundNameWin);
                     addGemsToBalance(20);
                  }
                  else
                  {
                     MinigameManager._pvpPromptReplay = true;
                     addGemsToBalance(5);
                     _readyLevelDisplay.setLose();
                     playSound(_soundNameLose);
                  }
                  _roundCompleteTimer = 5;
                  break;
               case 7:
                  hideDlg();
                  _readyLevelDisplay = _coinToss;
                  _timeOutTimer = TIMEOUT_TIME;
                  _gameTimer.activePlayer = _hasTurn;
                  if(_lastTurn)
                  {
                     _readyLevelDisplay.lastTurn();
                  }
                  else if(_hasTurn)
                  {
                     _readyLevelDisplay.setWin((int(myId == _pIDs[0])) + 1);
                  }
                  else if(_pIDs.length == 2)
                  {
                     _readyLevelDisplay.setLose(gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(_userNames[int(myId == _pIDs[0])],_dbIDs[int(myId == _pIDs[0])]).avName);
                  }
                  if(_hasTurn)
                  {
                     playSound(_soundNameTurn);
                     _loc4_ = _world.GetBodyList();
                     while(_loc4_)
                     {
                        _loc3_ = _loc4_.GetUserData();
                        if(myId == _pIDs[0] && _loc3_ is marble_1 || myId == _pIDs[1] && _loc3_ is marble_2)
                        {
                           _loc3_.gotoAndPlay("on");
                        }
                        _loc4_ = _loc4_.GetNext();
                     }
                  }
                  break;
               case 8:
                  _timeOutTimer = 10;
            }
         }
      }
      
      private function playSound(param1:String) : SoundChannel
      {
         if(_soundEnabled)
         {
            return _soundMan.playByName(param1);
         }
         return new SoundChannel();
      }
      
      private function stepPhysics() : void
      {
         var _loc17_:b2Body = null;
         var _loc12_:b2Body = null;
         var _loc8_:int = 0;
         var _loc18_:PVP_Marbles_CustomContactPoint = null;
         var _loc3_:* = undefined;
         var _loc2_:* = undefined;
         var _loc7_:MovieClip = null;
         var _loc4_:Object = null;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc1_:PVP_Marbles_Marble = null;
         var _loc13_:Object = null;
         _loc8_ = 0;
         while(_loc8_ < 2)
         {
            _world.Step(_timeStep,_iterations);
            while(_contactListener.contactStack.length)
            {
               _loc18_ = _contactListener.contactStack.pop();
               _loc3_ = _loc18_.shape1.GetBody().GetUserData();
               _loc2_ = _loc18_.shape2.GetBody().GetUserData();
               if(_loc3_ is PVP_Marbles_Marble && _loc2_ is PVP_Marbles_Marble)
               {
                  playSound(this["_soundNameSmall" + Math.ceil(Math.random() * 5)]).soundTransform.volume = 0.3 * _loc18_.normalImpulse;
               }
               else if(_loc18_.shape1.GetBody().IsStatic() || _loc18_.shape2.GetBody().IsStatic())
               {
                  playSound(_soundNameImpWood).soundTransform.volume = 0.3 * _loc18_.normalImpulse;
               }
               else
               {
                  playSound(this["_soundNameLarge" + Math.ceil(Math.random() * 4)]).soundTransform.volume = 0.3 * _loc18_.normalImpulse;
               }
               _loc7_ = GETDEFINITIONBYNAME("sparks");
               _layerPopups.addChild(_loc7_);
               _loc7_.gotoAndPlay("on");
               _loc7_.x = _loc18_.position.x / _phyScale;
               _loc7_.y = _loc18_.position.y / _phyScale;
               _loc7_.rotation = -(Math.atan2(_loc2_.y - _loc3_.y,_loc3_.x - _loc2_.x) * 180 / 3.141592653589793 + 90);
            }
            _loc8_++;
         }
         var _loc5_:Boolean = true;
         var _loc16_:Object = _scene.getLayer("bg").loader.content;
         var _loc19_:Point = new Point();
         var _loc11_:Number = 450;
         var _loc10_:Number = 275;
         var _loc9_:Number = _loc16_.circle.width * 0.5;
         var _loc6_:Boolean = myId == _pIDs[0] && _hasTurn || myId != _pIDs[0] && !_hasTurn;
         _loc17_ = _world.GetBodyList();
         while(_loc17_)
         {
            _loc12_ = _loc17_.m_next;
            if(!_loc17_.IsStatic() && _loc17_.GetUserData() is Object)
            {
               _loc4_ = _loc17_.GetUserData();
               _loc4_.x = _loc17_.GetPosition().x / _phyScale;
               _loc4_.y = _loc17_.GetPosition().y / _phyScale;
               if(_loc4_.hasOwnProperty("lastPosX"))
               {
                  _loc14_ = _loc4_.texture.width * 0.5;
                  _loc15_ = _loc4_.marble.width * 0.5;
                  _loc4_.texture.x += _loc4_.x - _loc4_.lastPosX;
                  _loc4_.texture.y += _loc4_.y - _loc4_.lastPosY;
                  if(_loc4_.texture.x > _loc14_ - _loc15_)
                  {
                     _loc4_.texture.x -= _loc14_;
                  }
                  if(_loc4_.texture.x < _loc15_ - _loc14_)
                  {
                     _loc4_.texture.x += _loc14_;
                  }
                  if(_loc4_.texture.y > _loc14_ - _loc15_)
                  {
                     _loc4_.texture.y -= _loc14_;
                  }
                  if(_loc4_.texture.y < _loc15_ - _loc14_)
                  {
                     _loc4_.texture.y += _loc14_;
                  }
                  _loc4_.lastPosX = _loc4_.x;
                  _loc4_.lastPosY = _loc4_.y;
               }
               _loc19_.x = _loc4_.x - _loc11_;
               _loc19_.y = _loc4_.y - _loc10_;
               if(_loc19_.length > _loc9_ && (_loc4_ is marble_1 || _loc4_ is marble_2) && _loc4_.alpha == 1)
               {
                  _loc13_ = GETDEFINITIONBYNAME("marbles_score_popup");
                  _layerPopups.addChild(_loc13_ as DisplayObject);
                  _loc13_.x = _loc4_.x;
                  _loc13_.y = _loc4_.y;
                  if(_loc4_ is marble_1)
                  {
                     _loc1_ = _loc4_ as PVP_Marbles_Marble;
                     if(_hasTurn)
                     {
                        if(_loc6_)
                        {
                           _loc13_.showscore(1);
                           playSound(_soundNamePoint);
                        }
                     }
                  }
                  else if(_loc4_ is marble_2)
                  {
                     _loc1_ = _loc4_ as PVP_Marbles_Marble;
                     if(_hasTurn)
                     {
                        if(!_loc6_)
                        {
                           _loc13_.showscore(1);
                           playSound(_soundNamePoint);
                        }
                     }
                  }
                  _loc1_.fade(fadedOut);
                  _loc4_.bb = _loc17_;
               }
               if(!_loc17_.IsSleeping() && _loc17_.m_linearVelocity.LengthSquared() > THRESHOLD)
               {
                  _loc5_ = false;
               }
            }
            _loc17_ = _loc12_;
         }
         if(_loc5_ && !_queueEndTurn)
         {
            endTurn();
         }
      }
      
      private function updateCuePreview() : void
      {
         var _loc4_:Array = null;
         var _loc2_:Number = 450;
         var _loc1_:Number = 275;
         if(_hasTurn)
         {
            _lastServerPosition.x = _serverPosition.x;
            _lastServerPosition.y = _serverPosition.y;
            _serverPosition.x = _trailingPosX = mouseX;
            _serverPosition.y = _trailingPosY = mouseY;
            _updatePositionTimer += _frameTime;
            if(_updatePositionTimer > 0.25 && (_lastServerPosition.x != _serverPosition.x || _lastServerPosition.y != _serverPosition.y))
            {
               _loc4_ = new Array(3);
               _loc4_[0] = "pos";
               _loc4_[1] = String(int(_serverPosition.x));
               _loc4_[2] = String(int(_serverPosition.y));
               messageServer(_loc4_);
               _updatePositionTimer = 0;
            }
         }
         else
         {
            _trailingPosX += (_serverPosition.x - _trailingPosX) * 0.25;
            _trailingPosY += (_serverPosition.y - _trailingPosY) * 0.25;
         }
         var _loc3_:Point = new Point(_trailingPosX - _loc2_,_trailingPosY - _loc1_);
         _loc3_.normalize(1);
         _activeCue.x = _loc2_ + _loc3_.x * (_background.loader.content.circle.width * 0.5 + 40);
         _activeCue.y = _loc1_ + _loc3_.y * (_background.loader.content.circle.width * 0.5 + 40);
         _activeCue.visible = true;
      }
      
      public function fadedIn(param1:Object) : void
      {
         var _loc2_:int = 0;
         param1._fadedIn = null;
         if(myId == _pIDs[0])
         {
            _loc2_ = int(!_hasTurn);
         }
         else
         {
            _loc2_ = int(_hasTurn);
         }
         var _loc3_:PVP_Marbles_Marble = null;
         if(_loc2_ == 0 && _marblesP1.length > 0)
         {
            _loc3_ = _marblesP1[_marblesP1.length - 1];
         }
         else if(_loc2_ == 1 && _marblesP2.length > 0)
         {
            _loc3_ = _marblesP2[_marblesP2.length - 1];
         }
         if(_loc3_)
         {
            _loc3_.fade(fadedOut);
         }
         else
         {
            _marblesToReturn = 0;
            switchTurns();
         }
      }
      
      public function fadedOut(param1:Object) : void
      {
         if(myId == _pIDs[0])
         {
            if(param1 is marble_1)
            {
               param1.x = 131;
               param1.y = 380 - _marblesP1.length * param1.marble.width;
            }
            else
            {
               param1.x = 773;
               param1.y = 380 - _marblesP2.length * param1.marble.width;
            }
         }
         else if(param1 is marble_1)
         {
            param1.x = 773;
            param1.y = 380 - _marblesP1.length * param1.marble.width;
         }
         else
         {
            param1.x = 131;
            param1.y = 380 - _marblesP2.length * param1.marble.width;
         }
         if(param1 is marble_1)
         {
            _marblesP1.push(param1);
         }
         else
         {
            _marblesP2.push(param1);
         }
         param1.texture.x = 0;
         param1.texture.y = 0;
         if(_world && param1.bb)
         {
            _world.DestroyBody(param1.bb);
         }
      }
      
      public function heartbeat(param1:Event) : void
      {
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc4_:* = null;
         var _loc3_:Object = null;
         var _loc2_:MovieClip = null;
         if(_sceneLoaded)
         {
            if(_serverStarted)
            {
               _frameTime = (getTimer() - _lastTime) / 1000;
               if(_frameTime > 0.5)
               {
                  _frameTime = 0.5;
               }
               _lastTime = getTimer();
               _gameTime += _frameTime;
               if(_gameState == 8)
               {
                  if(_readyLevelDisplay && _readyLevelDisplay.finished)
                  {
                     _readyLevelDisplay = null;
                     setGameState(4);
                  }
               }
               if(_gameState == 9)
               {
                  _timeOutTimer -= _frameTime;
                  _currentPopup.timer.text = Math.ceil(_timeOutTimer).toString();
                  if(_timeOutTimer <= 0)
                  {
                     sendReady();
                  }
               }
               if(_gameState == 5)
               {
                  _roundCompleteTimer -= _frameTime;
                  if(_roundCompleteTimer <= 0)
                  {
                     setGameState(8);
                  }
               }
               if(_gameState == 4)
               {
                  if(_drawLine)
                  {
                     _shootVector.x = mouseX - _startPosX;
                     _shootVector.y = mouseY - _startPosY;
                     if(_shootVector.length > 100)
                     {
                        _shootVector.normalize(100);
                     }
                     _loc3_ = _scene.getLayer("arrow").loader;
                     _loc3_.visible = true;
                     _loc3_.x = _startPosX;
                     _loc3_.y = _startPosY;
                     _loc3_.scaleX = _loc3_.scaleY = 0.3;
                     _loc3_.content.arrow.gotoAndStop(100 - Math.floor(_shootVector.length));
                     _loc3_.rotation = -Math.atan2(_shootVector.x,_shootVector.y) * 180 / 3.141592653589793;
                  }
                  else if(_activeCue)
                  {
                     updateCuePreview();
                  }
                  else
                  {
                     stepPhysics();
                  }
                  if((_activeCue && _activeCue.visible || _drawLine) && _timeOutTimer > 0)
                  {
                     _timeOutTimer -= _frameTime;
                     if(_timeOutTimer <= 0)
                     {
                        _timeOutTimer = 0;
                        if(_hasTurn)
                        {
                           _shootVector.x = _shootVector.y = 0;
                           if(!_cueBallBody)
                           {
                              _startPosX = _activeCue.x;
                              _startPosY = _activeCue.y;
                              createPlayerMarble();
                           }
                           shoot();
                        }
                     }
                     _gameTimer.time(_timeOutTimer,TIMEOUT_TIME);
                     if(_gameTimer.timer_count_down)
                     {
                        _gameTimer.timer_count_down = false;
                        playSound(_soundNameTimerCount);
                     }
                     if(_gameTimer.timer_timeUp)
                     {
                        _gameTimer.timer_timeUp = false;
                        playSound(_soundNameTimerDone);
                     }
                     if(_gameTimer.RedText_enter)
                     {
                        _gameTimer.RedText_enter = false;
                        playSound(_soundNameRedTextEnter);
                     }
                     if(_gameTimer.RedText_exit)
                     {
                        _gameTimer.RedText_exit = false;
                        playSound(_soundNameRedTextExit);
                     }
                  }
                  if(_queueEndTurn)
                  {
                     _roundCompleteTimer -= _frameTime;
                     if(_roundCompleteTimer <= 0)
                     {
                        _roundCompleteTimer = 0;
                        _queueEndTurn = false;
                        _loc5_ = [];
                        _loc5_[0] = "endTurn";
                        messageServer(_loc5_);
                        setGameState(7);
                     }
                  }
               }
               else if(_gameState == 6)
               {
                  if(_roundCompleteTimer > 0)
                  {
                     _roundCompleteTimer -= _frameTime;
                     if(_roundCompleteTimer <= 0)
                     {
                        end(null);
                     }
                     else if(_roundCompleteTimer <= 2 && _roundCompleteTimer + _frameTime > 2)
                     {
                        if(_tie)
                        {
                           _loc2_ = showDlg("Marbles_tie",[]);
                           _loc2_.x = 450;
                           _loc2_.y = 275;
                        }
                        else if(_iWon)
                        {
                           _loc2_ = showDlg("Marbles_win",[]);
                           _loc2_.x = 450;
                           _loc2_.y = 275;
                        }
                        else
                        {
                           _loc2_ = showDlg("Marbles_win",[]);
                           _loc2_.x = 450;
                           _loc2_.y = 275;
                           LocalizationManager.translateIdAndInsert(_loc2_.gemsEarned,11554,5);
                        }
                     }
                  }
               }
               else if(_gameState == 7)
               {
                  if(_queueNextTurn)
                  {
                     _queueNextTurn = false;
                     endTurnPart2();
                  }
               }
            }
         }
      }
   }
}

