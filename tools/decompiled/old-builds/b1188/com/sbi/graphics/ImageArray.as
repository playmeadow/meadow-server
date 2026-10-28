package com.sbi.graphics
{
   import flash.display.BitmapData;
   import flash.utils.ByteArray;
   
   public class ImageArray
   {
      
      public static const VERSION:uint = 117967104;
      
      private var _frames:Array;
      
      public function ImageArray()
      {
         super();
         this._frames = new Array();
      }
      
      public function get length() : int
      {
         return this._frames.length;
      }
      
      public function release() : void
      {
         this._frames.splice(0,this._frames.length);
      }
      
      public function addBitmap(param1:BitmapData) : void
      {
         var _loc2_:Object = BitmapByteArray.scaleAndPackImage(param1);
         this._frames.push(_loc2_);
      }
      
      public function attachShadow(param1:BitmapData) : void
      {
         var _loc2_:Object = null;
         var _loc3_:Object = null;
         if(this._frames.length)
         {
            _loc2_ = this._frames[this._frames.length - 1];
            _loc3_ = BitmapByteArray.scaleAndPackShadow(param1,_loc2_.x,_loc2_.y,_loc2_.w,_loc2_.h);
            _loc2_.s = _loc3_.b;
            _loc2_.sm = _loc3_.sm;
         }
      }
      
      public function addFrame(param1:Object) : void
      {
         this._frames.push(param1);
      }
      
      public function loadPackage(param1:ByteArray) : void
      {
         this.release();
         param1.position = 0;
         try
         {
            param1.uncompress();
         }
         catch(err:Error)
         {
         }
         var _loc2_:Object = param1.readObject();
         if(_loc2_.v == ImageArray.VERSION)
         {
            this._frames = _loc2_.f;
            return;
         }
      }
      
      public function getFrame(param1:int) : Object
      {
         return this._frames[param1];
      }
      
      public function getPackage(param1:Boolean = true) : ByteArray
      {
         var _loc2_:int = 0;
         var _loc3_:ByteArray = null;
         var _loc4_:Object = null;
         if(this._frames.length)
         {
            _loc4_ = {
               "v":ImageArray.VERSION,
               "f":this._frames
            };
            _loc3_ = new ByteArray();
            _loc3_.writeObject(_loc4_);
            _loc3_.position = 0;
            if(param1)
            {
               _loc3_.compress();
            }
         }
         return _loc3_;
      }
   }
}

