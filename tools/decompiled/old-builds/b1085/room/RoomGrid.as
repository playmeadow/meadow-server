package room
{
   import avatar.AvatarManager;
   import com.baseoneonline.astar.AStar;
   import com.baseoneonline.astar.Graph;
   import flash.geom.Point;
   import flash.utils.ByteArray;
   import gui.PartyManager;
   
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
         this._astar = new AStar();
      }
      
      public function setGridDepth(param1:uint) : void
      {
         this.GRID_DEPTH_LIMIT = param1;
      }
      
      public function setGrid(param1:Object) : void
      {
         var _loc2_:* = 0;
         var _loc3_:ByteArray = null;
         var _loc4_:Vector.<uint> = null;
         var _loc5_:int = 0;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:int = 0;
         if(param1.hasOwnProperty("packedGrid"))
         {
            _loc3_ = param1.packedGrid;
            _loc4_ = new Vector.<uint>(param1.height * param1.width);
            _loc5_ = 0;
            while(_loc5_ < _loc3_.length / 2)
            {
               _loc6_ = _loc3_.readUnsignedShort();
               _loc7_ = uint(_loc6_ >> 14);
               if(PartyManager.isBeYourPetParty())
               {
                  if(Boolean(_loc7_ & 1 << 1) && Boolean(AvatarManager.playerAvatarWorldView) && !AvatarManager.playerAvatarWorldView.isActivePetGroundPet())
                  {
                     _loc7_ = 0;
                  }
               }
               else if(AvatarManager.playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_AIR)
               {
                  if((_loc7_ & 1 << 1) == 0)
                  {
                     _loc7_ = 0;
                  }
               }
               else if(AvatarManager.playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_LAND)
               {
                  if((_loc7_ & 1 << 0) == 0)
                  {
                     _loc7_ = 0;
                  }
               }
               _loc6_ &= 16383;
               _loc8_ = 0;
               while(_loc8_ < _loc6_)
               {
                  var _loc9_:Number;
                  _loc4_[_loc9_ = _loc2_++] = _loc7_;
                  _loc8_++;
               }
               _loc5_++;
            }
            param1.grid = _loc4_;
         }
         this._grid = param1;
         this._astar.setGraph(this);
      }
      
      public function get hasReachedGoal() : Boolean
      {
         return this._astar.hasReachedGoal();
      }
      
      public function enableVolume(param1:String, param2:Boolean = true) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:uint = 0;
         var _loc11_:uint = 0;
         var _loc12_:int = 0;
         if(this._grid.hasOwnProperty("dynamicVolumes"))
         {
            _loc3_ = this._grid.dynamicVolumes;
            while(_loc4_ < _loc3_.length)
            {
               _loc5_ = _loc3_[_loc4_];
               if(_loc5_.name == param1)
               {
                  _loc5_.packedBlock.position = 0;
                  _loc6_ = int(_loc5_.y);
                  _loc8_ = _loc5_.x + _loc5_.y * this._grid.width;
                  _loc9_ = 0;
                  while(_loc9_ < _loc5_.packedBlock.length / 2)
                  {
                     _loc10_ = uint(_loc5_.packedBlock.readUnsignedShort());
                     _loc11_ = uint(_loc10_ >> 14);
                     _loc10_ &= 16383;
                     _loc12_ = 0;
                     while(_loc12_ < _loc10_)
                     {
                        if(_loc11_ > 0)
                        {
                           this._grid.grid[_loc8_] = param2 ? _loc11_ : 0;
                        }
                        _loc8_++;
                        if(++_loc7_ == _loc5_.width)
                        {
                           _loc7_ = 0;
                           _loc8_ += this._grid.width - _loc5_.width;
                        }
                        _loc12_++;
                     }
                     _loc9_++;
                  }
               }
               _loc4_++;
            }
         }
      }
      
      public function getCellIndex(param1:Number, param2:Number) : int
      {
         param1 -= this._grid.min.x;
         param2 -= this._grid.min.y;
         param1 /= this._grid.r2;
         param2 /= this._grid.r2;
         if(param1 < 0)
         {
            param1 = 0;
         }
         if(param1 >= this._grid.width)
         {
            param1 = this._grid.width - 1;
         }
         if(param2 < 0)
         {
            param2 = 0;
         }
         if(param2 >= this._grid.height)
         {
            param2 = this._grid.height - 1;
         }
         return int(int(param1) + int(param2) * this._grid.width);
      }
      
      public function convertWorldPosToGrid(param1:Number, param2:Number) : Object
      {
         param1 -= this._grid.min.x;
         param2 -= this._grid.min.y;
         param1 /= this._grid.r2;
         param2 /= this._grid.r2;
         var _loc3_:Boolean = true;
         if(param1 < 0 || param1 >= this._grid.width || param2 < 0 || param2 >= this._grid.height)
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
         var _loc2_:Number = int(param1 / this._grid.width);
         var _loc3_:Number = Math.abs(param1 % this._grid.width);
         return {
            "x":_loc3_,
            "y":_loc2_
         };
      }
      
      public function getCellIndexToWorldPos(param1:int) : Object
      {
         var _loc2_:Number = int(param1 / this._grid.width);
         var _loc3_:Number = param1 - _loc2_ * this._grid.width;
         _loc3_ *= this._grid.r2;
         _loc2_ *= this._grid.r2;
         _loc3_ += this._grid.min.x + this._grid.r;
         _loc2_ += this._grid.min.y + this._grid.r;
         return {
            "x":_loc3_,
            "y":_loc2_
         };
      }
      
      public function convertGridPosToWorld(param1:int, param2:int) : Object
      {
         var _loc3_:Number = param1 * this._grid.r2 + this._grid.min.x + this._grid.r;
         var _loc4_:Number = param2 * this._grid.r2 + this._grid.min.y + this._grid.r;
         return {
            "x":_loc3_,
            "y":_loc4_
         };
      }
      
      public function testGridCell(param1:int, param2:int) : uint
      {
         if(param1 >= 0 && param1 < this._grid.width && param2 >= 0 && param2 < this._grid.height)
         {
            return this._grid.grid[param2 * this._grid.width + param1];
         }
         return 1;
      }
      
      public function findPath(param1:Point, param2:Point) : Vector.<int>
      {
         if(!this._grid)
         {
            return new Vector.<int>();
         }
         return this._astar.solve(this.getCellIndex(param1.x,param1.y),this.getCellIndex(param2.x,param2.y));
      }
      
      public function findPathOptimized(param1:Point, param2:Point) : Vector.<int>
      {
         var _loc11_:int = 0;
         if(!this._grid)
         {
            return null;
         }
         var _loc3_:int = this.getCellIndex(param1.x,param1.y);
         var _loc4_:int = this.getCellIndex(param2.x,param2.y);
         if(_loc3_ < 0 || _loc4_ < 0 || _loc3_ > this.size() || _loc4_ > this.size())
         {
            return null;
         }
         var _loc5_:Vector.<int> = this._astar.solve(_loc3_,_loc4_);
         var _loc6_:Vector.<int> = new Vector.<int>();
         if(_loc5_.length == 1)
         {
            return _loc5_;
         }
         var _loc7_:int = this.getCellDir(_loc5_[0],_loc5_[1]);
         var _loc8_:int = int(_loc5_.length);
         var _loc9_:int = 0;
         var _loc10_:int = 1;
         while(_loc10_ < _loc8_)
         {
            _loc11_ = this.getCellDir(_loc5_[_loc10_ - 1],_loc5_[_loc10_]);
            if(_loc7_ != _loc11_)
            {
               _loc7_ = _loc11_;
               if(_loc9_ != _loc10_ - 1)
               {
                  _loc6_.push(_loc5_[_loc10_]);
                  _loc9_ = _loc10_;
               }
            }
            _loc10_++;
         }
         if(_loc6_.length == 0 || Boolean(_loc6_.length) && Boolean(_loc6_[_loc6_.length - 1] != _loc5_[_loc5_.length - 1]))
         {
            _loc6_.push(_loc5_[_loc5_.length - 1]);
         }
         return _loc6_;
      }
      
      private function getCellDir(param1:int, param2:int) : int
      {
         var _loc3_:int = -1;
         var _loc4_:int = int(this._grid.width);
         if(param1 - _loc4_ == param2)
         {
            _loc3_ = 0;
         }
         else if(param1 - _loc4_ + 1 == param2)
         {
            _loc3_ = 1;
         }
         else if(param1 + 1 == param2)
         {
            _loc3_ = 2;
         }
         else if(param1 + _loc4_ + 1 == param2)
         {
            _loc3_ = 3;
         }
         else if(param1 + _loc4_ == param2)
         {
            _loc3_ = 4;
         }
         else if(param1 + _loc4_ - 1 == param2)
         {
            _loc3_ = 5;
         }
         else if(param1 - 1 == param2)
         {
            _loc3_ = 6;
         }
         else if(param1 - _loc4_ - 1 == param2)
         {
            _loc3_ = 7;
         }
         return _loc3_;
      }
      
      public function setStartGridPos(param1:int) : void
      {
         this.startPos = this.convertCellToCoords(param1);
      }
      
      public function getNeighbors(param1:int, param2:Vector.<int>) : Vector.<int>
      {
         var _loc3_:int = 0;
         var _loc4_:Object = this.convertCellToCoords(param1);
         var _loc5_:int = int(_loc4_.x);
         var _loc6_:int = int(_loc4_.y);
         var _loc7_:int = int(this._grid.width);
         var _loc8_:int = int(this._grid.height);
         var _loc9_:Boolean = Math.abs(_loc4_.x - 1 - this.startPos.x) < this.GRID_DEPTH_LIMIT;
         var _loc10_:Boolean = Math.abs(_loc4_.x + 1 - this.startPos.x) < this.GRID_DEPTH_LIMIT;
         var _loc11_:Boolean = Math.abs(_loc4_.y - 1 - this.startPos.y) < this.GRID_DEPTH_LIMIT;
         var _loc12_:Boolean = Math.abs(_loc4_.y + 1 - this.startPos.y) < this.GRID_DEPTH_LIMIT;
         param2.length = 0;
         if(_loc5_ > 0)
         {
            _loc3_ = param1 - 1;
            if(!this._grid.grid[_loc3_] && _loc9_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc6_ > 0)
         {
            _loc3_ = param1 - _loc7_;
            if(!this._grid.grid[_loc3_] && _loc11_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc5_ < _loc7_ - 1)
         {
            _loc3_ = param1 + 1;
            if(!this._grid.grid[_loc3_] && _loc10_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc6_ < _loc8_ - 1)
         {
            _loc3_ = param1 + _loc7_;
            if(!this._grid.grid[_loc3_] && _loc12_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc5_ > 0 && _loc6_ > 0)
         {
            _loc3_ = param1 - 1 - _loc7_;
            if(!this._grid.grid[_loc3_] && !this._grid.grid[param1 - 1] && !this._grid.grid[param1 - _loc7_] && _loc11_ && _loc9_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc5_ < _loc7_ - 1 && _loc6_ > 0)
         {
            _loc3_ = param1 + 1 - _loc7_;
            if(!this._grid.grid[_loc3_] && !this._grid.grid[param1 + 1] && !this._grid.grid[param1 - _loc7_] && _loc11_ && _loc10_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc5_ > 0 && _loc6_ < _loc8_ - 1)
         {
            _loc3_ = param1 - 1 + _loc7_;
            if(!this._grid.grid[_loc3_] && !this._grid.grid[param1 - 1] && !this._grid.grid[param1 + _loc7_] && _loc12_ && _loc9_)
            {
               param2.push(_loc3_);
            }
         }
         if(_loc5_ < _loc7_ - 1 && _loc6_ < _loc8_ - 1)
         {
            _loc3_ = param1 + 1 + _loc7_;
            if(!this._grid.grid[_loc3_] && !this._grid.grid[param1 + 1] && !this._grid.grid[param1 + _loc7_] && _loc12_ && _loc10_)
            {
               param2.push(_loc3_);
            }
         }
         return param2;
      }
      
      public function distance(param1:int, param2:int) : Number
      {
         var _loc3_:Object = this.getCellIndexToWorldPos(param1);
         var _loc4_:Object = this.getCellIndexToWorldPos(param2);
         var _loc5_:Number = Math.min(Math.abs(_loc3_.x - _loc4_.x),Math.abs(_loc3_.y - _loc4_.y));
         var _loc6_:Number = Math.abs(_loc3_.x - _loc4_.x) + Math.abs(_loc3_.y - _loc4_.y);
         return COST_DIAG * _loc5_ + _loc6_ - 2 * _loc5_;
      }
      
      public function size() : int
      {
         if(this._grid == null)
         {
            return 0;
         }
         return this._grid.width * this._grid.height;
      }
      
      public function findClosestOpenGridCell(param1:Number, param2:Number) : Object
      {
         var _loc8_:int = 0;
         var _loc3_:Object = this.convertWorldPosToGrid(param1,param2);
         var _loc4_:* = int(_loc3_.x);
         var _loc5_:* = int(_loc3_.y);
         var _loc6_:int = int(this._grid.width);
         var _loc7_:int = int(this._grid.height);
         var _loc9_:int = 3;
         var _loc10_:int = 20;
         while(_loc9_ < _loc10_)
         {
            _loc3_ = this.scanBox(_loc4_,_loc5_,_loc9_);
            if(_loc3_)
            {
               break;
            }
            _loc9_ += 2;
            _loc4_--;
            _loc5_--;
         }
         if(_loc3_)
         {
            _loc3_ = this.convertGridPosToWorld(_loc3_.x,_loc3_.y);
         }
         return _loc3_;
      }
      
      private function scanBox(param1:int, param2:int, param3:int) : Object
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         param3--;
         param1++;
         while(_loc4_ < 4)
         {
            if(!this.testGridCell(param1,param2))
            {
               return {
                  "x":param1,
                  "y":param2
               };
            }
            if(++_loc5_ == param3)
            {
               _loc5_ = 0;
               _loc4_++;
            }
            switch(_loc4_)
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

