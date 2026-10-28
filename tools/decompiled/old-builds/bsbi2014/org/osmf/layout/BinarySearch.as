package org.osmf.layout
{
   import org.osmf.utils.OSMFStrings;
   
   [ExcludeClass]
   internal class BinarySearch
   {
      
      public function BinarySearch()
      {
         super();
      }
      
      public static function search(list:Object, compare:Function, item:*, firstIndex:int = 0, lastIndex:int = -2147483648) : int
      {
         var middle:int = 0;
         var listItem:* = undefined;
         if(list == null || compare == null)
         {
            throw new ArgumentError(OSMFStrings.getString(OSMFStrings.NULL_PARAM));
         }
         var result:int = -firstIndex;
         lastIndex = lastIndex == int.MIN_VALUE ? int(list.length - 1) : lastIndex;
         if(list.length > 0 && firstIndex <= lastIndex)
         {
            middle = (firstIndex + lastIndex) / 2;
            listItem = list[middle];
            switch(compare(item,listItem))
            {
               case -1:
                  result = search(list,compare,item,firstIndex,middle - 1);
                  break;
               case 0:
                  result = middle;
                  break;
               case 1:
                  result = search(list,compare,item,middle + 1,lastIndex);
            }
         }
         return result;
      }
   }
}

