package game.parachuteGlider
{
   import avatar.Avatar;
   import avatar.AvatarInfo;
   import avatar.AvatarManager;
   import avatar.AvatarUtility;
   import avatar.AvatarView;
   import com.sbi.corelib.math.Collision;
   import com.sbi.graphics.LayerAnim;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import gskinner.motion.GTween;
   
   public class ParachuteGliderPlayer
   {
      
      private static const MAX_GRAVITY:Number = 300;
      
      private static const MAX_ACCELERATION:int = 150;
      
      private static const JUMP_ACCELERATION:int = 225;
      
      private static const SIDE_ACCELERATION:int = 700;
      
      private static const MAX_SPEED:int = 150;
      
      private static const MAX_SIDE_SPEED:int = 200;
      
      private static const MAX_SIDE_WIND_SPEED:int = 275;
      
      private static const MAX_WIND_SPEED:int = 150;
      
      private static const MAX_WIND_DRAG:Number = 5000;
      
      private static const MAX_WIND_ACCELERATOR:Number = 2500;
      
      private static const JUMP_HOLD_TIME:Number = 0.15;
      
      private static const PHANTOM_HOLD_TIME:Number = 0.25;
      
      private static const HITTYPE_NONE:int = 0;
      
      private static const HITTYPE_BRANCH:int = 1;
      
      private static const HITTYPE_PHANTOM:int = 2;
      
      private static const HITTYPE_WIND:int = 3;
      
      private static const HITTYPE_LAND:int = 4;
      
      private static const POLLUTETIMER:Number = 3.5;
      
      private static const POLLUTETIMER_RETURN_TO_IDLE:Number = 2.25;
      
      private static const POSITION_UPDATE_TIME:Number = 0.25;
      
      public var _theGame:ParachuteGlider;
      
      public var _localPlayer:Boolean;
      
      public var _netID:int;
      
      public var _clone:AvatarView;
      
      public var _updatePositionTimer:Number;
      
      public var _lastFrameVelocity:Point;
      
      public var _currentVelocity:Point;
      
      public var _currentAcceleration:Point;
      
      public var _serverWindTargetAcceleration:Point;
      
      public var _serverWindAcceleration:Point;
      
      public var _serverVelocity:Point;
      
      public var _serverAcceleration:Point;
      
      public var _serverPosition:Point;
      
      public var _serverHitType:int;
      
      public var _gemCount:int;
      
      public var _radius:int;
      
      public var _centerPointOffsetX:int;
      
      public var _centerPointOffsetY:int;
      
      public var _waitingForAllLoaded:Boolean;
      
      private var _parachute:Object;
      
      private var _parachuteFrame:Sprite;
      
      private var _dropGems:Object;
      
      private var _polluteTimer:Number;
      
      private var _lastTreeBranchHit:Object;
      
      public var _landed:Boolean;
      
      private var _landedReceived:int;
      
      private var _positionHoldTimer:Number;
      
      public var _progressbar:Object;
      
      public var _alpha:Number;
      
      public var _phantomsHit:int;
      
      public function ParachuteGliderPlayer(param1:ParachuteGlider)
      {
         super();
         _theGame = param1;
         _lastFrameVelocity = new Point();
         _currentVelocity = new Point();
         _currentAcceleration = new Point();
         _serverVelocity = new Point();
         _serverWindAcceleration = new Point();
         _serverWindTargetAcceleration = new Point();
         _serverAcceleration = new Point();
         _serverPosition = new Point();
         _polluteTimer = 0;
         _landed = false;
         _landedReceived = 0;
         _positionHoldTimer = 0;
         _alpha = 0;
         _phantomsHit = 0;
         _radius = 30;
         _centerPointOffsetX = -20;
         _centerPointOffsetY = -35;
      }
      
      public function preloadAnims(param1:String, param2:int) : void
      {
         _waitingForAllLoaded = true;
         var _loc4_:AvatarInfo = gMainFrame.userInfo.getAvatarInfoByUsernamePerUserAvId(param1,param2);
         var _loc3_:Avatar = new Avatar();
         if(_loc4_)
         {
            _loc3_.init(_loc4_.perUserAvId,_loc4_.avName,_loc4_.type,_loc4_.colors,_loc4_.customAvId,null,param1);
         }
         else
         {
            _loc3_ = AvatarUtility.generateNew(param2,_loc3_,param1,AvatarManager.roomEnviroType);
         }
         _clone = new AvatarView();
         _clone.init(_loc3_);
         var _loc5_:Array = new Array(4);
         _loc5_[0] = 19;
         _loc5_[1] = 24;
         _loc5_[2] = 20;
         _loc5_[3] = 21;
         _clone.preloadAnims(_loc5_,redrawCallback);
      }
      
      public function init(param1:Array, param2:int, param3:Object, param4:Object) : int
      {
         _progressbar = param4;
         _netID = parseInt(param1[param2++]);
         _parachute = param3;
         _parachuteFrame = new Sprite();
         _parachute.loader.contentLoaderInfo.addEventListener("complete",onParachuteLoaderComplete);
         _dropGems = _theGame.getScene().cloneAsset("dropGems");
         _serverPosition.x = parseInt(param1[param2++]);
         _serverPosition.y = parseInt(param1[param2++]);
         _serverPosition.y = 300;
         _clone.x = _serverPosition.x;
         _clone.y = _serverPosition.y;
         _serverHitType = 0;
         _gemCount = 0;
         _updatePositionTimer = 0;
         _localPlayer = _theGame.myId == _netID;
         _alpha = 1;
         playAnimationState(19);
         _theGame._layerPlayers.addChild(_dropGems.loader);
         _parachuteFrame.addChild(_parachute.loader);
         _theGame._layerPlayers.addChild(_parachuteFrame);
         _theGame._layerPlayers.addChild(_clone);
         _updatePositionTimer = 0;
         return param2;
      }
      
      private function redrawCallback(param1:LayerAnim) : void
      {
         if(param1 && _clone)
         {
            _waitingForAllLoaded = false;
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
         if(_parachute)
         {
            if(_parachute.loader.parent)
            {
               _parachute.loader.parent.removeChild(_parachute.loader);
            }
            _theGame.getScene().releaseCloneAsset(_parachute.loader);
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
         var _loc12_:int = 0;
         var _loc19_:* = 0;
         var _loc2_:* = null;
         var _loc21_:Boolean = false;
         var _loc22_:Point = null;
         var _loc13_:Rectangle = null;
         var _loc11_:Number = NaN;
         var _loc6_:Object = null;
         var _loc10_:Array = null;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc8_:Boolean = false;
         var _loc18_:Boolean = false;
         var _loc17_:Array = null;
         var _loc5_:Point = null;
         var _loc4_:Point = null;
         var _loc7_:Point = null;
         var _loc14_:Number = NaN;
         var _loc20_:Number = NaN;
         if(!_waitingForAllLoaded)
         {
            _clone.alpha = _alpha;
            if(!_landed)
            {
               if(_landedReceived == 0)
               {
                  _loc19_ = -1;
                  _loc21_ = false;
                  _loc22_ = new Point();
                  if(_polluteTimer > 2.25)
                  {
                     _polluteTimer -= param1;
                     if(_polluteTimer <= 2.25)
                     {
                        playAnimationState(19);
                     }
                  }
                  else if(_polluteTimer > 0)
                  {
                     _polluteTimer -= param1;
                  }
                  if(_positionHoldTimer > 0)
                  {
                     _positionHoldTimer -= param1;
                     _lastFrameVelocity.x = 0;
                     _lastFrameVelocity.y = 0;
                  }
                  else
                  {
                     for each(_loc2_ in _theGame._winds)
                     {
                        if(_loc2_.clone)
                        {
                           _loc13_ = _loc2_.clone.getBounds(_theGame._layerWinds);
                           if(_serverPosition.x > _loc13_.x && _serverPosition.x < _loc13_.x + _loc13_.width && _serverPosition.y > _loc13_.y && _serverPosition.y < _loc13_.y + _loc13_.height)
                           {
                              if(_loc2_.ySpeed >= 0 || _serverWindAcceleration.y != 0 || _serverPosition.y > _loc13_.y + 50)
                              {
                                 if(_serverWindAcceleration.x == 0 && _loc2_.xSpeed != 0 || _serverWindAcceleration.y == 0 && _loc2_.ySpeed != 0)
                                 {
                                    _loc21_ = true;
                                    if(_serverWindAcceleration.x == 0 && _loc2_.xSpeed != 0)
                                    {
                                       _serverWindTargetAcceleration.x = _loc2_.xSpeed;
                                    }
                                    if(_serverWindAcceleration.y == 0 && _loc2_.ySpeed != 0)
                                    {
                                       _serverWindTargetAcceleration.y = _loc2_.ySpeed;
                                    }
                                    _theGame._soundMan.playByName(_theGame._soundNameWindGust);
                                 }
                              }
                              break;
                           }
                        }
                     }
                     if(_serverWindTargetAcceleration.x > 0)
                     {
                        _serverWindAcceleration.x += 2500 * param1;
                        if(_serverWindAcceleration.x > _serverWindTargetAcceleration.x)
                        {
                           _serverWindAcceleration.x = _serverWindTargetAcceleration.x;
                           _serverWindTargetAcceleration.x = 0;
                        }
                     }
                     else if(_serverWindTargetAcceleration.x < 0)
                     {
                        _serverWindAcceleration.x -= 2500 * param1;
                        if(_serverWindAcceleration.x < _serverWindTargetAcceleration.x)
                        {
                           _serverWindAcceleration.x = _serverWindTargetAcceleration.x;
                           _serverWindTargetAcceleration.x = 0;
                        }
                     }
                     else if(_serverWindAcceleration.x < 0)
                     {
                        _serverWindAcceleration.x += 5000 * param1;
                        if(_serverWindAcceleration.x > 0)
                        {
                           _serverWindAcceleration.x = 0;
                        }
                     }
                     else if(_serverWindAcceleration.x > 0)
                     {
                        _serverWindAcceleration.x -= 5000 * param1;
                        if(_serverWindAcceleration.x < 0)
                        {
                           _serverWindAcceleration.x = 0;
                        }
                     }
                     if(_serverWindTargetAcceleration.y > 0)
                     {
                        _serverWindAcceleration.y += 2500 * param1;
                        if(_serverWindAcceleration.y > _serverWindTargetAcceleration.y)
                        {
                           _serverWindAcceleration.y = _serverWindTargetAcceleration.y;
                           _serverWindTargetAcceleration.y = 0;
                        }
                     }
                     else if(_serverWindTargetAcceleration.y < 0)
                     {
                        _serverWindAcceleration.y -= 2500 * param1;
                        if(_serverWindAcceleration.y < _serverWindTargetAcceleration.y)
                        {
                           _serverWindAcceleration.y = _serverWindTargetAcceleration.y;
                           _serverWindTargetAcceleration.y = 0;
                        }
                     }
                     else if(_serverWindAcceleration.y < 0)
                     {
                        _serverWindAcceleration.y += 5000 * param1;
                        if(_serverWindAcceleration.y > 0)
                        {
                           _serverWindAcceleration.y = 0;
                        }
                     }
                     else if(_serverWindAcceleration.y > 0)
                     {
                        _serverWindAcceleration.y -= 5000 * param1;
                        if(_serverWindAcceleration.y < 0)
                        {
                           _serverWindAcceleration.y = 0;
                        }
                     }
                     if(_serverWindTargetAcceleration.y == 0)
                     {
                        if(_serverAcceleration.y < 150)
                        {
                           _serverAcceleration.y += 300 * param1;
                        }
                     }
                     else
                     {
                        _serverAcceleration.y = 0;
                     }
                     _serverVelocity.y += param1 * (_serverAcceleration.y + _serverWindAcceleration.y);
                     if(_serverWindAcceleration.y != 0)
                     {
                        if(_serverVelocity.y > 1.5 * 150)
                        {
                           _serverVelocity.y = 1.5 * 150;
                        }
                        if(_serverVelocity.y < -150)
                        {
                           _serverVelocity.y = -150;
                        }
                     }
                     else if(_serverVelocity.y > 150)
                     {
                        _serverVelocity.y -= 3 * 300 * param1;
                        if(_serverVelocity.y < 150)
                        {
                           _serverVelocity.y = 150;
                        }
                     }
                     if(_serverAcceleration.x != 0 || _serverWindAcceleration.x != 0)
                     {
                        _serverVelocity.x += param1 * (_serverAcceleration.x + _serverWindAcceleration.x);
                        if(_serverWindAcceleration.x != 0)
                        {
                           if(_serverVelocity.x > 275)
                           {
                              _serverVelocity.x = 275;
                           }
                           else if(_serverVelocity.x < -275)
                           {
                              _serverVelocity.x = -275;
                           }
                        }
                        else if(_serverVelocity.x > 200)
                        {
                           _serverVelocity.x -= 700 * param1;
                           if(_serverVelocity.x < 200)
                           {
                              _serverVelocity.x = 200;
                           }
                        }
                        else if(_serverVelocity.x < -200)
                        {
                           _serverVelocity.x += 700 * param1;
                           if(_serverVelocity.x > -200)
                           {
                              _serverVelocity.x = -200;
                           }
                        }
                     }
                     else if(_serverVelocity.x > 0)
                     {
                        _serverVelocity.x -= 700 * param1;
                        if(_serverVelocity.x < 0)
                        {
                           _serverVelocity.x = 0;
                        }
                     }
                     else if(_serverVelocity.x < 0)
                     {
                        _serverVelocity.x += 700 * param1;
                        if(_serverVelocity.x > 0)
                        {
                           _serverVelocity.x = 0;
                        }
                     }
                     _lastFrameVelocity.x = param1 * _serverVelocity.x;
                     _lastFrameVelocity.y = param1 * _serverVelocity.y;
                  }
                  _loc22_.x = _serverPosition.x + _centerPointOffsetX;
                  _loc22_.y = _serverPosition.y + _centerPointOffsetY;
                  if(_lastFrameVelocity.y != 0)
                  {
                     _loc12_ = 0;
                     while(_loc12_ < _theGame._treeBranches.length)
                     {
                        if(_theGame._treeBranches[_loc12_].clone && _theGame._treeBranches[_loc12_].enabled && (_loc22_.y + _radius >= _theGame._treeBranches[_loc12_].clone.y && _loc22_.y <= _theGame._treeBranches[_loc12_].clone.y + _theGame._treeBranches[_loc12_].clone.height))
                        {
                           _loc11_ = _theGame.PlayerBranchCollision(_loc22_,_lastFrameVelocity,_radius,_theGame._treeBranches[_loc12_]);
                           if(_loc11_ >= 0)
                           {
                              if(_lastTreeBranchHit != _theGame._treeBranches[_loc12_])
                              {
                                 _lastTreeBranchHit = _theGame._treeBranches[_loc12_];
                                 if(_lastFrameVelocity.y > 0)
                                 {
                                    _serverAcceleration.y = -225;
                                    if(_serverVelocity.y > 0)
                                    {
                                       if(_localPlayer)
                                       {
                                          playAnimationState(24);
                                          _loc19_ = _loc12_;
                                          _theGame._treeBranches[_loc12_].clone.content.gotoAndPlay("on");
                                          if(_theGame._treeBranches[_loc12_].removeAfterHit)
                                          {
                                             _theGame._soundMan.playByName(_theGame._soundNameCloudSwirl);
                                             _theGame._treeBranches[_loc12_].enabled = false;
                                          }
                                          else
                                          {
                                             _theGame._soundMan.playByName(_theGame._soundNameTreeBranch);
                                          }
                                       }
                                       _serverVelocity.y = -50;
                                       _lastFrameVelocity.y *= _loc11_;
                                       _positionHoldTimer = 0.15;
                                       _serverWindAcceleration.x = 0;
                                       _serverWindTargetAcceleration.x = 0;
                                       _serverWindAcceleration.y = 0;
                                       _serverWindTargetAcceleration.y = 0;
                                    }
                                 }
                                 else
                                 {
                                    _serverAcceleration.y = 0;
                                    _serverVelocity.y = 0;
                                    _lastFrameVelocity.y *= _loc11_;
                                    _serverWindAcceleration.y = 0;
                                    _serverWindTargetAcceleration.y = 0;
                                 }
                              }
                              break;
                           }
                        }
                        else if(_lastTreeBranchHit == _theGame._treeBranches[_loc12_])
                        {
                           _lastTreeBranchHit = null;
                        }
                        _loc12_++;
                     }
                  }
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
               }
               else
               {
                  _landedReceived = _landedReceived - 1;
                  if(_landedReceived == 0)
                  {
                     setLanded();
                  }
               }
               _loc6_ = null;
               if(_serverVelocity.x != 0)
               {
                  _parachuteFrame.rotation = 7 * _serverVelocity.x / 200;
               }
               else
               {
                  _clone.rotation = 0;
                  _parachuteFrame.rotation = 0;
               }
               if(_localPlayer)
               {
                  _loc8_ = false;
                  _loc18_ = false;
                  _clone.x = _serverPosition.x;
                  _clone.y = _serverPosition.y;
                  if(_theGame._ground.clone && _theGame._ground.clone.loader.parent)
                  {
                     _loc22_.x = _serverPosition.x + _centerPointOffsetX;
                     _loc22_.y = _serverPosition.y + _centerPointOffsetY;
                     if(_lastFrameVelocity.y != 0)
                     {
                        if(_loc22_.y + _radius >= _theGame._ground.clone.loader.y)
                        {
                           _loc17_ = _theGame._ground.volumePoints;
                           _loc5_ = new Point();
                           _loc4_ = new Point();
                           _loc12_ = 0;
                           while(_loc12_ < _loc17_.length - 1)
                           {
                              _loc5_.x = _loc17_[_loc12_].x + _theGame._ground.clone.loader.x;
                              _loc4_.x = _loc17_[_loc12_ + 1].x + _theGame._ground.clone.loader.x;
                              _loc5_.y = _loc17_[_loc12_].y + _theGame._ground.clone.loader.y;
                              _loc4_.y = _loc17_[_loc12_ + 1].y + _theGame._ground.clone.loader.y;
                              if(Collision.movingCircleVsRay(_loc22_,_radius,_lastFrameVelocity,1,_loc5_,_loc4_) >= 0)
                              {
                                 setLanded();
                                 _loc8_ = true;
                                 break;
                              }
                              _loc12_++;
                           }
                        }
                     }
                  }
                  for(var _loc3_:Object in _theGame._gems)
                  {
                     if(_theGame._gems[_loc3_] && _theGame._gems[_loc3_].enabled == true)
                     {
                        _loc15_ = _theGame._gems[_loc3_].centerPointX - (_clone.x + _centerPointOffsetX);
                        _loc16_ = _theGame._gems[_loc3_].centerPointY - (_clone.y + _centerPointOffsetY);
                        _loc9_ = _radius + _theGame._gems[_loc3_].radius;
                        _loc15_ *= _loc15_;
                        _loc16_ *= _loc16_;
                        if(_loc15_ + _loc16_ < _loc9_ * _loc9_)
                        {
                           _loc10_ = [];
                           _loc10_[0] = "gem";
                           _loc10_[1] = String(_loc3_);
                           _theGame.messageServer(_loc10_);
                           _theGame.gemPickup(int(_loc3_));
                           _theGame._soundMan.playByName(_theGame._soundNameGemAdded);
                           break;
                        }
                     }
                  }
                  if(_polluteTimer <= 0)
                  {
                     for each(_loc6_ in _theGame._phantoms)
                     {
                        if(_loc6_.clone && _loc6_.clone.content && _loc6_.polluteTimer <= 0)
                        {
                           _loc15_ = _loc6_.clone.x + _loc6_.clone.content.collision.x + _loc6_.clone.content.collision.width / 2 - (_clone.x + _centerPointOffsetX);
                           _loc16_ = _loc6_.clone.y + _loc6_.clone.content.collision.y + _loc6_.clone.content.collision.height / 2 - (_clone.y + _centerPointOffsetY);
                           _loc9_ = _radius + _loc6_.clone.content.collision.width / 2;
                           _loc15_ *= _loc15_;
                           _loc16_ *= _loc16_;
                           if(_loc15_ + _loc16_ < _loc9_ * _loc9_)
                           {
                              setPolluted(_loc6_,false);
                              _loc18_ = true;
                              _theGame._soundMan.playByName(_theGame._soundNamePhantomShock);
                              break;
                           }
                        }
                     }
                  }
                  if(_serverWindTargetAcceleration.x == 0)
                  {
                     if(_theGame._rightArrowDown)
                     {
                        _serverAcceleration.x = 700;
                     }
                     else if(_theGame._leftArrowDown)
                     {
                        _serverAcceleration.x = -700;
                     }
                     else
                     {
                        _serverAcceleration.x = 0;
                     }
                  }
                  else
                  {
                     _serverAcceleration.x = 0;
                  }
                  _updatePositionTimer += param1;
                  if(_updatePositionTimer > 0.25 || _loc19_ != -1 || _loc8_ || _loc18_ || _loc21_)
                  {
                     _loc10_ = [];
                     _loc10_[0] = "pos";
                     _loc10_[1] = String(int(_clone.x));
                     _loc10_[2] = String(int(_clone.y));
                     _loc10_[3] = String(int(_serverAcceleration.x));
                     _loc10_[4] = String(int(_serverAcceleration.y));
                     _loc10_[5] = String(int(_serverVelocity.x));
                     _loc10_[6] = String(int(_serverVelocity.y));
                     if(_loc8_)
                     {
                        _loc10_[7] = "4";
                     }
                     else if(_loc21_)
                     {
                        _loc10_[7] = "3";
                        _loc10_[8] = String(int(_serverWindTargetAcceleration.x));
                        _loc10_[9] = String(int(_serverWindTargetAcceleration.y));
                     }
                     else if(_loc18_)
                     {
                        _loc10_[7] = "2";
                        _loc10_[8] = String(_loc6_.phantomID);
                     }
                     else if(_loc19_ != -1)
                     {
                        _loc10_[7] = "1";
                        _loc10_[8] = String(int(_theGame._treeBranches[_loc19_].branchID));
                     }
                     else
                     {
                        _loc10_[7] = "0";
                     }
                     _theGame.messageServer(_loc10_);
                     _updatePositionTimer = 0;
                  }
               }
               else if(_landed)
               {
                  _clone.x = _serverPosition.x;
                  _clone.y = _serverPosition.y;
               }
               else
               {
                  _loc7_ = new Point();
                  _loc7_.x = _clone.x;
                  _loc7_.y = _clone.y;
                  _loc14_ = Point.distance(_loc7_,_serverPosition);
                  _currentVelocity.x = _serverPosition.x - _clone.x;
                  _currentVelocity.y = _serverPosition.y - _clone.y;
                  _serverHitType = 0;
                  _loc20_ = 0.2;
                  _clone.x += _currentVelocity.x * _loc20_;
                  _clone.y += _currentVelocity.y * _loc20_;
               }
               updateParachute();
            }
            else
            {
               _clone.rotation = 0;
               _parachuteFrame.rotation = 0;
            }
         }
      }
      
      public function receivePositionData(param1:Array, param2:int) : int
      {
         var _loc7_:int = 0;
         var _loc5_:* = null;
         var _loc4_:Object = null;
         var _loc6_:Boolean = false;
         var _loc3_:int = 0;
         _serverPosition.x = int(param1[param2++]);
         _serverPosition.y = int(param1[param2++]);
         _serverAcceleration.x = int(param1[param2++]);
         _serverAcceleration.y = int(param1[param2++]);
         _serverVelocity.x = int(param1[param2++]);
         _serverVelocity.y = int(param1[param2++]);
         _serverHitType = int(param1[param2++]);
         loop2:
         switch(_serverHitType - 1)
         {
            case 0:
               _loc3_ = int(param1[param2++]);
               _positionHoldTimer = 0.15 / 2;
               playAnimationState(24);
               _loc7_ = 0;
               while(true)
               {
                  if(_loc7_ >= _theGame._treeBranches.length)
                  {
                     break loop2;
                  }
                  if(_loc3_ == _theGame._treeBranches[_loc7_].branchID)
                  {
                     break;
                  }
                  _loc7_++;
               }
               if(_theGame._treeBranches[_loc7_].clone)
               {
                  _theGame._treeBranches[_loc7_].clone.content.gotoAndPlay("on");
               }
               if(_theGame._treeBranches[_loc7_].removeAfterHit)
               {
                  _theGame._treeBranches[_loc7_].enabled = false;
               }
               break;
            case 1:
               _loc7_ = int(param1[param2++]);
               _loc6_ = false;
               for each(_loc4_ in _theGame._phantoms)
               {
                  if(_loc4_.phantomID == _loc7_)
                  {
                     _loc6_ = true;
                     break;
                  }
               }
               if(!_loc6_)
               {
                  _loc4_ = null;
               }
               setPolluted(_loc4_,false);
               break;
            case 2:
               _serverWindTargetAcceleration.x = int(param1[param2++]);
               _serverWindTargetAcceleration.y = int(param1[param2++]);
               break;
            case 3:
               _landedReceived = 3;
         }
         return param2;
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
      
      private function playAnimationState(param1:int) : void
      {
         var _loc2_:Function = null;
         var _loc3_:int = 0;
         switch(param1 - 19)
         {
            case 0:
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "Float";
               }
               break;
            case 1:
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "Struggle";
               }
               break;
            case 2:
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "Land";
               }
               _loc2_ = animationAtEnd;
               break;
            case 5:
               _loc3_ = 0;
               if(_parachute.loader.content)
               {
                  _parachute.loader.content.transition = "BounceUp";
               }
               _loc2_ = animationAtEnd;
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
               case 3:
                  playAnimationState(19);
            }
         }
      }
      
      public function receiveGem(param1:int) : void
      {
         _gemCount = _gemCount + 1;
      }
      
      public function setLanded() : void
      {
         _landed = true;
         new GTween(this,0.5,{"_alpha":0});
         playAnimationState(21);
      }
      
      public function setPolluted(param1:Object, param2:Boolean) : void
      {
         _phantomsHit = _phantomsHit + 1;
         if(!_dropGems.loader.content.dropGems)
         {
            _dropGems.loader.content.dropGems = true;
         }
         if(param2)
         {
            _gemCount = 0;
         }
         else
         {
            _gemCount -= 3;
            if(_gemCount < 0)
            {
               _gemCount = 0;
            }
         }
         playAnimationState(20);
         _polluteTimer = 3.5;
         _positionHoldTimer = 0.25;
         _serverAcceleration.x = 0;
         _serverVelocity.x = 0;
         _serverWindAcceleration.x = 0;
         _serverWindTargetAcceleration.x = 0;
         _serverAcceleration.y = 0;
         _serverVelocity.y = 0;
         _serverWindAcceleration.y = 0;
         _serverWindTargetAcceleration.y = 0;
         if(!param2 && param1)
         {
            param1.polluteTimer = 1;
            if(param1.clone && param1.clone.content)
            {
               param1.clone.content.gotoAndPlay("Pollute");
               param1.clone.content.currentLoop = "Pollute";
               param1.clone.content.transition = null;
            }
         }
      }
      
      public function onParachuteLoaderComplete(param1:Event) : void
      {
         param1.target.content.transition = "Float";
         param1.target.removeEventListener("complete",onParachuteLoaderComplete);
      }
   }
}

