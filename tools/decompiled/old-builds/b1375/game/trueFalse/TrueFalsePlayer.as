package game.trueFalse
{
   import avatar.AvatarXtCommManager;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   
   public class TrueFalsePlayer
   {
      
      public var pId:int;
      
      public var sfsId:int;
      
      public var dbId:int;
      
      public var userName:String;
      
      public var _avtView:TrueFalseAvatarView;
      
      public var _bCorrect:Boolean;
      
      public var _avatarDirection:Point;
      
      private var _dir:Point;
      
      private var _followPath:Vector.<int>;
      
      private var _movePlayerToPos:Point;
      
      private var _moving:int;
      
      public var _moveToX:int;
      
      public var _moveToY:int;
      
      private var _lastMoveAngle:Number;
      
      private var _lastIdleAnim:int;
      
      private var _lastIdleFlip:Boolean;
      
      public var _localPlayer:Boolean;
      
      private var _theGame:TrueFalse;
      
      private var _throttle:Number;
      
      private var _serverX:int;
      
      private var _serverY:int;
      
      public var _splash:MovieClip;
      
      public var _isDancing:Boolean;
      
      public var _gemBonus:MovieClip;
      
      public function TrueFalsePlayer(param1:TrueFalse)
      {
         super();
         _theGame = param1;
         _avatarDirection = new Point();
         _dir = new Point();
         _throttle = 0;
      }
      
      public static function convertToIdle(param1:Number) : Object
      {
         var _loc3_:int = 14;
         var _loc2_:Boolean = false;
         var _loc4_:Number = 1.5707963267948966;
         if(param1 > -2 * _loc4_ && param1 < -_loc4_)
         {
            _loc3_ = 16;
            _loc2_ = true;
         }
         else if(param1 >= -_loc4_ && param1 < 0)
         {
            _loc3_ = 16;
         }
         else if(param1 >= 0 && param1 < _loc4_)
         {
            _loc3_ = 14;
         }
         else
         {
            _loc3_ = 14;
            _loc2_ = true;
         }
         return {
            "anim":_loc3_,
            "flip":_loc2_
         };
      }
      
      public function destroy() : void
      {
         if(_avtView)
         {
            _avtView.destroy();
            _avtView = null;
         }
         _avatarDirection = null;
      }
      
      public function addSplash() : void
      {
         _splash = GETDEFINITIONBYNAME("trueFalse_splashEffect");
         _splash.x = -80;
         _splash.y = -30;
         if(_avtView.x < 450)
         {
            _splash.visible = false;
         }
         else
         {
            _splash.setState(2);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc4_:Number = _avtView.x;
         var _loc3_:Number = _avtView.y;
         var _loc5_:Number = _dir.x * 24 * param1 / 0.07;
         var _loc2_:Number = _dir.y * 24 * param1 / 0.07;
         _avtView.heartbeat(param1);
         _throttle -= param1;
         if(_localPlayer && _throttle <= 0 && (_serverX != _moveToX || _serverY != _moveToY))
         {
            _theGame.updatePosition(_moveToX,_moveToY);
            _throttle = 0.5;
            _serverX = _moveToX;
            _serverY = _moveToY;
         }
         if(_loc5_)
         {
            if(_loc5_ > 0 && _loc5_ + _avtView.x >= _moveToX || _loc5_ < 0 && _loc5_ + _avtView.x <= _moveToX)
            {
               _dir.x = 0;
               _loc4_ = _moveToX;
            }
            else
            {
               _loc4_ += _loc5_;
            }
         }
         if(_loc2_)
         {
            if(_loc2_ > 0 && _loc2_ + _avtView.y >= _moveToY || _loc2_ < 0 && _loc2_ + _avtView.y <= _moveToY)
            {
               _dir.y = 0;
               _loc3_ = _moveToY;
            }
            else
            {
               _loc3_ += _loc2_;
            }
         }
         if(_loc4_ != _avtView.x || _loc3_ != _avtView.y)
         {
            _splash.setState(1);
            if(_avtView.x >= 450 && _loc4_ < 450)
            {
               if(_localPlayer)
               {
                  _theGame._bg.clearGuess();
                  _theGame._bg.guessTrue();
                  _theGame._soundMan.playByName(_theGame._soundNameCheck);
               }
               _splash.visible = false;
            }
            else if(_avtView.x < 450 && _loc4_ >= 450)
            {
               if(_localPlayer)
               {
                  _theGame._bg.clearGuess();
                  _theGame._bg.guessFalse();
                  _theGame._soundMan.playByName(_theGame._soundNameX);
               }
               _splash.visible = true;
            }
            _avtView.x = _loc4_;
            _avtView.y = _loc3_;
            if(_localPlayer)
            {
               if(_avtView.x < 180)
               {
                  _theGame._background.x = _theGame._playerLayer.x = Math.min(80,180 - _avtView.x);
               }
               else if(_avtView.x > 720)
               {
                  _theGame._background.x = _theGame._playerLayer.x = Math.max(-80,720 - _avtView.x);
               }
               else
               {
                  _theGame._background.x = 0;
               }
               if(_avtView.y > 450)
               {
                  _theGame._background.y = _theGame._playerLayer.y = Math.max(-30,450 - _avtView.y);
               }
               else
               {
                  _theGame._background.y = 0;
               }
            }
         }
         if(!_dir.x && !_dir.y)
         {
            switch(_moving - -1)
            {
               case 0:
                  playIdle();
                  break;
               case 2:
                  if(!_followPath)
                  {
                     _moving = -1;
                  }
            }
         }
      }
      
      public function onAgResponse(param1:String, param2:Boolean, param3:int) : void
      {
         AvatarXtCommManager.requestADForAvatar(dbId,true,_avtView.setupNamebar,_avtView.avatarData);
      }
      
      public function setGuess(param1:Boolean = true) : void
      {
         if(_avtView.x < 450)
         {
            _theGame._bg.clearGuess();
            _theGame._bg.guessTrue();
            if(param1)
            {
               _theGame._soundMan.playByName(_theGame._soundNameCheck);
            }
         }
         else
         {
            _theGame._bg.clearGuess();
            _theGame._bg.guessFalse();
            if(param1)
            {
               _theGame._soundMan.playByName(_theGame._soundNameX);
            }
         }
      }
      
      public function playIdle() : void
      {
         if(!_isDancing)
         {
            _avtView.playAnim(_lastIdleAnim,_lastIdleFlip);
         }
         _moving = 0;
         _movePlayerToPos = null;
         _dir.x = _dir.y = 0;
         _splash.setState(2);
      }
      
      public function followCursorTest(param1:Number, param2:Boolean) : void
      {
         var _loc6_:Point = null;
         var _loc5_:int = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!_avtView.visible)
         {
            return;
         }
         if(param2)
         {
            setMoveTo(gMainFrame.mouseX - _theGame._background.x,gMainFrame.mouseY - _theGame._background.y);
            if(Math.abs(_moveToX - _avtView.x) > 10 || Math.abs(_moveToY - _avtView.y) > 10)
            {
               updateAvatar(_moveToX,_moveToY);
               if(_movePlayerToPos == null)
               {
                  _movePlayerToPos = new Point();
               }
               _movePlayerToPos.x = _moveToX;
               _movePlayerToPos.y = _moveToY;
            }
            _isDancing = false;
         }
         else if(_movePlayerToPos == null)
         {
            if(_avatarDirection.x != 0 || _avatarDirection.y != 0)
            {
               _loc6_ = new Point();
               _loc5_ = 24 * param1 / 0.07;
               _loc3_ = _avatarDirection.x * _loc5_;
               _loc4_ = _avatarDirection.y * _loc5_;
               _loc6_.x = _avtView.x;
               _loc6_.y = _avtView.y;
               updateAvatar(_loc6_.x + _loc3_,_loc6_.y + _loc4_);
               _isDancing = false;
            }
         }
      }
      
      public function setAvatarDestination(param1:int, param2:int) : void
      {
         setMoveTo(param1,param2);
         updateAvatar(_moveToX,_moveToY);
         if(_movePlayerToPos == null)
         {
            _movePlayerToPos = new Point();
         }
         _movePlayerToPos.x = _moveToX;
         _movePlayerToPos.y = _moveToY;
      }
      
      private function updateAvatar(param1:int, param2:int) : void
      {
         setPos(param1,param2);
      }
      
      private function setPos(param1:Number, param2:Number) : void
      {
         setMoveTo(param1,param2);
         _dir.x = param1 - _avtView.x;
         _dir.y = param2 - _avtView.y;
         _dir.normalize(1);
         faceAnim(_dir.x,_dir.y,true);
         _moving = 1;
      }
      
      private function setMoveTo(param1:Number, param2:Number) : void
      {
         _moveToX = param1;
         _moveToY = param2;
         if(_moveToX > 940)
         {
            _moveToX = 940;
         }
         if(_moveToX < 0)
         {
            _moveToX = 0;
         }
         if(_moveToY > 580)
         {
            _moveToY = 580;
         }
         if(_moveToY < 10)
         {
            _moveToY = 10;
         }
         if(_localPlayer && _theGame._gameState == 4)
         {
            if(_avtView.x < 450)
            {
               if(_moveToX >= 450)
               {
                  _moveToX = 449;
               }
            }
            else if(_moveToX < 450)
            {
               _moveToX = 450;
            }
         }
      }
      
      private function faceAnim(param1:Number, param2:Number, param3:Boolean = true) : void
      {
         var _loc9_:Number = Math.atan2(param2,param1);
         var _loc6_:Number = 0.3141592653589793;
         var _loc8_:Number = 0.6283185307179586;
         _lastMoveAngle = _loc9_;
         var _loc5_:Object = convertToIdle(_lastMoveAngle);
         _lastIdleAnim = _loc5_.anim;
         _lastIdleFlip = _loc5_.flip;
         var _loc10_:int = 0;
         var _loc4_:Boolean = false;
         if(_loc9_ >= 5 * _loc8_ - _loc6_ || _loc9_ < -5 * _loc8_ + _loc6_)
         {
            _loc10_ = 2;
            _loc4_ = true;
         }
         else if(_loc9_ >= -4 * _loc8_ - _loc6_ && _loc9_ < -4 * _loc8_ + _loc6_)
         {
            _loc10_ = 1;
            _loc4_ = true;
         }
         else if(_loc9_ >= -3 * _loc8_ - _loc6_ && _loc9_ < -3 * _loc8_ + _loc6_)
         {
            _loc10_ = 0;
            _loc4_ = true;
         }
         else if(_loc9_ >= -2 * _loc8_ - _loc6_ && _loc9_ < -2 * _loc8_ + _loc6_)
         {
            _loc10_ = 0;
         }
         else if(_loc9_ >= -_loc8_ - _loc6_ && _loc9_ < -_loc8_ + _loc6_)
         {
            _loc10_ = 1;
         }
         else if(_loc9_ >= -_loc6_ && _loc9_ < _loc6_)
         {
            _loc10_ = 2;
         }
         else if(_loc9_ >= _loc8_ - _loc6_ && _loc9_ < _loc8_ + _loc6_)
         {
            _loc10_ = 3;
         }
         else if(_loc9_ >= 2 * _loc8_ - _loc6_ && _loc9_ < 2 * _loc8_ + _loc6_)
         {
            _loc10_ = 4;
         }
         else if(_loc9_ >= 3 * _loc8_ - _loc6_ && _loc9_ < 3 * _loc8_ + _loc6_)
         {
            _loc10_ = 4;
            _loc4_ = true;
         }
         else
         {
            _loc10_ = 3;
            _loc4_ = true;
         }
         var _loc7_:int = 7 + _loc10_;
         if(!param3)
         {
            switch(_loc10_)
            {
               case 0:
               case 1:
                  _loc7_ = 16;
                  break;
               case 2:
               case 3:
               case 4:
                  _loc7_ = 14;
            }
         }
         _avtView.playAnim(_loc7_,_loc4_,2);
      }
      
      public function playAnim(param1:int) : void
      {
         _avtView.playAnim(param1,_lastIdleFlip);
      }
      
      public function setEmote(param1:Sprite) : void
      {
         _avtView.setEmote(param1);
      }
   }
}

