package com.sbi.graphics
{
   import flash.utils.ByteArray;
   
   public class PaletteHelper
   {
      
      public static var gamePalette:Array;
      
      public static var avatarPalette1:Array;
      
      public static var avatarPalette2:Array;
      
      private static const PALETTE_ALPHA_OFFSET:int = 25;
      
      public function PaletteHelper()
      {
         super();
      }
      
      public static function setGamePalette(baPal:ByteArray, baAvatarPal1:ByteArray = null, baAvatarPal2:ByteArray = null) : void
      {
         var count:int = baPal.length / 4;
         gamePalette = new Array(count);
         var i:int = 0;
         while(i < count)
         {
            gamePalette[i++] = baPal.readUnsignedInt();
         }
         if(Boolean(baAvatarPal1))
         {
            count = int(baAvatarPal1.length);
            avatarPalette1 = new Array(count);
            i = 0;
            while(i < count)
            {
               avatarPalette1[i++] = baAvatarPal1.readUnsignedByte();
            }
         }
         if(Boolean(baAvatarPal2))
         {
            baAvatarPal2.position = 0;
            count = int(baAvatarPal2.length);
            avatarPalette2 = new Array(count);
            i = 0;
            while(i < count)
            {
               avatarPalette2[i++] = baAvatarPal2.readUnsignedByte();
            }
         }
      }
      
      public static function mixColors(color1:uint, color2:uint) : uint
      {
         var r1:uint = uint(color1 >> 16 & 0xFF);
         var g1:uint = uint(color1 >> 8 & 0xFF);
         var b1:uint = uint(color1 & 0xFF);
         var r2:uint = uint(color2 >> 16 & 0xFF);
         var g2:uint = uint(color2 >> 8 & 0xFF);
         var b2:uint = uint(color2 & 0xFF);
         r1 = (r1 + r2) / 2;
         g1 = (g1 + g2) / 2;
         b1 = (b1 + b2) / 2;
         return r1 << 16 | g1 << 8 | b1;
      }
      
      public static function setColorGradient(palette:Array, color:uint, offset:uint, count:uint) : void
      {
         var c:uint = 0;
         var r:uint = uint(color >> 16 & 0xFF);
         var g:uint = uint(color >> 8 & 0xFF);
         var b:uint = uint(color & 0xFF);
         var r1:uint = r / (count + 2);
         var g1:uint = g / (count + 2);
         var b1:uint = b / (count + 2);
         var index:int = offset + count - 1;
         for(var i:uint = 0; i < count; i++)
         {
            c = uint(r << 16 | g << 8 | b);
            palette[index] = c | 255 << 24;
            palette[index + PALETTE_ALPHA_OFFSET] = c | 192 << 24;
            palette[index + PALETTE_ALPHA_OFFSET * 2] = c | 128 << 24;
            palette[index + PALETTE_ALPHA_OFFSET * 3] = c | 64 << 24;
            r -= r1;
            g -= g1;
            b -= b1;
            index--;
         }
      }
      
      public static function AddRGB(color:uint, r:int, g:int, b:int) : uint
      {
         var ac:int = color >> 24 & 0xFF;
         var rc:int = color >> 16 & 0xFF;
         var gc:int = color >> 8 & 0xFF;
         var bc:int = color & 0xFF;
         rc += r;
         if(rc < 0)
         {
            rc = 0;
         }
         else if(rc > 255)
         {
            rc = 255;
         }
         gc += g;
         if(gc < 0)
         {
            gc = 0;
         }
         else if(gc > 255)
         {
            gc = 255;
         }
         bc += b;
         if(bc < 0)
         {
            bc = 0;
         }
         else if(bc > 255)
         {
            bc = 255;
         }
         return uint(ac << 24 | rc << 16 | gc << 8 | bc);
      }
      
      public static function getAnimalPalette() : Array
      {
         var j:int = 0;
         var c:uint = 0;
         var nc:uint = 0;
         var ret:Array = new Array(uint(4278255615),uint(4286513152),uint(4290707456),uint(4294901760),uint(4278222592),uint(4278238976),uint(4278255360),uint(4278190207),uint(4278190271),uint(4278190335),uint(4286545791),uint(4290756543),uint(4294967295),uint(4282400768),uint(4286611456),uint(4278206528),uint(4278222976),uint(4282384448),uint(4286578816),uint(4286595136),uint(4294934656),uint(4282417216),uint(4286644096),uint(4282400896),uint(4286611711),uint(4278190080));
         var a:uint = uint(192 << 24);
         for(var i:int = 0; i < 3; i++)
         {
            for(j = 1; j <= PALETTE_ALPHA_OFFSET; j++)
            {
               c = uint(ret[j] & 0xFFFFFF);
               nc = uint(c | a);
               ret.push(nc);
            }
            a -= 64 << 24;
         }
         return ret;
      }
      
      public static function BuildAnimalPalette(_palette:Array, color1:uint, color2:uint, color3:uint, color4:uint) : void
      {
         setColorGradient(_palette,color1,1,3);
         setColorGradient(_palette,color2,4,3);
         setColorGradient(_palette,color3,7,3);
         setColorGradient(_palette,color4,10,3);
         setColorGradient(_palette,PaletteHelper.mixColors(color1,color2),13,2);
         setColorGradient(_palette,PaletteHelper.mixColors(color2,color3),15,2);
         setColorGradient(_palette,PaletteHelper.mixColors(color1,color3),17,2);
         setColorGradient(_palette,PaletteHelper.mixColors(color1,color4),19,2);
         setColorGradient(_palette,PaletteHelper.mixColors(color2,color4),21,2);
         setColorGradient(_palette,PaletteHelper.mixColors(color3,color4),23,2);
      }
      
      public static function adjustPaletteColor(_palette:Array, argb:uint) : void
      {
         var i:int = 0;
         var color:uint = 0;
         var ac:int = 0;
         var rc:int = 0;
         var gc:int = 0;
         var bc:int = 0;
         var a:Number = NaN;
         var percent:Number = (argb >> 24 & 0xFF) / 255;
         var ra:int = argb >> 16 & 0xFF;
         var ga:int = argb >> 8 & 0xFF;
         for(var ba:int = argb & 0xFF; i < _palette.length; )
         {
            color = uint(_palette[i]);
            ac = color >> 24 & 0xFF;
            rc = color >> 16 & 0xFF;
            gc = color >> 8 & 0xFF;
            bc = color & 0xFF;
            a = ra - rc;
            a *= percent;
            rc += a;
            if(rc < 0)
            {
               rc = 0;
            }
            else if(rc > 255)
            {
               rc = 255;
            }
            a = ga - gc;
            a *= percent;
            gc += a;
            if(gc < 0)
            {
               gc = 0;
            }
            else if(gc > 255)
            {
               gc = 255;
            }
            a = ba - bc;
            a *= percent;
            bc += a;
            if(bc < 0)
            {
               bc = 0;
            }
            else if(bc > 255)
            {
               bc = 255;
            }
            _palette[i] = uint(ac << 24 | rc << 16 | gc << 8 | bc);
            i++;
         }
      }
      
      public static function getRGBColors(packedColors:uint) : Array
      {
         var colors:Array = [];
         colors[0] = decToRGBObj(gamePalette[packedColors >> 24 & 0xFF]);
         colors[1] = decToRGBObj(gamePalette[packedColors >> 16 & 0xFF]);
         colors[2] = decToRGBObj(gamePalette[packedColors >> 8 & 0xFF]);
         colors[3] = decToRGBObj(gamePalette[packedColors & 0xFF]);
         return colors;
      }
      
      private static function decToRGBObj(hex:uint) : Object
      {
         return {
            "r":hex >> 16 & 0xFF,
            "g":hex >> 8 & 0xFF,
            "b":hex & 0xFF
         };
      }
   }
}

