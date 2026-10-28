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
      
      override public function addChild(child:DisplayObject) : DisplayObject
      {
         var offset:int = int(child.name);
         child.name = (this.getNudge() + offset).toString();
         return super.addChild(child);
      }
      
      override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         var offset:int = int(child.name);
         child.name = (this.getNudge() + offset).toString();
         return super.addChildAt(child,index);
      }
      
      public function release() : void
      {
         this._nudge = 0;
         this._bottoms = new Dictionary(true);
      }
      
      public function depthSort(a:DisplayObject, b:DisplayObject) : int
      {
         return this._bottoms[a] - this._bottoms[b];
      }
      
      public function heartbeat() : void
      {
         var i:int = 0;
         var r:Rectangle = null;
         var bSort:Boolean = false;
         var d:DisplayObject = null;
         var y:Number = NaN;
         var offset:Number = NaN;
         var t:int = this.numChildren;
         var prev:Number = -999999999;
         if(t < 2)
         {
            return;
         }
         var sortArray:Array = [t];
         for(i = 0; i < t; i++)
         {
            d = this.getChildAt(i);
            sortArray[i] = d;
            r = d.getBounds(this);
            y = r.bottom;
            offset = Number(d.name);
            if(!offset)
            {
               offset = this.getNudge();
               d.name = offset.toString();
            }
            y -= offset;
            this._bottoms[d] = y;
            if(!bSort)
            {
               if(y < prev)
               {
                  bSort = true;
               }
               prev = y;
            }
         }
         if(bSort)
         {
            sortArray.sort(this.depthSort);
            for(i = 0; i < t; i++)
            {
               this.setChildIndex(sortArray[i],i);
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
      
      private function sort(a:Vector.<Number>) : void
      {
         this.quickSort(a,0,a.length - 1);
         this.InsertionSort(a,0,a.length - 1);
      }
      
      private function quickSort(a:Vector.<Number>, l:int, r:int) : void
      {
         var i:int = 0;
         var j:int = 0;
         var v:Number = NaN;
         var M:int = 4;
         if(r - l > M)
         {
            i = (r + l) / 2;
            if(a[l] > a[i])
            {
               this.swap(a,l,i);
            }
            if(a[l] > a[r])
            {
               this.swap(a,l,r);
            }
            if(a[i] > a[r])
            {
               this.swap(a,i,r);
            }
            j = r - 1;
            this.swap(a,i,j);
            i = l;
            v = a[j];
            while(true)
            {
               while(a[++i] < v)
               {
               }
               while(a[--j] > v)
               {
               }
               if(j < i)
               {
                  break;
               }
               this.swap(a,i,j);
            }
            this.swap(a,i,r - 1);
            this.quickSort(a,l,j);
            this.quickSort(a,i + 1,r);
         }
      }
      
      private function swap(a:Vector.<Number>, i:int, j:int) : void
      {
         var T:Number = NaN;
         T = a[i];
         a[i] = a[j];
         a[j] = T;
         swapChildrenAt(i,j);
      }
      
      private function move(a:Vector.<Number>, i:int, j:int) : void
      {
         a[j] = a[i];
         this.addChildAt(getChildAt(i),j);
      }
      
      private function InsertionSort(a:Vector.<Number>, lo0:int, hi0:int) : void
      {
         var i:int = 0;
         var j:int = 0;
         var v:Number = NaN;
         for(i = lo0 + 1; i <= hi0; i++)
         {
            v = a[i];
            j = i;
            while(j > lo0 && a[j - 1] > v)
            {
               this.move(a,j - 1,j);
               j--;
            }
         }
      }
   }
}

