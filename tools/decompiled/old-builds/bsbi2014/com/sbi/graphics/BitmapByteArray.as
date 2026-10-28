package com.sbi.graphics
{
   import flash.display.BitmapData;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class BitmapByteArray
   {
      
      private static const PALETTE_ALPHA_OFFSET:int = 25;
      
      private static const SHADOW_GRADIENT_SCALE:int = 3;
      
      private const TRANS:int = 0;
      
      private var _palette:Array;
      
      private var _h:int;
      
      private var _w:int;
      
      private var _offX:int;
      
      private var _offY:int;
      
      private var _ba:Vector.<int>;
      
      public function BitmapByteArray()
      {
         super();
         this._palette = PaletteHelper.getAnimalPalette();
      }
      
      public static function scaleAndPackImage(bm:BitmapData) : Object
      {
         var bmba:BitmapByteArray = new BitmapByteArray();
         bmba.loadBitmap(bm);
         bmba.halfImage();
         bmba.crop();
         return bmba.processPackImage();
      }
      
      public static function scaleAndPackShadow(bm:BitmapData, xOff:int, yOff:int, cropW:int, cropH:int) : Object
      {
         var bmba:BitmapByteArray = new BitmapByteArray();
         return bmba.scaleShadow(bm,xOff,yOff,cropW,cropH);
      }
      
      private function loadBitmap(bmd:BitmapData) : void
      {
         var x:uint = 0;
         var y:uint = 0;
         var color:uint = 0;
         this._w = bmd.width;
         this._h = bmd.height;
         this._ba = new Vector.<int>(this._w * this._h,true);
         var lastColor:uint = 0;
         var lastIndex:int = -1;
         var i:int = 0;
         for(y = 0; y < this._h; y++)
         {
            for(x = 0; x < this._w; x++)
            {
               color = bmd.getPixel32(x,y);
               if(lastColor != color || lastIndex < 0)
               {
                  lastColor = color;
                  lastIndex = int(this.findPaletteColor(color));
               }
               this._ba[i++] = lastIndex;
            }
         }
      }
      
      private function scaleShadow(bm:BitmapData, xOff:int, yOff:int, cropW:int, cropH:int) : Object
      {
         var c1:uint = 0;
         var c2:uint = 0;
         var c3:uint = 0;
         var c4:uint = 0;
         var x:int = 0;
         var pos:int = 0;
         this._w = bm.width;
         this._h = bm.height;
         var pixels:Vector.<uint> = bm.getVector(new Rectangle(0,0,this._w,this._h));
         var newBa:Vector.<int> = new Vector.<int>(this._w * this._h * 0.25,true);
         var p:int = 0;
         var i:int = 0;
         for(var y:int = 0; y < this._h; y += 2)
         {
            for(x = 0; x < this._w; x += 2)
            {
               p = x + y * this._w;
               c1 = pixels[p];
               c2 = pixels[p + 1];
               p += this._w;
               c3 = pixels[p];
               c4 = pixels[p + 1];
               newBa[i++] = this.blendShadowColors(c1,c2,c3,c4);
            }
         }
         this._ba = newBa;
         this._h /= 2;
         this._w /= 2;
         if(cropW != this._w || cropH != this._h)
         {
            i = 0;
            newBa = new Vector.<int>(cropW * cropH,true);
            for(y = yOff; y < yOff + cropH; y++)
            {
               pos = y * this._w + xOff;
               for(x = 0; x < cropW; x++)
               {
                  p = this._ba[pos++];
                  newBa[i++] = p;
               }
            }
            this._w = cropW;
            this._h = cropH;
            this._offX = xOff;
            this._offY = yOff;
            this._ba = newBa;
         }
         var ret:Object = this.processPackImage();
         ret.sm = SHADOW_GRADIENT_SCALE;
         return ret;
      }
      
      private function halfImage() : void
      {
         var c1:int = 0;
         var c2:int = 0;
         var c3:int = 0;
         var c4:int = 0;
         var x:int = 0;
         var newBa:Vector.<int> = new Vector.<int>(this._w * this._h * 0.25,true);
         var p:int = 0;
         var i:int = 0;
         for(var y:int = 0; y < this._h; y += 2)
         {
            for(x = 0; x < this._w; x += 2)
            {
               p = x + y * this._w;
               c1 = this._ba[p];
               c2 = this._ba[p + 1];
               p += this._w;
               c3 = this._ba[p];
               c4 = this._ba[p + 1];
               newBa[i++] = this.blendColors(c1,c2,c3,c4);
            }
         }
         this._ba = newBa;
         this._h /= 2;
         this._w /= 2;
      }
      
      private function crop() : void
      {
         var p:uint = 0;
         var x:int = 0;
         var y:int = 0;
         var newBA:Vector.<int> = null;
         var pos:int = 0;
         var xmin:int = this._w;
         var xmax:int = 0;
         var ymin:int = this._h;
         var ymax:int = 0;
         var i:int = 0;
         for(y = 0; y < this._h; y++)
         {
            for(x = 0; x < this._w; x++)
            {
               p = uint(this._ba[i++]);
               if(p > 0)
               {
                  if(x < xmin)
                  {
                     xmin = x;
                  }
                  if(x > xmax)
                  {
                     xmax = x;
                  }
                  if(y < ymin)
                  {
                     ymin = y;
                  }
                  if(y > ymax)
                  {
                     ymax = y;
                  }
               }
            }
         }
         this._offX = xmin;
         this._offY = ymin;
         var w:uint = xmax - xmin + 1;
         var h:uint = ymax - ymin + 1;
         if(xmin == this._w && ymin == this._h)
         {
            this._w = 0;
            this._h = 0;
            this._ba = null;
            return;
         }
         i = 0;
         if(w != this._w || h != this._h)
         {
            newBA = new Vector.<int>(w * h,true);
            for(y = ymin; y < ymin + h; y++)
            {
               pos = y * this._w + this._offX;
               for(x = 0; x < w; x++)
               {
                  p = uint(this._ba[pos++]);
                  newBA[i++] = p;
               }
            }
            this._w = w;
            this._h = h;
            this._ba = newBA;
         }
      }
      
      private function processPackImage() : Object
      {
         var x:int = 0;
         var y:int = 0;
         var line:String = null;
         var c:uint = 0;
         if(this._ba == null)
         {
            return null;
         }
         var o:Object = {
            "x":this._offX,
            "y":this._offY,
            "w":this._w,
            "h":this._h
         };
         var pack:ByteArray = new ByteArray();
         o.b = pack;
         var len:int = int(this._ba.length);
         var lastColor:uint = 256;
         var sameCount:uint = 0;
         var p:int = 0;
         while(p < len)
         {
            c = uint(this._ba[p++]);
            if(lastColor == 256)
            {
               lastColor = c;
            }
            else if(c != lastColor)
            {
               if(Boolean(sameCount))
               {
                  lastColor |= 128;
                  while(sameCount > 255)
                  {
                     pack.writeByte(lastColor);
                     pack.writeByte(uint(255));
                     sameCount -= 256;
                  }
                  if(sameCount > 0)
                  {
                     pack.writeByte(lastColor);
                     pack.writeByte(sameCount);
                  }
                  else
                  {
                     pack.writeByte(uint(lastColor & 0x7F));
                  }
               }
               else
               {
                  pack.writeByte(lastColor);
               }
               lastColor = c;
               sameCount = 0;
            }
            else
            {
               sameCount++;
            }
         }
         if(Boolean(sameCount) || len == 1)
         {
            lastColor |= 128;
            while(sameCount > 255)
            {
               pack.writeByte(lastColor);
               pack.writeByte(uint(255));
               sameCount -= 256;
            }
            if(sameCount > 0)
            {
               pack.writeByte(lastColor);
               pack.writeByte(sameCount);
            }
            else
            {
               pack.writeByte(uint(lastColor & 0x7F));
            }
         }
         return o;
      }
      
      private function findPaletteColor(color:uint) : uint
      {
         var alpha:uint = uint((color & 0xFF000000) >> 24);
         if(alpha < 160)
         {
            return this.TRANS;
         }
         color |= 4278190080;
         for(var i:uint = 0; i < PALETTE_ALPHA_OFFSET; i++)
         {
            if(this._palette[i] == color)
            {
               return i;
            }
         }
         var cr:int = color >> 16 & 0xFF;
         var cg:int = color >> 8 & 0xFF;
         var cb:int = color & 0xFF;
         return this.findClosetPaletteIndex(cr,cg,cb);
      }
      
      private function findClosetPaletteIndex(cr:int, cg:int, cb:int) : int
      {
         var a:int = 0;
         var r:int = 0;
         var g:int = 0;
         var b:int = 0;
         var distance:int = 0;
         var pc:uint = 0;
         var smallest:int = 10000000;
         var smallestIndex:int = 0;
         for(var j:uint = 0; j < PALETTE_ALPHA_OFFSET; j++)
         {
            pc = uint(this._palette[j]);
            r = (pc >> 16 & 0xFF) - cr;
            g = (pc >> 8 & 0xFF) - cg;
            b = (pc & 0xFF) - cb;
            distance = r * r + g * g + b * b;
            if(distance < smallest)
            {
               smallest = distance;
               smallestIndex = int(j);
            }
         }
         return smallestIndex;
      }
      
      private function blendColors(c:uint, c1:uint, c2:uint, c3:uint) : uint
      {
         var newColor:uint = 0;
         var transCount:int = 0;
         var a:Array = null;
         var total:int = 0;
         var cr:int = 0;
         var cg:int = 0;
         var cb:int = 0;
         var i:int = 0;
         if(c == this.TRANS)
         {
            transCount++;
         }
         if(c1 == this.TRANS)
         {
            transCount++;
         }
         if(c2 == this.TRANS)
         {
            transCount++;
         }
         if(c3 == this.TRANS)
         {
            transCount++;
         }
         if(transCount == 4)
         {
            return 0;
         }
         if(c == c1 && c == c2 && c == c3)
         {
            newColor = c;
         }
         else
         {
            for(a = [c,c1,c2,c3]; i < 4; )
            {
               if(a[i] != this.TRANS)
               {
                  c = uint(this._palette[a[i]]);
                  cr += c >> 16 & 0xFF;
                  cg += c >> 8 & 0xFF;
                  cb += c & 0xFF;
                  total++;
               }
               i++;
            }
            cr /= total;
            cg /= total;
            cb /= total;
            newColor = uint(this.findClosetPaletteIndex(cr,cg,cb));
         }
         return uint(newColor + transCount * PALETTE_ALPHA_OFFSET);
      }
      
      private function blendShadowColors(c1:uint, c2:uint, c3:uint, c4:uint) : int
      {
         var a:uint = ((c1 >> 24 & 0xFF) + (c2 >> 24 & 0xFF) + (c3 >> 24 & 0xFF) + (c4 >> 24 & 0xFF)) / 4;
         var c:uint = ((c1 & 0xFF & 0xFF) + (c2 & 0xFF & 0xFF) + (c3 & 0xFF & 0xFF) + (c4 & 0xFF & 0xFF)) / 4;
         if(Boolean(a))
         {
            c += (255 - c) * ((255 - a) / 255);
            c >>= BitmapByteArray.SHADOW_GRADIENT_SCALE;
            if(c == 0)
            {
               c = 1;
            }
         }
         else
         {
            c = 0;
         }
         return c;
      }
   }
}

