package com.baseoneonline.astar
{
   import flash.utils.Dictionary;
   
   public class AStar
   {
      
      private var graph:Graph;
      
      private var g:Vector.<Number>;
      
      private var h:Vector.<Number>;
      
      private var f:Vector.<Number>;
      
      private var parent:Vector.<int>;
      
      private var open:Vector.<int>;
      
      private var closed:Vector.<int>;
      
      private var closedDict:Dictionary;
      
      private var goalReached:Boolean = false;
      
      public function AStar(g:Graph = null)
      {
         super();
         if(Boolean(g))
         {
            this.setGraph(g);
         }
      }
      
      public function setGraph(graph:Graph) : void
      {
         this.graph = graph;
         this.updateGraph();
      }
      
      private function updateGraph() : void
      {
         var len:int = this.graph.size();
         this.g = new Vector.<Number>(len,true);
         this.h = new Vector.<Number>(len,true);
         this.f = new Vector.<Number>(len,true);
         this.parent = new Vector.<int>(len,true);
      }
      
      public function solve(start:int, goal:int) : Vector.<int>
      {
         var n:int = 0;
         var tf:Number = NaN;
         var x:int = 0;
         var i:int = 0;
         var y:int = 0;
         var e:int = 0;
         var tg:Number = NaN;
         var better:Boolean = false;
         var d:Number = NaN;
         var neighbors:Vector.<int> = new Vector.<int>();
         this.goalReached = false;
         this.open = new Vector.<int>();
         this.closed = new Vector.<int>();
         this.closedDict = new Dictionary(true);
         this.open.push(start);
         this.g[start] = 0;
         this.h[start] = this.graph.distance(start,goal);
         this.f[start] = this.h[start];
         this.parent[start] = -1;
         this.graph.setStartGridPos(start);
         while(this.open.length > 0)
         {
            tf = Number.POSITIVE_INFINITY;
            x = -1;
            for(i = 0; i < this.open.length; i++)
            {
               e = this.open[i];
               if(this.f[e] < tf)
               {
                  tf = this.f[e];
                  x = e;
               }
            }
            if(x == goal)
            {
               this.goalReached = true;
               return this.createPath(goal,start);
            }
            this.open.splice(this.open.indexOf(x),1);
            this.closed.push(x);
            this.closedDict[x] = 1;
            for each(y in this.graph.getNeighbors(x,neighbors))
            {
               if(this.closedDict[y] != 1)
               {
                  tg = this.g[x] + this.graph.distance(x,y);
                  better = false;
                  if(this.open.indexOf(y) == -1)
                  {
                     this.open.push(y);
                     better = true;
                  }
                  else if(tg < this.g[y])
                  {
                     better = true;
                  }
                  if(better)
                  {
                     this.parent[y] = x;
                     this.g[y] = tg;
                     this.h[y] = this.graph.distance(y,goal);
                     this.f[y] = this.g[y] + this.h[y];
                  }
               }
            }
         }
         var min:Number = Number.POSITIVE_INFINITY;
         var ng:int = -1;
         for each(n in this.closed)
         {
            d = this.h[n];
            if(d < min)
            {
               min = d;
               ng = n;
            }
         }
         return this.createPath(ng,start);
      }
      
      public function hasReachedGoal() : Boolean
      {
         return this.goalReached;
      }
      
      private function createPath(n:int, start:int) : Vector.<int>
      {
         var solution:Vector.<int> = new Vector.<int>();
         while(this.parent[n] != -1)
         {
            solution.push(n);
            n = this.parent[n];
         }
         solution.push(start);
         return solution.reverse();
      }
   }
}

