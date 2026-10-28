package room
{
   import avatar.AvatarManager;
   import com.baseoneonline.astar.AStar;
   import com.baseoneonline.astar.Graph;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import gui.GuiManager;
   
   public class RoomGrid implements Graph
   {
      
      public static const GRID_CELL_OPEN:uint = 0;
      
      public static const GRID_CELL_WALL:uint = 1;
      
      public static const GRID_CELL_AIR:uint = 2;
      
      public static const GRID_CELL_PHANTOM:uint = 3;
      
      private static const COST_DIAG:Number = Math.sqrt(2);
      
      private var GRID_DEPTH_LIMIT:uint = 128;
      
      private var startPos:Object;
      
      private var _grid:Object;
      
      private var _astar:AStar;
      
      public function RoomGrid()
      {
         super();
         _astar = new AStar();
      }
      
      public function setGridDepth(param1:uint) : void
      {
         GRID_DEPTH_LIMIT = param1;
      }
      
      public function setGrid(param1:Object) : void
      {
         var _loc8_:int = 0;
         var _loc4_:ByteArray = null;
         var _loc2_:* = undefined;
         var _loc7_:int = 0;
         var _loc3_:* = 0;
         var _loc6_:* = 0;
         var _loc5_:int = 0;
         if(param1.hasOwnProperty("packedGrid"))
         {
            _loc4_ = param1.packedGrid;
            _loc4_.position = 0;
            _loc2_ = new Vector.<uint>(param1.height * param1.width);
            _loc7_ = 0;
            while(_loc7_ < _loc4_.length / 2)
            {
               _loc3_ = _loc4_.readUnsignedShort();
               _loc6_ = uint(_loc3_ >> 14);
               if(GuiManager.isBeYourPetRoom())
               {
                  if(_loc6_ & 2 && AvatarManager.playerAvatarWorldView && !AvatarManager.playerAvatarWorldView.isActivePetGroundPet())
                  {
                     _loc6_ = 0;
                  }
               }
               else if(AvatarManager.playerAvatar)
               {
                  if(AvatarManager.playerAvatar.enviroTypeFlag & 1 << 2)
                  {
                     if((_loc6_ & 2) == 0)
                     {
                        _loc6_ = 0;
                     }
                  }
                  else if(AvatarManager.playerAvatar.enviroTypeFlag & 1 << 0)
                  {
                     if((_loc6_ & 1) == 0)
                     {
                        _loc6_ = 0;
                     }
                  }
               }
               _loc3_ &= 16383;
               _loc5_ = 0;
               while(_loc5_ < _loc3_)
               {
                  _loc2_[_loc8_++] = _loc6_;
                  _loc5_++;
               }
               _loc7_++;
            }
            param1.grid = _loc2_;
         }
         _grid = param1;
         _astar.setGraph(this);
      }
      
      public function get hasReachedGoal() : Boolean
      {
         return _astar.hasReachedGoal();
      }
      
      public function enableVolume(param1:String, param2:Boolean = true) : void
      {
         var _loc5_:Array = null;
         var _loc12_:int = 0;
         var _loc4_:Object = null;
         var _loc10_:int = 0;
         var _loc3_:int = 0;
         var _loc11_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:* = 0;
         var _loc9_:* = 0;
         var _loc8_:int = 0;
         if(_grid.hasOwnProperty("dynamicVolumes"))
         {
            _loc5_ = _grid.dynamicVolumes;
            while(_loc12_ < _loc5_.length)
            {
               _loc4_ = _loc5_[_loc12_];
               if(_loc4_.name == param1)
               {
                  _loc4_.packedBlock.position = 0;
                  _loc10_ = int(_loc4_.y);
                  _loc11_ = _loc4_.x + _loc4_.y * _grid.width;
                  _loc7_ = 0;
                  while(_loc7_ < _loc4_.packedBlock.length / 2)
                  {
                     _loc6_ = uint(_loc4_.packedBlock.readUnsignedShort());
                     _loc9_ = uint(_loc6_ >> 14);
                     _loc6_ &= 16383;
                     _loc8_ = 0;
                     while(_loc8_ < _loc6_)
                     {
                        if(_loc9_ > 0)
                        {
                           _grid.grid[_loc11_] = param2 ? _loc9_ : 0;
                        }
                        _loc11_++;
                        if(++_loc3_ == _loc4_.width)
                        {
                           _loc3_ = 0;
                           _loc11_ += _grid.width - _loc4_.width;
                        }
                        _loc8_++;
                     }
                     _loc7_++;
                  }
               }
               _loc12_++;
            }
         }
      }
      
      public function getCellIndex(param1:Number, param2:Number) : int
      {
         param1 -= _grid.min.x;
         param2 -= _grid.min.y;
         param1 /= _grid.r2;
         param2 /= _grid.r2;
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 >= _grid.width)
         {
            param1 = _grid.width - 1;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         if(param2 >= _grid.height)
         {
            param2 = _grid.height - 1;
         }
         return int(int(param1) + int(param2) * _grid.width);
      }
      
      public function convertWorldPosToGrid(param1:Number, param2:Number) : Object
      {
         param1 -= _grid.min.x;
         param2 -= _grid.min.y;
         param1 /= _grid.r2;
         param2 /= _grid.r2;
         var _loc3_:Boolean = true;
         if(param1 < 0 || param1 >= _grid.width || param2 < 0 || param2 >= _grid.height)
         {
            _loc3_ = false;
         }
         return {
            "x":int(param1),
            "y":int(param2),
            "bInBounds":_loc3_
         };
      }
      
      public function convertCellToCoords(param1:int) : Object
      {
         var _loc2_:Number = int(param1 / _grid.width);
         var _loc3_:Number = Math.abs(param1 % _grid.width);
         return {
            "x":_loc3_,
            "y":_loc2_
         };
      }
      
      public function getCellIndexToWorldPos(param1:int) : Object
      {
         var _loc2_:Number = int(param1 / _grid.width);
         var _loc3_:Number = param1 - _loc2_ * _grid.width;
         _loc3_ *= _grid.r2;
         _loc2_ *= _grid.r2;
         _loc3_ += _grid.min.x + _grid.r;
         _loc2_ += _grid.min.y + _grid.r;
         return {
            "x":_loc3_,
            "y":_loc2_
         };
      }
      
      public function convertGridPosToWorld(param1:int, param2:int) : Object
      {
         var _loc4_:Number = param1 * _grid.r2 + _grid.min.x + _grid.r;
         var _loc3_:Number = param2 * _grid.r2 + _grid.min.y + _grid.r;
         return {
            "x":_loc4_,
            "y":_loc3_
         };
      }
      
      public function testGridCell(param1:int, param2:int) : uint
      {
         if(param1 >= 0 && param1 < _grid.width && param2 >= 0 && param2 < _grid.height)
         {
            return _grid.grid[param2 * _grid.width + param1];
         }
         return 1;
      }
      
      public function findPath(param1:Point, param2:Point) : Vector.<int>
      {
         if(!_grid)
         {
            return new Vector.<int>();
         }
         return _astar.solve(getCellIndex(param1.x,param1.y),getCellIndex(param2.x,param2.y));
      }
      
      public function findPathOptimized(param1:Point, param2:Point) : Vector.<int>
      {
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         if(!_grid)
         {
            return null;
         }
         var _loc11_:int = getCellIndex(param1.x,param1.y);
         var _loc7_:int = getCellIndex(param2.x,param2.y);
         if(_loc11_ < 0 || _loc7_ < 0 || _loc11_ > size() || _loc7_ > size())
         {
            return null;
         }
         var _loc6_:Vector.<int> = _astar.solve(_loc11_,_loc7_);
         var _loc5_:Vector.<int> = new Vector.<int>();
         if(_loc6_.length == 1)
         {
            return _loc6_;
         }
         var _loc4_:int = getCellDir(_loc6_[0],_loc6_[1]);
         var _loc8_:int = int(_loc6_.length);
         var _loc10_:int = 0;
         _loc9_ = 1;
         while(_loc9_ < _loc8_)
         {
            _loc3_ = getCellDir(_loc6_[_loc9_ - 1],_loc6_[_loc9_]);
            if(_loc4_ != _loc3_)
            {
               _loc4_ = _loc3_;
               if(_loc10_ != _loc9_ - 1)
               {
                  _loc5_.push(_loc6_[_loc9_]);
                  _loc10_ = _loc9_;
               }
            }
            _loc9_++;
         }
         if(_loc5_.length == 0 || _loc5_.length && _loc5_[_loc5_.length - 1] != _loc6_[_loc6_.length - 1])
         {
            _loc5_.push(_loc6_[_loc6_.length - 1]);
         }
         return _loc5_;
      }
      
      private function getCellDir(param1:int, param2:int) : int
      {
         var _loc4_:int = -1;
         var _loc3_:int = int(_grid.width);
         if(param1 - _loc3_ == param2)
         {
            _loc4_ = 0;
         }
         else if(param1 - _loc3_ + 1 == param2)
         {
            _loc4_ = 1;
         }
         else if(param1 + 1 == param2)
         {
            _loc4_ = 2;
         }
         else if(param1 + _loc3_ + 1 == param2)
         {
            _loc4_ = 3;
         }
         else if(param1 + _loc3_ == param2)
         {
            _loc4_ = 4;
         }
         else if(param1 + _loc3_ - 1 == param2)
         {
            _loc4_ = 5;
         }
         else if(param1 - 1 == param2)
         {
            _loc4_ = 6;
         }
         else if(param1 - _loc3_ - 1 == param2)
         {
            _loc4_ = 7;
         }
         return _loc4_;
      }
      
      public function setStartGridPos(param1:int) : void
      {
         startPos = convertCellToCoords(param1);
      }
      
      public function getNeighbors(param1:int, param2:Vector.<int>) : Vector.<int>
      {
         var _loc6_:int = 0;
         var _loc12_:Object = convertCellToCoords(param1);
         var _loc11_:int = int(_loc12_.x);
         var _loc10_:int = int(_loc12_.y);
         var _loc3_:int = int(_grid.width);
         var _loc9_:int = int(_grid.height);
         var _loc8_:Boolean = Math.abs(_loc12_.x - 1 - startPos.x) < GRID_DEPTH_LIMIT;
         var _loc5_:Boolean = Math.abs(_loc12_.x + 1 - startPos.x) < GRID_DEPTH_LIMIT;
         var _loc4_:Boolean = Math.abs(_loc12_.y - 1 - startPos.y) < GRID_DEPTH_LIMIT;
         var _loc7_:Boolean = Math.abs(_loc12_.y + 1 - startPos.y) < GRID_DEPTH_LIMIT;
         param2.length = 0;
         if(_loc11_ > 0)
         {
            _loc6_ = param1 - 1;
            if(!_grid.grid[_loc6_] && _loc8_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc10_ > 0)
         {
            _loc6_ = param1 - _loc3_;
            if(!_grid.grid[_loc6_] && _loc4_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc11_ < _loc3_ - 1)
         {
            _loc6_ = param1 + 1;
            if(!_grid.grid[_loc6_] && _loc5_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc10_ < _loc9_ - 1)
         {
            _loc6_ = param1 + _loc3_;
            if(!_grid.grid[_loc6_] && _loc7_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc11_ > 0 && _loc10_ > 0)
         {
            _loc6_ = param1 - 1 - _loc3_;
            if(!_grid.grid[_loc6_] && !_grid.grid[param1 - 1] && !_grid.grid[param1 - _loc3_] && _loc4_ && _loc8_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc11_ < _loc3_ - 1 && _loc10_ > 0)
         {
            _loc6_ = param1 + 1 - _loc3_;
            if(!_grid.grid[_loc6_] && !_grid.grid[param1 + 1] && !_grid.grid[param1 - _loc3_] && _loc4_ && _loc5_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc11_ > 0 && _loc10_ < _loc9_ - 1)
         {
            _loc6_ = param1 - 1 + _loc3_;
            if(!_grid.grid[_loc6_] && !_grid.grid[param1 - 1] && !_grid.grid[param1 + _loc3_] && _loc7_ && _loc8_)
            {
               param2.push(_loc6_);
            }
         }
         if(_loc11_ < _loc3_ - 1 && _loc10_ < _loc9_ - 1)
         {
            _loc6_ = param1 + 1 + _loc3_;
            if(!_grid.grid[_loc6_] && !_grid.grid[param1 + 1] && !_grid.grid[param1 + _loc3_] && _loc7_ && _loc5_)
            {
               param2.push(_loc6_);
            }
         }
         return param2;
      }
      
      public function distance(param1:int, param2:int) : Number
      {
         var _loc3_:Object = getCellIndexToWorldPos(param1);
         var _loc5_:Object = getCellIndexToWorldPos(param2);
         var _loc6_:Number = Math.min(Math.abs(_loc3_.x - _loc5_.x),Math.abs(_loc3_.y - _loc5_.y));
         var _loc4_:Number = Math.abs(_loc3_.x - _loc5_.x) + Math.abs(_loc3_.y - _loc5_.y);
         return COST_DIAG * _loc6_ + _loc4_ - 2 * _loc6_;
      }
      
      public function size() : int
      {
         if(_grid == null)
         {
            return 0;
         }
         return _grid.width * _grid.height;
      }
      
      public function findClosestOpenGridCell(param1:Number, param2:Number) : Object
      {
         var _loc4_:int = 0;
         var _loc10_:Object = convertWorldPosToGrid(param1,param2);
         var _loc9_:int = int(_loc10_.x);
         var _loc8_:int = int(_loc10_.y);
         var _loc3_:int = int(_grid.width);
         var _loc7_:int = int(_grid.height);
         var _loc6_:int = 3;
         var _loc5_:int = 20;
         while(_loc6_ < _loc5_)
         {
            _loc10_ = scanBox(_loc9_,_loc8_,_loc6_);
            if(_loc10_)
            {
               break;
            }
            _loc6_ += 2;
            _loc9_--;
            _loc8_--;
         }
         if(_loc10_)
         {
            _loc10_ = convertGridPosToWorld(_loc10_.x,_loc10_.y);
         }
         return _loc10_;
      }
      
      private function scanBox(param1:int, param2:int, param3:int) : Object
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         param3--;
         param1++;
         while(_loc5_ < 4)
         {
            if(!testGridCell(param1,param2))
            {
               return {
                  "x":param1,
                  "y":param2
               };
            }
            if(++_loc4_ == param3)
            {
               _loc4_ = 0;
               _loc5_++;
            }
            switch(_loc5_)
            {
               case 0:
                  param1++;
                  break;
               case 1:
                  param2++;
                  break;
               case 2:
                  param1--;
                  break;
               case 3:
                  param2--;
            }
         }
         return null;
      }
   }
}

