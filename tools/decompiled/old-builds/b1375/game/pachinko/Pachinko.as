package game.pachinko
{
   import Box2D.Collision.Shapes.b2CircleDef;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2PolygonDef;
   import Box2D.Collision.b2AABB;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2BodyDef;
   import Box2D.Dynamics.b2DebugDraw;
   import Box2D.Dynamics.b2World;
   import achievement.AchievementManager;
   import achievement.AchievementXtCommManager;
   import com.sbi.corelib.audio.SBMusic;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.media.SoundChannel;
   import flash.utils.getTimer;
   import game.GameBase;
   import game.IMinigame;
   import game.MinigameManager;
   import game.SoundManager;
   import localization.LocalizationManager;
   
   public class Pachinko extends GameBase implements IMinigame
   {
      
      private static const MAX_BALLS:int = 10;
      
      private static const MAX_JACKPOT_ICONS:int = 3;
      
      private static const JACKPOT_GEM_AWARD:int = 75;
      
      private static const JACKPOT_POPUP_TIMER:int = 36;
      
      private static const SHOW_DEBUG:Boolean = false;
      
      private static const SPRING_FORCE_BASE:int = 180;
      
      private static const SPRING_FORCE_MULTIPLYER:Number = 3.7;
      
      private static const SPRING_FORCE_RANDOM_VARIANCE:Number = 10;
      
      private static const POPUP_X:int = 450;
      
      private static const POPUP_Y:int = 275;
      
      private var _world:b2World;
      
      private var _iterations:int = 10;
      
      private var _timeStep:Number = 0.041666666666666664;
      
      private var _phyScale:Number = 0.03333333333333333;
      
      private var _contactListener:ContactListener;
      
      private var _phyWidth:int = 900;
      
      private var _phyHeight:int = 700;
      
      private var _background:Sprite;
      
      private var _playfield:Sprite;
      
      private var _foreground:Sprite;
      
      private var _ballIcon:Array;
      
      private var _jackpotIcons:Array;
      
      private var _scoreCtrl:Object;
      
      private var _jackpot:Array;
      
      private var _gems:Array;
      
      private var _springMode:int;
      
      private var _spring:Object;
      
      private var _springTop:Object;
      
      private var _springOffset:Number;
      
      private var _ballBody:b2Body;
      
      private var _volumeBlockEntry:b2Body;
      
      private var _ballPos:b2Vec2;
      
      private var _offset:Point;
      
      private var _lastTime:int;
      
      private var _totalGameTime:Number;
      
      private var _displayAchievementTimer:Number;
      
      private var _jackpotCount:int;
      
      private var _inputEnabled:Boolean;
      
      public var _soundMan:SoundManager;
      
      private var _leaveCallback:Function;
      
      private var _audio:Array = ["impact_peg.mp3","aj_gem_new.mp3","jackpot_1.mp3","jackpot_2.mp3","jackpot_3.mp3","pachinko_spring_pull.mp3"];
      
      private var _soundNamePin:String = _audio[0];
      
      private var _soundNamePoints:String = _audio[1];
      
      private var _soundNameJackpot1:String = _audio[2];
      
      private var _soundNameJackpot2:String = _audio[3];
      
      private var _soundNameJackpot3:String = _audio[4];
      
      private var _soundNamePullSpring:String = _audio[5];
      
      private var _bBallInMotion:Boolean;
      
      private var _score:int;
      
      private var _balls:int;
      
      private var _clearJackpot:Boolean;
      
      private var _springStart:int;
      
      private var _springForce:int;
      
      private var _jackpotPopup:MovieClip;
      
      private var _jackpotCountdown:int;
      
      private var _bInit:Boolean;
      
      private var _bLevelComplete:Boolean;
      
      public var _SFX_Music:SBMusic;
      
      public var _musicLoop:SoundChannel;
      
      public function Pachinko()
      {
         super();
         init();
      }
      
      public function start(param1:uint, param2:Array, param3:Function, param4:Function) : void
      {
         _leaveCallback = param4;
         init();
      }
      
      private function init() : void
      {
         _lastTime = getTimer();
         _displayAchievementTimer = 0;
         _jackpotCount = 0;
         if(!_bInit)
         {
            _background = new Sprite();
            _playfield = new Sprite();
            _foreground = new Sprite();
            _guiLayer = new Sprite();
            _jackpot = [];
            _gems = [];
            _ballIcon = [];
            _jackpotIcons = [];
            addChild(_background);
            addChild(_playfield);
            addChild(_foreground);
            addChild(_guiLayer);
            loadScene("PachinkoAssets/game_main.xroom",_audio);
            _bInit = true;
         }
      }
      
      private function loadSounds() : void
      {
         _SFX_Music = _soundMan.addStream("AJ_mus_gem_ball",1);
         _soundMan.addSoundByName(_audioByName[_soundNamePin],_soundNamePin,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePoints],_soundNamePoints,1);
         _soundMan.addSoundByName(_audioByName[_soundNameJackpot1],_soundNameJackpot1,1);
         _soundMan.addSoundByName(_audioByName[_soundNameJackpot2],_soundNameJackpot2,1);
         _soundMan.addSoundByName(_audioByName[_soundNameJackpot3],_soundNameJackpot3,1);
         _soundMan.addSoundByName(_audioByName[_soundNamePullSpring],_soundNamePullSpring,1);
      }
      
      public function message(param1:Array) : void
      {
      }
      
      public function end(param1:Array) : void
      {
         exit();
      }
      
      private function exit() : void
      {
         if(_totalGameTime > 15 && MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
         }
         releaseBase();
         if(_musicLoop)
         {
            _musicLoop.stop();
            _musicLoop = null;
         }
         stage.removeEventListener("keyDown",replayKeyDown);
         removeEventListener("enterFrame",Update);
         disableInput();
         _world = null;
         removeLayer(_background);
         removeLayer(_playfield);
         removeLayer(_foreground);
         removeLayer(_guiLayer);
         _background = null;
         _playfield = null;
         _foreground = null;
         _guiLayer = null;
         _gems = null;
         if(_leaveCallback != null)
         {
            _leaveCallback();
         }
         _bInit = false;
      }
      
      override protected function showDlg(param1:String, param2:Array, param3:int = 0, param4:int = 0, param5:Boolean = true, param6:Boolean = false) : MovieClip
      {
         disableInput();
         return super.showDlg(param1,param2,0,0,param5);
      }
      
      override protected function sceneLoaded(param1:Event) : void
      {
         var _loc13_:int = 0;
         var _loc7_:Object = null;
         var _loc11_:* = null;
         var _loc3_:b2Body = null;
         var _loc6_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc2_:b2Body = null;
         var _loc20_:b2BodyDef = null;
         var _loc18_:Number = NaN;
         var _loc21_:Array = _scene.getActorList("ActorCollisionPoint");
         var _loc16_:Array = _scene.getActorList("ActorSpawn");
         var _loc8_:Array = _scene.getActorList("ActorVolume");
         _soundMan = new SoundManager(this);
         loadSounds();
         _musicLoop = _soundMan.playStream(_SFX_Music,0,999999);
         _offset = _scene.getOffset(stage);
         _offset.x = int(_offset.x);
         _offset.y = int(_offset.y);
         var _loc9_:b2AABB = new b2AABB();
         _loc9_.lowerBound.Set(-1000,-1000);
         _loc9_.upperBound.Set(1000,1000);
         var _loc24_:b2Vec2 = new b2Vec2(0,30);
         var _loc19_:Boolean = true;
         _world = new b2World(_loc9_,_loc24_,_loc19_);
         var _loc10_:b2PolygonDef = new b2PolygonDef();
         var _loc5_:b2BodyDef = new b2BodyDef();
         var _loc15_:b2Vec2 = new b2Vec2();
         var _loc14_:b2MassData = new b2MassData();
         for each(_loc7_ in _loc21_)
         {
            _loc6_ = Math.sqrt((_loc7_.x - _loc7_.x1) * (_loc7_.x - _loc7_.x1) + (_loc7_.y - _loc7_.y1) * (_loc7_.y - _loc7_.y1)) / 2;
            _loc15_.x = (_loc7_.x + _loc7_.x1) / 2 - _offset.x;
            _loc15_.y = (_loc7_.y + _loc7_.y1) / 2 - _offset.y;
            _loc12_ = Math.atan2(_loc7_.y - _loc7_.y1,_loc7_.x - _loc7_.x1);
            _loc5_.position.Set(_loc15_.x * _phyScale,_loc15_.y * _phyScale);
            _loc10_.SetAsOrientedBox(_loc6_ * _phyScale,1 * _phyScale,new b2Vec2(0,0),_loc12_);
            _loc3_ = _world.CreateBody(_loc5_);
            _loc3_.CreateShape(_loc10_);
            _loc3_.SetMassFromShapes();
         }
         for each(_loc7_ in _loc8_)
         {
            _loc5_.position.Set(0,0);
            _loc5_.userData = _loc7_;
            _loc10_.vertices = [];
            _loc13_ = 0;
            while(_loc13_ < _loc7_.points.length - 1)
            {
               _loc23_ = (_loc7_.points[_loc13_].x - _offset.x) * _phyScale;
               _loc22_ = (_loc7_.points[_loc13_].y - _offset.y) * _phyScale;
               _loc10_.vertices.push(new b2Vec2(_loc23_,_loc22_));
               _loc13_++;
            }
            if(_loc7_.name == "score")
            {
               _loc10_.isSensor = true;
            }
            else
            {
               _loc10_.isSensor = false;
            }
            _loc10_.vertexCount = _loc10_.vertices.length;
            _loc3_ = _world.CreateBody(_loc5_);
            _loc3_.CreateShape(_loc10_);
            _loc3_.SetMassFromShapes();
            if(_loc7_.name == "block_entry")
            {
               _volumeBlockEntry = _loc3_;
            }
         }
         var _loc17_:b2CircleDef = new b2CircleDef();
         var _loc4_:Array = _scene.getActorList("ActorLayer");
         for each(_loc7_ in _loc4_)
         {
            var _loc26_:* = _loc7_.name;
            if("col" === _loc26_)
            {
               _loc18_ = Math.sqrt(_loc7_.width * _loc7_.width + _loc7_.height * _loc7_.height) * 0.5;
               _loc18_ = _loc18_ * 0.7;
               _loc17_.radius = _loc18_ * _phyScale;
               _loc20_ = new b2BodyDef();
               _loc20_.position.x = (_loc7_.x - _offset.x + _loc7_.width * 0.5) * _phyScale;
               _loc20_.position.y = (_loc7_.y - _offset.y + _loc7_.height * 0.5) * _phyScale;
               _loc20_.userData = _loc7_;
               _loc17_.isSensor = false;
               _loc2_ = _world.CreateBody(_loc20_);
               _loc2_.CreateShape(_loc17_);
               _loc2_.SetMassFromShapes();
            }
         }
         for each(_loc7_ in _loc16_)
         {
            _loc17_.radius = _loc7_.r * _phyScale;
            _loc20_ = new b2BodyDef();
            _loc20_.position.x = (_loc7_.x - _offset.x) * _phyScale;
            _loc20_.position.y = (_loc7_.y - _offset.y) * _phyScale;
            _loc20_.userData = _loc7_;
            _loc17_.isSensor = true;
            _loc2_ = _world.CreateBody(_loc20_);
            _loc2_.CreateShape(_loc17_);
            _loc2_.SetMassFromShapes();
         }
         _contactListener = new ContactListener();
         _world.SetContactListener(_contactListener);
         addEventListener("enterFrame",Update);
         stage.addEventListener("keyDown",onKeyDown);
         stage.addEventListener("keyUp",onKeyUp);
         stage.addEventListener("mouseUp",onMouseUp);
         stage.addEventListener("mouseDown",onMouseDown);
         _loc13_ = 0;
         while(_loc13_ < _loc4_.length)
         {
            _loc7_ = _loc4_[_loc13_];
            _loc7_.s.x = _loc7_.s.x - _offset.x;
            _loc7_.s.y -= _offset.y;
            if(_loc7_.name != "ball_default" && _loc7_.name != "score_gem")
            {
               var _loc25_:* = _loc7_.layer;
               if(2 !== _loc25_)
               {
                  _background.addChild(_loc7_.s);
               }
               else
               {
                  _foreground.addChild(_loc7_.s);
               }
            }
            _loc13_++;
         }
         _loc13_ = 0;
         while(_loc13_ < 10)
         {
            _ballIcon[_loc13_] = _scene.getLayer("ball_" + (_loc13_ + 1));
            _loc13_++;
         }
         _jackpotIcons[0] = _scene.getLayer("butterfly_1x");
         _jackpotIcons[1] = _scene.getLayer("butterfly_2x");
         _jackpotIcons[2] = _scene.getLayer("butterfly_3x");
         _scoreCtrl = _scene.getLayer("scorectrl");
         _spring = _scene.getLayer("spring");
         _springTop = _scene.getLayer("spring_top");
         _loc7_ = _scene.getLayer("closeButton");
         _closeBtn = addBtn("CloseButton",_loc7_.x,_loc7_.y,showExitConfirmationDlg);
         _springOffset = 0;
         createBall();
         startLevel();
         super.sceneLoaded(param1);
      }
      
      private function createBall() : void
      {
         var _loc1_:b2Body = null;
         var _loc4_:b2BodyDef = null;
         var _loc3_:Object = _scene.cloneAsset("ball_default");
         _loc3_.name = "ball";
         var _loc5_:Loader = _loc3_.loader;
         var _loc2_:b2CircleDef = new b2CircleDef();
         _ballPos = new b2Vec2(_loc5_.x + _loc3_.width / 2,_loc5_.y + _loc3_.height / 2);
         _ballPos.x *= _phyScale;
         _ballPos.y *= _phyScale;
         _loc4_ = new b2BodyDef();
         _loc4_.position.x = _ballPos.x;
         _loc4_.position.y = _ballPos.y;
         _loc2_.radius = _loc3_.height * 0.5 * _phyScale;
         _loc2_.density = 1;
         _loc2_.friction = 0.01;
         _loc2_.restitution = 0.5;
         _loc4_.userData = _loc3_;
         _loc1_ = _world.CreateBody(_loc4_);
         if(_loc1_)
         {
            _loc1_.CreateShape(_loc2_);
            _loc1_.SetMassFromShapes();
            _playfield.addChild(_loc4_.userData.loader);
         }
         _ballBody = _loc1_;
      }
      
      private function Update(param1:Event) : void
      {
         var _loc4_:Object = null;
         var _loc12_:int = 0;
         var _loc13_:b2Body = null;
         var _loc6_:Loader = null;
         var _loc11_:Number = NaN;
         var _loc7_:Matrix = null;
         var _loc16_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:CustomContactPoint = null;
         var _loc3_:* = undefined;
         var _loc2_:* = undefined;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc5_:Number = (getTimer() - _lastTime) / 1000;
         _totalGameTime += _loc5_;
         if(_displayAchievementTimer > 0)
         {
            _displayAchievementTimer -= _loc5_;
            if(_displayAchievementTimer <= 0)
            {
               _displayAchievementTimer = 0;
               AchievementManager.displayNewAchievements();
            }
         }
         _lastTime = getTimer();
         AchievementManager.displayNewAchievements();
         if(_pauseGame)
         {
            return;
         }
         if(!_inputEnabled)
         {
            enableInput();
         }
         if(_springMode >= 0)
         {
            _loc12_ = _springOffset;
            if(_loc12_ < 0)
            {
               _loc12_ = 0;
            }
            _spring.loader.y = _spring.y + _loc12_;
            _springTop.loader.y = _springTop.y + _loc12_;
            if(_springMode < 4)
            {
               _ballBody.SetXForm(new b2Vec2(_ballPos.x,_ballPos.y + _springOffset * _phyScale),0);
               _ballBody.SetLinearVelocity(new b2Vec2());
            }
            switch(_springMode - 1)
            {
               case 0:
                  if(_springOffset < 100)
                  {
                     _springOffset += 5;
                  }
                  else
                  {
                     _springOffset = 100;
                     _springMode = 2;
                  }
                  break;
               case 1:
                  enableEntryBlock(false);
                  _springForce = _springOffset;
                  _springMode = 3;
                  break;
               case 2:
                  if(_springOffset > 0)
                  {
                     _springOffset -= 25;
                  }
                  else
                  {
                     launchBall();
                  }
                  break;
               case 3:
                  _springMode = -1;
                  _springStart = 0;
            }
         }
         _world.Step(_timeStep,_iterations);
         _loc13_ = _world.m_bodyList;
         while(_loc13_)
         {
            if(_loc13_.m_userData is Object)
            {
               _loc4_ = _loc13_.m_userData;
               if(_loc4_.hasOwnProperty("loader"))
               {
                  _loc6_ = _loc4_.loader;
                  _loc11_ = _loc13_.GetAngle();
                  _loc7_ = _loc6_.transform.matrix;
                  _loc16_ = _loc13_.GetPosition().x / _phyScale;
                  _loc14_ = _loc13_.GetPosition().y / _phyScale;
                  _loc6_.x = _loc16_ - _loc4_.width * 0.5;
                  _loc6_.y = _loc14_ - _loc4_.height * 0.5;
               }
            }
            _loc13_ = _loc13_.m_next;
         }
         var _loc10_:Boolean = _bBallInMotion;
         while(_contactListener.contactStack.length)
         {
            _loc15_ = _contactListener.contactStack.pop();
            _loc3_ = _loc15_.shape1.GetBody().GetUserData();
            _loc2_ = _loc15_.shape2.GetBody().GetUserData();
            if(_loc3_ != null && _loc3_.hasOwnProperty("name") && _loc3_.name == "ball")
            {
               processCollision(_loc2_);
            }
            else if(_loc2_ != null && _loc2_.hasOwnProperty("name") && _loc2_.name == "ball")
            {
               processCollision(_loc3_);
            }
         }
         if(_loc10_ != _bBallInMotion)
         {
            if(_balls == 0)
            {
               _ballBody.m_userData.loader.visible = false;
               _bLevelComplete = true;
               _springMode = 0;
               _balls = -1;
            }
            else
            {
               _balls = _balls - 1;
               refreshBallIcons();
               _springMode = 0;
            }
         }
         if(_jackpotPopup)
         {
            JackpotDlg_Heartbeat();
         }
         for each(_loc4_ in _gems)
         {
            _loc8_ = false;
            if(_loc4_.loader.content)
            {
               if(!_loc4_.loader.visible)
               {
                  _guiLayer.addChild(_loc4_.loader);
                  _loc4_.loader.visible = true;
               }
               _loc4_.loader.x += _loc4_.ox;
               _loc4_.loader.y += _loc4_.oy;
            }
            if(_loc4_.ox > 0 && _loc4_.loader.x > _loc4_.tx || _loc4_.ox < 0 && _loc4_.loader.x < _loc4_.tx)
            {
               _loc8_ = true;
            }
            else if(_loc4_.oy > 0 && _loc4_.loader.y > _loc4_.ty || _loc4_.oy < 0 && _loc4_.loader.y < _loc4_.ty)
            {
               _loc8_ = true;
            }
            if(_loc8_)
            {
               _loc9_ = _gems.indexOf(_loc4_);
               _gems.splice(_loc9_,1);
               _loc4_.loader.parent.removeChild(_loc4_.loader);
               _scene.releaseCloneAsset(_loc4_.loader);
               _score += _loc4_.points;
               updateScore();
            }
         }
         if(!_gems.length && _bLevelComplete)
         {
            endLevel();
         }
      }
      
      private function launchBall() : void
      {
         _bBallInMotion = true;
         _springOffset = 0;
         var _loc1_:Number = -(_springForce * 3.7 + 180 + Math.random() * 10);
         _ballBody.m_force = new b2Vec2(0,_loc1_);
         _springMode = 4;
      }
      
      private function processCollision(param1:Object) : void
      {
         var _loc7_:int = 0;
         var _loc6_:String = null;
         var _loc3_:Boolean = false;
         var _loc2_:int = 0;
         if(param1 == null || !param1.hasOwnProperty("name"))
         {
            return;
         }
         var _loc5_:int = -1;
         var _loc4_:int = -1;
         switch(param1.name)
         {
            case "col":
               _loc6_ = _soundNamePin;
               break;
            case "score":
               _loc5_ = int(param1.message);
               break;
            case "jackpot_1":
               _loc4_ = 0;
               break;
            case "jackpot_2":
               _loc4_ = 1;
               break;
            case "jackpot_3":
               _loc4_ = 2;
               break;
            case "ball_catch":
               _bBallInMotion = false;
               break;
            case "ball_inplay":
               enableEntryBlock(true);
         }
         if(_loc4_ >= 0 && !_clearJackpot)
         {
            if(!_jackpot[_loc4_])
            {
               _jackpot[_loc4_] = true;
               _loc3_ = true;
            }
            refreshJackpotIcons();
            _loc2_ = 0;
            _loc7_ = 0;
            while(_loc7_ < 3)
            {
               if(_jackpot[_loc7_] == true)
               {
                  _loc2_++;
               }
               _loc7_++;
            }
            if(_loc3_)
            {
               switch(_loc2_ - 1)
               {
                  case 0:
                     _soundMan.playByName(_soundNameJackpot1);
                     break;
                  case 1:
                     _soundMan.playByName(_soundNameJackpot2);
                     break;
                  case 2:
                     _soundMan.playByName(_soundNameJackpot3);
                     _clearJackpot = true;
                     showJackpotDlg();
                     _jackpotCount = _jackpotCount + 1;
                     if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
                     {
                        AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,_jackpotCount);
                        _displayAchievementTimer = 1;
                     }
               }
            }
         }
         if(_loc5_ >= 0)
         {
            if(_clearJackpot)
            {
               _loc7_ = 0;
               while(_loc7_ < 3)
               {
                  _jackpot[_loc7_] = false;
                  _loc7_++;
               }
               refreshJackpotIcons();
               _clearJackpot = false;
            }
            _bBallInMotion = false;
            _loc6_ = _soundNamePoints;
            if(_loc5_ > 0)
            {
               AddScore(_loc5_);
            }
         }
         if(_loc6_)
         {
            _soundMan.playByName(_loc6_);
         }
      }
      
      private function enableEntryBlock(param1:Boolean) : void
      {
         var _loc2_:b2Shape = _volumeBlockEntry.m_shapeList;
         _loc2_.m_isSensor = !param1;
      }
      
      private function onMouseDown(param1:MouseEvent) : void
      {
         startPullSpring();
      }
      
      private function onMouseUp(param1:MouseEvent) : void
      {
         releaseSpring();
      }
      
      private function onKeyDown(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 32)
         {
            startPullSpring();
         }
      }
      
      private function onKeyUp(param1:KeyboardEvent) : void
      {
         if(param1.keyCode == 32)
         {
            releaseSpring();
         }
         else if(param1.keyCode == 81)
         {
            showExitConfirmationDlg();
         }
      }
      
      private function startPullSpring() : void
      {
         if(!_bBallInMotion && _balls >= 0 && !_pauseGame && _springStart == 0)
         {
            _springStart = getTimer();
            _springMode = 1;
            _soundMan.playByName(_soundNamePullSpring);
         }
      }
      
      private function releaseSpring() : void
      {
         if(_springStart && _springMode == 1)
         {
            _springMode = 2;
         }
      }
      
      private function startLevel() : void
      {
         var _loc1_:int = 0;
         _totalGameTime = 0;
         _jackpotCount = 0;
         _bLevelComplete = false;
         _springMode = 0;
         _score = 0;
         _balls = 10 - 1;
         _ballBody.m_userData.loader.visible = true;
         while(_loc1_ < 3)
         {
            _jackpot[_loc1_] = false;
            _loc1_++;
         }
         refreshBallIcons();
         refreshJackpotIcons();
         updateScore();
      }
      
      private function endLevel() : void
      {
         var _loc1_:* = null;
         var _loc2_:int = 0;
         showGameOverDlg();
         for each(_loc1_ in _gems)
         {
            _loc2_ = _gems.indexOf(_loc1_);
            _gems.splice(_loc2_,1);
            if(_loc1_.loader.parent)
            {
               _loc1_.loader.parent.removeChild(_loc1_.loader);
            }
         }
         addGemsToBalance(_score);
      }
      
      private function refreshBallIcons() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 10)
         {
            _ballIcon[_loc1_].loader.visible = _loc1_ < _balls;
            _loc1_++;
         }
      }
      
      private function refreshJackpotIcons() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < 3)
         {
            if(_jackpot[_loc1_])
            {
               _jackpotIcons[_loc1_].loader.content.gotoAndPlay("on");
            }
            else
            {
               _jackpotIcons[_loc1_].loader.content.gotoAndStop("off");
            }
            _loc1_++;
         }
      }
      
      private function updateScore() : void
      {
         _scoreCtrl.loader.content.score.text = _score;
      }
      
      public function onGemCloneComplete(param1:Event) : void
      {
         param1.target.content.gotoAndPlay("collect");
         param1.target.removeEventListener("complete",onGemCloneComplete);
      }
      
      private function AddScore(param1:int) : void
      {
         var _loc5_:Object = _scene.cloneAsset("score_gem");
         var _loc6_:Loader = _loc5_.loader;
         _loc5_.loader.contentLoaderInfo.addEventListener("complete",onGemCloneComplete);
         _loc6_.x = _ballBody.m_userData.loader.x - 10;
         _loc6_.y = _ballBody.m_userData.loader.y - _loc5_.height / 2;
         _loc6_.scaleX = 1;
         _loc6_.scaleY = 1;
         _loc6_.visible = false;
         var _loc3_:int = _scoreCtrl.loader.x + _scoreCtrl.loader.width / 2;
         var _loc2_:int = _loc6_.y - 1;
         var _loc4_:int = 30;
         var _loc7_:Number = 0;
         var _loc8_:Number = (_loc2_ - _loc6_.y) / _loc4_;
         _loc5_ = {
            "loader":_loc6_,
            "ox":_loc7_,
            "oy":_loc8_,
            "tx":_loc3_,
            "ty":_loc2_,
            "points":param1
         };
         _gems.push(_loc5_);
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
         stage.removeEventListener("keyDown",replayKeyDown);
         hideDlg();
         if(showGemMultiplierDlg(onGemMultiplierDone) == null)
         {
            exit();
         }
      }
      
      private function onGemMultiplierDone() : void
      {
         hideDlg();
         exit();
      }
      
      private function onExit_No() : void
      {
         hideDlg();
      }
      
      private function showGameOverDlg() : void
      {
         var _loc1_:MovieClip = showDlg("pachinko_greatjob",[{
            "name":"button_yes",
            "f":GameOverDlg_close
         },{
            "name":"button_no",
            "f":onExit_Yes
         }]);
         _loc1_.x = 450;
         _loc1_.y = 275;
         LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,_score);
         if(_jackpotPopup)
         {
            _jackpotCountdown = 0;
            JackpotDlg_Heartbeat();
         }
         stage.addEventListener("keyDown",replayKeyDown);
      }
      
      private function replayKeyDown(param1:KeyboardEvent) : void
      {
         switch(param1.keyCode)
         {
            case 13:
            case 32:
               GameOverDlg_close();
               break;
            case 8:
            case 46:
            case 27:
               onExit_Yes();
         }
      }
      
      private function GameOverDlg_close() : void
      {
         stage.removeEventListener("keyDown",replayKeyDown);
         if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
         {
            AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).gameCountUserVarRef,1);
            _displayAchievementTimer = 1;
         }
         startLevel();
         hideDlg();
      }
      
      private function showJackpotDlg() : void
      {
         var _loc1_:MovieClip = showDlg("pachinko_jackpot",null,0,0,false);
         _loc1_.x = 450;
         _loc1_.y = 275;
         LocalizationManager.translateIdAndInsert(_loc1_.text_score,11432,75);
         AddScore(75);
         _jackpotPopup = _loc1_;
         _jackpotCountdown = 36;
      }
      
      private function JackpotDlg_Heartbeat() : void
      {
         if(_jackpotCountdown > 0)
         {
            _jackpotCountdown = _jackpotCountdown - 1;
         }
         if(_jackpotCountdown == 0)
         {
            _jackpotPopup.parent.removeChild(_jackpotPopup);
            _jackpotPopup = null;
         }
      }
      
      private function disableInput() : void
      {
         if(_inputEnabled)
         {
            stage.removeEventListener("keyDown",onKeyDown);
            stage.removeEventListener("keyUp",onKeyUp);
            stage.removeEventListener("mouseUp",onMouseUp);
            stage.removeEventListener("mouseDown",onMouseDown);
            _inputEnabled = false;
         }
      }
      
      private function enableInput() : void
      {
         if(!_inputEnabled)
         {
            stage.addEventListener("keyDown",onKeyDown);
            stage.addEventListener("keyUp",onKeyUp);
            stage.addEventListener("mouseUp",onMouseUp);
            stage.addEventListener("mouseDown",onMouseDown);
            _inputEnabled = true;
         }
      }
   }
}

