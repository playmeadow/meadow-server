package game.riverRace
{
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class RiverSegment
   {
      
      public static const SLOT_STARTX:int = 150;
      
      public static const RIVER_WIDTH:int = 615;
      
      public var _theGame:RiverRace;
      
      public var _scene:Sprite;
      
      public var _clone:Object;
      
      public var _riverWater:Object;
      
      public var _tileID:int;
      
      public var _flipType:int;
      
      public var _name:String;
      
      public var _volumes:Array;
      
      public var _startEnd:Boolean;
      
      public var _added:Boolean;
      
      public var _buoys:Array;
      
      public var _rocks:Array;
      
      public var _whirlpools:Array;
      
      public function RiverSegment(param1:RiverRace)
      {
         super();
         _theGame = param1;
      }
      
      public function init(param1:Object, param2:String, param3:Boolean, param4:int = -1, param5:int = 1) : void
      {
         var _loc13_:int = 0;
         var _loc8_:* = null;
         var _loc9_:* = null;
         _scene = new Sprite();
         _clone = param1;
         _startEnd = param3;
         _tileID = param4;
         _flipType = param5;
         _name = param2;
         _added = false;
         var _loc7_:int = int(param1.loader.x);
         var _loc6_:int = int(param1.loader.y);
         _clone.loader.x = 0;
         _clone.loader.y = 0;
         flipTile(_clone.loader);
         _scene.addChild(_clone.loader);
         var _loc10_:Array = _theGame.getScene().getActorList("ActorVolume");
         var _loc12_:Number = -1;
         var _loc11_:Number = -1;
         _volumes = [];
         for each(_loc8_ in _loc10_)
         {
            if(_loc8_.name.search(param2 + "_volume_") != -1)
            {
               _volumes.push(_loc8_.points);
            }
         }
         for each(_loc9_ in _volumes)
         {
            _loc13_ = 0;
            while(_loc13_ < _loc9_.length - 1)
            {
               _loc9_[_loc13_].x -= _loc7_;
               _loc9_[_loc13_].y -= _loc6_;
               _loc13_++;
            }
            _loc13_ = _loc9_.length - 1;
            while(_loc13_ >= 0)
            {
               if(_loc9_[_loc13_].x < 0 && _loc9_[_loc13_].y < 0 || _loc9_[_loc13_].x < 0 && _loc9_[_loc13_].y > _clone.loader.height || _loc9_[_loc13_].x > _clone.loader.width && _loc9_[_loc13_].y < 0 || _loc9_[_loc13_].x > _clone.loader.width && _loc9_[_loc13_].y > _clone.loader.height)
               {
                  _loc9_.splice(_loc13_,1);
               }
               else if(_loc9_[_loc13_].y < 0 || _loc9_[_loc13_].y > _clone.loader.height)
               {
                  if(_loc9_[_loc13_].y < 0)
                  {
                     _loc9_[_loc13_].y = 0;
                  }
                  else
                  {
                     _loc9_[_loc13_].y = _clone.loader.height;
                  }
                  if(_loc9_[_loc13_].x < _clone.loader.width - _loc9_[_loc13_].x)
                  {
                     if(_loc12_ == -1)
                     {
                        _loc12_ = Number(_loc9_[_loc13_].x);
                     }
                     else
                     {
                        _loc9_[_loc13_].x = _loc12_;
                     }
                  }
                  else if(_loc11_ == -1)
                  {
                     _loc11_ = Number(_loc9_[_loc13_].x);
                  }
                  else
                  {
                     _loc9_[_loc13_].x = _loc11_;
                  }
               }
               _loc13_--;
            }
         }
      }
      
      public function initRiverWater() : void
      {
         _riverWater.loader.content.gotoAndPlay("tile4_1");
      }
      
      public function onRiverWaterLoaderComplete(param1:Event) : void
      {
         if(_added)
         {
            initRiverWater();
         }
         param1.target.removeEventListener("complete",onRiverWaterLoaderComplete);
      }
      
      public function add(param1:int, param2:Boolean = false) : void
      {
         var _loc3_:Object = null;
         _added = true;
         if(_riverWater && _riverWater.loader.content)
         {
            initRiverWater();
         }
         _scene.x = 0;
         _scene.y = param1;
         _theGame._layerBackground.addChild(_scene);
         if(_startEnd)
         {
            if(param2)
            {
               _theGame._startingLine.loader.x = 0;
               _theGame._startingLine.loader.y = param1 + _theGame._startingLine.y;
               _theGame._currentBuoyY = _theGame._startingLine.loader.y;
               _theGame._layerForeground.addChild(_theGame._startingLine.loader);
            }
            else
            {
               _theGame._finishLine.loader.x = 0;
               _theGame._finishLine.loader.y = param1 + _theGame._finishLine.y;
               _theGame._layerBackground.addChild(_theGame._finishLine.loader);
            }
         }
         _buoys = [];
         _rocks = [];
         _whirlpools = [];
         while(_theGame._currentBuoyIndex < _theGame._levels[_theGame._levelIndex].length && -_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].offset + _theGame._currentBuoyY >= param1)
         {
            _loc3_ = null;
            _theGame._currentBuoyY += -_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].offset;
            if(_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].boost)
            {
               if(_theGame._inactiveBuoys.length > 0)
               {
                  _loc3_ = _theGame._inactiveBuoys[0];
                  _theGame._inactiveBuoys.splice(0,1);
                  initBuoy(_loc3_.loader);
               }
               else
               {
                  _loc3_ = _theGame.getScene().cloneAsset("arrows");
                  _loc3_.loader.contentLoaderInfo.addEventListener("complete",onBuoyLoaderComplete);
               }
               _loc3_.loader.x = 150 + (615 - _loc3_.width) / 4 * (_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].boost - 1);
               _loc3_.loader.y = _theGame._currentBuoyY + _theGame._arrowOffsetY;
               _theGame._layerBuoys.addChild(_loc3_.loader);
               _buoys.push(_loc3_);
            }
            else if(_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].rocks)
            {
               if(_theGame._inactiveRocks.length > 0)
               {
                  _loc3_ = _theGame._inactiveRocks[0];
                  _theGame._inactiveRocks.splice(0,1);
                  initRocks(_loc3_.loader);
               }
               else
               {
                  _loc3_ = _theGame.getScene().cloneAsset("rocks");
                  _loc3_.loader.contentLoaderInfo.addEventListener("complete",onRocksLoaderComplete);
               }
               _loc3_.loader.x = 150 + (615 - _loc3_.width) / 4 * (_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].rocks - 1);
               _theGame._layerBuoys.addChild(_loc3_.loader);
               _loc3_.loader.y = _theGame._currentBuoyY + _theGame._rocksOffsetY;
               _rocks.push(_loc3_);
            }
            else if(_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].whirlpool)
            {
               if(_theGame._inactiveWhirlpools.length > 0)
               {
                  _loc3_ = _theGame._inactiveWhirlpools[0];
                  _theGame._inactiveWhirlpools.splice(0,1);
                  initWhirlpool(_loc3_.loader);
               }
               else
               {
                  _loc3_ = _theGame.getScene().cloneAsset("whirlpool");
                  _loc3_.loader.contentLoaderInfo.addEventListener("complete",onWhirlpoolLoaderComplete);
               }
               _loc3_.loader.x = 150 + (615 - _loc3_.width) / 4 * (_theGame._levels[_theGame._levelIndex][_theGame._currentBuoyIndex].whirlpool - 1);
               _theGame._layerBuoys.addChild(_loc3_.loader);
               _loc3_.loader.y = _theGame._currentBuoyY + _theGame._whirlpoolOffsetY;
               _whirlpools.push(_loc3_);
            }
            if(_loc3_)
            {
               _loc3_._active = true;
            }
            _theGame._currentBuoyIndex++;
         }
      }
      
      public function remove() : void
      {
         var _loc1_:* = null;
         _added = false;
         while(_buoys && _buoys.length > 0)
         {
            if(_buoys[0].loader.parent)
            {
               _buoys[0].loader.parent.removeChild(_buoys[0].loader);
            }
            _theGame._inactiveBuoys.push(_buoys[0]);
            _buoys.splice(0,1);
         }
         _buoys = null;
         while(_rocks && _rocks.length > 0)
         {
            if(_rocks[0].loader.parent)
            {
               _rocks[0].loader.parent.removeChild(_rocks[0].loader);
            }
            _theGame._inactiveRocks.push(_rocks[0]);
            _rocks.splice(0,1);
         }
         _rocks = null;
         while(_whirlpools && _whirlpools.length > 0)
         {
            if(_whirlpools[0].loader.parent)
            {
               _whirlpools[0].loader.parent.removeChild(_whirlpools[0].loader);
            }
            _theGame._inactiveWhirlpools.push(_whirlpools[0]);
            _whirlpools.splice(0,1);
         }
         _whirlpools = null;
         if(_riverWater && _riverWater.loader.content)
         {
            _riverWater.loader.content.stop();
         }
         if(_startEnd)
         {
            if(_theGame._startingLine.loader.parent)
            {
               _theGame._startingLine.loader.parent.removeChild(_theGame._startingLine.loader);
            }
            if(_theGame._finishLine.loader.parent)
            {
               _theGame._finishLine.loader.parent.removeChild(_theGame._finishLine.loader);
            }
         }
         _scene.parent.removeChild(_scene);
      }
      
      public function onBuoyLoaderComplete(param1:Event) : void
      {
         initBuoy(param1.target);
         param1.target.removeEventListener("complete",onBuoyLoaderComplete);
      }
      
      public function onRocksLoaderComplete(param1:Event) : void
      {
         initRocks(param1.target);
         param1.target.removeEventListener("complete",onRocksLoaderComplete);
      }
      
      public function onWhirlpoolLoaderComplete(param1:Event) : void
      {
         initWhirlpool(param1.target);
         param1.target.removeEventListener("complete",onWhirlpoolLoaderComplete);
      }
      
      public function initBuoy(param1:Object) : void
      {
      }
      
      public function initRocks(param1:Object) : void
      {
      }
      
      public function initWhirlpool(param1:Object) : void
      {
      }
      
      public function flipTile(param1:Object) : void
      {
         var _loc4_:Matrix = null;
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         if(_flipType > 1)
         {
            _loc4_ = param1.transform.matrix;
            _loc4_.identity();
            _loc6_ = 1;
            _loc5_ = 1;
            _loc3_ = Number(param1.x);
            _loc2_ = Number(param1.y);
            if(_flipType == 2 || _flipType == 4)
            {
               _loc6_ *= -1;
               _loc3_ += param1.content.width;
            }
            if(_flipType == 3 || _flipType == 4)
            {
               _loc5_ *= -1;
               _loc2_ += param1.content.height;
            }
            _loc4_.scale(_loc6_,_loc5_);
            _loc4_.translate(_loc3_,_loc2_);
            param1.transform.matrix = _loc4_;
         }
      }
      
      public function getHeight() : int
      {
         return _clone.loader.height;
      }
      
      public function toggleRiverWater() : void
      {
         if(_riverWater && _riverWater.loader.content)
         {
            if(_riverWater.loader.parent)
            {
               _riverWater.loader.parent.removeChild(_riverWater.loader);
               _riverWater.loader.content.stop();
            }
            else
            {
               _scene.addChild(_riverWater.loader);
               initRiverWater();
            }
         }
      }
      
      public function testObstacleCollision(param1:RiverRacePlayer, param2:Point, param3:Point, param4:int) : void
      {
         var _loc7_:Rectangle = null;
         var _loc9_:Rectangle = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         if(param1._clone.loader.content)
         {
            _loc7_ = new Rectangle(param1._clone.loader.x + param1._clone.loader.content.collision.x,param1._clone.loader.y + param1._clone.loader.content.collision.y,param1._clone.loader.content.collision.width,param1._clone.loader.content.collision.height);
            _loc9_ = new Rectangle();
            if(_buoys)
            {
               _loc5_ = 0;
               while(_loc5_ < _buoys.length)
               {
                  _loc9_.x = _buoys[_loc5_].loader.content.collision.x + _buoys[_loc5_].loader.x;
                  _loc9_.y = _buoys[_loc5_].loader.content.collision.y + _buoys[_loc5_].loader.y;
                  _loc9_.width = _buoys[_loc5_].loader.content.collision.width;
                  _loc9_.height = _buoys[_loc5_].loader.content.collision.height;
                  if(_loc7_.intersects(_loc9_))
                  {
                     _buoys[_loc5_].loader.content.activateArrow();
                     param1.insideBuoy();
                  }
                  _loc5_++;
               }
            }
            if(_rocks)
            {
               _loc6_ = 0;
               while(_loc6_ < _rocks.length)
               {
                  _loc9_.x = _rocks[_loc6_].loader.content.collision.x + _rocks[_loc6_].loader.x;
                  _loc9_.y = _rocks[_loc6_].loader.content.collision.y + _rocks[_loc6_].loader.y;
                  _loc9_.width = _rocks[_loc6_].loader.content.collision.width;
                  _loc9_.height = _rocks[_loc6_].loader.content.collision.height;
                  if(_loc7_.intersects(_loc9_))
                  {
                     param1.insideRock();
                  }
                  _loc6_++;
               }
            }
            if(_whirlpools)
            {
               _loc8_ = 0;
               while(_loc8_ < _whirlpools.length)
               {
                  _loc9_.x = _whirlpools[_loc8_].loader.content.collision.x + _whirlpools[_loc8_].loader.x;
                  _loc9_.y = _whirlpools[_loc8_].loader.content.collision.y + _whirlpools[_loc8_].loader.y;
                  _loc9_.width = _whirlpools[_loc8_].loader.content.collision.width;
                  _loc9_.height = _whirlpools[_loc8_].loader.content.collision.height;
                  if(_loc7_.intersects(_loc9_))
                  {
                     param1.insideWhirlpool();
                  }
                  _loc8_++;
               }
            }
         }
      }
   }
}

