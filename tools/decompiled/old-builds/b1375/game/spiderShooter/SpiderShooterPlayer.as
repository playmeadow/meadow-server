package game.spiderShooter
{
   import flash.geom.Point;
   
   public class SpiderShooterPlayer
   {
      
      private static const UPDATE_POSITION_TIME:Number = 0.25;
      
      public var _theGame:SpiderShooter;
      
      public var _localPlayer:Boolean;
      
      public var _netID:int;
      
      private var _clone:Object;
      
      public var _updatePositionTimer:Number;
      
      public var _serverPosition:Point;
      
      public var _gemCount:int;
      
      public var _waitingForAllLoaded:Boolean;
      
      public var _shotRadius:int;
      
      public var _shootTimer:Number;
      
      public function SpiderShooterPlayer(param1:SpiderShooter)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:Array, param2:int, param3:Object) : int
      {
         _serverPosition = new Point();
         _netID = parseInt(param1[param2++]);
         _clone = param3;
         _clone.loader.content.gotoAndPlay("off");
         _clone.loader.x = parseInt(param1[param2++]);
         _clone.loader.y = parseInt(param1[param2++]);
         _serverPosition.x = _clone.loader.x;
         _serverPosition.y = _clone.loader.y;
         _shotRadius = _clone.loader.width / 3;
         _gemCount = 0;
         _shootTimer = 0;
         _updatePositionTimer = 0;
         _waitingForAllLoaded = false;
         _theGame._layerPlayers.addChild(_clone.loader);
         _localPlayer = _theGame.myId == _netID;
         return param2;
      }
      
      public function remove() : void
      {
         if(_clone.loader && _clone.loader.parent)
         {
            _clone.loader.parent.removeChild(_clone.loader);
         }
      }
      
      public function heartbeat(param1:Number) : void
      {
         var _loc5_:Array = null;
         var _loc3_:Point = null;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         if(!_waitingForAllLoaded)
         {
            if(_localPlayer)
            {
               _serverPosition.x = _theGame.stage.mouseX - _clone.loader.width / 2;
               if(_serverPosition.x < 0)
               {
                  _serverPosition.x = 0;
               }
               else if(_serverPosition.x > 900 - _clone.loader.width)
               {
                  _serverPosition.x = 900 - _clone.loader.width;
               }
               _serverPosition.y = _theGame.stage.mouseY - _clone.loader.height / 2;
               if(_serverPosition.y < 0)
               {
                  _serverPosition.y = 0;
               }
               else if(_serverPosition.y > 550 - _clone.loader.height)
               {
                  _serverPosition.y = 550 - _clone.loader.height;
               }
               _clone.loader.x = _serverPosition.x;
               _clone.loader.y = _serverPosition.y;
               if(_shootTimer > 0)
               {
                  _shootTimer -= param1;
               }
               _updatePositionTimer += param1;
               if(_updatePositionTimer > 0.25)
               {
                  _loc5_ = [];
                  _loc5_[0] = "pos";
                  _loc5_[1] = String(int(_clone.loader.x));
                  _loc5_[2] = String(int(_clone.loader.y));
                  _theGame.messageServer(_loc5_);
                  _updatePositionTimer = 0;
               }
            }
            else
            {
               _loc3_ = new Point();
               _loc3_.x = _clone.loader.x;
               _loc3_.y = _clone.loader.y;
               _loc2_ = Point.distance(_loc3_,_serverPosition);
               _loc4_ = 0.25;
               _clone.loader.x += (_serverPosition.x - _clone.loader.x) * _loc4_;
               _clone.loader.y += (_serverPosition.y - _clone.loader.y) * _loc4_;
            }
         }
      }
      
      public function receivePositionData(param1:Array, param2:int) : int
      {
         _serverPosition.x = int(param1[param2++]);
         _serverPosition.y = int(param1[param2++]);
         return param2;
      }
      
      public function shoot() : Boolean
      {
         _clone.loader.content.gotoAndPlay("on");
         if(_shootTimer <= 0)
         {
            _theGame._soundMan.playByName(_theGame._soundNamePlayerFired);
            _shootTimer = 0.15;
            return true;
         }
         return false;
      }
   }
}

