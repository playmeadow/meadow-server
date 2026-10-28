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
      
      public function AStar(param1:Graph = null)
      {
         super();
         if(param1)
         {
            this.setGraph(param1);
         }
      }
      
      public function setGraph(param1:Graph) : void
      {
         this.graph = param1;
         this.updateGraph();
      }
      
      private function updateGraph() : void
      {
         var _loc1_:int = this.graph.size();
         this.g = new Vector.<Number>(_loc1_,true);
         this.h = new Vector.<Number>(_loc1_,true);
         this.f = new Vector.<Number>(_loc1_,true);
         this.parent = new Vector.<int>(_loc1_,true);
      }
      
      public function solve(param1:int, param2:int) : Vector.<int>
      {
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:Boolean = false;
         var _loc14_:Number = NaN;
         var _loc3_:Vector.<int> = new Vector.<int>();
         this.goalReached = false;
         this.open = new Vector.<int>();
         this.closed = new Vector.<int>();
         this.closedDict = new Dictionary(true);
         this.open.push(param1);
         this.g[param1] = 0;
         this.h[param1] = this.graph.distance(param1,param2);
         this.f[param1] = this.h[param1];
         this.parent[param1] = -1;
         this.graph.setStartGridPos(param1);
         while(this.open.length > 0)
         {
            _loc7_ = Number.POSITIVE_INFINITY;
            _loc8_ = -1;
            _loc9_ = 0;
            while(_loc9_ < this.open.length)
            {
               _loc11_ = this.open[_loc9_];
               if(this.f[_loc11_] < _loc7_)
               {
                  _loc7_ = this.f[_loc11_];
                  _loc8_ = _loc11_;
               }
               _loc9_++;
            }
            if(_loc8_ == param2)
            {
               this.goalReached = true;
               return this.createPath(param2,param1);
            }
            this.open.splice(this.open.indexOf(_loc8_),1);
            this.closed.push(_loc8_);
            this.closedDict[_loc8_] = 1;
            for each(_loc10_ in this.graph.getNeighbors(_loc8_,_loc3_))
            {
               if(this.closedDict[_loc10_] != 1)
               {
                  _loc12_ = this.g[_loc8_] + this.graph.distance(_loc8_,_loc10_);
                  _loc13_ = false;
                  if(this.open.indexOf(_loc10_) == -1)
                  {
                     this.open.push(_loc10_);
                     _loc13_ = true;
                  }
                  else if(_loc12_ < this.g[_loc10_])
                  {
                     _loc13_ = true;
                  }
                  if(_loc13_)
                  {
                     this.parent[_loc10_] = _loc8_;
                     this.g[_loc10_] = _loc12_;
                     this.h[_loc10_] = this.graph.distance(_loc10_,param2);
                     this.f[_loc10_] = this.g[_loc10_] + this.h[_loc10_];
                  }
               }
            }
         }
         var _loc4_:Number = Number.POSITIVE_INFINITY;
         var _loc5_:int = -1;
         for each(_loc6_ in this.closed)
         {
            _loc14_ = this.h[_loc6_];
            if(_loc14_ < _loc4_)
            {
               _loc4_ = _loc14_;
               _loc5_ = _loc6_;
            }
         }
         return this.createPath(_loc5_,param1);
      }
      
      public function hasReachedGoal() : Boolean
      {
         return this.goalReached;
      }
      
      private function createPath(param1:int, param2:int) : Vector.<int>
      {
         var _loc3_:Vector.<int> = new Vector.<int>();
         while(this.parent[param1] != -1)
         {
            _loc3_.push(param1);
            param1 = this.parent[param1];
         }
         _loc3_.push(param2);
         return _loc3_.reverse();
      }
   }
}

