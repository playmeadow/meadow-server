package com.sbi.graphics
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   
   public class LayerBitmap extends Bitmap
   {
      
      private const _backgroundColor:uint = 0;
      
      private var _anchorPoint:Point;
      
      private var _layers:Array;
      
      private var _bmin:Point;
      
      private var _bmax:Point;
      
      private var _lastFrame:int;
      
      private var _lastHFlip:Boolean;
      
      private var _blendColor:uint;
      
      private var _bColorChanged:Boolean;
      
      public function LayerBitmap()
      {
         super();
         this._layers = new Array();
         this._anchorPoint = new Point();
         this._bmin = new Point();
         this._bmax = new Point();
      }
      
      public function get length() : int
      {
         var o:Object = this._layers[0];
         if(!o)
         {
            o = this._layers[1];
         }
         if(!o)
         {
            return 0;
         }
         return o.o.f.length;
      }
      
      public function release() : void
      {
         this._layers.splice(0,this._layers.length);
         this._lastFrame = -1;
         this._bColorChanged = false;
      }
      
      public function invalidate() : void
      {
         this._lastFrame = -1;
      }
      
      public function setLayer(layer:int, o:Object, color:uint) : void
      {
         if(layer < 0 || layer > 10)
         {
            return;
         }
         if(Boolean(o))
         {
            if(this._layers[layer] == null)
            {
               this._layers[layer] = {
                  "c":-1,
                  "lastColor":-1,
                  "blendColor":0
               };
            }
            this._layers[layer].o = o;
         }
         else
         {
            this._layers[layer] = null;
         }
         this.setLayerColor(layer,color);
         this._lastFrame = -1;
      }
      
      public function setLayerColor(layer:int, c:uint) : void
      {
         var o:Object = this._layers[layer];
         if(Boolean(o) && c != o.c)
         {
            o.c = c;
            this._bColorChanged = true;
         }
      }
      
      public function setBlendColor(argb:uint) : void
      {
         if(this._blendColor != argb)
         {
            this._blendColor = argb;
            this._bColorChanged = true;
         }
      }
      
      public function get anchorPoint() : Point
      {
         return this._anchorPoint;
      }
      
      private function refreshLayerPalette(i:int) : void
      {
         var c:uint = 0;
         var gp:Array = null;
         var c1:int = 0;
         var c2:int = 0;
         var c3:int = 0;
         var c4:int = 0;
         var a:int = 0;
         var o:Object = this._layers[i];
         if(Boolean(o) && (o.lastColor != o.c || o.blendColor != this._blendColor))
         {
            c = uint(o.c);
            gp = PaletteHelper.gamePalette;
            c1 = c >> 24 & 0xFF;
            c2 = c >> 16 & 0xFF;
            c3 = c >> 8 & 0xFF;
            c4 = c & 0xFF;
            if(!o.pal)
            {
               o.pal = [];
            }
            PaletteHelper.BuildAnimalPalette(o.pal,gp[c1],gp[c2],gp[c3],gp[c4]);
            a = this._blendColor >> 24 & 0xFF;
            if(i != 3)
            {
               if(a > 0)
               {
                  PaletteHelper.adjustPaletteColor(o.pal,this._blendColor);
               }
               o.blendColor = this._blendColor;
            }
            o.lastColor = c;
            this._lastFrame = -1;
         }
      }
      
      private function refreshAllPalettes() : void
      {
         for(var i:int = 1; i <= 10; i++)
         {
            this.refreshLayerPalette(i);
         }
         this._bColorChanged = false;
      }
      
      private function calcBounds(index:int) : void
      {
         var obj:Object = null;
         var o:Object = null;
         var total:int = 0;
         var fo:Object = null;
         var xOff:int = 0;
         var yOff:int = 0;
         var w:int = 0;
         var h:int = 0;
         this._bmin.x = 1000;
         this._bmin.y = 1000;
         this._bmax.x = 0;
         this._bmax.y = 0;
         for(var i:int = 1; i < this._layers.length; i++)
         {
            obj = this._layers[i];
            if(obj != null)
            {
               o = obj.o;
               if(o.v != ImageArray.VERSION)
               {
                  return;
               }
               total = int(o.f.length);
               if(index < total)
               {
                  fo = o.f[index];
                  if(fo)
                  {
                     xOff = int(fo.x);
                     yOff = int(fo.y);
                     w = int(fo.w);
                     h = int(fo.h);
                     if(xOff < this._bmin.x)
                     {
                        this._bmin.x = xOff;
                     }
                     if(yOff < this._bmin.y)
                     {
                        this._bmin.y = yOff;
                     }
                     if(xOff + w > this._bmax.x)
                     {
                        this._bmax.x = xOff + w;
                     }
                     if(yOff + h > this._bmax.y)
                     {
                        this._bmax.y = yOff + h;
                     }
                  }
               }
            }
         }
         if(this._bmin.x == 1000 || this._bmin.y == 1000)
         {
            if(Boolean(this.bitmapData))
            {
               trace("WARNING: making new empty 1x1 bitmap data (parent.name:" + parent.name + ") - is index:" + index + " valid?");
               this.bitmapData = new BitmapData(1,1,true,this._backgroundColor);
            }
            return;
         }
         this.resizeBitmap(1 + this._bmax.x - this._bmin.x,1 + this._bmax.y - this._bmin.y,true);
         this._anchorPoint.x = this._bmin.x;
         this._anchorPoint.y = this._bmin.y;
      }
      
      public function paint(index:int, bHFlip:Boolean = false, bUseSeq:Boolean = true) : Boolean
      {
         var o:Object = null;
         var bRet:Boolean = false;
         var i:int = 0;
         if(bUseSeq && this._layers[0] != null)
         {
            o = this._layers[0];
            index = int(o.o.f[index]);
         }
         if(index != this._lastFrame || bHFlip != this._lastHFlip || this._bColorChanged)
         {
            if(this._bColorChanged)
            {
               this.refreshAllPalettes();
            }
            this._lastFrame = index;
            this._lastHFlip = bHFlip;
            this.calcBounds(index);
            for(i = 1; i < this._layers.length; i++)
            {
               o = this._layers[i];
               if(o != null)
               {
                  this.paintFrame(o.o,index,o.pal,bHFlip);
               }
            }
            bRet = true;
            if(bHFlip)
            {
               this._anchorPoint.x = 500 - this._bmax.x;
            }
         }
         return bRet;
      }
      
      private function paintFrame(top:Object, index:int, palette:Array, bHFlip:Boolean) : void
      {
         var p:int = 0;
         var count:int = 0;
         var c:uint = 0;
         var d:uint = 0;
         var a1:int = 0;
         var r1:int = 0;
         var g1:int = 0;
         var b1:int = 0;
         var a2:int = 0;
         var r2:int = 0;
         var g2:int = 0;
         var b2:int = 0;
         var wOff:int = 0;
         var scr:Number = NaN;
         var c1:uint = 0;
         var shadowMultiplyer:int = 0;
         if(index >= top.f.length)
         {
            return;
         }
         var o:Object = top.f[index];
         if(!o)
         {
            return;
         }
         var bm:BitmapData = this.bitmapData;
         var pack:ByteArray = o.b;
         var xOff:int = int(o.x);
         var yOff:int = int(o.y);
         var w:int = int(o.w);
         var h:int = int(o.h);
         xOff -= this._bmin.x;
         yOff -= this._bmin.y;
         w += xOff;
         pack.position = 0;
         var max:int = int(pack.length);
         var x:int = xOff;
         var y:int = yOff;
         this.bitmapData.lock();
         var ow:int = w - xOff;
         if(!bHFlip)
         {
            while(pack.position < max)
            {
               p = int(pack.readUnsignedByte());
               count = 1;
               if((p & 0x80) == 128)
               {
                  p &= 127;
                  count = pack.readUnsignedByte() + 1;
               }
               if(p == 0)
               {
                  x += count;
                  if(x >= w)
                  {
                     count = x - w;
                     x = xOff + count % ow;
                     y += count / ow + 1;
                  }
               }
               else
               {
                  c = uint(palette[p]);
                  if(c >= 4278190080)
                  {
                     if(x + count < w)
                     {
                        while(--count > -1)
                        {
                           bm.setPixel32(x++,y,c);
                        }
                     }
                     else
                     {
                        while(--count > -1)
                        {
                           bm.setPixel32(x++,y,c);
                           if(x == w)
                           {
                              x = xOff;
                              y++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(--count > -1)
                     {
                        d = bm.getPixel32(x,y);
                        if(d != this._backgroundColor)
                        {
                           a1 = c >> 24 & 0xFF;
                           r1 = c >> 16 & 0xFF;
                           g1 = c >> 8 & 0xFF;
                           b1 = c & 0xFF;
                           a2 = d >> 24 & 0xFF;
                           r2 = d >> 16 & 0xFF;
                           g2 = d >> 8 & 0xFF;
                           b2 = d & 0xFF;
                           if(a1 == 192)
                           {
                              r1 = (r1 + r1 + r1 + r2) * 0.25;
                              g1 = (g1 + g1 + g1 + g2) * 0.25;
                              b1 = (b1 + b1 + b1 + b2) * 0.25;
                           }
                           else if(a1 == 128)
                           {
                              r1 = (r1 + r2) * 0.5;
                              g1 = (g1 + g2) * 0.5;
                              b1 = (b1 + b2) * 0.5;
                           }
                           else
                           {
                              r1 = (r1 + r2 + r2 + r2) * 0.25;
                              g1 = (g1 + g2 + g2 + g2) * 0.25;
                              b1 = (b1 + b2 + b2 + b2) * 0.25;
                           }
                           if(a2 > a1)
                           {
                              a1 = a2;
                           }
                           c = uint(a1 << 24 | r1 << 16 | g1 << 8 | b1);
                        }
                        bm.setPixel32(x++,y,c);
                        if(x == w)
                        {
                           x = xOff;
                           y++;
                        }
                     }
                  }
               }
            }
         }
         else
         {
            wOff = this._bmax.x - this._bmin.x;
            while(pack.position < max)
            {
               p = int(pack.readUnsignedByte());
               count = 1;
               if((p & 0x80) == 128)
               {
                  p &= 127;
                  count = pack.readUnsignedByte() + 1;
               }
               if(p == 0)
               {
                  x += count;
                  if(x >= w)
                  {
                     count = x - w;
                     x = xOff + count % ow;
                     y += count / ow + 1;
                  }
               }
               else
               {
                  c = uint(palette[p]);
                  if(c >= 4278190080)
                  {
                     if(x + count < w)
                     {
                        while(--count > -1)
                        {
                           bm.setPixel32(wOff - x++,y,c);
                        }
                     }
                     else
                     {
                        while(--count > -1)
                        {
                           bm.setPixel32(wOff - x++,y,c);
                           if(x == w)
                           {
                              x = xOff;
                              y++;
                           }
                        }
                     }
                  }
                  else
                  {
                     while(--count > -1)
                     {
                        d = bm.getPixel32(wOff - x,y);
                        if(d != this._backgroundColor)
                        {
                           a1 = c >> 24 & 0xFF;
                           r1 = c >> 16 & 0xFF;
                           g1 = c >> 8 & 0xFF;
                           b1 = c & 0xFF;
                           a2 = d >> 24 & 0xFF;
                           r2 = d >> 16 & 0xFF;
                           g2 = d >> 8 & 0xFF;
                           b2 = d & 0xFF;
                           switch(a1)
                           {
                              case 192:
                                 r1 = (r1 + r1 + r1 + r2) * 0.25;
                                 g1 = (g1 + g1 + g1 + g2) * 0.25;
                                 b1 = (b1 + b1 + b1 + b2) * 0.25;
                                 break;
                              case 128:
                                 r1 = (r1 + r2) * 0.5;
                                 g1 = (g1 + g2) * 0.5;
                                 b1 = (b1 + b2) * 0.5;
                                 break;
                              case 64:
                                 r1 = (r1 + r2 + r2 + r2) * 0.25;
                                 g1 = (g1 + g2 + g2 + g2) * 0.25;
                                 b1 = (b1 + b2 + b2 + b2) * 0.25;
                           }
                           if(a2 > a1)
                           {
                              a1 = a2;
                           }
                           c = uint(a1 << 24 | r1 << 16 | g1 << 8 | b1);
                        }
                        bm.setPixel32(wOff - x++,y,c);
                        if(x == w)
                        {
                           x = xOff;
                           y++;
                        }
                     }
                  }
               }
            }
         }
         if(o.hasOwnProperty("s"))
         {
            shadowMultiplyer = int(o.sm);
            pack = o.s;
            max = int(pack.length);
            pack.position = 0;
            x = xOff;
            y = yOff;
            if(!bHFlip)
            {
               while(pack.position < max)
               {
                  p = int(pack.readUnsignedByte());
                  count = 1;
                  if((p & 0x80) == 128)
                  {
                     p &= 127;
                     count = pack.readUnsignedByte() + 1;
                  }
                  if(p == 0)
                  {
                     x += count;
                     if(x >= w)
                     {
                        count = x - w;
                        x = xOff + count % ow;
                        y += count / ow + 1;
                     }
                  }
                  else
                  {
                     c = uint(p << shadowMultiplyer);
                     c += 24;
                     if(c > 255)
                     {
                        scr = 1;
                     }
                     else
                     {
                        scr = c / 255;
                     }
                     while(--count > -1)
                     {
                        d = bm.getPixel32(x,y);
                        if(d != this._backgroundColor)
                        {
                           a1 = d >> 24 & 0xFF;
                           r1 = (d >> 16 & 0xFF) * scr;
                           g1 = (d >> 8 & 0xFF) * scr;
                           b1 = (d & 0xFF) * scr;
                           c1 = uint(a1 << 24 | r1 << 16 | g1 << 8 | b1);
                           bm.setPixel32(x,y,c1);
                        }
                        if(++x == w)
                        {
                           x = xOff;
                           y++;
                        }
                     }
                  }
               }
            }
            else
            {
               wOff = this._bmax.x - this._bmin.x;
               while(pack.position < max)
               {
                  p = int(pack.readUnsignedByte());
                  count = 1;
                  if((p & 0x80) == 128)
                  {
                     p &= 127;
                     count = pack.readUnsignedByte() + 1;
                  }
                  if(p == 0)
                  {
                     x += count;
                     if(x >= w)
                     {
                        count = x - w;
                        x = xOff + count % ow;
                        y += count / ow + 1;
                     }
                  }
                  else
                  {
                     c = uint(p << shadowMultiplyer);
                     c += 24;
                     if(c > 255)
                     {
                        scr = 1;
                     }
                     else
                     {
                        scr = c / 255;
                     }
                     while(--count > -1)
                     {
                        d = bm.getPixel32(wOff - x,y);
                        if(d != this._backgroundColor)
                        {
                           a1 = d >> 24 & 0xFF;
                           r1 = (d >> 16 & 0xFF) * scr;
                           g1 = (d >> 8 & 0xFF) * scr;
                           b1 = (d & 0xFF) * scr;
                           c1 = uint(a1 << 24 | r1 << 16 | g1 << 8 | b1);
                           bm.setPixel32(wOff - x,y,c1);
                        }
                        if(++x == w)
                        {
                           x = xOff;
                           y++;
                        }
                     }
                  }
               }
            }
         }
         bm.unlock();
      }
      
      private function resizeBitmap(w:int, h:int, bClearBitmap:Boolean) : void
      {
         var iw:int = w;
         var ih:int = h;
         if(!this.bitmapData)
         {
            bClearBitmap = true;
         }
         var rect:Rectangle = new Rectangle(0,0,iw,ih);
         var ba:ByteArray = null;
         if(!bClearBitmap)
         {
            ba = this.bitmapData.getPixels(rect);
         }
         if(Boolean(this.bitmapData))
         {
            this.bitmapData.dispose();
         }
         this.bitmapData = new BitmapData(w,h,true,this._backgroundColor);
         if(!bClearBitmap)
         {
            this.bitmapData.setPixels(rect,ba);
         }
      }
   }
}

