package com.sbi.graphics
{
   public class ImageArrayHelper
   {
      
      public function ImageArrayHelper()
      {
         super();
      }
      
      public static function packId(aId:int, cId:int, lId:int) : uint
      {
         return aId << 24 | cId << 16 | lId;
      }
      
      public static function avatarId(id:uint) : int
      {
         return id >> 24 & 0xFF;
      }
      
      public static function categoryId(id:uint) : int
      {
         return id >> 16 & 0xFF;
      }
      
      public static function layerId(id:uint) : int
      {
         return id & 0xFFFF;
      }
   }
}

