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
      
      public function addBitmap(bm:BitmapData) : void
      {
         var o:Object = BitmapByteArray.scaleAndPackImage(bm);
         this._frames.push(o);
      }
      
      public function attachShadow(bm:BitmapData) : void
      {
         var current:Object = null;
         var o:Object = null;
         if(Boolean(this._frames.length))
         {
            current = this._frames[this._frames.length - 1];
            o = BitmapByteArray.scaleAndPackShadow(bm,current.x,current.y,current.w,current.h);
            current.s = o.b;
            current.sm = o.sm;
         }
      }
      
      public function addFrame(o:Object) : void
      {
         this._frames.push(o);
      }
      
      public function loadPackage(pack:ByteArray) : void
      {
         this.release();
         pack.position = 0;
         try
         {
            pack.uncompress();
         }
         catch(err:Error)
         {
         }
         var o:Object = pack.readObject();
         if(o.v == ImageArray.VERSION)
         {
            this._frames = o.f;
            return;
         }
      }
      
      public function getFrame(i:int) : Object
      {
         return this._frames[i];
      }
      
      public function getPackage(bCompress:Boolean = true) : ByteArray
      {
         var i:int = 0;
         var ba:ByteArray = null;
         var top:Object = null;
         if(Boolean(this._frames.length))
         {
            top = {
               "v":ImageArray.VERSION,
               "f":this._frames
            };
            ba = new ByteArray();
            ba.writeObject(top);
            ba.position = 0;
            if(bCompress)
            {
               ba.compress();
            }
         }
         return ba;
      }
   }
}

