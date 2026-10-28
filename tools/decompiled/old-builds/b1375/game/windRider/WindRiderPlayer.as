package game.windRider
{
   import achievement.AchievementXtCommManager;
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarView;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import game.MinigameManager;
   import gskinner.motion.GTween;
   
   public class WindRiderPlayer
   {
      
      public static const PLAYER_SCREEN_Y:Number = 450;
      
      private static const MAX_GRAVITY:Number = 2050;
      
      private static const MAX_ACCELERATION:int = 1000;
      
      private static const SIDE_ACCELERATION:int = 2750;
      
      private static const MAX_SPEED_FREEFALL:int = 750;
      
      private static const MAX_SIDE_SPEED_FREEFALL:int = 385;
      
      private static const MAX_SPEED_PARACHUTE:int = 200;
      
      private static const MAX_SIDE_SPEED_PARACHUTE:int = 300;
      
      private static const OBSTACLE_GEMS:int = 5;
      
      private static const JUMP_ACCELERATION:int = -1300;
      
      private static const MAX_FALL_HEIGHT:int = 500;
      
      private var _maxSpeed:Number;
      
      private var _maxSideSpeed:Number;
      
      public var _lastFrameVelocity:Point;
      
      public var _currentVelocity:Point;
      
      public var _currentAcceleration:Point;
      
      public var _serverVelocity:Point;
      
      public var _serverAcceleration:Point;
      
      public var _serverPosition:Point;
      
      public var _radius:int;
      
      public var _centerPointOffsetX:int;
      
      public var _centerPointOffsetY:int;
      
      public var _landed:Boolean;
      
      private var _landedReceived:int;
      
      public var _fallingTimer:Number;
      
      public var _falling:Boolean;
      
      private var _openChuteY:Number;
      
      public var _theGame:WindRider;
      
      public var _gemCount:int;
      
      public var _localPlayer:Boolean;
      
      public var _clone:AvatarView;
      
      private var _parachute:Object;
      
      private var _parachuteFrame:Sprite;
      
      public var _alpha:Number;
      
      private var _dropGems:Object;
      
      public var _parachuteActive:Boolean;
      
      public var _obstacleHitTimer:Number;
      
      public var _progressbar:Object;
      
      public var _lastCloudHitY:Number;
      
      public var _cloudHitSound:int;
      
      public var _animsLoaded:Boolean;
      
      public function WindRiderPlayer(param1:WindRider)
      {
         super();
         _lastFrameVelocity = new Point();
         _currentVelocity = new Point();
         _currentAcceleration = new Point();
         _serverVelocity = new Point();
         _serverAcceleration = new Point();
         _serverPosition = new Point();
         _radius = 30;
         _centerPointOffsetX = -20;
         _centerPointOffsetY = -35;
         _localPlayer = true;
         _theGame = param1;
      }
      
      public function init(param1:int, param2:Number, param3:Object, param4:Object) : void
      {
         _lastCloudHitY = 60000;
         _cloudHitSound = 1;
         _openChuteY = param2;
         _maxSpeed = 750;
         _maxSideSpeed = 385;
         _falling = false;
         _obstacleHitTimer = 0;
         _landedReceived = 0;
         _gemCount = 0;
         _alpha = 0;
         _landed = false;
         _parachuteActive = false;
         _progressbar = param4;
         _parachute = param3;
         _parachuteFrame = new Sprite();
         _parachuteFrame.addChild(_parachute.loader);
         _dropGems = _theGame.getScene().cloneAsset("dropGems");
         var _loc6_:AvatarInfo = gMainFrame.userInfo.playerAvatarInfo;
         var _loc5_:Avatar = new Avatar();
         _loc5_.init(_loc6_.perUserAvId,_loc6_.avName,_loc6_.type,_loc6_.colors,_loc6_.customAvId,null,gMainFrame.userInfo.myUserName);
         _clone = new AvatarView();
         _clone.init(_loc5_);
         _serverPosition.x = 450;
         _serverPosition.y = _theGame._ground.clone.loader.y + _radius;
         _clone.x = _serverPosition.x;
         _clone.y = _serverPosition.y;
         var _loc7_:Array = new Array(6);
         _loc7_[0] = 29;
         _loc7_[1] = 28;
         _loc7_[2] = 30;
         _loc7_[3] = 20;
         _loc7_[4] = 31;
         _loc7_[5] = 23;
         _animsLoaded = false;
         _clone.preloadAnims(_loc7_,redrawCallback);
      }
      
      public function reset() : void
      {
         _lastCloudHitY = 60000;
         _falling = false;
         _obstacleHitTimer = 0;
         _landedReceived = 0;
         _gemCount = 0;
         _landed = false;
         _parachuteActive = false;
         _serverPosition.x = 450;
         _serverPosition.y = _theGame._ground.clone.loader.y + _radius;
         _clone.x = _serverPosition.x;
         _clone.y = _serverPosition.y;
         playAnimationState(31);
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(param1 && _clone)
         {
            _alpha = 1;
            playAnimationState(31);
            _theGame._layerPlayers.addChild(_dropGems.loader);
            _theGame._layerPlayers.addChild(_parachuteFrame);
            _theGame._layerPlayers.addChild(_clone);
            _animsLoaded = true;
         }
      }
      
      public function remove() : void
      {
         if(_dropGems)
         {
            if(_dropGems.loader.parent)
            {
               _dropGems.loader.parent.removeChild(_dropGems.loader);
            }
            _theGame.getScene().releaseCloneAsset(_dropGems.loader);
            _dropGems = null;
         }
         if(_clone && _clone.parent)
         {
            _clone.parent.removeChild(_clone);
            _clone.destroy();
            _clone = null;
         }
         if(_parachute && _parachute.loader.parent)
         {
            _parachute.loader.parent.removeChild(_parachute.loader);
            _parachute = null;
         }
         if(_parachuteFrame && _parachuteFrame.parent)
         {
            _parachuteFrame.parent.removeChild(_parachuteFrame);
            _parachuteFrame = null;
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc11_:int = 0;
         var _loc22_:Point = null;
         var _loc3_:Boolean = false;
         var _loc17_:* = null;
         var _loc14_:Number = NaN;
         var _loc18_:int = 0;
         var _loc12_:Object = null;
         var _loc8_:* = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc7_:Boolean = false;
         var _loc5_:* = null;
         var _loc19_:Rectangle = null;
         var _loc10_:Rectangle = null;
         var _loc20_:Array = null;
         var _loc4_:Point = null;
         var _loc2_:Point = null;
         var _loc6_:Point = null;
         var _loc13_:Number = NaN;
         var _loc21_:Number = NaN;
         _clone.alpha = _alpha;
         if(_animsLoaded == false)
         {
            return;
         }
         if(!_landed)
         {
            if(_falling && _fallingTimer > 0)
            {
               _fallingTimer -= param1;
               if(_fallingTimer <= 0 || _serverPosition.y > _theGame._ground.clone.loader.y)
               {
                  _fallingTimer = 0;
                  _theGame.playerFell(this);
               }
            }
            if(_landedReceived == 0)
            {
               _loc22_ = new Point();
               if(_serverAcceleration.y < 1000)
               {
                  _serverAcceleration.y += 2050 * param1;
               }
               _loc3_ = _serverVelocity.y < 0;
               _serverVelocity.y += param1 * _serverAcceleration.y;
               if(_serverVelocity.y > _maxSpeed)
               {
                  _serverVelocity.y -= 3 * 2050 * param1;
                  if(_serverVelocity.y < _maxSpeed)
                  {
                     _serverVelocity.y = _maxSpeed;
                  }
               }
               if(!_falling && _loc3_ && _serverVelocity.y >= 0)
               {
                  playAnimationState(30);
               }
               if(_serverAcceleration.x != 0)
               {
                  _serverVelocity.x += param1 * _serverAcceleration.x;
                  if(_serverVelocity.x > _maxSideSpeed)
                  {
                     _serverVelocity.x -= 2750 * param1;
                     if(_serverVelocity.x < _maxSideSpeed)
                     {
                        _serverVelocity.x = _maxSideSpeed;
                     }
                  }
                  else if(_serverVelocity.x < -_maxSideSpeed)
                  {
                     _serverVelocity.x += 2750 * param1;
                     if(_serverVelocity.x > -_maxSideSpeed)
                     {
                        _serverVelocity.x = -_maxSideSpeed;
                     }
                  }
               }
               else if(_serverVelocity.x > 0)
               {
                  _serverVelocity.x -= 2750 * param1;
                  if(_serverVelocity.x < 0)
                  {
                     _serverVelocity.x = 0;
                  }
               }
               else if(_serverVelocity.x < 0)
               {
                  _serverVelocity.x += 2750 * param1;
                  if(_serverVelocity.x > 0)
                  {
                     _serverVelocity.x = 0;
                  }
               }
               _lastFrameVelocity.x = param1 * _serverVelocity.x;
               _lastFrameVelocity.y = param1 * _serverVelocity.y;
               _loc22_.x = _serverPosition.x + _centerPointOffsetX;
               _loc22_.y = _serverPosition.y + _centerPointOffsetY;
               if(_lastFrameVelocity.x != 0)
               {
                  _serverPosition.x += _lastFrameVelocity.x;
                  if(_serverPosition.x > 850)
                  {
                     _serverPosition.x = 850;
                  }
                  else if(_serverPosition.x - _radius < 50)
                  {
                     _serverPosition.x = 50 + _radius;
                  }
               }
               _serverPosition.y += _lastFrameVelocity.y;
               if(!_falling && _serverVelocity.y > 0)
               {
                  _loc14_ = 0;
                  _loc18_ = 0;
                  _loc12_ = null;
                  for each(_loc17_ in _theGame._cloudsActive)
                  {
                     if(_loc17_.loader.y > _loc14_)
                     {
                        _loc14_ = Number(_loc17_.loader.y);
                        _loc18_ = 1;
                     }
                     else if(_loc17_.loader.y == _loc14_)
                     {
                        _loc18_++;
                     }
                     if(_loc12_ == null && _loc17_.bounceTimer <= 0 && _loc22_.y <= _loc17_.loader.y + _loc17_.height / 2 && _serverPosition.y >= _loc17_.loader.y + _loc17_.height / 2 && _serverPosition.x >= _loc17_.loader.x && _serverPosition.x <= _loc17_.loader.x + _loc17_.width)
                     {
                        _loc12_ = _loc17_;
                     }
                  }
                  if(_loc12_)
                  {
                     hitCloud(_loc12_);
                     if(_loc18_ == 1 || _loc12_.loader.y < _loc14_)
                     {
                        _theGame.groundOff();
                     }
                  }
                  if(_theGame._groundOff && _serverVelocity.y > 0 && _serverPosition.y > _loc14_ + _loc17_.height + 10)
                  {
                     setFalling();
                  }
               }
            }
            else
            {
               _landedReceived = _landedReceived - 1;
               if(_landedReceived == 0)
               {
                  setLanded();
               }
            }
            if(_serverVelocity.x != 0)
            {
               _parachuteFrame.rotation = 7 * _serverVelocity.x / _maxSideSpeed;
            }
            else
            {
               _clone.rotation = 0;
               _parachuteFrame.rotation = 0;
            }
            if(_localPlayer)
            {
               _loc7_ = false;
               _clone.x = _serverPosition.x;
               _clone.y = _serverPosition.y;
               if(!_falling)
               {
                  _loc11_ = _theGame._gemsActive.length - 1;
                  while(_loc11_ >= 0)
                  {
                     _loc15_ = _theGame._gemsActive[_loc11_].loader.x + _theGame._gemsActive[_loc11_].width / 2 - (_clone.x + _centerPointOffsetX);
                     _loc16_ = _theGame._gemsActive[_loc11_].loader.y + _theGame._gemsActive[_loc11_].height / 2 - (_clone.y + _centerPointOffsetY);
                     _loc9_ = _radius + _theGame._gemsActive[_loc11_].width / 2;
                     _loc15_ *= _loc15_;
                     _loc16_ *= _loc16_;
                     if(_loc15_ + _loc16_ < _loc9_ * _loc9_)
                     {
                        _gemCount = _gemCount + 1;
                        _theGame.gemPickup(_loc11_);
                        _theGame._soundMan.playByName(_theGame._soundNameGemAdded);
                        break;
                     }
                     _loc11_--;
                  }
               }
               if(_obstacleHitTimer > 0)
               {
                  _obstacleHitTimer -= param1;
               }
               if(!_falling)
               {
                  if(_obstacleHitTimer <= 0)
                  {
                     _loc19_ = new Rectangle(_serverPosition.x + _centerPointOffsetX,_serverPosition.y + _centerPointOffsetY,_radius,_radius);
                     _loc10_ = new Rectangle();
                     for each(_loc5_ in _theGame._branchesActive)
                     {
                        if(_loc5_.loader.scaleX < 0)
                        {
                           _loc10_.x = _loc5_.loader.x - _loc5_.width;
                        }
                        else
                        {
                           _loc10_.x = _loc5_.loader.x;
                        }
                        _loc10_.y = _loc5_.loader.y;
                        _loc10_.width = _loc5_.width;
                        _loc10_.height = _loc5_.height;
                        if(_loc19_.intersects(_loc10_))
                        {
                           hitObstacle();
                           _loc5_.loader.content.gotoAndPlay("on");
                           break;
                        }
                     }
                  }
                  for each(_loc5_ in _theGame._phantomsActive)
                  {
                     if(_loc5_.polluteTimer <= 0 && _loc5_.phantom.loader.content)
                     {
                        _loc15_ = _loc5_.phantom.loader.x + _loc5_.phantom.loader.content.collision.x + _loc5_.phantom.loader.content.collision.width / 2 - (_clone.x + _centerPointOffsetX);
                        _loc16_ = _loc5_.phantom.loader.y + _loc5_.phantom.loader.content.collision.y + _loc5_.phantom.loader.content.collision.height / 2 - (_clone.y + _centerPointOffsetY);
                        _loc9_ = _radius + _loc5_.phantom.loader.content.collision.width / 2;
                        _loc15_ *= _loc15_;
                        _loc16_ *= _loc16_;
                        if(_loc15_ + _loc16_ < _loc9_ * _loc9_)
                        {
                           _loc5_.polluteTimer = 1;
                           if(_loc5_.phantom.loader.content)
                           {
                              _loc5_.phantom.loader.content.gotoAndPlay("Pollute");
                              _loc5_.phantom.loader.content.currentLoop = "Pollute";
                              _loc5_.phantom.loader.content.transition = null;
                           }
                           _theGame._soundMan.playByName(_theGame._soundNamePhantomShock);
                           hitObstacle();
                           setFalling();
                           break;
                        }
                     }
                  }
                  if(!_theGame._groundOff && _serverVelocity.y > 0 && _theGame._ground.clone && _theGame._ground.clone.loader.parent)
                  {
                     _loc22_.x = _serverPosition.x + _centerPointOffsetX;
                     _loc22_.y = _serverPosition.y + _centerPointOffsetY;
                     if(_lastFrameVelocity.y != 0)
                     {
                        if(_loc22_.y + _radius >= _theGame._ground.clone.loader.y)
                        {
                           _loc20_ = _theGame._ground.volumePoints;
                           _loc4_ = new Point();
                           _loc2_ = new Point();
                           _loc11_ = 0;
                           while(_loc11_ < _loc20_.length - 1)
                           {
                              _loc4_.x = _loc20_[_loc11_].x + _theGame._ground.clone.loader.x;
                              _loc2_.x = _loc20_[_loc11_ + 1].x + _theGame._ground.clone.loader.x;
                              _loc4_.y = _loc20_[_loc11_].y + _theGame._ground.clone.loader.y;
                              _loc2_.y = _loc20_[_loc11_ + 1].y + _theGame._ground.clone.loader.y;
                              if(Collision.movingCircleVsRay(_loc22_,_radius,_lastFrameVelocity,1,_loc4_,_loc2_) >= 0)
                              {
                                 _serverVelocity.y = 0;
                                 _serverAcceleration.y = -1300;
                                 playAnimationState(28);
                                 playCloudHitSound();
                                 break;
                              }
                              _loc11_++;
                           }
                        }
                     }
                  }
               }
               if(_theGame._rightArrowDown)
               {
                  _serverAcceleration.x = 2750;
               }
               else if(_theGame._leftArrowDown)
               {
                  _serverAcceleration.x = -2750;
               }
               else
               {
                  _serverAcceleration.x = 0;
               }
            }
            else if(_landed)
            {
               _clone.x = _serverPosition.x;
               _clone.y = _serverPosition.y;
            }
            else
            {
               _loc6_ = new Point();
               _loc6_.x = _clone.x;
               _loc6_.y = _clone.y;
               _loc13_ = Point.distance(_loc6_,_serverPosition);
               _currentVelocity.x = _serverPosition.x - _clone.x;
               _currentVelocity.y = _serverPosition.y - _clone.y;
               _loc21_ = 0.2;
               _clone.x += _currentVelocity.x * _loc21_;
               _clone.y += _currentVelocity.y * _loc21_;
            }
            updateParachute();
         }
         else
         {
            _clone.rotation = 0;
            _parachuteFrame.rotation = 0;
         }
      }
      
      public function getScreenY() : Number
      {
         return _clone.y;
      }
      
      private function playAnimationState(param1:int) : void
      {
         var _loc2_:Function = null;
         var _loc3_:int = 0;
         switch(param1 - 20)
         {
            case 3:
               _loc3_ = 0;
               break;
            case 8:
               _loc3_ = 0;
               _loc2_ = animationAtEnd;
               break;
            case 10:
            case 11:
         }
         _clone.playAnim(param1,false,_loc3_,_loc2_);
         if(_parachute)
         {
            updateParachute();
         }
      }
      
      private function animationAtEnd(param1:LayerAnim, param2:int) : void
      {
         if(_clone && param1)
         {
            switch(param2 - 21)
            {
               case 7:
                  playAnimationState(30);
                  break;
               case 9:
                  playAnimationState(30);
            }
         }
      }
      
      private function updateParachute() : void
      {
         if(_parachuteFrame)
         {
            _parachuteFrame.x = _clone.x - 112 + _parachute.loader.width / 2;
            _parachuteFrame.y = _clone.y - 230 + _parachute.loader.height;
            _parachute.loader.x = -_parachute.loader.width / 2;
            _parachute.loader.y = -_parachute.loader.height;
            if(_dropGems)
            {
               _dropGems.loader.x = _clone.x - 50;
               _dropGems.loader.y = _clone.y - 50;
            }
         }
      }
      
      public function openParachute() : void
      {
         if(_parachute.loader.content)
         {
            _maxSpeed = 200;
            _maxSideSpeed = 300;
            _parachute.loader.content.transition = "chuteOpen";
            _parachuteActive = true;
         }
      }
      
      public function hitCloud(param1:Object) : void
      {
         _serverVelocity.y = 0;
         if(param1.endCloud)
         {
            _gemCount += 100;
            _serverAcceleration.y = 0;
            _theGame._treasure.loader.content.gotoAndPlay("on");
            _theGame._soundMan.playByName(_theGame._soundNameTreasureChest);
            _theGame._soundMan.playByName(_theGame._soundNamePlayerWin);
            _landed = true;
            playAnimationState(23);
            _theGame.sendGameWin();
            if(MinigameManager.minigameInfoCache && MinigameManager.minigameInfoCache.currMinigameId != -1)
            {
               AchievementXtCommManager.requestSetUserVar(MinigameManager.minigameInfoCache.getMinigameInfo(MinigameManager.minigameInfoCache.currMinigameId).custom1UserVarRef,1);
            }
         }
         else
         {
            _serverAcceleration.y = -1300;
            playAnimationState(28);
            param1.loader.content.gotoAndPlay("on");
            param1.bounceTimer = 1.5;
            playCloudHitSound();
            if(param1.loader.y < _lastCloudHitY)
            {
               _lastCloudHitY = param1.loader.y;
            }
         }
      }
      
      private function playCloudHitSound() : void
      {
         if(_cloudHitSound == 1)
         {
            _theGame._soundMan.playByName(_theGame._soundNameCloudBurst1);
         }
         else if(_cloudHitSound == 2)
         {
            _theGame._soundMan.playByName(_theGame._soundNameCloudBurst2);
         }
         else
         {
            _theGame._soundMan.playByName(_theGame._soundNameCloudBurst3);
         }
         _cloudHitSound = _cloudHitSound + 1;
         if(_cloudHitSound > 3)
         {
            _cloudHitSound = 1;
         }
      }
      
      public function hitObstacle() : void
      {
         _gemCount -= 5;
         if(_gemCount < 0)
         {
            _gemCount = 0;
         }
         _obstacleHitTimer = 0.5;
         if(!_dropGems.loader.content.dropGems)
         {
            _dropGems.loader.content.dropGems = true;
         }
      }
      
      public function setFalling() : void
      {
         if(!_falling)
         {
            _falling = true;
            _fallingTimer = 1;
            playAnimationState(20);
            if(_theGame._musicLoop)
            {
               _theGame._musicLoop.stop();
               _theGame._musicLoop = null;
            }
            _theGame._soundMan.playByName(_theGame._soundNamePlayerLose);
         }
      }
      
      public function setLanded() : void
      {
         _landed = true;
         new GTween(this,0.5,{"_alpha":0});
         playAnimationState(21);
      }
   }
}

