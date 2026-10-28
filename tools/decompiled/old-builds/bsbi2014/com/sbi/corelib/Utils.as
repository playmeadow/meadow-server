package com.sbi.corelib
{
   import com.sbi.debug.DebugUtility;
   import flash.utils.getDefinitionByName;
   
   public class Utils
   {
      
      public function Utils()
      {
         super();
      }
      
      public static function getDefByName(getClassName:String) : Class
      {
         var returnClass:Class = null;
         try
         {
            returnClass = getDefinitionByName(getClassName) as Class;
         }
         catch(re:ReferenceError)
         {
            DebugUtility.debugTrace("WARNING: Missing class definition \"" + getClassName + "\"!");
            returnClass = null;
         }
         return returnClass;
      }
      
      public static function damerauLevenshteinDistance(a:Array, b:Array, C:int) : int
      {
         var DB:int = 0;
         var j:int = 0;
         var i1:int = 0;
         var j1:int = 0;
         var d:int = 0;
         var INF:int = a.length + b.length;
         var H:SimpleMatrix = new SimpleMatrix(a.length + 2,b.length + 2);
         H[0][0] = INF;
         for(var hi:int = 0; hi <= a.length; hi++)
         {
            H[hi + 1][1] = hi;
            H[hi + 1][0] = INF;
         }
         for(var hj:int = 0; hj <= b.length; hj++)
         {
            H[1][hj + 1] = hj;
            H[0][hj + 1] = INF;
         }
         var DA:Array = new Array(C);
         for(var dad:int = 0; dad < C; dad++)
         {
            DA[dad] = 0;
         }
         for(var i:int = 1; i <= a.length; i++)
         {
            DB = 0;
            for(j = 1; j <= b.length; j++)
            {
               i1 = int(DA[b[j - 1]]);
               j1 = DB;
               d = a[i - 1] == b[j - 1] ? 0 : 1;
               if(d == 0)
               {
                  DB = j;
               }
               H[i + 1][j + 1] = Math.min(H[i][j] + d,H[i + 1][j] + 1,H[i][j + 1] + 1,H[i1][j1] + (i - i1 - 1) + 1 + (j - j1 - 1));
            }
            DA[a[i - 1]] = i;
         }
         return H[a.length + 1][b.length + 1];
      }
   }
}

dynamic class SimpleMatrix extends Array
{
   
   public var rows:int;
   
   public var cols:int;
   
   public function SimpleMatrix(nrows:int = 0, ncols:int = -1)
   {
      super(nrows);
      if(ncols == -1)
      {
         ncols = nrows;
      }
      for(var i:int = 0; i < nrows; i++)
      {
         this[i] = new Array(ncols);
      }
      this.rows = nrows;
      this.cols = ncols;
   }
}
