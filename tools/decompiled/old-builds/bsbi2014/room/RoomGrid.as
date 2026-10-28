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
         this._astar = new AStar();
      }
      
      public function setGridDepth(depth:uint) : void
      {
         this.GRID_DEPTH_LIMIT = depth;
      }
      
      public function setGrid(grid:Object) : void
      {
         var pos:int = 0;
         var packed:ByteArray = null;
         var g:Vector.<uint> = null;
         var i:int = 0;
         var count:uint = 0;
         var type:uint = 0;
         var j:int = 0;
         if(grid.hasOwnProperty("packedGrid"))
         {
            packed = grid.packedGrid;
            packed.position = 0;
            g = new Vector.<uint>(grid.height * grid.width);
            for(i = 0; i < packed.length / 2; i++)
            {
               count = packed.readUnsignedShort();
               type = uint(count >> 14);
               if(GuiManager.isBeYourPetRoom())
               {
                  if(Boolean(type & 1 << 1) && Boolean(AvatarManager.playerAvatarWorldView) && !AvatarManager.playerAvatarWorldView.isActivePetGroundPet())
                  {
                     type = 0;
                  }
               }
               else if(Boolean(AvatarManager.playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_AIR))
               {
                  if((type & 1 << 1) == 0)
                  {
                     type = 0;
                  }
               }
               else if(Boolean(AvatarManager.playerAvatar.enviroTypeFlag & 1 << Utility.ENVIRO_LAND))
               {
                  if((type & 1 << 0) == 0)
                  {
                     type = 0;
                  }
               }
               count &= 16383;
               for(j = 0; j < count; j++)
               {
                  g[pos++] = type;
               }
            }
            grid.grid = g;
         }
         this._grid = grid;
         this._astar.setGraph(this);
      }
      
      public function get hasReachedGoal() : Boolean
      {
         return this._astar.hasReachedGoal();
      }
      
      public function enableVolume(name:String, bEnable:Boolean = true) : void
      {
         var d:Array = null;
         var i:int = 0;
         var dv:Object = null;
         var y:int = 0;
         var w:int = 0;
         var pos:int = 0;
         var c:int = 0;
         var count:uint = 0;
         var type:uint = 0;
         var j:int = 0;
         if(this._grid.hasOwnProperty("dynamicVolumes"))
         {
            for(d = this._grid.dynamicVolumes; i < d.length; )
            {
               dv = d[i];
               if(dv.name == name)
               {
                  dv.packedBlock.position = 0;
                  y = int(dv.y);
                  pos = dv.x + dv.y * this._grid.width;
                  for(c = 0; c < dv.packedBlock.length / 2; c++)
                  {
                     count = uint(dv.packedBlock.readUnsignedShort());
                     type = uint(count >> 14);
                     count &= 16383;
                     for(j = 0; j < count; j++)
                     {
                        if(type > 0)
                        {
                           this._grid.grid[pos] = bEnable ? type : 0;
                        }
                        pos++;
                        w++;
                        if(w == dv.width)
                        {
                           w = 0;
                           pos += this._grid.width - dv.width;
                        }
                     }
                  }
               }
               i++;
            }
         }
      }
      
      public function getCellIndex(x:Number, y:Number) : int
      {
         x -= this._grid.min.x;
         y -= this._grid.min.y;
         x /= this._grid.r2;
         y /= this._grid.r2;
         if(x < 0)
         {
            x = 0;
         }
         if(x >= this._grid.width)
         {
            x = this._grid.width - 1;
         }
         if(y < 0)
         {
            y = 0;
         }
         if(y >= this._grid.height)
         {
            y = this._grid.height - 1;
         }
         return int(int(x) + int(y) * this._grid.width);
      }
      
      public function convertWorldPosToGrid(x:Number, y:Number) : Object
      {
         x -= this._grid.min.x;
         y -= this._grid.min.y;
         x /= this._grid.r2;
         y /= this._grid.r2;
         var bInBounds:Boolean = true;
         if(x < 0 || x >= this._grid.width || y < 0 || y >= this._grid.height)
         {
            bInBounds = false;
         }
         return {
            "x":int(x),
            "y":int(y),
            "bInBounds":bInBounds
         };
      }
      
      public function convertCellToCoords(i:int) : Object
      {
         var y:Number = int(i / this._grid.width);
         var x:Number = Math.abs(i % this._grid.width);
         return {
            "x":x,
            "y":y
         };
      }
      
      public function getCellIndexToWorldPos(i:int) : Object
      {
         var y:Number = int(i / this._grid.width);
         var x:Number = i - y * this._grid.width;
         x *= this._grid.r2;
         y *= this._grid.r2;
         x += this._grid.min.x + this._grid.r;
         y += this._grid.min.y + this._grid.r;
         return {
            "x":x,
            "y":y
         };
      }
      
      public function convertGridPosToWorld(x:int, y:int) : Object
      {
         var xp:Number = x * this._grid.r2 + this._grid.min.x + this._grid.r;
         var yp:Number = y * this._grid.r2 + this._grid.min.y + this._grid.r;
         return {
            "x":xp,
            "y":yp
         };
      }
      
      public function testGridCell(x:int, y:int) : uint
      {
         if(x >= 0 && x < this._grid.width && y >= 0 && y < this._grid.height)
         {
            return this._grid.grid[y * this._grid.width + x];
         }
         return 1;
      }
      
      public function findPath(start:Point, end:Point) : Vector.<int>
      {
         if(!this._grid)
         {
            return new Vector.<int>();
         }
         return this._astar.solve(this.getCellIndex(start.x,start.y),this.getCellIndex(end.x,end.y));
      }
      
      public function findPathOptimized(start:Point, end:Point) : Vector.<int>
      {
         var newDir:int = 0;
         if(!this._grid)
         {
            return null;
         }
         var si:int = this.getCellIndex(start.x,start.y);
         var ei:int = this.getCellIndex(end.x,end.y);
         if(si < 0 || ei < 0 || si > this.size() || ei > this.size())
         {
            return null;
         }
         var p:Vector.<int> = this._astar.solve(si,ei);
         var a:Vector.<int> = new Vector.<int>();
         if(p.length == 1)
         {
            return p;
         }
         var dir:int = this.getCellDir(p[0],p[1]);
         var len:int = int(p.length);
         var lastAdded:int = 0;
         for(var i:int = 1; i < len; i++)
         {
            newDir = this.getCellDir(p[i - 1],p[i]);
            if(dir != newDir)
            {
               dir = newDir;
               if(lastAdded != i - 1)
               {
                  a.push(p[i]);
                  lastAdded = i;
               }
            }
         }
         if(a.length == 0 || Boolean(a.length) && Boolean(a[a.length - 1] != p[p.length - 1]))
         {
            a.push(p[p.length - 1]);
         }
         return a;
      }
      
      private function getCellDir(c1:int, c2:int) : int
      {
         var d:int = -1;
         var w:int = int(this._grid.width);
         if(c1 - w == c2)
         {
            d = 0;
         }
         else if(c1 - w + 1 == c2)
         {
            d = 1;
         }
         else if(c1 + 1 == c2)
         {
            d = 2;
         }
         else if(c1 + w + 1 == c2)
         {
            d = 3;
         }
         else if(c1 + w == c2)
         {
            d = 4;
         }
         else if(c1 + w - 1 == c2)
         {
            d = 5;
         }
         else if(c1 - 1 == c2)
         {
            d = 6;
         }
         else if(c1 - w - 1 == c2)
         {
            d = 7;
         }
         return d;
      }
      
      public function setStartGridPos(i:int) : void
      {
         this.startPos = this.convertCellToCoords(i);
      }
      
      public function getNeighbors(i:int, neighbors:Vector.<int>) : Vector.<int>
      {
         var c:int = 0;
         var pos:Object = this.convertCellToCoords(i);
         var x:int = int(pos.x);
         var y:int = int(pos.y);
         var w:int = int(this._grid.width);
         var h:int = int(this._grid.height);
         var wIsValid:Boolean = Math.abs(pos.x - 1 - this.startPos.x) < this.GRID_DEPTH_LIMIT;
         var eIsValid:Boolean = Math.abs(pos.x + 1 - this.startPos.x) < this.GRID_DEPTH_LIMIT;
         var nIsValid:Boolean = Math.abs(pos.y - 1 - this.startPos.y) < this.GRID_DEPTH_LIMIT;
         var sIsValid:Boolean = Math.abs(pos.y + 1 - this.startPos.y) < this.GRID_DEPTH_LIMIT;
         neighbors.length = 0;
         if(x > 0)
         {
            c = i - 1;
            if(!this._grid.grid[c] && wIsValid)
            {
               neighbors.push(c);
            }
         }
         if(y > 0)
         {
            c = i - w;
            if(!this._grid.grid[c] && nIsValid)
            {
               neighbors.push(c);
            }
         }
         if(x < w - 1)
         {
            c = i + 1;
            if(!this._grid.grid[c] && eIsValid)
            {
               neighbors.push(c);
            }
         }
         if(y < h - 1)
         {
            c = i + w;
            if(!this._grid.grid[c] && sIsValid)
            {
               neighbors.push(c);
            }
         }
         if(x > 0 && y > 0)
         {
            c = i - 1 - w;
            if(!this._grid.grid[c] && !this._grid.grid[i - 1] && !this._grid.grid[i - w] && nIsValid && wIsValid)
            {
               neighbors.push(c);
            }
         }
         if(x < w - 1 && y > 0)
         {
            c = i + 1 - w;
            if(!this._grid.grid[c] && !this._grid.grid[i + 1] && !this._grid.grid[i - w] && nIsValid && eIsValid)
            {
               neighbors.push(c);
            }
         }
         if(x > 0 && y < h - 1)
         {
            c = i - 1 + w;
            if(!this._grid.grid[c] && !this._grid.grid[i - 1] && !this._grid.grid[i + w] && sIsValid && wIsValid)
            {
               neighbors.push(c);
            }
         }
         if(x < w - 1 && y < h - 1)
         {
            c = i + 1 + w;
            if(!this._grid.grid[c] && !this._grid.grid[i + 1] && !this._grid.grid[i + w] && sIsValid && eIsValid)
            {
               neighbors.push(c);
            }
         }
         return neighbors;
      }
      
      public function distance(a:int, b:int) : Number
      {
         var n1:Object = this.getCellIndexToWorldPos(a);
         var n2:Object = this.getCellIndexToWorldPos(b);
         var h_diag:Number = Math.min(Math.abs(n1.x - n2.x),Math.abs(n1.y - n2.y));
         var h_orth:Number = Math.abs(n1.x - n2.x) + Math.abs(n1.y - n2.y);
         return COST_DIAG * h_diag + h_orth - 2 * h_diag;
      }
      
      public function size() : int
      {
         if(this._grid == null)
         {
            return 0;
         }
         return this._grid.width * this._grid.height;
      }
      
      public function findClosestOpenGridCell(xs:Number, ys:Number) : Object
      {
         var ci:int = 0;
         var pos:Object = this.convertWorldPosToGrid(xs,ys);
         var x:int = int(pos.x);
         var y:int = int(pos.y);
         var w:int = int(this._grid.width);
         var h:int = int(this._grid.height);
         var step:int = 3;
         var stepMax:int = 20;
         while(step < stepMax)
         {
            pos = this.scanBox(x,y,step);
            if(Boolean(pos))
            {
               break;
            }
            step += 2;
            x--;
            y--;
         }
         if(Boolean(pos))
         {
            pos = this.convertGridPosToWorld(pos.x,pos.y);
         }
         return pos;
      }
      
      private function scanBox(x:int, y:int, size:int) : Object
      {
         var dir:int = 0;
         var count:int = 0;
         size--;
         x++;
         while(dir < 4)
         {
            if(!this.testGridCell(x,y))
            {
               return {
                  "x":x,
                  "y":y
               };
            }
            count++;
            if(count == size)
            {
               count = 0;
               dir++;
            }
            switch(dir)
            {
               case 0:
                  x++;
                  break;
               case 1:
                  y++;
                  break;
               case 2:
                  x--;
                  break;
               case 3:
                  y--;
            }
         }
         return null;
      }
   }
}

