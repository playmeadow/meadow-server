package com.sbi.graphics
{
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   public class SortLayer extends Sprite
   {
      
      private var _bottoms:Dictionary;
      
      private var _nudge:Number = 0;
      
      public function SortLayer()
      {
         super();
         this._bottoms = new Dictionary(true);
      }
      
      override public function addChild(param1:DisplayObject) : DisplayObject
      {
         var _loc2_:int = int(param1.name);
         param1.name = (this.getNudge() + _loc2_).toString();
         return super.addChild(param1);
      }
      
      override public function addChildAt(param1:DisplayObject, param2:int) : DisplayObject
      {
         var _loc3_:int = int(param1.name);
         param1.name = (this.getNudge() + _loc3_).toString();
         return super.addChildAt(param1,param2);
      }
      
      public function release() : void
      {
         this._nudge = 0;
         this._bottoms = new Dictionary(true);
      }
      
      public function depthSort(param1:DisplayObject, param2:DisplayObject) : int
      {
         return this._bottoms[param1] - this._bottoms[param2];
      }
      
      public function heartbeat() : void
      {
         var _loc1_:int = 0;
         var _loc3_:Rectangle = null;
         var _loc4_:Boolean = false;
         var _loc7_:DisplayObject = null;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc2_:int = this.numChildren;
         var _loc5_:Number = -999999999;
         if(_loc2_ < 2)
         {
            return;
         }
         var _loc6_:Array = [_loc2_];
         _loc1_ = 0;
         while(_loc1_ < _loc2_)
         {
            _loc7_ = this.getChildAt(_loc1_);
            _loc6_[_loc1_] = _loc7_;
            _loc3_ = _loc7_.getBounds(this);
            _loc8_ = _loc3_.bottom;
            _loc9_ = Number(_loc7_.name);
            if(!_loc9_)
            {
               _loc9_ = this.getNudge();
               _loc7_.name = _loc9_.toString();
            }
            _loc8_ -= _loc9_;
            this._bottoms[_loc7_] = _loc8_;
            if(!_loc4_)
            {
               if(_loc8_ < _loc5_)
               {
                  _loc4_ = true;
               }
               _loc5_ = _loc8_;
            }
            _loc1_++;
         }
         if(_loc4_)
         {
            _loc6_.sort(this.depthSort);
            _loc1_ = 0;
            while(_loc1_ < _loc2_)
            {
               this.setChildIndex(_loc6_[_loc1_],_loc1_);
               _loc1_++;
            }
         }
      }
      
      private function getNudge() : Number
      {
         this._nudge += 0.001;
         if(this._nudge > 0.9)
         {
            this._nudge = 0;
         }
         return this._nudge;
      }
      
      private function sort(param1:Vector.<Number>) : void
      {
         this.quickSort(param1,0,param1.length - 1);
         this.InsertionSort(param1,0,param1.length - 1);
      }
      
      private function quickSort(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Number = NaN;
         var _loc4_:int = 4;
         if(param3 - param2 > _loc4_)
         {
            _loc5_ = (param3 + param2) / 2;
            if(param1[param2] > param1[_loc5_])
            {
               this.swap(param1,param2,_loc5_);
            }
            if(param1[param2] > param1[param3])
            {
               this.swap(param1,param2,param3);
            }
            if(param1[_loc5_] > param1[param3])
            {
               this.swap(param1,_loc5_,param3);
            }
            _loc6_ = param3 - 1;
            this.swap(param1,_loc5_,_loc6_);
            _loc5_ = param2;
            _loc7_ = param1[_loc6_];
            while(true)
            {
               while(param1[++_loc5_] < _loc7_)
               {
               }
               while(param1[--_loc6_] > _loc7_)
               {
               }
               if(_loc6_ < _loc5_)
               {
                  break;
               }
               this.swap(param1,_loc5_,_loc6_);
            }
            this.swap(param1,_loc5_,param3 - 1);
            this.quickSort(param1,param2,_loc6_);
            this.quickSort(param1,_loc5_ + 1,param3);
         }
      }
      
      private function swap(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         var _loc4_:Number = NaN;
         _loc4_ = param1[param2];
         param1[param2] = param1[param3];
         param1[param3] = _loc4_;
         swapChildrenAt(param2,param3);
      }
      
      private function move(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         param1[param3] = param1[param2];
         this.addChildAt(getChildAt(param2),param3);
      }
      
      private function InsertionSort(param1:Vector.<Number>, param2:int, param3:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = 0;
         var _loc6_:Number = NaN;
         _loc4_ = param2 + 1;
         while(_loc4_ <= param3)
         {
            _loc6_ = param1[_loc4_];
            _loc5_ = _loc4_;
            while(_loc5_ > param2 && param1[_loc5_ - 1] > _loc6_)
            {
               this.move(param1,_loc5_ - 1,_loc5_);
               _loc5_--;
            }
            _loc4_++;
         }
      }
   }
}

